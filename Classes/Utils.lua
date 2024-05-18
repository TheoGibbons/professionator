--- @class Professionator.Utils

local ProfessionatorDB = ProfessionatorLoader:ImportModule("ProfessionatorDB")

Professionator.Utils = {

    -- GetSpellIdFromSpellName
    -- @param professionName string EG "Enchanting", "Tailoring"
    -- @param spellName string EG "Enchant Bracer - Minor Health", "Bolt of Linen Cloth"
    -- @return number OR nil
    GetSpellIdFromSpellName = function(professionName, spellName)

        professionName = professionName:lower()

        local possibleRecipes = ProfessionatorDB[professionName] or nil

        if possibleRecipes == nil then
            DEFAULT_CHAT_FRAME:AddMessage("ERROR: Unknown profession '" .. professionName .. "'", 1, 0, 0)
            return nil
        end

        for spellId, recipe in pairs(possibleRecipes) do
            if recipe.name == spellName then
                return spellId
            end
        end

        return nil

    end,

    print = function(string, colour)
        if ItemPlannerDebugPrint and type(ItemPlannerDebugPrint.print) == "function" then

            if colour then
                string = Professionator.Utils.colourText(string, colour)
            end

            ItemPlannerDebugPrint:print(string)
        else
            print(string)
        end
    end,

    colourText = function(inputString, color)
        -- Escape any existing color codes in the input string
        local escapedString = inputString:gsub("|", "||")
        -- Construct the colored text with the provided color
        return "|c" .. color .. escapedString .. "|r"
    end,

    dd = function(value)
        Professionator.Utils.print(Professionator.Utils.dumpVariable(value))
    end,

    debugPrint = function(value)
        if Professionator.settings.debugEnabled then
            Professionator.Utils.print(Professionator.Utils.dumpVariable(value))
        end
    end,

    isArray = function(table)
        local isArray = true
        local i = 1
        for k, _ in pairs(table) do
            if k ~= i then
                isArray = false
                break
            end
            i = i + 1
        end

        return isArray
    end,

    dumpVariable = function(var, indent)
        indent = indent or 0
        local result = ""
        local varType = type(var)
        if varType == "table" then
            local isArray = Professionator.Utils.isArray(var)
            if isArray then
                result = result .. "[ "
                local first = true
                for _, v in ipairs(var) do
                    if not first then
                        result = result .. ", "
                    end
                    result = result .. Professionator.Utils.dumpVariable(v, indent)
                    first = false
                end
                result = result .. " ]"
            else
                result = result .. "{\n"
                for k, v in pairs(var) do
                    result = result .. string.rep(" ", indent + 4) .. "\"" .. k .. "\": "
                    result = result .. Professionator.Utils.dumpVariable(v, indent + 4) .. ",\n"
                end
                result = result .. string.rep(" ", indent) .. "}"
            end
        elseif varType == "string" then
            result = result .. "\"" .. var .. "\""
        elseif varType == "boolean" or var == nil then
            result = result .. tostring(var)
        else
            result = result .. var
        end
        return result
    end,

    getRecipeCraftCost = function(professionName, spellId)

        if professionName == 'enchanting' then
            return Professionator.Utils.getEnchantingCraftCost(professionName, spellId)
        else
            return Professionator.Utils.getCraftCost(professionName, spellId)
        end

    end,

    getLinkFromItemId = function(itemId)

        local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
        GetItemInfo(itemId)

        return itemLink

    end,

    -- Enchanting is different to all other professions for some reason
    getItemCost = function(itemId)
        local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemId)
        local auctionPrice = Auctionator.API.v1.GetAuctionPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemId)

        return vendorPrice or auctionPrice
    end,

    -- Enchanting is different to all other professions for some reason
    getEnchantingCraftCost = function(professionName, spellId)

        -- Make sure we're only calling this for Enchanting
        if professionName ~= 'enchanting' then
            Professionator.Utils.debugPrint("ERROR: getEnchantingCraftCost called with professionName '" .. professionName .. "'")
            return nil
        end

        local possibleRecipes = ProfessionatorDB[professionName:lower()] or nil
        local recipe = possibleRecipes[spellId] or nil

        if recipe == nil then
            Professionator.Utils.debugPrint("ERROR: Recipe not found for spellId '" .. spellId .. "'")
            return nil
        end

        local cost = 0

        for reagentId, reagent in pairs(recipe.reagents) do
            local link = Professionator.Utils.getLinkFromItemId(reagentId)
            if link ~= nil then

                local quantity = reagent['quantity']

                local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, link)
                local auctionPrice = Auctionator.API.v1.GetAuctionPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, link)

                local unitPrice = vendorPrice or auctionPrice

                if unitPrice ~= nil then
                    cost = cost + (quantity * unitPrice)
                end
            end

        end

        return cost

    end,

    -- This works for all professions except Enchanting
    getCraftCost = function(professionName, spellId)

        -- Make sure we're only calling this for Enchanting
        if professionName == 'enchanting' then
            Professionator.Utils.debugPrint("ERROR: getCraftCost called with professionName '" .. professionName .. "'")
            return nil
        end

        -- TODO
        Professionator.Utils.debugPrint("ERROR: TODO")
    end,

    formatNumericWithCommas = function(amount)
        local k
        while true do
            amount, k = tostring(amount):gsub("^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then
                break
            end
        end
        return amount
    end,

    GetMoneyString = function(amount)
        if amount == nil then
            return "none"
        end
        if amount > 0 then
            local formatted
            local gold,silver,copper = math.floor(amount / 100 / 100), math.floor((amount / 100) % 100), math.floor(amount % 100)
            if gold > 0 then
                formatted = Professionator.Utils.formatNumericWithCommas(gold) .. "|TInterface\\MONEYFRAME\\UI-GoldIcon:0|t"
            end
            if silver > 0 then
                formatted = (formatted or "") .. silver .. "|TInterface\\MONEYFRAME\\UI-SilverIcon:0|t"
            end
            if copper > 0 then
                formatted = (formatted or "") .. copper .. "|TInterface\\MONEYFRAME\\UI-CopperIcon:0|t"
            end
            return formatted
        end
        return amount
    end,

    -- Sort a table by the value of a field in the table
    -- Lua's table.sort() is limited by the fact that it only works on tables with sequential numeric keys
    -- This function is not limited in that way
    -- @param tbl table EG: { [-1] = { index = 3, name = "y" }, [0] = { index = 2, name = "z" }, ["hello"] = { index = 8, name = "world" }}
    -- @param sortFunc function EG: function(a, b) return a.index < b.index end
    -- @return table with sequential numeric keys (original keys are lost)
    --      EG: { [1] = { index = 2, name = "z" }, [2] = { index = 2, name = "z" }, [3] = { index = 8, name = "world" }}
    sortTable = function(tbl, sortFunc)
        local sequence = {}
        for k, v in pairs(tbl) do
            table.insert(sequence, v)
        end

        table.sort(sequence, function(a, b)
            return sortFunc(a, b)
        end)

        return sequence
    end,

    -- Crafting "Enchant Bracer - Minor Stamina" at skill level 125 has a chance of leveling up the Enchanting skill of 37.5%
    -- This function calculates that percentage
    -- @see https://www.reddit.com/r/woweconomy/comments/9epibc/crafting_skillups_exact_skillup_chance/
    chanceForCraftToLevel = function(level, grey, yellow)
        local percent = (grey - level) / (grey - yellow)
        return math.min(1, math.max(0, percent))
    end,

    -- pass in a number like 0.1234567
    -- get back a number like 12%
    prettyPercentage = function(percentage)
        percentage = Professionator.Utils.sigfig(percentage)
        return (percentage * 100) .. '%'
    end,

    -- EG:
    -- 0.1234567 -> 0.12
    -- 1234567 -> 1200000
    sigfig = function(number, figures)
        figures = figures or 2  -- default to 2 significant figures
        local scale = 10 ^ (figures - math.floor(math.log10(math.abs(number))) - 1)
        local rounded = math.floor(number * scale + 0.5) / scale
        return rounded
    end,

    -- This deepCopy function recursively copies tables and their contents, ensuring that original is an independent
    -- copy of the result rather than just referencing the same table.
    deepCopy = function(original)
        local copy
        if type(original) == "table" then
            copy = {}
            for k, v in pairs(original) do
                copy[k] = Professionator.Utils.deepCopy(v)
            end
        else
            copy = original
        end
        return copy
    end,

    tableMin = function(t)
        local minValue = math.huge -- Initialize with a large value
        for _, v in pairs(t) do
            if v < minValue then
                minValue = v
            end
        end
        return minValue
    end,

    tableMax = function(t)
        local maxValue = -math.huge -- Initialize with a very small value
        for _, v in pairs(t) do
            if v > maxValue then
                maxValue = v
            end
        end
        return maxValue
    end,

    round = function(num)
        return math.floor(num + 0.5)
    end,

    -- lua has #table to get the length of a table, but it only works for tables with sequential numeric keys
    arrayLength = function(arr)
        local count = 0
        for _ in pairs(arr) do
            count = count + 1
        end
        return count
    end,

    -- In lua pairs doesn't guarantee the order of keys
    -- This function returns an iterator that will return the keys in order
    -- Only works for tables with numeric keys
    orderedPairs = function(t)
        local keys = {}
        for k in pairs(t) do
            keys[#keys + 1] = k
        end
        table.sort(keys)
        local i = 0
        return function()
            i = i + 1
            if keys[i] then
                return keys[i], t[keys[i]]
            end
        end
    end,

    arrayUnique = function(arr)
        local unique = {}
        for _, v in ipairs(arr) do
            unique[v] = true
        end
        local result = {}
        for k, _ in pairs(unique) do
            table.insert(result, k)
        end
        return result
    end,

    implode = function(separator, arr)
        local result = ""
        local firstItem = true
        for _, v in ipairs(arr) do
            if not firstItem then
                result = result .. separator
            end
            result = result .. v
            firstItem = false
        end
        return result
    end,

}