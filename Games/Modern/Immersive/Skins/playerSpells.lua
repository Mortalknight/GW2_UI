---@class GW2
local GW = select(2, ...)

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

    if ClassTalentLoadoutImportDialog and ClassTalentLoadoutImportDialog.TalentTreeTweaks_ImportIntoCurrentCheckbox then
        ClassTalentLoadoutImportDialog.TalentTreeTweaks_ImportIntoCurrentCheckbox:GwSkinCheckButton(false, 13)
        ClassTalentLoadoutImportDialog.TalentTreeTweaks_ImportIntoCurrentCheckbox.text:SetTextColor(1, 1, 1)
    end
end

local function HandleTalentFrameDialog(dialog)
    if not dialog then return end

    dialog:GwStripTextures()
    dialog:GwCreateBackdrop(GW.BackdropTemplates.Default)

    if dialog.AcceptButton then dialog.AcceptButton:GwSkinButton(false, true) end
    if dialog.CancelButton then dialog.CancelButton:GwSkinButton(false, true) end
    if dialog.DeleteButton then
        dialog.DeleteButton:GwSkinButton(false, true)
        dialog.DeleteButton:GwSkinNegativeButton()
    end

    GW.SkinTextBox(dialog.NameControl.EditBox.Middle, dialog.NameControl.EditBox.Left, dialog.NameControl.EditBox.Right, nil, nil, 5, 5)
    dialog.NameControl.EditBox:ClearAllPoints()
    dialog.NameControl.EditBox:SetPoint("TOPLEFT", dialog.NameControl.Label, "BOTTOMLEFT", 0, -10)
    dialog.NameControl.EditBox:SetHeight(25)

    dialog.NameControl.Label:SetTextColor(1, 1, 1)
end

local function UpdateSpecFrame(frame)
    if not frame.SpecContentFramePool then return end

    for specContentFrame in frame.SpecContentFramePool:EnumerateActive() do
        if not specContentFrame.gwSkinned then
            specContentFrame.ActivateButton:GwSkinButton(false, true)

            local role = LFGRoleEnumToString[GetSpecializationRoleEnum(specContentFrame.specIndex, false, false)]
            specContentFrame.Description:SetTextColor(1, 1, 1)
            specContentFrame.RoleName:SetTextColor(1, 1, 1)
            specContentFrame.RoleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/character/statsicon.png")

            --SpecName
            specContentFrame.SpecName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
            specContentFrame.SampleAbilityText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
            specContentFrame.SampleAbilityText:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

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

                    if button.CircleMask then
                        button.CircleMask:Hide()
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

            specContentFrame.gwSkinned = true
        end

        if specContentFrame.isInGlowState then
            specContentFrame.SpecImage.backdrop:SetBackdropBorderColor(247/255, 203/255, 96/255)
        else
            specContentFrame.SpecImage.backdrop:SetBackdropBorderColor(1, 1, 1)
        end
    end

    if PlayerSpellsFrame.SpecFrame.BlackBG then
        PlayerSpellsFrame.SpecFrame.BlackBG:SetAlpha(0)
        PlayerSpellsFrame.SpecFrame.Background:SetAlpha(0)
    end
end

local function HandleHeroTalents(frame)
    if not frame then return end

    for specFrame in frame.SpecContentFramePool:EnumerateActive() do
        if specFrame and not specFrame.gwSkinned then
            if specFrame.SpecName then
                specFrame.SpecName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader)
                specFrame.SpecName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
                end
            if specFrame.Description then
                specFrame.Description:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
                specFrame.Description:SetTextColor(1, 1, 1)
                end

            if specFrame.CurrencyFrame then
                specFrame.CurrencyFrame.LabelText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
                specFrame.CurrencyFrame.AmountText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader)
            end
            specFrame.ActivateButton:GwSkinButton(false, true)
            specFrame.ApplyChangesButton:GwSkinButton(false, true)

            specFrame.gwSkinned = true
        end
    end
