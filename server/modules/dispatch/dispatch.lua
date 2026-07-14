BennyBridge = BennyBridge or {}
BennyBridge.Dispatch = BennyBridge.Dispatch or {}

local m_Provider = nil
local m_Type = 'none'

local function m_Started(m_Name)
    local m_State = GetResourceState(m_Name)
    return m_State == 'started' or m_State == 'starting'
end

local function m_Detect()
    local m_Configured = tostring(Config.Dispatch or 'auto')

    if m_Configured ~= 'auto' and m_Configured ~= '0' and m_Configured ~= '' then
        return m_Configured
    end

    if m_Started('tk_dispatch') then
        return 'tk_dispatch'
    end
    if m_Started('cd_dispatch') then
        return 'cd_dispatch'
    end
    if m_Started('ps-dispatch') then
        return 'ps-dispatch'
    end
    if m_Started('core_dispatch') then
        return 'core_dispatch'
    end
    if m_Started('qs-dispatch') then
        return 'qs-dispatch'
    end
    if m_Started('rcore_dispatch') then
        return 'rcore_dispatch'
    end
    if m_Started('codem-dispatch') then
        return 'codem-dispatch'
    end
    if m_Started('origen_police') then
        return 'origen_police'
    end
    if m_Started('lb-tablet') then
        return 'lb-tablet'
    end

    return 'none'
end

local function m_Jobs(m_Data)
    if type(m_Data) == 'table' and type(m_Data.m_Jobs) == 'table' and #m_Data.m_Jobs > 0 then
        return m_Data.m_Jobs
    end
    if type(Config.DispatchJobs) == 'table' and #Config.DispatchJobs > 0 then
        return Config.DispatchJobs
    end
    return { 'police' }
end

local function m_Coords(m_Source, m_Data)
    if type(m_Data) == 'table' and type(m_Data.m_Coords) == 'table' then
        local m_X = tonumber(m_Data.m_Coords.m_X or m_Data.m_Coords.x)
        local m_Y = tonumber(m_Data.m_Coords.m_Y or m_Data.m_Coords.y)
        local m_Z = tonumber(m_Data.m_Coords.m_Z or m_Data.m_Coords.z)
        if m_X and m_Y and m_Z then
            return vector3(m_X + 0.0, m_Y + 0.0, m_Z + 0.0)
        end
    end

    local m_Ped = GetPlayerPed(m_Source)
    if m_Ped and m_Ped ~= 0 then
        return GetEntityCoords(m_Ped)
    end

    return vector3(0.0, 0.0, 0.0)
end

local function m_Normalize(m_Source, m_Data)
    if type(m_Data) == 'string' then
        m_Data = {
            m_Title = 'Dispatch',
            m_Message = m_Data,
            m_Code = '10-50',
        }
    end

    if type(m_Data) ~= 'table' then
        return nil
    end

    local m_Blip = type(m_Data.m_Blip) == 'table' and m_Data.m_Blip or {}
    local m_CoordsValue = m_Coords(m_Source, m_Data)

    return {
        m_Title = tostring(m_Data.m_Title or 'Dispatch'),
        m_Message = tostring(m_Data.m_Message or ''),
        m_Code = tostring(m_Data.m_Code or '10-50'),
        m_Coords = m_CoordsValue,
        m_Jobs = m_Jobs(m_Data),
        m_Flash = m_Data.m_Flash == true,
        m_Blip = {
            m_Sprite = tonumber(m_Blip.m_Sprite) or 51,
            m_Scale = tonumber(m_Blip.m_Scale) or 1.2,
            m_Colour = tonumber(m_Blip.m_Colour) or 3,
            m_Flashes = m_Blip.m_Flashes == true,
            m_Text = tostring(m_Blip.m_Text or m_Data.m_Title or 'Dispatch'),
            m_Time = tonumber(m_Blip.m_Time) or (5 * 60 * 1000),
        },
    }
end

local m_Providers = {}

m_Providers.none = function()
    BennyBridge.mDebug('dispatch none — call ignored')
end

m_Providers.cd_dispatch = function(m_Source, m_Payload)
    TriggerClientEvent('benny-bridge:client:dispatch:cd', m_Source, m_Payload)
end

m_Providers['ps-dispatch'] = function(m_Source, m_Payload)
    TriggerClientEvent('benny-bridge:client:dispatch:ps', m_Source, m_Payload)
end

m_Providers.core_dispatch = function(m_Source, m_Payload)
    TriggerClientEvent('benny-bridge:client:dispatch:core', m_Source, m_Payload)
end

m_Providers['qs-dispatch'] = function(m_Source, m_Payload)
    TriggerClientEvent('benny-bridge:client:dispatch:qs', m_Source, m_Payload)
end

m_Providers.rcore_dispatch = function(m_Source, m_Payload)
    TriggerClientEvent('benny-bridge:client:dispatch:rcore', m_Source, m_Payload)
end

m_Providers['codem-dispatch'] = function(m_Source, m_Payload)
    TriggerClientEvent('benny-bridge:client:dispatch:codem', m_Source, m_Payload)
end

m_Providers.origen_police = function(m_Source, m_Payload)
    exports['origen_police']:SendAlert({
        coords = m_Payload.m_Coords,
        title = m_Payload.m_Title,
        type = 'GENERAL',
        message = m_Payload.m_Message,
        job = m_Payload.m_Jobs[1] or 'police',
    })
end

m_Providers['lb-tablet'] = function(m_Source, m_Payload)
    exports['lb-tablet']:AddDispatch({
        priority = 'medium',
        code = m_Payload.m_Code,
        title = m_Payload.m_Title,
        description = m_Payload.m_Message,
        location = {
            label = '',
            coords = vector2(m_Payload.m_Coords.x, m_Payload.m_Coords.y),
        },
        time = 5000,
        job = m_Payload.m_Jobs[1] or 'police',
    })
end

m_Providers.tk_dispatch = function(m_Source, m_Payload)
    exports.tk_dispatch:addCall({
        jobs = m_Payload.m_Jobs,
        coords = m_Payload.m_Coords,
        code = m_Payload.m_Code,
        title = m_Payload.m_Title,
        message = m_Payload.m_Message,
        flash = m_Payload.m_Flash,
        blip = {
            sprite = m_Payload.m_Blip.m_Sprite,
            scale = m_Payload.m_Blip.m_Scale,
            colour = m_Payload.m_Blip.m_Colour,
            flashes = m_Payload.m_Blip.m_Flashes,
            text = m_Payload.m_Blip.m_Text,
            time = m_Payload.m_Blip.m_Time,
        },
    })
end

function BennyBridge.Dispatch.mGetType()
    if not m_Type or m_Type == '' then
        m_Type = m_Detect()
        m_Provider = m_Providers[m_Type] or m_Providers.none
    end
    return m_Type
end

function BennyBridge.Dispatch.mSend(m_Source, m_Data)
    local m_Payload = m_Normalize(m_Source, m_Data)
    if not m_Payload then
        return false
    end

    BennyBridge.Dispatch.mGetType()
    local m_Fn = m_Provider or m_Providers.none
    local m_Ok, m_Err = pcall(m_Fn, m_Source, m_Payload)
    if not m_Ok then
        BennyBridge.mDebug('dispatch failed', m_Type, m_Err)
        return false
    end

    BennyBridge.mDebug('dispatch sent', m_Type, m_Payload.m_Title)
    return true
end

CreateThread(function()
    Wait(250)
    BennyBridge.Dispatch.mGetType()
    BennyBridge.mDebug('dispatch provider:', m_Type)
end)
