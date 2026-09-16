---@class GW2
local GW = select(2, ...)
local L = GW.L

local function LoadTooltipPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    p.panelId = "tooltips_general"
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.header:SetText(L["Tooltips"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit tooltip appearance and content."])

    p:AddOption(ENABLE, L["Replace the default UI tooltips."], {getterSetter = "tooltip.enabled", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    p:AddOption(L["Cursor Tooltips"], L["Anchor the tooltips to the cursor."], {getterSetter = "tooltip.anchor.toCursor", dependence = {["tooltip.enabled"] = true}})
    p:AddOption(L["Current Mount"], L["Display current mount the unit is riding."], {getterSetter = "tooltip.unit.mount", dependence = {["tooltip.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath})
    p:AddOption(L["Target Info"], L["When in a raid group, show if anyone in your raid is targeting the current tooltip unit."], {getterSetter = "tooltip.unit.targetInfo", dependence = {["tooltip.enabled"] = true}})
    p:AddOption(SHOW_PLAYER_TITLES, L["Display player titles."], {getterSetter = "tooltip.unit.playerTitles", dependence = {["tooltip.enabled"] = true}})
    p:AddOption(GUILDCONTROL_GUILDRANKS, L["Display guild ranks if a unit is a member of a guild."], {getterSetter = "tooltip.unit.guildRanks", dependence = {["tooltip.enabled"] = true}})
    p:AddOption(L["Always Show Realm"], nil, {getterSetter = "tooltip.unit.realmAlways", dependence = {["tooltip.enabled"] = true}})
    p:AddOption(ROLE, L["Display the unit role in the tooltip."], {getterSetter = "tooltip.unit.role", dependence = {["tooltip.enabled"] = true}})
    p:AddOption(CLASS_COLORS, COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS, {getterSetter = "tooltip.unit.classColor", dependence = {["tooltip.enabled"] = true}})
    p:AddOption(L["Gender"], L["Displays the player character's gender."], {getterSetter = "tooltip.unit.gender", dependence = {["tooltip.enabled"] = true}})
    p:AddOption(DUNGEON_SCORE, nil, {getterSetter = "tooltip.unit.dungeonScore", dependence = {["tooltip.enabled"] = true}, hidden = not GW.Retail})
    p:AddOption(CHALLENGE_MODE_KEYSTONE_NAME:format("_"):gsub(": _", ""), L["Adds descriptions for mythic keystone properties to their tooltips."], {getterSetter = "tooltip.unit.keystoneInfo", dependence = {["tooltip.enabled"] = true}, hidden = not GW.Retail})
    p:AddOption(L["Hide in combat"], L["Hide different kind of tooltips during combat."], {getterSetter = "tooltip.hideInCombat.enabled", dependence = {["tooltip.enabled"] = true}})
    p:AddOption(L["Show premade group info"], L["Add LFG group info to tooltip."], {getterSetter = "tooltip.unit.premadeGroupInfo", dependence = {["tooltip.enabled"] = true}, incompatibleAddons = "LfgInfo", hidden = not GW.Retail})
    p:AddOption(L["Shorten Health Bar Text"], nil, {getterSetter = "tooltip.healthBar.shortValues", dependence = {["tooltip.enabled"] = true}})
    p:AddOptionDropdown(L["Health Bar Position"], nil, { getterSetter = "tooltip.healthBar.position", optionsList = {"BOTTOM", "TOP", "DISABLED"}, optionNames = {L["Bottom"], L["Top"], GARRISON_DEACTIVATE_FOLLOWER}, dependence = {["tooltip.enabled"] = true}})
    p:AddOptionDropdown(L["Health Bar Values"], nil, { getterSetter = "tooltip.healthBar.values", optionsList = {"RAW", "PERCENTAGE", "BOTH", "NONE"}, optionNames = {STATUS_TEXT_VALUE, STATUS_TEXT_PERCENT, STATUS_TEXT_BOTH, NONE}, dependence = {["tooltip.enabled"] = true}})
    p:AddOptionDropdown(L["Combat Override Key"], L["Modifier to hold to show the tooltip in combat."], { getterSetter = "tooltip.hideInCombat.overrideKey", optionsList = {"ALWAYS", "NONE", "SHIFT", "CTRL", "ALT"}, optionNames = {ALWAYS, NONE, SHIFT_KEY, CTRL_KEY, ALT_KEY}, dependence = {["tooltip.enabled"] = true, ["tooltip.hideInCombat.enabled"] = true}})
    p:AddOptionDropdown(L["Hide Units"], L["Only hide unit tooltips of the selected reactions."], {
        getterSetter = "tooltip.hideInCombat.units",
        optionsList = {"NONE", "FRIENDLY", "HOSTILE", "NEUTRAL", "FRIENDLY_NEUTRAL", "FRIENDLY_HOSTILE", "HOSTILE_NEUTRAL", "ALL"},
        optionNames = {
            NONE,
            FRIENDLY,
            HOSTILE,
            FACTION_STANDING_LABEL4,
            FRIENDLY .. " & " .. FACTION_STANDING_LABEL4,
            FRIENDLY .. " & " .. HOSTILE,
            HOSTILE .. " & " .. FACTION_STANDING_LABEL4,
            ALL
        },
        dependence = {["tooltip.enabled"] = true, ["tooltip.hideInCombat.enabled"] = true}
    })
    p:AddOptionDropdown(L["Modifier for IDs"], nil, { getterSetter = "tooltip.idModifier", callback = function()
        -- keeps the tooltipShowAuraSpellIDs CVar (secure aura tooltips) in sync
        if GW.UpdateAuraTooltipIDCVar then
            GW.UpdateAuraTooltipIDCVar()
        end
    end, optionsList = {"ALWAYS", "NONE", "SHIFT", "CTRL", "ALT"}, dependence = {["tooltip.enabled"] = true}, optionNames = {ALWAYS, NONE, SHIFT_KEY, CTRL_KEY, ALT_KEY}})
    p:AddOptionDropdown(L["Item Count"], L["Display how many of a certain item you have in your possession."], { getterSetter = "tooltip.item.count", optionsList = {"Bag", "Bank", "Stack"}, optionNames = {INVTYPE_BAG, BANK, L["Stack Size"]}, dependence = {["tooltip.enabled"] = true}, checkbox = true})
    p:AddOption(L["Include Reagents"], nil, {getterSetter = "tooltip.item.countIncludeReagents", dependence = {["tooltip.enabled"] = true}, hidden = not GW.Retail})
    p:AddOption(L["Include Warband"], nil, {getterSetter = "tooltip.item.countIncludeWarband", dependence = {["tooltip.enabled"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(L["Cursor Anchor Type"], L["Only takes effect if 'Cursor Tooltips' is enabled"], { getterSetter = "tooltip.anchor.cursorType", optionsList = {"ANCHOR_CURSOR", "ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}, optionNames = {L["Cursor Anchor"], L["Cursor Anchor Left"], L["Cursor Anchor Right"]}, dependence = {["tooltip.enabled"] = true, ["tooltip.anchor.toCursor"] = true}})
    p:AddOptionSlider(L["Cursor Anchor Offset X"], L["Only takes effect if 'Cursor Tooltips' is enabled and the cursor anchor is not 'Cursor Anchor'"], { getterSetter = "tooltip.anchor.cursorOffsetX", min = -128, max = 128, decimalNumbers = 0, step = 1, dependence = {["tooltip.enabled"] = true, ["tooltip.anchor.toCursor"] = true, ["tooltip.anchor.cursorType"] = {"ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}}})
    p:AddOptionSlider(L["Cursor Anchor Offset Y"], L["Only takes effect if 'Cursor Tooltips' is enabled and the cursor anchor is not 'Cursor Anchor'"], { getterSetter = "tooltip.anchor.cursorOffsetY", min = -128, max = 128, decimalNumbers = 0, step = 1, dependence = {["tooltip.enabled"] = true, ["tooltip.anchor.toCursor"] = true, ["tooltip.anchor.cursorType"] = {"ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}}})

    p:AddGroupHeader(FONT_SIZE)
    p:AddOptionSlider(L["Tooltip Header"], nil, { getterSetter = "tooltip.fontSize.header", callback = GW.SetTooltipFonts, min = 5, max = 42, decimalNumbers = 0, step = 1, dependence = {["tooltip.enabled"] = true}})
    p:AddOptionSlider(L["Tooltip Body"], nil, { getterSetter = "tooltip.fontSize.body", callback = GW.SetTooltipFonts, min = 5, max = 42, decimalNumbers = 0, step = 1, dependence = {["tooltip.enabled"] = true}})
    p:AddOptionSlider(L["Comparison"], nil, { getterSetter = "tooltip.fontSize.comparison", callback = GW.SetTooltipFonts, min = 5, max = 42, decimalNumbers = 0, step = 1, dependence = {["tooltip.enabled"] = true}})
    p:AddOptionSlider(L["Health Bar Text"], nil, { getterSetter = "tooltip.fontSize.healthBar", callback = GW.SetTooltipFonts, min = 5, max = 20, decimalNumbers = 0, step = 1, dependence = {["tooltip.enabled"] = true}})


    sWindow:AddSettingsPanel(p, L["Tooltips"], L["Edit tooltip appearance and content."])
end
GW.LoadTooltipPanel = LoadTooltipPanel
