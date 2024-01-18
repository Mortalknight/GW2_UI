local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionButton = GW.AddOptionButton
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local addGroupHeader = GW.AddGroupHeader
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton;

local function LoadHudPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local general = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    general.header:SetFont(DAMAGE_TEXT_FONT, 20)
    general.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    general.header:SetText(UIOPTIONS_MENU)
    general.sub:SetFont(UNIT_NAME_FONT, 12)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    general.breadcrumb:SetText(GENERAL)

    local minimap = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    minimap.header:SetFont(DAMAGE_TEXT_FONT, 20)
    minimap.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    minimap.header:SetText(UIOPTIONS_MENU)
    minimap.sub:SetFont(UNIT_NAME_FONT, 12)
    minimap.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    minimap.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    minimap.header:SetWidth(minimap.header:GetStringWidth())
    minimap.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    minimap.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    minimap.breadcrumb:SetText(MINIMAP_LABEL)

    local worldmap = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    worldmap.header:SetFont(DAMAGE_TEXT_FONT, 20)
    worldmap.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    worldmap.header:SetText(UIOPTIONS_MENU)
    worldmap.sub:SetFont(UNIT_NAME_FONT, 12)
    worldmap.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    worldmap.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    worldmap.header:SetWidth(worldmap.header:GetStringWidth())
    worldmap.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    worldmap.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    worldmap.breadcrumb:SetText(WORLDMAP_BUTTON)

    local fct = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    fct.header:SetFont(DAMAGE_TEXT_FONT, 20)
    fct.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    fct.header:SetText(UIOPTIONS_MENU)
    fct.sub:SetFont(UNIT_NAME_FONT, 12)
    fct.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    fct.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    fct.header:SetWidth(fct.header:GetStringWidth())
    fct.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    fct.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    fct.breadcrumb:SetText(COMBAT_TEXT_LABEL)

    createCat(UIOPTIONS_MENU, L["Edit the HUD modules."], p, {general, minimap, worldmap, fct})
    settingsMenuAddButton(UIOPTIONS_MENU, p, {general, minimap, worldmap, fct})

    --GENERAL
    addOption(general.scroll.scrollchild, L["Show HUD background"], L["The HUD background changes color in the following situations: In Combat, Not In Combat, In Water, Low HP, Ghost"], "HUD_BACKGROUND", function() GW.ToggleHudBackground() end)
    addOption(general.scroll.scrollchild, L["Dynamic HUD"], L["Enable or disable the dynamically changing HUD background."], "HUD_SPELL_SWAP", nil, nil, {["HUD_BACKGROUND"] = true})
    addOption(general.scroll.scrollchild, L["AFK Mode"], L["When you go AFK, display the AFK screen."], "AFK_MODE", GW.ToggelAfkMode)
    addOption(general.scroll.scrollchild, L["Mark Quest Reward"], L["Marks the most valuable quest reward with a gold coin."], "QUEST_REWARDS_MOST_VALUE_ICON", function() GW.ResetQuestRewardMostValueIcon() end)
    addOption(general.scroll.scrollchild, L["XP Quest Percent"], L["Shows the xp you got from that quest in % based on your current needed xp for next level."], "QUEST_XP_PERCENT")
    addOption(general.scroll.scrollchild, L["Fade Menu Bar"], L["The main menu icons will fade when you move your cursor away."], "FADE_MICROMENU", function(value) Gw2MicroBarFrame.cf:SetAttribute("shouldFade", value) Gw2MicroBarFrame.cf:SetShown(not value) if value then Gw2MicroBarFrame.cf.fadeOut(Gw2MicroBarFrame.cf) else Gw2MicroBarFrame.cf.fadeIn(Gw2MicroBarFrame.cf) end end)
    addOption(general.scroll.scrollchild, L["Show event timer micro menu icon"], L["Displays an micro menu icon for the world map event timers"], "MICROMENU_EVENT_TIMER_ICON", function() GW.ToggleEventTimerMicroMenuIcon(Gw2MicroBarFrame.cf) end)    

    addOption(general.scroll.scrollchild, DISPLAY_BORDERS, L["Toggle the borders around the screen"], "BORDER_ENABLED", GW.ToggleHudBackground)
    addOption(general.scroll.scrollchild, L["Fade Group Manage Button"], L["The Group Manage Button will fade when you move the cursor away."], "FADE_GROUP_MANAGE_FRAME", function() GW.ShowRlPopup = true end, nil, {["PARTY_FRAMES"] = true})
    addOption(
        general.scroll.scrollchild,
        L["Pixel Perfect Mode"],
        L["Scales the UI into a Pixel Perfect Mode. This is dependent on screen resolution."],
        "PIXEL_PERFECTION",
        function()
            C_CVar.SetCVar("useUiScale", "0")
            GW.PixelPerfection()
        end
    )
    addOptionSlider(
        general.scroll.scrollchild,
        L["HUD Scale"],
        L["Change the HUD size."],
        "HUD_SCALE",
        function() GW.UpdateHudScale(); GW.ShowRlPopup = true end,
        0.5,
        1.5,
        nil,
        2
    )
    addOptionButton(general.scroll.scrollchild, L["Apply to all"], L["Applies the UI scale to all frames which can be scaled in 'Move HUD' mode."], "GW2_Apply_all_Button",
        function()
            local scale = GW.settings.HUD_SCALE
            for _, mf in pairs(GW.scaleableFrames) do
                mf.parent:SetScale(scale)
                mf:SetScale(scale)
                GW.settings[mf.setting .."_scale"] = scale
            end
        end)
    addOptionDropdown(
        general.scroll.scrollchild,
        L["Show Role Bar"],
        L["Whether to display a floating bar showing your group or raid's role composition. This can be moved via the 'Move HUD' interface."],
        "ROLE_BAR",
        GW.UpdateRaidCounterVisibility,
        {"ALWAYS", "NEVER", "IN_GROUP", "IN_RAID", "IN_RAID_IN_PARTY"},
        {
            ALWAYS,
            NEVER,
            AGGRO_WARNING_IN_PARTY,
            L["In raid"],
            L["In group or in raid"],
        }
    )
    addOptionDropdown(
        general.scroll.scrollchild,
        L["Auto Repair"],
        L["Automatically repair using the following method when visiting a merchant."],
        "AUTO_REPAIR",
        nil,
        {"NONE", "PLAYER", "GUILD"},
        {
            NONE_KEY,
            PLAYER,
            GUILD,
        }
    )
    addOptionSlider(
        general.scroll.scrollchild,
        L["Extended Vendor"],
        L["The number of pages shown in the merchant frame. Set 1 to disable."],
        "EXTENDED_VENDOR_NUM_PAGES",
        function() GW.ShowRlPopup = true end,
        1,
        6,
        nil,
        0,
        nil,
        1
    )

    --MINIMAP
    addOption(minimap.scroll.scrollchild, L["Addon Compartment"], nil, "MINIMAP_ADDON_COMPARTMENT_TOGGLE", function() GW.HandleAddonCompartmentButton() end, nil, {["MINIMAP_ENABLED"] = true}, "Minimap")
    addOption(minimap.scroll.scrollchild, L["Show FPS on minimap"], L["Show FPS on minimap"], "MINIMAP_FPS", GW.ToogleMinimapFpsLable, nil, {["MINIMAP_ENABLED"] = true}, "Minimap")
    addOption(minimap.scroll.scrollchild, L["Disable FPS tooltip"], nil, "MINIMAP_FPS_TOOLTIP_DISABLED", nil, nil, {["MINIMAP_ENABLED"] = true, ["MINIMAP_FPS"] = true}, "Minimap")
    addOption(minimap.scroll.scrollchild, L["Show Coordinates on Minimap"], L["Show Coordinates on Minimap"], "MINIMAP_COORDS_TOGGLE", GW.ToogleMinimapCoorsLable, nil, {["MINIMAP_ENABLED"] = true}, "Minimap")
    addOptionDropdown(
        minimap.scroll.scrollchild,
        L["Minimap details"],
        L["Always show Minimap details."],
        "MINIMAP_ALWAYS_SHOW_HOVER_DETAILS",
        GW.SetMinimapHover,
        {"CLOCK", "ZONE", "COORDS"},
        {TIMEMANAGER_TITLE, ZONE, L["Coordinates"]},
        nil,
        {["MINIMAP_ENABLED"] = true},
        true,
        "Minimap"
    )
    addOptionSlider(
        minimap.scroll.scrollchild,
        L["Minimap Scale"],
        L["Change the Minimap size."],
        "MINIMAP_SCALE",
        function()
            local size = GW.settings.MINIMAP_SCALE
            Minimap:SetSize(size, size)
            Minimap.gwMover:SetSize(size, size)
        end,
        160,
        420,
        nil,
        0,
        {["MINIMAP_ENABLED"] = true},
        1
    )
    --WORLDMAP
    -- world map coordinates
    addGroupHeader(worldmap.scroll.scrollchild, L["World Map Coordinates"])
    addOption(worldmap.scroll.scrollchild, L["Enable"], nil, "WORLDMAP_COORDS_TOGGLE", GW.UpdateWorldMapCoordinateSettings, nil, nil, nil, nil, L["World Map Coordinates"])
    addOptionDropdown(
        worldmap.scroll.scrollchild,
        GW.NewSign .. L["Position"],
        nil,
        "WORLDMAP_COORDS_POSITION",
        GW.UpdateWorldMapCoordinateSettings,
        {"BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT"},
        {L["Bottom"],L["Bottom left"], L["Bottom right"], L["Left"], L["Right"], L["Top"], L["Top Left"], L["Top Right"]},
        nil,
        {["WORLDMAP_COORDS_TOGGLE"] = true},
        nil, nil, nil, nil, nil, nil, nil, nil, nil,
        L["World Map Coordinates"]
    )
    addOptionSlider(
        worldmap.scroll.scrollchild,
        GW.NewSign .. L["X-Offset"],
        nil,
        "WORLDMAP_COORDS_X_OFFSET",
        GW.UpdateWorldMapCoordinateSettings,
        -200,
        200,
        nil,
        0,
        {["WORLDMAP_COORDS_TOGGLE"] = true},
        1,
        nil,
        nil,
        L["World Map Coordinates"]
    )
    addOptionSlider(
        worldmap.scroll.scrollchild,
        GW.NewSign .. L["Y-Offset"],
        nil,
        "WORLDMAP_COORDS_Y_OFFSET",
        GW.UpdateWorldMapCoordinateSettings,
        -200,
        200,
        nil,
        0,
        {["WORLDMAP_COORDS_TOGGLE"] = true},
        1,
        nil,
        nil,
        L["World Map Coordinates"]
    )

    -- Community Feast
    addGroupHeader(worldmap.scroll.scrollchild, L["Community Feast"])
    addOption(worldmap.scroll.scrollchild, L["Community Feast"], nil, "WORLD_EVENTS_COMMUNITY_FEAST_ENABLED", GW.UpdateWorldEventTrackers, nil, nil, nil, nil, L["Community Feast"])
    addOption(worldmap.scroll.scrollchild, L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], "WORLD_EVENTS_COMMUNITY_FEAST_DESATURATE", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true}, nil, nil, L["Community Feast"])
    addOption(worldmap.scroll.scrollchild, COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, "WORLD_EVENTS_COMMUNITY_FEAST_ALERT", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true}, nil, nil, L["Community Feast"])
    addOption(worldmap.scroll.scrollchild, L["Flash taskbar on reminder"], nil, "WORLD_EVENTS_COMMUNITY_FEAST_FLASH_TASKBAR", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true, ["WORLD_EVENTS_COMMUNITY_FEAST_ALERT"] = true}, nil, nil, L["Community Feast"])
    addOption(worldmap.scroll.scrollchild, L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], "WORLD_EVENTS_COMMUNITY_FEAST_STOP_ALERT_IF_COMPLETED", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true, ["WORLD_EVENTS_COMMUNITY_FEAST_ALERT"] = true}, nil, nil, L["Community Feast"])
    addOptionSlider(
        worldmap.scroll.scrollchild,
        L["Alert Second"],
        L["Alert will be triggered when the remaining time is less than the set value."],
        "WORLD_EVENTS_COMMUNITY_FEAST_ALERT_SECONDS",
        GW.UpdateWorldEventTrackers,
        0,
        3600,
        nil,
        0,
        {["WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"] = true, ["WORLD_EVENTS_COMMUNITY_FEAST_ALERT"] = true},
        1,
        nil,
        nil,
        L["Community Feast"]
    )

    -- Dragonbane Keep
    addGroupHeader(worldmap.scroll.scrollchild, L["Siege On Dragonbane Keep"])
    addOption(worldmap.scroll.scrollchild, L["Siege On Dragonbane Keep"], nil, "WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED", GW.UpdateWorldEventTrackers, nil, nil, nil, nil, L["Siege On Dragonbane Keep"])
    addOption(worldmap.scroll.scrollchild, L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], "WORLD_EVENTS_DRAGONBANE_KEEP_DESATURATE", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true}, nil, nil, L["Siege On Dragonbane Keep"])
    addOption(worldmap.scroll.scrollchild, COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, "WORLD_EVENTS_DRAGONBANE_KEEP_ALERT", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true}, nil, nil, L["Siege On Dragonbane Keep"])
    addOption(worldmap.scroll.scrollchild, L["Flash taskbar on reminder"], nil, "WORLD_EVENTS_DRAGONBANE_KEEP_FLASH_TASKBAR", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true, ["WORLD_EVENTS_DRAGONBANE_KEEP_ALERT"] = true}, nil, nil, L["Siege On Dragonbane Keep"])
    addOption(worldmap.scroll.scrollchild, L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], "WORLD_EVENTS_DRAGONBANE_KEEP_STOP_ALERT_IF_COMPLETED", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true, ["WORLD_EVENTS_DRAGONBANE_KEEP_ALERT"] = true}, nil, nil, L["Siege On Dragonbane Keep"])
    addOptionSlider(
        worldmap.scroll.scrollchild,
        L["Alert Second"],
        L["Alert will be triggered when the remaining time is less than the set value."],
        "WORLD_EVENTS_DRAGONBANE_KEEP_ALERT_SECONDS",
        GW.UpdateWorldEventTrackers,
        0,
        3600,
        nil,
        0,
        {["WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"] = true, ["WORLD_EVENTS_DRAGONBANE_KEEP_ALERT"] = true},
        1,
        nil,
        nil,
        L["Siege On Dragonbane Keep"]
    )

    -- Researchers Under Fire
    addGroupHeader(worldmap.scroll.scrollchild, L["Researchers"])
    addOption(worldmap.scroll.scrollchild, L["Researchers"], nil, "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED", GW.UpdateWorldEventTrackers, nil, nil, nil, nil, L["Researchers"])
    addOption(worldmap.scroll.scrollchild, L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_DESATURATE", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED"] = true}, nil, nil, L["Researchers"])
    addOption(worldmap.scroll.scrollchild, COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED"] = true}, nil, nil, L["Researchers"])
    addOption(worldmap.scroll.scrollchild, L["Flash taskbar on reminder"], nil, "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_FLASH_TASKBAR", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED"] = true, ["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT"] = true}, nil, nil, L["Researchers"])
    addOption(worldmap.scroll.scrollchild, L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_STOP_ALERT_IF_COMPLETED", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED"] = true, ["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT"] = true}, nil, nil, L["Researchers"])
    addOptionSlider(
        worldmap.scroll.scrollchild,
        L["Alert Second"],
        L["Alert will be triggered when the remaining time is less than the set value."],
        "WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT_SECONDS",
        GW.UpdateWorldEventTrackers,
        0,
        3600,
        nil,
        0,
        {["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED"] = true, ["WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT"] = true},
        1,
        nil,
        nil,
        L["Researchers"]
    )

    -- Time Rift Thaldraszus
    addGroupHeader(worldmap.scroll.scrollchild, L["Time Rift"])
    addOption(worldmap.scroll.scrollchild, L["Time Rift"], nil, "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED", GW.UpdateWorldEventTrackers, nil, nil, nil, nil, L["Time Rift"])
    addOption(worldmap.scroll.scrollchild, L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_DESATURATE", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED"] = true}, nil, nil, L["Time Rift"])
    addOption(worldmap.scroll.scrollchild, COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED"] = true}, nil, nil, L["Time Rift"])
    addOption(worldmap.scroll.scrollchild, L["Flash taskbar on reminder"], nil, "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_FLASH_TASKBAR", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED"] = true, ["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT"] = true}, nil, nil, L["Time Rift"])
    addOption(worldmap.scroll.scrollchild, L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_STOP_ALERT_IF_COMPLETED", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED"] = true, ["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT"] = true}, nil, nil, L["Time Rift"])
    addOptionSlider(
        worldmap.scroll.scrollchild,
        L["Alert Second"],
        L["Alert will be triggered when the remaining time is less than the set value."],
        "WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT_SECONDS",
        GW.UpdateWorldEventTrackers,
        0,
        3600,
        nil,
        0,
        {["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED"] = true, ["WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT"] = true},
        1,
        nil,
        nil,
        L["Time Rift"]
    )

    -- Superbloom
    addGroupHeader(worldmap.scroll.scrollchild, L["Superbloom"])
    addOption(worldmap.scroll.scrollchild, L["Superbloom"], nil, "WORLD_EVENTS_SUPER_BLOOM_ENABLED", GW.UpdateWorldEventTrackers, nil, nil, nil, nil, L["Superbloom"])
    addOption(worldmap.scroll.scrollchild, L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], "WORLD_EVENTS_SUPER_BLOOM_DESATURATE", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_SUPER_BLOOM_ENABLED"] = true}, nil, nil, L["Superbloom"])
    addOption(worldmap.scroll.scrollchild, COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, "WORLD_EVENTS_SUPER_BLOOM_ALERT", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_SUPER_BLOOM_ENABLED"] = true}, nil, nil, L["Superbloom"])
    addOption(worldmap.scroll.scrollchild, L["Flash taskbar on reminder"], nil, "WORLD_EVENTS_SUPER_BLOOM_FLASH_TASKBAR", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_SUPER_BLOOM_ENABLED"] = true, ["WORLD_EVENTS_SUPER_BLOOM_ALERT"] = true}, nil, nil, L["Superbloom"])
    addOption(worldmap.scroll.scrollchild, L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], "WORLD_EVENTS_SUPER_BLOOM_STOP_ALERT_IF_COMPLETED", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_SUPER_BLOOM_ENABLED"] = true, ["WORLD_EVENTS_SUPER_BLOOM_ALERT"] = true}, nil, nil, L["Superbloom"])
    addOptionSlider(
        worldmap.scroll.scrollchild,
        L["Alert Second"],
        L["Alert will be triggered when the remaining time is less than the set value."],
        "WORLD_EVENTS_SUPER_BLOOM_ALERT_SECONDS",
        GW.UpdateWorldEventTrackers,
        0,
        3600,
        nil,
        0,
        {["WORLD_EVENTS_SUPER_BLOOM_ENABLED"] = true, ["WORLD_EVENTS_SUPER_BLOOM_ALERT"] = true},
        1,
        nil,
        nil,
        L["Superbloom"]
    )

     -- Big Dig
     addGroupHeader(worldmap.scroll.scrollchild, GW.NewSign .. L["Big Dig"])
     addOption(worldmap.scroll.scrollchild, L["Big Dig"], nil, "WORLD_EVENTS_BIG_DIG_ENABLED", GW.UpdateWorldEventTrackers, nil, nil, nil, nil, L["Big Dig"])
     addOption(worldmap.scroll.scrollchild, L["Desaturate icon"], L["Desaturate icon if the event is completed in this week."], "WORLD_EVENTS_BIG_DIG_DESATURATE", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_BIG_DIG_ENABLED"] = true}, nil, nil, L["Big Dig"])
     addOption(worldmap.scroll.scrollchild, COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, "WORLD_EVENTS_BIG_DIG_ALERT", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_BIG_DIG_ENABLED"] = true}, nil, nil, L["Big Dig"])
     addOption(worldmap.scroll.scrollchild, L["Flash taskbar on reminder"], nil, "WORLD_EVENTS_BIG_DIG_FLASH_TASKBAR", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_BIG_DIG_ENABLED"] = true, ["WORLD_EVENTS_BIG_DIG_ALERT"] = true}, nil, nil, L["Big Dig"])
     addOption(worldmap.scroll.scrollchild, L["Stop alert if completed"], L["Stop alert when the event is completed in this week."], "WORLD_EVENTS_BIG_DIG_STOP_ALERT_IF_COMPLETED", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_BIG_DIG_ENABLED"] = true, ["WORLD_EVENTS_BIG_DIG_ALERT"] = true}, nil, nil, L["Big Dig"])
     addOptionSlider(
         worldmap.scroll.scrollchild,
         L["Alert Second"],
         L["Alert will be triggered when the remaining time is less than the set value."],
         "WORLD_EVENTS_BIG_DIG_ALERT_SECONDS",
         GW.UpdateWorldEventTrackers,
         0,
         3600,
         nil,
         0,
         {["WORLD_EVENTS_BIG_DIG_ENABLED"] = true, ["WORLD_EVENTS_BIG_DIG_ALERT"] = true},
         1,
         nil,
         nil,
         L["Big Dig"]
     )

    -- Fishing nets
    addGroupHeader(worldmap.scroll.scrollchild, L["Iskaaran Fishing Net"])
    addOption(worldmap.scroll.scrollchild, L["Iskaaran Fishing Net"], nil, "WORLD_EVENTS_ISKAARAN_FISHING_NET_ENABLED", GW.UpdateWorldEventTrackers, nil, nil, nil, nil, L["Iskaaran Fishing Net"])
    addOption(worldmap.scroll.scrollchild, COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, nil, "WORLD_EVENTS_ISKAARAN_FISHING_NET_ALERT", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_ISKAARAN_FISHING_NET_ENABLED"] = true}, nil, nil, L["Iskaaran Fishing Net"])
    addOption(worldmap.scroll.scrollchild, L["Flash taskbar on reminder"], nil, "WORLD_EVENTS_ISKAARAN_FISHING_NET_FLASH_TASKBAR", GW.UpdateWorldEventTrackers, nil, {["WORLD_EVENTS_ISKAARAN_FISHING_NET_ENABLED"] = true, ["WORLD_EVENTS_ISKAARAN_FISHING_NET_ALERT"] = true}, nil, nil, L["Iskaaran Fishing Net"])
    addOptionSlider(
        worldmap.scroll.scrollchild,
        L["Alert Timeout"],
        L["Alert will be disabled after the set value (hours)."],
        "WORLD_EVENTS_ISKAARAN_FISHING_NET_DISABLE_ALERT_AFTER_HOURS",
        GW.UpdateWorldEventTrackers,
        0,
        144,
        nil,
        0,
        {["WORLD_EVENTS_ISKAARAN_FISHING_NET_ENABLED"] = true, ["WORLD_EVENTS_ISKAARAN_FISHING_NET_ALERT"] = true},
        1,
        nil,
        nil,
        L["Iskaaran Fishing Net"]
    )

    --FCT
    addOptionDropdown(
        fct.scroll.scrollchild,
        COMBAT_TEXT_LABEL,
        COMBAT_SUBTEXT,
        "GW_COMBAT_TEXT_MODE",
        function(value)
            if value == "GW2" then
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
                if GW.settings.GW_COMBAT_TEXT_SHOW_HEALING_NUMBERS then
                    C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
                else
                    C_CVar.SetCVar("floatingCombatTextCombatHealing", "1")
                end
                GW.LoadDamageText(true)
            elseif value == "BLIZZARD" then
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "1")
                C_CVar.SetCVar("floatingCombatTextCombafloatingCombatTextCombatHealingtDamage", "1")
                GW.FloatingCombatTextToggleFormat(false)
            else
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
                C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
                GW.FloatingCombatTextToggleFormat(false)
            end

        end,
        {"GW2", "BLIZZARD", "OFF"},
        {GW.addonName, "Blizzard", OFF .. " / " .. OTHER .. " " .. ADDONS},
        nil,
        nil,
        nil,
        "FloatingCombatText"
    )
    addOption(fct.scroll.scrollchild, COMBAT_TEXT_LABEL .. L[": Use Blizzard colors"], nil, "GW_COMBAT_TEXT_BLIZZARD_COLOR", GW.UpdateDameTextSettings, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"}, "FloatingCombatText")
    addOption(fct.scroll.scrollchild, COMBAT_TEXT_LABEL .. L[": Show numbers with commas"], nil, "GW_COMBAT_TEXT_COMMA_FORMAT", GW.UpdateDameTextSettings, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"}, "FloatingCombatText")
    addOption(fct.scroll.scrollchild, COMBAT_TEXT_LABEL .. ": " .. L["Show healing numbers"], nil, "GW_COMBAT_TEXT_SHOW_HEALING_NUMBERS", function(value) if value then C_CVar.SetCVar("floatingCombatTextCombatHealing", "0") else C_CVar.SetCVar("floatingCombatTextCombatHealing", "1") end GW.UpdateDameTextSettings() end, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2", ["GW_COMBAT_TEXT_STYLE"] = {EXPANSION_NAME0, "Stacking"}}, "FloatingCombatText")

    addOptionDropdown(
        fct.scroll.scrollchild,
        L["GW2 floating combat text style"],
        nil,
        "GW_COMBAT_TEXT_STYLE",
        function() GW.UpdateDameTextSettings(); GW.FloatingCombatTextToggleFormat(true) end,
        {"Default", "Stacking", "Classic"},
        {DEFAULT, L["Stacking"], EXPANSION_NAME0},
        nil,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        nil,
        "FloatingCombatText"
    )

    addOptionDropdown(
        fct.scroll.scrollchild,
        L["Classic combat text anchoring"],
        nil,
        "GW_COMBAT_TEXT_STYLE_CLASSIC_ANCHOR",
        function() GW.UpdateDameTextSettings(); GW.FloatingCombatTextToggleFormat(true) end,
        {"Nameplates", "Center"},
        {NAMEPLATES_LABEL, L["Center of screen"]},
        nil,
        {["GW_COMBAT_TEXT_MODE"] = "GW2", ["GW_COMBAT_TEXT_STYLE"] = EXPANSION_NAME0},
        nil,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        GW.NewSign .. FONT_SIZE,
        nil,
        "GW_COMBAT_TEXT_FONT_SIZE",
        GW.UpdateDameTextSettings,
        2,
        50,
        nil,
        0,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        2,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        GW.NewSign .. FONT_SIZE .. ": " .. MISS,
        nil,
        "GW_COMBAT_TEXT_FONT_SIZE_MISS",
        GW.UpdateDameTextSettings,
        2,
        50,
        nil,
        0,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        2,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        GW.NewSign .. FONT_SIZE .. ": " .. CRIT_ABBR,
        nil,
        "GW_COMBAT_TEXT_FONT_SIZE_CRIT",
        GW.UpdateDameTextSettings,
        2,
        50,
        nil,
        0,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        2,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        GW.NewSign .. FONT_SIZE .. ": " .. BLOCK .. "/" .. ABSORB,
        nil,
        "GW_COMBAT_TEXT_FONT_SIZE_BLOCKED_ABSORBE",
        GW.UpdateDameTextSettings,
        2,
        50,
        nil,
        0,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        2,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        GW.NewSign .. FONT_SIZE .. ": " .. L["Crit modifier"],
        L["Used for animations"],
        "GW_COMBAT_TEXT_FONT_SIZE_CRIT_MODIFIER",
        GW.UpdateDameTextSettings,
        0.1,
        50,
        nil,
        2,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        nil,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        GW.NewSign .. FONT_SIZE .. ": " .. L["Pet number modifier"],
        nil,
        "GW_COMBAT_TEXT_FONT_SIZE_PET_MODIFIER",
        GW.UpdateDameTextSettings,
        0.1,
        50,
        nil,
        2,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        nil,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )

    InitPanel(general, true)
    InitPanel(minimap, true)
    InitPanel(worldmap, true)
    InitPanel(fct, true)
end
GW.LoadHudPanel = LoadHudPanel
