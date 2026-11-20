--!strict
-- build_spectacular_lobby.luau
-- Generates the Spectacular Fantasy Citadel Lobby in Roblox Studio
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

print("[LobbyBuilder] Iniciando construcción de la Gran Lobby Espectacular...")

-- 1. Limpieza de elementos previos
local oldLobby = Workspace:FindFirstChild("Lobby")
if oldLobby then oldLobby:Destroy() end

local oldStations = Workspace:FindFirstChild("PhysicalLobbyStations")
if oldStations then oldStations:Destroy() end

local oldSpots = Workspace:FindFirstChild("TrainingSpots")
if oldSpots then oldSpots:Destroy() end

-- Eliminar SpawnLocation por defecto
local oldSpawn = Workspace:FindFirstChild("SpawnLocation")
if oldSpawn then oldSpawn:Destroy() end

local oldLobbySpawn = Workspace:FindFirstChild("LobbySpawnLocation")
if oldLobbySpawn then oldLobbySpawn:Destroy() end

local lobby = Instance.new("Folder")
lobby.Name = "Lobby"
lobby.Parent = Workspace

--------------------------------------------------------------------------------
-- CONFIGURACIÓN DE ILUMINACIÓN Y ATMÓSFERA
--------------------------------------------------------------------------------
Lighting.ClockTime = 14.5
Lighting.Brightness = 2.2
Lighting.Ambient = Color3.fromRGB(120, 125, 150)
Lighting.OutdoorAmbient = Color3.fromRGB(140, 145, 170)
Lighting.GlobalShadows = true

local cc = Lighting:FindFirstChild("ArcaneColorCorrection") or Instance.new("ColorCorrectionEffect")
cc.Name = "ArcaneColorCorrection"
cc.TintColor = Color3.fromRGB(255, 252, 246)
cc.Brightness = 0.02
cc.Contrast = 0.08
cc.Saturation = 0.15
cc.Enabled = true
cc.Parent = Lighting

local bloom = Lighting:FindFirstChild("ArcaneBloom") or Instance.new("BloomEffect")
bloom.Name = "ArcaneBloom"
bloom.Intensity = 0.4
bloom.Size = 18
bloom.Threshold = 0.92
bloom.Enabled = true
bloom.Parent = Lighting

--------------------------------------------------------------------------------
-- HELPER: CREACIÓN DE PARTES BÁSICAS
--------------------------------------------------------------------------------
local function makePart(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.CanCollide = true
	p.CastShadow = true
	if shape then p.Shape = shape end
	p.Parent = parent
	return p
end

--------------------------------------------------------------------------------
-- 1. TOPOGRAFÍA ESCALONADA (CENTRO BAJO + TERRAZAS OESTE Y ESTE ELEVADAS)
--------------------------------------------------------------------------------
local terrainFolder = Instance.new("Folder")
terrainFolder.Name = "TerrainAndPlazas"
terrainFolder.Parent = lobby

-- A) Plaza Central (Y = 1.0, X: -26 a +26, Z: -45 a +85)
local centerFloor = makePart(terrainFolder, "CenterPlaza_Floor", Vector3.new(52, 2.4, 132), CFrame.new(0, 0, 20), Color3.fromRGB(38, 44, 58), Enum.Material.Slate)

-- Camino Real de Mármol Central con Adoquín
local royalWalk = makePart(terrainFolder, "RoyalWalkway", Vector3.new(22, 2.5, 130), CFrame.new(0, 0.06, 20), Color3.fromRGB(48, 56, 74), Enum.Material.Marble)

-- Líneas de canalización rúnica en el piso central (Cyan Neon)
for _, xOff in ipairs({ -11, 11 }) do
	local line = makePart(terrainFolder, "RunicEnergyConduit", Vector3.new(0.6, 2.52, 130), CFrame.new(xOff, 0.08, 20), Color3.fromRGB(0, 240, 255), Enum.Material.Neon)
	line.CanCollide = false
end

-- B) Terraza Oeste (Distrito de Artesanos) (Y = 4.2, X: -48 a -86, Z: -45 a +85)
local westTerrace = makePart(terrainFolder, "WestTerrace_Artisans", Vector3.new(38, 5.6, 132), CFrame.new(-45, 1.6, 20), Color3.fromRGB(34, 40, 52), Enum.Material.Cobblestone)
local westTile = makePart(terrainFolder, "WestTerrace_Tile", Vector3.new(36, 0.4, 130), westTerrace.CFrame * CFrame.new(0, 2.9, 0), Color3.fromRGB(42, 38, 48), Enum.Material.WoodPlanks)

-- C) Terraza Este (Paseo de la Ascensión - 7 Santuarios) (Y = 4.2, X: 48 a 86, Z: -45 a +85)
local eastTerrace = makePart(terrainFolder, "EastTerrace_Sanctums", Vector3.new(38, 5.6, 132), CFrame.new(45, 1.6, 20), Color3.fromRGB(34, 40, 52), Enum.Material.Cobblestone)
local eastTile = makePart(terrainFolder, "EastTerrace_Tile", Vector3.new(36, 0.4, 130), eastTerrace.CFrame * CFrame.new(0, 2.9, 0), Color3.fromRGB(30, 36, 50), Enum.Material.Marble)

-- D) Escaleras Monumentales de Piedra con bordes dorados conectando el centro con las terrazas
for _, side in ipairs({ -1, 1 }) do
	local stairX = side * 26
	for step = 1, 8 do
		local stepY = 1.0 + (step * 0.4)
		local stepZ = 20
		local stepPart = makePart(terrainFolder, "GrandStep_" .. (side < 0 and "West_" or "East_") .. step, Vector3.new(2.4, 0.42, 110), CFrame.new(stairX + (side * (step - 1) * 2.2), stepY, stepZ), Color3.fromRGB(56, 62, 78), Enum.Material.Slate)
		
		-- Moldura dorada en el escalón
		local trim = makePart(terrainFolder, "StepTrim", Vector3.new(0.3, 0.44, 110), stepPart.CFrame * CFrame.new(side * 1.15, 0.02, 0), Color3.fromRGB(220, 180, 50), Enum.Material.Metal)
		trim.CanCollide = false
	end
