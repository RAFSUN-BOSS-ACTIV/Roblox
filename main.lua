-- ==============================================================================
-- LULLABY v18.4 - COLLISION TAB, ALL-NOCLIP & LAND BYPASS (WINDUI PRO)
-- ==============================================================================
print("⏳ [Lullaby] Initializing Engine v18.4 with WindUI...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

_G.LullabyRegistry = _G.LullabyRegistry or {} 
_G.SavedWaypoints = _G.SavedWaypoints or {} 
_G.CustomGroups = _G.CustomGroups or {} 
local GroupCounter = 1

-- ==============================================================================
-- 1. LOAD WINDUI & CREATE WINDOW
-- ==============================================================================
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))()
end)

if not success or not WindUI then
    warn("❌ [Lullaby] Failed to load WindUI. Please check your internet or executor.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "⚡ Lullaby Modular Hub v18.4",
    Icon = "zap",
    Author = "by Lullaby",
    Folder = "LullabyHub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 195,
    HideSearchBar = true,
    KeySystem = {
        Title = "Access Required",
        Note = "Enter the access key 'free' to continue.",
        KeyValidator = function(key) return key == "free" end,
        SaveKey = true,
        Thumbnail = { Image = "rbxassetid://10618928818", Title = "Free Access Key: free" }
    }
})

local function NotifyState(title, state)
    local stateStr = type(state) == "boolean" and (state and "Enabled" or "Disabled") or state
    WindUI:Notify({ Title = title, Content = stateStr, Duration = 1.5 })
end

WindUI:Notify({ Title = "Welcome to Lullaby", Content = "v18.4 Full Collision System Loaded.", Icon = "check-circle", Duration = 4 })

-- ==============================================================================
-- 2. CONFIGURATION & STATE
-- ==============================================================================
local ESPConfig = {
    Player = { Enabled = true, Glow = true, Name = true, Distance = true, Health = false, Box = false, Skeleton = false, Tracer = false },
    MCP = { Enabled = false, Glow = true, Name = true, Distance = true, Health = false, Box = false, Skeleton = false, Tracer = false },
    Item = { Enabled = false, Glow = true, Name = true, Distance = true, Box = false, Tracer = false }
}

local RadarConfig = { Enabled = false, ShowXYZ = true }
local Colors = { ESP = Color3.fromRGB(0, 255, 0), MCP = Color3.fromRGB(255, 0, 0), Item = Color3.fromRGB(255, 150, 0) }

local AimConfig = { 
    Enabled = false, TargetPlayers = true, TargetMCP = true, 
    ShowFOV = false, FOV_Size = 150, VisCheck = false,
    TargetPart = "Head", 
    Smoothness = 0.5, Speed = 1,
    LockHighlight = false, ProjectileBox = false
}

local MagicConfig = { 
    SpeedEnabled = false, Speed = 0, JumpEnabled = false, Jump = 50, AirJump = false, ClickTP = false, 
    GodMode = false, ItemImmunity = false, Invisibility = false, Fly = false, FlySpeed = 50, 
    WallNoclip = false, NoclipWall = false, NoclipEverything = false, BypassLand = false,
    UnlimitedItems = false, InstantCooldown = false, InfiniteEnergy = false, DebugEnabled = false, HighKick = false 
}

local TeleportConfig = { TargetPlayer = "None", WaypointNameInput = "New Waypoint", MagnetActive = false, MagnetMode = "Me", MagnetStaticPos = nil, MagnetTargetGroup = "ALL ITEMS" }

-- ==============================================================================
-- 3. WINDUI TABS & SECTIONS
-- ==============================================================================
local TabVisuals = Window:Tab({ Title = "ESP & Visuals", Icon = "eye" })
local TabRadar = Window:Tab({ Title = "Interactive Radar", Icon = "radar" })
local TabAimbot = Window:Tab({ Title = "Aimbot (Import)", Icon = "crosshair" })
local TabMagic = Window:Tab({ Title = "Magic & Exploits", Icon = "wand-2" })
local TabCollision = Window:Tab({ Title = "Collision (All)", Icon = "box-select" }) -- NEW TAB
local TabTeleport = Window:Tab({ Title = "Teleport Hub", Icon = "map-pin" })
local TabEntity = Window:Tab({ Title = "Entity Manager", Icon = "package" })

-- --- VISUALS TAB ---
local SecPlayerESP = TabVisuals:Section({ Title = "Player ESP", Icon = "user", Opened = true })
SecPlayerESP:Toggle({ Title = "Enable Player ESP", Value = true, Callback = function(v) ESPConfig.Player.Enabled = v; NotifyState("Player ESP", v) end })
SecPlayerESP:Toggle({ Title = "Glow (Aura)", Value = true, Callback = function(v) ESPConfig.Player.Glow = v end })
SecPlayerESP:Toggle({ Title = "Show Name", Value = true, Callback = function(v) ESPConfig.Player.Name = v end })
SecPlayerESP:Toggle({ Title = "Show Distance", Value = true, Callback = function(v) ESPConfig.Player.Distance = v end })
SecPlayerESP:Toggle({ Title = "Show Health Bar", Value = false, Callback = function(v) ESPConfig.Player.Health = v end })
SecPlayerESP:Toggle({ Title = "Show 2D Box", Value = false, Callback = function(v) ESPConfig.Player.Box = v end })
SecPlayerESP:Toggle({ Title = "Show Skeleton", Value = false, Callback = function(v) ESPConfig.Player.Skeleton = v end })
SecPlayerESP:Toggle({ Title = "Show Bottom Tracers", Value = false, Callback = function(v) ESPConfig.Player.Tracer = v end })

