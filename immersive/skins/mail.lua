local _, GW = ...
local L = GW.L
local constBackdropFrame = GW.skins.constBackdropFrame

-- get local references
local MailFrame = _G.MailFrame
local InboxFrame = _G.InboxFrame
local SendMailFrame = _G.SendMailFrame
local OpenMailFrame = _G.OpenMailFrame

local function FixMailSkin()
    MailFrameTab2:SetSize(310, 24)
end
GW.FixMailSkin = FixMailSkin

local function SkinOpenMailFrame()
    -- configure location of OpenMail Frame
    OpenMailFrame:ClearAllPoints()
    OpenMailFrame:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", 0, 20)
    OpenMailFrameCloseButton:Hide()
    OpenMailTitleText:Hide()
    OpenMailFrameIcon:Hide()
    OpenMailSenderLabel:Hide()
    OpenMailSubjectLabel:Hide()

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
    OpenMailReplyButton:SetPoint("RIGHT", OpenMailDeleteButton, "LEFT", -5, 0)

    OpenMailDeleteButton:SkinButton(false, true)
    OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -5, 0)

    OpenMailCancelButton:SkinButton(false, true)

    OpenAllMail:SkinButton(false, true)
    OpenMailScrollChildFrame:SkinScrollFrame()
    OpenMailScrollFrameScrollBar:SkinScrollBar()
end

local function SkinSendMailFrame()
    -- configure location of SendMail Frame
    SendMailFrame:ClearAllPoints()
    SendMailFrame:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", 46, 20)
    SendMailFrame:SetParent(MailFrame)

    --Hides
    SendMailTitleText:Hide()
    SendStationeryBackgroundLeft:Hide() 
    SendStationeryBackgroundRight:Hide() 
    
    SendMailCancelButton:SkinButton(false, true)
    SendMailMailButton:SkinButton(false, true)

    SendMailScrollChildFrame:SkinScrollFrame()
    -- SendMailScrollChildFrame.mailFrameBgTexture = MailFrame:CreateTexture("MailFrameBgTexture", "BACKGROUND")
    -- SendMailScrollChildFrame.mailFrameBgTexture:SetSize(SendMailScrollChildFrame:GetSize())
    -- SendMailScrollChildFrame.mailFrameBgTexture:SetPoint("TOPLEFT", SendMailScrollChildFrame, "TOPLEFT", 5, 5)
    -- SendMailScrollChildFrame.mailFrameBgTexture:SetTexture("Interface/AddOns/GW2_UI/textures/chatframebackground")
    -- SendMailScrollChildFrame.mailFrameBgTexture:SetAlpha(.5)
    SendMailScrollFrameScrollBar:SkinScrollBar()

    SendMailMoneyBg:Hide()
    SendMailMoneyInset:Hide()
    SendMailMoneyFrame:ClearAllPoints()
    SendMailMoneyFrame:SetPoint("BOTTOMLEFT", InboxFrame, "BOTTOMLEFT", 10, 42)
    
    SendMailBodyEditBox:SetFont(UNIT_NAME_FONT, 14)
    SendMailBodyEditBox:SetTextColor(1, 1, 1, 1)

    --reposition buttons
    SendMailMailButton:ClearAllPoints()
    SendMailMailButton:SetPoint("BOTTOMRIGHT", SendMailFrame, "BOTTOMRIGHT", -53, 92)

    SendMailCancelButton:ClearAllPoints()
    SendMailCancelButton:SetPoint("RIGHT", SendMailMailButton, "LEFT", -5, 0)
    SendMailCancelButton:SetText("Clear")
    SendMailCancelButton:SetScript("OnClick", function()
        SendMailFrame_Reset()    
        --clear attachments
        for i=1, ATTACHMENTS_MAX_SEND do
            ClickSendMailItemButton(i, true);	
        end
    end)

    local cancelButton = CreateFrame("Button", "SendMailQuit", SendMailFrame, "UIPanelButtonNoTooltipTemplate")
    cancelButton:ClearAllPoints()
    cancelButton:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -5, 0)
    cancelButton:SetText("Cancel")
    cancelButton:SetSize(SendMailCancelButton:GetSize())
    cancelButton:SkinButton(false, true)
    cancelButton:SetScript("OnClick", function()
        SendMailFrame_Reset()    
        --clear attachments
        for i=1, ATTACHMENTS_MAX_SEND do
            ClickSendMailItemButton(i, true);	
        end

        SendMailFrame:Hide()  
        SetSendMailShowing(false)
        MailFrameTab_OnClick(self, 1)
    end)


