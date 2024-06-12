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

function printChancePerCastToLevel(recipeGroup)

    local min = Professionator.Utils.prettyPercentage(recipeGroup:getMinChancePerCastToLevel())
    local max = Professionator.Utils.prettyPercentage(recipeGroup:getMaxChancePerCastToLevel())

    if min == max then
        return min
    else
        return max .. " at level " .. recipeGroup:getMinLevel() .. " | " .. min .. " at level " .. recipeGroup:getMaxLevel()
    end

end

function RecipeListPrintRow(recipeGroup, frame, yOffset)

    local recipeText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    recipeText:SetPoint("TOPLEFT", 10, yOffset)

    -- Calculate printLevel
    -- Level should be shown as a range eg "20-30" or if there is just one level then eg "40"
    local printLevel = rangePrint(
            recipeGroup:getMinLevel(),
            recipeGroup:getMaxLevel()
    )

    local recipe = recipeGroup:getRecipe()
    local recipeName = recipe:getName()
    local recipeId = recipe:getId()

    recipeText:SetText(printLevel ..
            " " .. cleanUpName(recipeName) ..
            " x " .. Professionator.Utils.round(recipeGroup:getAverageCastsToLevel(), 0)
    )

    MyGameTooltip:SetupTooltip({
        targetElement = recipeText,
        beforeShow = function(tooltip)
            tooltip:ClearLines()
            tooltip:AddSpellByID(recipeId)
            tooltip:AddLine(" ", 1, 1, 1)
            tooltip:AddLine("-----------------------------", 1, 1, 1)
            tooltip:AddLine("Right click to use a different recipe", 1, 1, 1)
            tooltip:AddLine("-----------------------------", 1, 1, 1)
            tooltip:AddLine("Average Cost to Level " .. printLevel .. ": " .. Professionator.Utils.GetMoneyString(recipeGroup:getAverageCostToLevel()))
            tooltip:AddLine("Chance per cast to level: " .. printChancePerCastToLevel(recipeGroup))
            tooltip:AddLine("Time spent casting: " .. Professionator.Utils.PrettySeconds(recipeGroup:castTime()) .. '')

            --if #printRowData.alternatives > 0 then
            --    tooltip:AddLine("Alternatives: " .. Professionator.Utils.implode(', ', Professionator.Utils.arrayUnique(printRowData.alternatives)))
            --end

            tooltip:AddLine("Average number of casts to level: " .. Professionator.Utils.round(recipeGroup:getAverageCastsToLevel()))

            local sourceString = recipe:getSourceString(PlayersInventoryModule:GetInventory())
            if sourceString ~= nil then
                tooltip:AddLine("\n" .. sourceString)
            end

        end,
    })

end

-- Function to generate a frame element containing a list of fake recipe names
function GenerateRecipeList(professionName)

    local generateListStartTime = debugprofilestop()

    local frame = CreateFrame("Frame", nil)
    frame:SetSize(1, 1)     -- I don't know why 1x1 works but it does

    local yOffset = -10 -- Initial y offset for positioning recipe names

    local calculationEngine = Professionator.CalculationEngine:Create(professionName, 1, 300)

    local calculationResult = calculationEngine:Calculate()

    local calculationRecipeGroup = calculationResult:GetRecipeGroups()

    for i, recipeGroup in ipairs(calculationRecipeGroup) do
        RecipeListPrintRow(recipeGroup, frame, yOffset)
        yOffset = yOffset - 20
    end

    print("GenerateList: " .. Professionator.Utils.PrettySeconds((debugprofilestop() - generateListStartTime) / 1000) )

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
        width = 350,
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