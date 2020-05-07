local _, GW = ...
local L = GW.L
local UnitAura = UnitAura
local GetSetting = GW.GetSetting
local RegisterMovableFrame = GW.RegisterMovableFrame
local RGBToHex = GW.RGBToHex
local GWGetClassColor = GW.GWGetClassColor
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local LibClassicDurations = LibStub("LibClassicDurations", true)

local targetList = {}
local classification = {
    worldboss = format("|cffAF5050 %s|r", BOSS),
    rareelite = format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
    elite = "|cffAF5050+|r",
    rare = format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC)
}
local LEVEL1 = strlower(_G.TOOLTIP_UNIT_LEVEL:gsub("%s?%%s%s?%-?", ""))
local LEVEL2 = strlower(_G.TOOLTIP_UNIT_LEVEL_CLASS:gsub("^%%2$s%s?(.-)%s?%%1$s", "%1"):gsub("^%-?г?о?%s?", ""):gsub("%s?%%s%s?%-?", ""))

local UNSTYLED = {
    "GameTooltip",
    "ShoppingTooltip1",
    "ShoppingTooltip2",
    "ShoppingTooltip3",
    "ItemRefTooltip",
    "ItemRefShoppingTooltip1",
    "ItemRefShoppingTooltip2",
    "ItemRefShoppingTooltip3",
    "WorldMapTooltip",
    "WorldMapCompareTooltip1",
    "WorldMapCompareTooltip2",
    "WorldMapCompareTooltip3",
    "AtlasLootTooltip",
    "QuestHelperTooltip",
    "QuestGuru_QuestWatchTooltip",
    "TRP2_MainTooltip",
    "TRP2_ObjetTooltip",
    "TRP2_StaticPopupPersoTooltip",
    "TRP2_PersoTooltip",
    "TRP2_MountTooltip",
    "AltoTooltip",
    "AltoScanningTooltip",
    "ArkScanTooltipTemplate",
    "NxTooltipItem",
    "NxTooltipD",
    "DBMInfoFrame",
    "DBMRangeCheck",
    "DatatextTooltip",
    "VengeanceTooltip",
    "FishingBuddyTooltip",
    "FishLibTooltip",
    "HealBot_ScanTooltip",
    "hbGameTooltip",
    "PlateBuffsTooltip",
    "LibGroupInSpecTScanTip",
    "RecountTempTooltip",
    "VuhDoScanTooltip",
    "XPerl_BottomTip",
    "EventTraceTooltip",
    "FrameStackTooltip",
    "LibDBIconTooltip"
}

local function GetLevelLine(self, offset)
    if self:IsForbidden() then return end
    for i = offset, self:NumLines() do
        local tipLine = _G["GameTooltipTextLeft" .. i]
        local tipText = tipLine and tipLine.GetText and tipLine:GetText() and strlower(tipLine:GetText())
        if tipText and (strfind(tipText, LEVEL1) or strfind(tipText, LEVEL2)) then
            return tipLine
        end
    end
end

local function RemoveTrashLines(self)
    if self:IsForbidden() then return end
    for i = 3, self:NumLines() do
        local tiptext = _G["GameTooltipTextLeft" .. i]
        local linetext = tiptext:GetText()

        if linetext == PVP or linetext == FACTION_ALLIANCE or linetext == FACTION_HORDE then
            tiptext:SetText("")
            tiptext:Hide()
        end
    end
end

