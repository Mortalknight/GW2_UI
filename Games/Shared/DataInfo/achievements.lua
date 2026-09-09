---@class GW2
local GW = select(2, ...)

-- achievement micro button: player and guild achievement points (retail, mists and wrath)
local function Achievements_OnEnter(self)
    if not GetTotalAchievementPoints or not GW.EnsureMicroMenuTooltip(self) then return end

    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(ACHIEVEMENT_POINTS or ACHIEVEMENTS, BreakUpLargeNumbers(GetTotalAchievementPoints() or 0), 0.8, 0.8, 0.8, 1, 1, 1)
    if (GW.Retail or GW.Mists) and IsInGuild() then
        GameTooltip:AddDoubleLine(GUILD_ACHIEVEMENTS or GUILD, BreakUpLargeNumbers(GetTotalAchievementPoints(true) or 0), 0.8, 0.8, 0.8, 1, 1, 1)
    end
    GameTooltip:Show()
end
GW.Achievements_OnEnter = Achievements_OnEnter
