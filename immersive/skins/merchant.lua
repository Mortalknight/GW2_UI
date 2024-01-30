local _, GW = ...
local constBackdropFrameBorder = GW.BackdropTemplates.OnlyBorder
local constBackdropFrameSmallerBorder = GW.BackdropTemplates.DefaultWithSmallBorder

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
    item:GwCreateBackdrop(constBackdropFrameSmallerBorder, true, 6, 6)

    button:GwStripTextures()
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
GW.SkinMerchantFrameItemButton = SkinMerchantFrameItemButton

local function LoadMerchantFrameSkin()
    if not GW.settings.MERCHANT_SKIN_ENABLED then return end

    MerchantMoneyBg:GwStripTextures()
    MerchantMoneyInset:GwStripTextures()
    MerchantFrame:GwStripTextures()
    MerchantFrame.NineSlice:Hide()
    MerchantFrame.TopTileStreaks:Hide()
    MerchantFrame:GwCreateBackdrop()

    local r = {MerchantFrame:GetRegions()}
    local i = 1
    local headerText
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            if i == 2 then headerText = c break end
            i = i + 1
        end
    end

    GW.CreateFrameHeaderWithBody(MerchantFrame, headerText, "Interface/AddOns/GW2_UI/textures/character/macro-window-icon", {MerchantFrameInset, MerchantMoneyInset})
    MerchantFrame.gwHeader.windowIcon:SetSize(65, 65)
    MerchantFrame.gwHeader.windowIcon:ClearAllPoints()
    MerchantFrame.gwHeader.windowIcon:SetPoint("CENTER", MerchantFrame.gwHeader.BGLEFT, "LEFT", 25, -5)

    MerchantFrameInset.NineSlice:Hide()

    MerchantFrameCloseButton:GwSkinButton(true)
    MerchantFrameCloseButton:SetSize(20, 20)
    MerchantFramePortrait:Hide()

    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
        SetPortraitTexture(MerchantFrame.gwHeader.windowIcon, "NPC");
    end)

    hooksecurefunc(MerchantFrame, "SetWidth", function()
        local w2, h2 = MerchantFrame:GetSize()
        MerchantFrame.tex:SetSize(w2 + 50, h2 + 50)
    end)

    MerchantFrame:SetWidth(360)

    MerchantBuyBackItem:SetPoint("TOPLEFT", MerchantItem10, "BOTTOMLEFT", 0, -50)
    MerchantBuyBackItem:GwStripTextures(true)
    MerchantBuyBackItem:GwCreateBackdrop(constBackdropFrameSmallerBorder, true, 6, 6)
    MerchantBuyBackItem.backdrop:SetPoint("TOPLEFT", -6, 6)
    MerchantBuyBackItem.backdrop:SetPoint("BOTTOMRIGHT", 6, -6)

    MerchantExtraCurrencyInset:GwStripTextures()
    MerchantExtraCurrencyBg:GwStripTextures()

    MerchantFrameLootFilter:GwSkinDropDownMenu()

    MerchantItem1:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 24, -69)

    MerchantFrameTab1:GwSkinButton(false, true, nil, nil, true)
    MerchantFrameTab2:GwSkinButton(false, true, nil, nil, true)

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
        SkinMerchantFrameItemButton(i)
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

    MerchantRepairItemButton:GwSkinButton(false, false, true)
    MerchantRepairItemButton.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    MerchantRepairItemButton:GetRegions():GwSetInside()

    MerchantGuildBankRepairButton:SetPoint("LEFT", MerchantRepairAllButton, "RIGHT", 5, 0)
    MerchantGuildBankRepairButton:GwSkinButton(false, false, true)
    MerchantGuildBankRepairButton.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    MerchantGuildBankRepairButton:GetRegions():GwSetInside()

    MerchantRepairAllButton:GwSkinButton(false, false, true)
    MerchantRepairAllButton.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    MerchantRepairAllButton:GetRegions():GwSetInside()

    if MerchantSellAllJunkButton then
        MerchantSellAllJunkButton:GwSkinButton(false, false, true)
        MerchantSellAllJunkButton.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        MerchantSellAllJunkButton:GetRegions():GwSetInside()
    end

    GW.HandleNextPrevButton(MerchantNextPageButton, nil, true)
    GW.HandleNextPrevButton(MerchantPrevPageButton, nil, true)
    MerchantNextPageButton:ClearAllPoints()
    MerchantNextPageButton:SetPoint("LEFT", MerchantPageText, "RIGHT", 100, 4)

    hooksecurefunc("MerchantFrame_UpdateRepairButtons", UpdateRepairButtons)
    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", UpdateMerchantInfo)
end
GW.LoadMerchantFrameSkin = LoadMerchantFrameSkin