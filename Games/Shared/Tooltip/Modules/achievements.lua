---@class GW2
local GW = select(2, ...)

-- an achievement link somebody else posted: who earned it, and whether the player has it too
local function OnHyperlink(tooltip, link)
    if tooltip:IsForbidden() or GW.IsSecretValue(link) or type(link) ~= "string" then
        return
    end
    local achievementID, guid = strmatch(link, "achievement:(%d+):([^:]+)")
    if not achievementID or guid == GW.myguid then
        return
    end

    local _, _, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)
    if not (completed and earnedBy) then
        return
    end
    tooltip:AddLine(" ")
    if earnedBy ~= "" then
        tooltip:AddLine(format(ACHIEVEMENT_EARNED_BY, earnedBy))
    end
    if not wasEarnedByMe then
        tooltip:AddLine(format(ACHIEVEMENT_NOT_COMPLETED_BY, GW.myname))
    elseif earnedBy ~= GW.myname then
        tooltip:AddLine(format(ACHIEVEMENT_COMPLETED_BY, GW.myname))
    end
    tooltip:Show()
end

GW.RegisterTooltipModule({
    onLoad = function()
        hooksecurefunc(GameTooltip, "SetHyperlink", OnHyperlink)
        hooksecurefunc(ItemRefTooltip, "SetHyperlink", OnHyperlink)
    end,
})
