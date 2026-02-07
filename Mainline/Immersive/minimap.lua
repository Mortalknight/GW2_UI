local _, GW = ...
local L = GW.L

local MAP_FRAMES_HIDE = {}
MAP_FRAMES_HIDE[1] = MiniMapMailIcon
MAP_FRAMES_HIDE[2] = MiniMapTrackingButton
MAP_FRAMES_HIDE[3] = MiniMapTracking

local M = CreateFrame("Frame")

local minimapDetails = {
    ["ZONE"] = "GwMapGradient",
    ["CLOCK"] = "GwMapTime",
    ["COORDS"] = "GwMapCoords"
}

local expansionLandingPageTable = {
    { -- WOD
        id = 1,
        enabled = C_Garrison.GetNumFollowers(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower) > 0,
        text = GARRISON_LANDING_PAGE_TITLE .. " (Warlords of Draenor)",
        enumValue = Enum.GarrisonType.Type_6_0_Garrison,
        enumFollowerValue = Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower
    },
    { -- LEGION
        id = 2,
        enabled = C_Garrison.GetNumFollowers(Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower) > 0,
        text = ORDER_HALL_LANDING_PAGE_TITLE .. " (Legion)",
        enumValue = Enum.GarrisonType.Type_7_0_Garrison,
        enumFollowerValue = Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower
    },
    { -- BFA
        id = 3,
        enabled = C_Garrison.GetNumFollowers(Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower) > 0,
        text = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE .. " (Battle for Azeroth)",
        enumValue = Enum.GarrisonType.Type_8_0_Garrison,
        enumFollowerValue = Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower
    },
    { -- SHADOWLANDS
        id = 4,
        enabled = C_Garrison.GetNumFollowers(Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower) > 0,
        text = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE  .. " (Shadowlands)",
        enumValue = Enum.GarrisonType.Type_9_0_Garrison,
        enumFollowerValue = Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower
    },
}

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
        GwMapFPS:SetScript("OnEvent", GW.FpsOnEvent)
        GwMapFPS:RegisterEvent("MODIFIER_STATE_CHANGED")
        GwMapFPS:Show()
    else
        GwMapFPS:SetScript("OnEnter", nil)
        GwMapFPS:SetScript("OnUpdate", nil)
        GwMapFPS:SetScript("OnLeave", nil)
        GwMapFPS:SetScript("OnClick", nil)
        GwMapFPS:SetScript("OnEvent", nil)
        GwMapFPS:UnregisterEvent("MODIFIER_STATE_CHANGED")
        GwMapFPS:Hide()
    end
end
GW.ToogleMinimapFpsLable = ToogleMinimapFpsLable

local function Minimap_OnMouseDown(self, btn)
    if btn == "RightButton" then
        self.gwTrackingButton:OpenMenu()
    end
end

local function MapCanvas_OnMouseDown(self, btn)
    if btn == "RightButton" then
        self.gwTrackingButton:OpenMenu()
    end
end

local function Minimap_OnMouseWheel(_, d)
    if d > 0 then
        Minimap.ZoomIn:Click()
    elseif d < 0 then
        Minimap.ZoomOut:Click()
    end
end

local function GetLocTextColor()
    local pvpType = C_PvP.GetZonePVPInfo()
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
    Minimap.location:SetText(string.utf8sub(GetMinimapZoneText(), 1, 46))
    Minimap.location:SetTextColor(GetLocTextColor())
end

local function UpdateUxpansionLandingPageTable()
    for _, v in pairs(expansionLandingPageTable) do
        v.enabled = C_Garrison.GetNumFollowers(v.enumFollowerValue) > 0
    end
end

local function ExpansionLandingPageMinimapButtonDropdown(self)
    self:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            if ExpansionLandingPage:IsVisible() then
                ToggleExpansionLandingPage()
            end

            MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
                rootDescription:SetMinimumWidth(1)
                UpdateUxpansionLandingPageTable()

                sort(expansionLandingPageTable, function(a, b)
                    return a.id < b.id
                end)

                for _, v in pairs(expansionLandingPageTable) do

                    local btn = rootDescription:CreateButton(v.text, function()
                        if (GarrisonLandingPage and GarrisonLandingPage:IsShown()) then
                            HideUIPanel(GarrisonLandingPage)
                        end
                        local num = C_Garrison.GetAvailableMissions(GetPrimaryGarrisonFollowerType(v.enumValue))
                        if num == nil then return end
                        ShowGarrisonLandingPage(v.enumValue)
                        GarrisonMinimap_HideHelpTip(ExpansionLandingPageMinimapButton)
                    end)
                    btn:SetEnabled(v.enabled)

                end
            end)

            if C_AddOns.IsAddOnLoaded("WarPlan") then
                HideDropDownMenu(1)
            end
        else
            self:ToggleLandingPage()
        end
    end)
