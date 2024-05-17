-- GameTooltip.lua

---@class GameTooltip
---@field SetupTooltip function

local GameTooltip = ProfessionatorLoader:CreateModule("GameTooltip")


-- Called like:
-- GameTooltip:SetupTooltip({
--     targetElement = recipeText,
--     text = "This is a tooltip",
--     position = "RIGHT",      -- Optional. Default is "RIGHT"
--     x = 10,      -- Optional. Default is "0"
--     y = 0,      -- Optional. Default is "0"
-- })
function GameTooltip:SetupTooltip(options)
    local targetElement = options.targetElement
    local parentFrame = options.parentFrame or UIParent
    local text = options.text
    local anchor1 = options.anchor1 or "TOP"
    local anchor2 = options.anchor2 or "BOTTOM"
    local maxWidth = options.maxWidth or 200 -- Maximum width for the tooltip
    local padding = options.padding or 14

    -- Error checking
    if not targetElement or not text or not parentFrame then
        print("Error: Missing required parameters for tooltip setup")
        return
    end

    -- Create a frame for the tooltip if not already created
    if not targetElement.tooltipFrame then
        targetElement.tooltipFrame = CreateFrame("Frame", nil, parentFrame)
        targetElement.tooltipFrame:SetFrameStrata("TOOLTIP")
        targetElement.tooltipFrame:Hide()

        -- Create background texture
        targetElement.tooltipFrame.backgroundTexture = targetElement.tooltipFrame:CreateTexture(nil, "BACKGROUND")
        targetElement.tooltipFrame.backgroundTexture:SetAllPoints(targetElement.tooltipFrame)
        targetElement.tooltipFrame.backgroundTexture:SetColorTexture(0, 0, 0, 0.7) -- Black with 70% opacity
        -- Add a nice background
        --targetElement.tooltipFrame.backgroundTexture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Border")
        --targetElement.tooltipFrame.backgroundTexture:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
        targetElement.tooltipFrame.backgroundTexture:SetTexture("Interface\\Tooltips\\ChatBubble-Backdrop")

        -- Create font string for text
        targetElement.tooltipFrame.text = targetElement.tooltipFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        targetElement.tooltipFrame.text:SetPoint("TOPLEFT", targetElement.tooltipFrame, "TOPLEFT", padding, -padding)
        targetElement.tooltipFrame.text:SetPoint("BOTTOMRIGHT", targetElement.tooltipFrame, "BOTTOMRIGHT", -padding, padding)
        targetElement.tooltipFrame.text:SetJustifyH("LEFT") -- Align text to the left
        targetElement.tooltipFrame.text:SetJustifyV("TOP") -- Align text to the top
        targetElement.tooltipFrame.text:SetWordWrap(true) -- Enable word wrapping for the text
    end

    -- Set text and adjust tooltip size based on text width
    targetElement.tooltipFrame.text:SetText(text)
    targetElement.tooltipFrame.text:SetWidth(maxWidth - (padding * 2)) -- Subtracting padding
    targetElement.tooltipFrame.text:SetHeight(0) -- Reset height to auto-adjust based on content
    local textHeight = targetElement.tooltipFrame.text:GetStringHeight()
    local tooltipWidth = math.min(maxWidth, targetElement.tooltipFrame.text:GetStringWidth() + (padding * 2)) -- Adding padding

    targetElement.tooltipFrame:SetSize(tooltipWidth, textHeight + (padding * 2)) -- Adding padding

    targetElement.tooltipFrame:SetPoint(anchor1, targetElement, anchor2)

    targetElement:SetScript("OnEnter", function()
        targetElement.tooltipFrame:Show()
    end)

    targetElement:SetScript("OnLeave", function()
        targetElement.tooltipFrame:Hide()
    end)


    --GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
    GameTooltip:SetOwner(parentFrame, "ANCHOR_BOTTOM", 0,0	)
    GameTooltip:ClearLines()
    GameTooltip:AddLine("test",0.9,0.9,0.9,1)
    --GameTooltip:AddLine(string.format(GBB.L["msgLastTime"],GBB.formatTime(time()-req.last)).."|n"..string.format(GBB.L["msgTotalTime"],GBB.formatTime(time()-req.start)))

    GameTooltip:Show()
end
