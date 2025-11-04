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

local function formateStat(name, base, posBuff, negBuff)
    local effective = max(0, base + posBuff + negBuff)
    local text = HIGHLIGHT_FONT_COLOR_CODE .. name .. " " .. BreakUpLargeNumbers(effective)
    local stat
    if posBuff == 0 and negBuff == 0 then
        text = text .. FONT_COLOR_CODE_CLOSE
        stat = BreakUpLargeNumbers(effective)
    else
        if posBuff > 0 or negBuff < 0 then
            text = text .. " (" .. BreakUpLargeNumbers(base) .. FONT_COLOR_CODE_CLOSE
        end
        if posBuff > 0 then
            text = text .. FONT_COLOR_CODE_CLOSE .. GREEN_FONT_COLOR_CODE .. "+" .. BreakUpLargeNumbers(posBuff) .. FONT_COLOR_CODE_CLOSE
        end
        if negBuff < 0 then
            text = text .. RED_FONT_COLOR_CODE .. " " .. BreakUpLargeNumbers(negBuff) .. FONT_COLOR_CODE_CLOSE
        end
        if posBuff > 0 or negBuff < 0 then
            text = text .. HIGHLIGHT_FONT_COLOR_CODE .. ")" .. FONT_COLOR_CODE_CLOSE
        end

        -- if there is a negative buff then show the main number in red, even if there are
        -- positive buffs. Otherwise show the number in green
        if negBuff < 0 then
            stat = RED_FONT_COLOR_CODE .. BreakUpLargeNumbers(effective) .. FONT_COLOR_CODE_CLOSE
        else
            stat = GREEN_FONT_COLOR_CODE .. BreakUpLargeNumbers(effective) .. FONT_COLOR_CODE_CLOSE
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
    local classStatText = _G[strupper(classFileName or "") .. "_" .. PRIMARY_STATS[i] .. "_" .. "TOOLTIP"]

    -- If can't find one use the default
    if not classStatText then
        classStatText = _G["DEFAULT" .. "_" .. PRIMARY_STATS[i] .. "_" .. "TOOLTIP"]
    end

    if posBuff == 0 and negBuff == 0 then
        statText = BreakUpLargeNumbers(effectiveStat)
        tooltip = tooltipText .. BreakUpLargeNumbers(effectiveStat) .. FONT_COLOR_CODE_CLOSE
    else
        tooltipText = tooltipText .. BreakUpLargeNumbers(effectiveStat)
        if posBuff > 0 or negBuff < 0 then
            tooltipText = tooltipText .. " (" .. BreakUpLargeNumbers(stat - posBuff - negBuff) .. FONT_COLOR_CODE_CLOSE
        end
        if posBuff > 0 then
            tooltipText = tooltipText .. FONT_COLOR_CODE_CLOSE .. GREEN_FONT_COLOR_CODE .. "+" .. BreakUpLargeNumbers(posBuff) .. FONT_COLOR_CODE_CLOSE
        end
        if negBuff < 0 then
            tooltipText = tooltipText .. RED_FONT_COLOR_CODE .. " " .. BreakUpLargeNumbers(negBuff) .. FONT_COLOR_CODE_CLOSE
        end
        if posBuff > 0 or negBuff < 0 then
            tooltipText = tooltipText .. HIGHLIGHT_FONT_COLOR_CODE .. ")" .. FONT_COLOR_CODE_CLOSE
        end
        tooltip = tooltipText

        -- If there are any negative buffs then show the main number in red even if there are
        -- positive buffs. Otherwise show in green.
        if negBuff < 0 then
            statText = RED_FONT_COLOR_CODE .. BreakUpLargeNumbers(effectiveStat) .. FONT_COLOR_CODE_CLOSE
        else
            statText = GREEN_FONT_COLOR_CODE .. BreakUpLargeNumbers(effectiveStat) .. FONT_COLOR_CODE_CLOSE
        end
    end
    tooltip2 = getglobal("DEFAULT_STAT"..i.."_TOOLTIP")
    local _, unitClass = UnitClass("player")
	unitClass = strupper(unitClass)

    if i == 1 then
		local attackPower = GetAttackPowerForStat(i,effectiveStat);
		tooltip2 = format(tooltip2, attackPower);
    elseif ( i == 2 ) then
        local attackPower = GetAttackPowerForStat(i,effectiveStat);
        if ( attackPower > 0 ) then
            tooltip2 = format(STAT_TOOLTIP_BONUS_AP, attackPower) .. format(tooltip2, GetCritChanceFromAgility("player"));
        else
            tooltip2 = format(tooltip2, GetCritChanceFromAgility("player"));
        end
	elseif i == 3 then
		local baseStam = min(20, effectiveStat);
        local moreStam = effectiveStat - baseStam;
        tooltip2 = format(tooltip2, (baseStam + (moreStam*UnitHPPerStamina("player")))*GetUnitMaxHealthModifier("player"));
	elseif i == 4 then
		if ( UnitHasMana("player") ) then
            local baseInt = min(20, effectiveStat);
		    local moreInt = effectiveStat - baseInt
            if (GetOverrideSpellPowerByAP() ~= nil) then
                tooltip2 = format(STAT4_NOSPELLPOWER_TOOLTIP, baseInt + moreInt*MANA_PER_INTELLECT, GetSpellCritChanceFromIntellect("player"));
            else
                tooltip2 = format(tooltip2, baseInt + moreInt*MANA_PER_INTELLECT, max(0, effectiveStat-10), GetSpellCritChanceFromIntellect("player"));
            end
		else
			tooltip2 = STAT_USELESS_TOOLTIP;
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
		if ( UnitHasMana("player") ) then
            local regen = GetUnitManaRegenRateFromSpirit("player");
            regen = floor( regen * 5.0 );
            tooltip2 = format(MANA_REGEN_FROM_SPIRIT, regen);
        else
            tooltip2 = STAT_USELESS_TOOLTIP;
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
    local damageTooltip = BreakUpLargeNumbers(max(floor(minDamage), 1)) .. " - " .. BreakUpLargeNumbers(max(ceil(maxDamage), 1))

    local colorPos = "|cff20ff20"
    local colorNeg = "|cffff2020"

    	-- epsilon check
	if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
		totalBonus = 0.0;
	end

    if totalBonus == 0 then
        if displayMin < 100 and displayMax < 100 then
            stat = BreakUpLargeNumbers(displayMin) .. " - " ..  BreakUpLargeNumbers(displayMax)
        else
            stat =  BreakUpLargeNumbers(displayMin) .. "-" ..  BreakUpLargeNumbers(displayMax)
        end
    else
        local color
        if totalBonus > 0 then
            color = colorPos
        else
            color = colorNeg
        end
        if displayMin < 100 and displayMax < 100 then
            stat = color ..  BreakUpLargeNumbers(displayMin) .. " - " ..  BreakUpLargeNumbers(displayMax) .. "|r"
        else
            stat = color ..  BreakUpLargeNumbers(displayMin) .. "-" ..  BreakUpLargeNumbers(displayMax) .. "|r"
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

    local tooltip2 = ATTACK_SPEED_SECONDS .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", speed) .. FONT_COLOR_CODE_CLOSE .. "\n"
    tooltip2 = tooltip2 .. DAMAGE .. HIGHLIGHT_FONT_COLOR_CODE .. damageTooltip .. FONT_COLOR_CODE_CLOSE .. "\n"
    tooltip2 = tooltip2 .. DAMAGE_PER_SECOND .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.1F", damagePerSecond) .. FONT_COLOR_CODE_CLOSE .. "\n"

    if offhandSpeed then
        tooltip2 = tooltip2 .."\n"
        tooltip2 = tooltip2 .. HIGHLIGHT_FONT_COLOR_CODE .. INVTYPE_WEAPONOFFHAND .. FONT_COLOR_CODE_CLOSE .. "\n"
        tooltip2 = tooltip2 .. ATTACK_SPEED_SECONDS .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", offhandSpeed) .. FONT_COLOR_CODE_CLOSE .. "\n"
        tooltip2 = tooltip2 .. DAMAGE .. HIGHLIGHT_FONT_COLOR_CODE .. offhandDamageTooltip .. FONT_COLOR_CODE_CLOSE .. "\n"
        tooltip2 = tooltip2 .. DAMAGE_PER_SECOND .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.1F", offhandDamagePerSecond) .. FONT_COLOR_CODE_CLOSE .. "\n"
        tooltip2 = tooltip2 .."\n"
        tooltip2 = tooltip2 .. TOTAL .. " " .. DAMAGE .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.1F", (damagePerSecond + offhandDamagePerSecond)) .. FONT_COLOR_CODE_CLOSE
    end

    return stat, tooltip, tooltip2
