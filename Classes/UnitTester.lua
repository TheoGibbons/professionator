--- @class UnitTester
ItemPlanner.UnitTester = {}
ItemPlanner.UnitTester.__index = ItemPlanner.UnitTester

--- Creates a new UnitTester instance.
--- @param data table UnitTester data
--- @return UnitTester
function ItemPlanner.UnitTester:Create(data)
    local this = setmetatable({}, self)
    this.data = data
    return this
end

function ItemPlanner.UnitTester:RunTests()

    self:TestFilter()

end

-- Helper function to get a list of items matching a filter
function ItemPlanner.UnitTester:getAllItemsAsClasses(
        faction, -- "Alliance", "Horde" (Modules/ModalWindow/ModalWindowFilter/ModalWindowFilter.lua:14)
        race, -- "Night Elf", "Gnome", "Tauren", etc (Modules/ModalWindow/ModalWindowFilter/ModalWindowFilter.lua:14)
        class, -- "Priest", "Warrior", "Paladin", etc(Database/Generated/classicClassMap.lua:6)
        level, --
        slotName      -- "Shoulder", "Off Hand", "One-Hand", etc (Modules/ModalWindow/ModalWindowItemPlanel/ModalWindowItemPlanel.lua:135)
)

    faction = ItemPlanner.Utils.getFactionIdByName(faction)
    race = ItemPlanner.Utils.getRaceIdByName(race)
    class = ItemPlanner.Utils.getClassIdByName(class)

    local filter = ItemPlanner.Filter:Create()
    filter:setFaction(faction)
    filter:setRace(race)
    filter:setClass(class)
    filter:setLevel(level)

    local listOfItems = filter:getOrderedListOfItems()

    -- Get all the items that fit in this slot
    local slotId = ItemPlanner.Utils.getSlotIdByName(slotName)

    return listOfItems[slotId] or {}

end

