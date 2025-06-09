local _, GW = ...

GwUnitHealthbarMixin = {}

function GwUnitHealthbarMixin:UpdateHealthTextString(health, healthPrecentage, healthMax)
    local formatFunc = self.shortendHealthValues and GW.ShortValue or GW.GetLocalizedNumber
    local pctText = GW.GetLocalizedNumber(healthPrecentage * 100, 0) .. "%"

    local text
    if self.showHealthValue and self.showHealthPrecentage then
        text = self.frameInvert and (pctText .. " - " .. formatFunc(health)) or (formatFunc(health) .. " - " .. pctText)
    elseif self.showHealthValue then
        text = formatFunc(health)
    elseif self.showHealthPrecentage then
        text = pctText
    end

    self.healthString:SetText(text or "")
end

function GwUnitHealthbarMixin:UpdateHealthBar(forceUpdate)
    local unit = self.unit
    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)
    local absorb = UnitGetTotalAbsorbs and UnitGetTotalAbsorbs(unit) or 0
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
        self:UpdateHealthTextString(health, self.health:GetFillAmount(), healthMax)
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
