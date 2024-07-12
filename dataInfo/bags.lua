local _, GW = ...

local GetBagName = GetBagName or (C_Container and C_Container.GetBagName)

local iconString = "|T%s:14:14:0:0:64:64:4:60:4:60|t "

local function Bags_OnEnter(self)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    -- get blizzard tooltip infos:
    GameTooltip_SetTitle(GameTooltip, self.tooltipText)
    if not self:IsEnabled() then
        if self.factionGroup == "Neutral" then
            GameTooltip:AddLine(FEATURE_NOT_AVAILBLE_PANDAREN, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        elseif self.minLevel then
            GameTooltip:AddLine(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, self.minLevel), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        elseif self.disabledTooltip then
            local disabledTooltipText = GetValueOrCallFunction(self, "disabledTooltip")
            GameTooltip:AddLine(disabledTooltipText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        end
    end
    GameTooltip:AddLine(" ")

    for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        local bagName = GetBagName(i)
        if bagName then
            local numSlots = ContainerFrame_GetContainerNumSlots(i)
            local freeSlots = C_Container.GetContainerNumFreeSlots(i)
            local usedSlots = numSlots - freeSlots
            local sumNum = 19 + i

            local r2, g2, b2 = GW.ColorGradient(usedSlots / numSlots, 0.1, 1, 0.1, 1, 1, 0.1, 1, 0.1, 0.1)
            local r, g, b, icon

            if i > 0 then
                r, g, b = C_Item.GetItemQualityColor(GetInventoryItemQuality("player", sumNum) or 1)
                icon = GetInventoryItemTexture("player", sumNum)
            end

            bagName = GW.settings.BAG_SEPARATE_BAGS and strlen(GW.settings["BAG_HEADER_NAME" .. i]) > 0 and GW.settings["BAG_HEADER_NAME" .. i] or bagName

            GameTooltip:AddDoubleLine(format(iconString, icon or "Interface/Buttons/Button-Backpack-Up") .. bagName, format("%d/%d", usedSlots, numSlots), r or 1, g or 1, b or 1, r2, g2, b2)
        end
    end

    for i = 1, BackpackTokenFrame:GetMaxTokensWatched() do
        local info = C_CurrencyInfo.GetBackpackCurrencyInfo(i)
        if info then
            if i == 1 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(CURRENCY)
            end
            if info.quantity then
                GameTooltip:AddDoubleLine(format(iconString, info.iconFileID) .. info.name, info.quantity)
            end
        end
    end

    GameTooltip:Show()
end
GW.Bags_OnEnter = Bags_OnEnter
