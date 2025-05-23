-- Client-side configuration
Config.Client = {
    -- UI Elements
    UI = {
        disableControlsWhileOpen = true, -- Disable game controls when menu is open
        disableHudWhileOpen = true, -- Hide game HUD when menu is open
        allowMouse = true, -- Enable mouse controls
        showHotkeys = true, -- Show keyboard shortcuts in the menu
        sounds = true -- Enable UI sounds
    },
    
    -- Performance options
    Performance = {
        reduceGameFPS = false, -- Reduce game FPS while menu is open to save resources
        unloadWorldWhileOpen = false, -- Unload world entities when menu is open (improves performance)
        lowQualityMode = false -- Simplified UI for low-end PCs
    },
    
    -- Client-side callbacks
    Callbacks = {
        -- Pre-open menu callback
        beforeOpen = function()
            -- Do something before menu opens
            return true -- Return false to prevent opening
        end,
        
        -- Post-close menu callback
        afterClose = function()
            -- Do something after menu closes
        end
    },
    
    -- Player stat display settings
    PlayerStats = {
        showMoney = true,
        showBank = true,
        showJob = true,
        showGang = true,
        showID = true,
        showIcons = true,
        moneySymbol = '$'
    },
    
    -- Key mapping options
    KeyBinds = {
        openMenu = {
            key = 'ESCAPE',
            modifier = nil -- Modifier key, e.g. 'LALT'
        },
        closeMenu = {
            key = 'ESCAPE',
            modifier = nil
        },
        quickExit = {
            key = 'BACKSPACE',
            modifier = nil
        }
    },
    
    -- NUI Settings
    NUI = {
        focusOnOpen = true, -- Set NUI focus when menu opens
        cursorOnOpen = true, -- Show cursor when menu opens
        escapeClosesMenu = true, -- Pressing ESC closes the menu
    }
}

-- Custom client-side menu tabs (can be dynamically loaded)
Config.CustomTabs = {
    {
        id = "server_info",
        label = "Server Info",
        icon = "fas fa-server",
        order = 1,
        restricted = false, -- Not restricted to any permission
        content = {
            type = "info", -- Type of content (info, stats, buttons, custom)
            title = "Server Information",
            description = Config.ServerInfo.description,
            items = {
                {label = "Discord", value = Config.ServerInfo.discord, isLink = true},
                {label = "Website", value = Config.ServerInfo.website, isLink = true},
                {label = "Rules", value = Config.ServerInfo.rules, isLink = true}
            }
        }
    },
    {
        id = "player_stats",
        label = "My Character",
        icon = "fas fa-user",
        order = 2,
        restricted = false,
        content = {
            type = "stats",
            title = "Character Statistics",
            stats = {"money", "job", "gang", "hunger", "thirst", "stress"}
        }
    },
    {
        id = "settings",
        label = "Settings",
        icon = "fas fa-cog",
        order = 3,
        restricted = false,
        content = {
            type = "settings",
            title = "Game Settings",
            settings = {"voice", "hud", "notifications", "keybinds", "graphics"}
        }
    }
}

-- Add this to make ESX users aware of QBCore-only support
if GetResourceState('es_extended') ~= 'missing' then
    print('^1WARNING: mns-pausemenu is now QBCore-only. ESX support has been removed.^7')
end