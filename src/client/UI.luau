local TweenService = game:GetService("TweenService")
local UI = {}
UI.colors = {
    ink = Color3.fromRGB(18, 29, 33), panel = Color3.fromRGB(27, 42, 46),
    paper = Color3.fromRGB(240, 228, 201), muted = Color3.fromRGB(161, 181, 180),
    amber = Color3.fromRGB(224, 172, 103), teal = Color3.fromRGB(91, 156, 153),
    line = Color3.fromRGB(66, 86, 88), error = Color3.fromRGB(231, 153, 135),
}
UI.reducedMotion = false

function UI.make(class, props, parent)
    local obj = Instance.new(class)
    for key, value in pairs(props or {}) do obj[key] = value end
    obj.Parent = parent
    return obj
end

function UI.corner(object, radius)
    UI.make("UICorner", { CornerRadius = UDim.new(0, radius or 12) }, object)
end

function UI.stroke(object, color)
    UI.make("UIStroke", { Color = color or UI.colors.line, Thickness = 1, Transparency = 0.25 }, object)
end

function UI.frame(parent, props)
    local base = { BorderSizePixel = 0, BackgroundColor3 = UI.colors.panel }
    for k, v in pairs(props or {}) do base[k] = v end
    return UI.make("Frame", base, parent)
end

function UI.text(parent, value, props)
    local base = { BackgroundTransparency = 1, Text = value, TextColor3 = UI.colors.paper,
        Font = Enum.Font.Gotham, TextSize = 16, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, 0, 0, 30), BorderSizePixel = 0 }
    for k, v in pairs(props or {}) do base[k] = v end
    return UI.make("TextLabel", base, parent)
end

function UI.tween(object, props, seconds)
    if UI.reducedMotion then
        for key, value in pairs(props) do object[key] = value end
        return
    end
    TweenService:Create(object, TweenInfo.new(seconds or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

function UI.button(parent, value, callback, props)
    local base = { Text = value, TextColor3 = UI.colors.paper, TextSize = 15,
        Font = Enum.Font.GothamMedium, BackgroundColor3 = UI.colors.panel,
        AutoButtonColor = false, BorderSizePixel = 0, TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 48) }
    for k, v in pairs(props or {}) do base[k] = v end
    local button = UI.make("TextButton", base, parent)
    UI.corner(button, 9)
    UI.stroke(button)
    local normal = button.BackgroundColor3
    button.MouseEnter:Connect(function() UI.tween(button, { BackgroundColor3 = UI.colors.line }, 0.15) end)
    button.MouseLeave:Connect(function() UI.tween(button, { BackgroundColor3 = normal }, 0.15) end)
    button.Activated:Connect(callback)
    return button
end

function UI.list(parent, gap)
    return UI.make("UIListLayout", { Padding = UDim.new(0, gap or 10), SortOrder = Enum.SortOrder.LayoutOrder }, parent)
end

function UI.scroll(parent, props)
    local base = { BackgroundTransparency = 1, BorderSizePixel = 0,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = UI.colors.teal, ScrollingDirection = Enum.ScrollingDirection.Y }
    for k, v in pairs(props or {}) do base[k] = v end
    local scroll = UI.make("ScrollingFrame", base, parent)
    UI.make("UIPadding", { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 7), PaddingBottom = UDim.new(0, 12) }, scroll)
    return scroll
end

function UI.autoText(parent, value, props)
    local p = { AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), TextSize = 18 }
    for k, v in pairs(props or {}) do p[k] = v end
    return UI.text(parent, value, p)
end

return UI
