---@class GW2
local GW = select(2, ...)
local RoundDec = GW.RoundDec

local lastManaReg = 0

local BIZNICK_ENCHANT = 2523 -- 3% ranged hit

local ITEM_ENCHANT_MP5 = {
    [2565] = 4, -- Bracer Mana Regeneration
    [2590] = 4, -- Prophetic Aura (priest ZG)
}

local WEAPON_ENCHANT_MP5 = {
    [2629] = 12, -- Brilliant Mana Oil
    [2625] = 8, -- Lesser Mana Oil
    [2624] = 4, -- Minor Mana Oil
}

local AURA_MP5 = {
    [24363] = 12, -- Mageblood Potion
    [16609] = 10, -- Warchief's Blessing
    [18194] = 8, -- Nightfin Soup
    [25691] = 6, -- Sagefish Delight
    [25690] = 3, -- Smoked Sagefish
    [5677] = 10, -- Mana Spring Totem rank 1
    [10491] = 15, -- Mana Spring Totem rank 2
    [10493] = 20, -- Mana Spring Totem rank 3
    [10494] = 25, -- Mana Spring Totem rank 4
    [17252] = 22, -- Mark of the Dragon Lord
}

local BLESSING_OF_WISDOM_MP5 = {
    [19742] = 10, -- rank 1
    [19850] = 15, -- rank 2
    [19852] = 20, -- rank 3
    [19853] = 25, -- rank 4
    [19854] = 30, -- rank 5
    [25290] = 33, -- rank 6
    [25894] = 30, -- greater rank 1
    [25918] = 33, -- greater rank 2
}

local MAGE_ARMOR = {[6117] = true, [22782] = true, [22783] = true}

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

local function TalentRank(specializationIndex, talentIndex)
    local talentInfo = C_SpecializationInfo.GetTalentInfo({
        isInspect = false,
        isPet = false,
        groupIndex = GW.GetTalentSpec(),
        specializationIndex = specializationIndex,
        talentIndex = talentIndex,
    })
    return talentInfo and talentInfo.rank or 0
end

local function _IsRangeAttackClass()
    return GW.myClassID == GW.Enum.ClassIndex.Warrior or GW.myClassID == GW.Enum.ClassIndex.Rogue or GW.myClassID == GW.Enum.ClassIndex.Hunter
end

local function _IsShapeshifted()
    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
        if not aura then break end
        local spellId = aura.spellId
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
    return itemLink and tonumber(itemLink:match("item:%d+:(%d*)"))
end

local function _GetRangeHitBonus()
    local hitValue = GetHitModifier() or 0
    if GetEnchantFromItemLink(GetInventoryItemLink("player", INVSLOT_RANGED)) == BIZNICK_ENCHANT then
        hitValue = hitValue + 3
    end
    return hitValue
end

local function _GetTalentModifierDefense()
    if GW.myClassID == GW.Enum.ClassIndex.Warrior then
        return TalentRank(3, 2) * 2 -- Anticipation
    end
    return 0
end
GW.stats._GetTalentModifierDefense = _GetTalentModifierDefense

local function _GetTalentModifierMP5()
    if GW.myClassID == GW.Enum.ClassIndex.Priest then
        return TalentRank(1, 8) * 0.05 -- Meditation
    elseif GW.myClassID == GW.Enum.ClassIndex.Mage then
        return TalentRank(1, 12) * 0.05 -- Arcane Meditation
    elseif GW.myClassID == GW.Enum.ClassIndex.Druid then
        return TalentRank(3, 6) * 0.05 -- Reflection
    end
    return 0
end

local function _GetBlessingOfWisdomModifier()
    if GW.myClassID == GW.Enum.ClassIndex.Paladin then
        return TalentRank(1, 10) * 0.1 -- Improved Blessing of Wisdom
    end
    return 0
end

local function _GetAuraModifier()
    local mod = 0
    local bonus = 0
    local blessingMod = _GetBlessingOfWisdomModifier() + 1

    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
        if not aura then break end
        local spellId = aura.spellId
        if MAGE_ARMOR[spellId] then
            mod = mod + 0.3
        elseif BLESSING_OF_WISDOM_MP5[spellId] then
            bonus = bonus + math.ceil(BLESSING_OF_WISDOM_MP5[spellId] * blessingMod)
        else
            bonus = bonus + (AURA_MP5[spellId] or 0)
        end
    end

    return mod, bonus
end

local function _HasSetBonusModifierMP5()
    if GW.myClassID == GW.Enum.ClassIndex.Priest then
        return IsSetBonusActive("Vestments of Transcendence", 3)
    elseif GW.myClassID == GW.Enum.ClassIndex.Druid then
        return IsSetBonusActive("Stormrage Raiment", 3)
    end

    return false