end
GW.stats.getDamage = getDamage

local function getMastery()
	if (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
		return format("N/A")
	end

	local mastery = GetMastery();
    local _, class = UnitClass("player")
	local masteryBonus = GetCombatRatingBonus(CR_MASTERY)
    local tooltip, tooltip2
	local title = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MASTERY).." "..format("%.2F", mastery)..FONT_COLOR_CODE_CLOSE;
	if (masteryBonus > 0) then
		title = title..HIGHLIGHT_FONT_COLOR_CODE.." ("..format("%.2F", mastery-masteryBonus)..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..format("%.2F", masteryBonus)..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")";
	end
	tooltip = title

    -- Class mastery spells are not used in MoP.
	local isClassMasteryKnownOrUnused = ClassicExpansionAtLeast(LE_EXPANSION_MISTS_OF_PANDARIA) or GW.IsSpellKnown(CLASS_MASTERY_SPELLS[class]);
	local primaryTalentTree = C_SpecializationInfo.GetSpecialization();
	if (isClassMasteryKnownOrUnused and primaryTalentTree) then
		local masterySpells = C_SpecializationInfo.GetSpecializationMasterySpells(primaryTalentTree)
        local hasAddedAnyMasterySpell = false
        for i, masterySpell in ipairs(masterySpells) do
			if hasAddedAnyMasterySpell then
				GameTooltip:AddLine(" ")
			end
			GameTooltip:AddSpellByID(masterySpell)
			hasAddedAnyMasterySpell = true
		end
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, GetCombatRating(CR_MASTERY), masteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	else
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, GetCombatRating(CR_MASTERY), masteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:AddLine(" ");
		if (isClassMasteryKnownOrUnused) then
			GameTooltip:AddLine(STAT_MASTERY_TOOLTIP_NO_TALENT_SPEC, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		else
			GameTooltip:AddLine(STAT_MASTERY_TOOLTIP_NOT_KNOWN, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		end
	end

    return format("%.2F", mastery), tooltip, tooltip2
end
GW.stats.getMastery = getMastery

local function getMovementSpeed()
    return format(STAT_FORMAT, STAT_MOVEMENT_SPEED)
end
GW.stats.getMovementSpeed = getMovementSpeed

local function getAttackPower(unit)
    if not unit then
        unit = "player"
    end

    local base, posBuff, negBuff = UnitAttackPower(unit)
    local stat, tooltip = formateStat(MELEE_ATTACK_POWER, base, posBuff, negBuff)
    local tooltip2 = format(MELEE_ATTACK_POWER_TOOLTIP, max((base+posBuff+negBuff), 0) / ATTACK_POWER_MAGIC_NUMBER)
    return stat, tooltip, tooltip2
end
GW.stats.getAttackPower = getAttackPower

local function getRangedDamage(unit)
    if not unit then
        unit = "player"
    elseif unit == "pet" then
        return
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
            stat = BreakUpLargeNumbers(displayMin) .. " - ".. BreakUpLargeNumbers(displayMax)
        else
            stat = BreakUpLargeNumbers(displayMin) .. "-" .. BreakUpLargeNumbers(displayMax)
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
            stat = color .. BreakUpLargeNumbers(displayMin) .. " - " .. BreakUpLargeNumbers(displayMax) .. "|r"
        else
            stat = color .. BreakUpLargeNumbers(displayMin) .. "-" .. BreakUpLargeNumbers(displayMax) .. "|r"
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

    local tooltip2 = ATTACK_SPEED_SECONDS .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.2F", rangedAttackSpeed) .. FONT_COLOR_CODE_CLOSE .. "\n"
    tooltip2 = tooltip2 .. DAMAGE .. HIGHLIGHT_FONT_COLOR_CODE .. tooltip .. FONT_COLOR_CODE_CLOSE .. "\n"
    tooltip2 = tooltip2 .. DAMAGE_PER_SECOND .. HIGHLIGHT_FONT_COLOR_CODE .. format("%.1F", damagePerSecond) .. FONT_COLOR_CODE_CLOSE .. "\n"
    tooltip = HIGHLIGHT_FONT_COLOR_CODE .. INVTYPE_RANGED..FONT_COLOR_CODE_CLOSE
    return stat, tooltip, tooltip2
end
GW.stats.getRangedDamage = getRangedDamage

local function getRangedAttackPower(unit)
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
        stat = RED_FONT_COLOR_CODE .. BreakUpLargeNumbers(resistance) .. FONT_COLOR_CODE_CLOSE
    elseif abs(negative) == positive then
        stat = resistance
    else
        stat = GREEN_FONT_COLOR_CODE .. BreakUpLargeNumbers(resistance) .. FONT_COLOR_CODE_CLOSE
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
