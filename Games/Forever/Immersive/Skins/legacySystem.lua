---@class GW2
local GW = select(2, ...)

local PAGE_TOP = 34
local FRAME_HEIGHT = 575 + PAGE_TOP
local PAGE_HEIGHT = FRAME_HEIGHT - PAGE_TOP - 6
local CONTROL_HEIGHT = 24
-- the trait panel is 775 wide and hangs on the right, the rest is the selection column
local TREE_COLUMN_CENTER = (920 - 8 - 6 - 775) / 2
local TREE_SELECTION_SPACING = 15
local SCROLLBAR_WIDTH = 20
local SCROLLBAR_INSET = 18
local ARROW = "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png"
local STATUSBAR = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png"
local ROW_BG = "Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png"
local LIST_BG = "Interface/AddOns/GW2_UI/textures/bag/bag-sep.png"
local ROW_HOVER = "Interface/AddOns/GW2_UI/textures/uistuff/achievementhover.png"
local MENU_BG = "Interface/AddOns/GW2_UI/textures/character/menu-bg.png"
local MENU_HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"
local TAB_ICONS = {
    "Interface/AddOns/GW2_UI/textures/character/tabicon_legacy_rewards.png",
    "Interface/AddOns/GW2_UI/textures/character/tabicon_legacy_challenges.png",
    "Interface/AddOns/GW2_UI/textures/character/tabicon_legacy_tree.png",
}

local categoryFont = CreateFont("GwLegacyCategoryFont")
local categoryLeafFont = CreateFont("GwLegacyCategoryLeafFont")

local function SkinScrollBar(frame)
    GW.HandleTrimScrollBar(frame.ScrollBar)
    GW.HandleScrollControls(frame)
end

local function SkinIconTexture(icon)
    GW.HandleIcon(icon, true, GW.BackdropTemplates.DefaultWithColorableBorder, true)
    icon.backdrop:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
end

local function SkinProgressBar(bar)
    bar:SetStatusBarTexture(STATUSBAR)
    bar:SetStatusBarColor(GW.Colors.FactionBarColors[4]:GetRGB())
    bar.ProgressBarFrame:SetAlpha(0)
    bar.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "THINOUTLINE")
    GW.AddStatusBarFrame(bar)
end

local function SetArrow(texture, collapsed)
    texture:SetTexture(ARROW)
    texture:SetRotation(collapsed and math.pi / 2 or 0)
end

local function AddRowHover(row, texture)
    row.gwHover = row:CreateTexture(nil, "ARTWORK", nil, 1)
    row.gwHover:SetTexture(texture)
    row.gwHover:SetVertexColor(0.8, 0.8, 0.8, 0.8)
    row.gwHover:SetPoint("LEFT", row, "LEFT")
    row.gwHover:SetPoint("TOP", row, "TOP")
    row.gwHover:SetPoint("BOTTOM", row, "BOTTOM")
    row.gwHover:SetPoint("RIGHT", row, "LEFT")
    row.gwHover:Hide()
    row.limitHoverStripAmount = 1
    row:HookScript("OnEnter", function(self)
        self.gwHover:Show()
        GW.TriggerButtonHoverAnimation(self, self.gwHover)
    end)
    row:HookScript("OnLeave", function(self)
        self.gwHover:Hide()
    end)
end

---------- challenges ----------

-- the list mixes headers and leaf entries in one pooled row, so the art follows the row state
local function UpdateCategoryRowArt(row)
    local isHeader = row.collapsable
    row.gwBackground:SetShown(isHeader)
    row:GetNormalTexture():SetTexture(nil)
    row:GetHighlightTexture():SetTexture(nil)

    local font = isHeader and categoryFont or categoryLeafFont
    row:SetNormalFontObject(font)
    row:SetHighlightFontObject(font)
    row:SetDisabledFontObject(font)
    if isHeader then
        row:GetTitleRegion():GwLockTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    else
        row:GetTitleRegion():GwLockTextColor(1, 1, 1)
    end
end

