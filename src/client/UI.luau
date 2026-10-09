local TweenService = game:GetService("TweenService")
local UI = {}
UI.colors = {
    ink = Color3.fromRGB(12, 14, 17), panel = Color3.fromRGB(24, 27, 32),
    paper = Color3.fromRGB(235, 234, 228), muted = Color3.fromRGB(151, 155, 163),
    amber = Color3.fromRGB(219, 92, 75), teal = Color3.fromRGB(235, 234, 228),
    line = Color3.fromRGB(58, 62, 69), error = Color3.fromRGB(235, 130, 113),
    selected = Color3.fromRGB(55, 40, 40), positive = Color3.fromRGB(143, 177, 153),
}
UI.reducedMotion = false

function UI.make(class, props, parent)
    local obj = Instance.new(class)
    for key, value in pairs(props or {}) do obj[key] = value end
    obj.Parent = parent
    return obj
end

function UI.corner(object, radius)
    UI.make("UICorner", { CornerRadius = UDim.new(0, radius or 3) }, object)
end

function UI.stroke(object, color)
    return UI.make("UIStroke", { Color = color or UI.colors.line, Thickness = 1, Transparency = 0.35, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, object)
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
        AutoButtonColor = false, BorderSizePixel = 0, TextWrapped = true, Selectable = true,
        Size = UDim2.new(1, 0, 0, 50) }
    for k, v in pairs(props or {}) do base[k] = v end
    local button = UI.make("TextButton", base, parent)
    UI.corner(button, 3)
    local border = UI.stroke(button)
    UI.make("UIPadding", { PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18) }, button)
    local function focus()
        if button:GetAttribute("Disabled") then return end
        UI.tween(border, { Color = UI.colors.paper, Transparency = 0.05 }, 0.15)
    end
    local function blur()
        UI.tween(border, { Color = UI.colors.line, Transparency = 0.35 }, 0.15)
    end
    button.MouseEnter:Connect(focus)
    button.MouseLeave:Connect(blur)
    button.SelectionGained:Connect(focus)
    button.SelectionLost:Connect(blur)
    button.Activated:Connect(function() if not button:GetAttribute("Disabled") then callback() end end)
    return button
end

function UI.rule(parent, position, size, color, zindex)
    return UI.frame(parent, { Position = position, Size = size, BackgroundColor3 = color or UI.colors.line, ZIndex = zindex or parent.ZIndex })
end

function UI.link(parent, value, callback, props)
    local base = { BackgroundTransparency = 1, Text = value, TextColor3 = UI.colors.muted,
        TextSize = 15, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), Selectable = true }
    for key, val in pairs(props or {}) do base[key] = val end
    local button = UI.make("TextButton", base, parent)
    local function focus() UI.tween(button, { TextColor3 = UI.colors.paper }, 0.15) end
    local function blur() UI.tween(button, { TextColor3 = base.TextColor3 }, 0.15) end
    button.MouseEnter:Connect(focus)
    button.MouseLeave:Connect(blur)
    button.SelectionGained:Connect(focus)
    button.SelectionLost:Connect(blur)
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
