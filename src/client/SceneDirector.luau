local SceneDirector = {}

function SceneDirector.new(camera, lighting, worldData)
    local self = { elapsed = 0, actors = {}, actorIds = {}, actorsComplete = false, previousMode = nil }
    local focus = Instance.new("DepthOfFieldEffect")
    focus.Name = "FridayFocus"
    focus.FarIntensity = 0.13
    focus.NearIntensity = 0.05
    focus.InFocusRadius = 8
    focus.FocusDistance = 20
    focus.Enabled = false
    focus.Parent = lighting
    function self:update(dt, menuOpen, conversation, target, reducedMotion, playerPosition)
        self.elapsed += dt
        local cinematic = menuOpen or conversation
        focus.Enabled = cinematic
        if cinematic then
            camera.CameraType = Enum.CameraType.Scriptable
            local desired
            if menuOpen then
                local drift = reducedMotion and 0 or math.sin(self.elapsed * 0.075) * 0.45
                desired = CFrame.lookAt(Vector3.new(10 + drift, 5.7, 14), Vector3.new(-3, 4.8, -43))
                camera.FieldOfView = 56
                focus.FocusDistance = 32
            else
                local world = workspace:FindFirstChild("FridayWorld")
                local interactions = world and world:FindFirstChild("Interactions")
                local actor = interactions and interactions:FindFirstChild(target or "")
                if actor and actor:IsA("Model") and actor.PrimaryPart then
                    local root = actor.PrimaryPart
                    local subject = root.Position + Vector3.new(0, 1.2, 0)
                    desired = CFrame.lookAt(subject + root.CFrame.LookVector * 7 + root.CFrame.RightVector * 1.7 + Vector3.new(0, 0.5, 0), subject)
                    camera.FieldOfView = 48
                    focus.FocusDistance = 7
                end
            end
            if desired then
                if reducedMotion or self.previousMode == nil then camera.CFrame = desired
                else camera.CFrame = camera.CFrame:Lerp(desired, 1 - math.exp(-dt * 5)) end
            end
        else
            if self.previousMode then camera.CameraType = Enum.CameraType.Custom end
            camera.FieldOfView = 70
        end
        self.previousMode = cinematic
        if not self.actorsComplete then
            local world = workspace:FindFirstChild("FridayWorld")
            local interactions = world and world:FindFirstChild("Interactions")
            if interactions and world:GetAttribute("Ready") then
                local complete = true
                for id, data in pairs(worldData.targets) do
                    if not data.npc then continue end
                    local actor = interactions:FindFirstChild(id)
                    if not actor or not actor:IsA("Model") or not actor.PrimaryPart then
                        complete = false
                    elseif not self.actorIds[id] then
                        table.insert(self.actors, { model = actor, rest = actor:GetPivot(), current = actor:GetPivot() })
                        self.actorIds[id] = true
                    end
                end
                self.actorsComplete = complete
            end
        end
        if not reducedMotion then
            for index, actor in ipairs(self.actors) do
                if actor.model.Parent then
                    local desired = actor.rest
                    if playerPosition and not menuOpen and not conversation and (playerPosition - actor.rest.Position).Magnitude < 14 then
                        local point = Vector3.new(playerPosition.X, actor.rest.Position.Y, playerPosition.Z)
                        if (point - actor.rest.Position).Magnitude > 0.5 then desired = CFrame.lookAt(actor.rest.Position, point) end
                    end
                    actor.current = actor.current:Lerp(desired, 1 - math.exp(-dt * 2))
                    actor.model:PivotTo(actor.current + Vector3.new(0, math.sin(self.elapsed * 1.8 + index) * 0.018, 0))
                end
            end
        end
    end
    function self:destroy() focus:Destroy() end
    return self
end

return SceneDirector
