local _, GW = ...
local SetSetting = GW.SetSetting
local GetSetting = GW.GetSetting

-- get local references
local MailFrame = _G.MailFrame
local InboxFrame = _G.InboxFrame
local SendMailFrame = _G.SendMailFrame
local OpenMailFrame = _G.OpenMailFrame

local function FixMailSkin()
    MailFrameTab2:SetWidth(310)
    SendMailSendMoneyButtonText:SetTextColor(1, 1, 1, 1)
    SendMailCODButtonText:SetTextColor(1, 1, 1, 1)
end

local function AddFrameSeperator()
    MailFrame.mailFrameSepTexture = MailFrame:CreateTexture(nil, "ARTWORK")
    MailFrame.mailFrameSepTexture:SetSize(600, 2)
    MailFrame.mailFrameSepTexture:SetPoint("BOTTOMRIGHT", MailFrame, "BOTTOMRIGHT", 110, 50)
    MailFrame.mailFrameSepTexture:SetTexture("Interface/AddOns/GW2_UI/textures/hud/levelreward-sep")
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
                if ( modifiedClick ) then
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
    SendMailMoneyFrameCopperButtonText:SetFont(UNIT_NAME_FONT, 12)
    SendMailMoneyFrameCopperButtonText:SetTextColor(177 / 255, 97 / 255, 34 / 255)

    SendMailMoneyFrameSilverButtonText:SetFont(UNIT_NAME_FONT, 12)
    SendMailMoneyFrameSilverButtonText:SetTextColor(170 / 255, 170 / 255, 170 / 255)

    SendMailMoneyFrameGoldButtonText:SetFont(UNIT_NAME_FONT, 12)
    SendMailMoneyFrameGoldButtonText:SetTextColor(221/255, 187/255, 68/255)
end

local function SkinPager()
    local r = {InboxPrevPageButton:GetRegions()}
    r[1]:SetTextColor(1, 1, 1, 1)
    r[2]:SetTexture("Interface/AddOns/GW2_UI/textures/character/backicon")
    r[3]:SetTexture("Interface/AddOns/GW2_UI/textures/character/backicon")
    r[4]:SetTexture("Interface/AddOns/GW2_UI/textures/character/backicon")
    SetDesaturation(r[4], true)

    r = {InboxNextPageButton:GetRegions()}
    r[1]:SetTextColor(1, 1, 1, 1)
    r[2]:SetTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon")
    r[3]:SetTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon")
    r[4]:SetTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon")
    SetDesaturation(r[4], true)
end

local function SkinOpenMailFrame()
    -- configure location of OpenMail Frame
    OpenMailFrame:ClearAllPoints()
    OpenMailFrame:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", 0, 20)
    OpenMailFrameCloseButton:Hide()
    OpenMailFrameIcon:Hide()
    OpenMailSenderLabel:Hide()
    OpenMailSubjectLabel:Hide()
    OpenStationeryBackgroundLeft:Hide()
    OpenStationeryBackgroundRight:Hide()

    OpenMailBodyText:SetFont("P", UNIT_NAME_FONT, 14, "")
    OpenMailBodyText:SetTextColor("P", 1, 1, 1, 1)

    OpenMailFrame.NineSlice:Hide()
    OpenMailFrame.TopTileStreaks:Hide()
    OpenMailFrame:GwCreateBackdrop(nil)
    OpenMailFrame:SetParent(MailFrame)

    OpenMailSenderLabel:Hide()
    OpenMailSender.Name:SetPoint("TOPLEFT", OpenMailScrollFrame, "TOPLEFT", 0, 50)
    OpenMailSender.Name:SetFont(UNIT_NAME_FONT, 14)
    OpenMailSender.Name:SetTextColor(1, 1, 1, 1)

    OpenMailSubjectLabel:Hide()
    OpenMailSubject:SetPoint("TOPLEFT", OpenMailSender.Name, "BOTTOMLEFT", 0, -10)
    OpenMailSubject:SetFont(UNIT_NAME_FONT, 12)
    OpenMailSubject:SetTextColor(1, 1, 1, 1)

    OpenMailReportSpamButton:GwSkinButton(false, true)
    OpenMailReplyButton:GwSkinButton(false, true)
    OpenMailReplyButton:SetPoint("RIGHT", OpenMailDeleteButton, "LEFT", -5,  0)
    OpenMailReplyButton:SetScript("OnClick", function()
        OpenMail_Reply()
        OpenMailFrame:Hide()
        MailFrameTab_OnClick(self, 2)

        InboxFrame:Show()
        SendMailFrame:Show()
        SendMailFrame_Update()
        SetSendMailShowing(true)
    end)

    OpenMailDeleteButton:GwSkinButton(false, true)
    OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -5, 0)

    OpenMailCancelButton:GwSkinButton(false, true)
    OpenMailCancelButton:SetPoint("BOTTOMRIGHT", OpenMailFrame, "BOTTOMRIGHT", -7, -31)

    OpenAllMail:GwSkinButton(false, true)
    GW.HandleTrimScrollBar(OpenMailScrollFrame.ScrollBar, true)
    GW.HandleAchivementsScrollControls(OpenMailScrollFrame)

    for i = 1, _G.ATTACHMENTS_MAX_RECEIVE do
        local b = _G["OpenMailAttachmentButton" .. i]
        local t = _G["OpenMailAttachmentButton" .. i .. "IconTexture"]

    b:GwStripTextures()

        if b then
            b:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
            local r = {b:GetRegions()}
            local ii = 1
            for _,c in pairs(r) do
                if c:GetObjectType() == "Texture" then
                    if ii == 1 then
                        c:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitembackdrop")
                        c:SetSize(b:GetSize())
                    end
                    ii = ii + 1
                end
            end
        end

        if t then t:SetTexCoord(0.1, 0.9, 0.1, 0.9) end
    end
