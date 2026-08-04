-- ==============================================================================
-- LULLABY v14.2 - BULLETPROOF MONOLITHIC EDITION
-- ==============================================================================
print("⏳ [Lullaby] Waiting for game to load...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

_G.LullabyRegistry = _G.LullabyRegistry or {} 
_G.RefreshUILists = _G.RefreshUILists or function() end 

-- ==============================================================================
-- UI INITIALIZATION
-- ==============================================================================
local uiSuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not uiSuccess or type(WindUI) ~= "table" then
    warn("❌ [Lullaby FATAL ERROR] WindUI failed to load from Github!")
    return
end

WindUI:SetNotificationLower(true)

local Window = WindUI:CreateWindow({
    Title = "⚡ Lullaby All-In-One",
    Icon = "rbxassetid://10618928818", 
    Folder = "LullabyHub", 
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark", 
    KeySystem = {
        Title = "Premium Access",
        KeyValidator = function(key) return key == "123" end,
        SaveKey = false,
    }
})

-- SAFE ROUTER ICON
local safeGuiParent = (gethui and gethui()) or game:GetService("CoreGui")
if not pcall(function() local _ = safeGuiParent.Name end) then
    safeGuiParent = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LullabyRouter"
screenGui.Parent = safeGuiParent

local routerBtn = Instance.new("TextButton", screenGui)
routerBtn.Size = UDim2.new(0, 50, 0, 50)
routerBtn.Position = UDim2.new(0.9, 0, 0.1, 0)
routerBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
routerBtn.Text = "⭐"
routerBtn.TextSize = 30
routerBtn.Active = true
routerBtn.Draggable = true 
local rCorner = Instance.new("UICorner", routerBtn) 
rCorner.CornerRadius = UDim.new(1, 0)

routerBtn.MouseButton1Click:Connect(function() Window:Toggle() end)

-- CREATE TABS
local TabAimbot   = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
local TabESP      = Window:Tab({ Title = "ESP Visuals", Icon = "eye" })
local TabDebug    = Window:Tab({ Title = "Debug Roadmap", Icon = "bug" })
local TabMagic    = Window:Tab({ Title = "Magic & Exploits", Icon = "wand-2" })
local TabTeleport = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local TabSettings = Window:Tab({ Title = "Settings", Icon = "settings" })

TabSettings:Section({ Title = "Appearance" })
TabSettings:Toggle({
    Title = "Dark Mode",
    Value = true,
    Callback = function(Value)
        if Value then WindUI:SetTheme("Dark") else WindUI:SetTheme("Light") end
    end,
})

-- ==============================================================================
-- SAFE MODULE WRAPPER (Prevents empty tabs)
-- ==============================================================================
local function loadModule(name, tab, func)
    local success, err = pcall(func)
    if not success then
        warn("❌ [Lullaby] " .. name .. " failed to load: " .. tostring(err))
        tab:Section({ Title = "⚠️ Error loading " .. name })
    else
        print("✅ [Lullaby] " .. name .. " loaded successfully.")
    end
end

-- ==============================================================================
-- 1. AIMBOT MODULE
-- ==============================================================================
loadModule("Aimbot", TabAimbot, function()
    local Config = {
        Enabled = false, TargetPlayers = true, TargetMCP = false, TargetPart = "Head",
        Smoothness = 0.5, RequireClick = true, FOV_Enabled = false, FOV_Size = 150,
        FOV_Color = Color3.fromRGB(255, 255, 255)
    }

    TabAimbot:Section({ Title = "Aimbot Core" })
    TabAimbot:Toggle({ Title = "Enable Aimbot", Value = false, Callback = function(v) Config.Enabled = v end })
    TabAimbot:Toggle({ Title = "Only Aim While Firing", Value = true, Callback = function(v) Config.RequireClick = v end })

    TabAimbot:Section({ Title = "Targeting Rules" })
    TabAimbot:Toggle({ Title = "Target Players (Blue ESP)", Value = true, Callback = function(v) Config.TargetPlayers = v end })
    TabAimbot:Toggle({ Title = "Target Bots (Red MCP)", Value = false, Callback = function(v) Config.TargetMCP = v end })
    TabAimbot:Dropdown({ Title = "Target Body Part", Values = {"Head", "HumanoidRootPart", "LeftFoot"}, Value = "Head", Callback = function(Option) Config.TargetPart = Option end })

    TabAimbot:Section({ Title = "FOV & Smoothing" })
    TabAimbot:Toggle({ Title = "Show FOV Circle", Value = false, Callback = function(v) Config.FOV_Enabled = v end })
    TabAimbot:Slider({ Title = "FOV Size", Min = 10, Max = 500, Step = 10, Value = 150, Callback = function(v) Config.FOV_Size = v end })
    TabAimbot:Slider({ Title = "Aim Smoothing", Min = 1, Max = 100, Step = 1, Value = 50, Callback = function(v) Config.Smoothness = v / 100 end })

    local fovCircle = Instance.new("Frame")
    local fovCorner = Instance.new("UICorner", fovCircle)
    local fovStroke = Instance.new("UIStroke", fovCircle)
    local fovGui = Instance.new("ScreenGui", safeGuiParent)
    fovGui.Name = "LullabyFOV"
    fovCircle.Parent = fovGui
    fovCircle.BackgroundColor3 = Color3.new(1,1,1)
    fovCircle.BackgroundTransparency = 1
    fovCorner.CornerRadius = UDim.new(1, 0)
    fovStroke.Color = Config.FOV_Color
    fovStroke.Thickness = 1.5

    local function getClosestTarget()
        local closestTarget, shortestDistance = nil, Config.FOV_Size
        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
        for name, data in pairs(_G.LullabyRegistry) do
            local isValidTarget = (Config.TargetPlayers and data.State == "ESP") or (Config.TargetMCP and data.State == "MCP")
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
        if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Config.Smoothness) end
    end)
