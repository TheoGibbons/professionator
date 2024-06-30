-- The player doesn't want to be casting for 10 minutes to level up once. When they could cast 1 time using a different
-- recipe, even if casting for 10mins is cheaper.
-- So we need to add a penalty for cast time.
-- This number is expected to be from 0.0 to any number.
-- A user player who doesn't mind spending 10 minutes to save one copper could set this to 0.0
-- TODO add this to the options page so the user can set it.
local SETTING_CAST_TIME_PENALTY = 0.02

local SETTING_AVERAGE_LEVELS_A_RECIPE_IS_USED_FOR = 14

local SETTING_INVENTORY_RECIPE_CREATES_ITEM_CALCULATION_METHOD = "AverageRoundRegular"

Professionator.CalculationResult = {}
Professionator.CalculationResult.__index = Professionator.CalculationResult
function Professionator.CalculationResult:Create(professionName, startLevel, endLevel, inventory)

    Professionator.Utils.dd("startLevel ABC")
    Professionator.Utils.dd(startLevel)

    if inventory == nil then
        error("inventory cannot be nil")
    end

    local this =
    {
        professionName = professionName,
        startLevel = startLevel,
        endLevel = endLevel,
        initialInventory = inventory,
        result = {},
        inventoryCache = {},
    }
    setmetatable(this, self)
    return this
end

function Professionator.CalculationResult:getScoreForRecipeAtLevel(recipe, level, preliminaryCalc)

    local inventory = self:getInventoryFromCache(level-1)
    --if inventory ~= nil then
    --    inventory = inventory:Clone()
    --end

    -- Average cost to level
    local cost = recipe:getAverageCostToLevel(level, inventory)

    -- Penalty to learn the recipe
    local penaltyToLearnRecipe = self:calculatePenaltyToLearnRecipe(recipe, level, preliminaryCalc, inventory)

    -- calculate a penalty for cast time that can be added to the cost
    local castTimePenalty = self:calculateCastTimePenalty(level, cost, recipe)

    Professionator.Utils.dd("cost: " .. cost .. " |penaltyToLearnRecipe: " .. penaltyToLearnRecipe .. " |castTimePenalty: " .. castTimePenalty .. " |total: " .. (cost + penaltyToLearnRecipe + castTimePenalty))

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
        penaltyToLearnRecipe = costToLearnRecipe / SETTING_AVERAGE_LEVELS_A_RECIPE_IS_USED_FOR
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
    return cost * SETTING_CAST_TIME_PENALTY * castTime
end


function Professionator.CalculationResult:placeRecipeAtLevel(recipe, level)

    -- place the recipe at the level
    self:setRecipeAtLevel(level, recipe)

    -- if the recipe has reagents that we can craft, place them in the result where they would be best crafted
    self:placeRecipeReagents(recipe, level)

    local score = self:updateScoreForLevel(level)

    return score

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
    }
end

function Professionator.CalculationResult:updateScoreForLevel(level)
    local recipe = self:getRecipeAtLevel(level)
    if recipe == nil then
        return math.huge
    end

    local score = self:getScoreForRecipeAtLevel(recipe, level, true)

    self.result[level].score = score

    return score
end

function Professionator.CalculationResult:getRecipeAtLevel(level)
    if self.result[level] == nil then
        return nil
    end
    return self.result[level].recipe
end

function Professionator.CalculationResult:saveRecipeAtLevel(level)
    if self.result[level] == nil then
        return nil
    end
    return self.result[level]
end

function Professionator.CalculationResult:restoreRecipeAtLevel(level, state)
    self.result[level] = state
end

function Professionator.CalculationResult:Clone()

    local clone = Professionator.CalculationResult:Create(self.professionName, self.startLevel, self.endLevel, self.initialInventory:Clone())
    clone.result = Professionator.Utils.deepCopy(self.result)
    clone.inventoryCache = Professionator.Utils.deepCopy(self.inventoryCache)

    return clone

end

function Professionator.CalculationResult:GetRecipeGroups()

    local ret = {}
    local tempGroup = {}
    local tempRecipeId = nil

    --Professionator.Utils.dd(self.result)

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

