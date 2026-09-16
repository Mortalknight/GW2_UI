---@class GW2
local GW = select(2, ...)

local POS_FIELDS = {point = true, relativePoint = true, xOfs = true, yOfs = true, hasMoved = true}

-- Structure version of a profile. It has no default on purpose: AceDB strips values equal to their default on
-- logout, a marker in the defaults would be gone every time. Bump it when a later migration has to run once more.
local SETTINGS_VERSION = 4

local TOP_LEVEL_WITHOUT_DEFAULT = {profileIcon = true, profileChangedDate = true, settingsVersion = true}

local function IsArray(tbl)
    return type(tbl) == "table" and #tbl > 0
end

local function MergeInto(dst, src)
    for key, value in pairs(src) do
        if type(value) == "table" and type(dst[key]) == "table" and not IsArray(value) then
            MergeInto(dst[key], value)
        else
            dst[key] = type(value) == "table" and CopyTable(value) or value
        end
    end
end

local function ConvertLegacyValues(profile)
    profile.updateFramePositionMigrationDone = nil
    profile.chatTimeStampMigrationDone = nil
    profile.profileMetaDataFixed = nil
    profile.playerAuraSortMigrationDone = nil
    profile.BANK_ITEM_SETTINGS_SPLIT = nil
    if type(profile.INDICATOR_BAR) == "table" then
        profile.INDICATOR_BAR = nil
    end

    if profile.CASTINGBAR_DATA ~= nil then
        if profile.CASTINGBAR_DATA then
            profile.CASTINGBAR_SHOW_NAME = true
            profile.CASTINGBAR_SHOW_TIMER = true
            profile.CASTINGBAR_SHOW_LATENCY = true
            profile.CASTINGBAR_ICON_POSITION = "LEFT"
        end
        profile.CASTINGBAR_DATA = nil
    end

    for _, unit in next, {"target", "focus"} do
        local key = unit .. "_CASTINGBAR_DATA"
        if profile[key] ~= nil then
            if profile[key] then
                profile[unit .. "_CASTINGBAR_SHOW_TIMER"] = true
            end
            profile[key] = nil
        end
    end

    for _, key in next, {
        "PLAYER_DISPEL_ICON", "target_DISPEL_ICON", "focus_DISPEL_ICON", "PET_DISPEL_ICON",
        "PARTY_DISPEL_ICON", "PARTY_PET_DISPEL_ICON", "RAID_DISPEL_ICON", "RAID_25_DISPEL_ICON",
        "RAID_10_DISPEL_ICON", "RAID_PARTY_DISPEL_ICON", "RAID_PET_DISPEL_ICON", "RAID_MAINTANK_DISPEL_ICON",
    } do
        if type(profile[key]) == "boolean" then
            profile[key] = profile[key] and "DISPELLABLE" or "OFF"
        end
    end

    for _, barKey in next, {"PlayerBuffs", "PlayerDebuffs"} do
        local db = profile[barKey]
        if type(db) == "table" and (db.SortMethod or db.SortDir) then
            if db.SortMethod == "TIME" then
                db.Sort = db.SortDir == "-" and "EXPIRATION_DESC" or "EXPIRATION_ASC"
            elseif db.SortMethod == "NAME" then
                db.Sort = db.SortDir == "-" and "NAME_DESC" or "NAME_ASC"
            end
            db.SortMethod = nil
            db.SortDir = nil
        end
    end

    for old, new in next, {
        MICROMENU_NOTIFICATION_ICON_ANIMATION = "notificationIconAnimation",
        FADE_MICROMENU = "fade",
        MICROMENU_EVENT_TIMER_ICON = "eventTimerIcon",
    } do
        if profile[old] ~= nil then
            profile.micromenu = profile.micromenu or {}
            profile.micromenu[new] = profile[old]
            profile[old] = nil
        end
    end

    if profile.CHARACTER_STAT_ORDER ~= nil or profile.CHARACTER_STAT_VISIBILITY ~= nil or profile.CHARACTER_SHOW_SET_BONUS ~= nil then
        if profile == GW.settings then
            local stats = GW.private.heroPanel.stats
            if #stats.order == 0 and next(stats.visibility) == nil then
                for _, key in ipairs(profile.CHARACTER_STAT_ORDER or {}) do
                    tinsert(stats.order, key)
                end
                for key, visible in pairs(profile.CHARACTER_STAT_VISIBILITY or {}) do
                    stats.visibility[key] = visible
                end
                if profile.CHARACTER_SHOW_SET_BONUS == false then
                    stats.visibility.SETBONUS = false
                end
            end
        end
        profile.CHARACTER_STAT_ORDER = nil
        profile.CHARACTER_STAT_VISIBILITY = nil
        profile.CHARACTER_SHOW_SET_BONUS = nil
    end
end

