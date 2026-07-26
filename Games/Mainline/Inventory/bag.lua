---@class GW2
local GW = select(2, ...)
local L = GW.L

-- as many watched currency displays as fit between the currency button
-- on the left and the money display on the right
local function maxCurrencySlots(f)
    return math.max(1, math.floor((f:GetWidth() - 273) / 60) + 1)
end

local function getCurrencyFrame(f, index)
    local currencyFrame = f.gwCurrencyFrames[index]
    if currencyFrame then
        return currencyFrame
    end

    currencyFrame = CreateFrame("Button", nil, f, "GwBagWatchedCurrencyTemplate")
    currencyFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -183 - ((index - 1) * 60), -40)
    currencyFrame.value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    currencyFrame.value:SetTextColor(1, 1, 1)
    currencyFrame:SetScript("OnEnter", function(self)
        if self.id then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:ClearLines()
            GameTooltip:SetBackpackToken(self.id)
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            GameTooltip_AddInstructionLine(GameTooltip, TOKEN_REMOVE_FROM_BACKPACK_INSTRUCTION)
            GameTooltip:Show()
        end
    end)
    currencyFrame:SetScript("OnClick", function(self)
        if IsModifiedClick("CHATLINK") then
            local linkedToChat = HandleModifiedItemClick(C_CurrencyInfo.GetCurrencyLink(self.currencyID))
            if linkedToChat then
                return
            end
        end

        if IsModifiedClick("TOKENWATCHTOGGLE") then
            C_CurrencyInfo.SetCurrencyBackpackByID(self.currencyID, false)
        else
            if not InCombatLockdown() then
                ToggleCharacter("TokenFrame")
            end
        end
    end)

    f.gwCurrencyFrames[index] = currencyFrame
    return currencyFrame
end

-- fills the watched currency displays in the bag footer
local function watchCurrency(self)
    local maxSlots = maxCurrencySlots(self)
    local watchSlot = 1
    for i = 1, BackpackTokenFrame:GetMaxTokensWatched() do
        if watchSlot > maxSlots then
            break
        end
        local info = C_CurrencyInfo.GetBackpackCurrencyInfo(i)
        if info and info.quantity then
            local currencyFrame = getCurrencyFrame(self, watchSlot)
            currencyFrame.value:SetText(GW.GetLocalizedNumber(info.quantity))
            currencyFrame.icon:SetTexture(info.iconFileID)
            currencyFrame.id = i
            currencyFrame.currencyID = info.currencyTypesID
            currencyFrame:Show()
            watchSlot = watchSlot + 1
        end
    end

    for i = watchSlot, #self.gwCurrencyFrames do
        local currencyFrame = self.gwCurrencyFrames[i]
        currencyFrame.value:SetText("")
        currencyFrame.icon:SetTexture(nil)
        currencyFrame.id = nil
        currencyFrame.currencyID = nil
        currencyFrame:Hide()
    end
end


-- creates and wires the watched currency displays and the currency button
local function setupCurrencies(f)
    f.gwCurrencyFrames = {}
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

    f.currency:SetScript("OnEvent", function(self)
        if GW.inWorld then watchCurrency(self:GetParent()) end
    end)
    f.currency:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    hooksecurefunc(C_CurrencyInfo, "SetCurrencyBackpack", function() watchCurrency(f) end)
    hooksecurefunc(C_CurrencyInfo, "SetCurrencyBackpackByID", function() watchCurrency(f) end)
    f:HookScript("OnSizeChanged", function() watchCurrency(f) end)
    watchCurrency(f)
end


-- blizzards combined bag view fights with our own bag frame; the frame itself is
-- already made inert by the shared code, here we just keep the cvar off
local function disableCombinedBags(f)
    SetCVar("combinedBags", 0)

    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("CVAR_UPDATE")
    watcher:SetScript("OnEvent", function(_, _, cvarName, cvarValue)
        if cvarName == "combinedBags" and cvarValue == "1" then
            SetCVar("combinedBags", "0")
        end
    end)

    -- the help box for the extra bag slots anchors to the blizzard frames, move it to ours
    hooksecurefunc("ContainerFrame_GenerateFrame", function(frame)
        if frame.ExtraBagSlotsHelpBox then
            local h = frame.ExtraBagSlotsHelpBox
            h:ClearAllPoints()
            h:SetPoint("RIGHT", f, "TOPLEFT", -60, -90)
        end
    end)
end


GW.RegisterBagModule({
    onLoadBag = function(f)
        if BagBarExpandToggle then
            BagBarExpandToggle:SetParent(GW.HiddenFrame)
            SetCVar("expandBagBar", "1")
        end

        disableCombinedBags(f)
        setupCurrencies(f)
    end,
    onMenu = function(f, rootDescription, addCheck)
        addCheck(L["Show Scrap Icon"], function() return GW.settings.BAG_ITEM_SCRAP_ICON_SHOW end,
                 function() GW.settings.BAG_ITEM_SCRAP_ICON_SHOW = not GW.settings.BAG_ITEM_SCRAP_ICON_SHOW; GW.UpdateAllOwnBagItemButtons() end)
    end,
})
