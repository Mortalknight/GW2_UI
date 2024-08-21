local _, GW = ...

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

                    GW.HandleIcon(button.Icon, true)
                end
            end

            specContentFrame.IsSkinned = true
        end
    end
end

local function HandleHeroTalents(frame)
    if not frame then return end

    for specFrame in frame.SpecContentFramePool:EnumerateActive() do
        if specFrame and not specFrame.IsSkinned then
            if specFrame.SpecName then specFrame.SpecName:SetFont(UNIT_NAME_FONT, 18) end
            if specFrame.Description then specFrame.Description:SetFont(UNIT_NAME_FONT, 14) end
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
    GW.CreateFrameHeaderWithBody(PlayerSpellsFrame, PlayerSpellsFrameTitleText, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon", {PlayerSpellsFrame})


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

    TalentsFrame.SpecCurrencyDisplay.CurrencyLabel:SetFont(UNIT_NAME_FONT, 18)
    TalentsFrame.SpecCurrencyDisplay.CurrencyAmount:SetFont(UNIT_NAME_FONT, 26)

    GW.SkinTextBox(TalentsFrame.SearchBox.Middle, TalentsFrame.SearchBox.Left, TalentsFrame.SearchBox.Right)
    TalentsFrame.SearchBox:SetHeight(20)
    TalentsFrame.SearchPreviewContainer:GwStripTextures()
    TalentsFrame.SearchPreviewContainer:GwCreateBackdrop(GW.BackdropTemplates.Default, true)

    TalentsFrame.PvPTalentList:GwStripTextures()
    TalentsFrame.PvPTalentList:GwCreateBackdrop()
    TalentsFrame.PvPTalentList.backdrop:SetFrameStrata(PlayerSpellsFrame.TalentsFrame.PvPTalentList:GetFrameStrata())
    TalentsFrame.PvPTalentList.backdrop:SetFrameLevel(2000)

    for _, tab in next, { PlayerSpellsFrame.TabSystem:GetChildren() } do
        GW.HandleTabs(tab, true)
        tab:HookScript("OnClick", function(self)
            for _, t in next, { PlayerSpellsFrame.TabSystem:GetChildren() } do
                if t ~= self then
                    t.hover:SetAlpha(0)
                end
            end
        end)
    end

    PlayerSpellsFrame.TabSystem:ClearAllPoints()
    PlayerSpellsFrame.TabSystem:SetPoint("TOPLEFT", PlayerSpellsFrame, "BOTTOMLEFT", -3, 0)

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

        SpellBookFrame.HelpPlateButton:GwKill()

        for _, tab in next, { SpellBookFrame.CategoryTabSystem:GetChildren() } do
            GW.HandleTabs(tab, true)
            tab:HookScript("OnClick", function(self)
                for _, t in next, { SpellBookFrame.CategoryTabSystem:GetChildren() } do
                    if t ~= self then
                        t.hover:SetAlpha(0)
                    end
                end
            end)
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
