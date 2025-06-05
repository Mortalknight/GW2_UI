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
    local healthPercentage = (health > 0 and maxHealth > 0) and (health / maxHealth) or 0

    self.health:SetMinMaxValues(0, maxHealth)
    self.health:SetValue(health)
    self.health.value:SetText(GW.RoundInt(healthPercentage * 100) .. "%")
end

function GwObjectivesUnitFrameMixin:UpdatePower()
    local powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
    local power = UnitPower(self.unit, powerType)
    local powerMax = UnitPowerMax(self.unit, powerType)
    local powerPercentage = (power > 0 and powerMax > 0) and (power / powerMax) or 0

    if GW.PowerBarColorCustom[powerToken] then
        local pwcolor = GW.PowerBarColorCustom[powerToken]
        self.power:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    else
        self.power:SetStatusBarColor(altR or 0, altG or 0, altB or 0)
    end

    self.power:SetMinMaxValues(0, powerMax)
    self.power:SetValue(power)
    self.power.value:SetText(GW.RoundInt(powerPercentage * 100) .. "%")
end

function GwObjectivesUnitFrameMixin:UpdateName()
    local name = UnitName(self.unit)
    self.name:SetText(name)
    self.guid = UnitGUID(self.unit)
    if self.guid == UnitGUID("target") then
        self.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    else
        self.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL)
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
