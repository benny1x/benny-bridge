BennyBridge = BennyBridge or {}
BennyBridge.InventoryProviders = BennyBridge.InventoryProviders or {}

local m_Provider = {}

function m_Provider.mAddItem(m_Source, m_Item, m_Count, m_Meta)
    local m_Ok, m_Success = pcall(function()
        return exports.ox_inventory:AddItem(m_Source, m_Item, m_Count or 1, m_Meta)
    end)

    -- ox may return true or a slot number on success
    return m_Ok and m_Success ~= nil and m_Success ~= false
end

function m_Provider.mRemoveItem(m_Source, m_Item, m_Count, m_Meta)
    local m_Ok, m_Success = pcall(function()
        return exports.ox_inventory:RemoveItem(m_Source, m_Item, m_Count or 1, m_Meta)
    end)

    return m_Ok and m_Success ~= nil and m_Success ~= false
end

function m_Provider.mHasItem(m_Source, m_Item, m_Count)
    local m_Needed = m_Count or 1
    local m_Ok, m_Total = pcall(function()
        return exports.ox_inventory:GetItemCount(m_Source, m_Item)
    end)

    if not m_Ok then
        return false
    end

    return (m_Total or 0) >= m_Needed
end

function m_Provider.mGetItemCount(m_Source, m_Item)
    local m_Ok, m_Total = pcall(function()
        return exports.ox_inventory:GetItemCount(m_Source, m_Item)
    end)

    if not m_Ok then
        return 0
    end

    return m_Total or 0
end

function m_Provider.mGetItems()
    local m_Ok, m_Items = pcall(function()
        return exports.ox_inventory:Items()
    end)
    if m_Ok then
        return BennyBridge.InventoryProviders._items_util.normalize(m_Items)
    end
    return {}
end

function m_Provider.mCanCarryItem(m_Source, m_Item, m_Count)
    local m_Ok, m_Can = pcall(function()
        return exports.ox_inventory:CanCarryItem(m_Source, m_Item, m_Count or 1)
    end)
    return m_Ok and m_Can == true
end

function m_Provider.mRegisterShop(m_ShopName, m_Data)
    local m_Ok = pcall(function()
        exports.ox_inventory:RegisterShop(m_ShopName, {
            name = m_Data.name or m_Data.label or m_ShopName,
            inventory = m_Data.inventory,
            locations = m_Data.locations,
            groups = m_Data.groups,
        })
    end)
    return m_Ok
end

function m_Provider.mOpenShop(_m_Source, _m_ShopName, _m_Payload)
    return 'client'
end

BennyBridge.InventoryProviders.ox = m_Provider
