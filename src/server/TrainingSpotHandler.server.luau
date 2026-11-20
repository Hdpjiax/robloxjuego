--!strict
-- TrainingSpotHandler.server.luau
-- Wizard Craft & Combat Simulator
-- Controlador del Paseo de la Ascensión (7 Santuarios de Entrenamiento) en la Gran Lobby

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local function setupTrainingSpots()
	local lobby = Workspace:WaitForChild("Lobby", 10)
	if not lobby then
		warn("[TrainingSpotHandler] No se encontró workspace.Lobby")
		return
	end

	local spotsFolder = lobby:WaitForChild("TrainingSpots", 10)
	if not spotsFolder then
		warn("[TrainingSpotHandler] No se encontró TrainingSpots en Lobby")
		return
	end

	for _, child in ipairs(spotsFolder:GetChildren()) do
		if child:IsA("Model") and child.Name:match("^TrainingSpot_Tier%d+$") then
			local tier = child:GetAttribute("Tier") or 1
			local reqRebirths = child:GetAttribute("RequiredRebirths") or 0
			local mult = child:GetAttribute("Multiplier") or 1.0
			local spotName = child:GetAttribute("SpotName") or ("Tier " .. tostring(tier))

			local trainingPad = child:FindFirstChild("TrainingPad") :: BasePart?
			local bbg = child:FindFirstChild("SanctumGui") :: BillboardGui?

			if trainingPad then
				trainingPad.Touched:Connect(function(hit)
					local char = hit.Parent
					local player = Players:GetPlayerFromCharacter(char)
					if not player then return end

					local leaderstats = player:FindFirstChild("leaderstats")
					local rebirthsVal = leaderstats and leaderstats:FindFirstChild("Rebirths") :: NumberValue?
					local curRebirths = rebirthsVal and rebirthsVal.Value or 0

					if curRebirths >= reqRebirths then
						player:SetAttribute("MultPuesto", mult)
						player:SetAttribute("NombrePuesto", spotName)
					else
						-- Jugador no tiene suficientes rebirths: Repeler suavemente sin impulsos físicos
						local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
						if hrp then
							local dir = (hrp.Position - trainingPad.Position).Unit
							local pushDir = Vector3.new(dir.X, 0, dir.Z)
							if pushDir.Magnitude < 0.1 then
								pushDir = Vector3.new(-1, 0, 0)
							else
								pushDir = pushDir.Unit
							end
							hrp.CFrame = CFrame.new(trainingPad.Position + pushDir * 8 + Vector3.new(0, 1.2, 0))
						end
					end
				end)

				trainingPad.TouchEnded:Connect(function(hit)
					local char = hit.Parent
					local player = Players:GetPlayerFromCharacter(char)
					if not player then return end

					local curSpot = player:GetAttribute("NombrePuesto")
					if curSpot == spotName then
						player:SetAttribute("MultPuesto", 1.0)
						player:SetAttribute("NombrePuesto", "LOBBY")
					end
				end)
			end
		end
	end
	print("[TrainingSpotHandler] Los 7 Santuarios de la Ascensión han sido vinculados correctamente.")
end

task.spawn(setupTrainingSpots)
