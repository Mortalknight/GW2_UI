---@class GW2
local GW = select(2, ...)
local L = GW.L

-- Collections journal: frame, tabs, mounts, pets, toys, heirlooms, wardrobe items and sets, warband scenes.
-- Our header covers the top 32 units, blizzards control row there moves into the band above the insets.

local ICON_TEXCOORDS = {0.1, 0.9, 0.1, 0.9}
local SELECTED_TEXTURE = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"
local SELECTED_COLOR = {0.8, 0.8, 0.8, 1}
local HIGHLIGHT_COLOR = {1, 1, 1, 0.25}
local ACTIVE_COLOR = {0.9, 0.8, 0.1, 0.3}
local DISABLED_TEXT = {0.4, 0.4, 0.4}
local PROGRESS_COLOR = {0.32, 0.68, 0.32}
local STATUSBAR_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png"
local XP_COLOR = {0.35, 0.55, 0.9}
local FILTER_WIDTH = 90
local CONTROL_ROW_Y = -36
local CONTROL_HEIGHT = 20
local CLASS_DROPDOWN_WIDTH = 110 -- heirlooms and wardrobe, blizzards 150 crowd the control row
local CHECKBOX_SIZE = 15
local PROGRESS_WIDTH = 196 -- the width of blizzards progress bar template
local MOUNT_ACHIEVEMENT_CATEGORY = 15248
local TOYBOX_ACHIEVEMENT_CATEGORY = 15247
local COLLECTION_ACHIEVEMENT_CATEGORY = 15259

---------- small shared pieces ----------

-- the help tooltip is a glow box, blanked textures stay invisible when blizzard shows the arrows
local function SkinHelpPlateTooltip()
    local tooltip = HelpPlateTooltip
    if tooltip.gwSkinned then return end
    tooltip.gwSkinned = true
    tooltip:GwStripTextures()
    tooltip:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    tooltip.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    tooltip.Text:SetTextColor(1, 1, 1)
end

-- HelpTip frames are pooled and shared with the whole game: only tips on our buttons get our look,
-- and they get blizzards back when they hide
local skinnedHelpButtons = {}
local function StyleHelpTipFrame(frame)
    if not frame.gwHelpTipHooked then
        frame.gwHelpTipHooked = true
        frame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
        frame.backdrop:Hide()
        frame:HookScript("OnHide", function(self)
            if not self.gwStyled then return end
            self.gwStyled = nil
            self.backdrop:Hide()
            for _, region in next, {self:GetRegions()} do
                if region:IsObjectType("Texture") then
                    region:SetShown(region.gwWasShown)
                    region:SetAlpha(1)
                end
            end
            self.Arrow:SetAlpha(1)
        end)
    end
    frame.gwStyled = true
    frame.backdrop:Show()
    -- alpha alone left the gradient background visible, hiding the regions is reliable
    for _, region in next, {frame:GetRegions()} do
        if region:IsObjectType("Texture") then
            region.gwWasShown = region:IsShown()
            region:SetAlpha(0)
            region:Hide()
        end
    end
    frame.Arrow:SetAlpha(0)
end

local function HookHelpTips()
    if HelpTip.gwHooked then return end
    HelpTip.gwHooked = true
    hooksecurefunc(HelpTip, "Show", function(self, parent)
        if not skinnedHelpButtons[parent] then return end
        for frame in self.framePool:EnumerateActive() do
            if frame:GetParent() == parent then
                StyleHelpTipFrame(frame)
            end
        end
    end)
end

local HELP_BUTTON_SIZE = 20
local function SkinHelpButton(button)
    if not button.gwSkinned then
        button.gwSkinned = true
        -- blanked, so blizzards ring pulse for new players stays invisible
        button:GwStripTextures()
        -- the 64 unit template insets its hit rect by 20 on every side, at our size nothing would be left
        button:SetHitRectInsets(0, 0, 0, 0)
        button:SetSize(HELP_BUTTON_SIZE, HELP_BUTTON_SIZE)
        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/helpmicrobutton-up.png")
        icon:SetAllPoints(button)
        button.gwIcon = icon
        button:GwStyleButton(nil, true)
        skinnedHelpButtons[button] = true
        SkinHelpPlateTooltip()
        HookHelpTips()
    end
    button:ClearAllPoints()
    button:SetPoint("RIGHT", CollectionsJournal.CloseButton, "LEFT", -6, 0)
end

local function SkinSearchBox(box)
    if box.gwSkinned then return end
    box.gwSkinned = true
    GW.SkinTextBox(box.Middle, box.Left, box.Right)
end

-- xp bars have no color of their own and would vanish white on the gray background
local function SkinStatusBar(bar, artFrame, color)
    if bar.gwSkinned then return end
    bar.gwSkinned = true
    if artFrame then
        artFrame:GwStripTextures()
    end
    bar:GwStripTextures()
    GW.AddStatusBarFrame(bar)
    bar:SetStatusBarTexture(STATUSBAR_TEXTURE)
    if color then
        bar:SetStatusBarColor(unpack(color))
    end
    GW.WhitenFontStrings(bar)
end

-- blizzards bars and our own ones (CreateCollectionBar), only blizzards have the border frame
local function SkinProgressBar(bar)
    if bar.gwSkinned then return end
    bar.gwSkinned = true
    if bar.border then
        bar.border:Hide()
    end
    bar:GwStripTextures()
    GW.AddStatusBarFrame(bar)
    bar:SetHeight(12)
    bar:SetStatusBarTexture(STATUSBAR_TEXTURE)
    bar:SetStatusBarColor(unpack(PROGRESS_COLOR))
    bar.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    bar.text:SetTextColor(1, 1, 1)
end

-- hover on a progress bar: collected, missing and percentage, plus what the tab adds (extraLines)
local function AddProgressBarTooltip(bar, title, extraLines)
    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function(self)
        local collected = self:GetValue()
        local _, total = self:GetMinMaxValues()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(title, 1, 1, 1)
        GameTooltip:AddDoubleLine(COLLECTED, collected, nil, nil, nil, 1, 1, 1)
        GameTooltip:AddDoubleLine(NOT_COLLECTED, math.max(total - collected, 0), nil, nil, nil, 1, 1, 1)
        if total > 0 then
            GameTooltip:AddDoubleLine(STATUS_TEXT_PERCENT, string.format("%d%%", math.floor(collected / total * 100 + 0.5)), nil, nil, nil, 1, 1, 1)
        end
        if extraLines then
            extraLines(GameTooltip)
        end
        GameTooltip:Show()
    end)
    bar:SetScript("OnLeave", GameTooltip_Hide)
end

-- the helper would resize the arrows and misalign the page text
local function SkinPageButton(button, direction)
    local width, height = button:GetSize()
    GW.HandleNextPrevButton(button, direction)
    button:SetSize(width, height)
end

local function SkinPagingFrame(paging)
    if paging.gwSkinned then return end
    paging.gwSkinned = true
    SkinPageButton(paging.PrevPageButton, "left")
    SkinPageButton(paging.NextPageButton, "right")
    paging.PageText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    paging.PageText:SetTextColor(1, 1, 1)
end

