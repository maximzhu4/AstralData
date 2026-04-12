local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Стейт
local targetCFrame = CFrame.new(120.76, -15.05, 84.76)
local farmActive, hitboxActive, espActive, infJump, noclipActive, antiAfk = false, false, false, false, false, true
local walkSpeedValue, jumpPowerValue, hitboxSize = 16, 50, 15
local accentColor = Color3.fromRGB(0, 170, 255)

-- ОЧИЩЕННЯ
if _G.AstralLoop then _G.AstralLoop:Disconnect() end
local old = player.PlayerGui:FindFirstChild("AstralHub")
if old then old:Destroy() end

-- ANTI-AFK
player.Idled:Connect(function()
    if antiAfk then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end
end)

-- ФУНКЦІЯ ОПТИМІЗАЦІЇ
local function boostFPS()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("PostProcessEffect") or v:IsA("Explosion") then
            v.Enabled = false
        end
    end
end

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "AstralHub"
sg.ResetOnSpawn = false

-- ВІКНО
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 520, 0, 400)
main.Position = UDim2.new(0.5, -260, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- ПЛАНЕТА
local planet = Instance.new("Frame", main)
planet.Size = UDim2.new(0, 50, 0, 50)
planet.Position = UDim2.new(1, -65, 1, -65)
planet.BackgroundColor3 = accentColor
planet.ZIndex = 5
Instance.new("UICorner", planet).CornerRadius = UDim.new(1, 0)
local planetGrad = Instance.new("UIGradient", planet)
planetGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, accentColor)})
task.spawn(function() while task.wait() do planetGrad.Rotation = planetGrad.Rotation + 2 planet.BackgroundColor3 = accentColor end end)

-- БІЧНА ПАНЕЛЬ
local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 140, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Instance.new("UICorner", side)

local hubName = Instance.new("TextLabel", side)
hubName.Text = "ASTRAL"
hubName.Size = UDim2.new(1, 0, 0, 60)
hubName.TextColor3 = accentColor
hubName.Font = Enum.Font.GothamBold
hubName.TextSize = 24
hubName.BackgroundTransparency = 1

local containers = {}
local function createTab(name, order)
    local btn = Instance.new("TextButton", side)
    btn.Size = UDim2.new(1, -15, 0, 40)
    btn.Position = UDim2.new(0, 7, 0, 70 + (order * 50))
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = name
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    btn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", btn)
    
    local cont = Instance.new("ScrollingFrame", main)
    cont.Size = UDim2.new(1, -165, 1, -25)
    cont.Position = UDim2.new(0, 150, 0, 15)
    cont.BackgroundTransparency = 1
    cont.Visible = (order == 0)
    cont.ScrollBarThickness = 0
    containers[name] = cont
    Instance.new("UIListLayout", cont).Padding = UDim.new(0, 12)
    
    btn.MouseButton1Click:Connect(function()
        for _, c in pairs(containers) do c.Visible = false end
        cont.Visible = true
    end)
end

createTab("Main", 0)
createTab("Character", 1)
createTab("Visuals", 2)
createTab("Settings", 3)

local function createToggle(tab, text, callback)
    local b = Instance.new("TextButton", containers[tab])
    b.Size = UDim2.new(0.98, 0, 0, 38)
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

local function createHeader(tab, text)
    local l = Instance.new("TextLabel", containers[tab])
    l.Size = UDim2.new(1, 0, 0, 20)
    l.Text = "—— " .. text .. " ——"
    l.TextColor3 = accentColor
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
end

local function createBtn(tab, text, color, callback)
    local b = Instance.new("TextButton", containers[tab])
    b.Size = UDim2.new(0.98, 0, 0, 38)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