local function SkinCategoryRow(row)
    row.gwBackground = row:CreateTexture(nil, "BACKGROUND")
    row.gwBackground:SetAllPoints(row)
    row.gwBackground:SetTexture(MENU_BG)
    AddRowHover(row, MENU_HOVER)

    local collapse = row.CollapseButton
    collapse:SetSize(16, 16)
    SetArrow(collapse.Icon, collapse.collapsed)
    hooksecurefunc(collapse, "UpdateCollapsedState", function(self, collapsed)
        SetArrow(self.Icon, collapsed)
        self:SetHighlightTexture(ARROW, "ADD")
        self:GetHighlightTexture():SetAlpha(0.3)
    end)

    hooksecurefunc(row, "RefreshCardArt", UpdateCategoryRowArt)
    hooksecurefunc(row, "RefreshTitleColorState", UpdateCategoryRowArt)
    UpdateCategoryRowArt(row)
end

local function SkinCriteria(criteria)
    criteria.Background:SetTexture(ROW_BG)
    criteria.Background:SetVertexColor(1, 1, 1, 0.25)
    criteria.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    criteria.Name:GwLockTextColor(1, 1, 1)
    criteria.ProgressBarBackground:SetAlpha(0)
    SkinProgressBar(criteria.ProgressBar)
end

local function SkinChallengeIcon(icon)
    icon.texture:RemoveMaskTexture(icon.TextureMask)
    icon.frame:SetAlpha(0)
    SkinIconTexture(icon.texture)
end

local function SkinChallengeCard(card)
    for _, key in ipairs({"Background", "BackgroundTop", "BackgroundMiddle", "BackgroundBottom", "TitleBar", "SelectedOverlay"}) do
        card[key]:SetAlpha(0)
    end
    GW.AddDetailsBackground(card)
    AddRowHover(card, ROW_HOVER)

    card.Label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    card.Label:GwLockTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    card.Description:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    card.Description:GwLockTextColor(1, 1, 1)
    card.HiddenDescription:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    SkinChallengeIcon(card.Icon)

    card.PlusMinus:SetSize(16, 16)
    hooksecurefunc(card.PlusMinus, "SetAtlas", function(self, atlas)
        SetArrow(self, atlas and atlas:find("plus") ~= nil)
    end)
    SetArrow(card.PlusMinus, (card.PlusMinus:GetAtlas() or "plus"):find("plus") ~= nil)

    card.Shield.Points:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "THINOUTLINE")
    card.Shield.CheckBackground:SetAlpha(0)
    card.Shield.DateCompleted:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
end

local function SkinCategoryList(list)
    GW.AddDetailsBackground(list)
    list.tex:ClearAllPoints()
    list.tex:SetPoint("TOPLEFT", list, "TOPLEFT", 0, 0)
    list.tex:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -15, 0)

    local search = list.SearchBox
    GW.SkinTextBox(search.Middle, search.Left, search.Right)

    local dropdown = list.FilterDropdown
    dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, 80)
    dropdown:SetSize(80, CONTROL_HEIGHT)
    dropdown:ClearAllPoints()
    dropdown:SetPoint("TOPRIGHT", list, "TOPRIGHT", -(SCROLLBAR_INSET + 4), -6)
    dropdown.backdrop:ClearAllPoints()
    dropdown.backdrop:SetPoint("TOPLEFT", dropdown, "TOPLEFT", 0, 0)
    dropdown.backdrop:SetPoint("BOTTOMRIGHT", dropdown, "BOTTOMRIGHT", 0, 0)

    search:ClearAllPoints()
    search:SetPoint("TOPLEFT", list, "TOPLEFT", 12, -6)
    search:SetPoint("BOTTOMRIGHT", dropdown, "BOTTOMLEFT", -6, 0)

    -- the rows carry their own background, so they need room for it inside the scroll box
    list.ScrollBox:ClearAllPoints()
    list.ScrollBox:SetPoint("TOPLEFT", list, "TOPLEFT", 12, -35)
    list.ScrollBox:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -SCROLLBAR_INSET - SCROLLBAR_WIDTH, 5)
    SkinScrollBar(list)
    list.NoResultsText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)

    hooksecurefunc(list.ScrollBox, "Update", function(scrollBox)
        scrollBox:ForEachFrame(function(row)
            if not row.gwSkinned then
                SkinCategoryRow(row)
                row.gwSkinned = true
            end
        end)
    end)
end

