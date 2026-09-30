---@class GW2
local GW = select(2, ...)

-- worn items with durability, in slot order for the tooltip
local itemSlots, itemPercents = {}, {}
local lowestPercent = 100

-- the full tooltip data of an item is costly, so the cost is only asked for when the tooltip shows
local function GetRepairCost(slot)
    if C_TooltipInfo then
        local data = C_TooltipInfo.GetInventoryItem("player", slot)
        return data and data.repairCost or 0
    end
    -- clients without tooltip data return the cost from the scan tooltip
    local _, _, cost = GW.ScanTooltip:SetInventoryItem("player", slot)
    return cost or 0
end

local function DurabilityOnEvent(self, event)
    wipe(itemSlots)
    lowestPercent = 100

    -- slots without durability (rings, trinkets, shirt, ...) simply return nil
    for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        local current, maximum = GetInventoryItemDurability(slot)
        if current and maximum > 0 then
            local percent = current / maximum * 100
            itemSlots[#itemSlots + 1] = slot
            itemPercents[slot] = percent
            lowestPercent = min(lowestPercent, percent)
        end
    end

    self.Value:SetFormattedText("%d%%", lowestPercent)
    GW.Debug("Durability update with event", event, "and durability of", lowestPercent)
end
GW.DurabilityOnEvent = DurabilityOnEvent

local watcher
function GW.WatchDurability(tile)
    if not watcher then
        watcher = CreateFrame("Frame")
        watcher:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        watcher:RegisterEvent("MERCHANT_SHOW")
        watcher:SetScript("OnEvent", function(self, event)
            DurabilityOnEvent(self.tile, event)
        end)
    end
    watcher.tile = tile
    DurabilityOnEvent(tile, "ForceUpdate")
end

local function DurabilityTooltip(self)
    if self then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    end
    local white = GW.Colors.FallbackWhite
    local repairCost = 0
    GameTooltip:ClearLines()
    GameTooltip:AddLine(DURABILITY, white.r, white.g, white.b)

    for _, slot in ipairs(itemSlots) do
        -- the item may have been unequipped since the last update
        local texture, link = GetInventoryItemTexture("player", slot), GetInventoryItemLink("player", slot)
        if texture and link then
            local percent = itemPercents[slot]
            if percent < 100 then
                repairCost = repairCost + GetRepairCost(slot)
            end
            -- cropped so the icon border does not show
            local icon = CreateTextureMarkup(texture, 64, 64, 14, 14, 0.08, 0.92, 0.08, 0.92)
            GameTooltip:AddDoubleLine(icon .. " " .. link, format("%d%%", percent),
                white.r, white.g, white.b, GW.ColorGradient(percent / 100, 1, 0.1, 0.1, 1, 1, 0.1, 0.1, 1, 0.1))
        end
    end

    if repairCost > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(REPAIR_COST, GetMoneyString(repairCost), white.r, white.g, white.b, white.r, white.g, white.b)
    end

    GameTooltip:Show()
end
GW.DurabilityTooltip = DurabilityTooltip
