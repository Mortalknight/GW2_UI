local _, GW = ...
local GW_UF = GW.oUF
local GetSetting = GW.GetSetting
local FillTable = GW.FillTable
local INDICATORS = GW.INDICATORS

local headers = {}

local profiles = {
    PARTY = {
        name = "Party",
        visibility = '[group:raid][nogroup] hide; [group:party][nogroup] show;hide',
        numGroups = 1
    },
    RAID_PET = {
        name = "RaidPet",
        visibility = '[group:raid] show; hide',
        numGroups = 8
    },
    RAID40 = {
        name = "Raid40",
        size = 40,
        visibility = '[group:raid] show; hide',
        numGroups = 8
    },
}

--SecureCmdOptionParse("[group:raid][nogroup] hide; [group:party][nogroup] show;hide")
--SecureCmdOptionParse("[group:raid] show; hide")
--SecureCmdOptionParse("[@raid1,noexists][@raid21,exists] hide;show")
local DIRECTION_TO_POINT = {
	["DOWN+RIGHT"] = 'TOP',
	["DOWN+LEFT"] = 'TOP',
	["UP+RIGHT"] = 'BOTTOM',
	["UP+LEFT"] = 'BOTTOM',
	["RIGHT+DOWN"] = 'LEFT',
	["RIGHT+UP"] = 'LEFT',
	["LEFT+DOWN"] = 'RIGHT',
	["LEFT+UP"] = 'RIGHT'
}

local DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	["DOWN+RIGHT"] = 'LEFT',
	["DOWN+LEFT"] = 'RIGHT',
	["UP+RIGHT"] = 'LEFT',
	["UP+LEFT"] = 'RIGHT',
	["RIGHT+DOWN"] = 'TOP',
	["RIGHT+UP"] = 'BOTTOM',
	["LEFT+DOWN"] = 'TOP',
	["LEFT+UP"] = 'BOTTOM',
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	["DOWN+RIGHT"] = 1,
	["DOWN+LEFT"] = -1,
	["UP+RIGHT"] = 1,
	["UP+LEFT"] = -1,
	["RIGHT+DOWN"] = 1,
	["RIGHT+UP"] = 1,
	["LEFT+DOWN"] = -1,
	["LEFT+UP"] = -1,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	["DOWN+RIGHT"] = -1,
	["DOWN+LEFT"] = -1,
	["UP+RIGHT"] = 1,
	["UP+LEFT"] = 1,
	["RIGHT+DOWN"] = -1,
	["RIGHT+UP"] = 1,
	["LEFT+DOWN"] = -1,
	["LEFT+UP"] = 1,
}

local DIRECTION_TO_GROUP_ANCHOR_POINT = {
	["DOWN+RIGHT"] = 'TOPLEFT',
	["DOWN+LEFT"] = 'TOPRIGHT',
	["UP+RIGHT"] = 'BOTTOMLEFT',
	["UP+LEFT"] = 'BOTTOMRIGHT',
	["RIGHT+DOWN"] = 'TOPLEFT',
	["RIGHT+UP"] = 'BOTTOMLEFT',
	["LEFT+DOWN"] = 'TOPRIGHT',
	["LEFT+UP"] = 'BOTTOMRIGHT',
    ["OUT+RIGHT+UP"] = 'BOTTOM',
	["OUT+LEFT+UP"] = 'BOTTOM',
	["OUT+RIGHT+DOWN"] = 'TOP',
	["OUT+LEFT+DOWN"] = 'TOP',
	["OUT+UP+RIGHT"] = 'LEFT',
	["OUT+UP+LEFT"] = 'RIGHT',
	["OUT+DOWN+RIGHT"] = 'LEFT',
	["OUT+DOWN+LEFT"] = 'RIGHT',
}

