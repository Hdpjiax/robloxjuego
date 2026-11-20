--!strict
-- MainHUD.client.luau
-- Wizard Craft & Combat Simulator - HUD Definitivo con Iconografía Real y Alto Contraste
-- Enfoque: Magos que construyen bastones, recogen materiales en zonas, entrenan en puestos y ascienden (Rebirth)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")

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
local craftStaffEvent = ReplicatedStorage:WaitForChild("CraftStaff", 10)
local sellMaterialsEvent = ReplicatedStorage:WaitForChild("SellMaterials", 10)
local petEvent = ReplicatedStorage:WaitForChild("PetAction", 10)

local StavesData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("StavesData"))

--------------------------------------------------------------------------------
-- ICONOS REALES VERIFICADOS DE ROBLOX (Decal Textures 100% Transparentes y Nítidas)
--------------------------------------------------------------------------------
local ICONS = {
	Coin = "rbxassetid://6020249523",       -- Moneda de Oro Nítida
	Zap = "rbxassetid://477143964",         -- Rayo Eléctrico Azul Transparente Nítido
	Star = "rbxassetid://3057073083",       -- Estrella Blanca de Rebirth Nítida
	Wand = "rbxassetid://6412254026",       -- Varita Mágica Nítida Transparente
	Hammer = "rbxassetid://127904742940104", -- Martillo de Forja Nítido Transparente
	Backpack = "rbxassetid://124233015832617", -- Mochila de Materiales Nítida Transparente
	Cart = "rbxassetid://1906246466",       -- Carrito de Mercado Nítido Transparente
}

-- Precarga de texturas
task.spawn(function()
	local toPreload = {}
	for _, id in pairs(ICONS) do
		local img = Instance.new("ImageLabel")
		img.Image = id
		table.insert(toPreload, img)
	end
	pcall(function()
		ContentProvider:PreloadAsync(toPreload)
	end)
end)

--------------------------------------------------------------------------------
-- PALETA DE COLOR DE ALTA LUMINOSIDAD Y CONTRASTE (Cero fondos negros planos)
--------------------------------------------------------------------------------
local C_GOLD = Color3.fromRGB(255, 215, 0)
local C_GOLD_DARK = Color3.fromRGB(210, 145, 10)
local C_GOLD_BG = Color3.fromRGB(60, 48, 22)
local C_GOLD_BOT = Color3.fromRGB(42, 32, 16)

local C_CYAN = Color3.fromRGB(0, 230, 255)
local C_CYAN_DARK = Color3.fromRGB(0, 145, 225)
local C_CYAN_BG = Color3.fromRGB(24, 52, 85)
local C_CYAN_BOT = Color3.fromRGB(16, 36, 60)

local C_VIOLET = Color3.fromRGB(185, 135, 255)
local C_VIOLET_DARK = Color3.fromRGB(120, 50, 220)
local C_VIOLET_BG = Color3.fromRGB(54, 30, 82)
local C_VIOLET_BOT = Color3.fromRGB(36, 18, 58)

local C_AMBER = Color3.fromRGB(255, 145, 40)
local C_AMBER_DARK = Color3.fromRGB(190, 80, 10)
local C_AMBER_BG = Color3.fromRGB(62, 36, 20)
local C_AMBER_BOT = Color3.fromRGB(42, 22, 12)

local C_PANEL_TOP = Color3.fromRGB(38, 48, 78)
local C_PANEL_BOT = Color3.fromRGB(24, 30, 52)

local C_EMERALD = Color3.fromRGB(0, 235, 140)
local C_EMERALD_DARK = Color3.fromRGB(0, 160, 90)

local C_CRIMSON = Color3.fromRGB(235, 60, 75)
local C_CRIMSON_DARK = Color3.fromRGB(160, 30, 45)

local C_WHITE = Color3.fromRGB(255, 255, 255)
local C_TEXT_MUTED = Color3.fromRGB(190, 210, 245)
local C_STROKE_SHADOW = Color3.fromRGB(8, 10, 20)

-- Formateador numérico
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
-- HELPER: CREACIÓN DE PANELES CON CONTRASTE VISUAL Y BRILLO
--------------------------------------------------------------------------------
local function applyLuminousCard(frame: Frame, cornerRadius: number, strokeColor: Color3, topColor: Color3, botColor: Color3)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, cornerRadius)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2.5
	stroke.Color = strokeColor
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = frame

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, topColor),
		ColorSequenceKeypoint.new(1, botColor),
	})
	gradient.Rotation = 90
	gradient.Parent = frame

	local shine = Instance.new("Frame")
	shine.Name = "TopShine"
	shine.Size = UDim2.new(1, -12, 0, 1.5)
	shine.Position = UDim2.new(0, 6, 0, 1)
	shine.BackgroundColor3 = C_WHITE
	shine.BackgroundTransparency = 0.6
	shine.BorderSizePixel = 0
	shine.ZIndex = frame.ZIndex + 1
	shine.Parent = frame

	return stroke
end

--------------------------------------------------------------------------------
-- 1. TARJETAS SUPERIORES COMPACTAS CON ICONOS REALES Y COLOR DIFERENCIADO
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

local function createTopStatPill(title: string, iconId: string, accentColor: Color3, darkColor: Color3, bgTop: Color3, bgBot: Color3)
	local card = Instance.new("Frame")
	card.Name = title .. "Pill"
	card.Size = UDim2.new(0, 158, 0, 52)
	card.BackgroundColor3 = bgTop
	card.BorderSizePixel = 0
	card.Parent = topContainer

	applyLuminousCard(card, 14, accentColor, bgTop, bgBot)

	-- Insignia Circular con Icono Real Tintado
	local badge = Instance.new("Frame")
	badge.Name = "IconBadge"
	badge.Size = UDim2.new(0, 40, 0, 40)
	badge.Position = UDim2.new(0, 6, 0.5, -20)
	badge.BackgroundColor3 = accentColor
	badge.BorderSizePixel = 0
	badge.ZIndex = card.ZIndex + 2
	badge.Parent = card

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(1, 0)
	badgeCorner.Parent = badge

	local badgeGrad = Instance.new("UIGradient")
	badgeGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, accentColor),
		ColorSequenceKeypoint.new(1, darkColor),
	})
	badgeGrad.Rotation = 45
	badgeGrad.Parent = badge

	local badgeStroke = Instance.new("UIStroke")
	badgeStroke.Thickness = 2
	badgeStroke.Color = C_WHITE
	badgeStroke.Transparency = 0.2
	badgeStroke.Parent = badge

	local iconImg = Instance.new("ImageLabel")
	iconImg.Name = "Icon"
	iconImg.Size = UDim2.new(0, 24, 0, 24)
	iconImg.Position = UDim2.new(0.5, -12, 0.5, -12)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = iconId
	iconImg.ImageColor3 = C_WHITE
	iconImg.ZIndex = badge.ZIndex + 1
	iconImg.Parent = badge

	-- Textos (Título + Valor)
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -54, 0, 14)
	titleLbl.Position = UDim2.new(0, 52, 0, 7)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = string.upper(title)
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 10
	titleLbl.TextColor3 = accentColor
	titleLbl.TextStrokeColor3 = C_STROKE_SHADOW
	titleLbl.TextStrokeTransparency = 0.2
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.ZIndex = card.ZIndex + 2
	titleLbl.Parent = card

	local valLbl = Instance.new("TextLabel")
	valLbl.Name = "Value"
	valLbl.Size = UDim2.new(1, -54, 0, 24)
	valLbl.Position = UDim2.new(0, 52, 0, 21)
	valLbl.BackgroundTransparency = 1
	valLbl.Text = "0"
	valLbl.Font = Enum.Font.GothamBlack
	valLbl.TextSize = 16
	valLbl.TextColor3 = C_WHITE
	valLbl.TextStrokeColor3 = C_STROKE_SHADOW
	valLbl.TextStrokeTransparency = 0.1
	valLbl.TextXAlignment = Enum.TextXAlignment.Left
	valLbl.ZIndex = card.ZIndex + 2
	valLbl.Parent = card

	return valLbl
