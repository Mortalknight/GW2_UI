local _, GW = ...

local function setUpStatFrame(frame, func, header, yOffset, numShown, sectionHeight)
    local isShown
    func(frame, "player")
    isShown = frame:IsShown()

    frame:ClearAllPoints()
    frame:SetPoint("TOP", header, "BOTTOM", 0, -((numShown * 15) + 5))

    if isShown then
        numShown = numShown + 1
        sectionHeight = sectionHeight + frame:GetHeight()
    end

    return yOffset, numShown, sectionHeight
end

local function updateValues(self)
    -- Meele
    local totalHeight = 0
    local sectionHeight = 0
    local yOffset = 0
    local numShown = 0
    yOffset, numShown, sectionHeight = setUpStatFrame(self.meeleSection.damage, PaperDollFrame_SetDamage, self.meeleSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.meeleSection.dps, PaperDollFrame_SetMeleeDPS, self.meeleSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.meeleSection.attackPower, PaperDollFrame_SetAttackPower, self.meeleSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.meeleSection.attackSpeed, PaperDollFrame_SetAttackSpeed, self.meeleSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.meeleSection.haste, PaperDollFrame_SetMeleeHaste, self.meeleSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.meeleSection.hitChange, PaperDollFrame_SetMeleeHitChance, self.meeleSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.meeleSection.critChance, PaperDollFrame_SetMeleeCritChance, self.meeleSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.meeleSection.expertise, PaperDollFrame_SetExpertise, self.meeleSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.meeleSection.energyRegen, PaperDollFrame_SetEnergyRegen, self.meeleSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.meeleSection.runeRegen, PaperDollFrame_SetRuneRegen, self.meeleSection.Header, yOffset, numShown, sectionHeight)
    self.meeleSection:SetHeight(sectionHeight)
    totalHeight = totalHeight + sectionHeight
    --Range
    sectionHeight = 0
    yOffset = 0
    numShown = 0

    yOffset, numShown, sectionHeight = setUpStatFrame(self.rangeSection.damage, PaperDollFrame_SetRangedDamage, self.rangeSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.rangeSection.dps, PaperDollFrame_SetRangedDPS, self.rangeSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.rangeSection.attackPower, PaperDollFrame_SetRangedAttackPower, self.rangeSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.rangeSection.attackSpeed, PaperDollFrame_SetRangedAttackSpeed, self.rangeSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.rangeSection.critChance, PaperDollFrame_SetRangedCritChance, self.rangeSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.rangeSection.hitChange, PaperDollFrame_SetRangedHitChance, self.rangeSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.rangeSection.haste, PaperDollFrame_SetRangedHaste, self.rangeSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.rangeSection.regen, PaperDollFrame_SetFocusRegen, self.rangeSection.Header, yOffset, numShown, sectionHeight)
    self.rangeSection:SetHeight(sectionHeight)
    totalHeight = totalHeight + sectionHeight
    --Spell
    sectionHeight = 0
    yOffset = 0
    numShown = 0

    yOffset, numShown, sectionHeight = setUpStatFrame(self.spellSection.spellBonus, PaperDollFrame_SetSpellBonusDamage, self.spellSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.spellSection.bonusHealing, PaperDollFrame_SetSpellBonusHealing, self.spellSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.spellSection.spellHaste, PaperDollFrame_SetSpellHaste, self.spellSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.spellSection.hitChance, PaperDollFrame_SetSpellHitChance, self.spellSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.spellSection.regen, PaperDollFrame_SetManaRegen, self.spellSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.spellSection.combatManaRegen, PaperDollFrame_SetCombatManaRegen, self.spellSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.spellSection.critChance, PaperDollFrame_SetSpellCritChance, self.spellSection.Header, yOffset, numShown, sectionHeight)
    self.spellSection:SetHeight(sectionHeight)
    totalHeight = totalHeight + sectionHeight
    --Defense
    sectionHeight = 0
    yOffset = 0
    numShown = 0

    yOffset, numShown, sectionHeight = setUpStatFrame(self.defenseSection.dodge, PaperDollFrame_SetDodge, self.defenseSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.defenseSection.parry, PaperDollFrame_SetParry, self.defenseSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.defenseSection.block, PaperDollFrame_SetBlock, self.defenseSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.defenseSection.resilReduction, PaperDollFrame_SetResilience, self.defenseSection.Header, yOffset, numShown, sectionHeight)
    yOffset, numShown, sectionHeight = setUpStatFrame(self.defenseSection.pvpPower, PaperDollFrame_SetPvpPower, self.defenseSection.Header, yOffset, numShown, sectionHeight)
    self.defenseSection:SetHeight(sectionHeight)
    totalHeight = totalHeight + sectionHeight

    self:SetHeight(totalHeight + 120)
end

