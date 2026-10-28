---@class GW2
local GW = select(2, ...)
local L = GW.L

local effectiveHeight
local MAP_FRAMES_HIDE = {}
MAP_FRAMES_HIDE[1] = MiniMapMailIcon
MAP_FRAMES_HIDE[2] = MiniMapTracking
MAP_FRAMES_HIDE[3] = MinimapToggleButton
-- vanilla and tbc have only the day and night icon there, the calendar button came with wrath
local HAS_CALENDAR = not (GW.Classic or GW.TBC)
MAP_FRAMES_HIDE[4] = not HAS_CALENDAR and GameTimeFrame
MAP_FRAMES_HIDE[5] = MinimapCluster.DielFrame

local EVENT_BUTTON = MinimapBackdrop.ExternalEventURLButton

local M = CreateFrame("Frame")

local minimapDetails = {
    ["ZONE"] = "GwMapGradient",
    ["CLOCK"] = "GwMapTime",
    ["COORDS"] = "GwMapCoords",
    ["LAYER"] = "GwMapLayer",
}

local expansionLandingPageTable = {
    { -- WOD
        id = 1,
        enabled = C_Garrison and C_Garrison.GetNumFollowers(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower) > 0,
        text = (GARRISON_LANDING_PAGE_TITLE or "") .. " (Warlords of Draenor)",
        enumValue = Enum.GarrisonType.Type_6_0_Garrison,
        enumFollowerValue = Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower
    },
    { -- LEGION
        id = 2,
        enabled = C_Garrison and C_Garrison.GetNumFollowers(Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower) > 0,
        text = (ORDER_HALL_LANDING_PAGE_TITLE or "") .. " (Legion)",
        enumValue = Enum.GarrisonType.Type_7_0_Garrison,
        enumFollowerValue = Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower
    },
    { -- BFA
        id = 3,
        enabled = C_Garrison and C_Garrison.GetNumFollowers(Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower) > 0,
        text = (GARRISON_TYPE_8_0_LANDING_PAGE_TITLE or "") .. " (Battle for Azeroth)",
        enumValue = Enum.GarrisonType.Type_8_0_Garrison,
        enumFollowerValue = Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower
    },
    { -- SHADOWLANDS
        id = 4,
        enabled = C_Garrison and C_Garrison.GetNumFollowers(Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower) > 0,
        text = (GARRISON_TYPE_9_0_LANDING_PAGE_TITLE or "")  .. " (Shadowlands)",
        enumValue = Enum.GarrisonType.Type_9_0_Garrison,
        enumFollowerValue = Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower
    },
}

function GW.UpdateMinimapSize()
    local size = GW.settings.minimap.size
    local scale = GW.settings.minimap.scale

    Minimap:SetSize(size, size)
    Minimap:SetScale(scale)
    Minimap.gwMover:SetScale(scale)

    Minimap:ClearAllPoints()
    Minimap.location:ClearAllPoints()
    if Minimap.northTag then
        Minimap.northTag:ClearAllPoints()
    end
    MinimapBackdrop:ClearAllPoints()
    if GW.settings.minimap.keepSizeRatio then
        Minimap:SetMaskTexture(130937)
        Minimap:SetHitRectInsets(0, 0, 0, 0)
        Minimap:SetPoint("CENTER", Minimap.gwMover)
        Minimap.location:SetPoint("TOP", Minimap, "TOP", 0, -2)
        if Minimap.northTag then
            Minimap.northTag:SetPoint("TOP", Minimap, 0, 0)
        end
        Minimap.gwMover:SetSize(size, size)
        Minimap.gwMover:SetClampRectInsets(0, 0, 0, 0)
        Minimap.gwBorder:SetSize(size, size)
        MinimapBackdrop:SetAllPoints(Minimap)
        return
    end

    local maskId = floor(GW.settings.minimap.heightPercentage / 100 * 128)
    local texturePath = format([[Interface\AddOns\GW2_UI\Textures\MinimapMasks\%d.tga]], maskId)
    local heightPct = maskId / 128
    local newHeight = size * heightPct
    local diff = size - newHeight
    local halfDiff = ceil(diff / 2)
    local mmOffset = 1

    effectiveHeight = newHeight
    Minimap.gwMover:SetSize(GW.settings.minimap.size, effectiveHeight)
    Minimap.gwBorder:SetSize(GW.settings.minimap.size, effectiveHeight)

    Minimap:SetClampedToScreen(true)
    Minimap:SetClampRectInsets(0, 0, 0, 0)
    Minimap.gwMover:SetClampRectInsets(0, 0, halfDiff, -halfDiff)
    Minimap:SetPoint("TOPRIGHT", Minimap.gwMover, -mmOffset , -mmOffset + halfDiff)
    MinimapBackdrop:SetPoint("TOPRIGHT", Minimap, -mmOffset , -mmOffset + halfDiff)

    Minimap:SetMaskTexture(texturePath)
    Minimap:SetHitRectInsets(0, 0, halfDiff, halfDiff)

    Minimap.location:SetPoint("TOP", Minimap, 0, -4 - halfDiff)

    if Minimap.northTag then
        Minimap.northTag:SetPoint("TOP", Minimap, 0, -4 - halfDiff)
    end

    if HybridMinimap then
        local mapCanvas = HybridMinimap.MapCanvas
        local rectangleMask = HybridMinimap:CreateMaskTexture()
        rectangleMask:SetTexture(texturePath)
        rectangleMask:SetAllPoints(HybridMinimap)
        HybridMinimap.RectangleMask = rectangleMask
        mapCanvas:SetMaskTexture(rectangleMask)
        mapCanvas:SetUseMaskTexture(true)
    end
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
            v:GwKill()
        end
    end
