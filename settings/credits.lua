local _, GW = ...
local L = GW.L

local function CreateContentLines(num, parent, anchorTo)
    local content = CreateFrame("Frame", nil, parent)
    content:SetSize(260, (num * 20) + ((num - 1) * 5))
    content:SetPoint("TOP", anchorTo, "BOTTOM",0 , 0)

    for i = 1, num do
        local line = CreateFrame("Frame", nil, content)
        line:SetSize(260, 20)

        local text = line:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
        text:SetAllPoints()
        text:SetJustifyH("CENTER")
        text:SetJustifyV("MIDDLE")
        line.Text = text

        local numLine = line
        if i == 1 then
            numLine:SetPoint("TOP", content, "TOP")
        else
            numLine:SetPoint("TOP", content["Line" .. (i - 1)], "BOTTOM", 0, 0)
        end

        content["Line" .. i] = numLine
    end

    return content
end

local function CreateSection(width, height, parent, anchor1, anchorTo, anchor2, yOffset, oneDivider)
    local section = CreateFrame("Frame", nil, parent)
    section:SetSize(width, height)
    section:SetPoint(anchor1, anchorTo, anchor2, 0, yOffset)

    local header = CreateFrame("Frame", nil, section)
    header:SetSize(300, 30)
    header:SetPoint("TOP", section)
    section.Header = header

    local text = section.Header:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
    text:SetPoint("TOP")
    text:SetPoint("BOTTOM")
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")

    local font, fontHeight, fontFlags = text:GetFont()
    text:SetFont(font, fontHeight * 1.3, fontFlags)
    section.Header.Text = text

    if oneDivider then
        local Divider = section.Header:CreateTexture(nil, "ARTWORK")
        Divider:SetHeight(2)
        Divider:SetPoint("LEFT", section.Header, "LEFT", -20, 0)
        Divider:SetPoint("RIGHT", section.Header, "RIGHT", 20, 0)
        Divider:SetTexture("Interface/AddOns/GW2_UI/textures/levelreward-sep")
        section.Header.Divider = Divider
    else
        local leftDivider = section.Header:CreateTexture(nil, "ARTWORK")
        leftDivider:SetHeight(2)
        leftDivider:SetPoint("LEFT", section.Header, "LEFT", -10, 0)
        leftDivider:SetPoint("RIGHT", section.Header.Text, "LEFT", 20, 0)
        leftDivider:SetTexture("Interface/AddOns/GW2_UI/textures/levelreward-sep")
        section.Header.LeftDivider = leftDivider

        local rightDivider = section.Header:CreateTexture(nil, "ARTWORK")
        rightDivider:SetHeight(2)
        rightDivider:SetPoint("RIGHT", section.Header, "RIGHT", 10, 0)
        rightDivider:SetPoint("LEFT", section.Header.Text, "RIGHT", -20, 0)
        rightDivider:SetTexture("Interface/AddOns/GW2_UI/textures/levelreward-sep")
        section.Header.RightDivider = rightDivider
    end

    return section
end

