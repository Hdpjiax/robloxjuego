--!strict
-- Generator script for Zone 1 (Bosque Rúnico) in Studio
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local existing = Workspace:FindFirstChild("Zone1_BosqueRunico")
if existing then
    existing:Destroy()
end

local zone = Instance.new("Folder")
zone.Name = "Zone1_BosqueRunico"
zone.Parent = Workspace

--------------------------------------------------------------------------------
-- 1. PUENTE CONECTOR Y MURALLAS DEL CAÑÓN
--------------------------------------------------------------------------------
local bridgeModel = Instance.new("Model")
bridgeModel.Name = "BridgeConnector"
bridgeModel.Parent = zone

local bridgeFloor = Instance.new("Part")
bridgeFloor.Name = "BridgeFloor"
bridgeFloor.Anchored = true
bridgeFloor.CanCollide = true
bridgeFloor.Size = Vector3.new(22, 2.4, 38)
bridgeFloor.CFrame = CFrame.new(0, 1.2, 104)
bridgeFloor.Color = Color3.fromRGB(44, 50, 68)
bridgeFloor.Material = Enum.Material.Slate
bridgeFloor.Parent = bridgeModel

for _, xSide in ipairs({ -11.5, 11.5 }) do
    local wall = Instance.new("Part")
    wall.Name = "BridgeWall"
    wall.Anchored = true
    wall.CanCollide = true
    wall.Size = Vector3.new(2.4, 20, 38)
    wall.CFrame = CFrame.new(xSide, 10, 104)
    wall.Color = Color3.fromRGB(50, 58, 80)
    wall.Material = Enum.Material.Cobblestone
    wall.Parent = bridgeModel

    local trim = Instance.new("Part")
    trim.Anchored = true
    trim.CanCollide = true
    trim.Size = Vector3.new(3.2, 1.4, 38.4)
    trim.CFrame = wall.CFrame * CFrame.new(0, 10, 0)
    trim.Color = Color3.fromRGB(72, 82, 108)
    trim.Material = Enum.Material.Slate
    trim.Parent = bridgeModel

    for zOff = -14, 14, 14 do
        local lamp = Instance.new("Part")
        lamp.Shape = Enum.PartType.Ball
        lamp.Size = Vector3.new(1.8, 1.8, 1.8)
        lamp.CFrame = CFrame.new(xSide, 11.2, 104 + zOff)
        lamp.Color = Color3.fromRGB(0, 255, 140)
        lamp.Material = Enum.Material.Neon
        lamp.Anchored = true
        lamp.CanCollide = false
        lamp.Parent = bridgeModel

        local pl = Instance.new("PointLight")
        pl.Color = Color3.fromRGB(0, 255, 140)
        pl.Brightness = 2.0
        pl.Range = 16
        pl.Parent = lamp
    end
end

-- Acantilados Perimetrales (Cañón Místico Natural)
local wallsModel = Instance.new("Model")
wallsModel.Name = "Zone1_PerimeterCanyons"
wallsModel.Parent = zone

local CLIFF_H = 38
local CLIFF_THICK = 8

local westCliff = Instance.new("Part")
westCliff.Name = "WestCliff"
westCliff.Size = Vector3.new(CLIFF_THICK, CLIFF_H, 168)
westCliff.CFrame = CFrame.new(-56, CLIFF_H / 2, 206)
westCliff.Anchored = true
westCliff.CanCollide = true
westCliff.Color = Color3.fromRGB(36, 44, 48)
westCliff.Material = Enum.Material.Rock
westCliff.Parent = wallsModel

local eastCliff = Instance.new("Part")
eastCliff.Name = "EastCliff"
eastCliff.Size = Vector3.new(CLIFF_THICK, CLIFF_H, 168)
eastCliff.CFrame = CFrame.new(56, CLIFF_H / 2, 206)
eastCliff.Anchored = true
eastCliff.CanCollide = true
eastCliff.Color = Color3.fromRGB(36, 44, 48)
eastCliff.Material = Enum.Material.Rock
eastCliff.Parent = wallsModel

local southLeft = Instance.new("Part")
southLeft.Size = Vector3.new(44, CLIFF_H, CLIFF_THICK)
southLeft.CFrame = CFrame.new(-34, CLIFF_H / 2, 122)
southLeft.Anchored = true
southLeft.CanCollide = true
southLeft.Color = Color3.fromRGB(34, 40, 44)
southLeft.Material = Enum.Material.Rock
southLeft.Parent = wallsModel

local southRight = Instance.new("Part")
southRight.Size = Vector3.new(44, CLIFF_H, CLIFF_THICK)
southRight.CFrame = CFrame.new(34, CLIFF_H / 2, 122)
southRight.Anchored = true
southRight.CanCollide = true
southRight.Color = Color3.fromRGB(34, 40, 44)
southRight.Material = Enum.Material.Rock
southRight.Parent = wallsModel

local northLeft = Instance.new("Part")
northLeft.Size = Vector3.new(40, CLIFF_H, CLIFF_THICK)
northLeft.CFrame = CFrame.new(-36, CLIFF_H / 2, 288)
northLeft.Anchored = true
northLeft.CanCollide = true
northLeft.Color = Color3.fromRGB(34, 40, 44)
northLeft.Material = Enum.Material.Rock
northLeft.Parent = wallsModel

