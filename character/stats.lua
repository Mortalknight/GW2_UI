local _, GW = ...

GW.stats = {}
local PRIMARY_STATS={
    [1] ="STRENGTH",
    [2] ="AGILITY",
    [3] ="STAMINA",
    [4] ="INTELLECT",
    [5] ="SPIRIT"
}
GW.stats.PRIMARY_STATS = PRIMARY_STATS
local RESITANCE_STATS = {
    [1] = "Holy",
    [2] = "Fire",
    [3] = "Nature",
    [4] = "Frost",
    [5] = "Shadow",
    [6] = "Arcane",
}
GW.stats.RESITANCE_STATS = RESITANCE_STATS

local function formateStat(name, base, posBuff, negBuff)
    local effective = max(0, base + posBuff + negBuff)
    local text = HIGHLIGHT_FONT_COLOR_CODE .. name .. " " .. effective
    local stat
    if posBuff == 0 and negBuff == 0 then
        text = text .. FONT_COLOR_CODE_CLOSE
        stat = effective
    else
        if posBuff > 0 or negBuff < 0 then
            text = text .. " (" .. base .. FONT_COLOR_CODE_CLOSE
        end
        if posBuff > 0 then
            text = text .. FONT_COLOR_CODE_CLOSE .. GREEN_FONT_COLOR_CODE .. "+" .. posBuff .. FONT_COLOR_CODE_CLOSE
        end
        if negBuff < 0 then
            text = text .. RED_FONT_COLOR_CODE .. " " .. negBuff .. FONT_COLOR_CODE_CLOSE
        end
        if posBuff > 0 or negBuff < 0 then
            text = text .. HIGHLIGHT_FONT_COLOR_CODE .. ")" .. FONT_COLOR_CODE_CLOSE
        end

        -- if there is a negative buff then show the main number in red, even if there are
        -- positive buffs. Otherwise show the number in green
        if negBuff < 0 then
            stat = RED_FONT_COLOR_CODE .. effective .. FONT_COLOR_CODE_CLOSE
        else
            stat = GREEN_FONT_COLOR_CODE .. effective .. FONT_COLOR_CODE_CLOSE
        end
    end
    return stat, text
end