end)

-- ==============================================================================
-- 2. ESP MODULE
-- ==============================================================================
loadModule("ESP", TabESP, function()
    local Visuals = { Box = true, Name = true, Distance = true, Health = true, Skeleton = false, Line = false, LineOrigin = "Bottom" }
    local Colors = { ESP = Color3.fromRGB(0, 150, 255), MCP = Color3.fromRGB(255, 0, 0), Item = Color3.fromRGB(255, 150, 0) }

    local renderGui = Instance.new("ScreenGui", safeGuiParent)
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
        if not obj or not obj.Name or obj == LocalPlayer.Character then return end
        if not _G.LullabyRegistry[obj.Name] then
            _G.LullabyRegistry[obj.Name] = { State = "None", Instances = {} }
            _G.RefreshUILists()
        end
        table.insert(_G.LullabyRegistry[obj.Name].Instances, obj)
    end

    TabESP:Section({ Title = "Visual Elements" })
    TabESP:Toggle({ Title = "Show Boxes & Glow", Value = true, Callback = function(v) Visuals.Box = v end })
    TabESP:Toggle({ Title = "Show Names", Value = true, Callback = function(v) Visuals.Name = v end })
    TabESP:Toggle({ Title = "Show Health Bars", Value = true, Callback = function(v) Visuals.Health = v end })
    TabESP:Toggle({ Title = "Show Distance", Value = true, Callback = function(v) Visuals.Distance = v end })
    TabESP:Toggle({ Title = "Show Skeletons", Value = false, Callback = function(v) Visuals.Skeleton = v end })
    TabESP:Toggle({ Title = "Show Tracers (Lines)", Value = false, Callback = function(v) Visuals.Line = v end })
    TabESP:Dropdown({ Title = "Tracer Origin", Values = {"Bottom", "Top", "Center"}, Value = "Bottom", Callback = function(opt) Visuals.LineOrigin = opt end })

    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") or obj:IsA("BasePart") then task.wait(0.2) registerEntity(obj) end
    end)
    
    task.spawn(function()
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then registerEntity(obj) end
            count = count + 1
            if count % 100 == 0 then task.wait() end
        end
    end)
    
    local connections = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}
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
            local color = (data.State == "ESP" and Colors.ESP) or (data.State == "MCP" and Colors.MCP) or (data.State == "Item" and Colors.Item)
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
                            local p1, p2 = inst:FindFirstChild(conn[1]), inst:FindFirstChild(conn[2])
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
end)