local northRight = Instance.new("Part")
northRight.Size = Vector3.new(40, CLIFF_H, CLIFF_THICK)
northRight.CFrame = CFrame.new(36, CLIFF_H / 2, 288)
northRight.Anchored = true
northRight.CanCollide = true
northRight.Color = Color3.fromRGB(34, 40, 44)
northRight.Material = Enum.Material.Rock
northRight.Parent = wallsModel

-- Portal de Entrada Mágico
local portalGate = Instance.new("Model")
portalGate.Name = "PortalToZone1"
portalGate.Parent = zone

local pLeft = Instance.new("Part")
pLeft.Size = Vector3.new(5, 26, 5)
pLeft.CFrame = CFrame.new(-12, 13, 122)
pLeft.Anchored = true
pLeft.CanCollide = true
pLeft.Color = Color3.fromRGB(42, 50, 70)
pLeft.Material = Enum.Material.Slate
pLeft.Parent = portalGate

local pRight = Instance.new("Part")
pRight.Size = Vector3.new(5, 26, 5)
pRight.CFrame = CFrame.new(12, 13, 122)
pRight.Anchored = true
pRight.CanCollide = true
pRight.Color = Color3.fromRGB(42, 50, 70)
pRight.Material = Enum.Material.Slate
pRight.Parent = portalGate

local pLintel = Instance.new("Part")
pLintel.Size = Vector3.new(29, 5, 6)
pLintel.CFrame = CFrame.new(0, 25.5, 122)
pLintel.Anchored = true
pLintel.CanCollide = true
pLintel.Color = Color3.fromRGB(34, 40, 58)
pLintel.Material = Enum.Material.Cobblestone
pLintel.Parent = portalGate

local greenBarrier = Instance.new("Part")
greenBarrier.Name = "GreenPortalBarrier"
greenBarrier.Size = Vector3.new(20, 22, 1.2)
greenBarrier.CFrame = CFrame.new(0, 11, 122)
greenBarrier.Anchored = true
greenBarrier.CanCollide = false
greenBarrier.Color = Color3.fromRGB(0, 255, 120)
greenBarrier.Material = Enum.Material.Neon
greenBarrier.Transparency = 0.65
greenBarrier.Parent = portalGate

local pe = Instance.new("ParticleEmitter")
pe.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 230, 90)),
})
pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0.1) })
pe.Lifetime = NumberRange.new(1.8, 3.2)
pe.Speed = NumberRange.new(1.5, 4)
pe.Rate = 22
pe.Parent = greenBarrier

--------------------------------------------------------------------------------
-- 2. TERRENO MULTI-NIVEL ESCALONADO (NO PLANO)
--------------------------------------------------------------------------------
local terrainFolder = Instance.new("Folder")
terrainFolder.Name = "TerrainFeatures"
terrainFolder.Parent = zone

-- Suelo base general
local baseGround = Instance.new("Part")
baseGround.Name = "BaseGround"
baseGround.Anchored = true
baseGround.CanCollide = true
baseGround.Size = Vector3.new(112, 2.0, 166)
baseGround.CFrame = CFrame.new(0, 0.0, 205)
baseGround.Color = Color3.fromRGB(34, 82, 42)
baseGround.Material = Enum.Material.Grass
baseGround.Parent = terrainFolder

-- Terrazas y Mesetas Elevadas Naturales
local terraces = {
    -- Meseta Oeste Baja (Tierras del Slime)
    { pos = Vector3.new(-34, 2.2, 155), size = Vector3.new(34, 4.4, 42), color = Color3.fromRGB(38, 92, 46) },
    -- Meseta Oeste Alta (Arboleda Sagrada)
    { pos = Vector3.new(-36, 4.8, 220), size = Vector3.new(32, 5.0, 48), color = Color3.fromRGB(32, 85, 42) },
    -- Meseta Este Baja (Nido de Setas)
    { pos = Vector3.new(34, 2.2, 160), size = Vector3.new(34, 4.4, 44), color = Color3.fromRGB(38, 92, 46) },
    -- Meseta Este Alta (Colina de Cristales)
    { pos = Vector3.new(36, 5.2, 225), size = Vector3.new(32, 5.4, 46), color = Color3.fromRGB(32, 85, 42) },
    -- Meseta del Santuario del Rey (Boss Arena)
    { pos = Vector3.new(0, 3.0, 252), size = Vector3.new(58, 4.0, 44), color = Color3.fromRGB(42, 96, 52) },
}

for i, t in ipairs(terraceData or terraces) do
    local plate = Instance.new("Part")
    plate.Name = "Terrace_" .. i
    plate.Anchored = true
    plate.CanCollide = true
    plate.Size = t.size
    plate.CFrame = CFrame.new(t.pos)
    plate.Color = t.color
    plate.Material = Enum.Material.Grass
    plate.TopSurface = Enum.SurfaceType.Smooth
    plate.Parent = terrainFolder

    -- Muros de contención de roca natural alrededor de la meseta
    local rim = Instance.new("Part")
    rim.Name = "TerraceRim_" .. i
    rim.Anchored = true
    rim.CanCollide = true
    rim.Size = Vector3.new(t.size.X + 1.2, t.size.Y * 0.9, t.size.Z + 1.2)
    rim.CFrame = plate.CFrame * CFrame.new(0, -0.4, 0)
    rim.Color = Color3.fromRGB(44, 48, 54)
    rim.Material = Enum.Material.Slate
    rim.Parent = terrainFolder