local function getPrimary(i, unit)
    local statText
    local tooltip
    local tooltip2
    local stat
    local effectiveStat
    local posBuff
    local negBuff

    if unit == nil then unit = "player" end
    stat, effectiveStat, posBuff, negBuff = UnitStat(unit, i)

    -- Set the tooltip text
    local tooltipText = HIGHLIGHT_FONT_COLOR_CODE .. _G["SPELL_STAT" .. i .. "_NAME"] .. " "

    -- Get class specific tooltip for that stat
    local _, classFileName = UnitClass(unit)
    local classStatText = _G[strupper(classFileName) .. "_" .. PRIMARY_STATS[i] .. "_" .. "TOOLTIP"]

    -- If can't find one use the default
    if not classStatText then
        classStatText = _G["DEFAULT" .. "_" .. PRIMARY_STATS[i] .. "_" .. "TOOLTIP"]
    end

    if posBuff == 0 and negBuff == 0 then
        statText = effectiveStat
        tooltip = tooltipText .. effectiveStat .. FONT_COLOR_CODE_CLOSE
    else
        tooltipText = tooltipText .. effectiveStat
        if posBuff > 0 or negBuff < 0 then
            tooltipText = tooltipText .. " (" .. (stat - posBuff - negBuff) .. FONT_COLOR_CODE_CLOSE
        end
        if posBuff > 0 then
            tooltipText = tooltipText .. FONT_COLOR_CODE_CLOSE .. GREEN_FONT_COLOR_CODE .. "+" .. posBuff .. FONT_COLOR_CODE_CLOSE
        end
        if negBuff < 0 then
            tooltipText = tooltipText .. RED_FONT_COLOR_CODE .. " " .. negBuff .. FONT_COLOR_CODE_CLOSE
        end
        if posBuff > 0 or negBuff < 0 then
            tooltipText = tooltipText .. HIGHLIGHT_FONT_COLOR_CODE .. ")" .. FONT_COLOR_CODE_CLOSE
        end
        tooltip = tooltipText

        -- If there are any negative buffs then show the main number in red even if there are
        -- positive buffs. Otherwise show in green.
        if negBuff < 0 then
            statText = RED_FONT_COLOR_CODE .. effectiveStat .. FONT_COLOR_CODE_CLOSE
        else
            statText = GREEN_FONT_COLOR_CODE .. effectiveStat .. FONT_COLOR_CODE_CLOSE
        end
    end
    tooltip2 = getglobal("DEFAULT_STAT"..i.."_TOOLTIP")
    local _, unitClass = UnitClass("player")
	unitClass = strupper(unitClass)

    if i == 1 then
		local attackPower = GetAttackPowerForStat(i,effectiveStat)
		tooltip2 = format(tooltip2, attackPower)
		if ( unitClass == "WARRIOR" or unitClass == "SHAMAN" or unitClass == "PALADIN" ) then
			tooltip2 = tooltip2 .. "\n" .. format( STAT_BLOCK_TOOLTIP, effectiveStat * BLOCK_PER_STRENGTH )
		end
	elseif i == 3 then
		local baseStam = min(20, effectiveStat);
		local moreStam = effectiveStat - baseStam;
		tooltip2 = format(tooltip2, (baseStam + (moreStam*HEALTH_PER_STAMINA))*GetUnitMaxHealthModifier("player"));
		local petStam = ComputePetBonus("PET_BONUS_STAM", effectiveStat );
		if( petStam > 0 ) then
			tooltip2 = tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_STAMINA,petStam);
		end
	elseif i == 2 then
		local attackPower = GetAttackPowerForStat(i,effectiveStat);
		if ( attackPower > 0 ) then
			tooltip2 = format(STAT_ATTACK_POWER, attackPower) .. format(tooltip2, GetCritChanceFromAgility("player"), effectiveStat*ARMOR_PER_AGILITY);
		else
			tooltip2 = format(tooltip2, GetCritChanceFromAgility("player"), effectiveStat*ARMOR_PER_AGILITY);
		end
	elseif i == 4 then
		local baseInt = min(20, effectiveStat);
		local moreInt = effectiveStat - baseInt
		if ( UnitHasMana("player") ) then
			tooltip2 = format(tooltip2, baseInt + moreInt*MANA_PER_INTELLECT, GetSpellCritChanceFromIntellect("player"));
		else
			tooltip2 = nil;
		end
		local petInt = ComputePetBonus("PET_BONUS_INT", effectiveStat );
		if( petInt > 0 ) then
			if ( not tooltip2 ) then
				tooltip2 = "";
			end
			tooltip2 = tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_INTELLECT,petInt);
		end
	elseif i == 5 then
		-- All mana regen stats are displayed as mana/5 sec.
		tooltip2 = format(tooltip2, GetUnitHealthRegenRateFromSpirit("player"));
		if ( UnitHasMana("player") ) then
			local regen = GetUnitManaRegenRateFromSpirit("player");
			regen = floor( regen * 5.0 );
			tooltip2 = tooltip2.."\n"..format(MANA_REGEN_FROM_SPIRIT, regen);
		end
	end
    return _G["SPELL_STAT" .. i .. "_NAME"], statText, tooltip, tooltip2
end
GW.stats.getPrimary = getPrimary

