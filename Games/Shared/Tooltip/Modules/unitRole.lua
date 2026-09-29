---@class GW2
local GW = select(2, ...)
local Tooltip = GW.Tooltip

local ROLES = {
    TANK = {label = TANK, color = CreateColor(0.51, 0.67, 0.9)},
    HEALER = {label = HEALER, color = CreateColor(0, 1, 0.59)},
    DAMAGER = {label = DAMAGER, color = CreateColor(0.77, 0.12, 0.24)},
}
local RAID_ROLES = {
    MAINTANK = "|TInterface/AddOns/GW2_UI/textures/party/icon-maintank.png:0:0:0:-3:64:64:4:60:4:60|t " .. MAINTANK,
    MAINASSIST = "|TInterface/AddOns/GW2_UI/textures/party/icon-mainassist.png:0:0:0:-1:64:64:4:60:4:60|t " .. MAIN_ASSIST,
}
local LEADER_ICON = "|TInterface/AddOns/GW2_UI/textures/party/icon-groupleader.png:0:0:0:-2:64:64:4:60:4:60|t "
local ASSIST_ICON = "|TInterface/AddOns/GW2_UI/textures/party/icon-assist.png:0:0:0:-2:64:64:4:60:4:60|t "

local function Plain(value)
    return GW.NotSecretValue(value) and value or nil
end

-- the group role, the raid role, and whether the unit leads or assists the group
local function AddRole(tooltip, unit)
    local raidIndex, inParty = Plain(UnitInRaid(unit)), Plain(UnitInParty(unit))
    local roleName = Plain(UnitGroupRolesAssigned(unit))
    local role = ROLES[roleName]
    if not (raidIndex or inParty) or not role then
        return
    end

    local text = GW.nameRoleIcon[roleName] .. role.label
    local raidRole = raidIndex and RAID_ROLES[Plain(select(10, GetRaidRosterInfo(raidIndex)))]
    if raidRole then
        text = text .. " (" .. raidRole .. ")"
    end
    local r, g, b = role.color:GetRGB()
    tooltip:AddDoubleLine(ROLE .. ":", text, nil, nil, nil, r, g, b)

    if Plain(UnitIsGroupLeader(unit)) then
        tooltip:AddDoubleLine(" ", LEADER_ICON .. (IsInRaid() and RAID_LEADER or PARTY_LEADER), nil, nil, nil, r, g, b)
    elseif Plain(UnitIsGroupAssistant(unit)) then
        tooltip:AddDoubleLine(" ", ASSIST_ICON .. RAID_ASSISTANT, nil, nil, nil, r, g, b)
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        Tooltip.OnTooltipData("Unit", function(tooltip, data)
            if tooltip == GameTooltip and GW.settings.tooltip.unit.role and GW.allowRoles then
                local unit = Tooltip.GetUnit(tooltip, data)
                if unit then
                    AddRole(tooltip, unit)
                end
            end
        end)
    end,
})
