---@class GW2
local GW = select(2, ...)
local L = GW.L

local function VignetteName(id, stored)
    if type(stored) == "string" then return stored end
    return GW.VignetteNames[id] or UNKNOWN
end

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

    p:AddOption(ENABLE, L["Alert Frames"], {getterSetter = "notifications.enabled", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    p:AddOption(PLAYER_LEVEL_UP, nil, {getterSetter = "notifications.levelUp.enabled", previewFunc = GW.AlertPreviews.LEVEL_UP, dependence = {["notifications.enabled"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.levelUp.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.levelUp.enabled"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["New spell"], nil, {getterSetter = "notifications.newSpell.enabled", previewFunc = GW.AlertPreviews.NEW_SPELL, dependence = {["notifications.enabled"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.newSpell.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.newSpell.enabled"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["New mail"], nil, {getterSetter = "notifications.newMail.enabled", previewFunc = GW.AlertPreviews.NEW_MAIL, dependence = {["notifications.enabled"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.newMail.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.newMail.enabled"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Repair needed"], nil, {getterSetter = "notifications.repair.enabled", previewFunc = GW.AlertPreviews.REPAIR, dependence = {["notifications.enabled"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.repair.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.repair.enabled"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Paragon chest"], nil, {getterSetter = "notifications.paragon.enabled", previewFunc = GW.AlertPreviews.PARAGON, dependence = {["notifications.enabled"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.paragon.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.paragon.enabled"] = true}, hasSound = true, noNewLine = true, hidden = not GW.Retail})

    p:AddOption(L["Rare on minimap"], nil, {getterSetter = "notifications.rare.enabled", previewFunc = GW.AlertPreviews.RARE, dependence = {["notifications.enabled"] = true}, hidden = not GW.Retail, group = "rare"})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.rare.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.rare.enabled"] = true}, hasSound = true, noNewLine = true, hidden = not GW.Retail, group = "rare"})
    p:AddOption(L["Rare position in chat"], L["Adds a chat line with a clickable map pin link to the position of the rare."], {getterSetter = "notifications.rare.chat", dependence = {["notifications.enabled"] = true, ["notifications.rare.enabled"] = true}, hidden = not GW.Retail, group = "rare", forceNewLine = true})

    p:AddOptionNote(L["Rares on this list get no toast. Shift + right click on a rare toast adds it, the toast tooltip shows the ID."], {group = "rare", hidden = not GW.Retail})
    p:AddOptionIDList(L["Ignored rares"], L["Rares on this list get no toast. Shift + right click on a rare toast adds it, the toast tooltip shows the ID."], {
        getterSetter = "notifications.rare.ignored",
        dependence = {["notifications.enabled"] = true, ["notifications.rare.enabled"] = true},
        hidden = not GW.Retail,
        group = "rare",
        maxVisibleRows = 4,
        invalidInputText = L["Invalid ID"],
        resolveEntry = function(id, stored)
            return {name = VignetteName(id, stored), atlas = "VignetteKill"}
        end,
        entryTooltip = function(tooltip, id, stored)
            tooltip:SetText(VignetteName(id, stored), 1, 1, 1)
            tooltip:AddLine(format("ID %d", id), 0.6, 0.6, 0.6)
        end,
    })

    p:AddOption(L["Bags full"], nil, {getterSetter = "notifications.bagsFull.enabled", previewFunc = GW.AlertPreviews.BAGS_FULL, dependence = {["notifications.enabled"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.bagsFull.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.bagsFull.enabled"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(RATED_PVP_WEEKLY_VAULT, nil, {getterSetter = "notifications.greatVault.enabled", previewFunc = GW.AlertPreviews.GREAT_VAULT, dependence = {["notifications.enabled"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.greatVault.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.greatVault.enabled"] = true}, hasSound = true, noNewLine = true, hidden = not GW.Retail})

    p:AddOption(L["Calendar invite"], nil, {getterSetter = "notifications.calendarInvite.enabled", previewFunc = GW.AlertPreviews.CALENDAR_INVITE, dependence = {["notifications.enabled"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.calendarInvite.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.calendarInvite.enabled"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(BATTLEGROUND_HOLIDAY, nil, {getterSetter = "notifications.callToArms.enabled", previewFunc = GW.AlertPreviews.CALL_TO_ARMS, dependence = {["notifications.enabled"] = true}})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.callToArms.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.callToArms.enabled"] = true}, hasSound = true, noNewLine = true})

    p:AddOption(L["Mage Table"], nil, {getterSetter = "notifications.mageTable.enabled", previewFunc = GW.AlertPreviews.MAGE_TABLE, dependence = {["notifications.enabled"] = true}, hidden = GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.mageTable.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.mageTable.enabled"] = true}, hasSound = true, noNewLine = true, hidden = GW.Retail})

    p:AddOption(L["Ritual of Summoning"], nil, {getterSetter = "notifications.ritualOfSummoning.enabled", previewFunc = GW.AlertPreviews.RITUAL_OF_SUMMONING, dependence = {["notifications.enabled"] = true}, hidden = GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.ritualOfSummoning.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.ritualOfSummoning.enabled"] = true}, hasSound = true, noNewLine = true, hidden = GW.Retail})

    p:AddOption(L["Soulwell"], nil, {getterSetter = "notifications.soulwell.enabled", previewFunc = GW.AlertPreviews.SPOULWELL, dependence = {["notifications.enabled"] = true}, hidden = GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.soulwell.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.soulwell.enabled"] = true}, hasSound = true, noNewLine = true, hidden = GW.Retail})

    p:AddOption(L["Mage portal"], nil, {getterSetter = "notifications.magePortal.enabled", previewFunc = GW.AlertPreviews.MAGE_PORTAL, dependence = {["notifications.enabled"] = true}, hidden = GW.Retail})
    p:AddOptionDropdown(nil, nil, {getterSetter = "notifications.magePortal.sound", optionsList = soundKeys, optionNames = soundKeys, dependence = {["notifications.enabled"] = true, ["notifications.magePortal.enabled"] = true}, hasSound = true, noNewLine = true, hidden = GW.Retail})

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
