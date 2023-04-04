local _, GW = ...
local GetSetting = GW.GetSetting
local AFP = GW.AddProfiling
local GetSetting = GW.GetSetting

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
        frame.Count:SetFont(UNIT_NAME_FONT, 12, "THINOUTLINED")
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
    if not GetSetting("GOSSIP_SKIN_ENABLED") and not GetSetting("QUESTVIEW_ENABLED") and (template == QUEST_TEMPLATE_DETAIL or template == QUEST_TEMPLATE_REWARD or template == QUEST_TEMPLATE_LOG) then
        return
    end
    local isMapStyle = false
    if template == QUEST_TEMPLATE_MAP_DETAILS or template == QUEST_TEMPLATE_MAP_REWARDS then
        if not GetSetting("WORLDMAP_SKIN_ENABLED") then
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

    if not isMapStyle and GetSetting("QUESTVIEW_ENABLED") then
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

local function hook_UpdateState(self, isCollapsed)
    if isCollapsed then
        self:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrow_right")
        self:SetPushedTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrow_right")
    else
        self:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
        self:SetPushedTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
    end
    self:SetSize(16, 16)
end
AFP("hook_UpdateState", hook_UpdateState)

local sessionCommandToButtonAtlas = {
    [_G.Enum.QuestSessionCommand.Start] = "QuestSharing-DialogIcon",
    [_G.Enum.QuestSessionCommand.Stop] = "QuestSharing-Stop-DialogIcon"
}
local function hook_UpdateExecuteCommandAtlases(s, command)
    s.ExecuteSessionCommand:SetNormalTexture("")
    s.ExecuteSessionCommand:SetPushedTexture("")
    s.ExecuteSessionCommand:SetDisabledTexture("")
    local atlas = sessionCommandToButtonAtlas[command]
    if atlas then
        s.ExecuteSessionCommand.normalIcon:SetAtlas(atlas)
    end
end
AFP("hook_UpdateExecuteCommandAtlases", hook_UpdateExecuteCommandAtlases)

local function hook_NotifyDialogShow(_, dialog)
    if not dialog.isSkinned then
        dialog:GwStripTextures()
        dialog:GwCreateBackdrop()
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