end

-- Rampas de piedra suave que unen las mesetas
local ramps = {
    { cf = CFrame.new(-18, 1.8, 145) * CFrame.Angles(0, math.rad(-90), math.rad(12)), size = Vector3.new(14, 1.4, 16) },
    { cf = CFrame.new(18, 1.8, 145) * CFrame.Angles(0, math.rad(90), math.rad(12)), size = Vector3.new(14, 1.4, 16) },
    { cf = CFrame.new(0, 2.0, 230) * CFrame.Angles(math.rad(-10), 0, 0), size = Vector3.new(20, 1.4, 18) },
    { cf = CFrame.new(-20, 3.8, 220) * CFrame.Angles(0, math.rad(-90), math.rad(12)), size = Vector3.new(16, 1.4, 16) },
    { cf = CFrame.new(20, 3.8, 220) * CFrame.Angles(0, math.rad(90), math.rad(12)), size = Vector3.new(16, 1.4, 16) },
}
for i, r in ipairs(ramps) do
    local rampPart = Instance.new("Part")
    rampPart.Name = "StoneRamp_" .. i
    rampPart.Anchored = true
    rampPart.CanCollide = true
    rampPart.Size = r.size
    rampPart.CFrame = r.cf
    rampPart.Color = Color3.fromRGB(64, 60, 56)
    rampPart.Material = Enum.Material.Cobblestone
    rampPart.Parent = terrainFolder
end

-- RÍO DE MANÁ RESPLANDECIENTE (Atraviesa el cañón a Z = 188)
local river = Instance.new("Part")
river.Name = "ManaRiver"
river.Anchored = true
river.CanCollide = false
river.Size = Vector3.new(104, 1.2, 16)
river.CFrame = CFrame.new(0, 0.4, 188)
river.Color = Color3.fromRGB(0, 210, 255)
river.Material = Enum.Material.Glass
river.Transparency = 0.3
river.Reflectance = 0.4
river.Parent = terrainFolder

local riverMist = Instance.new("ParticleEmitter")
riverMist.Color = ColorSequence.new(Color3.fromRGB(100, 230, 255))
riverMist.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 3.0) })
riverMist.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(0.5, 0.4), NumberSequenceKeypoint.new(1, 1) })
riverMist.Lifetime = NumberRange.new(2.0, 3.5)
riverMist.Speed = NumberRange.new(0.5, 1.2)
riverMist.Rate = 18
riverMist.Parent = river

-- Puente de Madera y Cuerda sobre el Río
local riverBridge = Instance.new("Model")
riverBridge.Name = "WoodRiverBridge"
riverBridge.Parent = terrainFolder

local brFloor = Instance.new("Part")
brFloor.Name = "BridgeDeck"
brFloor.Anchored = true
brFloor.CanCollide = true
brFloor.Size = Vector3.new(18, 1.4, 22)
brFloor.CFrame = CFrame.new(0, 2.2, 188)
brFloor.Color = Color3.fromRGB(88, 62, 42)
brFloor.Material = Enum.Material.WoodPlanks
brFloor.Parent = riverBridge

for _, sideX in ipairs({ -9.5, 9.5 }) do
    local post1 = Instance.new("Part")
    post1.Size = Vector3.new(1.2, 4.5, 1.2)
    post1.CFrame = CFrame.new(sideX, 3.8, 178)
    post1.Color = Color3.fromRGB(60, 42, 28)
    post1.Material = Enum.Material.Wood
    post1.Anchored = true
    post1.Parent = riverBridge

    local post2 = Instance.new("Part")
    post2.Size = Vector3.new(1.2, 4.5, 1.2)
    post2.CFrame = CFrame.new(sideX, 3.8, 198)
    post2.Color = Color3.fromRGB(60, 42, 28)
    post2.Material = Enum.Material.Wood
    post2.Anchored = true
    post2.Parent = riverBridge

    local rail = Instance.new("Part")
    rail.Size = Vector3.new(0.8, 1.2, 22)
    rail.CFrame = CFrame.new(sideX, 4.5, 188)
    rail.Color = Color3.fromRGB(72, 50, 34)
    rail.Material = Enum.Material.Wood
    rail.Anchored = true
    rail.Parent = riverBridge

    local lamp = Instance.new("Part")
    lamp.Shape = Enum.PartType.Ball
    lamp.Size = Vector3.new(1.2, 1.2, 1.2)
    lamp.CFrame = CFrame.new(sideX, 6.2, 188)
    lamp.Color = Color3.fromRGB(0, 255, 180)
    lamp.Material = Enum.Material.Neon
    lamp.Anchored = true
    lamp.CanCollide = false
    lamp.Parent = riverBridge

    local lLight = Instance.new("PointLight")
    lLight.Color = Color3.fromRGB(0, 255, 180)
    lLight.Brightness = 1.8
    lLight.Range = 14
    lLight.Parent = lamp
end

