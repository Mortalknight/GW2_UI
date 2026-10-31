---@class GW2
local GW = select(2, ...)

local MAX_POINTS = 200
local MIN_DISTANCE = 0.004 -- of the map size, so the dots keep a gap on every zone
local RECORD_INTERVAL = 1

local trails = {} -- per map, only for this session
local provider
local ticker

local pinMixin = {}

function pinMixin:OnLoad()
    self:UseFrameLevelType("PIN_FRAME_LEVEL_DIG_SITE")
    self:SetScalingLimits(1, 1, 1)
    self.dot = self:CreateTexture(nil, "ARTWORK")
    self.dot:SetAllPoints()
    self.dot:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMask")
end

-- the older a dot, the paler
function pinMixin:OnAcquired(x, y, age)
    self:SetPosition(x, y)
    self.dot:SetVertexColor(GW.Colors.FallbackWhite.r, GW.Colors.FallbackWhite.g, GW.Colors.FallbackWhite.b, 0.15 + 0.85 * age)
end

local providerMixin = {}

function providerMixin:RemoveAllData()
    self:GetMap():RemoveAllPinsByTemplate("GwMapTrailPinTemplate")
end

function providerMixin:RefreshAllData()
    self:RemoveAllData()
    local map = self:GetMap()
    local trail = GW.settings.worldmap.trail and trails[map:GetMapID()]
    if not trail then return end

    for i, point in ipairs(trail) do
        map:AcquirePin("GwMapTrailPinTemplate", point[1], point[2], i / #trail)
    end
end

-- in instances blizzard gives no position, there is no trail
local function RecordPosition()
    local mapID = C_Map.GetBestMapForUnit("player")
    local position = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    if not position then return end

    local x, y = position:GetXY()
    local trail = trails[mapID]
    if not trail then
        trail = {}
        trails[mapID] = trail
    end
    local last = trail[#trail]
    if last and math.abs(last[1] - x) < MIN_DISTANCE and math.abs(last[2] - y) < MIN_DISTANCE then return end

    tinsert(trail, {x, y})
    if #trail > MAX_POINTS then
        tremove(trail, 1)
    end
    if WorldMapFrame:IsShown() and WorldMapFrame:GetMapID() == mapID then
        provider:RefreshAllData()
    end
end

function GW.UpdateMapTrail()
    local enabled = GW.settings.worldmap.trail
    if not provider then
        if not enabled then return end
        -- the map canvas mixins exist once the world map is loaded, not yet when this file runs
        GwMapTrailPinMixin = CreateFromMixins(MapCanvasPinMixin, pinMixin)
        provider = CreateFromMixins(MapCanvasDataProviderMixin, providerMixin)
        WorldMapFrame:AddDataProvider(provider)
    end

    if enabled and not ticker then
        ticker = C_Timer.NewTicker(RECORD_INTERVAL, RecordPosition)
    elseif not enabled and ticker then
        ticker:Cancel()
        ticker = nil
    end
    provider:RefreshAllData()
end
