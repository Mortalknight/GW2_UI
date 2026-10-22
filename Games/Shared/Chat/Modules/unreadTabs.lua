---@class GW2
local GW = select(2, ...)

-- the messages written to the player or the group, public channels are left out
local COUNTED = {
    WHISPER = true, BN_WHISPER = true, GUILD = true, OFFICER = true,
    PARTY = true, PARTY_LEADER = true, RAID = true, RAID_LEADER = true, RAID_WARNING = true,
    INSTANCE_CHAT = true, INSTANCE_CHAT_LEADER = true,
}

-- the round count badge of the micro menu, inside the tab: the dock clips everything above it
local function GetBadge(chatFrame)
    local tab = _G[chatFrame:GetName() .. "Tab"]
    if not tab then return end
    if not tab.gwUnread then
        local badge = CreateFrame("Frame", nil, tab)
        badge:SetSize(14, 14)
        badge:SetPoint("TOPRIGHT", tab, "TOPRIGHT", 0, -2)
        badge.background = badge:CreateTexture(nil, "BACKGROUND")
        badge.background:SetAllPoints()
        badge.background:SetTexture("Interface/AddOns/GW2_UI/textures/hud/notification-backdrop.png")
        badge.background:SetVertexColor(GW.Colors.SkinColors.NotificationBadge:GetRGBA())
        badge.text = badge:CreateFontString(nil, "OVERLAY")
        badge.text:SetPoint("CENTER", 1, 0)
        badge.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        badge.text:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        badge.text:SetShadowColor(GW.Colors.Transparent:GetRGBA())
        badge:Hide()
        tab.gwUnread = badge
    end
    return tab.gwUnread
end

local function SetUnread(chatFrame, count)
    chatFrame.gwUnreadCount = count
    local badge = GetBadge(chatFrame)
    if badge then
        badge.text:SetText(count > 9 and "9+" or count)
        badge:SetShown(count > 0)
    end

    -- a message while the chat is faded out brings its tab back, the fade itself handles the rest
    if count > 0 then
        GW.UpdateChatDockFade()
    end
end

GW.RegisterChatModule({
    setting = "unreadCount",
    onFrame = function(chatFrame)
        chatFrame:HookScript("OnShow", function(self)
            SetUnread(self, 0)
        end)
    end,
    onLine = function(chatFrame, _, _, _, _, infoID, accessID)
        if GW.IsSecretValue(infoID) or GW.IsSecretValue(accessID) or not accessID or chatFrame:IsVisible() then
            return
        end
        local chatType = infoID and C_ChatInfo.GetChatTypeName(infoID)
        if chatType and COUNTED[chatType] then
            SetUnread(chatFrame, (chatFrame.gwUnreadCount or 0) + 1)
        end
    end,
})
