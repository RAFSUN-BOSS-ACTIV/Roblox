local GodModeModule = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function GodModeModule:Init(Tab)
    Tab:Section({ Title = "Bot/Entity Exploits" })
    local godModeEnabled = false

    Tab:Toggle({
        Title = "God Mode (Bots Cannot See/Harm You)",
        Value = false,
        Callback = function(v)
            godModeEnabled = v
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid") or char and char:FindFirstChild("NonTarget")
            
            if v and hum and hum.Name == "Humanoid" then
                hum.Name = "NonTarget"
            elseif not v and hum and hum.Name == "NonTarget" then
                hum.Name = "Humanoid"
            end
        end
    })

    RunService.Heartbeat:Connect(function()
        if godModeEnabled then
            for name, data in pairs(_G.LullabyRegistry) do
                if data.State == "MCP" then
                    for _, inst in ipairs(data.Instances) do
                        if inst.Parent then
                            for _, child in ipairs(inst:GetDescendants()) do
                                if child:IsA("BasePart") then child.CanTouch = false end
                            end
                        end
                    end
                end
            end
        end
    end)
end

return GodModeModule
