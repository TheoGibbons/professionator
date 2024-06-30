local savedState
local setup = function ()
    savedState = ProfessionatorUnitTesting.setupEnvironment({
        possibleRecipes = {
            engineering = {
                [200] = ProfessionatorUnitTesting.mergeStandardRecipe({
                    id = 200,
                    name = "Test Engineering 2",
                    learned_at = 1,
                    yellow = 50,
                    grey = 50,
                    reagents = {
                        [22222] = {
                            name = 'Tin Bar',
                            quantity = 1,
                        },
                    },
                }),
                [201] = ProfessionatorUnitTesting.mergeStandardRecipe({
                    id = 201,
                    name = "Test Engineering 1",
                    learned_at = 1,
                    yellow = 50,
                    grey = 50,
                    reagents = {
                        [11111] = {
                            name = 'Copper Bar',
                            quantity = 2,
                        },
                    },
                }),
            }
        },
        prices = {
            [11111] = 5,        -- The price of two copper bars is > 1 tin bar. The price of 1 copper bar is < 1 tin bar.
            [22222] = 7,
        },
        playersInventory = Professionator.PlayersInventory:Create({
            inventory = {
                [100] = 3,
                [101] = 4,
            },
            bank = {
                [11111] = 5,
                [22222] = 0,
            },
        }),
    })
end

local tearDown = function ()
    ProfessionatorUnitTesting.setupEnvironment(savedState)
end

ProfessionatorUnitTesting.test_prioritize_recipe_with_inventory_reagents_4 = function()

    print("Running prioritize recipe with inventory reagents test 4...")

    setup()

    Professionator.Utils.tryCatchFinally(
        function()

            local calculationEngine = Professionator.CalculationEngine:Create("engineering", 1, 10)
            local calculationResult = calculationEngine:Calculate()
            local calculationRecipeGroup = calculationResult:GetRecipeGroups()

            -- Test to ensure that the recipe with Copper Bar is prioritized because it is in the inventory
            ProfessionatorUnitTesting.assert(201, calculationResult:getRecipeAtLevel(1):getId(), "Recipe at level 1 should be the 201 because 5 Copper Bar were in the inventory")
            ProfessionatorUnitTesting.assert(201, calculationResult:getRecipeAtLevel(2):getId(), "Recipe at level 2 should be the 201 because 3 Copper Bar were in the inventory")

            -- Test to ensure that when there is only one copper bar available in the inventory, the recipe with 1 tin is prioritized
            ProfessionatorUnitTesting.assert(201, calculationResult:getRecipeAtLevel(3):getId(), "Recipe at level 3 should be the 201 because there is only 1 Copper Bar in the inventory so we need to purchase 1 copper, which is cheaper than 1 tin")
            ProfessionatorUnitTesting.assert(200, calculationResult:getRecipeAtLevel(4):getId(), "Recipe at level 4 should be the 200 because there are no Copper Bar in the inventory so we need to purchase 2 copper, which is more expensive than 1 tin")

            print("Test passed")

        end,
        function(e)
            print("Error: " .. e)
        end,
        tearDown
    )

end
