--!strict
-- Zone1CombatHandler.server.luau
-- Wizard Craft & Combat Simulator
-- ZONA 1 (BOSQUE RÚNICO): Terreno Escalonado con Terrazas, Arroyo de Maná, Puente de Madera, 
-- Hongos Bioluminiscentes, Cristales Gigantes, Lianas, Ruinas Antiguas,
-- y 9 SLIMES ESTILIZADOS 3D (Animaciones fluidas: respiración líquida, salto parabólico squash & stretch,
-- flinch por impacto y explosión de maná al morir).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local StavesData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("StavesData"))

-- RemoteEvents necesarios
local notifyEvent = ReplicatedStorage:FindFirstChild("ShowGameNotification")
if not notifyEvent then
	notifyEvent = Instance.new("RemoteEvent")
	notifyEvent.Name = "ShowGameNotification"
	notifyEvent.Parent = ReplicatedStorage
end

type SlimeType = "Minor" | "Runic" | "Boss"

type SlimeData = {
	Model: Model,
	Body: Part,
	Core: Part,
	Shadow: Part,
	Type: SlimeType,
	CurrentHp: number,
	MaxHp: number,
	BaseSize: Vector3,
	SpawnPos: Vector3,
	HpFill: Frame,
	HpLabel: TextLabel,
	CoinsReward: number,
	WoodReward: number,
	IsAlive: boolean,
	RespawnTime: number,
	OrigColor: Color3,
}

local activeSlimes: { SlimeData } = {}

-- Función para números flotantes en 3D
local function createFloatingNumber(pos: Vector3, text: string, color: Color3)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.CFrame = CFrame.new(pos + Vector3.new(math.random(-2, 2), 2, math.random(-2, 2)))
	part.Parent = Workspace

	local bbg = Instance.new("BillboardGui")
	bbg.Size = UDim2.new(0, 160, 0, 40)
	bbg.AlwaysOnTop = true
	bbg.Adornee = part
	bbg.Parent = part

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 18
	lbl.TextColor3 = color
	lbl.TextStrokeColor3 = Color3.fromRGB(15, 15, 25)
	lbl.TextStrokeTransparency = 0.2
	lbl.Text = text
	lbl.Parent = bbg

	local rise = TweenService:Create(
		part,
		TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CFrame = part.CFrame + Vector3.new(0, 4.5, 0) }
	)
	local fade = TweenService:Create(
		lbl,
		TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ TextTransparency = 1, TextStrokeTransparency = 1 }
	)
	rise:Play()
	fade:Play()
	Debris:AddItem(part, 1.2)
end

--------------------------------------------------------------------------------
-- 1. VERIFICAR O CONSTRUIR ZONA 1 (PRESERVA EN RUNTIME LO CREADO EN STUDIO)
--------------------------------------------------------------------------------
local zoneFolder = Workspace:FindFirstChild("Zone1_BosqueRunico")
if not zoneFolder then
	zoneFolder = Instance.new("Folder")
	zoneFolder.Name = "Zone1_BosqueRunico"
	zoneFolder.Parent = Workspace
end

-- Conectar Barrera hacia Zona 2
local barrierModel = zoneFolder:FindFirstChild("BarrierToZone2")
local forcefield = barrierModel and barrierModel:FindFirstChild("ForcefieldWall") :: BasePart?
if forcefield then
	local debounceTouch: { [number]: boolean } = {}
	forcefield.Touched:Connect(function(hit)
		local char = hit.Parent
		if not char then return end
		local player = Players:GetPlayerFromCharacter(char)
		if not player then return end

		local leaderstats = player:FindFirstChild("leaderstats")
		local poderStat = leaderstats and (leaderstats:FindFirstChild("Poder") or leaderstats:FindFirstChild("Fuerza"))
		local poder = poderStat and poderStat.Value or 0

		if poder >= 100 then
			if not debounceTouch[player.UserId] then
				debounceTouch[player.UserId] = true
				notifyEvent:FireClient(player, "Acceso concedido a la Zona 2! (100+ Poder)", Color3.fromRGB(0, 255, 140))
				task.delay(4, function()
					debounceTouch[player.UserId] = nil
				end)
			end
			local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
			if root and root.Position.Z < 288 then
				root.CFrame = CFrame.new(root.Position.X, root.Position.Y, 296)
			end
		else
			if not debounceTouch[player.UserId] then
				debounceTouch[player.UserId] = true
				notifyEvent:FireClient(player, string.format("Falta Poder! Tienes %d / 100 Poder para cruzar a la Zona 2.", poder), Color3.fromRGB(255, 80, 80))
				local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
				if root then
					root.AssemblyLinearVelocity = Vector3.new(0, 6, -30)
				end
				task.delay(2.5, function()
					debounceTouch[player.UserId] = nil
				end)
			end
		end
	end)