end


local function MapCoordsMiniMap_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
    GameTooltip:AddLine(L["Map Coordinates"], 1, 1, 1)
    GameTooltip:AddLine(L["Left Click to toggle higher precision coordinates."], 0.8, 0.8, 0.8, true)
    GameTooltip:SetMinimumWidth(100)
    GameTooltip:Show()
end


local function mapCoordsMiniMap_setCoords(self)
    local x, y, xT, yT = GW.Location.GetCoords()
    self.Coords:SetShown(x ~= nil)
    self:EnableMouse(x ~= nil)
    if x and y then
        self.Coords:SetText(GW.GetLocalizedNumber(xT, GW.settings.minimap.coords.precision) .. "/" .. GW.GetLocalizedNumber(yT, GW.settings.minimap.coords.precision))
    end
end


local function MapCoordsMiniMap_OnClick(self, button)
    if button == "LeftButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

        if GW.settings.minimap.coords.precision == 0 then
            GW.settings.minimap.coords.precision = 2
        else
            GW.settings.minimap.coords.precision = 0
        end

        mapCoordsMiniMap_setCoords(self)
    end
end


-- blizzards fade shows its frame, a detail that is switched off (like the coordinates) stays hidden
local function hoverMiniMapIn()
    for k, v in pairs(GW.settings.minimap.alwaysShowHoverDetails) do
        local frame = v == false and minimapDetails[k] and _G[minimapDetails[k]]
        if frame and frame:IsShown() then
            UIFrameFadeIn(frame, 0.2, frame:GetAlpha(), 1)
        end
    end
end


local function hoverMiniMapOut()
    if GwMapTime:IsMouseOver() or GwMapCoords:IsMouseOver() then return end
    for k, v in pairs(GW.settings.minimap.alwaysShowHoverDetails) do
        local frame = v == false and minimapDetails[k] and _G[minimapDetails[k]]
        if frame and frame:IsShown() then
            UIFrameFadeOut(frame, 0.2, frame:GetAlpha(), 0)
        end
    end
end
GW.hoverMiniMapOut = hoverMiniMapOut

local function MapCoordsMiniMap_OnLeave()
    GameTooltip_Hide()
    hoverMiniMapOut()
end


local function GetMinimapShape()
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

local CALENDAR_TEXTURE = "Interface/AddOns/GW2_UI/textures/icons/calendar.png"
local calendarMirrored = false
local function UpdateCalendarIcon()
    local left, right = calendarMirrored and 1 or 0, calendarMirrored and 0 or 1
    if GameTimeFrame.StateTexture then
        for _, texture in ipairs({GameTimeFrame.StateTexture, GameTimeFrame.AddTexture}) do
            texture:SetTexture(CALENDAR_TEXTURE)
            texture:ClearAllPoints()
            texture:SetAllPoints()
            texture:SetTexCoord(left, right, 0, 1)
        end
    else
        for _, texture in pairs({GameTimeFrame:GetNormalTexture(), GameTimeFrame:GetHighlightTexture(), GameTimeFrame:GetPushedTexture()}) do
            texture:SetTexCoord(left, right, 0, 1)
        end
    end
end

