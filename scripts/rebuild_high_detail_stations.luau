--!strict
-- rebuild_high_detail_stations.luau
-- Wizard Craft & Combat Simulator
-- Transforma las 4 estaciones de la Gran Lobby en modelos 3D de alta definición,
-- recreando los diseños de Blender: Estantes Mágicos (Mercado), Horno y Yunque (Forja),
-- Altar Rúnico con Grimorio Flotante (Encantar) y Santuario de Mascotas (Arboleda Mística sin huevos).

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local lobby = Workspace:WaitForChild("Lobby")
local stationsFolder = lobby:FindFirstChild("PhysicalLobbyStations")
if not stationsFolder then
	stationsFolder = Instance.new("Folder")
	stationsFolder.Name = "PhysicalLobbyStations"
	stationsFolder.Parent = lobby
end

-- Limpiar estaciones anteriores
for _, child in ipairs(stationsFolder:GetChildren()) do
	child:Destroy()
end

local function makePart(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.CastShadow = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		p.Shape = shape
	end
	p.Parent = parent
	return p
end

local function createCrispSign(parent: Model, cf: CFrame, title: string, subtitle: string, accentColor: Color3)
	local board = makePart(parent, "SignBoard", Vector3.new(4.2, 1.8, 0.3), cf, Color3.fromRGB(18, 16, 22), Enum.Material.WoodPlanks)
	local frame = makePart(parent, "SignFrame", Vector3.new(4.4, 2.0, 0.35), cf, Color3.fromRGB(25, 25, 30), Enum.Material.Metal)
	frame.CanCollide = false
	
	local bbg = Instance.new("BillboardGui")
	bbg.Name = "StationSignGui"
	bbg.Size = UDim2.new(0, 240, 0, 75)
	bbg.StudsOffset = Vector3.new(0, 0.4, 0)
	bbg.MaxDistance = 12 -- Estrictamente visible solo a corta distancia
	bbg.AlwaysOnTop = false
	bbg.LightInfluence = 0
	bbg.Adornee = board
	bbg.Enabled = false -- Inicialmente apagado, controlado por ProximitySignController
	bbg.Parent = board

	local frameGui = Instance.new("Frame")
	frameGui.Size = UDim2.new(1, 0, 1, 0)
	frameGui.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
	frameGui.BackgroundTransparency = 0.2
	frameGui.BorderSizePixel = 0
	frameGui.Parent = bbg

	local stroke = Instance.new("UIStroke")
	stroke.Color = accentColor
	stroke.Thickness = 2
	stroke.Parent = frameGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frameGui

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0.52, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = title
	titleLabel.TextColor3 = accentColor
	titleLabel.TextSize = 15
	titleLabel.Parent = frameGui

	local subLabel = Instance.new("TextLabel")
	subLabel.Position = UDim2.new(0, 0, 0.5, 0)
	subLabel.Size = UDim2.new(1, 0, 0.45, 0)
	subLabel.BackgroundTransparency = 1
	subLabel.Font = Enum.Font.GothamMedium
	subLabel.Text = subtitle
	subLabel.TextColor3 = Color3.fromRGB(220, 225, 235)
	subLabel.TextSize = 11
	subLabel.Parent = frameGui
end

local WEST_X = -58

-- =============================================================================
-- 1. MERCADO ARCANO: ESTANTES MÁGICOS 3D Y BAZAR
-- =============================================================================
local marketModel = Instance.new("Model")
marketModel.Name = "Station_Mercado"
marketModel.Parent = stationsFolder
local mZ = -30

-- Plataforma de Madera Noble
makePart(marketModel, "MarketDeck", Vector3.new(16, 0.8, 16), CFrame.new(WEST_X, 4.8, mZ), Color3.fromRGB(48, 34, 24), Enum.Material.WoodPlanks)

-- Estante Mágico Principal (Backboard de Roble Oscuro)
local shelfBack = makePart(marketModel, "Shelf_Backboard", Vector3.new(12, 8.5, 0.6), CFrame.new(WEST_X, 9.2, mZ - 6.5), Color3.fromRGB(36, 24, 16), Enum.Material.Wood)
local shelfTopCrown = makePart(marketModel, "Shelf_ArchCrown", Vector3.new(12.4, 0.8, 0.8), CFrame.new(WEST_X, 13.8, mZ - 6.5), Color3.fromRGB(220, 180, 50), Enum.Material.Marble)

-- 4 Balas/Estantes Horizontales con Filigrana Dorada
local shelfHeights = { 6.2, 8.2, 10.2, 12.2 }
for idx, sY in ipairs(shelfHeights) do
	local plank = makePart(marketModel, "ShelfPlank_" .. idx, Vector3.new(11.6, 0.4, 1.8), CFrame.new(WEST_X, sY, mZ - 5.8), Color3.fromRGB(50, 32, 20), Enum.Material.WoodPlanks)
	local trim = makePart(marketModel, "GoldTrim_" .. idx, Vector3.new(11.8, 0.15, 0.2), CFrame.new(WEST_X, sY, mZ - 4.85), Color3.fromRGB(240, 195, 45), Enum.Material.Metal)
	trim.CanCollide = false
end

-- Columnas Laterales del Mueble
for _, dX in ipairs({ -5.8, 5.8 }) do
	local pillar = makePart(marketModel, "ShelfPillar", Vector3.new(0.8, 8.6, 1.8), CFrame.new(WEST_X + dX, 9.2, mZ - 5.8), Color3.fromRGB(42, 28, 18), Enum.Material.Wood)
end

-- Detalle de Pociones Alquímicas en los Estantes
local potionColors = {
	Color3.fromRGB(0, 220, 255), -- Poción de Maná
	Color3.fromRGB(255, 60, 80),  -- Poción de Vida
	Color3.fromRGB(60, 255, 120), -- Poción Arcana
	Color3.fromRGB(200, 70, 255), -- Elixir de Vacío
	Color3.fromRGB(255, 200, 40), -- Oro Líquido
}

for rowIdx, sY in ipairs(shelfHeights) do
	for colIdx = 1, 6 do
		local pX = WEST_X - 4.5 + (colIdx - 1) * 1.8
		local color = potionColors[(colIdx + rowIdx) % #potionColors + 1]
		
		if rowIdx == 1 then
			-- Estante 1: Libros y tomos mágicos apilados
			local book = makePart(marketModel, "SpellTome", Vector3.new(0.5, 1.4, 1.1), CFrame.new(pX, sY + 0.9, mZ - 5.7), Color3.fromRGB(80, 25, 30), Enum.Material.Leather)
			book.CanCollide = false
		elseif rowIdx == 2 then
			-- Estante 2: Frascos redondos de alquimia
			local bottle = makePart(marketModel, "FlaskBottle", Vector3.new(0.8, 0.8, 0.8), CFrame.new(pX, sY + 0.6, mZ - 5.7), color, Enum.Material.Neon, Enum.PartType.Ball)
			bottle.CanCollide = false
			local neck = makePart(marketModel, "FlaskNeck", Vector3.new(0.3, 0.4, 0.3), CFrame.new(pX, sY + 1.1, mZ - 5.7), Color3.fromRGB(240, 245, 255), Enum.Material.Glass, Enum.PartType.Cylinder)
			neck.CFrame = neck.CFrame * CFrame.Angles(0, 0, math.rad(90))
			neck.CanCollide = false
		elseif rowIdx == 3 then
			-- Estante 3: Pergaminos arcanos enrollados
			local scroll = makePart(marketModel, "Scroll", Vector3.new(1.2, 0.3, 0.3), CFrame.new(pX, sY + 0.35, mZ - 5.7), Color3.fromRGB(235, 225, 190), Enum.Material.Fabric, Enum.PartType.Cylinder)
			scroll.CanCollide = false
		else
			-- Estante 4: Cristales arcanos brillantes
			local crystal = makePart(marketModel, "MagicCrystal", Vector3.new(0.6, 1.2, 0.6), CFrame.new(pX, sY + 0.8, mZ - 5.7) * CFrame.Angles(math.rad(10), math.rad(colIdx * 45), 0), color, Enum.Material.Neon)
			crystal.CanCollide = false
		end
	end
end

-- Mostrador de Comercio con Balanza Dorada
local counter = makePart(marketModel, "Counter", Vector3.new(11, 3.2, 2.2), CFrame.new(WEST_X, 6.4, mZ + 2.5), Color3.fromRGB(60, 42, 28), Enum.Material.WoodPlanks)
local counterTop = makePart(marketModel, "CounterTop", Vector3.new(11.6, 0.35, 2.6), CFrame.new(WEST_X, 8.05, mZ + 2.5), Color3.fromRGB(225, 185, 65), Enum.Material.Marble)

-- Toldo de Tela Real Púrpura y Dorada
local canopy = makePart(marketModel, "Canopy", Vector3.new(15, 1.4, 14), CFrame.new(WEST_X, 13.8, mZ - 0.5), Color3.fromRGB(120, 35, 160), Enum.Material.Fabric)
local canopyTrim = makePart(marketModel, "CanopyTrim", Vector3.new(15.4, 0.4, 14.4), CFrame.new(WEST_X, 13.1, mZ - 0.5), Color3.fromRGB(245, 205, 50), Enum.Material.Fabric)

-- Farolillo Colgante
local lantern = makePart(marketModel, "ShopLantern", Vector3.new(0.8, 1.2, 0.8), CFrame.new(WEST_X, 12.0, mZ + 2.5), Color3.fromRGB(255, 200, 80), Enum.Material.Neon)
lantern.CanCollide = false
local shopLight = Instance.new("PointLight")
shopLight.Color = Color3.fromRGB(255, 210, 100)
shopLight.Brightness = 2.5
shopLight.Range = 16
shopLight.Parent = lantern

-- Pad de Interacción
local marketPad = makePart(marketModel, "InteractionPad", Vector3.new(5.0, 0.15, 3.5), CFrame.new(WEST_X, 5.25, mZ + 5.5), Color3.fromRGB(255, 195, 40), Enum.Material.Neon)
local promptM = Instance.new("ProximityPrompt")
promptM.ActionText = "Abrir Mercado"
promptM.ObjectText = "Tienda de Materiales"
promptM.KeyboardKeyCode = Enum.KeyCode.E
promptM.HoldDuration = 0
promptM.MaxActivationDistance = 12
promptM.RequiresLineOfSight = false
promptM.Parent = marketPad

createCrispSign(marketModel, CFrame.new(WEST_X, 11.2, mZ + 4.5), "MERCADO ARCANO", "Vende Materiales y Compra Pociones", Color3.fromRGB(255, 205, 50))


-- =============================================================================
-- 2. FORJA REAL: HORNO 3D, YUNQUE Y BRASAS ARDIENTES
-- =============================================================================
local forgeModel = Instance.new("Model")
forgeModel.Name = "Station_Forja"
forgeModel.Parent = stationsFolder
local fZ = 5

-- Plataforma de Piedra Volcánica
makePart(forgeModel, "ForgeDeck", Vector3.new(16, 0.8, 16), CFrame.new(WEST_X, 4.8, fZ), Color3.fromRGB(32, 34, 40), Enum.Material.Slate)

-- Horno de Mampostería de Piedra y Chimenea Alta
local ovenBase = makePart(forgeModel, "OvenBase", Vector3.new(8.5, 6.5, 5.0), CFrame.new(WEST_X, 8.0, fZ - 5.0), Color3.fromRGB(48, 50, 58), Enum.Material.Cobblestone)
local chimney = makePart(forgeModel, "Chimney", Vector3.new(3.2, 8.0, 3.2), CFrame.new(WEST_X, 15.0, fZ - 5.0), Color3.fromRGB(38, 40, 48), Enum.Material.Cobblestone)

-- Foco de Lava y Magma Ardiente en el Hogar
local lavaHearth = makePart(forgeModel, "LavaHearth", Vector3.new(5.5, 2.8, 2.4), CFrame.new(WEST_X, 6.8, fZ - 3.2), Color3.fromRGB(255, 95, 0), Enum.Material.Neon)
local forgeLight = Instance.new("PointLight")
forgeLight.Color = Color3.fromRGB(255, 110, 15)
forgeLight.Brightness = 4.5
forgeLight.Range = 20
forgeLight.Parent = lavaHearth

local forgeSparks = Instance.new("ParticleEmitter")
forgeSparks.Color = ColorSequence.new(Color3.fromRGB(255, 200, 50), Color3.fromRGB(255, 50, 0))
forgeSparks.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0.05) })
forgeSparks.Lifetime = NumberRange.new(0.6, 1.4)
forgeSparks.Rate = 22
forgeSparks.Speed = NumberRange.new(3, 8)
forgeSparks.Parent = lavaHearth

