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
    p.header:SetText(L["Modules"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Enable or disable the modules you need and don't need."])

    p.welcome.settings = sWindow
    p.welcome:SetText(L["Welcome"])
    p.welcome:SetScript("OnClick", welcome_OnClick)

    p.statusReport.settings = sWindow
    p.statusReport:SetText(LANDING_PAGE_REPORT)
    p.statusReport:SetScript("OnClick", statusReport_OnClick)

    createCat(L["MODULES"], L["Enable and disable components"], p, 0)

    addOption(p, XPBAR_LABEL, nil, "XPBAR_ENABLED")
    addOption(p, L["Health Globe"], L["Enable the health bar replacement."], "HEALTHGLOBE_ENABLED")
    addOption(p, DISPLAY_POWER_BARS, L["Replace the default mana/power bar."], "POWERBAR_ENABLED")
    addOption(p, FOCUS, L["Enable the focus target frame replacement."], "FOCUS_ENABLED")
    addOption(p, TARGET, L["Enable the target frame replacement."], "TARGET_ENABLED")
    addOption(p, MINIMAP_LABEL, L["Use the GW2 UI Minimap frame."], "MINIMAP_ENABLED")
    addOption(p, OBJECTIVES_TRACKER_LABEL, L["Enable the revamped and improved quest tracker."], "QUESTTRACKER_ENABLED")
    addOption(p, L["Tooltips"], L["Replace the default UI tooltips."], "TOOLTIPS_ENABLED")
    addOption(p, COMMUNITIES_ADD_TO_CHAT_DROP_DOWN_TITLE, L["Enable the improved chat window."], "CHATFRAME_ENABLED")
    addOption(p, L["Immersive Questing"], L["Enable the immersive questing view."], "QUESTVIEW_ENABLED")
    addOption(p, BUFFOPTIONS_LABEL, L["Move and resize the player auras."], "PLAYER_BUFFS_ENABLED")
    addOption(p, BINDING_HEADER_ACTIONBAR, L["Use the GW2 UI improved action bars."], "ACTIONBARS_ENABLED")
    addOption(p, BINDING_NAME_TOGGLECHARACTER3, L["Use the GW2 UI improved Pet bar."], "PETBAR_ENABLED")
    addOption(p, INVENTORY_TOOLTIP, L["Enable the unified inventory interface."], "BAGS_ENABLED")
    addOption(p, L["Fonts"], L["Replace the default fonts withGw2 UI fonts."], "FONTS_ENABLED")
    addOption(p, SHOW_ENEMY_CAST, L["Enable the GW2 style casting bar."], "CASTINGBAR_ENABLED")
    addOption(p, L["Class Power"], L["Enable the alternate class powers."], "CLASS_POWER")
    addOption(p, RAID_FRAMES_LABEL, RAID_FRAMES_SUBTEXT, "RAID_FRAMES")
    addOption(p, L["Group Frames"], L["Replace the default UI group frames."], "PARTY_FRAMES")
    addOption(p, BINDING_NAME_TOGGLECHARACTER0, L["Replace the default character window."], "USE_CHARACTER_WINDOW")
    addOption(p, TALENTS_BUTTON, L["Enable the talents, specialization, and spellbook replacement."], "USE_TALENT_WINDOW")
    addOption(p, BATTLEGROUND, nil, "USE_BATTLEGROUND_HUD")
    addOption(p, CAMERA_FOLLOWING_STYLE .. ": " .. DYNAMIC, nil, "DYNAMIC_CAM")
    addOption(p, CHAT_BUBBLES_TEXT, L["Replace the default UI chat bubbles. (Only in not protected areas)"], "CHATBUBBLES_ENABLED")
    addOption(p, L["Alert Frames"], nil, "ALERTFRAME_ENABLED")

    InitPanel(p)
end
GW.LoadModulesPanel = LoadModulesPanel
