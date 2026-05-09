---@class GW2
local GW = select(2, ...)

local function SkinContainer(frame, container)
    frame.NineSlice:GwKill()

    if frame.ScrollBox then
        hooksecurefunc(frame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
    end

    local child = container or frame
    if child and not child.backdrop then
        GW.AddDetailsBackground(child)
    end
end

local function StripClassTextures(button, classFile)
    button:SetTexCoord(GW.GetClassCoords(classFile, true))
end

local function HandleEventIcon(icon)
    icon:SetSize(54, 54)
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", CalendarViewEventFrame.HeaderFrame, "TOPLEFT", 15, -20)
    icon:GwCreateBackdrop()
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
end

local function ApplyCalendarFrameSkin()
    if not GW.settings.CalendarSkinEnabled then return end

    CalendarFrame:DisableDrawLayer("BORDER")
    GW.CreateFrameHeaderWithBody(CalendarFrame, nil, "Interface/AddOns/GW2_UI/textures/character/calendar_window_icon.png", nil, nil, nil, true)
    CalendarFrameHeader:SetFrameLevel(0)
    CalendarFrame.FilterButton:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, 85)
    CalendarFrame.FilterButton:SetPoint("TOPRIGHT", CalendarFrame, "TOPRIGHT", -4, -34)
    CalendarCloseButton:GwSkinButton(true)
    CalendarCloseButton:SetPoint("TOPRIGHT", CalendarFrame, "TOPRIGHT", -4, -2)

    CalendarMonthName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader)
    CalendarYearName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    CalendarYearName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    CalendarMonthBackground:SetPoint("TOP", -3, 8)
    CalendarYearBackground:SetPoint("TOP", CalendarMonthBackground, "BOTTOM", -2, 15)

    for i = 1, 7 do
        _G["CalendarWeekday" .. i .. "Background"]:SetAlpha(0)
        _G["CalendarWeekday" .. i .. "Name"]:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end

    SkinContainer(CalendarViewEventInviteList)
    SkinContainer(CalendarCreateEventInviteList)
    SkinContainer(CalendarViewEventDescriptionContainer, CalendarViewEventDescriptionScrollFrame)
    SkinContainer(CalendarCreateEventDescriptionContainer, CalendarCreateEventDescriptionScrollFrame)

    CalendarCreateEventFrameButtonBackground:Hide()
    CalendarCreateEventMassInviteButtonBorder:Hide()
    CalendarCreateEventCreateButtonBorder:Hide()
    CalendarEventPickerFrameButtonBackground:Hide()
    CalendarEventPickerCloseButtonBorder:Hide()
    CalendarCreateEventRaidInviteButtonBorder:Hide()
    CalendarMonthBackground:SetAlpha(0)
    CalendarYearBackground:SetAlpha(0)
    CalendarFrameModalOverlay:SetAlpha(.25)
    CalendarTexturePickerFrameButtonBackground:Hide()
    CalendarTexturePickerAcceptButtonBorder:Hide()
    CalendarTexturePickerCancelButtonBorder:Hide()
    CalendarClassTotalsButtonBackgroundTop:Hide()
    CalendarClassTotalsButtonBackgroundMiddle:Hide()
    CalendarClassTotalsButtonBackgroundBottom:Hide()
    CalendarViewEventDivider:Hide()
    CalendarCreateEventDivider:Hide()

    GW.HandleNextPrevButton(CalendarPrevMonthButton, nil, nil)
    GW.HandleNextPrevButton(CalendarNextMonthButton, nil, nil)

    for i = 1, 42 do
        _G["CalendarDayButton" .. i .. "DarkFrame"]:SetAlpha(.5)
        local bu = _G["CalendarDayButton" .. i]

        bu:DisableDrawLayer("BACKGROUND")
        bu:GwSetFrameTemplate("Dark")
        bu:SetBackdropColor(0, 0, 0, 0)
        bu:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png")
        bu:GwOffsetFrameLevel(1)

        local hl = bu:GetHighlightTexture()
        hl:SetVertexColor(1, 1, 1, 0.3)
        hl:SetPoint("TOPLEFT", -1, 1)
        hl:SetPoint("BOTTOMRIGHT")
        hl.SetAlpha = GW.NoOp
    end

    CalendarWeekdaySelectedTexture:SetDesaturated(true)
    CalendarWeekdaySelectedTexture:SetVertexColor(1, 1, 1, 0.6)

    CalendarTodayTexture:Hide()
    CalendarTodayTextureGlow:Hide()

    CalendarTodayFrame:GwSetFrameTemplate()
    CalendarTodayFrame:SetBackdropBorderColor(GW.Colors.TextColors.LightHeader:GetRGB())
    CalendarTodayFrame:SetBackdropColor(0, 0, 0, 0)
    CalendarTodayFrame:SetScript("OnUpdate", nil)

    hooksecurefunc("CalendarFrame_SetToday", function()
        CalendarTodayFrame:SetAllPoints()
    end)

    -- CreateEventFrame
    CalendarCreateEventFrame:GwStripTextures()
    CalendarCreateEventFrame:GwSetFrameTemplate("Dark")
    CalendarCreateEventFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
    CalendarCreateEventFrame.Header:GwStripTextures()
    CalendarCreateEventFrame.Header.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    CalendarCreateEventFrame.Header.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    GW.HandleTrimScrollBar(CalendarCreateEventInviteList.ScrollBar)
    GW.HandleScrollControls(CalendarCreateEventInviteList)
    hooksecurefunc(CalendarCreateEventInviteList.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    CalendarCreateEventCreateButton:GwSkinButton(false, true)
    CalendarCreateEventMassInviteButton:GwSkinButton(false, true)
    CalendarCreateEventInviteButton:GwSkinButton(false, true)
    CalendarCreateEventInviteButton:SetPoint("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
    CalendarCreateEventInviteEdit:SetWidth(CalendarCreateEventInviteEdit:GetWidth() - 2, CalendarCreateEventInviteEdit:GetWidth() - 2)

    GW.SkinTextBox(CalendarCreateEventInviteEdit.Middle, CalendarCreateEventInviteEdit.Left, CalendarCreateEventInviteEdit.Right)
    GW.SkinTextBox(CalendarCreateEventTitleEdit.Middle, CalendarCreateEventTitleEdit.Left, CalendarCreateEventTitleEdit.Right)
    CalendarCreateEventFrame.EventTypeDropdown:GwHandleDropDownBox(nil, nil, nil, 120)

    CalendarCreateEventCloseButton:GwSkinButton(true)
    CalendarCreateEventLockEventCheck:GwSkinCheckButton()

    CalendarCreateEventFrame.HourDropdown:GwHandleDropDownBox(nil, nil, nil, 52)
    CalendarCreateEventFrame.MinuteDropdown:GwHandleDropDownBox(nil, nil, nil, 52)
    CalendarCreateEventFrame.AMPMDropdown:GwHandleDropDownBox(nil, nil, nil, 57)

    -- Difficulty Dropdown
    CalendarCreateEventFrame.DifficultyOptionDropdown:GwHandleDropDownBox(nil, nil, nil, 80)
    CalendarCreateEventFrame.DifficultyOptionDropdown:ClearAllPoints()
    CalendarCreateEventFrame.DifficultyOptionDropdown:SetPoint("TOPLEFT", CalendarCreateEventFrame, "TOPLEFT", 220, -114)

    CalendarViewEventTitle:ClearAllPoints()
    CalendarViewEventTitle:SetPoint("TOPLEFT", CalendarViewEventIcon, "TOPRIGHT", 5, 0)
    HandleEventIcon(CalendarViewEventIcon)

    CalendarCreateEventDateLabel:ClearAllPoints()
    CalendarCreateEventDateLabel:SetPoint("TOPLEFT", CalendarCreateEventIcon, "TOPRIGHT", 5, 0)
    HandleEventIcon(CalendarCreateEventIcon)

    CalendarClassButton1:SetPoint("TOPLEFT", CalendarClassButtonContainer, "TOPLEFT", 3, 0)

    local lastClassButton
    for i, class in next, CLASS_SORT_ORDER do
        local button = _G["CalendarClassButton" .. i]
        local count = _G["CalendarClassButton" .. i .. "Count"]
        StripClassTextures(button:GetNormalTexture(), class)
        button:GetRegions():Hide()
        button:GwSetFrameTemplate("Dark")
        button:SetSize(28, 28)

        count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        count:ClearAllPoints()
        count:SetPoint("BOTTOMRIGHT", 0, 1)

        if lastClassButton then
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", lastClassButton, "BOTTOMLEFT", 0, -8)
        end

        lastClassButton = button
    end

    CalendarClassTotalsButton:GwStripTextures()
    CalendarClassTotalsButton:GwSetFrameTemplate("Dark")
    CalendarClassTotalsButton:SetSize(28, 18)

    -- Texture Picker Frame
    CalendarTexturePickerFrame:GwStripTextures()
    CalendarTexturePickerFrame.Header:GwStripTextures()
    CalendarTexturePickerFrame.Header.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    CalendarTexturePickerFrame.Header.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    CalendarTexturePickerFrame:GwSetFrameTemplate("Dark")
    GW.HandleTrimScrollBar(CalendarTexturePickerFrame.ScrollBar)
    GW.HandleScrollControls(CalendarTexturePickerFrame)
    hooksecurefunc(CalendarTexturePickerFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    CalendarTexturePickerAcceptButton:GwSkinButton(false, true)
    CalendarTexturePickerCancelButton:GwSkinButton(false, true)
    CalendarCreateEventInviteButton:GwSkinButton(false, true)
    CalendarCreateEventRaidInviteButton:GwSkinButton(false, true)

    -- Mass Invite Frame
    CalendarMassInviteFrame:GwStripTextures()
    CalendarMassInviteFrame:GwSetFrameTemplate("Dark")
    CalendarMassInviteFrame.Header:GwStripTextures()
    CalendarMassInviteFrame.Header.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    CalendarMassInviteFrame.Header.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    CalendarMassInviteFrame.CommunityDropdown:GwHandleDropDownBox(nil, nil, nil, 200)
    CalendarMassInviteFrame.RankDropdown:GwHandleDropDownBox(nil, nil, nil, 140)
    GW.SkinTextBox(CalendarMassInviteMinLevelEdit.Middle, CalendarMassInviteMinLevelEdit.Left, CalendarMassInviteMinLevelEdit.Right)
    GW.SkinTextBox(CalendarMassInviteMaxLevelEdit.Middle, CalendarMassInviteMaxLevelEdit.Left, CalendarMassInviteMaxLevelEdit.Right)
    CalendarMassInviteCloseButton:GwSkinButton(true)
    CalendarMassInviteAcceptButton:GwSkinButton(false, true)

    -- Raid View
    CalendarViewRaidFrame:GwStripTextures()
    CalendarViewRaidFrame:GwSetFrameTemplate("Dark")
    CalendarViewRaidFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
    CalendarViewRaidFrame.Header:GwStripTextures()
    CalendarViewRaidFrame.Header.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    CalendarViewRaidFrame.Header.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    CalendarViewRaidCloseButton:GwSkinButton(true)

    -- Holiday View
    CalendarViewHolidayFrame:GwStripTextures(true)
    CalendarViewHolidayFrame:GwSetFrameTemplate("Dark")
    CalendarViewHolidayFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
    CalendarViewHolidayFrame.Header:GwStripTextures()
    CalendarViewHolidayFrame.Header.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    CalendarViewHolidayFrame.Header.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    CalendarViewHolidayFrameModalOverlay:SetAlpha(0)
    CalendarViewHolidayCloseButton:GwSkinButton(true)

    -- Event View
    CalendarViewEventFrame:GwStripTextures()
    CalendarViewEventFrame:GwSetFrameTemplate("Dark")
    CalendarViewEventFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
    CalendarViewEventFrame.Header:GwStripTextures()
    CalendarViewEventFrame.Header.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    CalendarViewEventFrame.Header.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    CalendarViewEventInviteListSection:GwStripTextures()

    CalendarViewEventCloseButton:GwSkinButton(true)
    CalendarViewEventAcceptButton:GwSkinButton(false, true)
    CalendarViewEventTentativeButton:GwSkinButton(false, true)
    CalendarViewEventRemoveButton:GwSkinButton(false, true)
    CalendarViewEventRemoveButton:GwSkinNegativeButton()
    CalendarViewEventDeclineButton:GwSkinButton(false, true)

    -- Event Picker Frame
    CalendarEventPickerFrame:GwStripTextures()
    CalendarEventPickerFrame.Header:GwStripTextures()
    CalendarEventPickerFrame.Header.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    CalendarEventPickerFrame.Header.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    CalendarEventPickerFrame:GwSetFrameTemplate("Dark")

    GW.HandleTrimScrollBar(CalendarEventPickerFrame.ScrollBar)
    GW.HandleScrollControls(CalendarEventPickerFrame)
    hooksecurefunc(CalendarEventPickerFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
    CalendarEventPickerCloseButton:GwSkinButton(false, true)
end

function GW.LoadCalendarSkin()
    GW.RegisterLoadHook(ApplyCalendarFrameSkin, "Blizzard_Calendar", CalendarFrame)
end
