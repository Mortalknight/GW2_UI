local _, GW = ...

local storage

--[[
local LoadStorage = function ()
    GW2UI_STORAGE = GW2UI_STORAGE or {}
    storage = GW2UI_STORAGE

    GW.UpdateCharClass()
    GW.UpdateMoney()
end
GW.LoadStorage = LoadStorage

-- Set a storage value by passing the path segments and value
-- Example: To set storage[a][b][c] to v call SetStorage("a", "b", "c", v)
local SetStorage = function (...)
    if not storage then return end

    local s, n = storage, select("#", ...)

    for i=1, n-2 do
        local k = select(i, ...)
        s[k] = s[k] or {}
        s = s[k]
    end

    s[select(n-1, ...)] = select(n, ...)
end
GW.SetStorage = SetStorage

-- Get a storage value by passing the path segments
-- Example: To get storage[a][b][c] call GetStorage("a", "b", "c")
local GetStorage = function (...)
    if not storage then return end

    local s, n = storage, select("#", ...)

    for i=1, n do
        if s ~= nil then s = s[select(i, ...)] end
    end

    return s
end
GW.GetStorage = GetStorage

-- Get a storage or value for the players realm+faction
local GetRealmStorage = function (overrideFraction, ...)
    local _, realm = UnitFullName("player")

    return GetStorage(overrideFraction and overrideFraction or GW.myfaction, realm, ...)
end
GW.GetRealmStorage = GetRealmStorage

-- Set a value on the realm+faction storage
local SetRealmStorage = function (...)
    local _, realm = UnitFullName("player")

    SetStorage(GW.myfaction, realm, ...)
end
GW.SetRealmStorage = SetRealmStorage

-- Clear the whole storage or just a part of it
local ClearStorage = function (...)
    if not storage then return end

    local n, s, k = select("#", ...), ...
    if n > 0 and s == nil then
        return
    elseif type(s) ~= "table" then
        s, k = storage, s
    end

    if k then
        if type(s[k]) == "table" then
            wipe(s[k])
        else
            s[k] = nil
        end
    else
        wipe(s)
    end
end
GW.ClearStorage = ClearStorage


---------- CLASS ----------

local UpdateCharClass = function ()
    SetRealmStorage("CLASS", GW.myname, GW.myclass)
end
GW.UpdateCharClass = UpdateCharClass

local GetCharClass = function (name, fraction)
    return GetRealmStorage(fraction and fraction or nil, "CLASS", name)
end
GW.GetCharClass = GetCharClass


---------- MONEY ----------

local UpdateMoney = function ()
    local money = GetMoney()

    -- first store old money
    local oldMoney = GetRealmStorage(nil, "MONEY", GW.myname)
    local OldMoney = oldMoney or money

    local change = money - OldMoney 
    if OldMoney > money then		-- Lost Money
		GW.spentMoney = GW.spentMoney - change
	else							-- Gained Moeny
		GW.earnedMoney = GW.earnedMoney + change
	end

    SetRealmStorage("MONEY", GW.myname, money)
end
GW.UpdateMoney = UpdateMoney

-- Get all money on this realm and faction
local GetRealmMoney = function ()
    local s = GetRealmStorage(nil, "MONEY")

    if s then
        local sum = 0
        for _,v in pairs(s) do
            sum = sum + v
        end
        return s, sum
    end
end
GW.GetRealmMoney = GetRealmMoney

local GetRealmMoneyForFraction = function (fraction)
    local s = GetRealmStorage(fraction, "MONEY")

    if s then
        local sum = 0
        for _,v in pairs(s) do
            sum = sum + v
        end
        return s, sum
    end
end
GW.GetRealmMoneyForFraction = GetRealmMoneyForFraction
]]

local LoadStorage = function ()
    GW2UI_STORAGE2 = GW2UI_STORAGE2 or {}
    storage = GW2UI_STORAGE2

    -- Update Chardata
    GW.UpdateCharData()
    GW.UpdateMoney()
end
GW.LoadStorage = LoadStorage

-- Set a storage value by REALM FRACTION CHARNAME key = values
local SetStorage = function (key, value)
    if not storage then return end

    local s = storage

    s[GW.myrealm] = s[GW.myrealm] or {}
    s = s[GW.myrealm]
    s[GW.myfaction] = s[GW.myfaction] or {}
    s = s[GW.myfaction]
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
        elseif tableTyp == "FACTION" then
            return s[GW.myrealm] and s[GW.myrealm][GW.myfaction] and s[GW.myrealm][GW.myfaction] or nil
        end
    end   

    if s[GW.myrealm] and s[GW.myrealm][GW.myfaction] and s[GW.myrealm][GW.myfaction][GW.myname] then
        if key then
            if s[GW.myrealm][GW.myfaction][GW.myname][key] then
                return s[GW.myrealm][GW.myfaction][GW.myname][key]
            else
                return nil
            end
        else
            return s[GW.myrealm][GW.myfaction][GW.myname]
        end
    end

    return nil
end
GW.GetStorage = GetStorage

-- Clear the whole storage or just a part of it
local ClearStorage = function (key, overrideData)
    if not storage then return end

    local s = storage

    if overrideData then
        local overrideFation, overrideCharacter = unpack(overrideData)

        if s[GW.myrealm] and s[GW.myrealm][overrideFation] and s[GW.myrealm][overrideFation][overrideCharacter] then
            if key and s[GW.myrealm][overrideFation][overrideCharacter][key] then
                s[GW.myrealm][overrideFation][overrideCharacter][key] = nil
            elseif not key then
                s[GW.myrealm][overrideFation][overrideCharacter] = nil
            end
        end
        return
    end
    if s[GW.myrealm] and s[GW.myrealm][GW.myfaction] and s[GW.myrealm][GW.myfaction][GW.myname] then
        if key and s[GW.myrealm][GW.myfaction][GW.myname][key] then
            s[GW.myrealm][GW.myfaction][GW.myname][key] = nil
        elseif not key then
            s[GW.myrealm][GW.myfaction][GW.myname] = nil
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
    if OldMoney > money then		-- Lost Money
		GW.spentMoney = GW.spentMoney - change
	else							-- Gained Moeny
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


