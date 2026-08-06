-- ==============================================================================
-- LULLABY v17.2 - WINDUI PRO EDITION (ANDROID FIX)
-- ==============================================================================
print("⏳ [Lullaby] Initializing Engine v17.2 with WindUI...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

_G.LullabyRegistry = _G.LullabyRegistry or {} 

-- ==============================================================================
-- 1. LOAD WINDUI & CREATE WINDOW
-- ==============================================================================
-- FIXED: Using the exact correct release URL provided in the documentation
local success, WindUI = pcall(function()
    local _version = "1.6.66"
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))()
end)

if not success or not WindUI then
    warn("❌ [Lullaby] Failed to load WindUI. Please check your internet or executor.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "⚡ Lullaby Modular Hub v17.2",
    Icon = "zap",
    Author = "by Lullaby",
    Folder = "LullabyHub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 190,
    HideSearchBar = true,
    KeySystem = {
        Title = "Access Required",
        Note = "Enter the access key 'free' to continue.",
        KeyValidator = function(key)
            return key == "free"
        end,
        SaveKey = true,
        Thumbnail = {
            Image = "rbxassetid://10618928818",
            Title = "Free Access Key: free",
        }
    }
})

WindUI:Notify({
    Title = "Lullaby v17.2 Loaded",
    Content = "All features and WindUI injected successfully!",
    Icon = "check-circle",
    Duration = 5,
})

-- ==============================================================================
-- 2. CONFIGURATION & STATE
-- ==============================================================================
local ESPConfig = {
    Player = { Enabled = true, Glow = true, Name = true, Health = false, Box = false, Skeleton = false, Tracer = false },
    MCP = { Enabled = false, Glow = true, Name = true, Health = false, Box = false, Skeleton = false, Tracer = false },
    Item = { Enabled = false, Glow = true, Name = true }
}

local RadarConfig = { Enabled = false, ShowXYZ = true }
local Colors = { ESP = Color3.fromRGB(0, 255, 0), MCP = Color3.fromRGB(255, 0, 0), Item = Color3.fromRGB(255, 150, 0) }
local AimConfig = { Enabled = false, TargetPlayers = true, TargetMCP = false, Smoothness = 0.5, FOV_Size = 150 }
local MagicConfig = { Speed = 0, AirJump = false, ClickTP = false, GodMode = false, ItemImmunity = false, Invisibility = false, Fly = false, FlySpeed = 50, WallNoclip = false, UnlimitedItems = false, InstantCooldown = false, InfiniteEnergy = false, DebugEnabled = false }

-- ==============================================================================
-- 3. WINDUI TABS & SECTIONS
-- ==============================================================================
local TabVisuals = Window:Tab({ Title = "ESP & Visuals", Icon = "eye" })
local TabRadarAim = Window:Tab({ Title = "Radar & Aimbot", Icon = "crosshair" })
local TabMagic = Window:Tab({ Title = "Magic & Exploits", Icon = "wand-2" })
local TabEntity = Window:Tab({ Title = "Entity Manager", Icon = "package" })

-- --- VISUALS TAB: PLAYER ESP ---
local SecPlayerESP = TabVisuals:Section({ Title = "Player ESP", Icon = "user", Opened = true })
SecPlayerESP:Toggle({ Title = "Enable Player ESP", Value = true, Callback = function(v) ESPConfig.Player.Enabled = v end })
SecPlayerESP:Toggle({ Title = "Glow (Aura)", Value = true, Callback = function(v) ESPConfig.Player.Glow = v end })
SecPlayerESP:Toggle({ Title = "Show Name", Value = true, Callback = function(v) ESPConfig.Player.Name = v end })
SecPlayerESP:Toggle({ Title = "Show Health Bar", Value = false, Callback = function(v) ESPConfig.Player.Health = v end })
SecPlayerESP:Toggle({ Title = "Show 3D Box", Value = false, Callback = function(v) ESPConfig.Player.Box = v end })
SecPlayerESP:Toggle({ Title = "Show Skeleton", Value = false, Callback = function(v) ESPConfig.Player.Skeleton = v end })
SecPlayerESP:Toggle({ Title = "Show Tracers (Top Line)", Value = false, Callback = function(v) ESPConfig.Player.Tracer = v end })

