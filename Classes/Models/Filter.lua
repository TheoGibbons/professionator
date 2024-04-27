--- @class Filter
Professionator.Filter = {}
Professionator.Filter.__index = Professionator.Filter

--- Creates a new Filter instance.
--- @param data table Filter data
--- @return Filter
function Professionator.Filter:Create(data)
    local this = setmetatable({}, self)
    this.data = data or {}
    this.data.level = 1
    return this
end

--- Prints Filter data.
function Professionator.Filter:Matches(item, slotId)

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

function Professionator.Filter:setFaction(value)
    self.data.faction = value
end

function Professionator.Filter:setRace(value)
    self.data.race = value
end

function Professionator.Filter:setClass(value)
    self.data.classId = value
end

function Professionator.Filter:setLevel(value)
    self.data.level = value
end

function Professionator.Filter:setStatWeights(value)
    self.data.statWeight = value
end

function Professionator.Filter:getFaction()
    return self.data.faction or nil
end

function Professionator.Filter:getFactionName()
    if not self.data.faction then
        return nil
    end
    return Professionator.Utils.getFactionNameFromId(self.data.faction)
end

function Professionator.Filter:getRace()
    return self.data.race or nil
end

-- @see ProfessionatorDB.races
function Professionator.Filter:getRaceName()
    local raceId = self:getRace()
    if not raceId then
        return nil
    end
    return Professionator.Utils.getRaceNameFromId(raceId)
end

function Professionator.Filter:getClassId()
    return self.data.classId or nil
end

function Professionator.Filter:getLevel()
    return self.data.level or nil
end

function Professionator.Filter:getStatWeights()
    return self.data.statWeight or Professionator.Utils.getDefaultStatWeights()
end



function Professionator.Filter:getOrderedListOfItems()

    local items = Professionator.Utils.getAllItemsAsClasses()

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

function Professionator.Filter:orderItems(items)

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