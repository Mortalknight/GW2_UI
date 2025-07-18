local _, GW = ...
local L = GW.L
local trackingTypes = GW.trackingTypes

local MAP_FRAMES_HIDE = {}
MAP_FRAMES_HIDE[1] = MiniMapMailFrame
MAP_FRAMES_HIDE[2] = MiniMapVoiceChatFrame
MAP_FRAMES_HIDE[3] = GameTimeFrame
MAP_FRAMES_HIDE[4] = MiniMapTrackingButton
MAP_FRAMES_HIDE[5] = MiniMapTracking
MAP_FRAMES_HIDE[6] = MinimapToggleButton

local M = CreateFrame("Frame")

local minimapDetails = {
    ["ZONE"] = "GwMapGradient",
    ["CLOCK"] = "GwMapTime",
    ["COORDS"] = "GwMapCoords"
}

local function SetMinimapHover()
    -- show all and hide not needes
    for _, v in pairs(minimapDetails) do
        if v and _G[v] then _G[v]:SetAlpha(1) end
    end

    GW.hoverMiniMapOut()
end
GW.SetMinimapHover = SetMinimapHover

local function setMinimapButtons(side)
    MiniMapBattlefieldFrame:ClearAllPoints()
    if LFGMinimapFrame then
        LFGMinimapFrame:ClearAllPoints()
    end
    GwAddonToggle:ClearAllPoints()
    GwAddonToggle.container:ClearAllPoints()
    GwMiniMapTrackingFrame:ClearAllPoints()

    if side == "left" then
        GwMiniMapTrackingFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -7, 0)
        MiniMapBattlefieldFrame:SetPoint("TOP", GwMiniMapTrackingFrame, "BOTTOM", 3, -6)
        if LFGMinimapFrame then
            LFGMinimapFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", -5, -7)
        end
        GwAddonToggle:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -5, -127)
        GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")
        GwAddonToggle:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        GwAddonToggle:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
        GwAddonToggle:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
    else
        GwMiniMapTrackingFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 0, 0)
        MiniMapBattlefieldFrame:SetPoint("TOP", GwMiniMapTrackingFrame, "BOTTOM", 3, -6)
        if LFGMinimapFrame then
            LFGMinimapFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMRIGHT", 5, -7)
        end
        GwAddonToggle:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 8, -127)
        GwAddonToggle.container:SetPoint("LEFT", GwAddonToggle, "RIGHT")
        GwAddonToggle:GetNormalTexture():SetTexCoord(1, 0, 0, 1)
        GwAddonToggle:GetHighlightTexture():SetTexCoord(1, 0, 0, 1)
        GwAddonToggle:GetPushedTexture():SetTexCoord(1, 0, 0, 1)
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

local function lfgAnimPvPStop()
    MiniMapBattlefieldIcon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\LFGMicroButton-Down")
    MiniMapBattlefieldFrame.animationCircle:Hide()
    MiniMapBattlefieldIcon:SetTexCoord(unpack(GW.TexCoords))
end
GW.AddForProfiling("map", "lfgAnimPvPStop", lfgAnimPvPStop)

local function lfgAnimPvP(elapse)
    if Minimap:IsShown() then
        MiniMapBattlefieldIcon:SetAlpha(1)
    else
        MiniMapBattlefieldIcon:SetAlpha(0)
        return
    end
    if GetBattlefieldStatus(1) == "active" then
        lfgAnimPvPStop()
        return
    end
    MiniMapBattlefieldFrame.animationCircle:Show()

    local _, _, _, _, _, _, isRankedArena  = GetBattlefieldStatus(1)
    if isRankedArena then
        MiniMapBattlefieldIcon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon");
    elseif UnitFactionGroup("player") then
        MiniMapBattlefieldIcon:SetTexture("Interface\\BattlefieldFrame\\Battleground-"..UnitFactionGroup("player"));
    end

    local rot = MiniMapBattlefieldFrame.animationCircle.background:GetRotation() + (1.5 * elapse)

    MiniMapBattlefieldFrame.animationCircle.background:SetRotation(rot)
    MiniMapBattlefieldIcon:SetTexCoord(unpack(GW.TexCoords))
