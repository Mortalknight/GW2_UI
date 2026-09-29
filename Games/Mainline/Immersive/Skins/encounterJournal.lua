---@class GW2
local GW = select(2, ...)

local HEADER_COLOR = GW.Colors.TextColors.LightHeader
local DETAILS_BACKGROUND = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png"
local TOOLTIP_BACKDROP = {
    bgFile = DETAILS_BACKGROUND,
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-border.png",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}

-- our light button with black text
local function SkinLightButton(button, strip)
    button:GwSkinButton(false, true, nil, nil, strip)
    local text = button:GetFontString()
    if text then
        text:SetTextColor(0, 0, 0)
    end
end

-- the paper art of a section header, everything but the ability icon
local function StripPaperHeader(button)
    for _, region in ipairs({button:GetRegions()}) do
        if region:IsObjectType("Texture") and region ~= button.abilityIcon then
            region:SetTexture()
        end
    end
end

local function StopAnimation(animation)
    animation:Stop()
end

-- the sections of the overview tab: our button with a black title and +/-, white text below
local function SkinOverviewSection(frame, _, index)
    local section = frame.overviews[index]
    if not section or section.gwSkinned then return end
    section.gwSkinned = true

    StripPaperHeader(section.button)
    SkinLightButton(section.button)
    GW.LockFontStringColor(section.button.title, 0, 0, 0)
    GW.LockFontStringColor(section.button.expandedIcon, 0, 0, 0)
    section.descriptionBG:SetAlpha(0)
    section.descriptionBGBottom:SetAlpha(0)
    section.description:SetTextColor(1, 1, 1)
end

local function SkinOverviewBullets(object)
    for _, bullet in pairs(object:GetParent().Bullets or {}) do
        bullet.Text:SetTextColor("P", 1, 1, 1)
    end
end

-- the ability sections of a boss; blizzard creates them as the list is opened
local function SkinAbilitySections()
    local index = 1
    local section = _G["EncounterJournalInfoHeader" .. index]
    while section do
        local button = section.button
        if not section.gwSkinned then
            section.gwSkinned = true
            -- no flash when a section opens
            hooksecurefunc(section.flashAnim, "Play", StopAnimation)
            section.descriptionBG:SetTexture(DETAILS_BACKGROUND)
            section.descriptionBGBottom:SetAlpha(0)
            section.description:SetTextColor(1, 1, 1)

            StripPaperHeader(button)
            SkinLightButton(button)
            button.title:SetFont(DAMAGE_TEXT_FONT, 12, "")
            GW.LockFontStringColor(button.title, 0, 0, 0)
            GW.LockFontStringColor(button.expandedIcon, 0, 0, 0)
            button.abilityIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        end

        index = index + 1
        section = _G["EncounterJournalInfoHeader" .. index]
    end
end

-- suggestions and their rewards: square icons in our frame, the reward frame in its quality color
local function SquareIcon(icon, texture)
    icon:SetMask("")
    icon:SetTexture(texture)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
end

local function UpdateSuggestions()
    local suggestFrame = EncounterJournal.suggestFrame
    for i, data in ipairs(suggestFrame.suggestions) do
        local suggestion = next(data) and suggestFrame["Suggestion" .. i]
        if suggestion then
            if not suggestion.icon.backdrop then
                suggestion.icon:GwCreateBackdrop()
            end
            SquareIcon(suggestion.icon, data.iconPath)
            suggestion.iconRing:Hide()
        end
    end
end

local function UpdateSuggestionReward(suggestion)
    local reward = suggestion.reward
    local data = reward.data
    if not data then return end

    local icon = reward.icon
    if not icon.backdrop then
        icon:GwCreateBackdrop("Transparent", true)
        icon.backdrop:SetFrameLevel(3)
    end
    SquareIcon(icon, data.itemIcon or data.currencyIcon or [[Interface\Icons\achievement_guildperk_mobilebanking]])

    local quality = data.itemID and select(3, C_Item.GetItemInfo(data.itemID))
    local color = quality and quality > 1 and GW.GetQualityColor(quality)
    icon.backdrop:SetBackdropBorderColor(color and color.r or 1, color and color.g or 1, color and color.b or 1)
end

local function SkinSuggestion(suggestion, titleSize)
    suggestion.bg:Hide()
    suggestion.tex = GW.CreateDetailsBackgroundTexture(suggestion, 0)
    suggestion.tex:SetPoint("TOPLEFT", suggestion, "TOPLEFT", -1, 1)
    suggestion.tex:SetPoint("BOTTOMRIGHT", suggestion, "BOTTOMRIGHT", 1, -1)

    local display = suggestion.centerDisplay
    display.title.text:SetTextColor(1, 1, 1)
    display.title.text:SetFont(DAMAGE_TEXT_FONT, titleSize, "")
    display.description.text:SetTextColor(0.9, 0.9, 0.9)

    suggestion.reward.iconRing:Hide()
    suggestion.reward.iconRingHighlight:SetTexture()
end

-- the big suggestion with its arrows, the two small ones below
local function SkinSuggestions(suggestFrame)
    local first = suggestFrame.Suggestion1
    SkinSuggestion(first, 20)
    SkinLightButton(first.button)
    first.button:SetFrameLevel(4)
    first.reward.text:SetTextColor(0.9, 0.9, 0.9)
    GW.HandleNextPrevButton(first.prevButton, nil, true)
    GW.HandleNextPrevButton(first.nextButton, nil, true)

    for i = 2, 3 do
        local suggestion = suggestFrame["Suggestion" .. i]
        SkinSuggestion(suggestion, 18)
        SkinLightButton(suggestion.centerDisplay.button)
        suggestion.icon:SetPoint("TOPLEFT", 10, -10)
        suggestion.centerDisplay:ClearAllPoints()
        suggestion.centerDisplay:SetPoint("TOPLEFT", 85, -10)
    end

    hooksecurefunc("EJSuggestFrame_RefreshDisplay", UpdateSuggestions)
    hooksecurefunc("EJSuggestFrame_UpdateRewards", UpdateSuggestionReward)
end

-- an item set: our frame, every item icon with its quality on the border
local function SkinItemSet(set)
    set:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    if set.Background then
        set.Background:Hide()
    end
    for _, button in ipairs(set.ItemButtons or {}) do
        if button.Icon then
            GW.HandleIcon(button.Icon, true, GW.BackdropTemplates.DefaultWithColorableBorder)
            if button.Border then
                GW.HandleIconBorder(button.Border, button.Icon.backdrop)
            end
        end
    end
end

-- the instance tiles of the dungeon and raid tabs: art in our frame; on hover the tint of our lists and
-- cards with a thin light frame around the art
local HOVER_FRAME = {edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white.png", edgeSize = 1}

local function ShowTileFrame(tile)
    if tile:IsEnabled() then
        tile.gwHoverFrame:Show()
    end
end

local function HideTileFrame(tile)
    tile.gwHoverFrame:Hide()
end

local function SkinInstanceTile(tile)
    for _, state in ipairs({"Normal", "Pushed", "Disabled"}) do
        local setter = tile["Set" .. state .. "Texture"]
        if setter then
            setter(tile, "")
        end
    end
    tile:GwCreateBackdrop(GW.BackdropTemplates.Default, true, 4, 4)
    tile:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    local highlight = tile:GetHighlightTexture()
    highlight:SetBlendMode("BLEND")
    highlight:SetVertexColor(0.8, 0.8, 0.8, 0.35)
    highlight:GwSetInside(tile.bgImage, 0, 0)
    tile.gwHoverFrame = CreateFrame("Frame", nil, tile, "BackdropTemplate")
    tile.gwHoverFrame:SetAllPoints(tile.bgImage)
    tile.gwHoverFrame:SetBackdrop(HOVER_FRAME)
    tile.gwHoverFrame:SetBackdropBorderColor(HEADER_COLOR:GetRGB())
    tile.gwHoverFrame:Hide()
    tile:HookScript("OnEnter", ShowTileFrame)
    tile:HookScript("OnLeave", HideTileFrame)

    tile.bgImage:GwSetInside(2, 2)
    tile.bgImage:SetTexCoord(0.08, 0.6, 0.08, 0.6)
    tile.bgImage:SetDrawLayer("ARTWORK", 5)
    tile.name:SetTextColor(HEADER_COLOR:GetRGB())
    tile.name:SetFont(DAMAGE_TEXT_FONT, 16)
    tile.name:SetShadowColor(0, 0, 0, 0)
    tile.name:SetShadowOffset(1, -1)
end

-- the bosses of an instance; the selected one keeps its hover bar over the whole width
local function SkinBossButton(button)
    SkinLightButton(button, true)
    button.creature:ClearAllPoints()
    button.creature:SetPoint("TOPLEFT", 1, -4)
end

local function MarkSelectedBoss(scrollBox)
    local selected = EncounterJournal.encounter.infoFrame.encounterID
    scrollBox:ForEachFrame(function(button)
        local isSelected = button.encounterID == selected
        button.hover.skipHover = isSelected
        button.hover:SetAlpha(1)
        button.hover:SetPoint("RIGHT", button, "LEFT", isSelected and button:GetWidth() or 0, 0)
    end)
end

-- a loot row: dark frame, small icon with our quality border, the texts in white beside it
local BAG_ITEM_BORDER = "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png"
local settingBorder = false
local function KeepBagItemBorder(border)
    if settingBorder then return end
    settingBorder = true
    border:SetTexture(BAG_ITEM_BORDER)
    settingBorder = false
end

local function SkinLootRow(row)
    for _, key in ipairs({"bossTexture", "bosslessTexture"}) do
        if row[key] then
            row[key]:SetAlpha(0)
        end
    end
    if row.icon then
        row.icon:SetSize(32, 32)
        row.icon:SetPoint("TOPLEFT", 3, -7)
        GW.HandleIcon(row.icon)
        KeepBagItemBorder(row.IconBorder)
        hooksecurefunc(row.IconBorder, "SetTexture", KeepBagItemBorder)
    end
    if row.name then
        row.name:ClearAllPoints()
        row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, -2)
    end
    if row.slot then
        row.slot:ClearAllPoints()
        row.slot:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -3)
    end
    if row.boss then
        row.boss:ClearAllPoints()
        row.boss:SetPoint("BOTTOMLEFT", 4, 6)
    end
    if row.armorType then
        row.armorType:ClearAllPoints()
        row.armorType:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    end
    for _, key in ipairs({"boss", "slot", "armorType"}) do
        if row[key] then
            row[key]:SetTextColor(1, 1, 1)
        end
    end

    row:GwCreateBackdrop("Transparent")
    row.backdrop:SetBackdropBorderColor(0, 0, 0, 1)
    row.backdrop:SetPoint("TOPLEFT")
    row.backdrop:SetPoint("BOTTOMRIGHT", 0, 1)
