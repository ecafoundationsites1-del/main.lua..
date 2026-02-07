-- [[ APRIL FOOLS V7.0 ULTIMATE - REFERENCE STYLE ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ UI 제거 및 초기화 (중복 방지) ]]
local old = CoreGui:FindFirstChild("UltimateApril") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("UltimateApril")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateApril"
ScreenGui.Parent = (pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

-- [[ 설정 및 상태 ]]
local Settings = {
    Enabled = false,
    WallPenetration = false,
    Key = "DORS123"
}

-- [[ UI 구성 (모바일 최적화 다크 테마) ]]
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 280)
Main.Position = UDim2.new(0.5, -130, 0.4, -140)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "APRIL PREMIUIM V7"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title)

-- [ 로그인 및 기능 섹션 레이아웃 ]
local LoginSection = Instance.new("Frame", Main)
LoginSection.Size = UDim2.new(1, 0, 1, -40)
LoginSection.Position = UDim2.new(0, 0, 0, 40)
LoginSection.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox", LoginSection)
KeyInput.Size = UDim2.new(0.85, 0, 0, 45)
KeyInput.Position = UDim2.new(0.075, 0, 0.2, 0)
KeyInput.PlaceholderText = "KEY: DORS123"
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", KeyInput)

local LoginBtn = Instance.new("TextButton", LoginSection)
LoginBtn.Size = UDim2.new(0.85, 0, 0, 45)
LoginBtn.Position = UDim2.new(0.075, 0, 0.6, 0)
LoginBtn.Text = "LOGIN"
LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
LoginBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", LoginBtn)

local HackSection = Instance.new("Frame", Main)
HackSection.Size = UDim2.new(1, 0, 1, -40)
HackSection.Position = UDim2.new(0, 0, 0, 40)
HackSection.BackgroundTransparency = 1
HackSection.Visible = false

local AimBtn = Instance.new("TextButton", HackSection)
AimBtn.Size = UDim2.new(0.85, 0, 0, 50)
AimBtn.Position = UDim2.new(0.075, 0, 0.15, 0)
AimBtn.Text = "에임&몸 꺾기: OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
AimBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", AimBtn)

local WallBtn = Instance.new("TextButton", HackSection)
WallBtn.Size = UDim2.new(0.85, 0, 0, 50)
WallBtn.Position = UDim2.new(0.075, 0, 0.55, 0)
WallBtn.Text = "벽 관통 사격: OFF"
WallBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
WallBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", WallBtn)

-- [[ 타겟팅 시스템: 팀원 제외 및 살아있는 가장 가까운 적 ]]
local function GetClosestTarget()
    local nearest = nil
    local lastDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
            local hum = p.Character.Humanoid
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if hum.Health > 0 and root and (p.Team == nil or p.Team ~= LocalPlayer.Team) then
                local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < lastDist then
                    lastDist = dist
                    nearest = p.Character
                end
            end
        end
    end
    return nearest
end

-- [[ 기능 1: 몸 꺾기 & 화면 고정 (Stepped에서 애니메이션 덮어쓰기) ]]
RunService.Stepped:Connect(function()
    if Settings.Enabled and LocalPlayer.Character then
        local target = GetClosestTarget()
        if target then
            local waist = LocalPlayer.Character:FindFirstChild("Waist", true)
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if waist and root and target:FindFirstChild("Head") then
                -- 화면을 적 머리에 고정
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Head.Position)
                -- 애니메이���을 이기고 몸을 꺾음
                local lookAt = (target.Head.Position - root.Position).Unit
                waist.Transform = CFrame.new(Vector3.new(), root.CFrame:VectorToObjectSpace(lookAt))
            end
        end
    end
end)

-- [[ 기능 2: 벽 관통 (사격 데이터 후킹 시뮬레이션) ]]
local function BulletHook()
    local target = GetClosestTarget()
    if target and Settings.WallPenetration and LocalPlayer.Character then
        -- 참고 코드 방식의 데이터 패킷 구성
        local shotData = {
            ["Hit"] = target:FindFirstChild("Head") or target.PrimaryPart,
            ["Pos"] = target:FindFirstChild("Head") and target.Head.Position or target.PrimaryPart.Position,
            ["Ray"] = Ray.new(Camera.CFrame.Position, (target:FindFirstChild("Head") and target.Head.Position or target.PrimaryPart.Position - Camera.CFrame.Position).Unit * 1000)
        }
        
        -- 사격 리모트를 찾아 데이터 전송
        for _, r in pairs(game:GetDescendants()) do
            if r:IsA("RemoteEvent") and (r.Name:lower():find("fire") or r.Name:lower():find("shoot")) then
                pcall(function()
                    r:FireServer(shotData.Hit, shotData.Pos)
                end)
            end
        end
        
        -- 시각적 레이저 효과
        if LocalPlayer.Character:FindFirstChild("Head") then
            local p = Instance.new("Part", workspace)
            p.Anchored = true
            p.CanCollide = false
            p.Material = Enum.Material.Neon
            p.Color = Color3.new(1, 0, 0)
            p.Size = Vector3.new(0.1, 0.1, (LocalPlayer.Character.Head.Position - (target:FindFirstChild("Head") and target.Head.Position or target.PrimaryPart.Position)).Magnitude)
            p.CFrame = CFrame.lookAt(LocalPlayer.Character.Head.Position, target:FindFirstChild("Head") and target.Head.Position or target.PrimaryPart.Position) * CFrame.new(0, 0, -p.Size.Z/2)
            task.wait(0.06)
            p:Destroy()
        end
    end
end

-- [[ 버튼 및 입력 이벤트 ]]
LoginBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == Settings.Key then
        LoginSection.Visible = false
        HackSection.Visible = true
        Title.Text = "HACK LOADED"
        Title.TextColor3 = Color3.new(0, 1, 0)
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "WRONG KEY!"
    end
end)

AimBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    AimBtn.Text = "에임&몸 꺾기: " .. (Settings.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

WallBtn.MouseButton1Click:Connect(function()
    Settings.WallPenetration = not Settings.WallPenetration
    WallBtn.Text = "벽 관통 사격: " .. (Settings.WallPenetration and "ON" or "OFF")
    WallBtn.BackgroundColor3 = Settings.WallPenetration and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

UserInputService.InputBegan:Connect(function(input, proc)
    if not proc and Settings.WallPenetration and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        BulletHook()
    end
end)