end

--------------------------------------------------------------------------------
-- 2. FUENTE MONUMENTAL DE MANÁ DE LA ETERNIDAD (PLAZA CENTRAL, Z = 20)
--------------------------------------------------------------------------------
local fountainModel = Instance.new("Model")
fountainModel.Name = "GrandManaFountain"
fountainModel.Parent = lobby

-- Base octagonal de piedra
local fBase = makePart(fountainModel, "FountainBase", Vector3.new(20, 1.2, 20), CFrame.new(0, 1.8, 20), Color3.fromRGB(50, 58, 76), Enum.Material.Marble, Enum.PartType.Cylinder)
fBase.CFrame = fBase.CFrame * CFrame.Angles(0, 0, math.rad(90))

-- Borde exterior de mármol
local fRim = makePart(fountainModel, "FountainRim", Vector3.new(22, 1.6, 22), CFrame.new(0, 2.0, 20), Color3.fromRGB(65, 75, 95), Enum.Material.Slate, Enum.PartType.Cylinder)
fRim.CFrame = fRim.CFrame * CFrame.Angles(0, 0, math.rad(90))

-- Agua de Maná Resplandeciente (Piscina)
local fWater = makePart(fountainModel, "ManaWater", Vector3.new(19.2, 0.8, 19.2), CFrame.new(0, 2.3, 20), Color3.fromRGB(0, 210, 255), Enum.Material.Glass, Enum.PartType.Cylinder)
fWater.CFrame = fWater.CFrame * CFrame.Angles(0, 0, math.rad(90))
fWater.Transparency = 0.35

-- Monolito Central de Cristal Arcano
local crystalCore = makePart(fountainModel, "ManaMonolith", Vector3.new(3.2, 9.0, 3.2), CFrame.new(0, 6.5, 20) * CFrame.Angles(math.rad(6), math.rad(45), math.rad(6)), Color3.fromRGB(0, 240, 255), Enum.Material.Neon)
local crLight = Instance.new("PointLight")
crLight.Color = Color3.fromRGB(0, 230, 255)
crLight.Brightness = 3.5
crLight.Range = 24
crLight.Parent = crystalCore

-- Partículas de agua y energía de maná
local waterSparks = Instance.new("ParticleEmitter")
waterSparks.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 245, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255)),
})
waterSparks.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.4),
	NumberSequenceKeypoint.new(0.5, 0.8),
	NumberSequenceKeypoint.new(1, 0.1),
})
waterSparks.Lifetime = NumberRange.new(1.2, 2.2)
waterSparks.Rate = 26
waterSparks.Speed = NumberRange.new(4, 9)
waterSparks.SpreadAngle = Vector2.new(45, 45)
waterSparks.Acceleration = Vector3.new(0, -14, 0)
waterSparks.Parent = crystalCore

-- Bancos de descanso de mármol tallado alrededor de la fuente
for i = 1, 4 do
	local ang = math.rad(i * 90)
	local bDist = 14
	local bPos = Vector3.new(math.cos(ang) * bDist, 1.9, 20 + math.sin(ang) * bDist)
	local bench = makePart(fountainModel, "MarbleBench_" .. i, Vector3.new(4.8, 1.2, 1.6), CFrame.new(bPos, Vector3.new(0, 1.9, 20)), Color3.fromRGB(60, 68, 86), Enum.Material.Marble)
end

--------------------------------------------------------------------------------
-- 3. PAVILIÓN DE SPAWN SEGURO (SUR, Z = -30, X = 0)
--------------------------------------------------------------------------------
local spawnPavilion = Instance.new("Model")
spawnPavilion.Name = "SpawnPavilion"
spawnPavilion.Parent = lobby

-- Podio elevado octagonal
local spBase = makePart(spawnPavilion, "SpawnBase", Vector3.new(18, 1.8, 18), CFrame.new(0, 1.4, -30), Color3.fromRGB(48, 54, 72), Enum.Material.Marble, Enum.PartType.Cylinder)
spBase.CFrame = spBase.CFrame * CFrame.Angles(0, 0, math.rad(90))

-- Sello de la Estrella de Invocación
local spStar = makePart(spawnPavilion, "SpawnStar", Vector3.new(14, 0.2, 14), CFrame.new(0, 2.32, -30), Color3.fromRGB(0, 255, 230), Enum.Material.Neon, Enum.PartType.Cylinder)
spStar.CFrame = spStar.CFrame * CFrame.Angles(0, 0, math.rad(90))
spStar.Transparency = 0.2

-- SpawnLocation Oficial Único y Blindado
local spawnLoc = Instance.new("SpawnLocation")
spawnLoc.Name = "LobbySpawnLocation"
spawnLoc.Size = Vector3.new(12, 1.0, 12)
spawnLoc.CFrame = CFrame.new(0, 2.4, -30)
spawnLoc.Anchored = true
spawnLoc.CanCollide = true
spawnLoc.Duration = 0
spawnLoc.Transparency = 1
spawnLoc.Enabled = true
spawnLoc.Parent = spawnPavilion

-- 4 Pilares de Invocación alrededor del Spawn
for i = 1, 4 do
	local ang = math.rad((i - 1) * 90 + 45)
	local pPos = Vector3.new(math.cos(ang) * 9.5, 5.0, -30 + math.sin(ang) * 9.5)
	local pillar = makePart(spawnPavilion, "SpawnPillar_" .. i, Vector3.new(1.8, 7.2, 1.8), CFrame.new(pPos), Color3.fromRGB(60, 68, 88), Enum.Material.Slate)
	
	-- Gema flotante de luz en cada pilar
	local gem = makePart(spawnPavilion, "PillarGem", Vector3.new(1.0, 1.0, 1.0), CFrame.new(pPos + Vector3.new(0, 4.2, 0)) * CFrame.Angles(math.rad(45), math.rad(45), 0), Color3.fromRGB(0, 255, 230), Enum.Material.Neon)
	gem.CanCollide = false
	local pLight = Instance.new("PointLight")
	pLight.Color = Color3.fromRGB(0, 255, 230)
	pLight.Brightness = 2.0
	pLight.Range = 14
	pLight.Parent = gem
