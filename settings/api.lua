local _, GW = ...

local GW_DEFAULT = GW.DEFAULTS
local GW_PRIVATE_DEFAULT = GW.PRIVATE_DEFAULT
local LibBase64 = GW.Libs.LibBase64
local Compress = GW.Libs.Compress
local Serializer = GW.Libs.Serializer

local function GetAllLayouts()
    if GW2UI_LAYOUTS == nil then
        GW2UI_LAYOUTS = {}
    end
    return GW2UI_LAYOUTS
end
GW.GetAllLayouts = GetAllLayouts

local function GetLayoutById(id)
    if GW2UI_LAYOUTS == nil then
        GW2UI_LAYOUTS = {}
    end
    return GW2UI_LAYOUTS[id] or nil
end
GW.GetLayoutById = GetLayoutById

local function GetAllPrivateLayouts()
    if GW2UI_PRIVATE_LAYOUTS == nil then
        GW2UI_PRIVATE_LAYOUTS = {}
    end
    return GW2UI_PRIVATE_LAYOUTS
end
GW.GetAllPrivateLayouts = GetAllPrivateLayouts

local function GetPrivateLayoutByLayoutId(layoutId)
    if GW2UI_PRIVATE_LAYOUTS == nil then
        GW2UI_PRIVATE_LAYOUTS = {}
    end
    for k, _ in pairs(GW2UI_PRIVATE_LAYOUTS) do
        if GW2UI_PRIVATE_LAYOUTS[k].layoutId == layoutId then
            return GW2UI_PRIVATE_LAYOUTS[k]
        end
    end
    return nil
end
GW.GetPrivateLayoutByLayoutId = GetPrivateLayoutByLayoutId

local function DeletePrivateLayoutByLayoutId(layoutId)
    if GW2UI_PRIVATE_LAYOUTS == nil then
        GW2UI_PRIVATE_LAYOUTS = {}
    end
    for k, _ in pairs(GW2UI_PRIVATE_LAYOUTS) do
        if GW2UI_PRIVATE_LAYOUTS[k].layoutId == layoutId then
            GW2UI_PRIVATE_LAYOUTS[k] = nil
        end
    end
end
GW.DeletePrivateLayoutByLayoutId = DeletePrivateLayoutByLayoutId

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

local function GetSetting(name)
    if not name then
        return nil
    end
    local profileIndex = GetActiveProfile()

    if GW2UI_SETTINGS_PROFILES == nil then
        GW2UI_SETTINGS_PROFILES = {}
    end
    if GW2UI_SETTINGS_DB_03 == nil then
        GW2UI_SETTINGS_DB_03 = GW_DEFAULT
    end
    if GW2UI_PRIVATE_SETTINGS == nil then
        GW2UI_PRIVATE_SETTINGS = {}
    end

    local settings = GW_PRIVATE_DEFAULT[name] and GW2UI_PRIVATE_SETTINGS or profileIndex and GW2UI_SETTINGS_PROFILES[profileIndex] or GW2UI_SETTINGS_DB_03

    if settings[name] == nil then
        settings[name] = GW_PRIVATE_DEFAULT[name] or GetDefault(name)
    end

    return settings[name]
end
GW.GetSetting = GetSetting

local function SetSetting(name, state, tableID)
    local profileIndex = GetActiveProfile()

    local settings = GW_PRIVATE_DEFAULT[name] and GW2UI_PRIVATE_SETTINGS or GW2UI_SETTINGS_DB_03
    if GW_PRIVATE_DEFAULT[name] == nil and profileIndex and GW2UI_SETTINGS_PROFILES[profileIndex] then
        settings = GW2UI_SETTINGS_PROFILES[profileIndex]
        settings["profileLastUpdated"] = date("%m/%d/%y %H:%M:%S")
    end

    if tableID then
        settings[name][tableID] = state
    else
        settings[name] = state
    end
end
GW.SetSetting = SetSetting

local function SetOverrideIncompatibleAddons(setting, value)
    local profileIndex = GetActiveProfile()

    local settings = GW2UI_SETTINGS_DB_03
    if profileIndex and GW2UI_SETTINGS_PROFILES[profileIndex] then
        settings = GW2UI_SETTINGS_PROFILES[profileIndex]
        settings["profileLastUpdated"] = date("%m/%d/%y %H:%M:%S")
    end

    settings.IncompatibleAddons[setting].Override = value
    DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. GW.L["Incompatible Addons behavior Overridden. Needs a reload to take effect."]):gsub("*", GW.Gw2Color))
end
GW.SetOverrideIncompatibleAddons = SetOverrideIncompatibleAddons

