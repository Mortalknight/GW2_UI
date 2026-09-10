---@class GW2
local GW = select(2, ...)

-- Collections journal: frame, tabs, mounts, pets, toys, heirlooms, wardrobe items and sets, warband scenes.
-- Our header covers the top 32 units, blizzards control row there moves into the band above the insets.

local ICON_TEXCOORDS = {0.1, 0.9, 0.1, 0.9}
local SELECTED_COLOR = {0.5, 0.5, 0.5, 0.25}
local HIGHLIGHT_COLOR = {1, 1, 1, 0.25}
local ACTIVE_COLOR = {0.9, 0.8, 0.1, 0.3}
local DISABLED_TEXT = {0.4, 0.4, 0.4}
local PROGRESS_COLOR = {0.32, 0.68, 0.32}
local STATUSBAR_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png"
local XP_COLOR = {0.35, 0.55, 0.9}
local FILTER_WIDTH = 90
local CONTROL_ROW_Y = -36
local CONTROL_HEIGHT = 20
local CHECKBOX_SIZE = 15

---------- small shared pieces ----------

-- the help tooltip is a glow box, blanked textures stay invisible when blizzard shows the arrows
local function SkinHelpPlateTooltip()
    local tooltip = HelpPlateTooltip
    if not tooltip or tooltip.gwSkinned then return end
    tooltip.gwSkinned = true
    tooltip:GwStripTextures()
    tooltip:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    if tooltip.Text then
        tooltip.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        tooltip.Text:SetTextColor(1, 1, 1)
    end
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
            if self.Arrow then
                self.Arrow:SetAlpha(1)
            end
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
    if frame.Arrow then
        frame.Arrow:SetAlpha(0)
    end
end

local function HookHelpTips()
    if not HelpTip or HelpTip.gwHooked or not HelpTip.Show then return end
    HelpTip.gwHooked = true
    hooksecurefunc(HelpTip, "Show", function(self, parent)
        if not skinnedHelpButtons[parent] or not self.framePool then return end
        for frame in self.framePool:EnumerateActive() do
            if frame:GetParent() == parent then
                StyleHelpTipFrame(frame)
            end
        end
    end)
end

local HELP_BUTTON_SIZE = 20
local function SkinHelpButton(button)
    if not button then return end
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
    local close = CollectionsJournal.CloseButton
    if close then
        button:SetPoint("RIGHT", close, "LEFT", -6, 0)
    else
        button:SetPoint("TOPRIGHT", CollectionsJournal, "TOPRIGHT", -40, -2)
    end
end

local function SkinSearchBox(box)
    if not box or box.gwSkinned then return end
    box.gwSkinned = true
    GW.SkinTextBox(box.Middle, box.Left, box.Right)
end

-- xp bars have no color of their own and would vanish white on the gray background
local function SkinStatusBar(bar, artFrame, color)
    if not bar or bar.gwSkinned then return end
    bar.gwSkinned = true
    if artFrame and artFrame ~= bar then
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

local function SkinProgressBar(bar)
    if not bar or bar.gwSkinned then return end
    bar.gwSkinned = true
    if bar.border then
        bar.border:Hide()
    end
    bar:GwStripTextures()
    GW.AddStatusBarFrame(bar)
    bar:SetHeight(12)
    bar:SetStatusBarTexture(STATUSBAR_TEXTURE)
    bar:SetStatusBarColor(unpack(PROGRESS_COLOR))
    if bar.text then
        bar.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        bar.text:SetTextColor(1, 1, 1)
    end
end

-- the helper would resize the arrows and misalign the page text
local function SkinPageButton(button, direction)
    if not button then return end
    local width, height = button:GetSize()
    GW.HandleNextPrevButton(button, direction)
    button:SetSize(width, height)
end

local function SkinPagingFrame(paging)
    if not paging or paging.gwSkinned then return end
    paging.gwSkinned = true
    SkinPageButton(paging.PrevPageButton, "left")
    SkinPageButton(paging.NextPageButton, "right")
    if paging.PageText then
        paging.PageText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        paging.PageText:SetTextColor(1, 1, 1)
    end
end

-- the filter template relayouts itself on hover, the dropdown helper needs the layout hook for it
local function SkinFilterDropdown(dropdown, anchorTo, rightEdge)
    if not dropdown then return end
    dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, FILTER_WIDTH)
    dropdown:SetSize(FILTER_WIDTH, CONTROL_HEIGHT)
    dropdown.backdrop:ClearAllPoints()
    dropdown.backdrop:SetPoint("TOPLEFT", dropdown, "TOPLEFT", 0, 0)
    dropdown.backdrop:SetPoint("BOTTOMRIGHT", dropdown, "BOTTOMRIGHT", 0, 0)
    local reset = dropdown.ResetButton or dropdown.ClearFiltersButton
    if reset then
        reset:GwSkinButton(true)
        reset:SetSize(14, 14)
        reset:ClearAllPoints()
        reset:SetPoint("CENTER", dropdown, "TOPRIGHT", -2, -2)
    end
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
        if dropdown then
            -- a dropdown without a size yet keeps the helper default instead of collapsing to 0
            local width = dropdown:GetWidth()
            dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, width and width > 1 and width or nil)
            dropdown:SetHeight(CONTROL_HEIGHT)
            dropdown.backdrop:ClearAllPoints()
            dropdown.backdrop:SetPoint("TOPLEFT", dropdown, "TOPLEFT", 0, 0)
            dropdown.backdrop:SetPoint("BOTTOMRIGHT", dropdown, "BOTTOMRIGHT", 0, 0)
        end
    end
