---@class GW2
local GW = select(2, ...)

local LineType = Enum.TooltipDataLineType
local ENCHANT_PATTERN = gsub(ENCHANTED_TOOLTIP_LINE, "%%s", "(.+)")
local EMPTY_SOCKET = "Interface\\ItemSocketingFrame\\UI-EmptySocket-%s"
local SHORT_ENCHANT_LENGTH = 11
local AVERAGE_SLOTS = 16
-- the slots of the average, the shirt (4) does not count
local GEAR_SLOTS = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17}
local TWO_HANDED = {INVTYPE_2HWEAPON = true, INVTYPE_RANGED = true, INVTYPE_RANGEDRIGHT = true}
local GetItemInfoInstant = C_Item.GetItemInfoInstant or GetItemInfoInstant

function GW.PopulateUnitIlvlsCache(unitGUID, itemLevel, tooltip)
    if not itemLevel then
        return
    end
    local cached = GW.unitIlvlsCache[unitGUID]
    if cached then
        cached.time = GetTime()
        cached.itemLevel = itemLevel
    end
    if tooltip then
        GameTooltip.ItemLevelShown = true
        GameTooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL .. ":", itemLevel, nil, nil, nil, 1, 1, 1)
        GameTooltip:Show()
    end
end

-- "Item Level 480 (489)": the number in brackets is the one that counts right now
local function ReadItemLevel(text)
    return tonumber(strmatch(text, "%((%d+)%)") or strmatch(text, "(%d+)"))
end

-- "Enchanted: <color>Name|r <quality icon>": only the name gets shortened, color and icon stay
local function ReadEnchant(text)
    local enchant = strmatch(text, ENCHANT_PATTERN) or text
    local icon = strmatch(enchant, "%s?|A.-|a") or ""
    local colorStart, colorEnd = strmatch(enchant, "(|cn.-:).-(|r)")
    local name = gsub(gsub(enchant, "%s?|A.-|a", ""), "|cn.-:(.-)|r", "%1")
    colorStart, colorEnd = colorStart or "", colorEnd or ""
    return colorStart .. name .. colorEnd .. icon, colorStart .. string.utf8sub(name, 1, SHORT_ENCHANT_LENGTH) .. colorEnd .. icon
end

local function GetTooltipData(unit, slot, itemLink)
    if GW.NotSecretValue(itemLink) and itemLink and strfind(itemLink, "item", 1, true) then
        return C_TooltipInfo.GetHyperlink(itemLink)
    elseif slot then
        return C_TooltipInfo.GetInventoryItem(unit, slot)
    end
end

--[[
    What the tooltip of an equipped item says about it, read from its typed lines:
        iLvl, itemLevelColors {r, g, b}, enchantText, enchantTextShort2, enchantColors {r, g, b},
        gems (gem icons, or the empty socket art), isSetItem
    "tooSoon" while the item data is still on its way; an empty slot gives an empty table.
]]
local function GetGearSlotInfo(unit, slot, itemLink)
    local slotInfo = {gems = {}, enchantColors = {}, itemLevelColors = {}}
    local link = itemLink or (slot and GetInventoryItemLink(unit, slot))
    if GW.IsSecretValue(link) then
        return slotInfo
    end

    local data = GetTooltipData(unit, slot, itemLink)
    local lines = data and data.lines
    local firstText = lines and lines[1] and lines[1].leftText
    if GW.IsSecretValue(firstText) or not firstText or firstText == RETRIEVING_ITEM_INFO then
        return link and "tooSoon" or slotInfo
    end

    if lines[1].leftColor then
        slotInfo.itemLevelColors[1], slotInfo.itemLevelColors[2], slotInfo.itemLevelColors[3] = lines[1].leftColor:GetRGB()
    end

    for _, line in ipairs(lines) do
        local text = line.leftText
        if GW.NotSecretValue(text) and text then
            if line.type == LineType.ItemLevel then
                slotInfo.iLvl = ReadItemLevel(text)
            elseif line.type == LineType.ItemEnchantmentPermanent then
                slotInfo.enchantText, slotInfo.enchantTextShort2 = ReadEnchant(text)
                if line.leftColor then
                    slotInfo.enchantColors[1], slotInfo.enchantColors[2], slotInfo.enchantColors[3] = line.leftColor:GetRGB()
                end
            elseif line.type == LineType.GemSocket then
                tinsert(slotInfo.gems, line.gemIcon or (line.socketType and format(EMPTY_SOCKET, line.socketType)))
            end
        end
    end

    -- classic style tooltips name no item level, the link knows it, the quality gives the color
    if link then
        local _, _, quality, _, _, _, _, _, _, _, _, _, _, _, _, setID = C_Item.GetItemInfo(link)
        slotInfo.isSetItem = setID ~= nil
        if not slotInfo.iLvl then
            slotInfo.iLvl = C_Item.GetDetailedItemLevelInfo(link)
            if quality then
                slotInfo.itemLevelColors[1], slotInfo.itemLevelColors[2], slotInfo.itemLevelColors[3] = C_Item.GetItemQualityColor(quality)
            end
        end
    end

    return slotInfo