end
GW.AddForProfiling("map", "lfgAnimPvP", lfgAnimPvP)

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
    GameTooltip:AddLine(L["Map Coordinates"], 1, 1, 1)
    GameTooltip:AddLine(L["Left Click to toggle higher precision coordinates."], 0.8, 0.8, 0.8, true)
    GameTooltip:SetMinimumWidth(100)
    GameTooltip:Show()
end
GW.AddForProfiling("map", "MapCoordsMiniMap_OnEnter", MapCoordsMiniMap_OnEnter)

local function mapCoordsMiniMap_setCoords(self)
    local x, y, xT, yT = GW.Libs.GW2Lib:GetPlayerLocationCoords()
    if x and y then
        self.Coords:SetText(GW.GetLocalizedNumber(xT, GW.settings.MINIMAP_COORDS_PRECISION) .. "/" .. GW.GetLocalizedNumber(yT, GW.settings.MINIMAP_COORDS_PRECISION))
    else
        self.Coords:SetText(NOT_APPLICABLE)
    end
end
GW.AddForProfiling("map", "mapCoordsMiniMap_setCoords", mapCoordsMiniMap_setCoords)

local function MapCoordsMiniMap_OnClick(self, button)
    if button == "LeftButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

        if GW.settings.MINIMAP_COORDS_PRECISION == 0 then
            GW.settings.MINIMAP_COORDS_PRECISION = 2
        else
            GW.settings.MINIMAP_COORDS_PRECISION = 0
        end

        mapCoordsMiniMap_setCoords(self)
    end
end
GW.AddForProfiling("map", "MapCoordsMiniMap_OnClick", MapCoordsMiniMap_OnClick)

local function hoverMiniMapIn()
    for k, v in pairs(GW.settings.MINIMAP_ALWAYS_SHOW_HOVER_DETAILS) do
        if v == false and minimapDetails[k] and _G[minimapDetails[k]] then
            UIFrameFadeIn(_G[minimapDetails[k]], 0.2, _G[minimapDetails[k]]:GetAlpha(), 1)
        end
    end

    MinimapNorthTag:Hide()
end
GW.AddForProfiling("map", "hoverMiniMapIn", hoverMiniMapIn)

local function hoverMiniMapOut()
    for k, v in pairs(GW.settings.MINIMAP_ALWAYS_SHOW_HOVER_DETAILS) do
        if v == false and minimapDetails[k] and _G[minimapDetails[k]] then
            UIFrameFadeOut(_G[minimapDetails[k]], 0.2, _G[minimapDetails[k]]:GetAlpha(), 0)
        end
    end
end
GW.hoverMiniMapOut = hoverMiniMapOut
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

local function getMinimapShape()
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

local function ToogleMinimapCoordsLable()
    if GW.settings.MINIMAP_COORDS_TOGGLE then
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
GW.ToogleMinimapCoordsLable = ToogleMinimapCoordsLable

local function ToogleMinimapFpsLable()
    if GW.settings.MINIMAP_FPS then
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

local function SetUpLfgFrame()
    if not LFGMinimapFrame then return end

    local GwLfgQueueIcon = CreateFrame("Frame", "GwLfgQueueIcon", LFGMinimapFrame, "GwLfgQueueIcon")
    GwLfgQueueIcon:SetAllPoints(LFGMinimapFrame)
    if LFGMinimapFrameBorder then LFGMinimapFrameBorder:GwKill() end
    if LFGMinimapFrameIconTexture then LFGMinimapFrameIconTexture:GwKill() end
    LFGMinimapFrame:SetSize(26, 26)
    LFGMinimapFrame:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
    LFGMinimapFrame:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/LFGAnimation-1")
    hooksecurefunc(LFGMinimapFrameIcon, "StartAnimating", function()
        if not Minimap:IsShown() then return end
        GwLfgQueueIcon.animation:Play()
    end)
    hooksecurefunc(LFGMinimapFrameIcon, "StopAnimating", function()
        GwLfgQueueIcon.animation:Stop()
    end)

    local hookedTimerFrame = CreateFrame("Frame")
    MiniMapBattlefieldFrame:HookScript("OnShow", function()
        hookedTimerFrame:SetScript("OnUpdate", function(_, elapse)
            lfgAnimPvP(elapse)
        end)
    end)
    MiniMapBattlefieldFrame:HookScript("OnHide", function()
        lfgAnimPvPStop()
        hookedTimerFrame:SetScript("OnUpdate", nil)
    end)
    MiniMapBattlefieldFrame.animationCircle = CreateFrame("Frame", "GwLFDAnimation", MiniMapBattlefieldFrame, "GwLFDAnimation")

    -- check on which side we need to set the buttons
    local x = Minimap:GetCenter()
    local screenWidth = UIParent:GetRight()
    if x > (screenWidth / 2) then
        setMinimapButtons("left")
    else
        setMinimapButtons("right")
    end
