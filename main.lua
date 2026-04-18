local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

-- === CONFIG & STATE ===
_G.ASTRAL_PAUSE = false
local targetCFrame = CFrame.new(-65, 13.57, -30) 
local selectedPlayerCFrame = nil 

local farmActive, hitboxActive, myHitboxActive, espActive = false, false, false, false
local infJump, noclipActive, antiAfk, anchorActive = false, false, true, false
local autoClick, autoE = false, false
local hitboxSize, myHitboxSize = 15, 15
local accentColor = Color3.fromRGB(0, 170, 255)

-- === FUNCTIONS ===
local function superBoost()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") then
            v:Destroy()
        end
    end
end

-- === UI CONSTRUCTION ===
if _G.AstralLoop then _G.AstralLoop:Disconnect() end
local old = player.PlayerGui:FindFirstChild("AstralHub")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "AstralHub"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 580, 0, 480)
main.Position = UDim2.new(0.5, -290, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.Active = true
Instance.new("UICorner", main)

-- Анімація назви
local hubTitle = Instance.new("TextLabel", main)
hubTitle.Size = UDim2.new(0, 200, 0, 50)
hubTitle.Position = UDim2.new(0, 10, 0, 5)
hubTitle.Text = "ASTRAL HUB"
hubTitle.Font = Enum.Font.GothamBold
hubTitle.TextSize = 26
hubTitle.BackgroundTransparency = 1
hubTitle.ZIndex = 10
task.spawn(function()
    while task.wait() do
        for i = 0, 1, 0.005 do hubTitle.TextColor3 = Color3.fromHSV(i, 0.8, 1) task.wait(0.02) end
    end
end)

-- Зірки
task.spawn(function()
    while task.wait(0.5) do
        if main.Visible then
            local star = Instance.new("Frame", main)
            star.Size = UDim2.new(0, 2, 0, 2)
            star.Position = UDim2.new(math.random(), 0, -0.1, 0)
            star.ZIndex = 1
            Instance.new("UICorner", star)
            star:TweenPosition(UDim2.new(star.Position.X.Scale, 0, 1.1, 0), "Out", "Linear", 3)
            game:GetService("Debris"):AddItem(star, 3)
        end
    end
end)

local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 150, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Instance.new("UICorner", side)

local containers = {}
local function createTab(name, order)
    local btn = Instance.new("TextButton", side)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, 60 + (order * 45))
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Instance.new("UICorner", btn)
    
    local cont = Instance.new("ScrollingFrame", main)
    cont.Size = UDim2.new(1, -175, 1, -80)
    cont.Position = UDim2.new(0, 165, 0, 60)
    cont.BackgroundTransparency = 1
    cont.Visible = (order == 0)
    cont.AutomaticCanvasSize = Enum.AutomaticSize.Y
    containers[name] = cont
    Instance.new("UIListLayout", cont).Padding = UDim.new(0, 10)
    
    btn.MouseButton1Click:Connect(function()
        for _, c in pairs(containers) do c.Visible = false end
        cont.Visible = true
    end)
end

createTab("Main", 0)
createTab("Combat", 1)
createTab("Character", 2)
createTab("Visuals", 3)
createTab("Anti Spectator", 4)
createTab("Anti Danger", 5)
createTab("Settings", 6)

-- UI Builders
local function createToggle(tab, text, callback)
    local b = Instance.new("TextButton", containers[tab])
    b.Size = UDim2.new(0.96, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    b.Text = text .. ": OFF"
    b.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    Instance.new("UICorner", b)
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = text .. (s and ": ON" or ": OFF")
        b.BackgroundColor3 = s and accentColor or Color3.fromRGB(20, 20, 28)
        b.TextColor3 = s and Color3.new(1,1,1) or Color3.new(0.6, 0.6, 0.6)
        callback(s)
    end)
end

local function createBtn(tab, text, color, callback)
    local b = Instance.new("TextButton", containers[tab])
    b.Size = UDim2.new(0.96, 0, 0, 35)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

-- === MAIN ===
createToggle("Main", "Auto Farm", function(s) farmActive = s end)
createBtn("Main", "SET CURRENT POS AS FARM", Color3.fromRGB(45, 45, 60), function() 
    if player.Character:FindFirstChild("HumanoidRootPart") then targetCFrame = player.Character.HumanoidRootPart.CFrame end 
end)

local selInfo = Instance.new("TextLabel", containers["Main"])
selInfo.Size = UDim2.new(0.96, 0, 0, 25)
selInfo.Text = "Selected: None"
selInfo.TextColor3 = Color3.new(1,1,0)
selInfo.BackgroundTransparency = 1

