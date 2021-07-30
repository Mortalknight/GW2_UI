local _, GW =  ...

local constBackdropArgs = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local tabs = {
    "LeftDisabled",
    "MiddleDisabled",
    "RightDisabled",
    "Left",
    "Middle",
    "Right"
}

local function SetModifiedBackdrop(self)
    if self:IsEnabled() then
        if self.hovertex then
            self.hovertex:Show()
        end
    end
end

local function SetOriginalBackdrop(self)
    if self:IsEnabled() then
        if self.hovertex then
            self.hovertex:Hide()
        end
    end
end

local function SkinDungeons()
    local b1 = EncounterJournalInstanceSelectScrollFrameScrollChildInstanceButton1
    if b1 and not b1.isSkinned then
        if b1.SetNormalTexture then b1:SetNormalTexture("") end
        if b1.SetHighlightTexture then b1:SetHighlightTexture("") end
        if b1.SetPushedTexture then b1:SetPushedTexture("") end
        if b1.SetDisabledTexture then b1:SetDisabledTexture("") end
        b1:CreateBackdrop(GW.skins.constBackdropFrame, true, 4, 4)
        b1.hovertex = b1:CreateTexture(nil, "ARTWORK", nil, 7)
        b1.hovertex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\stancebar-border")
        b1.hovertex:SetAllPoints(b1)
        b1.hovertex:Hide()
        b1:HookScript("OnEnter", SetModifiedBackdrop)
        b1:HookScript("OnLeave", SetOriginalBackdrop)
        GW.SetInside(b1.bgImage)
        b1.bgImage:SetTexCoord(.08, .6, .08, .6)
        b1.bgImage:SetDrawLayer("ARTWORK", 5)
        b1.isSkinned = true
    end

    for i = 1, 100 do
        local b = _G["EncounterJournalInstanceSelectScrollFrameinstance" .. i]
        if b and not b.isSkinned then
            if b.SetNormalTexture then b:SetNormalTexture("") end
            if b.SetHighlightTexture then b:SetHighlightTexture("") end
            if b.SetPushedTexture then b:SetPushedTexture("") end
            if b.SetDisabledTexture then b:SetDisabledTexture("") end
            b:CreateBackdrop(GW.skins.constBackdropFrame, true, 4, 4)
            b.hovertex = b:CreateTexture(nil, "ARTWORK", nil, 7)
            b.hovertex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\stancebar-border")
            b.hovertex:SetAllPoints(b)
            b.hovertex:Hide()
            b:HookScript("OnEnter", SetModifiedBackdrop)
            b:HookScript("OnLeave", SetOriginalBackdrop)
            GW.SetInside(b.bgImage)
            b.bgImage:SetTexCoord(0.08, 0.6, 0.08, 0.6)
            b.bgImage:SetDrawLayer("ARTWORK", 5)
            b.isSkinned = true
        end
    end
end

local function SkinBosses()
    local bossIndex = 1
    local _, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex)
    local bossButton

    local encounter = EncounterJournal.encounter
    encounter.info.instanceButton.icon:SetMask("")

    while bossID do
        bossButton = _G["EncounterJournalBossButton" .. bossIndex]
        if bossButton and not bossButton.isSkinned then
            bossButton:SkinButton(false, true, nil, nil, true)
            bossButton.creature:ClearAllPoints()
            bossButton.creature:SetPoint("TOPLEFT", 1, -4)
            bossButton.isSkinned = true
        end

        bossIndex = bossIndex + 1
        _, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex)
    end
end

local function SkinOverviewInfo(self, _, index)
    local header = self.overviews[index]
    if not header.isSkinned then
        for i = 4, 18 do
            select(i, header.button:GetRegions()):SetTexture()
        end

        header.button:SkinButton(false, true)
        header.descriptionBG:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background")
        header.descriptionBGBottom:SetAlpha(0)
        header.description:SetTextColor(1, 1, 1)
        header.button.title:SetTextColor(0, 0, 0)
        header.button.title.SetTextColor = GW.NoOp
        header.button.expandedIcon:SetTextColor(0, 0, 0)
        header.button.expandedIcon.SetTextColor = GW.NoOp

        header.isSkinned = true
    end
end

