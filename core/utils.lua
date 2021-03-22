local _, GW = ...
local CLASS_COLORS_RAIDFRAME = GW.CLASS_COLORS_RAIDFRAME

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

local function GWGetClassColor(class, useClassColor, forNameString)
    if not class or not useClassColor then
        return RAID_CLASS_COLORS.PRIEST
    end

    local useBlizzardClassColor = GW.GetSetting("BLIZZARDCLASSCOLOR_ENABLED")
    local color
    local colorForNameString

    if useBlizzardClassColor then
        color = RAID_CLASS_COLORS[class]
    else
        color = CLASS_COLORS_RAIDFRAME[class]
    end

    if type(color) ~= "table" then return end

    if not color.colorStr then
        color.colorStr = GW.RGBToHex(color.r, color.g, color.b, "ff")
    elseif strlen(color.colorStr) == 6 then
        color.colorStr = "ff" .. color.colorStr
    end

    if forNameString and not useBlizzardClassColor then
        colorForNameString = {r = color.r + 0.3, g = color.g + 0.3, b = color.b + 0.3, a = color.a, colorStr = GW.RGBToHex(color.r + 0.3, color.g + 0.3, color.b + 0.3, "ff")}
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
    local englishFaction, localizedFaction = UnitFactionGroup(unit)

    -- this might be a rated BG or wargame and if so the player's faction might be altered
    -- should also apply if `player` is a mercenary.
    if unit == "player" then
        if C_PvP.IsRatedBattleground() or IsWargame() then
            englishFaction = PLAYER_FACTION_GROUP[GetBattlefieldArenaFaction()]
            localizedFaction = (englishFaction == "Alliance" and FACTION_ALLIANCE) or FACTION_HORDE
        elseif UnitIsMercenary(unit) then
            if englishFaction == "Alliance" then
                englishFaction, localizedFaction = "Horde", FACTION_HORDE
            else
                englishFaction, localizedFaction = "Alliance", FACTION_ALLIANCE
            end
        end
    end

    return englishFaction, localizedFaction
end
GW.GetUnitBattlefieldFaction = GetUnitBattlefieldFaction

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
    local type, _, playerdbID, _, _, cid = strsplit("-", guid or "")
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
    local function splitString(str, delim, returnTable)
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

        if returnTable then
            return splitTable
        else
            return unpack(splitTable)
        end
    end
    GW.splitString = splitString
end

local function FindInList(list, str, i, del)
    local dl = "([^%s" .. (del or ",;") .. ")]?)"
    local st = dl .. "(%s*)(" .. str .. ")(%s*)" .. dl
    i = i or 1
    while i do
        local s, e, a, b, m, c, d = list:find(st, i)
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
    msg_tab:AddMessage("|cffC0C0F0GW2 UI|r: " .. msg)
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
        RegisterStateDriver(f, "petoverride", "[overridebar] hide; [vehicleui] hide; [petbattle] hide; show")
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
        PetBattleFrame:HookScript("OnShow", f_OnShow)
        PetBattleFrame:HookScript("OnHide", f_OnHide)
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

local function getContainerItemLinkByName(itemName)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local item = GetContainerItemLink(bag, slot)
            if item and item:find(itemName) then
                return item
            end
        end
    end
end
GW.getContainerItemLinkByName = getContainerItemLinkByName

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

local function setItemLevel(button, quality, itemlink, slot)
    button.itemlevel:SetFont(UNIT_NAME_FONT, 12, "THINOUTLINED")
    if quality then
        local r, g, b = GetItemQualityColor(quality or 1)
        if quality >= Enum.ItemQuality.Common and GetItemQualityColor(quality) then
            r, g, b = GetItemQualityColor(quality)
            button.itemlevel:SetTextColor(r, g, b, 1)
        end
        local slotInfo = GW.GetGearSlotInfo("player", slot, itemlink)
        button.itemlevel:SetText(slotInfo.iLvl)
        button.itemlevel:SetTextColor(r, g, b, 1)
    else
        local r, g, b = GetItemQualityColor(1)
        button.itemlevel:SetText("")
        button.itemlevel:SetTextColor(r, g, b, 1)
    end
end
GW.setItemLevel = setItemLevel

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
    local a1, a2, a3, a4, a5 = "", "|c[fF][fF]%x%x%x%x%x%x", "|r", "|[TA].-|[ta]", "^%s*"
    local function StripString(s)
        return gsub(gsub(gsub(gsub(s, a2, a1), a3, a1), a4, a1) , a5, a1)
    end
    GW.StripString = StripString
end

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