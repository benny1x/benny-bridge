BennyBridge = BennyBridge or {}
BennyBridge.Inventory = BennyBridge.Inventory or {}
BennyBridge.Shops = BennyBridge.Shops or {}

local function m_NormalizeItems(m_Items)
    if type(m_Items) ~= 'table' then
        return {}
    end

    local m_List = {}
    for i = 1, #m_Items do
        local m_Row = m_Items[i]
        if type(m_Row) == 'table' and m_Row.name then
            local m_Entry = {
                name = tostring(m_Row.name),
                price = math.max(0, math.floor(tonumber(m_Row.price) or 0)),
                amount = math.max(1, math.floor(tonumber(m_Row.amount) or 1000)),
                slot = math.floor(tonumber(m_Row.slot) or i),
                currency = m_Row.currency,
                metadata = m_Row.metadata,
            }
            if tostring(m_Entry.name):find('WEAPON_', 1, true) then
                m_Entry.type = 'weapon'
            else
                m_Entry.type = m_Row.type or 'item'
            end
            m_List[#m_List + 1] = m_Entry
        end
    end
    return m_List
end

local function m_ShopCoords(m_Locations)
    if type(m_Locations) ~= 'table' or #m_Locations < 1 then
        return nil
    end
    local m_Loc = m_Locations[1]
    if type(m_Loc) == 'vector3' or type(m_Loc) == 'vector4' then
        return vector3(m_Loc.x + 0.0, m_Loc.y + 0.0, m_Loc.z + 0.0)
    end
    if type(m_Loc) == 'table' and m_Loc.x and m_Loc.y and m_Loc.z then
        return vector3(m_Loc.x + 0.0, m_Loc.y + 0.0, m_Loc.z + 0.0)
    end
    return nil
end

local function m_NearShop(m_Source, m_Shop, m_Max)
    local m_Coords = m_ShopCoords(m_Shop.locations)
    if not m_Coords then
        return true
    end

    local m_Ped = GetPlayerPed(m_Source)
    if not m_Ped or m_Ped == 0 then
        return false
    end

    return #(GetEntityCoords(m_Ped) - m_Coords) <= (tonumber(m_Max) or 8.0)
end

local function m_MoneyAccount(m_Currency)
    local m_Cur = tostring(m_Currency or 'money')
    if m_Cur == 'money' or m_Cur == 'cash' then
        local m_Fw = BennyBridge.Framework.mGetType()
        if m_Fw == 'qb' or m_Fw == 'qbx' then
            return 'cash'
        end
        return 'money'
    end
    return m_Cur
end

--- Register a shop with the active inventory (+ keep a bridge catalog for qs/fallback).
--- data = { name/label, inventory = { { name, price, amount?, currency? } }, locations? }
function BennyBridge.Inventory.mRegisterShop(m_ShopName, m_Data)
    if type(m_ShopName) ~= 'string' or m_ShopName == '' or type(m_Data) ~= 'table' then
        return false
    end

    local m_Items = m_NormalizeItems(m_Data.inventory or m_Data.items)
    if #m_Items < 1 then
        BennyBridge.mDebug('RegisterShop empty inventory', m_ShopName)
        return false
    end

    local m_Label = m_Data.name or m_Data.label or m_ShopName
    local m_Shop = {
        name = m_ShopName,
        label = m_Label,
        inventory = m_Items,
        locations = m_Data.locations,
        groups = m_Data.groups or m_Data.jobs,
    }
    BennyBridge.Shops[m_ShopName] = m_Shop

    local m_Provider = BennyBridge.InventoryProviders[BennyBridge.Inventory.mGetType()]
        or BennyBridge.InventoryProviders.none

    if type(m_Provider.mRegisterShop) == 'function' then
        local m_Ok, m_Result = pcall(m_Provider.mRegisterShop, m_ShopName, {
            name = m_Label,
            label = m_Label,
            inventory = m_Items,
            locations = m_Data.locations,
            groups = m_Shop.groups,
        })
        if not m_Ok then
            BennyBridge.mDebug('RegisterShop provider error', m_ShopName, m_Result)
        elseif m_Result == false then
            BennyBridge.mDebug('RegisterShop provider declined (fallback buy still available)', m_ShopName)
        else
            BennyBridge.mDebug('RegisterShop ok', m_ShopName, BennyBridge.Inventory.mGetType())
        end
    else
        BennyBridge.mDebug('RegisterShop catalog-only (no native shop API)', m_ShopName)
    end

    return true
end

function BennyBridge.Inventory.mGetShop(m_ShopName)
    return BennyBridge.Shops[m_ShopName]
end

function BennyBridge.Inventory.mOpenShop(m_Source, m_ShopName, m_Data)
    if not m_Source or type(m_ShopName) ~= 'string' then
        return false
    end

    local m_Shop = BennyBridge.Shops[m_ShopName]
    if not m_Shop then
        BennyBridge.mDebug('OpenShop unknown shop', m_ShopName)
        return false
    end

    if not m_NearShop(m_Source, m_Shop, 10.0) then
        TriggerClientEvent('benny-bridge:client:notify', m_Source, 'You are too far from the shop', 'error')
        return false
    end

    local m_Type = BennyBridge.Inventory.mGetType()
    local m_Provider = BennyBridge.InventoryProviders[m_Type] or BennyBridge.InventoryProviders.none
    local m_Payload = {
        type = m_ShopName,
        id = (m_Data and m_Data.id) or 1,
        label = m_Shop.label,
        items = m_Shop.inventory,
    }

    if type(m_Provider.mOpenShop) == 'function' then
        local m_Ok, m_Mode = pcall(m_Provider.mOpenShop, m_Source, m_ShopName, m_Payload)
        if m_Ok and m_Mode == true then
            return true
        end
        if m_Ok and m_Mode == 'client' then
            TriggerClientEvent('benny-bridge:client:openShop', m_Source, m_Type, m_ShopName, m_Payload)
            return true
        end
    end

    -- Universal fallback: bridge money purchase UI
    TriggerClientEvent('benny-bridge:client:openShopFallback', m_Source, m_ShopName, m_Shop.label, m_Shop.inventory)
    return true
end

function BennyBridge.Inventory.mBuyShopItem(m_Source, m_ShopName, m_Slot, m_Count)
    local m_Shop = BennyBridge.Shops[m_ShopName]
    if not m_Shop or not m_Source then
        return false
    end

    if not m_NearShop(m_Source, m_Shop, 10.0) then
        TriggerClientEvent('benny-bridge:client:notify', m_Source, 'You are too far from the shop', 'error')
        return false
    end

    local m_Index = math.floor(tonumber(m_Slot) or 1)
    local m_Item = m_Shop.inventory[m_Index]
    if not m_Item then
        return false
    end

    local m_Amount = math.max(1, math.min(math.floor(tonumber(m_Count) or 1), 25))
    local m_Cost = m_Item.price * m_Amount
    local m_Account = m_MoneyAccount(m_Item.currency)

    -- Item-currency (ox style): take inventory item as payment
    if m_Account ~= 'money' and m_Account ~= 'cash' and m_Account ~= 'bank' and m_Account ~= 'black_money' then
        if not BennyBridge.Inventory.mHasItem(m_Source, m_Account, m_Cost) then
            TriggerClientEvent('benny-bridge:client:notify', m_Source, 'Not enough ' .. m_Account, 'error')
            return false
        end
        if not BennyBridge.Inventory.mCanCarryItem(m_Source, m_Item.name, m_Amount) then
            TriggerClientEvent('benny-bridge:client:notify', m_Source, 'You cannot carry that', 'error')
            return false
        end
        if not BennyBridge.Inventory.mRemoveItem(m_Source, m_Account, m_Cost) then
            TriggerClientEvent('benny-bridge:client:notify', m_Source, 'Payment failed', 'error')
            return false
        end
    else
        local m_Balance = BennyBridge.Framework.mGetMoney(m_Source, m_Account) or 0
        if m_Balance < m_Cost then
            TriggerClientEvent('benny-bridge:client:notify', m_Source, 'Not enough money', 'error')
            return false
        end
        if not BennyBridge.Inventory.mCanCarryItem(m_Source, m_Item.name, m_Amount) then
            TriggerClientEvent('benny-bridge:client:notify', m_Source, 'You cannot carry that', 'error')
            return false
        end
        if not BennyBridge.Framework.mRemoveMoney(m_Source, m_Account, m_Cost, 'benny-bridge-shop') then
            TriggerClientEvent('benny-bridge:client:notify', m_Source, 'Payment failed', 'error')
            return false
        end
    end

    if not BennyBridge.Inventory.mAddItem(m_Source, m_Item.name, m_Amount, m_Item.metadata) then
        -- refund
        if m_Account ~= 'money' and m_Account ~= 'cash' and m_Account ~= 'bank' and m_Account ~= 'black_money' then
            BennyBridge.Inventory.mAddItem(m_Source, m_Account, m_Cost)
        else
            BennyBridge.Framework.mAddMoney(m_Source, m_Account, m_Cost, 'benny-bridge-shop-refund')
        end
        TriggerClientEvent('benny-bridge:client:notify', m_Source, 'Could not give item', 'error')
        return false
    end

    TriggerClientEvent('benny-bridge:client:notify', m_Source, ('Purchased x%s %s'):format(m_Amount, m_Item.name), 'success')
    return true
end

RegisterNetEvent('benny-bridge:server:openShop', function(m_ShopName, m_Data)
    BennyBridge.Inventory.mOpenShop(source, m_ShopName, m_Data)
end)

RegisterNetEvent('benny-bridge:server:buyShopItem', function(m_ShopName, m_Slot, m_Count)
    BennyBridge.Inventory.mBuyShopItem(source, m_ShopName, m_Slot, m_Count)
end)
