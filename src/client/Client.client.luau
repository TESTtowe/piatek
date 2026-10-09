local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Friday")
local Config = require(Shared:WaitForChild("Config"))
local Campaign = require(Shared:WaitForChild("Campaign"))
local FactBook = require(Shared:WaitForChild("FactBook"))
local WorldData = require(Shared:WaitForChild("WorldData"))
local UI = require(script.Parent:WaitForChild("UI"))
local C = UI.colors
local network = Shared:WaitForChild("Network")
local command = network:WaitForChild("Command")
local event = network:WaitForChild("Event")
local camera = workspace.CurrentCamera
local state, activeToken, mode, puzzleAnswer, puzzleDefinition
local pendingChapter, pendingEnd, puzzleFeedback, submitButton
local menuOpen, panelOpen, hasStarted = true, false, false
local directions, resetDeadline = true, 0
local marker, highlight
local showChapter, showEnding, renderState, closePanel
local gui = UI.make("ScreenGui", { Name = "FridayInterface", ResetOnSpawn = false, DisplayOrder = 10, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, player:WaitForChild("PlayerGui"))
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end)

local function send(action, payload) command:FireServer(action, payload) end
local function freeze()
    local blocked = menuOpen or panelOpen
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
local top = UI.frame(hud, { Size = UDim2.new(1, 0, 0, 72), BackgroundTransparency = 0.1, BackgroundColor3 = C.ink })
UI.text(top, "KP / OPOWIEŚĆ", { Position = UDim2.fromOffset(22, 13), Size = UDim2.fromOffset(155, 22), TextSize = 13, Font = Enum.Font.GothamBold, TextColor3 = C.amber })
local chapterLabel = UI.text(top, "", { Position = UDim2.fromOffset(22, 37), Size = UDim2.new(0.6, -22, 0, 22), TextSize = 14 })
local journalButton = UI.button(top, "Zeszyt  [J]", function()
    if panelOpen or menuOpen then return end
    mode = "journal"
    panelOpen = true
    renderState()
end, { Position = UDim2.new(1, -154, 0, 17), Size = UDim2.fromOffset(132, 38) })
local questPanel = UI.frame(hud, { Position = UDim2.fromOffset(22, 94), Size = UDim2.fromOffset(328, 123), BackgroundTransparency = 0.07 })
UI.corner(questPanel)
UI.stroke(questPanel)
UI.text(questPanel, "AKTUALNE ZADANIE", { Position = UDim2.fromOffset(16, 14), Size = UDim2.new(1, -32, 0, 20), TextSize = 11, TextColor3 = C.amber, Font = Enum.Font.GothamBold })
local questText = UI.text(questPanel, "", { Position = UDim2.fromOffset(16, 40), Size = UDim2.new(1, -32, 0, 50), TextSize = 17, Font = Enum.Font.GothamMedium })
local progressTrack = UI.frame(questPanel, { Position = UDim2.new(0, 16, 1, -14), Size = UDim2.new(1, -32, 0, 3), BackgroundColor3 = C.line })
local progressFill = UI.frame(progressTrack, { Size = UDim2.new(), BackgroundColor3 = C.amber })
local hint = UI.text(hud, "E · interakcja    J · zeszyt    M · menu", { Position = UDim2.new(0, 22, 1, -36), Size = UDim2.new(1, -220, 0, 24), TextSize = 12, TextColor3 = C.paper, TextStrokeTransparency = 0.4 })
local distanceText = UI.text(questPanel, "", { Position = UDim2.new(1, -66, 0, 13), Size = UDim2.fromOffset(50, 18), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.muted })

local map = UI.frame(hud, { Position = UDim2.new(1, -190, 1, -210), Size = UDim2.fromOffset(168, 166), BackgroundTransparency = 0.1 })
UI.corner(map)
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
UI.corner(toast)
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

