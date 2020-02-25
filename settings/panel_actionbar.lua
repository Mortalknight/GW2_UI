local _, GW = ...
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting

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

local function LoadActionbarPanel(sWindow)
    local pnl_action = CreateFrame("Frame", "GwSettingsActionbarOptions", sWindow.panels, "GwSettingsPanelTmpl")
    pnl_action.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_action.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    pnl_action.header:SetText(BINDING_HEADER_ACTIONBAR)
    pnl_action.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_action.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pnl_action.sub:SetText(ACTIONBARS_SUBTEXT)

    createCat(BINDING_HEADER_ACTIONBAR, nil, "GwSettingsActionbarOptions", 7)

    addOption(
        GwLocalization["HIDE_EMPTY_SLOTS"],
        GwLocalization["HIDE_EMPTY_SLOTS_DESC"],
        "HIDEACTIONBAR_BACKGROUND_ENABLED",
        "GwSettingsActionbarOptions"
    )
    addOption(
        GwLocalization["BUTTON_ASSIGNMENTS"],
        GwLocalization["BUTTON_ASSIGNMENTS_DESC"],
        "BUTTON_ASSIGNMENTS",
        "GwSettingsActionbarOptions"
    )
    addOptionDropdown(
        GwLocalization["STG_RIGHT_BAR_COLS"],
        GwLocalization["STG_RIGHT_BAR_COLS_DESC"],
        "MULTIBAR_RIGHT_COLS",
        "GwSettingsActionbarOptions",
        setMultibarCols,
        {1, 2, 3, 4, 6, 12},
        {"1", "2", "3", "4", "6", "12"}
    )
    addOptionDropdown(
        GwLocalization["STANCEBAR_POSITION"],
        GwLocalization["STANCEBAR_POSITION_DESC"],
        "STANCEBAR_POSITION",
        "GwSettingsActionbarOptions",
        GW.setStanceBar,
        {"LEFT", "RIGHT"},
        {GwLocalization["LEFT"], GwLocalization["RIGHT"]}
    )
    addOptionDropdown(
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR1_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_1",
        "GwSettingsActionbarOptions",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, GwLocalization["MOUSE_OVER"]}
    )
    addOptionDropdown(
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR2_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_2",
        "GwSettingsActionbarOptions",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, GwLocalization["MOUSE_OVER"]}
    )
    addOptionDropdown(
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR3_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_3",
        "GwSettingsActionbarOptions",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, GwLocalization["MOUSE_OVER"]}
    )
    addOptionDropdown(
        BINDING_HEADER_ACTIONBAR .. ": '" .. SHOW_MULTIBAR4_TEXT .. "' " .. SHOW,
        nil,
        "FADE_MULTIACTIONBAR_4",
        "GwSettingsActionbarOptions",
        nil,
        {"ALWAYS", "INCOMBAT", "MOUSE_OVER"},
        {ALWAYS, GARRISON_LANDING_STATUS_MISSION_COMBAT, GwLocalization["MOUSE_OVER"]}
    )
    addOptionDropdown(
        GwLocalization["MAINBAR_RANGE_INDICATOR"],
        nil,
        "MAINBAR_RANGEINDICATOR",
        "GwSettingsActionbarOptions",
        nil,
        {"RED_INDICATOR", "RED_OVERLAY", "BOTH", "NONE"},
        {GwLocalization["INDICATOR_TITLE"]:format(RED_GEM), GwLocalization["RED_OVERLAY"],STATUS_TEXT_BOTH,NONE}
    )
end
GW.LoadActionbarPanel = LoadActionbarPanel
