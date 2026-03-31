--// ANCLA TEST - ULTRA ANTI FLING (Cometas diagonales MUY lentas)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local enabled = false
local checkpointCFrame = nil
local mainConnection = nil

local suspiciousFolders = {
    Workspace:FindFirstChild("ClientObjects"),
    Workspace:FindFirstChild("Objects"),
    Workspace:FindFirstChild("LocalFallProtectors"),
    Workspace:FindFirstChild("ThrowBallFolder_WalmartList3_3")
}

--// ==================== SONIDO CON FADE OUT SUTIL ====================
local soundId = "rbxassetid://115643345182540"

local customSound = Instance.new("Sound")
customSound.SoundId = soundId
customSound.Volume = 0.7          -- Volumen inicial (puedes cambiarlo)
customSound.Looped = false
customSound.Parent = SoundService

-- Reproducir automáticamente al ejecutar el script
customSound:Play()

-- Fade out sutil: baja el volumen durante los últimos 2 segundos (del segundo 8 al 10)
task.delay(8, function()
    if customSound.IsPlaying then
        local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        TweenService:Create(customSound, tweenInfo, {Volume = 0}):Play()
        
        -- Detener el sonido completamente después del fade
        task.delay(2, function()
            if customSound then
                customSound:Stop()
            end
        end)
    end
end)

print("🔊 Reproduciendo audio (fade out sutil a los 8 segundos)")
--// =================================================================

--// GUI
local sg = Instance.new("ScreenGui")
sg.Name = "anclaTest"
sg.ResetOnSpawn = false
sg.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0, 340, 0, 170)
mainFrame.Position = UDim2.new(0, 30, 0, 180)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = mainFrame

-- Fondo animado
local bg = Instance.new("Frame", mainFrame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundTransparency = 1
bg.ZIndex = 1

local comets = {}
for i = 1, 4 do
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0, 2, 0, 2)
    c.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    c.BackgroundTransparency = 0.45
    c.BorderSizePixel = 0
    c.ZIndex = 1
    c.Parent = bg
    Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)
    table.insert(comets, {
        frame = c,
        x = math.random(30, 290),
        y = math.random(20, 140),
        speedX = (i % 2 == 0) and 0.15 or -0.15,
        speedY = 0.38 + math.random() * 0.32,
        alpha = 0.85
    })
end

-- Panel oscuro
local panel = Instance.new("Frame", mainFrame)
panel.Size = UDim2.new(1, -28, 0, 62)
panel.Position = UDim2.new(0, 14, 0, 78)
panel.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
panel.ZIndex = 2

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

-- Texto "Activar ancla"
local label = Instance.new("TextLabel", panel)
label.Size = UDim2.new(0.52, 0, 1, 0)
label.Position = UDim2.new(0, 22, 0, 0)
label.BackgroundTransparency = 1
label.Text = "Activar ancla"
label.TextColor3 = Color3.new(1, 1, 1)
label.TextSize = 15.5
label.Font = Enum.Font.GothamSemibold
label.TextXAlignment = Enum.TextXAlignment.Left
label.ZIndex = 5

-- Switch
local switchTrack = Instance.new("Frame", panel)
switchTrack.Size = UDim2.new(0, 46, 0, 24)
switchTrack.Position = UDim2.new(1, -66, 0.5, -12)
switchTrack.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
switchTrack.ZIndex = 3
Instance.new("UICorner", switchTrack).CornerRadius = UDim.new(1, 0)

local switchKnob = Instance.new("Frame", switchTrack)
switchKnob.Size = UDim2.new(0, 20, 0, 20)
switchKnob.Position = UDim2.new(0, 2, 0.5, -10)
switchKnob.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
switchKnob.ZIndex = 4
Instance.new("UICorner", switchKnob).CornerRadius = UDim.new(1, 0)

-- Minimizar
local minimizeBtn = Instance.new("TextButton", mainFrame)
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -36, 0, 8)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

