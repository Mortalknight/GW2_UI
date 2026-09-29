---@class GW2
local GW = select(2, ...)

local ARROW_DOWN = "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png"
local WHITE = "Interface/AddOns/GW2_UI/textures/uistuff/white.png"
local ADD_COLOR = GW.Colors.SkinColors.Positive
local REMOVE_COLOR = GW.Colors.SkinColors.Negative

-- the cart toggle of a product shows a plain plus or minus; blizzard sets its art again with the state
local function UpdateCartToggle(button)
    button:GwStripTextures()
    local inCart = button.itemInCart
    button.gwSign:SetText(inCart and "-" or "+")
    button.gwSign:SetTextColor((inCart and REMOVE_COLOR or ADD_COLOR):GetRGB())
end

local function SkinProduct(row)
    local contents = row.ContentsContainer
    if not contents then return end

    if contents.Icon then
        GW.HandleIcon(contents.Icon)
        contents.IconMask:Hide()
    end
    if contents.PriceIcon then
        GW.HandleIcon(contents.PriceIcon)
    end

    local toggle = contents.CartToggleButton
    if toggle then
        toggle:GwSkinButton(false, true)
        toggle.gwBorderFrame:Hide()
        toggle.gwSign = toggle:CreateFontString(nil, "ARTWORK")
        toggle.gwSign:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, "OUTLINE", 14)
        toggle.gwSign:SetPoint("CENTER")
        UpdateCartToggle(toggle)
        hooksecurefunc(toggle, "UpdateCartState", UpdateCartToggle)
    end
end

-- an item of a set, and an item in the cart: cropped icon, quality on our border, no braces
local function SkinItemRow(row)
    if row.Icon then
        GW.HandleIcon(row.Icon, true)
        if row.IconBorder then
            GW.HandleIconBorder(row.IconBorder, row.Icon.backdrop)
        end
    end
    if row.PriceIcon then
        GW.HandleIcon(row.PriceIcon)
    end
    if row.HighlightTexture then
        row.HighlightTexture:SetColorTexture(GW.Colors.SkinColors.HighlightWhite:GetRGBA())
        row.HighlightTexture:GwSetInside()
    end
    for _, key in ipairs({"TopBraceTexture", "BottomBraceTexture"}) do
        if row[key] then
            row[key]:SetAlpha(0)
        end
    end
end

local function SkinSetItem(row)
    SkinItemRow(row)
    if row.BackgroundTexture then
        row.BackgroundTexture:SetAlpha(0)
    end
end

local function SkinCartItem(row)
    SkinItemRow(row)
    if row.RemoveFromCartItemButton then
        row.RemoveFromCartItemButton.RemoveFromListButton:GwSkinButton(true)
    end
    if row.BackgroundTexture then
        row.BackgroundTexture:GwStripTextures()
        row.BackgroundTexture:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    end
    row.gwTint = row:CreateTexture(nil, "BACKGROUND")
    row.gwTint:SetTexture(WHITE)
    row.gwTint:GwSetInside(row)
end

-- items of a set get a faint tint in their quality color, the set rows a dark one
local function TintCartItem(_, row, elementData)
    if not row.gwTint then return end
    if row.BackgroundTexture then
        local color = GW.GetQualityColor(elementData and elementData.itemQuality)
        row.gwTint:SetVertexColor(color.r, color.g, color.b, elementData and elementData.isSetItem and 0.2 or 0)
    else
        row.gwTint:SetVertexColor(0, 0, 0, 0.25)
    end
end

local function SkinScrollList(container)
    GW.HandleTrimScrollBar(container.ScrollBar)
    GW.HandleScrollControls(container)
end

local function SkinPanel(panel)
    panel:GwStripTextures()
    panel:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
end

-- a desaturated cart icon on a button, the clear button crosses it out
local function AddCartIcon(button)
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAtlas("Perks-ShoppingCart")
    icon:GwSetInside(nil, 8, 8)
    icon:SetDesaturated(true)
    button.gwCartIcon = icon
end

-- the filter button takes blizzards font objects back on every state change
local function RestyleFilterText(filter)
    filter.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    filter.Text:SetShadowOffset(0, 0)
end

local function SkinFilter(filter)
    filter:GwSkinButton(false, true)
    filter.ResetButton:GwSkinButton(true)
    RestyleFilterText(filter)
    GW.LockFontStringColor(filter.Text, 0, 0, 0)
    for _, script in ipairs({"OnEnter", "OnLeave", "OnMouseDown", "OnMouseUp"}) do
        filter:HookScript(script, RestyleFilterText)
    end
    filter.Arrow:SetTexture(ARROW_DOWN)
    hooksecurefunc(filter.Arrow, "SetAtlas", function(arrow) arrow:SetTexture(ARROW_DOWN) end)
end

