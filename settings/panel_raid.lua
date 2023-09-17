local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local MapTable = GW.MapTable
local StrUpper = GW.StrUpper
local StrLower = GW.StrLower
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton
local addGroupHeader = GW.AddGroupHeader

-- Profiles
local function LoadRaid10Profile(panel)
    local raid10 = CreateFrame("Frame", "GwSettingsRaidPanel", panel, "GwSettingsPanelScrollTmpl")
    raid10.header:SetFont(DAMAGE_TEXT_FONT, 20)
    raid10.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    raid10.header:SetText(L["Group Frames"] )
    raid10.sub:SetFont(UNIT_NAME_FONT, 12)
    raid10.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    raid10.sub:SetText(L["Edit the party and raid options to suit your needs."])

    raid10.header:SetWidth(raid10.header:GetStringWidth())
    raid10.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    raid10.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    raid10.breadcrumb:SetText(RAID..": 10")

    --[[
    p.buttonRaidPreview:SetScript("OnClick", function()
        --GW.GridToggleFramesPreviewRaid(false, false) -- disabled for now
    end)
    p.buttonRaidPreview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to toggle raid frame preview and cycle through different group sizes."], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.buttonRaidPreview:SetScript("OnLeave", GameTooltip_Hide)
    p.buttonRaidPreview:SetEnabled(GetSetting("RAID_FRAMES"))
    ]]

    addOption(raid10.scroll.scrollchild, L["Enable Raid 10 grid"], L["Display a separate raid grid for groups from 11 to 25 players"], "RAID10_ENABLED", function() GW.UpdateGridSettings("RAID10", nil, true); GW.UpdateGridSettings("RAID25", nil, true); GW.UpdateGridSettings("RAID40", nil, true) end, nil, {["RAID_FRAMES"] = true})
    addOption(raid10.scroll.scrollchild, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], "RAID_CLASS_COLOR_RAID10", function() GW.UpdateGridSettings("RAID10") end, nil, {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true})
    addOption(raid10.scroll.scrollchild, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], "RAID_POWER_BARS_RAID10", function() GW.UpdateGridSettings("RAID10") end, nil, {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true})
    addOption(raid10.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "RAID_SHOW_DEBUFFS_RAID10", function() GW.UpdateGridSettings("RAID10") end, nil, {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true})
    addOption(raid10.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "RAID_ONLY_DISPELL_DEBUFFS_RAID10", function() GW.UpdateGridSettings("RAID10") end, nil, {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true, ["RAID_SHOW_DEBUFFS"] = true})
    addOption(raid10.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_RAID10", function() GW.UpdateGridSettings("RAID10") end, nil, {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true})
    addOption(raid10.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], "RAID_UNIT_MARKERS_RAID10", function() GW.UpdateGridSettings("RAID10") end, nil, {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true})
    addOption(raid10.scroll.scrollchild, L["Start Near Center"], L["The initial group will start near the center and grow out."], "UNITFRAME_ANCHOR_FROM_CENTER_RAID10", function() GW.UpdateGridSettings("RAID10", true) end, nil, {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true})
    addOptionDropdown(
        raid10.scroll.scrollchild,
        L["Show Aura Tooltips"],
        L["Show tooltips of buffs and debuffs."],
        "RAID_AURA_TOOLTIP_INCOMBAT_RAID10",
        function()
            GW.UpdateGridSettings("RAID10")
        end,
        {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"},
        {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]},
        nil,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )

    addOptionDropdown(
        raid10.scroll.scrollchild,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH_RAID10",
        function()
            GW.UpdateGridSettings("RAID10")
        end,
        {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        {
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH
        },
        nil,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )

    addOptionDropdown(
        raid10.scroll.scrollchild,
        L["Show Country Flag"],
        L["Display a country flag based on the unit's language"],
        "RAID_UNIT_FLAGS_RAID10",
        function()
            GW.UpdateGridSettings("RAID10")
        end,
        {"NONE", "DIFFERENT", "ALL"},
        {NONE_KEY, L["Different Than Own"], ALL},
        nil,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- Size and Positions
    addGroupHeader(raid10.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(
        raid10.scroll.scrollchild,
        L["Set Raid Growth Direction"],
        L["Set the grow direction for raid frames."],
        "RAID_GROW_RAID10",
        function()
            GW.UpdateGridSettings("RAID10", true)
        end,
        grow,
        MapTable(
            grow,
            function(dir)
                local g1, g2 = strsplit("+", dir)
                return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
            end
        ),
        nil,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )

    addOptionSlider(
        raid10.scroll.scrollchild,
        L["Set Raid Units per Column"],
        L["Set the number of raid unit frames per column or row, depending on grow directions."],
        "RAID_UNITS_PER_COLUMN_RAID10",
        function()
            GW.UpdateGridSettings("RAID10", true)
        end,
        1,
        40,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )

    addOptionSlider(
        raid10.scroll.scrollchild,
        L["Set Raid Unit Width"],
        L["Set the width of the raid units."],
        "RAID_WIDTH_RAID10",
        function()
            GW.UpdateGridSettings("RAID10", false, true)
        end,
        45,
        300,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )

    addOptionSlider(
        raid10.scroll.scrollchild,
        L["Set Raid Unit Height"],
        L["Set the height of the raid units."],
        "RAID_HEIGHT_RAID10",
        function()
            GW.UpdateGridSettings("RAID10", false, true)
        end,
        15,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )

    addOptionSlider(
        raid10.scroll.scrollchild,
        L["Horizontal Spacing"],
        nil,
        "RAID_UNITS_HORIZONTAL_SPACING_RAID10",
        function()
            GW.UpdateGridSettings("RAID10", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )

    addOptionSlider(
        raid10.scroll.scrollchild,
        L["Vertical Spacing"],
        nil,
        "RAID_UNITS_VERTICAL_SPACING_RAID10",
        function()
            GW.UpdateGridSettings("RAID10", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )

    addOptionSlider(
        raid10.scroll.scrollchild,
        L["Group Spacing"],
        L["Additional spacing between each individual group."],
        "RAID_UNITS_GROUP_SPACING_RAID10",
        function()
            GW.UpdateGridSettings("RAID10", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )

    -- Sorting
    addGroupHeader(raid10.scroll.scrollchild, L["Grouping & Sorting"])
    addOption(
        raid10.scroll.scrollchild,
        L["Raid-Wide Sorting"],
        L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."],
        "RAID_WIDE_SORTING_RAID10",
        function()
            GW.UpdateGridSettings("RAID10", true)
        end,
        nil,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )
    addOptionDropdown(
        raid10.scroll.scrollchild,
        L["Group By"],
        L["Set the order that the group will sort."],
        "RAID_GROUP_BY_RAID10",
        function()
            GW.UpdateGridSettings("RAID10", true)
        end,
        {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"},
        {CLASS, GROUP, "Index", NAME, ROLE},
        nil,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )
    addOptionDropdown(
        raid10.scroll.scrollchild,
        L["Sort Direction"],
        nil,
        "RAID_SORT_DIRECTION_RAID10",
        function()
            GW.UpdateGridSettings("RAID10", true)
        end,
        {"ASC", "DESC"},
        {L["Ascending"], L["Descending"]},
        nil,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}
    )
    addOptionDropdown(
        raid10.scroll.scrollchild,
        L["Sort Method"],
        nil,
        "RAID_RAID_SORT_METHOD_RAID10",
        function()
            GW.UpdateGridSettings("RAID10", true)
        end,
        {"INDEX", "NAME"},
        {L["Index"], NAME},
        nil,
        {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true, ["RAID_GROUP_BY"] = {"CLASS", "GROUP", "NAME", "ROLE"}}
    )

    return raid10
end
local function LoadRaid25Profile(panel)
    local raid25 = CreateFrame("Frame", "GwSettingsRaidPanel", panel, "GwSettingsPanelScrollTmpl")
    raid25.header:SetFont(DAMAGE_TEXT_FONT, 20)
    raid25.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    raid25.header:SetText(L["Group Frames"] )
    raid25.sub:SetFont(UNIT_NAME_FONT, 12)
    raid25.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    raid25.sub:SetText(L["Edit the party and raid options to suit your needs."])

    raid25.header:SetWidth(raid25.header:GetStringWidth())
    raid25.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    raid25.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    raid25.breadcrumb:SetText(RAID..": 25")

    --[[
    p.buttonRaidPreview:SetScript("OnClick", function()
        --GW.GridToggleFramesPreviewRaid(false, false) -- disabled for now
    end)
    p.buttonRaidPreview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to toggle raid frame preview and cycle through different group sizes."], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.buttonRaidPreview:SetScript("OnLeave", GameTooltip_Hide)
    p.buttonRaidPreview:SetEnabled(GetSetting("RAID_FRAMES"))
    ]]

    addOption(raid25.scroll.scrollchild, L["Enable Raid 25 grid"], L["Display a separate raid grid for groups from 11 to 25 players"], "RAID25_ENABLED", function() GW.UpdateGridSettings("RAID10", nil, true); GW.UpdateGridSettings("RAID25", nil, true); GW.UpdateGridSettings("RAID40", nil, true) end, nil, {["RAID_FRAMES"] = true})
    addOption(raid25.scroll.scrollchild, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], "RAID_CLASS_COLOR_RAID25", function() GW.UpdateGridSettings("RAID25") end, nil, {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true})
    addOption(raid25.scroll.scrollchild, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], "RAID_POWER_BARS_RAID25", function() GW.UpdateGridSettings("RAID25") end, nil, {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true})
    addOption(raid25.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "RAID_SHOW_DEBUFFS_RAID25", function() GW.UpdateGridSettings("RAID25") end, nil, {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true})
    addOption(raid25.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "RAID_ONLY_DISPELL_DEBUFFS_RAID25", function() GW.UpdateGridSettings("RAID25") end, nil, {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true, ["RAID_SHOW_DEBUFFS"] = true})
    addOption(raid25.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_RAID25", function() GW.UpdateGridSettings("RAID25") end, nil, {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true})
    addOption(raid25.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], "RAID_UNIT_MARKERS_RAID25", function() GW.UpdateGridSettings("RAID25") end, nil, {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true})
    addOption(raid25.scroll.scrollchild, L["Start Near Center"], L["The initial group will start near the center and grow out."], "UNITFRAME_ANCHOR_FROM_CENTER_RAID25", function() GW.UpdateGridSettings("RAID25", true) end, nil, {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true})
    addOptionDropdown(
        raid25.scroll.scrollchild,
        L["Show Aura Tooltips"],
        L["Show tooltips of buffs and debuffs."],
        "RAID_AURA_TOOLTIP_INCOMBAT_RAID25",
        function()
            GW.UpdateGridSettings("RAID25")
        end,
        {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"},
        {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]},
        nil,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )

    addOptionDropdown(
        raid25.scroll.scrollchild,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH_RAID25",
        function()
            GW.UpdateGridSettings("RAID25")
        end,
        {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        {
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH
        },
        nil,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )

    addOptionDropdown(
        raid25.scroll.scrollchild,
        L["Show Country Flag"],
        L["Display a country flag based on the unit's language"],
        "RAID_UNIT_FLAGS_RAID25",
        function()
            GW.UpdateGridSettings("RAID25")
        end,
        {"NONE", "DIFFERENT", "ALL"},
        {NONE_KEY, L["Different Than Own"], ALL},
        nil,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- Size and Positions
    addGroupHeader(raid25.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(
        raid25.scroll.scrollchild,
        L["Set Raid Growth Direction"],
        L["Set the grow direction for raid frames."],
        "RAID_GROW_RAID25",
        function()
            GW.UpdateGridSettings("RAID25", true)
        end,
        grow,
        MapTable(
            grow,
            function(dir)
                local g1, g2 = strsplit("+", dir)
                return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
            end
        ),
        nil,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )

    addOptionSlider(
        raid25.scroll.scrollchild,
        L["Set Raid Units per Column"],
        L["Set the number of raid unit frames per column or row, depending on grow directions."],
        "RAID_UNITS_PER_COLUMN_RAID25",
        function()
            GW.UpdateGridSettings("RAID25", true)
        end,
        1,
        40,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )

    addOptionSlider(
        raid25.scroll.scrollchild,
        L["Set Raid Unit Width"],
        L["Set the width of the raid units."],
        "RAID_WIDTH_RAID25",
        function()
            GW.UpdateGridSettings("RAID25", false, true)
        end,
        45,
        300,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )

    addOptionSlider(
        raid25.scroll.scrollchild,
        L["Set Raid Unit Height"],
        L["Set the height of the raid units."],
        "RAID_HEIGHT_RAID25",
        function()
            GW.UpdateGridSettings("RAID25", false, true)
        end,
        15,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )

    addOptionSlider(
        raid25.scroll.scrollchild,
        L["Horizontal Spacing"],
        nil,
        "RAID_UNITS_HORIZONTAL_SPACING_RAID25",
        function()
            GW.UpdateGridSettings("RAID25", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )

    addOptionSlider(
        raid25.scroll.scrollchild,
        L["Vertical Spacing"],
        nil,
        "RAID_UNITS_VERTICAL_SPACING_RAID25",
        function()
            GW.UpdateGridSettings("RAID25", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )

    addOptionSlider(
        raid25.scroll.scrollchild,
        L["Group Spacing"],
        L["Additional spacing between each individual group."],
        "RAID_UNITS_GROUP_SPACING_RAID25",
        function()
            GW.UpdateGridSettings("RAID25", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )

    -- Sorting
    addGroupHeader(raid25.scroll.scrollchild, L["Grouping & Sorting"])
    addOption(
        raid25.scroll.scrollchild,
        L["Raid-Wide Sorting"],
        L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."],
        "RAID_WIDE_SORTING_RAID25",
        function()
            GW.UpdateGridSettings("RAID25", true)
        end,
        nil,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )
    addOptionDropdown(
        raid25.scroll.scrollchild,
        L["Group By"],
        L["Set the order that the group will sort."],
        "RAID_GROUP_BY_RAID25",
        function()
            GW.UpdateGridSettings("RAID25", true)
        end,
        {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"},
        {CLASS, GROUP, "Index", NAME, ROLE},
        nil,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )
    addOptionDropdown(
        raid25.scroll.scrollchild,
        L["Sort Direction"],
        nil,
        "RAID_SORT_DIRECTION_RAID25",
        function()
            GW.UpdateGridSettings("RAID25", true)
        end,
        {"ASC", "DESC"},
        {L["Ascending"], L["Descending"]},
        nil,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}
    )
    addOptionDropdown(
        raid25.scroll.scrollchild,
        L["Sort Method"],
        nil,
        "RAID_RAID_SORT_METHOD_RAID25",
        function()
            GW.UpdateGridSettings("RAID25", true)
        end,
        {"INDEX", "NAME"},
        {L["Index"], NAME},
        nil,
        {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true, ["RAID_GROUP_BY"] = {"CLASS", "GROUP", "NAME", "ROLE"}}
    )

    return raid25
end

local function LoadRaid40Profile(panel)
    local raid40 = CreateFrame("Frame", "GwSettingsRaidPanel", panel, "GwSettingsPanelScrollTmpl")
    raid40.header:SetFont(DAMAGE_TEXT_FONT, 20)
    raid40.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    raid40.header:SetText(L["Group Frames"] )
    raid40.sub:SetFont(UNIT_NAME_FONT, 12)
    raid40.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    raid40.sub:SetText(L["Edit the party and raid options to suit your needs."])

    raid40.header:SetWidth(raid40.header:GetStringWidth())
    raid40.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    raid40.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    raid40.breadcrumb:SetText(RAID..": 40")

    --[[
    p.buttonRaidPreview:SetScript("OnClick", function()
        --GW.GridToggleFramesPreviewRaid(false, false) -- disabled for now
    end)
    p.buttonRaidPreview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to toggle raid frame preview and cycle through different group sizes."], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.buttonRaidPreview:SetScript("OnLeave", GameTooltip_Hide)
    p.buttonRaidPreview:SetEnabled(GetSetting("RAID_FRAMES"))
    ]]

    addOption(raid40.scroll.scrollchild, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], "RAID_CLASS_COLOR", function() GW.UpdateGridSettings("RAID40") end, nil, {["RAID_FRAMES"] = true})
    addOption(raid40.scroll.scrollchild, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], "RAID_POWER_BARS", function() GW.UpdateGridSettings("RAID40") end, nil, {["RAID_FRAMES"] = true})
    addOption(raid40.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "RAID_SHOW_DEBUFFS", function() GW.UpdateGridSettings("RAID40") end, nil, {["RAID_FRAMES"] = true})
    addOption(raid40.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "RAID_ONLY_DISPELL_DEBUFFS", function() GW.UpdateGridSettings("RAID40") end, nil, {["RAID_FRAMES"] = true, ["RAID_SHOW_DEBUFFS"] = true})
    addOption(raid40.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF", function() GW.UpdateGridSettings("RAID40") end, nil, {["RAID_FRAMES"] = true})
    addOption(raid40.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], "RAID_UNIT_MARKERS", function() GW.UpdateGridSettings("RAID40") end, nil, {["RAID_FRAMES"] = true})
    addOption(raid40.scroll.scrollchild, L["Start Near Center"], L["The initial group will start near the center and grow out."], "UNITFRAME_ANCHOR_FROM_CENTER", function() GW.UpdateGridSettings("RAID40", true) end, nil, {["RAID_FRAMES"] = true})
    addOptionDropdown(
        raid40.scroll.scrollchild,
        L["Show Aura Tooltips"],
        L["Show tooltips of buffs and debuffs."],
        "RAID_AURA_TOOLTIP_INCOMBAT",
        function()
            GW.UpdateGridSettings("RAID40")
        end,
        {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"},
        {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]},
        nil,
        {["RAID_FRAMES"] = true}
    )

    addOptionDropdown(
        raid40.scroll.scrollchild,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH",
        function()
            GW.UpdateGridSettings("RAID40")
        end,
        {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        {
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH
        },
        nil,
        {["RAID_FRAMES"] = true}
    )

    addOptionDropdown(
        raid40.scroll.scrollchild,
        L["Show Country Flag"],
        L["Display a country flag based on the unit's language"],
        "RAID_UNIT_FLAGS",
        function()
            GW.UpdateGridSettings("RAID40")
        end,
        {"NONE", "DIFFERENT", "ALL"},
        {NONE_KEY, L["Different Than Own"], ALL},
        nil,
        {["RAID_FRAMES"] = true}
    )

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- Size and Positions
    addGroupHeader(raid40.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(
        raid40.scroll.scrollchild,
        L["Set Raid Growth Direction"],
        L["Set the grow direction for raid frames."],
        "RAID_GROW",
        function()
            GW.UpdateGridSettings("RAID40", true)
        end,
        grow,
        MapTable(
            grow,
            function(dir)
                local g1, g2 = strsplit("+", dir)
                return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
            end
        ),
        nil,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        raid40.scroll.scrollchild,
        L["Set Raid Units per Column"],
        L["Set the number of raid unit frames per column or row, depending on grow directions."],
        "RAID_UNITS_PER_COLUMN",
        function()
            GW.UpdateGridSettings("RAID40", true)
        end,
        1,
        40,
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        raid40.scroll.scrollchild,
        L["Set Raid Unit Width"],
        L["Set the width of the raid units."],
        "RAID_WIDTH",
        function()
            GW.UpdateGridSettings("RAID40", false, true)
        end,
        45,
        300,
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        raid40.scroll.scrollchild,
        L["Set Raid Unit Height"],
        L["Set the height of the raid units."],
        "RAID_HEIGHT",
        function()
            GW.UpdateGridSettings("RAID40", false, true)
        end,
        15,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        raid40.scroll.scrollchild,
        L["Horizontal Spacing"],
        nil,
        "RAID_UNITS_HORIZONTAL_SPACING",
        function()
            GW.UpdateGridSettings("RAID40", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        raid40.scroll.scrollchild,
        L["Vertical Spacing"],
        nil,
        "RAID_UNITS_VERTICAL_SPACING",
        function()
            GW.UpdateGridSettings("RAID40", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        raid40.scroll.scrollchild,
        L["Group Spacing"],
        L["Additional spacing between each individual group."],
        "RAID_UNITS_GROUP_SPACING",
        function()
            GW.UpdateGridSettings("RAID40", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    -- Sorting
    addGroupHeader(raid40.scroll.scrollchild, L["Grouping & Sorting"])
    addOption(
        raid40.scroll.scrollchild,
        L["Raid-Wide Sorting"],
        L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."],
        "RAID_WIDE_SORTING",
        function()
            GW.UpdateGridSettings("RAID40", true)
        end,
        nil,
        {["RAID_FRAMES"] = true}
    )
    addOptionDropdown(
        raid40.scroll.scrollchild,
        L["Group By"],
        L["Set the order that the group will sort."],
        "RAID_GROUP_BY",
        function()
            GW.UpdateGridSettings("RAID40", true)
        end,
        {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"},
        {CLASS, GROUP, "Index", NAME, ROLE},
        nil,
        {["RAID_FRAMES"] = true}
    )
    addOptionDropdown(
        raid40.scroll.scrollchild,
        L["Sort Direction"],
        nil,
        "RAID_SORT_DIRECTION",
        function()
            GW.UpdateGridSettings("RAID40", true)
        end,
        {"ASC", "DESC"},
        {L["Ascending"], L["Descending"]},
        nil,
        {["RAID_FRAMES"] = true}
    )
    addOptionDropdown(
        raid40.scroll.scrollchild,
        L["Sort Method"],
        nil,
        "RAID_RAID_SORT_METHOD",
        function()
            GW.UpdateGridSettings("RAID40", true)
        end,
        {"INDEX", "NAME"},
        {L["Index"], NAME},
        nil,
        {["RAID_FRAMES"] = true, ["RAID_GROUP_BY"] = {"CLASS", "GROUP", "NAME", "ROLE"}}
    )

    return raid40
end

local function LoadRaidPetProfile(panel)
    local p = CreateFrame("Frame", "GwSettingsRaidPanel", panel, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(L["Group Frames"] )
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the party and raid options to suit your needs."])

    p.header:SetWidth(p.header:GetStringWidth())
    p.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.breadcrumb:SetText(PET)

    --[[
    p.buttonRaidPreview:SetScript("OnClick", function()
        --GW.GridToggleFramesPreviewRaidPet(false, false)
    end)
    p.buttonRaidPreview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to toggle raid frame preview and cycle through different group sizes."], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.buttonRaidPreview:SetScript("OnLeave", GameTooltip_Hide)
    p.buttonRaidPreview:SetEnabled(GetSetting("RAID_FRAMES") and GetSetting("RAID_PET_FRAMES"))
]]
    addOption(p.scroll.scrollchild, L["Enable Raid pet grid"], L["Show a separate grid for raid pets"], "RAID_PET_FRAMES",  function() GW.UpdateGridSettings("RAID_PET", nil, true) end, nil, {["RAID_FRAMES"] = true})
    addOption(p.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "RAID_SHOW_DEBUFFS_PET", function() GW.UpdateGridSettings("RAID_PET") end, nil, {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true})
    addOption(p.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "RAID_ONLY_DISPELL_DEBUFFS_PET", function() GW.UpdateGridSettings("RAID_PET") end, nil, {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true, ["RAID_SHOW_DEBUFFS_PET"] = true})
    addOption(p.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PET", function() GW.UpdateGridSettings("RAID_PET") end, nil, {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true})
    addOption(p.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], "RAID_UNIT_MARKERS_PET", function() GW.UpdateGridSettings("RAID_PET") end, nil, {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true})
    addOption(p.scroll.scrollchild, L["Start Near Center"], L["The initial group will start near the center and grow out."], "UNITFRAME_ANCHOR_FROM_CENTER_PET", function() GW.UpdateGridSettings("RAID_PET", true) end, nil, {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true})

    addOptionDropdown(
        p.scroll.scrollchild,
        L["Show Aura Tooltips"],
        L["Show tooltips of buffs and debuffs."],
        "RAID_AURA_TOOLTIP_INCOMBAT_PET",
        function()
            GW.UpdateGridSettings("RAID_PET")
        end,
        {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"},
        {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]},
        nil,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}
    )

    addOptionDropdown(
        p.scroll.scrollchild,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH_PET",
        function()
            GW.UpdateGridSettings("RAID_PET")
        end,
        {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        {
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH
        },
        nil,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}
    )

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- Size and Positions
    addGroupHeader(p.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Set Raid Growth Direction"],
        L["Set the grow direction for raid frames."],
        "RAID_GROW_PET",
        function()
            GW.UpdateGridSettings("RAID_PET", true)
        end,
        grow,
        MapTable(
            grow,
            function(dir)
                local g1, g2 = strsplit("+", dir)
                return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
            end
        ),
        nil,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}
    )

    addOptionSlider(
        p.scroll.scrollchild,
        L["Set Raid Units per Column"],
        L["Set the number of raid unit frames per column or row, depending on grow directions."],
        "RAID_UNITS_PER_COLUMN_PET",
        function()
            GW.UpdateGridSettings("RAID_PET", true)
        end,
        1,
        40,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}
    )

    addOptionSlider(
        p.scroll.scrollchild,
        L["Set Raid Unit Width"],
        L["Set the width of the raid units."],
        "RAID_WIDTH_PET",
        function()
            GW.UpdateGridSettings("RAID_PET", false, true)
        end,
        45,
        300,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}
    )

    addOptionSlider(
        p.scroll.scrollchild,
        L["Set Raid Unit Height"],
        L["Set the height of the raid units."],
        "RAID_HEIGHT_PET",
        function()
            GW.UpdateGridSettings("RAID_PET", false, true)
        end,
        15,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}
    )

    addOptionSlider(
        p.scroll.scrollchild,
        L["Horizontal Spacing"],
        nil,
        "RAID_UNITS_HORIZONTAL_SPACING_PET",
        function()
            GW.UpdateGridSettings("RAID_PET", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}
    )

    addOptionSlider(
        p.scroll.scrollchild,
        L["Vertical Spacing"],
        nil,
        "RAID_UNITS_VERTICAL_SPACING_PET",
        function()
            GW.UpdateGridSettings("RAID_PET", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}
    )

    addOptionSlider(
        p.scroll.scrollchild,
        L["Group Spacing"],
        L["Additional spacing between each individual group."],
        "RAID_UNITS_GROUP_SPACING_PET",
        function()
            GW.UpdateGridSettings("RAID_PET", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}
    )

    -- Sorting
    addGroupHeader(p.scroll.scrollchild, L["Grouping & Sorting"])
    addOption(
        p.scroll.scrollchild,
        L["Raid-Wide Sorting"],
        L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."],
        "RAID_WIDE_SORTING_PET",
        function()
            GW.UpdateGridSettings("RAID_PET", true)
        end,
        nil,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Sort Direction"],
        nil,
        "RAID_SORT_DIRECTION_PET",
        function()
            GW.UpdateGridSettings("RAID_PET", true)
        end,
        {"ASC", "DESC"},
        {L["Ascending"], L["Descending"]},
        nil,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Sort Method"],
        nil,
        "RAID_RAID_SORT_METHOD_PET",
        function()
            GW.UpdateGridSettings("RAID_PET", true)
        end,
        {"INDEX", "NAME"},
        {L["Index"], NAME},
        nil,
        {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true, ["RAID_GROUP_BY"] = {"CLASS", "GROUP", "NAME", "ROLE"}}
    )

    return p
end

local function LoadPartyProfile(panel)
    local party = CreateFrame("Frame", "GwSettingsRaidPartyPanel", panel, "GwSettingsPanelScrollTmpl")
    party.header:SetFont(DAMAGE_TEXT_FONT, 20)
    party.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    party.header:SetText(L["Group Frames"])
    party.sub:SetFont(UNIT_NAME_FONT, 12)
    party.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    party.sub:SetText(L["Edit the party and raid options to suit your needs."])

    party.header:SetWidth(party.header:GetStringWidth())
    party.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    party.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    party.breadcrumb:SetText(PARTY)

    --[[
    party.buttonRaidPreview:SetScript("OnClick", function()
        GW.GridToggleFramesPreviewParty(false, false)
    end)
    party.buttonRaidPreview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to toggle raid frame preview and cycle through different group sizes."], 1, 1, 1)
        GameTooltip:Show()
    end)
    party.buttonRaidPreview:SetScript("OnLeave", GameTooltip_Hide)
    party.buttonRaidPreview:SetEnabled(GetSetting("RAID_FRAMES"))
]]
    addOption(party.scroll.scrollchild, USE_RAID_STYLE_PARTY_FRAMES, OPTION_TOOLTIP_USE_RAID_STYLE_PARTY_FRAMES, "RAID_STYLE_PARTY", function() GW.UpdateGridSettings("PARTY"); GW.ShowRlPopup = true end, nil, {["RAID_FRAMES"] = true})
    addOption(party.scroll.scrollchild, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], "RAID_CLASS_COLOR_PARTY", function() GW.UpdateGridSettings("PARTY") end, nil, {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true})
    addOption(party.scroll.scrollchild, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], "RAID_POWER_BARS_PARTY", function() GW.UpdateGridSettings("PARTY") end, nil, {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true})
    addOption(party.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "RAID_SHOW_DEBUFFS_PARTY", function() GW.UpdateGridSettings("PARTY") end, nil, {["RAID_FRAMES"] = true})
    addOption(party.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "RAID_ONLY_DISPELL_DEBUFFS_PARTY", function() GW.UpdateGridSettings("PARTY") end, nil, {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true, ["RAID_SHOW_DEBUFFS_PARTY"] = true})
    addOption(party.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PARTY", function() GW.UpdateGridSettings("PARTY") end, nil, {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true})
    addOption(party.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], "RAID_UNIT_MARKERS_PARTY", function() GW.UpdateGridSettings("PARTY") end, nil, {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true})
    addOption(party.scroll.scrollchild, L["Start Near Center"], L["The initial group will start near the center and grow out."], "UNITFRAME_ANCHOR_FROM_CENTER_PARTY", function() GW.UpdateGridSettings("PARTY", true) end, nil, {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true})

    addOptionDropdown(
        party.scroll.scrollchild,
        L["Show Aura Tooltips"],
        L["Show tooltips of buffs and debuffs."],
        "RAID_AURA_TOOLTIP_INCOMBAT_PARTY",
        function()
            GW.UpdateGridSettings("PARTY")
        end,
        {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"},
        {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]},
        nil,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )

    addOptionDropdown(
        party.scroll.scrollchild,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH_PARTY",
        function()
            GW.UpdateGridSettings("PARTY")
        end,
        {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        {
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH
        },
        nil,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )

    addOptionDropdown(
        party.scroll.scrollchild,
        L["Show Country Flag"],
        L["Display a country flag based on the unit's language"],
        "RAID_UNIT_FLAGS_PARTY",
        function()
            GW.UpdateGridSettings("PARTY")
        end,
        {"NONE", "DIFFERENT", "ALL"},
        {NONE_KEY, L["Different Than Own"], ALL},
        nil,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- Size and Positions
    addGroupHeader(party.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(
        party.scroll.scrollchild,
        L["Set Raid Growth Direction"],
        L["Set the grow direction for raid frames."],
        "RAID_GROW_PARTY",
        function()
            GW.UpdateGridSettings("PARTY", true)
        end,
        grow,
        MapTable(
            grow,
            function(dir)
                local g1, g2 = strsplit("+", dir)
                return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
            end
        ),
        nil,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )

    addOptionSlider(
        party.scroll.scrollchild,
        L["Set Raid Units per Column"],
        L["Set the number of raid unit frames per column or row, depending on grow directions."],
        "RAID_UNITS_PER_COLUMN_PARTY",
        function()
            GW.UpdateGridSettings("PARTY", true)
        end,
        1,
        5,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )

    addOptionSlider(
        party.scroll.scrollchild,
        L["Set Raid Unit Width"],
        L["Set the width of the raid units."],
        "RAID_WIDTH_PARTY",
        function()
            GW.UpdateGridSettings("PARTY", false, true)
        end,
        45,
        300,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )

    addOptionSlider(
        party.scroll.scrollchild,
        L["Set Raid Unit Height"],
        L["Set the height of the raid units."],
        "RAID_HEIGHT_PARTY",
        function()
            GW.UpdateGridSettings("PARTY", false, true)
        end,
        15,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )
    addOptionSlider(
        party.scroll.scrollchild,
        L["Horizontal Spacing"],
        nil,
        "RAID_UNITS_HORIZONTAL_SPACING_PARTY",
        function()
            GW.UpdateGridSettings("PARTY", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )

    addOptionSlider(
        party.scroll.scrollchild,
        L["Vertical Spacing"],
        nil,
        "RAID_UNITS_VERTICAL_SPACING_PARTY",
        function()
            GW.UpdateGridSettings("PARTY", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )

    addOptionSlider(
        party.scroll.scrollchild,
        L["Group Spacing"],
        L["Additional spacing between each individual group."],
        "RAID_UNITS_GROUP_SPACING_PARTY",
        function()
            GW.UpdateGridSettings("PARTY", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )

    -- Sorting
    addGroupHeader(party.scroll.scrollchild, L["Grouping & Sorting"])
    addOption(
        party.scroll.scrollchild,
        L["Raid-Wide Sorting"],
        L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."],
        "RAID_WIDE_SORTING_PARTY",
        function()
            GW.UpdateGridSettings("PARTY", true)
        end,
        nil,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )
    addOptionDropdown(
        party.scroll.scrollchild,
        L["Group By"],
        L["Set the order that the group will sort."],
        "RAID_GROUP_BY_PARTY",
        function()
            GW.UpdateGridSettings("PARTY", true)
        end,
        {"CLASS", "INDEX", "NAME", "ROLE"},
        {CLASS, "Index", NAME, ROLE},
        nil,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )
    addOptionDropdown(
        party.scroll.scrollchild,
        L["Sort Direction"],
        nil,
        "RAID_SORT_DIRECTION_PARTY",
        function()
            GW.UpdateGridSettings("PARTY", true)
        end,
        {"ASC", "DESC"},
        {L["Ascending"], L["Descending"]},
        nil,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}
    )
    addOptionDropdown(
        party.scroll.scrollchild,
        L["Sort Method"],
        nil,
        "RAID_RAID_SORT_METHOD_PARTY",
        function()
            GW.UpdateGridSettings("PARTY", true)
        end,
        {"INDEX", "NAME"},
        {L["Index"], NAME},
        nil,
        {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true, ["RAID_GROUP_BY"] = {"CLASS", "NAME", "ROLE"}}
    )

    return party
end

local function LoadMaintankProfile(panel)
    local tank = CreateFrame("Frame", "GwSettingsRaidPanel", panel, "GwSettingsPanelScrollTmpl")
    tank.header:SetFont(DAMAGE_TEXT_FONT, 20)
    tank.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    tank.header:SetText(L["Group Frames"] )
    tank.sub:SetFont(UNIT_NAME_FONT, 12)
    tank.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    tank.sub:SetText(L["Edit the party and raid options to suit your needs."])

    tank.header:SetWidth(tank.header:GetStringWidth())
    tank.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    tank.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    tank.breadcrumb:SetText(MAINTANK)

    --[[
    p.buttonRaidPreview:SetScript("OnClick", function()
        --GW.GridToggleFramesPreviewRaid(false, false) -- disabled for now
    end)
    p.buttonRaidPreview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to toggle raid frame preview and cycle through different group sizes."], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.buttonRaidPreview:SetScript("OnLeave", GameTooltip_Hide)
    p.buttonRaidPreview:SetEnabled(GetSetting("RAID_FRAMES"))
    ]]

    addOption(tank.scroll.scrollchild, L["Enable Maintank grid"], nil, "RAID_MAINTANK_FRAMES_ENABLED", function() GW.UpdateGridSettings("TANK", nil, true) end, nil, {["RAID_FRAMES"] = true})
    addOption(tank.scroll.scrollchild, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], "RAID_CLASS_COLOR_TANK0", function() GW.UpdateGridSettings("TANK") end, nil, {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true})
    addOption(tank.scroll.scrollchild, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], "RAID_POWER_BARS_TANK", function() GW.UpdateGridSettings("TANK") end, nil, {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true})
    addOption(tank.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "RAID_SHOW_DEBUFFS_TANK", function() GW.UpdateGridSettings("TANK") end, nil, {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true})
    addOption(tank.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "RAID_ONLY_DISPELL_DEBUFFS_TANK", function() GW.UpdateGridSettings("TANK") end, nil, {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true, ["RAID_SHOW_DEBUFFS"] = true})
    addOption(tank.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_TANK", function() GW.UpdateGridSettings("TANK") end, nil, {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true})
    addOption(tank.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], "RAID_UNIT_MARKERS_TANK", function() GW.UpdateGridSettings("TANK") end, nil, {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true})
    addOptionDropdown(
        tank.scroll.scrollchild,
        L["Show Aura Tooltips"],
        L["Show tooltips of buffs and debuffs."],
        "RAID_AURA_TOOLTIP_INCOMBAT_TANK",
        function()
            GW.UpdateGridSettings("TANK")
        end,
        {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"},
        {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]},
        nil,
        {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}
    )

    addOptionDropdown(
        tank.scroll.scrollchild,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH_TANK",
        function()
            GW.UpdateGridSettings("TANK")
        end,
        {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        {
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH
        },
        nil,
        {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}
    )

    addOptionDropdown(
        tank.scroll.scrollchild,
        L["Show Country Flag"],
        L["Display a country flag based on the unit's language"],
        "RAID_UNIT_FLAGS_TANK",
        function()
            GW.UpdateGridSettings("TANK")
        end,
        {"NONE", "DIFFERENT", "ALL"},
        {NONE_KEY, L["Different Than Own"], ALL},
        nil,
        {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}
    )

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- Size and Positions
    addGroupHeader(tank.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(
        tank.scroll.scrollchild,
        L["Set Raid Growth Direction"],
        L["Set the grow direction for raid frames."],
        "RAID_GROW_TANK",
        function()
            GW.UpdateGridSettings("TANK", true)
        end,
        grow,
        MapTable(
            grow,
            function(dir)
                local g1, g2 = strsplit("+", dir)
                return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
            end
        ),
        nil,
        {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}
    )

    addOptionSlider(
        tank.scroll.scrollchild,
        L["Set Raid Units per Column"],
        L["Set the number of raid unit frames per column or row, depending on grow directions."],
        "RAID_UNITS_PER_COLUMN_TANK",
        function()
            GW.UpdateGridSettings("TANK", true)
        end,
        1,
        40,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}
    )

    addOptionSlider(
        tank.scroll.scrollchild,
        L["Set Raid Unit Width"],
        L["Set the width of the raid units."],
        "RAID_WIDTH_TANK",
        function()
            GW.UpdateGridSettings("TANK", false, true)
        end,
        45,
        300,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}
    )

    addOptionSlider(
        tank.scroll.scrollchild,
        L["Set Raid Unit Height"],
        L["Set the height of the raid units."],
        "RAID_HEIGHT_TANK",
        function()
            GW.UpdateGridSettings("TANK", false, true)
        end,
        15,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}
    )

    addOptionSlider(
        tank.scroll.scrollchild,
        L["Horizontal Spacing"],
        nil,
        "RAID_UNITS_HORIZONTAL_SPACING_TANK",
        function()
            GW.UpdateGridSettings("TANK", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}
    )

    addOptionSlider(
        tank.scroll.scrollchild,
        L["Vertical Spacing"],
        nil,
        "RAID_UNITS_VERTICAL_SPACING_TANK",
        function()
            GW.UpdateGridSettings("TANK", true)
        end,
        -1,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}
    )

    return tank
end

local function LoadRaidPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local profilePanles = {LoadRaid40Profile(p), LoadRaid25Profile(p), LoadRaid10Profile(p), LoadMaintankProfile(p), LoadRaidPetProfile(p), LoadPartyProfile(p)}
    createCat(L["Group Frames"], L["Edit the group settings."], p, profilePanles)
    settingsMenuAddButton(L["Group Frames"], p, profilePanles)

    InitPanel(profilePanles[1], true)
    InitPanel(profilePanles[2], true)
    InitPanel(profilePanles[3], true)
    InitPanel(profilePanles[4], true)
    InitPanel(profilePanles[5], true)
    InitPanel(profilePanles[6], true)
end
GW.LoadRaidPanel = LoadRaidPanel
