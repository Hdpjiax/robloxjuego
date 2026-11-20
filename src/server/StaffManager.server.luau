--!strict
-- StaffManager.server.luau
-- Wizard Craft & Combat Simulator
-- Sistema Maestro de los 100 Bastones Arcanos: Construcción 3D Procedural,
-- Forja Alquímica con Animación en el Mundo (Crisol + Yunque) y Equipamiento.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local StavesData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("StavesData"))

-- RemoteEvents para forjar y equipar bastones
local craftStaffEvent = ReplicatedStorage:FindFirstChild("CraftStaff") or Instance.new("RemoteEvent")
craftStaffEvent.Name = "CraftStaff"
craftStaffEvent.Parent = ReplicatedStorage

local forgeRandomStaffEvent = ReplicatedStorage:FindFirstChild("ForgeRandomStaff") or Instance.new("RemoteEvent")
forgeRandomStaffEvent.Name = "ForgeRandomStaff"
forgeRandomStaffEvent.Parent = ReplicatedStorage

local forgeVisualEvent = ReplicatedStorage:FindFirstChild("ForgeStaffVisualEffect") or Instance.new("RemoteEvent")
forgeVisualEvent.Name = "ForgeStaffVisualEffect"
forgeVisualEvent.Parent = ReplicatedStorage

local forgeResultEvent = ReplicatedStorage:FindFirstChild("ForgeResult") or Instance.new("RemoteEvent")
forgeResultEvent.Name = "ForgeResult"
forgeResultEvent.Parent = ReplicatedStorage

local equipStaffEvent = ReplicatedStorage:FindFirstChild("EquipStaff") or Instance.new("RemoteEvent")
equipStaffEvent.Name = "EquipStaff"
equipStaffEvent.Parent = ReplicatedStorage

local notifyEvent = ReplicatedStorage:FindFirstChild("ShowGameNotification") or Instance.new("RemoteEvent")
notifyEvent.Name = "ShowGameNotification"
notifyEvent.Parent = ReplicatedStorage