local function setMinimapButtons(side)
    Minimap.sidePanel:ClearAllPoints()
    GwAddonToggle.container:ClearAllPoints()
    if side == "LEFT" then
        Minimap.sidePanel:SetPoint("TOPRIGHT", Minimap.gwBorder, "TOPLEFT", 5, 0)
        Minimap.sidePanel:SetPoint("BOTTOMRIGHT", Minimap.gwBorder, "BOTTOMLEFT", 5, 0)
        GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")
        --flip GwAddonToggle icon
        GwAddonToggle:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        GwAddonToggle:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
        GwAddonToggle:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
    else
        Minimap.sidePanel:SetPoint("TOPLEFT", Minimap.gwBorder, "TOPRIGHT")
        Minimap.sidePanel:SetPoint("BOTTOMLEFT", Minimap.gwBorder, "BOTTOMRIGHT")
        GwAddonToggle.container:SetPoint("LEFT", GwAddonToggle, "RIGHT")
        --flip GwAddonToggle icon
        GwAddonToggle:GetNormalTexture():SetTexCoord(1, 0, 0, 1)
        GwAddonToggle:GetHighlightTexture():SetTexCoord(1, 0, 0, 1)
        GwAddonToggle:GetPushedTexture():SetTexCoord(1, 0, 0, 1)
    end
    if HAS_CALENDAR then
        calendarMirrored = side ~= "LEFT"
        UpdateCalendarIcon()
    end
end

local function UpdateButtonSide()
    local side = GW.settings.minimap.buttonSide
    if side == "AUTO" then
        side = Minimap:GetCenter() > UIParent:GetRight() / 2 and "LEFT" or "RIGHT"
    end
    setMinimapButtons(side)
end

local function UpdateMinimapCoordsTicker(self)
    local shouldRun = GW.settings.minimap.coords.enabled and self:IsShown() and self:GetAlpha() > 0
    if shouldRun and not self.CoordsTimer then
        mapCoordsMiniMap_setCoords(self)
        self.CoordsTimer = C_Timer.NewTicker(0.5, function() mapCoordsMiniMap_setCoords(self) end)
    elseif not shouldRun and self.CoordsTimer then
        self.CoordsTimer:Cancel()
        self.CoordsTimer = nil
    end
end

function GW.ToogleMinimapCoordsLable()
    if GW.settings.minimap.coords.enabled then
        GwMapCoords:Show()
        GwMapCoords:SetScript("OnEnter", MapCoordsMiniMap_OnEnter)
        GwMapCoords:SetScript("OnClick", MapCoordsMiniMap_OnClick)
        GwMapCoords:SetScript("OnLeave", MapCoordsMiniMap_OnLeave)
    else
        GwMapCoords:Hide()
        GwMapCoords:SetScript("OnEnter", nil)
        GwMapCoords:SetScript("OnClick", nil)
        GwMapCoords:SetScript("OnLeave", nil)
    end
    UpdateMinimapCoordsTicker(GwMapCoords)
end

-- the classic realms put the layer into the guid of every creature, the zone part; it needs an npc nearby
local function UpdateLayer(self, event, unit)
    if event == "PLAYER_ENTERING_WORLD" then
        self:SetShown(not IsInInstance())
        self.text:SetText(L["Layer"] .. ": ?")
        return
    end
    if IsInInstance() then return end
    unit = event == "PLAYER_TARGET_CHANGED" and "target" or event == "UPDATE_MOUSEOVER_UNIT" and "mouseover" or unit
    local unitType, _, _, _, zoneUID = strsplit("-", UnitGUID(unit) or "")
    if unitType == "Creature" and zoneUID then
        self.text:SetText(L["Layer"] .. ": " .. zoneUID)
    end
end

local function CreateLayerLabel()
    local layer = CreateFrame("Frame", "GwMapLayer", Minimap)
    layer:SetFrameStrata(Minimap.gwBorder.gradient:GetFrameStrata())
    layer:SetFrameLevel(Minimap.gwBorder.gradient:GetFrameLevel())
    layer:SetSize(100, 14)
    layer:SetPoint("TOP", Minimap.location, "BOTTOM", 0, 2)
    layer.text = layer:CreateFontString(nil, "OVERLAY")
    layer.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW")
    layer.text:SetIgnoreParentScale(true)
    layer.text:SetScale(1)
    layer.text:SetPoint("CENTER")
    for _, event in ipairs({"PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT", "NAME_PLATE_UNIT_ADDED"}) do
        layer:RegisterEvent(event)
    end
    layer:SetScript("OnEvent", UpdateLayer)
    UpdateLayer(layer, "PLAYER_ENTERING_WORLD")
