--!strict
-- Forge3DAnimationController.client.luau
-- Wizard Craft & Combat Simulator
-- Controlador de la Cinemática 3D de Forja en el Mundo y Reveal Modal en Pantalla

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local localPlayer = Players.LocalPlayer

-- RemoteEvents
local forgeVisualEvent = ReplicatedStorage:WaitForChild("ForgeStaffVisualEffect", 10) :: RemoteEvent?
local forgeResultEvent = ReplicatedStorage:WaitForChild("ForgeResult", 10) :: RemoteEvent?
local equipStaffEvent = ReplicatedStorage:WaitForChild("EquipStaff", 10) :: RemoteEvent?

--------------------------------------------------------------------------------
-- HELPER: INTERPOLACIÓN CUADRÁTICA BEZIER PARA EL TIRO DE MATERIALES
--------------------------------------------------------------------------------
local function quadraticBezier(p0: Vector3, p1: Vector3, p2: Vector3, t: number): Vector3
	local l1 = p0:Lerp(p1, t)
	local l2 = p1:Lerp(p2, t)
	return l1:Lerp(l2, t)
end

--------------------------------------------------------------------------------
-- CINEMÁTICA 3D DE LA FORJA EN EL MUNDO
--------------------------------------------------------------------------------
local function play3DForgeSequence(player: Player, staffConfig: any, anvilPos: Vector3, lavaPos: Vector3)
	local char = player.Character
	local startPos = if char and char.PrimaryPart then char.PrimaryPart.Position + Vector3.new(0, 1.5, 0) else (lavaPos + Vector3.new(0, 5, 8))

	-- FASE 1: LANZAMIENTO PARABÓLICO DE MATERIALES AL CRISOL (0.0s - 0.7s)
	local materialTypes = {
		{ Name = "Madera", Color = Color3.fromRGB(110, 70, 40), Mat = Enum.Material.Wood, Size = Vector3.new(0.7, 1.2, 0.7) },
		{ Name = "Cristal", Color = Color3.fromRGB(0, 240, 255), Mat = Enum.Material.Neon, Size = Vector3.new(0.8, 0.8, 0.8) },
		{ Name = "Gelatina", Color = Color3.fromRGB(40, 255, 120), Mat = Enum.Material.Glass, Size = Vector3.new(0.8, 0.8, 0.8) },
	}

	for i, mInfo in ipairs(materialTypes) do
		task.delay((i - 1) * 0.12, function()
			local matPart = Instance.new("Part")
			matPart.Name = "ForgeMaterialOrb_" .. mInfo.Name
			matPart.Size = mInfo.Size
			matPart.Color = mInfo.Color
			matPart.Material = mInfo.Mat
			matPart.CanCollide = false
			matPart.CanTouch = false
			matPart.CanQuery = false
			matPart.Anchored = true
			matPart.CFrame = CFrame.new(startPos)
			matPart.Parent = Workspace

			local p0 = startPos
			local p1 = (p0 + lavaPos) / 2 + Vector3.new(0, 5.5, 0)
			local p2 = lavaPos + Vector3.new(math.random(-1, 1) * 0.5, 0.3, math.random(-1, 1) * 0.5)

			local elapsed = 0
			local dur = 0.55
			while elapsed < dur do
				local dt = task.wait()
				elapsed += dt
				local t = math.clamp(elapsed / dur, 0, 1)
				local curPos = quadraticBezier(p0, p1, p2, t)
				matPart.CFrame = CFrame.new(curPos) * CFrame.Angles(elapsed * 8, elapsed * 6, 0)
			end

			-- Impacto en la lava: salpicadura y chispas
			local splashLight = Instance.new("PointLight")
			splashLight.Color = Color3.fromRGB(255, 120, 20)
			splashLight.Brightness = 6.0
			splashLight.Range = 14
			splashLight.Parent = matPart

			TweenService:Create(matPart, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.zero,
				Transparency = 1,
			}):Play()
			Debris:AddItem(matPart, 0.2)
		end)
	end

	-- FASE 2: ERUPCIÓN DEL CRISOL Y VAPOR (0.7s)
	task.delay(0.65, function()
		local flare = Instance.new("Part")
		flare.Shape = Enum.PartType.Ball
		flare.Size = Vector3.new(3, 3, 3)
		flare.CFrame = CFrame.new(lavaPos + Vector3.new(0, 1, 0))
		flare.Color = Color3.fromRGB(255, 140, 20)
		flare.Material = Enum.Material.Neon
		flare.CanCollide = false
		flare.Anchored = true
		flare.Parent = Workspace

		local flareLight = Instance.new("PointLight")
		flareLight.Color = Color3.fromRGB(255, 140, 20)
		flareLight.Brightness = 8.0
		flareLight.Range = 22
		flareLight.Parent = flare

		TweenService:Create(flare, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(7, 7, 7),
			Transparency = 1,
		}):Play()
		Debris:AddItem(flare, 0.45)
	end)

	-- FASE 3: MARTILLO DE HERRERO ENCANTADO GOLPEANDO EL YUNQUE (1.1s - 2.1s)
	task.delay(1.0, function()
		local hammerModel = Instance.new("Model")
		hammerModel.Name = "AnimatedForgeHammer"
		hammerModel.Parent = Workspace

		local hHandle = Instance.new("Part")
		hHandle.Size = Vector3.new(0.3, 3.2, 0.3)
		hHandle.Color = Color3.fromRGB(60, 42, 28)
		hHandle.Material = Enum.Material.Wood
		hHandle.CanCollide = false
		hHandle.Anchored = true
		hHandle.Parent = hammerModel

		local hHead = Instance.new("Part")
		hHead.Size = Vector3.new(1.4, 0.9, 0.9)
		hHead.Color = Color3.fromRGB(255, 180, 50)
		hHead.Material = Enum.Material.Neon
		hHead.CanCollide = false
		hHead.Anchored = true
		hHead.Parent = hammerModel

		local hLight = Instance.new("PointLight")
		hLight.Color = Color3.fromRGB(255, 180, 50)
		hLight.Brightness = 3.5
		hLight.Range = 14
		hLight.Parent = hHead

		local strikeY = anvilPos.Y + 0.5
		local restY = anvilPos.Y + 3.2

		local function updateHammer(yPos: number, rotDeg: number)
			hHead.CFrame = CFrame.new(anvilPos.X, yPos, anvilPos.Z) * CFrame.Angles(math.rad(rotDeg), 0, 0)
			hHandle.CFrame = hHead.CFrame * CFrame.new(0, 1.4, 0)
		end

		updateHammer(restY, -35)

		-- 3 Golpes rítmicos: CLANG! CLANG! CLANG!
		for strike = 1, 3 do
			task.delay((strike - 1) * 0.32, function()
				-- Golpe hacia abajo
				local tDown = 0.10
				local el = 0
				while el < tDown do
					local dt = task.wait()
					el += dt
					local progress = el / tDown
					updateHammer(restY + (strikeY - restY) * progress, -35 * (1 - progress))
				end
				updateHammer(strikeY, 0)

				-- Chispas y onda expansiva de forja
				local spark = Instance.new("Part")
				spark.Shape = Enum.PartType.Ball
				spark.Size = Vector3.new(1.8, 0.2, 1.8)
				spark.CFrame = CFrame.new(anvilPos + Vector3.new(0, 0.4, 0))
				spark.Color = Color3.fromRGB(255, 230, 90)
				spark.Material = Enum.Material.Neon
				spark.CanCollide = false
				spark.Anchored = true
				spark.Parent = Workspace

				TweenService:Create(spark, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(4.5, 0.05, 4.5),
					Transparency = 1,
				}):Play()
				Debris:AddItem(spark, 0.2)

				-- Rebote suave
				task.wait(0.04)
				updateHammer(restY, -35)
			end)
		end

		task.delay(1.1, function()
			hammerModel:Destroy()
		end)
	end)

	-- FASE 4: ASCENSIÓN DEL BASTÓN FORJADO FLOTANDO SOBRE EL YUNQUE (2.2s - 4.5s)
	task.delay(2.2, function()
		local previewStaff = Instance.new("Part")
		previewStaff.Name = "ForgedStaffPreview"
		previewStaff.Shape = Enum.PartType.Cylinder
		previewStaff.Size = Vector3.new(5.0, 0.45, 0.45)
		previewStaff.CFrame = CFrame.new(anvilPos + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		previewStaff.Color = staffConfig.RarityColor or Color3.fromRGB(255, 215, 60)
		previewStaff.Material = Enum.Material.Neon
		previewStaff.CanCollide = false
		previewStaff.Anchored = true
		previewStaff.Parent = Workspace

		-- Núcleo de gema flotante
		local pGem = Instance.new("Part")
		pGem.Shape = Enum.PartType.Ball
		pGem.Size = Vector3.new(1.4, 1.4, 1.4)
		pGem.CFrame = previewStaff.CFrame * CFrame.new(2.7, 0, 0)
		pGem.Color = staffConfig.GlowColor or staffConfig.RarityColor
		pGem.Material = Enum.Material.Neon
		pGem.CanCollide = false
		pGem.Anchored = true
		pGem.Parent = previewStaff

		-- Haz de luz vertical celestial
		local beam = Instance.new("Part")
		beam.Shape = Enum.PartType.Cylinder
		beam.Size = Vector3.new(35, 0.6, 0.6)
		beam.CFrame = previewStaff.CFrame * CFrame.new(2.7, 17.5, 0) * CFrame.Angles(0, 0, math.rad(90))
		beam.Color = staffConfig.RarityColor
		beam.Material = Enum.Material.Neon
		beam.Transparency = 0.5
		beam.CanCollide = false
		beam.Anchored = true
		beam.Parent = previewStaff

		local light = Instance.new("PointLight")
		light.Color = staffConfig.RarityColor
		light.Brightness = 4.5
		light.Range = 22
		light.Parent = pGem

		-- Elevar suavemente 3.8 studs
		local targetCFrame = CFrame.new(anvilPos + Vector3.new(0, 3.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
		TweenService:Create(previewStaff, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = targetCFrame,
		}):Play()

		-- Rotación continua elegante por 3 segundos
		local rotateConnection: RBXScriptConnection?
		local tStart = tick()
		rotateConnection = game:GetService("RunService").RenderStepped:Connect(function()
			if not previewStaff or not previewStaff.Parent then
				if rotateConnection then rotateConnection:Disconnect() end
				return
			end
			local el = tick() - tStart
			previewStaff.CFrame = CFrame.new(anvilPos + Vector3.new(0, 3.8 + math.sin(el * 3) * 0.25, 0))
				* CFrame.Angles(0, el * 2.5, math.rad(90))
			pGem.CFrame = previewStaff.CFrame * CFrame.new(2.7, 0, 0)
		end)

		-- Desvanecimiento suave
		task.delay(4.5, function()
			if rotateConnection then rotateConnection:Disconnect() end
			TweenService:Create(previewStaff, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
			}):Play()
			TweenService:Create(pGem, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
			}):Play()
			Debris:AddItem(previewStaff, 0.7)
		end)
	end)