-- Gran Yunque de Acero Forjado sobre Tronco de Madera
local anvilStump = makePart(forgeModel, "AnvilStump", Vector3.new(2.4, 2.4, 2.4), CFrame.new(WEST_X, 6.2, fZ + 0.5), Color3.fromRGB(42, 28, 18), Enum.Material.Wood, Enum.PartType.Cylinder)
anvilStump.CFrame = anvilStump.CFrame * CFrame.Angles(0, 0, math.rad(90))

local anvilBody = makePart(forgeModel, "AnvilBody", Vector3.new(3.2, 1.2, 1.8), CFrame.new(WEST_X, 7.6, fZ + 0.5), Color3.fromRGB(26, 26, 32), Enum.Material.Metal)
local anvilHorn = makePart(forgeModel, "AnvilHorn", Vector3.new(1.4, 0.6, 1.1), CFrame.new(WEST_X + 1.9, 7.7, fZ + 0.5), Color3.fromRGB(36, 36, 44), Enum.Material.Metal)

-- Martillo Espectral Flotando sobre el Yunque
local hammerHead = makePart(forgeModel, "SpectralHammerHead", Vector3.new(1.2, 0.8, 0.8), CFrame.new(WEST_X, 9.8, fZ + 0.5), Color3.fromRGB(255, 160, 40), Enum.Material.Neon)
hammerHead.CanCollide = false
local hammerHandle = makePart(forgeModel, "SpectralHammerHandle", Vector3.new(0.2, 2.0, 0.2), CFrame.new(WEST_X, 10.8, fZ + 0.5), Color3.fromRGB(200, 100, 20), Enum.Material.Metal)
hammerHandle.CanCollide = false

