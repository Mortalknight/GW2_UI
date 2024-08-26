local _, GW = ...
local L = GW.L
local RoundDec = GW.RoundDec

local MAP_FRAMES_HIDE = {}
MAP_FRAMES_HIDE[1] = MiniMapMailIcon
MAP_FRAMES_HIDE[2] = MiniMapVoiceChatFrame
MAP_FRAMES_HIDE[3] = MiniMapTrackingButton
MAP_FRAMES_HIDE[4] = MiniMapTracking

local ALWAYS_ON_FILTERS = {
    [Enum.MinimapTrackingFilter.QuestPoIs] = true,
    [Enum.MinimapTrackingFilter.TaxiNode] = true,
    [Enum.MinimapTrackingFilter.Innkeeper] = true,
    [Enum.MinimapTrackingFilter.ItemUpgrade] = true,
    [Enum.MinimapTrackingFilter.Battlemaster] = true,
    [Enum.MinimapTrackingFilter.Stablemaster] = true,
};

local CONDITIONAL_FILTERS = {
    [Enum.MinimapTrackingFilter.Target] = true,
    [Enum.MinimapTrackingFilter.Digsites] = true,
    [Enum.MinimapTrackingFilter.Repair] = true,
};

local OPTIONAL_FILTERS = {
    [Enum.MinimapTrackingFilter.Banker] = true,
    [Enum.MinimapTrackingFilter.Auctioneer] = true,
    [Enum.MinimapTrackingFilter.Barber] = true,
    [Enum.MinimapTrackingFilter.TrainerProfession] = true,
    [Enum.MinimapTrackingFilter.AccountCompletedQuests] = true,
    [Enum.MinimapTrackingFilter.TrivialQuests] = true,
    [Enum.MinimapTrackingFilter.Transmogrifier] = true,
    [Enum.MinimapTrackingFilter.Mailbox] = true,
};

local LOW_PRIORITY_TRACKING_SPELLS = {
    [261764] = true; -- Track Warboards
};

local TRACKING_SPELL_OVERRIDE_TEXTURES = {
    [43308] = "professions_tracking_fish";-- Find Fish
    [2580] = "professions_tracking_ore"; -- Find Minerals 1
    [8388] = "professions_tracking_ore"; -- Find Minerals 2
    [2383] = "professions_tracking_herb"; -- Find Herbs 1
    [8387] = "professions_tracking_herb"; -- Find Herbs 2
};

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
    GameTooltip:AddLine(L["Map Coordinates"])
    GameTooltip:AddLine(L["Left Click to toggle higher precision coordinates."], 1, 1, 1, true)
    GameTooltip:SetMinimumWidth(100)
    GameTooltip:Show()
end
GW.AddForProfiling("map", "MapCoordsMiniMap_OnEnter", MapCoordsMiniMap_OnEnter)

local function mapCoordsMiniMap_setCoords(self)
    local x, y, xT, yT = GW.Libs.GW2Lib:GetPlayerLocationCoords()
    if x and y then
        self.Coords:SetText(RoundDec(xT, self.MapCoordsMiniMapPrecision) .. ", " .. RoundDec(yT, self.MapCoordsMiniMapPrecision))
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

        GW.settings.MINIMAP_COORDS_PRECISION = self.MapCoordsMiniMapPrecision
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
    local expButton = ExpansionLandingPageMinimapButton or GarrisonLandingPageMinimapButton
    QueueStatusButton:ClearAllPoints()
    GameTimeFrame:ClearAllPoints()
    expButton:ClearAllPoints()
    GwAddonToggle:ClearAllPoints()
    GwAddonToggle.container:ClearAllPoints()
    AddonCompartmentFrame:ClearAllPoints()

    if side == "left" then
        GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -5, -2)
        AddonCompartmentFrame:SetPoint("TOP", GameTimeFrame, "BOTTOM", 1, 0)
        GwAddonToggle:SetPoint("TOP", GameTimeFrame, "BOTTOM", -3, -20) -- also attached to the gametime because the compartment be be hidden
        GwAddonToggle.container:SetPoint("RIGHT", GwAddonToggle, "LEFT")
        expButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", 0, -3)

        --flip GwAddonToggle icon

        GwAddonToggle:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        GwAddonToggle:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
        GwAddonToggle:GetPushedTexture():SetTexCoord(0, 1, 0, 1)

        QueueStatusButton:SetPoint("TOP", GwAddonToggle, "BOTTOM", 4, 0)
    else
        GameTimeFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 5, -2)
        AddonCompartmentFrame:SetPoint("TOP", GameTimeFrame, "BOTTOM", -1, 0)
        GwAddonToggle:SetPoint("TOP", GameTimeFrame, "BOTTOM", 3, -20)
        GwAddonToggle.container:SetPoint("LEFT", GwAddonToggle, "RIGHT")
        expButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMRIGHT", 2, -3)

        --flip GwAddonToggle icon

        GwAddonToggle:GetNormalTexture():SetTexCoord(1, 0, 0, 1)
        GwAddonToggle:GetHighlightTexture():SetTexCoord(1, 0, 0, 1)
        GwAddonToggle:GetPushedTexture():SetTexCoord(1, 0, 0, 1)

        QueueStatusButton:SetPoint("TOP", GwAddonToggle, "BOTTOM", -4, 0)
    end

    QueueStatusButton:SetParent(UIParent)
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