function ItemPlanner.UnitTester:TestFilter()

    local listOfItems

    if false then

        -- Test faction specific
        listOfItems = self:getAllItemsAsClasses("Horde", "Tauren", "Warrior", 19, "Two-Hand")
        self:assertListContainsItem(true, listOfItems, "4964", "Goblin Smasher")
        listOfItems = self:getAllItemsAsClasses("Horde", "Troll", "Warrior", 19, "Two-Hand")
        self:assertListContainsItem(false, listOfItems, "4964", "Goblin Smasher")   -- "Goblin Smasher"

        return true
    end

    -- Test level
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 10, "Shoulder")
    self:assertListContainsItem(true, listOfItems, "10657", "Talbar Mantle")
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 9, "Shoulder")
    self:assertListContainsItem(false, listOfItems, "10657", "Talbar Mantle")   -- "Talbar Mantle" requires level 10

    -- Test faction specific
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 19, "Neck")
    self:assertListContainsItem(true, listOfItems, "20444", "Sentinel's Medallion")
    listOfItems = self:getAllItemsAsClasses("Horde", "Undead", "Priest", 19, "Neck")
    self:assertListContainsItem(false, listOfItems, "20444", "Sentinel's Medallion")   -- "Sentinel's Medallion" is Alliance only (Scout's Medallion is the Horde equivalent)

    -- Test faction specific
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 19, "Neck")
    self:assertListContainsItem(false, listOfItems, "20442", "Scout's Medallion")
    listOfItems = self:getAllItemsAsClasses("Horde", "Undead", "Priest", 19, "Neck")
    self:assertListContainsItem(true, listOfItems, "20442", "Scout's Medallion")   -- "Sentinel's Medallion" is Alliance only (Scout's Medallion is the Horde equivalent)

    -- Test race specific
    -- https://www.wowhead.com/classic/item=4964/goblin-smasher#comments is the only race specific item
    -- https://www.wowhead.com/classic/items/slot:24:16:18:5:8:11:10:1:23:7:21:2:22:13:15:26:28:14:4:3:19:25:12:17:6:9?filter=153;12;0
    listOfItems = self:getAllItemsAsClasses("Horde", "Tauren", "Warrior", 19, "Two-Hand")
    self:assertListContainsItem(true, listOfItems, "4964", "Goblin Smasher")
    listOfItems = self:getAllItemsAsClasses("Horde", "Troll", "Warrior", 19, "Two-Hand")
    self:assertListContainsItem(false, listOfItems, "4964", "Goblin Smasher")   -- "Goblin Smasher"

    -- Test class specific
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 19, "Chest")
    self:assertListContainsItem(true, listOfItems, "16604", "Moon Robes of Elune")
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Warrior", 19, "Chest")
    self:assertListContainsItem(false, listOfItems, "16604", "Moon Robes of Elune")   -- "Twilight Cultist Mantle" is Priest only

    -- Unattainable item test
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Warrior", 60, "Finger")
    self:assertListContainsItem(false, listOfItems, "20144", "90 Epic Warrior Ring")

    -- Unattainable item test
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Hunter", 60, "Two-Hand")
    self:assertListContainsItem(false, listOfItems, "56265", "Monster - Staff, Crooked Green")

    -- Head
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 30, "Head")
    self:assertListContainsItem(true, listOfItems, "4039", "Nightsky Cowl")
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 29, "Head")
    self:assertListContainsItem(false, listOfItems, "4039", "Nightsky Cowl")

    -- Back
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 19, "Back")
    self:assertListContainsItem(true, listOfItems, "20428", "Caretaker's Cape")
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 17, "Back")
    self:assertListContainsItem(false, listOfItems, "20428", "Caretaker's Cape")

    -- Wrist
    listOfItems = self:getAllItemsAsClasses("Alliance", "Human", "Priest", 19, "Wrist")
    self:assertListContainsItem(true, listOfItems, "1974", "Mindthrust Bracers")
    listOfItems = self:getAllItemsAsClasses("Alliance", "Human", "Priest", 16, "Wrist")
    self:assertListContainsItem(false, listOfItems, "1974", "Mindthrust Bracers")

    -- Hands
    listOfItems = self:getAllItemsAsClasses("Alliance", "Human", "Priest", 19, "Hands")
    self:assertListContainsItem(true, listOfItems, "12977", "Magefist Gloves")

    -- Waist
    listOfItems = self:getAllItemsAsClasses("Alliance", "Human", "Priest", 19, "Waist")
    self:assertListContainsItem(true, listOfItems, "2911", "Keller's Girdle")

    -- Legs
    listOfItems = self:getAllItemsAsClasses("Alliance", "Human", "Priest", 19, "Legs")
    self:assertListContainsItem(true, listOfItems, "12987", "Darkweave Breeches")

    -- Feet
    listOfItems = self:getAllItemsAsClasses("Alliance", "Human", "Priest", 19, "Feet")
    self:assertListContainsItem(true, listOfItems, "12977", "Magefist Gloves")

    -- Finger
    listOfItems = self:getAllItemsAsClasses("Alliance", "Human", "Priest", 19, "Finger")
    self:assertListContainsItem(true, listOfItems, "2933", "Seal of Wrynn")

    -- Trinket
    listOfItems = self:getAllItemsAsClasses("Alliance", "Human", "Priest", 19, "Trinket")
    self:assertListContainsItem(true, listOfItems, "19024", "Arena Grand Master")
    listOfItems = self:getAllItemsAsClasses("Alliance", "Human", "Priest", 19, "Trinket")
    self:assertListContainsItem(true, listOfItems, "18854", "Insignia of the Alliance")
    listOfItems = self:getAllItemsAsClasses("Alliance", "Human", "Priest", 19, "Trinket")
    self:assertListContainsItem(false, listOfItems, "18834", "Insignia of the Horde")

    -- Two-Hand Staves
    listOfItems = self:getAllItemsAsClasses("Alliance", "Gnome", "Mage", 19, "Two-Hand")
    self:assertListContainsItem(true, listOfItems, "2271", "Staff of the Blessed Seer")

    -- Two-Hand "Two-Handed Axes"
    listOfItems = self:getAllItemsAsClasses("Horde", "Undead", "Warrior", 30, "Two-Hand")
    self:assertListContainsItem(true, listOfItems, "6975", "Whirlwind Axe")

    -- Two-Hand "Two-Handed Maces"
    listOfItems = self:getAllItemsAsClasses("Horde", "Troll", "Shaman", 40, "Two-Hand")
    self:assertListContainsItem(true, listOfItems, "9423", "The Jackhammer")

    -- Two-Hand "Two-Handed Swords"
    listOfItems = self:getAllItemsAsClasses("Horde", "Orc", "Hunter", 50, "Two-Hand")
    self:assertListContainsItem(true, listOfItems, "9372", "Sul'thraze the Lasher")

    -- Two-Hand "Polearms"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Dwarf", "Paladin", 20, "Two-Hand")
    self:assertListContainsItem(true, listOfItems, "1522", "Headhunting Spear")

    -- Two-Hand "Fishing Poles"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Warlock", 19, "Two-Hand")
    self:assertListContainsItem(true, listOfItems, "6365", "Strong Fishing Pole")

    -- Ranged Bows
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 19, "Ranged")
    self:assertListContainsItem(true, listOfItems, "3021", "Ranger Bow")

    -- Ranged Crossbows
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Hunter", 5, "Ranged")
    self:assertListContainsItem(true, listOfItems, "15807", "Light Crossbow")

    -- Ranged Guns
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Hunter", 40, "Ranged")
    self:assertListContainsItem(true, listOfItems, "10508", "Mithril Blunderbuss")

    -- Ranged Thrown
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 60, "Ranged")
    self:assertListContainsItem(true, listOfItems, "21135", "Assassin's Throwing Axe")

    -- Ranged Wands
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 10, "Ranged")
    self:assertListContainsItem(true, listOfItems, "11287", "Lesser Magic Wand")

    -- "Main Hand" "One-Handed Axes"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 60, "Main Hand")
    self:assertListContainsItem(true, listOfItems, "871", "Flurry Axe")

    -- "Main Hand" "One-Handed Swords"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 50, "Main Hand")
    self:assertListContainsItem(true, listOfItems, "17705", "Thrash Blade")

    -- "Main Hand" "One-Handed Maces"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 19, "Main Hand")
    self:assertListContainsItem(true, listOfItems, "220581", "Snake Clobberer")

    -- "Main Hand" "Daggers"
    listOfItems = self:getAllItemsAsClasses("Horde", "Orc", "Shaman", 19, "Main Hand")
    self:assertListContainsItem(true, listOfItems, "2567", "Evocator's Blade")

    -- "Main Hand" "Fist Weapons"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 60, "Main Hand")
    self:assertListContainsItem(true, listOfItems, "19896", "Thekal's Grasp")

    -- "Main Hand" "Miscellaneous (Weapons)"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 19, "Main Hand")
    self:assertListContainsItem(true, listOfItems, "7005", "Skinning Knife")

    -- "Off Hand" "One-Handed Axes"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 42, "Off Hand")
    self:assertListContainsItem(true, listOfItems, "871", "Flurry Axe")

    -- "Off Hand" "One-Handed Swords"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 55, "Off Hand")
    self:assertListContainsItem(true, listOfItems, "2244", "Krol Blade")

    -- "Off Hand" "One-Handed Maces"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 60, "Off Hand")
    self:assertListContainsItem(true, listOfItems, "21268", "Blessed Qiraji War Hammer")

    -- "Off Hand" "Daggers"
    listOfItems = self:getAllItemsAsClasses("Horde", "Troll", "Rogue", 19, "Off Hand")
    self:assertListContainsItem(true, listOfItems, "4974", "Compact Fighting Knife")

    -- "Off Hand" "Fist Weapons"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 19, "Off Hand")
    self:assertListContainsItem(true, listOfItems, "2942", "Iron Knuckles")

    -- "Off Hand" "Shield"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Human", "Paladin", 50, "Off Hand")
    self:assertListContainsItem(true, listOfItems, "1203", "Aegis of Stormwind")

    -- "Off Hand" "Held In Off-hand"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 19, "Off Hand")
    self:assertListContainsItem(true, listOfItems, "7344", "Torch of Holy Flame")

    -- "Off Hand" "Miscellaneous (Weapons)"
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 19, "Off Hand")
    self:assertListContainsItem(true, listOfItems, "7005", "Skinning Knife")

    -- Main hand only wep
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 40, "Off Hand")
    self:assertListContainsItem(false, listOfItems, "13026", "Heaven's Light")
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 40, "Main Hand")
    self:assertListContainsItem(true, listOfItems, "13026", "Heaven's Light")

    -- Off hand only wep
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 50, "Off Hand")
    self:assertListContainsItem(true, listOfItems, "220589", "Serpent's Striker")
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 50, "Main Hand")
    self:assertListContainsItem(false, listOfItems, "220589", "Serpent's Striker")

    -- Eng head
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Rogue", 50, "Head")
    self:assertListContainsItem(true, listOfItems, "16008", "Master Engineer's Goggles")
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 50, "Head")
    self:assertListContainsItem(true, listOfItems, "16008", "Master Engineer's Goggles")
    listOfItems = self:getAllItemsAsClasses("Alliance", "Night Elf", "Priest", 50, "Head")
    self:assertListContainsItem(true, listOfItems, "20569", "Flimsy Female Orc Mask")