local function getArmor(unit)
    if not unit then
        unit = "player"
    end

    local stat, tooltip, tooltip2
    local base, effectiveArmor, _, posBuff, negBuff = UnitArmor(unit)
    stat, tooltip = formateStat(ARMOR, base, posBuff, negBuff)
    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitLevel(unit))

    tooltip2 = format(DEFAULT_STATARMOR_TOOLTIP, armorReduction)
    if unit == "player" then
        local petBonus = ComputePetBonus("PET_BONUS_ARMOR", effectiveArmor)
        if petBonus > 0 then
            tooltip2 = tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_ARMOR, petBonus)
        end
    end

    return stat, tooltip, tooltip2
end
GW.stats.getArmor = getArmor

local function getDefense()
    local stat, tooltip, tooltip2

    local base, modifier = UnitDefense("player")
    local posBuff = 0
    local negBuff = 0
    if ( modifier > 0 ) then
        posBuff = modifier
    elseif ( modifier < 0 ) then
        negBuff = modifier
    end

    stat, tooltip = formateStat(DEFENSE_COLON, base, posBuff, negBuff)
    local defensePercent = GetDodgeBlockParryChanceFromDefense()
    tooltip2 = format(DEFAULT_STATDEFENSE_TOOLTIP, GetCombatRating(CR_DEFENSE_SKILL), GetCombatRatingBonus(CR_DEFENSE_SKILL), defensePercent, defensePercent)

    return stat, tooltip, tooltip2
end
GW.stats.getDefense = getDefense

local function getDamage(unit, prefix)
    if not unit then
        unit = "player"
    end
    if not prefix then
        prefix = "Character"
    end

    local stat
    local speed, offhandSpeed = UnitAttackSpeed(unit)
    local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage(unit)
    local displayMin = max(floor(minDamage), 1)
    local displayMax = max(ceil(maxDamage), 1)

    minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
    maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

    local baseDamage = (minDamage + maxDamage) * 0.5
    local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
    local totalBonus = (fullDamage - baseDamage)
    local damagePerSecond = (max(fullDamage, 1) / speed)
    local damageTooltip = max(floor(minDamage), 1) .. " - " .. max(ceil(maxDamage), 1)

    local colorPos = "|cff20ff20"
    local colorNeg = "|cffff2020"
    if totalBonus == 0 then
        if displayMin < 100 and displayMax < 100 then
            stat = displayMin .. " - " .. displayMax
        else
            stat = displayMin .. "-" .. displayMax
        end
    else
        local color
        if totalBonus > 0 then
            color = colorPos
        else
            color = colorNeg
        end
        if displayMin < 100 and displayMax < 100 then
            stat = color .. displayMin .. " - " .. displayMax .. "|r"
        else
            stat = color .. displayMin .. "-" .. displayMax .. "|r"
        end
        if physicalBonusPos > 0 then
            damageTooltip = damageTooltip .. colorPos .. " +" .. physicalBonusPos .. "|r"
        end
        if physicalBonusNeg < 0 then
            damageTooltip = damageTooltip .. colorNeg .. " " .. physicalBonusNeg .. "|r"
        end
        if percent > 1 then
            damageTooltip = damageTooltip .. colorPos .. " x" .. floor(percent * 100 + 0.5) .. "%|r"
        elseif percent < 1 then
            damageTooltip = damageTooltip .. colorNeg .. " x" .. floor(percent * 100 + 0.5) .. "%|r"
        end
    end

    local offhandDamageTooltip
    local offhandDamagePerSecond = 0

    -- If there's an offhand speed then add the offhand info to the tooltip
    if offhandSpeed then
        minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg
        maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg

        local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5
        local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent
        offhandDamagePerSecond = (max(offhandFullDamage, 1) / offhandSpeed)

        offhandDamageTooltip = max(floor(minOffHandDamage), 1) .. " - " .. max(ceil(maxOffHandDamage), 1)
        if physicalBonusPos > 0 then
            offhandDamageTooltip = offhandDamageTooltip .. colorPos .. " +" .. physicalBonusPos .. "|r"
        end
        if physicalBonusNeg < 0 then
            offhandDamageTooltip = offhandDamageTooltip .. colorNeg .. " " .. physicalBonusNeg .. "|r"
        end
        if percent > 1 then
            offhandDamageTooltip = offhandDamageTooltip .. colorPos .. " x" .. floor(percent * 100 + 0.5) .. "%|r"
        elseif percent < 1 then
            offhandDamageTooltip = offhandDamageTooltip .. colorNeg .. " x" .. floor(percent * 100 + 0.5) .. "%|r"
        end
    end

    local tooltip = HIGHLIGHT_FONT_COLOR_CODE .. INVTYPE_WEAPONMAINHAND .. FONT_COLOR_CODE_CLOSE

    local tooltip2 = ATTACK_SPEED_COLON .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", speed) .. FONT_COLOR_CODE_CLOSE .. "\n"
    tooltip2 = tooltip2 .. DAMAGE_COLON .. HIGHLIGHT_FONT_COLOR_CODE .. damageTooltip .. FONT_COLOR_CODE_CLOSE .. "\n"
    tooltip2 = tooltip2 .. DAMAGE_PER_SECOND .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.1F", damagePerSecond) .. FONT_COLOR_CODE_CLOSE .. "\n"

    if offhandSpeed then
        tooltip2 = tooltip2 .."\n"
        tooltip2 = tooltip2 .. HIGHLIGHT_FONT_COLOR_CODE .. INVTYPE_WEAPONOFFHAND .. FONT_COLOR_CODE_CLOSE .. "\n"
        tooltip2 = tooltip2 .. ATTACK_SPEED_COLON .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", offhandSpeed) .. FONT_COLOR_CODE_CLOSE .. "\n"
        tooltip2 = tooltip2 .. DAMAGE_COLON .. HIGHLIGHT_FONT_COLOR_CODE .. offhandDamageTooltip .. FONT_COLOR_CODE_CLOSE .. "\n"
        tooltip2 = tooltip2 .. DAMAGE_PER_SECOND .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.1F", offhandDamagePerSecond) .. FONT_COLOR_CODE_CLOSE .. "\n"
        tooltip2 = tooltip2 .."\n"
        tooltip2 = tooltip2 .. TOTAL .. " " .. DAMAGE .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.1F", (damagePerSecond + offhandDamagePerSecond)) .. FONT_COLOR_CODE_CLOSE
    end

    return stat, tooltip, tooltip2
