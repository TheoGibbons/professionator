local ProfessionatorDB = ProfessionatorLoader:ImportModule("ProfessionatorDB")

-- Wrath Death Knight - Cloth, Leather, Mail, Plate
-- Druid - Cloth, Leather
-- Hunter - Cloth, Leather, Mail (at level 40)
-- Mage - Cloth
-- Paladin - Cloth, Leather, Mail, Plate (at level 40), Shield
-- Priest - Cloth
-- Rogue - Cloth, Leather
-- Shaman - Cloth, Leather, Mail (at level 40), Shield
-- Warlock - Cloth
-- Warrior - Cloth, Leather, Mail, Plate (at level 40), Shield

local USUAL_ARMOR_PROFICIENCIES = {
    ["Cloth Armor"] = {
        Druid = 1,
        Hunter = 1,
        Mage = 1,
        Paladin = 1,
        Priest = 1,
        Rogue = 1,
        Shaman = 1,
        Warlock = 1,
        Warrior = 1,
        DeathKnight = 1,
    },
    ["Leather Armor"] = {
        Druid = 1,
        Hunter = 1,
        Paladin = 1,
        Rogue = 1,
        Shaman = 1,
        Warrior = 1,
        DeathKnight = 1,
    },
    ["Mail Armor"] = {
        Hunter = 40,
        Paladin = 1,
        Shaman = 40,
        Warrior = 1,
        DeathKnight = 1,
    },
    ["Plate Armor"] = {
        Paladin = 40,
        Warrior = 40,
        DeathKnight = 1,
    },
    ["Consumables"] = true, -- This seems to be items that don't actually exist in the game. Also Bloodsail Sash is in this category for some reason.
    ["Miscellaneous (Armor)"] = true, -- Items like "Flimsy Male Tauren Mask" from the halloween event
    [""] = true, -- Quest items like "Gahz'ridian Detector"
}

