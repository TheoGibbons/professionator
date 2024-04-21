--- @class StatWeights
ItemPlanner.StatWeights = {}
ItemPlanner.StatWeights.__index = ItemPlanner.StatWeights

--- Creates a new StatWeights instance.
--- @param data table StatWeights data
--- @return StatWeights
function ItemPlanner.StatWeights:Create(data)
    local this = setmetatable({}, self)
    this.data = data
    return this
end

--- Prints StatWeights data.
function ItemPlanner.StatWeights:calculateScore(item)

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