end
GW.stats.getDamage = getDamage

local function getRangeAttackSpeed()
    local text = UnitRangedDamage("player")
    text = format("%.2f", text);
    local tooltip = HIGHLIGHT_FONT_COLOR_CODE .. ATTACK_SPEED .. " " .. text .. FONT_COLOR_CODE_CLOSE;
    local tooltip2 = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_RANGED), GetCombatRatingBonus(CR_HASTE_RANGED));

    return text, tooltip, tooltip2
end
GW.stats.getRangeAttackSpeed = getRangeAttackSpeed

local function getAttackSpeed()
    local speed, offhandSpeed = UnitAttackSpeed("player")
    speed = format("%.2f", speed)
    if offhandSpeed then
        offhandSpeed = format("%.2f", offhandSpeed)
    end
    local text;
    if offhandSpeed then
        text = speed .. " / " .. offhandSpeed
    else
        text = speed
    end

    local tooltip = HIGHLIGHT_FONT_COLOR_CODE .. ATTACK_SPEED .. " " .. text .. FONT_COLOR_CODE_CLOSE
    local tooltip2 = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_MELEE), GetCombatRatingBonus(CR_HASTE_MELEE))

    return text, tooltip, tooltip2
end
GW.stats.getAttackSpeed = getAttackSpeed

local function getDodge()
    local chance = GetDodgeChance();
    local tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("DODGE_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
    local tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));

    return format("%.2f%%", chance), tooltip, tooltip2
end
GW.stats.getDodge = getDodge

