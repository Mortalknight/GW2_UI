local _, GW = ...
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local DEBUFF_COLOR = GW.DEBUFF_COLOR

if UnitIsTapDenied == nil then
    function UnitIsTapDenied()
        if (UnitIsTapped("target")) and (not UnitIsTappedByPlayer("target")) then
            return true
        end
        return false
    end
end

local function CountTable(T)
    local c = 0
    if T ~= nil and type(T) == "table" then
        for _ in pairs(T) do
            c = c + 1
        end
    end
    return c
end
GW.CountTable = CountTable

local function TimeCount(numSec, com)
    local nSeconds = tonumber(numSec)
    if nSeconds == nil then
        nSeconds = 0
    end
    if nSeconds == 0 then
        return "0"
    end

    local nHours = math.floor(nSeconds / 3600)
    if nHours > 0 then
        return nHours .. "h"
    end

    local nMins = math.floor(nSeconds / 60)
    if nMins > 0 then
        return nMins .. "m"
    end

    if com ~= nil then
        local nMilsecs = math.max(math.floor((nSeconds * 10 ^ 1) + 0.5) / (10 ^ 1), 0)
        return nMilsecs .. "s"
    end

    local nSecs = math.max(math.floor(nSeconds), 0)
    return nSecs .. "s"
end
GW.TimeCount = TimeCount

