local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addGroupHeader = GW.AddGroupHeader
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton

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

    createCat(UNITFRAME_LABEL, L["Edit the target frame settings."], p, {pPlayerPet, p_target, pTargetOfTarget, p_focus, pTargetOfFocus})
    settingsMenuAddButton(UNITFRAME_LABEL, p, {pPlayerPet, p_target, pTargetOfTarget, p_focus, pTargetOfFocus})

    --PET
    addOption(pPlayerPet.scroll.scrollchild, L["Display Portrait Damage"], L["Display Portrait Damage on this frame"], "PET_FLOATING_COMBAT_TEXT", function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleCombatFeedback() end end, nil, {["PETBAR_ENABLED"] = true})
    addOption(pPlayerPet.scroll.scrollchild, L["Show auras below"], nil, "PET_AURAS_UNDER", function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleAuraPosition() end end, nil, {["PETBAR_ENABLED"] = true})
    addOption(pPlayerPet.scroll.scrollchild, GW.NewSign .. L["Shorten health values"], nil, "PET_UNIT_HEALTH_SHORT_VALUES", function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateHealthBar() end end, nil, {["PETBAR_ENABLED"] = true})

    addGroupHeader(pPlayerPet.scroll.scrollchild, L["Fader"])
    addOptionDropdown(pPlayerPet.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, {settingName = "petFrameFader", getterSetter = "petFrameFader", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, optionsList = {"casting", "combat", "hover", "dynamicflight"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT}, dependence = {["PETBAR_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(pPlayerPet.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, {settingName = "petFrameFaderSmooth", getterSetter = "petFrameFader.smooth", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["PETBAR_ENABLED"] = true}})
    addOptionSlider(pPlayerPet.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, {settingName = "petFrameFaderMinAlpha", getterSetter = "petFrameFader.minAlpha", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["PETBAR_ENABLED"] = true}})
    addOptionSlider(pPlayerPet.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, {settingName = "petFrameFaderMaxAlpha", getterSetter = "petFrameFader.maxAlpha", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["PETBAR_ENABLED"] = true}})

    --TARGET
    addOption(p_target.scroll.scrollchild, SHOW_ENEMY_CAST, nil, "target_SHOW_CASTBAR", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], "target_HEALTH_VALUE_ENABLED", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], "target_HEALTH_VALUE_TYPE", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, GW.NewSign .. L["Shorten health values"], nil, "target_SHORT_VALUES", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, CLASS_COLORS, L["Display the class color as the health bar."], "target_CLASS_COLOR", function() GwTargetUnitFrame:ToggleSettings(); GwTargetTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, SHOW_DEBUFFS, L["Display the target's debuffs that you have inflicted."], "target_DEBUFFS", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "target_BUFFS_FILTER_IMPORTANT", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true, ["target_DEBUFFS"] = true})
    addOption(p_target.scroll.scrollchild, SHOW_ALL_ENEMY_DEBUFFS_TEXT, L["Display all of the target's debuffs."], "target_BUFFS_FILTER_ALL", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true, ["target_DEBUFFS"] = true})
    addOption(p_target.scroll.scrollchild, SHOW_BUFFS, L["Display the target's buffs."], "target_BUFFS", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, L["Show Threat"], L["Show Threat"], "target_THREAT_VALUE_ENABLED", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, L["Show Combo Points on Target"], L["Show combo points on target, below the health bar."], "target_HOOK_COMBOPOINTS", function() GwTargetUnitFrame:ToggleSettings() end, nil,{["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], "target_CASTINGBAR_DATA", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, BUFFS_ON_TOP, nil, "target_AURAS_ON_TOP", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, L["Display Portrait Damage"], L["Display Portrait Damage on this frame"], "target_FLOATING_COMBAT_TEXT", function() GwTargetUnitFrame:ToggleTargetFrameCombatFeedback() end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, L["Invert target frame"], nil, "target_FRAME_INVERT", function() GW.ShowRlPopup = true end, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target.scroll.scrollchild, L["Show alternative background texture"], nil, "target_FRAME_ALT_BACKGROUND", function() GwTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true})
    addOptionDropdown(p_target.scroll.scrollchild, L["Display additional information (ilvl, pvp level)"], L["Display the average item level, prestige level for friendly units or disable it."], {settingName = "target_ILVL", getterSetter = "target_ILVL", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = {"ITEM_LEVEL", "PVP_LEVEL", "NONE"}, optionNames = {STAT_AVERAGE_ITEM_LEVEL, L["PvP Level"], NONE}, dependence = {["TARGET_ENABLED"] = true}})

    addGroupHeader(p_target.scroll.scrollchild, L["Fader"])
    addOptionDropdown(p_target.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, {settingName = "targetFrameFader", getterSetter = "targetFrameFader", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT}, dependence = {["TARGET_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(p_target.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, {settingName = "targetFrameFaderSmooth", getterSetter = "targetFrameFader.smooth", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["TARGET_ENABLED"] = true}})
    addOptionSlider(p_target.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, {settingName = "targetFrameFaderMinAlpha", getterSetter = "targetFrameFader.minAlpha", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["TARGET_ENABLED"] = true}})
    addOptionSlider(p_target.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, {settingName = "targetFrameFaderMaxAlpha", getterSetter = "targetFrameFader.maxAlpha", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["TARGET_ENABLED"] = true}})

    --TARGET OF TARGET
    addOption(pTargetOfTarget.scroll.scrollchild, SHOW_TARGET_OF_TARGET_TEXT, L["Enable the target of target frame."], "target_TARGET_ENABLED", function() GwTargetTargetUnitFrame:ToggleUnitFrame() end, nil, {["TARGET_ENABLED"] = true})
    addOption(pTargetOfTarget.scroll.scrollchild, SHOW_ENEMY_CAST, nil, "target_TARGET_SHOW_CASTBAR", function() GwTargetTargetUnitFrame:ToggleSettings() end, nil, {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true})

    addGroupHeader(pTargetOfTarget.scroll.scrollchild, L["Fader"])
    addOptionDropdown(pTargetOfTarget.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, {settingName = "targettargetFrameFader", getterSetter = "targettargetFrameFader", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT}, dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(pTargetOfTarget.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, {settingName = "targettargetFrameFaderSmooth", getterSetter = "targettargetFrameFader.smooth", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})
    addOptionSlider(pTargetOfTarget.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, {settingName = "targettargetFrameFaderMinApha", getterSetter = "targettargetFrameFader.minAlpha", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})
    addOptionSlider(pTargetOfTarget.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, {settingName = "targettargetFrameFaderMaxAlpha", getterSetter = "targettargetFrameFader.maxAlpha", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["TARGET_ENABLED"] = true, ["target_TARGET_ENABLED"] = true}})


    --FOCUS
    addOption(p_focus.scroll.scrollchild, SHOW_ENEMY_CAST, nil, "focus_SHOW_CASTBAR", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus.scroll.scrollchild, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], "focus_HEALTH_VALUE_ENABLED", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus.scroll.scrollchild, RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], "focus_HEALTH_VALUE_TYPE", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus.scroll.scrollchild, GW.NewSign .. L["Shorten health values"], nil, "focus_SHORT_VALUES", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus.scroll.scrollchild, CLASS_COLORS, L["Display the class color as the health bar."], "focus_CLASS_COLOR", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus.scroll.scrollchild, SHOW_DEBUFFS, L["Display the target's debuffs that you have inflicted."], "focus_DEBUFFS", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "focus_BUFFS_FILTER_IMPORTANT", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true, ["focus_DEBUFFS"] = true})
    addOption(p_focus.scroll.scrollchild, SHOW_ALL_ENEMY_DEBUFFS_TEXT, L["Display all of the target's debuffs."], "focus_BUFFS_FILTER_ALL", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true, ["focus_DEBUFFS"] = true})
    addOption(p_focus.scroll.scrollchild, SHOW_BUFFS, L["Display the target's buffs."], "focus_BUFFS", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus.scroll.scrollchild, BUFFS_ON_TOP, nil, "focus_AURAS_ON_TOP", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus.scroll.scrollchild, L["Invert focus frame"], nil, "focus_FRAME_INVERT", function() GW.ShowRlPopup = true end, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus.scroll.scrollchild, L["Show alternative background texture"], nil, "focus_FRAME_ALT_BACKGROUND", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus.scroll.scrollchild, L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], "focus_CASTINGBAR_DATA", function() GwFocusUnitFrame:ToggleSettings() end, nil, {["FOCUS_ENABLED"] = true})
    addOptionDropdown(p_focus.scroll.scrollchild, L["Display additional information (ilvl, pvp level)"], L["Display the average item level, prestige level for friendly units or disable it."], {settingName = "focus_ILVL", getterSetter = "focus_ILVL", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = {"ITEM_LEVEL", "PVP_LEVEL", "NONE"}, optionNames = {STAT_AVERAGE_ITEM_LEVEL, L["PvP Level"], NONE}, dependence = {["FOCUS_ENABLED"] = true}})

    addGroupHeader(p_focus.scroll.scrollchild, L["Fader"])
    addOptionDropdown(p_focus.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, {settingName = "focusFrameFader", getterSetter = "focusFrameFader", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT}, dependence = {["FOCUS_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(p_focus.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, {settingName = "focusFrameFaderSmooth", getterSetter = "focusFrameFader.smooth", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true}})
    addOptionSlider(p_focus.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, {settingName = "focusFrameFaderMinAlpha", getterSetter = "focusFrameFader.minAlpha", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true}})
    addOptionSlider(p_focus.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, {settingName = "focusFrameFaderMaxAlpha", getterSetter = "focusFrameFader.maxAlpha", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true}})

    --TARGET OF FOCUS
    addOption(pTargetOfFocus.scroll.scrollchild, MINIMAP_TRACKING_FOCUS, L["Display the focus target frame."], "focus_TARGET_ENABLED", function() GwFocusTargetUnitFrame:ToggleUnitFrame() end, nil, {["FOCUS_ENABLED"] = true})
    addOption(pTargetOfFocus.scroll.scrollchild, SHOW_ENEMY_CAST, nil, "focus_TARGET_SHOW_CASTBAR", function() GwFocusTargetUnitFrame:ToggleSettings() end , nil, {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true})

    addGroupHeader(pTargetOfFocus.scroll.scrollchild, L["Fader"])
    addOptionDropdown(pTargetOfFocus.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, {settingName = "focustargetFrameFader", getterSetter = "focustargetFrameFader", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT}, dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(pTargetOfFocus.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, {settingName = "focustargetFrameFaderSmooth", getterSetter = "focusFrameFader.smooth", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}})
    addOptionSlider(pTargetOfFocus.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, {settingName = "focustargetFrameFaderMinAlpha", getterSetter = "focusFrameFader.minAlpha", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}})
    addOptionSlider(pTargetOfFocus.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, {settingName = "focustargetFrameFaderMaxAlpha", getterSetter = "focusFrameFader.maxAlpha", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["FOCUS_ENABLED"] = true, ["focus_TARGET_ENABLED"] = true}})


    InitPanel(pPlayerPet, true)
    InitPanel(p_target, true)
    InitPanel(pTargetOfTarget, true)
    InitPanel(p_focus, true)
    InitPanel(pTargetOfFocus, true)
end
GW.LoadTargetPanel = LoadTargetPanel
