---@class GW2
local GW = select(2, ...)

local RING_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/gcd-ring.png"
local EXPLORATION_CATEGORY = 97
local PVP_CATEGORY = 95
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

local PANEL_WIDTH = 230
local ROW_GAP = 8

local provider
local panel
local explorationAchievements
local zoneAchievement = {}
local kafZoneAchievements

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
            local explored = C_MapExplorationInfo.GetExploredMapTextures(zoneID)
            return math.min(explored and #explored or 0, total), total
        end
        return
    end

    local achievementID = GetZoneAchievement(zoneID, continentName)
    if achievementID then
        local explored, total = GetExplored(achievementID)
        return explored, total, achievementID
    end
end

-- Krowi's Achievement Filter keeps its zone lists in KrowiAF.ZoneData: groups of {AddZoneData, mapIDs, achievementIDs};
-- it is the table KAF fills itself from, read here only when the addon is there
local function CollectKafZoneAchievements()
    kafZoneAchievements = {}
    if not (KrowiAF and type(KrowiAF.ZoneData) == "table" and KrowiAF.AddZoneData) then return end

    local function AddIDs(list, ids)
        for _, id in ipairs(ids) do
            if type(id) == "table" then
                AddIDs(list, id)
            elseif type(id) == "number" then
                list[#list + 1] = id
            end
        end
    end
    for _, group in pairs(KrowiAF.ZoneData) do
        for _, entry in ipairs(group) do
            if type(entry) == "table" and entry[1] == KrowiAF.AddZoneData and type(entry[3]) == "table" then
                local mapIDs = type(entry[2]) == "table" and entry[2] or {entry[2]}
                for _, mapID in ipairs(mapIDs) do
                    kafZoneAchievements[mapID] = kafZoneAchievements[mapID] or {}
                    AddIDs(kafZoneAchievements[mapID], entry[3])
                end
            end
        end
    end
end

local function IsPvPAchievement(id)
    return GetAchievementCategory and IsInCategory(GetAchievementCategory(id), PVP_CATEGORY)
end

-- earned and all achievements of a zone after KAF, the missing ones for the tooltip
local function GetZoneAchievements(zoneID)
    if not kafZoneAchievements then
        CollectKafZoneAchievements()
    end
    local ids = kafZoneAchievements[zoneID]
    if not ids then return end

    local includePvP = GW.settings.worldmap.explorationAchievementsPvP
    local earned, total, missing = 0, 0, {}
    for _, id in ipairs(ids) do
        local _, name, _, completed = GetAchievementInfo(id)
        if name and (includePvP or not IsPvPAchievement(id)) then
            total = total + 1
            if completed then
                earned = earned + 1
            else
                missing[#missing + 1] = name
            end
        end
    end
    if total > 0 then
        return earned, total, missing
    end
end

-- KAF's own world map button opens its "selected zone" category with its filters; ours just clicks it
local function OpenKafZoneCategory()
    local buttons = LibStub and LibStub("Krowi_WorldMapButtons-1.4", true)
    for _, button in ipairs(buttons and buttons.Buttons or {}) do
        if KrowiAF_WorldMapButtonMixin and button.OnClick == KrowiAF_WorldMapButtonMixin.OnClick then
            button:Refresh()
            button:Click()
            return
        end
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
    self.ring:SetSwipeTexture(RING_TEXTURE, GW.Colors.Accent:GetRGBA())
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
    -- hidden until the mouse is over its zone, so the icons under it stay usable
    self:Hide()
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

---------- the completion panel on the world map ----------

local LINE_HEIGHT = 14
local ICON_EXPLORATION = "Interface/AddOns/GW2_UI/textures/icons/questlogmicrobutton-up.png"
local ICON_ACHIEVEMENTS = "Interface/AddOns/GW2_UI/textures/icons/achievementmicrobutton-up.png"

-- a small icon, the label and the value on the right
local function CreateLine(row, index)
    local line = CreateFrame("Frame", nil, row)
    line:SetHeight(LINE_HEIGHT)
    line:SetPoint("TOPLEFT", 32, -18 - (index - 1) * LINE_HEIGHT)
    line:SetPoint("TOPRIGHT", -4, -18 - (index - 1) * LINE_HEIGHT)

    line.icon = line:CreateTexture(nil, "ARTWORK")
    line.icon:SetSize(12, 12)
    line.icon:SetPoint("LEFT")

    line.value = line:CreateFontString(nil, "OVERLAY")
    line.value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
    line.value:SetPoint("RIGHT")

    line.label = line:CreateFontString(nil, "OVERLAY")
    line.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
    line.label:SetTextColor(GW.Colors.SkinColors.SubText:GetRGB())
    line.label:SetPoint("LEFT", line.icon, "RIGHT", 4, 0)
    line.label:SetPoint("RIGHT", line.value, "LEFT", -4, 0)
    line.label:SetJustifyH("LEFT")
    line.label:SetWordWrap(false)

    return line
end

-- the zone and its continent, in the look of the event tracker rows and in the accent color of the client
local function CreateRow(parent, icon)
    local row = CreateFrame("Frame", nil, parent)
    row:SetWidth(PANEL_WIDTH)

    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
    row.background:SetAllPoints()

    row.shine = row:CreateTexture(nil, "BORDER")
    row.shine:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    row.shine:SetAllPoints()
    row.shine:SetVertexColor(GW.Colors.Accent.r, GW.Colors.Accent.g, GW.Colors.Accent.b, 0.15)

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetTexture(icon)
    row.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    row.icon:SetSize(24, 24)
    row.icon:SetPoint("TOPLEFT", 3, -6)
    row.iconBorder = row:CreateTexture(nil, "OVERLAY")
    row.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    row.iconBorder:SetAllPoints(row.icon)

    row.percent = row:CreateFontString(nil, "OVERLAY")
    row.percent:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
    row.percent:SetTextColor(GW.Colors.FallbackWhite:GetRGB())

    row.name = row:CreateFontString(nil, "OVERLAY")
    row.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
    row.name:SetPoint("TOPLEFT", 32, -4)
    row.name:SetPoint("TOPRIGHT", row.percent, "TOPLEFT", -4, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)

    row.lines = {CreateLine(row, 1), CreateLine(row, 2)}

    row.bar = CreateFrame("StatusBar", nil, row)
    row.bar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    row.bar:SetStatusBarColor(GW.Colors.Accent:GetRGB())
    row.bar:SetPoint("BOTTOMLEFT", 32, 4)
    row.bar:SetPoint("BOTTOMRIGHT", -4, 4)
    row.bar:SetHeight(2)
    row.bar.bg = row.bar:CreateTexture(nil, "BACKGROUND")
    row.bar.bg:SetAllPoints()
    row.bar.bg:SetColorTexture(GW.Colors.SkinColors.StatusBarTrack:GetRGBA())

    row.separator = parent:CreateTexture(nil, "ARTWORK")
    row.separator:SetHeight(1)
    row.separator:SetColorTexture(GW.Colors.SkinColors.HeaderBorder:GetRGBA())

    return row
end

-- lines: {icon, label, value} each, the row grows with them
local function SetRow(row, title, explored, total, lines)
    row.name:SetText(title)
    row.percent:SetText(math.floor(explored / total * 100) .. "%")
    row.bar:SetMinMaxValues(0, total)
    row.bar:SetValue(explored)
    for i, line in ipairs(row.lines) do
        local data = lines[i]
        line:SetShown(data ~= nil)
        if data then
            line.icon:SetTexture(data[1])
            line.label:SetText(data[2])
            line.value:SetText(data[3])
        end
    end
    row:SetHeight(28 + #lines * LINE_HEIGHT)
end

-- the rows with data from top to bottom; collapsed only the first one stays
local function LayoutPanel()
    local settings = GW.settings.worldmap
    local collapsed = settings.explorationPanelCollapsed
    local hasMore = panel.zone.hasData
    local shown = {}
    for _, row in ipairs({panel.zone, panel.continent}) do
        row:Hide()
        row.separator:Hide()
        if row.hasData and not (collapsed and #shown > 0) then
            shown[#shown + 1] = row
        end
    end

    local height, previous = 0, nil
    for _, row in ipairs(shown) do
        row:ClearAllPoints()
        if previous then
            row:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -ROW_GAP)
            row.separator:SetPoint("LEFT", previous, "BOTTOMLEFT", 0, -ROW_GAP / 2)
            row.separator:SetPoint("RIGHT", previous, "BOTTOMRIGHT", 0, -ROW_GAP / 2)
            row.separator:Show()
            height = height + ROW_GAP
        else
            row:SetPoint("TOPLEFT")
        end
        -- with the arrow every percent makes room for it, so they stay in one column
        row.percent:ClearAllPoints()
        row.percent:SetPoint("TOPRIGHT", hasMore and -20 or -4, -4)
        row:Show()
        height = height + row:GetHeight()
        previous = row
    end
    panel:SetHeight(height)

    panel.toggle:SetShown(hasMore)
    panel.toggle:ClearAllPoints()
    panel.toggle:SetPoint("TOPRIGHT", shown[1], "TOPRIGHT", -4, -4)
    panel.toggle:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/" .. (collapsed and "arrowdown_up" or "arrowup_up") .. ".png")

    -- other addons use the corners of the map too, so the corner and the distance from it are settings;
    -- the distance counts into the map from any corner
    local corner = settings.explorationPanelPosition
    panel:ClearAllPoints()
    panel:SetPoint(corner, WorldMapFrame.ScrollContainer, corner, corner:find("LEFT") and settings.explorationPanelOffsetX or -settings.explorationPanelOffsetX, corner:find("TOP") and -settings.explorationPanelOffsetY or settings.explorationPanelOffsetY)
end

local function CreatePanel()
    panel = CreateFrame("Frame", nil, WorldMapFrame)
    panel:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
    panel:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
    panel:SetWidth(PANEL_WIDTH)
    -- the row art fades out to the right, the event tracker has its dark bar under it, we our backdrop
    panel:GwCreateBackdrop(GW.BackdropTemplates.Default, true, 4, 4)

    panel.zone = CreateRow(panel, "Interface/Icons/INV_Misc_Map_01")
    panel.continent = CreateRow(panel, "Interface/Icons/INV_Misc_Map02")
    panel.continent.hasData = true

    -- the achievements line of the zone after KAF: the missing ones as tooltip, a click opens them in KAF
    local achievements = panel.zone.lines[2]
    achievements:EnableMouse(true)
    achievements:SetScript("OnEnter", function(self)
        if not self.missing then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(ACHIEVEMENTS, GW.Colors.SkinColors.QuestGold:GetRGB())
        for i, name in ipairs(self.missing) do
            if i > MAX_TOOLTIP_AREAS then
                GameTooltip:AddLine("...", GW.Colors.SkinColors.Disabled:GetRGB())
                break
            end
            GameTooltip:AddLine(name, GW.Colors.SkinColors.Disabled:GetRGB())
        end
        GameTooltip:Show()
    end)
    achievements:SetScript("OnLeave", GameTooltip_Hide)
    achievements:SetScript("OnMouseUp", function(self)
        if self.missing then
            OpenKafZoneCategory()
        end
    end)

    panel.toggle = CreateFrame("Button", nil, panel)
    panel.toggle:SetSize(14, 14)
    panel.toggle:SetFrameLevel(panel:GetFrameLevel() + 5)
    panel.toggle:SetScript("OnClick", function()
        GW.settings.worldmap.explorationPanelCollapsed = not GW.settings.worldmap.explorationPanelCollapsed
        LayoutPanel()
    end)
end

-- the shown zone and its continent; the zone row only on a zone map
local function UpdatePanel(mapInfo)
    local continent = mapInfo
    while continent and continent.mapType > Enum.UIMapType.Continent do
        continent = C_Map.GetMapInfo(continent.parentMapID)
    end
    if not continent or continent.mapType ~= Enum.UIMapType.Continent then
        if panel then panel:Hide() end
        return
    end

    local exploredSum, totalSum, zonesDone, zonesCount = 0, 0, 0, 0
    for _, zone in ipairs(C_Map.GetMapChildrenInfo(continent.mapID, Enum.UIMapType.Zone) or {}) do
        local explored, total = GetZoneProgress(zone.mapID, continent.name)
        if explored then
            exploredSum, totalSum, zonesCount = exploredSum + explored, totalSum + total, zonesCount + 1
            if explored >= total then
                zonesDone = zonesDone + 1
            end
        end
    end
    if totalSum == 0 then
        if panel then panel:Hide() end
        return
    end

    if not panel then
        CreatePanel()
    end

    local explored, total, earned, all, missing
    if mapInfo.mapType == Enum.UIMapType.Zone then
        explored, total = GetZoneProgress(mapInfo.mapID, continent.name)
        if explored and GetAchievementInfo then
            earned, all, missing = GetZoneAchievements(mapInfo.mapID)
        end
    end
    panel.zone.hasData = explored ~= nil
    panel.zone.lines[2].missing = missing
    if explored then
        local lines = {{ICON_EXPLORATION, GW.L["Explored Areas"], explored .. "/" .. total}}
        if earned then
            lines[2] = {ICON_ACHIEVEMENTS, ACHIEVEMENTS, earned .. "/" .. all}
        end
        -- like the completion of guild wars 2, every area and achievement counts the same
        SetRow(panel.zone, mapInfo.name, explored + (earned or 0), total + (all or 0), lines)
    end
    SetRow(panel.continent, continent.name, exploredSum, totalSum, {{ICON_EXPLORATION, GW.L["Zones Completed"], zonesDone .. "/" .. zonesCount}})

    LayoutPanel()
    panel:Show()
end

-- the zone under the mouse shows its ring; while the mouse is on that ring it stays, even where
-- the middle of an odd shaped zone lies in another one
local function UpdateHoveredZone(watcher)
    if watcher.shownPin and watcher.shownPin:IsShown() and watcher.shownPin:IsMouseOver() then return end

    local map = WorldMapFrame
    local zoneID
    if map.ScrollContainer:IsMouseOver() then
        local x, y = map:GetNormalizedCursorPosition()
        local info = x and C_Map.GetMapInfoAtPosition(map:GetMapID(), x, y)
        zoneID = info and info.mapID
    end
    if zoneID == watcher.zoneID then return end

    watcher.zoneID = zoneID
    watcher.shownPin = nil
    for pin in map:EnumeratePinsByTemplate("GwExplorationPinTemplate") do
        pin:SetShown(pin.zoneID == zoneID)
        if pin.zoneID == zoneID then
            watcher.shownPin = pin
        end
    end
end

local providerMixin = {}

function providerMixin:RemoveAllData()
    self:GetMap():RemoveAllPinsByTemplate("GwExplorationPinTemplate")
end

function providerMixin:RefreshAllData()
    self:RemoveAllData()
    if not GW.settings.worldmap.explorationProgress then
        if panel then panel:Hide() end
        self.watcher:SetScript("OnUpdate", nil)
        return
    end

    local map = self:GetMap()
    local mapID = map:GetMapID()
    local mapInfo = mapID and C_Map.GetMapInfo(mapID)
    UpdatePanel(mapInfo)
    self.watcher.zoneID, self.watcher.shownPin = nil, nil
    local isContinent = mapInfo and mapInfo.mapType == Enum.UIMapType.Continent
    self.watcher:SetScript("OnUpdate", isContinent and UpdateHoveredZone or nil)
    if not isContinent then return end

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
        -- a child of the map, so it only runs while the map is open
        provider.watcher = CreateFrame("Frame", nil, WorldMapFrame)
        WorldMapFrame:AddDataProvider(provider)
    end
    provider:RefreshAllData()
end
