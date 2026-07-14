BennyBridge = BennyBridge or {}
BennyBridge.Useables = BennyBridge.Useables or {}

local m_Callbacks = {}
local m_OxHookId = nil

local function m_Invoke(m_Source, m_Item, m_Data)
    local m_Cb = m_Callbacks[m_Item]
    if type(m_Cb) ~= 'function' then
        return
    end
    local m_Ok, m_Err = pcall(m_Cb, m_Source, m_Item, m_Data)
    if not m_Ok then
        BennyBridge.mDebug('useable item error', m_Item, m_Err)
    end
end

local function m_EnsureOxHook()
    if m_OxHookId or not BennyBridge.Utils.mResourceStarted('ox_inventory') then
        return
    end

    local m_Ok, m_Id = pcall(function()
        return exports.ox_inventory:registerHook('usingItem', function(payload)
            local m_Name = payload and payload.item and payload.item.name
            if not m_Name or not m_Callbacks[m_Name] then
                return
            end
            m_Invoke(payload.source, m_Name, payload)
            -- Cancel default consume; callback decides RemoveItem itself
            return false
        end)
    end)

    if m_Ok then
        m_OxHookId = m_Id
        BennyBridge.mDebug('ox_inventory useable hook ready')
    end
end

local function m_RegisterFramework(m_Item, m_Cb)
    local m_Fw = BennyBridge.Framework and BennyBridge.Framework.mGetType and BennyBridge.Framework.mGetType()

    if m_Fw == 'esx' and BennyBridge.Utils.mResourceStarted('es_extended') then
        pcall(function()
            local m_ESX = exports['es_extended']:getSharedObject()
            m_ESX.RegisterUsableItem(m_Item, function(m_Source)
                m_Invoke(m_Source, m_Item)
            end)
        end)
        return
    end

    if (m_Fw == 'qb' or m_Fw == 'qbx') then
        pcall(function()
            local m_Core
            if BennyBridge.Utils.mResourceStarted('qbx_core') then
                m_Core = exports['qb-core']:GetCoreObject()
            elseif BennyBridge.Utils.mResourceStarted('qb-core') then
                m_Core = exports['qb-core']:GetCoreObject()
            end
            if m_Core and m_Core.Functions and m_Core.Functions.CreateUseableItem then
                m_Core.Functions.CreateUseableItem(m_Item, function(m_Source, m_ItemData)
                    m_Invoke(m_Source, m_Item, m_ItemData)
                end)
            end
        end)
    end
end

--- Register a usable inventory item. Callback: function(source, itemName, data?)
function BennyBridge.Useables.mCreate(m_Item, m_Cb)
    if type(m_Item) ~= 'string' or m_Item == '' or type(m_Cb) ~= 'function' then
        return false
    end

    m_Callbacks[m_Item] = m_Cb
    m_EnsureOxHook()
    m_RegisterFramework(m_Item, m_Cb)
    BennyBridge.mDebug('useable registered', m_Item)
    return true
end

CreateThread(function()
    Wait(750)
    m_EnsureOxHook()
end)
