---@class GW2
local GW = select(2, ...)

local RING_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/gcd-ring.png"
local EXPLORATION_CATEGORY = 97
local CRITERIA_TYPE_EXPLORE_AREA = 43
local MAX_TOOLTIP_AREAS = 12

-- era and tbc have no achievements: there the uncovered map overlays count, against the number each
-- zone has (WorldMapOverlay per uiMap, tbc anniversary; era has two less in Dustwallow Marsh and Silithus)
local OVERLAY_COUNTS = (GW.Classic or GW.TBC) and {
    [1411] = 11, [1412] = 14, [1413] = 25, [1416] = 15, [1417] = 16, [1418] = 14, [1419] = 9, [1420] = 16,
    [1421] = 15, [1422] = 13, [1423] = 22, [1424] = 12, [1425] = 14, [1426] = 18, [1427] = 7, [1428] = 10,
    [1429] = 12, [1430] = 3, [1431] = 13, [1432] = 11, [1433] = 11, [1434] = 27, [1435] = 11, [1436] = 14,
    [1437] = 15, [1438] = 11, [1439] = 9, [1440] = 18, [1441] = 9, [1442] = 11, [1443] = 15, [1444] = 16,
    [1445] = GW.Classic and 7 or 9, [1446] = 20, [1447] = 19, [1448] = 12, [1449] = 7, [1450] = 1,
    [1451] = GW.Classic and 7 or 9, [1452] = 13,
    [1941] = 28, [1942] = 18, [1943] = 22, [1944] = 25, [1946] = 25, [1948] = 24, [1949] = 30, [1950] = 28,
    [1951] = 20, [1952] = 37, [1953] = 24, [1957] = 7,
}

local provider
local explorationAchievements
local zoneAchievement = {}

local function IsInCategory(categoryID, rootID)
    while categoryID and categoryID > 0 do
        if categoryID == rootID then
            return true
        end
        categoryID = select(2, GetCategoryInfo(categoryID))
    end
    return false
end

-- the "explore <zone>" achievements, the treasure and rare ones of the same category have other criteria
local function CollectExplorationAchievements()
    explorationAchievements = {}
    for _, categoryID in ipairs(GetCategoryList()) do
        if IsInCategory(categoryID, EXPLORATION_CATEGORY) then
            local categoryName = GetCategoryInfo(categoryID)
            for i = 1, GetCategoryNumAchievements(categoryID, true) do
                local id, name = GetAchievementInfo(categoryID, i)
                if id and GetAchievementNumCriteria(id) > 0 and select(2, GetAchievementCriteriaInfo(id, 1)) == CRITERIA_TYPE_EXPLORE_AREA then
                    tinsert(explorationAchievements, {id = id, name = strlower(name), categoryName = categoryName})
                end
            end
        end
    end
end

-- the achievement carries the zone name; Nagrand and Shadowmoon Valley exist twice, there the
-- category named like the continent decides, otherwise the newest achievement
local function GetZoneAchievement(zoneID, continentName)
    if zoneAchievement[zoneID] == nil then
        if not explorationAchievements then
            CollectExplorationAchievements()
        end

        local zoneName = strlower(C_Map.GetMapInfo(zoneID).name)
        local best
        for _, achievement in ipairs(explorationAchievements) do
            if achievement.name:find(zoneName, 1, true) then
                if achievement.categoryName == continentName then
                    best = achievement
                    break
                elseif not best or achievement.id > best.id then
                    best = achievement
                end
            end
        end
        zoneAchievement[zoneID] = best and best.id or false
    end
    return zoneAchievement[zoneID]
end

local function GetExplored(achievementID)
    local numCriteria = GetAchievementNumCriteria(achievementID)
    local explored = 0
    for i = 1, numCriteria do
        if select(3, GetAchievementCriteriaInfo(achievementID, i)) then
            explored = explored + 1
        end
    end
    return explored, numCriteria
end

