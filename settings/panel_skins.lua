local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel


local function LoadSkinsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText("General Skins")
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText("Enable or disable the skins you need and don't need.")

    createCat(L["Skins"], L["Adjust Skin settings."], p, 6, nil, {p})

    addOption(p.scroll.scrollchild, MAINMENU_BUTTON, nil, "MAINMENU_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Popup notifications"], nil, "STATICPOPUP_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, SHOW_BATTLENET_TOASTS, nil, "BNTOASTFRAME_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Blizzard Class Colors"], nil, "BLIZZARDCLASSCOLOR_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, ADDON_LIST, nil, "ADDONLIST_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, INTERFACE_OPTIONS, nil, "BLIZZARD_OPTIONS_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, KEY_BINDINGS, nil, "BINDINGS_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, MACRO, nil, "MACRO_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, WORLD_MAP, nil, "WORLDMAP_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Gossip Frame"], nil, "GOSSIP_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, QUEST_LOG, nil, "QUESTLOG_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, MERCHANT, nil, "MERCHANT_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, READY_CHECK, nil, "READYCHECK_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, TIMEMANAGER_TITLE, nil, "TIMEMANAGER_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Socket Frame"], nil, "SOCKET_SKIN_ENABLED", function() GW.ShowRlPopup = true end)

    InitPanel(p, true)
end
GW.LoadSkinsPanel = LoadSkinsPanel
