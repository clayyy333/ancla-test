--// ANCLA TEST BY RYANG

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

local anclaEnabled = false
local antiSeatEnabled = false
local heartbeatEnabled = false

local checkpointCFrame = nil
local connection = nil

-- ==================== SONIDO ====================
local soundId = "rbxassetid://115643345182540"
local customSound = Instance.new("Sound")
customSound.SoundId = soundId
customSound.Volume = 0.7
customSound.Looped = false
customSound.Parent = SoundService
customSound:Play()

task.delay(8, function()
	if customSound.IsPlaying then
		local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		TweenService:Create(customSound, tweenInfo, {Volume = 0}):Play()
		task.delay(2, function()
			if customSound then customSound:Stop() end
		end)
	end
end)

-- ==================== GUI ====================
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "anclaTest"
sg.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0,340,0,250)
mainFrame.Position = UDim2.new(0,40,0,200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
mainFrame.Active = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,18)

-- ==================== TEXTO AÑADIDO ====================
local versionText = Instance.new("TextLabel", mainFrame)
versionText.Size = UDim2.new(0,220,0,14)
versionText.Position = UDim2.new(0,12,0,24)
versionText.BackgroundTransparency = 1
versionText.Text = "v1 por @intensiveee (RyanGosling)"
versionText.TextColor3 = Color3.fromRGB(180,180,180)
versionText.TextXAlignment = Enum.TextXAlignment.Left
versionText.Font = Enum.Font.Gotham
versionText.TextSize = 10
versionText.ZIndex = 1
versionText.Active = false
-- ====================================================

local borderLayers = {}
for i=1,3 do
	local b = Instance.new("Frame")
	b.Size = UDim2.new(1, i*4, 1, i*4)
	b.Position = UDim2.new(0,-i*2,0,-i*2)
	b.BackgroundColor3 = Color3.fromRGB(15,15,20)
	b.BorderSizePixel = 0
	b.ZIndex = 0
	b.Parent = mainFrame
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,18+i*2)
	table.insert(borderLayers,b)
end

local t=0
RunService.RenderStepped:Connect(function(dt)
	t += dt*2
	local pulse = (math.sin(t)+1)/2
	local active = anclaEnabled or antiSeatEnabled or heartbeatEnabled
	for i,v in ipairs(borderLayers) do
		if active then
			v.BackgroundTransparency = 0.45 + pulse*0.15 + i*0.02
		else
			v.BackgroundTransparency = 0.85 + i*0.02
		end
	end
end)

-- COMETAS
local bg = Instance.new("Frame", mainFrame)
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundTransparency = 1

local comets={}
for i=1,4 do
	local c=Instance.new("Frame")
	c.Size=UDim2.new(0,2,0,2)
	c.BackgroundColor3=Color3.new(1,1,1)
	c.BackgroundTransparency=0.45
	c.Parent=bg
	Instance.new("UICorner",c).CornerRadius=UDim.new(1,0)
	table.insert(comets,{
		frame=c,
		x=math.random(30,290),
		y=math.random(20,190),
		speedX=(i%2==0) and 0.15 or -0.15,
		speedY=0.38 + math.random()*0.32,
		alpha=0.85
	})
end

RunService.RenderStepped:Connect(function()
	for _,c in ipairs(comets) do
		c.x+=c.speedX
		c.y+=c.speedY
		c.alpha-=0.012
		if c.alpha<=0.07 then
			c.x=math.random(30,290)
			c.y=math.random(20,190)
			c.alpha=0.88
		end
		c.frame.Position=UDim2.new(0,c.x,0,c.y)
		c.frame.BackgroundTransparency=1-c.alpha
	end
end)

-- PANEL
local panel = Instance.new("Frame", mainFrame)
panel.Size = UDim2.new(1,-28,0,150)
panel.Position = UDim2.new(0,14,0,70)
panel.BackgroundColor3 = Color3.fromRGB(24,24,32)
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)

-- OPCIONES 
local label1 = Instance.new("TextLabel", panel)
label1.Size = UDim2.new(1,-80,1/3,0)
label1.Position = UDim2.new(0,12,0,0)
label1.TextXAlignment = Enum.TextXAlignment.Left
label1.Text = "Activar ancla"
label1.BackgroundTransparency = 1
label1.TextColor3 = Color3.new(1,1,1)

local btn1 = Instance.new("TextButton", panel)
btn1.Size = UDim2.new(0,50,0,25)
btn1.Position = UDim2.new(1,-70,1/6,-12)
btn1.Text = "OFF"
btn1.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner",btn1).CornerRadius = UDim.new(1,0)

local label2 = Instance.new("TextLabel", panel)
label2.Size = UDim2.new(1,-80,1/3,0)
label2.Position = UDim2.new(0,12,1/3,0)
label2.TextXAlignment = Enum.TextXAlignment.Left
label2.Text = "Activar AntiSeat"
label2.BackgroundTransparency = 1
label2.TextColor3 = Color3.new(1,1,1)

local btn2 = Instance.new("TextButton", panel)
btn2.Size = UDim2.new(0,50,0,25)
btn2.Position = UDim2.new(1,-70,0.5,-12)
btn2.Text = "OFF"
btn2.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner",btn2).CornerRadius = UDim.new(1,0)

local label3 = Instance.new("TextLabel", panel)
label3.Size = UDim2.new(1,-80,1/3,0)
label3.Position = UDim2.new(0,12,2/3,0)
label3.TextXAlignment = Enum.TextXAlignment.Left
label3.Text = "Activar Heartbeat"
label3.BackgroundTransparency = 1
label3.TextColor3 = Color3.new(1,1,1)

