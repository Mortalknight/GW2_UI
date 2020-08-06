local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local RoundDec = GW.RoundDec

local IS_GUILD_GROUP

local MAP_FRAMES_HIDE = {}
MAP_FRAMES_HIDE[1] = MiniMapMailFrame
MAP_FRAMES_HIDE[2] = MiniMapVoiceChatFrame
MAP_FRAMES_HIDE[3] = GameTimeFrame
MAP_FRAMES_HIDE[4] = MiniMapTrackingButton
MAP_FRAMES_HIDE[5] = GarrisonLandingPageMinimapButton
MAP_FRAMES_HIDE[6] = MiniMapTracking

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

local animationIndex = 0
local animationIndexY = 0
local anim_thro = 0
local framesToAdd = {}

local function SetMinimapHover()
    if GetSetting("MINIMAP_HOVER") == "NONE" then
        MAP_FRAMES_HOVER[1] = "GwMapGradient"
        MAP_FRAMES_HOVER[2] = "MinimapZoneText"
        MAP_FRAMES_HOVER[3] = "GwMapTime"
        MAP_FRAMES_HOVER[4] = "GwMapCoords"
    elseif GetSetting("MINIMAP_HOVER") == "CLOCK" then
        MAP_FRAMES_HOVER[1] = "GwMapGradient"
        MAP_FRAMES_HOVER[2] = "MinimapZoneText"
        MAP_FRAMES_HOVER[3] = "GwMapCoords"
    elseif GetSetting("MINIMAP_HOVER") == "ZONE" then
        MAP_FRAMES_HOVER[1] = "GwMapTime"
        MAP_FRAMES_HOVER[2] = "GwMapCoords"
    elseif GetSetting("MINIMAP_HOVER") == "COORDS" then
        MAP_FRAMES_HOVER[1] = "GwMapGradient"
        MAP_FRAMES_HOVER[2] = "MinimapZoneText"
        MAP_FRAMES_HOVER[3] = "GwMapTime"
    elseif GetSetting("MINIMAP_HOVER") == "CLOCKZONE" then
        MAP_FRAMES_HOVER[1] = "GwMapCoords"
    elseif GetSetting("MINIMAP_HOVER") == "CLOCKCOORDS" then
        MAP_FRAMES_HOVER[1] = "GwMapGradient"
        MAP_FRAMES_HOVER[2] = "MinimapZoneText"
    elseif GetSetting("MINIMAP_HOVER") == "ZONECOORDS" then
        MAP_FRAMES_HOVER[1] = "GwMapTime"
    end
end
GW.SetMinimapHover = SetMinimapHover

local function SetMinimapPosition()
    local ourBuffBar = GetSetting("PLAYER_BUFFS_ENABLED")
    local ourTracker = GetSetting("QUESTTRACKER_ENABLED")
    local mapPos = GetSetting("MINIMAP_POS")
    local mapSize = Minimap:GetHeight()

    -- adjust minimap and minimap cluster placement (some default things anchor off cluster)

    local mc_x = 0
    if ourTracker then
        mc_x = -320
    end

    MinimapCluster:ClearAllPoints()
    Minimap:ClearAllPoints()
    Minimap:SetParent(UIParent)
    MinimapZoneTextButton:Hide()

    MinimapCluster:SetSize(GwMinimapShadow:GetWidth(), 5)

    if mapPos == "TOP" then
        if ourBuffBar then
            MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", mc_x, -(mapSize + 60))
            Minimap:SetPoint("TOPRIGHT", UIParent, -5, -5)
        else
            MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", mc_x, -(mapSize + 110))
            Minimap:SetPoint("TOPRIGHT", UIParent, -5, -50)
        end
    else
        if ourBuffBar then
            MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", mc_x, 0)
        else
            MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", mc_x, -50)
        end
        if GW.GetSetting("XPBAR_ENABLED") then
            Minimap:SetPoint("BOTTOMRIGHT", UIParent, -5, 21)
        else
            Minimap:SetPoint("BOTTOMRIGHT", UIParent, -5, 7)
        end
    end

end
GW.SetMinimapPosition = SetMinimapPosition