end

local function StripFrames(...)
    for i = 1, select("#", ...) do
        local frame = select(i, ...)
        if frame then
            frame:GwStripTextures()
        end
    end
end

local function KeepLabelWhite(text)
    if not text or text.gwWhiteHooked then return end
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
    if not counter or counter.gwSkinned then return end
    counter.gwSkinned = true
    counter:GwStripTextures()
    GW.AddDetailsBackground(counter)
    GW.WhitenFontStrings(counter)

    local label, count = counter.Label, counter.Count
    if label and count then
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
end

local SPELL_BUTTON_SIZE = 26
local function SkinSpellFrame(frame)
    if not frame or frame.gwSkinned then return end
    frame.gwSkinned = true
    if frame.Button then
        GW.HandleItemButton(frame.Button, true)
        frame.Button:SetSize(SPELL_BUTTON_SIZE, SPELL_BUTTON_SIZE)
    end
    frame:SetHeight(SPELL_BUTTON_SIZE)
    GW.WhitenFontStrings(frame)
end

-- the plain backdrop would cover the icon's parent
local function BackdropAroundIcon(icon, template)
    GW.HandleIcon(icon, true, template or GW.BackdropTemplates.DefaultWithSmallBorder, true)
    return icon.backdrop
end

local function SkinIconButton(button)
    if not button then return end
    local icon = button.icon or button.Icon
    if icon then
        BackdropAroundIcon(icon)
    end
    button:GwStyleButton()
end

local function SetColorTextureSafe(texture, color)
    if texture then
        texture:SetColorTexture(unpack(color))
    end
end

-- the slot frames are killed for good, blizzards update code shows and fades them in again
local function SkinSpellButton(button)
    if not button or button.gwSkinned then return end
    button.gwSkinned = true

    for _, key in ipairs({"slotFrameCollected", "slotFrameUncollected", "slotFrameUncollectedInnerGlow"}) do
        if button[key] then
            button[key]:GwKill()
        end
    end
    local icon = button.iconTexture
    if icon then
        icon:SetTexCoord(unpack(ICON_TEXCOORDS))
        button.backdrop = BackdropAroundIcon(icon, GW.BackdropTemplates.DefaultWithColorableBorder)
        button.gwDefaultBorder = {button.backdrop:GetBackdropBorderColor()}
    end
    if button.iconTextureUncollected then
        button.iconTextureUncollected:SetTexCoord(unpack(ICON_TEXCOORDS))
    end
    button:GwStyleButton()
    if icon then
        for _, key in ipairs({"hover", "pushed", "checked"}) do
            if button[key] then
                button[key]:SetAllPoints(icon)
            end
        end
    end
    if button.cooldown then
        button.cooldown:SetAllPoints(icon or button)
    end
end

local UNOWNED_DIM = 0.45
local function SetBackdropQuality(frame, quality, dimmed)
    if not frame.backdrop then return end
    local color = quality and GW.GetBagItemQualityColor(quality)
    if color then
        local factor = dimmed and UNOWNED_DIM or 1
        frame.backdrop:SetBackdropBorderColor(color.r * factor, color.g * factor, color.b * factor, 1)
    elseif frame.gwDefaultBorder then
        frame.backdrop:SetBackdropBorderColor(unpack(frame.gwDefaultBorder))
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
    local name = row.name
    if not name then return end
    local textColor, borderColor = {1, 1, 1}, ROW_BORDER_DARK
    if name:GetFontObject() == GameFontDisable then
        textColor, borderColor = DISABLED_TEXT, ROW_BORDER_LIGHT
    elseif row.background then
        local _, g, b = row.background:GetVertexColor()
        if g == 0 and b == 0 then
            textColor, borderColor = {0.9, 0.3, 0.3}, ROW_BORDER_RED
        end
    end
    name:SetTextColor(unpack(textColor))
    if row.factionIcon and row.icon and row.icon.backdrop then
        row.icon.backdrop:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], 1)
    end
end

