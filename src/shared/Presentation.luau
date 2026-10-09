-- Rozmiary docelowe: 2560×1440. Tekst i geometria UI są renderowane natywnie.
local Presentation = {}

function Presentation.layout(width, height)
    width, height = math.max(width, 280), math.max(height, 240)
    local compact = width < 900
    local scale = compact and 1 or math.clamp(math.min(width / 1600, height / 900), 0.72, 1.6)
    local warningScale = compact and 1 or math.clamp(math.min(width / 1600, height / 900), 0.85, 1.3)
    local gameScale = compact and 1 or math.clamp(math.min(width / 1920, height / 1080), 1, 1.35)
    local margin = compact and 20 or math.floor(width * 0.065)
    return {
        compact = compact, margin = margin, scale = scale, warningScale = warningScale, gameScale = gameScale,
        menuWidth = compact and width - 2 * margin or math.min(660 * scale, width * 0.44),
        titleSize = compact and 66 or 98,
        panelWidth = math.min(840, width / gameScale - (compact and 24 or 80)),
        panelHeight = math.min(690, height / gameScale - (compact and 24 or 70)),
        warningWidth = math.min(820 * warningScale, width - 2 * margin),
    }
end

function Presentation.canEnter(gate)
    return gate.acknowledged == true and gate.ready == true and gate.worldReady == true and gate.artReady ~= false
end

return Presentation