end

local function OnEvent(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local initLogin, isReload = ...
        if initLogin or isReload then
            SetUpLfgFrame()
        end
    elseif event == "ADDON_LOADED" then
        local addon = ...
        if addon == "Blizzard_GroupFinder_VanillaStyle" then
            SetUpLfgFrame()
        end
    end
end

do
    local isResetting

    local function ResetZoom()
        Minimap:SetZoom(0)
        MinimapZoomIn:Enable()
        MinimapZoomOut:Disable()

        isResetting = false
    end

    local function SetupZoomReset()
        if GW.settings.MinimapResetZoom > 0 and not isResetting then
            isResetting = true

            GW.Wait(GW.settings.MinimapResetZoom, ResetZoom)
        end
    end
    GW.SetupZoomReset = SetupZoomReset
end

local function LoadMinimap()
    -- https://wowwiki.wikia.com/wiki/USERAPI_GetMinimapShape
    GetMinimapShape = getMinimapShape

    local GwMinimapShadow = CreateFrame("Frame", "GwMinimapShadow", Minimap, "GwMinimapShadow")

    SetMinimapHover()

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
        MiniMapInstanceDifficulty:SetScale(0.8)
    end
    if GuildInstanceDifficulty then
        GuildInstanceDifficulty:SetParent(Minimap)
        GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 10, -10)
        GuildInstanceDifficulty:SetScale(0.8)
    end
    if MiniMapChallengeMode then
        MiniMapChallengeMode:SetParent(Minimap)
        MiniMapChallengeMode:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 10, -10)
        MiniMapChallengeMode:SetScale(0.8)
    end

    GwMiniMapTrackingFrame = CreateFrame("Frame", "GwMiniMapTrackingFrame", Minimap, "GwMiniMapTrackingFrame")
    MiniMapTracking:UnregisterAllEvents()
    MiniMapTracking:SetScript("OnEvent", nil)
    MiniMapTracking:Hide()
    local icontype = MiniMapTrackingIcon:GetTexture()
    if icontype == 132328 then icontype = icontype .. GW.myClassID end
    if icontype and trackingTypes[icontype] then
        GwMiniMapTrackingFrame.icon:SetTexCoord(trackingTypes[icontype].l, trackingTypes[icontype].r, trackingTypes[icontype].t, trackingTypes[icontype].b)
        GwMiniMapTrackingFrame:Show()
    else
        GwMiniMapTrackingFrame:Hide()
    end

    GwMiniMapTrackingFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    GwMiniMapTrackingFrame:RegisterEvent("MINIMAP_UPDATE_TRACKING")
    GwMiniMapTrackingFrame:SetScript("OnEvent", function(self, event)
        local icontype = GetTrackingTexture()
        if icontype == 132328 then icontype = icontype .. GW.myClassID end
        if icontype and trackingTypes[icontype] then
            GwMiniMapTrackingFrame.icon:SetTexCoord(trackingTypes[icontype].l, trackingTypes[icontype].r, trackingTypes[icontype].t, trackingTypes[icontype].b)
            GwMiniMapTrackingFrame:Show()
        else
            GwMiniMapTrackingFrame:Hide()
        end
    end)
    GwMiniMapTrackingFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", -30, 0)

    --Time
    GwMapTime = CreateFrame("Button", "GwMapTime", Minimap, "GwMapTime")
    TimeManager_LoadUI()
    TimeManagerClockButton:Hide()
    GwMapTime:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    GwMapTime.Time:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.TextSizeType.NORMAL)
    GwMapTime.Time:SetTextColor(1, 1, 1)
    GwMapTime.Time:SetShadowOffset(2, -2)
    GwMapTime.timeTimer = C_Timer.NewTicker(0.2, function()
        GwMapTime.Time:SetText(GameTime_GetTime(false))
    end)
    GwMapTime:SetScript("OnClick", GW.Time_OnClick)
    GwMapTime:SetScript("OnEnter", GW.Time_OnEnter)
    GwMapTime:SetScript("OnLeave", GW.Time_OnLeave)
    GwMapTime:SetScript("OnEvent", GW.Time_OnEvent)

    --coords
    GwMapCoords = CreateFrame("Button", "GwMapCoords", Minimap, "GwMapCoords")
    GwMapCoords.Coords:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.TextSizeType.NORMAL)
    GwMapCoords.Coords:SetTextColor(1, 1, 1)
    GwMapCoords.Coords:SetShadowOffset(2, -2)
    GwMapCoords.Coords:SetText(NOT_APPLICABLE)
    ToogleMinimapCoordsLable()

    --FPS
    GwMapFPS = CreateFrame("Button", "GwMapFPS", Minimap, "GwMapFPS")
    GwMapFPS.fps:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.TextSizeType.NORMAL)
    GwMapFPS.fps:SetTextColor(1, 1, 1)
    GwMapFPS.fps:SetShadowOffset(2, -2)
    GwMapFPS.fps:SetText(NOT_APPLICABLE)
    ToogleMinimapFpsLable()

    MinimapNorthTag:ClearAllPoints()
    MinimapNorthTag:SetPoint("TOP", Minimap, 0, 0)

    MinimapCluster:SetAlpha(0.0)
    MinimapBorder:Hide()

    MinimapZoneText:ClearAllPoints()

    MinimapZoneText:SetParent(GwMapGradient)
    MinimapZoneText:SetDrawLayer("OVERLAY", 2)
    --MiniMapTracking:SetPoint("TOPLEFT", Minimap, -15, -30)
    --MiniMapLFGFrame:ClearAllPoints()
    --MiniMapLFGFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 45, 0)

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

    --CalenderIcon
    GameTimeFrame:HookScript(
        "OnShow",
        function(self)
            self:Hide()
        end
    )

    GW.CreateMinimapButtonsSack()

    MinimapZoneText:ClearAllPoints()
    MinimapZoneText:SetPoint("TOP", Minimap, 0, -5)

    hideMiniMapIcons()

    Minimap:SetScript(
        "OnEnter",
        function()
            hoverMiniMapIn()
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

    --Reset Zoom function
    hooksecurefunc(Minimap, "SetZoom", GW.SetupZoomReset)

    Minimap:SetScale(GW.settings.MinimapScale)
    local size = GW.settings.MINIMAP_SIZE
    Minimap:SetSize(size, size)

    -- mobeable stuff
    GW.RegisterMovableFrame(Minimap, MINIMAP_LABEL, "MinimapPos", ALL .. ",Blizzard,Map", {Minimap:GetSize()}, {"default"}, nil, MinimapPostDrag)
    Minimap:ClearAllPoints()
    Minimap:SetPoint("TOPLEFT", Minimap.gwMover)

    if not GW.ShouldBlockIncompatibleAddon("Objectives") then
        MinimapCluster:SetSize(GwMinimapShadow:GetWidth(), 5)
        MinimapCluster:ClearAllPoints()
        MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -320, 0)
    end

    if not GW.ClassicAnniv then
        M:RegisterEvent("PLAYER_ENTERING_WORLD")
    elseif GW.ClassicAnniv then
        if C_AddOns.IsAddOnLoaded("Blizzard_GroupFinder_VanillaStyle") then
            OnEvent(nil, "ADDON_LOADED", "Blizzard_GroupFinder_VanillaStyle")
        else
            M:RegisterEvent("ADDON_LOADED")
        end
    end
    M:SetScript("OnEvent", OnEvent)

    C_Timer.After(0.1, hoverMiniMapOut)

    Minimap:SetPlayerTexture("Interface/AddOns/GW2_UI/textures/icons/player_arrow")
end
GW.LoadMinimap = LoadMinimap
