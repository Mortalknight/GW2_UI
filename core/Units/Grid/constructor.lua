local _, GW = ...
local GW_UF = GW.oUF

local headers = {}
GW.GridGroupHeaders = headers

local profiles = {
    PARTY = {
        name = "Party",
        visibility = "[@raid1,exists][@party1,noexists] hide;show",
        numGroups = 1,
        styleFunc = GW.GridPartyStyleRegister,
        updateFunc = GW.UpdateGridPartyFrame
    },
    RAID_PET = {
        name = "RaidPet",
        visibility = "[@raid1,exists] show; hide",
        numGroups = 8,
        styleFunc = GW.GridRaidPetStyleRegister,
        updateFunc = GW.UpdateGridRaidPetFrame
    },
    RAID40 = {
        name = "Raid40",
        size = 40,
        visibility = "[@raid26,noexists] hide; show",
        visibilityAll = "[group:raid] show;hide",
        visibilityIncl25 = "[@raid11,noexists] hide; show",
        numGroups = 8,
        styleFunc = GW.GridRaid40StyleRegister,
        updateFunc = GW.UpdateGridRaid40Frame
    },
    RAID25 = {
        name = "Raid25",
        size = 25,
        visibility = "[@raid11,noexists][@raid26,exists] hide;show",
        visibilityIncl10 = "[@raid1,noexists][@raid26,exists] hide; show",
        numGroups = 5,
        styleFunc = GW.GridRaid25StyleRegister,
        updateFunc = GW.UpdateGridRaid25Frame
    },
    RAID10 = {
        name = "Raid10",
        size = 10,
        visibility = "[@raid1,noexists][@raid11,exists] hide;show",
        numGroups = 5,
        styleFunc = GW.GridRaid10StyleRegister,
        updateFunc = GW.UpdateGridRaid10Frame
    },
    TANK = {
        name = "Maintank",
        visibility = "[group:raid] show; hide",
        numGroups = 1,
        styleFunc = GW.GridMaintankStyleRegister,
        updateFunc = GW.UpdateGridMaintankFrame
    },
}


--SecureCmdOptionParse("[@raid1,noexists][@raid11,exists] hide;show")
--SecureCmdOptionParse("[@raid11,noexists][@raid26,exists] hide;show")
--SecureCmdOptionParse("[@raid1,exists][@party1,noexists] hide;show")
local DIRECTION_TO_POINT = {
	["DOWN+RIGHT"] = "TOP",
	["DOWN+LEFT"] = "TOP",
	["UP+RIGHT"] = "BOTTOM",
	["UP+LEFT"] = "BOTTOM",
	["RIGHT+DOWN"] = "LEFT",
	["RIGHT+UP"] = "LEFT",
	["LEFT+DOWN"] = "RIGHT",
	["LEFT+UP"] = "RIGHT"
}

local DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	["DOWN+RIGHT"] = "LEFT",
	["DOWN+LEFT"] = "RIGHT",
	["UP+RIGHT"] = "LEFT",
	["UP+LEFT"] = "RIGHT",
	["RIGHT+DOWN"] = "TOP",
	["RIGHT+UP"] = "BOTTOM",
	["LEFT+DOWN"] = "TOP",
	["LEFT+UP"] = "BOTTOM",
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
	["DOWN+RIGHT"] = "TOPLEFT",
	["DOWN+LEFT"] = "TOPRIGHT",
	["UP+RIGHT"] = "BOTTOMLEFT",
	["UP+LEFT"] = "BOTTOMRIGHT",
	["RIGHT+DOWN"] = "TOPLEFT",
	["RIGHT+UP"] = "BOTTOMLEFT",
	["LEFT+DOWN"] = "TOPRIGHT",
	["LEFT+UP"] = "BOTTOMRIGHT",
    ["OUT+RIGHT+UP"] = "BOTTOM",
	["OUT+LEFT+UP"] = "BOTTOM",
	["OUT+RIGHT+DOWN"] = "TOP",
	["OUT+LEFT+DOWN"] = "TOP",
	["OUT+UP+RIGHT"] = "LEFT",
	["OUT+UP+LEFT"] = "RIGHT",
	["OUT+DOWN+RIGHT"] = "LEFT",
	["OUT+DOWN+LEFT"] = "RIGHT",
}

