local _, GW = ...

local GW_DEFAULT = GW.DEFAULTS
local GW2UI_SETTINGS = {}

local function GetActiveProfile()
    if GW2UI_SETTINGS_DB_03 == nil then
        GW2UI_SETTINGS_DB_03 = {}
    end
    return GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"]
end
GW.GetActiveProfile = GetActiveProfile

local function SetProfileSettings()
    local profileIndex = GetActiveProfile()

    if profileIndex == nil or GW2UI_SETTINGS_PROFILES[profileIndex] == nil then
        return
    end

    for k, v in pairs(GW2UI_SETTINGS_DB_03) do
        GW2UI_SETTINGS_PROFILES[profileIndex][k] = v
    end
end
GW.SetProfileSettings = SetProfileSettings

local function GetDefault(name)
    return GW_DEFAULT[name]
end
GW.GetDefault = GetDefault

local function GetSetting(name, perSpec)
    local profileIndex = GetActiveProfile()

    if GW2UI_SETTINGS_PROFILES == nil then
        GW2UI_SETTINGS_PROFILES = {}
    end
    if GW2UI_SETTINGS_DB_03 == nil then
        GW2UI_SETTINGS_DB_03 = GW_DEFAULT
    end

    local settings = profileIndex and GW2UI_SETTINGS_PROFILES[profileIndex] or GW2UI_SETTINGS_DB_03

    if settings[name] == nil then
        settings[name] = GetDefault(name)
    end

    return settings[name]
end
GW.GetSetting = GetSetting

local function SetSetting(name, state)
    local profileIndex = GetActiveProfile()
    
    local settings = GW2UI_SETTINGS_DB_03
    if profileIndex and GW2UI_SETTINGS_PROFILES[profileIndex] then
        settings = GW2UI_SETTINGS_PROFILES[profileIndex]
        settings["profileLastUpdated"] = date("%m/%d/%y %H:%M:%S")
    end

    settings[name] = state
end
GW.SetSetting = SetSetting

local function ResetToDefault()
    local profileIndex = GetActiveProfile()

    if profileIndex ~= nil and GW2UI_SETTINGS_PROFILES[profileIndex] ~= nil then
        for k, v in pairs(GW_DEFAULT) do
            GW2UI_SETTINGS_PROFILES[profileIndex][k] = v
        end
        GW2UI_SETTINGS_PROFILES[profileIndex]["profileLastUpdated"] = date("%m/%d/%y %H:%M:%S")
        return
    end
    GW2UI_SETTINGS_DB_03 = GW_DEFAULT
end
GW.ResetToDefault = ResetToDefault

local function GetSettingsProfiles()
    if GW2UI_SETTINGS_PROFILES == nil then
        GW2UI_SETTINGS_PROFILES = {}
    end
    return GW2UI_SETTINGS_PROFILES
end
GW.GetSettingsProfiles = GetSettingsProfiles