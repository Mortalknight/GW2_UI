local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local InitPanel = GW.InitPanel
local StrUpper = GW.StrUpper
local AddForProfiling = GW.AddForProfiling
local settingsMenuAddButton = GW.settingsMenuAddButton

local function setMultibarCols(barName, setting)
    local mb = GetSetting(barName)
    local cols = GetSetting(setting)
    GW:Debug("setting multibar colsfor bar ", barName, "to", cols)

    mb["ButtonsPerRow"] = cols
    SetSetting(barName, mb)
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
    general.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    general.header:SetText(BINDING_HEADER_ACTIONBAR)
    general.sub:SetFont(UNIT_NAME_FONT, 12)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(ACTIONBARS_SUBTEXT)
    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    general.breadcrumb:SetText(GENERAL)

    local mainBar = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    mainBar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    mainBar.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    mainBar.header:SetText(BINDING_HEADER_ACTIONBAR)
    mainBar.header:SetWidth(mainBar.header:GetStringWidth())
    mainBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    mainBar.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    mainBar.breadcrumb:SetText(L["Main Action Bar"]) --TODO: translate
    mainBar.sub:SetFont(UNIT_NAME_FONT, 12)
    mainBar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    mainBar.sub:SetText("")

    local extraBars = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    extraBars.header:SetFont(DAMAGE_TEXT_FONT, 20)
    extraBars.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    extraBars.header:SetText(BINDING_HEADER_ACTIONBAR)
    extraBars.sub:SetFont(UNIT_NAME_FONT, 12)
    extraBars.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    extraBars.sub:SetText("")
    extraBars.header:SetWidth(extraBars.header:GetStringWidth())
    extraBars.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    extraBars.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    extraBars.breadcrumb:SetText(BINDING_HEADER_MULTIACTIONBAR)

    local totemBar = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    totemBar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    totemBar.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    totemBar.header:SetText(BINDING_HEADER_ACTIONBAR)
    totemBar.sub:SetFont(UNIT_NAME_FONT, 12)
    totemBar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    totemBar.sub:SetText("")
    totemBar.header:SetWidth(totemBar.header:GetStringWidth())
    totemBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    totemBar.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    totemBar.breadcrumb:SetText(TUTORIAL_TITLE47) --"Totem bar"

    local stanceBar = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    stanceBar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    stanceBar.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    stanceBar.header:SetText(BINDING_HEADER_ACTIONBAR)
    stanceBar.sub:SetFont(UNIT_NAME_FONT, 12)
    stanceBar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    stanceBar.sub:SetText("")
    stanceBar.header:SetWidth(stanceBar.header:GetStringWidth())
    stanceBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    stanceBar.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    stanceBar.breadcrumb:SetText(L["Stance bar"])

    createCat(BINDING_HEADER_ACTIONBAR, ACTIONBARS_SUBTEXT, p, {general, mainBar, extraBars, totemBar, stanceBar})
    settingsMenuAddButton(BINDING_HEADER_ACTIONBAR, p, {general, mainBar, extraBars, totemBar, stanceBar})

    addOption(general.scroll.scrollchild, L["Hide Empty Slots"], L["Hide the empty action bar slots."], "HIDEACTIONBAR_BACKGROUND_ENABLED", function() GW.ShowRlPopup = true; GW.UpdateMultibarButtons() end, nil, {["ACTIONBARS_ENABLED"] = true}, "Actionbars")
    addOption(general.scroll.scrollchild, L["Action Button Labels"], L["Enable or disable the action button assignment text"], "BUTTON_ASSIGNMENTS", function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons() end, nil, {["ACTIONBARS_ENABLED"] = true}, "Actionbars")
    addOption(general.scroll.scrollchild, L["Show Macro Name"], L["Show Macro Name on Action Button"], "SHOWACTIONBAR_MACRO_NAME_ENABLED", function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons(); GW.UpdatePetBarButtonsHot() end, nil, {["ACTIONBARS_ENABLED"] = true}, "Actionbars")

    -- MAINBAR
    addOptionSlider(
        mainBar.scroll.scrollchild,
        BINDING_HEADER_ACTIONBAR .. ": " .. L["Button Spacing"],
        nil,
        "MAINBAR_MARGIIN",
        GW.UpdateMainBarHot,
        0,
        10,
        nil,
        1,
        {["ACTIONBARS_ENABLED"] = true}
    )
    addOptionDropdown(
        mainBar.scroll.scrollchild,
        L["Main Bar Range Indicator"],
        nil,
        "MAINBAR_RANGEINDICATOR",
        GW.UpdateMainBarHot,
        {"RED_INDICATOR", "RED_OVERLAY", "BOTH", "NONE"},
        {L["%s Indicator"]:format(RED_GEM), L["Red Overlay"], STATUS_TEXT_BOTH, NONE},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        mainBar.scroll.scrollchild,
        BINDING_HEADER_ACTIONBAR .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_5",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )

    --EXTRABARS
    addOption(
        extraBars.scroll.scrollchild,
        SHOW_MULTIBAR1_TEXT,
        OPTION_TOOLTIP_SHOW_MULTIBAR1,
        "GW_SHOW_MULTI_ACTIONBAR_1",
        function(toSet)
            if toSet then SHOW_MULTI_ACTIONBAR_1 = "1" else SHOW_MULTI_ACTIONBAR_1 = nil end
            SetActionBarToggles(GetSetting("GW_SHOW_MULTI_ACTIONBAR_1"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_2"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_3"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_4"), GetSetting("HIDEACTIONBAR_BACKGROUND_ENABLED"))
            InterfaceOptions_UpdateMultiActionBars()
        end,
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        "Actionbars"
    )
    addOption(
        extraBars.scroll.scrollchild,
        SHOW_MULTIBAR2_TEXT,
        OPTION_TOOLTIP_SHOW_MULTIBAR2,
        "GW_SHOW_MULTI_ACTIONBAR_2",
        function(toSet)
            if toSet then SHOW_MULTI_ACTIONBAR_2 = "1" else SHOW_MULTI_ACTIONBAR_2 = nil end
            SetActionBarToggles(GetSetting("GW_SHOW_MULTI_ACTIONBAR_1"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_2"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_3"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_4"), GetSetting("HIDEACTIONBAR_BACKGROUND_ENABLED"))
            InterfaceOptions_UpdateMultiActionBars()
        end,
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        "Actionbars"
    )
    addOption(
        extraBars.scroll.scrollchild,
        SHOW_MULTIBAR3_TEXT,
        OPTION_TOOLTIP_SHOW_MULTIBAR3,
        "GW_SHOW_MULTI_ACTIONBAR_3",
        function(toSet)
            if toSet then SHOW_MULTI_ACTIONBAR_3 = "1" else SHOW_MULTI_ACTIONBAR_3 = nil end
            SetActionBarToggles(GetSetting("GW_SHOW_MULTI_ACTIONBAR_1"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_2"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_3"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_4"), GetSetting("HIDEACTIONBAR_BACKGROUND_ENABLED"))
            InterfaceOptions_UpdateMultiActionBars()
        end,
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        "Actionbars"
    )
    addOption(
        extraBars.scroll.scrollchild,
        SHOW_MULTIBAR4_TEXT,
        OPTION_TOOLTIP_SHOW_MULTIBAR4,
        "GW_SHOW_MULTI_ACTIONBAR_4",
        function(toSet)
            if toSet then SHOW_MULTI_ACTIONBAR_4 = "1" else SHOW_MULTI_ACTIONBAR_4 = nil end
            SetActionBarToggles(GetSetting("GW_SHOW_MULTI_ACTIONBAR_1"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_2"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_3"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_4"), GetSetting("HIDEACTIONBAR_BACKGROUND_ENABLED"))
            InterfaceOptions_UpdateMultiActionBars()
        end,
        nil,
        {["ACTIONBARS_ENABLED"] = true, ["GW_SHOW_MULTI_ACTIONBAR_3"] = true},
        "Actionbars"
    )
    addOptionSlider(
        extraBars.scroll.scrollchild,
        BINDING_HEADER_MULTIACTIONBAR .. ": " .. L["Button Spacing"],
        nil,
        "MULTIBAR_MARGIIN",
        GW.UpdateMultibarButtons,
        0,
        10,
        nil,
        1,
        {["ACTIONBARS_ENABLED"] = true}
    )
    addOptionDropdown(
        extraBars.scroll.scrollchild,
        L["Right Bar Width"],
        L["Number of columns in the two extra right-hand action bars."],
        "MULTIBAR_RIGHT_COLS",
        function()
            setMultibarCols("MultiBarRight", "MULTIBAR_RIGHT_COLS")
        end,
        {1, 2, 3, 4, 6, 12},
        {"1", "2", "3", "4", "6", "12"},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        extraBars.scroll.scrollchild,
        L["Right Bar 2 Width"],
        L["Number of columns in the two extra right-hand action bars."],
        "MULTIBAR_RIGHT_COLS_2",
        function()
            setMultibarCols("MultiBarLeft", "MULTIBAR_RIGHT_COLS_2")
        end,
        {1, 2, 3, 4, 6, 12},
        {"1", "2", "3", "4", "6", "12"},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        extraBars.scroll.scrollchild,
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR1_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_1",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true, ["GW_SHOW_MULTI_ACTIONBAR_1"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        extraBars.scroll.scrollchild,
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR2_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_2",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true, ["GW_SHOW_MULTI_ACTIONBAR_2"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        extraBars.scroll.scrollchild,
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR3_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_3",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true, ["GW_SHOW_MULTI_ACTIONBAR_3"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        extraBars.scroll.scrollchild,
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR4_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_4",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true, ["GW_SHOW_MULTI_ACTIONBAR_4"] = true},
        nil,
        "Actionbars"
    )

    --TOTEMBAR
    addOptionDropdown(
        totemBar.scroll.scrollchild,
        L["Class Totems Sorting"],
        nil,
        "TotemBar_SortDirection",
        function() GW.UpdateTotembar(GW_TotemBar) end,
        {"ASC", "DSC"},
        {L["Ascending"], L["Descending"]},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )
    addOptionDropdown(
        totemBar.scroll.scrollchild,
        L["Class Totems Growth Direction"],
        nil,
        "TotemBar_GrowDirection",
        function() GW.UpdateTotembar(GW_TotemBar) end,
        {"HORIZONTAL", "VERTICAL"},
        {L["Horizontal"], L["Vertical"]},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )
    -- STANCEBAR
    addOptionDropdown(
        stanceBar.scroll.scrollchild,
        L["Stance Bar Growth Direction"],
        L["Set the growth direction of the stance bar"],
        "StanceBar_GrowDirection",
        function()
            GW.SetStanceButtons(GwStanceBarButton)
        end,
        {"UP", "DOWN", "LEFT", "RIGHT"},
        {StrUpper(L["Up"], 1, 1), StrUpper(L["Down"], 1, 1), L["Left"], L["Right"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )

    InitPanel(general, true)
    InitPanel(mainBar, true)
    InitPanel(extraBars, true)
    InitPanel(totemBar, true)
    InitPanel(stanceBar, true)
end
GW.LoadActionbarPanel = LoadActionbarPanel
