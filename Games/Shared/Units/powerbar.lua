---@class GW2
local GW = select(2, ...)

GwPlayerPowerBarMixin = {}

function GwPlayerPowerBarMixin:ResetPowerBarVisuals()
    self:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
    self.bar:SetStatusBarColor(1, 1, 1, 1)
    self.bar.spark:SetAlpha(0)
    self.bar.spark:SetBlendMode("BLEND")

    if GW.isModern then return end
    self.animator:SetScript("OnUpdate", nil)
    self.bar.scrollTexture:SetAlpha(0)
    self.bar.scrollTexture2:SetAlpha(0)
    self.bar.scrollTexture:SetBlendMode("BLEND")
    self.bar.scrollTexture2:SetBlendMode("BLEND")
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
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/ragespark.png")
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/focus.png")

    if GW.isModern then return end
    self.decay:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/focus-intensity.png")
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
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/fury.png")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/furyspark.png")
    self.spark:SetAlpha(0.5)

    if GW.isModern then return end
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/fury-intensity.png","REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/fury-intensity2.png","REPEAT")
    self.animator:SetScript("OnUpdate",function(_,delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(1)
    self.scrollTexture2:SetAlpha(1)
    self.onUpdateAnimation = self.AnimationFury
end

function GwPlayerPowerBarMixin:SetPowerTypeRunic()
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/runicpower.png")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/spark.png")
    self.spark:SetAlpha(1)

    if GW.isModern then return end
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/runicpower-intensity2.png","REPEAT")
    self.runeoverlay:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/runicpower-intensity.png","REPEAT")
    self.onUpdateAnimation = self.AnimationRunicPower
    self.animator:SetScript("OnUpdate",function(_,delta) self:ScrollTextureOnUpdate(delta) end)
end

function GwPlayerPowerBarMixin:SetPowerTypeLunarPower()
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/lunar.png")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/spark.png")

    if GW.isModern then return end
    self.intensity:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/lunar-intensity.png")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/lunar-intensity2.png","REPEAT")
    self.scrollTexture:SetAlpha(0.5)
    self.onUpdateAnimation = self.AnimationLunarGlow
    self.animator:SetScript("OnUpdate",function(_,delta) self:ScrollTextureOnUpdate(delta) end)
end

function GwPlayerPowerBarMixin:SetPowerTypeRage()
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/rage.png")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/ragespark.png")

    if GW.isModern then return end
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll.png", "REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll2.png", "REPEAT")
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
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/energy.png")
    self.spark:SetAlpha(0)
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/spark.png")

    if GW.isModern then return end
    self.runeoverlay:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/energy-intensity.png","REPEAT")
    self.onUpdateAnimation = self.AnimationEnergy
end

