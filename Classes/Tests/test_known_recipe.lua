
local CharacterKnownRecipesModule = ProfessionatorLoader:CreateModule("CharacterKnownRecipesModule")

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
                     training_cost = 10,
                 }),
                 [102] = ProfessionatorUnitTesting.mergeStandardRecipe({
                     id = 102,
                     name = "Test Enchant 3",
                     learned_at = 1,
                     grey = 50,
                     yellow = 1,
                     training_cost = 3,
                 }),
             }
         },
         prices = {
             [10940] = 1,
         },
         knownRecipes = {
            enchanting = {
                currentSkillLevel = 115,
                maxSkillLevel = 300,
                recipes = { 101 }
            }
         }
     })
end

local tearDown = function ()
    ProfessionatorUnitTesting.setupEnvironment(savedState)
end

ProfessionatorUnitTesting.test_known_recipe = function()

    print("Running known recipe test...")

    setup()

    Professionator.Utils.tryCatchFinally(
        function()

            local calculationEngine = Professionator.CalculationEngine:Create("enchanting", 1, 50)
            local calculationResult = calculationEngine:Calculate()

            ProfessionatorUnitTesting.assert(101, calculationResult:getRecipeAtLevel(1):getId(), "Recipe at level 1 should be the 101")
            ProfessionatorUnitTesting.assert(101, calculationResult:getRecipeAtLevel(49):getId(), "Recipe at level 49 should be the 101")

            print("Test passed")

        end,
        function(e)
            print("Error: " .. e)
        end,
        tearDown
    )

end
