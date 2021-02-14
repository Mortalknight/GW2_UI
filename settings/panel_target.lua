local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel

local function LoadTargetPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local p_target = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_target:SetHeight(350)
    p_target:ClearAllPoints()
    p_target:SetPoint("TOPLEFT", p, "TOPLEFT", 0, 0)
    p_target.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_target.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p_target.header:SetText(TARGET)
    p_target.sub:SetFont(UNIT_NAME_FONT, 12)
    p_target.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_target.sub:SetText(L["Modify the target frame settings."])

    local p_focus = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_focus:SetHeight(250)
    p_focus:ClearAllPoints()
    p_focus:SetPoint("TOPLEFT", p_target, "BOTTOMLEFT", 0, 0)
    p_focus.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_focus.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p_focus.header:SetText(FOCUS)
    p_focus.sub:SetFont(UNIT_NAME_FONT, 12)
    p_focus.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_focus.sub:SetText(L["Modify the focus frame settings."])

    createCat(TARGET, L["Edit the target frame settings."], p, 1)

    addOption(p_target, SHOW_TARGET_OF_TARGET_TEXT, L["Enable the target of target frame."], "target_TARGET_ENABLED", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], "target_HEALTH_VALUE_ENABLED", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], "target_HEALTH_VALUE_TYPE", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, CLASS_COLORS, L["Display the class color as the health bar."], "target_CLASS_COLOR", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, SHOW_DEBUFFS, L["Display the target's debuffs that you have inflicted."], "target_DEBUFFS", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, SHOW_ALL_ENEMY_DEBUFFS_TEXT, L["Display all of the target's debuffs."], "target_BUFFS_FILTER_ALL", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, SHOW_BUFFS, L["Display the target's buffs."], "target_BUFFS", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, L["Display Average Item Level"], L["Display the average item level instead of prestige level for friendly units."], "target_SHOW_ILVL", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, L["Show Threat"], L["Show Threat"], "target_THREAT_VALUE_ENABLED", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, L["Show Combo Points on Target"], L["Show combo points on target, below the health bar."], "target_HOOK_COMBOPOINTS", nil, nil,{["TARGET_ENABLED"] = true})
    addOption(p_target, L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], "target_CASTINGBAR_DATA", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, BUFFS_ON_TOP, nil, "target_AURAS_ON_TOP", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, L["Display Portrait Damage"], L["Display Portrait Damage on this frame"], "target_FLOATING_COMBAT_TEXT", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_target, L["Invert target frame"], nil, "target_FRAME_INVERT", nil, nil, {["TARGET_ENABLED"] = true})
    addOption(p_focus, MINIMAP_TRACKING_FOCUS, L["Display the focus target frame."], "focus_TARGET_ENABLED", nil, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], "focus_HEALTH_VALUE_ENABLED", nil, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus, RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], "focus_HEALTH_VALUE_TYPE", nil, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus, CLASS_COLORS, L["Display the class color as the health bar."], "focus_CLASS_COLOR", nil, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus, SHOW_DEBUFFS, L["Display the target's debuffs that you have inflicted."], "focus_DEBUFFS", nil, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus, SHOW_ALL_ENEMY_DEBUFFS_TEXT, L["Display all of the target's debuffs."], "focus_BUFFS_FILTER_ALL", nil, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus, SHOW_BUFFS, L["Display the target's buffs."], "focus_BUFFS", nil, nil, {["FOCUS_ENABLED"] = true})
    addOption(p_focus, L["Invert focus frame"], nil, "focus_FRAME_INVERT", nil, nil, {["FOCUS_ENABLED"] = true})

    InitPanel(p_target)
    InitPanel(p_focus)
end
GW.LoadTargetPanel = LoadTargetPanel
