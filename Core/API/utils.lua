---@class GW2
local GW = select(2, ...)

local maxUpdatesPerCircle = 5
local EMPTY = {}
local NIL = {}
GW.CombatQueue = {
    queue = {},
    head = 1,
    tail = 0,
    byKey = {}
}

local function SetDeadIcon(self)
    local tex = GW.CLASS_ICONS.dead
    self:SetTexCoord(tex.l, tex.r, tex.t, tex.b)
end
GW.SetDeadIcon = SetDeadIcon


local secureAttributeHandler
local function SetSecureAttribute(frame, name, value)
    if InCombatLockdown() then return false end -- SetFrameRef is an attribute write itself

    local valueType = type(value)
    local literal
    if valueType == "string" then
        literal = format("%q", value)
    elseif valueType == "number" or valueType == "boolean" then
        literal = tostring(value)
    elseif valueType == "nil" then
        literal = "nil"
    else
        return false -- tables/functions cannot be expressed as a snippet literal
    end

    if not secureAttributeHandler then
        secureAttributeHandler = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")
    end

    secureAttributeHandler:SetFrameRef("gwTarget", frame)
    SecureHandlerExecute(secureAttributeHandler, format([[self:GetFrameRef("gwTarget"):SetAttribute(%q, %s)]], name, literal))
    return true
end
GW.SetSecureAttribute = SetSecureAttribute

-- Show/Hide of a frame that holds blizzard action buttons: their OnShow runs Update(), which must not run tainted
local function SetSecureShown(frame, shown)
    if InCombatLockdown() then
        frame:SetShown(shown) -- the restricted environment is closed in combat, the plain call keeps the old behavior
        return false
    end

    if not secureAttributeHandler then
        secureAttributeHandler = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")
    end

    secureAttributeHandler:SetFrameRef("gwTarget", frame)
    SecureHandlerExecute(secureAttributeHandler, format([[self:GetFrameRef("gwTarget"):%s()]], shown and "Show" or "Hide"))
    return true
end
GW.SetSecureShown = SetSecureShown

-- 12.1: declares the frame's roleset so the UI mode system gates its visibility
-- like Blizzard's own frames ("unitFrames", "arenaFrames", ...). No-op on clients
-- without the API.
local function SetFrameRoleset(frame, roleset)
    if frame.SetRolesets then
        frame:SetRolesets(roleset or "unitFrames")
    end
end
GW.SetFrameRoleset = SetFrameRoleset

local function SetClassIcon(self, class)
    if GW.IsSecretValue(class) or class == nil then
        class = 0
    end
    local tex = GW.CLASS_ICONS[class]

    self:SetTexCoord(tex.l, tex.r, tex.t, tex.b)
end
GW.SetClassIcon = SetClassIcon

--[[
    Basic helper function for spritemaps
    mapExample = {
    width = 100,
    height = 10,
    colums = 5,
    rows = 3
}
]]--
local function getSprite(map, x, y)
    local pw = 1 / map.colums
    local ph = 1 / map.rows

    local left = pw * (x - 1)
    local right = pw * x

    local top = ph * (y - 1)
    local bottom = ph * y

    return left, right, top, bottom
end
GW.getSprite = getSprite

local function getSpriteByIndex(map, index)
    if not map then
        return 0, 0, 0, 0
    end

    local w, h = map.width, map.height
    local cols, rows = map.colums, map.rows

    local tileWidth = w / cols
    local tileHeight = h / rows

    local col = index % cols
    local row = math.floor(index / cols)

    local left = tileWidth * col
    local top = tileHeight * row
    local right = left + tileWidth
    local bottom = top + tileHeight

    return left / w, right / w, top / h, bottom / h
end
GW.getSpriteByIndex = getSpriteByIndex

local function MapTable(T, fn, withKey, fnKeyValue)
    local t = {}
    for k,v in pairs(T) do
        if withKey then
            t[k] = fn(v, k)
        else
            t[k] = fn(v)
        end
        t[k] = fnKeyValue ~= nil and t[k][fnKeyValue] or t[k]
    end
    return t
end
GW.MapTable = MapTable

