---@class GW2
local GW = select(2, ...)

-- get local references
local MailFrame = _G.MailFrame
local InboxFrame = _G.InboxFrame
local SendMailFrame = _G.SendMailFrame
local OpenMailFrame = _G.OpenMailFrame

local InboxPrevPageButton = InboxFrame.PrevPageButton or _G.InboxPrevPageButton
local InboxNextPageButton = InboxFrame.NextPageButton or _G.InboxNextPageButton

local function ClearSendMailAttachments()
    for i = 1, ATTACHMENTS_MAX_SEND do
        ClickSendMailItemButton(i, true)
    end
end

local function SwitchToComposeView(tabButton)
    OpenMailFrame:Hide()
    MailFrameTab_OnClick(tabButton or MailFrameTab2, 2)
    InboxFrame:Show()
    SendMailFrame:Show()
    SendMailFrame_Update()
    SetSendMailShowing(true)
end

local function ResetComposeView()
    SendMailFrame_Reset()
    ClearSendMailAttachments()
end

local function AnchorComposeButton()
    MailFrameTab2:ClearAllPoints()
    MailFrameTab2:SetPoint("BOTTOMLEFT", MailItem1, "TOPLEFT", 0, 10)
    local postalOpen = PostalSelectOpenButton
    if postalOpen and postalOpen:IsShown() then
        MailFrameTab2:SetPoint("RIGHT", postalOpen, "LEFT", -4, 0)
    else
        MailFrameTab2:SetPoint("BOTTOMRIGHT", MailItem1, "TOPRIGHT", 0, 10)
    end
end
GW.AnchorMailComposeButton = AnchorComposeButton

local function FixMailSkin()
    -- MailFrameTab2.SetWidth is overridden with GW.NoOp later, so force width via SetSize.
    MailFrameTab2:SetSize(310, MailFrameTab2:GetHeight())
    AnchorComposeButton()
    SendMailSendMoneyButtonText:SetTextColor(GW.Colors.FallbackWhite:GetRGBA())
    SendMailCODButtonText:SetTextColor(GW.Colors.FallbackWhite:GetRGBA())
end

local function AddFrameSeperator()
    MailFrame.mailFrameSepTexture = MailFrame:CreateTexture(nil, "ARTWORK")
    MailFrame.mailFrameSepTexture:SetHeight(2)
    -- Keep the original vertical position, but size to the right pane width.
    MailFrame.mailFrameSepTexture:SetPoint("BOTTOMRIGHT", MailFrame, "BOTTOMRIGHT", 0, 50)
    MailFrame.mailFrameSepTexture:SetWidth(OpenMailFrame:GetWidth())
    MailFrame.mailFrameSepTexture:SetTexture("Interface/AddOns/GW2_UI/textures/hud/levelreward-sep.png")
    MailFrame.mailFrameSepTexture:Hide()
end

local function AddOnClickHandlers()
    for i = 1, _G.INBOXITEMS_TO_DISPLAY do
        local b = _G["MailItem" .. i .. "Button"]

        if b then
            b:SetScript("OnClick", function(self)
                --setup our UI code
                SendMailFrame:Hide()
                MailFrameTab_OnClick(self, 1)

                InboxFrame:Show()
                OpenMailFrame:Show()
                SendMailFrame_Update()
                SetSendMailShowing(false)

                --callback into blizz native functions for click handler
                local modifiedClick = IsModifiedClick("MAILAUTOLOOTTOGGLE");
                if (modifiedClick) then
                    InboxFrame_OnModifiedClick(self, self.index);
                else
                    InboxFrame_OnClick(self, self.index);
                end
            end)
        end
    end
end

local function SkinMoneyFrame()
    -- setup money frame
    GW.StyleMoneyText(SendMailMoneyFrameCopperButtonText, "Copper")
    GW.StyleMoneyText(SendMailMoneyFrameSilverButtonText, "Silver")
    GW.StyleMoneyText(SendMailMoneyFrameGoldButtonText, "Gold")
end

