local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local rebirthEvent = ReplicatedStorage:FindFirstChild("RequestRebirth") or Instance.new("RemoteEvent")
rebirthEvent.Name = "RequestRebirth"
rebirthEvent.Parent = ReplicatedStorage

rebirthEvent.OnServerEvent:Connect(function(player)
local leaderstats = player:FindFirstChild("leaderstats")
if not leaderstats then return end

local monedas = leaderstats:FindFirstChild("Monedas")
local fuerza = leaderstats:FindFirstChild("Fuerza")
local rebirths = leaderstats:FindFirstChild("Rebirths")
if not (monedas and fuerza and rebirths) then return end

local cost = math.floor(GameConfig.REBIRTH_COST_BASE * (1.5 ^ rebirths.Value))
if monedas.Value >= cost then
monedas.Value = 0
fuerza.Value = 0
rebirths.Value += 1
end
end)
