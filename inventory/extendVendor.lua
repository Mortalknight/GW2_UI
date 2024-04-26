local _, GW = ...
local BLIZZARD_MERCHANT_ITEMS_PER_PAGE = 10

local function UpdateBuybackPositions()
    for i = 1, MERCHANT_ITEMS_PER_PAGE do
        local button = _G["MerchantItem" .. i]
        button:ClearAllPoints()

        local contentWidth = 3 * _G["MerchantItem1"]:GetWidth() + 2 * 50
        local firstButtonOffsetX = (MerchantFrame:GetWidth() - contentWidth) / 2

        if i > BUYBACK_ITEMS_PER_PAGE then
            button:Hide()
        else
            if i == 1 then
                button:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", firstButtonOffsetX, -105)
            else
                if ((i % 3) == 1) then
                    button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 3)], "BOTTOMLEFT", 0, -30)
                else
                    button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", 50, 0)
                end
            end
        end
    end
end

local function UpdateMerchantPositions()
    for i = 1, MERCHANT_ITEMS_PER_PAGE do
        local button = _G["MerchantItem" .. i]
        button:Show()
        button:ClearAllPoints()

        if (i % BLIZZARD_MERCHANT_ITEMS_PER_PAGE) == 1 then
            if (i == 1) then
                button:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 24, -70)
            else
                button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - (BLIZZARD_MERCHANT_ITEMS_PER_PAGE - 1))], "TOPRIGHT", 12, 0)
            end
        else
            if (i % 2) == 1 then
                button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 2)], "BOTTOMLEFT", 0, -10)
            else
                button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", 12, 0)
            end
        end
    end
end


local function SetUpExtendedVendor()
    if C_AddOns.IsAddOnLoaded("ExtVendor") or C_AddOns.IsAddOnLoaded("Krowi_MerchantFrameExtended") or GW.settings.EXTENDED_VENDOR_NUM_PAGES == 1 then
        return
    end

    MERCHANT_ITEMS_PER_PAGE = GW.settings.EXTENDED_VENDOR_NUM_PAGES * 10
    MerchantFrame:SetWidth(30 + GW.settings.EXTENDED_VENDOR_NUM_PAGES * 330)

    for i = 1, MERCHANT_ITEMS_PER_PAGE do
        if not _G["MerchantItem" .. i] then
            CreateFrame("Frame", "MerchantItem" .. i, MerchantFrame, "MerchantItemTemplate")
            if GW.settings.MERCHANT_SKIN_ENABLED then
                GW.SkinMerchantFrameItemButton(i)
            end
        end
    end

    MerchantBuyBackItem:ClearAllPoints()
	MerchantBuyBackItem:SetPoint("TOPLEFT", MerchantItem10, "BOTTOMLEFT", -14,-43)
    MerchantPrevPageButton:ClearAllPoints()
    MerchantPrevPageButton:SetPoint("CENTER", MerchantFrame, "BOTTOM", 30, 55)
    MerchantPageText:ClearAllPoints()
    MerchantPageText:SetPoint("BOTTOM", MerchantFrame, "BOTTOM", 160, 50)
    MerchantNextPageButton:ClearAllPoints()
    MerchantNextPageButton:SetPoint("CENTER", MerchantFrame, "BOTTOM", 290, 55)

    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", UpdateMerchantPositions)
    hooksecurefunc("MerchantFrame_UpdateBuybackInfo", UpdateBuybackPositions)
end
GW.SetUpExtendedVendor = SetUpExtendedVendor