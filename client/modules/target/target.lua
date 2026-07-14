BennyBridge = BennyBridge or {}
BennyBridge.Target = BennyBridge.Target or {}

local m_Type = nil
local m_Tracked = {}

local m_DetectOrder = {
    { m_Id = 'ox', m_Resource = 'ox_target' },
    { m_Id = 'qb', m_Resource = 'qb-target' },
    { m_Id = 'qtarget', m_Resource = 'qtarget' },
}

local function m_Started(m_Name)
    return GetResourceState(m_Name) == 'started'
end

local function m_Detect()
    if Config.Target and Config.Target ~= 'auto' then
        return Config.Target
    end
    for i = 1, #m_DetectOrder do
        if m_Started(m_DetectOrder[i].m_Resource) then
            return m_DetectOrder[i].m_Id
        end
    end
    return 'none'
end

function BennyBridge.Target.mGetType()
    if not m_Type then
        m_Type = m_Detect()
        BennyBridge.mDebug('target resolved:', m_Type)
    end
    return m_Type
end

local function m_NormalizeOptions(m_Options)
    if type(m_Options) ~= 'table' then
        return {}
    end
    if m_Options.label or m_Options.m_Label or m_Options.name then
        return { m_Options }
    end
    return m_Options
end

local function m_OptionFields(m_Opt)
    return {
        m_Name = m_Opt.name or m_Opt.m_Name or 'benny_bridge_opt',
        m_Label = m_Opt.label or m_Opt.m_Label or 'Interact',
        m_Icon = m_Opt.icon or m_Opt.m_Icon or 'fa-solid fa-hand',
        m_Distance = tonumber(m_Opt.distance or m_Opt.m_Distance) or 2.0,
        m_OnSelect = m_Opt.onSelect or m_Opt.m_OnSelect or m_Opt.action,
        m_CanInteract = m_Opt.canInteract or m_Opt.m_CanInteract,
        m_Event = m_Opt.event or m_Opt.m_Event,
        m_Type = m_Opt.type or m_Opt.m_Type or 'client',
    }
end

function BennyBridge.Target.mAddLocalEntity(m_Entity, m_Options)
    if not m_Entity or m_Entity == 0 or not DoesEntityExist(m_Entity) then
        return false
    end

    local m_List = m_NormalizeOptions(m_Options)
    if #m_List < 1 then
        return false
    end

    local m_Kind = BennyBridge.Target.mGetType()
    m_Tracked[m_Entity] = m_Tracked[m_Entity] or { m_Names = {} }

    if m_Kind == 'ox' then
        local m_Ox = {}
        for i = 1, #m_List do
            local m_F = m_OptionFields(m_List[i])
            m_Tracked[m_Entity].m_Names[m_F.m_Name] = true
            m_Ox[#m_Ox + 1] = {
                name = m_F.m_Name,
                icon = m_F.m_Icon,
                label = m_F.m_Label,
                distance = m_F.m_Distance,
                canInteract = m_F.m_CanInteract,
                onSelect = m_F.m_OnSelect,
            }
        end
        local m_Ok = pcall(function()
            exports.ox_target:addLocalEntity(m_Entity, m_Ox)
        end)
        return m_Ok
    end

    if m_Kind == 'qb' or m_Kind == 'qtarget' then
        local m_Res = m_Kind == 'qb' and 'qb-target' or 'qtarget'
        local m_Qb = {}
        for i = 1, #m_List do
            local m_F = m_OptionFields(m_List[i])
            m_Tracked[m_Entity].m_Names[m_F.m_Name] = true
            m_Qb[#m_Qb + 1] = {
                num = i,
                type = m_F.m_Type,
                event = m_F.m_Event,
                icon = m_F.m_Icon,
                label = m_F.m_Label,
                targeticon = m_F.m_Icon,
                action = m_F.m_OnSelect,
                canInteract = m_F.m_CanInteract,
            }
        end
        local m_Ok = pcall(function()
            exports[m_Res]:AddTargetEntity(m_Entity, {
                options = m_Qb,
                distance = m_List[1] and (tonumber(m_List[1].distance or m_List[1].m_Distance) or 2.0) or 2.0,
            })
        end)
        return m_Ok
    end

    BennyBridge.mDebug('target none — no provider for AddLocalEntity')
    return false
end

function BennyBridge.Target.mRemoveLocalEntity(m_Entity, m_Name)
    if not m_Entity then
        return false
    end

    local m_Kind = BennyBridge.Target.mGetType()
    local m_Track = m_Tracked[m_Entity]

    if m_Kind == 'ox' then
        local m_Ok = pcall(function()
            if m_Name then
                exports.ox_target:removeLocalEntity(m_Entity, m_Name)
            else
                exports.ox_target:removeLocalEntity(m_Entity)
            end
        end)
        if m_Track then
            if m_Name then
                m_Track.m_Names[m_Name] = nil
            else
                m_Tracked[m_Entity] = nil
            end
        end
        return m_Ok
    end

    if m_Kind == 'qb' then
        local m_Ok = pcall(function()
            exports['qb-target']:RemoveTargetEntity(m_Entity)
        end)
        m_Tracked[m_Entity] = nil
        return m_Ok
    end

    if m_Kind == 'qtarget' then
        local m_Ok = pcall(function()
            exports.qtarget:RemoveTargetEntity(m_Entity)
        end)
        m_Tracked[m_Entity] = nil
        return m_Ok
    end

    return false
end

-- Register on this file so exports exist even if client/main load order changes
exports('GetTarget', function()
    return BennyBridge.Target.mGetType()
end)

exports('AddLocalEntity', function(m_Entity, m_Options)
    return BennyBridge.Target.mAddLocalEntity(m_Entity, m_Options)
end)

exports('RemoveLocalEntity', function(m_Entity, m_Name)
    return BennyBridge.Target.mRemoveLocalEntity(m_Entity, m_Name)
end)

CreateThread(function()
    Wait(200)
    BennyBridge.Target.mGetType()
end)

AddEventHandler('onResourceStop', function(m_Resource)
    if m_Resource ~= GetCurrentResourceName() then
        return
    end
    for m_Entity in pairs(m_Tracked) do
        BennyBridge.Target.mRemoveLocalEntity(m_Entity)
    end
end)
