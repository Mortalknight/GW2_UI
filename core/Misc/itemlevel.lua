local _, GW = ...
local RoundDec = GW.RoundDec

local GetSpellDescription = C_Spell.GetSpellDescription or GetSpellDescription
local ESSENCE_DESCRIPTION = GetSpellDescription(277253)

local essenceTextureID = 2975691
local MATCH_ITEM_LEVEL = ITEM_LEVEL:gsub("%%d", "(%%d+)")
local MATCH_ITEM_LEVEL_ALT = ITEM_LEVEL_ALT:gsub("%%d(%s?)%(%%d%)", "%%d+%1%%((%%d+)%%)")
local MATCH_ENCHANT = ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.+)")
local MATCH_SET_ITEM = ITEM_SET_BONUS:gsub("%%s", "(.+)")
local AZERITE_RESPEC_BUTTON = { -- use this to find Reforge (taken from retail)
    enUS = "Reforge",
    frFR = "Retouche",
    deDE = "Umschmieden",
    koKR = "재연마",
    ruRU = "Перековать",
    zhCN = "重铸",
    zhTW = "重鑄",
    esES = "Reforjar",
    esMX = "Reforjar",
    ptBR = "Reforjar",
    itIT = "Riforgia"
}
local X2_INVTYPES, X2_EXCEPTIONS, ARMOR_SLOTS = {
    INVTYPE_2HWEAPON = true,
    INVTYPE_RANGEDRIGHT = true,
    INVTYPE_RANGED = true,
    },
    {
        [2] = 19, -- wands, use INVTYPE_RANGEDRIGHT, but are 1H
    },
    {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}

local function PopulateUnitIlvlsCache(unitGUID, itemLevel, tooltip)
    if itemLevel then
        if GW.unitIlvlsCache[unitGUID] then
            GW.unitIlvlsCache[unitGUID].time = GetTime()
            GW.unitIlvlsCache[unitGUID].itemLevel = itemLevel
        end

        if tooltip then
            GameTooltip.ItemLevelShown = true
            GameTooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL .. ":", itemLevel, nil, nil, nil, 1, 1, 1)
            GameTooltip:Show()
        end
    end
end
GW.PopulateUnitIlvlsCache = PopulateUnitIlvlsCache

local function InspectGearSlot(line, lineText, slotInfo)
    if not lineText then return end

    local itemLevel = lineText and (strmatch(lineText, MATCH_ITEM_LEVEL_ALT) or strmatch(lineText, MATCH_ITEM_LEVEL))
    if itemLevel then
        slotInfo.iLvl = tonumber(itemLevel)

        local r1, g1, b1 = GW2_UIScanTooltipTextLeft1:GetTextColor()
        slotInfo.itemLevelColors[1] = r1
        slotInfo.itemLevelColors[2] = g1
        slotInfo.itemLevelColors[3] = b1
    end

    local isSetItem = lineText and strmatch(lineText, MATCH_SET_ITEM)
    if isSetItem then
        slotInfo.isSetItem = true
    end

    local r, g, b = line:GetTextColor()
    local allow = not GW.Mists or ((r == 0 and g == 1 and b == 0) and not strfind(lineText, ITEM_SPELL_TRIGGER_ONEQUIP, nil, true) and not strfind(lineText, AZERITE_RESPEC_BUTTON[GW.mylocal or "enUS"], nil, true) and not strfind(lineText, "%(%d+ min%)"))
    if not allow then return end

    local enchant = (not GW.Mists and strmatch(lineText, MATCH_ENCHANT)) or (GW.Mists and strfind(lineText, "^%+") and not strfind(lineText, BONUS_ARMOR, nil, true) and not strfind(lineText, STAT_MASTERY, nil, true) and lineText)
    if enchant then
        local color1, color2 = strmatch(enchant, "(|cn.-:).-(|r)")
        local enchantQuality = enchant:match("(%s?|A.-|a)")
        local text = gsub(gsub(enchant, "%s?|A.-|a", ""), "|cn.-:(.-)|r", "%1")
        slotInfo.enchantText = format("%s%s%s%s", color1 or "", text, color2 or "", enchantQuality or "")
        slotInfo.enchantTextShort = format("%s%s%s%s", color1 or "", string.utf8sub(text, 1, 18), color2 or "", enchantQuality or "")
        slotInfo.enchantTextShort2 = format("%s%s%s%s", color1 or "", string.utf8sub(text, 1, 11), color2 or "", enchantQuality or "")
        slotInfo.enchantTextReal = enchant
        slotInfo.enchantQuality = enchantQuality

        slotInfo.enchantColors[1] = r
        slotInfo.enchantColors[2] = g
        slotInfo.enchantColors[3] = b
    end
