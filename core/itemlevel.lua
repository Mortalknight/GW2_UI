local _, GW = ...
local RoundDec = GW.RoundDec

local MATCH_ITEM_LEVEL = ITEM_LEVEL:gsub("%%d", "(%%d+)")
local MATCH_ITEM_LEVEL_ALT = ITEM_LEVEL_ALT:gsub("%%d(%s?)%(%%d%)", "%%d+%1%%((%%d+)%%)")
local MATCH_ENCHANT = ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.+)")
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

local function InspectGearSlot(data, line, lineText, slotInfo)
    local enchant = strmatch(lineText, MATCH_ENCHANT)
    if enchant then
        local color1, color2 = strmatch(enchant, "(|cn.-:).-(|r)")
        local text = gsub(gsub(enchant, "%s?|A.-|a", ""), "|cn.-:(.-)|r", "%1")
        slotInfo.enchantText = format("%s%s%s", color1 or "", text, color2 or "")
        slotInfo.enchantTextShort = format("%s%s%s", color1 or "", string.utf8sub(text, 1, 18), color2 or "")
        slotInfo.enchantTextShort2 = format("%s%s%s", color1 or "", string.utf8sub(text, 1, 11), color2 or "")
        slotInfo.enchantTextReal = enchant

        if line.leftColor then
            slotInfo.enchantColors[1] = line.leftColor.r
            slotInfo.enchantColors[2] = line.leftColor.g
            slotInfo.enchantColors[3] = line.leftColor.b
        end
    end

    local itemLevel = lineText and (strmatch(lineText, MATCH_ITEM_LEVEL_ALT) or strmatch(lineText, MATCH_ITEM_LEVEL))
    if itemLevel then
        slotInfo.iLvl = tonumber(itemLevel)

        if data.lines[1].leftColor then
            slotInfo.itemLevelColors[1] = data.lines[1].leftColor.r
            slotInfo.itemLevelColors[2] = data.lines[1].leftColor.g
            slotInfo.itemLevelColors[3] = data.lines[1].leftColor.b
        end
    end
end

local function ScanTooltipTextures(data, slotInfo)
    if not slotInfo.gems then
        slotInfo.gems = {}
    else
        wipe(slotInfo.gems)
    end

    local idx = 1
    for i = 1, #data.lines do
        local texture = nil
        if data.lines[i].gemIcon then
            texture = data.lines[i].gemIcon
        end

        if texture then
            slotInfo.gems[idx] = texture
            idx = idx + 1
        end
    end
end

do
    local slotInfo = {}
    local data = nil
    local function GetGearSlotInfo(unit, slot, itemlink, deepScan)
        data = nil
        if itemlink and string.find(itemlink, "item") then
            data = C_TooltipInfo.GetHyperlink(itemlink)
        elseif slot then
            data = C_TooltipInfo.GetInventoryItem(unit, slot)
        end
        if not data then return {} end
        wipe(slotInfo)

        if deepScan then
            ScanTooltipTextures(data, slotInfo)

            if not slotInfo.enchantColors then slotInfo.enchantColors = {} else wipe(slotInfo.enchantColors) end
            if not slotInfo.itemLevelColors then slotInfo.itemLevelColors = {} else wipe(slotInfo.itemLevelColors) end

            for x = 1, #data.lines do
                local line = data.lines[x]
                if line then
                    local lineText = line.leftText
                    if lineText and x == 1 and lineText == RETRIEVING_ITEM_INFO then
                        return "tooSoon"
                    else
                        InspectGearSlot(data, line, lineText, slotInfo)
                    end
                end
            end
        else
            if data.lines[1] and data.lines[1].leftText
            and data.lines[1].leftText == RETRIEVING_ITEM_INFO then
                return "tooSoon"
            end

            local colorblind = GetCVarBool("colorblindmode") and 4 or 3
            for x = 2, colorblind do
                if data.lines[x] then
                    local line = data.lines[x].leftText
                    if line then
                        local itemLevel = line and (strmatch(line, MATCH_ITEM_LEVEL_ALT) or strmatch(line, MATCH_ITEM_LEVEL))
                        if itemLevel then
                            slotInfo.iLvl = tonumber(itemLevel)
                        end
                    end
                end
            end
        end
        if next(data) then wipe(data) end
        return slotInfo
    end
    GW.GetGearSlotInfo = GetGearSlotInfo
end

local function CalculateAverageItemLevel(iLevelDB, unit)
    local spec = GetInspectSpecialization(unit)
    local isOK, total, link = true, 0, nil

    if not spec or spec == 0 then
        isOK = false
    end

    -- Armor
    for _, id in next, ARMOR_SLOTS do
        link = GetInventoryItemLink(unit, id)
        if link then
            local cur = iLevelDB[id]
            if cur and cur > 0 then
                total = total + cur
            end
        elseif GetInventoryItemTexture(unit, id) then
            isOK = false
        end
    end

    -- Main hand
    local mainItemLevel, mainQuality, mainEquipLoc, mainItemClass, mainItemSubClass = 0, nil, nil, nil, nil
    link = GetInventoryItemLink(unit, 16)
    if link then
        mainItemLevel = iLevelDB[16]
        _, _, mainQuality, _, _, _, _, _, mainEquipLoc, _, _, mainItemClass, mainItemSubClass = C_Item.GetItemInfo(link)
    elseif GetInventoryItemTexture(unit, 16) then
        isOK = false
    end

    -- Off hand
    local offItemLevel, offEquipLoc = 0, nil
    link = GetInventoryItemLink(unit, 17)
    if link then
        offItemLevel = iLevelDB[17]
        _, _, _, _, _, _, _, _, offEquipLoc = C_Item.GetItemInfo(link)
    elseif GetInventoryItemTexture(unit, 17) then
        isOK = false
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
        isOK = false
    end

    return isOK and format("%0.2f", RoundDec(total / 16, 2))
end
GW.CalculateAverageItemLevel = CalculateAverageItemLevel

do
    local iLevelDB, tryAgain, slotInfo = {}, {}, nil
    local function GetUnitItemLevel(unit)
        if UnitIsUnit(unit, "player") then
            return format("%0.2f", RoundDec((select(2, GetAverageItemLevel())), 2))
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