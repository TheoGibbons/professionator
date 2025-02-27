local savedState
local setup = function ()
    savedState = ProfessionatorUnitTesting.setupEnvironment({
        possibleRecipes = {
            engineering = {
                [200] = ProfessionatorUnitTesting.mergeStandardRecipe({
                    id = 200,
                    name = "Test Engineering 2",
                    learned_at = 1,
                    grey = 50,
                    yellow = 1,
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
                    yellow = 1,
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
            [11111] = 100,
            [22222] = 2,
        },
        playersInventory = Professionator.PlayersInventory:Create({
            inventory = {
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

ProfessionatorUnitTesting.test_prioritize_recipe_with_inventory_reagents = function()

    print("Running prioritize recipe with inventory reagents test...")

    setup()

    Professionator.Utils.tryCatchFinally(
        function()

            local calculationEngine = Professionator.CalculationEngine:Create("engineering", 1, 3)
            local calculationResult = calculationEngine:Calculate()
            local calculationRecipeGroup = calculationResult:GetRecipeGroups()

            -- Test to ensure that the recipe with Copper Bar is prioritized because it is in the inventory
            ProfessionatorUnitTesting.assert(201, calculationResult:getRecipeAtLevel(1):getId(), "Recipe at level 1 should be the 201 because Copper Bar is in the inventory")

            print("Test passed")

        end,
        function(e)
            print("Error: " .. e)
        end,
        tearDown
    )

end