local menu = UI.frame(gui, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink, BackgroundTransparency = 0.28 })
UI.make("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.ink), ColorSequenceKeypoint.new(1, Color3.fromRGB(48, 66, 67)) }), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.75) }) }, menu)
local menuContent = UI.scroll(menu, { Position = UDim2.fromOffset(44, 36), Size = UDim2.new(0.47, 0, 1, -72), ScrollBarThickness = 0 })
UI.list(menuContent, 15)
UI.text(menuContent, "STUDIO OPOWIEŚCI  /  01", { TextSize = 11, TextColor3 = C.amber, Font = Enum.Font.GothamBold, LayoutOrder = 1 })
UI.autoText(menuContent, "KRWAWY\nPIĄTEK", { Font = Enum.Font.GothamBold, TextSize = 59, LayoutOrder = 2, LineHeight = 0.92 })
UI.autoText(menuContent, "Zanim zadzwoni dzwonek", { TextSize = 23, TextColor3 = C.amber, LayoutOrder = 3 })
UI.autoText(menuContent, "Jeden dzień. Kilka niedokończonych rozmów.\nZeszyt, w którym zostaje miejsce na jutro.", { TextSize = 17, TextColor3 = C.muted, LayoutOrder = 4 })
UI.autoText(menuContent, "FABUŁA NA TLE UDOKUMENTOWANYCH DONIESIEŃ\nPostacie i szkoła są fikcyjne. Archiwum zawiera komunikaty instytucji i relacje prasowe z października 2026.", { TextSize = 13, TextColor3 = C.paper, LayoutOrder = 5 })
local startButton = UI.button(menuContent, "Przygotowywanie gry…", function()
    if not state then return end
    if state.completed then showEnding(); return end
    if hasStarted then
        menuOpen = false
        menu.Visible = false
        hud.Visible = true
        camera.CameraType = Enum.CameraType.Custom
        freeze()
        renderState()
    else
        send("Start")
    end
end, { Size = UDim2.new(1, -8, 0, 52), BackgroundColor3 = C.teal, TextColor3 = C.ink, LayoutOrder = 6, TextSize = 17 })
UI.button(menuContent, "Jak gramy / źródła", function()
    mode = "about"; panelOpen = true; renderState()
end, { LayoutOrder = 7, Size = UDim2.new(1, -8, 0, 44) })
UI.button(menuContent, "Archiwum faktów / " .. #FactBook.entries .. " wpisów", function()
    mode = "facts"; panelOpen = true; renderState()
end, { LayoutOrder = 8, Size = UDim2.new(1, -8, 0, 44) })
UI.button(menuContent, "Ustawienia", function()
    mode = "settings"; panelOpen = true; renderState()
end, { LayoutOrder = 9, Size = UDim2.new(1, -8, 0, 44) })
local resetButton
resetButton = UI.button(menuContent, "Rozpocznij od nowa", function()
    if not state then return end
    if os.clock() > resetDeadline then
        resetDeadline = os.clock() + 5
        resetButton.Text = "Kliknij ponownie: usuń mój postęp"
        task.delay(5, function() if os.clock() >= resetDeadline then resetButton.Text = "Rozpocznij od nowa" end end)
        return
    end
    resetDeadline = 0
    hasStarted = false
    send("Reset")
    resetButton.Text = "Rozpocznij od nowa"
end, { LayoutOrder = 10, TextSize = 13, TextColor3 = C.muted, Size = UDim2.new(1, -8, 0, 40) })
UI.autoText(menuContent, "6 ROZDZIAŁÓW   ·   3 RODZAJE MINIGIER\nPC / TELEFON / KONTROLER", { TextSize = 10, TextColor3 = C.muted, LayoutOrder = 11 })
local menuCredit = UI.text(menu, "PIĄTEK / WERSJA ROBOCZA " .. Config.Version, { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -24, 1, -20), Size = UDim2.fromOffset(320, 20), TextXAlignment = Enum.TextXAlignment.Right, TextSize = 10, TextColor3 = C.muted })

