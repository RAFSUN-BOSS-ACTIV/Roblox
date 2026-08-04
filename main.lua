-- ==============================================================================
-- LULLABY v16.2 - ITEM IMMUNITY, GOD MODE, & GHOST INVISIBILITY
-- ==============================================================================
print("⏳ [Lullaby] Initializing Engine v16.2...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

_G.LullabyRegistry = _G.LullabyRegistry or {} 
_G.DebugButtons = _G.DebugButtons or {} 
_G.RefreshUILists = _G.RefreshUILists or function() end 

-- ==============================================================================
-- 1. COMPACT & FRIENDLY NATIVE UI
-- ==============================================================================
local safeGuiParent = (gethui and gethui()) or game:GetService("CoreGui")
if not pcall(function() local _ = safeGuiParent.Name end) then
    safeGuiParent = LocalPlayer:WaitForChild("PlayerGui")
end

local LullabyUI = Instance.new("ScreenGui")
LullabyUI.Name = "LullabyNativeUI_16_2"
LullabyUI.ResetOnSpawn = false
LullabyUI.Parent = safeGuiParent

local routerBtn = Instance.new("TextButton", LullabyUI)
routerBtn.Size = UDim2.new(0, 45, 0, 45)
routerBtn.Position = UDim2.new(0.9, -10, 0.1, 0)
routerBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
routerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
routerBtn.Text = "⚡"
routerBtn.TextSize = 20
routerBtn.Active = true
routerBtn.Draggable = true 
Instance.new("UICorner", routerBtn).CornerRadius = UDim.new(1, 0)

local function CreateWindow(titleText, size, position)
    local frame = Instance.new("Frame", LullabyUI)
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.Active = true
    frame.Draggable = true
    frame.Visible = false
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = " " .. titleText
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(1, 0, 0, 2)
    line.Position = UDim2.new(0, 0, 0, 30)
    line.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    line.BorderSizePixel = 0

    local container = Instance.new("ScrollingFrame", frame)
    container.Size = UDim2.new(1, -10, 1, -35)
    container.Position = UDim2.new(0, 5, 0, 35)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", container)
    layout.Padding = UDim.new(0, 4)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    return frame, container
end

local MainMenu, MainContainer = CreateWindow("⚙️ Visuals & Magic", UDim2.new(0, 180, 0, 320), UDim2.new(0.5, -285, 0.5, -160))
local PlayerWindow, PlayerContainer = CreateWindow("👤 Players & MCP", UDim2.new(0, 180, 0, 320), UDim2.new(0.5, -95, 0.5, -160))
local EntityWindow, EntityContainer = CreateWindow("📦 Items & Objects", UDim2.new(0, 180, 0, 320), UDim2.new(0.5, 95, 0.5, -160))

routerBtn.MouseButton1Click:Connect(function() 
    local state = not MainMenu.Visible
    MainMenu.Visible = state
    PlayerWindow.Visible = state
    EntityWindow.Visible = state
end)

local function CreateLabel(parent, text, color)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(150, 150, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
end

local function CreateToggle(parent, title, default, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.Text = " " .. title
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(1, -18, 0.5, -6)
    indicator.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        indicator.BackgroundColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        callback(state)
    end)
end

local function CreateButton(parent, title, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = color
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateSlider(parent, title, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title .. ": " .. tostring(default)
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local slideBg = Instance.new("TextButton", frame)
    slideBg.Size = UDim2.new(1, -10, 0, 15)
    slideBg.Position = UDim2.new(0, 5, 0, 20)
    slideBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    slideBg.Text = ""
    Instance.new("UICorner", slideBg).CornerRadius = UDim.new(1, 0)

    local slideFill = Instance.new("Frame", slideBg)
    local pct = (default - min) / (max - min)
    slideFill.Size = UDim2.new(pct, 0, 1, 0)
    slideFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    Instance.new("UICorner", slideFill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    slideBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local inputPos = input.Position.X
            local slidePos = slideBg.AbsolutePosition.X
            local slideSize = slideBg.AbsoluteSize.X
            local newPct = math.clamp((inputPos - slidePos) / slideSize, 0, 1)
            slideFill.Size = UDim2.new(newPct, 0, 1, 0)
            local val = math.floor(min + (newPct * (max - min)))
            lbl.Text = title .. ": " .. tostring(val)
            callback(val)
        end
    end)
end

-- ==============================================================================
-- 2. CONFIGURATION & SETTINGS
-- ==============================================================================
local Visuals = { MasterPlayerESP = true, Name = true, Tracers = false, Radar = false }
local Colors = { ESP = Color3.fromRGB(0, 255, 0), MCP = Color3.fromRGB(255, 0, 0), Item = Color3.fromRGB(255, 150, 0) }
local AimConfig = { Enabled = false, TargetPlayers = true, TargetMCP = false, Smoothness = 0.5, FOV_Size = 150 }
local MagicConfig = { Speed = 0, Jump = 50, AirJump = false, ClickTP = false, GodMode = false, ItemImmunity = false, Invisibility = false }

CreateLabel(MainContainer, "— Visual Elements —")
CreateToggle(MainContainer, "Master Player ESP", true, function(v) Visuals.MasterPlayerESP = v end)
CreateToggle(MainContainer, "Show Names", true, function(v) Visuals.Name = v end)
CreateToggle(MainContainer, "Show Tracers", false, function(v) Visuals.Tracers = v end)
CreateToggle(MainContainer, "Interactive 2D Radar", false, function(v) 
    Visuals.Radar = v 
    RadarFrame.Visible = v
end)

CreateLabel(MainContainer, "— Aimbot —")
CreateToggle(MainContainer, "Enable Aimbot", false, function(v) AimConfig.Enabled = v end)
CreateSlider(MainContainer, "Aim Smoothing", 1, 100, 50, function(v) AimConfig.Smoothness = v / 100 end)

CreateLabel(MainContainer, "— Magic & Exploits —")
CreateToggle(MainContainer, "God Mode (NonTarget Evasion)", false, function(v) 
    MagicConfig.GodMode = v 
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Name = v and "NonTarget" or "Humanoid" end
    end
end)
CreateToggle(MainContainer, "Item Immunity (No Harm)", false, function(v) MagicConfig.ItemImmunity = v end)
CreateToggle(MainContainer, "Ghost Invisibility", false, function(v) 
    MagicConfig.Invisibility = v 
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if v and char and root then
        -- Teleport away real body, leave ghost camera subject
        root.CFrame = CFrame.new(0, 999999, 0)
    elseif not v and char then
        -- Respawn / Reset position if turned off
        LocalPlayer:LoadCharacter()
    end
end)
CreateToggle(MainContainer, "Click to Teleport (Tool)", false, function(v) 
    MagicConfig.ClickTP = v 
    if v then
        local tpTool = Instance.new("Tool")
        tpTool.Name = "✨ Teleport"
        tpTool.RequiresHandle = false
        tpTool.Parent = LocalPlayer.Backpack
        tpTool.Activated:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    else
        local tpTool = LocalPlayer.Backpack:FindFirstChild("✨ Teleport") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("✨ Teleport"))
        if tpTool then tpTool:Destroy() end
    end
end)
CreateToggle(MainContainer, "Air Jump", false, function(v) MagicConfig.AirJump = v end)
CreateSlider(MainContainer, "Speed Boost", 0, 100, 0, function(v) MagicConfig.Speed = (v/100)*1.5 end)

-- ==============================================================================
-- 3. MOVABLE & STABLE 2D RADAR UI
-- ==============================================================================
local RadarFrame = Instance.new("Frame", LullabyUI)
RadarFrame.Size = UDim2.new(0, 150, 0, 150)
RadarFrame.Position = UDim2.new(0, 10, 0.5, -75)
RadarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
RadarFrame.BackgroundTransparency = 0.3
RadarFrame.Visible = false
RadarFrame.Active = true
RadarFrame.Draggable = true 
Instance.new("UICorner", RadarFrame).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", RadarFrame).Color = Color3.fromRGB(100, 100, 100)

local RadarCenter = Instance.new("Frame", RadarFrame)
RadarCenter.Size = UDim2.new(0, 4, 0, 4)
RadarCenter.Position = UDim2.new(0.5, -2, 0.5, -2)
RadarCenter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", RadarCenter).CornerRadius = UDim.new(1, 0)

-- ==============================================================================
-- 4. GROUPED NAME REGISTRY SYSTEM
-- ==============================================================================
local allPlayersEnabled = true
CreateButton(PlayerContainer, "Toggle All Players", Color3.fromRGB(50, 100, 200), function()
    allPlayersEnabled = not allPlayersEnabled
    for name, data in pairs(_G.LullabyRegistry) do
        if data.IsPlayer then
            data.State = allPlayersEnabled and "ESP" or "None"
            if _G.DebugButtons[name] then
                _G.DebugButtons[name].BackgroundColor3 = (data.State == "ESP") and Colors.ESP or Color3.fromRGB(35, 35, 40)
            end
        end
    end
end)

local StateColors = {
    None = Color3.fromRGB(35, 35, 40),
    ESP = Color3.fromRGB(0, 150, 50),
    MCP = Color3.fromRGB(200, 50, 50),
    Item = Color3.fromRGB(255, 150, 0)
}
local NextEntityState = { None = "Item", Item = "MCP", MCP = "None" }

_G.RefreshUILists = function()
    for _, child in ipairs(PlayerContainer:GetChildren()) do if not child:IsA("UIListLayout") and child.Text ~= "Toggle All Players" then child:Destroy() end end
    for _, child in ipairs(EntityContainer:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
    _G.DebugButtons = {} 
    
    for name, data in pairs(_G.LullabyRegistry) do
        local targetContainer = data.IsPlayer and PlayerContainer or EntityContainer

        local btn = Instance.new("TextButton", targetContainer)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = StateColors[data.State]
        btn.Text = name .. " (" .. #data.Instances .. ")"
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            if data.IsPlayer then
                data.State = (data.State == "ESP") and "None" or "ESP"
            else
                data.State = NextEntityState[data.State]
            end
            btn.BackgroundColor3 = StateColors[data.State]
        end)
        
        _G.DebugButtons[name] = btn 
    end
end

local function registerEntity(obj, forceState, isPlayer)
    if not obj or obj == LocalPlayer.Character then return end
    local name = obj.Name

    if not _G.LullabyRegistry[name] then
        _G.LullabyRegistry[name] = {
            DisplayName = name,
            State = forceState or "None",
            Instances = {},
            IsPlayer = isPlayer
        }
        _G.RefreshUILists()
    end

    local entry = _G.LullabyRegistry[name]
    local exists = false
    for _, inst in ipairs(entry.Instances) do if inst == obj then exists = true end end
    if not exists then table.insert(entry.Instances, obj) end
end

-- ==============================================================================
-- 5. AGGRESSIVE WORKSPACE SCANNER & EXPLOIT LOOPS
-- ==============================================================================
task.spawn(function()
    while true do
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then registerEntity(p.Character, "ESP", true) end
        end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj == LocalPlayer.Character or obj:IsDescendantOf(LocalPlayer.Character) then continue end
            
            local isEntity = false
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then isEntity = true end
            if obj:IsA("BasePart") and (obj:FindFirstChildOfClass("TouchTransmitter") or obj:FindFirstChildOfClass("ProximityPrompt")) then isEntity = true end
            
            if isEntity then
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do if p.Character == obj then isPlayer = true end end
                if not isPlayer then registerEntity(obj, "None", false) end
            end
        end
        task.wait(1)
    end
end)

-- Item Immunity & God Mode Background Executor
RunService.Heartbeat:Connect(function()
    -- Item Immunity Loop: Disables touch damage on all items set to "Item" state
    if MagicConfig.ItemImmunity then
        for name, data in pairs(_G.LullabyRegistry) do
            if data.State == "Item" then
                for _, inst in ipairs(data.Instances) do
                    if inst and inst.Parent then
                        for _, desc in ipairs(inst:GetDescendants()) do
                            if desc:IsA("BasePart") then desc.CanTouch = false end
                        end
                        if inst:IsA("BasePart") then inst.CanTouch = false end
                    end
                end
            end
        end
    end
end)

-- ==============================================================================
-- 6. RENDER & RADAR ENGINE (WITH FLOATING NAMES)
-- ==============================================================================
local renderGui = Instance.new("ScreenGui", safeGuiParent)
renderGui.Name = "LullabyRender"
local RadarBlips = {}

local function drawLine(frame, p1, p2, color, thickness)
    local center = (p1 + p2) / 2
    local vector = p2 - p1
    frame.Position = UDim2.new(0, center.X, 0, center.Y)
    frame.Size = UDim2.new(0, vector.Magnitude, 0, thickness or 2)
    frame.Rotation = math.deg(math.atan2(vector.Y, vector.X))
    frame.BackgroundColor3 = color
    frame.Visible = true
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    
    if myRoot then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if MagicConfig.Speed > 0 and hum and hum.MoveDirection.Magnitude > 0 then
            myRoot.CFrame = myRoot.CFrame + (hum.MoveDirection * MagicConfig.Speed)
        end
    end

    for _, frame in ipairs(renderGui:GetChildren()) do frame.Visible = false end
    for _, blip in ipairs(RadarBlips) do blip.Visible = false end
    RadarFrame.Visible = Visuals.Radar
    
    local lineIndex = 1
    local blipIndex = 1
    
    local function getLine()
        local frame = renderGui:GetChildren()[lineIndex]
        if not frame then
            frame = Instance.new("Frame", renderGui)
            frame.AnchorPoint = Vector2.new(0.5, 0.5)
            frame.BorderSizePixel = 0
        end
        lineIndex = lineIndex + 1
        return frame
    end
    
    local function getBlip()
        local blip = RadarBlips[blipIndex]
        if not blip then
            blip = Instance.new("Frame", RadarFrame)
            blip.Size = UDim2.new(0, 4, 0, 4)
            Instance.new("UICorner", blip).CornerRadius = UDim.new(1, 0)
            table.insert(RadarBlips, blip)
        end
        blipIndex = blipIndex + 1
        return blip
    end

    local closestTarget, shortestDistance = nil, AimConfig.FOV_Size
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)

    for name, data in pairs(_G.LullabyRegistry) do
        local isVisible = (data.State ~= "None")
        if data.IsPlayer and not Visuals.MasterPlayerESP then isVisible = false end
        local color = StateColors[data.State]

        for i = #data.Instances, 1, -1 do
            local inst = data.Instances[i]
            if not inst or not inst.Parent then 
                table.remove(data.Instances, i) 
            else
                local hl = inst:FindFirstChild("LullabyHighlight")
                local bb = inst:FindFirstChild("LullabyBillboard")
                
                if isVisible then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "LullabyHighlight"
                        hl.Adornee = inst
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0.2
                        pcall(function() hl.Parent = inst end)
                    end
                    hl.Enabled = true
                    hl.FillColor = color
                    hl.OutlineColor = color

                    if Visuals.Name then
                        if not bb then
                            bb = Instance.new("BillboardGui")
                            bb.Name = "LullabyBillboard"
                            bb.Size = UDim2.new(0, 200, 0, 40)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = inst:IsA("Model") and (inst:FindFirstChild("Head") or inst.PrimaryPart) or inst
                            
                            local lbl = Instance.new("TextLabel", bb)
                            lbl.Name = "Label"
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextStrokeTransparency = 0.2
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 12
                            pcall(function() bb.Parent = inst end)
                        end
                        bb.Enabled = true
                        local lbl = bb:FindFirstChild("Label")
                        if lbl then
                            lbl.Text = name
                            lbl.TextColor3 = color
                        end
                    else
                        if bb then bb.Enabled = false end
                    end
                else
                    if hl then hl.Enabled = false end
                    if bb then bb.Enabled = false end
                end
            end
        end

        local hasActiveInstances = #data.Instances > 0

        if isVisible and hasActiveInstances then
            for _, inst in ipairs(data.Instances) do
                local root = inst:IsA("Model") and (inst:FindFirstChild("HumanoidRootPart") or inst.PrimaryPart) or (inst:IsA("BasePart") and inst)
                
                -- Radar blip logic with distance tracking
                if Visuals.Radar and myRoot and root then
                    local offset = root.Position - myRoot.Position
                    local radarRadius = 75
                    local scale = 1.5
                    local rx = offset.X / scale
                    local rz = offset.Z / scale

                    if (Vector2.new(rx, rz).Magnitude) <= radarRadius then
                        local blip = getBlip()
                        blip.Position = UDim2.new(0.5, rx - 2, 0.5, rz - 2)
                        local blipColor = data.IsPlayer and Color3.fromRGB(0, 255, 0) or (data.State == "MCP" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 150, 0))
                        blip.BackgroundColor3 = blipColor
                        blip.Visible = true
                    end
                end

                if root then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        if Visuals.Tracers then
                            local origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) 
                            drawLine(getLine(), origin, Vector2.new(screenPos.X, screenPos.Y), color, 1.5)
                        end

                        if AimConfig.Enabled and data.State == "MCP" then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestTarget = root
                            end
                        end
                    end
                end
            end
        end
    end

    if AimConfig.Enabled and closestTarget and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closestTarget.Position), AimConfig.Smoothness)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if MagicConfig.AirJump then
        local char = LocalPlayer.Character
        local hum = char and (char:FindFirstChildOfClass("Humanoid"))
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if MagicConfig.GodMode then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Name = "NonTarget" end
    end
end)

MainMenu.Visible = true
PlayerWindow.Visible = true
EntityWindow.Visible = true
print("🚀 [Lullaby] v16.2 Ultimate Executed Successfully!")
