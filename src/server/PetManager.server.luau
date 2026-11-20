--!strict
-- PetManager.server.luau
-- Wizard Craft & Combat Simulator
-- Sistema Completo de Mascotas: Huevos Raros en Zonas de Combate, Inventario y Eclosión en Santuario

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Eventos Remotos
local notifyEvent = ReplicatedStorage:FindFirstChild("ShowGameNotification")
if not notifyEvent then
	notifyEvent = Instance.new("RemoteEvent")
	notifyEvent.Name = "ShowGameNotification"
	notifyEvent.Parent = ReplicatedStorage
end

local petEvent = ReplicatedStorage:FindFirstChild("PetAction")
if not petEvent then
	petEvent = Instance.new("RemoteEvent")
	petEvent.Name = "PetAction"
	petEvent.Parent = ReplicatedStorage
end

-- Catálogo de Mascotas
export type PetDef = {
	Id: string,
	Name: string,
	Rarity: "Común" | "Raro" | "Épico" | "Legendario",
	Multiplier: number,
	Color: Color3,
	AccentColor: Color3,
	Weight: number, -- Probabilidad relativa de eclosión
}

local PETS_CATALOG: { [string]: PetDef } = {
	["SlimeBebe"] = {
		Id = "SlimeBebe",
		Name = "Slime Bebé Rúnico",
		Rarity = "Común",
		Multiplier = 1.25, -- +25% Poder
		Color = Color3.fromRGB(0, 240, 160),
		AccentColor = Color3.fromRGB(255, 255, 255),
		Weight = 55,
	},
	["BuhoRunico"] = {
		Id = "BuhoRunico",
		Name = "Búho Rúnico Místico",
		Rarity = "Raro",
		Multiplier = 1.50, -- +50% Poder
		Color = Color3.fromRGB(0, 200, 255),
		AccentColor = Color3.fromRGB(255, 215, 60),
		Weight = 30,
	},
	["GolemCristal"] = {
		Id = "GolemCristal",
		Name = "Mini Golem de Cristal",
		Rarity = "Épico",
		Multiplier = 2.00, -- +100% Poder (x2.0)
		Color = Color3.fromRGB(180, 80, 255),
		AccentColor = Color3.fromRGB(0, 240, 255),
		Weight = 12,
	},
	["FenixArcano"] = {
		Id = "FenixArcano",
		Name = "Fénix de Fuego Arcana",
		Rarity = "Legendario",
		Multiplier = 3.50, -- +250% Poder (x3.5)
		Color = Color3.fromRGB(255, 80, 20),
		AccentColor = Color3.fromRGB(255, 230, 80),
		Weight = 3,
	},
}

local activePetModels: { [number]: Model } = {}
local playerPets: { [number]: { [string]: boolean } } = {}

