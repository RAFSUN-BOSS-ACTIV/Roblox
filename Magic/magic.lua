local MagicModule = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

function MagicModule:Init(Tab)
    Tab:Section({ Title = "Movement" })
    
    local speedBoost = 0
    local jumpPower = 50
    local airJump = false
    
    Tab:Slider({ Title = "Speed Boost", Min = 0, Max = 100, Step = 1, Value = 0, Callback = function(v) speedBoost = (v/100)*1.5 end })
    
    Tab:Slider({ Title = "Jump Power", Min = 0, Max = 100, Step = 1, Value = 0, Callback = function(v) 
        jumpPower = math.floor(50 + (v*1.5))
        local char = LocalPlayer.Character
        local hum = char and (char:FindFirstChild("Humanoid") or char:FindFirstChild("NonTarget"))
        if hum then hum.JumpPower = jumpPower end
    end})
    
    Tab:Toggle({ Title = "Air Jump", Value = false, Callback = function(v) airJump = v end })
    
    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and (char:FindFirstChild("Humanoid") or char:FindFirstChild("NonTarget"))
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if speedBoost > 0 and hum and root and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * speedBoost)
        end
    end)
    
    UserInputService.JumpRequest:Connect(function()
        if airJump then
            local char = LocalPlayer.Character
            local hum = char and (char:FindFirstChild("Humanoid") or char:FindFirstChild("NonTarget"))
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end

return MagicModule