--------------------------------------------------------------------------------
-- CONSTRUCCIÓN PROCEDURAL DE ALTO DETALLE DE CUALQUIERA DE LOS 100 BASTONES
--------------------------------------------------------------------------------
local function createStaffModel(staffConfig: any): Model
	local staffModel = Instance.new("Model")
	staffModel.Name = "EquippedStaff"
	staffModel:SetAttribute("StaffId", staffConfig.Id)
	staffModel:SetAttribute("Rarity", staffConfig.Rarity)

	local mDesign = staffConfig.ModelDesign or {}
	local staffLength = mDesign.ShaftLength or 5.2

	-- 1. ROOT HANDLE (Parte invisible base para el Motor6D de la mano)
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 0.4, 0.4)
	handle.Transparency = 1
	handle.CanCollide = false
	handle.CanTouch = false
	handle.CanQuery = false
	handle.Massless = true
	handle.Anchored = false
	handle.Parent = staffModel
	staffModel.PrimaryPart = handle

	-- 2. VARA MAESTRA (Cilindro vertical perfecto)
	local shaft = Instance.new("Part")
	shaft.Name = "Shaft"
	shaft.Shape = Enum.PartType.Cylinder
	shaft.Size = Vector3.new(staffLength, 0.36, 0.36)
	shaft.CFrame = handle.CFrame * CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, math.rad(90))
	shaft.Color = mDesign.ShaftColor or Color3.fromRGB(68, 42, 28)
	shaft.Material = mDesign.ShaftMaterial or Enum.Material.WoodPlanks
	shaft.CanCollide = false
	shaft.CanTouch = false
	shaft.CanQuery = false
	shaft.Massless = true
	shaft.Anchored = false
	shaft.Parent = staffModel

	local wShaft = Instance.new("WeldConstraint")
	wShaft.Part0 = handle
	wShaft.Part1 = shaft
	wShaft.Parent = handle

	-- 3. EMPUÑADURA DE CUERO (Grip Wrap en el punto de agarre de la mano)
	local grip = Instance.new("Part")
	grip.Name = "GripWrap"
	grip.Shape = Enum.PartType.Cylinder
	grip.Size = Vector3.new(1.3, 0.44, 0.44)
	grip.CFrame = handle.CFrame * CFrame.Angles(0, 0, math.rad(90))
	grip.Color = Color3.fromRGB(36, 26, 20)
	grip.Material = Enum.Material.Fabric
	grip.CanCollide = false
	grip.CanTouch = false
	grip.CanQuery = false
	grip.Massless = true
	grip.Anchored = false
	grip.Parent = staffModel

	local wGrip = Instance.new("WeldConstraint")
	wGrip.Part0 = handle
	wGrip.Part1 = grip
	wGrip.Parent = handle

	-- Anillos de oro que delimitan la empuñadura
	for _, yOff in ipairs({ 0.68, -0.68 }) do
		local ring = Instance.new("Part")
		ring.Shape = Enum.PartType.Cylinder
		ring.Size = Vector3.new(0.12, 0.48, 0.48)
		ring.CFrame = handle.CFrame * CFrame.new(0, yOff, 0) * CFrame.Angles(0, 0, math.rad(90))
		ring.Color = Color3.fromRGB(240, 200, 50)
		ring.Material = Enum.Material.Metal
		ring.CanCollide = false
		ring.CanTouch = false
		ring.CanQuery = false
		ring.Massless = true
		ring.Anchored = false
		ring.Parent = staffModel

		local wRing = Instance.new("WeldConstraint")
		wRing.Part0 = handle
		wRing.Part1 = ring
		wRing.Parent = handle
	end

	-- 4. REMATE INFERIOR (Pommel con gema resonadora)
	local pommel = Instance.new("Part")
	pommel.Name = "Pommel"
	pommel.Shape = Enum.PartType.Ball
	pommel.Size = Vector3.new(0.62, 0.62, 0.62)
	pommel.CFrame = handle.CFrame * CFrame.new(0, -(staffLength / 2) + 0.35, 0)
	pommel.Color = Color3.fromRGB(220, 185, 50)
	pommel.Material = Enum.Material.Metal
	pommel.CanCollide = false
	pommel.CanTouch = false
	pommel.CanQuery = false
	pommel.Massless = true
	pommel.Anchored = false
	pommel.Parent = staffModel

	local wPommel = Instance.new("WeldConstraint")
	wPommel.Part0 = handle
	wPommel.Part1 = pommel
	wPommel.Parent = handle

	local pommelGem = Instance.new("Part")
	pommelGem.Shape = Enum.PartType.Ball
	pommelGem.Size = Vector3.new(0.36, 0.36, 0.36)
	pommelGem.CFrame = pommel.CFrame * CFrame.new(0, -0.30, 0)
	pommelGem.Color = mDesign.GemColor or staffConfig.ProjectileColor or Color3.fromRGB(0, 235, 255)
	pommelGem.Material = Enum.Material.Neon
	pommelGem.CanCollide = false
	pommelGem.CanTouch = false
	pommelGem.CanQuery = false
	pommelGem.Massless = true
	pommelGem.Anchored = false
	pommelGem.Parent = staffModel

	local wPGem = Instance.new("WeldConstraint")
	wPGem.Part0 = handle
	wPGem.Part1 = pommelGem
	wPGem.Parent = handle

	-- 5. CABEZAL SUPERIOR Y CORONA DE GARRAS / ALAS
	local headBase = Instance.new("Part")
	headBase.Name = "StaffHeadBase"
	headBase.Shape = Enum.PartType.Cylinder
	headBase.Size = Vector3.new(0.42, 0.8, 0.8)
	headBase.CFrame = handle.CFrame * CFrame.new(0, (staffLength / 2) + 0.72, 0) * CFrame.Angles(0, 0, math.rad(90))
	headBase.Color = Color3.fromRGB(245, 210, 55)
	headBase.Material = Enum.Material.Metal
	headBase.CanCollide = false
	headBase.CanTouch = false
	headBase.CanQuery = false
	headBase.Massless = true
	headBase.Anchored = false
	headBase.Parent = staffModel

	local wHead = Instance.new("WeldConstraint")
	wHead.Part0 = handle
	wHead.Part1 = headBase
	wHead.Parent = handle

	local prongCount = mDesign.ProngCount or 4
	for i = 1, prongCount do
		local ang = math.rad((i - 1) * (360 / prongCount))
		local claw = Instance.new("Part")
		claw.Size = Vector3.new(0.2, 1.25, 0.2)
		claw.Color = Color3.fromRGB(230, 195, 45)
		claw.Material = Enum.Material.Metal
		claw.CanCollide = false
		claw.CanTouch = false
		claw.CanQuery = false
		claw.Massless = true
		claw.Anchored = false
		claw.CFrame = handle.CFrame * CFrame.new(0, (staffLength / 2) + 1.2, 0)
			* CFrame.Angles(0, ang, 0)
			* CFrame.new(0.42, 0, 0)
			* CFrame.Angles(0, 0, math.rad(-15))
		claw.Parent = staffModel

		local wClaw = Instance.new("WeldConstraint")
		wClaw.Part0 = handle
		wClaw.Part1 = claw
		wClaw.Parent = handle
	end

	-- 6. GRAN NÚCLEO DE CRISTAL FLOTANTE (Arcanum Core)
	local gem = Instance.new("Part")
	gem.Name = "CoreGem"
	gem.Shape = mDesign.GemShape or Enum.PartType.Ball
	gem.Size = Vector3.new(1.25, 1.25, 1.25)
	gem.Color = mDesign.GemColor or staffConfig.ProjectileColor or Color3.fromRGB(0, 240, 255)
	gem.Material = mDesign.GemMaterial or Enum.Material.Neon
	gem.CanCollide = false
	gem.CanTouch = false
	gem.CanQuery = false
	gem.Massless = true
	gem.Anchored = false
	gem.CFrame = handle.CFrame * CFrame.new(0, (staffLength / 2) + 1.35, 0)
	gem.Parent = staffModel

	local wGem = Instance.new("WeldConstraint")
	wGem.Part0 = handle
	wGem.Part1 = gem
	wGem.Parent = handle

	local gemLight = Instance.new("PointLight")
	gemLight.Color = staffConfig.ProjectileColor or Color3.fromRGB(0, 240, 255)
	gemLight.Brightness = 3.2
	gemLight.Range = 16
	gemLight.Parent = gem

	-- Partículas de aura mística
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Name = "StaffAura"
	sparkle.Color = ColorSequence.new(staffConfig.ProjectileColor or Color3.fromRGB(0, 240, 255), staffConfig.GlowColor or Color3.fromRGB(255, 255, 255))
	sparkle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.45),
		NumberSequenceKeypoint.new(1, 0.05),
	})
	sparkle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 1),
	})
	sparkle.Lifetime = NumberRange.new(0.7, 1.4)
	sparkle.Speed = NumberRange.new(0.4, 1.5)
	sparkle.Rate = 14
	sparkle.Parent = gem

	-- 7. HALO RÚNICO ORBITAL (Anillo giratorio)
	local ringCount = mDesign.OrbitRings or 1
	if ringCount > 0 then
		local halo = Instance.new("Part")
		halo.Name = "OrbitRing"
		halo.Shape = Enum.PartType.Cylinder
		halo.Size = Vector3.new(0.08, 1.9, 1.9)
		halo.CFrame = gem.CFrame * CFrame.Angles(math.rad(25), 0, math.rad(90))
		halo.Color = staffConfig.GlowColor or Color3.fromRGB(60, 255, 240)
		halo.Material = Enum.Material.Neon
		halo.Transparency = 0.35
		halo.CanCollide = false
		halo.CanTouch = false
		halo.CanQuery = false
		halo.Massless = true
		halo.Anchored = false
		halo.Parent = staffModel

		local wHalo = Instance.new("WeldConstraint")
		wHalo.Part0 = handle
		wHalo.Part1 = halo
		wHalo.Parent = handle
	end

	-- 8. PUNTO DE DISPARO EXACTO (CastPoint en la cúspide)
	local castPoint = Instance.new("Attachment")
	castPoint.Name = "CastPoint"
	castPoint.Position = Vector3.new(0, 0.85, 0)
	castPoint.Parent = gem

	-- Blindaje de propiedades físicas
	for _, p in ipairs(staffModel:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
			p.Massless = true
			p.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
		end
	end

	return staffModel
end

--------------------------------------------------------------------------------
-- EQUIPAR BASTÓN AL PERSONAJE (MEDIANTE MOTOR6D EN RIGHTHAND)
--------------------------------------------------------------------------------
local function equipStaffToCharacter(player: Player, character: Model)
	local oldStaff = character:FindFirstChild("EquippedStaff")
	if oldStaff then
		oldStaff:Destroy()
	end

	local staffId = player:GetAttribute("BastonEquipado") or "VaraDeAprendiz"
	local staffConfig = StavesData.getStaff(staffId)
	if not staffConfig then
		staffConfig = StavesData.getStaff("VaraDeAprendiz")
	end
	if not staffConfig then return end

	local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not rightHand then return end

	local staffModel = createStaffModel(staffConfig)
	local handle = staffModel.PrimaryPart :: BasePart

	staffModel.Parent = character

	local weld = Instance.new("Motor6D")
	weld.Name = "StaffGrip"
	weld.Part0 = rightHand
	weld.Part1 = handle
	weld.C0 = CFrame.new(0, -0.15, -0.05) * CFrame.Angles(math.rad(-10), math.rad(0), math.rad(0))
	weld.C1 = CFrame.new(0, 0, 0)
	weld.Parent = rightHand
end

-- Escuchar personajes que entran o reaparecen
Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(char: Model)
		task.wait(0.3)
		equipStaffToCharacter(player, char)
	end)

	player:GetAttributeChangedSignal("BastonEquipado"):Connect(function()
		local char = player.Character
		if char then
			equipStaffToCharacter(player, char)
		end
	end)

	if player.Character then
		equipStaffToCharacter(player, player.Character)
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		equipStaffToCharacter(player, player.Character)
	end
