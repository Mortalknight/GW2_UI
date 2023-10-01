local _, GW = ...
local L = GW.L
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local SetSetting = GW.SetSetting
local AddForProfiling = GW.AddForProfiling
local settingMenuToggle = GW.settingMenuToggle

local changelogTitelRows = {}
local changelogRows = {}
local addedFrames = {}

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
    SetSetting("GW2_UI_VERSION", GW.VERSION_STRING)
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

local function getChangeLogIcon(self,tag)

  if tag==GW.CHANGELOGS_TYPES.bug then
    self:SetTexCoord(0,0.5,0,0.5)
    return
  elseif tag==GW.CHANGELOGS_TYPES.feature then
    self:SetTexCoord(0.5,1,0,0.5)
    return
  end
  self:SetTexCoord(0,0.5,0.5,1)
end

local function GetTitleRow(idx, frame)
    if changelogTitelRows[idx] then
        changelogTitelRows[idx]:Show()
        return changelogTitelRows[idx]
    else
        local changelogtitle = CreateFrame("Frame", nil, frame.scroll.scrollchild, "GWChangelogVersionRow")
        tinsert(changelogTitelRows, changelogtitle)
        return changelogtitle
    end
end

local function GetContentRow(idx, frame)
    if changelogRows[idx] then
        changelogRows[idx]:Show()
        return changelogRows[idx]
    else
        local entry = CreateFrame("Frame", nil, frame.scroll.scrollchild, "GWChangelogRow")
        tinsert(changelogRows, entry)
        return entry
    end
end

local function SetScrollFrameSize(frame, size)
    local scrollMax = max(0, size - frame.scroll:GetHeight() + 50)

    frame.scroll.scrollchild:SetHeight(frame.scroll:GetHeight())
    frame.scroll.scrollchild:SetWidth(frame.scroll:GetWidth() - 20)
    frame.scroll.slider:SetMinMaxValues(0, scrollMax)
    --Calculate how big the thumb is this is IMPORTANT for UX :<
    frame.scroll.slider.thumb:SetHeight(frame.scroll.slider:GetHeight() * (frame.scroll:GetHeight() / (scrollMax + frame.scroll:GetHeight())) )

    frame.scroll.slider:SetValue(1)
    frame.scroll.maxScroll = scrollMax
end

local function ResetFrame(frame)
    for _, v in pairs(addedFrames) do
        v:ClearAllPoints()
        v:Hide()
    end

    wipe(addedFrames)

    SetScrollFrameSize(frame, 0)
end

local function ShowChangelog(frame)
    ResetFrame(frame)

    frame.header:SetText(L["Changelog"])
    local zebra
    local index = 1
    local margin = 0
    local size = 0
    local previousElement = nil
    local rowKey = 1

    for i = 1, #GW.GW_CHANGELOGS do
        local versionNumber = GW.GW_CHANGELOGS[i].version
        local changes = GW.GW_CHANGELOGS[i].changes

        local changelogtitle = GetTitleRow(i, frame)
        if not previousElement then
            changelogtitle:SetPoint("TOPLEFT", frame.scroll.scrollchild, "TOPLEFT", 0, -margin)
        else
            changelogtitle:SetPoint("TOPLEFT", previousElement, "BOTTOMLEFT", 0, 0)
        end
        tinsert(addedFrames, changelogtitle)
        zebra = index % 2
        changelogtitle.background:SetShown(zebra == 1)

        changelogtitle.text:SetFont(DAMAGE_TEXT_FONT, 14)
        changelogtitle.text:SetTextColor(255 / 255, 241 / 255, 209 / 255)
        changelogtitle.text:SetText(versionNumber)
        previousElement = changelogtitle
        index = index + 1
        size = size + changelogtitle:GetHeight()

        for _, change in pairs(changes) do
            local iconTag = change[1]
            local text = change[2]
            zebra = index % 2
            local entry = GetContentRow(rowKey, frame)
            tinsert(addedFrames, entry)
            entry:SetPoint("TOPLEFT", previousElement, "BOTTOMLEFT",0,0)
            entry.text:SetFont(UNIT_NAME_FONT, 12)
            entry.text:SetTextColor(181 / 255, 160 / 255, 128 / 255)
            entry.text:SetText(text)
            getChangeLogIcon(entry.icon, iconTag)
            entry.icon:Show()
            entry:SetHeight(math.max(36, entry.text:GetStringHeight() + 20))

            entry.background:SetShown(zebra == 1)

            previousElement = entry
            index = index + 1
            size = size + entry:GetHeight()
            rowKey = rowKey + 1
        end
    end

    SetScrollFrameSize(frame, size)
