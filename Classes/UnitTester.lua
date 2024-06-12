--- @class Professionator.UnitTester

local ProfessionatorDB = ProfessionatorLoader:ImportModule("ProfessionatorDB")

local PlayersInventoryModule = ProfessionatorLoader:ImportModule("PlayersInventoryModule")

local CharacterKnownRecipesModule = ProfessionatorLoader:ImportModule("CharacterKnownRecipesModule")

ProfessionatorUnitTesting = {

    RunTests = function()

        --ProfessionatorUnitTesting.test_inventory_item_quantity()
        --ProfessionatorUnitTesting.test_basic_functionality()
        --ProfessionatorUnitTesting.test_use_cheapest_recipe()
        --ProfessionatorUnitTesting.test_high_training_cost()
        --ProfessionatorUnitTesting.test_cast_time_penalty()
        --ProfessionatorUnitTesting.test_known_recipe()
        --ProfessionatorUnitTesting.test_prioritize_recipe_with_inventory_reagents()
        ProfessionatorUnitTesting.test_prioritize_recipe_with_inventory_reagents_2()

    end,

    -- Doing simply `ProfessionatorDB = newDB` will not work, so we need to do it this way
    overrideDB = function(newDB)
        for professionName, recipes in pairs(ProfessionatorDB) do
            if not newDB or newDB[professionName] == nil then
                ProfessionatorDB[professionName] = {}
            else
                ProfessionatorDB[professionName] = newDB[professionName]
            end
        end
    end,

    setupEnvironment = function(state)

        -- Save the current state
        local savedState = {
            possibleRecipes = Professionator.Utils.deepCopy(ProfessionatorDB),
            playersInventory = PlayersInventoryModule:GetInventory():Clone(),
            prices = nil,
            knownRecipes = Professionator.Utils.deepCopy(CharacterKnownRecipesModule.GetKnownRecipes()),
        }

        -- Override the DB so it only contains the test recipes
        ProfessionatorUnitTesting.overrideDB(state.possibleRecipes)

        -- Override the players inventory with the test inventory
        PlayersInventoryModule:SetInventory(state.playersInventory or Professionator.PlayersInventory:Create())

        -- Override the prices
        if state.prices == nil then
            Professionator.Pricer.OverridePrices(nil)
        else
            Professionator.Pricer.OverridePrices(state.prices)
        end

        -- Override the known recipes
        CharacterKnownRecipesModule:SetKnownRecipes(state.knownRecipes)

        -- Return the saved state so it can be restored after the test
        return savedState
    end,


    mergeStandardRecipe = function(t)
        local standardRecipe = {
            id = 7418,
            name = 'Enchant Bracer - Minor Health',
            recipe_source_alliance_short = 'Unknown',
            recipe_source_alliance_medium = 'Unknown',
            recipe_source_alliance_long = 'Unknown',
            recipe_source_horde_short = 'Unknown',
            recipe_source_horde_medium = 'Unknown',
            recipe_source_horde_long = 'Unknown',
            recipe_item_id_alliance = nil,
            recipe_item_id_horde = nil,
            recipe_item_id_bop = nil,
            training_cost = nil,
            cast_time = 5,
            learned_at = 1,
            red = 1,
            yellow = 50,
            green = 90,
            grey = 100,
            reagents = {
                [10940] = {
                    name = 'Strange Dust',
                    quantity = 1,
                },
            },
            tools = {
                [6218] = {
                    name = 'Runed Copper Rod',
                    quantity = 1,
                },
            },
        }

        return Professionator.Utils.mergeTable(standardRecipe, t)
    end,

    assert = function(expected, actual, message)
        if expected ~= actual then
            print("Test failed: " .. message)
            print("Expected: " .. tostring(expected))
            print("Actual: " .. tostring(actual))
            error("Test failed")
        end
    end,

}
