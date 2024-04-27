-- The only public class except for Professionator
---@class ProfessionatorLoader
ProfessionatorLoader = {}


local modules = {}

ProfessionatorLoader._modules = modules -- store reference so modules can be iterated for profiling

---@generic T
---@param name `T` @Module name
---@return T|{ private: table } @Module reference
function ProfessionatorLoader:CreateModule(name)
    if (not modules[name]) then
        modules[name] = { private = {} }
        return modules[name]
    else
        return modules[name]
    end
end

---@generic T
---@param name `T` @Module name
---@return T|{ private: table } @Module reference
function ProfessionatorLoader:ImportModule(name)
    if (not modules[name]) then
        modules[name] = { private = {} }
        return modules[name]
    else
        return modules[name]
    end
end

function ProfessionatorLoader:PopulateGlobals() -- called when debugging is enabled
    for name, module in pairs(modules) do
        _G[name] = module
    end
end

