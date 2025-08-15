local _, GW = ...

local L = GW.L
local AddForProfiling = GW.AddForProfiling

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
    self.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg")
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

local function LoadSettingsOverview(container)
    local settingsOverview = CreateFrame("Frame", nil, container, "GwSettingsOverviewTempl")

    settingsOverview.name = "GwSettingsOverview"
    settingsOverview.headerBreadcrumbText = OVERVIEW
    settingsOverview.hasSearch = false
    container:AddTab("Interface/AddOns/GW2_UI/textures/uistuff/tabicon_overview", settingsOverview)

    settingsOverview.splashart:AddMaskTexture(container.backgroundMask)
    settingsOverview.splashart2:AddMaskTexture(container.backgroundMask)

    if GW.Retail then
        settingsOverview.splashart:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-retail")
        settingsOverview.splashart2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-retail-dark")
    elseif GW.Classic then
        settingsOverview.splashart:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-classic")
        settingsOverview.splashart2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-classic")
    elseif GW.Mists then
        settingsOverview.splashart:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-cata")
        settingsOverview.splashart2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-cata")
    end

    CharacterMenuButton_OnLoad(settingsOverview.menu.welcomebtn, true)
    CharacterMenuButton_OnLoad(settingsOverview.menu.keybindingsbtn, false)
    CharacterMenuButton_OnLoad(settingsOverview.menu.movehudbtn, true)
    CharacterMenuButton_OnLoad(settingsOverview.menu.discordbtn, false)
    CharacterMenuButton_OnLoad(settingsOverview.menu.reportbtn, true)
    CharacterMenuButton_OnLoad(settingsOverview.menu.changelog, false)
    CharacterMenuButton_OnLoad(settingsOverview.menu.creditsbtn, true)

    settingsOverview.header:SetFont(DAMAGE_TEXT_FONT, 30)

    settingsOverview.menu.welcomebtn:SetText(L["Setup"])
    settingsOverview.menu.welcomebtn:SetScript("OnClick", welcome_OnClick)

    settingsOverview.menu.reportbtn:SetText(L["System info"])
    settingsOverview.menu.reportbtn:SetScript("OnClick", statusReport_OnClick)

    settingsOverview.menu.changelog:SetText(L["Changelog"])
    settingsOverview.menu.changelog:SetScript("OnClick", function() ShowChangelog(settingsOverview.ScrollBox) end)

    settingsOverview.menu.creditsbtn:SetText(L["Credits"])
    settingsOverview.menu.creditsbtn:SetScript("OnClick", function() ShowCredits(settingsOverview.ScrollBox) end)

    settingsOverview.menu.movehudbtn:SetText(L["Move HUD"])
    settingsOverview.menu.movehudbtn:SetScript("OnClick", function()
        if InCombatLockdown() then
            GW.Notice(L["You can not move elements during combat!"])
            return
        end
        GW.moveHudObjects(GW.MoveHudScaleableFrame)
    end)
    settingsOverview.menu.keybindingsbtn:SetText(KEY_BINDING)
    settingsOverview.menu.keybindingsbtn:SetScript("OnClick", function() container:Hide() GW.DisplayHoverBinding() end)
    settingsOverview.menu.discordbtn:SetText(L["Join Discord"])
    settingsOverview.menu.discordbtn:SetScript("OnClick", function()
        GW.ShowPopup({text = L["Join Discord"],
        hasEditBox = true,
        inputText = "https://discord.gg/MZZtRWt",
        EditBoxOnEscapePressed = function(popup) popup:Hide() end,
        hideOnEscape = true})
    end)

    -- setup scrollframe
    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GwSettingsChangeLogCreditsTemplate", function(button, elementData)
        InitButton(button, elementData);
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(settingsOverview.ScrollBox, settingsOverview.ScrollBar, view)
    view:SetElementExtentCalculator(function(dataIndex, elementData)
        if elementData.isHeader ~= nil and elementData.isHeader == true then
            return 36
        else
            return elementData.neededHeight or 36
        end
    end)
    ScrollUtil.AddResizableChildrenBehavior(settingsOverview.ScrollBox)
    GW.HandleTrimScrollBar(settingsOverview.ScrollBar)
    GW.HandleScrollControls(settingsOverview)
    settingsOverview.ScrollBar:SetHideIfUnscrollable(true)

    UpdateScrollBox(settingsOverview.ScrollBox, "changelog")

    if GW.Retail then
        GW.InitBeledarsSplashScreen(settingsOverview)
    end

    return settingsOverview
end
GW.LoadSettingsOverview = LoadSettingsOverview

