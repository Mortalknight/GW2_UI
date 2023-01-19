local _, GW = ...

local IterationCount = 500
local SellJunkFrame = CreateFrame("FRAME")
local SellJunkTicker

local IgnoreVendors = {
    [113831] = "Auto-Hammer",
    [100995] = "Auto-Hammer"
}

local whiteList = {}
-- These items cannot be sold but the game thinks they can be
-- https://www.wowhead.com/items/quest/min-level:1/max-level:1/quality:0?filter=64;3;1

-- Continued Waygate Exploration
whiteList[200590] = "Carefully Rolled Message"
whiteList[200593] = "Sealed Expedition Note"
whiteList[200594] = "Thaelin's Second Favorite Comb"
whiteList[200595] = "Odorous Parchment"
whiteList[200596] = "Letter from Thaelin Darkanvil"

-- Dirty Old Satchel
whiteList[200592] = "Dirty Old Satchel"
whiteList[200606] = "Previously Owned Map"


-- automaticly vendor junk
local function StopSelling()
    if SellJunkTicker then SellJunkTicker._cancelled = true end
    GwBagFrame.smsj:Hide()
    SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
    SellJunkFrame:UnregisterEvent("ITEM_UNLOCKED")
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
                _, _, rarity, _, _, _, _, _, _, _, itemPrice, classID, _, bindType = GetItemInfo(ItemLink)
                local itemID = GetItemInfoFromHyperlink(ItemLink)
                if itemID and whiteList[itemID] then
                    if rarity == 0 then
                        -- Junk item to keep
                        rarity = 20
                    elseif rarity == 1 then
                        -- White item to sell
                        rarity = 0
                    end
                end

                -- 10.0.5
                local _, sourceID = C_TransmogCollection.GetItemInfo(itemID)
                if sourceID then
                    local _, _, _, _, isCollected = C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
                    local _, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID)
                    if not isCollected then
                        -- Item is not collected at all
                        if canCollect then
                            -- Gear is designed for my character and exclude gear designed for my character is checked so do not sell
                            rarity = 20
                        end
                    end
                end

                if rarity and rarity == 0 and itemPrice ~= 0 and (classID ~= 12 or bindType ~= 4) then
                    soldCount = soldCount + 1
                    if MerchantFrame:IsShown() then
                        -- If merchant frame is open, vendor the item
                        C_Container.UseContainerItem(BagID, slotID)
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
        -- Check for vendors that refuse to buy items
        self:RegisterEvent("UI_ERROR_MESSAGE")
        -- Do nothing if shift key is held down
        if IsShiftKeyDown() then return end
        -- Check if we need to ignore these vendor
        if IgnoreVendors[GW.GetUnitCreatureId("npc")] then return end
        -- Cancel existing ticker if present
        if SellJunkTicker then SellJunkTicker._cancelled = true end
        -- Sell grey items using ticker (ends when all grey items are sold or iteration count reached)
        SellJunkTicker = NewAutoSellTicker(0.2, sellJunk, IterationCount)
        self:RegisterEvent("ITEM_LOCKED")
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
        SellJunkFrame:RegisterEvent("MERCHANT_CLOSED")
        SellJunkFrame:SetScript("OnEvent", SellJunkFrame_OnEvent)
    else
        SellJunkFrame:UnregisterEvent("MERCHANT_SHOW")
        SellJunkFrame:UnregisterEvent("MERCHANT_CLOSED")
        SellJunkFrame:SetScript("OnEvent", nil)
    end
end
GW.SetupVendorJunk = SetupVendorJunk