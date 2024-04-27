--- @class Professionator.Utils


local ProfessionatorDB = ProfessionatorLoader:ImportModule("ProfessionatorDB")

local missing = {};

Professionator.Utils = {

    addBackgroundTexture = function(widget, r, g, b, a)

        r = r or 200
        g = g or 200
        b = b or 200
        a = a or 0.5

        -- Add a texture to simulate the background color
        local bgTexture = widget.frame:CreateTexture(nil, "BACKGROUND")
        bgTexture:SetColorTexture(r, g, b, a)  -- Set the background color (RGBA: 0, 0, 0, 0.3)
        bgTexture:SetAllPoints(widget.frame)
    end,

    base64DecodeUrlSafe = function(data)

        data = string.gsub(data, "+", ".")
        data = string.gsub(data, "/", "_")
        data = string.gsub(data, "=", "-")

        return base64.decode(data)

    end,

    base64EncodeUrlSafe = function(data)

        local ret = base64.encode(data)

        ret = string.gsub(ret, "+", ".")
        ret = string.gsub(ret, "/", "_")
        ret = string.gsub(ret, "=", "-")

        return ret

    end,

    -- Create a deep copy of a table
    deepCopy = function(original)
        local copy = {}

        -- If the original is not a table then return it
        if type(original) ~= "table" then
            return original
        end

        for key, value in pairs(original) do
            if type(value) == "table" then
                copy[key] = Professionator.Utils.deepCopy(value)
            else
                copy[key] = value
            end
        end
        return copy
    end,

    getAllItemsAsClasses = function()

        -- Create a deep copy of the item data
        local items = Professionator.Utils.deepCopy(ProfessionatorDB.itemData)

        -- Convert the item data into Item instances
        for slotId, itemsInSlot in pairs(items) do

            for itemId, item in pairs(itemsInSlot) do
                itemsInSlot[itemId] = Professionator.Item:Create(item)
            end

        end

        return items

    end,

    getSlotIdByName = function(name)

        -- If name isn't an array then convert it to an array
        if (type(name) ~= "table") then
            name = { name }
        end

        for slotId, slotName in pairs(ProfessionatorDB.slotNames) do
            for _, nameToMatch in pairs(name) do
                if (slotName == nameToMatch) then
                    return slotId
                end
            end
        end

        -- Throw error
        error("Invalid slot name: " .. table.concat(name, "/"))

    end,

    getDefaultStatWeights = function()

        return Professionator.StatWeights:Create({
            ["intellect"] = 10,
            ["strength"] = 10,
            ["stamina"] = 50,
        })

    end,

    tableLimit = function(inputTable, n)
        local count = 0
        local newTable = {}

        -- Iterate through the original table and copy the first n elements to a new table
        for key, value in pairs(inputTable) do
            count = count + 1
            if count <= n then
                newTable[key] = value
            else
                break
            end
        end

        return newTable

    end,

    tableCountKeys = function(inputTable)
        local count = 0
        for _, _ in pairs(inputTable) do
            count = count + 1
        end
        return count
    end,

    -- Pass in EG "Warrior" and it will return 1
    inArray = function(needle, haystack)
        for _, value in ipairs(haystack) do
            if (value == needle) then
                return true
            end
        end
        return false
    end,

    -- Pass in EG 5 and it will return "Chest"
    -- @see ProfessionatorDB.slotNames
    getSlotNameFromId = function(slotId)
        return ProfessionatorDB.slotNames[slotId]
    end,

    -- Pass in EG 5 and it will return "Chest"
    -- @see ProfessionatorDB.slotNames
    getSubclassNameFromId = function(itemSubClassId)
        return ProfessionatorDB.itemSubclassMap[itemSubClassId]
    end,

    -- Pass in EG 5 and it will return "Priest"
    -- @see ProfessionatorDB.classMap
    getClassNameFromId = function(classId)
        return ProfessionatorDB.classMap[classId]
    end,

    getFactionNameFromId = function(factionId)
        return ProfessionatorDB.factions[factionId]
    end,

    getFactionIdByName = function(factionName)
        for factionId, name in pairs(ProfessionatorDB.factions) do
            if (name == factionName) then
                return factionId
            end
        end
        error(factionName .. " is not a valid faction name")
    end,

    -- @see ProfessionatorDB.races
    getRaceIdByName = function(raceName)
        for raceId, name in pairs(ProfessionatorDB.races) do
            if (name == raceName) then
                return raceId
            end
        end
        error(raceName .. " is not a valid race name")
    end,

    -- @see ProfessionatorDB.races
    getRaceNameFromId = function(raceId)
        return ProfessionatorDB.races[raceId]
    end,

    -- Pass in EG "Priest" and it will return 5
    -- @see ProfessionatorDB.classMap
    getClassIdByName = function(className)
        for classId, name in pairs(ProfessionatorDB.classMap) do
            if (name == className) then
                return classId
            end
        end
        error(className .. " is not a valid class name")
    end,

    missing = {},

    addMissing = function(itemId, slot, slotName, subclassName)
        -- Add to the missing array if it isn't already in there
        if (slot and not Professionator.Utils.missing[slot]) then
            Professionator.Utils.missing[slot] = {}
        end

        if slot and slotName then
            if (not Professionator.Utils.missing[slot][slotName]) then
                Professionator.Utils.missing[slot][slotName] = {
                    ['count'] = 1,
                    ['subclasses'] = {},
                    ['items'] = { itemId }
                }
            else
                Professionator.Utils.missing[slot][slotName]['count'] = Professionator.Utils.missing[slot][slotName]['count'] + 1
                table.insert(Professionator.Utils.missing[slot][slotName]['items'], itemId)

            end
        end

        if slot and slotName and subclassName then

            if (not Professionator.Utils.missing[slot][slotName]['subclasses'][subclassName]) then
                Professionator.Utils.missing[slot][slotName]['subclasses'][subclassName] = {}
                Professionator.Utils.missing[slot][slotName]['subclasses'][subclassName]['count'] = 1
                Professionator.Utils.missing[slot][slotName]['subclasses'][subclassName]['items'] = { itemId }
            else
                Professionator.Utils.missing[slot][slotName]['subclasses'][subclassName]['count'] = Professionator.Utils.missing[slot][slotName]['subclasses'][subclassName]['count'] + 1
                table.insert(Professionator.Utils.missing[slot][slotName]['subclasses'][subclassName]['items'], itemId)
            end

        end
    end,

    printAllMissing = function()
        print("These slots are missing from the ProfessionatorDB.armorProficiencies map:")
        for slot, slotData in pairs(Professionator.Utils.missing) do
            print("Slot: " .. slot)
            for slotName, slotNameData in pairs(slotData) do

                local firstTwoItems = Professionator.Utils.arraySlice(slotNameData['items'], 1, 5)
                firstTwoItems = table.concat(firstTwoItems, ", ")

                print("  Slot Name: " .. slotName .. " (" .. slotNameData['count'] .. ") [" .. firstTwoItems .. "]")
                for subclassName, subclass in pairs(slotNameData['subclasses']) do

                    firstTwoItems = Professionator.Utils.arraySlice(subclass['items'], 1, 5)
                    firstTwoItems = table.concat(firstTwoItems, ", ")

                    print("    Subclass: " .. subclassName .. " (" .. subclass['count'] .. ") [" .. firstTwoItems .. "]")
                end
            end
        end
    end,

    arraySlice = function(array, start, stop)
        local ret = {}
        for i = start, stop do
            if array[i] then
                table.insert(ret, array[i])
            end
        end
        return ret
    end,

    print = function(string, colour)
        if ProfessionatorDebugPrint and type(ProfessionatorDebugPrint.print) == "function" then

            if colour then
                string = Professionator.Utils.colourText(string, colour)
            end

            ProfessionatorDebugPrint:print(string)
        else
            print(string)
        end
    end,

    colourText = function(string, color)
        return "|c" .. color .. string.gsub(string, "|", "||") .. "|r"
    end,

}