-- Tina de Enfriamiento con Agua Translúcida
local waterTrough = makePart(forgeModel, "WaterTrough", Vector3.new(3.2, 2.2, 4.8), CFrame.new(WEST_X - 5.5, 6.1, fZ + 0.5), Color3.fromRGB(50, 55, 65), Enum.Material.Slate)
local troughWater = makePart(forgeModel, "TroughWater", Vector3.new(2.6, 0.4, 4.2), CFrame.new(WEST_X - 5.5, 7.0, fZ + 0.5), Color3.fromRGB(0, 190, 255), Enum.Material.Glass)
troughWater.Transparency = 0.35

-- Pad de Interacción
local forgePad = makePart(forgeModel, "InteractionPad", Vector3.new(5.0, 0.15, 3.5), CFrame.new(WEST_X, 5.25, fZ + 5.0), Color3.fromRGB(255, 100, 20), Enum.Material.Neon)
local promptF = Instance.new("ProximityPrompt")
promptF.ActionText = "Abrir Forja"
promptF.ObjectText = "Forja de 100 Bastones"
promptF.KeyboardKeyCode = Enum.KeyCode.E
promptF.HoldDuration = 0
promptF.MaxActivationDistance = 12
promptF.RequiresLineOfSight = false
promptF.Parent = forgePad