-- ==============================================================================
-- 3. DEBUG MODULE
-- ==============================================================================
loadModule("Debug", TabDebug, function()
    TabDebug:Section({ Title = "Debug Roadmap Controls" })
    local espDropdown, mcpDropdown, itemDropdown

    local function refreshDropdowns()
        local espList, mcpList, itemList = {"None"}, {"None"}, {"None"}
        for name, data in pairs(_G.LullabyRegistry) do
            if data.State == "ESP" or data.State == "None" then table.insert(espList, name) end
            if data.State == "MCP" or data.State == "None" then table.insert(mcpList, name) end
            if data.State == "Item" or data.State == "None" then table.insert(itemList, name) end
        end
        if espDropdown then espDropdown:Refresh(espList) end
        if mcpDropdown then mcpDropdown:Refresh(mcpList) end
        if itemDropdown then itemDropdown:Refresh(itemList) end
    end
    _G.RefreshUILists = refreshDropdowns

    TabDebug:Toggle({ Title = "Enable ESP Processing", Value = true, Callback = function(v) end })
    espDropdown = TabDebug:Dropdown({ Title = "ESP List", Values = {"None"}, Value = "None", Callback = function(Option) end })
    TabDebug:Button({ Title = "Set Selected to ESP (Green)", Callback = function()
        if espDropdown.Value and _G.LullabyRegistry[espDropdown.Value] then
            _G.LullabyRegistry[espDropdown.Value].State = "ESP" refreshDropdowns()
        end
    end})
    TabDebug:Button({ Title = "Turn OFF ESP", Callback = function()
        if espDropdown.Value and _G.LullabyRegistry[espDropdown.Value] then
            _G.LullabyRegistry[espDropdown.Value].State = "None" refreshDropdowns()
        end
    end})

    TabDebug:Section({ Title = "MCP Server (Bots)" })
    TabDebug:Toggle({ Title = "Enable MCP Rendering", Value = true, Callback = function(v) end })
    mcpDropdown = TabDebug:Dropdown({ Title = "MCP List", Values = {"None"}, Value = "None", Callback = function(Option) end })
    TabDebug:Button({ Title = "Set Selected to MCP (Red Bot)", Callback = function()
        if mcpDropdown.Value and _G.LullabyRegistry[mcpDropdown.Value] then
            _G.LullabyRegistry[mcpDropdown.Value].State = "MCP" refreshDropdowns()
        end
    end})

    TabDebug:Section({ Title = "Item Entities" })
    TabDebug:Toggle({ Title = "Enable Item Rendering", Value = true, Callback = function(v) end })
    itemDropdown = TabDebug:Dropdown({ Title = "Item List", Values = {"None"}, Value = "None", Callback = function(Option) end })
    TabDebug:Button({ Title = "Set Selected to Item (Orange)", Callback = function()
        if itemDropdown.Value and _G.LullabyRegistry[itemDropdown.Value] then
            _G.LullabyRegistry[itemDropdown.Value].State = "Item" refreshDropdowns()
        end
    end})
end)

