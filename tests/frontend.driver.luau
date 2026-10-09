local Config = require("../src/shared/Config")
local Presentation = require("../src/shared/Presentation")
local gui = Instance.new("ScreenGui")
local accepted, started, opened = 0, 0, ""
local front = FrontEnd.new(gui, UI, Config, Presentation, {
    accepted = function() accepted += 1 end,
    start = function() started += 1 end,
    open = function(kind) opened = kind end,
    reset = function() end,
})
local enter = gui:FindFirstChild("EnterMenu", true)
local ack = gui:FindFirstChild("Acknowledge", true)
assert(front.warning.Visible and not front.menu.Visible)
enter.Activated:Fire()
assert(not front.accepted, "Cannot bypass acknowledgement")
ack.Activated:Fire()
enter.Activated:Fire()
assert(not front.accepted, "Cannot enter before server state")
front:setReady(true, false)
enter.Activated:Fire()
assert(not front.accepted, "Cannot enter before world is loaded")
front:setReady(nil, true)
ack.Activated:Fire()
enter.Activated:Fire()
assert(not front.accepted, "Unticking acknowledgement must disable entry")
front:resize(1280, 800)
print(json({ screen = "warning-desktop", width = 1280, height = 800, tree = tree(gui) }))
front:resize(390, 844)
print(json({ screen = "warning-mobile", width = 390, height = 844, tree = tree(gui) }))
ack.Activated:Fire()
enter.Activated:Fire()
enter.Activated:Fire()
assert(front.accepted and accepted == 1 and not front.warning.Visible and front.menu.Visible)
front.start.Text = "Rozpocznij historię  →"
front.start.Activated:Fire()
assert(started == 1)
gui:FindFirstChild("credits", true).Activated:Fire()
assert(opened == "credits")
front:resize(1280, 800)
print(json({ screen = "menu-desktop", width = 1280, height = 800, tree = tree(gui) }))
front:resize(390, 844)
print(json({ screen = "menu-mobile", width = 390, height = 844, tree = tree(gui) }))
for _, size in ipairs({ { 320, 568 }, { 390, 844 }, { 844, 390 }, { 1280, 720 }, { 1920, 1080 } }) do
    local L = Presentation.layout(table.unpack(size))
    assert(L.menuWidth + 2 * L.margin <= size[1] + 1)
    assert(L.panelWidth <= size[1] and L.panelHeight <= size[2])
end
print("PASS Frontend: acknowledgement, loading, world readiness, single entry, navigation and five viewport sizes")

-- Real interaction handler must release a simulated touch hold when a prompt disappears.
local hint = Interaction.new(gui, UI)
local prompt = Instance.new("ProximityPrompt")
prompt.Name, prompt.Parent, prompt.Enabled = "StoryPrompt", gui, true
prompt.HoldDuration, prompt.ObjectText, prompt.ActionText = 0.15, "Lena", "Porozmawiaj"
local button = hint:FindFirstChildOfClass("TextButton")
promptService.PromptShown:Fire(prompt, Enum.ProximityPromptInputType.Touch)
assert(hint.Visible)
button.Activated:Fire()
assert(prompt:GetAttribute("began") == 1)
promptService.PromptHidden:Fire(prompt)
assert(not hint.Visible and prompt:GetAttribute("ended") == 1)
drain()
assert(prompt:GetAttribute("ended") == 1, "A stale timer must not release the same hold twice")
promptService.PromptShown:Fire(prompt, Enum.ProximityPromptInputType.Gamepad)
button.Activated:Fire()
button.Activated:Fire()
assert(prompt:GetAttribute("began") == 3 and prompt:GetAttribute("ended") == 2)
drain()
assert(prompt:GetAttribute("ended") == 3, "Only the latest timer releases the latest hold")
prompt.Enabled = false
button.Activated:Fire()
assert(prompt:GetAttribute("began") == 3)
print("PASS Interaction: touch cleanup, stale timer cancellation, repeated activation and disabled prompts")
