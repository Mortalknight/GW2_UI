local _, GW = ...
local AFP = GW.AddProfiling
local CoordsFrame
local MOUSE_LABEL = MOUSE_LABEL:gsub("|[TA].-|[ta]","")

local function UpdateSettings()
    -- set the position and toggle the frame
    CoordsFrame.Coords:ClearAllPoints()
    CoordsFrame.Coords:SetPoint(GW.settings.WORLDMAP_COORDS_POSITION, WorldMapFrame.ScrollContainer, GW.settings.WORLDMAP_COORDS_POSITION, GW.settings.WORLDMAP_COORDS_X_OFFSET, GW.settings.WORLDMAP_COORDS_Y_OFFSET)

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
        CoordsFrame.Coords:SetFormattedText("%s: %.2f, %.2f", PLAYER, (xT or 0), (yT or 0))
    else
        CoordsFrame.Coords:SetFormattedText("%s: %s", PLAYER, NOT_APPLICABLE)
    end

    if WorldMapFrame.ScrollContainer:IsMouseOver() then
        local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
        if x and y and x >= 0 and y >= 0 then
            CoordsFrame.Coords:SetFormattedText("%s - %s: %.2f, %.2f", CoordsFrame.Coords:GetText(), MOUSE_LABEL, x * 100, y * 100)
        end
    end
end
AFP("UpdateCoords", UpdateCoords)

local function AddCoordsToWorldMap()
    local CoordsTimer = nil
    CoordsFrame = CreateFrame("Frame", nil, WorldMapFrame)
    CoordsFrame:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
    CoordsFrame:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
    CoordsFrame.Coords = CoordsFrame:CreateFontString(nil, "OVERLAY")
    CoordsFrame.Coords:SetTextColor(1, 1 ,1)
    CoordsFrame.Coords:SetFontObject(Number12Font)

    WorldMapFrame:HookScript("OnShow", function()
        if not CoordsTimer and GW.settings.WORLDMAP_COORDS_TOGGLE then
            UpdateCoords()
            if CoordsTimer then
                CoordsTimer:Cancel()
                CoordsTimer = nil
            end
            CoordsTimer = C_Timer.NewTicker(0.1, function() UpdateCoords() end)
        end
    end)
    WorldMapFrame:HookScript("OnHide", function()
        if CoordsTimer then
            CoordsTimer:Cancel()
            CoordsTimer = nil
        end
    end)

    UpdateSettings()
end
GW.AddCoordsToWorldMap = AddCoordsToWorldMap