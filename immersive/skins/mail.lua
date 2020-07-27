local _, GW = ...
local L = GW.L
local constBackdropFrame = GW.skins.constBackdropFrame

local function FixMailSkin()
    MailFrameTab2:SetSize(310, 24)
end
GW.FixMailSkin = FixMailSkin

local function SkinMail()

    -- Strip and hide default textures
    local MailFrame = _G.MailFrame
    local InboxFrame = _G.InboxFrame
    local SendMailFrame = _G.SendMailFrame
    local OpenMailFrame = _G.OpenMailFrame

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

    -- Setup double sized frame to mimic approx. size for GW2 mail layout
    local newWidth, newHeight = MailFrame:GetSize()
    newWidth = (newWidth * 2.0) + 50
    newHeight = newHeight + 80
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
    inboxHeading:SetPoint("BOTTOMLEFT", nil, "TOPLEFT", 0, 5)
    inboxHeading:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader")
    InboxFrame.heading = inboxHeading

    -- configure location of SendMail Frame
    SendMailFrame:ClearAllPoints()
    SendMailFrame:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", 0, 0)
    SendMailFrame:SetParent(MailFrame)

    -- configure location of OpenMail Frame
    OpenMailFrame:ClearAllPoints()
    OpenMailFrame:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", 0, 0)
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

    InboxTitleText:SetPoint("TOPLEFT", MailItem1, "TOPLEFT", -85, 20)
    InboxTitleText:SetFont(UNIT_NAME_FONT, 14)
    InboxTitleText:SetTextColor(1, 1, 1, 1)

    -- Reskin OpenMailFrame Buttons
    OpenMailReportSpamButton:SkinButton(false, true)
    OpenMailReplyButton:SkinButton(false, true)
    OpenMailDeleteButton:SkinButton(false, true)
    OpenMailCancelButton:SkinButton(false, true)
    OpenAllMail:SkinButton(false, true)
    OpenMailScrollChildFrame:SkinScrollFrame()
    OpenMailScrollFrameScrollBar:SkinScrollBar()

    SendMailCancelButton:SkinButton(false, true)
    SendMailMailButton:SkinButton(false, true)

    MailFrameTab1:Hide()
    MailFrameTab2:SetSize(310, 24)
    -- MailFrameTab2:SetFont(UNIT_NAME_FONT, 14)
    MailFrameTab2:SetText("Compose")
    MailFrameTab2:SetPoint("TOPLEFT", InboxTitleText, "TOPLEFT", 85, 35)
    MailFrameTab2:SkinButton(false, true)
    MailFrameTab2:SetScript("OnClick", function()
        OpenMailFrame:Hide()
        MailFrameTab_OnClick(self, 2)

        InboxFrame:Show()
        SendMailFrame:Show()
        SendMailFrame_Update()
        SetSendMailShowing(true)
    end)
    -- hook inbox buttons to close the compose view if we want to look at a message and it's open
end
GW.SkinMail = SkinMail

GW.SkinMail()
