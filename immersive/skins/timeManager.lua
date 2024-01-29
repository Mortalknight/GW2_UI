local _, GW = ...

local function LoadTimeManagerSkin()
    if not GW.GetSetting("TIMEMANAGER_SKIN_ENABLED") then return end
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

    TimeManagerFrame:StripTextures()
    TimeManagerFrame.tex = TimeManagerFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    local w, h = TimeManagerFrame:GetSize()
    TimeManagerFrame.tex:SetPoint("TOP", TimeManagerFrame, "TOP", 0, 20)
    TimeManagerFrame.tex:SetSize(w + 50, h + 20)
    TimeManagerFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    TimeManagerFrame.CloseButton:SkinButton(true)
    TimeManagerFrame.CloseButton:SetSize(20, 20)

    _G.TimeManagerAlarmHourDropDown:SkinDropDownMenu()
    _G.TimeManagerAlarmMinuteDropDown:SkinDropDownMenu()
    _G.TimeManagerAlarmAMPMDropDown:SkinDropDownMenu()

    _G.TimeManagerAlarmHourDropDown:SetWidth(80)
    _G.TimeManagerAlarmMinuteDropDown:SetWidth(80)
    _G.TimeManagerAlarmAMPMDropDown:SetWidth(80)

    GW.SkinTextBox(_G.TimeManagerAlarmMessageEditBox.Middle, _G.TimeManagerAlarmMessageEditBox.Left, _G.TimeManagerAlarmMessageEditBox.Right, nil, nil, 4, 4)
    _G.TimeManagerAlarmEnabledButton:SkinCheckButton()
    _G.TimeManagerMilitaryTimeCheck:SkinCheckButton()
    _G.TimeManagerLocalTimeCheck:SkinCheckButton()

    _G.TimeManagerAlarmEnabledButton:SetSize(16, 16)
    _G.TimeManagerMilitaryTimeCheck:SetSize(16, 16)
    _G.TimeManagerLocalTimeCheck:SetSize(16, 16)

    local TimeManagerStopwatchCheck = _G.TimeManagerStopwatchCheck
    _G.TimeManagerStopwatchFrame:StripTextures()
    TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local hover = TimeManagerStopwatchCheck:CreateTexture()
    hover:SetColorTexture(1, 1, 1, 0.3)
    hover:SetPoint("TOPLEFT", TimeManagerStopwatchCheck, 2, -2)
    hover:SetPoint("BOTTOMRIGHT", TimeManagerStopwatchCheck, -2, 2)
    TimeManagerStopwatchCheck:SetHighlightTexture(hover)

    local StopwatchFrame = _G.StopwatchFrame
    StopwatchFrame:StripTextures()
    StopwatchFrame:CreateBackdrop(GW.skins.constBackdropFrame)

    _G.StopwatchTabFrame:StripTextures()
    _G.StopwatchCloseButton:SkinButton(true)
end
GW.LoadTimeManagerSkin = LoadTimeManagerSkin