local function getParry()
    local chance = GetParryChance();
    local tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("PARRY_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
    local tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));

    return format("%.2f%%", chance), tooltip, tooltip2
end
GW.stats.getParry = getParry

local function getBlock()
    local chance = GetBlockChance();
    local tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("BLOCK_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
    local tooltip2 = format(CR_BLOCK_TOOLTIP, GetCombatRating(CR_BLOCK), GetCombatRatingBonus(CR_BLOCK));

    return format("%.2f%%", chance), tooltip, tooltip2
end
GW.stats.getBlock = getBlock

local function getResilience()
    local resilience = GetCombatRating(CR_RESILIENCE_CRIT_TAKEN);
    local bonus = GetCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN);
    local tooltip = HIGHLIGHT_FONT_COLOR_CODE..STAT_RESILIENCE.." "..resilience..FONT_COLOR_CODE_CLOSE;
    local tooltip2 = format(RESILIENCE_TOOLTIP, bonus, min(bonus * 2, 25.00), bonus);

    return resilience, tooltip, tooltip2
end
GW.stats.getResilience = getResilience

local function getRating(ratingIndex)
    local rating = GetCombatRating(ratingIndex)
    local ratingBonus = GetCombatRatingBonus(ratingIndex)
    local statName = getglobal("COMBAT_RATING_NAME" .. ratingIndex)
    local tooltip, tooltip2 = HIGHLIGHT_FONT_COLOR_CODE .. statName .. " " .. rating .. FONT_COLOR_CODE_CLOSE, nil
    -- Can probably axe this if else tree if all rating tooltips follow the same format
    if ( ratingIndex == CR_HIT_MELEE ) then
        tooltip2 = format(CR_HIT_MELEE_TOOLTIP, UnitLevel("player"), ratingBonus, GetArmorPenetration());
    elseif ( ratingIndex == CR_HIT_RANGED ) then
        tooltip2 = format(CR_HIT_RANGED_TOOLTIP, UnitLevel("player"), ratingBonus, GetArmorPenetration());
    elseif ( ratingIndex == CR_DODGE ) then
        tooltip2 = format(CR_DODGE_TOOLTIP, ratingBonus);
    elseif ( ratingIndex == CR_PARRY ) then
        tooltip2 = format(CR_PARRY_TOOLTIP, ratingBonus);
    elseif ( ratingIndex == CR_BLOCK ) then
        tooltip2 = format(CR_PARRY_TOOLTIP, ratingBonus);
    elseif ( ratingIndex == CR_HIT_SPELL ) then
        tooltip2 = format(CR_HIT_SPELL_TOOLTIP, UnitLevel("player"), ratingBonus, GetSpellPenetration(), GetSpellPenetration());
    elseif ( ratingIndex == CR_EXPERTISE ) then
        tooltip2 = format(CR_EXPERTISE_TOOLTIP, ratingBonus);
    else
        tooltip2 = HIGHLIGHT_FONT_COLOR_CODE .. getglobal("COMBAT_RATING_NAME" .. ratingIndex) .. " " .. rating;
    end

    return rating, tooltip, tooltip2
end
GW.stats.getRating = getRating

local function getMeleeCritChance()
    local critChance = GetCritChance()
    critChance = format("%.2f%%", critChance);
    local tooltip = HIGHLIGHT_FONT_COLOR_CODE..MELEE_CRIT_CHANCE.." "..critChance..FONT_COLOR_CODE_CLOSE;
    local tooltip2 = format(CR_CRIT_MELEE_TOOLTIP, GetCombatRating(CR_CRIT_MELEE), GetCombatRatingBonus(CR_CRIT_MELEE));

    return critChance, tooltip, tooltip2
end
GW.stats.getMeleeCritChance = getMeleeCritChance

