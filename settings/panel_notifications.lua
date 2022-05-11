local _, GW = ...
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local L = GW.L


local function LoadNotificationsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(nil)

    createCat(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, L["Edit your GW2 notifications."], p, 11, nil, {p})

    local soundKeys = {}
    for _, sound in next, GW.Libs.LSM:List("sound") do
        tinsert(soundKeys, sound)
    end

    addOption(p.scroll.scrollchild, L["Level up"], nil, "ALERTFRAME_NOTIFICATION_LEVEL_UP", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Level up alert"],
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
        L["New spell alert"],
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
        L["New mail alert"],
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
        L["Repair needed alert"],
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
        L["Paragon chest alert"],
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
        L["Rare on minimap alert"],
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
        L["Calendar invite alert"],
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

    InitPanel(p, true)
end
GW.LoadNotificationsPanel = LoadNotificationsPanel