-- SENDERO EMPEDRADO CON RUNAS GRABADAS
local pathPositions = {
    CFrame.new(0, 1.1, 136),
    CFrame.new(-3, 1.1, 155) * CFrame.Angles(0, math.rad(-5), 0),
    CFrame.new(0, 1.1, 174),
    CFrame.new(0, 2.3, 188), -- en puente
    CFrame.new(2, 2.5, 206) * CFrame.Angles(0, math.rad(5), 0),
    CFrame.new(0, 4.1, 235),
    CFrame.new(0, 5.1, 260),
}
for i, cf in ipairs(pathPositions) do
    local pathSegment = Instance.new("Part")
    pathSegment.Name = "PathSegment_" .. i
    pathSegment.Anchored = true
    pathSegment.CanCollide = true
    pathSegment.Size = Vector3.new(16, 0.4, 20)
    pathSegment.CFrame = cf
    pathSegment.Color = Color3.fromRGB(56, 52, 48)
    pathSegment.Material = Enum.Material.Cobblestone
    pathSegment.Parent = terrainFolder
end

-- GRAN ANILLO RÚNICO EN LA ARENA DEL REY ALFA (Z = 252)
local arenaRing = Instance.new("Part")
arenaRing.Name = "BossArenaRunicCircle"
arenaRing.Shape = Enum.PartType.Cylinder
arenaRing.Size = Vector3.new(0.3, 34, 34)
arenaRing.CFrame = CFrame.new(0, 5.1, 252) * CFrame.Angles(0, 0, math.rad(90))
arenaRing.Color = Color3.fromRGB(24, 75, 45)
arenaRing.Material = Enum.Material.Marble
arenaRing.Anchored = true
arenaRing.CanCollide = true
arenaRing.Parent = terrainFolder

local innerRing = Instance.new("Part")
innerRing.Name = "InnerRunicRays"
innerRing.Shape = Enum.PartType.Cylinder
innerRing.Size = Vector3.new(0.35, 26, 26)
innerRing.CFrame = CFrame.new(0, 5.12, 252) * CFrame.Angles(0, 0, math.rad(90))
innerRing.Color = Color3.fromRGB(0, 230, 120)
innerRing.Material = Enum.Material.Neon
innerRing.Transparency = 0.45
innerRing.Anchored = true
innerRing.CanCollide = false
innerRing.Parent = terrainFolder

-- 4 Obeliscos Guardianes en la Arena del Boss
for idx, angle in ipairs({ 45, 135, 225, 315 }) do
    local rad = math.rad(angle)
    local ox = math.cos(rad) * 19
    local oz = math.sin(rad) * 19
    local obelisk = Instance.new("Part")
    obelisk.Name = "BossObelisk_" .. idx
    obelisk.Size = Vector3.new(3.5, 16, 3.5)
    obelisk.CFrame = CFrame.new(ox, 13, 252 + oz) * CFrame.Angles(0, rad, 0)
    obelisk.Color = Color3.fromRGB(48, 54, 72)
    obelisk.Material = Enum.Material.Slate
    obelisk.Anchored = true
    obelisk.CanCollide = true
    obelisk.Parent = terrainFolder

    local gem = Instance.new("Part")
    gem.Shape = Enum.PartType.Ball
    gem.Size = Vector3.new(2.4, 2.4, 2.4)
    gem.CFrame = obelisk.CFrame * CFrame.new(0, 9.5, 0)
    gem.Color = Color3.fromRGB(0, 255, 150)
    gem.Material = Enum.Material.Neon
    gem.Anchored = true
    gem.CanCollide = false
    gem.Parent = terrainFolder

    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(0, 255, 150)
    pl.Brightness = 2.2
    pl.Range = 16
    pl.Parent = gem
end

--------------------------------------------------------------------------------
-- 3. VEGETACIÓN EXHUBERANTE, RUINAS Y CRISTALES GIGANTES
--------------------------------------------------------------------------------
local decoFolder = Instance.new("Folder")
decoFolder.Name = "DecorationsAndFlora"
decoFolder.Parent = zone

-- Árboles Arcanos de Triple Copa
local treeLocations = {
    Vector3.new(-28, 2.2, 142),
    Vector3.new(28, 2.2, 148),
    Vector3.new(-42, 4.4, 168),
    Vector3.new(42, 4.4, 172),
    Vector3.new(-24, 2.2, 178),
    Vector3.new(26, 2.2, 180),
    Vector3.new(-40, 5.0, 210),
    Vector3.new(42, 5.2, 215),
    Vector3.new(-32, 5.0, 245),
    Vector3.new(34, 5.2, 248),
    Vector3.new(-26, 5.0, 270),
    Vector3.new(26, 5.2, 272),
}

