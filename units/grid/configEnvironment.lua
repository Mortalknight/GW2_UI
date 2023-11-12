local _, GW = ...
local GW_UF = GW.oUF

local configEnv
local originalEnvs = {}
local overrideFuncs = {}

local eventFrame = CreateFrame("Frame")

local function createConfigEnv()
    if configEnv then return end
    configEnv = setmetatable({
        UnitPower = function (unit, displayType)
            if unit:find("target") or unit:find("focus") then
                return UnitPower(unit, displayType)
            end

            return random(1, UnitPowerMax(unit, displayType) or 1)
        end,
        UnitHealth = function(unit)
            if unit:find("target") or unit:find("focus") then
                return UnitHealth(unit)
            end

            return random(1, UnitHealthMax(unit))
        end,
        UnitName = function(unit)
            if unit:find("target") or unit:find("focus") then
                return UnitName(unit)
            end
            if GW.CreditsList then
                local max = #GW.CreditsList
                return GW.CreditsList[random(1, max)]
            end
            return "Test Name"
        end,
        UnitClass = function(unit)
            if unit:find("target") or unit:find("focus") then
                return UnitClass(unit)
            end

            local classToken = CLASS_SORT_ORDER[random(1, #(CLASS_SORT_ORDER))]
            return LOCALIZED_CLASS_NAMES_MALE[classToken], classToken
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

local attributeBlacklist = {
    showRaid = true,
    showParty = true,
    showSolo = true
}

local allowHidePlayer = {
    party = false,
    RAID10 = false,
    RAID25 = false,
    RAID40 = false
}

local function ForceShow2(frame, header)
    if InCombatLockdown() then return end
    if not frame.isForced then
        frame.oldUnit = frame.unit
        frame.unit = "player"
        frame.isForced = true
        frame.oldOnUpdate = frame:GetScript("OnUpdate")
    end

    frame.forceShowAuras = true
    frame:SetScript("OnUpdate", nil)
    frame:EnableMouse(false)
    frame:Show()

    UnregisterUnitWatch(frame)
    RegisterUnitWatch(frame, true)

    GW["UpdateGrid" ..  header.profileName .. "Frame"](frame)

    if frame.Update then
        frame:Update()
    end
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
    if allowHidePlayer[header.groupName] then
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
    frame.oldUnit = nil
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

    GW["UpdateGrid" ..  header.profileName .. "Frame"](frame)

    if frame.Update then
        frame:Update()
    end
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
    if group:IsShown() then
        group.forceShow = header.forceShow
        group.forceShowAuras = header.forceShowAuras

        if not group.hasOnAttributeChanged then
            group:HookScript("OnAttributeChanged", OnAttributeChanged)
            group.hasOnAttributeChanged = true
        end


        if configMode then
            for key in pairs(attributeBlacklist) do
                group:SetAttribute(key, nil)
            end

            OnAttributeChanged(group)

            for _, child in ipairs({ group:GetChildren() }) do
                GW["UpdateGrid" ..  header.profileName .. "Frame"](child, header.groupName)
            end
        else
            for key in pairs(attributeBlacklist) do
                group:SetAttribute(key, true)
            end

            UnshowChildUnits(group)
            group:SetAttribute("startingIndex", 1)

            for _, child in ipairs({ group:GetChildren() }) do
                GW["UpdateGrid" ..  header.profileName .. "Frame"](child, header.groupName)
            end
        end
    end
end

local function ToggleGridConfigurationMode(header, enabled)
    if InCombatLockdown() then return end

    createConfigEnv()
    header.forceShow = enabled
    header.forceShowAuras = enabled
    header.isForced = enabled

    if enabled then
        for _, func in pairs(overrideFuncs) do
            if type(func) == "function" then
                if not originalEnvs[func] then
                    originalEnvs[func] = getfenv(func)
                    setfenv(func, configEnv)
                end
            end
        end

        RegisterStateDriver(header, "visibility", "show")
        for i = 1, header.numGroups do
            local group = header.groups[i]
            if group then
                RegisterStateDriver(group, "visibility", "show")

                -- register the correct visibility state driver
                if header.numGroups > 1 and i > 1 then
                    if GW.GridSettings.raidWideSorting[header.groupName] then
                        RegisterStateDriver(group, "visibility", "hide")
                    end
                end

                HeaderForceShow(header, group, enabled)
            end
        end
    else
        for func, env in pairs(originalEnvs) do
            setfenv(func, env)
            originalEnvs[func] = nil
        end

        for i = 1, header.numGroups do
            local group = header.groups[i]
            if group then
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

eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:SetScript("OnEvent", function()
    for _, header in pairs(GW.GridGroupHeaders) do
		if header.forceShow then
			ToggleGridConfigurationMode(header)
		end
	end
end)