-- PlayersInventoryModule.lua

-- The entire purpose of this module is to keep track of all items the player has in their bags and bank
-- This should be synced when the player opens their bags or bank
-- This doesn't need to persist on logout

---@class PlayersInventoryModule
---@field GetInventory function returns a Professionator.PlayersInventory object

local PlayersInventoryModule = ProfessionatorLoader:CreateModule("PlayersInventoryModule")

local playersInventories = {}


local function getCharacterId()
    return Professionator.Utils.getCharacterId()
end

-- Event handler for BAG_UPDATE event
local function OnBagUpdate()

    local inventoryBefore = Professionator.Utils.deepCopy(playersInventories[getCharacterId()]:get("inventory"))

    -- Clear current inventory items
    playersInventories[getCharacterId()]:flush("inventory")

    local count = 0

    -- Loop through all bag slots and update inventory items
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemId = C_Container.GetContainerItemID(bag, slot)
            if itemId then
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                local itemCount = itemInfo.stackCount
                playersInventories[getCharacterId()]:add(itemId, itemCount, "inventory")

                count = count + 1
            end
        end
    end

    local inventoryAfter = Professionator.Utils.deepCopy(playersInventories[getCharacterId()]:get("inventory"))

    -- Compare the inventory before and after the update
    if not Professionator.Utils.tableEqual(inventoryBefore, inventoryAfter) then
        print("Inventory changed!")
    end
end

-- Event handler for BANKFRAME_OPENED event
local function OnBankOpened()
    -- Clear current bank items
    playersInventories[getCharacterId()]:flush("bank")

    local count = 0

    -- Loop through all bank slots and update bank items
    for bankSlot = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bankSlot) do
            local itemId = C_Container.GetContainerItemID(bankSlot, slot)
            if itemId then
                local itemInfo = C_Container.GetContainerItemInfo(bankSlot, slot)
                local itemCount = itemInfo.stackCount
                playersInventories[getCharacterId()]:add(itemId, itemCount, "bank")

                count = count + 1
            end
        end
    end

    -- Also add items from the main bank container
    for slot = 1, C_Container.GetContainerNumSlots(BANK_CONTAINER) do
        local itemId = C_Container.GetContainerItemID(BANK_CONTAINER, slot)
        if itemId then
            local itemInfo = C_Container.GetContainerItemInfo(BANK_CONTAINER, slot)
            local itemCount = itemInfo.stackCount
            playersInventories[getCharacterId()]:add(itemId, itemCount, "bank")

            count = count + 1
        end
    end

    print("OnBankOpened: " .. count)
end

function PlayersInventoryModule:Register()
    -- Setup the playersInventory variable
    playersInventories[getCharacterId()] = Professionator.PlayersInventory:Create()

    local frame = CreateFrame("Frame")

    -- Register the events
    frame:RegisterEvent("BAG_UPDATE")
    frame:RegisterEvent("BANKFRAME_OPENED")

    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "BAG_UPDATE" then
            --print("Bags updated!")

            OnBagUpdate()

        elseif event == "BANKFRAME_OPENED" then
            print("Bank opened!")

            OnBankOpened()

        end
    end)


end

-- Return a Professionator.PlayersInventory object
function PlayersInventoryModule:GetInventory()
    return playersInventories[getCharacterId()]
end

-- Return a Professionator.PlayersInventory object
function PlayersInventoryModule:SetInventory(inventory)
    playersInventories[getCharacterId()] = inventory
end