for i, pos in ipairs(treeLocations) do
    local tree = Instance.new("Model")
    tree.Name = "StylizedTree_" .. i
    tree.Parent = decoFolder

    local trunk = Instance.new("Part")
    trunk.Name = "Trunk"
    trunk.Size = Vector3.new(3.6, 20, 3.6)
    trunk.CFrame = CFrame.new(pos + Vector3.new(0, 10, 0))
    trunk.Color = Color3.fromRGB(52, 38, 28)
    trunk.Material = Enum.Material.Wood
    trunk.Anchored = true
    trunk.CanCollide = true
    trunk.Parent = tree

    -- 3 Capas de Copa Esférica Estilizada
    local foliageData = {
        { size = Vector3.new(18, 12, 18), offY = 18, color = Color3.fromRGB(22, 125, 54) },
        { size = Vector3.new(14, 10, 14), offY = 24, color = Color3.fromRGB(30, 150, 68) },
        { size = Vector3.new(9, 8, 9), offY = 28, color = Color3.fromRGB(42, 175, 82) },
    }
    for fIdx, f in ipairs(foliageData) do
        local fPart = Instance.new("Part")
        fPart.Shape = Enum.PartType.Ball
        fPart.Size = f.size
        fPart.CFrame = CFrame.new(pos + Vector3.new(0, f.offY, 0))
        fPart.Color = f.color
        fPart.Material = Enum.Material.Grass
        fPart.Anchored = true
        fPart.CanCollide = true
        fPart.Parent = tree
    end

    -- Orbe de Maná colgante
    local fruit = Instance.new("Part")
    fruit.Shape = Enum.PartType.Ball
    fruit.Size = Vector3.new(2.2, 2.2, 2.2)
    fruit.CFrame = CFrame.new(pos + Vector3.new(0, 13.5, 0))
    fruit.Color = Color3.fromRGB(0, 255, 170)
    fruit.Material = Enum.Material.Neon
    fruit.Anchored = true
    fruit.CanCollide = false
    fruit.Parent = tree
end

-- Hongos Gigantes Bioluminiscentes
local mushroomLocations = {
    { pos = Vector3.new(-18, 2.2, 158), col = Color3.fromRGB(0, 230, 255) },
    { pos = Vector3.new(20, 2.2, 162), col = Color3.fromRGB(180, 70, 255) },
    { pos = Vector3.new(-22, 2.2, 195), col = Color3.fromRGB(0, 255, 170) },
    { pos = Vector3.new(22, 2.2, 200), col = Color3.fromRGB(0, 230, 255) },
    { pos = Vector3.new(-38, 5.0, 235), col = Color3.fromRGB(255, 120, 220) },
    { pos = Vector3.new(38, 5.2, 235), col = Color3.fromRGB(0, 255, 170) },
}
for i, m in ipairs(mushroomLocations) do
    local mush = Instance.new("Model")
    mush.Name = "GiantMushroom_" .. i
    mush.Parent = decoFolder

    local stem = Instance.new("Part")
    stem.Size = Vector3.new(1.8, 6.5, 1.8)
    stem.CFrame = CFrame.new(m.pos + Vector3.new(0, 3.25, 0))
    stem.Color = Color3.fromRGB(235, 240, 248)
    stem.Material = Enum.Material.SmoothPlastic
    stem.Anchored = true
    stem.CanCollide = true
    stem.Parent = mush

    local cap = Instance.new("Part")
    cap.Shape = Enum.PartType.Cylinder
    cap.Size = Vector3.new(1.4, 7.5, 7.5)
    cap.CFrame = stem.CFrame * CFrame.new(0, 3.8, 0) * CFrame.Angles(0, 0, math.rad(90))
    cap.Color = m.col
    cap.Material = Enum.Material.Neon
    cap.Anchored = true
    cap.CanCollide = false
    cap.Parent = mush

    local mLight = Instance.new("PointLight")
    mLight.Color = m.col
    mLight.Brightness = 2.4
    mLight.Range = 18
    mLight.Parent = cap
end

-- Espigas de Cristales Mágicos Emergiendo del Suelo
local crystalPillars = {
    { pos = Vector3.new(-48, 12, 160), rot = Vector3.new(0.2, 0.4, 0.3), col = Color3.fromRGB(0, 225, 255) },
    { pos = Vector3.new(48, 12, 165), rot = Vector3.new(-0.2, -0.4, -0.3), col = Color3.fromRGB(0, 255, 160) },
    { pos = Vector3.new(-48, 14, 230), rot = Vector3.new(0.3, 0.2, 0.4), col = Color3.fromRGB(160, 80, 255) },
    { pos = Vector3.new(48, 14, 235), rot = Vector3.new(-0.3, -0.2, -0.4), col = Color3.fromRGB(0, 225, 255) },
}
for i, c in ipairs(crystalPillars) do
    local cry = Instance.new("Part")
    cry.Name = "GiantCrystalPillar_" .. i
    cry.Size = Vector3.new(5.0, 22, 5.0)
    cry.CFrame = CFrame.new(c.pos) * CFrame.Angles(c.rot.X, c.rot.Y, c.rot.Z)
    cry.Color = c.col
    cry.Material = Enum.Material.Glass
    cry.Reflectance = 0.5
    cry.Transparency = 0.25
    cry.Anchored = true
    cry.CanCollide = true
    cry.Parent = decoFolder

    local glow = Instance.new("PointLight")
    glow.Color = c.col
    glow.Brightness = 2.5
    glow.Range = 22
    glow.Parent = cry
end

