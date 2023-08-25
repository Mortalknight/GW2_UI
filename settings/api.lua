local _, GW = ...

local GW_DEFAULT = GW.DEFAULTS
local GW_PRIVATE_DEFAULT = GW.PRIVATE_DEFAULT
local LibBase64 = GW.Libs.LibBase64
local Compress = GW.Libs.Compress
local Serializer = GW.Libs.Serializer
local Deflate = GW.Libs.Deflate

local EXPORT_PREFIX = "!GW2!"
Deflate.compressLevel = {level = 5}

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

local function GetDefault(name)
    return GW_DEFAULT[name]
end
GW.GetDefault = GetDefault

local function GetSetting(name, perSpec)
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

    if perSpec then
        local spec = GetSpecializationInfo(GW.myspec)
        if type(settings[name]) ~= "table" then
            settings[name] = {[0] = settings[name]}
        end
        if settings[name][spec] == nil then
            settings[name][spec] = settings[name][0]
        end
        return settings[name][spec]
    else
        return settings[name]
    end
end
GW.GetSetting = GetSetting

local function SetSetting(name, state, perSpec, tableID)
    local profileIndex = GetActiveProfile()

    local settings = GW_PRIVATE_DEFAULT[name] and GW2UI_PRIVATE_SETTINGS or GW2UI_SETTINGS_DB_03
    if GW_PRIVATE_DEFAULT[name] == nil and profileIndex and GW2UI_SETTINGS_PROFILES[profileIndex] then
        settings = GW2UI_SETTINGS_PROFILES[profileIndex]
        settings["profileLastUpdated"] = date("%m/%d/%y %H:%M:%S")
    end

    if perSpec then
        local spec = GetSpecializationInfo(GW.myspec)
        if type(settings[name]) ~= "table" then
            settings[name] = {[0] = settings[name]}
        end
        settings[name][spec] = state
    elseif tableID then
        if type(settings[name][tableID]) == "table" then
            settings[name][tableID].enable = state
        else
            settings[name][tableID] = state
        end
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

local function GetExportString(profileIndex, profileName)
    local profileTable = GW2UI_SETTINGS_PROFILES[profileIndex]

    local serialData = Serializer:Serialize(profileTable)
    local exportString = format("%s::%s::%s::%s", serialData, profileName, GW.myname, "Retail")
    local compressedData = Deflate:CompressDeflate(exportString, Deflate.compressLevel)
    local printableString = Deflate:EncodeForPrint(compressedData)

    return printableString and format("%s%s", EXPORT_PREFIX, printableString) or nil
end
GW.GetExportString = GetExportString

local function GetImportStringType(dataString)
    return (strmatch(dataString, "^" .. EXPORT_PREFIX) and "Deflate") or ""
end
GW.GetImportStringType = GetImportStringType

local function DecodeProfile(dataString)
    local stringType = GetImportStringType(dataString)
    local profileName, profilePlayer, version, profileData, success

    if stringType == "Deflate" then
        local data = gsub(dataString, "^" .. EXPORT_PREFIX, "")
        local decodedData = Deflate:DecodeForPrint(data)
        local decompressed = Deflate:DecompressDeflate(decodedData)

        if not decompressed then
            return
        end

        local serializedData, profileInfos = GW.splitString(decompressed, "^^::")

        if not serializedData or not profileInfos then
            return
        end

        serializedData = format("%s%s", serializedData, "^^")
        profileName, profilePlayer, version = GW.splitString(profileInfos, "::")
        success, profileData = Serializer:Deserialize(serializedData)

        if not success then
            return
        end
    end

    return profileName, profilePlayer, version, profileData
end
GW.DecodeProfile = DecodeProfile

local function ConvertOldProfileString(dataString)
    if strfind(dataString, EXPORT_PREFIX) then
        return false, "Error: Input already uses the new format."
    end
    if not LibBase64:IsBase64(dataString) then
        return false, "Error: Input doesn't look like a correct profile."
    end

    local decodedData = LibBase64:Decode(dataString)
    local decompressedData, decompressedMessage = Compress:Decompress(decodedData)

    if not decompressedData then
        return false, format("Error decompressing data: %s.", decompressedMessage)
    end

    local compressedData = Deflate:CompressDeflate(decompressedData, {level = 5})
    local profileExport = Deflate:EncodeForPrint(compressedData)

    return true, EXPORT_PREFIX .. profileExport
end
GW.ConvertOldProfileString = ConvertOldProfileString

local function ImportProfile(dataString)
    local profileName, profilePlayer, version, profileDataString = DecodeProfile(dataString)

    if not profileDataString or version ~= "Retail" then
        return
    end

    GW.addProfile(profileName, profileDataString)

    return profileName, profilePlayer, version
end
GW.ImportProfile = ImportProfile