-- the filter template relayouts itself on hover, the dropdown helper needs the layout hook for it
local function SkinFilterDropdown(dropdown, anchorTo, rightEdge)
    dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, FILTER_WIDTH)
    dropdown:SetSize(FILTER_WIDTH, CONTROL_HEIGHT)
    dropdown.backdrop:ClearAllPoints()
    dropdown.backdrop:SetPoint("TOPLEFT", dropdown, "TOPLEFT", 0, 0)
    dropdown.backdrop:SetPoint("BOTTOMRIGHT", dropdown, "BOTTOMRIGHT", 0, 0)
    local reset = dropdown.ResetButton
    reset:GwSkinButton(true)
    reset:SetSize(14, 14)
    reset:ClearAllPoints()
    reset:SetPoint("CENTER", dropdown, "TOPRIGHT", -2, -2)
    if anchorTo then
        -- the text box skin draws a two unit top line, the filter matches that edge
        dropdown:ClearAllPoints()
        dropdown:SetPoint("TOPLEFT", anchorTo, "TOPRIGHT", 6, 1)
        dropdown:SetPoint("BOTTOMLEFT", anchorTo, "BOTTOMRIGHT", 6, 0)
        if rightEdge then
            dropdown:SetPoint("RIGHT", rightEdge, "RIGHT", 0, 0)
        end
    end
end

local function SkinDropdowns(...)
    for i = 1, select("#", ...) do
        local dropdown = select(i, ...)
        -- a dropdown without a size yet keeps the helper default instead of collapsing to 0
        local width = dropdown:GetWidth()
        dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, width > 1 and width or nil)
        dropdown:SetHeight(CONTROL_HEIGHT)
        dropdown.backdrop:ClearAllPoints()
        dropdown.backdrop:SetPoint("TOPLEFT", dropdown, "TOPLEFT", 0, 0)
        dropdown.backdrop:SetPoint("BOTTOMRIGHT", dropdown, "BOTTOMRIGHT", 0, 0)
    end
end

local function StripFrames(...)
    for i = 1, select("#", ...) do
        select(i, ...):GwStripTextures()
    end
end

local function KeepLabelWhite(text)
    if text.gwWhiteHooked then return end
    text.gwWhiteHooked = true
    local function Recolor(self, r, g, b)
        if self.gwRecoloring then return end
        if r and g and b and r > 0.85 and g > 0.6 and b < 0.3 then
            self.gwRecoloring = true
            self:SetTextColor(1, 1, 1)
            self.gwRecoloring = nil
        end
    end
    hooksecurefunc(text, "SetTextColor", Recolor)
    Recolor(text, text:GetTextColor())
end

local function SkinCounter(counter)
    counter:GwStripTextures()
    GW.AddDetailsBackground(counter)
    GW.WhitenFontStrings(counter)

    local label, count = counter.Label, counter.Count
    label:ClearAllPoints()
    label:SetPoint("LEFT", counter, "LEFT", 8, 0)
    count:ClearAllPoints()
    count:SetPoint("LEFT", label, "RIGHT", 6, 0)
    local function FitWidth()
        counter:SetWidth(math.max(60, label:GetStringWidth() + count:GetStringWidth() + 22))
    end
    hooksecurefunc(count, "SetText", FitWidth)
    hooksecurefunc(label, "SetText", FitWidth)
    FitWidth()
end

local SPELL_BUTTON_SIZE = 26
local SUMMON_FRAME_WIDTH = 136
local HEAL_FRAME_WIDTH = 96
local SPELL_FRAME_GAP = 6
-- the frames share the control row with the progress bar, the label wraps into two small lines
local function SkinSpellFrame(frame, width)
    GW.HandleItemButton(frame.Button, true)
    frame.Button:SetSize(SPELL_BUTTON_SIZE, SPELL_BUTTON_SIZE)
    frame:SetSize(width, SPELL_BUTTON_SIZE)
    frame.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    GW.WhitenFontStrings(frame)
end

-- the plain backdrop would cover the icon's parent
local function BackdropAroundIcon(icon, template)
    GW.HandleIcon(icon, true, template or GW.BackdropTemplates.DefaultWithSmallBorder, true)
    return icon.backdrop
end

local function SkinIconButton(button)
    BackdropAroundIcon(button.icon)
    button:GwStyleButton()
end

-- the slot frames are killed for good, blizzards update code shows and fades them in again
local function SkinSpellButton(button)
    if button.gwSkinned then return end
    button.gwSkinned = true

    button.slotFrameCollected:GwKill()
    button.slotFrameUncollected:GwKill()
    button.slotFrameUncollectedInnerGlow:GwKill()
    local icon = button.iconTexture
    icon:SetTexCoord(unpack(ICON_TEXCOORDS))
    button.iconTextureUncollected:SetTexCoord(unpack(ICON_TEXCOORDS))
    button.backdrop = BackdropAroundIcon(icon, GW.BackdropTemplates.DefaultWithColorableBorder)
    button.gwDefaultBorder = {button.backdrop:GetBackdropBorderColor()}
    button:GwStyleButton()
    button.hover:SetAllPoints(icon)
    button.pushed:SetAllPoints(icon)
    button.checked:SetAllPoints(icon)
    button.cooldown:SetAllPoints(icon)
end

local UNOWNED_DIM = 0.45
local function SetBackdropQuality(button, quality, dimmed)
    local color = quality and GW.GetBagItemQualityColor(quality)
    if color then
        local factor = dimmed and UNOWNED_DIM or 1
        button.backdrop:SetBackdropBorderColor(color.r * factor, color.g * factor, color.b * factor, 1)
    else
        button.backdrop:SetBackdropBorderColor(unpack(button.gwDefaultBorder))
    end
end

local function RecolorCollectionText(text, r, g, b)
    if text.gwRecoloring then return end
    text.gwRecoloring = true
    if r == 1 and g == 0.82 and b == 0 then
        text:SetTextColor(1, 1, 1)
    elseif r == 0.33 and g == 0.27 and b == 0.2 then
        text:SetTextColor(unpack(DISABLED_TEXT))
    end
    text.gwRecoloring = nil
end

---------- list rows of the mount, pet and set lists ----------

local ROW_BORDER_DARK = {0.3, 0.3, 0.3}
local ROW_BORDER_LIGHT = {0.45, 0.45, 0.45}
local ROW_BORDER_RED = {0.9, 0.3, 0.3}

-- unusable mounts use GameFontDisable, the other faction a red row background
local function UpdateRowNameColor(row)
    local textColor, borderColor = {1, 1, 1}, ROW_BORDER_DARK
    if row.name:GetFontObject() == GameFontDisable then
        textColor, borderColor = DISABLED_TEXT, ROW_BORDER_LIGHT
    elseif row.background then
        local _, g, b = row.background:GetVertexColor()
        if g == 0 and b == 0 then
            textColor, borderColor = {0.9, 0.3, 0.3}, ROW_BORDER_RED
        end
    end
    row.name:SetTextColor(unpack(textColor))
    -- pet rows keep the quality color of blizzards border, mount rows (faction icon) follow the state
    if row.factionIcon then
        row.icon.backdrop:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], 1)
    end
end