-- --- VISUALS TAB: MCP BOT ESP ---
local SecMCPESP = TabVisuals:Section({ Title = "MCP Bot ESP", Icon = "bot", Opened = false })
SecMCPESP:Toggle({ Title = "Enable MCP ESP", Value = false, Callback = function(v) ESPConfig.MCP.Enabled = v end })
SecMCPESP:Toggle({ Title = "Glow (Aura)", Value = true, Callback = function(v) ESPConfig.MCP.Glow = v end })
SecMCPESP:Toggle({ Title = "Show Name", Value = true, Callback = function(v) ESPConfig.MCP.Name = v end })
SecMCPESP:Toggle({ Title = "Show Health Bar", Value = false, Callback = function(v) ESPConfig.MCP.Health = v end })
SecMCPESP:Toggle({ Title = "Show 3D Box", Value = false, Callback = function(v) ESPConfig.MCP.Box = v end })
SecMCPESP:Toggle({ Title = "Show Skeleton", Value = false, Callback = function(v) ESPConfig.MCP.Skeleton = v end })
SecMCPESP:Toggle({ Title = "Show Tracers (Top Line)", Value = false, Callback = function(v) ESPConfig.MCP.Tracer = v end })

-- --- VISUALS TAB: ITEM ESP ---
local SecItemESP = TabVisuals:Section({ Title = "Item ESP", Icon = "box", Opened = false })
SecItemESP:Toggle({ Title = "Enable Item ESP", Value = false, Callback = function(v) ESPConfig.Item.Enabled = v end })
SecItemESP:Toggle({ Title = "Glow (Aura)", Value = true, Callback = function(v) ESPConfig.Item.Glow = v end })
SecItemESP:Toggle({ Title = "Show Name", Value = true, Callback = function(v) ESPConfig.Item.Name = v end })

-- --- RADAR & AIMBOT TAB ---
local SecRadar = TabRadarAim:Section({ Title = "Interactive 2D Radar", Icon = "radar", Opened = true })
SecRadar:Toggle({ Title = "Show Radar Overlay", Value = false, Callback = function(v) RadarConfig.Enabled = v; _G.RadarFrame.Visible = v end })
SecRadar:Toggle({ Title = "Show Distance & XYZ on Blips", Value = true, Callback = function(v) RadarConfig.ShowXYZ = v end })

local SecAimbot = TabRadarAim:Section({ Title = "Aimbot Settings", Icon = "crosshair", Opened = true })
SecAimbot:Toggle({ Title = "Enable Aimbot", Value = false, Callback = function(v) AimConfig.Enabled = v end })
SecAimbot:Slider({ Title = "Aim Smoothing", Value = { Min = 1, Max = 100, Default = 50 }, Callback = function(v) AimConfig.Smoothness = v / 100 end })

-- --- MAGIC TAB ---
local SecMovement = TabMagic:Section({ Title = "Movement Exploits", Icon = "move", Opened = true })
SecMovement:Toggle({ Title = "Admin Fly (Camera-Look Android)", Value = false, Callback = function(v) MagicConfig.Fly = v end })
SecMovement:Slider({ Title = "Fly Speed", Value = { Min = 1, Max = 100, Default = 50 }, Callback = function(v) MagicConfig.FlySpeed = v end })
SecMovement:Toggle({ Title = "Wall-Only Noclip", Value = false, Callback = function(v) MagicConfig.WallNoclip = v end })
SecMovement:Toggle({ Title = "Air Jump", Value = false, Callback = function(v) MagicConfig.AirJump = v end })
SecMovement:Slider({ Title = "Speed Boost", Value = { Min = 0, Max = 1000, Default = 0 }, Callback = function(v) MagicConfig.Speed = (v / 100) * 1.5 end })
SecMovement:Toggle({ Title = "Click to Teleport (Tool)", Value = false, Callback = function(v) 
    MagicConfig.ClickTP = v 
    if v then
        local tpTool = Instance.new("Tool", LocalPlayer.Backpack)
        tpTool.Name = "✨ Teleport"
        tpTool.RequiresHandle = false
        tpTool.Activated:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    else
        local tpTool = LocalPlayer.Backpack:FindFirstChild("✨ Teleport") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("✨ Teleport"))
        if tpTool then tpTool:Destroy() end
    end
end })

