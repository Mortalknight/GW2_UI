local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder
local constBackdropFrameSmallerBorder = GW.skins.constBackdropFrameSmallerBorder

local function LoadMerchantFrameSkin()
    if not GW.GetSetting("MERCHANT_SKIN_ENABLED") then return end

    MerchantFrame:StripTextures()
    MerchantFrame.NineSlice:Hide()
    MerchantFrame.TitleBg:Hide()
    MerchantFrame.TopTileStreaks:Hide()
    MerchantFrame:CreateBackdrop()

    MerchantFrameInset.NineSlice:Hide()
    MerchantFrameInset:CreateBackdrop(constBackdropFrameBorder)

    MerchantFrameCloseButton:SkinButton(true)
    MerchantFrameCloseButton:SetSize(20, 20)

    local tex = MerchantFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", MerchantFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = MerchantFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    MerchantFrame.tex = tex

    local r = {MerchantFrame:GetRegions()}
    local i = 1
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            if i == 2 then c:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE"); break end
            i = i + 1
        end
    end

    MerchantFrame:SetWidth(360)

    MerchantBuyBackItem:StripTextures(true)
    MerchantBuyBackItem:CreateBackdrop(constBackdropFrameSmallerBorder, true, 6, 6)
    MerchantBuyBackItem.backdrop:SetPoint("TOPLEFT", -6, 6)
    MerchantBuyBackItem.backdrop:SetPoint("BOTTOMRIGHT", 6, -6)

    MerchantExtraCurrencyInset:StripTextures()
    MerchantExtraCurrencyBg:StripTextures()

    MerchantMoneyBg:StripTextures()
    MerchantMoneyInset:StripTextures()

    MerchantFrameLootFilter:SkinDropDownMenu()

    MerchantItem1:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 24, -69)

    MerchantFrameTab1:SkinButton(false, true)
    MerchantFrameTab2:SkinButton(false, true)

    MerchantFrameTab1:SetSize(80, 24)
    MerchantFrameTab2:SetSize(80, 24)

    MerchantFrameTab2:ClearAllPoints()
    MerchantFrameTab2:SetPoint("RIGHT",  MerchantFrameTab1, "RIGHT", 75, 0)

    hooksecurefunc("PanelTemplates_SelectTab", function(tab)
        local name = tab:GetName()
        local text = tab.Text or _G[name .. "Text"]
        text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2))
    end)

    for i = 1, BUYBACK_ITEMS_PER_PAGE do
        local button = _G["MerchantItem" .. i .. "ItemButton"]
        local icon = button.icon
        local iconBorder = button.IconBorder
        local item = _G["MerchantItem" .. i]
        item:StripTextures(true)
        item:CreateBackdrop(constBackdropFrameSmallerBorder, true, 6, 6)

        button:StripTextures()
        button:SetPoint("TOPLEFT", item, "TOPLEFT", 4, -4)

        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", -1, 1)

        iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        iconBorder:SetAllPoints(button)
        iconBorder:SetParent(button)

        hooksecurefunc(iconBorder, "SetVertexColor", function(self)
            self:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        end)


        _G["MerchantItem" .. i .. "MoneyFrame"]:ClearAllPoints()
        _G["MerchantItem" .. i .. "MoneyFrame"]:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)
    end

    MerchantBuyBackItemItemButton:StripTextures()

    local backDrop = CreateFrame("Frame", nil, MerchantBuyBackItemItemButton, "GwActionButtonBackdropTmpl")
    local backDropSize = 1
    if MerchantBuyBackItemItemButton:GetWidth() > 40 then
        backDropSize = 2
    end

    backDrop:SetPoint("TOPLEFT", MerchantBuyBackItemItemButton, "TOPLEFT", -backDropSize, backDropSize)
    backDrop:SetPoint("BOTTOMRIGHT", MerchantBuyBackItemItemButton, "BOTTOMRIGHT", backDropSize, -backDropSize)
    MerchantBuyBackItemItemButton.gwBackdrop = backDrop

    MerchantBuyBackItemItemButton.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    MerchantBuyBackItemItemButton.IconBorder:SetAllPoints(MerchantBuyBackItemItemButton)
    MerchantBuyBackItemItemButton.IconBorder:SetParent(MerchantBuyBackItemItemButton)
    hooksecurefunc(MerchantBuyBackItemItemButton.IconBorder, "SetVertexColor", function(self)
        self:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    end)

    MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    MerchantBuyBackItemItemButtonIconTexture:ClearAllPoints()
    MerchantBuyBackItemItemButtonIconTexture:SetPoint("TOPLEFT", 1, -1)
    MerchantBuyBackItemItemButtonIconTexture:SetPoint("BOTTOMRIGHT", -1, 1)

    MerchantRepairItemButton:SkinButton(false, false, true)
    MerchantRepairItemButton:GetRegions():SetTexCoord(0.04, 0.24, 0.06, 0.5)

    MerchantGuildBankRepairButton:SkinButton(false, false, true)
    MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52)

    MerchantRepairAllButton:SkinButton(false, false, true)
    MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)

    GW.HandleNextPrevButton(MerchantNextPageButton, nil, true)
    GW.HandleNextPrevButton(MerchantPrevPageButton, nil, true)
    MerchantNextPageButton:ClearAllPoints()
    MerchantNextPageButton:SetPoint("LEFT", MerchantPageText, "RIGHT", 100, 4)
end
GW.LoadMerchantFrameSkin = LoadMerchantFrameSkin