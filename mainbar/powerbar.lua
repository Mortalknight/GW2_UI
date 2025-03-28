local _, GW = ...
local PowerBarColorCustom = GW.PowerBarColorCustom

GwPlayerPowerBarMixin = {}

function GwPlayerPowerBarMixin:ResetPowerBarVisuals()
    self.animator:SetScript("OnUpdate", nil)
    self.bar:SetStatusBarColor(1, 1, 1, 1)
    self.bar.spark:SetAlpha(0)
    self.bar.spark:SetBlendMode("BLEND")
    self.bar.scrollTexture:SetAlpha(0)
    self.bar.scrollTexture2:SetAlpha(0)
    self.bar.scrollTexture:SetBlendMode("BLEND")
    self.bar.scrollTexture2:SetBlendMode("BLEND")
    self:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar")
    self.intensity:SetAlpha(0)
    self.intensity2:SetAlpha(0)
    self.runeoverlay:SetAlpha(0)
    self.onUpdateAnimation = nil
    self.intensity:ClearAllPoints()
    self.intensity:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
    self.intensity:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
    self.decay:ForceFillAmount(0)
    self.animationType = GW.BarAnimateTypes.All
end
function GwPlayerPowerBarMixin:ScrollTextureVerticalParalaxOnUpdate(delta)
    local speed = 0.5
    local speed2 = 0.3
    local speedMultiplier = self.scrollSpeedMultiplier or 1
    speed = speed * speedMultiplier
    speed2 = speed2 * speedMultiplier
    local offset = self.scrollTexture.yoffset or 1
    local offset2 = self.scrollTexture2.yoffset or 1
    local newPoint = offset + delta * speed
    local newPoint2 = offset2 + delta * speed2
    if newPoint > 1 then newPoint = newPoint - 1 end
    if newPoint2 > 1 then newPoint2 = newPoint2 - 1 end
    self.scrollTexture.yoffset = newPoint
    self.scrollTexture2.yoffset = newPoint2
    self.scrollTexture:SetTexCoord(0, 1, newPoint, newPoint + 1)
    self.scrollTexture2:SetTexCoord(0, 1, newPoint2, newPoint2 + 1)
end

function GwPlayerPowerBarMixin:ScrollTextureParalaxOnUpdate(delta)
    local speed = 0.025
    local speed2 = 0.015
    local speedMultiplier = self.scrollSpeedMultiplier or 1
    speed = speed * speedMultiplier
    speed2 = speed2 * speedMultiplier
    local offset = self.scrollTexture.xoffset or 1
    local offset2 = self.scrollTexture2.xoffset or 1
    local newPoint = offset - delta*speed
    local newPoint2 = offset2 - delta*speed2
    if newPoint < 0 then newPoint = newPoint + 1 end
    if newPoint2 < 0 then newPoint2 = newPoint2 + 1 end
    self.scrollTexture.xoffset = newPoint
    self.scrollTexture2.xoffset = newPoint2
    self.scrollTexture:SetTexCoord(newPoint, newPoint + 1, 0, 1)
    self.scrollTexture2:SetTexCoord(newPoint2, newPoint2 + 1, 0, 1)
end

function GwPlayerPowerBarMixin:ScrollTextureOnUpdate(delta)
    local speed = 0.025
    local speedMultiplier = self.scrollSpeedMultiplier or 1
    speed = speed * speedMultiplier
    local offset = self.scrollTexture.xoffset or 1
    local newPoint = offset - delta * speed
    if newPoint < 0 then newPoint = newPoint + 1 end
    self.scrollTexture.xoffset = newPoint
    self.scrollTexture:SetTexCoord(newPoint, newPoint + 1, 0, 1)
    self.runeoverlay:SetTexCoord(newPoint, newPoint + 1, 0, 1)
end

function GwPlayerPowerBarMixin:ScrollTextureVerticalOnUpdate(delta)
    local speed = 0.5
    local speedMultiplier = self.scrollSpeedMultiplier or 1
    speed = speed * speedMultiplier
    local offset = self.scrollTexture.yoffset or 1
    local newPoint = offset + delta * speed
    if newPoint > 1 then newPoint = newPoint - 1 end
    self.scrollTexture.yoffset = newPoint
    self.scrollTexture:SetTexCoord(0, 1, newPoint, newPoint + 1)
    self.runeoverlay:SetTexCoord(0, 1, newPoint, newPoint + 1)
end

function GwPlayerPowerBarMixin:AnimationFocus(animationProgress)
    local alphaStart = self.spark:GetAlpha()
    local newAlpha = 0
    if self.animatedStartValue < self.animatedValue then
        newAlpha = Lerp(alphaStart, 0.6, animationProgress)
    else
        newAlpha = Lerp(alphaStart, 0, animationProgress)
    end
    self.spark:SetAlpha(max(0, min(0.6, newAlpha)))