local function SkinListRow(row)
    if row.gwSkinned then return end
    row.gwSkinned = true

    local icon = row.icon or (row.IconFrame and row.IconFrame.Icon)

    -- the pill is blanked, not alpha 0: blizzard sets its vertex color with alpha 1 on every update
    if row.background then
        row.background:SetTexture()
    end
    local highlight = row.GetHighlightTexture and row:GetHighlightTexture()
    if highlight then
        highlight:SetAlpha(0)
    end
    SetColorTextureSafe(row.selectedTexture or row.SelectedTexture, SELECTED_COLOR)

    if icon then
        BackdropAroundIcon(icon, GW.BackdropTemplates.DefaultWithColorableBorder)
        if row.iconBorder and not row.factionIcon then
            GW.HandleIconBorder(row.iconBorder, icon.backdrop)
        end
    end

    local drag = row.DragButton or row.dragButton
    if drag then
        SetColorTextureSafe(drag.ActiveTexture, ACTIVE_COLOR)
        local dragHighlight = drag:GetHighlightTexture()
        if dragHighlight and icon then
            dragHighlight:SetColorTexture(unpack(HIGHLIGHT_COLOR))
            dragHighlight:SetAllPoints(icon)
        end
        if drag.levelBG then
            drag.levelBG:SetAlpha(0)
        end
        if drag.level then
            drag.level:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        end
    end

    if row.name then
        UpdateRowNameColor(row)
        hooksecurefunc(row.name, "SetFontObject", function() UpdateRowNameColor(row) end)
        if row.background then
            hooksecurefunc(row.background, "SetVertexColor", function() UpdateRowNameColor(row) end)
        end
    end
    local iconFrame = row.IconFrame
    if iconFrame and iconFrame.Icon and iconFrame.Icon.backdrop then
        local function UpdateSetBorder()
            local color = ROW_BORDER_LIGHT
            local _, g, b = iconFrame.Icon:GetVertexColor()
            if g and g < 0.5 and b and b < 0.5 then
                color = ROW_BORDER_RED
            elseif iconFrame.Cover and iconFrame.Cover:IsShown() then
                color = ROW_BORDER_DARK
            end
            iconFrame.Icon.backdrop:SetBackdropBorderColor(color[1], color[2], color[3], 1)
        end
        if iconFrame.SetIconCoverShown then
            hooksecurefunc(iconFrame, "SetIconCoverShown", UpdateSetBorder)
        end
        if iconFrame.SetIconColor then
            hooksecurefunc(iconFrame, "SetIconColor", UpdateSetBorder)
        end
        UpdateSetBorder()
    end
    if row.ProgressBar then
        row.ProgressBar:SetTexture(STATUSBAR_TEXTURE)
        row.ProgressBar:SetVertexColor(0.25, 0.75, 0.25, 1)
    end
end

local function SkinScrollList(container)
    if not container or not container.ScrollBox or container.gwListSkinned then return end
    container.gwListSkinned = true
    GW.HandleTrimScrollBar(container.ScrollBar)
    GW.HandleScrollControls(container)
    -- the wide skinned bar leans into the gap between list and details
    container.ScrollBar:ClearAllPoints()
    container.ScrollBar:SetPoint("TOPLEFT", container.ScrollBox, "TOPRIGHT", 10, 31)
    container.ScrollBar:SetPoint("BOTTOMLEFT", container.ScrollBox, "BOTTOMRIGHT", 10, -1)
    hooksecurefunc(container.ScrollBox, "Update", function(scrollBox)
        GW.HandleItemListScrollBoxHover(scrollBox)
        for _, row in next, {scrollBox.ScrollTarget:GetChildren()} do
            SkinListRow(row)
        end
    end)
end

---------- the tabs at the bottom of the journal ----------

-- blizzard overlaps its tabs by 16 units
local function LayoutJournalTabs()
    local previous
    for i = 1, 6 do
        local tab = _G["CollectionsJournalTab" .. i]
        if tab and tab:IsShown() then
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
        local tab = _G["CollectionsJournalTab" .. i]
        if tab then
            GW.HandleTabs(tab)
        end
    end
    LayoutJournalTabs()
    -- blizzard re-anchors the wardrobe tab whenever the heirlooms tab toggles
    hooksecurefunc("CollectionsJournal_CheckAndDisplayHeirloomsTab", LayoutJournalTabs)
end

---------- mount journal ----------

local function SkinFlyoutButton(button)
    if not button or button.gwSkinned then return end
    button.gwSkinned = true

    local normal = button.GetNormalTexture and button:GetNormalTexture()
    local pushed = button.GetPushedTexture and button:GetPushedTexture()
    local highlight = button.GetHighlightTexture and button:GetHighlightTexture()
    if normal then normal:SetAlpha(0) end
    if pushed then pushed:SetAlpha(0) end
    if highlight then
        highlight:SetColorTexture(unpack(HIGHLIGHT_COLOR))
    end

    -- the ring art has keys, the icon is the remaining texture region
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
        if highlight then
            highlight:ClearAllPoints()
            highlight:SetAllPoints(icon)
        end
    end
    button:SetSize(SPELL_BUTTON_SIZE, SPELL_BUTTON_SIZE)
    GW.WhitenFontStrings(button)
end