end

function GW.ToogleMinimapFpsLable()
    if GW.settings.minimap.fps then
        GW.BuildAddonList()
        GwMapFPS:SetScript("OnEnter", GW.FpsOnEnter)
        GwMapFPS:SetScript("OnLeave", GW.FpsOnLeave)
        GwMapFPS:SetScript("OnClick", GW.FpsOnClick)
        GwMapFPS:SetScript("OnEvent", GW.FpsOnEvent)
        GwMapFPS:RegisterEvent("MODIFIER_STATE_CHANGED")
        if GwMapFPS.updateTicker then
            GwMapFPS.updateTicker:Cancel()
        end
        GwMapFPS.updateTicker = C_Timer.NewTicker(1, function() GW.FpsOnUpdate(GwMapFPS) end)
        GW.FpsOnUpdate(GwMapFPS)
        GwMapFPS:Show()
    else
        GwMapFPS:SetScript("OnEnter", nil)
        GwMapFPS:SetScript("OnLeave", nil)
        GwMapFPS:SetScript("OnClick", nil)
        GwMapFPS:SetScript("OnEvent", nil)
        GwMapFPS:UnregisterEvent("MODIFIER_STATE_CHANGED")
        if GwMapFPS.updateTicker then
            GwMapFPS.updateTicker:Cancel()
            GwMapFPS.updateTicker = nil
        end
        GwMapFPS:Hide()
    end
end

local function Minimap_OnMouseDown(self, btn)
    if btn == "RightButton" then
        local button = (GW.isModern and MinimapCluster.Tracking.Button) or MiniMapTrackingButton
        if button then
            button:OpenMenu()

            if button.menu then
				local pos = Minimap.gwMover:GetPoint()
				local left = pos and pos:match('RIGHT')
				button.menu:ClearAllPoints()
				button.menu:SetPoint(left and 'TOPRIGHT' or 'TOPLEFT', Minimap, left and 'LEFT' or 'RIGHT', left and -4 or 4, 0)
			end
        end
    end
end

local function MapCanvas_OnMouseDown(self, btn)
    if btn == "RightButton" then
        local button = (GW.isModern and MinimapCluster.Tracking.Button) or MiniMapTrackingButton
        if button then
            button:OpenMenu()
        end
    end
end

local function Minimap_OnMouseWheel(_, d)
    if d > 0 then
        (MinimapZoomIn or Minimap.ZoomIn):Click()
    elseif d < 0 then
        (MinimapZoomOut or Minimap.ZoomOut):Click()
    end
end

-- the colors blizzards own minimap gives the zone name, by pvp type of the zone
local HOSTILE_ZONE_COLOR = CreateColor(1, 0.1, 0.1)
local ZONE_COLORS = {
    sanctuary = CreateColor(0.41, 0.8, 0.94),
    friendly = CreateColor(0.1, 1, 0.1),
    contested = CreateColor(1, 0.7, 0),
    hostile = HOSTILE_ZONE_COLOR,
    arena = HOSTILE_ZONE_COLOR,
    combat = HOSTILE_ZONE_COLOR,
}

local function GetLocTextColor()
    return (ZONE_COLORS[C_PvP.GetZonePVPInfo()] or NORMAL_FONT_COLOR):GetRGB()
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

local function lfgAnimPvPStop()
    MiniMapBattlefieldIcon:SetTexture("Interface/AddOns/GW2_UI/textures/lfgmicrobutton-down.png")
    MiniMapBattlefieldFrame.animationCircle:Hide()
    MiniMapBattlefieldIcon:SetTexCoord(unpack(GW.TexCoords))
end

local function lfgAnimPvP(_, elapse)
    if Minimap:IsShown() then
        MiniMapBattlefieldIcon:SetAlpha(1)
    else
        MiniMapBattlefieldIcon:SetAlpha(0)
        return
    end
    local status, _, _, _, _, _, isRankedArena = GetBattlefieldStatus(1)
    if status == "active" then
        lfgAnimPvPStop()
        return
    end
    MiniMapBattlefieldFrame.animationCircle:Show()

    if isRankedArena then
        MiniMapBattlefieldIcon:SetTexture("Interface/PVPFrame/PVP-ArenaPoints-Icon");
    elseif UnitFactionGroup("player") then
        MiniMapBattlefieldIcon:SetTexture("Interface/BattlefieldFrame/Battleground-"..UnitFactionGroup("player"));
    end

    local rot = MiniMapBattlefieldFrame.animationCircle.background:GetRotation() + (1.5 * elapse)

    MiniMapBattlefieldFrame.animationCircle.background:SetRotation(rot)
    MiniMapBattlefieldIcon:SetTexCoord(unpack(GW.TexCoords))