end

local function ScanTooltipTextures()
    local tt = GW.ScanTooltip

    if not tt.gems then
        tt.gems = {}
    else
        wipe(tt.gems)
    end

    if not tt.essences then
        tt.essences = {}
    else
        for _, essences in pairs(tt.essences) do
            wipe(essences)
        end
    end

    local step = 1
    for i = 1, 10 do
        local tex = _G["GW2_UIScanTooltipTexture" .. i]
        local texture = tex and tex:IsShown() and tex:GetTexture()
        if texture then
            if texture == essenceTextureID then
                local selected = (tt.gems[i - 1] ~= essenceTextureID and tt.gems[i - 1]) or nil
                if not tt.essences[step] then tt.essences[step] = {} end

                tt.essences[step][1] = selected			--essence texture if selected or nil
                tt.essences[step][2] = tex:GetAtlas()	--atlas place "tooltip-heartofazerothessence-major" or "tooltip-heartofazerothessence-minor"
                tt.essences[step][3] = texture			--border texture placed by the atlas

                step = step + 1

                if selected then
                    tt.gems[i-1] = nil
                end
            else
                tt.gems[i] = texture
            end
        end
    end
    return tt.gems, tt.essences
end

local function CollectEssenceInfo(index, lineText, slotInfo)
    local step = 1
    local essence = slotInfo.essences[step]
    if essence and next(essence) and (ESSENCE_DESCRIPTION and strfind(lineText, ESSENCE_DESCRIPTION, nil, true) and strfind(lineText, ITEM_SPELL_TRIGGER_ONEQUIP, nil, true)) then
        for i = 5, 2, -1 do
            local line = _G["GW2_UIScanTooltipTextLeft"..index - i]
            local text = line and line:GetText()

            if text and (not strmatch(text, "^[ +]")) and essence and next(essence) then
                local r, g, b = line:GetTextColor()

                essence[4] = GW.RGBToHex(r, g, b)
                essence[5] = text

                step = step + 1
                essence = slotInfo.essences[step]
            end
        end
    end
end

do
    local function GetGearSlotInfo(unit, slot, itemlink, deepScan)
        local tt = GW.ScanTooltip
        tt:SetOwner(UIParent, "ANCHOR_CURSOR")
        if itemlink and string.find(itemlink, "item") then
            tt:SetHyperlink(itemlink)
        elseif slot then
            tt:SetInventoryItem(unit, slot)
        end
        tt:Show()

        local info = tt:GetTooltipData()

        if not tt.slotInfo then tt.slotInfo = {} else wipe(tt.slotInfo) end
        local slotInfo = tt.slotInfo

        if deepScan then
            slotInfo.gems, slotInfo.essences = ScanTooltipTextures()

            if not tt.enchantColors then tt.enchantColors = {} else wipe(tt.enchantColors) end
            if not tt.itemLevelColors then tt.itemLevelColors = {} else wipe(tt.itemLevelColors) end
            slotInfo.enchantColors = tt.enchantColors
            slotInfo.itemLevelColors = tt.itemLevelColors

            if info then
                for i, line in next, info.lines do
                    local text = line and line.leftText
                    if i == 1 and text == RETRIEVING_ITEM_INFO then
                        tt:Hide()
                        return "tooSoon"
                    else
                        InspectGearSlot(_G["GW2_UIScanTooltipTextLeft"..i], text, slotInfo)
                        CollectEssenceInfo(i, text, slotInfo)
                    end
                end
            end
        elseif info then
            local firstLine = info.lines[1]
            local firstText = firstLine and firstLine.leftText
            if firstText == RETRIEVING_ITEM_INFO then
                tt:Hide()
                return "tooSoon"
            end

            local colorblind = GetCVarBool("colorblindmode")
            local numLines = GW.Mists and (colorblind and 21 or 20) or (colorblind and 4 or 3)
            for x = 2, numLines do
                local line = info.lines[x]
                if line then
                    local text = line.leftText
                    local itemLevel = (text and text ~= "") and (strmatch(text, MATCH_ITEM_LEVEL_ALT) or strmatch(text, MATCH_ITEM_LEVEL))
                    if itemLevel then
                        slotInfo.iLvl = tonumber(itemLevel)
                    end
                end
            end

        end
        tt:Hide()
        return slotInfo
    end
    GW.GetGearSlotInfo = GetGearSlotInfo
