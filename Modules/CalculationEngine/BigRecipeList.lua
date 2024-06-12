
local CharacterKnownRecipes = ProfessionatorLoader:ImportModule("CharacterKnownRecipes")
local ProfessionatorDB = ProfessionatorLoader:ImportModule("ProfessionatorDB")

Professionator.BigRecipeList = {}
Professionator.BigRecipeList.__index = Professionator.BigRecipeList
function Professionator.BigRecipeList:Create(professionName, startLevel, endLevel)
    local this =
    {
        professionName = professionName,
        startLevel = startLevel,
        endLevel = endLevel,
        RecipeList = null,
    }
    setmetatable(this, self)
    return this
end


function Professionator.BigRecipeList:getRecipesByLevel(possibleRecipes, startLevel, endLevel)

    local recipesByLevel = {}

    for level = startLevel, endLevel do

        local recipes = {}

        for spellId, recipe in pairs(possibleRecipes) do

            -- Can the player make this recipe at this level?
            if recipe.learnedat <= level then

                -- is the recipe gray at this level?
                if recipe.grey > level then

                    table.insert(recipes, Professionator.Recipe:Create(self.professionName, Professionator.Utils.deepCopy(recipe)))

                end

            end

        end

        recipesByLevel[level] = recipes

    end

    return recipesByLevel

end

function Professionator.BigRecipeList:Init()

    local knownRecipes = CharacterKnownRecipes:Get(self.professionName)
    local possibleRecipes = ProfessionatorDB[self.professionName]

    -- now lets create an array from startLevel to endLevel
    -- where each element is an array of recipes that can be made at that level (excluding the ones that are grey)
    local recipesByLevel = self:getRecipesByLevel(possibleRecipes, self.startLevel, self.endLevel)

    self.RecipeList = recipesByLevel

end