local _, GW = ...

local CoordsFrame
local MOUSE_LABEL = MOUSE_LABEL:gsub("|[TA].-|[ta]","")

local function UpdateCoords()
    local WorldMapFrame = _G.WorldMapFrame
    if not WorldMapFrame:IsShown() then
        return
    end

	if GW.locationData.x and GW.locationData.y then
		CoordsFrame.Coords:SetFormattedText("%s: %.2f, %.2f", PLAYER, (GW.locationData.xText or 0), (GW.locationData.yText or 0))
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
    CoordsFrame.Coords:SetFontObject(_G.Number12Font)

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