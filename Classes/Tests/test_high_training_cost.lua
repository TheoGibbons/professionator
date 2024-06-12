local savedState
local setup = function ()
    savedState = ProfessionatorUnitTesting.setupEnvironment({
         possibleRecipes = {
             enchanting = {
                 [100] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 100,
                     name = "Test Enchant 1",
                     learned_at = 1,
                     grey = 50,
                     yellow = 1,
                     training_cost = 2,
                 }),
                 [101] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 101,
                     name = "Test Enchant 2",
                     learned_at = 1,
                     grey = 50,
                     yellow = 1,
                     training_cost = 1,
                 }),
                 [102] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 102,
                     name = "Test Enchant 3",
                     learned_at = 1,
                     grey = 50,
                     yellow = 1,
                     training_cost = 3,
                 }),

                 [103] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 103,
                     name = "Test Enchant 4",
                     learned_at = 50,
                     grey = 100,
                     yellow = 1,
                     recipe_item_id_alliance = 400,
                     recipe_item_id_horde = 400,
                 }),
                 [104] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 104,
                     name = "Test Enchant 5",
                     learned_at = 50,
                     grey = 100,
                     yellow = 1,
                     recipe_item_id_alliance = 401,
                     recipe_item_id_horde = 401,
                 }),
                 [105] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 105,
                     name = "Test Enchant 6",
                     learned_at = 50,
                     grey = 100,
                     yellow = 1,
                     recipe_item_id_alliance = 402,
                     recipe_item_id_horde = 402,
                 }),
             }
         },
         prices = {
             [400] = 30,
             [401] = 20,
             [402] = 30,
             [10940] = 1,
         }
     })
end

local tearDown = function ()
    ProfessionatorUnitTesting.setupEnvironment(savedState)
end

ProfessionatorUnitTesting.test_high_training_cost = function()

    print("Running use higher training cost test...")

    setup()

    Professionator.Utils.tryCatchFinally(
        function()

            local calculationEngine = Professionator.CalculationEngine:Create("enchanting", 1, 100)
            local calculationResult = calculationEngine:Calculate()

            ProfessionatorUnitTesting.assert(101, calculationResult:getRecipeAtLevel(1):getId(), "Recipe at level 1 should be the 101")
            ProfessionatorUnitTesting.assert(101, calculationResult:getRecipeAtLevel(49):getId(), "Recipe at level 49 should be the 101")
            ProfessionatorUnitTesting.assert(104, calculationResult:getRecipeAtLevel(50):getId(), "Recipe at level 50 should be the 104")
            ProfessionatorUnitTesting.assert(104, calculationResult:getRecipeAtLevel(99):getId(), "Recipe at level 99 should be the 104")

            print("Test passed")

        end,
        function(e)
            print("Error: " .. e)
        end,
        tearDown
    )

end
