--!strict
-- MainHUD.client.luau
-- Wizard Craft & Combat Simulator - Cliente HUD Principal
-- Estética: Fantasía Arcana Moderna (Azul Medianoche, Dorado Antiguo, Cian Arcano, Violeta Místico)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Referencias seguras a leaderstats
local leaderstats = player:WaitForChild("leaderstats")
local poderStat = leaderstats:WaitForChild("Poder", 10) or leaderstats:WaitForChild("Fuerza", 10)
local monedasStat = leaderstats:WaitForChild("Monedas", 10)
local rebirthsStat = leaderstats:WaitForChild("Rebirths", 10)

-- Eventos remotos en ReplicatedStorage
local doClickEvent = ReplicatedStorage:WaitForChild("DoClick", 10)
local rebirthEvent = ReplicatedStorage:WaitForChild("RequestRebirth", 10)

-- Paleta de Colores Arcanos
local COLOR_MIDNIGHT = Color3.fromRGB(16, 18, 30)
local COLOR_MIDNIGHT_LIGHT = Color3.fromRGB(26, 30, 48)
local COLOR_GOLD = Color3.fromRGB(255, 215, 0)
local COLOR_CYAN = Color3.fromRGB(0, 229, 255)
local COLOR_VIOLET = Color3.fromRGB(179, 136, 255)
local COLOR_RED = Color3.fromRGB(240, 75, 75)
local COLOR_GREEN = Color3.fromRGB(0, 240, 150)
local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_MUTED = Color3.fromRGB(165, 175, 205)

-- Función de formateo de números grandes (K, M, B, T, Qa, Qi)
local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi" }
local function formatNumber(n: number): string
	if n < 1000 then
		return tostring(math.floor(n))
	end
	local idx = 1
	local val = n
	while val >= 1000 and idx < #SUFFIXES do
		val /= 1000
		idx += 1
	end
	return string.format("%.2f%s", val, SUFFIXES[idx])
end

-- ScreenGui Principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainHUD"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 10
screenGui.Parent = playerGui

--------------------------------------------------------------------------------
-- 1. TRES TARJETAS SUPERIORES HORIZONTALES
--------------------------------------------------------------------------------
local topContainer = Instance.new("Frame")
topContainer.Name = "TopStatsContainer"
topContainer.Size = UDim2.new(0, 510, 0, 56)
topContainer.Position = UDim2.new(0.42, -255, 0, 14)
topContainer.BackgroundTransparency = 1
topContainer.Parent = screenGui

local topLayout = Instance.new("UIListLayout")
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topLayout.Padding = UDim.new(0, 12)
topLayout.Parent = topContainer

local function createTopCard(name: string, iconText: string, accentColor: Color3)
	local card = Instance.new("Frame")
	card.Name = name .. "Card"
	card.Size = UDim2.new(0, 160, 0, 54)
	card.BackgroundColor3 = COLOR_MIDNIGHT
	card.BackgroundTransparency = 0.1
	card.BorderSizePixel = 0
	card.Parent = topContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2.5
	stroke.Color = accentColor
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = card

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, COLOR_MIDNIGHT_LIGHT),
		ColorSequenceKeypoint.new(1, COLOR_MIDNIGHT),
	})
	gradient.Rotation = 90
	gradient.Parent = card

	-- Contenedor interior para icono + título
	local headerFrame = Instance.new("Frame")
	headerFrame.Size = UDim2.new(1, -16, 0, 18)
	headerFrame.Position = UDim2.new(0, 10, 0, 6)
	headerFrame.BackgroundTransparency = 1
	headerFrame.Parent = card

	local headerLayout = Instance.new("UIListLayout")
	headerLayout.FillDirection = Enum.FillDirection.Horizontal
	headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	headerLayout.Padding = UDim.new(0, 5)
	headerLayout.Parent = headerFrame

	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.new(0, 16, 1, 0)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Text = iconText
	iconLbl.Font = Enum.Font.GothamBlack
	iconLbl.TextSize = 13
	iconLbl.TextColor3 = accentColor
	iconLbl.Parent = headerFrame

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -22, 1, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = string.upper(name)
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 11
	titleLbl.TextColor3 = accentColor
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = headerFrame

	-- Valor
	local valueLbl = Instance.new("TextLabel")
	valueLbl.Name = "ValueLabel"
	valueLbl.Size = UDim2.new(1, -16, 0, 24)
	valueLbl.Position = UDim2.new(0, 10, 0, 24)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Text = "0"
	valueLbl.Font = Enum.Font.GothamBlack
	valueLbl.TextSize = 17
	valueLbl.TextColor3 = COLOR_WHITE
	valueLbl.TextXAlignment = Enum.TextXAlignment.Left
	valueLbl.Parent = card

	return valueLbl