end

-- the reward tooltip of the suggestions, in our tooltip look
local function SkinRewardTooltip()
    local tooltip = EncounterJournalTooltip
    tooltip:GwStripTextures()
    tooltip:GwCreateBackdrop(TOOLTIP_BACKDROP)
    for _, item in ipairs({tooltip.Item1, tooltip.Item2}) do
        GW.HandleIcon(item.icon)
        item.IconBorder:GwKill()
    end
end

-- the scroll bars of the boss view, all in our style
local function SkinScrollBar(owner, key)
    GW.HandleTrimScrollBar(owner[key or "ScrollBar"])
    GW.HandleScrollControls(owner, key)
end

-- the boss view: instance button, difficulty and loot filters, the lists and the side tabs
local function SkinEncounterInfo(info)
    info.encounterTitle:GwKill()
    info.leftShadow:SetAlpha(0)
    info.rightShadow:SetAlpha(0)
    info.model.dungeonBG:SetAlpha(0)
    EncounterJournalEncounterFrameInfoModelFrameShadow:GwKill()

    local instanceButton = info.instanceButton
    GW.HandleIcon(instanceButton.icon, true)
    instanceButton.icon:SetTexCoord(0, 1, 0, 1)
    instanceButton:SetNormalTexture("")
    instanceButton:SetHighlightTexture("")
    instanceButton:ClearAllPoints()
    instanceButton:SetPoint("TOPLEFT", info, "TOPLEFT", 0, 0)
    info.instanceTitle:ClearAllPoints()
    info.instanceTitle:SetPoint("BOTTOM", info.bossesScroll, "TOP", 10, 15)

    local difficulty = info.difficulty
    difficulty:GwStripTextures()
    difficulty:ClearAllPoints()
    difficulty:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoBG, "TOPRIGHT", -5, 7)
    difficulty:GwHandleDropDownBox(nil, true, nil, 120)
    local loot = info.LootContainer
    loot.filter:ClearAllPoints()
    loot.filter:SetPoint("RIGHT", difficulty, "LEFT", -120, 0)
    loot.filter:GwHandleDropDownBox(nil, false, nil, 120)
    loot.slotFilter:GwHandleDropDownBox(nil, false, nil, 100)
    for _, toggle in ipairs({EncounterJournalEncounterFrameInfoFilterToggle, EncounterJournalEncounterFrameInfoSlotFilterToggle}) do
        SkinLightButton(toggle, true)
    end

    SkinScrollBar(info, "BossesScrollBar")
    SkinScrollBar(EncounterJournalEncounterFrameInstanceFrame, "LoreScrollBar")
    SkinScrollBar(EncounterJournalEncounterFrameInfoDetailsScrollFrame)
    SkinScrollBar(EncounterJournalEncounterFrameInfoOverviewScrollFrame)
    SkinScrollBar(loot)
    for _, scroll in ipairs({info.overviewScroll, info.detailsScroll}) do
        scroll.ScrollBar:GwSkinScrollBar()
        scroll.ScrollBar:SetWidth(3)
    end
    for _, list in ipairs({info.detailsScroll, loot, info.overviewScroll}) do
        list:SetHeight(360)
    end

    -- the tabs on the right: overview, loot, abilities, model from top to bottom
    local previous
    for _, key in ipairs({"overviewTab", "lootTab", "bossTab", "modelTab"}) do
        local tab = info[key]
        GW.HandleTabs(tab, "right", {tab.unselected, tab.selected})
        tab:ClearAllPoints()
        if previous then
            tab:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -1)
        else
            tab:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPRIGHT", 9, 0)
        end
        previous = tab
    end

    GW.SkinScrollBoxFrames(info.BossesScrollBox, SkinBossButton)
    hooksecurefunc(info.BossesScrollBox, "Update", MarkSelectedBoss)
    GW.SkinScrollBoxFrames(loot.ScrollBox, SkinLootRow)

    hooksecurefunc("EncounterJournal_SetUpOverview", SkinOverviewSection)
    hooksecurefunc("EncounterJournal_SetBullets", SkinOverviewBullets)
    hooksecurefunc("EncounterJournal_ToggleHeaders", SkinAbilitySections)

    -- white texts on our dark background
    info.detailsScroll.child.description:SetTextColor(1, 1, 1)
    info.overviewScroll.child.loreDescription:SetTextColor(1, 1, 1)
    local overview = EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:SetAlpha(0)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetFontObject("GameFontNormalLarge")
    GW.LockFontStringColor(EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle, HEADER_COLOR:GetRGB())
    overview.overviewDescription.Text:SetTextColor("P", 1, 1, 1)
    EncounterJournalEncounterFrameInfoBG:SetHeight(385)
    EncounterJournalEncounterFrameInfoBG:GwKill()