-- rows of three templates: mounts (icon, name, background, factionIcon, DragButton), pets (icon, name,
-- iconBorder, dragButton with level) and sets (IconFrame.Icon, Name, ProgressBar)
local function SkinListRow(row)
    if row.gwSkinned then return end
    row.gwSkinned = true
    GW.AddListItemChildHoverTexture(row)

    local icon = row.icon or row.IconFrame.Icon

    -- the pill is blanked, not alpha 0: blizzard sets its vertex color with alpha 1 on every update
    if row.background then
        row.background:SetTexture()
    end
    local highlight = row:GetHighlightTexture()
    if highlight then
        highlight:SetAlpha(0)
    end
    -- the same selection look as the other list skins (menu hover texture), not a flat box
    local selected = row.selectedTexture or row.SelectedTexture
    selected:SetTexture(SELECTED_TEXTURE)
    selected:SetTexCoord(0, 1, 0, 1)
    selected:SetVertexColor(unpack(SELECTED_COLOR))
    selected:ClearAllPoints()
    selected:SetAllPoints(row)

    BackdropAroundIcon(icon, GW.BackdropTemplates.DefaultWithColorableBorder)
    if row.iconBorder then
        GW.HandleIconBorder(row.iconBorder, icon.backdrop)
    end

    local drag = row.DragButton or row.dragButton
    if drag then
        drag.ActiveTexture:SetColorTexture(unpack(ACTIVE_COLOR))
        local dragHighlight = drag:GetHighlightTexture()
        dragHighlight:SetColorTexture(unpack(HIGHLIGHT_COLOR))
        dragHighlight:SetAllPoints(icon)
        if drag.level then
            drag.levelBG:SetAlpha(0)
            drag.level:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
            -- the pet level follows the quality color of the icon border
            local function ColorLevel(backdrop)
                drag.level:SetTextColor(backdrop:GetBackdropBorderColor())
            end
            hooksecurefunc(icon.backdrop, "SetBackdropBorderColor", ColorLevel)
            ColorLevel(icon.backdrop)
        end
    end

    if row.name then
        UpdateRowNameColor(row)
        hooksecurefunc(row.name, "SetFontObject", function() UpdateRowNameColor(row) end)
        if row.background then
            hooksecurefunc(row.background, "SetVertexColor", function() UpdateRowNameColor(row) end)
        end
    end

    -- set rows: the border follows the state (dark cover on incomplete sets, red icon for other classes)
    local iconFrame = row.IconFrame
    if iconFrame then
        local function UpdateSetBorder()
            local color = ROW_BORDER_LIGHT
            local _, g, b = iconFrame.Icon:GetVertexColor()
            if g < 0.5 and b < 0.5 then
                color = ROW_BORDER_RED
            elseif iconFrame.Cover:IsShown() then
                color = ROW_BORDER_DARK
            end
            icon.backdrop:SetBackdropBorderColor(color[1], color[2], color[3], 1)
        end
        hooksecurefunc(iconFrame, "SetIconCoverShown", UpdateSetBorder)
        hooksecurefunc(iconFrame, "SetIconColor", UpdateSetBorder)
        UpdateSetBorder()
        row.ProgressBar:SetTexture(STATUSBAR_TEXTURE)
        row.ProgressBar:SetVertexColor(0.25, 0.75, 0.25, 1)
    end

    -- mount and pet rows: double click summons, middle click toggles the favorite (blizzard ignores the
    -- middle button in its own click handler)
    if row.factionIcon then
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
        row:HookScript("OnDoubleClick", function(self)
            if self.mountID and not InCombatLockdown() and select(11, C_MountJournal.GetDisplayedMountInfo(self.index)) then
                C_MountJournal.SummonByID(self.mountID)
            end
        end)
        row:HookScript("OnClick", function(self, button)
            if button == "MiddleButton" and self.index then
                local isFavorite, canFavorite = C_MountJournal.GetIsFavorite(self.index)
                if canFavorite then
                    C_MountJournal.SetIsFavorite(self.index, not isFavorite)
                end
            end
        end)
    elseif row.dragButton then
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
        row:HookScript("OnDoubleClick", function(self)
            if self.petID and self.owned and not InCombatLockdown() then
                C_PetJournal.SummonPetByGUID(self.petID)
            end
        end)
        row:HookScript("OnClick", function(self, button)
            if button == "MiddleButton" and self.petID and self.owned then
                C_PetJournal.SetFavorite(self.petID, C_PetJournal.PetIsFavorite(self.petID) and 0 or 1)
            end
        end)
    end
end

local function SkinScrollList(container)
    if container.gwListSkinned then return end
    container.gwListSkinned = true
    GW.HandleTrimScrollBar(container.ScrollBar)
    GW.HandleScrollControls(container)
    -- the wide skinned bar leans into the gap between list and details
    container.ScrollBar:ClearAllPoints()
    container.ScrollBar:SetPoint("TOPLEFT", container.ScrollBox, "TOPRIGHT", 10, 31)
    container.ScrollBar:SetPoint("BOTTOMLEFT", container.ScrollBox, "BOTTOMRIGHT", 10, -1)
    hooksecurefunc(container.ScrollBox, "Update", function(scrollBox)
        for _, row in next, {scrollBox.ScrollTarget:GetChildren()} do
            SkinListRow(row)
        end
        GW.HandleItemListScrollBoxHover(scrollBox)
    end)
end

---------- the tabs at the bottom of the journal ----------

-- blizzard overlaps its tabs by 16 units
local function LayoutJournalTabs()
    local previous
    for i = 1, 6 do
        local tab = _G["CollectionsJournalTab" .. i]
        if tab:IsShown() then
            tab:ClearAllPoints()
            if previous then
                tab:SetPoint("LEFT", previous, "RIGHT", 0, 0)
            else
                tab:SetPoint("TOPLEFT", CollectionsJournal, "BOTTOMLEFT", 0, 1)
            end
            previous = tab
        end
    end
end

local function SkinJournalTabs()
    for i = 1, 6 do
        GW.HandleTabs(_G["CollectionsJournalTab" .. i])
    end
    LayoutJournalTabs()
    -- blizzard re-anchors the wardrobe tab whenever the heirlooms tab toggles
    hooksecurefunc("CollectionsJournal_CheckAndDisplayHeirloomsTab", LayoutJournalTabs)
end

---------- progress bar and achievement status above the mount and pet lists ----------

-- the mount and pet journals only have a plain counter, they get the "collected / total" bar of the other tabs
local function CreateCollectionBar(journal)
    local bar = CreateFrame("StatusBar", nil, journal)
    bar:SetSize(PROGRESS_WIDTH, 12)
    bar:SetMinMaxValues(0, 1)
    bar.text = bar:CreateFontString(nil, "OVERLAY")
    bar.text:SetPoint("CENTER")
    SkinProgressBar(bar)
    bar:SetPoint("TOP", journal, "TOP", 0, CONTROL_ROW_Y - 4)
    return bar
end

local function UpdateCollectionBar(bar, collected, total)
    collected, total = collected or 0, total or 0
    bar:SetMinMaxValues(0, math.max(total, 1))
    bar:SetValue(math.min(collected, math.max(total, 1)))
    bar.text:SetFormattedText(HEIRLOOMS_PROGRESS_FORMAT, collected, total)
end

-- blizzards pet achievement status: shield icon with the category points, a click opens the category
local ACHIEVEMENT_ICON = "Interface/AddOns/GW2_UI/textures/icons/microicons/achievementmicrobutton-up.png"
local ACHIEVEMENT_ICON_SIZE = 18
-- on every tab left of the progress bar
local function SkinAchievementStatus(button, bar)
    button:DisableDrawLayer("BACKGROUND")
    button:SetSize(60, 20)
    button:ClearAllPoints()
    button:SetPoint("RIGHT", bar, "LEFT", -10, 0)
    -- blizzards gold shield becomes the achievement icon of our micro menu
    button.icon:SetTexture(ACHIEVEMENT_ICON)
    button.icon:SetTexCoord(0, 1, 0, 1)
    button.icon:SetSize(ACHIEVEMENT_ICON_SIZE, ACHIEVEMENT_ICON_SIZE)
    button.icon:ClearAllPoints()
    button.icon:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    button.SumText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    button.SumText:SetTextColor(1, 1, 1)
    button.SumText:ClearAllPoints()
    button.SumText:SetPoint("RIGHT", button.icon, "LEFT", -4, 0)
end