end

local poderValueLabel = createTopCard("Poder", "⚡", COLOR_CYAN)
local monedasValueLabel = createTopCard("Monedas", "🪙", COLOR_GOLD)
local rebirthsValueLabel = createTopCard("Rebirths", "🔮", COLOR_VIOLET)

--------------------------------------------------------------------------------
-- 2. PANEL IZQUIERDO: REBIRTH Y BASTÓN EQUIPADO
--------------------------------------------------------------------------------
local leftPanel = Instance.new("Frame")
leftPanel.Name = "LeftPanel"
leftPanel.Size = UDim2.new(0, 195, 0, 155)
leftPanel.Position = UDim2.new(0, 18, 0.5, -85)
leftPanel.BackgroundTransparency = 1
leftPanel.Parent = screenGui

local leftLayout = Instance.new("UIListLayout")
leftLayout.FillDirection = Enum.FillDirection.Vertical
leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
leftLayout.VerticalAlignment = Enum.VerticalAlignment.Center
leftLayout.Padding = UDim.new(0, 12)
leftLayout.Parent = leftPanel

-- Botón Ascender (Rebirth)
local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "RebirthButton"
rebirthButton.Size = UDim2.new(1, 0, 0, 68)
rebirthButton.BackgroundColor3 = COLOR_MIDNIGHT
rebirthButton.AutoButtonColor = false
rebirthButton.Text = ""
rebirthButton.Parent = leftPanel

local rebirthCorner = Instance.new("UICorner")
rebirthCorner.CornerRadius = UDim.new(0, 14)
rebirthCorner.Parent = rebirthButton

local rebirthStroke = Instance.new("UIStroke")
rebirthStroke.Thickness = 2.5
rebirthStroke.Color = COLOR_RED
rebirthStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rebirthStroke.Parent = rebirthButton

local rebirthGradient = Instance.new("UIGradient")
rebirthGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 22, 38)),
	ColorSequenceKeypoint.new(1, COLOR_MIDNIGHT),
})
rebirthGradient.Rotation = 90
rebirthGradient.Parent = rebirthButton

local rebirthTitle = Instance.new("TextLabel")
rebirthTitle.Size = UDim2.new(1, -16, 0, 20)
rebirthTitle.Position = UDim2.new(0, 10, 0, 8)
rebirthTitle.BackgroundTransparency = 1
rebirthTitle.Text = "🔮 ASCENDER"
rebirthTitle.Font = Enum.Font.GothamBlack
rebirthTitle.TextSize = 13
rebirthTitle.TextColor3 = COLOR_WHITE
rebirthTitle.TextXAlignment = Enum.TextXAlignment.Center
rebirthTitle.Parent = rebirthButton

local rebirthCostLabel = Instance.new("TextLabel")
rebirthCostLabel.Name = "CostLabel"
rebirthCostLabel.Size = UDim2.new(1, -16, 0, 18)
rebirthCostLabel.Position = UDim2.new(0, 10, 0, 28)
rebirthCostLabel.BackgroundTransparency = 1
rebirthCostLabel.Text = "Costo: ⚡ 1.00K"
rebirthCostLabel.Font = Enum.Font.GothamBold
rebirthCostLabel.TextSize = 11
rebirthCostLabel.TextColor3 = COLOR_MUTED
rebirthCostLabel.TextXAlignment = Enum.TextXAlignment.Center
rebirthCostLabel.Parent = rebirthButton

