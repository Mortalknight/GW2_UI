local _, GW = ...

local L = GW.L

local CreditsSection = {
    GW.Gw2Color .. L["Created by: "]:gsub(":", "")  .. "|r",
    GW.Gw2Color .. L["Developed by"] .. "|r",
    GW.Gw2Color .. L["With Contributions by"] .. "|r",
    GW.Gw2Color .. L["Localised by"] .. "|r",
    GW.Gw2Color .. L["QA Testing by"] .. "|r",
}

local CREDITS = {
    OWNER = {"Aethelwulf"},
    DEVELOPER = {"Glow", "Nezroy", "Shrugal", "Shoodox"},
    CONTRIBUTION = {"Hatdragon"},
    LOCALIZATION = {"aSlightDrizzle", "Calcifer", "Murak", "AxelVader", "Crisll", "Dololo", "Kitto", "Pyrefox", "RickCiotti", "Throli", "Zelrog"},
    TESTING = {"Crohnleuchter", "KYZ", "Ultrachocobo", "Belazor", "Zerid"}
}

local function SortAndInsertCredits()
    local creditKeys = {"OWNER", "DEVELOPER", "CONTRIBUTION", "LOCALIZATION", "TESTING"}
    for _, key in ipairs(creditKeys) do
        local category = CREDITS[key]
        if category then
            sort(category)
            for _, name in pairs(category) do
                tinsert(GW.CreditsList, name)
            end
        end
    end
end

SortAndInsertCredits()
local welcome_OnClick = function()
    HideUIPanel(GwSettingsWindow)
    GW.ShowWelcomePanel()
end

local statusReport_OnClick = function()
    HideUIPanel(GwSettingsWindow)
    GW.ShowStatusReport()
end

local function getChangeLogIcon(self, tag)
    self:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/changelogicons.png")
    if tonumber(tag) == GW.ChangelogType.bug then
        self:SetTexCoord(0, 0.5, 0, 0.5)
    elseif tonumber(tag) == GW.ChangelogType.feature then
        self:SetTexCoord(0.5, 1, 0, 0.5)
    else
        self:SetTexCoord(0, 0.5, 0.5, 1)
    end
end
local function getCreditsIcon(self, type)
    self:SetTexCoord(0, 1, 0, 1)
    self:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/credits_" .. (type and type:lower() or "") .. ".png")
end

local function ConvertChangeLogTableToOneTable()
    local table = {}
    for _, line in pairs(GW.changelog) do
        tinsert(table, {name = "H-" .. line.version})
        for _, change in pairs(line.changes) do
            tinsert(table, {name = change[1] .. change[2]})
        end
    end

    return table
end

local function ConvertCreditsTableToOneTable()
    local table = {}
    local index = 1
    local creditKeys = {"OWNER", "DEVELOPER", "CONTRIBUTION", "LOCALIZATION", "TESTING"}

    for i = 1, #CreditsSection do
        table[index] = {name = "H-" .. CreditsSection[i]}
        index = index + 1

        local contentTable = CREDITS[creditKeys[i]] or {}
        for _, name in pairs(contentTable) do
            table[index] = {name = name, type = creditKeys[i]}
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
            dataProvider:Insert({index = index, type = type, name = line.name})
        end
    elseif type == "credits" then
        self:GetParent().header:SetText(L["Credits"])

        for index, line in pairs( ConvertCreditsTableToOneTable() ) do
            dataProvider:Insert({index = index, type = type, name = line.name, category = line.type})
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

    if string.sub(elementData.name, 1, 2) == "H-" then
        button.content:Hide()
        button.title.text:SetText(string.sub(elementData.name, 3))
        button.title:Show()
        elementData.isHeader = true
    else
        if elementData.type == "changelog" then
            button.content.text:SetText(string.sub(elementData.name, 2))
            getChangeLogIcon(button.content.icon, string.sub(elementData.name, 1, 1))
        elseif elementData.type == "credits" then
            button.content.text:SetText(elementData.name)
            getCreditsIcon(button.content.icon, elementData.category)
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
    container:AddTab("Interface/AddOns/GW2_UI/textures/uistuff/tabicon_overview.png", settingsOverview)

    settingsOverview.splashart:AddMaskTexture(container.backgroundMask)
    settingsOverview.splashart2:AddMaskTexture(container.backgroundMask)

    if GW.Retail then
        settingsOverview.splashart:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-retail.png")
        settingsOverview.splashart2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-retail-dark.png")
    elseif GW.Classic or GW.TBC then
        settingsOverview.splashart:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-classic.png")
        settingsOverview.splashart2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-classic.png")
    elseif GW.Mists then
        settingsOverview.splashart:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-cata.png")
        settingsOverview.splashart2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-cata.png")
    end

    local buttons = {
        {settingsOverview.menu.welcomebtn, L["Setup"], welcome_OnClick},
        {settingsOverview.menu.reportbtn, L["System info"], statusReport_OnClick},
        {settingsOverview.menu.changelog, L["Changelog"], function() ShowChangelog(settingsOverview.ScrollBox) end},
        {settingsOverview.menu.creditsbtn, L["Credits"], function() ShowCredits(settingsOverview.ScrollBox) end},
        {settingsOverview.menu.movehudbtn, L["Move HUD"], function()
            if InCombatLockdown() then
                GW.Notice(L["You can not move elements during combat!"])
                return
            end
            GW.moveHudObjects(GW.MoveHudScaleableFrame)
        end},
        {settingsOverview.menu.keybindingsbtn, KEY_BINDING, function() container:Hide() GW.DisplayHoverBinding() end},
        {settingsOverview.menu.discordbtn, L["Join Discord"], function()
            GW.ShowPopup({text = L["Join Discord"],
            hasEditBox = true,
            inputText = "https://discord.gg/MZZtRWt",
            EditBoxOnEscapePressed = function(popup) popup:Hide() end,
            hideOnEscape = true})
        end}
    }

    settingsOverview.header:SetFont(DAMAGE_TEXT_FONT, 30)

    local odd = true
    for _, button in ipairs(buttons) do
        GW.SettingsMenuButtonSetUp(button[1], odd)
        button[1]:SetText(button[2])
        button[1]:SetScript("OnClick", button[3])
        odd = not odd
    end

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
