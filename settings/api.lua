local _, GW = ...

local LibBase64 = GW.Libs.LibBase64
local Compress = GW.Libs.Compress
local Serializer = GW.Libs.Serializer

local function GetAllLayouts()
    if GW.global.layouts == nil then
        GW.global.layouts = {}
    end
    return GW.global.layouts
end
GW.GetAllLayouts = GetAllLayouts

local function GetLayoutById(id)
    if GW.global.layouts == nil then
        GW.global.layouts = {}
    end
    return GW.global.layouts[id] or nil
end
GW.GetLayoutById = GetLayoutById

local function GetAllPrivateLayouts()
    if GW.private.Layouts == nil then
        GW.private.Layouts = {}
    end
    return GW.private.Layouts
end
GW.GetAllPrivateLayouts = GetAllPrivateLayouts

local function GetPrivateLayoutByLayoutId(layoutId)
    if GW.private.Layouts == nil then
        GW.private.Layouts = {}
    end
    for k, _ in pairs(GW.private.Layouts) do
        if GW.private.Layouts[k].layoutId == layoutId then
            return GW.private.Layouts[k]
        end
    end
    return nil
end
GW.GetPrivateLayoutByLayoutId = GetPrivateLayoutByLayoutId

local function DeletePrivateLayoutByLayoutId(layoutId)
    if GW.private.Layouts == nil then
        GW.private.Layouts = {}
    end
    for k, _ in pairs(GW.private.Layouts) do
        if GW.private.Layouts[k].layoutId == layoutId then
            GW.private.Layouts[k] = nil
        end
    end
end
GW.DeletePrivateLayoutByLayoutId = DeletePrivateLayoutByLayoutId

local function SetOverrideIncompatibleAddons(setting, value)
    local profileName = GW.globalSettings:GetCurrentProfile()

    if profileName then
        GW.settings.profileLastUpdated = date("%m/%d/%y %H:%M:%S")
    end

    GW.settings.IncompatibleAddons[setting].Override = value
    GW.Notice(GW.L["Incompatible Addons behavior Overridden. Needs a reload to take effect."])
end
GW.SetOverrideIncompatibleAddons = SetOverrideIncompatibleAddons

local function ResetToDefault()
    local activeProfile = GW.globalSettings:GetCurrentProfile()
    local allLayouts = GetAllLayouts()
    local oldUsername, oldProfilename = nil, nil

    if activeProfile then
        oldUsername = GW.globalSettings.settings.profileCreatedCharacter
        oldProfilename = GW.globalSettings.settings.profilename
        GW.globalSettings:ResetProfile()
        GW.globalSettings.settings.profileLastUpdated = date("%m/%d/%y %H:%M:%S")
        GW.globalSettings.settings.profileCreatedDate = date("%m/%d/%y %H:%M:%S")
        GW.globalSettings.settings.profileCreatedCharacter = oldUsername or UNKNOWN
        GW.globalSettings.settings.profilename = oldProfilename or UNKNOWN

        -- also rest the matching profile layout
        for i = 0, #allLayouts do
            if allLayouts[i] and allLayouts[i].profileLayout and allLayouts[i].profileName == activeProfile then
                GW.global.layouts[i] = nil
                break
            end
        end

        return
    end
end
GW.ResetToDefault = ResetToDefault

local function GetExportString(profileName)
    local profileTable = GW.globalSettings.profiles[profileName]

    local serialData = Serializer:Serialize(profileTable)
    local exportString = format("%s::%s::%s::%s", serialData, profileName, GW.myname, "Retail")
    local compressedData = Deflate:CompressDeflate(exportString, Deflate.compressLevel)
    local printableString = Deflate:EncodeForPrint(compressedData)

        return encodedData
end
GW.GetExportString = GetExportString


local function DecodeProfile(dataString)
    local dataType = LibBase64:IsBase64(dataString) and "base64" or strfind(dataString, "{") and "table" or nil
    local profileName, profilePlayer, version, profileData, success

    if dataType == "base64" then
        local decodedData = LibBase64:Decode(dataString)
        local decompressedData, _ = Compress:Decompress(decodedData)

        if not decompressedData then
            return
        end

        local serializedData, profileInfo = GW.splitString(decompressed, "^^::")

        if not serializedData or not profileInfo then
            return
        end

        serializedData = format("%s%s", serializedData, "^^")
        profileName, profilePlayer, version = GW.splitString(profileInfo, "::")
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

    if not profileDataString or version ~= "Retail" then
        return
    end

    GW.addProfile(profileName, profileDataString)

    return profileName, profilePlayer, version
end
GW.ImportProfile = ImportProfile
