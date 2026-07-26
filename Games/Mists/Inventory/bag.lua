---@class GW2
local GW = select(2, ...)
local L = GW.L
local CommaValue = GW.CommaValue

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

-- fills the three watched currency displays in the bag footer
local function watchCurrency(self)
    local watchSlot = 1
    local currencyCount = GetCurrencyListSize()
    for i = 1, currencyCount do
        local _, isHeader, _, _, isWatched, count, icon = GetCurrencyListInfo(i)
        if not isHeader and isWatched and watchSlot < 4 then
            local currencyFrame = self["currencyFrame" .. watchSlot]
            currencyFrame.value:SetText(CommaValue(count))
            currencyFrame.icon:SetTexture(icon)
            currencyFrame.CurrencyIdx = i
            watchSlot = watchSlot + 1
        end
    end

    for i = watchSlot, 3 do
        local currencyFrame = self["currencyFrame" .. i]
        currencyFrame.value:SetText("")
        currencyFrame.icon:SetTexture(nil)
        currencyFrame.CurrencyIdx = nil
    end
end


-- creates and wires the watched currency displays and the currency button
local function setupCurrencies(f)
    f.currency = CreateFrame("Button", nil, f)
    f.currency:SetSize(32, 32)
    f.currency:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 2, -2)
    f.currency:SetFrameLevel(50)
    f.currency:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/currency-icon.png")
    f.currency:SetScript("OnClick", function()
        -- TODO: cannot do this properly until we make the whole bag frame secure
        if not InCombatLockdown() then
            ToggleCharacter("TokenFrame")
        end
    end)

    local anchorX = -183
    for i = 1, 3 do
        local currencyFrame = CreateFrame("Button", nil, f, "GwBagWatchedCurrencyTemplate")
        currencyFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", anchorX, -40)
        anchorX = anchorX - 60
        currencyFrame.value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        currencyFrame.value:SetTextColor(1, 1, 1)
        currencyFrame:SetScript("OnEnter", function(self)
            if self.CurrencyIdx then
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:ClearLines()
                GameTooltip:SetCurrencyToken(self.CurrencyIdx)
                GameTooltip:Show()
            end
        end)
        f["currencyFrame" .. i] = currencyFrame
    end

    f.currency:SetScript("OnEvent", function(self)
        if GW.inWorld then
            watchCurrency(self:GetParent())
        end
    end)
    f.currency:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    hooksecurefunc(
        "SetCurrencyBackpack",
        function()
            watchCurrency(f)
        end
    )
    watchCurrency(f)
end


GW.RegisterBagModule({
    onLoadBag = function(f)
        setupCurrencies(f)
    end,
    onMenu = function(f, rootDescription, addCheck)
        addCheck(L["Show Equipment Set Name"], function() return GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME end,
                 function() GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME = not GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME; GW.UpdateAllOwnBagItemButtons() end)
    end,
})
