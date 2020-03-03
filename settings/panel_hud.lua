local _, GW = ...
local addOption = GW.AddOption
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling
local L = GwLocalization

local function LoadHudPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(GwLocalization["HUD_CAT_1"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(GwLocalization["HUD_DESC"])

    createCat(L["HUD_CAT"], L["HUD_TOOLTIP"], p, 3)

    addOption(p, L["DYNAMIC_HUD"], L["DYNAMIC_HUD_DESC"], "HUD_SPELL_SWAP")
    addOption(p, L["CHAT_FADE"], L["CHAT_FADE_DESC"], "CHATFRAME_FADE")
    addOption(p, L["COMPASS_TOGGLE"], L["COMPASS_TOGGLE_DESC"], "SHOW_QUESTTRACKER_COMPASS")
    addOption(p, L["ADV_CAST_BAR"], L["ADV_CAST_BAR_DESC"], "CASTINGBAR_DATA")
    addOption(p, L["FADE_MICROMENU"], L["FADE_MICROMENU_DESC"], "FADE_MICROMENU")
    addOption(p, DISPLAY_BORDERS, nil, "BORDER_ENABLED")
    addOption(p, WORLD_MARKER:format(0):gsub("%d", ""), L["WORLD_MARKER_DESC"], "WORLD_MARKER_FRAME")
    addOption(p, L["MINIMAP_FPS"], L["MINIMAP_FPS"], "MINIMAP_FPS")
    addOption(p, L["PIXEL_PERFECTION"], L["PIXEL_PERFECTION_DESC"], "PIXEL_PERFECTION")
    addOption(p, L["MOUSE_TOOLTIP"], L["MOUSE_TOOLTIP_DESC"], "TOOLTIP_MOUSE")
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
    addOptionSlider(
        p,
        L["ANCHOR_CURSOR_OFFSET_X"],
        L["ANCHOR_CURSOR_OFFSET_DESC"],
        "ANCHOR_CURSOR_OFFSET_X",
        nil,
        -128,
        128
    )
    addOptionSlider(
        p,
        L["ANCHOR_CURSOR_OFFSET_Y"],
        L["ANCHOR_CURSOR_OFFSET_DESC"],
        "ANCHOR_CURSOR_OFFSET_Y",
        nil,
        -128,
        128
    )
    addOptionDropdown(
        p,
        L["CURSOR_ANCHOR_TYPE"],
        L["CURSOR_ANCHOR_TYPE_DESC"],
        "CURSOR_ANCHOR_TYPE",
        nil,
        {"ANCHOR_CURSOR", "ANCHOR_CURSOR_LEFT", "ANCHOR_CURSOR_RIGHT"},
        {
            L["CURSOR_ANCHOR"],
            L["ANCHOR_CURSOR_LEFT"],
            L["ANCHOR_CURSOR_RIGHT"]
        }
    )
    addOptionDropdown(
        p,
        L["MINIMAP_HOVER"],
        L["MINIMAP_HOVER_TOOLTIP"],
        "MINIMAP_HOVER",
        GW.SetMinimapHover,
        {"NONE", "ALL", "CLOCK", "ZONE", "COORDS", "CLOCKZONE", "CLOCKCOORDS", "ZONECOORDS"},
        {
            NONE_KEY,
            ALL,
            TIMEMANAGER_TITLE,
            ZONE,
            L["MINIMAP_COORDS"],
            TIMEMANAGER_TITLE .. " + " .. ZONE,
            TIMEMANAGER_TITLE .. " + " .. L["MINIMAP_COORDS"],
            ZONE .. " + " .. L["MINIMAP_COORDS"]
        }
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
        }
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
        }
    )

    InitPanel(p)
end
GW.LoadHudPanel = LoadHudPanel
