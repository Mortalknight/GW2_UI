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

local Minimap_Addon_Buttons = {
    [1] = "MiniMapTrackingFrame",
    [2] = "MiniMapMeetingStoneFrame",
    [3] = "MiniMapMailFrame",
    [4] = "MiniMapBattlefieldFrame",
    [5] = "MiniMapWorldMapButton",
    [6] = "MiniMapPing",
    [7] = "MinimapBackdrop",
    [8] = "MinimapZoomIn",
    [9] = "MinimapZoomOut",
    [10] = "BookOfTracksFrame",
    [11] = "GatherNote",
    [12] = "FishingExtravaganzaMini",
    [13] = "MiniNotePOI",
    [14] = "RecipeRadarMinimapIcon",
    [15] = "FWGMinimapPOI",
    [16] = "CartographerNotesPOI",
    [17] = "MBB_MinimapButtonFrame",
    [18] = "EnhancedFrameMinimapButton",
    [19] = "GFW_TrackMenuFrame",
    [20] = "GFW_TrackMenuButton",
    [21] = "TDial_TrackingIcon",
    [22] = "TDial_TrackButton",
    [23] = "MiniMapTracking",
    [24] = "GatherMatePin",
    [25] = "HandyNotesPin",
    [26] = "TimeManagerClockButton",
    [27] = "GameTimeFrame",
    [28] = "DA_Minimap",
    [29] = "ElvConfigToggle",
    [30] = "MinimapZoneTextButton",
    [31] = "MiniMapVoiceChatFrame",
    [32] = "MiniMapRecordingButton",
    [33] = "QueueStatusMinimapButton",
    [34] = "GatherArchNote",
    [35] = "ZGVMarker",
    [36] = "QuestPointerPOI",
    [37] = "poiMinimap",
    [38] = "MiniMapLFGFrame",
    [39] = "PremadeFilter_MinimapButton",
    [40] = "GarrisonMinimapButton",
    [41] = "GwMapTime",
    [42] = "GwMapCoords",
    [43] = "WarfrontRareTrackerPin",
    [44] = "GwMapFPS"
}

local MAP_FRAMES_HOVER = {}
local framesToAdd = {}

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

local function lfgAnim(_, elapse)
    if Minimap:IsShown() then
        QueueStatusMinimapButtonIcon:SetAlpha(1)
    else
        QueueStatusMinimapButtonIcon:SetAlpha(0)
        return
    end
    QueueStatusMinimapButton.animationCircle:Show()

    QueueStatusMinimapButtonIconTexture:SetTexture("Interface/AddOns/GW2_UI/textures/icons/LFDMicroButton-Down")

    local rot = QueueStatusMinimapButton.animationCircle.background:GetRotation() + (1.5 * elapse)

    QueueStatusMinimapButton.animationCircle.background:SetRotation(rot)
    QueueStatusMinimapButtonIconTexture:SetTexCoord(unpack(GW.TexCoords))
end
GW.AddForProfiling("map", "lfgAnim", lfgAnim)

local function lfgAnimStop()
    QueueStatusMinimapButtonIconTexture:SetTexture("Interface/AddOns/GW2_UI/textures/icons/LFDMicroButton-Down")
    QueueStatusMinimapButton.animationCircle:Hide()
    QueueStatusMinimapButtonIconTexture:SetTexCoord(unpack(GW.TexCoords))
end
GW.AddForProfiling("map", "lfgAnimStop", lfgAnimStop)

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
    MinimapNorthTag:Hide()
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
    MinimapNorthTag:SetShown(shouldShowNorthTag)
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

local function stackIcons(self)
    local children = {Minimap:GetChildren()}
    for _, child in ipairs(children) do
        if child:HasScript("OnClick") and child:IsShown() and child:GetName() then
            local ignore = false
            local childName = child:GetName()
            for _, v in pairs(Minimap_Addon_Buttons) do
                local namecompare = string.sub(childName, 1, string.len(v))
                if v == namecompare then
                    ignore = true
                    break
                end
            end
            if not ignore then
                framesToAdd[child:GetName()] = child
            end
        end
    end

    local frameIndex = 0
    for _, frame in pairs(framesToAdd) do
        if frame:IsShown() then
            frame:SetParent(self.container)
            frame:ClearAllPoints()
            frame:SetPoint("RIGHT", self.container, "RIGHT", frameIndex * -35, 0)
            frameIndex = frameIndex + 1
            frame:SetScript("OnDragStart", nil)
        end
    end
    self.container:SetWidth(frameIndex * 35)

    if frameIndex == 0 then
        self:Hide()
    end
end
GW.AddForProfiling("map", "stackIcons", stackIcons)

