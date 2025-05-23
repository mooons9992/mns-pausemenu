ESX = Config.Framework == 'esx' and exports['es_extended']:getSharedObject() or nil
QBCore = Config.Framework == 'qbcore' and exports['qb-core']:GetCoreObject() or nil

if ESX == nil and QBCore == nil then
  print('^1[ERROR]^1: Framework not set or not found. Please check your config.lua file. Current Config.Framework: ' .. tostring(Config.Framework) .. '^7')
end

-- QBCore specific pause menu server script
local QBCore = Config.GetCoreObject()

-- Player data cache to improve performance
local playerDataCache = {}
local uptimeStart = os.time()

-- Validate QBCore is loaded
if QBCore == nil then
    print('^1[ERROR]: QBCore not found. Please ensure qb-core is started before mns-pausemenu.^7')
    return
end

-- Log script startup
print('^2[mns-pausemenu]: Server script initialized. QBCore detected.^7')

-- Callback to get player data for the pause menu
lib.callback.register('mns-pausemenu:GetPlayerData', function(source)
    -- Check cache first if enabled
    if Config.CachePlayerData and playerDataCache[source] and 
       (os.time() - playerDataCache[source].timestamp) < (Config.CacheTime / 1000) then
        if Config.Debug then
            print('^3[mns-pausemenu]: Returning cached data for player ' .. source .. '^7')
        end
        return playerDataCache[source].data
    end
    
    -- Get player from QBCore
    local player = QBCore.Functions.GetPlayer(source)
    if not player then 
        return {
            playerJob = 'Unemployed',
            playerName = 'Unknown Player',
            citizenId = 'Unknown',
            onlinePlayers = #QBCore.Functions.GetPlayers(),
            isAdmin = false,
            stats = { hunger = 100, thirst = 100, stress = 0 },
            money = { cash = 0, bank = 0, crypto = 0 },
            uptime = os.difftime(os.time(), uptimeStart)
        }
    end
    
    -- Build player data object
    local playerData = {
        playerJob = Config.GetJob and Config.GetJob(source) or player.PlayerData.job.label .. ' - ' .. player.PlayerData.job.grade.name,
        playerGang = Config.GetGang and Config.GetGang(source) or (player.PlayerData.gang and (player.PlayerData.gang.label .. ' - ' .. player.PlayerData.gang.grade.name) or 'None'),
        playerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
        citizenId = player.PlayerData.citizenid,
        onlinePlayers = #QBCore.Functions.GetPlayers(),
        maxPlayers = Config.ServerInfo.maxPlayers,
        isAdmin = Config.IsPlayerAdmin(source),
        stats = Config.GetPlayerStats(source),
        money = Config.GetPlayerMoney(source),
        uptime = os.difftime(os.time(), uptimeStart)
    }
    
    -- Cache the data if enabled
    if Config.CachePlayerData then
        playerDataCache[source] = {
            data = playerData,
            timestamp = os.time()
        }
    end
    
    return playerData
end)

-- Function to get Discord ID from player identifiers
local function GetDiscordID(source)
    local identifiers = GetPlayerIdentifiers(source)
    local discord = nil

    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, 'discord:') then
            discord = string.gsub(identifier, 'discord:', '')
            break
        end
    end

    return discord
end

-- Function to request Discord user data using Discord API
local function RequestDiscord(discord_id)
    if not Config.BotToken or Config.BotToken == '' then
        return nil
    end
    
    local request_url = 'https://discord.com/api/v10/users/' .. discord_id
    local prom = promise.new()
    
    PerformHttpRequest(request_url, function(statusCode, response, headers)
        if statusCode == 200 and response then
            local data = json.decode(response)
            prom:resolve(data)
        else
            prom:resolve(nil)
        end
    end, 'GET', '', { 
        ['Authorization'] = 'Bot ' .. Config.BotToken 
    })
    
    return Citizen.Await(prom)
end

-- Callback to get Discord avatar
lib.callback.register('mns-pausemenu:GetDiscordAvatar', function(source)
    local discord_id = GetDiscordID(source)
    if not discord_id then return { avatar = nil, discord_id = nil } end
    
    local response = RequestDiscord(discord_id)
    if not response then 
        return { 
            avatar = nil,
            discord_id = discord_id
        }
    end
    
    -- Construct avatar URL if available
    local avatarUrl = nil
    if response.avatar then
        local isAnimated = string.sub(response.avatar, 1, 2) == "a_"
        local extension = isAnimated and ".gif" or ".png"
        avatarUrl = string.format("https://cdn.discordapp.com/avatars/%s/%s%s", discord_id, response.avatar, extension)
    end
    
    return {
        avatar = avatarUrl,
        discord_id = discord_id,
        username = response.username or "Unknown"
    }
end)

