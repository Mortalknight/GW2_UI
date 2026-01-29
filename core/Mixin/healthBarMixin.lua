local _, GW = ...

GwUnitHealthbarMixin = {}

function GwUnitHealthbarMixin:UpdateHealthTextString(health, healthPrecentage)
    local text = ""
    if GW.Retail then
        local formatFunc = self.shortendHealthValues and AbbreviateNumbers or BreakUpLargeNumbers
        local pctText = string.format("%.0f%%", UnitHealthPercent(self.unit, true, CurveConstants.ScaleTo100))
        if self.showHealthValue and self.showHealthPrecentage then
            text = self.frameInvert and (string.format("%s - %s", pctText, formatFunc(health))) or (string.format("%s - %s", formatFunc(health), pctText))
        elseif self.showHealthValue then
            text = formatFunc(health)
        elseif self.showHealthPrecentage then
            text = pctText
        end
    else
        local formatFunc = self.shortendHealthValues and GW.ShortValue or GW.GetLocalizedNumber
        local pctText = GW.RoundDec(healthPrecentage * 100, 0) .. "%"

        if self.showHealthValue and self.showHealthPrecentage then
            text = self.frameInvert and (pctText .. " - " .. formatFunc(health)) or (formatFunc(health) .. " - " .. pctText)
        elseif self.showHealthValue then
            text = formatFunc(health)
        elseif self.showHealthPrecentage then
            text = pctText
        end
    end

    self.healthString:SetText(text)
end

function GwUnitHealthbarMixin:UpdateHealthBar(forceUpdate)
    if GW.Retail then
        local statusBarAnimation = forceUpdate and Enum.StatusBarInterpolation.Immediate or Enum.StatusBarInterpolation.ExponentialEaseOut
        local unit = self.unit
        local health = UnitHealth(unit)
        local healthMax = UnitHealthMax(unit)
        local healthPrecentage = UnitHealthPercent(unit)

        UnitGetDetailedHealPrediction(unit, nil, self.hpValues)
        local allHeal = self.hpValues:GetIncomingHeals()
        local damageAbsorbAmount, damageAbsorbClamped = self.hpValues:GetDamageAbsorbs()
        local healAbsorbAmount = self.hpValues:GetHealAbsorbs()

        if self.healPrediction then
            self.healPrediction:SetMinMaxValues(0, healthMax)
            self.healPrediction:SetValue(allHeal, Enum.StatusBarInterpolation.ExponentialEaseOut)
        end

        self:UpdateHealthTextString(health, healthPrecentage, healthMax) -- HealthMax is used in the overriden PartyFrame UpdateHealthTextString function

        self.health:SetMinMaxValues(0, healthMax)
        self.health:SetValue(health, statusBarAnimation)

        if self.absorbbg then
            self.absorbbg:SetMinMaxValues(0, healthMax)
            self.absorbbg:SetValue(damageAbsorbAmount, statusBarAnimation)
        end
        if self.absorbOverlay then self.absorbOverlay:SetAlphaFromBoolean(damageAbsorbClamped, 1, 0) end
        if self.antiHeal then
            self.antiHeal:SetMinMaxValues(0, healthMax)
            self.antiHeal:SetValue(healAbsorbAmount, statusBarAnimation)
        end
    else
        local unit = self.unit
        local health = UnitHealth(unit)
        local healthMax = UnitHealthMax(unit)
        local absorb = (self.showAbsorbBar and UnitGetTotalAbsorbs and UnitGetTotalAbsorbs(unit)) or 0
        local prediction = UnitGetIncomingHeals(unit) or 0
        local healAbsorb = UnitGetTotalHealAbsorbs and UnitGetTotalHealAbsorbs(unit) or 0

        local healthPrecentage = (healthMax > 0) and (health / healthMax) or 0
        local absorbPrecentage = (absorb > 0 and healthMax > 0) and (absorb / healthMax) or 0
        local absorbAmount = absorb > 0 and (healthPrecentage + absorbPrecentage) or 0
        local absorbAmount2 = absorb > 0 and (absorbPrecentage - (1 - healthPrecentage)) or 0
        local predictionPrecentage = (prediction > 0 and healthMax > 0) and math.min(1, healthPrecentage + (prediction / healthMax)) or 0
        local healAbsorbPrecentage = (healAbsorb > 0 and healthMax > 0) and math.min(1, healAbsorb / healthMax) or 0

        if self.healPrediction then
            self.healPrediction:SetFillAmount(predictionPrecentage)
        end

        self.health.barOnUpdate = function()
            self:UpdateHealthTextString(health, self.health:GetFillAmount(), healthMax) -- HealthMax is used in the overriden PartyFrame UpdateHealthTextString function
        end

        if forceUpdate then
            self.health:ForceFillAmount(healthPrecentage)
            if self.absorbbg then self.absorbbg:ForceFillAmount(absorbAmount) end
            if self.absorbOverlay then self.absorbOverlay:ForceFillAmount(absorbAmount2) end
            if self.antiHeal then self.antiHeal:ForceFillAmount(healAbsorbPrecentage) end
        else
            self.health:SetFillAmount(healthPrecentage)
            if self.absorbbg then self.absorbbg:SetFillAmount(absorbAmount) end
            if self.absorbOverlay then self.absorbOverlay:SetFillAmount(absorbAmount2) end
            if self.antiHeal then self.antiHeal:SetFillAmount(healAbsorbPrecentage) end
        end
    end
end
