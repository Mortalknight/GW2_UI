---@class GW2
local GW = select(2, ...)

local function SkinHeaders(header)
    if header.gwSkinned then
        return
    end

    if header.TopFiligree then
        header.TopFiligree:Hide()
    end

    header:SetAlpha(0.8)

    header.HighlightTexture:SetAllPoints(header.Background)
    header.HighlightTexture:SetAlpha(0)

    header.gwSkinned = true
end


local sessionCommandToButtonAtlas = {
    [_G.Enum.QuestSessionCommand.Start] = "QuestSharing-DialogIcon",
    [_G.Enum.QuestSessionCommand.Stop] = "QuestSharing-Stop-DialogIcon"
}
local function UpdateExecuteCommandAtlases(frame, command)
    frame.ExecuteSessionCommand:SetNormalTexture("")
    frame.ExecuteSessionCommand:SetPushedTexture("")
    frame.ExecuteSessionCommand:SetDisabledTexture("")
    local atlas = sessionCommandToButtonAtlas[command]
    if atlas then
        frame.ExecuteSessionCommand.normalIcon:SetAtlas(atlas)
    end
end


local function hook_NotifyDialogShow(_, dialog)
    if not dialog.gwSkinned then
        dialog:GwStripTextures()
        dialog:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        dialog.ButtonContainer.Confirm:GwSkinButton(false, true)
        dialog.ButtonContainer.Decline:GwSkinButton(false, true)
        if dialog.MinimizeButton then
            dialog.MinimizeButton:GwStripTextures()
            dialog.MinimizeButton:SetSize(16, 16)

            dialog.MinimizeButton.tex = dialog.MinimizeButton:CreateTexture(nil, "OVERLAY")
            dialog.MinimizeButton.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button.png")
            dialog.MinimizeButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button.png", "ADD")
        end
        dialog.gwSkinned = true
    end
end


-- the collapse arrow of the quest log headers; blizzards icon has the flat size of its own atlas,
-- our arrow needs a square, pointing to the side while collapsed
local function updateCollapse(self, collapsed)
    local rotation = collapsed and math.pi / 2 or 0
    self.Icon:SetSize(14, 14)
    for _, texture in ipairs({self.Icon, self:GetHighlightTexture()}) do
        texture:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        texture:SetRotation(rotation)
    end
    self:GetHighlightTexture():SetAllPoints(self.Icon)
end

local SEPARATOR = "Interface/AddOns/GW2_UI/textures/bag/bag-sep.png"
local HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"

-- a header of the quest log or the event list: a thin light frame around our separator art
local function FrameHeaderArt(owner, art)
    owner:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
    owner.backdrop:SetBackdropBorderColor(GW.Colors.SkinColors.HeaderBorder:GetRGBA())
    if art then
        art:SetTexture(SEPARATOR)
    end
end

local function SkinQuestHeader(button)
    if not button.ButtonText then return end
    FrameHeaderArt(button)
    button:SetNormalTexture(SEPARATOR)
    button:SetHighlightTexture(SEPARATOR)
    button:GetHighlightTexture():SetColorTexture(GW.Colors.SkinColors.SeparatorHighlight:GetRGBA())
    if button.CollapseButton then
        hooksecurefunc(button.CollapseButton, "UpdateCollapsedState", updateCollapse)
    end
end

-- the track checkbox of a quest: our box and tick; blizzard shows the tick while the quest is tracked
local function SkinQuestTitle(button)
    local checkbox = button.Checkbox
    if not checkbox then return end
    for _, region in ipairs({checkbox:GetRegions()}) do
        if region:IsObjectType("Texture") then
            local isTick = region == checkbox.CheckMark
            region:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/" .. (isTick and "checkboxchecked.png" or "checkbox.png"))
            region:SetSize(14, 14)
            region:ClearAllPoints()
            region:SetPoint("CENTER")
            -- the hover copy of the box only lightens it
            if region:GetDrawLayer() == "HIGHLIGHT" then
                region:SetVertexColor(1, 1, 1, 0.3)
            end
        end
    end
end

