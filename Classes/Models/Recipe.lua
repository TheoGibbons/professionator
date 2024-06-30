
local CharacterKnownRecipesModule = ProfessionatorLoader:ImportModule("CharacterKnownRecipesModule")

Professionator.Recipe = {}
Professionator.Recipe.__index = Professionator.Recipe
function Professionator.Recipe:Create(professionName, data)
    local this =
    {
        professionName = professionName,
        data = data,
    }
    setmetatable(this, self)
    return this
end


function Professionator.Recipe:getChancePerCastToLevel(level)
    return Professionator.Utils.chanceForCraftToLevel(level, self:getGrey(), self:getYellow())
end

function Professionator.Recipe:getAverageCastsToLevel(level)
    return 1 / self:getChancePerCastToLevel(level)
end

function Professionator.Recipe:getCostToCraft(quantity, inventory)
    return Professionator.Pricer.getRecipeCraftCost(self.professionName, self:getSpellId(), inventory, quantity)
end

function Professionator.Recipe:getAverageCostToLevel(level, inventory)
    local casts = self:getAverageCastsToLevel(level)
    local cost = self:getCostToCraft(casts, inventory)

    if cost == nil then
        return math.huge
    end

    return cost
end

function Professionator.Recipe:getSpellId()
    return self.data.id
end

function Professionator.Recipe:getGrey()
    return self.data.grey
end

function Professionator.Recipe:getYellow()
    return self.data.yellow
end

function Professionator.Recipe:costToLearn(inventory)

     -- if the player already knows the recipe then the cost to learn is 0
     if CharacterKnownRecipesModule:KnowsRecipe(self.professionName, self.data.id) then
        return 0
    end

     -- if there is a value in training_cost then return that
    if self.data.training_cost ~= nil then
        return self.data.training_cost
    end

    -- if there is a value in recipe_item_id_alliance or recipe_item_id_horde
    local formulaId = nil
    if Professionator.Utils.isHorde() and self.data.recipe_item_id_horde then
        formulaId = self.data.recipe_item_id_horde
    elseif Professionator.Utils.isAlliance() and self.data.recipe_item_id_alliance then
        formulaId = self.data.recipe_item_id_alliance
    end

    if formulaId ~= nil then

        -- If the player has already purchased the formula then
        if inventory then
            if inventory:Contains(formulaId) then
                -- The cost to acquire this formula is zero
                return 0
            end
        end

        local formulaCost = Professionator.Pricer.getItemCost(formulaId)

        if formulaCost ~= nil then
            return formulaCost
        elseif self.data.recipe_item_id_bop == false then
            -- This probably means that this formula isn't on the AH
            --Professionator.Utils.dd("ERROR: No cost found for recipe " .. self.data.name .. " (" .. self.data.id .. ")" )
            return math.huge
        end

    end

    -- Some items have training_cost = nil and recipe_item_id_alliance = nil and recipe_item_id_horde = nil
    -- It seems that these are recipes that are given for free when you learn the profession
    -- EG: Enchant Bracer - Minor Health is given for free when you learn enchanting
    -- Or they are quest rewards
    -- EG: Tranquil Mechanical Yeti is a quest reward for completing Are We There, Yeti?
    -- EG: Sigil of Living Dreams is a quest reward
    -- So just return 0 in this case
    return 0
end

function Professionator.Recipe:canGiveSkillUp(level)

    -- Can the player make this recipe at this level?
    if self.data.learned_at <= level then

        -- is the recipe gray at this level?
        if self.data.grey > level then

            return true

        end

    end

    return false
end

function Professionator.Recipe:getCastTime()
    return self.data.cast_time
end

function Professionator.Recipe:getName()
    return self.data.name
end

function Professionator.Recipe:getId()
    return self.data.id
end

function Professionator.Recipe:getReagents()
    local reagents = {}

    for reagentId, reagent in pairs(self.data.reagents) do
        table.insert(reagents, {
            recipe = Professionator.Reagent:Create(self.professionName, reagentId, reagent),
            quantity = reagent.quantity,
        });
    end

    return reagents
end

function Professionator.Recipe:getSourceString(inventory)
    local ret = nil

    local costToLearn = self:costToLearn(inventory)

    local learnedAt = self.data.learned_at
    local recipeSource = self.data.recipe_source_alliance_long
    local recipeItemId = self.data.recipe_item_id_alliance

    if UnitFactionGroup("player") == "Horde" then
        recipeSource = self.data.recipe_source_horde_long
        recipeItemId = self.data.recipe_item_id_horde
    end

    if recipeSource ~= nil then
        ret = "Recipe Source (" .. learnedAt .. "):\n" .. recipeSource

        if self.data.recipe_item_id_bop == false and recipeItemId ~= nil then
            ret = ret .. "\nRecipe cost on AH: " .. Professionator.Utils.GetMoneyString(Professionator.Pricer.getItemCost(recipeItemId))
        elseif costToLearn ~= math.huge then
            ret = ret .. "\nCost to learn: " .. Professionator.Utils.GetMoneyString(costToLearn)
        end
    end

    return ret
end

function Professionator.Recipe:getCreatesItem()

    if self.data.creates_item ~= nil then
        return {
            id = self.data.creates_item[1],
            min = self.data.creates_item[2],
            max = self.data.creates_item[3],
        }
    end

    return nil
end