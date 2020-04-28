local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling

local function LoadHudPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(L["HUD_CAT_1"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["HUD_DESC"])

    createCat(L["HUD_CAT"], L["HUD_TOOLTIP"], p, 3)

    addOption(p, L["DYNAMIC_HUD"], L["DYNAMIC_HUD_DESC"], "HUD_SPELL_SWAP")
    addOption(p, L["CHAT_FADE"], L["CHAT_FADE_DESC"], "CHATFRAME_FADE", nil, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p, L["COMPASS_TOGGLE"], L["COMPASS_TOGGLE_DESC"], "SHOW_QUESTTRACKER_COMPASS", nil, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(p, L["ADV_CAST_BAR"], L["ADV_CAST_BAR_DESC"], "CASTINGBAR_DATA", nil, nil, {["CASTINGBAR_ENABLED"] = true})
    addOption(p, L["FADE_MICROMENU"], L["FADE_MICROMENU_DESC"], "FADE_MICROMENU")
    addOption(p, L["AUTO_REPAIR"], L["AUTO_REPAIR_DESC"], "AUTO_REPAIR")
    addOption(p, DISPLAY_BORDERS, nil, "BORDER_ENABLED")
    addOption(
        p,
        L["PIXEL_PERFECTION"],
        L["PIXEL_PERFECTION_DESC"],
        "PIXEL_PERFECTION",
        function()
            SetCVar("useUiScale", 0)
            GW.PixelPerfection()
        end
    )
    addOption(p, L["AFK_MODE"], L["AFK_MODE_DESC"], "AFK_MODE")
    addOptionSlider(
        p,
        L["HUD_SCALE"],
        L["HUD_SCALE_DESC"],
        "HUD_SCALE",
        GW.UpdateHudScale,
        0.5,
        1.5,
        nil,
        2
    )
    addOptionDropdown(
        p,
        L["MINIMAP_HOVER"],
        L["MINIMAP_HOVER_TOOLTIP"],
        "MINIMAP_HOVER",
        GW.SetMinimapHover,
        {"NONE", "BOTH", "CLOCK", "ZONE"},
        {
            NONE_KEY,
            ALL,
            TIMEMANAGER_TITLE,
            ZONE
        },
        nil,
        {["MINIMAP_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        L["MINIMAP_POS"],
        nil,
        "MINIMAP_POS",
        GW.SetMinimapPosition,
        {"BOTTOM", "TOP"},
        {
            TRACKER_SORT_MANUAL_BOTTOM,
            TRACKER_SORT_MANUAL_TOP
        },
        nil,
        {["MINIMAP_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        L["MINIMAP_SCALE"],
        L["MINIMAP_SCALE_DESC"],
        "MINIMAP_SCALE",
        function()
            Minimap:SetSize(GetSetting("MINIMAP_SCALE"), GetSetting("MINIMAP_SCALE"))
        end,
        {250, 200, 170},
        {
            LARGE,
            TIME_LEFT_MEDIUM,
            DEFAULT
        },
        nil,
        {["MINIMAP_ENABLED"] = true}
    )

    InitPanel(p)
end
GW.LoadHudPanel = LoadHudPanel