end

local function ShowCredits(frame)
    ResetFrame(frame)

    frame.header:SetText(L["Credits"])
    local zebra
    local index = 1
    local margin = 0
    local size = 0
    local previousElement = nil
    local rowKey = 1

    for k, v in pairs(CreditsSection) do
        local row = GetTitleRow(k, frame)

        if not previousElement then
            row:SetPoint("TOPLEFT", frame.scroll.scrollchild, "TOPLEFT", 0, -margin)
        else
            row:SetPoint("TOPLEFT", previousElement, "BOTTOMLEFT", 0, 0)
        end
        tinsert(addedFrames, row)
        zebra = index % 2
        row.background:SetShown(zebra == 1)

        row.text:SetFont(DAMAGE_TEXT_FONT, 14)
        row.text:SetTextColor(255 / 255, 241 / 255, 209 / 255)
        row.text:SetText(v)
        previousElement = row
        index = index + 1
        size = size + row:GetHeight()
        local contentTable = k == 1 and OWNER or k == 2 and DEVELOPER or k == 3 and CONTRIBUTION or k == 4 and LOCALIZATION or TESTING

        for _, name in pairs(contentTable) do
            zebra = index % 2

            local entry = GetContentRow(rowKey, frame)
            tinsert(addedFrames, entry)
            entry:SetPoint("TOPLEFT", previousElement, "BOTTOMLEFT", 0, 0)
            entry.text:SetFont(UNIT_NAME_FONT, 12)
            entry.text:SetTextColor(181 / 255, 160 / 255, 128 / 255)
            entry.text:SetText(name)
            entry:SetHeight(math.max(36, entry.text:GetStringHeight() + 20))
            entry.icon:Hide()

            entry.background:SetShown(zebra == 1)

            previousElement = entry
            index = index + 1
            size = size + entry:GetHeight()
            rowKey = rowKey + 1
        end
    end
    SetScrollFrameSize(frame, size)
end

local function LoadOverviewPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsSplashPanelTmpl")

    p.splashart:AddMaskTexture(sWindow.backgroundMask)

    CharacterMenuButton_OnLoad(p.menu.welcomebtn,true)
    CharacterMenuButton_OnLoad(p.menu.keybindingsbtn,false)
    CharacterMenuButton_OnLoad(p.menu.movehudbtn,true)
    CharacterMenuButton_OnLoad(p.menu.discordbtn,false)
    CharacterMenuButton_OnLoad(p.menu.reportbtn,true)
    CharacterMenuButton_OnLoad(p.menu.changelog,true)
    CharacterMenuButton_OnLoad(p.menu.creditsbtn,false)

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
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["You can not move elements during combat!"]):gsub("*", GW.Gw2Color))
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
    p.menu.changelog:SetScript("OnClick", function() ShowChangelog(p) end)

    p.menu.creditsbtn:SetParent(p)
    p.menu.creditsbtn.settings = sWindow
    p.menu.creditsbtn:SetText(L["Credits"])
    p.menu.creditsbtn:SetScript("OnClick", function() ShowCredits(p) end)

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

    createCat(L["Modules"], L["Enable and disable components"], p, {p}, true, "Interface\\AddOns\\GW2_UI\\textures\\uistuff\\tabicon_overview")

    InitPanel(p, false)
    p.scroll:SetScrollChild(p.scroll.scrollchild)

    p:SetScript("OnShow", function()
        settingMenuToggle(false)
        sWindow.headerString:SetWidth(sWindow.headerString:GetStringWidth())
        sWindow.headerBreadcrumb:SetText(OVERVIEW)
    end)

    ShowChangelog(p)
end
GW.LoadOverviewPanel = LoadOverviewPanel