local function ToogleMinimapCoorsLable()
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
GW.ToogleMinimapCoorsLable = ToogleMinimapCoorsLable

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

local function CreatePredictedTrackingState()
    local tbl = {};
    local state = {};

    tbl.SetSelected = function(self, index, selected)
        state[index] = selected;

        MinimapUtil.SetTrackingFilterByFilterIndex(index, selected); -- 11.0.2
    end

    -- Some filters (like trivial quest tracking) can be changed from other places in the UI (like the Options panel or the World Map)
    -- If a filter is changed from an external system, then all we need to do is update the predicted state
    tbl.OverrideSelectedState = function(self, index, selected)
        state[index] = selected;
    end

    tbl.IsSelected = function(self, index)
        return state[index] == true;
    end

    tbl.ClearSelections = function(self)
        state = {};

        C_Minimap.ClearAllTracking();
    end

    tbl.Enumerate = function(self)
        return ipairs(state);
    end

    return tbl;
end

local trackingState = CreatePredictedTrackingState()

local function CanDisplayTrackingInfo(index)
    local filter = C_Minimap.GetTrackingFilter(index);
    if not filter then
        return false;
    end

    return OPTIONAL_FILTERS[filter.filterID] or filter.spellID;
end

local function ToggleTrackingSelected(info)
    local selected = trackingState:IsSelected(info.index);
    local newSelected = not selected;
    trackingState:SetSelected(info.index, newSelected);
end

local function IsTrackingActive(info)
    return trackingState:IsSelected(info.index);
end

local function SetupMiniMapTrackingDropdown(self)
    MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
        local showAll = GetCVarBool("minimapTrackingShowAll")
        local isHunterClass = GW.myclass == "HUNTER"

        if not showAll then
            rootDescription:CreateButton(UNCHECK_ALL, function()
                trackingState:ClearSelections();

                for index = 1, C_Minimap.GetNumTrackingTypes() do
                    local filter = C_Minimap.GetTrackingFilter(index);
                    if ALWAYS_ON_FILTERS[filter.filterID] or CONDITIONAL_FILTERS[filter.filterID] then
                        trackingState:SetSelected(index, true);
                    end
                end

                return MenuResponse.Refresh;
            end);
        end

        local hunterInfo = {};
        local townfolkInfo = {};
        local regularInfo = {};

        for index = 1, C_Minimap.GetNumTrackingTypes() do
            if showAll or CanDisplayTrackingInfo(index) then
                local trackingInfo = C_Minimap.GetTrackingInfo(index);
                trackingInfo.index = index;

                if isHunterClass and (trackingInfo.subType == HUNTER_TRACKING) then
                    table.insert(hunterInfo, trackingInfo);
                elseif trackingInfo.subType == TOWNSFOLK_TRACKING then
                    table.insert(townfolkInfo, trackingInfo);
                else
                    table.insert(regularInfo, trackingInfo);
                end
            end
        end

        TableUtil.Execute({hunterInfo, townfolkInfo, regularInfo}, function(trackingInfo)
            table.sort(trackingInfo, function(a, b)
                -- Sort low priority tracking spells to the end
                local filterA = C_Minimap.GetTrackingFilter(a.index);
                local filterB = C_Minimap.GetTrackingFilter(b.index);
                local lowPriorityA = LOW_PRIORITY_TRACKING_SPELLS[filterA.spellID] or false;
                local lowPriorityB = LOW_PRIORITY_TRACKING_SPELLS[filterB.spellID] or false;
                if lowPriorityA ~= lowPriorityB then
                    return not lowPriorityA;
                end
                return a.index < b.index;
            end);
        end);

        local function CreateCheckboxWithIcon(parentDescription, trackingInfo)
            local name = trackingInfo.name;
            trackingInfo.text = name;

            local texture = TRACKING_SPELL_OVERRIDE_TEXTURES[trackingInfo.spellID] or trackingInfo.texture;
            local desc = parentDescription:CreateCheckbox(
                name,
                IsTrackingActive,
                ToggleTrackingSelected,
                trackingInfo);

            desc:AddInitializer(function(button, description, menu)
                local rightTexture = button:AttachTexture();
                rightTexture:SetSize(20, 20);
                rightTexture:SetPoint("RIGHT");
                rightTexture:SetTexture(texture);

                local fontString = button.fontString;
                fontString:SetPoint("RIGHT", rightTexture, "LEFT");

                if trackingInfo.type == "spell" then
                    local uv0, uv1 = .0625, .9;
                    rightTexture:SetTexCoord(uv0, uv1, uv0, uv1);
                end

                -- The size is explicitly provided because this requires a right-justified icon.
                local width, height = fontString:GetUnboundedStringWidth() + 60, 20;
                return width, height;
            end);

            return desc;
        end

        local hunterCount = #hunterInfo;
        if hunterCount > 0 then
            if hunterCount > 1 then
                local hunterMenuDesc = rootDescription:CreateButton(HUNTER_TRACKING_TEXT);
                for index, info in ipairs(hunterInfo) do
                    CreateCheckboxWithIcon(hunterMenuDesc, info);
                end
            else
                CreateCheckboxWithIcon(rootDescription);
            end
        end
        if #townfolkInfo > 0 then
            local townfolkMenuDesc = rootDescription;
            if showAll then
                townfolkMenuDesc = rootDescription:CreateButton(TOWNSFOLK_TRACKING_TEXT);
            end

            for index, info in ipairs(townfolkInfo) do
                CreateCheckboxWithIcon(townfolkMenuDesc, info);
            end
        end

        for index, info in ipairs(regularInfo) do
            CreateCheckboxWithIcon(rootDescription, info);
        end
    end)
