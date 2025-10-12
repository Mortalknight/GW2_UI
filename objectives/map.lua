local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local RoundDec = GW.RoundDec

local MAP_FRAMES_HIDE = {}
MAP_FRAMES_HIDE[1] = MiniMapMailIcon
MAP_FRAMES_HIDE[2] = MiniMapVoiceChatFrame
MAP_FRAMES_HIDE[3] = MiniMapTrackingButton
MAP_FRAMES_HIDE[4] = MiniMapTracking

local M = CreateFrame("Frame")

local minimapDetails = {
    ["ZONE"] = "GwMapGradient",
    ["CLOCK"] = "GwMapTime",
    ["COORDS"] = "GwMapCoords"
}

local settings = {
    hoverDetailsStay = {},
}

local function UpdateSettings()
    settings.hoverDetailsStay = GetSetting("MINIMAP_ALWAYS_SHOW_HOVER_DETAILS")
end
GW.UpdateMinimapSettings = UpdateSettings

local function SetMinimapHover()
    -- show all and hide not needes
    for _, v in pairs(minimapDetails) do
        if v and _G[v] then _G[v]:SetAlpha(1) end
    end

    GW.hoverMiniMapOut()
end
GW.SetMinimapHover = SetMinimapHover

local function hideMiniMapIcons()
    for _, v in pairs(MAP_FRAMES_HIDE) do
        if v and v.SetScript then
            v:Hide()
            v:SetScript(
                "OnShow",
                function(self)
                    self:Hide()
                end
            )
        end
    end
end
GW.AddForProfiling("map", "hideMiniMapIcons", hideMiniMapIcons)

local function MapCoordsMiniMap_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
    GameTooltip:AddLine(L["Map Coordinates"])
    GameTooltip:AddLine(L["Left Click to toggle higher precision coordinates."], 1, 1, 1, true)
    GameTooltip:SetMinimumWidth(100)
    GameTooltip:Show()
end
GW.AddForProfiling("map", "MapCoordsMiniMap_OnEnter", MapCoordsMiniMap_OnEnter)

local function mapCoordsMiniMap_setCoords(self)
    local x, y, xT, yT = GW.Libs.GW2Lib:GetPlayerLocationCoords()
    if x and y then
        self.Coords:SetText(RoundDec(xT, self.MapCoordsMiniMapPrecision) ..
        ", " .. RoundDec(yT, self.MapCoordsMiniMapPrecision))
    else
        self.Coords:SetText(NOT_APPLICABLE)
    end
end
GW.AddForProfiling("map", "mapCoordsMiniMap_setCoords", mapCoordsMiniMap_setCoords)

local function MapCoordsMiniMap_OnClick(self, button)
    if button == "LeftButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

        if self.MapCoordsMiniMapPrecision == 0 then
            self.MapCoordsMiniMapPrecision = 2
        else
            self.MapCoordsMiniMapPrecision = 0
        end

        SetSetting("MINIMAP_COORDS_PRECISION", self.MapCoordsMiniMapPrecision)
        mapCoordsMiniMap_setCoords(self)
    end
end
GW.AddForProfiling("map", "MapCoordsMiniMap_OnClick", MapCoordsMiniMap_OnClick)

local function hoverMiniMapIn()
    for k, v in pairs(settings.hoverDetailsStay) do
        if v == false and minimapDetails[k] and _G[minimapDetails[k]] then
            UIFrameFadeIn(_G[minimapDetails[k]], 0.2, _G[minimapDetails[k]]:GetAlpha(), 1)
        end
    end
end
GW.AddForProfiling("map", "hoverMiniMapIn", hoverMiniMapIn)

local function hoverMiniMapOut()
    for k, v in pairs(settings.hoverDetailsStay) do
        if v == false and minimapDetails[k] and _G[minimapDetails[k]] then
            UIFrameFadeOut(_G[minimapDetails[k]], 0.2, _G[minimapDetails[k]]:GetAlpha(), 0)
        end
    end
end
GW.hoverMiniMapOut = hoverMiniMapOut
GW.AddForProfiling("map", "hoverMiniMapOut", hoverMiniMapOut)

