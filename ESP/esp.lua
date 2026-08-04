local ESPModule = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local Visuals = { 
    Box = true, Name = true, Distance = true, Health = true, 
    Skeleton = false, Line = false, LineOrigin = "Bottom" 
}
local Colors = {
    ESP = Color3.fromRGB(0, 150, 255), 
    MCP = Color3.fromRGB(255, 0, 0),   
    Item = Color3.fromRGB(255, 150, 0) 
}

local renderGui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
renderGui.Name = "LullabyRender"

local function drawLine(frame, p1, p2, color, thickness)
    local center = (p1 + p2) / 2
    local vector = p2 - p1
    frame.Position = UDim2.new(0, center.X, 0, center.Y)
    frame.Size = UDim2.new(0, vector.Magnitude, 0, thickness or 2)
    frame.Rotation = math.deg(math.atan2(vector.Y, vector.X))
    frame.BackgroundColor3 = color
    frame.Visible = true
end

local function createLineInstance()
    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BorderSizePixel = 0
    frame.Parent = renderGui
    return frame
end

local function registerEntity(obj)
    if not obj or not obj.Name then return end
    if obj == Players.LocalPlayer.Character then return end
    
    if not _G.LullabyRegistry[obj.Name] then
        _G.LullabyRegistry[obj.Name] = { State = "None", Instances = {} }
        _G.RefreshUILists()
    end
    table.insert(_G.LullabyRegistry[obj.Name].Instances, obj)
end

function ESPModule:Init(Tab)
    Tab:Section({ Title = "Visual Elements" })
    
    Tab:Toggle({ Title = "Show Boxes & Glow", Value = true, Callback = function(v) Visuals.Box = v end })
    Tab:Toggle({ Title = "Show Names", Value = true, Callback = function(v) Visuals.Name = v end })
    Tab:Toggle({ Title = "Show Health Bars", Value = true, Callback = function(v) Visuals.Health = v end })
    Tab:Toggle({ Title = "Show Distance", Value = true, Callback = function(v) Visuals.Distance = v end })
    Tab:Toggle({ Title = "Show Skeletons", Value = false, Callback = function(v) Visuals.Skeleton = v end })
    Tab:Toggle({ Title = "Show Tracers (Draw Lines)", Value = false, Callback = function(v) Visuals.Line = v end })
    
    Tab:Dropdown({
        Title = "Tracer Origin", Values = {"Bottom", "Top", "Center"}, Value = "Bottom",
        Callback = function(opt) Visuals.LineOrigin = opt end
    })

    -- Smooth Async Workspace Scanner (Anti-Freeze)
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") or obj:IsA("BasePart") then task.wait(0.2) registerEntity(obj) end
    end)
    
    task.spawn(function()
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then 
                registerEntity(obj) 
            end
            count = count + 1
            if count % 100 == 0 then task.wait() end -- Yields to prevent freezing
        end
    end)
    
    local bones = {"Head", "UpperTorso", "LowerTorso", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperLeg", "RightLowerLeg", "RightFoot", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"}
    local connections = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}
    }

    RunService.RenderStepped:Connect(function()
        for _, frame in ipairs(renderGui:GetChildren()) do frame.Visible = false end
        local lineIndex = 1
        local function getLine()
            local frame = renderGui:GetChildren()[lineIndex]
            if not frame then frame = createLineInstance() end
            lineIndex = lineIndex + 1
            return frame
        end

        for name, data in pairs(_G.LullabyRegistry) do
            local color = nil
            if data.State == "ESP" then color = Colors.ESP
            elseif data.State == "MCP" then color = Colors.MCP
            elseif data.State == "Item" then color = Colors.Item end
            
            for _, inst in ipairs(data.Instances) do
                if not inst.Parent then continue end
                
                local hl = inst:FindFirstChild("LullabyHighlight")
                if color and Visuals.Box then
                    if not hl then hl = Instance.new("Highlight", inst) hl.Name = "LullabyHighlight" hl.FillTransparency = 0.5 end
                    hl.Enabled = true hl.FillColor = color hl.OutlineColor = color
                else
                    if hl then hl.Enabled = false end
                end

                if color then
                    local root = inst:IsA("Model") and (inst:FindFirstChild("HumanoidRootPart") or inst.PrimaryPart) or inst
                    if not root then continue end
                    
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if not onScreen then continue end
                    
                    if Visuals.Line then
                        local origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) 
                        if Visuals.LineOrigin == "Top" then origin = Vector2.new(Camera.ViewportSize.X/2, 0)
                        elseif Visuals.LineOrigin == "Center" then origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) end
                        drawLine(getLine(), origin, Vector2.new(screenPos.X, screenPos.Y), color, 1.5)
                    end

                    if Visuals.Skeleton and inst:IsA("Model") then
                        for _, conn in ipairs(connections) do
                            local p1 = inst:FindFirstChild(conn[1])
                            local p2 = inst:FindFirstChild(conn[2])
                            if p1 and p2 then
                                local s1, on1 = Camera:WorldToViewportPoint(p1.Position)
                                local s2, on2 = Camera:WorldToViewportPoint(p2.Position)
                                if on1 and on2 then drawLine(getLine(), Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y), color, 1.5) end
                            end
                        end
                    end
                end
            end
        end
    end)
end

return ESPModule