local function SkinOverviewInfoBullets(object)
    local parent = object:GetParent()

    if parent.Bullets then
        for _, bullet in pairs(parent.Bullets) do
            if not bullet.styled then
                bullet.Text:SetTextColor(1, 1, 1)
                bullet.styled = true
            end
        end
    end
end

local function SkinAbilitiesInfo()
    local index = 1
    local header = _G["EncounterJournalInfoHeader" .. index]
    while header do
        if not header.isSkinned then
            header.flashAnim.Play = GW.NoOp

            header.descriptionBG:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background")
            header.descriptionBGBottom:SetAlpha(0)
            for i = 4, 18 do
                select(i, header.button:GetRegions()):SetTexture()
            end

            header.description:SetTextColor(1, 1, 1)
            header.button.title:SetTextColor(0, 0, 0)
            header.button.title.SetTextColor = GW.NoOp
            header.button.expandedIcon:SetTextColor(0, 0, 0)
            header.button.expandedIcon.SetTextColor = GW.NoOp

            header.button:SkinButton(false, true)

            header.button.bg = CreateFrame("Frame", nil, header.button)
            header.button.bg:SetFrameLevel(header.button.bg:GetFrameLevel() - 1)
            header.button.abilityIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            header.isSkinned = true
        end

        if header.button.abilityIcon:IsShown() then
            header.button.bg:Show()
        else
            header.button.bg:Hide()
        end

        index = index + 1
        header = _G["EncounterJournalInfoHeader" .. index]
    end
end


local function HandleTopTabs(tab)
    for _, object in pairs(tabs) do
        local textureName = tab:GetName() and _G[tab:GetName() .. object]
        if textureName then
            textureName:SetTexture()
        elseif tab[object] then
            tab[object]:SetTexture()
        end
    end

    local highlightTex = tab.GetHighlightTexture and tab:GetHighlightTexture()
    if highlightTex then
        highlightTex:SetTexture()
    else
        tab:StripTextures()
    end

    tab:SkinButton(false, true)
    tab:SetHitRectInsets(0, 0, 0, 0)
    tab:GetFontString():SetTextColor(0, 0, 0)
end

local function HandleTabs(tab)
    tab:StripTextures()
    tab:SetText(tab.tooltip)
    tab:GetFontString():SetFont(UNIT_NAME_FONT, 12)
    tab:SkinButton(false, true)
    tab:SetScript("OnEnter", GW.NoOp)
    tab:SetScript("OnLeave", GW.NoOp)
    tab:SetSize(tab:GetFontString():GetStringWidth() * 1.5 , 20)
    tab.SetPoint = GW.NoOp
end


