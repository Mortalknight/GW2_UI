local _, GW = ...

local function SkinHeaders(header)
    if header.IsSkinned then
        return
    end

    if header.TopFiligree then
        header.TopFiligree:Hide()
    end

    header:SetAlpha(0.8)

    header.HighlightTexture:SetAllPoints(header.Background)
    header.HighlightTexture:SetAlpha(0)

    header.IsSkinned = true
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
    if not dialog.isSkinned then
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
        dialog.isSkinned = true
    end
end


local function updateCollapse(self, collapsed)
    if collapsed then
        self.Icon:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        self.Icon:SetRotation(1.570796325)
        self:GetHighlightTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        self:GetHighlightTexture():SetRotation(1.570796325)
    else
        self.Icon:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        self.Icon:SetRotation(0)
        self:GetHighlightTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        self:GetHighlightTexture():SetRotation(0)
    end
end

local function hook_QuestLogQuests_Update()
    for button in QuestScrollFrame.headerFramePool:EnumerateActive() do
        if button.ButtonText then
            if not button.IsSkinned then
                button:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
                button.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
                button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
                button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
                button:GetHighlightTexture():SetColorTexture(1, 0.93, 0.73, 0.25)

                if button.CollapseButton then
                    hooksecurefunc(button.CollapseButton, "UpdateCollapsedState", updateCollapse)
                end

                button.IsSkinned = true
            end
        end
    end

    for button in QuestScrollFrame.titleFramePool:EnumerateActive() do
        if not button.IsSkinned then
            if button.Checkbox then
                button.Checkbox:DisableDrawLayer("BACKGROUND")
                hooksecurefunc(button.Checkbox.CheckMark, "SetShown", function(self, isTracked)
                    self:Show()
                    if isTracked then
                        self:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png")
                    else
                        self:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png")
                    end
                end)
            end

            button.IsSkinned = true
        end
    end

    for header in QuestScrollFrame.campaignHeaderMinimalFramePool:EnumerateActive() do
        if header.CollapseButton and not header.IsSkinned then
            header.minimumCollapsedHeight = 25
            header.Background:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
            header.Background.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
            header.Background:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
            header.Highlight:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
            header.Highlight:SetColorTexture(1, 0.93, 0.73, 0.25)
            hooksecurefunc(header.CollapseButton, "UpdateCollapsedState", updateCollapse)
            header.IsSkinned = true
        end
    end
end


local function mover_OnDragStart(self)
    self:GetParent():StartMoving()
end


local function mover_OnDragStop(self)
    self:GetParent():StopMovingOrSizing()
end


local EventsFrameHookedElements = {}
local function EventsFrameHighlightTexture(element)
    element:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    element:SetVertexColor(0.8, 0.8, 0.8, 0.8)
end

local function EventsFrameBackgroundNormal(element, texture)
    if texture ~= "Interface/AddOns/GW2_UI/textures/character/menu-hover.png" then
        element:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
        element:SetVertexColor(0.8, 0.8, 0.8, 0.8)

        local parent = element:GetParent()
        if parent and parent.Highlight then
            EventsFrameHighlightTexture(parent.Highlight)
        end
    end
end

local EventsFrameFunctions = {
    function(element) -- 1: OngoingHeader
        if not element.Background.backdrop then
            element.Background:GwStripTextures()
            element.Background:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
            element.Background.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
            element.Background:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
        end

        element.Label:SetTextColor(1, 1, 1)
    end,
    function(element) -- 2: OngoingEvent
        if not EventsFrameHookedElements[element] then
            hooksecurefunc(element.Background, "SetAtlas", EventsFrameBackgroundNormal)
            EventsFrameHookedElements[element] = element.Background
        end
    end,
    function(element) -- 3: ScheduledHeader
        if not element.Background.backdrop then
            element.Background:GwStripTextures()
            element.Background:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
            element.Background.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
            element.Background:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
        end

        element.Label:SetTextColor(1, 1, 1)
    end,
    function(element) -- 4: ScheduledEvent
        if element.Highlight then
            if not element.IsSkinned then
                GW.AddListItemChildHoverTexture(element)

                element.IsSkinned = true
            end
            EventsFrameHighlightTexture(element.Highlight)
        end
    end
}