end

--------------------------------------------------------------------------------
-- 4. LAS 4 ESTACIONES INTERACTIVAS EN LA TERRAZA OESTE (3D ARQUITECTURAL)
--------------------------------------------------------------------------------
local stationsFolder = Instance.new("Folder")
stationsFolder.Name = "PhysicalLobbyStations"
stationsFolder.Parent = lobby

local WEST_X = -58

-- Helper para cartel flotante de alta definición
local function createStationSign(parent: Model, cf: CFrame, mainTitle: string, subtitle: string, tagColor: Color3)
	local board = makePart(parent, "SignBoard", Vector3.new(5.0, 2.2, 0.4), cf, Color3.fromRGB(28, 22, 18), Enum.Material.WoodPlanks)
	local frame = makePart(parent, "SignFrame", Vector3.new(5.2, 2.4, 0.45), cf, Color3.fromRGB(20, 20, 24), Enum.Material.Metal)
	frame.CanCollide = false
	
	local bbg = Instance.new("BillboardGui")
	bbg.Name = "StationSignGui"
	bbg.Size = UDim2.new(0, 280, 0, 100)
	bbg.StudsOffset = Vector3.new(0, 0.4, 0)
	bbg.MaxDistance = 12
	bbg.AlwaysOnTop = false
	bbg.LightInfluence = 0
	bbg.Adornee = board
	bbg.Enabled = false
	bbg.Parent = board

	local frameGui = Instance.new("Frame")
	frameGui.Size = UDim2.new(1, 0, 1, 0)
	frameGui.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
	frameGui.BackgroundTransparency = 0.2
	frameGui.BorderSizePixel = 0
	frameGui.Parent = bbg

	local stroke = Instance.new("UIStroke")
	stroke.Color = tagColor
	stroke.Thickness = 2.5
	stroke.Parent = frameGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frameGui

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0.55, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = mainTitle
	titleLabel.TextColor3 = tagColor
	titleLabel.TextSize = 18
	titleLabel.Parent = frameGui

	local subLabel = Instance.new("TextLabel")
	subLabel.Position = UDim2.new(0, 0, 0.52, 0)
	subLabel.Size = UDim2.new(1, 0, 0.42, 0)
	subLabel.BackgroundTransparency = 1
	subLabel.Font = Enum.Font.GothamMedium
	subLabel.Text = subtitle
	subLabel.TextColor3 = Color3.fromRGB(220, 225, 235)
	subLabel.TextSize = 13
	subLabel.Parent = frameGui
end

-- =============================================================================
-- ESTACIÓN 1: MERCADO ARCANO (Z = -25)
-- =============================================================================
local marketModel = Instance.new("Model")
marketModel.Name = "Station_Mercado"
marketModel.Parent = stationsFolder

local mZ = -25
-- Plataforma base de madera pulida
makePart(marketModel, "MarketDeck", Vector3.new(16, 0.8, 16), CFrame.new(WEST_X, 4.8, mZ), Color3.fromRGB(54, 40, 28), Enum.Material.WoodPlanks)

-- 4 Postes de madera de la tienda
for _, dx in ipairs({ -6.5, 6.5 }) do
	for _, dz in ipairs({ -6.5, 6.5 }) do
		makePart(marketModel, "StallPost", Vector3.new(0.9, 8.4, 0.9), CFrame.new(WEST_X + dx, 9.0, mZ + dz), Color3.fromRGB(48, 34, 24), Enum.Material.Wood)
	end
end

-- Mostrador de comercio
makePart(marketModel, "Counter", Vector3.new(10, 3.2, 2.0), CFrame.new(WEST_X, 6.4, mZ + 4.5), Color3.fromRGB(68, 50, 36), Enum.Material.WoodPlanks)
makePart(marketModel, "CounterTop", Vector3.new(10.6, 0.35, 2.4), CFrame.new(WEST_X, 8.05, mZ + 4.5), Color3.fromRGB(215, 175, 55), Enum.Material.Marble)

-- Toldo a rayas púrpura y oro
local canopy = makePart(marketModel, "Canopy", Vector3.new(15, 1.2, 15), CFrame.new(WEST_X, 13.4, mZ), Color3.fromRGB(130, 40, 180), Enum.Material.Fabric)
local canopyTrim = makePart(marketModel, "CanopyTrim", Vector3.new(15.4, 0.4, 15.4), CFrame.new(WEST_X, 12.8, mZ), Color3.fromRGB(240, 195, 45), Enum.Material.Fabric)

-- Estanterías traseras con pociones
local shelf = makePart(marketModel, "PotionShelf", Vector3.new(11, 6.5, 1.2), CFrame.new(WEST_X, 8.2, mZ - 5.5), Color3.fromRGB(42, 30, 22), Enum.Material.Wood)
for i = 1, 5 do
	local pColor = i % 2 == 0 and Color3.fromRGB(0, 230, 255) or (i % 3 == 0 and Color3.fromRGB(255, 60, 90) or Color3.fromRGB(60, 255, 120))
	local pot = makePart(marketModel, "Potion_" .. i, Vector3.new(0.6, 0.9, 0.6), CFrame.new(WEST_X - 4.0 + (i * 1.4), 9.2, mZ - 5.1), pColor, Enum.Material.Neon, Enum.PartType.Ball)
	pot.CanCollide = false
end

-- Cofre de monedas
local chest = makePart(marketModel, "LootChest", Vector3.new(2.4, 1.8, 1.6), CFrame.new(WEST_X + 3.8, 6.0, mZ + 1.0), Color3.fromRGB(90, 60, 35), Enum.Material.WoodPlanks)
local chestLock = makePart(marketModel, "ChestLock", Vector3.new(0.4, 0.5, 0.2), CFrame.new(WEST_X + 3.8, 6.0, mZ + 1.85), Color3.fromRGB(255, 215, 60), Enum.Material.Metal)

