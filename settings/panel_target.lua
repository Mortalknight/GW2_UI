local _, GW = ...
local addOption = GW.AddOption
local createCat = GW.CreateCat

local function LoadTargetPanel(sWindow)
    local pnl_tarfoc = CreateFrame("Frame", "GwSettingsTargetFocus", sWindow.panels, "GwSettingsPanelTmpl")
    pnl_tarfoc.header:Hide()
    pnl_tarfoc.sub:Hide()

    local pnl_target = CreateFrame("Frame", "GwSettingsTargetOptions", pnl_tarfoc, "GwSettingsPanelTmpl")
    pnl_target:SetHeight(300)
    pnl_target.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_target.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    pnl_target.header:SetText(TARGET)
    pnl_target.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_target.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pnl_target.sub:SetText(GwLocalization["TARGET_DESC"])

    local pnl_focus = CreateFrame("Frame", "GwSettingsFocusOptions", pnl_tarfoc, "GwSettingsPanelTmpl")
    pnl_focus:SetHeight(300)
    pnl_focus:ClearAllPoints()
    pnl_focus:SetPoint("TOPLEFT", pnl_target, "BOTTOMLEFT", 0, 0)
    pnl_focus.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_focus.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    pnl_focus.header:SetText(FOCUS)
    pnl_focus.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_focus.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pnl_focus.sub:SetText(GwLocalization["FOCUS_DESC"])

    createCat(TARGET, GwLocalization["TARGET_TOOLTIP"], "GwSettingsTargetFocus", 1)

    addOption(
        SHOW_TARGET_OF_TARGET_TEXT,
        GwLocalization["TARGET_OF_TARGET_DESC"],
        "target_TARGET_ENABLED",
        "GwSettingsTargetOptions"
    )
    addOption(
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        GwLocalization["HEALTH_VALUE_DESC"],
        "target_HEALTH_VALUE_ENABLED",
        "GwSettingsTargetOptions"
    )
    addOption(
        RAID_HEALTH_TEXT_PERC,
        GwLocalization["HEALTH_PERCENTAGE_DESC"],
        "target_HEALTH_VALUE_TYPE",
        "GwSettingsTargetOptions"
    )
    addOption(
        CLASS_COLORS,
        GwLocalization["CLASS_COLOR_DESC"],
        "target_CLASS_COLOR",
        "GwSettingsTargetOptions"
    )
    addOption(
        SHOW_DEBUFFS,
        GwLocalization["SHOW_DEBUFFS_DESC"],
        "target_DEBUFFS",
        "GwSettingsTargetOptions"
    )
    addOption(
        SHOW_ALL_ENEMY_DEBUFFS_TEXT,
        GwLocalization["SHOW_ALL_DEBUFFS_DESC"],
        "target_BUFFS_FILTER_ALL",
        "GwSettingsTargetOptions"
    )
    addOption(
        SHOW_BUFFS,
        GwLocalization["SHOW_BUFFS_DESC"],
        "target_BUFFS",
        "GwSettingsTargetOptions"
    )
    addOption(
        GwLocalization["SHOW_ILVL"],
        GwLocalization["SHOW_ILVL_DESC"],
        "target_SHOW_ILVL",
        "GwSettingsTargetOptions"
    )
    addOption(
        GwLocalization["SHOW_THREAT_VALUE"],
        GwLocalization["SHOW_THREAT_VALUE"],
        "target_THREAT_VALUE_ENABLED",
        "GwSettingsTargetOptions"
    )
    addOption(
        GwLocalization["TARGET_COMBOPOINTS"],
        GwLocalization["TARGET_COMBOPOINTS_DEC"],
        "target_HOOK_COMBOPOINTS",
        "GwSettingsTargetOptions"
    )
    addOption(
        GwLocalization["ADV_CAST_BAR"],
        GwLocalization["ADV_CAST_BAR_DESC"],
        "target_CASTINGBAR_DATA",
        "GwSettingsTargetOptions"
    )
    addOption(
        BUFFS_ON_TOP,
        nil,
        "target_AURAS_ON_TOP",
        "GwSettingsTargetOptions"
    )
    addOption(
        MINIMAP_TRACKING_FOCUS,
        GwLocalization["FOCUS_TARGET_DESC"],
        "focus_TARGET_ENABLED",
        "GwSettingsFocusOptions"
    )
    addOption(
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        GwLocalization["HEALTH_VALUE_DESC"],
        "focus_HEALTH_VALUE_ENABLED",
        "GwSettingsFocusOptions"
    )
    addOption(
        RAID_HEALTH_TEXT_PERC,
        GwLocalization["HEALTH_PERCENTAGE_DESC"],
        "focus_HEALTH_VALUE_TYPE",
        "GwSettingsFocusOptions"
    )
    addOption(
        CLASS_COLORS,
        GwLocalization["CLASS_COLOR_DESC"],
        "focus_CLASS_COLOR",
        "GwSettingsFocusOptions"
    )
    addOption(
        SHOW_DEBUFFS,
        GwLocalization["SHOW_DEBUFFS_DESC"],
        "focus_DEBUFFS",
        "GwSettingsFocusOptions"
    )
    addOption(
        SHOW_ALL_ENEMY_DEBUFFS_TEXT,
        GwLocalization["SHOW_ALL_DEBUFFS_DESC"],
        "focus_BUFFS_FILTER_ALL",
        "GwSettingsFocusOptions"
    )
    addOption(
        SHOW_BUFFS,
        GwLocalization["SHOW_BUFFS_DESC"],
        "focus_BUFFS",
        "GwSettingsFocusOptions"
    )
end
GW.LoadTargetPanel = LoadTargetPanel