local settings = {
    enabled = {},
    groupSpacing = {},
    horizontalSpacing = {},
    verticalSpacing = {},
    raidWidth = {},
    raidHeight = {},
    startFromCenter = {},
    raidGrow = {},
    groupsPerColumnRow = {},
    raidWideSorting = {},
    groupBy = {},
    sortDirection = {},
    sortMethod = {}
}
GW.GridSettings = settings

local settingsEventFrame = CreateFrame("Frame")
local pendingProfiles = {}

-- Helper-only mapping to simplify future settings updates (not wired yet).
local SETTINGS_HELPER_MAP = {
    enabled = {
        PARTY = "RAID_STYLE_PARTY",
        RAID_PET = "RAID_PET_FRAMES",
        RAID40 = "RAID_FRAMES",
        RAID25 = "RAID25_ENABLED",
        RAID10 = "RAID10_ENABLED",
        TANK = "RAID_MAINTANK_FRAMES_ENABLED",
    },
    horizontalSpacing = {
        PARTY = "RAID_UNITS_HORIZONTAL_SPACING_PARTY",
        RAID_PET = "RAID_UNITS_HORIZONTAL_SPACING_PET",
        RAID40 = "RAID_UNITS_HORIZONTAL_SPACING",
        RAID25 = "RAID_UNITS_HORIZONTAL_SPACING_RAID25",
        RAID10 = "RAID_UNITS_HORIZONTAL_SPACING_RAID10",
        TANK = "RAID_UNITS_HORIZONTAL_SPACING_TANK",
    },
    verticalSpacing = {
        PARTY = "RAID_UNITS_VERTICAL_SPACING_PARTY",
        RAID_PET = "RAID_UNITS_VERTICAL_SPACING_PET",
        RAID40 = "RAID_UNITS_VERTICAL_SPACING",
        RAID25 = "RAID_UNITS_VERTICAL_SPACING_RAID25",
        RAID10 = "RAID_UNITS_VERTICAL_SPACING_RAID10",
        TANK = "RAID_UNITS_VERTICAL_SPACING_TANK",
    },
    groupSpacing = {
        PARTY = "RAID_UNITS_GROUP_SPACING_PARTY",
        RAID_PET = "RAID_UNITS_GROUP_SPACING_PET",
        RAID40 = "RAID_UNITS_GROUP_SPACING",
        RAID25 = "RAID_UNITS_GROUP_SPACING_RAID25",
        RAID10 = "RAID_UNITS_GROUP_SPACING_RAID10",
        TANK = "RAID_UNITS_GROUP_SPACING_TANK",
    },
    raidWidth = {
        PARTY = "RAID_WIDTH_PARTY",
        RAID_PET = "RAID_WIDTH_PET",
        RAID40 = "RAID_WIDTH",
        RAID25 = "RAID_WIDTH_RAID25",
        RAID10 = "RAID_WIDTH_RAID10",
        TANK = "RAID_WIDTH_TANK",
    },
    raidHeight = {
        PARTY = "RAID_HEIGHT_PARTY",
        RAID_PET = "RAID_HEIGHT_PET",
        RAID40 = "RAID_HEIGHT",
        RAID25 = "RAID_HEIGHT_RAID25",
        RAID10 = "RAID_HEIGHT_RAID10",
        TANK = "RAID_HEIGHT_TANK",
    },
    startFromCenter = {
        PARTY = "UNITFRAME_ANCHOR_FROM_CENTER_PARTY",
        RAID_PET = "UNITFRAME_ANCHOR_FROM_CENTER_PET",
        RAID40 = "UNITFRAME_ANCHOR_FROM_CENTER",
        RAID25 = "UNITFRAME_ANCHOR_FROM_CENTER_RAID25",
        RAID10 = "UNITFRAME_ANCHOR_FROM_CENTER_RAID10",
        TANK = "UNITFRAME_ANCHOR_FROM_CENTER_TANK",
    },
    raidGrow = {
        PARTY = "RAID_GROW_PARTY",
        RAID_PET = "RAID_GROW_PET",
        RAID40 = "RAID_GROW",
        RAID25 = "RAID_GROW_RAID25",
        RAID10 = "RAID_GROW_RAID10",
        TANK = "RAID_GROW_TANK",
    },
    groupsPerColumnRow = {
        PARTY = "RAID_GROUPS_PER_COLUMN_PARTY",
        RAID_PET = "RAID_GROUPS_PER_COLUMN_PET",
        RAID40 = "RAID_GROUPS_PER_COLUMN",
        RAID25 = "RAID_GROUPS_PER_COLUMN_RAID25",
        RAID10 = "RAID_GROUPS_PER_COLUMN_RAID10",
        TANK = "RAID_GROUPS_PER_COLUMN_TANK",
    },
    raidWideSorting = {
        PARTY = "RAID_WIDE_SORTING_PARTY",
        RAID_PET = "RAID_WIDE_SORTING_PET",
        RAID40 = "RAID_WIDE_SORTING",
        RAID25 = "RAID_WIDE_SORTING_RAID25",
        RAID10 = "RAID_WIDE_SORTING_RAID10",
        TANK = "RAID_WIDE_SORTING_TANK",
    },
    groupBy = {
        PARTY = "RAID_GROUP_BY_PARTY",
        RAID_PET = "RAID_GROUP_BY_PET",
        RAID40 = "RAID_GROUP_BY",
        RAID25 = "RAID_GROUP_BY_RAID25",
        RAID10 = "RAID_GROUP_BY_RAID10",
        TANK = "RAID_GROUP_BY_TANK",
    },
    sortDirection = {
        PARTY = "RAID_SORT_DIRECTION_PARTY",
        RAID_PET = "RAID_SORT_DIRECTION_PET",
        RAID40 = "RAID_SORT_DIRECTION",
        RAID25 = "RAID_SORT_DIRECTION_RAID25",
        RAID10 = "RAID_SORT_DIRECTION_RAID10",
        TANK = "RAID_SORT_DIRECTION_TANK",
    },
    sortMethod = {
        PARTY = "RAID_RAID_SORT_METHOD_PARTY",
        RAID_PET = "RAID_RAID_SORT_METHOD_PET",
        RAID40 = "RAID_RAID_SORT_METHOD",
        RAID25 = "RAID_RAID_SORT_METHOD_RAID25",
        RAID10 = "RAID_RAID_SORT_METHOD_RAID10",
        TANK = "RAID_RAID_SORT_METHOD_TANK",
    },
}