-- Pad Interactivo
local marketPad = makePart(marketModel, "InteractionPad", Vector3.new(6.0, 0.15, 4.0), CFrame.new(WEST_X, 5.25, mZ + 7.5), Color3.fromRGB(255, 195, 40), Enum.Material.Neon)
local promptM = Instance.new("ProximityPrompt")
promptM.ActionText = "Abrir Mercado"
promptM.ObjectText = "Tienda de Materiales"
promptM.KeyboardKeyCode = Enum.KeyCode.E
promptM.HoldDuration = 0
promptM.MaxActivationDistance = 14
promptM.RequiresLineOfSight = false
promptM.Parent = marketPad

createStationSign(marketModel, CFrame.new(WEST_X, 11.2, mZ + 6.2), "MERCADO ARCANO", "Vende Materiales de Zonas", Color3.fromRGB(255, 205, 50))

-- =============================================================================
-- ESTACIÓN 2: FORJA REAL (Z = 10)
-- =============================================================================
local forgeModel = Instance.new("Model")
forgeModel.Name = "Station_Forja"
forgeModel.Parent = stationsFolder

local fZ = 10
-- Plataforma de piedra oscura
makePart(forgeModel, "ForgeDeck", Vector3.new(16, 0.8, 16), CFrame.new(WEST_X, 4.8, fZ), Color3.fromRGB(36, 38, 45), Enum.Material.Slate)

-- Horno de Forja de Piedra Masiva con Chimenea
local ovenBase = makePart(forgeModel, "OvenBase", Vector3.new(8.0, 6.0, 4.5), CFrame.new(WEST_X, 7.8, fZ - 5.0), Color3.fromRGB(50, 52, 60), Enum.Material.Cobblestone)
local chimney = makePart(forgeModel, "Chimney", Vector3.new(3.0, 7.5, 3.0), CFrame.new(WEST_X, 14.2, fZ - 5.0), Color3.fromRGB(42, 44, 52), Enum.Material.Cobblestone)

-- Foco de Lava Ardiente en el Horno
local lavaCore = makePart(forgeModel, "LavaCore", Vector3.new(5.0, 2.6, 2.0), CFrame.new(WEST_X, 6.8, fZ - 3.4), Color3.fromRGB(255, 90, 0), Enum.Material.Neon)
local lavaLight = Instance.new("PointLight")
lavaLight.Color = Color3.fromRGB(255, 110, 10)
lavaLight.Brightness = 4.0
lavaLight.Range = 18
lavaLight.Parent = lavaCore

-- Chispas del Horno
local forgeFire = Instance.new("ParticleEmitter")
forgeFire.Color = ColorSequence.new(Color3.fromRGB(255, 180, 40), Color3.fromRGB(255, 50, 0))
forgeFire.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0.05) })
forgeFire.Lifetime = NumberRange.new(0.5, 1.2)
forgeFire.Rate = 18
forgeFire.Speed = NumberRange.new(3, 7)
forgeFire.Parent = lavaCore

-- Gran Yunque de Acero
local anvilStump = makePart(forgeModel, "AnvilStump", Vector3.new(2.4, 2.4, 2.4), CFrame.new(WEST_X, 6.2, fZ + 1.0), Color3.fromRGB(45, 30, 20), Enum.Material.Wood, Enum.PartType.Cylinder)
anvilStump.CFrame = anvilStump.CFrame * CFrame.Angles(0, 0, math.rad(90))

local anvilBody = makePart(forgeModel, "AnvilBody", Vector3.new(3.0, 1.2, 1.6), CFrame.new(WEST_X, 7.6, fZ + 1.0), Color3.fromRGB(28, 28, 34), Enum.Material.Metal)
local anvilHorn = makePart(forgeModel, "AnvilHorn", Vector3.new(1.4, 0.6, 1.0), CFrame.new(WEST_X + 1.8, 7.7, fZ + 1.0), Color3.fromRGB(38, 38, 46), Enum.Material.Metal)

-- Tina de enfriamiento con agua humeante
local waterTrough = makePart(forgeModel, "WaterTrough", Vector3.new(3.2, 2.2, 5.0), CFrame.new(WEST_X - 5.5, 6.1, fZ + 0.5), Color3.fromRGB(55, 60, 68), Enum.Material.Slate)
local troughWater = makePart(forgeModel, "TroughWater", Vector3.new(2.6, 0.4, 4.4), CFrame.new(WEST_X - 5.5, 7.0, fZ + 0.5), Color3.fromRGB(0, 180, 240), Enum.Material.Glass)
troughWater.Transparency = 0.4

-- Pad Interactivo
local forgePad = makePart(forgeModel, "InteractionPad", Vector3.new(6.0, 0.15, 4.0), CFrame.new(WEST_X, 5.25, fZ + 6.0), Color3.fromRGB(255, 100, 20), Enum.Material.Neon)
local promptF = Instance.new("ProximityPrompt")
promptF.ActionText = "Abrir Forja"
promptF.ObjectText = "Crafteo de Bastones"
promptF.KeyboardKeyCode = Enum.KeyCode.E
promptF.HoldDuration = 0
promptF.MaxActivationDistance = 14
promptF.RequiresLineOfSight = false
promptF.Parent = forgePad

createStationSign(forgeModel, CFrame.new(WEST_X, 11.2, fZ + 5.0), "FORJA REAL", "Forja Nuevos Bastones Mágicos", Color3.fromRGB(255, 110, 30))

-- =============================================================================
-- ESTACIÓN 3: ALTAR DE ENCANTAR (Z = 45)
-- =============================================================================
local enchantModel = Instance.new("Model")
enchantModel.Name = "Station_Encantar"
enchantModel.Parent = stationsFolder

