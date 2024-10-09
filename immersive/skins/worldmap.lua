local _, GW = ...
local AFP = GW.AddProfiling

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
AFP("SkinHeaders", SkinHeaders)

local function handleReward(frame, isMap)
    if not frame then
        return
    end

    if frame.Icon then
        frame.Icon:SetDrawLayer("ARTWORK")
        frame.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        frame.Icon:SetAlpha(0.9)
    end

    if frame.IconBorder then
        frame.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    end

    if frame.Count then
        frame.Count:SetDrawLayer("OVERLAY")
        frame.Count:ClearAllPoints()
        frame.Count:SetPoint("TOPRIGHT", frame.Icon, "TOPRIGHT", 0, -3)
        frame.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "THINOUTLINE")
        frame.Count:SetJustifyH("RIGHT")
    end

    if frame.NameFrame then
        if isMap then
            frame.NameFrame:SetAlpha(0)
            --frame.NameFrame:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/nameframe-map")
        else
            frame.NameFrame:SetAlpha(0.75)
            frame.NameFrame:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/nameframe")
        end
    end

    if frame.Name then
        frame.Name:SetTextColor(1, 1, 1)
    end

    if frame.IconOverlay then
        frame.IconOverlay:SetAlpha(0)
    end

    if frame.CircleBackground then
        frame.CircleBackground:SetAlpha(0)
        frame.CircleBackgroundGlow:SetAlpha(0)
    end

    for i = 1, frame:GetNumRegions() do
        local Region = select(i, frame:GetRegions())
        if Region and Region:IsObjectType("Texture") and Region:GetTexture() == [[Interface\Spellbook\Spellbook-Parts]] then
            Region:SetTexture("")
        end
    end
end
GW.HandleReward = handleReward