local settings = {
    missing = {},
    ignored = {},
    raidClassColor = {},
    raidUnitHealthString = {},
    raidUnitFlag = {},
    raidUnitMarkers = {},
    raidUnitPowerBar = {},
    raidAuraTooltipInCombat = {},
    raidShowDebuffs = {},
    raidShowOnlyDispelDebuffs = {},
    raidShowImportendInstanceDebuffs = {},
    raidIndicators = {},

    raidWidth = {},
    raidHeight = {},
    startFromCenter = {},
    raidGrow = {},
    unitsPerColumn = {},
    raidWideSorting = {},
    groupBy = {},
    sortDirection = {},
    sortMethod = {}
}
GW.GridSettings = settings

local settingsEventFrame = CreateFrame("Frame")

local headerGroupBy = {
	CLASS = function(header, profile)
		local sortMethod = settings.sortMethod[profile]
		header:SetAttribute('groupingOrder', 'DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK')
		header:SetAttribute('sortMethod', sortMethod or 'NAME')
		header:SetAttribute('groupBy', 'CLASS')
	end,
	ROLE = function(header, profile)
		local sortMethod = settings.sortMethod[profile]
		header:SetAttribute('groupingOrder', 'TANK,HEALER,DAMAGER,NONE')
		header:SetAttribute('sortMethod', sortMethod or 'NAME')
		header:SetAttribute('groupBy', 'ASSIGNEDROLE')
	end,
	NAME = function(header)
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute('groupBy', nil)
	end,
	GROUP = function(header, profile)
		local sortMethod = settings.sortMethod[profile]
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', sortMethod or 'INDEX')
		header:SetAttribute('groupBy', 'GROUP')
	end,
	PETNAME = function(header)
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute('groupBy', nil)
		header:SetAttribute('filterOnPet', true) --This is the line that matters. Without this, it sorts based on the owners name
	end,
	INDEX = function(header)
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', 'INDEX')
		header:SetAttribute('groupBy', nil)
	end,
}