local function lfgAnim(self, elapse)
    if Minimap:IsShown() then
        QueueStatusMinimapButtonIcon:SetAlpha(1)
    else
        QueueStatusMinimapButtonIcon:SetAlpha(0)
        return
    end
    QueueStatusMinimapButton.animationCircle:Show()

    QueueStatusMinimapButtonIconTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")

    local speed = 1.5
    local rot = QueueStatusMinimapButton.animationCircle.background:GetRotation() + (speed * elapse)

    QueueStatusMinimapButton.animationCircle.background:SetRotation(rot)
    QueueStatusMinimapButtonIconTexture:SetTexCoord(unpack(GW.TexCoords))
end
GW.AddForProfiling("map", "lfgAnim", lfgAnim)

local function lfgAnimStop()
    QueueStatusMinimapButtonIconTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
    QueueStatusMinimapButton.animationCircle:Hide()
    QueueStatusMinimapButtonIconTexture:SetTexCoord(unpack(GW.TexCoords))
end
GW.AddForProfiling("map", "lfgAnimStop", lfgAnimStop)

local function hideMiniMapIcons()
    for k, v in pairs(MAP_FRAMES_HIDE) do
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

local function MapPositionToXY(arg)
    local mapID = C_Map.GetBestMapForUnit(arg)
    if mapID and arg then
        return GW.GetPlayerMapPos(mapID)
    end
    return 0, 0
end
GW.AddForProfiling("map", "MapPositionToXY", MapPositionToXY)

local function MapCoordsMiniMap_OnEnter(self) 
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
    GameTooltip:AddLine(L["MAP_COORDINATES_TITLE"])  
    GameTooltip:AddLine(L["MAP_COORDINATES_TOGGLE_TEXT"], 1, 1, 1, TRUE) 
    GameTooltip:SetMinimumWidth(100)
    GameTooltip:Show()
end
GW.AddForProfiling("map", "MapCoordsMiniMap_OnEnter", MapCoordsMiniMap_OnEnter)

local function mapCoordsMiniMap_setCoords(self)
    local posX, posY = MapPositionToXY("player")
    if (posX == nil and posY == nil) then
        self.Coords:SetText("n/a")
    else
        self.Coords:SetText(RoundDec(posX * 1000 / 10, self.MapCoordsMiniMapPrecision) .. ", " .. RoundDec(posY * 1000 / 10, self.MapCoordsMiniMapPrecision)) 
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

local function MapCoordsMiniMap_OnUpdate(self, elapsed)
    self.elapsedTimer = self.elapsedTimer - elapsed
    if self.elapsedTimer > 0 then
        return
    end
    self.elapsedTimer = self.updateCap
    mapCoordsMiniMap_setCoords(self)
end
GW.AddForProfiling("map", "MapCoordsMiniMap_OnUpdate", MapCoordsMiniMap_OnUpdate)

local function hoverMiniMap()
    for _, v in ipairs(MAP_FRAMES_HOVER) do
        local child = _G[v]
        UIFrameFadeIn(child, 0.2, child:GetAlpha(), 1)
        if child == GwMapCoords then
            GwMapCoords:SetScript("OnUpdate", MapCoordsMiniMap_OnUpdate)
        end
    end
    MinimapNorthTag:Hide()
end
GW.AddForProfiling("map", "hoverMiniMap", hoverMiniMap)

local function hoverMiniMapOut()
    for _, v in ipairs(MAP_FRAMES_HOVER) do
        local child = _G[v]
        if child ~= nil then
            UIFrameFadeOut(child, 0.2, child:GetAlpha(), 0)
            if child == GwMapCoords then
                GwMapCoords:SetScript("OnUpdate", nil)
            end
        end
    end
    MinimapNorthTag:Show()
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
    local string

    if GetCVarBool("timeMgrUseLocalTime") then
        string = TIMEMANAGER_TOOLTIP_LOCALTIME:gsub(":", "")
    else
        string = TIMEMANAGER_TOOLTIP_REALMTIME:gsub(":", "")
    end

    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
    GameTooltip:AddLine(TIMEMANAGER_TITLE)
    GameTooltip:AddLine(L["MAP_CLOCK_MILITARY"], 1, 1, 1, TRUE)
    GameTooltip:AddLine(L["MAP_CLOCK_LOCAL_REALM"], 1, 1, 1, TRUE)
    GameTooltip:AddLine(L["MAP_CLOCK_STOPWATCH"], 1, 1, 1, TRUE)
    GameTooltip:AddLine(L["MAP_CLOCK_TIMEMANAGER"], 1, 1, 1, TRUE)
    GameTooltip:AddDoubleLine(WORLD_MAP_FILTER_TITLE .. " ", string, nil, nil, nil, 1, 1, 0)
    GameTooltip:SetMinimumWidth(100)
    GameTooltip:Show()