end

local monedasLabel = createTopStatPill("Monedas", ICONS.Coin, C_GOLD, C_GOLD_DARK, C_GOLD_BG, C_GOLD_BOT)
local poderLabel = createTopStatPill("Poder", ICONS.Zap, C_CYAN, C_CYAN_DARK, C_CYAN_BG, C_CYAN_BOT)
local rebirthsLabel = createTopStatPill("Rebirths", ICONS.Star, C_VIOLET, C_VIOLET_DARK, C_VIOLET_BG, C_VIOLET_BOT)

--------------------------------------------------------------------------------
-- 2. PANEL IZQUIERDO: REBIRTH (ALTO CONTRASTE), BASTÓN Y ZONA DE ENTRENAMIENTO
--------------------------------------------------------------------------------
local leftPanel = Instance.new("Frame")
leftPanel.Name = "LeftPanel"
leftPanel.Size = UDim2.new(0, 210, 0, 215)
leftPanel.Position = UDim2.new(0, 18, 0.5, -107)
leftPanel.BackgroundTransparency = 1
leftPanel.Parent = screenGui

local leftLayout = Instance.new("UIListLayout")
leftLayout.FillDirection = Enum.FillDirection.Vertical
leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
leftLayout.VerticalAlignment = Enum.VerticalAlignment.Center
leftLayout.Padding = UDim.new(0, 10)
leftLayout.Parent = leftPanel

-- TARJETA DE ASCENSIÓN (REBIRTH)
local rebirthCard = Instance.new("Frame")
rebirthCard.Name = "RebirthCard"
rebirthCard.Size = UDim2.new(1, 0, 0, 106)
rebirthCard.BackgroundColor3 = C_PANEL_TOP
rebirthCard.BorderSizePixel = 0
rebirthCard.Parent = leftPanel

local rebCardStroke = applyLuminousCard(rebirthCard, 14, C_VIOLET, C_PANEL_TOP, C_PANEL_BOT)

-- Cabecera Rebirth
local rebHeader = Instance.new("Frame")
rebHeader.Size = UDim2.new(1, -16, 0, 22)
rebHeader.Position = UDim2.new(0, 8, 0, 6)
rebHeader.BackgroundTransparency = 1
rebHeader.Parent = rebirthCard

local rebIcon = Instance.new("ImageLabel")
rebIcon.Size = UDim2.new(0, 20, 0, 20)
rebIcon.Position = UDim2.new(0, 0, 0.5, -10)
rebIcon.BackgroundTransparency = 1
rebIcon.Image = ICONS.Star
rebIcon.ImageColor3 = C_VIOLET
rebIcon.Parent = rebHeader

local rebTitle = Instance.new("TextLabel")
rebTitle.Size = UDim2.new(0, 95, 1, 0)
rebTitle.Position = UDim2.new(0, 24, 0, 0)
rebTitle.BackgroundTransparency = 1
rebTitle.Text = "ASCENSIÓN"
rebTitle.Font = Enum.Font.GothamBlack
rebTitle.TextSize = 12
rebTitle.TextColor3 = C_VIOLET
rebTitle.TextStrokeColor3 = C_STROKE_SHADOW
rebTitle.TextStrokeTransparency = 0.2
rebTitle.TextXAlignment = Enum.TextXAlignment.Left
rebTitle.Parent = rebHeader

local rebCostTag = Instance.new("TextLabel")
rebCostTag.Name = "CostTag"
rebCostTag.Size = UDim2.new(1, -120, 1, 0)
rebCostTag.Position = UDim2.new(0, 118, 0, 0)
rebCostTag.BackgroundTransparency = 1
rebCostTag.Text = "⚡ 1.00K"
rebCostTag.Font = Enum.Font.GothamBlack
rebCostTag.TextSize = 11
rebCostTag.TextColor3 = C_CYAN
rebCostTag.TextStrokeColor3 = C_STROKE_SHADOW
rebCostTag.TextStrokeTransparency = 0.2
rebCostTag.TextXAlignment = Enum.TextXAlignment.Right
rebCostTag.Parent = rebHeader

-- Barra de Progreso Hacia Rebirth
local pbarBg = Instance.new("Frame")
pbarBg.Name = "ProgressBarBg"
pbarBg.Size = UDim2.new(1, -16, 0, 16)
pbarBg.Position = UDim2.new(0, 8, 0, 30)
pbarBg.BackgroundColor3 = Color3.fromRGB(14, 18, 32)
pbarBg.BorderSizePixel = 0
pbarBg.Parent = rebirthCard

local pbarCorner = Instance.new("UICorner")
pbarCorner.CornerRadius = UDim.new(1, 0)
pbarCorner.Parent = pbarBg

local pbarStroke = Instance.new("UIStroke")
pbarStroke.Thickness = 1.2
pbarStroke.Color = Color3.fromRGB(65, 80, 125)
pbarStroke.Parent = pbarBg

local pbarFill = Instance.new("Frame")
pbarFill.Name = "Fill"
pbarFill.Size = UDim2.new(0.05, 0, 1, 0)
pbarFill.BackgroundColor3 = C_CYAN
pbarFill.BorderSizePixel = 0
pbarFill.Parent = pbarBg

local pbarFillCorner = Instance.new("UICorner")
pbarFillCorner.CornerRadius = UDim.new(1, 0)
pbarFillCorner.Parent = pbarFill

local pbarFillGrad = Instance.new("UIGradient")
pbarFillGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C_CYAN),
	ColorSequenceKeypoint.new(1, C_VIOLET),
})
pbarFillGrad.Parent = pbarFill

local pbarPercent = Instance.new("TextLabel")
pbarPercent.Name = "Percent"
pbarPercent.Size = UDim2.new(1, 0, 1, 0)
pbarPercent.BackgroundTransparency = 1
pbarPercent.Text = "0%"
pbarPercent.Font = Enum.Font.GothamBlack
pbarPercent.TextSize = 10
pbarPercent.TextColor3 = C_WHITE
pbarPercent.TextStrokeColor3 = C_STROKE_SHADOW
pbarPercent.TextStrokeTransparency = 0.1
pbarPercent.Parent = pbarBg

-- Botón de Acción Rebirth (¡Muy Claro y Legible!)
local rebBtn = Instance.new("TextButton")
rebBtn.Name = "RebirthActionBtn"
rebBtn.Size = UDim2.new(1, -16, 0, 38)
rebBtn.Position = UDim2.new(0, 8, 0, 56)
rebBtn.BackgroundColor3 = C_CRIMSON
rebBtn.AutoButtonColor = false
rebBtn.Text = "FALTA PODER"
rebBtn.Font = Enum.Font.GothamBlack
rebBtn.TextSize = 12
rebBtn.TextColor3 = C_WHITE
rebBtn.TextStrokeColor3 = Color3.fromRGB(40, 10, 15)
rebBtn.TextStrokeTransparency = 0.2
rebBtn.Parent = rebirthCard

