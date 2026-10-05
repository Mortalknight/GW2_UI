---@class GW2
local GW = select(2, ...)
local L = GW.L
local Tooltip = GW.Tooltip

-- secret units only let the engine resolve their class color
local function GetClassColor(unit)
    local _, class = UnitClass(unit)
    if GW.IsSecretUnit(unit) then
        return C_ClassColor.GetClassColor(class) or RAID_CLASS_COLORS.PRIEST
    end
    return GW.GWGetClassColor(class, GW.settings.tooltip.unit.classColor)
end

local function AddTarget(tooltip, unit)
    local target = unit .. "target"
    if unit == "player" or not UnitExists(target) then
        return
    end
    local color
    if GW.IsSecretUnit(target) or UnitIsPlayer(target) and not (UnitHasVehicleUI and UnitHasVehicleUI(target)) then
        color = GetClassColor(target)
    else
        local reaction = UnitReaction(target, "player")
        color = GW.NotSecretValue(reaction) and GW.Colors.FactionBarColors[reaction] or RAID_CLASS_COLORS.PRIEST
    end
    tooltip:AddDoubleLine(TARGET .. ":", color:WrapTextInColorCode(GW.GetUnitDisplayName(target) or UNKNOWN))
end

-- the group members who have the unit targeted
local function AddTargetedBy(tooltip, unit)
    if not IsInGroup() then
        return
    end
    local prefix = IsInRaid() and "raid" or "party"
    local names, count = "", 0
    for i = 1, GetNumGroupMembers() do
        local member = prefix .. i
        local targetsUnit = GW.UnitNotUnit(member, "player") and GW.UnitIsUnit(member .. "target", unit)
        if GW.NotSecretValue(targetsUnit) and targetsUnit then
            -- names can be secret, those only concatenate
            local name = GetClassColor(member):WrapTextInColorCode(GW.GetUnitDisplayName(member) or UNKNOWN)
            names = count == 0 and name or names .. ", " .. name
            count = count + 1
        end
    end
    if count > 0 then
        tooltip:AddLine(L["Targeted by:"] .. " (|cffffffff" .. count .. "|r): " .. names, nil, nil, nil, true)
    end
end

-- shift and ctrl views show other things instead
local function OnUnitTooltip(tooltip, data)
    if tooltip ~= GameTooltip or not GW.settings.tooltip.unit.targetInfo or IsShiftKeyDown() or IsControlKeyDown() then
        return
    end
    local unit = Tooltip.GetUnit(tooltip, data)
    if unit then
        AddTarget(tooltip, unit)
        AddTargetedBy(tooltip, unit)
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        Tooltip.OnTooltipData("Unit", OnUnitTooltip)
    end,
})
