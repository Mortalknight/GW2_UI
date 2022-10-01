local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local RoundDec = GW.RoundDec

local MAP_FRAMES_HIDE = {}
MAP_FRAMES_HIDE[1] = MiniMapMailFrame
MAP_FRAMES_HIDE[2] = MiniMapVoiceChatFrame
MAP_FRAMES_HIDE[3] = MiniMapTrackingButton
MAP_FRAMES_HIDE[4] = MiniMapTracking

local MAP_FRAMES_HOVER = {}

local function SetMinimapHover()
    local hoverSetting = GetSetting("MINIMAP_HOVER")

    if hoverSetting == "NONE" then
        MAP_FRAMES_HOVER[1] = "GwMapGradient"
        MAP_FRAMES_HOVER[2] = "MinimapZoneText"
        MAP_FRAMES_HOVER[3] = "GwMapTime"
        MAP_FRAMES_HOVER[4] = "GwMapCoords"
    elseif hoverSetting == "CLOCK" then
        MAP_FRAMES_HOVER[1] = "GwMapGradient"
        MAP_FRAMES_HOVER[2] = "MinimapZoneText"
        MAP_FRAMES_HOVER[3] = "GwMapCoords"
    elseif hoverSetting == "ZONE" then
        MAP_FRAMES_HOVER[1] = "GwMapTime"
        MAP_FRAMES_HOVER[2] = "GwMapCoords"
    elseif hoverSetting == "COORDS" then
        MAP_FRAMES_HOVER[1] = "GwMapGradient"
        MAP_FRAMES_HOVER[2] = "MinimapZoneText"
        MAP_FRAMES_HOVER[3] = "GwMapTime"
    elseif hoverSetting == "CLOCKZONE" then
        MAP_FRAMES_HOVER[1] = "GwMapCoords"
    elseif hoverSetting == "CLOCKCOORDS" then
        MAP_FRAMES_HOVER[1] = "GwMapGradient"
        MAP_FRAMES_HOVER[2] = "MinimapZoneText"
    elseif hoverSetting == "ZONECOORDS" then
        MAP_FRAMES_HOVER[1] = "GwMapTime"
    end
end
GW.SetMinimapHover = SetMinimapHover

local function hideMiniMapIcons()
    for _, v in pairs(MAP_FRAMES_HIDE) do
        if v then
            v:Hide()
            v:SetScript(
                "OnShow",
                function(self)
                    self:Hide()
                end
            )
        end
    end

    Minimap:SetScript(
        "OnUpdate",
        function()
            if TimeManagerClockButton then
                TimeManagerClockButton:Hide()
                TimeManagerClockButton:SetScript(
                    "OnShow",
                    function(self)
                        self:Hide()
                    end
                )
                Minimap:SetScript("OnUpdate", nil)
            end
        end
    )
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
    if GW.locationData.x and GW.locationData.y then
        self.Coords:SetText(RoundDec(GW.locationData.xText, self.MapCoordsMiniMapPrecision) .. ", " .. RoundDec(GW.locationData.yText, self.MapCoordsMiniMapPrecision)) 
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

local function hoverMiniMap()
    for _, v in ipairs(MAP_FRAMES_HOVER) do
        local child = _G[v]
        if child ~= nil then
            UIFrameFadeIn(child, 0.2, child:GetAlpha(), 1)
            if child == GwMapCoords then
                GwMapCoords.CoordsTimer = C_Timer.NewTicker(0.1, function() mapCoordsMiniMap_setCoords(GwMapCoords) end)
            end
        end
    end
    --MinimapNorthTag:Hide()
end
GW.AddForProfiling("map", "hoverMiniMap", hoverMiniMap)

local function hoverMiniMapOut()
    local shouldShowNorthTag = false

    for _, v in ipairs(MAP_FRAMES_HOVER) do
        local child = _G[v]
        if child ~= nil then
            UIFrameFadeOut(child, 0.2, child:GetAlpha(), 0)
            if child == GwMapCoords then
                GwMapCoords:SetScript("OnUpdate", nil)
                if GwMapCoords.CoordsTimer then
                    GwMapCoords.CoordsTimer:Cancel()
                    GwMapCoords.CoordsTimer = nil
                end
            end
        end
        if v == "MinimapZoneText" then
            shouldShowNorthTag = true
        end
    end
    --MinimapNorthTag:SetShown(shouldShowNorthTag)