-- the same status for the other tabs, which blizzard does not offer
local function CreateAchievementStatus(journal, bar, categoryID, categoryName)
    local button = CreateFrame("Button", nil, journal)
    button.categoryID = categoryID
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.SumText = button:CreateFontString(nil, "OVERLAY")
    SkinAchievementStatus(button, bar)
    button:GwStyleButton(nil, true)

    function button:Update()
        self.SumText:SetText(GetCategoryAchievementPoints(self.categoryID, true))
    end
    button:SetScript("OnClick", function(self)
        if Kiosk.IsEnabled() or not CanShowAchievementUI() then return end
        if not AchievementFrame:IsShown() then
            ToggleAchievementFrame()
        end
        AchievementFrame_UpdateAndSelectCategory(self.categoryID)
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(categoryName, HIGHLIGHT_FONT_COLOR:GetRGB())
        GameTooltip:AddLine(ACHIEVEMENTS, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
    button:Update()
    return button
end

---------- mount journal ----------

-- FlyoutButtonTemplate: the ring art has keys, the icon is the remaining texture region
local function SkinFlyoutButton(button)
    if button.gwSkinned then return end
    button.gwSkinned = true

    local normal, pushed, highlight = button:GetNormalTexture(), button:GetPushedTexture(), button:GetHighlightTexture()
    if normal then normal:SetAlpha(0) end
    if pushed then pushed:SetAlpha(0) end
    highlight:SetColorTexture(unpack(HIGHLIGHT_COLOR))

    local icon = button.Icon or button.icon or button.texture
    for _, region in next, {button:GetRegions()} do
        if region:IsObjectType("Texture") and region ~= normal and region ~= pushed and region ~= highlight then
            if region == button.Border or region == button.BorderShadow or region == button.UnspentGlyphsHighlight then
                region:SetAlpha(0)
            elseif region ~= button.Arrow and not icon and region:GetTexture() then
                icon = region
            end
        end
    end
    if icon then
        icon:SetTexCoord(unpack(ICON_TEXCOORDS))
        icon:ClearAllPoints()
        icon:SetAllPoints(button)
        BackdropAroundIcon(icon)
        highlight:ClearAllPoints()
        highlight:SetAllPoints(icon)
    end
    button:SetSize(SPELL_BUTTON_SIZE, SPELL_BUTTON_SIZE)
    GW.WhitenFontStrings(button)
end

local function SkinMountJournal()
    local journal = MountJournal

    StripFrames(journal, journal.LeftInset, journal.RightInset, journal.BottomLeftInset)
    GW.AddDetailsBackground(journal.BottomLeftInset)
    SkinCounter(journal.MountCount)
    journal.MountCount:ClearAllPoints()
    journal.MountCount:SetPoint("BOTTOMLEFT", journal.LeftInset, "TOPLEFT", 2, 4)
    journal.gwProgressBar = CreateCollectionBar(journal)
    journal.gwAchievementStatus = CreateAchievementStatus(journal, journal.gwProgressBar, MOUNT_ACHIEVEMENT_CATEGORY, MOUNTS)
    -- total: only mounts this character can obtain, the same rule blizzard uses for its owned count
    local function UpdateMountBar()
        local total = 0
        for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
            if select(10, C_MountJournal.GetMountInfoByID(mountID)) ~= true then
                total = total + 1
            end
        end
        UpdateCollectionBar(journal.gwProgressBar, journal.numOwned, total)
        journal.gwAchievementStatus:Update()
    end
    hooksecurefunc("MountJournal_UpdateMountList", UpdateMountBar)
    UpdateMountBar()
    AddProgressBarTooltip(journal.gwProgressBar, MOUNTS, function(tooltip)
        tooltip:AddLine(" ")
        tooltip:AddDoubleLine(L["Shown"], C_MountJournal.GetNumDisplayedMounts(), nil, nil, nil, 1, 1, 1)
        tooltip:AddDoubleLine(TOTAL, C_MountJournal.GetNumMounts(), nil, nil, nil, 1, 1, 1)
        tooltip:AddDoubleLine(ACHIEVEMENTS, GetCategoryAchievementPoints(MOUNT_ACHIEVEMENT_CATEGORY, true), nil, nil, nil, 1, 1, 1)
    end)

    SkinSearchBox(journal.searchBox)
    journal.searchBox:ClearAllPoints()
    journal.searchBox:SetPoint("TOPLEFT", journal.LeftInset, "TOPLEFT", 2, -9)
    SkinFilterDropdown(journal.FilterDropdown, journal.searchBox, journal.ScrollBox)
    SkinScrollList(journal)
    journal.MountButton:GwSkinButton(false, true)

    local summon = journal.SummonRandomFavoriteSpellFrame
    SkinSpellFrame(summon, SUMMON_FRAME_WIDTH)
    summon:ClearAllPoints()
    summon:SetPoint("TOPRIGHT", journal, "TOPRIGHT", -8, CONTROL_ROW_Y + 2)
    SkinFlyoutButton(journal.ToggleDynamicFlightFlyoutButton)
    local popup = journal.DynamicFlightFlyoutPopup
    popup.Background:Hide()
    SkinFlyoutButton(popup.DynamicFlightModeButton)
    SkinFlyoutButton(popup.OpenDynamicFlightSkillTreeButton)

    local display = journal.MountDisplay
    StripFrames(display, display.ShadowOverlay)
    -- after the strip, otherwise the details background would be blanked with the rest
    display.InfoButton:GwNudgePoint(8, 0)
    GW.AddDetailsBackground(display, 10, -2)
    -- the mount hangs out left over the list, pull the scene's left edge in
    display.ModelScene:ClearAllPoints()
    display.ModelScene:SetPoint("TOPLEFT", display, "TOPLEFT", 40, 0)
    display.ModelScene:SetPoint("BOTTOMRIGHT", display, "BOTTOMRIGHT", 0, 0)
    GW.HandleModelSceneControlFrame(display.ModelScene.ControlFrame)
    display.ModelScene.TogglePlayer:GwSkinCheckButton(nil, CHECKBOX_SIZE)
    display.ModelScene.TogglePlayer.TogglePlayerText:SetTextColor(1, 1, 1)
    BackdropAroundIcon(display.InfoButton.Icon)
    display.InfoButton.Name:SetTextColor(1, 1, 1)
    display.InfoButton.Source:SetTextColor(1, 1, 1)
    display.InfoButton.Lore:SetTextColor(1, 1, 1)

    local slot = journal.BottomLeftInset.SlotButton
    slot:GwStripTextures()
    BackdropAroundIcon(slot.ItemIcon)
    slot:GwStyleButton()
    KeepLabelWhite(journal.BottomLeftInset.SlotLabel)
    KeepLabelWhite(journal.BottomLeftInset.SlotRequirementLabel)
end

---------- pet journal ----------

-- CompanionLoadOutTemplate, one of the three battle pet slots
local function SkinLoadoutPet(pet)
    pet.shadows:SetAlpha(0)
    pet.iconBorder:SetAlpha(0)
    pet.levelBG:SetAlpha(0)
    pet.level:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    BackdropAroundIcon(pet.icon, GW.BackdropTemplates.DefaultWithColorableBorder)
    GW.HandleIconBorder(pet.qualityBorder, pet.icon.backdrop)
    pet:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    local highlight = pet:GetHighlightTexture()
    if highlight then
        highlight:SetColorTexture(unpack(HIGHLIGHT_COLOR))
        highlight:SetAllPoints(pet.icon)
    end
    StripFrames(pet.helpFrame, pet.setButton)
    SkinStatusBar(pet.healthFrame.healthBar, pet.healthFrame)
    SkinStatusBar(pet.xpBar, nil, XP_COLOR)
    for i = 1, 3 do
        local spell = pet["spell" .. i]
        SkinIconButton(spell)
        spell.FlyoutArrow:SetTexture("Interface/Buttons/ActionBarFlyoutButton")
    end
end

local function SkinPetCard(card)
    card:GwStripTextures()
    local info = card.PetInfo
    info:GwNudgePoint(10, 0)
    GW.AddDetailsBackground(card, 8, 2)
    info.levelBG:SetAlpha(0)
    info.level:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    BackdropAroundIcon(info.icon, GW.BackdropTemplates.DefaultWithColorableBorder)
    GW.HandleIconBorder(info.qualityBorder, info.icon.backdrop)
    for i = 1, 6 do
        SkinIconButton(card["spell" .. i])
    end
    SkinStatusBar(card.HealthFrame.healthBar, card.HealthFrame)
    SkinStatusBar(card.xpBar, nil, XP_COLOR)
end

local function SkinPetJournal()
    local journal = PetJournal

    StripFrames(journal.LeftInset, journal.RightInset, journal.PetCardInset, journal.loadoutBorder, journal.SpellSelect)
    GW.AddDetailsBackground(journal.RightInset)
    SkinHelpButton(journal.MainHelpButton)
    for _, region in next, {journal.loadoutBorder:GetRegions()} do
        if region:IsObjectType("FontString") then
            region:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
            region:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
            region:GwNudgePoint(0, 8)
        end
    end
    SkinCounter(journal.PetCount)
    journal.PetCount:ClearAllPoints()
    journal.PetCount:SetPoint("BOTTOMLEFT", journal.LeftInset, "TOPLEFT", 2, 4)
    journal.gwProgressBar = CreateCollectionBar(journal)
    SkinAchievementStatus(journal.AchievementStatus, journal.gwProgressBar)
    local function UpdatePetBar()
        local numPets, numOwned = C_PetJournal.GetNumPets()
        UpdateCollectionBar(journal.gwProgressBar, numOwned, numPets)
    end
    hooksecurefunc("PetJournal_UpdatePetList", UpdatePetBar)
    UpdatePetBar()
    AddProgressBarTooltip(journal.gwProgressBar, PETS, function(tooltip)
        tooltip:AddLine(" ")
        tooltip:AddDoubleLine(TOTAL, C_PetJournal.GetNumPets(), nil, nil, nil, 1, 1, 1)
        tooltip:AddDoubleLine(ACHIEVEMENTS, GetCategoryAchievementPoints(PET_ACHIEVEMENT_CATEGORY, true), nil, nil, nil, 1, 1, 1)
    end)

    SkinSearchBox(journal.searchBox)
    journal.searchBox:ClearAllPoints()
    journal.searchBox:SetPoint("TOPLEFT", journal.LeftInset, "TOPLEFT", 2, -9)
    SkinFilterDropdown(journal.FilterDropdown, journal.searchBox, journal.ScrollBox)
    SkinScrollList(journal)
    journal.SummonButton:GwSkinButton(false, true)
    journal.FindBattleButton:GwSkinButton(false, true)

    local heal, summon = journal.HealPetSpellFrame, journal.SummonRandomPetSpellFrame
    SkinSpellFrame(heal, HEAL_FRAME_WIDTH)
    SkinSpellFrame(summon, SUMMON_FRAME_WIDTH)
    heal:ClearAllPoints()
    heal:SetPoint("TOPRIGHT", journal, "TOPRIGHT", -8, CONTROL_ROW_Y + 2)
    summon:ClearAllPoints()
    summon:SetPoint("RIGHT", heal, "LEFT", -SPELL_FRAME_GAP, 0)

    for i = 1, 3 do
        SkinLoadoutPet(journal.Loadout["Pet" .. i])
    end
    SkinIconButton(journal.SpellSelect.Spell1)
    SkinIconButton(journal.SpellSelect.Spell2)
    SkinPetCard(journal.PetCard)
end

---------- grids (toys, heirlooms) ----------

-- Blizzard lays the toy and heirloom grids out around a 625 wide column (the heirloom header width),
-- details backgrounds and control row follow that column
local GRID_CONTENT_WIDTH = 625
local GRID_SECTION_PAD = 10
local GRID_SECTION_TOP = -15 -- the first heirloom header sits at -25, plus the pad
local GRID_SECTION_BOTTOM = 80 -- leaves room for the paging row

-- nil until the grid has a size
local function GetGridMargin(icons)
    local width = icons:GetWidth()
    if width == 0 then return nil end
    return (width - GRID_CONTENT_WIDTH) / 2 - GRID_SECTION_PAD
end

-- false until the grid has a screen position
local function AlignControlRow(frame, icons, searchBox, leftControl)
    local margin = GetGridMargin(icons)
    if not margin or not icons:GetLeft() or not frame:GetLeft() then return false end
    local sectionLeft = icons:GetLeft() + margin - frame:GetLeft()
    local sectionRight = frame:GetRight() - (icons:GetRight() - margin)
    if leftControl then
        leftControl:ClearAllPoints()
        leftControl:SetPoint("TOPLEFT", frame, "TOPLEFT", sectionLeft, CONTROL_ROW_Y)
    end
    searchBox:ClearAllPoints()
    searchBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -(sectionRight + FILTER_WIDTH + 6), CONTROL_ROW_Y)
    return true
end

---------- toy box ----------

local function SkinToyBox()
    local box = ToyBox

    StripFrames(box.iconsFrame)
    SkinSearchBox(box.searchBox)
    box.searchBox:ClearAllPoints()
    box.searchBox:SetPoint("TOPRIGHT", box, "TOPRIGHT", -(FILTER_WIDTH + 16), CONTROL_ROW_Y)
    SkinFilterDropdown(box.FilterDropdown, box.searchBox)

    local details = GW.CreateDetailsBackgroundTexture(box.iconsFrame)
    details:Hide()
    local function LayoutToyGrid()
        local margin = GetGridMargin(box.iconsFrame)
        if not margin then return end
        details:ClearAllPoints()
        details:SetPoint("TOPLEFT", box.iconsFrame, "TOPLEFT", margin, GRID_SECTION_TOP)
        details:SetPoint("BOTTOMRIGHT", box.iconsFrame, "BOTTOMRIGHT", -margin, GRID_SECTION_BOTTOM)
        details:Show()
        if not AlignControlRow(box, box.iconsFrame, box.searchBox) and not box.gwLayoutRetry then
            box.gwLayoutRetry = true
            C_Timer.After(0, function()
                box.gwLayoutRetry = nil
                LayoutToyGrid()
            end)
        end
    end
    box:HookScript("OnShow", LayoutToyGrid)
    LayoutToyGrid()
    SkinProgressBar(box.progressBar)
    box.progressBar:ClearAllPoints()
    box.progressBar:SetPoint("TOP", box, "TOP", 0, CONTROL_ROW_Y - 4)
    AddProgressBarTooltip(box.progressBar, TOY_BOX, function(tooltip)
        tooltip:AddLine(" ")
        tooltip:AddDoubleLine(TOTAL, C_ToyBox.GetNumToys(), nil, nil, nil, 1, 1, 1)
    end)
    local achievements = CreateAchievementStatus(box, box.progressBar, TOYBOX_ACHIEVEMENT_CATEGORY, TOY_BOX)
    box:HookScript("OnShow", function() achievements:Update() end)
    SkinPagingFrame(box.PagingFrame)
    for i = 1, 18 do
        local button = box.iconsFrame["spellButton" .. i]
        SkinSpellButton(button)
        hooksecurefunc(button.name, "SetTextColor", RecolorCollectionText)
        hooksecurefunc(button.new, "SetTextColor", RecolorCollectionText)
    end

    hooksecurefunc("ToySpellButton_UpdateButton", function(button)
        local itemID = button.itemID
        if not itemID or itemID == -1 then return end
        SetBackdropQuality(button, C_Item.GetItemQualityByID(itemID), not PlayerHasToy(itemID))
    end)
end

---------- heirlooms ----------

-- one details background per slot header, reaching down to the next header or the paging row
local function AcquireSectionBackground(journal, index)
    journal.gwSectionBackgrounds = journal.gwSectionBackgrounds or {}
    local bg = journal.gwSectionBackgrounds[index]
    if not bg then
        bg = GW.CreateDetailsBackgroundTexture(journal.iconsFrame)
        journal.gwSectionBackgrounds[index] = bg
    end
    bg:ClearAllPoints()
    bg:Show()
    return bg
end

local function LayoutHeirloomSections(journal)
    local icons = journal.iconsFrame
    local iconsLeft, margin = icons:GetLeft(), GetGridMargin(icons)
    if not iconsLeft or not margin then return end

    local headers = {}
    for _, header in ipairs(journal.heirloomHeaderFrames) do
        if header:IsShown() then
            tinsert(headers, header)
        end
    end

    local used = 0
    local function EndSection(bg, nextHeader)
        if nextHeader then
            bg:SetPoint("BOTTOMRIGHT", nextHeader, "TOPRIGHT", GRID_SECTION_PAD, GRID_SECTION_PAD + 6)
        else
            bg:SetPoint("BOTTOMRIGHT", icons, "BOTTOMRIGHT", -margin, GRID_SECTION_BOTTOM)
        end
    end

    -- a page that continues a section starts with entries above its first header
    local firstEntry = journal.heirloomEntryFrames[1]
    if firstEntry and firstEntry:IsShown() and firstEntry:GetLeft() and (not headers[1] or (firstEntry:GetTop() or 0) > (headers[1]:GetTop() or 0)) then
        used = used + 1
        local bg = AcquireSectionBackground(journal, used)
        bg:SetPoint("TOPLEFT", firstEntry, "TOPLEFT", -(firstEntry:GetLeft() - iconsLeft - margin), GRID_SECTION_PAD + 6)
        EndSection(bg, headers[1])
    end

    for i, header in ipairs(headers) do
        used = used + 1
        local bg = AcquireSectionBackground(journal, used)
        bg:SetPoint("TOPLEFT", header, "TOPLEFT", -GRID_SECTION_PAD, GRID_SECTION_PAD)
        EndSection(bg, headers[i + 1])
    end

    for i = used + 1, #journal.gwSectionBackgrounds do
        journal.gwSectionBackgrounds[i]:Hide()
    end

    if not journal.gwControlsAligned then
        journal.gwControlsAligned = AlignControlRow(journal, icons, journal.SearchBox, journal.ClassDropdown)
    end
end

-- slot headers like the settings panel headers: title left, accent square, thin separator below
local function SkinHeirloomHeader(header)
    if header.gwSkinned then return end
    header.gwSkinned = true
    header:GwStripTextures()
    header.text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    header.text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    header.text:SetJustifyH("LEFT")
    header.text:ClearAllPoints()
    header.text:SetPoint("LEFT", header, "LEFT", 12, 0)
    header.text:SetPoint("RIGHT", header, "RIGHT", -12, 0)

    local accent = header:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(1, 1, 1, 0.85)
    accent:SetSize(5, 5)
    accent:SetPoint("LEFT", header, "LEFT", 2, 0)

    local separator = header:CreateTexture(nil, "ARTWORK")
    separator:SetTexture("Interface/AddOns/GW2_UI/textures/hud/levelreward-sep.png")
    separator:SetVertexColor(1, 1, 1, 0.65)
    -- the texture fades at both ends, show it from the solid middle to the right fade
    separator:SetTexCoord(0.5, 413 / 512, 0, 1)
    separator:SetSize(300, 2)
    separator:SetPoint("TOPLEFT", header.text, "BOTTOMLEFT", 0, -1)
end

-- upgrade level of an owned heirloom as a column of pips along the left edge of the icon, filled from the
-- bottom up: reached levels in the heirloom color, the missing ones gray
local PIP_SIZE, PIP_GAP, PIP_INSET = 5, 1, 3
local PIP_EMPTY = {0.35, 0.35, 0.35, 1}
local PIP_BACK = {0, 0, 0, 0.7}
local function UpdateHeirloomPips(button, owned)
    button.gwPips = button.gwPips or {}
    local pips = button.gwPips
    local maxLevel = owned and C_Heirloom.GetHeirloomMaxUpgradeLevel(button.itemID) or 0
    local level = maxLevel > 0 and select(5, C_Heirloom.GetHeirloomInfo(button.itemID)) or 0
    local color = GW.GetBagItemQualityColor(Enum.ItemQuality.Heirloom)
    local icon = button.iconTexture
    -- a dark strip behind the column keeps the pips readable on bright icons
    if not button.gwPipBack then
        button.gwPipBack = button:CreateTexture(nil, "OVERLAY", nil, 1)
        button.gwPipBack:SetColorTexture(unpack(PIP_BACK))
        button.gwPipBack:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", PIP_INSET - 1, PIP_INSET - 1)
    end
    button.gwPipBack:SetShown(maxLevel > 0)
    button.gwPipBack:SetSize(PIP_SIZE + 2, maxLevel * (PIP_SIZE + PIP_GAP) - PIP_GAP + 2)
    for i = 1, math.max(maxLevel, #pips) do
        local pip = pips[i]
        if not pip and i <= maxLevel then
            pip = button:CreateTexture(nil, "OVERLAY", nil, 2)
            pip:SetSize(PIP_SIZE, PIP_SIZE)
            pip:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", PIP_INSET, PIP_INSET + (i - 1) * (PIP_SIZE + PIP_GAP))
            pips[i] = pip
        end
        if pip then
            pip:SetShown(i <= maxLevel)
            if i <= level then
                pip:SetColorTexture(color.r, color.g, color.b, 1)
            else
                pip:SetColorTexture(unpack(PIP_EMPTY))
            end
        end
    end
end

local function SkinHeirlooms()
    local journal = HeirloomsJournal

    StripFrames(journal.iconsFrame)
    SkinSearchBox(journal.SearchBox)
    journal.SearchBox:ClearAllPoints()
    journal.SearchBox:SetPoint("TOPRIGHT", journal, "TOPRIGHT", -(FILTER_WIDTH + 16), CONTROL_ROW_Y)
    SkinFilterDropdown(journal.FilterDropdown, journal.SearchBox)
    SkinDropdowns(journal.ClassDropdown)
    journal.ClassDropdown:ClearAllPoints()
    journal.ClassDropdown:SetPoint("TOPLEFT", journal, "TOPLEFT", 10, CONTROL_ROW_Y)
    journal.ClassDropdown:SetWidth(CLASS_DROPDOWN_WIDTH)
    SkinProgressBar(journal.progressBar)
    journal.progressBar:ClearAllPoints()
    journal.progressBar:SetPoint("TOP", journal, "TOP", 0, CONTROL_ROW_Y - 4)
    AddProgressBarTooltip(journal.progressBar, HEIRLOOMS)
    local achievements = CreateAchievementStatus(journal, journal.progressBar, COLLECTION_ACHIEVEMENT_CATEGORY, HEIRLOOMS)
    journal:HookScript("OnShow", function() achievements:Update() end)
    SkinPagingFrame(journal.PagingFrame)

    -- entries come from a frame pool: skin on first update, color by ownership on every update
    hooksecurefunc(journal, "UpdateButton", function(_, button)
        SkinSpellButton(button)
        button.levelBackground:SetAlpha(0)
        button.level:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE", 3)
        local owned = button.itemID and C_Heirloom.PlayerHasHeirloom(button.itemID)
        if owned then
            button.name:SetTextColor(1, 1, 1)
            SetBackdropQuality(button, Enum.ItemQuality.Heirloom)
        else
            button.name:SetTextColor(unpack(DISABLED_TEXT))
            button.special:SetTextColor(unpack(DISABLED_TEXT))
            SetBackdropQuality(button, Enum.ItemQuality.Heirloom, true)
        end
        -- the level shares the border color, dimmed with it for heirlooms the player does not own
        button.level:SetTextColor(button.backdrop:GetBackdropBorderColor())
        UpdateHeirloomPips(button, owned)
    end)
    hooksecurefunc(journal, "LayoutCurrentPage", function(self)
        for _, header in ipairs(self.heirloomHeaderFrames) do
            SkinHeirloomHeader(header)
        end
        LayoutHeirloomSections(self)
    end)
end

---------- wardrobe ----------

local function GetModelAppearanceQuality(model)
    local visualID = model.visualInfo and model.visualInfo.visualID
    local sources = visualID and C_TransmogCollection.GetAllAppearanceSources(visualID)
    local info = sources and sources[1] and C_TransmogCollection.GetSourceInfo(sources[1])
    return info and info.quality
end

-- blizzard swaps the border atlas by state, the state becomes our border color
local WARDROBE_BORDER_COLORS = {
    ["transmog-wardrobe-border-uncollected"] = {0.45, 0.45, 0.45},
    ["transmog-wardrobe-border-unusable"] = {0.9, 0.3, 0.3},
}
local function UpdateWardrobeModelBorder(model, atlas)
    local color = WARDROBE_BORDER_COLORS[atlas]
    if color then
        model.backdrop:SetBackdropBorderColor(color[1], color[2], color[3], 1)
        return
    end
    if model.TransmogStateTexture:IsShown() then
        model.backdrop:SetBackdropBorderColor(1, 0.7, 1, 1)
        return
    end
    local quality = GetModelAppearanceQuality(model)
    local qualityColor = quality and GW.GetBagItemQualityColor(quality)
    if qualityColor then
        model.backdrop:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b, 1)
    else
        model.backdrop:SetBackdropBorderColor(unpack(model.gwDefaultBorder))
    end
end

local function SkinWardrobeModel(model)
    if model.gwSkinned then return end
    model.gwSkinned = true

    model:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
    model.gwDefaultBorder = {model.backdrop:GetBackdropBorderColor()}
    model.TransmogStateTexture:SetAlpha(0)
    model.Border:SetAlpha(0)
    hooksecurefunc(model.Border, "SetAtlas", function(_, atlas) UpdateWardrobeModelBorder(model, atlas) end)
    -- the hover glow is an unnamed texture with the transmogrify art
    for _, region in next, {model:GetRegions()} do
        if region:IsObjectType("Texture") then
            local texture = region:GetTexture()
            if texture == 1569530 or (texture == 1116940 and region ~= model.SlotInvalidTexture and region ~= model.DisabledOverlay) then
                region:SetColorTexture(unpack(HIGHLIGHT_COLOR))
                region:SetBlendMode("ADD")
                region:SetAllPoints(model)
            end
        end
    end
end

-- collected / total appearances of the slot a slot button stands for: the armor category of the slot, all
-- weapon categories the hand accepts, or the illusions
local function GetSlotCollectionCounts(button)
    local location = button.transmogLocation
    if location:IsIllusion() then
        local collected, total = 0, 0
        for _, illusion in ipairs(C_TransmogCollection.GetIllusions()) do
            total = total + 1
            if illusion.isCollected then
                collected = collected + 1
            end
        end
        return collected, total
    end
    if location:IsEitherHand() then
        local collected, total = 0, 0
        local mainHand = location:GetSlotName() == "MAINHANDSLOT"
        for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
            local _, isWeapon, _, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryID)
            if isWeapon and ((mainHand and canMainHand) or (not mainHand and canOffHand)) then
                collected = collected + C_TransmogCollection.GetCategoryCollectedCount(categoryID)
                total = total + C_TransmogCollection.GetCategoryTotal(categoryID)
            end
        end
        return collected, total
    end
    local categoryID = location:GetArmorCategoryID()
    return C_TransmogCollection.GetCategoryCollectedCount(categoryID), C_TransmogCollection.GetCategoryTotal(categoryID)
