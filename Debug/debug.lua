local DebugModule = {}

function DebugModule:Init(Tab)
    Tab:Section({ Title = "Debug Roadmap Controls" })
    
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

    Tab:Toggle({ Title = "Enable ESP Processing", Value = true, Callback = function(v) end })
    
    espDropdown = Tab:Dropdown({
        Title = "ESP List", Values = {"None"}, Value = "None",
        Callback = function(Option) end
    })
    
    Tab:Button({
        Title = "Set Selected to ESP (Green)",
        Callback = function()
            local opt = espDropdown.Value
            if opt and _G.LullabyRegistry[opt] then
                _G.LullabyRegistry[opt].State = "ESP"
                refreshDropdowns()
            end
        end
    })
    Tab:Button({
        Title = "Turn OFF ESP (Send to MCP/Items)",
        Callback = function()
            local opt = espDropdown.Value
            if opt and _G.LullabyRegistry[opt] then
                _G.LullabyRegistry[opt].State = "None"
                refreshDropdowns()
            end
        end
    })

    Tab:Section({ Title = "MCP Server (Bots)" })
    Tab:Toggle({ Title = "Enable MCP Rendering", Value = true, Callback = function(v) end })
    
    mcpDropdown = Tab:Dropdown({
        Title = "MCP List", Values = {"None"}, Value = "None",
        Callback = function(Option) end
    })
    
    Tab:Button({
        Title = "Set Selected to MCP (Red Bot)",
        Callback = function()
            local opt = mcpDropdown.Value
            if opt and _G.LullabyRegistry[opt] then
                _G.LullabyRegistry[opt].State = "MCP"
                refreshDropdowns()
            end
        end
    })

    Tab:Section({ Title = "Item Entities" })
    Tab:Toggle({ Title = "Enable Item Rendering", Value = true, Callback = function(v) end })
    
    itemDropdown = Tab:Dropdown({
        Title = "Item List", Values = {"None"}, Value = "None",
        Callback = function(Option) end
    })
    
    Tab:Button({
        Title = "Set Selected to Item (Orange)",
        Callback = function()
            local opt = itemDropdown.Value
            if opt and _G.LullabyRegistry[opt] then
                _G.LullabyRegistry[opt].State = "Item"
                refreshDropdowns()
            end
        end
    })
end

return DebugModule