end

local TAB_ART_KEYS = {
    "Left", "Middle", "Right", "LeftActive", "MiddleActive", "RightActive",
    "LeftHighlight", "MiddleHighlight", "RightHighlight",
    "SquareBackground", "SquareBackgroundActive", "SquareBackgroundActiveGlow",
}
local function HideTabArt(tab)
    for _, key in ipairs(TAB_ART_KEYS) do
        if tab[key] then
            tab[key]:SetAlpha(0)
        end
    end
end

local function RestoreTabIcon(tab)
    if tab.tabIcon and tab.Icon then
        tab.Icon:SetTexture(tab.tabIcon)
        tab.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        tab.Icon:ClearAllPoints()
        tab.Icon:SetPoint("CENTER", tab, "CENTER", 0, 0)
        tab.Icon:SetSize(28, 28)
        tab.Icon:Show()
        -- an empty mask hides everything it masks
        if tab.IconMask then
            tab.IconMask:SetAtlas("SquareMask")
            tab.IconMask:Show()
        end
    end
end

local function SkinTabSystemButton(tab, direction)
    if tab.gwSkinned then return end
    GW.HandleTabs(tab, direction)
    HideTabArt(tab)
    RestoreTabIcon(tab)
    if tab.SetTabSelected then
        hooksecurefunc(tab, "SetTabSelected", HideTabArt)
    end
    if tab.Init then
        hooksecurefunc(tab, "Init", RestoreTabIcon)
    end
end

local function SkinTabSystem(tabSystem, direction)
    if not tabSystem or tabSystem.gwSkinned then return end
    tabSystem.gwSkinned = true
    for _, tab in next, { tabSystem:GetChildren() } do
        SkinTabSystemButton(tab, direction)
    end
    if tabSystem.AddTab then
        hooksecurefunc(tabSystem, "AddTab", function(self)
            for _, tab in next, { self:GetChildren() } do
                SkinTabSystemButton(tab, direction)
            end
        end)
    end
end


local function HidePortrait()
    if PlayerSpellsFrame.PortraitContainer then
        PlayerSpellsFrame.PortraitContainer:SetAlpha(0)
    end
    local portrait = PlayerSpellsFrame.GetPortrait and PlayerSpellsFrame:GetPortrait()
    if portrait then
        portrait:SetAlpha(0)
    end
    if PlayerSpellsFramePortrait then
        PlayerSpellsFramePortrait:SetAlpha(0)
    end
end

local TALENT_ART_KEYS = {
    "Background", "BackgroundBorder",
    "DividerHorizontalLeft", "DividerHorizontalRight", "DividerVerticalLeft", "DividerVerticalRight",
}
local function HideTalentArt(TalentsFrame)
    if not TalentsFrame.BackgroundBorder then return end
    for _, key in ipairs(TALENT_ART_KEYS) do
        local region = TalentsFrame[key]
        if region and region.SetAlpha then
            region:SetAlpha(0)
        end
    end
end

-- blizzard re-anchors these controls on its own layout passes
local function PinPoint(frame, ...)
    local anchor = {...}
    frame.gwPinned = true
    frame:ClearAllPoints()
    frame:SetPoint(unpack(anchor))
    if not frame.gwPinHooked then
        frame.gwPinHooked = true
        hooksecurefunc(frame, "SetPoint", function(self)
            if self.gwPinning then return end
            self.gwPinning = true
            self:ClearAllPoints()
            self:SetPoint(unpack(anchor))
            self.gwPinning = nil
        end)
    end
end