local function GetMinimapShape()
    return "SQUARE"
end

local function minimap_OnShow()
    if GwAddonToggle and GwAddonToggle.gw_Showing then
        GwAddonToggle:Show()
    end
end
GW.AddForProfiling("map", "minimap_OnShow", minimap_OnShow)

local function minimap_OnHide()
    if GwAddonToggle then
        GwAddonToggle:Hide()
    end
end
GW.AddForProfiling("map", "minimap_OnHide", minimap_OnHide)

local function setMinimapButtons(side)
    local expButton = ExpansionLandingPageMinimapButton or GarrisonLandingPageMinimapButton
    QueueStatusMinimapButton:ClearAllPoints()
    GameTimeFrame:ClearAllPoints()
    expButton:ClearAllPoints()
    GwAddonToggle:ClearAllPoints()
    GwAddonToggle.container:ClearAllPoints()

    if side == "left" then
        GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -5, -2)
        QueueStatusMinimapButton:SetPoint("TOP", GameTimeFrame, "BOTTOM", 0, 0)
        GwAddonToggle:SetPoint("TOP", QueueStatusMinimapButton, "BOTTOM", -3, 0)
        GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")
        expButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", 0, -3)

        --flip GwAddonToggle icon

        GwAddonToggle:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        GwAddonToggle:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
        GwAddonToggle:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
    else
        GameTimeFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 5, -2)
        QueueStatusMinimapButton:SetPoint("TOP", GameTimeFrame, "BOTTOM", 0, 0)
        GwAddonToggle:SetPoint("TOP", QueueStatusMinimapButton, "BOTTOM", 3, 0)
        GwAddonToggle.container:SetPoint("LEFT", GwAddonToggle, "RIGHT")
        expButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMRIGHT", 2, -3)

        --flip GwAddonToggle icon

        GwAddonToggle:GetNormalTexture():SetTexCoord(1, 0, 0, 1)
        GwAddonToggle:GetHighlightTexture():SetTexCoord(1, 0, 0, 1)
        GwAddonToggle:GetPushedTexture():SetTexCoord(1, 0, 0, 1)
    end

    --  QueueStatusMinimapButton:SetParent(UIParent)
end
GW.setMinimapButtons = setMinimapButtons

local function MinimapPostDrag(self)
    MinimapBackdrop:ClearAllPoints()
    MinimapBackdrop:SetAllPoints(Minimap)

    local x = self.gwMover:GetCenter()
    local screenWidth = UIParent:GetRight()
    if x > (screenWidth / 2) then
        GW.setMinimapButtons("left")
    else
        GW.setMinimapButtons("right")
    end
end

local function ToogleMinimapCoorsLable()
    if GetSetting("MINIMAP_COORDS_TOGGLE") then
        GwMapCoords:Show()
        GwMapCoords:SetScript("OnEnter", MapCoordsMiniMap_OnEnter)
        GwMapCoords:SetScript("OnClick", MapCoordsMiniMap_OnClick)
        GwMapCoords:SetScript("OnLeave", GameTooltip_Hide)

        hooksecurefunc(GwMapCoords, "SetAlpha", function(self, a)
            if a == 1 then
                if not self.CoordsTimer then
                    self.CoordsTimer = C_Timer.NewTicker(0.3, function() mapCoordsMiniMap_setCoords(self) end)
                end
            elseif a == 0 then
                if self.CoordsTimer then
                    self.CoordsTimer:Cancel()
                    self.CoordsTimer = nil
                end
            end
        end)
    else
        GwMapCoords:Hide()
        GwMapCoords:SetScript("OnEnter", nil)
        GwMapCoords:SetScript("OnClick", nil)
        GwMapCoords:SetScript("OnLeave", nil)
        if GwMapCoords.CoordsTimer then
            GwMapCoords.CoordsTimer:Cancel()
            GwMapCoords.CoordsTimer = nil
        end
    end
end
GW.ToogleMinimapCoorsLable = ToogleMinimapCoorsLable