local function SetUnitText(self, unit, level, isShiftKeyDown)
    local name, realm = UnitName(unit)
    local showClassColor = GetSetting("ADVANCED_TOOLTIP_SHOW_CLASS_COLOR")

    if UnitIsPlayer(unit) then
        local localeClass, class = UnitClass(unit)
        if not localeClass or not class then return end

        local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
        local relationship = UnitRealmRelationship(unit)
        local pvpName = UnitPVPName(unit)
        local playerTitles = GetSetting("ADVANCED_TOOLTIP_SHOW_PLAYER_TITLES")
        local alwaysShowRealm = GetSetting("ADVANCED_TOOLTIP_SHOW_REALM_ALWAYS")
        local guildRanks = GetSetting("ADVANCED_TOOLTIP_SHOW_GUILD_RANKS")

        local nameColor = GWGetClassColor(class, showClassColor, true)

        if pvpName and playerTitles then
            name = pvpName
        end

        if realm and realm ~= "" then
            if isShiftKeyDown or alwaysShowRealm then
                name = name .. "-" .. realm
            elseif relationship == _G.LE_REALM_RELATION_COALESCED then
                name = name .. _G.FOREIGN_SERVER_LABEL
            elseif relationship == _G.LE_REALM_RELATION_VIRTUAL then
                name = name .. _G.INTERACTIVE_SERVER_LABEL
            end
        end

        name = name .. ((UnitIsAFK(unit) and " |cffFFFFFF[|r|cffFF0000" .. AFK .. "|r|cffFFFFFF]|r") or (UnitIsDND(unit) and " |cffFFFFFF[|r|cffFFFF00" .. DND .. "|r|cffFFFFFF]|r") or "")

        _G.GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", nameColor.colorStr, name or UNKNOWN)

        local lineOffset = 2
        if guildName then
            if guildRealm and isShiftKeyDown then
                guildName = guildName .. "-" .. guildRealm
            end

            if guildRanks then
                _G.GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r> [|cff00ff10%s|r]", guildName, guildRankName)
            else
                _G.GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r>", guildName)
            end

            lineOffset = 3
        end

        local diffColor = GetCreatureDifficultyColor(level)
        local race = UnitRace(unit)
        local levelString = format("|cff%02x%02x%02x%s|r %s |c%s%s|r", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", race or "", nameColor.colorStr, localeClass)

        if levelLine then
            levelLine:SetText(levelString)
        else
            GameTooltip:AddLine(levelString)
        end

        return nameColor
    else
        local levelLine = GetLevelLine(self, 2)
        if levelLine then
            local creatureClassification = UnitClassification(unit)
            local creatureType = UnitCreatureType(unit)
            local pvpFlag = ""
            local diffColor = GetCreatureDifficultyColor(level)

            if UnitIsPVP(unit) then
                pvpFlag = format(" (%s)", PVP)
            end

            levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classification[creatureClassification] or "", creatureType or "", pvpFlag)
        end

        local unitReaction = UnitReaction(unit, "player")
        local nameColor = unitReaction and GW.FACTION_BAR_COLORS[unitReaction] or RAID_CLASS_COLORS.PRIEST

        if unitReaction and unitReaction >= 5 then nameColor = COLOR_FRIENDLY[1] end --Friend

        local nameColorStr = nameColor.colorStr or RGBToHex(nameColor.r, nameColor.g, nameColor.b, "ff")
        _G.GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", nameColorStr, name or UNKNOWN)

        return UnitIsTapDenied(unit) and {r = 159 / 255, g = 159 / 255, b = 159 / 255} or nameColor
    end
end