end

function GwPlayerPowerBarMixin:AnimationFury(animationProgress)
    local fill = self:GetFillAmount()
    local cap = min(0.4, fill)
    local cap2 = min(0.6, fill)
    self.scrollSpeedMultiplier = max(1, min(5, fill * 5))
    if self.animatedStartValue < self.animatedValue then
        self.scrollTexture:SetAlpha(max(cap, min(1, 1 - animationProgress)))
        self.scrollTexture2:SetAlpha(max(cap2, min(1, 1 - animationProgress)))
    else
        self.scrollTexture:SetAlpha(cap)
        self.scrollTexture2:SetAlpha(cap2)
    end
end
function GwPlayerPowerBarMixin:AnimationRunicPower(animationProgress)
    local fill = self:GetFillAmount()
    local cap = min(0.4, fill)
    if self.animatedStartValue < self.animatedValue then
        self.runeoverlay:SetAlpha(max(0, min(1, 1 - animationProgress)))
    else
        self.runeoverlay:SetAlpha(0)
    end
    self.scrollSpeedMultiplier = 1
    self.scrollTexture:SetAlpha(cap)
    self.spark:SetAlpha(cap)
end

function GwPlayerPowerBarMixin:AnimationLunarGlow(animationProgress)
    local fill = self:GetFillAmount()
    local cap = min(1, max(0, (fill - 0.5) * 2))
    if self.animatedStartValue < self.animatedValue then
        self.scrollSpeedMultiplier = max(1, 1 + (5 * (1 - animationProgress)))
        self.scrollTexture:SetAlpha(max(0.5, min(1, 1 - animationProgress)))
        self.spark:SetAlpha(max(0, min(1, 1 - animationProgress)))
    end
    self.scrollSpeedMultiplier = 1
    self.intensity:SetAlpha(cap)
end
function GwPlayerPowerBarMixin:AnimationIntensityGlow(animationProgress)
    local fill = self:GetFillAmount()
    local cap1 = min(1, max(0, fill * 2))
    local cap2 = min(1, max(0, (fill - 0.5) * 2))
    self.scrollSpeedMultiplier = max(1, 1 + (5 * fill))
    if self.animatedStartValue < self.animatedValue then
        self.spark:SetAlpha(max(0.75, min(1, 1 - animationProgress)))
    end
    self.scrollTexture:SetAlpha(1 - cap2)
    self.intensity:SetAlpha(cap1)
    self.intensity2:SetAlpha(cap2)
    self.spark:SetAlpha(0.75)
end
function GwPlayerPowerBarMixin:AnimationEnergy(animationProgress)
    local alphaStart = self.runeoverlay:GetAlpha()
    local newAlpha = 0
    if self.animatedStartValue < self.animatedValue then
        newAlpha = Lerp(alphaStart, 1, animationProgress)
        self.runeoverlay:SetAlpha(max(0, min(1, newAlpha)))
        self.spark:SetAlpha(max(0, min(0.3, 0.3 * newAlpha)))
    else
        newAlpha = Lerp(alphaStart, 0, animationProgress)
        self.runeoverlay:SetAlpha(max(0, min(1, newAlpha)))
        self.spark:SetAlpha(max(0, min(0.3, 0.3 * newAlpha)))
    end
    self.scrollSpeedMultiplier = 1
end

function GwPlayerPowerBarMixin:SetPowerTypeFocus()
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/ragespark")
    self.decay:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/focus-intensity")
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/focus")

    self.onUpdateAnimation = self.AnimationFocus
    self.animationType = GW.BarAnimateTypes.Regenerate
    self.onAnimationStart = function(self, value)
    if self.animatedStartValue > self.animatedValue then
        if self.decay:GetFillAmount() < self.animatedStartValue then
            self.decay:ForceFillAmount(self.animatedStartValue)
        end
            self.decay:SetFillAmount(value)
        end
    end
end

function GwPlayerPowerBarMixin:SetPowerTypeFury()
  self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/fury")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/fury-intensity","REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/fury-intensity2","REPEAT")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/furyspark")
    self.animator:SetScript("OnUpdate",function(_,delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(1)
    self.scrollTexture2:SetAlpha(1)
    self.spark:SetAlpha(0.5)
    self.onUpdateAnimation = self.AnimationFury
end

function GwPlayerPowerBarMixin:SetPowerTypeRunic()
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/runicpower")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/runicpower-intensity2","REPEAT")
    self.runeoverlay:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/runicpower-intensity","REPEAT")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/spark")
    self.spark:SetAlpha(1)
    self.onUpdateAnimation = self.AnimationRunicPower
    self.animator:SetScript("OnUpdate",function(_,delta) self:ScrollTextureOnUpdate(delta) end)
end

