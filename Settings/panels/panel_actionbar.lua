---@class GW2
local GW = select(2, ...)
local L = GW.L


local function LoadActionbarPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local general = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    general.panelId = "actionbar_general"
    general.header:SetFont(DAMAGE_TEXT_FONT, 20)
    general.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    general.header:SetText(BINDING_HEADER_ACTIONBAR)
    general.sub:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(ACTIONBARS_SUBTEXT)
    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    general.breadcrumb:SetText(GENERAL)

    local mainBar = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    mainBar.panelId = "actionbar_main"
    mainBar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    mainBar.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    mainBar.header:SetText(BINDING_HEADER_ACTIONBAR)
    mainBar.header:SetWidth(mainBar.header:GetStringWidth())
    mainBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    mainBar.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    mainBar.breadcrumb:SetText(L["Main Action Bar"])
    mainBar.sub:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    mainBar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    mainBar.sub:SetText(L["Edit the main action bar settings."])

    local extraBars = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    extraBars.panelId = "actionbar_extra"
    extraBars.header:SetFont(DAMAGE_TEXT_FONT, 20)
    extraBars.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    extraBars.header:SetText(BINDING_HEADER_ACTIONBAR)
    extraBars.sub:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    extraBars.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    extraBars.sub:SetText(L["Edit the multi action bar settings."])
    extraBars.header:SetWidth(extraBars.header:GetStringWidth())
    extraBars.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    extraBars.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    extraBars.breadcrumb:SetText(BINDING_HEADER_MULTIACTIONBAR)


    local stanceBar = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    stanceBar.panelId = "actionbar_stance"
    stanceBar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    stanceBar.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    stanceBar.header:SetText(BINDING_HEADER_ACTIONBAR)
    stanceBar.sub:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    stanceBar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    stanceBar.sub:SetText(L["Edit the stance bar settings."])
    stanceBar.header:SetWidth(stanceBar.header:GetStringWidth())
    stanceBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    stanceBar.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    stanceBar.breadcrumb:SetText(HUD_EDIT_MODE_STANCE_BAR_LABEL or L["Stance Bar"])

    -- GENERAL
    general:AddOption(ENABLE, L["Use the GW2 UI improved action bars."], {getterSetter = "actionbars.enabled", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Actionbars", isMasterToggle = true})
    general:AddOption(L["Automatic Bar Layout"], L["Enable or disable the automatic layout management of the primary action bars and associated frames (pet, buffs); required for auto bar fading and some other features"], { getterSetter = "actionbars.barLayout", callback = function() GW.ShowRlPopup = true end, dependence = {["actionbars.enabled"] = true}, incompatibleAddons = "Actionbars", hidden = not GW.isModern, group = "autoLayout"})
    general:AddOption(L["Add space for Healthglobe"], nil, { getterSetter = "actionbars.healthGlobeSpace", callback = function() GW.ShowRlPopup = true end, dependence = {["actionbars.enabled"] = true, ["actionbars.barLayout"] = false}, incompatibleAddons = "Actionbars", hidden = not GW.isModern, group = "autoLayout"})
    general:AddOption(L["Action Button Labels"], L["Enable or disable the action button assignment text"], { getterSetter = "actionbars.buttonAssignments", callback = function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons() end, dependence = {["actionbars.enabled"] = true}, incompatibleAddons = "Actionbars", group = "buttonText"})
    general:AddOption(GW.NewSign .. L["Action Button Labels only on used slots"], L["Shows the assignments only on used slots"], { getterSetter = "actionbars.buttonAssignmentsUsedOnly", callback = function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons() end, dependence = {["actionbars.enabled"] = true, ["actionbars.buttonAssignments"] = true}, incompatibleAddons = "Actionbars", group = "buttonText"})
    general:AddOption(L["Show Macro Name"], L["Show Macro Name on Action Button"], { getterSetter = "actionbars.showMacroNames", callback = function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons(); if GwPlayerPetFrame then GwPlayerPetFrame:UpdatePetBarButtons() end end, dependence = {["actionbars.enabled"] = true}, incompatibleAddons = "Actionbars", group = "buttonText"})

    general:AddOptionSlider(L["Empty slots alpha"], L["Set the empty action bar slots alpha value."], { getterSetter = "actionbars.backgroundAlpha", callback = function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons() end, min = 0, max = 1, decimalNumbers = 1, step = 0.1, dependence = {["actionbars.enabled"] = true}, group = "emptySlots"})
    general:AddOptionButton(L["Fix: Restore empty action bar slots"], L["Restores empty slots across all 8 action bars when they were hidden in Blizzard Edit Mode."], {callback = GW.MakeActionbuttonsVisible, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), forceNewLine = true, group = "emptySlots"})

    -- MAINBAR
    mainBar:AddOptionNote(format(L["The action bars are disabled entirely: enable them under %s."], BINDING_HEADER_ACTIONBAR .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.actionbars.enabled ~= true end,
        group = "actionbarPageNote",
    })
    mainBar:AddOptionNote(format(L["The automatic bar layout is disabled: position, visibility and columns of these bars are managed by Blizzard's Edit Mode. Enable '%s' under %s to manage them here."], L["Automatic Bar Layout"], BINDING_HEADER_ACTIONBAR .. " - " .. GENERAL), {
        isVisible = function() return GW.isModern and GW.settings.actionbars.enabled == true and GW.settings.actionbars.barLayout ~= true end,
        group = "actionbarPageNote",
    })
    mainBar:AddOptionSlider(L["Button Spacing"], nil, { getterSetter = "actionbars.mainbarMargin", callback = function() GW.UpdateMainBarHot() end, min = 0, max = 10, decimalNumbers = 1, step = 0.1, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), group = "buttonAppearance"})

    mainBar:AddOptionDropdown(L["Main Bar Range Indicator"], nil, { getterSetter = "actionbars.rangeIndicator", callback = GW.UpdateMainBarHot, optionsList = {"RED_INDICATOR", "RED_OVERLAY", "BOTH", "NONE"}, optionNames = {L["%s Indicator"]:format(RED_GEM), L["Red Overlay"], STATUS_TEXT_BOTH, NONE}, dependence = {["actionbars.enabled"] = true}, incompatibleAddons = "Actionbars", group = "buttonAppearance"})
    mainBar:AddOptionDropdown(BINDING_HEADER_ACTIONBAR .. SHOW, nil, { getterSetter = "actionbars.mainBar.fade", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), incompatibleAddons = "Actionbars", group = "barVisibility"})

    --EXTRABARS
    extraBars:AddOptionNote(format(L["The action bars are disabled entirely: enable them under %s."], BINDING_HEADER_ACTIONBAR .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.actionbars.enabled ~= true end,
        group = "actionbarPageNote",
    })
    extraBars:AddOptionNote(format(L["The automatic bar layout is disabled: position, visibility and columns of these bars are managed by Blizzard's Edit Mode. Enable '%s' under %s to manage them here."], L["Automatic Bar Layout"], BINDING_HEADER_ACTIONBAR .. " - " .. GENERAL), {
        isVisible = function() return GW.isModern and GW.settings.actionbars.enabled == true and GW.settings.actionbars.barLayout ~= true end,
        group = "actionbarPageNote",
    })
    extraBars:AddOptionSlider(L["Button Spacing"], nil, { getterSetter = "actionbars.multibarMargin", callback = function() GW.UpdateMultibarButtons() end, min = 0, max = 10, decimalNumbers = 1, step = 0.1, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)()})

    extraBars:AddGroupHeader(OPTION_SHOW_ACTION_BAR:format(2))
    extraBars:AddOptionDropdown(SHOW, nil, { getterSetter = "actionbars.bars.MultiBarBottomLeft.fade", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), groupHeaderName = OPTION_SHOW_ACTION_BAR:format(2), incompatibleAddons = "Actionbars"})
    extraBars:AddOption(L["Invert"], nil, { getterSetter = "actionbars.bars.MultiBarBottomLeft.invert", callback = GW.UpdateMultibarButtons, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), groupHeaderName = OPTION_SHOW_ACTION_BAR:format(2), incompatibleAddons = "Actionbars"})


    extraBars:AddGroupHeader(OPTION_SHOW_ACTION_BAR:format(3))
    extraBars:AddOptionDropdown(SHOW, nil, { getterSetter = "actionbars.bars.MultiBarBottomRight.fade", groupHeaderName = OPTION_SHOW_ACTION_BAR:format(3), optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), incompatibleAddons = "Actionbars"})
    extraBars:AddOption(L["Invert"], nil, { getterSetter = "actionbars.bars.MultiBarBottomRight.invert", callback = GW.UpdateMultibarButtons, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), groupHeaderName = OPTION_SHOW_ACTION_BAR:format(3), incompatibleAddons = "Actionbars"})


    extraBars:AddGroupHeader(OPTION_SHOW_ACTION_BAR:format(4))
    extraBars:AddOptionDropdown(SHOW, nil, { getterSetter = "actionbars.bars.MultiBarRight.fade", groupHeaderName = OPTION_SHOW_ACTION_BAR:format(4), optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), incompatibleAddons = "Actionbars"})
    extraBars:AddOptionDropdown(L["Width"], L["Number of columns in the two extra right-hand action bars."], {
        getterSetter = "actionbars.bars.MultiBarRight.ButtonsPerRow",
        groupHeaderName = OPTION_SHOW_ACTION_BAR:format(4),
        callback = function() GW.UpdateMultibarButtons() end,
        optionsList = {1, 2, 3, 4, 6, 12},
        optionNames = {"1", "2", "3", "4", "6", "12"},
        dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(),
        incompatibleAddons = "Actionbars"
    })
    extraBars:AddOption(L["Invert"], nil, { getterSetter = "actionbars.bars.MultiBarRight.invert", callback = GW.UpdateMultibarButtons, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), groupHeaderName = OPTION_SHOW_ACTION_BAR:format(4), incompatibleAddons = "Actionbars"})


    extraBars:AddGroupHeader(OPTION_SHOW_ACTION_BAR:format(5))
    extraBars:AddOptionDropdown(SHOW, nil, { getterSetter = "actionbars.bars.MultiBarLeft.fade", groupHeaderName = OPTION_SHOW_ACTION_BAR:format(5), optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), incompatibleAddons = "Actionbars"})
    extraBars:AddOptionDropdown(L["Width"], L["Number of columns in the two extra right-hand action bars."], {
        getterSetter = "actionbars.bars.MultiBarLeft.ButtonsPerRow",
        groupHeaderName = OPTION_SHOW_ACTION_BAR:format(5),
        callback = function() GW.UpdateMultibarButtons() end,
        optionsList = {1, 2, 3, 4, 6, 12},
        optionNames = {"1", "2", "3", "4", "6", "12"},
        dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(),
        incompatibleAddons = "Actionbars"
    })
    extraBars:AddOption(L["Invert"], nil, { getterSetter = "actionbars.bars.MultiBarLeft.invert", callback = GW.UpdateMultibarButtons, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), groupHeaderName = OPTION_SHOW_ACTION_BAR:format(5), incompatibleAddons = "Actionbars"})


    extraBars:AddGroupHeader(OPTION_SHOW_ACTION_BAR:format(6))
    extraBars:AddOptionDropdown(SHOW, nil, { getterSetter = "actionbars.bars.MultiBar5.fade", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, groupHeaderName = OPTION_SHOW_ACTION_BAR:format(6), optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), incompatibleAddons = "Actionbars"})
    extraBars:AddOptionDropdown(L["Width"], L["Number of columns in the two extra right-hand action bars."], {
        getterSetter = "actionbars.bars.MultiBar5.ButtonsPerRow",
        groupHeaderName = OPTION_SHOW_ACTION_BAR:format(6),
        callback = function() GW.UpdateMultibarButtons() end,
        optionsList = {1, 2, 3, 4, 6, 12},
        optionNames = {"1", "2", "3", "4", "6", "12"},
        dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(),
        incompatibleAddons = "Actionbars"
    })
    extraBars:AddOption(L["Invert"], nil, { getterSetter = "actionbars.bars.MultiBar5.invert", callback = GW.UpdateMultibarButtons, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), groupHeaderName = OPTION_SHOW_ACTION_BAR:format(6), incompatibleAddons = "Actionbars"})


    extraBars:AddGroupHeader(OPTION_SHOW_ACTION_BAR:format(7))
    extraBars:AddOptionDropdown(SHOW, nil, { getterSetter = "actionbars.bars.MultiBar6.fade", groupHeaderName = OPTION_SHOW_ACTION_BAR:format(7), optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), incompatibleAddons = "Actionbars"})
    extraBars:AddOptionDropdown(L["Width"], L["Number of columns in the two extra right-hand action bars."], {
        getterSetter = "actionbars.bars.MultiBar6.ButtonsPerRow",
        groupHeaderName = OPTION_SHOW_ACTION_BAR:format(7),
        callback = function() GW.UpdateMultibarButtons() end,
        optionsList = {1, 2, 3, 4, 6, 12},
        optionNames = {"1", "2", "3", "4", "6", "12"},
        dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(),
        incompatibleAddons = "Actionbars"
    })
    extraBars:AddOption(L["Invert"], nil, { getterSetter = "actionbars.bars.MultiBar6.invert", callback = GW.UpdateMultibarButtons, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), groupHeaderName = OPTION_SHOW_ACTION_BAR:format(7), incompatibleAddons = "Actionbars"})


    extraBars:AddGroupHeader(OPTION_SHOW_ACTION_BAR:format(8))
    extraBars:AddOptionDropdown(SHOW, nil, { getterSetter = "actionbars.bars.MultiBar7.fade", groupHeaderName = OPTION_SHOW_ACTION_BAR:format(8), optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), incompatibleAddons = "Actionbars"})
    extraBars:AddOptionDropdown(L["Width"], L["Number of columns in the two extra right-hand action bars."], {
        getterSetter = "actionbars.bars.MultiBar7.ButtonsPerRow",
        groupHeaderName = OPTION_SHOW_ACTION_BAR:format(8),
        callback = function() GW.UpdateMultibarButtons() end,
        optionsList = {1, 2, 3, 4, 6, 12},
        optionNames = {"1", "2", "3", "4", "6", "12"},
        dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(),
        incompatibleAddons = "Actionbars"
    })
    extraBars:AddOption(L["Invert"], nil, { getterSetter = "actionbars.bars.MultiBar7.invert", callback = GW.UpdateMultibarButtons, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), groupHeaderName = OPTION_SHOW_ACTION_BAR:format(8), incompatibleAddons = "Actionbars"})

    -- STANCEBAR
    local stanceBarDependence = (function() local t = {["actionbars.enabled"] = true, ["stanceBar.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)()
    stanceBar:AddOptionNote(format(L["The action bars are disabled entirely: enable them under %s."], BINDING_HEADER_ACTIONBAR .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.actionbars.enabled ~= true end,
        group = "actionbarPageNote",
    })
    stanceBar:AddOptionNote(format(L["The automatic bar layout is disabled: position, visibility and columns of these bars are managed by Blizzard's Edit Mode. Enable '%s' under %s to manage them here."], L["Automatic Bar Layout"], BINDING_HEADER_ACTIONBAR .. " - " .. GENERAL), {
        isVisible = function() return GW.isModern and GW.settings.actionbars.enabled == true and GW.settings.actionbars.barLayout ~= true end,
        group = "actionbarPageNote",
    })
    stanceBar:AddOption(ENABLE, nil, { getterSetter = "stanceBar.enabled", isMasterToggle = true ,callback = function() if GwStanceBar then GwStanceBar:UpdateVisibility(); GwStanceBar:UpdateAlpha() end end, dependence = (function() local t = {["actionbars.enabled"] = true} if GW.isModern then t["actionbars.barLayout"] = true end return t end)(), incompatibleAddons = "Actionbars"})
    stanceBar:AddOptionDropdown(L["Growth Direction"], L["Set the growth direction of the stance bar."], {getterSetter = "stanceBar.growDirection", callback = function() if GwStanceBar then GwStanceBar:AdjustMaxStanceButtons() end end, optionsList = {"UP", "DOWN", "LEFT", "RIGHT"}, optionNames = {L["Up"], L["Down"], L["Left"], L["Right"]}, dependence = stanceBarDependence, incompatibleAddons = "Actionbars", group = "barLayout"})
    stanceBar:AddOptionSlider(L["Button Size"], nil, {getterSetter = "stanceBar.buttonSize", callback = function() if GwStanceBar then GwStanceBar:AdjustMaxStanceButtons() end end, min = 20, max = 60, decimalNumbers = 0, step = 1, dependence = stanceBarDependence, incompatibleAddons = "Actionbars", group = "barLayout"})
    stanceBar:AddOptionSlider(L["Button Spacing"], nil, {getterSetter = "stanceBar.spacing", callback = function() if GwStanceBar then GwStanceBar:AdjustMaxStanceButtons() end end, min = 0, max = 10, decimalNumbers = 0, step = 1, dependence = stanceBarDependence, incompatibleAddons = "Actionbars", group = "barLayout"})
    stanceBar:AddOptionSlider(L["Alpha"], nil, {getterSetter = "stanceBar.alpha", callback = function() if GwStanceBar then GwStanceBar:UpdateAlpha() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.05, dependence = stanceBarDependence, incompatibleAddons = "Actionbars", group = "barVisibility"})
    stanceBar:AddOption(L["Only on Mouse Over"], nil, {getterSetter = "stanceBar.mouseOver", callback = function() if GwStanceBar then GwStanceBar:UpdateAlpha() end end, dependence = stanceBarDependence, incompatibleAddons = "Actionbars", group = "barVisibility"})

    sWindow:AddSettingsPanel(p, BINDING_HEADER_ACTIONBAR, ACTIONBARS_SUBTEXT, {{name = GENERAL, frame = general}, {name = L["Main Action Bar"], frame = mainBar}, {name = BINDING_HEADER_MULTIACTIONBAR, frame = extraBars},  {name = HUD_EDIT_MODE_STANCE_BAR_LABEL or L["Stance Bar"], frame = stanceBar}})
end
GW.LoadActionbarPanel = LoadActionbarPanel
