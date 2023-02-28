local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder
local constBackdropFrameSmallerBorder = GW.skins.constBackdropFrameSmallerBorder

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
    if not GW.GetSetting("MERCHANT_SKIN_ENABLED") then return end

    MerchantFrame:GwStripTextures()
    MerchantFrame.TitleBg:Hide()
    MerchantFrame.TopTileStreaks:Hide()
    MerchantFrame:GwCreateBackdrop()

    MerchantFrameInset:GwCreateBackdrop(constBackdropFrameBorder)

    MerchantFrameCloseButton:GwSkinButton(true)
    MerchantFrameCloseButton:SetSize(20, 20)

    local tex = MerchantFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", MerchantFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = MerchantFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    MerchantFrame.tex = tex
    hooksecurefunc(MerchantFrame, "SetWidth", function()
        local w2, h2 = MerchantFrame:GetSize()
        MerchantFrame.tex:SetSize(w2 + 50, h2 + 50)
    end)

    local r = {MerchantFrame:GetRegions()}
    local i = 1
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            if i == 2 then c:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE"); break end
            i = i + 1
        end
    end

    MerchantFrame:SetWidth(360)

    MerchantBuyBackItem:GwStripTextures(true)
    MerchantBuyBackItem:GwCreateBackdrop(constBackdropFrameSmallerBorder, true, 6, 6)
    MerchantBuyBackItem.backdrop:SetPoint("TOPLEFT", -6, 6)
    MerchantBuyBackItem.backdrop:SetPoint("BOTTOMRIGHT", 6, -6)


    MerchantMoneyBg:GwStripTextures()
    MerchantMoneyInset:GwStripTextures()

    MerchantItem1:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 24, -69)

    MerchantFrameTab1:GwSkinButton(false, true)
    MerchantFrameTab2:GwSkinButton(false, true)

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
    MerchantRepairItemButton:GetRegions():SetTexCoord(0.04, 0.24, 0.06, 0.5)

    MerchantGuildBankRepairButton:GwSkinButton(false, false, true)
    MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52)

    MerchantRepairAllButton:GwSkinButton(false, false, true)
    MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)

    -- added repar cost to the tooltio
    MerchantRepairAllButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(MerchantRepairAllButton, "ANCHOR_RIGHT");
        local repairAllCost, canRepair = GetRepairAllCost()
        if canRepair and repairAllCost > 0 then
            GameTooltip:SetText(REPAIR_ALL_ITEMS)
            SetTooltipMoney(GameTooltip, repairAllCost)
        end
        GameTooltip:Show()
    end)
    MerchantRepairAllButton:SetScript("OnLeave", GameTooltip_Hide)

    GW.HandleNextPrevButton(MerchantNextPageButton, nil, true)
    GW.HandleNextPrevButton(MerchantPrevPageButton, nil, true)
    MerchantNextPageButton:ClearAllPoints()
    MerchantNextPageButton:SetPoint("LEFT", MerchantPageText, "RIGHT", 100, 4)
end
GW.LoadMerchantFrameSkin = LoadMerchantFrameSkin