local function UpdateSettings(profile, onlyHeaderUpdate, updasteHeaderAndFrames)
    -- generell settings
    settings.raidDebuffScale = GetSetting("RAIDDEBUFFS_Scale")
    settings.raidDispelDebuffScale = GetSetting("DISPELL_DEBUFFS_Scale")
    settings.raidIndicatorIcon = GetSetting("INDICATORS_ICON")
    settings.raidIndicatorTime = GetSetting("INDICATORS_TIME")
    settings.aurasIgnored = GetSetting("AURAS_IGNORED")
    settings.aurasMissing = GetSetting("AURAS_MISSING")
    settings.missing = FillTable({}, true, strsplit(",", (settings.aurasMissing:trim():gsub("%s*,%s*", ","))))
    settings.ignored = FillTable({}, true, strsplit(",", (settings.aurasIgnored:trim():gsub("%s*,%s*", ","))))

    for _, pos in ipairs(INDICATORS) do
        settings.raidIndicators[pos] = GetSetting("INDICATOR_" .. pos, true)
    end

    -- profile settings for the unitframes
    settings.raidClassColor.PARTY = GetSetting("RAID_CLASS_COLOR_PARTY")
    settings.raidClassColor.RAID_PET = GetSetting("RAID_CLASS_COLOR_PET")
    settings.raidClassColor.RAID40 = GetSetting("RAID_CLASS_COLOR")

    settings.raidUnitHealthString.PARTY = GetSetting("RAID_UNIT_HEALTH_PARTY")
    settings.raidUnitHealthString.RAID_PET = GetSetting("RAID_UNIT_HEALTH_PET")
    settings.raidUnitHealthString.RAID40 = GetSetting("RAID_UNIT_HEALTH")

    settings.raidUnitFlag.PARTY = GetSetting("RAID_UNIT_FLAGS_PARTY")
    settings.raidUnitFlag.RAID_PET = GetSetting("RAID_UNIT_FLAGS_PET")
    settings.raidUnitFlag.RAID40 = GetSetting("RAID_UNIT_FLAGS")

    settings.raidUnitMarkers.PARTY = GetSetting("RAID_UNIT_MARKERS_PARTY")
    settings.raidUnitMarkers.RAID_PET = GetSetting("RAID_UNIT_MARKERS_PET")
    settings.raidUnitMarkers.RAID40 = GetSetting("RAID_UNIT_MARKERS")

    settings.raidUnitPowerBar.PARTY = GetSetting("RAID_POWER_BARS_PARTY")
    settings.raidUnitPowerBar.RAID_PET = GetSetting("RAID_POWER_BARS_PET")
    settings.raidUnitPowerBar.RAID40 = GetSetting("RAID_POWER_BARS")

    settings.raidAuraTooltipInCombat.PARTY = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT_PARTY")
    settings.raidAuraTooltipInCombat.RAID_PET = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT_PET")
    settings.raidAuraTooltipInCombat.RAID40 = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT")

    settings.raidShowDebuffs.PARTY = GetSetting("RAID_SHOW_DEBUFFS_PARTY")
    settings.raidShowDebuffs.RAID_PET = GetSetting("RAID_SHOW_DEBUFFS_PET")
    settings.raidShowDebuffs.RAID40 = GetSetting("RAID_SHOW_DEBUFFS")

    settings.raidShowOnlyDispelDebuffs.PARTY = GetSetting("RAID_ONLY_DISPELL_DEBUFFS_PARTY")
    settings.raidShowOnlyDispelDebuffs.RAID_PET = GetSetting("RAID_ONLY_DISPELL_DEBUFFS_PET")
    settings.raidShowOnlyDispelDebuffs.RAID40 = GetSetting("RAID_ONLY_DISPELL_DEBUFFS")

    settings.raidShowImportendInstanceDebuffs.PARTY = GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PARTY")
    settings.raidShowImportendInstanceDebuffs.RAID_PET = GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PET")
    settings.raidShowImportendInstanceDebuffs.RAID40 = GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF")

    settings.raidWidth.PARTY = tonumber(GetSetting("RAID_WIDTH_PARTY"))
    settings.raidWidth.RAID_PET = tonumber(GetSetting("RAID_WIDTH_PET"))
    settings.raidWidth.RAID40 = tonumber(GetSetting("RAID_WIDTH"))

    settings.raidHeight.PARTY = tonumber(GetSetting("RAID_HEIGHT_PARTY"))
    settings.raidHeight.RAID_PET = tonumber(GetSetting("RAID_HEIGHT_PET"))
    settings.raidHeight.RAID40 = tonumber(GetSetting("RAID_HEIGHT"))

    -- profile settings for the header
    settings.startFromCenter.PARTY = GetSetting("UNITFRAME_ANCHOR_FROM_CENTER_PARTY")
    settings.startFromCenter.RAID_PET = GetSetting("UNITFRAME_ANCHOR_FROM_CENTER_PET")
    settings.startFromCenter.RAID40 = GetSetting("UNITFRAME_ANCHOR_FROM_CENTER")

    settings.raidGrow.PARTY = GetSetting("RAID_GROW_PARTY")
    settings.raidGrow.RAID_PET = GetSetting("RAID_GROW_PET")
    settings.raidGrow.RAID40 = GetSetting("RAID_GROW")

    settings.unitsPerColumn.PARTY = tonumber(GetSetting("RAID_UNITS_PER_COLUMN_PARTY"))
    settings.unitsPerColumn.RAID_PET = tonumber(GetSetting("RAID_UNITS_PER_COLUMN_PET"))
    settings.unitsPerColumn.RAID40 = tonumber(GetSetting("RAID_UNITS_PER_COLUMN"))

    settings.raidWideSorting.PARTY = GetSetting("RAID_WIDE_SORTING_PARTY")
    settings.raidWideSorting.RAID_PET = GetSetting("RAID_WIDE_SORTING_PET")
    settings.raidWideSorting.RAID40 = GetSetting("RAID_WIDE_SORTING")

    settings.groupBy.PARTY = GetSetting("RAID_GROUP_BY_PARTY")
    settings.groupBy.RAID_PET = GetSetting("RAID_GROUP_BY_PET")
    settings.groupBy.RAID40 = GetSetting("RAID_GROUP_BY")

    settings.sortDirection.PARTY = GetSetting("RAID_SORT_DIRECTION_PARTY")
    settings.sortDirection.RAID_PET = GetSetting("RAID_SORT_DIRECTION_PET")
    settings.sortDirection.RAID40 = GetSetting("RAID_SORT_DIRECTION")

    settings.sortMethod.PARTY = GetSetting("RAID_RAID_SORT_METHOD_PARTY")
    settings.sortMethod.RAID_PET = GetSetting("RAID_RAID_SORT_METHOD_PET")
    settings.sortMethod.RAID40 = GetSetting("RAID_RAID_SORT_METHOD")

    -- Update this settings on a spec switch
    if not settingsEventFrame.isSetup then
        settingsEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        settingsEventFrame:SetScript("OnEvent", function()
            UpdateSettings(profile, false, true)
        end)

        settingsEventFrame.isSetup = true
    end

    if not onlyHeaderUpdate or updasteHeaderAndFrames then
        for headerProfile, header in pairs(headers) do
            if headerProfile == profile then
                for i = 1, header.numGroups do
                    local group = header.groups[i]
                    for _, child in ipairs({ group:GetChildren() }) do
                        GW["UpdateGrid" ..  header.profileName .. "Frame"](child, header.groupName)
                    end
                end
            end
        end
    end

    if (onlyHeaderUpdate or updasteHeaderAndFrames) and headers[profile] then
        GW.UpdateGridHeader(profile)
    end