local function SkinCampaignHeader(header)
    if not header.CollapseButton then return end
    header.minimumCollapsedHeight = 25
    FrameHeaderArt(header.Background, header.Background)
    header.Highlight:SetTexture(SEPARATOR)
    header.Highlight:SetColorTexture(GW.Colors.SkinColors.SeparatorHighlight:GetRGBA())
    hooksecurefunc(header.CollapseButton, "UpdateCollapsedState", updateCollapse)
end

-- the quest log builds its rows from pools on every update
local function hook_QuestLogQuests_Update()
    GW.SkinPoolFrames(QuestScrollFrame.headerFramePool, SkinQuestHeader)
    GW.SkinPoolFrames(QuestScrollFrame.titleFramePool, SkinQuestTitle)
    GW.SkinPoolFrames(QuestScrollFrame.campaignHeaderMinimalFramePool, SkinCampaignHeader)
end


local function mover_OnDragStart(self)
    self:GetParent():StartMoving()
end


local function mover_OnDragStop(self)
    self:GetParent():StopMovingOrSizing()
end


-- the event list of the map: headers like the quest log, events with the hover of our lists
local function SetEventHover(texture)
    texture:SetTexture(HOVER)
    texture:SetVertexColor(GW.Colors.SkinColors.ListHover:GetRGBA())
end

-- ongoing events set their background atlas again on every refresh
local function KeepEventBackground(background)
    SetEventHover(background)
    local event = background:GetParent()
    if event and event.Highlight then
        SetEventHover(event.Highlight)
    end
end

local function SkinEventHeader(header)
    if not header.Background.backdrop then
        header.Background:GwStripTextures()
        FrameHeaderArt(header.Background, header.Background)
    end
    header.Label:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
end

local hookedEventBackgrounds = setmetatable({}, {__mode = "k"})
local function SkinOngoingEvent(event)
    if not hookedEventBackgrounds[event.Background] then
        hookedEventBackgrounds[event.Background] = true
        hooksecurefunc(event.Background, "SetAtlas", KeepEventBackground)
    end
end

local function SkinScheduledEvent(event)
    if not event.Highlight then return end
    if not event.gwHoverAdded then
        event.gwHoverAdded = true
        GW.AddListItemChildHoverTexture(event)
    end
    SetEventHover(event.Highlight)
end

-- by entry type: ongoing header, ongoing event, scheduled header, scheduled event
local EVENT_ROW_SKINS = {SkinEventHeader, SkinOngoingEvent, SkinEventHeader, SkinScheduledEvent}

local function SkinEventRow(row, elementData)
    local data = elementData and elementData.data
    local skin = data and EVENT_ROW_SKINS[data.entryType]
    if skin then
        skin(row)
    end
end

-- the quest model beside the map goes with the quest log, like blizzards QuestFrame_HideQuestPortrait
local function WorldMap_QuestMapHide(self)
	if self:GetParent() == QuestModelScene:GetParent() then -- variant of QuestFrame_HideQuestPortrait
		QuestModelScene:SetParent(nil)
		QuestModelScene:Hide()
	end
end

