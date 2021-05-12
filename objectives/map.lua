local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local RoundDec = GW.RoundDec
local trackingTypes = GW.trackingTypes

local IS_GUILD_GROUP

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

local function setMinimapButtons(side)
    MiniMapBattlefieldIcon:ClearAllPoints()
    GwMailButton:ClearAllPoints()
    GwAddonToggle:ClearAllPoints()
    GwAddonToggle.container:ClearAllPoints()

    if side == "left" then
        MiniMapBattlefieldIcon:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -8.5, -69)
        GwMailButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -16, -47)
        GwAddonToggle:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -10, -127)
        GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")
    else
        MiniMapBattlefieldIcon:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 8, -69)
        GwMailButton:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 14, -47)
        GwAddonToggle:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 8, -127)
        GwAddonToggle.container:SetPoint("LEFT", GwAddonToggle, "RIGHT")
    end
end
GW.setMinimapButtons = setMinimapButtons

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
    local status = GetBattlefieldStatus(1)
    if status == "active" then
        lfgAnimStop()
        return
    end
    MiniMapBattlefieldFrame.animationCircle:Show()

    MiniMapBattlefieldIcon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")

    local speed = 1.5
    local rot = MiniMapBattlefieldFrame.animationCircle.background:GetRotation() + (speed * elapse)

    MiniMapBattlefieldFrame.animationCircle.background:SetRotation(rot)
    MiniMapBattlefieldIcon:SetTexCoord(unpack(GW.TexCoords))
end
GW.AddForProfiling("map", "lfgAnim", lfgAnim)

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

local function MapCoordsMiniMap_OnUpdate(self, elapsed)
    self.elapsedTimer = self.elapsedTimer - elapsed
    if self.elapsedTimer > 0 then
        return
    end
    self.elapsedTimer = self.updateCap
    mapCoordsMiniMap_setCoords(self)
end

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
    Minimap_UpdateRotationSetting()
    MinimapCompassTexture:SetSize(300, 300)
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

local function time_OnClick(self, button)
    if button == "LeftButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        ToggleTimeManager()
    else
        GameTimeFrame:Click()
    end
end
GW.AddForProfiling("map", "time_OnClick", time_OnClick)

local function getMinimapShape()
    return "SQUARE"
end

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
    if GwAddonToggle and GwAddonToggle.gw_Showing then
        GwAddonToggle:Show()
    end
    if GwMailButton and GwMailButton.gw_Showing then
        GwMailButton:Show()
    end
end
GW.AddForProfiling("map", "minimap_OnShow", minimap_OnShow)

local function minimap_OnHide(self)
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
    _G["GetMinimapShape"] = getMinimapShape

    local GwMinimapShadow = CreateFrame("Frame", "GwMinimapShadow", Minimap, "GwMinimapShadow")

    SetMinimapHover()

    hooksecurefunc("BattlefieldFrame_OnUpdate", lfgAnim)
    --hooksecurefunc("EyeTemplate_StopAnimating", lfgAnimStop)

    MiniMapBattlefieldIcon:SetSize(20, 20)
    MiniMapBattlefieldIcon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
    MiniMapBattlefieldIcon:SetSize(20, 20)
    MiniMapBattlefieldFrame.animationCircle = CreateFrame("Frame", "GwLFDAnimation", MiniMapBattlefieldFrame, "GwLFDAnimation")

    Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
    Minimap:SetParent(UIParent)
    Minimap:SetFrameStrata("LOW")

    GwMapGradient = CreateFrame("Frame", "GwMapGradient", GwMinimapShadow, "GwMapGradient")
    GwMapGradient:SetParent(GwMinimapShadow)
    GwMapGradient:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    GwMapGradient:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)

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
        function(_, button)
            if button == "RightButton" then
                ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "MiniMapTracking", 0, -5)

                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end
        end
    )

    local Minimap_OnEvent = function(self, event, ...)
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
