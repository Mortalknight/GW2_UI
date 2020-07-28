local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder

local function SkinBlizzardOptions()
    --Interface and System Options
    local OptionsFrames = {_G.InterfaceOptionsFrameCategories, _G.InterfaceOptionsFramePanelContainer, _G.InterfaceOptionsFrameAddOns, _G.VideoOptionsFrameCategoryFrame, _G.VideoOptionsFramePanelContainer, _G.Display_, _G.Graphics_, _G.RaidGraphics_, _G.AudioOptionsSoundPanelHardware, _G.AudioOptionsSoundPanelVolume, _G.AudioOptionsSoundPanelPlayback, _G.AudioOptionsVoicePanelTalking, _G.AudioOptionsVoicePanelListening, _G.AudioOptionsVoicePanelBinding}
    local OptionsButtons = {_G.GraphicsButton, _G.RaidButton}

    local InterfaceOptions = {
        _G.InterfaceOptionsFrame, 
        _G.InterfaceOptionsControlsPanel,
        _G.InterfaceOptionsCombatPanel,
        _G.InterfaceOptionsCombatPanelEnemyCastBars,
        _G.InterfaceOptionsCombatTextPanel,
        _G.InterfaceOptionsDisplayPanel,
        _G.InterfaceOptionsObjectivesPanel,
        _G.InterfaceOptionsSocialPanel,
        _G.InterfaceOptionsActionBarsPanel,
        _G.InterfaceOptionsNamesPanel,
        _G.InterfaceOptionsNamesPanelFriendly,
        _G.InterfaceOptionsNamesPanelEnemy,
        _G.InterfaceOptionsNamesPanelUnitNameplates,
        _G.InterfaceOptionsBattlenetPanel,
        _G.InterfaceOptionsCameraPanel,
        _G.InterfaceOptionsMousePanel,
        _G.InterfaceOptionsHelpPanel,
        _G.InterfaceOptionsAccessibilityPanel,
        _G.CompactUnitFrameProfiles,
        _G.CompactUnitFrameProfilesGeneralOptionsFrame,
        _G.VideoOptionsFrame,
        _G.Display_,
        _G.Graphics_,
        _G.RaidGraphics_,
        _G.Advanced_,
        _G.NetworkOptionsPanel,
        _G.InterfaceOptionsLanguagesPanel,
        _G.MacKeyboardOptionsPanel,
        _G.AudioOptionsSoundPanel,
        _G.AudioOptionsSoundPanelHardware,
        _G.AudioOptionsSoundPanelVolume,
        _G.AudioOptionsSoundPanelPlayback,
        _G.AudioOptionsVoicePanel,
        _G.AudioOptionsVoicePanelTalking,
        _G.AudioOptionsVoicePanelListening,
        _G.AudioOptionsVoicePanelBinding,
        _G.AudioOptionsVoicePanelMicTest,
        _G.AudioOptionsVoicePanelChatMode1,
        _G.AudioOptionsVoicePanelChatMode2,
        }

    local InterfaceOptionsFrame = _G.InterfaceOptionsFrame
    InterfaceOptionsFrame.Header.CenterBG:Hide()
    InterfaceOptionsFrame.Header.RightBG:Hide()
    InterfaceOptionsFrame.Header.LeftBG:Hide()
    InterfaceOptionsFrame.Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    local VideoOptionsFrame = _G.VideoOptionsFrame
    VideoOptionsFrame.Header.CenterBG:Hide()
    VideoOptionsFrame.Header.RightBG:Hide()
    VideoOptionsFrame.Header.LeftBG:Hide()
    VideoOptionsFrame.Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    InterfaceOptionsFrame.Border:Hide()
    local tex = InterfaceOptionsFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", InterfaceOptionsFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = InterfaceOptionsFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    InterfaceOptionsFrame.tex = tex

    VideoOptionsFrame.Border:Hide()
    local tex = VideoOptionsFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", VideoOptionsFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = VideoOptionsFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    VideoOptionsFrame.tex = tex

    for _, Frame in pairs(OptionsFrames) do
        Frame:SetBackdrop(constBackdropFrameBorder)
    end

    for _, Tab in pairs(OptionsButtons) do
        Tab:SkinTab()
    end

    for _, Panel in pairs(InterfaceOptions) do
        if Panel then
            for i = 1, Panel:GetNumChildren() do
                local Child = select(i, Panel:GetChildren())
                if Child:IsObjectType("CheckButton") then
                    Child:SkinCheckButton()
                    Child:SetSize(15, 15)
                elseif Child:IsObjectType("Button") then
                    if Child == InterfaceOptionsFrameTab1 or Child == InterfaceOptionsFrameTab2 then
                        Child:SkinTab()
                    else
                        Child:SkinButton(false, true)
                    end
                elseif Child:IsObjectType("Slider") then
                    Child:SkinSliderFrame()
                elseif Child:IsObjectType("Tab") then
                    Child:SkinTab()
                elseif Child:IsObjectType("Frame") and Child.Left and Child.Middle and Child.Right then
                    Child:SkinDropDownMenu()
                end
            end
        end
    end

    --Create New Raid Profle
    local newProfileDialog = _G.CompactUnitFrameProfilesNewProfileDialog
    if newProfileDialog then
        local tex = newProfileDialog:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", newProfileDialog, "TOP", 0, 0)
        tex:SetSize(newProfileDialog:GetSize())
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
        newProfileDialog.tex = tex

        newProfileDialog.Border:Hide()

        _G.CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector:SkinDropDownMenu()
        _G.CompactUnitFrameProfilesNewProfileDialogCreateButton:SkinButton(false, true)
        _G.CompactUnitFrameProfilesNewProfileDialogCancelButton:SkinButton(false, true)

        if newProfileDialog.editBox then
            _G[newProfileDialog.editBox:GetName() .. "Left"]:Hide()
            _G[newProfileDialog.editBox:GetName() .. "Right"]:Hide()
            _G[newProfileDialog.editBox:GetName() .. "Mid"]:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")
            _G[newProfileDialog.editBox:GetName() .. "Mid"]:ClearAllPoints()
            _G[newProfileDialog.editBox:GetName() .. "Mid"]:SetPoint("TOPLEFT", _G[newProfileDialog.editBox:GetName() .. "Left"], "BOTTOMRIGHT", -25, 3)
            _G[newProfileDialog.editBox:GetName() .. "Mid"]:SetPoint("BOTTOMRIGHT", _G[newProfileDialog.editBox:GetName() .. "Right"], "TOPLEFT", 25, -3)
        end
    end

    --Delete Raid Profile
    local deleteProfileDialog = _G.CompactUnitFrameProfilesDeleteProfileDialog
    if deleteProfileDialog then
        local tex = deleteProfileDialog:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", deleteProfileDialog, "TOP", 0, 0)
        tex:SetSize(deleteProfileDialog:GetSize())
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
        deleteProfileDialog.tex = tex

        deleteProfileDialog.Border:Hide()

        _G.CompactUnitFrameProfilesDeleteProfileDialogDeleteButton:SkinButton(false, true)
        _G.CompactUnitFrameProfilesDeleteProfileDialogCancelButton:SkinButton(false, true)
    end

    --What's New
    local SplashFrame = _G.SplashFrame
    SplashFrame.BottomCloseButton:SkinButton(false, true)
    SplashFrame.TopCloseButton:SkinButton(true)

    -- Voice Sliders
    _G.UnitPopupVoiceSpeakerVolume.Slider:SkinSliderFrame()
    _G.UnitPopupVoiceMicrophoneVolume.Slider:SkinSliderFrame()
    _G.UnitPopupVoiceUserVolume.Slider:SkinSliderFrame()
end
GW.SkinBlizzardOptions = SkinBlizzardOptions