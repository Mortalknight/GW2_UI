local _, GW = ...
local GetSetting = GW.GetSetting

local MAP_FRAMES_HIDE = {}
MAP_FRAMES_HIDE[1] = MiniMapMailFrame
MAP_FRAMES_HIDE[3] = MinimapCluster
MAP_FRAMES_HIDE[4] = MiniMapVoiceChatFrame
MAP_FRAMES_HIDE[5] = GameTimeFrame
MAP_FRAMES_HIDE[6] = MiniMapTrackingButton
MAP_FRAMES_HIDE[7] = GarrisonLandingPageMinimapButton
MAP_FRAMES_HIDE[8] = MiniMapTracking

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
    [30] = "MiniMapInstanceDifficulty",
    [31] = "MinimapZoneTextButton",
    [32] = "GuildInstanceDifficulty",
    [33] = "MiniMapVoiceChatFrame",
    [34] = "MiniMapRecordingButton",
    [35] = "QueueStatusMinimapButton",
    [36] = "GatherArchNote",
    [37] = "ZGVMarker",
    [38] = "QuestPointerPOI",
    [39] = "poiMinimap",
    [40] = "MiniMapLFGFrame",
    [41] = "PremadeFilter_MinimapButton",
    [42] = "GarrisonMinimapButton",
    [43] = "GwMapTime",
    [44] = "GwMapCoords"
}

local MAP_FRAMES_HOVER = {}

local animationIndex = 0
local animationIndexY = 0
local anim_thro = 0
local framesToAdd = {}

local function SetMinimapHover()
    if GetSetting("MINIMAP_HOVER") == "NONE" then
        MAP_FRAMES_HOVER[1] = "mapGradient"
        MAP_FRAMES_HOVER[2] = "MinimapZoneText"
        MAP_FRAMES_HOVER[3] = "GwMapTime"
        MAP_FRAMES_HOVER[4] = "GwMapCoords"
    elseif GetSetting("MINIMAP_HOVER") == "CLOCK" then
        MAP_FRAMES_HOVER[1] = "mapGradient"
        MAP_FRAMES_HOVER[2] = "MinimapZoneText"
        MAP_FRAMES_HOVER[3] = "GwMapCoords"
    elseif GetSetting("MINIMAP_HOVER") == "ZONE" then
        MAP_FRAMES_HOVER[1] = "GwMapTime"
        MAP_FRAMES_HOVER[2] = "GwMapCoords"
    elseif GetSetting("MINIMAP_HOVER") == "COORDS" then
        MAP_FRAMES_HOVER[1] = "mapGradient"
        MAP_FRAMES_HOVER[2] = "MinimapZoneText"
        MAP_FRAMES_HOVER[3] = "GwMapTime"
    elseif GetSetting("MINIMAP_HOVER") == "CLOCKZONE" then
        MAP_FRAMES_HOVER[1] = "GwMapCoords"
    elseif GetSetting("MINIMAP_HOVER") == "CLOCKCOORDS" then
        MAP_FRAMES_HOVER[1] = "mapGradient"
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

    -- adjust minimap and minimap cluster placement/size (lots of default things anchor off cluster)
    MinimapCluster:ClearAllPoints()
    local mc_y = -50
    local mc_x = 0
    if ourBuffBar then
        mc_y = 0
    end
    if ourTracker then
        mc_x = -300
    end
    MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", mc_x, mc_y)
    Minimap:ClearAllPoints()
    if mapPos == "TOP" then
        if ourTracker then
            MinimapCluster:SetHeight(5)
            MinimapCluster:SetWidth(5)
        else
            MinimapCluster:SetHeight(mapSize + 60) -- extra room for pushing tracker, etc. further down
            MinimapCluster:SetWidth(mapSize)
        end
        if ourBuffBar then
            Minimap:SetPoint("TOPRIGHT", UIParent, -5, -5)
        else
            Minimap:SetPoint("TOPRIGHT", UIParent, -5, -45)
        end
    else
        Minimap:SetPoint("BOTTOMRIGHT", UIParent, -5, 21)
        MinimapCluster:SetHeight(5)
        MinimapCluster:SetWidth(5)
    end
