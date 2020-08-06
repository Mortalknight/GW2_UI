local _, GW = ...
local L = GW.L
local constBackdropFrame = GW.skins.constBackdropFrame
local SetSetting = GW.SetSetting
local GetSetting = GW.GetSetting

-- get local references
local MailFrame = _G.MailFrame
local InboxFrame = _G.InboxFrame
local SendMailFrame = _G.SendMailFrame
local OpenMailFrame = _G.OpenMailFrame

local function FixMailSkin()
    MailFrameTab2:SetSize(310, 24)
    SendMailSendMoneyButtonText:SetTextColor(1, 1, 1, 1)
    SendMailCODButtonText:SetTextColor(1, 1, 1, 1)
end

local function AddFrameSeperator()
    MailFrame.mailFrameSepTexture = MailFrame:CreateTexture("MailFrameSepTexture", "ARTWORK")
    MailFrame.mailFrameSepTexture:SetSize(600, 2)
    MailFrame.mailFrameSepTexture:SetPoint("BOTTOMRIGHT", MailFrame, "BOTTOMRIGHT", 110, 50)
    MailFrame.mailFrameSepTexture:SetTexture("Interface/AddOns/GW2_UI/textures/levelreward-sep")
end

local function AddOnClickHandlers()
    for i = 1, _G.INBOXITEMS_TO_DISPLAY do
        local b = _G["MailItem" .. i .. "Button"]
        
        if b then
            local r = {b:GetRegions()}
            local ii = 1
            
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
    OpenMailTitleText:Hide()
    OpenMailFrameIcon:Hide()
    OpenMailSenderLabel:Hide()
    OpenMailSubjectLabel:Hide()
    OpenStationeryBackgroundLeft:Hide() 
    OpenStationeryBackgroundRight:Hide() 

    OpenMailBodyText:SetFont(UNIT_NAME_FONT, 14)
    OpenMailBodyText:SetTextColor(1, 1, 1, 1)

    OpenMailFrame.NineSlice:Hide()
    OpenMailFrame.TitleBg:Hide()
    OpenMailFrame.TopTileStreaks:Hide()
    OpenMailFrame:SetBackdrop(nil)
    OpenMailFrame:SetParent(MailFrame)

    OpenMailSenderLabel:Hide()
    OpenMailSender.Name:SetPoint("TOPLEFT", OpenMailScrollFrame, "TOPLEFT", 0, 50)
    OpenMailSender.Name:SetFont(UNIT_NAME_FONT, 14)
    OpenMailSender.Name:SetTextColor(1, 1, 1, 1)

    OpenMailSubjectLabel:Hide()
    OpenMailSubject:SetPoint("TOPLEFT", OpenMailSender.Name, "BOTTOMLEFT", 0, -10)
    OpenMailSubject:SetFont(UNIT_NAME_FONT, 12)
    OpenMailSubject:SetTextColor(1, 1, 1, 1)

    OpenMailReportSpamButton:SkinButton(false, true)
    OpenMailReplyButton:SkinButton(false, true)
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

    OpenMailDeleteButton:SkinButton(false, true)
    OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -5, 0)

    OpenMailCancelButton:SkinButton(false, true)
    OpenMailCancelButton:SetPoint("BOTTOMRIGHT", OpenMailFrame, "BOTTOMRIGHT", -7, -31)

    OpenAllMail:SkinButton(false, true)
    OpenMailScrollChildFrame:SkinScrollFrame()
    OpenMailScrollFrameScrollBar:SkinScrollBar()

    for i = 1, _G.ATTACHMENTS_MAX_RECEIVE do
        local b = _G["OpenMailAttachmentButton" .. i]
        local t = _G["OpenMailAttachmentButton" .. i .. "IconTexture"]
        
    b:StripTextures()
        
        if b then
            b:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/UI-Quickslot-Depress")
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
            b:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/UI-Quickslot-Depress")
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
    SendMailTitleText:Hide()
    SendStationeryBackgroundLeft:Hide() 
    SendStationeryBackgroundRight:Hide()    
    SendMailMoneyBg:Hide()
    SendMailMoneyInset:Hide() 
    
    SendMailCancelButton:SkinButton(false, true)
    SendMailMailButton:SkinButton(false, true)

    SendMailScrollChildFrame:SkinScrollFrame()
    SendMailScrollFrameScrollBar:SkinScrollBar()

    SendMailMoneyFrame:ClearAllPoints()
    SendMailMoneyFrame:SetPoint("BOTTOMLEFT", InboxFrame, "BOTTOMLEFT", 10, 42)
    
    GW.SkinTextBox(SendMailNameEditBoxLeft,SendMailNameEditBoxMiddle, SendMailNameEditBoxRight)
    GW.SkinTextBox(SendMailSubjectEditBoxLeft,SendMailSubjectEditBoxMiddle, SendMailSubjectEditBoxRight)
    GW.SkinTextBox(SendMailMoneyGoldLeft,SendMailMoneyGoldMiddle, SendMailMoneyGoldRight)
    GW.SkinTextBox(SendMailMoneySilverLeft,SendMailMoneySilverMiddle, SendMailMoneySilverRight)
    GW.SkinTextBox(SendMailMoneyCopperLeft,SendMailMoneyCopperMiddle, SendMailMoneyCopperRight)

    SendMailBodyEditBox:SetFont(UNIT_NAME_FONT, 14)
    SendMailBodyEditBox:SetTextColor(1, 1, 1, 1)

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
    cancelButton:SkinButton(false, true)
    cancelButton:SetScript("OnClick", function()
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
    MailFrameTab2:SetSize(310, 24)
    MailFrameTab2:SetText(SENDMAIL)
    MailFrameTab2:SetPoint("TOPLEFT", InboxTitleText, "TOPLEFT", -10, 40)
    MailFrameTab2:SkinButton(false, true)
    MailFrameTab2:SetScript("OnClick", function()
        OpenMailFrame:Hide()
        MailFrameTab_OnClick(self, 2)

        InboxFrame:Show()
        SendMailFrame:Show()
        SendMailFrame_Update()
        SetSendMailShowing(true)
    end)
end

local function ClearMailTextures()
    _G.MailFrameBg:Hide()
    _G.MailFrameInset.NineSlice:Hide()
    _G.MailFrameInset:SetBackdrop(constBackdropFrameBorder)

    MailFrame:StripTextures()
    InboxFrame:StripTextures()
    SendMailFrame:StripTextures()
    SendMailScrollFrame:StripTextures()
    OpenMailFrame:StripTextures()
    OpenMailScrollFrame:StripTextures()

    MailFrame.NineSlice:Hide()
    MailFrame.TitleBg:Hide()
    MailFrame.TopTileStreaks:Hide()
    MailFrame:SetBackdrop(nil)

    for i = 1, _G.INBOXITEMS_TO_DISPLAY do
        local bg = _G["MailItem" .. i]
        bg:StripTextures()
        
        local btn = _G["MailItem" .. i .. "Button"]
        btn:StripTextures()
        
        local t = _G["MailItem" .. i .. "ButtonIcon"]
        t:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            
        local ib = _G["MailItem" .. i .. "ButtonIconBorder"]
        ib:ClearAllPoints()
        ib:SetPoint("TOPLEFT", t, "TOPLEFT", -2, 2)
        ib:SetPoint("BOTTOMRIGHT", t, "BOTTOMRIGHT", 2, -2)
        hooksecurefunc("SetItemButtonQuality", function(button)
            button.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        end)            
    end
    MailFrameTab1:Hide()
end

local function SkinMail()
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("MAIL_SHOW")
    eventFrame:RegisterEvent("MAIL_INBOX_UPDATE");
    eventFrame:RegisterEvent("MAIL_CLOSED");
    eventFrame:RegisterEvent("MAIL_SEND_INFO_UPDATE");
    eventFrame:RegisterEvent("MAIL_SEND_SUCCESS");
    eventFrame:RegisterEvent("MAIL_FAILED");
    eventFrame:RegisterEvent("MAIL_SUCCESS");    
    eventFrame:RegisterEvent("CLOSE_INBOX_ITEM");
    eventFrame:RegisterEvent("MAIL_LOCK_SEND_ITEMS");
    eventFrame:RegisterEvent("MAIL_UNLOCK_SEND_ITEMS");
    eventFrame:RegisterEvent("TRIAL_STATUS_UPDATE");
    eventFrame:SetScript("OnEvent", FixMailSkin)

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
    MailFrame.mailFrameBgTexture = MailFrame:CreateTexture("MailFrameBgTexture", "BACKGROUND")
    MailFrame.mailFrameBgTexture:SetSize(newWidth, newHeight)
    MailFrame.mailFrameBgTexture:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 0, 5)
    MailFrame.mailFrameBgTexture:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagbg")

    -- Configure Mail Heading
    MailFrame.heading = MailFrame:CreateTexture("bg", "BACKGROUND")
    MailFrame.heading:SetSize(newWidth, 64)
    MailFrame.heading:SetPoint("BOTTOMLEFT", MailFrame, "TOPLEFT", 0, 0)
    MailFrame.heading:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader")

    MailFrame.heading.Title = MailFrame:CreateFontString("MailFrameTitle", "ARTWORK")
    MailFrame.heading.Title:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 15, 30)
    MailFrame.heading.Title:SetFont(DAMAGE_TEXT_FONT, 20)
    MailFrame.heading.Title:SetText(MAIL_LABEL)
    MailFrame.heading.Title:SetTextColor(1, .93, .73)

    --MailFrame.icon = MailFrame:CreateTexture("MailFrameIcon", "ARTWORK")
    --MailFrame.icon:SetSize(64, 64)
    --MailFrame.icon:SetPoint("CENTER", MailFrame, "TOPLEFT", -16, 16)
    --MailFrame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/mail")

    MailFrame.headingRight = MailFrame:CreateTexture("bg", "BACKGROUND")
    MailFrame.headingRight:SetSize(newWidth, 64)
    MailFrame.headingRight:SetPoint("BOTTOMRIGHT", MailFrame, "TOPRIGHT", 0, 0)
    MailFrame.headingRight:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader-right")
 
    MailFrame.CloseButton:SkinButton(true, false)
    MailFrame.CloseButton:SetSize(20, 20)
    MailFrame.CloseButton:ClearAllPoints()
    MailFrame.CloseButton:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", -10, 30)
    MailFrame.CloseButton:SetParent(MailFrame)

    -- Configure footer
    MailFrame.footer = MailFrame:CreateTexture("bg", "BACKGROUND")
    MailFrame.footer:SetSize(newWidth, 70)
    MailFrame.footer:SetPoint("TOPLEFT", MailFrame, "BOTTOMLEFT", 0, 10)
    MailFrame.footer:SetPoint("TOPRIGHT", MailFrame, "BOTTOMRIGHT", 0, 10)
    MailFrame.footer:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagfooter")
   
    InboxFrame.heading = InboxFrame:CreateTexture("InboxHeadingBgTexture", "BACKGROUND")
    InboxFrame.heading:SetSize(newWidth, 48)
    InboxFrame.heading:SetPoint("BOTTOMLEFT", InboxTitleText, "TOPLEFT", -10, -21)
    InboxFrame.heading:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader")
    InboxFrame.heading:SetWidth(310)

    InboxTitleText:SetPoint("TOPLEFT", MailItem1, "TOPLEFT", 5, 20)
    InboxTitleText:SetFont(UNIT_NAME_FONT, 14)
    InboxTitleText:SetTextColor(1, 1, 1, 1)
    InboxTitleText:SetJustifyH("LEFT")

    _G.AutoCompleteBox:SetBackdrop(GW.skins.constBackdropFrame)

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
    MailFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    MailFrame.mover:SetScript("OnDragStop", function(self)
        local self = self:GetParent()

        self:StopMovingOrSizing()
        -- check if frame is out of screen, if yes move it back
        ValidateFramePosition(self)

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
end
GW.SkinMail = SkinMail
