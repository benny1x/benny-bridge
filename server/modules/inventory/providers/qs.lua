BennyBridge = BennyBridge or {}
BennyBridge.InventoryProviders = BennyBridge.InventoryProviders or {}

local m_Provider = {}

function m_Provider.mAddItem(m_Source, m_Item, m_Count, m_Meta)
    local m_Ok, m_Success = pcall(function()
        return exports['qs-inventory']:AddItem(m_Source, m_Item, m_Count or 1, nil, m_Meta)
    end)

    return m_Ok and m_Success ~= false
end

function m_Provider.mRemoveItem(m_Source, m_Item, m_Count, m_Meta)
    local m_Ok, m_Success = pcall(function()
        return exports['qs-inventory']:RemoveItem(m_Source, m_Item, m_Count or 1, nil, m_Meta)
    end)

    return m_Ok and m_Success ~= false
end

function m_Provider.mHasItem(m_Source, m_Item, m_Count)
    local m_Needed = m_Count or 1
    local m_Ok, m_Result = pcall(function()
        return exports['qs-inventory']:GetItemTotalAmount(m_Source, m_Item)
    end)

    if m_Ok and type(m_Result) == 'number' then
        return m_Result >= m_Needed
    end

    local m_Ok2, m_Has = pcall(function()
        return exports['qs-inventory']:HasItem(m_Source, m_Item, m_Needed)
    end)

    return m_Ok2 and m_Has == true
end

function m_Provider.mGetItemCount(m_Source, m_Item)
    local m_Ok, m_Result = pcall(function()
        return exports['qs-inventory']:GetItemTotalAmount(m_Source, m_Item)
    end)

    if m_Ok and type(m_Result) == 'number' then
        return m_Result
    end

    return 0
end

function m_Provider.mGetItems()
    local m_Ok, m_Items = pcall(function()
        return exports['qs-inventory']:GetItemList()
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

function m_Provider.mRegisterShop(_m_ShopName, _m_Data)
    -- qs shops are opened with an inline item list (no persistent register)
    return true
end

function m_Provider.mOpenShop(_m_Source, _m_ShopName, _m_Payload)
    return 'client'
end

function m_Provider.mOpenPlayerInventory(_m_Source, _m_Target)
    return 'client'
end

BennyBridge.InventoryProviders.qs = m_Provider
