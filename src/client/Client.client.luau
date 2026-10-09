local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Friday")
local Config = require(Shared:WaitForChild("Config"))
local Campaign = require(Shared:WaitForChild("Campaign"))
local FactBook = require(Shared:WaitForChild("FactBook"))
local WorldData = require(Shared:WaitForChild("WorldData"))
local UI = require(script.Parent:WaitForChild("UI"))
local FrontEnd = require(script.Parent:WaitForChild("FrontEnd"))
local SceneDirector = require(script.Parent:WaitForChild("SceneDirector"))
local Interaction = require(script.Parent:WaitForChild("Interaction"))
local Presentation = require(Shared:WaitForChild("Presentation"))
local C = UI.colors
local network = Shared:WaitForChild("Network")
local command = network:WaitForChild("Command")
local event = network:WaitForChild("Event")
local camera = workspace.CurrentCamera
local scene = SceneDirector.new(camera, Lighting, WorldData)
local state, activeToken, mode, puzzleAnswer, puzzleDefinition
local pendingChapter, pendingEnd, puzzleFeedback, submitButton
local menuOpen, panelOpen, hasStarted = true, false, false
local directions, resetDeadline = true, 0
local marker, highlight, front
local modalSpeaker, dialogueTarget
local layoutPanel
local showChapter, showEnding, renderState, closePanel
local gui = UI.make("ScreenGui", { Name = "FridayInterface", ResetOnSpawn = false, DisplayOrder = 10,
    ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, player:WaitForChild("PlayerGui"))
local function viewport()
    local size = gui.AbsoluteSize
    return size.X > 0 and size.Y > 0 and size or camera.ViewportSize
end
Interaction.new(gui, UI)
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end)

local function send(action, payload) command:FireServer(action, payload) end
local function freeze()
    local blocked = menuOpen or panelOpen or not front or not front.accepted
    if blocked then
        ContextActionService:BindActionAtPriority("FridayModal", function() return Enum.ContextActionResult.Sink end, false, 3000,
            Enum.PlayerActions.CharacterForward, Enum.PlayerActions.CharacterBackward, Enum.PlayerActions.CharacterLeft,
            Enum.PlayerActions.CharacterRight, Enum.PlayerActions.CharacterJump)
    else
        ContextActionService:UnbindAction("FridayModal")
    end
    -- Blokada Humanoid obejmuje także mobilny joystick.
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if blocked then
            if humanoid:GetAttribute("FridayWalkSpeed") == nil then humanoid:SetAttribute("FridayWalkSpeed", humanoid.WalkSpeed) end
            if humanoid:GetAttribute("FridayAutoRotate") == nil then humanoid:SetAttribute("FridayAutoRotate", humanoid.AutoRotate) end
            humanoid.WalkSpeed = 0
            humanoid.AutoRotate = false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        else
            humanoid.WalkSpeed = humanoid:GetAttribute("FridayWalkSpeed") or 13
            local original = humanoid:GetAttribute("FridayAutoRotate")
            humanoid.AutoRotate = original == nil or original
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            humanoid:SetAttribute("FridayWalkSpeed", nil)
            humanoid:SetAttribute("FridayAutoRotate", nil)
        end
    end
end

