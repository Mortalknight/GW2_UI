local _, GW = ...
local RoundDec = GW.RoundDec

local inspectColorFallback = {1, 1, 1}

local ITEM_SPELL_TRIGGER_ONEQUIP = ITEM_SPELL_TRIGGER_ONEQUIP
local ESSENCE_DESCRIPTION = GetSpellDescription(277253)

local MATCH_ITEM_LEVEL = ITEM_LEVEL:gsub("%%d", "(%%d+)")
local MATCH_ITEM_LEVEL_ALT = ITEM_LEVEL_ALT:gsub("%%d(%s?)%(%%d%)", "%%d+%1%%((%%d+)%%)")
local MATCH_ENCHANT = ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.+)")
local X2_INVTYPES, X2_EXCEPTIONS, ARMOR_SLOTS = {
    INVTYPE_2HWEAPON = true,
    INVTYPE_RANGEDRIGHT = true,
    INVTYPE_RANGED = true,
    }, {
        [2] = 19, -- wands, use INVTYPE_RANGEDRIGHT, but are 1H
    }, {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}

local essenceTextureID = 2975691
local iLevelDB, tryAgain = {}, {}


local function _GetSpecializationInfo(unit, isPlayer)
    local spec = (isPlayer and GetSpecialization()) or (unit and GetInspectSpecialization(unit))
    if spec and spec > 0 then
        if isPlayer then
            return select(2, GetSpecializationInfo(spec))
        else
            return select(2, GetSpecializationInfoByID(spec))
        end
    end
end
GW._GetSpecializationInfo = _GetSpecializationInfo

local function PopulateUnitIlvlsCache(unitGUID, itemLevel, target, tooltip)
    local specName = _GetSpecializationInfo(target)
    if specName and itemLevel then
        if GW.unitIlvlsCache[unitGUID] then
            GW.unitIlvlsCache[unitGUID].time = GetTime()
            GW.unitIlvlsCache[unitGUID].itemLevel = itemLevel
            GW.unitIlvlsCache[unitGUID].specName = specName
        end

        if tooltip then
            GameTooltip:AddDoubleLine(SPECIALIZATION .. ":", specName, nil, nil, nil, unpack((GW.unitIlvlsCache[unitGUID].unitColor) or inspectColorFallback))
            GameTooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL .. ":", itemLevel, nil, nil, nil, 1, 1, 1)
            GameTooltip:Show()
        end
    end
end
GW.PopulateUnitIlvlsCache = PopulateUnitIlvlsCache

local function InspectGearSlot(line, lineText, slotInfo)
    local enchant = strmatch(lineText, MATCH_ENCHANT)
    if enchant then
        slotInfo.enchantText = enchant
        slotInfo.enchantTextShort = strsub(enchant, 1, 18)

        local lr, lg, lb = line:GetTextColor()
        slotInfo.enchantColors[1] = lr
        slotInfo.enchantColors[2] = lg
        slotInfo.enchantColors[3] = lb
    end

    local itemLevel = lineText and (strmatch(lineText, MATCH_ITEM_LEVEL_ALT) or strmatch(lineText, MATCH_ITEM_LEVEL))
    if itemLevel then
        slotInfo.iLvl = tonumber(itemLevel)

        local tr, tg, tb = _G.GW2_UI_ScanTooltipTextLeft1:GetTextColor()
        slotInfo.itemLevelColors[1] = tr
        slotInfo.itemLevelColors[2] = tg
        slotInfo.itemLevelColors[3] = tb
    end
end

local function CollectEssenceInfo(index, lineText, slotInfo)
    local step = 1
    local essence = slotInfo.essences[step]
    if essence and next(essence) and (strfind(lineText, ITEM_SPELL_TRIGGER_ONEQUIP, nil, true) and strfind(lineText, ESSENCE_DESCRIPTION, nil, true)) then
        for i = 5, 2, -1 do
            local line = _G["GW2_UI_ScanTooltipTextLeft"..index - i]
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

