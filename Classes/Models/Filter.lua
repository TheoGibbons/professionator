--- @class Filter
ItemPlanner.Filter = {}
ItemPlanner.Filter.__index = ItemPlanner.Filter

--- Creates a new Filter instance.
--- @param data table Filter data
--- @return Filter
function ItemPlanner.Filter:Create(data)
    local this = setmetatable({}, self)
    this.data = data or {}
    this.data.level = 1
    return this
end

--- Prints Filter data.
function ItemPlanner.Filter:Matches(item, slotId)

    -- faction check
    local faction = self:getFaction()
    if (faction ~= nil) then
        if (not item:canBeWornByFaction(faction)) then
            return false
        end
    end

    -- race check
    local race = self:getRaceName()
    if (race ~= nil) then
        if (not item:canBeWornByRace(race)) then
            return false
        end
    end

    -- level check
  local level = self:getLevel()
    if (level ~= nil) then
        if (not item:canBeWornByLevel(level)) then
            return false
        end
    end

    -- class check
    local classId = self:getClassId()
    if (classId ~= nil) then
        if (not item:canBeWornByClass(classId, level, slotId)) then
            return false
        end
    end

    -- Unattainable check
    if (item:isUnattainable() == true) then
        return false
    end

    return true
end

function ItemPlanner.Filter:setFaction(value)
    self.data.faction = value
end

function ItemPlanner.Filter:setRace(value)
    self.data.race = value
end

function ItemPlanner.Filter:setClass(value)
    self.data.classId = value
end

function ItemPlanner.Filter:setLevel(value)
    self.data.level = value
end

function ItemPlanner.Filter:setStatWeights(value)
    self.data.statWeight = value
end

function ItemPlanner.Filter:getFaction()
    return self.data.faction or nil
end

function ItemPlanner.Filter:getFactionName()
    if not self.data.faction then
        return nil
    end
    return ItemPlanner.Utils.getFactionNameFromId(self.data.faction)
end

function ItemPlanner.Filter:getRace()
    return self.data.race or nil
end

-- @see ItemPlannerDB.races
function ItemPlanner.Filter:getRaceName()
    local raceId = self:getRace()
    if not raceId then
        return nil
    end
    return ItemPlanner.Utils.getRaceNameFromId(raceId)
end

function ItemPlanner.Filter:getClassId()
    return self.data.classId or nil
end

function ItemPlanner.Filter:getLevel()
    return self.data.level or nil
end

function ItemPlanner.Filter:getStatWeights()
    return self.data.statWeight or ItemPlanner.Utils.getDefaultStatWeights()
end



function ItemPlanner.Filter:getOrderedListOfItems()

    local items = ItemPlanner.Utils.getAllItemsAsClasses()

    -- For each slot
    for slotId, itemsInSlot in pairs(items) do

        -- For each item in the slot
        for itemId, item in pairs(itemsInSlot) do

            -- If the item does not match the filter, then remove it
            if (not self:Matches(item, slotId)) then
                items[slotId][itemId] = nil
            end

        end

    end

    -- Now order the items
    for slotId, itemsInSlot in pairs(items) do
        items[slotId] = self:orderItems(itemsInSlot)
    end

    return items

end

function ItemPlanner.Filter:orderItems(items)

    local statWeights = self:getStatWeights()
    local orderedItems = {}

    for itemId, item in pairs(items) do
        table.insert(orderedItems, item)
    end

    table.sort(orderedItems, function(a, b)
        return statWeights:calculateScore(a) > statWeights:calculateScore(b)
    end)

    return orderedItems

end