-- MyGameTooltip.lua

---@class MyGameTooltip
---@field SetupTooltip function

local MyGameTooltip = ProfessionatorLoader:CreateModule("MyGameTooltip")

-- @see https://wowpedia.fandom.com/wiki/UIOBJECT_GameTooltip
local myTooltip2 = CreateFrame("GameTooltip", "ProfessionatorTooltip", UIParent, "GameTooltipTemplate")

-- Called like:
-- MyGameTooltip:SetupTooltip({
--     targetElement = recipeText,
--     text = "This is a tooltip",
--     position = "RIGHT",      -- Optional. Default is "RIGHT"
--     x = 10,      -- Optional. Default is "0"
--     y = 0,      -- Optional. Default is "0"
-- })
function MyGameTooltip:SetupTooltip(options)
    local targetElement = options.targetElement
    local beforeShow = options.beforeShow
    local anchor = options.anchor or "ANCHOR_BOTTOM"

    -- Error checking
    if not targetElement or not beforeShow then
        print("Error: Missing required parameters for tooltip setup")
        return
    end

    targetElement:SetScript("OnEnter", function(self)
        myTooltip2:SetOwner(self, anchor)

        -- Call the beforeShow function
        -- This is where the caller adds content to the tooltip
        beforeShow(myTooltip2);

        myTooltip2:Show()
    end)
    --
    targetElement:SetScript("OnLeave", function()
        myTooltip2:Hide()
    end)

end
