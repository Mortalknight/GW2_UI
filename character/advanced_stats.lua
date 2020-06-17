local _, GW = ...
local L = GW.L
local RoundDec = GW.RoundDec
local ClassIndex = GW.ClassIndex

local lastManaReg = 0

local CHAR_EQUIP_SLOTS = {
    ["Head"] = "HeadSlot",
    ["Neck"] = "NeckSlot",
    ["Shoulder"] = "ShoulderSlot",
    ["Back"] = "BackSlot",
    ["Chest"] = "ChestSlot",
    ["Shirt"] = "ShirtSlot",
    ["Tabard"] = "TabardSlot",
    ["Wrist"] = "WristSlot",
    ["Hands"] = "HandsSlot",
    ["Wairst"] = "WaistSlot",
    ["Legs"] = "LegsSlot",
    ["Feet"] = "FeetSlot",
    ["Finger1"] = "Finger0Slot",
    ["Finger2"] = "Finger1Slot",
    ["Trinket1"] = "Trinket0Slot",
    ["Trinket2"] = "Trinket1Slot",
    ["MainHand"] = "MainHandSlot",
    ["OffHand"]  = "SecondaryHandSlot",
    ["Range"] = "RangedSlot",
}

local itemSets = {
    ["Stormrage Raiment"] = {
        [16899] = true,
        [16900] = true,
        [16901] = true,
        [16902] = true,
        [16903] = true,
        [16904] = true,
        [16897] = true,
        [16898] = true
    },
    ["Vestments of Transcendence"] = {
        [16919] = true,
        [16920] = true,
        [16921] = true,
        [16922] = true,
        [16923] = true,
        [16924] = true,
        [16925] = true,
        [16926] = true
    },
    ["Haruspex's Garb"] = {
        [19613] = true,
        [19955] = true,
        [19840] = true,
        [19839] = true,
        [19838] = true
    },
    ["Augur's Regalia"] = {
        [19609] = true,
        [19956] = true,
        [19830] = true,
        [19829] = true,
        [19828] = true
    },
    ["Freethinker's Armor"] = {
        [19952] = true,
        [19588] = true,
        [19827] = true,
        [19826] = true,
        [19825] = true
    }
}

local function IsSetBonusActive(setname, bonusLevel)
    local set = itemSets[setname]
    if not set then return false end
    
    local pieces_equipped = 0
    for slot = 1, 17 do
        local itemID = GetInventoryItemID("player", slot)
        if set[itemID] then pieces_equipped = pieces_equipped + 1 end
    end
    return (pieces_equipped >= bonusLevel)
end

local function _IsRangeAttackClass()
    return GW.myClassID == ClassIndex.WARRIOR or GW.myClassID == ClassIndex.ROGUE or GW.myClassID == ClassIndex.HUNTER
end

local function _IsShapeshifted()
    for i = 0, 40 do
        local _, _, _, _, _, _, _, _, _, spellId, _ = UnitAura("player", i, "HELPFUL", "PLAYER")
        if spellId == 5487 or spellId == 9634 or spellId == 768 then
            return true
        end
    end
    return false
end

local function _GetMissChanceByDifference(weaponSkill, defenseValue)
    if (defenseValue - weaponSkill) <= 10 then
        return 5 + (defenseValue - weaponSkill) * 0.1
    else
        return 7 + (defenseValue - weaponSkill - 10) * 0.4
    end
end