end
GW.AddForProfiling("map", "hoverMiniMapOut", hoverMiniMapOut)

local function checkCursorOverMap()
    if Minimap:IsMouseOver(100, -100, -100, 100) then
    else
        hoverMiniMapOut()
        Minimap:SetScript("OnUpdate", nil)
    end
end
GW.AddForProfiling("map", "checkCursorOverMap", checkCursorOverMap)

local function getMinimapShape()
    return "SQUARE"
end

local function minimap_OnShow()
    if GwAddonToggle and GwAddonToggle.gw_Showing then
        GwAddonToggle:Show()
    end
    if GwMailButton and GwMailButton.gw_Showing then
        GwMailButton:Show()
    end
end
GW.AddForProfiling("map", "minimap_OnShow", minimap_OnShow)

local function minimap_OnHide()
    if GwAddonToggle then
        GwAddonToggle:Hide()
    end
    if GwMailButton then
        GwMailButton:Hide()
    end
end
GW.AddForProfiling("map", "minimap_OnHide", minimap_OnHide)

local function setMinimapButtons(side)
    QueueStatusButton:ClearAllPoints()
    GameTimeFrame:ClearAllPoints()
    ExpansionLandingPageMinimapButton:ClearAllPoints()
    GwMailButton:ClearAllPoints()
    GwAddonToggle:ClearAllPoints()
    GwAddonToggle.container:ClearAllPoints()

    if side == "left" then
        GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -5, -2)
        GwMailButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -12, -47)
        QueueStatusButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -9.5, -66)
        GwAddonToggle:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", -9, 46)
        GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")
        ExpansionLandingPageMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", 0, -3)
    else
        GameTimeFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 5, -2)
        GwMailButton:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 11, -47)
        QueueStatusButton:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 9.5, -66)
        GwAddonToggle:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMRIGHT", 9, 46)
        GwAddonToggle.container:SetPoint("LEFT", GwAddonToggle, "RIGHT")
        ExpansionLandingPageMinimapButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMRIGHT", 2, -3)
    end
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

        -- only set the coords updater here if they are showen always
        local hoverSetting = GetSetting("MINIMAP_HOVER")
        if hoverSetting == "COORDS" or hoverSetting == "CLOCKCOORDS" or hoverSetting == "ZONECOORDS" or hoverSetting == "ALL" then
            GwMapCoords.CoordsTimer = C_Timer.NewTicker(0.1, function() mapCoordsMiniMap_setCoords(GwMapCoords) end)
        end
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