local rebirthStatusLabel = Instance.new("TextLabel")
rebirthStatusLabel.Name = "StatusLabel"
rebirthStatusLabel.Size = UDim2.new(1, -16, 0, 16)
rebirthStatusLabel.Position = UDim2.new(0, 10, 0, 46)
rebirthStatusLabel.BackgroundTransparency = 1
rebirthStatusLabel.Text = "[FALTA PODER]"
rebirthStatusLabel.Font = Enum.Font.GothamBlack
rebirthStatusLabel.TextSize = 10
rebirthStatusLabel.TextColor3 = COLOR_RED
rebirthStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
rebirthStatusLabel.Parent = rebirthButton

-- Tarjeta Compacta: Bastón Equipado
local staffCard = Instance.new("Frame")
staffCard.Name = "StaffCard"
staffCard.Size = UDim2.new(1, 0, 0, 62)
staffCard.BackgroundColor3 = COLOR_MIDNIGHT
staffCard.BackgroundTransparency = 0.1
staffCard.BorderSizePixel = 0
staffCard.Parent = leftPanel

local staffCorner = Instance.new("UICorner")
staffCorner.CornerRadius = UDim.new(0, 14)
staffCorner.Parent = staffCard

local staffStroke = Instance.new("UIStroke")
staffStroke.Thickness = 2.5
staffStroke.Color = COLOR_VIOLET
staffStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
staffStroke.Parent = staffCard

local staffGradient = Instance.new("UIGradient")
staffGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 24, 46)),
	ColorSequenceKeypoint.new(1, COLOR_MIDNIGHT),
})
staffGradient.Rotation = 90
staffGradient.Parent = staffCard

local staffTitle = Instance.new("TextLabel")
staffTitle.Size = UDim2.new(1, -16, 0, 18)
staffTitle.Position = UDim2.new(0, 10, 0, 8)
staffTitle.BackgroundTransparency = 1
staffTitle.Text = "🪄 BASTÓN ACTUAL"
staffTitle.Font = Enum.Font.GothamBold
staffTitle.TextSize = 10
staffTitle.TextColor3 = COLOR_VIOLET
staffTitle.TextXAlignment = Enum.TextXAlignment.Left
staffTitle.Parent = staffCard

local staffNameLabel = Instance.new("TextLabel")
staffNameLabel.Name = "StaffName"
staffNameLabel.Size = UDim2.new(1, -16, 0, 24)
staffNameLabel.Position = UDim2.new(0, 10, 0, 28)
staffNameLabel.BackgroundTransparency = 1
staffNameLabel.Text = "Vara de Aprendiz"
staffNameLabel.Font = Enum.Font.GothamBlack
staffNameLabel.TextSize = 12
staffNameLabel.TextColor3 = COLOR_WHITE
staffNameLabel.TextXAlignment = Enum.TextXAlignment.Left
staffNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
staffNameLabel.Parent = staffCard

--------------------------------------------------------------------------------
-- 3. VENTANA MODAL CENTRAL PARA ESTACIONES DE LA LOBBY
--------------------------------------------------------------------------------
local modalOverlay = Instance.new("TextButton")
modalOverlay.Name = "ModalOverlay"
modalOverlay.Size = UDim2.new(1, 0, 1, 0)
modalOverlay.Position = UDim2.new(0, 0, 0, 0)
modalOverlay.BackgroundColor3 = Color3.fromRGB(6, 8, 14)
modalOverlay.BackgroundTransparency = 1
modalOverlay.AutoButtonColor = false
modalOverlay.Text = ""
modalOverlay.Visible = false
modalOverlay.ZIndex = 50
modalOverlay.Parent = screenGui