end
GW.GetGearSlotInfo = GetGearSlotInfo

-- wands sit in the ranged slot but are one handed
local function IsTwoHanded(link)
    local _, _, _, equipLoc, _, classID, subClassID = GetItemInfoInstant(link)
    local isWand = Enum.ItemWeaponSubclass and classID == Enum.ItemClass.Weapon and subClassID == Enum.ItemWeaponSubclass.Wand
    return TWO_HANDED[equipLoc] and not isWand
end

-- the average over 16 slots like blizzard counts it: a two hander without off hand counts twice;
-- nil while an equipped item is still unknown or nothing is known at all
local function CalculateAverageItemLevel(itemLevels, unit)
    local total, hasOffHand = 0, false
    for _, slot in ipairs(GEAR_SLOTS) do
        local link, texture = GetInventoryItemLink(unit, slot), GetInventoryItemTexture(unit, slot)
        if GW.IsSecretValue(link) or GW.IsSecretValue(texture) then
            return
        elseif link then
            total = total + (itemLevels[slot] or 0)
            hasOffHand = hasOffHand or slot == 17
        elseif texture then
            return
        end
    end

    local mainHand = GetInventoryItemLink(unit, 16)
    if mainHand and not hasOffHand and IsTwoHanded(mainHand) then
        total = total + (itemLevels[16] or 0)
    end

    if total > 0 then
        return format("%0.2f", GW.RoundDec(total / AVERAGE_SLOTS, 2))
    end
end
GW.CalculateAverageItemLevel = CalculateAverageItemLevel

function GW.GetPlayerItemLevel()
    local average, equipped, pvp = GetAverageItemLevel()
    average, equipped, pvp = GW.RoundDec(average, 2), GW.RoundDec(equipped, 2), GW.RoundDec(pvp, 2)
    return average, equipped, pvp, GW.GetLocalizedNumber(average), GW.GetLocalizedNumber(equipped), GW.GetLocalizedNumber(pvp)
end

-- the average item level of an inspected unit; "tooSoon", unit, missing slots and the levels so far
-- while item data is still loading, the caller asks for the missing slots again
function GW.GetUnitItemLevel(unit)
    if GW.UnitIsUnit(unit, "player") then
        local _, equipped = GW.GetPlayerItemLevel()
        return equipped
    end

    local itemLevels, missing = {}, {}
    for _, slot in ipairs(GEAR_SLOTS) do
        local slotInfo = GetGearSlotInfo(unit, slot)
        if slotInfo == "tooSoon" then
            tinsert(missing, slot)
        else
            itemLevels[slot] = slotInfo.iLvl
        end
    end

    if #missing > 0 then
        return "tooSoon", unit, missing, itemLevels
    end
    return CalculateAverageItemLevel(itemLevels, unit)
end
