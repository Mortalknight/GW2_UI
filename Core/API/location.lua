---@class GW2
local GW = select(2, ...)

-- Where the player is: map, zone, instance and the coordinates on the map, and whether it can skyride. The coordinates
-- only tick while the player moves, the rest follows the zone events.

local state = {zoneText = UNKNOWN}
local mapRects = {}
local position = CreateVector2D(0, 0)
local ticker, stopTimer

GW.Location = {}

function GW.Location.GetMapID()
    return state.mapID
end

function GW.Location.GetInstanceMapID()
    return state.instanceMapID
end

function GW.Location.GetZoneText()
    return state.zoneText
end

-- 0..1 from the top left of the map, and the same in percent with two decimals
function GW.Location.GetCoords()
    return state.x, state.y, state.xText, state.yText
end

function GW.Location.IsSkyriding()
    return state.skyriding
end

-- the world rectangle of a map is kept per map
local function GetMapPosition(mapID)
    position.x, position.y = UnitPosition("player")
    if not position.x then return end

    local rect = mapRects[mapID]
    if not rect then
        local _, topLeft = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
        local _, bottomRight = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
        if not topLeft or not bottomRight then return end
        bottomRight:Subtract(topLeft)
        rect = {topLeft, bottomRight}
        mapRects[mapID] = rect
    end
    position:Subtract(rect[1])
    return position.y / rect[2].y, position.x / rect[2].x
end

local function UpdateCoords()
    local x, y
    if state.mapID then
        x, y = GetMapPosition(state.mapID)
    end
    state.x, state.y = x, y
    state.xText = x and tonumber(format("%.2f", 100 * x))
    state.yText = y and tonumber(format("%.2f", 100 * y))
end

local function StopTicker()
    stopTimer = nil
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
end

local function StartMoving()
    state.falling = nil
    if ticker then
        ticker:Cancel()
    end
    ticker = C_Timer.NewTicker(0.1, UpdateCoords)
    if stopTimer then
        stopTimer:Cancel()
        stopTimer = nil
    end
end

-- stopping in the air is no stop, the coordinates keep ticking until the landing
local function StopMoving(event)
    if event == "CRITERIA_UPDATE" then
        local speed = GetUnitSpeed("player") or 0
        if state.falling or (GW.NotSecretValue(speed) and speed > 0) then return end
        state.falling = nil
    elseif IsFalling() then
        state.falling = true
        return
    end
    if not stopTimer then
        stopTimer = C_Timer.NewTimer(0.5, StopTicker)
    end
end

local function UpdateSkyriding(canSkyride, isLogin)
    if canSkyride == nil then
        canSkyride = select(2, C_PlayerInfo.GetGlidingInfo())
    end
    if canSkyride ~= state.skyriding then
        state.skyriding = canSkyride
        EventRegistry:TriggerEvent("GW2_UI.PlayerSkyridingStateChanged", canSkyride, isLogin)
    end
end

local function UpdateZone()
    -- right after a zone change the game has no map for the player yet
    C_Timer.After(0.1, function()
        state.mapID = C_Map.GetBestMapForUnit("player")
    end)
    state.instanceMapID = select(8, GetInstanceInfo())
    state.zoneText = GetRealZoneText() or UNKNOWN
    UpdateCoords()
end

local hasSkyriding = C_PlayerInfo.GetGlidingInfo and C_EventUtils.IsEventValid("PLAYER_CAN_GLIDE_CHANGED")

local function OnEvent(_, event, ...)
    if event == "PLAYER_STARTED_MOVING" or event == "PLAYER_CONTROL_LOST" then
        StartMoving()
    elseif event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_CONTROL_GAINED" or event == "CRITERIA_UPDATE" then
        StopMoving(event)
    elseif event == "PLAYER_CAN_GLIDE_CHANGED" then
        UpdateSkyriding((...))
    else
        if event == "PLAYER_ENTERING_WORLD" and hasSkyriding then
            local isLogin, isReload = ...
            UpdateSkyriding(nil, isLogin or isReload)
        end
        UpdateZone()
    end
end

local watcher = CreateFrame("Frame")
watcher:SetScript("OnEvent", OnEvent)
for _, event in ipairs({
    "LOADING_SCREEN_DISABLED", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS",
    "MINIMAP_UPDATE_ZOOM", "CRITERIA_UPDATE", "PLAYER_STARTED_MOVING", "PLAYER_STOPPED_MOVING", "PLAYER_CONTROL_LOST",
    "PLAYER_CONTROL_GAINED",
}) do
    watcher:RegisterEvent(event)
end
if hasSkyriding then
    watcher:RegisterEvent("PLAYER_CAN_GLIDE_CHANGED")
end
