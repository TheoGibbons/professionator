
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

function Professionator.Recipe:getCostToCraft()
    return Professionator.Utils.getRecipeCraftCost(self.professionName, self:getSpellId())
end

function Professionator.Recipe:getAverageCostToLevel(level)
    return self:getCostToCraft() * self:getAverageCastsToLevel(level)
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
