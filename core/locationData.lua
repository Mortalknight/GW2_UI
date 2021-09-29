local _, GW = ...

local MapCoordsFrame = CreateFrame("Frame")
local mapRects, tempVec2D = {}, CreateVector2D(0, 0)

local function GetPlayerMapPos()
    local mapID = GW.locationData.mapID
    if not mapID then
        return nil, nil
    end

    tempVec2D.x, tempVec2D.y = UnitPosition("player")
    if not tempVec2D.x then return end

    local mapRect = mapRects[mapID]
    if not mapRect then
        mapRect = {
            select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))),
            select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))}
        if mapRect[1] and mapRect[2] then
            mapRect[2]:Subtract(mapRect[1])
            mapRects[mapID] = mapRect
        else
            return nil, nil
        end
    end
    tempVec2D:Subtract(mapRect[1])

    return (tempVec2D.y/mapRect[2].y), (tempVec2D.x/mapRect[2].x)
end
GW.GetPlayerMapPos = GetPlayerMapPos

local function UpdateCoord()
    GW.locationData.x, GW.locationData.y = GetPlayerMapPos()

    if GW.locationData.x and GW.locationData.y then
        GW.locationData.xText = GW.RoundDec(100 * GW.locationData.x, 2)
        GW.locationData.yText = GW.RoundDec(100 * GW.locationData.y, 2)
    else
        GW.locationData.xText, GW.locationData.yText = nil, nil
    end
end

local function LocationDate_OnUpdate(self, elapsed)
    self.lastUpdate = (self.lastUpdate or 0) + elapsed
    if self.lastUpdate > 0.1 then
        UpdateCoord()
        self.lastUpdate = 0
    end
end

local function MapInfoFrameOnEvent()
    GW.locationData.mapID = C_Map.GetBestMapForUnit("player")
    GW.locationData.instanceMapID = select(8, GetInstanceInfo())
    GW.locationData.ZoneText = GetRealZoneText()
    if GW.locationData.mapID then
        GW.locationData.mapPosition = C_Map.GetPlayerMapPosition(GW.locationData.mapID, "player")
    end
    GW.Debug("Zone change mapID: ", GW.locationData.instanceMapID, "; Instance mapID: ", GW.locationData.instanceMapID, " Zonename: ", GW.locationData.ZoneText)

    -- update also the coords in new area
    UpdateCoord()
end

local function MapCoordsFrameOnEvent(self, event)
    -- check if we need to starte coords updating
    -- Events for start updating coords
    if event == "PLAYER_STARTED_MOVING" or event == "PLAYER_CONTROL_LOST" then
        GW.locationData.coordsWatching = true
        GW.locationData.coordsFalling = nil
        self:SetScript("OnUpdate", LocationDate_OnUpdate)

        if GW.locationData.coordsStopTimer then
            GW.locationData.coordsStopTimer:Cancel()
            GW.locationData.coordsStopTimer = nil
        end
    elseif event == "CRITERIA_UPDATE" or event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_CONTROL_GAINED" then -- Events for stop updating coords
        if event == 'CRITERIA_UPDATE' then
            if not GW.locationData.coordsFalling or (GetUnitSpeed("player") or 0) > 0 then -- stop if we weren't falling or we are still moving
                return 
            end 
            GW.locationData.coordsFalling = nil -- we were falling!
        elseif event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_CONTROL_GAINED" and IsFalling() then
            GW.locationData.coordsFalling = true
            return
        end

        if not GW.locationData.coordsStopTimer then
            GW.locationData.coordsStopTimer = C_Timer.After(0.5, function()
                GW.locationData.coordsWatching = nil
                GW.locationData.coordsStopTimer = nil
                MapCoordsFrame:SetScript("OnUpdate", nil)
            end)
        end
    end
end

local function InitLocationDataHandler()
    GW.locationData.mapID = nil
    GW.locationData.instanceMapID = nil
    GW.locationData.mapID = ""

    local MapInfoFrame = CreateFrame("Frame")
    MapInfoFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
    MapInfoFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    MapInfoFrame:RegisterEvent("ZONE_CHANGED")
    MapInfoFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    MapInfoFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    MapInfoFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    MapInfoFrame:SetScript("OnEvent", MapInfoFrameOnEvent)

    MapCoordsFrame:RegisterEvent("CRITERIA_UPDATE")
    MapCoordsFrame:RegisterEvent("PLAYER_STARTED_MOVING")
    MapCoordsFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
    MapCoordsFrame:RegisterEvent("PLAYER_CONTROL_LOST")
    MapCoordsFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
    MapCoordsFrame:SetScript("OnEvent", MapCoordsFrameOnEvent)
end
GW.InitLocationDataHandler = InitLocationDataHandler