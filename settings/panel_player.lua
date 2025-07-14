local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local addOptionText = GW.AddOptionText
local addGroupHeader = GW.AddGroupHeader
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local StrUpper = GW.StrUpper

local function LoadPlayerPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local p_player = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    p_player.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_player.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_player.header:SetText(PLAYER)
    p_player.sub:SetFont(UNIT_NAME_FONT, 12)
    p_player.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_player.sub:SetText(L["Modify the player frame settings."])
    p_player.header:SetWidth(p_player.header:GetStringWidth())
    p_player.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_player.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_player.breadcrumb:SetText(GENERAL)

    local p_player_aura = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    p_player_aura.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_player_aura.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_player_aura.header:SetText(PLAYER)
    p_player_aura.header:SetWidth(p_player_aura.header:GetStringWidth())
    p_player_aura.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_player_aura.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_player_aura.breadcrumb:SetText(L["Buffs"])
    p_player_aura.sub:SetFont(UNIT_NAME_FONT, 12)
    p_player_aura.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_player_aura.sub:SetText("")

    local p_player_debuff = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    p_player_debuff.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_player_debuff.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_player_debuff.header:SetText(PLAYER)
    p_player_debuff.sub:SetFont(UNIT_NAME_FONT, 12)
    p_player_debuff.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_player_debuff.sub:SetText("")
    p_player_debuff.header:SetWidth(p_player_debuff.header:GetStringWidth())
    p_player_debuff.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_player_debuff.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_player_debuff.breadcrumb:SetText(L["Debuffs"])

    local fader = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    fader.header:SetFont(DAMAGE_TEXT_FONT, 20)
    fader.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    fader.header:SetText(PLAYER)
    fader.sub:SetFont(UNIT_NAME_FONT, 12)
    fader.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    fader.sub:SetText("")
    fader.header:SetWidth(fader.header:GetStringWidth())
    fader.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    fader.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    fader.breadcrumb:SetText(L["Fader"])

    createCat(PLAYER, L["Modify the player frame settings."], p, {p_player, p_player_aura, p_player_debuff, fader}, true)

    addOption(p_player.scroll.scrollchild, L["Player frame in target frame style"], nil, {getterSetter = "PLAYER_AS_TARGET_FRAME", callback = function() GW.ShowRlPopup = true end, dependence = {["HEALTHGLOBE_ENABLED"] = true}})
    addOption(p_player.scroll.scrollchild, L["Show alternative background texture"], nil, {getterSetter = "PLAYER_AS_TARGET_FRAME_ALT_BACKGROUND", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    addOption(p_player.scroll.scrollchild, L["Show absorb bar"], nil, {getterSetter = "PLAYER_SHOW_ABSORB_BAR", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}, hidden = not GW.Retail})

    addOption(p_player.scroll.scrollchild, L["Extend Ressourcebar size"], nil, {getterSetter = "PlayerTargetFrameExtendRessourcebar", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    addOption(p_player.scroll.scrollchild, RAID_USE_CLASS_COLORS, nil, {getterSetter = "player_CLASS_COLOR", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    addOption(p_player.scroll.scrollchild, L["Show an additional resource bar"], nil, {getterSetter = "PLAYER_AS_TARGET_FRAME_SHOW_RESSOURCEBAR", callback = function() GwPlayerPowerBar:ToggleBar(); GW.UpdateClassPowerExtraManabar() end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true, ["POWERBAR_ENABLED"] = true}})
    addOption(p_player.scroll.scrollchild, L["PvP Indicator"], nil, {getterSetter = "PLAYER_SHOW_PVP_INDICATOR", dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOption(p_player.scroll.scrollchild, L["Energy/Mana Ticker"], nil, {getterSetter = "PLAYER_ENERGY_MANA_TICK", PLAYER_ENERGY_MANA_TICK_HIDE_OFC = GW.Update5SrHot,  dependence = {["POWERBAR_ENABLED"] = true}, hidden = GW.Retail})
    addOption(p_player.scroll.scrollchild, L["Show Energy/Mana Ticker only in combat"], nil, {getterSetter = "PLAYER_ENERGY_MANA_TICK", callback = GW.Update5SrHot,  dependence = {["POWERBAR_ENABLED"] = true, ["PLAYER_ENERGY_MANA_TICK"] = true}, hidden = GW.Retail})
    addOption(p_player.scroll.scrollchild, L["Player de/buff animation"], L["Shows an animation for new de/buffs"], {getterSetter = "PLAYER_AURA_ANIMATION", dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOption(p_player.scroll.scrollchild, L["Show spell queue window on castingbar"], nil, {getterSetter = "PLAYER_CASTBAR_SHOW_SPELL_QUEUEWINDOW", dependence = {["CASTINGBAR_ENABLED"] = true, ["CASTINGBAR_DATA"] = true}})
    addOption(p_player.scroll.scrollchild, L["Show character item info"], L["Display gems and enchants on the GW2 character panel"], {getterSetter = "SHOW_CHARACTER_ITEM_INFO", callback = function() if not GW.Classic then GW.ToggleCharacterItemInfo() end end, dependence = {["USE_CHARACTER_WINDOW"] = true}})
    addOption(p_player.scroll.scrollchild, L["Hide Blizzard dragon riding vigor"], nil, {getterSetter = "HIDE_BLIZZARD_VIGOR_BAR", dependence = {["HEALTHGLOBE_ENABLED"] = true}, hidden = not GW.Retail})
    addOption(p_player.scroll.scrollchild, L["Show classpower bar only in combat"], nil, {getterSetter = "CLASSPOWER_ONLY_SHOW_IN_COMBAT", callback = function() GW.UpdateClassPowerVisibilitySetting(GwPlayerClassPower, true) end, dependence = {["CLASS_POWER"] = true}, hidden = GW.Classic})
    addOption(p_player.scroll.scrollchild, L["Shorten health values"], nil, {getterSetter = "PLAYER_UNIT_HEALTH_SHORT_VALUES", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_player.scroll.scrollchild, L["Shorten shield values"], nil, {getterSetter = "PLAYER_UNIT_SHIELD_SHORT_VALUES", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_player.scroll.scrollchild, L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], {getterSetter = "CASTINGBAR_DATA", callback = function(value) GW.TogglePlayerEnhancedCastbar(GwCastingBarPlayer, value); GW.TogglePlayerEnhancedCastbar(GwCastingBarPet, value); end, dependence = {["CASTINGBAR_ENABLED"] = true}})
    addOption(p_player.scroll.scrollchild, L["Ticks"], L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."], {getterSetter = "showPlayerCastBarTicks", dependence = {["CASTINGBAR_ENABLED"] = true}})
    addOptionDropdown(p_player.scroll.scrollchild, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, { getterSetter = "PLAYER_UNIT_HEALTH", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = {"NONE", "PREC", "VALUE", "BOTH"}, optionNames = {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH}, dependence = {["HEALTHGLOBE_ENABLED"] = true}})
    addOptionDropdown(p_player.scroll.scrollchild, L["Show Shield Value"], nil, { getterSetter = "PLAYER_UNIT_ABSORB", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = {"NONE", "PREC", "VALUE", "BOTH"}, optionNames = {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH}, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = false}, hidde = GW.Classic})

    addOptionText(p_player.scroll.scrollchild, L["Dodge Bar Ability"], L["Enter the spell ID which should be tracked by the dodge bar.\nIf no ID is entered, the default abilities based on your specialization and talents are tracked."], { getterSetter = "PLAYER_TRACKED_DODGEBAR_SPELL", callback = function(self)
            local spellId = self:GetNumber()
            local name = ""
            if spellId > 0 and IsSpellKnown(spellId) then
                local spellInfo = C_Spell.GetSpellInfo(spellId)
                name = spellInfo.name
            end
            self:SetText(name)
            GW.private.PLAYER_TRACKED_DODGEBAR_SPELL = name
            GW.private.PLAYER_TRACKED_DODGEBAR_SPELL_ID = spellId
            if GwDodgeBar then
                GwDodgeBar:InitBar()
                GwDodgeBar:SetupBar()
            end
        end, dependence = {["HEALTHGLOBE_ENABLED"] = true}, isPrivateSetting = true})

    -- BUFF
    addOptionDropdown(p_player_aura.scroll.scrollchild, L["Player Buff Growth Direction"], nil, { getterSetter = "PlayerBuffFrame_GrowDirection", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame") end, optionsList = {"UP", "DOWN", "UPR", "DOWNR"}, optionNames = {StrUpper(L["Up"], 1, 1), StrUpper(L["Down"], 1, 1), L["Up and right"], L["Down and right"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionDropdown(p_player_aura.scroll.scrollchild, L["Sort Method"], L["Defines how the group is sorted."], { getterSetter = "PlayerBuffFrame_SortMethod", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame") end, optionsList = {"INDEX", "TIME", "NAME"}, optionNames = {L["Index"], L["Time"], NAME}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionDropdown(p_player_aura.scroll.scrollchild, L["Sort Direction"], L["Defines the sort order of the selected sort method."], { getterSetter = "PlayerBuffFrame_SortDir", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame") end, optionsList = {"+", "-"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionDropdown(p_player_aura.scroll.scrollchild, L["Seperate"], L["Indicate whether buffs you cast yourself should be separated before or after."], { getterSetter = "PlayerBuffFrame_Seperate", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame") end, optionsList = {-1, 0, 1}, optionNames = {L["Other's First"], L["No Sorting"], L["Your Auras First"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionSlider(p_player_aura.scroll.scrollchild, L["Auras per row"], nil, { getterSetter = "PLAYER_AURA_WRAP_NUM", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame") end, min = 1, max = 20, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionSlider(p_player_aura.scroll.scrollchild, L["Horizontal Spacing"], nil, { getterSetter = "PlayerBuffFrame_HorizontalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame") end, min = -20, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionSlider(p_player_aura.scroll.scrollchild, L["Vertical Spacing"], nil, { getterSetter = "PlayerBuffFrame_VerticalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame") end, min = 0, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionSlider(p_player_aura.scroll.scrollchild, L["Max Wraps"], nil, { getterSetter = "PlayerBuffFrame_MaxWraps", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame") end, min = 1, max = 32, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionSlider(p_player_aura.scroll.scrollchild, L["Buff size"], nil, { getterSetter = "PlayerBuffFrame_ICON_SIZE", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs, "PlayerBuffFrame") end, min = 10, max = 60, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})

    -- DEBUFF
    addOptionDropdown(p_player_debuff.scroll.scrollchild,  L["Player Debuffs Growth Direction"], nil, { getterSetter = "PlayerDebuffFrame_GrowDirection", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame") end, optionsList = {"UP", "DOWN", "UPR", "DOWNR"}, optionNames = {StrUpper(L["Up"], 1, 1), StrUpper(L["Down"], 1, 1), L["Up and right"], L["Down and right"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionDropdown(p_player_debuff.scroll.scrollchild,  L["Sort Method"], L["Defines how the group is sorted."], { getterSetter = "PlayerDebuffFrame_SortMethod", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame") end, optionsList = {"INDEX", "TIME", "NAME"}, optionNames = {L["Index"], L["Time"], NAME}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionDropdown(p_player_debuff.scroll.scrollchild, L["Sort Direction"], L["Defines the sort order of the selected sort method."], { getterSetter = "PlayerDebuffFrame_SortDir", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame") end, optionsList = {"+", "-"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionDropdown(p_player_debuff.scroll.scrollchild, L["Seperate"], L["Indicate whether buffs you cast yourself should be separated before or after."], { getterSetter = "PlayerDebuffFrame_Seperate", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame") end, optionsList = {-1, 0, 1}, optionNames = {L["Other's First"], L["No Sorting"], L["Your Auras First"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})

    addOptionSlider(p_player_debuff.scroll.scrollchild, L["Auras per row"], nil, { getterSetter = "PLAYER_AURA_WRAP_NUM_DEBUFF", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame") end, min = 1, max = 20, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionSlider(p_player_debuff.scroll.scrollchild, L["Horizontal Spacing"], nil, { getterSetter = "PlayerDebuffFrame_HorizontalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame") end, min = 0, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionSlider(p_player_debuff.scroll.scrollchild, L["Vertical Spacing"], nil, { getterSetter = "PlayerDebuffFrame_VerticalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame") end, min = 0, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionSlider(p_player_debuff.scroll.scrollchild, L["Max Wraps"], nil, { getterSetter = "PlayerDebuffFrame_MaxWraps", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame") end, min = 1, max = 32, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    addOptionSlider(p_player_debuff.scroll.scrollchild, L["Debuff size"], nil, { getterSetter = "PlayerDebuffFrame_ICON_SIZE", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame") end, min = 10, max = 60, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})

    -- FADER
    addGroupHeader(fader.scroll.scrollchild, L["Fader"])
    addOptionDropdown(fader.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "playerFrameFader", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], TARGET}, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(fader.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "playerFrameFader.smooth", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    addOptionSlider(fader.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "playerFrameFader.minAlpha", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    addOptionSlider(fader.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "playerFrameFader.maxAlpha", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})

    InitPanel(p_player, true)
    InitPanel(p_player_aura, true)
    InitPanel(p_player_debuff, true)
    InitPanel(fader, true)
end
GW.LoadPlayerPanel = LoadPlayerPanel
