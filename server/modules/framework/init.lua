BennyBridge = BennyBridge or {}
BennyBridge.Framework = BennyBridge.Framework or {}

local m_Active = nil
local m_Type = nil

local function m_DetectFramework()
    if Config.Framework and Config.Framework ~= 'auto' then
        return Config.Framework
    end

    if BennyBridge.Utils.mResourceStarted('qbx_core') then
        return 'qbx'
    end

    if BennyBridge.Utils.mResourceStarted('qb-core') then
        return 'qb'
    end

    if BennyBridge.Utils.mResourceStarted('es_extended') then
        return 'esx'
    end

    if BennyBridge.Utils.mResourceStarted('ox_core') then
        return 'ox'
    end

    return 'standalone'
end

local function m_ResolveProvider()
    m_Type = m_DetectFramework()
    m_Active = BennyBridge.FrameworkProviders[m_Type] or BennyBridge.FrameworkProviders.standalone
    BennyBridge.mDebug('framework resolved:', m_Type)
    return m_Active
end

function BennyBridge.Framework.mGetType()
    if not m_Type then
        m_ResolveProvider()
    end

    return m_Type
end

function BennyBridge.Framework.mGetPlayer(m_Source)
    return m_ResolveProvider().mGetPlayer(m_Source)
end

function BennyBridge.Framework.mGetIdentifier(m_Source)
    return m_ResolveProvider().mGetIdentifier(m_Source)
end

function BennyBridge.Framework.mGetName(m_Source)
    return m_ResolveProvider().mGetName(m_Source)
end

function BennyBridge.Framework.mGetJob(m_Source)
    return m_ResolveProvider().mGetJob(m_Source)
end

function BennyBridge.Framework.mHasGroup(m_Source, m_Group)
    return m_ResolveProvider().mHasGroup(m_Source, m_Group) == true
end

function BennyBridge.Framework.mGetMoney(m_Source, m_Account)
    return m_ResolveProvider().mGetMoney(m_Source, m_Account or 'cash')
end

function BennyBridge.Framework.mAddMoney(m_Source, m_Account, m_Amount, m_Reason)
    return m_ResolveProvider().mAddMoney(m_Source, m_Account or 'cash', m_Amount, m_Reason) == true
end

function BennyBridge.Framework.mRemoveMoney(m_Source, m_Account, m_Amount, m_Reason)
    return m_ResolveProvider().mRemoveMoney(m_Source, m_Account or 'cash', m_Amount, m_Reason) == true
end

function BennyBridge.Framework.mIsStandalone()
    return BennyBridge.Framework.mGetType() == 'standalone'
end

CreateThread(function()
    Wait(250)
    m_ResolveProvider()
end)