end

-- the slot buttons keep blizzards round icons, idle slots dimmed, the selected one bright with a gold ring
local SLOT_SELECTED_COLOR = {1, 0.82, 0}
local SLOT_IDLE_ALPHA = 0.55
local function SkinWardrobeSlotButton(button)
    if button.gwSkinned then return end
    button.gwSkinned = true

    -- blizzards tooltip only names the slot, the collection progress of the slot goes below it
    button:HookScript("OnEnter", function(self)
        local collected, total = GetSlotCollectionCounts(self)
        if total == 0 then return end
        GameTooltip:AddDoubleLine(COLLECTED, string.format(HEIRLOOMS_PROGRESS_FORMAT, collected, total), 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine(STATUS_TEXT_PERCENT, string.format("%d%%", math.floor(collected / total * 100 + 0.5)), 1, 1, 1, 1, 1, 1)
        GameTooltip:Show()
    end)

    local icon, selected = button.NormalTexture, button.SelectedTexture
    button.Highlight:SetVertexColor(1, 1, 1, 0.6)
    selected:SetVertexColor(SLOT_SELECTED_COLOR[1], SLOT_SELECTED_COLOR[2], SLOT_SELECTED_COLOR[3], 1)
    local function UpdateSelection()
        icon:SetAlpha(selected:IsShown() and 1 or SLOT_IDLE_ALPHA)
    end
    hooksecurefunc(selected, "Show", UpdateSelection)
    hooksecurefunc(selected, "Hide", UpdateSelection)
    hooksecurefunc(selected, "SetShown", UpdateSelection)
    UpdateSelection()
end

-- blizzard (and Extended Transmog Sets, which replaces SetTab and adds a third tab) re-anchor search box, filter,
-- class dropdown and progress bar on every tab change; this runs after each of those and puts everything back.
-- The class dropdown goes into the top left corner of the details background, centered on the slot row
local function LayoutWardrobeControls(frame)
    -- all tabs in the control row, blizzards two and whatever an addon appended (WardrobeCollectionFrameTab3 ...)
    local previous
    for i = 1, 10 do
        local tab = _G["WardrobeCollectionFrameTab" .. i]
        if not tab then break end
        GW.HandleTabs(tab, "top")
        tab:ClearAllPoints()
        if previous then
            tab:SetPoint("LEFT", previous, "RIGHT", 0, 0)
        else
            tab:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, CONTROL_ROW_Y + 2)
        end
        previous = tab
    end
    frame.progressBar:ClearAllPoints()
    frame.progressBar:SetPoint("TOP", frame, "TOP", 0, CONTROL_ROW_Y - 4)
    frame.progressBar:SetWidth(PROGRESS_WIDTH)

    local items, sets = frame.ItemsCollectionFrame, frame.SetsCollectionFrame
    local margin = GetGridMargin(items)
    if items:IsShown() then
        if not AlignControlRow(frame, items, frame.SearchBox) then
            frame.SearchBox:ClearAllPoints()
            frame.SearchBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -(FILTER_WIDTH + 16), CONTROL_ROW_Y)
            -- on the very first show the grid has no screen position yet, align once it has one
            if not frame.gwLayoutRetry then
                frame.gwLayoutRetry = true
                C_Timer.After(0, function()
                    frame.gwLayoutRetry = nil
                    LayoutWardrobeControls(frame)
                end)
            end
        end
        if margin then
            frame.ClassDropdown:ClearAllPoints()
            frame.ClassDropdown:SetPoint("TOPLEFT", items, "TOPLEFT", margin + 10, -26)
            frame.ClassDropdown:SetWidth(CLASS_DROPDOWN_WIDTH)
        end
    elseif sets:IsShown() then
        frame.SearchBox:ClearAllPoints()
        frame.SearchBox:SetPoint("TOPLEFT", sets.LeftInset, "TOPLEFT", 2, -9)
    end
    frame.FilterButton:ClearAllPoints()
    frame.FilterButton:SetWidth(FILTER_WIDTH)
    frame.FilterButton:SetPoint("TOPLEFT", frame.SearchBox, "TOPRIGHT", 6, 1)
    frame.FilterButton:SetPoint("BOTTOMLEFT", frame.SearchBox, "BOTTOMRIGHT", 6, 0)
    if sets:IsShown() then
        frame.FilterButton:SetPoint("RIGHT", sets.ListContainer.ScrollBox, "RIGHT", 0, 0)
    end

    if margin then
        items.gwDetails:ClearAllPoints()
        items.gwDetails:SetPoint("TOPLEFT", items, "TOPLEFT", margin, GRID_SECTION_TOP)
        items.gwDetails:SetPoint("BOTTOMRIGHT", items, "BOTTOMRIGHT", -margin, GRID_SECTION_BOTTOM)
        items.gwDetails:Show()
    end
