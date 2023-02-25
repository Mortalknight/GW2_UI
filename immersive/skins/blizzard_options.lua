local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder

local function SkinBlizzardOptions()
    if not GW.GetSetting("BLIZZARD_OPTIONS_SKIN_ENABLED") then return end
    --Interface and System Options
    local OptionsFrames = {_G.Display_, _G.Graphics_, _G.RaidGraphics_, _G.AudioOptionsSoundPanelHardware, _G.AudioOptionsSoundPanelVolume, _G.AudioOptionsSoundPanelPlayback, _G.AudioOptionsVoicePanelTalking, _G.AudioOptionsVoicePanelListening, _G.AudioOptionsVoicePanelBinding}
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

    for _, Frame in pairs(OptionsFrames) do
        Frame:StripTextures()
        Frame:CreateBackdrop(constBackdropFrameBorder)
    end

    InterfaceOptionsFrameCategories:StripTextures()
    InterfaceOptionsFramePanelContainer:StripTextures()
    InterfaceOptionsFrameAddOns:StripTextures()
    VideoOptionsFrameCategoryFrame:StripTextures()
    VideoOptionsFramePanelContainer:StripTextures()

    InterfaceOptionsFrameCategories:CreateBackdrop(constBackdropFrameBorder, true)
    InterfaceOptionsFramePanelContainer:CreateBackdrop(constBackdropFrameBorder, true)
    InterfaceOptionsFrameAddOns:CreateBackdrop(constBackdropFrameBorder, true)
    VideoOptionsFrameCategoryFrame:CreateBackdrop(constBackdropFrameBorder, true)
    VideoOptionsFramePanelContainer:CreateBackdrop(constBackdropFrameBorder, true)

    VideoOptionsFrame:SetBackdrop(nil)
    InterfaceOptionsFrame:SetBackdrop(nil)
    VideoOptionsFrameHeader:Hide()
    InterfaceOptionsFrameHeader:Hide()

    GW.CreateFrameHeaderWithBody(InterfaceOptionsFrame, InterfaceOptionsFrameHeaderText, "Interface/AddOns/GW2_UI/textures/character/settings-window-icon", {InterfaceOptionsFrameCategories, InterfaceOptionsFramePanelContainer, InterfaceOptionsFrameAddOns})

    InterfaceOptionsDisplayPanelResetTutorials:ClearAllPoints()
    InterfaceOptionsDisplayPanelResetTutorials:SetPoint("LEFT", _G.InterfaceOptionsDisplayPanelShowTutorials, "RIGHT", 150, 0)

    GW.CreateFrameHeaderWithBody(VideoOptionsFrame, VideoOptionsFrameHeaderText, "Interface/AddOns/GW2_UI/textures/character/settings-window-icon", {VideoOptionsFrameCategoryFrame, VideoOptionsFramePanelContainer})

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

    _G.AudioOptionsVoicePanel.TestInputDevice.ToggleTest.Texture:SetTexture()

    _G.AudioOptionsVoicePanel.TestInputDevice.ToggleTest:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_down")
    _G.AudioOptionsVoicePanel.TestInputDevice.ToggleTest:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_up")
    _G.AudioOptionsVoicePanel.TestInputDevice.ToggleTest:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_down")

    -- Voice Sliders
    UnitPopupVoiceSpeakerVolume.Slider:SkinSliderFrame()
    UnitPopupVoiceMicrophoneVolume.Slider:SkinSliderFrame()
    UnitPopupVoiceUserVolume.Slider:SkinSliderFrame()

    --Create New Raid Profle
    local newProfileDialog = _G.CompactUnitFrameProfilesNewProfileDialog
    if newProfileDialog then
        local tex = newProfileDialog:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", newProfileDialog, "TOP", 0, 0)
        tex:SetSize(newProfileDialog:GetSize())
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
        newProfileDialog.tex = tex

        newProfileDialog:SetBackdrop(nil)

        _G.CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector:SkinDropDownMenu()
        _G.CompactUnitFrameProfilesNewProfileDialogCreateButton:SkinButton(false, true)
        _G.CompactUnitFrameProfilesNewProfileDialogCancelButton:SkinButton(false, true)

        if newProfileDialog.editBox then
            _G[newProfileDialog.editBox:GetName() .. "Left"]:Hide()
            _G[newProfileDialog.editBox:GetName() .. "Right"]:Hide()
            _G[newProfileDialog.editBox:GetName() .. "Mid"]:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg")
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

        deleteProfileDialog:SetBackdrop(nil)

        _G.CompactUnitFrameProfilesDeleteProfileDialogDeleteButton:SkinButton(false, true)
        _G.CompactUnitFrameProfilesDeleteProfileDialogCancelButton:SkinButton(false, true)
    end
end
GW.SkinBlizzardOptions = SkinBlizzardOptions