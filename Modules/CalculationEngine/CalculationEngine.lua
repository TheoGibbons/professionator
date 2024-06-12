Professionator.CalculationEngine = {}
Professionator.CalculationEngine.__index = Professionator.CalculationEngine
function Professionator.CalculationEngine:Create(professionName, startLevel, endLevel, BigRecipeList)

    -- Create a BigRecipeList if one is not provided
    if not BigRecipeList then
        BigRecipeList = Professionator.BigRecipeList:Create(professionName, startLevel, endLevel)
        BigRecipeList:Init()
    end

    local this =
    {
        professionName = professionName,
        BigRecipeList = BigRecipeList,
        startLevel = startLevel,
        endLevel = endLevel,
    }
    setmetatable(this, self)
    return this
end


local function getOrderedRecipesByLevel(recipesByLevel)

    local orderedRecipesByLevel = {}

    for level, recipesAtThisLevel in pairs(recipesByLevel) do

        orderedRecipesByLevel[level] = Professionator.Utils.sortTable(recipesAtThisLevel, function(a, b)
            return a.averageCostToLevel < b.averageCostToLevel
        end)

    end

    return orderedRecipesByLevel

end

function Professionator.CalculationEngine:Calculate()

    local result = {}

    -- Loop from startLevel to endLevel
    for level = self.startLevel, self.endLevel do

        local recipes = self.BigRecipeList.RecipeList[level]

        if recipes then

            local orderedRecipes = Professionator.Utils.sortTable(recipes, function(a, b)
                return a:getAverageCostToLevel(level) < b:getAverageCostToLevel(level)
            end)

            result[level] = orderedRecipes[1]

        end

    end

    self.result = result

    return self

end