local SecMCPESP = TabVisuals:Section({ Title = "MCP Bot ESP", Icon = "bot", Opened = false })
SecMCPESP:Toggle({ Title = "Enable MCP ESP", Value = false, Callback = function(v) ESPConfig.MCP.Enabled = v; NotifyState("MCP ESP", v) end })
SecMCPESP:Toggle({ Title = "Glow (Aura)", Value = true, Callback = function(v) ESPConfig.MCP.Glow = v end })
SecMCPESP:Toggle({ Title = "Show Name", Value = true, Callback = function(v) ESPConfig.MCP.Name = v end })
SecMCPESP:Toggle({ Title = "Show Distance", Value = true, Callback = function(v) ESPConfig.MCP.Distance = v end })
SecMCPESP:Toggle({ Title = "Show Health Bar", Value = false, Callback = function(v) ESPConfig.MCP.Health = v end })
SecMCPESP:Toggle({ Title = "Show 2D Box", Value = false, Callback = function(v) ESPConfig.MCP.Box = v end })
SecMCPESP:Toggle({ Title = "Show Bottom Tracers", Value = false, Callback = function(v) ESPConfig.MCP.Tracer = v end })

local SecItemESP = TabVisuals:Section({ Title = "Item ESP", Icon = "box", Opened = false })
SecItemESP:Toggle({ Title = "Enable Item ESP", Value = false, Callback = function(v) ESPConfig.Item.Enabled = v; NotifyState("Item ESP", v) end })
SecItemESP:Toggle({ Title = "Glow (Aura)", Value = true, Callback = function(v) ESPConfig.Item.Glow = v end })
SecItemESP:Toggle({ Title = "Show Name", Value = true, Callback = function(v) ESPConfig.Item.Name = v end })
SecItemESP:Toggle({ Title = "Show Distance", Value = true, Callback = function(v) ESPConfig.Item.Distance = v end })
SecItemESP:Toggle({ Title = "Show 2D Box", Value = false, Callback = function(v) ESPConfig.Item.Box = v end })
SecItemESP:Toggle({ Title = "Show Bottom Tracers", Value = false, Callback = function(v) ESPConfig.Item.Tracer = v end })

-- --- RADAR TAB ---
local SecRadar = TabRadar:Section({ Title = "Interactive 2D Radar", Icon = "radar", Opened = true })
SecRadar:Toggle({ Title = "Show Radar Overlay", Value = false, Callback = function(v) RadarConfig.Enabled = v; if _G.RadarFrame then _G.RadarFrame.Visible = v end; NotifyState("Radar", v) end })
SecRadar:Toggle({ Title = "Show Distance & XYZ on Blips", Value = true, Callback = function(v) RadarConfig.ShowXYZ = v end })

-- --- AIMBOT (IMPORT) TAB ---
local SecAim = TabAimbot:Section({ Title = "Advanced Aimbot Engine", Icon = "target", Opened = true })
SecAim:Toggle({ Title = "Enable Aimbot Lock", Value = false, Callback = function(v) AimConfig.Enabled = v; NotifyState("Aimbot", v) end })
SecAim:Toggle({ Title = "Visibility Check (Wall Check)", Value = false, Callback = function(v) AimConfig.VisCheck = v; NotifyState("Vis-Check", v) end })

local SecAimVisuals = TabAimbot:Section({ Title = "Targeting Visuals", Icon = "eye", Opened = true })
SecAimVisuals:Toggle({ Title = "Show FOV Circle", Value = false, Callback = function(v) AimConfig.ShowFOV = v; if _G.FOVCircle then _G.FOVCircle.Visible = v end end })
SecAimVisuals:Slider({ Title = "FOV Size", Value = { Min = 50, Max = 800, Default = 150 }, Callback = function(v) AimConfig.FOV_Size = v end })

SecAimVisuals:Toggle({ Title = "Target Lock Visuals (Red/Green Glow)", Value = false, Callback = function(v) AimConfig.LockHighlight = v end })
SecAimVisuals:Toggle({ Title = "Show Projectile Hit Box", Value = false, Callback = function(v) AimConfig.ProjectileBox = v end })

local SecAimConfig = TabAimbot:Section({ Title = "Robotic Tuning", Icon = "settings-2", Opened = true })
SecAimConfig:Dropdown({ Title = "Target Part", Options = {"Head", "Torso", "Legs"}, Default = "Head", Callback = function(v) AimConfig.TargetPart = v end })
SecAimConfig:Slider({ Title = "Aim Smoothness", Value = { Min = 1, Max = 100, Default = 50 }, Callback = function(v) AimConfig.Smoothness = v / 100 end })
SecAimConfig:Slider({ Title = "Aimbot Speed (Power)", Value = { Min = 1, Max = 100, Default = 50 }, Callback = function(v) AimConfig.Speed = v / 25 end })

-- --- MAGIC TAB ---
local SecMovement = TabMagic:Section({ Title = "Movement Exploits", Icon = "move", Opened = true })
SecMovement:Toggle({ Title = "Admin Fly (Camera-Look Android)", Value = false, Callback = function(v) MagicConfig.Fly = v; NotifyState("Fly Mode", v) end })
SecMovement:Slider({ Title = "Fly Speed", Value = { Min = 1, Max = 100, Default = 50 }, Callback = function(v) MagicConfig.FlySpeed = v end })
SecMovement:Toggle({ Title = "Enable Speed Boost", Value = false, Callback = function(v) MagicConfig.SpeedEnabled = v; NotifyState("Speed Boost", v) end })
SecMovement:Slider({ Title = "Speed Power", Value = { Min = 0, Max = 1000, Default = 0 }, Callback = function(v) MagicConfig.Speed = (v / 100) * 1.5 end })
SecMovement:Toggle({ Title = "Enable Jump Power", Value = false, Callback = function(v) 
    MagicConfig.JumpEnabled = v 
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true; hum.JumpPower = v and MagicConfig.Jump or 50 end
    NotifyState("Custom Jump", v)
end })
SecMovement:Slider({ Title = "Jump Power Level", Value = { Min = 0, Max = 1000, Default = 50 }, Callback = function(v) 
    MagicConfig.Jump = v 
    if MagicConfig.JumpEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end })
SecMovement:Toggle({ Title = "Air Jump", Value = false, Callback = function(v) MagicConfig.AirJump = v; NotifyState("Air Jump", v) end })

