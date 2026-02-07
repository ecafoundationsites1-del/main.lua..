-- [[ APRIL FOOLS PREMIUM V5 - ULTIMATE CONSOLIDATED ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ UI 초기화 및 중복 방지 ]]
local uiName = "AprilPremium_Final"
local oldGui = CoreGui:FindFirstChild(uiName) or (Player:FindFirstChild("PlayerGui") and Player.PlayerGui:FindFirstChild(uiName))
if oldGui then pcall(function() oldGui:Destroy() end) end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false -- 라운드 시작/부활 시 사라짐 방지
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 실행 환경에 따른 부모 설정
local success, err = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- [[ 전역 상태 ]]
local state = {
    aim = false,
    wall = false,
    lastFire = 0,
    fireRate = 0.1,
    key = "1234" -- 고정 접속 키
}

-- [[ UI 컴포넌트 ]]
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 280)
Main.Position = UDim2.new(0.5, -130, 0.4, -140)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "PREMIUM V5 (COMBINED)"
Title.TextColor3 = Color3.new(1, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

-- 페이지 설정
local LoginPage = Instance.new("Frame", Main)
LoginPage.Size = UDim2.new(1, 0, 1, -40)
LoginPage.Position = UDim2.new(0, 0, 0, 40)
LoginPage.BackgroundTransparency = 1

local HackPage = Instance.new("Frame", Main)
HackPage.Size = UDim2.new(1, 0, 1, -40)
HackPage.Position = UDim2.new(0, 0, 0, 40)
HackPage.BackgroundTransparency = 1
HackPage.Visible = false

-- 로그인 요소
local KeyInput = Instance.new("TextBox", LoginPage)
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.2, 0)
KeyInput.PlaceholderText = "Enter Key (1234)"
KeyInput.TextScaled = true

local LoginBtn = Instance.new("TextButton", LoginPage)
LoginBtn.Size = UDim2.new(0.8, 0, 0, 40)
LoginBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
LoginBtn.Text = "LOGIN"
LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)

-- 기능 버튼
local AimBtn = Instance.new("TextButton", HackPage)
AimBtn.Size = UDim2.new(0.8, 0, 0, 50)
AimBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
AimBtn.Text = "AIM LOCK: OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)

local WallBtn = Instance.new("TextButton", HackPage)
WallBtn.Size = UDim2.new(0.8, 0, 0, 50)
WallBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
WallBtn.Text = "WALL SHOOT: OFF"
WallBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)

-- [[ 핵심 기능 로직 ]]

local function getTarget()
    local target, dist = nil, 1500
    local myChar = Player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            -- 팀 체크 (적군만 타겟팅)
            if v.Team ~= Player.Team or v.Team == nil then
                local hum = v.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local mag = (v.Character.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
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

local function fireMagic()
    local target = getTarget()
    if not target or not Player.Character:FindFirstChild("Head") then return end
    
    local bullet = Instance.new("Part", workspace)
    bullet.Size = Vector3.new(0.4, 0.4, 6)
    bullet.Color = Color3.new(1, 1, 0)
    bullet.Material = Enum.Material.Neon
    bullet.Anchored = true
    bullet.CanCollide = false
    bullet.CanQuery = false -- 벽 무시 핵심 옵션
    
    local startPos = Player.Character.Head.Position
    local endPos = target.HumanoidRootPart.Position
    bullet.CFrame = CFrame.lookAt(startPos, endPos)
    
    local tween = TweenService:Create(bullet, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {Position = endPos})
    tween:Play()
    tween.Completed:Connect(function() bullet:Destroy() end)
    game:GetService("Debris"):AddItem(bullet, 1)
end

-- [[ 이벤트 연결 ]]

LoginBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == state.key then
        LoginPage.Visible = false
        HackPage.Visible = true
        Title.Text = "SYSTEM ACTIVE"
        Title.TextColor3 = Color3.new(0, 1, 0)
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "WRONG!"
    end
end)

AimBtn.MouseButton1Click:Connect(function()
    state.aim = not state.aim
    AimBtn.Text = "AIM LOCK: " .. (state.aim and "ON" or "OFF")
    AimBtn.BackgroundColor3 = state.aim and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
end)

WallBtn.MouseButton1Click:Connect(function()
    state.wall = not state.wall
    WallBtn.Text = "WALL SHOOT: " .. (state.wall and "ON" or "OFF")
    WallBtn.BackgroundColor3 = state.wall and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
end)

-- 프레임마다 에임 업데이트
RunService.Heartbeat:Connect(function()
    if state.aim then
        local target = getTarget()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.HumanoidRootPart.Position)
        end
    end
end)

-- 공격 입력 (모바일 터치/PC 클릭)
UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    if state.wall and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        if tick() - state.lastFire >= state.fireRate then
            state.lastFire = tick()
            fireMagic()
        end
    end
end)
