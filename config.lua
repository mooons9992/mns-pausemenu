Config = {}

-- [[ Framework Settings ]] --
-- Since we're only supporting QBCore now, this is fixed
Config.Framework = 'qbcore'

-- [[ Core Object ]] --
-- This allows the script to get the core object without exposing it globally
Config.GetCoreObject = function()
    return exports['qb-core']:GetCoreObject()
end

-- [[ Discord Bot Token ]] --
-- This is required for image fetching from Discord API.
-- You can create a bot at https://discord.com/developers/applications
-- It's not needed to join the bot to your server, you just need the token.
Config.BotToken = '' -- Optional

-- [[ Performance Settings ]] --
Config.PauseMenuTick = 5 -- Tick rate for checking pause menu state (ms)
Config.LowResMode = false -- Enable for lower resource usage on busy servers
Config.CachePlayerData = true -- Cache player data to reduce database calls
Config.CacheTime = 60000 -- How long to cache player data (ms)

-- [[ Commands and Keybinds ]] --
Config.Commands = {
    enable = true,
    primary = 'pausemenu',
    aliases = {'pmenu', 'pscreen'} -- Alternative commands
}
Config.Keybinds = {
    enable = true,
    primary = 'ESCAPE',
    secondary = 'P', -- Alternative keybind
    description = 'Open Pause Menu'
}

-- [[ UI Settings ]] --
Config.UI = {
    theme = 'dark', -- 'dark' or 'light'
    accentColor = '#4F7CAC', -- Primary color
    logo = 'https://your-server-logo.com/logo.png', -- Server logo URL
    backgroundImage = nil, -- Set to image URL for custom background
    blurBackground = true, -- Blur game background when menu is open
    fadeTime = 300, -- Transition time in ms
    scale = 1.0, -- UI scale factor (0.8-1.2 recommended)
    useGameFont = false -- Use game font instead of web font
}

-- [[ Server Branding ]] --
Config.ServerInfo = {
    name = 'Your Server Name',
    description = 'Welcome to our server! Enjoy your stay.',
    rules = 'https://your-server.com/rules',
    discord = 'https://discord.gg/yourserver',
    website = 'https://your-server.com',
    maxPlayers = 64,
    showOnlinePlayers = true, -- Show online player count
    showServerUptime = true -- Show how long server has been running
}

-- [[ Menu Features ]] --
Config.Features = {
    playerStats = true, -- Show player statistics
    jobInfo = true, -- Show job information
    gang = true, -- Show gang information
    settings = true, -- Show settings tab
    adminPanel = true, -- Show admin panel for staff
    mapBlips = true, -- Show custom map blips
    quickSettings = true, -- Show quick settings (voice, etc)
    customButtons = true -- Enable custom buttons
}

-- [[ Admin Settings ]] --
Config.Admin = {
    enabled = true,
    acePermission = 'mns.admin', -- ACE permission for admin access
    requiredPermissionLevel = 1, -- Minimum staff level in QBCore
    features = {
        playerList = true, -- Show online players
        teleport = true, -- Teleport options
        weather = true, -- Weather control
        announcement = true, -- Server announcements
        quickActions = true -- Common admin actions
    }
}

-- [[ Custom Buttons ]] --
-- These buttons can be configured to run specific functions
Config.CustomButtons = {
    {
        label = "Change Character",
        description = "Switch to another character",
        icon = "fa-solid fa-user-group",
        action = "changeCharacter"
    },
    {
        label = "Inventory",
        description = "Open your inventory",
        icon = "fa-solid fa-briefcase",
        action = "openInventory"
    },
    {
        label = "Report Bug",
        description = "Report a bug to administrators",
        icon = "fa-solid fa-bug",
        action = "reportBug"
    }
}

-- [[ Button Actions ]] --
Config.ButtonActions = {
    exitServer = function(source)
        DropPlayer(source, 'You have left the server.')
    end,
    changeCharacter = function(source)
        -- Change character logic here
        TriggerClientEvent('qb-multicharacter:client:chooseChar', source)
    end,
    openInventory = function(source)
        TriggerClientEvent('inventory:client:OpenInventory', source)
    end,
    reportBug = function(source)
        -- Add your bug report logic here
    end
}

-- [[ SERVER-SIDE FUNCTIONS ]] --
-- Getting Job data - Optimized for QBCore
Config.GetJob = function(source)
    local Player = Config.GetCoreObject().Functions.GetPlayer(source)
    if not Player then return 'Unknown' end
    
    local jobInfo = Player.PlayerData.job
    if not jobInfo then return 'Unemployed' end
    
    return jobInfo.label .. ' - ' .. jobInfo.grade.name
end

-- Gang function for QBCore
Config.GetGang = function(source)
    local Player = Config.GetCoreObject().Functions.GetPlayer(source)
    if not Player or not Player.PlayerData.gang then return 'None' end
    
    local gangInfo = Player.PlayerData.gang
    return gangInfo.label .. ' - ' .. gangInfo.grade.name
end

-- Player metadata getter
Config.GetPlayerMetadata = function(source, key)
    local Player = Config.GetCoreObject().Functions.GetPlayer(source)
    if not Player or not Player.PlayerData.metadata[key] then return nil end
    
    return Player.PlayerData.metadata[key]
end

-- Get player identifier (citizenid for QBCore)
Config.GetPlayerIdentifier = function(source)
    local Player = Config.GetCoreObject().Functions.GetPlayer(source)
    if not Player then return nil end
    
    return Player.PlayerData.citizenid
end

-- Get player name (formatted)
Config.GetPlayerName = function(source)
    local Player = Config.GetCoreObject().Functions.GetPlayer(source)
    if not Player then return "Unknown Player" end
    
    return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
end

-- Get player money (all accounts)
Config.GetPlayerMoney = function(source)
    local Player = Config.GetCoreObject().Functions.GetPlayer(source)
    if not Player then return {cash = 0, bank = 0, crypto = 0} end
    
    return {
        cash = Player.PlayerData.money.cash,
        bank = Player.PlayerData.money.bank,
        crypto = Player.PlayerData.money.crypto
    }
end

-- Check if player is admin
Config.IsPlayerAdmin = function(source)
    local Player = Config.GetCoreObject().Functions.GetPlayer(source)
    if not Player then return false end
    
    local playerPerm = Player.PlayerData.permission
    if playerPerm == "admin" or playerPerm == "god" then return true end
    
    -- Also check ACE permissions
    if IsPlayerAceAllowed(source, Config.Admin.acePermission) then return true end
    
    return false
end

-- Get player stats (hunger, thirst, stress)
Config.GetPlayerStats = function(source)
    local Player = Config.GetCoreObject().Functions.GetPlayer(source)
    if not Player then return {hunger = 100, thirst = 100, stress = 0} end
    
    local metadata = Player.PlayerData.metadata
    
    return {
        hunger = metadata.hunger,
        thirst = metadata.thirst,
        stress = metadata.stress
    }
end

-- [[ SHARED FUNCTIONS (Available to client) ]] --
Config.SharedFunctions = {
    FormatNumber = function(number)
        local formatted = number
        while true do  
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then break end
        end
        return formatted
    end,
    
    FormatTime = function(seconds)
        if seconds <= 0 then return "00:00:00" end
        
        local hours = string.format("%02.f", math.floor(seconds/3600))
        local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
        local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins*60))
        
        return hours..":"..mins..":"..secs
    end
}
