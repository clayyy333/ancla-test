--// ANCLA TEST - FINAL FIX REAL (ANTI SEAT + UI + BORDE) - VERSIÓN CORREGIDA (SIN SALTO CONSTANTE)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")  -- ← AÑADIDO PARA EL FADE
local SoundService = game:GetService("SoundService")   -- ← AÑADIDO PARA EL SONIDO

local player = Players.LocalPlayer
local anclaEnabled = false
local antiSeatEnabled = false
local checkpointCFrame = nil
local connection = nil

-- ==================== SONIDO CON FADE OUT SUTIL ====================
local soundId = "rbxassetid://115643345182540"

local customSound = Instance.new("Sound")
customSound.SoundId = soundId
customSound.Volume = 0.7          -- Volumen inicial
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
-- =================================================================

-- GUI (100% igual a la tuya original, sin tocar nada)
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "anclaTest"
sg.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0,340,0,200)
mainFrame.Position = UDim2.new(0,40,0,200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
mainFrame.Active = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,18)

-- 🔥 BORDE REAL RESPIRANDO
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
    local active = anclaEnabled or antiSeatEnabled
    for i,v in ipairs(borderLayers) do
        if active then
            v.BackgroundTransparency = 0.45 + pulse*0.15 + i*0.02
        else
            v.BackgroundTransparency = 0.85 + i*0.02
        end
    end
end)

-- 🌌 COMETAS (sin cambios)
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
        y=math.random(20,140),
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
            c.y=math.random(20,140)
            c.alpha=0.88
        end
        c.frame.Position=UDim2.new(0,c.x,0,c.y)
        c.frame.BackgroundTransparency=1-c.alpha
    end
end)

-- PANEL, LABELS Y BOTONES (sin cambios)
local panel = Instance.new("Frame", mainFrame)
panel.Size = UDim2.new(1,-28,0,100)
panel.Position = UDim2.new(0,14,0,70)
panel.BackgroundColor3 = Color3.fromRGB(24,24,32)
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)

local label1 = Instance.new("TextLabel", panel)
label1.Size = UDim2.new(1,-80,0.5,0)
label1.Position = UDim2.new(0,12,0,0)
label1.TextXAlignment = Enum.TextXAlignment.Left
label1.Text = "Activar ancla"
label1.BackgroundTransparency = 1
label1.TextColor3 = Color3.new(1,1,1)

local btn1 = Instance.new("TextButton", panel)
btn1.Size = UDim2.new(0,50,0,25)
btn1.Position = UDim2.new(1,-70,0.25,-12)
btn1.Text = "OFF"
btn1.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner",btn1).CornerRadius = UDim.new(1,0)

local label2 = Instance.new("TextLabel", panel)
label2.Size = UDim2.new(1,-80,0.5,0)
label2.Position = UDim2.new(0,12,0.5,0)
label2.TextXAlignment = Enum.TextXAlignment.Left
label2.Text = "Activar AntiSeat"
label2.BackgroundTransparency = 1
label2.TextColor3 = Color3.new(1,1,1)

local btn2 = Instance.new("TextButton", panel)
btn2.Size = UDim2.new(0,50,0,25)
btn2.Position = UDim2.new(1,-70,0.75,-12)
btn2.Text = "OFF"
btn2.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner",btn2).CornerRadius = UDim.new(1,0)

-- MINIMIZAR (sin cambios)
local minimize = Instance.new("TextButton", mainFrame)
minimize.Size = UDim2.new(0,28,0,28)
minimize.Position = UDim2.new(1,-36,0,8)
minimize.Text = "-"
minimize.BackgroundColor3 = Color3.fromRGB(25,25,30)
local restore = Instance.new("TextButton", sg)
restore.Size = UDim2.new(0,55,0,55)
restore.Position = UDim2.new(0,40,0,220)
restore.Text = "ANCLA"
restore.Visible = false

minimize.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    restore.Visible = true
end)

restore.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    restore.Visible = false
end)

-- DRAG (sin cambios)
local function dragify(obj)
    local drag=false
    local start,pos
    obj.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true
            start=i.Position
            pos=obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local delta=i.Position-start
            obj.Position=UDim2.new(pos.X.Scale,pos.X.Offset+delta.X,pos.Y.Scale,pos.Y.Offset+delta.Y)
        end
    end)
    obj.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=false
        end
    end)
end
dragify(mainFrame)
dragify(restore)

-- 🔥 ANTI SEAT CORREGIDO (sin cambios)
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

    local function breakMySeatWelds(model)
        for _, v in ipairs(model:GetDescendants()) do
            if v.Name == "SeatWeld" or v:IsA("Weld") or v:IsA("WeldConstraint") then
                local part0 = v:FindFirstChild("Part0") or v.Part0
                local part1 = v:FindFirstChild("Part1") or v.Part1
                if (part0 and char:IsAncestorOf(part0)) or (part1 and char:IsAncestorOf(part1)) then
                    pcall(function() v:Destroy() end)
                end
            end
        end
    end

    local folders = {Workspace:FindFirstChild("Cars"), Workspace:FindFirstChild("CarSpawnPoints")}
    for _, folder in ipairs(folders) do
        if folder then
            for _, vehicle in ipairs(folder:GetChildren()) do
                if vehicle.Name:find("ltp2_car_") or vehicle.Name:find("_ltp2_car_") then
                    breakMySeatWelds(vehicle)
                end
            end
        end
    end

    if hum.SeatPart then
        local seatModel = hum.SeatPart
        while seatModel and seatModel ~= Workspace do
            if seatModel.Name:find("ltp2_car_") or seatModel.Name:find("_ltp2_car_") then
                breakMySeatWelds(seatModel)
                break
            end
            seatModel = seatModel.Parent
        end
    end

    if hum.Sit then
        root.CFrame = root.CFrame + Vector3.new(0, 2, 0)
    end
end

-- ANCLA (sin cambios)
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

-- BOTONES (sin cambios)
btn1.MouseButton1Click:Connect(function()
    anclaEnabled = not anclaEnabled
    if anclaEnabled then
        local r = getRoot()
        if r then checkpointCFrame = r.CFrame end
        btn1.Text = "ON"
        btn1.BackgroundColor3 = Color3.fromRGB(0,160,80)
    else
        btn1.Text = "OFF"
        btn1.BackgroundColor3 = Color3.fromRGB(60,60,60)
    end
end)

btn2.MouseButton1Click:Connect(function()
    antiSeatEnabled = not antiSeatEnabled
    if antiSeatEnabled then
        btn2.Text = "ON"
        btn2.BackgroundColor3 = Color3.fromRGB(0,160,80)
    else
        btn2.Text = "OFF"
        btn2.BackgroundColor3 = Color3.fromRGB(60,60,60)
    end
end)

print("✅ ANCLA + ANTISEAT CORREGIDO (SIN SALTO CONSTANTE) - Listo para probar")