local pScroll = Instance.new("ScrollingFrame", containers["Main"])
pScroll.Size = UDim2.new(0.96, 0, 0, 140)
pScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
pScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", pScroll)

local function updatePlayers()
    for _, v in pairs(pScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", pScroll)
            b.Size = UDim2.new(1, -10, 0, 30)
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            b.TextColor3 = Color3.new(1,1,1)
            b.Text = p.DisplayName
            b.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    selectedPlayerCFrame = p.Character.HumanoidRootPart.CFrame
                    selInfo.Text = "Selected: " .. p.DisplayName
                end
            end)
        end
    end
end
createBtn("Main", "COPY SELECTED POS", Color3.fromRGB(80, 40, 80), function()
    if selectedPlayerCFrame then 
        targetCFrame = selectedPlayerCFrame 
        setclipboard("CFrame.new(" .. tostring(selectedPlayerCFrame) .. ")")
        selInfo.Text = "POS COPIED!"
    end
end)
createBtn("Main", "REFRESH PLAYERS", Color3.fromRGB(60, 60, 80), updatePlayers)

-- === COMBAT ===
createToggle("Combat", "Auto Click", function(s) autoClick = s end)
createToggle("Combat", "Auto E", function(s) autoE = s end)

-- === CHARACTER ===
createToggle("Character", "Anchor Lock", function(s) anchorActive = s end)
createToggle("Character", "Inf Jump", function(s) infJump = s end)
createToggle("Character", "Noclip", function(s) noclipActive = s end)
createToggle("Character", "My Hitbox Expand", function(s) myHitboxActive = s end)

-- === VISUALS ===
createToggle("Visuals", "Player ESP", function(s) espActive = s end)
createToggle("Visuals", "Enemies Hitbox", function(s) hitboxActive = s end)

-- === ANTI SPECTATOR ===
local specWarning = Instance.new("TextLabel", containers["Anti Spectator"])
specWarning.Size = UDim2.new(0.96, 0, 0, 60)
specWarning.BackgroundTransparency = 1
specWarning.TextColor3 = Color3.fromRGB(255, 100, 100)
specWarning.TextWrapped = true
specWarning.Font = Enum.Font.GothamMedium
specWarning.TextSize = 14
specWarning.Text = "WARNING: use after u setup everything becouse it might think you spectator if you are spectating to set up a farm and kick u becouse of that"

createBtn("Anti Spectator", "RUN CMD SPECTATOR DETECTOR", Color3.fromRGB(0, 150, 0), function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/maximzhu4/AstralData/refs/heads/main/cmd%20spectator%20detector"))()
end)

-- === ANTI DANGER ===
createBtn("Anti Danger", "RUN LOCATION LOCK & GUARD", Color3.fromRGB(100, 40, 0), function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/maximzhu4/AstralData/refs/heads/main/ASTRAL%20HUB%3A%20LOCATION%20LOCK%20%26%20GUARD"))()
end)

-- === SETTINGS ===
createBtn("Settings", "FPS BOOST", Color3.fromRGB(150, 0, 0), superBoost)
createToggle("Settings", "Anti-AFK", function(s) 
    if s then
        player.Idled:Connect(function() VirtualInputManager:SendKeyEvent(true, "Space", false, game) end)
    end
end)
createBtn("Settings", "CLOSE HUB", Color3.fromRGB(100, 20, 20), function() sg:Destroy() _G.AstralLoop:Disconnect() end)

-- === MAIN LOOP ===
_G.AstralLoop = RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if farmActive then
        root.CFrame = targetCFrame
        pcall(function() game:GetService("ReplicatedStorage")["Remote Events"].ActivateStarted:FireServer("Normal", targetCFrame) end)
    end

    root.Anchored = anchorActive
    if noclipActive then for _, v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    root.Size = myHitboxActive and Vector3.new(myHitboxSize, myHitboxSize, myHitboxSize) or Vector3.new(2,2,1)
    
    -- Виправлений Авто Клікер
    if autoClick then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end

    if autoE then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            hrp.Size = hitboxActive and Vector3.new(hitboxSize, hitboxSize, hitboxSize) or Vector3.new(2,2,1)
            hrp.Transparency = hitboxActive and 0.7 or 1
            if espActive then
                if not v.Character:FindFirstChild("AstralHighlight") then Instance.new("Highlight", v.Character).Name = "AstralHighlight" end
            elseif v.Character:FindFirstChild("AstralHighlight") then v.Character.AstralHighlight:Destroy() end
        end
    end
end)

UserInputService.JumpRequest:Connect(function() if infJump and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:ChangeState("Jumping") end end)

-- Dragging
local dToggle, dStart, sPos
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dToggle = true dStart = i.Position sPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dToggle and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dStart
    main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dToggle = false end end)

updatePlayers()