local function QuestInfo_Display(template, parentFrame)
    if not GW.settings.GOSSIP_SKIN_ENABLED and not GW.settings.QUESTVIEW_ENABLED and (template == QUEST_TEMPLATE_DETAIL or template == QUEST_TEMPLATE_REWARD or template == QUEST_TEMPLATE_LOG) then
        return
    end
    local isMapStyle = false
    if template == QUEST_TEMPLATE_MAP_DETAILS or template == QUEST_TEMPLATE_MAP_REWARDS then
        if not GW.settings.WORLDMAP_SKIN_ENABLED then
            return
        end
        isMapStyle = true
    end

    local fInfo = _G.QuestInfoFrame
    local fRwd = fInfo.rewardsFrame
    local questID
    local questFrame = parentFrame:GetParent():GetParent()
    if template.questLog then
        questID = questFrame.questID
    else
        questID = GetQuestID();
    end

    for i, questItem in ipairs(fRwd.RewardButtons) do
        local point, relativeTo, relativePoint, _, y = questItem:GetPoint()
        if point and relativeTo and relativePoint then
            if i == 1 then
                questItem:SetPoint(point, relativeTo, relativePoint, 0, y)
            elseif relativePoint == "BOTTOMLEFT" then
                questItem:SetPoint(point, relativeTo, relativePoint, 0, -4)
            else
                questItem:SetPoint(point, relativeTo, relativePoint, 4, 0)
            end
        end

        handleReward(questItem, isMapStyle)
    end

    local spellRewards = C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}
    --local numSpellRewards = isQuestLog and GetNumQuestLogRewardSpells() or GetNumRewardSpells()
    if #spellRewards > 0 then
        for spellHeader in fRwd.spellHeaderPool:EnumerateActive() do
            spellHeader:SetVertexColor(1, 1, 1)
        end
        for spellIcon in fRwd.spellRewardPool:EnumerateActive() do
            handleReward(spellIcon, isMapStyle)
        end

        for followerReward in fRwd.followerRewardPool:EnumerateActive() do
            if not followerReward.isSkinned then
                followerReward:GwCreateBackdrop()
                followerReward.backdrop:SetAllPoints(followerReward.BG)
                followerReward.backdrop:SetPoint("TOPLEFT", 40, -5)
                followerReward.backdrop:SetPoint("BOTTOMRIGHT", 2, 5)
                followerReward.BG:Hide()

                followerReward.PortraitFrame:ClearAllPoints()
                followerReward.PortraitFrame:SetPoint("RIGHT", followerReward.backdrop, "LEFT", -2, 0)

                followerReward.PortraitFrame.PortraitRing:Hide()
                followerReward.PortraitFrame.PortraitRingQuality:SetTexture()
                followerReward.PortraitFrame.LevelBorder:SetAlpha(0)
                followerReward.PortraitFrame.Portrait:SetTexCoord(0.2, 0.85, 0.2, 0.85)

                local level = followerReward.PortraitFrame.Level
                level:ClearAllPoints()
                level:SetPoint("BOTTOM", followerReward.PortraitFrame, 0, 3)

                local squareBG = CreateFrame("Frame", nil, followerReward.PortraitFrame, "BackdropTemplate")
                squareBG:SetFrameLevel(followerReward.PortraitFrame:GetFrameLevel()-1)
                squareBG:SetPoint("TOPLEFT", 2, -2)
                squareBG:SetPoint("BOTTOMRIGHT", -2, 2)
                followerReward.PortraitFrame.squareBG = squareBG

                followerReward.isSkinned = true
            end

            local r, g, b = followerReward.PortraitFrame.PortraitRingQuality:GetVertexColor()
            followerReward.PortraitFrame.squareBG:SetBackdropBorderColor(r, g, b)
        end
    end

    _G.QuestInfoTitleHeader:SetTextColor(1, 0.8, 0.1)
    _G.QuestInfoDescriptionHeader:SetTextColor(1, 0.8, 0.1)
    _G.QuestInfoDescriptionText:SetTextColor(1, 1, 1)
    _G.QuestInfoObjectivesHeader:SetTextColor(1, 0.8, 0.1)
    _G.QuestInfoObjectivesText:SetTextColor(1, 1, 1)
    _G.QuestInfoGroupSize:SetTextColor(1, 1, 1)
    _G.QuestInfoRewardText:SetTextColor(1, 1, 1)
    _G.QuestInfoQuestType:SetTextColor(1, 1, 1)
    select(1, _G.QuestInfoItemHighlight:GetRegions()):SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/questitemhighlight")
    fRwd.ItemChooseText:SetTextColor(1, 1, 1)
    fRwd.ItemReceiveText:SetTextColor(1, 1, 1)
    QuestInfoAccountCompletedNotice:SetTextColor(0, 0.9, 0.6)

    if not isMapStyle and GW.settings.QUESTVIEW_ENABLED then
        fRwd.Header:SetTextColor(1, 1, 1)
        fRwd.Header:SetShadowColor(0, 0, 0, 1)
    elseif fRwd.Header.SetTextColor then
        fRwd.Header:SetTextColor(1, 0.8, 0.1)
    end

    if fRwd.SpellLearnText then
        fRwd.SpellLearnText:SetTextColor(1, 1, 1)
    end

    if fRwd.PlayerTitleText then
        fRwd.PlayerTitleText:SetTextColor(1, 1, 1)
    end

    if fRwd.XPFrame.ReceiveText then
        fRwd.XPFrame.ReceiveText:SetTextColor(1, 1, 1)
    end

    local objectives = _G.QuestInfoObjectivesFrame.Objectives
    local index = 0

    local questID = C_QuestLog.GetSelectedQuest()
    local waypointText = C_QuestLog.GetNextWaypointText(questID)
    if waypointText then
        index = index + 1
        objectives[index]:SetTextColor(1, 0.93, 0.73)
    end

    for i = 1, GetNumQuestLeaderBoards() do
        local _, objectiveType, isCompleted = GetQuestLogLeaderBoard(i)
        if objectiveType ~= "spell" and objectiveType ~= "log" and index < _G.MAX_OBJECTIVES then
            index = index + 1

            local objective = objectives[index]
            if objective then
                if isCompleted then
                    objective:SetTextColor(0.2, 1, 0.2)
                else
                    objective:SetTextColor(1, 1, 1)
                end
            end
        end
    end
end
GW.QuestInfo_Display = QuestInfo_Display

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
AFP("UpdateExecuteCommandAtlases", UpdateExecuteCommandAtlases)

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
            dialog.MinimizeButton.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button")
            dialog.MinimizeButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button", "ADD")
        end
        dialog.isSkinned = true
    end
end
AFP("hook_NotifyDialogShow", hook_NotifyDialogShow)

local function updateCollapse(self, collapsed)
    if collapsed then
        self.Icon:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
        self.Icon:SetRotation(1.570796325)
        self:GetHighlightTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
        self:GetHighlightTexture():SetRotation(1.570796325)
    else
        self.Icon:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
        self.Icon:SetRotation(0)
        self:GetHighlightTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
        self:GetHighlightTexture():SetRotation(0)
    end
end

