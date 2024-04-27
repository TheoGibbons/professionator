-- HelperWindow.lua

---@class HelperWindow
---@field Initialize function
---@field Toggle function
---@field Show function
---@field Hide function

local HelperWindow = ProfessionatorLoader:CreateModule("HelperWindow")

local AceGUI = LibStub("AceGUI-3.0")


-- Create a local variable for the frame this should be immediately hidden because it isn't even setup yet
local frame

HelperWindow.windowWidth = 950

function HelperWindow:Register()

    -- Register the event
    -- When any trade window is opened, we want to show the helper window
    -- Which is a window off to the right of their trade window
    -- The actual content of the window will come from: HelperWindow:Viewify(self)

    frame = CreateFrame("Frame")
    frame:RegisterEvent("TRADE_SKILL_SHOW")
    frame:RegisterEvent("TRADE_SKILL_UPDATE")

    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "TRADE_SKILL_SHOW" then
            --print("Trade window opened!")
            -- Your code to handle the trade window being opened goes here
            -- For example, you can call a function to show your helper window
        elseif event == "TRADE_SKILL_UPDATE" then
            --print("Trade window updated!")
            ---- Your code to handle the trade window being updated goes here
            ---- For example, you can print the action that caused the update
            --local skillName, skillType, numAvailable, isExpanded = ...
            --print("Expansion is enabled. " .. json.encode(skillName))
            --print("Expansion is enabled. " .. skillName)
        end
    end)

end

function HelperWindow:Toggle()
    if (frame.frame:IsShown()) then
        self:Hide()
    else
        self:Show()
    end
end

function HelperWindow:Show()
    if (not frame.frame:IsShown()) then

        -- Build the window


        frame:Show()
    end
end

function HelperWindow:Hide()
    if (frame.frame:IsShown()) then
        frame:Hide()
    end
end

-- Register the module
--ProfessionatorLoader:RegisterModule("HelperWindow", HelperWindow)