local _, GW = ...

local function ReskinWhoFrameButton(button)
    if not button.isSkinned then
        button.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        button.Variable:SetFont(UNIT_NAME_FONT, 11)
        button.Level:SetFont(UNIT_NAME_FONT, 11)
        button.Class:SetFont(UNIT_NAME_FONT, 11)
        GW.AddListItemChildHoverTexture(button)
        button.isSkinned = true
    end
end

function GW.SkinWhoList()
    WhoFrameTotals:SetTextColor(1, 1, 1)
    WhoFrameListInset:SetAlpha(0)

    if GW.Retail then
        GW.HandleTrimScrollBar(WhoFrame.ScrollBar)
        GW.HandleScrollControls(WhoFrame)

        hooksecurefunc(WhoFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
        hooksecurefunc(WhoFrame.ScrollBox, "Update", function(scrollBox)
            scrollBox:ForEachFrame(ReskinWhoFrameButton)
        end)
    else
        WHOS_TO_DISPLAY = 30
        for i = 18, 30 do
		    local button = CreateFrame("Button", "WhoFrameButton"..i, WhoFrame, "FriendsFrameWhoButtonTemplate");
            button:SetID(i);
            button:SetPoint("TOP", _G["WhoFrameButton"..(i-1)], "BOTTOM");
        end
        WhoListScrollFrame:ClearAllPoints()
        WhoListScrollFrame:SetPoint("TOPLEFT", WhoFrame, 8, -87)
        WhoListScrollFrame:SetPoint("BOTTOMRIGHT", WhoFrame, -25, 60)
        WhoListScrollFrame:SetHeight(480)

        WhoListScrollFrame:GwStripTextures()
        WhoListScrollFrame:GwSkinScrollFrame()
        WhoListScrollFrameScrollBar:GwSkinScrollBar()
    end

    if WhoFrameEditBox.Backdrop then
        WhoFrameEditBox.Backdrop:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagsearchbg.png")
    end
    WhoFrameEditBox:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    WhoFrameEditBox.Instructions:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    WhoFrameEditBox.Instructions:SetTextColor(178 / 255, 178 / 255, 178 / 255)
    GW.SkinBagSearchBox(WhoFrameEditBox)

    for _, frame in ipairs({WhoFrameColumnHeader1, WhoFrameColumnHeader2, WhoFrameColumnHeader3, WhoFrameColumnHeader4}) do
        frame:GwStripTextures()
        local r = {frame:GetRegions()}
        for _,c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                c:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            end
        end
    end

    for _, object in pairs({WhoFrameColumnHeader1, WhoFrameColumnHeader2, WhoFrameColumnHeader3, WhoFrameColumnHeader4}) do
        GW.HandleScrollFrameHeaderButton(object)
    end

    WhoFrameDropdown:GwStripTextures()
    WhoFrameDropdown.Arrow:ClearAllPoints()
    WhoFrameDropdown.Arrow:SetPoint("RIGHT", WhoFrameDropdown, "RIGHT", -5, -3)
    WhoFrameDropdown.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
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
