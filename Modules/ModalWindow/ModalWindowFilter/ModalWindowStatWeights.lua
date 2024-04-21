---@class ModalWindowStatWeights
---@field Viewify function

local ModalWindowStatWeights = ItemPlannerLoader:CreateModule("ModalWindowStatWeights")
local ModalWindowFilter = ItemPlannerLoader:ImportModule("ModalWindowFilter")


local AceGUI = LibStub("AceGUI-3.0")

function ModalWindowStatWeights:Viewify()
    -- Initialization logic

    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    --container:SetFullWidth(true)
    --container:SetFullHeight(true)

    -- Button that is an image of cog
    -- That when clicked opens a modal window with stat weights
    local cogButton = AceGUI:Create("Icon")
    cogButton:SetImage("Interface\\Icons\\inv_misc_gear_01")
    cogButton:SetImageSize(20, 20)
    cogButton:SetLabel("Stat Weights")
    cogButton:SetCallback("OnClick", function()
        -- Handle cog button click
        -- Open modal window with stat weights
        ModalWindowStatWeights:OpenStatWeightsModal()
    end)

    return container
end

function ModalWindowStatWeights:statWeightsChanged()

    -- Create a new StatWeights instance
    --TODO These will be pulled form the modal windows elements
    local statWeights = ItemPlanner.StatWeights:Create({
        ["Spell power"] = 10,
        ["Shadow spell power"] = 10,
        ["Spell critical strike"] = 24,
        ["Spell hit"] = 100,
        ["Intellect"] = 0,
        ["Strength"] = 2,
        ["Stamina"] = 50,
    })

    --Trigger the statWeightsChanged event on ModalWindowFilter
    ModalWindowFilter:statWeightsChanged(statWeights)

end

function ModalWindowStatWeights:OpenStatWeightsModal()

    print ("TODO OpenStatWeightsModal")

    -- when anything changes in the modal call statWeightsChanged

end