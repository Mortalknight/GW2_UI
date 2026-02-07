local _, GW =  ...
local AFP = GW.AddProfiling

local lootQuality = {
    ["loottab-set-itemborder-white"] = nil, -- dont show white
    ["loottab-set-itemborder-green"] = 2,
    ["loottab-set-itemborder-blue"] = 3,
    ["loottab-set-itemborder-purple"] = 4,
    ["loottab-set-itemborder-orange"] = 5,
    ["loottab-set-itemborder-artifact"] = 6,
}

local constBackdropArgs = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png",
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-border.png",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
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


local function HandleButton(btn, strip)
    btn:GwSkinButton(false, true, nil, nil, strip)

    local str = btn:GetFontString()
    if str then
        str:SetTextColor(0, 0, 0)
    end
end

local SkinOverviewInfo
do
    local lockColors = {}
    local function LockValue(button, r, g, b)
        local rr, gg, bb = 0, 0, 0
        if r ~= rr or gg ~= g or b ~= bb then
            button:SetTextColor(rr, gg, bb)
        end
    end

    local function LockWhite(button, r, g, b)
        if r ~= 1 or g ~= 1 or b ~= 1 then
            button:SetTextColor(1, 1, 1)
        end
    end

    local function LockColor(button, valuecolor)
        if lockColors[button] then return end

        hooksecurefunc(button, "SetTextColor", (valuecolor and LockValue) or LockWhite)

        lockColors[button] = true
    end

    SkinOverviewInfo = function(self, _, index)
        local header = self.overviews[index]
        if not header.isSkinned then
            for i = 4, 18 do
                select(i, header.button:GetRegions()):SetTexture()
            end

            HandleButton(header.button)

            LockColor(header.button.title, true)
            LockColor(header.button.expandedIcon)

            header.descriptionBG:SetAlpha(0)
            header.descriptionBGBottom:SetAlpha(0)
            header.description:SetTextColor(1, 1, 1)

            header.isSkinned = true
        end
    end
end

local function SkinOverviewInfoBullets(object)
    local parent = object:GetParent()

    if parent.Bullets then
        for _, bullet in pairs(parent.Bullets) do
            if not bullet.styled then
                bullet.Text:SetTextColor("P", 1, 1, 1)
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

            header.descriptionBG:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png")
            header.descriptionBGBottom:SetAlpha(0)
            for i = 4, 18 do
                select(i, header.button:GetRegions()):SetTexture()
            end

            header.description:SetTextColor(1, 1, 1)
            header.button.title:SetTextColor(0, 0, 0)
            header.button.title:SetFont(DAMAGE_TEXT_FONT, 12, "")
            header.button.title.SetTextColor = GW.NoOp
            header.button.expandedIcon:SetTextColor(0, 0, 0)
            header.button.expandedIcon.SetTextColor = GW.NoOp

            HandleButton(header.button)

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

local function hook_EJSuggestFrame_RefreshDisplay()
    for i, data in ipairs(EncounterJournal.suggestFrame.suggestions) do
        local sugg = next(data) and EncounterJournal.suggestFrame["Suggestion" .. i]
        if sugg then
            if not sugg.icon.backdrop then
                sugg.icon:GwCreateBackdrop()
            end

            sugg.icon:SetMask("")
            sugg.icon:SetTexture(data.iconPath)
            sugg.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            sugg.iconRing:Hide()
        end
    end
end

local function hook_EJSuggestFrame_UpdateRewards(sugg)
    local rewardData = sugg.reward.data
    if rewardData then
        if not sugg.reward.icon.backdrop then
            sugg.reward.icon:GwCreateBackdrop("Transparent", true)
            sugg.reward.icon.backdrop:SetFrameLevel(3)
        end

        sugg.reward.icon:SetMask("")
        sugg.reward.icon:SetTexture(rewardData.itemIcon or rewardData.currencyIcon or [[Interface\Icons\achievement_guildperk_mobilebanking]])
        sugg.reward.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        local color = {r = 1, g = 1, b = 1}
        if rewardData.itemID then
            local quality = select(3, C_Item.GetItemInfo(rewardData.itemID))
            if quality and quality > 1 then
                color = GW.GetQualityColor(quality)
            end
        end
        sugg.reward.icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
    end
