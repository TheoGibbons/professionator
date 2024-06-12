--- @class Professionator.PlayersInventory

Professionator.PlayersInventory = {}
Professionator.PlayersInventory.__index = Professionator.PlayersInventory
function Professionator.PlayersInventory:Create(items)
    local this =
    {
        items = items or {
            inventory = {},
            bank = {},
        },
    }
    setmetatable(this, self)
    return this
end

-- @param type string "inventory" or "bank"
-- @param itemId number
-- @param quantity number (optional) defaults to 1
function Professionator.PlayersInventory:add(itemId, quantity, type)
    type = type or "inventory"
    if self.items[type][itemId] == nil then
        self.items[type][itemId] = 0
    end
    self.items[type][itemId] = self.items[type][itemId] + (quantity or 1)
end

function Professionator.PlayersInventory:removeItem(itemId, quantity, type)
    local totalRemoved = 0
    for key, items in pairs(self.items) do
        if not type or key == type then
            if items[itemId] then
                local remove = math.min(items[itemId], quantity)
                items[itemId] = items[itemId] - remove
                quantity = quantity - remove
                totalRemoved = totalRemoved + remove
            end
        end
    end
    return totalRemoved
end

-- @param type string "inventory" or "bank"
-- @param itemId number
function Professionator.PlayersInventory:set(type, itemId, quantity)
    self.items[type][itemId] = quantity
end

-- flush function to clear all items of a type
function Professionator.PlayersInventory:flush(type)
    self.items[type] = {}
end

function Professionator.PlayersInventory:get(type)
    return self.items[type] or {}
end

function Professionator.PlayersInventory:getItemQuantity(itemId)
    local ret = 0
    for _, items in pairs(self.items) do
        for id, quantity in pairs(items) do
            if id == itemId then
                ret = ret + quantity
            end
        end
    end

    return ret
end


function Professionator.PlayersInventory:Clone()
    local clone = Professionator.PlayersInventory:Create()
    clone.items = Professionator.Utils.deepCopy(self.items)

    return clone
end

function Professionator.PlayersInventory:Contains(key, quantity, type)
    quantity = quantity or 1
    for key, items in pairs(self.items) do
        if not type or key == type then
            if items[key] then
                if items[key] >= quantity then
                    return true
                end
            end
        end
    end
    return false
end
