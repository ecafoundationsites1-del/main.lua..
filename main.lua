-- [[ APRIL FOOLS PREMIUM V3 - TEAM & HEALTH FILTER ]] --

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- [ 설정 ]
local CONFIG = {
    KEY = "DORS123",
    LINK = "https://github.com/YourName/YourRepo", -- 본인 깃허브 링크로 수정
    TITLE = "MOBILE APRIL FOOLS V3"
}

-- [ 변수 ]
local aimEnabled = false
local wallHackEnabled = false

-- [ UI 생성 ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExploitGuiV3"
local success, err = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = Player.PlayerGui end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 280)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- 타이틀
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = CONFIG.TITLE
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- 1. 키 인증 섹션
local KeyPage = Instance.new("Frame", MainFrame)
KeyPage.Size = UDim2.new(1, 0, 1, -40)
KeyPage.Position = UDim2.new(0, 0, 0, 40)
KeyPage.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox", KeyPage)
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.2, 0)
KeyInput.PlaceholderText = "인증키 입력..."
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.TextColor3 = Color3.new(1, 1, 1)

local GetKeyBtn = Instance.new("TextButton", KeyPage)
GetKeyBtn.Size = UDim2.new(0.8, 0, 0, 40)
GetKeyBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
GetKeyBtn.Text = "키 링크 복사"
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 150)
GetKeyBtn.TextColor3 = Color3.new(1, 1, 1)

local LoginBtn = Instance.new("TextButton", KeyPage)
LoginBtn.Size = UDim2.new(0.8, 0, 0, 40)
LoginBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
LoginBtn.Text = "로그인"
LoginBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
LoginBtn.TextColor3 = Color3.new(1, 1, 1)

-- 2. 기능 섹션 (처음엔 숨김)
local HackPage = Instance.new("Frame", MainFrame)
HackPage.Size = UDim2.new(1, 0, 1, -40)
HackPage.Position = UDim2.new(0, 0, 0, 40)
HackPage.BackgroundTransparency = 1
HackPage.Visible = false

local AimBtn = Instance.new("TextButton", HackPage)
AimBtn.Size = UDim2.new(0.8, 0, 0, 50)
AimBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
AimBtn.Text = "몸 꺾기 (Silent): OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
AimBtn.TextColor3 = Color3.new(1, 1, 1)

local WallBtn = Instance.new("TextButton", HackPage)
WallBtn.Size = UDim2.new(0.8, 0, 0, 50)
WallBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
WallBtn.Text = "벽 관통샷: OFF"
WallBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
WallBtn.TextColor3 = Color3.new(1, 1, 1)

-- [ 필터링 로직: 팀원 제외 & 살아있는 적만 ]
local function getClosestEnemy()
    local maxDist = 2000
    local target = nil
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hum = v.Character:FindFirstChild("Humanoid")
            -- 팀 체크 & 체력 체크
            local isEnemy = (v.Team == nil or v.Team ~= Player.Team)
            local isAlive = (hum and hum.Health > 0)
            
            if isEnemy and isAlive then
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

-- 에임/몸 꺾기 루프
RunService.RenderStepped:Connect(function()
    if aimEnabled and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
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

-- 총알 관통 효과 (터치 시)
UserInputService.InputBegan:Connect(function(input, proc)
    if not proc and wallHackEnabled and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        local target = getClosestEnemy()
        if target then
            local p = Instance.new("Part", workspace)
            p.Anchored = true
            p.CanCollide = false
            p.Size = Vector3.new(0.4, 0.4, 4)
            p.Color = Color3.new(1, 1, 0)
            p.CFrame = CFrame.lookAt(Player.Character.Head.Position, target.HumanoidRootPart.Position)
            
            local tween = TweenService:Create(p, TweenInfo.new(0.15), {Position = target.HumanoidRootPart.Position})
            tween:Play()
            tween.Completed:Connect(function() p:Destroy() end)
        end
    end
end)

-- [ 이벤트 연결 ]
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(CONFIG.LINK)
        GetKeyBtn.Text = "링크 복사 완료!"
    else
        KeyInput.Text = CONFIG.LINK
        GetKeyBtn.Text = "위 칸 주소 확인"
    end
end)

LoginBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CONFIG.KEY then
        KeyPage.Visible = false
        HackPage.Visible = true
        Title.Text = "ACCESS GRANTED"
        Title.TextColor3 = Color3.new(0, 1, 0)
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "잘못된 키입니다!"
    end
end)

AimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimBtn.Text = "몸 꺾기: " .. (aimEnabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

WallBtn.MouseButton1Click:Connect(function()
    wallHackEnabled = not wallHackEnabled
    WallBtn.Text = "벽 관통샷: " .. (wallHackEnabled and "ON" or "OFF")
    WallBtn.BackgroundColor3 = wallHackEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)
