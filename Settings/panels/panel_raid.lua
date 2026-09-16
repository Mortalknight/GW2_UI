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
    general:AddOption(ENABLE, RAID_FRAMES_SUBTEXT, {getterSetter = "groupFrames.enabled", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})

    general:AddOptionSlider(L["Name Update Rate"], L["Maximum tick rate allowed for name updates per second."], { getterSetter = "groupFrames.tagUpdateRate", callback = function(value) GW.oUF.Tags:SetEventUpdateTimer(value) end, min = 0.05, max = 0.5, decimalNumbers = 2, step = 0.01})

    return general
end

-- NOTE 12.1: the private aura options were removed — the anchor system no longer
-- exists, private auras render as normal secret debuffs through the containers
local function CreateAuraFilterSection(panel, profile, buffDb, debuffDb, showBuffs, showDebuffs, dependence)
    if GW.Retail then
        panel:AddOptionNote(L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."]
            .. "\n" .. L["Clicking an entry cycles through three states: off (ignored) - check (only auras with this property are shown) - red cross (auras with this property are hidden)."]
            .. "\n" .. L["Important and dispellable debuffs always render through their own scaled groups, no matter what is selected here."], {
            isVisible = function() return GW.settings.groupFrames.enabled == true and GW.GetSetting(dependence) == true and (GW.GetSetting(showBuffs) == true or GW.GetSetting(showDebuffs) == true) end,
            group = "gridAuraFilterNote",
        })
    end

    panel:AddGroupHeader(L["Buffs"])

    panel:AddOption(SHOW_BUFFS, nil, {getterSetter = showBuffs, callback = function() GW.UpdateGridSettings(profile) end, dependence = {["groupFrames.enabled"] = true, [dependence] = true}, groupHeaderName = L["Buffs"]})
    panel:AddOptionDropdown(L["Buffs"], L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."], {getterSetter = buffDb, callback = function() GW.UpdateGridSettings(profile) end, optionsList = auraOptions, optionNames = auraOptionsNames, checkbox = true, triState = true, dependence = {["groupFrames.enabled"] = true, [dependence] = true, [showBuffs] = true}, groupHeaderName = L["Buffs"], hidden = not GW.Retail})

    panel:AddGroupHeader(L["Debuffs"])
    panel:AddOption(SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, {getterSetter = showDebuffs, callback = function() GW.UpdateGridSettings(profile) end, dependence = {["groupFrames.enabled"] = true, [dependence] = true}, groupHeaderName = L["Debuffs"]})
    panel:AddOptionDropdown(L["Debuffs"], L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."], {getterSetter = debuffDb, callback = function() GW.UpdateGridSettings(profile) end, optionsList = auraOptions, optionNames = auraOptionsNames, checkbox = true, triState = true, dependence = {["groupFrames.enabled"] = true, [dependence] = true, [showDebuffs] = true}, groupHeaderName = L["Debuffs"], hidden = not GW.Retail})
end

-- per grid ignore list (all game versions: retail containers exclude the spell ids,
-- the classic engine checks them in its aura filter). Own function: it is called
-- AFTER the classic only debuff options of each grid page, since the panel layout
-- follows the creation order
local function CreateIgnoredAuraSection(panel, profile, ignoredSetting, dependence)
    panel:AddGroupHeader(L["Ignored Auras"])
    panel:AddOptionSpellList(L["Ignored Auras"], L["A list of auras that should never be shown."], {getterSetter = ignoredSetting, callback = function() GW.UpdateGridSettings(profile) end, dependence = {["groupFrames.enabled"] = true, [dependence] = true}, groupHeaderName = L["Ignored Auras"]})
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
    raid10.preview:SetScript("OnClick", GridPreviewOnClick("raid10"))
    raid10.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    raid10.preview:SetScript("OnLeave", GameTooltip_Hide)
    raid10.preview:SetEnabled(GW.settings.groupFrames.raid10.enabled)

    raid10:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.groupFrames.enabled ~= true end,
        group = "gridPageNote",
    })
    raid10:AddOption(ENABLE, L["Display a separate raid grid for groups from 1 to 10 players"], {getterSetter = "groupFrames.raid10.enabled", isMasterToggle = true, callback = function(value) raid10.preview:SetEnabled(value) GW.UpdateGridSettings("raid10", nil, true) GW.UpdateGridSettings("raid25", nil, true) GW.UpdateGridSettings("raid40", nil, true) end, dependence = {["groupFrames.enabled"] = true}})
    raid10:AddOption(RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "groupFrames.raid10.classColor", callback = function() GW.UpdateGridSettings("raid10") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, group = "gridClass"})
    raid10:AddOption(L["Hide class icon"], nil, {getterSetter = "groupFrames.raid10.hideClassIcon", callback = function() GW.UpdateGridSettings("raid10") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true, ["groupFrames.raid10.classColor"] = false}, group = "gridClass"})

    raid10:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "groupFrames.raid10.unitMarkers", callback = function() GW.UpdateGridSettings("raid10") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, group = "gridIcons"})
    raid10:AddOption(L["Role Icon"], nil, {getterSetter = "groupFrames.raid10.showRoleIcon", callback = function() GW.UpdateGridSettings("raid10") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, group = "gridIcons"})
    raid10:AddOption(L["Tank Icon"], nil, {getterSetter = "groupFrames.raid10.showTankIcon", callback = function() GW.UpdateGridSettings("raid10") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, group = "gridIcons"})
    raid10:AddOption(L["Leader/Assist Icon"], nil, {getterSetter = "groupFrames.raid10.showLeaderIcon", callback = function() GW.UpdateGridSettings("raid10") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, group = "gridIcons"})

    raid10:AddOption(L["Shorten health values"], nil, {getterSetter = "groupFrames.raid10.shortHealthValues", callback = function() GW.UpdateGridSettings("raid10") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, hidden = not GW.Retail, group = "gridBars"})
    raid10:AddOption(L["Show absorb bar"], nil, {getterSetter = "groupFrames.raid10.showAbsorbBar", callback = function() GW.UpdateGridSettings("raid10") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    raid10:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "groupFrames.raid10.unitHealth",
        callback = function() GW.UpdateGridSettings("raid10") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true},
        group = "gridBars"
    })
    raid10:AddOptionDropdown(DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "groupFrames.raid10.showPowerBar", callback = function() GW.UpdateGridSettings("raid10") end, optionsList = {"ALL", "HEALER", "NONE"}, optionNames = {ALL, HEALER, NONE}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, group = "gridBars"})
    raid10:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "groupFrames.raid10.healthBarTexture", callback = function() GW.UpdateGridSettings("raid10") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, group = "gridBars"})

    raid10:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "groupFrames.raid10.auraTooltipInCombat", callback = function() GW.UpdateGridSettings("raid10") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, group = "gridMisc"})
    raid10:AddOptionDropdown(L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "groupFrames.raid10.unitFlags", callback = function() GW.UpdateGridSettings("raid10") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, hidden = not GW.Retail, group = "gridMisc"})

    raid10:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "groupFrames.raid10.anchorFromCenter", callback = function() GW.UpdateGridSettings("raid10", true) end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(raid10, "raid10", "groupFrames.raid10.buffFilter", "groupFrames.raid10.debuffFilter", "groupFrames.raid10.showBuffs", "groupFrames.raid10.showDebuffs", "groupFrames.raid10.enabled")
    -- none retail debuff filter
    raid10:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "groupFrames.raid10.onlyDispellableDebuffs", callback = function() GW.UpdateGridSettings("raid10") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true, ["groupFrames.raid10.showDebuffs"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid10:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "groupFrames.raid10.showRaidInstanceDebuffs", callback = function() GW.UpdateGridSettings("raid10") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid10:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "groupFrames.raid10.pandemicHighlight", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.raid10.enabled"] = true}, hidden = not GW.Retail})
    raid10:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "groupFrames.raid10.dispelIcon", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.raid10.enabled"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(raid10, "raid10", "groupFrames.raid10.ignoredAuras", "groupFrames.raid10.enabled")


    --fader
    raid10:AddGroupHeader(L["Fader"])
    raid10:AddOption(L["Range"], nil, {getterSetter = "groupFrames.raid10.faderRange", callback = function() GW.UpdateGridSettings("raid10") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}, groupHeaderName = L["Fader"]})
    raid10:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "groupFrames.raid10.fader", callback = function() GW.UpdateGridSettings("raid10") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true, ["groupFrames.raid10.faderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]
    })

    raid10:AddOptionSlider(L["Smooth"], nil, { getterSetter = "groupFrames.raid10.fader.smooth", callback = function() UpdateGridSettingsThrottled("raid10") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})
    raid10:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "groupFrames.raid10.fader.minAlpha", callback = function() UpdateGridSettingsThrottled("raid10") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})
    raid10:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "groupFrames.raid10.fader.maxAlpha", callback = function() UpdateGridSettingsThrottled("raid10") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})

    -- Size and Positions
    raid10:AddGroupHeader( L["Size and Positions"])
    raid10:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "groupFrames.raid10.grow", callback = function() GW.UpdateGridSettings("raid10", true) end, optionsList = grow, optionNames = MapTable(
            grow,
            function(dir)
                local g1, g2 = strsplit("+", dir)
                return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
            end
       ), dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})

    raid10:AddOptionSlider(L["Groups Per Row/Column"], nil, { getterSetter = "groupFrames.raid10.groupsPerColumn", callback = function() UpdateGridSettingsThrottled("raid10", true) end, min = 1, max = 2, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})
    raid10:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "groupFrames.raid10.width", callback = function() UpdateGridSettingsThrottled("raid10", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})
    raid10:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "groupFrames.raid10.height", callback = function() UpdateGridSettingsThrottled("raid10", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})
    raid10:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "groupFrames.raid10.horizontalSpacing", callback = function() UpdateGridSettingsThrottled("raid10", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})
    raid10:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "groupFrames.raid10.verticalSpacing", callback = function() UpdateGridSettingsThrottled("raid10", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})
    raid10:AddOptionSlider(L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "groupFrames.raid10.groupSpacing", callback = function() UpdateGridSettingsThrottled("raid10", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})

    -- Sorting
    raid10:AddGroupHeader(L["Grouping & Sorting"])
    raid10:AddOption(L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "groupFrames.raid10.wideSorting", callback = function() UpdateGridSettingsAndRefreshPreview("raid10", false, true) end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})
    raid10:AddOptionDropdown(L["Group By"], L["Set the order that the group will sort."], { getterSetter = "groupFrames.raid10.groupBy", callback = function() UpdateGridSettingsAndRefreshPreview("raid10", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})
    raid10:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "groupFrames.raid10.sortDirection", callback = function() UpdateGridSettingsAndRefreshPreview("raid10", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true}})
    raid10:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "groupFrames.raid10.sortMethod", callback = function() UpdateGridSettingsAndRefreshPreview("raid10", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid10.enabled"] = true, ["groupFrames.raid10.groupBy"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})

    CreateClassSortebalList(raid10, "groupFrames.raid10.groupByClassOrder", "groupFrames.raid10.groupBy")
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
    raid25.preview:SetScript("OnClick", GridPreviewOnClick("raid25"))
    raid25.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    raid25.preview:SetScript("OnLeave", GameTooltip_Hide)
    raid25.preview:SetEnabled(GW.settings.groupFrames.raid25.enabled)

    raid25:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.groupFrames.enabled ~= true end,
        group = "gridPageNote",
    })
    raid25:AddOption(ENABLE, L["Display a separate raid grid for groups from 11 to 25 players"], {getterSetter = "groupFrames.raid25.enabled", isMasterToggle = true, callback = function(value) raid25.preview:SetEnabled(value); GW.UpdateGridSettings("raid10", nil, true); GW.UpdateGridSettings("raid25", nil, true); GW.UpdateGridSettings("raid40", nil, true) end, dependence = {["groupFrames.enabled"] = true}})
    raid25:AddOption(RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "groupFrames.raid25.classColor", callback = function() GW.UpdateGridSettings("raid25") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, group = "gridClass"})
    raid25:AddOption(L["Hide class icon"], nil, {getterSetter = "groupFrames.raid25.hideClassIcon", callback = function() GW.UpdateGridSettings("raid25") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true, ["groupFrames.raid25.classColor"] = false}, group = "gridClass"})

    raid25:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "groupFrames.raid25.unitMarkers", callback = function() GW.UpdateGridSettings("raid25") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, group = "gridIcons"})
    raid25:AddOption(L["Role Icon"], nil, {getterSetter = "groupFrames.raid25.showRoleIcon", callback = function() GW.UpdateGridSettings("raid25") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, group = "gridIcons"})
    raid25:AddOption(L["Tank Icon"], nil, {getterSetter = "groupFrames.raid25.showTankIcon", callback = function() GW.UpdateGridSettings("raid25") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, group = "gridIcons"})
    raid25:AddOption(L["Leader/Assist Icon"], nil, {getterSetter = "groupFrames.raid25.showLeaderIcon", callback = function() GW.UpdateGridSettings("raid25") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, group = "gridIcons"})

    raid25:AddOption(L["Shorten health values"], nil, {getterSetter = "groupFrames.raid25.shortHealthValues", callback = function() GW.UpdateGridSettings("raid25") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, hidden = not GW.Retail, group = "gridBars"})
    raid25:AddOption(L["Show absorb bar"] , nil, {getterSetter = "groupFrames.raid25.showAbsorbBar", callback = function() GW.UpdateGridSettings("raid25") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    raid25:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "groupFrames.raid25.unitHealth",
        callback = function() GW.UpdateGridSettings("raid25") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true},
        group = "gridBars"
    })
    raid25:AddOptionDropdown(DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "groupFrames.raid25.showPowerBar", callback = function() GW.UpdateGridSettings("raid25") end, optionsList = {"ALL", "HEALER", "NONE"}, optionNames = {ALL, HEALER, NONE}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, group = "gridBars"})
    raid25:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "groupFrames.raid25.healthBarTexture", callback = function() GW.UpdateGridSettings("raid25") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, group = "gridBars"})

    raid25:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "groupFrames.raid25.auraTooltipInCombat", callback = function() GW.UpdateGridSettings("raid25") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, group = "gridMisc"})
    raid25:AddOptionDropdown(L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "groupFrames.raid25.unitFlags", callback = function() GW.UpdateGridSettings("raid25") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, hidden = not GW.Retail, group = "gridMisc"})

    raid25:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "groupFrames.raid25.anchorFromCenter", callback = function() GW.UpdateGridSettings("raid25", true) end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(raid25, "raid25", "groupFrames.raid25.buffFilter", "groupFrames.raid25.debuffFilter", "groupFrames.raid25.showBuffs", "groupFrames.raid25.showDebuffs", "groupFrames.raid25.enabled")
    -- none retail debuff filter
    raid25:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "groupFrames.raid25.onlyDispellableDebuffs", callback = function() GW.UpdateGridSettings("raid25") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true, ["groupFrames.raid25.showDebuffs"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid25:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "groupFrames.raid25.showRaidInstanceDebuffs", callback = function() GW.UpdateGridSettings("raid25") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid25:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "groupFrames.raid25.pandemicHighlight", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.raid25.enabled"] = true}, hidden = not GW.Retail})
    raid25:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "groupFrames.raid25.dispelIcon", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.raid25.enabled"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(raid25, "raid25", "groupFrames.raid25.ignoredAuras", "groupFrames.raid25.enabled")


    --fader
    raid25:AddGroupHeader(L["Fader"])
    raid25:AddOption(L["Range"], nil, {getterSetter = "groupFrames.raid25.faderRange", callback = function() GW.UpdateGridSettings("raid25") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}, groupHeaderName = L["Fader"]})

    raid25:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "groupFrames.raid25.fader", callback = function() GW.UpdateGridSettings("raid25") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true, ["groupFrames.raid25.faderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]
    })
    raid25:AddOptionSlider(L["Smooth"], nil, { getterSetter = "groupFrames.raid25.fader.smooth", callback = function() UpdateGridSettingsThrottled("raid25") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})
    raid25:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "groupFrames.raid25.fader.minAlpha", callback = function() UpdateGridSettingsThrottled("raid25") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})
    raid25:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "groupFrames.raid25.fader.maxAlpha", callback = function() UpdateGridSettingsThrottled("raid25") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})

    -- Size and Positions
    raid25:AddGroupHeader( L["Size and Positions"])
    raid25:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "groupFrames.raid25.grow", callback = function() GW.UpdateGridSettings("raid25", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})

    raid25:AddOptionSlider(L["Groups Per Row/Column"], nil, { getterSetter = "groupFrames.raid25.groupsPerColumn", callback = function() UpdateGridSettingsThrottled("raid25", true) end, min = 1, max = 5, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})
    raid25:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "groupFrames.raid25.width", callback = function() UpdateGridSettingsThrottled("raid25", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})
    raid25:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "groupFrames.raid25.height", callback = function() UpdateGridSettingsThrottled("raid25", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})
    raid25:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "groupFrames.raid25.horizontalSpacing", callback = function() UpdateGridSettingsThrottled("raid25", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})
    raid25:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "groupFrames.raid25.verticalSpacing", callback = function() UpdateGridSettingsThrottled("raid25", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})
    raid25:AddOptionSlider(L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "groupFrames.raid25.groupSpacing", callback = function() UpdateGridSettingsThrottled("raid25", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})

    -- Sorting
    raid25:AddGroupHeader(L["Grouping & Sorting"])
    raid25:AddOption(L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "groupFrames.raid25.wideSorting", callback = function() UpdateGridSettingsAndRefreshPreview("raid25", false, true) end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})
    raid25:AddOptionDropdown(L["Group By"], L["Set the order that the group will sort."], { getterSetter = "groupFrames.raid25.groupBy", callback = function() UpdateGridSettingsAndRefreshPreview("raid25", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})
    raid25:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "groupFrames.raid25.sortDirection", callback = function() UpdateGridSettingsAndRefreshPreview("raid25", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true}})
    raid25:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "groupFrames.raid25.sortMethod", callback = function() UpdateGridSettingsAndRefreshPreview("raid25", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid25.enabled"] = true, ["groupFrames.raid25.groupBy"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})

    CreateClassSortebalList(raid25, "groupFrames.raid25.groupByClassOrder", "groupFrames.raid25.groupBy")
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
    raid40.preview:SetScript("OnClick", GridPreviewOnClick("raid40"))
    raid40.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    raid40.preview:SetScript("OnLeave", GameTooltip_Hide)
    raid40.preview:SetEnabled(GW.settings.groupFrames.enabled and GW.settings.groupFrames.raid40.enabled)

    raid40:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.groupFrames.enabled ~= true end,
        group = "gridPageNote",
    })
    raid40:AddOption(ENABLE, L["Display a separate raid grid for groups from 26 to 40 players"], {getterSetter = "groupFrames.raid40.enabled", isMasterToggle = true, callback = function(value) raid40.preview:SetEnabled(value and GW.settings.groupFrames.enabled); GW.UpdateGridSettings("raid40", nil, true) end, dependence = {["groupFrames.enabled"] = true}})
    raid40:AddOption(RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "groupFrames.raid40.classColor", callback = function() GW.UpdateGridSettings("raid40") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, group = "gridClass"})
    raid40:AddOption(L["Hide class icon"], nil, {getterSetter = "groupFrames.raid40.hideClassIcon", callback = function() GW.UpdateGridSettings("raid40") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true, ["groupFrames.raid40.classColor"] = false}, group = "gridClass"})

    raid40:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "groupFrames.raid40.unitMarkers", callback = function() GW.UpdateGridSettings("raid40") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, group = "gridIcons"})
    raid40:AddOption(L["Role Icon"], nil, {getterSetter = "groupFrames.raid40.showRoleIcon", callback = function() GW.UpdateGridSettings("raid40") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, group = "gridIcons"})
    raid40:AddOption(L["Tank Icon"], nil, {getterSetter = "groupFrames.raid40.showTankIcon", callback = function() GW.UpdateGridSettings("raid40") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, group = "gridIcons"})
    raid40:AddOption(L["Leader/Assist Icon"], nil, {getterSetter = "groupFrames.raid40.showLeaderIcon", callback = function() GW.UpdateGridSettings("raid40") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, group = "gridIcons"})

    raid40:AddOption(L["Shorten health values"], nil, {getterSetter = "groupFrames.raid40.shortHealthValues", callback = function() GW.UpdateGridSettings("raid40") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, hidden = not GW.Retail, group = "gridBars"})
    raid40:AddOption(L["Show absorb bar"], nil, {getterSetter = "groupFrames.raid40.showAbsorbBar", callback = function() GW.UpdateGridSettings("raid40") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    raid40:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "groupFrames.raid40.unitHealth", callback = function() GW.UpdateGridSettings("raid40") end, optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"}, optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, group = "gridBars"
    })
    raid40:AddOptionDropdown(DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "groupFrames.raid40.showPowerBar", callback = function() GW.UpdateGridSettings("raid40") end, optionsList = {"ALL", "HEALER", "NONE"}, optionNames = {ALL, HEALER, NONE}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, group = "gridBars"})
    raid40:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "groupFrames.raid40.healthBarTexture", callback = function() GW.UpdateGridSettings("raid40") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, group = "gridBars"})

    raid40:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "groupFrames.raid40.auraTooltipInCombat", callback = function() GW.UpdateGridSettings("raid40") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, group = "gridMisc"})
    raid40:AddOptionDropdown(L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "groupFrames.raid40.unitFlags", callback = function() GW.UpdateGridSettings("raid40") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, hidden = not GW.Retail, group = "gridMisc"})

    raid40:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "groupFrames.raid40.anchorFromCenter", callback = function() GW.UpdateGridSettings("raid40", true) end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(raid40, "raid40", "groupFrames.raid40.buffFilter", "groupFrames.raid40.debuffFilter", "groupFrames.raid40.showBuffs", "groupFrames.raid40.showDebuffs", "groupFrames.raid40.enabled")
    -- none retail debuff filter
    raid40:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "groupFrames.raid40.onlyDispellableDebuffs", callback = function() GW.UpdateGridSettings("raid40") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true, ["groupFrames.raid40.showDebuffs"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid40:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "groupFrames.raid40.showRaidInstanceDebuffs", callback = function() GW.UpdateGridSettings("raid40") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    raid40:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "groupFrames.raid40.pandemicHighlight", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, hidden = not GW.Retail})
    raid40:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]},
        getterSetter = "groupFrames.raid40.dispelIcon", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, hidden = not GW.Retail
    })
    CreateIgnoredAuraSection(raid40, "raid40", "groupFrames.raid40.ignoredAuras", "groupFrames.raid40.enabled")


    --fader
    raid40:AddGroupHeader(L["Fader"])
    raid40:AddOption(L["Range"], nil, {getterSetter = "groupFrames.raid40.faderRange", callback = function() GW.UpdateGridSettings("raid40") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}, groupHeaderName = L["Fader"]})
    raid40:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "groupFrames.raid40.fader", callback = function() GW.UpdateGridSettings("raid40") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true, ["groupFrames.raid40.faderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]
    })
    raid40:AddOptionSlider(L["Smooth"], nil, { getterSetter = "groupFrames.raid40.fader.smooth", callback = function() UpdateGridSettingsThrottled("raid40") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true}})
    raid40:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "groupFrames.raid40.fader.minAlpha", callback = function() UpdateGridSettingsThrottled("raid40") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true}})
    raid40:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "groupFrames.raid40.fader.maxAlpha", callback = function() UpdateGridSettingsThrottled("raid40") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true}})

    -- Size and Positions
    raid40:AddGroupHeader(L["Size and Positions"])
    raid40:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "groupFrames.raid40.grow", callback = function() GW.UpdateGridSettings("raid40", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}})

    raid40:AddOptionSlider(L["Groups Per Row/Column"], nil, { getterSetter = "groupFrames.raid40.groupsPerColumn", callback = function() UpdateGridSettingsThrottled("raid40", true) end, min = 1, max = 8, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}})
    raid40:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "groupFrames.raid40.width", callback = function() UpdateGridSettingsThrottled("raid40", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}})
    raid40:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "groupFrames.raid40.height", callback = function() UpdateGridSettingsThrottled("raid40", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}})
    raid40:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "groupFrames.raid40.horizontalSpacing", callback = function() UpdateGridSettingsThrottled("raid40", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}})
    raid40:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "groupFrames.raid40.verticalSpacing", callback = function() UpdateGridSettingsThrottled("raid40", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}})
    raid40:AddOptionSlider(L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "groupFrames.raid40.groupSpacing", callback = function() UpdateGridSettingsThrottled("raid40", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence ={["groupFrames.enabled"] = true}})

    -- Sorting
    raid40:AddGroupHeader(L["Grouping & Sorting"])
    raid40:AddOption(L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "groupFrames.raid40.wideSorting", callback = function() UpdateGridSettingsAndRefreshPreview("raid40", false, true) end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}})
    raid40:AddOptionDropdown(L["Group By"], L["Set the order that the group will sort."], { getterSetter = "groupFrames.raid40.groupBy", callback = function() UpdateGridSettingsAndRefreshPreview("raid40", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}})
    raid40:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "groupFrames.raid40.sortDirection", callback = function() UpdateGridSettingsAndRefreshPreview("raid40", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true}})
    raid40:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "T", callback = function() UpdateGridSettingsAndRefreshPreview("raid40", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raid40.enabled"] = true, ["groupFrames.raid40.groupBy"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})
    CreateClassSortebalList(raid40, "groupFrames.raid40.groupByClassOrder", "groupFrames.raid40.groupBy")
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
    tank.preview:SetScript("OnClick", GridPreviewOnClick("maintank"))
    tank.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    tank.preview:SetScript("OnLeave", GameTooltip_Hide)
    tank.preview:SetEnabled(GW.settings.groupFrames.maintank.enabled)

    tank:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.groupFrames.enabled ~= true end,
        group = "gridPageNote",
    })
    tank:AddOption(ENABLE, L["Enable Maintank grid"], {getterSetter = "groupFrames.maintank.enabled", isMasterToggle = true, callback = function(value) tank.preview:SetEnabled(value); GW.UpdateGridSettings("maintank", nil, true) end, dependence = {["groupFrames.enabled"] = true}})
    tank:AddOption(RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "groupFrames.maintank.classColor", callback = function() GW.UpdateGridSettings("maintank") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, group = "gridClass"})
    tank:AddOption(L["Hide class icon"], nil, {getterSetter = "groupFrames.maintank.hideClassIcon", callback = function() GW.UpdateGridSettings("maintank") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true, ["groupFrames.maintank.classColor"] = false}, group = "gridClass"})

    tank:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "groupFrames.maintank.unitMarkers", callback = function() GW.UpdateGridSettings("maintank") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, group = "gridIcons"})
    tank:AddOption(L["Role Icon"], nil, {getterSetter = "groupFrames.maintank.showRoleIcon", callback = function() GW.UpdateGridSettings("maintank") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, group = "gridIcons"})
    tank:AddOption(L["Tank Icon"], nil, {getterSetter = "groupFrames.maintank.showTankIcon", callback = function() GW.UpdateGridSettings("maintank") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, group = "gridIcons"})
    tank:AddOption(L["Leader/Assist Icon"], nil, {getterSetter = "groupFrames.maintank.showLeaderIcon", callback = function() GW.UpdateGridSettings("maintank") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, group = "gridIcons"})

    tank:AddOption(L["Shorten health values"], nil, {getterSetter = "groupFrames.maintank.shortHealthValues", callback = function() GW.UpdateGridSettings("maintank") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, hidden = not GW.Retail, group = "gridBars"})
    tank:AddOption(L["Show absorb bar"], nil, {getterSetter = "groupFrames.maintank.showAbsorbBar", callback = function() GW.UpdateGridSettings("maintank") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    tank:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "groupFrames.maintank.unitHealth",
        callback = function() GW.UpdateGridSettings("maintank") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true},
        group = "gridBars"
    })
    tank:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "groupFrames.maintank.healthBarTexture", callback = function() GW.UpdateGridSettings("maintank") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, group = "gridBars"})

    tank:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "groupFrames.maintank.auraTooltipInCombat", callback = function() GW.UpdateGridSettings("maintank") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, group = "gridMisc"})
    tank:AddOptionDropdown(L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "groupFrames.maintank.unitFlags", callback = function() GW.UpdateGridSettings("maintank") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, hidden = not GW.Retail, group = "gridMisc"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(tank, "maintank", "groupFrames.maintank.buffFilter", "groupFrames.maintank.debuffFilter", "groupFrames.maintank.showBuffs", "groupFrames.maintank.showDebuffs", "groupFrames.maintank.enabled")
    -- none retail debuff filter
    tank:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "groupFrames.maintank.onlyDispellableDebuffs", callback = function() GW.UpdateGridSettings("maintank") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true, ["groupFrames.maintank.showDebuffs"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    tank:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "groupFrames.maintank.showRaidInstanceDebuffs", callback = function() GW.UpdateGridSettings("maintank") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    tank:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "groupFrames.maintank.pandemicHighlight", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.maintank.enabled"] = true}, hidden = not GW.Retail})
    tank:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "groupFrames.maintank.dispelIcon", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.maintank.enabled"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(tank, "maintank", "groupFrames.maintank.ignoredAuras", "groupFrames.maintank.enabled")


    --fader
    tank:AddGroupHeader(L["Fader"])
    tank:AddOption(L["Range"], nil, {getterSetter = "groupFrames.maintank.faderRange", callback = function() GW.UpdateGridSettings("maintank") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}, groupHeaderName = L["Fader"]})
    tank:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "groupFrames.maintank.fader",
        callback = function() GW.UpdateGridSettings("maintank") end,
        optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"},
        optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]},
        dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true, ["groupFrames.maintank.faderRange"] = false},
        checkbox = true,
        groupHeaderName = L["Fader"]
    })
    tank:AddOptionSlider(L["Smooth"], nil, { getterSetter = "groupFrames.maintank.fader.smooth", callback = function() UpdateGridSettingsThrottled("maintank") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}})
    tank:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "groupFrames.maintank.fader.minAlpha", callback = function() UpdateGridSettingsThrottled("maintank") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}})
    tank:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "groupFrames.maintank.fader.maxAlpha", callback = function() UpdateGridSettingsThrottled("maintank") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}})

    -- Size and Positions
    tank:AddGroupHeader( L["Size and Positions"])
    tank:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "groupFrames.maintank.grow", callback = function() GW.UpdateGridSettings("maintank", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}})

    tank:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "groupFrames.maintank.width", callback = function() UpdateGridSettingsThrottled("maintank", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}})
    tank:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "groupFrames.maintank.height", callback = function() UpdateGridSettingsThrottled("maintank", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}})
    tank:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "groupFrames.maintank.horizontalSpacing", callback = function() UpdateGridSettingsThrottled("maintank", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}})
    tank:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "groupFrames.maintank.verticalSpacing", callback = function() UpdateGridSettingsThrottled("maintank", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.maintank.enabled"] = true}})

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
    p.preview:SetScript("OnClick", GridPreviewOnClick("raidPet"))
    p.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.preview:SetScript("OnLeave", GameTooltip_Hide)
    p.preview:SetEnabled(GW.settings.groupFrames.raidPet.enabled)

    p:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.groupFrames.enabled ~= true end,
        group = "gridPageNote",
    })
    p:AddOption(ENABLE, L["Show a separate grid for raid pets"], {getterSetter = "groupFrames.raidPet.enabled", isMasterToggle = true, callback = function(value) p.preview:SetEnabled(value); GW.UpdateGridSettings("raidPet", nil, true) end, dependence = {["groupFrames.enabled"] = true}})
    p:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "groupFrames.raidPet.unitMarkers", callback = function() GW.UpdateGridSettings("raidPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}, group = "gridIcons"})

    p:AddOption(L["Shorten health values"], nil, {getterSetter = "groupFrames.raidPet.shortHealthValues", callback = function() GW.UpdateGridSettings("raidPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}, hidden = not GW.Retail, group = "gridBars"})
    p:AddOption(L["Show absorb bar"], nil, {getterSetter = "groupFrames.raidPet.showAbsorbBar", callback = function() GW.UpdateGridSettings("raidPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    p:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "groupFrames.raidPet.unitHealth",
        callback = function() GW.UpdateGridSettings("raidPet") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true},
        group = "gridBars"
    })
    p:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "groupFrames.raidPet.healthBarTexture", callback = function() GW.UpdateGridSettings("raidPet") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}, group = "gridBars"})

    p:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "groupFrames.raidPet.auraTooltipInCombat", callback = function() GW.UpdateGridSettings("raidPet") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}, group = "gridMisc"})

    p:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "groupFrames.raidPet.anchorFromCenter", callback = function() GW.UpdateGridSettings("raidPet", true) end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(p, "raidPet", "groupFrames.raidPet.buffFilter", "groupFrames.raidPet.debuffFilter", "groupFrames.raidPet.showBuffs", "groupFrames.raidPet.showDebuffs", "groupFrames.raidPet.enabled")
    -- none retail debuff filter
    p:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "groupFrames.raidPet.onlyDispellableDebuffs", callback = function() GW.UpdateGridSettings("raidPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true, ["groupFrames.raidPet.showDebuffs"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    p:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "groupFrames.raidPet.showRaidInstanceDebuffs", callback = function() GW.UpdateGridSettings("raidPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    p:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "groupFrames.raidPet.pandemicHighlight", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.raidPet.enabled"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "groupFrames.raidPet.dispelIcon", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.raidPet.enabled"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(p, "raidPet", "groupFrames.raidPet.ignoredAuras", "groupFrames.raidPet.enabled")

    --fader
    p:AddGroupHeader(L["Fader"])
    p:AddOption(L["Range"], nil, {getterSetter = "groupFrames.raidPet.faderRange", callback = function() GW.UpdateGridSettings("raidPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}, groupHeaderName = L["Fader"]})
    p:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "groupFrames.raidPet.fader", callback = function() GW.UpdateGridSettings("raidPet") end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true, ["groupFrames.raidPet.faderRange"] = false}, checkbox = true, groupHeaderName = L["Fader"]
    })
    p:AddOptionSlider(L["Smooth"], nil, { getterSetter = "groupFrames.raidPet.fader.smooth", callback = function() UpdateGridSettingsThrottled("raidPet") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})
    p:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "groupFrames.raidPet.fader.minAlpha", callback = function() UpdateGridSettingsThrottled("raidPet") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})
    p:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "groupFrames.raidPet.fader.maxAlpha", callback = function() UpdateGridSettingsThrottled("raidPet") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})

    -- Size and Positions
    p:AddGroupHeader( L["Size and Positions"])
    p:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "groupFrames.raidPet.grow", callback = function() GW.UpdateGridSettings("raidPet", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})

    p:AddOptionSlider(L["Groups Per Row/Column"], nil, { getterSetter = "groupFrames.raidPet.groupsPerColumn", callback = function() UpdateGridSettingsThrottled("raidPet", true) end, min = 1, max = 8, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})
    p:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "groupFrames.raidPet.width", callback = function() UpdateGridSettingsThrottled("raidPet", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})
    p:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "groupFrames.raidPet.height", callback = function() UpdateGridSettingsThrottled("raidPet", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})
    p:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "groupFrames.raidPet.horizontalSpacing", callback = function() UpdateGridSettingsThrottled("raidPet", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})
    p:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "groupFrames.raidPet.verticalSpacing", callback = function() UpdateGridSettingsThrottled("raidPet", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})
    p:AddOptionSlider(L["Group Spacing"], L["Additional spacing between each individual group."], { getterSetter = "groupFrames.raidPet.groupSpacing", callback = function() UpdateGridSettingsThrottled("raidPet", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})

    -- Sorting
    p:AddGroupHeader(L["Grouping & Sorting"])
    p:AddOption(L["Raid-Wide Sorting"], L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."], {getterSetter = "groupFrames.raidPet.wideSorting", callback = function() UpdateGridSettingsAndRefreshPreview("raidPet", false, true) end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})
    p:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "groupFrames.raidPet.sortDirection", callback = function() UpdateGridSettingsAndRefreshPreview("raidPet", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})
    p:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "groupFrames.raidPet.sortMethod", callback = function() UpdateGridSettingsAndRefreshPreview("raidPet", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.raidPet.enabled"] = true}})

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
    party.preview:SetScript("OnClick", GridPreviewOnClick("party"))
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
        return GW.settings.groupFrames.party.enabled == true or GW.settings.groupFrames.party.withPartyFrames == true
    end
    party.preview:SetEnabled(IsPartyGridActive())
    -- the "show both" toggle lives on the party frame page and has to reach the button here
    GW.UpdatePartyGridPreviewState = function() party.preview:SetEnabled(IsPartyGridActive()) end

    -- the whole page depends on {RAID_FRAMES = true, PARTY_GRID_ACTIVE = true}; these two notes
    -- name whichever of the two conditions is currently failing. RAID_FRAMES lives on the
    -- "Raid: 40" page, so without this the reason is invisible from here.
    party:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.groupFrames.enabled ~= true end,
        group = "partyPageNote",
    })
    party:AddOptionNote(format(L["This grid is not in use: the stylised party frames are shown instead. Enable '%s' below to replace them with this grid."], USE_RAID_STYLE_PARTY_FRAMES), {
        isVisible = function() return GW.settings.groupFrames.enabled == true and not IsPartyGridActive() end,
        group = "partyPageNote",
    })
    party:AddOption(USE_RAID_STYLE_PARTY_FRAMES, OPTION_TOOLTIP_USE_RAID_STYLE_PARTY_FRAMES, {getterSetter = "groupFrames.party.enabled", callback = function(value) party.preview:SetEnabled(IsPartyGridActive()); GW.UpdateGridSettings("party", false, true); GW.UpdatePlayerInPartySetting(value) end, isMasterToggle = true, dependence = {["groupFrames.enabled"] = true}})
    -- deliberately without a dependence: when this grid is off, every other option on this
    -- page is greyed out and this link is the only thing left that still explains why
    party:AddOptionButton(L["Go to the party frame settings"], L["The stylised party frames and the raid style party grid are two separate displays, each with its own settings page. This opens the other one."], {
        callback = function() GW.GetSettingsTabFrame():OpenSettingsToPanel("party_general") end,
        forceNewLine = true,
        group = "partyPageLink",
    })
    party:AddOption(RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], {getterSetter = "groupFrames.party.classColor", callback = function() GW.UpdateGridSettings("party") end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridClass"})
    party:AddOption(L["Hide class icon"], nil, {getterSetter = "groupFrames.party.hideClassIcon", callback = function() GW.UpdateGridSettings("party") end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true, ["groupFrames.party.classColor"] = false}, group = "gridClass"})

    party:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "groupFrames.party.unitMarkers", callback = function() GW.UpdateGridSettings("party") end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridIcons"})
    party:AddOption(L["Role Icon"], nil, {getterSetter = "groupFrames.party.showRoleIcon", callback = function() GW.UpdateGridSettings("party") end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridIcons"})
    party:AddOption(L["Tank Icon"], nil, {getterSetter = "groupFrames.party.showTankIcon", callback = function() GW.UpdateGridSettings("party") end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridIcons"})
    party:AddOption(L["Leader/Assist Icon"], nil, {getterSetter = "groupFrames.party.showLeaderIcon", callback = function() GW.UpdateGridSettings("party") end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridIcons"})

    party:AddOption(L["Shorten health values"], nil, {getterSetter = "groupFrames.party.shortHealthValues", callback = function() GW.UpdateGridSettings("party") end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, hidden = not GW.Retail, group = "gridBars"})
    party:AddOption(L["Show absorb bar"], nil, {getterSetter = "groupFrames.party.showAbsorbBar", callback = function() GW.UpdateGridSettings("party") end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    party:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "groupFrames.party.unitHealth",
        callback = function() GW.UpdateGridSettings("party") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true},
        group = "gridBars"
    })
    party:AddOptionDropdown(DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], {getterSetter = "groupFrames.party.showPowerBar", callback = function() GW.UpdateGridSettings("party") end, optionsList = {"ALL", "HEALER", "NONE"}, optionNames = {ALL, HEALER, NONE}, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridBars"})
    party:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "groupFrames.party.healthBarTexture", callback = function() GW.UpdateGridSettings("party") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridBars"})

    party:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "groupFrames.party.auraTooltipInCombat", callback = function() GW.UpdateGridSettings("party") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridMisc"})
    party:AddOptionDropdown(L["Show Country Flag"], L["Display a country flag based on the unit's language"], { getterSetter = "groupFrames.party.unitFlags", callback = function() GW.UpdateGridSettings("party") end, optionsList = {"NONE", "DIFFERENT", "ALL"}, optionNames = {NONE_KEY, L["Different Than Own"], ALL}, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, hidden = not GW.Retail, group = "gridMisc"})

    party:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "groupFrames.party.anchorFromCenter", callback = function() GW.UpdateGridSettings("party", true) end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridLayout"})
    party:AddOption(L["Player frame in group"], L["Show your player frame as part of the group"], {getterSetter = "groupFrames.party.showPlayer", callback = function() GW.UpdateGridSettings("party", true) end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(party, "party", "groupFrames.party.buffFilter", "groupFrames.party.debuffFilter", "groupFrames.party.showBuffs", "groupFrames.party.showDebuffs", "PARTY_GRID_ACTIVE")
    -- none retail debuff filter
    party:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "groupFrames.party.onlyDispellableDebuffs", callback = function() GW.UpdateGridSettings("party") end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true, ["groupFrames.party.showDebuffs"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    party:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "groupFrames.party.showRaidInstanceDebuffs", callback = function() GW.UpdateGridSettings("party") end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    party:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "groupFrames.party.pandemicHighlight", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["PARTY_GRID_ACTIVE"] = true}, hidden = not GW.Retail})
    party:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "groupFrames.party.dispelIcon", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["PARTY_GRID_ACTIVE"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(party, "party", "groupFrames.party.ignoredAuras", "PARTY_GRID_ACTIVE")


    --fader
    party:AddGroupHeader(L["Fader"])
    party:AddOption(L["Range"], nil, {getterSetter = "groupFrames.party.faderRange", callback = function() GW.UpdateGridSettings("party") end, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, groupHeaderName = L["Fader"]})
    party:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "groupFrames.party.fader",
        callback = function() GW.UpdateGridSettings("party") end,
        optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"},
        optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]},
        dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true, ["groupFrames.party.faderRange"] = false},
        checkbox = true,
        groupHeaderName = L["Fader"]
    })
    party:AddOptionSlider(L["Smooth"], nil, { getterSetter = "groupFrames.party.fader.smooth", callback = function() UpdateGridSettingsThrottled("party") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "groupFrames.party.fader.minAlpha", callback = function() UpdateGridSettingsThrottled("party") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "groupFrames.party.fader.maxAlpha", callback = function() UpdateGridSettingsThrottled("party") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}})

    -- Size and Positions
    party:AddGroupHeader(L["Size and Positions"])
    party:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "groupFrames.party.grow", callback = function() GW.UpdateGridSettings("party", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}})


    party:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "groupFrames.party.width", callback = function() UpdateGridSettingsThrottled("party", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "groupFrames.party.height", callback = function() UpdateGridSettingsThrottled("party", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "groupFrames.party.horizontalSpacing", callback = function() UpdateGridSettingsThrottled("party", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "groupFrames.party.verticalSpacing", callback = function() UpdateGridSettingsThrottled("party", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    -- Sorting
    party:AddGroupHeader(L["Grouping & Sorting"])
    party:AddOptionDropdown(L["Group By"], L["Set the order that the group will sort."], { getterSetter = "groupFrames.party.groupBy", callback = function() UpdateGridSettingsAndRefreshPreview("party", true) end, optionsList = {"CLASS", "GROUP", "INDEX", "NAME", "ROLE"}, optionNames = {CLASS, GROUP, "Index", NAME, ROLE}, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "groupFrames.party.sortDirection", callback = function() UpdateGridSettingsAndRefreshPreview("party", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}})
    party:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "groupFrames.party.sortMethod", callback = function() UpdateGridSettingsAndRefreshPreview("party", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["groupFrames.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true, ["groupFrames.party.groupBy"] = {"CLASS", "GROUP", "NAME", "ROLE"}}})
    CreateClassSortebalList(party, "groupFrames.party.groupByClassOrder", "groupFrames.party.groupBy")
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
    p.preview:SetScript("OnClick", GridPreviewOnClick("partyPet"))
    p.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Party Pet Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.preview:SetScript("OnLeave", GameTooltip_Hide)
    p.preview:SetEnabled(GW.settings.groupFrames.partyPet.enabled)

    p:AddOptionNote(format(L["Group frames are disabled entirely: enable them under %s."], L["Group Frames"] .. " - " .. GENERAL), {
        isVisible = function() return GW.settings.groupFrames.enabled ~= true end,
        group = "gridPageNote",
    })
    p:AddOption(ENABLE, L["Show a separate grid for party pets"], {getterSetter = "groupFrames.partyPet.enabled", isMasterToggle = true, callback = function(value) p.preview:SetEnabled(value); GW.UpdateGridSettings("partyPet", nil, true) end, dependence = {["groupFrames.enabled"] = true}})
    p:AddOption(RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], {getterSetter = "groupFrames.partyPet.unitMarkers", callback = function() GW.UpdateGridSettings("partyPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridIcons"})

    p:AddOption(L["Shorten health values"], nil, {getterSetter = "groupFrames.partyPet.shortHealthValues", callback = function() GW.UpdateGridSettings("partyPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, hidden = not GW.Retail, group = "gridBars"})
    p:AddOption(L["Show absorb bar"], nil, {getterSetter = "groupFrames.partyPet.showAbsorbBar", callback = function() GW.UpdateGridSettings("partyPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "gridBars"})
    p:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "groupFrames.partyPet.unitHealth",
        callback = function() GW.UpdateGridSettings("partyPet") end,
        optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH},
        dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true},
        group = "gridBars"
    })
    p:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "groupFrames.partyPet.healthBarTexture", callback = function() GW.UpdateGridSettings("partyPet") end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridBars"})

    p:AddOptionDropdown(L["Show Aura Tooltips"], L["Show tooltips of buffs and debuffs."], { getterSetter = "groupFrames.partyPet.auraTooltipInCombat", callback = function() GW.UpdateGridSettings("partyPet") end, optionsList = {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"}, optionNames = {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}, group = "gridMisc"})

    p:AddOption(L["Start Near Center"], L["The initial group will start near the center and grow out."], {getterSetter = "groupFrames.partyPet.anchorFromCenter", callback = function() GW.UpdateGridSettings("partyPet", true) end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true, ["PARTY_GRID_ACTIVE"] = true}, group = "gridLayout"})

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    -- retail only filter
    CreateAuraFilterSection(p, "partyPet", "groupFrames.partyPet.buffFilter", "groupFrames.partyPet.debuffFilter", "groupFrames.partyPet.showBuffs", "groupFrames.partyPet.showDebuffs", "groupFrames.partyPet.enabled")
    -- none retail debuff filter
    p:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "groupFrames.partyPet.onlyDispellableDebuffs", callback = function() GW.UpdateGridSettings("partyPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true, ["groupFrames.partyPet.showDebuffs"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    p:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "groupFrames.partyPet.showRaidInstanceDebuffs", callback = function() GW.UpdateGridSettings("partyPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})
    p:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "groupFrames.partyPet.pandemicHighlight", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.partyPet.enabled"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "groupFrames.partyPet.dispelIcon", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["groupFrames.partyPet.enabled"] = true}, hidden = not GW.Retail})
    CreateIgnoredAuraSection(p, "partyPet", "groupFrames.partyPet.ignoredAuras", "groupFrames.partyPet.enabled")

    --fader
    p:AddGroupHeader(L["Fader"])
    p:AddOption(L["Range"], nil, {getterSetter = "groupFrames.partyPet.faderRange", callback = function() GW.UpdateGridSettings("partyPet") end, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}, groupHeaderName = L["Fader"]})
    p:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "groupFrames.partyPet.fader",
        callback = function() GW.UpdateGridSettings("partyPet") end,
        optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"},
        optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]},
        dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true, ["groupFrames.partyPet.faderRange"] = false},
        checkbox = true,
        groupHeaderName = L["Fader"]
    })
    p:AddOptionSlider(L["Smooth"], nil, { getterSetter = "groupFrames.partyPet.fader.smooth", callback = function() UpdateGridSettingsThrottled("partyPet") end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "groupFrames.partyPet.fader.minAlpha", callback = function() UpdateGridSettingsThrottled("partyPet") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "groupFrames.partyPet.fader.maxAlpha", callback = function() UpdateGridSettingsThrottled("partyPet") end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}})

    -- Size and Positions
    p:AddGroupHeader( L["Size and Positions"])
    p:AddOptionDropdown(L["Set Raid Growth Direction"], L["Set the grow direction for raid frames."], { getterSetter = "groupFrames.partyPet.grow", callback = function() GW.UpdateGridSettings("partyPet", true) end, optionsList = grow, optionNames = MapTable(
        grow,
        function(dir)
            local g1, g2 = strsplit("+", dir)
            return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
        end
   ), dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}})

    p:AddOptionSlider(L["Set Raid Unit Width"], L["Set the width of the raid units."], { getterSetter = "groupFrames.partyPet.width", callback = function() UpdateGridSettingsThrottled("partyPet", false, true) end, min = 45, max = 300, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionSlider(L["Set Raid Unit Height"], L["Set the height of the raid units."], { getterSetter = "groupFrames.partyPet.height", callback = function() UpdateGridSettingsThrottled("partyPet", false, true) end, min = 15, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "groupFrames.partyPet.horizontalSpacing", callback = function() UpdateGridSettingsThrottled("partyPet", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "groupFrames.partyPet.verticalSpacing", callback = function() UpdateGridSettingsThrottled("partyPet", true) end, min = -1, max = 100, decimalNumbers = 0, step = 1, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}})

    -- Sorting
    p:AddGroupHeader(L["Grouping & Sorting"])
    p:AddOptionDropdown(L["Sort Direction"], nil, { getterSetter = "groupFrames.partyPet.sortDirection", callback = function() UpdateGridSettingsAndRefreshPreview("partyPet", true) end, optionsList = {"ASC", "DESC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}})
    p:AddOptionDropdown(L["Sort Method"], nil, { getterSetter = "groupFrames.partyPet.sortMethod", callback = function() UpdateGridSettingsAndRefreshPreview("partyPet", true) end, optionsList = {"INDEX", "NAME"}, optionNames = {L["Index"], NAME}, dependence = {["groupFrames.enabled"] = true, ["groupFrames.partyPet.enabled"] = true,  ["PARTY_GRID_ACTIVE"] = true}})

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
