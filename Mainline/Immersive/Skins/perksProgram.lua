local _, GW = ...

local function HandleCartToggleButton(button)
    if button.text then
        button:GwStripTextures()
        button.text:SetText(button.itemInCart and "-" or "+")

        if button.itemInCart then
            button.text:SetTextColor(1, 0.3, 0.3)
        else
            button.text:SetTextColor(0.3, 1, 0.3)
        end
    end
end

local function HandleRewardButton(child)
    local container = child.ContentsContainer
    if not container then return end

    local icon = container.Icon
    if icon then
        GW.HandleIcon(icon)

        container.IconMask:Hide()
    end

    local priceIcon = container.PriceIcon
    if priceIcon then
        GW.HandleIcon(priceIcon)
    end
    local cartButton = container.CartToggleButton
    if cartButton and not cartButton.text then
        cartButton.text = cartButton:CreateFontString(nil, "ARTWORK")
        cartButton.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.BIG_HEADER, "OUTLINE", 14)
        cartButton.text:SetPoint("CENTER")
        cartButton.text:SetTextColor(0.3, 1, 0.3)
        cartButton:GwSkinButton(false, true)
        cartButton.gwBorderFrame:Hide()

        HandleCartToggleButton(cartButton)

        hooksecurefunc(cartButton, "UpdateCartState", HandleCartToggleButton)
    end
end

local function HandleSetButtons(button)
    if not button then return end

    if not button.Icon.backdrop then
        GW.HandleIcon(button.Icon, true)
        GW.HandleIconBorder(button.IconBorder, button.Icon.backdrop)
    end

    if button.BackgroundTexture then
        button.BackgroundTexture:SetAlpha(0)
    end

    if button.HighlightTexture then
        button.HighlightTexture:SetColorTexture(1, 1, 1, .25)
        button.HighlightTexture:GwSetInside()
    end
    if button.TopBraceTexture then
        button.TopBraceTexture:Hide()
    end
    if button.BottomBraceTexture then
        button.BottomBraceTexture:Hide()
    end
end

local function HandleSortLabel(button)
    if button and button.Label then
        button.Label:SetFont("UNIT_NAME_FONT", 14)
        button.Label:SetTextColor(1, 1, 1, 1)
    end
end

local function HandleNextPrev(button)
    GW.HandleNextPrevButton(button)

    button:SetScript("OnMouseUp", nil)
    button:SetScript("OnMouseDown", nil)
end

local function DetailsScrollBoxUpdate(box)
    box:ForEachFrame(HandleSetButtons)
end

local function HandleRewards(frame)
    for _, child in next, { frame.ScrollTarget:GetChildren() } do
        HandleRewardButton(child)
    end
end

local function HandleShoppingCardButtons(button)
    if not button then return end

    if button.RemoveFromCartItemButton then
        button.RemoveFromCartItemButton.RemoveFromListButton:GwSkinButton(true)
    end

    if not button.bgSetTexture then
        button.bgSetTexture = button:CreateTexture(nil, "BACKGROUND")
        button.bgSetTexture:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/white")
        button.bgSetTexture:GwSetInside(button)
    end

    if button.Icon and not button.Icon.backdrop then
        GW.HandleIcon(button.Icon, true)
        GW.HandleIconBorder(button.IconBorder, button.Icon.backdrop)
    end

    if button.BackgroundTexture then
        if not button.BackgroundTexture.backdrop then
            button.BackgroundTexture:GwStripTextures()
            button.BackgroundTexture:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
        end

        local color = GW.GetQualityColor(button.elementData and button.elementData.itemQuality)
        button.bgSetTexture:SetVertexColor(color.r, color.g, color.b, button.elementData and button.elementData.isSetItem and 0.2 or 0)
    else
        button.bgSetTexture:SetVertexColor(0, 0, 0, 0.25)
    end

    if button.TopBraceTexture then
        button.TopBraceTexture:GwStripTextures()
    end

    if button.BottomBraceTexture then
        button.BottomBraceTexture:GwStripTextures()
    end

    if button.HighlightTexture then
        button.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
    end

    local priceIcon = button.PriceIcon
    if priceIcon then
        GW.HandleIcon(priceIcon)
    end
end

local function ShoppingCartScrollBoxUpdate(box)
    for _, child in next, { box.ScrollTarget:GetChildren() } do
        HandleShoppingCardButtons(child)
    end
end

local function PurchaseButton_EnterLeave(button)
    local label = button:GetFontString()

    label:SetTextColor(0, 0, 0, 1)
