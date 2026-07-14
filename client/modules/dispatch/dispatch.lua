BennyBridge = BennyBridge or {}

local function m_Coords(m_Payload)
    if type(m_Payload) ~= 'table' or m_Payload.m_Coords == nil then
        return GetEntityCoords(PlayerPedId())
    end

    local m_C = m_Payload.m_Coords
    local m_Type = type(m_C)
    if m_Type == 'vector3' then
        return m_C
    end

    if m_Type == 'table' then
        return vector3(
            tonumber(m_C.x or m_C.m_X) or 0.0,
            tonumber(m_C.y or m_C.m_Y) or 0.0,
            tonumber(m_C.z or m_C.m_Z) or 0.0
        )
    end

    return GetEntityCoords(PlayerPedId())
end

RegisterNetEvent('benny-bridge:client:dispatch:cd', function(m_Payload)
    local m_Info = nil
    local m_Ok, m_Result = pcall(function()
        return exports['cd_dispatch']:GetPlayerInfo()
    end)
    if m_Ok then
        m_Info = m_Result
    end

    local m_CoordsValue = m_Info and m_Info.coords or m_Coords(m_Payload)
    local m_Sex = m_Info and m_Info.sex or 'person'
    local m_Street = m_Info and m_Info.street or 'unknown street'

    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = m_Payload.m_Jobs or { 'police' },
        coords = m_CoordsValue,
        title = m_Payload.m_Title or '10-50',
        message = m_Payload.m_Message ~= '' and m_Payload.m_Message or ('A ' .. m_Sex .. ' reported at ' .. m_Street),
        flash = m_Payload.m_Flash and 1 or 0,
        unique_id = tostring(math.random(0000000, 9999999)),
        blip = {
            sprite = m_Payload.m_Blip and m_Payload.m_Blip.m_Sprite or 51,
            scale = m_Payload.m_Blip and m_Payload.m_Blip.m_Scale or 1.2,
            colour = m_Payload.m_Blip and m_Payload.m_Blip.m_Colour or 2,
            flashes = m_Payload.m_Blip and m_Payload.m_Blip.m_Flashes or false,
            text = m_Payload.m_Blip and m_Payload.m_Blip.m_Text or 'Dispatch',
            time = m_Payload.m_Blip and m_Payload.m_Blip.m_Time or (5 * 60 * 1000),
            sound = 1,
        },
    })
end)

RegisterNetEvent('benny-bridge:client:dispatch:ps', function()
    pcall(function()
        exports['ps-dispatch']:DrugSale()
    end)
end)

RegisterNetEvent('benny-bridge:client:dispatch:core', function(m_Payload)
    local m_Pos = m_Coords(m_Payload)
    local m_Sprite = m_Payload.m_Blip and m_Payload.m_Blip.m_Sprite or 496
    local m_Job = (m_Payload.m_Jobs and m_Payload.m_Jobs[1]) or 'police'

    pcall(function()
        exports['core_dispatch']:addCall(
            m_Payload.m_Code or '10-50',
            m_Payload.m_Title or 'Dispatch',
            {
                { icon = 'fas fa-exclamation', info = m_Payload.m_Message or 'Alert' },
            },
            { m_Pos.x, m_Pos.y, m_Pos.z },
            m_Job,
            3000,
            m_Sprite,
            5
        )
    end)
end)

RegisterNetEvent('benny-bridge:client:dispatch:qs', function(m_Payload)
    local m_Info = nil
    pcall(function()
        m_Info = exports['qs-dispatch']:GetPlayerInfo()
    end)

    local m_CoordsValue = m_Info and m_Info.coords or m_Coords(m_Payload)
    local m_Sex = m_Info and m_Info.sex or 'person'
    local m_Street = m_Info and (m_Info.street_1 or m_Info.street) or 'unknown street'

    local function m_Send(m_Image)
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = m_Payload.m_Jobs or { 'police' },
            callLocation = m_CoordsValue,
            callCode = {
                code = m_Payload.m_Title or 'Dispatch',
                snippet = m_Payload.m_Code or '10-50',
            },
            message = m_Payload.m_Message ~= '' and m_Payload.m_Message or ('A ' .. m_Sex .. ' reported at ' .. m_Street),
            flashes = m_Payload.m_Flash == true,
            image = m_Image,
            blip = {
                sprite = m_Payload.m_Blip and m_Payload.m_Blip.m_Sprite or 51,
                scale = m_Payload.m_Blip and m_Payload.m_Blip.m_Scale or 1.5,
                colour = m_Payload.m_Blip and m_Payload.m_Blip.m_Colour or 2,
                flashes = m_Payload.m_Blip and m_Payload.m_Blip.m_Flashes or false,
                text = m_Payload.m_Blip and m_Payload.m_Blip.m_Text or 'Dispatch',
                time = m_Payload.m_Blip and m_Payload.m_Blip.m_Time or (5 * 60 * 1000),
            },
        })
    end

    local m_Ok = pcall(function()
        exports['qs-dispatch']:getSSURL(function(m_Image)
            m_Send(m_Image)
        end)
    end)

    if not m_Ok then
        m_Send(nil)
    end
end)

RegisterNetEvent('benny-bridge:client:dispatch:rcore', function(m_Payload)
    pcall(function()
        exports['rcore_dispatch']:DrugSale(
            m_Payload.m_Title or 'Dispatch',
            m_Payload.m_Message or 'Alert',
            {
                job = (m_Payload.m_Jobs and m_Payload.m_Jobs[1]) or 'police',
                code = m_Payload.m_Code or '10-50',
                sprite = m_Payload.m_Blip and m_Payload.m_Blip.m_Sprite or 496,
            }
        )
    end)
end)

RegisterNetEvent('benny-bridge:client:dispatch:codem', function(m_Payload)
    pcall(function()
        exports['codem-dispatch']:CustomDispatch({
            type = 'Drug',
            header = m_Payload.m_Title or 'Dispatch',
            text = m_Payload.m_Message or 'Alert',
            code = m_Payload.m_Code or '10-50',
            message = m_Payload.m_Message or 'Alert',
        })
    end)
end)