local function GameTooltip_OnTooltipSetUnit(self)
    if self:IsForbidden() then return end

    local unit = select(2, self:GetUnit())
    local isShiftKeyDown = IsShiftKeyDown()
    local isControlKeyDown = IsControlKeyDown()
    local isPlayerUnit = UnitIsPlayer(unit)

    if not unit then
        local GMF = GetMouseFocus()
        if GMF and GMF.GetAttribute and GMF:GetAttribute("unit") then
            unit = GMF:GetAttribute("unit")
        end
        if not unit or not UnitExists(unit) then
            return
        end
    end

    RemoveTrashLines(self) -- keep an eye on this may be buggy

    local color = SetUnitText(self, unit, UnitLevel(unit), isShiftKeyDown)
    local showClassColor = GetSetting("ADVANCED_TOOLTIP_SHOW_CLASS_COLOR")

    if not isShiftKeyDown and not isControlKeyDown then
        local unitTarget = unit .. "target"
        local targetInfo = GetSetting("ADVANCED_TOOLTIP_SHOW_TARGET_INFO")
        if targetInfo and unit ~= "player" and UnitExists(unitTarget) then
            local targetColor
            if UnitIsPlayer(unitTarget) then
                local _, class = UnitClass(unitTarget)
                targetColor = GWGetClassColor(class, showClassColor, true)
            else
                targetColor = GW.FACTION_BAR_COLORS[UnitReaction(unitTarget, "player")]
            end

            if not targetColor.colorStr then
                targetColor.colorStr = RGBToHex(targetColor.r, targetColor.g, targetColor.b, "ff")
            elseif strlen(targetColor.colorStr) == 6 then
                targetColor.colorStr = "ff" .. targetColor.colorStr
            end
            self:AddDoubleLine(format("%s:", TARGET), format("|c%s%s|r", targetColor.colorStr, UnitName(unitTarget)))
        end

        if targetInfo and IsInGroup() then
            for i = 1, GetNumGroupMembers() do
                local groupUnit = (IsInRaid() and "raid" .. i or "party" .. i)
                if (UnitIsUnit(groupUnit .. "target", unit)) and (not UnitIsUnit(groupUnit, "player")) then
                    local _, class = UnitClass(groupUnit)
                    local classColor = GWGetClassColor(class, showClassColor, true)
                    tinsert(targetList, format("|c%s%s|r", classColor.colorStr, UnitName(groupUnit)))
                end
            end
            local numList = #targetList
            if (numList > 0) then
                self:AddLine(format("%s (|cffffffff%d|r): %s", L["TARGETED_BY"], numList, table.concat(targetList, ", ")), nil, nil, nil, true)
                wipe(targetList)
            end
        end
    end

    -- NPC ID's
    local npcID = GetSetting("ADVANCED_TOOLTIP_NPC_ID")
    if unit and npcID and not isPlayerUnit then
        local guid = UnitGUID(unit) or ""
        local id = tonumber(strmatch(guid, "%-(%d-)%-%x-$"), 10)
        if id then
            self:AddLine(format("|cffffedba%s|r %d", ID, id))
        end
    end
end

local function GameTooltip_OnTooltipCleared(self)
    if self:IsForbidden() then return end
    self.itemCleared = nil
end

local function GameTooltip_OnTooltipSetItem(self)
    if self:IsForbidden() then return end

    if not self.itemCleared then
        local _, link = self:GetItem()
        local num = GetItemCount(link)
        local numall = GetItemCount(link, true)
        local left, right, bankCount = " ", " ", " "
        local itemCountOption = GetSetting("ADVANCED_TOOLTIP_OPTION_ITEMCOUNT")
        local showSpellID = GetSetting("ADVANCED_TOOLTIP_SPELL_ITEM_ID")

        if right ~= nil and showSpellID then
            right = format("|cffffedba%s|r %s", ID, strmatch(link, ":(%w+)"))
        end

        if itemCountOption == "BAG" then
            left = format("|cffffedba%s|r %d", INVENTORY_TOOLTIP, num)
        elseif itemCountOption == "BANK" then
            bankCount = format("|cffffedba%s|r %d", BANK, (numall - num))
        elseif itemCountOption == "BOTH" then
            left = format("|cffffedba%s|r %d", INVENTORY_TOOLTIP, num)
            bankCount = format("|cffffedba%s|r %d", BANK, (numall - num))
        end

        if left ~= " " or right ~= " " then
            self:AddLine(" ")
            self:AddDoubleLine(left, right)
        end
        if bankCount ~= " " then
            self:AddDoubleLine(bankCount, " ")
        end

        self.itemCleared = true
    end
end

local function GameTooltip_OnTooltipSetSpell(self)
    if self:IsForbidden() then return end
    local id = select(2, self:GetSpell())
    local showSpellID = GetSetting("ADVANCED_TOOLTIP_SPELL_ITEM_ID")
    if not id or not showSpellID then return end

    local displayString = format("|cffffedba%s|r %d", ID, id)

    for i = 1, self:NumLines() do
        local line = _G[format("GameTooltipTextLeft%d", i)]
        local text = line and line.GetText and line:GetText()
        if text and strfind(text, displayString) then
            return
        end
    end

    self:AddLine(displayString)
    self:Show()
end

local function SetUnitAura(self, unit, index, filter)
    if not self or self:IsForbidden() then return end
    local _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)

    if id then
        local showSpellID = GetSetting("ADVANCED_TOOLTIP_SPELL_ITEM_ID")
        local showClassColor = GetSetting("ADVANCED_TOOLTIP_SHOW_CLASS_COLOR")

        if showSpellID then
            if caster then
                local name = UnitName(caster)
                local _, class = UnitClass(caster)
                local color = GWGetClassColor(class, showClassColor, true)
                self:AddDoubleLine(format("|cffffedba%s|r %d", ID, id), format("|c%s%s|r", color.colorStr, name))
            else
                self:AddLine(format("|cffffedba%s|r %d", ID, id))
            end
        end

        self:Show()
    end
