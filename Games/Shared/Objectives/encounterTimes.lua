---@class GW2
local GW = select(2, ...)
local L = GW.L

-- boss times per character: mythic+ splits since the key started, fight times in dungeons and raids,
-- each compared to the best time of that boss on this instance, difficulty and key level
local SETTING_BY_KIND = {mplus = "mythicPlus", party = "dungeon", raid = "raid"}
local COLOR_TIME = GW.Colors.SkinColors.Disabled
local COLOR_FASTER = GW.Colors.SkinColors.Positive
local COLOR_SLOWER = GW.Colors.SkinColors.Negative
local COLOR_HIGHLIGHT = GW.Colors.SkinColors.QuestGold
local CHAT_TEXT = {
    fight = L["%s defeated after %s."],
    split = L["%s defeated at %s in the key."],
    forces = L["%s complete at %s."],
    total = L["%s completed in %s."],
}

local run = {times = {}, fightStart = {}}

-- precise adds hundredths, only for fight and completion times, the key timer has whole seconds
local function FormatTime(seconds, precise)
    local units = math.floor(seconds * (precise and 100 or 1) + 0.5)
    local whole = precise and math.floor(units / 100) or units
    local text
    if whole >= 3600 then
        text = format("%d:%02d:%02d", whole / 3600, (whole % 3600) / 60, whole % 60)
    else
        text = format("%02d:%02d", whole / 60, whole % 60)
    end
    return precise and format("%s.%02d", text, units % 100) or text
end
GW.FormatEncounterTime = FormatTime

local function FormatEntry(entry)
    local text = COLOR_TIME:WrapTextInColorCode(FormatTime(entry.time))
    if entry.best then
        local delta = entry.time - entry.best
        local sign = delta > 0 and "+" or "-"
        text = text .. " " .. (delta > 0 and COLOR_SLOWER or COLOR_FASTER):WrapTextInColorCode("(" .. sign .. FormatTime(math.abs(delta)) .. ")")
    end
    return text
end

-- key, kind and the difficulty shown in the chat ("Normal", "+12")
local function GetRunKey(instanceMapID)
    if C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive and C_ChallengeMode.IsChallengeModeActive() then
       local level = C_ChallengeMode.GetActiveKeystoneInfo and C_ChallengeMode.GetActiveKeystoneInfo() or 0
        local label = level > 0 and "+" .. level or GetDifficultyInfo(select(3, GetInstanceInfo()))
        return "mplus:" .. C_ChallengeMode.GetActiveChallengeMapID() .. ":" .. level, "mplus", label
    end
    -- a completed key stays the run until the instance is left
    if run.kind == "mplus" and run.instanceMapID == instanceMapID then
        return run.key, run.kind, run.difficulty
    end
    local _, instanceType, difficultyID = GetInstanceInfo()
    if instanceType == "party" or instanceType == "raid" then
        return instanceType .. ":" .. instanceMapID .. ":" .. difficultyID, instanceType, GetDifficultyInfo(difficultyID)
    end
end

-- the current run lives in the character data, so a reload keeps its times and a running fight
local function NewRun(key, kind, difficulty, instanceMapID)
    run = {key = key, kind = kind, difficulty = difficulty, instanceMapID = instanceMapID, times = {}, fightStart = {}}
    GW.private.encounterRun = run
end

local function UpdateRun()
    local instanceMapID = select(8, GetInstanceInfo())
    local key, kind, difficulty = GetRunKey(instanceMapID)
    if key ~= run.key then
        NewRun(key, kind, difficulty, instanceMapID)
    end
    run.difficulty = difficulty
    return key
end

local function GetKeyElapsed()
    for _, timerID in ipairs({GetWorldElapsedTimers()}) do
        local _, elapsed, timerType = GetWorldElapsedTime(timerID)
        if timerType == Enum.WorldElapsedTimerTypes.ChallengeMode then
            return elapsed
        end
    end
end

function GW.RefreshEncounterTimes()
    if GwQuesttrackerContainerScenario then
        GwQuesttrackerContainerScenario:QueueUpdateLayout()
    end
    if GW.UpdateBossTimesPage then
        GW.UpdateBossTimesPage()
    end
end

-- per value: name, best time and its date, last time and the number of kills; returns the best before this one
local function StoreTime(id, seconds, name)
    GW.private.encounterTimes = GW.private.encounterTimes or {}
    local store = GW.private.encounterTimes[run.key] or {}
    GW.private.encounterTimes[run.key] = store

    local data = store[id]
    if type(data) ~= "table" then
        data = {best = data, kills = 0}
        store[id] = data
    end
    data.name = name or data.name
    data.firstDate = data.firstDate or time()
    local previousBest = data.best
    if not previousBest or seconds < previousBest then
        data.best = seconds
        data.bestDate = time()
    end
    data.last = seconds
    data.kills = data.kills + 1
    return previousBest
end