end
GW.UpdateGridSettings = UpdateSettings

local function CreateRaisedText(raised)
	local text = raised:CreateFontString(nil, 'OVERLAY')
	text:SetFont(UNIT_NAME_FONT, 11)
    text:SetShadowOffset(-1, -1)
    text:SetShadowColor(0, 0, 0, 1)

	return text
end
GW.CreateRaisedText = CreateRaisedText

local function CreateRaisedElement(frame)
	local raised = CreateFrame('Frame', nil, frame)
	local level = frame:GetFrameLevel() + 100
	raised:SetFrameLevel(level)
	raised.__owner = frame
	raised.TextureParent = CreateFrame('Frame', nil, raised)

	return raised
end
GW.CreateRaisedElement = CreateRaisedElement

local function UpdateGridHeader(profile)
    -- Update header values
    local header = headers[profile]
    if header.isUpdating then return end
    header.isUpdating = true

    local x, y = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[settings.raidGrow[profile]], DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[settings.raidGrow[profile]]
    local numGroups = header.numGroups
    local isParty = profile == "PARTY"
    local groupsPerRowCol = 1
    local width, height, newCols, newRows = 0, 0, 0, 0
    local groupSpacing = 0
    local horizontalSpacing = 2
    local verticalSpacing = 2
    local WIDTH = GW.Scale(settings.raidWidth[profile]) + horizontalSpacing
    local HEIGHT = GW.Scale(settings.raidHeight[profile]) + verticalSpacing
    local HEIGHT_FIVE = HEIGHT * 5
    local WIDTH_FIVE = WIDTH * 5
    local groupBy = settings.groupBy[profile]
    local sortDirection = settings.sortDirection[profile]
    local raidWideSorting = settings.raidWideSorting[profile]

    for i = 1, numGroups do
        local group = header.groups[i]
        local lastIndex = i - 1
        local lastGroup = lastIndex % groupsPerRowCol

        if group then
            group:ClearAllPoints()

            local idx = 1
            local child = group:GetAttribute('child'..idx)
            while child do
                child:ClearAllPoints()
                idx = idx + 1
                child = group:GetAttribute('child'..idx)
            end


            local point = DIRECTION_TO_POINT[settings.raidGrow[profile]]
            group:SetAttribute('point', point)

            if point == 'LEFT' or point == 'RIGHT' then
                group:SetAttribute('xOffset', horizontalSpacing * x)
                group:SetAttribute('yOffset', 0)
                group:SetAttribute('columnSpacing', verticalSpacing)
            else
                group:SetAttribute('xOffset', 0)
                group:SetAttribute('yOffset', verticalSpacing * y)
                group:SetAttribute('columnSpacing', horizontalSpacing)
            end

            if not group.initialized then
                group:SetAttribute('startingIndex', raidWideSorting and (-min(numGroups * (groupsPerRowCol * 5), MAX_RAID_MEMBERS) + 1) or -4)
                group:Show()
                group.initialized = true
            end
            group:SetAttribute('startingIndex', 1)

            group:SetAttribute('columnAnchorPoint', DIRECTION_TO_COLUMN_ANCHOR_POINT[settings.raidGrow[profile]])

            group:SetAttribute('maxColumns', raidWideSorting and numGroups or 1)
            if profile == "PARTY" or (profile ~= "PARTY" and raidWideSorting) then
                group:SetAttribute('unitsPerColumn', settings.unitsPerColumn[profile])
            else
                group:SetAttribute('unitsPerColumn', 5)
            end

            group:SetAttribute('showPlayer', true)
            group:SetAttribute('sortDir', sortDirection)
            -- sorting
            if profile == "RAID_PET" then
                headerGroupBy.PETNAME(group)
            else
                local func = headerGroupBy[groupBy] or headerGroupBy.INDEX
                func(group, profile)
            end

            local groupWide = i == 1 and raidWideSorting and strsub('1,2,3,4,5,6,7,8', 1, numGroups + numGroups-1)
            group:SetAttribute('groupFilter', groupWide or tostring(i))

            -- register the correct visibility state driver
            if numGroups > 1 and i > 1 then
                if raidWideSorting then
                    RegisterStateDriver(group, 'visibility', "hide")
                else
                    RegisterStateDriver(group, 'visibility', "show")
                end
            elseif profile == "PARTY" then
                if not GetSetting("RAID_STYLE_PARTY") and not GetSetting("RAID_STYLE_PARTY_AND_FRAMES") then
                    RegisterStateDriver(group, 'visibility', "hide")
                else
                    RegisterStateDriver(group, 'visibility', profiles.PARTY.visibility)
                end
            end
        end

        local point = DIRECTION_TO_GROUP_ANCHOR_POINT[settings.raidGrow[profile]]
        if (isParty or raidWideSorting) and settings.startFromCenter[profile] then
			point = DIRECTION_TO_GROUP_ANCHOR_POINT['OUT+' .. settings.raidGrow[profile]]
		end

        if lastGroup == 0 then
            if DIRECTION_TO_POINT[settings.raidGrow[profile]] == 'LEFT' or DIRECTION_TO_POINT[settings.raidGrow[profile]] == 'RIGHT' then
                if group then group:SetPoint(point, header, point, 0, height * y) end
                height = height + HEIGHT + groupSpacing
                newRows = newRows + 1
            else
                if group then group:SetPoint(point, header, point, width * x, 0) end
                width = width + WIDTH + groupSpacing
                newCols = newCols + 1
            end
        else
            if DIRECTION_TO_POINT[settings.raidGrow[profile]] == 'LEFT' or DIRECTION_TO_POINT[settings.raidGrow[profile]] == 'RIGHT' then
                if newRows == 1 then
                    if group then group:SetPoint(point, header, point, width * x, 0) end
                    width = width + WIDTH_FIVE + groupSpacing
                    newCols = newCols + 1
                elseif group then
                    group:SetPoint(point, header, point, ((WIDTH_FIVE * lastGroup) + lastGroup * groupSpacing) * x, ((HEIGHT + groupSpacing) * (newRows - 1)) * y)
                end
            else
                if newCols == 1 then
                    if group then group:SetPoint(point, header, point, 0, height * y) end
                    height = height + HEIGHT_FIVE + groupSpacing
                    newRows = newRows + 1
                elseif group then
                    group:SetPoint(point, header, point, ((WIDTH + groupSpacing) * (newCols - 1)) * x, ((HEIGHT_FIVE * lastGroup) + lastGroup * groupSpacing) * y)
                end
            end
        end

        if profile == "PARTY" then
            height = HEIGHT * settings.unitsPerColumn[profile]
            width = WIDTH * (math.floor(5 / settings.unitsPerColumn[profile]))
        else
            if height == 0 then height = height + HEIGHT_FIVE + groupSpacing end
            if width == 0 then width = width + WIDTH_FIVE + groupSpacing end
        end
    end

    header:SetSize(width - horizontalSpacing - groupSpacing, height - verticalSpacing - groupSpacing)
    header.gwMover:SetSize(width - horizontalSpacing - groupSpacing, height - verticalSpacing - groupSpacing)

    header.isUpdating = false
