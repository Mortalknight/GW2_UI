local _, GW = ...
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local L = GW.L
local settingsMenuAddButton = GW.settingsMenuAddButton;


local function LoadAlerts(panel)
    local p = CreateFrame("Frame", nil, panel, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL)
    p.header:SetWidth(p.header:GetStringWidth())
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(nil)
    p.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.breadcrumb:SetText(L["Vignettes"])

    local soundKeys = {}
    for _, sound in next, GW.Libs.LSM:List("sound") do
        tinsert(soundKeys, sound)
    end

    addOption(p.scroll.scrollchild, PLAYER_LEVEL_UP, nil, "ALERTFRAME_NOTIFICATION_LEVEL_UP", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_LEVEL_UP_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_LEVEL_UP"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, L["New spell"], nil, "ALERTFRAME_NOTIFICATION_NEW_SPELL", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_NEW_SPELL_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_NEW_SPELL"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, L["New mail"], nil, "ALERTFRAME_NOTIFICATION_NEW_MAIL", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_NEW_MAIL_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_NEW_MAIL"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, L["Repair needed"], nil, "ALERTFRAME_NOTIFICATION_REPAIR", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_REPAIR_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_REPAIR"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, L["Paragon chest"], nil, "ALERTFRAME_NOTIFICATION_PARAGON", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_PARAGON_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_PARAGON"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, L["Rare on minimap"], nil, "ALERTFRAME_NOTIFICATION_RARE", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_RARE_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_RARE"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, L["Calendar invite"], nil, "ALERTFRAME_NOTIFICATION_CALENDAR_INVITE", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_CALENDAR_INVITE_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_CALENDAR_INVITE"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, BATTLEGROUND_HOLIDAY, nil, "ALERTFRAME_NOTIFICATION_CALL_TO_ARMS", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_CALL_TO_ARMS_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_CALL_TO_ARMS"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, L["Mage table"], nil, "ALERTFRAME_NOTIFICATION_MAGE_TABLE", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_MAGE_TABLE_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_MAGE_TABLE"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, L["Ritual of Summoning"], nil, "ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, L["Soulwell"], nil, "ALERTFRAME_NOTIFICATION_SPOULWELL", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_SPOULWELL_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_SPOULWELL"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, L["Mage portal"], nil, "ALERTFRAME_NOTIFICATION_MAGE_PORTAL", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "ALERTFRAME_NOTIFICATION_MAGE_PORTAL_SOUND",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_MAGE_PORTAL"] = true},
        nil,
        nil,
        nil,
        nil,
        true,
        true
    )

    return p
end

local function LoadEventTracker(panel)
    local p = CreateFrame("Frame", nil, panel, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL)
    p.header:SetWidth(p.header:GetStringWidth())
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Add trackers for world events in the bottom of world map."])
    p.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.breadcrumb:SetText(L["Dragonflight World Events"])

    addOption(p.scroll.scrollchild, L["Community Feast"], nil, "WORLD_EVENTS_COMMUNITY_FEAST_ENABLED", GW.UpdateWorldEventTrackers)
    addOption(p.scroll.scrollchild, L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], "WORLD_EVENTS_COMMUNITY_FEAST_DESATURATE", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true})
    addOption(p.scroll.scrollchild, COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, "WORLD_EVENTS_COMMUNITY_FEAST_ALERT", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], "WORLD_EVENTS_COMMUNITY_FEAST_STOP_ALERT_IF_COMPLETED", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true, ["WORLD_EVENTS_COMMUNITY_FEAST_ALERT"] = true})
    addOptionSlider(
        p.scroll.scrollchild,
        L["Alert Second"],
        L["Alert will be triggered when the remaining time is less than the set value."],
        "WORLD_EVENTS_COMMUNITY_FEAST_ALERT_SECONDS",
        GW.UpdateWorldEventTrackers,
        0,
        3600,
        nil,
        0,
        {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true, ["WORLD_EVENTS_COMMUNITY_FEAST_ALERT"] = true},
        1
    )

    addOption(p.scroll.scrollchild, L["Siege On Dragonbane Keep"], nil, "WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED", GW.UpdateWorldEventTrackers)
    addOption(p.scroll.scrollchild, L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], "WORLD_EVENTS_DRAGONBANE_KEEP_DESATURATE", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true})
    addOption(p.scroll.scrollchild, COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, "WORLD_EVENTS_DRAGONBANE_KEEP_ALERT", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], "WORLD_EVENTS_DRAGONBANE_KEEP_STOP_ALERT_IF_COMPLETED", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true, ["WORLD_EVENTS_DRAGONBANE_KEEP_ALERT"] = true})
    addOptionSlider(
        p.scroll.scrollchild,
        L["Alert Second"],
        L["Alert will be triggered when the remaining time is less than the set value."],
        "WORLD_EVENTS_DRAGONBANE_KEEP_ALERT_SECONDS",
        GW.UpdateWorldEventTrackers,
        0,
        3600,
        nil,
        0,
        {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true, ["WORLD_EVENTS_DRAGONBANE_KEEP_ALERT"] = true},
        1
    )

    return p
end

local function LoadNotificationsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local alerts = LoadAlerts(p)
    local eventTracker = LoadEventTracker(p)

    createCat(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, L["Edit your GW2 notifications."], p, 11, nil, {alerts, eventTracker})
    settingsMenuAddButton(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, p, 11, nil, {alerts, eventTracker})

    InitPanel(alerts, true)
    InitPanel(eventTracker, true)
end
GW.LoadNotificationsPanel = LoadNotificationsPanel