local function SkinPager()
    local r = { InboxPrevPageButton:GetRegions() }
    r[1]:SetTextColor(GW.Colors.FallbackWhite:GetRGBA())
    r[2]:SetTexture("Interface/AddOns/GW2_UI/textures/character/backicon.png")
    r[3]:SetTexture("Interface/AddOns/GW2_UI/textures/character/backicon.png")
    r[4]:SetTexture("Interface/AddOns/GW2_UI/textures/character/backicon.png")
    r[4]:SetDesaturated(true)

    r = { InboxNextPageButton:GetRegions() }
    r[1]:SetTextColor(GW.Colors.FallbackWhite:GetRGBA())
    r[2]:SetTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon.png")
    r[3]:SetTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon.png")
    r[4]:SetTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon.png")
    r[4]:SetDesaturated(true)
end

local function SkinOpenMailFrame()
    -- configure location of OpenMail Frame
    OpenMailFrame:ClearAllPoints()
    OpenMailFrame:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 331, 0)
    OpenMailFrame:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", 0, 0)
    OpenMailFrameCloseButton:Hide()
    if OpenMailFrameIcon then
        OpenMailFrameIcon:Hide()
    end
    OpenMailSenderLabel:Hide()
    OpenMailSubjectLabel:Hide()
    OpenMailFrame.TitleContainer:Hide()
    OpenStationeryBackgroundLeft:Hide()
    OpenStationeryBackgroundRight:Hide()

    OpenMailBodyText:SetFont("P", UNIT_NAME_FONT, 14, "")
    OpenMailBodyText:SetTextColor("P", 1, 1, 1, 1)

    GW.HandlePortraitFrameArt(OpenMailFrame)
    OpenMailFrame:GwCreateBackdrop(nil)
    OpenMailFrame:SetParent(MailFrame)

    OpenMailSenderLabel:Hide()
    OpenMailSender.Name:SetPoint("TOPLEFT", OpenMailScrollFrame, "TOPLEFT", 0, 50)
    OpenMailSender.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    OpenMailSender.Name:SetTextColor(GW.Colors.FallbackWhite:GetRGBA())

    OpenMailSubjectLabel:Hide()
    OpenMailSubject:SetPoint("TOPLEFT", OpenMailSender.Name, "BOTTOMLEFT", 0, -10)
    OpenMailSubject:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    OpenMailSubject:SetTextColor(GW.Colors.FallbackWhite:GetRGBA())

    OpenMailReportSpamButton:GwSkinButton(false, true)
    OpenMailReplyButton:GwSkinButton(false, true)
    OpenMailReplyButton:SetPoint("RIGHT", OpenMailDeleteButton, "LEFT", -5, 0)
    OpenMailReplyButton:SetScript("OnClick", function(self)
        if OpenMail_Reply then
            OpenMail_Reply()
        else
            self:Reply()
        end
        SwitchToComposeView(self)
    end)

    OpenMailDeleteButton:GwSkinButton(false, true)
    OpenMailDeleteButton:GwSkinNegativeButton()
    OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -5, 0)

    OpenMailCancelButton:GwSkinButton(false, true)
    OpenMailCancelButton:SetPoint("BOTTOMRIGHT", OpenMailFrame, "BOTTOMRIGHT", -7, -20)

    OpenAllMail:GwSkinButton(false, true)
    OpenAllMail:ClearAllPoints()
    OpenAllMail:SetPoint("CENTER",InboxFrame,"BOTTOM",0,114)
    GW.SkinSlimScrollFrame(OpenMailScrollFrame)

    OpenMailScrollFrame:SetPoint("TOPLEFT",OpenMailFrame,"TOPLEFT",8,-84)
    OpenMailScrollFrame:SetPoint("TOPRIGHT", OpenMailFrame, "TOPRIGHT", -26, -84)
    for i = 1, _G.ATTACHMENTS_MAX_RECEIVE do
        local b = _G["OpenMailAttachmentButton" .. i]
        local t = _G["OpenMailAttachmentButton" .. i .. "IconTexture"]

        b:GwStripTextures()

        if b then
            b:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png")
            local r = { b:GetRegions() }
            local ii = 1
            for _, c in pairs(r) do
                if c:GetObjectType() == "Texture" then
                    if ii == 1 then
                        c:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitembackdrop.png")
                        c:SetSize(b:GetSize())
                    end
                    ii = ii + 1
                end
            end
            hooksecurefunc(b.IconBorder, "SetVertexColor", function(self)
                self:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
            end)

            b.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
        end

        if t then t:SetTexCoord(0.1, 0.9, 0.1, 0.9) end
    end