end

local function ItemSetsItemBorder(border, atlas)
    local parent = border:GetParent()
    local backdrop = parent and parent.Icon and parent.Icon.backdrop
    if backdrop and atlas then
        local color = GW.GetBagItemQualityColor(lootQuality[atlas])
        if color then
            backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
        else
            backdrop:SetBackdropBorderColor(1, 1, 1)
        end
    end
end
local function ItemSetElements(set)
    if not set.backdrop then
        set:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    end

    if set.Background then
        set.Background:Hide()
    end

    if set.ItemButtons then
        for _, button in next, set.ItemButtons do
            local icon = button.Icon
            if icon and not icon.backdrop then
                GW.HandleIcon(icon, true, GW.BackdropTemplates.DefaultWithColorableBorder)
            end

            local border = button.Border
            if border and not border.IsSkinned then
                border:SetAlpha(0)

                ItemSetsItemBorder(border, border:GetAtlas()) -- handle first one
                hooksecurefunc(border, 'SetAtlas', ItemSetsItemBorder)

                border.IsSkinned = true
            end
        end
    end
end

local function HandleItemSetsElements(scrollBox)
    if scrollBox then
        scrollBox:ForEachFrame(ItemSetElements)
    end
end

local function encounterJournalSkin()
    local EJ = EncounterJournal
    GW.HandlePortraitFrame(EJ)
    EJ.LootJournalItems:GwStripTextures()
    EncounterJournalMonthlyActivitiesFrame.FilterList:GwStripTextures()

    GW.CreateFrameHeaderWithBody(EJ, EncounterJournalTitleText, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon.png", {EJ.LootJournalItems, EncounterJournalMonthlyActivitiesFrame.FilterList}, nil, false, true)
    EncounterJournalTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    EJ:SetClampedToScreen(true)
    EJ:SetClampRectInsets(0, 0, EJ.gwHeader:GetHeight() - 20, 0)

    EJ.instanceSelect.Title:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    EJ.instanceSelect.Title:SetFont(DAMAGE_TEXT_FONT, 16, "")
    EJ.instanceSelect.Title:SetShadowColor(0, 0, 0, 0)
    EJ.instanceSelect.Title:SetShadowOffset(1, -1)

    EJ.navBar:GwStripTextures(true)
    EJ.navBar.overlay:GwStripTextures(true)
    EJ.navBar:SetPoint("TOPLEFT", 0, -33)

    EJ.navBar.tex = EJ.navBar:CreateTexture(nil, "BACKGROUND", nil, 0)
    EJ.navBar.tex:SetPoint("TOPLEFT", EJ.navBar, "TOPLEFT", 0, 20)
    EJ.navBar.tex:SetPoint("BOTTOMRIGHT", EJ.navBar, "BOTTOMRIGHT", 0, 1)
    EJ.navBar.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-header.png")

    EJ.innertex = EJ:CreateTexture(nil, "BACKGROUND", nil, 7)
    EJ.innertex:SetPoint("TOPLEFT", EJ.navBar, "BOTTOMLEFT", -1, 1)
    EJ.innertex:SetPoint("BOTTOMRIGHT", EJ, "BOTTOMRIGHT", 1, -1)
    EJ.innertex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background.png")
    EJ.innertex:SetTexCoord(0, 0.70703125, 0, 0.580078125)

    EJ.navBar.homeButton:GwStripTextures()
    local r = {EJ.navBar.homeButton:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:SetTextColor(1, 1, 1, 1)
            c:SetShadowOffset(0, 0)
        end
    end
    EJ.navBar.homeButton.tex = EJ.navBar.homeButton:CreateTexture(nil, "BACKGROUND")
    EJ.navBar.homeButton.tex:SetPoint("LEFT", EJ.navBar.homeButton, "LEFT")
    EJ.navBar.homeButton.tex:SetPoint("TOP", EJ.navBar.homeButton, "TOP")
    EJ.navBar.homeButton.tex:SetPoint("BOTTOM", EJ.navBar.homeButton, "BOTTOM")
    EJ.navBar.homeButton.tex:SetPoint("RIGHT", EJ.navBar.homeButton, "RIGHT")
    EJ.navBar.homeButton.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightinner.png")
    EJ.navBar.homeButton.tex:SetAlpha(1)

    EJ.navBar.homeButton.borderFrame = CreateFrame("Frame", nil, EJ.navBar.homeButton, "GwLightButtonBorder")
    EJ.CloseButton:SetPoint("TOPRIGHT", -10, -2)
    EncounterJournalPortrait:Show()

    GW.SkinTextBox(EncounterJournal.searchBox.Middle, EncounterJournal.searchBox.Left, EncounterJournal.searchBox.Right)
    EncounterJournal.searchBox:ClearAllPoints()
    EncounterJournal.searchBox:SetPoint("BOTTOMRIGHT", EncounterJournal.gwHeader, "BOTTOMRIGHT", -5, -30)

    local InstanceSelect = EJ.instanceSelect
    InstanceSelect.bg:GwKill()

    InstanceSelect.ExpansionDropdown:GwHandleDropDownBox()
    GW.HandleTrimScrollBar(InstanceSelect.ScrollBar)

    EncounterJournalInstanceSelectBG:SetAlpha(0)
    EncounterJournalMonthlyActivitiesFrame.Bg:SetAlpha(0)
    GW.HandleTrimScrollBar(EncounterJournalMonthlyActivitiesFrame.ScrollBar)
    GW.HandleScrollControls(EncounterJournalMonthlyActivitiesFrame)
    GW.HandleTrimScrollBar(EncounterJournalMonthlyActivitiesFrame.FilterList.ScrollBar)
    GW.HandleScrollControls(EncounterJournalMonthlyActivitiesFrame.FilterList)

    EncounterJournalMonthlyActivitiesFrame.HeaderContainer.Title:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    EncounterJournalMonthlyActivitiesFrame.HeaderContainer.Title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    EncounterJournalMonthlyActivitiesFrame.HeaderContainer.Title:SetShadowColor(0, 0, 0, 0)
    EncounterJournalMonthlyActivitiesFrame.HeaderContainer.Title:SetShadowOffset(1, -1)

    EncounterJournalMonthlyActivitiesFrame.BarComplete.PendingRewardsText:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    EncounterJournalMonthlyActivitiesFrame.BarComplete.AllRewardsCollectedText:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

    local loaded
    hooksecurefunc(EncounterJournalMonthlyActivitiesFrame.FilterList.ScrollBox, "Update", function(frame)
        GW.HandleItemListScrollBoxHover(frame)
        if not loaded then
            loaded = true
            frame.view:SetElementExtent(28)
        end
        for _, child in next, {frame.ScrollTarget:GetChildren()} do
            if not child.gwHooked then
                child.Label:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
                child:SetHeight(28)
                child.Texture:SetAlpha(0)
                child.gwHooked = true
                hooksecurefunc(child, "UpdateStateInternal", function(_, selected)
                    child.gwSelected:SetShown(selected)
                    child.Label:SetFont(UNIT_NAME_FONT, 16)
                end)
            end

        end
    end)
    EncounterJournalMonthlyActivitiesFrame.FilterList.ScrollBox:Update()
    hooksecurefunc(EncounterJournalMonthlyActivitiesFrame.ScrollBox, "Update", function(frame)
        GW.HandleItemListScrollBoxHover(frame)
        for _, child in next, {frame.ScrollTarget:GetChildren()} do
           child.TextContainer.NameText:SetTextColor(1, 1, 1)
        end
    end)

    -- Journays Tab
    GW.HandleTrimScrollBar(EncounterJournalJourneysFrame.ScrollBar)
    GW.HandleScrollControls(EncounterJournalJourneysFrame)
    EncounterJournalJourneysFrame.BorderFrame:Hide()

    EncounterJournalJourneysFrame.JourneyProgress.LevelSkipButton:GwSkinButton(false, true)
    EncounterJournalJourneysFrame.JourneyProgress.OverviewBtn:GwSkinButton(false, true)
    EncounterJournalJourneysFrame.JourneyOverview.OverviewBtn:GwSkinButton(false, true)

    GW.HandleTrimScrollBar(InstanceSelect.ScrollBar)
    GW.HandleScrollControls(InstanceSelect)

    for _, tab in next, {
        EncounterJournalJourneysTab,
		EncounterJournalSuggestTab,
		EncounterJournalDungeonTab,
		EncounterJournalRaidTab,
		EncounterJournalLootJournalTab,
		EncounterJournalMonthlyActivitiesTab,
        EncounterJournal.TutorialsTab,
        EncounterJournal.DelvesTab
	} do
        if tab then
		    GW.HandleTabs(tab)
        end
	end

    EncounterJournalJourneysTab:ClearAllPoints()
	EncounterJournalJourneysTab:SetPoint('TOPLEFT', EncounterJournal, 'BOTTOMLEFT', 0, 0)
    EncounterJournalJourneysTab.ClearAllPoints = GW.NoOp
    EncounterJournalJourneysTab.SetPoint = GW.NoOp

    EncounterJournalMonthlyActivitiesTab:ClearAllPoints()
	EncounterJournalMonthlyActivitiesTab:SetPoint('LEFT', EncounterJournalJourneysTab, 'RIGHT', 0, 0)
    EncounterJournalMonthlyActivitiesTab.ClearAllPoints = GW.NoOp
    EncounterJournalMonthlyActivitiesTab.SetPoint = GW.NoOp

	EncounterJournalSuggestTab:ClearAllPoints()
	EncounterJournalSuggestTab:SetPoint('LEFT', EncounterJournalMonthlyActivitiesTab, 'RIGHT', 0, 0)
    EncounterJournalSuggestTab.ClearAllPoints = GW.NoOp
    EncounterJournalSuggestTab.SetPoint = GW.NoOp

	EncounterJournalDungeonTab:ClearAllPoints()
	EncounterJournalDungeonTab:SetPoint('LEFT', EncounterJournalSuggestTab, 'RIGHT', 0, 0)
    EncounterJournalDungeonTab.ClearAllPoints = GW.NoOp
    EncounterJournalDungeonTab.SetPoint = GW.NoOp

	EncounterJournalRaidTab:ClearAllPoints()
	EncounterJournalRaidTab:SetPoint('LEFT', EncounterJournalDungeonTab, 'RIGHT', 0, 0)
    EncounterJournalRaidTab.ClearAllPoints = GW.NoOp
    EncounterJournalRaidTab.SetPoint = GW.NoOp

	EncounterJournalLootJournalTab:ClearAllPoints()
	EncounterJournalLootJournalTab:SetPoint('LEFT', EncounterJournalRaidTab, 'RIGHT', 0, 0)
    EncounterJournalLootJournalTab.ClearAllPoints = GW.NoOp
    EncounterJournalLootJournalTab.SetPoint = GW.NoOp

    EncounterJournal.TutorialsTab:ClearAllPoints()
	EncounterJournal.TutorialsTab:SetPoint('LEFT', EncounterJournalLootJournalTab, 'RIGHT', 0, 0)
    EncounterJournal.TutorialsTab.ClearAllPoints = GW.NoOp
    EncounterJournal.TutorialsTab.SetPoint = GW.NoOp

    if EncounterJournal.DelvesTab then
        EncounterJournal.DelvesTab:ClearAllPoints()
        EncounterJournal.DelvesTab:SetPoint('LEFT', EncounterJournal.TutorialsTab, 'RIGHT', 0, 0)
        EncounterJournal.DelvesTab.ClearAllPoints = GW.NoOp
        EncounterJournal.DelvesTab.SetPoint = GW.NoOp
    end

    EncounterJournalMonthlyActivitiesFrame.HelpButton:GwKill()

    EncounterJournal.TutorialsFrame.Contents.StartButton:GwSkinButton(false, true)

    local EncounterInfo = EJ.encounter.info
    EncounterInfo.encounterTitle:GwKill()

    GW.HandleIcon(EncounterInfo.instanceButton.icon, true)
    EncounterInfo.instanceButton.icon:SetTexCoord(0, 1, 0, 1)
    EncounterInfo.instanceButton:SetNormalTexture("")
    EncounterInfo.instanceButton:SetHighlightTexture("")

    EncounterInfo.leftShadow:SetAlpha(0)
    EncounterInfo.rightShadow:SetAlpha(0)
    EncounterInfo.model.dungeonBG:SetAlpha(0)
    EncounterJournalEncounterFrameInfoBG:SetHeight(385)
    EncounterJournalEncounterFrameInfoModelFrameShadow:GwKill()

    EncounterInfo.instanceButton:ClearAllPoints()
    EncounterInfo.instanceButton:SetPoint("TOPLEFT",EncounterInfo, "TOPLEFT", 0, 0)

    EncounterInfo.instanceTitle:ClearAllPoints()
    EncounterInfo.instanceTitle:SetPoint("BOTTOM", EncounterInfo.bossesScroll, "TOP", 10, 15)

    EncounterInfo.difficulty:GwStripTextures()

    -- buttons
    EncounterInfo.difficulty:ClearAllPoints()
    EncounterInfo.difficulty:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoBG, "TOPRIGHT", -5, 7)
    EncounterInfo.difficulty:GwHandleDropDownBox(nil, true, nil, 120)

    EncounterInfo.LootContainer.filter:ClearAllPoints()
    EncounterInfo.LootContainer.filter:SetPoint('RIGHT', EncounterInfo.difficulty, 'LEFT', -120, 0)
    EncounterInfo.LootContainer.filter:GwHandleDropDownBox(nil, false, nil, 120)
    EncounterInfo.LootContainer.slotFilter:GwHandleDropDownBox(nil, false, nil, 100)

    GW.HandleTrimScrollBar(EncounterInfo.BossesScrollBar, true)
    GW.HandleScrollControls(EncounterInfo, "BossesScrollBar")
    GW.HandleTrimScrollBar(EncounterJournalEncounterFrameInstanceFrame.LoreScrollBar, true)
    GW.HandleScrollControls(EncounterJournalEncounterFrameInstanceFrame, "LoreScrollBar")
    GW.HandleTrimScrollBar(EncounterJournalEncounterFrameInfoDetailsScrollFrame.ScrollBar, true)
    GW.HandleScrollControls(EncounterJournalEncounterFrameInfoDetailsScrollFrame)
    GW.HandleTrimScrollBar(EncounterJournalEncounterFrameInfoOverviewScrollFrame.ScrollBar, true)
    GW.HandleScrollControls(EncounterJournalEncounterFrameInfoOverviewScrollFrame)

    EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.85)
    EncounterJournalEncounterFrameInstanceFrameBG:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameBG:SetPoint("CENTER", 0, 40)
    EncounterJournalEncounterFrameInstanceFrameTitle:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameTitle:SetPoint("TOP", 0, -30)
    EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint("LEFT", 55, -70)

    EncounterInfo.overviewScroll.ScrollBar:GwSkinScrollBar()
    EncounterInfo.overviewScroll.ScrollBar:SetWidth(3)

    EncounterInfo.detailsScroll.ScrollBar:GwSkinScrollBar()
    EncounterInfo.detailsScroll.ScrollBar:SetWidth(3)

    GW.HandleTrimScrollBar(EncounterInfo.LootContainer.ScrollBar, true)
    GW.HandleScrollControls(EncounterInfo.LootContainer)

    EncounterInfo.detailsScroll:SetHeight(360)
    EncounterInfo.LootContainer:SetHeight(360)
    EncounterInfo.overviewScroll:SetHeight(360)

    for _, name in next, {"overviewTab", "modelTab", "bossTab", "lootTab"} do
        local info = EncounterJournal.encounter.info

        local tab = info[name]
        GW.HandleTabs(tab, "right", {tab.unselected, tab.selected})

        tab:ClearAllPoints()

        if name == "overviewTab" then
            tab:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPRIGHT", 9, 0)
        elseif name == "lootTab" then
            tab:SetPoint("TOPLEFT", info.overviewTab, "BOTTOMLEFT", 0, -1)
        elseif name == "bossTab" then
            tab:SetPoint("TOPLEFT", info.lootTab, "BOTTOMLEFT", 0, -1)
        elseif name == "modelTab" then
            tab:SetPoint("TOPLEFT", info.bossTab, "BOTTOMLEFT", 0, -1)
        end
    end

    EncounterJournalSearchResults:GwStripTextures()
    EncounterJournalSearchResults:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    EncounterJournalSearchBox.searchPreviewContainer:GwStripTextures()

    EncounterJournalSearchResultsCloseButton:GwSkinButton(true)
    EncounterJournalSearchResultsCloseButton:SetSize(20, 20)
    GW.HandleTrimScrollBar(EncounterJournalSearchResults.ScrollBar, true)
    GW.HandleScrollControls(EncounterJournalSearchResults)

    for i = 1, AJ_MAX_NUM_SUGGESTIONS do
        local suggestion = EJ.suggestFrame["Suggestion" .. i]
        if i == 1 then
            HandleButton(suggestion.button)
            suggestion.button:SetFrameLevel(4)
            GW.HandleNextPrevButton(suggestion.prevButton, nil, true)
            GW.HandleNextPrevButton(suggestion.nextButton, nil, true)
        else
            HandleButton(suggestion.centerDisplay.button)
        end
    end

    local suggestFrame = EJ.suggestFrame

    -- Suggestion 1
    local suggestion = suggestFrame.Suggestion1
    suggestion.bg:Hide()

    suggestion.tex = suggestion:CreateTexture(nil, "BACKGROUND", nil, 0)
    suggestion.tex:SetPoint("TOPLEFT", suggestion, "TOPLEFT", -1, 1)
    suggestion.tex:SetPoint("BOTTOMRIGHT", suggestion, "BOTTOMRIGHT", 1, -1)
    suggestion.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background.png")
    suggestion.tex:SetTexCoord(0, 0.70703125, 0, 0.580078125)

    local centerDisplay = suggestion.centerDisplay
    centerDisplay.title.text:SetTextColor(1, 1, 1)
    centerDisplay.title.text:SetFont(DAMAGE_TEXT_FONT, 20, "")
    centerDisplay.description.text:SetTextColor(0.9, 0.9, 0.9)

    local reward = suggestion.reward
    reward.text:SetTextColor(0.9, 0.9, 0.9)
    reward.iconRing:Hide()
    reward.iconRingHighlight:SetTexture()

    -- Suggestion 2 and 3
    for i = 2, 3 do
        suggestion = suggestFrame["Suggestion" .. i]
        suggestion.bg:Hide()
        suggestion.icon:SetPoint("TOPLEFT", 10, -10)

        suggestion.tex = suggestion:CreateTexture(nil, "BACKGROUND", nil, 0)
        suggestion.tex:SetPoint("TOPLEFT", suggestion, "TOPLEFT", -1, 1)
        suggestion.tex:SetPoint("BOTTOMRIGHT", suggestion, "BOTTOMRIGHT", 1, -1)
        suggestion.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background.png")
        suggestion.tex:SetTexCoord(0, 0.70703125, 0, 0.580078125)

        centerDisplay = suggestion.centerDisplay
        centerDisplay:ClearAllPoints()
        centerDisplay:SetPoint("TOPLEFT", 85, -10)
        centerDisplay.title.text:SetTextColor(1, 1, 1)
        centerDisplay.title.text:SetFont(DAMAGE_TEXT_FONT, 18, "")
        centerDisplay.description.text:SetTextColor(0.9, 0.9, 0.9)

        reward = suggestion.reward
        reward.iconRing:Hide()
        reward.iconRingHighlight:SetTexture()
    end

    hooksecurefunc("EJSuggestFrame_RefreshDisplay", hook_EJSuggestFrame_RefreshDisplay)
    hooksecurefunc("EJSuggestFrame_UpdateRewards", hook_EJSuggestFrame_UpdateRewards)

    --Suggestion Reward Tooltips
    if GW.settings.TOOLTIPS_ENABLED then
        local tooltip = EncounterJournalTooltip
        local item1 = tooltip.Item1
        local item2 = tooltip.Item2
        tooltip:GwStripTextures()
        tooltip:GwCreateBackdrop(constBackdropArgs)
        GW.HandleIcon(item1.icon)
        GW.HandleIcon(item2.icon)
        item1.IconBorder:GwKill()
        item2.IconBorder:GwKill()
    end

    local LJ = EJ.LootJournal
    GW.HandleTrimScrollBar(LJ.ScrollBar, true)
    GW.HandleScrollControls(LJ)

    for _, button in next, {EncounterJournalEncounterFrameInfoFilterToggle, EncounterJournalEncounterFrameInfoSlotFilterToggle } do
        HandleButton(button, true)
    end

    LJ:GwStripTextures()

    hooksecurefunc(EncounterJournal.instanceSelect.ScrollBox, "Update", function(frame)
        for _, child in next, { frame.ScrollTarget:GetChildren() } do
            if not child.isSkinned then
                child:SetNormalTexture("")
                child:SetHighlightTexture("")
                child:SetPushedTexture("")
                if child.SetDisabledTexture then child:SetDisabledTexture("") end
                child:GwCreateBackdrop(GW.BackdropTemplates.Default, true, 4, 4)
                child.hovertex = child:CreateTexture(nil, "ARTWORK", nil, 7)
                child.hovertex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\stancebar-border.png")
                child.hovertex:SetAllPoints(child)
                child.hovertex:Hide()
                child:HookScript("OnEnter", SetModifiedBackdrop)
                child:HookScript("OnLeave", SetOriginalBackdrop)
                child.bgImage:GwSetInside(2, 2)
                child.bgImage:SetTexCoord(.08, .6, .08, .6)
                child.bgImage:SetDrawLayer("ARTWORK", 5)
                child.name:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
                child.name:SetFont(DAMAGE_TEXT_FONT, 16)
                child.name:SetShadowColor(0, 0, 0, 0)
                child.name:SetShadowOffset(1, -1)
                child.isSkinned = true
            end
        end
    end)

    hooksecurefunc(EncounterJournal.encounter.info.BossesScrollBox, "Update", function(frame)
        for _, child in next, { frame.ScrollTarget:GetChildren() } do
            if not child.isSkinned then
                HandleButton(child, true)
                child.creature:ClearAllPoints()
                child.creature:SetPoint("TOPLEFT", 1, -4)
                child.isSkinned = true

                child.isSkinned = true
            end
            -- check for selceted boss
            if (child.encounterID == EncounterJournal.encounter.infoFrame.encounterID) then
                child.hover.skipHover = true
                child.hover:SetAlpha(1)
                child.hover:SetPoint("RIGHT", child, "LEFT", child:GetWidth(), 0)
            else
                child.hover.skipHover = false
                child.hover:SetAlpha(1)
                child.hover:SetPoint("RIGHT", child, "LEFT", 0, 0)
            end
        end
    end)

    hooksecurefunc(_G.EncounterJournal.encounter.info.LootContainer.ScrollBox, "Update", function(frame)
        for _, child in next, { frame.ScrollTarget:GetChildren() } do
            if not child.isSkinned then
                if child.bossTexture then child.bossTexture:SetAlpha(0) end
                if child.bosslessTexture then child.bosslessTexture:SetAlpha(0) end

                if child.name then
                    child.name:ClearAllPoints()
                    child.name:SetPoint("TOPLEFT", child.icon, "TOPRIGHT", 6, -2)
                end

                if child.boss then
                    child.boss:ClearAllPoints()
                    child.boss:SetPoint("BOTTOMLEFT", 4, 6)
                    child.boss:SetTextColor(1, 1, 1)
                end

                if child.slot then
                    child.slot:ClearAllPoints()
                    child.slot:SetPoint("TOPLEFT", child.name, "BOTTOMLEFT", 0, -3)
                    child.slot:SetTextColor(1, 1, 1)
                end

                if child.armorType then
                    child.armorType:ClearAllPoints()
                    child.armorType:SetPoint("RIGHT", child, "RIGHT", -10, 0)
                    child.armorType:SetTextColor(1, 1, 1)
                end

                if child.icon then
                    child.icon:SetSize(32, 32)
                    child.icon:SetPoint("TOPLEFT", 3 , -7)
                    GW.HandleIcon(child.icon)
                    child.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
                    if not child.IconBorder.hooked then
                        hooksecurefunc(child.IconBorder, "SetTexture", function()
                            if child.IconBorder:GetTexture() and child.IconBorder:GetTexture() > 0 and child.IconBorder:GetTexture() ~= "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png" then
                                child.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
                            end
                        end)
                        child.IconBorder.hooked = true
                    end
                end

                if not child.backdrop then
                    child:GwCreateBackdrop("Transparent")
                    child.backdrop:SetBackdropBorderColor(0, 0, 0, 1)
                    child.backdrop:SetPoint("TOPLEFT")
                    child.backdrop:SetPoint("BOTTOMRIGHT", 0, 1)
                end

                child.isSkinned = true
            end
        end
    end)

    hooksecurefunc("EncounterJournal_SetUpOverview", SkinOverviewInfo)
    hooksecurefunc("EncounterJournal_SetBullets", SkinOverviewInfoBullets)
    hooksecurefunc("EncounterJournal_ToggleHeaders", SkinAbilitiesInfo)

    EncounterJournalEncounterFrameInfoBG:GwKill()
    EncounterInfo.detailsScroll.child.description:SetTextColor(1, 1, 1)
    EncounterInfo.overviewScroll.child.loreDescription:SetTextColor(1, 1, 1)

    EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription:SetTextColor(1, 1, 1)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:Hide()
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetFontObject("GameFontNormalLarge")
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:SetTextColor(1, 1, 1)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, 0.8, 0)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:SetAlpha(0)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription.Text:SetTextColor("P", 1, 1, 1)

    EncounterJournalEncounterFrameInstanceFrameBG:SetTexCoord(0.71, 0.06, 0.582, 0.08)
    EncounterJournalEncounterFrameInstanceFrameBG:SetRotation(rad(180))
    EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.7)
    EncounterJournalEncounterFrameInstanceFrameBG:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    EncounterJournalEncounterFrameInstanceFrame.titleBG:SetAlpha(0)
    EncounterJournalEncounterFrameInstanceFrameTitle:SetTextColor(1, 1, 1)
    EncounterJournalEncounterFrameInstanceFrameTitle:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    for _, child in next, {EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont.ScrollBox.ScrollTarget:GetChildren()} do
        if child.FontString then
            child.FontString:SetTextColor(1, 1, 1)
        end
    end

    local parchment = LJ:GetRegions()
    if parchment then
        parchment:GwKill()
    end

    do -- Item Sets
        local ItemSetsFrame = EJ.LootJournalItems.ItemSetsFrame
        GW.HandleTrimScrollBar(ItemSetsFrame.ScrollBar, true)
        GW.HandleScrollControls(ItemSetsFrame)
        ItemSetsFrame.ClassDropdown:GwHandleDropDownBox()

        hooksecurefunc(ItemSetsFrame.ScrollBox, "Update", HandleItemSetsElements)
    end
end
AFP("encounterJournalSkin", encounterJournalSkin)

local function LoadEncounterJournalSkin()
    if not GW.settings.ENCOUNTER_JOURNAL_SKIN_ENABLED then
        return
    end
    GW.RegisterLoadHook(encounterJournalSkin, "Blizzard_EncounterJournal", EncounterJournal)
end
GW.LoadEncounterJournalSkin = LoadEncounterJournalSkin
