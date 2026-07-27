---@class GW2
local GW = select(2, ...)
local L = GW.L

local function GetItemEquipmentSetName(itemIDOrLink)
    local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()
    if equipmentSetIDs then
        for _, equipmentSetID in ipairs(equipmentSetIDs) do
            local equipmentSetItems = C_EquipmentSet.GetItemIDs(equipmentSetID)
            for _, equipmentSetItemId in pairs(equipmentSetItems) do
                if equipmentSetItemId == itemIDOrLink then
                    local equipmentSetName = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetID)
                    if string.len(equipmentSetName) > 5 then
                        equipmentSetName = string.sub(equipmentSetName, 1, 5)
                    end
                    return equipmentSetName
                end
            end
        end
    end
    return nil
end

-- show the equipment set name on the item buttons of set items
GW.RegisterItemButtonDecorator(function(button, _, itemIDOrLink)
    if not GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME then
        return
    end
    local equipmentSetName = GetItemEquipmentSetName(itemIDOrLink)
    if equipmentSetName then
        button.itemlevel:SetTextColor(255, 255, 255, 1)
        button.itemlevel:SetText(equipmentSetName)
    end
end)

-- the classic currency list mixes headers and unwatched entries into one flat list, and
-- the game never watches more than MAX_WATCHED_TOKENS of them. The list index is kept
-- because the tooltip is built from it.
local function enumerateWatchedCurrencies()
    local watched = {}
    for i = 1, GetCurrencyListSize() do
        local _, isHeader, _, _, isWatched, count, icon = GetCurrencyListInfo(i)
        if not isHeader and isWatched then
            watched[#watched + 1] = {quantity = count, icon = icon, listIndex = i}
            if #watched >= MAX_WATCHED_TOKENS then
                break
            end
        end
    end
    return watched
end

local function currency_OnEnter(self)
    if not self.gwCurrency then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    GameTooltip:SetCurrencyToken(self.gwCurrency.listIndex)
    GameTooltip:Show()
end


GW.RegisterBagModule({
    onLoadBag = function(f)
        GW.SetupBagCurrencyDisplay(f, {
            enumerate = enumerateWatchedCurrencies,
            onEnter = currency_OnEnter,
            onRefresh = function(refresh)
                hooksecurefunc("SetCurrencyBackpack", refresh)
            end,
        })
    end,
    onMenu = function(f, rootDescription, addCheck)
        addCheck(L["Show Equipment Set Name"], function() return GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME end,
                 function() GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME = not GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME; GW.UpdateAllOwnBagItemButtons() end)
    end,
})