local eZ = 45
-- Rotonda de Mármol Blanco
local rotundaFloor = makePart(enchantModel, "RotundaFloor", Vector3.new(16, 0.8, 16), CFrame.new(WEST_X, 4.8, eZ), Color3.fromRGB(60, 65, 80), Enum.Material.Marble, Enum.PartType.Cylinder)
rotundaFloor.CFrame = rotundaFloor.CFrame * CFrame.Angles(0, 0, math.rad(90))

-- 4 Columnas Corintias de Mármol
for i = 1, 4 do
	local ang = math.rad((i - 1) * 90 + 45)
	local cX = WEST_X + math.cos(ang) * 6.5
	local cZ = eZ + math.sin(ang) * 6.5
	local col = makePart(enchantModel, "MarbleCol_" .. i, Vector3.new(1.4, 8.5, 1.4), CFrame.new(cX, 9.2, cZ), Color3.fromRGB(210, 215, 225), Enum.Material.Marble, Enum.PartType.Cylinder)
	col.CFrame = col.CFrame * CFrame.Angles(0, 0, math.rad(90))
end

-- Cúpula / Anillo Superior
local archRing = makePart(enchantModel, "ArchRing", Vector3.new(15, 1.0, 15), CFrame.new(WEST_X, 13.5, eZ), Color3.fromRGB(70, 45, 95), Enum.Material.Marble, Enum.PartType.Cylinder)
archRing.CFrame = archRing.CFrame * CFrame.Angles(0, 0, math.rad(90))

-- Pedestal de Obsidiana
local altarPed = makePart(enchantModel, "ObsidianPedestal", Vector3.new(4.2, 3.2, 4.2), CFrame.new(WEST_X, 6.6, eZ), Color3.fromRGB(22, 18, 30), Enum.Material.Slate)
local altarGemPad = makePart(enchantModel, "AltarGemPad", Vector3.new(3.4, 0.3, 3.4), CFrame.new(WEST_X, 8.25, eZ), Color3.fromRGB(180, 60, 255), Enum.Material.Neon)

-- Gran Grimorio Mágico Abierto Flotando
local grimoireLeft = makePart(enchantModel, "GrimoirePageL", Vector3.new(1.6, 0.2, 2.2), CFrame.new(WEST_X - 0.7, 9.4, eZ) * CFrame.Angles(0, 0, math.rad(15)), Color3.fromRGB(240, 235, 210), Enum.Material.Fabric)
grimoireLeft.CanCollide = false
local grimoireRight = makePart(enchantModel, "GrimoirePageR", Vector3.new(1.6, 0.2, 2.2), CFrame.new(WEST_X + 0.7, 9.4, eZ) * CFrame.Angles(0, 0, math.rad(-15)), Color3.fromRGB(240, 235, 210), Enum.Material.Fabric)
grimoireRight.CanCollide = false
local grimoireCover = makePart(enchantModel, "GrimoireCover", Vector3.new(3.4, 0.25, 2.3), CFrame.new(WEST_X, 9.25, eZ), Color3.fromRGB(60, 20, 80), Enum.Material.Leather)
grimoireCover.CanCollide = false

-- 4 Cristales Orbitantes de Amatista
for i = 1, 4 do
	local ang = math.rad((i - 1) * 90)
	local ox = WEST_X + math.cos(ang) * 2.8
	local oz = eZ + math.sin(ang) * 2.8
	local cOrb = makePart(enchantModel, "OrbitCrystal_" .. i, Vector3.new(0.6, 1.4, 0.6), CFrame.new(ox, 9.6, oz) * CFrame.Angles(math.rad(15), ang, math.rad(15)), Color3.fromRGB(200, 70, 255), Enum.Material.Neon)
	cOrb.CanCollide = false
end

local enLight = Instance.new("PointLight")
enLight.Color = Color3.fromRGB(190, 70, 255)
enLight.Brightness = 3.5
enLight.Range = 16
enLight.Parent = altarGemPad

-- Pad Interactivo
local enchantPad = makePart(enchantModel, "InteractionPad", Vector3.new(6.0, 0.15, 4.0), CFrame.new(WEST_X, 5.25, eZ + 6.0), Color3.fromRGB(180, 50, 255), Enum.Material.Neon)
local promptE = Instance.new("ProximityPrompt")
promptE.ActionText = "Abrir Encantamientos"
promptE.ObjectText = "Altar Rúnico"
promptE.KeyboardKeyCode = Enum.KeyCode.E
promptE.HoldDuration = 0
promptE.MaxActivationDistance = 14
promptE.RequiresLineOfSight = false
promptE.Parent = enchantPad

createStationSign(enchantModel, CFrame.new(WEST_X, 11.2, eZ + 5.0), "ALTAR DE ENCANTAR", "Runas Mágicas y Mejoras", Color3.fromRGB(195, 80, 255))

-- =============================================================================
-- ESTACIÓN 4: SANTUARIO DE MASCOTAS (Z = 80)
-- =============================================================================
local petModel = Instance.new("Model")
petModel.Name = "Station_Mascotas"
petModel.Parent = stationsFolder

local pZ = 80
-- Plataforma de Piedra Musgosa Circular
local petDeck = makePart(petModel, "PetDeck", Vector3.new(16, 0.8, 16), CFrame.new(WEST_X, 4.8, pZ), Color3.fromRGB(35, 45, 38), Enum.Material.Slate, Enum.PartType.Cylinder)
petDeck.CFrame = petDeck.CFrame * CFrame.Angles(0, 0, math.rad(90))

-- Estanque Central de Agua de Maná
local pond = makePart(petModel, "ManaPond", Vector3.new(11, 0.25, 11), CFrame.new(WEST_X, 5.25, pZ - 1.0), Color3.fromRGB(0, 220, 180), Enum.Material.Glass, Enum.PartType.Cylinder)
pond.CFrame = pond.CFrame * CFrame.Angles(0, 0, math.rad(90))
pond.Transparency = 0.35

