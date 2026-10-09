local TweenService = game:GetService("TweenService")
local UI = {}
UI.colors = {
    ink = Color3.fromRGB(9, 17, 23), panel = Color3.fromRGB(19, 29, 36),
    paper = Color3.fromRGB(247, 243, 231), muted = Color3.fromRGB(177, 187, 187),
    amber = Color3.fromRGB(221, 186, 127), teal = Color3.fromRGB(231, 205, 157),
    line = Color3.fromRGB(87, 105, 113), error = Color3.fromRGB(235, 139, 119),
    selected = Color3.fromRGB(53, 53, 45), positive = Color3.fromRGB(166, 205, 176),
}
UI.reducedMotion = false

function UI.make(class, props, parent)
    local obj = Instance.new(class)
    for key, value in pairs(props or {}) do obj[key] = value end
    obj.Parent = parent
    return obj
end

function UI.corner(object, radius)
    UI.make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, object)
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
    UI.corner(button, 8)
    local border = UI.stroke(button)
    local compactControl = base.Size.X.Scale == 0 and base.Size.X.Offset <= 64
    local inset = compactControl and 0 or 18
    UI.make("UIPadding", { PaddingLeft = UDim.new(0, inset), PaddingRight = UDim.new(0, inset) }, button)
    local function focus()
        if button:GetAttribute("Disabled") then return end
        UI.tween(border, { Color = UI.colors.paper, Transparency = 0.05 }, 0.15)
    end
    local function blur()
        UI.tween(border, { Color = button:GetAttribute("Selected") and UI.colors.amber or UI.colors.line, Transparency = 0.35 }, 0.15)
    end
    button.MouseEnter:Connect(focus)
    button.MouseLeave:Connect(blur)
    button.SelectionGained:Connect(focus)
    button.SelectionLost:Connect(blur)
    button.Activated:Connect(function() if not button:GetAttribute("Disabled") then callback() end end)
    return button
end

-- Małe ikony wektorowe; brak emoji, płatnych assetów i zależności od fontu.
function UI.icon(parent, kind, position, color, zindex)
    local root = UI.frame(parent, { Name = "Icon_" .. kind, Position = position, Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1, ZIndex = zindex })
    local function line(x, y, width, height, rotation)
        return UI.frame(root, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(width, height), Rotation = rotation or 0, BackgroundColor3 = color, ZIndex = zindex })
    end
    if kind == "warning" then
        line(5.5, 10, 20.5, 1.5, -61)
        line(15.5, 10, 20.5, 1.5, 61)
        line(10.5, 19, 20, 1.5)
        line(10.5, 9.5, 1.6, 6)
        line(10.5, 15.5, 1.8, 1.8)
    elseif kind == "people" then
        for _, x in ipairs({ 7, 16 }) do
            local head = line(x, 6, 5, 5)
            UI.corner(head, 5)
            line(x, 15, 8, 1.5)
            line(x - 3.5, 12, 1.5, 5)
            line(x + 3.5, 12, 1.5, 5)
        end
    else
        line(2, 10, 1.5, 17)
        line(20, 10, 1.5, 17)
        line(11, 2, 18, 1.5)
        line(11, 18, 18, 1.5)
        if kind == "book" then line(11, 10, 1.5, 17)
        else
            line(11, 7, 10, 1.5)
            line(9, 11, 6, 1.5)
        end
    end
    return root
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
