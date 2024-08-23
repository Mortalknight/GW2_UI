local _, GW = ...

local LFGRoleEnumToString = {
	[Enum.LFGRole.Tank] = "TANK",
	[Enum.LFGRole.Healer] = "HEALER",
	[Enum.LFGRole.Damage] = "DAMAGER",
};

local function SkinAddonButtons()
    if PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_LinkToChatButton then
        PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_LinkToChatButton:GwSkinButton(false, true)
        PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_LinkToChatButton:ClearAllPoints()
        PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_LinkToChatButton:SetPoint("BOTTOMLEFT", 55, 5)
    end

    if PlayerSpellsFrame.TalentTreeViewer_OpenViewerButton then
        PlayerSpellsFrame.TalentTreeViewer_OpenViewerButton:GwSkinButton(false, true)
    end

    if PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_RespecButtonContainer then
        for i = 1, GetNumSpecializations() do
            if PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_RespecButtonContainer["RespecButton" .. i] then
                PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_RespecButtonContainer["RespecButton" .. i]:GetNormalTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)
            end
        end
    end
    if PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_TransparencySlider then
        PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_TransparencySlider.Slider:GwSkinSliderFrame()
        PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_TransparencySlider.Back:Hide()
        PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_TransparencySlider.Forward:Hide()
        PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_TransparencySlider.LeftText:SetTextColor(1, 1, 1)
        PlayerSpellsFrame.TalentsFrame.TalentTreeTweaks_TransparencySlider.RightText:SetTextColor(1, 1, 1)
    end

    if PlayerSpellsFrame.SpellBookFrame.TalentTreeTweaks_TransparencySlider then
        PlayerSpellsFrame.SpellBookFrame.TalentTreeTweaks_TransparencySlider.Slider:GwSkinSliderFrame()
        PlayerSpellsFrame.SpellBookFrame.TalentTreeTweaks_TransparencySlider.Back:Hide()
        PlayerSpellsFrame.SpellBookFrame.TalentTreeTweaks_TransparencySlider.Forward:Hide()
        PlayerSpellsFrame.SpellBookFrame.TalentTreeTweaks_TransparencySlider.LeftText:SetTextColor(1, 1, 1)
        PlayerSpellsFrame.SpellBookFrame.TalentTreeTweaks_TransparencySlider.RightText:SetTextColor(1, 1, 1)
    end
end

local function HandleTalentFrameDialog(dialog)
    if not dialog then return end

    dialog:GwStripTextures()
    dialog:GwCreateBackdrop(GW.BackdropTemplates.Default)

    if dialog.AcceptButton then dialog.AcceptButton:GwSkinButton(false, true) end
    if dialog.CancelButton then dialog.CancelButton:GwSkinButton(false, true) end
    if dialog.DeleteButton then dialog.DeleteButton:GwSkinButton(false, true) end

    GW.SkinTextBox(dialog.NameControl.EditBox.Middle, dialog.NameControl.EditBox.Left, dialog.NameControl.EditBox.Right, nil, nil, 5, 5)
    dialog.NameControl.EditBox:ClearAllPoints()
    dialog.NameControl.EditBox:SetPoint("TOPLEFT", dialog.NameControl.Label, "BOTTOMLEFT", 0, -10)
    dialog.NameControl.EditBox:SetHeight(25)

    dialog.NameControl.Label:SetTextColor(1, 1, 1)
end

