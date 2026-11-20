local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local doClickEvent = ReplicatedStorage:FindFirstChild("DoClick") or Instance.new("RemoteEvent")
doClickEvent.Name = "DoClick"
doClickEvent.Parent = ReplicatedStorage

local lastClick = {}

doClickEvent.OnServerEvent:Connect(function(player)
local now = os.clock()
if lastClick[player.UserId] and (now - lastClick[player.UserId]) < 0.1 then
return
end
lastClick[player.UserId] = now

local leaderstats = player:FindFirstChild("leaderstats")
if not leaderstats then return end

local monedas = leaderstats:FindFirstChild("Monedas")
local fuerza = leaderstats:FindFirstChild("Fuerza")
local rebirths = leaderstats:FindFirstChild("Rebirths")
if not (monedas and fuerza and rebirths) then return end

local zoneConfig = GameConfig.ZONES[1]
local gain = 1 * zoneConfig.multiplier * (1 + rebirths.Value * 0.5)

monedas.Value += gain
fuerza.Value += gain
end)
