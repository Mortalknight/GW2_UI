local _, GW = ...

local function AreOtherAddOnsEnabled()
    for i = 1, GetNumAddOns() do
        local name = GetAddOnInfo(i)
        if name ~= "GW2_UI"and GetAddOnEnableState(GW.myname, name) == 2 then --Loaded or load on demand
            return "|cffff0000Yes|r"
        end
    end
    return "|cff4beb2cNo|r"
end

local function CheckForPasteAddon()
    for i = 1, GetNumAddOns() do
        local name = GetAddOnInfo(i)
        if name == "Paste"and GetAddOnEnableState(GW.myname, name) == 2 then --Loaded or load on demand
            return true
        end
    end
    return false
end
GW.CheckForPasteAddon = CheckForPasteAddon

local function GetDisplayMode()
    local window, maximize = GetCVar("gxWindow") == "1", GetCVar("gxMaximize") == "1"
    return (window and maximize and "Windowed (Fullscreen)") or (window and "Windowed") or "Fullscreen"
end

local EnglishClassName = {
    ["DRUID"] = "Druid",
    ["HUNTER"] = "Hunter",
    ["MAGE"] = "Mage",
    ["MONK"] = "Monk",
    ["PALADIN"] = "Paladin",
    ["PRIEST"] = "Priest",
    ["ROGUE"] = "Rogue",
    ["SHAMAN"] = "Shaman",
    ["WARLOCK"] = "Warlock",
    ["WARRIOR"] = "Warrior"
}

local function CreateContentLines(num, parent, anchorTo)
    local content = CreateFrame("Frame", nil, parent)
    content:SetSize(260, (num * 20) + ((num - 1) * 5))
    content:SetPoint("TOP", anchorTo, "BOTTOM",0 , -5)

    for i = 1, num do
        local line = CreateFrame("Frame", nil, content)
        line:SetSize(260, 20)

        local text = line:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
        text:SetAllPoints()
        text:SetJustifyH("LEFT")
        text:SetJustifyV("MIDDLE")
        line.Text = text

        local numLine = line
        if i == 1 then
            numLine:SetPoint("TOP", content, "TOP")
        else
            numLine:SetPoint("TOP", content["Line" .. (i - 1)], "BOTTOM", 0, -5)
        end

        content["Line" .. i] = numLine
    end

    return content
end

local function CreateSection(width, height, parent, anchor1, anchorTo, anchor2, yOffset)
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

    return section
end

