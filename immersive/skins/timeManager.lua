local _, GW = ...

local function LoadTimeManagerSkin()
    if not GW.settings.TIMEMANAGER_SKIN_ENABLED then return end
    local TimeManagerFrame = _G.TimeManagerFrame

    local regions = {TimeManagerFrame:GetRegions()}
    for _,region in pairs(regions) do
        if region:IsObjectType("FontString") then
            if region:GetText() == TIMEMANAGER_TITLE then
                region:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
                break
            end
        end
    end
    TimeManagerFrame:SetMovable(true)
    TimeManagerFrame:EnableMouse(true)
    TimeManagerFrame:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            TimeManagerFrame:StartMoving()
        end
    end)
    TimeManagerFrame:SetScript("OnMouseUp", function()
        TimeManagerFrame:StopMovingOrSizing()
    end)
    TimeManagerFrame:GwStripTextures()
    TimeManagerFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)

    TimeManagerFrame.CloseButton:GwSkinButton(true)
    TimeManagerFrame.CloseButton:SetSize(20, 20)

    local Alarm = TimeManagerAlarmTimeFrame
    Alarm.HourDropdown:ClearAllPoints()
    Alarm.HourDropdown:SetPoint("TOPLEFT", TimeManagerAlarmTimeLabel, "BOTTOMLEFT", -10, -4)
    Alarm.HourDropdown:GwHandleDropDownBox()
    Alarm.MinuteDropdown:GwHandleDropDownBox()
    Alarm.AMPMDropdown:GwHandleDropDownBox()

    Alarm.HourDropdown:SetWidth(70)
    Alarm.MinuteDropdown:SetWidth(70)
    Alarm.AMPMDropdown:SetWidth(70)

    TimeManagerAlarmMessageFrame:ClearAllPoints()
    TimeManagerAlarmMessageFrame:SetPoint("TOPLEFT", Alarm.HourDropdown, "BOTTOMLEFT", 6, 0)

    GW.SkinTextBox(_G.TimeManagerAlarmMessageEditBox.Middle, _G.TimeManagerAlarmMessageEditBox.Left, _G.TimeManagerAlarmMessageEditBox.Right, nil, nil, 5, 5)
    _G.TimeManagerAlarmEnabledButton:GwSkinCheckButton()
    _G.TimeManagerMilitaryTimeCheck:GwSkinCheckButton()
    _G.TimeManagerLocalTimeCheck:GwSkinCheckButton()

    _G.TimeManagerAlarmEnabledButton:SetSize(16, 16)
    _G.TimeManagerMilitaryTimeCheck:SetSize(16, 16)
    _G.TimeManagerLocalTimeCheck:SetSize(16, 16)

    local TimeManagerStopwatchCheck = _G.TimeManagerStopwatchCheck
    _G.TimeManagerStopwatchFrame:GwStripTextures()
    TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local hover = TimeManagerStopwatchCheck:CreateTexture()
    hover:SetColorTexture(1, 1, 1, 0.3)
    hover:SetPoint("TOPLEFT", TimeManagerStopwatchCheck, 2, -2)
    hover:SetPoint("BOTTOMRIGHT", TimeManagerStopwatchCheck, -2, 2)
    TimeManagerStopwatchCheck:SetHighlightTexture(hover)

    local StopwatchFrame = _G.StopwatchFrame
    StopwatchFrame:GwStripTextures()
    StopwatchFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)

    _G.StopwatchTabFrame:GwStripTextures()
    _G.StopwatchCloseButton:GwSkinButton(true)
end
GW.LoadTimeManagerSkin = LoadTimeManagerSkin