local SecExploits = TabMagic:Section({ Title = "Game Exploits", Icon = "shield-alert", Opened = false })
SecExploits:Toggle({ Title = "Unlimited Items & Instant Cooldowns", Value = false, Callback = function(v) MagicConfig.UnlimitedItems = v; MagicConfig.InstantCooldown = v end })
SecExploits:Toggle({ Title = "Infinite Stamina / Energy Bar", Value = false, Callback = function(v) MagicConfig.InfiniteEnergy = v end })
SecExploits:Toggle({ Title = "God Mode (NonTarget Evasion)", Value = false, Callback = function(v) 
    MagicConfig.GodMode = v 
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Name = v and "NonTarget" or "Humanoid" end
    end
end })
SecExploits:Toggle({ Title = "Item Immunity (No Harm)", Value = false, Callback = function(v) MagicConfig.ItemImmunity = v end })
SecExploits:Toggle({ Title = "True Invisibility (Ghost)", Value = false, Callback = function(v) 
    MagicConfig.Invisibility = v 
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then part.Transparency = v and 1 or 0 end
        end
    end
end })

-- --- ENTITY MANAGER & DEBUG TAB ---
TabEntity:Paragraph({ Title = "Debug & Manual Override", Desc = "Enable Debug Mode to open the minimizable entity list overlay. Players are hidden from debug." })
TabEntity:Toggle({ Title = "Enable Debug List Overlay", Value = false, Callback = function(v) 
    MagicConfig.DebugEnabled = v 
    if _G.DebugUI then _G.DebugUI.Visible = v end
end })

local SelectedTarget = ""
TabEntity:Input({ Title = "Target Name", Placeholder = "e.g. Banana Peel, PlayerName", Callback = function(text) SelectedTarget = text end })

local ActionGroup = TabEntity:Group({})
ActionGroup:Button({ Title = "Set to Player (Green)", Callback = function() 
    if _G.LullabyRegistry[SelectedTarget] then _G.LullabyRegistry[SelectedTarget].State = "ESP" end 
    WindUI:Notify({Title="Updated", Content=SelectedTarget.." moved to Player ESP", Duration=2})
end })
ActionGroup:Button({ Title = "Set to MCP Bot (Red)", Callback = function() 
    if _G.LullabyRegistry[SelectedTarget] then _G.LullabyRegistry[SelectedTarget].State = "MCP" end 
    WindUI:Notify({Title="Updated", Content=SelectedTarget.." moved to MCP ESP", Duration=2})
end })
ActionGroup:Button({ Title = "Set to Item (Orange)", Callback = function() 
    if _G.LullabyRegistry[SelectedTarget] then _G.LullabyRegistry[SelectedTarget].State = "Item" end 
    WindUI:Notify({Title="Updated", Content=SelectedTarget.." moved to Item ESP", Duration=2})
end })
ActionGroup:Button({ Title = "Hide (None)", Callback = function() 
    if _G.LullabyRegistry[SelectedTarget] then _G.LullabyRegistry[SelectedTarget].State = "None" end 
end })

-- ==============================================================================
-- 4. NATIVE DEBUG BOX & RADAR OVERLAY
-- ==============================================================================
local safeCore = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

-- Radar Frame
local RadarScreen = Instance.new("ScreenGui", safeCore)
RadarScreen.Name = "LullabyRadarNative"
_G.RadarFrame = Instance.new("Frame", RadarScreen)
_G.RadarFrame.Size = UDim2.new(0, 200, 0, 200)
_G.RadarFrame.Position = UDim2.new(0, 10, 0.5, -100)
_G.RadarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
_G.RadarFrame.BackgroundTransparency = 0.3
_G.RadarFrame.Visible = false
_G.RadarFrame.Active = true
_G.RadarFrame.Draggable = true 
Instance.new("UICorner", _G.RadarFrame).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", _G.RadarFrame).Color = Color3.fromRGB(100, 100, 100)

local RadarCenter = Instance.new("Frame", _G.RadarFrame)
RadarCenter.Size = UDim2.new(0, 4, 0, 4)
RadarCenter.Position = UDim2.new(0.5, -2, 0.5, -2)
RadarCenter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", RadarCenter).CornerRadius = UDim.new(1, 0)