local hud = UI.frame(gui, { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false })
local top = UI.frame(hud, { Size = UDim2.new(1, 0, 0, 72), BackgroundTransparency = 0.12, BackgroundColor3 = C.ink })
UI.make("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0.15, 1) }, top)
UI.text(top, "PIĄTEK", { Position = UDim2.fromOffset(22, 13), Size = UDim2.fromOffset(155, 22), TextSize = 13, Font = Enum.Font.GothamBold, TextColor3 = C.amber })
local chapterLabel = UI.text(top, "", { Position = UDim2.fromOffset(22, 37), Size = UDim2.new(0.6, -22, 0, 22), TextSize = 14 })
local journalButton = UI.button(top, "Zeszyt  [J]", function()
    if panelOpen or menuOpen then return end
    mode = "journal"
    panelOpen = true
    renderState()
end, { Position = UDim2.new(1, -154, 0, 17), Size = UDim2.fromOffset(132, 38) })
local questPanel = UI.frame(hud, { Position = UDim2.fromOffset(22, 94), Size = UDim2.fromOffset(328, 123), BackgroundTransparency = 0.18, BackgroundColor3 = C.ink })
UI.corner(questPanel, 3)
UI.rule(questPanel, UDim2.fromOffset(0, 0), UDim2.new(0, 2, 1, 0), C.amber)
UI.text(questPanel, "DO ZROBIENIA", { Position = UDim2.fromOffset(16, 14), Size = UDim2.new(1, -32, 0, 20), TextSize = 11, TextColor3 = C.amber, Font = Enum.Font.GothamBold })
local questText = UI.text(questPanel, "", { Position = UDim2.fromOffset(16, 40), Size = UDim2.new(1, -32, 0, 50), TextSize = 17, Font = Enum.Font.GothamMedium })
local progressTrack = UI.frame(questPanel, { Position = UDim2.new(0, 16, 1, -14), Size = UDim2.new(1, -32, 0, 3), BackgroundColor3 = C.line })
local progressFill = UI.frame(progressTrack, { Size = UDim2.new(), BackgroundColor3 = C.amber })
local hint = UI.text(hud, "E · interakcja    J · zeszyt    M · menu", { Position = UDim2.new(0, 22, 1, -36), Size = UDim2.new(1, -220, 0, 24), TextSize = 12, TextColor3 = C.paper, TextStrokeTransparency = 0.4 })
local distanceText = UI.text(questPanel, "", { Position = UDim2.new(1, -66, 0, 13), Size = UDim2.fromOffset(50, 18), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.muted })

local map = UI.frame(hud, { Position = UDim2.new(1, -190, 1, -210), Size = UDim2.fromOffset(168, 166), BackgroundTransparency = 0.1 })
UI.corner(map, 3)
UI.stroke(map)
UI.text(map, "PLAN SZKOŁY", { Position = UDim2.fromOffset(12, 10), TextSize = 10, TextColor3 = C.amber })
local mapArea = UI.frame(map, { Position = UDim2.fromOffset(12, 34), Size = UDim2.fromOffset(144, 116), BackgroundColor3 = C.ink, ClipsDescendants = true })
UI.corner(mapArea, 6)
UI.frame(mapArea, { Position = UDim2.fromScale(0.08, 0.07), Size = UDim2.fromScale(0.84, 0.49), BackgroundColor3 = C.line })
UI.frame(mapArea, { Position = UDim2.fromScale(0.41, 0.07), Size = UDim2.fromScale(0.18, 0.49), BackgroundColor3 = C.muted, BackgroundTransparency = 0.8 })
UI.text(mapArea, "DZIEDZINIEC", { Position = UDim2.fromScale(0.18, 0.73), Size = UDim2.fromScale(0.7, 0.15), TextSize = 9, TextColor3 = C.muted })
local mapTarget = UI.frame(mapArea, { Size = UDim2.fromOffset(9, 9), BackgroundColor3 = C.amber, AnchorPoint = Vector2.new(0.5, 0.5) })
UI.corner(mapTarget, 9)
local mapPlayer = UI.frame(mapArea, { Size = UDim2.fromOffset(6, 6), BackgroundColor3 = C.paper, AnchorPoint = Vector2.new(0.5, 0.5) })
UI.corner(mapPlayer, 9)

local toast = UI.frame(gui, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -52), Size = UDim2.new(0.7, 0, 0, 76), BackgroundColor3 = C.ink, Visible = false, ZIndex = 30 })
UI.corner(toast, 3)
UI.stroke(toast, C.teal)
local toastText = UI.text(toast, "", { Position = UDim2.fromOffset(16, 13), Size = UDim2.new(1, -32, 1, -26), TextSize = 15, ZIndex = 31, TextYAlignment = Enum.TextYAlignment.Center })
local toastGeneration = 0
local function notify(text)
    toastGeneration += 1
    local generation = toastGeneration
    toastText.Text = text
    toast.Visible = true
    task.delay(4.5, function() if generation == toastGeneration then toast.Visible = false end end)
end

front = FrontEnd.new(gui, UI, Config, Presentation, {
    start = function()
        if not state or not front.accepted then return end
        if state.completed then showEnding(); return end
        if hasStarted then
            menuOpen = false
            hud.Visible = true
            camera.CameraType = Enum.CameraType.Custom
            renderState()
        else send("Start") end
    end,
    accepted = function() renderState() end,
    open = function(kind)
        if not front.accepted then return end
        mode, panelOpen = kind, true
        renderState()
    end,
    reset = function()
        if not state or not front.accepted then return end
        if os.clock() > resetDeadline then
            resetDeadline = os.clock() + 5
            front.reset.Text = "Jeszcze raz: rozpocznij od nowa"
            task.delay(5, function()
                if os.clock() >= resetDeadline then front.reset.Text = "Rozpocznij od nowa" end
            end)
            return
        end
        resetDeadline = 0
        hasStarted = false
        pendingChapter, pendingEnd = nil, false
        send("Reset")
        front.reset.Text = "Rozpocznij od nowa"
    end,
})
local menu, startButton, resetButton = front.menu, front.start, front.reset

local overlay = UI.frame(gui, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Visible = false, ZIndex = 40, Active = true })
local panel = UI.frame(overlay, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(680, 590), BackgroundColor3 = C.ink, ZIndex = 41 })
UI.corner(panel, 4)
UI.rule(panel, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 2), C.amber, 42)
UI.stroke(panel)
local panelEyebrow = UI.text(panel, "", { Position = UDim2.fromOffset(24, 20), Size = UDim2.new(1, -100, 0, 19), TextColor3 = C.amber, TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 42 })
local panelTitle = UI.text(panel, "", { Position = UDim2.fromOffset(24, 48), Size = UDim2.new(1, -100, 0, 56), TextSize = 25, Font = Enum.Font.GothamMedium, ZIndex = 42 })
local speakerPortrait = UI.make("ViewportFrame", { Name = "SpeakerPortrait", Position = UDim2.fromOffset(24, 46), Size = UDim2.fromOffset(52, 52),
    BackgroundColor3 = C.panel, BorderSizePixel = 0, Ambient = Color3.fromRGB(170, 174, 182), LightColor = C.paper,
    LightDirection = Vector3.new(-1, -0.5, -1), Visible = false, ZIndex = 42 }, panel)