end

-- the instance page: the round instance art turned into a framed picture, white lore text
local function SkinInstanceFrame(frame)
    local art = EncounterJournalEncounterFrameInstanceFrameBG
    art:SetTexCoord(0.71, 0.06, 0.582, 0.08)
    art:SetRotation(math.rad(180))
    art:SetScale(0.7)
    art:ClearAllPoints()
    art:SetPoint("CENTER", 0, 40)
    art:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    frame.titleBG:SetAlpha(0)

    local title = EncounterJournalEncounterFrameInstanceFrameTitle
    title:ClearAllPoints()
    title:SetPoint("TOP", 0, -30)
    title:SetTextColor(1, 1, 1)
    title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint("LEFT", 55, -70)

    for _, line in ipairs({frame.LoreScrollingFont.ScrollBox.ScrollTarget:GetChildren()}) do
        if line.FontString then
            line.FontString:SetTextColor(1, 1, 1)
        end
    end
end

local ICON_BORDER = {0.45, 0.45, 0.45}
local STATUSBAR = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png"
local STATUSBAR_BG = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg.png"

local function SkinJourneyIcon(icon)
    GW.HandleIcon(icon, true, GW.BackdropTemplates.DefaultWithColorableBorder, true)
    icon.backdrop:SetBackdropBorderColor(ICON_BORDER[1], ICON_BORDER[2], ICON_BORDER[3], 1)
