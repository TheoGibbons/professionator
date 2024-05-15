local CreateWindow = ProfessionatorLoader:CreateModule("CreateWindow")

function CreateWindow:Create(suffix, settings)
    local frame = CreateFrame("Frame", "Professionator" .. suffix, UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(300, 200)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnHide", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
    frame.title:SetText("Professionator")

    -- Create a ScrollFrame to contain the content
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -25)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 5)

    frame.content = CreateFrame("Frame", nil, frame.scrollFrame)
    --frame.content:SetSize(300, 200)
    frame.content:SetAllPoints()

    -- Attach the content to the ScrollFrame
    frame.scrollFrame:SetScrollChild(frame.content)

    if settings then
        if settings.title then
            frame.title:SetText(settings.title)
        end

        if settings.content then
            -- Attach content to the content frame
            settings.content:SetParent(frame.content)
            settings.content:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, 0)
            -- Adjust content size based on actual content size
            frame.content:SetSize(settings.content:GetWidth(), settings.content:GetHeight())
        end

        if settings.width then
            frame:SetWidth(settings.width)
            frame.scrollFrame:SetWidth(settings.width - 25) -- Adjust for scrollbar width
        end

        if settings.height then
            frame:SetHeight(settings.height)
            frame.scrollFrame:SetHeight(settings.height - 30) -- Adjust for scrollbar height and title height
        end

        if settings.referenceFrame then
            frame:SetPoint("TOPLEFT", settings.referenceFrame, "TOPRIGHT", -37, -13)
            frame:SetPoint("BOTTOMLEFT", settings.referenceFrame, "BOTTOMRIGHT", -37, 50)
        end
    end

    return frame
end
