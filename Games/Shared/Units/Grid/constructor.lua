---@class GW2
local GW = select(2, ...)
local GW_UF = GW.oUF

local headers = {}
GW.GridGroupHeaders = headers

local profiles = {
    party = {
        name = "Party",
        visibility = "[@raid1,exists][@party1,noexists] hide;show",
        numGroups = 1,
        styleFunc = GW.GridPartyStyleRegister,
        updateFunc = GW.UpdateGridPartyFrame
    },
    partyPet = {
        name = "PartyPet",
        visibility = "[@raid1,exists][@party1,noexists] hide;show",
        numGroups = 1,
        styleFunc = GW.GridPartyPetStyleRegister,
        updateFunc = GW.UpdateGridPartyPetFrame
    },
    raidPet = {
        name = "RaidPet",
        visibility = "[@raid1,exists] show; hide",
        numGroups = 8,
        styleFunc = GW.GridRaidPetStyleRegister,
        updateFunc = GW.UpdateGridRaidPetFrame
    },
    raid40 = {
        name = "Raid40",
        size = 40,
        visibility = "[@raid26,noexists] hide; show", -- fallback only, see BuildRaidGridVisibility
        numGroups = 8,
        styleFunc = GW.GridRaid40StyleRegister,
        updateFunc = GW.UpdateGridRaid40Frame
    },
    raid25 = {
        name = "Raid25",
        size = 25,
        visibility = "[@raid11,noexists][@raid26,exists] hide;show", -- fallback only, see BuildRaidGridVisibility
        numGroups = 5,
        styleFunc = GW.GridRaid25StyleRegister,
        updateFunc = GW.UpdateGridRaid25Frame
    },
    raid10 = {
        name = "Raid10",
        size = 10,
        visibility = "[@raid1,noexists][@raid11,exists] hide;show",
        numGroups = 5,
        styleFunc = GW.GridRaid10StyleRegister,
        updateFunc = GW.UpdateGridRaid10Frame
    },
    maintank = {
        name = "Maintank",
        visibility = "[group:raid] show; hide",
        numGroups = 1,
        styleFunc = GW.GridMaintankStyleRegister,
        updateFunc = GW.UpdateGridMaintankFrame
    },
}


--SecureCmdOptionParse("[@raid1,noexists][@raid26,exists] hide; show")
--SecureCmdOptionParse("[@raid11,noexists] hide; show")
--SecureCmdOptionParse("[@raid1,noexists][@raid11,exists] hide;show")
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

local settingsEventFrame = CreateFrame("Frame")
local pendingProfiles = {}


local function IsProfileEnabled(profile)
    if profile == "party" then
        -- mirrors the group visibility check in UpdateGridHeader
        return GW.settings.groupFrames.party.enabled or GW.settings.groupFrames.party.withPartyFrames
    end
    if profile == "raid40" then
        -- own toggle, additionally gated by the module master
        return GW.settings.groupFrames.enabled and GW.settings.groupFrames.raid40.enabled
    end

    return not not GW.settings.groupFrames[profile].enabled
end

-- defined after CreateHeader; called from UpdateFramesAndHeader at runtime only
local EnsureHeaderGroups

local function MarkPending(profile)
    settingsEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    if profile == "ALL" then
        pendingProfiles.ALL = true
    else
        pendingProfiles[profile] = true
    end
end

local function SetAttributeIfChanged(frame, attribute, value)
    if frame:GetAttribute(attribute) ~= value then
        frame:SetAttribute(attribute, value)
    end
end

local function SetPointIfChanged(frame, point, relativeFrame, relativePoint, xOffset, yOffset)
    if frame.gridLayoutPoint == point
        and frame.gridLayoutRelativeFrame == relativeFrame
        and frame.gridLayoutRelativePoint == relativePoint
        and frame.gridLayoutXOffset == xOffset
        and frame.gridLayoutYOffset == yOffset
    then
        return
    end

    frame:ClearAllPoints()
    frame:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset)
    frame.gridLayoutPoint = point
    frame.gridLayoutRelativeFrame = relativeFrame
    frame.gridLayoutRelativePoint = relativePoint
    frame.gridLayoutXOffset = xOffset
    frame.gridLayoutYOffset = yOffset