end

local ART_TRIM = {0.08, 0.94, 0.15, 0.85}

local function TrimArt(texture)
    if texture and not texture.gwTrimming then
        texture.gwTrimming = true -- setting the coordinates must not run us in circles
        texture:SetTexCoord(unpack(ART_TRIM))
        texture.gwTrimming = nil
    end
end

local function TrimJourneyCardArt(card)
    for _, texture in next, {normal = card.NormalTexture, pushed = card.PushedTexture, hover = card:GetHighlightTexture()} do
        TrimArt(texture)
        if not texture.gwTrimHooked then
            texture.gwTrimHooked = true
            hooksecurefunc(texture, "SetTexCoord", TrimArt)
            hooksecurefunc(texture, "SetAtlas", TrimArt)
        end
    end
end

local function SkinJourneyCard(card)
    local name = card.RenownCardFactionName or card.JourneyCardName
    if not name or card.gwSkinned then return end -- the list also holds category headers and dividers
    card.gwSkinned = true

    local hasArtwork = card.JourneyCardName ~= nil
    if hasArtwork then
        -- the atlas is set again on every refresh and takes its own coordinates along
        TrimJourneyCardArt(card)
        hooksecurefunc(card, "UpdateHighlightForState", TrimJourneyCardArt)
    else
        card.NormalTexture:SetAlpha(0)
        card.PushedTexture:SetAlpha(0)
        GW.AddDetailsBackground(card)

        local function SetHoverTexture()
            local highlight = card:GetHighlightTexture()
            highlight:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
            highlight:SetVertexColor(0.8, 0.8, 0.8, 0.35)
            highlight:SetAllPoints(card.tex)
        end
        SetHoverTexture()
        hooksecurefunc(card, "UpdateHighlightForState", SetHoverTexture)
    end

    local watchCheckbox = card.WatchedFactionToggleFrame and card.WatchedFactionToggleFrame.WatchFactionCheckbox
    if watchCheckbox then
        watchCheckbox:GwSkinCheckButton(false, 15)
        watchCheckbox.Label:SetTextColor(1, 1, 1) -- the label hangs on the checkbox, not on its frame
    end

    name:SetTextColor(1, 1, 1)
    local level = card.RenownCardFactionLevel or card.JourneyCardLevel
    if level then
        level:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end

    local bar = card.JourneyCardProgressBar
    if bar then
        bar:SetStatusBarTexture(STATUSBAR)
        bar:GetStatusBarTexture():SetVertexColor(GW.Colors.FactionBarColors[5]:GetRGB())
        bar.JourneyCardProgressBarFrame:SetAlpha(0)
        bar.JourneyCardProgressBarBG:SetAlpha(0)
        GW.AddStatusBarFrame(bar)
    end
