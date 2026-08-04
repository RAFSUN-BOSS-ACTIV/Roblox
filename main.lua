-- ==============================================================================
-- LULLABY v14.1 - GITHUB MASTER LOADER (ANTI-CRASH)
-- ==============================================================================
print("⏳ [Lullaby] Waiting for game to load...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

_G.LullabyRegistry = _G.LullabyRegistry or {} 
_G.RefreshUILists = _G.RefreshUILists or function() end 

local uiSuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not uiSuccess or type(WindUI) ~= "table" then
    warn("❌ [Lullaby FATAL ERROR] WindUI failed to load from Github!")
    return
end

WindUI:SetNotificationLower(true)

local Window = WindUI:CreateWindow({
    Title = "⚡ Lullaby Modular",
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
-- ASYNC MODULE DOWNLOADER (GITHUB SETUP)
-- ==============================================================================
local baseUrl = "https://raw.githubusercontent.com/RAFSUN-BOSS-ACTIV/Roblox/refs/heads/main/"

local modulesToLoad = {
    { Name = "Aimbot",        Url = baseUrl .. "Aimbot/aimbot.lua",       Tab = TabAimbot },
    { Name = "ESP Visuals",   Url = baseUrl .. "ESP/esp.lua",             Tab = TabESP },
    { Name = "Debug Roadmap", Url = baseUrl .. "Debug/debug.lua",         Tab = TabDebug },
    { Name = "Magic Core",    Url = baseUrl .. "Magic/magic.lua",         Tab = TabMagic },
    { Name = "God Mode",      Url = baseUrl .. "Magic/godmode.lua",       Tab = TabMagic },
    { Name = "Trap Immunity", Url = baseUrl .. "Magic/trap_immunity.lua", Tab = TabMagic },
    { Name = "Invisibility",  Url = baseUrl .. "Magic/invisible.lua",     Tab = TabMagic },
    { Name = "Teleport",      Url = baseUrl .. "Teleport/teleport.lua",   Tab = TabTeleport }
}

task.spawn(function()
    -- Load Config First
    local configSuccess, configErr = pcall(function() loadstring(game:HttpGet(baseUrl .. "Core/Config.lua"))() end)
    if not configSuccess then warn("❌ [Lullaby] Failed to load Core/Config.lua: " .. tostring(configErr)) end

    for _, mod in ipairs(modulesToLoad) do
        local success, result = pcall(function() return loadstring(game:HttpGet(mod.Url))() end)
        
        if success and type(result) == "table" then
            local initSuccess, initError = pcall(function() result:Init(mod.Tab) end)
            if not initSuccess then
                mod.Tab:Section({ Title = "⚠️ Error initializing " .. mod.Name })
                warn("❌ [Lullaby] " .. mod.Name .. " Init Error: " .. tostring(initError))
            end
        else
            mod.Tab:Section({ Title = "⚠️ Download Failed: " .. mod.Name })
        end
        task.wait(0.2) 
    end
end)
