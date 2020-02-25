local _, GW = ...
local addOption = GW.AddOption
local createCat = GW.CreateCat

local function LoadSkinsPanel(sWindow)
    local pnl_skins = CreateFrame("Frame", "GwSettingsGeneralSkinsOption", sWindow.panels, "GwSettingsPanelTmpl")
    pnl_skins.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_skins.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    pnl_skins.header:SetText("General Skins")
    pnl_skins.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_skins.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pnl_skins.sub:SetText("Enable or disable the skins you need and don't need.")

    createCat("General Skins", "Enable and disable general skins", "GwSettingsGeneralSkinsOption", 6)

    addOption("MainMenu", nil, "MAINMENU_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("Static Popup", nil, "STATICPOPUP_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("Battle.net Toast", nil, "BNTOASTFRAME_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("Ghost frame", nil, "GHOSTFRAME_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("Queuestatus frame", nil, "QUEUESTATUSFRAME_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("Deathrecap frame", nil, "DEATHRECAPFRAME_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("Drop-Down-List", nil, "DROPDOWNLIST_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("Drop-Down-Menu", nil, "DROPDOWNMENU_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("Gear Manager Dialog Popup", nil, "GEARMANAGERDIALOGPOPUP_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("LFG Dungeon Ready Status", nil, "LFGDUNGEONREADYSTATUS_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("LFG List Invite Dialog", nil, "LFGLISTINVITEDIALOG_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("LFG List Application Dialog", nil, "LFGLISTAPPLICATIONDIALOG_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("LFG Dungeon Ready Dialog", nil, "LFGDUNGEONREADYDIALOG_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("LFG Invite Popup", nil, "LFGINVITEPOPUP_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("Ready Check Listener Frame", nil, "READYCHECKLISTENERFRAME_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("Talking Head Frame", nil, "TALKINGHEAD_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
    addOption("Timer Tracker Frame", nil, "TIMERTRACKER_SKIN_ENABLED", "GwSettingsGeneralSkinsOption")
end
GW.LoadSkinsPanel = LoadSkinsPanel
