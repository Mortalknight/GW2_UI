local _, GW = ...
local addOption = GW.AddOption
local createCat = GW.CreateCat

local function LoadModulesPanel(sWindow)
    local pnl_module = CreateFrame("Frame", "GwSettingsModuleOption", sWindow.panels, "GwSettingsPanelTmpl")
    pnl_module.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_module.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    pnl_module.header:SetText(GwLocalization["MODULES_CAT_1"])
    pnl_module.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_module.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pnl_module.sub:SetText(GwLocalization["MODULES_DESC"])
    
    createCat(GwLocalization["MODULES_CAT"], GwLocalization["MODULES_CAT_TOOLTIP"], "GwSettingsModuleOption", 0)
        
    addOption(
        XPBAR_LABEL,
        nil,
        "XPBAR_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        GwLocalization["HEALTH_GLOBE"],
        GwLocalization["HEALTH_GLOBE_DESC"],
        "HEALTHGLOBE_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        DISPLAY_POWER_BARS,
        GwLocalization["RESOURCE_DESC"],
        "POWERBAR_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        FOCUS,
        GwLocalization["FOCUS_FRAME_DESC"],
        "FOCUS_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        TARGET,
        GwLocalization["TARGET_FRAME_DESC"],
        "TARGET_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        MINIMAP_LABEL,
        GwLocalization["MINIMAP_DESC"],
        "MINIMAP_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        OBJECTIVES_TRACKER_LABEL,
        GwLocalization["QUEST_TRACKER_DESC"],
        "QUESTTRACKER_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        GwLocalization["TOOLTIPS"],
        GwLocalization["TOOLTIPS_DESC"],
        "TOOLTIPS_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        COMMUNITIES_ADD_TO_CHAT_DROP_DOWN_TITLE,
        GwLocalization["CHAT_FRAME_DESC"],
        "CHATFRAME_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        GwLocalization["QUESTING_FRAME"],
        GwLocalization["QUESTING_FRAME_DESC"],
        "QUESTVIEW_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        BUFFOPTIONS_LABEL,
        GwLocalization["PLAYER_AURAS_DESC"],
        "PLAYER_BUFFS_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        BINDING_HEADER_ACTIONBAR,
        GwLocalization["ACTION_BARS_DESC"],
        "ACTIONBARS_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        BINDING_NAME_TOGGLECHARACTER3,
        GwLocalization["PET_BAR_DESC"],
        "PETBAR_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        INVENTORY_TOOLTIP,
        GwLocalization["INVENTORY_FRAME_DESC"],
        "BAGS_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(GwLocalization["FONTS"],
        GwLocalization["FONTS_DESC"],
        "FONTS_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        SHOW_ENEMY_CAST,
        GwLocalization["CASTING_BAR_DESC"],
        "CASTINGBAR_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        GwLocalization["CLASS_POWER"],
        GwLocalization["CLASS_POWER_DESC"],
        "CLASS_POWER",
        "GwSettingsModuleOption"
    )
    addOption(
        GwLocalization["GROUP_FRAMES"],
        GwLocalization["GROUP_FRAMES_DESC"],
        "GROUP_FRAMES",
        "GwSettingsModuleOption"
    )
    addOption(
        BINDING_NAME_TOGGLECHARACTER0,
        GwLocalization["CHRACTER_WINDOW_DESC"],
        "USE_CHARACTER_WINDOW",
        "GwSettingsModuleOption"
    )
    addOption(
        TALENTS_BUTTON,
        GwLocalization["TALENTS_BUTTON_DESC"],
        "USE_TALENT_WINDOW",
        "GwSettingsModuleOption"
    )
    addOption(
        BATTLEGROUND,
        nil,
        "USE_BATTLEGROUND_HUD",
        "GwSettingsModuleOption"
    )
    addOption(
        CAMERA_FOLLOWING_STYLE .. ": " .. DYNAMIC,
        nil,
        "DYNAMIC_CAM",
        "GwSettingsModuleOption"
    )
end
GW.LoadModulesPanel = LoadModulesPanel