local function SkinProducts(products)
    SkinFilter(products.PerksProgramFilter)

    local currency = products.PerksProgramCurrencyFrame
    currency.Text:SetFont(UNIT_NAME_FONT, 30)
    GW.HandleIcon(currency.Icon)
    currency.Icon:SetSize(30, 30)

    local details = products.PerksProgramProductDetailsContainerFrame
    SkinPanel(details)
    if details.SetDetailsScrollBoxContainer then
        SkinScrollList(details.SetDetailsScrollBoxContainer)
        GW.SkinScrollBoxFrames(details.SetDetailsScrollBoxContainer.ScrollBox, SkinSetItem)
    end
    local carousel = details.CarouselFrame
    if carousel and carousel.IncrementButton then
        GW.SkinStepperArrow(carousel.IncrementButton)
        GW.SkinStepperArrow(carousel.DecrementButton)
    end

    local cart = products.PerksProgramShoppingCartFrame
    if cart then
        cart.Background:Hide()
        SkinPanel(cart)
        cart.Title:SetTextColor(GW.Colors.FallbackWhite:GetRGBA())
        cart.CloseButton:GwSkinButton(true)
        cart.CloseButton:SetFrameLevel(cart.backdrop:GetFrameLevel() + 1)
        cart.PurchaseCartButton:GwSkinButton(false, true)

        local clear = cart.ClearCartButton
        clear:GwSkinButton(false, true)
        AddCartIcon(clear)
        clear.gwCross = clear:CreateFontString(nil, "ARTWORK")
        clear.gwCross:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, "OUTLINE", 24)
        clear.gwCross:SetPoint("CENTER")
        clear.gwCross:SetTextColor(REMOVE_COLOR:GetRGB())
        clear.gwCross:SetText("/")

        SkinScrollList(cart.ItemList)
        GW.SkinScrollBoxFrames(cart.ItemList.ScrollBox, SkinCartItem)
        -- ForEachFrame hands out (row, data), the callback gets (owner, row, data)
        cart.ItemList.ScrollBox:ForEachFrame(function(row, data) TintCartItem(nil, row, data) end)
        ScrollUtil.AddInitializedFrameCallback(cart.ItemList.ScrollBox, TintCartItem, cart)
    end

    local list = products.ProductsScrollBoxContainer
    SkinPanel(list)
    SkinScrollList(list)
    SkinPanel(list.PerksProgramHoldFrame)
    list.PerksProgramHoldFrame.backdrop:GwSetInside(3, 3)
    for _, sort in ipairs({list.NameSortButton, list.PriceSortButton}) do
        if sort and sort.Label then
            sort.Label:SetFont(UNIT_NAME_FONT, 14)
            sort.Label:SetTextColor(GW.Colors.FallbackWhite:GetRGBA())
        end
    end
    GW.SkinScrollBoxFrames(list.ScrollBox, SkinProduct)
end

local function SkinFooter(footer)
    footer.LeaveButton:SetText(LEAVE)
    for _, button in ipairs({footer.LeaveButton, footer.PurchaseButton, footer.RefundButton, footer.AddToCartButton,
        footer.RemoveFromCartButton, footer.ViewCartButton}) do
        button:GwSkinButton(false, true)
    end
    for _, button in ipairs({footer.RotateButtonContainer.RotateLeftButton, footer.RotateButtonContainer.RotateRightButton}) do
        button:GwSkinButton(false, true)
        button.Icon:SetDesaturated(true)
    end
    for _, toggle in ipairs({footer.TogglePlayerPreview, footer.ToggleHideArmor, footer.ToggleMountSpecial}) do
        toggle:GwSkinCheckButton(false, 20)
    end

    local viewCart = footer.ViewCartButton
    AddCartIcon(viewCart)
    -- the item count sits in the corner, without its bubble
    local countText, countBubble = viewCart.ItemCountText, viewCart.ItemCountBG
    if countBubble then
        countBubble:GwStripTextures()
    end
    if countText then
        countText:ClearAllPoints()
        countText:SetPoint("BOTTOMLEFT", 4, 2)
    end

    -- blizzard lets the purchase button glow and light up its text, our flat button stays plain
    local purchase = footer.PurchaseButton
    GW.LockFontStringColor(purchase:GetFontString(), 0, 0, 0)
    hooksecurefunc(GlowEmitterFactory, "Show", function(factory, target)
        if target == purchase then
            factory:Hide(target)
        end
    end)
end

local function SkinPerksProgram()
    if not GW.settings.skins.perkProgram.enabled then return end

    PerksProgramFrame.ThemeContainer:SetAlpha(0)
    if PerksProgramFrame.ProductsFrame then
        SkinProducts(PerksProgramFrame.ProductsFrame)
    end
    if PerksProgramFrame.FooterFrame then
        SkinFooter(PerksProgramFrame.FooterFrame)
    end
end

local function LoadPerksProgramSkin()
    GW.RegisterLoadHook(SkinPerksProgram, "Blizzard_PerksProgram", PerksProgramFrame)
end
GW.LoadPerksProgramSkin = LoadPerksProgramSkin
