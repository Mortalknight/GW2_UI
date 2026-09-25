---@class GW2
local GW = select(2, ...)

-- Readable items (books, notes, letters): our header with the item name, a page body and paging arrows.

local PAGE_TEXT_TYPES = {"P", "H1", "H2", "H3"}
local PAGE_ROW_Y = -40
local PAGE_BUTTON_OFFSET = 120

local function SkinPageText()
    for _, textType in ipairs(PAGE_TEXT_TYPES) do
        ItemTextPageText:SetTextColor(textType, 1, 1, 1)
    end

    hooksecurefunc(ItemTextPageText, "SetTextColor", function(pageText, textType, r, g, b)
        if r ~= 1 or g ~= 1 or b ~= 1 then
            pageText:SetTextColor(textType, 1, 1, 1)
        end
    end)
end

local function SkinScrollFrame()
    ItemTextScrollFrame:GwStripTextures()
    GW.AddDetailsBackground(ItemTextScrollFrame)

    local scrollBar = ItemTextScrollFrame.ScrollBar or ItemTextScrollFrameScrollBar
    if scrollBar.SetHideIfUnscrollable then
        GW.HandleTrimScrollBar(scrollBar)
        GW.HandleScrollControls(ItemTextScrollFrame)
        scrollBar:SetHideIfUnscrollable(true)
        scrollBar:Update()
    else
        scrollBar:GwSkinScrollBar()
        ItemTextScrollFrame:GwSkinScrollFrame()
        ItemTextScrollFrame.scrollBarHideable = 1
    end
end

local function LoadItemTextSkin()
    if not GW.settings.skins.gossip.enabled then return end

    ItemTextFrame:GwStripTextures(true)
    GW.HandlePortraitFrameArt(ItemTextFrame)

    for _, name in ipairs({"ItemTextFramePageBg", "ItemTextMaterialTopLeft", "ItemTextMaterialTopRight", "ItemTextMaterialBotLeft", "ItemTextMaterialBotRight"}) do
        local texture = _G[name]
        if texture then
            texture:SetAlpha(0)
        end
    end

    local title = ItemTextTitleText or (ItemTextFrame.TitleContainer and ItemTextFrame.TitleContainer.TitleText)
    local closeButton = ItemTextFrameCloseButton or ItemTextCloseButton or ItemTextFrame.CloseButton
    GW.SkinSmallWindow(ItemTextFrame, title, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png", closeButton)

    SkinScrollFrame()
    SkinPageText()

    ItemTextCurrentPage:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    ItemTextCurrentPage:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    GW.HandleNextPrevButton(ItemTextPrevPageButton, "left")
    GW.HandleNextPrevButton(ItemTextNextPageButton, "right")

    -- the labels are plain layer font strings, not button text, so GetFontString() does not find them
    for _, button in ipairs({ItemTextPrevPageButton, ItemTextNextPageButton}) do
        for _, region in ipairs({button:GetRegions()}) do
            if region:GetObjectType() == "FontString" then
                region:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
                region:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
            end
        end
    end

    -- blizzard offsets the page number by 20 to fit its parchment and parks the buttons in the corners,
    -- and the number is a 192 wide font string, so everything gets anchored to the frames centre instead
    ItemTextCurrentPage:ClearAllPoints()
    ItemTextCurrentPage:SetPoint("TOP", ItemTextFrame, "TOP", 0, PAGE_ROW_Y)
    ItemTextPrevPageButton:ClearAllPoints()
    ItemTextPrevPageButton:SetPoint("CENTER", ItemTextFrame, "TOP", -PAGE_BUTTON_OFFSET, PAGE_ROW_Y - 8)
    ItemTextNextPageButton:ClearAllPoints()
    ItemTextNextPageButton:SetPoint("CENTER", ItemTextFrame, "TOP", PAGE_BUTTON_OFFSET, PAGE_ROW_Y - 8)

    if ItemTextStatusBar then
        ItemTextStatusBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
        GW.AddStatusBarFrame(ItemTextStatusBar)
    end
end
GW.LoadItemTextSkin = LoadItemTextSkin
