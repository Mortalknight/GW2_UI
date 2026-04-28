---@class GW2
local GW = select(2, ...)
local FADE_TEXTURE = "Interface/AddOns/GW2_UI/textures/character/menu-bg.png"

local function AddFadeTexture(parent, width, height, alpha)
    local texture = parent:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture(FADE_TEXTURE)
    texture:SetSize(width, height)
    texture:SetAlpha(alpha or 0.80)
    texture:SetTexCoord(1, 0, 0, 1)
    texture:Show()

    return texture
end

local function SkinFontString(fontString, font, textSizeType, r, g, b)
    if not fontString then
        return
    end

    fontString:GwSetFontTemplate(font, textSizeType)
    fontString:SetShadowOffset(1, -1)
    GW.LockFontStringColor(fontString, r or 1, g or 1, b or 1)
end

local function SkinCheckButtonText(button)
    if not button or not button.GetName then
        return
    end

    local text = _G[button:GetName() .. "Text"]
    if not text then
        return
    end

    text:ClearAllPoints()
    text:SetPoint("LEFT", button, "RIGHT", 6, 0)
    text:SetJustifyH("LEFT")
    SkinFontString(text, UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, 1, 1, 1)
end

local function SkinStopwatchControlButton(button)
    if not button or button.gwTimeManagerSkinned then
        return
    end

    button:SetSize(24, 24)
    button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 1, 1)

    local function SkinTexture(texture)
        if not texture then
            return
        end

        texture:ClearAllPoints()
        texture:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
        texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)
        texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        texture:SetDesaturated(true)
        texture:SetVertexColor(1, 1, 1, 0.9)
    end

    SkinTexture(button:GetNormalTexture())
    SkinTexture(button:GetPushedTexture())
    SkinTexture(button:GetDisabledTexture())

    local hover = button:CreateTexture(nil, "HIGHLIGHT")
    hover:SetColorTexture(1, 1, 1, 0.18)
    hover:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    hover:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    button:SetHighlightTexture(hover)

    hooksecurefunc(button, "SetNormalTexture", function(self)
        SkinTexture(self:GetNormalTexture())
    end)

    button.gwTimeManagerSkinned = true
end

local function GetTimeManagerTitle(frame)
    for _, region in pairs({frame:GetRegions()}) do
        if region:IsObjectType("FontString") and region:GetText() == TIMEMANAGER_TITLE then
            return region
        end
    end
end

local function MakeFrameMovable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            frame:StartMoving()
        end
    end)
    frame:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
    end)
end

local function SkinTimeManagerDropdown(dropdown, width)
    if not dropdown then
        return
    end

    dropdown:GwHandleDropDownBox()
    dropdown:SetWidth(width)
end