local function ToogleMinimapFpsLable()
    if GetSetting("MINIMAP_FPS") then
        GW.BuildAddonList()
        GwMapFPS:SetScript("OnEnter", GW.FpsOnEnter)
        GwMapFPS:SetScript("OnUpdate", GW.FpsOnUpdate)
        GwMapFPS:SetScript("OnLeave", GW.FpsOnLeave)
        GwMapFPS:SetScript("OnClick", GW.FpsOnClick)
        GwMapFPS:Show()
    else
        GwMapFPS:SetScript("OnEnter", nil)
        GwMapFPS:SetScript("OnUpdate", nil)
        GwMapFPS:SetScript("OnLeave", nil)
        GwMapFPS:SetScript("OnClick", nil)
        GwMapFPS:Hide()
    end
end
GW.ToogleMinimapFpsLable = ToogleMinimapFpsLable


local function Minimap_OnMouseDown(self, btn)
    if M.TrackingDropdown then
        HideDropDownMenu(1, nil, M.TrackingDropdown)
    end

    if btn == "RightButton" and M.TrackingDropdown then
        ToggleDropDownMenu(1, nil, M.TrackingDropdown, "cursor")
    else
        Minimap.OnClick(self)
    end
end

local function MapCanvas_OnMouseDown(_, btn)
    if M.TrackingDropdown then
        HideDropDownMenu(1, nil, M.TrackingDropdown)
    end

    if btn == "RightButton" and M.TrackingDropdown then
        ToggleDropDownMenu(1, nil, M.TrackingDropdown, "cursor")
    end
end

local function Minimap_OnMouseWheel(self, delta)
    if delta > 0 and self:GetZoom() < 5 then
        MinimapZoomIn:Click()
    elseif delta < 0 and self:GetZoom() > 0 then
        MinimapZoomOut:Click()
    end
end

local function GetLocTextColor()
    local pvpType = GetZonePVPInfo()
    if pvpType == "arena" then
        return 0.84, 0.03, 0.03
    elseif pvpType == "friendly" then
        return 0.05, 0.85, 0.03
    elseif pvpType == "contested" then
        return 0.9, 0.85, 0.05
    elseif pvpType == "hostile" then
        return 0.84, 0.03, 0.03
    elseif pvpType == "sanctuary" then
        return 0.035, 0.58, 0.84
    elseif pvpType == "combat" then
        return 0.84, 0.03, 0.03
    else
        return 0.9, 0.85, 0.05
    end
end

local function Update_ZoneText()
    GwMapGradient.location:SetText(GetMinimapZoneText())
    GwMapGradient.location:SetTextColor(GetLocTextColor())
end

local function CreateMinimapTrackingDropdown()
    local dropdown = CreateFrame("Frame", "GW2UIMiniMapTrackingDropDown", UIParent, "UIDropDownMenuTemplate")
    dropdown:SetID(1)
    dropdown:SetClampedToScreen(true)
    dropdown:Hide()

    UIDropDownMenu_Initialize(dropdown, MiniMapTrackingDropDown_Initialize, "MENU")
    dropdown.noResize = true

    return dropdown
end

local function HandleExpansionButton()
    local garrison = ExpansionLandingPageMinimapButton or GarrisonLandingPageMinimapButton
    if not garrison then return end

    garrison:GetHighlightTexture():SetBlendMode("BLEND")
    garrison:SetSize(43, 43)

    -- Handle Position
    local x = Minimap.gwMover:GetCenter()
    local screenWidth = UIParent:GetRight()

    garrison:ClearAllPoints()
    if x > (screenWidth / 2) then
        garrison:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", 0, -3)
    else
        garrison:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMRIGHT", 2, -3)
    end

    local garrisonType = C_Garrison.GetLandingPageGarrisonType()

    garrison.garrisonType = garrisonType
 
    if garrison.garrisonType then
        if (garrisonType == Enum.GarrisonType.Type_6_0) then
            garrison.faction = UnitFactionGroup("player")
            garrison.title = GARRISON_LANDING_PAGE_TITLE;
            garrison.description = MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP
        elseif (garrisonType == Enum.GarrisonType.Type_7_0) then
            garrison.title = ORDER_HALL_LANDING_PAGE_TITLE;
            garrison.description = MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP
        elseif (garrisonType == Enum.GarrisonType.Type_8_0) then
            garrison.title = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE;
            garrison.description = GARRISON_TYPE_8_0_LANDING_PAGE_TOOLTIP
        elseif (garrisonType == Enum.GarrisonType.Type_9_0) then
            garrison.title = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE;
            garrison.description = GARRISON_TYPE_9_0_LANDING_PAGE_TOOLTIP
        end
        garrison:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up")
        garrison:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down")
        garrison:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down")
        garrison.LoopingGlow:SetTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up")
    else
        --[[
    local minimapDisplayInfo = ExpansionLandingPage:GetOverlayMinimapDisplayInfo();
        if minimapDisplayInfo then
            garrison.title = minimapDisplayInfo.title;
            garrison.description = minimapDisplayInfo.description;
        end
        ]]

        garrison:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon")
        garrison:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon")
        garrison:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon")
        garrison.LoopingGlow:SetTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon")
    end