-- MAIN TAB
createHeader("Main", "AFK & AUTOMATION")
createToggle("Main", "Anti-AFK Mode", function(s) antiAfk = s end)
createToggle("Main", "Auto Farm AFK", function(s) 
    farmActive = s 
    if s then
        local args = {[1] = "Normal", [2] = CFrame.new(13.00, 30.99, 96.00)}
        pcall(function() game:GetService("ReplicatedStorage")["Remote Events"].ActivateStarted:FireServer(unpack(args)) end)
    end
end)

createBtn("Main", "SET CURRENT POSITION", Color3.fromRGB(45, 45, 60), function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        targetCFrame = player.Character.HumanoidRootPart.CFrame
    end
end)

local nickBox = Instance.new("TextBox", containers["Main"])
nickBox.Size = UDim2.new(0.98, 0, 0, 35)
nickBox.PlaceholderText = "Players Name"
nickBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
nickBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", nickBox)

createBtn("Main", "GET PLAYER LOCATION", Color3.fromRGB(80, 45, 120), function()
    for _, v in pairs(game.Players:GetPlayers()) do
        if (v.Name:lower():find(nickBox.Text:lower()) or v.DisplayName:lower():find(nickBox.Text:lower())) and v.Character:FindFirstChild("HumanoidRootPart") then
            targetCFrame = v.Character.HumanoidRootPart.CFrame
            break
        end
    end
end)

createBtn("Main", "COPY TELEPORT + LAG FIX", Color3.fromRGB(30, 80, 30), function()
    local x, y, z = targetCFrame.X, targetCFrame.Y, targetCFrame.Z
    local code = string.format([[
local t = CFrame.new(%.2f, %.2f, %.2f)
settings().Rendering.QualityLevel = 1
for _,v in pairs(game:GetDescendants()) do 
    if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic elseif v:IsA("Decal") then v:Destroy() end 
end
game:GetService("RunService").Heartbeat:Connect(function()
    pcall(function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = t end)
end)
]], x, y, z)
    if setclipboard then setclipboard(code) end
end)

-- CHARACTER TAB
createHeader("Character", "MODS")
createToggle("Character", "Noclip", function(s) noclipActive = s end)
createToggle("Character", "Infinite Jump", function(s) infJump = s end)
createToggle("Character", "Expand Hitboxes", function(s) hitboxActive = s end)

-- VISUALS TAB
createHeader("Visuals", "PLAYER ESP")
createToggle("Visuals", "Highlight ESP", function(s) espActive = s end)

-- SETTINGS TAB
createHeader("Settings", "OPTIMIZATION")
createBtn("Settings", "EXTREME FPS BOOSTER", Color3.fromRGB(180, 50, 0), boostFPS)

-- ГОЛОВНИЙ ЦИКЛ
_G.AstralLoop = RunService.Heartbeat:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        if farmActive and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
            char.HumanoidRootPart.CFrame = targetCFrame
        end
        if noclipActive then
            for _, v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
    end
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            v.Character.HumanoidRootPart.Size = hitboxActive and Vector3.new(hitboxSize, hitboxSize, hitboxSize) or Vector3.new(2,2,1)
            v.Character.HumanoidRootPart.Transparency = hitboxActive and 0.7 or 1
            
            local hl = v.Character:FindFirstChild("AstralESP")
            if espActive then
                if not hl then 
                    hl = Instance.new("Highlight", v.Character)
                    hl.Name = "AstralESP"
                    hl.FillColor = accentColor
                end
            elseif hl then hl:Destroy() end
        end
    end
end)

-- Dragging
local d, di, ds, sp
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = main.Position i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end) end end)
main.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then di = i end end)
RunService.RenderStepped:Connect(function() if d and di then local delta = di.Position - ds main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)

local function createTopBtn(text, pos, color, cb)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0, 30, 0, 30)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb)
end
createTopBtn("✕", UDim2.new(1, -40, 0, 10), Color3.fromRGB(80, 20, 20), function() sg:Destroy() end)
createTopBtn("—", UDim2.new(1, -80, 0, 10), Color3.fromRGB(30, 30, 40), function() main.Visible = false end)
