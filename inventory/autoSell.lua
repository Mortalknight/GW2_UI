local _, GW = ...

local IterationCount = 500
local SellJunkFrame = CreateFrame("FRAME")
local SellJunkTicker, mBagID, mBagSlot

local IgnoreVendors = {
    [113831] = "Auto-Hammer",
    [100995] = "Auto-Hammer"
}

-- automaticly vendor junk
local function StopSelling()
    if SellJunkTicker then SellJunkTicker:Cancel() end
    GwBagFrame.smsj:Hide()
    SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
    SellJunkFrame:UnregisterEvent("ITEM_UNLOCKED")
end

local function sellJunk()
    -- Variables
    local counter = 0

    -- Traverse bags and sell grey items
    for BagID = 0, 4 do
        for slotID = 1, C_Container.GetContainerNumSlots(BagID) do
            local info = C_Container.GetContainerItemInfo(BagID, slotID)
            local itemLink = info and info.hyperlink
            if itemLink and not info.hasNoValue then
                local _, _, rarity, _, _, _, _, _, _, _, itemPrice, classID, _, bindType = GetItemInfo(itemLink)
                if rarity and rarity == 0
                and (classID ~= 12 or bindType ~= 4)
                and (not IsCosmeticItem(itemLink) or C_TransmogCollection.PlayerHasTransmogByItemInfo(itemLink)) then
                    if MerchantFrame:IsShown() then
                        counter = counter + 1
                        -- If merchant frame is open, vendor the item
                        C_Container.UseContainerItem(BagID, slotID)
                        -- Perform actions on first iteration
                        if SellJunkTicker._remainingIterations == IterationCount then
                            -- Store first sold bag slot for analysis
                            if counter == 1 then
                                mBagID, mBagSlot = BagID, slotID
                            end
                        end
                    else
                        -- If merchant frame is not open, stop selling
                        StopSelling()
                        return
                    end
                end
            end
        end
    end

    -- Stop selling if no items were sold for this iteration or iteration limit was reached
    if counter == 0 or SellJunkTicker and SellJunkTicker._remainingIterations == 1 then
        StopSelling()
    end
end

local function SellJunkFrame_OnEvent(self, event)
    if event == "MERCHANT_SHOW" then
        -- Reset variables
        mBagID, mBagSlot = -1, -1
        -- Do nothing if shift key is held down
        if IsShiftKeyDown() then return end
        -- Check if we need to ignore these vendor
        if IgnoreVendors[GW.GetUnitCreatureId("npc")] then return end
        -- Cancel existing ticker if present
        if SellJunkTicker then SellJunkTicker:Cancel() end
        -- Sell grey items using ticker (ends when all grey items are sold or iteration count reached)
        SellJunkTicker = C_Timer.NewTicker(0.2, sellJunk, IterationCount)
        self:RegisterEvent("ITEM_LOCKED")
        self:RegisterEvent("ITEM_UNLOCKED")
    elseif event == "ITEM_LOCKED" then
        GwBagFrame.smsj:Show()
        self:UnregisterEvent("ITEM_LOCKED")
    elseif event == "ITEM_UNLOCKED" then
        self:UnregisterEvent("ITEM_UNLOCKED")
        -- Check whether vendor refuses to buy items
        if mBagID and mBagSlot and mBagID ~= -1 and mBagSlot ~= -1 then
            local itemInfo = C_Container.GetContainerItemInfo(mBagID, mBagSlot)
            if itemInfo.stackCount and not itemInfo.isLocked then
                -- Item has been unlocked but still not sold so stop selling
                StopSelling()
            end
        end
    elseif event == "MERCHANT_CLOSED" then
        -- If merchant frame is closed, stop selling
        StopSelling()
    end
end

local function SetupVendorJunk(active)
    if active then
        SellJunkFrame:RegisterEvent("MERCHANT_SHOW")
        SellJunkFrame:RegisterEvent("MERCHANT_CLOSED")
        SellJunkFrame:SetScript("OnEvent", SellJunkFrame_OnEvent)
    else
        SellJunkFrame:UnregisterEvent("MERCHANT_SHOW")
        SellJunkFrame:UnregisterEvent("MERCHANT_CLOSED")
        SellJunkFrame:SetScript("OnEvent", nil)
    end
end
GW.SetupVendorJunk = SetupVendorJunk