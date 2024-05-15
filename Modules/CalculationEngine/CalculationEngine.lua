-- CalculationEngine.lua

---@class CalculationEngine
---@field Initialize function
---@field Toggle function
---@field Show function
---@field Hide function

local CalculationEngine = ProfessionatorLoader:CreateModule("CalculationEngine")
local CharacterKnownRecipes = ProfessionatorLoader:ImportModule("CharacterKnownRecipes")
local ProfessionatorDB = ProfessionatorLoader:ImportModule("ProfessionatorDB")


-- Update the possibleRecipes table to include the cost of each recipe
local function addCostToCraft(professionName, recipes)

    for spellId, recipe in pairs(recipes) do

        recipes[spellId].costToCraft = Professionator.Utils.getRecipeCraftCost(professionName, spellId)

    end

    return recipes

end

-- Update the possibleRecipes table to include the cost of each recipe
local function addAdditionalBitsForRecipesAtLevel(recipesByLevel)

    for level, recipesAtThisLevel in pairs(recipesByLevel) do

        for key, recipe in pairs(recipesAtThisLevel) do

            recipesByLevel[level][key].chancePerCastToLevel = Professionator.Utils.chanceForCraftToLevel(level, recipe.grey, recipe.yellow)
            recipesByLevel[level][key].averageCastsToLevel = 1 / recipesByLevel[level][key].chancePerCastToLevel
            if recipesByLevel[level][key].costToCraft == nil then
                recipesByLevel[level][key].averageCostToLevel = nil
            else
                recipesByLevel[level][key].averageCostToLevel = recipesByLevel[level][key].costToCraft * recipesByLevel[level][key].averageCastsToLevel
            end

        end

    end

    return recipesByLevel

end

local function getRecipesByLevel(possibleRecipes, startLevel, endLevel)

    local recipesByLevel = {}

    for level = startLevel, endLevel do

        local recipes = {}

        for spellId, recipe in pairs(possibleRecipes) do

            -- Can the player make this recipe at this level?
            if recipe.learnedat <= level then

                -- is the recipe gray at this level?
                if recipe.grey > level then

                    table.insert(recipes, recipe)

                end

            end

        end

        recipesByLevel[level] = recipes

    end

    return recipesByLevel

end

local function getOrderedRecipesByLevel(recipesByLevel)

    local orderedRecipesByLevel = {}

    for level, recipesAtThisLevel in pairs(recipesByLevel) do

        Professionator.Utils.sortTable(recipesAtThisLevel, function(a, b)
            return a.averageCostToLevel < b.averageCostToLevel
        end)

        orderedRecipesByLevel[level] = recipesAtThisLevel

    end

    return orderedRecipesByLevel

end

local function calculate(professionName, knownRecipes, possibleRecipes, startLevel, endLevel)

    -- now we need to calculate the cost of each recipe
    possibleRecipes = addCostToCraft(professionName, possibleRecipes)

    -- now lets create an array from startLevel to endLevel
    -- where each element is an array of recipes that can be made at that level (excluding the ones that are grey)
    local recipesByLevel = getRecipesByLevel(possibleRecipes, startLevel, endLevel)

    recipesByLevel = addAdditionalBitsForRecipesAtLevel(recipesByLevel)

    -- now arrange the recipes by cost
    return getOrderedRecipesByLevel(recipesByLevel)

end


function CalculationEngine:Calculate(professionName, startLevel, endLevel)

    local knownRecipes = CharacterKnownRecipes:Get(professionName)
    local possibleRecipes = ProfessionatorDB[professionName]
    print("test: " .. professionName .. " " .. #possibleRecipes)
    --Professionator.Utils.debugPrint(possibleRecipes);

    return calculate(professionName, knownRecipes, possibleRecipes, startLevel, endLevel)

end
