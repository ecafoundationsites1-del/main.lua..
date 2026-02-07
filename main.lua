-- [[ APRIL FOOLS PREMIUM V6 - FINAL ULTIMATE ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 기존 UI 제거 ]]
local old = CoreGui:FindFirstChild("FinalExploit") or Player.PlayerGui:FindFirstChild("FinalExploit")
if old then old:Destroy() end

-- [[ UI 생성 ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FinalExploit"
ScreenGui.Parent = (pcall(function() return CoreGui end) and CoreGui or Player.PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 300)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "APRIL FOOL PREMIUM"
Title.TextColor3 = Color3.new(1, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title)

-- [ 변수 ]
local aimEnabled = false
local wallEnabled = false
local CONFIG = { KEY = "DORS123" }

-- [ 페이지 레이아웃 ]
local LoginSection = Instance.new("Frame", MainFrame)
LoginSection.Size = UDim2.new(1, 0, 1, -40)
LoginSection.Position = UDim2.new(0, 0, 0, 40)
LoginSection.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox", LoginSection)
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.2, 0)
KeyInput.PlaceholderText = "인증키 입력..."
KeyInput.Text = ""
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.TextColor3 = Color3.new(1, 1, 1)

local LoginBtn = Instance.new("TextButton", LoginSection)
LoginBtn.Size = UDim2.new(0.8, 0, 0, 40)
LoginBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
LoginBtn.Text = "LOGIN"
LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
LoginBtn.TextColor3 = Color3.new(1, 1, 1)

local HackSection = Instance.new("Frame", MainFrame)
HackSection.Size = UDim2.new(1, 0, 1, -40)
HackSection.Position = UDim2.new(0, 0, 0, 40)
HackSection.BackgroundTransparency = 1
HackSection.Visible = false

local AimBtn = Instance.new("TextButton", HackSection)
AimBtn.Size = UDim2.new(0.8, 0, 0, 50)
AimBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
AimBtn.Text = "몸 꺾기 & 에임: OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
AimBtn.TextColor3 = Color3.new(1, 1, 1)

local WallBtn = Instance.new("TextButton", HackSection)
WallBtn.Size = UDim2.new(0.8, 0, 0, 50)
WallBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
WallBtn.Text = "벽 관통 리모트: OFF"
WallBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
WallBtn.TextColor3 = Color3.new(1, 1, 1)

-- [[ 핵심 로직 ]]

local function getTarget()
    local target, dist = nil, 2000
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Character.Humanoid.Health > 0 then
                local playerTeam = Player.Team
                local vTeam = v.Team
                if (vTeam == nil or playerTeam == nil or vTeam ~= playerTeam) then
                    local mag = (v.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                    if mag < dist then dist = mag; target = v.Character end
                end
            end
        end
    end
    return target
end

-- 1. 몸 꺾기 및 화면 강제 고정
RunService.RenderStepped:Connect(function()
    if aimEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local target = getTarget()
        if target and target:FindFirstChild("HumanoidRootPart") then
            -- 화면 적에게 고정
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.HumanoidRootPart.Position)
            
            -- 몸 강제 꺾기 (Neck 회전을 통한 방식)
            local root = Player.Character:FindFirstChild("HumanoidRootPart")
            local neck = Player.Character:FindFirstChild("Neck")
            if neck and root and target.HumanoidRootPart then
                local relativeDir = (target.HumanoidRootPart.Position - root.Position).Unit
                neck.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(0, -math.atan2(relativeDir.X, relativeDir.Z), 0)
            end
        end
    end
end)

-- 2. 실제 사격 리모트 후킹 (벽 관통의 핵심)
local function sendMagicBullet()
    if not (Player.Character and Player.Character:FindFirstChild("Head")) then return end
    
    local target = getTarget()
    if target and target:FindFirstChild("Head") and wallEnabled then
        -- 게임 내 사격 리모트를 자동 감지하여 적의 좌표 전��
        for _, r in pairs(ReplicatedStorage:GetDescendants()) do
            if r:IsA("RemoteEvent") and (r.Name:lower():find("fire") or r.Name:lower():find("shoot") or r.Name:lower():find("hit")) then
                -- 서버에 적의 머리를 맞췄다고 강제 보고 (벽 무시 대미지 발생)
                pcall(function()
                    r:FireServer(target.Head, target.Head.Position)
                end)
            end
        end
        
        -- 시각적 레이저 트레일 (벽 통과 연출)
        local laser = Instance.new("Part", workspace)
        laser.Anchored = true
        laser.CanCollide = false
        laser.Size = Vector3.new(0.1, 0.1, (Player.Character.Head.Position - target.Head.Position).Magnitude)
        laser.CFrame = CFrame.lookAt(Player.Character.Head.Position, target.Head.Position) * CFrame.new(0, 0, -laser.Size.Z/2)
        laser.Color = Color3.new(1, 0, 0)
        laser.Material = Enum.Material.Neon
        task.wait(0.05)
        laser:Destroy()
    end
end

-- [[ 이벤트 ]]
LoginBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CONFIG.KEY then
        LoginSection.Visible = false
        HackSection.Visible = true
        Title.Text = "HACK ENABLED"
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "WRONG KEY!"
    end
end)

AimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimBtn.Text = "에임&몸 꺾기: " .. (aimEnabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

WallBtn.MouseButton1Click:Connect(function()
    wallEnabled = not wallEnabled
    WallBtn.Text = "벽 관통 리모트: " .. (wallEnabled and "ON" or "OFF")
    WallBtn.BackgroundColor3 = wallEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

-- 터치 시 사격 리모트 작동
UserInputService.InputBegan:Connect(function(i, p)
    if not p and wallEnabled and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then
        sendMagicBullet()
    end
end)