end

-- Conectar Nodos de Madera Arcana
for _, desc in ipairs(zoneFolder:GetDescendants()) do
	if desc:IsA("ProximityPrompt") and desc.ObjectText == "Tronco Sagrado" then
		desc.Triggered:Connect(function(player: Player)
			local mats = player:FindFirstChild("Materiales")
			local madera = mats and mats:FindFirstChild("MaderaArcana") :: NumberValue?
			if madera then
				madera.Value += 3
				notifyEvent:FireClient(player, "Has recolectado +3 Madera Arcana del tronco sagrado!", Color3.fromRGB(100, 255, 140))
			end
			desc.Enabled = false
			local parentPart = desc.Parent :: BasePart?
			local siblingSprout = parentPart and parentPart.Parent and parentPart.Parent:FindFirstChildWhichIsA("BasePart")
			task.delay(6, function()
				desc.Enabled = true
			end)
		end)
	end
end

--------------------------------------------------------------------------------
-- 2. CONTROLADOR DE ANIMACIONES FLUIDAS (SQUASH & STRETCH, HOPPING Y COMBATE)
--------------------------------------------------------------------------------
local function setupSlimeLifecycle(slimeData: SlimeData)
	local body = slimeData.Body
	local shadow = slimeData.Shadow
	local baseSize = slimeData.BaseSize
	local baseW = baseSize.X
	local baseH = baseSize.Y
	local isBoss = (slimeData.Type == "Boss")
	local seed = math.random() * 10

	task.spawn(function()
		while slimeData.Model.Parent do
			-- ANIMACIÓN 1: RESPIRACIÓN LÍQUIDA SUTIL (Idle Jelly Wobble continuo)
			local idleDuration = math.random(22, 38) / 10
			local elapsed = 0
			while elapsed < idleDuration do
				task.wait(0.08)
				elapsed += 0.08
				if slimeData.IsAlive and body.Parent then
					local wobble = math.sin((os.clock() * 3.6) + seed) * 0.07
					body.Size = Vector3.new(baseW * (1 + wobble), baseH * (1 - wobble), baseW * (1 + wobble))
				end
			end

			if not slimeData.IsAlive or not body.Parent then
				task.wait(0.5)
				continue
			end

			-- ANIMACIÓN 2: SALTO PARABÓLICO ORGÁNICO CON SQUASH & STRETCH
			local radius = if isBoss then 7 else 12
			local offset = Vector3.new(math.random(-radius, radius), 0, math.random(-radius, radius))
			local targetGround = slimeData.SpawnPos + offset + Vector3.new(0, baseH / 2 + 0.3, 0)
			local currentPos = body.Position

			local lookCf = CFrame.lookAt(currentPos, Vector3.new(targetGround.X, currentPos.Y, targetGround.Z))
			body.CFrame = lookCf

			-- FASE A: ANTICIPACIÓN (Comprime el cuerpo contra el piso)
			local tPrep = TweenService:Create(body, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = Vector3.new(baseW * 1.35, baseH * 0.65, baseW * 1.35),
				CFrame = lookCf * CFrame.new(0, -(baseH * 0.18), 0),
			})
			tPrep:Play()
			tPrep.Completed:Wait()

			if not slimeData.IsAlive then continue end

			-- FASE B: VUELO PARABÓLICO (Estiramiento vertical elástico)
			local hopHeight = if isBoss then 3.6 else 2.8
			local midPoint = (currentPos + targetGround) / 2 + Vector3.new(0, hopHeight, 0)
			local midCf = CFrame.lookAt(midPoint, Vector3.new(targetGround.X, midPoint.Y, targetGround.Z))

			TweenService:Create(shadow, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(midPoint.X, slimeData.SpawnPos.Y + 0.05, midPoint.Z) * CFrame.Angles(0, 0, math.rad(90)),
				Size = Vector3.new(0.08, baseW * 0.65, baseW * 0.65),
			}):Play()

			local tAir = TweenService:Create(body, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = midCf,
				Size = Vector3.new(baseW * 0.8, baseH * 1.45, baseW * 0.8),
			})
			tAir:Play()
			tAir.Completed:Wait()

			if not slimeData.IsAlive then continue end

			-- FASE C: ATERRIZAJE E IMPACTO APLASTADO (Squash amplio)
			local landCf = CFrame.lookAt(targetGround, Vector3.new(targetGround.X + lookCf.LookVector.X, targetGround.Y, targetGround.Z + lookCf.LookVector.Z))

			TweenService:Create(shadow, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				CFrame = CFrame.new(targetGround.X, slimeData.SpawnPos.Y + 0.05, targetGround.Z) * CFrame.Angles(0, 0, math.rad(90)),
				Size = Vector3.new(0.08, baseW * 1.35, baseW * 1.35),
			}):Play()

			local tLand = TweenService:Create(body, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				CFrame = landCf * CFrame.new(0, -(baseH * 0.2), 0),
				Size = Vector3.new(baseW * 1.4, baseH * 0.6, baseW * 1.4),
			})
			tLand:Play()
			tLand.Completed:Wait()

			if not slimeData.IsAlive then continue end

			-- FASE D: REBOTE ELÁSTICO FINAL ANTES DE IDLE
			local tRebound = TweenService:Create(body, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = landCf,
				Size = baseSize,
			})
			tRebound:Play()
			tRebound.Completed:Wait()
		end
	end)
