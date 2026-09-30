---@class GW2
local GW = select(2, ...)
local GW_UF = GW.oUF

-- Config mode fills the group frames with made up members. The secure headers still
-- decide which frames exist; our tags read fake unit data through a swapped environment.

local CONFIG_MODE_UNIT_PREFIX = "gw2config"
local CONFIG_MODE_ROLES = { "TANK", "HEALER", "DAMAGER" }
local CONFIG_MODE_POWER_TYPES = { "MANA", "RAGE", "FOCUS", "ENERGY", "RUNIC_POWER" }

-- header attributes that hide a group depending on party, raid or solo
local VISIBILITY_ATTRIBUTES = { "showRaid", "showParty", "showSolo" }
local NIL_ATTRIBUTE = {}

-- tags that show unit data and therefore run in the fake environment
local FAKED_TAGS = {
    "GW2_Grid:name", "GW2_Grid:leaderIcon", "GW2_Grid:assistIcon", "GW2_Grid:roleIcon",
    "GW2_Grid:realmFlag", "GW2_Grid:mainTank", "GW2_Grid:healtValue",
}

-- unit functions the tags call, answered from the fake member when the unit is one of ours
local FAKE_UNIT_API = {
    UnitPower = function(data) return data.power end,
    UnitPowerMax = function(data) return data.maxPower end,
    UnitHealth = function(data) return data.health end,
    UnitHealthMax = function(data) return data.maxHealth end,
    UnitHealthMissing = function(data) return max(data.maxHealth - data.health, 0) end,
    UnitHealthPercent = function(data) return data.maxHealth > 0 and data.health / data.maxHealth * 100 or 0 end,
    UnitName = function(data) return data.name end,
    UnitClass = function(data) return LOCALIZED_CLASS_NAMES_MALE[data.classToken], data.classToken end,
    UnitGroupRolesAssigned = function(data) return data.role end,
}

local fakeEnv
local savedEnvs = {}          -- tag function -> its real environment while config mode runs
local configModeUnits = {}    -- fake unit token -> fake member
local activeHeaders = {}
local savedChildState = {}    -- forced child -> what we changed on it
local savedAttributes = {}    -- group -> its visibility attributes before config mode
local hookedGroups = {}
local drivenVisibility = {}   -- header or group -> the visibility state we registered

local function ForEachGroup(header, func)
    for i = 1, header.numGroups do
        local group = header.groups[i]
        if group then
            func(group, i)
        end
    end
end

local function ForEachChild(group, func, ...)
    local index = 1
    local child = group:GetAttribute("child" .. index)
    while child do
        func(child, index, ...)
        index = index + 1
        child = group:GetAttribute("child" .. index)
    end
end

local function UpdateChild(child, group, groupName)
    GW["UpdateGrid" .. group.profileName .. "Frame"](child, groupName)
end