end

local function GlowEmitterFactory_Toggle(frame, target, show)
    local perks = _G.PerksProgramFrame
    local footer = perks and perks.FooterFrame
    local button = footer and footer.PurchaseButton
    if not button or target ~= button then return end

    if show then
        frame:Hide(target)
    end

    PurchaseButton_EnterLeave(target)
end

local function GlowEmitterFactory_Show(frame, target)
    GlowEmitterFactory_Toggle(frame, target, true)
end

local function GlowEmitterFactory_Hide(frame, target)
    GlowEmitterFactory_Toggle(frame, target)
end

local function PurchaseButton_OnEnter(button)
    PurchaseButton_EnterLeave(button)
end

local function PurchaseButton_OnLeave(button)
    PurchaseButton_EnterLeave(button)
end

local function SkinPerksProgram()
    if not GW.settings.PERK_PROGRAM_SKIN_ENABLED then return end

    PerksProgramFrame.ThemeContainer:SetAlpha(0)

    if PerksProgramFrame.ProductsFrame then
        PerksProgramFrame.ProductsFrame.PerksProgramFilter:GwSkinButton(false, true)

        PerksProgramFrame.ProductsFrame.PerksProgramFilter.ResetButton:GwSkinButton(true)

        PerksProgramFrame.ProductsFrame.PerksProgramFilter.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        PerksProgramFrame.ProductsFrame.PerksProgramFilter.Text:SetShadowOffset(0, 0)
        PerksProgramFrame.ProductsFrame.PerksProgramFilter.Text:SetTextColor(0, 0, 0)

        PerksProgramFrame.ProductsFrame.PerksProgramFilter:SetScript("OnEnter", function(self)
            self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            self.Text:SetShadowOffset(0, 0)
            self.Text:SetTextColor(0, 0, 0)
        end)
        PerksProgramFrame.ProductsFrame.PerksProgramFilter:SetScript("OnLeave", function(self)
            self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            self.Text:SetShadowOffset(0, 0)
            self.Text:SetTextColor(0, 0, 0)
        end)
        PerksProgramFrame.ProductsFrame.PerksProgramFilter:HookScript("OnClick", function(self)
            self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            self.Text:SetShadowOffset(0, 0)
            self.Text:SetTextColor(0, 0, 0)
            self.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        end)
        PerksProgramFrame.ProductsFrame.PerksProgramFilter:HookScript("OnMouseDown", function(self)
            self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            self.Text:SetShadowOffset(0, 0)
            self.Text:SetTextColor(0, 0, 0)
            self.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        end)

        PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Text:SetFont("UNIT_NAME_FONT", 30)
        GW.HandleIcon(PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Icon)
        PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Icon:SetSize(30, 30)

        PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame:GwStripTextures()
        PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)

        local container = PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame.SetDetailsScrollBoxContainer
        if container then
            GW.HandleTrimScrollBar(container.ScrollBar)
            GW.HandleScrollControls(container)

            hooksecurefunc(container.ScrollBox, "Update", DetailsScrollBoxUpdate)
        end

        local shoppingCart = PerksProgramFrame.ProductsFrame.PerksProgramShoppingCartFrame
        if shoppingCart then
            shoppingCart.Background:Hide()
            shoppingCart:GwStripTextures()
            shoppingCart:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
            shoppingCart.CloseButton:GwSkinButton(true)
            shoppingCart.CloseButton:SetFrameLevel(shoppingCart.backdrop:GetFrameLevel() + 1)

            shoppingCart.ClearCartButton:GwSkinButton(false, true)
            shoppingCart.PurchaseCartButton:GwSkinButton(false, true)

            shoppingCart.ClearCartButton.texture = shoppingCart.ClearCartButton:CreateTexture(nil, "ARTWORK")
            shoppingCart.ClearCartButton.texture:SetAtlas("Perks-ShoppingCart")
            shoppingCart.ClearCartButton.texture:GwSetInside(nil, 8, 8)
            shoppingCart.ClearCartButton.texture:SetDesaturated(true)

            shoppingCart.ClearCartButton.text = shoppingCart.ClearCartButton:CreateFontString(nil, "ARTWORK")
            shoppingCart.ClearCartButton.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.BIG_HEADER, "OUTLINE", 24)
            shoppingCart.ClearCartButton.text:SetPoint("CENTER")
            shoppingCart.ClearCartButton.text:SetTextColor(1, 0.3, 0.3)
            shoppingCart.ClearCartButton.text:SetText("/")

            shoppingCart.Title:SetTextColor(1, 1, 1, 1)

            local itemList = shoppingCart.ItemList
            GW.HandleTrimScrollBar(itemList.ScrollBar)
            GW.HandleScrollControls(itemList)
            hooksecurefunc(itemList.ScrollBox, "Update", ShoppingCartScrollBoxUpdate)
        end

        local carousel = PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame.CarouselFrame
        if carousel and carousel.IncrementButton then
            HandleNextPrev(carousel.IncrementButton)
            HandleNextPrev(carousel.DecrementButton)
        end

        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer:GwStripTextures()
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
        GW.HandleTrimScrollBar(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBar)
        GW.HandleScrollControls(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame:GwStripTextures()
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame.backdrop:GwSetInside(3, 3)

        HandleSortLabel(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.NameSortButton)
        HandleSortLabel(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PriceSortButton)

        hooksecurefunc(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBox, "Update", HandleRewards)
    end

    if PerksProgramFrame.FooterFrame then
        PerksProgramFrame.FooterFrame.LeaveButton:SetText(LEAVE)
        PerksProgramFrame.FooterFrame.LeaveButton:GwSkinButton(false, true)
        PerksProgramFrame.FooterFrame.PurchaseButton:GwSkinButton(false, true)
        PerksProgramFrame.FooterFrame.RefundButton:GwSkinButton(false, true)
        PerksProgramFrame.FooterFrame.AddToCartButton:GwSkinButton(false, true)
        PerksProgramFrame.FooterFrame.RemoveFromCartButton:GwSkinButton(false, true)
        PerksProgramFrame.FooterFrame.ViewCartButton:GwSkinButton(false, true)--, nil, nil, true)

        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateLeftButton:GwSkinButton(false, true)
        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateRightButton:GwSkinButton(false, true)
        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateLeftButton.Icon:SetDesaturated(true)
        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateRightButton.Icon:SetDesaturated(true)

        PerksProgramFrame.FooterFrame.TogglePlayerPreview:GwSkinCheckButton()
        PerksProgramFrame.FooterFrame.TogglePlayerPreview:SetSize(20, 20)

        PerksProgramFrame.FooterFrame.ToggleHideArmor:GwSkinCheckButton()
        PerksProgramFrame.FooterFrame.ToggleHideArmor:SetSize(20, 20)

        PerksProgramFrame.FooterFrame.ToggleMountSpecial:GwSkinCheckButton()
        PerksProgramFrame.FooterFrame.ToggleMountSpecial:SetSize(20, 20)

        PerksProgramFrame.FooterFrame.PurchaseButton:HookScript("OnEnter", PurchaseButton_OnEnter)
        PerksProgramFrame.FooterFrame.PurchaseButton:HookScript("OnLeave", PurchaseButton_OnLeave)

        if PerksProgramFrame.FooterFrame.ViewCartButton.ItemCountBG then
            PerksProgramFrame.FooterFrame.ViewCartButton.ItemCountBG:GwStripTextures()
        end

        if PerksProgramFrame.FooterFrame.ViewCartButton.ItemCountText then
            PerksProgramFrame.FooterFrame.ViewCartButton.ItemCountText:ClearAllPoints()
            PerksProgramFrame.FooterFrame.ViewCartButton.ItemCountText:SetPoint("BOTTOMLEFT", 4, 2)
        end

        PerksProgramFrame.FooterFrame.ViewCartButton.texture = PerksProgramFrame.FooterFrame.ViewCartButton:CreateTexture(nil, "ARTWORK")
        PerksProgramFrame.FooterFrame.ViewCartButton.texture:SetAtlas("Perks-ShoppingCart")
        PerksProgramFrame.FooterFrame.ViewCartButton.texture:GwSetInside(nil, 8, 8)
        PerksProgramFrame.FooterFrame.ViewCartButton.texture:SetDesaturated(true)

        -- handle the glow
        hooksecurefunc(GlowEmitterFactory, "Show", GlowEmitterFactory_Show)
        hooksecurefunc(GlowEmitterFactory, "Hide", GlowEmitterFactory_Hide)
    end
end

local function LoadPerksProgramSkin()
    GW.RegisterLoadHook(SkinPerksProgram, "Blizzard_PerksProgram", PerksProgramFrame)
end
GW.LoadPerksProgramSkin = LoadPerksProgramSkin
