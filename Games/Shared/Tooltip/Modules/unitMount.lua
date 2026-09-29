---@class GW2
local GW = select(2, ...)
local Tooltip = GW.Tooltip

-- the mount a player rides, ctrl adds where it comes from
local function AddMount(tooltip, unit)
    local index = 1
    local aura = C_UnitAuras.GetBuffDataByIndex(unit, index, "HELPFUL")
    while aura and GW.NotSecretValue(aura.spellId) do
        local source = Tooltip.GetMountSource(aura.spellId)
        if source then
            tooltip:AddDoubleLine(MOUNT .. ":", aura.name, nil, nil, nil, 1, 1, 1)
            if IsControlKeyDown() then
                -- each source line reads "|cff..Label:|r value"
                for line in gmatch(gsub(source, "|n", "\n"), "[^\n]+") do
                    local label, value = strmatch(line, "(.-|r)%s?(.+)")
                    if label then
                        tooltip:AddDoubleLine(label, value, nil, nil, nil, 1, 1, 1)
                    else
                        tooltip:AddDoubleLine(FROM, gsub(line, "|c%x%x%x%x%x%x%x%x", ""), nil, nil, nil, 1, 1, 1)
                    end
                end
            end
            return
        end
        index = index + 1
        aura = C_UnitAuras.GetBuffDataByIndex(unit, index, "HELPFUL")
    end
end

-- other players out of combat; shift shows the item level instead
local function OnUnitTooltip(tooltip, data)
    if tooltip ~= GameTooltip or not GW.settings.tooltip.unit.mount or IsShiftKeyDown() or InCombatLockdown() or GW.IsRestrictedInstance() then
        return
    end
    local unit = Tooltip.GetUnit(tooltip, data)
    if unit and unit ~= "player" and UnitIsPlayer(unit) then
        AddMount(tooltip, unit)
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        if C_MountJournal then
            Tooltip.OnTooltipData("Unit", OnUnitTooltip)
        end
    end,
})