local function StringWithRGB(string, color)
    if not color then
        return string
    end
    return format("|cFF%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, string)
end
GW.StringWithRGB = StringWithRGB

function GW.CombatQueue:Initialize()
    C_Timer.NewTicker(0.1, function()
        if InCombatLockdown() then
            return
        end

        local count = 0
        while count < maxUpdatesPerCircle do
            local entry = self.queue[self.head]
            if not entry then
                if self.head > self.tail then
                    self.head = 1
                    self.tail = 0
                end
                break
            end

            self.queue[self.head] = nil
            self.head = self.head + 1

            if entry.key and self.byKey[entry.key] == entry then
                self.byKey[entry.key] = nil
            end

            if entry.obj then
                entry.func(unpack(entry.obj))
            else
                entry.func()
            end

            count = count + 1
            if InCombatLockdown() then
                break
            end
        end
    end)
end

function GW.CombatQueue:Queue(key, func, obj)
    if key ~= nil then
        local existing = self.byKey[key]
        if existing then
            existing.func = func
            existing.obj = obj
            return
        end
    end

    local entry = {key = key, func = func, obj = obj}
    self.tail = self.tail + 1
    self.queue[self.tail] = entry

    if key ~= nil then
        self.byKey[key] = entry
    end
end

local function StoreGameMenuButton()
    GameMenuFrame.GwMenuButtons = {}
    hooksecurefunc(GameMenuFrame, "Layout", function()
        for button in GameMenuFrame.buttonPool:EnumerateActive() do
            local text = button:GetText()
            GameMenuFrame.GwMenuButtons[text] = button
        end
    end)
end
GW.StoreGameMenuButton = StoreGameMenuButton

-- Our layout apply taints what the game menu reads while wiring its buttons, so logout and exit get secure
-- /logout and /quit overlays. Those stay out of the game menu and leave its buttons before a fight: a
-- protected frame inside or anchored to it would lock the menu layout in combat. In combat the two buttons
-- are blizzards own again.
local function SecureGameMenuLogoutButtons()
    local overlays = {}

    local function getOverlay(key, macroText, clickSound)
        if overlays[key] then
            return overlays[key]
        end

        local overlay = CreateFrame("Button", "GwGameMenuSecure" .. key .. "Button", UIParent, "SecureActionButtonTemplate")
        overlay:SetAttribute("type", "macro")
        overlay:SetAttribute("macrotext", macroText)
        overlay:RegisterForClicks("AnyUp", "AnyDown") -- the secure handler picks the one matching the ActionButtonUseKeyDown cvar
        overlay.clickSound = clickSound

        overlay:SetScript("OnEnter", function(self)
            if self.menuButton then
                self.menuButton:LockHighlight()
                local onEnter = self.menuButton:GetScript("OnEnter")
                if onEnter then onEnter(self.menuButton) end
            end
        end)
        overlay:SetScript("OnLeave", function(self)
            if self.menuButton then
                self.menuButton:UnlockHighlight()
                local onLeave = self.menuButton:GetScript("OnLeave")
                if onLeave then onLeave(self.menuButton) end
            end
        end)
        overlay:SetScript("PostClick", function(self, _, down)
            if down then return end
            PlaySound(self.clickSound)
            HideUIPanel(GameMenuFrame)
        end)
        overlay:Hide()

        overlays[key] = overlay
        return overlay
    end

    local function ReleaseOverlays()
        for _, overlay in pairs(overlays) do
            overlay:Hide()
            overlay:ClearAllPoints()
            overlay.menuButton = nil
        end
    end

    local function PlaceOverlays(menu)
        if not menu.buttonPool or InCombatLockdown() then
            return
        end

        local logoutText = menu.GetLogoutText and menu:GetLogoutText() or LOGOUT
        for button in menu.buttonPool:EnumerateActive() do
            local text = button:GetText()
            local overlay
            if text == logoutText then
                overlay = getOverlay("Logout", "/logout", SOUNDKIT.IG_MAINMENU_LOGOUT)
            elseif text == EXIT_GAME then
                overlay = getOverlay("Quit", "/quit", SOUNDKIT.IG_MAINMENU_QUIT)
            end

            if overlay then
                overlay.menuButton = button
                overlay:ClearAllPoints()
                overlay:SetAllPoints(button)
                overlay:SetFrameStrata(menu:GetFrameStrata())
                overlay:SetFrameLevel(button:GetFrameLevel() + 1)
                overlay:SetShown(button:IsEnabled())
            end
        end
    end

    hooksecurefunc(GameMenuFrame, "InitButtons", PlaceOverlays)
    GameMenuFrame:HookScript("OnHide", function()
        if not InCombatLockdown() then
            ReleaseOverlays()
        end
    end)

    -- the regen disabled event still allows it, the overlays leave the menu before the lockdown
    local combatWatcher = CreateFrame("Frame")
    combatWatcher:RegisterEvent("PLAYER_REGEN_DISABLED")
    combatWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
    combatWatcher:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_DISABLED" then
            ReleaseOverlays()
        elseif GameMenuFrame:IsShown() then
            PlaceOverlays(GameMenuFrame)
        end
    end)
end
GW.SecureGameMenuLogoutButtons = SecureGameMenuLogoutButtons

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

local function HookActionBarStateChanges()
    if GW.ActionBarStateChangesHooked then
        return
    end

    hooksecurefunc("ValidateActionBarTransition", function()
        EventRegistry:TriggerEvent("GW2_UI.ActionBarStateChanged")
    end)
    GW.ActionBarStateChangesHooked = true
end
GW.HookActionBarStateChanges = HookActionBarStateChanges

local function Clamp(v, min, max)
    if v < min then return min end
    if v > max then return max end
    return v
end
GW.Clamp = Clamp

local function GetScaledCursorDistance(left, top, scale)
    local x, y = GetCursorPosition()
    x = x / scale - left
    y = top - y / scale
    return sqrt(x * x + y * y)
end
GW.GetScaledCursorDistance = GetScaledCursorDistance

-- the units of the chosen prefix style (biggest first) and the decimals shown with them
local shortUnits = {}
local shortFormat = "%.1f"
GW.ShortValueAbbreviationOptions = nil

local RETAIL_SHORT_DECIMAL_MAX = 3

local function BuildRetailShortValueOptions()
    if not (GW.isModern and CreateAbbreviateConfig) then
        GW.ShortValueAbbreviationOptions = nil
        return
    end

    local decimal = GW.settings.unitframes.shortValueDecimals
    decimal = min(decimal, RETAIL_SHORT_DECIMAL_MAX)

    local fractionDivisor = 10 ^ decimal
    local breakpointData = {}

    for i, unit in ipairs(shortUnits) do
        local breakpoint, abbreviation = unit[1], unit[2]

        breakpointData[i] = {
            breakpoint = breakpoint,
            abbreviation = abbreviation,
            significandDivisor = breakpoint / fractionDivisor,
            fractionDivisor = fractionDivisor,
            abbreviationIsGlobal = false
        }
    end

    GW.ShortValueAbbreviationOptions = {config = CreateAbbreviateConfig(breakpointData)}
end

local function BuildPrefixValues()
    local settings = GW.settings.unitframes
    shortUnits = GW.ShortPrefixStyles[settings.shortValuePrefixStyle] or GW.ShortPrefixStyles.ENGLISH
    shortFormat = "%." .. (settings.shortValueDecimals or 1) .. "f"
    BuildRetailShortValueOptions()
end
GW.BuildPrefixValues = BuildPrefixValues

local function ShortValue(value)
    -- retail values can be secret, only Blizzard's formatter may touch them
    if GW.isModern then
        return AbbreviateNumbers(value, GW.ShortValueAbbreviationOptions)
    end

    local size = abs(value)
    for _, unit in ipairs(shortUnits) do
        if size >= unit[1] then
            return GW.GetLocalizedNumber(format(shortFormat, value / unit[1])) .. unit[2]
        end
    end
    return GW.GetLocalizedNumber(format("%.0f", value))
