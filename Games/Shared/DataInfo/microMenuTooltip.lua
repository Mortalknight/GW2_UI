---@class GW2
local GW = select(2, ...)

-- Micro menu buttons show blizzards tooltip (title and keybind) through their own OnEnter, the DataInfo
-- tooltips append to it. Our replacement buttons on the classic clients have no tooltip of their own, for
-- them the tooltip is opened here with the button's tooltipText as title.
local function EnsureMicroMenuTooltip(button)
    if GameTooltip:IsOwned(button) then
        return true
    end
    if not button.tooltipText or button.tooltipText == "" then
        return false
    end
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip_SetTitle(GameTooltip, button.tooltipText)
    return true
end
GW.EnsureMicroMenuTooltip = EnsureMicroMenuTooltip

-- for buttons whose tooltip shows running times: GameTooltip calls owner:UpdateTooltip() every 0.2 seconds,
-- the tooltip is rebuilt through the button's own OnEnter (blizzards part plus the hooked DataInfo part)
local function RefreshMicroMenuTooltip(self)
    if not GameTooltip:IsOwned(self) then return end
    local onEnter = self:GetScript("OnEnter")
    if onEnter then
        onEnter(self)
    end
end
GW.RefreshMicroMenuTooltip = RefreshMicroMenuTooltip

-- fraction "collected/total" colored from red (nothing) to green (everything)
local function FormatProgressFraction(current, total)
    local perc = total > 0 and current / total or 0
    local r, g, b = GW.ColorGradient(perc, 1, 0.1, 0.1, 1, 1, 0.1, 0.1, 1, 0.1)
    return GW.RGBToHex(r, g, b) .. format(GENERIC_FRACTION_STRING, current, total) .. "|r"
end
GW.FormatProgressFraction = FormatProgressFraction
