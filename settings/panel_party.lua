local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling

local function LoadPartyPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(CHAT_MSG_PARTY)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["GROUP_DESC"])

    createCat(CHAT_MSG_PARTY, L["GROUP_TOOLTIP"], p, 4)

    addOption(p, USE_RAID_STYLE_PARTY_FRAMES, L["RAID_PARTY_STYLE_DESC"], "RAID_STYLE_PARTY", nil, nil, {["GROUP_FRAMES"] = true})
    addOption(p, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "PARTY_SHOW_DEBUFFS", nil, nil, {["GROUP_FRAMES"] = true})
    addOption(p, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["DEBUFF_DISPELL_DESC"], "PARTY_ONLY_DISPELL_DEBUFFS", nil, nil, {["GROUP_FRAMES"] = true, ["PARTY_SHOW_DEBUFFS"] = true})
    addOption(p, L["RAID_SHOW_IMPORTEND_RAID_DEBUFFS"], L["RAID_SHOW_IMPORTEND_RAID_DEBUFFS_DESC"], "PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF", nil, nil, {["GROUP_FRAMES"] = true})
    addOption(p, L["FADE_GROUP_MANAGE_FRAME"], L["FADE_GROUP_MANAGE_FRAME_DESC"], "FADE_GROUP_MANAGE_FRAME", nil, nil, {["GROUP_FRAMES"] = true})
    addOptionDropdown(
        p,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "PARTY_UNIT_HEALTH",
        nil,
        {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        {
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH
        },
        nil,
        {["GROUP_FRAMES"] = true}
    )

    InitPanel(p)
end
GW.LoadPartyPanel = LoadPartyPanel
