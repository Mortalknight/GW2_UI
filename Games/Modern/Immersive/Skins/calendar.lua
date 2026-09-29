---@class GW2
local GW = select(2, ...)

local HEADER_COLOR = GW.Colors.TextColors.LightHeader
local HOVER = "Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png"
local EVENT_HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"

-- blizzards borders and backgrounds around buttons, dividers and the month and year plates
local HIDDEN_ART = {
    "CalendarCreateEventFrameButtonBackground", "CalendarCreateEventMassInviteButtonBorder", "CalendarCreateEventCreateButtonBorder",
    "CalendarCreateEventRaidInviteButtonBorder", "CalendarEventPickerFrameButtonBackground", "CalendarEventPickerCloseButtonBorder",
    "CalendarTexturePickerFrameButtonBackground", "CalendarTexturePickerAcceptButtonBorder", "CalendarTexturePickerCancelButtonBorder",
    "CalendarClassTotalsButtonBackgroundTop", "CalendarClassTotalsButtonBackgroundMiddle", "CalendarClassTotalsButtonBackgroundBottom",
    "CalendarViewEventDivider", "CalendarCreateEventDivider", "CalendarTodayTexture", "CalendarTodayTextureGlow",
}

local CLOSE_BUTTONS = {
    "CalendarCloseButton", "CalendarCreateEventCloseButton", "CalendarMassInviteCloseButton", "CalendarViewRaidCloseButton",
    "CalendarViewHolidayCloseButton", "CalendarViewEventCloseButton",
}

local ACTION_BUTTONS = {
    "CalendarCreateEventCreateButton", "CalendarCreateEventMassInviteButton", "CalendarCreateEventInviteButton",
    "CalendarCreateEventRaidInviteButton", "CalendarTexturePickerAcceptButton", "CalendarTexturePickerCancelButton",
    "CalendarMassInviteAcceptButton", "CalendarViewEventAcceptButton", "CalendarViewEventTentativeButton",
    "CalendarViewEventRemoveButton", "CalendarViewEventDeclineButton", "CalendarEventPickerCloseButton",
}

-- dropdowns and their width
local DROPDOWNS = {
    {"CalendarCreateEventFrame", "EventTypeDropdown", 120}, {"CalendarCreateEventFrame", "HourDropdown", 52},
    {"CalendarCreateEventFrame", "MinuteDropdown", 52}, {"CalendarCreateEventFrame", "AMPMDropdown", 57},
    {"CalendarCreateEventFrame", "DifficultyOptionDropdown", 80}, {"CalendarMassInviteFrame", "CommunityDropdown", 200},
    {"CalendarMassInviteFrame", "RankDropdown", 140},
}

-- the popups beside the calendar; true for those that open right next to it
local POPUPS = {
    CalendarCreateEventFrame = true, CalendarViewRaidFrame = true, CalendarViewHolidayFrame = true, CalendarViewEventFrame = true,
    CalendarTexturePickerFrame = false, CalendarMassInviteFrame = false, CalendarEventPickerFrame = false,
}

local function SkinPopup(popup, besideCalendar)
    popup:GwStripTextures(popup == CalendarViewHolidayFrame)
    popup:GwSetFrameTemplate("Dark")
    popup.Header:GwStripTextures()
    popup.Header.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    popup.Header.Text:SetTextColor(HEADER_COLOR:GetRGB())
    if besideCalendar then
        popup:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
    end
end

-- the rows of the lists get the hover of our item lists
local function AddListHover(frame)
    hooksecurefunc(frame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
end

local function SkinScrollBar(frame)
    GW.HandleTrimScrollBar(frame.ScrollBar)
    GW.HandleScrollControls(frame)
end

local function SkinTextSection(frame, background)
    frame.NineSlice:GwKill()
    local target = background or frame
    if not target.backdrop then
        GW.AddDetailsBackground(target)
    end
end

local function SkinTextBox(edit)
    GW.SkinTextBox(edit.Middle, edit.Left, edit.Right)
end

-- the event icon sits big in the corner of the event header, the title or date beside it
local function SkinEventIcon(icon, label)
    icon:SetSize(54, 54)
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", CalendarViewEventFrame.HeaderFrame, "TOPLEFT", 15, -20)
    icon:GwCreateBackdrop()
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    label:ClearAllPoints()
    label:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5, 0)