local function ResetToDefault()
    local profileIndex = GetActiveProfile()
    local allLayouts = GetAllLayouts()
    local oldUsername, oldProfilename = nil, nil

    if profileIndex ~= nil and GW2UI_SETTINGS_PROFILES[profileIndex] ~= nil then
        oldUsername = GW2UI_SETTINGS_PROFILES[profileIndex].profileCreatedCharacter
        oldProfilename = GW2UI_SETTINGS_PROFILES[profileIndex].profilename
        GW2UI_SETTINGS_PROFILES[profileIndex] = nil
        GW2UI_SETTINGS_PROFILES[profileIndex] = GW.copyTable(nil, GW_DEFAULT)
        GW2UI_PRIVATE_SETTINGS = nil
        GW2UI_PRIVATE_SETTINGS = GW.copyTable(nil, GW_PRIVATE_DEFAULT)
        GW2UI_SETTINGS_PROFILES[profileIndex].profileLastUpdated = date("%m/%d/%y %H:%M:%S")
        GW2UI_SETTINGS_PROFILES[profileIndex].profileCreatedDate = date("%m/%d/%y %H:%M:%S")
        GW2UI_SETTINGS_PROFILES[profileIndex].profileCreatedCharacter = oldUsername or UNKNOWN
        GW2UI_SETTINGS_PROFILES[profileIndex].profilename = oldProfilename or UNKNOWN
        -- also rest the matching profile layout
        for i = 0, #allLayouts do
            if allLayouts[i] and allLayouts[i].profileLayout and allLayouts[i].profileId == profileIndex then
                GW2UI_LAYOUTS[i] = nil
                break
            end
        end

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

do -- This code is from WeakAuras Team, creadits goes to them
    local function recurse(table, level, ret)
        for i, v in pairs(table) do
            ret = ret .. strrep("    ", level) .. "["
            if type(i) == "string" then
                ret = ret .. '"' .. i .. '"'
            else
                ret = ret .. i
            end
            ret = ret .. "] = "

            if type(v) == "number" then
                ret = ret .. v .. ",\n"
            elseif type(v) == "string" then
                ret = ret .. '"' .. v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\124", "\124\124") .. '",\n'
            elseif type(v) == "boolean" then
                if v then 
                    ret = ret .. "true,\n"
                else
                    ret = ret .. "false,\n"
                end
            elseif type(v) == "table" then
                ret = ret .. "{\n"
                ret = recurse(v, level + 1, ret)
                ret = ret .. strrep( "    ", level) .. "},\n"
            else
                ret = ret .. '"' .. tostring(v) .. '",\n'
            end
        end

        return ret
    end

    local function TableToLuaString(inTable)
        if type(inTable) ~= "table" then
            return
        end

        local exportString = "{\n"
        exportString = recurse(inTable, 1, exportString)
        exportString = exportString .. "}"

        return exportString
    end
    GW.TableToLuaString = TableToLuaString

    local function GetExportString(profileIndex, profileName)
        local profileTable = GW2UI_SETTINGS_PROFILES[profileIndex]
        local serialData = Serializer:Serialize(profileTable)
        local exportString = format("%s::%s::%s::%s", serialData, profileName, GW.myname, "Classic")
        local compressedData = Compress:Compress(exportString)
        local encodedData = LibBase64:Encode(compressedData)

        return encodedData
    end
    GW.GetExportString = GetExportString
end

local function DecodeProfile(dataString)
    local dataType = LibBase64:IsBase64(dataString) and "base64" or strfind(dataString, "{") and "table" or nil
    local profileName, profilePlayer, version, profileData, success

    if dataType == "base64" then
        local decodedData = LibBase64:Decode(dataString)
        local decompressedData, decompressedMessage = Compress:Decompress(decodedData)

        if not decompressedData then
            return
        end

        local serializedData, profileInfos = GW.splitString(decompressedData, "^^::")

        if not serializedData or not profileInfos then
            return
        end

        serializedData = format("%s%s", serializedData, "^^")

        profileName, profilePlayer, version = GW.splitString(profileInfos, "::")

        success, profileData = Serializer:Deserialize(serializedData)

        if not success then
            return
        end
    elseif dataType == "table" then
        local profileDataAsString, profileInfos = GW.splitString(dataString, "}::")

        if not profileDataAsString or not profileInfos then
            return
        end

        profileData = format("%s%s", profileDataAsString, "}")
        profileData = gsub(profileData, "\124\124", "\124")
        profileName, profilePlayer, version = GW.splitString(profileInfos, "::")

        local profileToTable = loadstring(format("%s %s", "return", profileData))
        local pm
        if profileToTable then
            pm, profileData = pcall(profileToTable)
        end

        if pm and (not profileData or type(profileData) ~= "table") then
            return
        end
    end

    return profileName, profilePlayer, version, profileData
end
GW.DecodeProfile = DecodeProfile

local function ImportProfile(dataString)
    local profileName, profilePlayer, version, profileDataString = DecodeProfile(dataString)

    if not profileDataString or version ~= "Classic" then
        return
    end

    GW.addProfile(profileName, profileDataString)

    return profileName, profilePlayer, version
end
GW.ImportProfile = ImportProfile
