local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton;

local function LoadPartyPanel(sWindow)
    local p = CreateFrame("Frame", "GwSettingsPartyPanel", sWindow.panels, "GwSettingsPartyPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.header:SetText(CHAT_MSG_PARTY)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the party and raid options to suit your needs."])

    createCat(CHAT_MSG_PARTY, L["Edit the group settings."], p)
    settingsMenuAddButton(CHAT_MSG_PARTY, p, {})

    addOption(p, L["Show both party frames and party grid"], format(L["If enabled, this will show both the stylised party frames as well as the grid frame. This setting has no effect if '%s' is enabled."], USE_RAID_STYLE_PARTY_FRAMES), "RAID_STYLE_PARTY_AND_FRAMES", function() GW.UpdateGridSettings("PARTY", true); end, nil, {["PARTY_FRAMES"] = true, ["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, SHOW_BUFFS, nil, "PARTY_SHOW_BUFFS", GW.UpdatePartyFrames, nil, {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "PARTY_SHOW_DEBUFFS", GW.UpdatePartyFrames, nil, {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "PARTY_ONLY_DISPELL_DEBUFFS", GW.UpdatePartyFrames, nil, {["PARTY_FRAMES"] = true, ["PARTY_SHOW_DEBUFFS"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF", GW.UpdatePartyFrames, nil, {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, L["Player frame in group"], L["Show your player frame as part of the group"], "PARTY_PLAYER_FRAME", function() GW.UpdatePlayerInPartySetting() end, nil, {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS, nil, "PARTY_SHOW_PETS", GW.UpdatePartyPetVisibility, nil, {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
    addOption(p, L["Shorten health values"], nil, "PARTY_UNIT_HEALTH_SHORT_VALUES", GW.UpdatePartyFrames, nil, {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false})
    addOptionDropdown(p, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {settingName = "PARTY_UNIT_HEALTH", getterSetter = "PARTY_UNIT_HEALTH", callback = GW.UpdatePartyFrames, optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"}, optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}, dependence = {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false}})
    addOptionSlider(p, L["Aura size"], nil, {settingName = "PARTY_SHOW_AURA_ICON_SIZE", getterSetter = "PARTY_SHOW_AURA_ICON_SIZE", callback = GW.UpdatePartyFrames, min = 10, max = 40, decimalNumbers = 0, step = 2, dependence = {["PARTY_FRAMES"] = true, ["RAID_STYLE_PARTY"] = false}})

    InitPanel(p)
end
GW.LoadPartyPanel = LoadPartyPanel