local rebBtnCorner = Instance.new("UICorner")
rebBtnCorner.CornerRadius = UDim.new(0, 10)
rebBtnCorner.Parent = rebBtn

local rebBtnStroke = Instance.new("UIStroke")
rebBtnStroke.Thickness = 2
rebBtnStroke.Color = Color3.fromRGB(255, 120, 130)
rebBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rebBtnStroke.Parent = rebBtn

local rebBtnGrad = Instance.new("UIGradient")
rebBtnGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C_CRIMSON),
	ColorSequenceKeypoint.new(1, C_CRIMSON_DARK),
})
rebBtnGrad.Rotation = 90
rebBtnGrad.Parent = rebBtn

-- TARJETA COMPACTA: BASTÓN EQUIPADO
local staffCard = Instance.new("Frame")
staffCard.Name = "StaffCard"
staffCard.Size = UDim2.new(1, 0, 0, 64)
staffCard.BackgroundColor3 = C_PANEL_TOP
staffCard.BorderSizePixel = 0
staffCard.Parent = leftPanel

applyLuminousCard(staffCard, 14, C_CYAN, C_PANEL_TOP, C_PANEL_BOT)

local staffBadge = Instance.new("Frame")
staffBadge.Size = UDim2.new(0, 44, 0, 44)
staffBadge.Position = UDim2.new(0, 8, 0.5, -22)
staffBadge.BackgroundColor3 = Color3.fromRGB(35, 52, 85)
staffBadge.BorderSizePixel = 0
staffBadge.Parent = staffCard

local staffBadgeCorner = Instance.new("UICorner")
staffBadgeCorner.CornerRadius = UDim.new(0, 10)
staffBadgeCorner.Parent = staffBadge

local staffBadgeStroke = Instance.new("UIStroke")
staffBadgeStroke.Thickness = 1.8
staffBadgeStroke.Color = C_CYAN
staffBadgeStroke.Parent = staffBadge

local staffIcon = Instance.new("ImageLabel")
staffIcon.Size = UDim2.new(0, 26, 0, 26)
staffIcon.Position = UDim2.new(0.5, -13, 0.5, -13)
staffIcon.BackgroundTransparency = 1
staffIcon.Image = ICONS.Wand
staffIcon.ImageColor3 = C_WHITE
staffIcon.Parent = staffBadge

local staffSub = Instance.new("TextLabel")
staffSub.Size = UDim2.new(1, -64, 0, 14)
staffSub.Position = UDim2.new(0, 58, 0, 11)
staffSub.BackgroundTransparency = 1
staffSub.Text = "BASTÓN EQUIPADO"
staffSub.Font = Enum.Font.GothamBold
staffSub.TextSize = 10
staffSub.TextColor3 = C_TEXT_MUTED
staffSub.TextStrokeColor3 = C_STROKE_SHADOW
staffSub.TextStrokeTransparency = 0.4
staffSub.TextXAlignment = Enum.TextXAlignment.Left
staffSub.Parent = staffCard

local staffNameLabel = Instance.new("TextLabel")
staffNameLabel.Name = "StaffName"
staffNameLabel.Size = UDim2.new(1, -64, 0, 22)
staffNameLabel.Position = UDim2.new(0, 58, 0, 27)
staffNameLabel.BackgroundTransparency = 1
staffNameLabel.Text = "Vara de Aprendiz"
staffNameLabel.Font = Enum.Font.GothamBlack
staffNameLabel.TextSize = 13
staffNameLabel.TextColor3 = C_WHITE
staffNameLabel.TextStrokeColor3 = C_STROKE_SHADOW
staffNameLabel.TextStrokeTransparency = 0.2
staffNameLabel.TextXAlignment = Enum.TextXAlignment.Left
staffNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
staffNameLabel.Parent = staffCard

-- BADGE INDICADOR DE PUESTO DE ENTRENAMIENTO
local trainingBadge = Instance.new("Frame")
trainingBadge.Name = "TrainingBadge"
trainingBadge.Size = UDim2.new(1, 0, 0, 28)
trainingBadge.BackgroundColor3 = Color3.fromRGB(24, 34, 58)
trainingBadge.BorderSizePixel = 0
trainingBadge.Parent = leftPanel

local trCorner = Instance.new("UICorner")
trCorner.CornerRadius = UDim.new(0, 8)
trCorner.Parent = trainingBadge

local trStroke = Instance.new("UIStroke")
trStroke.Thickness = 1.5
trStroke.Color = Color3.fromRGB(80, 105, 160)
trStroke.Parent = trainingBadge

local trText = Instance.new("TextLabel")
trText.Name = "Text"
trText.Size = UDim2.new(1, -12, 1, 0)
trText.Position = UDim2.new(0, 6, 0, 0)
trText.BackgroundTransparency = 1
trText.Text = "⚡ PUESTO: LOBBY (x1.0 PODER)"
trText.Font = Enum.Font.GothamBlack
trText.TextSize = 10
trText.TextColor3 = C_CYAN
trText.TextStrokeColor3 = C_STROKE_SHADOW
trText.TextStrokeTransparency = 0.3
trText.TextXAlignment = Enum.TextXAlignment.Center
trText.Parent = trainingBadge

--------------------------------------------------------------------------------
-- 3. VENTANA MODAL CENTRAL: ESTACIONES DE LA LOBBY (FORJA, ENCANTAR, MOCHILA, MERCADO)
--------------------------------------------------------------------------------
local modalOverlay = Instance.new("TextButton")
modalOverlay.Name = "ModalOverlay"
modalOverlay.Size = UDim2.new(1, 0, 1, 0)
modalOverlay.BackgroundColor3 = Color3.fromRGB(4, 6, 14)
modalOverlay.BackgroundTransparency = 1
modalOverlay.AutoButtonColor = false
modalOverlay.Text = ""
modalOverlay.Visible = false
modalOverlay.ZIndex = 50
modalOverlay.Parent = screenGui

local modalCard = Instance.new("Frame")
modalCard.Name = "ModalCard"
modalCard.AnchorPoint = Vector2.new(0.5, 0.5)
modalCard.Size = UDim2.new(0, 490, 0, 340)
modalCard.Position = UDim2.new(0.5, 0, 0.5, 0)
modalCard.BackgroundColor3 = C_PANEL_TOP
modalCard.BorderSizePixel = 0
modalCard.ClipsDescendants = true
modalCard.ZIndex = 51
modalCard.Parent = modalOverlay

local modalStroke = applyLuminousCard(modalCard, 18, C_VIOLET, C_PANEL_TOP, C_PANEL_BOT)

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -44, 0, 12)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
closeBtn.AutoButtonColor = false
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 18
closeBtn.TextColor3 = C_WHITE
closeBtn.ZIndex = 53
closeBtn.Parent = modalCard

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

local closeStroke = Instance.new("UIStroke")
closeStroke.Thickness = 2.5
closeStroke.Color = Color3.fromRGB(255, 160, 170)
closeStroke.Parent = closeBtn

