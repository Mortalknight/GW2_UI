local _, GW = ...
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local L = GW.L
local settingsMenuAddButton = GW.settingsMenuAddButton;


local function LoadNotificationsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.header:SetText(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL)
    p.header:SetWidth(p.header:GetStringWidth())
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(nil)
    p.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.breadcrumb:SetText(L["Vignettes"])

    createCat(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, L["Edit your GW2 notifications."], p, {p})
    settingsMenuAddButton(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, p, {})

    local soundKeys = {}
    for _, sound in next, GW.Libs.LSM:List("sound") do
        tinsert(soundKeys, sound)
    end


    addOption(p.scroll.scrollchild, GW.NewSign .. L["Bots"], nil, "alertFrameNotificatioBot", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "alertFrameNotificatioBotSound",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["alertFrameNotificatioBot"] = true},
        nil,
        nil,
        nil,
        true,
        true
    )

    addOption(p.scroll.scrollchild, GW.NewSign .. L["Feasts"], nil, "alertFrameNotificatioFeast", nil, nil, {["ALERTFRAME_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        nil,
        nil,
        "alertFrameNotificatioFeastSound",
        nil,
        soundKeys,
        soundKeys,
        nil,
        {["ALERTFRAME_ENABLED"] = true, ["alertFrameNotificatioFeast"] = true},
        nil,
        nil,
        nil,
        true,
        true
    )

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
        true,
        true
    )

    InitPanel(p, true)
end
GW.LoadNotificationsPanel = LoadNotificationsPanel