local function _GetRangeHitBonus()
    local hitValue = 0
    -- From Enchant
    local slotId, _ = GetInventorySlotInfo(CHAR_EQUIP_SLOTS["Range"])
    local itemLink = GetInventoryItemLink("player", slotId)
    if itemLink then
        local _, itemStringLink = GetItemInfo(itemLink)
        if itemStringLink then
            local _, _, _, _, _, Enchant, _, _, _, _, _, _, _, _ = string.find(itemStringLink,
            "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
            if (Enchant == "2523") then -- 3% Hit from Biznicks 247x128 Accurascope
                hitValue = hitValue + 3
            end
        end
    end
    -- From Items
    local hitFromItems = GetHitModifier()
    if hitFromItems then -- This needs to be checked because on dungeon entering it becomes nil
        hitValue = hitValue + hitFromItems
    end

    return hitValue
end

local function _GetTalentModifierDefense()
    local mod = 0

    if GW.myClassID == ClassIndex.WARRIOR then
        local _, _, _, _, points = GetTalentInfo(3, 2)
        mod = points * 2 -- 0-10 Anticipation
    end

    return mod
end
GW.stats._GetTalentModifierDefense = _GetTalentModifierDefense

local function _GetTalentModifierMP5()
    local mod = 0

    if GW.myClassID == ClassIndex.PRIEST then
        local _, _, _, _, points = GetTalentInfo(1, 8)
        mod = points * 0.05 -- 0-15% from Meditation
    elseif GW.myClassID == ClassIndex.MAGE then
        local _, _, _, _, points= GetTalentInfo(1, 12)
        mod = points * 0.05 -- 0-15% Arcane Meditation
    elseif GW.myClassID == ClassIndex.DRUID then
        local _, _, _, _, points = GetTalentInfo(3, 6)
        mod = points * 0.05 -- 0-15% from Reflection
    end

    return mod
end

local function _HasSetBonusModifierMP5()
    if GW.myClassID == ClassIndex.PRIEST then
        return IsSetBonusActive("Vestments of Transcendence", 3)
    elseif GW.myClassID == ClassIndex.DRUID then
        return IsSetBonusActive("Stormrage Raiment", 3)
    end

    return false
end

local function GetSetBonusValueMP5()
    if (GW.myClassID == ClassIndex.DRUID and IsSetBonusActive("Haruspex's Garb", 2))
        or (GW.myClassID == ClassIndex.SHAMAN and IsSetBonusActive("Augur's Regalia", 2))
        or (GW.myClassID == ClassIndex.PALADIN and IsSetBonusActive("Freethinker's Armor", 2)) then
        return 4
    end
    return 0
end

local function _GetTalentModifierHolyCrit()
    local mod = 0

    if GW.myClassID == ClassIndex.PALADIN then -- Paladin
        local _, _, _, _, points = GetTalentInfo(1, 13)
        mod = points * 1 -- 0-5% Holy Power
    elseif GW.myClassID == ClassIndex.PRIEST then -- Priest
        local _, _, _, _, points = GetTalentInfo(2, 3)
        mod = points * 1 -- 0-5% Holy Specialization
    end

    return mod
end

local function _GetTalentModifierSpellCrit()
    local mod = 0

    if GW.myClassID == ClassIndex.MAGE then -- Mage
        local _, _, _, _, points = GetTalentInfo(1, 15)
        mod = points * 1 -- 0-3% Arcane Instability
    end

    return mod
end

local function _GetTalentModifierSpellHit()
    local mod = 0

    if GW.myClassID == ClassIndex.PRIEST then -- Priest
        local _, _, _, _, points = GetTalentInfo(3, 5)
        mod = points * 2 -- 0-10% from Shadow Focus
    elseif GW.myClassID == ClassIndex.MAGE then -- Mage
        local _, _, _, _, points = GetTalentInfo(3, 3)
        mod = points * 2 -- 0-6% from Elemental Precision
    end

    return mod
end

local function _GetMP5ValueOnItems() 
    local mp5 = 0
    for i = 1, 17 do
        local itemLink = GetInventoryItemLink("player", i)
        if itemLink then
            local stats = GetItemStats(itemLink)
            if stats then
                local statMP5 = stats["ITEM_MOD_POWER_REGEN0_SHORT"]
                if statMP5 then
                    mp5 = mp5 + statMP5 + 1
                end
            end
        end
    end

    return mp5
end

-- Get MP5 from spirit
local function GetMP5FromSpirit()
    local base, _ = GetManaRegen() -- Returns mana reg per 1 second
    if base < 1 then
        base = lastManaReg
    end
    lastManaReg = base
    return RoundDec(base, 0) * 5
end

-- Get MP5 from items
local function GetMP5FromItems()
    local mp5 = _GetMP5ValueOnItems()
    mp5 = mp5 + GetSetBonusValueMP5()

    return mp5
end

-- Get manaregen while casting
local function GetMP5WhileCasting()
    local _, casting = GetManaRegen() -- Returns mana reg per 1 second
    if casting < 1 then
        casting = lastManaReg
    end
    lastManaReg = casting

    local mod = _GetTalentModifierMP5()
    if _HasSetBonusModifierMP5() then
        mod = mod + 0.15
    end
    if mod > 0 then
        casting = casting * mod
    end

    local mp5Items = GetMP5FromItems()
    casting = (casting * 5) + mp5Items

    return RoundDec(casting, 2)
end

-- Get holy crit chance
local function HolyCrit()
    local spellCrit = _GetTalentModifierSpellCrit()
    local talentModifier = _GetTalentModifierHolyCrit()
    spellCrit = spellCrit + talentModifier + GetSpellCritChance(2)
    return RoundDec(spellCrit, 2) .. "%"
end

local function SpellCrit()
    local crit = _GetTalentModifierSpellCrit()
    crit = crit + GetSpellCritChance()
    return RoundDec(crit, 2) .. "%"
end

local function MeleeHitMissChanceSameLevel()
    local mainBase, mainMod, _, _ = UnitAttackBothHands("player")
    local enemyDefenseValue = GW.mylevel * 5

    local missChance = 0
    if _IsShapeshifted() then
        missChance = 6
    else
        missChance = _GetMissChanceByDifference(mainBase + mainMod, enemyDefenseValue)
    end

    local hitFromItems = GetHitModifier()
    if hitFromItems then -- This needs to be checked because on dungeon entering it becomes nil
        missChance = missChance - hitFromItems
    end

    missChance = Clamp(missChance, 0, 100)

    return RoundDec(missChance, 2) .. "%"
end

local function MeleeHitMissChanceBossLevel()
    local mainBase, mainMod, _, _ = UnitAttackBothHands("player")
    local enemyDefenseValue = (GW.mylevel + 3) * 5

    local missChance = 0
    if _IsShapeshifted() then
        missChance = 9
    else
        missChance = _GetMissChanceByDifference(mainBase + mainMod, enemyDefenseValue)
    end

    local hitFromItems = GetHitModifier()
    if hitFromItems then -- This needs to be checked because on dungeon entering it becomes nil
        missChance = missChance - hitFromItems
    end

    missChance = Clamp(missChance, 0, 100)

    return RoundDec(missChance, 2) .. "%"
end

local function RangeHitBonus()
    return RoundDec(_GetRangeHitBonus(), 2) .. "%"
end

local function RangeMissChanceSameLevel()
    local rangedAttackBase, rangedAttackMod = UnitRangedAttack("player")
    local enemyDefenseValue = GW.mylevel * 5

    local missChance = _GetMissChanceByDifference(rangedAttackBase + rangedAttackMod, enemyDefenseValue)
    missChance = missChance - _GetRangeHitBonus()

    missChance = Clamp(missChance, 0, 100)

    return RoundDec(missChance, 2) .. "%"
end

-- Gets the range hit chance against enemies 3 level above the player level
local function RangeMissChanceBossLevel()
    local rangedAttackBase, rangedAttackMod = UnitRangedAttack("player")
    local enemyDefenseValue = (GW.mylevel + 3) * 5

    local missChance = _GetMissChanceByDifference(rangedAttackBase + rangedAttackMod, enemyDefenseValue)
    missChance = missChance - _GetRangeHitBonus()
    
    missChance = Clamp(missChance, 0, 100)

    return RoundDec(missChance, 2) .. "%"
end

local function SpellHitBonus()
    local hit = _GetTalentModifierSpellHit()
    hit = hit + GetSpellHitModifier()

    return RoundDec(hit, 2) .. "%"
end

local function SpellMissChanceSameLevel()
    local missChance = 3

    missChance = missChance - _GetTalentModifierSpellHit()
    local mod = GetSpellHitModifier()
    if mod then
        missChance = missChance - mod
    end

    missChance = Clamp(missChance, 0, 100)

    return RoundDec(missChance, 2) .. "%"
end

local function SpellMissChanceBossLevel()
    local missChance = 16

    missChance = missChance - _GetTalentModifierSpellHit()
    local mod = GetSpellHitModifier()
    if mod then
        missChance = missChance - mod
    end

    missChance = Clamp(missChance, 0, 100)

    return RoundDec(missChance, 2) .. "%"
end

local function GetBlockValue()
    return RoundDec(GetShieldBlock(), 2)
end

local function PhysicalCrit()
    local spellCrit = _GetTalentModifierSpellCrit()
    spellCrit = spellCrit + GetSpellCritChance(1)

    return RoundDec(spellCrit, 2) .. "%"
end

local function FireCrit()
    local spellCrit = _GetTalentModifierSpellCrit()
    spellCrit = spellCrit + GetSpellCritChance(3)

    return RoundDec(spellCrit, 2) .. "%"
end

local function NatureCrit()
    local spellCrit = _GetTalentModifierSpellCrit()
    spellCrit = spellCrit + GetSpellCritChance(4)

    return RoundDec(spellCrit, 2) .. "%"
end

local function FrostCrit()
    local spellCrit = _GetTalentModifierSpellCrit()
    spellCrit = spellCrit + GetSpellCritChance(5)

    return RoundDec(spellCrit, 2) .. "%"
end

local function ShadowCrit()
    local spellCrit = _GetTalentModifierSpellCrit()
    spellCrit = spellCrit + GetSpellCritChance(6)

    return RoundDec(spellCrit, 2) .. "%"
end

local function ArcaneCrit()
    local spellCrit = _GetTalentModifierSpellCrit()
    spellCrit = spellCrit + GetSpellCritChance(7)

    return RoundDec(spellCrit, 2) .. "%"
end

local function GetMeleeAttackPower()
    local melee, posBuff, negBuff = UnitAttackPower("player")
    return melee + posBuff + negBuff
end

local function GetRangeAttackPower()
    if not _IsRangeAttackClass() then
        return 0
    end

    local melee, posBuff, negBuff = UnitRangedAttackPower("player")
    return melee + posBuff + negBuff
end


local function showAdvancedChatStats(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

    GameTooltip:SetText(ADVANCED_LABEL .. " " .. STAT_CATEGORY_ATTRIBUTES) 
    GameTooltip:AddLine(" ")

    GameTooltip:AddLine(MELEE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. MELEE_CRIT_CHANCE .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetCritChance()) .."%" .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. ITEM_MOD_HIT_MELEE_RATING_SHORT .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetHitModifier()) .."%" .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. ATTACK_POWER_TOOLTIP .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. GetMeleeAttackPower() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   Miss-Chance:" .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. MeleeHitMissChanceSameLevel() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   Miss-Chance (Level + 3):" .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. MeleeHitMissChanceBossLevel() .. FONT_COLOR_CODE_CLOSE)
    
    if _IsRangeAttackClass() then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(RANGED)
        GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. RANGED_CRIT_CHANCE .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetRangedCritChance()) .."%" .. FONT_COLOR_CODE_CLOSE)
        GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. ITEM_MOD_HIT_RANGED_RATING_SHORT .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. RangeHitBonus() .. FONT_COLOR_CODE_CLOSE)
        GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. RANGED_ATTACK_TOOLTIP .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. GetRangeAttackPower() .. FONT_COLOR_CODE_CLOSE)
        GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   Miss-Chance:" .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. RangeMissChanceSameLevel() .. FONT_COLOR_CODE_CLOSE)
        GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   Miss-Chance (Level + 3):" .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. RangeMissChanceBossLevel() .. FONT_COLOR_CODE_CLOSE)
    end
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(DEFENSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. BLOCK_CHANCE .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetBlockChance()) .."%" .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. ITEM_MOD_BLOCK_VALUE_SHORT .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. GetBlockValue() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. PARRY_CHANCE .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetParryChance()) .."%" .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DODGE_CHANCE .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetDodgeChance()) .."%" .. FONT_COLOR_CODE_CLOSE)

    if UnitPowerType("player") == 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(MANA_REGEN)
        GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. ITEM_MOD_POWER_REGEN0_SHORT .. " (" .. HELPFRAME_ITEM_TITLE .. "):" .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetMP5FromItems()) .. FONT_COLOR_CODE_CLOSE)
        GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. ITEM_MOD_POWER_REGEN0_SHORT .. " (" .. PLAYERSTAT_SPELL_COMBAT .. "): " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetMP5WhileCasting()) .. FONT_COLOR_CODE_CLOSE)
        GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. ITEM_MOD_POWER_REGEN0_SHORT .. " (" .. ITEM_MOD_SPIRIT_SHORT .. "): " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetMP5FromSpirit()) .. FONT_COLOR_CODE_CLOSE)
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(STAT_CATEGORY_SPELL)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. SPELL_CRIT_CHANCE .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. SpellCrit() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. ITEM_MOD_HIT_SPELL_RATING_SHORT .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. SpellHitBonus() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   Miss-Chance:" .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. SpellMissChanceSameLevel() .. FONT_COLOR_CODE_CLOSE)
        GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   Miss-Chance (Level + 3):" .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. SpellMissChanceBossLevel() .. FONT_COLOR_CODE_CLOSE)
    

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(SPELL_BONUS)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. BONUS_HEALING .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellBonusHealing()) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL6 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellBonusDamage(6)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL6 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. ShadowCrit().. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL2 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellBonusDamage(2)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL2 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. HolyCrit() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL3 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellBonusDamage(3)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL3 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. FireCrit() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL5 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellBonusDamage(5)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL5 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. FrostCrit() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL7 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellBonusDamage(7)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL7 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. ArcaneCrit() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL4 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellBonusDamage(4)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL4 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. NatureCrit() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. STRING_SCHOOL_PHYSICAL .. " " .. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellBonusDamage(1)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. STRING_SCHOOL_PHYSICAL .. " " .. CRIT_ABBR .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. PhysicalCrit() .. FONT_COLOR_CODE_CLOSE)

    GameTooltip:Show()
end
GW.showAdvancedChatStats = showAdvancedChatStats
