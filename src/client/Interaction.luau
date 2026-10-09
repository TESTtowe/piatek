local ProximityPromptService = game:GetService("ProximityPromptService")
local Interaction = {}

function Interaction.new(gui, UI)
    local C = UI.colors
    local current, generation, holding = nil, 0, nil
    local root = UI.frame(gui, { Name = "InteractionHint", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -58),
        Size = UDim2.fromOffset(304, 64), BackgroundColor3 = C.ink, BackgroundTransparency = 0.12, Visible = false, ZIndex = 20 })
    UI.corner(root, 3)
    UI.stroke(root)
    local button = UI.make("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), AutoButtonColor = false, ZIndex = 21 }, root)
    local key = UI.text(root, "E", { Position = UDim2.fromOffset(15, 14), Size = UDim2.fromOffset(36, 36), Font = Enum.Font.Code,
        TextSize = 19, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 22 })
    local target = UI.text(root, "", { Position = UDim2.fromOffset(68, 12), Size = UDim2.new(1, -82, 0, 19), TextSize = 14, Font = Enum.Font.GothamMedium, ZIndex = 22 })
    local action = UI.text(root, "", { Position = UDim2.fromOffset(68, 34), Size = UDim2.new(1, -82, 0, 16), TextSize = 10, TextColor3 = C.muted, Font = Enum.Font.Code, ZIndex = 22 })
    local bar = UI.rule(root, UDim2.new(0, 0, 1, -2), UDim2.new(0, 0, 0, 2), C.amber, 22)
    button.Activated:Connect(function()
        local prompt = current
        if not prompt or not prompt.Enabled then return end
        generation += 1
        local token = generation
        if holding then holding:InputHoldEnd() end
        holding = prompt
        prompt:InputHoldBegin()
        task.delay(prompt.HoldDuration + 0.05, function()
            if token == generation and holding == prompt then
                if prompt.Parent then prompt:InputHoldEnd() end
                holding = nil
            end
        end)
    end)
    ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
        if prompt.Name ~= "StoryPrompt" then return end
        current = prompt
        root.Visible = true
        key.Text = inputType == Enum.ProximityPromptInputType.Touch and "→" or inputType == Enum.ProximityPromptInputType.Gamepad and "X" or "E"
        target.Text = prompt.ObjectText
        action.Text = string.upper(prompt.ActionText)
        bar.Size = UDim2.new(0, 0, 0, 2)
    end)
    ProximityPromptService.PromptHidden:Connect(function(prompt)
        if current ~= prompt then return end
        generation += 1
        if holding == prompt then
            if prompt.Parent then prompt:InputHoldEnd() end
            holding = nil
        end
        current = nil
        root.Visible = false
    end)
    ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
        if current == prompt then UI.tween(bar, { Size = UDim2.new(1, 0, 0, 2) }, prompt.HoldDuration) end
    end)
    ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt)
        if current == prompt then UI.tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, 0.1) end
    end)
    return root
end

return Interaction