local function MoveValue(profile, newPath, value)
    if type(value) ~= "table" then
        GW.SetSettingInTable(profile, newPath, value)
        return
    end

    -- the active profile already carries the default filled tables; a stored table holds only the values that
    -- differ from the defaults, so it is laid over the existing one instead of replacing it
    local existing = GW.GetSettingFromTable(profile, newPath)
    if type(existing) == "table" and not IsArray(value) then
        MergeInto(existing, value)
    else
        GW.SetSettingInTable(profile, newPath, CopyTable(value))
    end
end

local function MigrateProfileSettings(profile)
    if type(profile) ~= "table" or profile.settingsVersion == SETTINGS_VERSION then return end

    ConvertLegacyValues(profile)

    for _, bar in ipairs(GW.MultiBarMigrationKeys) do
        local old = profile[bar]
        if type(old) == "table" then
            local target = GW.MoverKeyMigrationMap[bar]
            for key, value in pairs(old) do
                MoveValue(profile, target .. (POS_FIELDS[key] and ".pos." or ".") .. key, value)
            end
            profile[bar] = nil
        end
    end
    -- the bar tables have a fixed set of keys; older builds left cols and margin behind
    local barDefaults = GW.globalDefault.profile.actionbars.bars
    for bar, db in pairs(profile.actionbars and profile.actionbars.bars or {}) do
        if type(db) == "table" and barDefaults[bar] then
            for key in pairs(db) do
                if barDefaults[bar][key] == nil then
                    db[key] = nil
                end
            end
        end
    end

    for oldKey, newPath in pairs(GW.SettingsMigrationMap) do
        local root, sub = strsplit(".", oldKey)
        local value
        if sub then
            value = type(profile[root]) == "table" and profile[root][sub] or nil
        else
            value = profile[oldKey]
        end

        if value ~= nil then
            MoveValue(profile, newPath, value)
            if sub then
                profile[root][sub] = nil
            else
                profile[oldKey] = nil
            end
        end
    end
    if type(profile.Minimap) == "table" and next(profile.Minimap) == nil then
        profile.Minimap = nil
    end

    for key in pairs(profile) do
        if GW.globalDefault.profile[key] == nil and not TOP_LEVEL_WITHOUT_DEFAULT[key] then
            profile[key] = nil
        end
    end

    profile.settingsVersion = SETTINGS_VERSION
end
GW.MigrateProfileSettings = MigrateProfileSettings

local function MigrateLayoutFrames()
    for _, layout in pairs(GW.global.layouts or {}) do
        local kept = {}
        for _, frame in pairs(layout.frames or {}) do
            frame.settingName = GW.MoverKeyMigrationMap[frame.settingName] or frame.settingName
            if frame.settingName and GW.GetSettingDefault(frame.settingName .. ".pos") ~= nil then
                kept[#kept + 1] = frame
            end
        end
        layout.frames = kept
    end
end

local function DatabaseValueMigration()
    for _, profile in pairs(GW.globalSettings.profiles) do
        MigrateProfileSettings(profile)
    end
    MigrateLayoutFrames()
end
GW.DatabaseValueMigration = DatabaseValueMigration

local function GetLayoutKeys(layouts)
    local keys = {}
    for key in pairs(layouts) do
        keys[#keys + 1] = key
    end
    return keys
end

-- moves a layout onto another key and takes its name, the spec assignment and the current selection along
local function MoveLayout(layouts, oldKey, newName)
    local layout = layouts[oldKey]
    layouts[newName] = layout
    layouts[oldKey] = nil
    layout.name = newName

    local privateLayoutSettings = GW.GetPrivateLayoutByLayoutName(oldKey)
    if privateLayoutSettings then
        privateLayoutSettings.layoutName = newName
    end
    if GW.private.Layouts.currentSelected == oldKey then
        GW.private.Layouts.currentSelected = newName
    end
end

local function LayoutMigration()
    local layouts = GW.global and GW.global.layouts
    if not layouts then return end

    for _, key in ipairs(GetLayoutKeys(layouts)) do
        local layout = layouts[key]
        if type(layout) == "table" and layout.name and layout.name ~= key then
            if layouts[layout.name] then
                layout.name = key -- that name is taken, the key is the only thing left to name it after
            else
                MoveLayout(layouts, key, layout.name)
            end
        end
    end

    local prefix = GW.L["Profiles"] .. " - "
    for _, key in ipairs(GetLayoutKeys(layouts)) do
        local layout = layouts[key]
        if type(layout) == "table" and layout.profileLayout
            and not (layout.profileName and GW.globalSettings.profiles[layout.profileName]) then

            local plainName = layout.profileName
            if not plainName and key:sub(1, #prefix) == prefix then
                plainName = key:sub(#prefix + 1)
            end

            layout.profileLayout = false
            layout.profileName = nil

            if plainName and plainName ~= key and not layouts[plainName] then
                MoveLayout(layouts, key, plainName)
            end
        end
    end
end
GW.LayoutMigration = LayoutMigration