local function LoadEncounterJournalSkin()
    if not GW.GetSetting("ENCOUNTER_JOURNAL_SKIN_ENABLED") then return end

    if not EncounterJournal then
        EncounterJournal_LoadUI()
    end
    GW.HandlePortraitFrame(EncounterJournal, true)
    EncounterJournalTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    EncounterJournal.navBar:StripTextures(true)
    EncounterJournal.navBar.overlay:StripTextures(true)

    EncounterJournalPortrait:Show()
    GW.SkinTextBox(EncounterJournal.searchBox.Middle, EncounterJournal.searchBox.Left, EncounterJournal.searchBox.Right)
    EncounterJournal.searchBox:ClearAllPoints()
    EncounterJournal.searchBox:SetPoint("TOPLEFT", EncounterJournal.navBar, "TOPRIGHT", 4, 0)

    EncounterJournal.instanceSelect.bg:Kill()

    EncounterJournal.instanceSelect.scroll.ScrollBar:SkinScrollBar()
    EncounterJournal.instanceSelect.scroll.ScrollBar:SetWidth(3)
    EncounterJournal.instanceSelect.scroll:SkinScrollFrame()
    EncounterJournal.instanceSelect.tierDropDown:SkinDropDownMenu()
    HandleTopTabs(EncounterJournal.instanceSelect.suggestTab)
    HandleTopTabs(EncounterJournal.instanceSelect.dungeonsTab)
    HandleTopTabs(EncounterJournal.instanceSelect.raidsTab)
    HandleTopTabs(EncounterJournal.instanceSelect.LootJournalTab)

    hooksecurefunc("EJ_ContentTab_Select", function(id)
        for i = 1, #EncounterJournal.instanceSelect.Tabs do
            local tab = EncounterJournal.instanceSelect.Tabs[i]
            if tab.id ~= id then
                tab:GetFontString():SetTextColor(0, 0, 0)
            else
                tab:GetFontString():SetTextColor(0, 0, 0)
            end
        end
    end)

    EncounterJournal.instanceSelect.dungeonsTab:ClearAllPoints()
    EncounterJournal.instanceSelect.dungeonsTab:SetPoint("BOTTOMLEFT", EncounterJournal.instanceSelect.suggestTab, "BOTTOMRIGHT", 2, 0)
    EncounterJournal.instanceSelect.raidsTab:ClearAllPoints()
    EncounterJournal.instanceSelect.raidsTab:SetPoint("BOTTOMLEFT", EncounterJournal.instanceSelect.dungeonsTab, "BOTTOMRIGHT", 2, 0)
    EncounterJournal.instanceSelect.LootJournalTab:ClearAllPoints()
    EncounterJournal.instanceSelect.LootJournalTab:SetPoint("BOTTOMLEFT", EncounterJournal.instanceSelect.raidsTab, "BOTTOMRIGHT", 2, 0)

    for i = 1, #EncounterJournal.instanceSelect.Tabs do
        local tab = EncounterJournal.instanceSelect.Tabs[i]
        local text = tab:GetFontString()

        text:SetPoint("CENTER")
    end

    EncounterJournal.encounter.info:CreateBackdrop(GW.skins.constBackdropFrame)
    EncounterJournal.encounter.info.encounterTitle:Kill()

    GW.HandleIcon(EncounterJournal.encounter.info.instanceButton.icon, true)
    EncounterJournal.encounter.info.instanceButton.icon:SetTexCoord(0, 1, 0, 1)
    EncounterJournal.encounter.info.instanceButton:SetNormalTexture("")
    EncounterJournal.encounter.info.instanceButton:SetHighlightTexture("")

    EncounterJournalEncounterFrameInfoBG:SetHeight(385)
    EncounterJournal.encounter.info.leftShadow:Kill()
    EncounterJournal.encounter.info.rightShadow:Kill()
    EncounterJournal.encounter.info.model.dungeonBG:Kill()
    EncounterJournalEncounterFrameInfoModelFrameShadow:Kill()

    EncounterJournal.encounter.info.instanceButton:ClearAllPoints()
    EncounterJournal.encounter.info.instanceButton:SetPoint("TOPLEFT", EncounterJournal.encounter.info, "TOPLEFT", 0, 15)

    EncounterJournal.encounter.info.instanceTitle:ClearAllPoints()
    EncounterJournal.encounter.info.instanceTitle:SetPoint("BOTTOM", EncounterJournal.encounter.info.bossesScroll, "TOP", 10, 15)

    EncounterJournalEncounterFrameInfoLootScrollFrameClassFilterClearFrame:GetRegions():SetAlpha(0)

    EncounterJournal.encounter.info.difficulty:StripTextures()
    EncounterJournal.encounter.info.reset:StripTextures()

    EncounterJournal.encounter.info.difficulty:ClearAllPoints()
    EncounterJournal.encounter.info.difficulty:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoBG, "TOPRIGHT", -5, 7)
    EncounterJournal.encounter.info.reset:SkinButton(false, true)
    EncounterJournal.encounter.info.difficulty:SkinButton(false, true, nil, nil, true)

    EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle:SkinButton(false, true, nil, nil, true)
    EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:SkinButton(false, true, nil, nil, true)

    EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle:ClearAllPoints()
    EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle:SetPoint("TOPLEFT", EncounterJournal.encounter.info, "TOP", 0, -8)
    EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:ClearAllPoints()
    EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:SetPoint("LEFT", EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle, "RIGHT", 4, 0)

    EncounterJournal.encounter.info.reset:ClearAllPoints()
    EncounterJournal.encounter.info.reset:SetPoint("TOPRIGHT", EncounterJournal.encounter.info.difficulty, "TOPLEFT", -10, 0)
    EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexture([[Interface\EncounterJournal\UI-EncounterJournalTextures]])
    EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexCoord(0.90625000, 0.94726563, 0.00097656, 0.02050781)

    EncounterJournal.encounter.info.bossesScroll.ScrollBar:SkinScrollBar()
    EncounterJournal.encounter.info.bossesScroll.ScrollBar:SetWidth(3)
    EncounterJournal.encounter.info.bossesScroll:SkinScrollFrame()

    EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar:SkinScrollBar()
    EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar:SetWidth(3)
    EncounterJournalEncounterFrameInstanceFrameLoreScrollFrame:SkinScrollFrame()

    EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.85)
    EncounterJournalEncounterFrameInstanceFrameBG:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameBG:SetPoint("CENTER", 0, 40)
    EncounterJournalEncounterFrameInstanceFrameTitle:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameTitle:SetPoint("TOP", 0, -105)
    EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint("LEFT", 55, -56)

    EncounterJournal.encounter.info.overviewScroll.ScrollBar:SkinScrollBar()
    EncounterJournal.encounter.info.overviewScroll.ScrollBar:SetWidth(3)

    EncounterJournal.encounter.info.detailsScroll.ScrollBar:SkinScrollBar()
    EncounterJournal.encounter.info.detailsScroll.ScrollBar:SetWidth(3)

    EncounterJournal.encounter.info.lootScroll.scrollBar:SkinScrollBar()
    EncounterJournal.encounter.info.lootScroll.scrollBar:SetWidth(3)

    EncounterJournal.encounter.info.detailsScroll:SetHeight(360)
    EncounterJournal.encounter.info.lootScroll:SetHeight(360)
    EncounterJournal.encounter.info.overviewScroll:SetHeight(360)
    EncounterJournal.encounter.info.bossesScroll:SetHeight(360)
    EncounterJournalEncounterFrameInfoLootScrollFrame:SetHeight(360)
    EncounterJournalEncounterFrameInfoLootScrollFrame:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfoLootScrollFrame:GetParent(), "TOP", 20, -70)
    EncounterJournalEncounterFrameInfoLootScrollFrame:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoLootScrollFrame:GetParent(), "BOTTOMRIGHT", -10, 5)

    local frameTabs = {
        EncounterJournal.encounter.info.overviewTab,
        EncounterJournal.encounter.info.lootTab,
        EncounterJournal.encounter.info.bossTab,
        EncounterJournal.encounter.info.modelTab
    }

    for i = 1, #frameTabs do
        frameTabs[i]:ClearAllPoints()
    end

    for i = 1, #frameTabs do
        local tab = frameTabs[i]
        if i == 4 then
            tab:SetPoint("TOPRIGHT", _G.EncounterJournal, "BOTTOMRIGHT", -10, 2)
        else
            tab:SetPoint("RIGHT", frameTabs[i + 1], "LEFT", -4, 0)
        end

        HandleTabs(tab)
    end

    hooksecurefunc("EncounterJournal_SetTabEnabled", function(tab, enabled)
        if enabled then
            tab:GetFontString():SetTextColor(0, 0, 0)
        else
            tab:GetFontString():SetTextColor(0.6, 0.6, 0.6)
        end
    end)

    local items = EncounterJournal.encounter.info.lootScroll.buttons
    for i = 1, #items do
        local item = items[i]

        item.bossTexture:SetAlpha(0)
        item.bosslessTexture:SetAlpha(0)

        item.icon:SetSize(32, 32)
        item.icon:SetPoint("TOPLEFT", 1, -1)
        item.icon:SetDrawLayer("ARTWORK")
        item.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        item.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        item.IconBorder:SetAllPoints(item.icon)
        item.IconBorder:SetParent(item)

        hooksecurefunc(item.IconBorder, "SetVertexColor", function(self)
            self:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        end)

        item.name:ClearAllPoints()
        item.name:SetPoint("TOPLEFT", item.icon, "TOPRIGHT", 6, -2)

        item.boss:ClearAllPoints()
        item.boss:SetPoint("BOTTOMLEFT", 4, 6)

        item.slot:ClearAllPoints()
        item.slot:SetPoint("TOPLEFT", item.name, "BOTTOMLEFT", 0, -3)

        item.armorType:ClearAllPoints()
        item.armorType:SetPoint("RIGHT", item, "RIGHT", -10, 0)

        item:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)

        item.boss:SetTextColor(1, 1, 1)
        item.slot:SetTextColor(1, 1, 1)
        item.armorType:SetTextColor(1, 1, 1)

        if i == 1 then
            item:ClearAllPoints()
            item:SetPoint("TOPLEFT", EncounterJournal.encounter.info.lootScroll.scrollChild, "TOPLEFT", 5, 0)
        end
    end

    EncounterJournalSearchResults:StripTextures()
    EncounterJournalSearchResults:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
    EncounterJournalSearchBox.searchPreviewContainer:StripTextures()

    EncounterJournalSearchResultsCloseButton:SkinButton(true)
    EncounterJournalSearchResultsCloseButton:SetSize(20, 20)
    EncounterJournalSearchResultsScrollFrameScrollBar:SkinScrollBar()
    EncounterJournalSearchResultsScrollFrameScrollBar:SetWidth(3)
    EncounterJournalSearchResultsScrollFrame:SkinScrollFrame()

    for i = 1, AJ_MAX_NUM_SUGGESTIONS do
        local suggestion = EncounterJournal.suggestFrame["Suggestion" .. i]
        if i == 1 then
            suggestion.button:SkinButton(false, true)
            suggestion.button:SetFrameLevel(4)
            GW.HandleNextPrevButton(suggestion.prevButton, nil, true)
            GW.HandleNextPrevButton(suggestion.nextButton, nil, true)
        else
            suggestion.centerDisplay.button:SkinButton(false, true)
        end
    end

    local suggestion = EncounterJournal.suggestFrame.Suggestion1
    suggestion.bg:Hide()
    suggestion:CreateBackdrop(GW.skins.constBackdropFrame, true)

    local centerDisplay = suggestion.centerDisplay
    centerDisplay.title.text:SetTextColor(1, 1, 1)
    centerDisplay.description.text:SetTextColor(0.9, 0.9, 0.9)

    local reward = suggestion.reward
    reward.text:SetTextColor(0.9, 0.9, 0.9)
    reward.iconRing:Hide()
    reward.iconRingHighlight:SetTexture()

    for i = 2, 3 do
        suggestion = EncounterJournal.suggestFrame["Suggestion" .. i]
        suggestion.bg:Hide()
        suggestion:CreateBackdrop(GW.skins.constBackdropFrame, true)
        suggestion.icon:SetPoint("TOPLEFT", 10, -10)

        centerDisplay = suggestion.centerDisplay
        centerDisplay:ClearAllPoints()
        centerDisplay:SetPoint("TOPLEFT", 85, -10)
        centerDisplay.title.text:SetTextColor(1, 1, 1)
        centerDisplay.description.text:SetTextColor(0.9, 0.9, 0.9)

        reward = suggestion.reward
        reward.iconRing:Hide()
        reward.iconRingHighlight:SetTexture()
    end

    hooksecurefunc("EJSuggestFrame_RefreshDisplay", function()
        for i, data in ipairs(EncounterJournal.suggestFrame.suggestions) do
            local sugg = next(data) and EncounterJournal.suggestFrame["Suggestion" .. i]
            if sugg then
                if not sugg.icon.backdrop then
                    sugg.icon:CreateBackdrop()
                end

                sugg.icon:SetMask("")
                sugg.icon:SetTexture(data.iconPath)
                sugg.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                sugg.iconRing:Hide()
            end
        end
    end)

    hooksecurefunc("EJSuggestFrame_UpdateRewards", function(sugg)
        local rewardData = sugg.reward.data
        if rewardData then
            if not sugg.reward.icon.backdrop then
                sugg.reward.icon:CreateBackdrop()
            end

            sugg.reward.icon:SetMask("")
            sugg.reward.icon:SetTexture(rewardData.itemIcon or rewardData.currencyIcon or [[Interface\Icons\achievement_guildperk_mobilebanking]])
            sugg.reward.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

            local r, g, b = 1, 1, 1
            if rewardData.itemID then
                local quality = select(3, GetItemInfo(rewardData.itemID))
                if quality and quality > 1 then
                    r, g, b = GetItemQualityColor(quality)
                end
            end
            if not sugg.reward.icon.iconBorder then
                sugg.reward.icon.iconBorder = sugg.reward:CreateTexture(nil, "ARTWORK")
                sugg.reward.icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
                sugg.reward.icon.iconBorder:SetPoint("TOPLEFT", sugg.reward.icon, "TOPLEFT", -1, 1)
                sugg.reward.icon.iconBorder:SetPoint("BOTTOMRIGHT", sugg.reward.icon, "BOTTOMRIGHT", 1, -1)
            end
            sugg.reward.icon.iconBorder:SetVertexColor(r, g, b)
        end
    end)

    if GW.GetSetting("TOOLTIPS_ENABLED") then
        local item1 = EncounterJournalTooltip.Item1
        local item2 = EncounterJournalTooltip.Item2
        EncounterJournalTooltip:StripTextures()
        EncounterJournalTooltip:CreateBackdrop(constBackdropArgs)
        GW.HandleIcon(item1.icon)
        GW.HandleIcon(item2.icon)
        item1.IconBorder:Kill()
        item2.IconBorder:Kill()
    end

    local LootJournal = EncounterJournal.LootJournal
    LootJournal.ClassDropDownButton:SkinButton(false, true, nil, nil, true)
    LootJournal.ClassDropDownButton:SetFrameLevel(10)
    LootJournal.RuneforgePowerFilterDropDownButton:SkinButton(false, true, nil, nil, true)
    LootJournal.RuneforgePowerFilterDropDownButton:SetFrameLevel(10)

    EncounterJournal.LootJournal:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)

    LootJournal.PowersFrame.ScrollBar:SkinScrollBar()
    LootJournal.PowersFrame.ScrollBar:SetWidth(3)
    LootJournal.PowersFrame:SkinScrollFrame()

    local r, g, b = GetItemQualityColor(Enum.ItemQuality.Legendary or 5)
    hooksecurefunc(LootJournal.PowersFrame, "RefreshListDisplay", function(buttons)
        if not buttons.elements then return end

        for i = 1, buttons:GetNumElementFrames() do
            local btn = buttons.elements[i]
            if btn and not btn.IsSkinned then
                btn.Background:SetAlpha(0)
                btn.BackgroundOverlay:SetAlpha(0)
                btn.CircleMask:Hide()
                GW.HandleIcon(btn.Icon)

                btn.Icon.iconBorder = btn:CreateTexture(nil, "ARTWORK")
                btn.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
                btn.Icon.iconBorder:SetAllPoints(btn.Icon)
                btn.Icon.iconBorder:SetVertexColor(r, g, b)

                btn:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
                btn.backdrop:SetPoint("TOPLEFT", 3, 0)
                btn.backdrop:SetPoint("BOTTOMRIGHT", -2, 1)

                btn.IsSkinned = true
            end
        end
    end)

    hooksecurefunc("EncounterJournal_ListInstances", SkinDungeons)
    EncounterJournal_ListInstances()

    hooksecurefunc("EncounterJournal_DisplayInstance", SkinBosses)
    hooksecurefunc("EncounterJournal_SetUpOverview", SkinOverviewInfo)
    hooksecurefunc("EncounterJournal_SetBullets", SkinOverviewInfoBullets)
    hooksecurefunc("EncounterJournal_ToggleHeaders", SkinAbilitiesInfo)

    EncounterJournalEncounterFrameInfoBG:Kill()

    EncounterJournal.encounter.info.detailsScroll.child.description:SetTextColor(1, 1, 1)
    EncounterJournal.encounter.info.overviewScroll.child.loreDescription:SetTextColor(1, 1, 1)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, 1, 1)
    EncounterJournal.encounter.info.overviewScroll.child.overviewDescription.Text:SetTextColor(1, 1, 1)
    EncounterJournal.encounter.instance.loreScroll.child.lore:SetTextColor(1, 1, 1)
    EncounterJournalEncounterFrameInstanceFrameBG:SetTexCoord(0.71, 0.06, 0.582, 0.08)
    EncounterJournalEncounterFrameInstanceFrameBG:SetRotation(rad(180))
    EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.7)
    EncounterJournalEncounterFrameInstanceFrameBG:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
    EncounterJournalEncounterFrameInstanceFrame.titleBG:SetAlpha(0)
    EncounterJournalEncounterFrameInstanceFrameTitle:SetTextColor(1, 1, 1)
    EncounterJournalEncounterFrameInstanceFrameTitle:SetFont(UNIT_NAME_FONT, 25)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:SetAlpha(0)

    EncounterJournal.LootJournal:GetRegions():Kill()
end
GW.LoadEncounterJournalSkin = LoadEncounterJournalSkin