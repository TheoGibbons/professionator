---@class WorldMapButton
---@field Initialize function
local WorldMapButton = ItemPlannerLoader:CreateModule("WorldMapButton")

---@type ModalWindow
local ModalWindow = ItemPlannerLoader:ImportModule("ModalWindow")

local LibDBIcon = LibStub("LibDBIcon-1.0")
local LibDataBroker = LibStub("LibDataBroker-1.1")
local AceDB = LibStub("AceDB-3.0")

local bunnyLDB = LibDataBroker:NewDataObject("Bunnies!", {
    type = "data source",
    text = "Bunnies!",
    icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
    OnClick = function(_, button)
        if button == "LeftButton" then
            -- Handle left-click behavior
            --addon:ToggleModalWindow()
            --print("left click")
            ModalWindow:Toggle()
        elseif button == "RightButton" then
            -- Handle right-click behavior
            --addon:OpenOptions()
            --print("right click")
        end
    end,

    OnTooltipShow = function(tooltip)

        if not tooltip or not tooltip.AddLine then return end

        tooltip:AddLine("Item Planner")
        tooltip:AddLine(format("%s%s:|r %s", GRAY_FONT_COLOR_CODE, "Left Click", "Open"))
        tooltip:AddLine(format("%s%s:|r %s", GRAY_FONT_COLOR_CODE, "Right Click", "Options"))

    end,
})

function WorldMapButton:Initialize(addon)
    -- Obviously you'll need a ## SavedVariables: BunniesDB line in your TOC, duh!
    addon.db = AceDB:New("BunniesDB", { profile = { minimap = { hide = false, }, }, })
    LibDBIcon:Register("Bunnies!", bunnyLDB, addon.db.profile.minimap)
    addon:RegisterChatCommand("bunnies", "CommandTheBunnies")

    self.addon = addon
end

function WorldMapButton:CommandTheBunnies()
    self.addon.db.profile.minimap.hide = not self.addon.db.profile.minimap.hide
    if self.addon.db.profile.minimap.hide then
        LibDBIcon:Hide("Bunnies!")
    else
        LibDBIcon:Show("Bunnies!")
    end
end