end

local function setFontColorToWhite(self)
    self:SetTextColor(GW.Colors.FallbackWhite:GetRGBA())
end

local BAG_TEXTURES = "Interface/AddOns/GW2_UI/textures/bag/"

-- the attachment slots in the look of our bag slots: backdrop, a grey frame when empty, the quality frame with an item
local function SkinSendAttachment(button)
    button.gwSkinned = true
    local slotBackground = button:GetRegions()
    slotBackground:SetTexture(BAG_TEXTURES .. "bagitembackdrop.png")
    slotBackground:ClearAllPoints()
    slotBackground:SetAllPoints(button)

    local emptyBorder = button:CreateTexture(nil, "BORDER")
    emptyBorder:SetTexture(BAG_TEXTURES .. "bagitemborder.png")
    emptyBorder:SetVertexColor(GW.Colors.SkinColors.IconBorder:GetRGB())
    emptyBorder:SetAllPoints(button)

    button.IconBorder:ClearAllPoints()
    button.IconBorder:SetAllPoints(button)
    button:SetHighlightTexture(BAG_TEXTURES .. "bagitemborder.png", "ADD")
    button:GetHighlightTexture():SetAlpha(0.33)

    button.Count:ClearAllPoints()
    button.Count:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, -3)
    button.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
end

-- blizzard sets the icon as normal texture and recolors the border on every update
local function SkinMailFrameSendItems()
    for i = 1, ATTACHMENTS_MAX_SEND do
        local button = _G["SendMailAttachment" .. i]
        if not button.gwSkinned then
            SkinSendAttachment(button)
        end
        local icon = button:GetNormalTexture()
        if icon then
            icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        end
        GW.SetItemSlotQuality(button, select(5, GetSendMailItem(i)))
    end
end

