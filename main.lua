-- [[ APRIL FOOLS PREMIUM V5 - WALL PENETRATION FIXED ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ Remove existing UI ]]
local oldGui = CoreGui:FindFirstChild("AprilFinal") or (Player:FindFirstChild("PlayerGui") and Player.PlayerGui:FindFirstChild("AprilFinal"))
if oldGui then pcall(function() oldGui:Destroy() end) end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AprilFinal"
ScreenGui.ResetOnSpawn = false

-- [[ Configuration ]]
local aimEnabled = false
local wallEnabled = false
local lastFireTime = 0
local fireRate = 0.1 
local CONFIG = { 
    KEY = "1234",
    MAX_FIRE_DISTANCE = 2000
}

-- [[ UI Creation ]]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 250)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "WALL PENETRATION V5"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Font = Enum.Font.GothamBold

local AimBtn = Instance.new("TextButton", MainFrame)
AimBtn.Size = UDim2.new(0.9, 0, 0, 45)
AimBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
AimBtn.Text = "AIM LOCK: OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
AimBtn.TextColor3 = Color3.new(1, 1, 1)
AimBtn.Font = Enum.Font.Gotham

local WallBtn = Instance.new("TextButton", MainFrame)
WallBtn.Size = UDim2.new(0.9, 0, 0, 45)
WallBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
WallBtn.Text = "WALL SHOOT: OFF"
WallBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
WallBtn.TextColor3 = Color3.new(1, 1, 1)
WallBtn.Font = Enum.Font.Gotham

-- [[ Target finding function ]]
local function getTarget()
    local target, dist = nil, CONFIG.MAX_FIRE_DISTANCE
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Team ~= Player.Team then
                local mag = (v.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                if mag < dist then
                    dist = mag
                    target = v.Character
                end
            end
        end
    end
    return target
end

-- [[ Core: Wall-piercing bullet function ]]
local function fireMagic()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local target = getTarget()
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    
    local startPos = Player.Character.Head.Position
    local endPos = target.HumanoidRootPart.Position

    -- Create projectile
    local projectile = Instance.new("Part")
    projectile.Size = Vector3.new(0.3, 0.3, 8)
    projectile.Color = Color3.new(1, 0.5, 0) -- Orange trajectory
    projectile.Material = Enum.Material.Neon
    projectile.Parent = workspace
    
    -- Core settings for wall penetration
    projectile.Anchored = true
    projectile.CanCollide = false
    projectile.CanTouch = false
    projectile.CanQuery = false
    
    projectile.CFrame = CFrame.lookAt(startPos, endPos)

    -- Movement (Tween)
    local tween = TweenService:Create(projectile, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Position = endPos})
    tween:Play()
    
    -- Delete after impact
    tween.Completed:Connect(function()
        if projectile and projectile.Parent then
            projectile:Destroy()
        end
    end)
    game:GetService("Debris"):AddItem(projectile, 1)
end

-- [[ Event connections ]]
AimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimBtn.Text = "AIM LOCK: " .. (aimEnabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

WallBtn.MouseButton1Click:Connect(function()
    wallEnabled = not wallEnabled
    WallBtn.Text = "WALL SHOOT: " .. (wallEnabled and "ON" or "OFF")
    WallBtn.BackgroundColor3 = wallEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if aimEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local target = getTarget()
        if target and target:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.HumanoidRootPart.Position)
        end
    end
end)

-- Fire on click/touch
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if wallEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        if tick() - lastFireTime >= fireRate then
            lastFireTime = tick()
            fireMagic()
        end
    end
end)
