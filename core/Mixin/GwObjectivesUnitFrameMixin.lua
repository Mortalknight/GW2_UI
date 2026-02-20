local _, GW = ...

GwObjectivesUnitFrameMixin = {}

function GwObjectivesUnitFrameMixin:OnHide()
    -- override per module
end

function GwObjectivesUnitFrameMixin:OnShow()
    -- override per module
end


function GwObjectivesUnitFrameMixin:UpdateHealth()
    local health = UnitHealth(self.unit)
    local maxHealth = UnitHealthMax(self.unit)
    self.health:SetMinMaxValues(0, maxHealth)

    if GW.Retail then
        self.health:SetValue(health, Enum.StatusBarInterpolation.ExponentialEaseOut)
        self.health.value:SetText(string.format("%.0f%%", UnitHealthPercent(self.unit, true, CurveConstants.ScaleTo100)))
    else
        local healthPercentage = (health > 0 and maxHealth > 0) and (health / maxHealth) or 0
        self.health:SetValue(health)
        self.health.value:SetText(GW.RoundInt(healthPercentage * 100) .. "%")
    end
end

function GwObjectivesUnitFrameMixin:UpdatePower()
    local powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
    local power = UnitPower(self.unit, powerType)
    local powerMax = UnitPowerMax(self.unit, powerType)

    self.power:SetMinMaxValues(0, powerMax)

     if GW.Colors.PowerBarCustomColors[powerToken] then
        local pwcolor = GW.Colors.PowerBarCustomColors[powerToken]
        self.power:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    else
        self.power:SetStatusBarColor(altR or 0, altG or 0, altB or 0)
    end

    if GW.Retail then
        self.power:SetValue(power, Enum.StatusBarInterpolation.ExponentialEaseOut)
        self.power.value:SetText(string.format("%.0f%%", UnitPowerPercent(self.unit, powerType, CurveConstants.ScaleTo100)))
    else
        local powerPercentage = (power > 0 and powerMax > 0) and (power / powerMax) or 0
        self.power:SetValue(power)
        self.power.value:SetText(GW.RoundInt(powerPercentage * 100) .. "%")
    end
end

function GwObjectivesUnitFrameMixin:UpdateName()
    local name = UnitName(self.unit)
    self.name:SetText(name)

    if GW.Retail then return end -- guid is secret
    self.guid = UnitGUID(self.unit)
    if self.guid == UnitGUID("target") then
        self.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    else
        self.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small)
    end
end

function GwObjectivesUnitFrameMixin:OnEnter()
    if self.unit then
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(self.unit)
        GameTooltip:Show()
    end
end

function GwObjectivesUnitFrameMixin:OnLeave()
    GameTooltip_Hide()
end
