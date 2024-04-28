local MAJOR, MINOR = "LibGW2-1.0", 1
assert(LibStub, MAJOR .." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")
local CoordsStopTimer = nil
local CoordsTicker = nil
local activeDragonridingBuffs = {}

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
lib.isDragonRiding = false

function lib:IsPlayerDragonRiding()
    return lib.isDragonRiding
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

do
    local frame = CreateFrame("Frame")
    local mapRects, tempVec2D = {}, CreateVector2D(0, 0)

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
        CoordsTicker = C_Timer.NewTicker(0.1, function() CoordsUpdate() end)
        if CoordsStopTimer then
            CoordsStopTimer:Cancel()
            CoordsStopTimer = nil
        end
    end

    local function CoordsWatcherStop(event)
        if event == "CRITERIA_UPDATE" then
            if lib.locationData.coordsFalling then return end
            if (GetUnitSpeed("player") or 0) > 0 then return end
            lib.locationData.coordsFalling = nil
        elseif (event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_CONTROL_GAINED") and IsFalling() then
            lib.locationData.coordsFalling = true
            return
        end

        if not CoordsStopTimer then
            CoordsStopTimer = C_Timer.NewTimer(0.5, function() CoordsStopWatching() end)
        end
    end

    local function MapInfoUpdateMapId()
        lib.locationData.mapID = C_Map.GetBestMapForUnit("player")
        if not lib.locationData.mapID then
            C_Timer.After(0.1, function() MapInfoUpdateMapId() end)
        end
    end

    local function UpdateDragonRidingState(isLogin, useDelay, dragonridingBuffActive)
        if dragonridingBuffActive then
            lib.isDragonRiding = true
        elseif IsMounted() then
            local dragonridingSpellIds = C_MountJournal.GetCollectedDragonridingMounts()
            lib.isDragonRiding = false
            for _, mountId in ipairs(dragonridingSpellIds) do
                local spellId = select(2, C_MountJournal.GetMountInfoByID(mountId))
                if C_UnitAuras.GetPlayerAuraBySpellID(spellId) then
                    lib.isDragonRiding = true
                    break
                end
            end
        else
            lib.isDragonRiding = false
        end
        if useDelay then
            C_Timer.After(1, function()
                UpdateDragonRidingState(true)
            end)
        else
            lib.callbacks:Fire("GW2_PLAYER_DRAGONRIDING_STATE_CHANGE", lib.isDragonRiding, isLogin)
        end
    end

    local function HandleEvents(_, event, ...)
        if event == "CRITERIA_UPDATE" or event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_CONTROL_GAINED" then
            CoordsWatcherStop(event)
        elseif event == "PLAYER_STARTED_MOVING" or event == "PLAYER_CONTROL_LOST" then
            CoordsWatcherStart()
        elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
            UpdateDragonRidingState()
        elseif event == "PLAYER_ENTERING_WORLD" then
            local isLogin, isReload = ...do
                UpdateDragonRidingState(isLogin or isReload, true)
            end
        elseif event == "UNIT_AURA" then
            local updateInfo = select(2, ...)
            if updateInfo.addedAuras then
                for _, data in next, updateInfo.addedAuras do
                    if data.spellId == 369536 then --soar from evoker
                        activeDragonridingBuffs[data.auraInstanceID] = data
                        UpdateDragonRidingState(nil, nil, true)
                        break
                    end
                end
            end

            if updateInfo.removedAuraInstanceIDs then
				for _, auraInstanceID in next, updateInfo.removedAuraInstanceIDs do
                    if activeDragonridingBuffs[auraInstanceID] then
                        activeDragonridingBuffs[auraInstanceID] = nil
                        UpdateDragonRidingState(nil, nil, false)
                        break
                    end
                end
            end
        else
            MapInfoUpdateMapId()
            lib.locationData.instanceMapID = select(8, GetInstanceInfo())
            lib.locationData.zoneText = GetRealZoneText() or UNKNOWN

            CoordsUpdate()
        end
    end

    frame:RegisterEvent("LOADING_SCREEN_DISABLED")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:RegisterEvent("ZONE_CHANGED")
    frame:RegisterEvent("ZONE_CHANGED_INDOORS")
    frame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("CRITERIA_UPDATE")
    frame:RegisterEvent("PLAYER_STARTED_MOVING")
    frame:RegisterEvent("PLAYER_STOPPED_MOVING")
    frame:RegisterEvent("PLAYER_CONTROL_LOST")
    frame:RegisterEvent("PLAYER_CONTROL_GAINED")
    frame:RegisterUnitEvent("UNIT_AURA", "player")
    frame:SetScript("OnEvent", HandleEvents)
end