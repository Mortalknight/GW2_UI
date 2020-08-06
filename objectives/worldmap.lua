local _, GW = ...

local CoordsFrame
local MOUSE_LABEL = MOUSE_LABEL:gsub("|[TA].-|[ta]","")

local mapRects, tempVec2D = {}, CreateVector2D(0, 0)
local function GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end

	local mapRect = mapRects[mapID]
	if not mapRect then
		mapRect = {
			select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))),
			select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))}
		mapRect[2]:Subtract(mapRect[1])
		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return (tempVec2D.y/mapRect[2].y), (tempVec2D.x/mapRect[2].x)
end
GW.GetPlayerMapPos = GetPlayerMapPos

local function UpdateCoords()
    local WorldMapFrame = _G.WorldMapFrame
    if not WorldMapFrame:IsShown() then
        return
    end

	local x, y
	local mapID = C_Map.GetBestMapForUnit("player")
	if mapID then
		x, y = GetPlayerMapPos(mapID)
	else
		x, y = nil, nil
	end

	if x and y then
		x = GW.RoundDec(100 * x, 2)
		y = GW.RoundDec(100 * y, 2)
		CoordsFrame.Coords:SetFormattedText("%s: %.2f, %.2f", PLAYER, (x or 0), (y or 0))
	else
		CoordsFrame.Coords:SetFormattedText("%s: %s", PLAYER, "n/a")
    end
    
    if WorldMapFrame.ScrollContainer:IsMouseOver() then
        local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
        if x and y and x >= 0 and y >= 0 then
            CoordsFrame.Coords:SetFormattedText("%s - %s: %.2f, %.2f", CoordsFrame.Coords:GetText(), MOUSE_LABEL, x * 100, y * 100)
        end
    end
end

local function AddCoordsToWorldMap()
    local WorldMapFrame = _G.WorldMapFrame

	local CoordsTimer = nil
    CoordsFrame = CreateFrame("Frame", nil, WorldMapFrame)
    CoordsFrame:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
    CoordsFrame:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
    CoordsFrame.Coords = CoordsFrame:CreateFontString(nil, "OVERLAY")
    CoordsFrame.Coords:SetTextColor(1, 1 ,1)
    CoordsFrame.Coords:SetFontObject(_G.NumberFontNormal)

    WorldMapFrame:HookScript("OnShow", function()
        if not CoordsTimer then
			UpdateCoords()
			CoordsTimer = C_Timer.NewTicker(0.1, function() UpdateCoords() end)
        end
    end)
    WorldMapFrame:HookScript("OnHide", function()
        CoordsTimer:Cancel()
        CoordsTimer = nil
    end)

    CoordsFrame.Coords:ClearAllPoints()
	CoordsFrame.Coords:SetPoint("TOP", _G.WorldMapFrame.ScrollContainer, "TOP", 0, 0)
end
GW.AddCoordsToWorldMap = AddCoordsToWorldMap