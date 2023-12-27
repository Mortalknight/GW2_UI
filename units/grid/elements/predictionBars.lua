local _, GW = ...

local function UpdatePredictionBarsOverride(self, event, unit)
    if(self.unit ~= unit) then return end

	local element = self.HealthPrediction

    if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)
    local healthPrecentage = 0

    local absorb = UnitGetTotalAbsorbs(unit)
    local absorbPrecentage = 0
    local absorbAmount = 0
    local absorbAmount2 = 0

    local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
    local allIncomingHealPrecentage = 0

    local healAbsorb =  UnitGetTotalHealAbsorbs(unit)
    local healAbsorbPrecentage = 0

    if healthMax > 0 then
        healthPrecentage = health / healthMax
    end

    if absorb > 0 and healthMax > 0 then
        absorbPrecentage = absorb / healthMax
        absorbAmount = healthPrecentage + absorbPrecentage
        absorbAmount2 = absorbPrecentage - (1 - healthPrecentage)
    end
    if allIncomingHeal > 0 and healthMax > 0 then
        allIncomingHealPrecentage = math.min((healthPrecentage) + (allIncomingHeal / healthMax), 1)
    end

    if healAbsorb > 0 and healthMax > 0 then
        healAbsorbPrecentage = min(healthMax, healAbsorb / healthMax)
    end

    if not self.Forced then
        element.healthPredictionbar:SetFillAmount(allIncomingHealPrecentage)
        element.absorbBar:SetFillAmount(absorbAmount)
        element.overAbsorb:SetFillAmount(absorbAmount2)
        element.healAbsorbBar:SetFillAmount(healAbsorbPrecentage)
    else
        element.healthPredictionbar:ForceFillAmount(allIncomingHealPrecentage)
        element.absorbBar:ForceFillAmount(absorbAmount)
        element.overAbsorb:ForceFillAmount(absorbAmount2)
        element.healAbsorbBar:ForceFillAmount(healAbsorbPrecentage)
    end

    if(element.PostUpdate) then
		--return element:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb)
	end
end

local function Construct_PredictionBar(frame)
    frame.HealthPrediction.Override  = UpdatePredictionBarsOverride
end
GW.Construct_PredictionBar = Construct_PredictionBar

local function Update_PredictionBars(frame)
    --nothing atm
end
GW.Update_PredictionBars = Update_PredictionBars