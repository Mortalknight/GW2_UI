local _, GW = ...

local SellJunkFrame = CreateFrame("FRAME")

local function SellJunkFrame_OnEvent(self, event, arg1)
    if event == "MERCHANT_SHOW" then
        if IsShiftKeyDown() then return end
        C_MerchantFrame.SellAllJunkItems()
    end
end

local function SetupVendorJunk(active)
    if active then
        SellJunkFrame:RegisterEvent("MERCHANT_SHOW")
        SellJunkFrame:SetScript("OnEvent", SellJunkFrame_OnEvent)
    else
        SellJunkFrame:UnregisterEvent("MERCHANT_SHOW")
        SellJunkFrame:SetScript("OnEvent", nil)
    end
end
GW.SetupVendorJunk = SetupVendorJunk