-- 2 Nodos de Madera Arcana Sagrada
local woodNodePos = { Vector3.new(-24, 2.2, 165), Vector3.new(24, 5.0, 215) }
for i, wPos in ipairs(woodNodePos) do
    local nodeModel = Instance.new("Model")
    nodeModel.Name = "ArcaneWoodNode_" .. i
    nodeModel.Parent = decoFolder

    local stump = Instance.new("Part")
    stump.Name = "NodeStump"
    stump.Shape = Enum.PartType.Cylinder
    stump.Size = Vector3.new(4.2, 5.5, 5.5)
    stump.CFrame = CFrame.new(wPos + Vector3.new(0, 2.1, 0)) * CFrame.Angles(0, 0, math.rad(90))
    stump.Color = Color3.fromRGB(68, 48, 34)
    stump.Material = Enum.Material.Wood
    stump.Anchored = true
    stump.CanCollide = true
    stump.Parent = nodeModel

    local sprout = Instance.new("Part")
    sprout.Size = Vector3.new(2.2, 4.0, 2.2)
    sprout.CFrame = stump.CFrame * CFrame.new(2.4, 0, 0) * CFrame.Angles(0.2, 0.4, 0)
    sprout.Color = Color3.fromRGB(0, 255, 140)
    sprout.Material = Enum.Material.Neon
    sprout.Anchored = true
    sprout.CanCollide = false
    sprout.Parent = nodeModel

    local prompt = Instance.new("ProximityPrompt")
    prompt.ObjectText = "Tronco Sagrado"
    prompt.ActionText = "Canalizar Madera Arcana (+3)"
    prompt.HoldDuration = 1.0
    prompt.MaxActivationDistance = 14
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.Parent = stump
end

--------------------------------------------------------------------------------
-- 4. BARRERA MÁGICA SELLADA HACIA LA ZONA 2 (Z = 288)
--------------------------------------------------------------------------------
local barrierModel = Instance.new("Model")
barrierModel.Name = "BarrierToZone2"
barrierModel.Parent = zone

local bLeftPillar = Instance.new("Part")
bLeftPillar.Size = Vector3.new(6, 28, 6)
bLeftPillar.CFrame = CFrame.new(-16, 14, 288)
bLeftPillar.Color = Color3.fromRGB(38, 46, 68)
bLeftPillar.Material = Enum.Material.Slate
bLeftPillar.Anchored = true
bLeftPillar.CanCollide = true
bLeftPillar.Parent = barrierModel

local bRightPillar = Instance.new("Part")
bRightPillar.Size = Vector3.new(6, 28, 6)
bRightPillar.CFrame = CFrame.new(16, 14, 288)
bRightPillar.Color = Color3.fromRGB(38, 46, 68)
bRightPillar.Material = Enum.Material.Slate
bRightPillar.Anchored = true
bRightPillar.CanCollide = true
bRightPillar.Parent = barrierModel

local bArch = Instance.new("Part")
bArch.Size = Vector3.new(38, 5, 6)
bArch.CFrame = CFrame.new(0, 28, 288)
bArch.Color = Color3.fromRGB(28, 34, 52)
bArch.Material = Enum.Material.Cobblestone
bArch.Anchored = true
bArch.CanCollide = true
bArch.Parent = barrierModel

local bForcefield = Instance.new("Part")
bForcefield.Name = "ForcefieldWall"
bForcefield.Size = Vector3.new(28, 26, 1.6)
bForcefield.CFrame = CFrame.new(0, 13, 288)
bForcefield.Color = Color3.fromRGB(0, 220, 255)
bForcefield.Material = Enum.Material.Neon
bForcefield.Transparency = 0.55
bForcefield.Anchored = true
bForcefield.CanCollide = true
bForcefield.Parent = barrierModel

-- Isla preview de Zona 2 al fondo
local z2Island = Instance.new("Part")
z2Island.Name = "Zone2_IslandPreview"
z2Island.Size = Vector3.new(90, 3.0, 70)
z2Island.CFrame = CFrame.new(0, 5.0, 335)
z2Island.Color = Color3.fromRGB(42, 48, 76)
z2Island.Material = Enum.Material.Cobblestone
z2Island.Anchored = true
z2Island.CanCollide = true
z2Island.Parent = zone

for _, cPos in ipairs({ Vector3.new(-22, 6.5, 330), Vector3.new(22, 6.5, 335), Vector3.new(0, 6.5, 350) }) do
    local crystal = Instance.new("Part")
    crystal.Size = Vector3.new(5, 20, 5)
    crystal.CFrame = CFrame.new(cPos + Vector3.new(0, 10, 0)) * CFrame.Angles(0.2, 0.5, 0.1)
    crystal.Color = Color3.fromRGB(0, 230, 255)
    crystal.Material = Enum.Material.Glass
    crystal.Anchored = true
    crystal.Parent = z2Island
end

--------------------------------------------------------------------------------
-- 5. SLIMES ESTILIZADOS EN 3D CON DOBLE CAPA JELLY, ROSTRO CHIBI Y NÚCLEO
--------------------------------------------------------------------------------
local mobsFolder = Instance.new("Folder")
mobsFolder.Name = "ForestMobs"
mobsFolder.Parent = zone