function GwPlayerPowerBarMixin:SetPowerTypeLunarPower()
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/lunar")
    self.intensity:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/lunar-intensity")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/spark")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/lunar-intensity2","REPEAT")
    self.scrollTexture:SetAlpha(0.5)
    self.onUpdateAnimation = self.AnimationLunarGlow
    self.animator:SetScript("OnUpdate",function(_,delta) self:ScrollTextureOnUpdate(delta) end)
end

function GwPlayerPowerBarMixin:SetPowerTypeRage()
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/ragespark")
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/rage")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll", "REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll2", "REPEAT")
    self.animator:SetScript("OnUpdate", function(_, delta) self:ScrollTextureParalaxOnUpdate(delta) end)

    self.onUpdateAnimation = function(self, animationProgress)
        local l = self:GetFillAmount()
        self.scrollTexture:SetAlpha(math.max(0.4,l))
        self.scrollTexture2:SetAlpha(math.max(0.4,l))
        self.scrollSpeedMultiplier = 5 * l
        if self.animatedStartValue < self.animatedValue then
            self.spark:SetAlpha(max(0, min(1, 1 - animationProgress)))
        else
            self.spark:SetAlpha(0)
        end
    end
end

function GwPlayerPowerBarMixin:SetPowerTypeEnergy()
    self.spark:SetAlpha(0)
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/spark")
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/energy")
    self.runeoverlay:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/energy-intensity","REPEAT")
    self.onUpdateAnimation = self.AnimationEnergy
end

