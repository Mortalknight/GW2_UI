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
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local p_player = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    p_player:SetHeight(250)
    p_player:SetWidth(512)
    p_player:ClearAllPoints()
    p_player:SetPoint("TOPLEFT", p, "TOPLEFT", 0, 5)
    p_player.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_player.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p_player.header:SetText(PLAYER)
    p_player.sub:SetFont(UNIT_NAME_FONT, 12)
    p_player.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_player.sub:SetText(L["Modify the player frame settings."])

    local p_player_aura = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    p_player_aura:SetHeight(190)
    p_player_aura:SetWidth(512)
    p_player_aura:ClearAllPoints()
    p_player_aura:SetPoint("TOPLEFT", p_player, "BOTTOMLEFT", 0, 0)
    p_player_aura.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_player_aura.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p_player_aura.header:SetText(L["Buffs"])
    p_player_aura.sub:SetFont(UNIT_NAME_FONT, 12)
    p_player_aura.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_player_aura.sub:SetText("")

    local p_player_debuff = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    p_player_debuff:SetHeight(190)
    p_player_debuff:SetWidth(512)
    p_player_debuff:ClearAllPoints()
    p_player_debuff:SetPoint("TOPLEFT", p_player_aura, "BOTTOMLEFT", 0, 0)
    p_player_debuff.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_player_debuff.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p_player_debuff.header:SetText(L["Debuffs"])
    p_player_debuff.sub:SetFont(UNIT_NAME_FONT, 12)
    p_player_debuff.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_player_debuff.sub:SetText("")

    createCat(PLAYER, L["Modify the player frame settings."], p, 9, nil, {p_player, p_player_aura, p_player_debuff})


    addOption(p_player.scroll.scrollchild, L["Player frame in target frame style"], nil, "PLAYER_AS_TARGET_FRAME", nil, nil, {["HEALTHGLOBE_ENABLED"] = true})
    addOption(p_player.scroll.scrollchild, RAID_USE_CLASS_COLORS, nil, "player_CLASS_COLOR", nil, nil, {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true})
    addOption(p_player.scroll.scrollchild, L["Show an additional resource bar"], nil, "PLAYER_AS_TARGET_FRAME_SHOW_RESSOURCEBAR", nil, nil, {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true, ["POWERBAR_ENABLED"] = true})
    addOption(p_player.scroll.scrollchild, L["PvP Indicator"], nil, "PLAYER_SHOW_PVP_INDICATOR", nil, nil, {["HEALTHGLOBE_ENABLED"] = true})
    addOption(p_player.scroll.scrollchild, L["Player de/buff animation"], L["Shows an animation for new de/buffs"], "PLAYER_AURA_ANIMATION", nil, nil, {["PLAYER_BUFFS_ENABLED"] = true})
    addOption(p_player.scroll.scrollchild, L["Energy/Mana Ticker"], nil, "PLAYER_ENERGY_MANA_TICK", nil, nil, {["POWERBAR_ENABLED"] = true})
    addOption(p_player.scroll.scrollchild, L["Show Energy/Mana Ticker only in combat"], nil, "PLAYER_ENERGY_MANA_TICK_HIDE_OFC", nil, nil, {["POWERBAR_ENABLED"] = true, ["PLAYER_ENERGY_MANA_TICK"] = true})
    addOption(p_player.scroll.scrollchild, L["5 secound rule: display remaning time"], nil, "PLAYER_5SR_TIMER", nil, nil, {["POWERBAR_ENABLED"] = true, ["PLAYER_ENERGY_MANA_TICK"] = true})
    addOption(p_player.scroll.scrollchild, L["Show spell queue window on castinbar"], nil, "PLAYER_CASTBAR_SHOW_SPELL_QUEUEWINDOW", nil, nil, {["CASTINGBAR_ENABLED"] = true})
    addOption(p_player.scroll.scrollchild, L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], "CASTINGBAR_DATA", nil, nil, {["CASTINGBAR_ENABLED"] = true})
    addOption(p_player.scroll.scrollchild, PET .. ": " .. L["Display Portrait Damage"], L["Display Portrait Damage on this frame"], "PET_FLOATING_COMBAT_TEXT", nil, nil, {["PETBAR_ENABLED"] = true})
    addOption(p_player.scroll.scrollchild, PET .. ": " .. L["Show auras below"], nil, "PET_AURAS_UNDER", nil, nil, {["PETBAR_ENABLED"] = true})
    addOptionDropdown(
        p_player.scroll.scrollchild,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "PLAYER_UNIT_HEALTH",
        nil,
        {"NONE", "PREC", "VALUE", "BOTH"},
        {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )
    addOptionDropdown(
        p_player.scroll.scrollchild,
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
        p_player.scroll.scrollchild,
        L["Class Totems Growth Direction"],
        nil,
        "TotemBar_GrowDirection",
        nil,
        {"HORIZONTAL", "VERTICAL"},
        {L["Horizontal"], L["Vertical"]},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )
    addOptionText(
        p_player.scroll.scrollchild,
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

     -- BUFF
     addOptionDropdown(
        p_player_aura.scroll.scrollchild,
        L["Player Buff Growth Direction"],
        nil,
        "PlayerBuffFrame_GrowDirection",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame")
        end,
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
        p_player_aura.scroll.scrollchild,
        L["Sort Method"],
        L["Defines how the group is sorted."],
        "PlayerBuffFrame_SortMethod",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame")
        end,
        {"INDEX", "TIME", "NAME"},
        {
            L["Index"],
            L["Time"],
            NAME
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionDropdown(
        p_player_aura.scroll.scrollchild,
        L["Sort Direction"],
        L["Defines the sort order of the selected sort method."],
        "PlayerBuffFrame_SortDir",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame")
        end,
        {"+", "-"},
        {
            L["Ascending"],
            L["Descending"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionDropdown(
        p_player_aura.scroll.scrollchild,
        L["Seperate"],
        L["Indicate whether buffs you cast yourself should be separated before or after."],
        "PlayerBuffFrame_Seperate",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame")
        end,
        {-1, 0, 1},
        {
            L["Other's First"],
            L["No Sorting"],
            L["Your Auras First"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionSlider(
        p_player_aura.scroll.scrollchild,
        L["Auras per row"],
        nil,
        "PLAYER_AURA_WRAP_NUM",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame")
        end,
        1,
        20,
        nil,
        0,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionSlider(
        p_player_aura.scroll.scrollchild,
        L["Buff size"],
        nil,
        "PlayerBuffFrame_ICON_SIZE",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame")
        end,
        16,
        60,
        nil,
        0,
        {["PLAYER_BUFFS_ENABLED"] = true},
        2
    )

    -- DEBUFF
    addOptionDropdown(
        p_player_debuff.scroll.scrollchild,
        L["Player Debuffs Growth Direction"],
        nil,
        "PlayerDebuffFrame_GrowDirection",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame")
        end,
        {"UP", "DOWN", "UPR", "DOWNR"},
        {
            StrUpper(L["Up"], 1, 1),
            StrUpper(L["Down"], 1, 1),
            L["Up and right"],
            L["Down and right"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionDropdown(
        p_player_debuff.scroll.scrollchild,
        L["Sort Method"],
        L["Defines how the group is sorted."],
        "PlayerDebuffFrame_SortMethod",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame")
        end,
        {"INDEX", "TIME", "NAME"},
        {
            L["Index"],
            L["Time"],
            NAME
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionDropdown(
        p_player_debuff.scroll.scrollchild,
        L["Sort Direction"],
        L["Defines the sort order of the selected sort method."],
        "PlayerDebuffFrame_SortDir",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame")
        end,
        {"+", "-"},
        {
            L["Ascending"],
            L["Descending"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionDropdown(
        p_player_debuff.scroll.scrollchild,
        L["Seperate"],
        L["Indicate whether buffs you cast yourself should be separated before or after."],
        "PlayerDebuffFrame_Seperate",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame")
        end,
        {-1, 0, 1},
        {
            L["Other's First"],
            L["No Sorting"],
            L["Your Auras First"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionSlider(
        p_player_debuff.scroll.scrollchild,
        L["Auras per row"],
        nil,
        "PLAYER_AURA_WRAP_NUM_DEBUFF",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame")
        end,
        1,
        20,
        nil,
        0,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionSlider(
        p_player_debuff.scroll.scrollchild,
        L["Debuff size"],
        nil,
        "PlayerDebuffFrame_ICON_SIZE",
        function()
            GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame")
        end,
        16,
        60,
        nil,
        0,
        {["PLAYER_BUFFS_ENABLED"] = true},
        2
    )

    InitPanel(p_player, true)
    InitPanel(p_player_aura, true)
    InitPanel(p_player_debuff, true)
end
GW.LoadPlayerPanel = LoadPlayerPanel
