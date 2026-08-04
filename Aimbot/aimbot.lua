local AimbotModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Config = {
    Enabled = false,
    TargetPlayers = true,
    TargetMCP = false,
    TargetPart = "Head",
    Smoothness = 0.5,
    RequireClick = true,
    FOV_Enabled = false,
    FOV_Size = 150,
    FOV_Color = Color3.fromRGB(255, 255, 255)
}

function AimbotModule:Init(Tab)
    Tab:Section({ Title = "Aimbot Core" })
    
    Tab:Toggle({
        Title = "Enable Aimbot",
        Value = false,
        Callback = function(v) Config.Enabled = v end
    })
    Tab:Toggle({
        Title = "Only Aim While Firing (Clicking)",
        Value = true,
        Callback = function(v) Config.RequireClick = v end
    })

    Tab:Section({ Title = "Targeting Rules" })
    Tab:Toggle({ Title = "Target Players (Blue ESP)", Value = true, Callback = function(v) Config.TargetPlayers = v end })
    Tab:Toggle({ Title = "Target Bots/Enemies (Red MCP)", Value = false, Callback = function(v) Config.TargetMCP = v end })
    
    Tab:Dropdown({
        Title = "Target Body Part",
        Values = {"Head", "HumanoidRootPart", "LeftFoot"},
        Value = "Head",
        Callback = function(Option) Config.TargetPart = Option end
    })

    Tab:Section({ Title = "FOV & Smoothing" })
    Tab:Toggle({ Title = "Show FOV Circle", Value = false, Callback = function(v) Config.FOV_Enabled = v end })
    Tab:Slider({ Title = "FOV Size", Min = 10, Max = 500, Step = 10, Value = 150, Callback = function(v) Config.FOV_Size = v end })
    Tab:Slider({ Title = "Smoothing (Aim Speed)", Min = 1, Max = 100, Step = 1, Value = 50, Callback = function(v) Config.Smoothness = v / 100 end })

    local fovCircle = Instance.new("Frame")
    local fovCorner = Instance.new("UICorner", fovCircle)
    local fovStroke = Instance.new("UIStroke", fovCircle)
    
    local fovGui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
    fovGui.Name = "LullabyFOV"
    fovCircle.Parent = fovGui
    fovCircle.BackgroundColor3 = Color3.new(1,1,1)
    fovCircle.BackgroundTransparency = 1
    fovCorner.CornerRadius = UDim.new(1, 0)
    fovStroke.Color = Config.FOV_Color
    fovStroke.Thickness = 1.5

    local function getClosestTarget()
        local closestTarget = nil
        local shortestDistance = Config.FOV_Size
        local mousePos = Vector2.new(Mouse.X, Mouse.Y)

        for name, data in pairs(_G.LullabyRegistry) do
            local isValidTarget = false
            if Config.TargetPlayers and data.State == "ESP" then isValidTarget = true end
            if Config.TargetMCP and data.State == "MCP" then isValidTarget = true end
            
            if isValidTarget then
                for _, inst in ipairs(data.Instances) do
                    local targetPart = inst:FindFirstChild(Config.TargetPart)
                    if targetPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
        return closestTarget
    end

    RunService.RenderStepped:Connect(function()
        fovCircle.Visible = Config.FOV_Enabled
        if Config.FOV_Enabled then
            fovCircle.Size = UDim2.new(0, Config.FOV_Size * 2, 0, Config.FOV_Size * 2)
            fovCircle.Position = UDim2.new(0, Mouse.X - Config.FOV_Size, 0, Mouse.Y - Config.FOV_Size)
        end

        if not Config.Enabled then return end
        if Config.RequireClick and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
        
        local target = getClosestTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Config.Smoothness)
        end
    end)
end

return AimbotModule