local function EventsFrameCallback(_, frame, elementData)
    if not elementData.data then return end

    local func = EventsFrameFunctions[elementData.data.entryType]
    if func then
        func(frame)
    end
end

local function worldMapSkin()
    WorldMapFrame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(WorldMapFrame, WorldMapFrameTitleText, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png", {QuestMapFrame}, nil, false, true)
    WorldMapFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    WorldMapFrame.BorderFrame:GwStripTextures()
    WorldMapFrame.BorderFrame:SetFrameStrata(WorldMapFrame:GetFrameStrata())
    WorldMapFrame.BorderFrame.NineSlice:Hide()
    WorldMapFrame.NavBar:GwStripTextures()
    WorldMapFrame.NavBar.overlay:GwStripTextures()
    WorldMapFrame.NavBar:SetPoint("TOPLEFT", 1, -47)
    hooksecurefunc(WorldMapFrame.NavBar, "SetPoint", function(self)
        local point, relTo, _, x, y = self:GetPoint()
        if point ~= "TOPLEFT" or x ~= 1 or y ~= -47 then
            self:SetPoint("TOPLEFT", relTo, "TOPLEFT", 1, -47)
        end
    end)

    local navBarTex = WorldMapFrame.NavBar:CreateTexture(nil, "BACKGROUND", nil, 0)
    navBarTex:SetPoint("TOPLEFT", WorldMapFrame.NavBar, "TOPLEFT", 0,20)
    navBarTex:SetPoint("BOTTOMRIGHT", WorldMapFrame.NavBar, "BOTTOMRIGHT", 0, -10)
    navBarTex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-header.png")
    WorldMapFrame.NavBar.tex = navBarTex

    WorldMapFrame.ScrollContainer:GwCreateBackdrop()

    QuestMapFrame:SetPoint("TOPRIGHT",WorldMapFrame,"TOPRIGHT",-3,-32)

    WorldMapFrame.NavBar.homeButton:GwStripTextures()
    local r = {WorldMapFrame.NavBar.homeButton:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:SetTextColor(1, 1, 1, 1)
            c:SetShadowOffset(0, 0)
        end
    end
    local tex = WorldMapFrame.NavBar.homeButton:CreateTexture(nil, "BACKGROUND")
    tex:SetPoint("LEFT", WorldMapFrame.NavBar.homeButton, "LEFT")
    tex:SetPoint("TOP", WorldMapFrame.NavBar.homeButton, "TOP")
    tex:SetPoint("BOTTOM", WorldMapFrame.NavBar.homeButton, "BOTTOM")
    tex:SetPoint("RIGHT", WorldMapFrame.NavBar.homeButton, "RIGHT")
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightinner.png")
    WorldMapFrame.NavBar.homeButton.tex = tex
    WorldMapFrame.NavBar.homeButton.tex:SetAlpha(1)

    WorldMapFrame.NavBar.homeButton.borderFrame = CreateFrame("Frame", nil, WorldMapFrame.NavBar.homeButton, "GwLightButtonBorder")

    WorldMapFrame.BorderFrame.CloseButton:GwSkinButton(true)
    WorldMapFrame.BorderFrame.CloseButton:SetSize(20, 20)
    WorldMapFrame.BorderFrame.CloseButton:SetPoint("TOPRIGHT",-10,-2)

    WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:GwHandleMaxMinFrame()

    

    local QuestMapFrame = _G.QuestMapFrame
    QuestMapFrame.VerticalSeparator:Hide()
    QuestMapFrame:SetScript("OnHide", nil)

    QuestMapFrame.DetailsFrame:GwStripTextures(true)

    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame:GwStripTextures()
    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame:GwCreateBackdrop(GW.BackdropTemplates.DopwDown)
    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame.backdrop:SetPoint("TOPLEFT", -3, -14)
    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame.backdrop:SetPoint("BOTTOMRIGHT", -1, 1)
    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame.backdrop:SetBackdropColor(0, 0, 0, 1)

    QuestMapFrame.DetailsFrame.BackFrame:GwStripTextures()
    QuestMapFrame.DetailsFrame.BackFrame.BackButton:GwSkinButton(false, true)
    QuestMapFrame.DetailsFrame.BackFrame.BackButton:SetFrameLevel(5)
    QuestMapFrame.DetailsFrame.AbandonButton:GwStripTextures()
    QuestMapFrame.DetailsFrame.AbandonButton:GwSkinButton(false, true)
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

    SkinHeaders(QuestScrollFrame.Contents.StoryHeader)
    QuestScrollFrame.ScrollBar:GwSkinScrollBar()
    QuestScrollFrame:GwSkinScrollFrame()

    GW.HandleTrimScrollBar(QuestScrollFrame.ScrollBar, true)
    GW.HandleScrollControls(QuestScrollFrame)

    GW.HandleTrimScrollBar(QuestMapDetailsScrollFrame.ScrollBar, true)
    GW.HandleScrollControls(QuestMapDetailsScrollFrame)

    GW.HandleNextPrevButton(WorldMapFrame.SidePanelToggle.CloseButton, "left")
    GW.HandleNextPrevButton(WorldMapFrame.SidePanelToggle.OpenButton, "right")

    WorldMapFrame.BorderFrame.Tutorial:GwKill()

    do
        local dropdown, Tracking, Pin = unpack(WorldMapFrame.overlayFrames)
        dropdown:GwHandleDropDownBox()

        Tracking.Icon:SetTexture(136460) -- Interface\Minimap\Tracking/None
        Tracking:SetHighlightTexture(136460, "ADD")

        local TrackingHighlight = Tracking:GetHighlightTexture()
        TrackingHighlight:SetAllPoints(Tracking.Icon)

        Pin.Icon:SetAtlas("Waypoint-MapPin-Untracked")
        Pin.ActiveTexture:SetAtlas("Waypoint-MapPin-Tracked")
        Pin.ActiveTexture:SetAllPoints(Pin.Icon)
        Pin:SetHighlightTexture(3500068, "ADD") -- Interface\Waypoint\WaypoinMapPinUI

        local PinHighlight = Pin:GetHighlightTexture()
        PinHighlight:SetAllPoints(Pin.Icon)
        PinHighlight:SetTexCoord(0.3203125, 0.5546875, 0.015625, 0.484375)
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

    WorldMapFrame:SetClampedToScreen(true)
    WorldMapFrame:SetClampRectInsets(0, 0, WorldMapFrameHeader:GetHeight() - 30, 0)

    -- 11.0 Map Legend
    QuestMapFrame.MapLegend.TitleText:SetFont(STANDARD_TEXT_FONT, 16)
    QuestMapFrame.MapLegend.BorderFrame:SetAlpha(0)
    MapLegendScrollFrame:GwStripTextures()
    MapLegendScrollFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    GW.HandleTrimScrollBar(MapLegendScrollFrame.ScrollBar)
    -- 11.1 Side Tabs
    local lastTab = nil
    for idx, tab in ipairs (QuestMapFrame.TabButtons) do
        GW.HandleTabs(tab, "right", {tab.Icon}, true)
        if idx > 1 then
            tab:ClearAllPoints()
            tab:SetPoint("TOP", lastTab, "BOTTOM", 0, 1)
        end
        lastTab = tab
    end
    -- add a delay here so that other addons can add there tabs to that array
    C_Timer.After(2, function()
        for idx, tab in ipairs (QuestMapFrame.TabButtons) do
            GW.HandleTabs(tab, "right", {tab.Icon}, true)
            if idx > 1 then
                tab:ClearAllPoints()
                tab:SetPoint("TOP", lastTab, "BOTTOM", 0, 1)
            end
            lastTab = tab
        end

        if C_AddOns.IsAddOnLoaded("WorldQuestTab") then
            GW.HandleTabs(WQT_QuestMapTab, "right", {WQT_QuestMapTab.Icon}, true)
            WQT_QuestMapTab:ClearAllPoints()
            WQT_QuestMapTab:SetPoint("TOP", lastTab, "BOTTOM", 0, 1)

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

    ScrollUtil.AddAcquiredFrameCallback(QuestMapFrame.EventsFrame.ScrollBox, EventsFrameCallback, QuestMapFrame.EventsFrame, true)
end

local function LoadWorldMapSkin()
    if not GW.settings.WORLDMAP_SKIN_ENABLED then return end

    GW.RegisterLoadHook(worldMapSkin, "Blizzard_WorldMap", WorldMapFrame)
end
GW.LoadWorldMapSkin = LoadWorldMapSkin