local function getSpellCritChance(frame)
    local holySchool = 2;
    -- Start at 2 to skip physical damage
    local minCrit = GetSpellCritChance(holySchool)
    frame.spellCrit = frame.spellCrit or {}
    frame.spellCrit[holySchool] = minCrit;
    local spellCrit;
    for i = (holySchool + 1), MAX_SPELL_SCHOOLS do
        spellCrit = GetSpellCritChance(i);
        minCrit = min(minCrit, spellCrit);
        frame.spellCrit[i] = spellCrit;
    end
    -- Add agility contribution
    --minCrit = minCrit + GetSpellCritChanceFromIntellect();
    minCrit = format("%.2f%%", minCrit);
    frame.minCrit = minCrit;

    return minCrit
end
GW.stats.getSpellCritChance = getSpellCritChance

local function getRangedCritChance()
    local critChance = GetRangedCritChance()
    critChance = format("%.2f%%", critChance);
    local tooltip = HIGHLIGHT_FONT_COLOR_CODE .. RANGED_CRIT_CHANCE .. " " .. critChance .. FONT_COLOR_CODE_CLOSE;
    local tooltip2 = format(CR_CRIT_RANGED_TOOLTIP, GetCombatRating(CR_CRIT_RANGED), GetCombatRatingBonus(CR_CRIT_RANGED));

    return critChance, tooltip, tooltip2
end
GW.stats.getRangedCritChance = getRangedCritChance

local function getMeleeExpertise()
    local expertise, offhandExpertise = GetExpertise();
    local _, offhandSpeed = UnitAttackSpeed("player");
    local exp;
    if( offhandSpeed ) then
        exp = expertise .. " / " .. offhandExpertise;
    else
        exp = expertise;
    end

    local text
    local tooltip = HIGHLIGHT_FONT_COLOR_CODE .. getglobal("COMBAT_RATING_NAME" .. CR_EXPERTISE) .. " " .. exp .. FONT_COLOR_CODE_CLOSE;

    local expertisePercent, offhandExpertisePercent = GetExpertisePercent();
    expertisePercent = format("%.2f", expertisePercent);
    if( offhandSpeed ) then
        offhandExpertisePercent = format("%.2f", offhandExpertisePercent);
        text = expertisePercent.."% / "..offhandExpertisePercent.."%";
    else
        text = expertisePercent.."%";
    end
    local tooltip2 = format(CR_EXPERTISE_TOOLTIP, text, GetCombatRating(CR_EXPERTISE), GetCombatRatingBonus(CR_EXPERTISE));

    return exp, tooltip, tooltip2
end
GW.stats.getMeleeExpertise = getMeleeExpertise

local function getSpellHaste()
    local tooltip = HIGHLIGHT_FONT_COLOR_CODE .. SPELL_HASTE .. FONT_COLOR_CODE_CLOSE;
    local tooltip2 = format(SPELL_HASTE_TOOLTIP, GetCombatRatingBonus(CR_HASTE_SPELL));

    return GetCombatRating(CR_HASTE_SPELL), tooltip, tooltip2
end
GW.stats.getSpellHaste = getSpellHaste

local function getManaReg()
    if ( not UnitHasMana("player") ) then
        return NOT_APPLICABLE, nil, nil
    end

    local base, casting = GetManaRegen(); 
    -- All mana regen stats are displayed as mana/5 sec.
    base = floor( base * 5.0 );
    casting = floor( casting * 5.0 );
    local tooltip = HIGHLIGHT_FONT_COLOR_CODE .. MANA_REGEN .. FONT_COLOR_CODE_CLOSE;
    local tooltip2 = format(MANA_REGEN_TOOLTIP, base, casting);

    return base, tooltip, tooltip2
end
GW.stats.getManaReg = getManaReg

