local DSS, Players = game:GetService("DataStoreService"), game:GetService("Players")
local okS, DS = pcall(function() return DSS:GetDataStore("WizardSim_v1") end)

local function save(p)
    if not okS or not DS then return end
    local ls = p:FindFirstChild("leaderstats")
    if ls then pcall(function() DS:SetAsync(tostring(p.UserId), {Poder=ls.Poder.Value, Monedas=ls.Monedas.Value, Rebirths=ls.Rebirths.Value}) end) end
end

Players.PlayerAdded:Connect(function(p)
    local ls = Instance.new("Folder", p); ls.Name = "leaderstats"
    local pod = Instance.new("NumberValue", ls); pod.Name = "Poder"
    local mon = Instance.new("NumberValue", ls); mon.Name = "Monedas"
    local reb = Instance.new("NumberValue", ls); reb.Name = "Rebirths"
    p:SetAttribute("BastonEquipado", "Vara de Aprendiz")
    p:SetAttribute("MultPuesto", 1)
    if okS and DS then
        local ok, d = pcall(function() return DS:GetAsync(tostring(p.UserId)) end)
        if ok and type(d) == "table" then pod.Value = d.Poder or 0; mon.Value = d.Monedas or 0; reb.Value = d.Rebirths or 0 end
    end
end)
Players.PlayerRemoving:Connect(save)
game:BindToClose(function() for _, p in ipairs(Players:GetPlayers()) do save(p) end end)