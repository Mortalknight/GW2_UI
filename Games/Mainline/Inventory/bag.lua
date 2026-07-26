---@class GW2
local GW = select(2, ...)
local L = GW.L

-- fills the four watched currency displays in the bag footer
local function watchCurrency(self)
    local watchSlot = 1
    for i = 1, BackpackTokenFrame:GetMaxTokensWatched() do
        local info = C_CurrencyInfo.GetBackpackCurrencyInfo(i)
        if info then
            if info.quantity then
                local currencyFrame = self["currencyFrame" .. watchSlot]
                currencyFrame.value:SetText(GW.GetLocalizedNumber(info.quantity))
                currencyFrame.icon:SetTexture(info.iconFileID)
                currencyFrame.id = i
                currencyFrame.currencyID = info.currencyTypesID
                watchSlot = watchSlot + 1
            end
        end
    end

    for i = watchSlot, 4 do
        local currencyFrame = self["currencyFrame" .. i]
        currencyFrame.value:SetText("")
        currencyFrame.icon:SetTexture(nil)
        currencyFrame.id = nil
        currencyFrame.currencyID = nil
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
    for i = 1, 4 do
        local currencyFrame = CreateFrame("Button", nil, f, "GwBagWatchedCurrencyTemplate")
        currencyFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", anchorX, -40)
        anchorX = anchorX - 60
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
        f["currencyFrame" .. i] = currencyFrame
    end

    f.currency:SetScript("OnEvent", function(self)
        if GW.inWorld then watchCurrency(self:GetParent()) end
    end)
    f.currency:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    hooksecurefunc(C_CurrencyInfo, "SetCurrencyBackpack", function() watchCurrency(f) end)
    hooksecurefunc(C_CurrencyInfo, "SetCurrencyBackpackByID", function() watchCurrency(f) end)
    watchCurrency(f)
end


-- blizzards combined bag view fights with our own bag frame, keep it off and parked
local function disableCombinedBags(f)
    ContainerFrameCombinedBags:SetScript("OnShow", nil)
    ContainerFrameCombinedBags:SetScript("OnHide", nil)
    ContainerFrameCombinedBags:SetParent(GW.HiddenFrame)
    ContainerFrameCombinedBags:ClearAllPoints()
    ContainerFrameCombinedBags:SetPoint("BOTTOM")
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


local function skinStackSplit()
    StackSplitFrame:GwStripTextures()
    StackSplitFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)

    StackSplitFrame.OkayButton:GwSkinButton(false, true)
    StackSplitFrame.CancelButton:GwSkinButton(false, true)

    GW.HandleNextPrevButton(StackSplitFrame.RightButton, "right")
    GW.HandleNextPrevButton(StackSplitFrame.LeftButton, "left")

    StackSplitFrame.RightButton:SetSize(25, 25)
    StackSplitFrame.RightButton:SetPoint("LEFT", StackSplitFrame, "CENTER", 51, 18)

    StackSplitFrame.LeftButton:SetSize(25, 25)
    StackSplitFrame.LeftButton:SetPoint("RIGHT", StackSplitFrame, "CENTER", -50, 18)

    StackSplitFrame.textboxbg = StackSplitFrame:CreateTexture(nil, "BACKGROUND")
    StackSplitFrame.textboxbg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg.png")
    StackSplitFrame.textboxbg:SetPoint("TOPLEFT", 35, -20)
    StackSplitFrame.textboxbg:SetPoint("BOTTOMRIGHT", -35, 55)
end


GW.RegisterBagModule({
    onLoadBag = function(f)
        -- retail styled money icons
        f.bronzeIcon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/coins.png")
        f.bronzeIcon:SetTexCoord(0, 0.33, 0.022, 0.66)
        f.silverIcon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/coins.png")
        f.silverIcon:SetTexCoord(0.66, 0.99, 0.022, 0.66)
        f.goldIcon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/coins.png")
        f.goldIcon:SetTexCoord(0.33, 0.66, 0.022, 0.66)

        if BagBarExpandToggle then
            BagBarExpandToggle:SetParent(GW.HiddenFrame)
            SetCVar("expandBagBar", "1")
        end

        disableCombinedBags(f)
        setupCurrencies(f)
        skinStackSplit()
    end,
    onMenu = function(f, rootDescription, addCheck)
        addCheck(L["Show Scrap Icon"], function() return GW.settings.BAG_ITEM_SCRAP_ICON_SHOW end,
                 function() GW.settings.BAG_ITEM_SCRAP_ICON_SHOW = not GW.settings.BAG_ITEM_SCRAP_ICON_SHOW; GW.UpdateAllOwnBagItemButtons() end)
    end,
})
