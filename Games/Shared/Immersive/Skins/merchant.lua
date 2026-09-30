---@class GW2
local GW = select(2, ...)

local ITEM_BORDER = "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png"

-- repair and junk buttons: the icon crop of their modern Icon, else of the classic region
local REPAIR_BUTTONS = {
    { name = "MerchantRepairItemButton", iconCoords = { 0.07, 0.93, 0.07, 0.93 }, classicCoords = { 0.04, 0.24, 0.06, 0.5 } },
    { name = "MerchantGuildBankRepairButton", iconCoords = { 0.61, 0.82, 0.1, 0.52 }, classicCoords = { 0.04, 0.24, 0.06, 0.5 } },
    { name = "MerchantRepairAllButton", iconCoords = { 0.07, 0.93, 0.07, 0.93 } },
    { name = "MerchantSellAllJunkButton", iconCoords = { 0.07, 0.93, 0.07, 0.93 } },
}

local skinned = false
local skinnedSlots = {}

local function StyleItemIcon(icon)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", -1, 1)
end

-- the extended vendor adds slots later, so this is safe to call again
local function SkinMerchantFrameItemButton(index)
    local slot = _G["MerchantItem" .. index]
    if skinnedSlots[slot] then return end
    skinnedSlots[slot] = true

    slot:GwStripTextures(true)
    slot:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 6, 6)
    slot.backdrop:SetFrameLevel(slot:GetFrameLevel())

    local button = _G["MerchantItem" .. index .. "ItemButton"]
    button:GwStripTextures()
    button:GwStyleButton()
    button:SetPoint("TOPLEFT", slot, "TOPLEFT", 4, -4)
    StyleItemIcon(button.icon)

    button.IconBorder:SetTexture(ITEM_BORDER)
    button.IconBorder:SetAllPoints(button)
    GW.HandleIcon(button.icon, true, GW.BackdropTemplates.ColorableBorderOnly)
    GW.HandleIconBorder(button.IconBorder, button.icon.backdrop)
end
GW.SkinMerchantFrameItemButton = SkinMerchantFrameItemButton

-- prices sit next to the item; a second currency follows the gold price
local function PlacePrices()
    for index = 1, MERCHANT_ITEMS_PER_PAGE do
        local button = _G["MerchantItem" .. index .. "ItemButton"]
        local money = _G["MerchantItem" .. index .. "MoneyFrame"]
        local currency = _G["MerchantItem" .. index .. "AltCurrencyFrame"]

        money:ClearAllPoints()
        money:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 5, -3)
        currency:ClearAllPoints()
        if button.price and button.extendedCost then
            currency:SetPoint("LEFT", money, "RIGHT", -8, 0)
        else
            currency:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 5, -3)
        end
    end
end

-- the junk button sits between the two repair buttons; without guild repair Blizzard puts the label behind them
local function PlaceRepairButtons()
    MerchantRepairText:ClearAllPoints()
    MerchantRepairText:SetPoint("BOTTOMLEFT", MerchantFrame, "BOTTOMLEFT", 14, 69)
    MerchantRepairAllButton:ClearAllPoints()
    MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 90, 32)
    MerchantRepairItemButton:ClearAllPoints()
    MerchantRepairItemButton:SetPoint("RIGHT", MerchantRepairAllButton, "LEFT", -5, 0)
    if MerchantSellAllJunkButton then
        MerchantSellAllJunkButton:ClearAllPoints()
        MerchantSellAllJunkButton:SetPoint("RIGHT", MerchantRepairAllButton, "LEFT", 117, 0)
    end
end

-- item name and border in quality color, white up to common items
local function ColorByQuality(item, name, backdrop)
    local quality = item and C_Item.GetItemQualityByID(item)
    local r, g, b = GW.Colors.FallbackWhite:GetRGB()
    if quality and quality > Enum.ItemQuality.Common then
        r, g, b = C_Item.GetItemQualityColor(quality)
    end
    backdrop:SetBackdropBorderColor(r, g, b)
    if name then
        name:SetTextColor(r, g, b)
    end
end

-- Mists' merchant leaves names and borders uncolored
local function ColorItemsByQuality()
    local firstIndex = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE
    for index = 1, min(MERCHANT_ITEMS_PER_PAGE, GetMerchantNumItems() - firstIndex) do
        local button = _G["MerchantItem" .. index .. "ItemButton"]
        ColorByQuality(button.link, _G["MerchantItem" .. index .. "Name"], button.icon.backdrop)
    end

    local buybackName = GetBuybackItemInfo(GetNumBuybackItems())
    ColorByQuality(buybackName, buybackName and MerchantBuyBackItemName, MerchantBuyBackItemItemButtonIconTexture.backdrop)
end

local function OnMerchantInfoUpdate()
    GW.SetHeaderPortrait(MerchantFrame.gwHeader, "NPC")
    if GW.Mists then
        ColorItemsByQuality()
    end
    PlacePrices()
end

local function SkinHeader()
    -- the classic frame has no title key, its second font string is the title
    local title = MerchantFrameTitleText
    if not GW.Retail then
        local found = 0
        for _, region in ipairs({ MerchantFrame:GetRegions() }) do
            if region:GetObjectType() == "FontString" then
                found = found + 1
                if found == 2 then
                    title = region
                    break
                end
            end
        end
    end

    GW.CreateFrameHeaderWithBody(MerchantFrame, title, "Interface/AddOns/GW2_UI/textures/character/macro-window-icon.png", { MerchantFrameInset, MerchantMoneyInset }, nil, false, true)
    local icon = MerchantFrame.gwHeader.windowIcon
    icon:SetSize(48, 48)
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", MerchantFrame.gwHeader, "BOTTOMLEFT", 30, 19)
    title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
