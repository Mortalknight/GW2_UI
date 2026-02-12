local _, GW = ...
local L = GW.L
local trackingTypes = GW.trackingTypes

local MAP_FRAMES_HIDE = {}
MAP_FRAMES_HIDE[1] = MiniMapMailFrame
MAP_FRAMES_HIDE[2] = MiniMapVoiceChatFrame
MAP_FRAMES_HIDE[3] = MiniMapTrackingButton
MAP_FRAMES_HIDE[4] = MiniMapTracking
MAP_FRAMES_HIDE[5] = MinimapToggleButton

local minimapDetails = {
    ["ZONE"] = "GwMapGradient",
    ["CLOCK"] = "GwMapTime",
    ["COORDS"] = "GwMapCoords"
}

local function setMinimapButtons(side)
    Minimap.sidePanel:ClearAllPoints()
    GwAddonToggle.container:ClearAllPoints()

    if side == "left" then
        Minimap.sidePanel:SetPoint("TOPRIGHT", Minimap.gwBorder, "TOPLEFT", 5, 0)
        Minimap.sidePanel:SetPoint("BOTTOMRIGHT", Minimap.gwBorder, "BOTTOMLEFT", 5, 0)
        GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")

        --flip GwAddonToggle icon
        GwAddonToggle:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        GwAddonToggle:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
        GwAddonToggle:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
        GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        GameTimeFrame:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
        GameTimeFrame:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
    else
        Minimap.sidePanel:SetPoint("TOPLEFT", Minimap.gwBorder, "TOPRIGHT")
        Minimap.sidePanel:SetPoint("BOTTOMLEFT", Minimap.gwBorder, "BOTTOMRIGHT")
        GwAddonToggle.container:SetPoint("LEFT", GwAddonToggle, "RIGHT")
        --flip GwAddonToggle icon
        GwAddonToggle:GetNormalTexture():SetTexCoord(1, 0, 0, 1)
        GwAddonToggle:GetHighlightTexture():SetTexCoord(1, 0, 0, 1)
        GwAddonToggle:GetPushedTexture():SetTexCoord(1, 0, 0, 1)
        GameTimeFrame:GetNormalTexture():SetTexCoord(1, 0, 0, 1)
        GameTimeFrame:GetHighlightTexture():SetTexCoord(1, 0, 0, 1)
        GameTimeFrame:GetPushedTexture():SetTexCoord(1, 0, 0, 1)
    end
end

local function MinimapPostDrag(self)
    local x = self.gwMover:GetCenter()
    local screenWidth = UIParent:GetRight()
    if x > (screenWidth / 2) then
        setMinimapButtons("left")
    else
        setMinimapButtons("right")
    end
end

local function lfgAnimPvPStop()
    MiniMapBattlefieldFrameIconTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\lfdmicroButton-down.png")
    MiniMapBattlefieldFrame.animationCircle:Hide()
    MiniMapBattlefieldFrameIconTexture:SetTexCoord(unpack(GW.TexCoords))
end


local function lfgAnimPvP(elapse)
    if Minimap:IsShown() then
        MiniMapBattlefieldFrameIcon:SetAlpha(1)
    else
        MiniMapBattlefieldFrameIcon:SetAlpha(0)
        return
    end
    if GetBattlefieldStatus(1) == "active" then
        lfgAnimPvPStop()
        return
    end
    MiniMapBattlefieldFrame.animationCircle:Show()

    local _, _, _, _, _, _, isRankedArena  = GetBattlefieldStatus(1)
    if isRankedArena then
        MiniMapBattlefieldFrameIconTexture:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon");
    elseif UnitFactionGroup("player") then
        MiniMapBattlefieldFrameIconTexture:SetTexture("Interface\\BattlefieldFrame\\Battleground-" .. UnitFactionGroup("player"));
    end

    local rot = MiniMapBattlefieldFrame.animationCircle.background:GetRotation() + (1.5 * elapse)

    MiniMapBattlefieldFrame.animationCircle.background:SetRotation(rot)
    MiniMapBattlefieldFrameIconTexture:SetTexCoord(unpack(GW.TexCoords))
    MiniMapBattlefieldFrameIcon:SetScript("OnUpdate", nil)
