-- Rozmiary i przepływ wejścia są testowane niezależnie od silnika Roblox.
local Presentation = {}

function Presentation.layout(width, height)
    width, height = math.max(width, 280), math.max(height, 240)
    local compact = width < 760
    local margin = compact and 24 or math.clamp(math.floor(width * 0.065), 48, 110)
    return {
        compact = compact, margin = margin,
        menuWidth = compact and width - 2 * margin or math.min(510, width * 0.42),
        titleSize = compact and 68 or math.clamp(math.floor(height * 0.115), 68, 112),
        panelWidth = math.min(840, width - (compact and 24 or 80)),
        panelHeight = math.min(690, height - (compact and 24 or 70)),
        warningWidth = math.min(720, width - 2 * margin),
    }
end

function Presentation.canEnter(gate)
    return gate.acknowledged == true and gate.ready == true and gate.worldReady == true
end

return Presentation
