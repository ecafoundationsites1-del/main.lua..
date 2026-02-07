-- [[ 서비스 선언 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

-- [[ 기존 UI 제거 (중복 실행 방지) ]]
for _, v in pairs(Player.PlayerGui:GetChildren()) do
    if v.Name == "OptimizedGui" then v:Destroy() end
end

-- [[ 설정 ]]
local CONFIG = {
    KEY = "DORS123",
    TITLE = "MOBILE PREMIUM V3"
}

-- [[ UI 생성 ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OptimizedGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 실행기에 따라 적절한 부모 설정 (PlayerGui 직접 사용)
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 280)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- 모바일 드래그 지원

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- 타이틀 바
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = CONFIG.TITLE
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BorderSizePixel = 0
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

-- [ 로그인 섹션 ]
local LoginSection = Instance.new("Frame", MainFrame)
LoginSection.Size = UDim2.new(1, -20, 1, -60)
LoginSection.Position = UDim2.new(0, 10, 0, 50)
LoginSection.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox", LoginSection)
KeyInput.Size = UDim2.new(1, 0, 0, 45)
KeyInput.Position = UDim2.new(0, 0, 0.15, 0)
KeyInput.PlaceholderText = "인증키(DORS123) 입력..."
KeyInput.Text = ""
KeyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
KeyInput.TextColor3 = Color3.new(1, 1, 1)
KeyInput.BorderSizePixel = 0
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)

local LoginBtn = Instance.new("TextButton", LoginSection)
LoginBtn.Size = UDim2.new(1, 0, 0, 45)
LoginBtn.Position = UDim2.new(0, 0, 0.5, 0)
LoginBtn.Text = "로그인 인증"
LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
LoginBtn.TextColor3 = Color3.new(1, 1, 1)
LoginBtn.BorderSizePixel = 0
LoginBtn.Font = Enum.Font.GothamBold
LoginBtn.TextSize = 14
Instance.new("UICorner", LoginBtn).CornerRadius = UDim.new(0, 8)

-- [ 기능 섹션 ]
local FeatureSection = Instance.new("Frame", MainFrame)
FeatureSection.Size = UDim2.new(1, -20, 1, -60)
FeatureSection.Position = UDim2.new(0, 10, 0, 50)
FeatureSection.BackgroundTransparency = 1
FeatureSection.Visible = false

local aimEnabled = false
local wallHackEnabled = false

local AimBtn = Instance.new("TextButton", FeatureSection)
AimBtn.Size = UDim2.new(1, 0, 0, 50)
AimBtn.Position = UDim2.new(0, 0, 0.1, 0)
AimBtn.Text = "몸 꺾기 에임: OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
AimBtn.TextColor3 = Color3.new(1, 1, 1)
AimBtn.BorderSizePixel = 0
AimBtn.Font = Enum.Font.GothamBold
AimBtn.TextSize = 14
Instance.new("UICorner", AimBtn).CornerRadius = UDim.new(0, 8)

local WallBtn = Instance.new("TextButton", FeatureSection)
WallBtn.Size = UDim2.new(1, 0, 0, 50)
WallBtn.Position = UDim2.new(0, 0, 0.5, 0)
WallBtn.Text = "벽 관통 사격: OFF"
WallBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
WallBtn.TextColor3 = Color3.new(1, 1, 1)
WallBtn.BorderSizePixel = 0
WallBtn.Font = Enum.Font.GothamBold
WallBtn.TextSize = 14
Instance.new("UICorner", WallBtn).CornerRadius = UDim.new(0, 8)

-- [[ 필터링 로직: 팀원 제외 및 살아있는 적만 ]]
local function getClosestEnemy()
    local maxDist = 2000
    local target = nil
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hum = v.Character:FindFirstChild("Humanoid")
            -- 적군 및 생존 여부 확인
            if (v.Team == nil or v.Team ~= Player.Team) and (hum and hum.Health > 0) then
                local mag = (v.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                if mag < maxDist then
                    maxDist = mag
                    target = v.Character
                end
            end
        end
    end
    return target
end

-- [[ 이벤트 연결 ]]
LoginBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CONFIG.KEY then
        LoginSection.Visible = false
        FeatureSection.Visible = true
        Title.Text = "ACCESS GRANTED"
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "잘못된 키입니다!"
    end
end)

AimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimBtn.Text = "몸 꺾기 에임: " .. (aimEnabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

WallBtn.MouseButton1Click:Connect(function()
    wallHackEnabled = not wallHackEnabled
    WallBtn.Text = "벽 관통 사격: " .. (wallHackEnabled and "ON" or "OFF")
    WallBtn.BackgroundColor3 = wallHackEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

-- 에임봇 루프 (몸 꺾기)
RunService.RenderStepped:Connect(function()
    if aimEnabled and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        local target = getClosestEnemy()
        if target then
            local waist = Player.Character:FindFirstChild("Waist", true)
            if waist then
                local dir = (target.HumanoidRootPart.Position - Player.Character.Head.Position).Unit
                waist.C0 = waist.C0:Lerp(CFrame.new(waist.C0.Position, dir), 0.15)
            end
        end
    end
end)

-- 벽 관통 총알 연출
UserInputService.InputBegan:Connect(function(input, proc)
    if not proc and wallHackEnabled and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        local target = getClosestEnemy()
        if target then
            local p = Instance.new("Part", workspace)
            p.Anchored = true; p.CanCollide = false; p.Size = Vector3.new(0.3, 0.3, 5)
            p.Color = Color3.new(1, 1, 0); p.CFrame = CFrame.lookAt(Player.Character.Head.Position, target.HumanoidRootPart.Position)
            local tween = TweenService:Create(p, TweenInfo.new(0.15), {Position = target.HumanoidRootPart.Position})
            tween:Play(); tween.Completed:Connect(function() p:Destroy() end)
        end
    end
end)