end

if forgeVisualEvent then
	forgeVisualEvent.OnClientEvent:Connect(play3DForgeSequence)
end

--------------------------------------------------------------------------------
-- REVEAL MODAL CELEBRATORIO EN PANTALLA (GACHA CARD)
--------------------------------------------------------------------------------
local function showForgeRevealModal(staffConfig: any)
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local screenGui = playerGui:FindFirstChild("MainScreenGui") or Instance.new("ScreenGui")
	screenGui.Name = "MainScreenGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local overlay = Instance.new("Frame")
	overlay.Name = "ForgeRevealOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(6, 8, 16)
	overlay.BackgroundTransparency = 0.35
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 80
	overlay.Parent = screenGui

	local card = Instance.new("Frame")
	card.Name = "RevealCard"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Size = UDim2.new(0, 480, 0, 380)
	card.Position = UDim2.new(0.5, 0, 0.5, 0)
	card.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.ZIndex = 81
	card.Parent = overlay

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 16)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Thickness = 3
	cardStroke.Color = staffConfig.RarityColor or Color3.fromRGB(255, 215, 60)
	cardStroke.Parent = card

	-- Header / Rarity Badge
	local badge = Instance.new("TextLabel")
	badge.Size = UDim2.new(1, -40, 0, 36)
	badge.Position = UDim2.new(0, 20, 0, 20)
	badge.BackgroundColor3 = Color3.fromRGB(28, 34, 52)
	badge.Text = string.format("✦ ¡NUEVO BASTÓN %s! ✦", string.upper(staffConfig.Rarity))
	badge.Font = Enum.Font.GothamBlack
	badge.TextSize = 16
	badge.TextColor3 = staffConfig.RarityColor
	badge.ZIndex = 82
	badge.Parent = card

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 8)
	badgeCorner.Parent = badge

	local badgeStroke = Instance.new("UIStroke")
	badgeStroke.Thickness = 1.8
	badgeStroke.Color = staffConfig.RarityColor
	badgeStroke.Parent = badge

	-- Staff Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -40, 0, 38)
	nameLabel.Position = UDim2.new(0, 20, 0, 68)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.Text = staffConfig.Name
	nameLabel.TextSize = 24
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.ZIndex = 82
	nameLabel.Parent = card

	-- Stats Box
	local statsBox = Instance.new("Frame")
	statsBox.Size = UDim2.new(1, -40, 0, 95)
	statsBox.Position = UDim2.new(0, 20, 0, 116)
	statsBox.BackgroundColor3 = Color3.fromRGB(24, 28, 44)
	statsBox.BorderSizePixel = 0
	statsBox.ZIndex = 82
	statsBox.Parent = card

	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(0, 10)
	sCorner.Parent = statsBox

	local statPower = Instance.new("TextLabel")
	statPower.Size = UDim2.new(1, -20, 0, 28)
	statPower.Position = UDim2.new(0, 10, 0, 8)
	statPower.BackgroundTransparency = 1
	statPower.Font = Enum.Font.GothamBold
	statPower.Text = string.format("⚡ MULTIPLICADOR DE PODER: +x%.1f", staffConfig.PowerMultiplier)
	statPower.TextColor3 = Color3.fromRGB(0, 240, 255)
	statPower.TextSize = 15
	statPower.TextXAlignment = Enum.TextXAlignment.Left
	statPower.ZIndex = 83
	statPower.Parent = statsBox

	local statDamage = Instance.new("TextLabel")
	statDamage.Size = UDim2.new(1, -20, 0, 26)
	statDamage.Position = UDim2.new(0, 10, 0, 36)
	statDamage.BackgroundTransparency = 1
	statDamage.Font = Enum.Font.GothamBold
	statDamage.Text = string.format("🗡️ DAÑO EN COMBATE: %d", staffConfig.Damage)
	statDamage.TextColor3 = Color3.fromRGB(255, 120, 120)
	statDamage.TextSize = 15
	statDamage.TextXAlignment = Enum.TextXAlignment.Left
	statDamage.ZIndex = 83
	statDamage.Parent = statsBox

	local loreLabel = Instance.new("TextLabel")
	loreLabel.Size = UDim2.new(1, -20, 0, 24)
	loreLabel.Position = UDim2.new(0, 10, 0, 64)
	loreLabel.BackgroundTransparency = 1
	loreLabel.Font = Enum.Font.GothamMedium
	loreLabel.Text = staffConfig.Description or "Forjado con esencias arcanas en la Forja Real."
	loreLabel.TextColor3 = Color3.fromRGB(180, 190, 210)
	loreLabel.TextSize = 12
	loreLabel.TextXAlignment = Enum.TextXAlignment.Left
	loreLabel.ZIndex = 83
	loreLabel.Parent = statsBox

	-- Botón Equipar Ahora
	local equipBtn = Instance.new("TextButton")
	equipBtn.Size = UDim2.new(0, 210, 0, 48)
	equipBtn.Position = UDim2.new(0, 20, 0, 305)
	equipBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	equipBtn.Text = "⚡ EQUIPAR AHORA"
	equipBtn.Font = Enum.Font.GothamBlack
	equipBtn.TextSize = 15
	equipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	equipBtn.ZIndex = 82
	equipBtn.Parent = card

	local eqCorner = Instance.new("UICorner")
	eqCorner.CornerRadius = UDim.new(0, 10)
	eqCorner.Parent = equipBtn

	equipBtn.MouseButton1Click:Connect(function()
		if equipStaffEvent then
			equipStaffEvent:FireServer(staffConfig.Id)
		end
		overlay:Destroy()
	end)

	-- Botón Guardar en Mochila
	local saveBtn = Instance.new("TextButton")
	saveBtn.Size = UDim2.new(0, 210, 0, 48)
	saveBtn.Position = UDim2.new(1, -230, 0, 305)
	saveBtn.BackgroundColor3 = Color3.fromRGB(45, 52, 70)
	saveBtn.Text = "GUARDAR EN MOCHILA"
	saveBtn.Font = Enum.Font.GothamBold
	saveBtn.TextSize = 14
	saveBtn.TextColor3 = Color3.fromRGB(220, 225, 240)
	saveBtn.ZIndex = 82
	saveBtn.Parent = card

	local svCorner = Instance.new("UICorner")
	svCorner.CornerRadius = UDim.new(0, 10)
	svCorner.Parent = saveBtn

	saveBtn.MouseButton1Click:Connect(function()
		overlay:Destroy()
	end)

	-- Animación de entrada de la tarjeta
	card.Size = UDim2.new(0, 360, 0, 280)
	TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 480, 0, 380),
	}):Play()
end

if forgeResultEvent then
	forgeResultEvent.OnClientEvent:Connect(function(staffConfig)
		task.wait(2.2) -- Esperar a que la cinemática de martillo termine
		showForgeRevealModal(staffConfig)
	end)
end

print("[Forge3DAnimationController] Sistema de Cinemáticas 3D de Forja y Reveal Modal activo.")
