--- @class Professionator.Stopwatch

local times = {}

Professionator.Stopwatch = {

    add = function(key, time)
        if times[key] == nil then
            times[key] = 0
        end

        times[key] = times[key] + time
    end,

    get = function()
        return times
    end

}