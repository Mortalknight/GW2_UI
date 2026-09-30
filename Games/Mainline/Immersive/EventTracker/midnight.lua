---@class GW2
local GW = select(2, ...)
local L = GW.L
local ET = GW.EventTracker

---------- Weekly quests ----------

-- Abundance rotates between zones; resolve the current one from the event scheduler / map POIs
local AbundanceMapIDs = {
    [2395] = true, -- Eversong Woods
    [2405] = true, -- Voidstorm
    [2413] = true, -- Harandar
    [2437] = true, -- Zul'Aman
}

local function ContainsText(value, text)
    return type(value) == "string"
        and type(text) == "string"
        and strfind(strlower(value), strlower(text), 1, true) ~= nil
end

local function IsAbundanceEvent(eventInfo, poiInfo)
    local abundanceName = type(L["Abundance"]) == "string" and L["Abundance"] or "Abundance"
    return ContainsText(eventInfo and eventInfo.eventKey, "abundance")
        or ContainsText(poiInfo and poiInfo.name, abundanceName)
        or ContainsText(poiInfo and poiInfo.description, abundanceName)
end

local function GetEventPOIInfo(mapID, areaPoiID)
    if not C_AreaPoiInfo.GetAreaPOIInfo or not areaPoiID then
        return
    end

    return C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
        or C_AreaPoiInfo.GetAreaPOIInfo(nil, areaPoiID)
end

local function FindAbundanceMap(events, currentTime, hasSchedule)
    local scheduledMapID
    local hasCurrentEventFlag = false

    for _, eventInfo in ipairs(events or {}) do
        local areaPoiID = eventInfo and eventInfo.areaPoiID
        local mapID = areaPoiID and C_EventScheduler.GetEventUiMapID and C_EventScheduler.GetEventUiMapID(areaPoiID)

        if mapID and AbundanceMapIDs[mapID] then
            local poiInfo = GetEventPOIInfo(mapID, areaPoiID)
            if poiInfo and poiInfo.isCurrentEvent ~= nil then
                hasCurrentEventFlag = true
            end

            local isCurrent = not hasSchedule
                or ((not eventInfo.startTime or eventInfo.startTime <= currentTime)
                    and (not eventInfo.endTime or eventInfo.endTime > currentTime))
            if isCurrent and IsAbundanceEvent(eventInfo, poiInfo) then
                if poiInfo and poiInfo.isCurrentEvent then
                    return mapID
                end

                if not scheduledMapID then
                    scheduledMapID = mapID
                end
            end
        end
    end

    if not hasCurrentEventFlag then
        return scheduledMapID
    end
end

local abundanceCache = { mapID = nil, time = 0 }
local ABUNDANCE_CACHE_SECONDS = 60

-- called from the weekly ticker (every 2s), the lookup walks scheduler and poi data of four maps,
-- so the result is cached for a minute
local function GetCurrentAbundanceMapID()
    local currentTime = GetServerTime()
    if abundanceCache.mapID and currentTime - abundanceCache.time < ABUNDANCE_CACHE_SECONDS then
        return abundanceCache.mapID
    end

    local mapID
    if C_EventScheduler.HasData and C_EventScheduler.HasData() then
        mapID = FindAbundanceMap(C_EventScheduler.GetScheduledEvents and C_EventScheduler.GetScheduledEvents(), currentTime, true)
            or FindAbundanceMap(C_EventScheduler.GetOngoingEvents and C_EventScheduler.GetOngoingEvents(), currentTime, false)
    elseif C_EventScheduler.RequestEvents then
        C_EventScheduler.RequestEvents()
    end

    if not mapID and C_AreaPoiInfo.GetEventsForMap and C_AreaPoiInfo.GetAreaPOIInfo then
        for candidateMapID in pairs(AbundanceMapIDs) do
            for _, areaPoiID in ipairs(C_AreaPoiInfo.GetEventsForMap(candidateMapID) or {}) do
                local poiInfo = GetEventPOIInfo(candidateMapID, areaPoiID)
                if poiInfo and poiInfo.isCurrentEvent and IsAbundanceEvent(nil, poiInfo) then
                    mapID = candidateMapID
                    break
                end
            end
            if mapID then break end
        end
    end

    if mapID then
        abundanceCache.mapID, abundanceCache.time = mapID, currentTime
    end

    return mapID
end

