---@class GW2
local GW = select(2, ...)

local MAX_POINTS = 200
local MIN_DISTANCE = 0.004 -- of the map size, so the dots keep a gap on every zone
local RECORD_INTERVAL = 1
local DOT_SIZE = 5

local trails = {} -- per map, only for this session
local ticker

-- the dots are our own textures on the map canvas: blizzards pin system (AcquirePin) writes the canvas and
-- scroll state, from our code that runs every later map change and zoom as GW2_UI
local overlay
local dots = {}

local function DrawTrail()
    if not overlay then return end
    for _, dot in ipairs(dots) do
        dot:Hide()
    end
    local trail = GW.settings.worldmap.trail and WorldMapFrame:IsShown() and trails[WorldMapFrame:GetMapID()]
    if not trail then return end

    local width, height = overlay:GetSize()
    -- the canvas scales with the zoom, the dots keep their size on screen
    local size = DOT_SIZE / (WorldMapFrame.ScrollContainer:GetCanvasScale() or 1)
    for i, point in ipairs(trail) do
        local dot = dots[i]
        if not dot then
            dot = overlay:CreateTexture(nil, "ARTWORK")
            dot:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMask")
            dots[i] = dot
        end
        dot:SetSize(size, size)
        dot:ClearAllPoints()
        dot:SetPoint("CENTER", overlay, "TOPLEFT", point[1] * width, -point[2] * height)
        -- the older a dot, the paler
        dot:SetVertexColor(GW.Colors.FallbackWhite.r, GW.Colors.FallbackWhite.g, GW.Colors.FallbackWhite.b, 0.15 + 0.85 * i / #trail)
        dot:Show()
    end
end

-- a zoom only changes the size, the positions are relative to the canvas
local function ResizeTrail()
    local size = DOT_SIZE / (WorldMapFrame.ScrollContainer:GetCanvasScale() or 1)
    for _, dot in ipairs(dots) do
        if dot:IsShown() then
            dot:SetSize(size, size)
        end
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
        DrawTrail()
    end
end

function GW.UpdateMapTrail()
    local enabled = GW.settings.worldmap.trail
    if not overlay then
        if not enabled then return end
        -- the canvas exists once the world map is loaded, not yet when this file runs
        overlay = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer.Child)
        overlay:SetAllPoints()
        -- blizzard draws the explored map art as pins from frame level 2000 up: above it, below the icons
        overlay:SetFrameLevel(WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_MAP_HIGHLIGHT") + 1)
        hooksecurefunc(WorldMapFrame, "OnMapChanged", DrawTrail)
        hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", ResizeTrail)
        WorldMapFrame:HookScript("OnShow", DrawTrail)
    end

    if enabled and not ticker then
        ticker = C_Timer.NewTicker(RECORD_INTERVAL, RecordPosition)
    elseif not enabled and ticker then
        ticker:Cancel()
        ticker = nil
    end
    DrawTrail()
end