local function SkinChallengesPage(page)
    page.Background:Hide()
    page.VerticalDivider:Hide()
    SkinCategoryList(page.CategoryList)

    local details = page.DetailPane
    GW.AddDetailsBackground(details)
    details.ScrollBox:ClearAllPoints()
    details.ScrollBox:SetPoint("TOPLEFT", details, "TOPLEFT", 4, -3)
    details.ScrollBox:SetPoint("BOTTOMRIGHT", details, "BOTTOMRIGHT", -(SCROLLBAR_INSET + SCROLLBAR_WIDTH), 5)
    details.ScrollBar:ClearAllPoints()
    details.ScrollBar:SetPoint("TOPLEFT", details.ScrollBox, "TOPRIGHT", 0, 0)
    details.ScrollBar:SetPoint("BOTTOMLEFT", details.ScrollBox, "BOTTOMRIGHT", 0, 0)
    SkinScrollBar(details)
    hooksecurefunc(details.ScrollBox, "Update", function(scrollBox)
        scrollBox:ForEachFrame(function(card)
            if not card.gwSkinned then
                SkinChallengeCard(card)
                card.gwSkinned = true
            end
            -- earned challenges keep blizzards green, open ones stay grey
            if card.completed then
                card.tex:SetVertexColor(0.45, 0.78, 0.55)
            else
                card.tex:SetVertexColor(0.62, 0.62, 0.62)
            end
        end)
    end)

    hooksecurefunc(LegacyChallengeObjectives, "Display", function(self)
        for criteria in self.criteriaPool:EnumerateActive() do
            if not criteria.gwSkinned then
                SkinCriteria(criteria)
                criteria.gwSkinned = true
            end
        end
    end)

    local summary = page.LegacyChallengePointSummary
    summary.ProgressBarBackground:SetAlpha(0)
    summary.PointsBar:ClearAllPoints()
    summary.PointsBar:SetPoint("LEFT", summary, "LEFT", 0, -2)
    summary.PointsBar:SetPoint("RIGHT", summary, "RIGHT", 0, -2)
    summary.PointsBar:SetHeight(16)
    SkinProgressBar(summary.PointsBar)
    summary.Shield:ClearAllPoints()
    summary.Shield:SetPoint("RIGHT", summary, "LEFT", -6, 4)
    summary.Shield.Points:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "THINOUTLINE")
end

---------- reward track ----------

local function SkinRewardCard(card)
    card.RewardCardBG:SetAlpha(0)
    card.IconBorder:SetAlpha(0)
    card.LevelSquare:SetAlpha(0)
    GW.AddDetailsBackground(card)
    SkinIconTexture(card.Icon)

    card.gwLevelPlate = card:CreateTexture(nil, "ARTWORK", nil, 0)
    card.gwLevelPlate:SetTexture(LIST_BG)
    card.gwLevelPlate:SetHeight(30)
    card.gwLevelPlate:SetPoint("TOPLEFT", card, "TOPLEFT", 6, -4)
    card.gwLevelPlate:SetPoint("TOPRIGHT", card, "TOPRIGHT", -6, -4)
    card.Level:ClearAllPoints()
    card.Level:SetPoint("CENTER", card.gwLevelPlate, "CENTER", 0, 0)
    card.Level:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 4)
    card.Level:GwLockTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    card.RewardName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    card.RewardName:GwLockTextColor(1, 1, 1)
end

local function SkinRewardTrackPage(page)
    page.Background:Hide()
    page.ProgressBarBackground:Hide()
    page.Points:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader)
    page.PointsLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    page.PointsLabel:GwLockTextColor(1, 1, 1)

    local bar = page.LegacyRewardProgressBar
    bar:ClearAllPoints()
    bar:SetPoint("TOP", page.PointsLabel, "BOTTOM", 0, -30)
    bar:SetSize(850, 18)
    SkinProgressBar(bar)

    local progress = page.LegacyRewardProgressFrame
    -- blizzard caches the element pitch on load, so the spacing change has to go in with it
    progress.elementSpacing = 10
    progress.calculationWidth = progress.elementWidth + progress.elementSpacing
    progress:ClearAllPoints()
    progress:SetPoint("TOP", bar, "BOTTOM", 0, -18)

    local function SkinCards()
        for card in progress.elementPool:EnumerateActive() do
            if not card.gwSkinned then
                SkinRewardCard(card)
                card.gwSkinned = true
            end
        end
    end
    hooksecurefunc(progress, "Init", SkinCards)
    page:HookScript("OnShow", SkinCards)