local function CreateSection(width, height, parent, anchor1, anchorTo, anchor2, yOffset)
    local section = CreateFrame("Frame", nil, parent)
    section:SetSize(width, height)
    section:SetPoint(anchor1, anchorTo, anchor2, 0, yOffset)

    local header = CreateFrame("Frame", nil, section)
    header:SetSize(width, 30)
    header:SetPoint("TOP", section)
    section.Header = header

    local text = section.Header:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
    text:SetPoint("LEFT")
    text:SetPoint("BOTTOM")
    text:SetJustifyH("LEFT")
    text:SetJustifyV("MIDDLE")

    local font, fontHeight, fontFlags = text:GetFont()
    text:SetFont(font, fontHeight * 1.1, fontFlags)
    section.Header.Text = text

    return section
end

local function CreateStatsFrame(parent, anchorTo, width, globalName, specialOnEnter)
    local statFrame = CreateFrame("Frame", "GwHeroPanelStats_" .. globalName, parent)
    statFrame:SetSize(width, 15)
    statFrame:SetPoint("TOP", anchorTo, "BOTTOM", 0, -5)

    local textL = statFrame:CreateFontString("GwHeroPanelStats_" .. globalName .. "Label", "ARTWORK", "SystemFont_Outline")
    textL:SetPoint("TOPLEFT", statFrame, "TOPLEFT", 0, 0)
    textL:SetJustifyH("LEFT")
    textL:SetJustifyV("MIDDLE")
    statFrame.Label = textL

    local textR = statFrame:CreateFontString("GwHeroPanelStats_" .. globalName .. "StatText", "ARTWORK", "SystemFont_Outline")
    textR:SetPoint("TOPRIGHT", statFrame, "TOPRIGHT", -10, 0)
    textR:SetJustifyH("RIGHT")
    textR:SetJustifyV("MIDDLE")
    statFrame.Value = textR

    statFrame:SetScript("OnLeave", GameTooltip_Hide)
    if specialOnEnter then
        statFrame:SetScript("OnEnter", specialOnEnter)
    else
        statFrame:SetScript("OnEnter", function(self)
            if not self.tooltip then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true)
            if self.tooltip2 then
                GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
            end
            GameTooltip:Show()
        end)
    end

    return statFrame
end

