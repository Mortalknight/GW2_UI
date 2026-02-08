local _, GW = ...
local L = GW.L

local function LoadHudPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local general = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    general.panelId = "hud_general"
    general.header:SetFont(DAMAGE_TEXT_FONT, 20)
    general.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    general.header:SetText(UIOPTIONS_MENU)
    general.sub:SetFont(UNIT_NAME_FONT, 12)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    general.breadcrumb:SetText(GENERAL)

    local minimap = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    minimap.panelId = "hud_minimap"
    minimap.header:SetFont(DAMAGE_TEXT_FONT, 20)
    minimap.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    minimap.header:SetText(UIOPTIONS_MENU)
    minimap.sub:SetFont(UNIT_NAME_FONT, 12)
    minimap.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    minimap.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    minimap.header:SetWidth(minimap.header:GetStringWidth())
    minimap.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    minimap.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    minimap.breadcrumb:SetText(MINIMAP_LABEL)

    local worldmap = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    worldmap.panelId = "hud_worldmap"
    worldmap.header:SetFont(DAMAGE_TEXT_FONT, 20)
    worldmap.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    worldmap.header:SetText(UIOPTIONS_MENU)
    worldmap.sub:SetFont(UNIT_NAME_FONT, 12)
    worldmap.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    worldmap.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    worldmap.header:SetWidth(worldmap.header:GetStringWidth())
    worldmap.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    worldmap.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    worldmap.breadcrumb:SetText(WORLDMAP_BUTTON)

    local fct = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    fct.panelId = "hud_fct"
    fct.header:SetFont(DAMAGE_TEXT_FONT, 20)
    fct.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    fct.header:SetText(UIOPTIONS_MENU)
    fct.sub:SetFont(UNIT_NAME_FONT, 12)
    fct.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    fct.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    fct.header:SetWidth(fct.header:GetStringWidth())
    fct.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    fct.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    fct.breadcrumb:SetText(COMBAT_TEXT_LABEL)

    --GENERAL
    general:AddOption(L["Show HUD background"], L["The HUD background changes color in the following situations: In Combat, Not In Combat, In Water, Low HP, Ghost"], {getterSetter = "HUD_BACKGROUND", callback = GW.ToggleHudBackground})
    general:AddOption(L["Dynamic HUD"], L["Enable or disable the dynamically changing HUD background."], {getterSetter = "HUD_SPELL_SWAP", dependence = {["HUD_BACKGROUND"] = true}})
    general:AddOption(L["Mark Quest Reward"], L["Marks the most valuable quest reward with a gold coin."], {getterSetter = "QUEST_REWARDS_MOST_VALUE_ICON", callback = GW.ResetQuestRewardMostValueIcon})
    general:AddOption(L["XP Quest Percent"], L["Shows the xp you got from that quest in % based on your current needed xp for next level."], {getterSetter = "QUEST_XP_PERCENT"})
    general:AddOption(L["Fade Menu Bar"], L["The main menu icons will fade when you move your cursor away."], {getterSetter = "FADE_MICROMENU", callback = function(value) Gw2MicroBarFrame.cf:SetAttribute("shouldFade", value) Gw2MicroBarFrame.cf:SetShown(not value) if value then Gw2MicroBarFrame.cf.fadeOut(Gw2MicroBarFrame.cf) else Gw2MicroBarFrame.cf.fadeIn(Gw2MicroBarFrame.cf) end end})
    general:AddOption(L["Show event timer micro menu icon"], L["Displays an micro menu icon for the world map event timers"], {getterSetter = "MICROMENU_EVENT_TIMER_ICON", callback = function() GW.ToggleEventTimerMicroMenuIcon(Gw2MicroBarFrame.cf) end, hidden = not GW.Retail})
    general:AddOption(L["Toggle the borders around the screen"], nil, {getterSetter = "BORDER_ENABLED", callback = GW.ToggleHudBackground})
    general:AddOption(L["Fade Group Manage Button"], L["The Group Manage Button will fade when you move the cursor away."], {getterSetter = "FADE_GROUP_MANAGE_FRAME", callback = GW.ToggleRaidControllFrame, dependence = {["PARTY_FRAMES"] = true}})
    general:AddOption(L["Singing Sockets Info"], L["Adds a Singing sockets selection tool on the Socketing Frame"], {getterSetter = "singingSockets", hidden = not GW.Retail})
    general:AddOption(L["Pixel Perfect Mode"], L["Scales the UI into a Pixel Perfect Mode. This is dependent on screen resolution."], {getterSetter = "PIXEL_PERFECTION", callback = function() C_CVar.SetCVar("useUiScale", "0") GW.PixelPerfection() end})
    general:AddOptionSlider(L["HUD Scale"], L["Change the HUD size."], { getterSetter = "HUD_SCALE", callback = function() GW.UpdateHudScale(); GW.ShowRlPopup = true end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01})
    general:AddOptionButton(L["Apply to all"], L["Applies the UI scale to all frames which can be scaled in 'Move HUD' mode."], {callback =
        function()
            local scale = GW.settings.HUD_SCALE
            for _, mf in pairs(GW.scaleableFrames) do
                mf.parent:SetScale(scale)
                mf:SetScale(scale)
                GW.settings[mf.setting .."_scale"] = scale
            end
        end})
    general:AddOptionDropdown(L["Show Role Bar"], L["Whether to display a floating bar showing your group or raid's role composition. This can be moved via the 'Move HUD' interface."], { getterSetter = "ROLE_BAR", callback = GW.UpdateRaidCounterVisibility, optionsList = {"ALWAYS", "NEVER", "IN_GROUP", "IN_RAID", "IN_RAID_IN_PARTY"}, optionNames = {ALWAYS, NEVER, AGGRO_WARNING_IN_PARTY, L["Raid Only"], L["Party / Raid"]}})
    general:AddOptionSlider(L["Talking Head Scale"], nil, { getterSetter = "TalkingHeadFrameScale", callback = GW.ScaleTalkingHeadFrame, min = 0.5, max = 2, decimalNumbers = 2, step = 0.01, dependence = {["TALKINGHEAD_SKIN_ENABLED"] = true}, hidden = not GW.Retail})
    general:AddOptionSlider(GW.NewSign .. L["Chatbubble Scale"], nil, { getterSetter = "ChatBubbleScale", min = 0.5, max = 2, decimalNumbers = 2, step = 0.01, dependence = {["CHATBUBBLES_ENABLED"] = true}, hidden = not GW.Retail})

    --MINIMAP
    minimap:AddOption(L["Addon Compartment"], nil, {getterSetter = "MINIMAP_ADDON_COMPARTMENT_TOGGLE", callback = GW.HandleAddonCompartmentButton, dependence = {["MINIMAP_ENABLED"] = true}, incompatibleAddons = "Minimap", hidden = not GW.Retail})
    minimap:AddOption(L["Show FPS on minimap"], L["Show FPS on minimap"], {getterSetter = "MINIMAP_FPS", callback = GW.ToogleMinimapFpsLable, dependence = {["MINIMAP_ENABLED"] = true}, incompatibleAddons = "Minimap"})
    minimap:AddOption(L["Disable FPS tooltip"], nil, {getterSetter = "MINIMAP_FPS_TOOLTIP_DISABLED", dependence = {["MINIMAP_ENABLED"] = true, ["MINIMAP_FPS"] = true}, incompatibleAddons = "Minimap"})
    minimap:AddOption(L["Show Coordinates on Minimap"], L["Show Coordinates on Minimap"], {getterSetter = "MINIMAP_COORDS_TOGGLE", callback = GW.ToogleMinimapCoordsLable, dependence = {["MINIMAP_ENABLED"] = true}, incompatibleAddons = "Minimap"})
    minimap:AddOptionDropdown(L["Minimap details"], L["Always show Minimap details."], { getterSetter = "MINIMAP_ALWAYS_SHOW_HOVER_DETAILS", callback = GW.SetMinimapHover, checkbox = true, optionsList = {"CLOCK", "ZONE", "COORDS"}, optionNames = {TIMEMANAGER_TITLE, ZONE, L["Coordinates"]}, dependence = {["MINIMAP_ENABLED"] = true}, incompatibleAddons = "Minimap"})
    minimap:AddOptionSlider(L["Minimap Scale"], L["Adjust the scale of the minimap and also the pins. Eg: Quests, Resource nodes, Group members"], { getterSetter = "MinimapScale", callback = function() GW.UpdateMinimapSize() end, min = 0.1, max = 2, decimalNumbers = 2, step = 0.01, dependence = {["MINIMAP_ENABLED"] = true}})
    minimap:AddOptionSlider(L["Reset Zoom"], L["Reset Minimap Zoom to default value. Set 0 to disable it"], { getterSetter = "MinimapResetZoom", min = 0, max = 15, decimalNumbers = 0, step = 1, dependence = {["MINIMAP_ENABLED"] = true}})
    minimap:AddOptionSlider(L["Minimap Size"], L["Change the Minimap size."], { getterSetter = "MINIMAP_SIZE", callback = function() GW.UpdateMinimapSize() end, min = 160, max = 420, decimalNumbers = 0, step = 1, dependence = {["MINIMAP_ENABLED"] = true}})
    minimap:AddOptionSlider(GW.NewSign .. L["Height Percentage"], nil, { getterSetter = "Minimap.HeightPercentage", callback = function() GW.UpdateMinimapSize() end, min = 1, max = 100, decimalNumbers = 0, step = 1, dependence = {["MINIMAP_ENABLED"] = true, ["Minimap.KeepSizeRatio"] = false}})
    minimap:AddOption(GW.NewSign .. L["Keep Size Ratio"], L["With this setting you are not able anymore to move the minimap complety to othe top or buttom of the screen. This is not allowed from Blizzard."], {getterSetter = "Minimap.KeepSizeRatio", callback = function(value) local widget = GW.FindSettingsWidgetByOption("MINIMAP_SIZE"); widget.title:SetText(value == true and L["Minimap Size"] or L["Width"]); GW.UpdateMinimapSize() end, dependence = {["MINIMAP_ENABLED"] = true}})

    --WORLDMAP
    -- world map coordinates
    worldmap:AddGroupHeader(L["World Map Coordinates"])
    worldmap:AddOption(L["Enable"], nil, {getterSetter = "WORLDMAP_COORDS_TOGGLE", callback = GW.UpdateWorldMapCoordinateSettings, groupHeaderName = L["World Map Coordinates"]})
    worldmap:AddOptionDropdown(L["Position"], nil, { getterSetter = "WORLDMAP_COORDS_POSITION", callback = GW.UpdateWorldMapCoordinateSettings, optionsList = {"BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT"}, optionNames = {L["Bottom"],L["Bottom left"], L["Bottom right"], L["Left"], L["Right"], L["Top"], L["Top Left"], L["Top Right"]}, dependence = {["WORLDMAP_COORDS_TOGGLE"] = true}, groupHeaderName = L["World Map Coordinates"]})
    worldmap:AddOptionSlider(L["X-Offset"], nil, { getterSetter = "WORLDMAP_COORDS_X_OFFSET", callback = GW.UpdateWorldMapCoordinateSettings, min = -200, max = 200, decimalNumbers = 0, step = 1, groupHeaderName = L["World Map Coordinates"], dependence = {["WORLDMAP_COORDS_TOGGLE"] = true}})
    worldmap:AddOptionSlider(L["Y-Offset"], nil, { getterSetter = "WORLDMAP_COORDS_Y_OFFSET", callback = GW.UpdateWorldMapCoordinateSettings, min = -200, max = 200, decimalNumbers = 0, step = 1, groupHeaderName = L["World Map Coordinates"], dependence = {["WORLDMAP_COORDS_TOGGLE"] = true}})

    -- Theater Troupe
    worldmap:AddGroupHeader(L["Khaz Algar Emissary"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Khaz Algar Emissary"], nil, {getterSetter = "WORLD_EVENTS_KHAZ_ALGAR_EMISSARY_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Khaz Algar Emissary"], hidden = not GW.Retail})
    worldmap:AddOption(L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], {getterSetter = "WORLD_EVENTS_KHAZ_ALGAR_EMISSARY_DESATURATE", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_KHAZ_ALGAR_EMISSARY_ENABLED"] = true}, groupHeaderName = L["Khaz Algar Emissary"], hidden = not GW.Retail})

    -- Theater Troupe
    worldmap:AddGroupHeader(L["Ringing Deeps"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Ringing Deeps"], nil, {getterSetter = "WORLD_EVENTS_RINGING_DEEPS_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Ringing Deeps"], hidden = not GW.Retail})
    worldmap:AddOption(L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], {getterSetter = "WORLD_EVENTS_RINGING_DEEPS_DESATURATE", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_RINGING_DEEPS_ENABLED"] = true}, groupHeaderName = L["Ringing Deeps"], hidden = not GW.Retail})

    -- Theater Troupe
    worldmap:AddGroupHeader(L["Spreading The Light"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Spreading The Light"], nil, {getterSetter = "WORLD_EVENTS_SPREADING_THE_LIGHT_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Spreading The Light"], hidden = not GW.Retail})
    worldmap:AddOption(L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], {getterSetter = "WORLD_EVENTS_SPREADING_THE_LIGHT_DESATURATE", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_SPREADING_THE_LIGHT_ENABLED"] = true}, groupHeaderName = L["Spreading The Light"], hidden = not GW.Retail})

    -- Theater Troupe
    worldmap:AddGroupHeader(L["Underworld Operative"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Underworld Operative"], nil, {getterSetter = "WORLD_EVENTS_UNDERWORLD_OPERATIVE_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Underworld Operative"], hidden = not GW.Retail})
    worldmap:AddOption(L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], {getterSetter = "WORLD_EVENTS_UNDERWORLD_OPERATIVE_DESATURATE", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_UNDERWORLD_OPERATIVE_ENABLED"] = true}, groupHeaderName = L["Underworld Operative"], hidden = not GW.Retail})

    -- Theater Troupe
    worldmap:AddGroupHeader(L["Theater Troupe"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Theater Troupe"], nil, {getterSetter = "WORLD_EVENTS_THEATER_TROUPE_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Theater Troupe"], hidden = not GW.Retail})
    worldmap:AddOption(L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], {getterSetter = "WORLD_EVENTS_THEATER_TROUPE_DESATURATE", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_THEATER_TROUPE_ENABLED"] = true}, groupHeaderName = L["Theater Troupe"], hidden = not GW.Retail})
    worldmap:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "WORLD_EVENTS_THEATER_TROUPE_ALERT", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_THEATER_TROUPE_ENABLED"] = true}, groupHeaderName = L["Theater Troupe"], hidden = not GW.Retail})
    worldmap:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "WORLD_EVENTS_THEATER_TROUPE_FLASH_TASKBAR", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_THEATER_TROUPE_ENABLED"] = true, ["WORLD_EVENTS_THEATER_TROUPE_ALERT"] = true}, groupHeaderName = L["Theater Troupe"], hidden = not GW.Retail})
    worldmap:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "WORLD_EVENTS_THEATER_TROUPE_STOP_ALERT_IF_COMPLETED", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_THEATER_TROUPE_ENABLED"] = true, ["WORLD_EVENTS_THEATER_TROUPE_ALERT"] = true}, groupHeaderName = L["Theater Troupe"], hidden = not GW.Retail})
    worldmap:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], {getterSetter = "WORLD_EVENTS_THEATER_TROUPE_ALERT_SECONDS", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Theater Troupe"], dependence = {["WORLD_EVENTS_THEATER_TROUPE_ENABLED"] = true, ["WORLD_EVENTS_THEATER_TROUPE_ALERT"] = true}, hidden = not GW.Retail})

    -- Community Feast
    worldmap:AddGroupHeader(L["Community Feast"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Community Feast"], nil, {getterSetter = "WORLD_EVENTS_COMMUNITY_FEAST_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Community Feast"], hidden = not GW.Retail})
    worldmap:AddOption(L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], {getterSetter = "WORLD_EVENTS_COMMUNITY_FEAST_DESATURATE", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true}, groupHeaderName = L["Community Feast"], hidden = not GW.Retail})
    worldmap:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "WORLD_EVENTS_COMMUNITY_FEAST_ALERT", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true}, groupHeaderName = L["Community Feast"], hidden = not GW.Retail})
    worldmap:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "WORLD_EVENTS_COMMUNITY_FEAST_FLASH_TASKBAR", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true, ["WORLD_EVENTS_COMMUNITY_FEAST_ALERT"] = true}, groupHeaderName = L["Community Feast"], hidden = not GW.Retail})
    worldmap:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "WORLD_EVENTS_COMMUNITY_FEAST_STOP_ALERT_IF_COMPLETED", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true, ["WORLD_EVENTS_COMMUNITY_FEAST_ALERT"] = true}, groupHeaderName = L["Community Feast"], hidden = not GW.Retail})
    worldmap:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], {getterSetter = "WORLD_EVENTS_COMMUNITY_FEAST_ALERT_SECONDS", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Community Feast"], dependence = {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true, ["WORLD_EVENTS_COMMUNITY_FEAST_ALERT"] = true}, hidden = not GW.Retail})

    -- Dragonbane Keep
    worldmap:AddGroupHeader(L["Siege On Dragonbane Keep"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Siege On Dragonbane Keep"], nil, {getterSetter = "WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Siege On Dragonbane Keep"], hidden = not GW.Retail})
    worldmap:AddOption(L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], {getterSetter = "WORLD_EVENTS_DRAGONBANE_KEEP_DESATURATE", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true}, groupHeaderName = L["Siege On Dragonbane Keep"], hidden = not GW.Retail})
    worldmap:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "WORLD_EVENTS_DRAGONBANE_KEEP_ALERT", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true}, groupHeaderName = L["Siege On Dragonbane Keep"], hidden = not GW.Retail})
    worldmap:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "WORLD_EVENTS_DRAGONBANE_KEEP_FLASH_TASKBAR", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true, ["WORLD_EVENTS_DRAGONBANE_KEEP_ALERT"] = true}, groupHeaderName = L["Siege On Dragonbane Keep"], hidden = not GW.Retail})
    worldmap:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "WORLD_EVENTS_DRAGONBANE_KEEP_STOP_ALERT_IF_COMPLETED", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true, ["WORLD_EVENTS_DRAGONBANE_KEEP_ALERT"] = true}, groupHeaderName = L["Siege On Dragonbane Keep"], hidden = not GW.Retail})
    worldmap:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], { getterSetter = "WORLD_EVENTS_DRAGONBANE_KEEP_ALERT_SECONDS", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Siege On Dragonbane Keep"], dependence = {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true, ["WORLD_EVENTS_DRAGONBANE_KEEP_ALERT"] = true}, hidden = not GW.Retail})

    -- Researchers Under Fire
    worldmap:AddGroupHeader(L["Researchers"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Researchers"], nil, {getterSetter = "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Researchers"], hidden = not GW.Retail})
    worldmap:AddOption(L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], {getterSetter = "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_DESATURATE", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED"] = true}, groupHeaderName = L["Researchers"], hidden = not GW.Retail})
    worldmap:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED"] = true}, groupHeaderName = L["Researchers"], hidden = not GW.Retail})
    worldmap:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_FLASH_TASKBAR", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED"] = true, ["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT"] = true}, groupHeaderName = L["Researchers"], hidden = not GW.Retail})
    worldmap:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_STOP_ALERT_IF_COMPLETED", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED"] = true, ["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT"] = true}, groupHeaderName = L["Researchers"], hidden = not GW.Retail})
    worldmap:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], { getterSetter = "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT_SECONDS", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Researchers"], dependence = {["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED"] = true, ["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT"] = true}, hidden = not GW.Retail})

    -- Time Rift Thaldraszus
    worldmap:AddGroupHeader(L["Time Rift"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Time Rift"], nil, {getterSetter = "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Time Rift"], hidden = not GW.Retail})
    worldmap:AddOption(L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], {getterSetter = "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_DESATURATE", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED"] = true}, groupHeaderName = L["Time Rift"], hidden = not GW.Retail})
    worldmap:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED"] = true}, groupHeaderName = L["Time Rift"], hidden = not GW.Retail})
    worldmap:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_FLASH_TASKBAR", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED"] = true, ["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT"] = true}, groupHeaderName = L["Time Rift"], hidden = not GW.Retail})
    worldmap:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_STOP_ALERT_IF_COMPLETED", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED"] = true, ["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT"] = true}, groupHeaderName = L["Time Rift"], hidden = not GW.Retail})
    worldmap:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], { getterSetter = "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT_SECONDS", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Time Rift"], dependence = {["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED"] = true, ["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT"] = true}, hidden = not GW.Retail})

    -- Superbloom
    worldmap:AddGroupHeader(L["Superbloom"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Superbloom"], nil, {getterSetter = "WORLD_EVENTS_SUPER_BLOOM_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Superbloom"], hidden = not GW.Retail})
    worldmap:AddOption(L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], {getterSetter = "WORLD_EVENTS_SUPER_BLOOM_DESATURATE", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_SUPER_BLOOM_ENABLED"] = true}, groupHeaderName = L["Superbloom"], hidden = not GW.Retail})
    worldmap:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "WORLD_EVENTS_SUPER_BLOOM_ALERT", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_SUPER_BLOOM_ENABLED"] = true}, groupHeaderName = L["Superbloom"], hidden = not GW.Retail})
    worldmap:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "WORLD_EVENTS_SUPER_BLOOM_FLASH_TASKBAR", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_SUPER_BLOOM_ENABLED"] = true, ["WORLD_EVENTS_SUPER_BLOOM_ALERT"] = true}, groupHeaderName = L["Superbloom"], hidden = not GW.Retail})
    worldmap:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "WORLD_EVENTS_SUPER_BLOOM_STOP_ALERT_IF_COMPLETED", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_SUPER_BLOOM_ENABLED"] = true, ["WORLD_EVENTS_SUPER_BLOOM_ALERT"] = true}, groupHeaderName = L["Superbloom"], hidden = not GW.Retail})
    worldmap:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], { getterSetter = "WORLD_EVENTS_SUPER_BLOOM_ALERT_SECONDS", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Superbloom"], dependence = {["WORLD_EVENTS_SUPER_BLOOM_ENABLED"] = true, ["WORLD_EVENTS_SUPER_BLOOM_ALERT"] = true}, hidden = not GW.Retail})

    -- Big Dig
    worldmap:AddGroupHeader(L["Big Dig"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Big Dig"], nil, {getterSetter = "WORLD_EVENTS_BIG_DIG_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Big Dig"], hidden = not GW.Retail})
    worldmap:AddOption(L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], {getterSetter = "WORLD_EVENTS_BIG_DIG_DESATURATE", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_BIG_DIG_ENABLED"] = true}, groupHeaderName = L["Big Dig"], hidden = not GW.Retail})
    worldmap:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "WORLD_EVENTS_BIG_DIG_ALERT", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_BIG_DIG_ENABLED"] = true}, groupHeaderName = L["Big Dig"], hidden = not GW.Retail})
    worldmap:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "WORLD_EVENTS_BIG_DIG_FLASH_TASKBAR", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_BIG_DIG_ENABLED"] = true, ["WORLD_EVENTS_BIG_DIG_ALERT"] = true}, groupHeaderName = L["Big Dig"], hidden = not GW.Retail})
    worldmap:AddOption(L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], {getterSetter = "WORLD_EVENTS_BIG_DIG_STOP_ALERT_IF_COMPLETED", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_BIG_DIG_ENABLED"] = true, ["WORLD_EVENTS_BIG_DIG_ALERT"] = true}, groupHeaderName = L["Big Dig"], hidden = not GW.Retail})
    worldmap:AddOptionSlider(L["Alert Second"], L["Alert will be triggered when the remaining time is less than the set value."], { getterSetter = "WORLD_EVENTS_BIG_DIG_ALERT_SECONDS", callback = GW.UpdateWorldEventTrackers, min = 0, max = 3600, decimalNumbers = 0, step = 1, groupHeaderName = L["Big Dig"], dependence = {["WORLD_EVENTS_BIG_DIG_ENABLED"] = true, ["WORLD_EVENTS_BIG_DIG_ALERT"] = true}, hidden = not GW.Retail})

    -- Fishing nets
    worldmap:AddGroupHeader(L["Iskaaran Fishing Net"], {hidden = not GW.Retail})
    worldmap:AddOption(L["Iskaaran Fishing Net"], nil, {getterSetter = "WORLD_EVENTS_ISKAARAN_FISHING_NET_ENABLED", callback = GW.UpdateWorldEventTrackers, groupHeaderName = L["Iskaaran Fishing Net"], hidden = not GW.Retail})
    worldmap:AddOption(COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, {getterSetter = "WORLD_EVENTS_ISKAARAN_FISHING_NET_ALERT", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_ISKAARAN_FISHING_NET_ENABLED"] = true}, groupHeaderName = L["Iskaaran Fishing Net"], hidden = not GW.Retail})
    worldmap:AddOption(L["Flash taskbar on reminder"], nil, {getterSetter = "WORLD_EVENTS_ISKAARAN_FISHING_NET_FLASH_TASKBAR", callback = GW.UpdateWorldEventTrackers, dependence = {["WORLD_EVENTS_ISKAARAN_FISHING_NET_ENABLED"] = true, ["WORLD_EVENTS_ISKAARAN_FISHING_NET_ALERT"] = true}, groupHeaderName = L["Iskaaran Fishing Net"], hidden = not GW.Retail})
    worldmap:AddOptionSlider(L["Alert Timeout"],  L["Alert will be disabled after the set value (hours)."], { getterSetter = "WORLD_EVENTS_ISKAARAN_FISHING_NET_DISABLE_ALERT_AFTER_HOURS", callback = GW.UpdateWorldEventTrackers, min = 0, max = 144, decimalNumbers = 0, step = 1, groupHeaderName = L["Iskaaran Fishing Net"], dependence = {["WORLD_EVENTS_ISKAARAN_FISHING_NET_ENABLED"] = true, ["WORLD_EVENTS_ISKAARAN_FISHING_NET_ALERT"] = true}, hidden = not GW.Retail})

    --FCT
    fct:AddOptionDropdown(COMBAT_TEXT_LABEL, COMBAT_SUBTEXT, { getterSetter = "GW_COMBAT_TEXT_MODE", callback = function(value)
            if value == "GW2" then
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
                if GW.settings.GW_COMBAT_TEXT_SHOW_HEALING_NUMBERS then
                    C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
                else
                    C_CVar.SetCVar("floatingCombatTextCombatHealing", "1")
                end
                GW.FloatingCombatTextToggleFormat(true)
            elseif value == "BLIZZARD" then
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "1")
                C_CVar.SetCVar("floatingCombatTextCombafloatingCombatTextCombatHealingtDamage", "1")
                GW.FloatingCombatTextToggleFormat(false)
            else
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
                C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
                GW.FloatingCombatTextToggleFormat(false)
            end
        end, optionsList = {"GW2", "BLIZZARD", "OFF"}, optionNames = {GW.addonName, "Blizzard", OFF .. " / " .. OTHER .. " " .. ADDONS}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})

    fct:AddOption(L["Use Blizzard colors"], nil, {getterSetter = "GW_COMBAT_TEXT_BLIZZARD_COLOR", callback = GW.UpdateDameTextSettings, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2"}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})
    fct:AddOption(L["Show numbers with commas"], nil, {getterSetter = "GW_COMBAT_TEXT_COMMA_FORMAT", callback = GW.UpdateDameTextSettings, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2"}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})
    fct:AddOption(L["Show healing numbers"], nil, {getterSetter = "GW_COMBAT_TEXT_SHOW_HEALING_NUMBERS", callback = function(value) if value then C_CVar.SetCVar("floatingCombatTextCombatHealing", "0") else C_CVar.SetCVar("floatingCombatTextCombatHealing", "1") end GW.UpdateDameTextSettings() end, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2", ["GW_COMBAT_TEXT_STYLE"] = {EXPANSION_NAME0, "Stacking"}}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})
    fct:AddOption(L["Shorten values"], nil, {getterSetter = "GW_COMBAT_TEXT_SHORT_VALUES", callback = GW.UpdateDameTextSettings, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2"}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})
    fct:AddOptionDropdown(L["GW2 floating combat text style"], nil, { getterSetter = "GW_COMBAT_TEXT_STYLE", callback = function()
            local enabled = GW.settings.GW_COMBAT_TEXT_MODE == "GW2" or GW.settings.GW_COMBAT_TEXT_MODE == "BLIZZARD" or false
            GW.UpdateDameTextSettings()
            GW.FloatingCombatTextToggleFormat(enabled)
        end, optionsList = {"Default", "Stacking", "Classic"}, optionNames = {DEFAULT, L["Stacking"], EXPANSION_NAME0}, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2"}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})
    fct:AddOptionDropdown(L["Classic combat text anchoring"], nil, { getterSetter = "GW_COMBAT_TEXT_STYLE_CLASSIC_ANCHOR", callback = function()
            local enabled = GW.settings.GW_COMBAT_TEXT_MODE == "GW2" or GW.settings.GW_COMBAT_TEXT_MODE == "BLIZZARD" or false
            GW.UpdateDameTextSettings()
            GW.FloatingCombatTextToggleFormat(enabled)
        end, optionsList = {"Nameplates", "Center"}, optionNames = {NAMEPLATES_LABEL, L["Center of screen"]}, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2", ["GW_COMBAT_TEXT_STYLE"] = EXPANSION_NAME0}, groupHeaderName = COMBAT_TEXT_LABEL, incompatibleAddons = "FloatingCombatText"})

    fct:AddGroupHeader(FONT_SIZE, {groupHeaderName = COMBAT_TEXT_LABEL, hidden = GW.Retail})
    fct:AddOptionSlider(FONT_SIZE, nil, { getterSetter = "GW_COMBAT_TEXT_FONT_SIZE", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2"}})
    fct:AddOptionSlider(MISS, nil, { getterSetter = "GW_COMBAT_TEXT_FONT_SIZE_MISS", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2"}})
    fct:AddOptionSlider(CRIT_ABBR, nil, { getterSetter = "GW_COMBAT_TEXT_FONT_SIZE_CRIT", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2"}})
    fct:AddOptionSlider(BLOCK .. "/" .. ABSORB, nil, { getterSetter = "GW_COMBAT_TEXT_FONT_SIZE_BLOCKED_ABSORBE", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2"}})
    fct:AddOptionSlider(L["Crit modifier"], nil, { getterSetter = "GW_COMBAT_TEXT_FONT_SIZE_CRIT_MODIFIER", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2"}})
    fct:AddOptionSlider(L["Pet number modifier"], nil, { getterSetter = "GW_COMBAT_TEXT_FONT_SIZE_PET_MODIFIER", callback = GW.UpdateDameTextSettings, min = 2, max = 50, decimalNumbers = 0, step = 1, incompatibleAddons = "FloatingCombatText", groupHeaderName = COMBAT_TEXT_LABEL, dependence = {["GW_COMBAT_TEXT_MODE"] = "GW2"}})

    sWindow:AddSettingsPanel(p, UIOPTIONS_MENU, L["Edit the modules in the Heads-Up Display for more customization."], {{name = GENERAL, frame = general}, {name = MINIMAP_LABEL, frame = minimap}, {name = WORLDMAP_BUTTON, frame = worldmap}, not GW.Retail and {name = COMBAT_TEXT_LABEL, frame = fct} or nil})
end
GW.LoadHudPanel = LoadHudPanel
