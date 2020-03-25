local _, GW = ...
local addOption = GW.AddOption
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling

local function LoadSkinsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText("General Skins")
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText("Enable or disable the skins you need and don't need.")

    createCat("General Skins", "Enable and disable general skins", p, 6)

    addOption(p, "MainMenu", nil, "MAINMENU_SKIN_ENABLED")
    addOption(p, "Static Popup", nil, "STATICPOPUP_SKIN_ENABLED")
    addOption(p, SHOW_BATTLENET_TOASTS, nil, "BNTOASTFRAME_SKIN_ENABLED")
    addOption(p, "Ghost frame", nil, "GHOSTFRAME_SKIN_ENABLED")
    addOption(p, "Queuestatus frame", nil, "QUEUESTATUSFRAME_SKIN_ENABLED")
    addOption(p, DEATH_RECAP_TITLE, nil, "DEATHRECAPFRAME_SKIN_ENABLED")
    addOption(p, "Drop-Down-List", nil, "DROPDOWNLIST_SKIN_ENABLED")
    addOption(p, "Drop-Down-Menu", nil, "DROPDOWNMENU_SKIN_ENABLED")
    addOption(p, GEARSETS_TITLE, nil, "GEARMANAGERDIALOGPOPUP_SKIN_ENABLED")
    addOption(p, "LFG Dungeon Ready Status", nil, "LFGDUNGEONREADYSTATUS_SKIN_ENABLED")
    addOption(p, "LFG List Invite Dialog", nil, "LFGLISTINVITEDIALOG_SKIN_ENABLED")
    addOption(p, "LFG List Application Dialog", nil, "LFGLISTAPPLICATIONDIALOG_SKIN_ENABLED")
    addOption(p, "LFG Dungeon Ready Dialog", nil, "LFGDUNGEONREADYDIALOG_SKIN_ENABLED")
    addOption(p, "LFG Invite Popup", nil, "LFGINVITEPOPUP_SKIN_ENABLED")
    addOption(p, READY_CHECK, nil, "READYCHECKLISTENERFRAME_SKIN_ENABLED")
    addOption(p, "Talking Head Frame", nil, "TALKINGHEAD_SKIN_ENABLED")
    addOption(p, "Timer Tracker Frame", nil, "TIMERTRACKER_SKIN_ENABLED")
    addOption(p, "Immersion Addon", nil, "IMMERSIONADDON_SKIN_ENABLED")
    addOption(p, FLIGHT_MAP, nil, "FLIGHTMAP_SKIN_ENABLED")
    addOption(p, "Use Blizzard Class Colors", nil, "BLIZZARDCLASSCOLOR_ENABLED")
    addOption(p, ADDON_LIST, nil, "ADDONLIST_SKIN_ENABLED")
    addOption(p, SYSTEMOPTIONS_MENU, nil, "SETTINGS_SKIN_ENABLED")
    addOption(p, KEY_BINDINGS, nil, "BINDINGS_SKIN_ENABLED")
    addOption(p, UIOPTIONS_MENU, nil, "INTERFACE_SKIN_ENABLED")
    addOption(p, MACRO, nil, "MACRO_SKIN_ENABLED")
    
    InitPanel(p)
end
GW.LoadSkinsPanel = LoadSkinsPanel