end

local function movePlacement(self)
    local settings = GetSetting("GameTooltipPos")
    self:ClearAllPoints()
    self:SetPoint(settings.point, UIParent, settings.relativePoint, settings.xOfs, settings.yOfs)
end
GW.AddForProfiling("tooltips", "movePlacement", movePlacement)

local constBackdropArgs = {
    bgFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Background",
    edgeFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
local function styleTooltip(self)
    if not self:IsShown() then
        return
    end
    self:SetBackdrop(constBackdropArgs)
    if _G[self:GetName() .. "StatusBarTexture"] then
        _G[self:GetName() .. "StatusBarTexture"]:SetTexture("Interface/Addons/GW2_UI/Textures/castinbar-white")
    end
end
GW.AddForProfiling("tooltips", "styleTooltip", styleTooltip)

local function tooltip_SetBackdropStyle(self, args)
    --if args and args == GAME_TOOLTIP_BACKDROP_STYLE_EMBEDDED then
        --return
    --end
    if not self:IsShown() then
        return
    end
    self:SetBackdrop(constBackdropArgs)
end
GW.AddForProfiling("tooltips", "tooltip_SetBackdropStyle", tooltip_SetBackdropStyle)

local function anchorTooltip(self, p)
    self:SetOwner(p, GetSetting("CURSOR_ANCHOR_TYPE"), GetSetting("ANCHOR_CURSOR_OFFSET_X"), GetSetting("ANCHOR_CURSOR_OFFSET_Y"))
end
GW.AddForProfiling("tooltips", "anchorTooltip", anchorTooltip)

local function LoadTooltips()
    if GetSetting("TOOLTIP_MOUSE") then
        hooksecurefunc("GameTooltip_SetDefaultAnchor", anchorTooltip)
    else
        GameTooltip:HookScript("OnTooltipSetUnit", movePlacement)
        GameTooltip:HookScript("OnTooltipSetQuest", movePlacement)
        GameTooltip:HookScript("OnTooltipSetSpell", movePlacement)
        --GameTooltip:HookScript("OnTooltipSetItem", movePlacement)
        GameTooltip:HookScript("OnTooltipSetDefaultAnchor", movePlacement)
        RegisterMovableFrame(GameTooltip, "Tooltip", "GameTooltipPos", "VerticalActionBarDummy")
        hooksecurefunc(GameTooltip.gwMover, "StopMovingOrSizing", function (frame)
            local anchor = "BOTTOMRIGHT"
            local x = frame:GetRight() - GetScreenWidth()
            local y = frame:GetBottom()

            frame:ClearAllPoints()
            frame:SetPoint(anchor, x, y)

            if not InCombatLockdown() then
                GameTooltip:ClearAllPoints()
                GameTooltip:SetPoint(frame:GetPoint())
            end
        end)
    end

    if GetSetting("ADVANCED_TOOLTIP") then
        GameTooltip:HookScript("OnTooltipSetUnit", GameTooltip_OnTooltipSetUnit)
        GameTooltip:HookScript("OnTooltipSetItem", GameTooltip_OnTooltipSetItem)
        GameTooltip:HookScript("OnTooltipCleared", GameTooltip_OnTooltipCleared)
        GameTooltip:HookScript("OnTooltipSetSpell", GameTooltip_OnTooltipSetSpell)
        hooksecurefunc(GameTooltip, "SetUnitBuff", SetUnitAura)
        hooksecurefunc(GameTooltip, "SetUnitDebuff", SetUnitAura)
    end

    hooksecurefunc("GameTooltip_SetBackdropStyle", tooltip_SetBackdropStyle)
    for _, toStyle in ipairs(UNSTYLED) do
        local f = _G[toStyle]
        if f then
            f:HookScript("OnUpdate", styleTooltip)
        end
    end

    if LibClassicDurations then
        LibClassicDurations:Register("GW2_UI")
        UnitAura = LibClassicDurations.UnitAuraWrapper
    end
end
GW.LoadTooltips = LoadTooltips