---@class GW2
local GW = select(2, ...)

-- the link types GameTooltip:SetHyperlink knows how to show
local TOOLTIP_LINKS = {
    item = true, spell = true, enchant = true, talent = true, glyph = true, apower = true,
    achievement = true, currency = true, quest = true, instancelock = true, keystone = true, unit = true,
}

local tooltipOwner

local function OnHyperlinkEnter(chatFrame, link)
    if GW.IsSecretValue(link) or not GW.settings.chat.hyperlinkTooltip or InCombatLockdown() then
        return
    end
    if TOOLTIP_LINKS[strmatch(link, "^[^:]+")] then
        GameTooltip:SetOwner(chatFrame, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
        tooltipOwner = chatFrame
    end
end

-- leaving the link or scrolling it away closes the tooltip it opened
local function HideTooltip(chatFrame)
    if tooltipOwner and tooltipOwner == chatFrame then
        tooltipOwner = nil
        GameTooltip:Hide()
    end
end

GW.RegisterChatModule({
    onFrame = function(chatFrame)
        chatFrame:HookScript("OnHyperlinkEnter", OnHyperlinkEnter)
        chatFrame:HookScript("OnHyperlinkLeave", HideTooltip)
        -- the wheel script gets replaced now and then, the scroll calls stay
        hooksecurefunc(chatFrame, "ScrollUp", HideTooltip)
        hooksecurefunc(chatFrame, "ScrollDown", HideTooltip)
        hooksecurefunc(chatFrame, "ScrollToTop", HideTooltip)
        hooksecurefunc(chatFrame, "ScrollToBottom", HideTooltip)
    end,
})