end

local function SkinJourneyRewardCard(card)
    if card.gwSkinned then return end
    card.gwSkinned = true

    card.RewardCardBG:SetAlpha(0)
    card.RewardCardBGGlow:SetAlpha(0)
    card.RewardCardIconBorderDefault:SetAlpha(0)
    GW.AddDetailsBackground(card)
    card.RewardCardName:SetTextColor(1, 1, 1)

    local icon = card.RewardCardIcon
    if card.TextureMask then
        icon:RemoveMaskTexture(card.TextureMask) -- blizzard rounds the corners, ours are square
    end
    SkinJourneyIcon(icon)
end

local function SkinProgressDetails(details)
    if not details then return end

    if details.JourneyLevelBar then
        details.JourneyLevelBar:SetTexture(STATUSBAR_BG)
        details.JourneyLevelBar:SetVertexColor(0, 0, 0, 0.6)
    end
    if details.JourneyLevelBg then
        details.JourneyLevelBg:SetTexture(STATUSBAR_BG)
        details.JourneyLevelBg:SetVertexColor(0, 0, 0, 0.8)
    end
    if details.JourneyLevel then
        details.JourneyLevel:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end
    if details.JourneyLevelProgress then
        details.JourneyLevelProgress:SetTextColor(1, 1, 1)
    end