local SecCombat = TabMagic:Section({ Title = "Combat & Tools", Icon = "swords", Opened = false })
SecCombat:Toggle({ Title = "High Power Kick (Tool)", Value = false, Callback = function(v) 
    MagicConfig.HighKick = v 
    NotifyState("High Kick Tool", v)
    if v then
        local kickTool = Instance.new("Tool", LocalPlayer.Backpack)
        kickTool.Name = "🦵 High Kick"
        kickTool.RequiresHandle = false
        kickTool.Activated:Connect(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= char and obj:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = obj:FindFirstChild("HumanoidRootPart")
                    local dist = (targetRoot.Position - root.Position).Magnitude
                    if dist < 15 then
                        local bv = Instance.new("BodyVelocity", targetRoot)
                        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bv.Velocity = (targetRoot.Position - root.Position).Unit * 500 + Vector3.new(0, 100, 0)
                        game:GetService("Debris"):AddItem(bv, 0.2)
                    end
                end
            end
        end)
    else
        local t = LocalPlayer.Backpack:FindFirstChild("🦵 High Kick") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("🦵 High Kick"))
        if t then t:Destroy() end
    end
end })

local SecExploits = TabMagic:Section({ Title = "Game Exploits", Icon = "shield-alert", Opened = false })
SecExploits:Toggle({ Title = "Unlimited Items & Instant Cooldowns", Value = false, Callback = function(v) MagicConfig.UnlimitedItems = v; MagicConfig.InstantCooldown = v; NotifyState("No Cooldowns", v) end })
SecExploits:Toggle({ Title = "Infinite Stamina / Energy Bar", Value = false, Callback = function(v) MagicConfig.InfiniteEnergy = v; NotifyState("Infinite Energy", v) end })
SecExploits:Toggle({ Title = "God Mode (NonTarget Evasion)", Value = false, Callback = function(v) 
    MagicConfig.GodMode = v 
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Name = v and "NonTarget" or "Humanoid" end
    end
    NotifyState("God Mode", v)
end })
SecExploits:Toggle({ Title = "Item Immunity (No Harm)", Value = false, Callback = function(v) MagicConfig.ItemImmunity = v; NotifyState("Item Immunity", v) end })
SecExploits:Toggle({ Title = "True Invisibility (Ghost)", Value = false, Callback = function(v) MagicConfig.Invisibility = v; NotifyState("Invisibility", v) end })

-- --- COLLISION (ALL) TAB ---
local SecNoclip = TabCollision:Section({ Title = "Noclip Engine", Icon = "ghost", Opened = true })
SecNoclip:Toggle({ Title = "Go Through Walls", Value = false, Callback = function(v) MagicConfig.NoclipWall = v; NotifyState("Wall Noclip", v) end })
SecNoclip:Toggle({ Title = "Go Through Everything", Value = false, Callback = function(v) MagicConfig.NoclipEverything = v; NotifyState("Everything Noclip", v) end })
SecNoclip:Toggle({ Title = "Include Land (Go Through Floor)", Value = false, Callback = function(v) MagicConfig.BypassLand = v; NotifyState("Land Bypass", v) end })

