local _, GW = ...
local L = GW.L

local function LoadTargetPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local pPlayerPet = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    pPlayerPet.panelId = "player_pet"
    pPlayerPet.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pPlayerPet.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    pPlayerPet.header:SetText(UNITFRAME_LABEL)
    pPlayerPet.sub:SetFont(UNIT_NAME_FONT, 12)
    pPlayerPet.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pPlayerPet.sub:SetText(L["Modify the player pet frame settings."])
    pPlayerPet.header:SetWidth(pPlayerPet.header:GetStringWidth())
    pPlayerPet.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    pPlayerPet.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    pPlayerPet.breadcrumb:SetText(PET)

    local p_target = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_target.panelId = "target_general"
    p_target.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_target.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_target.header:SetText(UNITFRAME_LABEL)
    p_target.sub:SetFont(UNIT_NAME_FONT, 12)
    p_target.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_target.sub:SetText(L["Modify the target frame settings."])
    p_target.header:SetWidth(p_target.header:GetStringWidth())
    p_target.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_target.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_target.breadcrumb:SetText(TARGET)

    local pTargetOfTarget = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    pTargetOfTarget.panelId = "target_of_target"
    pTargetOfTarget.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pTargetOfTarget.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    pTargetOfTarget.header:SetText(UNITFRAME_LABEL)
    pTargetOfTarget.sub:SetFont(UNIT_NAME_FONT, 12)
    pTargetOfTarget.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pTargetOfTarget.sub:SetText(L["Modify the target of target frame settings."])
    pTargetOfTarget.header:SetWidth(pTargetOfTarget.header:GetStringWidth())
    pTargetOfTarget.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    pTargetOfTarget.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    pTargetOfTarget.breadcrumb:SetText(SHOW_TARGET_OF_TARGET_TEXT)

    local p_focus = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_focus.panelId = "focus_general"
    p_focus.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_focus.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_focus.header:SetText(UNITFRAME_LABEL)
    p_focus.sub:SetFont(UNIT_NAME_FONT, 12)
    p_focus.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_focus.sub:SetText(L["Modify the focus frame settings."])
    p_focus.header:SetWidth(p_focus.header:GetStringWidth())
    p_focus.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_focus.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_focus.breadcrumb:SetText(FOCUS)

    local pTargetOfFocus = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    pTargetOfFocus.panelId = "target_of_focus"
    pTargetOfFocus.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pTargetOfFocus.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    pTargetOfFocus.header:SetText(UNITFRAME_LABEL)
    pTargetOfFocus.sub:SetFont(UNIT_NAME_FONT, 12)
    pTargetOfFocus.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pTargetOfFocus.sub:SetText(L["Modify the target of focus frame settings."])
    pTargetOfFocus.header:SetWidth(pTargetOfFocus.header:GetStringWidth())
    pTargetOfFocus.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    pTargetOfFocus.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    pTargetOfFocus.breadcrumb:SetText(L["Focus target"])

    local panels = {
        {name = PET, frame = pPlayerPet},
        {name = TARGET, frame = p_target},
        {name = SHOW_TARGET_OF_TARGET_TEXT, frame = pTargetOfTarget},
    }

    if not GW.Classic then
        table.insert(panels, {name = FOCUS, frame = p_focus})
        table.insert(panels, {name = L["Focus target"], frame = pTargetOfFocus})
    end

    local buffOptions = {"all", "advanced", "none"}
    local buffOptionNames = {ALL, L["Advanced Filtering"], NONE}
    local debuffOptions = {"all", "player", "advanced", "none"}
    local debuffOptionNames = {ALL, PLAYER, L["Advanced Filtering"], NONE}
    local advancedAuraOptions = {"isAuraPlayer", "isAuraRaid", "isAuraCancelable", "notAuraCancelable"}
    local advancedAuraOptionsNames = {PLAYER, RAID, L["Is Cancelable"], L["Not Cancelable"]}

    if GW.Retail then
        tinsert(advancedAuraOptions, "isAuraDefensive")
        tinsert(advancedAuraOptionsNames, EXTERNAL_DEFENSIVES_LABEL)
        tinsert(advancedAuraOptions, "isAuraImportant")
        tinsert(advancedAuraOptionsNames, MAP_LEGEND_IMPORTANT)
        tinsert(advancedAuraOptions, "isAuraCrowdControl")
        tinsert(advancedAuraOptionsNames, L["Crowd Control"])
        tinsert(advancedAuraOptions, "isAuraBigDefensive")
        tinsert(advancedAuraOptionsNames, L["Big Defensive"])
        tinsert(advancedAuraOptions, "isAuraRaidInCombat")
        tinsert(advancedAuraOptionsNames, RAID_FRAMES_LABEL)
        tinsert(advancedAuraOptions, "isAuraRaidPlayerDispellable")
        tinsert(advancedAuraOptionsNames, COMPACT_UNIT_FRAME_PROFILE_DISPELLABLE_INDICATOR_TYPE_ME)
    else
        tinsert(debuffOptions, 2, "importent")
        tinsert(debuffOptionNames, 2, L["Dungeon & Raid Debuffs"])
    end

    --PET
    pPlayerPet:AddOption(L["Display Portrait Damage"], L["Display Portrait Damage on this frame"], {getterSetter = "PET_FLOATING_COMBAT_TEXT", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleCombatFeedback() end end, dependence = {["PETBAR_ENABLED"] = true}})
    pPlayerPet:AddOption(L["Show auras below"], nil, {getterSetter = "PET_AURAS_UNDER", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleAuraPosition() end end, dependence = {["PETBAR_ENABLED"] = true}})
    pPlayerPet:AddOption(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], {getterSetter = "PET_HEALTH_VALUE_RAW", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateSettings() end end, dependence = {["PETBAR_ENABLED"] = true}, hidden = GW.Classic or GW.TBC})
    pPlayerPet:AddOption(RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], {getterSetter = "PET_HEALTH_VALUE_PERCENT", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateSettings() end end, dependence = {["PETBAR_ENABLED"] = true}, hidden = GW.Classic or GW.TBC})
    pPlayerPet:AddOption(L["Shorten health values"], nil, {getterSetter = "PET_UNIT_HEALTH_SHORT_VALUES", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateSettings() end end, dependence = {["PETBAR_ENABLED"] = true}, hidden = not GW.Retail})
    pPlayerPet:AddOption(L["Show absorb bar"], nil, {getterSetter = "PET_SHOW_ABSORB_BAR", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateSettings() end end, dependence = {["PETBAR_ENABLED"] = true}, hidden = GW.Classic or GW.TBC})

    pPlayerPet:AddGroupHeader(L["Fader"])
    pPlayerPet:AddOptionDropdown(L["Fader"], nil, { getterSetter = "petFrameFader", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["PETBAR_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    pPlayerPet:AddOptionSlider(L["Smooth"], nil, { getterSetter = "petFrameFader.smooth", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["PETBAR_ENABLED"] = true}})
    pPlayerPet:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "petFrameFader.minAlpha", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["PETBAR_ENABLED"] = true}})
    pPlayerPet:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "petFrameFader.maxAlpha", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["PETBAR_ENABLED"] = true}})

    pPlayerPet:AddGroupHeader(L["Size"])
    pPlayerPet:AddOptionSlider(L["Scale"], nil, { getterSetter = "pet_pos_scale", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateSettings() end end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence =  {["PETBAR_ENABLED"] = true}})


    --TARGET
    p_target:AddOption(SHOW_ENEMY_CAST, nil, {getterSetter = "target_SHOW_CASTBAR", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOption(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], {getterSetter = "target_HEALTH_VALUE_ENABLED", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOption(RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], {getterSetter = "target_HEALTH_VALUE_TYPE", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOption(L["Shorten health values"], nil, {getterSetter = "target_SHORT_VALUES", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}, hidden = not GW.Retail})
    p_target:AddOption(CLASS_COLORS, L["Display the class color as the health bar."], {getterSetter = "target_CLASS_COLOR", callback = function() GwTargetUnitFrame:ToggleSettings(); GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOption(L["Show Threat"], L["Show Threat"], {getterSetter = "target_THREAT_VALUE_ENABLED", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOption(L["Show Combo Points on Target"], L["Show combo points on target, below the health bar."], {getterSetter = "target_HOOK_COMBOPOINTS", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOption(L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], {getterSetter = "target_CASTINGBAR_DATA", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOption(L["Display Portrait Damage"], L["Display Portrait Damage on this frame"], {getterSetter = "target_FLOATING_COMBAT_TEXT", callback = function() GwTargetUnitFrame:ToggleTargetFrameCombatFeedback() end, dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOption(L["Invert target frame"], nil, {getterSetter = "target_FRAME_INVERT", callback = function() GW.ShowRlPopup = true end, dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOption(L["Show alternative background texture"], nil, {getterSetter = "target_FRAME_ALT_BACKGROUND", callback = function() GwTargetUnitFrame:ToggleSettings(); GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOption(L["Show absorb bar"], nil, {getterSetter = "target_SHOW_ABSORB_BAR", callback = function() GwTargetUnitFrame:ToggleSettings(); GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}, hidden = GW.Classic or GW.TBC})
    p_target:AddOptionDropdown(L["Display additional information (ilvl, pvp level)"], L["Display the average item level, prestige level for friendly units or disable it."], { getterSetter = "target_ILVL", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = {"ITEM_LEVEL", "PVP_LEVEL", "NONE"}, optionNames = {STAT_AVERAGE_ITEM_LEVEL, L["PvP Level"], NONE}, dependence = {["TARGET_ENABLED"] = true}, hidden = GW.Classic})

    p_target:AddGroupHeader(AURAS)
    p_target:AddOption(BUFFS_ON_TOP, nil, {getterSetter = "target_AURAS_ON_TOP", callback = function() GwTargetUnitFrame:ToggleSettings() end, groupHeaderName = AURAS, dependence = {["TARGET_ENABLED"] = true}})

    p_target:AddOptionDropdown(L["Buffs"], L["Display the target's buffs."], { getterSetter = "target_Buff_Filter", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = buffOptions, optionNames = buffOptionNames, dependence = {["TARGET_ENABLED"] = true}, groupHeaderName = AURAS})
    p_target:AddOptionDropdown(L["Buffs: Advanced Filtering"], nil, { getterSetter = "target_Buff_Filter_advanced",
        callback = function() GwTargetUnitFrame:ToggleSettings() end,
        optionsList = advancedAuraOptions,
        optionNames = advancedAuraOptionsNames,
        dependence = {["TARGET_ENABLED"] = true, ["target_Buff_Filter"] = {"advanced"}},
        checkbox = true,
        groupHeaderName = AURAS,
        hidden = not GW.Retail}
    )

    p_target:AddOptionDropdown(L["Debuffs"], L["Display the target's debuffs."], { getterSetter = "target_Debuff_Filter", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = debuffOptions, optionNames = debuffOptionNames, dependence = {["TARGET_ENABLED"] = true}, groupHeaderName = AURAS})
    p_target:AddOptionDropdown(L["Debuffs: Advanced Filtering"], nil, { getterSetter = "target_Debuff_Filter_advanced",
        callback = function() GwTargetUnitFrame:ToggleSettings() end,
        optionsList = advancedAuraOptions,
        optionNames = advancedAuraOptionsNames,
        dependence = {["TARGET_ENABLED"] = true, ["target_Debuff_Filter"] = {"advanced"}},
        checkbox = true,
        groupHeaderName = AURAS,
        hidden = not GW.Retail}
    )

    p_target:AddGroupHeader(L["Fader"])
    p_target:AddOptionDropdown(L["Fader"], nil, { getterSetter = "targetFrameFader", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["TARGET_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    p_target:AddOptionSlider(L["Smooth"], nil, { getterSetter = "targetFrameFader.smooth", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["TARGET_ENABLED"] = true}})
    p_target:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "targetFrameFader.minAlpha", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["TARGET_ENABLED"] = true}})
    p_target:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "targetFrameFader.maxAlpha", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["TARGET_ENABLED"] = true}})

    p_target:AddGroupHeader(L["Size"])
    p_target:AddOptionSlider(L["Scale"], nil, { getterSetter = "target_pos_scale", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence =  {["TARGET_ENABLED"] = true}})

    p_target:AddOptionSlider(GW.NewSign .. L["Bar Width"], nil, { getterSetter = "targetFrameHealthBarSize.width", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 150, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOptionSlider(GW.NewSign .. L["Healthbar Height"], nil, { getterSetter = "targetFrameHealthBarSize.height", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 5, max = 150, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOptionSlider(GW.NewSign .. L["Healthbar Text X-Offset"], nil, { getterSetter = "targetFrameHealthBarTextOffset.x", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["TARGET_ENABLED"] = true}})
    p_target:AddOptionSlider(GW.NewSign .. L["Healthbar Text Y-Offset"], nil, { getterSetter = "targetFrameHealthBarTextOffset.y", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["TARGET_ENABLED"] = true}})    
    p_target:AddOptionSlider(GW.NewSign .. L["Powerbar Height"], nil, { getterSetter = "targetFramePowerBarSize.height", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 1, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["TARGET_ENABLED"] = true}})


    --TARGET OF TARGET
    pTargetOfTarget:AddOption(SHOW_TARGET_OF_TARGET_TEXT, L["Enable the target of target frame."], {getterSetter = "target_TARGET_ENABLED", callback = function() GwTargetTargetUnitFrame:ToggleUnitFrame() end, dependence = {["TARGET_ENABLED"] = true}})
    pTargetOfTarget:AddOption(SHOW_ENEMY_CAST, nil, {getterSetter = "target_TARGET_SHOW_CASTBAR", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})
    pTargetOfTarget:AddOption(L["Show absorb bar"], nil, {getterSetter = "target_TARGET_SHOW_ABSORB_BAR", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}, hidden = GW.Classic or GW.TBC})

    pTargetOfTarget:AddGroupHeader(L["Fader"])
    pTargetOfTarget:AddOptionDropdown(L["Fader"], nil, { getterSetter = "targettargetFrameFader", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    pTargetOfTarget:AddOptionSlider(L["Smooth"], nil, { getterSetter = "targettargetFrameFader.smooth", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})
    pTargetOfTarget:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "targettargetFrameFader.minAlpha", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})
    pTargetOfTarget:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "targettargetFrameFader.maxAlpha", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})

    pTargetOfTarget:AddGroupHeader(L["Size"])
    pTargetOfTarget:AddOptionSlider(L["Scale"], nil, { getterSetter = "targettarget_pos_scale", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})
    pTargetOfTarget:AddOptionSlider(GW.NewSign .. L["Bar Width"], nil, { getterSetter = "targettargetFrameHealthBarSize.width", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 50, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})
    pTargetOfTarget:AddOptionSlider(GW.NewSign .. L["Healthbar Height"], nil, { getterSetter = "targettargetFrameHealthBarSize.height", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 5, max = 150, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})
    pTargetOfTarget:AddOptionSlider(GW.NewSign .. L["Powerbar Height"], nil, { getterSetter = "targettargetFramePowerBarSize.height", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 1, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})

    --FOCUS
    p_focus:AddOption(SHOW_ENEMY_CAST, nil, {getterSetter = "focus_SHOW_CASTBAR", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    p_focus:AddOption(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], {getterSetter = "focus_HEALTH_VALUE_ENABLED", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    p_focus:AddOption(RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], {getterSetter = "focus_HEALTH_VALUE_TYPE", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    p_focus:AddOption(L["Shorten health values"], nil, {getterSetter = "focus_SHORT_VALUES", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    p_focus:AddOption(CLASS_COLORS, L["Display the class color as the health bar."], {getterSetter = "focus_CLASS_COLOR", callback = function() GwFocusUnitFrame:ToggleSettings(); GwFocusTargetUnitFrame:ToggleUnitFrame() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    p_focus:AddOption(L["Invert focus frame"], nil, {getterSetter = "focus_FRAME_INVERT", callback = function() GW.ShowRlPopup = true end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    p_focus:AddOption(L["Show alternative background texture"], nil, {getterSetter = "focus_FRAME_ALT_BACKGROUND", callback = function() GwFocusUnitFrame:ToggleSettings(); GwFocusTargetUnitFrame:ToggleUnitFrame() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    p_focus:AddOption(L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], {getterSetter = "focus_CASTINGBAR_DATA", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    p_focus:AddOption(L["Show absorb bar"], nil, {getterSetter = "focus_SHOW_ABSORB_BAR", callback = function() GwFocusUnitFrame:ToggleSettings(); GwFocusTargetUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic or GW.TBC})

    p_focus:AddOptionDropdown(L["Display additional information (ilvl, pvp level)"], L["Display the average item level, prestige level for friendly units or disable it."], { getterSetter = "focus_ILVL", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = {"ITEM_LEVEL", "PVP_LEVEL", "NONE"}, optionNames = {STAT_AVERAGE_ITEM_LEVEL, L["PvP Level"], NONE}, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic })

    p_focus:AddGroupHeader(AURAS)
    p_focus:AddOption(BUFFS_ON_TOP, nil, {getterSetter = "focus_AURAS_ON_TOP", callback = function() GwFocusUnitFrame:ToggleSettings() end, groupHeaderName = AURAS, dependence = {["FOCUS_ENABLED"] = true}})

    p_focus:AddOptionDropdown(L["Buffs"], L["Display the focus's buffs."], { getterSetter = "focus_Buff_Filter", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = buffOptions, optionNames = buffOptionNames, dependence = {["FOCUS_ENABLED"] = true}, groupHeaderName = AURAS})
    p_focus:AddOptionDropdown(L["Buffs: Advanced Filtering"], nil, { getterSetter = "focus_Buff_Filter_advanced",
        callback = function() GwFocusUnitFrame:ToggleSettings() end,
        optionsList = advancedAuraOptions,
        optionNames = advancedAuraOptionsNames,
        dependence = {["FOCUS_ENABLED"] = true, ["focus_Buff_Filter"] = {"advanced"}},
        checkbox = true,
        groupHeaderName = AURAS,
        hidden = not GW.Retail}
    )

    p_focus:AddOptionDropdown(L["Debuffs"], L["Display the focus's debuffs."], { getterSetter = "focus_Debuff_Filter", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = debuffOptions, optionNames = debuffOptionNames, dependence = {["FOCUS_ENABLED"] = true}, groupHeaderName = AURAS})
    p_focus:AddOptionDropdown(L["Debuffs: Advanced Filtering"], nil, { getterSetter = "focus_Debuff_Filter_advanced",
        callback = function() GwFocusUnitFrame:ToggleSettings() end,
        optionsList = advancedAuraOptions,
        optionNames = advancedAuraOptionsNames,
        dependence = {["FOCUS_ENABLED"] = true, ["focus_Debuff_Filter"] = {"advanced"}},
        checkbox = true,
        groupHeaderName = AURAS,
        hidden = not GW.Retail}
    )

    p_focus:AddGroupHeader(L["Fader"], {hidden = GW.Classic})
    p_focus:AddOptionDropdown(L["Fader"], nil, { getterSetter = "focusFrameFader", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["FOCUS_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"], hidden = GW.Classic})
    p_focus:AddOptionSlider(L["Smooth"], nil, { getterSetter = "focusFrameFader.smooth", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    p_focus:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "focusFrameFader.minAlpha", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    p_focus:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "focusFrameFader.maxAlpha", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})

    p_focus:AddGroupHeader(L["Size"])
    p_focus:AddOptionSlider(L["Scale"], nil, { getterSetter = "focus_pos_scale", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence =  {["FOCUS_ENABLED"] = true}})
    p_focus:AddOptionSlider(GW.NewSign .. L["Bar Width"], nil, { getterSetter = "focusFrameHealthBarSize.width", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 150, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["FOCUS_ENABLED"] = true}})
    p_focus:AddOptionSlider(GW.NewSign .. L["Healthbar Height"], nil, { getterSetter = "focusFrameHealthBarSize.height", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 5, max = 150, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["FOCUS_ENABLED"] = true}})
    p_focus:AddOptionSlider(GW.NewSign .. L["Healthbar Text X-Offset"], nil, { getterSetter = "focusFrameHealthBarTextOffset.x", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["FOCUS_ENABLED"] = true}})
    p_focus:AddOptionSlider(GW.NewSign .. L["Healthbar Text Y-Offset"], nil, { getterSetter = "focusFrameHealthBarTextOffset.y", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["FOCUS_ENABLED"] = true}})
    p_focus:AddOptionSlider(GW.NewSign .. L["Powerbar Height"], nil, { getterSetter = "focusFramePowerBarSize.height", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 1, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["FOCUS_ENABLED"] = true}})
    --TARGET OF FOCUS
    pTargetOfFocus:AddOption(MINIMAP_TRACKING_FOCUS, L["Display the focus target frame."], {getterSetter = "focus_TARGET_ENABLED", callback = function() GwFocusTargetUnitFrame:ToggleUnitFrame() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    pTargetOfFocus:AddOption(SHOW_ENEMY_CAST, nil, {getterSetter = "focus_TARGET_SHOW_CASTBAR", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, hidden = GW.Classic})
    pTargetOfFocus:AddOption(L["Show absorb bar"], nil, {getterSetter = "focus_TARGET_SHOW_ABSORB_BAR", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, hidden = GW.Classic or GW.TBC})

    pTargetOfFocus:AddGroupHeader(L["Fader"], {hidden = GW.Classic})
    pTargetOfFocus:AddOptionDropdown(L["Fader"], nil, { getterSetter = "focustargetFrameFader", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, UNIT_TARGET, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"], hidden = GW.Classic})
    pTargetOfFocus:AddOptionSlider(L["Smooth"], nil, { getterSetter = "focusFrameFader.smooth", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, hidden = GW.Classic})
    pTargetOfFocus:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "focusFrameFader.minAlpha", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, hidden = GW.Classic})
    pTargetOfFocus:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "focusFrameFader.maxAlpha", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, hidden = GW.Classic})

    pTargetOfFocus:AddGroupHeader(L["Size"])
    pTargetOfFocus:AddOptionSlider(L["Scale"], nil, { getterSetter = "focustarget_pos_scale", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}})
    pTargetOfFocus:AddOptionSlider(GW.NewSign .. L["Bar Width"], nil, { getterSetter = "focustargetFrameHealthBarSize.width", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 50, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}})
    pTargetOfFocus:AddOptionSlider(GW.NewSign .. L["Healthbar Height"], nil, { getterSetter = "focustargetFrameHealthBarSize.height", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 5, max = 150, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}})
    pTargetOfFocus:AddOptionSlider(GW.NewSign .. L["Powerbar Height"], nil, { getterSetter = "focustargetFramePowerBarSize.height", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 1, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}})

    sWindow:AddSettingsPanel(p, UNITFRAME_LABEL, L["Modify the player pet frame settings."], panels)
end
GW.LoadTargetPanel = LoadTargetPanel
