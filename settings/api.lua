local _, GW = ...

local LibBase64 = GW.Libs.LibBase64
local Compress = GW.Libs.Compress
local Serializer = GW.Libs.Serializer
local Deflate = GW.Libs.Deflate

local EXPORT_PREFIX = "!GW2!"
Deflate.compressLevel = {level = 5}

local function GetSetting(settingsName)
    -- Wrapper function to not break other addons/plugins
    return GW.settings[settingsName]
end
GW.GetSetting = GetSetting

local function GetAllLayouts()
    if GW.global.layouts == nil then
        GW.global.layouts = {}
    end
    return GW.global.layouts
end
GW.GetAllLayouts = GetAllLayouts

local function GetLayoutByName(layoutName)
    if GW.global.layouts == nil then
        GW.global.layouts = {}
    end
    return GW.global.layouts[layoutName] or nil
end
GW.GetLayoutByName = GetLayoutByName

local function GetAllPrivateLayouts()
    if GW.private.Layouts == nil then
        GW.private.Layouts = {}
    end
    return GW.private.Layouts
end
GW.GetAllPrivateLayouts = GetAllPrivateLayouts

local function GetPrivateLayoutByLayoutName(layoutName)
    if GW.private.Layouts == nil then
        GW.private.Layouts = {}
    end
    for k, _ in pairs(GW.private.Layouts) do
        if GW.private.Layouts[k].layoutName == layoutName then
            return GW.private.Layouts[k]
        end
    end
    return nil
end
GW.GetPrivateLayoutByLayoutName = GetPrivateLayoutByLayoutName


local function DeletePrivateLayoutByLayoutName(layoutName)
    if GW.private.Layouts == nil then
        GW.private.Layouts = {}
    end
    for k, _ in pairs(GW.private.Layouts) do
        if GW.private.Layouts[k].layoutName == layoutName then
            GW.private.Layouts[k] = nil
        end
    end
end
GW.DeletePrivateLayoutByLayoutName = DeletePrivateLayoutByLayoutName

local function SetOverrideIncompatibleAddons(setting, value)
    GW.settings.IncompatibleAddons[setting].Override = value
    GW.Notice(GW.L["Incompatible Addons behavior Overridden. Needs a reload to take effect."])
end
GW.SetOverrideIncompatibleAddons = SetOverrideIncompatibleAddons

local function ResetToDefault()
    local activeProfile = GW.globalSettings:GetCurrentProfile()
    local allLayouts = GetAllLayouts()
    local oldUsername = nil

    if activeProfile then
        oldUsername = GW.globalSettings.profiles[activeProfile].profileCreatedCharacter
        GW.globalSettings:ResetProfile()
        GW.globalSettings.profiles[activeProfile].profileCreatedDate = date(GW.L["TimeStamp m/d/y h:m:s"])
        GW.globalSettings.profiles[activeProfile].profileCreatedCharacter = oldUsername or "GW2_UI"

        -- also rest the matching profile layout
        local profileName = GW.L["Profiles"] .. " - " .. activeProfile
        if allLayouts[profileName] then
            GW.global.layouts[profileName] = nil
        end
    end
end
GW.ResetToDefault = ResetToDefault

local function GetExportString(profileName)
    local profileTable = GW.globalSettings.profiles[profileName]

    local serialData = Serializer:Serialize(profileTable)
    local exportString = format("%s::%s::%s::%s", serialData, profileName, GW.myname, "Retail") -- we need Retail here for older profiles
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
    local profileName, profilePlayer, profileData, success

    if stringType == "Deflate" then
        local data = gsub(dataString, "^" .. EXPORT_PREFIX, "")
        local decodedData = Deflate:DecodeForPrint(data)
        local decompressed = Deflate:DecompressDeflate(decodedData)

        if not decompressed then
            return
        end

        local serializedData, profileInfo = GW.splitString(decompressed, "^^::")

        if not serializedData or not profileInfo then
            return
        end

        serializedData = format("%s%s", serializedData, "^^")
        profileName, profilePlayer = GW.splitString(profileInfo, "::")
        success, profileData = Serializer:Deserialize(serializedData)

        if not success then
            return
        end
    end

    return profileName, profilePlayer, profileData
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
    local profileName, profilePlayer, profileDataString = DecodeProfile(dataString)

    if not profileDataString then
        return
    end

    GW.AddProfile(profileName .. " - " .. profilePlayer, false, profileDataString)

    return profileName, profilePlayer
end
GW.ImportProfile = ImportProfile

function GW.GetStatusBarTextures()
    local assets = GW.Libs.LSM:List("statusbar")
    local textureLabels, textureValues = {}, {}
    local textureOtherLabels, textureOtherValues = {}, {}

    for _, key in ipairs(assets) do
        local file = GW.Libs.LSM:Fetch("statusbar", key)
        if key:find("GW2", 1, true) then
            table.insert(textureLabels, "|T".. file .. ":" .. 18 .. ":" .. 55 .. "|t " .. key)
            table.insert(textureValues, key)
        else
            table.insert(textureOtherLabels, "|T".. file .. ":" .. 18 .. ":" .. 55 .. "|t [Custom] " .. key)
            table.insert(textureOtherValues, key)
        end
        print(key)
    end

    for i = 1, #textureOtherLabels do
        tinsert(textureLabels, textureOtherLabels[i])
        tinsert(textureValues, textureOtherValues[i])
    end

    return textureValues, textureLabels
end