local SETTINGS_HELPER_TONUMBER = {
    raidWidth = true,
    raidHeight = true,
    groupsPerColumnRow = true,
}

local function ApplySettings()
    for settingName, mapping in pairs(SETTINGS_HELPER_MAP) do
        local target = settings[settingName]
        if target then
            local needsNumber = SETTINGS_HELPER_TONUMBER[settingName]
            for profile, gwKey in pairs(mapping) do
                local value = GW.settings[gwKey]
                if needsNumber then
                    value = tonumber(value)
                end
                target[profile] = value
            end
        end
    end

    settings.partyGridShowPlayer = GW.settings.RAID_SHOW_PLAYER_PARTY
end

local function MarkPending(profile)
    settingsEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    if profile == "ALL" then
        pendingProfiles.ALL = true
    else
        pendingProfiles[profile] = true
    end
end

local headerGroupBy = {
	CLASS = function(header, profile)
		local sortMethod = settings.sortMethod[profile]
		header:SetAttribute("groupingOrder", "DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK")
		header:SetAttribute("sortMethod", sortMethod or "NAME")
		header:SetAttribute("groupBy", "CLASS")
	end,
	ROLE = function(header, profile)
		local sortMethod = settings.sortMethod[profile]
		header:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		header:SetAttribute("sortMethod", sortMethod or "NAME")
		header:SetAttribute("groupBy", "ASSIGNEDROLE")
	end,
	NAME = function(header, profile)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", nil)
	end,
	GROUP = function(header, profile)
		local sortMethod = settings.sortMethod[profile]
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", sortMethod or "INDEX")
		header:SetAttribute("groupBy", "GROUP")
	end,
	PETNAME = function(header, profile)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", nil)
		header:SetAttribute("filterOnPet", true) --This is the line that matters. Without this, it sorts based on the owners name
	end,
	INDEX = function(header, profile)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "INDEX")
		header:SetAttribute("groupBy", nil)
	end,
    TANK = function(header, profile)
        header:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		header:SetAttribute("sortMethod", "INDEX")
		header:SetAttribute("groupBy", nil)
        header:SetAttribute("groupFilter", "MAINTANK")
    end,
}

