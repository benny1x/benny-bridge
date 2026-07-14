BennyBridge = BennyBridge or {}
BennyBridge.Medical = BennyBridge.Medical or {}

local m_Type = nil

local function m_Started(m_Name)
    local m_State = GetResourceState(m_Name)
    return m_State == 'started' or m_State == 'starting'
end

local function m_Detect()
    local m_Configured = tostring(Config.Medical and Config.Medical.Provider or 'auto')

    if m_Configured ~= 'auto' and m_Configured ~= '' and m_Configured ~= '0' then
        return m_Configured
    end

    if m_Started('wasabi_ambulance_v2') then
        return 'wasabi_ambulance_v2'
    end
    if m_Started('wasabi_ambulance') then
        return 'wasabi_ambulance'
    end
    if m_Started('qbx_medical') then
        return 'qbx_medical'
    end
    if m_Started('ars_ambulance') then
        return 'ars_ambulance'
    end
    if m_Started('ars_ambulancejob') then
        return 'ars_ambulancejob'
    end
    if m_Started('ak47_qb_ambulancejob') then
        return 'ak47_qb_ambulancejob'
    end
    if m_Started('ak47_ambulancejob') then
        return 'ak47_ambulancejob'
    end
    if m_Started('qb-ambulancejob') then
        return 'qb-ambulancejob'
    end
    if m_Started('esx_ambulancejob') then
        return 'esx_ambulancejob'
    end
    if m_Started('p_ambulancejob') then
        return 'p_ambulancejob'
    end
    if m_Started('brutal_ambulancejob') then
        return 'brutal_ambulancejob'
    end
    if m_Started('tk_ambulancejob') then
        return 'tk_ambulancejob'
    end

    return 'native'
end

local m_Providers = {}

m_Providers.wasabi_ambulance_v2 = function(m_Source)
    exports['wasabi_ambulance_v2']:RevivePlayer(m_Source)
end

m_Providers.wasabi_ambulance = function(m_Source)
    exports.wasabi_ambulance:RevivePlayer(m_Source)
end

m_Providers.qbx_medical = function(m_Source)
    exports.qbx_medical:Revive(m_Source)
end

m_Providers.ars_ambulance = function(m_Source)
    exports['ars_ambulance']:ReviveSelectedPlayer(m_Source)
end

m_Providers.ars_ambulancejob = function(m_Source)
    TriggerClientEvent('ars_ambulancejob:healPlayer', m_Source, { revive = true })
end

m_Providers.ak47_qb_ambulancejob = function(m_Source)
    TriggerClientEvent('ak47_qb_ambulancejob:revive', m_Source)
end

m_Providers.ak47_ambulancejob = function(m_Source)
    TriggerClientEvent('ak47_ambulancejob:revive', m_Source)
end

m_Providers['qb-ambulancejob'] = function(m_Source)
    TriggerClientEvent('hospital:client:Revive', m_Source)
end

m_Providers.esx_ambulancejob = function(m_Source)
    TriggerClientEvent('esx_ambulancejob:revive', m_Source)
end

m_Providers.p_ambulancejob = function(m_Source)
    TriggerClientEvent('p_ambulancejob/client/death/revive', m_Source)
end

m_Providers.brutal_ambulancejob = function(m_Source)
    TriggerClientEvent('brutal_ambulancejob:revive', m_Source)
end

m_Providers.tk_ambulancejob = function(m_Source)
    exports.tk_ambulancejob:revive(m_Source, true)
end

m_Providers.native = function(m_Source)
    TriggerClientEvent('benny-bridge:client:medical:nativeRevive', m_Source)
end

m_Providers.custom = function(m_Source)
    local m_Event = Config.Medical and Config.Medical.CustomReviveEvent
    if type(m_Event) == 'string' and m_Event ~= '' then
        TriggerClientEvent(m_Event, m_Source)
        return
    end

    local m_ExportRes = Config.Medical and Config.Medical.CustomReviveExportResource
    local m_ExportName = Config.Medical and Config.Medical.CustomReviveExportName
    if type(m_ExportRes) == 'string' and type(m_ExportName) == 'string' then
        exports[m_ExportRes][m_ExportName](m_Source)
    end
end

function BennyBridge.Medical.mGetType()
    if not m_Type then
        m_Type = m_Detect()
        BennyBridge.mDebug('medical provider:', m_Type)
    end
    return m_Type
end

function BennyBridge.Medical.mRevive(m_Source)
    if not m_Source or m_Source < 1 then
        return false
    end

    BennyBridge.Medical.mGetType()
    local m_Fn = m_Providers[m_Type] or m_Providers.native
    local m_Ok, m_Err = pcall(m_Fn, m_Source)
    if not m_Ok then
        BennyBridge.mDebug('medical revive failed', m_Type, m_Err)
        pcall(m_Providers.native, m_Source)
        return false
    end

    BennyBridge.mDebug('medical revive', m_Type, m_Source)
    return true
end

CreateThread(function()
    Wait(250)
    BennyBridge.Medical.mGetType()
end)
