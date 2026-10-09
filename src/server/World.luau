local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage:WaitForChild("Friday"):WaitForChild("WorldData"))

local World = {}
local palette = {
    plaster = Color3.fromRGB(204, 207, 209), trim = Color3.fromRGB(64, 78, 89),
    brick = Color3.fromRGB(99, 109, 117), wood = Color3.fromRGB(133, 113, 89),
    dark = Color3.fromRGB(42, 57, 61), paper = Color3.fromRGB(229, 230, 226),
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
    local shirt = Color3.fromRGB(table.unpack(data.color))
    local skin = Color3.fromRGB(208, 169, 137)
    local torso = part(model, "Torso", Vector3.new(1.8, 2, 1), pos, shirt, Enum.Material.Fabric)
    local head = part(model, "Head", Vector3.new(1.25, 1.25, 1.25), pos + Vector3.new(0, 1.65, 0), skin)
    local headMesh = Instance.new("SpecialMesh")
    headMesh.MeshType = Enum.MeshType.Head
    headMesh.Scale = Vector3.new(1.1, 1.1, 1.1)
    headMesh.Parent = head
    local face = Instance.new("Decal")
    face.Name = "Face"
    face.Face = Enum.NormalId.Front
    face.Texture = "rbxasset://textures/face.png"
    face.Parent = head
    local hairColor = name == "Lena" and Color3.fromRGB(96, 67, 49) or Color3.fromRGB(46, 41, 40)
    local hair = part(model, "Hair", Vector3.new(1.37, 0.5, 1.37), pos + Vector3.new(0, 2.16, 0), hairColor)
    local hairMesh = Instance.new("SpecialMesh")
    hairMesh.MeshType = Enum.MeshType.Sphere
    hairMesh.Scale = Vector3.new(1, 1.7, 1)
    hairMesh.Parent = hair
    if name == "Lena" or name == "Pedagog" then
        for _, side in ipairs({ -1, 1 }) do
            local lock = part(model, "HairLock", Vector3.new(0.25, 1.2, 0.85), pos + Vector3.new(side * 0.65, 1.5, 0.22), hairColor)
            lock.CanCollide = false
        end
    end
    part(model, "Collar", Vector3.new(0.7, 0.2, 1.02), pos + Vector3.new(0, 0.9, 0), palette.paper)
    part(model, "ShirtSeam", Vector3.new(0.05, 1.65, 0.025), pos + Vector3.new(0, -0.05, -0.515), palette.paper)
    for _, side in ipairs({ -1, 1 }) do
        part(model, "Sleeve", Vector3.new(0.58, 1.45, 0.78), pos + Vector3.new(side * 1.21, 0.18, 0), shirt, Enum.Material.Fabric)
        local hand = part(model, "Hand", Vector3.new(0.55, 0.52, 0.72), pos + Vector3.new(side * 1.21, -0.8, 0), skin)
        local handMesh = Instance.new("SpecialMesh")
        handMesh.MeshType = Enum.MeshType.Sphere
        handMesh.Parent = hand
        part(model, "Trousers", Vector3.new(0.76, 1.7, 0.83), pos + Vector3.new(side * 0.46, -1.85, 0), palette.dark, Enum.Material.Fabric)
        part(model, "Shoe", Vector3.new(0.81, 0.3, 1.05), pos + Vector3.new(side * 0.46, -2.65, -0.08), Color3.fromRGB(30, 32, 35))
        part(model, "Sole", Vector3.new(0.82, 0.1, 1.08), pos + Vector3.new(side * 0.46, -2.85, -0.08), palette.paper)
    end
    if name == "Olek" then
        part(model, "Satchel", Vector3.new(0.85, 1, 0.35), pos + Vector3.new(0.95, -0.55, 0.22), palette.wood)
        part(model, "SatchelStrap", Vector3.new(0.15, 2, 0.04), pos + Vector3.new(-0.3, 0, -0.53), palette.dark).Orientation = Vector3.new(0, 0, -24)
    elseif name == "Dyrektor" or name == "Marta" then
        local glasses = part(model, "GlassesBridge", Vector3.new(0.7, 0.04, 0.04), head.Position + Vector3.new(0, 0.1, -0.68), palette.dark)
        glasses.CanCollide = false
        for _, side in ipairs({ -1, 1 }) do
            local frame = part(model, "Glasses", Vector3.new(0.42, 0.28, 0.04), head.Position + Vector3.new(side * 0.27, 0.1, -0.7), palette.dark)
            local lens = part(model, "Lens", Vector3.new(0.33, 0.19, 0.04), frame.Position + Vector3.new(0, 0, -0.025), Color3.fromRGB(184, 202, 205), Enum.Material.Glass)
            frame.CanCollide, lens.CanCollide = false, false
            lens.Transparency = 0.65
        end
    end
    model.PrimaryPart = torso
    -- Każda postać patrzy w stronę korytarza lub środka dziedzińca.
    model:PivotTo(CFrame.lookAt(pos, Vector3.new(0, pos.Y, pos.Z + (name == "Marta" and 16 or 0))))
    local tag = Instance.new("BillboardGui")
    tag.Name = "Nameplate"
    tag.Size = UDim2.fromOffset(180, 36)
    tag.StudsOffset = Vector3.new(0, 3.6, 0)
    tag.MaxDistance = 18
    tag.Adornee = torso
    tag.Parent = torso
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamMedium
    text.TextSize = 13
    text.TextColor3 = palette.paper
    text.TextStrokeTransparency = 0.35
    text.Text = data.label
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
        -- Ściana ma prawdziwe otwory: szyby nie są naklejone na pełny mur.
        part(architecture, "FacadeBase", Vector3.new(62, 4, 1), Vector3.new(x, 2, 20), palette.brick, Enum.Material.Brick)
        part(architecture, "FacadeHeader", Vector3.new(62, 3, 1), Vector3.new(x, 11.5, 20), palette.brick, Enum.Material.Brick)
        local cursor = x - 31
        for _, wx in ipairs({ x - 15, x, x + 15 }) do
            local edge = wx - 4
            part(architecture, "FacadePier", Vector3.new(edge - cursor, 6, 1), Vector3.new((edge + cursor) / 2, 7, 20), palette.brick, Enum.Material.Brick)
            cursor = wx + 4
            local glass = part(architecture, "Window", Vector3.new(8, 6, 0.18), Vector3.new(wx, 7, 20.15), Color3.fromRGB(163, 189, 201), Enum.Material.Glass)
            glass.Transparency, glass.Reflectance = 0.7, 0.08
            for _, side in ipairs({ -1, 1 }) do
                part(architecture, "WindowFrame", Vector3.new(0.18, 6.2, 0.55), Vector3.new(wx + side * 4, 7, 20.2), palette.paper)
            end
            part(architecture, "WindowSill", Vector3.new(8.6, 0.25, 1.2), Vector3.new(wx, 4, 20.3), palette.paper)
            part(architecture, "WindowHeader", Vector3.new(8.6, 0.18, 0.55), Vector3.new(wx, 10, 20.2), palette.paper)
            part(architecture, "WindowMullion", Vector3.new(0.18, 6, 0.55), Vector3.new(wx, 7, 20.2), palette.paper)
            part(architecture, "WindowCrossbar", Vector3.new(8, 0.15, 0.55), Vector3.new(wx, 7.4, 20.2), palette.paper)
        end
        part(architecture, "FacadePier", Vector3.new(x + 31 - cursor, 6, 1), Vector3.new((x + 31 + cursor) / 2, 7, 20), palette.brick, Enum.Material.Brick)
    end
    part(architecture, "EntranceLintel", Vector3.new(28, 3, 2), Vector3.new(0, 11.5, 20), palette.trim)
    local sign = part(architecture, "SchoolSign", Vector3.new(25, 2, 0.3), Vector3.new(0, 11.5, 21.2), palette.dark)
    -- Front ściany jest skierowany na dziedziniec.
    label(sign, "SZKOŁA PODSTAWOWA", 24, palette.paper, Enum.NormalId.Back)
    for _, spec in ipairs({ { -18, -64, -32 }, { -18, -14, -4 }, { -18, 12, 20 }, { 18, -64, -57 }, { 18, -41, -27 }, { 18, -9, 20 } }) do
        local x, a, b = table.unpack(spec)
        part(architecture, "Partition", Vector3.new(0.6, 11, b - a), Vector3.new(x, 5.5, (a + b) / 2), palette.plaster)
        part(architecture, "Wainscot", Vector3.new(0.7, 3, b - a), Vector3.new(x, 1.5, (a + b) / 2), palette.trim)
    end
    part(architecture, "LibraryWall", Vector3.new(58, 11, 0.5), Vector3.new(-47, 5.5, -4), palette.plaster)
    part(architecture, "OfficeWall", Vector3.new(58, 11, 0.5), Vector3.new(47, 5.5, -32), palette.plaster)
    for _, x in ipairs({ -47, 47 }) do
        part(architecture, "Roof", Vector3.new(60, 0.7, 86), Vector3.new(x, 13.4, -22), palette.paper)
    end
    local skylight = part(architecture, "Skylight", Vector3.new(33, 0.35, 86), Vector3.new(0, 13.4, -22), Color3.fromRGB(152, 178, 188), Enum.Material.Glass)
    skylight.Transparency = 0.78
    for z = -63, 20, 12 do
        part(architecture, "SkylightBeam", Vector3.new(34, 0.4, 0.45), Vector3.new(0, 13.7, z), palette.dark, Enum.Material.Metal)
    end
    for _, x in ipairs({ -17, 17 }) do
        part(architecture, "RoofTrim", Vector3.new(0.4, 0.4, 86), Vector3.new(x, 13.7, -22), palette.dark, Enum.Material.Metal)
    end

    for _, point in ipairs({ { 0, 9 }, { 0, -17 }, { 0, -44 }, { -46, 7 }, { -46, -36 }, { 47, -14 }, { 47, -48 } }) do
        local lamp = part(decor, "CeilingPanel", Vector3.new(5, 0.2, 2), Vector3.new(point[1], 12.8, point[2]), Color3.fromRGB(240, 244, 239), Enum.Material.Neon)
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
    for treeIndex, point in ipairs({ { -70, 38 }, { 70, 38 }, { -70, 76 }, { 70, 76 } }) do
        local x, z = table.unpack(point)
        local trunk = part(decor, "TreeTrunk", Vector3.new(1.5, 13, 1.5), Vector3.new(x, 6.5, z), Color3.fromRGB(87, 76, 61), Enum.Material.Wood)
        trunk.Orientation = Vector3.new(0, treeIndex * 17, 2)
        for branch = 1, 3 do
            local limb = part(decor, "TreeBranch", Vector3.new(0.7, 7, 0.7), Vector3.new(x + (branch - 2) * 2, 11, z + (branch % 2) * 2), trunk.Color, Enum.Material.Wood)
            limb.Orientation = Vector3.new(branch * 14, branch * 85, (branch - 2) * 36)
        end
        for cluster = 1, 7 do
            local angle = cluster * 2.4 + treeIndex
            local spread = cluster == 7 and 0 or 5.5
            local crown = part(decor, "TreeCrown", Vector3.new(11 + cluster % 3, 9 + cluster % 2, 11),
                Vector3.new(x + math.cos(angle) * spread, 14 + cluster % 3 * 1.7, z + math.sin(angle) * spread),
                Color3.fromRGB(139 + cluster * 4, 119 + treeIndex * 4, 65 + cluster * 2), Enum.Material.Grass)
            crown.Shape = Enum.PartType.Ball
            crown.CanCollide = false
        end
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

    -- Korytarz: szafki, listwy, zegar, gablota i drobne ślady użytkowania.
    for _, spec in ipairs({ { -16, -48, 6 }, { 16, 7, 4 } }) do
        local x, startZ, count = table.unpack(spec)
        local facing = x < 0 and 1 or -1
        for i = 1, count do
            local z = startZ + i * 2.2
            part(decor, "Locker", Vector3.new(1.35, 6, 2.05), Vector3.new(x, 3.2, z), Color3.fromRGB(89 + i * 2, 102 + i * 2, 111 + i * 2), Enum.Material.Metal)
            part(decor, "LockerDoor", Vector3.new(0.08, 5.65, 1.91), Vector3.new(x + facing * 0.72, 3.25, z), Color3.fromRGB(107, 121, 130), Enum.Material.Metal)
            part(decor, "LockerHandle", Vector3.new(0.16, 0.38, 0.12), Vector3.new(x + facing * 0.81, 3.3, z + 0.6), palette.dark, Enum.Material.Metal)
            for row = 1, 3 do
                part(decor, "LockerVent", Vector3.new(0.06, 0.07, 1.1), Vector3.new(x + facing * 0.8, 5.3 - row * 0.16, z), palette.dark)
            end
        end
    end
    for z = -60, 16, 4 do
        part(decor, "FloorJoint", Vector3.new(33, 0.015, 0.025), Vector3.new(0, 0.305, z), Color3.fromRGB(141, 143, 140)).CanCollide = false
    end
    for _, x in ipairs({ -12, -4, 4, 12 }) do
        part(decor, "FloorJoint", Vector3.new(0.025, 0.015, 80), Vector3.new(x, 0.305, -22), Color3.fromRGB(141, 143, 140)).CanCollide = false
    end
    local clock = part(decor, "Clock", Vector3.new(3, 3, 0.3), Vector3.new(0, 9, -63.25), palette.dark)
    label(clock, "08:05", 32, palette.paper, Enum.NormalId.Back)
    local display = part(decor, "NoticeCase", Vector3.new(0.35, 4.8, 8), Vector3.new(17.55, 5.5, -3), palette.wood)
    label(display, "Z ŻYCIA SZKOŁY\nWystawa naszej dzielnicy\nBiblioteka · piątek", 18, palette.paper, Enum.NormalId.Left)
    part(decor, "Radiator", Vector3.new(1, 2.6, 9), Vector3.new(-16.9, 1.55, -8), palette.paper, Enum.Material.Metal)
    for z = -12, -4 do
        part(decor, "RadiatorFin", Vector3.new(1.1, 2.5, 0.15), Vector3.new(-16.85, 1.55, z), Color3.fromRGB(182, 187, 188))
    end
    for _, spec in ipairs({ { -18, -23 }, { -18, 4 }, { 18, -49 }, { 18, -18 } }) do
        local x, z = table.unpack(spec)
        for _, offset in ipairs({ -6.2, 6.2 }) do
            part(decor, "DoorJamb", Vector3.new(0.9, 9.5, 0.4), Vector3.new(x, 4.75, z + offset), palette.wood)
        end
        part(decor, "DoorLintel", Vector3.new(0.9, 0.6, 13), Vector3.new(x, 9.5, z), palette.wood)
    end
    for _, x in ipairs({ -42, 42 }) do
        local lamp = part(decor, "StandingLamp", Vector3.new(0.3, 10, 0.3), Vector3.new(x, 5, 72), palette.dark, Enum.Material.Metal)
        local hood = part(decor, "LampHead", Vector3.new(2.5, 0.4, 2.5), lamp.Position + Vector3.new(0, 5, 0), palette.dark)
        local bulb = part(decor, "LampBulb", Vector3.new(1.6, 0.08, 1.6), hood.Position - Vector3.new(0, 0.24, 0), Color3.fromRGB(238, 222, 192), Enum.Material.Neon)
        local light = Instance.new("PointLight")
        light.Color, light.Brightness, light.Range = bulb.Color, 0.65, 22
        light.Parent = bulb
    end

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
        prompt.Style = Enum.ProximityPromptStyle.Custom
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
    atmosphere.Density = 0.2
    atmosphere.Offset = 0.1
    atmosphere.Color = Color3.fromRGB(208, 222, 230)
    atmosphere.Decay = Color3.fromRGB(117, 142, 166)
    atmosphere:SetAttribute("FridayEffect", true)
    atmosphere.Parent = Lighting
    local grade = Instance.new("ColorCorrectionEffect")
    grade.Name = "FridayGrade"
    grade.Contrast = 0.18
    grade.Saturation = -0.22
    grade.TintColor = Color3.fromRGB(238, 245, 255)
    grade:SetAttribute("FridayEffect", true)
    grade.Parent = Lighting
    local bloom = Instance.new("BloomEffect")
    bloom.Name, bloom.Intensity, bloom.Size, bloom.Threshold = "FridayBloom", 0.15, 22, 1.3
    bloom:SetAttribute("FridayEffect", true)
    bloom.Parent = Lighting
    local rays = Instance.new("SunRaysEffect")
    rays.Name, rays.Intensity, rays.Spread = "FridaySunlight", 0.025, 0.9
    rays:SetAttribute("FridayEffect", true)
    rays.Parent = Lighting
    root:SetAttribute("Ready", true)
    return handles
end

return World
