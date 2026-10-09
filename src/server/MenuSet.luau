-- Osobny kadr menu: skala, okna i światło dopasowane do kompozycji ekranu.
-- Poza obszarem gry; brak interakcji i kolizji z graczami.
local MenuSet = {}
function MenuSet.build(parent)
    local root = Instance.new("Model")
    root.Name = "MenuSet"
    root.Parent = parent
    local ivory = Color3.fromRGB(218, 213, 193)
    local sage = Color3.fromRGB(104, 122, 113)
    local wood = Color3.fromRGB(101, 76, 54)
    local function box(name, size, position, color, material)
        local p = Instance.new("Part")
        p.Name, p.Size, p.Position, p.Color = name, size, position, color
        p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
        p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
        p.Material = material or Enum.Material.SmoothPlastic
        p.Parent = root
        return p
    end
    box("Terrazzo", Vector3.new(25, 0.3, 74), Vector3.new(0, -0.1, -363), Color3.fromRGB(155, 150, 135), Enum.Material.Marble).Reflectance = 0.06
    box("Ceiling", Vector3.new(25, 0.3, 74), Vector3.new(0, 12.2, -363), ivory)
    box("LeftWall", Vector3.new(0.5, 12, 74), Vector3.new(-12, 6, -363), ivory, Enum.Material.Concrete)
    box("LeftWainscot", Vector3.new(0.56, 4.3, 74), Vector3.new(-11.96, 2.15, -363), sage)
    box("RightWainscot", Vector3.new(0.5, 4.3, 74), Vector3.new(12, 2.15, -363), sage)
    box("WindowHeader", Vector3.new(0.5, 1.3, 74), Vector3.new(12, 11.5, -363), ivory)
    for _, x in ipairs({ -11.65, 11.65 }) do
        box("Skirting", Vector3.new(0.16, 0.45, 74), Vector3.new(x, 0.25, -363), wood)
        box("DadoRail", Vector3.new(0.2, 0.14, 74), Vector3.new(x, 4.3, -363), ivory)
    end
    for z = -398, -326, 8 do
        box("WindowPier", Vector3.new(0.7, 7.6, 0.7), Vector3.new(12, 8.1, z), ivory)
        if z < -326 then
            local glass = box("DaylightGlass", Vector3.new(0.15, 6.6, 7.3), Vector3.new(12, 7.65, z + 4), Color3.fromRGB(185, 200, 199), Enum.Material.Glass)
            glass.Transparency = 0.82
            box("WindowSill", Vector3.new(1.1, 0.17, 7.6), Vector3.new(11.75, 4.4, z + 4), ivory)
            box("WindowMullion", Vector3.new(0.38, 6.6, 0.14), Vector3.new(11.82, 7.65, z + 4), ivory)
            box("WindowCrossbar", Vector3.new(0.38, 0.14, 7.6), Vector3.new(11.82, 8.25, z + 4), ivory)
            box("RadiatorBack", Vector3.new(0.5, 2.6, 5.3), Vector3.new(11.4, 1.8, z + 4), Color3.fromRGB(172, 168, 151), Enum.Material.Metal)
            for fin = 1, 12 do
                box("RadiatorFin", Vector3.new(0.75, 2.55, 0.15), Vector3.new(11.1, 1.8, z + 1.45 + fin * 0.4), ivory, Enum.Material.Metal)
            end
            box("RadiatorValve", Vector3.new(0.35, 0.3, 0.35), Vector3.new(11, 2.7, z + 6.8), wood, Enum.Material.Metal)
        end
    end
    for index, z in ipairs({ -340, -357, -375, -391 }) do
        box("DoorFrame", Vector3.new(0.6, 9.2, 5.5), Vector3.new(-11.5, 4.6, z), wood, Enum.Material.Wood)
        box("Door", Vector3.new(0.24, 8.6, 4.9), Vector3.new(-11.08, 4.4, z), Color3.fromRGB(132, 101, 72), Enum.Material.Wood)
        for _, offset in ipairs({ -1.2, 1.2 }) do
            box("DoorPanel", Vector3.new(0.14, 5.2, 1.9), Vector3.new(-10.91, 4.6, z + offset), wood, Enum.Material.Wood)
        end
        box("Handle", Vector3.new(0.25, 0.15, 0.6), Vector3.new(-10.76, 4.15, z + 1.75), Color3.fromRGB(193, 178, 135), Enum.Material.Metal)
        if index < 4 then
            local fixture = box("FluorescentHousing", Vector3.new(1.1, 0.35, 6), Vector3.new(0, 11.7, z - 2), Color3.fromRGB(117, 123, 112), Enum.Material.Metal)
            box("Diffuser", Vector3.new(0.85, 0.06, 5.6), fixture.Position - Vector3.new(0, 0.21, 0), Color3.fromRGB(234, 228, 196), Enum.Material.Neon)
            local light = Instance.new("SurfaceLight")
            light.Face, light.Angle, light.Brightness, light.Range, light.Shadows = Enum.NormalId.Bottom, 130, 0.65, 17, true
            light.Color = Color3.fromRGB(244, 227, 190)
            light.Parent = fixture
        end
    end
    for z = -398, -326, 6 do
        box("FloorJoint", Vector3.new(24, 0.012, 0.026), Vector3.new(0, 0.055, z), Color3.fromRGB(126, 125, 114))
        box("CeilingBeam", Vector3.new(24, 0.25, 0.3), Vector3.new(0, 12, z), ivory)
    end
    local board = box("CorkboardFrame", Vector3.new(0.35, 4.9, 7.8), Vector3.new(-11.2, 7, -348), wood, Enum.Material.Wood)
    box("Cork", Vector3.new(0.15, 4.5, 7.4), board.Position + Vector3.new(0.22, 0, 0), Color3.fromRGB(156, 130, 87), Enum.Material.Fabric)
    for i = 1, 5 do
        local paper = box("Paper", Vector3.new(0.03, 1.6 + i % 2 * 0.3, 1.2), Vector3.new(-10.96, 6.1 + i % 2 * 1.7, -351 + i * 1.1), ivory)
        paper.Orientation = Vector3.new(i % 2 * 4, 0, 0)
    end
    for i = 1, 6 do
        local z = -370 - i * 2.15
        box("Locker", Vector3.new(1.3, 6.3, 2), Vector3.new(-10.9, 3.2, z), sage, Enum.Material.Metal)
        box("LockerHandle", Vector3.new(0.17, 0.45, 0.1), Vector3.new(-10.15, 3.25, z + 0.6), wood, Enum.Material.Metal)
        for row = 1, 3 do box("Vent", Vector3.new(0.06, 0.05, 1), Vector3.new(-10.22, 5.3 - row * 0.15, z), Color3.fromRGB(61, 81, 71)) end
    end
    box("BenchSeat", Vector3.new(2.1, 0.25, 8), Vector3.new(9.1, 1.7, -349), wood, Enum.Material.Wood)
    for _, z in ipairs({ -352.2, -345.8 }) do
        box("BenchLeg", Vector3.new(1.9, 1.65, 0.3), Vector3.new(9.1, 0.85, z), Color3.fromRGB(62, 71, 65), Enum.Material.Metal)
    end
    box("EndWall", Vector3.new(24, 12, 0.5), Vector3.new(0, 6, -400), ivory)
    box("EndDoorFrame", Vector3.new(8, 9, 0.7), Vector3.new(2, 4.5, -399.6), wood, Enum.Material.Wood)
    local endDoor = box("EndGlass", Vector3.new(7.2, 8.3, 0.15), Vector3.new(2, 4.5, -399.15), Color3.fromRGB(143, 164, 156), Enum.Material.Glass)
    endDoor.Transparency = 0.4
    for _, x in ipairs({ -1.6, 2, 5.6 }) do box("EndMullion", Vector3.new(0.2, 8.3, 0.3), Vector3.new(x, 4.5, -399), wood) end
    box("ExteriorGarden", Vector3.new(80, 0.4, 100), Vector3.new(39, -0.5, -363), Color3.fromRGB(123, 130, 91), Enum.Material.Grass)
    for i = 1, 6 do
        local x, z = 31 + i % 2 * 8, -327 - i * 11
        box("AutumnTrunk", Vector3.new(1.3, 12, 1.3), Vector3.new(x, 6, z), wood, Enum.Material.Wood)
        for cluster = 1, 4 do
            local crown = box("AutumnFoliage", Vector3.new(10, 8, 10), Vector3.new(x + math.sin(cluster * 2) * 4, 13 + cluster % 2 * 3, z + math.cos(cluster * 2) * 4),
                Color3.fromRGB(157 + cluster * 9, 120 + cluster * 7, 62), Enum.Material.Grass)
            crown.Shape = Enum.PartType.Ball
        end
    end
    return root
end
return MenuSet
