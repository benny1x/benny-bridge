BennyBridge = BennyBridge or {}

local function m_Export(m_Name, m_Fn)
    exports(m_Name, m_Fn)
end

m_Export('GetFramework', function()
    return BennyBridge.Framework.mGetType()
end)

m_Export('GetInventory', function()
    return BennyBridge.Inventory.mGetType()
end)

m_Export('GetPlayer', function(m_Source)
    return BennyBridge.Framework.mGetPlayer(m_Source)
end)

m_Export('GetIdentifier', function(m_Source)
    return BennyBridge.Framework.mGetIdentifier(m_Source)
end)

m_Export('GetName', function(m_Source)
    return BennyBridge.Framework.mGetName(m_Source)
end)

m_Export('GetJob', function(m_Source)
    return BennyBridge.Framework.mGetJob(m_Source)
end)

m_Export('HasGroup', function(m_Source, m_Group)
    return BennyBridge.Framework.mHasGroup(m_Source, m_Group)
end)

m_Export('GetMoney', function(m_Source, m_Account)
    return BennyBridge.Framework.mGetMoney(m_Source, m_Account)
end)

m_Export('AddMoney', function(m_Source, m_Account, m_Amount, m_Reason)
    return BennyBridge.Framework.mAddMoney(m_Source, m_Account, m_Amount, m_Reason)
end)

m_Export('RemoveMoney', function(m_Source, m_Account, m_Amount, m_Reason)
    return BennyBridge.Framework.mRemoveMoney(m_Source, m_Account, m_Amount, m_Reason)
end)

m_Export('AddItem', function(m_Source, m_Item, m_Count, m_Meta)
    return BennyBridge.Inventory.mAddItem(m_Source, m_Item, m_Count, m_Meta)
end)

m_Export('RemoveItem', function(m_Source, m_Item, m_Count, m_Meta)
    return BennyBridge.Inventory.mRemoveItem(m_Source, m_Item, m_Count, m_Meta)
end)

m_Export('HasItem', function(m_Source, m_Item, m_Count)
    return BennyBridge.Inventory.mHasItem(m_Source, m_Item, m_Count)
end)

m_Export('GetItemCount', function(m_Source, m_Item)
    return BennyBridge.Inventory.mGetItemCount(m_Source, m_Item)
end)

m_Export('GetItems', function()
    return BennyBridge.Inventory.mGetItems()
end)

m_Export('CanCarryItem', function(m_Source, m_Item, m_Count)
    return BennyBridge.Inventory.mCanCarryItem(m_Source, m_Item, m_Count)
end)

m_Export('CreateUseableItem', function(m_Item, m_Cb)
    return BennyBridge.Useables.mCreate(m_Item, m_Cb)
end)

m_Export('RegisterShop', function(m_ShopName, m_Data)
    return BennyBridge.Inventory.mRegisterShop(m_ShopName, m_Data)
end)

m_Export('OpenShop', function(m_Source, m_ShopName, m_Data)
    return BennyBridge.Inventory.mOpenShop(m_Source, m_ShopName, m_Data)
end)

m_Export('OpenPlayerInventory', function(m_Source, m_Target)
    return BennyBridge.Inventory.mOpenPlayerInventory(m_Source, m_Target)
end)

m_Export('GetShop', function(m_ShopName)
    return BennyBridge.Inventory.mGetShop(m_ShopName)
end)

m_Export('Notify', function(m_Source, m_Message, m_Type)
    if not m_Source or type(m_Message) ~= 'string' or m_Message == '' then
        return
    end

    TriggerClientEvent('benny-bridge:client:notify', m_Source, m_Message, m_Type or 'inform')
end)

m_Export('GetDispatch', function()
    return BennyBridge.Dispatch.mGetType()
end)

m_Export('SendDispatch', function(m_Source, m_Data)
    return BennyBridge.Dispatch.mSend(m_Source, m_Data)
end)

m_Export('GetMedical', function()
    return BennyBridge.Medical.mGetType()
end)

m_Export('Revive', function(m_Source)
    return BennyBridge.Medical.mRevive(m_Source)
end)

m_Export('CheckVersion', function(m_Resource, m_FileName)
    return BennyBridge.Version.Check(m_Resource, m_FileName)
end)

m_Export('CheckVersions', function()
    return BennyBridge.Version.CheckAll()
end)

BennyBridge.mDebug('setup server.')