end

---------- tree ----------

local function SquareHighlight(button)
    local highlight = button:GetHighlightTexture()
    highlight:RemoveMaskTexture(button.CircleMask)
    highlight:SetTexture(MENU_HOVER)
    highlight:SetVertexColor(1, 1, 1, 0.25)
    highlight:ClearAllPoints()
    highlight:SetAllPoints(button)
end

local function SquareTreeIcon(button)
    button.Ring:SetAlpha(0)
    button.CircleMask:Hide()
    local icon = button:GetNormalTexture()
    icon:RemoveMaskTexture(button.CircleMask)
    button:GetPushedTexture():RemoveMaskTexture(button.CircleMask)
    SquareHighlight(button)
    hooksecurefunc(button, "UpdateHighlightTexture", SquareHighlight)

    button.CheckedTexture:SetTexture(MENU_HOVER)
    button.CheckedTexture:SetVertexColor(1, 0.93, 0.73, 0.35)
    button.CheckedTexture:ClearAllPoints()
    button.CheckedTexture:SetAllPoints(button)

    SkinIconTexture(icon)
end

local function SkinTreeSelection(button)
    button.Background:SetAlpha(0)
    button.SelectedGlow:SetTexture(MENU_HOVER)
    button.SelectedGlow:SetVertexColor(1, 0.93, 0.73, 0.3)
    SquareTreeIcon(button)
end

local function SkinIconButton(button)
    button:GwStripTextures()
    button:GwSkinButton(false, true, true)
    button.Icon:ClearAllPoints()
    button.Icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.Icon:SetSize(18, 18)
end

local function SkinTreePage(page)
    page.Background:Hide()
    page.VerticalDivider:Hide()

    local panel = page.LegacyTreeTraitPanel
    GW.AddDetailsBackground(panel)

    local summary = page.LegacyTreePointSummary
    summary.Border:SetAlpha(0)
    summary.AvailablePointsLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    summary.AvailablePointsLabel:GwLockTextColor(1, 1, 1)
    summary:ClearAllPoints()
    summary:SetPoint("TOPLEFT", panel, "TOPLEFT", 74, -14)
    summary.Shield:ClearAllPoints()
    summary.Shield:SetPoint("RIGHT", summary, "LEFT", -6, 0)
    summary.Shield.Points:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "THINOUTLINE")
    GW.SkinTextBox(panel.SearchBox.Middle, panel.SearchBox.Left, panel.SearchBox.Right)
    panel.SearchBox:SetHeight(CONTROL_HEIGHT)
    panel.ApplyButton:GwSkinButton(false, true)
    SkinIconButton(panel.ResetButton)
    SkinIconButton(panel.UndoButton)
    panel.SpentPointsFrame.Background:SetAlpha(0)
    panel.SpentPointsFrame.Text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    panel.SelectedTreeIcon.SelectedTreeLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader)
    panel.SelectedTreeIcon.SelectedTreeLabel:GwLockTextColor(1, 1, 1)

    SquareTreeIcon(panel.SelectedTreeIcon)

    local function SkinTalentButtons()
        for button in panel:EnumerateAllTalentButtons() do
            GW.SkinTalentButton(button)
        end
    end
    panel:RegisterCallback("TalentButtonAcquired", function(_, button)
        GW.SkinTalentButton(button)
    end, "GwLegacySystemSkin")
    SkinTalentButtons()

    -- blizzards column keeps the buttons in a 142 wide card slot, so they are placed by hand
    -- on the centre of the strip left of the trait panel
    local selection = page.LegacyTreeSelectionPanel
    local function LayoutSelections()
        local children = selection.TreeSelections:GetLayoutChildren()
        if #children == 0 then return end

        local height = TREE_SELECTION_SPACING * (#children - 1)
        for _, child in ipairs(children) do
            height = height + child:GetHeight()
        end

        local previous
        for _, child in ipairs(children) do
            child:ClearAllPoints()
            if previous then
                child:SetPoint("TOP", previous, "BOTTOM", 0, -TREE_SELECTION_SPACING)
            else
                child:SetPoint("TOP", page, "TOPLEFT", TREE_COLUMN_CENTER, -(PAGE_HEIGHT - height) / 2)
            end
            previous = child
        end
    end
    hooksecurefunc(selection.TreeSelections, "Layout", LayoutSelections)

    local function SkinSelections()
        for button in selection.treeButtonPool:EnumerateActive() do
            if not button.gwSkinned then
                SkinTreeSelection(button)
                button.gwSkinned = true
            end
        end
    end
    hooksecurefunc(selection, "RefreshTreeButtons", function()
        SkinSelections()
        LayoutSelections()
    end)
    page:HookScript("OnShow", function()
        SkinSelections()
        SkinTalentButtons()
        LayoutSelections()
    end)
    SkinSelections()
    LayoutSelections()
end

---------- window ----------

local function SkinTabs(frame)
    for index, tab in ipairs(frame.Tabs) do
        GW.SkinSideTabButton(tab, TAB_ICONS[index], tab.tooltipText)
        tab.Icon:SetAlpha(0)
        tab:SetParent(frame.LeftSidePanel)
        tab:ClearAllPoints()
        tab:SetPoint("TOPRIGHT", frame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * (index - 1)))
        tab:SetSize(64, 40)
        hooksecurefunc(tab, "SetChecked", function(self, checked)
            self.icon:SetTexCoord(checked and 0 or 0.51, checked and 0.5 or 1, 0, 0.625)
        end)
        tab:SetChecked(index == frame.currentPage)
    end