local function SkinTimeManagerFrame()
    local frame = TimeManagerFrame
    if not frame then
        return
    end

    local title = GetTimeManagerTitle(frame)

    frame:SetSize(250, 258)
    MakeFrameMovable(frame)
    frame:GwStripTextures()
    frame:GwCreateBackdrop(GW.BackdropTemplates.Default)

    if title then
        title:ClearAllPoints()
        title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -14)
        SkinFontString(title, DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, GW.Colors.TextColors.LightHeader:GetRGB())
    end

    if TimeManagerFrameTicker then
        TimeManagerFrameTicker:ClearAllPoints()
        TimeManagerFrameTicker:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -34, -17)
        SkinFontString(TimeManagerFrameTicker, DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, 1, 1, 1)

        local clockFade = AddFadeTexture(frame, 150, 30)
        clockFade:SetPoint("RIGHT", TimeManagerFrameTicker, "RIGHT", 5, 0)
    end

    if frame.CloseButton then
        frame.CloseButton:GwSkinButton(true)
        frame.CloseButton:SetSize(20, 20)
        frame.CloseButton:ClearAllPoints()
        frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -6)
    end

    if TimeManagerStopwatchFrame then
        TimeManagerStopwatchFrame:ClearAllPoints()
        TimeManagerStopwatchFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -44)
        TimeManagerStopwatchFrame:SetSize(218, 32)
        TimeManagerStopwatchFrame:GwStripTextures()

        local stopwatchToggleFade = AddFadeTexture(TimeManagerStopwatchFrame, 218, 32)
        stopwatchToggleFade:SetAllPoints(TimeManagerStopwatchFrame)
    end

    local alarm = TimeManagerAlarmTimeFrame
    if alarm then
        alarm:ClearAllPoints()
        alarm:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -84)
        alarm:SetSize(218, 52)

        if alarm.HourDropdown and TimeManagerAlarmTimeLabel then
            alarm.HourDropdown:ClearAllPoints()
            alarm.HourDropdown:SetPoint("TOPLEFT", TimeManagerAlarmTimeLabel, "BOTTOMLEFT", -10, -6)
        end

        SkinTimeManagerDropdown(alarm.HourDropdown, 70)
        SkinTimeManagerDropdown(alarm.MinuteDropdown, 70)
        SkinTimeManagerDropdown(alarm.AMPMDropdown, 70)
    end

    if TimeManagerAlarmMessageFrame and alarm and alarm.HourDropdown then
        TimeManagerAlarmMessageFrame:ClearAllPoints()
        TimeManagerAlarmMessageFrame:SetPoint("TOPLEFT", alarm.HourDropdown, "BOTTOMLEFT", 6, -4)
        TimeManagerAlarmMessageFrame:SetSize(218, 44)
    end

    if TimeManagerAlarmMessageEditBox then
        GW.SkinTextBox(TimeManagerAlarmMessageEditBox.Middle, TimeManagerAlarmMessageEditBox.Left, TimeManagerAlarmMessageEditBox.Right, nil, nil, 5, 5)
        TimeManagerAlarmMessageEditBox:SetWidth(210)
        TimeManagerAlarmMessageEditBox:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        TimeManagerAlarmMessageEditBox:SetTextColor(1, 1, 1)
    end

    for _, checkButton in pairs({
        TimeManagerAlarmEnabledButton,
        TimeManagerMilitaryTimeCheck,
        TimeManagerLocalTimeCheck,
    }) do
        if checkButton then
            checkButton:GwSkinCheckButton()
            checkButton:SetSize(16, 16)
            SkinCheckButtonText(checkButton)
        end
    end

    if TimeManagerAlarmEnabledButton and TimeManagerAlarmMessageEditBox then
        TimeManagerAlarmEnabledButton:ClearAllPoints()
        TimeManagerAlarmEnabledButton:SetPoint("TOPLEFT", TimeManagerAlarmMessageEditBox, "BOTTOMLEFT", -2, -16)
    end

    if TimeManagerMilitaryTimeCheck and TimeManagerAlarmEnabledButton then
        TimeManagerMilitaryTimeCheck:ClearAllPoints()
        TimeManagerMilitaryTimeCheck:SetPoint("TOPLEFT", TimeManagerAlarmEnabledButton, "BOTTOMLEFT", 0, -8)
    end

    if TimeManagerLocalTimeCheck and TimeManagerMilitaryTimeCheck then
        TimeManagerLocalTimeCheck:ClearAllPoints()
        TimeManagerLocalTimeCheck:SetPoint("TOPLEFT", TimeManagerMilitaryTimeCheck, "BOTTOMLEFT", 0, -8)
    end

    SkinFontString(TimeManagerStopwatchFrameText, UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, 1, 1, 1)
    SkinFontString(TimeManagerAlarmTimeLabel, UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, 1, 1, 1)
    SkinFontString(TimeManagerAlarmMessageLabel, UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, 1, 1, 1)

    local stopwatchCheck = TimeManagerStopwatchCheck
    if stopwatchCheck and TimeManagerStopwatchFrame then
        stopwatchCheck:SetSize(28, 28)
        stopwatchCheck:ClearAllPoints()
        stopwatchCheck:SetPoint("RIGHT", TimeManagerStopwatchFrame, "RIGHT", -2, 0)
        stopwatchCheck:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/watchicon.png")
        stopwatchCheck:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/watchiconactive.png")

        if stopwatchCheck:GetNormalTexture() then
            stopwatchCheck:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        end

        if stopwatchCheck:GetCheckedTexture() then
            stopwatchCheck:GetCheckedTexture():SetTexCoord(0, 1, 0, 1)
        end

        if TimeManagerStopwatchFrameText then
            TimeManagerStopwatchFrameText:ClearAllPoints()
            TimeManagerStopwatchFrameText:SetPoint("RIGHT", stopwatchCheck, "LEFT", -8, 0)
        end

        local hover = stopwatchCheck:CreateTexture()
        hover:SetColorTexture(1, 1, 1, 0.18)
        hover:SetPoint("TOPLEFT", stopwatchCheck, 2, -2)
        hover:SetPoint("BOTTOMRIGHT", stopwatchCheck, -2, 2)
        stopwatchCheck:SetHighlightTexture(hover)
    end