end

local function setFontColorToWhite(self)
    self:SetTextColor(1, 1, 1, 1)
end

local function SkinMailFrameSendItems()
    for i = 1, _G.ATTACHMENTS_MAX_SEND do
        local b = _G["SendMailAttachment" .. i]
        if b then
            b:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
            local r = {b:GetRegions()}
            local ii = 1
            for _,c in pairs(r) do
                if c:GetObjectType() == "Texture" then
                    if ii == 1 then
                        c:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitembackdrop")
                        c:SetSize(b:GetSize())
                    end
                    ii = ii + 1
                end
            end
        end

        local t = b:GetNormalTexture()
        if t then t:SetTexCoord(0.1, 0.9, 0.1, 0.9) end

        b.IconBorder:ClearAllPoints()
        b.IconBorder:SetPoint("TOPLEFT", b, "TOPLEFT", -2, 2)
        b.IconBorder:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 2, -2)
    end
end

local function SkinSendMailFrame()

    GW.MutateInaccessableObject(SendMailCostMoneyFrame, "FontString", setFontColorToWhite)
    GW.MutateInaccessableObject(SendMailNameEditBox, "FontString", setFontColorToWhite)
    GW.MutateInaccessableObject(SendMailSubjectEditBox, "FontString", setFontColorToWhite)

    SkinMoneyFrame()
    SendMailMoneyText:SetTextColor(1, 1, 1, 1)

    -- configure location of SendMail Frame
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

    SendMailScrollFrame:GwStripTextures(true)
    GW.HandleTrimScrollBar(SendMailScrollFrame.ScrollBar, true)
    GW.HandleAchivementsScrollControls(SendMailScrollFrame)

    SendMailMoneyFrame:ClearAllPoints()
    SendMailMoneyFrame:SetPoint("BOTTOMRIGHT", SendMailFrame, "BOTTOMRIGHT", -40, 15)

    GW.SkinTextBox(SendMailNameEditBoxMiddle, SendMailNameEditBoxLeft, SendMailNameEditBoxRight, nil, nil, 5)
    GW.SkinTextBox(SendMailSubjectEditBoxMiddle, SendMailSubjectEditBoxLeft, SendMailSubjectEditBoxRight, nil, nil, 5)
    GW.SkinTextBox(SendMailMoneyGoldMiddle, SendMailMoneyGoldLeft, SendMailMoneyGoldRight, nil, nil, 5)
    GW.SkinTextBox(SendMailMoneySilverMiddle, SendMailMoneySilverLeft, SendMailMoneySilverRight, nil, nil, 5, -12)
    GW.SkinTextBox(SendMailMoneyCopperMiddle, SendMailMoneyCopperLeft, SendMailMoneyCopperRight, nil, nil, 5, -12)

    --reposition buttons
    SendMailMailButton:ClearAllPoints()
    SendMailMailButton:SetPoint("BOTTOMRIGHT", SendMailFrame, "BOTTOMRIGHT", -53, 57)

    SendMailCancelButton:ClearAllPoints()
    SendMailCancelButton:SetPoint("RIGHT", SendMailMailButton, "LEFT", -5, 0)
    SendMailCancelButton:SetText(RESET)
    SendMailCancelButton:SetScript("OnClick", function()
        SendMailFrame_Reset()
        --clear attachments
        for i = 1, ATTACHMENTS_MAX_SEND do
            ClickSendMailItemButton(i, true);
        end
    end)

    local cancelButton = CreateFrame("Button", "SendMailQuit", SendMailFrame, "UIPanelButtonNoTooltipTemplate")
    cancelButton:ClearAllPoints()
    cancelButton:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -5, 0)
    cancelButton:SetText(CANCEL)
    cancelButton:SetSize(SendMailCancelButton:GetSize())
    cancelButton:GwSkinButton(false, true)
    cancelButton:SetScript("OnClick", function(self)
        SendMailFrame_Reset()
        --clear attachments
        for i =1 , ATTACHMENTS_MAX_SEND do
            ClickSendMailItemButton(i, true);
        end

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
    MailFrameTab2:SetScript("OnClick", function(self)
        OpenMailFrame:Hide()
        MailFrameTab_OnClick(self, 2)

        InboxFrame:Show()
        SendMailFrame:Show()
        SendMailFrame_Update()
        SetSendMailShowing(true)
    end)
end

local function ClearMailTextures()
    MailFrameTitleText:Hide()
    _G.MailFrameBg:Hide()
    _G.MailFrameInset.NineSlice:Hide()
    _G.MailFrameInset:GwCreateBackdrop()

    MailFrame:GwStripTextures()
    InboxFrame:GwStripTextures()
    SendMailFrame:GwStripTextures()
    SendMailScrollFrame:GwStripTextures(true)
    OpenMailFrame:GwStripTextures()
    OpenMailScrollFrame:GwStripTextures()

    SendMailScrollFrame:GwCreateBackdrop(GW.skins.constBackdropFrame)

    MailFrame.NineSlice:Hide()
    MailFrame.TopTileStreaks:Hide()
    MailFrame:GwCreateBackdrop()

    OpenMailLetterButtonIconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    OpenMailLetterButton:GwStripTextures()
    OpenMailMoneyButtonIconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    OpenMailMoneyButton:GwStripTextures()

    for i = 1, _G.INBOXITEMS_TO_DISPLAY do
        local bg = _G["MailItem" .. i]
        bg:GwStripTextures()

        local btn = _G["MailItem" .. i .. "Button"]
        btn:GwStripTextures()

        local t = _G["MailItem" .. i .. "ButtonIcon"]
        t:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        local ib = _G["MailItem" .. i .. "ButtonIconBorder"]
        ib:ClearAllPoints()
        ib:SetPoint("TOPLEFT", t, "TOPLEFT", -2, 2)
        ib:SetPoint("BOTTOMRIGHT", t, "BOTTOMRIGHT", 2, -2)
        hooksecurefunc(ib, "SetVertexColor", function(self)
            self:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        end)
    end
    MailFrameTab1:Hide()
end

local function LoadMailSkin()
    if not GetSetting("MAIL_SKIN_ENABLED") then return end

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

    InvoiceTextFontNormal:SetTextColor(1, 1, 1)
    MailTextFontNormal:SetTextColor(1, 1, 1)

    -- Strip and hide default textures
    ClearMailTextures()

    -- Setup double sized frame to mimic approx. size for GW2 mail layout
    local newWidth, newHeight = MailFrame:GetSize()
    newWidth = (newWidth * 2.0) + 50
    newHeight = newHeight + 30
    MailFrame:SetSize(newWidth, newHeight)

    -- override max tabsize for the "compose" button (as it's just the send mail tab)
    MailFrame.maxTabWidth = 320

    -- Configure Mail Frame Background
    MailFrame.mailFrameBgTexture = MailFrame:CreateTexture(nil, "BACKGROUND", nil, -7)
    MailFrame.mailFrameBgTexture:SetSize(newWidth, newHeight)
    MailFrame.mailFrameBgTexture:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 0, 5)
    MailFrame.mailFrameBgTexture:SetTexture("Interface/AddOns/GW2_UI/textures/hud/mailboxwindow-background")
    MailFrame.mailFrameBgTexture:SetTexCoord(0,0.7099,0,0.955);

    -- Configure Mail Heading
    MailFrame.heading = MailFrame:CreateTexture(nil, "BACKGROUND")
    MailFrame.heading:SetSize(newWidth, 64)
    MailFrame.heading:SetPoint("BOTTOMLEFT", MailFrame, "TOPLEFT", 0, 0)
    MailFrame.heading:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader")

    MailFrame.heading.Title = MailFrame:CreateFontString("MailFrameTitle", "ARTWORK")
    MailFrame.heading.Title:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 50, 30)
    MailFrame.heading.Title:SetFont(DAMAGE_TEXT_FONT, 20)
    MailFrame.heading.Title:SetText(MAIL_LABEL)
    MailFrame.heading.Title:SetTextColor(1, .93, .73)

    MailFrame.icon = MailFrame:CreateTexture(nil, "ARTWORK")
    MailFrame.icon:SetSize(80, 80)
    MailFrame.icon:SetPoint("CENTER", MailFrame, "TOPLEFT", 12, 25)
    MailFrame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/mail-window-icon")

    MailFrame.headingRight = MailFrame:CreateTexture(nil, "BACKGROUND")
    MailFrame.headingRight:SetSize(newWidth, 64)
    MailFrame.headingRight:SetPoint("BOTTOMRIGHT", MailFrame, "TOPRIGHT", 0, 0)
    MailFrame.headingRight:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader-right")

    MailFrame.CloseButton:GwSkinButton(true, false)
    MailFrame.CloseButton:SetSize(20, 20)
    MailFrame.CloseButton:ClearAllPoints()
    MailFrame.CloseButton:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", -10, 30)
    MailFrame.CloseButton:SetParent(MailFrame)

    -- Configure footer
    MailFrame.footer = MailFrame:CreateTexture(nil, "BACKGROUND")
    MailFrame.footer:SetSize(newWidth, 70)
    MailFrame.footer:SetPoint("TOPLEFT", MailFrame, "BOTTOMLEFT", 0, 5)
    MailFrame.footer:SetPoint("TOPRIGHT", MailFrame, "BOTTOMRIGHT", 0, 5)
    MailFrame.footer:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagfooter")



    _G.AutoCompleteBox:GwStripTextures()
    _G.AutoCompleteBox:GwCreateBackdrop(GW.skins.constBackdropFrame)

    -- movable stuff
    local pos = GetSetting("MAILBOX_POSITION")
    MailFrame.mover = CreateFrame("Frame", nil, MailFrame)
    MailFrame.mover:EnableMouse(true)
    MailFrame:SetMovable(true)
    MailFrame.mover:SetSize(newWidth, 30)
    MailFrame.mover:SetPoint("BOTTOMLEFT", MailFrame, "TOPLEFT", 0, 0)
    MailFrame.mover:SetPoint("BOTTOMRIGHT", MailFrame, "TOPRIGHT", 0, 0)
    MailFrame.mover:RegisterForDrag("LeftButton")
    MailFrame.mover.onMoveSetting = "MAILBOX_POSITION"
    MailFrame:SetClampedToScreen(true)
    MailFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    MailFrame.mover:SetScript("OnDragStop", function(self)
        local self = self:GetParent()

        self:StopMovingOrSizing()

        local x = self:GetLeft()
        local y = self:GetTop()

        -- re-anchor to UIParent after the move
        self.SetPoint = nil -- Make SetPoint accessable
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
        self.SetPoint = GW.NoOp -- Prevent Blizzard to reanchor that frame

        -- store the updated position
        if self.mover.onMoveSetting then
            local pos = GetSetting(self.mover.onMoveSetting)
            if pos then
                wipe(pos)
            else
                pos = {}
            end
            pos.point = "TOPLEFT"
            pos.relativePoint = "BOTTOMLEFT"
            pos.xOfs = x
            pos.yOfs = y
            SetSetting(self.mover.onMoveSetting, pos)
        end
    end)
    MailFrame:ClearAllPoints()
    MailFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    MailFrame.SetPoint = GW.NoOp -- Prevent Blizzard to reanchor that frame

    -- Reskin OpenMailFrame Buttons
    SkinPager()
    SkinOpenMailFrame()
    SkinSendMailFrame()
    SkinComposeButton()
    AddFrameSeperator()

    -- Hook's
    hooksecurefunc("SendMailFrame_Update", SkinMailFrameSendItems)

    -- hook inbox buttons to close the compose view if we want to look at a message and it's open
    AddOnClickHandlers()

    -- Skin Postal Addon
    GW.LoadPostalAddonSkin()
end
GW.LoadMailSkin = LoadMailSkin