local function SkinMountJournal()
    local journal = MountJournal
    if not journal then return end

    StripFrames(journal, journal.LeftInset, journal.RightInset, journal.BottomLeftInset)
    GW.AddDetailsBackground(journal.BottomLeftInset)
    SkinCounter(journal.MountCount)
    journal.MountCount:ClearAllPoints()
    journal.MountCount:SetPoint("BOTTOMLEFT", journal.LeftInset, "TOPLEFT", 2, 4)

    SkinSearchBox(journal.searchBox)
    journal.searchBox:ClearAllPoints()
    journal.searchBox:SetPoint("TOPLEFT", journal.LeftInset, "TOPLEFT", 2, -9)
    SkinFilterDropdown(journal.FilterDropdown, journal.searchBox, journal.ScrollBox)
    SkinScrollList(journal)
    journal.MountButton:GwSkinButton(false, true)

    local summon = journal.SummonRandomFavoriteSpellFrame
    SkinSpellFrame(summon)
    if summon then
        summon:ClearAllPoints()
        summon:SetPoint("TOPRIGHT", journal, "TOPRIGHT", -8, CONTROL_ROW_Y + 2)
    end
    SkinFlyoutButton(journal.ToggleDynamicFlightFlyoutButton)
    local popup = journal.DynamicFlightFlyoutPopup
    if popup then
        if popup.Background then
            popup.Background:Hide()
        end
        SkinFlyoutButton(popup.DynamicFlightModeButton)
        SkinFlyoutButton(popup.OpenDynamicFlightSkillTreeButton)
    end

    local display = journal.MountDisplay
    if display then
        StripFrames(display, display.ShadowOverlay)
        -- after the strip, otherwise the details background would be blanked with the rest
        if display.InfoButton then
            display.InfoButton:GwNudgePoint(8, 0)
        end
        GW.AddDetailsBackground(display, 10, -2)
        if display.ModelScene then
            -- the mount hangs out left over the list, pull the scene's left edge in
            display.ModelScene:ClearAllPoints()
            display.ModelScene:SetPoint("TOPLEFT", display, "TOPLEFT", 40, 0)
            display.ModelScene:SetPoint("BOTTOMRIGHT", display, "BOTTOMRIGHT", 0, 0)
            GW.HandleModelSceneControlFrame(display.ModelScene.ControlFrame)
            local toggle = display.ModelScene.TogglePlayer
            if toggle then
                toggle:GwSkinCheckButton(nil, CHECKBOX_SIZE)
                if toggle.TogglePlayerText then
                    toggle.TogglePlayerText:SetTextColor(1, 1, 1)
                end
            end
        end
        local info = display.InfoButton
        if info then
            if info.Icon then
                BackdropAroundIcon(info.Icon)
            end
            for _, key in ipairs({"Name", "Source", "Lore"}) do
                if info[key] then
                    info[key]:SetTextColor(1, 1, 1)
                end
            end
        end
    end

    local slot = journal.BottomLeftInset and journal.BottomLeftInset.SlotButton
    if slot then
        slot:GwStripTextures()
        if slot.ItemIcon then
            BackdropAroundIcon(slot.ItemIcon)
        end
        slot:GwStyleButton()
    end
    if journal.BottomLeftInset then
        KeepLabelWhite(journal.BottomLeftInset.SlotLabel)
        KeepLabelWhite(journal.BottomLeftInset.SlotRequirementLabel)
    end
end

---------- pet journal ----------

local function SkinLoadoutPet(pet)
    if not pet or pet.gwSkinned then return end
    pet.gwSkinned = true

    if pet.shadows then pet.shadows:SetAlpha(0) end
    if pet.iconBorder then pet.iconBorder:SetAlpha(0) end
    if pet.levelBG then pet.levelBG:SetAlpha(0) end
    if pet.level then
        pet.level:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    end
    if pet.icon then
        BackdropAroundIcon(pet.icon, GW.BackdropTemplates.DefaultWithColorableBorder)
        if pet.qualityBorder then
            GW.HandleIconBorder(pet.qualityBorder, pet.icon.backdrop)
        end
    end
    pet:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    local highlight = pet:GetHighlightTexture()
    if highlight and pet.icon then
        highlight:SetColorTexture(unpack(HIGHLIGHT_COLOR))
        highlight:SetAllPoints(pet.icon)
    end
    StripFrames(pet.helpFrame, pet.setButton)
    if pet.healthFrame then
        SkinStatusBar(pet.healthFrame.healthBar, pet.healthFrame)
    end
    SkinStatusBar(pet.xpBar, nil, XP_COLOR)
    for i = 1, 3 do
        local spell = pet["spell" .. i]
        if spell then
            SkinIconButton(spell)
            if spell.FlyoutArrow then
                spell.FlyoutArrow:SetTexture("Interface/Buttons/ActionBarFlyoutButton")
            end
        end
    end
end

