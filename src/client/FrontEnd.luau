-- Osobny ekran wejścia i menu, skalowane do 1440p; bez zależności od silnika fabuły.
local FrontEnd = {}

function FrontEnd.new(gui, UI, Config, Presentation, callbacks)
    local C = UI.colors
    local self = { accepted = false, gate = { acknowledged = false, ready = false, worldReady = false, artReady = false } }
    self.backdrop = UI.frame(gui, { Name = "ArtBackdrop", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 8 })
    local menu = UI.frame(gui, { Name = "MainMenu", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 10 })
    self.menu = menu
    local veil = UI.frame(menu, { Name = "MenuVeil", Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink, ZIndex = 10 })
    local veilGradient = UI.make("UIGradient", { Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.35, 0.36),
        NumberSequenceKeypoint.new(0.65, 0.8), NumberSequenceKeypoint.new(1, 0.94),
    }) }, veil)
    local bottomVeil = UI.frame(menu, { Position = UDim2.fromScale(0, 0.64), Size = UDim2.fromScale(1, 0.36), BackgroundColor3 = C.ink, ZIndex = 10 })
    UI.make("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0.16) }, bottomVeil)
    local topVeil = UI.frame(menu, { Name = "HeaderVeil", Size = UDim2.new(1, 0, 0, 170), BackgroundColor3 = C.ink, ZIndex = 11 })
    UI.make("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.7, 0.35), NumberSequenceKeypoint.new(1, 1) }) }, topVeil)
    local masthead = UI.frame(menu, { Name = "Masthead", BackgroundTransparency = 1, Size = UDim2.new(1, -120, 0, 45), ZIndex = 12 })
    local mastheadScale = UI.make("UIScale", { Scale = 1 }, masthead)
    UI.rule(masthead, UDim2.fromOffset(0, 5), UDim2.fromOffset(3, 23), C.amber, 13)
    UI.text(masthead, string.upper(Config.ProjectCredit), { Position = UDim2.fromOffset(17, 7), Size = UDim2.fromOffset(190, 22), Font = Enum.Font.GothamMedium, TextSize = 14, ZIndex = 13 })
    local setting = UI.link(masthead, "Ustawienia", function() callbacks.open("settings") end, { Name = "settings", AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(120, 36), TextColor3 = C.paper, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 13 })
    local location = UI.text(masthead, "POLSKA  ·  PAŹDZIERNIK 2026", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -160, 0, 10),
        Size = UDim2.fromOffset(280, 20), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.paper, ZIndex = 13 })
    local menuContent = UI.scroll(menu, { Name = "MenuContent", ScrollBarThickness = 0, ZIndex = 12 })
    local menuScale = UI.make("UIScale", { Scale = 1 }, menuContent)
    UI.list(menuContent, 0)
    local function text(value, height, props)
        local options = { Size = UDim2.new(1, -8, 0, height), ZIndex = 13 }
        for key, val in pairs(props or {}) do options[key] = val end
        return UI.text(menuContent, value, options)
    end
    text("INTERAKTYWNA OPOWIEŚĆ", 30, { TextSize = 11, TextColor3 = C.amber, Font = Enum.Font.GothamMedium, LayoutOrder = 1 })
    local title = text("KRWAWY\nPIĄTEK", 225, { Name = "GameTitle", Font = Enum.Font.Bodoni, TextSize = 98, LineHeight = 0.98, LayoutOrder = 2 })
    text("Zanim zadzwoni dzwonek", 39, { TextSize = 21, Font = Enum.Font.GothamMedium, LayoutOrder = 3 })
    text("Poznaj swoją klasę. Podejmuj decyzje.\nPrzejdź sześć rozdziałów szkolnej historii.", 66, { TextSize = 16, TextColor3 = C.muted, LineHeight = 1.3, LayoutOrder = 4 })
    local start = UI.button(menuContent, "Przygotowywanie opowieści…", function()
        if self.accepted and Presentation.canEnter(self.gate) then callbacks.start() end
    end, { Name = "StartStory", Size = UDim2.new(1, -8, 0, 64), BackgroundColor3 = C.teal, TextColor3 = C.ink,
        TextXAlignment = Enum.TextXAlignment.Left, TextSize = 19, LayoutOrder = 5, ZIndex = 13 })
    UI.frame(menuContent, { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = 6, ZIndex = 13 })
    local nav = UI.frame(menuContent, { Name = "MenuNavigation", Size = UDim2.new(1, -8, 0, 104), BackgroundTransparency = 1, LayoutOrder = 7, ZIndex = 13 })
    for index, entry in ipairs({ { "Rozdziały", "chapters", "book" }, { "Archiwum wydarzeń", "facts", "archive" }, { "Autorzy", "credits", "people" } }) do
        local column = index == 2 and 1 or 0
        local row = index == 3 and 1 or 0
        local button = UI.button(nav, entry[1], function() callbacks.open(entry[2]) end, { Name = entry[2],
            Position = UDim2.new(column * 0.5, column == 1 and 4 or 0, 0, row * 56), Size = UDim2.new(0.5, -4, 0, 48),
            BackgroundColor3 = C.ink, BackgroundTransparency = 0.34, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13 })
        local padding = button:FindFirstChildOfClass("UIPadding")
        padding.PaddingLeft = UDim.new(0, 46)
        UI.icon(nav, entry[3], UDim2.new(column * 0.5, (column == 1 and 4 or 0) + 16, 0, row * 56 + 13), C.muted, 14)
    end
    local reset = UI.link(nav, "Rozpocznij od nowa", callbacks.reset, { Name = "ResetStory", Visible = false,
        Position = UDim2.new(0.5, 4, 0, 56), Size = UDim2.new(0.5, -4, 0, 48), TextSize = 12, ZIndex = 13 })
    self.start, self.reset = start, reset
    local footer = UI.frame(menu, { Name = "MenuFooter", Size = UDim2.new(1, -120, 0, 30), BackgroundTransparency = 1, ZIndex = 12 })
    local footerScale = UI.make("UIScale", { Scale = 1 }, footer)
    UI.text(footer, "Fabuła autorska · Udokumentowany kontekst", { Size = UDim2.new(1, -110, 1, 0), TextSize = 11, TextColor3 = C.muted, ZIndex = 13 })
    UI.text(footer, "v" .. Config.Version, { Position = UDim2.new(1, -90, 0, 0), Size = UDim2.fromOffset(90, 25), TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.muted, ZIndex = 13 })
    local chapter = UI.frame(menu, { Name = "ChapterPreview", BackgroundColor3 = C.ink, BackgroundTransparency = 0.23, ZIndex = 12 })
    UI.corner(chapter, 10)
    UI.stroke(chapter)
    local chapterScale = UI.make("UIScale", { Scale = 1 }, chapter)
    UI.text(chapter, "TWOJA OPOWIEŚĆ", { Position = UDim2.fromOffset(24, 19), Size = UDim2.new(1, -48, 0, 18), TextSize = 10, TextColor3 = C.amber, ZIndex = 13 })
    self.caption = UI.text(chapter, "01 / Zwyczajny piątek", { Position = UDim2.fromOffset(24, 48), Size = UDim2.new(1, -48, 0, 52),
        Font = Enum.Font.GothamMedium, TextSize = 19, ZIndex = 13 })
    local track = UI.frame(chapter, { Position = UDim2.new(0, 24, 1, -27), Size = UDim2.new(1, -48, 0, 2), BackgroundColor3 = C.line, ZIndex = 13 })
    self.progress = UI.frame(track, { Size = UDim2.new(), BackgroundColor3 = C.amber, ZIndex = 14 })

    local warning = UI.frame(gui, { Name = "EntryWarning", Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink,
        BackgroundTransparency = 0.28, ZIndex = 100, Active = true })
    self.warning = warning
    local fade = UI.frame(gui, { Name = "EntryTransition", Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink,
        BackgroundTransparency = 1, Visible = false, ZIndex = 180, Active = true })
    local shadow = UI.frame(warning, { Name = "WarningShadow", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.58, ZIndex = 101 })
    UI.corner(shadow, 18)
    local card = UI.frame(warning, { Name = "WarningCard", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = C.panel,
        BackgroundTransparency = 0.04, ZIndex = 102 })
    UI.corner(card, 14)
    local border = UI.stroke(card, C.line)
    border.Transparency = 0.3
    local warningScale = UI.make("UIScale", { Scale = 1 }, card)
    local shadowScale = UI.make("UIScale", { Scale = 1 }, shadow)
    local warningContent = UI.scroll(card, { Name = "WarningContent", Position = UDim2.fromOffset(38, 34), Size = UDim2.new(1, -76, 1, -208), ScrollBarThickness = 2, ZIndex = 103 })
    UI.list(warningContent, 0)
    local iconRow = UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 63), BackgroundTransparency = 1, LayoutOrder = 1, ZIndex = 104 })
    local iconBox = UI.frame(iconRow, { Size = UDim2.fromOffset(43, 43), BackgroundColor3 = C.selected, ZIndex = 104 })
    UI.corner(iconBox, 10)
    UI.icon(iconBox, "warning", UDim2.fromOffset(11, 10), C.amber, 105)
    UI.text(iconRow, "INFORMACJA O TREŚCI", { Position = UDim2.fromOffset(58, 15), Size = UDim2.new(1, -58, 0, 22), TextSize = 11, TextColor3 = C.amber, Font = Enum.Font.GothamMedium, ZIndex = 104 })
    local function warningText(value, props)
        local options = { ZIndex = 104 }
        for key, val in pairs(props or {}) do options[key] = val end
        return UI.autoText(warningContent, value, options)
    end
    local warningTitle = warningText("Zanim wejdziesz", { Font = Enum.Font.GothamMedium, TextSize = 37, LayoutOrder = 2 })
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 3, ZIndex = 104 })
    warningText("Ta opowieść porusza temat przemocy w szkołach, gróźb i ich wpływu na ludzi. Może wywołać niepokój.", {
        TextSize = 18, LineHeight = 1.28, LayoutOrder = 4 })
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = 5, ZIndex = 104 })
    warningText("Nie naśladuj niebezpiecznych zachowań.", { TextSize = 17, Font = Enum.Font.GothamMedium, TextColor3 = C.amber, LayoutOrder = 6 })
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 10), BackgroundTransparency = 1, LayoutOrder = 7, ZIndex = 104 })
    warningText("Gra nie jest instrukcją działania. Nie pokazuje przebiegu ataku. Jeśli potrzebujesz przerwy, możesz zakończyć rozgrywkę w każdej chwili.", {
        TextSize = 15, TextColor3 = C.muted, LineHeight = 1.3, LayoutOrder = 8 })
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 9, ZIndex = 104 })
    warningText("Postacie, szkoła i dialogi są fikcyjne. Udokumentowane wydarzenia znajdziesz w archiwum wraz ze źródłami.", {
        TextSize = 14, TextColor3 = C.muted, LineHeight = 1.3, LayoutOrder = 10 })
    UI.frame(warningContent, { Size = UDim2.new(1, 0, 0, 27), BackgroundTransparency = 1, LayoutOrder = 11, ZIndex = 104 })
    local actions = UI.frame(card, { Name = "WarningActions", Position = UDim2.new(0, 38, 1, -148), Size = UDim2.new(1, -76, 0, 120), BackgroundTransparency = 1, ZIndex = 103 })
    local separator = UI.rule(card, UDim2.new(0, 38, 1, -165), UDim2.new(1, -76, 0, 1), C.line, 103)
    local acknowledge, enter
    local function refreshGate()
        local allowed = Presentation.canEnter(self.gate)
        enter:SetAttribute("Disabled", not allowed)
        enter.BackgroundColor3 = allowed and C.teal or C.selected
        enter.TextColor3 = allowed and C.ink or C.muted
        enter.Text = self.gate.ready and self.gate.worldReady and self.gate.artReady and "Rozumiem — przejdź do menu  →" or "Przygotowywanie świata…"
    end
    local acknowledgeRow = UI.frame(actions, { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, LayoutOrder = 12, ZIndex = 104 })
    acknowledge = UI.button(acknowledgeRow, "Potwierdzam, że przeczytałem informację", function()
        self.gate.acknowledged = not self.gate.acknowledged
        self.check.Visible = self.gate.acknowledged
        refreshGate()
    end, { Name = "Acknowledge", BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 14, Size = UDim2.new(1, -8, 0, 48), LayoutOrder = 12, ZIndex = 104 })
    acknowledge:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim.new(0, 46)
    local box = UI.frame(acknowledgeRow, { Position = UDim2.fromOffset(14, 15), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = C.ink, ZIndex = 105 })
    UI.corner(box, 4)
    UI.stroke(box, C.muted)
    self.check = UI.text(box, "✓", { Size = UDim2.fromScale(1, 1), TextSize = 15, Font = Enum.Font.GothamBold, TextColor3 = C.amber,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, Visible = false, ZIndex = 106 })
    enter = UI.button(actions, "Przygotowywanie świata…", function()
        if self.accepted or not Presentation.canEnter(self.gate) then return end
        self.accepted = true
        fade.Visible = true
        UI.tween(fade, { BackgroundTransparency = 0 }, 0.14)
        task.delay(UI.reducedMotion and 0 or 0.14, function()
            warning.Visible = false
            menu.Visible = true
            callbacks.accepted()
            UI.tween(fade, { BackgroundTransparency = 1 }, 0.36)
            task.delay(UI.reducedMotion and 0 or 0.36, function() fade.Visible = false end)
        end)
    end, { Name = "EnterMenu", Position = UDim2.fromOffset(0, 60), BackgroundColor3 = C.selected, TextColor3 = C.muted, TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -8, 0, 57), LayoutOrder = 14, ZIndex = 104 })
    enter:SetAttribute("Disabled", true)
    warningText("Potrzebujesz wsparcia?", { TextSize = 12, TextColor3 = C.muted, LayoutOrder = 16 })
    warningText("112 — bezpośrednie zagrożenie\n116 111 — telefon zaufania dla dzieci i młodzieży", {
        TextSize = 12, TextColor3 = C.muted, LineHeight = 1.4, LayoutOrder = 17 })

    function self:setReady(ready, worldReady, artReady)
        if ready ~= nil then self.gate.ready = ready end
        if worldReady ~= nil then self.gate.worldReady = worldReady end
        if artReady ~= nil then self.gate.artReady = artReady end
        start:SetAttribute("Disabled", not Presentation.canEnter(self.gate))
        refreshGate()
    end
    function self:showBackground(visible) self.backdrop.Visible = visible end
    function self:resize(width, height, topInset)
        local L = Presentation.layout(width, height)
        local safeTop = (topInset or 58) + 12
        local top = math.max(safeTop + 55, L.compact and 125 or math.floor(height * 0.22))
        menuScale.Scale = L.scale
        veilGradient.Enabled = not L.compact
        veil.BackgroundTransparency = L.compact and 0.28 or 0
        menuContent.Position = UDim2.fromOffset(L.margin, top)
        menuContent.Size = UDim2.fromOffset(L.menuWidth / L.scale, math.max(120, height - top - (L.compact and 30 or 96)) / L.scale)
        menuContent.ScrollBarThickness = L.compact and 2 or 0
        title.TextSize = L.titleSize
        title.Size = UDim2.new(1, -8, 0, L.compact and 158 or 225)
        masthead.Position = UDim2.fromOffset(L.margin, safeTop)
        local chromeScale = math.max(1, L.scale)
        topVeil.Size = UDim2.new(1, 0, 0, safeTop + 95 * chromeScale)
        mastheadScale.Scale, footerScale.Scale = chromeScale, chromeScale
        masthead.Size = UDim2.fromOffset((width - 2 * L.margin) / chromeScale, 45)
        location.Visible = not L.compact
        setting.Size = UDim2.fromOffset(L.compact and 105 or 120, 36)
        footer.Visible = not L.compact
        footer.Position = UDim2.new(0, L.margin, 1, -48)
        footer.Size = UDim2.fromOffset((width - 2 * L.margin) / chromeScale, 25)
        chapter.Visible = not L.compact and height > 620
        chapterScale.Scale = L.scale
        chapter.AnchorPoint = Vector2.new(1, 1)
        chapter.Position = UDim2.new(1, -L.margin, 1, -106)
        chapter.Size = UDim2.fromOffset(320, 142)
        warningScale.Scale, shadowScale.Scale = L.warningScale, L.warningScale
        local cardHeight = math.min((L.compact and 760 or 650) * L.warningScale, height - safeTop - 32)
        local centerY = safeTop + (height - safeTop - 24) / 2
        card.Size = UDim2.fromOffset(L.warningWidth / L.warningScale, cardHeight / L.warningScale)
        card.Position = UDim2.new(0.5, 0, 0, centerY)
        shadow.Size = UDim2.fromOffset(L.warningWidth / L.warningScale + 14, cardHeight / L.warningScale + 18)
        shadow.Position = UDim2.new(0.5, 0, 0, centerY + 9)
        warningContent.Position = UDim2.fromOffset(L.compact and 22 or 38, 30)
        warningContent.Size = UDim2.new(1, L.compact and -44 or -76, 1, -208)
        actions.Position = UDim2.new(0, L.compact and 22 or 38, 1, -148)
        actions.Size = UDim2.new(1, L.compact and -44 or -76, 0, 120)
        separator.Position = UDim2.new(0, L.compact and 22 or 38, 1, -165)
        separator.Size = UDim2.new(1, L.compact and -44 or -76, 0, 1)
        warningTitle.TextSize = L.compact and 27 or 37
    end
    return self
end

return FrontEnd
