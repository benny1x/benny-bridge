BennyBridge = BennyBridge or {}
BennyBridge.InventoryProviders = BennyBridge.InventoryProviders or {}

local m_Provider = {}

function m_Provider.mAddItem(m_Source, m_Item, m_Count, m_Meta)
    BennyBridge.mDebug('inventory none: AddItem ignored', m_Source, m_Item, m_Count)
    return false
end

function m_Provider.mRemoveItem(m_Source, m_Item, m_Count, m_Meta)
    BennyBridge.mDebug('inventory none: RemoveItem ignored', m_Source, m_Item, m_Count)
    return false
end

function m_Provider.mHasItem(_m_Source, _m_Item, _m_Count)
    return false
end

function m_Provider.mGetItemCount(_m_Source, _m_Item)
    return 0
end

function m_Provider.mGetItems()
    return {}
end

function m_Provider.mRegisterShop(_m_ShopName, _m_Data)
    return false
end

function m_Provider.mOpenShop(_m_Source, _m_ShopName, _m_Payload)
    return false
end

BennyBridge.InventoryProviders.none = m_Provider
