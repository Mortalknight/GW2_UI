local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling
local StrUpper = GW.StrUpper

local function setMultibarCols(barName, setting)
    local mb = GetSetting(barName)
    local cols = GetSetting(setting)
    GW.Debug("setting multibar colsfor bar ", barName, "to", cols)

    mb["ButtonsPerRow"] = cols
    SetSetting(barName, mb)
    --#regionto update the cols
    GW.UpdateMultibarButtons()
end
AddForProfiling("panel_actionbar", "setMultibarCols", setMultibarCols)

local function LoadActionbarPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(BINDING_HEADER_ACTIONBAR)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(ACTIONBARS_SUBTEXT)

    createCat(BINDING_HEADER_ACTIONBAR, nil, p, 7, nil, {p})

    addOption(p.scroll.scrollchild, L["Hide Empty Slots"], L["Hide the empty action bar slots."], "HIDEACTIONBAR_BACKGROUND_ENABLED", function() GW.ShowRlPopup = true; GW.UpdateMultibarButtons() end, nil, {["ACTIONBARS_ENABLED"] = true}, "Actionbars")
    addOption(p.scroll.scrollchild, L["Action Button Labels"], L["Enable or disable the action button assignment text"], "BUTTON_ASSIGNMENTS", function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons() end, nil, {["ACTIONBARS_ENABLED"] = true}, "Actionbars")
    addOptionSlider(
        p.scroll.scrollchild,
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
    addOptionSlider(
        p.scroll.scrollchild,
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
        p.scroll.scrollchild,
        OPTION_SHOW_ACTION_BAR:format(4) .. ": " .. L["Width"],
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
        p.scroll.scrollchild,
        OPTION_SHOW_ACTION_BAR:format(5) .. ": " .. L["Width"],
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
        p.scroll.scrollchild,
        OPTION_SHOW_ACTION_BAR:format(6) .. ": " .. L["Width"],
        L["Number of columns in the two extra right-hand action bars."],
        "MULTIBAR_RIGHT_COLS_3",
        function()
            setMultibarCols("MultiBar5", "MULTIBAR_RIGHT_COLS_3")
        end,
        {1, 2, 3, 4, 6, 12},
        {"1", "2", "3", "4", "6", "12"},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )

    addOptionDropdown(
        p.scroll.scrollchild,
        OPTION_SHOW_ACTION_BAR:format(7) .. ": " .. L["Width"],
        L["Number of columns in the two extra right-hand action bars."],
        "MULTIBAR_RIGHT_COLS_4",
        function()
            setMultibarCols("MultiBar6", "MULTIBAR_RIGHT_COLS_4")
        end,
        {1, 2, 3, 4, 6, 12},
        {"1", "2", "3", "4", "6", "12"},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )

    addOptionDropdown(
        p.scroll.scrollchild,
        OPTION_SHOW_ACTION_BAR:format(8) .. ": " .. L["Width"],
        L["Number of columns in the two extra right-hand action bars."],
        "MULTIBAR_RIGHT_COLS_5",
        function()
            setMultibarCols("MultiBar7", "MULTIBAR_RIGHT_COLS_5")
        end,
        {1, 2, 3, 4, 6, 12},
        {"1", "2", "3", "4", "6", "12"},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )




    addOptionDropdown(
        p.scroll.scrollchild,
        L["Stance Bar Growth Direction"],
        L["Set the growth direction of the stance bar"],
        "StanceBar_GrowDirection",
        function()
            GW.SetStanceButtons(GwStanceBar)
        end,
        {"UP", "DOWN", "LEFT", "RIGHT"},
        {StrUpper(L["Up"], 1, 1), StrUpper(L["Down"], 1, 1), L["Left"], L["Right"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        BINDING_HEADER_ACTIONBAR .. ": '" .. BINDING_HEADER_ACTIONBAR .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_8",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        BINDING_HEADER_MULTIACTIONBAR .. ": '" .. OPTION_SHOW_ACTION_BAR:format(2) .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_1",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        BINDING_HEADER_MULTIACTIONBAR .. ": '" .. OPTION_SHOW_ACTION_BAR:format(3) .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_2",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        BINDING_HEADER_MULTIACTIONBAR .. ": '" .. OPTION_SHOW_ACTION_BAR:format(4) .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_3",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        BINDING_HEADER_MULTIACTIONBAR .. ": '" .. OPTION_SHOW_ACTION_BAR:format(5) .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_4",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )

    addOptionDropdown(
        p.scroll.scrollchild,
        BINDING_HEADER_MULTIACTIONBAR .. ": '" .. OPTION_SHOW_ACTION_BAR:format(6) .. "' " .. SHOW,
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

    addOptionDropdown(
        p.scroll.scrollchild,
        BINDING_HEADER_MULTIACTIONBAR .. ": '" .. OPTION_SHOW_ACTION_BAR:format(7) .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_6",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )

    addOptionDropdown(
        p.scroll.scrollchild,
        BINDING_HEADER_MULTIACTIONBAR .. ": '" .. OPTION_SHOW_ACTION_BAR:format(8) .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_7",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Only on Mouse Over"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        p.scroll.scrollchild,
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
    addOption(p.scroll.scrollchild, L["Show Macro Name"], L["Show Macro Name on Action Button"], "SHOWACTIONBAR_MACRO_NAME_ENABLED", function() GW.UpdateMainBarHot(); GW.UpdateMultibarButtons(); GW.UpdatePetBarButtonsHot() end, nil, {["ACTIONBARS_ENABLED"] = true}, "Actionbars")

    InitPanel(p, true)
end
GW.LoadActionbarPanel = LoadActionbarPanel