ProfessionatorDB.armorProficiencies = {
    Head = USUAL_ARMOR_PROFICIENCIES,
    Shoulder = USUAL_ARMOR_PROFICIENCIES,
    Chest = USUAL_ARMOR_PROFICIENCIES,
    Wrist = USUAL_ARMOR_PROFICIENCIES,
    Hands = USUAL_ARMOR_PROFICIENCIES,
    Waist = USUAL_ARMOR_PROFICIENCIES,
    Legs = USUAL_ARMOR_PROFICIENCIES,
    Feet = USUAL_ARMOR_PROFICIENCIES,
    Back = true,
    Finger = true,
    Trinket = true,
    Neck = true,
    Shirt = true,
    Tabard = true,

    Ammo = {
        Arrows = {
            Hunter = 1,
            Warrior = 1,
            Rogue = 1,
        },
        Bullets = {
            Hunter = 1,
            Warrior = 1,
            Rogue = 1,
        }
    },

    --Ranged: Bows, Crossbows, Guns, Thrown Wands
    Ranged = {
        Bows = {
            Hunter = 1,
            Warrior = 1,
            Rogue = 1,
        },
        Crossbows = {
            Hunter = 1,
            Warrior = 1,
            Rogue = 1,
        },
        Guns = {
            Hunter = 1,
            Warrior = 1,
            Rogue = 1,
        },
        Thrown = {
            Hunter = 1,
            Warrior = 1,
            Rogue = 1,
        },
        Wands = {
            Mage = 1,
            Priest = 1,
            Warlock = 1,
        },
        [""] = false, -- There is only one quest item in this category, "Egan's Blaster"
        ["Leather Armor"] = false, -- There is only one unattainable item in this category, "Test Ranged Slot"
        ["Fist Weapons"] = false, -- There is only one unattainable item in this category, "Fast Test Fist"
    },

    -- One Hand: Axes (1H/2H), Swords (1H/2H), Maces (1H/2H), Polearms (2H), Staves (2H), Daggers (1H), Fist weapons (1H)
    ["Main Hand"] = {

        -- Death Knights, Hunters, Paladins, Shamans, and Warriors. Rogues can wield only one-handed axes.
        ["One-Handed Axes"] = {
            DeathKnight = 1,
            Hunter = 1,
            Paladin = 1,
            Shaman = 1,
            Warrior = 1,
            Rogue = 1,
        },

        -- Both one-handed and two-handed swords can be wielded by Hunters, Paladins, and Warriors.
        -- Rogues, Mages, and Warlocks can wield only one-handed swords.
        ["One-Handed Swords"] = {
            Hunter = 1,
            Paladin = 1,
            Warrior = 1,
            Rogue = 1,
            Mage = 1,
            Warlock = 1,
        },

        -- Both one-handed and two-handed maces can be wielded by Death Knights, Paladins, Shamans, Druids, and Warriors.
        --Rogues and Priests can wield one-handed maces but not two-handed maces.
        ["One-Handed Maces"] = {
            DeathKnight = 1,
            Paladin = 1,
            Shaman = 1,
            Druid = 1,
            Warrior = 1,
            Rogue = 1,
            Priest = 1,
        },
        ["Daggers"] = {
            Rogue = 1,
            Warrior = 1,
            Mage = 1,
            Warlock = 1,
            Priest = 1,
        },

        -- Druids, Hunters, Rogues, Shamans, and Warriors.
        ["Fist Weapons"] = {
            Druid = 1,
            Hunter = 1,
            Rogue = 1,
            Shaman = 1,
            Warrior = 1,
        },
        [""] = false, -- Only unattainable items in this category
        ["Miscellaneous (Weapons)"] = true, -- Quest items in this category
        ["Two-Handed Maces"] = false, -- Only unattainable items in this category
        ["Polearms"] = false, -- Only unattainable items in this category
        ["Two-Handed Swords"] = false, -- Only unattainable items in this category
    },

    -- Off Hand: Axes (1H/2H), Swords (1H/2H), Maces (1H/2H), Polearms (2H), Staves (2H), Daggers (1H), Fist weapons (1H)     Shield - Only Paladins, Shamans, and Warriors can use.
    ["Off Hand"] = {
        ["One-Handed Axes"] = {
            DeathKnight = 1,
            Rogue = 10,
            Hunter = 20,
            Warrior = 20,
            Shaman = 6,     --  Shamans cannot duel wield in classic but they can in SODw with a level 6 quest
        },
        ["One-Handed Swords"] = {
            Hunter = 20,
            Warrior = 20,
            Rogue = 10,
        },
        ["One-Handed Maces"] = {
            DeathKnight = 1,
            Shaman = 6,
            Warrior = 20,
            Rogue = 10,
        },
        ["Daggers"] = {
            Rogue = 10,
            Warrior = 20,
            Shaman = 6,
            DeathKnight = 1,
        },
        ["Fist Weapons"] = {
            Hunter = 20,
            Rogue = 10,
            Shaman = 6,
            Warrior = 20,
        },
        ["Shield"] = {
            Paladin = 1,
            Shaman = 1,
            Warrior = 1,
        },
        ["Held In Off-hand"] = true,
        ["Consumables"] = false, -- Only unattainable items in this category
        ["Miscellaneous (Weapons)"] = true, -- Only unattainable items in this category I think
        ["Two-Handed Maces"] = false, -- Only unattainable items in this category
        ["Polearms"] = false, -- Only unattainable items in this category
        ["Two-Handed Swords"] = false, -- Only unattainable items in this category
    },

    -- two Hand: Axes (1H/2H), Swords (1H/2H), Maces (1H/2H), Polearms (2H), Staves (2H), Daggers (1H), Fist weapons (1H)
    ["Two-Hand"] = {
        ["Two-Handed Axes"] = {
            DeathKnight = 1,
            Hunter = 1,
            Paladin = 1,
            Shaman = 1,
            Warrior = 1,
        },
        ["Two-Handed Swords"] = {
            Hunter = 1,
            Paladin = 1,
            Warrior = 1,
        },
        ["Two-Handed Maces"] = {
            DeathKnight = 1,
            Paladin = 1,
            Shaman = 1,
            Druid = 1,
            Warrior = 1,
        },
        ["Polearms"] = {
            Warrior = 20,
            Paladin = 20,
            Shaman = 20,
            DeathKnight = 20,
        },
        ["Staves"] = {
            Druid = 1,
            Priest = 1,
            Shaman = 1,
            Warlock = 1,
            Mage = 1,
        },
        ["Fishing Poles"] = {
            Druid = 1,
            Hunter = 1,
            Mage = 1,
            Paladin = 1,
            Priest = 1,
            Rogue = 1,
            Shaman = 1,
            Warlock = 1,
            Warrior = 1,
            DeathKnight = 1,
        },
        [""] = false, -- Only unattainable items in this category
        ["One-Handed Axes"] = false, -- Only unattainable items in this category
        ["Miscellaneous (Armor)"] = false, -- Only unattainable items in this category
    },
    ["Bag"] = false,

}