local function CreateCreditsFrame()
    local BackdropFrame = {
        bgFile = "Interface/AddOns/GW2_UI/textures/welcome-bg",
        edgeFile = "",
        tile = false,
        tileSize = 64,
        edgeSize = 32,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    }

    --Main frame
    local CreditsFrame = CreateFrame("Frame", "GWCreditsFrame", UIParent)
    CreditsFrame:SetSize(320, 815)
    CreditsFrame:SetPoint("CENTER", UIParent, "CENTER")
    CreditsFrame:SetFrameStrata("HIGH")
    CreditsFrame:CreateBackdrop(BackdropFrame)
    CreditsFrame:SetMovable(true)
    CreditsFrame:Hide()

    --Title logo (drag to move frame)
    local titleLogoFrame = CreateFrame("Frame", nil, CreditsFrame, "TitleDragAreaTemplate")
    titleLogoFrame:SetPoint("TOP", CreditsFrame, "TOP")
    titleLogoFrame:SetSize(240, 150)
    CreditsFrame.TitleLogoFrame = titleLogoFrame

    local titleTexture = CreditsFrame.TitleLogoFrame:CreateTexture(nil, "ARTWORK")
    titleTexture:SetPoint("CENTER", titleLogoFrame, "CENTER")
    titleTexture:SetTexture("Interface/AddOns/GW2_UI/textures/gwlogo")
    titleTexture:SetSize(128, 128)
    titleLogoFrame.Texture = titleTexture

    --Sections
    CreditsFrame.Section1 = CreateSection(300, 55, CreditsFrame, "TOP", CreditsFrame, "TOP", -150)
    CreditsFrame.Section2 = CreateSection(300, 95, CreditsFrame, "TOP", CreditsFrame.Section1, "BOTTOM", 0)
    CreditsFrame.Section3 = CreateSection(300, 55, CreditsFrame, "TOP", CreditsFrame.Section2, "BOTTOM", 0)
    CreditsFrame.Section4 = CreateSection(300, 255, CreditsFrame, "TOP", CreditsFrame.Section3, "BOTTOM", 0)
    CreditsFrame.Section5 = CreateSection(300, 125, CreditsFrame, "TOP", CreditsFrame.Section4, "BOTTOM", 0)
    CreditsFrame.Section6 = CreateSection(300, 55, CreditsFrame, "TOP", CreditsFrame.Section5, "BOTTOM", 0, true)

    --Section headers
    CreditsFrame.Section1.Header.Text:SetText(GW.Gw2Color .. L["\nCreated by: "]:gsub("\n", ""):gsub(":", "")  .. "|r")
    CreditsFrame.Section2.Header.Text:SetText(GW.Gw2Color .. L["Developed by"] .. "|r")
    CreditsFrame.Section3.Header.Text:SetText(GW.Gw2Color .. L["With Contributions by"] .. "|r")
    CreditsFrame.Section4.Header.Text:SetText(GW.Gw2Color .. L["Localised by"] .. "|r")
    CreditsFrame.Section5.Header.Text:SetText(GW.Gw2Color .. L["QA Testing by"] .. "|r")
    CreditsFrame.Section6.Header.Text:SetText("")

    --Section content
    CreditsFrame.Section1.Content = CreateContentLines(1, CreditsFrame.Section1, CreditsFrame.Section1.Header)
    CreditsFrame.Section2.Content = CreateContentLines(3, CreditsFrame.Section2, CreditsFrame.Section2.Header)
    CreditsFrame.Section3.Content = CreateContentLines(1, CreditsFrame.Section3, CreditsFrame.Section3.Header)
    CreditsFrame.Section4.Content = CreateContentLines(11, CreditsFrame.Section4, CreditsFrame.Section4.Header)
    CreditsFrame.Section5.Content = CreateContentLines(5, CreditsFrame.Section5, CreditsFrame.Section5.Header)
    CreditsFrame.Section6.Content = CreateFrame("Frame", nil, CreditsFrame.Section6)
    CreditsFrame.Section6.Content:SetSize(240, 25)
    CreditsFrame.Section6.Content:SetPoint("TOP", CreditsFrame.Section6.Header, "BOTTOM", 0, 0)

    --Content lines
    --Created by
    CreditsFrame.Section1.Content.Line1.Text:SetText("Aethelwulf")

    --Developed by
    CreditsFrame.Section2.Content.Line1.Text:SetText("Glow")
    CreditsFrame.Section2.Content.Line2.Text:SetText("nezroy")
    CreditsFrame.Section2.Content.Line3.Text:SetText("Shrugal")

    --With Contributions by
    CreditsFrame.Section3.Content.Line1.Text:SetText("hatdragon")

    --Localised by
    CreditsFrame.Section4.Content.Line1.Text:SetText("aSlightDrizzle - Localisation Team Lead")
    CreditsFrame.Section4.Content.Line2.Text:SetText("Calcifer - Italian")
    CreditsFrame.Section4.Content.Line3.Text:SetText("Murak - Italian")
    CreditsFrame.Section4.Content.Line4.Text:SetText("AxelVader - Spanish (Spain)")
    CreditsFrame.Section4.Content.Line5.Text:SetText("Crisll - Spanish (Spain)")
    CreditsFrame.Section4.Content.Line6.Text:SetText("Dololo - Chinese (Taiwan)")
    CreditsFrame.Section4.Content.Line7.Text:SetText("Kitto - French")
    CreditsFrame.Section4.Content.Line8.Text:SetText("Pyrefox - Portuguese")
    CreditsFrame.Section4.Content.Line9.Text:SetText("RickCiotti - Spanish (Latin America)")
    CreditsFrame.Section4.Content.Line10.Text:SetText("Throli - Korean")
    CreditsFrame.Section4.Content.Line11.Text:SetText("Zelrog - Russian")

    --QA Testing by
    CreditsFrame.Section5.Content.Line1.Text:SetText("Crohnleuchter")
    CreditsFrame.Section5.Content.Line2.Text:SetText("KYZ")
    CreditsFrame.Section5.Content.Line3.Text:SetText("Ultrachocobo")
    CreditsFrame.Section5.Content.Line4.Text:SetText("Belazor")
    CreditsFrame.Section5.Content.Line5.Text:SetText("Zerid")

    --Action button
    CreditsFrame.Section6.Content.Button = CreateFrame("Button", nil, CreditsFrame.Section6.Content, "GwStandardButton")
    CreditsFrame.Section6.Content.Button:SetSize(100, 25)
    CreditsFrame.Section6.Content.Button:SetPoint("CENTER", CreditsFrame.Section6.Content, "CENTER")
    CreditsFrame.Section6.Content.Button:SetText(CLOSE)
    CreditsFrame.Section6.Content.Button:SetScript("OnClick", function()
        HideUIPanel(CreditsFrame)
        GwSettingsWindow:Show()
    end)

    tinsert(UISpecialFrames, "GWCreditsFrame")

    return CreditsFrame
end

local function ShowCredits()
    if not GW.CreditsFrame then
        GW.CreditsFrame = CreateCreditsFrame()
    end

    if not GW.CreditsFrame:IsShown() then
        GW.CreditsFrame:Raise()
        GW.CreditsFrame:Show()
    else
        GW.CreditsFrame:Hide()
    end
end
GW.ShowCredits = ShowCredits