-- Minimizable Debug Entity List
_G.DebugUI = Instance.new("Frame", RadarScreen)
_G.DebugUI.Size = UDim2.new(0, 220, 0, 300)
_G.DebugUI.Position = UDim2.new(1, -230, 0.5, -150)
_G.DebugUI.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
_G.DebugUI.Visible = false
_G.DebugUI.Active = true
_G.DebugUI.Draggable = true
Instance.new("UICorner", _G.DebugUI).CornerRadius = UDim.new(0, 6)

local DebugTitle = Instance.new("TextButton", _G.DebugUI)
DebugTitle.Size = UDim2.new(1, 0, 0, 30)
DebugTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
DebugTitle.Text = " 🔍 Debug Entities (Click to Minimize)"
DebugTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
DebugTitle.Font = Enum.Font.GothamBold
DebugTitle.TextSize = 11
DebugTitle.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", DebugTitle).CornerRadius = UDim.new(0, 6)

local DebugScroll = Instance.new("ScrollingFrame", _G.DebugUI)
DebugScroll.Size = UDim2.new(1, -10, 1, -40)
DebugScroll.Position = UDim2.new(0, 5, 0, 35)
DebugScroll.BackgroundTransparency = 1
DebugScroll.ScrollBarThickness = 3
local DebugLayout = Instance.new("UIListLayout", DebugScroll)
DebugLayout.Padding = UDim.new(0, 4)

local debugMinimized = false
DebugTitle.MouseButton1Click:Connect(function()
    debugMinimized = not debugMinimized
    _G.DebugUI.Size = debugMinimized and UDim2.new(0, 220, 0, 30) or UDim2.new(0, 220, 0, 300)
    DebugScroll.Visible = not debugMinimized
end)

local NextEntityState = { None = "Item", Item = "MCP", MCP = "None" }
local DebugStateColors = { None = Color3.fromRGB(60, 60, 65), MCP = Color3.fromRGB(200, 50, 50), Item = Color3.fromRGB(200, 150, 0) }

local function RefreshDebugList()
    if not _G.DebugUI or not DebugScroll then return end
    for _, child in ipairs(DebugScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for name, data in pairs(_G.LullabyRegistry) do
        if not data.IsPlayer then
            local btn = Instance.new("TextButton", DebugScroll)
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 11
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = DebugStateColors[data.State] or DebugStateColors.None
            btn.Text = name .. " (" .. #data.Instances .. ") [" .. data.State .. "]"
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                data.State = NextEntityState[data.State]
                btn.BackgroundColor3 = DebugStateColors[data.State]
                btn.Text = name .. " (" .. #data.Instances .. ") [" .. data.State .. "]"
            end)
        end
    end
    DebugScroll.CanvasSize = UDim2.new(0, 0, 0, DebugLayout.AbsoluteContentSize.Y + 10)
end

-- ==============================================================================
-- 5. GROUPED NAME REGISTRY SYSTEM
-- ==============================================================================
local function autoClassify(name)
    local lName = string.lower(name)
    if string.find(lName, "bot") or string.find(lName, "enemy") or string.find(lName, "worm") or string.find(lName, "monster") then return "MCP" end
    if string.find(lName, "banana") or string.find(lName, "item") or string.find(lName, "trap") or string.find(lName, "trigger") then return "Item" end
    return "None"
end

local function registerEntity(obj, isPlayer)
    if not obj or obj == LocalPlayer.Character then return end
    local name = obj.Name

    if not _G.LullabyRegistry[name] then
        _G.LullabyRegistry[name] = {
            DisplayName = name,
            State = isPlayer and "ESP" or autoClassify(name),
            Instances = {},
            IsPlayer = isPlayer
        }
    end

    local entry = _G.LullabyRegistry[name]
    local exists = false
    for _, inst in ipairs(entry.Instances) do if inst == obj then exists = true end end
    if not exists then 
        table.insert(entry.Instances, obj) 
        if MagicConfig.DebugEnabled then RefreshDebugList() end
    end
end

