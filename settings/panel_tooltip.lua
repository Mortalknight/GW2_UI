local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling

local function LoadTooltipPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(L["Tooltips"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])

    createCat(L["Tooltips"], nil, p, 10)

    addOption(p, L["Cursor Tooltips"], L["Anchor the tooltips to the cursor."], "TOOLTIP_MOUSE", nil, nil, {["TOOLTIPS_ENABLED"] = true})
    addOption(p, L["Advanced Tooltips"], L["Displays additional information in the tooltip (further information is displayed when the SHIFT key is pressed)"], "ADVANCED_TOOLTIP", nil, nil, {["TOOLTIPS_ENABLED"] = true})
    addOption(p, L["Target Info"], L["When in a raid group, show if anyone in your raid is targeting the current tooltip unit."], "ADVANCED_TOOLTIP_SHOW_TARGET_INFO", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p, GUILDCONTROL_GUILDRANKS, L["Display guild ranks if a unit is a member of a guild."], "ADVANCED_TOOLTIP_SHOW_GUILD_RANKS", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p, L["Always Show Realm"], nil, "ADVANCED_TOOLTIP_SHOW_REALM_ALWAYS", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p, CLASS_COLORS, COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS, "ADVANCED_TOOLTIP_SHOW_CLASS_COLOR", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p, L["Gender"], L["Displays the player character's gender."], "ADVANCED_TOOLTIP_SHOW_GENDER", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOptionSlider(
        p,
        FONT_SIZE,
        nil,
        "TOOLTIP_FONT_SIZE",
        GW.SetTooltipFonts,
        5,
        42,
        nil,
        0,
        {["TOOLTIPS_ENABLED"] = true},
        1
    )    
    addOptionDropdown(
        p,
        L["Modifier for IDs"],
        nil,
        "ADVANCED_TOOLTIP_ID_MODIFIER",
        nil,
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
        p,
        L["Item Count"],
        L["Display how many of a certain item you have in your possession."],
        "ADVANCED_TOOLTIP_OPTION_ITEMCOUNT",
        nil,
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
        p,
        L["Cursor Anchor Type"],
        L["Only takes effect if the option 'Cursor Tooltips' is activated"],
        "CURSOR_ANCHOR_TYPE",
        nil,
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
        p,
        L["Cursor Anchor Offset X"],
        L["Only takes effect if the option 'Cursor Tooltips' is activated and the cursor anchor is NOT 'Cursor Anchor'"],
        "ANCHOR_CURSOR_OFFSET_X",
        nil,
        -128,
        128,
        nil,
        0,
        {["TOOLTIPS_ENABLED"] = true, ["TOOLTIP_MOUSE"] = true, ["CURSOR_ANCHOR_TYPE"] = {"ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}}
    )
    addOptionSlider(
        p,
        L["Cursor Anchor Offset Y"],
        L["Only takes effect if the option 'Cursor Tooltips' is activated and the cursor anchor is NOT 'Cursor Anchor'"],
        "ANCHOR_CURSOR_OFFSET_Y",
        nil,
        -128,
        128,
        nil,
        0,
        {["TOOLTIPS_ENABLED"] = true, ["TOOLTIP_MOUSE"] = true, ["CURSOR_ANCHOR_TYPE"] = {"ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}}
    )

    InitPanel(p)
end
GW.LoadTooltipPanel = LoadTooltipPanel