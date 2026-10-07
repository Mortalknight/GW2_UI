---@class GW2
local GW = select(2, ...)

local function ReskinWhoFrameButton(button)
    if not button.gwSkinned then
        button.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        button.Variable:SetFont(UNIT_NAME_FONT, 11)
        button.Level:SetFont(UNIT_NAME_FONT, 11)
        button.Class:SetFont(UNIT_NAME_FONT, 11)
        GW.AddListItemChildHoverTexture(button)
        button.gwSkinned = true
    end
end

function GW.SkinWhoFrameDropdown()
    -- blizzard lets the dropdown hang out of the header on the left
    local dropdown = WhoFrameDropdown
    dropdown:GwStripTextures()
    dropdown:ClearAllPoints()
    dropdown:SetPoint("TOPLEFT", WhoFrameColumnHeader2, "TOPLEFT", 0, 0)
    dropdown:SetPoint("BOTTOMRIGHT", WhoFrameColumnHeader2, "BOTTOMRIGHT", -5, 0)
    dropdown.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    dropdown.Text:SetShadowOffset(0, 0)
    dropdown.Text:SetTextColor(1, 1, 1)
    dropdown.Text:SetJustifyH("LEFT")
    dropdown.Text:ClearAllPoints()
    dropdown.Text:SetPoint("LEFT", dropdown, "LEFT", 8, 0)
    dropdown.Text:SetPoint("RIGHT", dropdown.Arrow, "LEFT", -2, 0)
    local function SkinArrow()
        dropdown.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
        dropdown.Arrow:SetSize(16, 16)
        dropdown.Arrow:ClearAllPoints()
        dropdown.Arrow:SetPoint("RIGHT", dropdown, "RIGHT", -5, 0)
    end
    SkinArrow()
    hooksecurefunc(dropdown, "OnButtonStateChanged", SkinArrow)
    if dropdown.Background then
        dropdown.Background:Hide()
    end
end

function GW.SkinWhoList()
    if GW.Forever then return end
    WhoFrameTotals:SetTextColor(1, 1, 1)
    WhoFrameListInset:SetAlpha(0)

    if GW.Retail then
        GW.HandleTrimScrollBar(WhoFrame.ScrollBar)
        GW.HandleScrollControls(WhoFrame)

        -- rows first, the hover helper skips rows already marked as skinned
        hooksecurefunc(WhoFrame.ScrollBox, "Update", function(scrollBox)
            scrollBox:ForEachFrame(ReskinWhoFrameButton)
        end)
        hooksecurefunc(WhoFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
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
    WhoFrameEditBox:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    WhoFrameEditBox.Instructions:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    WhoFrameEditBox.Instructions:SetTextColor(178 / 255, 178 / 255, 178 / 255)
    GW.SkinBagSearchBox(WhoFrameEditBox)

    for _, frame in ipairs({WhoFrameColumnHeader1, WhoFrameColumnHeader2, WhoFrameColumnHeader3, WhoFrameColumnHeader4}) do
        frame:GwStripTextures()
        local r = {frame:GetRegions()}
        for _,c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                c:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
                -- the button sets its own font again when its state changes
                local fontObject = c:GetFontObject()
                if fontObject then
                    frame:SetNormalFontObject(fontObject)
                    frame:SetHighlightFontObject(fontObject)
                end
            end
        end
    end

    for _, object in pairs({WhoFrameColumnHeader1, WhoFrameColumnHeader2, WhoFrameColumnHeader3, WhoFrameColumnHeader4}) do
        GW.HandleScrollFrameHeaderButton(object)
    end

    GW.SkinWhoFrameDropdown()

    WhoFrameColumnHeader1:SetPoint("BOTTOMLEFT", WhoFrameListInset, "TOPLEFT", 5, 0)
    WhoFrameWhoButton:GwSkinButton(false, true)
    WhoFrameAddFriendButton:GwSkinButton(false, true)
    WhoFrameGroupInviteButton:GwSkinButton(false, true)
end
