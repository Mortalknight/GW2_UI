local _, GW = ...

local function updateValues(self)
    local attackspeed, tt1, tt2 = GW.stats.getAttackSpeed()
    self.meeleSection.attackspeed.tt1 = tt1
    self.meeleSection.attackspeed.tt2 = tt2
    self.meeleSection.attackspeed.TextL:SetText(WEAPON_SPEED)
    self.meeleSection.attackspeed.TextR:SetText(attackspeed)

    local rating, tt1, tt2 = GW.stats.getRating(CR_HIT_MELEE)
    self.meeleSection.rating.tt1 = tt1
    self.meeleSection.rating.tt2 = tt2
    self.meeleSection.rating.TextL:SetText(COMBAT_RATING_NAME6)
    self.meeleSection.rating.TextR:SetText(rating)

    local meleeCrit, tt1, tt2 = GW.stats.getMeleeCritChance()
    self.meeleSection.crit.tt1 = tt1
    self.meeleSection.crit.tt2 = tt2
    self.meeleSection.crit.TextL:SetText(MELEE_CRIT_CHANCE)
    self.meeleSection.crit.TextR:SetText(meleeCrit)

    local meleeExp, tt1, tt2 = GW.stats.getMeleeExpertise()
    self.meeleSection.exp.tt1 = tt1
    self.meeleSection.exp.tt2 = tt2
    self.meeleSection.exp.TextL:SetText(STAT_EXPERTISE)
    self.meeleSection.exp.TextR:SetText(meleeExp)

    local rngSpeed, tt1, tt2 = GW.stats.getRangeAttackSpeed()
    self.rangeSection.attackspeed.tt1 = tt1
    self.rangeSection.attackspeed.tt2 = tt2
    self.rangeSection.attackspeed.TextL:SetText(WEAPON_SPEED)
    self.rangeSection.attackspeed.TextR:SetText(rngSpeed)

    local rngRating, tt1, tt2 = GW.stats.getRating(CR_HIT_RANGED)
    self.rangeSection.rating.tt1 = tt1
    self.rangeSection.rating.tt2 = tt2
    self.rangeSection.rating.TextL:SetText(COMBAT_RATING_NAME7)
    self.rangeSection.rating.TextR:SetText(rngRating)

    local rngCrit, tt1, tt2 = GW.stats.getRangedCritChance()
    self.rangeSection.crit.tt1 = tt1
    self.rangeSection.crit.tt2 = tt2
    self.rangeSection.crit.TextL:SetText(RANGED_CRIT_CHANCE)
    self.rangeSection.crit.TextR:SetText(rngCrit)

    self.spellSection.spellBonus.TextL:SetText(BONUS_DAMAGE)
    self.spellSection.spellBonus.TextR:SetText(GW.stats.getSpellBonusDamage(self.spellSection.spellBonus))

    local bonusHealing, tt1, tt2 = GW.stats.getBonusHealing()
    self.spellSection.bonusHealing.tt1 = tt1
    self.spellSection.bonusHealing.tt2 = tt2
    self.spellSection.bonusHealing.TextL:SetText(BONUS_HEALING)
    self.spellSection.bonusHealing.TextR:SetText(bonusHealing)

    local spellRating, tt1, tt2 = GW.stats.getRating(CR_HIT_SPELL)
    self.spellSection.rating.tt1 = tt1
    self.spellSection.rating.tt2 = tt2
    self.spellSection.rating.TextL:SetText(COMBAT_RATING_NAME8)
    self.spellSection.rating.TextR:SetText(spellRating)

    self.spellSection.crit.TextL:SetText(SPELL_CRIT_CHANCE)
    self.spellSection.crit.TextR:SetText(GW.stats.getSpellCritChance(self.spellSection.crit))

    local spellRating, tt1, tt2 = GW.stats.getSpellHaste()
    self.spellSection.hast.tt1 = tt1
    self.spellSection.hast.tt2 = tt2
    self.spellSection.hast.TextL:SetText(SPELL_HASTE)
    self.spellSection.hast.TextR:SetText(spellRating)

    local manaReg, tt1, tt2 = GW.stats.getManaReg()
    self.spellSection.reg.tt1 = tt1
    self.spellSection.reg.tt2 = tt2
    self.spellSection.reg.TextL:SetText(MANA_REGEN)
    self.spellSection.reg.TextR:SetText(manaReg)

    local dodge, tt1, tt2 = GW.stats.getDodge()
    self.defenseSection.dodge.tt1 = tt1
    self.defenseSection.dodge.tt2 = tt2
    self.defenseSection.dodge.TextL:SetText(STAT_DODGE)
    self.defenseSection.dodge.TextR:SetText(dodge)

    local parry, tt1, tt2 = GW.stats.getParry()
    self.defenseSection.parry.tt1 = tt1
    self.defenseSection.parry.tt2 = tt2
    self.defenseSection.parry.TextL:SetText(STAT_PARRY)
    self.defenseSection.parry.TextR:SetText(parry)

    local block, tt1, tt2 = GW.stats.getBlock()
    self.defenseSection.block.tt1 = tt1
    self.defenseSection.block.tt2 = tt2
    self.defenseSection.block.TextL:SetText(STAT_BLOCK)
    self.defenseSection.block.TextR:SetText(block)

    local resil, tt1, tt2 = GW.stats.getResilience()
    self.defenseSection.resil.tt1 = tt1
    self.defenseSection.resil.tt2 = tt2
    self.defenseSection.resil.TextL:SetText(STAT_RESILIENCE)
    self.defenseSection.resil.TextR:SetText(resil)
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