end

local headerGroupBy = {
	CLASS = function(header, profile)
		local sortMethod = GW.settings.groupFrames[profile].sortMethod
        local classSortOrder = GW.settings.groupFrames[profile].groupByClassOrder
		SetAttributeIfChanged(header, "groupingOrder", table.concat(classSortOrder, ", "))
		SetAttributeIfChanged(header, "sortMethod", sortMethod or "NAME")
		SetAttributeIfChanged(header, "groupBy", "CLASS")
	end,
	ROLE = function(header, profile)
		local sortMethod = GW.settings.groupFrames[profile].sortMethod
		SetAttributeIfChanged(header, "groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		SetAttributeIfChanged(header, "sortMethod", sortMethod or "NAME")
		SetAttributeIfChanged(header, "groupBy", "ASSIGNEDROLE")
	end,
	NAME = function(header, profile)
		SetAttributeIfChanged(header, "groupingOrder", "1,2,3,4,5,6,7,8")
		SetAttributeIfChanged(header, "sortMethod", "NAME")
		SetAttributeIfChanged(header, "groupBy", nil)
	end,
	GROUP = function(header, profile)
		local sortMethod = GW.settings.groupFrames[profile].sortMethod
		SetAttributeIfChanged(header, "groupingOrder", "1,2,3,4,5,6,7,8")
		SetAttributeIfChanged(header, "sortMethod", sortMethod or "INDEX")
		SetAttributeIfChanged(header, "groupBy", "GROUP")
	end,
	PETNAME = function(header, profile)
		SetAttributeIfChanged(header, "groupingOrder", "1,2,3,4,5,6,7,8")
		SetAttributeIfChanged(header, "sortMethod", "NAME")
		SetAttributeIfChanged(header, "groupBy", nil)
		SetAttributeIfChanged(header, "filterOnPet", true) --This is the line that matters. Without this, it sorts based on the owners name
	end,
	INDEX = function(header, profile)
		SetAttributeIfChanged(header, "groupingOrder", "1,2,3,4,5,6,7,8")
		SetAttributeIfChanged(header, "sortMethod", "INDEX")
		SetAttributeIfChanged(header, "groupBy", nil)
	end,
    TANK = function(header, profile)
        SetAttributeIfChanged(header, "groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		SetAttributeIfChanged(header, "sortMethod", "INDEX")
		SetAttributeIfChanged(header, "groupBy", nil)
        SetAttributeIfChanged(header, "groupFilter", "MAINTANK")
    end,
}

local function UpdateFramesAndHeader(profile, onlyHeaderUpdate, updateHeaderAndFrames)
    if GW.disableGridUpdate then return end

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

    -- profiles disabled at login have no groups yet — build them once the profile
    -- gets enabled: the header update materializes the secure children, the
    -- updateFunc pass right after pushes the current settings onto them (the
    -- regular pass below is skipped for pure header updates)
    for headerProfile, header in pairs(headers) do
        if profile == "ALL" or headerProfile == profile then
            if EnsureHeaderGroups(headerProfile) then
                GW.UpdateGridHeader(headerProfile)
                for i = 1, header.numGroups do
                    local group = header.groups[i]
                    if group then
                        for _, child in ipairs({ group:GetChildren() }) do
                            header.updateFunc(child)
                        end
                    end
                end
            end
        end
    end

    if not onlyHeaderUpdate or updateHeaderAndFrames then
        if InCombatLockdown() then
            MarkPending(profile)
        end
        for headerProfile, header in pairs(headers) do
            if profile == "ALL" or headerProfile == profile then
                for i = 1, header.numGroups do
                    local group = header.groups[i]
                    if group then
                        for _, child in ipairs({ group:GetChildren() }) do
                            header.updateFunc(child)
                        end
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

    -- the setting gated aura regions (pandemic, dispel icon) read the frame fields
    -- pushed above — re-evaluate them here so this also covers the post combat catch up
    if GW.Retail then
        GW.UpdateAuraOptionRegions()
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
    raised:SetAllPoints()
	raised:SetFrameLevel(level)

	raised.__owner = frame
	raised.TextureParent = CreateFrame("Frame", nil, raised)

    raised.AuraLevel = level
    raised.AuraBarLevel = level + 10
    raised.MissingAuraIndicator = level + 15

	return raised
end
GW.CreateRaisedElement = CreateRaisedElement

-- the raid grids in ascending size; every grid has its own enable, RAID_FRAMES is
-- only the module master on top
local RAID_GRID_ORDER = {
    { profile = "raid10", size = 10, enabled = function() return GW.settings.groupFrames.raid10.enabled end },
    { profile = "raid25", size = 25, enabled = function() return GW.settings.groupFrames.raid25.enabled end },
    { profile = "raid40", size = 40, enabled = function() return GW.settings.groupFrames.enabled and GW.settings.groupFrames.raid40.enabled end },
}

-- ONE source of truth for the raid grid visibility drivers. Macro conditionals cannot
-- read addon settings, so a grid cannot carry a single static condition covering every
-- enable-combination - instead the condition is generated from the enabled set: every
-- enabled grid covers from one above the next smaller enabled grid up to its own size,
-- the biggest one upwards. The ranges partition 1-40 by construction, so exactly one
-- grid is visible for any raid size. The previous hand-picked variants could overlap
-- after runtime toggles (RAID25 on with RAID10 off returned no condition at all for
-- RAID40, leaving whatever driver was registered before).
local function BuildRaidGridVisibility(profile)
    local lower = 1
    local target

    for _, grid in ipairs(RAID_GRID_ORDER) do
        if grid.profile == profile then
            if not grid.enabled() then return "hide" end
            target = grid
            break
        elseif grid.enabled() then
            lower = grid.size + 1 -- the biggest enabled smaller grid ends below us
        end
    end

    if not target then return nil end

    -- IMPORTANT: multiple bracket groups in a macro conditional are OR'ed, not AND'ed.
    -- "show inside the range" therefore has to be written in its De Morgan form:
    -- hide when below the lower bound OR above the upper bound, otherwise show.
    local condition = "[@raid" .. lower .. ",noexists]"
    if target.size < MAX_RAID_MEMBERS then
        condition = condition .. "[@raid" .. (target.size + 1) .. ",exists]"
    end
    return condition .. " hide; show"
end

local function GetHeaderVisibility(profile)
    if profile == "raid40" or profile == "raid25" or profile == "raid10" then
        return BuildRaidGridVisibility(profile)
    elseif profile == "raidPet" then
        return GW.settings.groupFrames.raidPet.enabled and profiles.raidPet.visibility or "hide"
    elseif profile == "maintank" then
        return GW.settings.groupFrames.maintank.enabled and profiles.maintank.visibility or "hide"
    end

    return nil
end

local function UpdateGroupVisibility(header, profile, enabled)
    if not header.isForced then
        local numGroups = header.numGroups
        local raidWideSorting = GW.settings.groupFrames[profile].wideSorting
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

local function UpdateGridHeaderLayout(header, profile)
    local direction = GW.settings.groupFrames[profile].grow or "DOWN+RIGHT"
    local point = DIRECTION_TO_POINT[direction]
    local x, y = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction], DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction]
    local numGroups = header.numGroups
    local isParty = profile == "party"
    local groupsPerRowCol = isParty and 1 or tonumber(GW.settings.groupFrames[profile].groupsPerColumn)
    local width, height, newCols, newRows = 0, 0, 0, 0
    local groupSpacing = tonumber(GW.settings.groupFrames[profile].groupSpacing)
    local horizontalSpacing = tonumber(GW.settings.groupFrames[profile].horizontalSpacing)
    local verticalSpacing = tonumber(GW.settings.groupFrames[profile].verticalSpacing)
    local WIDTH = GW.Scale(tonumber(GW.settings.groupFrames[profile].width)) + horizontalSpacing
    local HEIGHT = GW.Scale(tonumber(GW.settings.groupFrames[profile].height)) + verticalSpacing
    local HEIGHT_FIVE = HEIGHT * 5
    local WIDTH_FIVE = WIDTH * 5
    local groupBy = GW.settings.groupFrames[profile].groupBy
    local sortDirection = GW.settings.groupFrames[profile].sortDirection
    local raidWideSorting = GW.settings.groupFrames[profile].wideSorting
    local showPlayer = true

    if isParty then
        showPlayer = GW.settings.groupFrames.party.showPlayer
    end

    for i = 1, numGroups do
        local group = header.groups[i]
        local lastIndex = i - 1
        local lastGroup = lastIndex % groupsPerRowCol

        if group then
            local isConfigForced = header.forceShow or group.isForced

            if not isConfigForced then
                local idx = 1
                local child = group:GetAttribute("child"..idx)
                while child do
                    child:ClearAllPoints()
                    idx = idx + 1
                    child = group:GetAttribute("child"..idx)
                end
            end

            SetAttributeIfChanged(group, "point", point)

            if point == "LEFT" or point == "RIGHT" then
                SetAttributeIfChanged(group, "xOffset", horizontalSpacing * x)
                SetAttributeIfChanged(group, "yOffset", 0)
                SetAttributeIfChanged(group, "columnSpacing", verticalSpacing)
            else
                SetAttributeIfChanged(group, "xOffset", 0)
                SetAttributeIfChanged(group, "yOffset", verticalSpacing * y)
                SetAttributeIfChanged(group, "columnSpacing", horizontalSpacing)
            end

            if not isConfigForced then
                if not group.initialized then
                    SetAttributeIfChanged(group, "startingIndex", raidWideSorting and (-min(numGroups * (groupsPerRowCol * 5), MAX_RAID_MEMBERS) + 1) or -4)
                    group:Show()
                    group.initialized = true
                end
                SetAttributeIfChanged(group, "startingIndex", 1)
            end

            SetAttributeIfChanged(group, "columnAnchorPoint", DIRECTION_TO_COLUMN_ANCHOR_POINT[direction])

            if not isConfigForced or header.forceConfigHeaderUpdate then
                SetAttributeIfChanged(group, "maxColumns", raidWideSorting and numGroups or 1)
                SetAttributeIfChanged(group, "unitsPerColumn", raidWideSorting and (groupsPerRowCol * 5) or 5)
                SetAttributeIfChanged(group, "showPlayer", showPlayer)
                SetAttributeIfChanged(group, "sortDir", sortDirection)
                -- sorting
                if profile == "raidPet" then
                    headerGroupBy.PETNAME(group)
                elseif profile == "maintank" then
                    headerGroupBy.TANK(group)
                else
                    local func = headerGroupBy[groupBy] or headerGroupBy.INDEX
                    func(group, profile)
                end
            end

            if profile ~= "maintank" then
                local groupWide = i == 1 and raidWideSorting and strsub("1,2,3,4,5,6,7,8", 1, numGroups + numGroups-1)
                SetAttributeIfChanged(group, "groupFilter", groupWide or tostring(i))
            end

            -- register the correct visibility state driver
            if profile == "party" and not isConfigForced then
                if not GW.settings.groupFrames.party.enabled and not GW.settings.groupFrames.party.withPartyFrames then
                    RegisterStateDriver(group, "visibility", "hide")
                else
                    RegisterStateDriver(group, "visibility", profiles.party.visibility)
                end
            end
        end

        local pointInner = DIRECTION_TO_GROUP_ANCHOR_POINT[direction]
        if (isParty or raidWideSorting) and GW.settings.groupFrames[profile].anchorFromCenter then
			pointInner = DIRECTION_TO_GROUP_ANCHOR_POINT["OUT+" .. direction]
		end

        if lastGroup == 0 then
            if DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT" then
                if group then SetPointIfChanged(group, pointInner, header, pointInner, 0, height * y) end
                height = height + HEIGHT + groupSpacing
                newRows = newRows + 1
            else
                if group then SetPointIfChanged(group, pointInner, header, pointInner, width * x, 0) end
                width = width + WIDTH + groupSpacing
                newCols = newCols + 1
            end
        else
            if DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT" then
                if newRows == 1 then
                    if group then SetPointIfChanged(group, pointInner, header, pointInner, width * x, 0) end
                    width = width + WIDTH_FIVE + groupSpacing
                    newCols = newCols + 1
                elseif group then
                    SetPointIfChanged(group, pointInner, header, pointInner, ((WIDTH_FIVE * lastGroup) + lastGroup * groupSpacing) * x, ((HEIGHT + groupSpacing) * (newRows - 1)) * y)
                end
            else
                if newCols == 1 then
                    if group then SetPointIfChanged(group, pointInner, header, pointInner, 0, height * y) end
                    height = height + HEIGHT_FIVE + groupSpacing
                    newRows = newRows + 1
                elseif group then
                    SetPointIfChanged(group, pointInner, header, pointInner, ((WIDTH + groupSpacing) * (newCols - 1)) * x, ((HEIGHT_FIVE * lastGroup) + lastGroup * groupSpacing) * y)
                end
            end
        end

        if height == 0 then height = height + HEIGHT_FIVE + groupSpacing end
        if width == 0 then width = width + WIDTH_FIVE + groupSpacing end
    end

    header:SetSize(width - horizontalSpacing - groupSpacing, height - verticalSpacing - groupSpacing)
    header.gwMover:SetSize(width - horizontalSpacing - groupSpacing, height - verticalSpacing - groupSpacing)
