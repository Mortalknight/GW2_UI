local _, GW = ...

local function updateHealthTextString(self, health, healthPrecentage)
    local healthString = ""
    local formatFunction

    if self.shortendHealthValues then
        formatFunction = GW.ShortValue
    else
        formatFunction = GW.GetLocalizedNumber
    end

    if self.showHealthValue and self.showHealthPrecentage then
        if not self.frameInvert then
            healthString = formatFunction(health) .. " - " .. GW.GetLocalizedNumber(healthPrecentage * 100, 0) .. "%"
        else
            healthString = GW.GetLocalizedNumber(healthPrecentage * 100, 0) .. "% - " .. formatFunction(health)
        end
    elseif self.showHealthValue and not self.showHealthPrecentage then
        healthString = formatFunction(health)
    elseif not self.showHealthValue and self.showHealthPrecentage then
        healthString = GW.GetLocalizedNumber(healthPrecentage * 100, 0) .. "%"
    end

    self.healthString:SetText(healthString)
end
GW.AddForProfiling("unitframes", "updateHealthTextString", updateHealthTextString)

local function UpdateHealthBar(self, forceUpdate)
    local health = UnitHealth(self.unit)
    local healthMax = UnitHealthMax(self.unit)
    local absorb = UnitGetTotalAbsorbs(self.unit)
    local prediction = UnitGetIncomingHeals(self.unit) or 0
    local healAbsorb =  UnitGetTotalHealAbsorbs(self.unit)
    local absorbPrecentage = 0
    local absorbAmount = 0
    local absorbAmount2 = 0
    local predictionPrecentage = 0
    local healAbsorbPrecentage = 0
    local healthPrecentage = 0

    if health > 0 and healthMax > 0 then
        healthPrecentage = health / healthMax
    end

    if absorb > 0 and healthMax > 0 then
        absorbPrecentage = absorb / healthMax
        absorbAmount = healthPrecentage + absorbPrecentage
        absorbAmount2 = absorbPrecentage - (1 - healthPrecentage)
    end

    if prediction > 0 and healthMax > 0 then
        predictionPrecentage = (prediction / healthMax) + healthPrecentage
    end
    if healAbsorb > 0 and healthMax > 0 then
        healAbsorbPrecentage = min(healthMax,healAbsorb / healthMax)
    end
    if self.healPrediction then self.healPrediction:SetFillAmount(predictionPrecentage) end

    self.health.barOnUpdate = function()
        (self.updateHealthTextString or updateHealthTextString)(self, health, self.health:GetFillAmount())
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
GW.UpdateHealthBar = UpdateHealthBar