local modalBadge = Instance.new("Frame")
modalBadge.Size = UDim2.new(0, 52, 0, 52)
modalBadge.Position = UDim2.new(0, 22, 0, 16)
modalBadge.BackgroundColor3 = Color3.fromRGB(40, 52, 85)
modalBadge.BorderSizePixel = 0
modalBadge.ZIndex = 52
modalBadge.Parent = modalCard

local modalBadgeCorner = Instance.new("UICorner")
modalBadgeCorner.CornerRadius = UDim.new(0, 14)
modalBadgeCorner.Parent = modalBadge

local modalBadgeStroke = Instance.new("UIStroke")
modalBadgeStroke.Thickness = 2
modalBadgeStroke.Color = C_VIOLET
modalBadgeStroke.Parent = modalBadge

local modalBadgeIcon = Instance.new("ImageLabel")
modalBadgeIcon.Name = "Icon"
modalBadgeIcon.Size = UDim2.new(0, 32, 0, 32)
modalBadgeIcon.Position = UDim2.new(0.5, -16, 0.5, -16)
modalBadgeIcon.BackgroundTransparency = 1
modalBadgeIcon.Image = ICONS.Hammer
modalBadgeIcon.ImageColor3 = C_WHITE
modalBadgeIcon.ZIndex = 53
modalBadgeIcon.Parent = modalBadge

local modalTitle = Instance.new("TextLabel")
modalTitle.Name = "Title"
modalTitle.Size = UDim2.new(1, -145, 0, 24)
modalTitle.Position = UDim2.new(0, 86, 0, 18)
modalTitle.BackgroundTransparency = 1
modalTitle.Text = "ESTACIÓN"
modalTitle.Font = Enum.Font.GothamBlack
modalTitle.TextSize = 20
modalTitle.TextColor3 = C_WHITE
modalTitle.TextStrokeColor3 = C_STROKE_SHADOW
modalTitle.TextStrokeTransparency = 0.2
modalTitle.TextXAlignment = Enum.TextXAlignment.Left
modalTitle.ZIndex = 52
modalTitle.Parent = modalCard

local modalSub = Instance.new("TextLabel")
modalSub.Name = "Sub"
modalSub.Size = UDim2.new(1, -145, 0, 16)
modalSub.Position = UDim2.new(0, 86, 0, 44)
modalSub.BackgroundTransparency = 1
modalSub.Text = "Lobby de Magos"
modalSub.Font = Enum.Font.GothamBold
modalSub.TextSize = 12
modalSub.TextColor3 = C_TEXT_MUTED
modalSub.TextXAlignment = Enum.TextXAlignment.Left
modalSub.ZIndex = 52
modalSub.Parent = modalCard

local modalDivider = Instance.new("Frame")
modalDivider.Size = UDim2.new(1, -44, 0, 2)
modalDivider.Position = UDim2.new(0, 22, 0, 78)
modalDivider.BackgroundColor3 = C_CYAN
modalDivider.BorderSizePixel = 0
modalDivider.ZIndex = 52
modalDivider.Parent = modalCard

local modalDesc = Instance.new("TextLabel")
modalDesc.Name = "Desc"
modalDesc.Size = UDim2.new(1, -44, 0, 140)
modalDesc.Position = UDim2.new(0, 22, 0, 92)
modalDesc.BackgroundTransparency = 1
modalDesc.Text = "Descripción de la estación."
modalDesc.Font = Enum.Font.GothamBold
modalDesc.TextSize = 13
modalDesc.TextColor3 = Color3.fromRGB(220, 230, 255)
modalDesc.TextWrapped = true
modalDesc.TextYAlignment = Enum.TextYAlignment.Top
modalDesc.TextXAlignment = Enum.TextXAlignment.Left
modalDesc.ZIndex = 52
modalDesc.Parent = modalCard

local modalAction = Instance.new("TextButton")
modalAction.Name = "ActionBtn"
modalAction.Size = UDim2.new(1, -44, 0, 48)
modalAction.Position = UDim2.new(0, 22, 1, -64)
modalAction.BackgroundColor3 = C_VIOLET
modalAction.AutoButtonColor = false
modalAction.Text = "✦ ABRIR ESTACIÓN ✦"
modalAction.Font = Enum.Font.GothamBlack
modalAction.TextSize = 14
modalAction.TextColor3 = C_WHITE
modalAction.TextStrokeColor3 = C_STROKE_SHADOW
modalAction.TextStrokeTransparency = 0.2
modalAction.ZIndex = 53
modalAction.Parent = modalCard

local modalActionCorner = Instance.new("UICorner")
modalActionCorner.CornerRadius = UDim.new(0, 12)
modalActionCorner.Parent = modalAction

local modalActionGrad = Instance.new("UIGradient")
modalActionGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C_VIOLET),
	ColorSequenceKeypoint.new(1, C_CYAN),
})
modalActionGrad.Rotation = 45
modalActionGrad.Parent = modalAction

local isModalOpen = false
local currentStationKey = ""

local function closeModal()
	if not isModalOpen then return end
	isModalOpen = false
	currentStationKey = ""

	local shrink = TweenService:Create(
		modalCard,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Size = UDim2.new(0, 410, 0, 270) }
	)
	local fade = TweenService:Create(
		modalOverlay,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ BackgroundTransparency = 1 }
	)

	shrink:Play()
	fade:Play()
	shrink.Completed:Connect(function()
		modalOverlay.Visible = false
	end)
end