local function CreateStatsFrame(parent, anchorTo, width, specialOnEnter)
    local statFrame = CreateFrame("Frame", nil, parent)
    statFrame:SetSize(width, 15)
    statFrame:SetPoint("TOP", anchorTo, "BOTTOM", 0, -5)

    local textL = statFrame:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
    textL:SetPoint("TOPLEFT", statFrame, "TOPLEFT", 0, 0)
    textL:SetJustifyH("LEFT")
    textL:SetJustifyV("MIDDLE")
    statFrame.TextL = textL

    local textR = statFrame:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
    textR:SetPoint("TOPRIGHT", statFrame, "TOPRIGHT", -10, 0)
    textR:SetJustifyH("RIGHT")
    textR:SetJustifyV("MIDDLE")
    statFrame.TextR = textR

    statFrame:SetScript("OnLeave", GameTooltip_Hide)
    if specialOnEnter then
        statFrame:SetScript("OnEnter", specialOnEnter)
    else
        statFrame:SetScript("OnEnter", function(self)
            if not self.tt1 then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:SetText(self.tt1, nil, nil, nil, nil, true)
            if self.tt2 then
                GameTooltip:AddLine(self.tt2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
            end
            GameTooltip:Show()
        end)
    end

    return statFrame
end

local function CreateAdvancedChatStats(parent)
    local as = CreateFrame("Frame", nil, parent)
    as:SetPoint("TOPLEFT", parent, "TOPRIGHT", 40, 60)
    as:SetSize(200, parent:GetHeight() + 170)

    local tex = as:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", as, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = as:GetSize()
    tex:SetSize(w + 50, h + 50)
    as.tex = tex

    as.header = as:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
    as.header:SetPoint("TOP")
    as.header:SetJustifyH("CENTER")
    as.header:SetJustifyV("MIDDLE")

    local font, fontHeight, fontFlags = as.header:GetFont()
    as.header:SetFont(font, fontHeight * 1.3, fontFlags)
    as.header:SetText(ADVANCED_LABEL .. " " .. STAT_CATEGORY_ATTRIBUTES)

    as.meeleSection =  CreateSection(200, 80, as, "TOP", as.header, "TOP", -20)
    as.meeleSection.Header.Text:SetText(PLAYERSTAT_MELEE_COMBAT)
    as.meeleSection.attackspeed = CreateStatsFrame(as.meeleSection, as.meeleSection.Header, 180)
    as.meeleSection.rating = CreateStatsFrame(as.meeleSection, as.meeleSection.attackspeed, 180)
    as.meeleSection.crit = CreateStatsFrame(as.meeleSection, as.meeleSection.rating, 180)
    as.meeleSection.exp = CreateStatsFrame(as.meeleSection, as.meeleSection.crit, 180)

    as.rangeSection =  CreateSection(200, 60, as, "TOP", as.meeleSection, "BOTTOM", -25)
    as.rangeSection.Header.Text:SetText(PLAYERSTAT_RANGED_COMBAT)
    as.rangeSection.attackspeed = CreateStatsFrame(as.rangeSection, as.rangeSection.Header, 180)
    as.rangeSection.rating = CreateStatsFrame(as.rangeSection, as.rangeSection.attackspeed, 180)
    as.rangeSection.crit = CreateStatsFrame(as.rangeSection, as.rangeSection.rating, 180)

    as.spellSection =  CreateSection(200, 120, as, "TOP", as.rangeSection, "BOTTOM", -25)
    as.spellSection.Header.Text:SetText(PLAYERSTAT_SPELL_COMBAT)
    as.spellSection.spellBonus = CreateStatsFrame(as.spellSection, as.spellSection.Header, 180, CharacterSpellBonusDamage_OnEnter)
    as.spellSection.bonusHealing = CreateStatsFrame(as.spellSection, as.spellSection.spellBonus, 180)
    as.spellSection.rating = CreateStatsFrame(as.spellSection, as.spellSection.bonusHealing, 180)
    as.spellSection.crit = CreateStatsFrame(as.spellSection, as.spellSection.rating, 180, CharacterSpellCritChance_OnEnter)
    as.spellSection.hast = CreateStatsFrame(as.spellSection, as.spellSection.crit, 180)
    as.spellSection.reg = CreateStatsFrame(as.spellSection, as.spellSection.hast, 180)

    as.defenseSection =  CreateSection(200, 80, as, "TOP", as.spellSection, "BOTTOM", -20)
    as.defenseSection.Header.Text:SetText(PLAYERSTAT_DEFENSES)
    as.defenseSection.dodge = CreateStatsFrame(as.defenseSection, as.defenseSection.Header, 180)
    as.defenseSection.parry = CreateStatsFrame(as.defenseSection, as.defenseSection.dodge, 180)
    as.defenseSection.block = CreateStatsFrame(as.defenseSection, as.defenseSection.parry, 180)
    as.defenseSection.resil = CreateStatsFrame(as.defenseSection, as.defenseSection.block, 180)


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
