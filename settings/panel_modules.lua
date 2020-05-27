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
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(L["MODULES_CAT_1"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["MODULES_DESC"])

    p.welcome.settings = sWindow
    p.welcome:SetText(L["WELCOME"])
    p.welcome:SetScript("OnClick", welcome_OnClick)

    p.statusReport.settings = sWindow
    p.statusReport:SetText(LANDING_PAGE_REPORT)
    p.statusReport:SetScript("OnClick", statusReport_OnClick)

    createCat(L["MODULES_CAT"], L["MODULES_CAT_TOOLTIP"], p, 0)

    addOption(p, XPBAR_LABEL, nil, "XPBAR_ENABLED")
    addOption(p, L["HEALTH_GLOBE"], L["HEALTH_GLOBE_DESC"], "HEALTHGLOBE_ENABLED")
    addOption(p, DISPLAY_POWER_BARS, L["RESOURCE_DESC"], "POWERBAR_ENABLED")
    addOption(p, FOCUS, L["FOCUS_FRAME_DESC"], "FOCUS_ENABLED")
    addOption(p, TARGET, L["TARGET_FRAME_DESC"], "TARGET_ENABLED")
    addOption(p, MINIMAP_LABEL, L["MINIMAP_DESC"], "MINIMAP_ENABLED")
    addOption(p, OBJECTIVES_TRACKER_LABEL, L["QUEST_TRACKER_DESC"], "QUESTTRACKER_ENABLED")
    addOption(p, L["TOOLTIPS"], L["TOOLTIPS_DESC"], "TOOLTIPS_ENABLED")
    addOption(p, COMMUNITIES_ADD_TO_CHAT_DROP_DOWN_TITLE, L["CHAT_FRAME_DESC"], "CHATFRAME_ENABLED")
    addOption(p, L["QUESTING_FRAME"], L["QUESTING_FRAME_DESC"], "QUESTVIEW_ENABLED")
    addOption(p, BUFFOPTIONS_LABEL, L["PLAYER_AURAS_DESC"], "PLAYER_BUFFS_ENABLED")
    addOption(p, BINDING_HEADER_ACTIONBAR, L["ACTION_BARS_DESC"], "ACTIONBARS_ENABLED")
    addOption(p, BINDING_NAME_TOGGLECHARACTER3, L["PET_BAR_DESC"], "PETBAR_ENABLED")
    addOption(p, INVENTORY_TOOLTIP, L["INVENTORY_FRAME_DESC"], "BAGS_ENABLED")
    addOption(p, L["FONTS"], L["FONTS_DESC"], "FONTS_ENABLED")
    addOption(p, SHOW_ENEMY_CAST, L["CASTING_BAR_DESC"], "CASTINGBAR_ENABLED")
    addOption(p, L["CLASS_POWER"], L["CLASS_POWER_DESC"], "CLASS_POWER")
    addOption(p, L["GROUP_FRAMES"], L["GROUP_FRAMES_DESC"], "GROUP_FRAMES")
    addOption(p, BINDING_NAME_TOGGLECHARACTER0, L["CHRACTER_WINDOW_DESC"], "USE_CHARACTER_WINDOW")
    addOption(p, TALENTS_BUTTON, L["TALENTS_BUTTON_DESC"], "USE_TALENT_WINDOW")
    addOption(p, BATTLEGROUND, nil, "USE_BATTLEGROUND_HUD")
    addOption(p, CAMERA_FOLLOWING_STYLE .. ": " .. DYNAMIC, nil, "DYNAMIC_CAM")
    addOption(p, CHAT_BUBBLES_TEXT, L["CHAT_BUBBLES_DESC"], "CHATBUBBLES_ENABLED")

    InitPanel(p)
end
GW.LoadModulesPanel = LoadModulesPanel
