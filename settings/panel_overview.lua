local _, GW = ...
local L = GW.L
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling
local settingMenuToggle = GW.settingMenuToggle

local CreditsSection = {
    GW.Gw2Color .. L["Created by: "]:gsub(":", "")  .. "|r",
    GW.Gw2Color .. L["Developed by"] .. "|r",
    GW.Gw2Color .. L["With Contributions by"] .. "|r",
    GW.Gw2Color .. L["Localised by"] .. "|r",
    GW.Gw2Color .. L["QA Testing by"] .. "|r",
}

local OWNER = {
    "Aethelwulf"
}

local DEVELOPER = {
    "Glow",
    "Nezroy",
    "Shrugal",
    "Shoodox",
}

local CONTRIBUTION = {
    "Hatdragon"
}

local LOCALIZATION = {
    "aSlightDrizzle",
    "Calcifer",
    "Murak",
    "AxelVader",
    "Crisll",
    "Dololo",
    "Kitto",
    "Pyrefox",
    "RickCiotti",
    "Throli",
    "Zelrog",
}

local TESTING = {
    "Crohnleuchter",
    "KYZ",
    "Ultrachocobo",
    "Belazor",
    "Zerid"
}

local function SortList(a, b)
    return a < b
end

sort(OWNER, SortList)
sort(DEVELOPER, SortList)
sort(CONTRIBUTION, SortList)
sort(LOCALIZATION, SortList)
sort(TESTING, SortList)
for _, name in pairs(OWNER) do
    tinsert(GW.CreditsList, name)
end
for _, name in pairs(DEVELOPER) do
    tinsert(GW.CreditsList, name)
end
for _, name in pairs(CONTRIBUTION) do
    tinsert(GW.CreditsList, name)
end
for _, name in pairs(LOCALIZATION) do
    tinsert(GW.CreditsList, name)
end
for _, name in pairs(TESTING) do
    tinsert(GW.CreditsList, name)
end

--copied from character.lua needs to be removed later
local function CharacterMenuButton_OnLoad(self, odd)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
    end

    self:GetFontString():SetJustifyH("LEFT")
    self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
end

local welcome_OnClick = function(self)
    if self.settings then
        self.settings:Hide()
    end
    GW.ShowWelcomePanel()
    --Save current Version
    GW.private.GW2_UI_VERSION = GW.VERSION_STRING
end
AddForProfiling("panel_modules", "welcome_OnClick", welcome_OnClick)

local statusReport_OnClick = function(self)
    if self.settings then
        self.settings:Hide()
    end
    GW.ShowStatusReport()
end
AddForProfiling("panel_modules", "statusReport_OnClick", statusReport_OnClick)

local creditst_OnClick = function(self)
    if self.settings then
        self.settings:Hide()
    end
    GW.ShowCredits()
end
AddForProfiling("panel_modules", "creditst_OnClick", creditst_OnClick)

local function getChangeLogIcon(self, tag)
    if tonumber(tag) == GW.CHANGELOGS_TYPES.bug then
        self:SetTexCoord(0, 0.5, 0, 0.5)
    elseif tonumber(tag) == GW.CHANGELOGS_TYPES.feature then
        self:SetTexCoord(0.5, 1, 0, 0.5)
    else
        self:SetTexCoord(0, 0.5, 0.5, 1)
    end
end

local function ConvertChangeLogTableToOneTable()
    local table = {}
    local index = 1
    for i = 1, #GW.GW_CHANGELOGS do
        table[index] = "H-" .. GW.GW_CHANGELOGS[i].version
        index = index + 1
        for _, change in pairs(GW.GW_CHANGELOGS[i].changes) do
            table[index] = change[1] .. change[2]
            index = index + 1
        end
    end
    return table
end