end
GW.UpdateGridHeader = UpdateGridHeader

local function CreateHeader(parent, options, overrideName, groupFilter)
    parent:SetActiveStyle('GW2_Grid' .. options.name)

    local header = parent:SpawnHeader(overrideName, (options.name == "RaidPet" and "SecureGroupPetHeaderTemplate" or nil), "custom " .. options.visibility,
        'showParty', true,
        'showRaid', options.name ~= "Party",
        'showPlayer', true,
        'groupFilter', groupFilter,
        'groupingOrder', "1,2,3,4,5,6,7,8",
        'oUF-initialConfigFunction', [[
            self:SetHeight(19)
            self:SetWidth(126)
        ]]
    )

    return header
end

local function Setup(self)
    -- create headers and groups for all profiles
    for profile, options in pairs(profiles) do
        self:RegisterStyle('GW2_Grid' .. options.name, GW['GW2_Grid' .. options.name .. "StyleRegister"])
        self:SetActiveStyle('GW2_Grid' .. options.name)

        -- Create a holding header
        local Header = CreateFrame('Frame', "GW2_" .. options.name .. 'GridContainer', UIParent, 'SecureHandlerStateTemplate')
        Header.groups = {}
        Header.groupName = profile
        Header.numGroups = options.numGroups
        Header.profileName = options.name
        headers[profile] = Header

        Header.groups[1] = CreateHeader(self, options, "GW2_" .. options.name .. "Group1")

        while options.numGroups > #Header.groups do
            local index = tostring(#Header.groups + 1)
            tinsert(Header.groups, CreateHeader(self, options, "GW2_" .. options.name .. "Group" .. index, index))
        end

        if profile == "RAID_PET" and not GetSetting("RAID_PET_FRAMES") then
            options.visibility = 'hide'
        end
        if profile == "PARTY" then
            if not GetSetting("RAID_STYLE_PARTY") and not GetSetting("RAID_STYLE_PARTY_AND_FRAMES") then
                options.visibility = 'hide'
            end
        end

        RegisterStateDriver(Header, 'visibility', options.visibility)

        -- movable frame for the container
        if profile == "PARTY" then
            GW.RegisterMovableFrame(Header, GW.L["Group Frames"], "raid_party_pos",  ALL .. ",Unitframe,Group", nil, {"default", "default"})
        elseif profile == "RAID_PET" then
            GW.RegisterMovableFrame(Header, GW.L["Raid pet's Grid"], "raid_pet_pos",  ALL .. ",Unitframe,Rid", nil, {"default", "default"})
        else
            GW.RegisterMovableFrame(Header, RAID_FRAMES_LABEL .. ": " .. options.size, "raid_pos",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})
        end

        Header:ClearAllPoints()
        Header:SetPoint("TOPLEFT", Header.gwMover)

        UpdateGridHeader(profile)
    end

    C_Timer.After(0, function()
        for profile, _ in pairs(profiles) do
            UpdateSettings(profile)
        end
    end)
end
local function Initialize()
    if not GwManageGroupButton then
        GW.manageButton()
    end

    for profile, _ in pairs(profiles) do
        UpdateSettings(profile)
    end

    GW.Create_Tags()
    GW_UF:Factory(Setup)



    --needed later
    --[[
    GwSettingsWindowMoveHud:HookScript("OnClick", function ()
        GW.GridToggleFramesPreviewRaid(true, true)
        GW.GridToggleFramesPreviewParty(true, true)
    end)
    GwSmallSettingsContainer.moverSettingsFrame.defaultButtons.lockHud:HookScript("OnClick", function()
        GW.GridToggleFramesPreviewRaid(true, true)
        GW.GridToggleFramesPreviewParty(true, true)
    end)
    ]]
end
GW.InitializeRaidFrames = Initialize