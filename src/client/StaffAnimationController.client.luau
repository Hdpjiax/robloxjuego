--!strict
-- StaffAnimationController.client.luau
-- Wizard Craft & Combat Simulator
-- Controlador de cinemática ultra fluida para el Bastón Arcano Principal:
-- 1. CAMINATA NATURAL Y FLUIDA: Interpolación continua (damped lerp) en todas las articulaciones,
--    inclinación suave del torso, contrapeso orgánico del brazo izquierdo y balanceo rítmico del bastón sin tirones.
-- 2. REPOSO NOBLE (IDLE): Respiración rítmica sutil, postura de hechicero alerta con el báculo erguido.
-- 3. ANIMACIÓN DE DISPARO DINÁMICO (Smooth 4-Phase Cast):
--    - Fase 1 (Carga fluida): Elevación elegante del bastón, torsión del torso y canalización rúnica.
--    - Fase 2 (Proyección Explosiva): Destello mágico en CastPoint, disparo de proyectil con estela brillante.
--    - Fase 3 (Absorción de Retroceso): Onda de dispersión y recuperación elástica.
--    - Fase 4 (Blend de retorno): Transición suave hacia la postura actual (caminar o reposo).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function smoothstep(t: number): number
	t = math.clamp(t, 0, 1)
	return t * t * (3 - 2 * t)
end

local function easeOutQuad(t: number): number
	t = math.clamp(t, 0, 1)
	return 1 - (1 - t) * (1 - t)
end

local isCasting = false
local castTime = 0
local CAST_DURATION = 0.38
local hasFiredProjectileThisCast = false

-- Estados interpolados para evitar cualquier salto o tosquedad
local curWaist = CFrame.identity
local curNeck = CFrame.identity
local curRightShoulder = CFrame.identity
local curRightElbow = CFrame.identity
local curRightWrist = CFrame.identity
local curLeftShoulder = CFrame.identity
local curLeftElbow = CFrame.identity
local curStaffGrip = CFrame.identity

--------------------------------------------------------------------------------
-- DISPARAR PROYECTIL VISUAL CLIENTE DESDE EL CASTPOINT
--------------------------------------------------------------------------------
local function spawnShootingProjectile(origin: Vector3, direction: Vector3)
	-- 1. Destello Muzzle Flash en la punta del bastón
	local flash = Instance.new("Part")
	flash.Shape = Enum.PartType.Ball
	flash.Size = Vector3.new(1.8, 1.8, 1.8)
	flash.CFrame = CFrame.new(origin)
	flash.Color = Color3.fromRGB(80, 240, 255)
	flash.Material = Enum.Material.Neon
	flash.Anchored = true
	flash.CanCollide = false
	flash.Parent = Workspace

	local flLight = Instance.new("PointLight")
	flLight.Color = Color3.fromRGB(0, 240, 255)
	flLight.Brightness = 4.5
	flLight.Range = 16
	flLight.Parent = flash

	TweenService:Create(flash, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(4.2, 4.2, 4.2),
		Transparency = 1,
	}):Play()
	Debris:AddItem(flash, 0.14)

	-- 2. Orbe de Maná volador con Trail resplandeciente
	local bolt = Instance.new("Part")
	bolt.Name = "ArcaneCastBolt"
	bolt.Shape = Enum.PartType.Ball
	bolt.Size = Vector3.new(1.2, 1.2, 1.2)
	bolt.CFrame = CFrame.new(origin)
	bolt.Color = Color3.fromRGB(0, 230, 255)
	bolt.Material = Enum.Material.Neon
	bolt.Anchored = true
	bolt.CanCollide = false
	bolt.Parent = Workspace

	local bLight = Instance.new("PointLight")
	bLight.Color = Color3.fromRGB(0, 240, 255)
	bLight.Brightness = 3.5
	bLight.Range = 14
	bLight.Parent = bolt

	local att0 = Instance.new("Attachment")
	att0.Position = Vector3.new(0, 0.4, 0)
	att0.Parent = bolt

	local att1 = Instance.new("Attachment")
	att1.Position = Vector3.new(0, -0.4, 0)
	att1.Parent = bolt

	local trail = Instance.new("Trail")
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 160, 255)),
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.Lifetime = 0.22
	trail.Parent = bolt

	local targetPos = origin + (direction.Unit * 52)
	local flyTween = TweenService:Create(bolt, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(targetPos),
	})
	flyTween:Play()

	flyTween.Completed:Connect(function()
		local impact = Instance.new("Part")
		impact.Shape = Enum.PartType.Ball
		impact.Size = Vector3.new(1.8, 1.8, 1.8)
		impact.CFrame = CFrame.new(targetPos)
		impact.Color = Color3.fromRGB(70, 255, 240)
		impact.Material = Enum.Material.Neon
		impact.Anchored = true
		impact.CanCollide = false
		impact.Parent = Workspace

		TweenService:Create(impact, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(5.5, 5.5, 5.5),
			Transparency = 1,
		}):Play()
		Debris:AddItem(impact, 0.18)
		bolt:Destroy()
	end)
end

