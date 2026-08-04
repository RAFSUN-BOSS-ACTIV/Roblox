local TeleportModule = {}
local Players = game:GetService("Players")

function TeleportModule:Init(Tab)
    Tab:Section({ Title = "Waypoint System" })
    
    local savedLocations = {}
    local currentInput = "New Waypoint"
    local selectedWaypoint = nil
    
    Tab:Input({ Title = "Waypoint Name", PlaceholderText = "Enter name...", Callback = function(t) currentInput = t end })
    
    local drop = Tab:Dropdown({ Title = "Saved Locations", Values = {"None"}, Value = "None", Callback = function(o) selectedWaypoint = o end })
    
    local function refresh()
        local list = {}
        for k,_ in pairs(savedLocations) do table.insert(list, k) end
        if #list == 0 then table.insert(list, "None") end
        drop:Refresh(list)
    end
    
    Tab:Button({ Title = "Save Current Position", Callback = function()
        local root = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            savedLocations[currentInput] = root.CFrame
            refresh()
        end
    end})
    
    Tab:Button({ Title = "Travel", Callback = function()
        local root = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and selectedWaypoint and savedLocations[selectedWaypoint] then
            root.CFrame = savedLocations[selectedWaypoint]
        end
    end})
    
    Tab:Button({ Title = "Delete Selected", Callback = function()
        if selectedWaypoint and savedLocations[selectedWaypoint] then
            savedLocations[selectedWaypoint] = nil
            selectedWaypoint = nil
            refresh()
        end
    end})
end

return TeleportModule
