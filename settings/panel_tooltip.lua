local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel

local function LoadTooltipPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.header:SetText(L["Tooltips"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])

    createCat(L["Tooltips"], nil, p, {p}, true)

    addOption(p.scroll.scrollchild, L["Cursor Tooltips"], L["Anchor the tooltips to the cursor."], {getterSetter = "TOOLTIP_MOUSE", dependence = {["TOOLTIPS_ENABLED"] = true}})
    addOption(p.scroll.scrollchild, L["Advanced Tooltips"], L["Displays additional information in the tooltip (further information is displayed when the SHIFT key is pressed)"], {getterSetter = "ADVANCED_TOOLTIP", dependence = {["TOOLTIPS_ENABLED"] = true}})
    addOption(p.scroll.scrollchild, L["Current Mount"], L["Display current mount the unit is riding."], {getterSetter = "ADVANCED_TOOLTIP_SHOW_MOUNT", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}, hidden = GW.Classic})
    addOption(p.scroll.scrollchild, L["Target Info"], L["When in a raid group, show if anyone in your raid is targeting the current tooltip unit."], {getterSetter = "ADVANCED_TOOLTIP_SHOW_TARGET_INFO", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}})
    addOption(p.scroll.scrollchild, SHOW_PLAYER_TITLES, L["Display player titles."], {getterSetter = "ADVANCED_TOOLTIP_SHOW_PLAYER_TITLES", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}})
    addOption(p.scroll.scrollchild, GUILDCONTROL_GUILDRANKS, L["Display guild ranks if a unit is a member of a guild."], {getterSetter = "ADVANCED_TOOLTIP_SHOW_GUILD_RANKS", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}})
    addOption(p.scroll.scrollchild, L["Always Show Realm"], nil, {getterSetter = "ADVANCED_TOOLTIP_SHOW_REALM_ALWAYS", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}})
    addOption(p.scroll.scrollchild, ROLE, L["Display the unit role in the tooltip."], {getterSetter = "ADVANCED_TOOLTIP_SHOW_ROLE", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}})
    addOption(p.scroll.scrollchild, CLASS_COLORS, COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS, {getterSetter = "ADVANCED_TOOLTIP_SHOW_CLASS_COLOR", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}})
    addOption(p.scroll.scrollchild, L["Gender"], L["Displays the player character's gender."], {getterSetter = "ADVANCED_TOOLTIP_SHOW_GENDER", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}})
    addOption(p.scroll.scrollchild, DUNGEON_SCORE, nil, {getterSetter = "ADVANCED_TOOLTIP_SHOW_DUNGEONSCORE", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}, hidden = not GW.Retail})
    addOption(p.scroll.scrollchild, CHALLENGE_MODE_KEYSTONE_NAME:format("_"):gsub(": _", ""), L["Adds descriptions for mythic keystone properties to their tooltips."], {getterSetter = "ADVANCED_TOOLTIP_SHOW_KEYSTONEINFO", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}, hidden = not GW.Retail})
    addOption(p.scroll.scrollchild, L["Show Health bar text"], nil, {getterSetter = "ADVANCED_TOOLTIP_SHOW_HEALTHBAR_TEXT", callback = function(value) if not GameTooltip:IsForbidden() then if value then GameTooltipStatusBar.text:Show() else GameTooltipStatusBar.text:Hide() end end end, dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}})
    addOption(p.scroll.scrollchild, L["Hide in combat"], L["Hide different kind of tooltips during combat."], {getterSetter = "HIDE_TOOLTIP_IN_COMBAT", dependence = {["TOOLTIPS_ENABLED"] = true}})
    addOption(p.scroll.scrollchild, L["Show premade group info"], L["Add LFG group info to tooltip."], {getterSetter = "TOOLTIP_SHOW_PREMADE_GROUP_INFO", dependence = {["TOOLTIPS_ENABLED"] = true}, incompatibleAddons = "LfgInfo", hidden = not GW.Retail})
    addOptionDropdown(p.scroll.scrollchild, L["Health Bar Position"], nil, { getterSetter = "TOOLTIP_HEALTHBAER_POSITION", optionsList = {"BOTTOM", "TOP", "DISABLED"}, optionNames = {L["Bottom"], L["Top"], GARRISON_DEACTIVATE_FOLLOWER}, dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}})
    addOptionDropdown(p.scroll.scrollchild, L["Combat Override Key"], L["Modifier to hold to show the tooltip in combat."], { getterSetter = "HIDE_TOOLTIP_IN_COMBAT_OVERRIDE", optionsList = {"ALWAYS", "NONE", "SHIFT", "CTRL", "ALT"}, optionNames = {ALWAYS, NONE, SHIFT_KEY, CTRL_KEY, ALT_KEY}, dependence = {["TOOLTIPS_ENABLED"] = true, ["HIDE_TOOLTIP_IN_COMBAT"] = true}})
    addOptionDropdown(p.scroll.scrollchild, L["Hide Units"],  L["Only hide unit tooltips of the selected reactions."], { getterSetter = "HIDE_TOOLTIP_IN_COMBAT_UNIT", optionsList = {"NONE", "FRIENDLY", "HOSTILE", "NEUTRAL", "FRIENDLY_NEUTRAL", "FRIENDLY_HOSTILE", "HOSTILE_NEUTRAL", "ALL"}, optionNames = {NONE, FRIENDLY, HOSTILE, FACTION_STANDING_LABEL4, FRIENDLY .. " & " .. FACTION_STANDING_LABEL4, FRIENDLY .. " & " .. HOSTILE, HOSTILE .. " & " .. FACTION_STANDING_LABEL4, ALL}, dependence = {["TOOLTIPS_ENABLED"] = true, ["HIDE_TOOLTIP_IN_COMBAT"] = true}})
    addOptionSlider(p.scroll.scrollchild, FONT_SIZE .. ": " .. L["Tooltip Header"], nil, { getterSetter = "TOOLTIP_HEADER_FONT_SIZE", callback = GW.SetTooltipFonts, min = 5, max = 42, decimalNumbers = 0, step = 1, dependence = {["TOOLTIPS_ENABLED"] = true}})
    addOptionSlider(p.scroll.scrollchild, FONT_SIZE .. ": " .. L["Tooltip Body"], nil, { getterSetter = "TOOLTIP_FONT_SIZE", callback = GW.SetTooltipFonts, min = 5, max = 42, decimalNumbers = 0, step = 1, dependence = {["TOOLTIPS_ENABLED"] = true}})
    addOptionSlider(p.scroll.scrollchild, FONT_SIZE .. ": " .. L["Comparison"], nil, { getterSetter = "TOOLTIP_SMALL_FONT_SIZE", callback = GW.SetTooltipFonts, min = 5, max = 42, decimalNumbers = 0, step = 1, dependence = {["TOOLTIPS_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, L["Modifier for IDs"], nil, { getterSetter = "ADVANCED_TOOLTIP_ID_MODIFIER", optionsList = {"ALWAYS", "NONE", "SHIFT", "CTRL", "ALT"}, optionNames = {ALWAYS, NONE, SHIFT_KEY, CTRL_KEY, ALT_KEY}, dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}})
    addOptionDropdown(p.scroll.scrollchild, L["Item Count"], L["Display how many of a certain item you have in your possession."], { getterSetter = "ADVANCED_TOOLTIP_OPTION_ITEMCOUNT", optionsList = {"Bag", "Bank", "Stack"}, optionNames = {INVTYPE_BAG, BANK, L["Stack Size"]}, dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}, checkbox = true})
    addOption(p.scroll.scrollchild, L["Include Reagents"], nil, {getterSetter = "ADVANCED_TOOLTIP_OPTION_ITEMCOUNT_INCLUDE_REAGENTS", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}, hidden = not GW.Retail})
    addOption(p.scroll.scrollchild, L["Include Warband"], nil, {getterSetter = "ADVANCED_TOOLTIP_OPTION_ITEMCOUNT_INCLUDE_WARBAND", dependence = {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}, hidden = not GW.Retail})
    addOptionDropdown(p.scroll.scrollchild, L["Cursor Anchor Type"], L["Only takes effect if the option 'Cursor Tooltips' is activated"], { getterSetter = "CURSOR_ANCHOR_TYPE", optionsList = {"ANCHOR_CURSOR", "ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}, optionNames = {L["Cursor Anchor"], L["Cursor Anchor Left"], L["Cursor Anchor Right"]}, dependence = {["TOOLTIPS_ENABLED"] = true, ["TOOLTIP_MOUSE"] = true}})
    addOptionSlider(p.scroll.scrollchild, L["Cursor Anchor Offset X"], L["Only takes effect if the option 'Cursor Tooltips' is activated and the cursor anchor is NOT 'Cursor Anchor'"], { getterSetter = "ANCHOR_CURSOR_OFFSET_X", min = -128, max = 128, decimalNumbers = 0, step = 1, dependence = {["TOOLTIPS_ENABLED"] = true, ["TOOLTIP_MOUSE"] = true, ["CURSOR_ANCHOR_TYPE"] = {"ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}}})
    addOptionSlider(p.scroll.scrollchild, L["Cursor Anchor Offset Y"], L["Only takes effect if the option 'Cursor Tooltips' is activated and the cursor anchor is NOT 'Cursor Anchor'"], { getterSetter = "ANCHOR_CURSOR_OFFSET_Y", min = -128, max = 128, decimalNumbers = 0, step = 1, dependence = {["TOOLTIPS_ENABLED"] = true, ["TOOLTIP_MOUSE"] = true, ["CURSOR_ANCHOR_TYPE"] = {"ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}}})

    InitPanel(p, true)
end
GW.LoadTooltipPanel = LoadTooltipPanel
