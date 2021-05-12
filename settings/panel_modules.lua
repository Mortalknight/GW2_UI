local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local SetSetting = GW.SetSetting
local AddForProfiling = GW.AddForProfiling

local welcome_OnClick = function(self, button)
    if self.settings then
        self.settings:Hide()
    end
    GW.ShowWelcomePanel()
    --Save current Version
    SetSetting("GW2_UI_VERSION", GW.VERSION_STRING)
end
AddForProfiling("panel_modules", "welcome_OnClick", welcome_OnClick)

local statusReport_OnClick = function(self, button)
    if self.settings then
        self.settings:Hide()
    end
    GW.ShowStatusReport()
end
AddForProfiling("panel_modules", "statusReport_OnClick", statusReport_OnClick)

local function LoadModulesPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsModulePanelTmpl")
    p.scroll.scrollchild.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.scroll.scrollchild.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.scroll.scrollchild.header:SetText(L["Modules"])
    p.scroll.scrollchild.sub:SetFont(UNIT_NAME_FONT, 12)
    p.scroll.scrollchild.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.scroll.scrollchild.sub:SetText(L["Enable or disable the modules you need and don't need."])

    p.welcome:SetParent(p.scroll.scrollchild)
    p.welcome.settings = sWindow
    p.welcome:SetText(L["Welcome"])
    p.welcome:SetScript("OnClick", welcome_OnClick)

    p.statusReport:SetParent(p.scroll.scrollchild)
    p.statusReport.settings = sWindow
    p.statusReport:SetText(LANDING_PAGE_REPORT)
    p.statusReport:SetScript("OnClick", statusReport_OnClick)

    createCat(L["Modules"], L["Enable and disable components"], p, 0, nil, {p})

    addOption(p.scroll.scrollchild, XPBAR_LABEL, nil, "XPBAR_ENABLED")
    addOption(p.scroll.scrollchild, L["HEALTH_GLOBE"], L["HEALTH_GLOBE_DESC"], "HEALTHGLOBE_ENABLED")
    addOption(p.scroll.scrollchild, DISPLAY_POWER_BARS, L["RESOURCE_DESC"], "POWERBAR_ENABLED")
    addOption(p.scroll.scrollchild, TARGET, L["TARGET_FRAME_DESC"], "TARGET_ENABLED")
    addOption(p.scroll.scrollchild, MINIMAP_LABEL, L["MINIMAP_DESC"], "MINIMAP_ENABLED")
    addOption(p.scroll.scrollchild, OBJECTIVES_TRACKER_LABEL, L["QUEST_TRACKER_DESC"], "QUESTTRACKER_ENABLED")
    addOption(p.scroll.scrollchild, L["TOOLTIPS"], L["TOOLTIPS_DESC"], "TOOLTIPS_ENABLED")
    addOption(p.scroll.scrollchild, COMMUNITIES_ADD_TO_CHAT_DROP_DOWN_TITLE, L["CHAT_FRAME_DESC"], "CHATFRAME_ENABLED")
    addOption(p.scroll.scrollchild, L["QUESTING_FRAME"], L["QUESTING_FRAME_DESC"], "QUESTVIEW_ENABLED")
    addOption(p.scroll.scrollchild, BUFFOPTIONS_LABEL, L["PLAYER_AURAS_DESC"], "PLAYER_BUFFS_ENABLED")
    addOption(p.scroll.scrollchild, BINDING_HEADER_ACTIONBAR, L["ACTION_BARS_DESC"], "ACTIONBARS_ENABLED")
    addOption(p.scroll.scrollchild, BINDING_NAME_TOGGLECHARACTER3, L["PET_BAR_DESC"], "PETBAR_ENABLED")
    addOption(p.scroll.scrollchild, INVENTORY_TOOLTIP, L["INVENTORY_FRAME_DESC"], "BAGS_ENABLED")
    addOption(p.scroll.scrollchild, L["FONTS"], L["FONTS_DESC"], "FONTS_ENABLED")
    addOption(p.scroll.scrollchild, SHOW_ENEMY_CAST, L["CASTING_BAR_DESC"], "CASTINGBAR_ENABLED")
    addOption(p.scroll.scrollchild, L["CLASS_POWER"], L["CLASS_POWER_DESC"], "CLASS_POWER")
    addOption(p.scroll.scrollchild, RAID_FRAMES_LABEL, RAID_FRAMES_SUBTEXT, "RAID_FRAMES")
    addOption(p.scroll.scrollchild, L["GROUP_FRAMES"], L["GROUP_FRAMES_DESC"], "PARTY_FRAMES")
    addOption(p.scroll.scrollchild, BINDING_NAME_TOGGLECHARACTER0, L["CHRACTER_WINDOW_DESC"], "USE_CHARACTER_WINDOW")
    addOption(p.scroll.scrollchild, TALENTS, L["TALENTS_BUTTON_DESC"], "USE_TALENT_WINDOW")
    addOption(p.scroll.scrollchild, SPELLBOOK_ABILITIES_BUTTON, SPELLBOOK_ABILITIES_BUTTON, "USE_SPELLBOOK_WINDOW")
    addOption(p.scroll.scrollchild, CAMERA_FOLLOWING_STYLE .. ": " .. DYNAMIC, nil, "DYNAMIC_CAM")
    addOption(p.scroll.scrollchild, CHAT_BUBBLES_TEXT, L["CHAT_BUBBLES_DESC"], "CHATBUBBLES_ENABLED")

    InitPanel(p, true)
end
GW.LoadModulesPanel = LoadModulesPanel