-- Icono restauración
local restoreIcon = Instance.new("TextButton", sg)
restoreIcon.Size = UDim2.new(0, 52, 0, 52)
restoreIcon.Position = UDim2.new(0, 40, 0, 200)
restoreIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
restoreIcon.Text = "ANCLA"
restoreIcon.TextColor3 = Color3.new(1, 1, 1)
restoreIcon.TextSize = 12
restoreIcon.Font = Enum.Font.GothamBold
restoreIcon.Visible = false
Instance.new("UICorner", restoreIcon).CornerRadius = UDim.new(0, 14)

-- DRAG Main Frame
local dragging = false
local dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- DRAG Restore Icon
local draggingIcon = false
local dragStartIcon, startPosIcon
restoreIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingIcon = true
        dragStartIcon = input.Position
        startPosIcon = restoreIcon.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingIcon and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartIcon
        restoreIcon.Position = UDim2.new(startPosIcon.X.Scale, startPosIcon.X.Offset + delta.X, startPosIcon.Y.Scale, startPosIcon.Y.Offset + delta.Y)
    end
end)

restoreIcon.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingIcon = false end
end)

-- Animación del fondo
local function animateBackground()
    for _, c in ipairs(comets) do
        c.x += c.speedX
        c.y += c.speedY
        c.alpha = c.alpha - 0.012
        if c.alpha <= 0.07 or c.y > 165 or c.x < 15 or c.x > 315 then
            c.x = math.random(30, 290)
            c.y = math.random(20, 140)
            c.speedX = (math.random() > 0.5) and 0.18 or -0.18
            c.speedY = 0.32 + math.random() * 0.28
            c.alpha = 0.88
        end
        c.frame.Position = UDim2.new(0, c.x, 0, c.y)
        c.frame.BackgroundTransparency = 1 - c.alpha
    end
end

-- Switch Animation
local function updateSwitch(on)
    local tweenInfo = TweenInfo.new(0.27, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if on then
        TweenService:Create(switchKnob, tweenInfo, {Position = UDim2.new(0, 24, 0.5, -10)}):Play()
        TweenService:Create(switchTrack, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 175, 85)}):Play()
    else
        TweenService:Create(switchKnob, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -10)}):Play()
        TweenService:Create(switchTrack, tweenInfo, {BackgroundColor3 = Color3.fromRGB(55, 55, 60)}):Play()
    end
end

-- Lógica Anti-Fling
local function getRoot()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function saveCheckpoint()
    local root = getRoot()
    if root then checkpointCFrame = root.CFrame end
end

local function cleanTrollObjects()
    for _, folder in ipairs(suspiciousFolders) do
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("BasePart") or obj:IsA("Attachment") or obj:IsA("VectorForce") or
                   obj:IsA("AlignPosition") or obj:IsA("AlignOrientation") or obj:IsA("LinearVelocity") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
end

local function force()
    local root = getRoot()
    if root and checkpointCFrame then
        root:PivotTo(checkpointCFrame)
        root.CFrame = checkpointCFrame
        root.Velocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    cleanTrollObjects()
end

local function activate()
    enabled = true
    saveCheckpoint()
    if mainConnection then mainConnection:Disconnect() end
    mainConnection = RunService.Heartbeat:Connect(force)
    updateSwitch(true)
end

local function deactivate()
    enabled = false
    if mainConnection then mainConnection:Disconnect() end
    mainConnection = nil
    checkpointCFrame = nil
    updateSwitch(false)
end

switchTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if enabled then deactivate() else activate() end
    end
end)

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    restoreIcon.Visible = true
end)

restoreIcon.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    restoreIcon.Visible = false
end)

RunService.RenderStepped:Connect(animateBackground)

player.CharacterAdded:Connect(function()
    if enabled then
        task.wait(0.15)
        saveCheckpoint()
    end
end)

print("✅ anclaTest cargado - Cometas diagonales MUY lentas")