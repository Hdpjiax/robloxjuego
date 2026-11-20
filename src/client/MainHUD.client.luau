local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local leaderstats = player:WaitForChild("leaderstats")
local monedas = leaderstats:WaitForChild("Monedas")
local fuerza = leaderstats:WaitForChild("Fuerza")
local rebirths = leaderstats:WaitForChild("Rebirths")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local doClickEvent = ReplicatedStorage:WaitForChild("DoClick")
local rebirthEvent = ReplicatedStorage:WaitForChild("RequestRebirth")

local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi"}
local function formatNumber(n)
	if n < 1000 then
		return tostring(math.floor(n))
	end
	local idx = 1
	while n >= 1000 and idx < #suffixes do
		n /= 1000
		idx += 1
	end
	return string.format("%.2f%s", n, suffixes[idx])
end

local gui = Instance.new("ScreenGui")
gui.Name = "MainHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Contenedor superior de 3 tarjetas (a la izquierda de la lista de jugadores)
local topContainer = Instance.new("Frame")
topContainer.Name = "TopStats"
topContainer.Size = UDim2.new(0, 510, 0, 56)
topContainer.Position = UDim2.new(0.42, -255, 0, 14)
topContainer.BackgroundTransparency = 1
topContainer.Parent = gui

local topLayout = Instance.new("UIListLayout")
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topLayout.Padding = UDim.new(0, 12)
topLayout.Parent = topContainer

local function createStatCard(title, accentColor)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(0, 160, 0, 54)
	card.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
	card.BackgroundTransparency = 0.12
	card.BorderSizePixel = 0
	card.Parent = topContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2.5
	stroke.Color = accentColor
	stroke.Parent = card

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 42, 62)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 17, 26)),
	})
	gradient.Rotation = 90
	gradient.Parent = card

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -12, 0, 18)
	titleLbl.Position = UDim2.new(0, 6, 0, 5)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = string.upper(title)
	titleLbl.TextColor3 = accentColor
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 11
	titleLbl.Parent = card

	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(1, -12, 0, 26)
	valueLbl.Position = UDim2.new(0, 6, 0, 22)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Text = "0"
	valueLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueLbl.Font = Enum.Font.GothamBlack
	valueLbl.TextSize = 18
	valueLbl.Parent = card

	return valueLbl
end

local monedasVal = createStatCard("Monedas", Color3.fromRGB(255, 215, 0))
local fuerzaVal = createStatCard("Fuerza", Color3.fromRGB(0, 229, 255))
local rebirthsVal = createStatCard("Rebirths", Color3.fromRGB(179, 136, 255))

-- Botón central inferior de Entrenar con animación de rebote
local clickBtn = Instance.new("TextButton")
clickBtn.Name = "TrainButton"
clickBtn.Size = UDim2.new(0, 240, 0, 66)
clickBtn.Position = UDim2.new(0.5, -120, 1, -92)
clickBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
clickBtn.AutoButtonColor = false
clickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clickBtn.Font = Enum.Font.GothamBlack
clickBtn.TextSize = 20
clickBtn.Text = "ENTRENAR (+CLIC)"
clickBtn.Parent = gui

local clickCorner = Instance.new("UICorner")
clickCorner.CornerRadius = UDim.new(0, 16)
clickCorner.Parent = clickBtn

local clickStroke = Instance.new("UIStroke")
clickStroke.Thickness = 3
clickStroke.Color = Color3.fromRGB(180, 245, 255)
clickStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
clickStroke.Parent = clickBtn

local clickGrad = Instance.new("UIGradient")
clickGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 210, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 115, 230)),
})
clickGrad.Rotation = 90
clickGrad.Parent = clickBtn

-- Botón lateral izquierdo de Rebirth
local rebirthBtn = Instance.new("TextButton")
rebirthBtn.Name = "RebirthButton"
rebirthBtn.Size = UDim2.new(0, 185, 0, 60)
rebirthBtn.Position = UDim2.new(0, 18, 0.5, -30)
rebirthBtn.BackgroundColor3 = Color3.fromRGB(235, 75, 45)
rebirthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthBtn.Font = Enum.Font.GothamBold
rebirthBtn.TextSize = 14
rebirthBtn.Parent = gui

