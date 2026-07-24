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
    if not GW.settings.MERCHANT_SKIN_ENABLED then return end

    --[[


    ]]

    MerchantFrame:GwStripTextures()
    -- MerchantFrame.NineSlice:Hide()
    MerchantFrame.TopTileStreaks:Hide()
    MerchantFrame:GwCreateBackdrop()

    -- MerchantFrameInset.NineSlice:Hide()
    --MerchantFrameInset:GwCreateBackdrop(constBackdropFrameBorder)

    MerchantFrameCloseButton:GwSkinButton(true)
    MerchantFrameCloseButton:SetSize(20, 20)


    local r = { MerchantFrame:GetRegions() }
    local i = 1
    for _, c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            if i == 2 then
                c:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE"); break
            end
            i = i + 1
        end
    end

    -- MerchantFrame:SetWidth(360)

    -- MerchantBuyBackItem:GwStripTextures(true)
    --  MerchantBuyBackItem:GwCreateBackdrop(constBackdropFrameSmallerBorder, true, 6, 6)
    -- MerchantBuyBackItem.backdrop:SetPoint("TOPLEFT", -6, 6)
    --MerchantBuyBackItem.backdrop:SetPoint("BOTTOMRIGHT", 6, -6)

    MerchantExtraCurrencyInset:GwStripTextures()
    MerchantExtraCurrencyBg:GwStripTextures()

    MerchantMoneyBg:GwStripTextures()
    MerchantMoneyInset:GwStripTextures()

    MerchantFrameLootFilter:GwSkinDropDownMenu()

    MerchantItem1:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 24, -69)

    MerchantFrameTab1:GwSkinButton(false, true, nil, nil, true)
    MerchantFrameTab2:GwSkinButton(false, true, nil, nil, true)

    MerchantFrameTab1:SetSize(80, 24)
    MerchantFrameTab2:SetSize(80, 24)

    MerchantFrameTab2:ClearAllPoints()
    MerchantFrameTab2:SetPoint("RIGHT", MerchantFrameTab1, "RIGHT", 75, 0)

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

    GW.HandleNextPrevButton(MerchantNextPageButton, nil, true)
    GW.HandleNextPrevButton(MerchantPrevPageButton, nil, true)
    MerchantNextPageButton:ClearAllPoints()
    MerchantNextPageButton:SetPoint("LEFT", MerchantPageText, "RIGHT", 100, 4)


    MerchantFrame:GwStripTextures()
    MerchantFramePortrait:GwKill()
    GW.CreateFrameHeaderWithBody(MerchantFrame, MerchantNameText,
        "Interface/AddOns/GW2_UI/textures/character/loot-window-icon", {})
    CreateFrame("Frame", "MerchantFrameLeftPanel", MerchantFrame, "GwWindowLeftPanel");
    MerchantFrameHeader.windowIcon:SetPoint("CENTER", MerchantFrameHeader, "LEFT", -16, 5)

    MerchantFrameHeader.breadcrumb = MerchantFrameHeader:CreateFontString(nil, "overlay");
    MerchantFrameHeader.breadcrumb:ClearAllPoints()
    MerchantFrameHeader.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 14)
    MerchantFrameHeader.breadcrumb:SetJustifyH("LEFT")
    MerchantFrameHeader.breadcrumb:SetJustifyV("MIDDLE")
    MerchantFrameHeader.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    MerchantFrameHeader.breadcrumb:SetPoint("LEFT", MerchantNameText, "RIGHT", 20, 0)
    MerchantFrameHeader.breadcrumb:SetText("Unknown")
    MerchantFrameHeader.breadcrumb:SetSize(500, 40)

    hooksecurefunc(MerchantNameText, "SetText", function(self, text)
        if text == MERCHANT then
            return
        end
        MerchantNameText:SetText(MERCHANT)
        MerchantFrameHeader.breadcrumb:SetText(text)
        MerchantNameText:SetWidth(MerchantNameText:GetStringWidth())

    end)



    local w, h = MerchantFrame:GetSize()
    MerchantFrame.mover = CreateFrame("Frame", nil, MerchantFrame)
    MerchantFrame.mover:EnableMouse(true)
    MerchantFrame:SetMovable(true)
    MerchantFrame.mover:SetSize(w, 30)
    MerchantFrame.mover:SetPoint("BOTTOMLEFT", MerchantFrame, "TOPLEFT", 0, -20)
    MerchantFrame.mover:SetPoint("BOTTOMRIGHT", MerchantFrame, "TOPRIGHT", 0, 20)
    MerchantFrame.mover:RegisterForDrag("LeftButton")
    MerchantFrame:SetClampedToScreen(true)
    MerchantFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    MerchantFrame.mover:SetScript("OnDragStop", function(self)
        local self = self:GetParent()

        self:StopMovingOrSizing()
    end)
end
GW.LoadMerchantFrameSkin = LoadMerchantFrameSkin