end

local function SkinStopwatchFrame()
    local frame = StopwatchFrame
    if not frame then
        return
    end

    frame:SetSize(158, 56)
    frame:GwStripTextures()
    frame:GwCreateBackdrop(GW.BackdropTemplates.Default)

    if StopwatchTabFrame then
        StopwatchTabFrame:GwStripTextures()
        StopwatchTabFrame:ClearAllPoints()
        StopwatchTabFrame:SetAllPoints(frame)
    end

    if StopwatchCloseButton then
        StopwatchCloseButton:GwSkinButton(true)
        StopwatchCloseButton:SetSize(18, 18)
        StopwatchCloseButton:ClearAllPoints()
        StopwatchCloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    end

    if StopwatchTitle then
        StopwatchTitle:ClearAllPoints()
        StopwatchTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -7)
        SkinFontString(StopwatchTitle, UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, GW.Colors.TextColors.LightHeader:GetRGB())
    end

    if StopwatchTicker then
        StopwatchTicker:ClearAllPoints()
        StopwatchTicker:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 8)
        StopwatchTicker:SetSize(86, 20)

        for _, region in pairs({StopwatchTicker:GetRegions()}) do
            if region:IsObjectType("FontString") then
                SkinFontString(region, DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, 1, 1, 1)
            end
        end
    end

    if StopwatchResetButton then
        StopwatchResetButton:ClearAllPoints()
        StopwatchResetButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 6)
        SkinStopwatchControlButton(StopwatchResetButton)
    end

    if StopwatchPlayPauseButton and StopwatchResetButton then
        StopwatchPlayPauseButton:ClearAllPoints()
        StopwatchPlayPauseButton:SetPoint("RIGHT", StopwatchResetButton, "LEFT", -4, 0)
        SkinStopwatchControlButton(StopwatchPlayPauseButton)
    end

    if StopwatchTicker and StopwatchResetButton then
        local stopwatchFade = AddFadeTexture(frame, 150, 28)
        stopwatchFade:SetPoint("RIGHT", StopwatchResetButton, "RIGHT", 4, 0)
    end
end

local function ApplyTimeManagerSkin()
    if not TimeManagerFrame and not StopwatchFrame then
        return
    end

    SkinTimeManagerFrame()
    SkinStopwatchFrame()
end

local function LoadTimeManagerSkin()
    if not GW.settings.TIMEMANAGER_SKIN_ENABLED then
        return
    end

    GW.RegisterLoadHook(ApplyTimeManagerSkin, "Blizzard_TimeManager", TimeManagerFrame)
end
GW.LoadTimeManagerSkin = LoadTimeManagerSkin