local function getSpellBonusDamage(frame)
    local holySchool = 2;
    -- Start at 2 to skip physical damage
    local minModifier = GetSpellBonusDamage(holySchool)
    frame.bonusDamage = frame.bonusDamage or {}
    frame.bonusDamage[holySchool] = minModifier
    local bonusDamage
    for i = (holySchool + 1), MAX_SPELL_SCHOOLS do
        bonusDamage = GetSpellBonusDamage(i)
        minModifier = min(minModifier, bonusDamage)
        frame.bonusDamage[i] = bonusDamage
    end
    frame.minModifier = minModifier;

    return minModifier
end
GW.stats.getSpellBonusDamage = getSpellBonusDamage

local function getBonusHealing()
    local bonusHealing = GetSpellBonusHealing();
    local tooltip = HIGHLIGHT_FONT_COLOR_CODE .. BONUS_HEALING .. FONT_COLOR_CODE_CLOSE;
    local tooltip2 =format(BONUS_HEALING_TOOLTIP, bonusHealing);

    return bonusHealing, tooltip, tooltip2
end
GW.stats.getBonusHealing = getBonusHealing

local function getAttackPower(unit, prefix)
    if not unit then
        unit = "player"
    end
    if not prefix then
        prefix = "Character"
    end

    local base, posBuff, negBuff = UnitAttackPower(unit)
    local stat, tooltip = formateStat(MELEE_ATTACK_POWER, base, posBuff, negBuff)
    local tooltip2 = format(MELEE_ATTACK_POWER_TOOLTIP, max((base+posBuff+negBuff), 0) / ATTACK_POWER_MAGIC_NUMBER)
    return stat, tooltip, tooltip2
end
GW.stats.getAttackPower = getAttackPower

local function getRangedDamage(unit, prefix)
    if not unit then
        unit = "player"
    elseif unit == "pet" then
        return
    end
    if not prefix then
        prefix = "Character"
    end

    local stat
    local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage(unit)
    if rangedAttackSpeed == 0 then
        return nil
    end

    local displayMin = max(floor(minDamage), 1)
    local displayMax = max(ceil(maxDamage), 1)

    minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
    maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

    local baseDamage = (minDamage + maxDamage) * 0.5
    local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
    local totalBonus = (fullDamage - baseDamage)
    local damagePerSecond = (max(fullDamage, 1) / rangedAttackSpeed)
    local tooltip = max(floor(minDamage), 1) .. " - " .. max(ceil(maxDamage), 1)

    if totalBonus == 0 then
        if (displayMin < 100) and (displayMax < 100) then
            stat = displayMin .. " - ".. displayMax
        else
            stat = displayMin .. "-" .. displayMax
        end
    else
        local colorPos = "|cff20ff20"
        local colorNeg = "|cffff2020"
        local color
        if totalBonus > 0 then
            color = colorPos
        else
            color = colorNeg
        end
        if (displayMin < 100) and (displayMax < 100) then
            stat = color .. displayMin .. " - " .. displayMax .. "|r"
        else
            stat = color .. displayMin .. "-" .. displayMax .. "|r"
        end
        if physicalBonusPos > 0 then
            tooltip = tooltip .. colorPos .. " +" .. physicalBonusPos .. "|r"
        end
        if physicalBonusNeg < 0 then
            tooltip = tooltip .. colorNeg .. " " .. physicalBonusNeg .. "|r"
        end
        if percent > 1 then
            tooltip = tooltip .. colorPos .. " x" .. floor(percent * 100 + 0.5) .. "%|r"
        elseif percent < 1 then
            tooltip = tooltip .. colorNeg .. " x" .. floor(percent * 100 + 0.5) .. "%|r"
        end
    end

    local tooltip2 = ATTACK_SPEED_COLON .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", rangedAttackSpeed) .. FONT_COLOR_CODE_CLOSE .. "\n"
    tooltip2 = tooltip2 .. DAMAGE_COLON .. HIGHLIGHT_FONT_COLOR_CODE .. tooltip .. FONT_COLOR_CODE_CLOSE .. "\n"
    tooltip2 = tooltip2 .. DAMAGE_PER_SECOND .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.1F", damagePerSecond) .. FONT_COLOR_CODE_CLOSE .. "\n"
    tooltip = HIGHLIGHT_FONT_COLOR_CODE .. INVTYPE_RANGED..FONT_COLOR_CODE_CLOSE
    return stat, tooltip, tooltip2