local function SkinSendMailFrame()
    GW.MutateInaccessableObject(SendMailCostMoneyFrame, "FontString", setFontColorToWhite)
    GW.MutateInaccessableObject(SendMailNameEditBox, "FontString", setFontColorToWhite)
    GW.MutateInaccessableObject(SendMailSubjectEditBox, "FontString", setFontColorToWhite)

    if not GW.isModern then
        MailEditBox.ScrollBox.EditBox:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        MailEditBox.ScrollBox:GwStripTextures()
        MailEditBox.ScrollBox:GwCreateBackdrop(GW.BackdropTemplates.Default, true, 10, 10)
        -- blizzard already pairs the box with this bar; its track is inset by 7 on each side, too much for the slim bar
        MailEditBoxScrollBar:ClearAllPoints()
        MailEditBoxScrollBar:SetPoint("TOPLEFT", MailEditBox, "TOPRIGHT", 6, -4)
        MailEditBoxScrollBar:SetPoint("BOTTOMLEFT", MailEditBox, "BOTTOMRIGHT", 6, 5)
        GW.SkinSlimScrollBar(MailEditBoxScrollBar)
        MailEditBoxScrollBar.Track:ClearAllPoints()
        MailEditBoxScrollBar.Track:SetPoint("TOPLEFT", 0, -20)
        MailEditBoxScrollBar.Track:SetPoint("BOTTOMRIGHT", 0, 20)
        MailEditBoxScrollBar:GetThumb():SetPoint("LEFT", 1, 0)
    end

    SkinMoneyFrame()
    SendMailMoneyText:SetTextColor(GW.Colors.FallbackWhite:GetRGBA())
    SendMailSendMoneyButton:GwSkinCheckButton(true, 15)
    SendMailCODButton:GwSkinCheckButton(true, 15)

    -- configure location of SendMail Frame; forever spans it over the mail frame instead of giving
    -- it a size, a single anchor would leave it at 0x0, so it gets the size of the other clients
    SendMailFrame:SetSize(384, 512)
    SendMailFrame:ClearAllPoints()
    SendMailFrame:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", 46, 20)
    SendMailFrame:SetParent(MailFrame)

    --Hides
    SendStationeryBackgroundLeft:Hide()
    SendStationeryBackgroundRight:Hide()
    SendMailMoneyBg:Hide()
    SendMailMoneyInset:Hide()

    SendMailCancelButton:GwSkinButton(false, true)
    SendMailMailButton:GwSkinButton(false, true)

    if GW.isModern then
        SendMailScrollFrame:GwStripTextures(true)
        GW.SkinSlimScrollFrame(SendMailScrollFrame)
    end

    SendMailMoneyFrame:ClearAllPoints()
    SendMailMoneyFrame:SetPoint("BOTTOMRIGHT", SendMailFrame, "BOTTOMRIGHT", -40, 15)

    -- forever places the postage at the right edge and the money to send below the attachments,
    -- in our sized send frame both go where retail and mists have them
    SendMailCostMoneyFrame:ClearAllPoints()
    SendMailCostMoneyFrame:SetPoint("TOPRIGHT", SendMailFrame, "TOPRIGHT", -50, -34)
    SendMailMoneyButton:ClearAllPoints()
    SendMailMoneyButton:SetPoint("BOTTOMLEFT", SendMailFrame, "BOTTOMLEFT", 15, 125)

    GW.SkinTextBox(SendMailNameEditBoxMiddle, SendMailNameEditBoxLeft, SendMailNameEditBoxRight, nil, nil, 5)
    GW.SkinTextBox(SendMailSubjectEditBoxMiddle, SendMailSubjectEditBoxLeft, SendMailSubjectEditBoxRight, nil, nil, 5)
    GW.SkinTextBox(SendMailMoneyGoldMiddle, SendMailMoneyGoldLeft, SendMailMoneyGoldRight, nil, nil, 5)
    -- the classic coins hang right of the box, the newer template draws them inside
    local coinOffset = not SendMailMoneySilver.coinAtlas and -12 or nil
    GW.SkinTextBox(SendMailMoneySilverMiddle, SendMailMoneySilverLeft, SendMailMoneySilverRight, nil, nil, 5, coinOffset)
    GW.SkinTextBox(SendMailMoneyCopperMiddle, SendMailMoneyCopperLeft, SendMailMoneyCopperRight, nil, nil, 5, coinOffset)

    --reposition buttons
    SendMailMailButton:ClearAllPoints()
    SendMailMailButton:SetPoint("BOTTOMRIGHT", SendMailFrame, "BOTTOMRIGHT", -53, 57)

    SendMailCancelButton:ClearAllPoints()
    SendMailCancelButton:SetPoint("RIGHT", SendMailMailButton, "LEFT", -5, 0)
    SendMailCancelButton:SetText(RESET)
    SendMailCancelButton:SetScript("OnClick", function()
        ResetComposeView()
    end)

    local cancelButton = CreateFrame("Button", "SendMailQuit", SendMailFrame, "UIPanelButtonNoTooltipTemplate")
    cancelButton:ClearAllPoints()
    cancelButton:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -5, 0)
    cancelButton:SetText(CANCEL)
    cancelButton:SetSize(SendMailCancelButton:GetSize())
    cancelButton:GwSkinButton(false, true)
    cancelButton:SetScript("OnClick", function(self)
        ResetComposeView()

        SendMailFrame:Hide()
        SetSendMailShowing(false)
        MailFrameTab_OnClick(self, 1)
    end)
end

local function SkinComposeButton()
    MailFrameTab2:GwStripTextures()
    MailFrameTab2:SetSize(310, 24)
    MailFrameTab2.SetWidth = GW.NoOp

    MailFrameTab2:SetText(SENDMAIL)
    MailFrameTab2:GwSkinButton(false, true)
    -- a tab moves its text up or down with its state, as our button it stays in the middle
    MailFrameTab2.selectedTextY = 0
    MailFrameTab2.deselectedTextY = 0
    MailFrameTab2:GetFontString():ClearAllPoints()
    MailFrameTab2:GetFontString():SetPoint("CENTER")
    MailFrameTab2:SetScript("OnClick", function(self)
        SwitchToComposeView(self)
    end)
end

