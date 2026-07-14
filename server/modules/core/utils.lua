BennyBridge = BennyBridge or {}
BennyBridge.Utils = BennyBridge.Utils or {}

function BennyBridge.Utils.mResourceStarted(m_Name)
    return GetResourceState(m_Name) == 'started'
end

function BennyBridge.Utils.mSafeCall(m_Label, m_Fn, ...)
    local m_Ok, m_Result = pcall(m_Fn, ...)

    if not m_Ok then
        BennyBridge.mDebug(('safe call failed (%s): %s'):format(m_Label, tostring(m_Result)))
        return false, nil
    end

    return true, m_Result
end