local function stack_OnEvent(self)
    stackIcons(self)
end
GW.AddForProfiling("map", "stack_OnEvent", stack_OnEvent)

local function stack_OnClick(self)
    stackIcons(self)
    self.container:SetShown(not self.container:IsShown())
end
GW.AddForProfiling("map", "stack_OnClick", stack_OnClick)

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
    GarrisonLandingPageMinimapButton.SetPoint = nil
    GarrisonLandingPageMinimapButton.ClearAllPoints = nil

    QueueStatusMinimapButton:ClearAllPoints()
    GameTimeFrame:ClearAllPoints()
    GarrisonLandingPageMinimapButton:ClearAllPoints()
    GwMailButton:ClearAllPoints()
    GwAddonToggle:ClearAllPoints()
    GwAddonToggle.container:ClearAllPoints()

    if side == "left" then
        QueueStatusMinimapButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -8.5, -69)
        GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -7, 0)
        GarrisonLandingPageMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", 1, -7)
        GwMailButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -16, -47)
        GwAddonToggle:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -10, -127)
        GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")
    else
        QueueStatusMinimapButton:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 8, -69)
        GameTimeFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 7, 0)
        GarrisonLandingPageMinimapButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMRIGHT", -1, -7)
        GwMailButton:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 14, -47)
        GwAddonToggle:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 8, -127)
        GwAddonToggle.container:SetPoint("LEFT", GwAddonToggle, "RIGHT")
    end
    GarrisonLandingPageMinimapButton.SetPoint = GW.NoOp
    GarrisonLandingPageMinimapButton.ClearAllPoints = GW.NoOp
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

