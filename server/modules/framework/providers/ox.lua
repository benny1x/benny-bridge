BennyBridge = BennyBridge or {}
BennyBridge.FrameworkProviders = BennyBridge.FrameworkProviders or {}

local m_Provider = {}

function m_Provider.mGetPlayer(m_Source)
    local m_Ok, m_Player = pcall(function()
        return exports.ox_core:GetPlayer(m_Source)
    end)

    if m_Ok then
        return m_Player
    end

    return nil
end

function m_Provider.mGetIdentifier(m_Source)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player then
        return nil
    end

    return m_Player.charId or m_Player.stateId or m_Player.identifier or nil
end

function m_Provider.mGetName(m_Source)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player then
        return 'Unknown'
    end

    if m_Player.get and m_Player.get('firstName') then
        return ('%s %s'):format(m_Player.get('firstName') or '', m_Player.get('lastName') or ''):gsub('^%s+', ''):gsub('%s+$', '')
    end

    return GetPlayerName(m_Source) or 'Unknown'
end

function m_Provider.mGetJob(m_Source)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player or not m_Player.getGroup then
        return nil
    end

    return nil
end

function m_Provider.mHasGroup(m_Source, m_Group)
    local m_Player = m_Provider.mGetPlayer(m_Source)

    if not m_Player then
        return false
    end

    if m_Player.getGroup and m_Player.getGroup(m_Group) then
        return true
    end

    return IsPlayerAceAllowed(m_Source, m_Group) == true
end

function m_Provider.mGetMoney(m_Source, m_Account)
    BennyBridge.mDebug('ox money helpers are inventory-driven on most setups; returning 0 for', m_Account)
    return 0
end

function m_Provider.mAddMoney(m_Source, m_Account, m_Amount, m_Reason)
    BennyBridge.mDebug('ox AddMoney stub — wire to your money item/account later', m_Source, m_Account, m_Amount, m_Reason)
    return false
end

function m_Provider.mRemoveMoney(m_Source, m_Account, m_Amount, m_Reason)
    BennyBridge.mDebug('ox RemoveMoney stub — wire to your money item/account later', m_Source, m_Account, m_Amount, m_Reason)
    return false
end

BennyBridge.FrameworkProviders.ox = m_Provider
