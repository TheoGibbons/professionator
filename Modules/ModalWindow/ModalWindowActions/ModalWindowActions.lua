---@class ModalWindowActions
---@field Viewify function

local ModalWindowActions = ItemPlannerLoader:CreateModule("ModalWindowActions")

local AceGUI = LibStub("AceGUI-3.0")

function ModalWindowActions:Viewify()

    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetFullWidth(true)


    -- Save Button
    local saveButton = AceGUI:Create("Button")
    saveButton:SetText("Save")
    saveButton:SetCallback("OnClick", function()
        --self:SaveData()  -- Implement your save logic here

        -- TODO While testing reload
        ReloadUI()
    end)
    container:AddChild(saveButton)


    -- Close Button
    local closeButton = AceGUI:Create("Button")
    closeButton:SetText("Close")
    closeButton:SetCallback("OnClick", function()
        frame:Hide()
    end)
    container:AddChild(closeButton)

    return container
end