-- a stable fake member per slot, spread over classes, roles and power types
local function GetConfigModeData(frame, group, index)
    if frame.configModeData then
        return frame.configModeData
    end

    local groupNumber = tonumber(strmatch(group:GetName() or "", "Group(%d+)$")) or 1
    local slot = (groupNumber - 1) * MEMBERS_PER_RAID_GROUP + index
    local credits = GW.CreditsList
    local data = {
        unit = CONFIG_MODE_UNIT_PREFIX .. ":" .. (group:GetName() or group.groupName) .. ":" .. index,
        name = credits and #credits > 0 and credits[(slot - 1) % #credits + 1] or ("Test Name " .. slot),
        classToken = CLASS_SORT_ORDER[(slot - 1) % #CLASS_SORT_ORDER + 1],
        role = CONFIG_MODE_ROLES[(slot - 1) % #CONFIG_MODE_ROLES + 1],
        powerType = CONFIG_MODE_POWER_TYPES[(slot - 1) % #CONFIG_MODE_POWER_TYPES + 1],
        health = 35 + (slot * 17) % 65,
        maxHealth = 100,
        power = 20 + (slot * 23) % 80,
        maxPower = 100,
    }

    frame.configModeData = data
    configModeUnits[data.unit] = data
    return data
end

local function CreateFakeEnv()
    if fakeEnv then return end

    local api = {}
    for name, fake in pairs(FAKE_UNIT_API) do
        api[name] = function(unit, ...)
            local data = configModeUnits[unit]
            if data then
                return fake(data)
            end
            return _G[name](unit, ...)
        end
    end
    -- the tags color with Hex, which takes a color table or r, g, b
    api.Hex = function(r, g, b)
        if type(r) == "table" then
            if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
        end
        return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
    end

    fakeEnv = setmetatable(api, {
        __index = _G,
        __newindex = function(_, key, value) _G[key] = value end,
    })
end

local function IsAnyHeaderInConfigMode()
    for header in pairs(activeHeaders) do
        if header.forceShow then
            return true
        end
    end
    return false
end

local function UseFakeEnv()
    CreateFakeEnv()
    for _, tag in ipairs(FAKED_TAGS) do
        local method = GW_UF.Tags.Methods[tag]
        if type(method) == "function" and not savedEnvs[method] then
            savedEnvs[method] = getfenv(method)
            setfenv(method, fakeEnv)
        end
    end
end

local function RestoreRealEnv()
    if IsAnyHeaderInConfigMode() then return end
    for method, env in pairs(savedEnvs) do
        setfenv(method, env)
        savedEnvs[method] = nil
    end
end

local function HideVisibilityAttributes(group)
    if not savedAttributes[group] then
        local saved = {}
        for _, key in ipairs(VISIBILITY_ATTRIBUTES) do
            local value = group:GetAttribute(key)
            saved[key] = value == nil and NIL_ATTRIBUTE or value
        end
        savedAttributes[group] = saved
    end
    for _, key in ipairs(VISIBILITY_ATTRIBUTES) do
        group:SetAttribute(key, nil)
    end
end

local function RestoreVisibilityAttributes(group)
    local saved = savedAttributes[group]
    if not saved then return end
    for _, key in ipairs(VISIBILITY_ATTRIBUTES) do
        local value = saved[key]
        group:SetAttribute(key, value ~= NIL_ATTRIBUTE and value or nil)
    end
    savedAttributes[group] = nil
end

local function ForceChild(child, index, group, limit)
    child:SetID(index)
    -- the party header can hide the player: every limit-th slot stays empty then
    if InCombatLockdown() or (limit and index % limit == 0) then return end

    if not child.isForced then
        savedChildState[child] = {
            unit = child.__unit,
            realUnit = child.__realUnit,
            nameOverride = child.Name and child.Name.overrideUnit,
            healthOverride = child.HealthValueText and child.HealthValueText.overrideUnit,
            onUpdate = child:GetScript("OnUpdate"),
        }
        child.__unit = "player"
        child.isForced = true
    end

    local data = GetConfigModeData(child, group, index)
    child.forceShowAuras = true
    child:SetScript("OnUpdate", nil)
    child:EnableMouse(false)
    child:Show()
    -- the second argument keeps the frame shown without a real unit
    UnregisterUnitWatch(child)
    RegisterUnitWatch(child, true)

    child.__realUnit = data.unit
    child.Name.overrideUnit = true
    child.HealthValueText.overrideUnit = true
    UpdateChild(child, group)
end

local function ReleaseChild(child, _, group)
    if InCombatLockdown() or not child.isForced then return end

    local saved = savedChildState[child] or {}
    savedChildState[child] = nil
    child.__unit = saved.unit or child.__unit
    child.__realUnit = saved.realUnit
    child.isForced = nil
    child.forceShowAuras = nil
    child:EnableMouse(true)

    -- back to the state driver showing the frame only for real units
    UnregisterUnitWatch(child)
    RegisterUnitWatch(child)

    if saved.onUpdate then
        child:SetScript("OnUpdate", saved.onUpdate)
    end
    child.Name.overrideUnit = saved.nameOverride
    child.HealthValueText.overrideUnit = saved.healthOverride
    UpdateChild(child, group)
end

-- constructor.lua reads group.isForced while laying out the children
local function ForceChildren(group)
    group.isForced = true
    local limit
    if group.groupName == "party" and GW.settings.groupFrames.party.showPlayer == false then
        limit = MAX_PARTY_MEMBERS + 1
    end
    ForEachChild(group, ForceChild, group, limit)
end

-- a negative starting index makes the header create that many empty slots, which we fill:
-- one for the tank list, a group of five, or every member slot the wide layout shows
local function GetConfigStartingIndex(group)
    if group.groupName == "maintank" then
        return -1
    end
    local settings = GW.settings.groupFrames[group.groupName]
    if not settings.wideSorting then
        return -4
    end
    local slots = (group.numGroups or 1) * (settings.groupsPerColumn or 1) * MEMBERS_PER_RAID_GROUP
    return -(min(slots, MAX_RAID_MEMBERS) + 1)
end

-- the header rebuilds its children on attribute changes, fill them again afterwards
local function OnGroupAttributeChanged(group)
    if not group:IsShown() or not (group.forceShow or group:GetParent().forceShow) then return end

    local index = GetConfigStartingIndex(group)
    if group:GetAttribute("startingIndex") ~= index then
        group:SetAttribute("startingIndex", index)
        ForceChildren(group)
    end
end

-- only children oUF has styled carry our elements (see constructor.lua)
local function UpdateStyledChildren(header, group)
    for _, child in ipairs({ group:GetChildren() }) do
        if child.style then
            UpdateChild(child, header, header.groupName)
        end
    end
end

local function SetGroupConfigMode(header, group, enabled)
    group.forceShow = header.forceShow
    group.forceShowAuras = header.forceShowAuras

    if not hookedGroups[group] then
        hookedGroups[group] = true
        group:HookScript("OnAttributeChanged", OnGroupAttributeChanged)
    end

    if enabled then
        HideVisibilityAttributes(group)
        if group:IsShown() then
            OnGroupAttributeChanged(group)
        end
    else
        RestoreVisibilityAttributes(group)
        group.isForced = nil
        ForEachChild(group, ReleaseChild, group)
        group:SetAttribute("startingIndex", 1)
    end
    UpdateStyledChildren(header, group)
end

local function DriveVisibility(frame, state)
    if drivenVisibility[frame] ~= state then
        RegisterStateDriver(frame, "visibility", state)
        drivenVisibility[frame] = state
    end
end

local function ApplyConfigVisibility(header)
    DriveVisibility(header, "show")
    -- wide sorting puts every member into the first group
    local wideSorting = GW.settings.groupFrames[header.groupName].wideSorting
    ForEachGroup(header, function(group, i)
        DriveVisibility(group, (wideSorting and i > 1) and "hide" or "show")
    end)
end

local function ApplyConfigFrameSizes(header)
    local settings = GW.settings.groupFrames[header.groupName]
    local width, height = tonumber(settings.width), tonumber(settings.height)
    if not width or not height then return end

    ForEachGroup(header, function(group)
        ForEachChild(group, function(child)
            if child.isForced then
                child.unitWidth, child.unitHeight = width, height
                child:SetSize(width, height)
            end
        end)
    end)
end

local function ToggleGridConfigurationMode(header, enabled)
    if InCombatLockdown() then return end

    enabled = enabled == true
    header.forceShow = enabled or nil
    header.forceShowAuras = enabled or nil
    header.isForced = enabled or nil

    if enabled then
        activeHeaders[header] = true
        UseFakeEnv()
        ApplyConfigVisibility(header)
        ForEachGroup(header, function(group) SetGroupConfigMode(header, group, true) end)
        return
    end

    activeHeaders[header] = nil
    drivenVisibility[header] = nil
    RestoreRealEnv()
    ForEachGroup(header, function(group)
        drivenVisibility[group] = nil
        SetGroupConfigMode(header, group, false)
    end)

    GW.UpdateGroupVisibility(header, header.groupName, GW.settings.groupFrames[header.groupName].enabled)
    -- drops the fake values from the frames
    GW.UpdateGridSettings(header.groupName, nil, true)
    -- lets the header run its full update like after a loading screen
    local onEvent = header:GetScript("OnEvent")
    if onEvent then
        onEvent(header, "PLAYER_ENTERING_WORLD")
    end
end
GW.ToggleGridConfigurationMode = ToggleGridConfigurationMode

local function RefreshGridConfigurationMode(profile, updateChildren, skipHeaderUpdate)
    local header = type(profile) == "table" and profile or GW.GridGroupHeaders and GW.GridGroupHeaders[profile]
    if not (header and header.forceShow) or InCombatLockdown() then return end

    if not skipHeaderUpdate then
        header.forceConfigHeaderUpdate = updateChildren or nil
        GW.UpdateGridHeader(header.groupName)
        header.forceConfigHeaderUpdate = nil
    end

    ApplyConfigVisibility(header)
    ApplyConfigFrameSizes(header)
    if updateChildren then
        ForEachGroup(header, function(group) SetGroupConfigMode(header, group, true) end)
    end
end
GW.RefreshGridConfigurationMode = RefreshGridConfigurationMode

-- secure frames can not change in combat, so config mode ends when a fight starts
local combatWatcher = CreateFrame("Frame")
combatWatcher:RegisterEvent("PLAYER_REGEN_DISABLED")
combatWatcher:SetScript("OnEvent", function()
    for _, header in pairs(GW.GridGroupHeaders) do
        if header.forceShow then
            ToggleGridConfigurationMode(header)
        end
    end
end)
