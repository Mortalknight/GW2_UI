local _, GW = ...
local CLASS_COLORS_RAIDFRAME = GW.CLASS_COLORS_RAIDFRAME

local STRIP_TEX = "Texture"
local STRIP_FONT = "FontString"

local StripTexturesBlizzFrames = {
    "Inset",
    "inset",
    "InsetFrame",
    "LeftInset",
    "RightInset",
    "NineSlice",
    "BG",
    "border",
    "Border",
    "BorderFrame",
    "bottomInset",
    "BottomInset",
    "bgLeft",
    "bgRight",
    "FilligreeOverlay",
    "PortraitOverlay",
    "ArtOverlayFrame",
    "Portrait",
    "portrait",
    "ScrollFrameBorder",
}

GW.NoOp = function() end

local function StripRegion(which, object, hide, alpha)
    if hide then
        object:Hide()
    elseif alpha then
        object:SetAlpha(0)
    elseif which == STRIP_TEX then
        object:SetTexture()
    elseif which == STRIP_FONT then
        object:SetText("")
    end
end

local function StripType(which, object, hide, alpha)
    if object:IsObjectType(which) then
        StripRegion(which, object, hide, alpha)
    else
        if which == STRIP_TEX then
            local FrameName = object.GetName and object:GetName()
            for _, Blizzard in pairs(StripTexturesBlizzFrames) do
                local BlizzFrame = object[Blizzard] or (FrameName and _G[FrameName..Blizzard])
                if BlizzFrame and BlizzFrame.StripTextures then
                    StripTextures(BlizzFrame, hide, alpha)
                end
            end
        end

        if object.GetNumRegions then
            for i = 1, object:GetNumRegions() do
                local region = select(i, object:GetRegions())
                if region and region.IsObjectType and region:IsObjectType(which) then
                    StripRegion(which, region, hide, alpha)
                end
            end
        end
    end
end

local function StripTextures(object, hide, alpha)
    StripType(STRIP_TEX, object, hide, alpha)
end
GW.StripTextures = StripTextures

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
    local gold = floor(value / 10000)
    local silver = floor((value / 100) % 100)
    local copper = floor(value % 100)

    if gold > 0 then
        str = format("%s%d|r|TInterface/MoneyFrame/UI-GoldIcon:12:12|t%s", goldcolor, GW.CommaValue(gold), (silver > 0 or copper > 0) and " " or "")
    end
    if silver > 0 then
        str = format("%s%s%d|r|TInterface/MoneyFrame/UI-SilverIcon:12:12|t%s", str, silvercolor, silver, copper > 0 and " " or "")
    end
    if copper > 0 or value == 0 then
        str = format("%s%s%d|r|TInterface/MoneyFrame/UI-CopperIcon:12:12|t", str, coppercolor, copper)
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
    local type, _, playerdbID, _, _, cid, creationbits = strsplit("-", guid or "")
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
    if not str or IsIn(GetLocale(), "koKR", "zhCN", "zhTW") then
        return str
    else
        return (i and str:sub(1, i - 1) or "") .. str:sub(i or 1, j):upper() .. (j and str:sub(j + 1) or "")
    end
end
GW.StrUpper = StrUpper
local function StrLower(str, i, j)
    if not str or IsIn(GetLocale(), "koKR", "zhCN", "zhTW") then
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

--@debug@
local function AddForProfiling(unit, name, ...)
    if not Profiler then
        return
    end
    local gName = "GW_" .. unit
    if not _G[gName] then
        _G[gName] = {}
    end

    _G[gName][name] = ...
end

local function inDebug(tab, ...)
    local debug_tab = _G["ChatFrame" .. tab]
    if not debug_tab then
        return
    end
    local msg = ""
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        msg = msg .. tostring(arg) .. " "
    end
    debug_tab:AddMessage(date("%H:%M:%S") .. " " .. msg)
end

local function Debug(...)
    if GW.dbgTab then
        inDebug(GW.dbgTab, ...)
    end
end

local function Trace()
    print("------------------------- Trace -------------------------")
    for i,v in ipairs({("\n"):split(debugstack(2))}) do
        if v ~= "" then
            print(i .. ": " .. v)
        end
    end
    print("---------------------------------------------------------")
end

--@end-debug@
--[===[@non-debug@
local function Debug()
    return
end
local function AddForProfiling()
    return
end
local function Trace()
    return
end
--@end-non-debug@]===]
GW.Debug = Debug
GW.Trace = Trace
GW.AddForProfiling = AddForProfiling

local function vernotes(ver, notes)
    if not GW.GW_CHANGELOGS then
        GW.GW_CHANGELOGS = ""
    end
    GW.GW_CHANGELOGS = GW.GW_CHANGELOGS .. "\n" .. ver .. "\n\n" .. notes .. "\n\n"
end
GW.vernotes = vernotes

-- create custom UIFrameFlash animation
local function FrameFlash(frame, fadeInTime, fadeOutTime, showWhenDone, flashInHoldTime, flashOutHoldTime)
    local flasher

    if not frame.flasher then
        flasher = frame:CreateAnimationGroup()
    else
        flasher = frame.flasher
    end

    local fade1 = flasher:CreateAnimation("Alpha")
    local fade2 = flasher:CreateAnimation("Alpha")
    fade1:SetDuration(fadeInTime)
    fade1:SetToAlpha(1)
    fade1:SetOrder(1)
    fade1:SetEndDelay(flashInHoldTime)
    
    fade2:SetDuration(fadeOutTime)
    fade2:SetToAlpha(0)
    fade2:SetOrder(2)
    fade2:SetEndDelay(flashOutHoldTime)

    if showWhenDone then
        flasher:SetScript("OnFinished", function(self)
            frame:SetAlpha(1)
            self:SetScript("OnFinished", nil)
        end)
    end

    frame.flasher = flasher

    frame.flasher:Play()
end
GW.FrameFlash = FrameFlash

local function setItemLevel(button, quality, itemlink)
    button.itemlevel:SetFont(UNIT_NAME_FONT, 12, "THINOUTLINED")
    if quality then
        if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
            button.itemlevel:SetTextColor(
                BAG_ITEM_QUALITY_COLORS[quality].r,
                BAG_ITEM_QUALITY_COLORS[quality].g,
                BAG_ITEM_QUALITY_COLORS[quality].b,
                1
            )
        end
        local slotInfo = GW.GetGearSlotInfo("player", button:GetID(), itemlink)
        button.itemlevel:SetText(slotInfo.iLvl)
    else
        button.itemlevel:SetText("")
    end
end
GW.setItemLevel = setItemLevel