createCrispSign(forgeModel, CFrame.new(WEST_X, 11.2, fZ + 4.0), "FORJA REAL", "Forja 100 Bastones Mágicos Únicos", Color3.fromRGB(255, 110, 30))


-- =============================================================================
-- 3. ALTAR DE ENCANTAR: DAIS OCTAGONAL, GRIMORIO FLOTANTE Y CRISTALES ORBITANTES
-- =============================================================================
local enchantModel = Instance.new("Model")
enchantModel.Name = "Station_Encantar"
enchantModel.Parent = stationsFolder
local eZ = 40

-- Rotonda de Mármol y Obsidiana
local rotundaFloor = makePart(enchantModel, "RotundaFloor", Vector3.new(16, 0.8, 16), CFrame.new(WEST_X, 4.8, eZ), Color3.fromRGB(45, 48, 60), Enum.Material.Marble, Enum.PartType.Cylinder)
rotundaFloor.CFrame = rotundaFloor.CFrame * CFrame.Angles(0, 0, math.rad(90))

-- 4 Columnas de Mármol Flanqueando el Altar
for i = 1, 4 do
	local ang = math.rad((i - 1) * 90 + 45)
	local cX = WEST_X + math.cos(ang) * 6.5
	local cZ = eZ + math.sin(ang) * 6.5
	local col = makePart(enchantModel, "MarbleCol_" .. i, Vector3.new(1.4, 8.5, 1.4), CFrame.new(cX, 9.2, cZ), Color3.fromRGB(215, 220, 230), Enum.Material.Marble, Enum.PartType.Cylinder)
	col.CFrame = col.CFrame * CFrame.Angles(0, 0, math.rad(90))
