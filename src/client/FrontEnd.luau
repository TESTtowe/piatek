-- Pierwsze wejście, ostrzeżenie i menu. Nie zależy od postępu fabuły.
local FrontEnd = {}

function FrontEnd.new(gui, UI, Config, Presentation, callbacks)
    local C = UI.colors
    local self = { accepted = false, gate = { acknowledged = false, ready = false, worldReady = false } }
    local menu = UI.frame(gui, { Name = "MainMenu", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 10 })
    self.menu = menu
    local veil = UI.frame(menu, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink, ZIndex = 10 })
    UI.make("UIGradient", { Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.36, 0.06),
        NumberSequenceKeypoint.new(0.66, 0.53), NumberSequenceKeypoint.new(1, 0.72),
    }) }, veil)
    local letterboxTop = UI.frame(menu, { Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = C.ink, ZIndex = 11 })
    local letterboxBottom = UI.frame(menu, { Position = UDim2.new(0, 0, 1, -22), Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = C.ink, ZIndex = 11 })
    local menuContent = UI.scroll(menu, { Name = "MenuContent", Position = UDim2.fromOffset(80, 75), Size = UDim2.fromOffset(500, 600), ScrollBarThickness = 0, ZIndex = 12 })
    UI.list(menuContent, 0)
    local function text(value, height, props)
        local options = { Size = UDim2.new(1, -8, 0, height), ZIndex = 13 }
        for key, val in pairs(props or {}) do options[key] = val end
        return UI.text(menuContent, value, options)
    end
    text(string.upper(Config.ProjectCredit) .. "  PRZEDSTAWIA", 30, { TextSize = 11, TextColor3 = C.muted, Font = Enum.Font.GothamMedium, LayoutOrder = 1 })
    local heading = UI.frame(menuContent, { Size = UDim2.new(1, 0, 0, 206), BackgroundTransparency = 1, LayoutOrder = 2, ZIndex = 13 })
    local firstTitle = UI.text(heading, "KRWAWY", { Size = UDim2.fromScale(1, 0.5), Font = Enum.Font.Oswald, TextSize = 94, ZIndex = 13 })
    local secondTitle = UI.text(heading, "PIĄTEK", { Position = UDim2.fromScale(0, 0.47), Size = UDim2.fromScale(1, 0.53), Font = Enum.Font.Oswald, TextSize = 94, TextColor3 = C.amber, ZIndex = 13 })
    text("ZANIM ZADZWONI DZWONEK", 28, { TextSize = 12, Font = Enum.Font.GothamMedium, LayoutOrder = 3 })
    text("Nie każdy piątek kończy się wraz z ostatnią lekcją.", 44, { TextSize = 16, TextColor3 = C.muted, LayoutOrder = 4 })
    local line = UI.frame(menuContent, { Size = UDim2.new(1, -8, 0, 1), BackgroundColor3 = C.line, LayoutOrder = 5, ZIndex = 13 })
    UI.frame(menuContent, { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = 6, ZIndex = 13 })
    local start = UI.button(menuContent, "Ładowanie opowieści…", function()
        if self.accepted and self.gate.ready then callbacks.start() end
    end, { Name = "StartStory", Size = UDim2.new(1, -8, 0, 55), BackgroundColor3 = C.paper, TextColor3 = C.ink,
        TextXAlignment = Enum.TextXAlignment.Left, TextSize = 16, LayoutOrder = 7, ZIndex = 13 })
    UI.frame(menuContent, { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, LayoutOrder = 8, ZIndex = 13 })
    local links = { { "Rozdziały", "chapters" }, { "Archiwum wydarzeń", "facts" }, { "Ustawienia", "settings" }, { "Autorzy", "credits" } }
    local nav = UI.frame(menuContent, { Name = "MenuNavigation", Size = UDim2.new(1, -8, 0, 74), BackgroundTransparency = 1, LayoutOrder = 9, ZIndex = 13 })
    for index, entry in ipairs(links) do
        local column, row = (index - 1) % 2, math.floor((index - 1) / 2)
        UI.link(nav, entry[1], function() callbacks.open(entry[2]) end,
            { Name = entry[2], Position = UDim2.new(column * 0.5, 0, 0, row * 37), Size = UDim2.new(0.5, -8, 0, 35), TextSize = 14, ZIndex = 13 })
    end
    local reset = UI.link(menuContent, "Rozpocznij od nowa", callbacks.reset,
        { Name = "ResetStory", LayoutOrder = 13, Visible = false, TextSize = 12, TextColor3 = C.muted, Size = UDim2.new(1, -8, 0, 35), ZIndex = 13 })
    self.start, self.reset = start, reset
    local menuBottom = UI.text(menu, "HISTORIA FABULARNA  /  KONTEKST DOKUMENTALNY", {
        Position = UDim2.new(0, 80, 1, -52), Size = UDim2.new(1, -160, 0, 18), TextSize = 10, TextColor3 = C.muted, Font = Enum.Font.Code, ZIndex = 13 })
    local version = UI.text(menu, "V" .. Config.Version, { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -40, 1, -36),
        Size = UDim2.fromOffset(90, 16), TextXAlignment = Enum.TextXAlignment.Right, TextSize = 10, Font = Enum.Font.Code, TextColor3 = C.muted, ZIndex = 13 })
    local location = UI.text(menu, "POLSKA\nPAŹDZIERNIK 2026", { Position = UDim2.new(1, -245, 0, 54), Size = UDim2.fromOffset(205, 55),
        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.paper, Font = Enum.Font.Code, ZIndex = 13 })
    local rightCaption = UI.text(menu, "01 / ZWYCZAJNY PIĄTEK", { Position = UDim2.new(0.65, 0, 1, -110), Size = UDim2.new(0.3, 0, 0, 30),
        TextSize = 11, Font = Enum.Font.Code, TextColor3 = C.paper, ZIndex = 13 })
    self.caption = rightCaption
    local captionRule = UI.rule(menu, UDim2.new(0.65, 0, 1, -76), UDim2.new(0.29, 0, 0, 1), C.muted, 13)

    local warning = UI.frame(gui, { Name = "EntryWarning", Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink, ZIndex = 100, Active = true })
    self.warning = warning
    UI.rule(warning, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 3), C.amber, 101)
    local warningContent = UI.scroll(warning, { Position = UDim2.fromOffset(80, 60), Size = UDim2.fromOffset(700, 650), ScrollBarThickness = 2, ZIndex = 101 })
    UI.list(warningContent, 0)
    local function warningText(value, props)
        local options = { ZIndex = 102, LayoutOrder = 1 }
        for key, val in pairs(props or {}) do options[key] = val end
        return UI.autoText(warningContent, value, options)
    end
    warningText("INFORMACJA DLA GRACZA", { TextSize = 11, Font = Enum.Font.Code, TextColor3 = C.amber, LayoutOrder = 1 })
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, LayoutOrder = 2, ZIndex = 102 })
    local warningTitle = warningText("ZANIM\nZACZNIEMY.", { Font = Enum.Font.Oswald, TextSize = 62, LineHeight = 1, LayoutOrder = 3 })
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 4, ZIndex = 102 })
    warningText("Ta historia porusza temat przemocy w szkołach, gróźb i ich wpływu na ludzi. Może wywołać niepokój.", {
        TextSize = 18, LineHeight = 1.18, LayoutOrder = 5 })
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 19), BackgroundTransparency = 1, LayoutOrder = 6, ZIndex = 102 })
    warningText("NIE NAŚLADUJ NIEBEZPIECZNYCH ZACHOWAŃ.", { TextSize = 13, Font = Enum.Font.GothamBold, TextColor3 = C.amber, LayoutOrder = 7 })
    warningText("Gra nie jest instrukcją działania. Nie pokazuje przebiegu ataku. Możesz przerwać rozgrywkę w każdej chwili.", {
        TextSize = 15, TextColor3 = C.muted, LineHeight = 1.18, LayoutOrder = 8 })
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 17), BackgroundTransparency = 1, LayoutOrder = 9, ZIndex = 102 })
    warningText("Postacie, szkoła i dialogi są fikcyjne. Udokumentowane wydarzenia znajdziesz w osobnym archiwum, razem ze źródłami.", {
        TextSize = 13, TextColor3 = C.muted, LayoutOrder = 10 })
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 11, ZIndex = 102 })
    local acknowledge
    local enter
    local function refreshGate()
        local allowed = Presentation.canEnter(self.gate)
        enter:SetAttribute("Disabled", not allowed)
        enter.BackgroundColor3 = allowed and C.paper or C.panel
        enter.TextColor3 = allowed and C.ink or C.muted
        enter.Text = self.gate.ready and self.gate.worldReady and "Przejdź do menu  →" or "Przygotowywanie świata…"
    end
    acknowledge = UI.button(warningContent, "□  Rozumiem i chcę kontynuować", function()
        self.gate.acknowledged = not self.gate.acknowledged
        acknowledge.Text = (self.gate.acknowledged and "✓" or "□") .. "  Rozumiem i chcę kontynuować"
        acknowledge.TextColor3 = self.gate.acknowledged and C.paper or C.muted
        refreshGate()
    end, { Name = "Acknowledge", BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 14, Size = UDim2.new(1, -8, 0, 48), LayoutOrder = 12, ZIndex = 102 })
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 10), BackgroundTransparency = 1, LayoutOrder = 13, ZIndex = 102 })
    enter = UI.button(warningContent, "Przygotowywanie świata…", function()
        if self.accepted or not Presentation.canEnter(self.gate) then return end
        self.accepted = true
        warning.Visible = false
        menu.Visible = true
        callbacks.accepted()
    end, { Name = "EnterMenu", BackgroundColor3 = C.panel, TextColor3 = C.muted, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -8, 0, 52), LayoutOrder = 14, ZIndex = 102 })
    enter:SetAttribute("Disabled", true)
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = 15, ZIndex = 102 })
    warningText("POMOC: 112 — BEZPOŚREDNIE ZAGROŻENIE  /  116 111 — TELEFON ZAUFANIA", {
        TextSize = 10, TextColor3 = C.muted, Font = Enum.Font.Code, LayoutOrder = 16 })

    function self:setReady(ready, worldReady)
        if ready ~= nil then self.gate.ready = ready end
        if worldReady ~= nil then self.gate.worldReady = worldReady end
        start:SetAttribute("Disabled", not self.gate.ready)
        refreshGate()
    end
    function self:resize(width, height, topInset)
        local L = Presentation.layout(width, height)
        local safeTop = (topInset or 58) + 10
        local top = math.max(safeTop, L.compact and 48 or math.floor(height * 0.09))
        menuContent.Position = UDim2.fromOffset(L.margin, top)
        menuContent.Size = UDim2.fromOffset(L.menuWidth, height - top - (L.compact and 34 or 80))
        firstTitle.TextSize, secondTitle.TextSize = L.titleSize, L.titleSize
        heading.Size = UDim2.new(1, 0, 0, L.titleSize * 2.13)
        menuBottom.Position = UDim2.new(0, L.margin, 1, -51)
        menuBottom.Visible, version.Visible, location.Visible, rightCaption.Visible = not L.compact, not L.compact, not L.compact, not L.compact
        captionRule.Visible = not L.compact
        letterboxTop.Visible, letterboxBottom.Visible = not L.compact, not L.compact
        local warningTop = math.max(safeTop, L.compact and 48 or math.floor((height - 660) / 2))
        warningContent.Position = UDim2.fromOffset(math.floor((width - L.warningWidth) / 2), warningTop)
        warningContent.Size = UDim2.fromOffset(L.warningWidth, math.max(100, height - warningTop - 28))
        warningTitle.TextSize = L.compact and 48 or 62
    end
    return self
end

return FrontEnd
