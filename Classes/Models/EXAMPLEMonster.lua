Monster = {}
Monster.__index = Monster
function Monster:Create()
    local this =
    {
        name = "orc",
        health = 10,
        attack = 3
    }
    setmetatable(this, self)
    return this
end

function Monster:WarCry()
    print(self.name .. ": GRAAAHH!!!")
end

monster_1 = Monster:Create()
monster_1:WarCry() -- > "orc: GRAAAHH!!!"