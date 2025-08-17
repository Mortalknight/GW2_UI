local _, GW = ...
local L = GW.L


local function LoadNotificationsPanel(sWindow)
    if GW.Classic then return end

    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    p.panelId = "notifications_general"
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

    local soundKeys = {}
    for _, sound in next, GW.Libs.LSM:List("sound") do
        tinsert(soundKeys, sound)
    end

    p:AddOption(L["Bots"], nil, {getterSetter = "alertFrameNotificatioBot", dependence = {["ALERTFRAME_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "alertFrameNotificatioBotSound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["alertFrameNotificatioBot"] = true}, hasSound = true, noNewLine = true, hidden = not GW.Retail})

    p:AddOption(L["Feasts"], nil, {getterSetter = "alertFrameNotificatioFeast", dependence = {["ALERTFRAME_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "alertFrameNotificatioFeastSound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["alertFrameNotificatioFeast"] = true}, hasSound = true, noNewLine = true, hidden = not GW.Retail})

    p:AddOption(PLAYER_LEVEL_UP, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_LEVEL_UP", dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_LEVEL_UP_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_LEVEL_UP"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["New spell"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_SPELL", dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_SPELL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_NEW_SPELL"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["New mail"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_MAIL", dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_MAIL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_NEW_MAIL"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Repair needed"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_REPAIR", dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_REPAIR_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_REPAIR"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Paragon chest"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_PARAGON", dependence = {["ALERTFRAME_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_PARAGON_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_PARAGON"] = true}, hasSound = true, noNewLine = true, hidden = not GW.Retail})

    p:AddOption(L["Rare on minimap"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RARE", dependence = {["ALERTFRAME_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RARE_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_RARE"] = true}, hasSound = true, noNewLine = true, hidden = not GW.Retail})

    p:AddOption(L["Calendar invite"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALENDAR_INVITE", dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALENDAR_INVITE_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_CALENDAR_INVITE"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(BATTLEGROUND_HOLIDAY, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALL_TO_ARMS", dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALL_TO_ARMS_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_CALL_TO_ARMS"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Mage table"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_TABLE", dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_TABLE_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_MAGE_TABLE"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Ritual of Summoning"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING", dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Soulwell"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_SPOULWELL", dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_SPOULWELL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_SPOULWELL"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Mage portal"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_PORTAL", dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_PORTAL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_MAGE_PORTAL"] = true}, hasSound = true, noNewLine = true})

    sWindow:AddSettingsPanel(p, COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL)
end
GW.LoadNotificationsPanel = LoadNotificationsPanel
