local _, GW = ...
local CommaValue = GW.CommaValue
local PowerBarColorCustom = GW.PowerBarColorCustom
local bloodSpark = GW.BLOOD_SPARK
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local GetSetting = GW.GetSetting

local function scrollTextureOnUpdate(self,delta)
  local barWidth = self:GetWidth()
  local speed = (0.025 * barWidth)/barWidth
  local speedMultiplier = self.scrollSpeedMultiplier or 1
  speed = speed * speedMultiplier
  local offset = self.scrollTexture.xoffset or 1
  local newPoint = offset - delta*speed
  if newPoint<0 then
    newPoint = newPoint + 1
  end
  self.scrollTexture.xoffset = newPoint
  self.scrollTexture:SetTexCoord(newPoint,newPoint+1,0,1)
end
local function AnimationLunarGlow(self,animationProgress,delta)
    local fill = self:GetFillAmount()
    local cap = min(1,max(0,(fill-0.5)*2))

  if self.animatedStartValue<self.animatedValue then
    self.scrollSpeedMultiplier = max(1,1 + (5 * (1 - animationProgress)))
    self.scrollTexture:SetAlpha(max(0.5,min(1,1 - animationProgress)))
    self.spark:SetAlpha(max(0,min(1,1 - animationProgress)))
  end
  self.scrollSpeedMultiplier = 1
  self.intensity:SetAlpha(cap)

end
local function AnimationIntensityGlow(self,animationProgress)
    local fill = self:GetFillAmount()
    local cap1 = min(1,max(0,fill*2))
    local cap2 = min(1,max(0,(fill-0.5)*2))
    self.scrollSpeedMultiplier = max(1,1 + (5 * fill))
  if self.animatedStartValue<self.animatedValue then
    local prog = 1 - animationProgress
    prog = max(0,min(1,prog))
    local alpha2 = fill>0.5 and 1 or 0

    self.spark:SetAlpha(max(0.75,min(1,1 - animationProgress)))
  end
  self.scrollTexture:SetAlpha(1-cap2)
  self.intensity:SetAlpha(cap1)
  self.intensity2:SetAlpha(cap2)
  self.spark:SetAlpha(0.75)
end





local function setPowerTypeLunarPower(self)
  self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/lunar")
  self.intensity:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/lunar-intensity")
  self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/spark")
  self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/lunar-intensity2","REPEAT")
  self.scrollTexture:SetAlpha(0.5)
  self.onUpdateAnimation =AnimationLunarGlow
  self.animator:SetScript("OnUpdate",function(_,delta) scrollTextureOnUpdate(self,delta) end)
end
local function setPowerTypeRage(self)
  self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/ragespark")
  self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/rage")
  self.onUpdateAnimation = function(self,animationProgress)
    if self.animatedStartValue<self.animatedValue then
      self.spark:SetAlpha(max(0,min(1,1 - animationProgress)))
    else
      self.spark:SetAlpha(0)
    end
  end
end
local function setPowerTypeEnergy(self)
  self.spark:SetAlpha(1)
  self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/ragespark")
  self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/energy")
end
local function setPowerTypeMana(self)
  self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/mana")
end
local function setPowerTypeInsanity(self)
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity-scroll","REPEAT")
    self.intensity:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity-intensity")
    self.intensity2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity-intensity2")
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanityspark")
    self.onUpdateAnimation =AnimationIntensityGlow
    self.animator:SetScript("OnUpdate",function(_,delta) scrollTextureOnUpdate(self,delta) end)
    self.scrollTexture:SetAlpha(1)
      self.spark:SetAlpha(0.75)
end

local function setPowerBarVisuals(self,powerType,powerToken)

  if self.pType==powerType then
    return
  end
  self.pType = powerToken
  --reset to default
  self.animator:SetScript("OnUpdate",nil)
  self.bar:SetStatusBarColor(1,1,1,1)
  self.bar.spark:SetAlpha(0)
  self.bar.scrollTexture:SetAlpha(0)
  self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/statusbar")
  self.intensity:SetAlpha(0)
  self.intensity2:SetAlpha(0)
  self.spark:SetAlpha(0)
  self.onUpdateAnimation = nil

  if powerType == Enum.PowerType.Insanity then
    setPowerTypeInsanity(self)
    return
  elseif powerType == Enum.PowerType.Mana then
    setPowerTypeMana(self)
    return
  elseif powerType == Enum.PowerType.Rage then
    setPowerTypeRage(self)
    return
  elseif powerType == Enum.PowerType.Energy then
    setPowerTypeEnergy(self)
    return
  elseif powerType == Enum.PowerType.LunarPower then
    setPowerTypeLunarPower(self)
    return
  end

  if PowerBarColorCustom[powerToken] then
      local pwcolor = PowerBarColorCustom[powerToken]
      self.bar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
  end
end


