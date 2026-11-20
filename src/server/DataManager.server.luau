--!strict
-- DataManager.server.luau
-- Wizard Craft & Combat Simulator - Gestor de Datos, Leaderstats, Materiales, Huevos y Bastones

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local okStore, playerStore = pcall(function()
	return DataStoreService:GetDataStore("WizardCraft_v3")
end)

local function saveData(player: Player)
	if not (okStore and playerStore) then return end
	local ls = player:FindFirstChild("leaderstats")
	local mats = player:FindFirstChild("Materiales")
	if not ls then return end

	local poder = ls:FindFirstChild("Poder") :: NumberValue?
	local monedas = ls:FindFirstChild("Monedas") :: NumberValue?
	local rebirths = ls:FindFirstChild("Rebirths") :: NumberValue?

	local madera = mats and mats:FindFirstChild("MaderaArcana") :: NumberValue?
	local cristal = mats and mats:FindFirstChild("CristalCeleste") :: NumberValue?
	local gelatina = mats and mats:FindFirstChild("GelatinaSlime") :: NumberValue?
	local huevos = mats and mats:FindFirstChild("HuevosRaros") :: NumberValue?

	local data = {
		Poder = poder and poder.Value or 0,
		Monedas = monedas and monedas.Value or 0,
		Rebirths = rebirths and rebirths.Value or 0,
		BastonEquipado = player:GetAttribute("BastonEquipado") or "VaraDeAprendiz",
		OwnedStaves = player:GetAttribute("OwnedStaves") or "VaraDeAprendiz",
		MascotaEquipada = player:GetAttribute("MascotaEquipada") or "Ninguna",
		MaderaArcana = madera and madera.Value or 0,
		CristalCeleste = cristal and cristal.Value or 0,
		GelatinaSlime = gelatina and gelatina.Value or 0,
		HuevosRaros = huevos and huevos.Value or 0,
	}

	pcall(function()
		playerStore:SetAsync(tostring(player.UserId), data)
	end)
end

Players.PlayerAdded:Connect(function(player: Player)
	-- Carpeta Leaderstats
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	ls.Parent = player

	local poder = Instance.new("NumberValue")
	poder.Name = "Poder"
	poder.Value = 0
	poder.Parent = ls

	local monedas = Instance.new("NumberValue")
	monedas.Name = "Monedas"
	monedas.Value = 0
	monedas.Parent = ls

	local rebirths = Instance.new("NumberValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = ls

	-- Carpeta de Materiales para Crafteo
	local mats = Instance.new("Folder")
	mats.Name = "Materiales"
	mats.Parent = player

	local madera = Instance.new("NumberValue")
	madera.Name = "MaderaArcana"
	madera.Value = 0
	madera.Parent = mats

	local cristal = Instance.new("NumberValue")
	cristal.Name = "CristalCeleste"
	cristal.Value = 0
	cristal.Parent = mats

	local gelatina = Instance.new("NumberValue")
	gelatina.Name = "GelatinaSlime"
	gelatina.Value = 0
	gelatina.Parent = mats

	local huevos = Instance.new("NumberValue")
	huevos.Name = "HuevosRaros"
	huevos.Value = 0
	huevos.Parent = mats

	-- Atributos base
	player:SetAttribute("BastonEquipado", "VaraDeAprendiz")
	player:SetAttribute("BastonesEquipado", "Vara de Aprendiz")
	player:SetAttribute("OwnedStaves", "VaraDeAprendiz")
	player:SetAttribute("MultPuesto", 1.0)
	player:SetAttribute("NombrePuesto", "LOBBY")
	player:SetAttribute("PetMultiplier", 1.0)
	player:SetAttribute("MascotaEquipada", "Ninguna")
	player:SetAttribute("HuevosRaros", 0)

	-- Sincronizar cambios de HuevosRaros a atributo
	huevos.Changed:Connect(function(newVal)
		player:SetAttribute("HuevosRaros", newVal)
	end)

	-- Cargar datos guardados
	if okStore and playerStore then
		local ok, saved = pcall(function()
			return playerStore:GetAsync(tostring(player.UserId))
		end)

		if ok and type(saved) == "table" then
			poder.Value = saved.Poder or 0
			monedas.Value = saved.Monedas or 0
			rebirths.Value = saved.Rebirths or 0
			madera.Value = saved.MaderaArcana or 0
			cristal.Value = saved.CristalCeleste or 0
			gelatina.Value = saved.GelatinaSlime or 0
			huevos.Value = saved.HuevosRaros or 0

			local baston = saved.BastonEquipado or "VaraDeAprendiz"
			player:SetAttribute("BastonEquipado", baston)
			player:SetAttribute("BastonesEquipado", baston)

			local owned = saved.OwnedStaves or "VaraDeAprendiz"
			player:SetAttribute("OwnedStaves", owned)

			local mascota = saved.MascotaEquipada or "Ninguna"
			player:SetAttribute("MascotaEquipada", mascota)
			player:SetAttribute("HuevosRaros", huevos.Value)
		end
	end
end)

Players.PlayerRemoving:Connect(saveData)

game:BindToClose(function()
	for _, p in ipairs(Players:GetPlayers()) do
		task.spawn(saveData, p)
	end
end)

print("[DataManager] Gestor de Datos listo con soporte para 100 bastones, materiales y huevos raros.")
