local _, GW = ...
local CoordsFrame
local MOUSE_LABEL = MOUSE_LABEL:gsub("|[TA].-|[ta]","")

local function UpdateSettings()
    -- set the position and toggle the frame
    local pos = GW.settings.WORLDMAP_COORDS_POSITION
    local xOff = GW.settings.WORLDMAP_COORDS_X_OFFSET
    local yOff = GW.settings.WORLDMAP_COORDS_Y_OFFSET
    CoordsFrame.Coords:ClearAllPoints()
    CoordsFrame.Coords:SetPoint(pos, WorldMapFrame.ScrollContainer, pos, xOff, yOff)

    if GW.settings.WORLDMAP_COORDS_TOGGLE then
        CoordsFrame:Show()
    else
        CoordsFrame:Hide()
    end
end
GW.UpdateWorldMapCoordinateSettings = UpdateSettings

local function UpdateCoords()
    if not WorldMapFrame:IsShown() then
        return
    end

    local x, y, xT, yT = GW.Libs.GW2Lib:GetPlayerLocationCoords()
    if x and y then
        CoordsFrame.Coords:SetFormattedText("%s: %s/%s", PLAYER, GW.GetLocalizedNumber(xT or 0, 2), GW.GetLocalizedNumber(yT or 0, 2))
    else
        CoordsFrame.Coords:SetFormattedText("%s: %s", PLAYER, NOT_APPLICABLE)
    end

    if WorldMapFrame.ScrollContainer:IsMouseOver() then
        local mX, mY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
        if mX and mY and mX >= 0 and mY >= 0 then
            CoordsFrame.Coords:SetFormattedText("%s - %s: %s/%s", CoordsFrame.Coords:GetText(), MOUSE_LABEL, GW.GetLocalizedNumber(mX * 100, 2), GW.GetLocalizedNumber(mY * 100, 2))
        end
    end
end


local function AddCoordsToWorldMap()
    local ticker
    CoordsFrame = CreateFrame("Frame", nil, WorldMapFrame)
    CoordsFrame:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
    CoordsFrame:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
    CoordsFrame.Coords = CoordsFrame:CreateFontString(nil, "OVERLAY")
    CoordsFrame.Coords:SetTextColor(1, 1, 1)
    CoordsFrame.Coords:SetFontObject(Number12Font)

    WorldMapFrame:HookScript("OnShow", function()
        if GW.settings.WORLDMAP_COORDS_TOGGLE and not ticker then
            UpdateCoords()
            ticker = C_Timer.NewTicker(0.1, UpdateCoords)
        end
    end)
    WorldMapFrame:HookScript("OnHide", function()
        if ticker then
            ticker:Cancel()
            ticker = nil
        end
    end)

    UpdateSettings()
end
GW.AddCoordsToWorldMap = AddCoordsToWorldMap