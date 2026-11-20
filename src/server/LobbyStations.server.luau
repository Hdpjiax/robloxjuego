--!strict
-- LobbyStations.server.luau
-- Wizard Craft & Combat Simulator
-- Controlador del lado del servidor para las 4 Estaciones Interactivas de la Gran Lobby
-- (Mercado Arcano, Forja Real, Altar de Encantar y Santuario de Mascotas)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Eventos Remotos
local openUiEvent = ReplicatedStorage:FindFirstChild("OpenStationUI")
if not openUiEvent then
	openUiEvent = Instance.new("RemoteEvent")
	openUiEvent.Name = "OpenStationUI"
	openUiEvent.Parent = ReplicatedStorage
end

local sellMaterialsEvent = ReplicatedStorage:FindFirstChild("SellMaterials")
if not sellMaterialsEvent then
	sellMaterialsEvent = Instance.new("RemoteEvent")
	sellMaterialsEvent.Name = "SellMaterials"
	sellMaterialsEvent.Parent = ReplicatedStorage
end

local notifyEvent = ReplicatedStorage:FindFirstChild("ShowGameNotification")
if not notifyEvent then
	notifyEvent = Instance.new("RemoteEvent")
	notifyEvent.Name = "ShowGameNotification"
	notifyEvent.Parent = ReplicatedStorage
end

--------------------------------------------------------------------------------
-- VINCULAR ESTACIONES FÍSICAS EN EL LOBBY
--------------------------------------------------------------------------------
local function setupStationPrompts()
	local lobbyFolder = Workspace:WaitForChild("Lobby", 10)
	if not lobbyFolder then
		warn("[LobbyStations] No se encontró workspace.Lobby")
		return
	end

	local stationsFolder = lobbyFolder:WaitForChild("PhysicalLobbyStations", 10)
	if not stationsFolder then
		warn("[LobbyStations] No se encontró PhysicalLobbyStations en Lobby")
		return
	end

	local stationBindings = {
		{ FolderName = "Station_Mercado", UIKey = "Mercado" },
		{ FolderName = "Station_Forja", UIKey = "Forjar" },
		{ FolderName = "Station_Encantar", UIKey = "Encantar" },
		{ FolderName = "Station_Mascotas", UIKey = "Mascotas" },
	}

	for _, binding in ipairs(stationBindings) do
		local stationModel = stationsFolder:FindFirstChild(binding.FolderName)
		if stationModel then
			local function hookPrompt(prompt: ProximityPrompt)
				prompt.Triggered:Connect(function(player: Player)
					openUiEvent:FireClient(player, binding.UIKey)
				end)
				print(string.format("[LobbyStations] Vinculado ProximityPrompt de %s -> UI '%s'", binding.FolderName, binding.UIKey))
			end

			local prompt = stationModel:FindFirstChildWhichIsA("ProximityPrompt", true)
			if prompt then
				hookPrompt(prompt)
			end

			stationModel.DescendantAdded:Connect(function(desc)
				if desc:IsA("ProximityPrompt") then
					hookPrompt(desc)
				end
			end)
		end
	end
end

task.spawn(setupStationPrompts)

--------------------------------------------------------------------------------
-- SISTEMA DE VENTA DE MATERIALES (MERCADO ARCANO)
--------------------------------------------------------------------------------
sellMaterialsEvent.OnServerEvent:Connect(function(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local monedas = leaderstats and leaderstats:FindFirstChild("Monedas") :: NumberValue?
	local materiales = player:FindFirstChild("Materiales")

	if not leaderstats or not monedas or not materiales then
		notifyEvent:FireClient(player, "No tienes materiales para vender.", Color3.fromRGB(255, 120, 120))
		return
	end

	local madera = materiales:FindFirstChild("MaderaArcana") :: NumberValue?
	local cristal = materiales:FindFirstChild("CristalCeleste") :: NumberValue?
	local gelatina = materiales:FindFirstChild("GelatinaSlime") :: NumberValue?

	local numMadera = madera and madera.Value or 0
	local numCristal = cristal and cristal.Value or 0
	local numGelatina = gelatina and gelatina.Value or 0

	local totalGain = (numMadera * 5) + (numCristal * 15) + (numGelatina * 25)

	if totalGain <= 0 then
		notifyEvent:FireClient(player, "¡Tu mochila de materiales está vacía! Explora el Bosque Rúnico.", Color3.fromRGB(240, 180, 80))
		return
	end

	if madera then madera.Value = 0 end
	if cristal then cristal.Value = 0 end
	if gelatina then gelatina.Value = 0 end

	monedas.Value += totalGain

	notifyEvent:FireClient(
		player,
		string.format("¡Vendiste %d maderas, %d cristales y %d gelatinas por +%d Monedas!", numMadera, numCristal, numGelatina, totalGain),
		Color3.fromRGB(255, 215, 60)
	)
end)

print("[LobbyStations] Controlador de Estaciones y Mercado iniciado correctamente.")
