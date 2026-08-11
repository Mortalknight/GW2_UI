---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- MONK (brewmaster stagger, windwalker chi)
if GW.myClassID ~= GW.Enum.ClassIndex.Monk or not (GW.Retail or GW.Mists) then return end

local RoundInt = GW.RoundInt
local staggerTextColors = {
    {r = 0.4, g = 0.9, b = 0.4},
    {r = 0.95, g = 0.85, b = 0.3},
    {r = 0.9, g = 0.4, b = 0.4}
}

local function powerChi(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "CHI" and pType ~= "DARK_FORCE" then
        return
    end

    local old_power = self.gwPower
    old_power = old_power or -1

    local pwrMax = UnitPowerMax("player", Enum.PowerType.Chi)
    local pwr = UnitPower("player", Enum.PowerType.Chi)
    local p = pwr - 1

    self.gwPower = pwr

    self.background:SetTexCoord(0, 1, 0.111 * (pwrMax + 2), 0.111 * (pwrMax + 3))
    self.fill:SetTexCoord(0, 1, 0.111 * p, 0.111 * (p + 1))

    if old_power < pwr and event ~= "CLASS_POWER_INIT" then
        CP.animFlare(self)
    end
end


local function ironSkin_OnUpdate(self)
    local precentage = math.min(1, math.max(0, (self.expires - GetTime()) / 23))
    self.ironartwork:SetAlpha(precentage)
    self.fill:SetTexCoord(0, precentage, 0, 1)
    self.fill:SetWidth(precentage * 256)

    self.indicator:SetPoint("LEFT", math.min(252, (precentage * 256)) - 13, 19)
    self.indicatorText:SetText(RoundInt(self.expires - GetTime()) .. "s")
end


local function setStaggerBar()
    local fb = CP.frame.brewmaster

    if not GW.Retail then
        local auraData = CP.GetAuraData("player", nil, "HELPFUL", GW.Mists and 115307 or 215479)

        if auraData and auraData.expirationTime then
            fb.ironskin.expires = auraData.expirationTime
            if fb.ironskin.ticker then
                fb.ironskin.ticker:Cancel()
            end
            fb.ironskin.ticker = C_Timer.NewTicker(0.05, function() ironSkin_OnUpdate(fb.ironskin) end)
            fb.ironskin:Show()
            fb.ironskin.ironartwork:Show()
        else
            if fb.ironskin.ticker then
                fb.ironskin.ticker:Cancel()
            end
            fb.ironskin:Hide()
            fb.ironskin.ironartwork:Hide()
            fb.ironskin.expires = nil
        end
    end


    local bar = CP.frame.defaultResourceBar
    local pwrMax = UnitHealthMax("player")
    local stagger = UnitStagger("player") or 0

    bar:SetMinMaxValues(0, pwrMax)
    bar:SetValue(stagger, Enum.StatusBarInterpolation.ExponentialEaseOut)

    local staggerPrec = math.max(0, math.min(stagger / pwrMax, 1))
    local colorToUse = staggerTextColors[1]
    if staggerPrec >= 0.75 then
        colorToUse = staggerTextColors[3]
    elseif staggerPrec >= 0.5 then
        colorToUse = staggerTextColors[2]
    end

    local staggerText = GW.GetLocalizedNumber(format("%.2f%%", staggerPrec * 100))
    if bar.label._lastText ~= staggerText then
        bar.label:SetText(staggerText)
        if GW.settings.CLASSPOWER_SHOW_VALUE then
            bar.label:SetText(staggerText)
        else
            bar.label:SetText("")
        end
        bar.label._lastText = staggerText
    end
    if not (bar.label._lastR == colorToUse.r and bar.label._lastG == colorToUse.g and bar.label._lastB == colorToUse.b) then
        bar.label:SetTextColor(colorToUse.r, colorToUse.g, colorToUse.b)
        bar.label._lastR, bar.label._lastG, bar.label._lastB = colorToUse.r, colorToUse.g, colorToUse.b
    end
end

local function powerStagger(self, event, ...)
    local unit = select(1, ...)
    local fb = self.brewmaster
    if event == nil then
        fb.ironskin:Hide()
        fb.ironskin.ironartwork:Hide()
        if fb.ironskin.ticker then
            fb.ironskin.ticker:Cancel()
        end
    end

    if unit == "player" and event == "UNIT_AURA" then
        setStaggerBar()
    end
end

local function setMonk(f)
    if GW.Retail then
        if GW.myspec == 1 then -- brewmaster
            CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT")
            f.background:SetTexture(nil)
            f.fill:SetTexture(nil)
            CP.setPowerTypeStagger(f.defaultResourceBar)
            f.brewmaster:Show()
            f.defaultResourceBar:Show()
            f.defaultResourceBar:SetWidth(312)
            f:SetWidth(f.defaultResourceBar:GetWidth())
            f.defaultResourceBar:ClearAllPoints()
            f.defaultResourceBar:SetPoint("LEFT", f, "LEFT", 0, CP.GetAnchorMode() == "DEFAULT" and -5 or 0)

            f:SetScript("OnEvent", powerStagger)
            powerStagger(f, "CLASS_POWER_INIT")

            f:RegisterUnitEvent("UNIT_AURA", "player")
            f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
            f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

            return true
        elseif GW.myspec == 3 then -- ww
            CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT")
            f:SetHeight(32)
            f:SetWidth(256)
            f.background:SetHeight(32)
            f.background:SetWidth(320)
            f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi.png")
            f.background:SetTexCoord(0, 1, 0.5, 1)
            f.flare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi-flare.png")
            f.fill:SetHeight(32)
            f.fill:SetWidth(256)
            f.fill:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi.png")

            f:SetScript("OnEvent", powerChi)
            powerChi(f, "CLASS_POWER_INIT")
            f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
            f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

            return true
        end
    elseif GW.Mists then
        CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT")
        f:SetHeight(32)
        f:SetWidth(256)
        f.background:SetHeight(32)
        f.background:SetWidth(320)
        f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi.png")
        f.background:SetTexCoord(0, 1, 0.5, 1)
        f.flare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi-flare.png")
        f.fill:SetHeight(32)
        f.fill:SetWidth(256)
        f.fill:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi.png")

        f:SetScript("OnEvent", powerChi)
        powerChi(f, "CLASS_POWER_INIT")
        f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
        f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

        return true
    end

    return false
end

CP.setups[GW.Enum.ClassIndex.Monk] = setMonk
