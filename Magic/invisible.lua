local InvisibleModule = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local isInvisible = false
local invisibleClone = nil

function InvisibleModule:Init(Tab)
    Tab:Section({ Title = "Invisibility (Ghost Mode)" })
    
    Tab:Toggle({
        Title = "Enable Invisibility",
        Value = false,
        Callback = function(Value)
            isInvisible = Value
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if isInvisible and char and root then
                local oldCFrame = root.CFrame
                invisibleClone = Instance.new("Part")
                invisibleClone.Name = "FakeRoot"
                invisibleClone.Size = root.Size
                invisibleClone.CFrame = oldCFrame
                invisibleClone.Anchored = true
                invisibleClone.Transparency = 1
                invisibleClone.Parent = workspace
                
                root.CFrame = CFrame.new(0, 999999, 0)
                workspace.CurrentCamera.CameraSubject = invisibleClone
            else
                if invisibleClone then
                    if root then root.CFrame = invisibleClone.CFrame end
                    invisibleClone:Destroy()
                    invisibleClone = nil
                end
                if char then workspace.CurrentCamera.CameraSubject = char:FindFirstChild("Humanoid") end
            end
        end
    })
end

return InvisibleModule