end

local function UpdateGridHeaderVisibility(header, profile)
    -- header driver + mover state. The header visibility itself is registered inside
    -- UpdateGroupVisibility from GetHeaderVisibility - registering it here as well (as the
    -- code used to) is the kind of duplication that caused overlapping grids
    if not header.isForced then
        if profile == "raid40" then
            GW.ToggleMover(header.gwMover, GW.settings.groupFrames.raid40.enabled)
            UpdateGroupVisibility(header, profile, GW.settings.groupFrames.raid40.enabled)
        elseif profile == "raid25" then
            GW.ToggleMover(header.gwMover, GW.settings.groupFrames.raid25.enabled)
            UpdateGroupVisibility(header, profile, GW.settings.groupFrames.raid25.enabled)
        elseif profile == "raid10" then
            GW.ToggleMover(header.gwMover, GW.settings.groupFrames.raid10.enabled)
            UpdateGroupVisibility(header, profile, GW.settings.groupFrames.raid10.enabled)
        elseif profile == "raidPet" then
            GW.ToggleMover(header.gwMover, GW.settings.groupFrames.raidPet.enabled)
            UpdateGroupVisibility(header, profile, GW.settings.groupFrames.raidPet.enabled)
        elseif profile == "maintank" then
            GW.ToggleMover(header.gwMover, GW.settings.groupFrames.maintank.enabled)
            UpdateGroupVisibility(header, profile, GW.settings.groupFrames.maintank.enabled)
        end
    end