local function openModal(key: string, title: string, subtitle: string, iconId: string, desc: string, accentColor: Color3)
	if isModalOpen and currentStationKey == key then
		closeModal()
		return
	end

	currentStationKey = key
	isModalOpen = true

	modalTitle.Text = title
	modalSub.Text = subtitle
	modalBadgeIcon.Image = iconId
	modalBadgeStroke.Color = accentColor
	modalDesc.Text = desc
	modalStroke.Color = accentColor
	modalDivider.BackgroundColor3 = accentColor

	-- Contenido dinámico según la estación
	if key == "Forjar" then
		local curStaffId = player:GetAttribute("BastonEquipado") or "VaraDeAprendiz"
		local curStaff = StavesData.getStaff(curStaffId)

		local mats = player:FindFirstChild("Materiales")
		local woodVal = mats and mats:FindFirstChild("MaderaArcana") and (mats:FindFirstChild("MaderaArcana") :: NumberValue).Value or 0
		local crystalVal = mats and mats:FindFirstChild("CristalCeleste") and (mats:FindFirstChild("CristalCeleste") :: NumberValue).Value or 0
		local slimeVal = mats and mats:FindFirstChild("GelatinaSlime") and (mats:FindFirstChild("GelatinaSlime") :: NumberValue).Value or 0

		modalDesc.Text = string.format(
			"🔥 FORJA ALQUÍMICA (CATÁLOGO DE 100 BASTONES ARCANOS):\n\n" ..
			"• Bastón Equipado: %s [%s]\n  (Mult: x%.1f | Daño: %d)\n\n" ..
			"📦 Tus Materiales en Mochila:\n" ..
			"  - Madera Arcana: %d (Requiere 10)\n" ..
			"  - Cristales Celestes: %d (Requiere 3)\n" ..
			"  - Gelatina Slime: %d\n\n" ..
			"🎲 Probabilidades de Forja:\n" ..
			"  [Común 50%%] [Poco Común 28%%] [Raro 14%%]\n" ..
			"  [Épico 5.5%%] [Legendario 2.0%%] [Mítico 0.5%%]\n\n" ..
			"✨ ¡Vierte tus materiales en el crisol para forjar con cinemática 3D!",
			curStaff.Name, curStaff.Rarity, curStaff.PowerMultiplier, curStaff.Damage,
			woodVal, crystalVal, slimeVal
		)

		if woodVal >= 10 and crystalVal >= 3 then
			modalAction.Text = "¡VERTER MATERIALES Y FORJAR! (10 Madera, 3 Cristal)"
		elseif woodVal >= 5 then
			modalAction.Text = "¡FORJA RÚNICA BÁSICA! (5 Madera)"
		else
			modalAction.Text = "FALTAN MATERIALES (MÍNIMO 5 MADERA)"
		end
	elseif key == "Mercado" then
		local mats = player:FindFirstChild("Materiales")
		local woodVal = mats and mats:FindFirstChild("MaderaArcana") and (mats:FindFirstChild("MaderaArcana") :: NumberValue).Value or 0
		local crystalVal = mats and mats:FindFirstChild("CristalCeleste") and (mats:FindFirstChild("CristalCeleste") :: NumberValue).Value or 0
		local slimeVal = mats and mats:FindFirstChild("GelatinaSlime") and (mats:FindFirstChild("GelatinaSlime") :: NumberValue).Value or 0

		local totalValue = (woodVal * 5) + (crystalVal * 15) + (slimeVal * 25)
		modalDesc.Text = string.format(
			"MERCADO ARCANO - VENTA DE MATERIALES:\n\n- Madera Arcana: %d  (Vale: %d 🪙)\n- Cristal Celeste: %d  (Vale: %d 🪙)\n- Gelatina Slime: %d  (Vale: %d 🪙)\n\n💰 VALOR TOTAL DE VENTA: +%d MONEDAS DE ORO\n\n¡Vende tus materiales de las zonas para ganar monedas y forjar mejores bastones!",
			woodVal, woodVal * 5,
			crystalVal, crystalVal * 15,
			slimeVal, slimeVal * 25,
			totalValue
		)
		if totalValue > 0 then
			modalAction.Text = string.format("VENDER TODO (+%d 🪙)", totalValue)
		else
			modalAction.Text = "INVENTARIO VACÍO"
		end
	elseif key == "Encantar" then
		modalDesc.Text = "ALTAR DE ENCANTAMIENTO ARCANO:\n\n✨ Próximamente en el Gran Castillo:\nPodrás recolectar Runas Antiguas derrotando a los guardianes para imbuir tus bastones con:\n\n- Runa de Fuego (+30% Daño de Quemadura)\n- Runa de Hielo (+40% Ralentización de Mobs)\n- Runa de Rayo (+50% Daño en Cadena)\n- Runa de Vacío (+100% Daño Crítico)!\n\n¡Sigue forjando bastones y entrenando en el lobby para prepararte!"
		modalAction.Text = "ENTENDIDO"
	elseif key == "Mascotas" then
		local curPet = player:GetAttribute("MascotaEquipada") or "Ninguna"
		local curMult = player:GetAttribute("PetMultiplier") or 1.0
		local eggsVal = player:GetAttribute("HuevosRaros") or 0

		modalDesc.Text = string.format(
			"SANTUARIO Y CRIADERO DE MASCOTAS:\n\n* Mascota Equipada: %s\n* Multiplicador Activo: x%.2f Poder\n\n🥚 HUEVOS MÍSTICOS EN TU MOCHILA: %d\n\nLos huevos son hallazgos raros que caen derrotando monstruos en el Bosque Rúnico (o escondidos en rincones secretos de las zonas).\n\n¡Consigue un Huevo Místico en las zonas para eclosionarlo aquí en la incubadora!",
			curPet, curMult, eggsVal
		)

		if eggsVal > 0 then
			modalAction.Text = string.format("¡ECLOSIONAR HUEVO RARO! (Tienes: %d)", eggsVal)
		else
			modalAction.Text = "FALTA HUEVO RARO (Explora el Bosque)"
		end
	elseif key == "Mochila" then
		local mats = player:FindFirstChild("Materiales")
		local woodVal = mats and mats:FindFirstChild("MaderaArcana") and (mats:FindFirstChild("MaderaArcana") :: NumberValue).Value or 0
		local crystalVal = mats and mats:FindFirstChild("CristalCeleste") and (mats:FindFirstChild("CristalCeleste") :: NumberValue).Value or 0
		local fireVal = mats and mats:FindFirstChild("EsenciaFuego") and (mats:FindFirstChild("EsenciaFuego") :: NumberValue).Value or 0
		local coinVal = monedasStat and monedasStat.Value or 0

		modalDesc.Text = string.format(
			"INVENTARIO DE RECURSOS RECOGIDOS:\n\n- Madera Arcana: %d (Zona 1: Bosque)\n- Cristales Celestes: %d (Zona 2: Cueva)\n- Esencia de Fuego: %d (Zona 3: Volcan)\n- Monedas de Oro: %d (Derrotando enemigos)\n\nUsa tus materiales en la Forja para fabricar mejores bastones o en el Mercado para venderlos!",
			woodVal, crystalVal, fireVal, coinVal
		)
		modalAction.Text = "CERRAR MOCHILA"
	else
		modalAction.Text = "ABRIR ESTACION"
	end

	modalOverlay.Visible = true
	modalCard.Size = UDim2.new(0, 420, 0, 280)
	modalOverlay.BackgroundTransparency = 1

	TweenService:Create(
		modalCard,
		TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = UDim2.new(0, 490, 0, 340) }
	):Play()

	TweenService:Create(
		modalOverlay,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.5 }
	):Play()
end

closeBtn.MouseButton1Click:Connect(closeModal)
modalOverlay.MouseButton1Click:Connect(closeModal)

modalAction.MouseButton1Click:Connect(function()
	if currentStationKey == "Forjar" then
		local mats = player:FindFirstChild("Materiales")
		local woodVal = mats and mats:FindFirstChild("MaderaArcana") and (mats:FindFirstChild("MaderaArcana") :: NumberValue).Value or 0
		local crystalVal = mats and mats:FindFirstChild("CristalCeleste") and (mats:FindFirstChild("CristalCeleste") :: NumberValue).Value or 0
		
		if woodVal < 5 then
			return
		end

		local forgeRandomEvent = ReplicatedStorage:FindFirstChild("ForgeRandomStaff")
		if forgeRandomEvent and forgeRandomEvent:IsA("RemoteEvent") then
			local wCost = if (woodVal >= 10 and crystalVal >= 3) then 10 else 5
			local cCost = if (woodVal >= 10 and crystalVal >= 3) then 3 else 0
			forgeRandomEvent:FireServer(wCost, cCost)
			closeModal()
		end
	elseif currentStationKey == "Mercado" then
		if sellMaterialsEvent and sellMaterialsEvent:IsA("RemoteEvent") then
			sellMaterialsEvent:FireServer()
			task.wait(0.2)
			closeModal()
		end
	elseif currentStationKey == "Mascotas" then
		local eggsVal = player:GetAttribute("HuevosRaros") or 0
		if eggsVal <= 0 then
			return
		end
		if petEvent and petEvent:IsA("RemoteEvent") then
			petEvent:FireServer("Hatch")
			task.wait(0.3)
			closeModal()
		end
	else
		closeModal()
	end
end)

