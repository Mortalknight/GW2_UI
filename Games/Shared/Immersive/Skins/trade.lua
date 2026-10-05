---@class GW2
local GW = select(2, ...)

-- trade window: only art and fonts, the trade and cancel buttons keep blizzards scripts;
-- the gold input is a forbidden frame, it keeps blizzards look
local WINDOW_ICON = "Interface/AddOns/GW2_UI/textures/character/currency-window-icon.png"
local INSETS = {"TradePlayerItemsInset", "TradeRecipientItemsInset", "TradePlayerEnchantInset", "TradeRecipientEnchantInset", "TradePlayerInputMoneyInset", "TradeRecipientMoneyInset"}
local HIGHLIGHTS = {"TradeHighlightPlayer", "TradeHighlightRecipient", "TradeHighlightPlayerEnchant", "TradeHighlightRecipientEnchant"}
local HIDDEN_ART = {"TradeFramePlayerPortrait", "TradeFrameRecipientPortrait", "TradeRecipientPortraitFrame", "TradeRecipientMoneyBg"}

local function SkinTradeItem(prefix)
    local button = _G[prefix .. "ItemButton"]
    local icon = _G[prefix .. "ItemButtonIconTexture"]
    _G[prefix .. "NameFrame"]:SetAlpha(0)
    _G[prefix .. "SlotTexture"]:SetAlpha(0)

    button:GwStripTextures()
    button:GwStyleButton()
    icon:GwSetInside(button)
    GW.HandleIcon(icon, true, GW.BackdropTemplates.ColorableBorderOnly)
    GW.HandleIconBorder(button.IconBorder, icon.backdrop)
end

local function ApplyTradeSkin()
    TradeFrame:GwStripTextures()
    GW.HandlePortraitFrameArt(TradeFrame)
    if TradeFrame.RecipientOverlay then
        TradeFrame.RecipientOverlay:GwStripTextures()
    end
    for _, name in ipairs(HIDDEN_ART) do
        if _G[name] then
            _G[name]:SetAlpha(0)
        end
    end

    GW.SkinSmallWindow(TradeFrame, TRADE, WINDOW_ICON, TradeFrame.CloseButton or TradeFrameCloseButton)

    for _, name in ipairs(INSETS) do
        local inset = _G[name]
        inset:GwStripTextures()
        if inset.NineSlice then
            inset.NineSlice:Hide()
        end
        GW.AddDetailsBackground(inset)
    end

    for i = 1, MAX_TRADE_ITEMS do
        SkinTradeItem("TradePlayerItem" .. i)
        SkinTradeItem("TradeRecipientItem" .. i)
    end

    -- the green glow when a side accepted
    local r, g, b = GW.Colors.SkinColors.Positive:GetRGB()
    for _, name in ipairs(HIGHLIGHTS) do
        for _, part in ipairs({"Top", "Middle", "Bottom"}) do
            _G[name .. part]:SetColorTexture(r, g, b, 0.2)
        end
    end

    TradeFramePlayerNameText:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    TradeFrameRecipientNameText:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    TradeFrameTradeButton:GwSkinButton(false, true)
    TradeFrameCancelButton:GwSkinButton(false, true)
end

local function LoadTradeSkin()
    if not GW.settings.skins.trade.enabled then return end
    GW.RegisterLoadHook(ApplyTradeSkin, "Blizzard_UIPanels_Game", TradeFrame)
end
GW.LoadTradeSkin = LoadTradeSkin
