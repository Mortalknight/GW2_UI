local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local addOptionButton = GW.AddOptionButton
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel

local function LoadHudPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.scroll.scrollchild.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.scroll.scrollchild.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.scroll.scrollchild.header:SetText(UIOPTIONS_MENU)
    p.scroll.scrollchild.sub:SetFont(UNIT_NAME_FONT, 12)
    p.scroll.scrollchild.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.scroll.scrollchild.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])

    createCat(UIOPTIONS_MENU, L["Edit the HUD modules."], p, 3, nil, {p})

    addOption(p.scroll.scrollchild, L["HUD_BACKGROUND"], L["HUD_BACKGROUND_DESC"], "HUD_BACKGROUND")
    addOption(p.scroll.scrollchild, L["DYNAMIC_HUD"], L["DYNAMIC_HUD_DESC"], "HUD_SPELL_SWAP", nil, nil, {["HUD_BACKGROUND"] = true})
    addOption(p.scroll.scrollchild, L["CHAT_FADE"], L["CHAT_FADE_DESC"], "CHATFRAME_FADE", nil, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["COMPASS_TOGGLE"], L["COMPASS_TOGGLE_DESC"], "SHOW_QUESTTRACKER_COMPASS", nil, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["ADV_CAST_BAR"], L["ADV_CAST_BAR_DESC"], "CASTINGBAR_DATA", nil, nil, {["CASTINGBAR_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["FADE_MICROMENU"], L["FADE_MICROMENU_DESC"], "FADE_MICROMENU")
    addOption(p.scroll.scrollchild, L["AUTO_REPAIR"], L["AUTO_REPAIR_DESC"], "AUTO_REPAIR")
    addOption(p.scroll.scrollchild, DISPLAY_BORDERS, nil, "BORDER_ENABLED")
    addOption(p.scroll.scrollchild, L["MINIMAP_FPS"], L["MINIMAP_FPS"], "MINIMAP_FPS", nil, nil, {["MINIMAP_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["FADE_GROUP_MANAGE_FRAME"], L["FADE_GROUP_MANAGE_FRAME_DESC"], "FADE_GROUP_MANAGE_FRAME", nil, nil, {["PARTY_FRAMES"] = true})
    addOption(
        p.scroll.scrollchild,
        L["PIXEL_PERFECTION"],
        L["PIXEL_PERFECTION_DESC"],
        "PIXEL_PERFECTION",
        function()
            SetCVar("useUiScale", 0)
            GW.PixelPerfection()
        end
    )
    addOption(p.scroll.scrollchild, L["AFK_MODE"], L["AFK_MODE_DESC"], "AFK_MODE")
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
    addOptionButton(p.scroll.scrollchild, L["Apply UI scale to all scaleable frames"], L["Applies the UI scale to all frames, which can be scaled in 'Move HUD' mode."], nil, function()
        local scale = GetSetting("HUD_SCALE")
        for _, mf in pairs(GW.scaleableFrames) do
            mf.gw_frame:SetScale(scale)
            mf:SetScale(scale)
            GW.SetSetting(mf.gw_Settings .."_scale", scale)
        end
    end)
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Minimap details"],
        L["Always show Minimap details."],
        "MINIMAP_HOVER",
        GW.SetMinimapHover,
        {"NONE", "ALL", "CLOCK", "ZONE", "COORDS", "CLOCKZONE", "CLOCKCOORDS", "ZONECOORDS"},
        {
            NONE_KEY,
            ALL,
            TIMEMANAGER_TITLE,
            ZONE,
            L["Coordinates"],
            TIMEMANAGER_TITLE .. " + " .. ZONE,
            TIMEMANAGER_TITLE .. " + " .. L["Coordinates"],
            ZONE .. " + " .. L["Coordinates"]
        },
        nil,
        {["MINIMAP_ENABLED"] = true},
        nil,
        "Minimap"
    )
    addOptionDropdown(
        p.scroll.scrollchild,
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

    InitPanel(p, true)
end
GW.LoadHudPanel = LoadHudPanel
