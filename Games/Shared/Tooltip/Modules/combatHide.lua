---@class GW2
local GW = select(2, ...)
local Tooltip = GW.Tooltip

-- the unit tooltips the setting hides in combat, by reaction: hostile, neutral, friendly or all
local function ShouldHide(tooltip)
    local settings = GW.settings.tooltip.hideInCombat
    if not settings.enabled or Tooltip.IsModifierDown(settings.overrideKey) then
        return false
    end
    local unit = select(2, tooltip:GetUnit())
    local reaction = GW.NotSecretValue(unit) and unit and UnitReaction("player", unit)
    if GW.IsSecretValue(reaction) or not reaction then
        return false
    end
    local units = settings.units
    return units == "ALL"
        or strfind(units, "HOSTILE", 1, true) and reaction <= 3
        or strfind(units, "NEUTRAL", 1, true) and reaction == 4
        or strfind(units, "FRIENDLY", 1, true) and reaction >= 5
        or false
end

-- what hovering would have shown: the world unit at the default anchor (over the world there is no
-- mouse focus at all), a unit frame through its own handler
local function ShowMouseoverTooltip()
    if not Tooltip.IsModifierDown(GW.settings.tooltip.hideInCombat.overrideKey) or not UnitExists("mouseover") then
        return
    end
    local focus = GetMouseFoci()[1]
    if not focus or focus == WorldFrame then
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit("mouseover")
        GameTooltip:Show()
    elseif focus:GetScript("OnEnter") then
        focus:GetScript("OnEnter")(focus)
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        GameTooltip:HookScript("OnShow", function(tooltip)
            if InCombatLockdown() and ShouldHide(tooltip) then
                tooltip:Hide()
            end
        end)
        -- a tooltip that was open when the fight started, and the override key pressed or let go
        -- while the mouse rests on a unit
        local watcher = CreateFrame("Frame")
        watcher:RegisterEvent("PLAYER_REGEN_DISABLED")
        watcher:RegisterEvent("MODIFIER_STATE_CHANGED")
        watcher:SetScript("OnEvent", function(_, event)
            if GameTooltip:IsForbidden() then
                return
            end
            if GameTooltip:IsShown() then
                if ShouldHide(GameTooltip) then
                    GameTooltip:Hide()
                end
            elseif event == "MODIFIER_STATE_CHANGED" and InCombatLockdown() and GW.settings.tooltip.hideInCombat.enabled then
                ShowMouseoverTooltip()
            end
        end)
    end,
})
