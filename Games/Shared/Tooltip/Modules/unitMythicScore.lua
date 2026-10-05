---@class GW2
local GW = select(2, ...)
local Tooltip = GW.Tooltip

-- "Mythic+ Rating: %s" without the value
local SCORE_LABEL = strmatch(DUNGEON_SCORE_LEADER or "", "^(.-):") or DUNGEON_SCORE_LEADER

-- the mythic+ rating of the season, in its rarity color; not in combat, the summary is not cheap
local function AddMythicScore(tooltip, data)
    if tooltip ~= GameTooltip or InCombatLockdown() or not GW.settings.tooltip.unit.dungeonScore then
        return
    end
    local unit = Tooltip.GetUnit(tooltip, data)
    local summary = unit and C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
    local score = summary and summary.currentSeasonScore
    if GW.NotSecretValue(score) and score and score > 0 then
        local color = C_ChallengeMode.GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
        tooltip:AddDoubleLine(SCORE_LABEL, GW.GetLocalizedNumber(score), nil, nil, nil, color:GetRGB())

        if GW.settings.tooltip.unit.dungeonBestRun and summary and summary.runs then
            local bestRun, dungeonName = 0, ""
            for _, run in ipairs(summary.runs) do
                local level = GW.NotSecretValue(run.finishedSuccess) and run.finishedSuccess and run.bestRunLevel
                if GW.NotSecretValue(level) and level and level > bestRun then
                    bestRun = level
                    dungeonName = run.challengeModeID and C_ChallengeMode.GetMapUIInfo(run.challengeModeID) or ""
                end
            end
            if bestRun > 0 then
                tooltip:AddDoubleLine(LFG_LIST_BEST_RUN, "+" .. bestRun .. " " .. dungeonName, nil, nil, nil, color:GetRGB())
            end
        end
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        if C_PlayerInfo.GetPlayerMythicPlusRatingSummary and C_ChallengeMode then
            Tooltip.OnTooltipData("Unit", AddMythicScore)
        end
    end,
})
