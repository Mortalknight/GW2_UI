local _, GW = ...

local storage

local function EnsureCharScope()
    if not storage or not GW.myrealm or not GW.myname then return end
    local realm = GW.myrealm
    local name = GW.myname

    storage[realm] = storage[realm] or {}
    storage[realm][name] = storage[realm][name] or {}
    return storage[realm][name]
end

local function SetMigrateData(realm, name, key, value)
    storage[realm] = storage[realm] or {}
    storage[realm][name] = storage[realm][name] or {}
    storage[realm][name][key] = value
end

local function LoadStorage()
    GW2UI_STORAGE2 = GW2UI_STORAGE2 or {}
    storage = GW2UI_STORAGE2

    -- Migrate data to new table (temp function)
    if GW2UI_STORAGE and type(GW2UI_STORAGE) == "table" then
        local oldStorage = GW2UI_STORAGE

        for faction, realm in pairs(oldStorage) do
            if type(realm) == "table" then
                for realmName, realmValues in pairs(realm) do
                    if type(realmValues) == "table" then
                        for typeKey, typeValues in pairs(realmValues) do
                            if type(typeValues) == "table" then
                                for valueKey, values in pairs(typeValues) do
                                    SetMigrateData(realmName, valueKey, "name", valueKey)
                                    SetMigrateData(realmName, valueKey, "faction", faction)
                                    if typeKey == "CLASS" then SetMigrateData(realmName, valueKey, "class", values) end
                                    if typeKey == "MONEY" then SetMigrateData(realmName, valueKey, "money", values) end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- add money if we do not have them
        for _, chars in pairs(storage) do
            if type(chars) == "table" then
                for _, v in pairs(chars) do
                    if not v.money then v.money = 0 end
                end
            end
        end

        GW2UI_STORAGE = nil
    end
end
GW.LoadStorage = LoadStorage

-- Set a storage value by REALM CHARNAME key = values
local function SetStorage(key, value)
    local s = EnsureCharScope()
    if not s then return end
    s[key] = value
end
GW.SetStorage = SetStorage

-- Get a storage value by passing the key or a tableScope to get the complete table or without an parameter to get char table
-- tableScope: "REALM" | "CHAR" | nil  (nil behaves like "CHAR")
local function GetStorage(key, tableScope)
    if not storage then return end
    tableScope = tableScope or "CHAR"

    if tableScope == "REALM" then
        return storage[GW.myrealm] and storage[GW.myrealm] or nil
    elseif tableScope == "CHAR" then
        if not GW.myname then return end
        local s = storage[GW.myrealm] and storage[GW.myrealm][GW.myname]
        if not s then return end
        if key ~= nil then
            return s[key]
        else
            return s
        end
    end

    return nil
end
GW.GetStorage = GetStorage

-- Clear the whole storage or just a part of it
local function ClearStorage(key, overrideCharacter)
    if not storage then return end
    local name = overrideCharacter or GW.myname
    local realmTbl = storage[GW.myrealm]
    local charTbl = realmTbl and realmTbl[name]
    if not charTbl then return end

    if key ~= nil then
        charTbl[key] = nil
    else
        realmTbl[name] = nil
    end
end
GW.ClearStorage = ClearStorage

---------- MONEY ----------
local UpdateMoney = function ()
    local money = GetMoney() or 0

    -- first store old money
    local prev = GetStorage("money") or money
    local delta = money - prev

    if delta < 0 then
        GW.spentMoney = GW.spentMoney + (-delta)
    elseif delta > 0 then
        GW.earnedMoney = GW.earnedMoney + delta
    end

    SetStorage("money", money)
end
GW.UpdateMoney = UpdateMoney

---------- CHAR DATA ----------
local UpdateCharData = function ()
    SetStorage("name", GW.myname)
    SetStorage("faction", GW.myfaction)
    SetStorage("class", GW.myclass)
    UpdateMoney()
end
GW.UpdateCharData = UpdateCharData
