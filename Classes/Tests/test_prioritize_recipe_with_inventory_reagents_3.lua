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
                [202] = ProfessionatorUnitTesting.mergeStandardRecipe({
                    id = 202,
                    name = "Test Engineering 3",
                    learned_at = 1,
                    grey = 50,
                    yellow = 1,
                    reagents = {
                        [11111] = {
                            name = 'Copper Bar',
                            quantity = 10,
                        },
                    },
                }),
                [203] = ProfessionatorUnitTesting.mergeStandardRecipe({
                    id = 203,
                    name = "Test Engineering 4",
                    learned_at = 1,
                    grey = 50,
                    yellow = 1,
                    reagents = {
                        [11111] = {
                            name = 'Copper Bar',
                            quantity = 1,
                        },
                        [22222] = {
                            name = 'Tin Bar',
                            quantity = 2,
                        },
                    },
                }),
                [204] = ProfessionatorUnitTesting.mergeStandardRecipe({
                    id = 204,
                    name = "Test Engineering 5",
                    learned_at = 1,
                    grey = 50,
                    yellow = 1,
                    reagents = {
                        [11111] = {
                            name = 'Copper Bar',
                            quantity = 1,
                        },
                        [22222] = {
                            name = 'Tin Bar',
                            quantity = 1,
                        },
                    },
                }),
            }
        },
        prices = {
            [11111] = 15,
            [22222] = 25,
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

ProfessionatorUnitTesting.test_prioritize_recipe_with_inventory_reagents_3 = function()

    print("Running prioritize recipe with inventory reagents test 3...")

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
