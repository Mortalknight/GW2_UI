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

    general:AddOption(L["Alert Frames"], nil, {getterSetter = "skins.alertFrame.enabled", callback = function() GW.ShowRlPopup = true end, hidden = GW.Classic or GW.TBC or GW.Wrath})
    general:AddOption(MAINMENU_BUTTON, nil, {getterSetter = "skins.mainMenu.enabled", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(L["Popup notifications"], nil, {getterSetter = "skins.staticPopup.enabled", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(SHOW_BATTLENET_TOASTS, nil, {getterSetter = "skins.bnToast.enabled", callback = function() GW.ShowRlPopup = true end})
    general:AddOption("Drop-Down", nil, {getterSetter = "skins.dropdown.enabled", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(L["Looking for Group notifications"], nil, {getterSetter = "skins.lfgFrames.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    general:AddOption(READY_CHECK, nil, {getterSetter = "skins.readyCheck.enabled", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(L["Talking Head"], nil, {getterSetter = "skins.talkingHead.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    general:AddOption(L["Misc Frames"], nil, {getterSetter = "skins.misc.enabled", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(ADDON_LIST, nil, {getterSetter = "skins.addonList.enabled", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(MINIMAP_TRACKING_MAILBOX, nil, {getterSetter = "skins.mail.enabled", callback = function() GW.ShowRlPopup = true end, hidden = GW.Classic or GW.TBC or GW.Wrath})
    general:AddOption(HELP_FRAME_TITLE, nil, {getterSetter = "skins.helpFrame.enabled", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(GW.NewSign .. SETTINGS_TITLE, nil, {getterSetter = "skins.blizzardOptions.enabled", callback = function() GW.ShowRlPopup = true end})
    general:AddOption(TIMEMANAGER_TITLE, nil, {getterSetter = "skins.timeManager.enabled", callback = function() GW.ShowRlPopup = true end})

    gameFrames:AddOption(QUEST_LOG, nil, {getterSetter = "skins.questLog.enabled", callback = function() GW.ShowRlPopup = true end, hidden = GW.Retail})
    gameFrames:AddOption(FLIGHT_MAP, nil, {getterSetter = "skins.flightMap.enabled", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(LEGACY_BUTTON or "Legacy", nil, {getterSetter = "skins.legacySystem.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Forever})
    gameFrames:AddOption(MACRO, nil, {getterSetter = "skins.macro.enabled", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(BARBERSHOP, nil, {getterSetter = "skins.barberShop.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(INSPECT, nil, {getterSetter = "skins.inspection.enabled", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(DRESSUP_FRAME, nil, {getterSetter = "skins.dressUp.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Socket Frame"], nil, {getterSetter = "skins.socket.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(WORLDMAP_BUTTON, nil, {getterSetter = "skins.worldmap.enabled", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(L["BG Map"], nil, {getterSetter = "skins.battlefieldMap.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Gossip Frame"], nil, {getterSetter = "skins.gossip.enabled", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(ITEM_UPGRADE, nil, {getterSetter = "skins.itemUpgrade.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(MERCHANT, nil, {getterSetter = "skins.merchant.enabled", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(QUEST_TIMERS, nil, {getterSetter = "skins.questTimers.enabled", callback = function() GW.ShowRlPopup = true end, hidden = GW.Retail})
    gameFrames:AddOption(L["Loot Frame"], nil, {getterSetter = "skins.lootFrame.enabled", callback = function() GW.ShowRlPopup = true end})
    gameFrames:AddOption(COOLDOWN_VIEWER_LABEL, nil, {getterSetter = "skins.cooldownManager.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(DEATH_RECAP_TITLE, nil, {getterSetter = "skins.deathRecap.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(ADVENTURE_JOURNAL, nil, {getterSetter = "skins.encounterJournal.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(GW.NewSign .. COLLECTIONS, nil, {getterSetter = "skins.collections.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(COVENANT_SANCTUM_TAB_UPGRADES, nil, {getterSetter = "skins.covenantSanctum.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(COVENANT_PREVIEW_SOULBINDS, nil, {getterSetter = "skins.soulbinds.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Chromie Time Frame"], nil, {getterSetter = "skins.chromieTime.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Allied Races"], nil, {getterSetter = "skins.alliedRaces.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(PVP_WEEKLY_REWARD, nil, {getterSetter = "skins.weeklyRewards.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(LFG_TITLE, nil, {getterSetter = "skins.lfg.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Garrison"], nil, {getterSetter = "skins.orderHallTalents.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(ACHIEVEMENTS, nil, {getterSetter = "skins.achievement.enabled", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "AchievementSkin", hidden = not GW.Retail})
    gameFrames:AddOption(L["Trading post"], nil, {getterSetter = "skins.perkProgram.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Expansion Landing Page"], nil, {getterSetter = "skins.expansionLandingPage.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Generic Trait"], nil, {getterSetter = "skins.genericTraits.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(ADVENTURE_MAP_TITLE, nil, {getterSetter = "skins.adventureMap.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(TALENTS, nil, {getterSetter = "skins.playerSpells.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(AUCTIONS, nil, {getterSetter = "skins.auctionHouse.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(L["Major Factions"], nil, {getterSetter = "skins.majorFaction.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(GW.NewSign .. (DAMAGE_METER_LABEL or ""), nil, {getterSetter = "skins.damageMeter.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    gameFrames:AddOption(GW.NewSign .. L["Calendar"], nil, {getterSetter = "skins.calendar.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})

    addonSkins:AddOption("|cffaaaaaa[AddOn]|r World Quest Tracker", nil, {getterSetter = "skins.wqt.enabled", callback = function() GW.ShowRlPopup = true end, dependence = {["objectives.enabled"] = true}, incompatibleAddons = "Objectives", hidden = not GW.Retail})
    addonSkins:AddOption("|cffaaaaaa[AddOn]|r Immersion", nil, {getterSetter = "skins.immersion.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    addonSkins:AddOption("|cffaaaaaa[AddOn]|r PetTracker", nil, {getterSetter = "skins.petTracker.enabled", callback = function() GW.ShowRlPopup = true end, dependence = {["objectives.enabled"] = true}, incompatibleAddons = "Objectives", hidden = not GW.Retail})
    addonSkins:AddOption("|cffaaaaaa[AddOn]|r Auctionator", nil, {getterSetter = "skins.auctionator.enabled", callback = function() GW.ShowRlPopup = true end, dependence = {["skins.auctionHouse.enabled"] = true}, hidden = not GW.Retail})
    addonSkins:AddOption("|cffaaaaaa[AddOn]|r Todoloo", nil, {getterSetter = "skins.todoloo.enabled", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    addonSkins:AddOption("|cffaaaaaa[AddOn]|r Extended Transmog Sets", nil, {getterSetter = "skins.extendedSets.enabled", callback = function() GW.ShowRlPopup = true end, dependence = {["skins.collections.enabled"] = true}, hidden = not GW.Retail})

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
