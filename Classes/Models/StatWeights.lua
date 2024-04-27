--- @class StatWeights
Professionator.StatWeights = {}
Professionator.StatWeights.__index = Professionator.StatWeights

--- Creates a new StatWeights instance.
--- @param data table StatWeights data
--- @return StatWeights
function Professionator.StatWeights:Create(data)
    local this = setmetatable({}, self)
    this.data = data
    return this
end

--- Prints StatWeights data.
function Professionator.StatWeights:calculateScore(item)

    local score = 0

    -- For each stat
    for stat, weight in pairs(self.data) do
        local value = item:getStat(stat)
        if (value) then
            score = score + (value * weight)
        end
    end

    return score

end

