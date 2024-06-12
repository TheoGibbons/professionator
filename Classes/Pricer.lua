--- @class Professionator.Pricer

local ProfessionatorDB = ProfessionatorLoader:ImportModule("ProfessionatorDB")

Professionator.PricerOverridePrices = nil

Professionator.Pricer = {

    -- Get the cost of an item from the auction house or vendor
    OverridePrices = function(prices)
        Professionator.PricerOverridePrices = prices
    end,

    -- Get the cost of an item from the auction house or vendor
    getItemCost = function(itemId)

        if Professionator.PricerOverridePrices ~= nil then
            return Professionator.PricerOverridePrices[itemId] or nil
        end

        local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemId)
        local auctionPrice = Auctionator.API.v1.GetAuctionPriceByItemID(AUCTIONATOR_L_REAGENT_SEARCH, itemId)

        return vendorPrice or auctionPrice
    end,

    -- Get the cost of a recipe from the auction house or vendor
    getRecipeCraftCost = function(professionName, spellId, inventory, quantity)

        if not professionName or not spellId or not inventory then
            Professionator.Utils.debugPrint("ERROR: Invalid input parameters")
            return nil
        end

        local possibleRecipes = ProfessionatorDB[professionName:lower()]

        if not possibleRecipes then
            -- Professionator.Utils.debugPrint("ERROR: No recipes found for profession '" .. professionName .. "'")
            return nil
        end

        local recipe = possibleRecipes[spellId]

        if not recipe then
            Professionator.Utils.debugPrint("ERROR: Recipe not found for spellId '" .. spellId .. "'")
            return nil
        end

        local cost = 0

        for reagentId, reagent in pairs(recipe.reagents) do

            local numberOfReagentsNeeded = reagent['quantity'] * quantity

            local unitPrice = Professionator.Pricer.getItemCost(reagentId)

            local inventoryQuantity = inventory:getItemQuantity(reagentId)
            print("reagentId:" .. reagentId .. " Inventory Quantity:" .. inventoryQuantity)

            local useThisManyFromInventory = math.min(numberOfReagentsNeeded, inventoryQuantity)

            inventory:removeItem(reagentId, useThisManyFromInventory)

            local acquireThisManyFromAuctionHouse = numberOfReagentsNeeded - useThisManyFromInventory

            if unitPrice ~= nil then
                cost = cost + (acquireThisManyFromAuctionHouse * unitPrice)
            end

        end

        return cost

    end,

}