--------------------------------------------------------------------------------
-- 4. MENÚ LATERAL DERECHO: 5 BOTONES DE ACCIÓN (CON ICONOS REALES Y COLOR VIVO)
--------------------------------------------------------------------------------
local rightSidebar = Instance.new("Frame")
rightSidebar.Name = "RightSidebar"
rightSidebar.Size = UDim2.new(0, 150, 0, 310)
rightSidebar.Position = UDim2.new(1, -160, 0.5, -155)
rightSidebar.BackgroundTransparency = 1
rightSidebar.Parent = screenGui

local sideLayout = Instance.new("UIListLayout")
sideLayout.FillDirection = Enum.FillDirection.Vertical
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Center
sideLayout.Padding = UDim.new(0, 10)
sideLayout.Parent = rightSidebar

type StationConfig = {
	Key: string,
	Name: string,
	Sub: string,
	Icon: string,
	Desc: string,
	Accent: Color3,
	Dark: Color3,
	BgTop: Color3,
	BgBot: Color3,
}

local stations: { StationConfig } = {
	{
		Key = "Forjar",
		Name = "FORJAR",
		Sub = "Crafteo Bastones",
		Icon = ICONS.Hammer,
		Desc = "Usa materiales recogidos en las zonas (maderas sagradas, cristales arcanos y esencias) para construir bastones más poderosos. ¡Cada bastón aumenta exponencialmente el poder que ganas!",
		Accent = C_AMBER,
		Dark = C_AMBER_DARK,
		BgTop = C_AMBER_BG,
		BgBot = C_AMBER_BOT,
	},
	{
		Key = "Encantar",
		Name = "ENCANTAR",
		Sub = "Mesa Mágica",
		Icon = ICONS.Wand,
		Desc = "Imbuye tus bastones con encantamientos elementales (Fuego, Hielo, Rayo o Vacío) para desbloquear pasivas de combate y multiplicadores únicos.",
		Accent = C_VIOLET,
		Dark = C_VIOLET_DARK,
		BgTop = C_VIOLET_BG,
		BgBot = C_VIOLET_BOT,
	},
	{
		Key = "Mascotas",
		Name = "MASCOTAS",
		Sub = "Huevos & Compañeros",
		Icon = ICONS.Star,
		Desc = "Eclosiona y equipa adorables compañeros mágicos que aumentan tu Poder.",
		Accent = Color3.fromRGB(0, 255, 180),
		Dark = Color3.fromRGB(0, 180, 120),
		BgTop = Color3.fromRGB(20, 50, 42),
		BgBot = Color3.fromRGB(14, 34, 28),
	},
	{
		Key = "Mochila",
		Name = "MOCHILA",
		Sub = "Materiales Zonas",
		Icon = ICONS.Backpack,
		Desc = "Revisa tus materiales recogidos en las zonas: cristales, maderas, esencias elementales y orbes para la creación de bastones.",
		Accent = C_CYAN,
		Dark = C_CYAN_DARK,
		BgTop = C_CYAN_BG,
		BgBot = C_CYAN_BOT,
	},
	{
		Key = "Mercado",
		Name = "MERCADO",
		Sub = "Vender Materiales",
		Icon = ICONS.Cart,
		Desc = "Vende tus materiales recogidos para ganar Monedas de oro de inmediato.",
		Accent = C_GOLD,
		Dark = C_GOLD_DARK,
		BgTop = C_GOLD_BG,
		BgBot = C_GOLD_BOT,
	},
}

local function createSidebarPill(data: StationConfig)
	local container = Instance.new("Frame")
	container.Name = data.Key .. "Container"
	container.Size = UDim2.new(0, 144, 0, 48)
	container.BackgroundTransparency = 1
	container.Parent = rightSidebar

	-- Base sombra 3D
	local chassis = Instance.new("Frame")
	chassis.Size = UDim2.new(1, 0, 1, 0)
	chassis.Position = UDim2.new(0, 0, 0, 4)
	chassis.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
	chassis.BorderSizePixel = 0
	chassis.Parent = container

	local chassisCorner = Instance.new("UICorner")
	chassisCorner.CornerRadius = UDim.new(0, 14)
	chassisCorner.Parent = chassis

	-- Botón interactivo
	local btn = Instance.new("TextButton")
	btn.Name = "Surface"
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.Position = UDim2.new(0, 0, 0, 0)
	btn.BackgroundColor3 = data.BgTop
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.Parent = container

	local btnStroke = applyLuminousCard(btn, 14, data.Accent, data.BgTop, data.BgBot)

	-- Insignia Circular con Icono Real
	local iconBadge = Instance.new("Frame")
	iconBadge.Size = UDim2.new(0, 34, 0, 34)
	iconBadge.Position = UDim2.new(0, 6, 0.5, -17)
	iconBadge.BackgroundColor3 = data.Accent
	iconBadge.BorderSizePixel = 0
	iconBadge.Parent = btn

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(1, 0)
	iconCorner.Parent = iconBadge

	local iconGrad = Instance.new("UIGradient")
	iconGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, data.Accent),
		ColorSequenceKeypoint.new(1, data.Dark),
	})
	iconGrad.Rotation = 45
	iconGrad.Parent = iconBadge

	local iconStroke = Instance.new("UIStroke")
	iconStroke.Thickness = 1.5
	iconStroke.Color = C_WHITE
	iconStroke.Transparency = 0.3
	iconStroke.Parent = iconBadge

	local iconImg = Instance.new("ImageLabel")
	iconImg.Size = UDim2.new(0, 20, 0, 20)
	iconImg.Position = UDim2.new(0.5, -10, 0.5, -10)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = data.Icon
	iconImg.ImageColor3 = C_WHITE
	iconImg.Parent = iconBadge

	-- Textos nítidos
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -48, 0, 16)
	titleLbl.Position = UDim2.new(0, 46, 0, 7)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = data.Name
	titleLbl.Font = Enum.Font.GothamBlack
	titleLbl.TextSize = 12
	titleLbl.TextColor3 = C_WHITE
	titleLbl.TextStrokeColor3 = C_STROKE_SHADOW
	titleLbl.TextStrokeTransparency = 0.2
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = btn

	local subLbl = Instance.new("TextLabel")
	subLbl.Size = UDim2.new(1, -48, 0, 14)
	subLbl.Position = UDim2.new(0, 46, 0, 24)
	subLbl.BackgroundTransparency = 1
	subLbl.Text = data.Sub
	subLbl.Font = Enum.Font.GothamBold
	subLbl.TextSize = 9
	subLbl.TextColor3 = C_TEXT_MUTED
	subLbl.TextStrokeColor3 = C_STROKE_SHADOW
	subLbl.TextStrokeTransparency = 0.4
	subLbl.TextXAlignment = Enum.TextXAlignment.Left
	subLbl.Parent = btn

	-- Efectos Táctiles
	btn.MouseEnter:Connect(function()
		TweenService:Create(
			container,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 152, 0, 48) }
		):Play()
		TweenService:Create(
			btnStroke,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Thickness = 3.2 }
		):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(
			container,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 144, 0, 48) }
		):Play()
		TweenService:Create(
			btnStroke,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Thickness = 2.5 }
		):Play()
		btn.Position = UDim2.new(0, 0, 0, 0)
	end)

	btn.MouseButton1Down:Connect(function()
		btn.Position = UDim2.new(0, 0, 0, 4)
	end)

	btn.MouseButton1Up:Connect(function()
		btn.Position = UDim2.new(0, 0, 0, 0)
	end)

	btn.MouseButton1Click:Connect(function()
		openModal(data.Key, data.Name, data.Sub, data.Icon, data.Desc, data.Accent)
	end)
