local _, GW = ...
local PowerBarColorCustom = GW.PowerBarColorCustom

GwUnitPowerbarMixin = {}

function GwUnitPowerbarMixin:UpdatePowerBar(forceUpdate)
    if GW.Retail then
        local statusBarAnimation = forceUpdate and Enum.StatusBarInterpolation.Immediate or Enum.StatusBarInterpolation.ExponentialEaseOut
        local powerType, powerToken = UnitPowerType(self.unit)
        local power = UnitPower(self.unit, powerType)
        local powerMax = UnitPowerMax(self.unit, powerType)

        self.powerbar:Show()
        self.powerbar:SetMinMaxValues(0, powerMax)
        self.powerbar:SetValue(power, statusBarAnimation)

        if PowerBarColorCustom[powerToken] then
            local color = PowerBarColorCustom[powerToken]
            self.powerbar:SetStatusBarColor(color.r, color.g, color.b)
        end
    else
        local powerType, powerToken = UnitPowerType(self.unit)
        local power = UnitPower(self.unit, powerType)
        local powerMax = UnitPowerMax(self.unit, powerType)
        local pct = (powerMax > 0) and (power / powerMax) or 0

        self.powerbar:Show()

        if PowerBarColorCustom[powerToken] then
            local color = PowerBarColorCustom[powerToken]
            self.powerbar:SetStatusBarColor(color.r, color.g, color.b)
        end

        if forceUpdate then
            self.powerbar:ForceFillAmount(pct)
        else
            self.powerbar:SetFillAmount(pct)
        end
    end
end