end

local function SkinWardrobe()
    local frame = WardrobeCollectionFrame
    local items, sets = frame.ItemsCollectionFrame, frame.SetsCollectionFrame

    SkinSearchBox(frame.SearchBox)
    frame.SearchBox:SetFrameLevel(5)
    SkinFilterDropdown(frame.FilterButton)
    SkinDropdowns(frame.ClassDropdown, items.WeaponDropdown, sets.DetailsFrame.VariantSetsDropdown)
    SkinProgressBar(frame.progressBar)
    AddProgressBarTooltip(frame.progressBar, WARDROBE)
    SkinHelpButton(frame.InfoButton)

    StripFrames(items, sets.LeftInset, sets.RightInset)
    items.gwDetails = GW.CreateDetailsBackgroundTexture(items)
    items.gwDetails:Hide()
    LayoutWardrobeControls(frame)
    -- both blizzards SetTab and the Extended Transmog Sets replacement start with PanelTemplates_SetTab; the
    -- rest of their work (anchoring) follows, so the layout runs now and once more a frame later
    hooksecurefunc("PanelTemplates_SetTab", function(self)
        if self ~= frame then return end
        LayoutWardrobeControls(frame)
        C_Timer.After(0, function() LayoutWardrobeControls(frame) end)
    end)
    items:HookScript("OnShow", function() LayoutWardrobeControls(frame) end)

    for _, model in pairs(items.Models) do
        SkinWardrobeModel(model)
    end
    SkinPagingFrame(items.PagingFrame)
    for _, button in ipairs(items.SlotsFrame.Buttons) do
        SkinWardrobeSlotButton(button)
    end
    for _, child in ipairs({items.SlotsFrame:GetChildren()}) do
        if child:IsObjectType("Button") then
            SkinWardrobeSlotButton(child)
        end
    end

    GW.AddDetailsBackground(sets.RightInset, 8, 0)
    SkinScrollList(sets.ListContainer)
    local details = sets.DetailsFrame
    details.ModelFadeTexture:Hide()
    details.IconRowBackground:Hide()
    for _, key in ipairs({"Name", "LongName"}) do
        details[key]:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        details[key]:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end
    details.Label:SetTextColor(1, 1, 1)
    -- the item icons of a set: border in the quality color of the collected source
    hooksecurefunc(sets, "SetItemFrameQuality", function(_, itemFrame)
        local icon = itemFrame.Icon
        if not icon.backdrop then
            BackdropAroundIcon(icon, GW.BackdropTemplates.DefaultWithColorableBorder)
            itemFrame.IconBorder:Hide()
        end
        local source = itemFrame.collected and itemFrame.sourceID and C_TransmogCollection.GetSourceInfo(itemFrame.sourceID)
        local color = source and source.quality and GW.GetBagItemQualityColor(source.quality)
        if color then
            icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b, 1)
        else
            icon.backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        end
    end)