end

-- Cúpula Anular Superior con Glifos Púrpura
local archRing = makePart(enchantModel, "ArchRing", Vector3.new(15, 1.0, 15), CFrame.new(WEST_X, 13.5, eZ), Color3.fromRGB(65, 40, 90), Enum.Material.Marble, Enum.PartType.Cylinder)
archRing.CFrame = archRing.CFrame * CFrame.Angles(0, 0, math.rad(90))

-- Pedestal Central de Obsidiana con Ranuras Rúnicas
local altarPed = makePart(enchantModel, "ObsidianPedestal", Vector3.new(4.2, 3.2, 4.2), CFrame.new(WEST_X, 6.6, eZ), Color3.fromRGB(20, 16, 28), Enum.Material.Slate)
local altarGemPad = makePart(enchantModel, "AltarGemPad", Vector3.new(3.4, 0.3, 3.4), CFrame.new(WEST_X, 8.25, eZ), Color3.fromRGB(180, 50, 255), Enum.Material.Neon)

-- Gran Grimorio Mágico Abierto Flotando en el Centro
local grimoireLeft = makePart(enchantModel, "GrimoirePageL", Vector3.new(1.6, 0.2, 2.2), CFrame.new(WEST_X - 0.7, 9.5, eZ) * CFrame.Angles(0, 0, math.rad(16)), Color3.fromRGB(245, 240, 220), Enum.Material.Fabric)
grimoireLeft.CanCollide = false
local grimoireRight = makePart(enchantModel, "GrimoirePageR", Vector3.new(1.6, 0.2, 2.2), CFrame.new(WEST_X + 0.7, 9.5, eZ) * CFrame.Angles(0, 0, math.rad(-16)), Color3.fromRGB(245, 240, 220), Enum.Material.Fabric)
grimoireRight.CanCollide = false
local grimoireCover = makePart(enchantModel, "GrimoireCover", Vector3.new(3.4, 0.25, 2.3), CFrame.new(WEST_X, 9.35, eZ), Color3.fromRGB(70, 20, 95), Enum.Material.Leather)
grimoireCover.CanCollide = false

-- 4 Cristales Orbitantes de Amatista con Aura
for i = 1, 4 do
	local ang = math.rad((i - 1) * 90)
	local ox = WEST_X + math.cos(ang) * 3.0
	local oz = eZ + math.sin(ang) * 3.0
	local cOrb = makePart(enchantModel, "OrbitCrystal_" .. i, Vector3.new(0.6, 1.5, 0.6), CFrame.new(ox, 9.8, oz) * CFrame.Angles(math.rad(15), ang, math.rad(15)), Color3.fromRGB(210, 75, 255), Enum.Material.Neon)
	cOrb.CanCollide = false
end

-- Brillo de Niebla Arcana
local enLight = Instance.new("PointLight")
enLight.Color = Color3.fromRGB(195, 75, 255)
enLight.Brightness = 3.8
enLight.Range = 18
enLight.Parent = altarGemPad

-- Pad de Interacción
local enchantPad = makePart(enchantModel, "InteractionPad", Vector3.new(5.0, 0.15, 3.5), CFrame.new(WEST_X, 5.25, eZ + 5.0), Color3.fromRGB(185, 55, 255), Enum.Material.Neon)
local promptE = Instance.new("ProximityPrompt")
promptE.ActionText = "Abrir Encantamientos"
promptE.ObjectText = "Altar Rúnico Arcana"
promptE.KeyboardKeyCode = Enum.KeyCode.E
promptE.HoldDuration = 0
promptE.MaxActivationDistance = 12
promptE.RequiresLineOfSight = false
promptE.Parent = enchantPad