local function LoadMinimap()
    -- https://wowwiki.wikia.com/wiki/USERAPI_GetMinimapShape
    GetMinimapShape = getMinimapShape

    local GwMinimapShadow = CreateFrame("Frame", "GwMinimapShadow", Minimap, "GwMinimapShadow")

    SetMinimapHover()

    QueueStatusButton:SetSize(26, 26)
    QueueStatusButtonIcon:Kill()
    QueueStatusButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton")
    QueueStatusButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
    QueueStatusButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
    local GwLfgQueueIcon = CreateFrame("Frame", "GwLfgQueueIcon", QueueStatusButton, "GwLfgQueueIcon")
    GwLfgQueueIcon:SetPoint("TOPLEFT", QueueStatusButton, "TOPLEFT", 0, 0)
    hooksecurefunc(QueueStatusButtonIcon, "PlayAnim", function()
        if not Minimap:IsShown() then return end
        QueueStatusButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/LFGAnimation-1")
        QueueStatusButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/LFGAnimation-1-Highlight")
        QueueStatusButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/LFGAnimation-1-Highlight")
        GwLfgQueueIcon.animation:Play()
    end)
    hooksecurefunc(QueueStatusButtonIcon, "StopAnimating", function()
        GwLfgQueueIcon.animation:Stop()
        QueueStatusButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton")
        QueueStatusButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
        QueueStatusButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
    end)

    Minimap:SetMaskTexture("Interface/ChatFrame/ChatFrameBackground")
    Minimap:SetParent(UIParent)
    Minimap:SetFrameStrata("LOW")

    GwMapGradient = CreateFrame("Frame", "GwMapGradient", GwMinimapShadow, "GwMapGradient")
    GwMapGradient:SetParent(GwMinimapShadow)
    GwMapGradient:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    GwMapGradient:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)

    if MiniMapInstanceDifficulty then
        MiniMapInstanceDifficulty:SetParent(Minimap)
        MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 10, -10)
    end
    if GuildInstanceDifficulty then
        GuildInstanceDifficulty:SetParent(Minimap)
        GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 10, -10)
    end
    if MiniMapChallengeMode then
        MiniMapChallengeMode:SetParent(Minimap)
        MiniMapChallengeMode:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 10, -10)
    end

    GwMapTime = CreateFrame("Button", "GwMapTime", Minimap, "GwMapTime")
    TimeManager_LoadUI()
    TimeManagerClockButton:Hide()
    --StopwatchFrame:SetParent("UIParent")
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
    GwMapCoords.Coords:SetFont(STANDARD_TEXT_FONT, 12)
    GwMapCoords.MapCoordsMiniMapPrecision = GetSetting("MINIMAP_COORDS_PRECISION")
    ToogleMinimapCoorsLable()

    --FPS
    GwMapFPS = CreateFrame("Button", "GwMapFPS", Minimap, "GwMapFPS")
    GwMapFPS.fps:SetText(NOT_APPLICABLE)
    GwMapFPS.fps:SetFont(STANDARD_TEXT_FONT, 12)
    ToogleMinimapFpsLable()

    MinimapCluster:SetAlpha(0)
    hooksecurefunc(MinimapCluster, "SetAlpha", function(self, alpha, forced)
        if alpha ~= 0 and forced ~= true then
            self:SetAlpha(0, true)
        end
    end)
    MinimapCompassTexture:Hide()

    MinimapZoneText:ClearAllPoints()
    MinimapZoneText:SetParent(GwMapGradient)
    MinimapZoneText:SetDrawLayer("OVERLAY", 2)
    MinimapZoneText:SetPoint("CENTER")

    MinimapZoneText:SetTextColor(1, 1, 1)

    hooksecurefunc(
        MinimapZoneText,
        "SetText",
        function()
            MinimapZoneText:SetTextColor(1, 1, 1)
        end
    )

    GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
    GameTimeFrame:SetSize(35, 35)
    GameTimeFrame:StripTextures()
    GameTimeFrame:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/icon-calendar-Up")
    GameTimeFrame:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/icon-calendar")
    --GameTimeFrame:SetHighlightTexture(nil)
    GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
    GameTimeFrame:GetPushedTexture():SetTexCoord(0, 1, 0, 1)

    ExpansionLandingPageMinimapButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up")
    ExpansionLandingPageMinimapButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down")
    ExpansionLandingPageMinimapButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down")
    ExpansionLandingPageMinimapButton:GetHighlightTexture():SetBlendMode("BLEND")
    ExpansionLandingPageMinimapButton.LoopingGlow:SetTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up")
    ExpansionLandingPageMinimapButton:SetSize(43, 43)
    -- override blizzard function to prevent texture changes
    ExpansionLandingPageMinimapButton_UpdateIcon = function(self)
        local garrisonType = C_Garrison.GetLandingPageGarrisonType()
        self.garrisonType = garrisonType

        if (garrisonType == Enum.GarrisonType.Type_6_0) then
            self.faction = UnitFactionGroup("player")
            self.title = GARRISON_LANDING_PAGE_TITLE;
            self.description = MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP
        elseif (garrisonType == Enum.GarrisonType.Type_7_0) then
            self.title = ORDER_HALL_LANDING_PAGE_TITLE;
            self.description = MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP
        elseif (garrisonType == Enum.GarrisonType.Type_8_0) then
            self.title = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE;
            self.description = GARRISON_TYPE_8_0_LANDING_PAGE_TOOLTIP
        elseif (garrisonType == Enum.GarrisonType.Type_9_0) then
            self.title = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE;
            self.description = GARRISON_TYPE_9_0_LANDING_PAGE_TOOLTIP
        end
    end
    ExpansionLandingPageMinimapButton:SetScript("OnEnter", GW.LandingButton_OnEnter)

    local GwMailButton = CreateFrame("Button", "GwMailButton", UIParent, "GwMailButton")
    local fnGwMailButton_OnEvent = function(self, event)
        if (event == "UPDATE_PENDING_MAIL") then
            if (HasNewMail()) then
                if Minimap:IsShown() then
                    self:Show()
                end
                self.gw_Showing = true
                if (GameTooltip:IsOwned(self)) then
                    MinimapMailFrameUpdate()
                end
            else
                self:Hide()
                self.gw_Showing = false
            end
        end
    end
    local fnGwMailButton_OnEnter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -55)
        if (GameTooltip:IsOwned(self)) then
            MinimapMailFrameUpdate()
        end
    end
    GwMailButton:SetScript("OnEvent", fnGwMailButton_OnEvent)
    GwMailButton:SetScript("OnEnter", fnGwMailButton_OnEnter)
    GwMailButton:SetScript("OnLeave", GameTooltip_Hide)
    GwMailButton.gw_Showing = false
    GwMailButton:RegisterEvent("UPDATE_PENDING_MAIL")
    GwMailButton:SetFrameLevel(GwMailButton:GetFrameLevel() + 1)

    GW.CreateMinimapButtonsSack()

    Minimap:SetScale(1.2)

    MinimapZoneText:ClearAllPoints()
    MinimapZoneText:SetPoint("TOP", Minimap, 0, -5)

    hideMiniMapIcons()

    Minimap:SetScript(
        "OnEnter",
        function()
            hoverMiniMap()
            Minimap:SetScript(
                "OnUpdate",
                function()
                    checkCursorOverMap()
                end
            )
        end
    )

    Minimap.ZoomIn:Hide()
    Minimap.ZoomOut:Hide()
    Minimap:EnableMouseWheel(true)

    Minimap:SetScript(
        "OnMouseWheel",
        function(self, delta)
            if delta > 0 and self:GetZoom() < 5 then
                Minimap.ZoomIn:Click()
            elseif delta < 0 and self:GetZoom() > 0 then
                Minimap.ZoomOut:Click()
            end
        end
    )
    Minimap:SetScript(
        "OnMouseDown",
        function(_, button)
            if button == "RightButton" then
                ToggleDropDownMenu(1, nil, MinimapCluster.Tracking.DropDown, Minimap, 8, 5)

                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end
        end
    )

    Minimap:HookScript("OnShow", minimap_OnShow)
    Minimap:HookScript("OnHide", minimap_OnHide)

    -- remove quest blob
    Minimap:SetArchBlobRingScalar(0)
    Minimap:SetQuestBlobRingScalar(0)

    local size = GetSetting("MINIMAP_SCALE")
    Minimap:SetSize(size, size)

    -- mobeable stuff
    GW.RegisterMovableFrame(Minimap, MINIMAP_LABEL, "MinimapPos", "VerticalActionBarDummy", {size, size}, {"default"}, nil, MinimapPostDrag)
    Minimap:ClearAllPoints()
    Minimap:SetPoint("TOPLEFT", Minimap.gwMover)

    MinimapCluster:EnableMouse(false)
    -- check on which side we need to set the buttons
    local x = Minimap:GetCenter()
    local screenWidth = UIParent:GetRight()
    if x > (screenWidth / 2) then
        setMinimapButtons("left")
    else
        setMinimapButtons("right")
    end

    if not GW.IsIncompatibleAddonLoadedOrOverride("Objectives", true) then
        MinimapCluster:SetSize(GwMinimapShadow:GetWidth(), 5)
        MinimapCluster:ClearAllPoints()
        MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -320, 0)
    end

    Minimap:SetPlayerTexture("Interface/AddOns/GW2_UI/textures/icons/player_arrow")

    C_Timer.After(0.1, hoverMiniMapOut)
end
GW.LoadMinimap = LoadMinimap

