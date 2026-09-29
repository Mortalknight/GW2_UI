---@class GW2
local GW = select(2, ...)
local Tooltip = GW.Tooltip

-- where a mount comes from, and with the id modifier the spell id and who cast the aura
local function AddAuraInfo(tooltip, aura)
    local mountSource = Tooltip.GetMountSource(aura.spellId)
    if mountSource then
        tooltip:AddLine(" ")
        tooltip:AddLine(mountSource, 1, 1, 1)
    end

    if Tooltip.IsModifierDown() and GW.NotSecretValue(aura.spellId) then
        if mountSource then
            tooltip:AddLine(" ")
        end
        local caster = GW.NotSecretValue(aura.sourceUnit) and aura.sourceUnit
        if caster then
            local _, class = UnitClass(caster)
            local color = GW.GWGetClassColor(class, GW.settings.tooltip.unit.classColor)
            tooltip:AddDoubleLine(Tooltip.FormatID(aura.spellId), color:WrapTextInColorCode(UnitName(caster) or UNKNOWN))
        else
            tooltip:AddLine(Tooltip.FormatID(aura.spellId))
        end
    end
    tooltip:Show()
end

local function IsAuraTooltipReady(tooltip)
    return not tooltip:IsForbidden() and tooltip:NumLines() > 0 and not GW.AreAurasSecret()
end

local function OnSetAuraByIndex(tooltip, unit, index, filter)
    if IsAuraTooltipReady(tooltip) then
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
        if aura then
            AddAuraInfo(tooltip, aura)
        end
    end
end

-- the cooldown viewer passes secret instance ids
local function OnSetAuraByInstanceID(tooltip, unit, auraInstanceID)
    if GW.IsSecretValue(unit) or GW.IsSecretValue(auraInstanceID) or not IsAuraTooltipReady(tooltip) then
        return
    end
    local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
    if aura then
        AddAuraInfo(tooltip, aura)
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        for _, name in ipairs({"SetUnitAura", "SetUnitBuff", "SetUnitDebuff"}) do
            hooksecurefunc(GameTooltip, name, OnSetAuraByIndex)
        end
        for _, name in ipairs({"SetUnitAuraByAuraInstanceID", "SetUnitBuffByAuraInstanceID", "SetUnitDebuffByAuraInstanceID"}) do
            if GameTooltip[name] then
                hooksecurefunc(GameTooltip, name, OnSetAuraByInstanceID)
            end
        end
    end,
})
