---@class GW2
local GW = select(2, ...)
local L = GW.L
local MapTable = GW.MapTable
local StrUpper = GW.StrUpper
local StrLower = GW.StrLower

-- tri-state aura filters: properties block + filter token block
local auraOptions = {
    "HEADER", "isAuraPlayer", "isAuraRaidPlayerDispellable", "isAuraStealable", "isAuraBoss", "isAuraPriority", "isAuraRole",
    "HEADER", "isAuraRaid", "isAuraRaidInCombat", "isAuraCancelable", "isAuraCrowdControl", "isAuraBigDefensive", "isAuraExternalDefensive", "isAuraImportant"
}
local auraOptionsNames = {
    L["Aura Properties"], PLAYER, L["Dispellable"], L["Stealable"], L["Boss Aura"], L["Priority Debuff"], L["Role Aura"],
    FILTERS, RAID, RAID_FRAMES_LABEL, L["Is Cancelable"], L["Crowd Control"], L["Big Defensive"], L["External Defensives"], L["Important"]
}
local statusBarTexturesOptions, statusBarTexturesLables = GW.GetStatusBarTextures()

local classOrderValues, classOrderNames = {}, {}
local pendingGridSettingUpdates = {}
local pendingGridSettingTimers = {}

for _, classFile in ipairs({"DEATHKNIGHT","DEMONHUNTER","DRUID","EVOKER","HUNTER","MAGE","PALADIN","PRIEST","ROGUE","SHAMAN","WARLOCK","WARRIOR","MONK"}) do
    local maleName = LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classFile]
    local femaleName = LOCALIZED_CLASS_NAMES_FEMALE and LOCALIZED_CLASS_NAMES_FEMALE[classFile]
    local className = maleName or femaleName
    if className then
        local index = #classOrderValues + 1
        local color = RAID_CLASS_COLORS[classFile]

        classOrderValues[index] = classFile
        classOrderNames[index] =  color:WrapTextInColorCode(className)
    end
end

local function IsGridPreviewActive(profile)
    local header = GW.GridGroupHeaders[profile]
    return header and header.forceShow
end

-- preview buttons share one handler: registers with the settings preview
-- tracker so only one preview is active and it closes with the window
local function GridPreviewOnClick(profileKey)
    return function()
        if InCombatLockdown() then return end
        local header = GW.GridGroupHeaders[profileKey]
        if header.forceShow then
            GW.ToggleGridConfigurationMode(header, nil)
            GW.DeactivateSettingsPreview(profileKey)
        else
            GW.ActivateSettingsPreview(profileKey, function()
                GW.ToggleGridConfigurationMode(GW.GridGroupHeaders[profileKey], nil)
            end)
            GW.ToggleGridConfigurationMode(header, true)
        end
    end
end

local function UpdateGridSettingsThrottled(profile, onlyHeaderUpdate, updateHeaderAndFrames)
    if not IsGridPreviewActive(profile) then
        GW.UpdateGridSettings(profile, onlyHeaderUpdate, updateHeaderAndFrames)
        return
    end

    pendingGridSettingUpdates[profile] = true

    if pendingGridSettingTimers[profile] then return end

    pendingGridSettingTimers[profile] = C_Timer.NewTimer(0.1, function()
        pendingGridSettingTimers[profile] = nil

        local hasPendingUpdate = pendingGridSettingUpdates[profile]
        pendingGridSettingUpdates[profile] = nil
        if hasPendingUpdate then
            GW.UpdateGridSettings(profile, true)
            GW.RefreshGridConfigurationMode(profile, nil, true)
        end
    end)
end

--general Grid Settings
local function LoadGeneralGridSettings(panel)
    local general = CreateFrame("Frame", nil, panel, "GwSettingsPanelTmpl")
    general.panelId = "raid_general"
    general.header:SetFont(DAMAGE_TEXT_FONT, 20)
    general.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    general.header:SetText(L["Group Frames"])
    general.sub:SetFont(UNIT_NAME_FONT, 12)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(L["General settings for all group frames."])

    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    general.breadcrumb:SetText(GENERAL)

    -- module master for ALL group frames (raid grids, party grid, pets, tank); the
    -- individual raid grids carry their own enable on their pages
    general:AddOption(ENABLE, RAID_FRAMES_SUBTEXT, {getterSetter = "RAID_FRAMES", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})

    general:AddOptionSlider(L["Name Update Rate"], L["Maximum tick rate allowed for name updates per second."], { getterSetter = "tagUpdateRate", callback = function(value) GW.oUF.Tags:SetEventUpdateTimer(value) end, min = 0.05, max = 0.5, decimalNumbers = 2, step = 0.01})

    return general
end

