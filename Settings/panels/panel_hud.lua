---@class GW2
local GW = select(2, ...)
local L = GW.L

-- Applies the chosen combat text mode (cvars + format toggle); shared by the
-- settings dropdown and the installer combat text step
local function ApplyCombatTextMode(value)
    if value == "GW2" then
        C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
        if GW.settings.combatText.showHealing then
            C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
        else
            C_CVar.SetCVar("floatingCombatTextCombatHealing", "1")
        end
        GW.FloatingCombatTextToggleFormat(true)
    elseif value == "BLIZZARD" then
        C_CVar.SetCVar("floatingCombatTextCombatDamage", "1")
        C_CVar.SetCVar("floatingCombatTextCombatHealing", "1")
        GW.FloatingCombatTextToggleFormat(false)
    else
        C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
        C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
        GW.FloatingCombatTextToggleFormat(false)
    end
end
GW.ApplyCombatTextMode = ApplyCombatTextMode
GW.COMBAT_TEXT_MODES = { "GW2", "BLIZZARD", "OFF" }
GW.COMBAT_TEXT_MODE_NAMES = { GW.addonName, "Blizzard", OFF .. " / " .. OTHER .. " " .. ADDONS }

local function LoadHudPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local general = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    general.panelId = "hud_general"
    general.header:SetFont(DAMAGE_TEXT_FONT, 20)
    general.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    general.header:SetText(UIOPTIONS_MENU)
    general.sub:SetFont(UNIT_NAME_FONT, 12)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    general.breadcrumb:SetText(GENERAL)

    local microBar = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    microBar.panelId = "hud_microbar"
    microBar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    microBar.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    microBar.header:SetText(UIOPTIONS_MENU)
    microBar.sub:SetFont(UNIT_NAME_FONT, 12)
    microBar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    microBar.sub:SetText(L["Edit micro bar settings."])
    microBar.header:SetWidth(microBar.header:GetStringWidth())
    microBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    microBar.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    microBar.breadcrumb:SetText(L["Micro Bar"])

    local chatBubbles = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    chatBubbles.panelId = "hud_chatbubbles"
    chatBubbles.header:SetFont(DAMAGE_TEXT_FONT, 20)
    chatBubbles.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    chatBubbles.header:SetText(UIOPTIONS_MENU)
    chatBubbles.sub:SetFont(UNIT_NAME_FONT, 12)
    chatBubbles.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    chatBubbles.sub:SetText(L["Edit chat bubble settings."])
    chatBubbles.header:SetWidth(chatBubbles.header:GetStringWidth())
    chatBubbles.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    chatBubbles.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    chatBubbles.breadcrumb:SetText(CHAT_BUBBLES_TEXT)

    local minimap = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    minimap.panelId = "hud_minimap"
    minimap.header:SetFont(DAMAGE_TEXT_FONT, 20)
    minimap.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    minimap.header:SetText(UIOPTIONS_MENU)
    minimap.sub:SetFont(UNIT_NAME_FONT, 12)
    minimap.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    minimap.sub:SetText(L["Edit minimap settings."])
    minimap.header:SetWidth(minimap.header:GetStringWidth())
    minimap.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    minimap.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    minimap.breadcrumb:SetText(MINIMAP_LABEL)

    local worldmap = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    worldmap.panelId = "hud_worldmap"
    worldmap.header:SetFont(DAMAGE_TEXT_FONT, 20)
    worldmap.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    worldmap.header:SetText(UIOPTIONS_MENU)
    worldmap.sub:SetFont(UNIT_NAME_FONT, 12)
    worldmap.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    worldmap.sub:SetText(L["Edit world map settings."])
    worldmap.header:SetWidth(worldmap.header:GetStringWidth())
    worldmap.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    worldmap.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    worldmap.breadcrumb:SetText(WORLDMAP_BUTTON)

    local worldEvents = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    worldEvents.panelId = "hud_worldevents"
    worldEvents.header:SetFont(DAMAGE_TEXT_FONT, 20)
    worldEvents.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    worldEvents.header:SetText(UIOPTIONS_MENU)
    worldEvents.sub:SetFont(UNIT_NAME_FONT, 12)
    worldEvents.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    worldEvents.sub:SetText(L["Edit world event tracker settings."])
    worldEvents.header:SetWidth(worldEvents.header:GetStringWidth())
    worldEvents.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    worldEvents.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    worldEvents.breadcrumb:SetText(L["World Events"])

    local fct = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    fct.panelId = "hud_fct"
    fct.header:SetFont(DAMAGE_TEXT_FONT, 20)
    fct.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    fct.header:SetText(UIOPTIONS_MENU)
    fct.sub:SetFont(UNIT_NAME_FONT, 12)
    fct.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    fct.sub:SetText(COMBATTEXT_SUBTEXT)
    fct.header:SetWidth(fct.header:GetStringWidth())
    fct.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    fct.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    fct.breadcrumb:SetText(COMBAT_TEXT_LABEL)


    local questing = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    questing.panelId = "hud_questing"
    questing.header:SetFont(DAMAGE_TEXT_FONT, 20)
    questing.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    questing.header:SetText(UIOPTIONS_MENU)
    questing.sub:SetFont(UNIT_NAME_FONT, 12)
    questing.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    questing.sub:SetText(L["Edit Immersive quest settings."])
    questing.header:SetWidth(questing.header:GetStringWidth())
    questing.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    questing.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    questing.breadcrumb:SetText(L["Immersive Questing"])


    --GENERAL
    general:AddOption(XPBAR_LABEL, nil, {getterSetter = "hud.xpBar", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    general:AddOption(L["Show HUD background"], L["The HUD background changes color in the following situations: In Combat, Not In Combat, In Water, Low HP, Ghost"], {getterSetter = "hud.background", callback = GW.ToggleHudBackground})
    general:AddOption(L["Dynamic HUD"], L["Enable or disable the dynamically changing HUD background."], {getterSetter = "hud.dynamicBackground", dependence = {["hud.background"] = true}})
    general:AddOption(L["Mark Quest Reward"], L["Marks the most valuable quest reward with a gold coin."], {getterSetter = "general.questRewardMostValueIcon", callback = GW.ResetQuestRewardMostValueIcon})
    general:AddOption(L["XP Quest Percent"], L["Shows the xp you got from that quest in % based on your current needed xp for next level."], {getterSetter = "general.questXpPercent"})
    general:AddOption(L["Toggle the borders around the screen"], nil, {getterSetter = "hud.screenBorder", callback = GW.ToggleHudBackground})
    general:AddOption(L["Fade Group Manage Button"], L["The Group Manage Button will fade when you move the cursor away."], {getterSetter = "hud.fadeGroupManageButton", callback = GW.ToggleRaidControllFrame, dependence = {["unitframes.party.enabled"] = true}})
    general:AddOption(L["Pixel Perfect Mode"], L["Scales the UI into a Pixel Perfect Mode. This is dependent on screen resolution."], {getterSetter = "general.pixelPerfection", callback = function() C_CVar.SetCVar("useUiScale", "0") GW.PixelPerfection() end})
    general:AddOptionSlider(L["HUD Scale"], L["Change the HUD size."], { getterSetter = "hud.scale", callback = function() GW.UpdateHudScale(); GW.ShowRlPopup = true end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01})
    general:AddOptionButton(L["Apply to all"], L["Applies the UI scale to all frames which can be scaled in 'Move HUD' mode."], {callback =
        function()
            local scale = GW.settings.hud.scale
            for _, mf in pairs(GW.scaleableFrames) do
                mf.parent:SetScale(scale)
                mf:SetScale(scale)
                GW.GetSetting(mf.setting).scale = scale
            end
        end})
    general:AddOptionDropdown(L["Show Role Bar"], L["Whether to display a floating bar showing your group or raid's role composition. This can be moved via the 'Move HUD' interface."], { getterSetter = "roleBar.mode", callback = GW.UpdateRaidCounterVisibility, optionsList = {"ALWAYS", "NEVER", "IN_GROUP", "IN_RAID", "IN_RAID_IN_PARTY"}, optionNames = {ALWAYS, NEVER, AGGRO_WARNING_IN_PARTY, L["Raid Only"], L["Party / Raid"]}})
    general:AddOptionSlider(L["Talking Head Scale"], nil, { getterSetter = "skins.talkingHead.scale", callback = GW.ScaleTalkingHeadFrame, min = 0.5, max = 2, decimalNumbers = 2, step = 0.01, dependence = {["skins.talkingHead.enabled"] = true}, hidden = not GW.Retail})

    -- MICRO BAR
    microBar:AddOption(ENABLE, L["Micro Bar"], {getterSetter = "micromenu.enabled", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    microBar:AddOption(L["Fade Menu Bar"], L["The main menu icons will fade when you move your cursor away."], {
        getterSetter = "micromenu.fade",
        callback = function(value)
            if Gw2MicroBarFrame and Gw2MicroBarFrame.cf then
                Gw2MicroBarFrame.cf:SetAttribute("shouldFade", value)
                Gw2MicroBarFrame.cf:SetShown(not value)
                if value then
                    Gw2MicroBarFrame.cf.fadeOut(Gw2MicroBarFrame.cf)
                else
                    Gw2MicroBarFrame.cf.fadeIn(Gw2MicroBarFrame.cf)
                end
            end
        end,
        dependence = {["micromenu.enabled"] = true}
    })
    microBar:AddOption(GW.NewSign .. L["Show Background"], nil, {
        getterSetter = "micromenu.showBackground",
        callback = function() GW.UpdateMicroBarOrientation() end,
        dependence = {["micromenu.enabled"] = true}
    })
    microBar:AddOptionDropdown(GW.NewSign .. L["Orientation"], nil, {
        getterSetter = "micromenu.orientation",
        callback = function()
            GW.UpdateMicroBarOrientation()
            GW.LayoutMicroButtons()
        end,
        optionsList = {"HORIZONTAL", "VERTICAL"},
        optionNames = {L["Horizontal"], L["Vertical"]},
        dependence = {["micromenu.enabled"] = true}
    })
    microBar:AddOption(L["Show event timer micro menu icon"], L["Displays an micro menu icon for the world map event timers"], {
        getterSetter = "micromenu.eventTimerIcon",
        callback = function()
            if Gw2MicroBarFrame and Gw2MicroBarFrame.cf then
                GW.ToggleEventTimerMicroMenuIcon(Gw2MicroBarFrame.cf)
            end
        end,
        hidden = not GW.Retail,
        dependence = {["micromenu.enabled"] = true}
    })
    local microBarSlotKeys, microBarSlotNames = {}, {}
    for _, slot in ipairs(GW.MicroBarLayout or {}) do
        tinsert(microBarSlotKeys, slot.key)
        tinsert(microBarSlotNames, GW.GetMicroBarSlotName(slot.key))
    end
    microBar:AddOptionSortableList(GW.NewSign .. L["Micro bar buttons"], L["Set the order of the micro bar buttons, uncheck a button to hide it."], {
        getterSetter = "micromenu.buttonOrder",
        callback = function()
            if GW.LayoutMicroButtons then
                GW.LayoutMicroButtons()
            end
        end,
        optionsList = microBarSlotKeys,
        optionNames = microBarSlotNames,
        toggle = {
            get = function(key) return GW.settings.micromenu.buttonVisibility[key] ~= false end,
            set = function(key, enabled)
                -- only hidden buttons are stored, a visible one falls back to the default
                if enabled then
                    GW.settings.micromenu.buttonVisibility[key] = nil
                else
                    GW.settings.micromenu.buttonVisibility[key] = false
                end
            end,
        },
        maxVisibleRows = 8,
        dependence = {["micromenu.enabled"] = true}
    })
    microBar:AddOptionButton(L["Reset micro bar layout"], L["Restores the default order and shows all buttons."], {
        callback = function()
            wipe(GW.settings.micromenu.buttonOrder)
            wipe(GW.settings.micromenu.buttonVisibility)
            local widget = GW.FindSettingsWidgetByOption("micromenu.buttonOrder")
            if widget and widget.RefreshList then
                widget:RefreshList()
            end
            if GW.LayoutMicroButtons then
                GW.LayoutMicroButtons()
            end
        end,
        isNegativeButton = true,
        forceNewLine = true,
        dependence = {["micromenu.enabled"] = true}
    })
    microBar:AddOption(GW.NewSign .. L["Show update notifications"], L["Chat notice and flashing icon when a group or guild member runs a newer GW2 UI version. The update icon itself stays visible."], {
        getterSetter = "micromenu.updateNotification",
        dependence = {["micromenu.enabled"] = true}
    })
    microBar:AddOption(L["Animate micro menu notification icons"], L["Play entrance animations and flashes for micro menu notification icons (mail, great vault, collections, encounter journal and work orders)."], {
        getterSetter = "micromenu.notificationIconAnimation",
        callback = GW.ToggleMicroMenuNotificationIconAnimation,
        dependence = {["micromenu.enabled"] = true}
    })

    -- CHAT BUBBLES
    chatBubbles:AddOption(ENABLE, L["Replace the default UI chat bubbles. (Only in not protected areas)"], {getterSetter = "chat.bubbles.enabled", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    chatBubbles:AddOptionSlider(GW.NewSign .. L["Chatbubble Scale"], nil, { getterSetter = "chat.bubbles.scale", min = 0.5, max = 2, decimalNumbers = 2, step = 0.01, dependence = {["chat.bubbles.enabled"] = true}})

    --MINIMAP
    minimap:AddOption(ENABLE, L["Use the GW2 UI Minimap frame."], {getterSetter = "minimap.enabled", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Minimap", isMasterToggle = true})
    minimap:AddOption(L["Addon Compartment"], nil, {getterSetter = "minimap.addonCompartment", callback = GW.HandleAddonCompartmentButton, dependence = {["minimap.enabled"] = true}, incompatibleAddons = "Minimap", hidden = not GW.Retail})
    minimap:AddOption(L["Always show AddOn flyout button"], L["Always show the minimap AddOns flyout button, even when only one AddOn button is available."], {getterSetter = "minimap.addonFlyoutAlways", callback = function() GW.UpdateMinimapButtonsSack() end, dependence = {["minimap.enabled"] = true}, incompatibleAddons = "Minimap"})
    minimap:AddOption(L["Show FPS on minimap"], L["Show FPS on minimap"], {getterSetter = "minimap.fps", callback = GW.ToogleMinimapFpsLable, dependence = {["minimap.enabled"] = true}, incompatibleAddons = "Minimap"})
    minimap:AddOption(L["Disable FPS tooltip"], nil, {getterSetter = "minimap.fpsTooltipDisabled", dependence = {["minimap.enabled"] = true, ["minimap.fps"] = true}, incompatibleAddons = "Minimap"})
    minimap:AddOption(L["Show Coordinates on Minimap"], L["Show Coordinates on Minimap"], {getterSetter = "minimap.coords.enabled", callback = GW.ToogleMinimapCoordsLable, dependence = {["minimap.enabled"] = true}, incompatibleAddons = "Minimap"})
    minimap:AddOptionDropdown(L["Minimap details"], L["Always show Minimap details."], { getterSetter = "minimap.alwaysShowHoverDetails", callback = GW.SetMinimapHover, checkbox = true, optionsList = {"CLOCK", "ZONE", "COORDS"}, optionNames = {TIMEMANAGER_TITLE, ZONE, L["Coordinates"]}, dependence = {["minimap.enabled"] = true}, incompatibleAddons = "Minimap"})
    minimap:AddOptionSlider(L["Minimap Scale"], L["Adjust the scale of the minimap and also the pins. Eg: Quests, Resource nodes, Group members"], { getterSetter = "minimap.scale", callback = function() GW.UpdateMinimapSize() end, min = 0.1, max = 2, decimalNumbers = 2, step = 0.01, dependence = {["minimap.enabled"] = true}})
    minimap:AddOptionSlider(L["Reset Zoom"], L["Reset Minimap Zoom to default value. Set 0 to disable it"], { getterSetter = "minimap.resetZoom", min = 0, max = 15, decimalNumbers = 0, step = 1, dependence = {["minimap.enabled"] = true}})
    minimap:AddOptionSlider(L["Minimap Size"], L["Change the Minimap size."], { getterSetter = "minimap.size", callback = function() GW.UpdateMinimapSize() end, min = 160, max = 420, decimalNumbers = 0, step = 1, dependence = {["minimap.enabled"] = true}})
    minimap:AddOptionSlider(GW.NewSign .. L["Height Percentage"], nil, { getterSetter = "minimap.heightPercentage", callback = function() GW.UpdateMinimapSize() end, min = 1, max = 100, decimalNumbers = 0, step = 1, dependence = {["minimap.enabled"] = true, ["minimap.keepSizeRatio"] = false}})
    minimap:AddOption(GW.NewSign .. L["Keep Size Ratio"], L["With this setting you can no longer move the minimap completely to the top or bottom of the screen. This is not allowed by Blizzard."], {getterSetter = "minimap.keepSizeRatio", callback = function(value) local widget = GW.FindSettingsWidgetByOption("minimap.size"); widget.title:SetText(value == true and L["Minimap Size"] or L["Width"]); GW.UpdateMinimapSize() end, dependence = {["minimap.enabled"] = true}})

    --WORLDMAP
    -- world map coordinates
    worldmap:AddGroupHeader(L["World Map Coordinates"])
    worldmap:AddOption(L["Enable"], nil, {getterSetter = "worldmap.coords.enabled", callback = GW.UpdateWorldMapCoordinateSettings, groupHeaderName = L["World Map Coordinates"]})
    worldmap:AddOptionDropdown(L["Position"], nil, { getterSetter = "worldmap.coords.position", callback = GW.UpdateWorldMapCoordinateSettings, optionsList = {"BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT"}, optionNames = {L["Bottom"],L["Bottom left"], L["Bottom right"], L["Left"], L["Right"], L["Top"], L["Top Left"], L["Top Right"]}, dependence = {["worldmap.coords.enabled"] = true}, groupHeaderName = L["World Map Coordinates"]})
    worldmap:AddOptionSlider(L["X-Offset"], nil, { getterSetter = "worldmap.coords.offsetX", callback = GW.UpdateWorldMapCoordinateSettings, min = -200, max = 200, decimalNumbers = 0, step = 1, groupHeaderName = L["World Map Coordinates"], dependence = {["worldmap.coords.enabled"] = true}})
    worldmap:AddOptionSlider(L["Y-Offset"], nil, { getterSetter = "worldmap.coords.offsetY", callback = GW.UpdateWorldMapCoordinateSettings, min = -200, max = 200, decimalNumbers = 0, step = 1, groupHeaderName = L["World Map Coordinates"], dependence = {["worldmap.coords.enabled"] = true}})

    -- Midnight
    worldEvents:AddGroupHeader(L["Midnight"], {hidden = not GW.Retail})
    --Cursed Surges
    worldEvents:AddSubGroupHeader(L["Cursed Surges"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Cursed Surges"], nil, {getterSetter = "weeklyEvents.cursedSurges.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Cursed Surges"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.cursedSurges.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.cursedSurges.enabled"] = true}, groupHeaderName = L["Cursed Surges"], hidden = not GW.Retail})
    worldEvents:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "weeklyEvents.cursedSurges.alert", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.cursedSurges.enabled"] = true}, groupHeaderName = L["Cursed Surges"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "weeklyEvents.cursedSurges.flashTaskbar", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.cursedSurges.enabled"] = true, ["weeklyEvents.cursedSurges.alert"] = true}, groupHeaderName = L["Cursed Surges"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "weeklyEvents.cursedSurges.stopAlertIfCompleted", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.cursedSurges.enabled"] = true, ["weeklyEvents.cursedSurges.alert"] = true}, groupHeaderName = L["Cursed Surges"], hidden = not GW.Retail})
    worldEvents:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], {getterSetter = "weeklyEvents.cursedSurges.alertSeconds", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Cursed Surges"], dependence = {["weeklyEvents.cursedSurges.enabled"] = true, ["weeklyEvents.cursedSurges.alert"] = true}, hidden = not GW.Retail})

    --Stormarion Assault
    worldEvents:AddSubGroupHeader(L["Stormarion Assault"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Stormarion Assault"], nil, {getterSetter = "weeklyEvents.stormarionAssault.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Stormarion Assault"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.stormarionAssault.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.stormarionAssault.enabled"] = true}, groupHeaderName = L["Stormarion Assault"], hidden = not GW.Retail})
    worldEvents:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "weeklyEvents.stormarionAssault.alert", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.stormarionAssault.enabled"] = true}, groupHeaderName = L["Stormarion Assault"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "weeklyEvents.stormarionAssault.flashTaskbar", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.stormarionAssault.enabled"] = true, ["weeklyEvents.stormarionAssault.alert"] = true}, groupHeaderName = L["Stormarion Assault"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "weeklyEvents.stormarionAssault.stopAlertIfCompleted", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.stormarionAssault.enabled"] = true, ["weeklyEvents.stormarionAssault.alert"] = true}, groupHeaderName = L["Stormarion Assault"], hidden = not GW.Retail})
    worldEvents:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], {getterSetter = "weeklyEvents.stormarionAssault.alertSeconds", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Stormarion Assault"], dependence = {["weeklyEvents.stormarionAssault.enabled"] = true, ["weeklyEvents.stormarionAssault.alert"] = true}, hidden = not GW.Retail})

    -- Weekly
    worldEvents:AddSubGroupHeader(L["Weekly Quest"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Weekly Quest"], nil, {getterSetter = "weeklyEvents.weeklyMN.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Weekly Quest"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.weeklyMN.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.weeklyMN.enabled"] = true}, groupHeaderName = L["Weekly Quest"], hidden = not GW.Retail})

    -- Profession
    worldEvents:AddSubGroupHeader(L["Professions Weekly Quest"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Professions Weekly Quest"], nil, {getterSetter = "weeklyEvents.professionsWeeklyMN.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Professions Weekly Quest"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.professionsWeeklyMN.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.professionsWeeklyMN.enabled"] = true}, groupHeaderName = L["Professions Weekly Quest"], hidden = not GW.Retail})

    -- TWW
    worldEvents:AddGroupHeader(L["The War Within"], {hidden = not GW.Retail})
    -- Weekly
    worldEvents:AddSubGroupHeader(L["Weekly Quest"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Weekly Quest"], nil, {getterSetter = "weeklyEvents.weeklyTWW.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Weekly Quest"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.weeklyTWW.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.weeklyTWW.enabled"] = true}, groupHeaderName = L["Weekly Quest"], hidden = not GW.Retail})

    --Ecological Succession"
    worldEvents:AddSubGroupHeader(L["Ecological Succession"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Ecological Succession"], nil, {getterSetter = "weeklyEvents.ecologicalSuccession.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Ecological Succession"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.ecologicalSuccession.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.ecologicalSuccession.enabled"] = true}, groupHeaderName = L["Ecological Succession"], hidden = not GW.Retail})

    --Nightfall
    worldEvents:AddSubGroupHeader(L["Nightfall"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Nightfall"], nil, {getterSetter = "weeklyEvents.nightFall.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Nightfall"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.nightFall.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.nightFall.enabled"] = true}, groupHeaderName = L["Nightfall"], hidden = not GW.Retail})

    -- Ringing Deeps
    worldEvents:AddSubGroupHeader(L["Ringing Deeps"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Ringing Deeps"], nil, {getterSetter = "weeklyEvents.ringingDeeps.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Ringing Deeps"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.ringingDeeps.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.ringingDeeps.enabled"] = true}, groupHeaderName = L["Ringing Deeps"], hidden = not GW.Retail})

    -- Spreading The Light"
    worldEvents:AddSubGroupHeader(L["Spreading The Light"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Spreading The Light"], nil, {getterSetter = "weeklyEvents.spreadingTheLight.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Spreading The Light"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.spreadingTheLight.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.spreadingTheLight.enabled"] = true}, groupHeaderName = L["Spreading The Light"], hidden = not GW.Retail})

    -- Underworld Operative
    worldEvents:AddSubGroupHeader(L["Underworld Operative"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Underworld Operative"], nil, {getterSetter = "weeklyEvents.underworldOperative.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Underworld Operative"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.underworldOperative.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.underworldOperative.enabled"] = true}, groupHeaderName = L["Underworld Operative"], hidden = not GW.Retail})

    -- Theater Troupe
    worldEvents:AddSubGroupHeader(L["Theater Troupe"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Theater Troupe"], nil, {getterSetter = "weeklyEvents.theaterTroupe.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Theater Troupe"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.theaterTroupe.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.theaterTroupe.enabled"] = true}, groupHeaderName = L["Theater Troupe"], hidden = not GW.Retail})
    worldEvents:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "weeklyEvents.theaterTroupe.alert", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.theaterTroupe.enabled"] = true}, groupHeaderName = L["Theater Troupe"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "weeklyEvents.theaterTroupe.flashTaskbar", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.theaterTroupe.enabled"] = true, ["weeklyEvents.theaterTroupe.alert"] = true}, groupHeaderName = L["Theater Troupe"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "weeklyEvents.theaterTroupe.stopAlertIfCompleted", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.theaterTroupe.enabled"] = true, ["weeklyEvents.theaterTroupe.alert"] = true}, groupHeaderName = L["Theater Troupe"], hidden = not GW.Retail})
    worldEvents:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], {getterSetter = "weeklyEvents.theaterTroupe.alertSeconds", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Theater Troupe"], dependence = {["weeklyEvents.theaterTroupe.enabled"] = true, ["weeklyEvents.theaterTroupe.alert"] = true}, hidden = not GW.Retail})

    --DF
    worldEvents:AddGroupHeader(L["Dragonflight"], {hidden = not GW.Retail})
    -- Community Feast
    worldEvents:AddSubGroupHeader(L["Community Feast"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Community Feast"], nil, {getterSetter = "weeklyEvents.communityFeast.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Community Feast"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.communityFeast.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.communityFeast.enabled"] = true}, groupHeaderName = L["Community Feast"], hidden = not GW.Retail})
    worldEvents:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "weeklyEvents.communityFeast.alert", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.communityFeast.enabled"] = true}, groupHeaderName = L["Community Feast"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "weeklyEvents.communityFeast.flashTaskbar", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.communityFeast.enabled"] = true, ["weeklyEvents.communityFeast.alert"] = true}, groupHeaderName = L["Community Feast"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "weeklyEvents.communityFeast.stopAlertIfCompleted", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.communityFeast.enabled"] = true, ["weeklyEvents.communityFeast.alert"] = true}, groupHeaderName = L["Community Feast"], hidden = not GW.Retail})
    worldEvents:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], {getterSetter = "weeklyEvents.communityFeast.alertSeconds", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Community Feast"], dependence = {["weeklyEvents.communityFeast.enabled"] = true, ["weeklyEvents.communityFeast.alert"] = true}, hidden = not GW.Retail})

    -- Dragonbane Keep
    worldEvents:AddSubGroupHeader(L["Siege On Dragonbane Keep"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Siege On Dragonbane Keep"], nil, {getterSetter = "weeklyEvents.dragonbaneKeep.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Siege On Dragonbane Keep"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.dragonbaneKeep.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.dragonbaneKeep.enabled"] = true}, groupHeaderName = L["Siege On Dragonbane Keep"], hidden = not GW.Retail})
    worldEvents:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "weeklyEvents.dragonbaneKeep.alert", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.dragonbaneKeep.enabled"] = true}, groupHeaderName = L["Siege On Dragonbane Keep"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "weeklyEvents.dragonbaneKeep.flashTaskbar", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.dragonbaneKeep.enabled"] = true, ["weeklyEvents.dragonbaneKeep.alert"] = true}, groupHeaderName = L["Siege On Dragonbane Keep"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "weeklyEvents.dragonbaneKeep.stopAlertIfCompleted", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.dragonbaneKeep.enabled"] = true, ["weeklyEvents.dragonbaneKeep.alert"] = true}, groupHeaderName = L["Siege On Dragonbane Keep"], hidden = not GW.Retail})
    worldEvents:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], { getterSetter = "weeklyEvents.dragonbaneKeep.alertSeconds", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Siege On Dragonbane Keep"], dependence = {["weeklyEvents.dragonbaneKeep.enabled"] = true, ["weeklyEvents.dragonbaneKeep.alert"] = true}, hidden = not GW.Retail})

    -- Researchers Under Fire
    worldEvents:AddSubGroupHeader(L["Researchers"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Researchers"], nil, {getterSetter = "weeklyEvents.researchersUnderFire.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Researchers"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.researchersUnderFire.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.researchersUnderFire.enabled"] = true}, groupHeaderName = L["Researchers"], hidden = not GW.Retail})
    worldEvents:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "weeklyEvents.researchersUnderFire.alert", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.researchersUnderFire.enabled"] = true}, groupHeaderName = L["Researchers"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "weeklyEvents.researchersUnderFire.flashTaskbar", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.researchersUnderFire.enabled"] = true, ["weeklyEvents.researchersUnderFire.alert"] = true}, groupHeaderName = L["Researchers"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "weeklyEvents.researchersUnderFire.stopAlertIfCompleted", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.researchersUnderFire.enabled"] = true, ["weeklyEvents.researchersUnderFire.alert"] = true}, groupHeaderName = L["Researchers"], hidden = not GW.Retail})
    worldEvents:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], { getterSetter = "weeklyEvents.researchersUnderFire.alertSeconds", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Researchers"], dependence = {["weeklyEvents.researchersUnderFire.enabled"] = true, ["weeklyEvents.researchersUnderFire.alert"] = true}, hidden = not GW.Retail})

    -- Time Rift Thaldraszus
    worldEvents:AddSubGroupHeader(L["Time Rift"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Time Rift"], nil, {getterSetter = "weeklyEvents.timeRiftThaldraszus.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Time Rift"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.timeRiftThaldraszus.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.timeRiftThaldraszus.enabled"] = true}, groupHeaderName = L["Time Rift"], hidden = not GW.Retail})
    worldEvents:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "weeklyEvents.timeRiftThaldraszus.alert", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.timeRiftThaldraszus.enabled"] = true}, groupHeaderName = L["Time Rift"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "weeklyEvents.timeRiftThaldraszus.flashTaskbar", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.timeRiftThaldraszus.enabled"] = true, ["weeklyEvents.timeRiftThaldraszus.alert"] = true}, groupHeaderName = L["Time Rift"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "weeklyEvents.timeRiftThaldraszus.stopAlertIfCompleted", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.timeRiftThaldraszus.enabled"] = true, ["weeklyEvents.timeRiftThaldraszus.alert"] = true}, groupHeaderName = L["Time Rift"], hidden = not GW.Retail})
    worldEvents:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], { getterSetter = "weeklyEvents.timeRiftThaldraszus.alertSeconds", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Time Rift"], dependence = {["weeklyEvents.timeRiftThaldraszus.enabled"] = true, ["weeklyEvents.timeRiftThaldraszus.alert"] = true}, hidden = not GW.Retail})

    -- Superbloom
    worldEvents:AddSubGroupHeader(L["Superbloom"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Superbloom"], nil, {getterSetter = "weeklyEvents.superBloom.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Superbloom"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.superBloom.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.superBloom.enabled"] = true}, groupHeaderName = L["Superbloom"], hidden = not GW.Retail})
    worldEvents:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "weeklyEvents.superBloom.alert", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.superBloom.enabled"] = true}, groupHeaderName = L["Superbloom"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "weeklyEvents.superBloom.flashTaskbar", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.superBloom.enabled"] = true, ["weeklyEvents.superBloom.alert"] = true}, groupHeaderName = L["Superbloom"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "weeklyEvents.superBloom.stopAlertIfCompleted", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.superBloom.enabled"] = true, ["weeklyEvents.superBloom.alert"] = true}, groupHeaderName = L["Superbloom"], hidden = not GW.Retail})
    worldEvents:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], { getterSetter = "weeklyEvents.superBloom.alertSeconds", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Superbloom"], dependence = {["weeklyEvents.superBloom.enabled"] = true, ["weeklyEvents.superBloom.alert"] = true}, hidden = not GW.Retail})

    -- Big Dig
    worldEvents:AddSubGroupHeader(L["Big Dig"], {hidden = not GW.Retail})
    worldEvents:AddOption(L["Big Dig"], nil, {getterSetter = "weeklyEvents.bigDig.enabled", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Big Dig"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Desaturate Icon"], L["Desaturate the icon if the event is completed this week."], {getterSetter = "weeklyEvents.bigDig.desaturate", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.bigDig.enabled"] = true}, groupHeaderName = L["Big Dig"], hidden = not GW.Retail})
    worldEvents:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "weeklyEvents.bigDig.alert", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.bigDig.enabled"] = true}, groupHeaderName = L["Big Dig"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "weeklyEvents.bigDig.flashTaskbar", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.bigDig.enabled"] = true, ["weeklyEvents.bigDig.alert"] = true}, groupHeaderName = L["Big Dig"], hidden = not GW.Retail})
    worldEvents:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "weeklyEvents.bigDig.stopAlertIfCompleted", callback = GW.UpdateWorldEventTrackers, dependence = {["weeklyEvents.bigDig.enabled"] = true, ["weeklyEvents.bigDig.alert"] = true}, groupHeaderName = L["Big Dig"], hidden = not GW.Retail})
    worldEvents:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], { getterSetter = "weeklyEvents.bigDig.alertSeconds", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Big Dig"], dependence = {["weeklyEvents.bigDig.enabled"] = true, ["weeklyEvents.bigDig.alert"] = true}, hidden = not GW.Retail})

    --FCT
    fct:AddOptionDropdown(COMBAT_TEXT_LABEL, COMBAT_SUBTEXT, { getterSetter = "combatText.mode", callback = GW.ApplyCombatTextMode, optionsList = GW.COMBAT_TEXT_MODES, optionNames = GW.COMBAT_TEXT_MODE_NAMES, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})

    fct:AddOption(L["Use Blizzard colors"], nil, {getterSetter = "combatText.blizzardColor", callback = GW.UpdateDameTextSettings, dependence = {["combatText.mode"] = "GW2"}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})
    fct:AddOption(L["Show numbers with commas"], nil, {getterSetter = "combatText.commaFormat", callback = GW.UpdateDameTextSettings, dependence = {["combatText.mode"] = "GW2"}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})
    fct:AddOption(L["Show healing numbers"], nil, {getterSetter = "combatText.showHealing", callback = function(value) if value then C_CVar.SetCVar("floatingCombatTextCombatHealing", "0") else C_CVar.SetCVar("floatingCombatTextCombatHealing", "1") end GW.UpdateDameTextSettings() end, dependence = {["combatText.mode"] = "GW2", ["combatText.style"] = {EXPANSION_NAME0, "Stacking"}}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})
    fct:AddOption(L["Shorten values"], nil, {getterSetter = "combatText.shortValues", callback = GW.UpdateDameTextSettings, dependence = {["combatText.mode"] = "GW2"}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})
    fct:AddOption(L["Show spell icons"], nil, {getterSetter = "combatText.showIcons", dependence = {["combatText.mode"] = "GW2"}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})

    fct:AddOptionDropdown(L["GW2 floating combat text style"], nil, { getterSetter = "combatText.style", callback = function()
            local enabled = GW.settings.combatText.mode == "GW2" or GW.settings.combatText.mode == "BLIZZARD" or false
            GW.UpdateDameTextSettings()
            GW.FloatingCombatTextToggleFormat(enabled)
        end, optionsList = {"Default", "Stacking", "Classic"}, optionNames = {DEFAULT, L["Stacking"], EXPANSION_NAME0}, dependence = {["combatText.mode"] = "GW2"}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})
    fct:AddOptionDropdown(L["Classic combat text anchoring"], nil, { getterSetter = "combatText.classicAnchor", callback = function()
            local enabled = GW.settings.combatText.mode == "GW2" or GW.settings.combatText.mode == "BLIZZARD" or false
            GW.UpdateDameTextSettings()
            GW.FloatingCombatTextToggleFormat(enabled)
        end, optionsList = {"Nameplates", "Center"}, optionNames = {NAMEPLATES_LABEL, L["Center of screen"]}, dependence = {["combatText.mode"] = "GW2", ["combatText.style"] = EXPANSION_NAME0}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})

    fct:AddGroupHeader(FONT_SIZE, {groupHeaderName = COMBAT_TEXT_LABEL, hidden = GW.Retail})
    fct:AddOptionSlider(FONT_SIZE, nil, { getterSetter = "combatText.fontSize.normal", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["combatText.mode"] = "GW2"}})
    fct:AddOptionSlider(MISS, nil, { getterSetter = "combatText.fontSize.miss", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["combatText.mode"] = "GW2"}})
    fct:AddOptionSlider(CRIT_ABBR, nil, { getterSetter = "combatText.fontSize.crit", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["combatText.mode"] = "GW2"}})
    fct:AddOptionSlider(BLOCK .. "/" .. ABSORB, nil, { getterSetter = "combatText.fontSize.blockedAbsorbed", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["combatText.mode"] = "GW2"}})
    fct:AddOptionSlider(L["Crit modifier"], nil, { getterSetter = "combatText.fontSize.critModifier", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["combatText.mode"] = "GW2"}})
    fct:AddOptionSlider(L["Pet number modifier"], nil, { getterSetter = "combatText.fontSize.petModifier", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["combatText.mode"] = "GW2"}})

    -- Immersive questing
    questing:AddOption(ENABLE, L["Enable the immersive questing view."], {getterSetter = "immersiveQuesting.enabled", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "ImmersiveQuesting", isMasterToggle = true})
    questing:AddOption(L["Lock Frame"], L["Prevents the Immersive Questing window from being moved from its current position."], {getterSetter = "immersiveQuesting.lockFrame", callback = function() if GwImmersiveQuestFrame then GwImmersiveQuestFrame:applyLockFrame() end end, dependence = {["immersiveQuesting.enabled"] = true}})
    questing:AddOptionSlider(L["Scale"], L["Adjusts the size of the Immersive Questing window."], { getterSetter = "immersiveQuesting.scale", callback = function() if GwImmersiveQuestFrame then GwImmersiveQuestFrame:UiScaleChanged() end end, min = 0.5, max = 2, decimalNumbers = 2, step = 0.05, dependence = {["immersiveQuesting.enabled"] = true}})
    questing:AddOptionDropdown(L["Title Style"], L["Adjusts the style of the title bar."], { getterSetter = "immersiveQuesting.titleStyle", callback = function() if GwImmersiveQuestFrame then GwImmersiveQuestFrame:applyTitleStyle() end end, optionsList = {"DEFAULT", "THIN", "TRANSPARENT"}, optionNames = {DEFAULT, L["Thin"], L["Transparent"]}, dependence = {["immersiveQuesting.enabled"] = true}})
    questing:AddOption(L["Left-Click to Accept/Complete"], L["Determines if left-clicking anywhere in the Immersive Questing window counts the same as clicking on the Accept and Complete Quest buttons."], {getterSetter = "immersiveQuesting.clickAccept", dependence = {["immersiveQuesting.enabled"] = true}})
    questing:AddOption(L["Head Slot Behavior"], L["Determines the default head slot visibility behavior."], {getterSetter = "immersiveQuesting.showHelmet", dependence = {["immersiveQuesting.enabled"] = true}})
    questing:AddOptionDropdown(L["Weapon Behavior"], L["Determines the default weapon visibility behavior."], { getterSetter = "immersiveQuesting.weaponMode", optionsList = {"STOW", "DRAW", "HIDE"}, optionNames = {L["Stow"], L["Draw"], HIDE}, dependence = {["immersiveQuesting.enabled"] = true}})
    questing:AddOptionSlider(L["Scale Player Model"], L["Adjusts the size of the player model for the current character."], { getterSetter = "immersiveQuesting.playerScale", callback = function() if GwImmersiveQuestFrame then GwImmersiveQuestFrame:UiScaleChanged() end end, min = 0.5, max = 2, decimalNumbers = 2, step = 0.05, dependence = {["immersiveQuesting.enabled"] = true}})

    local panels = {
        {name = GENERAL, frame = general},
        {name = L["Micro Bar"], frame = microBar},
        {name = CHAT_BUBBLES_TEXT, frame = chatBubbles},
        {name = MINIMAP_LABEL, frame = minimap},
        {name = WORLDMAP_BUTTON, frame = worldmap},
    }
    if GW.Retail then
        tinsert(panels, {name = L["World Events"], frame = worldEvents})
    end
    tinsert(panels, {name = L["Immersive Questing"], frame = questing})
    if not GW.isModern then
        tinsert(panels, {name = COMBAT_TEXT_LABEL, frame = fct})
    end

    sWindow:AddSettingsPanel(p, UIOPTIONS_MENU, L["Edit the modules in the Heads-Up Display for more customization."], panels)
end
GW.LoadHudPanel = LoadHudPanel
