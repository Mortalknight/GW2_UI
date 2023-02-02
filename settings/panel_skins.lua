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

    addOption(p.scroll.scrollchild, L["Alert Frames"], nil, "ALERTFRAME_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, MAINMENU_BUTTON, nil, "MAINMENU_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Popup notifications"], nil, "STATICPOPUP_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, SHOW_BATTLENET_TOASTS, nil, "BNTOASTFRAME_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, DEATH_RECAP_TITLE, nil, "DEATHRECAPFRAME_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, "Drop-Down", nil, "DROPDOWN_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Looking for Group notifications"] , nil, "LFG_FRAMES_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, READY_CHECK, nil, "READYCHECK_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Talking Head"], nil, "TALKINGHEAD_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Misc Frames"], nil, "MISC_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, FLIGHT_MAP, nil, "FLIGHTMAP_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Blizzard Class Colors"], nil, "BLIZZARDCLASSCOLOR_ENABLED", function() GW.UpdateClassColorSetting(); GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, ADDON_LIST, nil, "ADDONLIST_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, MACRO, nil, "MACRO_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, MINIMAP_TRACKING_MAILBOX, nil, "MAIL_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, BARBERSHOP, nil, "BARBERSHOP_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, INSPECT, nil, "INSPECTION_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, DRESSUP_FRAME, nil, "DRESSUP_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, HELP_FRAME_TITLE, nil, "HELPFRAME_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Socket Frame"], nil, "SOCKET_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, WORLDMAP_BUTTON, nil, "WORLDMAP_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, GW.NewSign .. L["Gossip Frame"], nil, "GOSSIP_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, ITEM_UPGRADE, nil, "ITEMUPGRADE_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, TIMEMANAGER_TITLE, nil, "TIMEMANAGER_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, MERCHANT, nil, "MERCHANT_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, ADVENTURE_JOURNAL, nil, "ENCOUNTER_JOURNAL_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, COVENANT_SANCTUM_TAB_UPGRADES, nil, "CONCENANT_SANCTUM_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, COVENANT_PREVIEW_SOULBINDS, nil, "SOULBINDS_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Chromie Time Frame"], nil, "CHROMIE_TIME_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Allied Races"], nil, "ALLIEND_RACES_UI_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, PVP_WEEKLY_REWARD, nil, "WEEKLY_REWARDS_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, LFG_TITLE, nil, "LFG_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, C_Garrison.GetTalentTreeInfo(461).title, nil, "ORDERRHALL_TALENT_FRAME_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, L["Loot Frame"], nil, "LOOTFRAME_SKIN_ENABLED", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, GW.NewSign .. ACHIEVEMENTS, nil, "ACHIEVEMENT_SKIN_ENABLED", function() GW.ShowRlPopup = true end, nil, nil, "AchievementSkin")

    addOption(p.scroll.scrollchild, "|cffaaaaaa[AddOn]|r World Quest Tracker", nil, "SKIN_WQT_ENABLED", function() GW.ShowRlPopup = true end, nil, {["QUESTTRACKER_ENABLED"] = true}, "Objectives")
    addOption(p.scroll.scrollchild, "|cffaaaaaa[AddOn]|r Immersion", nil, "IMMERSIONADDON_SKIN_ENABLED", function() GW.ShowRlPopup = true end)

    InitPanel(p, true)
end
GW.LoadSkinsPanel = LoadSkinsPanel