local function ScanTooltipTextures()
    local tt = GW2_UI_ScanTooltip or CreateFrame("GameTooltip", "GW2_UI_ScanTooltip", UIParent, "GameTooltipTemplate")

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
        local tex = _G["GW2_UI_ScanTooltipTexture" .. i]
        local texture = tex and tex:IsShown() and tex:GetTexture()
        if texture then
            if texture == essenceTextureID then
                local selected = (tt.gems[i-1] ~= essenceTextureID and tt.gems[i-1]) or nil
                if not tt.essences[step] then tt.essences[step] = {} end

                tt.essences[step][1] = selected            --essence texture if selected or nil
                tt.essences[step][2] = tex:GetAtlas()    --atlas place "tooltip-heartofazerothessence-major" or "tooltip-heartofazerothessence-minor"
                tt.essences[step][3] = texture            --border texture placed by the atlas
                --`CollectEssenceInfo` will add 4 (hex quality color) and 5 (essence name)

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

local function GetGearSlotInfo(unit, slot, deepScan)
    local tt = GW2_UI_ScanTooltip or CreateFrame("GameTooltip", "GW2_UI_ScanTooltip", UIParent, "GameTooltipTemplate")
    tt:SetOwner(UIParent, "ANCHOR_NONE")
    tt:SetInventoryItem(unit, slot)
    tt:Show()

    if not tt.slotInfo then tt.slotInfo = {} else wipe(tt.slotInfo) end
    local slotInfo = tt.slotInfo

    if deepScan then
        slotInfo.gems, slotInfo.essences = ScanTooltipTextures()

        if not tt.enchantColors then tt.enchantColors = {} else wipe(tt.enchantColors) end
        if not tt.itemLevelColors then tt.itemLevelColors = {} else wipe(tt.itemLevelColors) end
        slotInfo.enchantColors = tt.enchantColors
        slotInfo.itemLevelColors = tt.itemLevelColors

        for x = 1, tt:NumLines() do
            local line = _G["GW2_UI_ScanTooltipTextLeft" .. x]
            if line then
                local lineText = line:GetText()
                if x == 1 and lineText == RETRIEVING_ITEM_INFO then
                    return "tooSoon"
                else
                    InspectGearSlot(line, lineText, slotInfo)
                    CollectEssenceInfo(x, lineText, slotInfo)
                end
            end
        end
    else
        local firstLine = _G.GW2_UI_ScanTooltipTextLeft1:GetText()
        if firstLine == RETRIEVING_ITEM_INFO then
            return "tooSoon"
        end

        local colorblind = GetCVarBool("colorblindmode") and 4 or 3
        for x = 2, colorblind do
            local line = _G["GW2_UI_ScanTooltipTextLeft"..x]
            if line then
                local lineText = line:GetText()
                local itemLevel = lineText and (strmatch(lineText, MATCH_ITEM_LEVEL_ALT) or strmatch(lineText, MATCH_ITEM_LEVEL))
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

local function CalculateAverageItemLevel(iLevelDB, unit)
    local spec = GetInspectSpecialization(unit)
    local isOK, total, link = true, 0

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
    local mainItemLevel, mainQuality, mainEquipLoc, mainItemClass, mainItemSubClass, _ = 0
    link = GetInventoryItemLink(unit, 16)
    if link then
        mainItemLevel = iLevelDB[16]
        _, _, mainQuality, _, _, _, _, _, mainEquipLoc, _, _, mainItemClass, mainItemSubClass = GetItemInfo(link)
    elseif GetInventoryItemTexture(unit, 16) then
        isOK = false
    end

    -- Off hand
    local offItemLevel, offEquipLoc = 0
    link = GetInventoryItemLink(unit, 17)
    if link then
        offItemLevel = iLevelDB[17]
        _, _, _, _, _, _, _, _, offEquipLoc = GetItemInfo(link)
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

local function GetUnitItemLevel(unit)
    if UnitIsUnit("player", unit) then
        return format("%0.2f", RoundDec((select(2, GetAverageItemLevel())), 2))
    end

    if next(iLevelDB) then wipe(iLevelDB) end
    if next(tryAgain) then wipe(tryAgain) end

    for i = 1, 17 do
        if i ~= 4 then
            local slotInfo = GetGearSlotInfo(unit, i)
            if slotInfo == "tooSoon" then
                tinsert(tryAgain, i)
            else
                iLevelDB[i] = slotInfo.iLvl
            end
        end
    end

    if next(tryAgain) then
        return "tooSoon", unit, tryAgain, iLevelDB
    end

    return CalculateAverageItemLevel(iLevelDB, unit)
end
GW.GetUnitItemLevel = GetUnitItemLevel