local function SkinPetCard(card)
    if not card or card.gwSkinned then return end
    card.gwSkinned = true

    card:GwStripTextures()
    local info = card.PetInfo
    if info then
        info:GwNudgePoint(8, 0)
    end
    GW.AddDetailsBackground(card, 10, -2)
    if info then
        if info.levelBG then info.levelBG:SetAlpha(0) end
        if info.level then
            info.level:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        end
        if info.icon then
            BackdropAroundIcon(info.icon, GW.BackdropTemplates.DefaultWithColorableBorder)
            if info.qualityBorder then
                GW.HandleIconBorder(info.qualityBorder, info.icon.backdrop)
            end
        end
    end
    for i = 1, 6 do
        SkinIconButton(card["spell" .. i])
    end
    if card.HealthFrame then
        SkinStatusBar(card.HealthFrame.healthBar, card.HealthFrame)
    end
    SkinStatusBar(card.xpBar, nil, XP_COLOR)
end

local function SkinPetJournal()
    local journal = PetJournal
    if not journal then return end

    StripFrames(journal.LeftInset, journal.RightInset, journal.PetCardInset, journal.loadoutBorder, journal.SpellSelect)
    GW.AddDetailsBackground(journal.RightInset)
    SkinHelpButton(journal.MainHelpButton)
    if journal.loadoutBorder then
        for _, region in next, {journal.loadoutBorder:GetRegions()} do
            if region:IsObjectType("FontString") then
                region:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
                region:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
                region:GwNudgePoint(0, 8)
            end
        end
    end
    SkinCounter(journal.PetCount)
    journal.PetCount:ClearAllPoints()
    journal.PetCount:SetPoint("BOTTOMLEFT", journal.LeftInset, "TOPLEFT", 2, 4)
    if journal.AchievementStatus then
        journal.AchievementStatus:DisableDrawLayer("BACKGROUND")
        journal.AchievementStatus:SetHeight(20)
        journal.AchievementStatus:ClearAllPoints()
        journal.AchievementStatus:SetPoint("LEFT", journal.PetCount, "RIGHT", 10, 0)
        GW.WhitenFontStrings(journal.AchievementStatus)
    end

    SkinSearchBox(journal.searchBox)
    journal.searchBox:ClearAllPoints()
    journal.searchBox:SetPoint("TOPLEFT", journal.LeftInset, "TOPLEFT", 2, -9)
    SkinFilterDropdown(journal.FilterDropdown, journal.searchBox, journal.ScrollBox)
    SkinScrollList(journal)
    journal.SummonButton:GwSkinButton(false, true)
    journal.FindBattleButton:GwSkinButton(false, true)

    local heal, summon = journal.HealPetSpellFrame, journal.SummonRandomPetSpellFrame
    SkinSpellFrame(heal)
    SkinSpellFrame(summon)
    if heal then
        heal:ClearAllPoints()
        heal:SetPoint("TOPRIGHT", journal, "TOPRIGHT", -8, CONTROL_ROW_Y + 2)
    end
    if summon and heal then
        summon:ClearAllPoints()
        summon:SetPoint("RIGHT", heal, "LEFT", -10, 0)
    end

    if journal.Loadout then
        for i = 1, 3 do
            SkinLoadoutPet(journal.Loadout["Pet" .. i])
        end
    end
    if journal.SpellSelect then
        SkinIconButton(journal.SpellSelect.Spell1)
        SkinIconButton(journal.SpellSelect.Spell2)
    end
    SkinPetCard(journal.PetCard)
end

---------- grids (toys, heirlooms) ----------

-- Blizzard lays the toy and heirloom grids out around a 625 wide column (the heirloom header width),
-- details backgrounds and control row follow that column
local GRID_CONTENT_WIDTH = 625
local GRID_SECTION_PAD = 10
local GRID_SECTION_TOP = -15 -- the first heirloom header sits at -25, plus the pad
local GRID_SECTION_BOTTOM = 80 -- leaves room for the paging row

local function GetGridMargin(icons)
    local width = icons:GetWidth()
    if not width or width == 0 then return nil end
    return (width - GRID_CONTENT_WIDTH) / 2 - GRID_SECTION_PAD
end

local function AlignControlRow(frame, icons, searchBox, leftControl)
    local margin = GetGridMargin(icons)
    if not margin or not icons:GetLeft() or not frame:GetLeft() then return false end
    local sectionLeft = icons:GetLeft() + margin - frame:GetLeft()
    local sectionRight = frame:GetRight() - (icons:GetRight() - margin)
    if leftControl then
        leftControl:ClearAllPoints()
        leftControl:SetPoint("TOPLEFT", frame, "TOPLEFT", sectionLeft - 5, CONTROL_ROW_Y)
    end
    searchBox:ClearAllPoints()
    searchBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -(sectionRight + FILTER_WIDTH + 6), CONTROL_ROW_Y)
    return true
end

---------- toy box ----------

