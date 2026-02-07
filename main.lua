-- [[ APRIL FOOLS PREMIUM V5 - ULTIMATE MOBILE FORCE ]] --
-- Revised version with error handling and security improvements

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Validate essential services
if not Player or not Camera then
    warn("FATAL ERROR: Could not initialize Player or Camera service")
    return
end

-- [[ Remove existing UI and recreate ]]
local oldGui = CoreGui:FindFirstChild("AprilFinal") or Player:FindFirstChild("PlayerGui") and Player.PlayerGui:FindFirstChild("AprilFinal")
if oldGui then 
    pcall(function() oldGui:Destroy() end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AprilFinal"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Set parent with safety checks
local uiParent
local success = pcall(function() 
    ScreenGui.Parent = CoreGui 
    uiParent = CoreGui
end)

if not success then
    local playerGui = Player:FindFirstChild("PlayerGui")
    if playerGui then
        ScreenGui.Parent = playerGui
        uiParent = playerGui
    else
        warn("ERROR: Could not find suitable parent for UI")
        return
    end
end

-- [[ Global state ]]
local aimEnabled = false
local wallEnabled = false
local lastFireTime = 0
local fireRate = 0.1 -- Prevent spam
local CONFIG = { 
    KEY = os.time() % 10000, -- Dynamic key based on time
    TITLE = "MOBILE HACK V5",
    MAX_FIRE_DISTANCE = 1000
}

-- [[ UI Components (Draggable) ]]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 280)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = CONFIG.TITLE
Title.TextColor3 = Color3.new(1, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Instance.new("UICorner", Title)

-- [[ Page 1: Login ]]
local LoginPage = Instance.new("Frame", MainFrame)
LoginPage.Size = UDim2.new(1, 0, 1, -40)
LoginPage.Position = UDim2.new(0, 0, 0, 40)
LoginPage.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox", LoginPage)
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.2, 0)
KeyInput.PlaceholderText = "Enter authentication key..."
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.TextColor3 = Color3.new(1, 1, 1)
KeyInput.TextScaled = true

local LoginBtn = Instance.new("TextButton", LoginPage)
LoginBtn.Size = UDim2.new(0.8, 0, 0, 40)
LoginBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
LoginBtn.Text = "LOGIN"
LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
LoginBtn.TextColor3 = Color3.new(1, 1, 1)
LoginBtn.TextScaled = true

-- [[ Page 2: Features ]]
local HackPage = Instance.new("Frame", MainFrame)
HackPage.Size = UDim2.new(1, 0, 1, -40)
HackPage.Position = UDim2.new(0, 0, 0, 40)
HackPage.BackgroundTransparency = 1
HackPage.Visible = false

local AimBtn = Instance.new("TextButton", HackPage)
AimBtn.Size = UDim2.new(0.8, 0, 0, 50)
AimBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
AimBtn.Text = "Aim & Body Rotation: OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
AimBtn.TextColor3 = Color3.new(1, 1, 1)
AimBtn.TextScaled = true

local WallBtn = Instance.new("TextButton", HackPage)
WallBtn.Size = UDim2.new(0.8, 0, 0, 50)
WallBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
WallBtn.Text = "Wall Penetration: OFF"
WallBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
WallBtn.TextColor3 = Color3.new(1, 1, 1)
WallBtn.TextScaled = true

-- [[ Core Functions ]]

-- Safe target acquisition with distance limit
local function getTarget()
    if not Player or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local playerRoot = Player.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return nil end
    
    local target, dist = nil, CONFIG.MAX_FIRE_DISTANCE
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character then
            local humanoid = v.Character:FindFirstChild("Humanoid")
            local targetRoot = v.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and targetRoot and humanoid.Health > 0 then
                -- Check if enemy (different team or no team)
                if v.Team == nil or v.Team ~= Player.Team then
                    local mag = (targetRoot.Position - playerRoot.Position).Magnitude
                    if mag < dist then
                        dist = mag
                        target = v.Character
                    end
                end
            end
        end
    end
    
    return target
end

-- Feature 1: Body rotation with safety checks
local steppedConnection
steppedConnection = RunService.Stepped:Connect(function()
    if not aimEnabled or not Player or not Player.Character then
        return
    end
    
    local playerChar = Player.Character
    local waist = playerChar:FindFirstChild("Waist", true)
    local root = playerChar:FindFirstChild("HumanoidRootPart")
    local head = playerChar:FindFirstChild("Head")
    
    if not waist or not root or not head then
        return
    end
    
    local target = getTarget()
    if target then
        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            pcall(function()
                -- Fix camera aim
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetRoot.Position)
                -- Force waist rotation toward target
                local lookAt = (targetRoot.Position - root.Position).Unit
                local targetCFrame = CFrame.new(Vector3.new(), root.CFrame:VectorToObjectSpace(lookAt))
                waist.Transform = targetCFrame
            end)
        end
    end
end)

-- Feature 2: Wall penetration projectile with safety and cleanup
local activeParts = {}

local function cleanupPart(part)
    if part and part.Parent then
        table.remove(activeParts, table.find(activeParts, part) or #activeParts)
        pcall(function() part:Destroy() end)
    end
end

local function fireMagic()
    if not Player or not Player.Character then return end
    
    local playerHead = Player.Character:FindFirstChild("Head")
    if not playerHead then return end
    
    local target = getTarget()
    if not target then return end
    
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    -- Create projectile with safety
    local p = pcall(function()
        local projectile = Instance.new("Part", workspace)
        projectile.Size = Vector3.new(0.3, 0.3, 10)
        projectile.Color = Color3.new(1, 1, 0)
        projectile.CanCollide = false
        projectile.Anchored = true
        projectile.CFrame = CFrame.lookAt(playerHead.Position, targetRoot.Position)
        
        table.insert(activeParts, projectile)
        
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(projectile, tweenInfo, {Position = targetRoot.Position})
        
        tween.Completed:Connect(function()
            cleanupPart(projectile)
        end)
        
        tween:Play()
        
        -- Failsafe cleanup after 5 seconds
        game:GetService("Debris"):AddItem(projectile, 5)
    end)
    
    if not p then
        warn("ERROR: Failed to create projectile")
    end
end

-- [[ Event Handlers ]]

-- Login button handler
LoginBtn.MouseButton1Click:Connect(function()
    local inputKey = tonumber(KeyInput.Text) or -1
    if inputKey == CONFIG.KEY then
        LoginPage.Visible = false
        HackPage.Visible = true
        Title.Text = "WELCOME, DEVELOPER"
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "WRONG KEY! Try again."
    end
end)

-- Aim button handler
AimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimBtn.Text = "Aim & Body Rotation: " .. (aimEnabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
end)

-- Wall penetration button handler
WallBtn.MouseButton1Click:Connect(function()
    wallEnabled = not wallEnabled
    WallBtn.Text = "Wall Penetration: " .. (wallEnabled and "ON" or "OFF")
    WallBtn.BackgroundColor3 = wallEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
end)

-- Fire input handler with rate limiting
UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    
    if wallEnabled and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        local currentTime = tick()
        if currentTime - lastFireTime >= fireRate then
            lastFireTime = currentTime
            fireMagic()
        end
    end
end)

-- Cleanup on script unload
game:BindToClose(function()
    if steppedConnection then
        steppedConnection:Disconnect()
    end
    for _, part in ipairs(activeParts) do
        cleanupPart(part)
    end
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
    end
end)

