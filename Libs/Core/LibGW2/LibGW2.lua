local _, GW = ...
local MAJOR, MINOR = "LibGW2-1.0", 3
assert(LibStub, MAJOR .. " requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")
local CoordsStopTimer = nil
local CoordsTicker = nil
local frame = CreateFrame("Frame")
local mapRects, tempVec2D = {}, CreateVector2D(0, 0)
local cleuEventListener = {}

local isTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
local isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

lib.callbacks = CallbackHandler:New(lib)

lib.locationData = {
    instanceMapID = nil,
    zoneText = UNKNOWN,
    coordsFalling = nil,
    coordsWatching = nil,
    mapID = nil,
    x = nil,
    y = nil,
    xText = nil,
    yText = nil
}
lib.isSkyridingRiding = nil

--/dump GW2_ADDON.Libs.GW2Lib:IsPlayerSkyRiding()
function lib:IsPlayerSkyRiding()
    return lib.isSkyridingRiding
end

function lib:GetPlayerInstanceMapID()
    return lib.locationData.instanceMapID
end

function lib:GetPlayerLocationMapID()
    return lib.locationData.mapID
end

function lib:GetPlayerLocationZoneText()
    return lib.locationData.zoneText
end

function lib:GetPlayerLocationCoords()
    return lib.locationData.x, lib.locationData.y, lib.locationData.xText, lib.locationData.yText
end

local function EnableCLEU()
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    GW.Debug("CLEU ENABLED")
end

local function DisableCLEU()
    frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    GW.Debug("CLEU DISABLED")
end

local function IsCLEUEnable()
    return frame:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED")
end

function lib:RegisterCombatEvent(frm, event, func)
    if not IsCLEUEnable() then
        EnableCLEU()
    end
    cleuEventListener[event] = cleuEventListener[event] or {}
    cleuEventListener[event][frm] = func
end

function lib:UnregisterCombatEvent(frm, event)
    if cleuEventListener[event] and cleuEventListener[event][frm] then
        cleuEventListener[event][frm] = nil
    end

    -- prune empty event tables so we can actually disable CLEU when nothing listens
    if cleuEventListener[event] and not next(cleuEventListener[event]) then
        cleuEventListener[event] = nil
    end

    if not next(cleuEventListener) then
        DisableCLEU()
    end
end

function lib:UnregisterAllCombatEvents(frm)
    for event, frames in pairs(cleuEventListener) do
        if frames[frm] then
            frames[frm] = nil
            if not next(frames) then
                cleuEventListener[event] = nil
            end
        end
    end

    if not next(cleuEventListener) then
        DisableCLEU()
    end
end


local function HandlingCLEU(_, subEvent, _, sourceGUID, srcName, sourceFlags, _, destGUID, destName, _, _, ...)
    for eventKey, frameListeners in pairs(cleuEventListener) do
        if subEvent == eventKey or strmatch(subEvent, eventKey) then
            for frm, func in pairs(frameListeners) do
                if type(func) == "function" then
                    func(frm, _, subEvent, _, sourceGUID, srcName, sourceFlags, _, destGUID, destName, _, _, ...)
                end
            end
        end
    end
end

local function GetPlayerMapPos(mapID)
    tempVec2D.x, tempVec2D.y = UnitPosition("player")
    if not tempVec2D.x then return end

    local mapRect = mapRects[mapID]
    if not mapRect then
        local _, pos1 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
        local _, pos2 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
        if not pos1 or not pos2 then return end

        mapRect = {pos1, pos2}
        mapRect[2]:Subtract(mapRect[1])
        mapRects[mapID] = mapRect
    end
    tempVec2D:Subtract(mapRect[1])

    return (tempVec2D.y / mapRect[2].y), (tempVec2D.x / mapRect[2].x)
end