local overlay = UI.frame(gui, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Visible = false, ZIndex = 40, Active = true })
local panel = UI.frame(overlay, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(680, 590), BackgroundColor3 = C.ink, ZIndex = 41 })
UI.corner(panel, 16)
UI.stroke(panel)
local panelEyebrow = UI.text(panel, "", { Position = UDim2.fromOffset(24, 20), Size = UDim2.new(1, -100, 0, 19), TextColor3 = C.amber, TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 42 })
local panelTitle = UI.text(panel, "", { Position = UDim2.fromOffset(24, 48), Size = UDim2.new(1, -100, 0, 56), TextSize = 25, Font = Enum.Font.GothamMedium, ZIndex = 42 })
local panelClose = UI.button(panel, "×", function() closePanel() end, { Position = UDim2.new(1, -62, 0, 20), Size = UDim2.fromOffset(38, 38), TextSize = 24, ZIndex = 42 })
local content = UI.scroll(panel, { Position = UDim2.fromOffset(24, 115), Size = UDim2.new(1, -48, 1, -139), ZIndex = 42 })
local function clearContent()
    for _, child in ipairs(content:GetChildren()) do if not child:IsA("UIPadding") then child:Destroy() end end
    UI.list(content, 12)
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
    panelEyebrow.Text = eyebrow
    panelTitle.Text = title
    overlay.Visible = true
    freeze()
end

