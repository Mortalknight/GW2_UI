---@class GW2
local GW = select(2, ...)

GwUnitPowerbarMixin = {}

function GwUnitPowerbarMixin:UpdatePowerBar(forceUpdate)
    if GW.isModern then
        local statusBarAnimation = forceUpdate and Enum.StatusBarInterpolation.Immediate or Enum.StatusBarInterpolation.ExponentialEaseOut
        local powerType, powerToken = UnitPowerType(self.gwUnit)
        local powerMax = UnitPowerMax(self.gwUnit, powerType)
        local power = powerMax
        if UnitIsConnected(self.gwUnit) then
            power = UnitPower(self.gwUnit, powerType)
        end

        self.powerbar:Show()
        self.powerbar:SetMinMaxValues(0, powerMax)
        self.powerbar:SetValue(power, statusBarAnimation)

        if GW.Colors.PowerBarCustomColors[powerToken] then
            local color = GW.Colors.PowerBarCustomColors[powerToken]
            self.powerbar:SetStatusBarColor(color.r, color.g, color.b)
        end
    else
        local powerType, powerToken = UnitPowerType(self.gwUnit)
        local powerMax = UnitPowerMax(self.gwUnit, powerType)
        local power = UnitIsConnected(self.gwUnit) and UnitPower(self.gwUnit, powerType) or powerMax
        local pct = (powerMax > 0) and (power / powerMax) or 0

        self.powerbar:Show()

        if GW.Colors.PowerBarCustomColors[powerToken] then
            local color = GW.Colors.PowerBarCustomColors[powerToken]
            self.powerbar:SetStatusBarColor(color.r, color.g, color.b)
        end

        if forceUpdate then
            self.powerbar:ForceFillAmount(pct)
        else
            self.powerbar:SetFillAmount(pct)
        end
    end
end