local function SkinLegacyTalentTree(TalentsFrame)
    local art = TalentsFrame.ClassBackground
    if not art then return end

    local function SkinNodes()
        for button in TalentsFrame:EnumerateAllTalentButtons() do
            GW.SkinTalentButton(button)
        end
    end

    local function SkinTreeHeader(header)
        if header.gwSkinned then return end
        header.gwSkinned = true

        header.MainRing:SetAlpha(0)

        local pointsBox, pointsText = header.TextBackground, header.Text
        for _, region in ipairs({header:GetRegions()}) do
            local objectType = region:GetObjectType()
            if objectType == "MaskTexture" then
                header.Icon:RemoveMaskTexture(region)
            elseif objectType == "Texture" and region:GetAtlas() == "talents-main-ring-box-c60" then
                pointsBox = pointsBox or region
            elseif objectType == "FontString" and region ~= header.Name then
                pointsText = pointsText or region
            end
        end

        GW.HandleIcon(header.Icon, true, GW.BackdropTemplates.DefaultWithColorableBorder, true)
        header.Icon.backdrop:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)

        header.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        header.Name:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

        header.Divider:ClearAllPoints()
        header.Divider:SetPoint("BOTTOM", header, "BOTTOM", 60, -8)

        if pointsBox then
            pointsBox:SetAlpha(0)
        end

        -- blizzards box washes over the icon art, so the counter gets its own plate on top of it
        local badge = CreateFrame("Frame", nil, header)
        badge:SetFrameLevel(header:GetFrameLevel() + 2)
        badge:SetSize(24, 16)
        badge:SetPoint("CENTER", header.Icon, "BOTTOMRIGHT", -2, 1)
        badge.background = badge:CreateTexture(nil, "BACKGROUND")
        badge.background:SetAllPoints()
        badge.background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
        badge.background:SetVertexColor(0, 0, 0, 0.8)
        header.gwPointsBadge = badge

        pointsText:SetParent(badge)
        pointsText:ClearAllPoints()
        pointsText:SetPoint("CENTER", badge, "CENTER", 0, 0)
        pointsText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "THINOUTLINE")
    end

    local function SkinTreeHeaders()
        for _, header in ipairs(TalentsFrame.treeHeaders or {}) do
            SkinTreeHeader(header)
        end
    end
    hooksecurefunc(TalentsFrame, "RefreshTreeHeaders", SkinTreeHeaders)
    SkinTreeHeaders()
    TalentsFrame:RegisterCallback("TalentButtonAcquired", function(_, button)
        GW.SkinTalentButton(button)
    end, "GwPlayerSpellsSkin")
    TalentsFrame:HookScript("OnShow", function()
        SkinNodes()
        SkinTreeHeaders()
    end)
    SkinNodes()

    local panel = CreateFrame("Frame", nil, TalentsFrame)
    panel:SetFrameLevel(math.max(0, TalentsFrame:GetFrameLevel() - 1))
    panel:SetPoint("TOPLEFT", art, "TOPLEFT", 0, 0)
    panel:SetPoint("BOTTOMRIGHT", art, "BOTTOMRIGHT", 0, 0)
    GW.AddDetailsBackground(panel)
    TalentsFrame.gwTreePanel = panel

    local footer = CreateFrame("Frame", nil, TalentsFrame)
    footer:SetFrameLevel(TalentsFrame:GetFrameLevel() + 5)
    footer:SetHeight(70)
    footer:SetPoint("TOPLEFT", PlayerSpellsFrame, "BOTTOMLEFT", 0, 35)
    footer:SetPoint("TOPRIGHT", PlayerSpellsFrame, "BOTTOMRIGHT", 0, 35)
    footer.tex = footer:CreateTexture(nil, "BACKGROUND")
    footer.tex:SetAllPoints()
    footer.tex:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagfooter.png")
    TalentsFrame.gwFooter = footer

    local INSET = 12
    art:ClearAllPoints()
    art:SetPoint("TOPLEFT", TalentsFrame, "TOPLEFT", INSET, -70)
    art:SetPoint("BOTTOMRIGHT", TalentsFrame, "BOTTOMRIGHT", -INSET, 48)

    if TalentsFrame.SearchBox then
        PinPoint(TalentsFrame.SearchBox, "BOTTOMLEFT", PlayerSpellsFrame, "BOTTOMLEFT", 40, 5)
        TalentsFrame.SearchBox:SetWidth(220)
    end
    if TalentsFrame.SearchOptionsDropdown and TalentsFrame.SearchBox then
        PinPoint(TalentsFrame.SearchOptionsDropdown, "LEFT", TalentsFrame.SearchBox, "RIGHT", 6, 0)
    end
    if TalentsFrame.ApplyButton then
        PinPoint(TalentsFrame.ApplyButton, "BOTTOM", PlayerSpellsFrame, "BOTTOM", 0, 5)
        TalentsFrame.ApplyButton:SetFrameLevel(footer:GetFrameLevel() + 1)
    end
    if TalentsFrame.LoadSystem then
        PinPoint(TalentsFrame.LoadSystem, "BOTTOMRIGHT", PlayerSpellsFrame, "BOTTOMRIGHT", -20, 5)
    end
    if TalentsFrame.ClassCurrencyDisplay then
        PinPoint(TalentsFrame.ClassCurrencyDisplay, "BOTTOMRIGHT", art, "TOPRIGHT", -10, 4)
    end

    -- blizzards frames catch the mouse above the scenery, so the columns are polled
    TalentsFrame.gwTreeColumns = {}
    local function GetColumn(index)
        local column = TalentsFrame.gwTreeColumns[index]
        if column then return column end
        column = CreateFrame("Frame", nil, TalentsFrame)
        column:SetFrameLevel(TalentsFrame:GetFrameLevel() + 1)
        column:EnableMouse(false)
        column.shade = column:CreateTexture(nil, "OVERLAY")
        column.shade:SetAllPoints()
        column.shade:SetColorTexture(0, 0, 0, 0.35)
        TalentsFrame.gwTreeColumns[index] = column
        return column
    end
    TalentsFrame:HookScript("OnUpdate", function(_, elapsed)
        for _, column in ipairs(TalentsFrame.gwTreeColumns) do
            if column:IsShown() then
                local target = column:IsMouseOver() and 0 or 1
                local alpha = column.shade:GetAlpha()
                if alpha ~= target then
                    local step = elapsed * 6
                    if alpha < target then
                        alpha = math.min(target, alpha + step)
                    else
                        alpha = math.max(target, alpha - step)
                    end
                    column.shade:SetAlpha(alpha)
                end
            end
        end
    end)
    local function LayoutColumns(frame)
        local count = frame.treeHeaders and #frame.treeHeaders or 0
        for index, column in ipairs(TalentsFrame.gwTreeColumns) do
            column:SetShown(index <= count)
        end
        if count == 0 then return end
        local width = (TalentsFrame:GetWidth() - 2 * INSET) / count
        for index = 1, count do
            local column = GetColumn(index)
            column:ClearAllPoints()
            column:SetPoint("TOP", art, "TOP", 0, 0)
            column:SetPoint("BOTTOM", art, "BOTTOM", 0, 0)
            column:SetPoint("LEFT", art, "LEFT", (index - 1) * width, 0)
            column:SetWidth(width)
            column:Show()
        end
    end
    if TalentsFrame.RefreshTreeHeaders then
        hooksecurefunc(TalentsFrame, "RefreshTreeHeaders", LayoutColumns)
    end
    LayoutColumns(TalentsFrame)