local modalFrame = Instance.new("Frame")
modalFrame.Name = "ModalFrame"
modalFrame.AnchorPoint = Vector2.new(0.5, 0.5)
modalFrame.Size = UDim2.new(0, 460, 0, 310)
modalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
modalFrame.BackgroundColor3 = COLOR_MIDNIGHT
modalFrame.BorderSizePixel = 0
modalFrame.ClipsDescendants = true
modalFrame.ZIndex = 51
modalFrame.Parent = modalOverlay

local modalCorner = Instance.new("UICorner")
modalCorner.CornerRadius = UDim.new(0, 14)
modalCorner.Parent = modalFrame

local modalStroke = Instance.new("UIStroke")
modalStroke.Thickness = 2.5
modalStroke.Color = COLOR_CYAN
modalStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
modalStroke.Parent = modalFrame

local modalGradient = Instance.new("UIGradient")
modalGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 34, 54)),
	ColorSequenceKeypoint.new(1, COLOR_MIDNIGHT),
})
modalGradient.Rotation = 90
modalGradient.Parent = modalFrame

-- Barra superior de la modal con botón de cierre
local modalCloseBtn = Instance.new("TextButton")
modalCloseBtn.Name = "CloseButton"
modalCloseBtn.Size = UDim2.new(0, 32, 0, 32)
modalCloseBtn.Position = UDim2.new(1, -42, 0, 10)
modalCloseBtn.BackgroundColor3 = Color3.fromRGB(35, 20, 28)
modalCloseBtn.AutoButtonColor = false
modalCloseBtn.Text = "✕"
modalCloseBtn.Font = Enum.Font.GothamBlack
modalCloseBtn.TextSize = 16
modalCloseBtn.TextColor3 = COLOR_RED
modalCloseBtn.ZIndex = 52
modalCloseBtn.Parent = modalFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = modalCloseBtn

local closeStroke = Instance.new("UIStroke")
closeStroke.Thickness = 1.5
closeStroke.Color = COLOR_RED
closeStroke.Parent = modalCloseBtn

local modalIcon = Instance.new("TextLabel")
modalIcon.Name = "ModalIcon"
modalIcon.Size = UDim2.new(0, 48, 0, 48)
modalIcon.Position = UDim2.new(0, 24, 0, 20)
modalIcon.BackgroundTransparency = 1
modalIcon.Text = "⚒️"
modalIcon.Font = Enum.Font.GothamBlack
modalIcon.TextSize = 36
modalIcon.TextColor3 = COLOR_WHITE
modalIcon.ZIndex = 52
modalIcon.Parent = modalFrame

local modalTitle = Instance.new("TextLabel")
modalTitle.Name = "ModalTitle"
modalTitle.Size = UDim2.new(1, -140, 0, 26)
modalTitle.Position = UDim2.new(0, 80, 0, 22)
modalTitle.BackgroundTransparency = 1
modalTitle.Text = "ESTACIÓN ARCANA"
modalTitle.Font = Enum.Font.GothamBlack
modalTitle.TextSize = 20
modalTitle.TextColor3 = COLOR_GOLD
modalTitle.TextXAlignment = Enum.TextXAlignment.Left
modalTitle.ZIndex = 52
modalTitle.Parent = modalFrame

local modalSubtitle = Instance.new("TextLabel")
modalSubtitle.Name = "ModalSubtitle"
modalSubtitle.Size = UDim2.new(1, -140, 0, 18)
modalSubtitle.Position = UDim2.new(0, 80, 0, 48)
modalSubtitle.BackgroundTransparency = 1
modalSubtitle.Text = "Lobby de Magos"
modalSubtitle.Font = Enum.Font.GothamBold
modalSubtitle.TextSize = 12
modalSubtitle.TextColor3 = COLOR_CYAN
modalSubtitle.TextXAlignment = Enum.TextXAlignment.Left
modalSubtitle.ZIndex = 52
modalSubtitle.Parent = modalFrame