end

local function SetupHybridMinimap()
    local MapCanvas = HybridMinimap.MapCanvas
    --MapCanvas:SetMaskTexture(E.Media.Textures.White8x8)
    MapCanvas:SetScript("OnMouseWheel", Minimap_OnMouseWheel)
    MapCanvas:SetScript("OnMouseDown", MapCanvas_OnMouseDown)
    MapCanvas:SetScript("OnMouseUp", GW.NoOp)

    _G.HybridMinimap.CircleMask:GwStripTextures()
end

local function UpdateClusterPoint(_, _, anchor)
    if anchor ~= GW2UI_MinimapClusterHolder then
        MinimapCluster:ClearAllPoints()
        MinimapCluster:SetPoint("TOPRIGHT", GW2UI_MinimapClusterHolder, 0, 1)
    end
end

local function LoadMinimap()
    -- https://wowwiki.wikia.com/wiki/USERAPI_GetMinimapShape
    GetMinimapShape = GetMinimapShape

    GW.UpdateMinimapSettings()

    Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
    Minimap:SetScale(1.2)

    local size = GetSetting("MINIMAP_SCALE")
    Minimap:SetSize(size, size)

    GW.RegisterMovableFrame(Minimap, MINIMAP_LABEL, "MinimapPos", ALL .. ",Blizzard,Map", { Minimap:GetSize() },
        { "default" }, nil, MinimapPostDrag)
    Minimap:ClearAllPoints()
    Minimap:SetPoint("CENTER", Minimap.gwMover)

    MinimapCluster:GwKillEditMode()

    local clusterHolder = CreateFrame("Frame", "GW2UI_MinimapClusterHolder", MinimapCluster)
    clusterHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -350, -3)
    clusterHolder:SetSize(MinimapCluster:GetSize())

    local clusterBackdrop = CreateFrame("Frame", "GWUI_MinimapClusterBackdrop", MinimapCluster)
    clusterBackdrop:SetPoint("TOPRIGHT", 0, -1)
    clusterBackdrop:SetIgnoreParentScale(true)
    clusterBackdrop:SetScale(1)
    local mcWidth = MinimapCluster:GetWidth()
    local height, width = 20, (mcWidth - 30)
    clusterBackdrop:SetSize(width, height)

    --Hide the BlopRing on Minimap
    Minimap:SetArchBlobRingAlpha(0)
    Minimap:SetArchBlobRingScalar(0)
    Minimap:SetQuestBlobRingAlpha(0)
    Minimap:SetQuestBlobRingScalar(0)

    UpdateClusterPoint()
    MinimapCluster:SetScale(1)
    MinimapCluster:EnableMouse(false)
    MinimapCluster:SetFrameLevel(20) -- set before minimap itself
    hooksecurefunc(MinimapCluster, "SetPoint", UpdateClusterPoint)

    Minimap:EnableMouseWheel(true)
    Minimap:SetFrameLevel(10)
    Minimap:SetFrameStrata("LOW")

    local GwMinimapShadow = CreateFrame("Frame", "GwMinimapShadow", Minimap, "GwMinimapShadow")
    local GwMapGradient = CreateFrame("Frame", "GwMapGradient", GwMinimapShadow, "GwMapGradient")
    GwMapGradient:SetParent(GwMinimapShadow)
    GwMapGradient:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    GwMapGradient:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)

    if Minimap.backdrop then -- level to hybrid maps fixed values
        Minimap.backdrop:SetFrameLevel(99)
        Minimap.backdrop:SetFrameStrata("BACKGROUND")
        Minimap.backdrop:SetIgnoreParentScale(true)
        Minimap.backdrop:SetScale(1)
    end

    Minimap:SetScript("OnMouseWheel", Minimap_OnMouseWheel)
    Minimap:SetScript("OnMouseDown", Minimap_OnMouseDown)
    Minimap:SetScript("OnMouseUp", GW.NoOp)

    Minimap:HookScript("OnEnter", hoverMiniMapIn)
    Minimap:HookScript("OnLeave", hoverMiniMapOut)

    Minimap:HookScript("OnShow", minimap_OnShow)
    Minimap:HookScript("OnHide", minimap_OnHide)

    -- MinimapCluster.ZoneTextButton:GwKill()
    TimeManagerClockButton:GwKill()
    -- MinimapCluster.Tracking.Button:SetParent(GW.HiddenFrame)

    GwMapGradient.location = GwMapGradient:CreateFontString(nil, "OVERLAY", "GW_Standard_Button_Font_Small", 7)
    GwMapGradient.location:SetPoint("TOP", Minimap, "TOP", 0, -2)
    GwMapGradient.location:SetJustifyH("CENTER")
    GwMapGradient.location:SetJustifyV("MIDDLE")
    GwMapGradient.location:SetIgnoreParentScale(true)
    -- GwMapGradient.location:SetScale(1)

    local killFrames = {
        MinimapBorder,
        MinimapBorderTop,
        MinimapZoomIn,
        MinimapZoomOut,
        MinimapNorthTag,
        MinimapZoneTextButton,
        MiniMapWorldMapButton,
        MiniMapMailFrame,
        MiniMapTracking,
        Minimap.ZoomIn,
        Minimap.ZoomOut,
        MinimapCompassTexture,
        MinimapCluster.IndicatorFrame
    }

    -- MinimapCluster.BorderTop:GwStripTextures()
    -- MinimapCluster.Tracking.Background:GwStripTextures()

    for _, frame in next, killFrames do
        frame:GwKill()
    end


    if ExpansionLandingPageMinimapButton and ExpansionLandingPageMinimapButton.UpdateIcon then
        hooksecurefunc(ExpansionLandingPageMinimapButton, "UpdateIcon", HandleExpansionButton)
        --ExpansionLandingPageMinimapButton:SetScript("OnEnter", GW.LandingButton_OnEnter) -- This was for SL
    else
        hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", HandleExpansionButton)
        --GarrisonLandingPageMinimapButton:SetScript("OnEnter", GW.LandingButton_OnEnter) -- This was for SL
    end
 
    HandleExpansionButton()

    QueueStatusFrame:SetClampedToScreen(true)

    M.TrackingDropdown = CreateMinimapTrackingDropdown()

    if HybridMinimap then SetupHybridMinimap() end

    M:RegisterEvent("ADDON_LOADED")
    M:RegisterEvent("PLAYER_ENTERING_WORLD")
    M:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    M:RegisterEvent("ZONE_CHANGED_INDOORS")
    M:RegisterEvent("ZONE_CHANGED")
    M:SetScript("OnEvent", function(_, event, ...)
        if event == "ADDON_LOADED" then
            local addon = ...
            if addon == "Blizzard_TimeManager" then
                TimeManagerClockButton:GwKill()
            elseif addon == "Blizzard_FeedbackUI" then
                FeedbackUIButton:GwKill()
            elseif addon == "Blizzard_HybridMinimap" then
                SetupHybridMinimap()
            elseif addon == "Blizzard_EncounterJournal" then
                -- Since the default non-quest map is full screen, it overrides the showing of the encounter journal
                hooksecurefunc("EJ_HideNonInstancePanels", function()
                    if InCombatLockdown() or not WorldMapFrame:IsShown() then return end

                    HideUIPanel(WorldMapFrame)
                end)
            end
        else
            Update_ZoneText()
        end
    end)

    --Time
    GwMapTime = CreateFrame("Button", "GwMapTime", Minimap, "GwMapTime")
    GwMapTime:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    GwMapTime.timeTimer = C_Timer.NewTicker(0.2, function()
        GwMapTime.Time:SetText(GameTime_GetTime(false))
    end)
    GwMapTime:RegisterEvent("UPDATE_INSTANCE_INFO")
    GwMapTime:SetScript("OnClick", GW.Time_OnClick)
    GwMapTime:SetScript("OnEnter", GW.Time_OnEnter)
    GwMapTime:SetScript("OnLeave", GW.Time_OnLeave)
    GwMapTime:SetScript("OnEvent", GW.Time_OnEvent)

    --coords
    GwMapCoords = CreateFrame("Button", "GwMapCoords", Minimap, "GwMapCoords")
    GwMapCoords.Coords:SetText(NOT_APPLICABLE)
    GwMapCoords.Coords:SetFont(STANDARD_TEXT_FONT, 12, "")
    GwMapCoords.MapCoordsMiniMapPrecision = GetSetting("MINIMAP_COORDS_PRECISION")
    ToogleMinimapCoorsLable()

    --FPS
    GwMapFPS = CreateFrame("Button", "GwMapFPS", Minimap, "GwMapFPS")
    GwMapFPS.fps:SetText(NOT_APPLICABLE)
    GwMapFPS.fps:SetFont(STANDARD_TEXT_FONT, 12)
    ToogleMinimapFpsLable()

    --CalenderIcon
    GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
    GameTimeFrame:SetSize(32, 32)

    hooksecurefunc("GameTimeFrame_SetDate", function()
        GameTimeFrame:GwStripTextures()
        GameTimeFrame:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/calendar")
        GameTimeFrame:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/calendar")
        GameTimeFrame:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/calendar")
        GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        GameTimeFrame:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
        GameTimeFrame:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
    end)

    -- Addon Icons
    GW.CreateMinimapButtonsSack()

    -- check on which side we need to set the buttons
    local x = Minimap:GetCenter()
    local screenWidth = UIParent:GetRight()
    if x > (screenWidth / 2) then
        setMinimapButtons("left")
    else
        setMinimapButtons("right")
    end

    Minimap:SetPlayerTexture("Interface/AddOns/GW2_UI/textures/icons/player_arrow")

    hideMiniMapIcons()

    SetMinimapHover()
    C_Timer.After(0.2, hoverMiniMapOut)

    GW.SkinMinimapInstanceDifficult()
    --
    QueueStatusMinimapButton:SetSize(26, 26)
    QueueStatusMinimapButtonBorder:GwKill()
    QueueStatusMinimapButtonIcon:GwKill()
    QueueStatusMinimapButtonIcon.texture:SetTexture(nil)
    QueueStatusMinimapButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton")
    QueueStatusMinimapButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
    QueueStatusMinimapButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
    local GwLfgQueueIcon = CreateFrame("Frame", "GwLfgQueueIcon", QueueStatusMinimapButton, "GwLfgQueueIcon")
    GwLfgQueueIcon:SetPoint("CENTER", QueueStatusMinimapButton, "CENTER", 0, 0)
    --[[hooksecurefunc(QueueStatusMinimapButtonIcon, "PlayAnim", function()
        if not Minimap:IsShown() then return end
        QueueStatusMinimapButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/LFGAnimation-1")
        QueueStatusMinimapButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/LFGAnimation-1-Highlight")
        QueueStatusMinimapButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/LFGAnimation-1-Highlight")
        GwLfgQueueIcon.animation:Play()
    end)
    hooksecurefunc(QueueStatusMinimapButtonIcon, "StopAnimating", function()
        GwLfgQueueIcon.animation:Stop()
        QueueStatusMinimapButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton")
        QueueStatusMinimapButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
        QueueStatusMinimapButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
    end)
    ]]
end
GW.LoadMinimap = LoadMinimap