local function hook_QuestLogQuests_Update()
    for button in QuestScrollFrame.headerFramePool:EnumerateActive() do
        if button.ButtonText then
            if not button.IsSkinned then
                button:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
                button.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
                button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep")
                button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep")
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
                button.Checkbox:DisableDrawLayer('BACKGROUND')
                hooksecurefunc(button.Checkbox.CheckMark, "SetShown", function(self, isTracked)
                    self:Show()
                    if isTracked then
                        self:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked")
                    else
                        self:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox")
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
            header.Background:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep")
            header.Highlight:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep")
            header.Highlight:SetColorTexture(1, 0.93, 0.73, 0.25)
            hooksecurefunc(header.CollapseButton, "UpdateCollapsedState", updateCollapse)
            header.IsSkinned = true
        end
    end
end
AFP("hook_QuestLogQuests_Update", hook_QuestLogQuests_Update)

local function mover_OnDragStart(self)
    self:GetParent():StartMoving()
end
AFP("mover_OnDragStart", mover_OnDragStart)

local function mover_OnDragStop(self)
    local self = self:GetParent()
    self:StopMovingOrSizing()
end
AFP("mover_OnDragStop", mover_OnDragStop)

local function worldMapSkin()
    -- prevent: [ADDON_ACTION_BLOCKED] AddOn 'GW2_UI' hat versucht die geschützte Funktion 'Frame:SetPropagateMouseClicks()' 
    WorldDungeonEntrancePinMixin = CreateFromMixins(DungeonEntrancePinMixin)
    function WorldDungeonEntrancePinMixin:UpdateMousePropagation() end

    WorldMapFrame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(WorldMapFrame, WorldMapFrameTitleText, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon", {QuestMapFrame}, nil, false, true)
    WorldMapFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    WorldMapFrame.BorderFrame:GwStripTextures()
    WorldMapFrame.BorderFrame:SetFrameStrata(WorldMapFrame:GetFrameStrata())
    WorldMapFrame.BorderFrame.NineSlice:Hide()
    WorldMapFrame.NavBar:GwStripTextures()
    WorldMapFrame.NavBar.overlay:GwStripTextures()
    WorldMapFrame.NavBar:SetPoint("TOPLEFT", 1, -47)
    WorldMapFrame.NavBar.SetPoint = GW.NoOp

    local navBarTex = WorldMapFrame.NavBar:CreateTexture(nil, "BACKGROUND", nil, 0)
    navBarTex:SetPoint("TOPLEFT", WorldMapFrame.NavBar, "TOPLEFT", 0,20)
    navBarTex:SetPoint("BOTTOMRIGHT", WorldMapFrame.NavBar, "BOTTOMRIGHT", 0, -10)
    navBarTex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-header")
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
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightInner")
    WorldMapFrame.NavBar.homeButton.tex = tex
    WorldMapFrame.NavBar.homeButton.tex:SetAlpha(1)

    WorldMapFrame.NavBar.homeButton.borderFrame = CreateFrame("Frame",nil, WorldMapFrame.NavBar.homeButton, "GwLightButtonBorder")
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
    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame.backdrop:SetPoint('TOPLEFT', -3, -14)
    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame.backdrop:SetPoint('BOTTOMRIGHT', -1, 1)
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
        handleReward(_G.MapQuestInfoRewardsFrame[frame], true)
    end
    handleReward(_G.MapQuestInfoRewardsFrame.MoneyFrame, true)

    if not GW.QuestInfo_Display_hooked then
        hooksecurefunc("QuestInfo_Display", QuestInfo_Display)
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

    local CampaignOverview = QuestMapFrame.CampaignOverview
    SkinHeaders(CampaignOverview.Header)
    CampaignOverview.ScrollFrame:GwStripTextures()
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
        Tracking:SetHighlightTexture(136460, 'ADD')

        local TrackingHighlight = Tracking:GetHighlightTexture()
        TrackingHighlight:SetAllPoints(Tracking.Icon)

        Pin.Icon:SetAtlas('Waypoint-MapPin-Untracked')
        Pin.ActiveTexture:SetAtlas('Waypoint-MapPin-Tracked')
        Pin.ActiveTexture:SetAllPoints(Pin.Icon)
        Pin:SetHighlightTexture(3500068, 'ADD') -- Interface\Waypoint\WaypoinMapPinUI

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
        pin:SetPinTexture("player", "Interface/AddOns/GW2_UI/textures/icons/player_arrow")
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
    QuestMapFrame.MapLegend.BackButton:GwSkinButton(false, true)
    QuestMapFrame.MapLegend.TitleText:SetFont(STANDARD_TEXT_FONT, 16)
    QuestMapFrame.MapLegend.BorderFrame:SetAlpha(0)
    MapLegendScrollFrame:GwStripTextures()
    MapLegendScrollFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    GW.HandleTrimScrollBar(MapLegendScrollFrame.ScrollBar)
end
AFP("worldMapSkin", worldMapSkin)

local function LoadWorldMapSkin()
    if not GW.settings.WORLDMAP_SKIN_ENABLED then return end

    GW.RegisterLoadHook(worldMapSkin, "Blizzard_WorldMap", WorldMapFrame)
end
GW.LoadWorldMapSkin = LoadWorldMapSkin