end

--------------------------------------------------------------------------------
-- 3. DAÑO, FLINCH POR IMPACTO Y RECOMPENSAS
--------------------------------------------------------------------------------
local function damageSlime(slime: SlimeData, player: Player, damage: number)
	if not slime.IsAlive then return end

	slime.CurrentHp = math.clamp(slime.CurrentHp - damage, 0, slime.MaxHp)
	local hpPct = slime.CurrentHp / slime.MaxHp

	slime.HpFill.Size = UDim2.new(hpPct, 0, 1, 0)
	slime.HpLabel.Text = string.format("%d / %d HP", slime.CurrentHp, slime.MaxHp)

	createFloatingNumber(slime.Body.Position, "-" .. tostring(math.floor(damage)), Color3.fromRGB(255, 75, 75))

	-- ANIMACIÓN 3: REACCIÓN AL GOLPE (Flinch Wobble + Flash Blanco/Rojo)
	slime.Body.Color = Color3.fromRGB(255, 120, 120)
	local tFlinch = TweenService:Create(slime.Body, TweenInfo.new(0.09, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		Size = Vector3.new(slime.BaseSize.X * 1.25, slime.BaseSize.Y * 0.75, slime.BaseSize.X * 1.25),
	})
	tFlinch:Play()

	task.delay(0.12, function()
		if slime.IsAlive then
			slime.Body.Color = slime.OrigColor
			TweenService:Create(slime.Body, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = slime.BaseSize,
			}):Play()
		end
	end)

	if slime.CurrentHp <= 0 then
		slime.IsAlive = false

		local coinsReward = slime.CoinsReward
		local woodReward = slime.WoodReward

		local leaderstats = player:FindFirstChild("leaderstats")
		local monedas = leaderstats and leaderstats:FindFirstChild("Monedas") :: NumberValue?
		if monedas then
			monedas.Value += coinsReward
		end

		local materiales = player:FindFirstChild("Materiales")
		local madera = materiales and materiales:FindFirstChild("MaderaArcana") :: NumberValue?
		if madera then
			madera.Value += woodReward
		end

		createFloatingNumber(slime.Body.Position + Vector3.new(0, 2, 0), string.format("+%d Monedas", coinsReward), Color3.fromRGB(255, 215, 0))
		createFloatingNumber(slime.Body.Position + Vector3.new(0, 4, 0), string.format("+%d Madera Arcana", woodReward), Color3.fromRGB(100, 255, 140))

		local defeatMsg = if slime.Type == "Boss"
			then string.format("👑 HAS DERROTADO AL REY SLIME ALFA! +%d Monedas | +%d Madera Arcana", coinsReward, woodReward)
			else string.format("Slime derrotado! +%d Monedas | +%d Madera Arcana", coinsReward, woodReward)

		notifyEvent:FireClient(player, defeatMsg, if slime.Type == "Boss" then Color3.fromRGB(255, 215, 0) else Color3.fromRGB(120, 255, 180))

		-- Probabilidad de drop de huevo raro en zona (3.5% normales, 35% Boss)
		if typeof(_G.TryDropMonsterEgg) == "function" then
			_G.TryDropMonsterEgg(slime.Body.Position, slime.Type == "Boss")
		end

		-- ANIMACIÓN 4: EXPLOSIÓN DE POP & SPLAT
		local tPop = TweenService:Create(slime.Body, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = slime.BaseSize * 1.5,
			Transparency = 0.9,
		})
		tPop:Play()
		tPop.Completed:Wait()

		for _, part in ipairs(slime.Model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 1
			elseif part:IsA("BillboardGui") then
				part.Enabled = false
			elseif part:IsA("ParticleEmitter") then
				part.Enabled = false
			end
		end

		-- RESPAWN MÁGICO
		task.delay(slime.RespawnTime, function()
			slime.CurrentHp = slime.MaxHp
			slime.HpFill.Size = UDim2.new(1, 0, 1, 0)
			slime.HpLabel.Text = string.format("%d / %d HP", slime.MaxHp, slime.MaxHp)

			for _, part in ipairs(slime.Model:GetDescendants()) do
				if part:IsA("BasePart") then
					if part.Name == "SlimeBody" then
						part.Transparency = 0.28
						part.Color = slime.OrigColor
						part.Size = slime.BaseSize
						part.CFrame = CFrame.new(slime.SpawnPos + Vector3.new(0, slime.BaseSize.Y / 2 + 0.3, 0))
					elseif part.Name == "Shadow" then
						part.Transparency = 0.55
						part.CFrame = CFrame.new(slime.SpawnPos.X, slime.SpawnPos.Y + 0.05, slime.SpawnPos.Z) * CFrame.Angles(0, 0, math.rad(90))
					else
						part.Transparency = 0
					end
				elseif part:IsA("BillboardGui") then
					part.Enabled = true
				elseif part:IsA("ParticleEmitter") then
					part.Enabled = true
				end
			end
			slime.IsAlive = true
		end)
	end
end

--------------------------------------------------------------------------------
-- 4. DISPARO MÁGICO Y PROYECTILES DEL JUGADOR
--------------------------------------------------------------------------------
local function castMagicAttack(player: Player, slime: SlimeData)
	local char = player.Character
	if not char then return end

	local staffId = player:GetAttribute("BastonEquipado")
	local staffConfig = StavesData.getStaff(staffId)

	local startPos = slime.Body.Position
	local equippedStaff = char:FindFirstChild("EquippedStaff")
	local castPoint = equippedStaff and equippedStaff:FindFirstChild("CastPoint", true) :: Attachment?
	if castPoint then
		startPos = castPoint.WorldPosition
	else
		local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") :: BasePart?
		if rightHand then
			startPos = rightHand.Position + Vector3.new(0, 0.5, 0)
		end
	end

	local targetPos = slime.Body.Position

	if staffConfig.ProjectileType == "Beam" or staffConfig.ProjectileType == "Lightning" then
		local beamPart = Instance.new("Part")
		beamPart.Anchored = true
		beamPart.CanCollide = false
		beamPart.Transparency = 1
		beamPart.Size = Vector3.new(0.4, 0.4, 0.4)
		beamPart.CFrame = CFrame.new(startPos)
		beamPart.Parent = Workspace

		local att0 = Instance.new("Attachment")
		att0.Parent = beamPart

		local att1 = Instance.new("Attachment")
		att1.WorldPosition = targetPos
		att1.Parent = slime.Body

		local beam = Instance.new("Beam")
		beam.Attachment0 = att0
		beam.Attachment1 = att1
		beam.Color = ColorSequence.new(staffConfig.ProjectileColor, staffConfig.GlowColor)
		beam.Width0 = 1.3
		beam.Width1 = 2.2
		beam.Texture = "rbxassetid://477143964"
		beam.TextureSpeed = 12
		beam.TextureLength = 3
		beam.Parent = beamPart

		local flash = Instance.new("PointLight")
		flash.Color = staffConfig.ProjectileColor
		flash.Brightness = 4
		flash.Range = 18
		flash.Parent = slime.Body

		Debris:AddItem(flash, 0.16)
		Debris:AddItem(att1, 0.18)
		Debris:AddItem(beamPart, 0.18)
	else
		local orb = Instance.new("Part")
		orb.Name = "MagicOrb"
		orb.Shape = Enum.PartType.Ball
		orb.Size = Vector3.new(1.5, 1.5, 1.5)
		orb.Color = staffConfig.ProjectileColor
		orb.Material = Enum.Material.Neon
		orb.Anchored = true
		orb.CanCollide = false
		orb.CFrame = CFrame.new(startPos)
		orb.Parent = Workspace

		local light = Instance.new("PointLight")
		light.Color = staffConfig.ProjectileColor
		light.Brightness = 3
		light.Range = 15
		light.Parent = orb

		local fly = TweenService:Create(
			orb,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = CFrame.new(targetPos) }
		)
		fly:Play()
		fly.Completed:Connect(function()
			local burst = Instance.new("Part")
			burst.Shape = Enum.PartType.Ball
			burst.Size = Vector3.new(1.8, 1.8, 1.8)
			burst.Color = staffConfig.ProjectileColor
			burst.Material = Enum.Material.Neon
			burst.Anchored = true
			burst.CanCollide = false
			burst.CFrame = CFrame.new(targetPos)
			burst.Parent = Workspace

			TweenService:Create(
				burst,
				TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = Vector3.new(5.5, 5.5, 5.5), Transparency = 1 }
			):Play()
			Debris:AddItem(burst, 0.2)
			orb:Destroy()
		end)
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local poderStat = leaderstats and (leaderstats:FindFirstChild("Poder") or leaderstats:FindFirstChild("Fuerza"))
	local poder = poderStat and poderStat.Value or 0
	local damage = staffConfig.Damage + math.floor(poder / 20)

	damageSlime(slime, player, damage)
