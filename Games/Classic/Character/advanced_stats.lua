---@class GW2
local GW = select(2, ...)
local RoundDec = GW.RoundDec

local lastSpiritRegen = 0

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

-- the spirit regen is 0 within the five second rule, then the last value outside of it is used
local function GetSpiritRegen()
    local base = GetManaRegen()
    if base < 1 then
        base = lastSpiritRegen
    end
    lastSpiritRegen = base
    return base
end

local function GetMP5FromSpirit()
    return RoundDec(GetSpiritRegen() * 5, 1)
end

local function GetMP5FromItems()
    return _GetMP5ValueOnItems() + GetSetBonusValueMP5()
end

-- blizzard leaves the casting regen at 0: talents, mage armor and set bonuses let a part of the spirit regen go on
local function GetMP5WhileCasting()
    local mod = _GetTalentModifierMP5()
    if _HasSetBonusModifierMP5() then
        mod = mod + 0.15
    end
    local auraMod, auraValues = _GetAuraModifier()
    mod = mod + auraMod

    return RoundDec(GetSpiritRegen() * mod * 5 + GetMP5FromItems() + auraValues, 2)
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

local MISS_CHANCE_BOSS = MISS_CHANCE .. " (" .. LEVEL .. " +3)"

local ROW_HEIGHT = 17
local SECTION_HEIGHT = 26

local function Percent(value)
    return format("%.2F%%", value)
end

-- the sections fit the class, rows are a label and a function for their value
local function GetSections()
    local sections = {}
    tinsert(sections, {MELEE, {
        {MELEE_CRIT_CHANCE, function() return Percent(GetCritChance()) end},
        {ITEM_MOD_HIT_MELEE_RATING_SHORT, function() return Percent(GetHitModifier() or 0) end},
        {ATTACK_POWER_TOOLTIP, GetMeleeAttackPower},
        {MISS_CHANCE, function() return Percent(MeleeMissChance(0)) end},
        {MISS_CHANCE_BOSS, function() return Percent(MeleeMissChance(3)) end},
    }})
    if _IsRangeAttackClass() then
        tinsert(sections, {RANGED, {
            {RANGED_CRIT_CHANCE, function() return Percent(GetRangedCritChance()) end},
            {ITEM_MOD_HIT_RANGED_RATING_SHORT, function() return Percent(_GetRangeHitBonus()) end},
            {RANGED_ATTACK_TOOLTIP, GetRangeAttackPower},
            {MISS_CHANCE, function() return Percent(RangeMissChance(0)) end},
            {MISS_CHANCE_BOSS, function() return Percent(RangeMissChance(3)) end},
        }})
    end
    tinsert(sections, {DEFENSE, {
        {BLOCK_CHANCE, function() return Percent(GetBlockChance()) end},
        {ITEM_MOD_BLOCK_VALUE_SHORT, GetBlockValue},
        {PARRY_CHANCE, function() return Percent(GetParryChance()) end},
        {DODGE_CHANCE, function() return Percent(GetDodgeChance()) end},
    }})
    if UnitPowerMax("player", Enum.PowerType.Mana) > 0 then
        tinsert(sections, {MANA_REGEN, {
            {ITEM_MOD_POWER_REGEN0_SHORT .. " (" .. HELPFRAME_ITEM_TITLE .. ")", function() return format("%.2F", GetMP5FromItems()) end},
            {ITEM_MOD_POWER_REGEN0_SHORT .. " (" .. PLAYERSTAT_SPELL_COMBAT .. ")", function() return format("%.2F", GetMP5WhileCasting()) end},
            {ITEM_MOD_POWER_REGEN0_SHORT .. " (" .. ITEM_MOD_SPIRIT_SHORT .. ")", function() return format("%.2F", GetMP5FromSpirit()) end},
        }})
    end
    tinsert(sections, {STAT_CATEGORY_SPELL, {
        {SPELL_CRIT_CHANCE, function() return Percent(GetSpellCrit(schools.holy)) end},
        {ITEM_MOD_HIT_SPELL_RATING_SHORT, function() return Percent(SpellHitBonus()) end},
        {MISS_CHANCE, function() return Percent(SpellMissChance(4)) end},
        {MISS_CHANCE_BOSS, function() return Percent(SpellMissChance(17)) end},
    }})
    -- one row per school: damage and crit
    local bonus = {{BONUS_HEALING, function() return format("%.2F", GetSpellBonusHealing()) end}}
    for _, info in ipairs(SPELL_SCHOOLS) do
        tinsert(bonus, {info.label, function() return format("%.2F  %s", GetSpellDmg(info.school), Percent(GetSpellCrit(info.school))) end})
    end
    tinsert(sections, {SPELL_BONUS, bonus})
    return sections