local function ClearMailTextures()
    MailFrameTitleText:Hide()
    _G.MailFrameBg:Hide()
    _G.MailFrameInset.NineSlice:Hide()
    _G.MailFrameInset:GwCreateBackdrop()

   if InboxTitleText then InboxTitleText:Hide() end
   if SendMailTitleText then SendMailTitleText:Hide() end

    MailFrame:GwStripTextures()
    InboxFrame:GwStripTextures()
    SendMailFrame:GwStripTextures()
    if GW.isModern then
        SendMailScrollFrame:GwStripTextures(true)
    end
    OpenMailFrame:GwStripTextures()
    OpenMailScrollFrame:GwStripTextures()
    OpenMailScrollFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)

    if GW.isModern then
        SendMailScrollFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    end
    GW.HandlePortraitFrameArt(MailFrame)
    MailFrame:GwCreateBackdrop()

    OpenMailLetterButtonIconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    OpenMailLetterButton:GwStripTextures()
    OpenMailMoneyButtonIconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    OpenMailMoneyButton:GwStripTextures()

    for i = 1, _G.INBOXITEMS_TO_DISPLAY do
        local zebra = i % 2
        local bg = _G["MailItem" .. i]

        bg:GwStripTextures()

        local btn = _G["MailItem" .. i .. "Button"]
        btn:GwStripTextures()

        local t = _G["MailItem" .. i .. "ButtonIcon"]
        t:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        bg.gwZebra = bg:CreateTexture(nil, "BACKGROUND")
        bg.gwZebra:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
        bg.gwZebra:SetSize(32, 32)
        bg.gwZebra:SetPoint("TOPLEFT", bg, "TOPLEFT")
        bg.gwZebra:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT")
        bg.gwZebra:SetVertexColor(0,0,0,zebra/4 + 0.2)

        local ib = _G["MailItem" .. i .. "ButtonIconBorder"]
        ib:ClearAllPoints()
        ib:SetPoint("TOPLEFT", t, "TOPLEFT", -2, 2)
        ib:SetPoint("BOTTOMRIGHT", t, "BOTTOMRIGHT", 2, -2)
        hooksecurefunc(ib, "SetVertexColor", function(self)
            self:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
        end)
    end
    MailFrameTab1:Hide()
end

-- forever lays the attachments out 88 lower and without a right margin, blizzard sets them on every
-- update; in our send frame they go where retail has them, above the money
local FOREVER_ROW_OFFSET = 88
local RETAIL_RIGHT_MARGIN = 46

local function GetAttachmentColumns(rightMargin)
    local columns = ATTACHMENTS_PER_ROW_SEND
    local iconWidth = SendMailAttachment1:GetWidth() + 2
    local area = SendMailFrame:GetWidth() - 14 - rightMargin
    local gap = math.floor((area - iconWidth * columns) / (columns - 1))
    local indent = 14 + math.floor((area - iconWidth * columns - gap * (columns - 1)) / 2)
    return indent, iconWidth + gap - 2
end

local function PlaceForeverAttachments()
    local foreverIndent, foreverStep = GetAttachmentColumns(0)
    local retailIndent, retailStep = GetAttachmentColumns(RETAIL_RIGHT_MARGIN)
    for i = 1, ATTACHMENTS_MAX_SEND do
        local button = _G["SendMailAttachment" .. i]
        if button:IsShown() then
            local point, relativeTo, relativePoint, x, y = button:GetPoint()
            local column = math.floor((x - foreverIndent) / foreverStep + 0.5)
            button:SetPoint(point, relativeTo, relativePoint, retailIndent + retailStep * column, y + FOREVER_ROW_OFFSET)
        end
    end
end