-- Árbol Espiritual Sagrado en el Centro
local trunk = makePart(petModel, "SpiritTree_Trunk", Vector3.new(1.4, 6.5, 1.4), CFrame.new(WEST_X, 8.2, pZ - 1.0), Color3.fromRGB(45, 32, 22), Enum.Material.Wood, Enum.PartType.Cylinder)
trunk.CFrame = trunk.CFrame * CFrame.Angles(0, 0, math.rad(90))

local foliage1 = makePart(petModel, "FoliageCrown", Vector3.new(5.5, 4.0, 5.5), CFrame.new(WEST_X, 12.0, pZ - 1.0), Color3.fromRGB(30, 235, 140), Enum.Material.Neon, Enum.PartType.Ball)
foliage1.CanCollide = false
local foliage2 = makePart(petModel, "FoliageWingL", Vector3.new(3.5, 3.0, 3.5), CFrame.new(WEST_X - 2.5, 10.5, pZ - 1.0), Color3.fromRGB(0, 210, 180), Enum.Material.Neon, Enum.PartType.Ball)
foliage2.CanCollide = false
local foliage3 = makePart(petModel, "FoliageWingR", Vector3.new(3.5, 3.0, 3.5), CFrame.new(WEST_X + 2.5, 10.5, pZ - 1.0), Color3.fromRGB(0, 210, 180), Enum.Material.Neon, Enum.PartType.Ball)
foliage3.CanCollide = false

-- Espíritus Familiares Flotantes
for i = 1, 4 do
	local ang = math.rad((i - 1) * 90 + 30)
	local fx = WEST_X + math.cos(ang) * 4.2
	local fz = (pZ - 1.0) + math.sin(ang) * 4.2
	local spirit = makePart(petModel, "SpiritWisp_" .. i, Vector3.new(0.6, 0.6, 0.6), CFrame.new(fx, 7.8 + (i % 2) * 0.8, fz), Color3.fromRGB(50, 255, 180), Enum.Material.Neon, Enum.PartType.Ball)
	spirit.CanCollide = false
	local sL = Instance.new("PointLight")
	sL.Color = Color3.fromRGB(50, 255, 180)
	sL.Brightness = 1.8
	sL.Range = 10
	sL.Parent = spirit
end

-- Cojines de Terciopelo para Descanso de Mascotas
local cushionAngles = { -45, 0, 45 }
for idx, cAng in ipairs(cushionAngles) do
	local rad = math.rad(cAng)
	local cx = WEST_X + math.sin(rad) * 4.8
	local cz = (pZ - 1.0) - math.cos(rad) * 4.8
	local plinth = makePart(petModel, "PetPlinth_" .. idx, Vector3.new(2.2, 0.5, 2.2), CFrame.new(cx, 5.4, cz), Color3.fromRGB(48, 55, 62), Enum.Material.Marble, Enum.PartType.Cylinder)
	plinth.CFrame = plinth.CFrame * CFrame.Angles(0, 0, math.rad(90))
	local cushion = makePart(petModel, "PetCushion_" .. idx, Vector3.new(1.8, 0.35, 1.8), CFrame.new(cx, 5.75, cz), Color3.fromRGB(15, 120, 110), Enum.Material.Fabric, Enum.PartType.Cylinder)
	cushion.CFrame = cushion.CFrame * CFrame.Angles(0, 0, math.rad(90))
end

-- Pad Interactivo
local petPad = makePart(petModel, "InteractionPad", Vector3.new(5.0, 0.15, 3.5), CFrame.new(WEST_X, 5.25, pZ + 5.0), Color3.fromRGB(0, 240, 140), Enum.Material.Neon)
local promptP = Instance.new("ProximityPrompt")
promptP.ActionText = "Ver Mascotas"
promptP.ObjectText = "Santuario de Mascotas"
promptP.KeyboardKeyCode = Enum.KeyCode.E
promptP.HoldDuration = 0
promptP.MaxActivationDistance = 12
promptP.RequiresLineOfSight = false
promptP.Parent = petPad

createStationSign(petModel, CFrame.new(WEST_X, 11.2, pZ + 4.0), "SANTUARIO DE MASCOTAS", "Equipa y Sube de Nivel a tus Compañeros", Color3.fromRGB(0, 245, 140))

--------------------------------------------------------------------------------
-- 5. LOS 7 SANTUARIOS / TRAINING SPOTS EN LA TERRAZA ESTE (PASEO DE LA ASCENSIÓN)
--------------------------------------------------------------------------------
local sanctumsFolder = Instance.new("Folder")
sanctumsFolder.Name = "TrainingSpots"
sanctumsFolder.Parent = lobby

local EAST_X = 58
local sanctumConfigs = {
	{ Tier = 1, Z = -35, Name = "Piedra Rúnica", RebirthReq = 0, Mult = 1.0, Color = Color3.fromRGB(0, 240, 255), Mat = Enum.Material.Slate },
	{ Tier = 2, Z = -15, Name = "Bronce Elemental", RebirthReq = 1, Mult = 2.5, Color = Color3.fromRGB(255, 170, 40), Mat = Enum.Material.Metal },
	{ Tier = 3, Z = 5, Name = "Plata Helada", RebirthReq = 3, Mult = 6.0, Color = Color3.fromRGB(180, 230, 255), Mat = Enum.Material.Glass },
	{ Tier = 4, Z = 25, Name = "Jade Arcano", RebirthReq = 6, Mult = 15.0, Color = Color3.fromRGB(40, 255, 130), Mat = Enum.Material.Marble },
	{ Tier = 5, Z = 45, Name = "Llama Fénix", RebirthReq = 10, Mult = 40.0, Color = Color3.fromRGB(255, 70, 30), Mat = Enum.Material.Neon },
	{ Tier = 6, Z = 65, Name = "Vacío Astral", RebirthReq = 16, Mult = 100.0, Color = Color3.fromRGB(160, 40, 255), Mat = Enum.Material.Slate },
	{ Tier = 7, Z = 85, Name = "Vórtice Celestial", RebirthReq = 25, Mult = 300.0, Color = Color3.fromRGB(255, 235, 90), Mat = Enum.Material.Neon },
}

