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

    addOption(p.scroll.scrollchild, L["Bots"], nil, {getterSetter = "alertFrameNotificatioBot", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "alertFrameNotificatioBotSound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["alertFrameNotificatioBot"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, L["Feasts"], nil, {getterSetter = "alertFrameNotificatioFeast", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "alertFrameNotificatioFeastSound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["alertFrameNotificatioFeast"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, PLAYER_LEVEL_UP, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_LEVEL_UP", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_LEVEL_UP_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_LEVEL_UP"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, L["New spell"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_SPELL", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_SPELL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_NEW_SPELL"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, L["New mail"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_MAIL", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_MAIL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_NEW_MAIL"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, L["Repair needed"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_REPAIR", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_REPAIR_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_REPAIR"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, L["Paragon chest"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_PARAGON", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_PARAGON_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_PARAGON"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, L["Rare on minimap"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RARE", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RARE_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_RARE"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, L["Calendar invite"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALENDAR_INVITE", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALENDAR_INVITE_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_CALENDAR_INVITE"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, BATTLEGROUND_HOLIDAY, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALL_TO_ARMS", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALL_TO_ARMS_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_CALL_TO_ARMS"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, L["Mage table"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_TABLE", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_TABLE_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_MAGE_TABLE"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, L["Ritual of Summoning"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, L["Soulwell"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_SPOULWELL", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_SPOULWELL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_SPOULWELL"] = true}, isSound = true, noNewLine = true})

    addOption(p.scroll.scrollchild, L["Mage portal"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_PORTAL", dependence = {["ALERTFRAME_ENABLED"] = true}})
    addOptionDropdown(p.scroll.scrollchild, nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_PORTAL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_MAGE_PORTAL"] = true}, isSound = true, noNewLine = true})

    InitPanel(p, true)
end
GW.LoadNotificationsPanel = LoadNotificationsPanel
