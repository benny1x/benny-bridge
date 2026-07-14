BennyBridge = BennyBridge or {}
BennyBridge.FrameworkProviders = BennyBridge.FrameworkProviders or {}

local m_Provider = {}

function m_Provider.mGetPlayer(m_Source)
    if not m_Source or m_Source <= 0 then
        return nil
    end

    return {
        source = m_Source,
        name = GetPlayerName(m_Source),
    }
end

function m_Provider.mGetIdentifier(m_Source)
    local m_License = GetPlayerIdentifierByType(m_Source, 'license')
    return m_License or GetPlayerIdentifierByType(m_Source, 'license2')
end

function m_Provider.mGetName(m_Source)
    return GetPlayerName(m_Source) or 'Unknown'
end

function m_Provider.mGetJob(_m_Source)
    return nil
end

function m_Provider.mHasGroup(m_Source, m_Group)
    return IsPlayerAceAllowed(m_Source, m_Group) == true
end

function m_Provider.mGetMoney(_m_Source, _m_Account)
    return 0
end

function m_Provider.mAddMoney(_m_Source, _m_Account, _m_Amount, _m_Reason)
    return false
end

function m_Provider.mRemoveMoney(_m_Source, _m_Account, _m_Amount, _m_Reason)
    return false
end

BennyBridge.FrameworkProviders.standalone = m_Provider