end


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


local function MapCoordsMiniMap_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
    GameTooltip:AddLine(L["Map Coordinates"], 1, 1, 1)
    GameTooltip:AddLine(L["Left Click to toggle higher precision coordinates."], 0.8, 0.8, 0.8, true)
    GameTooltip:SetMinimumWidth(100)
    GameTooltip:Show()
end


local function mapCoordsMiniMap_setCoords(self)
    local x, y, xT, yT = GW.Libs.GW2Lib:GetPlayerLocationCoords()
    if x and y then
        self.Coords:SetText(GW.GetLocalizedNumber(xT, GW.settings.MINIMAP_COORDS_PRECISION) .. "/" .. GW.GetLocalizedNumber(yT, GW.settings.MINIMAP_COORDS_PRECISION))
    else
        self.Coords:SetText(NOT_APPLICABLE)
    end
end


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


local function hoverMiniMapIn()
    for k, v in pairs(GW.settings.MINIMAP_ALWAYS_SHOW_HOVER_DETAILS) do
        if v == false and minimapDetails[k] and _G[minimapDetails[k]] then
            --UIFrameFadeIn(_G[minimapDetails[k]], 0.2, _G[minimapDetails[k]]:GetAlpha(), 1) --bugged
            _G[minimapDetails[k]]:SetAlpha(1)
        end
    end
    MinimapNorthTag:Hide()
end


local function hoverMiniMapOut()
    for k, v in pairs(GW.settings.MINIMAP_ALWAYS_SHOW_HOVER_DETAILS) do
        if v == false and minimapDetails[k] and _G[minimapDetails[k]] then
            --UIFrameFadeOut(_G[minimapDetails[k]], 0.2, _G[minimapDetails[k]]:GetAlpha(), 0) --bugged
            _G[minimapDetails[k]]:SetAlpha(0)
        end
    end
    MinimapNorthTag:Hide()
end
GW.hoverMiniMapOut = hoverMiniMapOut


local function checkCursorOverMap()
    if Minimap:IsMouseOver(100, -100, -100, 100) then
    else
        hoverMiniMapOut()
        Minimap:SetScript("OnUpdate", nil)
    end
end


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


local function time_OnClick(_, button)
    if button == "LeftButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
        TimeManager_Toggle()
    else
        Stopwatch_Toggle()
    end
end


local function getMinimapShape()
    return "SQUARE"
end

local function minimap_OnShow()
    if GwAddonToggle and GwAddonToggle.gw_Showing then
        GwAddonToggle:Show()
    end
end


local function minimap_OnHide()
    if GwAddonToggle then
        GwAddonToggle:Hide()
    end
end


