---@class GW2
local GW = select(2, ...)
local L = GW.L

local function CreateSkinsSubPanel(parent, panelId, breadcrumb)
    local panel = CreateFrame("Frame", nil, parent, "GwSettingsPanelTmpl")
    panel.panelId = panelId
    panel.header:SetFont(DAMAGE_TEXT_FONT, 20)
    panel.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    panel.header:SetText(L["Skins"])
    panel.sub:SetFont(UNIT_NAME_FONT, 12)
    panel.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    panel.sub:SetText(L["Adjust Skin settings."])
    panel.header:SetWidth(panel.header:GetStringWidth())
    panel.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    panel.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    panel.breadcrumb:SetText(breadcrumb)

    return panel
end

local function LoadSkinsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local general = CreateSkinsSubPanel(p, "skins_general", GENERAL)
    local gameFrames = CreateSkinsSubPanel(p, "skins_game_frames", L["Game Frames"])
    local addonSkins = CreateSkinsSubPanel(p, "skins_addons", ADDONS)

    general:AddOption(L["Alert Frames"], nil, {getterSetter = "ALERTFRAME_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = GW.Classic or GW.TBC or GW.Wrath})
    general:AddOption(MAINMENU_BUTTON, nil, {getterSetter = "MAINMENU_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(L["Popup notifications"], nil, {getterSetter = "STATICPOPUP_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(SHOW_BATTLENET_TOASTS, nil, {getterSetter = "BNTOASTFRAME_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    general:AddOption("Drop-Down", nil, {getterSetter = "DROPDOWN_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(L["Looking for Group notifications"], nil, {getterSetter = "LFG_FRAMES_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    general:AddOption(READY_CHECK, nil, {getterSetter = "READYCHECK_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(L["Talking Head"], nil, {getterSetter = "TALKINGHEAD_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    general:AddOption(L["Misc Frames"], nil, {getterSetter = "MISC_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(ADDON_LIST, nil, {getterSetter = "ADDONLIST_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(MINIMAP_TRACKING_MAILBOX, nil, {getterSetter = "MAIL_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = GW.Classic or GW.TBC or GW.Wrath})
    general:AddOption(HELP_FRAME_TITLE, nil, {getterSetter = "HELPFRAME_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(TIMEMANAGER_TITLE, nil, {getterSetter = "TIMEMANAGER_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})

    gameFrames:AddOption(QUEST_LOG, nil, {getterSetter = "QUESTLOG_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = GW.Retail})
    gameFrames:AddOption(FLIGHT_MAP, nil, {getterSetter = "FLIGHTMAP_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(MACRO, nil, {getterSetter = "MACRO_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(BARBERSHOP, nil, {getterSetter = "BARBERSHOP_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(INSPECT, nil, {getterSetter = "INSPECTION_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = GW.Classic or GW.TBC or GW.Wrath})
    gameFrames:AddOption(DRESSUP_FRAME, nil, {getterSetter = "DRESSUP_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Socket Frame"], nil, {getterSetter = "SOCKET_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(WORLDMAP_BUTTON, nil, {getterSetter = "WORLDMAP_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(L["BG Map"], nil, {getterSetter = "BattlefieldMapSkinEnabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Gossip Frame"], nil, {getterSetter = "GOSSIP_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(ITEM_UPGRADE, nil, {getterSetter = "ITEMUPGRADE_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(MERCHANT, nil, {getterSetter = "MERCHANT_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(QUEST_TIMERS, nil, {getterSetter = "QUESTTIMERS_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = GW.Retail})
    gameFrames:AddOption(L["Loot Frame"], nil, {getterSetter = "LOOTFRAME_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(COOLDOWN_VIEWER_LABEL, nil, {getterSetter = "CooldownManagerSkinEnabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(DEATH_RECAP_TITLE, nil, {getterSetter = "DEATHRECAPFRAME_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(ADVENTURE_JOURNAL, nil, {getterSetter = "ENCOUNTER_JOURNAL_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(COVENANT_SANCTUM_TAB_UPGRADES, nil, {getterSetter = "CONCENANT_SANCTUM_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(COVENANT_PREVIEW_SOULBINDS, nil, {getterSetter = "SOULBINDS_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Chromie Time Frame"], nil, {getterSetter = "CHROMIE_TIME_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Allied Races"], nil, {getterSetter = "ALLIEND_RACES_UI_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(PVP_WEEKLY_REWARD, nil, {getterSetter = "WEEKLY_REWARDS_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(LFG_TITLE, nil, {getterSetter = "LFG_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Garrison"], nil, {getterSetter = "ORDERRHALL_TALENT_FRAME_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(ACHIEVEMENTS, nil, {getterSetter = "ACHIEVEMENT_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "AchievementSkin", hidden = not GW.Retail})
    gameFrames:AddOption(L["Trading post"], nil, {getterSetter = "PERK_PROGRAM_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Expansion Landing Page"], nil, {getterSetter = "EXPANSION_LANDING_PAGE_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Generic Trait"], nil, {getterSetter = "GENERIC_TRAINT_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(ADVENTURE_MAP_TITLE, nil, {getterSetter = "ADVENTURE_MAP_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(TALENTS, nil, {getterSetter = "PLAYER_SPELLS_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(AUCTIONS, nil, {getterSetter = "AuctionHouseSkinEnabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Major Factions"], nil, {getterSetter = "MajorFactionSkinEnabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(GW.NewSign .. (DAMAGE_METER_LABEL or ""), nil, {getterSetter = "DamageMeterSkinEnabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(GW.NewSign .. L["Calendar"], nil, {getterSetter = "CalendarSkinEnabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})

    addonSkins:AddOption("|cffaaaaaa[AddOn]|r World Quest Tracker", nil, {getterSetter = "SKIN_WQT_ENABLED", callback = function() GW.ShowRlPopup = true end, dependence = {["QUESTTRACKER_ENABLED"] = true}, incompatibleAddons = "Objectives", hidden = not GW.Retail})
    addonSkins:AddOption("|cffaaaaaa[AddOn]|r Immersion", nil, {getterSetter = "IMMERSIONADDON_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    addonSkins:AddOption("|cffaaaaaa[AddOn]|r PetTracker", nil, {getterSetter = "SKIN_PETTRACKER_ENABLED", callback = function() GW.ShowRlPopup = true end, dependence = {["QUESTTRACKER_ENABLED"] = true}, incompatibleAddons = "Objectives", hidden = not GW.Retail})
    addonSkins:AddOption("|cffaaaaaa[AddOn]|r Auctionator", nil, {getterSetter = "AUCTIONATOR_SKIN_ENABLED", callback = function() GW.ShowRlPopup = true end, dependence = {["AuctionHouseSkinEnabled"] = true}, hidden = not GW.Retail})
    addonSkins:AddOption("|cffaaaaaa[AddOn]|r Todoloo", nil, {getterSetter = "SKIN_TODOLOO_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})

    local panels = {
        {name = GENERAL, frame = general},
        {name = L["Game Frames"], frame = gameFrames},
    }
    if GW.Retail then
        tinsert(panels, {name = ADDONS, frame = addonSkins})
    end

    sWindow:AddSettingsPanel(p, L["Skins"], L["Adjust Skin settings."], panels)
end
GW.LoadSkinsPanel = LoadSkinsPanel
