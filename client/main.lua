BennyBridge = BennyBridge or {}

local function m_Notify(m_Message, m_Type)
    if type(m_Message) ~= 'string' or m_Message == '' then
        return
    end

    local m_Kind = tostring(m_Type or 'inform')

    if GetResourceState('ox_lib') == 'started' and lib and lib.notify then
        lib.notify({
            description = m_Message,
            type = m_Kind == 'primary' and 'inform' or m_Kind,
        })
        return
    end

    if GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started' then
        TriggerEvent('QBCore:Notify', m_Message, m_Kind == 'inform' and 'primary' or m_Kind)
        return
    end

    if GetResourceState('es_extended') == 'started' then
        TriggerEvent('esx:showNotification', m_Message)
        return
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(m_Message)
    EndTextCommandThefeedPostTicker(false, true)
end

exports('Notify', m_Notify)

RegisterNetEvent('benny-bridge:client:notify', function(m_Message, m_Type)
    m_Notify(m_Message, m_Type)
end)

CreateThread(function()
    Wait(100)
    BennyBridge.mDebug('client shell ready')
end)
