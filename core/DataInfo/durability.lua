local _, GW = ...

local totalDurability = 0
local invDurability = {}
local totalRepairCost
local tooltipData

local slots = {
    [1] = INVTYPE_HEAD,
    [3] = INVTYPE_SHOULDER,
    [5] = INVTYPE_CHEST,
    [6] = INVTYPE_WAIST,
    [7] = INVTYPE_LEGS,
    [8] = INVTYPE_FEET,
    [9] = INVTYPE_WRIST,
    [10] = INVTYPE_HAND,
    [16] = INVTYPE_WEAPONMAINHAND,
    [17] = INVTYPE_WEAPONOFFHAND,
    [18] = INVTYPE_RANGED,
}
local function DurabilityOnEvent(self, event)
    totalDurability = 100
    totalRepairCost = 0

    wipe(invDurability)

    for idx in pairs(slots) do
        local current, maximum = GetInventoryItemDurability(idx)
        if current and maximum > 0 then
            local perc = (current / maximum) * 100
            invDurability[idx] = perc

            if perc < totalDurability then
                totalDurability = perc
            end
            tooltipData = C_TooltipInfo.GetInventoryItem("player", idx)
			totalRepairCost = totalRepairCost + (tooltipData and tooltipData.repairCost or 0)
        end
    end
    tooltipData = nil
    self.Value:SetFormattedText("%d%%", totalDurability)

    GW.Debug("Durability update with event", event, "and durability of", totalDurability)
end
GW.DurabilityOnEvent = DurabilityOnEvent

local function DurabilityTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(DURABILITY, 1, 1, 1)

    for slot, durability in pairs(invDurability) do
        GameTooltip:AddDoubleLine(format("|T%s:14:14:0:0:64:64:4:60:4:60|t %s", GetInventoryItemTexture("player", slot), GetInventoryItemLink("player", slot)), format("%d%%", durability), 1, 1, 1, GW.ColorGradient(durability * 0.01, 1, 0.1, 0.1, 1, 1, 0.1, 0.1, 1, 0.1))
    end

    if totalRepairCost > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(REPAIR_COST, GetMoneyString(totalRepairCost), 1, 1, 1, 1, 1, 1)
    end

    GameTooltip:Show()
end
GW.DurabilityTooltip = DurabilityTooltip