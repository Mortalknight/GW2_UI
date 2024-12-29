local _, GW = ...
local PowerBarColorCustom = GW.PowerBarColorCustom

local function UpdatePowerBar(self, forceUpdate)
    local powerType, powerToken, _ = UnitPowerType(self.unit)
    local power = UnitPower(self.unit, powerType)
    local powerMax = UnitPowerMax(self.unit, powerType)
    local powerPrecentage = 0

    if power > 0 and powerMax > 0 then
        powerPrecentage = power / powerMax
    end

    self.powerbar:Show()

    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.powerbar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end

    if forceUpdate then
      self.powerbar:ForceFillAmount(powerPrecentage)
    else
      self.powerbar:SetFillAmount(powerPrecentage)
    end
end
GW.UpdatePowerBar = UpdatePowerBar