function Professionator.CalculationResult:getInventoryFromCache(level)

    if self.inventoryCache[level] == nil then
        self.inventoryCache[level] = self:calculateInventoryAtLevel(level)
    end

    return self.inventoryCache[level]
end

-- Calculate the inventory at a certain level
-- This is the inventory after crafting all the recipes from the start level to the level (inclusive)
-- If useCache is true (default) then we will try to use the inventory from the cache
-- If updateCache is true (default) then we will update the cache along the way
function Professionator.CalculationResult:calculateInventoryAtLevel(level, useCache, updateCache)

    -- Default values
    if useCache == nil then
        useCache = true
    end
    if updateCache == nil then
        updateCache = true
    end

    local inventoryTemp = nil
    local inventoryTempIndex = nil

    if useCache then
        if self.inventoryCache[level] ~= nil then
            return self.inventoryCache[level]
        end

        -- First loop backwards through the levels to try to find an inventory in the cache for a previous level we can use
        Professionator.Utils.dd("level=" .. level .. " | startLevel=" .. self.startLevel)
        for i = level, self.startLevel, -1 do
            if self.inventoryCache[i] ~= nil then
                inventoryTemp = self.inventoryCache[i]:Clone()
                inventoryTempIndex = i
                break
            end
        end

    end

    -- Now inventoryTempIndex = the level of the inventory in the cache we can use
    -- inventoryTemp is now the inventory at level inventoryTempIndex OR it is nil

    -- If inventoryTemp is still nil, use initialInventory
    if inventoryTemp == nil then
        inventoryTemp = self.initialInventory:Clone()
        inventoryTempIndex = self.startLevel
    end

    -- Loop from inventoryTempIndex to level and update inventory
    for i = inventoryTempIndex, level do
        local recipe = self:getRecipeAtLevel(i)
        if recipe ~= nil then

            -- Remove the reagents
            for _, reagent in pairs(recipe:getReagents()) do
                inventoryTemp:removeItem(reagent.recipe:getId(), reagent.quantity)
            end

            -- Add the result of the recipe
            local createsItem = recipe:getCreatesItem()

            if createsItem ~= nil then

                -- Creates Item ID
                local createsItemId = createsItem.id
                local createsMinQuantity = createsItem.min
                local createsMaxQuantity = createsItem.max

                local amountToAddToInventory = self:calculateAmountToAddToInventory(createsMinQuantity, createsMaxQuantity)
                
                inventoryTemp:add(createsItemId, amountToAddToInventory)
            end

            -- Update cache if necessary
            if updateCache then
                self.inventoryCache[i] = inventoryTemp:Clone()  -- Assuming Clone() deep copies the inventory
            end

        end
    end

    return inventoryTemp
end

function Professionator.CalculationResult:calculateAmountToAddToInventory(createsMin, createsMax)

    -- What's best to do here:
    -- 1. Add average quantity to inventory. But then we could have 1.5 items added to inventory
    -- 2. Add min quantity to inventory.
    -- 3. Add average quantity rounded either: a) ceil b) floor c) regular.
    local amountToAddToInventory

    if SETTING_INVENTORY_RECIPE_CREATES_ITEM_CALCULATION_METHOD == "Average" then
        amountToAddToInventory = (createsMin + createsMax) / 2
    elseif SETTING_INVENTORY_RECIPE_CREATES_ITEM_CALCULATION_METHOD == "Min" then
        amountToAddToInventory = createsMin
    elseif SETTING_INVENTORY_RECIPE_CREATES_ITEM_CALCULATION_METHOD == "AverageRoundCeil" then
        amountToAddToInventory = math.ceil((createsMin + createsMax) / 2)
    elseif SETTING_INVENTORY_RECIPE_CREATES_ITEM_CALCULATION_METHOD == "AverageRoundFloor" then
        amountToAddToInventory = math.floor((createsMin + createsMax) / 2)
    elseif SETTING_INVENTORY_RECIPE_CREATES_ITEM_CALCULATION_METHOD == "AverageRoundRegular" then
        amountToAddToInventory = Professionator.Utils.round((createsMin + createsMax) / 2)
    else
        error("Invalid setting for SETTING_INVENTORY_RECIPE_CREATES_ITEM_CALCULATION_METHOD")
    end

    return amountToAddToInventory
end