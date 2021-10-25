local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder

local function LoadBlizzardOptionsSkin()
    if not GW.GetSetting("BLIZZARD_OPTIONS_SKIN_ENABLED") then return end

    --Interface and System Options
    local OptionsFrames = {InterfaceOptionsFrameCategories, InterfaceOptionsFramePanelContainer, InterfaceOptionsFrameAddOns, VideoOptionsFrameCategoryFrame, VideoOptionsFramePanelContainer, Display_, Graphics_, RaidGraphics_, AudioOptionsSoundPanelHardware, AudioOptionsSoundPanelVolume, AudioOptionsSoundPanelPlayback, AudioOptionsVoicePanelTalking, AudioOptionsVoicePanelListening, AudioOptionsVoicePanelBinding}
    local OptionsButtons = {GraphicsButton, RaidButton}

    local InterfaceOptions = {
        InterfaceOptionsFrame, 
        InterfaceOptionsControlsPanel,
        InterfaceOptionsColorblindPanel,
        InterfaceOptionsCombatPanel,
        InterfaceOptionsCombatPanelEnemyCastBars,
        InterfaceOptionsCombatTextPanel,
        InterfaceOptionsDisplayPanel,
        InterfaceOptionsObjectivesPanel,
        InterfaceOptionsSocialPanel,
        InterfaceOptionsActionBarsPanel,
        InterfaceOptionsNamesPanel,
        InterfaceOptionsNamesPanelFriendly,
        InterfaceOptionsNamesPanelEnemy,
        InterfaceOptionsNamesPanelUnitNameplates,
        InterfaceOptionsBattlenetPanel,
        InterfaceOptionsCameraPanel,
        InterfaceOptionsMousePanel,
        InterfaceOptionsHelpPanel,
        InterfaceOptionsAccessibilityPanel,
        CompactUnitFrameProfiles,
        CompactUnitFrameProfilesGeneralOptionsFrame,
        VideoOptionsFrame,
        Display_,
        Graphics_,
        RaidGraphics_,
        Advanced_,
        NetworkOptionsPanel,
        InterfaceOptionsLanguagesPanel,
        MacKeyboardOptionsPanel,
        AudioOptionsSoundPanel,
        AudioOptionsSoundPanelHardware,
        AudioOptionsSoundPanelVolume,
        AudioOptionsSoundPanelPlayback,
        AudioOptionsVoicePanel,
        AudioOptionsVoicePanelTalking,
        AudioOptionsVoicePanelListening,
        AudioOptionsVoicePanelBinding,
        AudioOptionsVoicePanelMicTest,
        AudioOptionsVoicePanelChatMode1,
        AudioOptionsVoicePanelChatMode2,
        }

    RolePollPopup:StripTextures()
    RolePollPopup:CreateBackdrop(GW.skins.constBackdropFrame)
    RolePollPopupCloseButton:SkinButton(true)


    local InterfaceOptionsFrame = _G.InterfaceOptionsFrame
    InterfaceOptionsFrame.Header:StripTextures()
    InterfaceOptionsFrame.Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    InterfaceOptionsFrame:SetClampedToScreen(true)
    InterfaceOptionsFrame:SetMovable(true)
    InterfaceOptionsFrame:EnableMouse(true)
    InterfaceOptionsFrame:RegisterForDrag("LeftButton", "RightButton")
    InterfaceOptionsFrame:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then return end
        self:StartMoving()
        self.isMoving = true
    end)
    InterfaceOptionsFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
    end)

    local VideoOptionsFrame = _G.VideoOptionsFrame
    VideoOptionsFrame.Header:StripTextures()
    VideoOptionsFrame.Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    VideoOptionsFrame:SetClampedToScreen(true)
    VideoOptionsFrame:SetMovable(true)
    VideoOptionsFrame:EnableMouse(true)
    VideoOptionsFrame:RegisterForDrag("LeftButton", "RightButton")
    VideoOptionsFrame:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then return end
        self:StartMoving()
        self.isMoving = true
    end)
    VideoOptionsFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
    end)

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
        Frame:StripTextures()
        Frame:CreateBackdrop(constBackdropFrameBorder)
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
            _G[newProfileDialog.editBox:GetName() .. "Mid"]:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg")
            _G[newProfileDialog.editBox:GetName() .. "Mid"]:ClearAllPoints()
            _G[newProfileDialog.editBox:GetName() .. "Mid"]:SetPoint("TOPLEFT", _G[newProfileDialog.editBox:GetName() .. "Left"], "BOTTOMRIGHT", -25, 3)
            _G[newProfileDialog.editBox:GetName() .. "Mid"]:SetPoint("BOTTOMRIGHT", _G[newProfileDialog.editBox:GetName() .. "Right"], "TOPLEFT", 25, -3)
        end
    end

    --Delete Raid Profile
    if CompactUnitFrameProfilesDeleteProfileDialog then
        local tex = CompactUnitFrameProfilesDeleteProfileDialog:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", deletePrCompactUnitFrameProfilesDeleteProfileDialogofileDialog, "TOP", 0, 0)
        tex:SetSize(CompactUnitFrameProfilesDeleteProfileDialog:GetSize())
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
        CompactUnitFrameProfilesDeleteProfileDialog.tex = tex

        CompactUnitFrameProfilesDeleteProfileDialog.Border:Hide()

        _G.CompactUnitFrameProfilesDeleteProfileDialogDeleteButton:SkinButton(false, true)
        _G.CompactUnitFrameProfilesDeleteProfileDialogCancelButton:SkinButton(false, true)
    end

    --What's New
    local SplashFrame = _G.SplashFrame
    SplashFrame.BottomCloseButton:SkinButton(false, true)
    SplashFrame.BottomCloseButton:SetFrameLevel(SplashFrame.BottomCloseButton:GetFrameLevel() + 1)
    SplashFrame.TopCloseButton:SkinButton(true)

    -- Voice Sliders
    UnitPopupVoiceSpeakerVolume.Slider:SkinSliderFrame()
    UnitPopupVoiceMicrophoneVolume.Slider:SkinSliderFrame()
    UnitPopupVoiceUserVolume.Slider:SkinSliderFrame()

    -- Chat Settings
    local ChatFrames = {
        _G.ChatConfigFrame,
        _G.ChatConfigCombatSettingsFiltersScrollFrame,
        _G.CombatConfigColorsHighlighting,
        _G.CombatConfigColorsColorizeUnitName,
        _G.CombatConfigColorsColorizeSpellNames,
        _G.CombatConfigColorsColorizeDamageNumber,
        _G.CombatConfigColorsColorizeDamageSchool,
        _G.CombatConfigColorsColorizeEntireLine,
        _G.ChatConfigChatSettingsLeft,
        _G.ChatConfigOtherSettingsCombat,
        _G.ChatConfigOtherSettingsPVP,
        _G.ChatConfigOtherSettingsSystem,
        _G.ChatConfigOtherSettingsCreature,
        _G.ChatConfigChannelSettingsLeft,
        _G.CombatConfigMessageSourcesDoneBy,
        _G.CombatConfigColorsUnitColors,
        _G.CombatConfigMessageSourcesDoneTo,
    }

    local ChatFramesCat = {
        _G.ChatConfigCategoryFrame,
        _G.ChatConfigBackgroundFrame,
        _G.ChatConfigCombatSettingsFilters,
    }

    local ChatButtons = {
        _G.ChatConfigFrameDefaultButton,
        _G.ChatConfigFrameRedockButton,
        _G.ChatConfigFrame.ToggleChatButton,
        _G.ChatConfigFrameOkayButton,
        _G.ChatConfigCombatSettingsFiltersDeleteButton,
        _G.ChatConfigCombatSettingsFiltersAddFilterButton,
        _G.ChatConfigCombatSettingsFiltersCopyFilterButton,
        _G.CombatConfigSettingsSaveButton,
        _G.CombatLogDefaultButton,
    }

    local ChatCheckBoxs = {
        _G.CombatConfigColorsHighlightingLine,
        _G.CombatConfigColorsHighlightingAbility,
        _G.CombatConfigColorsHighlightingDamage,
        _G.CombatConfigColorsHighlightingSchool,
        _G.CombatConfigColorsColorizeUnitNameCheck,
        _G.CombatConfigColorsColorizeSpellNamesCheck,
        _G.CombatConfigColorsColorizeSpellNamesSchoolColoring,
        _G.CombatConfigColorsColorizeDamageNumberCheck,
        _G.CombatConfigColorsColorizeDamageNumberSchoolColoring,
        _G.CombatConfigColorsColorizeDamageSchoolCheck,
        _G.CombatConfigColorsColorizeEntireLineCheck,
        _G.CombatConfigFormattingShowTimeStamp,
        _G.CombatConfigFormattingShowBraces,
        _G.CombatConfigFormattingUnitNames,
        _G.CombatConfigFormattingSpellNames,
        _G.CombatConfigFormattingItemNames,
        _G.CombatConfigFormattingFullText,
        _G.CombatConfigSettingsShowQuickButton,
        _G.CombatConfigSettingsSolo,
        _G.CombatConfigSettingsParty,
        _G.CombatConfigSettingsRaid,
    }

    for _, frame in pairs(ChatFrames) do
        frame:StripTextures()
    end

    _G.ChatConfigFrame:SetClampedToScreen(true)
    _G.ChatConfigFrame:SetMovable(true)
    _G.ChatConfigFrame:EnableMouse(true)
    _G.ChatConfigFrame:RegisterForDrag("LeftButton", "RightButton")
    _G.ChatConfigFrame:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then return end
        self:StartMoving()
        self.isMoving = true
    end)
    _G.ChatConfigFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
    end)

    _G.ChatConfigFrame.Header:StripTextures()
    _G.ChatConfigFrame.Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    local tex = _G.ChatConfigFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", _G.ChatConfigFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = _G.ChatConfigFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    _G.ChatConfigFrame.tex = tex

    for _, frame in pairs(ChatFramesCat) do
        frame:StripTextures()
        frame:CreateBackdrop(constBackdropFrameBorder)
    end

    for _, checkBox in pairs(ChatCheckBoxs) do
        checkBox:SkinCheckButton()
        checkBox:SetSize(15, 15)
       _G[checkBox:GetName() .. "Text"]:ClearAllPoints()
       _G[checkBox:GetName() .. "Text"]:SetPoint("LEFT", "$parent", "LEFT", 20, 0)
    end

    for _, button in pairs(ChatButtons) do
        button:SkinButton(false, true)
    end

    for i in pairs(_G.COMBAT_CONFIG_TABS) do
        _G["CombatConfigTab" .. i]:SkinTab()
    end

    GW.SkinTextBox(_G.CombatConfigSettingsNameEditBox.Left, _G.CombatConfigSettingsNameEditBox.Middle, _G.CombatConfigSettingsNameEditBox.Right)

    _G.ChatConfigMoveFilterUpButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_up")
    _G.ChatConfigMoveFilterUpButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down")
    _G.ChatConfigMoveFilterUpButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down")
    _G.ChatConfigMoveFilterUpButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_up")

    _G.ChatConfigMoveFilterDownButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    _G.ChatConfigMoveFilterDownButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    _G.ChatConfigMoveFilterDownButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    _G.ChatConfigMoveFilterDownButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")

    hooksecurefunc("ChatConfig_UpdateCheckboxes", function(self)
        if not _G.FCF_GetCurrentChatFrame() then return end

        for index in ipairs(self.checkBoxTable) do
            local checkBoxNameString = self:GetName() .. "CheckBox"
            local checkBoxName = checkBoxNameString .. index
            local checkBox = _G[checkBoxName]
            local check = _G[checkBoxName .. "Check"]
            if checkBox and not checkBox.isSkinned then
                checkBox:StripTextures()
                check:SkinCheckButton()
                check:SetSize(15, 15)
                _G[checkBoxName .. "Check" .. "Text"]:ClearAllPoints()
                _G[checkBoxName .. "Check" .. "Text"]:SetPoint("LEFT", "$parent", "LEFT", 20, 0)
                if _G[checkBoxName .. "ColorClasses"] then
                    _G[checkBoxName .. "ColorClasses"]:SkinCheckButton()
                    _G[checkBoxName .. "ColorClasses"]:SetSize(15, 15)
                end
                checkBox.isSkinned = true
            end
        end
    end)

    hooksecurefunc("ChatConfig_UpdateTieredCheckboxes", function(self, index)
        local group = self.checkBoxTable[index]
        local checkBox = _G[self:GetName() .. "CheckBox" .. index]
        if checkBox then
            checkBox:SkinCheckButton()
            checkBox:SetSize(15, 15)
            _G[self:GetName() .. "CheckBox" .. index .. "Text"]:ClearAllPoints()
            _G[self:GetName() .. "CheckBox" .. index .. "Text"]:SetPoint("LEFT", "$parent", "LEFT", 20, 0)
        end
        if group.subTypes then
            for k in ipairs(group.subTypes) do
                _G[self:GetName() .. "CheckBox" .. index .. "_" .. k]:SkinCheckButton()
                _G[self:GetName() .. "CheckBox" .. index .. "_" .. k]:SetSize(15, 15)
                _G[self:GetName() .. "CheckBox" .. index .. "_" .. k .. "Text"]:ClearAllPoints()
                _G[self:GetName() .. "CheckBox" .. index .. "_" .. k .. "Text"]:SetPoint("LEFT", "$parent", "LEFT", 20, 0)
            end
        end
    end)

    hooksecurefunc("ChatConfig_UpdateSwatches", function(self)
        if not _G.FCF_GetCurrentChatFrame() then return end

        for index in ipairs(self.swatchTable) do
            _G[self:GetName() .. "Swatch" .. index]:StripTextures()
        end
    end)

    hooksecurefunc(_G.ChatConfigFrameChatTabManager, "UpdateWidth", function(self)
        for tab in self.tabPool:EnumerateActive() do
            if not tab.IsSkinned then
                tab:StripTextures()
                tab:SkinTab()

                tab.IsSkinned = true
            end
        end
    end)
end
GW.LoadBlizzardOptionsSkin = LoadBlizzardOptionsSkin