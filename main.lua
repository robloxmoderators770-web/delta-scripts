-- [[ RIVALS: ZOMBIE TOWER FULL DELTA HUB ]] --

-- 1. Configuration Toggles
getgenv().AimbotEnabled = true
getgenv().ESPBoxesEnabled = true
getgenv().TeamCheck = false -- Disabled by default so it targets Zombies instead of treating them like a friendly team

-- 2. Anti-Duplicate Check
if getgenv().RivalsZombieScriptLoaded then
    print("[Rivals Hub] Already active!")
    return
else
    getgenv().RivalsZombieScriptLoaded = true
end

-- 3. Core Roblox Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 4. Simple Visual Mobile GUI Menu
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleAimbot = Instance.new("TextButton")
local ToggleESP = Instance.new("TextButton")

ScreenGui.Name = "DeltaRivalsMenu"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 140)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "RIVALS ZOMBIE HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14.000

ToggleAimbot.Name = "ToggleAimbot"
ToggleAimbot.Parent = MainFrame
ToggleAimbot.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
ToggleAimbot.Position = UDim2.new(0.05, 0, 0.3, 0)
ToggleAimbot.Size = UDim2.new(0.9, 0, 0, 30)
ToggleAimbot.Font = Enum.Font.SourceSans
ToggleAimbot.Text = "Aimbot: ON"
ToggleAimbot.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleAimbot.TextSize = 14.000

ToggleESP.Name = "ToggleESP"
ToggleESP.Parent = MainFrame
ToggleESP.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
ToggleESP.Position = UDim2.new(0.05, 0, 0.65, 0)
ToggleESP.Size = UDim2.new(0.9, 0, 0, 30)
ToggleESP.Font = Enum.Font.SourceSans
ToggleESP.Text = "ESP Boxes: ON"
ToggleESP.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleESP.TextSize = 14.000

-- Button Behaviors
ToggleAimbot.MouseButton1Click:Connect(function()
    getgenv().AimbotEnabled = not getgenv().AimbotEnabled
    if getgenv().AimbotEnabled then
        ToggleAimbot.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
        ToggleAimbot.Text = "Aimbot: ON"
    else
        ToggleAimbot.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        ToggleAimbot.Text = "Aimbot: OFF"
    end
end)

ToggleESP.MouseButton1Click:Connect(function()
    getgenv().ESPBoxesEnabled = not getgenv().ESPBoxesEnabled
    if getgenv().ESPBoxesEnabled then
        ToggleESP.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
        ToggleESP.Text = "ESP Boxes: ON"
    else
        ToggleESP.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        ToggleESP.Text = "ESP Boxes: OFF"
    end
end)

-- 5. Core ESP Drawing Functionality
local function ApplyESP(player)
    if player == LocalPlayer then return end

    local function CreateESP()
        local Box = Drawing.new("Square")
        Box.Visible = false
        Box.Color = Color3.fromRGB(0, 255, 100)
        Box.Thickness = 2
        Box.Filled = false

        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            if not player or not player.Parent or not getgenv().ESPBoxesEnabled then
                Box.Visible = false
                if not player.Parent then Connection:Disconnect() Box:Remove() end
                return
            end

            local Character = player.Character
            local HumRoot = Character and Character:FindFirstChild("HumanoidRootPart")
            
            if HumRoot then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HumRoot.Position)
                if OnScreen then
                    local CamDist = (Camera.CFrame.p - HumRoot.Position).Magnitude
                    local SizeX = math.clamp(2000 / CamDist, 10, 150)
                    local SizeY = math.clamp(3000 / CamDist, 15, 200)

                    Box.Size = Vector2.new(SizeX, SizeY)
                    Box.Position = Vector2.new(ScreenPos.X - SizeX / 2, ScreenPos.Y - SizeY / 2)
                    Box.Visible = true
                else
                    Box.Visible = false
                end
            else
                Box.Visible = false
            end
        end)
    end
    
    if player.Character then CreateESP() end
    player.CharacterAdded:Connect(CreateESP)
end

for _, p in ipairs(Players:GetPlayers()) do ApplyESP(p) end
Players.PlayerAdded:Connect(ApplyESP)

-- 6. Core Aimbot Engine
local function GetClosestTarget()
    local ClosestDist = math.huge
    local Target = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local HumRoot = player.Character.HumanoidRootPart
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HumRoot.Position)
            
            if OnScreen then
                local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - ScreenCenter).Magnitude
                
                if Dist < ClosestDist then
                    ClosestDist = Dist
                    Target = HumRoot
                end
            end
        end
    end
    return Target
end

RunService.RenderStepped:Connect(function()
    if not getgenv().AimbotEnabled then return end
    local Target = GetClosestTarget()
    if Target then
        Camera.CFrame = CFrame.new(Camera.CFrame.p, Target.Position)
    end
end)

print("[Delta Rivals Hub] System injected successfully!")