local function createSlimeModel(index: number, spawnPos: Vector3, sType: string): Model
    local isBoss = (sType == "Boss")
    local isRunic = (sType == "Runic")

    local baseW = if isBoss then 7.0 elseif isRunic then 4.8 else 3.8
    local baseH = if isBoss then 6.0 elseif isRunic then 4.0 else 3.2

    local jellyCol = if isBoss then Color3.fromRGB(0, 245, 145)
        elseif isRunic then Color3.fromRGB(0, 225, 255)
        else Color3.fromRGB(40, 235, 115)

    local coreCol = if isBoss then Color3.fromRGB(255, 225, 40)
        elseif isRunic then Color3.fromRGB(120, 245, 255)
        else Color3.fromRGB(130, 255, 185)

    local model = Instance.new("Model")
    model.Name = "Slime_" .. sType .. "_" .. index

    -- Sombra dinámica en el suelo
    local shadow = Instance.new("Part")
    shadow.Name = "Shadow"
    shadow.Shape = Enum.PartType.Cylinder
    shadow.Size = Vector3.new(0.08, baseW * 1.1, baseW * 1.1)
    shadow.CFrame = CFrame.new(spawnPos.X, spawnPos.Y + 0.05, spawnPos.Z) * CFrame.Angles(0, 0, math.rad(90))
    shadow.Color = Color3.fromRGB(14, 20, 16)
    shadow.Material = Enum.Material.SmoothPlastic
    shadow.Transparency = 0.55
    shadow.Anchored = true
    shadow.CanCollide = false
    shadow.Parent = model

    -- Membrana de gelatina translúcida (Gota orgánica estilizada)
    local body = Instance.new("Part")
    body.Name = "SlimeBody"
    body.Shape = Enum.PartType.Ball
    body.Size = Vector3.new(baseW, baseH, baseW)
    body.CFrame = CFrame.new(spawnPos + Vector3.new(0, baseH / 2 + 0.3, 0))
    body.Color = jellyCol
    body.Material = Enum.Material.Glass
    body.Transparency = 0.28
    body.Reflectance = 0.18
    body.Anchored = true
    body.CanCollide = false
    body.Parent = model
    model.PrimaryPart = body

    -- Núcleo interno de maná flotante
    local core = Instance.new("Part")
    core.Name = "Manacore"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(baseW * 0.45, baseH * 0.45, baseW * 0.45)
    core.CFrame = body.CFrame
    core.Color = coreCol
    core.Material = Enum.Material.Neon
    core.Anchored = false
    core.CanCollide = false
    core.Parent = model

    local wCore = Instance.new("WeldConstraint")
    wCore.Part0 = body
    wCore.Part1 = core
    wCore.Parent = body

    local coreLight = Instance.new("PointLight")
    coreLight.Color = coreCol
    coreLight.Brightness = if isBoss then 2.8 else 1.6
    coreLight.Range = if isBoss then 18 else 11
    coreLight.Parent = core

    -- Rostro Chibi Expresivo (Ojos grandes + destello + mejillas sonrosadas)
    local eyeOffset = baseW * 0.22
    local eyeZ = -(baseW * 0.46)
    for _, eyeX in ipairs({ -eyeOffset, eyeOffset }) do
        local eye = Instance.new("Part")
        eye.Shape = Enum.PartType.Ball
        eye.Size = Vector3.new(baseW * 0.18, baseW * 0.22, baseW * 0.18)
        eye.CFrame = body.CFrame * CFrame.new(eyeX, baseH * 0.08, eyeZ)
        eye.Color = Color3.fromRGB(15, 18, 24)
        eye.Material = Enum.Material.SmoothPlastic
        eye.Anchored = false
        eye.CanCollide = false
        eye.Parent = model

        local wEye = Instance.new("WeldConstraint")
        wEye.Part0 = body
        wEye.Part1 = eye
        wEye.Parent = body

        -- Destello de pupila blanca
        local pup = Instance.new("Part")
        pup.Shape = Enum.PartType.Ball
        pup.Size = Vector3.new(baseW * 0.08, baseW * 0.08, baseW * 0.08)
        pup.CFrame = eye.CFrame * CFrame.new(0.04, 0.05, -eye.Size.Z * 0.38)
        pup.Color = Color3.fromRGB(255, 255, 255)
        pup.Material = Enum.Material.Neon
        pup.Anchored = false
        pup.CanCollide = false
        pup.Parent = model

        local wPup = Instance.new("WeldConstraint")
        wPup.Part0 = body
        wPup.Part1 = pup
        wPup.Parent = body

        -- Mejilla sonrosada
        local cheek = Instance.new("Part")
        cheek.Shape = Enum.PartType.Ball
        cheek.Size = Vector3.new(baseW * 0.12, baseW * 0.08, baseW * 0.1)
        cheek.CFrame = body.CFrame * CFrame.new(eyeX * 1.35, -(baseH * 0.12), eyeZ + 0.15)
        cheek.Color = Color3.fromRGB(255, 140, 180)
        cheek.Material = Enum.Material.Neon
        cheek.Transparency = 0.35
        cheek.Anchored = false
        cheek.CanCollide = false
        cheek.Parent = model

        local wCheek = Instance.new("WeldConstraint")
        wCheek.Part0 = body
        wCheek.Part1 = cheek
        wCheek.Parent = body
    end

    -- Corona del Rey Alfa o Runa Flotante
    if isBoss then
        local crown = Instance.new("Part")
        crown.Name = "BossCrown"
        crown.Size = Vector3.new(3.2, 0.8, 3.2)
        crown.CFrame = body.CFrame * CFrame.new(0, baseH * 0.58, 0)
        crown.Color = Color3.fromRGB(255, 215, 0)
        crown.Material = Enum.Material.Metal
        crown.Anchored = false
        crown.CanCollide = false
        crown.Parent = model

        local wCrown = Instance.new("WeldConstraint")
        wCrown.Part0 = body
        wCrown.Part1 = crown
        wCrown.Parent = body

        for p = 1, 5 do
            local ang = math.rad((p - 1) * 72)
            local spike = Instance.new("Part")
            spike.Size = Vector3.new(0.5, 1.3, 0.5)
            spike.CFrame = crown.CFrame * CFrame.Angles(0, ang, 0) * CFrame.new(1.3, 0.9, 0)
            spike.Color = Color3.fromRGB(255, 215, 0)
            spike.Material = Enum.Material.Metal
            spike.Anchored = false
            spike.CanCollide = false
            spike.Parent = model

            local wSpk = Instance.new("WeldConstraint")
            wSpk.Part0 = body
            wSpk.Part1 = spike
            wSpk.Parent = body
        end

        local ruby = Instance.new("Part")
        ruby.Shape = Enum.PartType.Ball
        ruby.Size = Vector3.new(0.9, 0.9, 0.9)
        ruby.CFrame = crown.CFrame * CFrame.new(0, 0.5, -1.5)
        ruby.Color = Color3.fromRGB(255, 30, 60)
        ruby.Material = Enum.Material.Neon
        ruby.Anchored = false
        ruby.CanCollide = false
        ruby.Parent = model

        local wRuby = Instance.new("WeldConstraint")
        wRuby.Part0 = body
        wRuby.Part1 = ruby
        wRuby.Parent = body
    else
        local rune = Instance.new("Part")
        rune.Shape = Enum.PartType.Ball
        rune.Size = Vector3.new(1.2, 1.2, 1.2)
        rune.CFrame = body.CFrame * CFrame.new(0, baseH * 0.62, 0)
        rune.Color = if isRunic then Color3.fromRGB(0, 240, 255) else Color3.fromRGB(120, 255, 180)
        rune.Material = Enum.Material.Neon
        rune.Anchored = false
        rune.CanCollide = false
        rune.Parent = model

        local wRune = Instance.new("WeldConstraint")
        wRune.Part0 = body
        wRune.Part1 = rune
        wRune.Parent = body
    end

    -- Billboard de Vida
    local bbg = Instance.new("BillboardGui")
    bbg.Name = "HealthGui"
    bbg.Size = if isBoss then UDim2.new(0, 220, 0, 60) else UDim2.new(0, 150, 0, 50)
    bbg.StudsOffset = Vector3.new(0, baseH + 1.6, 0)
    bbg.MaxDistance = 60
    bbg.Adornee = body
    bbg.Parent = model

    local tag = Instance.new("TextLabel")
    tag.Size = UDim2.new(1, 0, 0, 16)
    tag.BackgroundTransparency = 1
    tag.Font = Enum.Font.GothamBlack
    tag.TextSize = if isBoss then 14 else 11
    tag.TextColor3 = if isBoss then Color3.fromRGB(255, 215, 50) elseif isRunic then Color3.fromRGB(120, 240, 255) else Color3.fromRGB(160, 255, 190)
    tag.Text = if isBoss then "👑 SLIME REY ALFA [JEFE]" elseif isRunic then "SLIME RUNICO (Niv. 2)" else "SLIME MENOR (Niv. 1)"
    tag.Parent = bbg

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, 0, 0, if isBoss then 14 else 11)
    barBg.Position = UDim2.new(0, 0, 0, 18)
    barBg.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
    barBg.BorderSizePixel = 0
    barBg.Parent = bbg

    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(0, 6)
    c1.Parent = barBg

    local barFill = Instance.new("Frame")
    barFill.Name = "HpFill"
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = if isBoss then Color3.fromRGB(255, 180, 20) else Color3.fromRGB(0, 230, 110)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg

    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 6)
    c2.Parent = barFill

    local hpTxt = Instance.new("TextLabel")
    hpTxt.Name = "HpText"
    hpTxt.Size = UDim2.new(1, 0, 0, 12)
    hpTxt.Position = UDim2.new(0, 0, 0, if isBoss then 36 else 32)
    hpTxt.BackgroundTransparency = 1
    hpTxt.Font = Enum.Font.GothamBold
    hpTxt.TextSize = 10
    hpTxt.TextColor3 = Color3.fromRGB(220, 240, 230)
    local maxHp = if isBoss then 150 elseif isRunic then 60 else 30
    hpTxt.Text = string.format("%d / %d HP", maxHp, maxHp)
    hpTxt.Parent = bbg

    local cd = Instance.new("ClickDetector")
    cd.MaxActivationDistance = 28
    cd.Parent = body

    model.Parent = mobsFolder
    return model
end

-- Posiciones estratégicas de spawn para los Slimes
local spawnPositions = {
    { pos = Vector3.new(-16, 2.2, 148), type = "Minor" },
    { pos = Vector3.new(16, 2.2, 152), type = "Minor" },
    { pos = Vector3.new(-28, 2.2, 168), type = "Minor" },
    { pos = Vector3.new(28, 2.2, 170), type = "Minor" },
    { pos = Vector3.new(-18, 2.2, 210), type = "Runic" },
    { pos = Vector3.new(18, 2.2, 215), type = "Runic" },
    { pos = Vector3.new(-26, 4.4, 232), type = "Runic" },
    { pos = Vector3.new(26, 4.4, 234), type = "Runic" },
    { pos = Vector3.new(0, 3.2, 252), type = "Boss" }, -- Slime Rey Alfa en la Arena
}

for i, sp in ipairs(spawnPositions) do
    createSlimeModel(i, sp.pos, sp.type)
end

return string.format("Zone1 created: %d mobs, terrain, river, bridge, trees, crystals, and barrier built.", #spawnPositions)