end

-- blizzard lights the selected day up to full alpha, ours keeps a soft hover on every day
local HIGHLIGHT_ALPHA = 0.15
local function KeepHighlightAlpha(highlight, alpha)
    if alpha ~= HIGHLIGHT_ALPHA then
        highlight:SetAlpha(HIGHLIGHT_ALPHA)
    end
end

local function SkinDayButtons()
    for i = 1, 42 do
        local day = _G["CalendarDayButton" .. i]
        _G["CalendarDayButton" .. i .. "DarkFrame"]:SetAlpha(0.5)
        day:DisableDrawLayer("BACKGROUND")
        day:GwSetFrameTemplate("Dark")
        day:SetBackdropColor(GW.Colors.Transparent:GetRGBA())
        day:GwOffsetFrameLevel(1)

        day:SetHighlightTexture(HOVER)
        local highlight = day:GetHighlightTexture()
        -- blended, not added: on the bright event art an added white washes everything out
        highlight:SetBlendMode("BLEND")
        highlight:SetPoint("TOPLEFT", -1, 1)
        highlight:SetPoint("BOTTOMRIGHT")
        highlight:SetAlpha(HIGHLIGHT_ALPHA)
        hooksecurefunc(highlight, "SetAlpha", KeepHighlightAlpha)

        -- the event lines of the day hover like the rows of our lists
        for j = 1, 4 do
            local event = _G["CalendarDayButton" .. i .. "EventButton" .. j]
            if event then
                event:SetHighlightTexture(EVENT_HOVER)
                local eventHighlight = event:GetHighlightTexture()
                eventHighlight:SetBlendMode("BLEND")
                eventHighlight:SetVertexColor(GW.Colors.SkinColors.ListHover:GetRGBA())
            end
        end
    end

    -- today gets a light frame instead of the pulsing glow; blizzard moves it to the day of today
    CalendarTodayFrame:GwSetFrameTemplate()
    CalendarTodayFrame:SetBackdropBorderColor(HEADER_COLOR:GetRGB())
    CalendarTodayFrame:SetBackdropColor(GW.Colors.Transparent:GetRGBA())
    CalendarTodayFrame:SetScript("OnUpdate", nil)
    hooksecurefunc("CalendarFrame_SetToday", function() CalendarTodayFrame:SetAllPoints() end)

    CalendarWeekdaySelectedTexture:SetDesaturated(true)
    CalendarWeekdaySelectedTexture:SetVertexColor(1, 1, 1, 0.6)
    for i = 1, 7 do
        _G["CalendarWeekday" .. i .. "Background"]:SetAlpha(0)
        _G["CalendarWeekday" .. i .. "Name"]:SetTextColor(HEADER_COLOR:GetRGB())
    end
end

-- the class counts of a raid event: class icons in a column
local function SkinClassButtons()
    CalendarClassButton1:SetPoint("TOPLEFT", CalendarClassButtonContainer, "TOPLEFT", 3, 0)
    for i, class in ipairs(CLASS_SORT_ORDER) do
        local button = _G["CalendarClassButton" .. i]
        button:GetNormalTexture():SetTexCoord(GW.GetClassCoords(class, true))
        button:GetRegions():Hide()
        button:GwSetFrameTemplate("Dark")
        button:SetSize(28, 28)
        if i > 1 then
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", _G["CalendarClassButton" .. i - 1], "BOTTOMLEFT", 0, -8)
        end

        local count = _G["CalendarClassButton" .. i .. "Count"]
        count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        count:ClearAllPoints()
        count:SetPoint("BOTTOMRIGHT", 0, 1)
    end

    CalendarClassTotalsButton:GwStripTextures()
    CalendarClassTotalsButton:GwSetFrameTemplate("Dark")
    CalendarClassTotalsButton:SetSize(28, 18)
end

