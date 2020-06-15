local _, GW = ...

local storage

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
local GetRealmStorage = function (...)
    local _, realm = UnitFullName("player")

    return GetStorage(GW.myfaction, realm, ...)
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

local GetCharClass = function (name)
    return GetRealmStorage("CLASS", name)
end
GW.GetCharClass = GetCharClass


---------- MONEY ----------

local UpdateMoney = function ()
    local money = GetMoney()
    SetRealmStorage("MONEY", GW.myname, money)
end
GW.UpdateMoney = UpdateMoney

-- Get all money on this realm and faction
local GetRealmMoney = function ()
    local s = GetRealmStorage("MONEY")

    if s then
        local sum = 0
        for _,v in pairs(s) do
            sum = sum + v
        end
        return s, sum
    end
end
GW.GetRealmMoney = GetRealmMoney