end
GW.AddForProfiling("map", "time_OnEnter", time_OnEnter)

local function time_OnClick(self, button)
    if button == "LeftButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

        if not IsShiftKeyDown() then
            TimeManager_ToggleLocalTime()
            time_OnEnter(self)
        else
            TimeManager_ToggleTimeFormat()
        end
    end
    if button == "RightButton" then
        if IsShiftKeyDown() then
            ToggleTimeManager()
        else
            PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
            Stopwatch_Toggle()
        end
    end
end
GW.AddForProfiling("map", "time_OnClick", time_OnClick)

local function getMinimapShape()
    return "SQUARE"
end

local function garrisonBtn_OnEnter(self)
    local garrisonType = self.gw_GarrisonType
    if not garrisonType then
        self.gw_GarrisonType = C_Garrison.GetLandingPageGarrisonType()
        garrisonType = self.gw_GarrisonType
    end
    if not garrisonType then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -45)
    if garrisonType == LE_GARRISON_TYPE_6_0 then
        GameTooltip:SetText(GARRISON_LANDING_PAGE_TITLE, 1, 1, 1)
        GameTooltip:AddLine(MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP, nil, nil, nil, true)
    elseif garrisonType == LE_GARRISON_TYPE_7_0 then
        GameTooltip:SetText(ORDER_HALL_LANDING_PAGE_TITLE, 1, 1, 1)
        GameTooltip:AddLine(MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP, nil, nil, nil, true)
    elseif garrisonType == LE_GARRISON_TYPE_8_0 then
        GameTooltip:SetText(GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, 1, 1, 1)
        GameTooltip:AddLine(GARRISON_TYPE_8_0_LANDING_PAGE_TOOLTIP, nil, nil, nil, true)
    end
    GameTooltip:Show()
end

local function garrisonBtn_OnEvent(self, event, ...)
    if event ~= "GARRISON_UPDATE" then
        return
    end
    self.gw_GarrisonType = C_Garrison.GetLandingPageGarrisonType()
    local garrisonType = self.gw_GarrisonType
    if not garrisonType then
        self:Hide()
        self.gw_Showing = false
        return
    end
    if garrisonType == LE_GARRISON_TYPE_6_0 or garrisonType == LE_GARRISON_TYPE_7_0 or garrisonType == LE_GARRISON_TYPE_8_0 then
        if Minimap:IsShown() then
            self:Show()
        end
        self.gw_Showing = true
    else
        self:Hide()
        self.gw_Showing = false
    end
end
GW.AddForProfiling("map", "garrisonBtn_OnEvent", garrisonBtn_OnEvent)

local function stackIcons(self, event, ...)
    local foundFrames = false

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
                foundFrames = true
                framesToAdd[child:GetName()] = child
            end
        end
    end

    local frameIndex = 0
    for _, frame in pairs(framesToAdd) do
        if frame:IsShown() then
            frame:SetParent(self.container)
            frame:ClearAllPoints()
            frame:SetPoint("RIGHT", self.container, "RIGHT", frameIndex * -36, 0)
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

local function stack_OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        stackIcons(self)
    end
end
GW.AddForProfiling("map", "stack_OnEvent", stack_OnEvent)

local function stack_OnClick(self, button)
    if not self.container:IsShown() then
        stackIcons(self)
        self.container:Show()
    else
        stackIcons(self)
        self.container:Hide()
    end
end
GW.AddForProfiling("map", "stack_OnClick", stack_OnClick)

local function minimap_OnShow(self)
    if GwCalendarButton then
        GwCalendarButton:Show()
    end
    if GwAddonToggle and GwAddonToggle.gw_Showing then
        GwAddonToggle:Show()
    end
    if GwGarrisonButton and GwGarrisonButton.gw_Showing then
        GwGarrisonButton:Show()
    end
    if GwMailButton and GwMailButton.gw_Showing then
        GwMailButton:Show()
    end
end
GW.AddForProfiling("map", "minimap_OnShow", minimap_OnShow)

local function minimap_OnHide(self)
    if GwCalendarButton then
        GwCalendarButton:Hide()
    end
    if GwAddonToggle then
        GwAddonToggle:Hide()
    end
    if GwGarrisonButton then
        GwGarrisonButton:Hide()
    end
    if GwMailButton then
        GwMailButton:Hide()
    end