local function LoadMailSkin()
    if not GW.settings.skins.mail.enabled then return end

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("MAIL_SHOW")
    eventFrame:RegisterEvent("MAIL_INBOX_UPDATE")
    eventFrame:RegisterEvent("MAIL_CLOSED")
    eventFrame:RegisterEvent("MAIL_SEND_INFO_UPDATE")
    eventFrame:RegisterEvent("MAIL_SEND_SUCCESS")
    eventFrame:RegisterEvent("MAIL_FAILED")
    eventFrame:RegisterEvent("MAIL_SUCCESS")
    eventFrame:RegisterEvent("CLOSE_INBOX_ITEM")
    eventFrame:RegisterEvent("MAIL_LOCK_SEND_ITEMS")
    eventFrame:RegisterEvent("MAIL_UNLOCK_SEND_ITEMS")
    eventFrame:RegisterEvent("TRIAL_STATUS_UPDATE")
    eventFrame:SetScript("OnEvent", FixMailSkin)

    InvoiceTextFontNormal:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    MailTextFontNormal:SetTextColor(GW.Colors.FallbackWhite:GetRGB())

    -- Strip and hide default textures
    ClearMailTextures()

    -- Setup adaptive frame size:
    -- compact mode keeps only the inbox area visible;
    -- expanded mode adds a right pane with similar width.
    local baseWidth, baseHeight = MailFrame:GetSize()
    local leftPaneWidth = 331
    local sidePadding = 20
    local compactWidth = baseWidth
    local expandedWidth = (leftPaneWidth * 2) + sidePadding
    local frameHeight = baseHeight + 30

    -- override max tabsize for the "compose" button (as it's just the send mail tab)
    MailFrame.maxTabWidth = 320

    -- Configure Mail Frame Background
    MailFrame.mailFrameBgTexture = MailFrame:CreateTexture(nil, "BACKGROUND", nil, -7)
    MailFrame.mailFrameBgTexture:SetSize(expandedWidth, frameHeight)
    MailFrame.mailFrameBgTexture:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 0, 5)
    MailFrame.mailFrameBgTexture:SetTexture("Interface/AddOns/GW2_UI/textures/hud/mailboxwindow-background.png")
    MailFrame.mailFrameBgTexture:SetTexCoord(0, 0.7099, 0, 0.955);

    -- Configure Mail Heading
    MailFrame.heading = MailFrame:CreateTexture(nil, "BACKGROUND")
    MailFrame.heading:SetSize(expandedWidth, 64)
    MailFrame.heading:SetPoint("BOTTOMLEFT", MailFrame, "TOPLEFT", 0, 0)
    MailFrame.heading:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader.png")

    MailFrame.heading.Title = MailFrame:CreateFontString("MailFrameTitle", "ARTWORK")
    MailFrame.heading.Title:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 50, 30)
    MailFrame.heading.Title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, "OUTLINE", 2)
    MailFrame.heading.Title:SetText(MAIL_LABEL)
    MailFrame.heading.Title:SetTextColor(1, .93, .73)

    MailFrame.icon = MailFrame:CreateTexture(nil, "ARTWORK")
    MailFrame.icon:SetSize(80, 80)
    MailFrame.icon:SetPoint("CENTER", MailFrame, "TOPLEFT", 12, 25)
    MailFrame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/mail-window-icon.png")

    MailFrame.headingRight = MailFrame:CreateTexture(nil, "BACKGROUND")
    MailFrame.headingRight:SetSize(expandedWidth, 64)
    MailFrame.headingRight:SetPoint("BOTTOMRIGHT", MailFrame, "TOPRIGHT", 0, 0)
    MailFrame.headingRight:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader-right.png")

    MailFrame.CloseButton:GwSkinButton(true, false)
    MailFrame.CloseButton:SetSize(20, 20)
    MailFrame.CloseButton:ClearAllPoints()
    MailFrame.CloseButton:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", -10, 30)
    MailFrame.CloseButton:SetParent(MailFrame)

    -- Configure footer
    MailFrame.footer = MailFrame:CreateTexture(nil, "BACKGROUND")
    MailFrame.footer:SetSize(expandedWidth, 70)
    MailFrame.footer:SetPoint("TOPLEFT", MailFrame, "BOTTOMLEFT", 0, 5)
    MailFrame.footer:SetPoint("TOPRIGHT", MailFrame, "BOTTOMRIGHT", 0, 5)
    MailFrame.footer:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagfooter.png")

    InboxFrame:ClearAllPoints()
    InboxFrame:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 0, 0)
    InboxFrame:SetSize(leftPaneWidth, 512)

    _G.AutoCompleteBox:GwStripTextures()
    _G.AutoCompleteBox:GwCreateBackdrop(GW.BackdropTemplates.Default)

    -- movable stuff
    local pos = GW.settings.skins.mail.pos
    MailFrame.mover = CreateFrame("Frame", nil, MailFrame)
    MailFrame.mover:EnableMouse(true)
    MailFrame:SetMovable(true)
    MailFrame.mover:SetSize(expandedWidth, 30)
    MailFrame.mover:SetPoint("BOTTOMLEFT", MailFrame, "TOPLEFT", 0, 0)
    MailFrame.mover:SetPoint("BOTTOMRIGHT", MailFrame, "TOPRIGHT", 0, 0)
    MailFrame.mover:RegisterForDrag("LeftButton")
    MailFrame:SetClampedToScreen(true)
    MailFrame.mover:SetScript("OnDragStart", function()
        MailFrame:StartMoving()
    end)
    MailFrame.mover:SetScript("OnDragStop", function()
        MailFrame:StopMovingOrSizing()

        local x = MailFrame:GetLeft()
        local y = MailFrame:GetTop()

        -- re-anchor to UIParent after the move
        MailFrame.SetPoint = nil
        MailFrame:ClearAllPoints()
        MailFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
        MailFrame.SetPoint = GW.NoOp -- prevent blizz from overriding our position

        -- store the updated position
        local pos = GW.settings.skins.mail.pos
        wipe(pos)
        pos.point = "TOPLEFT"
        pos.relativePoint = "BOTTOMLEFT"
        pos.xOfs = x
        pos.yOfs = y
        GW.settings.skins.mail.pos = pos
    end)
    MailFrame:ClearAllPoints()
    MailFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    MailFrame.SetPoint = GW.NoOp -- prevent blizz from overriding our position

    MailFrame:HookScript("OnShow", function()
        local pos = GW.settings.skins.mail.pos
        MailFrame.SetPoint = nil
        MailFrame:ClearAllPoints()
        MailFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
        MailFrame.SetPoint = GW.NoOp -- prevent blizz from overriding our position
    end)

    local function UpdateInboxBottomButtons()
        local yOffset = 88

        OpenAllMail:ClearAllPoints()
        OpenAllMail:SetPoint("CENTER", InboxFrame, "BOTTOM", 0, yOffset)

        local prevBottomOffset = yOffset - (InboxPrevPageButton:GetHeight() * 0.5)
        InboxPrevPageButton:ClearAllPoints()
        InboxPrevPageButton:SetPoint("BOTTOMLEFT", InboxFrame, "BOTTOMLEFT", 6, prevBottomOffset)

        local nextBottomOffset = yOffset - (InboxNextPageButton:GetHeight() * 0.5)
        InboxNextPageButton:ClearAllPoints()
        InboxNextPageButton:SetPoint("BOTTOMRIGHT", InboxFrame, "BOTTOMRIGHT", -6, nextBottomOffset)
    end

    local function ApplyMailFrameSize(width)
        MailFrame:SetSize(width, frameHeight)
        MailFrame.mailFrameBgTexture:SetSize(width, frameHeight)
        MailFrame.heading:SetSize(width, 64)
        MailFrame.headingRight:SetSize(width, 64)
        MailFrame.footer:SetSize(width, 70)
        MailFrame.mover:SetWidth(width)
    end

    local function UpdateMailFrameSize()
        local shouldExpand = OpenMailFrame:IsShown() or SendMailFrame:IsShown()
        ApplyMailFrameSize(shouldExpand and expandedWidth or compactWidth)
        if MailFrame.mailFrameSepTexture then
            MailFrame.mailFrameSepTexture:SetWidth(OpenMailFrame:GetWidth())
            MailFrame.mailFrameSepTexture:SetShown(shouldExpand)
        end
        UpdateInboxBottomButtons()
    end

    MailFrame:HookScript("OnShow", UpdateMailFrameSize)
    OpenMailFrame:HookScript("OnShow", UpdateMailFrameSize)
    OpenMailFrame:HookScript("OnHide", UpdateMailFrameSize)
    SendMailFrame:HookScript("OnShow", UpdateMailFrameSize)
    SendMailFrame:HookScript("OnHide", UpdateMailFrameSize)
    hooksecurefunc("MailFrameTab_OnClick", UpdateMailFrameSize)
    UpdateMailFrameSize()

    -- Reskin OpenMailFrame Buttons
    SkinPager()
    SkinOpenMailFrame()
    SkinSendMailFrame()
    SkinComposeButton()
    AddFrameSeperator()

    -- Hook's
    hooksecurefunc("SendMailFrame_Update", SkinMailFrameSendItems)
    if GW.Forever then
        hooksecurefunc("SendMailFrame_Update", PlaceForeverAttachments)
    end

    -- hook inbox buttons to close the compose view if we want to look at a message and it's open
    AddOnClickHandlers()

    -- Skin Postal Addon
    GW.LoadPostalAddonSkin()
end
GW.LoadMailSkin = LoadMailSkin
