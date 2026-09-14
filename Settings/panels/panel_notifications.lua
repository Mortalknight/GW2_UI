---@class GW2
local GW = select(2, ...)
local L = GW.L

local function LoadNotificationsPanel(sWindow)
    if GW.Classic or GW.TBC or GW.Wrath then return end

    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    p.panelId = "notifications_general"
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.header:SetText(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL)
    p.header:SetWidth(p.header:GetStringWidth())
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit vignette notification settings."])
    p.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.breadcrumb:SetText(L["Vignettes"])

    local soundKeys = {}
    for _, sound in next, GW.Libs.LSM:List("sound") do
        tinsert(soundKeys, sound)
    end

    p:AddOption(ENABLE, L["Alert Frames"], {getterSetter = "ALERTFRAME_ENABLED", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    p:AddOption(PLAYER_LEVEL_UP, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_LEVEL_UP", previewFunc = GW.AlertPreviews.LEVEL_UP, dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_LEVEL_UP_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_LEVEL_UP"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["New spell"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_SPELL", previewFunc = GW.AlertPreviews.NEW_SPELL, dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_SPELL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_NEW_SPELL"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["New mail"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_MAIL", previewFunc = GW.AlertPreviews.NEW_MAIL, dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_NEW_MAIL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_NEW_MAIL"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Repair needed"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_REPAIR", previewFunc = GW.AlertPreviews.REPAIR, dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_REPAIR_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_REPAIR"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Paragon chest"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_PARAGON", previewFunc = GW.AlertPreviews.PARAGON, dependence = {["ALERTFRAME_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_PARAGON_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_PARAGON"] = true}, hasSound = true, noNewLine = true, hidden = not GW.Retail})

    p:AddOption(L["Rare on minimap"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RARE", previewFunc = GW.AlertPreviews.RARE, dependence = {["ALERTFRAME_ENABLED"] = true}, hidden = not GW.Retail, group = "rare"})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RARE_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_RARE"] = true}, hasSound = true, noNewLine = true, hidden = not GW.Retail, group = "rare"})
    p:AddOption(L["Rare position in chat"], L["Adds a chat line with a clickable map pin link to the position of the rare."], {getterSetter = "ALERTFRAME_NOTIFICATION_RARE_CHAT", dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_RARE"] = true}, hidden = not GW.Retail, group = "rare", forceNewLine = true})

    p:AddOption(L["Bags full"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_BAGS_FULL", previewFunc = GW.AlertPreviews.BAGS_FULL, dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_BAGS_FULL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_BAGS_FULL"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(RATED_PVP_WEEKLY_VAULT, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_GREAT_VAULT", previewFunc = GW.AlertPreviews.GREAT_VAULT, dependence = {["ALERTFRAME_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_GREAT_VAULT_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_GREAT_VAULT"] = true}, hasSound = true, noNewLine = true, hidden = not GW.Retail})

    p:AddOption(L["Calendar invite"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALENDAR_INVITE", previewFunc = GW.AlertPreviews.CALENDAR_INVITE, dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALENDAR_INVITE_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_CALENDAR_INVITE"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(BATTLEGROUND_HOLIDAY, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALL_TO_ARMS", previewFunc = GW.AlertPreviews.CALL_TO_ARMS, dependence = {["ALERTFRAME_ENABLED"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_CALL_TO_ARMS_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_CALL_TO_ARMS"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Mage Table"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_TABLE", previewFunc = GW.AlertPreviews.MAGE_TABLE, dependence = {["ALERTFRAME_ENABLED"] = true}, hidden = GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_TABLE_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_MAGE_TABLE"] = true}, hasSound = true, noNewLine = true, hidden = GW.Retail})

    p:AddOption(L["Ritual of Summoning"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING", previewFunc = GW.AlertPreviews.RITUAL_OF_SUMMONING, dependence = {["ALERTFRAME_ENABLED"] = true}, hidden = GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING"] = true}, hasSound = true, noNewLine = true, hidden = GW.Retail})

    p:AddOption(L["Soulwell"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_SPOULWELL", previewFunc = GW.AlertPreviews.SPOULWELL, dependence = {["ALERTFRAME_ENABLED"] = true}, hidden = GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_SPOULWELL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_SPOULWELL"] = true}, hasSound = true, noNewLine = true, hidden = GW.Retail})

    p:AddOption(L["Mage portal"], nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_PORTAL", previewFunc = GW.AlertPreviews.MAGE_PORTAL, dependence = {["ALERTFRAME_ENABLED"] = true}, hidden = GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "ALERTFRAME_NOTIFICATION_MAGE_PORTAL_SOUND", optionsList = soundKeys, optionNames = soundKeys, dependence = {["ALERTFRAME_ENABLED"] = true, ["ALERTFRAME_NOTIFICATION_MAGE_PORTAL"] = true}, hasSound = true, noNewLine = true, hidden = GW.Retail})

    -- blizzards toasts have no settings here, the dropdown only shows the chosen one once
    -- nothing is stored: the dropdown falls back to "no option selected" after every pick
    p:AddOptionDropdown(L["Blizzard toast preview"], L["Shows the chosen Blizzard toast once with sample data."], {
        getter = GW.NoOp,
        setter = function(key)
            -- a profile reset hands in the default, nil
            if GW.BlizzardAlertPreviews.show[key] then
                GW.BlizzardAlertPreviews.show[key]()
            end
        end,
        getDefault = function() return nil end,
        optionsList = GW.BlizzardAlertPreviews.keys,
        optionNames = GW.BlizzardAlertPreviews.names,
        startsGroup = true,
    })

    sWindow:AddSettingsPanel(p, COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, L["Edit vignette notification settings."])
end
GW.LoadNotificationsPanel = LoadNotificationsPanel
