local savedState
local setup = function ()
    savedState = ProfessionatorUnitTesting.setupEnvironment({
         possibleRecipes = {
             enchanting = {
                 [100] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 100,
                     name = "Test Enchant 1",
                     learned_at = 1,
                     yellow = 1,
                     grey = 50,
                     reagents = {
                         [10940] = {
                             name = 'Strange Dust',
                             quantity = 1,
                         },
                     },
                 }),
                 [101] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 101,
                     name = "Test Enchant 2",
                     learned_at = 1,
                     grey = 50,
                     yellow = 1,
                     reagents = {
                         [1000] = {
                             name = 'reagent x',
                             quantity = 1,
                         },
                     },
                 }),
                 [102] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 102,
                     name = "Test Enchant 3",
                     learned_at = 1,
                     grey = 50,
                     yellow = 1,
                     reagents = {
                         [1001] = {
                             name = 'Reagent Y',
                             quantity = 1,
                         },
                     },
                 }),
             }
         },
         prices = {
             [10940] = 30,
             [1000] = 20,
             [1001] = 30,
         }
     })
end

local tearDown = function ()
    ProfessionatorUnitTesting.setupEnvironment(savedState)
end

ProfessionatorUnitTesting.test_use_cheapest_recipe = function()

    print("Running use cheapest recipe test...")

    setup()

    Professionator.Utils.tryCatchFinally(
        function()

            local calculationEngine = Professionator.CalculationEngine:Create("enchanting", 1, 3)
            local calculationResult = calculationEngine:Calculate()
            local calculationRecipeGroup = calculationResult:GetRecipeGroups()

            ProfessionatorUnitTesting.assert(101, calculationResult:getRecipeAtLevel(1):getId(), "Recipe at level 1 should be the 101")
            ProfessionatorUnitTesting.assert(101, calculationResult:getRecipeAtLevel(2):getId(), "Recipe at level 49 should be the 101")

            print("Test passed")

        end,
        function(e)
            print("Error: " .. e)
        end,
        tearDown
    )

end