local chapterCard = UI.frame(gui, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink, BackgroundTransparency = 0.1, Visible = false, ZIndex = 35 })
UI.text(chapterCard, "PIĄTEK", { Position = UDim2.fromScale(0.1, 0.28), Size = UDim2.fromScale(0.8, 0.06), TextColor3 = C.amber, TextSize = 14, ZIndex = 36 })
local chapterTitle = UI.text(chapterCard, "", { Position = UDim2.fromScale(0.1, 0.38), Size = UDim2.fromScale(0.8, 0.25), TextSize = 34, Font = Enum.Font.GothamMedium, ZIndex = 36 })
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
    local page = 1
    local waiting = false
    local function render()
        panelHeading("ROZMOWA / " .. objective.speaker, objective.speaker)
        paragraph(string.format("%02d / %02d", page, #objective.lines), { TextSize = 12, TextColor3 = C.muted })
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
    puzzleDefinition = Campaign.puzzles[data.id]
    local definition = puzzleDefinition
    if not definition then return end
    panelOpen, mode, activeToken = true, "puzzle", data.token
    puzzleAnswer = {}
    panelHeading("ZADANIE / ZESZYT", definition.title)
    paragraph(definition.description, { TextSize = 16, TextColor3 = C.muted })
    local selectedLabels = {}
    local answerLabel
    local controls = {}
    local function mark(button, selected)
        button.BackgroundColor3 = selected and C.teal or C.panel
        button.TextColor3 = selected and C.ink or C.paper
    end
    if definition.kind == "order" then
        answerLabel = paragraph("Wybrana kolejność: —", { TextSize = 15, TextColor3 = C.amber })
        for _, card in ipairs(definition.cards) do
            local button
            button = action(card.text, function()
                if table.find(puzzleAnswer, card.id) then return end
                table.insert(puzzleAnswer, card.id)
                table.insert(selectedLabels, card.text)
                answerLabel.Text = table.concat(selectedLabels, "\n↓\n")
                mark(button, true)
            end)
            table.insert(controls, button)
        end
        action("Wyczyść kolejność", function()
            puzzleAnswer, selectedLabels = {}, {}
            answerLabel.Text = "Wybrana kolejność: —"
            for _, button in ipairs(controls) do mark(button, false) end
        end, { TextSize = 13, Size = UDim2.new(1, -3, 0, 42) })
    elseif definition.kind == "classify" then
        for _, card in ipairs(definition.cards) do
            paragraph(card.text, { TextSize = 17 })
            local buttons = {}
            for _, category in ipairs(definition.categories) do
                local button
                button = action(category.label, function()
                    puzzleAnswer[card.id] = category.id
                    for _, existing in ipairs(buttons) do mark(existing, existing == button) end
                end, { Size = UDim2.new(1, -3, 0, 40), TextSize = 14 })
                table.insert(buttons, button)
            end
        end
    elseif definition.kind == "memory" then
        local memory = data.memory or {}
        local preview = paragraph("Zapamiętaj: " .. table.concat(memory, ", "), { TextSize = 23, TextColor3 = C.amber })
        local nextPage
        local revealed = false
        nextPage = action("Oglądam listę…", function()
            if revealed or nextPage:GetAttribute("Ready") ~= true then return end
            revealed = true
            preview:Destroy()
            nextPage:Destroy()
            for _, card in ipairs(definition.cards) do
                local button
                button = action(card.text, function()
                    local index = table.find(puzzleAnswer, card.id)
                    if index then table.remove(puzzleAnswer, index)
                    elseif #puzzleAnswer < definition.count then table.insert(puzzleAnswer, card.id) end
                    mark(button, table.find(puzzleAnswer, card.id) ~= nil)
                end, { LayoutOrder = 1 })
            end
        end)
        task.delay(7, function()
            if nextPage.Parent and activeToken == data.token then
                nextPage:SetAttribute("Ready", true)
                nextPage.Text = "Jestem gotowy / następna strona"
            end
        end)
    end
    puzzleFeedback = paragraph("Możesz próbować ponownie. Zadanie nie ma limitu błędów.", { TextSize = 13, TextColor3 = C.muted, LayoutOrder = 2 })
    local sending = false
    submitButton = action("Sprawdź zapis", function()
        if sending then return end
        sending = true
        send("Solve", { token = activeToken, answer = puzzleAnswer })
        task.delay(1, function() sending = false end)
    end, { BackgroundColor3 = C.teal, TextColor3 = C.ink, LayoutOrder = 3 })
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
    freeze()
    if state then
        local chapter = Campaign.chapters[state.chapter]
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
        panelHeading("REPLIKA / ROZMOWA", "Po twojej odpowiedzi")
        paragraph(data.text, { TextSize = 21 })
        action("Wróć do opowieści →", closePanel, { BackgroundColor3 = C.teal, TextColor3 = C.ink })
    elseif kind == "Puzzle" then
        puzzle(data); updateMarker()
    elseif kind == "PuzzleResult" then
        if mode ~= "puzzle" then return end
        if puzzleFeedback then puzzleFeedback.Text = data.message; puzzleFeedback.TextColor3 = data.ok and C.teal or C.error end
        if data.ok then
            activeToken = nil
            mode = "puzzle_done"
            if submitButton then submitButton.Visible = false end
            action("Gotowe / wróć do opowieści →", closePanel, { BackgroundColor3 = C.teal, TextColor3 = C.ink, LayoutOrder = 4 })
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
    local size = camera.ViewportSize
    local compact = size.X < 680
    menuContent.Position = UDim2.fromOffset(compact and 22 or 44, compact and 18 or 36)
    menuContent.Size = compact and UDim2.new(1, -44, 1, -36) or UDim2.new(0.47, 0, 1, -72)
    menuCredit.Visible = not compact
    panel.Size = UDim2.fromOffset(math.min(680, math.max(280, size.X - 28)), math.min(650, math.max(240, size.Y - 42)))
    panelTitle.TextSize = compact and 21 or 25
    questPanel.Size = UDim2.fromOffset(compact and math.min(290, size.X - 130) or 328, compact and 140 or 123)
    questText.Size = UDim2.new(1, -32, 0, compact and 70 or 50)
    questText.TextSize = compact and 14 or 17
    map.Visible = size.X >= 780 and size.Y >= 550
    hint.Visible = not UserInputService.TouchEnabled and size.Y > 480
    if compact then chapterLabel.Size = UDim2.new(1, -180, 0, 28); chapterLabel.TextSize = 11 end
    toast.Size = UDim2.fromOffset(math.min(560, size.X - 32), 86)
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
resize()
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    if activeToken then send("Cancel", { token = activeToken }); activeToken = nil end
    if panelOpen then closePanel() end
    freeze()
    if not menuOpen then camera.CameraType = Enum.CameraType.Custom end
end)

local elapsed, tickAccumulator = 0, 0
RunService.RenderStepped:Connect(function(dt)
    elapsed += dt
    if menuOpen then
        camera.CameraType = Enum.CameraType.Scriptable
        local sway = UI.reducedMotion and 0 or math.sin(elapsed * 0.08) * 7
        camera.CFrame = CFrame.lookAt(Vector3.new(64 + sway, 30, 92), Vector3.new(0, 6, 10))
    end
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
    workspace:WaitForChild("FridayWorld"):WaitForChild("Interactions")
    if state then updateMarker() end
end)
-- Handshake ponawiany do pierwszego stanu: obsługuje wolne ładowanie DataStore.
task.spawn(function()
    while not state do send("Sync"); task.wait(1) end
end)
