local _, GW = ...

local function UpdateRepairButtons()
    MerchantRepairAllButton:ClearAllPoints()
    MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 90, 32)
    MerchantRepairItemButton:ClearAllPoints()
    MerchantRepairItemButton:SetPoint("RIGHT", MerchantRepairAllButton, "LEFT", -5, 0)
    -- to be sure
    if MerchantSellAllJunkButton then
        MerchantSellAllJunkButton:ClearAllPoints()
        MerchantSellAllJunkButton:SetPoint("RIGHT", MerchantRepairAllButton, "LEFT", 117, 0)
    end
end

local function UpdateMerchantInfo()
    for i = 1, MERCHANT_ITEMS_PER_PAGE do
        local button = _G["MerchantItem" .. i .. "ItemButton"]

        local money = _G["MerchantItem" .. i .. "MoneyFrame"]
        money:ClearAllPoints()
        money:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 5, -3)

        local currency = _G["MerchantItem" .. i .. "AltCurrencyFrame"]
        currency:ClearAllPoints()

        if button.price and button.extendedCost then
            currency:SetPoint("LEFT", money, "RIGHT", -8, 0)
        else
            currency:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 5, -3)
        end
    end
end

local function SkinMerchantFrameItemButton(i)
    local button = _G["MerchantItem" .. i .. "ItemButton"]
    local icon = button.icon
    local iconBorder = button.IconBorder
    local item = _G["MerchantItem" .. i]

    item:GwStripTextures(true)
    item:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 6, 6)
    item.backdrop:SetFrameLevel(item:GetFrameLevel())

    button:GwStripTextures()
    button:GwStyleButton()
    button:SetPoint("TOPLEFT", item, "TOPLEFT", 4, -4)

    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", -1, 1)

    iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    iconBorder:SetAllPoints(button)
    iconBorder:SetParent(button)

    GW.HandleIcon(icon, true, GW.BackdropTemplates.ColorableBorderOnly)
    GW.HandleIconBorder(iconBorder, icon.backdrop)

    _G["MerchantItem" .. i .. "MoneyFrame"]:ClearAllPoints()
    _G["MerchantItem" .. i .. "MoneyFrame"]:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)

    item.isGw2Skinned = true
end
GW.SkinMerchantFrameItemButton = SkinMerchantFrameItemButton