end

local function ApplyLegacySystemSkin()
    if not GW.settings.skins.legacySystem.enabled then return end

    local size = GW.settings.fonts.size.normal or 14
    categoryFont:SetFont(DAMAGE_TEXT_FONT, size, "")
    categoryLeafFont:SetFont(UNIT_NAME_FONT, size, "")

    LegacySystemFrame:GwStripTextures()
    GW.HandlePortraitFrameArt(LegacySystemFrame)
    LegacySystemFrame.NineSlice:Hide()
    LegacySystemFrame.PortraitContainer:Hide()
    LegacySystemFrame.Bg:Hide()
    LegacySystemFrame:SetHeight(FRAME_HEIGHT)

    GW.CreateFrameHeaderWithBody(LegacySystemFrame, LegacySystemFrame:GetTitleText(), "Interface/AddOns/GW2_UI/textures/character/achievements-window-icon.png", nil, nil, true, true)
    LegacySystemFrame.gwHeader.windowIcon:ClearAllPoints()
    LegacySystemFrame.gwHeader.windowIcon:SetPoint("CENTER", LegacySystemFrame.gwHeader, "BOTTOMLEFT", -26, 35)
    LegacySystemFrame:GetTitleText():ClearAllPoints()
    LegacySystemFrame:GetTitleText():SetPoint("BOTTOMLEFT", LegacySystemFrame.gwHeader, "BOTTOMLEFT", 25, 10)
    LegacySystemFrame:GetTitleText():GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    LegacySystemFrame:SetClampedToScreen(true)
    LegacySystemFrame:SetClampRectInsets(-40, 0, LegacySystemFrame.gwHeader:GetHeight() - 30, 0)

    LegacySystemFrame.CloseButton:GwSkinButton(true, false)
    LegacySystemFrame.CloseButton:SetSize(25, 25)
    LegacySystemFrame.CloseButton:ClearAllPoints()
    LegacySystemFrame.CloseButton:SetPoint("TOPRIGHT", LegacySystemFrame, "TOPRIGHT", -6, 4)

    SkinTabs(LegacySystemFrame)

    for _, page in ipairs(LegacySystemFrame.Pages) do
        page:ClearAllPoints()
        page:SetPoint("TOPLEFT", LegacySystemFrame, "TOPLEFT", 4, -PAGE_TOP)
        page:SetPoint("BOTTOMRIGHT", LegacySystemFrame, "BOTTOMRIGHT", -4, 6)
    end

    SkinRewardTrackPage(LegacySystemFrame.RewardTrackPage)
    SkinChallengesPage(LegacySystemFrame.ChallengesPage)
    SkinTreePage(LegacySystemFrame.TreePage)
end

local function LoadLegacySystemSkin()
    GW.RegisterLoadHook(ApplyLegacySystemSkin, "Blizzard_LegacySystem", LegacySystemFrame)
end
GW.LoadLegacySystemSkin = LoadLegacySystemSkin
