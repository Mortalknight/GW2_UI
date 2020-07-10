local _, GW = ...
local L = GW.L
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local addOption = GW.AddOption
local StrUpper = GW.StrUpper
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling

local function LoadPlayerPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(PLAYER)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["PLAYER_DESC"])

    createCat(PLAYER, L["PLAYER_DESC"], p, 9)

    addOption(p, L["ENERGY_MANA_TICK"], nil, "PLAYER_ENERGY_MANA_TICK", nil, nil, {["POWERBAR_ENABLED"] = true})
    addOption(p, L["ENERGY_MANA_TICK_HIDE_OFC"], nil, "PLAYER_ENERGY_MANA_TICK_HIDE_OFC", nil, nil, {["POWERBAR_ENABLED"] = true, ["PLAYER_ENERGY_MANA_TICK"] = true})
    addOption(p, L["5SR_TIMER"], nil, "PLAYER_5SR_TIMER", nil, nil, {["POWERBAR_ENABLED"] = true, ["PLAYER_ENERGY_MANA_TICK"] = true})

    addOptionSlider(
        p,
        L["AURAS_PER_ROW"],
        nil,
        "PLAYER_AURA_WRAP_NUM",
        nil,
        1,
        20,
        nil,
        0,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionSlider(
        p,
        L["PLAYER_BUFF_SIZE"],
        nil,
        "PlayerBuffFrame_ICON_SIZE",
        nil,
        16,
        60,
        nil,
        0,
        {["PLAYER_BUFFS_ENABLED"] = true},
        2
    )
    addOptionSlider(
        p,
        L["PLAYER_DEBUFF_SIZE"],
        nil,
        "PlayerDebuffFrame_ICON_SIZE",
        nil,
        16,
        60,
        nil,
        0,
        {["PLAYER_BUFFS_ENABLED"] = true},
        2
    )
    addOptionDropdown(
        p,
        L["PLAYER_BUFFS_GROW"],
        nil,
        "PlayerBuffFrame_GrowDirection",
        GW.UpdateHudScale(),
        {"UP", "DOWN", "UPR", "DOWNR"},
        {
            StrUpper(L["UP"], 1, 1),
            StrUpper(L["DOWN"], 1, 1),
            L["UP_AND_RIGHT"],
            L["DOWN_AND_RIGHT"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        L["PLAYER_DEBUFFS_GROW"],
        nil,
        "PlayerDebuffFrame_GrowDirection",
        GW.UpdateHudScale(),
        {"UP", "DOWN", "UPR", "DOWNR"},
        {
            StrUpper(L["UP"], 1, 1),
            StrUpper(L["DOWN"], 1, 1),
            L["UP_AND_RIGHT"],
            L["DOWN_AND_RIGHT"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "PLAYER_UNIT_HEALTH",
        nil,
        {"NONE", "PREC", "VALUE", "BOTH"},
        {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )

    InitPanel(p)
end
GW.LoadPlayerPanel = LoadPlayerPanel