end

local function CalculateAverageItemLevel(iLevelDB, unit)
    local spec = GW.Retail and GetInspectSpecialization(unit)
    local total = 0

    if GW.Retail and (not spec or spec == 0) then
		return
	end

    -- Armor
    for _, id in next, ARMOR_SLOTS do
        local link = GetInventoryItemLink(unit, id)
        if link then
            local cur = iLevelDB[id]
            if cur and cur > 0 then
                total = total + cur
            end
        elseif GetInventoryItemTexture(unit, id) then
            return
        end
    end

    -- Main hand
    local mainItemLevel, mainQuality, mainEquipLoc, mainItemClass, mainItemSubClass = 0, nil, nil, nil, nil
    local mainLink = GetInventoryItemLink(unit, 16)
    if mainLink then
        mainItemLevel = iLevelDB[16]
        _, _, mainQuality, _, _, _, _, _, mainEquipLoc, _, _, mainItemClass, mainItemSubClass = C_Item.GetItemInfo(mainLink)
    elseif GetInventoryItemTexture(unit, 16) then
        return
    end

    -- Off hand
    local offItemLevel, offEquipLoc = 0, nil
    local offLink = GetInventoryItemLink(unit, 17)
    if offLink then
        offItemLevel = iLevelDB[17]
        _, _, _, _, _, _, _, _, offEquipLoc = C_Item.GetItemInfo(offLink)
    elseif GetInventoryItemTexture(unit, 17) then
        return
    end

    if mainItemLevel and offItemLevel then
        if (mainQuality == 6) or (not offEquipLoc and X2_INVTYPES[mainEquipLoc] and X2_EXCEPTIONS[mainItemClass] ~= mainItemSubClass and spec ~= 72) then
            mainItemLevel = max(mainItemLevel, offItemLevel)
            total = total + mainItemLevel * 2
        else
            total = total + mainItemLevel + offItemLevel
        end
    end

    -- at the beginning of an arena match no info might be available,
    -- so despite having equipped gear a person may appear naked
    if total == 0 then
        return
    end

    local numItems = GW.Mists and 17 or 16
	return format("%0.2f", RoundDec(total / numItems, 2))
end
GW.CalculateAverageItemLevel = CalculateAverageItemLevel

local function GetPlayerItemLevel()
    local average, equipped, pvpItemLevel = GetAverageItemLevel()
    local averageLocal, equippedLocal, pvpItemLevelLocal
    average, equipped, pvpItemLevel = RoundDec(average, 2), RoundDec(equipped, 2), RoundDec(pvpItemLevel, 2)

    averageLocal = GW.GetLocalizedNumber(average)
    equippedLocal = GW.GetLocalizedNumber(equipped)
    pvpItemLevelLocal = GW.GetLocalizedNumber(pvpItemLevel)

    return average, equipped, pvpItemLevel, averageLocal, equippedLocal, pvpItemLevelLocal
end
GW.GetPlayerItemLevel = GetPlayerItemLevel

do
    local iLevelDB, tryAgain, slotInfo = {}, {}, nil
    local function GetUnitItemLevel(unit)
        if UnitIsUnit(unit, "player") then
            local _, equipped = GW.GetPlayerItemLevel()
            return equipped
        end

        if next(iLevelDB) then wipe(iLevelDB) end
        if next(tryAgain) then wipe(tryAgain) end

        for i = 1, 17 do
            if i ~= 4 then
                if slotInfo and type(slotInfo) == "table" then wipe(slotInfo) end
                slotInfo = GW.GetGearSlotInfo(unit, i)
                if slotInfo == "tooSoon" then
                    tinsert(tryAgain, i)
                else
                    iLevelDB[i] = slotInfo.iLvl
                end
            end
        end
        if slotInfo and type(slotInfo) == "table" then wipe(slotInfo) end

        if next(tryAgain) then
            return "tooSoon", unit, tryAgain, iLevelDB
        end

        return CalculateAverageItemLevel(iLevelDB, unit)
    end
    GW.GetUnitItemLevel = GetUnitItemLevel
end