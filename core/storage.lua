local _, GW = ...

local storage

local LoadStorage = function ()
    GW2UI_STORAGE2 = GW2UI_STORAGE2 or {}
    storage = GW2UI_STORAGE2

    -- Update Chardata
    GW.UpdateCharData()
    GW.UpdateMoney()

    -- Migrate data to new table (temp function)
    if GW2UI_STORAGE then
        local oldStorage = GW2UI_STORAGE
        local SetMigrateData = function(realm, name, key, value)
            local s = storage

            s[realm] = s[realm] or {}
            s = s[realm]
            s[name] = s[name] or {}
            s = s[name]

            s[key] = value
        end

        for faction, realm in pairs(oldStorage) do
            if realm and type(realm) == "table" then
                for realmName, realmValues in pairs(realm) do
                    if realmValues and type(realmValues) == "table" then
                        for typeKey, typeValues in pairs(realmValues) do
                            if typeValues and type(typeValues) == "table" then
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
            if chars and type(chars) == "table" then
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
local SetStorage = function (key, value)
    if not storage then return end

    local s = storage

    s[GW.myrealm] = s[GW.myrealm] or {}
    s = s[GW.myrealm]
    s[GW.myname] = s[GW.myname] or {}
    s = s[GW.myname]

    s[key] = value
end
GW.SetStorage = SetStorage

-- Get a storage value by passing the key or a tableTyp to get the complete table or without an parameter to get char table
local GetStorage = function (key, tableTyp)
    if not storage then return end

    local s = storage

    if tableTyp then
        if tableTyp == "REALM" then
            return s[GW.myrealm] and s[GW.myrealm] or nil
        end
    end

    if s[GW.myrealm] and s[GW.myrealm][GW.myname] then
        if key then
            if s[GW.myrealm][GW.myname][key] then
                return s[GW.myrealm][GW.myname][key]
            else
                return nil
            end
        else
            return s[GW.myrealm][GW.myname]
        end
    end

    return nil
end
GW.GetStorage = GetStorage

-- Clear the whole storage or just a part of it
local ClearStorage = function (key, overrideCharacter)
    if not storage then return end

    local s = storage

    if s[GW.myrealm] and s[GW.myrealm][(overrideCharacter and overrideCharacter or GW.myname)] then
        if key and s[GW.myrealm][(overrideCharacter and overrideCharacter or GW.myname)][key] then
            s[GW.myrealm][(overrideCharacter and overrideCharacter or GW.myname)][key] = nil
        elseif not key then
            s[GW.myrealm][(overrideCharacter and overrideCharacter or GW.myname)] = nil
        end
    end
end
GW.ClearStorage = ClearStorage

---------- MONEY ----------
local UpdateMoney = function ()
    local money = GetMoney()

    -- first store old money
    local oldMoney = GetStorage("money")
    local OldMoney = oldMoney or money

    local change = money - OldMoney 
    if OldMoney > money then        -- Lost Money
        GW.spentMoney = GW.spentMoney - change
    else                            -- Gained Moeny
        GW.earnedMoney = GW.earnedMoney + change
    end

    SetStorage("money", money)
end
GW.UpdateMoney = UpdateMoney

---------- CHAR DATA ----------
local UpdateCharData = function ()
    SetStorage("name", GW.myname)
    SetStorage("faction", GW.myfaction)
    SetStorage("class", GW.myclass)
end
GW.UpdateCharData = UpdateCharData
