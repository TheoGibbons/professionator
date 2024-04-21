-- ModalWindow.lua

---@class ModalWindow
---@field Initialize function
---@field Toggle function
---@field Show function
---@field Hide function

local ModalWindow = ItemPlannerLoader:CreateModule("ModalWindow")
local ModalWindowFilter = ItemPlannerLoader:ImportModule("ModalWindowFilter")
local ModalWindowItemPlanel = ItemPlannerLoader:ImportModule("ModalWindowItemPlanel")
local ModalWindowActions = ItemPlannerLoader:ImportModule("ModalWindowActions")

local AceGUI = LibStub("AceGUI-3.0")


-- Constants for dropdown options
local factions = { "Alliance", "Horde" }
local classes = { "Warrior", "Mage", "Rogue", "Priest", "Shaman", "Paladin", "Hunter", "Warlock", "Monk", "Druid", "Death Knight" }
local statWeights = { "Strength", "Agility", "Intellect", "Stamina", "Critical Strike", "Haste", "Mastery", "Versatility" }


-- Create a local variable for the frame this should be immediately hidden because it isn't even setup yet
local frame

ModalWindow.windowWidth = 950

function ModalWindow:Initialize()
    -- Initialization logic

    -- Create a local variable for the frame this should be immediately hidden because it isn't even setup yet
    frame = AceGUI:Create("Frame")

    frame:SetTitle("Item Planner")
    frame:SetWidth(ModalWindow.windowWidth)
    frame:SetHeight(600)
    frame:SetLayout("Flow")

    frame:SetTitle("Flare")
    frame:SetStatusText("Ready") -- This is the text to the left of the default close button
    --frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)

    -- This allows the escape button to close the window
    -- Add the frame as a global variable under the name `MyGlobalFrameName`
    _G["MyGlobalFrameName"] = frame.frame
    -- Register the global variable `MyGlobalFrameName` as a "special frame"
    -- so that it is closed when the escape key is pressed.
    tinsert(UISpecialFrames, "MyGlobalFrameName")


    -- Add the item filter to the top of the page
    local filterContainer = ModalWindowFilter:Viewify(self)
    frame:AddChild(filterContainer)


    -- Add the item panel to the page (This is the main element of the window)
    local itemPanelContainer = ModalWindowItemPlanel:Viewify(self)
    frame:AddChild(itemPanelContainer)


    -- Add the save buttons to the bottom of the modal
    local ModalWindowActions = ModalWindowActions:Viewify(self)
    frame:AddChild(ModalWindowActions)

end

function ModalWindow:Toggle()
    if (frame.frame:IsShown()) then
        self:Hide()
    else
        self:Show()
    end
end

function ModalWindow:Show()
    if (not frame.frame:IsShown()) then
        frame:Show()
    end
end

function ModalWindow:Hide()
    if (frame.frame:IsShown()) then
        frame:Hide()
    end
end

-- Register the module
--ItemPlannerLoader:RegisterModule("ModalWindow", ModalWindow)