function GwPlayerPowerBarMixin:SetPowerTypeMana()
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/mana")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/manaspark")
    self.spark:SetAlpha(1)

    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/mana-intensity","REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/mana-intensity2","REPEAT")
    self.animator:SetScript("OnUpdate",function(_,delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(1)
    self.scrollTexture2:SetAlpha(1)
end
function GwPlayerPowerBarMixin:SetPowerTypeInsanity()
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity-scroll","REPEAT")
    self.intensity:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity-intensity")
    self.intensity2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity-intensity2")
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanityspark")
    self.onUpdateAnimation = self.AnimationIntensityGlow
    self.animator:SetScript("OnUpdate",function(_,delta) self:ScrollTextureOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(1)
    self.spark:SetAlpha(0.75)
end

function GwPlayerPowerBarMixin:SetPowerBarVisuals(powerType, powerToken)
    if self.pType == powerType then
        return
    end
    self.pType = powerType
    self:ResetPowerBarVisuals()

    if powerType == Enum.PowerType.Insanity then
        self:SetPowerTypeInsanity()
        return
    elseif powerType == Enum.PowerType.Mana then
        self:SetPowerTypeMana()
        return
    elseif powerType == Enum.PowerType.Rage then
        self:SetPowerTypeRage()
        return
    elseif powerType == Enum.PowerType.Energy then
        self:SetPowerTypeEnergy()
        return
    elseif powerType == Enum.PowerType.LunarPower then
        self:SetPowerTypeLunarPower()
        return
    elseif powerType == Enum.PowerType.RunicPower then
        self:SetPowerTypeRunic()
        return
    elseif powerType == Enum.PowerType.Fury then
        self:SetPowerTypeFury()
        return
    elseif powerType == Enum.PowerType.Focus then
        self:SetPowerTypeFocus()
        return
    end

    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.bar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end
end

function GwPlayerPowerBarMixin:OnUpdate()
    if not self.lostKnownPower or not self.powerMax or not self.lastUpdate or self.animating then
        return
    end
    if self.lostKnownPower >= self.powerMax then
        return
    end

    self.textUpdate = self.textUpdate or 0
    local decayRate = 1
    local inactiveRegen, activeRegen = GetPowerRegen()
    local regen = InCombatLockdown() and activeRegen or inactiveRegen
    local addPower = regen * ((GetTime() - self.lastUpdate) / decayRate)
    local power = self.lostKnownPower + addPower
    local powerMax = self.powerMax
    local powerPrec = (power > 0 and powerMax > 0) and min(1, power / powerMax) or 0

    if powerPrec == 0 then
        self:Hide()
    else
        self:Show()
    end
    self:SetFillAmount(0)

    if self.textUpdate < GetTime() then
        self.powerBarString:SetText(GW.GetLocalizedNumber(powerMax * powerPrec))
        self.textUpdate = GetTime() + 0.2
    end
end

function GwPlayerPowerBarMixin:UpdatePowerData(forcePowerType, powerToken)
    if not forcePowerType then
        forcePowerType, powerToken = UnitPowerType("player")
    end

    self.animating = true
    local power = UnitPower("player", forcePowerType)
    local powerMax = UnitPowerMax("player", forcePowerType)
    local powerBarWidth = self:GetWidth()
    local powerPrec = (power >= 0 and powerMax > 0) and (power / powerMax) or 0
    self.powerType = forcePowerType
    self.lostKnownPower = power
    self.powerMax = powerMax
    self.lastUpdate = GetTime()
    self.powerBarWidth = powerBarWidth

    self:SetPowerBarVisuals(forcePowerType, powerToken)

    self:SetFillAmount(powerPrec)
    self.label:SetText(GW.GetLocalizedNumber(self.lostKnownPower))

    if self.lastPowerType ~= self.powerType and self == GwPlayerPowerBar then
        self.lastPowerType = self.powerType
        self.powerBarString = self.label
        self:ForceFillAmount(powerPrec)
        if (not self.powerType) or (self.powerType == 1 or self.powerType == 6 or self.powerType == 13 or self.powerType == 8) then
            self.barOnUpdate = nil
        else
            self.barOnUpdate = self.OnUpdate
        end
    end
end

local function OnEvent(self, event, unit)
    if (event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER") and unit == "player" then
        self:UpdatePowerData()
    elseif event == "UPDATE_SHAPESHIFT_FORM" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
        self.lastPowerType = nil
        self:UpdatePowerData()
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(0.5, function() self:UpdatePowerData() end)
        self:UnregisterEvent(event)
    end
end

function GwPlayerPowerBarMixin:ToggleBar()
    if GW.settings.POWERBAR_ENABLED and (GW.settings.PLAYER_AS_TARGET_FRAME and GW.settings.PLAYER_AS_TARGET_FRAME_SHOW_RESSOURCEBAR or not GW.settings.PLAYER_AS_TARGET_FRAME) then
        self:SetParent(UIParent)
        self.decay:SetParent(UIParent)
        self:SetScript("OnEvent", OnEvent)
        self:UpdatePowerData()
        GW.ToggleMover(self.gwMover, true)
    else
        self:SetParent(GW.HiddenFrame)
        self.decay:SetParent(GW.HiddenFrame)
        self:SetScript("OnEvent", nil)
        GW.ToggleMover(self.gwMover, false)
    end
end

local function LoadPowerBar()
    local playerPowerBar = GW.CreateAnimatedStatusBar("GwPlayerPowerBar", UIParent, "GwStatusPowerBar", true)
    playerPowerBar.customMaskSize = 64
    playerPowerBar.bar = playerPowerBar
    playerPowerBar:AddToBarMask(playerPowerBar.intensity)
    playerPowerBar:AddToBarMask(playerPowerBar.intensity2)
    playerPowerBar:AddToBarMask(playerPowerBar.scrollTexture)
    playerPowerBar:AddToBarMask(playerPowerBar.scrollTexture2)
    playerPowerBar:AddToBarMask(playerPowerBar.runeoverlay)
    playerPowerBar.runicmask:SetSize(playerPowerBar:GetSize())
    playerPowerBar.runeoverlay:AddMaskTexture(playerPowerBar.runicmask)

    playerPowerBar.decay = GW.CreateAnimatedStatusBar("GwPlayerPowerBarDecay",UIParent,nil,true)

    playerPowerBar.decay:SetFillAmount(0)
    playerPowerBar.decay:SetFrameLevel(playerPowerBar.decay:GetFrameLevel() - 1)
    playerPowerBar.decay:ClearAllPoints()
    playerPowerBar.decay:SetPoint("TOPLEFT", playerPowerBar, "TOPLEFT", 0, 0)
    playerPowerBar.decay:SetPoint("BOTTOMRIGHT", playerPowerBar, "BOTTOMRIGHT", 0, 0)

    GW.RegisterMovableFrame(playerPowerBar, DISPLAY_POWER_BARS, "PowerBar_pos", ALL .. ",Unitframe,Power", nil, {"default", "scaleable"}, true)

    playerPowerBar:ClearAllPoints()
    playerPowerBar:SetPoint("TOPLEFT", playerPowerBar.gwMover)

    -- position mover
    if (not GW.settings.XPBAR_ENABLED or GW.settings.PLAYER_AS_TARGET_FRAME) and not playerPowerBar.isMoved  then
        local framePoint = GW.settings.PowerBar_pos
        local yOff = not GW.settings.XPBAR_ENABLED and 14 or 0
        local xOff = GW.settings.PLAYER_AS_TARGET_FRAME and -52 or 0
        playerPowerBar.gwMover:ClearAllPoints()
        playerPowerBar.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs + xOff, framePoint.yOfs - yOff)
    end
    GW.MixinHideDuringPetAndOverride(playerPowerBar)

    playerPowerBar.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    playerPowerBar.label:SetShadowColor(0, 0, 0, 1)
    playerPowerBar.label:SetShadowOffset(1, -1)
    playerPowerBar:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    playerPowerBar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    playerPowerBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    playerPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    playerPowerBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

    playerPowerBar:ToggleBar()
end
GW.LoadPowerBar = LoadPowerBar
