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

local function UpdateCoords()
    local WorldMapFrame = _G.WorldMapFrame
    if not WorldMapFrame:IsShown() then
        return
    end

    if WorldMapFrame.ScrollContainer:IsMouseOver() then
        local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
        if x and y and x >= 0 and y >= 0 then
            CoordsFrame.mouseCoords:SetFormattedText("%s: %.2f, %.2f", MOUSE_LABEL, x * 100, y * 100)
        else
            CoordsFrame.mouseCoords:SetText("")
        end
    else
        CoordsFrame.mouseCoords:SetText("")
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
		CoordsFrame.playerCoords:SetFormattedText("%s: %.2f, %.2f", PLAYER, (x or 0), (y or 0))
	else
		CoordsFrame.playerCoords:SetFormattedText("%s: %s", PLAYER, "N/A")
	end
end

local function AddCoordsToWorldMap()
    local WorldMapFrame = _G.WorldMapFrame

	local CoordsTimer = nil
    CoordsFrame = CreateFrame("Frame", nil, WorldMapFrame)
    CoordsFrame:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
    CoordsFrame:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
    CoordsFrame.playerCoords = CoordsFrame:CreateFontString(nil, "OVERLAY")
    CoordsFrame.mouseCoords = CoordsFrame:CreateFontString(nil, "OVERLAY")
    CoordsFrame.playerCoords:SetTextColor(1, 1 ,1)
    CoordsFrame.mouseCoords:SetTextColor(1, 1 ,1)
    CoordsFrame.playerCoords:SetFontObject(_G.NumberFontNormal)
    CoordsFrame.mouseCoords:SetFontObject(_G.NumberFontNormal)

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

    CoordsFrame.playerCoords:ClearAllPoints()
	CoordsFrame.playerCoords:SetPoint("BOTTOMLEFT", _G.WorldMapFrame.ScrollContainer, "BOTTOMLEFT", 5, 5)

	CoordsFrame.mouseCoords:ClearAllPoints()
	CoordsFrame.mouseCoords:SetPoint("BOTTOMLEFT", CoordsFrame.playerCoords, "TOPLEFT", 0, 5)
end
GW.AddCoordsToWorldMap = AddCoordsToWorldMap