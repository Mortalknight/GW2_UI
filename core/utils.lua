local _, GW = ...

local afterCombatQueue = {}
local EMPTY = {}
local NIL = {}

local maxUpdatesPerCircle = 5

local function CombatQueue_Initialize()
    C_Timer.NewTicker(0.1, function()
        if InCombatLockdown() then
            return
        end

        local func = tremove(afterCombatQueue, 1)
        local count = 0
        while func do
            func.func(unpack(func.obj))
            if InCombatLockdown() or count >= maxUpdatesPerCircle then
                break
            end
            func = tremove(afterCombatQueue, 1)
            count = count + 1
        end
    end)
end
GW.CombatQueue_Initialize = CombatQueue_Initialize

local function CombatQueue_Queue(key, func, obj)
    local alreadyIn = false
    for _, v in pairs(afterCombatQueue) do
        if v.key == key and v.func == func and v.obj == obj then
            alreadyIn = true
        end
    end
    if not alreadyIn or key == nil then
        tinsert(afterCombatQueue, {key = key, func = func, obj = obj})
    end
end
GW.CombatQueue_Queue = CombatQueue_Queue

-- Easy menu
GW.EasyMenu = CreateFrame("Frame", "GWEasyMenu", UIParent, "UIDropDownMenuTemplate")

local function SetEasyMenuAnchor(menu, frame)
    local point = GW.GetScreenQuadrant(frame)
    local bottom = point and strfind(point, "BOTTOM")
    local left = point and strfind(point, "LEFT")

    local anchor1 = (bottom and left and "BOTTOMLEFT") or (bottom and "BOTTOMRIGHT") or (left and "TOPLEFT") or "TOPRIGHT"
    local anchor2 = (bottom and left and "TOPLEFT") or (bottom and "TOPRIGHT") or (left and "BOTTOMLEFT") or "BOTTOMRIGHT"

    UIDropDownMenu_SetAnchor(menu, 0, 0, anchor1, frame, anchor2)
end
GW.SetEasyMenuAnchor = SetEasyMenuAnchor

if UnitIsTapDenied == nil then
    function UnitIsTapDenied()
        if (UnitIsTapped("target")) and (not UnitIsTappedByPlayer("target")) then
            return true
        end
        return false
    end
end

local function IsIn(val, ...)
    for i = 1, select("#", ...) do
        if val == select(i, ...) then return true end
    end
    return false
end
GW.IsIn = IsIn

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

local function SetPointsRestricted(frame)
	if frame and not pcall(frame.GetPoint, frame) then
		return true
	end
end
GW.SetPointsRestricted = SetPointsRestricted

local function tableContains(t,val)
    for _,v in pairs(t) do
        if v == val then
            return true
        end
    end
    return false
end
GW.tableContains = tableContains

function GW.__genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function GW.orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = GW.__genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function GW.orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return GW.orderedNext, t, nil
end

local function MapTable(T, fn, withKey)
    local t = {}
    for k,v in pairs(T) do
        if withKey then
            t[k] = fn(v, k)
        else
            t[k] = fn(v)
        end
    end
    return t
end
GW.MapTable = MapTable