end

local function SkinComposeButton()
    MailFrameTab2:SetSize(310, 24)
    -- MailFrameTab2:SetFont(UNIT_NAME_FONT, 14)
    MailFrameTab2:SetText("Compose")
    MailFrameTab2:SetPoint("TOPLEFT", InboxTitleText, "TOPLEFT", 85, 40)
    MailFrameTab2:SkinButton(false, true)
    MailFrameTab2:SetScript("OnClick", function()
        --SendMailScrollChildFrame.mailFrameBgTexture:Show()
        OpenMailFrame:Hide()
        MailFrameTab_OnClick(self, 2)

        InboxFrame:Show()
        SendMailFrame:Show()
        SendMailFrame_Update()
        SetSendMailShowing(true)
    end)
end

local function ClearMailTextures()
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

    MailFrameTab1:Hide()
end

local function InboxFrameMailItem_OnClick()
    
    -- local modifiedClick = IsModifiedClick("MAILAUTOLOOTTOGGLE");
    -- if ( modifiedClick ) then
    --     InboxFrame_OnModifiedClick(self, self.index);
    -- else
    --     InboxFrame_OnClick(self, self.index);
    -- end
end

local function SkinMail()

    -- Strip and hide default textures
    _G.MailFrameBg:Hide()
    _G.MailFrameInset.NineSlice:Hide()
    _G.MailFrameInset:SetBackdrop(constBackdropFrameBorder)

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
    MailFrame.heading:SetPoint("BOTTOMLEFT", MailFrame, "TOPLEFT", 0, 5)
    MailFrame.heading:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader")

    MailFrame.heading.Title = MailFrame:CreateFontString("MailFrameTitle", "ARTWORK")
    MailFrame.heading.Title:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 5, 30)
    MailFrame.heading.Title:SetFont(DAMAGE_TEXT_FONT, 20)
    MailFrame.heading.Title:SetText("Mail")

    -- MailFrame.icon = MailFrame:CreateTexture("MailFrameIcon", "ARTWORK")
    -- MailFrame.icon:SetSize(128, 128)
    -- MailFrame.icon:SetPoint("CENTER", MailFrame, "TOPLEFT", -16, 16)
    -- MailFrame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/mail-icon")

    MailFrame.headingRight = MailFrame:CreateTexture("bg", "BACKGROUND")
    MailFrame.headingRight:SetSize(newWidth, 64)
    MailFrame.headingRight:SetPoint("BOTTOMRIGHT", MailFrame, "TOPRIGHT", 0, 5)
    MailFrame.headingRight:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader-right")
 
    MailFrame.CloseButton:SkinButton(true, false)
    MailFrame.CloseButton:SetSize(25, 25)
    MailFrame.CloseButton:ClearAllPoints()
    MailFrame.CloseButton:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", -5, 36)
    MailFrame.CloseButton:SetParent(MailFrame)

    -- Configure footer
    MailFrame.footer = MailFrame:CreateTexture("bg", "BACKGROUND")
    MailFrame.footer:SetSize(newWidth, 70)
    MailFrame.footer:SetPoint("TOPLEFT", MailFrame, "BOTTOMLEFT", 0, 10)
    MailFrame.footer:SetPoint("TOPRIGHT", MailFrame, "BOTTOMRIGHT", 0, 10)
    MailFrame.footer:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagfooter")
   
    local inboxHeading = InboxFrame:CreateTexture("InboxHeadingBgTexture", "BACKGROUND")
    inboxHeading:SetSize(newWidth, 64)
    inboxHeading:SetPoint("BOTTOMLEFT", InboxTitleText, "TOPLEFT", 85, -24)
    inboxHeading:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader")
    
    InboxFrame.heading = inboxHeading
    InboxFrame.heading:SetWidth(310)

    InboxTitleText:SetPoint("TOPLEFT", MailItem1, "TOPLEFT", -85, 20)
    InboxTitleText:SetFont(UNIT_NAME_FONT, 14)
    InboxTitleText:SetTextColor(1, 1, 1, 1)

    -- Reskin OpenMailFrame Buttons
    SkinOpenMailFrame()
    SkinSendMailFrame()
    SkinComposeButton()

    -- hook inbox buttons to close the compose view if we want to look at a message and it's open



end
GW.SkinMail = SkinMail



GW.SkinMail()
