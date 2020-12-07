local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local RoundDec = GW.RoundDec

local MAP_FRAMES_HIDE = {}
MAP_FRAMES_HIDE[1] = MiniMapMailFrame
MAP_FRAMES_HIDE[2] = MiniMapVoiceChatFrame
--MAP_FRAMES_HIDE[3] = GameTimeFrame
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

local function lfgAnim(self, elapse)
    if Minimap:IsShown() then
        QueueStatusMinimapButtonIcon:SetAlpha(1)
    else
        QueueStatusMinimapButtonIcon:SetAlpha(0)
        return
    end
    QueueStatusMinimapButton.animationCircle:Show()

    QueueStatusMinimapButtonIconTexture:SetTexture("Interface/AddOns/GW2_UI/textures/icons/LFDMicroButton-Down")

    local speed = 1.5
    local rot = QueueStatusMinimapButton.animationCircle.background:GetRotation() + (speed * elapse)

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

local function MapCoordsMiniMap_OnEnter(self) 
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
    GameTooltip:AddLine(L["MAP_COORDINATES_TITLE"])  
    GameTooltip:AddLine(L["MAP_COORDINATES_TOGGLE_TEXT"], 1, 1, 1, TRUE) 
    GameTooltip:SetMinimumWidth(100)
    GameTooltip:Show()
end
GW.AddForProfiling("map", "MapCoordsMiniMap_OnEnter", MapCoordsMiniMap_OnEnter)

local function mapCoordsMiniMap_setCoords(self)
    if GW.locationData.x and GW.locationData.y then
        self.Coords:SetText(RoundDec(GW.locationData.xText, self.MapCoordsMiniMapPrecision) .. ", " .. RoundDec(GW.locationData.yText, self.MapCoordsMiniMapPrecision)) 
    else
        self.Coords:SetText("n/a")
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

local function stackIcons(self, event, ...)
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
    if GameTimeFrame then
        GameTimeFrame:Show()
    end
    if GwAddonToggle and GwAddonToggle.gw_Showing then
        GwAddonToggle:Show()
    end
    if GarrisonLandingPageMinimapButton and GarrisonLandingPageMinimapButton.gw_Showing then
        GarrisonLandingPageMinimapButton:Show()
    end
    if GwMailButton and GwMailButton.gw_Showing then
        GwMailButton:Show()
    end
end
GW.AddForProfiling("map", "minimap_OnShow", minimap_OnShow)

local function minimap_OnHide(self)
    if GameTimeFrame then
        GameTimeFrame:Hide()
    end
    if GwAddonToggle then
        GwAddonToggle:Hide()
    end
    if GarrisonLandingPageMinimapButton then
        GarrisonLandingPageMinimapButton:Hide()
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
        QueueStatusMinimapButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -5, -69)
        GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -7, 0)
        GarrisonLandingPageMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", 1, -7)
        GwMailButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -12, -47)
        GwAddonToggle:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -5.5, -127)
        GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")
    else
        QueueStatusMinimapButton:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 5, -69)
        GameTimeFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 7, 0)
        GarrisonLandingPageMinimapButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMRIGHT", -1, -7)
        GwMailButton:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 10, -47)
        GwAddonToggle:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 5.5, -127)
        GwAddonToggle.container:SetPoint("LEFT", GwAddonToggle, "RIGHT")
    end
    GarrisonLandingPageMinimapButton.SetPoint = GW.NoOp
    GarrisonLandingPageMinimapButton.ClearAllPoints = GW.NoOp
end
GW.setMinimapButtons = setMinimapButtons

local function LoadMinimap()
    -- https://wowwiki.wikia.com/wiki/USERAPI_GetMinimapShape
    _G["GetMinimapShape"] = getMinimapShape

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

    --coords
    if GetSetting("MINIMAP_COORDS_TOGGLE") then
        GwMapCoords = CreateFrame("Button", "GwMapCoords", Minimap, "GwMapCoords")
        GwMapCoords.Coords:SetText("n/a")
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
            self.fps:SetText(FPS_FORMAT:format(RoundDec(framerate)))
        end
        GwMapFPS:SetScript("OnUpdate", MapFPSMiniMap_OnUpdate)
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

    MiniMapMailFrame:ClearAllPoints()
    MiniMapMailFrame:SetPoint("TOPLEFT", Minimap, 45, 15)

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
    GameTimeFrame.gw_Showing = true
    GameTimeFrame:SetSize(35, 35)
    GameTimeFrame:StripTextures()
    GameTimeFrame:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/icon-calendar-Up")
    GameTimeFrame:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/icon-calendar")
    GameTimeFrame:SetHighlightTexture(nil)
    local GameTimeFrameNormalTexture = GameTimeFrame:GetNormalTexture()
    local GameTimeFramePushedTexture = GameTimeFrame:GetPushedTexture()
    GameTimeFrameNormalTexture:SetTexCoord(0, 1, 0, 1)
    GameTimeFramePushedTexture:SetTexCoord(0, 1, 0, 1)

    GarrisonLandingPageMinimapButton:SetSize(50, 50)
    GarrisonLandingPageMinimapButton.gw_Showing = false
    hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(self)
        self:SetSize(50, 50)
        self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up")
        self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down")
        self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down")
        self.LoopingGlow:SetTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up")
    end)

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

    -- remove quest blob
    Minimap:SetArchBlobRingScalar(0)
    Minimap:SetQuestBlobRingScalar(0)

    local size = GetSetting("MINIMAP_SCALE")
    Minimap:SetSize(size, size)

    -- mobeable stuff
    GW.RegisterMovableFrame(Minimap, MINIMAP_LABEL, "MinimapPos", "VerticalActionBarDummy", {size, size}, nil, {"default"})
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