end
GW.ShortValue = ShortValue

local function SetPointsRestricted(frame)
    if frame and not pcall(frame.GetPoint, frame) then
        return true
    end
end
GW.SetPointsRestricted = SetPointsRestricted

-- hideEmptyUnits drops the zero silver and copper, like blizzards price tags
local function FormatMoneyForChat(amount, hideEmptyUnits)
    local str, coppercolor, silvercolor, goldcolor = "", "|cffb16022", "|cffaaaaaa", "|cffddbc44"

    local value = abs(amount)
    local gold = math.floor(value / (COPPER_PER_SILVER * SILVER_PER_GOLD))
    local silver = math.floor((value - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
    local copper = mod(value, COPPER_PER_SILVER)
    local showSilver = silver > 0 or (gold > 0 and not hideEmptyUnits)
    local showCopper = copper > 0 or not hideEmptyUnits or value == 0

    if gold > 0 then
        str = format("%s%s |r|TInterface/AddOns/GW2_UI/textures/icons/coins.png:12:12:0:0:64:32:22:42:1:20|t%s", goldcolor, GW.GetLocalizedNumber(gold), (showSilver or showCopper) and " " or "")
    end
    if showSilver then
        str = format("%s%s%d |r|TInterface/AddOns/GW2_UI/textures/icons/coins.png:12:12:0:0:64:32:43:64:1:20|t%s", str, silvercolor, silver, (copper > 0 or gold > 0) and showCopper and " " or "")
    end
    if showCopper then
        str = format("%s%s%d |r|TInterface/AddOns/GW2_UI/textures/icons/coins.png:12:12:0:0:64:32:0:21:1:20|t", str, coppercolor, copper)
    end

    return str
end
GW.FormatMoneyForChat = FormatMoneyForChat

local function GetDefaultClassColor(class)
    local color
    if GW.settings.general.blizzardClassColors then
        color = RAID_CLASS_COLORS[class]
    else
        color = GW.privateDefaults.profile.Gw2ClassColor[class]
    end
    if type(color) ~= "table" then return end

    return color
end
GW.GetDefaultClassColor = GetDefaultClassColor

-- Returns a ColorMixin, never a color string: both sources hold mixins, so callers use
-- :GetRGB() for widgets and :WrapTextInColorCode() for text. Nothing is written back into the
-- color tables, which is why the class color settings no longer have to invalidate cached fields
function GW.GWGetClassColor(class, useClassColor, alwaysUseBlizzardColors)
    if GW.IsSecretValue(class) then
        -- a secret class cannot be used as a table key, so the engine has to resolve the color
        local ok, secretColor = pcall(C_ClassColor.GetClassColor, class)
        return (ok and secretColor) or RAID_CLASS_COLORS.PRIEST
    end

    local color
    if class and useClassColor then
        if alwaysUseBlizzardColors or GW.settings.general.blizzardClassColors then
            color = RAID_CLASS_COLORS[class]
        else
            color = GW.Colors.ClassColors[class]
        end
    end

    return color or RAID_CLASS_COLORS.PRIEST
end


-- channels outside 0..1 count as full
local function ToHexByte(channel)
    return format("%02x", (channel >= 0 and channel <= 1 and channel or 1) * 255)
end

-- "|cffrrggbb" unless another header is given
local function RGBToHex(r, g, b, header, ending)
    return (header or "|cff") .. ToHexByte(r) .. ToHexByte(g) .. ToHexByte(b) .. (ending or "")
end
GW.RGBToHex = RGBToHex

local function HexToRGB(hex)
    local rhex, ghex, bhex = strsub(hex, 1, 2), strsub(hex, 3, 4), strsub(hex, 5, 6)
    return tonumber(rhex, 16) / 255, tonumber(ghex, 16) / 255, tonumber(bhex, 16) / 255
end
GW.HexToRGB = HexToRGB


-- the side a unit fights for: rated battlegrounds, wargames and mercenary mode can put the player on the other one
function GW.GetUnitBattlefieldFaction(unit)
    local faction, localizedFaction = UnitFactionGroup(unit)
    if unit ~= "player" or not GW.Retail then
        return faction, localizedFaction
    end
    if C_PvP.IsRatedBattleground() or IsWargame() then
        faction = PLAYER_FACTION_GROUP[GetBattlefieldArenaFaction()]
    elseif UnitIsMercenary(unit) then
        faction = faction == "Alliance" and "Horde" or "Alliance"
    else
        return faction, localizedFaction
    end
    return faction, faction == "Alliance" and FACTION_ALLIANCE or FACTION_HORDE
end

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
    if type(number) ~= "number" then
        number = tonumber(number)
    end

    if decimals and decimals > 0 then
        local mult = 10 ^ decimals
        return floor(number * mult + 0.5) / mult
    end

    return floor(number + 0.5)
end
GW.RoundDec = RoundDec

local function GetLocalizedNumber(number, numberDecimal)
    local DECIMAL_DELIMITER = GW.settings.general.numberFormat == "POINT" and "." or ","
    local LARGE_NUMBER_DELIMITER = GW.settings.general.numberFormat == "POINT" and "," or "."
    local formattedNumber, integerPart, decimalPart

    -- Wandelt die Zahl in einen String um
    local zahlStr = tostring(number)

    -- Bestimme die Position des Dezimaltrennzeichens
    local decimalPos = string.find(zahlStr, "%.")

    if decimalPos then
        -- Teile die Zahl in Ganzzahl und Dezimalteil
        integerPart = string.sub(zahlStr, 1, decimalPos - 1)
        decimalPart = string.sub(zahlStr, decimalPos + 1)
    else
        -- Falls kein Dezimaltrennzeichen vorhanden ist, setze den Dezimalteil auf leer
        integerPart = zahlStr
        decimalPart = ""
    end

    -- Tausendertrennzeichen in der Ganzzahl hinzufügen
    local formattedInteger = {}
    local len = #integerPart

    -- Von rechts nach links durch die Ganzzahl laufen und in eine Tabelle speichern
    local count = 0  -- Zähler für Gruppen von 3 Ziffern
    for i = len, 1, -1 do
        local currentChar = integerPart:sub(i, i)

        -- Tausendertrennzeichen hinzufügen, wenn nötig
        if count > 0 and count % 3 == 0 then
            table.insert(formattedInteger, 1, LARGE_NUMBER_DELIMITER)
        end

        -- Füge das aktuelle Zeichen zur formatierten Ganzzahl hinzu
        table.insert(formattedInteger, 1, currentChar)
        count = count + 1
    end

    -- Wenn Dezimalteil vorhanden ist, füge ihn hinzu
    if numberDecimal then
        decimalPart = string.sub(decimalPart, 1, numberDecimal)
    end
    if #decimalPart > 0 then
        formattedNumber = table.concat(formattedInteger) .. DECIMAL_DELIMITER .. decimalPart
    else
        formattedNumber = table.concat(formattedInteger)
    end

    return formattedNumber
end
GW.GetLocalizedNumber = GetLocalizedNumber
-- /dump GetLocalizedNumber2(5600000.345, 3)

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
    t = max(0,min(1,t))
    if v0 == nil then
        v0 = 0
    end
    return (1 - t) * v0 + t * v1;
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
    -- the parts are reused between calls, callers asking for the table must not keep it
    local parts = {}
    local function splitString(str, delim, returnTable)
        wipe(parts)
        local start = 1
        repeat
            local first, last = strfind(str, delim, start, true)
            parts[#parts + 1] = strsub(str, start, first and first - 1 or -1)
            start = last and last + 1
        until not first

        if returnTable then
            return parts
        end
        return unpack(parts)
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

local function StartsWith(str, str2)
    return type(str) == "string" and str:sub(1, str2:len()) == str2
end
GW.StartsWith = StartsWith

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

-- forever hands out the surname where the other clients hand out the realm: "First Last" there, the name elsewhere
local function GetUnitDisplayName(unit)
    local name, realm = UnitName(unit)
    if GW.Forever and GW.NotSecretValue(realm) and realm and realm ~= "" then
        return name .. " " .. realm
    end
    return name
end
GW.GetUnitDisplayName = GetUnitDisplayName

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

local function secureHideDurinPetAndMountedgMounted(f)
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

    RegisterStateDriver(f, "petoverride", "[bonusbar:5] hide; [overridebar] hide; [vehicleui] hide; [petbattle] hide; [possessbar,@vehicle,exists] hide; show")
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
    if stateType ~= "override" and PetBattleFrame then
        PetBattleFrame:HookScript("OnShow", f_OnShow)
        PetBattleFrame:HookScript("OnHide", f_OnHide)
    end

    return true
end

local function MixinHideDuringPet(f)
    if not f then return end
    -- TODO: figure out how to do real mixins
    if f:IsProtected() then
        return securePetAndOverride(f, "petbattle")
    else
        return normPetAndOverride(f, "petbattle")
    end
end
GW.MixinHideDuringPet = MixinHideDuringPet

local function MixinHideDuringOverride(f)
    if not f then return end
    if f:IsProtected() then
        return securePetAndOverride(f, "override")
    else
        return normPetAndOverride(f, "override")
    end
end
GW.MixinHideDuringOverride = MixinHideDuringOverride

-- forever's gamepad interface replaces the action bars and the micro menu; switching it reloads the ui
function GW.IsGamepadInterface()
    return InputUtil and InputUtil.IsGamepadUIEnabled and InputUtil.IsGamepadUIEnabled()
end

local function MixinHideDuringPetAndOverride(f)
    if not f then return end
    if f:IsProtected() then
        return securePetAndOverride(f)
    else
        return normPetAndOverride(f)
    end
end
GW.MixinHideDuringPetAndOverride = MixinHideDuringPetAndOverride
local function MixinHideDuringPetAndMountedOverride(f)
    if not f then return end
    if f:IsProtected() then
        return secureHideDurinPetAndMountedgMounted(f)
    else
        return normPetAndOverride(f)
    end
end
GW.MixinHideDuringPetAndMountedOverride = MixinHideDuringPetAndMountedOverride

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
        SetUpFrameFlash(frame, loop)
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

local function LoadItemAsync(itemInput, callback)
    if type(itemInput) == "string" and itemInput:find("^|c.+|Hitem:") then
        callback(itemInput)
        return
    end

    local _, link = C_Item.GetItemInfo(itemInput)
    if link then
        callback(link)
        return
    end

    local itemID = tonumber(itemInput)
    if not itemID then return end

    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        local _, resolvedLink = C_Item.GetItemInfo(itemID)
        if resolvedLink then
            callback(resolvedLink)
        end
    end)
end

local function IsItemEligibleForItemLevelDisplay(itemInput)
    local classID = select(6, C_Item.GetItemInfoInstant(itemInput))
    return
        -- Regular equipment
        classID == Enum.ItemClass.Armor or classID == Enum.ItemClass.Weapon
        -- Profession equipment (retail only)
        or classID == Enum.ItemClass.Profession
        -- Legion Artifact relics (retail only)
        or (classID == Enum.ItemClass.Gem and IsArtifactRelicItem and IsArtifactRelicItem(itemInput))
end
GW.IsItemEligibleForItemLevelDisplay = IsItemEligibleForItemLevelDisplay

-- minItemLevel hides the number below that value, the bags offer it as a setting
local function SetItemLevel(button, quality, itemInput, slot, minItemLevel)
    if not itemInput or itemInput == "" then
        button.itemlevel:SetText("")
        button.__gwLastItemLink = nil
        return
    end

    if button.__gwLastItemLink == itemInput and button.__gwLastMinItemLevel == minItemLevel then return end

    local function applyItemLevel(ilvl, color, usedLink)
        if not ilvl or ilvl <= 0 or (minItemLevel and ilvl < minItemLevel) then
            button.itemlevel:SetText("")
            button.__gwLastItemLink = nil
            return
        end

        button.itemlevel:SetText(ilvl)
        if color then
            button.itemlevel:SetTextColor(color.r, color.g, color.b, 1)
        end

        button.__gwLastItemLink = usedLink
        button.__gwLastMinItemLevel = minItemLevel
    end

    LoadItemAsync(itemInput, function(itemLink)
        local color = GW.GetQualityColor(quality or 0)
        local item = Item:CreateFromItemLink(itemLink)

        item:ContinueOnItemLoad(function()
            -- our own bag buttons carry the id as gwBagID, foreign buttons still as bagID
            local buttonBagID = button.gwBagID or button.bagID
            if buttonBagID and button:GetID() or button.itemLocation then
                local itemLoc = button.itemLocation or ItemLocation:CreateFromBagAndSlot(buttonBagID, button:GetID())
                if itemLoc and itemLoc:IsValid() then
                    local ilvl = C_Item.GetCurrentItemLevel(itemLoc)
                    if ilvl and ilvl > 0 then
                        applyItemLevel(ilvl, color, itemLink)
                        return
                    end
                end
            end
            -- Fallback for items without location
            local ilvl = C_Item.GetDetailedItemLevelInfo(itemLink)
            if ilvl and ilvl > 0 then
                applyItemLevel(ilvl, color, itemLink)
                return
            end

            -- Fallback: Tooltipscan
            local slotInfo = GW.GetGearSlotInfo("player", slot, itemLink, false)
            if slotInfo and slotInfo.iLvl then
                applyItemLevel(slotInfo.iLvl, color, itemLink)
            else
                button.itemlevel:SetText("")
                button.__gwLastItemLink = nil
            end
        end)
    end)
end
GW.SetItemLevel = SetItemLevel

-- Shared read-only color objects/caches: the Retail ColorManager path already returns shared
-- objects, so callers treat these as read-only. This avoids allocating a fresh table on every
-- call (these run in bag/inventory refresh loops over many slots).
local BLACK_QUALITY_COLOR = {r = 0, g = 0, b = 0}
local qualityColorFallbackCache = {}

local function GetQualityColor(quality)
    if ColorManager then
        if quality == -1 then
            return BLACK_QUALITY_COLOR
        end
        return ColorManager.GetColorDataForItemQuality(quality)
    else
        local cached = qualityColorFallbackCache[quality]
        if not cached then
            local r, g, b = C_Item.GetItemQualityColor(quality)
            cached = {r = r, g = g, b = b}
            if quality ~= nil then
                qualityColorFallbackCache[quality] = cached
            end
        end
        return cached
    end
end
GW.GetQualityColor = GetQualityColor

function GW.GetHonorBadge(honorLevel, size)
    local info = C_PvP and C_PvP.GetHonorRewardInfo and C_PvP.GetHonorRewardInfo(honorLevel)
    return info and info.badgeFileDataID and ("|T" .. info.badgeFileDataID .. ":" .. (size or 16) .. ":" .. (size or 16) .. "|t")
end

local nextBadgeLevels = {}
function GW.GetNextHonorBadgeLevel(honorLevel)
    if nextBadgeLevels[honorLevel] == nil then
        local current = GW.GetHonorBadge(honorLevel)
        nextBadgeLevels[honorLevel] = false
        for level = honorLevel + 1, honorLevel + 100 do
            local badge = GW.GetHonorBadge(level)
            if badge and badge ~= current then
                nextBadgeLevels[honorLevel] = level
                break
            end
        end
    end
    return nextBadgeLevels[honorLevel] or nil
end

local function GetBagItemQualityColor(quality)
    if ColorManager then
        if quality == -1 then
            return BLACK_QUALITY_COLOR
        end
        local color = ColorManager.GetColorDataForBagItemQuality(quality)
        return color or BLACK_QUALITY_COLOR
    else
        local cached = qualityColorFallbackCache[quality]
        if not cached then
            local r, g, b = C_Item.GetItemQualityColor(quality)
            cached = {r = r, g = g, b = b}
            if quality ~= nil then
                qualityColorFallbackCache[quality] = cached
            end
        end
        return cached
    end
end
GW.GetBagItemQualityColor = GetBagItemQualityColor

-- the ninth of the screen a frame's center is in, named like an anchor point
local SCREEN_GRID = {
    { "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT" },
    { "LEFT", "CENTER", "RIGHT" },
    { "TOPLEFT", "TOP", "TOPRIGHT" },
}
local function GetScreenQuadrant(frame)
    local x, y = frame:GetCenter()
    if not (x and y) then
        return "UNKNOWN"
    end

    local column = min(3, max(1, floor(x / GetScreenWidth() * 3) + 1))
    local row = min(3, max(1, floor(y / GetScreenHeight() * 3) + 1))
    return SCREEN_GRID[row][column]
end
GW.GetScreenQuadrant = GetScreenQuadrant

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

local function TextGradient(text, ...)
    local msg, total = "", strlenutf8(text)
    local idx, num = 0, select("#", ...) / 3

    for i = 1, total do
        local x = string.utf8sub(text, i, i)
        if strmatch(x, "%s") then
            msg = msg .. x
            idx = idx + 1
        else
            local segment, relperc = math.modf((idx / total) * num)
            local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

            if not r2 then
                msg = msg .. GW.RGBToHex(r1, g1, b1, nil, x .. '|r')
            else
                msg = msg .. GW.RGBToHex(r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc, nil, x ..'|r')
                idx = idx + 1
            end
        end
    end

    return msg
end
GW.TextGradient = TextGradient

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

local function EscapeString(s)
    return gsub(s, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end
GW.EscapeString = EscapeString

do
    local cuttedIconTemplate = "|T%s:%d:%d:0:0:64:64:5:59:5:59|t"
    local cuttedIconAspectRatioTemplate = "|T%s:%d:%d:0:0:64:64:%d:%d:%d:%d|t"
    local s = 14

    local function GetIconString(icon, height, width, aspectRatio)
        if aspectRatio and height and height > 0 and width and width > 0 then
            local proportionality = height / width
            local offset = ceil((54 - 54 * proportionality) / 2)
            if proportionality > 1 then
                return format(cuttedIconAspectRatioTemplate, icon, height, width, 5 + offset, 59 - offset, 5, 59)
            elseif proportionality < 1 then
                return format(cuttedIconAspectRatioTemplate, icon, height, width, 5, 59, 5 + offset, 59 - offset)
            end
        end

        width = width or height
        return format(cuttedIconTemplate, icon, height or s, width or s)
    end
    GW.GetIconString = GetIconString
end

local function GetClassIconStringWithStyle(class, width, height)
    if not class then
        return
    end


    if not width and not height then
        return format("|T%s:0|t", "Interface/Addons/GW2_UI/Textures/classicons/" .. class .. "_flat.png")
    end

    if not height then
        height = width
    end

    return format("|T%s:%d:%d:0:0:64:64:0:64:0:64|t", "Interface/Addons/GW2_UI/Textures/classicons/" .. class .. "_flat.png", height, width)
end
GW.GetClassIconStringWithStyle = GetClassIconStringWithStyle

local function IsGroupMember(name)
    if name then
        local nameRaid = UnitInRaid(name)
        local nameParty = UnitInParty(name)

        if GW.NotSecretValue(nameParty) and nameParty then
            return 1
        elseif GW.NotSecretValue(nameRaid) and nameRaid then
            return 2
        elseif name == GW.myname then
            return 3
        end
    end

    return false
end
GW.IsGroupMember = IsGroupMember

local function IsSpellTalented(spellID) -- this could be made to be a lot more efficient, if you already know the relevant nodeID and entryID
    local configID = C_ClassTalents.GetActiveConfigID()
    if configID == nil then return end

    local configInfo = C_Traits.GetConfigInfo(configID)
    if configInfo == nil then return end

    for _, treeID in ipairs(configInfo.treeIDs) do -- in the context of talent trees, there is only 1 treeID
        local nodes = C_Traits.GetTreeNodes(treeID)
        for _, nodeID in ipairs(nodes) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            for _, entryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do -- there should be 1 or 0
                local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
                if entryInfo and entryInfo.definitionID then
                    local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                    if definitionInfo.spellID == spellID then
                        return true
                    end
                end
            end
        end
    end
    return false
end
GW.IsSpellTalented = IsSpellTalented

local function moveFrameToPosition(frame, x, y)
    local pos = GW.settings.skins[frame.gwSkin].pos

    if x and y then
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point = "TOPLEFT"
        pos.relativePoint = "TOPLEFT"
        pos.xOfs = x
        pos.yOfs = y

        GW.settings.skins[frame.gwSkin].pos = pos
    end

    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
end

local function MakeFrameMovable(frame, target, skin, moveFrameOnShow)
    if not target then
        local point = GW.settings.skins[skin].pos
        frame:ClearAllPoints()
        frame:SetPoint(point.point, UIParent, point.relativePoint, point.xOfs, point. yOfs)
    end

    target = target or frame

    target.gwSkin = skin
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetUserPlaced(false)
    frame:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            target:StartMoving()
        end
    end)
    frame:SetScript("OnMouseUp", function()
        target:StopMovingOrSizing()

        local x, y = target:GetLeft(), target:GetTop() - UIParent:GetTop()

        moveFrameToPosition(target, x, y)
    end)
    if moveFrameOnShow then
        frame:HookScript("OnShow", function()
            moveFrameToPosition(target)
        end)
        hooksecurefunc(frame, "SetPoint", function(self)
            if not self:IsShown() or self.gwApplyingPosition then
                return
            end
            self.gwApplyingPosition = true
            moveFrameToPosition(target)
            self.gwApplyingPosition = nil
        end)
    end
end
GW.MakeFrameMovable = MakeFrameMovable

local function UpdateFontSettings()
    for text in pairs(GW.texts) do
        if text then
            text:GwSetFontTemplate(text.gwFont, text.gwTextSizeType, text.gwStyle, text.gwTextSizeAddition, true)
        else
            GW.texts[text] = nil
        end
    end
end
GW.UpdateFontSettings = UpdateFontSettings

-- encounter journal art of a dungeon or raid by its game map id (the last return of GetSavedInstanceInfo)
local instanceIcons = {}
local function GetInstanceIcon(mapID)
    if not mapID then return end
    if not instanceIcons[mapID] and C_EncounterJournal and EJ_GetInstanceInfo then
        local journalID = C_EncounterJournal.GetInstanceForGameMap(mapID)
        -- only hits are cached, the journal may not be ready on the first try
        instanceIcons[mapID] = journalID and select(4, EJ_GetInstanceInfo(journalID)) or nil
    end
    return instanceIcons[mapID]
end
GW.GetInstanceIcon = GetInstanceIcon

local function BlizzardDropdownRadioButtonInitializer(button, description, menu, isSelected, data)
    if not isSelected and description.isSelected and type(description.isSelected) == "function" then
        isSelected = description.isSelected
    end
    if not data and description.data then
        data = description.data
    end
    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png")
    button.highlight:SetDrawLayer("BACKGROUND")
    button.highlight:SetBlendMode("BLEND")
    button.highlight:SetAlpha(0.5)
    if GW.isModern then
        button.leftTexture1:SetSize(13, 13)
        button.leftTexture1:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/radio-unselected.png")
        button.leftTexture1:SetPoint("LEFT", 0, 0)
        if button.leftTexture2 then
            button.leftTexture2:SetSize(13, 13)
            button.leftTexture2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/radio-selected.png")
            button.leftTexture2:SetPoint("CENTER", button.leftTexture1, "CENTER", 0, 0)
        end
    else
        if isSelected(data) then
            button.leftTexture1:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png")
        else
            button.leftTexture1:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png")
        end
    end
    if not button.gwHooked then
        hooksecurefunc(button.highlight, "SetAlpha", function(self, a)
            if a ~= 0.5 then
                self:SetAlpha(0.5)
            end
        end)
        button.gwHooked = true
    end
end
GW.BlizzardDropdownRadioButtonInitializer = BlizzardDropdownRadioButtonInitializer

local function BlizzardDropdownCheckButtonInitializer(button, description, menu, isSelected, data)
    if not isSelected and description.isSelected and type(description.isSelected) == "function" then
        isSelected = description.isSelected
    end
    if not data and description.data then
        data = description.data
    end
    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png")
    button.highlight:SetDrawLayer("BACKGROUND")
    button.highlight:SetBlendMode("BLEND")
    button.highlight:SetAlpha(0.5)
    button.leftTexture1:SetSize(13, 13)
    if GW.isModern or not isSelected then
        button.leftTexture1:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png")
        if button.leftTexture2 then
            button.leftTexture2:SetSize(13, 13)
            button.leftTexture2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png")
            button.leftTexture2:SetPoint("CENTER", button.leftTexture1, "CENTER", 0, 0)
        end
    else
        if isSelected(data) then
            button.leftTexture1:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png")
        else
            button.leftTexture1:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png")
        end
    end
    if not button.gwHooked then
        hooksecurefunc(button.highlight, "SetAlpha", function(self, a)
            if a ~= 0.5 then
                self:SetAlpha(0.5)
            end
        end)
        button.gwHooked = true
    end
end
GW.BlizzardDropdownCheckButtonInitializer = BlizzardDropdownCheckButtonInitializer

local function BlizzardDropdownButtonInitializer(button, description, menu)
    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png")
    button.highlight:SetDrawLayer("BACKGROUND")
    button.highlight:SetBlendMode("BLEND")
    button.highlight:SetAlpha(0.5)
    if not button.gwHooked then
        hooksecurefunc(button.highlight, "SetAlpha", function(self, a)
            if a ~= 0.5 then
                self:SetAlpha(0.5)
            end
        end)
        button.gwHooked = true
    end
end
GW.BlizzardDropdownButtonInitializer = BlizzardDropdownButtonInitializer

local function AddMenuSliderDescription(rootDescription, config)
    local title = config.title or ""
    if title ~= "" then
        local button = rootDescription:CreateButton(title)
        button:AddInitializer(GW.BlizzardDropdownButtonInitializer)
    end

    local frameElement = rootDescription:CreateTemplate(config.template or "GwDropdownSliderValueMenuTemplate")
    frameElement:SetCanSelect(false)
    frameElement:SetSelectionIgnored()
    frameElement:AddInitializer(function(frame)
        if frame.title then
            frame.title:SetText("")
        end

        local slider = frame.slider
        local step = config.step or 1
        -- Frames are pooled by Blizzard's menu system; clear any stale callback before
        -- changing limits/value to avoid writing unrelated settings during init.
        slider:SetScript("OnValueChanged", nil)
        slider:SetMinMaxValues(config.minValue or 0, config.maxValue or 1)
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        slider:EnableMouseWheel(true)
        slider:SetScript("OnMouseWheel", function(self, delta)
            self:SetValue(self:GetValue() + (delta > 0 and step or -step))
        end)

        local currentValue = config.getValue()
        slider:SetValue(currentValue)
        frame.valueText:SetText(slider:GetValue())

        slider:SetScript("OnValueChanged", function(self, value)
            local normalizedValue = config.setValue(value)
            if normalizedValue ~= value then
                self:SetValue(normalizedValue)
                return
            end
            frame.valueText:SetText(normalizedValue)
        end)
    end)
end
GW.AddMenuSliderDescription = AddMenuSliderDescription

local function DoesAncestryInclude(ancestry, frame)
    if ancestry then
        local currentFrame = frame
        while currentFrame do
            if currentFrame == ancestry then
                return true;
            end
            currentFrame = GW.SafeGetParent(currentFrame)
        end
    end
    return false
end
GW.DoesAncestryInclude = DoesAncestryInclude

local function DoesAncestryIncludeAny(ancestry, frames)
    for _, frame in ipairs(frames) do
        if DoesAncestryInclude(ancestry, frame) then
            return true;
        end
    end
    return false;
end
GW.DoesAncestryIncludeAny = DoesAncestryIncludeAny

-- activating the saved layout makes the client fire EDIT_MODE_LAYOUTS_UPDATED, and blizzards handler applies
-- it untainted; applying it from here taints the action bar state and blocks the stance bar in combat
local layoutsUpdated = false
local layoutWatcher = CreateFrame("Frame")
layoutWatcher:SetScript("OnEvent", function()
    layoutsUpdated = true
end)

local function ApplyLayoutChanges()
    layoutsUpdated = false
    layoutWatcher:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
    GW.Libs.LEMO:SaveOnly()
    layoutWatcher:UnregisterEvent("EDIT_MODE_LAYOUTS_UPDATED")

    if not layoutsUpdated then
        GW.Debug("edit mode layout was not re-applied by the client, applying it ourselves")
        EditModeManagerFrame:UpdateLayoutInfo(C_EditMode.GetLayouts())
        local ManageFrames = ManageFramePositions or UIParent_ManageFramePositions
        if ManageFrames then
            ManageFrames()
        end
    end
end
GW.ApplyLayoutChanges = ApplyLayoutChanges

-- NOTE: no skip-when-unchanged shortcut here! An earlier optimization compared the saved
-- layout values and skipped ApplyChanges when they matched — but the saved values say
-- nothing about what the client actually APPLIED this session, and skipping the apply
-- left some users with fully invisible action bars (only tooltips worked). The layout
-- has to be applied unconditionally on every login.
local function AddGw2Layout(init)
    if not GW.Libs.LEMO:IsReady() then
        C_Timer.After(0, function() AddGw2Layout(init) end)
        return
    end

    GW.Libs.LEMO:LoadLayouts()

    if init or (not init and GW.Libs.LEMO:GetActiveLayout() ~= "GW2_Layout") then
        if not GW.Libs.LEMO:DoesLayoutExist("GW2_Layout") then
            if GW.Libs.LEMO:GetNumAccountLayouts() < 5 then
                GW.Libs.LEMO:AddLayout(Enum.EditModeLayoutType.Account, "GW2_Layout")
            else
                GW.Libs.LEMO:AddLayout(Enum.EditModeLayoutType.Character, "GW2_Layout")
            end
        end
        GW.Libs.LEMO:SetActiveLayout("GW2_Layout")

        -- icon size in percent, the library turns it into the step blizzard stores
        GW.Libs.LEMO:SetFrameSetting(MainActionBar, Enum.EditModeActionBarSetting.IconSize, 100)
        GW.Libs.LEMO:SetFrameSetting(MainActionBar, Enum.EditModeActionBarSetting.HideBarArt, 1)
        GW.Libs.LEMO:SetFrameSetting(MultiBarBottomLeft, Enum.EditModeActionBarSetting.IconSize, 100)
        GW.Libs.LEMO:SetFrameSetting(MultiBarBottomRight, Enum.EditModeActionBarSetting.IconSize, 100)
        GW.Libs.LEMO:SetFrameSetting(MultiBarRight, Enum.EditModeActionBarSetting.IconSize, 100)
        GW.Libs.LEMO:SetFrameSetting(MultiBarLeft, Enum.EditModeActionBarSetting.IconSize, 100)
        GW.Libs.LEMO:SetFrameSetting(MultiBar5, Enum.EditModeActionBarSetting.IconSize, 100)
        GW.Libs.LEMO:SetFrameSetting(MultiBar6, Enum.EditModeActionBarSetting.IconSize, 100)
        GW.Libs.LEMO:SetFrameSetting(MultiBar7, Enum.EditModeActionBarSetting.IconSize, 100)
        -- Main Actionbar
        GW.Libs.LEMO:SetFrameSetting(MainActionBar, Enum.EditModeActionBarSetting.Orientation, Enum.ActionBarOrientation.Horizontal)
        GW.Libs.LEMO:SetFrameSetting(MainActionBar, Enum.EditModeActionBarSetting.NumRows, 1)
        GW.Libs.LEMO:SetFrameSetting(MainActionBar, Enum.EditModeActionBarSetting.NumIcons, 12)
        GW.Libs.LEMO:SetFrameSetting(MainActionBar, Enum.EditModeActionBarSetting.HideBarScrolling, 1)
        GW.Libs.LEMO:ReanchorFrame(MainActionBar, "TOP", UIParent, "BOTTOM", 0, (80 * (tonumber(GW.settings.hud.scale) or 1)))

        -- PossessActionBar
        GW.Libs.LEMO:ReanchorFrame(PossessActionBar, "BOTTOM", MainActionBar, "TOP", -110, 40)
        ApplyLayoutChanges()
    end

    if init then
        GW.Libs.LEMO:RegisterForLayoutChangeBackToGW2Layout()
    end
end
GW.AddGw2Layout = AddGw2Layout

-- applies our layout once on load, AddGw2Layout waits for the lib itself; the edit mode stays with
-- blizzard, our code there would only taint it
local function ApplyEditModeLayout()
    if InCombatLockdown() then
        GW.CombatQueue:Queue("GwApplyEditModeLayout", ApplyEditModeLayout)
        return
    end
    AddGw2Layout(true)

    if MirrorTimerContainer then
        MirrorTimerContainer:Show()
    end
end

local function LoadEditModeLayout()
    if GW.settings.actionbars.enabled and GW.settings.actionbars.barLayout and not GW.IsGamepadInterface() then
        C_Timer.After(0, ApplyEditModeLayout)
    end
end
GW.LoadEditModeLayout = LoadEditModeLayout

local function MakeActionbuttonsVisible()
    if not GW.Libs.LEMO:IsReady() then
        GW.Notice("LEMO not ready, cannot make action buttons visible")
        return
    end

    GW.Libs.LEMO:LoadLayouts()

    if GW.Libs.LEMO:DoesLayoutExist("GW2_Layout")then
        GW.Libs.LEMO:SetActiveLayout("GW2_Layout")

        GW.Libs.LEMO:SetFrameSetting(MainActionBar, Enum.EditModeActionBarSetting.AlwaysShowButtons, 1)
        GW.Libs.LEMO:SetFrameSetting(MultiBarBottomLeft, Enum.EditModeActionBarSetting.AlwaysShowButtons, 1)
        GW.Libs.LEMO:SetFrameSetting(MultiBarBottomRight, Enum.EditModeActionBarSetting.AlwaysShowButtons, 1)
        GW.Libs.LEMO:SetFrameSetting(MultiBarRight, Enum.EditModeActionBarSetting.AlwaysShowButtons, 1)
        GW.Libs.LEMO:SetFrameSetting(MultiBarLeft, Enum.EditModeActionBarSetting.AlwaysShowButtons, 1)
        GW.Libs.LEMO:SetFrameSetting(MultiBar5, Enum.EditModeActionBarSetting.AlwaysShowButtons, 1)
        GW.Libs.LEMO:SetFrameSetting(MultiBar6, Enum.EditModeActionBarSetting.AlwaysShowButtons, 1)
        GW.Libs.LEMO:SetFrameSetting(MultiBar7, Enum.EditModeActionBarSetting.AlwaysShowButtons, 1)
        ApplyLayoutChanges()

        GW.Notice("Making action buttons visible via LEMO")
    else
        GW.Notice("Could not make action buttons visible via LEMO, GW2_Layout not found")
    end
end
GW.MakeActionbuttonsVisible = MakeActionbuttonsVisible

local function GetDebuffScaleBasedOnPrio()
    local scale = 1

    if GW.settings.groupFrames.debuffScalePriority == "DISPELL" then
        return tonumber(GW.settings.groupFrames.dispelDebuffsScale)
    elseif GW.settings.groupFrames.debuffScalePriority == "IMPORTANT" then
        return tonumber(GW.settings.groupFrames.raidDebuffsScale)
    end

    return scale
end
GW.GetDebuffScaleBasedOnPrio = GetDebuffScaleBasedOnPrio

function GW.GetEnumName(enum, enumValue)
    local keysByValue = tInvert(enum)
    return keysByValue[enumValue] or UNKNOWN .. enumValue
end