end

---------- warband scenes ----------

local WARBAND_TILE_BORDER = {0.3, 0.3, 0.3}
local function SkinWarbandScenes()
    local journal = WarbandSceneJournal

    StripFrames(journal.IconsFrame)
    local controls = journal.IconsFrame.Icons.Controls
    controls.ShowOwned.Checkbox:GwSkinCheckButton(nil, CHECKBOX_SIZE)
    GW.WhitenFontStrings(controls.ShowOwned)
    for _, child in ipairs({controls.PagingControls:GetChildren()}) do
        if child:IsObjectType("Button") then
            SkinPageButton(child)
        end
    end
    GW.WhitenFontStrings(controls.PagingControls)

    -- the entries are pooled, skin them when their data is set
    hooksecurefunc(WarbandSceneEntryMixin, "UpdateWarbandSceneData", function(entry)
        if entry.gwSkinned then return end
        entry.gwSkinned = true
        entry.Border:SetAlpha(0)
        -- the black frame is baked into the picture texture, the icon helper crops it away
        BackdropAroundIcon(entry.Icon, GW.BackdropTemplates.DefaultWithColorableBorder)
        entry.Icon.backdrop:SetBackdropBorderColor(WARBAND_TILE_BORDER[1], WARBAND_TILE_BORDER[2], WARBAND_TILE_BORDER[3], 1)
        local highlight = entry:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetColorTexture(unpack(HIGHLIGHT_COLOR))
        highlight:SetAllPoints(entry.Icon)
        entry:SetHighlightTexture(highlight)
        GW.WhitenFontStrings(entry)
    end)