end

local LayoutSideButtons
local lfgFrameSetUp = false
local function SetUpLfgFrame()
    if not LFGMinimapFrame or lfgFrameSetUp then return end
    lfgFrameSetUp = true

    LFGMinimapFrame:HookScript("OnShow", LayoutSideButtons)
    LFGMinimapFrame:HookScript("OnHide", LayoutSideButtons)

    local GwLfgQueueIcon = CreateFrame("Frame", "GwLfgQueueIcon", LFGMinimapFrame, "GwLfgQueueIcon")
    GwLfgQueueIcon:SetAllPoints(LFGMinimapFrame)
    if LFGMinimapFrameBorder then LFGMinimapFrameBorder:GwKill() end
    if LFGMinimapFrameIconTexture then LFGMinimapFrameIconTexture:GwKill() end
    LFGMinimapFrame:SetSize(26, 26)
    LFGMinimapFrame:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/lfgminimapbutton-highlight.png")
    LFGMinimapFrame:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/lfganimation-1.png")
    hooksecurefunc(LFGMinimapFrameIcon, "StartAnimating", function()
        if not Minimap:IsShown() then return end
        GwLfgQueueIcon.animation:Play()
    end)
    hooksecurefunc(LFGMinimapFrameIcon, "StopAnimating", function()
        GwLfgQueueIcon.animation:Stop()
    end)

    local hookedTimerFrame = CreateFrame("Frame")
    MiniMapBattlefieldFrame:HookScript("OnShow", function()
        hookedTimerFrame:SetScript("OnUpdate", lfgAnimPvP)
    end)
    MiniMapBattlefieldFrame:HookScript("OnHide", function()
        lfgAnimPvPStop()
        hookedTimerFrame:SetScript("OnUpdate", nil)
    end)
    MiniMapBattlefieldFrame.animationCircle = CreateFrame("Frame", "GwLFDAnimation", MiniMapBattlefieldFrame, "GwLFDAnimation")

    GW.UpdateMinimapSideButtons()
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

function GW.HandleAddonCompartmentButton()
    if AddonCompartmentFrame then
        if not AddonCompartmentFrame.gw2Handled then
            AddonCompartmentFrame:GwStripTextures()
            AddonCompartmentFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
            AddonCompartmentFrame.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
            AddonCompartmentFrame:SetSize(18, 18)
            if AddonCompartmentFrame.StateTexture then
                local function HideStateTextures(self)
                    self.StateTexture:SetAlpha(0)
                    self.AddTexture:SetAlpha(0)
                end
                hooksecurefunc(AddonCompartmentFrame, "OnButtonStateChanged", HideStateTextures)
                HideStateTextures(AddonCompartmentFrame)
            end
            AddonCompartmentFrame.gw2Handled = true


            GW.MixinHideDuringPetAndOverride(AddonCompartmentFrame)
        end

        AddonCompartmentFrame:SetParent(GW.settings.minimap.sideButtons.COMPARTMENT and UIParent or GW.HiddenFrame)
    end
end

local SIDE_BUTTON_SPACING = 2
local queueAnchor
local function GetSideButtons(key)
    if key == "CALENDAR" then
        return HAS_CALENDAR and {{GameTimeFrame, GameTimeFrame, -5}}
    elseif key == "COMPARTMENT" then
        return GW.isModern and {{AddonCompartmentFrame, AddonCompartmentFrame, -4}}
    elseif key == "ADDONS" then
        return {{GwAddonToggle, GwAddonToggle, -5}}
    elseif key == "EVENT" then
        return EVENT_BUTTON and {{EVENT_BUTTON, EVENT_BUTTON, -2}}
    elseif key == "QUEUE" then
        if GW.isModern then
            return {{queueAnchor, QueueStatusButton, -5}}
        end
        return {{MiniMapBattlefieldFrame, MiniMapBattlefieldFrame, -7}, {LFGMinimapFrame, LFGMinimapFrame, -5}}
    end
end

-- the saved order first, buttons that came later after it
local function GetSideButtonOrder()
    local order, seen = {}, {}
    for _, list in ipairs({GW.settings.minimap.sideButtonOrder, GW.globalDefault.profile.minimap.sideButtonOrder}) do
        for _, key in ipairs(list) do
            if not seen[key] then
                seen[key] = true
                tinsert(order, key)
            end
        end
    end
    return order