end
GW.SetMinimapPosition = SetMinimapPosition

local function stackIcons(self, event)
    for _, frame in pairs(framesToAdd) do
        frame:SetParent(Minimap)
    end

    local foundFrames = false
    framesToAdd = {}

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
                framesToAdd[#framesToAdd + 1] = child
            end
        end
    end

    if not foundFrames then
        return
    end

    local fmGAT = CreateFrame("Button", "GwAddonToggle", UIParent, "GwAddonToggle")
    local fnGAT_OnClick = function(self, button)
        if not self.container:IsShown() then
            stackIcons()
            self.container:Show()
        else
            stackIcons()
            self.container:Hide()
        end
    end
    local fnGAT_OnEvent = function(self, event,...)
        if (event == "PLAYER_ENTERING_WORLD") then
            stackIcons()
        end
    end
    fmGAT:SetScript("OnClick", fnGAT_OnClick)
    fmGAT:SetScript("OnUpdate", function(self)
        if Minimap:IsShown() then
            self:SetAlpha(1)
            self:SetScript("OnClick", fnGAT_OnClick)

        else
            self:SetAlpha(0)
            self:SetScript("OnClick", nil)
        end
    end)
    fmGAT:SetScript("OnEvent", fnGAT_OnEvent)
    fmGAT:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    GwAddonToggle:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -5.5, -127)
    _G["GwAddonToggleTexture"]:SetTexCoord(0, 0.5, 0, 0.25)

    GwAddonToggle.container:SetWidth(#framesToAdd * 35)
    GwAddonToggle:SetFrameStrata("MEDIUM")
    local frameIndex = 0
    for _, frame in pairs(framesToAdd) do
        frame:SetParent(GwAddonToggle.container)
        frame:ClearAllPoints()
        frame:SetPoint("RIGHT", GwAddonToggle.container, "RIGHT", frameIndex * -36, 0)
        frameIndex = frameIndex + 1
        frame:SetScript("OnDragStart", nil)
    end
end
GW.AddForProfiling("map", "stackIcons", stackIcons)

local function lfgAnim(self,elapse)
    if Minimap:IsShown() then
        QueueStatusMinimapButtonIcon:SetAlpha(1)

    else
        QueueStatusMinimapButtonIcon:SetAlpha(0)
        return
    end
     QueueStatusMinimapButton.animationCircle:Show()
    
    QueueStatusMinimapButtonIconTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
    
    local speed = 1.5;
    local rot =  QueueStatusMinimapButton.animationCircle.background:GetRotation() + (speed * elapse);
    
    QueueStatusMinimapButton.animationCircle.background:SetRotation(rot);
    QueueStatusMinimapButtonIconTexture:SetTexCoord(0,1,0,1)
    
   
end
GW.AddForProfiling("map", "lfgAnim", lfgAnim)

local function lfgAnimStop()
    QueueStatusMinimapButtonIconTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
    QueueStatusMinimapButton.animationCircle:Hide()
    QueueStatusMinimapButtonIconTexture:SetTexCoord(0,1,0,1)
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

local function hoverMiniMap()
    for k, v in pairs(MAP_FRAMES_HOVER) do
        local child = _G[v]
        UIFrameFadeIn(child, 0.2, child:GetAlpha(), 1)
    end
    MinimapNorthTag:Hide()
end
GW.AddForProfiling("map", "hoverMiniMap", hoverMiniMap)

local function hoverMiniMapOut()
    for k, v in pairs(MAP_FRAMES_HOVER) do
        local child = _G[v]
        UIFrameFadeOut(child, 0.2, child:GetAlpha(), 0)
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
    GameTooltip:AddLine(GwLocalization["MAP_CLOCK_MILITARY"], 1, 1, 1, TRUE)
    GameTooltip:AddLine(GwLocalization["MAP_CLOCK_LOCAL_REALM"], 1, 1, 1, TRUE)
    GameTooltip:AddLine(GwLocalization["MAP_CLOCK_STOPWATCH"], 1, 1, 1, TRUE)
    GameTooltip:AddLine(GwLocalization["MAP_CLOCK_TIMEMANAGER"], 1, 1, 1, TRUE)
    GameTooltip:AddDoubleLine(WORLD_MAP_FILTER_TITLE .. " ", string, nil, nil, nil, 1, 1, 0)
    GameTooltip:SetMinimumWidth(100)
    GameTooltip:Show()
end
GW.AddForProfiling("map", "time_OnEnter", time_OnEnter)

local function time_OnClick(self, button)
    if button == "LeftButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

        if IsShiftKeyDown() then
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

local function MapPositionToXY(arg)
    local mapID = C_Map.GetBestMapForUnit(arg)
    if mapID and arg then
        local mapPos = C_Map.GetPlayerMapPosition(mapID, arg)
        if mapPos then
            return mapPos:GetXY()
        end
    end
    return 0, 0
end
GW.AddForProfiling("map", "MapPositionToXY", MapPositionToXY)

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
        return
    end
    if
        garrisonType == LE_GARRISON_TYPE_6_0 or garrisonType == LE_GARRISON_TYPE_7_0 or
            garrisonType == LE_GARRISON_TYPE_8_0
     then
        self:Show()
    else
        self:Hide()
    end
end
GW.AddForProfiling("map", "garrisonBtn_OnEvent", garrisonBtn_OnEvent)

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
    QueueStatusMinimapButton.animationCircle = CreateFrame("Frame","GwLFDAnimation",QueueStatusMinimapButton,"GwLFDAnimation")


    Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
    Minimap:SetParent(UIParent)
    Minimap:SetFrameStrata("LOW")

    mapGradient = CreateFrame("Frame", "GwMapGradient", GwMinimapShadow, "GwMapGradient")
    mapGradient:SetParent(GwMinimapShadow)
    mapGradient:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    mapGradient:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)

    GwMapTime = CreateFrame("Button", "GwMapTime", Minimap, "GwMapTime")
    TimeManager_LoadUI()
    TimeManagerClockButton:Hide()
    StopwatchFrame:SetParent("UIParent")
    GwMapTime:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local fnGwMapTime_OnUpdate = function(self, elapsed)
        self.Time:SetText(GameTime_GetTime(false))
    end
    GwMapTime:SetScript("OnUpdate", fnGwMapTime_OnUpdate)
    GwMapTime:SetScript("OnClick", time_OnClick)
    GwMapTime:SetScript("OnEnter", time_OnEnter)
    GwMapTime:SetScript("OnLeave", GameTooltip_Hide)

    GwMapCoords = CreateFrame("Button", "GwMapCoords", Minimap, "GwMapCoords")
    GwMapCoords.Coords:SetText("n/a")
    GwMapCoords.Coords:SetFont(STANDARD_TEXT_FONT, 12)
    local MapCoordsMiniMap_OnUpdate = function(self)
        local posX, posY = MapPositionToXY("player")
        if (posX == 0 and posY == 0) then
            self.Coords:SetText("n/a")
        else
            self.Coords:SetText(GW.RoundDec(posX * 1000 / 10) .. " / " .. GW.RoundDec(posY * 1000 / 10))
        end
    end
    GwMapCoords:SetScript("OnUpdate", MapCoordsMiniMap_OnUpdate)

    MinimapNorthTag:ClearAllPoints()
    MinimapNorthTag:SetPoint("TOP", Minimap, 0, 0)

    MinimapCluster:Hide()
    MinimapBorder:Hide()
    MiniMapWorldMapButton:Hide()

    GarrisonLandingPageMinimapButton:ClearAllPoints()
    MiniMapMailFrame:ClearAllPoints()
    MinimapZoneText:ClearAllPoints()

    MinimapZoneText:SetParent(mapGradient)
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
    GwCalendarButton:SetScript("OnUpdate", function(self)
        if Minimap:IsShown() then
            self:SetAlpha(1)
            self:SetScript("OnClick", GameTimeFrame_OnClick)
            self:SetScript("OnEnter", fnGwCalendarButton_OnEnter)
            self:SetScript("OnLeave", GameTooltip_Hide)
            self:SetScript("OnShow", fnGwCalendarButton_OnShow)
        else
            self:SetAlpha(0)
            self:SetScript("OnClick", nil)
            self:SetScript("OnEnter", nil)
            self:SetScript("OnShow", nil)
            self:SetScript("OnLeave", nil)
        end
    end)

    GwCalendarButton:HookScript(
        "OnEvent",
        function()
            GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -30)
        end
    )

    GwCalendarButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -7, 0)

    local GwGarrisonButton = CreateFrame("Button", "GwGarrisonButton", UIParent, "GwGarrisonButton")
    GwGarrisonButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", 1, -7)
    GwGarrisonButton:SetScript("OnClick", GarrisonLandingPageMinimapButton_OnClick)
    GwGarrisonButton:SetScript("OnEnter", garrisonBtn_OnEnter)
    GwGarrisonButton:SetScript("OnLeave", GameTooltip_Hide)
    GwGarrisonButton:SetScript("OnEvent", garrisonBtn_OnEvent)
    GwGarrisonButton:SetScript("OnUpdate", function(self)
        if Minimap:IsShown() then
            self:SetAlpha(1)
            self:SetScript("OnClick", GarrisonLandingPageMinimapButton_OnClick)
            self:SetScript("OnEnter", garrisonBtn_OnEnter)
            self:SetScript("OnLeave", GameTooltip_Hide)
        else
            self:SetAlpha(0)
            self:SetScript("OnClick", nil)
            self:SetScript("OnEnter", nil)
            self:SetScript("OnLeave", nil)
        end
    end)
    GwGarrisonButton:RegisterEvent("GARRISON_UPDATE")

    local GwMailButton = CreateFrame("Button", "GwMailButton", UIParent, "GwMailButton")
    local fnGwMailButton_OnEvent = function(self, event, ...)
        if (event == "UPDATE_PENDING_MAIL") then
            if (HasNewMail()) then
                self:Show()
                if (GameTooltip:IsOwned(self)) then
                    MinimapMailFrameUpdate()
                end
            else
                self:Hide()
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
    GwMailButton:SetScript("OnUpdate", function(self)
        if Minimap:IsShown() then
            self:SetAlpha(1)
            self:SetScript("OnEnter", fnGwMailButton_OnEnter)
            self:SetScript("OnLeave", GameTooltip_Hide)
        else
            self:SetAlpha(0)
            self:SetScript("OnEnter", nil)
            self:SetScript("OnLeave", nil)
        end
    end)

    GwMailButton:RegisterEvent("UPDATE_PENDING_MAIL")
    GwMailButton:SetFrameLevel(GwMailButton:GetFrameLevel() + 1)
    GwMailButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -12, -47)

    GwDateText:SetFont(UNIT_NAME_FONT, 14)
    GwDateText:SetTextColor(0, 0, 0)
    GwDateText:SetText(date("%d"))

    hooksecurefunc(
        Minimap,
        "SetScale",
        function()
        end
    )

    stackIcons()
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

    Minimap:RegisterEvent("PLAYER_ENTERING_WORLD")

    Minimap:SetSize(GetSetting("MINIMAP_SCALE"), GetSetting("MINIMAP_SCALE"))

    SetMinimapPosition()

    hoverMiniMapOut()
end
GW.LoadMinimap = LoadMinimap