function GwPlayerPowerBarMixin:SetPowerTypeMana()
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/mana.png")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/manaspark.png")
    self.spark:SetAlpha(1)

    if GW.isModern then return end
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/mana-intensity.png","REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/mana-intensity2.png","REPEAT")
    self.animator:SetScript("OnUpdate",function(_,delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(1)
    self.scrollTexture2:SetAlpha(1)
end

function GwPlayerPowerBarMixin:SetPowerTypeInsanity()
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity.png")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanityspark.png")

    if GW.isModern then return end
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity-scroll.png","REPEAT")
    self.intensity:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity-intensity.png")
    self.intensity2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/insanity-intensity2.png")
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

    if GW.Colors.PowerBarCustomColors[powerToken] then
        local pwcolor = GW.Colors.PowerBarCustomColors[powerToken]
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

    local decayRate = 1
    local inactiveRegen, activeRegen = GetPowerRegen()
    local regen = InCombatLockdown() and activeRegen or inactiveRegen
    local addPower = regen * ((GetTime() - self.lastUpdate) / decayRate)
    local power = self.lostKnownPower + addPower
    local powerMax = self.powerMax
    local powerPrec

    if GW.isModern then
        self:SetValue(0, Enum.StatusBarInterpolation.ExponentialEaseOut)
        self:Show()
    else
        powerPrec = (power >= 0 and powerMax > 0) and min(1, power / powerMax) or 0
        self:SetFillAmount(0)
        if powerPrec == 0 then
            self:Hide()
        else
            self:Show()
        end
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
    local powerPrec

    if GW.isModern then
        powerPrec = UnitPowerPercent("player", forcePowerType)
    else
        powerPrec = (power >= 0 and powerMax > 0) and (power / powerMax) or 0
    end

    self.powerType = forcePowerType
    self.lostKnownPower = power
    self.powerMax = powerMax
    self.lastUpdate = GetTime()
    self.powerBarWidth = powerBarWidth

    self:SetPowerBarVisuals(forcePowerType, powerToken)

    if GW.isModern then
        self:SetValue(powerPrec, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
        self:SetFillAmount(powerPrec)
    end

    if self.lastPowerType ~= self.powerType and self == GwPlayerPowerBar then
        self.lastPowerType = self.powerType

        if GW.isModern then
            self:SetValue(powerPrec, Enum.StatusBarInterpolation.ExponentialEaseOut)
        else
            self:SetFillAmount(powerPrec)
        end
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
    if GW.settings.powerBar.enabled and ((GW.settings.unitframes.player.enabled and GW.settings.unitframes.player.showResourceBar) or not GW.settings.unitframes.player.enabled) then
        self:SetParent(UIParent)
        if self.decay then
            self.decay:SetParent(UIParent)
        end
        self:SetScript("OnEvent", OnEvent)
        self:UpdatePowerData()
        GW.ToggleMover(self.gwMover, true)
        self.shouldShow = true
    else
        self:SetParent(GW.HiddenFrame)
        if self.decay then
            self.decay:SetParent(GW.HiddenFrame)
        end
        self:SetScript("OnEvent", nil)
        GW.ToggleMover(self.gwMover, false)
        self.shouldShow = false
    end
end

-- the text of the bar comes from the text designer, the bar showed its power value
local function GetPowerTextBlocks()
    return GW.settings.powerBar.powerText or {{k = "power", mode = "CUR"}}
end

local function AnchorLabel(bar)
    local offset = GW.settings.powerBar.textOffset
    bar.label:ClearAllPoints()
    bar.label:SetPoint("CENTER", bar, "CENTER", offset.x, offset.y)
end

function GwPlayerPowerBarMixin:ApplyTextTags()
    self.gwUnit = "player"
    AnchorLabel(self)
    GW.SetFontStringTag(self, self.label, GW.BuildTagString(GetPowerTextBlocks()))
    self.label:UpdateTag()
end

function GwPlayerPowerBarMixin:ToggleSettings()
    self:ApplyTextTags()
    self:ClearAllPoints()
    local point = GW.ClassPowers and GW.ClassPowers.GetAnchorPoint("TOPLEFT") or "TOPLEFT"
    self:SetPoint(point, self.gwMover, point)
    self:UpdatePowerData()
end

-- the look of the bar, shared by the bar and its text preview
local function CreatePowerBar(name)
    local playerPowerBar

    if GW.isModern then
        playerPowerBar = CreateFrame("StatusBar", name, UIParent, "GwStatusPowerBarModernTemplate")
        playerPowerBar.spark:ClearAllPoints()
        playerPowerBar.spark:SetPoint("RIGHT", playerPowerBar:GetStatusBarTexture(), "RIGHT", 0, 0)
    else
        playerPowerBar = GW.CreateAnimatedStatusBar(name, UIParent, "GwStatusPowerBar", true)
        playerPowerBar.customMaskSize = 64
        playerPowerBar:AddToBarMask(playerPowerBar.intensity)
        playerPowerBar:AddToBarMask(playerPowerBar.intensity2)
        playerPowerBar:AddToBarMask(playerPowerBar.scrollTexture)
        playerPowerBar:AddToBarMask(playerPowerBar.scrollTexture2)
        playerPowerBar:AddToBarMask(playerPowerBar.runeoverlay)
        playerPowerBar.runicmask:SetSize(playerPowerBar:GetSize())
        playerPowerBar.runeoverlay:AddMaskTexture(playerPowerBar.runicmask)

        playerPowerBar.decay = GW.CreateAnimatedStatusBar(name .. "Decay", UIParent, nil, true)
        playerPowerBar.decay:SetFillAmount(0)

        playerPowerBar.decay:SetFrameLevel(playerPowerBar.decay:GetFrameLevel() - 1)
        playerPowerBar.decay:ClearAllPoints()
        playerPowerBar.decay:SetPoint("TOPLEFT", playerPowerBar, "TOPLEFT", 0, 0)
        playerPowerBar.decay:SetPoint("BOTTOMRIGHT", playerPowerBar, "BOTTOMRIGHT", 0, 0)
    end
    playerPowerBar.bar = playerPowerBar
    playerPowerBar.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    return playerPowerBar
end

-- the bar in the text preview, filled with your own power type
local function CreatePowerBarTextPreview(parent)
    local preview = CreateFrame("Frame", nil, parent)
    local bar = CreatePowerBar("GwPlayerPowerBarTextPreview")
    bar:SetParent(preview)
    bar:SetFrameStrata(parent:GetFrameStrata())
    bar:ClearAllPoints()
    bar:SetPoint("LEFT", 0, 0)
    if bar.decay then
        bar.decay:SetParent(preview)
    end
    bar:SetPowerBarVisuals(UnitPowerType("player"))
    if GW.isModern then
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(0.84)
    else
        bar:SetFillAmount(0.84)
    end
    preview:SetSize(bar:GetWidth(), bar:GetHeight() + 20)
    preview.texts = {powerText = bar.label}
    function preview:Refresh()
        AnchorLabel(bar)
    end
    preview:Refresh()
    return preview
end

function GW.GetPowerBarTextTarget()
    return {
        createPreview = CreatePowerBarTextPreview,
        player = true,
        categories = {power = true, color = true, text = true},
        lines = {{key = "powerText", label = GW.L["Power"]}},
        get = function() return GetPowerTextBlocks() end,
        -- nil goes back to the built-in line
        set = function(_, blocks)
            GW.settings.powerBar.powerText = blocks or false
            if GwPlayerPowerBar then
                GwPlayerPowerBar:ApplyTextTags()
            end
        end,
    }
end

local function LoadPowerBar()
    local playerPowerBar = CreatePowerBar("GwPlayerPowerBar")

    GW.RegisterMovableFrame(playerPowerBar, DISPLAY_POWER_BARS, "powerBar", "Unitframe,Power", nil, {GW.MoverOption.Scale}, true)

    playerPowerBar:ClearAllPoints()
    local point = GW.ClassPowers and GW.ClassPowers.GetAnchorPoint("TOPLEFT") or "TOPLEFT"
    playerPowerBar:SetPoint(point, playerPowerBar.gwMover, point)

    -- position mover, shift values are central in mainBarLayout.lua
    if (not GW.settings.hud.xpBar or GW.settings.unitframes.player.enabled) and not playerPowerBar.isMoved  then
        local framePoint = GW.settings.powerBar.pos
        local xOff, yOff = GW.GetHudClusterShift(GW.Enum.HudShiftDirection.Left)
        playerPowerBar.gwMover:ClearAllPoints()
        playerPowerBar.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs + xOff, framePoint.yOfs - yOff)
    end
    if not (GW.Classic or GW.TBC or GW.Wrath) then
        GW.MixinHideDuringPetAndOverride(playerPowerBar)
        GW.MixinHideDuringPetAndOverride(playerPowerBar.decay)
    end

    playerPowerBar:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    playerPowerBar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    playerPowerBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    playerPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    playerPowerBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

    playerPowerBar:ToggleSettings()
    playerPowerBar:ToggleBar()

    if (GW.Classic or GW.TBC or GW.Wrath or GW.Forever) and GW.settings.unitframes.player.energyManaTick then
        GW.Load5SR()
    end
end
GW.LoadPowerBar = LoadPowerBar
