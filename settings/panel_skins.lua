local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton;

local function LoadSkinsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(L["Skins"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Adjust Skin settings."])

    createCat(L["Skins"], L["Adjust Skin settings."], p, {p})

    settingsMenuAddButton(L["Skins"],p,{})

    addOption(p, MAINMENU_BUTTON, nil, "MAINMENU_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p, L["Popup notifications"], nil, "STATICPOPUP_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p, SHOW_BATTLENET_TOASTS, nil, "BNTOASTFRAME_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p, L["Blizzard Class Colors"], nil, "BLIZZARDCLASSCOLOR_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p, ADDON_LIST, nil, "ADDONLIST_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p, INTERFACE_OPTIONS, nil, "BLIZZARD_OPTIONS_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p, MACRO, nil, "MACRO_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p, WORLD_MAP, nil, "WORLDMAP_SKIN_ENABLED", function() GW.ShowRlPopup = true end)

    InitPanel(p)
end
GW.LoadSkinsPanel = LoadSkinsPanel