-- NOTE 12.1: the private aura options were removed — the anchor system no longer
-- exists, private auras render as normal secret debuffs through the containers
local function CreateAuraFilterSection(panel, profile, buffDb, debuffDb, showBuffs, showDebuffs, dependence)
    if GW.Retail then
        panel:AddOptionNote(L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."]
            .. "\n" .. L["Clicking an entry cycles through three states: off (ignored) - check (only auras with this property are shown) - red cross (auras with this property are hidden)."]
            .. "\n" .. L["Important and dispellable debuffs always render through their own scaled groups, no matter what is selected here."], {
            isVisible = function() return GW.settings.RAID_FRAMES == true and GW.settings[dependence] == true and (GW.settings[showBuffs] == true or GW.settings[showDebuffs] == true) end,
            group = "gridAuraFilterNote",
        })
    end

    panel:AddGroupHeader(L["Buffs"])

    panel:AddOption(SHOW_BUFFS, nil, {getterSetter = showBuffs, callback = function() GW.UpdateGridSettings(profile) end, dependence = {["RAID_FRAMES"] = true, [dependence] = true}, groupHeaderName = L["Buffs"]})
    panel:AddOptionDropdown(L["Buffs"], L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."], {getterSetter = buffDb, callback = function() GW.UpdateGridSettings(profile) end, optionsList = auraOptions, optionNames = auraOptionsNames, checkbox = true, triState = true, dependence = {["RAID_FRAMES"] = true, [dependence] = true, [showBuffs] = true}, groupHeaderName = L["Buffs"], hidden = not GW.Retail})

    panel:AddGroupHeader(L["Debuffs"])
    panel:AddOption(SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, {getterSetter = showDebuffs, callback = function() GW.UpdateGridSettings(profile) end, dependence = {["RAID_FRAMES"] = true, [dependence] = true}, groupHeaderName = L["Debuffs"]})
    panel:AddOptionDropdown(L["Debuffs"], L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."], {getterSetter = debuffDb, callback = function() GW.UpdateGridSettings(profile) end, optionsList = auraOptions, optionNames = auraOptionsNames, checkbox = true, triState = true, dependence = {["RAID_FRAMES"] = true, [dependence] = true, [showDebuffs] = true}, groupHeaderName = L["Debuffs"], hidden = not GW.Retail})
end

-- per grid ignore list (all game versions: retail containers exclude the spell ids,
-- the classic engine checks them in its aura filter). Own function: it is called
-- AFTER the classic only debuff options of each grid page, since the panel layout
-- follows the creation order
local function CreateIgnoredAuraSection(panel, profile, ignoredSetting, dependence)
    panel:AddGroupHeader(L["Ignored Auras"])
    panel:AddOptionSpellList(L["Ignored Auras"], L["A list of auras that should never be shown."], {getterSetter = ignoredSetting, callback = function() GW.UpdateGridSettings(profile) end, dependence = {["RAID_FRAMES"] = true, [dependence] = true}, groupHeaderName = L["Ignored Auras"]})
end

local function CreateClassSortebalList(panel, setting, dependence)
    panel:AddOptionSortableList(L["Class Order"], L["Set the order of classes."], {
        getterSetter = setting,
        callback = nil,
        optionsList = classOrderValues,
        optionNames = classOrderNames,
        maxVisibleRows = 6,
        dependence = {[dependence] = {"CLASS"}}
    })
end

local function UpdateGridSettingsAndRefreshPreview(profile, onlyHeaderUpdate, updateHeaderAndFrames)
    if IsGridPreviewActive(profile) then
        GW.UpdateGridSettings(profile, true)
        if GW.RefreshGridConfigurationMode then
            GW.RefreshGridConfigurationMode(profile, true)
        end
        return
    end

    GW.UpdateGridSettings(profile, onlyHeaderUpdate, updateHeaderAndFrames)
end

-- Profiles
local function LoadRaid10Profile(panel)
    local raid10 = CreateFrame("Frame", nil, panel, "GwSettingsPanelPreviewTmpl")
    raid10.panelId = "raid10"
    raid10.header:SetFont(DAMAGE_TEXT_FONT, 20)
    raid10.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    raid10.header:SetText(L["Group Frames"])
    raid10.sub:SetFont(UNIT_NAME_FONT, 12)
    raid10.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    raid10.sub:SetText(L["Edit size, layout and aura display for this grid."])

    raid10.header:SetWidth(raid10.header:GetStringWidth())
    raid10.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    raid10.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    raid10.breadcrumb:SetText(RAID..": 10")

    raid10.preview:SetWidth(raid10.preview:GetFontString():GetStringWidth() + 5)
    raid10.preview:SetScript("OnClick", GridPreviewOnClick("RAID10"))
    raid10.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    raid10.preview:SetScript("OnLeave", GameTooltip_Hide)
    raid10.preview:SetEnabled(GW.settings.RAID10_ENABLED)

    raid10:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.RAID_FRAMES ~= true end,
        group = "gridPageNote",
    })
    raid10:AddOption(ENABLE, L["Display a separate raid grid for groups from 1 to 10 players"], {getterSetter = "RAID10_ENABLED", isMasterToggle = true, callback = function(value) raid10.preview:SetEnabled(value) GW.UpdateGridSettings("RAID10", nil, true) GW.UpdateGridSettings("RAID25", nil, true) GW.UpdateGridSettings("RAID40", nil, true) end, dependence = {["RAID_FRAMES"] = true}})
    raid10:AddOption(RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "RAID_CLASS_COLOR_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, group = "gridClass"})
    raid10:AddOption(L["Hide class icon"], nil, {getterSetter = "RAID_HIDE_CLASS_ICON_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true, ["RAID_CLASS_COLOR_RAID10"] = false}, group = "gridClass"})

    raid10:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, group = "gridIcons"})
    raid10:AddOption(L["Role Icon"], nil, {getterSetter = "RAID_SHOW_ROLE_ICON_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, group = "gridIcons"})
    raid10:AddOption(L["Tank Icon"], nil, {getterSetter = "RAID_SHOW_TANK_ICON_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, group = "gridIcons"})
    raid10:AddOption(L["Leader/Assist Icon"], nil, {getterSetter = "RAID_SHOW_LEADER_ICON_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, group = "gridIcons"})

    raid10:AddOption(L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, hidden = not GW.Retail, group = "gridBars"})
    raid10:AddOption(L["Show absorb bar"], nil, {getterSetter = "RAID_SHOW_ABSORB_BAR_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    raid10:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "RAID_UNIT_HEALTH_RAID10",
        callback = function() GW.UpdateGridSettings("RAID10") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true},
        group = "gridBars"
    })
    raid10:AddOptionDropdown(DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "raid10_show_powerbar", callback = function() GW.UpdateGridSettings("RAID10") end, optionsList = {"ALL", "HEALER", "NONE"}, optionNames = {ALL, HEALER, NONE}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, group = "gridBars"})
    raid10:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "raid10_FrameHealthBarTexture", callback = function() GW.UpdateGridSettings("RAID10") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, group = "gridBars"})

    raid10:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, group = "gridMisc"})
    raid10:AddOptionDropdown(L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "RAID_UNIT_FLAGS_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, hidden = not GW.Retail, group = "gridMisc"})

    raid10:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "UNITFRAME_ANCHOR_FROM_CENTER_RAID10", callback = function() GW.UpdateGridSettings("RAID10", true) end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(raid10, "RAID10", "RAID_10_BUFF_FILTER", "RAID_10_DEBUFF_FILTER", "RAID_10_SHOW_BUFFS", "RAID_SHOW_DEBUFFS_RAID10", "RAID10_ENABLED")
    -- none retail debuff filter
    raid10:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true, ["RAID_SHOW_DEBUFFS_RAID10"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid10:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_RAID10", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid10:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "RAID_10_PANDEMIC_HIGHLIGHT", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID10_ENABLED"] = true}, hidden = not GW.Retail})
    raid10:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "RAID_10_DISPEL_ICON", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID10_ENABLED"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(raid10, "RAID10", "RAID_10_IGNORED_AURAS", "RAID10_ENABLED")


    --fader
    raid10:AddGroupHeader(L["Fader"])
    raid10:AddOption(L["Range"], nil, {getterSetter = "grid10FrameFaderRange", callback = function() GW.UpdateGridSettings("RAID10") end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}, groupHeaderName = L["Fader"]})
    raid10:AddOptionDropdown(L["Fader"], nil, { getterSetter = "grid10FrameFader", callback = function() GW.UpdateGridSettings("RAID10") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true, ["grid10FrameFaderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]})

    raid10:AddOptionSlider(L["Smooth"], nil, { getterSetter = "grid10FrameFader.smooth", callback = function() UpdateGridSettingsThrottled("RAID10") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    raid10:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "grid10FrameFader.minAlpha", callback = function() UpdateGridSettingsThrottled("RAID10") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    raid10:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "grid10FrameFader.maxAlpha", callback = function() UpdateGridSettingsThrottled("RAID10") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})

    -- Size and Positions
    raid10:AddGroupHeader( L["Size and Positions"])
    raid10:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW_RAID10", callback = function() GW.UpdateGridSettings("RAID10", true) end, optionsList = grow, optionNames = MapTable(
            grow,
            function(dir)
                local g1, g2 = strsplit("+", dir)
                return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
            end
       ), dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})

    raid10:AddOptionSlider(L["Groups Per Row/Column"], nil, { getterSetter = "RAID_GROUPS_PER_COLUMN_RAID10", callback = function() UpdateGridSettingsThrottled("RAID10", true) end, min = 1, max = 2, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    raid10:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH_RAID10", callback = function() UpdateGridSettingsThrottled("RAID10", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    raid10:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT_RAID10", callback = function() UpdateGridSettingsThrottled("RAID10", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    raid10:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING_RAID10", callback = function() UpdateGridSettingsThrottled("RAID10", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    raid10:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING_RAID10", callback = function() UpdateGridSettingsThrottled("RAID10", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    raid10:AddOptionSlider(L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "RAID_UNITS_GROUP_SPACING_RAID10", callback = function() UpdateGridSettingsThrottled("RAID10", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})

    -- Sorting
    raid10:AddGroupHeader(L["Grouping & Sorting"])
    raid10:AddOption(L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "RAID_WIDE_SORTING_RAID10", callback = function() UpdateGridSettingsAndRefreshPreview("RAID10", false, true) end, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    raid10:AddOptionDropdown(L["Group By"], L["Set the order that the group will sort."], { getterSetter = "RAID_GROUP_BY_RAID10", callback = function() UpdateGridSettingsAndRefreshPreview("RAID10", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    raid10:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "RAID_SORT_DIRECTION_RAID10", callback = function() UpdateGridSettingsAndRefreshPreview("RAID10", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true}})
    raid10:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "RAID_RAID_SORT_METHOD_RAID10", callback = function() UpdateGridSettingsAndRefreshPreview("RAID10", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["RAID_FRAMES"] = true, ["RAID10_ENABLED"] = true, ["RAID_GROUP_BY_RAID10"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})

    CreateClassSortebalList(raid10, "Raid10GroupByClassOrder", "RAID_GROUP_BY_RAID10")
    return raid10
end

local function LoadRaid25Profile(panel)
    local raid25 = CreateFrame("Frame", nil, panel, "GwSettingsPanelPreviewTmpl")
    raid25.panelId = "raid25"
    raid25.header:SetFont(DAMAGE_TEXT_FONT, 20)
    raid25.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    raid25.header:SetText(L["Group Frames"])
    raid25.sub:SetFont(UNIT_NAME_FONT, 12)
    raid25.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    raid25.sub:SetText(L["Edit size, layout and aura display for this grid."])

    raid25.header:SetWidth(raid25.header:GetStringWidth())
    raid25.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    raid25.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    raid25.breadcrumb:SetText(RAID..": 25")

    raid25.preview:SetWidth(raid25.preview:GetFontString():GetStringWidth() + 5)
    raid25.preview:SetScript("OnClick", GridPreviewOnClick("RAID25"))
    raid25.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    raid25.preview:SetScript("OnLeave", GameTooltip_Hide)
    raid25.preview:SetEnabled(GW.settings.RAID25_ENABLED)

    raid25:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.RAID_FRAMES ~= true end,
        group = "gridPageNote",
    })
    raid25:AddOption(ENABLE, L["Display a separate raid grid for groups from 11 to 25 players"], {getterSetter = "RAID25_ENABLED", isMasterToggle = true, callback = function(value) raid25.preview:SetEnabled(value); GW.UpdateGridSettings("RAID10", nil, true); GW.UpdateGridSettings("RAID25", nil, true); GW.UpdateGridSettings("RAID40", nil, true) end, dependence = {["RAID_FRAMES"] = true}})
    raid25:AddOption(RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "RAID_CLASS_COLOR_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, group = "gridClass"})
    raid25:AddOption(L["Hide class icon"], nil, {getterSetter = "RAID_HIDE_CLASS_ICON_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true, ["RAID_CLASS_COLOR_RAID25"] = false}, group = "gridClass"})

    raid25:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, group = "gridIcons"})
    raid25:AddOption(L["Role Icon"], nil, {getterSetter = "RAID_SHOW_ROLE_ICON_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, group = "gridIcons"})
    raid25:AddOption(L["Tank Icon"], nil, {getterSetter = "RAID_SHOW_TANK_ICON_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, group = "gridIcons"})
    raid25:AddOption(L["Leader/Assist Icon"], nil, {getterSetter = "RAID_SHOW_LEADER_ICON_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, group = "gridIcons"})

    raid25:AddOption(L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, hidden = not GW.Retail, group = "gridBars"})
    raid25:AddOption(L["Show absorb bar"] , nil, {getterSetter = "RAID_SHOW_ABSORB_BAR_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    raid25:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "RAID_UNIT_HEALTH_RAID25",
        callback = function() GW.UpdateGridSettings("RAID25") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true},
        group = "gridBars"
    })
    raid25:AddOptionDropdown(DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "raid25_show_powerbar", callback = function() GW.UpdateGridSettings("RAID25") end, optionsList = {"ALL", "HEALER", "NONE"}, optionNames = {ALL, HEALER, NONE}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, group = "gridBars"})
    raid25:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "raid25_FrameHealthBarTexture", callback = function() GW.UpdateGridSettings("RAID25") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, group = "gridBars"})

    raid25:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, group = "gridMisc"})
    raid25:AddOptionDropdown(L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "RAID_UNIT_FLAGS_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, hidden = not GW.Retail, group = "gridMisc"})

    raid25:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "UNITFRAME_ANCHOR_FROM_CENTER_RAID25", callback = function() GW.UpdateGridSettings("RAID25", true) end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(raid25, "RAID25", "RAID_25_BUFF_FILTER", "RAID_25_DEBUFF_FILTER", "RAID_25_SHOW_BUFFS", "RAID_SHOW_DEBUFFS_RAID25", "RAID25_ENABLED")
    -- none retail debuff filter
    raid25:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true, ["RAID_SHOW_DEBUFFS_RAID25"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid25:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_RAID25", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid25:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "RAID_25_PANDEMIC_HIGHLIGHT", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID25_ENABLED"] = true}, hidden = not GW.Retail})
    raid25:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "RAID_25_DISPEL_ICON", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID25_ENABLED"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(raid25, "RAID25", "RAID_25_IGNORED_AURAS", "RAID25_ENABLED")


    --fader
    raid25:AddGroupHeader(L["Fader"])
    raid25:AddOption(L["Range"], nil, {getterSetter = "grid25FrameFaderRange", callback = function() GW.UpdateGridSettings("RAID25") end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}, groupHeaderName = L["Fader"]})

    raid25:AddOptionDropdown(L["Fader"], nil, { getterSetter = "grid25FrameFader", callback = function() GW.UpdateGridSettings("RAID25") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true, ["grid25FrameFaderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]})
    raid25:AddOptionSlider(L["Smooth"], nil, { getterSetter = "grid25FrameFader.smooth", callback = function() UpdateGridSettingsThrottled("RAID25") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    raid25:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "grid25FrameFader.minAlpha", callback = function() UpdateGridSettingsThrottled("RAID25") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    raid25:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "grid25FrameFader.maxAlpha", callback = function() UpdateGridSettingsThrottled("RAID25") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})

    -- Size and Positions
    raid25:AddGroupHeader( L["Size and Positions"])
    raid25:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW_RAID25", callback = function() GW.UpdateGridSettings("RAID25", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})

    raid25:AddOptionSlider(L["Groups Per Row/Column"], nil, { getterSetter = "RAID_GROUPS_PER_COLUMN_RAID25", callback = function() UpdateGridSettingsThrottled("RAID25", true) end, min = 1, max = 5, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    raid25:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH_RAID25", callback = function() UpdateGridSettingsThrottled("RAID25", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    raid25:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT_RAID25", callback = function() UpdateGridSettingsThrottled("RAID25", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    raid25:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING_RAID25", callback = function() UpdateGridSettingsThrottled("RAID25", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    raid25:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING_RAID25", callback = function() UpdateGridSettingsThrottled("RAID25", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    raid25:AddOptionSlider(L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "RAID_UNITS_GROUP_SPACING_RAID25", callback = function() UpdateGridSettingsThrottled("RAID25", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})

    -- Sorting
    raid25:AddGroupHeader(L["Grouping & Sorting"])
    raid25:AddOption(L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "RAID_WIDE_SORTING_RAID25", callback = function() UpdateGridSettingsAndRefreshPreview("RAID25", false, true) end, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    raid25:AddOptionDropdown(L["Group By"], L["Set the order that the group will sort."], { getterSetter = "RAID_GROUP_BY_RAID25", callback = function() UpdateGridSettingsAndRefreshPreview("RAID25", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    raid25:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "RAID_SORT_DIRECTION_RAID25", callback = function() UpdateGridSettingsAndRefreshPreview("RAID25", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true}})
    raid25:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "RAID_RAID_SORT_METHOD_RAID25", callback = function() UpdateGridSettingsAndRefreshPreview("RAID25", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["RAID_FRAMES"] = true, ["RAID25_ENABLED"] = true, ["RAID_GROUP_BY_RAID25"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})

    CreateClassSortebalList(raid25, "Raid25GroupByClassOrder", "RAID_GROUP_BY_RAID25")
    return raid25
end

local function LoadRaid40Profile(panel)
    local raid40 = CreateFrame("Frame", nil, panel, "GwSettingsPanelPreviewTmpl")
    raid40.panelId = "raid40"
    raid40.header:SetFont(DAMAGE_TEXT_FONT, 20)
    raid40.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    raid40.header:SetText(L["Group Frames"])
    raid40.sub:SetFont(UNIT_NAME_FONT, 12)
    raid40.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    raid40.sub:SetText(L["Edit size, layout and aura display for this grid."])

    raid40.header:SetWidth(raid40.header:GetStringWidth())
    raid40.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    raid40.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    raid40.breadcrumb:SetText(RAID..": 40")

    raid40.preview:SetWidth(raid40.preview:GetFontString():GetStringWidth() + 5)
    raid40.preview:SetScript("OnClick", GridPreviewOnClick("RAID40"))
    raid40.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    raid40.preview:SetScript("OnLeave", GameTooltip_Hide)
    raid40.preview:SetEnabled(GW.settings.RAID_FRAMES and GW.settings.RAID40_ENABLED)

    raid40:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.RAID_FRAMES ~= true end,
        group = "gridPageNote",
    })
    raid40:AddOption(ENABLE, L["Display a separate raid grid for groups from 26 to 40 players"], {getterSetter = "RAID40_ENABLED", isMasterToggle = true, callback = function(value) raid40.preview:SetEnabled(value and GW.settings.RAID_FRAMES); GW.UpdateGridSettings("RAID40", nil, true) end, dependence = {["RAID_FRAMES"] = true}})
    raid40:AddOption(RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "RAID_CLASS_COLOR", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, group = "gridClass"})
    raid40:AddOption(L["Hide class icon"], nil, {getterSetter = "RAID_HIDE_CLASS_ICON", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true, ["RAID_CLASS_COLOR"] = false}, group = "gridClass"})

    raid40:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, group = "gridIcons"})
    raid40:AddOption(L["Role Icon"], nil, {getterSetter = "RAID_SHOW_ROLE_ICON", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, group = "gridIcons"})
    raid40:AddOption(L["Tank Icon"], nil, {getterSetter = "RAID_SHOW_TANK_ICON", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, group = "gridIcons"})
    raid40:AddOption(L["Leader/Assist Icon"], nil, {getterSetter = "RAID_SHOW_LEADER_ICON", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, group = "gridIcons"})

    raid40:AddOption(L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, hidden = not GW.Retail, group = "gridBars"})
    raid40:AddOption(L["Show absorb bar"], nil, {getterSetter = "RAID_SHOW_ABSORB_BAR", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    raid40:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, { getterSetter = "RAID_UNIT_HEALTH", callback = function() GW.UpdateGridSettings("RAID40") end, optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"}, optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, group = "gridBars"})
    raid40:AddOptionDropdown(DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "raid40_show_powerbar", callback = function() GW.UpdateGridSettings("RAID40") end, optionsList = {"ALL", "HEALER", "NONE"}, optionNames = {ALL, HEALER, NONE}, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, group = "gridBars"})
    raid40:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "raid40_FrameHealthBarTexture", callback = function() GW.UpdateGridSettings("RAID40") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, group = "gridBars"})

    raid40:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT", callback = function() GW.UpdateGridSettings("RAID40") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, group = "gridMisc"})
    raid40:AddOptionDropdown(L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "RAID_UNIT_FLAGS", callback = function() GW.UpdateGridSettings("RAID40") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, hidden = not GW.Retail, group = "gridMisc"})

    raid40:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "UNITFRAME_ANCHOR_FROM_CENTER", callback = function() GW.UpdateGridSettings("RAID40", true) end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(raid40, "RAID40", "RAID_BUFF_FILTER", "RAID_DEBUFF_FILTER", "RAID_SHOW_BUFFS", "RAID_SHOW_DEBUFFS", "RAID40_ENABLED")
    -- none retail debuff filter
    raid40:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true, ["RAID_SHOW_DEBUFFS"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid40:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid40:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "RAID_PANDEMIC_HIGHLIGHT", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, hidden = not GW.Retail})
    raid40:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "RAID_DISPEL_ICON", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(raid40, "RAID40", "RAID_IGNORED_AURAS", "RAID40_ENABLED")


    --fader
    raid40:AddGroupHeader(L["Fader"])
    raid40:AddOption(L["Range"], nil, {getterSetter = "grid40FrameFaderRange", callback = function() GW.UpdateGridSettings("RAID40") end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}, groupHeaderName = L["Fader"]})
    raid40:AddOptionDropdown(L["Fader"], nil, { getterSetter = "grid40FrameFader", callback = function() GW.UpdateGridSettings("RAID40") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true, ["grid40FrameFaderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]})
    raid40:AddOptionSlider(L["Smooth"], nil, { getterSetter = "grid40FrameFader.smooth", callback = function() UpdateGridSettingsThrottled("RAID40") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true}})
    raid40:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "grid40FrameFader.minAlpha", callback = function() UpdateGridSettingsThrottled("RAID40") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true}})
    raid40:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "grid40FrameFader.maxAlpha", callback = function() UpdateGridSettingsThrottled("RAID40") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true}})

    -- Size and Positions
    raid40:AddGroupHeader(L["Size and Positions"])
    raid40:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW", callback = function() GW.UpdateGridSettings("RAID40", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}})

    raid40:AddOptionSlider(L["Groups Per Row/Column"], nil, { getterSetter = "RAID_GROUPS_PER_COLUMN", callback = function() UpdateGridSettingsThrottled("RAID40", true) end, min = 1, max = 8, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}})
    raid40:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH", callback = function() UpdateGridSettingsThrottled("RAID40", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}})
    raid40:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT", callback = function() UpdateGridSettingsThrottled("RAID40", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}})
    raid40:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING", callback = function() UpdateGridSettingsThrottled("RAID40", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}})
    raid40:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING", callback = function() UpdateGridSettingsThrottled("RAID40", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}})
    raid40:AddOptionSlider(L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "RAID_UNITS_GROUP_SPACING", callback = function() UpdateGridSettingsThrottled("RAID40", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence ={["RAID_FRAMES"] = true}})

    -- Sorting
    raid40:AddGroupHeader(L["Grouping & Sorting"])
    raid40:AddOption(L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "RAID_WIDE_SORTING", callback = function() UpdateGridSettingsAndRefreshPreview("RAID40", false, true) end, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}})
    raid40:AddOptionDropdown(L["Group By"], L["Set the order that the group will sort."], { getterSetter = "RAID_GROUP_BY", callback = function() UpdateGridSettingsAndRefreshPreview("RAID40", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}})
    raid40:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "RAID_SORT_DIRECTION", callback = function() UpdateGridSettingsAndRefreshPreview("RAID40", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true}})
    raid40:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "T", callback = function() UpdateGridSettingsAndRefreshPreview("RAID40", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["RAID_FRAMES"] = true, ["RAID40_ENABLED"] = true, ["RAID_GROUP_BY"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})
    CreateClassSortebalList(raid40, "Raid40GroupByClassOrder", "RAID_GROUP_BY")
    return raid40