--------------------------------------------------------------------------------
-- CONSTRUCCIÓN Y SEGUIMIENTO FÍSICO SEGURO DE MASCOTAS
--------------------------------------------------------------------------------
local function buildPetVisualModel(pet: PetDef): Model
	local model = Instance.new("Model")
	model.Name = "ActivePet_" .. pet.Id

	local body = Instance.new("Part")
	body.Name = "PetBody"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(1.6, 1.6, 1.6)
	body.Color = pet.Color
	body.Material = Enum.Material.Neon
	body.CanCollide = false
	body.CanTouch = false
	body.CanQuery = false
	body.Massless = true
	body.CastShadow = false
	body.CustomPhysicalProperties = PhysicalProperties.new(0.001, 0, 0, 0, 0)
	body.Parent = model
	model.PrimaryPart = body

	-- Ojos expresivos
	for _, xSide in ipairs({ -0.32, 0.32 }) do
		local eye = Instance.new("Part")
		eye.Shape = Enum.PartType.Ball
		eye.Size = Vector3.new(0.35, 0.35, 0.35)
		eye.Color = Color3.fromRGB(20, 20, 25)
		eye.Material = Enum.Material.SmoothPlastic
		eye.CanCollide = false
		eye.CanTouch = false
		eye.Massless = true
		eye.CFrame = body.CFrame * CFrame.new(xSide, 0.15, -0.7)
		eye.Parent = model

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = body
		weld.Part1 = eye
		weld.Parent = body
	end

	-- Halo orbital
	local halo = Instance.new("Part")
	halo.Shape = Enum.PartType.Cylinder
	halo.Size = Vector3.new(0.06, 2.2, 2.2)
	halo.CFrame = body.CFrame * CFrame.Angles(math.rad(25), 0, math.rad(90))
	halo.Color = pet.AccentColor
	halo.Material = Enum.Material.Neon
	halo.Transparency = 0.4
	halo.CanCollide = false
	halo.CanTouch = false
	halo.Massless = true
	halo.Parent = model

	local weldH = Instance.new("WeldConstraint")
	weldH.Part0 = body
	weldH.Part1 = halo
	weldH.Parent = body

	-- Luz y aura
	local light = Instance.new("PointLight")
	light.Color = pet.Color
	light.Brightness = 1.8
	light.Range = 10
	light.Parent = body

	-- Cartel con nombre y multiplicador
	local bbg = Instance.new("BillboardGui")
	bbg.Size = UDim2.new(0, 160, 0, 40)
	bbg.StudsOffset = Vector3.new(0, 1.8, 0)
	bbg.AlwaysOnTop = false
	bbg.LightInfluence = 0
	bbg.MaxDistance = 35
	bbg.Adornee = body
	bbg.Parent = model

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(1, 0, 0.55, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.Text = pet.Name
	nameLbl.TextColor3 = pet.Color
	nameLbl.TextSize = 13
	nameLbl.Parent = bbg

	local multLbl = Instance.new("TextLabel")
	multLbl.Position = UDim2.new(0, 0, 0.5, 0)
	multLbl.Size = UDim2.new(1, 0, 0.5, 0)
	multLbl.BackgroundTransparency = 1
	multLbl.Font = Enum.Font.GothamBlack
	multLbl.Text = string.format("⚡ +%.0f%% PODER (x%.2f)", (pet.Multiplier - 1) * 100, pet.Multiplier)
	multLbl.TextColor3 = Color3.fromRGB(255, 225, 60)
	multLbl.TextSize = 11
	multLbl.Parent = bbg

	return model
end

local function equipPet(player: Player, petId: string)
	local pet = PETS_CATALOG[petId]
	if not pet then return end

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return end

	if activePetModels[player.UserId] then
		activePetModels[player.UserId]:Destroy()
		activePetModels[player.UserId] = nil
	end

	local petModel = buildPetVisualModel(pet)
	local body = petModel.PrimaryPart :: BasePart

	body.CFrame = hrp.CFrame * CFrame.new(3.5, 2.0, 3.0)
	petModel.Parent = char
	activePetModels[player.UserId] = petModel

	-- Fijación suave con AlignPosition y AlignOrientation sin fuerzas de reacción
	local attPlayer = Instance.new("Attachment")
	attPlayer.Name = "PetFollowAttachment"
	attPlayer.Position = Vector3.new(3.2, 1.8, 2.6)
	attPlayer.Parent = hrp

	local attPet = Instance.new("Attachment")
	attPet.Name = "PetCenterAttachment"
	attPet.Parent = body

	local alignPos = Instance.new("AlignPosition")
	alignPos.Mode = Enum.PositionAlignmentMode.TwoAttachment
	alignPos.Attachment0 = attPet
	alignPos.Attachment1 = attPlayer
	alignPos.MaxForce = 6000
	alignPos.Responsiveness = 18
	alignPos.ReactionForceEnabled = false
	alignPos.Parent = body

	local alignRot = Instance.new("AlignOrientation")
	alignRot.Mode = Enum.OrientationAlignmentMode.TwoAttachment
	alignRot.Attachment0 = attPet
	alignRot.Attachment1 = attPlayer
	alignRot.MaxTorque = 3000
	alignRot.Responsiveness = 14
	alignRot.ReactionTorqueEnabled = false
	alignRot.Parent = body

	player:SetAttribute("PetMultiplier", pet.Multiplier)
	player:SetAttribute("MascotaEquipada", pet.Name)

	notifyEvent:FireClient(
		player,
		string.format("¡Mascota Equipada: %s! Multiplicador activo: x%.2f", pet.Name, pet.Multiplier),
		pet.Color
	)
end

--------------------------------------------------------------------------------
-- ECLOSIÓN DE HUEVO EN EL SANTUARIO
--------------------------------------------------------------------------------
local function hatchEggForPlayer(player: Player)
	local mats = player:FindFirstChild("Materiales")
	local huevos = mats and mats:FindFirstChild("HuevosRaros") :: NumberValue?
	local curEggs = huevos and huevos.Value or (player:GetAttribute("HuevosRaros") or 0)

	if curEggs <= 0 then
		notifyEvent:FireClient(
			player,
			"¡No tienes Huevos Raros! Explora el Bosque Rúnico y derrota slimes para encontrarlos.",
			Color3.fromRGB(255, 90, 90)
		)
		return
	end

	-- Consumir 1 huevo
	if huevos then
		huevos.Value -= 1
	else
		player:SetAttribute("HuevosRaros", curEggs - 1)
	end

	-- Selección ponderada
	local totalWeight = 0
	for _, p in pairs(PETS_CATALOG) do
		totalWeight += p.Weight
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	local chosenPet: PetDef = PETS_CATALOG["SlimeBebe"]

	for _, p in pairs(PETS_CATALOG) do
		cumulative += p.Weight
		if roll <= cumulative then
			chosenPet = p
			break
		end
	end

	equipPet(player, chosenPet.Id)

	notifyEvent:FireClient(
		player,
		string.format("✨ ¡ECLOSIÓN EXITOSA! Obtuviste: %s [%s] (+%.0f%% Poder)", chosenPet.Name, chosenPet.Rarity, (chosenPet.Multiplier - 1) * 100),
		Color3.fromRGB(255, 215, 0)
	)
end

--------------------------------------------------------------------------------
-- SPAWNER DE HUEVOS RAROS EXCLUSIVAMENTE EN ZONAS DE AVENTURA (CERO EN LOBBY)
--------------------------------------------------------------------------------
local eggsFolder = Instance.new("Folder")
eggsFolder.Name = "RareEggsWorld"
eggsFolder.Parent = Workspace

local ZONE1_EGG_SPOTS = {
	Vector3.new(24, 4.2, 175),   -- Rincón este del Bosque Rúnico
	Vector3.new(-24, 4.2, 215),  -- Junto a los cristales del arroyo
	Vector3.new(18, 5.2, 255),   -- Cerca de la arena del Jefe Slime
}

local MAX_WILD_EGGS = 1

local function spawnWorldEgg(pos: Vector3, isMonsterDrop: boolean?)
	if #eggsFolder:GetChildren() >= MAX_WILD_EGGS then return end

	local egg = Instance.new("Part")
	egg.Name = "RareEgg"
	egg.Shape = Enum.PartType.Ball
	egg.Size = Vector3.new(2.4, 3.2, 2.4)
	egg.CFrame = CFrame.new(pos)
	egg.Anchored = true
	egg.CanCollide = true
	egg.Color = Color3.fromRGB(255, 215, 60)
	egg.Material = Enum.Material.Neon
	egg.Parent = eggsFolder

	-- Haz de luz vertical celestial
	local beam = Instance.new("Part")
	beam.Name = "BeaconBeam"
	beam.Shape = Enum.PartType.Cylinder
	beam.Size = Vector3.new(40, 0.45, 0.45)
	beam.CFrame = egg.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(0, 0, math.rad(90))
	beam.Anchored = true
	beam.CanCollide = false
	beam.Color = Color3.fromRGB(255, 230, 90)
	beam.Material = Enum.Material.Neon
	beam.Transparency = 0.4
	beam.Parent = egg

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 215, 60)
	light.Brightness = 3.5
	light.Range = 22
	light.Parent = egg

	local bbg = Instance.new("BillboardGui")
	bbg.Size = UDim2.new(0, 200, 0, 48)
	bbg.StudsOffset = Vector3.new(0, 3.0, 0)
	bbg.AlwaysOnTop = true
	bbg.LightInfluence = 0
	bbg.MaxDistance = 55
	bbg.Adornee = egg
	bbg.Parent = egg

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 14
	lbl.TextColor3 = Color3.fromRGB(255, 235, 120)
	lbl.TextStrokeColor3 = Color3.fromRGB(20, 20, 20)
	lbl.TextStrokeTransparency = 0
	lbl.Text = "[ ¡HUEVO MÍSTICO RARO! ]"
	lbl.Parent = bbg

	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "Huevo Místico Raro"
	prompt.ActionText = "Recoger Huevo"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 14
	prompt.Parent = egg

	local msg = if isMonsterDrop
		then "¡Un monstruo ha soltado un misterioso Huevo de Criatura en el Bosque!"
		else "¡Un Huevo Místico Raro ha caído en las profundidades del Bosque Rúnico!"
	notifyEvent:FireAllClients(msg, Color3.fromRGB(255, 225, 80))

	local isCollected = false
	prompt.Triggered:Connect(function(player: Player)
		if isCollected then return end
		isCollected = true

		local mats = player:FindFirstChild("Materiales")
		local huevos = mats and mats:FindFirstChild("HuevosRaros") :: NumberValue?
		if huevos then
			huevos.Value += 1
		else
			local cur = player:GetAttribute("HuevosRaros") or 0
			player:SetAttribute("HuevosRaros", cur + 1)
		end

		notifyEvent:FireClient(
			player,
			"🥚 ¡Recogiste un Huevo Místico Raro! Llévalo al Santuario de Mascotas en el Lobby para eclosionarlo.",
			Color3.fromRGB(255, 215, 60)
		)

		task.wait(0.2)
		egg:Destroy()
	end)

	-- Si nadie lo reclama en 3 minutos, desaparece
	task.delay(180, function()
		if egg and egg.Parent and not isCollected then
			egg:Destroy()
		end
	end)
