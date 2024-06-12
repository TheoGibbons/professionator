
local ProfessionatorDB = ProfessionatorLoader:ImportModule("ProfessionatorDB")

Professionator.Reagent = {}
Professionator.Reagent.__index = Professionator.Reagent
function Professionator.Reagent:Create(professionName, id, data)
    local this =
    {
        professionName = professionName,
        id = id,
        data = data,
    }
    setmetatable(this, self)
    return this
end

function Professionator.Reagent:getCraftingRecipe()
    return ProfessionatorDB[self.professionName][self.id]
end