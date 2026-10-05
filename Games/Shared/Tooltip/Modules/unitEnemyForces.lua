---@class GW2
local GW = select(2, ...)
local L = GW.L
local Tooltip = GW.Tooltip

-- how much of the enemy forces a mob gives in mythic+
local function AddEnemyForces(tooltip, data)
    if tooltip ~= GameTooltip or not GW.settings.tooltip.unit.enemyForces or not C_ChallengeMode.IsChallengeModeActive() then
        return
    end
    local unit = Tooltip.GetUnit(tooltip, data)
    if not unit then return end
    local isPlayer = UnitIsPlayer(unit)
    if GW.NotSecretValue(isPlayer) and isPlayer then return end

    local value, _, percent = C_ScenarioInfo.GetUnitCriteriaProgressValues(unit)
    if GW.NotSecretValue(value) and not (value and value > 0) then return end
    if GW.NotSecretValue(percent) and not percent then return end
    tooltip:AddDoubleLine(L["Enemy Forces"], "+" .. percent .. "%", nil, nil, nil, 1, 1, 1)
end

GW.RegisterTooltipModule({
    onLoad = function()
        if C_ScenarioInfo and C_ScenarioInfo.GetUnitCriteriaProgressValues and C_ChallengeMode then
            Tooltip.OnTooltipData("Unit", AddEnemyForces)
        end
    end,
})