local modalDivider = Instance.new("Frame")
modalDivider.Size = UDim2.new(1, -48, 0, 2)
modalDivider.Position = UDim2.new(0, 24, 0, 80)
modalDivider.BackgroundColor3 = COLOR_CYAN
modalDivider.BorderSizePixel = 0
modalDivider.ZIndex = 52
modalDivider.Parent = modalFrame

local dividerGrad = Instance.new("UIGradient")
dividerGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, COLOR_CYAN),
	ColorSequenceKeypoint.new(0.5, COLOR_VIOLET),
	ColorSequenceKeypoint.new(1, COLOR_GOLD),
})
dividerGrad.Parent = modalDivider

local modalContent = Instance.new("TextLabel")
modalContent.Name = "ModalContent"
modalContent.Size = UDim2.new(1, -48, 0, 130)
modalContent.Position = UDim2.new(0, 24, 0, 96)
modalContent.BackgroundTransparency = 1
modalContent.Text = "Contenido de la estación listo para enlazar."
modalContent.Font = Enum.Font.GothamBold
modalContent.TextSize = 13
modalContent.TextColor3 = COLOR_MUTED
modalContent.TextWrapped = true
modalContent.TextYAlignment = Enum.TextYAlignment.Top
modalContent.TextXAlignment = Enum.TextXAlignment.Left
modalContent.ZIndex = 52
modalContent.Parent = modalFrame

local modalActionBtn = Instance.new("TextButton")
modalActionBtn.Name = "ModalActionBtn"
modalActionBtn.Size = UDim2.new(1, -48, 0, 46)
modalActionBtn.Position = UDim2.new(0, 24, 1, -62)
modalActionBtn.BackgroundColor3 = COLOR_MIDNIGHT_LIGHT
modalActionBtn.AutoButtonColor = false
modalActionBtn.Text = "✦ INTERACTUAR ✦"
modalActionBtn.Font = Enum.Font.GothamBlack
modalActionBtn.TextSize = 14
modalActionBtn.TextColor3 = COLOR_WHITE
modalActionBtn.ZIndex = 52
modalActionBtn.Parent = modalFrame

local actionCorner = Instance.new("UICorner")
actionCorner.CornerRadius = UDim.new(0, 12)
actionCorner.Parent = modalActionBtn

local actionStroke = Instance.new("UIStroke")
actionStroke.Thickness = 2
actionStroke.Color = COLOR_CYAN
actionStroke.Parent = modalActionBtn

local actionGrad = Instance.new("UIGradient")
actionGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, COLOR_VIOLET),
	ColorSequenceKeypoint.new(1, COLOR_CYAN),
})
actionGrad.Rotation = 45
actionGrad.Parent = modalActionBtn

local isModalOpen = false
local currentStation = ""

local function closeModal()
	if not isModalOpen then return end
	isModalOpen = false
	currentStation = ""

	local closeTween = TweenService:Create(
		modalFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Size = UDim2.new(0, 360, 0, 240) }
	)
	local fadeTween = TweenService:Create(
		modalOverlay,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ BackgroundTransparency = 1 }
	)

	closeTween:Play()
	fadeTween:Play()
	closeTween.Completed:Connect(function()
		modalOverlay.Visible = false
	end)
end

local function openModal(title: string, subtitle: string, icon: string, description: string, accentColor: Color3)
	if isModalOpen and currentStation == title then
		closeModal()
		return
	end

	currentStation = title
	isModalOpen = true

	modalIcon.Text = icon
	modalTitle.Text = title
	modalSubtitle.Text = subtitle
	modalContent.Text = description
	modalStroke.Color = accentColor
	actionStroke.Color = accentColor

	modalOverlay.Visible = true
	modalFrame.Size = UDim2.new(0, 380, 0, 260)
	modalOverlay.BackgroundTransparency = 1

	local popTween = TweenService:Create(
		modalFrame,
		TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = UDim2.new(0, 460, 0, 310) }
	)
	local fadeTween = TweenService:Create(
		modalOverlay,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.5 }
	)

	popTween:Play()
	fadeTween:Play()
