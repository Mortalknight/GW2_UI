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

local function setMultibarCols()
    local cols = GetSetting("MULTIBAR_RIGHT_COLS")
    GW:Debug("setting multibar cols", cols)
    local mb1 = GetSetting("MultiBarRight")
    local mb2 = GetSetting("MultiBarLeft")
    mb1["ButtonsPerRow"] = cols
    mb2["ButtonsPerRow"] = cols
    SetSetting("MultiBarRight", mb1)
    SetSetting("MultiBarLeft", mb2)
    GW.UpdateMultibarButtonMargin()
end
AddForProfiling("panel_actionbar", "setMultibarCols", setMultibarCols)

local function LoadActionbarPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(BINDING_HEADER_ACTIONBAR)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(ACTIONBARS_SUBTEXT)

    createCat(BINDING_HEADER_ACTIONBAR, nil, p, 7)

    addOption(p, L["Hide Empty Slots"], L["Hide the empty action bar slots."], "HIDEACTIONBAR_BACKGROUND_ENABLED", nil, nil, {["ACTIONBARS_ENABLED"] = true}, "Actionbars")
    addOption(p, L["Action Button Labels"], L["Enable or disable the action button assignment text"], "BUTTON_ASSIGNMENTS", nil, nil, {["ACTIONBARS_ENABLED"] = true}, "Actionbars")
    addOption(
        p,
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
        p,
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
        p,
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
        p,
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
        p,
        BINDING_HEADER_ACTIONBAR .. ": " .. L["Button Spacing"],
        nil,
        "MAINBAR_MARGIIN",
        GW.UpdateMainBarMargin,
        0,
        10,
        nil,
        1,
        {["ACTIONBARS_ENABLED"] = true}
    )
    addOptionSlider(
        p,
        BINDING_HEADER_MULTIACTIONBAR .. ": " .. L["Button Spacing"],
        nil,
        "MULTIBAR_MARGIIN",
        GW.UpdateMultibarButtonMargin,
        0,
        10,
        nil,
        1,
        {["ACTIONBARS_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        L["Right Bar Width"],
        L["Number of columns in the two extra right-hand action bars."],
        "MULTIBAR_RIGHT_COLS",
        setMultibarCols,
        {1, 2, 3, 4, 6, 12},
        {"1", "2", "3", "4", "6", "12"},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )
    addOptionDropdown(
        p,
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
    addOptionDropdown(
        p,
        BINDING_HEADER_ACTIONBAR .. ": '" .. BINDING_HEADER_ACTIONBAR .. "' " .. SHOW,
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
        p,
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
        p,
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
        p,
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
        p,
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
    addOptionDropdown(
        p,
        L["Main Bar Range Indicator"],
        nil,
        "MAINBAR_RANGEINDICATOR",
        nil,
        {"RED_INDICATOR", "RED_OVERLAY", "BOTH", "NONE"},
        {L["%s Indicator"]:format(RED_GEM), L["Red Overlay"], STATUS_TEXT_BOTH, NONE},
        nil,
        {["ACTIONBARS_ENABLED"] = true},
        nil,
        "Actionbars"
    )
    addOption(p, L["Show Macro Name"], L["Show Macro Name on Action Button"], "SHOWACTIONBAR_MACRO_NAME_ENABLED", nil, nil, {["ACTIONBARS_ENABLED"] = true}, "Actionbars")

    InitPanel(p)
end
GW.LoadActionbarPanel = LoadActionbarPanel
