--!strict
-- ProximitySignController.client.luau
-- Wizard Craft & Combat Simulator
-- Garantiza que los letreros de las bases de entrenamiento y las estaciones de la lobby
-- SOLO se vean cuando el jugador se acerca a uno de ellos (exclusividad de 1 solo letrero a la vez).
-- Cuando el jugador está caminando por la plaza o lejos, NINGÚN letrero se muestra para mantener la vista 100% limpia.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local ACTIVATION_FLAT_DISTANCE = 13.0 -- Máxima distancia horizontal en studs para mostrar un letrero
local CHECK_INTERVAL = 0.08 -- ~12 veces por segundo para respuesta ágil

local lastCheck = 0

-- Función que recolecta dinámicamente todos los billboards de entrenamiento y estaciones
local function collectAllManagedBillboards(): { BillboardGui }
	local billboards: { BillboardGui } = {}
	local lobby = Workspace:FindFirstChild("Lobby")
	if not lobby then return billboards end

	-- 1. Bases de Entrenamiento (TrainingSpots: SanctumGui o cualquier BillboardGui)
	local trainingFolder = lobby:FindFirstChild("TrainingSpots")
	if trainingFolder then
		for _, spot in ipairs(trainingFolder:GetChildren()) do
			for _, desc in ipairs(spot:GetDescendants()) do
				if desc:IsA("BillboardGui") then
					table.insert(billboards, desc)
				end
			end
		end
	end

	-- 2. Estaciones Físicas (PhysicalLobbyStations: StationSignGui o cualquier BillboardGui)
	local stationsFolder = lobby:FindFirstChild("PhysicalLobbyStations") or Workspace:FindFirstChild("PhysicalLobbyStations")
	if stationsFolder then
		for _, station in ipairs(stationsFolder:GetChildren()) do
			for _, desc in ipairs(station:GetDescendants()) do
				if desc:IsA("BillboardGui") then
					table.insert(billboards, desc)
				end
			end
		end
	end

	return billboards
end

local function updateSignVisibility()
	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return end

	local playerPos = hrp.Position
	local allBillboards = collectAllManagedBillboards()

	local closestBbg: BillboardGui? = nil
	local closestDist = ACTIVATION_FLAT_DISTANCE

	for _, bbg in ipairs(allBillboards) do
		-- Aseguramos que MaxDistance nativo de Roblox esté acotado a 14 studs
		if bbg.MaxDistance > 14 then
			bbg.MaxDistance = 14
		end

		local adornee = bbg.Adornee
		local targetPos: Vector3? = nil

		if adornee and adornee:IsA("BasePart") then
			targetPos = adornee.Position
		elseif bbg.Parent and bbg.Parent:IsA("BasePart") then
			targetPos = (bbg.Parent :: BasePart).Position
		end

		if targetPos then
			-- Distancia horizontal 2D en el plano X-Z
			local dx = playerPos.X - targetPos.X
			local dz = playerPos.Z - targetPos.Z
			local flatDist = math.sqrt(dx * dx + dz * dz)

			if flatDist < closestDist then
				closestDist = flatDist
				closestBbg = bbg
			end
		end
	end

	-- Habilitar ÚNICAMENTE el letrero más cercano si está dentro del radio de 13 studs.
	-- Todos los demás se apagan inmediatamente.
	for _, bbg in ipairs(allBillboards) do
		local shouldEnable = (bbg == closestBbg)
		if bbg.Enabled ~= shouldEnable then
			bbg.Enabled = shouldEnable
		end
	end
end

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	if now - lastCheck >= CHECK_INTERVAL then
		lastCheck = now
		updateSignVisibility()
	end
end)

print("[ProximitySignController] Control de proximidad exclusivo activo: Máximo 1 letrero visible dentro de 13 studs.")