local function UpdateFramesAndHeader(profile, onlyHeaderUpdate, updateHeaderAndFrames, skipSettings)
    if GW.disableGridUpdate then return end

    if not skipSettings then
        ApplySettings()
    end

    -- Update this settings on a spec switch
    if not settingsEventFrame.isSetup then
        settingsEventFrame:SetScript("OnEvent", function(_, event)
            if event == "PLAYER_REGEN_ENABLED" then
                if pendingProfiles.ALL then
                    UpdateFramesAndHeader("ALL", false, true)
                else
                    for pendingProfile, _ in pairs(pendingProfiles) do
                        UpdateFramesAndHeader(pendingProfile, false, true)
                    end
                end

                wipe(pendingProfiles)
                settingsEventFrame:UnregisterEvent(event)
            end
        end)

        settingsEventFrame.isSetup = true
    end

    if not onlyHeaderUpdate or updateHeaderAndFrames then
        if InCombatLockdown() then
            MarkPending(profile)
        end
        for headerProfile, header in pairs(headers) do
            if profile == "ALL" or headerProfile == profile then
                for i = 1, header.numGroups do
                    local group = header.groups[i]
                    for _, child in ipairs({ group:GetChildren() }) do
                        header.updateFunc(child)
                    end
                end
            end
        end
    end

    if (onlyHeaderUpdate or updateHeaderAndFrames) and (headers[profile] or profile == "ALL") then
        if InCombatLockdown() then
            MarkPending(profile)
        else
            if profile == "ALL" then
                for headerProfile, _ in pairs(headers) do
                    GW.UpdateGridHeader(headerProfile)
                end
            else
                GW.UpdateGridHeader(profile)
            end
        end
    end
end
GW.UpdateGridSettings = UpdateFramesAndHeader

local function GetGroupHeaderForProfile(profile)
    for headerProfile, header in pairs(GW.GridGroupHeaders) do
        if headerProfile == profile then
            return header
        end
    end

    return nil
end
GW.GetGroupHeaderForProfile = GetGroupHeaderForProfile

local function CreateRaisedText(raised)
	local text = raised:CreateFontString(nil, "OVERLAY")
	text:SetFont(UNIT_NAME_FONT, 11)
    text:SetShadowOffset(-1, -1)
    text:SetShadowColor(0, 0, 0, 1)

	return text
end
GW.CreateRaisedText = CreateRaisedText

local function CreateRaisedElement(frame)
	local raised = CreateFrame("Frame", nil, frame)
	local level = frame:GetFrameLevel() + 100
	raised:SetFrameLevel(level)
	raised.__owner = frame
	raised.TextureParent = CreateFrame("Frame", nil, raised)

	return raised
end
GW.CreateRaisedElement = CreateRaisedElement

local function GetHeaderVisibility(profile)
    if profile == "RAID40" then
        if not GW.settings.RAID_FRAMES then
            return "hide"
        end
        if GW.settings.RAID25_ENABLED then
            return GW.settings.RAID10_ENABLED and profiles.RAID40.visibility or profiles.RAID40.visibilityIncl25
        end
        return GW.settings.RAID10_ENABLED and profiles.RAID40.visibilityIncl25 or profiles.RAID40.visibilityAll
    elseif profile == "RAID25" then
        if not GW.settings.RAID25_ENABLED then
            return "hide"
        end
        return GW.settings.RAID10_ENABLED and profiles.RAID25.visibility or profiles.RAID25.visibilityIncl10
    elseif profile == "RAID10" then
        return GW.settings.RAID10_ENABLED and profiles.RAID10.visibility or "hide"
    elseif profile == "RAID_PET" then
        return GW.settings.RAID_PET_FRAMES and profiles.RAID_PET.visibility or "hide"
    end

    return nil
end

