-- ProfessionatorWindow.lua

---@class ProfessionatorWindow
---@field Initialize function
---@field Toggle function
---@field Show function
---@field Hide function

local ProfessionatorWindow = ProfessionatorLoader:CreateModule("ProfessionatorWindow")
local CreateWindow = ProfessionatorLoader:ImportModule("CreateWindow")
local CalculationEngine = ProfessionatorLoader:ImportModule("CalculationEngine")
local GameTooltip = ProfessionatorLoader:ImportModule("GameTooltip")

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
            " " .. cleanUpName(printRowData.name) ..
            " - ave:" .. printRowData.averageCostToLevel ..
            " - craft:" .. (printRowData.costToCraft or 'Unknown') ..
            " - chanc:" .. rangePrint(
                    Professionator.Utils.prettyPercentage(Professionator.Utils.tableMin(printRowData.chancePerCastToLevel)),
                    Professionator.Utils.prettyPercentage(Professionator.Utils.tableMax(printRowData.chancePerCastToLevel))
            ) ..
            " - casts:" .. printRowData.averageCastsToLevel
    )

    GameTooltip:SetupTooltip({
        targetElement = recipeText,
        parentFrame = frame,
        text = printRowData.name .. "\n" ..
                "Average Cost to Level " .. printLevel .. ": " .. printRowData.averageCostToLevel .. "\n" ..
                "Chance to level: " .. rangePrint(
                        Professionator.Utils.prettyPercentage(Professionator.Utils.tableMin(printRowData.chancePerCastToLevel)),
                        Professionator.Utils.prettyPercentage(Professionator.Utils.tableMax(printRowData.chancePerCastToLevel))
                ) .. "\n" ..
                "Average number of casts: " .. printRowData.averageCastsToLevel,
    })

end

-- Function to generate a frame element containing a list of fake recipe names
function GenerateRecipeList(professionName)
    local frame = CreateFrame("Frame", nil)
    frame:SetSize(300, 200)

    local yOffset = -10 -- Initial y offset for positioning recipe names

    local recipesByLevel = CalculationEngine:Calculate(professionName, 1, 300)

    -- for example from level 1-19 you might craft "Enchant Minor Stats"
    -- Then 20-30 you might craft "Enchant Lesser Stats"
    -- There is no need to print 30 rows for this let's combine them into 2 rows
    -- That is the point of these rowData and initialRowData variables
    local initialPrintRowData = {
        id = nil,
        name = nil,
        costToCraft = nil,
        count = 0,
        levels = {},
        averageCastsToLevel = 0,
        chancePerCastToLevel = {},
        averageCostToLevel = 0,
    }
    local printRowData = Professionator.Utils.deepCopy(initialPrintRowData)

    for level, recipesAtLevel in pairs(recipesByLevel) do

        local recipe = recipesAtLevel[1]

        if recipe == nil then
            print("No recipe found for level " .. level .. " in " .. professionName)
        end

        -- Print this row?
        if printRowData.id ~= nil then
            if printRowData.id ~= recipe.id then
                RecipeListPrintRow(frame, printRowData, yOffset)
                yOffset = yOffset - 20 -- Adjusting y offset for the next recipe name
                printRowData = Professionator.Utils.deepCopy(initialPrintRowData)
            end
        end

        -- update printRowData
        printRowData.id = recipe.id
        printRowData.name = recipe.name
        printRowData.costToCraft = recipe.costToCraft
        printRowData.count = printRowData.count + 1
        table.insert(printRowData.levels, level)
        printRowData.averageCastsToLevel = printRowData.averageCastsToLevel + recipe.averageCastsToLevel
        table.insert(printRowData.chancePerCastToLevel, recipe.chancePerCastToLevel)
        printRowData.averageCostToLevel = printRowData.averageCastsToLevel * recipe.costToCraft
    end

    if printRowData.id ~= nil then
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