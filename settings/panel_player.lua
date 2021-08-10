local _, GW = ...
local L = GW.L
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local addOptionText = GW.AddOptionText
local addOption = GW.AddOption
local StrUpper = GW.StrUpper
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel

local function LoadPlayerPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.scroll.scrollchild.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.scroll.scrollchild.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.scroll.scrollchild.header:SetText(PLAYER)
    p.scroll.scrollchild.sub:SetFont(UNIT_NAME_FONT, 12)
    p.scroll.scrollchild.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.scroll.scrollchild.sub:SetText(L["Modify the player frame settings."])

    createCat(PLAYER, L["Modify the player frame settings."], p, 9, nil, {p})

    addOption(p.scroll.scrollchild, L["Player frame in target frame style"], nil, "PLAYER_AS_TARGET_FRAME", nil, nil, {["HEALTHGLOBE_ENABLED"] = true})
    addOption(p.scroll.scrollchild, RAID_USE_CLASS_COLORS, nil, "player_CLASS_COLOR", nil, nil, {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true})
    addOption(p.scroll.scrollchild, L["Show an additional resource bar"], nil, "PLAYER_AS_TARGET_FRAME_SHOW_RESSOURCEBAR", nil, nil, {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true, ["POWERBAR_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["PvP Indicator"], nil, "PLAYER_SHOW_PVP_INDICATOR", nil, nil, {["HEALTHGLOBE_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Energy/Mana Ticker"], nil, "PLAYER_ENERGY_MANA_TICK", nil, nil, {["POWERBAR_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Show Energy/Mana Ticker only in combat"], nil, "PLAYER_ENERGY_MANA_TICK_HIDE_OFC", nil, nil, {["POWERBAR_ENABLED"] = true, ["PLAYER_ENERGY_MANA_TICK"] = true})
    addOption(p.scroll.scrollchild, L["5 secound rule: display remaning time"], nil, "PLAYER_5SR_TIMER", nil, nil, {["POWERBAR_ENABLED"] = true, ["PLAYER_ENERGY_MANA_TICK"] = true})
    addOption(p.scroll.scrollchild, PET .. ": " .. L["Display Portrait Damage"], L["Display Portrait Damage on this frame"], "PET_FLOATING_COMBAT_TEXT", nil, nil, {["PETBAR_ENABLED"] = true})
    addOption(p.scroll.scrollchild, PET .. ": " .. L["Show auras below"], nil, "PET_AURAS_UNDER", nil, nil, {["PETBAR_ENABLED"] = true})
    addOptionSlider(
        p.scroll.scrollchild,
        L["Auras per row"],
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
        p.scroll.scrollchild,
        L["Buff size"],
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
        p.scroll.scrollchild,
        L["Debuff size"],
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
        p.scroll.scrollchild,
        L["Player Buff Growth Direction"],
        nil,
        "PlayerBuffFrame_GrowDirection",
        GW.UpdateHudScale(),
        {"UP", "DOWN", "UPR", "DOWNR"},
        {
            StrUpper(L["Up"], 1, 1),
            StrUpper(L["Down"], 1, 1),
            L["Up and Right"],
            L["Down and Right"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Player Debuffs Growth Direction"],
        nil,
        "PlayerDebuffFrame_GrowDirection",
        GW.UpdateHudScale(),
        {"UP", "DOWN", "UPR", "DOWNR"},
        {
            StrUpper(L["Up"], 1, 1),
            StrUpper(L["Down"], 1, 1),
            L["Up and Right"],
            L["Down and Right"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "PLAYER_UNIT_HEALTH",
        nil,
        {"NONE", "PREC", "VALUE", "BOTH"},
        {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )
    --addOptionDropdown(
    --    p.scroll.scrollchild,
    --    L["Show Shield Value"],
    --    nil,
    --    "PLAYER_UNIT_ABSORB",
    --    nil,
    --    {"NONE", "PREC", "VALUE", "BOTH"},
    --    {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH},
    --    nil,
    --    {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = false}
    --)

    addOptionDropdown(
        p.scroll.scrollchild,
        L["Class Totems Sorting"],
        nil,
        "TotemBar_SortDirection",
        nil,
        {"ASC", "DSC"},
        {L["Ascending"], L["Descending"]},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Class Totems Growth Direction"],
        nil,
        "TotemBar_GrowDirection",
        nil,
        {"HORIZONTAL", "VERTICAL"},
        {L["Horizontal"], L["Vertical"]},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )
    addOptionText(p.scroll.scrollchild,
        L["Dodge Bar Ability"],
        L["Enter the spell ID which should be tracked by the dodge bar.\nIf no ID is entered, the default abilities based on your specialization and talents are tracked."],
        "PLAYER_TRACKED_DODGEBAR_SPELL",
        function(self)
            local spellId = self:GetNumber()
            local name = ""
            if spellId > 0 and IsSpellKnown(spellId) then
                name = GetSpellInfo(spellId)
            end
            self:SetText(name)
            GW.SetSetting("PLAYER_TRACKED_DODGEBAR_SPELL", name)
            GW.SetSetting("PLAYER_TRACKED_DODGEBAR_SPELL_ID", spellId)
            GW.initDodgebarSpell(GwDodgeBar)
            GW.setDodgebarSpell(GwDodgeBar)
        end,
        nil,
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )

    InitPanel(p, true)
end
GW.LoadPlayerPanel = LoadPlayerPanel
