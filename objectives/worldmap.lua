local _, GW = ...
local AFP = GW.AddProfiling

local CoordsFrame
local MOUSE_LABEL = MOUSE_LABEL:gsub("|[TA].-|[ta]","")

function WorldMapScrollFrame_GetNormalizedCursorPosition(frame)
    local scale = frame:GetEffectiveScale()

    local cursorX, cursorY = GetCursorPosition()
    cursorX = cursorX / scale
    cursorY = cursorY / scale

    local left, bottom, width, height = frame:GetRect()

    local x = (cursorX - left) / width
    local y = (bottom + height - cursorY) / height

    return x, y
end

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

    if WorldMapScrollFrame:IsMouseOver() then
        local x, y = WorldMapScrollFrame_GetNormalizedCursorPosition(WorldMapScrollFrame)
        if x and y and x >= 0 and y >= 0 then
            CoordsFrame.Coords:SetFormattedText("%s - %s: %.2f, %.2f", CoordsFrame.Coords:GetText(), MOUSE_LABEL, x * 100, y * 100)
        end
    end
end
AFP("UpdateCoords", UpdateCoords)



local function ToggleWorldMapCoords()
    if GW.settings.WORLDMAP_COORDS_TOGGLE then
        CoordsFrame:Show()
    else
        CoordsFrame:Hide()
    end
end
GW.ToggleWorldMapCoords = ToggleWorldMapCoords

local function AddCoordsToWorldMap()
    local CoordsTimer = nil
    CoordsFrame = CreateFrame("Frame", nil, WorldMapFrame)
    CoordsFrame:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
    CoordsFrame:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
    CoordsFrame.Coords = CoordsFrame:CreateFontString(nil, "OVERLAY")
    CoordsFrame.Coords:SetTextColor(1, 1 ,1)

    CoordsFrame.Coords:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)

    WorldMapFrame:HookScript("OnShow", function()
        if not CoordsTimer then
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

    CoordsFrame.Coords:ClearAllPoints()
    CoordsFrame.Coords:SetPoint("TOP", WorldMapFrame.ScrollContainer, "TOP", 0, 0)

    ToggleWorldMapCoords()
end
GW.AddCoordsToWorldMap = AddCoordsToWorldMap