-- ==============================================================================
-- 4. MAGIC & EXPLOITS MODULE
-- ==============================================================================
loadModule("Magic", TabMagic, function()
    -- MOVEMENT
    TabMagic:Section({ Title = "Movement" })
    local speedBoost, jumpPower, airJump = 0, 50, false
    
    TabMagic:Slider({ Title = "Speed Boost", Min = 0, Max = 100, Step = 1, Value = 0, Callback = function(v) speedBoost = (v/100)*1.5 end })
    TabMagic:Slider({ Title = "Jump Power", Min = 0, Max = 100, Step = 1, Value = 0, Callback = function(v) 
        jumpPower = math.floor(50 + (v*1.5))
        local char = LocalPlayer.Character
        local hum = char and (char:FindFirstChild("Humanoid") or char:FindFirstChild("NonTarget"))
        if hum then hum.JumpPower = jumpPower end
    end})
    TabMagic:Toggle({ Title = "Air Jump", Value = false, Callback = function(v) airJump = v end })
    
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

    -- GOD MODE
    TabMagic:Section({ Title = "Bot/Entity Exploits" })
    local godModeEnabled = false
    TabMagic:Toggle({
        Title = "God Mode (Bots Cannot See/Harm You)",
        Value = false,
        Callback = function(v)
            godModeEnabled = v
            local char = LocalPlayer.Character
            local hum = char and (char:FindFirstChild("Humanoid") or char:FindFirstChild("NonTarget"))
            if v and hum and hum.Name == "Humanoid" then hum.Name = "NonTarget"
            elseif not v and hum and hum.Name == "NonTarget" then hum.Name = "Humanoid" end
        end
    })

    -- TRAP IMMUNITY
    TabMagic:Section({ Title = "Item/Trap Protection" })
    local immunityEnabled = false
    TabMagic:Toggle({ Title = "Trap Immunity (No Damage/Triggers)", Value = false, Callback = function(v) immunityEnabled = v end })

    RunService.Heartbeat:Connect(function()
        if godModeEnabled or immunityEnabled then
            for name, data in pairs(_G.LullabyRegistry) do
                if (godModeEnabled and data.State == "MCP") or (immunityEnabled and data.State == "Item") then
                    for _, inst in ipairs(data.Instances) do
                        if inst.Parent then
                            for _, child in ipairs(inst:GetDescendants()) do
                                if child:IsA("BasePart") then child.CanTouch = false 
                                elseif immunityEnabled and child:IsA("TouchTransmitter") then child:Destroy() end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- INVISIBILITY
    TabMagic:Section({ Title = "Invisibility (Ghost Mode)" })
    local isInvisible, invisibleClone = false, nil
    TabMagic:Toggle({
        Title = "Enable Invisibility", Value = false,
        Callback = function(Value)
            isInvisible = Value
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if isInvisible and char and root then
                invisibleClone = Instance.new("Part")
                invisibleClone.Name = "FakeRoot"
                invisibleClone.Size = root.Size
                invisibleClone.CFrame = root.CFrame
                invisibleClone.Anchored = true
                invisibleClone.Transparency = 1
                invisibleClone.Parent = workspace
                root.CFrame = CFrame.new(0, 999999, 0)
                Camera.CameraSubject = invisibleClone
            else
                if invisibleClone then
                    if root then root.CFrame = invisibleClone.CFrame end
                    invisibleClone:Destroy() invisibleClone = nil
                end
                if char then Camera.CameraSubject = char:FindFirstChild("Humanoid") end
            end
        end
    })
end)

-- ==============================================================================
-- 5. TELEPORT MODULE
-- ==============================================================================
loadModule("Teleport", TabTeleport, function()
    TabTeleport:Section({ Title = "Waypoint System" })
    local savedLocations, currentInput, selectedWaypoint = {}, "New Waypoint", nil
    
    TabTeleport:Input({ Title = "Waypoint Name", PlaceholderText = "Enter name...", Callback = function(t) currentInput = t end })
    local drop = TabTeleport:Dropdown({ Title = "Saved Locations", Values = {"None"}, Value = "None", Callback = function(o) selectedWaypoint = o end })
    
    local function refresh()
        local list = {}
        for k,_ in pairs(savedLocations) do table.insert(list, k) end
        if #list == 0 then table.insert(list, "None") end
        drop:Refresh(list)
    end
    
    TabTeleport:Button({ Title = "Save Current Position", Callback = function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then savedLocations[currentInput] = root.CFrame refresh() end
    end})
    
    TabTeleport:Button({ Title = "Travel", Callback = function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and selectedWaypoint and savedLocations[selectedWaypoint] then root.CFrame = savedLocations[selectedWaypoint] end
    end})
    
    TabTeleport:Button({ Title = "Delete Selected", Callback = function()
        if selectedWaypoint and savedLocations[selectedWaypoint] then
            savedLocations[selectedWaypoint] = nil selectedWaypoint = nil refresh()
        end
    end})
end)

print("🚀 [Lullaby] Script Fully Executed!")