local function ApplyCalendarFrameSkin()
    if not GW.settings.skins.calendar.enabled then return end

    CalendarFrame:DisableDrawLayer("BORDER")
    GW.CreateFrameHeaderWithBody(CalendarFrame, nil, "Interface/AddOns/GW2_UI/textures/character/calendar_window_icon.png", nil, nil, nil, true)
    CalendarFrameHeader:SetFrameLevel(0)
    CalendarFrame.FilterButton:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, 85)
    CalendarFrame.FilterButton:SetPoint("TOPRIGHT", CalendarFrame, "TOPRIGHT", -4, -34)
    CalendarFrameModalOverlay:SetAlpha(0.25)

    CalendarMonthName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader)
    CalendarYearName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    CalendarYearName:SetTextColor(HEADER_COLOR:GetRGB())
    CalendarMonthBackground:SetAlpha(0)
    CalendarMonthBackground:SetPoint("TOP", -3, 8)
    CalendarYearBackground:SetAlpha(0)
    CalendarYearBackground:SetPoint("TOP", CalendarMonthBackground, "BOTTOM", -2, 15)
    GW.HandleNextPrevButton(CalendarPrevMonthButton)
    GW.HandleNextPrevButton(CalendarNextMonthButton)

    for _, name in ipairs(HIDDEN_ART) do
        _G[name]:Hide()
    end
    for _, name in ipairs(CLOSE_BUTTONS) do
        _G[name]:GwSkinButton(true)
    end
    CalendarCloseButton:SetPoint("TOPRIGHT", CalendarFrame, "TOPRIGHT", -4, -2)
    for _, name in ipairs(ACTION_BUTTONS) do
        _G[name]:GwSkinButton(false, true)
    end
    CalendarViewEventRemoveButton:GwSkinNegativeButton()
    for _, dropdown in ipairs(DROPDOWNS) do
        _G[dropdown[1]][dropdown[2]]:GwHandleDropDownBox(nil, nil, nil, dropdown[3])
    end
    for name, besideCalendar in pairs(POPUPS) do
        SkinPopup(_G[name], besideCalendar)
    end

    SkinDayButtons()
    SkinClassButtons()

    -- create event: invite line, title, lock check and difficulty
    CalendarCreateEventInviteEdit:SetWidth(CalendarCreateEventInviteEdit:GetWidth() - 2)
    CalendarCreateEventInviteButton:SetPoint("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
    for _, edit in ipairs({CalendarCreateEventInviteEdit, CalendarCreateEventTitleEdit, CalendarMassInviteMinLevelEdit, CalendarMassInviteMaxLevelEdit}) do
        SkinTextBox(edit)
    end
    CalendarCreateEventLockEventCheck:GwSkinCheckButton()
    CalendarCreateEventFrame.DifficultyOptionDropdown:ClearAllPoints()
    CalendarCreateEventFrame.DifficultyOptionDropdown:SetPoint("TOPLEFT", CalendarCreateEventFrame, "TOPLEFT", 220, -114)
    SkinEventIcon(CalendarViewEventIcon, CalendarViewEventTitle)
    SkinEventIcon(CalendarCreateEventIcon, CalendarCreateEventDateLabel)

    -- invite lists, descriptions and the pickers
    SkinTextSection(CalendarViewEventInviteList)
    SkinTextSection(CalendarCreateEventInviteList)
    SkinTextSection(CalendarViewEventDescriptionContainer, CalendarViewEventDescriptionScrollFrame)
    SkinTextSection(CalendarCreateEventDescriptionContainer, CalendarCreateEventDescriptionScrollFrame)
    GW.SkinSlimScrollBar(CalendarViewEventDescriptionContainer.ScrollBar)
    GW.SkinSlimScrollBar(CalendarCreateEventDescriptionContainer.ScrollBar)
    CalendarViewEventInviteListSection:GwStripTextures()
    CalendarViewHolidayFrameModalOverlay:SetAlpha(0)
    for _, list in ipairs({CalendarCreateEventInviteList, CalendarTexturePickerFrame, CalendarEventPickerFrame}) do
        SkinScrollBar(list)
    end
    for _, list in ipairs({CalendarViewEventInviteList, CalendarCreateEventInviteList, CalendarTexturePickerFrame, CalendarEventPickerFrame}) do
        AddListHover(list)
    end
end

function GW.LoadCalendarSkin()
    GW.RegisterLoadHook(ApplyCalendarFrameSkin, "Blizzard_Calendar", CalendarFrame)
end