local function FormatMoneyForChat(amount)
    local str, coppercolor, silvercolor, goldcolor = "", "|cffb16022", "|cffaaaaaa", "|cffddbc44"

    local value = abs(amount)
    local gold = math.floor(value / (COPPER_PER_SILVER * SILVER_PER_GOLD))
    local silver = math.floor((value - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
    local copper = mod(value, COPPER_PER_SILVER)

    if gold > 0 then
        str = format("%s%s |r|TInterface/MoneyFrame/UI-GoldIcon:12:12|t%s", goldcolor, GW.CommaValue(gold), " ")
    end
    if silver > 0 or gold > 0 then
        str = format("%s%s%d |r|TInterface/MoneyFrame/UI-SilverIcon:12:12|t%s", str, silvercolor, silver, (copper > 0 or gold > 0) and " " or "")
    end
    if copper > 0 or value == 0 or value > 0 then
        str = format("%s%s%d |r|TInterface/MoneyFrame/UI-CopperIcon:12:12|t", str, coppercolor, copper)
    end

    return str
end
GW.FormatMoneyForChat = FormatMoneyForChat

local function GWGetClassColor(class, useClassColor, forNameString, alwaysUseBlizzardColors)
    if not class or not useClassColor then
        return RAID_CLASS_COLORS.PRIEST
    end

    local useBlizzardClassColor = alwaysUseBlizzardColors or GW.settings.BLIZZARDCLASSCOLOR_ENABLED
    local color = useBlizzardClassColor and RAID_CLASS_COLORS[class] or GW.GW_CLASS_COLORS[class]
    local colorForNameString

    if type(color) ~= "table" then return end

    if not color.colorStr then
        color.colorStr = GW.RGBToHex(color.r, color.g, color.b, "ff")
    elseif strlen(color.colorStr) == 6 then
        color.colorStr = "ff" .. color.colorStr
    end

    if forNameString and not useBlizzardClassColor then
        colorForNameString = {r = min(color.r + 0.3, 1), g = min(color.g + 0.3, 1), b = min(color.b + 0.3, 1), a = color.a, colorStr = GW.RGBToHex(min(color.r + 0.3, 1), min(color.g + 0.3, 1), min(color.b + 0.3, 1), "ff")}
    end

    return forNameString and colorForNameString or color
end
GW.GWGetClassColor = GWGetClassColor

--RGB to Hex
local function RGBToHex(r, g, b, header, ending)
    r = r <= 1 and r >= 0 and r or 1
    g = g <= 1 and g >= 0 and g or 1
    b = b <= 1 and b >= 0 and b or 1
    return format("%s%02x%02x%02x%s", header or "|cff", r * 255, g * 255, b * 255, ending or "")
end
GW.RGBToHex = RGBToHex

local function GetUnitBattlefieldFaction(unit)
    return UnitFactionGroup(unit)
end
GW.GetUnitBattlefieldFaction = GetUnitBattlefieldFaction

local function FillTable(T, map, ...)
    wipe(T)
    for i=1,select("#", ...) do
        local v = select(i, ...)
        if map then
            T[v] = true
        else
            tinsert(T, v)
        end
    end
    return T
end
GW.FillTable = FillTable

local function TimeParts(ms)
    local nMS = tonumber(ms)
    local nSec, nMin, nHr
    if nMS == nil then
        nMS = 0
    end

    nHr = math.floor(nMS / 1440000)
    nMS = nMS - (nHr * 1440000)

    nMin = math.floor(nMS / 60000)
    nMS = nMS - (nMin * 60000)

    nSec = math.floor(nMS / 1000)
    nMS = nMS - (nSec * 1000)

    return nHr, nMin, nSec, nMS
end
GW.TimeParts = TimeParts

local function GetCIDFromGUID(guid)
    local type, _, playerdbID, _, _, cid, _ = strsplit("-", guid or "")
    if type and (type == "Creature" or type == "Vehicle" or type == "Pet") then
        return tonumber(cid)
    elseif type and (type == "Player" or type == "Item") then
        return tonumber(playerdbID)
    end
    return 0
end

local function GetUnitCreatureId(uId)
    local guid = UnitGUID(uId)
    return GetCIDFromGUID(guid)
end
GW.GetUnitCreatureId = GetUnitCreatureId

local fstr = "%.0fs"
local function TimeCount(numSec, com)
    local nSeconds = tonumber(numSec)
    if nSeconds == nil then
        nSeconds = 0
    end
    if nSeconds == 0 then
        return "0s"
    end
    if nSeconds >= 86400 then
        return ceil(nSeconds / 86400) .. "d"
    end
    if nSeconds >= 3600 then
        return ceil(nSeconds / 3600) .. "h"
    end
    if nSeconds >= 60 then
        return ceil(nSeconds / 60) .. "m"
    end
    if com ~= nil then
        local nMilsecs = math.max(math.floor((nSeconds * 10 ^ 1) + 0.5) / (10 ^ 1), 0)
        return nMilsecs .. "s"
    end
    -- inline this because we do it a lot
    return fstr:format(nSeconds)
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
    local vf = math.floor(v)
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

local function lerpEaseOut(v0,v1,t)
    t = min(1,t)
    t = math.sin(t * math.pi * 0.5);

    return lerp(v0,v1,t)
end
GW.lerpEaseOut = lerpEaseOut

local function signum(number)
    if number > 0 then
       return 1
    elseif number < 0 then
       return -1
    else
       return 0
    end
end

local function MoveTowards( current,  target,  maxDelta)
    if math.abs(target - current) <= maxDelta then
        return target;
    end
    return current + signum(target - current) * maxDelta;
end
GW.MoveTowards = MoveTowards

local function Length(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end
GW.Length = Length

do
    local splitTable = {}
    local function splitString(str, delim)
        local start = 1
        wipe(splitTable)

        while true do
            local pos = strfind(str, delim, start, true)
            if not pos then
                break
            end
            tinsert(splitTable, strsub(str, start, pos -1))
            start = pos + strlen(delim)
        end

        tinsert(splitTable, strsub(str, start))

        return unpack(splitTable)
    end
    GW.splitString = splitString
end

local function FindInList(list, str, i, del)
    local del = "([^%s" .. (del or ",;") .. ")]?)"
    str = del .. "(%s*)(" .. str .. ")(%s*)" .. del
    i = i or 1
    while i do
        local s, e, a, b, m, c, d = list:find(str, i)
        if s and a == "" and d == "" then
            return s + #b, e - #c, m
        end
        i = e and e + 1
    end
end
GW.FindInList = FindInList

-- String upper and lower that are noops for locales without letter case
local function StrUpper(str, i, j)
    if not str or IsIn(GW.mylocal, "koKR", "zhCN", "zhTW") then
        return str
    else
        return (i and str:sub(1, i - 1) or "") .. str:sub(i or 1, j):upper() .. (j and str:sub(j + 1) or "")
    end
end
GW.StrUpper = StrUpper
local function StrLower(str, i, j)
    if not str or IsIn(GW.mylocal, "koKR", "zhCN", "zhTW") then
        return str
    else
        return (i and str:sub(1, i - 1) or "") .. str:sub(i or 1, j):lower() .. (j and str:sub(j + 1) or "")
    end
end
GW.StrLower = StrLower

local function IsNAN(n)
    return tostring(n) == tostring(0/0)
end
GW.IsNAN = IsNAN

local function IsFrameModified(f_name)
    if not MovAny then
        return false
    end
    return MovAny:IsModified(f_name)
end
GW.IsFrameModified = IsFrameModified

local function Notice(...)
    local msg_tab = _G["ChatFrame1"]
    if not msg_tab then
        return
    end
    local msg = ""
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        msg = msg .. tostring(arg) .. " "
    end
    msg_tab:AddMessage(GW.Gw2Color .. "GW2 UI|r: " .. msg)
end
GW.Notice = Notice

local function securePetAndOverride(f, stateType)
    if InCombatLockdown() then
        return false
    end
    f:SetAttribute("gw_WasShowing", f:IsShown())
    f:SetAttribute(
        "_onstate-petoverride",
        [=[
        if newstate == "show" then
            if self:GetAttribute("gw_WasShowing") then
                self:Show()
            end
        elseif newstate == "hide" then
            self:SetAttribute("gw_WasShowing", self:IsShown())
            self:Hide()
        end
    ]=]
    )
    if stateType == "petbattle" then
        RegisterStateDriver(f, "petoverride", "[petbattle] hide; show")
    elseif stateType == "override" then
        RegisterStateDriver(f, "petoverride", "[overridebar] hide; [vehicleui] hide; show")
    else
        RegisterStateDriver(f, "petoverride", "[overridebar] hide; [vehicleui] hide; [petbattle] hide; [possessbar,@vehicle,exists] hide; show")
    end
    return true
end

local function normPetAndOverride(f, stateType)
    local f_OnShow = function()
        f.gw_WasShowing = f:IsShown()
        f:Hide()
    end
    local f_OnHide = function()
        if f.gw_WasShowing then
            f:Show()
        end
    end

    if stateType ~= "petbattle" then
        OverrideActionBar:HookScript("OnShow", f_OnShow)
        OverrideActionBar:HookScript("OnHide", f_OnHide)
    end
    if stateType ~= "override" then
        --PetBattleFrame:HookScript("OnShow", f_OnShow)
        --PetBattleFrame:HookScript("OnHide", f_OnHide)
    end

    return true
end

local function MixinHideDuringPet(f)
    -- TODO: figure out how to do real mixins
    if f:IsProtected() then
        return securePetAndOverride(f, "petbattle")
    else
        return normPetAndOverride(f, "petbattle")
    end
end
GW.MixinHideDuringPet = MixinHideDuringPet

local function MixinHideDuringOverride(f)
    if f:IsProtected() then
        return securePetAndOverride(f, "override")
    else
        return normPetAndOverride(f, "override")
    end
end
GW.MixinHideDuringOverride = MixinHideDuringOverride

local function MixinHideDuringPetAndOverride(f)
    if f:IsProtected() then
        return securePetAndOverride(f)
    else
        return normPetAndOverride(f)
    end
end
GW.MixinHideDuringPetAndOverride = MixinHideDuringPetAndOverride

local PATTERN_ILVL = ITEM_LEVEL:gsub("%%d", "(%%d+)")
local PATTERN_ILVL_SCALED = ITEM_LEVEL_ALT:gsub("%(%%d%)", "%%((%%d)%%)"):gsub("%%d", "%%d+")

-- Get an item's real level, scanning the tooltip if necessary
local function GetRealItemLevel(link)
    local i, numBonusIds, linkLvl, upgradeLvl = 0, 0, nil, nil
    for v in link:gmatch(":(%-?%d*)") do
        i, v = i + 1, tonumber(v)
        if i == 9 then
            linkLvl = v
        elseif i == 13 then
            numBonusIds = v or 0
        elseif i == 14 + numBonusIds then
            upgradeLvl = v break
        end
    end

    if linkLvl and upgradeLvl and linkLvl ~= upgradeLvl then
        local tt = GWHiddenTooltip or CreateFrame("GameTooltip", "GWHiddenTooltip", nil, "GameTooltipTemplate")
        tt:SetOwner(UIParent, "ANCHOR_NONE")
        tt:ClearLines()
        tt:SetHyperlink(link)

        for i=2,min(3, tt:NumLines()) do
            local line = _G["GWHiddenTooltipTextLeft" .. i]:GetText()
            local lvl = line and tonumber(line:match(PATTERN_ILVL_SCALED) or line:match(PATTERN_ILVL))
            if lvl then return lvl end
        end
    end

    return (C_Item.GetDetailedItemLevelInfo(link))
end
GW.GetRealItemLevel = GetRealItemLevel

local function getContainerItemLinkByName(itemName)
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemLink(bag, slot)
            if item and item:find(itemName) then
                return item
            end
        end
    end
end
GW.getContainerItemLinkByName = getContainerItemLinkByName

local function frame_OnEnter(self)
    GameTooltip:SetOwner(self, self.tooltipDir, 0, self.tooltipYoff)
    GameTooltip:SetText(self.tooltipText, 1, 1, 1)
    if self.tooltipAddLine then
        GameTooltip:AddLine(self.tooltipAddLine)
    end
    GameTooltip:Show()
end

local function EnableTooltip(self, text, dir, y_off)
    self.tooltipText = text
    if not dir then
        dir = "ANCHOR_LEFT"
    end
    if not y_off then
        y_off = -40
    end
    self.tooltipDir = dir
    self.tooltipYoff = y_off
    self:HookScript("OnEnter", frame_OnEnter)
    self:HookScript("OnLeave", GameTooltip_Hide)
end
GW.EnableTooltip = EnableTooltip

local function vernotes(ver, notes)
    if not GW.GW_CHANGELOGS then
        GW.GW_CHANGELOGS = ""
    end
    GW.GW_CHANGELOGS = GW.GW_CHANGELOGS .. "\n" .. ver .. "\n\n" .. notes .. "\n\n"
end
GW.vernotes = vernotes

local function addChange(addonVersion, changeList)
    if not GW.GW_CHANGELOGS then
        GW.GW_CHANGELOGS = {}
    end
    GW.GW_CHANGELOGS[#GW.GW_CHANGELOGS + 1] = {version = addonVersion, changes = changeList}
end
GW.addChange = addChange

-- create custom UIFrameFlash animation
local function SetUpFrameFlash(frame, loop)
    frame.flasher = frame:CreateAnimationGroup("Flash")
    frame.flasher.fadein = frame.flasher:CreateAnimation("Alpha", "FadeIn")
    frame.flasher.fadein:SetOrder(1)

    frame.flasher.fadeout = frame.flasher:CreateAnimation("Alpha", "FadeOut")
    frame.flasher.fadeout:SetOrder(2)

    if loop then
        frame.flasher:SetScript("OnFinished", function(self)
            self:Play()
        end)
    end
end

local function StopFlash(frame)
    if frame.flasher and frame.flasher:IsPlaying() then
        frame.flasher:Stop()
    end
end
GW.StopFlash = StopFlash

local function FrameFlash(frame, duration, fadeOutAlpha, fadeInAlpha, loop)
    if not frame.flasher then
        SetUpFrameFlash(frame,loop)
    end

    if not frame.flasher:IsPlaying() then
        frame.flasher.fadein:SetDuration(duration)
        frame.flasher.fadein:SetFromAlpha(fadeOutAlpha or 0)
        frame.flasher.fadein:SetToAlpha(fadeInAlpha or 1)
        frame.flasher.fadeout:SetDuration(duration)
        frame.flasher.fadeout:SetFromAlpha(fadeInAlpha or 1)
        frame.flasher.fadeout:SetToAlpha(fadeOutAlpha or 0)
        frame.flasher:Play()
    end
end
GW.FrameFlash = FrameFlash

local function IsDispellableByMe(debuffType)
    local dispel = GW.DispelClasses[GW.myclass]
    return dispel and dispel[debuffType]
end
GW.IsDispellableByMe = IsDispellableByMe

local function GetScreenQuadrant(frame)
    local x, y = frame:GetCenter()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()

    if not (x and y) then
        return "UNKNOWN"
    end

    local point
    if (x > (screenWidth / 3) and x < (screenWidth / 3) * 2) and y > (screenHeight / 3) * 2 then
        point = "TOP"
    elseif x < (screenWidth / 3) and y > (screenHeight / 3) * 2 then
        point = "TOPLEFT"
    elseif x > (screenWidth / 3) * 2 and y > (screenHeight / 3) * 2 then
        point = "TOPRIGHT"
    elseif (x > (screenWidth / 3) and x < (screenWidth / 3) * 2) and y < (screenHeight / 3) then
        point = "BOTTOM"
    elseif x < (screenWidth / 3) and y < (screenHeight / 3) then
        point = "BOTTOMLEFT"
    elseif x > (screenWidth / 3) * 2 and y < (screenHeight / 3) then
        point = "BOTTOMRIGHT"
    elseif x < (screenWidth / 3) and (y > (screenHeight / 3) and y < (screenHeight / 3) * 2) then
        point = "LEFT"
    elseif x > (screenWidth / 3) * 2 and y < (screenHeight / 3) * 2 and y > (screenHeight / 3) then
        point = "RIGHT"
    else
        point = "CENTER"
    end

    return point
end
GW.GetScreenQuadrant = GetScreenQuadrant

do
    local a, d = "", {"|c[fF][fF]%x%x%x%x%x%x","|r","^%s+","%s+$","|[TA].-|[ta]"}
    local function StripString(s, ignoreTextures)
        for i = 1, #d - (ignoreTextures and 1 or 0) do s = gsub(s, d[i], a) end
        return s
    end
    GW.StripString = StripString
end

local function setItemLevel(button, quality, itemlink)
    button.itemlevel:SetFont(UNIT_NAME_FONT, 12, "THINOUTLINED")
    if quality then
        local r, g, b = C_Item.GetItemQualityColor(quality or 1)
        if quality >= LE_ITEM_QUALITY_COMMON and C_Item.GetItemQualityColor(quality) then
            r, g, b = C_Item.GetItemQualityColor(quality)
            button.itemlevel:SetTextColor(r, g, b, 1)
        end
        local _, _, _, ItemLevel = C_Item.GetItemInfo(itemlink)
        button.itemlevel:SetText(ItemLevel)
        button.itemlevel:SetTextColor(r, g, b, 1)
    else
        local r, g, b = C_Item.GetItemQualityColor(1)
        button.itemlevel:SetText("")
        button.itemlevel:SetTextColor(r, g, b, 1)
    end
end
GW.setItemLevel = setItemLevel

local function ColorGradient(perc, ...)
    if perc >= 1 then
        return select(select("#", ...) - 2, ...)
    elseif perc <= 0 then
        return ...
    end

    local num = select("#", ...) / 3
    local segment, relperc = math.modf(perc * (num - 1))
    local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

    return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end
GW.ColorGradient = ColorGradient

local function StatusBarColorGradient(bar, value, max, backdrop)
	if not (bar and value) then return end

	local current = (not max and value) or (value and max and max ~= 0 and value / max)
	if not current then return end

	local r, g, b = ColorGradient(current, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8,  0)
	bar:SetStatusBarColor(r, g, b)

	if not backdrop then
		backdrop = bar.backdrop
	end

	if backdrop then
		backdrop:SetBackdropColor(r * 0.25, g * 0.25, b * 0.25)
	end
end
GW.StatusBarColorGradient = StatusBarColorGradient

local Fn = function (...) return not GW.Matches(...) end

local function Tmp(...)
    local t = {}
    for i=1, select("#", ...) do
        local v = select(i, ...)
        t[i] = v == nil and NIL or v
    end
    return setmetatable(t, EMPTY)
end

local function Each(...)
    if ... and type(...) == "table" then
        return next, ...
    elseif select("#", ...) == 0 then
        return GW.NoOp
    else
        return Fn, Tmp(...)
    end
end

local function Contains(t, u, deep)
    if t == u then
        return true
    elseif (t == nil) ~= (u == nil) then
        return false
    end

    for i,v in pairs(u) do
        if deep and type(t[i]) == "table" and type(v) == "table" then
            if not Contains(t[i], v, true) then
                return false
            end
        elseif t[i] ~= v then
            return false
        end
    end
    return true
end

local function IEach(...)
    if ... and type(...) == "table" then
        return Fn, ...
    else
        return Each(...)
    end
end

local function Get(t, ...)
    local n, path = select("#", ...), ...

    if n == 1 and type(path) == "string" and path:find("%.") then
        path = Tmp(("."):split((...)))
    elseif type(path) ~= "table" then
        path = Tmp(...)
    end

    for _, k in IEach(path) do
        if k == nil then
            break
        elseif t ~= nil then
            t = t[k]
        end
    end

    return t
end

local function Matches(t, ...)
    if type(...) == "table" then
        return Contains(t, ...)
    else
        for i=1, select("#", ...), 2 do
            local key, val = select(i, ...)
            local v = Get(t, key)
            if v == nil or val ~= nil and v ~= val then
                return false
            end
        end

        return true
    end
end
GW.Matches = Matches

local function Join(del, ...)
    local s = ""
    for _, v in Each(...) do
        if not not (type(v) == "string" and v:trim() ~= "") then
            s = s .. (s == "" and "" or del or " ") .. v
        end
    end
    return s
end
GW.Join = Join

local function IsGroupMember(name)
	if name then
		if UnitInParty(name) then
			return 1
		elseif UnitInRaid(name) then
			return 2
		elseif name == GW.myname then
			return 3
		end
	end

	return false
end
GW.IsGroupMember = IsGroupMember

local function EscapeString(s)
    return gsub(s, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end
GW.EscapeString = EscapeString

local function getContainerItemLinkByNameOrId(itemName, id)
    local itemLink = nil
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemLink(bag, slot)
            if item and (item:find(itemName) or item:find(id)) then
                itemLink = item
                break
            end
        end
    end

    return itemLink
end
GW.getContainerItemLinkByNameOrId = getContainerItemLinkByNameOrId

local function getInventoryItemLinkByNameAndId(name, id)
    for slot = 1, 17 do
        local itemLink = GetInventoryItemLink("player", slot)
        if itemLink and itemLink:find(name) and itemLink:find(id) then
            return itemLink
        end
    end

    return nil
end
GW.getInventoryItemLinkByNameAndId = getInventoryItemLinkByNameAndId

-- tooltip function
local function CompatibleTooltip(self)
	if self.GetTooltipData then return end

	local info = { name = self:GetName(), lines = {} }
	info.leftTextName = info.name .. 'TextLeft'
	info.rightTextName = info.name .. 'TextRight'

	self.GetTooltipData = function()
		wipe(info.lines)

		for i = 1, self:NumLines() do
			local left = _G[info.leftTextName..i]
			local leftText = left and left:GetText() or nil

			local right = _G[info.rightTextName..i]
			local rightText = right and right:GetText() or nil

			tinsert(info.lines, i, { lineIndex = i, leftText = leftText, rightText = rightText })
		end

		return info
	end
end
CompatibleTooltip(GW.ScanTooltip)
CompatibleTooltip(GameTooltip)