local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage:WaitForChild("Friday"):WaitForChild("WorldData"))

local World = {}
local palette = {
    plaster = Color3.fromRGB(220, 216, 199), trim = Color3.fromRGB(64, 96, 95),
    brick = Color3.fromRGB(128, 86, 65), wood = Color3.fromRGB(144, 107, 70),
    dark = Color3.fromRGB(42, 57, 61), paper = Color3.fromRGB(237, 224, 187),
}

local function part(parent, name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function label(parent, text, size, color, face)
    local gui = Instance.new("SurfaceGui")
    gui.Face = face or Enum.NormalId.Front
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 40
    gui.Parent = parent
    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = color or palette.paper
    t.TextSize = size or 24
    t.Font = Enum.Font.GothamMedium
    t.TextWrapped = true
    t.Parent = gui
end

local function desk(parent, x, z, width)
    local w = width or 5
    part(parent, "Blat", Vector3.new(w, 0.35, 3), Vector3.new(x, 2.2, z), palette.wood, Enum.Material.Wood)
    for _, dx in ipairs({ -w / 2 + 0.3, w / 2 - 0.3 }) do
        part(parent, "Stelaż", Vector3.new(0.25, 2, 2.5), Vector3.new(x + dx, 1, z), palette.dark, Enum.Material.Metal)
    end
    part(parent, "Siedzisko", Vector3.new(2, 0.25, 2), Vector3.new(x, 1.25, z + 2.5), palette.trim)
    part(parent, "Oparcie", Vector3.new(2, 2, 0.25), Vector3.new(x, 2, z + 3.4), palette.trim)
    part(parent, "Noga krzesła", Vector3.new(0.6, 1.2, 0.6), Vector3.new(x, 0.6, z + 2.5), palette.dark)
end

local function plant(parent, x, z)
    part(parent, "Donica", Vector3.new(2, 2, 2), Vector3.new(x, 1, z), palette.brick)
    local leaves = part(parent, "Liście", Vector3.new(3, 4, 3), Vector3.new(x, 4, z), Color3.fromRGB(86, 112, 77), Enum.Material.Grass)
    leaves.Shape = Enum.PartType.Ball
    leaves.CanCollide = false
end

local function npc(parent, name, data)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent
    local pos = Vector3.new(table.unpack(data.position))
    local c = Color3.fromRGB(table.unpack(data.color))
    local torso = part(model, "Torso", Vector3.new(2, 2, 1), pos, c, Enum.Material.Fabric)
    local head = part(model, "Head", Vector3.new(1.3, 1.3, 1.3), pos + Vector3.new(0, 1.65, 0), Color3.fromRGB(211, 168, 130))
    local hair = part(model, "Hair", Vector3.new(1.4, 0.5, 1.4), pos + Vector3.new(0, 2.15, 0), palette.dark)
    hair.CanCollide = false
    for _, side in ipairs({ -1, 1 }) do
        part(model, "Arm", Vector3.new(0.65, 2, 0.8), pos + Vector3.new(side * 1.35, 0, 0), c)
        part(model, "Leg", Vector3.new(0.85, 1.9, 0.9), pos + Vector3.new(side * 0.5, -1.9, 0), palette.dark)
        local eye = part(model, "Eye", Vector3.new(0.13, 0.13, 0.05), head.Position + Vector3.new(side * 0.27, 0.07, -0.67), palette.dark)
        eye.CanCollide = false
    end
    model.PrimaryPart = torso
    local tag = Instance.new("BillboardGui")
    tag.Name = "Nameplate"
    tag.Size = UDim2.fromOffset(180, 46)
    tag.StudsOffset = Vector3.new(0, 3.8, 0)
    tag.MaxDistance = 28
    tag.Adornee = torso
    tag.Parent = torso
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamMedium
    text.TextSize = 14
    text.TextColor3 = palette.paper
    text.TextStrokeTransparency = 0.4
    text.Text = data.label .. "\n" .. data.role
    text.Parent = tag
    return torso
end

function World.build(onInteract)
    local previous = Workspace:FindFirstChild("FridayWorld")
    if previous then previous:Destroy() end
    local root = Instance.new("Model")
    root.Name = "FridayWorld"
    root.Parent = Workspace
    local architecture = Instance.new("Folder")
    architecture.Name = "Architecture"
    architecture.Parent = root
    local decor = Instance.new("Folder")
    decor.Name = "Furniture"
    decor.Parent = root
    local targets = Instance.new("Folder")
    targets.Name = "Interactions"
    targets.Parent = root
    part(architecture, "Ground", Vector3.new(240, 2, 240), Vector3.new(0, -1.2, 0), Color3.fromRGB(107, 124, 97), Enum.Material.Grass)
    part(architecture, "Courtyard", Vector3.new(112, 0.3, 70), Vector3.new(0, -0.05, 56), Color3.fromRGB(134, 137, 127), Enum.Material.Cobblestone)
    part(architecture, "SchoolFloor", Vector3.new(152, 0.4, 84), Vector3.new(0, 0, -22), Color3.fromRGB(179, 177, 162), Enum.Material.Concrete)
    part(architecture, "CorridorRunner", Vector3.new(30, 0.08, 80), Vector3.new(0, 0.25, -22), Color3.fromRGB(170, 156, 133), Enum.Material.Fabric)
    for _, x in ipairs({ -76, 76 }) do
        part(architecture, "ExteriorWall", Vector3.new(1, 13, 84), Vector3.new(x, 6.5, -22), palette.plaster, Enum.Material.Concrete)
    end
    part(architecture, "BackWall", Vector3.new(152, 13, 1), Vector3.new(0, 6.5, -64), palette.plaster)
    for _, x in ipairs({ -45, 45 }) do
        part(architecture, "Facade", Vector3.new(62, 13, 1), Vector3.new(x, 6.5, 20), palette.brick, Enum.Material.Brick)
        for _, wx in ipairs({ x - 15, x, x + 15 }) do
            local glass = part(architecture, "Window", Vector3.new(8, 6, 0.3), Vector3.new(wx, 7, 20.6), Color3.fromRGB(122, 166, 170), Enum.Material.Glass)
            glass.Transparency = 0.35
            part(architecture, "WindowSill", Vector3.new(9, 0.3, 1), Vector3.new(wx, 3.8, 20.8), palette.paper)
            part(architecture, "WindowMullion", Vector3.new(0.25, 6, 0.5), Vector3.new(wx, 7, 20.8), palette.paper)
        end
    end
    part(architecture, "EntranceLintel", Vector3.new(28, 3, 2), Vector3.new(0, 11.5, 20), palette.trim)
    local sign = part(architecture, "SchoolSign", Vector3.new(25, 2, 0.3), Vector3.new(0, 11.5, 21.2), palette.dark)
    -- Front ściany jest skierowany na dziedziniec.
    label(sign, "SZKOŁA · MIEJSCE ROZMÓW", 24, palette.paper, Enum.NormalId.Back)
    for _, spec in ipairs({ { -18, -64, -32 }, { -18, -14, -4 }, { -18, 12, 20 }, { 18, -64, -57 }, { 18, -41, -27 }, { 18, -9, 20 } }) do
        local x, a, b = table.unpack(spec)
        part(architecture, "Partition", Vector3.new(0.6, 11, b - a), Vector3.new(x, 5.5, (a + b) / 2), palette.plaster)
        part(architecture, "Wainscot", Vector3.new(0.7, 3, b - a), Vector3.new(x, 1.5, (a + b) / 2), palette.trim)
    end
    part(architecture, "LibraryWall", Vector3.new(58, 11, 0.5), Vector3.new(-47, 5.5, -4), palette.plaster)
    part(architecture, "OfficeWall", Vector3.new(58, 11, 0.5), Vector3.new(47, 5.5, -32), palette.plaster)
    part(architecture, "Roof", Vector3.new(154, 0.7, 86), Vector3.new(0, 13.4, -22), palette.paper)

    for _, z in ipairs({ 9, -17, -44 }) do
        local lamp = part(decor, "CeilingPanel", Vector3.new(5, 0.2, 2), Vector3.new(0, 12.8, z), Color3.fromRGB(251, 228, 183), Enum.Material.Neon)
        local light = Instance.new("PointLight")
        light.Color = lamp.Color
        light.Brightness = 0.8
        light.Range = 32
        light.Parent = lamp
    end
    for _, spec in ipairs({ { -19, -23, "BIBLIOTEKA" }, { 19, -18, "SEKRETARIAT" }, { 19, -49, "PEDAGOG" }, { -19, 4, "SALA 01" } }) do
        local plaque = part(decor, "RoomSign", Vector3.new(0.2, 1.3, 8), Vector3.new(spec[1], 7.8, spec[2]), palette.trim)
        label(plaque, spec[3], 19, palette.paper, spec[1] < 0 and Enum.NormalId.Right or Enum.NormalId.Left)
    end
    for _, x in ipairs({ -69, -59, -49, -39, -29 }) do
        local shelf = part(decor, "Bookcase", Vector3.new(7, 7, 2), Vector3.new(x, 3.5, -61), palette.wood, Enum.Material.Wood)
        for row = 1, 3 do
            part(decor, "Shelf", Vector3.new(7.2, 0.15, 2.3), shelf.Position + Vector3.new(0, row * 2 - 3.5, 0), palette.dark)
            for col = 1, 6 do
                part(decor, "Book", Vector3.new(0.6, 1.4 + (col % 2) * 0.2, 1.6), Vector3.new(x - 3 + col * 0.85, row * 2 - 0.8, -60.7), Color3.fromRGB(75 + col * 12, 91 + row * 14, 87 + col * 7))
            end
        end
    end
    for _, x in ipairs({ -62, -46, -32 }) do desk(decor, x, -40, 7) end
    desk(decor, 58, -22, 9)
    desk(decor, 43, -55, 7)
    desk(decor, 9, -48, 6)
    for _, x in ipairs({ -63, -44, -25 }) do for _, z in ipairs({ 3, 12 }) do desk(decor, x, z) end end
    local blackboard = part(decor, "Blackboard", Vector3.new(25, 6, 0.4), Vector3.new(-46, 6, -3.6), palette.trim)
    label(blackboard, "NASZA DZIELNICA\nLudzie. Miejsca. Małe historie.", 28, palette.paper, Enum.NormalId.Back)
    for _, x in ipairs({ -25, 25 }) do
        part(decor, "Bench", Vector3.new(14, 0.5, 3), Vector3.new(x, 1.4, 43), palette.wood, Enum.Material.Wood)
        part(decor, "BenchBack", Vector3.new(14, 2, 0.4), Vector3.new(x, 2.7, 44.5), palette.wood)
        for _, dx in ipairs({ -5, 5 }) do part(decor, "BenchLeg", Vector3.new(0.5, 1.4, 2), Vector3.new(x + dx, 0.7, 43), palette.dark) end
    end
    for _, point in ipairs({ { -70, 38 }, { 70, 38 }, { -70, 76 }, { 70, 76 } }) do
        local x, z = table.unpack(point)
        part(decor, "TreeTrunk", Vector3.new(2, 13, 2), Vector3.new(x, 6.5, z), palette.wood, Enum.Material.Wood)
        local crown = part(decor, "TreeCrown", Vector3.new(19, 15, 19), Vector3.new(x, 16, z), Color3.fromRGB(151, 132, 71), Enum.Material.Grass)
        crown.Shape = Enum.PartType.Ball
        crown.CanCollide = false
        for i = 1, 7 do
            local leaf = part(decor, "FallenLeaf", Vector3.new(0.8, 0.04, 0.45), Vector3.new(x + math.sin(i * 3) * 9, 0.05, z + math.cos(i * 5) * 9), Color3.fromRGB(167, 111, 59))
            leaf.CanCollide = false
        end
    end
    for _, p in ipairs({ { -15, -60 }, { 15, 12 }, { 70, -57 }, { -71, -8 } }) do plant(decor, p[1], p[2]) end
    for x = -100, 100, 20 do
        part(architecture, "FencePost", Vector3.new(0.6, 5, 0.6), Vector3.new(x, 2.5, 98), palette.dark, Enum.Material.Metal)
    end
    part(architecture, "FenceRail", Vector3.new(204, 0.25, 0.25), Vector3.new(0, 4, 98), palette.dark)
    for _, x in ipairs({ -102, 102 }) do part(architecture, "Boundary", Vector3.new(1, 6, 194), Vector3.new(x, 3, 2), palette.trim) end
    part(architecture, "Boundary", Vector3.new(204, 6, 1), Vector3.new(0, 3, -95), palette.trim)

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "FridaySpawn"
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Duration = 0
    spawn.Transparency = 1
    spawn.CanCollide = false
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.Position = Vector3.new(0, 0.8, 68)
    spawn.Parent = root
    local handles = {}
    for id, data in pairs(Data.targets) do
        local handle
        if data.npc then
            handle = npc(targets, id, data)
        else
            local pos = Vector3.new(table.unpack(data.position))
            if data.object == "board" then
                handle = part(targets, id, Vector3.new(6, 5, 0.35), pos, palette.trim)
                label(handle, "PIĄTEK\nPlan zajęć\n08:15 / 08:35 / 09:00", 20)
                for _, dx in ipairs({ -2.5, 2.5 }) do part(decor, "BoardLeg", Vector3.new(0.3, 4, 0.3), pos + Vector3.new(dx, -2, 0), palette.wood) end
            else
                handle = part(targets, id, Vector3.new(2.5, 0.15, 1.7), pos, palette.paper)
                label(handle, data.label, 15, palette.dark, Enum.NormalId.Top)
            end
        end
        handle:SetAttribute("TargetId", id)
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "StoryPrompt"
        prompt.ActionText = data.npc and "Porozmawiaj" or "Sprawdź"
        prompt.ObjectText = data.label
        prompt.HoldDuration = 0.15
        prompt.MaxActivationDistance = 11
        prompt.RequiresLineOfSight = false
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
        prompt.Parent = handle
        prompt.Triggered:Connect(function(player) onInteract(player, id) end)
        handles[id] = handle
    end

    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:GetAttribute("FridayEffect") then effect:Destroy() end
    end
    local atmosphere = Instance.new("Atmosphere")
    atmosphere.Density = 0.27
    atmosphere.Offset = 0.1
    atmosphere.Color = Color3.fromRGB(219, 215, 194)
    atmosphere.Decay = Color3.fromRGB(114, 138, 143)
    atmosphere:SetAttribute("FridayEffect", true)
    atmosphere.Parent = Lighting
    local grade = Instance.new("ColorCorrectionEffect")
    grade.Name = "FridayGrade"
    grade.Contrast = 0.12
    grade.Saturation = -0.12
    grade.TintColor = Color3.fromRGB(255, 240, 218)
    grade:SetAttribute("FridayEffect", true)
    grade.Parent = Lighting
    return handles
end

return World