end

modalCloseBtn.MouseButton1Click:Connect(closeModal)
modalOverlay.MouseButton1Click:Connect(function()
	closeModal()
end)

--------------------------------------------------------------------------------
-- 4. MENÚ LATERAL DERECHO (4 BOTONES DE ACCIÓN DE LA LOBBY)
--------------------------------------------------------------------------------
local rightSidebar = Instance.new("Frame")
rightSidebar.Name = "RightSidebar"
rightSidebar.Size = UDim2.new(0, 160, 0, 245)
rightSidebar.Position = UDim2.new(1, -172, 0.5, -122)
rightSidebar.BackgroundTransparency = 1
rightSidebar.Parent = screenGui

local sideLayout = Instance.new("UIListLayout")
sideLayout.FillDirection = Enum.FillDirection.Vertical
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Center
sideLayout.Padding = UDim.new(0, 10)
sideLayout.Parent = rightSidebar

type StationConfig = {
	Title: string,
	Subtitle: string,
	Icon: string,
	Description: string,
	Accent: Color3,
}

local stations: { [string]: StationConfig } = {
	Forjar = {
		Title = "FORJA DE BASTONES",
		Subtitle = "Elaboración Mágica",
		Icon = "⚒️",
		Description = "Usa cristales mágicos, maderas antiguas y esencias para forjar báculos de alto calibre. Cada bastón incrementa exponencialmente el poder obtenido por canalización.",
		Accent = Color3.fromRGB(255, 150, 50),
	},
	Encantar = {
		Title = "MESA DE ENCANTAMIENTOS",
		Subtitle = "Mejora de Hechizos",
		Icon = "✨",
		Description = "Infunde encantamientos elementales en tus armas arcanas: Fuego Ígneo, Escarcha Criogénica o Rayo Cósmico para desbloquear multiplicadores pasivos.",
		Accent = COLOR_VIOLET,
	},
	Mochila = {
		Title = "MOCHILA DE RECURSOS",
		Subtitle = "Inventario de Materiales",
		Icon = "🎒",
		Description = "Consulta tus esencias recolectadas, gemas raras, fragmentos de meteorito y reliquias recogidas a través de todas las zonas mágicas desbloqueadas.",
		Accent = COLOR_CYAN,
	},
	Mercado = {
		Title = "MERCADO ARCANO",
		Subtitle = "Compra y Venta",
		Icon = "🏪",
		Description = "Intercambia tus materiales excedentes por Monedas doradas o adquiere esencias exóticas que no se encuentran en las zonas iniciales.",
		Accent = COLOR_GOLD,
	},
}

local function createSidebarButton(nameKey: string, text: string, accentColor: Color3)
	local btn = Instance.new("TextButton")
	btn.Name = nameKey .. "Btn"
	btn.Size = UDim2.new(0, 152, 0, 48)
	btn.BackgroundColor3 = COLOR_MIDNIGHT
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.Parent = rightSidebar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2.5
	stroke.Color = accentColor
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = btn

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 28, 44)),
		ColorSequenceKeypoint.new(1, COLOR_MIDNIGHT),
	})
	gradient.Rotation = 90
	gradient.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -12, 1, 0)
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 13
	lbl.TextColor3 = COLOR_WHITE
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = btn

	-- Efectos táctiles hover / juice
	btn.MouseEnter:Connect(function()
		TweenService:Create(
			btn,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 158, 0, 48), BackgroundColor3 = COLOR_MIDNIGHT_LIGHT }
		):Play()
		TweenService:Create(
			stroke,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Thickness = 3.2 }
		):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(
			btn,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 152, 0, 48), BackgroundColor3 = COLOR_MIDNIGHT }
		):Play()
		TweenService:Create(
			stroke,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Thickness = 2.5 }
		):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		local cfg = stations[nameKey]
		if cfg then
			openModal(cfg.Title, cfg.Subtitle, cfg.Icon, cfg.Description, cfg.Accent)
		end
	end)

	return btn