end

_G.TryDropMonsterEgg = function(dropPos: Vector3, isBoss: boolean?)
	if #eggsFolder:GetChildren() >= MAX_WILD_EGGS then return end
	local chance = if isBoss then 0.35 else 0.035
	if math.random() <= chance then
		spawnWorldEgg(dropPos + Vector3.new(0, 1.2, 0), true)
	end
end

-- Bucle de aparición periódica rara en el Bosque (cada 5 a 8 minutos)
task.spawn(function()
	while true do
		task.wait(math.random(300, 480))
		if #eggsFolder:GetChildren() < MAX_WILD_EGGS then
			local targetSpot = ZONE1_EGG_SPOTS[math.random(1, #ZONE1_EGG_SPOTS)]
			spawnWorldEgg(targetSpot, false)
		end
	end
end)

--------------------------------------------------------------------------------
-- RECONEXIÓN Y MANEJO DE JUGADORES
--------------------------------------------------------------------------------
Players.PlayerAdded:Connect(function(player: Player)
	playerPets[player.UserId] = {}

	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local curPet = player:GetAttribute("MascotaEquipada")
		for _, pet in pairs(PETS_CATALOG) do
			if pet.Name == curPet then
				equipPet(player, pet.Id)
				break
			end
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	if activePetModels[player.UserId] then
		activePetModels[player.UserId]:Destroy()
		activePetModels[player.UserId] = nil
	end
	playerPets[player.UserId] = nil
end)

petEvent.OnServerEvent:Connect(function(player: Player, action: string, petId: string?)
	if action == "Hatch" then
		hatchEggForPlayer(player)
	elseif action == "Equip" and petId then
		equipPet(player, petId)
	end
end)

print("[PetManager] Sistema de Mascotas corregido: Huevos raros solo en zonas, recogida en mochila y eclosión en santuario.")