local weeklyMNStorylines = {
    [ET.WeeklyName(7578704, L["Liadrin 4 > 1"], 2393)] = {
        -- https://www.wowhead.com/npc=256203/lady-liadrin
        93766, 93767, 93769, 93889, 93890, 93891, 93892, 93909, 93911, 93912, 93913, 94457,
        95842, 95843, 96727, 98232,
    },
    [ET.WeeklyName(7578704, L["Prey Hunt"], 2393)] = {
        -- https://www.wowhead.com/quest=94446/a-nightmarish-task
        -- https://www.wowhead.com/quest=93910/midnight-prey
        94446, 93910,
    },
    [ET.WeeklyName(5554512, L["Dungeon"], 2393)] = {
        -- https://www.wowhead.com/npc=256210/halduron-brightwing
        93751, 93752, 93753, 93754, 93755, 93756, 93757, 93758,
    },
    [ET.WeeklyName(2066011, L["Soiree"], 2395)] = {
        -- https://www.wowhead.com/item=268489/surplus-bag-of-party-favors
        90573, 90574, 90575, 90576,
    },
    [ET.WeeklyName(7385004, L["Legend"], 2413)] = {
        -- https://www.wowhead.com/npc=238170/zurashar-kassameh#ends
        89268, 92713,
    },
    [ET.WeeklyName(236681, L["Silvermoon Court"], 2395)] = {
        -- https://www.wowhead.com/quest=89289/favor-of-the-court
        89289,
    },
    [ET.WeeklyName(7431083, L["Zul'jarra's Forces"], 2512)] = {
        -- https://www.wowhead.com/quest=96995/turn-back-the-surge
        -- https://www.wowhead.com/quest=95520/purging-the-vaults
        96995, 95520,
    },
    [ET.WeeklyName(236681, L["Slayer's Duellum"], 2444)] = {
        -- https://www.wowhead.com/quest=89354/preparing-for-battle
        89354,
    },
}

-- the Abundance entry carries the current zone in its label, so the table is rebuilt only when
-- the zone changes
local weeklyMNQuestIDs, weeklyMNAbundanceMapID
local function GetWeeklyMNQuestIDs()
    local mapID = GetCurrentAbundanceMapID()
    if weeklyMNQuestIDs and weeklyMNAbundanceMapID == mapID then
        return weeklyMNQuestIDs
    end

    weeklyMNAbundanceMapID = mapID
    weeklyMNQuestIDs = {}
    for storylineName, storylineQuests in pairs(weeklyMNStorylines) do
        weeklyMNQuestIDs[storylineName] = storylineQuests
    end
    weeklyMNQuestIDs[ET.WeeklyName(7636650, L["Abundance"], mapID)] = {
        -- https://www.wowhead.com/quest=89507/abundant-offerings
        89507,
    }

    return weeklyMNQuestIDs
end

ET:RegisterEvent("WeeklyMN", {
    dbKey = "weeklyMN",
    args = {
        icon = 236681,
        type = "weekly",
        questIDs = GetWeeklyMNQuestIDs,
        questProgress = ET.StorylineQuestProgress,
        eventName = format("%s (%s)", L["Weekly Quest"], L["Midnight"]),
        location = ET.GetMapName(2537),
        label = format("%s (%s)", L["Weekly Quest"], L["MN"]),
        onClick = ET.GetWorldMapIDSetter(2537),
        onClickHelpText = L["Click to show location"],
    },
})

---------- Professions weekly ----------

-- profession icon id -> weekly quest id(s)
local professionQuests = {
    [4620669] = 93690, -- Alchemy
    [4620670] = 93691, -- Blacksmithing
    [4620672] = { 93697, 93698, 93699 }, -- Enchanting
    [4620673] = 93692, -- Engineering
    [4620675] = { 93700, 93702, 93703, 93704 }, -- Herbalism
    [4620676] = 93693, -- Inscription
    [4620677] = 93694, -- Jewelcrafting
    [4620678] = 93695, -- Leatherworking
    [4620679] = { 93705, 93706, 93708, 93709 }, -- Mining
    [4620680] = { 93710, 93711, 93714 }, -- Skinning
    [4620681] = 93696, -- Tailoring
}

-- the players professions rarely change; rebuilt on SKILL_LINES_CHANGED instead of every tick
local professionQuestCache
local function GetProfessionQuestProgress()
    if professionQuestCache then
        return professionQuestCache
    end

    local prof1, prof2 = GetProfessions()
    local quests = {}
    for _, prof in pairs({ prof1, prof2 }) do
        if prof then
            local name, iconID = GetProfessionInfo(prof)
            local questData = professionQuests[iconID]
            if questData then
                tinsert(quests, {
                    questID = questData,
                    label = GW.GetIconString(iconID, 14, 14) .. " " .. name,
                })
            end
        end
    end

    professionQuestCache = quests
    return quests
end

