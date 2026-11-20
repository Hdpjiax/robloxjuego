--!strict
-- ClickHandler.server.luau
-- Wizard Craft & Combat Simulator
-- Gestiona la canalización de magia considerando Bastón, Puesto de Entrenamiento, Rebirths y Mascotas

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StavesData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("StavesData"))

local doClickEvent = ReplicatedStorage:FindFirstChild("DoClick")
if not doClickEvent then
	doClickEvent = Instance.new("RemoteEvent")
	doClickEvent.Name = "DoClick"
	doClickEvent.Parent = ReplicatedStorage
end

local lastClick: { [number]: number } = {}

doClickEvent.OnServerEvent:Connect(function(player: Player)
	local now = os.clock()
	if lastClick[player.UserId] and (now - lastClick[player.UserId]) < 0.08 then return end
	lastClick[player.UserId] = now

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	local poder = leaderstats:FindFirstChild("Poder") :: NumberValue?
	local rebirths = leaderstats:FindFirstChild("Rebirths") :: NumberValue?
	if not (poder and rebirths) then return end

	-- Multiplicador del Bastón
	local staffId = player:GetAttribute("BastonEquipado")
	local staffConfig = StavesData.getStaff(staffId)
	local staffMult = staffConfig and staffConfig.PowerMultiplier or 1.0

	-- Multiplicador del Puesto de Entrenamiento
	local multPuesto = player:GetAttribute("MultPuesto") or 1

	-- Multiplicador de Rebirths
	local rebirthMult = 1 + (rebirths.Value * 0.5)

	-- Multiplicador de Mascota Activa
	local petMult = player:GetAttribute("PetMultiplier") or 1.0

	local gain = math.floor(1 * staffMult * multPuesto * rebirthMult * petMult)
	if gain < 1 then gain = 1 end

	poder.Value += gain

	-- Notificar al cliente para sincronizar animación y efectos
	doClickEvent:FireClient(player)
end)