-- Función pública para activar el lanzamiento mágico
local function triggerCast()
	isCasting = true
	castTime = 0
	hasFiredProjectileThisCast = false
end

_G.PlayStaffCast = triggerCast

local doClickEvent = ReplicatedStorage:WaitForChild("DoClick", 10)
if doClickEvent and doClickEvent:IsA("RemoteEvent") then
	doClickEvent.OnClientEvent:Connect(function()
		triggerCast()
	end)
end

--------------------------------------------------------------------------------
-- CICLO PRINCIPAL DE RENDER STEPPED (CON DAMPED LERP CONTINUO)
--------------------------------------------------------------------------------
local function onRenderStep(dt: number)
	local char = player.Character
	if not char then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local rightShoulder = char:FindFirstChild("RightShoulder", true) :: Motor6D?
	local rightElbow = char:FindFirstChild("RightElbow", true) :: Motor6D?
	local rightWrist = char:FindFirstChild("RightWrist", true) :: Motor6D?
	local leftShoulder = char:FindFirstChild("LeftShoulder", true) :: Motor6D?
	local leftElbow = char:FindFirstChild("LeftElbow", true) :: Motor6D?
	local waist = char:FindFirstChild("Waist", true) :: Motor6D?
	local neck = char:FindFirstChild("Neck", true) :: Motor6D?

	local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
	local staffGrip = rightHand and rightHand:FindFirstChild("StaffGrip") :: Motor6D?
	if not staffGrip then return end

	local staffModel = char:FindFirstChild("EquippedStaff")
	local castPoint = staffModel and staffModel:FindFirstChild("CastPoint", true) :: Attachment?

	local clock = os.clock()
	local isMoving = humanoid.MoveDirection.Magnitude > 0.08

	-- Objetivos de postura calculados en cada frame
	local targetWaist = CFrame.identity
	local targetNeck = CFrame.identity
	local targetRightShoulder = CFrame.identity
	local targetRightElbow = CFrame.identity
	local targetRightWrist = CFrame.identity
	local targetLeftShoulder = CFrame.identity
	local targetLeftElbow = CFrame.identity
	local targetStaffGrip = CFrame.identity

	if isCasting then
		castTime += dt
		local t = math.clamp(castTime / CAST_DURATION, 0, 1)

		if t < 0.24 then
			-- FASE 1: CARGA DE PODER RÁPIDA (0.0s -> 0.09s)
			local subT = smoothstep(t / 0.24)
			targetWaist = CFrame.Angles(math.rad(-3 * subT), math.rad(-14 * subT), 0)
			targetNeck = CFrame.Angles(math.rad(3 * subT), math.rad(8 * subT), 0)
			targetRightShoulder = CFrame.Angles(math.rad(lerp(18, 70, subT)), math.rad(lerp(-8, -20, subT)), math.rad(lerp(6, 16, subT)))
			targetRightElbow = CFrame.Angles(math.rad(lerp(42, 78, subT)), 0, 0)
			targetRightWrist = CFrame.Angles(math.rad(-10 * subT), 0, 0)
			targetLeftShoulder = CFrame.Angles(math.rad(48 * subT), math.rad(16 * subT), math.rad(-10 * subT))
			targetLeftElbow = CFrame.Angles(math.rad(28 * subT), 0, 0)
			targetStaffGrip = CFrame.Angles(math.rad(subT * 16), 0, 0)

		elseif t < 0.54 then
			-- FASE 2: EMPUJE EXPLOSIVO Y SALIDA DEL PROYECTIL
			local subT = easeOutQuad((t - 0.24) / 0.30)

			if not hasFiredProjectileThisCast then
				hasFiredProjectileThisCast = true
				local originPos = if castPoint then castPoint.WorldPosition else (rightHand and rightHand.Position or Vector3.zero)
				local shootDir = char.PrimaryPart and char.PrimaryPart.CFrame.LookVector or Vector3.new(0, 0, 1)
				spawnShootingProjectile(originPos, shootDir)
			end

			targetWaist = CFrame.Angles(math.rad(lerp(-3, 12, subT)), math.rad(lerp(-14, 10, subT)), 0)
			targetNeck = CFrame.Angles(math.rad(lerp(3, -5, subT)), math.rad(lerp(8, -5, subT)), 0)
			targetRightShoulder = CFrame.Angles(math.rad(lerp(70, 88, subT)), math.rad(lerp(-20, 4, subT)), math.rad(lerp(16, -2, subT)))
			targetRightElbow = CFrame.Angles(math.rad(lerp(78, 14, subT)), 0, 0)
			targetRightWrist = CFrame.Angles(math.rad(lerp(-10, 20, subT)), 0, 0)
			targetLeftShoulder = CFrame.Angles(math.rad(lerp(48, -24, subT)), math.rad(lerp(16, -10, subT)), math.rad(-14))
			targetLeftElbow = CFrame.Angles(math.rad(lerp(28, 12, subT)), 0, 0)
			targetStaffGrip = CFrame.new(0, 0, -0.15 * subT) * CFrame.Angles(math.rad(subT * 20), 0, 0)

		elseif t < 0.78 then
			-- FASE 3: ABSORCIÓN DEL RETROCESO
			local subT = (t - 0.54) / 0.24
			local shake = math.sin(subT * math.pi * 2.5) * (1 - subT) * 0.03
			targetWaist = CFrame.Angles(math.rad(lerp(12, 3, subT) + shake * 2), math.rad(lerp(10, 2, subT)), 0)
			targetRightShoulder = CFrame.Angles(math.rad(lerp(88, 38, subT) + shake), math.rad(lerp(4, -6, subT)), 0)
			targetRightElbow = CFrame.Angles(math.rad(lerp(14, 36, subT)), 0, 0)
			targetRightWrist = CFrame.Angles(math.rad(lerp(20, 5, subT)), 0, 0)
			targetLeftShoulder = CFrame.Angles(math.rad(lerp(-24, 0, subT)), 0, 0)
			targetStaffGrip = CFrame.Angles(math.rad(lerp(20, 0, subT)), 0, 0)

		else
			-- FASE 4: RECUPERACIÓN SUAVE
			local subT = smoothstep((t - 0.78) / 0.22)
			local targetPitch = if isMoving then 18 else 12
			local targetElbow = if isMoving then 44 else 38
			targetRightShoulder = CFrame.Angles(math.rad(lerp(38, targetPitch, subT)), math.rad(-8), math.rad(6))
			targetRightElbow = CFrame.Angles(math.rad(lerp(36, targetElbow, subT)), 0, 0)
			targetStaffGrip = CFrame.identity
		end

		if t >= 1 then
			isCasting = false
		end
	elseif isMoving then
		-- CASO B: CAMINATA FLUIDA CON PORTE DE MAGO
		local stepClock = clock * 9.5
		local strideBob = math.sin(stepClock) * 0.04
		local strideSide = math.cos(stepClock * 0.5) * 0.025
		local armCounterSwing = math.sin(stepClock) * 0.2

		targetWaist = CFrame.Angles(math.rad(4.5), math.rad(strideSide * 35), 0)
		targetNeck = CFrame.Angles(math.rad(-2), math.rad(-strideSide * 20), 0)
		targetRightShoulder = CFrame.Angles(math.rad(16) + (strideBob * 0.5), math.rad(-8) + (strideSide * 0.3), math.rad(6))
		targetRightElbow = CFrame.Angles(math.rad(44) + (strideBob * 0.6), 0, 0)
		targetRightWrist = CFrame.Angles(math.rad(6), math.rad(-3), 0)
		targetLeftShoulder = CFrame.Angles(armCounterSwing, 0, 0)
		targetLeftElbow = CFrame.Angles(math.abs(armCounterSwing) * 0.4, 0, 0)
		targetStaffGrip = CFrame.new(0, strideBob * 0.1, 0)
	else
		-- CASO C: REPOSO (IDLE NOBLE MÍSTICO)
		local breathe = math.sin(clock * 2.0) * 0.025
		targetWaist = CFrame.Angles(breathe * 0.5, 0, 0)
		targetRightShoulder = CFrame.Angles(math.rad(12) + breathe, math.rad(-7), math.rad(5))
		targetRightElbow = CFrame.Angles(math.rad(38) + breathe * 0.4, 0, 0)
		targetRightWrist = CFrame.Angles(math.rad(4), 0, 0)
		targetLeftShoulder = CFrame.Angles(breathe * 0.3, 0, 0)
		targetStaffGrip = CFrame.identity
	end

	-- Suavizado exponencial continuo (Damped Slerp) a 16 rad/s para transiciones de seda
	local blendSpeed = math.clamp(dt * 16, 0, 1)
	curWaist = curWaist:Lerp(targetWaist, blendSpeed)
	curNeck = curNeck:Lerp(targetNeck, blendSpeed)
	curRightShoulder = curRightShoulder:Lerp(targetRightShoulder, blendSpeed)
	curRightElbow = curRightElbow:Lerp(targetRightElbow, blendSpeed)
	curRightWrist = curRightWrist:Lerp(targetRightWrist, blendSpeed)
	curLeftShoulder = curLeftShoulder:Lerp(targetLeftShoulder, blendSpeed)
	curLeftElbow = curLeftElbow:Lerp(targetLeftElbow, blendSpeed)
	curStaffGrip = curStaffGrip:Lerp(targetStaffGrip, blendSpeed)

	-- Aplicar a los motores
	if waist then waist.Transform = curWaist end
	if neck then neck.Transform = curNeck end
	if rightShoulder then rightShoulder.Transform = curRightShoulder end
	if rightElbow then rightElbow.Transform = curRightElbow end
	if rightWrist then rightWrist.Transform = curRightWrist end
	if leftShoulder then leftShoulder.Transform = curLeftShoulder end
	if leftElbow then leftElbow.Transform = curLeftElbow end
	staffGrip.Transform = curStaffGrip
end

RunService.RenderStepped:Connect(onRenderStep)
print("[StaffAnimationController] Bastón Arcano con cinemática Damped Lerp y animación fluida activa.")
