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
                     cast_time = 5,
                 }),
                 [101] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 101,
                     name = "Test Enchant 2",
                     learned_at = 1,
                     yellow = 1,
                     grey = 50,
                     cast_time = 4,
                 }),
                 [102] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 102,
                     name = "Test Enchant 3",
                     learned_at = 1,
                     yellow = 1,
                     grey = 50,
                     cast_time = 6,
                 }),
             }
         }
     })
end

local tearDown = function ()
    ProfessionatorUnitTesting.setupEnvironment(savedState)
end

ProfessionatorUnitTesting.test_cast_time_penalty = function()

    print("Running cast time penalty test...")

    setup()

    Professionator.Utils.tryCatchFinally(
        function()

            local calculationEngine = Professionator.CalculationEngine:Create("enchanting", 1, 30)
            local calculationResult = calculationEngine:Calculate()
            local calculationRecipeGroup = calculationResult:GetRecipeGroups()

            ProfessionatorUnitTesting.assert(101, calculationResult:getRecipeAtLevel(1):getId(), "Recipe at level 1 should be the 101")
            ProfessionatorUnitTesting.assert(101, calculationResult:getRecipeAtLevel(20):getId(), "Recipe at level 20 should be the 101")

            print("Test passed")

        end,
        function(e)
            print("Error: " .. e)
        end,
        tearDown
    )

end