end

local function CreateText(parent, scale)
    local text = parent:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
    if scale then
        local font, fontHeight, fontFlags = text:GetFont()
        text:SetFont(font, fontHeight * scale, fontFlags)
    end
    return text
end

local function UpdateValues(self)
    for _, row in ipairs(self.rows) do
        row.text:SetText(row.value())
    end
end

local function CreateAdvancedCharStats(parent)
    local as = CreateFrame("Frame", nil, parent)
    as:SetPoint("TOPLEFT", parent, "TOPRIGHT", 19, 60)
    as:SetWidth(200)
    as:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 10, 10)

    as.header = CreateText(as, 1.3)
    as.header:SetPoint("TOP")
    as.header:SetText(ADVANCED_LABEL .. " " .. STAT_CATEGORY_ATTRIBUTES)

    as.rows = {}
    local y = -20
    for _, section in ipairs(GetSections()) do
        y = y - SECTION_HEIGHT
        local title = CreateText(as, 1.1)
        title:SetPoint("BOTTOMLEFT", as, "TOPLEFT", 0, y + 4)
        title:SetText(section[1])
        for _, row in ipairs(section[2]) do
            local value = CreateText(as)
            value:SetPoint("TOPRIGHT", -20, y)
            local label = CreateText(as)
            label:SetPoint("TOPLEFT", 10, y)
            label:SetPoint("RIGHT", value, "LEFT", -4, 0)
            label:SetJustifyH("LEFT")
            label:SetWordWrap(false)
            label:SetText(row[1])
            tinsert(as.rows, {text = value, value = row[2]})
            y = y - ROW_HEIGHT
        end
    end
    as:SetHeight(-y + 10)

    parent.advancedStatsFrame = as
    as:SetScript("OnShow", UpdateValues)
    -- a closed window catches up through OnShow
    as:SetScript("OnEvent", function(self)
        if self:IsVisible() then
            UpdateValues(self)
        end
    end)
    for _, event in ipairs({"CHARACTER_POINTS_CHANGED", "UNIT_LEVEL", "SKILL_LINES_CHANGED", "PLAYER_EQUIPMENT_CHANGED", "SPELL_POWER_CHANGED", "COMBAT_RATING_UPDATE", "PLAYER_DAMAGE_DONE_MODS"}) do
        as:RegisterEvent(event)
    end
    for _, event in ipairs({"UNIT_STATS", "UNIT_ATTACK_POWER", "UNIT_RANGED_ATTACK_POWER", "UNIT_ATTACK", "UNIT_DAMAGE", "UNIT_RESISTANCES", "UNIT_AURA", "UNIT_INVENTORY_CHANGED"}) do
        as:RegisterUnitEvent(event, "player")
    end
    as:Hide()
end

-- shown nil toggles; the state is kept in the profile and restored when the character window loads
local function ShowAdvancedCharStats(parent, shown)
    if not parent.advancedStatsFrame then CreateAdvancedCharStats(parent) end
    if shown == nil then
        shown = not parent.advancedStatsFrame:IsShown()
    end
    parent.advancedStatsFrame:SetShown(shown)
    GW.settings.windows.character.advancedStats = shown
end
GW.ShowAdvancedCharStats = ShowAdvancedCharStats
