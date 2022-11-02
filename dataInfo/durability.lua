local _, GW = ...

local totalDurability = 0
local invDurability = {}
local totalRepairCost

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
local function collectDurability(self)
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

            GW.ScanTooltip:SetInventoryItem("player", idx)
            GW.ScanTooltip:Show()

            if GW.ScanTooltip.GetTooltipData then
				GW.ScanTooltip:SetInventoryItem("player", idx)
				GW.ScanTooltip:Show()

				local data = GW.ScanTooltip:GetTooltipData()
				totalRepairCost = totalRepairCost + (data and data.repairCost or 0)
			else
				totalRepairCost = totalRepairCost + select(3, GW.ScanTooltip:SetInventoryItem("player", idx))
			end
        end
    end
    self.Value:SetFormattedText("%d%%", totalDurability)
end
GW.collectDurability = collectDurability

local function DurabilityTooltip()
    GameTooltip:ClearLines()
    GameTooltip:AddLine(DURABILITY, 1, 0.85, 0)

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