end

local function SkinParagonLevel(paragon)
    if not paragon then return end

    for _, key in ipairs({"Divider", "LabelBackground", "LevelFrame", "IconBorder"}) do
        if paragon[key] then
            paragon[key]:SetAlpha(0)
        end
    end
    GW.AddDetailsBackground(paragon)

    if paragon.Label then
        paragon.Label:SetTextColor(1, 1, 1)
    end
    if paragon.Level then
        paragon.Level:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end
    if paragon.Icon then
        SkinJourneyIcon(paragon.Icon)
    end
end

local function SkinRewardTrackCard(card)
    if card.gwSkinned or not card.RewardCardBG then return end
    card.gwSkinned = true

    card.RewardCardBG:SetAlpha(0)
    if card.IconBorder then
        card.IconBorder:SetAlpha(0)
    end
    GW.AddDetailsBackground(card)

    if card.Icon then
        if card.Mask then
            card.Icon:RemoveMaskTexture(card.Mask) -- blizzard rounds the icon, ours are square
        end
        SkinJourneyIcon(card.Icon)
    end
    if card.RewardName then
        card.RewardName:SetTextColor(1, 1, 1)
    end
    if card.Level then
        card.Level:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end
end

local function HookCardPool(pool, skin)
    if not pool then return end

    hooksecurefunc(pool, "Acquire", function(self)
        for card in self:EnumerateActive() do
            skin(card)
        end
    end)
end

local function HookRewardTrack(track)
    HookCardPool(track.elementPool, SkinRewardTrackCard)
end

local function SkinCompanionButton(button)
    if not button then return end

    button.NormalTexture:SetAlpha(0)
    button.PushedTexture:SetAlpha(0)
    if button.IconBorder then
        button.IconBorder:SetAlpha(0)
    end
    GW.AddDetailsBackground(button)

    if button.Icon then
        SkinJourneyIcon(button.Icon)
    end
    if button.CompanionName then
        button.CompanionName:SetTextColor(1, 1, 1)
    end

    local function SetHoverTexture()
        local highlight = button:GetHighlightTexture()
        highlight:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
        highlight:SetVertexColor(0.8, 0.8, 0.8, 0.35)
        highlight:SetAllPoints(button.tex)
    end
    SetHoverTexture()
    hooksecurefunc(button, "UpdateHighlightForState", SetHoverTexture)
end