local function CoordsUpdate()
    if lib.locationData.mapID then
        lib.locationData.x, lib.locationData.y = GetPlayerMapPos(lib.locationData.mapID)
    else
        lib.locationData.x, lib.locationData.y = nil, nil
    end

    if lib.locationData.x and lib.locationData.y then
        lib.locationData.xText = tonumber(string.format("%.2f", 100 * lib.locationData.x))
        lib.locationData.yText = tonumber(string.format("%.2f", 100 * lib.locationData.y))
    else
        lib.locationData.xText, lib.locationData.yText = nil, nil
    end
end

local function CoordsStopWatching()
    lib.locationData.coordsWatching = nil
    CoordsStopTimer = nil
    if CoordsTicker then
        CoordsTicker:Cancel()
        CoordsTicker = nil
    end
end

local function CoordsWatcherStart()
    lib.locationData.coordsWatching = true
    lib.locationData.coordsFalling = nil
    if CoordsTicker then
        CoordsTicker:Cancel()
        CoordsTicker = nil
    end
    CoordsTicker = C_Timer.NewTicker(0.1, CoordsUpdate)
    if CoordsStopTimer then
        CoordsStopTimer:Cancel()
        CoordsStopTimer = nil
    end
end

local function CoordsWatcherStop(event)
    if event == "CRITERIA_UPDATE" then
        if lib.locationData.coordsFalling or (GetUnitSpeed("player") or 0) > 0 then return end
        lib.locationData.coordsFalling = nil
    elseif (event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_CONTROL_GAINED") and IsFalling() then
        lib.locationData.coordsFalling = true
        return
    end

    if not CoordsStopTimer then
        CoordsStopTimer = C_Timer.NewTimer(0.5, CoordsStopWatching)
    end
end

local function MapInfoUpdateMapId()
    lib.locationData.mapID = C_Map.GetBestMapForUnit("player")
    if not lib.locationData.mapID then
        C_Timer.After(0.1, MapInfoUpdateMapId)
    end
end

local function IsSkyriding(canSkyriding, isLogin)
    if canSkyriding == nil then
        canSkyriding = select(2, C_PlayerInfo.GetGlidingInfo())
    end
    if canSkyriding ~= lib.isSkyridingRiding then
        lib.isSkyridingRiding = canSkyriding
        lib.callbacks:Fire("GW2_PLAYER_SKYRIDING_STATE_CHANGE", lib.isSkyridingRiding, isLogin)
    end
end
local function HandleEvents(_, event, ...)
    if event == "CRITERIA_UPDATE" or event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_CONTROL_GAINED" then
        CoordsWatcherStop(event)
    elseif event == "PLAYER_STARTED_MOVING" or event == "PLAYER_CONTROL_LOST" then
        CoordsWatcherStart()
    elseif event == "PLAYER_CAN_GLIDE_CHANGED" then
        local canSkyriding = ...
        IsSkyriding(canSkyriding)
    elseif event == "PLAYER_ENTERING_WORLD" and GW.Retail then
        local isLogin, isReload = ...
        IsSkyriding(nil, isLogin or isReload)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        HandlingCLEU(CombatLogGetCurrentEventInfo())
    else
        MapInfoUpdateMapId()
        lib.locationData.instanceMapID = select(8, GetInstanceInfo())
        lib.locationData.zoneText = GetRealZoneText() or UNKNOWN

        CoordsUpdate()
    end
end

local events = {
    "LOADING_SCREEN_DISABLED",
    "ZONE_CHANGED_NEW_AREA",
    "ZONE_CHANGED",
    "ZONE_CHANGED_INDOORS",
    "PLAYER_ENTERING_WORLD",
    "CRITERIA_UPDATE",
    "PLAYER_STARTED_MOVING",
    "PLAYER_STOPPED_MOVING",
    "PLAYER_CONTROL_LOST",
    "PLAYER_CONTROL_GAINED"
}
if isRetail then
    tinsert(events, "PLAYER_CAN_GLIDE_CHANGED")
end

for _, evt in ipairs(events) do
    frame:RegisterEvent(evt)
end

frame:SetScript("OnEvent", HandleEvents)