local function RoundDec(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end
GW.RoundDec = RoundDec

local function CommaValue(n)
    n = RoundDec(n)
    local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")
    return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end
GW.CommaValue = CommaValue

local function RoundInt(v)
    if v == nil then
        return 0
    end
    vf = math.floor(v)
    if (v - vf) > 0.5 then
        return vf + 1
    end
    return vf
end
GW.RoundInt = RoundInt

local function Diff(a, b)
    if a == nil then
        a = 0
    end
    if b == nil then
        b = 0
    end

    if a > b then
        return a - b
    else
        return b - a
    end
end
GW.Diff = Diff

local function lerp(v0, v1, t)
    if v0 == nil then
        v0 = 0
    end
    local p = (v1 - v0)
    return v0 + t * p
end
GW.lerp = lerp

local function Length(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end
GW.Length = Length

local function SplitString(inputstr, sep, sep2, sep3)
    if sep == nil then
        sep = "%s"
    end
    inputstr = inputstr:gsub("\n", "")
    local t = {}
    i = 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "|" .. sep2 .. "|" .. sep3 .. "]+)") do
        st, en, cap1, cap2, cap3 = string.find(inputstr, str)
        if en ~= nil then
            s = string.sub(inputstr, en + 1, en + 1)
            if s ~= nil or s ~= "" then
                str = str .. s
            end
        end
        t[i] = str
        i = i + 1
    end
    return t
end
GW.SplitString = SplitString

local function IsNAN(n)
    return tostring(n) == "-1.#IND"
end
GW.IsNAN = IsNAN

local function IsFrameModified(f_name)
    if not MovAny then
        return false
    end
    return MovAny:IsModified(f_name)
end
GW.IsFrameModified = IsFrameModified

local function sortAuras(a, b)
    if a["caster"] == nil then
        a["caster"] = ""
    end
    if b["caster"] == nil then
        b["caster"] = ""
    end

    if a["caster"] == b["caster"] then
        return a["timeremaning"] < b["timeremaning"]
    end

    return (b["caster"] ~= "player" and a["caster"] == "player")
end

local function sortAuraList(auraList)
    table.sort(
        auraList,
        function(a, b)
            return sortAuras(a, b)
        end
    )

    return auraList
end

local function GetBuffs(unit, filter)
    if filter == nil then
        filter = ""
    end
    local auraList = {}
    for i = 1, 40 do
        if UnitBuff(unit, i, filter) ~= nil then
            auraList[i] = {}
            auraList[i]["id"] = i

            auraList[i]["name"],
                auraList[i]["icon"],
                auraList[i]["count"],
                auraList[i]["dispelType"],
                auraList[i]["duration"],
                auraList[i]["expires"],
                auraList[i]["caster"],
                auraList[i]["isStealable"],
                auraList[i]["shouldConsolidate"],
                auraList[i]["spellID"] = UnitBuff(unit, i, filter)

            auraList[i]["timeremaning"] = auraList[i]["expires"] - GetTime()

            if auraList[i]["duration"] <= 0 then
                auraList[i]["timeremaning"] = 500001
            end
        end
    end

    return sortAuraList(auraList)
end
GW.GetBuffs = GetBuffs

local function GetDebuffs(unit, filter)
    local auraList = {}

    for i = 1, 40 do
        if UnitDebuff(unit, i, filter) ~= nil then
            auraList[i] = {}
            auraList[i]["id"] = i

            auraList[i]["name"],
                auraList[i]["rank"],
                auraList[i]["icon"],
                auraList[i]["count"],
                auraList[i]["dispelType"],
                auraList[i]["duration"],
                auraList[i]["expires"],
                auraList[i]["caster"],
                auraList[i]["isStealable"],
                auraList[i]["shouldConsolidate"],
                auraList[i]["spellID"] = UnitDebuff(unit, i, filter)

            auraList[i]["timeremaning"] = auraList[i]["expires"] - GetTime()

            if auraList[i]["duration"] <= 0 then
                auraList[i]["timeremaning"] = 500001
            end
        end
    end

    return sortAuraList(auraList)
end
GW.GetDebuffs = GetDebuffs

local function setAuraType(self, typeAura)
    if self.typeAura == typeAura then
        return
    end

    if typeAura == "smallbuff" then
        self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
        self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
        self.duration:SetFont(UNIT_NAME_FONT, 11)
        self.stacks:SetFont(UNIT_NAME_FONT, 12, "OUTLINED")
    end

    if typeAura == "bigBuff" then
        self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
        self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
        self.duration:SetFont(UNIT_NAME_FONT, 14)
        self.stacks:SetFont(UNIT_NAME_FONT, 14, "OUTLINED")
    end

    self.typeAura = typeAura
end

local function SetBuffData(self, buffs, i, oldBuffs)
    if not self or not buffs then
        return false
    end
    local b = buffs[i]
    if b == nil or b["name"] == nil then
        return false
    end

    local stacks = ""
    local duration = ""

    if b["caster"] == "player" and (b["duration"] > 0 and b["duration"] < 120) then
        setAuraType(self, "bigBuff")

        self.cooldown:SetCooldown(b["expires"] - b["duration"], b["duration"])
    else
        setAuraType(self, "smallbuff")
    end

    if b["count"] ~= nil and b["count"] > 1 then
        stacks = b["count"]
    end
    if b["timeremaning"] ~= nil and b["timeremaning"] > 0 and b["timeremaning"] < 500000 then
        duration = TimeCount(b["timeremaning"])
    end

    if b["expires"] < 1 or b["timeremaning"] > 500000 then
        self.expires = nil
    else
        self.expires = b["expires"]
    end

    if self.auraType == "debuff" then
        if b["dispelType"] ~= nil then
            self.background:SetVertexColor(
                DEBUFF_COLOR[b["dispelType"]].r,
                DEBUFF_COLOR[b["dispelType"]].g,
                DEBUFF_COLOR[b["dispelType"]].b
            )
        else
            self.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
        end
    else
        if b["isStealable"] then
            self.background:SetVertexColor(1, 1, 1)
        else
            self.background:SetVertexColor(0, 0, 0)
        end
    end

    self.auraid = b["id"]
    self.duration:SetText(duration)
    self.stacks:SetText(stacks)
    self.icon:SetTexture(b["icon"])

    return true
end
GW.SetBuffData = SetBuffData

local function AddForProfiling(unit, name, ...)
    if not Profiler then
        return
    end
    --[[
    local variables = {}
    local idx = 1
    while true do
        local ln, lv = debug.getlocal(2, idx)
        if ln ~= nil then
            variables[ln] = lv
        else
            break
        end
        idx = 1 + idx
    end
    _G["GW_" .. name] = variables
    --]]
    local gName = "GW_" .. unit
    if not _G[gName] then
        _G[gName] = {}
    end

    _G[gName][name] = ...
end
GW.AddForProfiling = AddForProfiling