end

createSidebarButton("Forjar", "⚒️ FORJAR", Color3.fromRGB(255, 150, 50))
createSidebarButton("Encantar", "✨ ENCANTAR", COLOR_VIOLET)
createSidebarButton("Mochila", "🎒 MOCHILA", COLOR_CYAN)
createSidebarButton("Mercado", "🏪 MERCADO", COLOR_GOLD)

--------------------------------------------------------------------------------
-- 5. BOTÓN INFERIOR CENTRAL DE CANALIZAR MAGIA (ENTRENAMIENTO)
--------------------------------------------------------------------------------
local channelButton = Instance.new("TextButton")
channelButton.Name = "ChannelPowerButton"
channelButton.Size = UDim2.new(0, 280, 0, 68)
channelButton.Position = UDim2.new(0.5, -140, 1, -95)
channelButton.BackgroundColor3 = Color3.fromRGB(24, 20, 48)
channelButton.AutoButtonColor = false
channelButton.Text = "✨ CANALIZAR PODER"
channelButton.Font = Enum.Font.GothamBlack
channelButton.TextSize = 20
channelButton.TextColor3 = COLOR_WHITE
channelButton.Parent = screenGui

local channelCorner = Instance.new("UICorner")
channelCorner.CornerRadius = UDim.new(0, 14)
channelCorner.Parent = channelButton

local channelStroke = Instance.new("UIStroke")
channelStroke.Thickness = 2.5
channelStroke.Color = Color3.fromRGB(220, 245, 255)
channelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
channelStroke.Parent = channelButton

local channelGradient = Instance.new("UIGradient")
channelGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, COLOR_VIOLET),
	ColorSequenceKeypoint.new(1, COLOR_CYAN),
})
channelGradient.Rotation = 45
channelGradient.Parent = channelButton

-- Animación de número flotante arcano
local function spawnFloatingGain(amount: number)
	local floatLbl = Instance.new("TextLabel")
	floatLbl.Name = "FloatingGain"
	floatLbl.Size = UDim2.new(0, 160, 0, 36)
	local randX = math.random(-80, 80)
	floatLbl.Position = UDim2.new(0.5, randX - 80, 1, -140)
	floatLbl.BackgroundTransparency = 1
	floatLbl.Text = "+" .. formatNumber(amount) .. " ⚡"
	floatLbl.Font = Enum.Font.GothamBlack
	floatLbl.TextSize = 24
	floatLbl.TextColor3 = COLOR_CYAN
	floatLbl.TextStrokeTransparency = 0.3
	floatLbl.TextStrokeColor3 = Color3.fromRGB(8, 12, 28)
	floatLbl.ZIndex = 40
	floatLbl.Parent = screenGui

	local tween = TweenService:Create(
		floatLbl,
		TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Position = floatLbl.Position - UDim2.new(0, 0, 0, 70),
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		floatLbl:Destroy()
	end)
end

-- Acción de canalización
local isBouncing = false
local function triggerChannel()
	if doClickEvent and doClickEvent:IsA("RemoteEvent") then
		pcall(function()
			doClickEvent:FireServer()
		end)
	end

	local rebirthsVal = rebirthsStat and rebirthsStat.Value or 0
	local multPuesto = player:GetAttribute("MultPuesto") or 1
	local gain = 1 * multPuesto * (1 + rebirthsVal * 0.5)
	spawnFloatingGain(gain)

	-- Animación de Juice (rebote elástico)
	if not isBouncing then
		isBouncing = true
		local shrinkTween = TweenService:Create(
			channelButton,
			TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(0, 260, 0, 62),
				Position = UDim2.new(0.5, -130, 1, -92),
			}
		)
		shrinkTween:Play()
		shrinkTween.Completed:Connect(function()
			local returnTween = TweenService:Create(
				channelButton,
				TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = UDim2.new(0, 280, 0, 68),
					Position = UDim2.new(0.5, -140, 1, -95),
				}
			)
			returnTween:Play()
			returnTween.Completed:Connect(function()
				isBouncing = false
			end)
		end)
	end
