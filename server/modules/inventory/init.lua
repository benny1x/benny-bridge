BennyBridge = BennyBridge or {}
BennyBridge.Inventory = BennyBridge.Inventory or {}

local m_Active = nil
local m_Type = nil

local m_DetectOrder = {
    { m_Id = 'ox', m_Resource = 'ox_inventory' },
    { m_Id = 'qs', m_Resource = 'qs-inventory' },
    { m_Id = 'codem', m_Resource = 'codem-inventory' },
    { m_Id = 'tgiann', m_Resource = 'tgiann-inventory' },
    { m_Id = 'core', m_Resource = 'core_inventory' },
    { m_Id = 'ps', m_Resource = 'ps-inventory' },
    { m_Id = 'lj', m_Resource = 'lj-inventory' },
    { m_Id = 'qb', m_Resource = 'qb-inventory' },
}

local function m_DetectInventory()
    if Config.Inventory and Config.Inventory ~= 'auto' then
        return Config.Inventory
    end

    for m_Index = 1, #m_DetectOrder do
        local m_Entry = m_DetectOrder[m_Index]

        if BennyBridge.Utils.mResourceStarted(m_Entry.m_Resource) then
            return m_Entry.m_Id
        end
    end

    return 'none'
end

local function m_ResolveProvider()
    m_Type = m_DetectInventory()
    m_Active = BennyBridge.InventoryProviders[m_Type] or BennyBridge.InventoryProviders.none
    BennyBridge.mDebug('inventory resolved:', m_Type)
    return m_Active
end

function BennyBridge.Inventory.mGetType()
    if not m_Type then
        m_ResolveProvider()
    end

    return m_Type
end

function BennyBridge.Inventory.mAddItem(m_Source, m_Item, m_Count, m_Meta)
    if not m_Source or not m_Item then
        return false
    end

    return m_ResolveProvider().mAddItem(m_Source, m_Item, m_Count or 1, m_Meta) == true
end

function BennyBridge.Inventory.mRemoveItem(m_Source, m_Item, m_Count, m_Meta)
    if not m_Source or not m_Item then
        return false
    end

    return m_ResolveProvider().mRemoveItem(m_Source, m_Item, m_Count or 1, m_Meta) == true
end

function BennyBridge.Inventory.mHasItem(m_Source, m_Item, m_Count)
    if not m_Source or not m_Item then
        return false
    end

    return m_ResolveProvider().mHasItem(m_Source, m_Item, m_Count or 1) == true
end

function BennyBridge.Inventory.mGetItemCount(m_Source, m_Item)
    if not m_Source or not m_Item then
        return 0
    end

    return m_ResolveProvider().mGetItemCount(m_Source, m_Item) or 0
end

function BennyBridge.Inventory.mGetItems()
    local m_Provider = m_ResolveProvider()
    if type(m_Provider.mGetItems) ~= 'function' then
        return {}
    end

    local m_Ok, m_List = pcall(m_Provider.mGetItems)
    if not m_Ok or type(m_List) ~= 'table' then
        BennyBridge.mDebug('inventory GetItems failed', m_List)
        return {}
    end

    return m_List
end

function BennyBridge.Inventory.mCanCarryItem(m_Source, m_Item, m_Count)
    if not m_Source or not m_Item then
        return false
    end

    local m_Provider = m_ResolveProvider()
    if type(m_Provider.mCanCarryItem) == 'function' then
        return m_Provider.mCanCarryItem(m_Source, m_Item, m_Count or 1) == true
    end

    -- Inventories without weight APIs: assume ok (AddItem will still validate)
    return true
end

--- Open another player's inventory (looting / searching).
function BennyBridge.Inventory.mOpenPlayerInventory(m_Source, m_Target)
    if not m_Source or not m_Target or m_Source == m_Target then
        return false
    end

    local m_Provider = m_ResolveProvider()
    if type(m_Provider.mOpenPlayerInventory) ~= 'function' then
        TriggerClientEvent('benny-bridge:client:openPlayerInventory', m_Source, m_Type, m_Target)
        return true
    end

    local m_Ok, m_Result = pcall(m_Provider.mOpenPlayerInventory, m_Source, m_Target)
    if not m_Ok then
        BennyBridge.mDebug('OpenPlayerInventory failed', m_Result)
        return false
    end

    if m_Result == true then
        return true
    end

    if m_Result == 'client' then
        TriggerClientEvent('benny-bridge:client:openPlayerInventory', m_Source, m_Type, m_Target)
        return true
    end

    return false
end

CreateThread(function()
    Wait(350)
    m_ResolveProvider()
end)
