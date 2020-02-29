local _, GW = ...
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local L = GwLocalization
local AddForProfiling = GW.AddForProfiling

local wpanel

local function settings_OnClick(self, button)
    local t = self.target
    self:GetParent():Hide()
    t:Show()
    UIFrameFadeIn(t, 0.2, 0, 1)
end
AddForProfiling("welcome", "settings_OnClick", settings_OnClick)

local function toggle_OnClick(self, button)
    if self:GetText() == L["CHANGELOG"] then
        self:GetParent().welcome:Hide()
        self:GetParent().changelog:Show()
        self:SetText(L["WELCOME"])
    else
        self:GetParent().changelog:Hide()
        self:GetParent().welcome:Show()
        self:SetText(L["CHANGELOG"])
    end
end
AddForProfiling("welcome", "toggle_OnClick", toggle_OnClick)

local function movehud_OnClick(self, button)
    if InCombatLockdown() then
        DEFAULT_CHAT_FRAME:AddMessage(L["HUD_MOVE_ERR"])
        return
    end
    self:GetParent():Hide()
    GW.moveHudObjects()
end
AddForProfiling("welcome", "movehud_OnClick", movehud_OnClick)

local function pixel_OnClick(self)
    if self:GetText() == L["PIXEL_PERFECTION_ON"] then
        GW.PixelPerfection()
        SetSetting("PIXEL_PERFECTION", true)
        self:SetText(L["PIXEL_PERFECTION_OFF"])
    else
        SetCVar("useUiScale", true)
        SetCVar("useUiScale", false)
        SetSetting("PIXEL_PERFECTION", false)
        self:SetText(L["PIXEL_PERFECTION_ON"])
    end
end
AddForProfiling("welcome", "pixel_OnClick", pixel_OnClick)

local function createPanel()
    wpanel = CreateFrame("Frame", nil, UIParent, "GwWelcomePageTmpl")
    wpanel.changelog.scroll:SetScrollChild(wpanel.changelog.scroll.scrollchild)
    wpanel.changelog.scroll.scrollchild:SetSize(wpanel.changelog.scroll:GetSize())
    wpanel.changelog.scroll.scrollchild:SetWidth(wpanel.changelog.scroll:GetWidth() - 20)

    wpanel.header:SetFont(DAMAGE_TEXT_FONT,30,"OUTLINE")
    wpanel.header:SetTextColor(1,0.95,0.8,1)

    wpanel.subHeader:SetFont(DAMAGE_TEXT_FONT,16,"OUTLINE")
    wpanel.subHeader:SetTextColor(0.9,0.85,0.7,1)

    wpanel.changelog.header:SetFont(DAMAGE_TEXT_FONT,14)
    wpanel.changelog.header:SetTextColor(0.8,0.75,0.6,1)

    wpanel.changelog.scroll.scrollchild.text:SetFont(DAMAGE_TEXT_FONT,14)
    wpanel.changelog.scroll.scrollchild.text:SetTextColor(0.8,0.75,0.6,1)

    wpanel.welcome.header:SetFont(DAMAGE_TEXT_FONT,14)
    wpanel.welcome.header:SetTextColor(0.8,0.75,0.6,1)

    wpanel.header:SetText(L["WELCOME_SPLASH_HEADER"])
    wpanel.welcome.header:SetText(L["WELCOME_SPLASH_WELCOME_TEXT"] .. "\n\n\n" .. L["WELCOME_SPLASH_WELCOME_TEXT_PP"])

    wpanel.close:SetText(CLOSE)
    wpanel.movehud:SetText(L["MOVE_HUD_BUTTON"])
    wpanel.settings:SetText(CHAT_CONFIGURATION)
    wpanel.welcome.pixelbutton:SetText(L["PIXEL_PERFECTION_ON"])

    wpanel.changelog.header:SetText(L["CHANGELOG"])

    wpanel.subHeader:SetText(GW.VERSION_STRING)
    wpanel.changelog.scroll.scrollchild.text:SetText(GW.GW_CHANGELOGS)
    wpanel.changelog.scroll.slider:SetMinMaxValues(0, wpanel.changelog.scroll.scrollchild.text:GetStringHeight())
    wpanel.changelog.scroll.slider.thumb:SetHeight(100)
    wpanel.changelog.scroll.slider:SetValue(1)
    wpanel.changelogORwelcome:SetText(L["CHANGELOG"])
    if GetSetting("PIXEL_PERFECTION") then
        wpanel.welcome.pixelbutton:SetText(L["PIXEL_PERFECTION_OFF"])
    end

    -- settings button
    wpanel.settings.target = GwSettingsWindow
    wpanel.settings:SetScript("OnClick", settings_OnClick)

    -- changelog/welcome toggle button
    wpanel.changelogORwelcome:SetScript("OnClick", toggle_OnClick)

    -- move HUD Button
    wpanel.movehud:SetScript("OnClick", movehud_OnClick)

    -- pixel perfect toggle
    wpanel.welcome.pixelbutton:SetScript("OnClick", pixel_OnClick)

    -- pixel perfect toggle
    wpanel.close:SetScript("OnClick", GW.Parent_Hide)
end
AddForProfiling("welcome", "createPanel", createPanel)

local function ShowWelcomePanel()
    if not wpanel then
        createPanel()
    end

    wpanel.changelogORwelcome:SetText(L["CHANGELOG"])
    wpanel.changelog:Hide()
    wpanel.welcome:Show()
    wpanel:Show()
end
GW.ShowWelcomePanel = ShowWelcomePanel

local function ShowChangelogPanel()
    if not wpanel then
        createPanel()
    end

    wpanel.changelogORwelcome:SetText(L["WELCOME"])
    wpanel.welcome:Hide()
    wpanel.changelog:Show()
    wpanel:Show()
end
GW.ShowChangelogPanel = ShowChangelogPanel