local function worldMapSkin()
    WorldMapFrame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(WorldMapFrame, WorldMapFrameTitleText, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png", {QuestMapFrame}, nil, false, true)

    WorldMapFrame.gwBodyEdge = WorldMapFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    WorldMapFrame.gwBodyEdge:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-background.png")
    WorldMapFrame.gwBodyEdge:SetTexCoord(0.6, 0.65, 0, 1)
    WorldMapFrame.gwBodyEdge:SetWidth(12)
    WorldMapFrame.gwBodyEdge:Hide()
    if WorldMapFrame.backgroundMask then
        WorldMapFrame.gwBodyEdge:AddMaskTexture(WorldMapFrame.backgroundMask)
    end
    WorldMapFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

    WorldMapFrame.BorderFrame:GwStripTextures()
    WorldMapFrame.BorderFrame:SetFrameStrata(WorldMapFrame:GetFrameStrata())
    WorldMapFrame.BorderFrame.NineSlice:Hide()

    WorldMapFrame.NavBar:GwStripTextures()
    WorldMapFrame.NavBar.overlay:GwStripTextures()
    WorldMapFrame.NavBar:SetPoint("TOPLEFT", 1, -47)

    GW.HandleNavBarButtons(WorldMapFrame.NavBar, nil, true)

    WorldMapFrame.NavBar.tex = WorldMapFrame.NavBar:CreateTexture(nil, "BACKGROUND", nil, 0)
    WorldMapFrame.NavBar.tex:SetPoint("TOPLEFT", WorldMapFrame.NavBar, "TOPLEFT", 0,20)
    WorldMapFrame.NavBar.tex:SetPoint("BOTTOMRIGHT", WorldMapFrame.NavBar, "BOTTOMRIGHT", 0, -10)
    WorldMapFrame.NavBar.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-header.png")

    WorldMapFrame.NavBar.homeButton:GwStripTextures()
    local r = {WorldMapFrame.NavBar.homeButton:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:SetTextColor(GW.Colors.FallbackWhite:GetRGBA())
            c:SetShadowOffset(0, 0)
        end
    end

    WorldMapFrame.NavBar.homeButton.tex = WorldMapFrame.NavBar.homeButton:CreateTexture(nil, "BACKGROUND")
    WorldMapFrame.NavBar.homeButton.tex :SetPoint("LEFT", WorldMapFrame.NavBar.homeButton, "LEFT")
    WorldMapFrame.NavBar.homeButton.tex :SetPoint("TOP", WorldMapFrame.NavBar.homeButton, "TOP")
    WorldMapFrame.NavBar.homeButton.tex :SetPoint("BOTTOM", WorldMapFrame.NavBar.homeButton, "BOTTOM")
    WorldMapFrame.NavBar.homeButton.tex :SetPoint("RIGHT", WorldMapFrame.NavBar.homeButton, "RIGHT")
    WorldMapFrame.NavBar.homeButton.tex :SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightinner.png")
    WorldMapFrame.NavBar.homeButton.tex:SetAlpha(1)
    WorldMapFrame.NavBar.homeButton.borderFrame = CreateFrame("Frame", nil, WorldMapFrame.NavBar.homeButton, "GwLightButtonBorder")

    WorldMapFrame.ScrollContainer:GwCreateBackdrop()
    QuestMapFrame:SetPoint("TOPRIGHT",WorldMapFrame,"TOPRIGHT",-3,-32)

    WorldMapFrame.BorderFrame.CloseButton:GwSkinButton(true)
    WorldMapFrame.BorderFrame.CloseButton:SetSize(20, 20)
    WorldMapFrame.BorderFrame.CloseButton:SetPoint("TOPRIGHT",-10,-2)

    WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:GwHandleMaxMinFrame()

    local QuestMapFrame = _G.QuestMapFrame
    QuestMapFrame.VerticalSeparator:Hide()
    QuestMapFrame:SetScript("OnHide", WorldMap_QuestMapHide)

    QuestMapFrame.DetailsFrame:GwStripTextures(true)

    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame:GwStripTextures()
    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame:GwCreateBackdrop(GW.BackdropTemplates.DopwDown)
    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame.backdrop:SetPoint("TOPLEFT", -3, -14)
    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame.backdrop:SetPoint("BOTTOMRIGHT", -1, 1)
    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame.backdrop:SetBackdropColor(GW.Colors.Fallback:GetRGBA())

    QuestMapFrame.DetailsFrame.BackFrame:GwStripTextures()
    QuestMapFrame.DetailsFrame.BackFrame.BackButton:GwSkinButton(false, true)
    QuestMapFrame.DetailsFrame.BackFrame.BackButton:SetFrameLevel(5)
    QuestMapFrame.DetailsFrame.AbandonButton:GwStripTextures()
    QuestMapFrame.DetailsFrame.AbandonButton:GwSkinButton(false, true)
    QuestMapFrame.DetailsFrame.AbandonButton:GwSkinNegativeButton()
    QuestMapFrame.DetailsFrame.AbandonButton:SetFrameLevel(5)
    QuestMapFrame.DetailsFrame.ShareButton:GwStripTextures()
    QuestMapFrame.DetailsFrame.ShareButton:GwSkinButton(false, true)
    QuestMapFrame.DetailsFrame.ShareButton:SetFrameLevel(5)
    QuestMapFrame.DetailsFrame.TrackButton:GwStripTextures()
    QuestMapFrame.DetailsFrame.TrackButton:GwSkinButton(false, true)
    QuestMapFrame.DetailsFrame.TrackButton:SetFrameLevel(5)
    QuestMapFrame.DetailsFrame.TrackButton:SetWidth(95)

    if QuestMapFrame.DetailsFrame.SealMaterialBG then
        QuestMapFrame.DetailsFrame.SealMaterialBG:SetAlpha(0)
    end

    if QuestMapFrame.Background then
        QuestMapFrame.Background:SetAlpha(0)
    end

    for _, frame in pairs({"HonorFrame", "XPFrame", "SpellFrame", "SkillPointFrame", "ArtifactXPFrame", "TitleFrame", "WarModeBonusFrame"}) do
        GW.HandleItemReward(_G.MapQuestInfoRewardsFrame[frame], true)
    end
    GW.HandleItemReward(_G.MapQuestInfoRewardsFrame.MoneyFrame, true)

    if not GW.QuestInfo_Display_hooked then
        hooksecurefunc("QuestInfo_Display", GW.QuestInfo_Display)
        GW.QuestInfo_Display_hooked = true
    end

    QuestScrollFrame.Contents.Separator.Divider:Hide()
    QuestScrollFrame.Edge:SetAlpha(0)
    QuestScrollFrame.BorderFrame:SetAlpha(0)
    QuestScrollFrame.Background:SetAlpha(0)
    GW.SkinTextBox(QuestScrollFrame.SearchBox.Middle, QuestScrollFrame.SearchBox.Left, QuestScrollFrame.SearchBox.Right)
    -- the quest count pill next to the search box: same input box art, forever shows it
    -- (QuestLogQuests_ShowQuestCount), retail keeps it hidden
    if QuestLogCount and QuestLogCount.Middle then
        GW.SkinTextBox(QuestLogCount.Middle, QuestLogCount.Left, QuestLogCount.Right)
        if QuestLogQuestCount then
            -- blizzard only colors the numbers, the label keeps the font objects yellow
            QuestLogQuestCount:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
            QuestLogQuestCount:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        end
    end

    SkinHeaders(QuestScrollFrame.Contents.StoryHeader)
    QuestScrollFrame.ScrollBar:GwSkinScrollBar()
    QuestScrollFrame:GwSkinScrollFrame()

    GW.HandleTrimScrollBar(QuestScrollFrame.ScrollBar)
    GW.HandleScrollControls(QuestScrollFrame)

    GW.HandleTrimScrollBar(QuestMapDetailsScrollFrame.ScrollBar)
    GW.HandleScrollControls(QuestMapDetailsScrollFrame)

    GW.HandleNextPrevButton(WorldMapFrame.SidePanelToggle.CloseButton, "left")
    GW.HandleNextPrevButton(WorldMapFrame.SidePanelToggle.OpenButton, "right")

    WorldMapFrame.BorderFrame.Tutorial:GwKill()

    do
        -- the overlay frames are positional on retail; forever stores the two tracking
        -- buttons as fields and may leave either out by game rule
        local overlays = WorldMapFrame.overlayFrames
        local dropdown = overlays[1]
        local Tracking = WorldMapFrame.WorldMapTrackingOptionsButton or overlays[2]
        local Pin = WorldMapFrame.WorldMapTrackingPinButton or overlays[3]
        dropdown:GwHandleDropDownBox()

        if Tracking and Tracking.Icon then
            local function SetTrackingIcon()
                Tracking.Icon:SetTexture(136460) -- Interface\Minimap\Tracking/None
            end
            SetTrackingIcon()
            -- the plain tracking icon glows on hover
            Tracking:SetHighlightTexture(136460, "ADD")
            Tracking:GetHighlightTexture():SetAllPoints(Tracking.Icon)

            if not Tracking.Background then
                -- forever: a bare dropdown atlas button without the round minimap art of
                -- retail, and it swaps its icon atlas on every click - keep our icon on it,
                -- centered and plain like the pin button next to it
                hooksecurefunc(Tracking.Icon, "SetAtlas", SetTrackingIcon)
                Tracking.Icon:ClearAllPoints()
                Tracking.Icon:SetPoint("CENTER", Tracking, "CENTER", 0, 0)
                Tracking.Icon:SetSize(20, 20)
            end
        end

        -- the waypoint pin without its round frame, the tracked pin over it, the pin itself glowing on hover
        if Pin and Pin.Icon then
            Pin.Icon:SetAtlas("Waypoint-MapPin-Untracked")
            Pin.ActiveTexture:SetAtlas("Waypoint-MapPin-Tracked")
            Pin.ActiveTexture:SetAllPoints(Pin.Icon)
            Pin:SetHighlightTexture(3500068, "ADD") -- Interface\Waypoint\WaypoinMapPinUI, the pin part of it
            local glow = Pin:GetHighlightTexture()
            glow:SetAllPoints(Pin.Icon)
            glow:SetTexCoord(0.3203125, 0.5546875, 0.015625, 0.484375)
        end
    end

    QuestMapFrame.QuestSessionManagement:GwStripTextures()

    local ExecuteSessionCommand = QuestMapFrame.QuestSessionManagement.ExecuteSessionCommand
    ExecuteSessionCommand:GwStripTextures()
    ExecuteSessionCommand:GwStyleButton()

    local icon = ExecuteSessionCommand:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 0, 0)
    icon:SetPoint("BOTTOMRIGHT", 0, 0)
    ExecuteSessionCommand.normalIcon = icon

    hooksecurefunc(QuestMapFrame.QuestSessionManagement, "UpdateExecuteCommandAtlases", UpdateExecuteCommandAtlases)
    hooksecurefunc(QuestSessionManager, "NotifyDialogShow", hook_NotifyDialogShow)
    hooksecurefunc("QuestLogQuests_Update", hook_QuestLogQuests_Update)

    -- Addons
    if _G["AtlasLootToggleFromWorldMap2"] then
        local button = _G["AtlasLootToggleFromWorldMap2"]
        button:SetNormalTexture("Interface/Icons/INV_Box_01")
        button:SetWidth(16)
        button:SetHeight(16)
        button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")
    end

    -- player pin
    for pin in WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate") do
        pin:SetPinTexture("player", "Interface/AddOns/GW2_UI/textures/icons/player_arrow.png")
        pin.dataProvider:GetUnitPinSizesTable().player = 34
        pin:SynchronizePinSizes()
        break
    end

    -- Mover
    if not GW.HasDeModal then
        WorldMapFrame.mover = CreateFrame("Frame", nil, WorldMapFrame)
        WorldMapFrame.mover:EnableMouse(true)
        WorldMapFrame:SetMovable(true)
        WorldMapFrame.mover:SetSize(WorldMapFrame:GetWidth(), 30)
        WorldMapFrame.mover:SetPoint("BOTTOMLEFT", WorldMapFrame, "TOPLEFT", 0, -20)
        WorldMapFrame.mover:SetPoint("BOTTOMRIGHT", WorldMapFrame, "TOPRIGHT", 0, 20)
        WorldMapFrame.mover:RegisterForDrag("LeftButton")
        WorldMapFrame.mover:SetScript("OnDragStart", mover_OnDragStart)
        WorldMapFrame.mover:SetScript("OnDragStop", mover_OnDragStop)
    end

    if InCombatLockdown() then
        GW.CombatQueue:Queue("WorldMapClampedToScreen", function()
            WorldMapFrame:SetClampedToScreen(true)
            WorldMapFrame:SetClampRectInsets(0, 0, WorldMapFrameHeader:GetHeight() - 30, 0)
        end)
    else
        WorldMapFrame:SetClampedToScreen(true)
        WorldMapFrame:SetClampRectInsets(0, 0, WorldMapFrameHeader:GetHeight() - 30, 0)
    end

    -- 11.0 Map Legend
    QuestMapFrame.MapLegend.TitleText:SetFont(STANDARD_TEXT_FONT, 16)
    QuestMapFrame.MapLegend.BorderFrame:SetAlpha(0)
    MapLegendScrollFrame:GwStripTextures()
    MapLegendScrollFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    GW.HandleTrimScrollBar(MapLegendScrollFrame.ScrollBar)
    -- 11.1 Side Tabs
    local function SkinQuestMapTab(tab, lastTab)
        GW.HandleTabs(tab, "right", {tab.Icon}, true)
        tab:ClearAllPoints()
        if lastTab then
            tab:SetPoint("TOP", lastTab, "BOTTOM", 0, 1)
        else
            tab:SetPoint("TOPLEFT", QuestMapFrame, "TOPRIGHT", 0, -28)
        end

        -- straight body edge behind the tab column, see gwBodyEdge above
        local edge = WorldMapFrame.gwBodyEdge
        if edge then
            if not lastTab then
                edge:ClearAllPoints()
                edge:SetPoint("RIGHT", WorldMapFrame.tex, "RIGHT", 0, 0)
                edge:SetPoint("TOP", tab, "TOP", 0, 2)
            end
            edge:SetPoint("BOTTOM", tab, "BOTTOM", 0, -2)
            edge:Show()
        end
    end

    local lastTab = nil
    for _, tab in ipairs(QuestMapFrame.TabButtons) do
        SkinQuestMapTab(tab, lastTab)
        lastTab = tab
    end
    -- add a delay here so that other addons can add there tabs to that array
    C_Timer.After(2, function()
        lastTab = nil
        for _, tab in ipairs(QuestMapFrame.TabButtons) do
            SkinQuestMapTab(tab, lastTab)
            lastTab = tab
        end

        if C_AddOns.IsAddOnLoaded("WorldQuestTab") then
            SkinQuestMapTab(WQT_QuestMapTab, lastTab)

            FML:GwHandleDropDownBox()
            WQT_ListContainer.TopBar.FilterDropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true)
            WQT_ListContainer.TopBar.FilterDropdown:SetWidth(125)
            GW.HandleTrimScrollBar(WQT_ListContainer.ScrollBar)
            GW.HandleScrollControls(WQT_ListContainer)
            WQTBorder:GwStripTextures()
            WQT_ListContainer.Background:GwKill()
            WQT_ListContainer:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        end
    end)

    -- 11.1 Event Tab
    QuestMapFrame.EventsFrame.TitleText:SetFont(STANDARD_TEXT_FONT, 16)
    QuestMapFrame.EventsFrame.BorderFrame:SetAlpha(0)
    QuestMapFrame.EventsFrame:GwStripTextures()
    QuestMapFrame.EventsFrame.ScrollBox.Background:SetDrawLayer("BACKGROUND", -1)
    QuestMapFrame.EventsFrame.ScrollBox.Background:SetVertexColor(1, 0, 1)
    QuestMapFrame.EventsFrame.ScrollBox.Background:SetAlpha(0.9)
    QuestMapFrame.EventsFrame.ScrollBox:GwStripTextures()
    QuestMapFrame.EventsFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    for _, region in next, { QuestMapFrame.EventsFrame:GetRegions() } do
        if region:IsObjectType("Texture") then
            region:Hide()

            break
        end
    end

    GW.HandleTrimScrollBar(QuestMapFrame.EventsFrame.ScrollBar)

    -- ForEachFrame hands out (row, data), the acquired callback (owner, row, data)
    local eventsBox = QuestMapFrame.EventsFrame.ScrollBox
    eventsBox:ForEachFrame(SkinEventRow)
    ScrollUtil.AddAcquiredFrameCallback(eventsBox, function(_, row, elementData) SkinEventRow(row, elementData) end, QuestMapFrame.EventsFrame)
end

local function LoadWorldMapSkin()
    if not GW.settings.skins.worldmap.enabled then return end

    GW.RegisterLoadHook(worldMapSkin, "Blizzard_WorldMap", WorldMapFrame)
end
GW.LoadWorldMapSkin = LoadWorldMapSkin
