-- [[ APRIL FOOLS PREMIUM V5 - WALL PENETRATION FIXED ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 기존 UI 제거 ]]
local oldGui = CoreGui:FindFirstChild("AprilFinal") or (Player:FindFirstChild("PlayerGui") and Player.PlayerGui:FindFirstChild("AprilFinal"))
if oldGui then pcall(function() oldGui:Destroy() end) end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AprilFinal"
ScreenGui.ResetOnSpawn = false

-- [[ 설정 값 ]]
local aimEnabled = false
local wallEnabled = false
local lastFireTime = 0
local fireRate = 0.1 
local CONFIG = { 
    KEY = "1234", -- 사용하기 편하게 고정 키로 변경했습니다.
    MAX_FIRE_DISTANCE = 2000
}

-- [[ UI 생성 (간소화) ]]
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
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local AimBtn = Instance.new("TextButton", MainFrame)
AimBtn.Size = UDim2.new(0.9, 0, 0, 45)
AimBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
AimBtn.Text = "AIM LOCK: OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

local WallBtn = Instance.new("TextButton", MainFrame)
WallBtn.Size = UDim2.new(0.9, 0, 0, 45)
WallBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
WallBtn.Text = "WALL SHOOT: OFF"
WallBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

-- [[ 타겟 찾기 함수 ]]
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

-- [[ 핵심: 벽 뚫는 총알 함수 ]]
local function fireMagic()
    local target = getTarget()
    if not target or not Player.Character then return end
    
    local startPos = Player.Character.Head.Position
    local endPos = target.HumanoidRootPart.Position

    -- 투사체 생성
    local projectile = Instance.new("Part")
    projectile.Size = Vector3.new(0.3, 0.3, 8)
    projectile.Color = Color3.new(1, 0.5, 0) -- 주황색 궤적
    projectile.Material = Enum.Material.Neon
    projectile.Parent = workspace
    
    -- 벽 통과를 위한 핵심 설정
    projectile.Anchored = true      -- 물리 엔진 영향 제거
    projectile.CanCollide = false   -- 물리적 충돌 제거
    projectile.CanTouch = false     -- 닿음 이벤트 제거
    projectile.CanQuery = false     -- 레이캐스트(벽 체크) 무시
    
    projectile.CFrame = CFrame.lookAt(startPos, endPos)

    -- 이동 (Tween)
    local tween = TweenService:Create(projectile, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Position = endPos})
    tween:Play()
    
    -- 적중 후 삭제
    tween.Completed:Connect(function()
        projectile:Destroy()
    end)
    game:GetService("Debris"):AddItem(projectile, 1)
end

-- [[ 이벤트 연결 ]]
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

-- 에임봇 루프
RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local target = getTarget()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.HumanoidRootPart.Position)
        end
    end
end)

-- 클릭/터치 시 발사
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if wallEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        if tick() - lastFireTime >= fireRate then
            lastFireTime = tick()
            fireMagic()
        end
    end
end)

