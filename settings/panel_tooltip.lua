local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton;

local function LoadTooltipPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(L["Tooltips"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])

    createCat(L["Tooltips"], nil, p, 10, nil, {p})
    settingsMenuAddButton(L["Tooltips"],p,10,nil, {})

    addOption(p.scroll.scrollchild, L["Cursor Tooltips"], L["Anchor the tooltips to the cursor."], "TOOLTIP_MOUSE", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Advanced Tooltips"], L["Displays additional information in the tooltip (further information is displayed when the SHIFT key is pressed)"], "ADVANCED_TOOLTIP", function() GW.ShowRlPopup = true end, nil, {["TOOLTIPS_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Current Mount"], L["Display current mount the unit is riding."], "ADVANCED_TOOLTIP_SHOW_MOUNT", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p.scroll.scrollchild, L["Target Info"], L["When in a raid group, show if anyone in your raid is targeting the current tooltip unit."], "ADVANCED_TOOLTIP_SHOW_TARGET_INFO", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p.scroll.scrollchild, SHOW_PLAYER_TITLES, L["Display player titles."], "ADVANCED_TOOLTIP_SHOW_PLAYER_TITLES", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p.scroll.scrollchild, GUILDCONTROL_GUILDRANKS, L["Display guild ranks if a unit is a member of a guild."], "ADVANCED_TOOLTIP_SHOW_GUILD_RANKS", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p.scroll.scrollchild, L["Always Show Realm"], nil, "ADVANCED_TOOLTIP_SHOW_REALM_ALWAYS", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p.scroll.scrollchild, ROLE, L["Display the unit role in the tooltip."], "ADVANCED_TOOLTIP_SHOW_ROLE", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p.scroll.scrollchild, CLASS_COLORS, COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS, "ADVANCED_TOOLTIP_SHOW_CLASS_COLOR", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p.scroll.scrollchild, L["Gender"], L["Displays the player character's gender."], "ADVANCED_TOOLTIP_SHOW_GENDER", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p.scroll.scrollchild, DUNGEON_SCORE, nil, "ADVANCED_TOOLTIP_SHOW_DUNGEONSCORE", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p.scroll.scrollchild, CHALLENGE_MODE_KEYSTONE_NAME:format("_"):gsub(": _", ""), L["Adds descriptions for mythic keystone properties to their tooltips."], "ADVANCED_TOOLTIP_SHOW_KEYSTONEINFO", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p.scroll.scrollchild, L["Show Health bar text"], nil, "ADVANCED_TOOLTIP_SHOW_HEALTHBAR_TEXT", function(value) GW.UpdateTooltipSettings(); if not GameTooltip:IsForbidden() then if value then GameTooltipStatusBar.text:Show(); else GameTooltipStatusBar.text:Hide() end end end, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p.scroll.scrollchild, L["Hide in combat"], L["Hide different kind of tooltips during combat."], "HIDE_TOOLTIP_IN_COMBAT", GW.UpdateTooltipSettings, nil, {["TOOLTIPS_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Health Bar Position"],
        nil,
        "TOOLTIP_HEALTHBAER_POSITION",
        GW.UpdateTooltipSettings,
        {"BOTTOM", "TOP", "DISABLED"},
        {
            L["Bottom"],
            L["Top"],
            GARRISON_DEACTIVATE_FOLLOWER
        },
        nil,
        {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Combat Override Key"],
        L["Modifier to hold to show the tooltip in combat."],
        "HIDE_TOOLTIP_IN_COMBAT_OVERRIDE",
        GW.UpdateTooltipSettings,
        {"ALWAYS", "NONE", "SHIFT", "CTRL", "ALT"},
        {
            ALWAYS,
            NONE,
            SHIFT_KEY,
            CTRL_KEY,
            ALT_KEY,
        },
        nil,
        {["TOOLTIPS_ENABLED"] = true, ["HIDE_TOOLTIP_IN_COMBAT"] = true}
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Hide Units"],
        L["Only hide unit tooltips of the selected reactions."],
        "HIDE_TOOLTIP_IN_COMBAT_UNIT",
        GW.UpdateTooltipSettings,
        {"NONE", "FRIENDLY", "HOSTILE", "NEUTRAL", "FRIENDLY_NEUTRAL", "FRIENDLY_HOSTILE", "HOSTILE_NEUTRAL", "ALL"},
        {
            NONE,
            FRIENDLY,
            HOSTILE,
            FACTION_STANDING_LABEL4,
            FRIENDLY .. " & " .. FACTION_STANDING_LABEL4,
            FRIENDLY .. " & " .. HOSTILE,
            HOSTILE .. " & " .. FACTION_STANDING_LABEL4,
            ALL
        },
        nil,
        {["TOOLTIPS_ENABLED"] = true, ["HIDE_TOOLTIP_IN_COMBAT"] = true}
    )
    addOptionSlider(
        p.scroll.scrollchild,
        FONT_SIZE,
        nil,
        "TOOLTIP_FONT_SIZE",
        function()
            GW.UpdateTooltipSettings()
            GW.SetTooltipFonts()
        end,
        5,
        42,
        nil,
        0,
        {["TOOLTIPS_ENABLED"] = true},
        1
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Modifier for IDs"],
        nil,
        "ADVANCED_TOOLTIP_ID_MODIFIER",
        GW.UpdateTooltipSettings,
        {"ALWAYS", "NONE", "SHIFT", "CTRL", "ALT"},
        {
            ALWAYS,
            NONE,
            SHIFT_KEY,
            CTRL_KEY,
            ALT_KEY,
        },
        nil,
        {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Item Count"],
        L["Display how many of a certain item you have in your possession."],
        "ADVANCED_TOOLTIP_OPTION_ITEMCOUNT",
        GW.UpdateTooltipSettings,
        {"NONE", "BAG", "BANK", "BOTH"},
        {
            NONE,
            INVTYPE_BAG,
            BANK,
            STATUS_TEXT_BOTH
        },
        nil,
        {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Cursor Anchor Type"],
        L["Only takes effect if the option 'Cursor Tooltips' is activated"],
        "CURSOR_ANCHOR_TYPE",
        GW.UpdateTooltipSettings,
        {"ANCHOR_CURSOR", "ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"},
        {
            L["Cursor Anchor"],
            L["Cursor Anchor Left"],
            L["Cursor Anchor Right"]
        },
        nil,
        {["TOOLTIPS_ENABLED"] = true, ["TOOLTIP_MOUSE"] = true}
    )
    addOptionSlider(
        p.scroll.scrollchild,
        L["Cursor Anchor Offset X"],
        L["Only takes effect if the option 'Cursor Tooltips' is activated and the cursor anchor is NOT 'Cursor Anchor'"],
        "ANCHOR_CURSOR_OFFSET_X",
        GW.UpdateTooltipSettings,
        -128,
        128,
        nil,
        0,
        {["TOOLTIPS_ENABLED"] = true, ["TOOLTIP_MOUSE"] = true, ["CURSOR_ANCHOR_TYPE"] = {"ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}}
    )
    addOptionSlider(
        p.scroll.scrollchild,
        L["Cursor Anchor Offset Y"],
        L["Only takes effect if the option 'Cursor Tooltips' is activated and the cursor anchor is NOT 'Cursor Anchor'"],
        "ANCHOR_CURSOR_OFFSET_Y",
        GW.UpdateTooltipSettings,
        -128,
        128,
        nil,
        0,
        {["TOOLTIPS_ENABLED"] = true, ["TOOLTIP_MOUSE"] = true, ["CURSOR_ANCHOR_TYPE"] = {"ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}}
    )

    InitPanel(p, true)
end
GW.LoadTooltipPanel = LoadTooltipPanel