end

local function MakeMovable(frame)
    local mover = CreateFrame("Frame", nil, frame)
    mover:EnableMouse(true)
    mover:SetHeight(30)
    mover:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -20)
    mover:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -20)
    mover:RegisterForDrag("LeftButton")
    mover:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
    mover:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)

    frame:SetMovable(true)
    if InCombatLockdown() then
        GW.CombatQueue:Queue("PlayerSpellsClampedToScreen", function()
            frame:SetClampedToScreen(true)
        end)
    else
        frame:SetClampedToScreen(true)
    end

    frame.mover = mover
end

local HEADER_OVERLAP = 32

local function GrowForHeader()
    if not PlayerSpellsFrame:IsShown() then return end
    if InCombatLockdown() then
        GW.CombatQueue:Queue("gw_player_spells_height", GrowForHeader)
        return
    end

    local content = (PlayerSpellsFrame.SpellBookFrame and PlayerSpellsFrame.SpellBookFrame:IsShown() and PlayerSpellsFrame.SpellBookFrame)
        or (PlayerSpellsFrame.TalentsFrame and PlayerSpellsFrame.TalentsFrame:IsShown() and PlayerSpellsFrame.TalentsFrame)
        or (PlayerSpellsFrame.SpecFrame and PlayerSpellsFrame.SpecFrame:IsShown() and PlayerSpellsFrame.SpecFrame)
    if not content then return end

    local frameTop, contentTop = PlayerSpellsFrame:GetTop(), content:GetTop()
    if not frameTop or not contentTop then return end

    local missing = HEADER_OVERLAP - (frameTop - contentTop)
    if missing > 0.5 then
        PlayerSpellsFrame:SetHeight(PlayerSpellsFrame:GetHeight() + missing)
    end