local function CreateAdvancedChatStats(parent)
    local as = CreateFrame("Frame", nil, parent)
    as:SetPoint("TOPLEFT", parent, "TOPRIGHT", 19, 60)
    as:SetSize(200, parent:GetHeight() + 170)

    as:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 10, 10)

    as.header = as:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
    as.header:SetPoint("TOP")
    as.header:SetJustifyH("CENTER")
    as.header:SetJustifyV("MIDDLE")

    local font, fontHeight, fontFlags = as.header:GetFont()
    as.header:SetFont(font, fontHeight * 1.3, fontFlags)
    as.header:SetText(ADVANCED_LABEL .. " " .. STAT_CATEGORY_ATTRIBUTES)

    as.meeleSection =  CreateSection(200, 80, as, "TOP", as.header, "TOP", -20)
    as.meeleSection.Header.Text:SetText(PLAYERSTAT_MELEE_COMBAT)
    as.meeleSection.damage = CreateStatsFrame(as.meeleSection, as.meeleSection.Header, 180, "MEELE_DMG")
    as.meeleSection.dps = CreateStatsFrame(as.meeleSection, as.meeleSection.damage, 180, "MEELE_DPS")
    as.meeleSection.attackPower = CreateStatsFrame(as.meeleSection, as.meeleSection.dps, 180, "MEELE_AP")
    as.meeleSection.attackSpeed = CreateStatsFrame(as.meeleSection, as.meeleSection.attackPower, 180, "MEELE_AS")
    as.meeleSection.haste = CreateStatsFrame(as.meeleSection, as.meeleSection.attackSpeed, 180, "MEELE_HAST")
    as.meeleSection.hitChange = CreateStatsFrame(as.meeleSection, as.meeleSection.haste, 180, "MEELE_HC")
    as.meeleSection.critChance = CreateStatsFrame(as.meeleSection, as.meeleSection.hitChange, 180, "MEELE_CC")
    as.meeleSection.expertise = CreateStatsFrame(as.meeleSection, as.meeleSection.critChance, 180, "MEELE_EXP")
    as.meeleSection.energyRegen = CreateStatsFrame(as.meeleSection, as.meeleSection.expertise, 180, "MEELE_ER")
    as.meeleSection.runeRegen = CreateStatsFrame(as.meeleSection, as.meeleSection.energyRegen, 180, "MEELE_RR")

    as.rangeSection =  CreateSection(200, 60, as, "TOP", as.meeleSection, "BOTTOM", -25)
    as.rangeSection.Header.Text:SetText(PLAYERSTAT_RANGED_COMBAT)
    as.rangeSection.damage = CreateStatsFrame(as.rangeSection, as.rangeSection.Header, 180, "RANGE_DMG")
    as.rangeSection.dps = CreateStatsFrame(as.rangeSection, as.rangeSection.damage, 180, "RANGE_DPS")
    as.rangeSection.attackPower = CreateStatsFrame(as.rangeSection, as.rangeSection.dps, 180, "RANGE_AP")
    as.rangeSection.attackSpeed = CreateStatsFrame(as.rangeSection, as.rangeSection.attackPower, 180, "RANGE_AS")
    as.rangeSection.critChance = CreateStatsFrame(as.rangeSection, as.rangeSection.attackSpeed, 180, "RANGE_CC")
    as.rangeSection.hitChange = CreateStatsFrame(as.rangeSection, as.rangeSection.critChance, 180, "RANGE_HT")
    as.rangeSection.haste = CreateStatsFrame(as.rangeSection, as.rangeSection.hitChange, 180, "RANGE_HASTE")
    as.rangeSection.regen = CreateStatsFrame(as.rangeSection, as.rangeSection.haste, 180, "RANGE_REGEN")

    as.spellSection =  CreateSection(200, 120, as, "TOP", as.rangeSection, "BOTTOM", -25)
    as.spellSection.Header.Text:SetText(PLAYERSTAT_SPELL_COMBAT)
    as.spellSection.spellBonus = CreateStatsFrame(as.spellSection, as.spellSection.Header, 180, "SPELL_DMG", CharacterSpellBonusDamage_OnEnter)
    as.spellSection.bonusHealing = CreateStatsFrame(as.spellSection, as.spellSection.spellBonus, 180, "SPELL_HEALING", CharacterSpellBonusDamage_OnEnter)
    as.spellSection.spellHaste = CreateStatsFrame(as.spellSection, as.spellSection.bonusHealing, 180, "SPELL_HASTE")
    as.spellSection.hitChance = CreateStatsFrame(as.spellSection, as.spellSection.spellHaste, 180, "SPELL_HC")
    as.spellSection.regen = CreateStatsFrame(as.spellSection, as.spellSection.penetration, 180, "SPELL_REGEN")
    as.spellSection.combatManaRegen = CreateStatsFrame(as.spellSection, as.spellSection.regen, 180, "SPELL_CMR")
    as.spellSection.critChance = CreateStatsFrame(as.spellSection, as.spellSection.combatManaRegen, 180, "SPELL_CC", CharacterSpellCritChance_OnEnter)

    as.defenseSection =  CreateSection(200, 80, as, "TOP", as.spellSection, "BOTTOM", -20)
    as.defenseSection.Header.Text:SetText(PLAYERSTAT_DEFENSES)
    as.defenseSection.dodge = CreateStatsFrame(as.defenseSection, as.defenseSection.Header, 180, "DEFENS_DODGE")
    as.defenseSection.parry = CreateStatsFrame(as.defenseSection, as.defenseSection.dodge, 180, "DEFENS_PARRY")
    as.defenseSection.block = CreateStatsFrame(as.defenseSection, as.defenseSection.parry, 180, "DEFENS_BLOCK")
    as.defenseSection.resilReduction = CreateStatsFrame(as.defenseSection, as.defenseSection.block, 180, "DEFENS_RESIL")
    as.defenseSection.pvpPower = CreateStatsFrame(as.defenseSection, as.defenseSection.resilReduction, 180, "PVP_POWER")

    parent.advancedStatsFrameCreated = true
    parent.advancedStatsFrame = as
    as:SetScript("OnShow", updateValues)
    as:SetScript("OnEvent", updateValues)

    as:RegisterEvent("CHARACTER_POINTS_CHANGED")
    as:RegisterEvent("UNIT_MODEL_CHANGED")
    as:RegisterEvent("UNIT_LEVEL")
    as:RegisterEvent("UNIT_STATS")
    as:RegisterEvent("UNIT_RANGEDDAMAGE")
    as:RegisterEvent("UNIT_ATTACK_POWER")
    as:RegisterEvent("UNIT_RANGED_ATTACK_POWER")
    as:RegisterEvent("UNIT_ATTACK")
    as:RegisterEvent("UNIT_SPELL_HASTE")
    as:RegisterEvent("UNIT_RESISTANCES")
    as:RegisterEvent("PLAYER_GUILD_UPDATE")
    as:RegisterEvent("SKILL_LINES_CHANGED")
    as:RegisterEvent("COMBAT_RATING_UPDATE")
    as:RegisterEvent("UNIT_NAME_UPDATE")
    as:RegisterEvent("BAG_UPDATE")
    as:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    as:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    as:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
    as:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
    as:RegisterEvent("SPELL_POWER_CHANGED")
    as:RegisterEvent("CHARACTER_ITEM_FIXUP_NOTIFICATION")
    as:RegisterEvent("UNIT_NAME_UPDATE")
    as:RegisterEvent("UNIT_INVENTORY_CHANGED")
    as:RegisterEvent("UPDATE_INVENTORY_ALERTS")
    as:Hide()
end
local function ShowAdvancedChatStats(parent)
    if not parent.advancedStatsFrameCreated then CreateAdvancedChatStats(parent) end

    parent.advancedStatsFrame:SetShown(not parent.advancedStatsFrame:IsShown())
end
GW.ShowAdvancedChatStats = ShowAdvancedChatStats
