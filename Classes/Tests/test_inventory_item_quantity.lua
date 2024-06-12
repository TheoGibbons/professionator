
local PlayersInventoryModule = ProfessionatorLoader:ImportModule("PlayersInventoryModule")

local savedState
local setup = function ()
    savedState = ProfessionatorUnitTesting.setupEnvironment({
        playersInventory = Professionator.PlayersInventory:Create({
            inventory = {
                [100] = 3,
                [101] = 4,
                [33333] = 3,
            },
            bank = {
                [11111] = 5,
                [22222] = 0,
                [33333] = 4,
            },
        }),
     })
end

local tearDown = function ()
    ProfessionatorUnitTesting.setupEnvironment(savedState)
end

ProfessionatorUnitTesting.test_inventory_item_quantity = function()

    print("Running inventory item quantity test...")

    setup()

    Professionator.Utils.tryCatchFinally(
        function()

            ProfessionatorUnitTesting.assert(3, PlayersInventoryModule:GetInventory():getItemQuantity(100), "There are 3 items with id 100 in the inventory")
            ProfessionatorUnitTesting.assert(4, PlayersInventoryModule:GetInventory():getItemQuantity(101), "There are 4 items with id 101 in the inventory")
            ProfessionatorUnitTesting.assert(5, PlayersInventoryModule:GetInventory():getItemQuantity(11111), "There are 5 items with id 11111 in the bank")
            ProfessionatorUnitTesting.assert(0, PlayersInventoryModule:GetInventory():getItemQuantity(22222), "There are 0 items with id 22222 in the bank")
            ProfessionatorUnitTesting.assert(7, PlayersInventoryModule:GetInventory():getItemQuantity(33333), "There are 7 items with id 33333 in the inventory")
            ProfessionatorUnitTesting.assert(0, PlayersInventoryModule:GetInventory():getItemQuantity(4444), "There are 0 items with id 4444 in the inventory")

            print("Test passed")

        end,
        function(e)
            print("Error: " .. e)
        end,
        tearDown
    )

end