local function UpdateGroupVisibility(header, profile, enabled)
    if not header.isForced then
        local numGroups = header.numGroups
        local raidWideSorting = settings.raidWideSorting[profile]
        local visibilityToUseForGroups
        local headerVisibility = GetHeaderVisibility(profile)

        if headerVisibility then
            RegisterStateDriver(header, "visibility", headerVisibility)
            if headerVisibility ~= "hide" then
                visibilityToUseForGroups = headerVisibility
            end
        end

        for i = 1, numGroups do
            local group = header.groups[i]
            if group then
                if enabled then
                    -- register the correct visibility state driver
                    if numGroups > 1 then
                        local groupVisibility = visibilityToUseForGroups
                        if i > 1 and raidWideSorting then
                            groupVisibility = "hide"
                        end
                        RegisterStateDriver(group, "visibility", groupVisibility)
                    end
                else
                    RegisterStateDriver(group, "visibility", "hide")
                end
            end
        end
    end
end
GW.UpdateGroupVisibility = UpdateGroupVisibility

local function UpdateGridHeader(profile)
    -- Update header values
    local header = headers[profile]
    if header.isUpdating then return end
    header.isUpdating = true
    local direction = settings.raidGrow[profile] or "DOWN+RIGHT"
    local point = DIRECTION_TO_POINT[direction]
    local x, y = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction], DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction]
    local numGroups = header.numGroups
    local isParty = profile == "PARTY"
    local groupsPerRowCol = isParty and 1 or tonumber(settings.groupsPerColumnRow[profile])
    local width, height, newCols, newRows = 0, 0, 0, 0
    local groupSpacing = tonumber(settings.groupSpacing[profile])
    local horizontalSpacing = tonumber(settings.horizontalSpacing[profile])
    local verticalSpacing = tonumber(settings.verticalSpacing[profile])
    local WIDTH = GW.Scale(settings.raidWidth[profile]) + horizontalSpacing
    local HEIGHT = GW.Scale(settings.raidHeight[profile]) + verticalSpacing
    local HEIGHT_FIVE = HEIGHT * 5
    local WIDTH_FIVE = WIDTH * 5
    local groupBy = settings.groupBy[profile]
    local sortDirection = settings.sortDirection[profile]
    local raidWideSorting = settings.raidWideSorting[profile]
    local showPlayer = true

    if isParty then
        showPlayer = settings.partyGridShowPlayer
    end

    for i = 1, numGroups do
        local group = header.groups[i]
        local lastIndex = i - 1
        local lastGroup = lastIndex % groupsPerRowCol

        if group then
            group:ClearAllPoints()

            local idx = 1
            local child = group:GetAttribute("child"..idx)
            while child do
                child:ClearAllPoints()
                idx = idx + 1
                child = group:GetAttribute("child"..idx)
            end

            group:SetAttribute("point", point)

            if point == "LEFT" or point == "RIGHT" then
                group:SetAttribute("xOffset", horizontalSpacing * x)
                group:SetAttribute("yOffset", 0)
                group:SetAttribute("columnSpacing", verticalSpacing)
            else
                group:SetAttribute("xOffset", 0)
                group:SetAttribute("yOffset", verticalSpacing * y)
                group:SetAttribute("columnSpacing", horizontalSpacing)
            end

            if not group.isForced then
                if not group.initialized then
                    group:SetAttribute("startingIndex", raidWideSorting and (-min(numGroups * (groupsPerRowCol * 5), MAX_RAID_MEMBERS) + 1) or -4)
                    group:Show()
                    group.initialized = true
                end
                group:SetAttribute("startingIndex", 1)
            end

            group:SetAttribute("columnAnchorPoint", DIRECTION_TO_COLUMN_ANCHOR_POINT[direction])

            if not group.isForced then
                group:SetAttribute("maxColumns", raidWideSorting and numGroups or 1)
                group:SetAttribute("unitsPerColumn", raidWideSorting and (groupsPerRowCol * 5) or 5)
                group:SetAttribute("showPlayer", showPlayer)
                group:SetAttribute("sortDir", sortDirection)
                -- sorting
                if profile == "RAID_PET" then
                    headerGroupBy.PETNAME(group)
                elseif profile == "TANK" then
                    headerGroupBy.TANK(group)
                else
                    local func = headerGroupBy[groupBy] or headerGroupBy.INDEX
                    func(group, profile)
                end
            end

            if profile ~= "TANK" then
                local groupWide = i == 1 and raidWideSorting and strsub("1,2,3,4,5,6,7,8", 1, numGroups + numGroups-1)
                group:SetAttribute("groupFilter", groupWide or tostring(i))
            end

            -- register the correct visibility state driver
            if profile == "PARTY" then
                if not GW.settings.RAID_STYLE_PARTY and not GW.settings.RAID_STYLE_PARTY_AND_FRAMES then
                    RegisterStateDriver(group, "visibility", "hide")
                else
                    RegisterStateDriver(group, "visibility", profiles.PARTY.visibility)
                end
            end
        end

        local pointInner = DIRECTION_TO_GROUP_ANCHOR_POINT[direction]
        if (isParty or raidWideSorting) and settings.startFromCenter[profile] then
			pointInner = DIRECTION_TO_GROUP_ANCHOR_POINT["OUT+" .. direction]
		end

        if lastGroup == 0 then
            if DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT" then
                if group then group:SetPoint(pointInner, header, pointInner, 0, height * y) end
                height = height + HEIGHT + groupSpacing
                newRows = newRows + 1
            else
                if group then group:SetPoint(pointInner, header, pointInner, width * x, 0) end
                width = width + WIDTH + groupSpacing
                newCols = newCols + 1
            end
        else
            if DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT" then
                if newRows == 1 then
                    if group then group:SetPoint(pointInner, header, pointInner, width * x, 0) end
                    width = width + WIDTH_FIVE + groupSpacing
                    newCols = newCols + 1
                elseif group then
                    group:SetPoint(pointInner, header, pointInner, ((WIDTH_FIVE * lastGroup) + lastGroup * groupSpacing) * x, ((HEIGHT + groupSpacing) * (newRows - 1)) * y)
                end
            else
                if newCols == 1 then
                    if group then group:SetPoint(pointInner, header, pointInner, 0, height * y) end
                    height = height + HEIGHT_FIVE + groupSpacing
                    newRows = newRows + 1
                elseif group then
                    group:SetPoint(pointInner, header, pointInner, ((WIDTH + groupSpacing) * (newCols - 1)) * x, ((HEIGHT_FIVE * lastGroup) + lastGroup * groupSpacing) * y)
                end
            end
        end

        if height == 0 then height = height + HEIGHT_FIVE + groupSpacing end
        if width == 0 then width = width + WIDTH_FIVE + groupSpacing end
    end

    header:SetSize(width - horizontalSpacing - groupSpacing, height - verticalSpacing - groupSpacing)
    header.gwMover:SetSize(width - horizontalSpacing - groupSpacing, height - verticalSpacing - groupSpacing)

    --check if we can diable the frame and also the mover
    if not header.isForced then
        if profile == "RAID40" then
            RegisterStateDriver(header, "visibility", profiles.RAID40.visibility)
            UpdateGroupVisibility(header, profile, true)
        elseif profile == "RAID25" then
            GW.ToggleMover(header.gwMover, GW.settings.RAID25_ENABLED)
            if not GW.settings.RAID25_ENABLED then
                RegisterStateDriver(header, "visibility", "hide")
            else
                RegisterStateDriver(header, "visibility", profiles.RAID25.visibility)
            end
            UpdateGroupVisibility(header, profile, GW.settings.RAID25_ENABLED)
        elseif profile == "RAID10" then
            GW.ToggleMover(header.gwMover, GW.settings.RAID10_ENABLED)
            if not GW.settings.RAID10_ENABLED then
                RegisterStateDriver(header, "visibility", "hide")
            else
                RegisterStateDriver(header, "visibility", profiles.RAID10.visibility)
            end
            UpdateGroupVisibility(header, profile, GW.settings.RAID10_ENABLED)
        elseif profile == "RAID_PET" then
            GW.ToggleMover(header.gwMover, GW.settings.RAID_PET_FRAMES)
            if not GW.settings.RAID_PET_FRAMES then
                RegisterStateDriver(header, "visibility", "hide")
            else
                RegisterStateDriver(header, "visibility", profiles.RAID_PET.visibility)
            end
            UpdateGroupVisibility(header, profile, GW.settings.RAID_PET_FRAMES)
        elseif profile == "TANK" then
            GW.ToggleMover(header.gwMover, GW.settings.RAID_MAINTANK_FRAMES_ENABLED)
            if not GW.settings.RAID_MAINTANK_FRAMES_ENABLED then
                RegisterStateDriver(header, "visibility", "hide")
            else
                RegisterStateDriver(header, "visibility", profiles.TANK.visibility)
            end
            UpdateGroupVisibility(header, profile, GW.settings.RAID_MAINTANK_FRAMES_ENABLED)
        end
    end

    header.isUpdating = false