end

local function GetSetBonusValueMP5()
    if (GW.myClassID == GW.Enum.ClassIndex.Druid and IsSetBonusActive("Haruspex's Garb", 2))
        or (GW.myClassID == GW.Enum.ClassIndex.Shaman and IsSetBonusActive("Augur's Regalia", 2))
        or (GW.myClassID == GW.Enum.ClassIndex.Paladin and IsSetBonusActive("Freethinker's Armor", 2)) then
        return 4
    end
    return 0
end

local function HasSetBonusModifierNatureCrit()
    if GW.myClassID == GW.Enum.ClassIndex.Shaman then
        return IsSetBonusActive("The Ten Storms", 5)
    end

    return false
end

local function _GetGeneralTalentModifier()
    if GW.myClassID == GW.Enum.ClassIndex.Mage then
        return TalentRank(1, 15) -- Arcane Instability
    end
    return 0
end

local function _GetTalentModifierSpellHit()
    if GW.myClassID == GW.Enum.ClassIndex.Priest then
        return TalentRank(3, 5) * 2 -- Shadow Focus
    elseif GW.myClassID == GW.Enum.ClassIndex.Mage then
        return TalentRank(3, 3) * 2 -- Elemental Precision
    end
    return 0
end

local function _GetMP5ValueOnItems()
    local mp5 = 0
    for slot = 1, 18 do
        local itemLink = GetInventoryItemLink("player", slot)
        if itemLink then
            local stats = GetItemStats(itemLink)
            local statMP5 = stats and stats.ITEM_MOD_POWER_REGEN0_SHORT
            if statMP5 then
                mp5 = mp5 + statMP5 + 1
            end
            mp5 = mp5 + (ITEM_ENCHANT_MP5[GetEnchantFromItemLink(itemLink)] or 0)
        end
    end

    local hasMainHandEnchant, _, _, mainHandEnchantID = GetWeaponEnchantInfo()
    if hasMainHandEnchant then
        mp5 = mp5 + (WEAPON_ENCHANT_MP5[mainHandEnchantID] or 0)
    end

    return mp5
end

local function GetSpellDmg(school)
    local spellDmg = GetSpellBonusDamage(school)
    local modifier = _GetGeneralTalentModifier()

    spellDmg = spellDmg * (1 + (modifier / 100))

    return RoundDec(spellDmg, 0)
end

local function GetMP5FromSpirit()
    local base, _ = GetManaRegen() -- Returns mana reg per 1 second
    if base < 1 then
        base = lastManaReg
    end
    lastManaReg = base
    return RoundDec(base * 5, 1)
end

local function GetMP5FromItems()
    local mp5 = _GetMP5ValueOnItems()
    mp5 = mp5 + GetSetBonusValueMP5()

    return mp5
end

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

local function MeleeMissChance(levelOffset)
    local missChance
    if _IsShapeshifted() then
        missChance = 6 + levelOffset
    else
        local mainBase, mainMod = UnitAttackBothHands("player")
        missChance = _GetMissChanceByDifference(mainBase + mainMod, (GW.mylevel + levelOffset) * 5)
    end
    return Clamp(missChance - (GetHitModifier() or 0), 0, 100)
end

local function RangeMissChance(levelOffset)
    local rangedAttackBase, rangedAttackMod = UnitRangedAttack("player")
    local rangedWeaponSkill = rangedAttackBase + rangedAttackMod
    local missChance = _GetMissChanceByDifference(rangedWeaponSkill, (GW.mylevel + levelOffset) * 5)
    local hitBonus = _GetRangeHitBonus()
    if levelOffset > 0 and rangedWeaponSkill < 305 and hitBonus >= 1 then
        hitBonus = hitBonus - 1
    end
    return Clamp(missChance - hitBonus, 0, 100)
end

local function SpellHitBonus()
    return _GetTalentModifierSpellHit() + (GetSpellHitModifier() or 0)
end

local function SpellMissChance(baseMissChance)
    return Clamp(baseMissChance - SpellHitBonus(), 1, 100)
end

local function GetBlockValue()
    return RoundDec(GetShieldBlock(), 2)
end

local function _GetTalentModierBySchool(school)
    if school == schools.holy and GW.myClassID == GW.Enum.ClassIndex.Priest then
        return TalentRank(2, 3) -- Holy Specialization
    elseif school == schools.fire and GW.myClassID == GW.Enum.ClassIndex.Mage then
        return TalentRank(2, 13) * 2 -- Critical Mass
    end
    return 0
end

local function _GetItemModifierBySchool(school)
    if school == schools.holy and GetInventoryItemID("player", INVSLOT_MAINHAND) == 18608 then
        return 2 -- Benediction
    end
    return 0