local function SkinJourneysTab()
    local journeys = EncounterJournalJourneysFrame

    GW.HandleTrimScrollBar(journeys.ScrollBar)
    GW.HandleScrollControls(journeys)
    journeys.BorderFrame:Hide()

    journeys.JourneyProgress.LevelSkipButton:GwSkinButton(false, true)
    journeys.JourneyProgress.OverviewBtn:GwSkinButton(false, true)
    journeys.JourneyOverview.OverviewBtn:GwSkinButton(false, true)

    hooksecurefunc(journeys.JourneysList, "Update", function(scrollBox)
        scrollBox:ForEachFrame(SkinJourneyCard)
    end)

    local vaultButton = EncounterJournal.instanceSelect and EncounterJournal.instanceSelect.GreatVaultButton
    if vaultButton then
        vaultButton:GwStripTextures()
        vaultButton:GwStyleButton()
        vaultButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/greatvaultmicrobutton-up.png")
        vaultButton:GetNormalTexture():GwSetInside()
        vaultButton:SetSize(26, 26)
    end

    local progress = journeys.JourneyProgress
    SkinProgressDetails(progress.ProgressDetailsFrame)

    for _, track in ipairs({progress.RenownTrackFrame, progress.EncounterRewardProgressFrame}) do
        if track then
            if track.ClipFrame then
                SkinParagonLevel(track.ClipFrame.ParagonLevelFrame)
            end
            HookRewardTrack(track)
        end
    end

    if progress.DelvesCompanionConfigurationFrame then
        SkinCompanionButton(progress.DelvesCompanionConfigurationFrame.CompanionConfigBtn)
    end

    HookCardPool(progress.rewardPool, SkinJourneyRewardCard)
end


