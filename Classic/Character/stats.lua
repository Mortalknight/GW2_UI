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
    local classStatText = _G[strupper(classFileName or "") .. "_" .. PRIMARY_STATS[i] .. "_" .. "TOOLTIP"]

    -- If can't find one use the default
    if not classStatText then
        classStatText = _G["DEFAULT" .. "_" .. PRIMARY_STATS[i] .. "_" .. "TOOLTIP"]
    end

    if posBuff == 0 and negBuff == 0 then
        statText = effectiveStat
        tooltip = tooltipText .. effectiveStat .. FONT_COLOR_CODE_CLOSE
        tooltip2 = classStatText
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
        tooltip2 = classStatText

        -- If there are any negative buffs then show the main number in red even if there are
        -- positive buffs. Otherwise show in green.
        if negBuff < 0 then
            statText = RED_FONT_COLOR_CODE .. effectiveStat .. FONT_COLOR_CODE_CLOSE
        else
            statText = GREEN_FONT_COLOR_CODE .. effectiveStat .. FONT_COLOR_CODE_CLOSE
        end
    end

    return _G["SPELL_STAT" .. i .. "_NAME"], statText, tooltip, tooltip2
end
GW.stats.getPrimary = getPrimary

local function getArmor(unit, prefix)
    if not unit then
        unit = "player"
    end
    if not prefix then
        prefix = "Character"
    end

    local stat
    local tooltip
    local tooltip2
    local base, effectiveArmor, _, posBuff, negBuff = UnitArmor(unit)

    stat, tooltip = formateStat(ARMOR, base, posBuff, negBuff)
    local playerLevel = UnitLevel(unit)
    local armorReduction = effectiveArmor / ((85 * playerLevel) + 400)
    armorReduction = 100 * (armorReduction / (armorReduction + 1))

    tooltip2 = format(ARMOR_TOOLTIP, playerLevel, armorReduction)
    return stat, tooltip, tooltip2
end
GW.stats.getArmor = getArmor



local function getDefense(unit)
    local numSkills = GetNumSkillLines()
    local skillIndex = 0
    local stat
    local tooltip
    local tooltip2

    for i = 1, numSkills do
        local skillName = select(1, GetSkillLineInfo(i))
        local isHeader = select(2, GetSkillLineInfo(i))

        if (isHeader == nil or (not isHeader)) and (skillName == DEFENSE) then
            skillIndex = i
            break
        end
    end

    local skillRank = 0
    local skillModifier = 0
    if (skillIndex > 0) then
        skillRank = select(4, GetSkillLineInfo(skillIndex))
        skillModifier = select(6, GetSkillLineInfo(skillIndex))
    end
    
    skillModifier = skillModifier + GW.stats._GetTalentModifierDefense()

    local posBuff = 0
    local negBuff = 0
    if skillModifier > 0 then
        posBuff = skillModifier
    elseif skillModifier < 0 then
        negBuff = skillModifier
    end
    stat, tooltip = formateStat(DEFENSE_COLON, skillRank, posBuff, negBuff)
    local valueNum = max(0, skillRank + posBuff + negBuff)
    tooltip2 = format(DEFAULT_STATDEFENSE_TOOLTIP, valueNum, 0, valueNum * 0.04, valueNum * 0.04)
    tooltip2 = tooltip2:gsub('.-\n', '', 1)
    tooltip2 = tooltip2:gsub('%b()', '')

    return stat, tooltip, tooltip2
end
GW.stats.getDefense = getDefense

local function getAttackBothHands(unit, prefix)
    if not unit then
        unit = "player";
    end
    if not prefix then
        prefix = "Character"
    end

    local stat
    local mainHandAttackBase, mainHandAttackMod = UnitAttackBothHands(unit)

    if mainHandAttackMod == 0 then
        stat = mainHandAttackBase
    else
        local color = RED_FONT_COLOR_CODE
        if mainHandAttackMod > 0 then
            color = GREEN_FONT_COLOR_CODE
        end
        stat = color .. (mainHandAttackBase + mainHandAttackMod) .. FONT_COLOR_CODE_CLOSE
    end

    return stat, ATTACK_TOOLTIP, ATTACK_TOOLTIP_SUBTEXT
end
GW.stats.getAttackBothHands = getAttackBothHands

local function getDamage(unit, prefix)
    if not unit then
        unit = "player"
    end
    if not prefix then
        prefix = "Character"
    end

    local stat
    local damageText = _G[prefix .. "DamageFrameStatText"]
    local damageFrame = _G[prefix .. "DamageFrame"]
    local speed, offhandSpeed = UnitAttackSpeed(unit)
    local minDamage
    local maxDamage
    local minOffHandDamage
    local maxOffHandDamage
    local physicalBonusPos
    local physicalBonusNeg
    local percent
    minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage(unit)
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

local function getRangedAttack(unit, prefix)
    if not unit then
        unit = "player"
    elseif unit == "pet" then
        return
    end
    if not prefix then
        prefix = "Character"
    end

    local hasRelic = UnitHasRelicSlot(unit)
    local rangedAttackBase, rangedAttackMod = UnitRangedAttack(unit)

    if rangedAttackBase == 0 then
        return nil
    end

    local stat
    local tooltip
    local tooltip2
    
    -- If no ranged texture then set stats to n/a
    local rangedTexture = GetInventoryItemTexture("player", 18)
    if rangedTexture and not hasRelic then
        --do nothing
    else
        stat = NOT_APPLICABLE
        tooltip = nil
    end
    if not rangedTexture or hasRelic then
        return nil,nil, nil
    end

    if rangedAttackMod == 0 then
        stat = rangedAttackBase
    else
        local color = RED_FONT_COLOR_CODE
        if rangedAttackMod > 0 then
            color = GREEN_FONT_COLOR_CODE
        end
        stat = color .. (rangedAttackBase + rangedAttackMod) .. FONT_COLOR_CODE_CLOSE
    end

    tooltip = RANGED_ATTACK_TOOLTIP
    tooltip2 = ATTACK_TOOLTIP_SUBTEXT
    return stat, tooltip, tooltip2
end
GW.stats.getRangedAttack = getRangedAttack

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

local function getRangedAttackPower(unit, prefix)
    if not unit then
        unit = "player"
    elseif unit == "pet" then
        return
    end
    if not prefix then
        prefix = "Character"
    end

    local stat
    -- If no ranged attack then set to n/a
    if HasWandEquipped() then
        stat = "--"
        return
    end

    local base, posBuff, negBuff = UnitRangedAttackPower(unit)
    local tooltip, tooltip2
    stat, tooltip = formateStat(RANGED_ATTACK_POWER, base, posBuff, negBuff)

    tooltip2 = format(RANGED_ATTACK_POWER_TOOLTIP, base / ATTACK_POWER_MAGIC_NUMBER)
    return stat, tooltip,tooltip2
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
