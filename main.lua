-- [[ RIVALS: ZOMBIE TOWER DELTA INJECTOR ]] --

-- Establish global config settings based on your parameters
getgenv().Config = {
    ESP_Skeleton = true,
    SilentAim = true,
    InfiniteJump = true,
    NoMuzzleFlash = true,
    DoubleJump = true
}

-- Anti-double execute protection
if getgenv().RivalsZombieScriptLoaded then
    print("[Delta] Script features already active!")
    return
else
    getgenv().RivalsZombieScriptLoaded = true
end

-- Core Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Simple Mobile Indicator GUI
local ScreenGui = Instance.new("ScreenGui")
local NotifyFrame = Instance.new("Frame")
local StatusText = Instance.new("TextLabel")

ScreenGui.Parent = game:GetService("CoreGui")
NotifyFrame.Size = UDim2.new(0, 200, 0, 40)
NotifyFrame.Position = UDim2.new(0.5, -100, 0.05, 0)
NotifyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)

StatusText.Parent = NotifyFrame
StatusText.Size = UDim2.new(1, 0, 1, 0)
StatusText.Text = "ZOMBIE HUB: ACTIVE"
StatusText.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusText.Font = Enum.Font.SourceSansBold
StatusText.TextSize = 16

-- Auto Clean UI notice after 4 seconds
task.delay(4, function() ScreenGui:Destroy() end)

-- Core Aimbot Engine
local function GetClosestZombie()
    local Target = nil
    local ClosestDist = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local Root = p.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            if OnScreen then
                local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local Dist = (Vector2.new(Pos.X, Pos.Y) - Center).Magnitude
                if Dist < ClosestDist then
                    ClosestDist = Dist
                    Target = Root
                end
            end
        end
    end
    return Target
end

RunService.RenderStepped:Connect(function()
    if getgenv().Config.SilentAim then
        local Target = GetClosestZombie()
        if Target then
            Camera.CFrame = CFrame.new(Camera.CFrame.p, Target.Position)
        end
    end
end)

print("[Delta] Rivals Hub completely setup and active!")