ET:RegisterEvent("ProfessionsWeeklyMN", {
    dbKey = "professionsWeeklyMN",
    args = {
        icon = 1392955,
        type = "weekly",
        questProgress = GetProfessionQuestProgress,
        events = {
            { "SKILL_LINES_CHANGED", function() professionQuestCache = nil end },
        },
        hasWeeklyReward = false,
        eventName = L["Professions Weekly"],
        location = ET.GetMapName(2393),
        label = L["Professions Weekly"],
        onClick = ET.GetWorldMapIDSetter(2393),
        onClickHelpText = L["Click to show location"],
    },
})

---------- Stormarion Assault ----------

ET:RegisterEvent("StormarionAssault", {
    dbKey = "stormarionAssault",
    args = {
        icon = 7431083,
        type = "loopTimer",
        runningBarColor = ET.colorPalette.green,
        questIDs = { 90962 },
        hasWeeklyReward = true,
        duration = 15 * 60,
        interval = 30 * 60,
        eventName = L["Stormarion Assault"],
        label = L["Stormarion Assault"],
        location = ET.GetMapName(2405),
        runningText = IN_PROGRESS,
        filter = ET.QuestCompletedFilter(91281),
        startTimestamp = 1772728200,
        onClick = ET.GetWorldMapIDSetter(2405),
        onClickHelpText = L["Click to show location"],
    },
})

---------- Cursed Surges ----------
-- no fixed schedule; the times come from C_EventScheduler, the locations are fixed spots on the
-- Coiled Isle (map 2512). The live POI position is not reliable for upcoming events, so the
-- static coordinates are the source of truth for waypoints.

local CURSED_SURGE_MAP = 2512

local function SetCursedSurgeWaypoint(args)
    local eventInfo = args.currentEvent or args.nextEvent
    local position = eventInfo and (eventInfo.position or args.eventCoordinates[eventInfo.areaPoiID])
    if not position then
        return
    end

    if C_Map.OpenWorldMap then
        C_Map.OpenWorldMap(CURSED_SURGE_MAP)
    elseif WorldMapFrame and WorldMapFrame.SetMapID then
        WorldMapFrame:SetMapID(CURSED_SURGE_MAP)
    end

    if C_Map.CanSetUserWaypointOnMap(CURSED_SURGE_MAP) then
        C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(CURSED_SURGE_MAP, position[1], position[2]))
        GW.Wait(0.1, C_SuperTrack.SetSuperTrackedUserWaypoint, true)
    end
end

local function GetCursedSurgePOIInfo(areaPoiID)
    if not C_AreaPoiInfo.GetAreaPOIInfo then
        return
    end

    local success, poiInfo = pcall(C_AreaPoiInfo.GetAreaPOIInfo, nil, areaPoiID)
    if success and type(poiInfo) == "table" then
        return poiInfo
    end

    success, poiInfo = pcall(C_AreaPoiInfo.GetAreaPOIInfo, CURSED_SURGE_MAP, areaPoiID)
    if success and type(poiInfo) == "table" then
        return poiInfo
    end
end

local function GetCursedSurgeName(eventInfo)
    local areaPoiID = eventInfo and eventInfo.areaPoiID
    local poiInfo = areaPoiID and GetCursedSurgePOIInfo(areaPoiID)
    if poiInfo then
        local success, poiName = pcall(function() return poiInfo.name end)
        if success and poiName then
            return poiName
        end
    end

    if C_EventScheduler.GetEventZoneName then
        local success, zoneName = pcall(C_EventScheduler.GetEventZoneName, areaPoiID)
        if success and zoneName then
            return zoneName
        end
    end

    return L["Cursed Surges"]
end

local function GetCursedSurgeEvents(args, now)
    local activeEvent, nextEvent

    if C_EventScheduler.GetScheduledEvents then
        local success, scheduledEvents = pcall(C_EventScheduler.GetScheduledEvents)
        if success and type(scheduledEvents) == "table" then
            for _, eventInfo in ipairs(scheduledEvents) do
                local areaPoiID = eventInfo and eventInfo.areaPoiID
                if areaPoiID and args.eventAreaPoiIDs[areaPoiID] then
                    local startTime = ET.SafeNumber(eventInfo.startTime)
                    local endTime = ET.SafeNumber(eventInfo.endTime)
                    if startTime then
                        if startTime <= now and endTime then
                            local eventEndTime = min(endTime, startTime + args.duration)
                            if now < eventEndTime and (not activeEvent or startTime > activeEvent.startTime) then
                                activeEvent = { areaPoiID = areaPoiID, endTime = eventEndTime, startTime = startTime }
                            end
                        end

                        if startTime > now and not nextEvent then
                            nextEvent = { areaPoiID = areaPoiID, startTime = startTime }
                        end
                    end
                end
            end
        end
    end

    if not activeEvent and C_EventScheduler.GetOngoingEvents then
        local success, ongoingEvents = pcall(C_EventScheduler.GetOngoingEvents)
        if success and type(ongoingEvents) == "table" then
            for _, eventInfo in ipairs(ongoingEvents) do
                local areaPoiID = eventInfo and eventInfo.areaPoiID
                if areaPoiID and args.eventAreaPoiIDs[areaPoiID] then
                    activeEvent = { areaPoiID = areaPoiID, endTime = now + args.duration, startTime = now }
                    break
                end
            end
        end
    end

    -- the key tells the alert whether it already announced this surge
    for _, event in pairs({ active = activeEvent, next = nextEvent }) do
        event.position = args.eventCoordinates[event.areaPoiID]
        event.key = format("%s:%s", event.areaPoiID, event.startTime)
    end

    return activeEvent, nextEvent
