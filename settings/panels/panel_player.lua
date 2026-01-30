local _, GW = ...
local L = GW.L
local StrUpper = GW.StrUpper

local function LoadPlayerPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local p_player = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_player.panelId = "player_general"
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

    local p_player_aura = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_player_aura.panelId = "player_aura"
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

    local p_player_debuff = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_player_debuff.panelId = "player_debuff"
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

    local fader = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    fader.panelId = "player_fader"
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

    local classpower = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    classpower.panelId = "player_classpower"
    classpower.header:SetFont(DAMAGE_TEXT_FONT, 20)
    classpower.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    classpower.header:SetText(PLAYER)
    classpower.sub:SetFont(UNIT_NAME_FONT, 12)
    classpower.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    classpower.sub:SetText("")
    classpower.header:SetWidth(fader.header:GetStringWidth())
    classpower.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    classpower.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    classpower.breadcrumb:SetText(L["Class Power"])

    p_player:AddOption(L["Player frame in target frame style"], nil, {getterSetter = "PLAYER_AS_TARGET_FRAME", callback = function() GW.ShowRlPopup = true end, dependence = {["HEALTHGLOBE_ENABLED"] = true}})
    p_player:AddOption(L["Show alternative background texture"], nil, {getterSetter = "PLAYER_AS_TARGET_FRAME_ALT_BACKGROUND", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOption(L["Show absorb bar"], nil, {getterSetter = "PLAYER_SHOW_ABSORB_BAR", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}, hidden = GW.Classic or GW.TBC})

    p_player:AddOption(RAID_USE_CLASS_COLORS, nil, {getterSetter = "player_CLASS_COLOR", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOption(L["PvP Indicator"], nil, {getterSetter = "PLAYER_SHOW_PVP_INDICATOR", dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player:AddOption(L["Show spell queue window on castingbar"], nil, {getterSetter = "PLAYER_CASTBAR_SHOW_SPELL_QUEUEWINDOW", dependence = {["CASTINGBAR_ENABLED"] = true, ["CASTINGBAR_DATA"] = true}})
    p_player:AddOption(L["Show character item info"], L["Display gems and enchants on the GW2 character panel"], {getterSetter = "SHOW_CHARACTER_ITEM_INFO", callback = function() if not (GW.Classic or GW.TBC) then GW.ToggleCharacterItemInfo() end end, dependence = {["USE_CHARACTER_WINDOW"] = true}})
    p_player:AddOption(L["Shorten health values"], nil, {getterSetter = "PLAYER_UNIT_HEALTH_SHORT_VALUES", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true}, hidden = GW.Classic or GW.TBC})
    p_player:AddOption(L["Shorten shield values"], nil, {getterSetter = "PLAYER_UNIT_SHIELD_SHORT_VALUES", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true}, hidden = GW.Classic or GW.TBC or GW.Retail})
    p_player:AddOption(L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], {getterSetter = "CASTINGBAR_DATA", callback = function(value) GW.TogglePlayerEnhancedCastbar(GwCastingBarPlayer, value); GW.TogglePlayerEnhancedCastbar(GwCastingBarPet, value); end, dependence = {["CASTINGBAR_ENABLED"] = true}})
    p_player:AddOption(L["Ticks"], L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."], {getterSetter = "showPlayerCastBarTicks", dependence = {["CASTINGBAR_ENABLED"] = true}})
    p_player:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, { getterSetter = "PLAYER_UNIT_HEALTH", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = {"NONE", "PREC", "VALUE", "BOTH"}, optionNames = {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH}, dependence = {["HEALTHGLOBE_ENABLED"] = true}})

    local absorbSettingsList = {"NONE", "VALUE"}
    local absorbSettingsNames = {NONE, STATUS_TEXT_VALUE}
    if not GW.Retail then
        tinsert(absorbSettingsList, "PREC")
        tinsert(absorbSettingsList, STATUS_TEXT_PERCENT)
        tinsert(absorbSettingsNames, "BOTH")
        tinsert(absorbSettingsNames, STATUS_TEXT_BOTH)
    end

    p_player:AddOptionDropdown(L["Show Shield Value"], nil, { getterSetter = "PLAYER_UNIT_ABSORB", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = absorbSettingsList, optionNames = absorbSettingsNames, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = false}, hidden = GW.Classic or GW.TBC})

    p_player:AddOptionText(L["Dodge Bar Ability"], L["Enter the spell ID which should be tracked by the dodge bar.\nIf no ID is entered, the default abilities based on your specialization and talents are tracked."], { getterSetter = "PLAYER_TRACKED_DODGEBAR_SPELL", callback = function(self)
            local spellId = self:GetNumber()
            local name = ""
            if spellId > 0 and GW.IsSpellKnown(spellId) then
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


    p_player:AddGroupHeader(L["Size"])
    p_player:AddOptionSlider(L["Scale"], nil, { getterSetter = "player_pos_scale", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})

    p_player:AddOptionSlider(L["Healthbar Height"], nil, { getterSetter = "playerFrameHealthBarSize.height", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 5, max = 150, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOptionSlider(L["Healthbar Width"], nil, { getterSetter = "playerFrameHealthBarSize.width", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 50, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOptionSlider(L["Healthbar text x-offset"], nil, { getterSetter = "playerFrameHealthBarTextOffset.x", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOptionSlider(L["Healthbar text y-offset"], nil, { getterSetter = "playerFrameHealthBarTextOffset.y", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})

    p_player:AddOptionSlider(L["Powerbar Height"], nil, { getterSetter = "playerFramePowerBarSize.height", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 1, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOptionSlider(L["Powerbar Width"], nil, { getterSetter = "playerFramePowerBarSize.width", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 50, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOptionSlider(L["Powerbar text x-offset"], nil, { getterSetter = "playerFramePowerBarTextOffset.x", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOptionSlider(L["Powerbar text y-offset"], nil, { getterSetter = "playerFramePowerBarTextOffset.y", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})


    -- BUFF
    p_player_aura:AddOptionDropdown(L["Player Buff Growth Direction"], nil, { getterSetter = "PlayerBuffs.GrowDirection", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, optionsList = {"UP", "DOWN", "UPR", "DOWNR"}, optionNames = {StrUpper(L["Up"], 1, 1), StrUpper(L["Down"], 1, 1), L["Up and right"], L["Down and right"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_aura:AddOptionDropdown(L["Sort Method"], L["Defines how the group is sorted."], { getterSetter = "PlayerBuffs.SortMethod", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, optionsList = {"INDEX", "TIME", "NAME"}, optionNames = {L["Index"], L["Time"], NAME}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_aura:AddOptionDropdown(L["Sort Direction"], L["Defines the sort order of the selected sort method."], { getterSetter = "PlayerBuffs.SortDir", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, optionsList = {"+", "-"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_aura:AddOptionDropdown(L["Seperate"], L["Indicate whether buffs you cast yourself should be separated before or after."], { getterSetter = "PlayerBuffs.Seperate", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, optionsList = {-1, 0, 1}, optionNames = {L["Other's First"], L["No Sorting"], L["Your Auras First"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_aura:AddOptionSlider(L["Auras per row"], nil, { getterSetter = "PlayerBuffs.WrapAfter", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 1, max = 20, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_aura:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "PlayerBuffs.HorizontalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = -20, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_aura:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "PlayerBuffs.VerticalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 0, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_aura:AddOptionSlider(L["Max Wraps"], nil, { getterSetter = "PlayerBuffs.MaxWraps", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 1, max = 32, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_aura:AddOptionSlider(L["Size"], nil, { getterSetter = "PlayerBuffs.IconSize", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_aura:AddOptionSlider(L["Height"], nil, { getterSetter = "PlayerBuffs.IconHeight", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true, ["PlayerBuffs.KeepSizeRatio"] = false}})
    p_player_aura:AddOption(L["Keep Size Ratio"], nil, {getterSetter = "PlayerBuffs.KeepSizeRatio", callback = function(value) local widget = GW.FindSettingsWidgetByOption("PlayerBuffs.IconSize"); widget.title:SetText(value == true and L["Size"] or L["Width"]); GW.UpdateAuraHeader(GW2UIPlayerBuffs) end,dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_aura:AddOption(ANIMATION, L["Shows an animation for new de/buffs"], {getterSetter = "PlayerBuffs.NewAuraAnimation", dependence = {["PLAYER_BUFFS_ENABLED"] = true}, hidden = GW.Retail})

    -- DEBUFF
    p_player_debuff:AddOptionDropdown(L["Player Debuffs Growth Direction"], nil, { getterSetter = "PlayerDebuffs.GrowDirection", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame") end, optionsList = {"UP", "DOWN", "UPR", "DOWNR"}, optionNames = {StrUpper(L["Up"], 1, 1), StrUpper(L["Down"], 1, 1), L["Up and right"], L["Down and right"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_debuff:AddOptionDropdown(L["Sort Method"], L["Defines how the group is sorted."], { getterSetter = "PlayerDebuffs.SortMethod", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, optionsList = {"INDEX", "TIME", "NAME"}, optionNames = {L["Index"], L["Time"], NAME}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_debuff:AddOptionDropdown(L["Sort Direction"], L["Defines the sort order of the selected sort method."], { getterSetter = "PlayerDebuffs.SortDir", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, optionsList = {"+", "-"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_debuff:AddOptionDropdown(L["Seperate"], L["Indicate whether buffs you cast yourself should be separated before or after."], { getterSetter = "PlayerDebuffs.Seperate", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, optionsList = {-1, 0, 1}, optionNames = {L["Other's First"], L["No Sorting"], L["Your Auras First"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_debuff:AddOptionSlider(L["Auras per row"], nil, { getterSetter = "PlayerDebuffs.WrapAfter", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 1, max = 20, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_debuff:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "PlayerDebuffs.HorizontalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = -20, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_debuff:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "PlayerDebuffs.VerticalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 0, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_debuff:AddOptionSlider(L["Max Wraps"], nil, { getterSetter = "PlayerDebuffs.MaxWraps", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 1, max = 32, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_debuff:AddOptionSlider(L["Size"], nil, { getterSetter = "PlayerDebuffs.IconSize", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_debuff:AddOptionSlider(L["Height"], nil, { getterSetter = "PlayerDebuffs.IconHeight", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true, ["PlayerDebuffs.KeepSizeRatio"] = false}})
    p_player_debuff:AddOption(L["Keep Size Ratio"], nil, {getterSetter = "PlayerDebuffs.KeepSizeRatio", callback = function(value) local widget = GW.FindSettingsWidgetByOption("PlayerDebuffs.IconSize"); widget.title:SetText(value == true and L["Size"] or L["Width"]); GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, dependence = {["PLAYER_BUFFS_ENABLED"] = true}})
    p_player_debuff:AddOption(ANIMATION, L["Shows an animation for new de/buffs"], {getterSetter = "PlayerDebuffs.NewAuraAnimation", dependence = {["PLAYER_BUFFS_ENABLED"] = true}, hidden = GW.Retail})


    -- FADER
    fader:AddGroupHeader(L["Fader"])
    fader:AddOptionDropdown(L["Fader"], nil, { getterSetter = "playerFrameFader", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], TARGET}, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    fader:AddOptionSlider(L["Smooth"], nil, { getterSetter = "playerFrameFader.smooth", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    fader:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "playerFrameFader.minAlpha", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    fader:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "playerFrameFader.maxAlpha", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})


    -- Classpower
    classpower:AddOption(L["Show value on bar"], nil, {getterSetter = "CLASSPOWER_SHOW_VALUE", callback = function() GW.UpdateClasspowerSetting(GwPlayerClassPower); GwPlayerPowerBar:ToggleSettings(); if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["CLASS_POWER"] = true}, hidden = GW.Classic or GW.TBC})
    classpower:AddOption(L["Anchor classpower bar to center"], nil, {getterSetter = "CLASSPOWER_ANCHOR_TO_CENTER", callback = function() GW.UpdateClasspowerSetting(GwPlayerClassPower) end, dependence = {["CLASS_POWER"] = true}, hidden = GW.Classic or GW.TBC})
    classpower:AddOption(L["Show classpower bar only in combat"], nil, {getterSetter = "CLASSPOWER_ONLY_SHOW_IN_COMBAT", callback = function() GW.UpdateClassPowerVisibilitySetting(GwPlayerClassPower, true) end, dependence = {["CLASS_POWER"] = true}, hidden = GW.Classic or GW.TBC})
    classpower:AddOption(L["Energy/Mana Ticker"], L["5 second rule: display remaining time"], {getterSetter = "PLAYER_ENERGY_MANA_TICK", PLAYER_ENERGY_MANA_TICK_HIDE_OFC = GW.Update5SrHot,  dependence = {["POWERBAR_ENABLED"] = true}, hidden = GW.Retail or GW.Mists})
    classpower:AddOption(L["Show Energy/Mana Ticker only in combat"], nil, {getterSetter = "PLAYER_ENERGY_MANA_TICK", callback = GW.Update5SrHot,  dependence = {["POWERBAR_ENABLED"] = true, ["PLAYER_ENERGY_MANA_TICK"] = true}, hidden = GW.Retail or GW.Mists})
    classpower:AddOption(L["Show an additional resource bar"], nil, {getterSetter = "PLAYER_AS_TARGET_FRAME_SHOW_RESSOURCEBAR", callback = function() GwPlayerPowerBar:ToggleBar(); GW.UpdateClassPowerExtraManabar() end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true, ["POWERBAR_ENABLED"] = true}})


    sWindow:AddSettingsPanel(p, PLAYER, L["Modify the player frame settings."], {{name = GENERAL, frame = p_player}, {name = L["Buffs"], frame = p_player_aura}, {name = L["Debuffs"], frame = p_player_debuff}, {name = L["Fader"], frame = fader}, {name = L["Class Power"], frame = classpower}})
end
GW.LoadPlayerPanel = LoadPlayerPanel