local function LoadMinimap()
    -- https://wowwiki.wikia.com/wiki/USERAPI_GetMinimapShape
    GetMinimapShape = getMinimapShape

    local GwMinimapShadow = CreateFrame("Frame", "GwMinimapShadow", Minimap, "GwMinimapShadow")

    SetMinimapHover()

    hooksecurefunc("EyeTemplate_OnUpdate", lfgAnim)
    hooksecurefunc("EyeTemplate_StopAnimating", lfgAnimStop)

    QueueStatusMinimapButtonIconTexture:SetSize(20, 20)
    QueueStatusMinimapButtonIconTexture:SetTexture("Interface/AddOns/GW2_UI/textures/icons/LFDMicroButton-Down")
    QueueStatusMinimapButtonIcon:SetSize(20, 20)
    QueueStatusMinimapButton.animationCircle =
        CreateFrame("Frame", "GwLFDAnimation", QueueStatusMinimapButton, "GwLFDAnimation")

    Minimap:SetMaskTexture("Interface/ChatFrame/ChatFrameBackground")
    Minimap:SetParent(UIParent)
    Minimap:SetFrameStrata("LOW")

    GwMapGradient = CreateFrame("Frame", "GwMapGradient", GwMinimapShadow, "GwMapGradient")
    GwMapGradient:SetParent(GwMinimapShadow)
    GwMapGradient:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    GwMapGradient:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)

    if MiniMapInstanceDifficulty then
        MiniMapInstanceDifficulty:SetParent(UIParent)
        MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 10, -10)
    end
    if GuildInstanceDifficulty then
        GuildInstanceDifficulty:SetParent(UIParent)
        GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 10, -10)
    end
    if MiniMapChallengeMode then
        MiniMapChallengeMode:SetParent(UIParent)
        MiniMapChallengeMode:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 10, -10)
    end

    GwMapTime = CreateFrame("Button", "GwMapTime", Minimap, "GwMapTime")
    TimeManager_LoadUI()
    TimeManagerClockButton:Hide()
    StopwatchFrame:SetParent("UIParent")
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
    if GetSetting("MINIMAP_COORDS_TOGGLE") then
        GwMapCoords = CreateFrame("Button", "GwMapCoords", Minimap, "GwMapCoords")
        GwMapCoords.Coords:SetText(NOT_APPLICABLE)
        GwMapCoords.Coords:SetFont(STANDARD_TEXT_FONT, 12)
        GwMapCoords.MapCoordsMiniMapPrecision = GetSetting("MINIMAP_COORDS_PRECISION")
        GwMapCoords:SetScript("OnEnter", MapCoordsMiniMap_OnEnter)
        GwMapCoords:SetScript("OnClick", MapCoordsMiniMap_OnClick)
        GwMapCoords:SetScript("OnLeave", GameTooltip_Hide)

        -- only set the coords updater here if they are showen always
        local hoverSetting = GetSetting("MINIMAP_HOVER")
        if hoverSetting == "COORDS" or hoverSetting == "CLOCKCOORDS" or hoverSetting == "ZONECOORDS" or hoverSetting == "ALL" then
            GwMapCoords.CoordsTimer = C_Timer.NewTicker(0.1, function() mapCoordsMiniMap_setCoords(GwMapCoords) end)
        end
    end

    --FPS
    if GetSetting("MINIMAP_FPS") then
        GwMapFPS = CreateFrame("Button", "GwMapFPS", Minimap, "GwMapFPS")
        GwMapFPS.fps:SetText(NOT_APPLICABLE)
        GwMapFPS.fps:SetFont(STANDARD_TEXT_FONT, 12)
        GwMapFPS.fpsTimer = C_Timer.NewTicker(0.5, function()
            GwMapFPS.fps:SetText(RoundDec(GetFramerate()) .. " FPS")
        end)
    end

    MinimapNorthTag:ClearAllPoints()
    MinimapNorthTag:SetPoint("TOP", Minimap, 0, 0)

    MinimapCluster:SetAlpha(0)
    hooksecurefunc(MinimapCluster, "SetAlpha", function(self, alpha, forced)
        if alpha ~= 0 and forced ~= true then
            self:SetAlpha(0, true)
        end
    end)
    MinimapBorder:Hide()
    MiniMapWorldMapButton:Hide()

    MinimapZoneText:ClearAllPoints()
    MinimapZoneText:SetParent(GwMapGradient)
    MinimapZoneText:SetDrawLayer("OVERLAY", 2)
    MiniMapTracking:SetPoint("TOPLEFT", Minimap, -15, -30)

    MinimapZoneText:SetTextColor(1, 1, 1)

    hooksecurefunc(
        MinimapZoneText,
        "SetText",
        function()
            MinimapZoneText:SetTextColor(1, 1, 1)
        end
    )

    QueueStatusMinimapButtonBorder:SetTexture(nil)

    GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
    GameTimeFrame:SetSize(35, 35)
    GameTimeFrame:StripTextures()
    GameTimeFrame:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/icon-calendar-Up")
    GameTimeFrame:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/icon-calendar")
    GameTimeFrame:SetHighlightTexture(nil)
    GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
    GameTimeFrame:GetPushedTexture():SetTexCoord(0, 1, 0, 1)

    GarrisonLandingPageMinimapButton:SetSize(50, 50)
    hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(self)
        self:SetSize(50, 50)
        self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up")
        self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down")
        self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down")
        self.LoopingGlow:SetTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up")
    end)
    GarrisonLandingPageMinimapButton:SetScript("OnEnter", GW.LandingButton_OnEnter)

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

    local fmGAT = CreateFrame("Button", "GwAddonToggle", UIParent, "GwAddonToggle")
    fmGAT:SetScript("OnClick", stack_OnClick)
    fmGAT:SetScript("OnEvent", stack_OnEvent)
    fmGAT:RegisterEvent("PLAYER_ENTERING_WORLD")
    fmGAT:SetFrameStrata("MEDIUM")
    fmGAT.gw_Showing = true
    stackIcons(fmGAT)

    hooksecurefunc(
        Minimap,
        "SetScale",
        function()
        end
    )

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

    MinimapZoomIn:Hide()
    MinimapZoomOut:Hide()
    Minimap:EnableMouseWheel(true)

    Minimap:SetScript(
        "OnMouseWheel",
        function(self, delta)
            if delta > 0 and self:GetZoom() < 5 then
                self:SetZoom(self:GetZoom() + 1)
            elseif delta < 0 and self:GetZoom() > 0 then
                self:SetZoom(self:GetZoom() - 1)
            end
        end
    )
    Minimap:SetScript(
        "OnMouseDown",
        function(_, button)
            if button == "RightButton" then
                ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "MiniMapTracking", 0, -5)

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
    GW.RegisterMovableFrame(Minimap, MINIMAP_LABEL, "MinimapPos", "VerticalActionBarDummy", {size, size}, nil, {"default"}, nil, MinimapPostDrag)
    Minimap:ClearAllPoints()
    Minimap:SetPoint("TOPLEFT", Minimap.gwMover)
    -- check on which side we need to set the buttons
    local x = Minimap:GetCenter()
    local screenWidth = UIParent:GetRight()
    if x > (screenWidth / 2) then
        setMinimapButtons("left")
    else
        setMinimapButtons("right")
    end
    MinimapCluster:SetSize(GwMinimapShadow:GetWidth(), 5)
    MinimapCluster:ClearAllPoints()
    MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -320, 0)

    C_Timer.After(0.1, hoverMiniMapOut)
end
GW.LoadMinimap = LoadMinimap

