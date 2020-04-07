local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling

local function setMultibarCols()
    local cols = GetSetting("MULTIBAR_RIGHT_COLS")
    Debug("setting multibar cols", cols)
    local mb1 = GetSetting("MultiBarRight")
    local mb2 = GetSetting("MultiBarLeft")
    mb1["ButtonsPerRow"] = cols
    mb2["ButtonsPerRow"] = cols
    SetSetting("MultiBarRight", mb1)
    SetSetting("MultiBarLeft", mb2)
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

    addOption(p, L["HIDE_EMPTY_SLOTS"], L["HIDE_EMPTY_SLOTS_DESC"], "HIDEACTIONBAR_BACKGROUND_ENABLED", nil, nil, {["ACTIONBARS_ENABLED"] = true})
    addOption(p, L["BUTTON_ASSIGNMENTS"], L["BUTTON_ASSIGNMENTS_DESC"], "BUTTON_ASSIGNMENTS", nil, nil, {["ACTIONBARS_ENABLED"] = true})
    addOptionDropdown(
        p,
        L["STG_RIGHT_BAR_COLS"],
        L["STG_RIGHT_BAR_COLS_DESC"],
        "MULTIBAR_RIGHT_COLS",
        setMultibarCols,
        {1, 2, 3, 4, 6, 12},
        {"1", "2", "3", "4", "6", "12"},
        nil,
        {["ACTIONBARS_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        L["STANCEBAR_POSITION"],
        L["STANCEBAR_POSITION_DESC"],
        "STANCEBAR_POSITION",
        GW.setStanceBar,
        {"LEFT", "RIGHT"},
        {L["LEFT"], L["RIGHT"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR1_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_1",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["MOUSE_OVER"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR2_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_2",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["MOUSE_OVER"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR3_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_3",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["MOUSE_OVER"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR4_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_4",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["MOUSE_OVER"]},
        nil,
        {["ACTIONBARS_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        L["MAINBAR_RANGE_INDICATOR"],
        nil,
        "MAINBAR_RANGEINDICATOR",
        nil,
        {"RED_INDICATOR", "RED_OVERLAY", "BOTH", "NONE"},
        {L["INDICATOR_TITLE"]:format(RED_GEM), L["RED_OVERLAY"], STATUS_TEXT_BOTH, NONE},
        nil,
        {["ACTIONBARS_ENABLED"] = true}
    )

    InitPanel(p)
end
GW.LoadActionbarPanel = LoadActionbarPanel
