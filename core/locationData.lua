local _, GW = ...

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

local function eventFrameOnEvent(self)
    GW.locationData.mapID = C_Map.GetBestMapForUnit("player")
    GW.locationData.instanceMapID = select(8, GetInstanceInfo())
    GW.locationData.ZoneText = GetRealZoneText()
    GW.Debug("Zone change mapID: ", GW.locationData.instanceMapID, "; Instance mapID: ", GW.locationData.instanceMapID, " Zonename: ", GW.locationData.ZoneText)
end

local function InitLocationDataHandler()
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    eventFrame:RegisterEvent("ZONE_CHANGED")
    eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    eventFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    
    eventFrame.updateCap = 1 / 5
    eventFrame.elapsedTimer = -1
    GW.locationData.mapID = nil
    GW.locationData.instanceMapID = nil
    GW.locationData.mapID = ""

    eventFrame:SetScript("OnEvent", eventFrameOnEvent)
end
GW.InitLocationDataHandler = InitLocationDataHandler