end
GW.UpdateGridHeader = UpdateGridHeader

local function CreateHeader(parent, profile, options, overrideName, groupFilter)
    local header = parent:SpawnHeader(overrideName, (options.name == "RaidPet" and "SecureGroupPetHeaderTemplate" or nil),
        "showParty", true,
        "showRaid", options.name ~= "Party",
        "showPlayer", true,
        "groupFilter", groupFilter,
        "groupingOrder", "1,2,3,4,5,6,7,8",
        "oUF-initialConfigFunction", format("self:SetWidth(%d); self:SetHeight(%d);", settings.raidWidth[profile], settings.raidHeight[profile])
    )

    header.groupName = profile
    header.profileName = options.name
    header.numGroups = options.numGroups
    header.styleFunc = options.styleFunc
    header.updateFunc = options.updateFunc

    header:SetVisibility("custom " .. options.visibility)

    return header
end

local function Initialize()
    GW.CreateRaidControlFrame()
    GW.Create_Tags()
    ApplySettings()

    -- create headers and groups for all profiles
    for profile, options in pairs(profiles) do
        GW_UF:RegisterStyle("GW2_Grid" .. options.name, options.styleFunc)
        GW_UF:SetActiveStyle("GW2_Grid" .. options.name)

        -- Create a holding header
        local Header = CreateFrame("Frame", "GW2_" .. options.name .. "GridContainer", UIParent, "SecureHandlerStateTemplate")
        Header.groups = {}
        Header.groupName = profile
        Header.numGroups = options.numGroups
        Header.profileName = options.name
        Header.styleFunc = options.styleFunc
        Header.updateFunc = options.updateFunc
        headers[profile] = Header

        Header.groups[1] = CreateHeader(GW_UF, profile, options, "GW2_" .. options.name .. "Group1")

        while options.numGroups > #Header.groups do
            local index = tostring(#Header.groups + 1)
            tinsert(Header.groups, CreateHeader(GW_UF, profile, options, "GW2_" .. options.name .. "Group" .. index, index))
        end

        RegisterStateDriver(Header, "visibility", options.visibility)

        -- movable frame for the container
        if profile == "PARTY" then
            GW.RegisterMovableFrame(Header, GW.L["Group Frames"], "raid_party_pos",  ALL .. ",Unitframe,Group", nil, {"default", "default"})
        elseif profile == "RAID_PET" then
            GW.RegisterMovableFrame(Header, GW.L["Raid pet's Grid"], "raid_pet_pos",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})
        elseif profile == "RAID40" then
            GW.RegisterMovableFrame(Header, RAID_FRAMES_LABEL .. ": " .. options.size, "raid_pos",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})
        elseif profile == "RAID25" then
            GW.RegisterMovableFrame(Header, RAID_FRAMES_LABEL .. ": " .. options.size, "raid25_pos",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})
        elseif profile == "RAID10" then
            GW.RegisterMovableFrame(Header, RAID_FRAMES_LABEL .. ": " .. options.size, "raid10_pos",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})
        elseif profile == "TANK" then
            GW.RegisterMovableFrame(Header, MAINTANK, "raidMaintank_pos",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})
        end

        Header:ClearAllPoints()
        Header:SetPoint("TOPLEFT", Header.gwMover)

        UpdateGridHeader(profile)
    end

    UpdateFramesAndHeader("ALL", false, true, true)
end
GW.InitializeRaidFrames = Initialize