local rebCorner = Instance.new("UICorner")
rebCorner.CornerRadius = UDim.new(0, 14)
rebCorner.Parent = rebirthBtn

local rebStroke = Instance.new("UIStroke")
rebStroke.Thickness = 2.5
rebStroke.Color = Color3.fromRGB(255, 190, 160)
rebStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rebStroke.Parent = rebirthBtn

-- Contenedor lateral derecho listo para Mascotas, Zonas y Tienda
local rightSidebar = Instance.new("Frame")
rightSidebar.Name = "RightSidebar"
rightSidebar.Size = UDim2.new(0, 150, 0, 260)
rightSidebar.Position = UDim2.new(1, -168, 0.5, -130)
rightSidebar.BackgroundTransparency = 1
rightSidebar.Parent = gui

local sideLayout = Instance.new("UIListLayout")
sideLayout.FillDirection = Enum.FillDirection.Vertical
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Center
sideLayout.Padding = UDim.new(0, 12)
sideLayout.Parent = rightSidebar

local function updateUI()
	local mult = 1 + rebirths.Value * 0.5
	local rebirthCost = math.floor(GameConfig.REBIRTH_COST_BASE * (1.5 ^ rebirths.Value))

	monedasVal.Text = formatNumber(monedas.Value)
	fuerzaVal.Text = formatNumber(fuerza.Value)
	rebirthsVal.Text = string.format("%d (%.1fx)", rebirths.Value, mult)

	rebirthBtn.Text = string.format("REBIRTH\nCosto: %s", formatNumber(rebirthCost))
	if monedas.Value >= rebirthCost then
		rebirthBtn.BackgroundColor3 = Color3.fromRGB(38, 195, 105)
		rebStroke.Color = Color3.fromRGB(165, 255, 195)
	else
		rebirthBtn.BackgroundColor3 = Color3.fromRGB(235, 75, 45)
		rebStroke.Color = Color3.fromRGB(255, 190, 160)
	end
end

local function spawnFloatingGain(amount)
	local floatLbl = Instance.new("TextLabel")
	floatLbl.Size = UDim2.new(0, 150, 0, 34)
	floatLbl.Position = UDim2.new(0.5, math.random(-90, 20), 1, -135)
	floatLbl.BackgroundTransparency = 1
	floatLbl.TextColor3 = Color3.fromRGB(255, 230, 80)
	floatLbl.TextStrokeTransparency = 0.2
	floatLbl.Font = Enum.Font.GothamBlack
	floatLbl.TextSize = 22
	floatLbl.Text = "+" .. formatNumber(amount)
	floatLbl.Parent = gui

	local tween = TweenService:Create(
		floatLbl,
		TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = floatLbl.Position - UDim2.new(0, 0, 0, 65), TextTransparency = 1, TextStrokeTransparency = 1 }
	)
	tween:Play()
	tween.Completed:Connect(function()
		floatLbl:Destroy()
	end)
end

local function triggerTrain()
	doClickEvent:FireServer()
	local gain = 1 * GameConfig.ZONES[1].multiplier * (1 + rebirths.Value * 0.5)
	spawnFloatingGain(gain)

	local shrink = TweenService:Create(
		clickBtn,
		TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.new(0, 222, 0, 58), Position = UDim2.new(0.5, -111, 1, -88) }
	)
	shrink:Play()
	shrink.Completed:Connect(function()
		TweenService:Create(
			clickBtn,
			TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 240, 0, 66), Position = UDim2.new(0.5, -120, 1, -92) }
		):Play()
	end)
end

clickBtn.MouseButton1Click:Connect(triggerTrain)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		triggerTrain()
	end
end)

rebirthBtn.MouseButton1Click:Connect(function()
	rebirthEvent:FireServer()
end)

monedas.Changed:Connect(updateUI)
fuerza.Changed:Connect(updateUI)
rebirths.Changed:Connect(updateUI)
updateUI()