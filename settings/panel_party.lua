local _, GW = ...
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling
local L = GwLocalization

local function LoadPartyPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(CHAT_MSG_PARTY)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["GROUP_DESC"])

    createCat(CHAT_MSG_PARTY, L["GROUP_TOOLTIP"], p, 4)

    addOption(p, USE_RAID_STYLE_PARTY_FRAMES, L["RAID_PARTY_STYLE_DESC"], "RAID_STYLE_PARTY")
    addOption(p, RAID_USE_CLASS_COLORS, L["CLASS_COLOR_RAID_DESC"], "RAID_CLASS_COLOR")
    addOption(p, DISPLAY_POWER_BARS, L["POWER_BARS_RAID_DESC"], "RAID_POWER_BARS")
    addOption(p, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["DEBUFF_DISPELL_DESC"], "RAID_ONLY_DISPELL_DEBUFFS")
    addOption(p, RAID_TARGET_ICON, L["RAID_MARKER_DESC"], "RAID_UNIT_MARKERS")
    addOption(
        p,
        L["RAID_SORT_BY_ROLE"],
        L["RAID_SORT_BY_ROLE_DESC"],
        "RAID_SORT_BY_ROLE",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end
    )
    addOption(p, L["RAID_AURA_TOOLTIP_IN_COMBAT"], L["RAID_AURA_TOOLTIP_IN_COMBAT_DESC"], "RAID_AURA_TOOLTIP_IN_COMBAT")

    addOptionDropdown(
        p,
        L["RAID_UNIT_FLAGS"],
        L["RAID_UNIT_FLAGS_TOOLTIP"],
        "RAID_UNIT_FLAGS",
        nil,
        {"NONE", "DIFFERENT", "ALL"},
        {NONE_KEY, L["RAID_UNIT_FLAGS_2"], ALL}
    )

    addOptionDropdown(
        p,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH",
        nil,
        {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        {
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH
        }
    )

    InitPanel(p)
end
GW.LoadPartyPanel = LoadPartyPanel
