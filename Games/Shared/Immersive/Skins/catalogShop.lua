---@class GW2
local GW = select(2, ...)

-- the shop keeps its own art and models, it gets our border, buttons, search box and scroll bars
local function ApplyCatalogShopSkin()
    if not GW.settings.skins.catalogShop.enabled then return end
    local frame = CatalogShopFrame

    GW.HandlePortraitFrame(frame)
    GW.HandlePortraitFrameArt(frame)
    frame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    frame:GetTitleText():GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    frame:GetTitleText():SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    GW.SkinEditBox(frame.HeaderFrame.SearchBox, {search = true})
    GW.HandleTrimScrollBar(frame.ProductContainerFrame.ProductsScrollBoxContainer.ScrollBar)

    local details = frame.CatalogShopDetailsFrame
    details.Border:Hide()
    details:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    for _, button in ipairs({details.ButtonContainer:GetChildren()}) do
        if button:IsObjectType("Button") then
            button:GwSkinButton(false, true)
        end
    end
    local priceFont = CreateFont("GW2_CatalogShopPriceFont")
    priceFont:CopyFontObject(GameFontNormalLarge)
    priceFont:SetTextColor(0, 0, 0)
    details.ButtonContainer.PurchaseButton:SetNormalFontObject(priceFont)
    details.ButtonContainer.PurchaseButton:SetHighlightFontObject(priceFont)

    local productDetails = frame.ProductDetailsContainerFrame
    productDetails.BackButton:GwSkinButton(false, true)
    GW.HandleTrimScrollBar(productDetails.DetailsProductContainerFrame.ProductsScrollBoxContainer.ScrollBar)
end

local function LoadCatalogShopSkin()
    GW.RegisterLoadHook(ApplyCatalogShopSkin, "Blizzard_CatalogShop", CatalogShopFrame)
end
GW.LoadCatalogShopSkin = LoadCatalogShopSkin
