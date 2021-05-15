local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel


local function LoadSkinsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText("General Skins")
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText("Enable or disable the skins you need and don't need.")

    createCat("General Skins", "Enable and disable general skins", p, 6)

    addOption(p, MAINMENU_BUTTON, nil, "MAINMENU_SKIN_ENABLED")
    addOption(p, L["Popup notifications"], nil, "STATICPOPUP_SKIN_ENABLED")
    addOption(p, SHOW_BATTLENET_TOASTS, nil, "BNTOASTFRAME_SKIN_ENABLED")
    addOption(p, L["Blizzard Class Colors"], nil, "BLIZZARDCLASSCOLOR_ENABLED")
    addOption(p, ADDON_LIST, nil, "ADDONLIST_SKIN_ENABLED")
    addOption(p, INTERFACE_OPTIONS, nil, "BLIZZARD_OPTIONS_SKIN_ENABLED")
    addOption(p, KEY_BINDINGS, nil, "BINDINGS_SKIN_ENABLED")
    addOption(p, MACRO, nil, "MACRO_SKIN_ENABLED")
    addOption(p, WORLD_MAP, nil, "WORLDMAP_SKIN_ENABLED")

    InitPanel(p)
end
GW.LoadSkinsPanel = LoadSkinsPanel
