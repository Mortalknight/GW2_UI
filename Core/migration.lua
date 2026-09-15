---@class GW2
local GW = select(2, ...)

local function DatabaseValueMigration()
    -- marker flags of migrations that have been removed again (everything before 11.0.0), cleaned out of the profiles
    GW.settings.updateFramePositionMigrationDone = nil
    GW.settings.chatTimeStampMigrationDone = nil
    GW.settings.profileMetaDataFixed = nil
    GW.settings.BANK_ITEM_SETTINGS_SPLIT = nil

    -- migration of the player cast bar details: the single "Advanced Casting Bar" toggle was
    -- split into one setting per element. Only profiles that had it enabled carry the key
    -- (it is gone from the defaults), so everyone else keeps the plain bar
    if GW.settings.CASTINGBAR_DATA ~= nil then
        if GW.settings.CASTINGBAR_DATA then
            GW.settings.CASTINGBAR_SHOW_NAME = true
            GW.settings.CASTINGBAR_SHOW_TIMER = true
            GW.settings.CASTINGBAR_SHOW_LATENCY = true
            GW.settings.CASTINGBAR_ICON_POSITION = "LEFT"
        end

        GW.settings.CASTINGBAR_DATA = nil
    end

    -- same split for the target/focus cast bars: their toggle only ever drove the cast
    -- timer text, the spell name was always shown (and stays on by default)
    for _, unit in next, { "target", "focus" } do
        local key = unit .. "_CASTINGBAR_DATA"
        if GW.settings[key] ~= nil then
            if GW.settings[key] then
                GW.settings[unit .. "_CASTINGBAR_SHOW_TIMER"] = true
            end
            GW.settings[key] = nil
        end
    end

    -- migration of the dispel type icon settings: the per-frame checkbox became a three
    -- state dropdown (OFF/ALL/DISPELLABLE); enabled maps to the new default behavior
    for _, key in next, {
        "PLAYER_DISPEL_ICON", "target_DISPEL_ICON", "focus_DISPEL_ICON", "PET_DISPEL_ICON",
        "PARTY_DISPEL_ICON", "PARTY_PET_DISPEL_ICON", "RAID_DISPEL_ICON", "RAID_25_DISPEL_ICON",
        "RAID_10_DISPEL_ICON", "RAID_PARTY_DISPEL_ICON", "RAID_PET_DISPEL_ICON", "RAID_MAINTANK_DISPEL_ICON",
    } do
        if type(GW.settings[key]) == "boolean" then
            GW.settings[key] = GW.settings[key] and "DISPELLABLE" or "OFF"
        end
    end

    -- migration of the player aura sorting: SortMethod + SortDir were combined into
    -- a single Sort preset (shared values with the unit frame aura sorting)
    if not GW.settings.playerAuraSortMigrationDone then
        for _, barKey in next, { "PlayerBuffs", "PlayerDebuffs" } do
            local db = GW.settings[barKey]
            if db then
                if db.SortMethod == "TIME" then
                    db.Sort = db.SortDir == "-" and "EXPIRATION_DESC" or "EXPIRATION_ASC"
                elseif db.SortMethod == "NAME" then
                    db.Sort = db.SortDir == "-" and "NAME_DESC" or "NAME_ASC"
                end
                db.SortMethod = nil
                db.SortDir = nil
            end
        end

        GW.settings.playerAuraSortMigrationDone = true
    end


    -- micro menu settings moved into the micromenu table
    if GW.settings.MICROMENU_NOTIFICATION_ICON_ANIMATION ~= nil then
        GW.settings.micromenu.notificationIconAnimation = GW.settings.MICROMENU_NOTIFICATION_ICON_ANIMATION
        GW.settings.MICROMENU_NOTIFICATION_ICON_ANIMATION = nil
    end
    if GW.settings.FADE_MICROMENU ~= nil then
        GW.settings.micromenu.fade = GW.settings.FADE_MICROMENU
        GW.settings.FADE_MICROMENU = nil
    end
    if GW.settings.MICROMENU_EVENT_TIMER_ICON ~= nil then
        GW.settings.micromenu.eventTimerIcon = GW.settings.MICROMENU_EVENT_TIMER_ICON
        GW.settings.MICROMENU_EVENT_TIMER_ICON = nil
    end

    -- hero panel stats moved from the profile into the character settings (11.2.0)
    if GW.settings.CHARACTER_STAT_ORDER ~= nil or GW.settings.CHARACTER_STAT_VISIBILITY ~= nil or GW.settings.CHARACTER_SHOW_SET_BONUS ~= nil then
        local stats = GW.private.heroPanel.stats
        if #stats.order == 0 and next(stats.visibility) == nil then
            for _, key in ipairs(GW.settings.CHARACTER_STAT_ORDER or {}) do
                tinsert(stats.order, key)
            end
            for key, visible in pairs(GW.settings.CHARACTER_STAT_VISIBILITY or {}) do
                stats.visibility[key] = visible
            end
            if GW.settings.CHARACTER_SHOW_SET_BONUS == false then
                stats.visibility.SETBONUS = false
            end
        end
        GW.settings.CHARACTER_STAT_ORDER = nil
        GW.settings.CHARACTER_STAT_VISIBILITY = nil
        GW.settings.CHARACTER_SHOW_SET_BONUS = nil
    end
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