local function hook_QuestLogQuests_Update()
    for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
        SkinHeaders(header)
    end

    for i = 1, _G.QuestMapFrame.QuestsFrame.Contents:GetNumChildren() do
        local child = select(i, _G.QuestMapFrame.QuestsFrame.Contents:GetChildren())
        if child and child.ButtonText and not child.questID then
            child:SetSize(16, 16)

            for x = 1, child:GetNumRegions() do
                local tex = select(x, child:GetRegions())
                if tex and tex.GetAtlas then
                    local atlas = tex:GetAtlas()
                    if atlas == "Campaign_HeaderIcon_Closed" or atlas == "Campaign_HeaderIcon_ClosedPressed" then
                        tex:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrow_right")
                    elseif atlas == "Campaign_HeaderIcon_Open" or atlas == "Campaign_HeaderIcon_OpenPressed" then
                        tex:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
                    end
                end
            end
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
    local WorldMapFrame = _G.WorldMapFrame

    WorldMapFrame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(WorldMapFrame, WorldMapFrameTitleText, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon", {QuestMapFrame})

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

    local homeButtonBorder = CreateFrame("Frame",nil,WorldMapFrame.NavBar.homeButton, "GwLightButtonBorder")
    WorldMapFrame.NavBar.homeButton.borderFrame =homeButtonBorder
    WorldMapFrame.NavBar.homeButton.xoffset = -1
    WorldMapFrame.BorderFrame.CloseButton:GwSkinButton(true)
    WorldMapFrame.BorderFrame.CloseButton:SetSize(20, 20)
    --WorldMapFrame.BorderFrame.CloseButton:ClearAllPoints()
    WorldMapFrame.BorderFrame.CloseButton:SetPoint("TOPRIGHT",-10,-2)

    WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:GwHandleMaxMinFrame()

    local QuestMapFrame = _G.QuestMapFrame
    QuestMapFrame.VerticalSeparator:Hide()
    QuestMapFrame:SetScript("OnHide", nil)

    QuestMapFrame.DetailsFrame:GwStripTextures(true)
    QuestMapFrame.DetailsFrame.RewardsFrame:GwStripTextures()

    hooksecurefunc(_G.CampaignCollapseButtonMixin, "UpdateState", hook_UpdateState)

    for _, frame in pairs({"HonorFrame", "XPFrame", "SpellFrame", "SkillPointFrame", "ArtifactXPFrame", "TitleFrame", "WarModeBonusFrame"}) do
        handleReward(_G.MapQuestInfoRewardsFrame[frame], true)
    end
    handleReward(_G.MapQuestInfoRewardsFrame.MoneyFrame, true)

    if not GW.QuestInfo_Display_hooked then
        hooksecurefunc("QuestInfo_Display", QuestInfo_Display)
        GW.QuestInfo_Display_hooked = true
    end

    if QuestMapFrame.Background then
        QuestMapFrame.Background:SetAlpha(0)
    end

    if QuestMapFrame.DetailsFrame.SealMaterialBG then
        QuestMapFrame.DetailsFrame.SealMaterialBG:SetAlpha(0)
    end

    QuestScrollFrame.DetailFrame:GwStripTextures()
    QuestScrollFrame.DetailFrame.BottomDetail:Hide()
    QuestScrollFrame.Contents.Separator.Divider:Hide()

    SkinHeaders(QuestScrollFrame.Contents.StoryHeader)
    QuestScrollFrame.ScrollBar:GwSkinScrollBar()
    QuestScrollFrame:GwSkinScrollFrame()

    QuestMapFrame.DetailsFrame.BackButton:GwStripTextures()
    QuestMapFrame.DetailsFrame.BackButton:GwSkinButton(false, true)
    QuestMapFrame.DetailsFrame.BackButton:SetFrameLevel(5)
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
    QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:GwSkinButton(false, true)

    local CampaignOverview = QuestMapFrame.CampaignOverview
    SkinHeaders(CampaignOverview.Header)
    CampaignOverview.ScrollFrame:GwStripTextures()
    GW.HandleTrimScrollBar(QuestScrollFrame.ScrollBar, true)
    GW.HandleAchivementsScrollControls(QuestScrollFrame)

    _G.QuestMapDetailsScrollFrame.ScrollBar:SetWidth(3)
    _G.QuestMapDetailsScrollFrame.ScrollBar:GwSkinScrollBar()
    _G.QuestMapDetailsScrollFrame:GwSkinScrollFrame()

    QuestMapFrame.DetailsFrame.CompleteQuestFrame:GwStripTextures()

    GW.HandleNextPrevButton(WorldMapFrame.SidePanelToggle.CloseButton, "left")
    GW.HandleNextPrevButton(WorldMapFrame.SidePanelToggle.OpenButton, "right")

    WorldMapFrame.BorderFrame.Tutorial:GwKill()

    WorldMapFrame.overlayFrames[1]:GwSkinDropDownMenu()
    WorldMapFrame.overlayFrames[1]:SetPoint("TOPLEFT", WorldMapFrame.ScrollContainer, "TOPLEFT", -7, 2)

    WorldMapFrame.overlayFrames[2]:GwStripTextures()
    WorldMapFrame.overlayFrames[2].Icon:SetTexture([[Interface\Minimap\Tracking\None]])
    WorldMapFrame.overlayFrames[2]:SetHighlightTexture([[Interface\Minimap\Tracking\None]], "ADD")
    WorldMapFrame.overlayFrames[2]:GetHighlightTexture():SetAllPoints(WorldMapFrame.overlayFrames[2].Icon)

    QuestMapFrame.QuestSessionManagement:GwStripTextures()

    local ExecuteSessionCommand = QuestMapFrame.QuestSessionManagement.ExecuteSessionCommand
    ExecuteSessionCommand:GwCreateBackdrop()
    ExecuteSessionCommand:GwSkinButton(false, true, false, true)

    local icon = ExecuteSessionCommand:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 0, 0)
    icon:SetPoint("BOTTOMRIGHT", 0, 0)
    ExecuteSessionCommand.normalIcon = icon

    hooksecurefunc(QuestMapFrame.QuestSessionManagement, "UpdateExecuteCommandAtlases", hook_UpdateExecuteCommandAtlases)

    hooksecurefunc(_G.QuestSessionManager, "NotifyDialogShow", hook_NotifyDialogShow)

    hooksecurefunc("QuestLogQuests_Update", hook_QuestLogQuests_Update)

    local qms = _G.QuestModelScene
    local w, h = qms:GetSize()
    qms:GwStripTextures()
    qms.tex = qms:CreateTexture(nil, "BACKGROUND", nil, 0)
    qms.tex:SetPoint("TOP", qms, "TOP", 0, 20)
    qms.tex:SetSize(w + 30, h + 60)
    qms.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

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
        WorldMapFrame:SetClampedToScreen(true)
        WorldMapFrame.mover:SetScript("OnDragStart", mover_OnDragStart)
        WorldMapFrame.mover:SetScript("OnDragStop", mover_OnDragStop)
    end
end
AFP("worldMapSkin", worldMapSkin)

local function LoadWorldMapSkin()
    if not GetSetting("WORLDMAP_SKIN_ENABLED") then return end

    GW.RegisterLoadHook(worldMapSkin, "Blizzard_WorldMap", WorldMapFrame)
end
GW.LoadWorldMapSkin = LoadWorldMapSkin
