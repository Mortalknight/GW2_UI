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
    p.header:SetText(L["TOOLTIPS"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["HUD_DESC"])

    createCat(L["TOOLTIPS"], nil, p, 3)

    addOption(p, L["MOUSE_TOOLTIP"], L["MOUSE_TOOLTIP_DESC"], "TOOLTIP_MOUSE", nil, nil, {["TOOLTIPS_ENABLED"] = true})
    addOption(p, L["ADVANCED_TOOLTIP"], L["ADVANCED_TOOLTIP_DESC"], "ADVANCED_TOOLTIP", nil, nil, {["TOOLTIPS_ENABLED"] = true})
    addOption(p, L["ADVANCED_TOOLTIP_SPELL_ITEM_ID"], L["ADVANCED_TOOLTIP_SPELL_ITEM_ID_DESC"], "ADVANCED_TOOLTIP_SPELL_ITEM_ID", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p, L["ADVANCED_TOOLTIP_SHOW_MOUNT"], L["ADVANCED_TOOLTIP_SHOW_MOUNT_DESC"], "ADVANCED_TOOLTIP_SHOW_MOUNT", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p, L["ADVANCED_TOOLTIP_SHOW_TARGET_INFO"], L["ADVANCED_TOOLTIP_SHOW_TARGET_INFO_DESC"], "ADVANCED_TOOLTIP_SHOW_TARGET_INFO", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p, L["ADVANCED_TOOLTIP_NPC_ID"], L["ADVANCED_TOOLTIP_NPC_ID_DESC"], "ADVANCED_TOOLTIP_NPC_ID", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p, SHOW_PLAYER_TITLES, L["ADVANCED_TOOLTIP_SHOW_PLAYER_TITLES_DESC"], "ADVANCED_TOOLTIP_SHOW_PLAYER_TITLES", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p, L["ADVANCED_TOOLTIP_SHOW_GUILD_RANKS"], L["ADVANCED_TOOLTIP_SHOW_GUILD_RANKS_DESC"], "ADVANCED_TOOLTIP_SHOW_GUILD_RANKS", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p, L["ADVANCED_TOOLTIP_SHOW_REALM_ALWAYS"], nil, "ADVANCED_TOOLTIP_SHOW_REALM_ALWAYS", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOption(p, ROLE, L["ADVANCED_TOOLTIP_SHOW_ROLE_DESC"], "ADVANCED_TOOLTIP_SHOW_ROLE", nil, nil, {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true})
    addOptionDropdown(
        p,
        L["ADVANCED_TOOLTIP_OPTION_ITEMCOUNT"],
        L["ADVANCED_TOOLTIP_OPTION_ITEMCOUNT_DESC"],
        "ADVANCED_TOOLTIP_OPTION_ITEMCOUNT",
        nil,
        {"BAG", "BANK", "BOTH"},
        {
            INVTYPE_BAG,
            BANK,
            STATUS_TEXT_BOTH
        },
        nil,
        {["TOOLTIPS_ENABLED"] = true, ["ADVANCED_TOOLTIP"] = true}
    )
    addOptionDropdown(
        p,
        L["CURSOR_ANCHOR_TYPE"],
        L["CURSOR_ANCHOR_TYPE_DESC"],
        "CURSOR_ANCHOR_TYPE",
        nil,
        {"ANCHOR_CURSOR", "ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"},
        {
            L["CURSOR_ANCHOR"],
            L["ANCHOR_CURSOR_LEFT"],
            L["ANCHOR_CURSOR_RIGHT"]
        },
        nil,
        {["TOOLTIPS_ENABLED"] = true}
    )
    addOptionSlider(
        p,
        L["ANCHOR_CURSOR_OFFSET_X"],
        L["ANCHOR_CURSOR_OFFSET_DESC"],
        "ANCHOR_CURSOR_OFFSET_X",
        nil,
        -128,
        128,
        nil,
        0,
        {["TOOLTIPS_ENABLED"] = true, ["CURSOR_ANCHOR_TYPE"] = {"ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}}
    )
    addOptionSlider(
        p,
        L["ANCHOR_CURSOR_OFFSET_Y"],
        L["ANCHOR_CURSOR_OFFSET_DESC"],
        "ANCHOR_CURSOR_OFFSET_Y",
        nil,
        -128,
        128,
        nil,
        0,
        {["TOOLTIPS_ENABLED"] = true, ["CURSOR_ANCHOR_TYPE"] = {"ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"}}
    )

    InitPanel(p)
end
GW.LoadTooltipPanel = LoadTooltipPanel