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
local addGroupHeader = GW.AddGroupHeader


--general Grid Settings
local function LoadGeneralGridSettings(panel)
    local general = CreateFrame("Frame", "GwSettingsRaidPanel", panel, "GwSettingsPanelScrollTmpl")
    general.header:SetFont(DAMAGE_TEXT_FONT, 20)
    general.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    general.header:SetText(L["Group Frames"])
    general.sub:SetFont(UNIT_NAME_FONT, 12)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(L["Edit the party and raid options to suit your needs."])

    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    general.breadcrumb:SetText(GENERAL)

    addOptionSlider(general.scroll.scrollchild, L["Name Update Rate"], L["Maximum tick rate allowed for name updates per second."], { getterSetter = "tagUpdateRate", callback = function(value) GW.oUF.Tags:SetEventUpdateTimer(value) end, min = 0.05, max = 0.5, decimalNumbers = 2, step = 0.01})

    return general
end

-- Profiles
local function LoadRaid10Profile(panel)
    local raid10 = CreateFrame("Frame", "GwSettingsRaidPanel", panel, "GwSettingsRaidPanelTmpl")
    raid10.header:SetFont(DAMAGE_TEXT_FONT, 20)
    raid10.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    raid10.header:SetText(L["Group Frames"])
    raid10.sub:SetFont(UNIT_NAME_FONT, 12)
    raid10.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    raid10.sub:SetText(L["Edit the party and raid options to suit your needs."])

    raid10.header:SetWidth(raid10.header:GetStringWidth())
    raid10.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    raid10.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    raid10.breadcrumb:SetText(RAID..": 10")

    raid10.preview:SetWidth(raid10.preview:GetFontString():GetStringWidth() + 5)
    raid10.preview:SetScript("OnClick", function()
        GW.ToggleGridConfigurationMode(GW.GridGroupHeaders.RAID10, GW.GridGroupHeaders.RAID10.forceShow ~= true or nil)
    end)
    raid10.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    raid10.preview:SetScript("OnLeave", GameTooltip_Hide)
    raid10.preview:SetEnabled(GW.settings.RAID10_ENABLED)

    addOption(raid10.scroll.scrollchild, L["Enable Raid 10 grid"], L["Display a separate raid grid for groups from 1 to 10 players"], {getterSetter = "RAID10_ENABLED", callback = function(value) raid10.preview:SetEnabled(value) GW.UpdateGridSettings("RAID10", nil, true) GW.UpdateGridSettings("RAID25", nil, true) GW.UpdateGridSettings("RAID40", nil, true) end, dependence = {["RAID_FRAMES"] = true}})
    addOption(raid10.scroll.scrollchild, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "RAID_CLASS_COLOR_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOption(raid10.scroll.scrollchild, L["Hide class icon"], nil, {getterSetter = "RAID_HIDE_CLASS_ICON_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true, ["RAID_CLASS_COLOR_RAID10"] = false}})
    addOption(raid10.scroll.scrollchild, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "RAID_POWER_BARS_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOption(raid10.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, {getterSetter = "RAID_SHOW_DEBUFFS_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOption(raid10.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true, ["RAID_SHOW_DEBUFFS"] = true}})
    addOption(raid10.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOption(raid10.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOption(raid10.scroll.scrollchild, L["Role Icon"], nil, {getterSetter = "RAID_SHOW_ROLE_ICON_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOption(raid10.scroll.scrollchild, L["Tank Icon"], nil, {getterSetter = "RAID_SHOW_TANK_ICON_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOption(raid10.scroll.scrollchild, L["Leader/Assist Icon"], nil, {getterSetter = "RAID_SHOW_LEADER_ICON_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOption(raid10.scroll.scrollchild, L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "UNITFRAME_ANCHOR_FROM_CENTER_RAID10", callback = function() GW.UpdateGridSettings("RAID10", true) end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOption(raid10.scroll.scrollchild, L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, hidden = not GW.Retail})
    addOption(raid10.scroll.scrollchild, L["Show absorb bar"], nil, {getterSetter = "RAID_SHOW_ABSORB_BAR_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})

    addOptionDropdown(raid10.scroll.scrollchild, L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionDropdown(raid10.scroll.scrollchild, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, { getterSetter = "RAID_UNIT_HEALTH_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"}, optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionDropdown(raid10.scroll.scrollchild, L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "RAID_UNIT_FLAGS_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, hidden = not GW.Retail})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    --fader
    addGroupHeader(raid10.scroll.scrollchild, L["Fader"])
    addOption(raid10.scroll.scrollchild, L["Range"], nil, {getterSetter = "grid10FrameFaderRange", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, groupHeaderName = L["Fader"]})
    addOptionDropdown(raid10.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "grid10FrameFader", callback = function() GW.UpdateGridSettings("RAID10") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true, ["grid10FrameFaderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]})

    addOptionSlider(raid10.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "grid10FrameFader.smooth", callback = function() GW.UpdateGridSettings("RAID10") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionSlider(raid10.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "grid10FrameFader.minAlpha", callback = function() GW.UpdateGridSettings("RAID10") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionSlider(raid10.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "grid10FrameFader.maxAlpha", callback = function() GW.UpdateGridSettings("RAID10") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})

    -- Size and Positions
    addGroupHeader(raid10.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(raid10.scroll.scrollchild, L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW_RAID10", callback = function() GW.UpdateGridSettings("RAID10", true) end, optionsList = grow, optionNames = MapTable(
            grow,
            function(dir)
                local g1, g2 = strsplit("+", dir)
                return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
            end
       ), dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})

    addOptionSlider(raid10.scroll.scrollchild, L["Groups Per Row/Column"], nil, { getterSetter = "RAID_GROUPS_PER_COLUMN_RAID10", callback = function() GW.UpdateGridSettings("RAID10", true) end, min = 1, max = 2, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionSlider(raid10.scroll.scrollchild, L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH_RAID10", callback = function() GW.UpdateGridSettings("RAID10", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionSlider(raid10.scroll.scrollchild, L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT_RAID10", callback = function() GW.UpdateGridSettings("RAID10", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionSlider(raid10.scroll.scrollchild, L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING_RAID10", callback = function() GW.UpdateGridSettings("RAID10", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionSlider(raid10.scroll.scrollchild, L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING_RAID10", callback = function() GW.UpdateGridSettings("RAID10", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionSlider(raid10.scroll.scrollchild, L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "RAID_UNITS_GROUP_SPACING_RAID10", callback = function() GW.UpdateGridSettings("RAID10", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})

    -- Sorting
    addGroupHeader(raid10.scroll.scrollchild, L["Grouping & Sorting"])
    addOption(raid10.scroll.scrollchild, L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "RAID_WIDE_SORTING_RAID10", callback = function() GW.UpdateGridSettings("RAID10", false, true) end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionDropdown(raid10.scroll.scrollchild, L["Group By"], L["Set the order that the group will sort."], { getterSetter = "RAID_GROUP_BY_RAID10", callback = function() GW.UpdateGridSettings("RAID10", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionDropdown(raid10.scroll.scrollchild, L["Sort Direction"], nil, { getterSetter = "RAID_SORT_DIRECTION_RAID10", callback = function() GW.UpdateGridSettings("RAID10", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    addOptionDropdown(raid10.scroll.scrollchild, L["Sort Method"], nil, { getterSetter = "RAID_RAID_SORT_METHOD_RAID10", callback = function() GW.UpdateGridSettings("RAID10", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true, ["RAID_GROUP_BY_RAID10"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})

    return raid10
end
local function LoadRaid25Profile(panel)
    local raid25 = CreateFrame("Frame", "GwSettingsRaidPanel", panel, "GwSettingsRaidPanelTmpl")
    raid25.header:SetFont(DAMAGE_TEXT_FONT, 20)
    raid25.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    raid25.header:SetText(L["Group Frames"])
    raid25.sub:SetFont(UNIT_NAME_FONT, 12)
    raid25.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    raid25.sub:SetText(L["Edit the party and raid options to suit your needs."])

    raid25.header:SetWidth(raid25.header:GetStringWidth())
    raid25.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    raid25.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    raid25.breadcrumb:SetText(RAID..": 25")

    raid25.preview:SetWidth(raid25.preview:GetFontString():GetStringWidth() + 5)
    raid25.preview:SetScript("OnClick", function()
        GW.ToggleGridConfigurationMode(GW.GridGroupHeaders.RAID25, GW.GridGroupHeaders.RAID25.forceShow ~= true or nil)
    end)
    raid25.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    raid25.preview:SetScript("OnLeave", GameTooltip_Hide)
    raid25.preview:SetEnabled(GW.settings.RAID25_ENABLED)

    addOption(raid25.scroll.scrollchild, L["Enable Raid 25 grid"], L["Display a separate raid grid for groups from 11 to 25 players"], {getterSetter = "RAID25_ENABLED", callback = function(value) raid25.preview:SetEnabled(value); GW.UpdateGridSettings("RAID10", nil, true); GW.UpdateGridSettings("RAID25", nil, true); GW.UpdateGridSettings("RAID40", nil, true) end, dependence = {["RAID_FRAMES"] = true}})
    addOption(raid25.scroll.scrollchild, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "RAID_CLASS_COLOR_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOption(raid25.scroll.scrollchild, L["Hide class icon"], nil, {getterSetter = "RAID_HIDE_CLASS_ICON_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true, ["RAID_CLASS_COLOR_RAID25"] = false}})
    addOption(raid25.scroll.scrollchild, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "RAID_POWER_BARS_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOption(raid25.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, {getterSetter = "RAID_SHOW_DEBUFFS_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOption(raid25.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true, ["RAID_SHOW_DEBUFFS"] = true}})
    addOption(raid25.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOption(raid25.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOption(raid25.scroll.scrollchild, L["Role Icon"], nil, {getterSetter = "RAID_SHOW_ROLE_ICON_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOption(raid25.scroll.scrollchild, L["Tank Icon"], nil, {getterSetter = "RAID_SHOW_TANK_ICON_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOption(raid25.scroll.scrollchild, L["Leader/Assist Icon"], nil, {getterSetter = "RAID_SHOW_LEADER_ICON_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOption(raid25.scroll.scrollchild, L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "UNITFRAME_ANCHOR_FROM_CENTER_RAID25", callback = function() GW.UpdateGridSettings("RAID25", true) end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOption(raid25.scroll.scrollchild, L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, hidden = not GW.Retail})
    addOption(raid25.scroll.scrollchild, L["Show absorb bar"] , nil, {getterSetter = "RAID_SHOW_ABSORB_BAR_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})

    addOptionDropdown(raid25.scroll.scrollchild, L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionDropdown(raid25.scroll.scrollchild, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, { getterSetter = "RAID_UNIT_HEALTH_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"}, optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionDropdown(raid25.scroll.scrollchild, L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "RAID_UNIT_FLAGS_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, hidden = not GW.Retail})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    --fader
    addGroupHeader(raid25.scroll.scrollchild, L["Fader"])
    addOption(raid25.scroll.scrollchild, L["Range"], nil, {getterSetter = "grid25FrameFaderRange", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, groupHeaderName = L["Fader"]})

    addOptionDropdown(raid25.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "grid25FrameFader", callback = function() GW.UpdateGridSettings("RAID25") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true, ["grid25FrameFaderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(raid25.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "grid25FrameFader.smooth", callback = function() GW.UpdateGridSettings("RAID25") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionSlider(raid25.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "grid25FrameFader.minAlpha", callback = function() GW.UpdateGridSettings("RAID25") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionSlider(raid25.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "grid25FrameFader.maxAlpha", callback = function() GW.UpdateGridSettings("RAID25") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})

    -- Size and Positions
    addGroupHeader(raid25.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(raid25.scroll.scrollchild, L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW_RAID25", callback = function() GW.UpdateGridSettings("RAID25", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})

    addOptionSlider(raid25.scroll.scrollchild, L["Groups Per Row/Column"], nil, { getterSetter = "RAID_GROUPS_PER_COLUMN_RAID25", callback = function() GW.UpdateGridSettings("RAID25", true) end, min = 1, max = 5, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionSlider(raid25.scroll.scrollchild, L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH_RAID25", callback = function() GW.UpdateGridSettings("RAID25", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionSlider(raid25.scroll.scrollchild, L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT_RAID25", callback = function() GW.UpdateGridSettings("RAID25", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionSlider(raid25.scroll.scrollchild, L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING_RAID25", callback = function() GW.UpdateGridSettings("RAID25", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionSlider(raid25.scroll.scrollchild, L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING_RAID25", callback = function() GW.UpdateGridSettings("RAID25", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionSlider(raid25.scroll.scrollchild, L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "RAID_UNITS_GROUP_SPACING_RAID25", callback = function() GW.UpdateGridSettings("RAID25", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})

    -- Sorting
    addGroupHeader(raid25.scroll.scrollchild, L["Grouping & Sorting"])
    addOption(raid25.scroll.scrollchild, L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "RAID_WIDE_SORTING_RAID25", callback = function() GW.UpdateGridSettings("RAID25", false, true) end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionDropdown(raid25.scroll.scrollchild, L["Group By"], L["Set the order that the group will sort."], { getterSetter = "RAID_GROUP_BY_RAID25", callback = function() GW.UpdateGridSettings("RAID25", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionDropdown(raid25.scroll.scrollchild, L["Sort Direction"], nil, { getterSetter = "RAID_SORT_DIRECTION_RAID25", callback = function() GW.UpdateGridSettings("RAID25", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    addOptionDropdown(raid25.scroll.scrollchild, L["Sort Method"], nil, { getterSetter = "RAID_RAID_SORT_METHOD_RAID25", callback = function() GW.UpdateGridSettings("RAID25", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true, ["RAID_GROUP_BY_RAID25"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})

    return raid25
end
local function LoadRaid40Profile(panel)
    local raid40 = CreateFrame("Frame", "GwSettingsRaidPanel", panel, "GwSettingsRaidPanelTmpl")
    raid40.header:SetFont(DAMAGE_TEXT_FONT, 20)
    raid40.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    raid40.header:SetText(L["Group Frames"])
    raid40.sub:SetFont(UNIT_NAME_FONT, 12)
    raid40.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    raid40.sub:SetText(L["Edit the party and raid options to suit your needs."])

    raid40.header:SetWidth(raid40.header:GetStringWidth())
    raid40.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    raid40.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    raid40.breadcrumb:SetText(RAID..": 40")

    raid40.preview:SetWidth(raid40.preview:GetFontString():GetStringWidth() + 5)
    raid40.preview:SetScript("OnClick", function()
        GW.ToggleGridConfigurationMode(GW.GridGroupHeaders.RAID40, GW.GridGroupHeaders.RAID40.forceShow ~= true or nil)
    end)
    raid40.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    raid40.preview:SetScript("OnLeave", GameTooltip_Hide)
    raid40.preview:SetEnabled(GW.settings.RAID_FRAMES)

    addOption(raid40.scroll.scrollchild, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "RAID_CLASS_COLOR", callback = function(value) raid40.preview:SetEnabled(value); GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true}})
    addOption(raid40.scroll.scrollchild, L["Hide class icon"], nil, {getterSetter = "RAID_HIDE_CLASS_ICON", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID_CLASS_COLOR"] = false}})
    addOption(raid40.scroll.scrollchild, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "RAID_POWER_BARS", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true}})
    addOption(raid40.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, {getterSetter = "RAID_SHOW_DEBUFFS", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true}})
    addOption(raid40.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID_SHOW_DEBUFFS"] = true}})
    addOption(raid40.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true}})
    addOption(raid40.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true}})
    addOption(raid40.scroll.scrollchild, L["Role Icon"], nil, {getterSetter = "RAID_SHOW_ROLE_ICON", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true}})
    addOption(raid40.scroll.scrollchild, L["Tank Icon"], nil, {getterSetter = "RAID_SHOW_TANK_ICON", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true}})
    addOption(raid40.scroll.scrollchild, L["Leader/Assist Icon"], nil, {getterSetter = "RAID_SHOW_LEADER_ICON", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true}})
    addOption(raid40.scroll.scrollchild, L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "UNITFRAME_ANCHOR_FROM_CENTER", callback = function() GW.UpdateGridSettings("RAID40", true) end, dependence = {["RAID_FRAMES"] = true}})
    addOption(raid40.scroll.scrollchild, L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true}, hidden = not GW.Retail})
    addOption(raid40.scroll.scrollchild, L["Show absorb bar"], nil, {getterSetter = "RAID_SHOW_ABSORB_BAR", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true}})
    addOptionDropdown(raid40.scroll.scrollchild, L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT", callback = function() GW.UpdateGridSettings("RAID40") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true}})
    addOptionDropdown(raid40.scroll.scrollchild, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, { getterSetter = "RAID_UNIT_HEALTH", callback = function() GW.UpdateGridSettings("RAID40") end, optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"}, optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}, dependence = {["RAID_FRAMES"] = true}})
    addOptionDropdown(raid40.scroll.scrollchild, L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "RAID_UNIT_FLAGS", callback = function() GW.UpdateGridSettings("RAID40") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["RAID_FRAMES"] = true}, hidden = not GW.Retail})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

        --fader
    addGroupHeader(raid40.scroll.scrollchild, L["Fader"])
    addOption(raid40.scroll.scrollchild, L["Range"], nil, {getterSetter = "grid40FrameFaderRange", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true}, groupHeaderName = L["Fader"]})
    addOptionDropdown(raid40.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "grid40FrameFader", callback = function() GW.UpdateGridSettings("RAID40") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["RAID_FRAMES"] = true, ["grid40FrameFaderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(raid40.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "grid40FrameFader.smooth", callback = function() GW.UpdateGridSettings("RAID40") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true}})
    addOptionSlider(raid40.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "grid40FrameFader.minAlpha", callback = function() GW.UpdateGridSettings("RAID40") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true}})
    addOptionSlider(raid40.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "grid40FrameFader.maxAlpha", callback = function() GW.UpdateGridSettings("RAID40") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true}})

    -- Size and Positions
    addGroupHeader(raid40.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(raid40.scroll.scrollchild, L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW", callback = function() GW.UpdateGridSettings("RAID40", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["RAID_FRAMES"] = true}})

    addOptionSlider(raid40.scroll.scrollchild, L["Groups Per Row/Column"], nil, { getterSetter = "RAID_GROUPS_PER_COLUMN", callback = function() GW.UpdateGridSettings("RAID40", true) end, min = 1, max = 8, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true}})
    addOptionSlider(raid40.scroll.scrollchild, L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH", callback = function() GW.UpdateGridSettings("RAID40", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true}})
    addOptionSlider(raid40.scroll.scrollchild, L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT", callback = function() GW.UpdateGridSettings("RAID40", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true}})
    addOptionSlider(raid40.scroll.scrollchild, L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING", callback = function() GW.UpdateGridSettings("RAID40", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true}})
    addOptionSlider(raid40.scroll.scrollchild, L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING", callback = function() GW.UpdateGridSettings("RAID40", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true}})
    addOptionSlider(raid40.scroll.scrollchild, L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "RAID_UNITS_GROUP_SPACING", callback = function() GW.UpdateGridSettings("RAID40", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence ={["RAID_FRAMES"] = true}})

    -- Sorting
    addGroupHeader(raid40.scroll.scrollchild, L["Grouping & Sorting"])
    addOption(raid40.scroll.scrollchild, L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "RAID_WIDE_SORTING", callback = function() GW.UpdateGridSettings("RAID40", false, true) end, dependence = {["RAID_FRAMES"] = true}})
    addOptionDropdown(raid40.scroll.scrollchild, L["Group By"], L["Set the order that the group will sort."], { getterSetter = "RAID_GROUP_BY", callback = function() GW.UpdateGridSettings("RAID40", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["RAID_FRAMES"] = true}})
    addOptionDropdown(raid40.scroll.scrollchild, L["Sort Direction"], nil, { getterSetter = "RAID_SORT_DIRECTION", callback = function() GW.UpdateGridSettings("RAID40", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["RAID_FRAMES"] = true}})
    addOptionDropdown(raid40.scroll.scrollchild, L["Sort Method"], nil, { getterSetter = "T", callback = function() GW.UpdateGridSettings("RAID40", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["RAID_FRAMES"] = true, ["RAID_GROUP_BY"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})

    return raid40
end
local function LoadRaidPetProfile(panel)
    local p = CreateFrame("Frame", "GwSettingsRaidPanel", panel, "GwSettingsRaidPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.header:SetText(L["Group Frames"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the party and raid options to suit your needs."])

    p.header:SetWidth(p.header:GetStringWidth())
    p.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.breadcrumb:SetText(PET)

    p.preview:SetWidth(p.preview:GetFontString():GetStringWidth() + 5)
    p.preview:SetScript("OnClick", function()
        GW.ToggleGridConfigurationMode(GW.GridGroupHeaders.RAID_PET, GW.GridGroupHeaders.RAID_PET.forceShow ~= true or nil)
    end)
    p.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.preview:SetScript("OnLeave", GameTooltip_Hide)
    p.preview:SetEnabled(GW.settings.RAID_PET_FRAMES)

    addOption(p.scroll.scrollchild, L["Enable Raid pet grid"], L["Show a separate grid for raid pets"], {getterSetter = "RAID_PET_FRAMES", callback = function(value) p.preview:SetEnabled(value); GW.UpdateGridSettings("RAID_PET", nil, true) end, dependence = {["RAID_FRAMES"] = true}})
    addOption(p.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, {getterSetter = "RAID_SHOW_DEBUFFS_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOption(p.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true, ["RAID_SHOW_DEBUFFS_PET"] = true}})
    addOption(p.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOption(p.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOption(p.scroll.scrollchild, L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "UNITFRAME_ANCHOR_FROM_CENTER_PET", callback = function() GW.UpdateGridSettings("RAID_PET", true) end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOption(p.scroll.scrollchild, L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}, hidden = not GW.Retail})
    addOption(p.scroll.scrollchild, L["Show absorb bar"], nil, {getterSetter = "RAID_SHOW_ABSORB_BAR_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})

    addOptionDropdown(p.scroll.scrollchild, L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOptionDropdown(p.scroll.scrollchild, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, { getterSetter = "RAID_UNIT_HEALTH_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"}, optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    --fader
    addGroupHeader(p.scroll.scrollchild, L["Fader"])
    addOption(p.scroll.scrollchild, L["Range"], nil, {getterSetter = "gridPetFrameFaderRange", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}, groupHeaderName = L["Fader"]})
    addOptionDropdown(p.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "gridPetFrameFader", callback = function() GW.UpdateGridSettings("RAID_PET") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true, ["gridPetFrameFaderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(p.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "gridPetFrameFader.smooth", callback = function() GW.UpdateGridSettings("RAID_PET") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOptionSlider(p.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "gridPetFrameFader.minAlpha", callback = function() GW.UpdateGridSettings("RAID_PET") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOptionSlider(p.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "gridPetFrameFader.maxAlpha", callback = function() GW.UpdateGridSettings("RAID_PET") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})

    -- Size and Positions
    addGroupHeader(p.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(p.scroll.scrollchild, L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW_PET", callback = function() GW.UpdateGridSettings("RAID_PET", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})

    addOptionSlider(p.scroll.scrollchild, L["Groups Per Row/Column"], nil, { getterSetter = "RAID_GROUPS_PER_COLUMN_PET", callback = function() GW.UpdateGridSettings("RAID_PET", true) end, min = 1, max = 8, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOptionSlider(p.scroll.scrollchild, L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH_PET", callback = function() GW.UpdateGridSettings("RAID_PET", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOptionSlider(p.scroll.scrollchild, L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT_PET", callback = function() GW.UpdateGridSettings("RAID_PET", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOptionSlider(p.scroll.scrollchild, L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING_PET", callback = function() GW.UpdateGridSettings("RAID_PET", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOptionSlider(p.scroll.scrollchild, L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING_PET", callback = function() GW.UpdateGridSettings("RAID_PET", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOptionSlider(p.scroll.scrollchild, L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "RAID_UNITS_GROUP_SPACING_PET", callback = function() GW.UpdateGridSettings("RAID_PET", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})

    -- Sorting
    addGroupHeader(p.scroll.scrollchild, L["Grouping & Sorting"])
    addOption(p.scroll.scrollchild, L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "RAID_WIDE_SORTING_PET", callback = function() GW.UpdateGridSettings("RAID_PET", false, true) end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOptionDropdown(p.scroll.scrollchild, L["Sort Direction"], nil, { getterSetter = "RAID_SORT_DIRECTION_PET", callback = function() GW.UpdateGridSettings("RAID_PET", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    addOptionDropdown(p.scroll.scrollchild, L["Sort Method"], nil, { getterSetter = "RAID_RAID_SORT_METHOD_PET", callback = function() GW.UpdateGridSettings("RAID_PET", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})

    return p
end
local function LoadPartyProfile(panel)
    local party = CreateFrame("Frame", "GwSettingsRaidPartyPanel", panel, "GwSettingsRaidPanelTmpl")
    party.header:SetFont(DAMAGE_TEXT_FONT, 20)
    party.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    party.header:SetText(L["Group Frames"])
    party.sub:SetFont(UNIT_NAME_FONT, 12)
    party.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    party.sub:SetText(L["Edit the party and raid options to suit your needs."])

    party.header:SetWidth(party.header:GetStringWidth())
    party.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    party.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    party.breadcrumb:SetText(PARTY)

    party.preview:SetWidth(party.preview:GetFontString():GetStringWidth() + 5)
    party.preview:SetScript("OnClick", function()
        GW.ToggleGridConfigurationMode(GW.GridGroupHeaders.PARTY, GW.GridGroupHeaders.PARTY.forceShow ~= true or nil)
    end)
    party.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    party.preview:SetScript("OnLeave", GameTooltip_Hide)
    party.preview:SetEnabled(GW.settings.RAID_STYLE_PARTY)

    addOption(party.scroll.scrollchild, USE_RAID_STYLE_PARTY_FRAMES, OPTION_TOOLTIP_USE_RAID_STYLE_PARTY_FRAMES, {getterSetter = "RAID_STYLE_PARTY", callback = function(value) party.preview:SetEnabled(value); GW.UpdateGridSettings("PARTY", false, true); GW.UpdatePlayerInPartySetting(value) end, dependence = {["RAID_FRAMES"] = true}})
    addOption(party.scroll.scrollchild, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "RAID_CLASS_COLOR_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOption(party.scroll.scrollchild, L["Hide class icon"], nil, {getterSetter = "RAID_HIDE_CLASS_ICON_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true, ["RAID_CLASS_COLOR_PARTY"] = false}})
    addOption(party.scroll.scrollchild, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "RAID_POWER_BARS_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOption(party.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, {getterSetter = "RAID_SHOW_DEBUFFS_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true}})
    addOption(party.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true, ["RAID_SHOW_DEBUFFS_PARTY"] = true}})
    addOption(party.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOption(party.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOption(party.scroll.scrollchild, L["Role Icon"], nil, {getterSetter = "RAID_SHOW_ROLE_ICON_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOption(party.scroll.scrollchild, L["Tank Icon"], nil, {getterSetter = "RAID_SHOW_TANK_ICON_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOption(party.scroll.scrollchild, L["Leader/Assist Icon"], nil, {getterSetter = "RAID_SHOW_LEADER_ICON_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOption(party.scroll.scrollchild, L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "UNITFRAME_ANCHOR_FROM_CENTER_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOption(party.scroll.scrollchild, L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}, hidden = not GW.Retail})
    addOption(party.scroll.scrollchild, L["Player frame in group"], L["Show your player frame as part of the group"], {getterSetter = "RAID_SHOW_PLAYER_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOption(party.scroll.scrollchild, L["Show absorb bar"], nil, {getterSetter = "RAID_SHOW_ABSORB_BAR_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})

    addOptionDropdown(party.scroll.scrollchild, L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOptionDropdown(party.scroll.scrollchild, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, { getterSetter = "RAID_UNIT_HEALTH_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"}, optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOptionDropdown(party.scroll.scrollchild, L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "RAID_UNIT_FLAGS_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}, hidden = not GW.Retail})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    --fader
    addGroupHeader(party.scroll.scrollchild, L["Fader"])
    addOption(party.scroll.scrollchild, L["Range"], nil, {getterSetter = "gridPartyFrameFaderRange", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}, groupHeaderName = L["Fader"]})
    addOptionDropdown(party.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "gridPartyFrameFader", callback = function() GW.UpdateGridSettings("PARTY") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true, ["gridPartyFrameFaderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(party.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "gridPartyFrameFader.smooth", callback = function() GW.UpdateGridSettings("PARTY") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOptionSlider(party.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "gridPartyFrameFader.minAlpha", callback = function() GW.UpdateGridSettings("PARTY") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOptionSlider(party.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "gridPartyFrameFader.maxAlpha", callback = function() GW.UpdateGridSettings("PARTY") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})

    -- Size and Positions
    addGroupHeader(party.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(party.scroll.scrollchild, L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})


    addOptionSlider(party.scroll.scrollchild, L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH_PARTY", callback = function() GW.UpdateGridSettings("PARTY", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOptionSlider(party.scroll.scrollchild, L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT_PARTY", callback = function() GW.UpdateGridSettings("PARTY", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOptionSlider(party.scroll.scrollchild, L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOptionSlider(party.scroll.scrollchild, L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOptionSlider(party.scroll.scrollchild, L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "RAID_UNITS_GROUP_SPACING_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})

    -- Sorting
    addGroupHeader(party.scroll.scrollchild, L["Grouping & Sorting"])
    addOption(party.scroll.scrollchild, L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "RAID_WIDE_SORTING_PARTY", callback = function() GW.UpdateGridSettings("PARTY", false, true) end, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOptionDropdown(party.scroll.scrollchild, L["Group By"], L["Set the order that the group will sort."], { getterSetter = "RAID_GROUP_BY_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOptionDropdown(party.scroll.scrollchild, L["Sort Direction"], nil, { getterSetter = "RAID_SORT_DIRECTION_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true}})
    addOptionDropdown(party.scroll.scrollchild, L["Sort Method"], nil, { getterSetter = "RAID_RAID_SORT_METHOD_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["RAID_FRAMES"] = true, ["RAID_STYLE_PARTY"] = true, ["RAID_GROUP_BY_PARTY"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})

    return party
end

local function LoadMaintankProfile(panel)
    local tank = CreateFrame("Frame", "GwSettingsRaidPanel", panel, "GwSettingsRaidPanelTmpl")
    tank.header:SetFont(DAMAGE_TEXT_FONT, 20)
    tank.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    tank.header:SetText(L["Group Frames"])
    tank.sub:SetFont(UNIT_NAME_FONT, 12)
    tank.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    tank.sub:SetText(L["Edit the party and raid options to suit your needs."])

    tank.header:SetWidth(tank.header:GetStringWidth())
    tank.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    tank.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    tank.breadcrumb:SetText(MAINTANK)

    tank.preview:SetWidth(tank.preview:GetFontString():GetStringWidth() + 5)
    tank.preview:SetScript("OnClick", function()
        GW.ToggleGridConfigurationMode(GW.GridGroupHeaders.TANK, GW.GridGroupHeaders.TANK.forceShow ~= true or nil)
    end)
    tank.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    tank.preview:SetScript("OnLeave", GameTooltip_Hide)
    tank.preview:SetEnabled(GW.settings.RAID_MAINTANK_FRAMES_ENABLED)

    addOption(tank.scroll.scrollchild, L["Enable Maintank grid"], nil, {getterSetter = "RAID_MAINTANK_FRAMES_ENABLED", callback = function(value) tank.preview:SetEnabled(value); GW.UpdateGridSettings("TANK", nil, true) end, dependence = {["RAID_FRAMES"] = true}})
    addOption(tank.scroll.scrollchild, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "RAID_CLASS_COLOR_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOption(tank.scroll.scrollchild, L["Hide class icon"], nil, {getterSetter = "RAID_HIDE_CLASS_ICON_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true, ["RAID_CLASS_COLOR_TANK"] = false}})
    addOption(tank.scroll.scrollchild, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "RAID_POWER_BARS_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOption(tank.scroll.scrollchild, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, {getterSetter = "RAID_SHOW_DEBUFFS_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOption(tank.scroll.scrollchild, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true, ["RAID_SHOW_DEBUFFS"] = true}})
    addOption(tank.scroll.scrollchild, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOption(tank.scroll.scrollchild, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOption(tank.scroll.scrollchild, L["Role Icon"], nil, {getterSetter = "RAID_SHOW_ROLE_ICON_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOption(tank.scroll.scrollchild, L["Tank Icon"], nil, {getterSetter = "RAID_SHOW_TANK_ICON_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOption(tank.scroll.scrollchild, L["Leader/Assist Icon"], nil, {getterSetter = "RAID_SHOW_LEADER_ICON_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOption(tank.scroll.scrollchild, L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, hidden = not GW.Retail})
    addOption(tank.scroll.scrollchild, L["Show absorb bar"], nil, {getterSetter = "RAID_SHOW_ABSORB_BAR_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})


    addOptionDropdown(tank.scroll.scrollchild, L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT_TANK", callback = function() GW.UpdateGridSettings("TANK") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOptionDropdown(tank.scroll.scrollchild, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, { getterSetter = "RAID_UNIT_HEALTH_TANK", callback = function() GW.UpdateGridSettings("TANK") end, optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"}, optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOptionDropdown(tank.scroll.scrollchild, L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "RAID_UNIT_FLAGS_TANK", callback = function() GW.UpdateGridSettings("TANK") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, hidden = not GW.Retail})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    --fader
    addGroupHeader(tank.scroll.scrollchild, L["Fader"])
    addOption(tank.scroll.scrollchild, L["Range"], nil, {getterSetter = "gridTankFrameFaderRange", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, groupHeaderName = L["Fader"]})
    addOptionDropdown(tank.scroll.scrollchild, GW.NewSign .. L["Fader"], nil, { getterSetter = "gridTankFrameFader", callback = function() GW.UpdateGridSettings("TANK") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true, ["gridTankFrameFaderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]})
    addOptionSlider(tank.scroll.scrollchild, GW.NewSign .. L["Smooth"], nil, { getterSetter = "gridTankFrameFader.smooth", callback = function() GW.UpdateGridSettings("TANK") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOptionSlider(tank.scroll.scrollchild, GW.NewSign .. L["Min Alpha"], nil, { getterSetter = "gridTankFrameFader.minAlpha", callback = function() GW.UpdateGridSettings("TANK") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOptionSlider(tank.scroll.scrollchild, GW.NewSign .. L["Max Alpha"], nil, { getterSetter = "gridTankFrameFader.maxAlpha", callback = function() GW.UpdateGridSettings("TANK") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})

    -- Size and Positions
    addGroupHeader(tank.scroll.scrollchild,  L["Size and Positions"])
    addOptionDropdown(tank.scroll.scrollchild, L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW_TANK", callback = function() GW.UpdateGridSettings("TANK", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})

    addOptionSlider(tank.scroll.scrollchild, L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH_TANK", callback = function() GW.UpdateGridSettings("TANK", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOptionSlider(tank.scroll.scrollchild, L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT_TANK", callback = function() GW.UpdateGridSettings("TANK", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOptionSlider(tank.scroll.scrollchild, L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING_TANK", callback = function() GW.UpdateGridSettings("TANK", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    addOptionSlider(tank.scroll.scrollchild, L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING_TANK", callback = function() GW.UpdateGridSettings("TANK", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})

    return tank
end

local function LoadRaidPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local profilePanles = {LoadGeneralGridSettings(p), LoadRaid40Profile(p), LoadRaid25Profile(p), LoadRaid10Profile(p), LoadMaintankProfile(p), LoadRaidPetProfile(p), LoadPartyProfile(p)}
    createCat(L["Group Frames"], L["Edit the group settings."], p, profilePanles, true)

    InitPanel(profilePanles[1], true)
    InitPanel(profilePanles[2], true)
    InitPanel(profilePanles[3], true)
    InitPanel(profilePanles[4], true)
    InitPanel(profilePanles[5], true)
    InitPanel(profilePanles[6], true)
    InitPanel(profilePanles[7], true)
end
GW.LoadRaidPanel = LoadRaidPanel