end

local function HandleExpansionButton()
    local garrison = ExpansionLandingPageMinimapButton
    if not garrison then return end

    if not garrison.gw2Hooked then
        garrison:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        ExpansionLandingPageMinimapButtonDropdown(garrison)
        hooksecurefunc(ExpansionLandingPageMinimapButton, "HandleGarrisonEvent", UpdateUxpansionLandingPageTable)

        garrison.gw2Hooked = true
    end

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

    if garrison:IsInGarrisonMode() then
        if (garrisonType == Enum.GarrisonType.Type_6_0_Garrison) then
            garrison.faction = UnitFactionGroup("player")
            garrison.title = GARRISON_LANDING_PAGE_TITLE;
            garrison.description = MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP
        elseif (garrisonType == Enum.GarrisonType.Type_7_0_Garrison) then
            garrison.title = ORDER_HALL_LANDING_PAGE_TITLE;
            garrison.description = MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP
        elseif (garrisonType == Enum.GarrisonType.Type_8_0_Garrison) then
            garrison.title = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE;
            garrison.description = GARRISON_TYPE_8_0_LANDING_PAGE_TOOLTIP
        elseif (garrisonType == Enum.GarrisonType.Type_9_0_Garrison) then
            garrison.title = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE;
            garrison.description = GARRISON_TYPE_9_0_LANDING_PAGE_TOOLTIP
        end
        garrison:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up.png")
        garrison:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down.png")
        garrison:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down.png")
        garrison.LoopingGlow:SetTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up.png")
    else
        local minimapDisplayInfo = ExpansionLandingPage:GetOverlayMinimapDisplayInfo();
        if minimapDisplayInfo then
            garrison.title = minimapDisplayInfo.title;
            garrison.description = minimapDisplayInfo.description;
        end
        local expansionLandingPageType = ExpansionLandingPage:GetLandingPageType()
        if expansionLandingPageType == Enum.ExpansionLandingPageType.Dragonflight then
            garrison:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon.png")
            garrison:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon.png")
            garrison:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon.png")
            garrison.LoopingGlow:SetTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon.png")
        elseif expansionLandingPageType == Enum.ExpansionLandingPageType.WarWithin then
            garrison:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-tww.png")
            garrison:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-tww-active.png")
            garrison:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-tww-active.png")
            garrison.LoopingGlow:SetTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-tww-active.png")
        end
    end
end

local function SetupHybridMinimap()
    local MapCanvas = HybridMinimap.MapCanvas
    MapCanvas:SetScript("OnMouseWheel", Minimap_OnMouseWheel)
    MapCanvas:SetScript("OnMouseDown", MapCanvas_OnMouseDown)
    MapCanvas:SetScript("OnMouseUp", GW.NoOp)

    HybridMinimap.CircleMask:GwStripTextures()
end

local function UpdateClusterPoint(_, _, anchor)
    if anchor ~= GW2UI_MinimapClusterHolder then
        MinimapCluster:ClearAllPoints()
        MinimapCluster:SetPoint("TOPRIGHT", GW2UI_MinimapClusterHolder, 0, 1)
    end
end

local function HandleAddonCompartmentButton()
    if AddonCompartmentFrame then
        if not AddonCompartmentFrame.gw2Handled then
            AddonCompartmentFrame:GwStripTextures()
            AddonCompartmentFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
            AddonCompartmentFrame.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
            AddonCompartmentFrame:SetSize(18, 18)
            AddonCompartmentFrame.gw2Handled = true


            GW.MixinHideDuringPetAndOverride(AddonCompartmentFrame)
        end

        if GW.settings.MINIMAP_ADDON_COMPARTMENT_TOGGLE then
            AddonCompartmentFrame:SetParent(UIParent)
        else
            AddonCompartmentFrame:SetParent(GW.HiddenFrame)
        end
    end
end
GW.HandleAddonCompartmentButton = HandleAddonCompartmentButton