UI.corner(speakerPortrait, 3)
local function portrait(target)
    for _, child in ipairs(speakerPortrait:GetChildren()) do if not child:IsA("UICorner") then child:Destroy() end end
    local root = workspace:FindFirstChild("FridayWorld")
    local interactions = root and root:FindFirstChild("Interactions")
    local npc = interactions and interactions:FindFirstChild(target or "")
    speakerPortrait.Visible = npc ~= nil and npc:IsA("Model")
    if not speakerPortrait.Visible then return end
    local model = npc:Clone()
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("ProximityPrompt") or child:IsA("BillboardGui") then child:Destroy() end
    end
    model.Parent = UI.make("WorldModel", {}, speakerPortrait)
    local viewCamera = UI.make("Camera", { FieldOfView = 35 }, speakerPortrait)
    local head = model:FindFirstChild("Head")
    if head then
        local focus = head.Position + Vector3.new(0, -0.3, 0)
        viewCamera.CFrame = CFrame.lookAt(focus + head.CFrame.LookVector * 5.5, focus)
    end
    speakerPortrait.CurrentCamera = viewCamera
end
local panelClose = UI.button(panel, "×", function() closePanel() end, { Position = UDim2.new(1, -62, 0, 20), Size = UDim2.fromOffset(38, 38), TextSize = 24, ZIndex = 42 })
local content = UI.scroll(panel, { Position = UDim2.fromOffset(24, 115), Size = UDim2.new(1, -48, 1, -139), ZIndex = 42 })
local function clearContent()
    for _, child in ipairs(content:GetChildren()) do if not child:IsA("UIPadding") then child:Destroy() end end
    UI.list(content, 16)
    content.CanvasPosition = Vector2.zero
    puzzleFeedback, submitButton = nil, nil
end
local function paragraph(value, props)
    local p = { ZIndex = 43 }
    for k, v in pairs(props or {}) do p[k] = v end
    return UI.autoText(content, value, p)
end
local function action(value, callback, props)
    local p = { ZIndex = 43, Size = UDim2.new(1, -3, 0, 56) }
    for k, v in pairs(props or {}) do p[k] = v end
    return UI.button(content, value, callback, p)
end
local function panelHeading(eyebrow, title)
    clearContent()
    layoutPanel()
    speakerPortrait.Visible = false
    panelTitle.Position = UDim2.fromOffset(24, 48)
    panelTitle.Size = UDim2.new(1, -100, 0, 56)
    panelEyebrow.Text = eyebrow
    panelTitle.Text = title
    overlay.Visible = true
    freeze()
end

layoutPanel = function()
    local size = viewport()
    local L = Presentation.layout(size.X, size.Y)
    local conversation = mode == "dialogue" or mode == "reply"
    overlay.BackgroundTransparency = conversation and 0.72 or 0.32
    panel.AnchorPoint = Vector2.new(0.5, conversation and 1 or 0.5)
    panel.Position = conversation and UDim2.new(0.5, 0, 1, -18) or UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.fromOffset(L.panelWidth, conversation and math.min(L.panelHeight, size.Y < 540 and 290 or 390) or L.panelHeight)
    panelTitle.TextSize = L.compact and 22 or 28
end

local chapterCard = UI.frame(gui, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink, BackgroundTransparency = 0.1, Visible = false, ZIndex = 35 })
UI.text(chapterCard, "ROZDZIAŁ", { Position = UDim2.fromScale(0.1, 0.28), Size = UDim2.fromScale(0.8, 0.06), TextColor3 = C.amber, TextSize = 14, ZIndex = 36 })
local chapterTitle = UI.text(chapterCard, "", { Position = UDim2.fromScale(0.1, 0.38), Size = UDim2.fromScale(0.8, 0.25), TextSize = 48, Font = Enum.Font.Oswald, ZIndex = 36 })
local chapterSub = UI.text(chapterCard, "", { Position = UDim2.fromScale(0.1, 0.69), Size = UDim2.fromScale(0.8, 0.15), TextSize = 18, TextColor3 = C.muted, ZIndex = 36 })
local chapterGeneration = 0
showChapter = function(index)
    local chapter = Campaign.chapters[index]
    if not chapter then return end
    if panelOpen then pendingChapter = index; return end
    chapterGeneration += 1
    local generation = chapterGeneration
    chapterTitle.Text = string.format("%02d / %s\n%s", index, chapter.time, chapter.title)
    chapterSub.Text = chapter.subtitle
    chapterCard.Visible = true
    task.delay(UI.reducedMotion and 1.5 or 3, function()
        if generation == chapterGeneration then chapterCard.Visible = false end
    end)
end

