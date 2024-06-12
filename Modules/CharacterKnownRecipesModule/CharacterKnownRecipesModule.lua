-- CharacterKnownRecipesModule.lua

-- The entire purpose of this module is to keep track of all the recipes that the player knows
-- This information will be kept track of by this `CachedRecipes` variable

---@class CharacterKnownRecipesModule
---@field Initialize function
---@field Toggle function
---@field Show function
---@field Hide function

local CharacterKnownRecipesModule = ProfessionatorLoader:CreateModule("CharacterKnownRecipesModule")

-- This is an array of all recipes known by the player
-- It will look like {"<character_name>-<server_name>": {"enchanting": {"currentSkillLevel":115, "maxSkillLevel" : 300, "recipes" : {123, 456, ...}, "blacksmithing": ...}}
local CachedRecipes = {}

local function getCharacterId()
    return Professionator.Utils.getCharacterId()
end

function CharacterKnownRecipesModule:Get(professionName)
    return CachedRecipes[getCharacterId()] and CachedRecipes[getCharacterId()][professionName] or {}
end

function CharacterKnownRecipesModule:GetKnownRecipes()
    return CachedRecipes[getCharacterId()] or {}
end

function CharacterKnownRecipesModule:SetKnownRecipes(recipes)
    CachedRecipes[getCharacterId()] = recipes
end

function CharacterKnownRecipesModule:KnowsRecipe(professionName, recipeSpellId)
    if self:Get(professionName).recipes == nil then
        return false
    end

    return tableContains(self:Get(professionName).recipes, recipeSpellId)
end

function CharacterKnownRecipesModule:Register()

    -- Register the event
    -- When any trade window is opened, we want to show the helper window
    -- Which is a window off to the right of their trade window
    -- The actual content of the window will come from: CharacterKnownRecipesModule:Viewify(self)

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("TRADE_SKILL_SHOW");
    frame:RegisterEvent("NEW_RECIPE_LEARNED");
    frame:RegisterEvent("CRAFT_SHOW");

    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "TRADE_SKILL_SHOW" then
            print("Trade window opened!")

            RefreshRecipes();

        elseif event == "CRAFT_SHOW" then
            -- TRADE_SKILL_SHOW doesn't work with enchanting. CRAFT_SHOW does.
            print("Craft window opened!")

            RefreshRecipes();

        elseif event == "TRADE_SKILL_FILTER_UPDATE" then
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

    -- NOTE: The craft skill window and non craft skill windows can be showing at the same time EG Tailoring and Enchanting
    -- There cannot be two trade skill windows open at the same time IE Tailoring and Blacksmithing cannot be open at the same time

    if CraftFrame and CraftFrame:IsVisible() then
        -- Crafting Skills (Enchanting and Beast Training Only)
        local craftSkillName, craftSkillLevel, craftSkillMaxLevel = GetCraftDisplaySkillLine();
        if craftSkillName and craftSkillName ~= "UNKNOWN" then

            addToCache(craftSkillName, craftSkillLevel, craftSkillMaxLevel, getRecipesFromCraftSkill(craftSkillName))

        end
    end

    if TradeSkillFrame and TradeSkillFrame:IsVisible() then
        -- Trade Skills (Non-Enchanting)
        local tradeSkillName, tradeSkillLevel, tradeSkillMaxLevel = GetTradeSkillLine();
        if tradeSkillName and tradeSkillName ~= "UNKNOWN" then

            addToCache(tradeSkillName, tradeSkillLevel, tradeSkillMaxLevel, getRecipesFromTradeSkill(tradeSkillName))

        end
    end

end

-- Trade Skills (Non-Enchanting)
function getRecipesFromTradeSkill(tradeSkillName)
    local recipes = {}
    local numSkills = GetNumTradeSkills()
    for i = 1, numSkills do

        -- NOTE: If a heading is collapsed, it will not be returned by GetTradeSkillInfo

        local skillName, skillType, numAvailable, isExpanded = GetTradeSkillInfo(i)

        --print(
        --    " 3. skillName: " ..(skillName or 'nil') ..
        --    ', skillType: ' ..(skillType or 'nil') ..
        --    ', numAvailable: ' ..(numAvailable or 'nil') ..
        --    ', isExpanded: ' ..(isExpanded or 'nil')
        --)		-- Returns " 3. skillName: Anti-Venom, skillType: trivial, numAvailable: 0, isExpanded: nil"

        if(skillType ~= "header") then

            local recipeSpellId = Professionator.Utils.GetSpellIdFromSpellName(tradeSkillName, skillName)
            if(recipeSpellId) then
                table.insert(recipes, recipeSpellId)
            else
                DEFAULT_CHAT_FRAME:AddMessage("ERROR: " .. skillName .. " was not found in the database", 1, 0, 0)
            end

        elseif(skillType == "header" and isExpanded == nil) then
            print("ERROR: " .. skillName .. " is collapsed. Expand it then close and reopen your trade window")
        end

    end
    return recipes
end

function tableContains(table, value)
    for _, v in pairs(table) do
        if (v .. '') == (value .. '') then
            return true
        end
    end
    return false
end

function addToCache(skillName, skillLevel, skillMaxLevel, recipes)

    skillName = skillName:lower()

    local characterId = getCharacterId()

    -- Initialise the character's cache if it doesn't exist
    if not CachedRecipes[characterId] then
        CachedRecipes[characterId] = {}
    end

    -- get a copy of the characters cache for easy reference
    local cachedCharacterProfessions= CachedRecipes[characterId][skillName] or {}

    -- get old values
    local oldSkillCurrentLevel = cachedCharacterProfessions.currentSkillLevel or 0
    local oldSkillMaxLevel = cachedCharacterProfessions.maxSkillLevel or 0
    local oldRecipes = cachedCharacterProfessions.recipes or {}

    -- If the skill level has increased, then print a message to the user
    if oldSkillCurrentLevel < skillLevel and oldSkillCurrentLevel ~= 0 then
        print("You have increased your " .. skillName .. " skill " .. oldSkillCurrentLevel .. " -> " .. skillLevel)
    end

    -- If the max skill level has increased, then print a message to the user
    if oldSkillMaxLevel < skillMaxLevel and oldSkillMaxLevel ~= 0 then
        --print("You have increased your " .. skillName .. " max skill level " .. oldSkillMaxLevel .. " -> " .. skillMaxLevel)
    end

    -- Get all learnt recipes  (learnt just now)
    -- NOTE: Recipes cannot be unlearned
    local recipesLearnt = {}
    for _, newRecipe in pairs(recipes) do
        if not tableContains(oldRecipes, newRecipe) then
            table.insert(recipesLearnt, newRecipe)
        end
    end

    -- print a message to the user if they have learnt new recipes
    if #recipesLearnt > 0 then
        if #recipesLearnt > 3 then
            print("You have learned " .. #recipesLearnt .. " new recipes")
        else
            for _, newRecipe in pairs(recipesLearnt) do
                print("You have learned a new recipe: " .. newRecipe)
            end
        end
    end

    local cacheShouldBeUpdated = #recipesLearnt > 0 or oldSkillCurrentLevel < skillLevel or oldSkillMaxLevel < skillMaxLevel

    if cacheShouldBeUpdated then
        -- Now let's add the new recipes into the oldRecipes
        for _, newRecipe in pairs(recipesLearnt) do
            table.insert(oldRecipes, newRecipe)
        end

        CachedRecipes[characterId][skillName] = {
            currentSkillLevel = skillLevel,
            maxSkillLevel = skillMaxLevel,
            recipes = recipes
        }
    end
end

-- Crafting Skills (Enchanting and Beast Training Only)
function getRecipesFromCraftSkill(craftSkillName)
    local recipes = {}
    local numSkills = GetNumCrafts()
    for i = 1, numSkills do

        -- NOTE: If a heading is collapsed, it will not be returned by GetTradeSkillInfo

        local craftName, craftSubSpellName, craftType, numAvailable, isExpanded, trainingPointCost, requiredLevel = GetCraftInfo(i)

        --print(
        --    " 4. craftName: " ..(craftName or 'nil') ..
        --    ', craftSubSpellName: ' ..(craftSubSpellName or 'nil') ..
        --    ', craftType: ' ..(craftType or 'nil') ..
        --    ', numAvailable: ' ..(numAvailable or 'nil') ..
        --    ', isExpanded: ' ..(isExpanded or 'nil') ..
        --    ', trainingPointCost: ' ..(trainingPointCost or 'nil') ..
        --    ', requiredLevel: ' ..(requiredLevel or 'nil')
        --)		-- Returns " 3. craftName: Anti-Venom, craftSubSpellName: nil, craftType: trivial, numAvailable: 0, isExpanded: nil, trainingPointCost: nil, requiredLevel: nil"

        if(craftType ~= "header") then

            local recipeSpellId = Professionator.Utils.GetSpellIdFromSpellName(craftSkillName, craftName)
            if(recipeSpellId) then
                table.insert(recipes, recipeSpellId)
            else
                DEFAULT_CHAT_FRAME:AddMessage("ERROR: " .. craftName .. " was not found in the database", 1, 0, 0)
            end

        elseif(craftType == "header" and isExpanded == nil) then
            print("ERROR: " .. craftName .. " is collapsed. Expand it then close and reopen your trade window")
        end

    end
    return recipes
end