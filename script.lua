-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- // Settings
local CreditKillEnabled = false
local AuraRange = 25
local LastAuraTime = 0

-- // UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CreditKillUI_Final"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 180)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 5, 5)
Title.Text = "💀 CREDIT KILLER (Remote)"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local MassKillBtn = Instance.new("TextButton")
MassKillBtn.Size = UDim2.new(1, -20, 0, 45)
MassKillBtn.Position = UDim2.new(0, 10, 0, 50)
MassKillBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
MassKillBtn.Text = "☠️ УБИТЬ ВСЕХ (С ФРАГАМИ)"
MassKillBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MassKillBtn.Font = Enum.Font.GothamBold
MassKillBtn.TextSize = 15
MassKillBtn.Parent = MainFrame
local MassBtnCorner = Instance.new("UICorner")
MassBtnCorner.CornerRadius = UDim.new(0, 6)
MassBtnCorner.Parent = MassKillBtn

local AuraBtn = Instance.new("TextButton")
AuraBtn.Size = UDim2.new(1, -20, 0, 40)
AuraBtn.Position = UDim2.new(0, 10, 0, 105)
AuraBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
AuraBtn.Text = "💀 Credit Aura: ВЫКЛ"
AuraBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
AuraBtn.Font = Enum.Font.GothamBold
AuraBtn.TextSize = 14
AuraBtn.Parent = MainFrame
local AuraBtnCorner = Instance.new("UICorner")
AuraBtnCorner.CornerRadius = UDim.new(0, 6)
AuraBtnCorner.Parent = AuraBtn

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 20)
InfoLabel.Position = UDim2.new(0, 10, 0, 155)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Ищет Dummy и спамит урон через Remote."
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 11
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Parent = MainFrame

-- // Поиск всех ремоутов для урона
local DamageRemotes = {}
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") and (obj.Name:lower():find("damage") or obj.Name:lower():find("hit") or obj.Name:lower():find("kill") or obj.Name:lower():find("weapon")) then
        table.insert(DamageRemotes, obj)
        print("[SYSTEM] Найден ремоут урона:", obj:GetFullName())
    end
end

-- // Функция убийства
local function ForceKill(dummy)
    local hum = dummy:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    -- 1. Пытаемся нанести урон через найденные ремоуты
    for _, remote in ipairs(DamageRemotes) do
        pcall(function()
            remote:FireServer(dummy, 9999)
            remote:FireServer(dummy, 9999, "Head")
            remote:FireServer(dummy, 9999, dummy:FindFirstChild("Head"))
            remote:FireServer(dummy.Head, 9999)
        end)
    end

    -- 2. Если ремоутов нет или они не сработали, просто обнуляем здоровье
    pcall(function()
        hum:TakeDamage(9999)
        hum.Health = 0
        hum:ChangeState(Enum.HumanoidStateType.Dead)
    end)
end

-- // Кнопка "Убить всех"
MassKillBtn.MouseButton1Click:Connect(function()
    MassKillBtn.Text = "УБИВАЕМ..."
    MassKillBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)

    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("dummy") and obj ~= LocalPlayer.Character then
            ForceKill(obj)
            count = count + 1
        end
    end

    MassKillBtn.Text = "✅ УБИТО: " .. count
    task.wait(2)
    MassKillBtn.Text = "☠️ УБИТЬ ВСЕХ (С ФРАГАМИ)"
    MassKillBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
end)

-- // Логика Ауры
AuraBtn.MouseButton1Click:Connect(function()
    CreditKillEnabled = not CreditKillEnabled
    if CreditKillEnabled then
        AuraBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        AuraBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        AuraBtn.Text = "💀 Credit Aura: ВКЛ"
    else
        AuraBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        AuraBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        AuraBtn.Text = "💀 Credit Aura: ВЫКЛ"
    end
end)

-- // Главный цикл Ауры (Проверка раз в 0.5 сек, чтобы не лагало)
RunService.Heartbeat:Connect(function()
    if not CreditKillEnabled then return end
    
    if tick() - LastAuraTime < 0.5 then return end
    LastAuraTime = tick()
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("dummy") and obj ~= LocalPlayer.Character then
            local dummyRoot = obj:FindFirstChild("HumanoidRootPart")
            if dummyRoot and (dummyRoot.Position - hrp.Position).Magnitude <= AuraRange then
                ForceKill(obj)
            end
        end
    end
end)

print("[SYSTEM] Credit Killer loaded! Найдено ремоутов: " .. #DamageRemotes)
