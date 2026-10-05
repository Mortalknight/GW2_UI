---@class GW2
local GW = select(2, ...)

-- trade window: only art and fonts, the trade and cancel buttons keep blizzards scripts;
-- the gold input is a forbidden frame, it keeps blizzards look
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
    GW.HandleIconBorder(button.IconBorder, icon.backdrop, GW.Colors.SkinColors.IconBorder)
end

local function ApplyTradeSkin()
    TradeFrame:GwStripTextures()
    GW.HandlePortraitFrameArt(TradeFrame)
    if TradeFrame.RecipientOverlay then
        TradeFrame.RecipientOverlay:GwStripTextures()
        TradeFrame.RecipientOverlay.portrait:SetAlpha(0)
    end
    for _, name in ipairs(HIDDEN_ART) do
        if _G[name] then
            _G[name]:SetAlpha(0)
        end
    end

    GW.SkinSmallWindow(TradeFrame, TRADE, nil, TradeFrame.CloseButton or TradeFrameCloseButton)
    -- our own portrait in the header, the partner is named above their column
    local icon = TradeFrame.gwHeader.windowIcon
    icon:SetSize(48, 48)
    TradeFrame:HookScript("OnShow", function() SetPortraitTexture(icon, "player") end)

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

    -- the names sit in the header by default, they move above their money row
    for nameText, inset in pairs({[TradeFramePlayerNameText] = TradePlayerInputMoneyInset, [TradeFrameRecipientNameText] = TradeRecipientMoneyInset}) do
        nameText:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        nameText:SetJustifyH("LEFT")
        nameText:ClearAllPoints()
        nameText:SetPoint("BOTTOMLEFT", inset, "TOPLEFT", 2, 6)
        nameText:SetPoint("BOTTOMRIGHT", inset, "TOPRIGHT", -2, 6)
    end

    TradeFrameTradeButton:GwSkinButton(false, true)
    TradeFrameCancelButton:GwSkinButton(false, true)
    -- blizzard gives the cancel button its own button text, the template text is not the one shown
    TradeFrameCancelButton:GetFontString():SetTextColor(GW.Colors.Fallback:GetRGB())
    TradeFrameCancelButton:GetFontString():SetShadowOffset(0, 0)
end

local function LoadTradeSkin()
    if not GW.settings.skins.trade.enabled then return end
    GW.RegisterLoadHook(ApplyTradeSkin, "Blizzard_UIPanels_Game", TradeFrame)
end
GW.LoadTradeSkin = LoadTradeSkin