local function powerBar_OnUpdate(self)
    if self.lostKnownPower == nil or self.powerMax == nil or self.lastUpdate == nil or self.animating == true then
        return
    end
    if self.lostKnownPower >= self.powerMax then
        return
    end
    if self.textUpdate == nil then
        self.textUpdate = 0
    end

    local decayRate = 1
    local inactiveRegen, activeRegen = GetPowerRegen()

    local regen = inactiveRegen

    if InCombatLockdown() then
        regen = activeRegen
    end

    local addPower = regen * ((GetTime() - self.lastUpdate) / decayRate)

    local power = self.lostKnownPower + addPower
    local powerMax = self.powerMax
    local powerPrec = 0
    local powerBarWidth = self.powerBarWidth

    if power > 0 and powerMax > 0 then
        powerPrec = math.min(1, power / powerMax)
    end



    if powerPrec == 0 then
        self:Hide()
    else
        self:Show()
    end
    self:SetFillAmount(0)
--    self.powerCandy:SetValue(0)

    if self.textUpdate < GetTime() then
        self.powerBarString:SetText(CommaValue(powerMax * powerPrec))
        self.textUpdate = GetTime() + 0.2
    end

  --  self.animationCurrent = powerPrec
end
GW.AddForProfiling("playerhud", "powerBar_OnUpdate", powerBar_OnUpdate)

local function UpdatePowerData(self, forcePowerType, powerToken)
    if forcePowerType == nil then
        forcePowerType, powerToken = UnitPowerType("player")
    end

    self.animating = true

    local power = UnitPower("player", forcePowerType)
    local powerMax = UnitPowerMax("player", forcePowerType)
    local powerPrec
    local powerBarWidth = self:GetWidth()

    self.powerType = forcePowerType
    self.lostKnownPower = power
    self.powerMax = powerMax
    self.lastUpdate = GetTime()
    self.powerBarWidth = powerBarWidth

    if power >= 0 and powerMax > 0 then
        powerPrec = power / powerMax
    else
        powerPrec = 0
    end

    setPowerBarVisuals(self,forcePowerType,powerToken)

    self:SetFillAmount(powerPrec)
    self.label:SetText(CommaValue(self.lostKnownPower))

    if self.lastPowerType ~= self.powerType and self == GwPlayerPowerBar then
        self.lastPowerType = self.powerType
        self.powerBarString = self.label
        self:ForceFIllAmount(powerPrec)
    if self.powerType == nil or self.powerType == 1 or self.powerType == 6 or self.powerType == 13 or self.powerType == 8 then
        self.barOnUpdate = nil
    else
        self.barOnUpdate = powerBar_OnUpdate
    end
  end

end
GW.UpdatePowerData = UpdatePowerData

local function LoadPowerBar()
    local playerPowerBar = GW.createNewStatusbar("GwPlayerPowerBar",UIParent,"GwStatusPowerBar",true)
    playerPowerBar.customMaskSize = 64
    playerPowerBar.bar = playerPowerBar
    playerPowerBar:addToBarMask(playerPowerBar.intensity)
    playerPowerBar:addToBarMask(playerPowerBar.intensity2)
    playerPowerBar:addToBarMask(playerPowerBar.scrollTexture)
    --CreateFrame("Frame", "GwPlayerPowerBar", UIParent, "GwPlayerPowerBar")

    GW.RegisterMovableFrame(playerPowerBar, DISPLAY_POWER_BARS, "PowerBar_pos", ALL .. ",Unitframe,Power", nil, {"default", "scaleable"}, true)

    playerPowerBar:ClearAllPoints()
    playerPowerBar:SetPoint("TOPLEFT", playerPowerBar.gwMover)

    -- position mover
    if (not GetSetting("XPBAR_ENABLED") or GetSetting("PLAYER_AS_TARGET_FRAME")) and not playerPowerBar.isMoved  then
        local framePoint = GetSetting("PowerBar_pos")
        local yOff = not GetSetting("XPBAR_ENABLED") and 14 or 0
        local xOff = GetSetting("PLAYER_AS_TARGET_FRAME") and -52 or 0
        playerPowerBar.gwMover:ClearAllPoints()
        playerPowerBar.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs + xOff, framePoint.yOfs - yOff)
    end
    GW.MixinHideDuringPetAndOverride(playerPowerBar)



    playerPowerBar:SetScript(
        "OnEvent",
        function(self, event, unit)
            if (event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER") and unit == "player" then
                UpdatePowerData(playerPowerBar)
            elseif event == "UPDATE_SHAPESHIFT_FORM" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
                playerPowerBar.lastPowerType = nil
                UpdatePowerData(playerPowerBar)
            elseif event == "PLAYER_ENTERING_WORLD" then
                C_Timer.After(0.5, function() UpdatePowerData(playerPowerBar) end)
                self:UnregisterEvent(event)
            end
        end
    )

    playerPowerBar.label:SetFont(DAMAGE_TEXT_FONT, 12)

    playerPowerBar:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    playerPowerBar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    playerPowerBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    playerPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    playerPowerBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

    UpdatePowerData(playerPowerBar)
end
GW.LoadPowerBar = LoadPowerBar
