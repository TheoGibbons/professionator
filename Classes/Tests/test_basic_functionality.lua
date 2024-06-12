local savedState
local setup = function ()
    savedState = ProfessionatorUnitTesting.setupEnvironment({
         possibleRecipes = {
             enchanting = {
                 [100] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 100,
                     name = "Test Recipe 1",
                     learned_at = 1,
                     grey = 50,
                 }),
                 [101] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 101,
                     name = "Test Recipe 2",
                     learned_at = 50,
                     grey = 200,
                 }),
             }
         },
         prices = {
             [100] = 10,
             [101] = 20,
         },
         playersInventory = Professionator.PlayersInventory:Create({
             inventory = {
                 [100] = 1,
                 [101] = 2,
             },
             bank = {
                 [100] = 3,
                 [101] = 4,
             },
         }),
     })
end

local tearDown = function ()
    ProfessionatorUnitTesting.setupEnvironment(savedState)
end

ProfessionatorUnitTesting.test_basic_functionality = function()

    print("Running basic functionality test...")

    setup()

    Professionator.Utils.tryCatchFinally(
        function()

            local calculationEngine = Professionator.CalculationEngine:Create("enchanting", 1, 100)
            local calculationResult = calculationEngine:Calculate()

            ProfessionatorUnitTesting.assert("Test Recipe 1", calculationResult:getRecipeAtLevel(1):getName(), "Recipe at level 1 should be Test Recipe 1")
            ProfessionatorUnitTesting.assert("Test Recipe 2", calculationResult:getRecipeAtLevel(50):getName(), "Recipe at level 50 should be Test Recipe 2")
            ProfessionatorUnitTesting.assert("Test Recipe 2", calculationResult:getRecipeAtLevel(99):getName(), "Recipe at level 99 should be Test Recipe 2")
            ProfessionatorUnitTesting.assert(nil, calculationResult:getRecipeAtLevel(100), "Recipe at level 100 should be nil")

            print("Test passed")

        end,
        function(e)
            print("Error: " .. e)
        end,
        tearDown
    )

end
