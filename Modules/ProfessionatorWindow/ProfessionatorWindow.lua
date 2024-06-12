-- ProfessionatorWindow.lua

---@class ProfessionatorWindow
---@field Initialize function
---@field Toggle function
---@field Show function
---@field Hide function

local ProfessionatorWindow = ProfessionatorLoader:CreateModule("ProfessionatorWindow")
local CreateWindow = ProfessionatorLoader:ImportModule("CreateWindow")
local CalculationEngine = ProfessionatorLoader:ImportModule("CalculationEngine")
local MyGameTooltip = ProfessionatorLoader:ImportModule("MyGameTooltip")

-- Create a local variable for the frame this should be immediately hidden because it isn't even setup yet
local modalWindow

ProfessionatorWindow.windowWidth = 950

function ProfessionatorWindow:Register()

    -- Register the event
    -- When any trade window is opened, we want to show the helper window
    -- Which is a window off to the right of their trade window
    -- The actual content of the window will come from: ProfessionatorWindow:Viewify(self)

    local frame = CreateFrame("Frame")
    local parentSelf = self
    frame:RegisterEvent("TRADE_SKILL_SHOW")
    frame:RegisterEvent("TRADE_SKILL_CLOSE")
    frame:RegisterEvent("CRAFT_SHOW");
    frame:RegisterEvent("CRAFT_CLOSE");

    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "TRADE_SKILL_SHOW" then
            print("Trade window opened!")

            local professionName = GetTradeSkillLine()

            ActuallyShow(professionName)

        elseif event == "TRADE_SKILL_CLOSE" then
            print("Trade window closed!")

            parentSelf:Hide()

        elseif event == "CRAFT_SHOW" then
            print("Craft window opened!")

            local professionName = GetCraftDisplaySkillLine()

            ActuallyShow(professionName)

        elseif event == "CRAFT_CLOSE" then
            print("Craft window closed!")

            parentSelf:Hide()

        end
    end)

end

function cleanUpName(recipeName)
    -- if the recipeName starts with "Enchanting " remove that because it's unnecessary
    if type(recipeName) == "string" and string.sub(recipeName, 1, 8) == "Enchant " then
        return string.sub(recipeName, 9)
    end
    return recipeName
end

-- Level should be shown as a range eg "20-30" or if there is just one level then eg "40"
function rangePrint(start, finish)
    if start ~= finish then
        return "(" .. start .. "-" .. finish .. ")"
    else
        return start
    end
end

function RecipeListPrintRow(frame, printRowData, yOffset)

    local recipeText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    recipeText:SetPoint("TOPLEFT", 10, yOffset)

    -- Calculate printLevel
    -- Level should be shown as a range eg "20-30" or if there is just one level then eg "40"
    local printLevel = rangePrint(
            Professionator.Utils.tableMin(printRowData.levels),
            Professionator.Utils.tableMax(printRowData.levels)
    )

    recipeText:SetText(printLevel ..
            " " .. cleanUpName(printRowData.recipe.name) ..
            " x " .. Professionator.Utils.round(printRowData.averageCastsToLevel)
    )

    MyGameTooltip:SetupTooltip({
        targetElement = recipeText,
        beforeShow = function(tooltip)
            tooltip:ClearLines()
            tooltip:AddSpellByID(printRowData.recipe.id)
            tooltip:AddLine(" ", 1, 1, 1)
            tooltip:AddLine("-----------------------------", 1, 1, 1)
            tooltip:AddLine("Right click to use a different recipe", 1, 1, 1)
            tooltip:AddLine("-----------------------------", 1, 1, 1)
            tooltip:AddLine("Average Cost to Level " .. printLevel .. ": " .. Professionator.Utils.GetMoneyString(printRowData.averageCostToLevel))
            tooltip:AddLine("Chance to level: " .. rangePrint(
                    Professionator.Utils.prettyPercentage(Professionator.Utils.tableMax(printRowData.chancePerCastToLevel)),
                    Professionator.Utils.prettyPercentage(Professionator.Utils.tableMin(printRowData.chancePerCastToLevel))
            ))
            tooltip:AddLine("Time spent casting: " .. Professionator.Utils.round(printRowData.recipe.cast_time * printRowData.averageCastsToLevel, 1) .. 'sec')

            -- Print recipe location/cost
            if UnitFactionGroup("player") == "Horde" then
                if printRowData.recipe.recipe_source_horde_long ~= nil then
                    tooltip:AddLine("Recipe Source (" .. printRowData.recipe.learnedat .. "): " .. printRowData.recipe.recipe_source_horde_long)

                    if printRowData.recipe.recipe_item_id_bop == false and printRowData.recipe.recipe_item_id_horde ~= nil then
                        tooltip:AddLine("Recipe cost on AH: " .. Professionator.Utils.GetMoneyString(Professionator.Utils.cost(printRowData.recipe.recipe_item_id_horde)))
                    end
                end
            else
                if printRowData.recipe.recipe_source_alliance_long ~= nil then
                    tooltip:AddLine("Recipe Source (" .. printRowData.recipe.learnedat .. "): " .. printRowData.recipe.recipe_source_alliance_long)

                    if printRowData.recipe.recipe_item_id_bop == false and printRowData.recipe.recipe_item_id_alliance ~= nil then
                        tooltip:AddLine("Recipe cost on AH: " .. Professionator.Utils.GetMoneyString(Professionator.Utils.getItemCost(printRowData.recipe.recipe_item_id_alliance)))
                    end
                end
            end

            if #printRowData.alternatives > 0 then
                tooltip:AddLine("Alternatives: " .. Professionator.Utils.implode(', ', Professionator.Utils.arrayUnique(printRowData.alternatives)))
            end

            if printRowData.count > 7 or printRowData.count == 1 then
                tooltip:AddLine("Average number of casts to level: " .. Professionator.Utils.round(printRowData.averageCastsToLevel))
            else
                tooltip:AddLine("Average number of casts:")
                for level, averageCastsToLevel in Professionator.Utils.orderedPairs(printRowData.averageCastsToLevels) do
                    tooltip:AddLine("  " .. level .. ": " .. Professionator.Utils.round(averageCastsToLevel, 2))
                end
                tooltip:AddLine("  total: " .. Professionator.Utils.round(printRowData.averageCastsToLevel))
            end

        end,
    })