for _, cfg in ipairs(sanctumConfigs) do
	local sModel = Instance.new("Model")
	sModel.Name = "TrainingSpot_Tier" .. cfg.Tier
	sModel:SetAttribute("Tier", cfg.Tier)
	sModel:SetAttribute("RequiredRebirths", cfg.RebirthReq)
	sModel:SetAttribute("Multiplier", cfg.Mult)
	sModel:SetAttribute("SpotName", cfg.Name)
	sModel.Parent = sanctumsFolder

	local sZ = cfg.Z
	-- Pedestal Base Cilíndrico
	local sBase = makePart(sModel, "SanctumBase", Vector3.new(12, 1.2, 12), CFrame.new(EAST_X, 4.8, sZ), Color3.fromRGB(40, 46, 62), cfg.Mat, Enum.PartType.Cylinder)
	sBase.CFrame = sBase.CFrame * CFrame.Angles(0, 0, math.rad(90))

	-- Anillo Rúnico Brillante
	local sRing = makePart(sModel, "RunicRing", Vector3.new(10.5, 0.25, 10.5), CFrame.new(EAST_X, 5.45, sZ), cfg.Color, Enum.Material.Neon, Enum.PartType.Cylinder)
	sRing.CFrame = sRing.CFrame * CFrame.Angles(0, 0, math.rad(90))
	sRing.CanCollide = false

	-- Sello Central de Estrella
	local sPad = makePart(sModel, "TrainingPad", Vector3.new(7.0, 0.28, 7.0), CFrame.new(EAST_X, 5.48, sZ), Color3.fromRGB(240, 245, 255), Enum.Material.Marble)

	-- 2 Columnas de Resonancia en los bordes
	for _, dz in ipairs({ -5.0, 5.0 }) do
		local col = makePart(sModel, "Pillar", Vector3.new(1.2, 6.0, 1.2), CFrame.new(EAST_X + 4.5, 7.8, sZ + dz), Color3.fromRGB(55, 62, 78), Enum.Material.Slate)
		local gem = makePart(sModel, "Gem", Vector3.new(0.8, 0.8, 0.8), CFrame.new(EAST_X + 4.5, 11.2, sZ + dz) * CFrame.Angles(math.rad(45), math.rad(45), 0), cfg.Color, Enum.Material.Neon)
		gem.CanCollide = false
		local pL = Instance.new("PointLight")
		pL.Color = cfg.Color
		pL.Brightness = 1.8
		pL.Range = 10
		pL.Parent = gem
	end

	-- Partículas de Aura
	local aura = Instance.new("ParticleEmitter")
	aura.Color = ColorSequence.new(cfg.Color)
	aura.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.7) })
	aura.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
	aura.Lifetime = NumberRange.new(1.0, 1.8)
	aura.Rate = 12
	aura.Speed = NumberRange.new(1.5, 4)
	aura.Parent = sPad

	-- Cartel Flotante del Santuario
	local bbg = Instance.new("BillboardGui")
	bbg.Name = "SanctumGui"
	bbg.Size = UDim2.new(0, 220, 0, 75)
	bbg.StudsOffset = Vector3.new(0, 7.5, 0)
	bbg.MaxDistance = 12
	bbg.AlwaysOnTop = false
	bbg.Adornee = sPad
	bbg.Enabled = false
	bbg.Parent = sModel

	local fG = Instance.new("Frame")
	fG.Size = UDim2.new(1, 0, 1, 0)
	fG.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
	fG.BackgroundTransparency = 0.25
	fG.BorderSizePixel = 0
	fG.Parent = bbg

	local stroke = Instance.new("UIStroke")
	stroke.Color = cfg.Color
	stroke.Thickness = 2
	stroke.Parent = fG

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = fG

	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, 0, 0.5, 0)
	tLbl.BackgroundTransparency = 1
	tLbl.Font = Enum.Font.GothamBold
	tLbl.Text = string.format("⚡ TIER %d: %s", cfg.Tier, cfg.Name)
	tLbl.TextColor3 = cfg.Color
	tLbl.TextSize = 14
	tLbl.Parent = fG

	local sLbl = Instance.new("TextLabel")
	sLbl.Position = UDim2.new(0, 0, 0.48, 0)
	sLbl.Size = UDim2.new(1, 0, 0.48, 0)
	sLbl.BackgroundTransparency = 1
	sLbl.Font = Enum.Font.GothamMedium
	sLbl.Text = string.format("Req: %d Rebirths  |  x%.1f Poder", cfg.RebirthReq, cfg.Mult)
	sLbl.TextColor3 = Color3.fromRGB(230, 235, 245)
	sLbl.TextSize = 12
	sLbl.Parent = fG
end

--------------------------------------------------------------------------------
-- 6. NATURALEZA Y VEGETACIÓN ARCANO (ÁRBOLES ESTILIZADOS Y FAROLAS)
--------------------------------------------------------------------------------
local decorFolder = Instance.new("Folder")
decorFolder.Name = "VegetationAndDecor"
decorFolder.Parent = lobby