end
GW.AddForProfiling("map", "minimap_OnHide", minimap_OnHide)

local function LoadMinimap()
    -- https://wowwiki.wikia.com/wiki/USERAPI_GetMinimapShape
    _G["GetMinimapShape"] = getMinimapShape

    local GwMinimapShadow = CreateFrame("Frame", "GwMinimapShadow", Minimap, "GwMinimapShadow")

    SetMinimapHover()

    hooksecurefunc("EyeTemplate_OnUpdate", lfgAnim)
    hooksecurefunc("EyeTemplate_StopAnimating", lfgAnimStop)

    QueueStatusMinimapButtonIconTexture:SetSize(20, 20)
    QueueStatusMinimapButtonIconTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
    QueueStatusMinimapButtonIcon:SetSize(20, 20)
    QueueStatusMinimapButton.animationCircle =
        CreateFrame("Frame", "GwLFDAnimation", QueueStatusMinimapButton, "GwLFDAnimation")

    Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
    Minimap:SetParent(UIParent)
    Minimap:SetFrameStrata("LOW")

    GwMapGradient = CreateFrame("Frame", "GwMapGradient", GwMinimapShadow, "GwMapGradient")
    GwMapGradient:SetParent(GwMinimapShadow)
    GwMapGradient:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    GwMapGradient:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)

    if _G.MiniMapInstanceDifficulty then
        _G.MiniMapInstanceDifficulty:SetParent(_G.UIParent)
        _G.MiniMapInstanceDifficulty:SetPoint("TOPLEFT", _G.Minimap, "TOPLEFT", 10, -10)
    end
    if _G.GuildInstanceDifficulty then
        _G.GuildInstanceDifficulty:SetParent(_G.UIParent)
        _G.GuildInstanceDifficulty:SetPoint("TOPLEFT", _G.Minimap, "TOPLEFT", 10, -10)
    end
    if _G.MiniMapChallengeMode then
        _G.MiniMapChallengeMode:SetParent(_G.UIParent)
        _G.MiniMapChallengeMode:SetPoint("TOPLEFT", _G.Minimap, "TOPLEFT", 10, -10)
    end

    GwMapTime = CreateFrame("Button", "GwMapTime", Minimap, "GwMapTime")
    TimeManager_LoadUI()
    TimeManagerClockButton:Hide()
    StopwatchFrame:SetParent("UIParent")
    GwMapTime:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    GwMapTime.total_elapsed = 0
    local fnGwMapTime_OnUpdate = function(self, elapsed)
        if self.total_elapsed > 0 then
            self.total_elapsed = self.total_elapsed - elapsed
            return
        end
        self.total_elapsed = 0.1
        self.Time:SetText(GameTime_GetTime(false))
    end
    GwMapTime:SetScript("OnUpdate", fnGwMapTime_OnUpdate)
    GwMapTime:SetScript("OnClick", time_OnClick)
    GwMapTime:SetScript("OnEnter", time_OnEnter)
    GwMapTime:SetScript("OnLeave", GameTooltip_Hide)

    GwMapCoords = CreateFrame("Button", "GwMapCoords", Minimap, "GwMapCoords")
    GwMapCoords.Coords:SetText("n/a")
    GwMapCoords.Coords:SetFont(STANDARD_TEXT_FONT, 12)
    GwMapCoords.elapsedTimer = -1
    GwMapCoords.updateCap = 1 / 5 -- cap coord update to 5 FPS
    GwMapCoords.MapCoordsMiniMapPrecision = GetSetting("MINIMAP_COORDS_PRECISION")
    GwMapCoords:SetScript("OnUpdate", MapCoordsMiniMap_OnUpdate)
    GwMapCoords:SetScript("OnEnter", MapCoordsMiniMap_OnEnter)
    GwMapCoords:SetScript("OnClick", MapCoordsMiniMap_OnClick)
    GwMapCoords:SetScript("OnLeave", GameTooltip_Hide)

    --FPS
    if GetSetting("MINIMAP_FPS") then
        GwMapFPS = CreateFrame("Button", "GwMapFPS", Minimap, "GwMapFPS")
        GwMapFPS.fps:SetText("n/a")
        GwMapFPS.fps:SetFont(STANDARD_TEXT_FONT, 12)
        GwMapFPS.elapsedTimer = -1
        local updateCap = 1 / 5 -- cap fps update to 5 FPS
        local MapFPSMiniMap_OnUpdate = function(self, elapsed)
            self.elapsedTimer = self.elapsedTimer - elapsed
            if self.elapsedTimer > 0 then
                return
            end
            self.elapsedTimer = updateCap
            local framerate = GetFramerate()
            self.fps:SetText(RoundDec(framerate) .. " FPS")
        end
        GwMapFPS:SetScript("OnUpdate", MapFPSMiniMap_OnUpdate)
    end

    MinimapNorthTag:ClearAllPoints()
    MinimapNorthTag:SetPoint("TOP", Minimap, 0, 0)

    MinimapCluster:SetAlpha(0.0)
    MinimapBorder:Hide()
    MiniMapWorldMapButton:Hide()

    GarrisonLandingPageMinimapButton:ClearAllPoints()
    MiniMapMailFrame:ClearAllPoints()
    MinimapZoneText:ClearAllPoints()

    MinimapZoneText:SetParent(GwMapGradient)
    MinimapZoneText:SetDrawLayer("OVERLAY", 2)

    GarrisonLandingPageMinimapButton:SetPoint("TOPLEFT", Minimap, 0, 30)
    GameTimeFrame:SetPoint("TOPLEFT", Minimap, -42, 0)
    MiniMapTracking:SetPoint("TOPLEFT", Minimap, -15, -30)
    MiniMapMailFrame:SetPoint("TOPLEFT", Minimap, 45, 15)
    QueueStatusMinimapButton:ClearAllPoints()
    QueueStatusMinimapButton:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 45, 0)

    MinimapZoneText:SetTextColor(1, 1, 1)

    hooksecurefunc(
        MinimapZoneText,
        "SetText",
        function()
            MinimapZoneText:SetTextColor(1, 1, 1)
        end
    )

    QueueStatusMinimapButtonBorder:SetTexture(nil)
    QueueStatusMinimapButton:ClearAllPoints()
    QueueStatusMinimapButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -5, -69)

    GameTimeFrame:HookScript(
        "OnShow",
        function(self)
            self:Hide()
        end
    )

    GwCalendarButton = CreateFrame("Button", "GwCalendarButton", UIParent, "GwCalendarButton")
    local fnGwCalendarButton_OnShow = function(self)
        if (IsKioskModeEnabled()) then
            self:Disable()
        end
    end
    local fnGwCalendarButton_OnEnter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -70)
        GameTooltip:AddLine(GAMETIME_TOOLTIP_TOGGLE_CALENDAR, 1, 1, 1)
        GameTooltip:Show()
    end
    GwCalendarButton:SetScript("OnShow", fnGwCalendarButton_OnShow)
    GwCalendarButton:SetScript("OnEnter", fnGwCalendarButton_OnEnter)
    GwCalendarButton:SetScript("OnLeave", GameTooltip_Hide)
    GwCalendarButton:SetScript("OnClick", GameTimeFrame_OnClick)
    GwCalendarButton.gw_Showing = true
    GwCalendarButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -7, 0)
    GwCalendarButton.Text:SetFont(UNIT_NAME_FONT, 14)
    GwCalendarButton.Text:SetTextColor(0, 0, 0)
    GwCalendarButton.Text:SetText(date("%d"))

    local GwGarrisonButton = CreateFrame("Button", "GwGarrisonButton", UIParent, "GwGarrisonButton")
    GwGarrisonButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", 1, -7)
    GwGarrisonButton:SetScript("OnClick", GarrisonLandingPageMinimapButton_OnClick)
    GwGarrisonButton:SetScript("OnEnter", garrisonBtn_OnEnter)
    GwGarrisonButton:SetScript("OnLeave", GameTooltip_Hide)
    GwGarrisonButton:SetScript("OnEvent", garrisonBtn_OnEvent)
    GwGarrisonButton.gw_Showing = false
    GwGarrisonButton:RegisterEvent("GARRISON_UPDATE")

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
    fmGAT:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -5.5, -127)
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
        function(self)
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
        function(self, event)
            if event == "RightButton" then
                ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "MiniMapTracking", 0, -5)

                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end
        end
    )

    Minimap:HookScript("OnShow", minimap_OnShow)
    Minimap:HookScript("OnHide", minimap_OnHide)

    Minimap:SetSize(GetSetting("MINIMAP_SCALE"), GetSetting("MINIMAP_SCALE"))

    SetMinimapPosition()

    hoverMiniMapOut()
end
GW.LoadMinimap = LoadMinimap
