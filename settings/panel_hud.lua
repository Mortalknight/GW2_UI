local _, GW = ...
local addOption = GW.AddOption
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting

local function LoadHudPanel(sWindow)
    local pnl_hud = CreateFrame("Frame", "GwSettingsHudOptions", sWindow.panels, "GwSettingsPanelTmpl")
    pnl_hud.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_hud.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    pnl_hud.header:SetText(GwLocalization["HUD_CAT_1"])
    pnl_hud.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_hud.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pnl_hud.sub:SetText(GwLocalization["HUD_DESC"])

    createCat(GwLocalization["HUD_CAT"], GwLocalization["HUD_TOOLTIP"], "GwSettingsHudOptions", 3)

    addOption(
        GwLocalization["DYNAMIC_HUD"],
        GwLocalization["DYNAMIC_HUD_DESC"],
        "HUD_SPELL_SWAP",
        "GwSettingsHudOptions"
    )
    addOption(GwLocalization["CHAT_FADE"],
        GwLocalization["CHAT_FADE_DESC"],
        "CHATFRAME_FADE",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["COMPASS_TOGGLE"],
        GwLocalization["COMPASS_TOGGLE_DESC"],
        "SHOW_QUESTTRACKER_COMPASS",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["ADV_CAST_BAR"],
        GwLocalization["ADV_CAST_BAR_DESC"],
        "CASTINGBAR_DATA",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["FADE_MICROMENU"],
        GwLocalization["FADE_MICROMENU_DESC"],
        "FADE_MICROMENU",
        "GwSettingsHudOptions"
    )
    addOption(
        DISPLAY_BORDERS,
        nil,
        "BORDER_ENABLED",
        "GwSettingsHudOptions"
    )
    addOption(
        WORLD_MARKER:format(0):gsub("%d", ""),
        GwLocalization["WORLD_MARKER_DESC"],
        "WORLD_MARKER_FRAME",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["MINIMAP_FPS"],
        GwLocalization["MINIMAP_FPS"],
        "MINIMAP_FPS",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["PIXEL_PERFECTION"],
        GwLocalization["PIXEL_PERFECTION_DESC"],
        "PIXEL_PERFECTION",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["MOUSE_TOOLTIP"],
        GwLocalization["MOUSE_TOOLTIP_DESC"],
        "TOOLTIP_MOUSE",
        "GwSettingsHudOptions"
    )
    addOptionSlider(
        GwLocalization['ANCHOR_CURSOR_OFFSET_X'],
        GwLocalization["ANCHOR_CURSOR_OFFSET_DESC"],
        "ANCHOR_CURSOR_OFFSET_X",
        "GwSettingsHudOptions",
        nil,
        -128,
        128 
    )
    addOptionSlider(
        GwLocalization['ANCHOR_CURSOR_OFFSET_Y'],
        GwLocalization["ANCHOR_CURSOR_OFFSET_DESC"],
        "ANCHOR_CURSOR_OFFSET_Y",
        "GwSettingsHudOptions",
        nil,
        -128,
        128 
    )
    addOptionDropdown(
        GwLocalization["CURSOR_ANCHOR_TYPE"],
        GwLocalization["CURSOR_ANCHOR_TYPE_DESC"],
        "CURSOR_ANCHOR_TYPE",
        "GwSettingsHudOptions",
        function()
            if GetSetting("CURSOR_ANCHOR_TYPE") == "ANCHOR_CURSOR" then
                for k, v in pairs(options) do
                    if v.optionName == "ANCHOR_CURSOR_OFFSET_X" or v.optionName == "ANCHOR_CURSOR_OFFSET_Y" then
                        if _G["GwOptionBox" .. k].slider then
                            _G["GwOptionBox" .. k].slider:Disable()
                            SetSetting(v.optionName, 0)
                            _G["GwOptionBox" .. k].slider:SetValue(0)
                            _G["GwOptionBox" .. k].title:SetTextColor(0.82, 0.82, 0.82)
                            _G["GwOptionBox" .. k].slider.label:SetTextColor(0.82, 0.82, 0.82)
                        end
                    end
                end
            else
                for k, v in pairs(options) do
                    if v.optionName == "ANCHOR_CURSOR_OFFSET_X" or v.optionName == "ANCHOR_CURSOR_OFFSET_Y" then
                        if _G["GwOptionBox" .. k].slider then
                            _G["GwOptionBox" .. k].slider:Enable()
                            _G["GwOptionBox" .. k].title:SetTextColor(1, 1, 1)
                            _G["GwOptionBox" .. k].slider.label:SetTextColor(1, 1, 1)
                        end
                    end
                end
            end
        end,
        {'ANCHOR_CURSOR','ANCHOR_CURSOR_LEFT','ANCHOR_CURSOR_RIGHT'},
        {
            GwLocalization['CURSOR_ANCHOR'],
            GwLocalization['ANCHOR_CURSOR_LEFT'],
            GwLocalization['ANCHOR_CURSOR_RIGHT']
        }
    )
    addOptionDropdown(
        GwLocalization["MINIMAP_HOVER"],
        GwLocalization["MINIMAP_HOVER_TOOLTIP"],
        "MINIMAP_HOVER",
        "GwSettingsHudOptions",
        function()
            GW.SetMinimapHover()
        end,
        {"NONE", "ALL", "CLOCK", "ZONE", "COORDS", "CLOCKZONE", "CLOCKCOORDS", "ZONECOORDS"},
        {
            NONE_KEY,
            ALL,
            TIMEMANAGER_TITLE,
            ZONE,
            GwLocalization['MINIMAP_COORDS'],
            TIMEMANAGER_TITLE .. " + " .. ZONE,
            TIMEMANAGER_TITLE .. " + " .. GwLocalization['MINIMAP_COORDS'],
            ZONE .. " + " .. GwLocalization['MINIMAP_COORDS']
        }
    )
    addOptionDropdown(
        GwLocalization["MINIMAP_POS"],
        nil,
        "MINIMAP_POS",
        "GwSettingsHudOptions",
        function()
            GW.SetMinimapPosition()
        end,
        {"BOTTOM", "TOP"},
        {
            TRACKER_SORT_MANUAL_BOTTOM,
            TRACKER_SORT_MANUAL_TOP
        }
    )
    addOptionDropdown(
        GwLocalization["MINIMAP_SCALE"],
        GwLocalization["MINIMAP_SCALE_DESC"],
        "MINIMAP_SCALE",
        "GwSettingsHudOptions",
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
    addOptionDropdown(
        GwLocalization["HUD_SCALE"],
        GwLocalization["HUD_SCALE_DESC"],
        "HUD_SCALE",
        "GwSettingsHudOptions",
        function()
            GW.UpdateHudScale()
        end,
        {1, 0.9, 0.8},
        {
            DEFAULT,
            SMALL,
            GwLocalization["HUD_SCALE_TINY"]
        }
    )
end
GW.LoadHudPanel = LoadHudPanel