end

function ItemPlanner.UnitTester:assertListContainsItem(shouldContain, listOfItems, itemId, itemName)

    local found
    for _, item in pairs(listOfItems) do
        --ItemPlanner.Utils.print("Test:" .. item:getId() .. ' - ' .. item:getName(), "000000ff")
        if (item:getId() .. '' == itemId .. '') then
            found = item
            break
        end
    end

    if shouldContain then

        if found then

            if found:getName() == itemName then
                ItemPlanner.Utils.print("Success: Item " .. itemId .. " (" .. itemName .. ") found in list.", "0028a745")
            else
                ItemPlanner.Utils.print("Failed: Item " .. itemId .. " found in list. However the name is incorrect. Expected: " .. itemName .. " Actual: " .. found:getName(), "00ffc107")
            end

        else
            ItemPlanner.Utils.print("Failed: Item " .. itemId .. " (" .. itemName .. ") not found in list", "00dc3545")
        end

    else

        if found then
            if found:getName() == itemName then
                ItemPlanner.Utils.print("Failed: Item " .. itemId .. " (" .. itemName .. ") found in list when it shouldn't be.", "00dc3545")
            else
                ItemPlanner.Utils.print("Failed: Item " .. itemId .. " found in list when it shouldn't be. Also, the name is incorrect. Expected: " .. itemName .. " Actual: " .. found:getName(), "00ffc107")
            end
        else
            ItemPlanner.Utils.print("Success: Item " .. itemId .. " (" .. itemName .. ") not found in list.", "0028a745")
        end

    end

end