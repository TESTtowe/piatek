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
enter.Activated:Fire()
assert(not front.accepted, "Cannot enter until the image or fallback is ready")
front:setReady(nil, nil, true)
ack.Activated:Fire()
enter.Activated:Fire()
assert(not front.accepted, "Unticking acknowledgement must disable entry")
front:resize(2560, 1440)
print(json({ screen = "warning-desktop", width = 2560, height = 1440, tree = tree(gui) }))
front:resize(390, 844)
print(json({ screen = "warning-mobile", width = 390, height = 844, tree = tree(gui) }))
ack.Activated:Fire()
enter.Activated:Fire()
enter.Activated:Fire()
drain()
drain()
assert(front.accepted and accepted == 1 and not front.warning.Visible and front.menu.Visible)
front.start.Text = "Rozpocznij historię  →"
front.start.Activated:Fire()
assert(started == 1)
gui:FindFirstChild("credits", true).Activated:Fire()
assert(opened == "credits")
front:resize(2560, 1440)
print(json({ screen = "menu-desktop", width = 2560, height = 1440, tree = tree(gui) }))
front:resize(390, 844)
print(json({ screen = "menu-mobile", width = 390, height = 844, tree = tree(gui) }))
for _, size in ipairs({ { 320, 568 }, { 390, 844 }, { 844, 390 }, { 1280, 720 }, { 1920, 1080 }, { 2560, 1440 }, { 3840, 2160 } }) do
    local L = Presentation.layout(table.unpack(size))
    assert(L.menuWidth + 2 * L.margin <= size[1] + 1)
    assert(L.panelWidth <= size[1] and L.panelHeight <= size[2])
end
print("PASS Frontend: acknowledgement, loading, world readiness, single entry, transition, art readiness, navigation and seven viewport sizes")
local close = UI.button(gui, "×", function() end, { Size = UDim2.fromOffset(38, 38), TextSize = 24 })
local closePadding = close:FindFirstChildOfClass("UIPadding")
assert(close.Size.X.Offset - closePadding.PaddingLeft.Offset - closePadding.PaddingRight.Offset >= close.TextSize,
    "The modal close control must have room to render its glyph")
close:Destroy()

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

-- Execute the real image lifecycle against controlled API failure modes.
local function testImageData()
    return { width = 2, height = 1, tiles = {
        { x = 0, y = 0, width = 1, height = 1, data = "test" },
        { x = 1, y = 0, width = 1, height = 1, data = "test" },
    } }
end
local statuses = {}
local image = ArtBackground.new(gui, UI, { MenuImage = "" }, function(status) table.insert(statuses, status) end, testImageData)
assert(image.status == "image" and image.photo.Visible and #image.images == 2)
assert(#statuses == 1 and statuses[1] == "image")
image:resize(320, 180)
assert(image.photo.Size.X.Offset == 360 and image.photo.Size.Y.Offset == 180)
local retained = table.clone(image.images)
image:destroy()
for _, object in ipairs(retained) do assert(object:GetAttribute("Destroyed")) end
assetMock.objects, assetMock.attempts, assetMock.failAfter = {}, 0, 1
statuses = {}
local fallback = ArtBackground.new(gui, UI, { MenuImage = "" }, function(status) table.insert(statuses, status) end, testImageData)
assert(fallback.status == "scene" and not fallback.photo.Visible and #fallback.images == 0)
assert(assetMock.objects[1]:GetAttribute("Destroyed"), "Partial allocations must be cleaned up")
assert(#statuses == 1 and statuses[1] == "scene", "Failure must unblock the entry gate exactly once")
fallback:destroy()
assetMock.attempts = 0
local published = ArtBackground.new(gui, UI, { MenuImage = "rbxassetid://example" }, function() end,
    function() error("Published assets must bypass the embedded decoder") end)
assert(published.status == "image" and assetMock.attempts == 0)
published:destroy()
assetMock.publishedStatus = Enum.AssetFetchStatus.Failure
local unavailable = ArtBackground.new(gui, UI, { MenuImage = "rbxassetid://example" }, function(status)
    assert(status == "scene")
end)
assert(unavailable.status == "scene" and not unavailable.photo.Visible)
unavailable:destroy()
print("PASS Art lifecycle adapter: tile binding, cover, disposal, partial memory failure, ready callback and published asset success/failure")
