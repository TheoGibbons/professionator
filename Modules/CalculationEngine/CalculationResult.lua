-- The player doesn't want to be casting for 10 minutes to level up once. When they could cast 1 time using a different
-- recipe, even if casting for 10mins is cheaper.
-- So we need to add a penalty for cast time.
-- This number is expected to be from 0.0 to any number.
-- A user player who doesn't mind spending 10 minutes to save one copper could set this to 0.0
-- TODO add this to the options page so the user can set it.
local CAST_TIME_PENALTY = 0.02

local AVERAGE_LEVELS_A_RECIPE_IS_USED_FOR = 14

Professionator.CalculationResult = {}
Professionator.CalculationResult.__index = Professionator.CalculationResult
function Professionator.CalculationResult:Create(professionName, startLevel, endLevel, inventory)
    local this =
    {
        professionName = professionName,
        startLevel = startLevel,
        endLevel = endLevel,
        inventory = inventory,
        result = {},
    }
    setmetatable(this, self)
    return this
end

-- Lower score is better
function Professionator.CalculationResult:getPreliminaryScore()

    return self:getScore(true)

end

-- Lower score is better
function Professionator.CalculationResult:getScore(preliminaryCalc)

    local score = 0

    for level, data in pairs(self.result) do
        score = score + data.score
    end

    return score

end

function Professionator.CalculationResult:getScoreForRecipeAtLevel(recipe, level, preliminaryCalc)

    local inventory = self:getInventory(level-1):Clone()

    -- Average cost to level
    local cost = recipe:getAverageCostToLevel(level, inventory)

    -- Penalty to learn the recipe
    local penaltyToLearnRecipe = self:calculatePenaltyToLearnRecipe(recipe, level, preliminaryCalc, inventory)

    -- calculate a penalty for cast time that can be added to the cost
    local castTimePenalty = self:calculateCastTimePenalty(level, cost, recipe)

    return cost + penaltyToLearnRecipe + castTimePenalty

end


function Professionator.CalculationResult:getNumberLevelsRecipeIsUsedFor(recipe)

    local count = 0

    for level, data in pairs(self.result) do
        if recipe.id == data.recipe.id then
            count = count + 1
        end
    end

    return count

end

-- Calculate the penalty for learning the recipe. Lower is better
function Professionator.CalculationResult:calculatePenaltyToLearnRecipe(recipe, level, preliminaryCalc, inventory)

    local costToLearnRecipe = recipe:costToLearn(inventory)
    local penaltyToLearnRecipe

    if preliminaryCalc then
        -- Cost to learn the recipe
        -- We can't accurately calculate this until self.result is finalised.
        -- But we need the result of this to build self.result so it's a bit of a chicken and egg situation.
        -- I've calculated the average number of levels a recipe is used for is 14. So we could just divide the cost by 14
        -- for an estimate. This is not accurate
        penaltyToLearnRecipe = costToLearnRecipe / AVERAGE_LEVELS_A_RECIPE_IS_USED_FOR
    else
        -- Here we can get an accurate cost to learn the recipe because self.result is finalised
        penaltyToLearnRecipe = costToLearnRecipe / self:getNumberLevelsRecipeIsUsedFor(recipe)
    end

    return penaltyToLearnRecipe
end

-- Calculate the penalty for cast time. Lower is better
function Professionator.CalculationResult:calculateCastTimePenalty(level, cost, recipe)

    -- Cast time to level once
    local castTime = recipe:getCastTime() * recipe:getAverageCastsToLevel(level)

    -- TODO create a better formula for calculating this.
    -- I've done some playing round in Excel to get this formula which seems to work well for a CAST TIME PENALTY of 0.02
    -- But this can definitely be improved. Maybe some sort of exponential function?
    return cost * CAST_TIME_PENALTY * castTime
end


function Professionator.CalculationResult:placeRecipeAtLevel(recipe, level)

    -- place the recipe at the level
    self:setRecipeAtLevel(level, recipe)

    -- if the recipe has reagents that we can craft, place them in the result where they would be best crafted
    self:placeRecipeReagents(recipe, level)

end

function Professionator.CalculationResult:placeRecipeReagents(recipe, level)

    for reagentId, reagent in pairs(recipe:getReagents()) do

           -- TODO

        -- If the reagent is a recipe
        --if reagent:isCraftable() then


        --end

    end

end

function Professionator.CalculationResult:setRecipeAtLevel(level, recipe)
    self.result[level] = {
        recipe = recipe,
        score = self:getScoreForRecipeAtLevel(recipe, level, true)
    }
end

function Professionator.CalculationResult:getRecipeAtLevel(level)
    if self.result[level] == nil then
        return nil
    end
    return self.result[level].recipe
end

function Professionator.CalculationResult:Clone()

    local clone = Professionator.CalculationResult:Create(nil, nil, nil, nil)
    clone.result = Professionator.Utils.deepCopy(self.result)

    return clone

end

function Professionator.CalculationResult:GetRecipeGroups()

    local ret = {}
    local tempGroup = {}
    local tempRecipeId = nil

    for level, data in Professionator.Utils.orderedPairs(self.result) do

        tempGroup[level] = data.recipe

        if tempRecipeId ~= nil and tempRecipeId ~= data.recipe:getId() then

            table.insert(ret, Professionator.RecipeGroup:Create(tempGroup))
            tempGroup = {}

        end

        tempRecipeId = data.recipe:getId()

    end
    if next(tempGroup) ~= nil then
        table.insert(ret, Professionator.RecipeGroup:Create(tempGroup))
    end

    return ret

end

function Professionator.CalculationResult:getInventory()
    return self.inventory
end

function Professionator.CalculationResult:setInventory(inventory)
    self.inventory = inventory
end
