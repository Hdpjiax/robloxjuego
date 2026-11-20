local ReplicatedStorage = game:GetService("ReplicatedStorage")

local doClickEvent = ReplicatedStorage:FindFirstChild("DoClick") or Instance.new("RemoteEvent")
doClickEvent.Name = "DoClick"
doClickEvent.Parent = ReplicatedStorage

local lastClick = {}

doClickEvent.OnServerEvent:Connect(function(player)
local now = os.clock()
if lastClick[player.UserId] and (now - lastClick[player.UserId]) < 0.08 then return end
lastClick[player.UserId] = now

local leaderstats = player:FindFirstChild("leaderstats")
if not leaderstats then return end
local poder = leaderstats:FindFirstChild("Poder")
local rebirths = leaderstats:FindFirstChild("Rebirths")
if not (poder and rebirths) then return end

local multPuesto = player:GetAttribute("MultPuesto") or 1
local gain = 1 * multPuesto * (1 + rebirths.Value * 0.5)
poder.Value += gain
end)