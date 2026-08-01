---@class GW2
local GW = select(2, ...)

local function ReskinWhoFrameButton(button)
    if not button.isSkinned then
        button.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        button.Variable:SetFont(UNIT_NAME_FONT, 11)
        button.Level:SetFont(UNIT_NAME_FONT, 11)
        button.Class:SetFont(UNIT_NAME_FONT, 11)
        GW.AddListItemChildHoverTexture(button)
        button.isSkinned = true
    end
end

-- 12.1: The Who window still lives in the old FriendsFrame — when the SocialUI is active,
-- Blizzard hides all tabs there except "Who". The legacy window therefore gets
-- its GW header here.
local function SkinLegacyFriendsFrame()
    GW.HandlePortraitFrame(FriendsFrame)
    if FriendsFrameIcon then
        FriendsFrameIcon:SetAlpha(0)
    end
    FriendsFrameCloseButton:SetPoint("TOPRIGHT", -5, -2)

    GW.CreateFrameHeaderWithBody(FriendsFrame, FriendsFrameTitleText, "Interface/AddOns/GW2_UI/textures/social/social-windowheader.png", {WhoFrame.ScrollBox}, nil, true, true)
    FriendsFrame.gwHeader.windowIcon:ClearAllPoints()
    FriendsFrame.gwHeader.windowIcon:SetPoint("CENTER", FriendsFrame.gwHeader, "BOTTOMLEFT", -26, 35)
    FriendsFrameTitleText:ClearAllPoints()
    FriendsFrameTitleText:SetPoint("BOTTOMLEFT", FriendsFrame.gwHeader, "BOTTOMLEFT", 25, 10)
    FriendsFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    FriendsFrame:SetClampedToScreen(true)
    FriendsFrame:SetClampRectInsets(-40, 0, FriendsFrame.gwHeader:GetHeight() - 30, 0)

    for i = 1, FRIEND_TAB_COUNT do
        local tab = _G["FriendsFrameTab" .. i]
        if tab then
            tab:GwStripTextures()
            if tab.Text then
                tab.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
            end
        end
    end

    if FriendsFrameBattlenetFrame and FriendsFrameBattlenetFrame.UnavailableInfoFrame then
        FriendsFrameBattlenetFrame.UnavailableInfoFrame:ClearAllPoints()
        FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetPoint("TOPLEFT", FriendsFrame.gwHeader, "TOPRIGHT", 1, -18)
    end
end

function GW.SkinWhoList()
    SkinLegacyFriendsFrame()

    WhoFrameTotals:SetTextColor(1, 1, 1)
    WhoFrameListInset:SetAlpha(0)

    GW.HandleTrimScrollBar(WhoFrame.ScrollBar)
    GW.HandleScrollControls(WhoFrame)

    hooksecurefunc(WhoFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
    hooksecurefunc(WhoFrame.ScrollBox, "Update", function(scrollBox)
        scrollBox:ForEachFrame(ReskinWhoFrameButton)
    end)

    if WhoFrameEditBox.Backdrop then
        WhoFrameEditBox.Backdrop:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagsearchbg.png")
    end
    WhoFrameEditBox:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    WhoFrameEditBox.Instructions:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    WhoFrameEditBox.Instructions:SetTextColor(178 / 255, 178 / 255, 178 / 255)
    GW.SkinBagSearchBox(WhoFrameEditBox)

    for _, frame in ipairs({WhoFrameColumnHeader1, WhoFrameColumnHeader2, WhoFrameColumnHeader3, WhoFrameColumnHeader4}) do
        frame:GwStripTextures()
        local r = {frame:GetRegions()}
        for _, c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                c:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
            end
        end
        GW.HandleScrollFrameHeaderButton(frame)
    end

    WhoFrameDropdown:GwStripTextures()
    WhoFrameDropdown.Arrow:ClearAllPoints()
    WhoFrameDropdown.Arrow:SetPoint("RIGHT", WhoFrameDropdown, "RIGHT", -5, -3)
    WhoFrameDropdown.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    WhoFrameDropdown.Text:SetShadowOffset(0, 0)
    WhoFrameDropdown.Text:SetTextColor(1, 1, 1)
    WhoFrameDropdown.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
    WhoFrameDropdown:HookScript("OnClick", function(self)
        self.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
    end)
    WhoFrameDropdown:HookScript("OnMouseDown", function(self)
        self.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
    end)
    if WhoFrameDropdown.Background then
        WhoFrameDropdown.Background:Hide()
    end

    WhoFrameColumnHeader1:SetPoint("BOTTOMLEFT", WhoFrameListInset, "TOPLEFT", 5, 0)
    WhoFrameWhoButton:GwSkinButton(false, true)
    WhoFrameAddFriendButton:GwSkinButton(false, true)
    WhoFrameGroupInviteButton:GwSkinButton(false, true)
end