end

---------- the journal frame ----------

local function collectionsSkin()
    local journal = CollectionsJournal
    GW.HandlePortraitFrame(journal)
    GW.CreateFrameHeaderWithBody(journal, journal.TitleContainer.TitleText, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon.png", nil, nil, false, true)

    journal:SetClampedToScreen(true)
    journal:SetClampRectInsets(0, 0, journal.gwHeader:GetHeight() - 20, 0)
    journal.CloseButton:ClearAllPoints()
    journal.CloseButton:SetPoint("TOPRIGHT", -10, -2)

    SkinJournalTabs()
    SkinMountJournal()
    SkinPetJournal()
    SkinToyBox()
    SkinHeirlooms()
    SkinWardrobe()
    SkinWarbandScenes()
end

local function LoadCollectionsSkin()
    if not GW.settings.COLLECTIONS_SKIN_ENABLED then
        return
    end
    GW.RegisterLoadHook(collectionsSkin, "Blizzard_Collections", CollectionsJournal)
end
GW.LoadCollectionsSkin = LoadCollectionsSkin

-- pieces the addon skins for the collections journal build on (Extended Transmog Sets)
GW.CollectionsSkin = {
    SkinListRow = SkinListRow,
    SkinFilterDropdown = SkinFilterDropdown,
    SkinDropdowns = SkinDropdowns,
    SkinSearchBox = SkinSearchBox,
}
