local _, GW = ...

local function LoadTimeManagerSkin()
    if not GW.settings.TIMEMANAGER_SKIN_ENABLED then return end
    local TimeManagerFrame = _G.TimeManagerFrame

    local regions = {TimeManagerFrame:GetRegions()}
    for _,region in pairs(regions) do
        if region:IsObjectType("FontString") then
            if region:GetText() == TIMEMANAGER_TITLE then
                region:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
                break
            end
        end
    end

    TimeManagerFrame:GwStripTextures()
    TimeManagerFrame.tex = TimeManagerFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    local w, h = TimeManagerFrame:GetSize()
    TimeManagerFrame.tex:SetPoint("TOP", TimeManagerFrame, "TOP", 0, 20)
    TimeManagerFrame.tex:SetSize(w + 50, h + 20)
    TimeManagerFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    TimeManagerFrame.CloseButton:GwSkinButton(true)
    TimeManagerFrame.CloseButton:SetSize(20, 20)

    TimeManagerAlarmTimeFrame.HourDropdown:GwHandleDropDownBox()
    TimeManagerAlarmTimeFrame.MinuteDropdown:GwHandleDropDownBox()
    TimeManagerAlarmTimeFrame.AMPMDropdown:GwHandleDropDownBox()

    TimeManagerAlarmTimeFrame.HourDropdown:SetWidth(70)
    TimeManagerAlarmTimeFrame.MinuteDropdown:SetWidth(70)
    TimeManagerAlarmTimeFrame.AMPMDropdown:SetWidth(70)

    GW.SkinTextBox(_G.TimeManagerAlarmMessageEditBox.Middle, _G.TimeManagerAlarmMessageEditBox.Left, _G.TimeManagerAlarmMessageEditBox.Right, nil, nil, 4, 4)
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