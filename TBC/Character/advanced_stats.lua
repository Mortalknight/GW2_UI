local _, GW = ...
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

local enchants = {
    Biznick = 2523, --3% Hit from Biznick
    Bracer_Mana_Reg = 2565,-- 4 MP5
    PROPHETIC_AURA = 2590, -- 4 MP5 for priest ZG Enchant
    BRILLIANT_MANA_OIL = 2629, -- 12 MP5
    LESSER_MANA_OIL = 2625, -- 8 MP5
    MINOR_MANA_OIL = 2624, -- 4 MP5
}

local schools = {
    physical = 1,
    holy = 2,
    fire = 3,
    nature = 4,
    frost = 5,
    shadow = 6,
    arcane = 7
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
    },
    ["The Ten Storms"] = {
        [16944] = true,
        [16943] = true,
        [16950] = true,
        [16945] = true,
        [16948] = true,
        [16949] = true,
        [16947] = true,
        [16946] = true
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
    for i = 1, 40 do
        local _, _, _, _, _, _, _, _, _, spellId, _ = UnitAura("player", i, "HELPFUL", "PLAYER")
        if not spellId then break end
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
        return min(8, 6 + (defenseValue - weaponSkill) * 0.2)
    end
end

local function GetEnchantFromItemLink(itemLink)
    if not itemLink then return nil end

    local _, itemStrLink = C_Item.GetItemInfo(itemLink)
    if itemStrLink then
        local _, _, enchant = strfind(itemStrLink, "item:%d+:(%d*)")
        return tonumber(enchant)
    end
end

local function GetEnchantForEquipSlot(slot)
    local slotID = GetInventorySlotInfo(slot)
    local itemLink = GetInventoryItemLink("player", slotID)

    return GetEnchantFromItemLink(itemLink)
end

local function _GetRangeHitBonus()
    local hitValue = 0

    -- From Enchant
    local rangedEnchant = GetEnchantForEquipSlot(CHAR_EQUIP_SLOTS["Range"])
    if rangedEnchant and rangedEnchant == enchants.Biznick then
        hitValue = hitValue + 3
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
        local talentInfoQuery = {}
        talentInfoQuery.isInspect = false
        talentInfoQuery.isPet = false
        talentInfoQuery.groupIndex = GW.GetTalentSpec()
        talentInfoQuery.specializationIndex = 3
		talentInfoQuery.talentIndex = 2
        local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
        if talentInfo then
            mod = talentInfo.rank * 2 -- 0-10 Anticipation
        end
    end

    return mod
end
GW.stats._GetTalentModifierDefense = _GetTalentModifierDefense

local function _GetTalentModifierMP5()
    local mod = 0
    local talentInfoQuery = {}
    talentInfoQuery.isInspect = false
    talentInfoQuery.isPet = false
    talentInfoQuery.groupIndex = GW.GetTalentSpec()

    if GW.myClassID == ClassIndex.PRIEST then
        talentInfoQuery.specializationIndex = 1
		talentInfoQuery.talentIndex = 8
        local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
        if talentInfo then
            mod = talentInfo.rank * 0.05 -- 0-15% from Meditation
        end
    elseif GW.myClassID == ClassIndex.MAGE then
        talentInfoQuery.specializationIndex = 1
		talentInfoQuery.talentIndex = 12
        local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
        if talentInfo then
            mod = talentInfo.rank * 0.05 -- 0-15% Arcane Meditation
        end
    elseif GW.myClassID == ClassIndex.DRUID then
        talentInfoQuery.specializationIndex = 3
		talentInfoQuery.talentIndex = 6
        local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
        if talentInfo then
            mod = talentInfo.rank * 0.05 -- 0-15% from Reflection
        end
    end

    return mod
end

local function _GetBlessingOfWisdomModifier()
    local mod = 0
    if GW.myClassID == ClassIndex.PALADIN then
        local talentInfoQuery = {}
        talentInfoQuery.isInspect = false
        talentInfoQuery.isPet = false
        talentInfoQuery.groupIndex = GW.GetTalentSpec()
        talentInfoQuery.specializationIndex = 1
		talentInfoQuery.talentIndex = 10
        local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
        if talentInfo then
            mod = talentInfo.rank * 0.1 -- 0-20% from Improved Blessing of Wisdom
        end
    end
    return mod
end

local function _GetAuraModifier()
    local mod = 0
    local bonus = 0

    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
        if not aura then break end
        local spellId = aura.spellId
        if spellId == 6117 or spellId == 22782 or spellId == 22783 then
            mod = mod + 0.3 -- 30% Mage Armor
        elseif spellId == 24363 then
            bonus = bonus + 12 -- 12 MP5 from Mageblood Potion
        elseif spellId == 16609 then
            bonus = bonus + 10 -- 10 MP5 from Warchief Belssing
        elseif spellId == 18194 then
            bonus = bonus + 8 -- 8 MP5 from Nightfin Soup
        elseif spellId == 25691 then
            bonus = bonus + 6 -- 6 MP5 from Sagefish Delight
        elseif spellId == 25690 then
            bonus = bonus + 3 -- 8 MP5 from Smoked Sagefish
        elseif spellId == 5677 then
            bonus = bonus + 10 -- 4 mana pe 2 sec Mana spring Totem Rank 1
        elseif spellId == 10491 then
            bonus = bonus + 15 -- 6 mana pe 2 sec Mana spring Totem Rank 2
        elseif spellId == 10493 then
            bonus = bonus + 20 -- 8 mana pe 2 sec Mana spring Totem Rank 3
        elseif spellId == 10494 then
            bonus = bonus + 25 -- 10 mana pe 2 sec Mana spring Totem Rank 4
        elseif spellId == 25894 then
            local blessingMod = _GetBlessingOfWisdomModifier() + 1
         	bonus = bonus + math.ceil(30 * blessingMod) -- Greater Blessing of Wisdom Rank 1
        elseif spellId == 25918 then
            local blessingMod = _GetBlessingOfWisdomModifier() + 1
         	bonus = bonus + math.ceil(33 * blessingMod) -- Greater Blessing of Wisdom Rank 2
        elseif spellId == 19742 then
            local blessingMod = _GetBlessingOfWisdomModifier() + 1
            bonus = bonus + math.ceil(10 * blessingMod) -- Blessing of Wisdom Rank 1
        elseif spellId == 19850 then
            local blessingMod = _GetBlessingOfWisdomModifier() + 1
         	bonus = bonus + math.ceil(15 * blessingMod) -- Blessing of Wisdom Rank 2
        elseif spellId == 19852 then
            local blessingMod = _GetBlessingOfWisdomModifier() + 1
            bonus = bonus + math.ceil(20 * blessingMod) -- Blessing of Wisdom Rank 3
        elseif spellId == 19853 then
            local blessingMod = _GetBlessingOfWisdomModifier() + 1
         	bonus = bonus + math.ceil(25 * blessingMod) -- Blessing of Wisdom Rank 4
        elseif spellId == 19854 then
            local blessingMod = _GetBlessingOfWisdomModifier() + 1
         	bonus = bonus + math.ceil(30 * blessingMod) -- Blessing of Wisdom Rank 5
        elseif spellId == 25290 then
            local blessingMod = _GetBlessingOfWisdomModifier() + 1
         	bonus = bonus + math.ceil(33 * blessingMod) -- Blessing of Wisdom Rank 6
        elseif spellId == 17252 then
            bonus = bonus + 22 -- 22 MP5 from Mark of the Dragon Lord
        end
    end

    return mod, bonus
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

local function HasSetBonusModifierNatureCrit()
    if GW.myClassID == ClassIndex.SHAMAN then
        return IsSetBonusActive("The Then Storms", 5)
    end

    return false
end


local function _GetGeneralTalentModifier()
    local mod = 0

    if GW.myClassID == ClassIndex.MAGE then -- Mage
        local talentInfoQuery = {}
        talentInfoQuery.isInspect = false
        talentInfoQuery.isPet = false
        talentInfoQuery.groupIndex = GW.GetTalentSpec()
        talentInfoQuery.specializationIndex = 1
		talentInfoQuery.talentIndex = 15
        local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
        if talentInfo then
            mod = talentInfo.rank * 1 -- 0-3% Arcane Instability
        end
    end

    return mod
end

local function _GetTalentModifierSpellHit()
    local mod = 0
    local talentInfoQuery = {}
    talentInfoQuery.isInspect = false
    talentInfoQuery.isPet = false
    talentInfoQuery.groupIndex = GW.GetTalentSpec()

    if GW.myClassID == ClassIndex.PRIEST then -- Priest
        talentInfoQuery.specializationIndex = 3
        talentInfoQuery.talentIndex = 5
        local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
        if talentInfo then
            mod = talentInfo.rank * 2 -- 0-10% from Shadow Focus
        end
    elseif GW.myClassID == ClassIndex.MAGE then -- Mage
        talentInfoQuery.specializationIndex = 3
        talentInfoQuery.talentIndex = 3
        local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
        if talentInfo then
            mod = talentInfo.rank * 2 -- 0-6% from Elemental Precision
        end
    end

    return mod
end

local function _GetMP5ValueOnItems() 
    local mp5 = 0
    for i = 1, 18 do
        local itemLink = GetInventoryItemLink("player", i)
        if itemLink then
            local stats = GetItemStats(itemLink)
            if stats then
                local statMP5 = stats["ITEM_MOD_POWER_REGEN0_SHORT"]
                if statMP5 then
                    mp5 = mp5 + statMP5 + 1
                end
            end
            local enchant = GetEnchantFromItemLink(itemLink)
            if enchant and enchant == enchants.Bracer_Mana_Reg then
                mp5 = mp5 + 4
            end
            -- Priest ZG Enchant
            if enchant and enchant == enchants.PROPHETIC_AURA then
                mp5 = mp5 + 4
            end
        end
    end

    -- Check weapon enchants (e.g. Mana Oil)
    local hasMainEnchant, _, _, mainHandEnchantID = GetWeaponEnchantInfo()
    if (hasMainEnchant) then
        if mainHandEnchantID == enchants.BRILLIANT_MANA_OIL then
            mp5 = mp5 + 12
        end
        if mainHandEnchantID == enchants.LESSER_MANA_OIL then
            mp5 = mp5 + 8
        end
        if mainHandEnchantID == enchants.MINOR_MANA_OIL then
            mp5 = mp5 + 4
        end
    end

    return mp5
end

local function GetSpellDmg(school)
    local spellDmg = GetSpellBonusDamage(school)
    local modifier = _GetGeneralTalentModifier()

    spellDmg = spellDmg * (1 + (modifier / 100))

    return RoundDec(spellDmg, 0)
end

-- Get MP5 from spirit
local function GetMP5FromSpirit()
    local base, _ = GetManaRegen() -- Returns mana reg per 1 second
    if base < 1 then
        base = lastManaReg
    end
    lastManaReg = base
    return RoundDec(base * 5, 1)
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
    local auraMod, auraValues = _GetAuraModifier()
    mod = mod + auraMod
    if mod == 0 then
        casting = 0
    end
    casting = casting + mod

    local mp5Items = GetMP5FromItems()
    casting = (casting * 5) + mp5Items + auraValues

    return RoundDec(casting, 2)
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
    local rangedWeaponSkill = rangedAttackBase + rangedAttackMod
    local enemyDefenseValue = (GW.mylevel + 3) * 5

    local missChance = _GetMissChanceByDifference(rangedWeaponSkill, enemyDefenseValue)
    local hitBonus = _GetRangeHitBonus()
    if rangedWeaponSkill < 305 and hitBonus >= 1 then
        hitBonus = hitBonus - 1
    end
    missChance = missChance - hitBonus

    if missChance < 0 then
        missChance = 0
    elseif missChance > 100 then
        missChance = 100
    end

    return RoundDec(missChance, 2) .. "%"
end

local function SpellHitBonus()
    local hit = _GetTalentModifierSpellHit()
    hit = hit + GetSpellHitModifier()

    return RoundDec(hit, 2) .. "%"
end

local function SpellMissChanceSameLevel()
    local missChance = 4

    missChance = missChance - _GetTalentModifierSpellHit()
    local mod = GetSpellHitModifier()
    if mod then
        missChance = missChance - mod
    end

    if missChance < 1 then
        missChance = 1
    elseif missChance > 100 then
        missChance = 100
    end

    return RoundDec(missChance, 2) .. "%"
end

local function SpellMissChanceBossLevel()
    local missChance = 17

    missChance = missChance - _GetTalentModifierSpellHit()
    local mod = GetSpellHitModifier()
    if mod then
        missChance = missChance - mod
    end

    if missChance < 1 then
        missChance = 1
    elseif missChance > 100 then
        missChance = 100
    end

    return RoundDec(missChance, 2) .. "%"
end

local function GetBlockValue()
    return RoundDec(GetShieldBlock(), 2)
end

local function _GetTalentModifierHolyCrit()
    local mod = 0

    if GW.myClassID == ClassIndex.PRIEST then -- Priest
        local talentInfoQuery = {}
        talentInfoQuery.isInspect = false
        talentInfoQuery.isPet = false
        talentInfoQuery.groupIndex = GW.GetTalentSpec()
        talentInfoQuery.specializationIndex = 2
		talentInfoQuery.talentIndex = 3
        local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
        if talentInfo then
            mod = talentInfo.rank * 1 -- 0-5% Holy Specialization
        end
    end

    return mod
end

local function _GetTalentModifierFireCrit()
    local mod = 0

    if GW.myClassID == ClassIndex.MAGE then -- Mage
        local talentInfoQuery = {}
        talentInfoQuery.isInspect = false
        talentInfoQuery.isPet = false
        talentInfoQuery.groupIndex = GW.GetTalentSpec()
        talentInfoQuery.specializationIndex = 2
		talentInfoQuery.talentIndex = 13
        local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
        if talentInfo then
            mod = talentInfo.rank * 2 -- 0-6% Critical Mass
        end
    end

    return mod
end

local function _GetTalentModierBySchool(school)
    if school == schools.holy then
        return _GetTalentModifierHolyCrit()
    elseif school == schools.fire then
        return _GetTalentModifierFireCrit()
    else
        return 0
    end
end

local function _GetItemModifierBySchool(school)
    if school == schools.holy then
        local mainHand = GetInventoryItemID("player", 16)
        if mainHand == 18608 then 
            return 2 -- 2% Holy Crit from Benediction
        end
    end

    return 0
end

local function _GetSetBonus(school)
    local bonus = 0

    if schools == schools.nature and HasSetBonusModifierNatureCrit() then
        bonus = 3 -- 3% Nature Crit Shame T2
    end

    return bonus
end

local function _GetTalentModifier(school)
    local modifier = _GetGeneralTalentModifier()
    local modifierForSchool = _GetTalentModierBySchool(school)

    return modifier + modifierForSchool
end

local function GetSpellCrit(school)
    local crit = _GetTalentModifier(school)
    local itemBonus = _GetItemModifierBySchool(school)
    local setBonus = _GetSetBonus(school)
    local spellCrit = school and GetSpellCritChance(school) or GetSpellCritChanceFromIntellect("player")
    crit = crit + spellCrit + itemBonus + setBonus
    return RoundDec(crit, 2) .. "%"
end

local function PhysicalCrit()
    return GetSpellCrit(schools.physical)
end

-- Get holy crit chance
local function HolyCrit()
    return GetSpellCrit(schools.holy)
end

local function FireCrit()
    return GetSpellCrit(schools.fire)
end

local function NatureCrit()
    return GetSpellCrit(schools.nature)
end

local function FrostCrit()
    return GetSpellCrit(schools.frost)
end

local function ShadowCrit()
    return GetSpellCrit(schools.shadow)
end

local function ArcaneCrit()
    return GetSpellCrit(schools.arcane)
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
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. SPELL_CRIT_CHANCE .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. GetSpellCrit(2) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. ITEM_MOD_HIT_SPELL_RATING_SHORT .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. SpellHitBonus() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   Miss-Chance:" .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. SpellMissChanceSameLevel() .. FONT_COLOR_CODE_CLOSE)
        GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   Miss-Chance (Level + 3):" .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. SpellMissChanceBossLevel() .. FONT_COLOR_CODE_CLOSE)
    

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(SPELL_BONUS)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. BONUS_HEALING .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellBonusHealing()) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL6 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellDmg(schools.shadow)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL6 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. ShadowCrit().. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL2 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellDmg(schools.holy)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL2 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. HolyCrit() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL3 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellDmg(schools.fire)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL3 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. FireCrit() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL5 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellDmg(schools.frost)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL5 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. FrostCrit() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL7 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellDmg(schools.arcane)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL7 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. ArcaneCrit() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL4 .. " ".. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellDmg(schools.nature)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. DAMAGE_SCHOOL4 .. " ".. CRIT_ABBR ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. NatureCrit() .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. STRING_SCHOOL_PHYSICAL .. " " .. DAMAGE ..": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", GetSpellDmg(schools.physical)) .. FONT_COLOR_CODE_CLOSE)
    GameTooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE .. "   " .. STRING_SCHOOL_PHYSICAL .. " " .. CRIT_ABBR .. ": " .. FONT_COLOR_CODE_CLOSE, HIGHLIGHT_FONT_COLOR_CODE .. PhysicalCrit() .. FONT_COLOR_CODE_CLOSE)

    GameTooltip:Show()
end
GW.showAdvancedChatStats = showAdvancedChatStats
