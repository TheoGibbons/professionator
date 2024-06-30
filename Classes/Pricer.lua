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
    -- NOTE Quantity is not necessarily an integer, because averages are used
    getRecipeCraftCost = function(professionName, spellId, inventory, quantity)

        if not professionName or not spellId then
            Professionator.Utils.debugPrint({ "ERROR: Invalid input parameters", professionName, spellId })
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

            local useThisManyFromInventory = 0

            if inventory ~= nil then
                local inventoryQuantity = inventory:getItemQuantity(reagentId)
                --Professionator.Utils.dd("reagentId:" .. reagentId .. " Inventory Quantity:" .. inventoryQuantity)

                Professionator.Utils.dd({ "inventory before:" , inventory.items })

                useThisManyFromInventory = math.min(numberOfReagentsNeeded, inventoryQuantity)

                Professionator.Utils.dd("useThisManyFromInventory: " .. useThisManyFromInventory .. " | reagentId: " .. reagentId .. " | spellId: " .. spellId .. " | quantity: " .. quantity .. " | reagent['quantity']: " .. reagent['quantity'])

                if useThisManyFromInventory > 0 then
                    local removed = inventory:removeItem(reagentId, useThisManyFromInventory)
                    Professionator.Utils.dd("removed: " .. removed)
                end
                Professionator.Utils.dd({ "inventory after:" , inventory.items })
            end

            local acquireThisManyFromAuctionHouse = numberOfReagentsNeeded - useThisManyFromInventory

            if unitPrice ~= nil then
                cost = cost + (acquireThisManyFromAuctionHouse * unitPrice)
            end
            Professionator.Utils.dd("acquireThisManyFromAuctionHouse: " .. acquireThisManyFromAuctionHouse .. " | reagentId: " .. reagentId .. " | spellId: ")

        end
        Professionator.Utils.dd("cost: " .. cost)

        return cost

    end,

}