end

local function Minimap_OnMouseDown(self, btn)
    if btn == "RightButton" then
        SetupMiniMapTrackingDropdown(self)
    else
        Minimap.OnClick(self)
    end
end

local function MapCanvas_OnMouseDown(self, btn)--TODO

    if btn == "RightButton" then
        SetupMiniMapTrackingDropdown(self)
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
    GwMapGradient.location:SetText(string.utf8sub(GetMinimapZoneText(), 1, 46))
    GwMapGradient.location:SetTextColor(GetLocTextColor())
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

    if garrison.garrisonMode then
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
        garrison:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up")
        garrison:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down")
        garrison:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-down")
        garrison.LoopingGlow:SetTexture("Interface/AddOns/GW2_UI/textures/icons/garrison-up")
    else
        local minimapDisplayInfo = ExpansionLandingPage:GetOverlayMinimapDisplayInfo();
        if minimapDisplayInfo then
            garrison.title = minimapDisplayInfo.title;
            garrison.description = minimapDisplayInfo.description;
        end
        local expansionLandingPageType = ExpansionLandingPage:GetLandingPageType()
        if expansionLandingPageType == Enum.ExpansionLandingPageType.Dragonflight then
            garrison:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon")
            garrison:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon")
            garrison:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon")
            garrison.LoopingGlow:SetTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-dragon")
        elseif expansionLandingPageType == Enum.ExpansionLandingPageType.WarWithin then
            garrison:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-tww")
            garrison:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-tww-active")
            garrison:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-tww-active")
            garrison.LoopingGlow:SetTexture("Interface/AddOns/GW2_UI/textures/icons/landingpage-tww-active")
        end
    end
end

local function SetupHybridMinimap()
    local MapCanvas = HybridMinimap.MapCanvas
    --MapCanvas:SetMaskTexture(E.Media.Textures.White8x8)
    MapCanvas:SetScript("OnMouseWheel", Minimap_OnMouseWheel)
    MapCanvas:SetScript("OnMouseDown", MapCanvas_OnMouseDown)
    MapCanvas:SetScript("OnMouseUp", GW.NoOp)

    _G.HybridMinimap.CircleMask:GwStripTextures()
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
            AddonCompartmentFrame.Text:SetFont(UNIT_NAME_FONT, 12, "NONE")
            AddonCompartmentFrame:SetSize(18, 18)
            AddonCompartmentFrame.gw2Handled = true
        end

        if GW.settings.MINIMAP_ADDON_COMPARTMENT_TOGGLE then
            AddonCompartmentFrame:SetParent(UIParent)
        else
            AddonCompartmentFrame:SetParent(GW.HiddenFrame)
        end
    end
end
GW.HandleAddonCompartmentButton = HandleAddonCompartmentButton