-- ==============================================================================
-- 6. BACKGROUND WORKERS (SCANNER & EXPLOITS)
-- ==============================================================================
task.spawn(function()
    while true do
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then registerEntity(p.Character, true) end
        end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj == LocalPlayer.Character or obj:IsDescendantOf(LocalPlayer.Character) then continue end
            
            local isEntity = false
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then isEntity = true end
            if obj:IsA("BasePart") and (obj:FindFirstChildOfClass("TouchTransmitter") or obj:FindFirstChildOfClass("ProximityPrompt")) then isEntity = true end
            
            if isEntity then
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do if p.Character == obj then isPlayer = true end end
                if not isPlayer then registerEntity(obj, false) end
            end
        end
        task.wait(2) 
    end
end)

RunService.Heartbeat:Connect(function()
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

    if MagicConfig.UnlimitedItems or MagicConfig.InstantCooldown then
        local containers = {LocalPlayer:FindFirstChildOfClass("Backpack"), LocalPlayer.Character}
        for _, container in ipairs(containers) do
            if container then
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") then
                        pcall(function()
                            if tool:FindFirstChild("Cooldown") then tool.Cooldown.Value = 0 end
                            if tool:FindFirstChild("Debounce") then tool.Debounce.Value = false end
                            if tool:FindFirstChild("CooldowTime") then tool.CooldowTime.Value = 0 end
                            tool.Enabled = true
                        end)
                    end
                end
            end
        end
        pcall(function()
            local stats = LocalPlayer:FindFirstChild("PlayerStats") or LocalPlayer:FindFirstChild("Values")
            if stats then
                for _, stat in ipairs(stats:GetChildren()) do
                    local n = string.lower(stat.Name)
                    if string.find(n, "cooldown") or string.find(n, "delay") or string.find(n, "time") then
                        if stat:IsA("NumberValue") or stat:IsA("IntValue") then stat.Value = 0 end
                    end
                end
            end
        end)
    end

    if MagicConfig.InfiniteEnergy then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, val in ipairs(char:GetDescendants()) do
                    local n = string.lower(val.Name)
                    if (val:IsA("NumberValue") or val:IsA("IntValue")) and (string.find(n, "stamina") or string.find(n, "energy") or string.find(n, "power") or string.find(n, "exhaust")) then
                        val.Value = 100
                    end
                end
            end
        end)
    end

    local char = LocalPlayer.Character
    if MagicConfig.WallNoclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local ray = Ray.new(part.Position, Vector3.new(0, -3, 0))
                local hit = workspace:FindPartOnRay(ray, char)
                if hit then part.CanCollide = true else part.CanCollide = false end
            end
        end
    end
end)

-- ==============================================================================
-- 7. RENDER, RADAR & FLY ENGINE
-- ==============================================================================
local function drawLine(frame, p1, p2, color, thickness)
    local center = (p1 + p2) / 2
    local vector = p2 - p1
    frame.Position = UDim2.new(0, center.X, 0, center.Y)
    frame.Size = UDim2.new(0, vector.Magnitude, 0, thickness or 2)
    frame.Rotation = math.deg(math.atan2(vector.Y, vector.X))
    frame.BackgroundColor3 = color
    frame.Visible = true
end

