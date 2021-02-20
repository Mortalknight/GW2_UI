local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel

local function LoadSkinsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local p_blizzard = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_blizzard:SetHeight(500)
    p_blizzard:ClearAllPoints()
    p_blizzard:SetPoint("TOPLEFT", p, "TOPLEFT", 0, 0)
    p_blizzard.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_blizzard.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p_blizzard.header:SetText(L["Skins"])
    p_blizzard.sub:SetFont(UNIT_NAME_FONT, 12)
    p_blizzard.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_blizzard.sub:SetText(L["Adjust Skin settings."])

    local p_addons = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_addons:SetHeight(100)
    p_addons:ClearAllPoints()
    p_addons:SetPoint("TOPLEFT", p_blizzard, "BOTTOMLEFT", 0, 0)
    p_addons.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_addons.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p_addons.header:SetText(ADDONS)
    p_addons.sub:SetFont(UNIT_NAME_FONT, 12)
    p_addons.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_addons.sub:SetText("")

    createCat(L["Skins"], L["Adjust Skin settings."], p, 6)

    addOption(p_blizzard, MAINMENU_BUTTON, nil, "MAINMENU_SKIN_ENABLED")
    addOption(p_blizzard, "Static Popup", nil, "STATICPOPUP_SKIN_ENABLED")
    addOption(p_blizzard, SHOW_BATTLENET_TOASTS, nil, "BNTOASTFRAME_SKIN_ENABLED")
    addOption(p_blizzard, "Ghost frame", nil, "GHOSTFRAME_SKIN_ENABLED")
    addOption(p_blizzard, DEATH_RECAP_TITLE, nil, "DEATHRECAPFRAME_SKIN_ENABLED")
    addOption(p_blizzard, "Drop-Down", nil, "DROPDOWN_SKIN_ENABLED")
    addOption(p_blizzard, "LFG Popups", nil, "LFG_FRAMES_SKIN_ENABLED")
    addOption(p_blizzard, READY_CHECK, nil, "READYCHECK_SKIN_ENABLED")
    addOption(p_blizzard, L["Talking Head"], nil, "TALKINGHEAD_SKIN_ENABLED")
    addOption(p_blizzard, "Timer Tracker Frame", nil, "TIMERTRACKER_SKIN_ENABLED")
    addOption(p_blizzard, FLIGHT_MAP, nil, "FLIGHTMAP_SKIN_ENABLED")
    addOption(p_blizzard, "Use Blizzard Class Colors", nil, "BLIZZARDCLASSCOLOR_ENABLED")
    addOption(p_blizzard, ADDON_LIST, nil, "ADDONLIST_SKIN_ENABLED")
    addOption(p_blizzard, INTERFACE_OPTIONS, nil, "BLIZZARD_OPTIONS_SKIN_ENABLED")
    addOption(p_blizzard, KEY_BINDINGS, nil, "BINDINGS_SKIN_ENABLED")
    addOption(p_blizzard, MACRO, nil, "MACRO_SKIN_ENABLED")
    addOption(p_blizzard, MINIMAP_TRACKING_MAILBOX, nil, "MAIL_SKIN_ENABLED")
    addOption(p_blizzard, BARBERSHOP, nil, "BARBERSHOP_SKIN_ENABLED")
    addOption(p_blizzard, INSPECT, nil, "INSPECTION_SKIN_ENABLED")
    addOption(p_blizzard, DRESSUP_FRAME, nil, "DRESSUP_SKIN_ENABLED")
    addOption(p_blizzard, HELP_FRAME_TITLE, nil, "HELPFRAME_SKIN_ENABLED")
    addOption(p_addons, "World Quest Tracker", nil, "SKIN_WQT_ENABLED", nil, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(p_addons, "Immersion", nil, "IMMERSIONADDON_SKIN_ENABLED")

    InitPanel(p_blizzard)
    InitPanel(p_addons)
end
GW.LoadSkinsPanel = LoadSkinsPanel
