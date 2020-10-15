local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionButton = GW.AddOptionButton
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel

local function LoadHudPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(UIOPTIONS_MENU)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["HUD_DESC"])

    createCat(UIOPTIONS_MENU, L["HUD_TOOLTIP"], p, 3)

    addOption(p, L["HUD_BACKGROUND"], L["HUD_BACKGROUND_DESC"], "HUD_BACKGROUND")
    addOption(p, L["DYNAMIC_HUD"], L["DYNAMIC_HUD_DESC"], "HUD_SPELL_SWAP", nil, nil, {["HUD_BACKGROUND"] = true})
    addOption(p, L["CHAT_FADE"], L["CHAT_FADE_DESC"], "CHATFRAME_FADE", nil, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p, L["COMPASS_TOGGLE"], L["COMPASS_TOGGLE_DESC"], "SHOW_QUESTTRACKER_COMPASS", nil, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(p, L["ADV_CAST_BAR"], L["ADV_CAST_BAR_DESC"], "CASTINGBAR_DATA", nil, nil, {["CASTINGBAR_ENABLED"] = true})
    addOption(p, L["FADE_MICROMENU"], L["FADE_MICROMENU_DESC"], "FADE_MICROMENU")
    addOption(p, DISPLAY_BORDERS, nil, "BORDER_ENABLED")
    addOption(p, WORLD_MARKER:format(0):gsub("%d", ""), L["WORLD_MARKER_DESC"], "WORLD_MARKER_FRAME")
    addOption(p, L["MINIMAP_FPS"], L["MINIMAP_FPS"], "MINIMAP_FPS", nil, nil, {["MINIMAP_ENABLED"] = true})
    addOption(p, L["FADE_GROUP_MANAGE_FRAME"], L["FADE_GROUP_MANAGE_FRAME_DESC"], "FADE_GROUP_MANAGE_FRAME", nil, nil, {["PARTY_FRAMES"] = true})
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
    addOptionButton(p, L["APPLY_SCALE_TO_ALL_SCALEABELFRAMES"], L["APPLY_SCALE_TO_ALL_SCALEABELFRAMES_DESC"], nil, function()
        local scale = GetSetting("HUD_SCALE")
        for _, mf in pairs(GW.scaleableFrames) do
            mf.gw_frame:SetScale(scale)
            mf:SetScale(scale)
            GW.SetSetting(mf.gw_Settings .."_scale", scale)
        end
    end)
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
            local size = GetSetting("MINIMAP_SCALE")
            Minimap:SetSize(size, size)
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
    addOptionDropdown(
        p,
        L["AUTO_REPAIR"],
        L["AUTO_REPAIR_DESC"],
        "AUTO_REPAIR",
        nil,
        {"NONE", "PLAYER", "GUILD"},
        {
            NONE_KEY,
            PLAYER,
            GUILD,
        }
    )

    InitPanel(p)
end
GW.LoadHudPanel = LoadHudPanel