end

for _, item in ipairs(stations) do
	createSidebarPill(item)
end

--------------------------------------------------------------------------------
-- 5. BOTÓN CENTRAL INFERIOR: CANALIZAR PODER (ALTO IMPACTO Y JUGOSO)
--------------------------------------------------------------------------------
local channelContainer = Instance.new("Frame")
channelContainer.Name = "ChannelContainer"
channelContainer.Size = UDim2.new(0, 300, 0, 74)
channelContainer.Position = UDim2.new(0.5, -150, 1, -96)
channelContainer.BackgroundTransparency = 1
channelContainer.Parent = screenGui

-- Base Sombra 3D
local channelChassis = Instance.new("Frame")
channelChassis.Size = UDim2.new(1, 0, 1, 0)
channelChassis.Position = UDim2.new(0, 0, 0, 6)
channelChassis.BackgroundColor3 = Color3.fromRGB(18, 10, 36)
channelChassis.BorderSizePixel = 0
channelChassis.Parent = channelContainer

local chassisCorner = Instance.new("UICorner")
chassisCorner.CornerRadius = UDim.new(0, 20)
chassisCorner.Parent = channelChassis

-- Superficie del Botón con Degradado Radiante
local channelBtn = Instance.new("TextButton")
channelBtn.Name = "Surface"
channelBtn.Size = UDim2.new(1, 0, 1, 0)
channelBtn.Position = UDim2.new(0, 0, 0, 0)
channelBtn.BackgroundColor3 = Color3.fromRGB(150, 60, 255)
channelBtn.AutoButtonColor = false
channelBtn.Text = ""
channelBtn.Parent = channelContainer

local channelCorner = Instance.new("UICorner")
channelCorner.CornerRadius = UDim.new(0, 20)
channelCorner.Parent = channelBtn

local channelStroke = Instance.new("UIStroke")
channelStroke.Thickness = 3
channelStroke.Color = Color3.fromRGB(240, 252, 255)
channelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
channelStroke.Parent = channelBtn

local channelGrad = Instance.new("UIGradient")
channelGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(195, 110, 255)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(130, 45, 245)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 225, 255)),
})
channelGrad.Rotation = 45
channelGrad.Parent = channelBtn

-- Reflejo Superior
local topShine = Instance.new("Frame")
topShine.Size = UDim2.new(1, -26, 0, 2.5)
topShine.Position = UDim2.new(0, 13, 0, 2)
topShine.BackgroundColor3 = C_WHITE
topShine.BackgroundTransparency = 0.5
topShine.BorderSizePixel = 0
topShine.Parent = channelBtn

-- Contenedor Central con Icono + Texto
local channelContent = Instance.new("Frame")
channelContent.Size = UDim2.new(1, 0, 1, 0)
channelContent.BackgroundTransparency = 1
channelContent.Parent = channelBtn

local channelIcon = Instance.new("ImageLabel")
channelIcon.Size = UDim2.new(0, 26, 0, 26)
channelIcon.Position = UDim2.new(0, 24, 0, 14)
channelIcon.BackgroundTransparency = 1
channelIcon.Image = ICONS.Zap
channelIcon.ImageColor3 = C_WHITE
channelIcon.Parent = channelContent

local channelTitle = Instance.new("TextLabel")
channelTitle.Size = UDim2.new(1, -60, 0, 26)
channelTitle.Position = UDim2.new(0, 56, 0, 14)
channelTitle.BackgroundTransparency = 1
channelTitle.Text = "CANALIZAR PODER"
channelTitle.Font = Enum.Font.GothamBlack
channelTitle.TextSize = 18
channelTitle.TextColor3 = C_WHITE
channelTitle.TextStrokeColor3 = Color3.fromRGB(15, 6, 32)
channelTitle.TextStrokeTransparency = 0.1
channelTitle.TextXAlignment = Enum.TextXAlignment.Left
channelTitle.Parent = channelContent

local channelSub = Instance.new("TextLabel")
channelSub.Size = UDim2.new(1, 0, 0, 16)
channelSub.Position = UDim2.new(0, 0, 0, 44)
channelSub.BackgroundTransparency = 1
channelSub.Text = "[CLIC O TOCA LA PANTALLA]"
channelSub.Font = Enum.Font.GothamBold
channelSub.TextSize = 10
channelSub.TextColor3 = Color3.fromRGB(235, 250, 255)
channelSub.TextStrokeColor3 = Color3.fromRGB(15, 6, 32)
channelSub.TextStrokeTransparency = 0.3
channelSub.Parent = channelContent

-- Animación de número flotante
local function spawnFloatingGain(amount: number)
	local floatLbl = Instance.new("TextLabel")
	floatLbl.Name = "FloatingGain"
	floatLbl.Size = UDim2.new(0, 160, 0, 36)

	local randX = math.random(-90, 90)
	floatLbl.Position = UDim2.new(0.5, randX - 80, 1, -125)
	floatLbl.BackgroundTransparency = 1
	floatLbl.Text = "+" .. formatNumber(amount) .. " ⚡"
	floatLbl.Font = Enum.Font.GothamBlack
	floatLbl.TextSize = 24
	floatLbl.TextColor3 = C_CYAN
	floatLbl.TextStrokeTransparency = 0.1
	floatLbl.TextStrokeColor3 = Color3.fromRGB(6, 10, 22)
	floatLbl.ZIndex = 40
	floatLbl.Parent = screenGui

	local tween = TweenService:Create(
		floatLbl,
		TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
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

-- Activar la animación procedural fluida de lanzamiento del bastón
local function playCastingAnimation()
	if typeof(_G.PlayStaffCast) == "function" then
		_G.PlayStaffCast()
	end
end

-- Mecánica de disparo de canalización
local isClicking = false
local function triggerChannel()
	playCastingAnimation()

	if doClickEvent and doClickEvent:IsA("RemoteEvent") then
		pcall(function()
			doClickEvent:FireServer()
		end)
	end

	local rebirthsValNum = rebirthsStat and rebirthsStat.Value or 0
	local multPuesto = player:GetAttribute("MultPuesto") or 1
	local gain = 1 * multPuesto * (1 + rebirthsValNum * 0.5)
	spawnFloatingGain(gain)

	-- Rebote elástico
	if not isClicking then
		isClicking = true
		channelBtn.Position = UDim2.new(0, 0, 0, 5)

		local returnTween = TweenService:Create(
			channelBtn,
			TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, 0, 0, 0) }
		)
		returnTween:Play()
		returnTween.Completed:Connect(function()
			isClicking = false
		end)
	end
end

channelBtn.MouseButton1Click:Connect(triggerChannel)

-- Disparador en toda la pantalla cuando no se pulsa UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or isModalOpen then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		triggerChannel()
	end
end)