end

LayoutSideButtons = function()
    if not Minimap.sidePanel then return end
    local buttons = GW.settings.minimap.sideButtons
    local y = 0
    for _, key in ipairs(GetSideButtonOrder()) do
        for _, entry in ipairs(buttons[key] and GetSideButtons(key) or {}) do
            local anchor, frame, x = entry[1], entry[2], entry[3]
            if anchor and frame and frame:IsShown() then
                anchor:ClearAllPoints()
                anchor:SetPoint("TOP", Minimap.sidePanel, "TOP", x, -y)
                y = y + frame:GetHeight() + SIDE_BUTTON_SPACING
            end
        end
    end
end

local function SetSideButtonShown(frame, shown)
    if not frame then return end
    frame.gwParent = frame.gwParent or frame:GetParent()
    frame:SetParent(shown and frame.gwParent or GW.HiddenFrame)
end

function GW.UpdateMinimapSideButtons()
    local buttons = GW.settings.minimap.sideButtons
    if HAS_CALENDAR then
        SetSideButtonShown(GameTimeFrame, buttons.CALENDAR)
    end
    if GW.isModern then
        SetSideButtonShown(ExpansionLandingPageMinimapButton or GarrisonLandingPageMinimapButton, buttons.EXPANSION)
        SetSideButtonShown(QueueStatusButton, buttons.QUEUE)
        GW.HandleAddonCompartmentButton()
    else
        SetSideButtonShown(MiniMapBattlefieldFrame, buttons.QUEUE)
        SetSideButtonShown(LFGMinimapFrame, buttons.QUEUE)
    end
    SetSideButtonShown(EVENT_BUTTON, buttons.EVENT)
    SetSideButtonShown(GwAddonToggle, buttons.ADDONS)
    LayoutSideButtons()
    UpdateButtonSide()
end

do
    local isResetting

    local function ResetZoom()
        Minimap:SetZoom(0)
        if GW.isModern then
            Minimap.ZoomIn:Enable()
            Minimap.ZoomOut:Disable()
        else
            MinimapZoomIn:Enable()
            MinimapZoomOut:Disable()
        end

        isResetting = false
    end

    local function SetupZoomReset()
        if GW.settings.minimap.resetZoom > 0 and not isResetting then
            isResetting = true

            GW.Wait(GW.settings.minimap.resetZoom, ResetZoom)
        end
    end
    GW.SetupZoomReset = SetupZoomReset
end

