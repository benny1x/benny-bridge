BennyBridge = BennyBridge or {}
BennyBridge.InventoryProviders = BennyBridge.InventoryProviders or {}

BennyBridge.InventoryProviders._items_util = BennyBridge.InventoryProviders._items_util or {}

function BennyBridge.InventoryProviders._items_util.normalize(raw)
    local m_List = {}
    local m_Seen = {}

    local function push(name, label)
        if type(name) ~= 'string' or name == '' then
            return
        end
        local m_Key = name:lower()
        if m_Seen[m_Key] then
            return
        end
        m_Seen[m_Key] = true
        m_List[#m_List + 1] = {
            m_Name = name,
            m_Label = (type(label) == 'string' and label ~= '' and label) or name,
        }
    end

    if type(raw) ~= 'table' then
        return m_List
    end

    for m_Key, m_Value in pairs(raw) do
        if type(m_Value) == 'string' then
            push(m_Value, m_Value)
        elseif type(m_Value) == 'table' then
            local m_Name = m_Value.name or m_Value.item or m_Value.itemName or (type(m_Key) == 'string' and m_Key or nil)
            local m_Label = m_Value.label or m_Value.Label or m_Value.description or m_Name
            push(m_Name, m_Label)
        elseif type(m_Key) == 'string' then
            push(m_Key, m_Key)
        end
    end

    table.sort(m_List, function(a, b)
        return tostring(a.m_Label):lower() < tostring(b.m_Label):lower()
    end)

    return m_List
end