local function ConvertCreditsTableToOneTable()
    local table = {}
    local index = 1
    for i = 1, #CreditsSection do
        table[index] = "H-" .. CreditsSection[i]
        index = index + 1

        local contentTable = i == 1 and OWNER or i == 2 and DEVELOPER or i == 3 and CONTRIBUTION or i == 4 and LOCALIZATION or TESTING
        for _, name in pairs(contentTable) do
            table[index] = name
            index = index + 1
        end
    end
    return table
end

local function UpdateScrollBox(self, type)
    local dataProvider = CreateDataProvider()

    if type == "changelog" then
        self:GetParent().header:SetText(L["Changelog"])

        for index, line in pairs( ConvertChangeLogTableToOneTable() ) do
            dataProvider:Insert({index = index, type = type, info = line})
        end
    elseif type == "credits" then
        self:GetParent().header:SetText(L["Credits"])

        for index, line in pairs( ConvertCreditsTableToOneTable() ) do
            dataProvider:Insert({index = index, type = type, info = line})
        end
    end

    self:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

local function ShowChangelog(frame)
    UpdateScrollBox(frame, "changelog")
    frame:GetParent().ScrollBar:ScrollToBegin();
end

local function ShowCredits(frame)
    UpdateScrollBox(frame, "credits")
    frame:GetParent().ScrollBar:ScrollToBegin();
end

local function InitButton(button, elementData)
    if not button.isSkinned then
        button.title.text:SetFont(DAMAGE_TEXT_FONT, 14)
        button.title.text:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

        button.content.text:SetFont(UNIT_NAME_FONT, 12)
        button.content.text:SetTextColor(181 / 255, 160 / 255, 128 / 255)
        GW.AddListItemChildHoverTexture(button)

        button.isSkinned = true
    end

    if string.sub(elementData.info, 1, 2) == "H-" then
        button.content:Hide()
        button.title.text:SetText(string.sub(elementData.info, 3))
        button.title:Show()
        elementData.isHeader = true
    else
        if elementData.type == "changelog" then
            button.content.text:SetText(string.sub(elementData.info, 2))
            button.content.text:SetPoint("TOPLEFT", 46, -10)
            getChangeLogIcon(button.content.icon, string.sub(elementData.info, 1, 1))
            button.content.icon:Show()
        elseif elementData.type == "credits" then
            button.content.text:SetText(elementData.info)
            button.content.text:SetPoint("TOPLEFT", 25, -13)
            button.content.icon:Hide()
        end

        button.title:Hide()
        button.content:Show()
        elementData.isHeader = false
    end
    elementData.neededHeight = elementData.isHeader and 36 or math.max(36, button.content.text:GetStringHeight() + 20)
    button:SetHeight(elementData.neededHeight)

    -- set zebra color by idx or watch status
    if (elementData.index % 2) == 1 then
        button.content.background:SetVertexColor(1, 1, 1, 1)
    else
        button.content.background:SetVertexColor(0, 0, 0, 0)
    end
end

