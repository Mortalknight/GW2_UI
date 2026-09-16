-- luajit tools/migrationHarness.lua "<WoW>/_retail_/WTF/Account/<ACCOUNT>/SavedVariables/GW2_UI.lua"
-- runs Core/migration.lua against a SavedVariables file: every profile raw and with the AceDB defaults copied in,
-- exit code 1 when a value does not arrive at its new path
-- luacheck: globals date CopyTable Mixin strjoin strsplit tinsert wipe C_Spell GW2UI_DATABASE

local ROOT = (arg[0]:match("^(.*)[/\\]tools[/\\]") or ".") .. "/"
local svPath = assert(arg[1], "usage: luajit tools/migrationHarness.lua <SavedVariables GW2_UI.lua>")

local GW = {L = setmetatable({}, {__index = function(_, k) return k end}), AURAS_IGNORED = {1, 2}, AURAS_MISSING = {1},
    Retail = true, MapTable = function() return {} end, Enum = {}}
date = function() return "stub" end
function CopyTable(t) local n = {} for k, v in pairs(t) do n[k] = type(v) == "table" and CopyTable(v) or v end return n end
function Mixin(dst, src) for k, v in pairs(src) do dst[k] = v end return dst end
strjoin = function(sep, ...) return table.concat({...}, sep) end
strsplit = function(sep, str) -- wow: plain separator characters, all pieces
    local pieces, esc = {}, sep:gsub("%p", "%%%0")
    for piece in (str .. sep):gmatch("(.-)[" .. esc .. "]") do pieces[#pieces + 1] = piece end
    return unpack(pieces)
end
tinsert = table.insert
wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
C_Spell = {GetSpellInfo = function() return {name = "x"} end}

local function runFile(path)
    local chunk = assert(loadfile(path))
    return chunk("GW2_UI", GW)
end

runFile(ROOT .. "Settings/defaults.lua")
runFile(ROOT .. "Settings/settingsMigration.lua")
local api = io.open(ROOT .. "Settings/api.lua"):read("*a")
local helpers = api:match("(local pathCache = {}.-GW%.GetSettingDefault = GetSettingDefault)")
assert(helpers, "path helpers not found in api.lua")
local helperChunk = assert(loadstring("local GW = select(2, ...) " .. helpers))
helperChunk("GW2_UI", GW)
runFile(ROOT .. "Core/migration.lua")

assert(loadfile(svPath))()
local db = assert(GW2UI_DATABASE, "no GW2UI_DATABASE in file")
local defaults = GW.globalDefault.profile

local function copyDefaults(dest, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if rawget(dest, k) == nil then rawset(dest, k, {}) end
            if type(dest[k]) == "table" then copyDefaults(dest[k], v) end
        elseif rawget(dest, k) == nil then
            rawset(dest, k, v)
        end
    end
end
local function removeDefaults(db_, defaults_)
    for k, v in pairs(defaults_) do
        if type(v) == "table" and type(db_[k]) == "table" then
            removeDefaults(db_[k], v)
            if next(db_[k]) == nil then db_[k] = nil end
        elseif db_[k] == defaults_[k] then
            db_[k] = nil
        end
    end
end

local POS_FIELDS = {point = true, relativePoint = true, xOfs = true, yOfs = true, hasMoved = true}
local IDENTITY = {profileCreatedCharacter = true, profileCreatedDate = true, profileIcon = true, profileChangedDate = true,
    micromenu = true, immersiveQuesting = true, settingsVersion = true}
local problems, moved = 0, 0

local function report(...)
    problems = problems + 1
    print("  PROBLEM:", ...)
end

local function isSubset(old, new, path)
    if type(old) ~= "table" then
        if old ~= new then report(path, "value", tostring(old), "->", tostring(new)) return end
        return
    end
    if type(new) ~= "table" then report(path, "table lost, now", tostring(new)) return end
    for k, v in pairs(old) do
        isSubset(v, new[k], path .. "." .. tostring(k))
    end
end

local function checkProfile(name, raw, active)
    local before = CopyTable(raw)
    local profile = CopyTable(raw)
    if active then
        copyDefaults(profile, defaults)
        GW.settings = profile
    else
        GW.settings = {}
    end
    GW.private = {heroPanel = {stats = {order = {}, visibility = {}}}}

    GW.MigrateProfileSettings(profile)
    if not profile.settingsVersion then report(name, "settingsVersion not stamped") end
    local snapshot = CopyTable(profile)
    GW.MigrateProfileSettings(profile)
    isSubset(snapshot, profile, name .. " second run")
    isSubset(profile, snapshot, name .. " second run")

    for key, value in pairs(before) do
        if not IDENTITY[key] and defaults[key] == nil then
            if profile[key] ~= nil then
                report(name, "old key still present:", key)
            end
            local newPath = GW.SettingsMigrationMap[key]
            local isMultiBar = false
            for _, bar in ipairs(GW.MultiBarMigrationKeys) do if bar == key then isMultiBar = true end end
            if isMultiBar then
                local target = GW.MoverKeyMigrationMap[key]
                local barDefaults = GW.GetSettingFromTable(defaults, target)
                for sub, v in pairs(value) do
                    if POS_FIELDS[sub] or barDefaults[sub] ~= nil then
                        moved = moved + 1
                        isSubset(v, GW.GetSettingFromTable(profile, target .. (POS_FIELDS[sub] and ".pos." or ".") .. sub), name .. ":" .. key .. "." .. sub)
                    else
                        print("  note:", name, "removed bar key dropped:", key .. "." .. sub)
                    end
                end
            elseif newPath then
                moved = moved + 1
                if (key == "PlayerBuffs" or key == "PlayerDebuffs") and type(value) == "table" and (value.SortMethod or value.SortDir) then
                    value = CopyTable(value)
                    local expected = value.SortMethod == "TIME" and (value.SortDir == "-" and "EXPIRATION_DESC" or "EXPIRATION_ASC")
                        or value.SortMethod == "NAME" and (value.SortDir == "-" and "NAME_DESC" or "NAME_ASC") or nil
                    value.SortMethod, value.SortDir = nil, nil
                    if expected then value.Sort = expected end
                end
                isSubset(value, GW.GetSettingFromTable(profile, newPath), name .. ":" .. key)
            elseif key == "Minimap" then
                for sub, v in pairs(value) do
                    local subPath = GW.SettingsMigrationMap["Minimap." .. sub]
                    if subPath then
                        moved = moved + 1
                        isSubset(v, GW.GetSettingFromTable(profile, subPath), name .. ":Minimap." .. sub)
                    else
                        print("  note:", name, "removed minimap key dropped: Minimap." .. sub)
                    end
                end
            elseif defaults[key] == nil then
                print("  note:", name, "unknown old key dropped or kept:", key, type(value))
            end
        end
    end

    for key in pairs(profile) do
        if defaults[key] == nil and not IDENTITY[key] then
            report(name, "top level key not in defaults:", key)
        end
    end

    if active then
        removeDefaults(profile, defaults)
    end
    local function count(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end
    print(string.format("  %-28s %3d top level keys before, %3d after (%s)", name, count(before), count(profile), active and "active, defaults applied" or "raw"))
end

print("profiles:")
local names = {}
for name in pairs(db.profiles or {}) do names[#names + 1] = name end
table.sort(names)
for _, name in ipairs(names) do
    checkProfile(name, db.profiles[name], false)
end
for _, name in ipairs(names) do
    checkProfile(name .. " [active]", db.profiles[name], true)
end

print("layouts:")
GW.global = db.global or {}
local layoutFrames, unknownFrames = 0, 0
for lname, layout in pairs(GW.global.layouts or {}) do
    for _, frame in pairs(layout.frames or {}) do
        local new = GW.MoverKeyMigrationMap[frame.settingName]
        if new then
            layoutFrames = layoutFrames + 1
            if GW.GetSettingFromTable(defaults, new .. ".pos") == nil then report("layout", lname, "mover path without pos table", new) end
        elseif GW.GetSettingFromTable(defaults, frame.settingName .. ".pos") == nil then
            unknownFrames = unknownFrames + 1
            print("  note: layout", lname, "unknown frame key", frame.settingName)
        end
    end
end
print(string.format("  %d frame entries renamed, %d unknown", layoutFrames, unknownFrames))

print(string.format("\nmoved values checked: %d, problems: %d", moved, problems))
os.exit(problems == 0 and 0 or 1)