-- --- TELEPORT HUB TAB ---
local SecClickTP = TabTeleport:Section({ Title = "Click Teleport", Icon = "mouse-pointer", Opened = true })
SecClickTP:Toggle({ Title = "Click to Teleport (Tool)", Value = false, Callback = function(v) 
    MagicConfig.ClickTP = v 
    NotifyState("Click TP Tool", v)
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

local SecPlayerTP = TabTeleport:Section({ Title = "Player Teleport", Icon = "users", Opened = true })
_G.ActivePlayerDisplay = SecPlayerTP:Paragraph({ Title = "Selected Player", Desc = "None" })
SecPlayerTP:Button({ Title = "🔍 Select Player from List", Callback = function() 
    if _G.OpenSelectorUI then _G.OpenSelectorUI("Player") end 
end })
SecPlayerTP:Button({ Title = "Teleport to Selected Player", Callback = function()
    local target = Players:FindFirstChild(TeleportConfig.TargetPlayer)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then 
            myRoot.CFrame = target.Character.HumanoidRootPart.CFrame 
            WindUI:Notify({Title="Teleported", Content="Moved to " .. target.Name, Duration=1.5})
        end
    end
end })

local SecWaypoints = TabTeleport:Section({ Title = "Saved Waypoints (Max 10)", Icon = "map-pin", Opened = false })
SecWaypoints:Input({ Title = "Waypoint Name", Placeholder = "e.g. Safe Zone, Base", Callback = function(text) TeleportConfig.WaypointNameInput = text end })

local function CountWaypoints() local c = 0; for _ in pairs(_G.SavedWaypoints) do c = c + 1 end; return c end
local WaypointGroup = SecWaypoints:Group({})

SecWaypoints:Button({ Title = "Save Current Position", Callback = function()
    if CountWaypoints() >= 10 then WindUI:Notify({Title="Limit Reached", Content="You can only save 10 waypoints at a time.", Duration=3}); return end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and TeleportConfig.WaypointNameInput ~= "" then
        local name = TeleportConfig.WaypointNameInput
        _G.SavedWaypoints[name] = myRoot.CFrame
        WaypointGroup:Button({ Title = "TP: " .. name, Callback = function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and _G.SavedWaypoints[name] then
                root.CFrame = _G.SavedWaypoints[name]
                WindUI:Notify({Title="Teleported", Content="Arrived at " .. name, Duration=1.5})
            end
        end })
        WindUI:Notify({Title="Waypoint Saved", Content="Saved Location: " .. name, Duration=2})
    end
end })

local SecItemMagnet = TabTeleport:Section({ Title = "Continuous Item Magnet", Icon = "magnet", Opened = true })
_G.ActiveMagnetDisplay = SecItemMagnet:Paragraph({ Title = "Selected Target", Desc = "ALL ITEMS" })
SecItemMagnet:Button({ Title = "🔍 Select Target / Group", Callback = function() 
    if _G.OpenSelectorUI then _G.OpenSelectorUI("Magnet") end 
end })

local MagnetGroup = SecItemMagnet:Group({})
MagnetGroup:Button({ Title = "🎯 Set Drop Point: ME (Follow)", Callback = function() 
    TeleportConfig.MagnetMode = "Me"
    WindUI:Notify({Title="Mode Set", Content="Target: ME (Follows you)", Duration=2})
end })
MagnetGroup:Button({ Title = "📍 Set Drop Point: HERE (Static)", Callback = function() 
    TeleportConfig.MagnetMode = "Here"
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        TeleportConfig.MagnetStaticPos = root.CFrame
        WindUI:Notify({Title="Mode Set", Content="Target: Static Drop Point Saved.", Duration=2})
    end
end })

SecItemMagnet:Toggle({ Title = "▶ START Continuous Magnet", Value = false, Callback = function(v) 
    TeleportConfig.MagnetActive = v 
    NotifyState("Item Magnet Loop", v)
end })

-- --- ENTITY MANAGER TAB ---
local SecCustomGroups = TabEntity:Section({ Title = "Custom Group Builder", Icon = "layers", Opened = true })
SecCustomGroups:Button({ Title = "Open Visual Group Builder", Callback = function()
    if _G.GroupBuilderUI then
        _G.GroupBuilderUI.Visible = true
        if _G.RefreshGroupBuilder then _G.RefreshGroupBuilder() end
    end
end })

local SecOverrides = TabEntity:Section({ Title = "Debug & Live Scanner", Icon = "cpu", Opened = true })
SecOverrides:Toggle({ Title = "Enable Debug List Overlay", Value = false, Callback = function(v) 
    MagicConfig.DebugEnabled = v 
    if _G.DebugUI then _G.DebugUI.Visible = v end
    NotifyState("Debug Overlay", v)
end })

-- ==============================================================================
-- 4. NATIVE OVERLAY UIs (Radar, FOV, Selectors)
-- ==============================================================================
local safeCore = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
local RadarScreen = Instance.new("ScreenGui", safeCore)
RadarScreen.Name = "LullabyNativeOverlays"

-- 4a. FOV CIRCLE
_G.FOVCircle = Instance.new("Frame", RadarScreen)
_G.FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
_G.FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
_G.FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_G.FOVCircle.BackgroundTransparency = 1
_G.FOVCircle.Visible = false
local FOVStroke = Instance.new("UIStroke", _G.FOVCircle)
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.5
local FOVCorner = Instance.new("UICorner", _G.FOVCircle)
FOVCorner.CornerRadius = UDim.new(1, 0)

-- 4b. RADAR
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

-- 4c. DEBUG UI
_G.DebugUI = Instance.new("Frame", RadarScreen)
_G.DebugUI.Size = UDim2.new(0, 240, 0, 360)
_G.DebugUI.Position = UDim2.new(1, -250, 0.5, -180)
_G.DebugUI.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
_G.DebugUI.Visible = false
_G.DebugUI.Active = true
_G.DebugUI.Draggable = true
Instance.new("UICorner", _G.DebugUI).CornerRadius = UDim.new(0, 6)

local DebugTitle = Instance.new("TextButton", _G.DebugUI)
DebugTitle.Size = UDim2.new(1, 0, 0, 40) 
DebugTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
DebugTitle.Text = " 🔍 Debug Scanner (Tap to Min/Max)"
DebugTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
DebugTitle.Font = Enum.Font.GothamBold
DebugTitle.TextSize = 12
DebugTitle.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", DebugTitle).CornerRadius = UDim.new(0, 6)

local DebugSearch = Instance.new("TextBox", _G.DebugUI)
DebugSearch.Size = UDim2.new(1, -10, 0, 30)
DebugSearch.Position = UDim2.new(0, 5, 0, 45)
DebugSearch.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
DebugSearch.TextColor3 = Color3.fromRGB(255, 255, 255)
DebugSearch.PlaceholderText = "Search entities..."
DebugSearch.Font = Enum.Font.Gotham
DebugSearch.TextSize = 12
Instance.new("UICorner", DebugSearch).CornerRadius = UDim.new(0, 4)

local DebugScroll = Instance.new("ScrollingFrame", _G.DebugUI)
DebugScroll.Size = UDim2.new(1, -10, 1, -85)
DebugScroll.Position = UDim2.new(0, 5, 0, 80)
DebugScroll.BackgroundTransparency = 1
DebugScroll.ScrollBarThickness = 4
local DebugLayout = Instance.new("UIListLayout", DebugScroll)
DebugLayout.Padding = UDim.new(0, 4)

local debugMinimized = false
DebugTitle.MouseButton1Click:Connect(function()
    debugMinimized = not debugMinimized
    _G.DebugUI.Size = debugMinimized and UDim2.new(0, 240, 0, 40) or UDim2.new(0, 240, 0, 360)
    DebugScroll.Visible = not debugMinimized
    DebugSearch.Visible = not debugMinimized
end)

local NextStateCycle = { None = "Item", Item = "MCP", MCP = "None" }
local DebugStateColors = { None = Color3.fromRGB(60, 60, 65), MCP = Color3.fromRGB(200, 50, 50), Item = Color3.fromRGB(200, 150, 0) }

local DebugButtonCache = {}
RunService.Heartbeat:Connect(function()
    if not MagicConfig.DebugEnabled then return end
    local filter = string.lower(DebugSearch.Text)
    
    for name, data in pairs(_G.LullabyRegistry) do
        if not data.IsPlayer then
            if filter == "" or string.find(string.lower(name), filter) then
                if not DebugButtonCache[name] then
                    local btn = Instance.new("TextButton", DebugScroll)
                    btn.Size = UDim2.new(1, 0, 0, 28)
                    btn.Font = Enum.Font.GothamSemibold
                    btn.TextSize = 11
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                    
                    btn.MouseButton1Click:Connect(function() data.State = NextStateCycle[data.State] end)
                    DebugButtonCache[name] = btn
                    DebugScroll.CanvasSize = UDim2.new(0, 0, 0, DebugLayout.AbsoluteContentSize.Y + 10)
                end
                
                local btn = DebugButtonCache[name]
                if btn then
                    btn.Visible = true
                    btn.Text = name .. " (" .. #data.Instances .. ") [" .. data.State .. "]"
                    btn.BackgroundColor3 = DebugStateColors[data.State] or DebugStateColors.None
                end
            elseif DebugButtonCache[name] then
                DebugButtonCache[name].Visible = false
            end
        end
    end
end)

-- 4d. VISUAL GROUP BUILDER UI & SELECTORS
_G.GroupBuilderUI = Instance.new("Frame", RadarScreen)
_G.GroupBuilderUI.Size = UDim2.new(0, 240, 0, 360)
_G.GroupBuilderUI.Position = UDim2.new(0.5, -120, 0.5, -180)
_G.GroupBuilderUI.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
_G.GroupBuilderUI.Visible = false
_G.GroupBuilderUI.Active = true
_G.GroupBuilderUI.Draggable = true
Instance.new("UICorner", _G.GroupBuilderUI).CornerRadius = UDim.new(0, 6)

local GBTitle = Instance.new("TextLabel", _G.GroupBuilderUI)
GBTitle.Size = UDim2.new(1, 0, 0, 40)
GBTitle.BackgroundTransparency = 1
GBTitle.Text = " Group Builder"
GBTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GBTitle.Font = Enum.Font.GothamBold
GBTitle.TextSize = 14

local GBClose = Instance.new("TextButton", _G.GroupBuilderUI)
GBClose.Size = UDim2.new(0, 30, 0, 30)
GBClose.Position = UDim2.new(1, -30, 0, 0)
GBClose.BackgroundTransparency = 1
GBClose.Text = "X"
GBClose.TextColor3 = Color3.fromRGB(255, 50, 50)
GBClose.Font = Enum.Font.GothamBold
GBClose.TextSize = 14
GBClose.MouseButton1Click:Connect(function() _G.GroupBuilderUI.Visible = false end)

local GBScroll = Instance.new("ScrollingFrame", _G.GroupBuilderUI)
GBScroll.Size = UDim2.new(1, -10, 1, -90)
GBScroll.Position = UDim2.new(0, 5, 0, 40)
GBScroll.BackgroundTransparency = 1
GBScroll.ScrollBarThickness = 4
local GBLayout = Instance.new("UIListLayout", GBScroll)
GBLayout.Padding = UDim.new(0, 4)

local GBSaveBtn = Instance.new("TextButton", _G.GroupBuilderUI)
GBSaveBtn.Size = UDim2.new(1, -10, 0, 40)
GBSaveBtn.Position = UDim2.new(0, 5, 1, -45)
GBSaveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
GBSaveBtn.Text = "💾 Save as New Group"
GBSaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GBSaveBtn.Font = Enum.Font.GothamBold
GBSaveBtn.TextSize = 12
Instance.new("UICorner", GBSaveBtn).CornerRadius = UDim.new(0, 6)

local SelectedForGroup = {}

GBSaveBtn.MouseButton1Click:Connect(function()
    local count = 0
    for _ in pairs(SelectedForGroup) do count = count + 1 end
    if count < 1 then
        WindUI:Notify({Title="Error", Content="Select at least one item first!", Duration=2})
        return
    end
    local groupName = "Group " .. GroupCounter
    GroupCounter = GroupCounter + 1
    _G.CustomGroups[groupName] = {}
    for item, _ in pairs(SelectedForGroup) do _G.CustomGroups[groupName][item] = true end
    WindUI:Notify({Title="Saved!", Content="Created '" .. groupName .. "' with " .. count .. " items.", Duration=3})
    _G.GroupBuilderUI.Visible = false
end)

_G.RefreshGroupBuilder = function()
    for _, child in ipairs(GBScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    SelectedForGroup = {}
    local addedAny = false
    for name, data in pairs(_G.LullabyRegistry) do
        if data.State == "Item" then
            addedAny = true
            local btn = Instance.new("TextButton", GBScroll)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            btn.Text = name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 11
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                if SelectedForGroup[name] then
                    SelectedForGroup[name] = nil
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                else
                    SelectedForGroup[name] = true
                    btn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
                end
            end)
        end
    end
    if not addedAny then
        local lbl = Instance.new("TextLabel", GBScroll)
        lbl.Size = UDim2.new(1, 0, 0, 30)
        lbl.BackgroundTransparency = 1
        lbl.Text = "No items marked as Orange in Debug yet!"
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
    end
    GBScroll.CanvasSize = UDim2.new(0, 0, 0, GBLayout.AbsoluteContentSize.Y + 10)
end

-- UNIVERSAL SELECTOR UI
_G.SelectorUI = Instance.new("Frame", RadarScreen)
_G.SelectorUI.Size = UDim2.new(0, 240, 0, 360)
_G.SelectorUI.Position = UDim2.new(0.5, -120, 0.5, -180)
_G.SelectorUI.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
_G.SelectorUI.Visible = false
_G.SelectorUI.Active = true
_G.SelectorUI.Draggable = true
Instance.new("UICorner", _G.SelectorUI).CornerRadius = UDim.new(0, 6)

local SelTitle = Instance.new("TextLabel", _G.SelectorUI)
SelTitle.Size = UDim2.new(1, 0, 0, 30)
SelTitle.BackgroundTransparency = 1
SelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SelTitle.Font = Enum.Font.GothamBold
SelTitle.TextSize = 14

local SelClose = Instance.new("TextButton", _G.SelectorUI)
SelClose.Size = UDim2.new(0, 30, 0, 30)
SelClose.Position = UDim2.new(1, -30, 0, 0)
SelClose.BackgroundTransparency = 1
SelClose.Text = "X"
SelClose.TextColor3 = Color3.fromRGB(255, 50, 50)
SelClose.Font = Enum.Font.GothamBold
SelClose.TextSize = 14
SelClose.MouseButton1Click:Connect(function() _G.SelectorUI.Visible = false end)

local SelSearch = Instance.new("TextBox", _G.SelectorUI)
SelSearch.Size = UDim2.new(1, -10, 0, 30)
SelSearch.Position = UDim2.new(0, 5, 0, 35)
SelSearch.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SelSearch.TextColor3 = Color3.fromRGB(255, 255, 255)
SelSearch.PlaceholderText = "Search..."
SelSearch.Font = Enum.Font.Gotham
SelSearch.TextSize = 12
Instance.new("UICorner", SelSearch).CornerRadius = UDim.new(0, 4)

local SelScroll = Instance.new("ScrollingFrame", _G.SelectorUI)
SelScroll.Size = UDim2.new(1, -10, 1, -75)
SelScroll.Position = UDim2.new(0, 5, 0, 70)
SelScroll.BackgroundTransparency = 1
SelScroll.ScrollBarThickness = 4
local SelLayout = Instance.new("UIListLayout", SelScroll)
SelLayout.Padding = UDim.new(0, 4)

local SelectorButtonCache = {}
_G.CurrentSelectorMode = nil

_G.OpenSelectorUI = function(mode)
    _G.CurrentSelectorMode = mode
    _G.SelectorUI.Visible = true
    SelTitle.Text = mode == "Player" and " Select Player" or " Select Magnet Target"
end

task.spawn(function()
    while true do
        task.wait(1)
        if _G.SelectorUI and _G.SelectorUI.Visible and _G.CurrentSelectorMode then
            local filter = string.lower(SelSearch.Text or "")
            local activeNames = {}
            
            if _G.CurrentSelectorMode == "Player" then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and (filter == "" or string.find(string.lower(p.Name), filter)) then
                        activeNames[p.Name] = true
                    end
                end
            elseif _G.CurrentSelectorMode == "Magnet" then
                if filter == "" or string.find(string.lower("ALL ITEMS"), filter) then activeNames["ALL ITEMS"] = true end
                for gName, _ in pairs(_G.CustomGroups) do
                    local fName = "[Group] " .. gName
                    if filter == "" or string.find(string.lower(fName), filter) then activeNames[fName] = true end
                end
                for name, data in pairs(_G.LullabyRegistry) do
                    if data.State == "Item" and (filter == "" or string.find(string.lower(name), filter)) then
                        activeNames[name] = true
                    end
                end
            end

            for name, _ in pairs(activeNames) do
                if not SelectorButtonCache[name] then
                    local btn = Instance.new("TextButton", SelScroll)
                    btn.Size = UDim2.new(1, 0, 0, 30)
                    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                    btn.Text = name
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Font = Enum.Font.GothamSemibold
                    btn.TextSize = 11
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                    
                    btn.MouseButton1Click:Connect(function() 
                        if _G.CurrentSelectorMode == "Player" then
                            TeleportConfig.TargetPlayer = name
                            if _G.ActivePlayerDisplay then _G.ActivePlayerDisplay:SetDesc(name) end
                        elseif _G.CurrentSelectorMode == "Magnet" then
                            TeleportConfig.MagnetTargetGroup = name
                            if _G.ActiveMagnetDisplay then _G.ActiveMagnetDisplay:SetDesc(name) end
                        end
                        _G.SelectorUI.Visible = false 
                    end)
                    SelectorButtonCache[name] = btn
                end
                SelectorButtonCache[name].Visible = true
            end

            for name, btn in pairs(SelectorButtonCache) do
                if not activeNames[name] then btn.Visible = false end
            end
            SelScroll.CanvasSize = UDim2.new(0, 0, 0, SelLayout.AbsoluteContentSize.Y + 10)
        end
    end
end)

-- ==============================================================================
-- 5. BROAD SCANNER REGISTRY SYSTEM
-- ==============================================================================
local function autoClassify(name)
    local lName = string.lower(name)
    if string.find(lName, "bot") or string.find(lName, "enemy") or string.find(lName, "worm") or string.find(lName, "monster") then return "MCP" end
    if string.find(lName, "banana") or string.find(lName, "item") or string.find(lName, "trap") or string.find(lName, "trigger") or string.find(lName, "coin") then return "Item" end
    return "None"
end

local function registerEntity(obj, isPlayer)
    if not obj or obj == LocalPlayer.Character then return end
    local name = obj.Name
    if not _G.LullabyRegistry[name] then
        _G.LullabyRegistry[name] = { DisplayName = name, State = isPlayer and "ESP" or autoClassify(name), Instances = {}, IsPlayer = isPlayer }
    end
    local entry = _G.LullabyRegistry[name]
    local exists = false
    for _, inst in ipairs(entry.Instances) do if inst == obj then exists = true end end
    if not exists then table.insert(entry.Instances, obj) end
end

task.spawn(function()
    while true do
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        for _, p in ipairs(Players:GetPlayers()) do if p.Character then registerEntity(p.Character, true) end end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj == LocalPlayer.Character or obj:IsDescendantOf(LocalPlayer.Character) then continue end
            local isEntity = false
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then isEntity = true end
            if obj:IsA("BasePart") and (obj:FindFirstChildOfClass("TouchTransmitter") or obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildOfClass("ClickDetector")) then isEntity = true end
            if obj:IsA("Tool") then isEntity = true end
            
            if isEntity then
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do if p.Character == obj then isPlayer = true end end
                if not isPlayer then
                    if myRoot then
                        local targetPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position) or obj.Position
                        if (targetPos - myRoot.Position).Magnitude <= 1000 then registerEntity(obj, false) end
                    else
                        registerEntity(obj, false) 
                    end
                end
            end
        end
        task.wait(2) 
    end
end)

-- ==============================================================================
-- 6. BACKGROUND WORKERS (NOCLIP, MAGNET & EXPLOITS)
-- ==============================================================================
-- True Physics-Step Noclip
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local doNoclip = MagicConfig.NoclipWall or MagicConfig.NoclipEverything or MagicConfig.WallNoclip
        if doNoclip then
            local bypassLand = MagicConfig.BypassLand or MagicConfig.NoclipEverything
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if bypassLand then
                        part.CanCollide = false
                    else
                        local ray = Ray.new(part.Position, Vector3.new(0, -3, 0))
                        local hit = workspace:FindPartOnRay(ray, char)
                        if hit then part.CanCollide = true else part.CanCollide = false end
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")

    if MagicConfig.JumpEnabled and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.UseJumpPower = true
            hum.JumpPower = MagicConfig.Jump 
        end
    end

    if MagicConfig.Invisibility and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then 
                part.Transparency = 1 
                part.LocalTransparencyModifier = 1
            elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
                part.Handle.Transparency = 1
                part.Handle.LocalTransparencyModifier = 1
            end
        end
    end

    if TeleportConfig.MagnetActive then
        local destCFrame = nil
        if TeleportConfig.MagnetMode == "Me" and myRoot then
            destCFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
        else
            destCFrame = TeleportConfig.MagnetStaticPos
        end

        if destCFrame then
            local target = TeleportConfig.MagnetTargetGroup
            local isCustomGroup = string.sub(target, 1, 8) == "[Group] "
            local groupName = isCustomGroup and string.sub(target, 9) or nil

            for name, data in pairs(_G.LullabyRegistry) do
                if data.State == "Item" then
                    local shouldTP = false
                    if target == "ALL ITEMS" then shouldTP = true
                    elseif isCustomGroup and _G.CustomGroups[groupName] and _G.CustomGroups[groupName][name] then shouldTP = true
                    elseif target == name then shouldTP = true end

                    if shouldTP then
                        for _, inst in ipairs(data.Instances) do
                            if inst and inst.Parent then
                                if inst:IsA("Model") then
                                    for _, p in ipairs(inst:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false; p.AssemblyLinearVelocity = Vector3.zero end end
                                    inst:PivotTo(destCFrame)
                                elseif inst:IsA("BasePart") then
                                    inst.CanCollide = false
                                    inst.AssemblyLinearVelocity = Vector3.zero
                                    inst.CFrame = destCFrame
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if MagicConfig.ItemImmunity then
        for name, data in pairs(_G.LullabyRegistry) do
            if data.State == "Item" then
                for _, inst in ipairs(data.Instances) do
                    if inst and inst.Parent then
                        for _, desc in ipairs(inst:GetDescendants()) do if desc:IsA("BasePart") then desc.CanTouch = false end end
                        if inst:IsA("BasePart") then inst.CanTouch = false end
                    end
                end
            end
        end
    end

    if MagicConfig.UnlimitedItems or MagicConfig.InstantCooldown then
        local containers = {LocalPlayer:FindFirstChildOfClass("Backpack"), char}
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
    end

    if MagicConfig.InfiniteEnergy and char then
        pcall(function()
            for _, val in ipairs(char:GetDescendants()) do
                local n = string.lower(val.Name)
                if (val:IsA("NumberValue") or val:IsA("IntValue")) and (string.find(n, "stamina") or string.find(n, "energy") or string.find(n, "power") or string.find(n, "exhaust")) then val.Value = 100 end
            end
        end)
    end
end)

-- ==============================================================================
-- 7. RENDER: ESP, AIMBOT & FLY ENGINE
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

local TargetAdornment = Instance.new("BoxHandleAdornment", RadarScreen)
TargetAdornment.Name = "AimbotTargetBox"
TargetAdornment.AlwaysOnTop = true
TargetAdornment.ZIndex = 10
TargetAdornment.Transparency = 0.3
TargetAdornment.Color3 = Color3.new(1, 0, 0)
TargetAdornment.Visible = false

local LinesCache, BoxesCache, RadarBlips = {}, {}, {}
local bgBodyVel, bgBodyGyro = nil, nil
local R15_Conns = { {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"} }
local R6_Conns = { {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"} }

local function getLine(index)
    local line = LinesCache[index]
    if not line then
        line = Instance.new("Frame", RadarScreen)
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BorderSizePixel = 0
        LinesCache[index] = line
    end
    return line
end

local function getBox(index)
    local box = BoxesCache[index]
    if not box then
        box = Instance.new("Frame", RadarScreen)
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        local stroke = Instance.new("UIStroke", box)
        stroke.Name = "Outline"
        stroke.Thickness = 1.5
        BoxesCache[index] = box
    end
    return box
end

local function isVisible(targetPart, char)
    if not AimConfig.VisCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, dir, params)
    return result == nil
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    
    if myRoot and MagicConfig.SpeedEnabled and not MagicConfig.Fly then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if MagicConfig.Speed > 0 and hum and hum.MoveDirection.Magnitude > 0 then
            myRoot.CFrame = myRoot.CFrame + (hum.MoveDirection * MagicConfig.Speed)
        end
    end

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
        if frame.Name ~= "Frame" and frame.Name ~= "LullabyRadarNative" and frame.Name ~= "AimbotTargetBox" then frame.Visible = false end 
    end
    for _, line in pairs(LinesCache) do line.Visible = false end
    for _, box in pairs(BoxesCache) do box.Visible = false end
    for _, blip in ipairs(RadarBlips) do blip.Visible = false end
    TargetAdornment.Visible = false
    
    if _G.FOVCircle then
        _G.FOVCircle.Size = UDim2.new(0, AimConfig.FOV_Size * 2, 0, AimConfig.FOV_Size * 2)
        _G.FOVCircle.Visible = AimConfig.ShowFOV
    end

    local lineIndex, boxIndex, blipIndex = 1, 1, 1
    local closestTargetPart = nil
    local shortestDistance = AimConfig.FOV_Size
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

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

    for name, data in pairs(_G.LullabyRegistry) do
        local categoryConfig = nil
        if data.State == "ESP" then categoryConfig = ESPConfig.Player
        elseif data.State == "MCP" then categoryConfig = ESPConfig.MCP
        elseif data.State == "Item" then categoryConfig = ESPConfig.Item
        end

        local isVisible = categoryConfig and categoryConfig.Enabled
        local defaultColor = (data.State == "ESP" and Colors.ESP) or (data.State == "MCP" and Colors.MCP) or Colors.Item

        for i = #data.Instances, 1, -1 do
            local inst = data.Instances[i]
            if not inst or not inst.Parent then 
                table.remove(data.Instances, i) 
            else
                local hl = inst:FindFirstChild("LullabyHighlight")
                local bb = inst:FindFirstChild("LullabyBillboard")
                
                local targetAimPart = nil
                if inst:IsA("Model") then
                    if AimConfig.TargetPart == "Head" then targetAimPart = inst:FindFirstChild("Head")
                    elseif AimConfig.TargetPart == "Torso" then targetAimPart = inst:FindFirstChild("HumanoidRootPart") or inst:FindFirstChild("Torso") or inst:FindFirstChild("UpperTorso")
                    elseif AimConfig.TargetPart == "Legs" then targetAimPart = inst:FindFirstChild("RightLowerLeg") or inst:FindFirstChild("Right Leg") or inst.PrimaryPart
                    end
                else
                    targetAimPart = inst
                end

                local isAimbotTarget = false
                if AimConfig.Enabled and targetAimPart and char then
                    local validTargetType = (data.State == "ESP" and AimConfig.TargetPlayers) or (data.State == "MCP" and AimConfig.TargetMCP)
                    if validTargetType then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetAimPart.Position)
                        if onScreen then
                            local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if distToCenter < shortestDistance then
                                if isVisible == false or isVisible(targetAimPart, char) then
                                    shortestDistance = distToCenter
                                    closestTargetPart = targetAimPart
                                end
                            end
                        end
                    end
                end

                if closestTargetPart and closestTargetPart:IsDescendantOf(inst) then
                    isAimbotTarget = true
                end

                local renderColor = defaultColor
                if isAimbotTarget and AimConfig.LockHighlight then
                    renderColor = Color3.fromRGB(0, 255, 0)
                    TargetAdornment.Adornee = closestTargetPart
                    TargetAdornment.Size = closestTargetPart.Size * 1.1
                    TargetAdornment.Visible = AimConfig.ProjectileBox
                end

                if isVisible then
                    if categoryConfig.Glow then
                        if not hl then
                            hl = Instance.new("Highlight", inst)
                            hl.Name = "LullabyHighlight"
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0.2
                        end
                        hl.Enabled = true
                        hl.FillColor = renderColor
                        hl.OutlineColor = renderColor
                    elseif hl then hl.Enabled = false end

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
                            local distStr = ""
                            if categoryConfig.Distance and myRoot then
                                local rootPos = inst:IsA("Model") and (inst.PrimaryPart and inst.PrimaryPart.Position or inst:GetPivot().Position) or inst.Position
                                distStr = " [" .. math.floor((rootPos - myRoot.Position).Magnitude) .. "m]"
                            end
                            lbl.Text = name .. distStr
                            lbl.TextColor3 = renderColor
                            lbl.Visible = true
                        elseif lbl then lbl.Visible = false end
                        
                        if categoryConfig.Health and hpBg then
                            hpBg.Visible = true
                            local hum = inst:FindFirstChildOfClass("Humanoid")
                            if hum then hpBg:FindFirstChild("HPFill").Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0) end
                        elseif hpBg then hpBg.Visible = false end
                    elseif bb then bb.Enabled = false end

                    local rootPart = inst:IsA("Model") and (inst:FindFirstChild("HumanoidRootPart") or inst.PrimaryPart) or (inst:IsA("BasePart") and inst)
                    if rootPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        if onScreen then
                            if categoryConfig.Tracer then
                                local line = getLine(lineIndex); lineIndex = lineIndex + 1
                                drawLine(line, Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y), Vector2.new(screenPos.X, screenPos.Y), renderColor, 1.5)
                            end
                            
                            if categoryConfig.Box and inst:IsA("Model") then
                                local topPos = rootPart.Position + Vector3.new(0, 3, 0)
                                local botPos = rootPart.Position - Vector3.new(0, 3.5, 0)
                                local top2D, on1 = Camera:WorldToViewportPoint(topPos)
                                local bot2D, on2 = Camera:WorldToViewportPoint(botPos)
                                if on1 and on2 then
                                    local height = math.abs(bot2D.Y - top2D.Y)
                                    local width = height * 0.6
                                    local box = getBox(boxIndex); boxIndex = boxIndex + 1
                                    box.Position = UDim2.new(0, top2D.X - width/2, 0, top2D.Y)
                                    box.Size = UDim2.new(0, width, 0, height)
                                    box:FindFirstChild("Outline").Color = renderColor
                                    box.Visible = true
                                end
                            end

                            if categoryConfig.Skeleton and inst:IsA("Model") then
                                local conns = inst:FindFirstChild("UpperTorso") and R15_Conns or (inst:FindFirstChild("Torso") and R6_Conns or nil)
                                if conns then
                                    for _, conn in ipairs(conns) do
                                        local p1, p2 = inst:FindFirstChild(conn[1]), inst:FindFirstChild(conn[2])
                                        if p1 and p2 then
                                            local s1, on1 = Camera:WorldToViewportPoint(p1.Position)
                                            local s2, on2 = Camera:WorldToViewportPoint(p2.Position)
                                            if on1 and on2 then 
                                                local line = getLine(lineIndex); lineIndex = lineIndex + 1
                                                drawLine(line, Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y), renderColor, 1.5) 
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if RadarConfig.Enabled and myRoot then
                            local offset = rootPart.Position - myRoot.Position
                            if offset.Magnitude <= 142 then
                                local blip = getBlip()
                                blip.Position = UDim2.new(0.5, (offset.X / 1.5) - 3, 0.5, (offset.Z / 1.5) - 3)
                                blip.BackgroundColor3 = renderColor
                                blip.Visible = true
                                local lbl = blip:FindFirstChild("DataLabel")
                                if lbl then
                                    if RadarConfig.ShowXYZ then
                                        lbl.Text = string.format("%dm (Y:%d)", math.floor(offset.Magnitude), math.floor(offset.Y))
                                        lbl.TextColor3 = renderColor
                                        lbl.Visible = true
                                    else
                                        lbl.Visible = false
                                    end
                                end
                            end
                        end
                    end
                else
                    if hl then hl.Enabled = false end
                    if bb then bb.Enabled = false end
                end
            end
        end
    end

    if AimConfig.Enabled and closestTargetPart then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local lerpFactor = AimConfig.Smoothness * AimConfig.Speed
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closestTargetPart.Position), lerpFactor)
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if MagicConfig.AirJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if hum and root then 
            hum:ChangeState(Enum.HumanoidStateType.Jumping) 
            root.Velocity = Vector3.new(root.Velocity.X, hum.UseJumpPower and hum.JumpPower or 50, root.Velocity.Z)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if MagicConfig.GodMode then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Name = "NonTarget" end
    end
    if MagicConfig.ClickTP then
        local tpTool = Instance.new("Tool", LocalPlayer:WaitForChild("Backpack"))
        tpTool.Name = "✨ Teleport"
        tpTool.RequiresHandle = false
        tpTool.Activated:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    end
end)

print("🚀 [Lullaby] WindUI v18.4 Executed Successfully!")