local RadarBlips = {}
local bgBodyVel, bgBodyGyro = nil, nil
local R15_Conns = { {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"} }
local R6_Conns = { {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"} }

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Speed Boost
    if myRoot and not MagicConfig.Fly then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if MagicConfig.Speed > 0 and hum and hum.MoveDirection.Magnitude > 0 then
            myRoot.CFrame = myRoot.CFrame + (hum.MoveDirection * MagicConfig.Speed)
        end
    end

    -- Admin Fly
    if MagicConfig.Fly and myRoot then
        if not bgBodyVel then
            bgBodyVel = Instance.new("BodyVelocity", myRoot)
            bgBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bgBodyVel.Velocity = Vector3.new(0, 0, 0)
        end
        if not bgBodyGyro then
            bgBodyGyro = Instance.new("BodyGyro", myRoot)
            bgBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bgBodyGyro.P = 1000
            bgBodyGyro.D = 50
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end

        local camCFrame = Camera.CFrame
        local moveDir = Vector3.new(0, 0, 0)
        
        if hum and hum.MoveDirection.Magnitude > 0 then
            local rawMove = hum.MoveDirection
            local forwardAmount = rawMove:Dot(camCFrame.LookVector)
            local rightAmount = rawMove:Dot(camCFrame.RightVector)
            moveDir = (camCFrame.LookVector * forwardAmount) + (camCFrame.RightVector * rightAmount)
            if moveDir.Magnitude == 0 then moveDir = rawMove end
        end

        bgBodyVel.Velocity = moveDir * (MagicConfig.FlySpeed * 1.5)
        bgBodyGyro.CFrame = camCFrame
    else
        if bgBodyVel then bgBodyVel:Destroy() bgBodyVel = nil end
        if bgBodyGyro then bgBodyGyro:Destroy() bgBodyGyro = nil end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.PlatformStand then hum.PlatformStand = false end
    end

    for _, frame in ipairs(RadarScreen:GetChildren()) do 
        if frame.Name ~= "Frame" then frame.Visible = false end 
    end
    for _, blip in ipairs(RadarBlips) do blip.Visible = false end
    
    local lineIndex = 1
    local blipIndex = 1
    
    local function getLine()
        local frame = RadarScreen:GetChildren()[lineIndex]
        if not frame or frame.Name == "Frame" then
            frame = Instance.new("Frame", RadarScreen)
            frame.AnchorPoint = Vector2.new(0.5, 0.5)
            frame.BorderSizePixel = 0
        end
        lineIndex = lineIndex + 1
        return frame
    end
    
    local function getBlip()
        local blip = RadarBlips[blipIndex]
        if not blip then
            blip = Instance.new("Frame", _G.RadarFrame)
            blip.Size = UDim2.new(0, 6, 0, 6)
            Instance.new("UICorner", blip).CornerRadius = UDim.new(1, 0)
            
            local lbl = Instance.new("TextLabel", blip)
            lbl.Name = "DataLabel"
            lbl.Size = UDim2.new(0, 100, 0, 15)
            lbl.Position = UDim2.new(1, 4, 0.5, -7)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            table.insert(RadarBlips, blip)
        end
        blipIndex = blipIndex + 1
        return blip
    end

    local closestTarget, shortestDistance = nil, AimConfig.FOV_Size
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)

    for name, data in pairs(_G.LullabyRegistry) do
        local categoryConfig = nil
        if data.State == "ESP" then categoryConfig = ESPConfig.Player
        elseif data.State == "MCP" then categoryConfig = ESPConfig.MCP
        elseif data.State == "Item" then categoryConfig = ESPConfig.Item
        end

        local isVisible = categoryConfig and categoryConfig.Enabled
        local color = (data.State == "ESP" and Colors.ESP) or (data.State == "MCP" and Colors.MCP) or Colors.Item

        for i = #data.Instances, 1, -1 do
            local inst = data.Instances[i]
            if not inst or not inst.Parent then 
                table.remove(data.Instances, i) 
            else
                local hl = inst:FindFirstChild("LullabyHighlight")
                local bb = inst:FindFirstChild("LullabyBillboard")
                local box = inst:FindFirstChild("LullabyBox")
                
                if isVisible then
                    -- Glow
                    if categoryConfig.Glow then
                        if not hl then
                            hl = Instance.new("Highlight", inst)
                            hl.Name = "LullabyHighlight"
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0.2
                        end
                        hl.Enabled = true
                        hl.FillColor = color
                        hl.OutlineColor = color
                    elseif hl then hl.Enabled = false end

                    -- Box
                    if categoryConfig.Box then
                        if not box then
                            box = Instance.new("BoxHandleAdornment", inst)
                            box.Name = "LullabyBox"
                            box.AlwaysOnTop = true
                            box.ZIndex = 5
                            box.Transparency = 0.6
                            box.Adornee = inst:IsA("Model") and (inst.PrimaryPart or inst:FindFirstChild("HumanoidRootPart")) or inst
                            box.Size = inst:IsA("Model") and inst:GetExtentsSize() or inst.Size
                        end
                        box.Visible = true
                        box.Color3 = color
                    elseif box then box.Visible = false end

                    -- Name & Health
                    if categoryConfig.Name or categoryConfig.Health then
                        if not bb then
                            bb = Instance.new("BillboardGui", inst)
                            bb.Name = "LullabyBillboard"
                            bb.Size = UDim2.new(0, 200, 0, 40)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = inst:IsA("Model") and (inst:FindFirstChild("Head") or inst.PrimaryPart) or inst
                            
                            local lbl = Instance.new("TextLabel", bb)
                            lbl.Name = "Label"
                            lbl.Size = UDim2.new(1, 0, 0, 20)
                            lbl.BackgroundTransparency = 1
                            lbl.TextStrokeTransparency = 0.2
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 12
                            
                            local hpBg = Instance.new("Frame", bb)
                            hpBg.Name = "HPBg"
                            hpBg.Size = UDim2.new(0.5, 0, 0, 4)
                            hpBg.Position = UDim2.new(0.25, 0, 0, 22)
                            hpBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                            
                            local hpFill = Instance.new("Frame", hpBg)
                            hpFill.Name = "HPFill"
                            hpFill.Size = UDim2.new(1, 0, 1, 0)
                            hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        end
                        bb.Enabled = true
                        local lbl = bb:FindFirstChild("Label")
                        local hpBg = bb:FindFirstChild("HPBg")
                        
                        if categoryConfig.Name and lbl then
                            lbl.Text = name
                            lbl.TextColor3 = color
                            lbl.Visible = true
                        elseif lbl then lbl.Visible = false end
                        
                        if categoryConfig.Health and hpBg then
                            hpBg.Visible = true
                            local hum = inst:FindFirstChildOfClass("Humanoid")
                            if hum then
                                hpBg:FindFirstChild("HPFill").Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
                            end
                        elseif hpBg then hpBg.Visible = false end
                    elseif bb then bb.Enabled = false end
                else
                    if hl then hl.Enabled = false end
                    if bb then bb.Enabled = false end
                    if box then box.Visible = false end
                end
            end
        end

        if isVisible and #data.Instances > 0 then
            for _, inst in ipairs(data.Instances) do
                local root = inst:IsA("Model") and (inst:FindFirstChild("HumanoidRootPart") or inst.PrimaryPart) or (inst:IsA("BasePart") and inst)
                
                -- Radar with XYZ
                if RadarConfig.Enabled and myRoot and root then
                    local offset = root.Position - myRoot.Position
                    local radarRadius = 95
                    local scale = 1.5
                    local rx = offset.X / scale
                    local rz = offset.Z / scale

                    if (Vector2.new(rx, rz).Magnitude) <= radarRadius then
                        local blip = getBlip()
                        blip.Position = UDim2.new(0.5, rx - 3, 0.5, rz - 3)
                        blip.BackgroundColor3 = color
                        blip.Visible = true
                        
                        local lbl = blip:FindFirstChild("DataLabel")
                        if lbl then
                            if RadarConfig.ShowXYZ then
                                local dist = math.floor(offset.Magnitude)
                                local yDiff = math.floor(offset.Y)
                                lbl.Text = string.format("%dm (Y:%d)", dist, yDiff)
                                lbl.TextColor3 = color
                                lbl.Visible = true
                            else
                                lbl.Visible = false
                            end
                        end
                    end
                end

                if root then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        if categoryConfig.Tracer then
                            local origin = Vector2.new(Camera.ViewportSize.X/2, 0) 
                            drawLine(getLine(), origin, Vector2.new(screenPos.X, screenPos.Y), color, 1.5)
                        end
                        
                        if categoryConfig.Skeleton and inst:IsA("Model") then
                            local conns = inst:FindFirstChild("UpperTorso") and R15_Conns or (inst:FindFirstChild("Torso") and R6_Conns or nil)
                            if conns then
                                for _, conn in ipairs(conns) do
                                    local p1, p2 = inst:FindFirstChild(conn[1]), inst:FindFirstChild(conn[2])
                                    if p1 and p2 then
                                        local s1, on1 = Camera:WorldToViewportPoint(p1.Position)
                                        local s2, on2 = Camera:WorldToViewportPoint(p2.Position)
                                        if on1 and on2 then drawLine(getLine(), Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y), color, 1.5) end
                                    end
                                end
                            end
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
    if MagicConfig.Invisibility then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then part.Transparency = 1 end
        end
    end
end)

print("🚀 [Lullaby] WindUI v17.1 Executed Successfully!")