end

--------------------------------------------------------------------------------
-- 5. RECONOCER Y VINCULAR LOS SLIMES EN EL WORKSPACE
--------------------------------------------------------------------------------
local mobsFolder = zoneFolder:FindFirstChild("ForestMobs")
if mobsFolder then
	for _, m in ipairs(mobsFolder:GetChildren()) do
		if m:IsA("Model") and m.Name:find("Slime") then
			local body = m:FindFirstChild("SlimeBody") :: Part?
			local core = m:FindFirstChild("Manacore") :: Part?
			local shadow = m:FindFirstChild("Shadow") :: Part?
			local hGui = m:FindFirstChild("HealthGui") :: BillboardGui?
			local hpFill = hGui and hGui:FindFirstChild("HpFill", true) :: Frame?
			local hpTxt = hGui and hGui:FindFirstChild("HpText", true) :: TextLabel?

			if body and core and shadow and hpFill and hpTxt then
				local isBoss = m.Name:find("Boss") ~= nil
				local isRunic = m.Name:find("Runic") ~= nil
				local sType: SlimeType = if isBoss then "Boss" elseif isRunic then "Runic" else "Minor"

				local maxHp = if isBoss then 150 elseif isRunic then 60 else 30
				local coinsReward = if isBoss then 45 elseif isRunic then 15 else 6
				local woodReward = if isBoss then 12 elseif isRunic then 5 else 2

				local sData: SlimeData = {
					Model = m,
					Body = body,
					Core = core,
					Shadow = shadow,
					Type = sType,
					CurrentHp = maxHp,
					MaxHp = maxHp,
					BaseSize = body.Size,
					SpawnPos = shadow.Position,
					HpFill = hpFill,
					HpLabel = hpTxt,
					CoinsReward = coinsReward,
					WoodReward = woodReward,
					IsAlive = true,
					RespawnTime = if isBoss then 5.0 else 3.5,
					OrigColor = body.Color,
				}

				table.insert(activeSlimes, sData)
				setupSlimeLifecycle(sData)

				-- ClickDetector directo sobre el Slime
				local cd = body:FindFirstChildOfClass("ClickDetector") or Instance.new("ClickDetector")
				cd.MaxActivationDistance = 28
				cd.Parent = body
				cd.MouseClick:Connect(function(player: Player)
					local char = player.Character
					if not char then return end
					local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
					if not root then return end

					local dist = (root.Position - body.Position).Magnitude
					if dist <= 42 then
						castMagicAttack(player, sData)
					end
				end)
			end
		end
	end
end

-- Conectar DoClick (Ataque automático al slime más cercano en Zona 1)
local doClickEvent = ReplicatedStorage:WaitForChild("DoClick", 10)
if doClickEvent and doClickEvent:IsA("RemoteEvent") then
	doClickEvent.OnServerEvent:Connect(function(player: Player)
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not root then return end

		if root.Position.Z >= 122 then
			local nearestSlime: SlimeData? = nil
			local minDist = 40

			for _, slime in ipairs(activeSlimes) do
				if slime.IsAlive then
					local dist = (root.Position - slime.Body.Position).Magnitude
					if dist < minDist then
						minDist = dist
						nearestSlime = slime
					end
				end
			end

			if nearestSlime then
				castMagicAttack(player, nearestSlime)
			end
		end
	end)
end

print(string.format("[Zone1CombatHandler] Vinculados %d Slimes con animaciones de física líquida y combate listos.", #activeSlimes))