createCrispSign(enchantModel, CFrame.new(WEST_X, 11.2, eZ + 4.0), "ALTAR DE ENCANTAR", "Imbuye Runas Mágicas en tu Equipo", Color3.fromRGB(195, 80, 255))


-- =============================================================================
-- 4. SANTUARIO DE MASCOTAS: ARBOLEDA DE LOS ESPÍRITUS (SIN HUEVOS EN LOBBY)
-- =============================================================================
local petModel = Instance.new("Model")
petModel.Name = "Station_Mascotas"
petModel.Parent = stationsFolder
local pZ = 75

-- Terraza Circular de Piedra con Musgo
local petDeck = makePart(petModel, "PetDeck", Vector3.new(16, 0.8, 16), CFrame.new(WEST_X, 4.8, pZ), Color3.fromRGB(35, 45, 38), Enum.Material.Slate, Enum.PartType.Cylinder)
petDeck.CFrame = petDeck.CFrame * CFrame.Angles(0, 0, math.rad(90))

-- Estanque Central de Agua de Maná Turquesa
local pond = makePart(petModel, "ManaPond", Vector3.new(11, 0.25, 11), CFrame.new(WEST_X, 5.25, pZ - 1.0), Color3.fromRGB(0, 220, 180), Enum.Material.Glass, Enum.PartType.Cylinder)
pond.CFrame = pond.CFrame * CFrame.Angles(0, 0, math.rad(90))
pond.Transparency = 0.35

-- Árbol Espiritual Sagrado en el Centro
local trunk = makePart(petModel, "SpiritTree_Trunk", Vector3.new(1.4, 6.5, 1.4), CFrame.new(WEST_X, 8.2, pZ - 1.0), Color3.fromRGB(45, 32, 22), Enum.Material.Wood, Enum.PartType.Cylinder)
trunk.CFrame = trunk.CFrame * CFrame.Angles(0, 0, math.rad(90))

-- Follaje de Nube Brillante
local foliage1 = makePart(petModel, "FoliageCrown", Vector3.new(5.5, 4.0, 5.5), CFrame.new(WEST_X, 12.0, pZ - 1.0), Color3.fromRGB(30, 235, 140), Enum.Material.Neon, Enum.PartType.Ball)
foliage1.CanCollide = false
local foliage2 = makePart(petModel, "FoliageWingL", Vector3.new(3.5, 3.0, 3.5), CFrame.new(WEST_X - 2.5, 10.5, pZ - 1.0), Color3.fromRGB(0, 210, 180), Enum.Material.Neon, Enum.PartType.Ball)
foliage2.CanCollide = false
local foliage3 = makePart(petModel, "FoliageWingR", Vector3.new(3.5, 3.0, 3.5), CFrame.new(WEST_X + 2.5, 10.5, pZ - 1.0), Color3.fromRGB(0, 210, 180), Enum.Material.Neon, Enum.PartType.Ball)
foliage3.CanCollide = false

-- Espíritus Familiares Flotantes (Luces suaves de luciérnaga)
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

-- 3 Cojines Acolchados de Terciopelo para Descanso de Mascotas
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

-- Pad de Interacción
local petPad = makePart(petModel, "InteractionPad", Vector3.new(5.0, 0.15, 3.5), CFrame.new(WEST_X, 5.25, pZ + 5.0), Color3.fromRGB(0, 240, 140), Enum.Material.Neon)
local promptP = Instance.new("ProximityPrompt")
promptP.ActionText = "Ver Mascotas"
promptP.ObjectText = "Santuario de Mascotas"
promptP.KeyboardKeyCode = Enum.KeyCode.E
promptP.HoldDuration = 0
promptP.MaxActivationDistance = 12
promptP.RequiresLineOfSight = false
promptP.Parent = petPad

createCrispSign(petModel, CFrame.new(WEST_X, 11.2, pZ + 4.0), "SANTUARIO DE MASCOTAS", "Equipa y Sube de Nivel a tus Compañeros", Color3.fromRGB(0, 245, 140))

print("[LobbyBuilder] Las 4 Estaciones de Alta Fidelidad han sido construidas exitosamente en la Gran Lobby.")
return "4 High Fidelity Stations Created"