closePanel = function()
    if activeToken then send("Cancel", { token = activeToken }) end
    activeToken = nil
    panelOpen = false
    mode = nil
    overlay.Visible = false
    puzzleAnswer, puzzleDefinition = nil, nil
    freeze()
    renderState()
    if pendingEnd then pendingEnd = false; showEnding()
    elseif pendingChapter then local index = pendingChapter; pendingChapter = nil; showChapter(index) end
end

local function dialogue(data)
    panelOpen, mode, activeToken = true, "dialogue", data.token
    local objective = data.objective
    dialogueTarget, modalSpeaker = objective.target, objective.speaker
    local page = 1
    local waiting = false
    local function render()
        panelHeading("ROZMOWA", objective.speaker)
        portrait(dialogueTarget)
        if speakerPortrait.Visible then
            panelTitle.Position = UDim2.fromOffset(90, 52)
            panelTitle.Size = UDim2.new(1, -165, 0, 56)
        end
        paragraph(string.format("%02d / %02d", page, #objective.lines), { TextSize = 11, Font = Enum.Font.Code, TextColor3 = C.muted })
        paragraph(objective.lines[page], { TextSize = 21, LineHeight = 1.18 })
        if page < #objective.lines then
            action("Dalej →", function() page += 1; render() end, { BackgroundColor3 = C.teal, TextColor3 = C.ink })
        else
            paragraph("TWOJA ODPOWIEDŹ", { TextSize = 11, TextColor3 = C.amber })
            for _, option in ipairs(objective.choices) do
                action(option.label, function()
                    if waiting then return end
                    waiting = true
                    send("Choice", { token = activeToken, choice = option.id })
                    task.delay(2, function() waiting = false end)
                end, { TextXAlignment = Enum.TextXAlignment.Left })
            end
        end
    end
    render()
end

local function puzzle(data)
    local definition = Campaign.puzzles[data.id]
    if not definition then return end
    puzzleDefinition = definition
    panelOpen, mode, activeToken = true, "puzzle", data.token
    puzzleAnswer = {}
    local page, revealed, ready, sending = 1, false, false, false
    local render
    local function mark(button, selected)
        button.BackgroundColor3 = selected and C.selected or C.panel
        button.TextColor3 = selected and C.paper or C.muted
        local border = button:FindFirstChildOfClass("UIStroke")
        if border then border.Color = selected and C.amber or C.line end
    end
    local function submit()
        if sending or mode ~= "puzzle" or not activeToken then return end
        sending = true
        send("Solve", { token = activeToken, answer = puzzleAnswer })
        task.delay(1, function() sending = false end)
    end
    local function feedback()
        puzzleFeedback = paragraph("", { TextSize = 14, TextColor3 = C.muted, LayoutOrder = 20 })
    end
    render = function()
        if mode ~= "puzzle" then return end
        panelHeading("ZADANIE / " .. string.upper(definition.kind == "order" and "chronologia" or definition.kind == "classify" and "weryfikacja" or "lista grupy"), definition.title)
        paragraph(definition.description, { TextSize = 15, TextColor3 = C.muted, LayoutOrder = 1 })
        if definition.kind == "order" then
            paragraph(string.format("WYBRANO %d Z %d KART", #puzzleAnswer, #definition.cards), { Font = Enum.Font.Code, TextSize = 11, TextColor3 = C.amber, LayoutOrder = 2 })
            -- Wybrane karty przechodzą na początek. Numery pokazują faktyczną kolejność.
            local ordered = {}
            for _, id in ipairs(puzzleAnswer) do
                for _, card in ipairs(definition.cards) do if card.id == id then table.insert(ordered, card) end end
            end
            for _, card in ipairs(definition.cards) do if not table.find(puzzleAnswer, card.id) then table.insert(ordered, card) end end
            for index, card in ipairs(ordered) do
                local picked = table.find(puzzleAnswer, card.id)
                local button = action((picked and string.format("%02d", picked) or "+") .. "    " .. card.text, function()
                    local position = table.find(puzzleAnswer, card.id)
                    if position then table.remove(puzzleAnswer, position) else table.insert(puzzleAnswer, card.id) end
                    render()
                end, { LayoutOrder = index + 2, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -3, 0, 60) })
                mark(button, picked ~= nil)
            end
            action("Wyczyść kolejność", function() puzzleAnswer = {}; render() end,
                { LayoutOrder = 15, Size = UDim2.new(1, -3, 0, 40), TextSize = 12, BackgroundTransparency = 1 })
            feedback()
            submitButton = action("Zatwierdź kolejność  →", submit, { LayoutOrder = 21, BackgroundColor3 = C.paper, TextColor3 = C.ink })
            submitButton:SetAttribute("Disabled", #puzzleAnswer ~= #definition.cards)
        elseif definition.kind == "classify" then
            local card = definition.cards[page]
            paragraph(string.format("DOKUMENT %02d / %02d", page, #definition.cards), { Font = Enum.Font.Code, TextSize = 11, TextColor3 = C.amber, LayoutOrder = 2 })
            local paper = UI.frame(content, { Size = UDim2.new(1, -3, 0, 120), BackgroundColor3 = C.paper, LayoutOrder = 3, ZIndex = 43 })
            UI.rule(paper, UDim2.fromOffset(18, 17), UDim2.fromOffset(30, 2), C.amber, 44)
            UI.text(paper, card.text, { Position = UDim2.fromOffset(18, 35), Size = UDim2.new(1, -36, 1, -50), TextSize = 19,
                Font = Enum.Font.GothamMedium, TextColor3 = C.ink, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 44 })
            paragraph("JAK OZNACZYSZ TEN ZAPIS?", { Font = Enum.Font.Code, TextSize = 11, TextColor3 = C.muted, LayoutOrder = 4 })
            for index, category in ipairs(definition.categories) do
                local chosen = puzzleAnswer[card.id] == category.id
                local button = action((chosen and "●" or "○") .. "    " .. category.label, function()
                    puzzleAnswer[card.id] = category.id
                    render()
                end, { LayoutOrder = 4 + index, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -3, 0, 48) })
                mark(button, chosen)
            end
            feedback()
            submitButton = action(page == #definition.cards and "Sprawdź wszystkie dokumenty  →" or "Zapisz i następny dokument  →", function()
                if not puzzleAnswer[card.id] then return end
                if page < #definition.cards then page += 1; render() else submit() end
            end, { LayoutOrder = 21, BackgroundColor3 = C.paper, TextColor3 = C.ink })
            submitButton:SetAttribute("Disabled", puzzleAnswer[card.id] == nil)
            if page > 1 then action("←  Poprzedni dokument", function() page -= 1; render() end, { LayoutOrder = 22, BackgroundTransparency = 1, TextSize = 12, Size = UDim2.new(1, -3, 0, 36) }) end
        elseif definition.kind == "memory" then
            if not revealed then
                paragraph("LISTA DO ZAPAMIĘTANIA", { Font = Enum.Font.Code, TextSize = 11, TextColor3 = C.amber, LayoutOrder = 2 })
                local names = {}
                for _, id in ipairs(data.memory or {}) do
                    for _, card in ipairs(definition.cards) do if card.id == id then table.insert(names, card.text) end end
                end
                for index, name in ipairs(names) do
                    paragraph(string.format("%02d     %s", index, name), { TextSize = 27, Font = Enum.Font.Oswald, LayoutOrder = index + 2 })
                end
                feedback()
                submitButton = action(ready and "Przejdź do wyboru imion  →" or "Przyjrzyj się spokojnie liście…", function()
                    if not ready then return end
                    revealed = true
                    render()
                end, { LayoutOrder = 21, BackgroundColor3 = ready and C.paper or C.panel, TextColor3 = ready and C.ink or C.muted })
                submitButton:SetAttribute("Disabled", not ready)
            else
                paragraph(string.format("ZAZNACZONO %d / %d", #puzzleAnswer, definition.count), { Font = Enum.Font.Code, TextSize = 11, TextColor3 = C.amber, LayoutOrder = 2 })
                local grid = UI.frame(content, { Size = UDim2.new(1, -3, 0, 202), BackgroundTransparency = 1, LayoutOrder = 3, ZIndex = 43 })
                UI.make("UIGridLayout", { CellSize = UDim2.new(0.5, -6, 0, 62), CellPadding = UDim2.fromOffset(12, 8), SortOrder = Enum.SortOrder.LayoutOrder }, grid)
                for index, card in ipairs(definition.cards) do
                    local button = UI.button(grid, (table.find(puzzleAnswer, card.id) and "●  " or "○  ") .. card.text, function()
                        local selected = table.find(puzzleAnswer, card.id)
                        if selected then table.remove(puzzleAnswer, selected)
                        elseif #puzzleAnswer < definition.count then table.insert(puzzleAnswer, card.id) end
                        render()
                    end, { LayoutOrder = index, TextSize = 17, ZIndex = 44 })
                    mark(button, table.find(puzzleAnswer, card.id) ~= nil)
                end
                feedback()
                submitButton = action("Sprawdź listę  →", submit, { LayoutOrder = 21, BackgroundColor3 = C.paper, TextColor3 = C.ink })
                submitButton:SetAttribute("Disabled", #puzzleAnswer ~= definition.count)
            end
        end
    end
    render()
    if definition.kind == "memory" then
        task.delay(7, function()
            if activeToken == data.token and mode == "puzzle" then ready = true; render() end
        end)
    end
end
showEnding = function()
    if not state then return end
    if panelOpen then pendingEnd = true; return end
    mode, panelOpen = "ending", true
    panelHeading("EPILOG / TWOJA OPOWIEŚĆ", state.endingTitle)
    paragraph(state.endingText, { TextSize = 21 })
    paragraph("Żaden wybór nie zmienia krzywdy w wygraną. To zakończenie opisuje ton twoich rozmów, a nie ocenę reakcji na kryzys.", { TextSize = 15, TextColor3 = C.muted })
    paragraph(Config.SourceNotice, { TextSize = 13, TextColor3 = C.amber })
    action("Otwórz zeszyt", function() mode = "journal"; renderState() end)
    action("Wróć do menu", function()
        pendingEnd = false
        closePanel()
        menuOpen = true
        menu.Visible = true
        hud.Visible = false
        freeze()
    end)
end

local function mapPosition(position)
    return UDim2.fromScale(math.clamp((position.X + 90) / 180, 0, 1), math.clamp((position.Z + 76) / 190, 0, 1))
end

local function updateMarker()
    if marker then marker:Destroy(); marker = nil end
    if highlight then highlight:Destroy(); highlight = nil end
    if not state then return end
    local chapter = Campaign.chapters[state.chapter]
    local objective = not state.completed and chapter.objectives[state.step] or nil
    local world = workspace:FindFirstChild("FridayWorld")
    local interactions = world and world:FindFirstChild("Interactions")
    if not interactions then return end
    local targetId = objective and objective.target
    for _, p in ipairs(interactions:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            p.Enabled = state.started and not state.completed and not panelOpen and not menuOpen and p.Parent:GetAttribute("TargetId") == targetId
        end
    end
    mapTarget.Visible = objective ~= nil and directions
    if not objective then return end
    local object = interactions:FindFirstChild(targetId)
    local handle = object and (object:IsA("Model") and object.PrimaryPart or object)
    if not handle then return end
    mapTarget.Position = mapPosition(handle.Position)
    if not directions then return end
    marker = UI.make("BillboardGui", { Name = "QuestMarker", Adornee = handle, Size = UDim2.fromOffset(168, 44), StudsOffset = Vector3.new(0, 5.8, 0), AlwaysOnTop = true, MaxDistance = 150 }, gui)
    local badge = UI.frame(marker, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink, BackgroundTransparency = 0.12 })
    UI.corner(badge, 8)
    UI.stroke(badge, C.amber)
    UI.text(badge, "◇  " .. WorldData.targets[targetId].label, { Position = UDim2.fromOffset(8, 7), Size = UDim2.new(1, -16, 1, -14), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, TextColor3 = C.amber })
    highlight = UI.make("Highlight", { Adornee = object, FillTransparency = 0.9, OutlineTransparency = 0.1, OutlineColor = C.amber, FillColor = C.amber, DepthMode = Enum.HighlightDepthMode.Occluded }, gui)
end

renderState = function()
    overlay.Visible = panelOpen
    menu.Visible = menuOpen and front.accepted
    front:setReady(state ~= nil, nil)
    freeze()
    if state then
        local chapter = Campaign.chapters[state.chapter]
        front.caption.Text = string.format("%02d / %s", state.chapter, string.upper(chapter.title))
        chapterLabel.Text = string.format("%02d / %s · %s", state.chapter, chapter.title, chapter.time)
        questText.Text = state.completed and "Historia ukończona. Zajrzyj do zeszytu." or chapter.objectives[state.step].title
        UI.tween(progressFill, { Size = UDim2.fromScale(state.done / state.total, 1) }, 0.4)
        startButton.Text = state.completed and "Zobacz epilog" or (state.done > 0 or hasStarted) and "Wróć do opowieści →" or "Otwórz pierwszy rozdział →"
        resetButton.Visible = state.done > 0 or hasStarted
        UI.tween(Lighting, { ClockTime = chapter.clock }, 2)
    end
    if mode == "journal" then
        panelHeading("TWÓJ ZESZYT / ZAPIS ROZMÓW", "To, co zostaje")
        if not state or #state.journal == 0 then paragraph("Pierwsza strona jest jeszcze pusta. Porozmawiaj z Leną na dziedzińcu.", { TextColor3 = C.muted })
        else
            for index, entry in ipairs(state.journal) do
                paragraph(string.format("%02d   %s", index, entry), { TextSize = 17 })
            end
        end
        if state then
            local persistence = state.saving == "session" and "Postęp przechowywany w bieżącej sesji." or state.saving == "saved" and "Postęp zapisany w DataStore." or state.saving == "failed" and "Zapis nie powiódł się; postęp jest w tej sesji." or "Zapis postępu: oczekiwanie."
            paragraph(state.loadWarning or persistence, { TextSize = 13, TextColor3 = C.amber })
        end
    elseif mode == "credits" then
        panelHeading("TWÓRCY", "Autorzy projektu")
        for _, credit in ipairs(Config.Credits) do
            paragraph(credit.role, { TextSize = 11, Font = Enum.Font.Code, TextColor3 = C.amber })
            paragraph(credit.name, { TextSize = 26, Font = Enum.Font.Oswald })
        end
        paragraph("Opracowanie dokumentalne", { TextSize = 17 })
        paragraph("Policja, Prokuratura Okręgowa w Ostrołęce, Ministerstwo Edukacji Narodowej. Uzupełniające relacje: Polsat News i RMF24.", { TextSize = 14, TextColor3 = C.muted })
        paragraph("Wersja " .. Config.Version .. " · Pełne źródła dostępne w archiwum wydarzeń.", { TextSize = 12, TextColor3 = C.muted })
    elseif mode == "chapters" then
        panelHeading("OPOWIEŚĆ / SZEŚĆ ROZDZIAŁÓW", "Spis rozdziałów")
        for index, chapter in ipairs(Campaign.chapters) do
            local status = not state and "NIE ROZPOCZĘTO" or state.completed and "UKOŃCZONY" or index < state.chapter and "UKOŃCZONY" or index == state.chapter and "BIEŻĄCY" or "PRZED TOBĄ"
            paragraph(string.format("%02d    %s    /    %s", index, chapter.time, status), { TextSize = 11, Font = Enum.Font.Code, TextColor3 = index == (state and state.chapter) and C.amber or C.muted })
            paragraph(chapter.title, { TextSize = 23, Font = Enum.Font.Oswald })
            paragraph(chapter.subtitle, { TextSize = 14, TextColor3 = C.muted })
        end
    elseif mode == "about" then
        panelHeading("O PROJEKCIE / ŹRÓDŁA", "Historia wymaga źródeł")
        paragraph(Config.SourceNotice, { TextSize = 18, TextColor3 = C.amber })
        paragraph("Grasz jako członek fikcyjnej klasy. Rozmawiasz, porządkujesz informacje i zapisujesz cudze słowa za zgodą rozmówców. Przebieg zdarzenia pozostaje poza sceną.")
        paragraph("STEROWANIE\nPC: WASD, mysz, E — interakcja, J — zeszyt, M — menu. Telefon: joystick i przyciski na ekranie. Kontroler: ruch oraz systemowe podpowiedzi interakcji; przyciski UI obsługują wybór.", { TextSize = 15 })
        paragraph("PRAWDA I FABUŁA\nArchiwum faktów przytacza wybrane komunikaty Policji i podaje źródła. Fabuła nie rekonstruuje konkretnej szkoły ani losów prawdziwych osób. Materiały minigier są fikcyjne.", { TextSize = 15 })
        paragraph(FactBook.caveat, { TextSize = 14, TextColor3 = C.muted })
        paragraph("To opowieść o rozmowach. Nie jest poradnikiem reagowania na atak ani symulacją zachowania służb.", { TextSize = 14, TextColor3 = C.muted })
        paragraph("Potrzebujesz przerwy? Wróć do menu. W realnym bezpośrednim zagrożeniu w Polsce numer alarmowy to 112; wykonuj polecenia służb i odpowiedzialnych dorosłych.", { TextSize = 14, TextColor3 = C.muted })
    elseif mode == "facts" then
        panelHeading("ARCHIWUM / UDOKUMENTOWANE DONIESIENIA", "Co potwierdzono?")
        paragraph(FactBook.scope, { TextSize = 15, TextColor3 = C.muted })
        paragraph(FactBook.caveat, { TextSize = 14, TextColor3 = C.amber })
        for _, entry in ipairs(FactBook.entries) do
            local source = FactBook.sources[entry.source]
            paragraph(entry.category, { TextSize = 11, TextColor3 = C.teal })
            paragraph(entry.place, { TextSize = 21, Font = Enum.Font.GothamMedium })
            paragraph(entry.text, { TextSize = 16 })
            paragraph(source.publisher .. " · publikacja " .. source.date .. " · " .. entry.source, { TextSize = 12, TextColor3 = C.muted })
        end
        paragraph("Źródła i ich pełne adresy zapisano także w dokumentacji projektu. Data przy wpisie oznacza datę publikacji komunikatu; opis odnosi się do stanu podanego w źródle.", { TextSize = 13, TextColor3 = C.muted })
    elseif mode == "settings" then
        panelHeading("USTAWIENIA / KOMFORT", "W twoim tempie")
        local motionButton
        motionButton = action("Ogranicz ruch: " .. (UI.reducedMotion and "tak" or "nie"), function()
            UI.reducedMotion = not UI.reducedMotion
            motionButton.Text = "Ogranicz ruch: " .. (UI.reducedMotion and "tak" or "nie")
        end)
        local directionsButton
        directionsButton = action("Znaczniki zadań: " .. (directions and "widoczne" or "ukryte"), function()
            directions = not directions
            directionsButton.Text = "Znaczniki zadań: " .. (directions and "widoczne" or "ukryte")
            updateMarker()
        end)
        paragraph("Dialogi przewijasz samodzielnie. Minigry mają nieograniczoną liczbę prób. Lista pamięci pozostaje widoczna, aż wybierzesz następną stronę.", { TextColor3 = C.muted, TextSize = 15 })
    end
    updateMarker()
end

local function openMenu()
    if not front.accepted then return end
    if panelOpen then closePanel() end
    menuOpen = not menuOpen
    menu.Visible = menuOpen
    hud.Visible = not menuOpen and hasStarted
    if not menuOpen then camera.CameraType = Enum.CameraType.Custom end
    freeze()
    updateMarker()
end

local menuButton = UI.button(hud, "Menu", openMenu, { Position = UDim2.new(1, -102, 0, 85), Size = UDim2.fromOffset(80, 35), TextSize = 13 })

event.OnClientEvent:Connect(function(kind, data)
    if kind == "State" then
        local wasStarted = hasStarted
        local wasCompleted = state and state.completed
        state = data
        hasStarted = data.started
        if hasStarted and not wasStarted then
            menuOpen = false
            menu.Visible = false
            hud.Visible = true
            camera.CameraType = Enum.CameraType.Custom
        elseif not hasStarted then
            menuOpen = true
            menu.Visible = true
            hud.Visible = false
        end
        renderState()
        if data.completed and hasStarted and not wasCompleted then
            if panelOpen then pendingEnd = true else showEnding() end
        end
    elseif kind == "Dialogue" then
        dialogue(data); updateMarker()
    elseif kind == "Reply" then
        activeToken = nil
        mode = "reply"
        panelHeading("ROZMOWA", modalSpeaker or "Rozmówca")
        portrait(dialogueTarget)
        if speakerPortrait.Visible then
            panelTitle.Position = UDim2.fromOffset(90, 52)
            panelTitle.Size = UDim2.new(1, -165, 0, 56)
        end
        paragraph(data.text, { TextSize = 21 })
        action("Wróć do opowieści →", closePanel, { BackgroundColor3 = C.teal, TextColor3 = C.ink })
    elseif kind == "Puzzle" then
        puzzle(data); updateMarker()
    elseif kind == "PuzzleResult" then
        if mode ~= "puzzle" then return end
        if puzzleFeedback then puzzleFeedback.Text = data.message; puzzleFeedback.TextColor3 = data.ok and C.positive or C.error end
        if data.ok then
            activeToken = nil
            mode = "puzzle_done"
            for _, control in ipairs(content:GetDescendants()) do
                if control:IsA("TextButton") then control:SetAttribute("Disabled", true) end
            end
            if submitButton then submitButton.Visible = false end
            action("Wróć do opowieści  →", closePanel, { BackgroundColor3 = C.teal, TextColor3 = C.ink, LayoutOrder = 30 })
        end
    elseif kind == "Chapter" then
        showChapter(data.index)
    elseif kind == "Toast" then
        notify(data)
    elseif kind == "Expired" then
        activeToken = nil
        closePanel()
        notify(data)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.J and hasStarted and not panelOpen and not menuOpen then
        panelOpen, mode = true, "journal"; renderState()
    elseif input.KeyCode == Enum.KeyCode.M and hasStarted then openMenu()
    elseif input.KeyCode == Enum.KeyCode.ButtonB and panelOpen then closePanel() end
end)

local function resize()
    local size = viewport()
    local compact = size.X < 760
    local inset = GuiService:GetGuiInset()
    front:resize(size.X, size.Y, inset.Y)
    top.Position = UDim2.fromOffset(0, inset.Y)
    questPanel.Position = UDim2.fromOffset(22, 94 + inset.Y)
    menuButton.Position = UDim2.new(1, -102, 0, 85 + inset.Y)
    layoutPanel()
    questPanel.Size = UDim2.fromOffset(compact and math.min(290, size.X - 130) or 328, compact and 140 or 123)
    questText.Size = UDim2.new(1, -32, 0, compact and 70 or 50)
    questText.TextSize = compact and 14 or 17
    map.Visible = size.X >= 780 and size.Y >= 550
    hint.Visible = not UserInputService.TouchEnabled and size.Y > 480
    chapterLabel.Size = compact and UDim2.new(1, -180, 0, 28) or UDim2.new(0.6, -22, 0, 22)
    chapterLabel.TextSize = compact and 11 or 14
    toast.Size = UDim2.fromOffset(math.min(560, size.X - 32), 86)
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
resize()
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    if activeToken then send("Cancel", { token = activeToken }); activeToken = nil end
    if panelOpen then closePanel() end
    freeze()
    if not menuOpen then camera.CameraType = Enum.CameraType.Custom end
end)

local tickAccumulator = 0
RunService.RenderStepped:Connect(function(dt)
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    scene:update(dt, menuOpen, panelOpen and (mode == "dialogue" or mode == "reply"), dialogueTarget, UI.reducedMotion, rootPart and rootPart.Position)
    tickAccumulator += dt
    if tickAccumulator < 0.15 then return end
    tickAccumulator = 0
    local pivot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if pivot then
        mapPlayer.Position = mapPosition(pivot.Position)
        if state and not state.completed then
            local objective = Campaign.chapters[state.chapter].objectives[state.step]
            local position = Vector3.new(table.unpack(WorldData.targets[objective.target].position))
            distanceText.Text = math.floor((position - pivot.Position).Magnitude) .. " st."
        else distanceText.Text = "" end
    end
end)
freeze()
task.spawn(function()
    local world = workspace:WaitForChild("FridayWorld")
    local interactions = world:WaitForChild("Interactions")
    while not world:GetAttribute("Ready") do world:GetAttributeChangedSignal("Ready"):Wait() end
    for id, data in pairs(WorldData.targets) do
        local object = interactions:WaitForChild(id)
        if data.npc then
            object:WaitForChild("Head")
            while not object.PrimaryPart do object:GetPropertyChangedSignal("PrimaryPart"):Wait() end
        end
    end
    front:setReady(nil, true)
    if state then updateMarker() end
end)
-- Handshake ponawiany do pierwszego stanu: obsługuje wolne ładowanie DataStore.
task.spawn(function()
    while not state do send("Sync"); task.wait(1) end
end)