end

local function UpdateGridHeader(profile)
    local header = headers[profile]
    if header.isUpdating then return end
    header.isUpdating = true

    local okLayout, layoutError = pcall(UpdateGridHeaderLayout, header, profile)
    local okVisibility, visibilityError = pcall(UpdateGridHeaderVisibility, header, profile)
    header.isUpdating = false

    if not okLayout then geterrorhandler()(layoutError) end
    if not okVisibility then geterrorhandler()(visibilityError) end
end
GW.UpdateGridHeader = UpdateGridHeader

local function CreateHeader(parent, profile, options, overrideName, groupFilter)
    local header = parent:SpawnHeader(overrideName, ((options.name == "RaidPet" or options.name == "PartyPet") and "SecureGroupPetHeaderTemplate" or nil),
        "showParty", true,
        "showRaid", options.name ~= "Party" and options.name ~= "PartyPet",
        "showPlayer", true,
        "groupFilter", groupFilter,
        "groupingOrder", "1,2,3,4,5,6,7,8",
        "oUF-initialConfigFunction", format("self:SetWidth(%d); self:SetHeight(%d);", tonumber(GW.settings.groupFrames[profile].width), tonumber(GW.settings.groupFrames[profile].height))
    )

    header.groupName = profile
    header.profileName = options.name
    header.numGroups = options.numGroups
    header.styleFunc = options.styleFunc
    header.updateFunc = options.updateFunc

    header:SetVisibility("custom " .. (GetHeaderVisibility(profile) or options.visibility))

    tinsert(GW.GridHeaders, header)

    return header
