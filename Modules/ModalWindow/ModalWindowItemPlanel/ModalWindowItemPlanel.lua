---@class ModalWindowItemPlanel
---@field Viewify function

local ModalWindowItemPlanel = ItemPlannerLoader:CreateModule("ModalWindowItemPlanel")
local ModalWindow = ItemPlannerLoader:ImportModule("ModalWindow")

local AceGUI = LibStub("AceGUI-3.0")

local ITEMS_TO_SHOW_PER_SLOT = 5
local ICON_SIZE = 13

ModalWindowItemPlanel.ItemsShowing = {}

local function generateHoverableItem(itemId, suffixId, suffixText)

    -- Create a ClickableLabel widget
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetWidth(200)  -- Adjust width as needed

    -- getItemLinks
    local links = ItemPlanner.ItemLinkHelper.getItemLinks(itemId, suffixId, suffixText)

    -- Create a dummy spacer to add padding
    local spacer = AceGUI:Create("Label")
    spacer:SetWidth(ICON_SIZE) -- Adjust width as needed
    container:AddChild(spacer)

    -- Create the icon texture
    local icon = CreateFrame("Frame", nil, container.frame)
    icon:SetWidth(ICON_SIZE) -- Adjust width as needed
    icon:SetHeight(ICON_SIZE) -- Adjust height as needed
    icon:SetPoint("LEFT", container.frame, "LEFT", 0, 0)

    local iconTexture = icon:CreateTexture(nil, "BACKGROUND")
    iconTexture:SetAllPoints(true)
    iconTexture:SetTexture(links.itemTexture)

    -- Create the label for the item link
    local clickableLabel = AceGUI:Create("InteractiveLabel")
    clickableLabel:SetText(links.hoverable)

    -- Set the font size
    clickableLabel:SetFontObject(GameFontNormal)

    -- Handle mouseover event to show the tooltip
    clickableLabel:SetCallback("OnEnter", function(widget, event)
        GameTooltip:SetOwner(widget.frame, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(links.hoverable)
        GameTooltip:Show()
    end)

    -- Handle mouseout event to hide the tooltip
    clickableLabel:SetCallback("OnLeave", function(widget, event)
        GameTooltip:Hide()
    end)

    -- Handle click event to insert item link into chat
    clickableLabel:SetCallback("OnClick", function(widget, event, button)
        if button == "LeftButton" and IsShiftKeyDown() then
            ChatEdit_InsertLink(links.linkable)
        end
    end)

    container:AddChild(clickableLabel)

    return container
end

local function getItemsForSlot(sectionName)

    -- Get all the items that fit in this slot
    local slotId = ItemPlanner.Utils.getSlotIdByName(sectionName)

    return ModalWindowItemPlanel.ItemsShowing[slotId] or {}

end

local function getSlotSection(sectionName)

    local container = AceGUI:Create("SimpleGroup")

    --sectionName is an array implode it
    local sectionNameText
    if (type(sectionName) ~= "table") then
        sectionNameText = sectionName
    else
        sectionNameText = table.concat(sectionName, "/")
    end

    -- Add Heading "Shoulder"
    local headHeading = AceGUI:Create("Heading")
    headHeading:SetText(sectionNameText)
    headHeading:SetFullWidth(true)
    --headHeading:SetRelativeWidth(1)
    container:AddChild(headHeading)

    local itemsForSlot = getItemsForSlot(sectionName)

    -- Iterate over the table using pairs
    for _, item in pairs(itemsForSlot) do
        --local clickableLabel = generateHoverableItem("10242", "614", " of the Monkey")
        local clickableLabel = generateHoverableItem(item:getId(), item:getSuffixId(), item:getSuffixText())
        clickableLabel:SetFullWidth(true)
        container:AddChild(clickableLabel)
    end

    return container
end

local function getItemsViewContainer()

    -- Table with 2 columns
    local tableContainer = AceGUI:Create("SimpleGroup")
    tableContainer:SetLayout("Flow")
    tableContainer:SetFullWidth(true)
    --tableContainer:SetHeight(0)
    --tableContainer:SetFullHeight(true)

    local windowPadding = 38
    local halfWidth = ModalWindow.windowWidth * 0.5 - windowPadding

    -- Left Column
    local leftColumn = AceGUI:Create("SimpleGroup")
    leftColumn:SetLayout("List")
    leftColumn:SetWidth(halfWidth)  -- Adjust the width based on your needs
    tableContainer:AddChild(leftColumn)

    -- Right Column
    local rightColumn = AceGUI:Create("SimpleGroup")
    rightColumn:SetLayout("List")
    rightColumn:SetWidth(halfWidth)  -- Adjust the width based on your needs
    tableContainer:AddChild(rightColumn)

    leftColumn:AddChild(getSlotSection("Head"))
    leftColumn:AddChild(getSlotSection("Neck"))
    leftColumn:AddChild(getSlotSection("Shoulder"))
    leftColumn:AddChild(getSlotSection("Back"))
    leftColumn:AddChild(getSlotSection("Chest"))
    leftColumn:AddChild(getSlotSection("Wrist"))
    leftColumn:AddChild(getSlotSection("Two-Hand"))
    leftColumn:AddChild(getSlotSection({ "Main Hand",  "One-Hand" }))
    leftColumn:AddChild(getSlotSection({ "Off Hand",  "One-Hand" }))

    rightColumn:AddChild(getSlotSection("Hands"))
    rightColumn:AddChild(getSlotSection("Waist"))
    rightColumn:AddChild(getSlotSection("Legs"))
    rightColumn:AddChild(getSlotSection("Feet"))
    rightColumn:AddChild(getSlotSection("Finger"))
    rightColumn:AddChild(getSlotSection("Trinket"))
    rightColumn:AddChild(getSlotSection("Ranged"))
    --rightColumn:AddChild(getSlotSection("Relic"))

    return tableContainer
end

local container

function ModalWindowItemPlanel:Viewify()

    -- Create the outer scroll frame
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow") -- Adjust layout as needed
    --scrollFrame:SetWidth(200) -- Adjust width as needed
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetHeight(300) -- Adjust height as needed

    -- Create the inner InlineGroup
    container = AceGUI:Create("InlineGroup")
    container:SetFullWidth(true) -- Adjust width to fill the parent
    container:SetLayout("List") -- Adjust layout as needed
    --container:SetHeight(0) -- Initially set height to 0, it will adjust automatically

    -- No longer add items on page load
    -- Add elements to the inner InlineGroup
    --local itemViewContainer = getItemsViewContainer()
    --container:AddChild(itemViewContainer)

    -- Add the inner InlineGroup to the scroll frame
    scrollFrame:AddChild(container)

    return scrollFrame

end

-- Opposite of the serialise() function
-- This takes a string of items and loads them into the view
function ModalWindowItemPlanel:RefreshView()
    container:ReleaseChildren()

    -- Add elements to the inner InlineGroup
    local itemViewContainer = getItemsViewContainer()
    container:AddChild(itemViewContainer)

    -- Refresh the parent element so the scroll bar appears if required
    container.parent:DoLayout()
end

-- Opposite of the serialise() function
-- This takes a string of items and loads them into the view
function ModalWindowItemPlanel:LoadEncodedItems(serialised)

    local json = ItemPlanner.Utils.base64DecodeUrlSafe(serialised)

    if (json) then

        local items = ItemPlanner.Json.decode(json)
        if (items) then
            self.ItemsShowing = items
            self.RefreshView()
            return
        end

    end

    print("Invalid items list found")
    throw "Invalid items list found"

end

-- Opposite of the Load() function
-- This returns a string of the items currently showing
function ModalWindowItemPlanel:Serialise()

    local json = ItemPlanner.Json.encode(self.ItemsShowing)
    return ItemPlanner.Utils.base64EncodeUrlSafe(json)

end

function mergePinnedItemsIntoNewItems(newItems, oldItems)

    -- Iterate over the table using pairs
    for key, value in pairs(oldItems) do
        -- If the item is pined, then add it to the new items
        if (value.pinned) then

            -- Add it to the start of the list
            table.insert(newItems, 1, value)

        end
    end

    return newItems

end

function limitItemsPerSlot(items)

    local limitedItems = {}

    for slotId, itemsInSlot in pairs(items) do

        limitedItems[slotId] = ItemPlanner.Utils.tableLimit(itemsInSlot, ITEMS_TO_SHOW_PER_SLOT)

    end

    return limitedItems

end

function ModalWindowItemPlanel:updateListOfShowingItems(orderedListOfItems, unpinAllPinedItems)

    print("COUNT 0 " .. ItemPlanner.Utils.tableCountKeys(orderedListOfItems))

    -- If not unpinning all pined items, then merge the currently pined items into the new items
    if (not unpinAllPinedItems) then
        orderedListOfItems = mergePinnedItemsIntoNewItems(orderedListOfItems, self.ItemsShowing)
    end

    print("COUNT " .. ItemPlanner.Utils.tableCountKeys(orderedListOfItems))

    -- The items array holds a list of all items possible to show
    -- So let's limit it down to 5 items per slot
    orderedListOfItems = limitItemsPerSlot(orderedListOfItems)

    print("COUNT 1 " .. ItemPlanner.Utils.tableCountKeys(orderedListOfItems))

    self.ItemsShowing = orderedListOfItems
    self:RefreshView()

end