local function UpdateSpecFrame(frame)
    if not frame.SpecContentFramePool then return end

    for specContentFrame in frame.SpecContentFramePool:EnumerateActive() do
        if not specContentFrame.IsSkinned then
            specContentFrame.ActivateButton:GwSkinButton(false, true)

            local role = LFGRoleEnumToString[GetSpecializationRoleEnum(specContentFrame.specIndex, false, false)]
            specContentFrame.Description:SetTextColor(1, 1, 1)
            specContentFrame.RoleName:SetTextColor(1, 1, 1)
            specContentFrame.RoleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/character/statsicon")

            --SpecName
            specContentFrame.SpecName:SetTextColor(255 / 255, 241 / 255, 209 / 255)
            specContentFrame.SampleAbilityText:SetFont(UNIT_NAME_FONT, 16)
            specContentFrame.SampleAbilityText:SetTextColor(255 / 255, 241 / 255, 209 / 255)

            if role == "DAMAGER" then
                specContentFrame.RoleIcon:SetTexCoord(0.75, 1, 0.75, 1)
            elseif role == "TANK" then
                specContentFrame.RoleIcon:SetTexCoord(0.75, 1, 0.5, 0.75)
            elseif role == "HEALER" then
                specContentFrame.RoleIcon:SetTexCoord(0.25, 0.5, 0.75, 1)
            end

            specContentFrame.SpecImageBorderOff:SetAlpha(0)
            specContentFrame.SpecImageBorderOn:SetAlpha(0)
            specContentFrame.SpecImage:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)

            if specContentFrame.SpellButtonPool then
                for button in specContentFrame.SpellButtonPool:EnumerateActive() do
                    if button.Ring then
                        button.Ring:Hide()
                    end

                    if button.spellID then
                        local texture = C_Spell.GetSpellTexture(button.spellID)
                        if texture then
                            button.Icon:SetTexture(texture)
                        end
                    end

                    GW.HandleIcon(button.Icon, true, GW.BackdropTemplates.DefaultWithColorableBorder, true)
                end
            end

            specContentFrame.IsSkinned = true
        end

        if specContentFrame.isInGlowState then
            specContentFrame.SpecImage.backdrop:SetBackdropBorderColor(247/255, 203/255, 96/255)
        else
            specContentFrame.SpecImage.backdrop:SetBackdropBorderColor(1, 1, 1)
        end
    end

    PlayerSpellsFrame.SpecFrame.BlackBG:SetAlpha(0)
    PlayerSpellsFrame.SpecFrame.Background:SetAlpha(0)
end

local function HandleHeroTalents(frame)
    if not frame then return end

    for specFrame in frame.SpecContentFramePool:EnumerateActive() do
        if specFrame and not specFrame.IsSkinned then
            if specFrame.SpecName then
                specFrame.SpecName:SetFont(UNIT_NAME_FONT, 18)
                specFrame.SpecName:SetTextColor(255 / 255, 241 / 255, 209 / 255)
                end
            if specFrame.Description then
                specFrame.Description:SetFont(UNIT_NAME_FONT, 14)
                specFrame.Description:SetTextColor(1, 1, 1)
                end

            if specFrame.CurrencyFrame then
                specFrame.CurrencyFrame.LabelText:SetFont(UNIT_NAME_FONT, 12)
                specFrame.CurrencyFrame.AmountText:SetFont(UNIT_NAME_FONT, 18)
            end
            specFrame.ActivateButton:GwSkinButton(false, true)
            specFrame.ApplyChangesButton:GwSkinButton(false, true)

            specFrame.IsSkinned = true
        end
    end
end

