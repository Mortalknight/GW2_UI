---@class GW2
local GW = select(2, ...)

-- the members of a premade group search result, by role
local function AddGroupMembers(tooltip, resultID)
    local members = GW.settings.tooltip.unit.premadeGroupInfo and GW.LFGPI.GetPartyInfo(resultID)
    if not members then
        return
    end
    tooltip:AddLine(" ")
    tooltip:AddLine(MEMBERS_COLON)
    for _, role in ipairs(GW.LFGPI.GetRoleOrder()) do
        for _, line in ipairs(members[role]) do
            tooltip:AddLine(line)
        end
    end
    -- beside the group finder, the member list gets long
    tooltip:ClearAllPoints()
    tooltip:SetPoint("TOPLEFT", LFGListFrame, "TOPRIGHT", 10, 0)
    tooltip:Show()
end

GW.RegisterTooltipModule({
    onLoad = function()
        if LFGListUtil_SetSearchEntryTooltip and GW.LFGPI and not GW.ShouldBlockIncompatibleAddon("LfgInfo") then
            hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", AddGroupMembers)
        end
    end,
})
