local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling
local StrUpper = GW.StrUpper
local settingsMenuAddButton = GW.settingsMenuAddButton;

local function setMultibarCols(barName, setting)
    local mb = GW.settings[barName]
    local cols = GW.settings[setting]
    GW.Debug("setting multibar colsfor bar ", barName, "to", cols)

    mb["ButtonsPerRow"] = cols
    GW.settings[barName] = mb
    --#regionto update the cols
    GW.UpdateMultibarButtons()
end
AddForProfiling("panel_actionbar", "setMultibarCols", setMultibarCols)

local function LoadActionbarPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local general = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    general.header:SetFont(DAMAGE_TEXT_FONT, 20)
    general.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    general.header:SetText(BINDING_HEADER_ACTIONBAR)
    general.sub:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(ACTIONBARS_SUBTEXT)
    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    general.breadcrumb:SetText(GENERAL)

    local mainBar = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    mainBar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    mainBar.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    mainBar.header:SetText(BINDING_HEADER_ACTIONBAR)
    mainBar.header:SetWidth(mainBar.header:GetStringWidth())
    mainBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    mainBar.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    mainBar.breadcrumb:SetText(L["Main Action Bar"]) --TODO: translate
    mainBar.sub:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    mainBar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    mainBar.sub:SetText("")

    local extraBars = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    extraBars.header:SetFont(DAMAGE_TEXT_FONT, 20)
    extraBars.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    extraBars.header:SetText(BINDING_HEADER_ACTIONBAR)
    extraBars.sub:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    extraBars.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    extraBars.sub:SetText("")
    extraBars.header:SetWidth(extraBars.header:GetStringWidth())
    extraBars.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    extraBars.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    extraBars.breadcrumb:SetText(BINDING_HEADER_MULTIACTIONBAR)

    local totemBar = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    totemBar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    totemBar.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    totemBar.header:SetText(BINDING_HEADER_ACTIONBAR)
    totemBar.sub:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    totemBar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    totemBar.sub:SetText("")
    totemBar.header:SetWidth(totemBar.header:GetStringWidth())
    totemBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    totemBar.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    totemBar.breadcrumb:SetText(TUTORIAL_TITLE47) --"Totem bar"

    local stanceBar = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    stanceBar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    stanceBar.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    stanceBar.header:SetText(BINDING_HEADER_ACTIONBAR)
    stanceBar.sub:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    stanceBar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    stanceBar.sub:SetText("")
    stanceBar.header:SetWidth(stanceBar.header:GetStringWidth())
    stanceBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    stanceBar.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    stanceBar.breadcrumb:SetText(HUD_EDIT_MODE_STANCE_BAR_LABEL)

    createCat(BINDING_HEADER_ACTIONBAR, ACTIONBARS_SUBTEXT, p, {general, mainBar, extraBars, totemBar, stanceBar})
    settingsMenuAddButton(BINDING_HEADER_ACTIONBAR, p, {general, mainBar, extraBars, totemBar, stanceBar})

    -- GENERAL
    addOption(general.scroll.scrollchild, L["Automatic Bar Layout"], L["Enable or disable the automatic layout management of the primary action bars and associated frames (pet, buffs); required for auto bar fading and some other features"], { getterSetter = "BAR_LAYOUT_ENABLED", callback = function() GW.ShowRlPopup = true end, dependence = {["ACTIONBARS_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionSlider(general.scroll.scrollchild, L["Empty slots alpha"], L["Set the empty action bar slots alpha value."], { getterSetter = "ACTIONBAR_BACKGROUND_ALPHA", callback = function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons() end, min = 0, max = 1, decimalNumbers = 1, step = 0.1, dependence = {["ACTIONBARS_ENABLED"] = true}})
    addOption(general.scroll.scrollchild, L["Action Button Labels"], L["Enable or disable the action button assignment text"], { getterSetter = "BUTTON_ASSIGNMENTS", callback = function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons() end, dependence = {["ACTIONBARS_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOption(general.scroll.scrollchild, L["Show Macro Name"], L["Show Macro Name on Action Button"], { getterSetter = "SHOWACTIONBAR_MACRO_NAME_ENABLED", callback = function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons(); if GwPlayerPetFrame then GwPlayerPetFrame:UpdatePetBarButtons() end end, dependence = {["ACTIONBARS_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    -- MAINBAR
    addOptionSlider(mainBar.scroll.scrollchild, L["Button Spacing"], nil, { getterSetter = "MAINBAR_MARGIIN", callback = function() GW.UpdateMainBarHot() end, min = 0, max = 10, decimalNumbers = 1, step = 0.1, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}})

    addOptionDropdown(mainBar.scroll.scrollchild, L["Main Bar Range Indicator"], nil, { getterSetter = "MAINBAR_RANGEINDICATOR", callback = GW.UpdateMainBarHot, optionsList = {"RED_INDICATOR", "RED_OVERLAY", "BOTH", "NONE"}, optionNames = {L["%s Indicator"]:format(RED_GEM), L["Red Overlay"], STATUS_TEXT_BOTH, NONE}, dependence = {["ACTIONBARS_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, BINDING_HEADER_ACTIONBAR .. SHOW, nil, { getterSetter = "FADE_MULTIACTIONBAR_8", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})

    --EXTRABARS
    addOptionSlider(extraBars.scroll.scrollchild, L["Button Spacing"], nil, { getterSetter = "MULTIBAR_MARGIIN", callback = function() GW.UpdateMultibarButtons() end, min = 0, max = 10, decimalNumbers = 1, step = 0.1, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}})

    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(2) .. " " .. SHOW, nil, { getterSetter = "FADE_MULTIACTIONBAR_1", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(3) .. " " .. SHOW, nil, { getterSetter = "FADE_MULTIACTIONBAR_2", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(4) .. " " .. SHOW, nil, { getterSetter = "FADE_MULTIACTIONBAR_3", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(4) .. " " .. L["Width"], L["Number of columns in the two extra right-hand action bars."], { getterSetter = "MULTIBAR_RIGHT_COLS", callback = function() setMultibarCols("MultiBarRight", "MULTIBAR_RIGHT_COLS") end, optionsList = {1, 2, 3, 4, 6, 12}, optionNames = {"1", "2", "3", "4", "6", "12"}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(5) .. " " .. SHOW, nil, { getterSetter = "FADE_MULTIACTIONBAR_4", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(5) .. " " .. L["Width"], L["Number of columns in the two extra right-hand action bars."], { getterSetter = "MULTIBAR_RIGHT_COLS_2", callback = function() setMultibarCols("MultiBarLeft", "MULTIBAR_RIGHT_COLS_2") end, optionsList = {1, 2, 3, 4, 6, 12}, optionNames = {"1", "2", "3", "4", "6", "12"}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(6) .. " " .. SHOW, nil, { getterSetter = "FADE_MULTIACTIONBAR_5", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(6) .. " " .. L["Width"], L["Number of columns in the two extra right-hand action bars."], { getterSetter = "MULTIBAR_RIGHT_COLS_3", callback = function() setMultibarCols("MultiBar5", "MULTIBAR_RIGHT_COLS_3") end, optionsList = {1, 2, 3, 4, 6, 12}, optionNames = {"1", "2", "3", "4", "6", "12"}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(7) .. " " .. SHOW, nil, { getterSetter = "FADE_MULTIACTIONBAR_6", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(7) .. " " .. L["Width"], L["Number of columns in the two extra right-hand action bars."], { getterSetter = "MULTIBAR_RIGHT_COLS_4", callback = function() setMultibarCols("MultiBar6", "MULTIBAR_RIGHT_COLS_4") end, optionsList = {1, 2, 3, 4, 6, 12}, optionNames = {"1", "2", "3", "4", "6", "12"}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(8) .. " " .. SHOW, nil, { getterSetter = "FADE_MULTIACTIONBAR_7", optionsList = {"ALWAYS", "INCOMBAT", "MOUSE_OVER"}, optionNames = {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(mainBar.scroll.scrollchild, OPTION_SHOW_ACTION_BAR:format(8) .. " " .. L["Width"], L["Number of columns in the two extra right-hand action bars."], { getterSetter = "MULTIBAR_RIGHT_COLS_5", callback = function() setMultibarCols("MultiBar7", "MULTIBAR_RIGHT_COLS_5") end, optionsList = {1, 2, 3, 4, 6, 12}, optionNames = {"1", "2", "3", "4", "6", "12"}, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})


    --TOTEMBAR
    addOptionDropdown(totemBar.scroll.scrollchild, L["Class Totems Sorting"], nil, { getterSetter = "TotemBar_SortDirection", callback = function() GW.UpdateTotembar(GW_TotemBar) end, optionsList = {"ASC", "DSC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["HEALTHGLOBE_ENABLED"] = true}})
    addOptionDropdown(totemBar.scroll.scrollchild, L["Class Totems Growth Direction"], nil, { getterSetter = "TotemBar_GrowDirection", callback = function() GW.UpdateTotembar(GW_TotemBar) end, optionsList = {"HORIZONTAL", "VERTICAL"}, optionNames = {L["Horizontal"], L["Vertical"]}, dependence = {["HEALTHGLOBE_ENABLED"] = true}})

    -- STANCEBAR
    addOption(general.scroll.scrollchild, ENABLE, nil, { getterSetter = "StanceBarEnabled", callback = function() GW.UpdateStanceBarVisibility(GwStanceBar) end, dependence = {["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    addOptionDropdown(totemBar.scroll.scrollchild, L["Class Totems Growth Direction"], L["Set the growth direction of the stance bar"], { getterSetter = "StanceBar_GrowDirection", callback = function() GW.SetStanceButtons(GwStanceBar) end, optionsList = {"UP", "DOWN", "LEFT", "RIGHT"}, optionNames = {StrUpper(L["Up"], 1, 1), StrUpper(L["Down"], 1, 1), L["Left"], L["Right"]}, dependence = {["StanceBarEnabled"] = true, ["ACTIONBARS_ENABLED"] = true, ["BAR_LAYOUT_ENABLED"] = true}, incompatibleAddons = "Actionbars"})

    InitPanel(general, true)
    InitPanel(mainBar, true)
    InitPanel(extraBars, true)
    InitPanel(totemBar, true)
    InitPanel(stanceBar, true)
end
GW.LoadActionbarPanel = LoadActionbarPanel