local function PostToChat(entry, chatType)
    local precise = chatType == "fight" or chatType == "total"
    local text = CHAT_TEXT[chatType]:format(entry.name, COLOR_HIGHLIGHT:WrapTextInColorCode(FormatTime(entry.time, precise)))
    if not entry.best then
        local firstText = (chatType == "fight" or chatType == "split") and L["First kill on %s!"] or L["First time on %s!"]
        text = text .. " " .. firstText:format(COLOR_HIGHLIGHT:WrapTextInColorCode(run.difficulty or ""))
    elseif entry.time < entry.best then
        text = text .. " " .. L["New best time, %s faster!"]:format(COLOR_FASTER:WrapTextInColorCode(FormatTime(entry.best - entry.time, precise)))
    elseif entry.time > entry.best then
        text = text .. " " .. L["%s slower than your best time of %s."]:format(COLOR_SLOWER:WrapTextInColorCode(FormatTime(entry.time - entry.best, precise)), COLOR_HIGHLIGHT:WrapTextInColorCode(FormatTime(entry.best, precise)))
    else
        text = text .. " " .. L["Same time as your best."]
    end
    GW.Notice(text)
end

local function Record(id, seconds, label, chatType, creatureIDs)
    if not seconds then return end
    local entry = {time = seconds, best = StoreTime(id, seconds, label), name = label, creatureIDs = creatureIDs}
    run.times[id] = entry

    if GW.settings.objectives.encounterTimes.chat then
        PostToChat(entry, chatType)
    end
    GW.RefreshEncounterTimes()
end

local function RecordForces()
    if run.kind ~= "mplus" or run.times.forces then return end
    local _, _, numCriteria = C_Scenario.GetStepInfo()
    for index = 1, numCriteria or 0 do
        local info = C_ScenarioInfo.GetCriteriaInfo(index)
        if info and info.isWeightedProgress and info.completed then
            Record("forces", GetKeyElapsed(), L["Enemy Forces"], "forces")
            return
        end
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, isReloadingUi = ...
        if isInitialLogin or isReloadingUi then
            run = GW.private.encounterRun or run
            run.fightStart = run.fightStart or {}
        else
            NewRun()
        end
        UpdateRun()
        GW.RefreshEncounterTimes()
        return
    end
    if not UpdateRun() then return end

    if event == "ENCOUNTER_START" then
        local encounterID = ...
        run.fightStart[encounterID] = GetTime()
    elseif event == "ENCOUNTER_END" then
        local encounterID, encounterName, _, _, success, unitStatus = ...
        -- GetTime keeps running through a reload, so a fight that started before one still counts
        local fightTime = run.fightStart[encounterID] and GetTime() - run.fightStart[encounterID]
        run.fightStart[encounterID] = nil
        if success ~= 1 then return end
        local creatureIDs = {}
        for _, unitInfo in ipairs(unitStatus or {}) do
            if unitInfo.creatureID then
                creatureIDs[unitInfo.creatureID] = true
            end
        end
        if run.kind == "mplus" then
            -- the fight time is only stored for later stats, the split is what the tracker shows
            if fightTime then
                StoreTime("fight:" .. encounterID, fightTime, encounterName)
            end
            Record(encounterID, GetKeyElapsed(), encounterName, "split", creatureIDs)
        else
            Record(encounterID, fightTime, encounterName, "fight", creatureIDs)
        end
    elseif event == "SCENARIO_CRITERIA_UPDATE" then
        RecordForces()
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        local info = C_ChallengeMode.GetChallengeCompletionInfo()
        if info and info.time and info.time > 0 and not info.practiceRun then
            local name = C_ChallengeMode.GetMapUIInfo(info.mapChallengeModeID) or ""
            Record("total", info.time / 1000, name .. (info.level > 0 and " +" .. info.level or ""), "total")
        end
    end
end)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("ENCOUNTER_END")
if C_EventUtils.IsEventValid("CHALLENGE_MODE_COMPLETED") then
    frame:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
end

-- the time of a boss row in the scenario block, nil when there is none to show
function GW.GetEncounterTimeText(criteriaInfo)
    local setting = SETTING_BY_KIND[run.kind]
    if not setting or not GW.settings.objectives.encounterTimes[setting] then return end
    if criteriaInfo.isWeightedProgress then
        return run.times.forces and FormatEntry(run.times.forces)
    end
    -- newer dungeons carry the encounter id, older ones the creature id of the boss
    local entry = run.times[criteriaInfo.assetID]
    if not entry then
        for id, candidate in pairs(run.times) do
            if type(id) == "number" and ((candidate.creatureIDs and candidate.creatureIDs[criteriaInfo.assetID])
                or (criteriaInfo.description and criteriaInfo.description:find(candidate.name, 1, true))) then
                entry = candidate
                break
            end
        end
    end
    return entry and FormatEntry(entry)
end

function GW.SetObjectiveTimeText(row, text)
    if not row.gwTimeText then
        if not text then return end
        row.gwTimeText = row:CreateFontString(nil, "OVERLAY")
        row.gwTimeText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        row.gwTimeText:SetJustifyH("RIGHT")
        row.gwTimeText:SetPoint("TOPRIGHT", row.ObjectiveText, "TOPRIGHT", 0, 0)
    end
    row.gwTimeText:SetText(text or "")
end