local function CreateStatusFrame()
    local BackdropFrame = {
        bgFile = "Interface/AddOns/GW2_UI/textures/welcome-bg",
        edgeFile = "",
        tile = false,
        tileSize = 64,
        edgeSize = 32,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    }
    local isPasteAddon = CheckForPasteAddon()

    --Main frame
    local StatusFrame = CreateFrame("Frame", "GWStatusFrame", UIParent)
    StatusFrame:SetSize(320, 685)
    StatusFrame:SetPoint("CENTER", UIParent, "CENTER")
    StatusFrame:SetFrameStrata("HIGH")
    StatusFrame:CreateBackdrop(BackdropFrame)
    StatusFrame:SetMovable(true)
    StatusFrame:Hide()

    --Title logo (drag to move frame)
    local titleLogoFrame = CreateFrame("Frame", nil, StatusFrame, "TitleDragAreaTemplate")
    titleLogoFrame:SetPoint("TOP", StatusFrame, "TOP")
    titleLogoFrame:SetSize(240, 150)
    StatusFrame.TitleLogoFrame = titleLogoFrame

    local titleTexture = StatusFrame.TitleLogoFrame:CreateTexture(nil, "ARTWORK")
    titleTexture:SetPoint("CENTER", titleLogoFrame, "CENTER")
    titleTexture:SetTexture("Interface/AddOns/GW2_UI/Textures/gwlogo")
    titleTexture:SetSize(128, 128)
    titleLogoFrame.Texture = titleTexture

    --Sections
    StatusFrame.Section1 = CreateSection(300, 150, StatusFrame, "TOP", StatusFrame, "TOP", -150)
    StatusFrame.Section2 = CreateSection(300, 150, StatusFrame, "TOP", StatusFrame.Section1, "BOTTOM", 0)
    StatusFrame.Section3 = CreateSection(300, 150, StatusFrame, "TOP", StatusFrame.Section2, "BOTTOM", 0)
    StatusFrame.Section4 = CreateSection(300, 60, StatusFrame, "TOP", StatusFrame.Section3, "BOTTOM", 0)

    --Section headers
    StatusFrame.Section1.Header.Text:SetText("|cffffedbaAddOn Info|r")
    StatusFrame.Section2.Header.Text:SetText("|cffffedbaWoW Info|r")
    StatusFrame.Section3.Header.Text:SetText("|cffffedbaCharacter Info|r")
    StatusFrame.Section4.Header.Text:SetText("|cffffedbaActions|r")

    --Section content
    StatusFrame.Section1.Content = CreateContentLines(5, StatusFrame.Section1, StatusFrame.Section1.Header)
    StatusFrame.Section2.Content = CreateContentLines(5, StatusFrame.Section2, StatusFrame.Section2.Header)
    StatusFrame.Section3.Content = CreateContentLines(5, StatusFrame.Section3, StatusFrame.Section3.Header)
    StatusFrame.Section4.Content = CreateFrame("Frame", nil, StatusFrame.Section4)
    StatusFrame.Section4.Content:SetSize(240, 25)
    StatusFrame.Section4.Content:SetPoint("TOP", StatusFrame.Section4.Header, "BOTTOM", 0, 0)

    --Content lines
    StatusFrame.Section1.Content.Line1.Text:SetFormattedText("GW2 UI version: |cff4beb2c%s|r", GW.VERSION_STRING)
    StatusFrame.Section1.Content.Line2.Text:SetFormattedText("Other AddOns Enabled: |cff4beb2c%s|r", AreOtherAddOnsEnabled())
    StatusFrame.Section1.Content.Line3.Text:SetFormattedText("Paste Addon Enabled: %s", isPasteAddon and "|cffff0000Yes|r" or "|cff4beb2cNo|r")
    StatusFrame.Section1.Content.Line4.Text:SetFormattedText("Recommended Scale: |cff4beb2c%s|r", GW.getBestPixelScale())
    StatusFrame.Section1.Content.Line5.Text:SetFormattedText("UI Scale Is: %s", GW.scale == GW.getBestPixelScale() and  format("|cff4beb2c%s|r", GW.scale) or format("|cffff0000%s|r", GW.scale))
    StatusFrame.Section2.Content.Line1.Text:SetFormattedText("WoW version: |cff4beb2c%s (build %s)|r", GW.wowpatch, GW.wowbuild) 
    StatusFrame.Section2.Content.Line2.Text:SetFormattedText("Client Language: |cff4beb2c%s|r", GetLocale())
    StatusFrame.Section2.Content.Line3.Text:SetFormattedText("Display Mode: |cff4beb2c%s|r", GetDisplayMode())
    StatusFrame.Section2.Content.Line4.Text:SetFormattedText("Resolution: |cff4beb2c%s|r", GW.resolution)
    StatusFrame.Section2.Content.Line5.Text:SetFormattedText("Using Mac Client: |cff4beb2c%s|r", (IsMacClient() == true and "Yes" or "No"))
    StatusFrame.Section3.Content.Line1.Text:SetFormattedText("Faction: |cff4beb2c%s|r", GW.myfaction)
    StatusFrame.Section3.Content.Line2.Text:SetFormattedText("Race: |cff4beb2c%s|r", GW.myrace)
    StatusFrame.Section3.Content.Line3.Text:SetFormattedText("Class: |cff4beb2c%s|r", EnglishClassName[GW.myclass])
    StatusFrame.Section3.Content.Line4.Text:SetFormattedText("Level: |cff4beb2c%s|r", GW.mylevel)
    StatusFrame.Section3.Content.Line5.Text:SetFormattedText("Zone: |cff4beb2c%s|r", GetRealZoneText())

    --Action button
    StatusFrame.Section4.Content.Button1 = CreateFrame("Button", nil, StatusFrame.Section4.Content, "GwStandardButton")
    StatusFrame.Section4.Content.Button1:SetSize(100, 25)
    StatusFrame.Section4.Content.Button1:SetPoint("LEFT", StatusFrame.Section4.Content, "LEFT")
    StatusFrame.Section4.Content.Button1:SetText(RELOADUI)
    StatusFrame.Section4.Content.Button1:SetScript("OnClick", function(self)
        C_UI.Reload()
    end)
    StatusFrame.Section4.Content.Button2 = CreateFrame("Button", nil, StatusFrame.Section4.Content, "GwStandardButton")
    StatusFrame.Section4.Content.Button2:SetSize(100, 25)
    StatusFrame.Section4.Content.Button2:SetPoint("RIGHT", StatusFrame.Section4.Content, "RIGHT")
    StatusFrame.Section4.Content.Button2:SetText(CLOSE)
    StatusFrame.Section4.Content.Button2:SetScript("OnClick", function(self)
        HideUIPanel(StatusFrame)
    end)

    tinsert(UISpecialFrames, "GWStatusFrame")

    return StatusFrame
end

local function UpdateDynamicValues()
    local StatusFrame = GW.StatusFrame

    local Section1 = StatusFrame.Section1
    Section1.Content.Line5.Text:SetFormattedText("UI Scale Is: %s", GW.scale == GW.getBestPixelScale() and  format("|cff4beb2c%s|r", GW.scale) or format("|cffff0000%s|r", GW.scale))

    local Section2 = StatusFrame.Section2
    Section2.Content.Line3.Text:SetFormattedText("Display Mode: |cff4beb2c%s|r", GetDisplayMode())
    Section2.Content.Line4.Text:SetFormattedText("Resolution: |cff4beb2c%s|r", GW.resolution)

    local Section3 = StatusFrame.Section3
    Section3.Content.Line4.Text:SetFormattedText("Level: |cff4beb2c%s|r", GW.mylevel)
    Section3.Content.Line5.Text:SetFormattedText("Zone: |cff4beb2c%s|r", GW.locationData.ZoneText)
end

local function ShowStatusReport()
    if not GW.StatusFrame then
        GW.StatusFrame = CreateStatusFrame()
    end

    if not GW.StatusFrame:IsShown() then
        UpdateDynamicValues()
        GW.StatusFrame:Raise()
        GW.StatusFrame:Show()
    else
        GW.StatusFrame:Hide()
    end
end
GW.ShowStatusReport = ShowStatusReport