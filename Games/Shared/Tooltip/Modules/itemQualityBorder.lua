---@class GW2
local GW = select(2, ...)
local Tooltip = GW.Tooltip

local function ResetBorder(tooltip)
    if tooltip.gwQualityBorder then
        tooltip.gwQualityBorder = nil
        tooltip:SetBackdropBorderColor(0.05, 0.05, 0.05, 1)
    end
end

local function OnItemTooltip(tooltip)
    if not GW.settings.tooltip.item.qualityBorder or tooltip:IsForbidden() or not tooltip.SetBackdropBorderColor then
        return
    end
    local GetItem = TooltipUtil and TooltipUtil.GetDisplayedItem or tooltip.GetItem
    local _, link = GetItem(tooltip)
    if GW.IsSecretValue(link) or not link then return end

    local quality = C_Item.GetItemQualityByID(link)
    if quality and quality > Enum.ItemQuality.Common then
        if not tooltip.gwQualityBorderHooked then
            tooltip.gwQualityBorderHooked = true
            tooltip:HookScript("OnTooltipCleared", ResetBorder)
        end
        local color = GW.GetBagItemQualityColor(quality)
        tooltip:SetBackdropBorderColor(color.r, color.g, color.b, 1)
        tooltip.gwQualityBorder = true
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        Tooltip.OnTooltipData("Item", OnItemTooltip)
    end,
})