end

local function _GetSetBonus(school)
    if school == schools.nature and HasSetBonusModifierNatureCrit() then
        return 3 -- The Ten Storms
    end
    return 0
end

local function GetSpellCrit(school)
    local crit = _GetGeneralTalentModifier() + _GetTalentModierBySchool(school) + _GetItemModifierBySchool(school) + _GetSetBonus(school)
    local spellCrit = school and GetSpellCritChance(school) or GetSpellCritChanceFromIntellect("player")
    return crit + spellCrit
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

local SPELL_SCHOOLS = {
    {school = schools.shadow, label = DAMAGE_SCHOOL6},
    {school = schools.holy, label = DAMAGE_SCHOOL2},
    {school = schools.fire, label = DAMAGE_SCHOOL3},
    {school = schools.frost, label = DAMAGE_SCHOOL5},
    {school = schools.arcane, label = DAMAGE_SCHOOL7},
    {school = schools.nature, label = DAMAGE_SCHOOL4},
    {school = schools.physical, label = STRING_SCHOOL_PHYSICAL},
}

local function AddHeader(text)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(text)
end

local function AddStat(label, value)
    local r, g, b = HIGHLIGHT_FONT_COLOR:GetRGB()
    GameTooltip:AddDoubleLine("   " .. label .. ":", value, r, g, b, r, g, b)
end

local function Percent(value)
    return format("%.2F%%", value)
end

local function showAdvancedChatStats(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(ADVANCED_LABEL .. " " .. STAT_CATEGORY_ATTRIBUTES)

    AddHeader(MELEE)
    AddStat(MELEE_CRIT_CHANCE, Percent(GetCritChance()))
    AddStat(ITEM_MOD_HIT_MELEE_RATING_SHORT, Percent(GetHitModifier() or 0))
    AddStat(ATTACK_POWER_TOOLTIP, GetMeleeAttackPower())
    AddStat("Miss-Chance", Percent(MeleeMissChance(0)))
    AddStat("Miss-Chance (Level + 3)", Percent(MeleeMissChance(3)))

    if _IsRangeAttackClass() then
        AddHeader(RANGED)
        AddStat(RANGED_CRIT_CHANCE, Percent(GetRangedCritChance()))
        AddStat(ITEM_MOD_HIT_RANGED_RATING_SHORT, Percent(_GetRangeHitBonus()))
        AddStat(RANGED_ATTACK_TOOLTIP, GetRangeAttackPower())
        AddStat("Miss-Chance", Percent(RangeMissChance(0)))
        AddStat("Miss-Chance (Level + 3)", Percent(RangeMissChance(3)))
    end

    AddHeader(DEFENSE)
    AddStat(BLOCK_CHANCE, Percent(GetBlockChance()))
    AddStat(ITEM_MOD_BLOCK_VALUE_SHORT, GetBlockValue())
    AddStat(PARRY_CHANCE, Percent(GetParryChance()))
    AddStat(DODGE_CHANCE, Percent(GetDodgeChance()))

    if UnitPowerType("player") == Enum.PowerType.Mana then
        AddHeader(MANA_REGEN)
        AddStat(ITEM_MOD_POWER_REGEN0_SHORT .. " (" .. HELPFRAME_ITEM_TITLE .. ")", format("%.2F", GetMP5FromItems()))
        AddStat(ITEM_MOD_POWER_REGEN0_SHORT .. " (" .. PLAYERSTAT_SPELL_COMBAT .. ")", format("%.2F", GetMP5WhileCasting()))
        AddStat(ITEM_MOD_POWER_REGEN0_SHORT .. " (" .. ITEM_MOD_SPIRIT_SHORT .. ")", format("%.2F", GetMP5FromSpirit()))
    end

    AddHeader(STAT_CATEGORY_SPELL)
    AddStat(SPELL_CRIT_CHANCE, Percent(GetSpellCrit(schools.holy)))
    AddStat(ITEM_MOD_HIT_SPELL_RATING_SHORT, Percent(SpellHitBonus()))
    AddStat("Miss-Chance", Percent(SpellMissChance(4)))
    AddStat("Miss-Chance (Level + 3)", Percent(SpellMissChance(17)))

    AddHeader(SPELL_BONUS)
    AddStat(BONUS_HEALING, format("%.2F", GetSpellBonusHealing()))
    for _, info in ipairs(SPELL_SCHOOLS) do
        AddStat(info.label .. " " .. DAMAGE, format("%.2F", GetSpellDmg(info.school)))
        AddStat(info.label .. " " .. CRIT_ABBR, Percent(GetSpellCrit(info.school)))
    end

    GameTooltip:Show()
end
GW.showAdvancedChatStats = showAdvancedChatStats