end

-- the scheduler answers with fresh tables of every event in the world, so it is only asked again
-- after this many seconds or once the known start or end of a surge has passed
local CURSED_SURGE_RESCAN_SECONDS = 30

local function ScanCursedSurges(args, now)
    args.scanTime = now
    args.currentEvent, args.nextEvent = nil, nil
    args.currentLocation, args.nextLocation = nil, nil

    if C_EventScheduler.HasData then
        local success, hasData = pcall(C_EventScheduler.HasData)
        if success and not hasData then
            if C_EventScheduler.RequestEvents and (not args.schedulerRequestTime or now - args.schedulerRequestTime >= 5) then
                args.schedulerRequestTime = now
                pcall(C_EventScheduler.RequestEvents)
            end
            -- no data yet: look again soon instead of waiting for the full interval
            args.scanTime = now - CURSED_SURGE_RESCAN_SECONDS + 5
            return
        end
    end

    local activeEvent, nextEvent = GetCursedSurgeEvents(args, now)
    args.currentEvent, args.nextEvent = activeEvent, nextEvent
    args.currentLocation = activeEvent and GetCursedSurgeName(activeEvent)
    args.nextLocation = nextEvent and GetCursedSurgeName(nextEvent)
end

-- replaces the fixed schedule of the loopTimer type; runs from the 0.3s ticker, but only the
-- time left is worked out on every call, from the surges found by the last scan
local function UpdateCursedSurges(self)
    local args = self.args
    local now = GetServerTime()
    if args.lastScanTime == now then
        return
    end
    args.lastScanTime = now

    local boundary = args.currentEvent and args.currentEvent.endTime or args.nextEvent and args.nextEvent.startTime
    if not args.scanTime or now - args.scanTime >= CURSED_SURGE_RESCAN_SECONDS or (boundary and now >= boundary) then
        ScanCursedSurges(args, now)
    end

    local activeEvent, nextEvent = args.currentEvent, args.nextEvent
    if activeEvent then
        self.isRunning = true
        self.isCompleted = false
        self.timeLeft = activeEvent.endTime - now
        self.timeOver = args.duration - self.timeLeft
        self.nextEventIndex = activeEvent.key
        self.nextEventTimestamp = nextEvent and nextEvent.startTime
    elseif nextEvent then
        self.isRunning = false
        self.isCompleted = false
        self.timeLeft = nextEvent.startTime - now
        self.timeOver = 0
        self.nextEventIndex = nextEvent.key
        self.nextEventTimestamp = nextEvent.startTime
    else
        self.isRunning = false
        self.isCompleted = false
        self.timeLeft = 0
        self.timeOver = 0
        self.nextEventIndex = nil
        self.nextEventTimestamp = nil
    end
end

ET:RegisterEvent("CursedSurges", {
    dbKey = "cursedSurges",
    args = {
        icon = [[Interface\Icons\Spell_Nature_CorrosiveBreath]],
        type = "loopTimer",
        runningBarColor = ET.colorPalette.purple,
        dateUpdater = UpdateCursedSurges,
        eventAreaPoiIDs = {
            [8936] = true,
            [8937] = true,
            [8938] = true,
            [8939] = true,
            [8940] = true,
        },
        eventCoordinates = {
            [8936] = { 0.264, 0.649 },
            [8937] = { 0.671, 0.775 },
            [8938] = { 0.457, 0.296 },
            [8939] = { 0.705, 0.327 },
            [8940] = { 0.467, 0.628 },
        },
        duration = 5 * 60,
        interval = 45 * 60,
        eventName = L["Cursed Surges"],
        label = L["Cursed Surges"],
        location = ET.GetMapName(CURSED_SURGE_MAP),
        runningText = IN_PROGRESS,
        runningTextUpdater = function(args)
            return args.currentLocation or args.runningText
        end,
        onClick = SetCursedSurgeWaypoint,
        onClickHelpText = L["Click to show location"],
    },
})