end

local function LoadMaintankProfile(panel)
    local tank = CreateFrame("Frame", nil, panel, "GwSettingsPanelPreviewTmpl")
    tank.panelId = "raid_maintank"
    tank.header:SetFont(DAMAGE_TEXT_FONT, 20)
    tank.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    tank.header:SetText(L["Group Frames"])
    tank.sub:SetFont(UNIT_NAME_FONT, 12)
    tank.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    tank.sub:SetText(L["Edit size, layout and aura display for this grid."])

    tank.header:SetWidth(tank.header:GetStringWidth())
    tank.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    tank.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    tank.breadcrumb:SetText(MAINTANK)

    tank.preview:SetWidth(tank.preview:GetFontString():GetStringWidth() + 5)
    tank.preview:SetScript("OnClick", GridPreviewOnClick("TANK"))
    tank.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    tank.preview:SetScript("OnLeave", GameTooltip_Hide)
    tank.preview:SetEnabled(GW.settings.RAID_MAINTANK_FRAMES_ENABLED)

    tank:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.RAID_FRAMES ~= true end,
        group = "gridPageNote",
    })
    tank:AddOption(ENABLE, L["Enable Maintank grid"], {getterSetter = "RAID_MAINTANK_FRAMES_ENABLED", isMasterToggle = true, callback = function(value) tank.preview:SetEnabled(value); GW.UpdateGridSettings("TANK", nil, true) end, dependence = {["RAID_FRAMES"] = true}})
    tank:AddOption(RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "RAID_CLASS_COLOR_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, group = "gridClass"})
    tank:AddOption(L["Hide class icon"], nil, {getterSetter = "RAID_HIDE_CLASS_ICON_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true, ["RAID_CLASS_COLOR_TANK"] = false}, group = "gridClass"})

    tank:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, group = "gridIcons"})
    tank:AddOption(L["Role Icon"], nil, {getterSetter = "RAID_SHOW_ROLE_ICON_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, group = "gridIcons"})
    tank:AddOption(L["Tank Icon"], nil, {getterSetter = "RAID_SHOW_TANK_ICON_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, group = "gridIcons"})
    tank:AddOption(L["Leader/Assist Icon"], nil, {getterSetter = "RAID_SHOW_LEADER_ICON_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, group = "gridIcons"})

    tank:AddOption(L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, hidden = not GW.Retail, group = "gridBars"})
    tank:AddOption(L["Show absorb bar"], nil, {getterSetter = "RAID_SHOW_ABSORB_BAR_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    tank:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "RAID_UNIT_HEALTH_TANK",
        callback = function() GW.UpdateGridSettings("TANK") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true},
        group = "gridBars"
    })
    tank:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "maintank_FrameHealthBarTexture", callback = function() GW.UpdateGridSettings("TANK") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, group = "gridBars"})

    tank:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT_TANK", callback = function() GW.UpdateGridSettings("TANK") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, group = "gridMisc"})
    tank:AddOptionDropdown(L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "RAID_UNIT_FLAGS_TANK", callback = function() GW.UpdateGridSettings("TANK") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, hidden = not GW.Retail, group = "gridMisc"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(tank, "TANK", "RAID_MAINTANK_BUFF_FILTER", "RAID_MAINTANK_DEBUFF_FILTER", "RAID_SHOW_BUFFS_TANK", "RAID_SHOW_DEBUFFS_TANK", "RAID_MAINTANK_FRAMES_ENABLED")
    -- none retail debuff filter
    tank:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true, ["RAID_SHOW_DEBUFFS_TANK"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    tank:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_TANK", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    tank:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "RAID_MAINTANK_PANDEMIC_HIGHLIGHT", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_MAINTANK_FRAMES_ENABLED"] = true}, hidden = not GW.Retail})
    tank:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "RAID_MAINTANK_DISPEL_ICON", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_MAINTANK_FRAMES_ENABLED"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(tank, "TANK", "RAID_MAINTANK_IGNORED_AURAS", "RAID_MAINTANK_FRAMES_ENABLED")


    --fader
    tank:AddGroupHeader(L["Fader"])
    tank:AddOption(L["Range"], nil, {getterSetter = "gridTankFrameFaderRange", callback = function() GW.UpdateGridSettings("TANK") end, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}, groupHeaderName = L["Fader"]})
    tank:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "gridTankFrameFader",
        callback = function() GW.UpdateGridSettings("TANK") end,
        optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"},
        optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]},
        dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true, ["gridTankFrameFaderRange"] = false},
        checkbox = true,
        groupHeaderName = L["Fader"]
    })
    tank:AddOptionSlider(L["Smooth"], nil, { getterSetter = "gridTankFrameFader.smooth", callback = function() UpdateGridSettingsThrottled("TANK") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    tank:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "gridTankFrameFader.minAlpha", callback = function() UpdateGridSettingsThrottled("TANK") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    tank:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "gridTankFrameFader.maxAlpha", callback = function() UpdateGridSettingsThrottled("TANK") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})

    -- Size and Positions
    tank:AddGroupHeader( L["Size and Positions"])
    tank:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW_TANK", callback = function() GW.UpdateGridSettings("TANK", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})

    tank:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH_TANK", callback = function() UpdateGridSettingsThrottled("TANK", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    tank:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT_TANK", callback = function() UpdateGridSettingsThrottled("TANK", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    tank:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING_TANK", callback = function() UpdateGridSettingsThrottled("TANK", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})
    tank:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING_TANK", callback = function() UpdateGridSettingsThrottled("TANK", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_MAINTANK_FRAMES_ENABLED"] = true}})

    return tank