end

local function skinPlayerSpells()
    GW.HandlePortraitFrame(PlayerSpellsFrame)
    GW.CreateFrameHeaderWithBody(PlayerSpellsFrame, PlayerSpellsFrameTitleText, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png", {PlayerSpellsFrame.SpecFrame, PlayerSpellsFrame.TalentsFrame}, -3, false, true)
    PlayerSpellsFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    HidePortrait()
    for _, method in ipairs({"UpdatePortrait", "SetPortraitShown", "SetPortraitToAsset", "SetPortraitToClassIcon", "SetPortraitToUnit"}) do
        if PlayerSpellsFrame[method] then
            hooksecurefunc(PlayerSpellsFrame, method, HidePortrait)
        end
    end
    if PlayerSpellsFrame.UpdateSize then
        hooksecurefunc(PlayerSpellsFrame, "UpdateSize", GrowForHeader)
    end
    PlayerSpellsFrame:HookScript("OnShow", GrowForHeader)

    local contentLevel = math.max(PlayerSpellsFrame.SpellBookFrame and PlayerSpellsFrame.SpellBookFrame:GetFrameLevel() or 0, PlayerSpellsFrame.TalentsFrame:GetFrameLevel())
    PlayerSpellsFrame.gwHeader:SetFrameLevel(contentLevel + 10)
    if PlayerSpellsFrame.CloseButton then
        PlayerSpellsFrame.CloseButton:SetFrameLevel(contentLevel + 11)
    end
    MakeMovable(PlayerSpellsFrame)
    PlayerSpellsFrame.mover:SetFrameLevel(contentLevel + 11)
    if PlayerSpellsFrame.SpecFrame.UpdateSpecFrame then
        hooksecurefunc(PlayerSpellsFrame.SpecFrame, "UpdateSpecFrame", UpdateSpecFrame)
    end

    local TalentsFrame = PlayerSpellsFrame.TalentsFrame
    if TalentsFrame.BlackBG then TalentsFrame.BlackBG:SetAlpha(0) end
    if TalentsFrame.BottomBar then TalentsFrame.BottomBar:SetAlpha(0) end
    HideTalentArt(TalentsFrame)
    SkinLegacyTalentTree(TalentsFrame)
    SkinTabSystem(TalentsFrame.TabSystem, "top")
    for _, key in ipairs({"ResetButton", "UndoButton"}) do
        if TalentsFrame[key] then
            TalentsFrame[key]:GwSkinButton(false, true)
        end
    end
    GW.SkinArrowDropdown(TalentsFrame.SearchOptionsDropdown)

    TalentsFrame.ApplyButton:GwSkinButton(false, true)
    if TalentsFrame.LoadSystem and TalentsFrame.LoadSystem.Dropdown then
        TalentsFrame.LoadSystem.Dropdown:GwHandleDropDownBox()
    end

    if TalentsFrame.InspectCopyButton then
        TalentsFrame.InspectCopyButton:GwSkinButton(false, true)
    end

    for _, key in ipairs({"ClassCurrencyDisplay", "SpecCurrencyDisplay"}) do
        local display = TalentsFrame[key]
        if display then
            local label = display.CurrencyLabel or display.UnspentLabel
            if label then
                label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader)
                label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
            end
            display.CurrentAmountContainer.CurrencyAmount:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 8)
            for _, artKey in ipairs({"Border", "TextBackground"}) do
                if display[artKey] then
                    display[artKey]:SetAlpha(0)
                end
            end
        end
    end

    GW.SkinTextBox(TalentsFrame.SearchBox.Middle, TalentsFrame.SearchBox.Left, TalentsFrame.SearchBox.Right)
    TalentsFrame.SearchBox:SetHeight(20)
    TalentsFrame.SearchPreviewContainer:GwStripTextures()
    TalentsFrame.SearchPreviewContainer:GwCreateBackdrop(GW.BackdropTemplates.Default, true)

    if TalentsFrame.PvPTalentList then
        TalentsFrame.PvPTalentList:GwStripTextures()
        TalentsFrame.PvPTalentList:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
        TalentsFrame.PvPTalentList.backdrop:SetFrameStrata(TalentsFrame.PvPTalentList:GetFrameStrata())
        TalentsFrame.PvPTalentList.backdrop:SetFrameLevel(2000)
    end

    SkinTabSystem(PlayerSpellsFrame.TabSystem)

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
            check.CheckButton:GwSkinCheckButton(false, 20)
            check.Label:SetTextColor(1, 1, 1)
        end
    end

    -- Addon buttons
    C_Timer.After(0, SkinAddonButtons)

    -- Hero Talents
    local HeroTalentContainer = TalentsFrame.HeroTalentsContainer
    if HeroTalentContainer and HeroTalentContainer.HeroSpecLabel then
        HeroTalentContainer.HeroSpecLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    end

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
        -- the key changed over the versions
        local maxMin = PlayerSpellsFrame.MaximizeMinimizeButton or PlayerSpellsFrame.MaxMinButtonFrame
        if maxMin then
            maxMin:GwHandleMaxMinFrame()
        end
        GW.SkinTextBox(SpellBookFrame.SearchBox.Middle, SpellBookFrame.SearchBox.Left, SpellBookFrame.SearchBox.Right)
        SpellBookFrame.SearchBox:SetHeight(20)
        if SpellBookFrame.HidePassivesCheckButton then
            SpellBookFrame.HidePassivesCheckButton.Button:GwSkinCheckButton(false, 20)
            SpellBookFrame.HidePassivesCheckButton.Label:SetTextColor(1, 1, 1)
        end

        SpellBookFrame.HelpPlateButton:GwKill()
        GW.SkinArrowDropdown(SpellBookFrame.SettingsDropdown)

        SkinTabSystem(SpellBookFrame.CategoryTabSystem, "top")

        local PagedSpellsFrame = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame
        PagedSpellsFrame.View1:DisableDrawLayer("OVERLAY")

        local PagingControls = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame.PagingControls
        GW.HandleNextPrevButton(PagingControls.PrevPageButton)
        GW.HandleNextPrevButton(PagingControls.NextPageButton)
        PagingControls.PageText:SetTextColor(1, 1, 1)
    end
end

local function LoadPlayerSpellsSkin()
    if not GW.settings.skins.playerSpells.enabled then return end
    C_AddOns.LoadAddOn("Blizzard_PlayerSpells")
    GW.RegisterLoadHook(skinPlayerSpells, "Blizzard_PlayerSpells", PlayerSpellsFrame)
end
GW.LoadPlayerSpellsSkin = LoadPlayerSpellsSkin