local function encounterJournalSkin()
    local EJ = EncounterJournal
    GW.HandlePortraitFrame(EJ)
    EJ.LootJournalItems:GwStripTextures()
    EncounterJournalMonthlyActivitiesFrame.FilterList:GwStripTextures()

    GW.CreateFrameHeaderWithBody(EJ, EncounterJournalTitleText, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon.png", {EJ.LootJournalItems, EncounterJournalMonthlyActivitiesFrame.FilterList}, nil, false, true)
    EncounterJournalTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

    EJ:SetClampedToScreen(true)
    EJ:SetClampRectInsets(0, 0, EJ.gwHeader:GetHeight() - 20, 0)

    EJ.instanceSelect.Title:SetTextColor(HEADER_COLOR:GetRGB())
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

    EJ.innertex = GW.CreateDetailsBackgroundTexture(EJ)
    EJ.innertex:SetPoint("TOPLEFT", EJ.navBar, "BOTTOMLEFT", -1, 1)
    EJ.innertex:SetPoint("BOTTOMRIGHT", EJ, "BOTTOMRIGHT", 1, -1)

    local home = EJ.navBar.homeButton
    home:GwStripTextures()
    for _, region in ipairs({home:GetRegions()}) do
        if region:IsObjectType("FontString") then
            region:SetTextColor(1, 1, 1, 1)
            region:SetShadowOffset(0, 0)
        end
    end
    home.tex = home:CreateTexture(nil, "BACKGROUND")
    home.tex:SetAllPoints(home)
    home.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightinner.png")
    home.borderFrame = CreateFrame("Frame", nil, home, "GwLightButtonBorder")
    EJ.CloseButton:SetPoint("TOPRIGHT", -10, -2)
    EncounterJournalPortrait:Show()

    GW.SkinTextBox(EJ.searchBox.Middle, EJ.searchBox.Left, EJ.searchBox.Right)
    EJ.searchBox:ClearAllPoints()
    EJ.searchBox:SetPoint("BOTTOMRIGHT", EJ.gwHeader, "BOTTOMRIGHT", -5, -30)
    EncounterJournalSearchResults:GwStripTextures()
    EncounterJournalSearchResults:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    EncounterJournalSearchBox.searchPreviewContainer:GwStripTextures()
    EncounterJournalSearchResultsCloseButton:GwSkinButton(true)
    EncounterJournalSearchResultsCloseButton:SetSize(20, 20)
    SkinScrollBar(EncounterJournalSearchResults)

    local instanceSelect = EJ.instanceSelect
    instanceSelect.bg:GwKill()
    instanceSelect.ExpansionDropdown:GwHandleDropDownBox()
    SkinScrollBar(instanceSelect)
    EncounterJournalInstanceSelectBG:SetAlpha(0)
    GW.SkinScrollBoxFrames(instanceSelect.ScrollBox, SkinInstanceTile)

    -- traveler's log
    local monthly = EncounterJournalMonthlyActivitiesFrame
    monthly.Bg:SetAlpha(0)
    monthly.HelpButton:GwKill()
    SkinScrollBar(monthly)
    SkinScrollBar(monthly.FilterList)
    monthly.HeaderContainer.Title:SetTextColor(HEADER_COLOR:GetRGB())
    monthly.HeaderContainer.Title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    monthly.HeaderContainer.Title:SetShadowColor(0, 0, 0, 0)
    monthly.HeaderContainer.Title:SetShadowOffset(1, -1)
    monthly.BarComplete.PendingRewardsText:SetTextColor(HEADER_COLOR:GetRGB())
    monthly.BarComplete.AllRewardsCollectedText:SetTextColor(HEADER_COLOR:GetRGB())

    local loaded
    hooksecurefunc(monthly.FilterList.ScrollBox, "Update", function(frame)
        GW.HandleItemListScrollBoxHover(frame)
        if not loaded then
            loaded = true
            frame.view:SetElementExtent(28)
        end
        for _, child in next, {frame.ScrollTarget:GetChildren()} do
            if not child.gwHooked then
                child.Label:SetTextColor(HEADER_COLOR:GetRGB())
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
    monthly.FilterList.ScrollBox:Update()
    hooksecurefunc(monthly.ScrollBox, "Update", function(frame)
        GW.HandleItemListScrollBoxHover(frame)
        for _, child in next, {frame.ScrollTarget:GetChildren()} do
            child.TextContainer.NameText:SetTextColor(1, 1, 1)
        end
    end)

    SkinJourneysTab()

    EJ:HookScript("OnShow", function()
        local tabInfo = {
            { EJ.JourneysTab, GameRulesUtil.EJShouldShowJourneys },
            { EJ.MonthlyActivitiesTab, GameRulesUtil.EJShouldShowTravelersLog },
            { EJ.suggestTab, GameRulesUtil.EJShouldShowSuggestedContent },
            { EJ.dungeonsTab, GameRulesUtil.EJShouldShowDungeons },
            { EJ.raidsTab, GameRulesUtil.EJShouldShowRaids },
            { EJ.LootJournalTab, GameRulesUtil.EJShouldShowItemSets },
            { EJ.TutorialsTab, GameRulesUtil.EJShouldShowTutorials },
            { EJ.DelvesTab, function() return EJ.DelvesTab end },
        }

        local previousTab
        for _, tabData in ipairs(tabInfo) do
            local tab, shouldShow = unpack(tabData)
            GW.HandleTabs(tab)
            if shouldShow() and tab then
                tab:ClearAllPoints()
                if previousTab then
                    tab:SetPoint("LEFT", previousTab, "RIGHT", 0, 0)
                else
                    tab:SetPoint("TOPLEFT", EJ, "BOTTOMLEFT", 0, 0)
                end
                previousTab = tab
            end
        end
    end)

    EJ.TutorialsFrame.Contents.StartButton:GwSkinButton(false, true)

    SkinEncounterInfo(EJ.encounter.info)
    SkinInstanceFrame(EncounterJournalEncounterFrameInstanceFrame)
    SkinSuggestions(EJ.suggestFrame)
    if GW.settings.tooltip.enabled then
        SkinRewardTooltip()
    end

    -- loot journal and item sets
    local lootJournal = EJ.LootJournal
    lootJournal:GwStripTextures()
    SkinScrollBar(lootJournal)
    local parchment = lootJournal:GetRegions()
    if parchment then
        parchment:GwKill()
    end
    local itemSets = EJ.LootJournalItems.ItemSetsFrame
    SkinScrollBar(itemSets)
    itemSets.ClassDropdown:GwHandleDropDownBox()
    GW.SkinScrollBoxFrames(itemSets.ScrollBox, SkinItemSet)
end

local function LoadEncounterJournalSkin()
    if not GW.settings.skins.encounterJournal.enabled then
        return
    end
    GW.RegisterLoadHook(encounterJournalSkin, "Blizzard_EncounterJournal", EncounterJournal)
end
GW.LoadEncounterJournalSkin = LoadEncounterJournalSkin
