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
    self:GetFontString():SetTextColor(255 / 255, 241 / 255, 209 / 255)
    self:GetFontString():SetShadowColor(0, 0, 0, 0)
    self:GetFontString():SetShadowOffset(1, -1)
    self:GetFontString():SetFont(DAMAGE_TEXT_FONT, 14)
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
        table[index] = "H" .. GW.GW_CHANGELOGS[i].version
        index = index + 1
        for _, change in pairs(GW.GW_CHANGELOGS[i].changes) do
            table[index] = change[1] .. change[2]
            index = index + 1
        end
    end
    return table
end

local function ShowChangelog(frame)
    frame.update = ShowChangelog
    frame:GetParent().header:SetText(L["Changelog"])

    local USED_CHANGELOG_HEIGHT = 0
    local extraSpace = 0
    local zebra

    local offset = HybridScrollFrame_GetOffset(frame)
    local changelogCombiendTable = ConvertChangeLogTableToOneTable()
    local numberOfRows = #changelogCombiendTable

    for i = 1, #frame.buttons do
        local slot = frame.buttons[i]
        local idx = i + offset
        if idx > numberOfRows then
            -- empty row (blank starter row, final row, and any empty entries)
            slot.content:Hide()
            slot.title:Hide()
        else
            local line = changelogCombiendTable[idx]

            if string.sub(line, 1, 1) == "H" then
                slot.content:Hide()
                slot.title.text:SetText(string.sub(line, 2))
                slot.title:Show()
                slot:SetHeight(36)

                zebra = idx % 2
                slot.title.background:SetShown(zebra == 1)
            else
                slot.title:Hide()
                slot.content.text:SetText(string.sub(line, 2))
                slot.content.text:SetPoint("TOPLEFT", 46, -10)
                getChangeLogIcon(slot.content.icon, string.sub(line, 1, 1))
                slot.content.icon:Show()
                -- set zebra color by idx or watch status
                zebra = idx % 2
                slot.content.background:SetShown(zebra == 1)
                slot:SetHeight(math.max(36, slot.content.text:GetStringHeight() + 20))

                extraSpace = extraSpace + slot:GetHeight()
                slot.content:Show()
            end
            slot:Show()
        end
    end

    USED_CHANGELOG_HEIGHT = 36 * numberOfRows + (extraSpace)
    HybridScrollFrame_Update(frame, USED_CHANGELOG_HEIGHT, 390)
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

local function ShowCredits(frame)
    frame.update = ShowCredits
    frame:GetParent().header:SetText(L["Credits"])

    local USED_CREDITS_HEIGHT = 0
    local zebra

    local offset = HybridScrollFrame_GetOffset(frame)
    local creditsCombiendTable = ConvertCreditsTableToOneTable()
    local numberOfRows = #creditsCombiendTable

    for i = 1, #frame.buttons do
        local slot = frame.buttons[i]
        local idx = i + offset
        if idx > numberOfRows then
            -- empty row (blank starter row, final row, and any empty entries)
            slot.content:Hide()
            slot.title:Hide()
        else
            local line = creditsCombiendTable[idx]

            if string.sub(line, 1, 2) == "H-" then
                slot.content:Hide()
                slot.title.text:SetText(string.sub(line, 3))
                slot.title:Show()
                slot:SetHeight(36)

                zebra = idx % 2
                slot.title.background:SetShown(zebra == 1)
            else
                slot.title:Hide()
                slot.content.text:SetText(line)
                slot.content.text:SetPoint("TOPLEFT", 25, -13)
                slot.content.icon:Hide()
                -- set zebra color by idx or watch status
                zebra = idx % 2
                slot.content.background:SetShown(zebra == 1)
                slot:SetHeight(36)

                slot.content:Show()
            end
            slot:Show()
        end
    end

    USED_CREDITS_HEIGHT = 36 * numberOfRows
    HybridScrollFrame_Update(frame, USED_CREDITS_HEIGHT, 390)
end

local function SetUpScrollFrame(frame)
    HybridScrollFrame_CreateButtons(frame, "GWSettingsPanelRow", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #frame.buttons do
        local slot = frame.buttons[i]
        slot:SetWidth(frame:GetWidth() - 12)
        slot.title.text:SetFont(DAMAGE_TEXT_FONT, 14)
        slot.title.text:SetTextColor(255 / 255, 241 / 255, 209 / 255)

        slot.content.text:SetFont(UNIT_NAME_FONT, 12)
        slot.content.text:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    end
end

local function LoadOverviewPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsSplashPanelTmpl")

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
    p.menu.changelog:SetScript("OnClick", function() ShowChangelog(p.scroll) end)

    p.menu.creditsbtn:SetParent(p)
    p.menu.creditsbtn.settings = sWindow
    p.menu.creditsbtn:SetText(L["Credits"])
    p.menu.creditsbtn:SetScript("OnClick", function() ShowCredits(p.scroll) end)

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
    local scroll = p.scroll
    scroll.scrollBar.doNotHide = true

    SetUpScrollFrame(scroll)

    p:SetScript("OnShow", function()
        settingMenuToggle(false)
        sWindow.headerString:SetWidth(sWindow.headerString:GetStringWidth())
        sWindow.headerBreadcrumb:SetText(OVERVIEW)
    end)

    ShowChangelog(scroll)
end
GW.LoadOverviewPanel = LoadOverviewPanel
