---@class GW2
local GW = select(2, ...)
local L = GW.L
local CommaValue = GW.CommaValue

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
                 function() GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME = not GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME; ContainerFrame_UpdateAll() end)
    end,
})