end
GW.stats.getRangedDamage = getRangedDamage

local function getRangedAttackPower(unit    )
    if not unit then
        unit = "player"
    end

    local stat, tooltip, tooltip2
    local base, posBuff, negBuff = UnitRangedAttackPower(unit)

    stat, tooltip = formateStat(RANGED_ATTACK_POWER, base, posBuff, negBuff)
	local totalAP = base + posBuff + negBuff
	tooltip2 = format(RANGED_ATTACK_POWER_TOOLTIP, max((totalAP), 0) / ATTACK_POWER_MAGIC_NUMBER)
	local petAPBonus = ComputePetBonus( "PET_BONUS_RAP_TO_AP", totalAP )
	if petAPBonus > 0 then
		tooltip2 = tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER, math.floor(petAPBonus));
	end

	local petSpellDmgBonus = ComputePetBonus( "PET_BONUS_RAP_TO_SPELLDMG", totalAP );
	if( petSpellDmgBonus > 0 ) then
		tooltip2 = tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_SPELLDAMAGE, math.floor(petSpellDmgBonus));
	end

    return stat, tooltip, tooltip2
end
GW.stats.getRangedAttackPower = getRangedAttackPower

local function getResitance(i, unit)
    local resistance
    local positive
    local negative
    local base
    local stat
    local tooltip
    local tooltip2

    if unit == nil then unit = "player" end

    base, resistance, positive, negative = UnitResistance(unit, i)

    -- resistances can now be negative. Show Red if negative, Green if positive, white otherwise
    if abs(negative) > positive then
        stat = RED_FONT_COLOR_CODE .. resistance .. FONT_COLOR_CODE_CLOSE
    elseif abs(negative) == positive then
        stat = resistance
    else
        stat = GREEN_FONT_COLOR_CODE .. resistance .. FONT_COLOR_CODE_CLOSE
    end

    local resistanceName = _G["RESISTANCE" .. i .. "_NAME"]
    tooltip = resistanceName .. " " .. resistance
    if positive ~= 0 or negative ~= 0 then
        -- Otherwise build up the formula
        tooltip = tooltip .. " ( " .. HIGHLIGHT_FONT_COLOR_CODE .. base
        if positive > 0 then
            tooltip = tooltip .. GREEN_FONT_COLOR_CODE .. " +" .. positive
        end
        if negative < 0 then
            tooltip = tooltip .. " " .. RED_FONT_COLOR_CODE .. negative
        end
        tooltip = tooltip .. FONT_COLOR_CODE_CLOSE .. " )"
    end

    local unitLevel = UnitLevel(unit)
    local resistanceLevel
    unitLevel = max(unitLevel, 20)
    local magicResistanceNumber = resistance / unitLevel
    if magicResistanceNumber > 5 then
        resistanceLevel = RESISTANCE_EXCELLENT
    elseif magicResistanceNumber > 3.75 then
        resistanceLevel = RESISTANCE_VERYGOOD
    elseif magicResistanceNumber > 2.5 then
        resistanceLevel = RESISTANCE_GOOD
    elseif magicResistanceNumber > 1.25 then
        resistanceLevel = RESISTANCE_FAIR
    elseif magicResistanceNumber > 0 then
        resistanceLevel = RESISTANCE_POOR
    else
        resistanceLevel = RESISTANCE_NONE
    end
    tooltip2 = format(RESISTANCE_TOOLTIP_SUBTEXT, _G["RESISTANCE_TYPE" .. i], unitLevel, resistanceLevel)
    return resistanceName, stat, tooltip, tooltip2
end
GW.stats.getResitance = getResitance
