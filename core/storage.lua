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

    for i=1, n-1 do
        local k = select(i, ...)
        if i == n-1 then
            s[k] = select(n, ...)
        else
            s[k] = s[k] or {}
            s = s[k]
        end
    end
end
GW.SetStorage = SetStorage

-- Get a storage value by passing the path segments
-- Example: To get storage[a][b][c] call GetStorage("a", "b", "c")
local GetStorage = function (...)
    if not storage then return end

    local s, n = storage, select("#", ...)

    for i=1, n do
        local k = select(i, ...)
        if i == n or s[k] == nil then
            return s[k]
        else
            s = s[k]
        end
    end
end
GW.GetStorage = GetStorage

-- Get a storage or value for the players realm+faction
local GetRealmStorage = function (...)
    local faction = UnitFactionGroup("player")
    local _, realm = UnitFullName("player")

    SetStorage(faction, realm, GetStorage(faction, realm) or {})

    return GetStorage(faction, realm, ...)
end
GW.GetRealmStorage = GetRealmStorage

-- Set a value on the realm+faction storage
local SetRealmStorage = function (...)
    local faction = UnitFactionGroup("player")
    local _, realm = UnitFullName("player")

    SetStorage(faction, realm, ...)
end
GW.SetRealmStorage = SetRealmStorage

-- Clear the whole storage or just a part of it
local ClearStorage = function (s, k)
    if not storage then return end

    s = s or storage

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
    local name = UnitName("player")
    local class = select(2, UnitClass("player"))
    SetRealmStorage("CLASS", name, class)
end
GW.UpdateCharClass = UpdateCharClass

local GetCharClass = function (name)
    return GetRealmStorage("CLASS", name)
end
GW.GetCharClass = GetCharClass


---------- MONEY ----------

local UpdateMoney = function ()
    local money = GetMoney()
    local name = UnitName("player")
    SetRealmStorage("MONEY", name, money)
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