function GW.LoadMinimap()
    -- https://wowwiki.wikia.com/wiki/USERAPI_GetMinimapShape
    _G.GetMinimapShape = GetMinimapShape

    GW.RegisterMovableFrame(Minimap, MINIMAP_LABEL, "minimap", "Blizzard,Map", {Minimap:GetSize()}, nil, nil, UpdateButtonSide)
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
    if GW.isModern then
        Minimap:SetArchBlobRingAlpha(0)
        Minimap:SetArchBlobRingScalar(0)
        Minimap:SetQuestBlobRingAlpha(0)
        Minimap:SetQuestBlobRingScalar(0)
    end

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

    if MiniMapTrackingButton then
        MiniMapTrackingButton:SetParent(Minimap)
        MiniMapTrackingButton:EnableMouse(false)
        MiniMapTrackingButton:SetAlpha(0)
        MiniMapTrackingButtonBorder:Hide()
    end


    -- Minimap Tracking Button
    if GW.isModern then
        MinimapCluster.Tracking.Button:EnableMouse(false)
        MinimapCluster.Tracking.Button:SetAlpha(0)
    end

    Minimap:HookScript("OnEnter", hoverMiniMapIn)
    Minimap:HookScript("OnLeave", hoverMiniMapOut)

    Minimap:HookScript("OnShow", minimap_OnShow)
    Minimap:HookScript("OnHide", minimap_OnHide)

    --Reset Zoom function
    hooksecurefunc(Minimap, "SetZoom", GW.SetupZoomReset)

    MinimapCluster.ZoneTextButton:GwKill()
    if TimeManagerClockButton then
        TimeManagerClockButton:GwKill()
    end

    Minimap.gwBorder.gradient.location = Minimap.gwBorder.gradient:CreateFontString(nil, "OVERLAY")
    Minimap.gwBorder.gradient.location:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -2)
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
        MinimapZoomIn or Minimap.ZoomIn,
        MinimapZoomOut or Minimap.ZoomOut,
        MinimapCompassTexture,
        MinimapCluster.IndicatorFrame
    }

    if MinimapCluster.BorderTop then
        MinimapCluster.BorderTop:GwStripTextures()
    end

    -- retail and forever have coordinates of their own now, ours stay; the cvar stays the players choice
    local blizzardCoords = MinimapCluster.MinimapContainer and MinimapCluster.MinimapContainer.PlayerCoords
    if blizzardCoords then
        blizzardCoords:GwKill()
    end

    if MinimapCluster.Tracking then
        MinimapCluster.Tracking.Background:GwStripTextures()
    end

    for _, frame in next, killFrames do
        frame:GwKill()
    end

    if GW.isModern then
        hooksecurefunc(ExpansionLandingPageMinimapButton, "UpdateIcon", HandleExpansionButton)
        HandleExpansionButton()
    end

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
            elseif addon == "Blizzard_EncounterJournal" and EJ_HideNonInstancePanels then
                -- Since the default non-quest map is full screen, it overrides the showing of the encounter journal
                hooksecurefunc("EJ_HideNonInstancePanels", function()
                    if InCombatLockdown() or not WorldMapFrame:IsShown() then return end

                    HideUIPanel(WorldMapFrame)
                end)
            end
        else
            if not GW.isModern and event == "PLAYER_ENTERING_WORLD" then
                SetUpLfgFrame()
            end
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
    GwMapTime.Time:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    GwMapTime.Time:SetTextColor(1, 1, 1)
    GwMapTime.timeTimer = C_Timer.NewTicker(1, function()
        GwMapTime.Time:SetText(GameTime_GetTime(true))
        GwMapTime:SetWidth(math.max(50, GwMapTime.Time:GetStringWidth() + 10))
    end)
    GwMapTime:RegisterEvent("UPDATE_INSTANCE_INFO")
    GwMapTime:SetScript("OnClick", GW.Time_OnClick)
    GwMapTime:SetScript("OnEnter", GW.Time_OnEnter)
    GwMapTime:SetScript("OnLeave", GW.Time_OnLeave)
    GwMapTime:HookScript("OnLeave", hoverMiniMapOut)
    GwMapTime:SetScript("OnEvent", GW.Time_OnEvent)

    --coords
    GwMapCoords = CreateFrame("Button", "GwMapCoords", panel, "GwMapCoords")
    GwMapCoords.Coords:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    GwMapCoords.Coords:SetTextColor(1, 1, 1)
    GwMapCoords.Coords:SetText(NOT_APPLICABLE)
    hooksecurefunc(GwMapCoords, "SetAlpha", UpdateMinimapCoordsTicker)
    GW.ToogleMinimapCoordsLable()

    --FPS
    GwMapFPS = CreateFrame("Button", "GwMapFPS", panel, "GwMapFPS")
    GwMapFPS.fps:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    GwMapFPS.fps:SetTextColor(1, 1, 1)
    GwMapFPS.fps:SetText(NOT_APPLICABLE)
    GW.ToogleMinimapFpsLable()

    -- the modern clients have no layers
    if not GW.isModern then
        CreateLayerLabel()
    end

    --CalenderIcon
    GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
    GameTimeFrame:SetSize(32, 32)

    if GameTimeFrame.StateTexture then
        hooksecurefunc(GameTimeFrame, "OnButtonStateChanged", UpdateCalendarIcon)
        UpdateCalendarIcon()
    elseif GameTimeFrame_SetDate then
        local dayText = GameTimeFrame:GetFontString()
        if dayText then
            dayText:SetAlpha(0)
        end
        hooksecurefunc("GameTimeFrame_SetDate", function()
            GameTimeFrame:GwStripTextures()
            GameTimeFrame:SetNormalTexture(CALENDAR_TEXTURE)
            GameTimeFrame:SetPushedTexture(CALENDAR_TEXTURE)
            GameTimeFrame:SetHighlightTexture(CALENDAR_TEXTURE)
            UpdateCalendarIcon()
        end)
    end

    if MinimapNorthTag then
        MinimapNorthTag:ClearAllPoints()
        MinimapNorthTag:SetPoint("TOP", Minimap, 0, 0)
        Minimap.northTag = MinimapNorthTag
    end

    -- Addon Icons
    GW.CreateMinimapButtonsSack()
    GwAddonToggle:ClearAllPoints()
    if GW.isModern then
        local expButton = ExpansionLandingPageMinimapButton or GarrisonLandingPageMinimapButton
        QueueStatusButton:ClearAllPoints()
        expButton:ClearAllPoints()
        expButton:SetPoint("BOTTOMRIGHT", Minimap.sidePanel, "BOTTOMLEFT", 0, -3)

        queueAnchor = CreateFrame("Frame", nil, Minimap.sidePanel)
        queueAnchor:SetSize(1, 1)
        queueAnchor:SetPoint("TOP", Minimap.sidePanel, "TOP")

        QueueStatusButton:SetParent(UIParent)
        QueueStatusButton:SetPoint("TOP", queueAnchor, "TOP", 0, 0)
        hooksecurefunc(QueueStatusButton, "SetPoint", function(self, _, relativeTo)
            if relativeTo ~= queueAnchor then
                self:ClearAllPoints()
                self:SetPoint("TOP", queueAnchor, "TOP", 0, 0)
            end
        end)
        hooksecurefunc(QueueStatusButton, "SetParent", function(self, parent)
            local target = GW.settings.minimap.sideButtons.QUEUE and UIParent or GW.HiddenFrame
            if parent ~= target then
                self:SetParent(target)
            end
        end)
        if QueueStatusButton.UpdatePosition then
            hooksecurefunc(QueueStatusButton, "UpdatePosition", UpdateButtonSide)
        end
    elseif GW.TBC or GW.Wrath or GW.Mists or GW.Classic then
        MiniMapBattlefieldFrame:ClearAllPoints()
    end

    if EVENT_BUTTON then
        for _, region in ipairs({EVENT_BUTTON:GetRegions()}) do
            if region:IsObjectType("MaskTexture") then
                EVENT_BUTTON.Icon:RemoveMaskTexture(region)
            end
        end
        EVENT_BUTTON.Border:SetAlpha(0)
        EVENT_BUTTON.SpellEffectModelScene:SetAlpha(0)
        EVENT_BUTTON:SetSize(24, 24)
        -- blizzard moves the icon by a pixel while pressed, keep it on the border
        local function AnchorEventIcon(self)
            self.Icon:ClearAllPoints()
            self.Icon:SetAllPoints()
        end
        hooksecurefunc(EVENT_BUTTON, "OnButtonStateChanged", AnchorEventIcon)
        AnchorEventIcon(EVENT_BUTTON)
        GW.HandleIcon(EVENT_BUTTON.Icon)
        EVENT_BUTTON.Icon:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true, 1, 1)
        EVENT_BUTTON.Icon.backdrop:SetBackdropBorderColor(GW.Colors.SkinColors.IconBorder:GetRGBA())
        EVENT_BUTTON:HookScript("OnEnter", function(self) self.Icon:SetBlendMode("ADD") end)
        EVENT_BUTTON:HookScript("OnLeave", function(self) self.Icon:SetBlendMode("BLEND") end)
        -- on UIParent like the other side buttons, the minimap scale would stretch its offsets
        EVENT_BUTTON.gwParent = UIParent
        EVENT_BUTTON:SetParent(UIParent)
        hooksecurefunc(EVENT_BUTTON, "SetParent", function(self, parent)
            local target = GW.settings.minimap.sideButtons.EVENT and UIParent or GW.HiddenFrame
            if parent ~= target then
                self:SetParent(target)
            end
        end)
        EVENT_BUTTON:ClearAllPoints()
        EVENT_BUTTON:HookScript("OnShow", LayoutSideButtons)
        EVENT_BUTTON:HookScript("OnHide", LayoutSideButtons)
    end

    for _, frame in ipairs({GwAddonToggle, GW.isModern and QueueStatusButton or MiniMapBattlefieldFrame}) do
        frame:HookScript("OnShow", LayoutSideButtons)
        frame:HookScript("OnHide", LayoutSideButtons)
    end

    GwAddonToggle.container:ClearAllPoints()
    GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")

    if Minimap.SetPlayerTexture then
        Minimap:SetPlayerTexture("Interface/AddOns/GW2_UI/textures/icons/player_arrow.png")
    end

    hideMiniMapIcons()

    SetMinimapHover()
    C_Timer.After(0.2, hoverMiniMapOut)

    GW.SkinMinimapInstanceDifficult()

    if GW.TBC or GW.Wrath or GW.Classic then
        MiniMapBattlefieldBorder:SetTexture(nil)
        BattlegroundShine:SetTexture(nil)
    end

    if QueueStatusButton then
        QueueStatusButton:GwKillEditMode()
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
    end

    GW.UpdateMinimapSideButtons()
    GW.UpdateMinimapSize()
end