do
    local isResetting

    local function ResetZoom()
        Minimap:SetZoom(0)
        Minimap.ZoomIn:Enable()
        Minimap.ZoomOut:Disable()

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
    GetMinimapShape = GetMinimapShape

    GW.RegisterMovableFrame(Minimap, MINIMAP_LABEL, "MinimapPos", ALL .. ",Blizzard,Map", {Minimap:GetSize()}, {"default"}, nil, MinimapPostDrag)
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

    Minimap.gwBorder = CreateFrame("Frame", "GwMinimapShadow", Minimap, "GwMinimapShadow")
    Minimap.gwBorder:ClearAllPoints()
    Minimap.gwBorder:SetPoint("CENTER", Minimap)
    Minimap.gwBorder.gradient = CreateFrame("Frame", "GwMapGradient", Minimap.gwBorder, "GwMapGradient")
    Minimap.gwBorder.gradient:SetParent(Minimap.gwBorder)
    Minimap.gwBorder.gradient:SetPoint("TOPLEFT", Minimap.gwBorder, "TOPLEFT", 0, 0)
    Minimap.gwBorder.gradient:SetPoint("TOPRIGHT", Minimap.gwBorder, "TOPRIGHT", 0, 0)

    if Minimap.backdrop then -- level to hybrid maps fixed values
        Minimap.backdrop:SetFrameLevel(99)
        Minimap.backdrop:SetFrameStrata("BACKGROUND")
        Minimap.backdrop:SetIgnoreParentScale(true)
        Minimap.backdrop:SetScale(1)
    end

    local clickHandler = CreateFrame("Frame", "Gw2UI_MinimapClickHandler", Minimap)
    clickHandler:SetPassThroughButtons("LeftButton")
    clickHandler:SetPropagateMouseMotion(true)
    clickHandler:SetAllPoints()

    clickHandler:SetScript("OnMouseWheel", Minimap_OnMouseWheel)
    clickHandler:SetScript("OnMouseDown", Minimap_OnMouseDown)

    -- Minimap Tracking Button
    clickHandler.gwTrackingButton = CreateFrame("DropdownButton")
    clickHandler.gwTrackingButton:SetFrameStrata("BACKGROUND")
    MinimapCluster.Tracking.Button:SetParent(GW.HiddenFrame)
    Mixin(clickHandler.gwTrackingButton, MiniMapTrackingButtonMixin)
    clickHandler.gwTrackingButton:OnLoad()
    clickHandler.gwTrackingButton:SetScript("OnEvent", clickHandler.gwTrackingButton.OnEvent)
    clickHandler.gwTrackingButton:SetAllPoints(Minimap)

    Minimap:HookScript("OnEnter", hoverMiniMapIn)
    Minimap:HookScript("OnLeave", hoverMiniMapOut)

    Minimap:HookScript("OnShow", minimap_OnShow)
    Minimap:HookScript("OnHide", minimap_OnHide)

    --Reset Zoom function
    hooksecurefunc(Minimap, "SetZoom", GW.SetupZoomReset)

    MinimapCluster.ZoneTextButton:GwKill()
    TimeManagerClockButton:GwKill()

    Minimap.gwBorder.gradient.location = Minimap.gwBorder.gradient:CreateFontString(nil, "OVERLAY")
    Minimap.gwBorder.gradient.location:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -2)
    Minimap.gwBorder.gradient.location:SetPoint("TOP", Minimap, "TOP", 0, -2)
    Minimap.gwBorder.gradient.location:SetJustifyH("CENTER")
    Minimap.gwBorder.gradient.location:SetJustifyV("MIDDLE")
    Minimap.gwBorder.gradient.location:SetIgnoreParentScale(true)
    Minimap.gwBorder.gradient.location:SetScale(1)
    Minimap.location = Minimap.gwBorder.gradient.location

    local killFrames = {
        MinimapBorder,
        MinimapBorderTop,
        MinimapNorthTag,
        MinimapZoneTextButton,
        MiniMapWorldMapButton,
        MiniMapMailBorder,
        MiniMapTracking,
        Minimap.ZoomIn,
        Minimap.ZoomOut,
        MinimapCompassTexture,
        MinimapCluster.IndicatorFrame
    }

    MinimapCluster.BorderTop:GwStripTextures()
    MinimapCluster.Tracking.Background:GwStripTextures()

    for _, frame in next, killFrames do
        frame:GwKill()
    end

    hooksecurefunc(ExpansionLandingPageMinimapButton, "UpdateIcon", HandleExpansionButton)
    HandleExpansionButton()

    QueueStatusFrame:SetClampedToScreen(true)

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

    local panel = CreateFrame("Frame", nil, Minimap)
    panel:SetPoint("BOTTOMLEFT", Minimap.gwBorder, "BOTTOMLEFT", 5, 0)
    panel:SetPoint("BOTTOMRIGHT", Minimap.gwBorder, "BOTTOMRIGHT", 5, 0)
    panel:SetHeight(25)
    Minimap.lowerPanel = panel

    local sidePanel = CreateFrame("Frame", nil, Minimap)
    sidePanel:SetPoint("TOPRIGHT", Minimap.gwBorder, "TOPLEFT")
    sidePanel:SetPoint("BOTTOMRIGHT", Minimap.gwBorder, "BOTTOMLEFT")
    sidePanel:SetWidth(40)
    Minimap.sidePanel = sidePanel

    --Time
    GwMapTime = CreateFrame("Button", "GwMapTime", panel, "GwMapTime")
    GwMapTime:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    GwMapTime.Time:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.TextSizeType.NORMAL)
    GwMapTime.Time:SetTextColor(1, 1, 1)
    GwMapTime.Time:SetShadowOffset(2, -2)
    GwMapTime.timeTimer = C_Timer.NewTicker(0.2, function()
        GwMapTime.Time:SetText(GameTime_GetTime(false))
    end)
    GwMapTime:RegisterEvent("UPDATE_INSTANCE_INFO")
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

    --CalenderIcon
    GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
    GameTimeFrame:SetSize(32, 32)

    hooksecurefunc("GameTimeFrame_SetDate", function()
        GameTimeFrame:GwStripTextures()
        GameTimeFrame:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/calendar.png")
        GameTimeFrame:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/calendar.png")
        GameTimeFrame:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/calendar.png")
    end)

    -- Addon Icons
    GW.CreateMinimapButtonsSack()
    local expButton = ExpansionLandingPageMinimapButton or GarrisonLandingPageMinimapButton
    QueueStatusButton:ClearAllPoints()
    GameTimeFrame:ClearAllPoints()
    expButton:ClearAllPoints()
    GwAddonToggle:ClearAllPoints()
    GwAddonToggle.container:ClearAllPoints()
    AddonCompartmentFrame:ClearAllPoints()
    GameTimeFrame:SetPoint("TOP", Minimap.sidePanel, "TOP", -5, 0)
    AddonCompartmentFrame:SetPoint("TOP", GameTimeFrame, "BOTTOM", 1, 0)
    GwAddonToggle:SetPoint("TOP", GameTimeFrame, "BOTTOM", 0, -20) -- also attached to the gametime because the compartment be be hidden
    GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")
    expButton:SetPoint("BOTTOMRIGHT", Minimap.sidePanel, "BOTTOMLEFT", 0, -3)
    QueueStatusButton:SetPoint("TOP", GwAddonToggle, "BOTTOM", 0, 0)
    QueueStatusButton.SetPoint = GW.NoOp
    QueueStatusButton.SetParent = GW.NoOp
    QueueStatusButton.ClearAllPoints = GW.NoOp
    hooksecurefunc(QueueStatusButton, "SetPoint", function(_, _, parent)
        if parent ~= GwAddonToggle then
            QueueStatusButton:ClearAllPoints()
            QueueStatusButton:SetParent(UIParent)
            QueueStatusButton:SetPoint("TOP", GwAddonToggle, "BOTTOM", 0, 0)
        end
    end)

    -- check on which side we need to set the buttons
    local x = Minimap:GetCenter()
    local screenWidth = UIParent:GetRight()
    if x > (screenWidth / 2) then
        setMinimapButtons("left")
    else
        setMinimapButtons("right")
    end

    HandleAddonCompartmentButton()

    hooksecurefunc(QueueStatusButton, "UpdatePosition", function()
        local x = Minimap:GetCenter()
        local screenWidth = UIParent:GetRight()
        if x > (screenWidth / 2) then
            setMinimapButtons("left")
        else
            setMinimapButtons("right")
        end
    end)

    Minimap:SetPlayerTexture("Interface/AddOns/GW2_UI/textures/icons/player_arrow.png")

    hideMiniMapIcons()

    SetMinimapHover()
    C_Timer.After(0.2, hoverMiniMapOut)

    GW.SkinMinimapInstanceDifficult()

    QueueStatusButton:SetSize(26, 26)
    QueueStatusButtonIcon:GwKill()
    QueueStatusButtonIcon.texture:SetTexture(nil)
    QueueStatusButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/lfgminimapbutton.png")
    QueueStatusButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/lfgminimapbutton-highlight.png")
    QueueStatusButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
    local GwLfgQueueIcon = CreateFrame("Frame", "GwLfgQueueIcon", QueueStatusButton, "GwLfgQueueIcon")
    GwLfgQueueIcon:SetPoint("CENTER", QueueStatusButton, "CENTER", 0, 0)
    hooksecurefunc(QueueStatusButtonIcon, "PlayAnim", function()
        if not Minimap:IsShown() then return end
        QueueStatusButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/lfganimation-1.png")
        QueueStatusButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/lfganimation-1-highlight.png")
        QueueStatusButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/lfganimation-1-highlight.png")
        GwLfgQueueIcon.animation:Play()
    end)
    hooksecurefunc(QueueStatusButtonIcon, "StopAnimating", function()
        GwLfgQueueIcon.animation:Stop()
        QueueStatusButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/lfgminimapbutton.png")
        QueueStatusButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/lfgminimapbutton-highlight.png")
        QueueStatusButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/lfgminimapbutton-highlight.png")
    end)

    GW.UpdateMinimapSize()
end
GW.LoadMinimap = LoadMinimap
