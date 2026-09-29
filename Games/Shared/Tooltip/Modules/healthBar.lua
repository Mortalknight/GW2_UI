---@class GW2
local GW = select(2, ...)
local Tooltip = GW.Tooltip

local UNKNOWN_UNIT_COLOR = CreateColor(0.6, 0.6, 0.6)
local VALUE_COLOR = CreateColor(159 / 255, 159 / 255, 159 / 255)

local function FormatValue(value)
    return (GW.settings.tooltip.healthBar.shortValues and GW.ShortValue or BreakUpLargeNumbers)(value)
end

-- RAW, PERCENTAGE or both; NONE leaves the bar without text
local function SetHealthText(bar, value, percent)
    local mode = GW.settings.tooltip.healthBar.values
    if mode == "RAW" then
        bar.Text:SetText(FormatValue(value))
    elseif mode == "PERCENTAGE" then
        bar.Text:SetFormattedText("%d%%", percent)
    else
        bar.Text:SetFormattedText("%s (%d%%)", FormatValue(value), percent)
    end
end

-- modern clients: health and percent can be secret, the engine formats them
local function OnUpdateUnitHealth(bar)
    local unit = GW.settings.tooltip.healthBar.values ~= "NONE" and Tooltip.GetUnit(bar:GetParent())
    if unit then
        SetHealthText(bar, UnitHealth(unit), UnitHealthPercent(unit, true, CurveConstants.ScaleTo100))
    else
        bar.Text:SetText("")
    end
end

-- classic clients: the bar value, the real health where the unit is known
local function OnValueChanged(bar, value)
    if not value or GW.settings.tooltip.healthBar.values == "NONE" then
        bar.Text:SetText("")
        return
    end
    local unit = Tooltip.GetUnit(bar:GetParent())
    if value == 0 or unit and UnitIsDeadOrGhost(unit) then
        bar.Text:SetText(DEAD)
        return
    end
    local maximum
    if unit then
        value, maximum = UnitHealth(unit), UnitHealthMax(unit)
    else
        maximum = select(2, bar:GetMinMaxValues())
    end
    SetHealthText(bar, value, value / math.max(maximum or 1, 1) * 100)
    bar:SetStatusBarColor(VALUE_COLOR:GetRGB())
end

-- below or above the tooltip, or not at all
local function PlaceBar(tooltip)
    local position = GW.settings.tooltip.healthBar.position
    local offset = GW.SpacingSize * 3
    GameTooltipStatusBar:SetAlpha(position == "DISABLED" and 0 or 1)
    if position == "BOTTOM" then
        GameTooltipStatusBar:ClearAllPoints()
        GameTooltipStatusBar:SetPoint("TOPLEFT", tooltip, "BOTTOMLEFT", GW.BorderSize, -offset)
        GameTooltipStatusBar:SetPoint("TOPRIGHT", tooltip, "BOTTOMRIGHT", -GW.BorderSize, -offset)
    elseif position == "TOP" then
        GameTooltipStatusBar:ClearAllPoints()
        GameTooltipStatusBar:SetPoint("BOTTOMLEFT", tooltip, "TOPLEFT", GW.BorderSize, offset)
        GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", tooltip, "TOPRIGHT", -GW.BorderSize, offset)
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        local bar = GameTooltipStatusBar
        bar.Text = bar:CreateFontString(nil, "OVERLAY")
        bar.Text:SetFont(DAMAGE_TEXT_FONT, GW.settings.tooltip.fontSize.healthBar, "OUTLINE")
        bar.Text:SetPoint("CENTER", bar)
        bar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/hud/castinbar-white.png")
        bar:GwCreateBackdrop()
        PlaceBar(GameTooltip)

        -- the bar takes the color of the unit name
        Tooltip.OnTooltipData("Unit", function(tooltip, data)
            if tooltip == GameTooltip then
                local unit = Tooltip.GetUnit(tooltip, data)
                bar:SetStatusBarColor((unit and Tooltip.GetUnitColor(unit) or UNKNOWN_UNIT_COLOR):GetRGB())
            end
        end)
        hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
            if not tooltip:IsForbidden() and tooltip:GetAnchorType() == "ANCHOR_NONE" then
                PlaceBar(tooltip)
            end
        end)
        -- the bar can outlive its tooltip
        hooksecurefunc(GameTooltip, "Hide", function()
            if not GameTooltip:IsForbidden() and bar:IsShown() then
                bar:Hide()
            end
        end)

        if bar.UpdateUnitHealth then
            bar:SetScript("OnValueChanged", nil)
            hooksecurefunc(bar, "UpdateUnitHealth", OnUpdateUnitHealth)
        else
            bar:HookScript("OnValueChanged", OnValueChanged)
        end
    end,
})
