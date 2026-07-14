BennyBridge = BennyBridge or {}
BennyBridge.FrameworkProviders = BennyBridge.FrameworkProviders or {}

local m_Provider = {}

function m_Provider.mGetObject()
    if ESX and type(ESX.GetPlayerFromId) == 'function' then
        return ESX
    end

    local m_Ok, m_Object = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if m_Ok and m_Object then
        ESX = m_Object
        return ESX
    end

    return nil
end

function m_Provider.mGetPlayer(m_Source)
    local m_Esx = m_Provider.mGetObject()

    if not m_Esx then
        return nil
    end

    return m_Esx.GetPlayerFromId(m_Source)
end

function m_Provider.mGetIdentifier(m_Source)
    local m_Player = m_Provider.mGetPlayer(m_Source)
    return m_Player and m_Player.identifier or nil
end

function m_Provider.mGetName(m_Source)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player then
        return 'Unknown'
    end

    if m_Player.getName then
        return m_Player.getName()
    end

    return 'Unknown'
end

function m_Provider.mGetJob(m_Source)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player or not m_Player.job then
        return nil
    end

    return {
        m_Name = m_Player.job.name,
        m_Label = m_Player.job.label,
        m_Grade = m_Player.job.grade,
        m_GradeName = m_Player.job.grade_name,
    }
end

function m_Provider.mHasGroup(m_Source, m_Group)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player then
        return false
    end

    if m_Player.getGroup and m_Player.getGroup() == m_Group then
        return true
    end

    if m_Player.job and m_Player.job.name == m_Group then
        return true
    end

    return false
end

function m_Provider.mGetMoney(m_Source, m_Account)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player then
        return 0
    end

    m_Account = m_Account == 'cash' and 'money' or m_Account
    local m_Data = m_Player.getAccount and m_Player.getAccount(m_Account)
    return m_Data and m_Data.money or 0
end

function m_Provider.mAddMoney(m_Source, m_Account, m_Amount, m_Reason)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player or m_Amount <= 0 then
        return false
    end

    m_Account = m_Account == 'cash' and 'money' or m_Account
    m_Player.addAccountMoney(m_Account, m_Amount, m_Reason or 'benny-bridge')
    return true
end

function m_Provider.mRemoveMoney(m_Source, m_Account, m_Amount, m_Reason)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player or m_Amount <= 0 then
        return false
    end

    m_Account = m_Account == 'cash' and 'money' or m_Account
    local m_Balance = m_Provider.mGetMoney(m_Source, m_Account)

    if m_Balance < m_Amount then
        return false
    end

    m_Player.removeAccountMoney(m_Account, m_Amount, m_Reason or 'benny-bridge')
    return true
end

BennyBridge.FrameworkProviders.esx = m_Provider