local function LoadMerchantFrameSkin()
    if not GW.settings.MERCHANT_SKIN_ENABLED then return end

    MerchantMoneyBg:GwStripTextures()
    MerchantMoneyInset:GwStripTextures()
    MerchantFrame:GwStripTextures()
    MerchantFrame.NineSlice:Hide()
    MerchantFrame.TopTileStreaks:Hide()

    local r = {MerchantFrame:GetRegions()}
    local i = 1
    local headerText
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            if i == 2 then headerText = c break end
            i = i + 1
        end
    end

    GW.CreateFrameHeaderWithBody(MerchantFrame, headerText, "Interface/AddOns/GW2_UI/textures/character/macro-window-icon.png", {MerchantFrameInset, MerchantMoneyInset}, nil, false, true)
    MerchantFrame.gwHeader.windowIcon:SetSize(65, 65)
    MerchantFrame.gwHeader.windowIcon:ClearAllPoints()
    MerchantFrame.gwHeader.windowIcon:SetPoint("CENTER", MerchantFrame.gwHeader.BGLEFT, "LEFT", 25, -5)
    headerText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    MerchantFrameInset.NineSlice:Hide()

    MerchantFrameCloseButton:GwSkinButton(true)
    MerchantFrameCloseButton:SetSize(20, 20)
    MerchantFrameCloseButton:SetPoint("TOPRIGHT", MerchantFrame, "TOPRIGHT", -10, -2)
    MerchantFramePortrait:Hide()

    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
        SetPortraitTexture(MerchantFrame.gwHeader.windowIcon, "NPC")
        if GW.Mists then
            local numMerchantItems = GetMerchantNumItems()
            local index = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE
            for i = 1, MERCHANT_ITEMS_PER_PAGE do
                index = index + 1

                if index <= numMerchantItems then
                    local button = _G["MerchantItem" .. i .. "ItemButton"]
                    local name = _G["MerchantItem" .. i .. "Name"]

                    if button.link then
                        local quality = C_Item.GetItemQualityByID(button.link)
                        if quality and quality > 1 then
                            local r, g, b = C_Item.GetItemQualityColor(quality)
                            button.icon.backdrop:SetBackdropBorderColor(r, g, b)
                            name:SetTextColor(r, g, b)
                        else
                            button.icon.backdrop:SetBackdropBorderColor(1, 1, 1)
                            name:SetTextColor(1, 1, 1)
                        end
                    else
                        button.icon.backdrop:SetBackdropBorderColor(1, 1, 1)
                        name:SetTextColor(1, 1, 1)
                    end
                end

                local itemName = GetBuybackItemInfo(GetNumBuybackItems())
                if itemName then
                    local quality = C_Item.GetItemQualityByID(itemName)
                    if quality and quality > 1 then
                        local r, g, b = C_Item.GetItemQualityColor(quality)
                        MerchantBuyBackItemItemButtonIconTexture.backdrop:SetBackdropBorderColor(r, g, b)
                        MerchantBuyBackItemName:SetTextColor(r, g, b)
                    else
                        MerchantBuyBackItemItemButtonIconTexture.backdrop:SetBackdropBorderColor(1, 1, 1)
                        MerchantBuyBackItemName:SetTextColor(1, 1, 1)
                    end
                else
                    MerchantBuyBackItemItemButtonIconTexture.backdrop:SetBackdropBorderColor(1, 1, 1)
                end
            end

            MerchantRepairText:SetPoint('BOTTOMLEFT', 14, 69)
        end
    end)

    hooksecurefunc(MerchantFrame, "SetWidth", function()
        local w2, h2 = MerchantFrame:GetSize()
        MerchantFrame.tex:SetSize(w2 + 50, h2 + 50)
    end)

    MerchantFrame:SetWidth(360)

    MerchantBuyBackItem:SetPoint("TOPLEFT", MerchantItem10, "BOTTOMLEFT", 0, -50)
    MerchantBuyBackItem:GwStripTextures(true)
    MerchantBuyBackItem:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 6, 6)
    MerchantBuyBackItem.backdrop:SetFrameLevel(MerchantBuyBackItem:GetFrameLevel())
    MerchantBuyBackItem.backdrop:SetPoint("TOPLEFT", -6, 6)
    MerchantBuyBackItem.backdrop:SetPoint("BOTTOMRIGHT", 6, -6)

    if GW.Retail then
        MerchantExtraCurrencyInset:GwStripTextures()
        MerchantExtraCurrencyBg:GwStripTextures()
        MerchantFrame.FilterDropdown:GwHandleDropDownBox()
    end

    MerchantItem1:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 24, -69)

    GW.HandleTabs(MerchantFrameTab1)
    GW.HandleTabs(MerchantFrameTab2)

    MerchantFrameTab1:SetSize(80, 24)
    MerchantFrameTab2:SetSize(80, 24)

    MerchantFrameTab1:ClearAllPoints()
    MerchantFrameTab1:SetPoint("TOPLEFT", MerchantFrame, "BOTTOMLEFT", 0, 0)

    MerchantFrameTab2:ClearAllPoints()
    MerchantFrameTab2:SetPoint("LEFT", MerchantFrameTab1, "RIGHT", 0, 0)

    hooksecurefunc("PanelTemplates_SelectTab", function(tab)
        local name = tab:GetName()
        local text = tab.Text or _G[name .. "Text"]
        text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2))
    end)

    for i = 1, MERCHANT_ITEMS_PER_PAGE do
        if not _G["MerchantItem" .. i].isGw2Skinned then
            SkinMerchantFrameItemButton(i)
        end
    end

    MerchantBuyBackItemItemButton:GwStripTextures()

    local backDrop = CreateFrame("Frame", nil, MerchantBuyBackItemItemButton, "GwActionButtonBackdropTmpl")
    local backDropSize = 1
    if MerchantBuyBackItemItemButton:GetWidth() > 40 then
        backDropSize = 2
    end

    backDrop:SetPoint("TOPLEFT", MerchantBuyBackItemItemButton, "TOPLEFT", -backDropSize, backDropSize)
    backDrop:SetPoint("BOTTOMRIGHT", MerchantBuyBackItemItemButton, "BOTTOMRIGHT", backDropSize, -backDropSize)
    MerchantBuyBackItemItemButton.gwBackdrop = backDrop

    if UndoFrame then
        UndoFrame.Arrow:SetPoint("CENTER", MerchantBuyBackItemItemButton, "CENTER")
    end

    MerchantBuyBackItemItemButton.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    MerchantBuyBackItemItemButton.IconBorder:SetAllPoints(MerchantBuyBackItemItemButton)
    MerchantBuyBackItemItemButton.IconBorder:SetParent(MerchantBuyBackItemItemButton)
    hooksecurefunc(MerchantBuyBackItemItemButton.IconBorder, "SetVertexColor", function(self)
        self:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    end)

    MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    MerchantBuyBackItemItemButtonIconTexture:ClearAllPoints()
    MerchantBuyBackItemItemButtonIconTexture:SetPoint("TOPLEFT", 1, -1)
    MerchantBuyBackItemItemButtonIconTexture:SetPoint("BOTTOMRIGHT", -1, 1)

    if GW.Mists then
        GW.HandleIcon(MerchantBuyBackItemItemButtonIconTexture, true, GW.BackdropTemplates.ColorableBorderOnly)
        GW.HandleIconBorder(MerchantBuyBackItemItemButton.IconBorder, MerchantBuyBackItemItemButtonIconTexture.backdrop)
    end

    MerchantRepairItemButton:GwSkinButton(false, false, true)
    MerchantRepairItemButton:GetRegions():GwSetInside()
    if MerchantRepairItemButton.Icon then
        MerchantRepairItemButton.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    else
        MerchantRepairItemButton:GetRegions():SetTexCoord(0.04, 0.24, 0.06, 0.5)
    end

    MerchantGuildBankRepairButton:SetPoint("LEFT", MerchantRepairAllButton, "RIGHT", 5, 0)
    MerchantGuildBankRepairButton:GwSkinButton(false, false, true)
    MerchantGuildBankRepairButton:GetRegions():GwSetInside()
    if MerchantGuildBankRepairButton.Icon then
        MerchantGuildBankRepairButton.Icon:SetTexCoord(0.61, 0.82, 0.1, 0.52)
    else
        MerchantGuildBankRepairButton:GetRegions():SetTexCoord(0.04, 0.24, 0.06, 0.5)
    end

    MerchantRepairAllButton:GwSkinButton(false, false, true)
    MerchantRepairAllButton:GetRegions():GwSetInside()
    if MerchantRepairAllButton.Icon then
        MerchantRepairAllButton.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    else
        MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
    end

    if MerchantSellAllJunkButton then
        MerchantSellAllJunkButton:GwSkinButton(false, false, true)
        MerchantSellAllJunkButton.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        MerchantSellAllJunkButton:GetRegions():GwSetInside()
    end


    for _, btn in next, {MerchantNextPageButton, MerchantPrevPageButton} do
        GW.HandleNextPrevButton(btn, nil, true)
        for _, c in pairs( {btn:GetRegions()} ) do
            if c:GetObjectType() == "FontString" then
                c:SetTextColor(1, 1, 1)
                break
            end
        end
    end
    MerchantPageText:SetTextColor(1, 1, 1)

    MerchantNextPageButton:ClearAllPoints()
    MerchantNextPageButton:SetPoint("LEFT", MerchantPageText, "RIGHT", 100, 4)

    hooksecurefunc("MerchantFrame_UpdateRepairButtons", UpdateRepairButtons)
    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", UpdateMerchantInfo)
end
GW.LoadMerchantFrameSkin = LoadMerchantFrameSkin