end

--------------------------------------------------------------------------------
-- SISTEMA DE FORJA ALEATORIA DE BASTONES (CON CINEMÁTICA 3D Y 100 BASTONES)
--------------------------------------------------------------------------------
forgeRandomStaffEvent.OnServerEvent:Connect(function(player: Player, woodInvested: number?, crystalInvested: number?)
	local wood = woodInvested or 10
	local crystal = crystalInvested or 3

	local mats = player:FindFirstChild("Materiales")
	local madera = mats and mats:FindFirstChild("MaderaArcana") :: NumberValue?
	local cristal = mats and mats:FindFirstChild("CristalCeleste") :: NumberValue?

	local userWood = madera and madera.Value or 0
	local userCrystal = cristal and cristal.Value or 0

	if userWood < wood then
		notifyEvent:FireClient(player, "¡Necesitas al menos " .. wood .. " Madera Arcana para alimentar la Forja!", Color3.fromRGB(255, 80, 80))
		return
	end
	if crystal > 0 and userCrystal < crystal then
		notifyEvent:FireClient(player, "¡No tienes suficientes Cristales Celestes (" .. crystal .. ")!", Color3.fromRGB(255, 80, 80))
		return
	end

	-- Descontar materiales
	if madera then madera.Value -= wood end
	if crystal > 0 and cristal then cristal.Value -= crystal end

	-- Tirada aleatoria del nuevo bastón entre los 100 bastones
	local staff = StavesData.rollRandomStaff(wood, crystal)

	-- Guardar en el inventario de bastones del jugador
	local owned = player:GetAttribute("OwnedStaves") or "VaraDeAprendiz"
	if not string.find(owned, staff.Id) then
		owned = owned .. "," .. staff.Id
		player:SetAttribute("OwnedStaves", owned)
	end

	-- Localizar el Horno y el Yunque en el Lobby
	local stationForja = Workspace:FindFirstChild("Lobby")
		and Workspace.Lobby:FindFirstChild("PhysicalLobbyStations")
		and Workspace.Lobby.PhysicalLobbyStations:FindFirstChild("Station_Forja")

	local anvil = stationForja and stationForja:FindFirstChild("AnvilBody")
	local lava = stationForja and stationForja:FindFirstChild("LavaCore")

	local anvilPos = anvil and anvil.Position or Vector3.new(-45, 7.6, 11)
	local lavaPos = lava and lava.Position or Vector3.new(-45, 6.8, 6.6)

	-- 1. Efecto visual 3D global en la forja para todos los jugadores
	forgeVisualEvent:FireAllClients(player, staff, anvilPos, lavaPos)

	-- 2. Enviar resultado al cliente para el reveal modal
	forgeResultEvent:FireClient(player, staff)

	-- 3. Anuncio especial si es Legendario o Mítico
	if staff.Rarity == "Legendario" or staff.Rarity == "Mitico" then
		notifyEvent:FireAllClients(
			string.format("⚡ ¡HAZAÑA DE FORJA! %s ha forjado el legendario: %s [%s] (+x%.1f Poder)!", player.Name, staff.Name, staff.Rarity, staff.PowerMultiplier),
			staff.RarityColor
		)
	else
		notifyEvent:FireClient(
			player,
			string.format("¡FORJASTE: %s [%s]! (Mult: x%.1f | Daño: %d)", staff.Name, staff.Rarity, staff.PowerMultiplier, staff.Damage),
			staff.RarityColor
		)
	end
end)

--------------------------------------------------------------------------------
-- EQUIPAR CUALQUIER BASTÓN POSEÍDO
--------------------------------------------------------------------------------
equipStaffEvent.OnServerEvent:Connect(function(player: Player, staffId: string)
	local staffConfig = StavesData.getStaff(staffId)
	if not staffConfig then return end

	local owned = player:GetAttribute("OwnedStaves") or "VaraDeAprendiz"
	if staffId ~= "VaraDeAprendiz" and not string.find(owned, staffId) then
		notifyEvent:FireClient(player, "¡Aún no has forjado este bastón!", Color3.fromRGB(255, 80, 80))
		return
	end

	player:SetAttribute("BastonEquipado", staffConfig.Id)
	player:SetAttribute("BastonesEquipado", staffConfig.Name)

	local char = player.Character
	if char then
		equipStaffToCharacter(player, char)
	end

	notifyEvent:FireClient(player, "Bastón Equipado: " .. staffConfig.Name .. " (" .. staffConfig.Rarity .. ")", staffConfig.RarityColor)
end)

print("[StaffManager] Sistema Maestro de 100 Bastones Arcanos con Forja 3D Procedural inicializado.")
