---@class GW2
local GW = select(2, ...)
local GW_UF = GW.oUF

local configEnv
local originalEnvs = {}
local overrideFuncs = {}
local activeConfigHeaders = {}
local configModeUnits = {}

local eventFrame = CreateFrame("Frame")
local NIL_ATTRIBUTE = {}
local CONFIG_MODE_UNIT_PREFIX = "gw2config"
local CONFIG_MODE_ROLES = {"TANK", "HEALER", "DAMAGER"}
local CONFIG_MODE_POWER_TYPES = {"MANA", "RAGE", "FOCUS", "ENERGY", "RUNIC_POWER"}

local function GetConfigModeUnitData(unit)
    return configModeUnits[unit]
end

local function GetConfigModeIndex(header, index)
    local headerName = header:GetName()
    local groupIndex = headerName and tonumber(strmatch(headerName, "Group(%d+)$")) or 1

    return ((groupIndex or 1) - 1) * 5 + index
end

local function GetConfigModeName(index)
    if GW.CreditsList and #GW.CreditsList > 0 then
        return GW.CreditsList[((index - 1) % #GW.CreditsList) + 1]
    end

    return "Test Name " .. index
end

local function GetConfigModeData(frame, header, index)
    if frame.configModeData then
        return frame.configModeData
    end

    local configIndex = GetConfigModeIndex(header, index)
    local headerName = header:GetName() or header.groupName
    local classIndex = ((configIndex - 1) % #CLASS_SORT_ORDER) + 1
    local roleIndex = ((configIndex - 1) % #CONFIG_MODE_ROLES) + 1
    local powerTypeIndex = ((configIndex - 1) % #CONFIG_MODE_POWER_TYPES) + 1
    local data = {
        unit = CONFIG_MODE_UNIT_PREFIX .. ":" .. headerName .. ":" .. index,
        name = GetConfigModeName(configIndex),
        classToken = CLASS_SORT_ORDER[classIndex],
        health = 35 + ((configIndex * 17) % 65),
        maxHealth = 100,
        power = 20 + ((configIndex * 23) % 80),
        maxPower = 100,
        role = CONFIG_MODE_ROLES[roleIndex],
        powerType = CONFIG_MODE_POWER_TYPES[powerTypeIndex]
    }

    frame.configModeData = data
    configModeUnits[data.unit] = data

    return data
end

local function createConfigEnv()
    if configEnv then return end
    configEnv = setmetatable({
        UnitPower = function (unit, displayType)
            local data = GetConfigModeUnitData(unit)
            if data then
                return data.power
            end
            if unit:find("target") or unit:find("focus") then
                return UnitPower(unit, displayType)
            end

            return UnitPower(unit, displayType)
        end,
        UnitPowerMax = function(unit, displayType)
            local data = GetConfigModeUnitData(unit)
            if data then
                return data.maxPower
            end

            return UnitPowerMax(unit, displayType)
        end,
        UnitHealth = function(unit)
            local data = GetConfigModeUnitData(unit)
            if data then
                return data.health
            end
            if unit:find("target") or unit:find("focus") then
                return UnitHealth(unit)
            end

            return UnitHealth(unit)
        end,
        UnitHealthMax = function(unit)
            local data = GetConfigModeUnitData(unit)
            if data then
                return data.maxHealth
            end

            return UnitHealthMax(unit)
        end,
        UnitHealthMissing = function(unit)
            local data = GetConfigModeUnitData(unit)
            if data then
                return max(data.maxHealth - data.health, 0)
            end

            return UnitHealthMissing(unit)
        end,
        UnitHealthPercent = function(unit, usePredictedHealth, overrideHealthScale)
            local data = GetConfigModeUnitData(unit)
            if data then
                return data.maxHealth > 0 and (data.health / data.maxHealth * 100) or 0
            end

            return UnitHealthPercent(unit, usePredictedHealth, overrideHealthScale)
        end,
        UnitName = function(unit)
            local data = GetConfigModeUnitData(unit)
            if data then
                return data.name
            end
            if unit:find("target") or unit:find("focus") then
                return UnitName(unit)
            end

            return UnitName(unit)
        end,
        UnitClass = function(unit)
            local data = GetConfigModeUnitData(unit)
            if data then
                return LOCALIZED_CLASS_NAMES_MALE[data.classToken], data.classToken
            end
            if unit:find("target") or unit:find("focus") then
                return UnitClass(unit)
            end

            return UnitClass(unit)
        end,
        UnitGroupRolesAssigned = function(unit)
            local data = GetConfigModeUnitData(unit)
            if data then
                return data.role
            end

            return UnitGroupRolesAssigned(unit)
        end,
        Hex = function(r, g, b)
            if type(r) == "table" then
                if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
            end
            return format("|cff%02x%02x%02x", r*255, g*255, b*255)
        end,
    }, {
        __index = _G,
        __newindex = function(_, key, value) _G[key] = value end,
    })

    overrideFuncs["GW2_Grid:name"] = GW_UF.Tags.Methods["GW2_Grid:name"]
    overrideFuncs["GW2_Grid:leaderIcon"] = GW_UF.Tags.Methods["GW2_Grid:leaderIcon"]
    overrideFuncs["GW2_Grid:assistIcon"] = GW_UF.Tags.Methods["GW2_Grid:assistIcon"]
    overrideFuncs["GW2_Grid:roleIcon"] = GW_UF.Tags.Methods["GW2_Grid:roleIcon"]
    overrideFuncs["GW2_Grid:realmFlag"] = GW_UF.Tags.Methods["GW2_Grid:realmFlag"]
    overrideFuncs["GW2_Grid:mainTank"] = GW_UF.Tags.Methods["GW2_Grid:mainTank"]
    overrideFuncs["GW2_Grid:healtValue"] = GW_UF.Tags.Methods["GW2_Grid:healtValue"]
end

local forcedVisibilityAttributes = {
    showRaid = true,
    showParty = true,
    showSolo = true
}

local canHidePlayer = {
    PARTY = true
}

local function HasActiveConfigHeader()
    for header in pairs(activeConfigHeaders) do
        if header.forceShow then
            return true
        end
    end

    return false
end

local function EnableConfigEnvironment()
    createConfigEnv()

    for _, func in pairs(overrideFuncs) do
        if type(func) == "function" and not originalEnvs[func] then
            originalEnvs[func] = getfenv(func)
            setfenv(func, configEnv)
        end
    end
end

local function RestoreConfigEnvironment()
    if HasActiveConfigHeader() then return end

    for func, env in pairs(originalEnvs) do
        setfenv(func, env)
        originalEnvs[func] = nil
    end
end

local function StoreForcedAttributes(group)
    if group.configModeAttributes then return end

    group.configModeAttributes = {}
    for key in pairs(forcedVisibilityAttributes) do
        local value = group:GetAttribute(key)
        group.configModeAttributes[key] = value == nil and NIL_ATTRIBUTE or value
    end
end

local function RestoreForcedAttributes(group)
    local attributes = group.configModeAttributes
    if not attributes then return end

    for key in pairs(forcedVisibilityAttributes) do
        local value = attributes[key]
        group:SetAttribute(key, value == NIL_ATTRIBUTE and nil or value)
    end

    group.configModeAttributes = nil
end

local function ForceShow2(frame, header)
    if InCombatLockdown() then return end
    if not frame.isForced then
        frame.oldUnit = frame.unit
        frame.oldRealUnit = frame.realUnit
        frame.oldNameOverrideUnit = frame.Name and frame.Name.overrideUnit
        frame.oldHealthValueOverrideUnit = frame.HealthValueText and frame.HealthValueText.overrideUnit
        frame.unit = "player"
        frame.isForced = true
        frame.oldOnUpdate = frame:GetScript("OnUpdate")
    end

    local configModeData = GetConfigModeData(frame, header, frame:GetID())
    frame.forceShowAuras = true
    frame:SetScript("OnUpdate", nil)
    frame:EnableMouse(false)
    frame:Show()

    UnregisterUnitWatch(frame)
    RegisterUnitWatch(frame, true)

    frame.realUnit = configModeData.unit
    frame.Name.overrideUnit = true
    frame.HealthValueText.overrideUnit = true

    GW["UpdateGrid" ..  header.profileName .. "Frame"](frame)
end

local function ForceShow(frame, index, length, header)
    frame:SetID(index)

    if not length or (index % length) > 0 then
        ForceShow2(frame, header)
    end
end

local function ShowChildUnits(header)
    header.isForced = true

    local length -- Limit number of players shown, if Display Player option is disabled
    if canHidePlayer[header.groupName] and GW.GridSettings.partyGridShowPlayer == false then
        length = MAX_PARTY_MEMBERS + 1
    end

    local idx = 1
    local child = header:GetAttribute("child"..idx)
    while child do
        ForceShow(child, idx, length, header)
        idx = idx + 1
        child = header:GetAttribute("child"..idx)
    end
end

local function UnforceShow(frame, header)
    if InCombatLockdown() then return end
    if not frame.isForced then return end

    frame.unit = frame.oldUnit or frame.unit
    frame.realUnit = frame.oldRealUnit
    frame.oldUnit = nil
    frame.oldRealUnit = nil
    frame.isForced = nil
    frame.forceShowAuras = nil
    frame:EnableMouse(true)

    -- Ask the SecureStateDriver to show/hide the frame for us
    UnregisterUnitWatch(frame)
    RegisterUnitWatch(frame)

    if frame.oldOnUpdate then
        frame:SetScript("OnUpdate", frame.oldOnUpdate)
        frame.oldOnUpdate = nil
    end
    frame.Name.overrideUnit = frame.oldNameOverrideUnit
    frame.HealthValueText.overrideUnit = frame.oldHealthValueOverrideUnit

    frame.oldNameOverrideUnit = nil
    frame.oldHealthValueOverrideUnit = nil

    GW["UpdateGrid" ..  header.profileName .. "Frame"](frame)
end

local function UnshowChildUnits(header)
    header.isForced = nil

    local idx = 1
    local child = header:GetAttribute("child"..idx)
    while child do
        UnforceShow(child, header)
        idx = idx + 1
        child = header:GetAttribute("child"..idx)
    end
end

local function OnAttributeChanged(self, attr)
    if not self:IsShown() or (not self:GetParent().forceShow and not self.forceShow) then return end

    local isTank = self.groupName == "TANK"
    local index = isTank and -1 or not GW.GridSettings.raidWideSorting[self.groupName] and -4 or -(min((self.numGroups or 1) * ((GW.GridSettings.groupsPerColumnRow[self.groupName] or 1) * 5), MAX_RAID_MEMBERS) + 1)
    if self:GetAttribute("startingIndex") ~= index then
        self:SetAttribute("startingIndex", index)
        ShowChildUnits(self)
    elseif isTank then -- for showing target frames
        if attr == "startingindex" then
            self.waitForTarget = nil
        elseif self.waitForTarget and attr == "statehidden" then
            ShowChildUnits(self)
            self.waitForTarget = nil
        end
    end
end

local function HeaderForceShow(header, group, configMode)
    group.forceShow = header.forceShow
    group.forceShowAuras = header.forceShowAuras

    if not group.hasOnAttributeChanged then
        group:HookScript("OnAttributeChanged", OnAttributeChanged)
        group.hasOnAttributeChanged = true
    end


    if configMode then
        StoreForcedAttributes(group)
        for key in pairs(forcedVisibilityAttributes) do
            group:SetAttribute(key, nil)
        end

        if group:IsShown() then
            OnAttributeChanged(group)
        end

        for _, child in ipairs({ group:GetChildren() }) do
            GW["UpdateGrid" ..  header.profileName .. "Frame"](child, header.groupName)
        end
    else
        RestoreForcedAttributes(group)

        UnshowChildUnits(group)
        group:SetAttribute("startingIndex", 1)

        for _, child in ipairs({ group:GetChildren() }) do
            GW["UpdateGrid" ..  header.profileName .. "Frame"](child, header.groupName)
        end
    end
end

local function UpdateConfigGroupVisibility(header)
    if header.configModeVisibility ~= "show" then
        RegisterStateDriver(header, "visibility", "show")
        header.configModeVisibility = "show"
    end

    for i = 1, header.numGroups do
        local group = header.groups[i]
        if group then
            local visibility = header.numGroups > 1 and i > 1 and GW.GridSettings.raidWideSorting[header.groupName] and "hide" or "show"
            if group.configModeVisibility ~= visibility then
                RegisterStateDriver(group, "visibility", visibility)
                group.configModeVisibility = visibility
            end
        end
    end
end

local function UpdateConfigFrameSizes(header)
    local width = tonumber(GW.GridSettings.raidWidth[header.groupName])
    local height = tonumber(GW.GridSettings.raidHeight[header.groupName])
    if not width or not height then return end

    for i = 1, header.numGroups do
        local group = header.groups[i]
        if group then
            local idx = 1
            local child = group:GetAttribute("child" .. idx)
            while child do
                if child.isForced then
                    child.unitWidth = width
                    child.unitHeight = height
                    child:SetSize(width, height)
                end
                idx = idx + 1
                child = group:GetAttribute("child" .. idx)
            end
        end
    end
end

local function ToggleGridConfigurationMode(header, enabled)
    if InCombatLockdown() then return end

    enabled = enabled == true
    header.forceShow = enabled or nil
    header.forceShowAuras = enabled or nil
    header.isForced = enabled or nil

    if enabled then
        activeConfigHeaders[header] = true
        EnableConfigEnvironment()

        RegisterStateDriver(header, "visibility", "show")
        header.configModeVisibility = "show"
        for i = 1, header.numGroups do
            local group = header.groups[i]
            if group then
                local visibility = header.numGroups > 1 and i > 1 and GW.GridSettings.raidWideSorting[header.groupName] and "hide" or "show"
                RegisterStateDriver(group, "visibility", visibility)
                group.configModeVisibility = visibility

                HeaderForceShow(header, group, enabled)
            end
        end
    else
        activeConfigHeaders[header] = nil
        header.configModeVisibility = nil
        RestoreConfigEnvironment()

        for i = 1, header.numGroups do
            local group = header.groups[i]
            if group then
                group.configModeVisibility = nil
                HeaderForceShow(header, group, enabled)
            end
        end

        GW.UpdateGroupVisibility(header, header.groupName, GW.GridSettings.enabled[header.groupName])

        -- reset the stored dummy values
        GW.UpdateGridSettings(header.groupName, nil, true)

        local onEvent = header:GetScript("OnEvent")
        if onEvent then
            onEvent(header, "PLAYER_ENTERING_WORLD")
        end
    end
end
GW.ToggleGridConfigurationMode = ToggleGridConfigurationMode

local function RefreshGridConfigurationMode(profile, updateChildren, skipHeaderUpdate)
    local header = type(profile) == "table" and profile or GW.GridGroupHeaders and GW.GridGroupHeaders[profile]
    if header and header.forceShow then
        if InCombatLockdown() then return end

        if not skipHeaderUpdate then
            header.forceConfigHeaderUpdate = updateChildren or nil
            GW.UpdateGridHeader(header.groupName)
            header.forceConfigHeaderUpdate = nil
        end

        UpdateConfigGroupVisibility(header)
        UpdateConfigFrameSizes(header)

        if updateChildren then
            for i = 1, header.numGroups do
                local group = header.groups[i]
                if group then
                    HeaderForceShow(header, group, true)
                end
            end
        end
    end
end
GW.RefreshGridConfigurationMode = RefreshGridConfigurationMode

eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:SetScript("OnEvent", function()
    for _, header in pairs(GW.GridGroupHeaders) do
		if header.forceShow then
			ToggleGridConfigurationMode(header)
		end
	end
end)