local function createStylizedTree(cf: CFrame, leafColor: Color3)
	local treeModel = Instance.new("Model")
	treeModel.Name = "ArcaneTree"
	treeModel.Parent = decorFolder

	-- Tronco retorcido de madera noble
	local trunk = makePart(treeModel, "Trunk", Vector3.new(2.2, 10.0, 2.2), cf * CFrame.new(0, 5.0, 0), Color3.fromRGB(48, 36, 26), Enum.Material.Wood, Enum.PartType.Cylinder)
	trunk.CFrame = trunk.CFrame * CFrame.Angles(0, 0, math.rad(90))

	-- Copa de hojas estilizada (3 capas esféricas)
	local c1 = makePart(treeModel, "Canopy1", Vector3.new(8.0, 6.0, 8.0), cf * CFrame.new(0, 11.0, 0), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
	local c2 = makePart(treeModel, "Canopy2", Vector3.new(6.0, 4.5, 6.0), cf * CFrame.new(0, 14.5, 0), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
	local c3 = makePart(treeModel, "Canopy3", Vector3.new(3.5, 3.0, 3.5), cf * CFrame.new(0, 17.0, 0), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
	
	-- Frutas / Gemas brillantes colgando de las ramas
	local gemLight = makePart(treeModel, "TreeGlow", Vector3.new(0.8, 0.8, 0.8), cf * CFrame.new(2.0, 9.5, 1.5), Color3.fromRGB(0, 255, 220), Enum.Material.Neon, Enum.PartType.Ball)
	gemLight.CanCollide = false
end

-- Árboles a lo largo de las terrazas
createStylizedTree(CFrame.new(-30, 4.2, -35), Color3.fromRGB(160, 60, 200))
createStylizedTree(CFrame.new(-30, 4.2, -5), Color3.fromRGB(60, 180, 230))
createStylizedTree(CFrame.new(-30, 4.2, 25), Color3.fromRGB(160, 60, 200))
createStylizedTree(CFrame.new(-30, 4.2, 60), Color3.fromRGB(60, 180, 230))

createStylizedTree(CFrame.new(30, 4.2, -35), Color3.fromRGB(60, 180, 230))
createStylizedTree(CFrame.new(30, 4.2, -5), Color3.fromRGB(160, 60, 200))
createStylizedTree(CFrame.new(30, 4.2, 25), Color3.fromRGB(60, 180, 230))
createStylizedTree(CFrame.new(30, 4.2, 60), Color3.fromRGB(160, 60, 200))

-- Farolas de forja medieval a lo largo del Paseo Central
local function createStreetLamp(cf: CFrame)
	local lampModel = Instance.new("Model")
	lampModel.Name = "StreetLamp"
	lampModel.Parent = decorFolder

	local pole = makePart(lampModel, "Pole", Vector3.new(0.8, 8.0, 0.8), cf * CFrame.new(0, 4.0, 0), Color3.fromRGB(30, 32, 40), Enum.Material.Metal)
	local arm = makePart(lampModel, "Arm", Vector3.new(2.2, 0.4, 0.4), cf * CFrame.new(0.8, 7.8, 0), Color3.fromRGB(30, 32, 40), Enum.Material.Metal)
	local orb = makePart(lampModel, "LampOrb", Vector3.new(1.2, 1.2, 1.2), cf * CFrame.new(1.6, 7.2, 0), Color3.fromRGB(255, 220, 140), Enum.Material.Neon, Enum.PartType.Ball)
	orb.CanCollide = false

	local pl = Instance.new("PointLight")
	pl.Color = Color3.fromRGB(255, 215, 130)
	pl.Brightness = 2.0
	pl.Range = 16
	pl.Parent = orb
end

for z = -20, 70, 30 do
	createStreetLamp(CFrame.new(-12, 1.0, z))
	createStreetLamp(CFrame.new(12, 1.0, z) * CFrame.Angles(0, math.rad(180), 0))
end

--------------------------------------------------------------------------------
-- 7. MURALLAS DE LA CIUDADELA Y PORTAL NORTE HACIA ZONA 1
--------------------------------------------------------------------------------
local wallsFolder = Instance.new("Folder")
wallsFolder.Name = "CitadelWalls"
wallsFolder.Parent = lobby

-- Muralla Oeste (X = -72)
makePart(wallsFolder, "WallWest", Vector3.new(4, 24, 136), CFrame.new(-72, 12, 20), Color3.fromRGB(45, 52, 68), Enum.Material.Cobblestone)
-- Muralla Este (X = 72)
makePart(wallsFolder, "WallEast", Vector3.new(4, 24, 136), CFrame.new(72, 12, 20), Color3.fromRGB(45, 52, 68), Enum.Material.Cobblestone)
-- Muralla Sur (Z = -46)
makePart(wallsFolder, "WallSouth", Vector3.new(148, 24, 4), CFrame.new(0, 12, -46), Color3.fromRGB(45, 52, 68), Enum.Material.Cobblestone)

-- Muralla Norte (Flancos del portal a Zona 1)
makePart(wallsFolder, "WallNorthLeft", Vector3.new(60, 24, 4), CFrame.new(-42, 12, 86), Color3.fromRGB(45, 52, 68), Enum.Material.Cobblestone)
makePart(wallsFolder, "WallNorthRight", Vector3.new(60, 24, 4), CFrame.new(42, 12, 86), Color3.fromRGB(45, 52, 68), Enum.Material.Cobblestone)

-- Gran Portal Arco hacia Zona 1 (Z = 86, X: -12 a 12)
local portalArch = Instance.new("Model")
portalArch.Name = "GateToZone1"
portalArch.Parent = wallsFolder

makePart(portalArch, "ArchColLeft", Vector3.new(3.5, 22, 3.5), CFrame.new(-13.5, 11, 86), Color3.fromRGB(60, 70, 90), Enum.Material.Slate)
makePart(portalArch, "ArchColRight", Vector3.new(3.5, 22, 3.5), CFrame.new(13.5, 11, 86), Color3.fromRGB(60, 70, 90), Enum.Material.Slate)
makePart(portalArch, "ArchBeam", Vector3.new(30, 4, 4), CFrame.new(0, 22, 86), Color3.fromRGB(70, 80, 105), Enum.Material.Slate)

-- Estandartes de la Ciudadela Colgados en los Muros
for _, xBanner in ipairs({ -30, -50, 30, 50 }) do
	local banner = makePart(wallsFolder, "CitadelBanner", Vector3.new(4.5, 12, 0.2), CFrame.new(xBanner, 14, -44), Color3.fromRGB(120, 30, 170), Enum.Material.Fabric)
	banner.CanCollide = false
	local bannerGold = makePart(wallsFolder, "BannerGold", Vector3.new(1.2, 1.2, 0.3), CFrame.new(xBanner, 16, -43.9), Color3.fromRGB(240, 200, 50), Enum.Material.Metal)
	bannerGold.CanCollide = false
end

print("[LobbyBuilder] ¡Gran Lobby Espectacular construida exitosamente!")
return "LOBBY_BUILD_SUCCESS"
