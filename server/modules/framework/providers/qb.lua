BennyBridge = BennyBridge or {}
BennyBridge.FrameworkProviders = BennyBridge.FrameworkProviders or {}

local m_Provider = {}

function m_Provider.mGetCore()
    local m_Ok, m_Core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    if m_Ok then
        return m_Core
    end

    return nil
end

function m_Provider.mGetPlayer(m_Source)
    local m_Core = m_Provider.mGetCore()

    if not m_Core then
        return nil
    end

    return m_Core.Functions.GetPlayer(m_Source)
end

function m_Provider.mGetIdentifier(m_Source)
    local m_Player = m_Provider.mGetPlayer(m_Source)
    return m_Player and m_Player.PlayerData and m_Player.PlayerData.citizenid or nil
end

function m_Provider.mGetName(m_Source)
    local m_Player = m_Provider.mGetPlayer(m_Source)
    local m_Charinfo = m_Player and m_Player.PlayerData and m_Player.PlayerData.charinfo

    if not m_Charinfo then
        return 'Unknown'
    end

    return ('%s %s'):format(m_Charinfo.firstname or '', m_Charinfo.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

function m_Provider.mGetJob(m_Source)
    local m_Player = m_Provider.mGetPlayer(m_Source)
    local m_Job = m_Player and m_Player.PlayerData and m_Player.PlayerData.job

    if not m_Job then
        return nil
    end

    return {
        m_Name = m_Job.name,
        m_Label = m_Job.label,
        m_Grade = m_Job.grade and m_Job.grade.level or 0,
        m_GradeName = m_Job.grade and m_Job.grade.name or nil,
    }
end

function m_Provider.mHasGroup(m_Source, m_Group)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player then
        return false
    end

    local m_Job = m_Player.PlayerData and m_Player.PlayerData.job
    if m_Job and m_Job.name == m_Group then
        return true
    end

    local m_Meta = m_Player.PlayerData and m_Player.PlayerData.metadata
    if m_Meta and m_Meta.permissions and m_Meta.permissions[m_Group] then
        return true
    end

    return false
end

function m_Provider.mGetMoney(m_Source, m_Account)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player then
        return 0
    end

    return m_Player.PlayerData.money and m_Player.PlayerData.money[m_Account] or 0
end

function m_Provider.mAddMoney(m_Source, m_Account, m_Amount, m_Reason)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player or m_Amount <= 0 then
        return false
    end

    return m_Player.Functions.AddMoney(m_Account, m_Amount, m_Reason or 'benny-bridge') == true
end

function m_Provider.mRemoveMoney(m_Source, m_Account, m_Amount, m_Reason)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player or m_Amount <= 0 then
        return false
    end

    return m_Player.Functions.RemoveMoney(m_Account, m_Amount, m_Reason or 'benny-bridge') == true
end

BennyBridge.FrameworkProviders.qb = m_Provider
