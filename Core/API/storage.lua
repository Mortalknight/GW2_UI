---@class GW2
local GW = select(2, ...)

local charRealm, charName

local function GetForeverRuleset()
    if C_GameRules.IsGameRuleActive(Enum.GameRule.HardcoreRuleset) then
        return "Hardcore"
    elseif C_GameRules.IsGameRuleActive(Enum.GameRule.RPRuleset) then
        return "RP"
    elseif C_GameRules.IsGameRuleActive(Enum.GameRule.PvPRuleset) then
        return "PvP"
    end
    return "PvE"
end

local function GetCharKeys()
    if not charName then
        if GW.Forever then
            local name, surname = UnitNameUnmodified("player")
            if not name or name == UNKNOWNOBJECT then return end
            charRealm = GetForeverRuleset()
            charName = surname and surname ~= "" and format("%s %s", name, surname) or name
        else
            local name = UnitName("player")
            if not name or name == UNKNOWNOBJECT then return end
            charRealm, charName = GW.myrealm, name
        end
    end
    return charRealm, charName
end

local function EnsureCharScope()
    local chars = GW.global.chars
    if not chars then return end
    local realm, name = GetCharKeys()
    if not realm then return end

    chars[realm] = chars[realm] or {}
    chars[realm][name] = chars[realm][name] or {}
    return chars[realm][name]
end

local function LoadStorage()
    local chars = GW.global.chars

    -- migrate the old standalone saved variable (temp function)
    if type(GW2UI_STORAGE2) == "table" then
        for realm, realmChars in pairs(GW2UI_STORAGE2) do
            if type(realmChars) == "table" then
                chars[realm] = chars[realm] or {}
                for name, values in pairs(realmChars) do
                    if type(values) == "table" and chars[realm][name] == nil then
                        chars[realm][name] = values
                    end
                end
            end
        end
        GW2UI_STORAGE2 = nil
    end
end
GW.LoadStorage = LoadStorage

-- Set a storage value by REALM CHARNAME key = values
local function SetStorage(key, value)
    local s = EnsureCharScope()
    if not s then return end
    s[key] = value
    -- shown on the characters page of the profiles
    s.lastUpdate = time()
end
GW.SetStorage = SetStorage

-- Get a storage value by passing the key or a tableScope to get the complete table or without an parameter to get char table
-- tableScope: "REALM" | "CHAR" | nil  (nil behaves like "CHAR")
local function GetStorage(key, tableScope)
    local chars = GW.global.chars
    tableScope = tableScope or "CHAR"

    local realm, name = GetCharKeys()
    if not realm then return end

    if tableScope == "REALM" then
        return chars[realm]
    elseif tableScope == "CHAR" then
        local s = chars[realm] and chars[realm][name]
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
    local chars = GW.global.chars
    local realm, myName = GetCharKeys()
    if not realm then return end
    local name = overrideCharacter or myName
    local realmTbl = chars[realm]
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
    if not IsLoggedIn() then return end
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
    SetStorage("name", select(2, GetCharKeys()))
    -- forever files the storage under the ruleset, the realm names the character in the profile databases
    SetStorage("realm", GW.myrealm)
    -- lets the characters page of the profiles tell old characters apart
    SetStorage("lastSeen", time())
    SetStorage("faction", GW.myfaction)
    SetStorage("class", GW.myclass)
    UpdateMoney()
end
GW.UpdateCharData = UpdateCharData
