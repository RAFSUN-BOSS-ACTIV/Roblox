local TrapImmunityModule = {}
local RunService = game:GetService("RunService")

function TrapImmunityModule:Init(Tab)
    Tab:Section({ Title = "Item/Trap Protection" })
    local immunityEnabled = false

    Tab:Toggle({
        Title = "Trap Immunity (No Damage/Triggers)",
        Value = false,
        Callback = function(v) immunityEnabled = v end
    })

    RunService.Heartbeat:Connect(function()
        if immunityEnabled then
            for name, data in pairs(_G.LullabyRegistry) do
                if data.State == "Item" then
                    for _, inst in ipairs(data.Instances) do
                        if inst.Parent then
                            for _, child in ipairs(inst:GetDescendants()) do
                                if child:IsA("BasePart") then 
                                    child.CanTouch = false 
                                elseif child:IsA("TouchTransmitter") then
                                    child:Destroy()
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

return TrapImmunityModule
