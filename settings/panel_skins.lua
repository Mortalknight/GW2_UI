local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel

local function LoadSkinsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p = p.scroll.scrollchild
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(L["Skins"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Adjust Skin settings."])

    createCat(L["Skins"], L["Adjust Skin settings."], p:GetParent():GetParent(), 6, nil, true)

    addOption(p, MAINMENU_BUTTON, nil, "MAINMENU_SKIN_ENABLED")
    addOption(p, L["Popup notifications"], nil, "STATICPOPUP_SKIN_ENABLED")
    addOption(p, SHOW_BATTLENET_TOASTS, nil, "BNTOASTFRAME_SKIN_ENABLED")
    addOption(p, DEATH_RECAP_TITLE, nil, "DEATHRECAPFRAME_SKIN_ENABLED")
    addOption(p, "Drop-Down", nil, "DROPDOWN_SKIN_ENABLED")
    addOption(p, L["Looking for Group notifications"] , nil, "LFG_FRAMES_SKIN_ENABLED")
    addOption(p, READY_CHECK, nil, "READYCHECK_SKIN_ENABLED")
    addOption(p, L["Talking Head"], nil, "TALKINGHEAD_SKIN_ENABLED")
    addOption(p, L["Misc Frames"], nil, "MISC_SKIN_ENABLED")
    addOption(p, FLIGHT_MAP, nil, "FLIGHTMAP_SKIN_ENABLED")
    addOption(p, L["Blizzard Class Colors"], nil, "BLIZZARDCLASSCOLOR_ENABLED")
    addOption(p, ADDON_LIST, nil, "ADDONLIST_SKIN_ENABLED")
    addOption(p, INTERFACE_OPTIONS, nil, "BLIZZARD_OPTIONS_SKIN_ENABLED")
    addOption(p, KEY_BINDINGS, nil, "BINDINGS_SKIN_ENABLED")
    addOption(p, MACRO, nil, "MACRO_SKIN_ENABLED")
    addOption(p, MINIMAP_TRACKING_MAILBOX, nil, "MAIL_SKIN_ENABLED")
    addOption(p, BARBERSHOP, nil, "BARBERSHOP_SKIN_ENABLED")
    addOption(p, INSPECT, nil, "INSPECTION_SKIN_ENABLED")
    addOption(p, DRESSUP_FRAME, nil, "DRESSUP_SKIN_ENABLED")
    addOption(p, HELP_FRAME_TITLE, nil, "HELPFRAME_SKIN_ENABLED")
    addOption(p, L["Socket Frame"], nil, "SOCKET_SKIN_ENABLED")
    addOption(p, WORLDMAP_BUTTON, nil, "WORLDMAP_SKIN_ENABLED")
    addOption(p, L["Gossip Frame"], nil, "GOSSIP_SKIN_ENABLED")
    addOption(p, ITEM_UPGRADE, nil, "ITEMUPGRADE_SKIN_ENABLED")
    
    addOption(p, "|cffaaaaaa[AddOn]|r World Quest Tracker", nil, "SKIN_WQT_ENABLED", nil, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(p, "|cffaaaaaa[AddOn]|r Immersion", nil, "IMMERSIONADDON_SKIN_ENABLED")

    -- 26 = Number of options
    p = p:GetParent():GetParent()
    p.scroll:SetScrollChild(p.scroll.scrollchild)
    p.scroll.scrollchild:SetHeight(p:GetHeight())
    p.scroll.scrollchild:SetWidth(p.scroll:GetWidth() - 20)
    p.scroll.slider:SetMinMaxValues(0, max(0, 26 * 25 - p:GetHeight() - 75))
    p.scroll.slider.thumb:SetHeight(100)
    p.scroll.slider:SetValue(1)
    p.scroll.maxScroll = max(0, 26 * 25 - p:GetHeight() - 75)

    InitPanel(p, true)
end
GW.LoadSkinsPanel = LoadSkinsPanel
