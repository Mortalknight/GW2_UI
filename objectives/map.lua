local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local RoundDec = GW.RoundDec
local trackingTypes = GW.trackingTypes

local MAP_FRAMES_HIDE = {}
MAP_FRAMES_HIDE[1] = MiniMapMailFrame
MAP_FRAMES_HIDE[2] = MiniMapVoiceChatFrame
MAP_FRAMES_HIDE[3] = GameTimeFrame
MAP_FRAMES_HIDE[4] = MiniMapTrackingButton
MAP_FRAMES_HIDE[5] = MiniMapTracking
MAP_FRAMES_HIDE[6] = MinimapToggleButton

local Minimap_Addon_Buttons = {
    [1] = "MinimapToggleButton",
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
    [33] = "MiniMapBattlefieldFrame",
    [34] = "GatherArchNote",
    [35] = "ZGVMarker",
    [36] = "QuestPointerPOI",
    [37] = "poiMinimap",
    [38] = "MiniMapLFGFrame",
    [39] = "PremadeFilter_MinimapButton",
    [40] = "GwMapTime",
    [41] = "GwMapCoords",
    [42] = "GwMapFPS",
    [43] = "QuestieFrame",
    [44] = "miningminimap",
    [45] = "herbalismminimap",
    [46] = "fishminimap",
    [47] = "treasureminimap",
    [48] = "GatherLite",
    [49] = "GwMapFPS"
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

local function setMinimapButtons(side)
    MiniMapBattlefieldIcon:ClearAllPoints()
    GwMailButton:ClearAllPoints()
    GwAddonToggle:ClearAllPoints()
    GwAddonToggle.container:ClearAllPoints()
    GwMiniMapTrackingFrame:ClearAllPoints()

    if side == "left" then
        MiniMapBattlefieldIcon:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -8.5, -69)
        GwMailButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -10, -47)
        GwAddonToggle:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -5, -127)
        GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")
        GwMiniMapTrackingFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -7, 0)
    else
        MiniMapBattlefieldIcon:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 8, -69)
        GwMailButton:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 14, -47)
        GwAddonToggle:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 8, -127)
        GwAddonToggle.container:SetPoint("LEFT", GwAddonToggle, "RIGHT")
        GwMiniMapTrackingFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 7, 0)
    end
end

local function MinimapPostDrag(self)
    MinimapBackdrop:ClearAllPoints()
    MinimapBackdrop:SetAllPoints(Minimap)

    local x = self.gwMover:GetCenter()
    local screenWidth = UIParent:GetRight()
    if x > (screenWidth / 2) then
        setMinimapButtons("left")
    else
        setMinimapButtons("right")
    end
end

local function lfgAnimStop()
    MiniMapBattlefieldIcon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
    MiniMapBattlefieldFrame.animationCircle:Hide()
    MiniMapBattlefieldIcon:SetTexCoord(unpack(GW.TexCoords))
end
GW.AddForProfiling("map", "lfgAnimStop", lfgAnimStop)

local function lfgAnim(elapse)
    if Minimap:IsShown() then
        MiniMapBattlefieldIcon:SetAlpha(1)
    else
        MiniMapBattlefieldIcon:SetAlpha(0)
        return
    end
    if GetBattlefieldStatus(1) == "active" then
        lfgAnimStop()
        return
    end
    MiniMapBattlefieldFrame.animationCircle:Show()

    MiniMapBattlefieldIcon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")

    local rot = MiniMapBattlefieldFrame.animationCircle.background:GetRotation() + (1.5 * elapse)

    MiniMapBattlefieldFrame.animationCircle.background:SetRotation(rot)
    MiniMapBattlefieldIcon:SetTexCoord(unpack(GW.TexCoords))
end
GW.AddForProfiling("map", "lfgAnim", lfgAnim)

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

local function time_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, TIMEMANAGER_TOOLTIP_TITLE)
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true), nil, nil, nil, 1, 1, 1)
    GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true), nil, nil, nil, 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(format("%s%s%s", "|cffaaaaaa", GAMETIME_TOOLTIP_TOGGLE_CLOCK, "|r"))
    GameTooltip:Show()
end
GW.AddForProfiling("map", "time_OnEnter", time_OnEnter)

local function time_OnClick(_, button)
    if button == "LeftButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
        TimeManager_Toggle()
    else
        Stopwatch_Toggle()
    end
end
GW.AddForProfiling("map", "time_OnClick", time_OnClick)

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

