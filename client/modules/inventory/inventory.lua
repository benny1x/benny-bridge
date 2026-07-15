BennyBridge = BennyBridge or {}
BennyBridge.Inventory = BennyBridge.Inventory or {}

local function m_Started(m_Name)
    return GetResourceState(m_Name) == 'started'
end

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

function BennyBridge.Inventory.mGetType()
    if Config.Inventory and Config.Inventory ~= 'auto' then
        return Config.Inventory
    end
    for i = 1, #m_DetectOrder do
        if m_Started(m_DetectOrder[i].m_Resource) then
            return m_DetectOrder[i].m_Id
        end
    end
    return 'none'
end

--- Open a shop registered via server `RegisterShop` (distance checked server-side).
function BennyBridge.Inventory.mOpenShop(m_ShopName, m_Data)
    if type(m_ShopName) ~= 'string' or m_ShopName == '' then
        return false
    end
    TriggerServerEvent('benny-bridge:server:openShop', m_ShopName, m_Data or { id = 1 })
    return true
end

RegisterNetEvent('benny-bridge:client:openShop', function(m_InvType, m_ShopName, m_Payload)
    m_Payload = m_Payload or {}
    m_Payload.type = m_ShopName or m_Payload.type
    m_Payload.id = m_Payload.id or 1

    if m_InvType == 'ox' and m_Started('ox_inventory') then
        pcall(function()
            exports.ox_inventory:openInventory('shop', {
                type = m_Payload.type,
                id = m_Payload.id,
            })
        end)
        return
    end

    if m_InvType == 'qs' and m_Started('qs-inventory') then
        local m_Id = tostring(m_Payload.type) .. '_' .. tostring(m_Payload.id)
        TriggerServerEvent('inventory:server:OpenInventory', 'shop', m_Id, {
            label = m_Payload.label or m_Payload.type,
            items = m_Payload.items or {},
        })
        return
    end

    if m_InvType == 'codem' then
        TriggerEvent('codem-inventory:openshop', m_Payload.type)
        return
    end

    TriggerEvent('benny-bridge:client:openShopFallback', m_Payload.type, m_Payload.label, m_Payload.items)
end)

RegisterNetEvent('benny-bridge:client:openShopFallback', function(m_ShopName, m_Label, m_Items)
    m_Items = m_Items or {}
    if #m_Items < 1 then
        return
    end

    if lib and lib.registerContext then
        local m_Options = {}
        for i = 1, #m_Items do
            local m_Row = m_Items[i]
            local m_Price = math.floor(tonumber(m_Row.price) or 0)
            m_Options[#m_Options + 1] = {
                title = m_Row.name,
                description = ('Price: $%s'):format(m_Price),
                icon = 'fa-solid fa-cart-shopping',
                onSelect = function()
                    TriggerServerEvent('benny-bridge:server:buyShopItem', m_ShopName, i, 1)
                end,
            }
        end

        local m_Ctx = 'benny_bridge_shop_' .. tostring(m_ShopName)
        lib.registerContext({
            id = m_Ctx,
            title = m_Label or m_ShopName,
            options = m_Options,
        })
        lib.showContext(m_Ctx)
        return
    end

    TriggerServerEvent('benny-bridge:server:buyShopItem', m_ShopName, 1, 1)
end)

RegisterNetEvent('benny-bridge:client:openPlayerInventory', function(m_InvType, m_Target)
    m_Target = tonumber(m_Target)
    if not m_Target then
        return
    end

    if m_InvType == 'ox' and m_Started('ox_inventory') then
        pcall(function()
            exports.ox_inventory:openInventory('player', m_Target)
        end)
        return
    end

    if m_InvType == 'qs' and m_Started('qs-inventory') then
        TriggerServerEvent('inventory:server:OpenInventory', 'otherplayer', m_Target)
        return
    end

    if (m_InvType == 'qb' or m_InvType == 'lj' or m_InvType == 'ps') then
        TriggerServerEvent('inventory:server:OpenInventory', 'otherplayer', m_Target)
        return
    end

    if m_InvType == 'tgiann' and m_Started('tgiann-inventory') then
        pcall(function()
            exports['tgiann-inventory']:OpenInventory('otherplayer', m_Target)
        end)
        return
    end

    if m_InvType == 'codem' then
        TriggerEvent('codem-inventory:client:robplayer')
    end
end)

exports('GetInventory', function()
    return BennyBridge.Inventory.mGetType()
end)

exports('OpenShop', function(m_ShopName, m_Data)
    return BennyBridge.Inventory.mOpenShop(m_ShopName, m_Data)
end)
