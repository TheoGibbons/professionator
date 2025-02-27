---@field Render function

local HelperWindow = ProfessionatorLoader:ImportModule("HelperWindow")

local AceGUI = LibStub("AceGUI-3.0")
function HelperWindow:Render()
    -- Initialization logic


    -- This is the main body element (scrollable container)
    local scrollcontainer = AceGUI:Create("InlineGroup") -- "InlineGroup" is also good
    scrollcontainer:SetFullWidth(true)
    --scrollcontainer:SetFullHeight(true) -- probably?
    scrollcontainer:SetLayout("Fill") -- important!

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") -- probably?
    scrollcontainer:AddChild(scroll)

    getItemsViewContainer(scroll)

    return scrollcontainer
end