end

-- Function to generate a frame element containing a list of fake recipe names
function GenerateRecipeList(professionName)
    local frame = CreateFrame("Frame", nil)
    frame:SetSize(300, 200)

    local yOffset = -10 -- Initial y offset for positioning recipe names

    local calculationEngine = Professionator.CalculationEngine:Create(professionName, 1, 300)
    calculationEngine = calculationEngine:Calculate()

    -- for example from level 1-19 you might craft "Enchant Minor Stats"
    -- Then 20-30 you might craft "Enchant Lesser Stats"
    -- There is no need to print 30 rows for this let's combine them into 2 rows
    -- That is the point of these rowData and initialRowData variables
    local initialPrintRowData = {
        recipe = nil,
        count = 0,
        levels = {},
        averageCastsToLevel = 0,
        averageCastsToLevels = {},
        chancePerCastToLevel = {},
        averageCostToLevel = 0,
        alternatives = {},
    }
    local printRowData = Professionator.Utils.deepCopy(initialPrintRowData)

    for level, recipe in Professionator.Utils.orderedPairs(calculationEngine.result) do

        if recipe == nil then
            print("No recipe found for level " .. level .. " in " .. professionName)
        end

        -- Print this row?
        if printRowData.recipe ~= nil and printRowData.recipe.id ~= nil then
            if printRowData.recipe.id ~= recipe:getId() then
                RecipeListPrintRow(frame, printRowData, yOffset)
                yOffset = yOffset - 20 -- Adjusting y offset for the next recipe name
                printRowData = Professionator.Utils.deepCopy(initialPrintRowData)
            end
        end

        -- update printRowData
        printRowData.recipe = recipe
        printRowData.count = printRowData.count + 1
        table.insert(printRowData.levels, level)
        printRowData.averageCastsToLevel = printRowData.averageCastsToLevel + recipe:getAverageCastsToLevel()
        printRowData.averageCastsToLevels[level] = recipe:getAverageCastsToLevel()
        table.insert(printRowData.chancePerCastToLevel, recipe:getGetChancePerCastToLevel())
        printRowData.averageCostToLevel = printRowData.averageCastsToLevel * recipe:GetCostToCraft()
    end

    if printRowData.recipe ~= nil and printRowData.recipe:getId() ~= nil then
        RecipeListPrintRow(frame, printRowData, yOffset)
    end

    return frame
end

function ProfessionatorWindow:Toggle()
    if (modalWindow.frame:IsShown()) then
        self:Hide()
    else
        self:Show()
    end
end

function ActuallyShow(professionName)
    local referenceFrame = TradeSkillFrame -- You can change this to your desired reference frame
    if(professionName:lower() == "enchanting") then
        referenceFrame = CraftFrame
    end
    modalWindow = CreateWindow:Create("Test", {
        title = "Professionator - " .. professionName,
        width = 600,
        --height = 300,
        referenceFrame = referenceFrame,
        content = GenerateRecipeList(professionName:lower()),
    })
    modalWindow:Show()
end

function ProfessionatorWindow:Show()
    if (modalWindow and not modalWindow:IsShown()) then
        modalWindow:Show()
    end
end

function ProfessionatorWindow:Hide()
    if (modalWindow and modalWindow:IsShown()) then
        modalWindow:Hide()
    end
end

-- Register the module
--ProfessionatorLoader:RegisterModule("ProfessionatorWindow", ProfessionatorWindow)