local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel

local function LoadPartyPanel(sWindow)
    local p = CreateFrame("Frame", "GwSettingsPartyPanel", sWindow.panels, "GwSettingsPartyPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(CHAT_MSG_PARTY)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the party and raid options to suit your needs."])

    createCat(CHAT_MSG_PARTY, L["Edit the group settings."], p, 4)

    addOption(p, USE_RAID_STYLE_PARTY_FRAMES, L["Style the party frames like the raid frames."], "RAID_STYLE_PARTY", nil, nil, {["PARTY_FRAMES"] = true, ["RAID_FRAMES"] = true})
    addOption(p, L["Show both party frames and party grid"], format(L["If enabled, this will show both the stylised party frames as well as the grid frame. This setting has no effect if '%s' is enabled."], USE_RAID_STYLE_PARTY_FRAMES), "RAID_STYLE_PARTY_AND_FRAMES", nil, nil, {["PARTY_FRAMES"] = true, ["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "PARTY_SHOW_DEBUFFS", nil, nil, {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "PARTY_ONLY_DISPELL_DEBUFFS", nil, nil, {["PARTY_FRAMES"] = true, ["PARTY_SHOW_DEBUFFS"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF", nil, nil, {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, L["Player frame in group"], L["Show your player frame as part of the group"], "PARTY_PLAYER_FRAME", nil, nil, {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS, nil, "PARTY_SHOW_PETS", nil, nil, {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
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
        {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false}
    )

    InitPanel(p)
end
GW.LoadPartyPanel = LoadPartyPanel
