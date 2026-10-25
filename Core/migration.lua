---@class GW2
local GW = select(2, ...)

local POS_FIELDS = {point = true, relativePoint = true, xOfs = true, yOfs = true, hasMoved = true}

-- Structure version of a profile, for later migrations to key off. It has no default on purpose: AceDB strips
-- values equal to their default on logout. The flat key move itself runs on every login: a session with an older
-- version writes flat keys again, and those have to be carried over instead of lingering.
local SETTINGS_VERSION = 5
GW.SETTINGS_VERSION = SETTINGS_VERSION

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

local GRID_TEXT_OPTIONS = {"showRoleIcon", "showTankIcon", "showLeaderIcon", "unitFlags", "unitHealth", "shortHealthValues"}
local GRID_PROFILES = {party = false, raid10 = false, raid25 = false, raid40 = false, maintank = false, partyPet = true, raidPet = true}

local function MigrateGridTexts(db, isPet)
    local found = false
    for _, key in ipairs(GRID_TEXT_OPTIONS) do
        found = found or db[key] ~= nil
    end
    if not found then return end

    local function Value(key, default)
        if db[key] == nil then return default end
        return db[key]
    end

    if not db.nameText then
        local blocks = {}
        if Value("showTankIcon", not isPet) then tinsert(blocks, {k = "mainTankIcon"}) end
        if Value("showLeaderIcon", not isPet) then
            tinsert(blocks, {k = "leaderIcon"})
            tinsert(blocks, {k = "assistIcon"})
        end
        if Value("showRoleIcon", not isPet) then tinsert(blocks, {k = "roleIcon"}) end
        tinsert(blocks, {k = "name"})
        local flags = Value("unitFlags", "NONE")
        if flags ~= "NONE" then
            tinsert(blocks, {k = "space"})
            tinsert(blocks, {k = "realmFlag", mode = flags})
        end
        db.nameText = blocks
    end

    if not db.healthText then
        local health = Value("unitHealth", "NONE")
        db.healthText = health ~= "NONE" and {{k = "healthValue", mode = health, short = Value("shortHealthValues", false)}} or {}
    end

    for _, key in ipairs(GRID_TEXT_OPTIONS) do
        db[key] = nil
    end
end

-- the single health text options became the health line of the text designer: value and percent joined by a dash,
-- swapped on an inverted frame; a text line is false until the designer stores one, AceDB copies that default into
-- the active profile
local function MigrateHealthText(db, valueKey, percentKey, shortKey, valueDefault)
    if db[valueKey] == nil and db[percentKey] == nil and db[shortKey] == nil then return end

    if not db.healthText then
        local showValue = db[valueKey]
        if showValue == nil then
            showValue = valueDefault
        end
        local value = showValue and {k = "healthValue", mode = "HEALTH", short = db[shortKey] == true}
        local percent = db[percentKey] and {k = "healthValue", mode = "PREC"}
        local first, second = value, percent
        if db.invert then
            first, second = percent, value
        end
        local blocks = {first or second}
        if first and second then
            tinsert(blocks, {k = "text", text = " - "})
            tinsert(blocks, second)
        end
        db.healthText = blocks
    end
    db[valueKey], db[percentKey], db[shortKey] = nil, nil, nil
end

-- the text options of the health globe became its two lines in the text designer, value and percent on two rows;
-- the player frame took the health text from the globe and gets it on one row
local function GlobeTextBlocks(show, short, blockKey, joiner)
    local value = {k = blockKey, mode = blockKey == "absorb" and "CUR" or "HEALTH", short = short}
    local percent = {k = blockKey, mode = "PREC"}
    return show == "VALUE" and {value} or show == "PREC" and {percent}
        or show == "BOTH" and {value, {k = joiner == "\n" and "newLine" or "text", text = joiner}, percent} or {}
end

