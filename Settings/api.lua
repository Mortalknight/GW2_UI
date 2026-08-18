---@class GW2
local GW = select(2, ...)

local EXPORT_PREFIX_LEGACY = "!GW2!" -- LibDeflate era exports (import only)
local EXPORT_PREFIX = "!GW3!"        -- C_EncodingUtil exports (deflate + base64)

-- Decoder for the legacy LibDeflate EncodeForPrint alphabet (a-z A-Z 0-9 "(" ")",
-- little-endian 6 bit groups) — keeps old "!GW2!" profile strings importable after
-- the switch to C_EncodingUtil; the compression itself is plain deflate either way
local legacy6BitToByte = {}
do
    local alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()"
    for i = 1, #alphabet do
        legacy6BitToByte[strbyte(alphabet, i)] = i - 1
    end
end

local function DecodeLegacyForPrint(str)
    str = strtrim(str)
    local buffer, bitCache, bitLen = {}, 0, 0

    for i = 1, #str do
        local value = legacy6BitToByte[strbyte(str, i)]
        if not value then return nil end
        bitCache = bitCache + value * (2 ^ bitLen)
        bitLen = bitLen + 6
        if bitLen >= 8 then
            local byte = bitCache % 256
            buffer[#buffer + 1] = strchar(byte)
            bitCache = (bitCache - byte) / 256
            bitLen = bitLen - 8
        end
    end

    return table.concat(buffer)
end

-- Minimal AceSerializer-3.0 DEserializer, ported 1:1 from the bundled lib before its
-- removal — only needed to read legacy "!GW2!" profile strings, new exports use CBOR.
-- (AceSerializer-3.0 is part of Ace3, https://www.wowace.com/projects/ace3)
local DeserializeLegacyValue
do
    local inf = math.huge
    local serInf, serInfMac = "1.#INF", "inf"
    local serNegInf, serNegInfMac = "-1.#INF", "-inf"

    local function DeserializeStringHelper(escape)
        if escape < "~\122" then
            return strchar(strbyte(escape, 2, 2) - 64)
        elseif escape == "~\122" then -- special case encode since 30+64=94 ("^")
            return "\030"
        elseif escape == "~\123" then
            return "\127"
        elseif escape == "~\124" then
            return "\126"
        elseif escape == "~\125" then
            return "\94"
        end
        error("DeserializeStringHelper got called for '" .. escape .. "'?!?")
    end

    local function DeserializeNumberHelper(number)
        if number == serNegInf or number == serNegInfMac then
            return -inf
        elseif number == serInf or number == serInfMac then
            return inf
        else
            return tonumber(number)
        end
    end

    function DeserializeLegacyValue(iter, single, ctl, data)
        if not single then
            ctl, data = iter()
        end

        if not ctl then
            error("Supplied data misses AceSerializer terminator ('^^')")
        end

        if ctl == "^^" then
            return -- ignore extraneous data
        end

        local res

        if ctl == "^S" then
            res = gsub(data, "~.", DeserializeStringHelper)
        elseif ctl == "^N" then
            res = DeserializeNumberHelper(data)
            if not res then
                error("Invalid serialized number: '" .. tostring(data) .. "'")
            end
        elseif ctl == "^F" then -- ^F<mantissa>^f<exponent>
            local ctl2, e = iter()
            if ctl2 ~= "^f" then
                error("Invalid serialized floating-point number, expected '^f', not '" .. tostring(ctl2) .. "'")
            end
            local m = tonumber(data)
            e = tonumber(e)
            if not (m and e) then
                error("Invalid serialized floating-point number, expected mantissa and exponent, got '" .. tostring(m) .. "' and '" .. tostring(e) .. "'")
            end
            res = m * (2 ^ e)
        elseif ctl == "^B" then
            res = true
        elseif ctl == "^b" then
            res = false
        elseif ctl == "^Z" then
            res = nil
        elseif ctl == "^T" then
            res = {}
            local k, v
            while true do
                ctl, data = iter()
                if ctl == "^t" then break end
                k = DeserializeLegacyValue(iter, true, ctl, data)
                if k == nil then
                    error("Invalid AceSerializer table format (no table end marker)")
                end
                ctl, data = iter()
                v = DeserializeLegacyValue(iter, true, ctl, data)
                if v == nil then
                    error("Invalid AceSerializer table format (no table end marker)")
                end
                res[k] = v
            end
        else
            error("Invalid AceSerializer control code '" .. ctl .. "'")
        end

        if not single then
            return res, DeserializeLegacyValue(iter)
        else
            return res
        end
    end
end

local function DeserializeLegacy(str)
    str = gsub(str, "[%c ]", "") -- ignore all control characters and whitespace

    local iter = gmatch(str, "(^.)([^^]*)") -- any ^x followed by a string of non-^
    local ctl = iter()
    if not ctl or ctl ~= "^1" then
        return false, "Supplied data is not AceSerializer data (rev 1)"
    end

    return pcall(DeserializeLegacyValue, iter)
end

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

    -- one CBOR payload instead of the old "::" joined string — binary safe, no
    -- string splitting on import needed
    local payload = {
        profile = profileTable,
        profileName = profileName,
        profilePlayer = GW.myname,
    }
    -- pcall: SerializeCBOR errors on unserializable values (functions, secrets) —
    -- a polluted profile table should fail the export, not throw at the user
    local ok, printableString = pcall(function()
        local serialData = C_EncodingUtil.SerializeCBOR(payload)
        local compressedData = C_EncodingUtil.CompressString(serialData, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize)
        return C_EncodingUtil.EncodeBase64(compressedData)
    end)

    return (ok and printableString) and format("%s%s", EXPORT_PREFIX, printableString) or nil
end
GW.GetExportString = GetExportString

local function GetImportStringType(dataString)
    if strmatch(dataString, "^" .. EXPORT_PREFIX) then
        return "Base64"
    elseif strmatch(dataString, "^" .. EXPORT_PREFIX_LEGACY) then
        return "Deflate"
    end
    return ""
end
GW.GetImportStringType = GetImportStringType

local function DecodeProfile(dataString)
    local stringType = GetImportStringType(dataString)
    local profileName, profilePlayer, profileData, success

    local decodedData
    if stringType == "Base64" then
        local decodeOk, decoded = pcall(C_EncodingUtil.DecodeBase64, (gsub(dataString, "^" .. EXPORT_PREFIX, "")))
        decodedData = decodeOk and decoded or nil
    elseif stringType == "Deflate" then -- legacy LibDeflate exports
        decodedData = DecodeLegacyForPrint(gsub(dataString, "^" .. EXPORT_PREFIX_LEGACY, ""))
    end

    if decodedData then
        -- pcall: C_EncodingUtil errors on malformed input instead of returning nil
        local ok, decompressed = pcall(C_EncodingUtil.DecompressString, decodedData, Enum.CompressionMethod.Deflate)
        if not ok or not decompressed then
            return
        end

        if stringType == "Base64" then
            -- current format: one CBOR payload table
            local cborOk, payload = pcall(C_EncodingUtil.DeserializeCBOR, decompressed)
            if not cborOk or type(payload) ~= "table" or type(payload.profile) ~= "table"
                or type(payload.profileName) ~= "string" or type(payload.profilePlayer) ~= "string" then
                return
            end
            profileName, profilePlayer, profileData = payload.profileName, payload.profilePlayer, payload.profile
        else
            -- legacy format: AceSerializer string joined with "::" metadata
            local serializedData, profileInfo = GW.splitString(decompressed, "^^::")

            if not serializedData or not profileInfo then
                return
            end

            serializedData = format("%s%s", serializedData, "^^")
            profileName, profilePlayer = GW.splitString(profileInfo, "::")
            success, profileData = DeserializeLegacy(serializedData)

            -- same shape validation as the CBOR path: a corrupt string that still
            -- inflates must fail cleanly here, not error later in AddProfile
            if not success or type(profileData) ~= "table"
                or type(profileName) ~= "string" or type(profilePlayer) ~= "string" then
                return
            end
        end
    end

    return profileName, profilePlayer, profileData
end
GW.DecodeProfile = DecodeProfile

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
    end

    for i = 1, #textureOtherLabels do
        tinsert(textureLabels, textureOtherLabels[i])
        tinsert(textureValues, textureOtherValues[i])
    end

    return textureValues, textureLabels
end
