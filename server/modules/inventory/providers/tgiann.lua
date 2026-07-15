BennyBridge = BennyBridge or {}
BennyBridge.InventoryProviders = BennyBridge.InventoryProviders or {}

local m_Provider = {}

function m_Provider.mAddItem(m_Source, m_Item, m_Count, m_Meta)
    local m_Ok, m_Success = pcall(function()
        return exports['tgiann-inventory']:AddItem(m_Source, m_Item, m_Count or 1, nil, m_Meta)
    end)

    return m_Ok and m_Success ~= false
end

function m_Provider.mRemoveItem(m_Source, m_Item, m_Count, m_Meta)
    local m_Ok, m_Success = pcall(function()
        return exports['tgiann-inventory']:RemoveItem(m_Source, m_Item, m_Count or 1, nil, m_Meta)
    end)

    return m_Ok and m_Success ~= false
end

function m_Provider.mHasItem(m_Source, m_Item, m_Count)
    local m_Needed = m_Count or 1
    local m_Ok, m_Has = pcall(function()
        return exports['tgiann-inventory']:HasItem(m_Source, m_Item, m_Needed)
    end)

    return m_Ok and m_Has == true
end

function m_Provider.mGetItemCount(m_Source, m_Item)
    local m_Ok, m_Result = pcall(function()
        return exports['tgiann-inventory']:GetItemCount(m_Source, m_Item)
    end)

    if m_Ok and type(m_Result) == 'number' then
        return m_Result
    end

    return 0
end

function m_Provider.mGetItems()
    local m_Ok, m_Items = pcall(function()
        return exports['tgiann-inventory']:GetItemList()
    end)
    if not m_Ok or type(m_Items) ~= 'table' then
        m_Ok, m_Items = pcall(function()
            return exports['qb-core']:GetCoreObject().Shared.Items
        end)
    end
    if m_Ok then
        return BennyBridge.InventoryProviders._items_util.normalize(m_Items)
    end
    return {}
end

function m_Provider.mRegisterShop(m_ShopName, m_Data)
    local m_Ok = pcall(function()
        exports['tgiann-inventory']:RegisterShop(m_ShopName, m_Data.inventory)
    end)
    return m_Ok
end

function m_Provider.mOpenShop(m_Source, m_ShopName, _m_Payload)
    local m_Ok = pcall(function()
        exports['tgiann-inventory']:OpenShop(m_Source, m_ShopName)
    end)
    return m_Ok
end

function m_Provider.mOpenPlayerInventory(_m_Source, _m_Target)
    return 'client'
end

BennyBridge.InventoryProviders.tgiann = m_Provider