local function LoadOverviewPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsSplashPanelTmpl")

    sWindow.splashart = p.splashart
    p.splashart:AddMaskTexture(sWindow.backgroundMask)

    CharacterMenuButton_OnLoad(p.menu.welcomebtn, true)
    CharacterMenuButton_OnLoad(p.menu.keybindingsbtn, false)
    CharacterMenuButton_OnLoad(p.menu.movehudbtn, true)
    CharacterMenuButton_OnLoad(p.menu.discordbtn, false)
    CharacterMenuButton_OnLoad(p.menu.reportbtn, true)
    CharacterMenuButton_OnLoad(p.menu.changelog, false)
    CharacterMenuButton_OnLoad(p.menu.creditsbtn, true)

    p.header:SetFont(DAMAGE_TEXT_FONT, 30)
    p.header:SetTextColor(1,1,1)
    p.header:ClearAllPoints()
    p.header:SetPoint("BOTTOMLEFT",p.pageblock,"TOPLEFT",20,10)

    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Enable or disable the modules you need and don't need."])
    p.sub:Hide()

    local fnGSWMH_OnClick = function()
        if InCombatLockdown() then
            GW.Notice(L["You can not move elements during combat!"])
            return
        end
        GW.moveHudObjects(GW.MoveHudScaleableFrame)
    end
    local fnGSWD_OnClick = function()
        StaticPopup_Show("JOIN_DISCORD")
    end
    local fmGSWKB_OnClick = function()
        sWindow:Hide()
        GW.DisplayHoverBinding()
    end
    GwSettingsWindowMoveHud = p.menu.movehudbtn

    p.menu.welcomebtn:SetParent(p)
    p.menu.welcomebtn.settings = sWindow
    p.menu.welcomebtn:SetText(L["Setup"])
    p.menu.welcomebtn:SetScript("OnClick", welcome_OnClick)

    p.menu.reportbtn:SetParent(p)
    p.menu.reportbtn.settings = sWindow
    p.menu.reportbtn:SetText(L["System info"])
    p.menu.reportbtn:SetScript("OnClick", statusReport_OnClick)

    p.menu.changelog:SetParent(p)
    p.menu.changelog.settings = sWindow
    p.menu.changelog:SetText(L["Changelog"])
    p.menu.changelog:SetScript("OnClick", function() ShowChangelog(p.ScrollBox) end)

    p.menu.creditsbtn:SetParent(p)
    p.menu.creditsbtn.settings = sWindow
    p.menu.creditsbtn:SetText(L["Credits"])
    p.menu.creditsbtn:SetScript("OnClick", function() ShowCredits(p.ScrollBox) end)

    p.menu.movehudbtn:SetText(L["Move HUD"])
    p.menu.movehudbtn:SetScript("OnClick", fnGSWMH_OnClick)
    p.menu.keybindingsbtn:SetText(KEY_BINDING)
    p.menu.keybindingsbtn:SetScript("OnClick", fmGSWKB_OnClick)
    p.menu.discordbtn:SetText(L["Join Discord"])
    p.menu.discordbtn:SetScript("OnClick", fnGSWD_OnClick)

    sWindow.headerString:SetFont(DAMAGE_TEXT_FONT, 24)
    sWindow.versionString:SetFont(UNIT_NAME_FONT, 12)
    sWindow.versionString:SetText(GW.VERSION_STRING)
    sWindow.headerString:SetText(CHAT_CONFIGURATION)

    sWindow.headerString:SetWidth(sWindow.headerString:GetStringWidth())
    sWindow.headerBreadcrumb:SetFont(DAMAGE_TEXT_FONT, 14)
    sWindow.headerBreadcrumb:SetText(CHAT_CONFIGURATION)

    createCat(L["Modules"], L["Enable and disable components"], p, nil, true, "Interface\\AddOns\\GW2_UI\\textures\\uistuff\\tabicon_overview")

    InitPanel(p, false)

    -- setup scrollframe
    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GwSettingsChangeLogCreditsTemplate", function(button, elementData)
        InitButton(button, elementData);
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(p.ScrollBox, p.ScrollBar, view)
    view:SetElementExtentCalculator(function(dataIndex, elementData)
        if elementData.isHeader ~= nil and elementData.isHeader == true then
            return 36
        else
            return elementData.neededHeight or 36
        end
    end)
    ScrollUtil.AddResizableChildrenBehavior(p.ScrollBox)
    GW.HandleTrimScrollBar(p.ScrollBar)
    GW.HandleScrollControls(p)
    p.ScrollBar:SetHideIfUnscrollable(true)

    UpdateScrollBox(p.ScrollBox, "changelog")

    p:SetScript("OnShow", function()
        settingMenuToggle(false)
        sWindow.headerString:SetWidth(sWindow.headerString:GetStringWidth())
        sWindow.headerBreadcrumb:SetText(OVERVIEW)
    end)

    GW.InitBeledarsSplashScreen(p)
end
GW.LoadOverviewPanel = LoadOverviewPanel
