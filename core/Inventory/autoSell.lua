local _, GW = ...

local IterationCount, totalPrice = 500, 0
local SellJunkFrame = CreateFrame("FRAME")
local SellJunkTicker

-- automaticly vendor junk
local function StopSelling()
    if SellJunkTicker then SellJunkTicker._cancelled = true end
    GwBagFrame.smsj:Hide()
    SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
    SellJunkFrame:UnregisterEvent("UI_ERROR_MESSAGE")
end

local function sellJunk()
    -- Variables
    local soldCount, rarity, itemPrice, classID, bindType = 0, 0, 0, 0, 0
    local ItemLink

    -- Traverse bags and sell grey items
    for BagID = 0, 4 do
        for slotID = 1, C_Container.GetContainerNumSlots(BagID) do
            ItemLink = C_Container.GetContainerItemLink(BagID, slotID)
            if ItemLink then
                _, _, rarity, _, _, _, _, _, _, _, itemPrice, classID, _, bindType = C_Item.GetItemInfo(ItemLink)
                local itemInfo = C_Container.GetContainerItemInfo(BagID, slotID)
                local itemCount = itemInfo.stackCount or 1

                if rarity and rarity == 0 and itemPrice ~= 0 and (classID ~= 12 or bindType ~= 4) then
                    soldCount = soldCount + 1
                    if MerchantFrame:IsShown() then
                        -- If merchant frame is open, vendor the item
                        C_Container.UseContainerItem(BagID, slotID)
                        -- Perform actions on first iteration
                        if SellJunkTicker._remainingIterations == IterationCount then
                            -- Calculate total price
                            totalPrice = totalPrice + (itemPrice * itemCount)
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
    if soldCount == 0 or SellJunkTicker and SellJunkTicker._remainingIterations == 1 then
        StopSelling()
        if totalPrice > 0 then
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r " .. GW.L["Sold Junk for: %s"]:format(GW.FormatMoneyForChat(totalPrice)))
        end
    end
end

local function NewAutoSellTicker(duration, callback, iterations)
    local ticker = setmetatable({}, TickerMetatable)
    ticker._remainingIterations = iterations
    ticker._callback = function()
        if not ticker._cancelled then
            callback(ticker)
            --Make sure we weren't cancelled during the callback
            if not ticker._cancelled then
                if ticker._remainingIterations then
                    ticker._remainingIterations = ticker._remainingIterations - 1
                end
                if not ticker._remainingIterations or ticker._remainingIterations > 0 then
                    C_Timer.After(duration, ticker._callback)
                end
            end
        end
    end
    C_Timer.After(duration, ticker._callback)
    return ticker
end

local function SellJunkFrame_OnEvent(self, event, arg1)
    if event == "MERCHANT_SHOW" then
        if GW.Retail then
            if IsShiftKeyDown() then return end
            C_MerchantFrame.SellAllJunkItems()
        else
            -- Check for vendors that refuse to buy items
            self:RegisterEvent("UI_ERROR_MESSAGE")
            -- Reset variable
            totalPrice = 0
            -- Do nothing if shift key is held down
            if IsShiftKeyDown() then return end
            -- Cancel existing ticker if present
            if SellJunkTicker then SellJunkTicker._cancelled = true end
            -- Sell grey items using ticker (ends when all grey items are sold or iteration count reached)
            SellJunkTicker = NewAutoSellTicker(0.2, sellJunk, IterationCount)
            self:RegisterEvent("ITEM_LOCKED")
        end
    elseif event == "ITEM_LOCKED" then
        GwBagFrame.smsj:Show()
        self:UnregisterEvent("ITEM_LOCKED")
    elseif event == "MERCHANT_CLOSED" then
        -- If merchant frame is closed, stop selling
        StopSelling()
    elseif event == "UI_ERROR_MESSAGE" then
        if arg1 == 46 then
            StopSelling() -- Vendor refuses to buy items
        end
    end
end

local function SetupVendorJunk(active)
    if active then
        SellJunkFrame:RegisterEvent("MERCHANT_SHOW")
        if not GW.Retail then
            SellJunkFrame:RegisterEvent("MERCHANT_CLOSED")
        end
        SellJunkFrame:SetScript("OnEvent", SellJunkFrame_OnEvent)
    else
        SellJunkFrame:UnregisterEvent("MERCHANT_SHOW")
        if not GW.Retail then
            SellJunkFrame:UnregisterEvent("MERCHANT_CLOSED")
        end
        SellJunkFrame:SetScript("OnEvent", nil)
    end
end
GW.SetupVendorJunk = SetupVendorJunk