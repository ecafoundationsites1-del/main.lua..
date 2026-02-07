-- [[ 서비스 선언 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

-- [[ 기존 UI 제거 (중복 실행 방지) ]]
local oldGui = Player.PlayerGui:FindFirstChild("OptimizedGui") or (game:GetService("CoreGui"):FindFirstChild("OptimizedGui"))
if oldGui then oldGui:Destroy() end

-- [[ 설정 ]]
local CONFIG = {
    KEY = "DORS123",
    TITLE = "DELTA PREMIUM V2"
}

-- [[ UI 생성 - Delta 최적화 ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OptimizedGui"
ScreenGui.ResetOnSpawn = false -- 캐릭터 죽어도 유지
-- Delta에서는 PlayerGui가 가장 확실합니다.
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 300)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Delta에서는 기본 Draggable이 먹히는 경우가 많음

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

-- 타이틀
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = CONFIG.TITLE
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

-- [ 로그인 섹션 ]
local LoginSection = Instance.new("Frame", MainFrame)
LoginSection.Size = UDim2.new(1, -20, 1, -60)
LoginSection.Position = UDim2.new(0, 10, 0, 50)
LoginSection.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox", LoginSection)
KeyInput.Size = UDim2.new(1, 0, 0, 40)
KeyInput.Position = UDim2.new(0, 0, 0.2, 0)
KeyInput.PlaceholderText = "인증키 입력..."
KeyInput.Text = ""
KeyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
KeyInput.TextColor3 = Color3.new(1, 1, 1)

local LoginBtn = Instance.new("TextButton", LoginSection)
LoginBtn.Size = UDim2.new(1, 0, 0, 40)
LoginBtn.Position = UDim2.new(0, 0, 0.5, 0)
LoginBtn.Text = "로그인 (DORS123)"
LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
LoginBtn.TextColor3 = Color3.new(1, 1, 1)

-- [ 기능 섹션 ]
local FeatureSection = Instance.new("Frame", MainFrame)
FeatureSection.Size = UDim2.new(1, -20, 1, -60)
FeatureSection.Position = UDim2.new(0, 10, 0, 50)
FeatureSection.BackgroundTransparency = 1
FeatureSection.Visible = false

local aimEnabled = false
local AimBtn = Instance.new("TextButton", FeatureSection)
AimBtn.Size = UDim2.new(1, 0, 0, 45)
AimBtn.Text = "Aimbot: OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
AimBtn.TextColor3 = Color3.new(1, 1, 1)

-- [[ 로직 ]]
LoginBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CONFIG.KEY then
        LoginSection.Visible = false
        FeatureSection.Visible = true
        Title.Text = "환영합니다, " .. Player.Name
    else
        KeyInput.PlaceholderText = "잘못된 키!"
        KeyInput.Text = ""
    end
end)

AimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimBtn.Text = "Aimbot: " .. (aimEnabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

-- 에임봇 작동 (가장 가까운 사람 보기)
RunService.RenderStepped:Connect(function()
    if aimEnabled and Player.Character then
        local closest = nil
        local dist = 1000
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local d = (v.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = v.Character
                end
            end
        end
        if closest then
            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, closest.HumanoidRootPart.Position)
        end
    end
end)

