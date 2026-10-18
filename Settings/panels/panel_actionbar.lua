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
    general.sub:SetText(L["Edit action bar settings."])
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

    local totemBar = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    totemBar.panelId = "actionbar_totem"
    totemBar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    totemBar.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    totemBar.header:SetText(BINDING_HEADER_ACTIONBAR)
    totemBar.sub:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    totemBar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    totemBar.sub:SetText(L["Edit the totem bar settings."])
    totemBar.header:SetWidth(totemBar.header:GetStringWidth())
    totemBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    totemBar.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    totemBar.breadcrumb:SetText(L["Totem Bar"])

    local barDependence = {["actionbars.enabled"] = true}
    if GW.isModern then
        barDependence["actionbars.barLayout"] = true
    end

    local hotkeyDependence = {["actionbars.enabled"] = true, ["actionbars.buttonAssignments"] = true}
    local macroNameDependence = {["actionbars.enabled"] = true, ["actionbars.showMacroNames"] = true}

    local function UpdateButtonTexts()
        GW.UpdateHotkeyPositions()
        GW.UpdateMainBarHot()
        GW.UpdateMultibarButtons()
        if GwPlayerPetFrame then
            GwPlayerPetFrame:UpdatePetBarButtons()
        end
    end

    -- position and offset of keybind and macro name, the placement puts them into the group of their bar
    local function AddButtonTextOptions(panel, key, placement)
        local function Options(setting, dependence, extra)
            local options = {getterSetter = key .. setting, callback = UpdateButtonTexts, dependence = dependence, incompatibleAddons = "Actionbars", group = placement.group, groupHeaderName = placement.groupHeaderName}
            for k, v in pairs(extra) do
                options[k] = v
            end
            return options
        end
        local positions = {optionsList = {"TOP", "CENTER", "BOTTOM"}, optionNames = {L["Top"], L["Center"], L["Bottom"]}}
        local offset = {min = -20, max = 20, decimalNumbers = 0, step = 1}
        panel:AddOptionDropdown(L["Action Button Labels Position"], nil, Options("hotkeyPosition", hotkeyDependence, positions))
        panel:AddOptionSlider(L["X-Offset"], nil, Options("hotkeyX", hotkeyDependence, offset))
        panel:AddOptionSlider(L["Y-Offset"], nil, Options("hotkeyY", hotkeyDependence, offset))
        panel:AddOptionDropdown(L["Macro Name Position"], nil, Options("macroNamePosition", macroNameDependence, positions))
        panel:AddOptionSlider(L["X-Offset"], nil, Options("macroNameX", macroNameDependence, offset))
        panel:AddOptionSlider(L["Y-Offset"], nil, Options("macroNameY", macroNameDependence, offset))
    end

    local function AddBarPageNotes(panel)
        panel:AddOptionNote(format(L["The action bars are disabled entirely: enable them under %s."], BINDING_HEADER_ACTIONBAR .. " - " .. GENERAL), {
            isVisible = function() return GW.settings.actionbars.enabled ~= true end,
            group = "actionbarPageNote",
        })
        panel:AddOptionNote(format(L["The automatic bar layout is disabled: position, visibility and columns of these bars are managed by Blizzard's Edit Mode. Enable '%s' under %s to manage them here."], L["Automatic Bar Layout"], BINDING_HEADER_ACTIONBAR .. " - " .. GENERAL), {
            isVisible = function() return GW.isModern and GW.settings.actionbars.enabled == true and GW.settings.actionbars.barLayout ~= true end,
            group = "actionbarPageNote",
        })
    end

    -- GENERAL
    general:AddOption(ENABLE, L["Use the GW2 UI improved action bars."], {getterSetter = "actionbars.enabled", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Actionbars", isMasterToggle = true})
    general:AddOption(L["Automatic Bar Layout"], L["Enable or disable the automatic layout management of the primary action bars and associated frames (pet, buffs); required for auto bar fading and some other features"], { getterSetter = "actionbars.barLayout", callback = function() GW.ShowRlPopup = true end, dependence = {["actionbars.enabled"] = true}, incompatibleAddons = "Actionbars", hidden = not GW.isModern, group = "autoLayout"})
    general:AddOption(L["Add space for Healthglobe"], nil, { getterSetter = "actionbars.healthGlobeSpace", callback = function() GW.ShowRlPopup = true end, dependence = {["actionbars.enabled"] = true, ["actionbars.barLayout"] = false}, incompatibleAddons = "Actionbars", hidden = not GW.isModern, group = "autoLayout"})
    general:AddOption(L["Action Button Labels"], L["Enable or disable the action button assignment text"], { getterSetter = "actionbars.buttonAssignments", callback = function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons() end, dependence = {["actionbars.enabled"] = true}, incompatibleAddons = "Actionbars", group = "buttonText"})
    general:AddOption(L["Action Button Labels only on used slots"], L["Shows the assignments only on used slots"], { getterSetter = "actionbars.buttonAssignmentsUsedOnly", callback = function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons() end, dependence = {["actionbars.enabled"] = true, ["actionbars.buttonAssignments"] = true}, incompatibleAddons = "Actionbars", group = "buttonText"})
    general:AddOption(L["Show Macro Name"], L["Shows the macro name on the action button."], { getterSetter = "actionbars.showMacroNames", callback = function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons(); if GwPlayerPetFrame then GwPlayerPetFrame:UpdatePetBarButtons() end end, dependence = {["actionbars.enabled"] = true}, incompatibleAddons = "Actionbars", group = "buttonText"})

    general:AddOptionSlider(L["Empty slots alpha"], L["Set the empty action bar slots alpha value."], { getterSetter = "actionbars.backgroundAlpha", callback = function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons() end, isPercent = true, min = 0, max = 1, decimalNumbers = 1, step = 0.1, dependence = {["actionbars.enabled"] = true}, group = "emptySlots"})

    -- MAINBAR
    AddBarPageNotes(mainBar)
    mainBar:AddOptionSlider(L["Button Spacing"], nil, { getterSetter = "actionbars.mainbarMargin", callback = function() GW.UpdateMainBarHot() end, min = 0, max = 10, decimalNumbers = 1, step = 0.1, dependence = barDependence, group = "buttonAppearance"})

    mainBar:AddOptionDropdown(L["Main Bar Range Indicator"], nil, { getterSetter = "actionbars.rangeIndicator", callback = GW.UpdateMainBarHot, optionsList = {"NONE", "RED_INDICATOR", "RED_OVERLAY", "BOTH"}, optionNames = {NONE, L["%s Indicator"]:format(RED_GEM), L["Red Overlay"], STATUS_TEXT_BOTH}, dependence = {["actionbars.enabled"] = true}, incompatibleAddons = "Actionbars", group = "buttonAppearance"})
    mainBar:AddOptionDropdown(BINDING_HEADER_ACTIONBAR .. SHOW, nil, { getterSetter = "actionbars.mainBar.fade", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = barDependence, incompatibleAddons = "Actionbars", group = "barVisibility"})
    mainBar:AddOption(L["Hide while mounted or in a vehicle"], L["The main bar stays while it shows the skyriding, vehicle or possess abilities."], { getterSetter = "actionbars.mainBar.hideMounted", dependence = barDependence, incompatibleAddons = "Actionbars", group = "barVisibility"})
    local skyridingDependence = CopyTable(barDependence)
    skyridingDependence["actionbars.mainBar.hideMounted"] = true
    mainBar:AddOption(L["Also while skyriding"], nil, { getterSetter = "actionbars.mainBar.hideSkyriding", dependence = skyridingDependence, incompatibleAddons = "Actionbars", hidden = not GW.Retail, group = "barVisibility"})
    AddButtonTextOptions(mainBar, "actionbars.mainBar.", {group = "buttonText"})

    --EXTRABARS
    AddBarPageNotes(extraBars)
    extraBars:AddOptionSlider(L["Button Spacing"], nil, { getterSetter = "actionbars.multibarMargin", callback = function() GW.UpdateMultibarButtons() end, min = 0, max = 10, decimalNumbers = 1, step = 0.1, dependence = barDependence})

    local function AddExtraBarOptions(barName, barNumber, hasWidth)
        local header = OPTION_SHOW_ACTION_BAR:format(barNumber)
        local key = "actionbars.bars." .. barName .. "."
        extraBars:AddGroupHeader(header)
        extraBars:AddOptionDropdown(SHOW, nil, { getterSetter = key .. "fade", callback = GW.UpdateAllMultibarVisibility, optionsList = {"ALWAYS", "INCOMBAT", "HIDE_IN_COMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT, L["Only on Mouse Over"]}, dependence = barDependence, groupHeaderName = header, incompatibleAddons = "Actionbars"})
        extraBars:AddOption(L["Hide while mounted or in a vehicle"], nil, { getterSetter = key .. "hideMounted", callback = GW.UpdateAllMultibarVisibility, dependence = barDependence, groupHeaderName = header, incompatibleAddons = "Actionbars"})
        if hasWidth then
            extraBars:AddOptionDropdown(L["Width"], L["Number of columns in the two extra right-hand action bars."], { getterSetter = key .. "ButtonsPerRow", callback = GW.UpdateMultibarButtons, optionsList = {1, 2, 3, 4, 6, 12}, optionNames = {"1", "2", "3", "4", "6", "12"}, dependence = barDependence, groupHeaderName = header, incompatibleAddons = "Actionbars"})
        end
        extraBars:AddOption(L["Invert"], nil, { getterSetter = key .. "invert", callback = GW.UpdateMultibarButtons, dependence = barDependence, groupHeaderName = header, incompatibleAddons = "Actionbars"})
        AddButtonTextOptions(extraBars, key, {groupHeaderName = header})
    end
    AddExtraBarOptions("MultiBarBottomLeft", 2)
    AddExtraBarOptions("MultiBarBottomRight", 3)
    AddExtraBarOptions("MultiBarRight", 4, true)
    AddExtraBarOptions("MultiBarLeft", 5, true)
    AddExtraBarOptions("MultiBar5", 6, true)
    AddExtraBarOptions("MultiBar6", 7, true)
    AddExtraBarOptions("MultiBar7", 8, true)

    -- STANCEBAR
    local stanceBarDependence = CopyTable(barDependence)
    stanceBarDependence["stanceBar.enabled"] = true
    AddBarPageNotes(stanceBar)
    stanceBar:AddOption(ENABLE, nil, { getterSetter = "stanceBar.enabled", isMasterToggle = true ,callback = function() if GwStanceBar then GwStanceBar:UpdateVisibility(); GwStanceBar:UpdateAlpha() end end, dependence = barDependence, incompatibleAddons = "Actionbars"})
    stanceBar:AddOptionDropdown(L["Growth Direction"], L["Set the growth direction of the stance bar."], {getterSetter = "stanceBar.growDirection", callback = function() if GwStanceBar then GwStanceBar:AdjustMaxStanceButtons() end end, optionsList = {"UP", "DOWN", "LEFT", "RIGHT"}, optionNames = {L["Up"], L["Down"], L["Left"], L["Right"]}, dependence = stanceBarDependence, incompatibleAddons = "Actionbars", group = "barLayout"})
    stanceBar:AddOptionSlider(L["Button Size"], nil, {getterSetter = "stanceBar.buttonSize", callback = function() if GwStanceBar then GwStanceBar:AdjustMaxStanceButtons() end end, min = 20, max = 60, decimalNumbers = 0, step = 1, dependence = stanceBarDependence, incompatibleAddons = "Actionbars", group = "barLayout"})
    stanceBar:AddOptionSlider(L["Button Spacing"], nil, {getterSetter = "stanceBar.spacing", callback = function() if GwStanceBar then GwStanceBar:AdjustMaxStanceButtons() end end, min = 0, max = 10, decimalNumbers = 0, step = 1, dependence = stanceBarDependence, incompatibleAddons = "Actionbars", group = "barLayout"})
    stanceBar:AddOptionSlider(L["Alpha"], nil, {getterSetter = "stanceBar.alpha", callback = function() if GwStanceBar then GwStanceBar:UpdateAlpha() end end, isPercent = true, min = 0, max = 1, decimalNumbers = 2, step = 0.05, dependence = stanceBarDependence, incompatibleAddons = "Actionbars", group = "barVisibility"})
    stanceBar:AddOption(L["Only on Mouse Over"], nil, {getterSetter = "stanceBar.mouseOver", callback = function() if GwStanceBar then GwStanceBar:UpdateAlpha() end end, dependence = stanceBarDependence, incompatibleAddons = "Actionbars", group = "barVisibility"})

    --TOTEMBAR
    totemBar:AddOption(ENABLE, nil, { getterSetter = "totemBar.enabled", isMasterToggle = true, callback = function() if GwTotemBar then GwTotemBar:UpdateVisibility() end end, dependence = {["unitframes.healthGlobe.enabled"] = true}, incompatibleAddons = "Actionbars"})
    totemBar:AddOptionDropdown(L["Sorting"], nil, { getterSetter = "totemBar.sortDirection", callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end, optionsList = {"ASC", "DSC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["unitframes.healthGlobe.enabled"] = true, ["totemBar.enabled"] = true}, incompatibleAddons = "Actionbars"})
    totemBar:AddOptionDropdown(L["Growth Direction"], nil, { getterSetter = "totemBar.growDirection", callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end, optionsList = {"HORIZONTAL", "VERTICAL"}, optionNames = {L["Horizontal"], L["Vertical"]}, dependence = {["unitframes.healthGlobe.enabled"] = true, ["totemBar.enabled"] = true}, incompatibleAddons = "Actionbars"})
    totemBar:AddOptionSlider(L["Button Spacing"], nil, {
        getterSetter = "totemBar.spacing",
        callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end,
        min = 0,
        max = 10,
        decimalNumbers = 0,
        step = 1,
        dependence = {["unitframes.healthGlobe.enabled"] = true, ["totemBar.enabled"] = true},
        incompatibleAddons = "Actionbars"
    })
    totemBar:AddOptionSlider(L["Button Size"], nil, {
        getterSetter = "totemBar.buttonSize",
        callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end,
        min = 20,
        max = 60,
        decimalNumbers = 0,
        step = 1,
        dependence = {["unitframes.healthGlobe.enabled"] = true, ["totemBar.enabled"] = true},
        incompatibleAddons = "Actionbars"
    })

    sWindow:AddSettingsPanel(p, BINDING_HEADER_ACTIONBAR, L["Edit action bar settings."], {{name = GENERAL, frame = general}, {name = L["Main Action Bar"], frame = mainBar}, {name = BINDING_HEADER_MULTIACTIONBAR, frame = extraBars},  {name = HUD_EDIT_MODE_STANCE_BAR_LABEL or L["Stance Bar"], frame = stanceBar}, {name = L["Totem Bar"], frame = totemBar}})
end
GW.LoadActionbarPanel = LoadActionbarPanel
