local ReplicatedStorage = game:GetService("ReplicatedStorage")

local rebirthEvent = ReplicatedStorage:FindFirstChild("RequestRebirth") or Instance.new("RemoteEvent")
rebirthEvent.Name = "RequestRebirth"
rebirthEvent.Parent = ReplicatedStorage

rebirthEvent.OnServerEvent:Connect(function(player)
local leaderstats = player:FindFirstChild("leaderstats")
if not leaderstats then return end
local poder = leaderstats:FindFirstChild("Poder")
local rebirths = leaderstats:FindFirstChild("Rebirths")
if not (poder and rebirths) then return end

local cost = math.floor(1000 * (1.8 ^ rebirths.Value))
if poder.Value >= cost then
poder.Value = 0
rebirths.Value += 1
end
end)