local function SkinToyBox()
    local box = ToyBox
    if not box then return end

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
        AlignControlRow(box, box.iconsFrame, box.searchBox)
    end
    box:HookScript("OnShow", LayoutToyGrid)
    LayoutToyGrid()
    SkinProgressBar(box.progressBar)
    box.progressBar:ClearAllPoints()
    box.progressBar:SetPoint("TOP", box, "TOP", 0, CONTROL_ROW_Y - 4)
    SkinPagingFrame(box.PagingFrame)
    for i = 1, 18 do
        local button = box.iconsFrame["spellButton" .. i]
        SkinSpellButton(button)
        if button then
            if button.name then
                hooksecurefunc(button.name, "SetTextColor", RecolorCollectionText)
            end
            if button.new then
                hooksecurefunc(button.new, "SetTextColor", RecolorCollectionText)
            end
        end
    end

    hooksecurefunc("ToySpellButton_UpdateButton", function(button)
        local itemID = button.itemID
        if not itemID or itemID == -1 then return end
        local quality = C_Item.GetItemQualityByID(itemID)
        SetBackdropQuality(button, quality, not PlayerHasToy(itemID))
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
    for _, header in ipairs(journal.heirloomHeaderFrames or {}) do
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
    local firstEntry = journal.heirloomEntryFrames and journal.heirloomEntryFrames[1]
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

    for i = used + 1, #(journal.gwSectionBackgrounds or {}) do
        journal.gwSectionBackgrounds[i]:Hide()
    end

    if not journal.gwControlsAligned then
        journal.gwControlsAligned = AlignControlRow(journal, icons, journal.SearchBox, journal.ClassDropdown)
    end
end

local function SkinHeirlooms()
    local journal = HeirloomsJournal
    if not journal then return end

    StripFrames(journal.iconsFrame)
    SkinSearchBox(journal.SearchBox)
    journal.SearchBox:ClearAllPoints()
    journal.SearchBox:SetPoint("TOPRIGHT", journal, "TOPRIGHT", -(FILTER_WIDTH + 16), CONTROL_ROW_Y)
    SkinFilterDropdown(journal.FilterDropdown, journal.SearchBox)
    SkinDropdowns(journal.ClassDropdown)
    journal.ClassDropdown:ClearAllPoints()
    journal.ClassDropdown:SetPoint("TOPLEFT", journal, "TOPLEFT", 10, CONTROL_ROW_Y)
    SkinProgressBar(journal.progressBar)
    journal.progressBar:ClearAllPoints()
    journal.progressBar:SetPoint("TOP", journal, "TOP", 0, CONTROL_ROW_Y - 4)
    SkinPagingFrame(journal.PagingFrame)

    hooksecurefunc(journal, "UpdateButton", function(_, button)
        SkinSpellButton(button)
        if button.levelBackground then
            button.levelBackground:SetAlpha(0)
        end
        local owned = button.itemID and C_Heirloom.PlayerHasHeirloom(button.itemID)
        if owned then
            button.name:SetTextColor(1, 1, 1)
            if button.level then button.level:SetTextColor(1, 1, 1) end
            SetBackdropQuality(button, Enum.ItemQuality.Heirloom)
        else
            button.name:SetTextColor(unpack(DISABLED_TEXT))
            if button.level then button.level:SetTextColor(unpack(DISABLED_TEXT)) end
            if button.special then button.special:SetTextColor(unpack(DISABLED_TEXT)) end
            SetBackdropQuality(button, Enum.ItemQuality.Heirloom, true)
        end
    end)
    hooksecurefunc(journal, "LayoutCurrentPage", function(self)
        for _, header in ipairs(self.heirloomHeaderFrames or {}) do
            if header.text and not header.gwSkinned then
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
        end
        LayoutHeirloomSections(self)
    end)
end

---------- wardrobe ----------

local function GetModelAppearanceQuality(model)
    local visualID = model.visualInfo and model.visualInfo.visualID
    if not visualID or not C_TransmogCollection.GetAllAppearanceSources then return nil end
    local sources = C_TransmogCollection.GetAllAppearanceSources(visualID)
    local sourceID = sources and sources[1]
    local info = sourceID and C_TransmogCollection.GetSourceInfo(sourceID)
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
    if model.TransmogStateTexture and model.TransmogStateTexture:IsShown() then
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
    if not model or model.gwSkinned then return end
    model.gwSkinned = true

    model:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
    model.gwDefaultBorder = {model.backdrop:GetBackdropBorderColor()}
    if model.TransmogStateTexture then
        model.TransmogStateTexture:SetAlpha(0)
    end
    if model.Border then
        model.Border:SetAlpha(0)
        hooksecurefunc(model.Border, "SetAtlas", function(_, atlas) UpdateWardrobeModelBorder(model, atlas) end)
    end
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

local SLOT_SELECTED_COLOR = {1, 0.82, 0}
local SLOT_IDLE_ALPHA = 0.55
local function SkinWardrobeSlotButton(button)
    if not button or button.gwSkinned then return end
    button.gwSkinned = true

    local icon = button.NormalTexture
    local selected = button.SelectedTexture
    local highlight = button.Highlight or (button.GetHighlightTexture and button:GetHighlightTexture())
    if highlight then
        highlight:SetVertexColor(1, 1, 1, 0.6)
    end
    if selected then
        selected:SetVertexColor(SLOT_SELECTED_COLOR[1], SLOT_SELECTED_COLOR[2], SLOT_SELECTED_COLOR[3], 1)
        local function UpdateSelection()
            if icon then
                icon:SetAlpha(selected:IsShown() and 1 or SLOT_IDLE_ALPHA)
            end
        end
        hooksecurefunc(selected, "Show", UpdateSelection)
        hooksecurefunc(selected, "Hide", UpdateSelection)
        hooksecurefunc(selected, "SetShown", UpdateSelection)
        UpdateSelection()
    end
end

-- blizzard re-anchors search box, filter and class dropdown on every tab change
local WARDROBE_CLASS_DROPDOWN_WIDTH = 100
local WARDROBE_PROGRESS_WIDTH = 150
local function LayoutWardrobeControls(frame)
    local itemsTab = frame.ItemsTab
    if itemsTab then
        itemsTab:ClearAllPoints()
        itemsTab:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, CONTROL_ROW_Y + 2)
    end
    if not frame.SearchBox then return end

    local onItemsTab = frame.selectedCollectionTab == 1 or (frame.ItemsCollectionFrame and frame.ItemsCollectionFrame:IsShown())
    if onItemsTab then
        if not AlignControlRow(frame, frame.ItemsCollectionFrame, frame.SearchBox) then
            frame.SearchBox:ClearAllPoints()
            frame.SearchBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -(FILTER_WIDTH + 16), CONTROL_ROW_Y)
        end
        -- the spot below the slot row belongs to the weapon dropdown
        if frame.ClassDropdown then
            frame.ClassDropdown:ClearAllPoints()
            frame.ClassDropdown:SetPoint("TOPRIGHT", frame.SearchBox, "TOPLEFT", -6, 1)
            frame.ClassDropdown:SetPoint("BOTTOMRIGHT", frame.SearchBox, "BOTTOMLEFT", -6, 0)
            frame.ClassDropdown:SetWidth(WARDROBE_CLASS_DROPDOWN_WIDTH)
        end
        if frame.progressBar and frame.ClassDropdown then
            frame.progressBar:ClearAllPoints()
            frame.progressBar:SetPoint("RIGHT", frame.ClassDropdown, "LEFT", -8, 0)
            frame.progressBar:SetWidth(WARDROBE_PROGRESS_WIDTH)
        end
    elseif frame.SetsCollectionFrame and frame.SetsCollectionFrame.LeftInset then
        frame.SearchBox:ClearAllPoints()
        frame.SearchBox:SetPoint("TOPLEFT", frame.SetsCollectionFrame.LeftInset, "TOPLEFT", 2, -9)
        if frame.progressBar then
            frame.progressBar:ClearAllPoints()
            frame.progressBar:SetPoint("TOP", frame, "TOP", 0, CONTROL_ROW_Y - 4)
        end
    end
    if frame.FilterButton then
        frame.FilterButton:ClearAllPoints()
        frame.FilterButton:SetPoint("TOPLEFT", frame.SearchBox, "TOPRIGHT", 6, 1)
        frame.FilterButton:SetPoint("BOTTOMLEFT", frame.SearchBox, "BOTTOMRIGHT", 6, 0)
        local setsList = not onItemsTab and frame.SetsCollectionFrame and frame.SetsCollectionFrame.ListContainer
        if setsList and setsList.ScrollBox then
            frame.FilterButton:SetPoint("RIGHT", setsList.ScrollBox, "RIGHT", 0, 0)
        end
    end

    local items = frame.ItemsCollectionFrame
    if items and items.gwDetails then
        local margin = GetGridMargin(items)
        if margin then
            items.gwDetails:ClearAllPoints()
            items.gwDetails:SetPoint("TOPLEFT", items, "TOPLEFT", margin, GRID_SECTION_TOP)
            items.gwDetails:SetPoint("BOTTOMRIGHT", items, "BOTTOMRIGHT", -margin, GRID_SECTION_BOTTOM)
            items.gwDetails:Show()
        end
    end