end

channelButton.MouseButton1Click:Connect(triggerChannel)

-- Disparador también al hacer clic o tocar la pantalla (cuando no se interactúa con la interfaz modal)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or isModalOpen then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		triggerChannel()
	end
end)

--------------------------------------------------------------------------------
-- 6. ACTUALIZACIÓN DINÁMICA DE ESTADÍSTICAS Y ESTADOS
--------------------------------------------------------------------------------
local function updateStats()
	local poder = poderStat and poderStat.Value or 0
	local monedas = monedasStat and monedasStat.Value or 0
	local rebirths = rebirthsStat and rebirthsStat.Value or 0

	poderValueLabel.Text = formatNumber(poder)
	monedasValueLabel.Text = formatNumber(monedas)

	local multiplier = 1.0 + (rebirths * 0.5)
	rebirthsValueLabel.Text = string.format("%d (%.1fx)", rebirths, multiplier)

	-- Costo de Rebirth en Poder: 1000 * (1.8 ^ Rebirths)
	local rebirthCost = math.floor(1000 * (1.8 ^ rebirths))
	rebirthCostLabel.Text = "Costo: ⚡ " .. formatNumber(rebirthCost)

	if poder >= rebirthCost then
		rebirthStroke.Color = COLOR_GREEN
		rebirthStatusLabel.Text = "✦ LISTO PARA ASCENDER ✦"
		rebirthStatusLabel.TextColor3 = COLOR_GREEN
		rebirthButton.BackgroundColor3 = Color3.fromRGB(18, 38, 28)
	else
		rebirthStroke.Color = COLOR_RED
		rebirthStatusLabel.Text = "[FALTA PODER]"
		rebirthStatusLabel.TextColor3 = COLOR_RED
		rebirthButton.BackgroundColor3 = COLOR_MIDNIGHT
	end

	-- Bastón equipado
	local staffName = player:GetAttribute("BastonesEquipado")
		or player:GetAttribute("BastonEquipado")
		or "Vara de Aprendiz"
	staffNameLabel.Text = tostring(staffName)
end

-- Ejecución de Rebirth al pulsar el botón
rebirthButton.MouseButton1Click:Connect(function()
	local poder = poderStat and poderStat.Value or 0
	local rebirths = rebirthsStat and rebirthsStat.Value or 0
	local rebirthCost = math.floor(1000 * (1.8 ^ rebirths))

	if poder >= rebirthCost then
		if rebirthEvent and rebirthEvent:IsA("RemoteEvent") then
			pcall(function()
				rebirthEvent:FireServer()
			end)
		end
	else
		-- Feedback visual de que falta poder
		local shake = TweenService:Create(
			rebirthButton,
			TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true),
			{ Position = UDim2.new(0, 24, 0.5, -85) }
		)
		shake:Play()
		shake.Completed:Connect(function()
			rebirthButton.Position = UDim2.new(0, 0, 0, 0) -- controlado por el list layout
		end)
	end
end)

-- Conectar cambios de atributos de bastón
player:GetAttributeChangedSignal("BastonesEquipado"):Connect(updateStats)
player:GetAttributeChangedSignal("BastonEquipado"):Connect(updateStats)

-- Conectar cambios de valores de leaderstats
if poderStat then
	poderStat.Changed:Connect(updateStats)
end
if monedasStat then
	monedasStat.Changed:Connect(updateStats)
end
if rebirthsStat then
	rebirthsStat.Changed:Connect(updateStats)
end

-- Actualización inicial
updateStats()