--------------------------------------------------------------------------------
-- 6. ACTUALIZACIÓN DINÁMICA DE ESTADÍSTICAS Y ESTADO DEL JUGADOR
--------------------------------------------------------------------------------
local function updateUI()
	local poder = poderStat and poderStat.Value or 0
	local monedas = monedasStat and monedasStat.Value or 0
	local rebirths = rebirthsStat and rebirthsStat.Value or 0

	monedasLabel.Text = formatNumber(monedas)
	poderLabel.Text = formatNumber(poder)

	local multiplier = 1.0 + (rebirths * 0.5)
	rebirthsLabel.Text = string.format("%d (%.1fx)", rebirths, multiplier)

	-- Costo exacto de Rebirth
	local cost = math.floor(1000 * (1.8 ^ rebirths))
	rebCostTag.Text = "⚡ " .. formatNumber(cost)

	-- Barra de Progreso
	local ratio = math.clamp(poder / math.max(cost, 1), 0, 1)
	local percentText = string.format("%.0f%%", ratio * 100)
	pbarPercent.Text = percentText

	TweenService:Create(
		pbarFill,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.new(math.max(ratio, 0.05), 0, 1, 0) }
	):Play()

	if poder >= cost then
		rebCardStroke.Color = C_EMERALD
		rebBtnStroke.Color = Color3.fromRGB(180, 255, 215)
		rebBtn.BackgroundColor3 = C_EMERALD
		rebBtn.TextColor3 = C_WHITE
		rebBtn.Text = "¡ASCENDER AHORA!"
		rebBtnGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C_EMERALD),
			ColorSequenceKeypoint.new(1, C_EMERALD_DARK),
		})
	else
		rebCardStroke.Color = C_VIOLET
		rebBtnStroke.Color = Color3.fromRGB(255, 120, 130)
		rebBtn.BackgroundColor3 = C_CRIMSON
		rebBtn.TextColor3 = C_WHITE
		rebBtn.Text = "FALTA PODER"
		rebBtnGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C_CRIMSON),
			ColorSequenceKeypoint.new(1, C_CRIMSON_DARK),
		})
	end

	-- Nombre del bastón actual
	local staffName = player:GetAttribute("BastonesEquipado")
		or player:GetAttribute("BastonEquipado")
		or "Vara de Aprendiz"
	staffNameLabel.Text = tostring(staffName)

	-- Multiplicador y Nombre del puesto de entrenamiento
	local multPuesto = player:GetAttribute("MultPuesto") or 1
	local nombrePuesto = player:GetAttribute("NombrePuesto") or "LOBBY"
	trText.Text = string.format("⚡ %s (x%.1f)", string.upper(tostring(nombrePuesto)), multPuesto)
end

-- Ejecución de Rebirth al pulsar el botón
rebBtn.MouseButton1Click:Connect(function()
	local poder = poderStat and poderStat.Value or 0
	local rebirths = rebirthsStat and rebirthsStat.Value or 0
	local cost = math.floor(1000 * (1.8 ^ rebirths))

	if poder >= cost then
		if rebirthEvent and rebirthEvent:IsA("RemoteEvent") then
			pcall(function()
				rebirthEvent:FireServer()
			end)
		end
	else
		-- Feedback de error
		local origPos = UDim2.new(0, 8, 0, 56)
		local shake = TweenService:Create(
			rebBtn,
			TweenInfo.new(0.04, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true),
			{ Position = UDim2.new(0, 13, 0, 56) }
		)
		shake:Play()
		shake.Completed:Connect(function()
			rebBtn.Position = origPos
		end)
	end
end)

-- Conexiones de Eventos
player:GetAttributeChangedSignal("BastonesEquipado"):Connect(updateUI)
player:GetAttributeChangedSignal("BastonEquipado"):Connect(updateUI)
player:GetAttributeChangedSignal("MultPuesto"):Connect(updateUI)
player:GetAttributeChangedSignal("NombrePuesto"):Connect(updateUI)

if poderStat then
	poderStat.Changed:Connect(updateUI)
end
if monedasStat then
	monedasStat.Changed:Connect(updateUI)
end
if rebirthsStat then
	rebirthsStat.Changed:Connect(updateUI)
end

-- Escucha para abrir modales desde las Estaciones Físicas de la Lobby
local openStationEvent = ReplicatedStorage:WaitForChild("OpenStationUI", 10)
if openStationEvent and openStationEvent:IsA("RemoteEvent") then
	openStationEvent.OnClientEvent:Connect(function(stationKey: string)
		local lTarget = string.lower(stationKey)
		for _, data in ipairs(stations) do
			local lKey = string.lower(data.Key)
			if lKey == lTarget or string.find(lKey, lTarget) or string.find(lTarget, lKey) then
				openModal(data.Key, data.Name, data.Sub, data.Icon, data.Desc, data.Accent)
				break
			end
		end
	end)
end

-- Notificación flotante de botín y alertas
local notifyEvent = ReplicatedStorage:FindFirstChild("ShowGameNotification")
if not notifyEvent then
	notifyEvent = Instance.new("RemoteEvent")
	notifyEvent.Name = "ShowGameNotification"
	notifyEvent.Parent = ReplicatedStorage
end

notifyEvent.OnClientEvent:Connect(function(msg: string, color: Color3?)
	local notifCard = Instance.new("Frame")
	notifCard.Size = UDim2.new(0, 360, 0, 44)
	notifCard.Position = UDim2.new(0.5, -180, 0, 78)
	notifCard.BackgroundColor3 = Color3.fromRGB(16, 20, 34)
	notifCard.BackgroundTransparency = 0.15
	notifCard.ZIndex = 80
	notifCard.Parent = screenGui

	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 10)
	notifCorner.Parent = notifCard

	local notifStroke = Instance.new("UIStroke")
	notifStroke.Thickness = 2
	notifStroke.Color = color or Color3.fromRGB(0, 225, 255)
	notifStroke.Parent = notifCard

	local notifText = Instance.new("TextLabel")
	notifText.Size = UDim2.new(1, -20, 1, 0)
	notifText.Position = UDim2.new(0, 10, 0, 0)
	notifText.BackgroundTransparency = 1
	notifText.Font = Enum.Font.GothamBold
	notifText.TextSize = 13
	notifText.TextColor3 = Color3.new(1, 1, 1)
	notifText.Text = msg
	notifText.ZIndex = 81
	notifText.Parent = notifCard

	TweenService:Create(
		notifCard,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, -180, 0, 92) }
	):Play()

	task.delay(2.6, function()
		local fade = TweenService:Create(
			notifCard,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Position = UDim2.new(0.5, -180, 0, 60), BackgroundTransparency = 1 }
		)
		fade:Play()
		TweenService:Create(notifText, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 }):Play()
		TweenService:Create(notifStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 }):Play()
		fade.Completed:Connect(function()
			notifCard:Destroy()
		end)
	end)
end)

-- Actualización dinámica en el cliente de la Barrera de Zona 2
task.spawn(function()
	local zone1 = Workspace:WaitForChild("Zone1_BosqueRunico", 10)
	local barrierModel = zone1 and zone1:WaitForChild("BarrierToZone2", 10)
	local forcefield = barrierModel and barrierModel:WaitForChild("ForcefieldWall", 10) :: BasePart?
	if forcefield then
		local function updateBarrierCollision()
			local curPoder = poderStat and poderStat.Value or 0
			if curPoder >= 100 then
				forcefield.CanCollide = false
				forcefield.Transparency = 0.82
			else
				forcefield.CanCollide = true
				forcefield.Transparency = 0.55
			end
		end
		if poderStat then
			poderStat.Changed:Connect(updateBarrierCollision)
		end
		updateBarrierCollision()
	end
end)

updateUI()