end

local function SkinWardrobe()
    local frame = WardrobeCollectionFrame
    if not frame then return end

    SkinSearchBox(frame.SearchBox)
    frame.SearchBox:SetFrameLevel(5)
    SkinFilterDropdown(frame.FilterButton)
    SkinDropdowns(frame.ClassDropdown)
    SkinProgressBar(frame.progressBar)
    SkinHelpButton(frame.InfoButton)
    for _, tab in ipairs({frame.ItemsTab, frame.SetsTab}) do
        if tab then
            GW.HandleTabs(tab, "top")
        end
    end
    if frame.SetsTab and frame.ItemsTab then
        frame.SetsTab:ClearAllPoints()
        frame.SetsTab:SetPoint("LEFT", frame.ItemsTab, "RIGHT", 0, 0)
    end
    LayoutWardrobeControls(frame)
    if frame.SetTab then
        hooksecurefunc(frame, "SetTab", LayoutWardrobeControls)
    end

    for _, content in ipairs(frame.ContentFrames or {}) do
        if content.Models then
            for _, model in pairs(content.Models) do
                SkinWardrobeModel(model)
            end
        end
        SkinPagingFrame(content.PagingFrame)
    end

    local items = frame.ItemsCollectionFrame
    if items then
        StripFrames(items)
        items.gwDetails = GW.CreateDetailsBackgroundTexture(items)
        items.gwDetails:Hide()
        SkinDropdowns(items.WeaponDropdown)
        if items.SlotsFrame then
            for _, button in ipairs(items.SlotsFrame.Buttons or {}) do
                SkinWardrobeSlotButton(button)
            end
            for _, child in ipairs({items.SlotsFrame:GetChildren()}) do
                if child:IsObjectType("Button") then
                    SkinWardrobeSlotButton(child)
                end
            end
        end
        items:HookScript("OnShow", function() LayoutWardrobeControls(frame) end)
    end
    if frame.progressBar and not frame.ClassDropdown then
        frame.progressBar:ClearAllPoints()
        frame.progressBar:SetPoint("TOP", frame, "TOP", 0, CONTROL_ROW_Y - 4)
    end

    local sets = frame.SetsCollectionFrame
    if sets then
        StripFrames(sets.LeftInset, sets.RightInset)
        GW.AddDetailsBackground(sets.RightInset, 8, 0)
        SkinScrollList(sets.ListContainer)
        local details = sets.DetailsFrame
        if details then
            if details.ModelFadeTexture then details.ModelFadeTexture:Hide() end
            if details.IconRowBackground then details.IconRowBackground:Hide() end
            if details.Name then details.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header) end
            if details.LongName then details.LongName:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header) end
            if details.Label then details.Label:SetTextColor(1, 1, 1) end
            SkinDropdowns(details.VariantSetsDropdown)
        end
        if sets.SetItemFrameQuality then
            hooksecurefunc(sets, "SetItemFrameQuality", function(_, itemFrame)
                local icon = itemFrame.Icon
                if not icon then return end
                if not icon.backdrop then
                    BackdropAroundIcon(icon, GW.BackdropTemplates.DefaultWithColorableBorder)
                    if itemFrame.IconBorder then
                        itemFrame.IconBorder:Hide()
                    end
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
    end
end

---------- warband scenes ----------

local WARBAND_TILE_BORDER = {0.3, 0.3, 0.3}
local function SkinWarbandScenes()
    local journal = WarbandSceneJournal
    if not journal or not journal.IconsFrame then return end

    StripFrames(journal.IconsFrame)
    local controls = journal.IconsFrame.Icons and journal.IconsFrame.Icons.Controls
    if controls then
        if controls.ShowOwned then
            controls.ShowOwned.Checkbox:GwSkinCheckButton(nil, CHECKBOX_SIZE)
            GW.WhitenFontStrings(controls.ShowOwned)
        end
        local paging = controls.PagingControls
        if paging then
            for _, child in ipairs({paging:GetChildren()}) do
                if child:IsObjectType("Button") then
                    SkinPageButton(child)
                end
            end
            GW.WhitenFontStrings(paging)
        end
    end

    if WarbandSceneEntryMixin and WarbandSceneEntryMixin.UpdateWarbandSceneData then
        hooksecurefunc(WarbandSceneEntryMixin, "UpdateWarbandSceneData", function(entry)
            if entry.gwSkinned or not entry.Icon then return end
            entry.gwSkinned = true
            if entry.Border then
                entry.Border:SetAlpha(0)
            end
            -- the black frame is baked into the picture texture, the icon helper crops it away
            BackdropAroundIcon(entry.Icon, GW.BackdropTemplates.DefaultWithColorableBorder)
            entry.Icon.backdrop:SetBackdropBorderColor(WARBAND_TILE_BORDER[1], WARBAND_TILE_BORDER[2], WARBAND_TILE_BORDER[3], 1)
            if entry.SetHighlightTexture then
                local highlight = entry:CreateTexture(nil, "HIGHLIGHT")
                highlight:SetColorTexture(unpack(HIGHLIGHT_COLOR))
                highlight:SetAllPoints(entry.Icon)
                entry:SetHighlightTexture(highlight)
            end
            GW.WhitenFontStrings(entry)
        end)
    end
end

---------- the journal frame ----------

local function collectionsSkin()
    local journal = CollectionsJournal
    GW.HandlePortraitFrame(journal)
    GW.CreateFrameHeaderWithBody(journal, journal.TitleContainer and journal.TitleContainer.TitleText, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon.png", nil, nil, false, true)

    journal:SetClampedToScreen(true)
    journal:SetClampRectInsets(0, 0, journal.gwHeader:GetHeight() - 20, 0)
    if journal.CloseButton then
        journal.CloseButton:ClearAllPoints()
        journal.CloseButton:SetPoint("TOPRIGHT", -10, -2)
    end

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