local function LoadMinimap()
    -- https://wowwiki.wikia.com/wiki/USERAPI_GetMinimapShape
    GetMinimapShape = getMinimapShape

    local GwMinimapShadow = CreateFrame("Frame", "GwMinimapShadow", Minimap, "GwMinimapShadow")

    SetMinimapHover()

    hooksecurefunc("BattlefieldFrame_OnUpdate", lfgAnim)
    hooksecurefunc("MiniMapBattlefieldFrame_isArena", function()
        MiniMapBattlefieldIcon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
        MiniMapBattlefieldIcon:SetSize(20, 20)
        MiniMapBattlefieldIcon:ClearAllPoints()
        MiniMapBattlefieldIcon:SetPoint("CENTER", MiniMapBattlefieldFrame, "CENTER", 0, 0)
    end)
    MiniMapBattlefieldFrame.animationCircle = CreateFrame("Frame", "GwLFDAnimation", MiniMapBattlefieldFrame, "GwLFDAnimation")

    Minimap:SetMaskTexture("Interface/ChatFrame/ChatFrameBackground")
    Minimap:SetParent(UIParent)
    Minimap:SetFrameStrata("LOW")

    GwMapGradient = CreateFrame("Frame", "GwMapGradient", GwMinimapShadow, "GwMapGradient")
    GwMapGradient:SetParent(GwMinimapShadow)
    GwMapGradient:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    GwMapGradient:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)

    GwMiniMapTrackingFrame = CreateFrame("Frame", "GwMiniMapTrackingFrame", Minimap, "GwMiniMapTrackingFrame")

    local icontype = MiniMapTrackingIcon:GetTexture()
    if icontype == 132328 then icontype = icontype .. GW.myClassID end
    if icontype and trackingTypes[icontype] then
        GwMiniMapTrackingFrame.icon:SetTexCoord(trackingTypes[icontype].l, trackingTypes[icontype].r, trackingTypes[icontype].t, trackingTypes[icontype].b)
        GwMiniMapTrackingFrame:Show()
    else
        GwMiniMapTrackingFrame:Hide()
    end

    GwMiniMapTrackingFrame:RegisterEvent("MINIMAP_UPDATE_TRACKING")
    GwMiniMapTrackingFrame:SetScript("OnEvent", function(self)
        local icontype = MiniMapTrackingIcon:GetTexture()
        if icontype == 132328 then icontype = icontype .. GW.myClassID end
        if icontype and trackingTypes[icontype] then
            self.icon:SetTexCoord(trackingTypes[icontype].l, trackingTypes[icontype].r, trackingTypes[icontype].t, trackingTypes[icontype].b)
            self:Show()
        else
            self:Hide()
        end
    end)

    GwMapTime = CreateFrame("Button", "GwMapTime", Minimap, "GwMapTime")
    TimeManager_LoadUI()
    TimeManagerClockButton:Hide()
    StopwatchFrame:SetParent("UIParent")
    GwMapTime:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    GwMapTime.timeTimer = C_Timer.NewTicker(0.2, function()
        GwMapTime.Time:SetText(GameTime_GetTime(false))
    end)
    GwMapTime:SetScript("OnClick", time_OnClick)
    GwMapTime:SetScript("OnEnter", time_OnEnter)
    GwMapTime:SetScript("OnLeave", GameTooltip_Hide)

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

    MinimapCluster:SetAlpha(0.0)
    MinimapBorder:Hide()
    MiniMapWorldMapButton:Kill()

    MiniMapMailFrame:ClearAllPoints()
    MinimapZoneText:ClearAllPoints()

    MinimapZoneText:SetParent(GwMapGradient)
    MinimapZoneText:SetDrawLayer("OVERLAY", 2)
    MiniMapTracking:SetPoint("TOPLEFT", Minimap, -15, -30)
    GameTimeFrame:SetPoint("TOPLEFT", Minimap, -42, 0)
    MiniMapMailFrame:SetPoint("TOPLEFT", Minimap, 45, 15)
    MiniMapBattlefieldFrame:ClearAllPoints()
    MiniMapBattlefieldFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 45, 0)

    MinimapZoneText:SetTextColor(1, 1, 1)

    hooksecurefunc(
        MinimapZoneText,
        "SetText",
        function()
            MinimapZoneText:SetTextColor(1, 1, 1)
        end
    )

    MiniMapBattlefieldBorder:SetTexture(nil)
    BattlegroundShine:SetTexture(nil)
    MiniMapBattlefieldFrame:ClearAllPoints()
    MiniMapBattlefieldFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -5, -69)

    GameTimeFrame:HookScript(
        "OnShow",
        function(self)
            self:Hide()
        end
    )

    local GwMailButton = CreateFrame("Button", "GwMailButton", UIParent, "GwMailButton")
    local fnGwMailButton_OnEvent = function(self, event, ...)
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
    GwMailButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -12, -47)

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
                MinimapZoomIn:Click()
            elseif delta < 0 and self:GetZoom() > 0 then
                MinimapZoomOut:Click()
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

    local Minimap_OnEvent = function(_, event)
        if event == "CVAR_UPDATE" then
            Minimap_UpdateRotationSetting()
            MinimapCompassTexture:SetSize(300, 300)
        end
    end
    Minimap:SetScript("OnEvent", Minimap_OnEvent)
    Minimap:RegisterEvent("CVAR_UPDATE")

    Minimap:HookScript("OnShow", minimap_OnShow)
    Minimap:HookScript("OnHide", minimap_OnHide)

    local size = GetSetting("MINIMAP_SCALE")
    Minimap:SetSize(size, size)

    -- mobeable stuff
    GW.RegisterMovableFrame(Minimap, MINIMAP_LABEL, "MinimapPos", "VerticalActionBarDummy", {size, size}, nil, {"default"}, nil, MinimapPostDrag, true)
    local framePoint = GetSetting("MinimapPos")
    local defaultPoint = GW.GetDefault("MinimapPos")
    Minimap:ClearAllPoints()
    if not framePoint.point or not framePoint.relativePoint or not framePoint.xOfs or not framePoint.yOfs then
        -- use default position
        Minimap:SetPoint(defaultPoint.point, UIParent, defaultPoint.relativePoint, defaultPoint.xOfs, defaultPoint.yOfs)
    else
        Minimap:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs, framePoint.yOfs)
    end
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
