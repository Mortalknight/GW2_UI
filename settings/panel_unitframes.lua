local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addGroupHeader = GW.AddGroupHeader
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel

local function LoadTargetPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local pPlayerPet = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
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

    local p_target = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
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

    local pTargetOfTarget = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
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

    local p_focus = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
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

    local pTargetOfFocus = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
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

    createCat(UNITFRAME_LABEL, L["Edit the target frame settings."], p, {pPlayerPet, p_target, pTargetOfTarget, not GW.Classic and p_focus or nil, not GW.Classic and pTargetOfFocus or nil}, true)

    --PET
    addOption(pPlayerPet.scroll.scrollchild, L["Display Portrait Damage"], L["Display Portrait Damage on this frame"], {getterSetter = "PET_FLOATING_COMBAT_TEXT", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleCombatFeedback() end end, dependence = {["PETBAR_ENABLED"] = true}})
    addOption(pPlayerPet.scroll.scrollchild, L["Show auras below"], nil, {getterSetter = "PET_AURAS_UNDER", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleAuraPosition() end end, dependence = {["PETBAR_ENABLED"] = true}})
    addOption(pPlayerPet.scroll.scrollchild, GW.NewSign .. L["Shorten health values"], nil, {getterSetter = "PET_UNIT_HEALTH_SHORT_VALUES", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateHealthBar() end end, dependence = {["PETBAR_ENABLED"] = true}, hidden = not GW.Retail})


    addGroupHeader(pPlayerPet.scroll.scrollchild, L["Fader"])
    addOptionDropdown(pPlayerPet.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "petFrameFader", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["PETBAR_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(pPlayerPet.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "petFrameFader.smooth", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["PETBAR_ENABLED"] = true}})
    addOptionSlider(pPlayerPet.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "petFrameFader.minAlpha", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["PETBAR_ENABLED"] = true}})
    addOptionSlider(pPlayerPet.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "petFrameFader.maxAlpha", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["PETBAR_ENABLED"] = true}})

    --TARGET
    addOption(p_target.scroll.scrollchild, SHOW_ENEMY_CAST, nil, {getterSetter = "target_SHOW_CASTBAR", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], {getterSetter = "target_HEALTH_VALUE_ENABLED", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], {getterSetter = "target_HEALTH_VALUE_TYPE", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, GW.NewSign .. L["Shorten health values"], nil, {getterSetter = "target_SHORT_VALUES", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}, hidden = not GW.Retail})
    addOption(p_target.scroll.scrollchild, CLASS_COLORS, L["Display the class color as the health bar."], {getterSetter = "target_CLASS_COLOR", callback = function() GwTargetUnitFrame:ToggleSettings(); GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, SHOW_DEBUFFS, L["Display the target's debuffs that you have inflicted."], {getterSetter = "target_DEBUFFS", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "target_BUFFS_FILTER_IMPORTANT", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true, ["target_DEBUFFS"] = true}})
    addOption(p_target.scroll.scrollchild, SHOW_ALL_ENEMY_DEBUFFS_TEXT, L["Display all of the target's debuffs."], {getterSetter = "target_BUFFS_FILTER_ALL", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true, ["target_DEBUFFS"] = true, ["target_BUFFS_FILTER_IMPORTANT"] = false}})
    addOption(p_target.scroll.scrollchild, SHOW_BUFFS, L["Display the target's buffs."], {getterSetter = "target_BUFFS", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, L["Show Threat"], L["Show Threat"], {getterSetter = "target_THREAT_VALUE_ENABLED", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, L["Show Combo Points on Target"], L["Show combo points on target, below the health bar."], {getterSetter = "target_HOOK_COMBOPOINTS", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], {getterSetter = "target_CASTINGBAR_DATA", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, BUFFS_ON_TOP, nil, {getterSetter = "target_AURAS_ON_TOP", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, L["Display Portrait Damage"], L["Display Portrait Damage on this frame"], {getterSetter = "target_FLOATING_COMBAT_TEXT", callback = function() GwTargetUnitFrame:ToggleTargetFrameCombatFeedback() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, L["Invert target frame"], nil, {getterSetter = "target_FRAME_INVERT", callback = function() GW.ShowRlPopup = true end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(p_target.scroll.scrollchild, L["Show alternative background texture"], nil, {getterSetter = "target_FRAME_ALT_BACKGROUND", callback = function() GwTargetUnitFrame:ToggleSettings(); GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true}})

    addOptionDropdown(p_target.scroll.scrollchild, L["Display additional information (ilvl, pvp level)"], L["Display the average item level, prestige level for friendly units or disable it."], { getterSetter = "target_ILVL", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = {"ITEM_LEVEL", "PVP_LEVEL", "NONE"}, optionNames = {STAT_AVERAGE_ITEM_LEVEL, L["PvP Level"], NONE}, dependence = {["TARGET_ENABLED"] = true}, hidden = GW.Classic})

    addGroupHeader(p_target.scroll.scrollchild, L["Fader"])
    addOptionDropdown(p_target.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "targetFrameFader", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["TARGET_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(p_target.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "targetFrameFader.smooth", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["TARGET_ENABLED"] = true}})
    addOptionSlider(p_target.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "targetFrameFader.minAlpha", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["TARGET_ENABLED"] = true}})
    addOptionSlider(p_target.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "targetFrameFader.maxAlpha", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["TARGET_ENABLED"] = true}})

    --TARGET OF TARGET
    addOption(pTargetOfTarget.scroll.scrollchild, SHOW_TARGET_OF_TARGET_TEXT, L["Enable the target of target frame."], {getterSetter = "target_TARGET_ENABLED", callback = function() GwTargetTargetUnitFrame:ToggleUnitFrame() end, dependence = {["TARGET_ENABLED"] = true}})
    addOption(pTargetOfTarget.scroll.scrollchild, SHOW_ENEMY_CAST, nil, {getterSetter = "target_TARGET_SHOW_CASTBAR", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})


    addGroupHeader(pTargetOfTarget.scroll.scrollchild, L["Fader"])
    addOptionDropdown(pTargetOfTarget.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "targettargetFrameFader", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(pTargetOfTarget.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "targettargetFrameFader.smooth", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})
    addOptionSlider(pTargetOfTarget.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "targettargetFrameFader.minAlpha", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})
    addOptionSlider(pTargetOfTarget.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "targettargetFrameFader.maxAlpha", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})

    --FOCUS
    addOption(p_focus.scroll.scrollchild, SHOW_ENEMY_CAST, nil, {getterSetter = "focus_SHOW_CASTBAR", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], {getterSetter = "focus_HEALTH_VALUE_ENABLED", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], {getterSetter = "focus_HEALTH_VALUE_TYPE", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, GW.NewSign .. L["Shorten health values"], nil, {getterSetter = "focus_SHORT_VALUES", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, CLASS_COLORS, L["Display the class color as the health bar."], {getterSetter = "focus_CLASS_COLOR", callback = function() GwFocusUnitFrame:ToggleSettings(); GwFocusTargetUnitFrame:ToggleUnitFrame() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, SHOW_DEBUFFS, L["Display the target's debuffs that you have inflicted."], {getterSetter = "focus_DEBUFFS", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "focus_BUFFS_FILTER_IMPORTANT", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true, ["focus_DEBUFFS"] = true}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, SHOW_ALL_ENEMY_DEBUFFS_TEXT, L["Display all of the target's debuffs."], {getterSetter = "focus_BUFFS_FILTER_ALL", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true, ["focus_DEBUFFS"] = true, ["focus_BUFFS_FILTER_IMPORTANT"] = false}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, SHOW_BUFFS, L["Display the target's buffs."], {getterSetter = "focus_BUFFS", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, BUFFS_ON_TOP, nil, {getterSetter = "focus_AURAS_ON_TOP", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, L["Invert focus frame"], nil, {getterSetter = "focus_FRAME_INVERT", callback = function() GW.ShowRlPopup = true end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, L["Show alternative background texture"], nil, {getterSetter = "focus_FRAME_ALT_BACKGROUND", callback = function() GwFocusUnitFrame:ToggleSettings(); GwFocusTargetUnitFrame:ToggleUnitFrame() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOption(p_focus.scroll.scrollchild, L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], {getterSetter = "focus_CASTINGBAR_DATA", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})

    addOptionDropdown(p_focus.scroll.scrollchild, L["Display additional information (ilvl, pvp level)"], L["Display the average item level, prestige level for friendly units or disable it."], { getterSetter = "focus_ILVL", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = {"ITEM_LEVEL", "PVP_LEVEL", "NONE"}, optionNames = {STAT_AVERAGE_ITEM_LEVEL, L["PvP Level"], NONE}, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})

    addGroupHeader(p_focus.scroll.scrollchild, L["Fader"], {hidden = GW.Classic})
    addOptionDropdown(p_focus.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "focusFrameFader", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["FOCUS_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"], hidden = GW.Classic})
    addOptionSlider(p_focus.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "focusFrameFader.smooth", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOptionSlider(p_focus.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "focusFrameFader.minAlpha", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOptionSlider(p_focus.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "focusFrameFader.maxAlpha", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})

    --TARGET OF FOCUS
    addOption(pTargetOfFocus.scroll.scrollchild, MINIMAP_TRACKING_FOCUS, L["Display the focus target frame."], {getterSetter = "focus_TARGET_ENABLED", callback = function() GwFocusTargetUnitFrame:ToggleUnitFrame() end, dependence = {["FOCUS_ENABLED"] = true}, hidden = GW.Classic})
    addOption(pTargetOfFocus.scroll.scrollchild, SHOW_ENEMY_CAST, nil, {getterSetter = "focus_TARGET_SHOW_CASTBAR", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, hidden = GW.Classic})

    addGroupHeader(pTargetOfFocus.scroll.scrollchild, L["Fader"], {hidden = GW.Classic})
    addOptionDropdown(pTargetOfFocus.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "focustargetFrameFader", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, UNIT_TARGET, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"], hidden = GW.Classic})
    addOptionSlider(pTargetOfFocus.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "focusFrameFader.smooth", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, hidden = GW.Classic})
    addOptionSlider(pTargetOfFocus.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "focusFrameFader.minAlpha", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, hidden = GW.Classic})
    addOptionSlider(pTargetOfFocus.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "focusFrameFader.maxAlpha", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, hidden = GW.Classic})


    InitPanel(pPlayerPet, true)
    InitPanel(p_target, true)
    InitPanel(pTargetOfTarget, true)
    InitPanel(p_focus, true)
    InitPanel(pTargetOfFocus, true)
end
GW.LoadTargetPanel = LoadTargetPanel