end

-- Builds the secure group headers (and thereby their pre-created children) for a
-- profile. Skipped for disabled profiles: each group pre-creates ALL its secure
-- children out of combat (RAID40 = 40 frames, RAID_PET = 40, ...) so that mid-combat
-- roster growth already has frames — but that also means a disabled profile would
-- pay the full creation cost for frames that can never become visible. Called again
-- from UpdateFramesAndHeader when a profile gets enabled after login; in combat the
-- creation is deferred via MarkPending. Returns true when groups were just created.
EnsureHeaderGroups = function(profile)
    local header = headers[profile]
    if not header or header.groups[1] or not IsProfileEnabled(profile) then return false end
    if InCombatLockdown() then
        MarkPending(profile)
        return false
    end

    local options = profiles[profile]
    GW_UF:SetActiveStyle("GW2_Grid" .. options.name)

    header.groups[1] = CreateHeader(GW_UF, profile, options, "GW2_" .. options.name .. "Group1")

    while options.numGroups > #header.groups do
        local index = tostring(#header.groups + 1)
        tinsert(header.groups, CreateHeader(GW_UF, profile, options, "GW2_" .. options.name .. "Group" .. index, index))
    end

    return true
end

local function Initialize()
    GW.CreateRaidControlFrame()
    GW.Create_Tags()

    -- create headers (and groups for the enabled profiles)
    for profile, options in pairs(profiles) do
        GW_UF:RegisterStyle("GW2_Grid" .. options.name, options.styleFunc)

        -- Create a holding header
        local Header = CreateFrame("Frame", "GW2_" .. options.name .. "GridContainer", UIParent, "SecureHandlerStateTemplate")
        Header.groups = {}
        Header.groupName = profile
        Header.numGroups = options.numGroups
        Header.profileName = options.name
        Header.styleFunc = options.styleFunc
        Header.updateFunc = options.updateFunc
        headers[profile] = Header

        EnsureHeaderGroups(profile)

        RegisterStateDriver(Header, "visibility", GetHeaderVisibility(profile) or options.visibility)

        -- movable frame for the container
        if profile == "party" then
            GW.RegisterMovableFrame(Header, GW.L["Group Frames"], "groupFrames.party",  "Unitframe,Group")
        elseif profile == "partyPet" then
            GW.RegisterMovableFrame(Header, GW.L["Party pet's Grid"], "groupFrames.partyPet",  "Unitframe,Group")
        elseif profile == "raidPet" then
            GW.RegisterMovableFrame(Header, GW.L["Raid pet's Grid"], "groupFrames.raidPet",  "Unitframe,Raid")
        elseif profile == "raid40" then
            GW.RegisterMovableFrame(Header, RAID_FRAMES_LABEL .. ": " .. options.size, "groupFrames.raid40",  "Unitframe,Raid")
        elseif profile == "raid25" then
            GW.RegisterMovableFrame(Header, RAID_FRAMES_LABEL .. ": " .. options.size, "groupFrames.raid25",  "Unitframe,Raid")
        elseif profile == "raid10" then
            GW.RegisterMovableFrame(Header, RAID_FRAMES_LABEL .. ": " .. options.size, "groupFrames.raid10",  "Unitframe,Raid")
        elseif profile == "maintank" then
            GW.RegisterMovableFrame(Header, MAINTANK, "groupFrames.maintank",  "Unitframe,Raid")
        end

        Header:ClearAllPoints()
        Header:SetPoint("TOPLEFT", Header.gwMover)

        UpdateGridHeader(profile)
    end

    UpdateFramesAndHeader("ALL", false, true)
end
GW.InitializeRaidFrames = Initialize