local function skinPlayerSpells()
    GW.HandlePortraitFrame(PlayerSpellsFrame)
    GW.CreateFrameHeaderWithBody(PlayerSpellsFrame, PlayerSpellsFrameTitleText, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon", {PlayerSpellsFrame.SpecFrame, PlayerSpellsFrame.TalentsFrame}, -3)

    -- Specialisation
    hooksecurefunc(PlayerSpellsFrame.SpecFrame, "UpdateSpecFrame", UpdateSpecFrame)


    -- TalentsFrame
    local TalentsFrame = PlayerSpellsFrame.TalentsFrame
    TalentsFrame.BlackBG:SetAlpha(0)
    TalentsFrame.BottomBar:SetAlpha(0)

    TalentsFrame.ApplyButton:GwSkinButton(false, true)
    TalentsFrame.LoadSystem.Dropdown:GwHandleDropDownBox()

    TalentsFrame.InspectCopyButton:GwSkinButton(false, true)

    TalentsFrame.ClassCurrencyDisplay.CurrencyLabel:SetFont(UNIT_NAME_FONT, 18)
    TalentsFrame.ClassCurrencyDisplay.CurrencyAmount:SetFont(UNIT_NAME_FONT, 26)

    TalentsFrame.ClassCurrencyDisplay.CurrencyLabel:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    TalentsFrame.SpecCurrencyDisplay.CurrencyLabel:SetFont(UNIT_NAME_FONT, 18)
    TalentsFrame.SpecCurrencyDisplay.CurrencyAmount:SetFont(UNIT_NAME_FONT, 26)

    TalentsFrame.SpecCurrencyDisplay.CurrencyLabel:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    GW.SkinTextBox(TalentsFrame.SearchBox.Middle, TalentsFrame.SearchBox.Left, TalentsFrame.SearchBox.Right)
    TalentsFrame.SearchBox:SetHeight(20)
    TalentsFrame.SearchPreviewContainer:GwStripTextures()
    TalentsFrame.SearchPreviewContainer:GwCreateBackdrop(GW.BackdropTemplates.Default, true)

    TalentsFrame.PvPTalentList:GwStripTextures()
    TalentsFrame.PvPTalentList:GwCreateBackdrop()
    TalentsFrame.PvPTalentList.backdrop:SetFrameStrata(PlayerSpellsFrame.TalentsFrame.PvPTalentList:GetFrameStrata())
    TalentsFrame.PvPTalentList.backdrop:SetFrameLevel(2000)

    for _, tab in next, { PlayerSpellsFrame.TabSystem:GetChildren() } do
        GW.HandleTabs(tab)
    end

    PlayerSpellsFrame.TabSystem:ClearAllPoints()
    PlayerSpellsFrame.TabSystem:SetPoint("TOPLEFT", PlayerSpellsFrame, "BOTTOMLEFT", 0, 0)

    if ClassTalentLoadoutImportDialog then
        HandleTalentFrameDialog(ClassTalentLoadoutImportDialog)
        ClassTalentLoadoutImportDialog.ImportControl.Label:SetTextColor(1, 1, 1)
        ClassTalentLoadoutImportDialog.ImportControl.InputContainer:GwStripTextures()
        GW.SkinTextBox(ClassTalentLoadoutImportDialog.ImportControl.InputContainer.MiddleTex, ClassTalentLoadoutImportDialog.ImportControl.InputContainer.LeftTex, ClassTalentLoadoutImportDialog.ImportControl.InputContainer.RightTex, nil, nil, 5, 5)
    end

    if ClassTalentLoadoutCreateDialog then
        HandleTalentFrameDialog(ClassTalentLoadoutCreateDialog)
    end

    if ClassTalentLoadoutEditDialog then
        HandleTalentFrameDialog(ClassTalentLoadoutEditDialog)

        local editbox = ClassTalentLoadoutEditDialog.LoadoutName
        if editbox then
            GW.SkinTextBox(editbox.Middle, editbox.Left, editbox.Right)
            editbox:SetHeight(20)
        end

        local check = ClassTalentLoadoutEditDialog.UsesSharedActionBars
        if check then
            check.CheckButton:GwSkinCheckButton()
            check.CheckButton:SetSize(20, 20)
            check.Label:SetTextColor(1, 1, 1)
        end
    end

    -- Addon buttons
    C_Timer.After(0, SkinAddonButtons)

    -- Hero Talents
    local HeroTalentContainer = TalentsFrame.HeroTalentsContainer
    HeroTalentContainer.HeroSpecLabel:SetFont(UNIT_NAME_FONT, 16)

    local TalentsSelect = HeroTalentsSelectionDialog
    if TalentsSelect then
        TalentsSelect:GwStripTextures()
        TalentsSelect:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        TalentsSelect.CloseButton:GwSkinButton(true)

        hooksecurefunc(TalentsSelect, "ShowDialog", HandleHeroTalents)
    end

    -- SpellBook
    local SpellBookFrame = PlayerSpellsFrame.SpellBookFrame
    if SpellBookFrame then
        SpellBookFrame.TopBar:Hide()
        SpellBookFrame.BookCornerFlipbook:Hide()
        PlayerSpellsFrame.MaxMinButtonFrame:GwHandleMaxMinFrame()
        GW.SkinTextBox(SpellBookFrame.SearchBox.Middle, SpellBookFrame.SearchBox.Left, SpellBookFrame.SearchBox.Right)
        SpellBookFrame.SearchBox:SetHeight(20)
        SpellBookFrame.HidePassivesCheckButton.Button:GwSkinCheckButton()
        SpellBookFrame.HidePassivesCheckButton.Button:SetSize(20, 20)
        SpellBookFrame.HidePassivesCheckButton.Label:SetTextColor(1, 1, 1)

        SpellBookFrame.HelpPlateButton:GwKill()

        for _, tab in next, { SpellBookFrame.CategoryTabSystem:GetChildren() } do
            GW.HandleTabs(tab, true)
        end

        local PagedSpellsFrame = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame
        PagedSpellsFrame.View1:DisableDrawLayer("OVERLAY")

        local PagingControls = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame.PagingControls
        GW.HandleNextPrevButton(PagingControls.PrevPageButton, nil, nil, true)
        GW.HandleNextPrevButton(PagingControls.NextPageButton, nil, nil, true)
        PagingControls.PageText:SetTextColor(1, 1, 1)
    end
end

local function LoadPlayerSpellsSkin()
    if not GW.settings.PLAYER_SPELLS_SKIN_ENABLED then return end

    GW.RegisterLoadHook(skinPlayerSpells, "Blizzard_PlayerSpells", PlayerSpellsFrame)
end
GW.LoadPlayerSpellsSkin = LoadPlayerSpellsSkin