local btn3 = Instance.new("TextButton", panel)
btn3.Size = UDim2.new(0,50,0,25)
btn3.Position = UDim2.new(1,-70,5/6,-12)
btn3.Text = "OFF"
btn3.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner",btn3).CornerRadius = UDim.new(1,0)

-- MINIMIZAR + DRAG 
local minimize = Instance.new("TextButton", mainFrame)
minimize.Size = UDim2.new(0,28,0,28)
minimize.Position = UDim2.new(1,-36,0,8)
minimize.Text = "-"
minimize.BackgroundColor3 = Color3.fromRGB(25,25,30)

local restore = Instance.new("Frame", sg)
restore.Size = UDim2.new(0,48,0,48)
restore.Position = UDim2.new(0,40,0,220)
restore.BackgroundColor3 = Color3.fromRGB(0,0,0)
restore.Visible = false
Instance.new("UICorner",restore).CornerRadius = UDim.new(0,16)

local restoreText = Instance.new("TextLabel", restore)
restoreText.Size = UDim2.new(1,0,1,0)
restoreText.BackgroundTransparency = 1
restoreText.Text = "ANCLA"
restoreText.TextColor3 = Color3.new(1,1,1)
restoreText.TextScaled = true
restoreText.Font = Enum.Font.GothamBold

local function isClick(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

btn1.InputBegan:Connect(function(input)
	if not isClick(input) then return end
	anclaEnabled = not anclaEnabled
	if anclaEnabled then
		local r = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if r then checkpointCFrame = r.CFrame end
		btn1.Text = "ON"
		btn1.BackgroundColor3 = Color3.fromRGB(0,160,80)
	else
		btn1.Text = "OFF"
		btn1.BackgroundColor3 = Color3.fromRGB(60,60,60)
	end
end)

btn2.InputBegan:Connect(function(input)
	if not isClick(input) then return end
	antiSeatEnabled = not antiSeatEnabled
	if antiSeatEnabled then
		btn2.Text = "ON"
		btn2.BackgroundColor3 = Color3.fromRGB(0,160,80)
	else
		btn2.Text = "OFF"
		btn2.BackgroundColor3 = Color3.fromRGB(60,60,60)
	end
end)

btn3.InputBegan:Connect(function(input)
	if not isClick(input) then return end
	heartbeatEnabled = not heartbeatEnabled
	if heartbeatEnabled then
		btn3.Text = "ON"
		btn3.BackgroundColor3 = Color3.fromRGB(0,160,80)
	else
		btn3.Text = "OFF"
		btn3.BackgroundColor3 = Color3.fromRGB(60,60,60)
	end
end)

minimize.InputBegan:Connect(function(input)
	if not isClick(input) then return end
	mainFrame.Visible = false
	restore.Visible = true
end)

restore.InputBegan:Connect(function(input)
	if not isClick(input) then return end
	mainFrame.Visible = true
	restore.Visible = false
end)

local function dragify(obj)
	local dragging = false
	local dragStart, startPos
	obj.InputBegan:Connect(function(input)
		if isClick(input) then
			dragging = true
			dragStart = input.Position
			startPos = obj.Position
		end
	end)
	obj.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			obj.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	obj.InputEnded:Connect(function(input)
		if isClick(input) then
			dragging = false
		end
	end)
end

dragify(mainFrame)
dragify(restore)

-- ==================== NUEVO: PREVENTIVO  BY RYAN ====================
local TARGETS = {
	"Babycar_a","Babycar_b","Babycar_c",
	"Stretcher","FoldingTable_1","Folding_table_02"
}

local function isTarget(model)
	for _,n in ipairs(TARGETS) do
		if model.Name:find(n) then
			return true
		end
	end
	return false
end

Workspace.DescendantAdded:Connect(function(obj)
	if not antiSeatEnabled then return end
	if obj.Name ~= "SeatWeld" then return end

	local model = obj:FindFirstAncestorOfClass("Model")
	if model and isTarget(model) then
		pcall(function() obj:Destroy() end)
	end
end)

-- ==================== ANTISEAT ORIGINAL MEJORADO BY RYAN  ====================
local function antiSeat()
	if not antiSeatEnabled then return end

	local char = player.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	hum.Sit = false
	hum:ChangeState(Enum.HumanoidStateType.Running)
	hum.PlatformStand = false

	for _,obj in ipairs(Workspace:GetChildren()) do
		if isTarget(obj) then
			for _,v in ipairs(obj:GetDescendants()) do
				if v.Name == "SeatWeld" then
					pcall(function() v:Destroy() end)
				end
			end
		end
	end

	if hum.Sit then
		root.CFrame = root.CFrame + Vector3.new(0,2,0)
	end
end

-- ==================== LOOP ORIGINAL BY RYAN====================
local function getRoot()
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function loop()
	local root = getRoot()
	if anclaEnabled and root and checkpointCFrame then
		root.CFrame = checkpointCFrame
		root.Velocity = Vector3.zero
	end
	antiSeat()
end

connection = RunService.RenderStepped:Connect(loop)

-- ==================== HEARTBEAT BY RYAN ====================
local function heartbeatLoop()
	if not heartbeatEnabled or not anclaEnabled then return end
	local root = getRoot()
	if root and checkpointCFrame then
		root.CFrame = checkpointCFrame
		root.Velocity = Vector3.zero
	end
end

RunService.Heartbeat:Connect(heartbeatLoop)

-- ==================== 🔒 REFUERZO HARD LOCK BY RYAN====================
RunService.Stepped:Connect(function()
	if not anclaEnabled then return end

	local char = player.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum or not checkpointCFrame then return end

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	root.CFrame = checkpointCFrame

	hum:ChangeState(Enum.HumanoidStateType.Running)
	hum.Sit = false
	hum.PlatformStand = false
end)

print(" ANTISEAT PREVENTIVO + CORRECTIVO + HARD LOCK ")