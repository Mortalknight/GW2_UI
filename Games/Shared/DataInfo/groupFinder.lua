---@class GW2
local GW = select(2, ...)
local L = GW.L

-- dungeon finder micro button, two sections named like the group finder tabs:
-- * dungeons and raids: running dungeon finder queues (every client), keystone and mythic+ rating (retail)
-- * pvp: running battleground queues (every client), rated brackets (retail; the classics show them on the pvp button)

local PVE_CATEGORIES = {"LE_LFG_CATEGORY_LFD", "LE_LFG_CATEGORY_LFR", "LE_LFG_CATEGORY_RF", "LE_LFG_CATEGORY_SCENARIO", "LE_LFG_CATEGORY_FLEXRAID"}
local PVP_CATEGORIES = {"LE_LFG_CATEGORY_WORLDPVP", "LE_LFG_CATEGORY_BATTLEFIELD"}

local function AddQueueLine(name, waited, estimated)
    local right = waited and waited > 0 and SecondsToTime(waited) or ""
    if estimated and estimated > 0 then
        right = format("%s |cffaaaaaa(~%s)|r", right, SecondsToTime(estimated))
    end
    GameTooltip:AddDoubleLine(name, right, 1, 1, 1, 1, 1, 1)
end

-- section header, written once before the first line of the section
local function SectionHeader(state, title)
    if state.open then return end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(title, 1, 0.82, 0)
    state.open = true
end

local function AddLfgQueueLines(state, title, categoryNames)
    if not (GetLFGMode and GetLFGQueueStats) then return end
    for _, name in ipairs(categoryNames) do
        local category = _G[name]
        if category and GetLFGMode(category) == "queued" then
            local hasData, _, _, _, _, _, _, _, _, _, instanceName, averageWait, _, _, _, myWait, queuedTime = GetLFGQueueStats(category)
            SectionHeader(state, title)
            local waited = queuedTime and (GetTime() - queuedTime) or 0
            AddQueueLine(hasData and instanceName or LFG_TITLE, waited, (myWait and myWait > 0) and myWait or averageWait)
        end
    end
end

local function AddBattlefieldQueueLines(state, title)
    if not (GetBattlefieldStatus and GetMaxBattlefieldID) then return end
    for i = 1, GetMaxBattlefieldID() do
        local status, mapName = GetBattlefieldStatus(i)
        if status == "queued" or status == "confirm" then
            SectionHeader(state, title)
            local waited = GetBattlefieldTimeWaited and (GetBattlefieldTimeWaited(i) or 0) / 1000 or 0
            local estimated = GetBattlefieldEstimatedWaitTime and (GetBattlefieldEstimatedWaitTime(i) or 0) / 1000 or 0
            local name = mapName or BATTLEGROUND
            if status == "confirm" then
                name = name .. " |cff00ff00(" .. (BATTLEFIELD_QUEUE_CONFIRM or READY) .. ")|r"
            end
            AddQueueLine(name, waited, estimated)
        end
    end
end

local function AddMythicPlusLines(state, title)
    if not (C_MythicPlus and C_ChallengeMode) then return end

    local level = C_MythicPlus.GetOwnedKeystoneLevel and C_MythicPlus.GetOwnedKeystoneLevel()
    local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID and C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    if level and level > 0 and mapID then
        local mapName = C_ChallengeMode.GetMapUIInfo(mapID)
        SectionHeader(state, title)
        GameTooltip:AddDoubleLine(L["Keystone"], format("+%d %s", level, mapName or ""), 0.8, 0.8, 0.8, 1, 1, 1)
    end

    local score = C_ChallengeMode.GetOverallDungeonScore and C_ChallengeMode.GetOverallDungeonScore()
    if score and score > 0 then
        SectionHeader(state, title)
        local color = C_ChallengeMode.GetDungeonScoreRarityColor and C_ChallengeMode.GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
        GameTooltip:AddDoubleLine(DUNGEON_SCORE or L["Mythic+"], color:WrapTextInColorCode(tostring(score)), 0.8, 0.8, 0.8)
    end
end

local function GroupFinder_OnEnter(self)
    if not GW.EnsureMicroMenuTooltip(self) then return end

    local pve = {}
    AddLfgQueueLines(pve, DUNGEONS_BUTTON, PVE_CATEGORIES)
    if GW.Retail then
        AddMythicPlusLines(pve, DUNGEONS_BUTTON)
    end

    local pvp = {}
    AddLfgQueueLines(pvp, PVP, PVP_CATEGORIES)
    AddBattlefieldQueueLines(pvp, PVP)
    if GW.Retail then
        GW.AddRatedPvpTooltipLines(function() SectionHeader(pvp, PVP) end)
    end

    GameTooltip:Show()
end
GW.GroupFinder_OnEnter = GroupFinder_OnEnter
