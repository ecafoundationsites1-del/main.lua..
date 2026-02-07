-- [[ APRIL FOOLS PREMIUM V5 - ULTIMATE MOBILE FORCE ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 기존 UI 제거 및 재생성 ]]
local oldGui = CoreGui:FindFirstChild("AprilFinal") or Player.PlayerGui:FindFirstChild("AprilFinal")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AprilFinal"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-- 실행기 호환성을 위해 부모 설정
local uiParent = pcall(function() ScreenGui.Parent = CoreGui end) and CoreGui or Player:WaitForChild("PlayerGui")
ScreenGui.Parent = uiParent

-- [ 전역 상태 ]
local aimEnabled = false
local wallEnabled = false
local CONFIG = { KEY = "DORS123", TITLE = "MOBILE HACK V5" }

-- [[ UI 구성 (드래그 가능) ]]
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
Instance.new("UICorner", Title)

-- [ 페이지 1: 로그인 ]
local LoginPage = Instance.new("Frame", MainFrame)
LoginPage.Size = UDim2.new(1, 0, 1, -40)
LoginPage.Position = UDim2.new(0, 0, 0, 40)
LoginPage.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox", LoginPage)
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.2, 0)
KeyInput.PlaceholderText = "인증키(DORS123) 입력..."
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.TextColor3 = Color3.new(1, 1, 1)

local LoginBtn = Instance.new("TextButton", LoginPage)
LoginBtn.Size = UDim2.new(0.8, 0, 0, 40)
LoginBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
LoginBtn.Text = "LOGIN"
LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
LoginBtn.TextColor3 = Color3.new(1, 1, 1)

-- [ 페이지 2: 기능 ]
local HackPage = Instance.new("Frame", MainFrame)
HackPage.Size = UDim2.new(1, 0, 1, -40)
HackPage.Position = UDim2.new(0, 0, 0, 40)
HackPage.BackgroundTransparency = 1
HackPage.Visible = false

local AimBtn = Instance.new("TextButton", HackPage)
AimBtn.Size = UDim2.new(0.8, 0, 0, 50)
AimBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
AimBtn.Text = "에임&몸 꺾기: OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
AimBtn.TextColor3 = Color3.new(1, 1, 1)

local WallBtn = Instance.new("TextButton", HackPage)
WallBtn.Size = UDim2.new(0.8, 0, 0, 50)
WallBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
WallBtn.Text = "벽 관통샷: OFF"
WallBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
WallBtn.TextColor3 = Color3.new(1, 1, 1)

-- [[ 핵심 기능 로직 ]]

local function getTarget()
    local target, dist = nil, 1000
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Humanoid") then
            if v.Character.Humanoid.Health > 0 and (v.Team == nil or v.Team ~= Player.Team) then
                local mag = (v.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                if mag < dist then dist = mag; target = v.Character end
            end
        end
    end
    return target
end

-- 기능 1: 몸 꺾기 (Stepped에서 강제 Transform)
RunService.Stepped:Connect(function()
    if aimEnabled and Player.Character then
        local target = getTarget()
        if target then
            local waist = Player.Character:FindFirstChild("Waist", true)
            local root = Player.Character:FindFirstChild("HumanoidRootPart")
            if waist and root then
                -- 카메라 에임 고정
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.HumanoidRootPart.Position)
                -- 애니메이션을 무시하고 허리를 타겟 방향으로 강제 회전
                local lookAt = (target.HumanoidRootPart.Position - root.Position).Unit
                local targetCFrame = CFrame.new(Vector3.new(), root.CFrame:VectorToObjectSpace(lookAt))
                waist.Transform = targetCFrame
            end
        end
    end
end)

-- 기능 2: 벽 관통 총알 시뮬레이션
local function fireMagic()
    local target = getTarget()
    if target then
        local p = Instance.new("Part", workspace)
        p.Size = Vector3.new(0.3, 0.3, 10)
        p.Color = Color3.new(1, 1, 0)
        p.CanCollide = false
        p.Anchored = true
        p.CFrame = CFrame.lookAt(Player.Character.Head.Position, target.HumanoidRootPart.Position)
        
        local tw = TweenService:Create(p, TweenInfo.new(0.1), {Position = target.HumanoidRootPart.Position})
        tw:Play()
        tw.Completed:Connect(function() p:Destroy() end)
    end
end

-- [[ 이벤트 ]]
LoginBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CONFIG.KEY then
        LoginPage.Visible = false
        HackPage.Visible = true
        Title.Text = "WELCOME, DEVELOPER"
    else
        KeyInput.Text = ""; KeyInput.PlaceholderText = "WRONG KEY!"
    end
end)

AimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimBtn.Text = "에임&몸 꺾기: " .. (aimEnabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
end)

WallBtn.MouseButton1Click:Connect(function()
    wallEnabled = not wallEnabled
    WallBtn.Text = "벽 관통샷: " .. (wallEnabled and "ON" or "OFF")
    WallBtn.BackgroundColor3 = wallEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
end)

UserInputService.InputBegan:Connect(function(input, proc)
    if not proc and wallEnabled and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        fireMagic()
    end
end)