end

local function SkinBuyback()
    MerchantBuyBackItem:SetPoint("TOPLEFT", MerchantItem10, "BOTTOMLEFT", 0, -50)
    MerchantBuyBackItem:GwStripTextures(true)
    MerchantBuyBackItem:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 6, 6)
    MerchantBuyBackItem.backdrop:SetFrameLevel(MerchantBuyBackItem:GetFrameLevel())
    MerchantBuyBackItem.backdrop:SetPoint("TOPLEFT", -6, 6)
    MerchantBuyBackItem.backdrop:SetPoint("BOTTOMRIGHT", 6, -6)

    local button = MerchantBuyBackItemItemButton
    button:GwStripTextures()
    local frameSize = button:GetWidth() > 40 and 2 or 1
    local frame = CreateFrame("Frame", nil, button, "GwActionButtonBackdropTmpl")
    frame:SetPoint("TOPLEFT", -frameSize, frameSize)
    frame:SetPoint("BOTTOMRIGHT", frameSize, -frameSize)
    button.gwBackdrop = frame
    if UndoFrame then
        UndoFrame.Arrow:SetPoint("CENTER", button, "CENTER")
    end

    -- Blizzard resets the border texture along with its quality color
    button.IconBorder:SetTexture(ITEM_BORDER)
    button.IconBorder:SetAllPoints(button)
    hooksecurefunc(button.IconBorder, "SetVertexColor", function(border) border:SetTexture(ITEM_BORDER) end)

    StyleItemIcon(MerchantBuyBackItemItemButtonIconTexture)
    if GW.Mists then
        GW.HandleIcon(MerchantBuyBackItemItemButtonIconTexture, true, GW.BackdropTemplates.ColorableBorderOnly)
        GW.HandleIconBorder(button.IconBorder, MerchantBuyBackItemItemButtonIconTexture.backdrop)
    end
end

local function SkinButtons()
    for _, info in ipairs(REPAIR_BUTTONS) do
        local button = _G[info.name]
        if button then
            button:GwSkinButton(false, false, true)
            button:GetRegions():GwSetInside()
            if button.Icon then
                button.Icon:SetTexCoord(unpack(info.iconCoords))
            elseif info.classicCoords then
                button:GetRegions():SetTexCoord(unpack(info.classicCoords))
            end
        end
    end
    -- the classic repair all icon is a rotated quarter of the repair sheet
    if not MerchantRepairAllButton.Icon then
        MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
    end
    MerchantGuildBankRepairButton:SetPoint("LEFT", MerchantRepairAllButton, "RIGHT", 5, 0)

    for _, button in ipairs({ MerchantNextPageButton, MerchantPrevPageButton }) do
        GW.HandleNextPrevButton(button, nil, true)
        for _, region in ipairs({ button:GetRegions() }) do
            if region:GetObjectType() == "FontString" then
                region:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
                break
            end
        end
    end
    MerchantPageText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    MerchantNextPageButton:ClearAllPoints()
    MerchantNextPageButton:SetPoint("LEFT", MerchantPageText, "RIGHT", 100, 4)

    MerchantFrameCloseButton:GwSkinButton(true)
    MerchantFrameCloseButton:SetSize(20, 20)
    MerchantFrameCloseButton:SetPoint("TOPRIGHT", MerchantFrame, "TOPRIGHT", -10, -2)
end

local function SkinTabs()
    local previous
    for _, tab in ipairs({ MerchantFrameTab1, MerchantFrameTab2 }) do
        GW.HandleTabs(tab)
        tab:SetSize(80, 24)
        tab:ClearAllPoints()
        if previous then
            tab:SetPoint("LEFT", previous, "RIGHT", 0, 0)
        else
            tab:SetPoint("TOPLEFT", MerchantFrame, "BOTTOMLEFT", 0, 0)
        end
        previous = tab
    end
end

local function LoadMerchantFrameSkin()
    -- also runs after a profile switch, the skin can not be undone anyway
    if skinned or not GW.settings.skins.merchant.enabled then return end
    skinned = true

    for _, region in ipairs({ MerchantMoneyBg, MerchantMoneyInset, MerchantFrame }) do
        region:GwStripTextures()
    end
    MerchantFrame.NineSlice:Hide()
    MerchantFrame.TopTileStreaks:Hide()
    MerchantFrameInset.NineSlice:Hide()
    MerchantFramePortrait:Hide()
    if MerchantExtraCurrencyInset then
        MerchantExtraCurrencyInset:GwStripTextures()
        MerchantExtraCurrencyBg:GwStripTextures()
    end
    if MerchantFrame.FilterDropdown then
        MerchantFrame.FilterDropdown:GwHandleDropDownBox()
    end

    SkinHeader()
    -- the background follows the width the extended vendor sets
    hooksecurefunc(MerchantFrame, "SetWidth", function()
        local width, height = MerchantFrame:GetSize()
        MerchantFrame.tex:SetSize(width + 50, height + 50)
    end)
    MerchantFrame:SetWidth(360)

    MerchantItem1:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 24, -69)
    for index = 1, MERCHANT_ITEMS_PER_PAGE do
        SkinMerchantFrameItemButton(index)
    end
    SkinBuyback()
    SkinButtons()
    SkinTabs()

    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", OnMerchantInfoUpdate)
    hooksecurefunc("MerchantFrame_UpdateRepairButtons", PlaceRepairButtons)
end
GW.LoadMerchantFrameSkin = LoadMerchantFrameSkin