local function GetZoneProgress(zoneID, continentName)
    if OVERLAY_COUNTS then
        local total = OVERLAY_COUNTS[zoneID]
        if total then
            return math.min(#C_MapExplorationInfo.GetExploredMapTextures(zoneID), total), total
        end
        return
    end

    local achievementID = GetZoneAchievement(zoneID, continentName)
    if achievementID then
        local explored, total = GetExplored(achievementID)
        return explored, total, achievementID
    end
end

local pinMixin = {}

function pinMixin:OnLoad()
    self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
    self:SetScalingLimits(1, 1, 1.2)

    self.bg = self:CreateTexture(nil, "BACKGROUND")
    self.bg:SetPoint("TOPLEFT", 3, -3)
    self.bg:SetPoint("BOTTOMRIGHT", -3, 3)
    self.bg:SetColorTexture(GW.Colors.SkinColors.MapBadge:GetRGBA())
    self.mask = self:CreateMaskTexture()
    self.mask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    self.mask:SetAllPoints(self.bg)
    self.bg:AddMaskTexture(self.mask)

    self.track = self:CreateTexture(nil, "BORDER")
    self.track:SetAllPoints()
    self.track:SetTexture(RING_TEXTURE)
    self.track:SetVertexColor(GW.Colors.SkinColors.StatusBarTrack:GetRGBA())

    self.ring = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
    self.ring:SetAllPoints()
    self.ring:SetSwipeTexture(RING_TEXTURE, GW.Colors.SkinColors.QuestGold:GetRGBA())
    self.ring:SetUseCircularEdge(true)
    self.ring:SetDrawEdge(false)
    self.ring:SetDrawBling(false)
    self.ring:SetHideCountdownNumbers(true)

    self.text = self:CreateFontString(nil, "OVERLAY")
    self.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
    self.text:SetPoint("CENTER", self.ring)
end

function pinMixin:OnAcquired(zoneID, achievementID, explored, total, x, y)
    self.zoneID = zoneID
    self.achievementID = achievementID
    self.explored, self.total = explored, total
    self:SetPosition(x, y)

    local progress = explored / total
    self.text:SetText(math.floor(progress * 100) .. "%")
    -- the swipe draws what is left of a cooldown, so the remaining time is the explored part
    self.ring:SetCooldown(GetTime() - (1 - progress) * 100, 100)
    self.ring:Pause()
end

function pinMixin:OnMouseEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(C_Map.GetMapInfo(self.zoneID).name, GW.Colors.SkinColors.QuestGold:GetRGB())
    if self.achievementID then
        GameTooltip:AddDoubleLine(select(2, GetAchievementInfo(self.achievementID)), self.explored .. "/" .. self.total, 1, 1, 1, 1, 1, 1)
        local shown = 0
        for i = 1, self.total do
            local name, _, completed = GetAchievementCriteriaInfo(self.achievementID, i)
            if not completed then
                shown = shown + 1
                if shown > MAX_TOOLTIP_AREAS then
                    GameTooltip:AddLine("...", GW.Colors.SkinColors.Disabled:GetRGB())
                    break
                end
                GameTooltip:AddLine(name, GW.Colors.SkinColors.Disabled:GetRGB())
            end
        end
    else
        GameTooltip:AddDoubleLine(GW.L["Explored Areas"], self.explored .. "/" .. self.total, 1, 1, 1, 1, 1, 1)
    end
    GameTooltip:Show()
end

function pinMixin:OnMouseLeave()
    GameTooltip:Hide()
end

function pinMixin:OnClick(button)
    if button == "LeftButton" then
        self:GetMap():SetMapID(self.zoneID)
    else
        self:GetMap():NavigateToParentMap()
    end
end

local providerMixin = {}

function providerMixin:RemoveAllData()
    self:GetMap():RemoveAllPinsByTemplate("GwExplorationPinTemplate")
end

function providerMixin:RefreshAllData()
    self:RemoveAllData()
    if not GW.settings.worldmap.explorationProgress then return end

    local map = self:GetMap()
    local mapID = map:GetMapID()
    local mapInfo = mapID and C_Map.GetMapInfo(mapID)
    if not mapInfo or mapInfo.mapType ~= Enum.UIMapType.Continent then return end

    for _, zone in ipairs(C_Map.GetMapChildrenInfo(mapID, Enum.UIMapType.Zone) or {}) do
        local explored, total, achievementID = GetZoneProgress(zone.mapID, mapInfo.name)
        if explored and explored < total then
            local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(zone.mapID, mapID)
            if minX then
                map:AcquirePin("GwExplorationPinTemplate", zone.mapID, achievementID, explored, total, (minX + maxX) / 2, (minY + maxY) / 2)
            end
        end
    end
end

function GW.UpdateExplorationMapPins()
    if not provider then
        if not GW.settings.worldmap.explorationProgress then return end
        -- the map canvas mixins exist once the world map is loaded, not yet when this file runs
        GwExplorationPinMixin = CreateFromMixins(MapCanvasPinMixin, pinMixin)
        provider = CreateFromMixins(MapCanvasDataProviderMixin, providerMixin)
        WorldMapFrame:AddDataProvider(provider)
    end
    provider:RefreshAllData()
end
