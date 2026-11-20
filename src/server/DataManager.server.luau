local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local okStore, PlayerDataStore = pcall(function()
    return DataStoreService:GetDataStore("WizardSim_v1")
end)

local function savePlayerData(player)
    if not okStore or not PlayerDataStore then return end
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end
    local data = {
        Poder = leaderstats.Poder.Value,
        Monedas = leaderstats.Monedas.Value,
        Rebirths = leaderstats.Rebirths.Value,
    }
    pcall(function()
        PlayerDataStore:SetAsync(tostring(player.UserId), data)
    end)
end

Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local poder = Instance.new("NumberValue")
    poder.Name = "Poder"
    poder.Value = 0
    poder.Parent = leaderstats

    local monedas = Instance.new("NumberValue")
    monedas.Name = "Monedas"
    monedas.Value = 0
    monedas.Parent = leaderstats

    local rebirths = Instance.new("NumberValue")
    rebirths.Name = "Rebirths"
    rebirths.Value = 0
    rebirths.Parent = leaderstats

    player:SetAttribute("BastonesEquipado", "Vara de Aprendiz")
    player:SetAttribute("MultiplicadorPoder", 1)

    if okStore and PlayerDataStore then
        local ok, saved = pcall(function()
            return PlayerDataStore:GetAsync(tostring(player.UserId))
        end)
        if ok and type(saved) == "table" then
            poder.Value = saved.Poder or 0
            monedas.Value = saved.Monedas or 0
            rebirths.Value = saved.Rebirths or 0
        end
    end

    task.spawn(function()
        while player.Parent == Players do
            task.wait(60)
            if player.Parent == Players then
                savePlayerData(player)
            end
        end
    end)
end)

Players.PlayerRemoving:Connect(savePlayerData)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        savePlayerData(player)
    end
end)