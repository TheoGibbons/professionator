local ProfessionatorDB = ProfessionatorLoader:ImportModule("ProfessionatorDB")

--- @class Item
Professionator.Item = {}
Professionator.Item.__index = Professionator.Item

--- Creates a new Item instance.
--- @param data table Item data
--- @return Item
function Professionator.Item:Create(data)
    local this = setmetatable({}, self)
    this.data = data
    return this
end

--- Prints item data.
function Professionator.Item:printData()
    print(self.data)
end

--- The ProfessionatorDB.itemData looks like this { [21] = { [25]={[0]='Worn Shortsword',[1]=2,...},
--- Which the [0] index is the name of the item, [1] is the item level ...
--- This function will return the index of the data we are looking for.
--- For example passing "name" to this function will return "0".
function Professionator.Item:getItemKeyIndex(itemKey)

    local dataIndex = ProfessionatorDB.itemKeys[itemKey] or nil

    -- The item key MUST EXIST
    -- NOTE: It must exist in the ProfessionatorDB.itemKeys array but it may not exist in the itemData array
    if (dataIndex == nil) then
        error("Item key not found: " .. itemKey)
    end

    return dataIndex

end

function Professionator.Item:getStat(stat)
    local itemKeyIndex = self:getItemKeyIndex(stat)
    return self.data[itemKeyIndex] or nil
end

--- Gets the agility value.
--- @return number Agility value
function Professionator.Item:getAgility()
    return self:getStat("agility")
end

--- Gets the id value.
--- @return number id value
function Professionator.Item:getId()
    return self:getStat("id")
end

--- Gets the strength value.
--- @return number Strength value
function Professionator.Item:getStrength()
    return self:getStat("strength")
end

function Professionator.Item:getName()
    return self:getStat("name")
end
function Professionator.Item:getSlotId()
    return self:getStat("slot")
end
function Professionator.Item:getSlotName()
    local slotId = self:getSlotId()       -- EG: 1, 16, 21 (this matches ProfessionatorDB.slotNames array)
    return Professionator.Utils.getSlotNameFromId(slotId)       -- EG: "Head", "Main Hand", "One-Hand" (this matches ProfessionatorDB.slotNames array)
end
function Professionator.Item:getSlotId()
    return self:getStat("slot")
end
function Professionator.Item:getSubclassId()
    return self:getStat("itemSubclass")      -- EG: 1, 2, 4
end
function Professionator.Item:getSubclassName()
    local subclassId = self:getSubclassId()      -- EG: 1, 2, 4
    return Professionator.Utils.getSubclassNameFromId(subclassId)       -- EG: "Chest"
end

--- Gets the suffix for items that have a suffix. EG Heavy Lamellar Gauntlets of the Monkey
--- @return string|nil EG "614"
--- @see https://warcraft.wiki.gg/wiki/SuffixId
function Professionator.Item:getSuffixId()
    return self:getStat("suffixId")
end

--- Gets the suffix text for items that have a suffix. EG Heavy Lamellar Gauntlets of the Monkey
--- @return string|nil EG "of the Monkey"
--- @see https://warcraft.wiki.gg/wiki/SuffixId
function Professionator.Item:getSuffixText()
    return self:getStat("suffixText")
end

--- Gets the suffix text for items that have a suffix. EG Heavy Lamellar Gauntlets of the Monkey
--- @return string|nil EG "of the Monkey"
--- @see https://warcraft.wiki.gg/wiki/SuffixId
function Professionator.Item:getSuffixText()
    return self:getStat("suffixText")
end

function Professionator.Item:isUnattainable()
    return self:getStat("isUnattainable") or false
end

function Professionator.Item:canBeWornByFaction(factionId)

    local usableByFaction = self:getStat("usableByFaction")

    if (usableByFaction == nil) then
        return true
    end

    if (factionId == usableByFaction) then
        return true
    end

    return false
end

function Professionator.Item:canBeWornByRace(raceName)
    local requiredRaces = self:getStat("reqraces")

    if (requiredRaces == nil) then
        return true
    end

    if (Professionator.Utils.inArray(raceName, requiredRaces)) then
        return true
    end

    return false
end

function Professionator.Item:canBeWornByClass(classId, level, slotId)

    -- Item requires classes?
    local requiredClass = self:getStat("requiredClass")

    -- Can this item on by worn by certain classes?
    if (requiredClass ~= nil) then

        -- Check if classId is one of the classes in the requiredClass array
        if (not Professionator.Utils.inArray(classId, requiredClass)) then
           return false
        end
    end

    -- Check that a {class} at {level} can wear this item
    if (not self:canClassWearItemAtLevel(classId, level, slotId)) then
        return false
    end

    return true
end

function Professionator.Item:canBeWornByLevel(level)
    local requiredLevel = self:getStat("requiredLevel")
    if (requiredLevel ~= nil) then
        return level >= requiredLevel
    end

    return true
end

-- Can a class wear an item at a certain level
-- EG a warrior at level 40 can wear plate
function Professionator.Item:canClassWearItemAtLevel(classId, level, slotId)
    local minLevel = self:getMinEquipLevel(classId, slotId)

    return level >= minLevel
end

-- Pass in EG: "Hunter", "Chest", "Leather"
function Professionator.Item:getMinEquipLevel(classId)

    -- Everyone can wear this item
    local MIN_LEVEL = 1

    -- Lets just return a high number that no player can reach
    local IMPOSSIBLE_LEVEL = 1000

    if self:getSlotId() == 0 then
        -- There are lots of unequippable items in this category EG "A Crumpled Missive"
        return IMPOSSIBLE_LEVEL
    end

    -- Get the slot name of the item
    local slotName = self:getSlotName()       -- EG: "Head", "Main Hand", "One-Hand" (this matches ProfessionatorDB.slotNames array)

    -- Get the subclass of the item EG: "Cloth", "One-Handed Swords" (this matches ProfessionatorDB.itemSubclassMap)
    local subclassName = self:getSubclassName()       -- EG: "Cloth", "One-Handed Swords" (this matches ProfessionatorDB.itemSubclassMap)

    -- Here are some overrides for the slotName
    if slotName == "Held In Off-hand" then
        slotName = "Off Hand"
        subclassName = "Held In Off-hand"
    end
    if slotName == "Thrown" then
        slotName = "Ranged"
        subclassName = "Thrown"
    end
    if slotName == "Shield" then
        slotName = "Off Hand"
        subclassName = "Shield"
    end
    if slotName == "Off-hand" then
        slotName = "Off Hand"
    end

    -- If the slot doesn't exist then return an impossible level
    if not slotName then
        --print("Slot name missing in map: " .. self:getSlotId())
        Professionator.Utils.addMissing(self:getId(), self:getSlotId())
        return IMPOSSIBLE_LEVEL
    end

    -- Get the slot eg: Head, Chest, Legs
    local slot = ProfessionatorDB.armorProficiencies[slotName]

    -- Sometimes this is true (eg neck, finger) in which case we can just return the minimum level
    if slot == true then
        return MIN_LEVEL
    elseif slot == false then
        return IMPOSSIBLE_LEVEL
    end

    -- If the slot doesn't exist then return an impossible level
    if slot == nil then
        --print("Slot missing: " .. slotName)
        Professionator.Utils.addMissing(self:getId(), self:getSlotId(), slotName)
        return IMPOSSIBLE_LEVEL
    end

    -- Get the group EG "Leather Armor"
    local group = slot[subclassName or ""]

    -- Sometimes this is true (eg neck, finger) in which case we can just return the minimum level
    if group == true then
        return MIN_LEVEL
    elseif group == false then
        return IMPOSSIBLE_LEVEL
    end

    if group == nil then
        --print("Item subclass missing: " .. slotName .. ' | ' .. subclassName)
        Professionator.Utils.addMissing(self:getId(), self:getSlotId(), slotName, subclassName)
        return IMPOSSIBLE_LEVEL
    end

    local className = Professionator.Utils.getClassNameFromId(classId)

    if group[className] then
        return group[className]       -- This returns the level required to equip the item
    end

    if (self:getId() .. '') == '10002' then
        print("slotName: " .. slotName .. " subclassName: " .. subclassName .. " name: " .. self:getName() .. " classId: " .. (group['Priest'] or 'nil'))
    end

    -- This class can never wear this item so just return a high number that no player can reach
    return IMPOSSIBLE_LEVEL

end
