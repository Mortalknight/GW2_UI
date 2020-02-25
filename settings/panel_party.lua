local _, GW = ...
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting

local function LoadPartyPanel(sWindow)
    local pnl_group = CreateFrame("Frame", "GwSettingsGroupframe", sWindow.panels, "GwSettingsPanelTmpl")
    pnl_group.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_group.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    pnl_group.header:SetText(CHAT_MSG_PARTY)
    pnl_group.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_group.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pnl_group.sub:SetText(GwLocalization["GROUP_DESC"])

    createCat(CHAT_MSG_PARTY, GwLocalization["GROUP_TOOLTIP"], "GwSettingsGroupframe", 4)

    addOption(
        USE_RAID_STYLE_PARTY_FRAMES,
        GwLocalization["RAID_PARTY_STYLE_DESC"],
        "RAID_STYLE_PARTY",
        "GwSettingsGroupframe"
    )
    addOption(
        RAID_USE_CLASS_COLORS,
        GwLocalization["CLASS_COLOR_RAID_DESC"],
        "RAID_CLASS_COLOR",
        "GwSettingsGroupframe"
    )
    addOption(
        DISPLAY_POWER_BARS,
        GwLocalization["POWER_BARS_RAID_DESC"],
        "RAID_POWER_BARS",
        "GwSettingsGroupframe"
    )
    addOption(
        DISPLAY_ONLY_DISPELLABLE_DEBUFFS,
        GwLocalization["DEBUFF_DISPELL_DESC"],
        "RAID_ONLY_DISPELL_DEBUFFS",
        "GwSettingsGroupframe"
    )
    addOption(
        RAID_TARGET_ICON,
        GwLocalization["RAID_MARKER_DESC"],
        "RAID_UNIT_MARKERS",
        "GwSettingsGroupframe"
    )
    addOption(
        GwLocalization["RAID_SORT_BY_ROLE"],
        GwLocalization["RAID_SORT_BY_ROLE_DESC"],
        "RAID_SORT_BY_ROLE",
        "GwSettingsGroupframe",
        function ()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end
    )
    addOption(
        GwLocalization["RAID_AURA_TOOLTIP_IN_COMBAT"],
        GwLocalization["RAID_AURA_TOOLTIP_IN_COMBAT_DESC"],
        "RAID_AURA_TOOLTIP_IN_COMBAT",
        "GwSettingsGroupframe"
    )

    addOptionDropdown(
        GwLocalization["RAID_UNIT_FLAGS"],
        GwLocalization["RAID_UNIT_FLAGS_TOOLTIP"],
        "RAID_UNIT_FLAGS",
        "GwSettingsGroupframe",
        function()
        end,
        {"NONE", "DIFFERENT", "ALL"},
        {NONE_KEY, GwLocalization["RAID_UNIT_FLAGS_2"], ALL}
    )

    addOptionDropdown(
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH",
        "GwSettingsGroupframe",
        function()
        end,
        {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}
    )

end
GW.LoadPartyPanel = LoadPartyPanel
