
-- for example from level 1-19 you might craft "Enchant Minor Stats"
-- Then 20-30 you might craft "Enchant Lesser Stats"
-- There is no need to print 30 rows for this let's combine them into 2 rows

Professionator.RecipeGroup = {}
Professionator.RecipeGroup.__index = Professionator.RecipeGroup
function Professionator.RecipeGroup:Create(group)
    local this =
    {
        group = group,
    }
    setmetatable(this, self)
    return this
end

function Professionator.RecipeGroup:getMinLevel()
    local minLevel = nil
    for level, _ in pairs(self.group) do
        if minLevel == nil or level < minLevel then
            minLevel = level
        end
    end
    return minLevel
end

function Professionator.RecipeGroup:getMaxLevel()
    local maxLevel = nil
    for level, _ in pairs(self.group) do
        if maxLevel == nil or level > maxLevel then
            maxLevel = level
        end
    end
    return maxLevel
end

function Professionator.RecipeGroup:getRecipe()
    return Professionator.Utils.ArrayFirst(self.group)
end

function Professionator.RecipeGroup:getAverageCastsToLevel()
    local averageCastsToLevel = 0
    for level, recipe in pairs(self.group) do
        averageCastsToLevel = averageCastsToLevel + recipe:getAverageCastsToLevel(level)
    end
    return averageCastsToLevel
end

function Professionator.RecipeGroup:getAverageCostToLevel()
    return self:getAverageCastsToLevel() * self:getRecipe():getCostToCraft()
end

function Professionator.RecipeGroup:getMinChancePerCastToLevel()
    local minChancePerCastToLevel = nil
    for level, recipe in pairs(self.group) do
        local chancePerCastToLevel = recipe:getChancePerCastToLevel(level)
        if minChancePerCastToLevel == nil or chancePerCastToLevel < minChancePerCastToLevel then
            minChancePerCastToLevel = chancePerCastToLevel
        end
    end
    return minChancePerCastToLevel
end

function Professionator.RecipeGroup:getMaxChancePerCastToLevel()
    local maxChancePerCastToLevel = nil
    for level, recipe in pairs(self.group) do
        local chancePerCastToLevel = recipe:getChancePerCastToLevel(level)
        if maxChancePerCastToLevel == nil or chancePerCastToLevel > maxChancePerCastToLevel then
            maxChancePerCastToLevel = chancePerCastToLevel
        end
    end
    return maxChancePerCastToLevel
end

function Professionator.RecipeGroup:castTime()
    return self:getAverageCastsToLevel() * self:getRecipe():getCastTime()
end
