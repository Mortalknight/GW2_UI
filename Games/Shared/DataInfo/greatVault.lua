---@class GW2
local GW = select(2, ...)

local function FormatActivityProgress(info)
    local thresholdType = Enum.WeeklyRewardChestThresholdType
    if info.progress >= info.threshold then
        local text
        if info.type == thresholdType.Raid then
            text = DifficultyUtil.GetDifficultyName(info.level)
        elseif info.type == thresholdType.Activities then
            local difficultyID = C_WeeklyRewards.GetDifficultyIDForActivityTier(info.activityTierID)
            if difficultyID == DifficultyUtil.ID.DungeonHeroic then
                text = WEEKLY_REWARDS_HEROIC
            else
                text = WEEKLY_REWARDS_MYTHIC:format(info.level)
            end
        elseif info.type == thresholdType.World then
            text = GREAT_VAULT_WORLD_TIER:format(info.level)
        end
        return GREEN_FONT_COLOR:WrapTextInColorCode(text or GENERIC_FRACTION_STRING:format(info.progress, info.threshold))
    end

    local color = info.progress > 0 and NORMAL_FONT_COLOR or DISABLED_FONT_COLOR
    return color:WrapTextInColorCode(GENERIC_FRACTION_STRING:format(info.progress, info.threshold))
end

local function SortActivities(a, b)
    return a.index < b.index
end

local function GreatVault_OnEnter(self)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    -- title and the "collect your rewards" hint, same as the default micro button tooltip
    GameTooltip_SetTitle(GameTooltip, self.tooltipText)
    if not self:IsEnabled() then
        if self.minLevel then
            GameTooltip:AddLine(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, self.minLevel), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        elseif self.disabledTooltip then
            local disabledTooltipText = GetValueOrCallFunction(self, "disabledTooltip")
            GameTooltip:AddLine(disabledTooltipText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        end
    end

    if C_WeeklyRewards and Enum.WeeklyRewardChestThresholdType then
        local thresholdType = Enum.WeeklyRewardChestThresholdType
        local rows = {
            {type = thresholdType.Raid, label = RAIDS},
            {type = thresholdType.Activities, label = DUNGEONS},
            {type = thresholdType.World, label = WORLD},
        }

        local added = false
        for _, row in ipairs(rows) do
            if row.type then
                local activities = C_WeeklyRewards.GetActivities(row.type)
                if activities and #activities > 0 then
                    table.sort(activities, SortActivities)
                    local parts = {}
                    for i, info in ipairs(activities) do
                        parts[i] = FormatActivityProgress(info)
                    end
                    if not added then
                        GameTooltip:AddLine(" ")
                        added = true
                    end
                    GameTooltip:AddDoubleLine(row.label, table.concat(parts, "  "), 0.8, 0.8, 0.8)
                end
            end
        end
    end

    GameTooltip:Show()
end
GW.GreatVault_OnEnter = GreatVault_OnEnter