-- Quit server event handler
RegisterNetEvent('mns-pausemenu:quitServer')
AddEventHandler('mns-pausemenu:quitServer', function()
    local source = source
    
    -- Use custom exit function from config if available
    if Config.ButtonActions and Config.ButtonActions.exitServer then
        Config.ButtonActions.exitServer(source)
    else
        -- Default behavior
        DropPlayer(source, 'You have left the server.')
    end
end)

-- Get all online players data for admin panel
lib.callback.register('mns-pausemenu:GetOnlinePlayers', function(source)
    -- Check if requester is an admin
    if not Config.IsPlayerAdmin(source) then
        return nil
    end
    
    local players = {}
    for _, playerId in ipairs(QBCore.Functions.GetPlayers()) do
        local player = QBCore.Functions.GetPlayer(tonumber(playerId))
        if player then
            table.insert(players, {
                id = playerId,
                name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
                citizenId = player.PlayerData.citizenid,
                job = player.PlayerData.job.label,
                ping = GetPlayerPing(playerId)
            })
        end
    end
    
    return players
end)

-- Register admin actions
RegisterNetEvent('mns-pausemenu:adminAction')
AddEventHandler('mns-pausemenu:adminAction', function(action, targetId, param)
    local source = source
    
    -- Verify the player is an admin
    if not Config.IsPlayerAdmin(source) then
        return
    end
    
    -- Handle different admin actions
    if action == 'kick' then
        if not targetId then return end
        DropPlayer(targetId, param or 'You have been kicked from the server.')
        
    elseif action == 'teleport' then
        if not targetId then return end
        TriggerClientEvent('mns-pausemenu:teleportTo', source, targetId)
        
    elseif action == 'bring' then
        if not targetId then return end
        TriggerClientEvent('mns-pausemenu:bringPlayer', targetId, source)
        
    elseif action == 'setweather' then
        if not param then return end
        TriggerClientEvent('qb-weathersync:client:setWeather', -1, param)
        
    elseif action == 'announcement' then
        if not param then return end
        TriggerClientEvent('mns-pausemenu:showAnnouncement', -1, param)
    end
end)

-- Clear player cache on disconnect
AddEventHandler('playerDropped', function(reason)
    local source = source
    if playerDataCache[source] then
        playerDataCache[source] = nil
    end
end)

-- Custom command registration
if Config.Commands and Config.Commands.enable then
    QBCore.Commands.Add(Config.Commands.primary, 'Open the pause menu', {}, false, function(source)
        TriggerClientEvent('mns-pausemenu:openMenu', source)
    end)
    
    if Config.Commands.aliases then
        for _, alias in ipairs(Config.Commands.aliases) do
            QBCore.Commands.Add(alias, 'Open the pause menu', {}, false, function(source)
                TriggerClientEvent('mns-pausemenu:openMenu', source)
            end)
        end
    end
end

-- Utility function to convert milliseconds to readable date
function milliseconds_to_date(ms)
    local timestamp = math.floor(ms / 1000)
    local date_string = os.date("%d/%m/%Y %H:%M:%S", timestamp)
    return date_string
end

-- Get server uptime in formatted string
lib.callback.register('mns-pausemenu:GetServerUptime', function()
    local uptime = os.difftime(os.time(), uptimeStart)
    return Config.SharedFunctions.FormatTime(uptime)
end)

-- Get server info
lib.callback.register('mns-pausemenu:GetServerInfo', function()
    return {
        name = Config.ServerInfo.name,
        description = Config.ServerInfo.description,
        playerCount = #QBCore.Functions.GetPlayers(),
        maxPlayers = Config.ServerInfo.maxPlayers,
        uptime = Config.SharedFunctions.FormatTime(os.difftime(os.time(), uptimeStart))
    }
end)

-- Get custom buttons
lib.callback.register('mns-pausemenu:GetCustomButtons', function(source)
    if not Config.Features.customButtons then
        return {}
    end
    
    return Config.CustomButtons
end)

-- Custom button action handler
RegisterNetEvent('mns-pausemenu:triggerButtonAction')
AddEventHandler('mns-pausemenu:triggerButtonAction', function(action)
    local source = source
    
    if Config.ButtonActions and Config.ButtonActions[action] then
        Config.ButtonActions[action](source)
    end
end)