local function LoadMinimap()
    -- https://wowwiki.wikia.com/wiki/USERAPI_GetMinimapShape
    GetMinimapShape = GetMinimapShape

    Minimap:SetMaskTexture(130937)
    Minimap:SetScale(1.2)

    local size = GW.settings.MINIMAP_SCALE
    Minimap:SetSize(size, size)

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

    local GwMinimapShadow = CreateFrame("Frame", "GwMinimapShadow", Minimap, "GwMinimapShadow")
    local GwMapGradient = CreateFrame("Frame", "GwMapGradient", GwMinimapShadow, "GwMapGradient")
    GwMapGradient:SetParent(GwMinimapShadow)
    GwMapGradient:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    GwMapGradient:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)

    if Minimap.backdrop then -- level to hybrid maps fixed values
        Minimap.backdrop:SetFrameLevel(99)
        Minimap.backdrop:SetFrameStrata("BACKGROUND")
        Minimap.backdrop:SetIgnoreParentScale(true)
        Minimap.backdrop:SetScale(1)
    end

    Minimap:SetScript("OnMouseWheel", Minimap_OnMouseWheel)
    Minimap:SetScript("OnMouseDown", Minimap_OnMouseDown)
    Minimap:SetScript("OnMouseUp", GW.NoOp)

    Minimap:HookScript("OnEnter", hoverMiniMapIn)
    Minimap:HookScript("OnLeave", hoverMiniMapOut)

    Minimap:HookScript("OnShow", minimap_OnShow)
    Minimap:HookScript("OnHide", minimap_OnHide)

    MinimapCluster.ZoneTextButton:GwKill()
    TimeManagerClockButton:GwKill()
    MinimapCluster.Tracking.Button:SetParent(GW.HiddenFrame)

    GwMapGradient.location = GwMapGradient:CreateFontString(nil, "OVERLAY", "GW_Standard_Button_Font_Small", 7)
    GwMapGradient.location:SetPoint("TOP", Minimap, "TOP", 0, -2)
    GwMapGradient.location:SetJustifyH("CENTER")
    GwMapGradient.location:SetJustifyV("MIDDLE")
    GwMapGradient.location:SetIgnoreParentScale(true)
    GwMapGradient.location:SetScale(1)

    local killFrames = {
        MinimapBorder,
        MinimapBorderTop,
        MinimapZoomIn,
        MinimapZoomOut,
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

    --Time
    GwMapTime = CreateFrame("Button", "GwMapTime", Minimap, "GwMapTime")
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
    GwMapCoords = CreateFrame("Button", "GwMapCoords", Minimap, "GwMapCoords")
    GwMapCoords.Coords:SetText(NOT_APPLICABLE)
    GwMapCoords.Coords:SetFont(STANDARD_TEXT_FONT, 12, "")
    GwMapCoords.MapCoordsMiniMapPrecision = GW.settings.MINIMAP_COORDS_PRECISION
    ToogleMinimapCoorsLable()

    --FPS
    GwMapFPS = CreateFrame("Button", "GwMapFPS", Minimap, "GwMapFPS")
    GwMapFPS.fps:SetText(NOT_APPLICABLE)
    GwMapFPS.fps:SetFont(STANDARD_TEXT_FONT, 12)
    ToogleMinimapFpsLable()

    --CalenderIcon
    GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
    GameTimeFrame:SetSize(32, 32)

    hooksecurefunc("GameTimeFrame_SetDate", function()
        GameTimeFrame:GwStripTextures()
        GameTimeFrame:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/calendar")
        GameTimeFrame:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/calendar")
        GameTimeFrame:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/calendar")
        GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        GameTimeFrame:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
        GameTimeFrame:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
    end)

    -- Addon Icons
    GW.CreateMinimapButtonsSack()

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

    Minimap:SetPlayerTexture("Interface/AddOns/GW2_UI/textures/icons/player_arrow")

    hideMiniMapIcons()

    SetMinimapHover()
    C_Timer.After(0.2, hoverMiniMapOut)

    GW.SkinMinimapInstanceDifficult()

    QueueStatusButton:SetSize(26, 26)
    QueueStatusButtonIcon:GwKill()
    QueueStatusButtonIcon.texture:SetTexture(nil)
    QueueStatusButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton")
    QueueStatusButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
    QueueStatusButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
    local GwLfgQueueIcon = CreateFrame("Frame", "GwLfgQueueIcon", QueueStatusButton, "GwLfgQueueIcon")
    GwLfgQueueIcon:SetPoint("CENTER", QueueStatusButton, "CENTER", 0, 0)
    hooksecurefunc(QueueStatusButtonIcon, "PlayAnim", function()
        if not Minimap:IsShown() then return end
        QueueStatusButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/LFGAnimation-1")
        QueueStatusButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/LFGAnimation-1-Highlight")
        QueueStatusButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/LFGAnimation-1-Highlight")
        GwLfgQueueIcon.animation:Play()
    end)
    hooksecurefunc(QueueStatusButtonIcon, "StopAnimating", function()
        GwLfgQueueIcon.animation:Stop()
        QueueStatusButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton")
        QueueStatusButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
        QueueStatusButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/LFGMinimapButton-Highlight")
    end)
end
GW.LoadMinimap = LoadMinimap