end

local function LoadRaidPetProfile(panel)
    local p = CreateFrame("Frame", nil, panel, "GwSettingsPanelPreviewTmpl")
    p.panelId = "raid_pet"
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.header:SetText(L["Group Frames"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit size, layout and aura display for this grid."])

    p.header:SetWidth(p.header:GetStringWidth())
    p.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.breadcrumb:SetText(PET)

    p.preview:SetWidth(p.preview:GetFontString():GetStringWidth() + 5)
    p.preview:SetScript("OnClick", GridPreviewOnClick("RAID_PET"))
    p.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.preview:SetScript("OnLeave", GameTooltip_Hide)
    p.preview:SetEnabled(GW.settings.RAID_PET_FRAMES)

    p:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.RAID_FRAMES ~= true end,
        group = "gridPageNote",
    })
    p:AddOption(ENABLE, L["Show a separate grid for raid pets"], {getterSetter = "RAID_PET_FRAMES", isMasterToggle = true, callback = function(value) p.preview:SetEnabled(value); GW.UpdateGridSettings("RAID_PET", nil, true) end, dependence = {["RAID_FRAMES"] = true}})
    p:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}, group = "gridIcons"})

    p:AddOption(L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}, hidden = not GW.Retail, group = "gridBars"})
    p:AddOption(L["Show absorb bar"], nil, {getterSetter = "RAID_SHOW_ABSORB_BAR_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    p:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "RAID_UNIT_HEALTH_PET",
        callback = function() GW.UpdateGridSettings("RAID_PET") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true},
        group = "gridBars"
    })
    p:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "pet_FrameHealthBarTexture", callback = function() GW.UpdateGridSettings("RAID_PET") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}, group = "gridBars"})

    p:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}, group = "gridMisc"})

    p:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "UNITFRAME_ANCHOR_FROM_CENTER_PET", callback = function() GW.UpdateGridSettings("RAID_PET", true) end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(p, "RAID_PET", "RAID_PET_BUFF_FILTER", "RAID_PET_DEBUFF_FILTER", "RAID_PET_SHOW_BUFFS", "RAID_SHOW_DEBUFFS_PET", "RAID_PET_FRAMES")
    -- none retail debuff filter
    p:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true, ["RAID_SHOW_DEBUFFS_PET"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    p:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PET", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    p:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "RAID_PET_PANDEMIC_HIGHLIGHT", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_PET_FRAMES"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "RAID_PET_DISPEL_ICON", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_PET_FRAMES"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(p, "RAID_PET", "RAID_PET_IGNORED_AURAS", "RAID_PET_FRAMES")

    --fader
    p:AddGroupHeader(L["Fader"])
    p:AddOption(L["Range"], nil, {getterSetter = "gridPetFrameFaderRange", callback = function() GW.UpdateGridSettings("RAID_PET") end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}, groupHeaderName = L["Fader"]})
    p:AddOptionDropdown(L["Fader"], nil, { getterSetter = "gridPetFrameFader", callback = function() GW.UpdateGridSettings("RAID_PET") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true, ["gridPetFrameFaderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]})
    p:AddOptionSlider(L["Smooth"], nil, { getterSetter = "gridPetFrameFader.smooth", callback = function() UpdateGridSettingsThrottled("RAID_PET") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    p:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "gridPetFrameFader.minAlpha", callback = function() UpdateGridSettingsThrottled("RAID_PET") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    p:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "gridPetFrameFader.maxAlpha", callback = function() UpdateGridSettingsThrottled("RAID_PET") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})

    -- Size and Positions
    p:AddGroupHeader( L["Size and Positions"])
    p:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW_PET", callback = function() GW.UpdateGridSettings("RAID_PET", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})

    p:AddOptionSlider(L["Groups Per Row/Column"], nil, { getterSetter = "RAID_GROUPS_PER_COLUMN_PET", callback = function() UpdateGridSettingsThrottled("RAID_PET", true) end, min = 1, max = 8, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    p:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH_PET", callback = function() UpdateGridSettingsThrottled("RAID_PET", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    p:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT_PET", callback = function() UpdateGridSettingsThrottled("RAID_PET", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    p:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING_PET", callback = function() UpdateGridSettingsThrottled("RAID_PET", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    p:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING_PET", callback = function() UpdateGridSettingsThrottled("RAID_PET", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    p:AddOptionSlider(L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "RAID_UNITS_GROUP_SPACING_PET", callback = function() UpdateGridSettingsThrottled("RAID_PET", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})

    -- Sorting
    p:AddGroupHeader(L["Grouping & Sorting"])
    p:AddOption(L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "RAID_WIDE_SORTING_PET", callback = function() UpdateGridSettingsAndRefreshPreview("RAID_PET", false, true) end, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    p:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "RAID_SORT_DIRECTION_PET", callback = function() UpdateGridSettingsAndRefreshPreview("RAID_PET", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})
    p:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "RAID_RAID_SORT_METHOD_PET", callback = function() UpdateGridSettingsAndRefreshPreview("RAID_PET", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["RAID_FRAMES"] = true, ["RAID_PET_FRAMES"] = true}})

    return p
end
local function LoadPartyProfile(panel)
    local party = CreateFrame("Frame", "GwSettingsRaidPartyPanel", panel, "GwSettingsPanelPreviewTmpl")
    party.panelId = "raid_party"
    party.header:SetFont(DAMAGE_TEXT_FONT, 20)
    party.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    party.header:SetText(L["Group Frames"])
    party.sub:SetFont(UNIT_NAME_FONT, 12)
    party.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    party.sub:SetText(L["Edit size, layout and aura display for this grid."])

    party.header:SetWidth(party.header:GetStringWidth())
    party.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    party.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    -- "Party Grid", not just "Party": the stylised party frames have their own page under
    -- Unitframes and users kept mixing the two up while both were labelled "Party"
    party.breadcrumb:SetText(L["Party Grid"])

    party.preview:SetWidth(party.preview:GetFontString():GetStringWidth() + 5)
    party.preview:SetScript("OnClick", GridPreviewOnClick("PARTY"))
    party.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    party.preview:SetScript("OnLeave", GameTooltip_Hide)
    -- the grid is displayed both when it replaces the party frames and in "show both" mode,
    -- so the preview has to follow the same condition as the settings on this page
    local function IsPartyGridActive()
        return GW.settings.RAID_STYLE_PARTY == true or GW.settings.RAID_STYLE_PARTY_AND_FRAMES == true
    end
    party.preview:SetEnabled(IsPartyGridActive())
    -- the "show both" toggle lives on the party frame page and has to reach the button here
    GW.UpdatePartyGridPreviewState = function() party.preview:SetEnabled(IsPartyGridActive()) end

    -- the whole page depends on {RAID_FRAMES = true, PARTY_GRID_ACTIVE = true}; these two notes
    -- name whichever of the two conditions is currently failing. RAID_FRAMES lives on the
    -- "Raid: 40" page, so without this the reason is invisible from here.
    party:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.RAID_FRAMES ~= true end,
        group = "partyPageNote",
    })
    party:AddOptionNote(format(L["This grid is not in use: the stylised party frames are shown instead. Enable '%s' below to replace them with this grid."], USE_RAID_STYLE_PARTY_FRAMES), {
        isVisible = function() return GW.settings.RAID_FRAMES == true and not IsPartyGridActive() end,
        group = "partyPageNote",
    })
    party:AddOption(USE_RAID_STYLE_PARTY_FRAMES, OPTION_TOOLTIP_USE_RAID_STYLE_PARTY_FRAMES, {getterSetter = "RAID_STYLE_PARTY", callback = function(value) party.preview:SetEnabled(IsPartyGridActive()); GW.UpdateGridSettings("PARTY", false, true); GW.UpdatePlayerInPartySetting(value) end, isMasterToggle = true, dependence = {["RAID_FRAMES"] = true}})
    -- deliberately without a dependence: when this grid is off, every other option on this
    -- page is greyed out and this link is the only thing left that still explains why
    party:AddOptionButton(L["Go to the party frame settings"], L["The stylised party frames and the raid style party grid are two separate displays, each with its own settings page. This opens the other one."], {
        callback = function() GW.GetSettingsTabFrame():OpenSettingsToPanel("party_general") end,
        forceNewLine = true,
        group = "partyPageLink",
    })
    party:AddOption(RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "RAID_CLASS_COLOR_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridClass"})
    party:AddOption(L["Hide class icon"], nil, {getterSetter = "RAID_HIDE_CLASS_ICON_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true, ["RAID_CLASS_COLOR_PARTY"] = false}, group = "gridClass"})

    party:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "RAID_UNIT_MARKERS_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridIcons"})
    party:AddOption(L["Role Icon"], nil, {getterSetter = "RAID_SHOW_ROLE_ICON_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridIcons"})
    party:AddOption(L["Tank Icon"], nil, {getterSetter = "RAID_SHOW_TANK_ICON_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridIcons"})
    party:AddOption(L["Leader/Assist Icon"], nil, {getterSetter = "RAID_SHOW_LEADER_ICON_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridIcons"})

    party:AddOption(L["Shorten health values"], nil, {getterSetter = "RAID_SHORT_HEALTH_VALUES_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, hidden = not GW.Retail, group = "gridBars"})
    party:AddOption(L["Show absorb bar"], nil, {getterSetter = "RAID_SHOW_ABSORB_BAR_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    party:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "RAID_UNIT_HEALTH_PARTY",
        callback = function() GW.UpdateGridSettings("PARTY") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true},
        group = "gridBars"
    })
    party:AddOptionDropdown(DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "party_grid_show_powerbar", callback = function() GW.UpdateGridSettings("PARTY") end, optionsList = {"ALL", "HEALER", "NONE"}, optionNames = {ALL, HEALER, NONE}, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridBars"})
    party:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "party_grid_FrameHealthBarTexture", callback = function() GW.UpdateGridSettings("PARTY") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridBars"})

    party:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "RAID_AURA_TOOLTIP_INCOMBAT_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridMisc"})
    party:AddOptionDropdown(L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "RAID_UNIT_FLAGS_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, hidden = not GW.Retail, group = "gridMisc"})

    party:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "UNITFRAME_ANCHOR_FROM_CENTER_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridLayout"})
    party:AddOption(L["Player frame in group"], L["Show your player frame as part of the group"], {getterSetter = "RAID_SHOW_PLAYER_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(party, "PARTY", "RAID_PARTY_BUFF_FILTER", "RAID_PARTY_DEBUFF_FILTER", "RAID_PARTY_SHOW_BUFFS", "RAID_SHOW_DEBUFFS_PARTY", "PARTY_GRID_ACTIVE")
    -- none retail debuff filter
    party:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "RAID_ONLY_DISPELL_DEBUFFS_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true, ["RAID_SHOW_DEBUFFS_PARTY"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    party:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PARTY", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    party:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "RAID_PARTY_PANDEMIC_HIGHLIGHT", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["PARTY_GRID_ACTIVE"] = true}, hidden = not GW.Retail})
    party:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "RAID_PARTY_DISPEL_ICON", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["PARTY_GRID_ACTIVE"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(party, "PARTY", "RAID_PARTY_IGNORED_AURAS", "PARTY_GRID_ACTIVE")


    --fader
    party:AddGroupHeader(L["Fader"])
    party:AddOption(L["Range"], nil, {getterSetter = "gridPartyFrameFaderRange", callback = function() GW.UpdateGridSettings("PARTY") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}, groupHeaderName = L["Fader"]})
    party:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "gridPartyFrameFader",
        callback = function() GW.UpdateGridSettings("PARTY") end,
        optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"},
        optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]},
        dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true, ["gridPartyFrameFaderRange"] = false},
        checkbox = true,
        groupHeaderName = L["Fader"]
    })
    party:AddOptionSlider(L["Smooth"], nil, { getterSetter = "gridPartyFrameFader.smooth", callback = function() UpdateGridSettingsThrottled("PARTY") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "gridPartyFrameFader.minAlpha", callback = function() UpdateGridSettingsThrottled("PARTY") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "gridPartyFrameFader.maxAlpha", callback = function() UpdateGridSettingsThrottled("PARTY") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}})

    -- Size and Positions
    party:AddGroupHeader(L["Size and Positions"])
    party:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "RAID_GROW_PARTY", callback = function() GW.UpdateGridSettings("PARTY", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}})


    party:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "RAID_WIDTH_PARTY", callback = function() UpdateGridSettingsThrottled("PARTY", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "RAID_HEIGHT_PARTY", callback = function() UpdateGridSettingsThrottled("PARTY", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "RAID_UNITS_HORIZONTAL_SPACING_PARTY", callback = function() UpdateGridSettingsThrottled("PARTY", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "RAID_UNITS_VERTICAL_SPACING_PARTY", callback = function() UpdateGridSettingsThrottled("PARTY", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    -- Sorting
    party:AddGroupHeader(L["Grouping & Sorting"])
    party:AddOptionDropdown(L["Group By"], L["Set the order that the group will sort."], { getterSetter = "RAID_GROUP_BY_PARTY", callback = function() UpdateGridSettingsAndRefreshPreview("PARTY", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "RAID_SORT_DIRECTION_PARTY", callback = function() UpdateGridSettingsAndRefreshPreview("PARTY", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "RAID_RAID_SORT_METHOD_PARTY", callback = function() UpdateGridSettingsAndRefreshPreview("PARTY", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["RAID_FRAMES"] = true, ["PARTY_GRID_ACTIVE"] = true, ["RAID_GROUP_BY_PARTY"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})
    CreateClassSortebalList(party, "PartyGroupByClassOrder", "RAID_GROUP_BY_PARTY")
    return party
end

local function LoadPartyPetProfile(panel)
    local p = CreateFrame("Frame", nil, panel, "GwSettingsPanelPreviewTmpl")
    p.panelId = "party_pet"
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.header:SetText(L["Group Frames"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit size, layout and aura display for this grid."])

    p.header:SetWidth(p.header:GetStringWidth())
    p.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.breadcrumb:SetText(L["Party Grid"] .. ": " .. PET)

    p.preview:SetWidth(p.preview:GetFontString():GetStringWidth() + 5)
    p.preview:SetScript("OnClick", GridPreviewOnClick("PARTY_PET"))
    p.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Party Pet Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.preview:SetScript("OnLeave", GameTooltip_Hide)
    p.preview:SetEnabled(GW.settings.PARTY_PET_FRAMES_ENABLED)

    p:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.RAID_FRAMES ~= true end,
        group = "gridPageNote",
    })
    p:AddOption(ENABLE, L["Show a separate grid for party pets"], {getterSetter = "PARTY_PET_FRAMES_ENABLED", isMasterToggle = true, callback = function(value) p.preview:SetEnabled(value); GW.UpdateGridSettings("PARTY_PET", nil, true) end, dependence = {["RAID_FRAMES"] = true}})
    p:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "PARTY_UNIT_MARKERS_PET", callback = function() GW.UpdateGridSettings("PARTY_PET") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridIcons"})

    p:AddOption(L["Shorten health values"], nil, {getterSetter = "PARTY_SHORT_HEALTH_VALUES_PET", callback = function() GW.UpdateGridSettings("PARTY_PET") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true, ["PARTY_GRID_ACTIVE"] = true}, hidden = not GW.Retail, group = "gridBars"})
    p:AddOption(L["Show absorb bar"], nil, {getterSetter = "PARTY_SHOW_ABSORB_BAR_PET", callback = function() GW.UpdateGridSettings("PARTY_PET") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true, ["PARTY_GRID_ACTIVE"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    p:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "PARTY_UNIT_HEALTH_PET",
        callback = function() GW.UpdateGridSettings("PARTY_PET") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true},
        group = "gridBars"
    })
    p:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "party_pet_FrameHealthBarTexture", callback = function() GW.UpdateGridSettings("PARTY_PET") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridBars"})

    p:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "PARTY_AURA_TOOLTIP_INCOMBAT_PET", callback = function() GW.UpdateGridSettings("PARTY_PET") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}, group = "gridMisc"})

    p:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "PARTY_PET_UNITFRAME_ANCHOR_FROM_CENTER", callback = function() GW.UpdateGridSettings("PARTY_PET", true) end, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(p, "PARTY_PET", "PARTY_PET_BUFF_FILTER", "PARTY_PET_DEBUFF_FILTER", "PARTY_PET_SHOW_BUFFS", "PARTY_SHOW_DEBUFFS_PET", "PARTY_PET_FRAMES_ENABLED")
    -- none retail debuff filter
    p:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "PARTY_ONLY_DISPELL_DEBUFFS_PET", callback = function() GW.UpdateGridSettings("PARTY_PET") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true, ["PARTY_SHOW_DEBUFFS_PET"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    p:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PET", callback = function() GW.UpdateGridSettings("PARTY_PET") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    p:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "PARTY_PET_PANDEMIC_HIGHLIGHT", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["PARTY_PET_FRAMES_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "PARTY_PET_DISPEL_ICON", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["PARTY_PET_FRAMES_ENABLED"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(p, "PARTY_PET", "PARTY_PET_IGNORED_AURAS", "PARTY_PET_FRAMES_ENABLED")

    --fader
    p:AddGroupHeader(L["Fader"])
    p:AddOption(L["Range"], nil, {getterSetter = "gridPartyPetFrameFaderRange", callback = function() GW.UpdateGridSettings("PARTY_PET") end, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}, groupHeaderName = L["Fader"]})
    p:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "gridPartyPetFrameFader",
        callback = function() GW.UpdateGridSettings("PARTY_PET") end,
        optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"},
        optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]},
        dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true, ["gridPartyPetFrameFaderRange"] = false},
        checkbox = true,
        groupHeaderName = L["Fader"]
    })
    p:AddOptionSlider(L["Smooth"], nil, { getterSetter = "gridPartyPetFrameFader.smooth", callback = function() UpdateGridSettingsThrottled("PARTY_PET") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "gridPartyPetFrameFader.minAlpha", callback = function() UpdateGridSettingsThrottled("PARTY_PET") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "gridPartyPetFrameFader.maxAlpha", callback = function() UpdateGridSettingsThrottled("PARTY_PET") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}})

    -- Size and Positions
    p:AddGroupHeader( L["Size and Positions"])
    p:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "PARTY_GROW_PET", callback = function() GW.UpdateGridSettings("PARTY_PET", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}})

    p:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "PARTY_WIDTH_PET", callback = function() UpdateGridSettingsThrottled("PARTY_PET", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "PARTY_HEIGHT_PET", callback = function() UpdateGridSettingsThrottled("PARTY_PET", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "PARTY_UNITS_HORIZONTAL_SPACING_PET", callback = function() UpdateGridSettingsThrottled("PARTY_PET", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "PARTY_UNITS_VERTICAL_SPACING_PET", callback = function() UpdateGridSettingsThrottled("PARTY_PET", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}})

    -- Sorting
    p:AddGroupHeader(L["Grouping & Sorting"])
    p:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "PARTY_SORT_DIRECTION_PET", callback = function() UpdateGridSettingsAndRefreshPreview("PARTY_PET", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "PARTY_RAID_SORT_METHOD_PET", callback = function() UpdateGridSettingsAndRefreshPreview("PARTY_PET", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["RAID_FRAMES"] = true, ["PARTY_PET_FRAMES_ENABLED"] = true,  ["PARTY_GRID_ACTIVE"] = true}})

    return p
end

local function LoadRaidPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    local profilePanles = {LoadGeneralGridSettings(p), LoadRaid40Profile(p), LoadRaid25Profile(p), LoadRaid10Profile(p), LoadRaidPetProfile(p), LoadMaintankProfile(p), LoadPartyProfile(p), LoadPartyPetProfile(p)}

    sWindow:AddSettingsPanel(p, L["Group Frames"], L["Edit the party and raid options to suit your needs."], {
        {name = GENERAL, frame = profilePanles[1]},
        {name = RAID..": 40", frame = profilePanles[2]},
        {name = RAID..": 25", frame = profilePanles[3]},
        {name = RAID..": 10", frame = profilePanles[4]},
        {name = RAID .. ": " .. PET, frame = profilePanles[5]},
        {name = MAINTANK, frame = profilePanles[6]},
        {name = L["Party Grid"], frame = profilePanles[7]},
        {name = L["Party Grid"] .. ": " .. PET, frame = profilePanles[8]}
    })
end
GW.LoadRaidPanel = LoadRaidPanel