local function ToogleMinimapCoordsLable()
    if GW.settings.MINIMAP_COORDS_TOGGLE then
        GwMapCoords:Show()
        GwMapCoords:SetScript("OnEnter", MapCoordsMiniMap_OnEnter)
        GwMapCoords:SetScript("OnClick", MapCoordsMiniMap_OnClick)
        GwMapCoords:SetScript("OnLeave", GameTooltip_Hide)

        if not GwMapCoords.gwAlphaHooked then
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
            GwMapCoords.gwAlphaHooked = true
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

    local GwLfgQueueIcon = CreateFrame("Frame", "GwLfgQueueIcon", MiniMapLFGFrame, "GwLfgQueueIcon")
    GwLfgQueueIcon:SetAllPoints(MiniMapLFGFrame)
    MiniMapLFGFrameBorder:GwKill()
    MiniMapLFGFrame.eye:GwKill()
    MiniMapLFGFrame:SetSize(26, 26)
    MiniMapLFGFrame:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/lfgminimapbutton-highlight.png")
    MiniMapLFGFrame:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/lfganimation-1.png")
    MiniMapLFGFrame:HookScript("OnShow", function()
        if not Minimap:IsShown() then return end
        GwLfgQueueIcon.animation:Play()
    end)
    MiniMapLFGFrame:HookScript("OnHide", function()
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

    Minimap:SetMaskTexture("Interface/ChatFrame/ChatFrameBackground")
    Minimap:SetParent(UIParent)
    Minimap:SetFrameStrata("LOW")

    Minimap.gwBorder = CreateFrame("Frame", "GwMinimapShadow", Minimap, "GwMinimapShadow")
    Minimap.gwBorder:ClearAllPoints()
    Minimap.gwBorder:SetPoint("CENTER", Minimap)
    Minimap.gwBorder.gradient = CreateFrame("Frame", "GwMapGradient", Minimap.gwBorder, "GwMapGradient")
    Minimap.gwBorder.gradient:SetParent(Minimap.gwBorder)
    Minimap.gwBorder.gradient:SetPoint("TOPLEFT", Minimap.gwBorder, "TOPLEFT", 0, 0)
    Minimap.gwBorder.gradient:SetPoint("TOPRIGHT", Minimap.gwBorder, "TOPRIGHT", 0, 0)

    local panel = CreateFrame("Frame", nil, Minimap)
    panel:SetPoint("BOTTOMLEFT", Minimap.gwBorder, "BOTTOMLEFT", 5, 0)
    panel:SetPoint("BOTTOMRIGHT", Minimap.gwBorder, "BOTTOMRIGHT", 5, 0)
    panel:SetHeight(25)
    Minimap.lowerPanel = panel

    local topPanel = CreateFrame("Frame", nil, Minimap)
    topPanel:SetPoint("TOPLEFT", Minimap.gwBorder, "TOPLEFT")
    topPanel:SetPoint("TOPRIGHT", Minimap.gwBorder, "TOPRIGHT")
    topPanel:SetHeight(25)
    Minimap.topPanel = topPanel

    local sidePanel = CreateFrame("Frame", nil, Minimap)
    sidePanel:SetPoint("TOPRIGHT", Minimap.gwBorder, "TOPLEFT")
    sidePanel:SetPoint("BOTTOMRIGHT", Minimap.gwBorder, "BOTTOMLEFT")
    sidePanel:SetWidth(40)
    Minimap.sidePanel = sidePanel

    GwMiniMapTrackingFrame = CreateFrame("DropdownButton", "GwMiniMapTrackingFrame", Minimap, "GwMiniMapTrackingFrameDropDownTemplate")
    GwMiniMapTrackingFrame:OnLoad()
    GwMiniMapTrackingFrame:Show()
    local icontype = MiniMapTrackingIcon:GetTexture() or 136025
    if icontype == 132328 then icontype = icontype .. GW.myClassID end
    if trackingTypes[icontype] == nil then
        icontype = 136025
    end
    GwMiniMapTrackingFrame.icon:SetTexCoord(trackingTypes[icontype].l, trackingTypes[icontype].r, trackingTypes[icontype].t, trackingTypes[icontype].b)

    GwMiniMapTrackingFrame:RegisterEvent("MINIMAP_UPDATE_TRACKING")
    GwMiniMapTrackingFrame:HookScript("OnEvent", function(self)
        local icontype = MiniMapTrackingIcon:GetTexture() or 136025
        if icontype == 132328 then icontype = icontype .. GW.myClassID end
        if trackingTypes[icontype] == nil then
            icontype = 136025
        end
        self.icon:SetTexCoord(trackingTypes[icontype].l, trackingTypes[icontype].r, trackingTypes[icontype].t, trackingTypes[icontype].b)
    end)
    GwMiniMapTrackingFrame:SetPoint("TOPLEFT", topPanel, "TOPRIGHT", -30, 0)


    --Time
    TimeManager_LoadUI()
    TimeManagerClockButton:Hide()
    GwMapTime = CreateFrame("Button", "GwMapTime", panel, "GwMapTime")
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
    GwMapCoords = CreateFrame("Button", "GwMapCoords", panel, "GwMapCoords")
    GwMapCoords.Coords:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.TextSizeType.NORMAL)
    GwMapCoords.Coords:SetTextColor(1, 1, 1)
    GwMapCoords.Coords:SetShadowOffset(2, -2)
    GwMapCoords.Coords:SetText(NOT_APPLICABLE)
    ToogleMinimapCoordsLable()

    --FPS
    GwMapFPS = CreateFrame("Button", "GwMapFPS", panel, "GwMapFPS")
    GwMapFPS.fps:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.TextSizeType.NORMAL)
    GwMapFPS.fps:SetTextColor(1, 1, 1)
    GwMapFPS.fps:SetShadowOffset(2, -2)
    GwMapFPS.fps:SetText(NOT_APPLICABLE)
    ToogleMinimapFpsLable()

    MinimapNorthTag:ClearAllPoints()
    MinimapNorthTag:SetPoint("TOP", Minimap, 0, 0)
    Minimap.northTag = MinimapNorthTag

    MinimapCluster:SetAlpha(0.0)
    MinimapBorder:Hide()
    MiniMapWorldMapButton:GwKill()

    MinimapZoneText:ClearAllPoints()
    MinimapZoneText:SetPoint("TOP", Minimap, 0, -5)
    MinimapZoneText:SetParent(GwMapGradient)
    MinimapZoneText:SetDrawLayer("OVERLAY", 2)
    MinimapZoneText:SetTextColor(1, 1, 1)
    Minimap.location = MinimapZoneText

    hooksecurefunc(
        MinimapZoneText,
        "SetText",
        function()
            MinimapZoneText:SetTextColor(1, 1, 1)
        end
    )

    --CalenderIcon
    GameTimeFrame:SetParent(Minimap)
    GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
    GameTimeFrame:SetSize(32, 32)

    hooksecurefunc("GameTimeFrame_SetDate", function()
        GameTimeFrame:GwStripTextures()
        GameTimeFrame:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/icons/calendar.png")
        GameTimeFrame:SetPushedTexture("Interface/AddOns/GW2_UI/Textures/icons/calendar.png")
        GameTimeFrame:SetHighlightTexture("Interface/AddOns/GW2_UI/Textures/icons/calendar.png")
    end)

    GW.CreateMinimapButtonsSack()
    MiniMapBattlefieldFrame:ClearAllPoints()
    GameTimeFrame:ClearAllPoints()
    MiniMapLFGFrame:ClearAllPoints()
    GwAddonToggle:ClearAllPoints()
    GwAddonToggle.container:ClearAllPoints()
    GameTimeFrame:SetPoint("TOP", sidePanel, "TOP", -5, 0)
    MiniMapBattlefieldFrame:SetPoint("TOP", GameTimeFrame, "BOTTOM", 0, 0)
    MiniMapLFGFrame:SetPoint("TOP", MiniMapBattlefieldFrame, "BOTTOM", 0, 0)
    GwAddonToggle:SetPoint("TOP", MiniMapLFGFrame, "BOTTOM", -3, 0)
    GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")

    Minimap:SetScale(1.2)

    hideMiniMapIcons()

    SetMinimapHover()
    C_Timer.After(0.2, hoverMiniMapOut)

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

    -- mobeable stuff
    GW.RegisterMovableFrame(Minimap, MINIMAP_LABEL, "MinimapPos", ALL .. ",Blizzard,Map", {Minimap:GetSize()}, {"default"}, nil, MinimapPostDrag)
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

    if not GW.ShouldBlockIncompatibleAddon("Objectives") then
        MinimapCluster:SetSize(GwMinimapShadow:GetWidth(), 5)
        MinimapCluster:ClearAllPoints()
        MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -320, 0)
    end

    Minimap:SetPlayerTexture("Interface/AddOns/GW2_UI/textures/icons/player_arrow.png")

    GW.UpdateMinimapSize()
end
GW.LoadMinimap = LoadMinimap
