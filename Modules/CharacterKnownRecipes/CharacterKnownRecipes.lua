-- CharacterKnownRecipes.lua

---@class CharacterKnownRecipes
---@field Initialize function
---@field Toggle function
---@field Show function
---@field Hide function

local CharacterKnownRecipes = ProfessionatorLoader:CreateModule("CharacterKnownRecipes")

-- This is an array of all recipes known by the player
-- It will look like {"Enchanting": {123, 456, ...}, "Blacksmithing": {789, 1011, ...}, ...}
local CachedRecipes = {}

function CharacterKnownRecipes:Register()

    -- Register the event
    -- When any trade window is opened, we want to show the helper window
    -- Which is a window off to the right of their trade window
    -- The actual content of the window will come from: CharacterKnownRecipes:Viewify(self)

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("TRADE_SKILL_SHOW");
    frame:RegisterEvent("NEW_RECIPE_LEARNED");

    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "TRADE_SKILL_SHOW" then
            print("Trade window opened!")

            RefreshRecipes();

        elseif event == "NEW_RECIPE_LEARNED" then
            print("Trade window updated!")
            -- Your code to handle the trade window being updated goes here
            -- For example, you can print the action that caused the update
            local skillName, skillType, numAvailable, isExpanded = ...
            print("Expansion is enabled. " .. json.encode(skillName))
            print("Expansion is enabled. " .. skillName)
        end
    end)

end

function RefreshRecipes()

    -- Get the trade name
    local tradeSkillName = getTradeName(), tradeSkillLevel, tradeSkillMaxLevel = GetTradeSkillLine();
    local tradeSkillName, tradeSkillLevel, tradeSkillMaxLevel = GetTradeSkillLine();
    print(" 2. tradeSkillName: " ..(tradeSkillName or 'nil') ..
        ', tradeSkillLevel: ' ..(tradeSkillLevel or 'nil') ..
        ', tradeSkillMaxLevel: ' ..(tradeSkillMaxLevel or 'nil')
    )		-- Returns "tradeSkillName: Tailoring, tradeSkillLevel: 175, tradeSkillMaxLevel: 225" If the tailoring window is open doesn't work with enchanting



end

function getTradeName()