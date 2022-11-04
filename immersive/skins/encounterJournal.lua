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
        header.button.expandedIcon:SetTextColor(1, 1, 1)
        header.button.expandedIcon.SetTextColor = GW.NoOp

        header.isSkinned = true
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

local function hook_EJSuggestFrame_RefreshDisplay()
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
end

local function hook_EJSuggestFrame_UpdateRewards(sugg)
    local rewardData = sugg.reward.data
    if rewardData then
        if not sugg.reward.icon.backdrop then
            sugg.reward.icon:CreateBackdrop("Transparent", true)
            sugg.reward.icon.backdrop:SetFrameLevel(3)
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
        sugg.reward.icon.backdrop:SetBackdropBorderColor(r, g, b)
    end
end

local function ItemSetsItemBorder(border, atlas)
    local parent = border:GetParent()
    local backdrop = parent and parent.Icon and parent.Icon.backdrop
    if backdrop then
        local color = GetItemQualityColor[lootQuality[atlas]]
        if color then
            backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
        else
            backdrop:SetBackdropBorderColor(1, 1, 1)
        end
    end
end

local function encounterJournalSkin()
    local EJ = EncounterJournal
    GW.HandlePortraitFrame(EJ)
    local header = CreateFrame("Frame", "GwEncounterJournalHeader", EJ, "GwWorldmapHeader")

    EJ.navBar:StripTextures()
    EJ.navBar.overlay:StripTextures()
    EJ.navBar:SetPoint("TOPLEFT", 0, -33)
    EJ.navBar.SetPoint = GW.NoOp

    EJ.navBar.tex = EJ.navBar:CreateTexture("bg", "BACKGROUND", nil, 0)
    EJ.navBar.tex:SetPoint("TOPLEFT", EJ.navBar, "TOPLEFT", 0, 20)
    EJ.navBar.tex:SetPoint("BOTTOMRIGHT", EJ.navBar, "BOTTOMRIGHT", 0, 1)
    EJ.navBar.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-header")

    EJ.tex = EJ:CreateTexture("bg", "BACKGROUND", nil, 0)
    EJ.tex:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    EJ.tex:SetPoint("BOTTOMRIGHT", EJ, "BOTTOMRIGHT", 0, 0)
    EJ.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-background")

    EJ.innertex = EJ:CreateTexture("bg2", "BACKGROUND", nil, 7)
    EJ.innertex:SetPoint("TOPLEFT", EJ.navBar, "BOTTOMLEFT", -1, 1)
    EJ.innertex:SetPoint("BOTTOMRIGHT", EJ, "BOTTOMRIGHT", 1, -1)
    EJ.innertex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background")
    EJ.innertex:SetTexCoord(0, 0.70703125, 0, 0.580078125)

    EJ.navBar.homeButton:StripTextures()
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
    EJ.navBar.homeButton.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightInner")
    EJ.navBar.homeButton.tex:SetAlpha(1)

    local homeButtonBorder = CreateFrame("Frame", nil, EJ.navBar.homeButton, "GwLightButtonBorder")
    EJ.navBar.homeButton.borderFrame = homeButtonBorder
    EJ.navBar.homeButton.xoffset = -1

    EncounterJournalTitleText:ClearAllPoints()
    EncounterJournalTitleText:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 64, 10)
    EncounterJournalTitleText:SetFont(DAMAGE_TEXT_FONT, 20)
    EncounterJournalTitleText:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    EJ.CloseButton:SetPoint("TOPRIGHT", -10, -2)

    EncounterJournalPortrait:Show()

    GW.SkinTextBox(EncounterJournal.searchBox.Middle, EncounterJournal.searchBox.Left, EncounterJournal.searchBox.Right)
    EncounterJournal.searchBox:ClearAllPoints()
    EncounterJournal.searchBox:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -15, -25)

    local InstanceSelect = EJ.instanceSelect
    InstanceSelect.bg:Kill()

    InstanceSelect.bg:Kill()
    InstanceSelect.tierDropDown:SkinDropDownMenu()

    GW.HandleTrimScrollBar(InstanceSelect.ScrollBar)

    HandleTopTabs(EncounterJournalSuggestTab)
    HandleTopTabs(EncounterJournalDungeonTab)
    HandleTopTabs(EncounterJournalRaidTab)
    HandleTopTabs(EncounterJournalLootJournalTab)

    local EncounterInfo = EJ.encounter.info

    --EncounterInfo.tex = EncounterInfo:CreateTexture("bg", "BACKGROUND", nil, 7)
    --EncounterInfo.tex:SetPoint("TOPLEFT", EncounterInfo, "TOPLEFT", -1, -1)
    --EncounterInfo.tex:SetPoint("BOTTOMRIGHT", EncounterInfo, "BOTTOMRIGHT", 1, 1)
    --EncounterInfo.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background")
    --EncounterInfo.tex:SetTexCoord(0, 0.70703125, 0, 0.580078125)

    EncounterInfo.encounterTitle:Kill()

    GW.HandleIcon(EncounterInfo.instanceButton.icon, true)
    EncounterInfo.instanceButton.icon:SetTexCoord(0, 1, 0, 1)
    EncounterInfo.instanceButton:SetNormalTexture("")
    EncounterInfo.instanceButton:SetHighlightTexture("")

    EncounterInfo.leftShadow:Kill()
    EncounterInfo.rightShadow:Kill()
    EncounterInfo.model.dungeonBG:Kill()
    EncounterJournalEncounterFrameInfoBG:SetHeight(385)
    EncounterJournalEncounterFrameInfoModelFrameShadow:Kill()

    EncounterInfo.instanceButton:ClearAllPoints()
    EncounterInfo.instanceButton:SetPoint("TOPLEFT",EncounterInfo, "TOPLEFT", 0, 0)

    EncounterInfo.instanceTitle:ClearAllPoints()
    EncounterInfo.instanceTitle:SetPoint("BOTTOM", EncounterInfo.bossesScroll, "TOP", 10, 15)

    EncounterInfo.difficulty:StripTextures()
    EncounterInfo.reset:StripTextures()

    -- buttons
    EncounterInfo.difficulty:ClearAllPoints()
    EncounterInfo.difficulty:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoBG, "TOPRIGHT", -5, 7)
    EncounterInfo.reset:SkinButton(false, true)
    EncounterInfo.difficulty:SkinButton(false, true, nil, nil, true)

    EncounterInfo.reset:ClearAllPoints()
    EncounterInfo.reset:SetPoint("TOPRIGHT",EncounterInfo.difficulty, "TOPLEFT", -10, 0)
    EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexture([[Interface\EncounterJournal\UI-EncounterJournalTextures]])
    EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexCoord(0.90625000, 0.94726563, 0.00097656, 0.02050781)

    GW.HandleTrimScrollBar(EncounterInfo.BossesScrollBar)
    GW.HandleTrimScrollBar(EncounterJournalEncounterFrameInstanceFrame.LoreScrollBar)

    EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.85)
    EncounterJournalEncounterFrameInstanceFrameBG:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameBG:SetPoint("CENTER", 0, 40)
    EncounterJournalEncounterFrameInstanceFrameTitle:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameTitle:SetPoint("TOP", 0, -105)
    EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint("LEFT", 55, -56)

    EncounterInfo.overviewScroll.ScrollBar:SkinScrollBar()
    EncounterInfo.overviewScroll.ScrollBar:SetWidth(3)

    EncounterInfo.detailsScroll.ScrollBar:SkinScrollBar()
    EncounterInfo.detailsScroll.ScrollBar:SetWidth(3)

    GW.HandleTrimScrollBar(EncounterInfo.LootContainer.ScrollBar)

    EncounterInfo.detailsScroll:SetHeight(360)
    EncounterInfo.LootContainer:SetHeight(360)
    EncounterInfo.overviewScroll:SetHeight(360)

    for _, name in next, {"overviewTab", "modelTab", "bossTab", "lootTab"} do
        local info = EncounterJournal.encounter.info

        local tab = info[name]
        tab:SkinButton(false, true)

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

    EncounterJournalSearchResults:StripTextures()
    EncounterJournalSearchResults:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
    EncounterJournalSearchBox.searchPreviewContainer:StripTextures()

    EncounterJournalSearchResultsCloseButton:SkinButton(true)
    EncounterJournalSearchResultsCloseButton:SetSize(20, 20)
    GW.HandleTrimScrollBar(EncounterJournalSearchResults.ScrollBar)

    for i = 1, AJ_MAX_NUM_SUGGESTIONS do
        local suggestion = EJ.suggestFrame["Suggestion" .. i]
        if i == 1 then
            suggestion.button:SkinButton(false, true)
            suggestion.button:SetFrameLevel(4)
            GW.HandleNextPrevButton(suggestion.prevButton, nil, true)
            GW.HandleNextPrevButton(suggestion.nextButton, nil, true)
        else
            suggestion.centerDisplay.button:SkinButton(false, true)
        end
    end

    local suggestFrame = EJ.suggestFrame

    -- Suggestion 1
    local suggestion = suggestFrame.Suggestion1
    suggestion.bg:Hide()

    suggestion.tex = suggestion:CreateTexture("bg", "BACKGROUND", nil, 0)
    suggestion.tex:SetPoint("TOPLEFT", suggestion, "TOPLEFT", -1, 1)
    suggestion.tex:SetPoint("BOTTOMRIGHT", suggestion, "BOTTOMRIGHT", 1, -1)
    suggestion.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background")
    suggestion.tex:SetTexCoord(0, 0.70703125, 0, 0.580078125)

    local centerDisplay = suggestion.centerDisplay
    centerDisplay.title.text:SetTextColor(1, 1, 1)
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

        suggestion.tex = suggestion:CreateTexture("bg", "BACKGROUND", nil, 0)
        suggestion.tex:SetPoint("TOPLEFT", suggestion, "TOPLEFT", -1, 1)
        suggestion.tex:SetPoint("BOTTOMRIGHT", suggestion, "BOTTOMRIGHT", 1, -1)
        suggestion.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background")
        suggestion.tex:SetTexCoord(0, 0.70703125, 0, 0.580078125)

        centerDisplay = suggestion.centerDisplay
        centerDisplay:ClearAllPoints()
        centerDisplay:SetPoint("TOPLEFT", 85, -10)
        centerDisplay.title.text:SetTextColor(1, 1, 1)
        centerDisplay.description.text:SetTextColor(0.9, 0.9, 0.9)

        reward = suggestion.reward
        reward.iconRing:Hide()
        reward.iconRingHighlight:SetTexture()
    end

    hooksecurefunc("EJSuggestFrame_RefreshDisplay", hook_EJSuggestFrame_RefreshDisplay)
    hooksecurefunc("EJSuggestFrame_UpdateRewards", hook_EJSuggestFrame_UpdateRewards)

    --Suggestion Reward Tooltips
    if GW.GetSetting("TOOLTIPS_ENABLED") then
        local tooltip = EncounterJournalTooltip
        local item1 = tooltip.Item1
        local item2 = tooltip.Item2
        tooltip:StripTextures()
        tooltip:CreateBackdrop(constBackdropArgs)
        GW.HandleIcon(item1.icon)
        GW.HandleIcon(item2.icon)
        item1.IconBorder:Kill()
        item2.IconBorder:Kill()
    end

    --Powers
    local LJ = EJ.LootJournal
    LJ.ClassDropDownButton:SkinButton(false, true, nil, nil, true)
    LJ.ClassDropDownButton:SetFrameLevel(10)
    LJ.RuneforgePowerFilterDropDownButton:SkinButton(false, true, nil, nil, true)
    LJ.RuneforgePowerFilterDropDownButton:SetFrameLevel(10)

    GW.HandleTrimScrollBar(EncounterJournal.LootJournal.ScrollBar)

    for _, button in next, {EncounterJournalEncounterFrameInfoFilterToggle, EncounterJournalEncounterFrameInfoSlotFilterToggle } do
        button:SkinButton(false, true, nil, nil, true)
    end

    LJ:StripTextures()
    --LJ.tex = LJ:CreateTexture("bg", "BACKGROUND", nil, 0)
    --LJ.tex:SetPoint("TOPLEFT", LJ, "TOPLEFT", -1, 1)
    --LJ.tex:SetPoint("BOTTOMRIGHT", LJ, "BOTTOMRIGHT", 1, -1)
    --LJ.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background")
    --LJ.tex:SetTexCoord(0, 0.70703125, 0, 0.580078125)

    hooksecurefunc(EncounterJournal.instanceSelect.ScrollBox, "Update", function(frame)
        for _, child in next, { frame.ScrollTarget:GetChildren() } do
            if not child.isSkinned then
                child:SetNormalTexture("")
                child:SetHighlightTexture("")
                child:SetPushedTexture("")
                if child.SetDisabledTexture then child:SetDisabledTexture("") end
                child:CreateBackdrop(GW.skins.constBackdropFrame, true, 4, 4)
                child.hovertex = child:CreateTexture(nil, "ARTWORK", nil, 7)
                child.hovertex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\stancebar-border")
                child.hovertex:SetAllPoints(child)
                child.hovertex:Hide()
                child:HookScript("OnEnter", SetModifiedBackdrop)
                child:HookScript("OnLeave", SetOriginalBackdrop)
                child.bgImage:SetInside(2, 2)
                child.bgImage:SetTexCoord(.08, .6, .08, .6)
                child.bgImage:SetDrawLayer("ARTWORK", 5)
                child.isSkinned = true
            end
        end
    end)

    hooksecurefunc(EncounterJournal.encounter.info.BossesScrollBox, "Update", function(frame)
        for _, child in next, { frame.ScrollTarget:GetChildren() } do
            if not child.isSkinned then

                child:SkinButton(false, true, nil, nil, true)
                child.creature:ClearAllPoints()
                child.creature:SetPoint("TOPLEFT", 1, -4)
                child.isSkinned = true

                child.isSkinned = true
            end
            -- check for selceted boss
            if (child.encounterID == EncounterJournal.encounter.infoFrame.encounterID) then
                child.gwHover.skipHover = true
                child.gwHover:SetAlpha(1)
                child.gwHover:SetPoint("RIGHT", child, "LEFT", child:GetWidth(), 0)
            else
                child.gwHover.skipHover = false
                child.gwHover:SetAlpha(1)
                child.gwHover:SetPoint("RIGHT", child, "LEFT", 0, 0)
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
                    child.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
                    if not child.IconBorder.hooked then
                        hooksecurefunc(child.IconBorder, "SetTexture", function()
                            if child.IconBorder:GetTexture() and child.IconBorder:GetTexture() > 0 and child.IconBorder:GetTexture() ~= "Interface/AddOns/GW2_UI/textures/bag/bagitemborder" then
                                child.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
                            end
                        end)
                        child.IconBorder.hooked = true
                    end
                end

                if not child.backdrop then
                    child:CreateBackdrop("Transparent")
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

    EncounterJournalEncounterFrameInfoBG:Kill()
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
    EncounterJournalEncounterFrameInstanceFrameBG:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
    EncounterJournalEncounterFrameInstanceFrame.titleBG:SetAlpha(0)
    EncounterJournalEncounterFrameInstanceFrameTitle:SetTextColor(1, 1, 1)
    EncounterJournalEncounterFrameInstanceFrameTitle:SetFont(UNIT_NAME_FONT, 25, "")


    for _, child in next, {EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont.ScrollBox.ScrollTarget:GetChildren()} do
        if child.FontString then
            child.FontString:SetTextColor(1, 1, 1)
        end
    end

    local parchment = LJ:GetRegions()
    if parchment then
        parchment:Kill()
    end

    local LootDropdown = EncounterJournalLootJournalViewDropDown
    LootDropdown:SkinDropDownMenu()
    LootDropdown:SetScript("OnShow", function(dd) dd:SetFrameLevel(5) end) -- might be able to hook a function later; hotfix builds didn"t export Blizzard_LootJournalItems.xml

    do -- Item Sets
        local ItemSetsFrame = EJ.LootJournalItems.ItemSetsFrame
        ItemSetsFrame.ClassButton:SkinButton(false, true)
        ItemSetsFrame.scrollBar:SkinScrollBar()

        EJ.LootJournalItems:StripTextures()
        EJ.LootJournalItems:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)

        hooksecurefunc(ItemSetsFrame, "UpdateList", function(frame)
            if frame.buttons then
                for _, button in ipairs(frame.buttons) do
                    if button and not button.backdrop then
                        button:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
                        button.Background:Hide()
                    end
                end
            end
        end)

        hooksecurefunc(ItemSetsFrame, "ConfigureItemButton", function(_, button)
            if not button.Icon then return end

            if not button.Icon.backdrop then
                GW.HandleIcon(button.Icon, true)
            end

            if button.Border and not button.Border.isSkinned then
                button.Border:SetAlpha(0)

                ItemSetsItemBorder(button.Border, button.Border:GetAtlas()) -- handle first one
                hooksecurefunc(button.Border, "SetAtlas", ItemSetsItemBorder)

                button.Border.isSkinned = true
            end
        end)
    end
end
AFP("encounterJournalSkin", encounterJournalSkin)

local function LoadEncounterJournalSkin()
    if not GW.GetSetting("ENCOUNTER_JOURNAL_SKIN_ENABLED") then
        return
    end
    GW.RegisterLoadHook(encounterJournalSkin, "Blizzard_EncounterJournal", EncounterJournal)
end
GW.LoadEncounterJournalSkin = LoadEncounterJournalSkin
