---@class ModalWindowFilter
---@field Viewify function

local ModalWindowFilter = ItemPlannerLoader:CreateModule("ModalWindowFilter")
local ModalWindowItemPlanel = ItemPlannerLoader:ImportModule("ModalWindowItemPlanel")
local ModalWindowStatWeights = ItemPlannerLoader:ImportModule("ModalWindowStatWeights")

---@type ItemPlannerDB
local ItemPlannerDB = ItemPlannerLoader:ImportModule("ItemPlannerDB")

local AceGUI = LibStub("AceGUI-3.0")

local filter = ItemPlanner.Filter:Create()

function ModalWindowFilter:Viewify()
    -- Initialization logic

    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetFullWidth(true)
    --container:SetFullHeight(true)

    -- Faction Dropdown
    local factionDropdown = AceGUI:Create("Dropdown")
    factionDropdown:SetList(ItemPlannerDB.factions)
    factionDropdown:SetLabel("Select Faction")
    factionDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        -- Handle faction selection
        filter:setFaction(value)
        self:filterChanged()
    end)
    container:AddChild(factionDropdown)

    -- Race Dropdown
    local raceDropdown = AceGUI:Create("Dropdown")
    raceDropdown:SetList(ItemPlannerDB.races)
    raceDropdown:SetLabel("Select Race")
    raceDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        -- Handle race selection
        filter:setRace(value)
        self:filterChanged()
    end)
    container:AddChild(raceDropdown)

    -- Class Dropdown
    local classDropdown = AceGUI:Create("Dropdown")
    classDropdown:SetList(self:getSimpleClassMap())
    classDropdown:SetLabel("Select Class")
    classDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        -- Handle class selection
        filter:setClass(value)
        self:filterChanged()
    end)
    container:AddChild(classDropdown)

    -- Level Slider
    local levelSlider = AceGUI:Create("Slider")
    levelSlider:SetSliderValues(1, 60, 1)
    levelSlider:SetLabel("Select Level")
    levelSlider:SetCallback("OnValueChanged", function(widget, event, value)
        -- Handle level selection
        filter:setLevel(value)
        self:filterChanged()
    end)
    container:AddChild(levelSlider)

    -- Stat Weight Dropdown
    local statWeight = ModalWindowStatWeights:Viewify()
    container:AddChild(statWeight)

    return container
end

function ModalWindowFilter:filterChanged()
    -- Handle filter change
    -- Update the item panel view

    local listOfItems = filter:getOrderedListOfItems()

    ModalWindowItemPlanel:updateListOfShowingItems(listOfItems, false)

    if ItemPlanner.settings.debugEnabled then
        ItemPlanner.Utils.printAllMissing()
    end

end

function ModalWindowFilter:statWeightsChanged(statWeights)

    -- Trigger the statWeightsChanged event on ModalWindowFilter
    filter:setStatWeights(statWeights)

    self:filterChanged()

end

function ModalWindowFilter:getSimpleClassMap()

    local ret = {}

    for k, v in pairs(ItemPlannerDB.classMap) do
        ret[k] = v
    end

    return ret

end