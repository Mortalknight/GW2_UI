local _, GW = ...
local mapInfoWatcher = CreateFrame("Frame")
local coordsWatcher = CreateFrame("Frame")
local mapRects, tempVec2D = {}, CreateVector2D(0, 0)

local function GetPlayerMapPos(mapID)
    tempVec2D.x, tempVec2D.y = UnitPosition("player")
    if not tempVec2D.x then return end

    local mapRect = mapRects[mapID]
    if not mapRect then
        local _, pos1 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
        local _, pos2 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
        if not pos1 or not pos2 then return end

        mapRect = {pos1, pos2}
        mapRect[2]:Subtract(mapRect[1])
        mapRects[mapID] = mapRect
    end
    tempVec2D:Subtract(mapRect[1])

    return (tempVec2D.y / mapRect[2].y), (tempVec2D.x / mapRect[2].x)
end

local function CoordsUpdate()
    if GW.locationData.mapID then
        GW.locationData.x, GW.locationData.y = GetPlayerMapPos(GW.locationData.mapID)
    else
        GW.locationData.x, GW.locationData.y = nil, nil
    end

    if GW.locationData.x and GW.locationData.y then
        GW.locationData.xText = GW.RoundDec(100 * GW.locationData.x, 2)
        GW.locationData.yText = GW.RoundDec(100 * GW.locationData.y, 2)
    else
        GW.locationData.xText, GW.locationData.yText = nil, nil
    end
end

local function CoordsWatcherOnUpdate(self, elapsed)
    self.lastUpdate = (self.lastUpdate or 0) + elapsed
    if self.lastUpdate > 0.1 then
        CoordsUpdate()
        self.lastUpdate = 0
    end
end

local function CoordsWatcherStart()
    GW.locationData.coordsWatching = true
    GW.locationData.coordsFalling = nil
    coordsWatcher:SetScript("OnUpdate", CoordsWatcherOnUpdate)

    if GW.locationData.coordsStopTimer then
        GW.locationData.coordsStopTimer:Cancel()
        GW.locationData.coordsStopTimer = nil
    end

end

local function CoordsStopWatching()
    GW.locationData.coordsWatching = nil
    GW.locationData.coordsStopTimer = nil
    coordsWatcher:SetScript("OnUpdate", nil)
end

local function CoordsWatcherStop(event)
    if event == "CRITERIA_UPDATE" then
        if GW.locationData.coordsFalling then return end
        if (GetUnitSpeed("player") or 0) > 0 then return end
        GW.locationData.coordsFalling = nil
    elseif (event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_CONTROL_GAINED") and IsFalling() then
        GW.locationData.coordsFalling = true
        return
    end

    if not GW.locationData.coordsStopTimer then
        GW.locationData.coordsStopTimer = C_Timer.NewTimer(0.5, function() CoordsStopWatching() end)
    end
end

local function CoordsWatcherOnEvent(_, event)
    if GW.IsIn(event, "CRITERIA_UPDATE", "PLAYER_STOPPED_MOVING", "PLAYER_CONTROL_GAINED") then
        CoordsWatcherStop(event)
    elseif GW.IsIn(event, "PLAYER_STARTED_MOVING", "PLAYER_CONTROL_LOST") then
        CoordsWatcherStart()
    end
end

local function MapInfoUpdateMapId()
    GW.locationData.mapID = C_Map.GetBestMapForUnit("player")
    if not GW.locationData.mapID then
        C_Timer.After(0.1, function() MapInfoUpdateMapId() end)
    end
    GW.Debug("Update location data: mapID:", GW.locationData.mapID)
end

local function MapInfoWatcherOnEvent()
    MapInfoUpdateMapId()
    GW.locationData.instanceMapID = select(8, GetInstanceInfo())
    GW.locationData.ZoneText = GetRealZoneText() or UNKNOWN

    CoordsUpdate()

    GW.Debug("Update location data: Instance mapID:", GW.locationData.instanceMapID)
    GW.Debug("Update location data: Zonename:", GW.locationData.ZoneText)
end

local function InitLocationDataHandler()
    mapInfoWatcher:RegisterEvent("LOADING_SCREEN_DISABLED")
    mapInfoWatcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    mapInfoWatcher:RegisterEvent("ZONE_CHANGED")
    mapInfoWatcher:RegisterEvent("ZONE_CHANGED_INDOORS")
    mapInfoWatcher:SetScript("OnEvent", MapInfoWatcherOnEvent)

    coordsWatcher:RegisterEvent("CRITERIA_UPDATE")
    coordsWatcher:RegisterEvent("PLAYER_STARTED_MOVING")
    coordsWatcher:RegisterEvent("PLAYER_STOPPED_MOVING")
    coordsWatcher:RegisterEvent("PLAYER_CONTROL_LOST")
    coordsWatcher:RegisterEvent("PLAYER_CONTROL_GAINED")
    coordsWatcher:SetScript("OnEvent", CoordsWatcherOnEvent)
end
GW.InitLocationDataHandler = InitLocationDataHandler