local function MigrateHealthGlobeTexts(unitframes)
    local globe = unitframes.healthGlobe
    if globe.healthValue ~= nil or globe.shortHealthValues ~= nil then
        local show, short = globe.healthValue or "VALUE", globe.shortHealthValues == true
        if not globe.healthText then
            globe.healthText = GlobeTextBlocks(show, short, "healthValue", "\n")
        end
        unitframes.player = type(unitframes.player) == "table" and unitframes.player or {}
        if not unitframes.player.healthText then
            unitframes.player.healthText = GlobeTextBlocks(show, short, "healthValue", " - ")
        end
        globe.healthValue, globe.shortHealthValues = nil, nil
    end
    if globe.absorbValue ~= nil or globe.shortShieldValues ~= nil then
        if not globe.absorbText then
            globe.absorbText = GlobeTextBlocks(globe.absorbValue or "VALUE", globe.shortShieldValues == true, "absorb", "\n")
        end
        globe.absorbValue, globe.shortShieldValues = nil, nil
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
    if type(profile) ~= "table" then return end

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
    -- the reactions that hide unit tooltips in combat were one string of combinations, now one switch each
    local hideInCombat = type(profile.tooltip) == "table" and profile.tooltip.hideInCombat
    if type(hideInCombat) == "table" and type(hideInCombat.units) == "string" then
        local units = hideInCombat.units
        hideInCombat.units = {
            FRIENDLY = units == "ALL" or strfind(units, "FRIENDLY", 1, true) ~= nil,
            NEUTRAL = units == "ALL" or strfind(units, "NEUTRAL", 1, true) ~= nil,
            HOSTILE = units == "ALL" or strfind(units, "HOSTILE", 1, true) ~= nil,
        }
    end

    -- the addon compartment switch joined the other buttons next to the minimap
    local minimapSettings = type(profile.minimap) == "table" and profile.minimap
    if minimapSettings and minimapSettings.addonCompartment ~= nil then
        minimapSettings.sideButtons = minimapSettings.sideButtons or {}
        minimapSettings.sideButtons.COMPARTMENT = minimapSettings.addonCompartment
        minimapSettings.addonCompartment = nil
    end

    if type(profile.groupFrames) == "table" then
        for grid, isPet in pairs(GRID_PROFILES) do
            if type(profile.groupFrames[grid]) == "table" then
                MigrateGridTexts(profile.groupFrames[grid], isPet)
            end
        end
    end

    -- "Show value on bar" became the lines of the class power bars, the power bar and the player frame; switched off
    -- they all start empty
    local classpower = type(profile.classpower) == "table" and profile.classpower
    if classpower and classpower.showValue ~= nil then
        if classpower.showValue == false then
            for _, line in ipairs({"manaText", "littleManaText", "classBarText"}) do
                classpower[line] = classpower[line] or {}
            end
            profile.powerBar = type(profile.powerBar) == "table" and profile.powerBar or {}
            profile.powerBar.powerText = profile.powerBar.powerText or {}
            profile.unitframes = type(profile.unitframes) == "table" and profile.unitframes or {}
            profile.unitframes.player = type(profile.unitframes.player) == "table" and profile.unitframes.player or {}
            profile.unitframes.player.powerText = profile.unitframes.player.powerText or {}
        end
        classpower.showValue = nil
    end

    if type(profile.unitframes) == "table" then
        for _, unit in ipairs({"target", "focus"}) do
            if type(profile.unitframes[unit]) == "table" then
                MigrateHealthText(profile.unitframes[unit], "healthValue", "healthValueType", "shortValues", false)
            end
        end
        if type(profile.unitframes.healthGlobe) == "table" then
            MigrateHealthGlobeTexts(profile.unitframes)
        end
        local party = profile.unitframes.party
        if type(party) == "table" and (party.healthValue ~= nil or party.shortHealthValues ~= nil) then
            -- the party frames showed one health mode, none by default
            local mode = party.healthValue or "NONE"
            if not party.healthText then
                party.healthText = mode ~= "NONE" and {{k = "healthValue", mode = mode, short = party.shortHealthValues == true}} or {}
            end
            party.healthValue, party.shortHealthValues = nil, nil
        end
        if type(profile.unitframes.pet) == "table" then
            -- the pet showed its health value by default
            MigrateHealthText(profile.unitframes.pet, "healthValueRaw", "healthValuePercent", "shortHealthValues", true)
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

local function IsUsablePoint(point)
    return type(point) == "table" and point.point ~= nil and point.relativePoint ~= nil and point.xOfs ~= nil and point.yOfs ~= nil
end

local function IsDefaultPoint(settingName, point)
    local default = GW.GetSettingDefault(settingName .. ".pos")
    return IsUsablePoint(point) and point.point == default.point and point.relativePoint == default.relativePoint
        and point.xOfs == default.xOfs and point.yOfs == default.yOfs
end

-- one entry per frame: an incomplete point loses to anything, a default position to a moved one, otherwise the
-- later entry wins
local function PointWins(settingName, candidate, current)
    if not IsUsablePoint(candidate) then return false end
    if not IsUsablePoint(current) then return true end
    return not IsDefaultPoint(settingName, candidate) or IsDefaultPoint(settingName, current)
end

local function MigrateLayoutFrames()
    for _, layout in pairs(GW.global.layouts or {}) do
        local kept, byName = {}, {}
        for _, frame in pairs(layout.frames or {}) do
            frame.settingName = GW.MoverKeyMigrationMap[frame.settingName] or frame.settingName
            if frame.settingName and GW.GetSettingDefault(frame.settingName .. ".pos") ~= nil then
                local index = byName[frame.settingName]
                if not index then
                    kept[#kept + 1] = frame
                    byName[frame.settingName] = #kept
                elseif PointWins(frame.settingName, frame.point, kept[index].point) then
                    kept[index] = frame
                end
            end
        end
        layout.frames = kept
    end
end

local function DatabaseValueMigration()
    for _, profile in pairs(GW.globalSettings.profiles) do
        xpcall(MigrateProfileSettings, geterrorhandler(), profile)
    end
    xpcall(MigrateLayoutFrames, geterrorhandler())
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
