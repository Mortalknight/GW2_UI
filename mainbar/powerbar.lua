local _, GW = ...
local CommaValue = GW.CommaValue
local PowerBarColorCustom = GW.PowerBarColorCustom
local bloodSpark = GW.BLOOD_SPARK
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation

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

    local bit = powerBarWidth / 15
    local spark = bit * math.floor(15 * (powerPrec))

    local spark_current = (bit * (15 * (powerPrec)) - spark) / bit

    local bI = math.min(16, math.max(1, math.floor(17 - (16 * spark_current))))

    self.powerCandySpark:SetTexCoord(
        bloodSpark[bI].left,
        bloodSpark[bI].right,
        bloodSpark[bI].top,
        bloodSpark[bI].bottom
    )
    local barPoint = spark + 3
    if powerPrec == 0 then
        self.bar:Hide()
    else
        self.bar:Show()
    end

    self.powerCandySpark:SetPoint("LEFT", self.bar, "RIGHT", -2, 0)
    self.bar:SetPoint("RIGHT", self, "LEFT", barPoint, 0)

    self.powerBar:SetValue(0)
    self.powerCandy:SetValue(0)

    if self.textUpdate < GetTime() then
        self.powerBarString:SetText(CommaValue(powerMax * powerPrec))
        self.textUpdate = GetTime() + 0.2
    end

    self.animationCurrent = powerPrec
end
GW.AddForProfiling("playerhud", "powerBar_OnUpdate", powerBar_OnUpdate)

local function UpdatePowerData(self, forcePowerType, powerToken, forceAnimationName)
    if forcePowerType == nil then
        forcePowerType, powerToken, _ = UnitPowerType("player")
        forceAnimationName = "powerBarAnimation"
    end

    self.animating = true

    local power = UnitPower("player", forcePowerType)
    local powerMax = UnitPowerMax("player", forcePowerType)
    local powerPrec
    local powerBarWidth = self.statusBar:GetWidth()

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

    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.statusBar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
        self.candy.spark:SetVertexColor(pwcolor.r, pwcolor.g, pwcolor.b)
        self.candy:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
        self.bar:SetVertexColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end

    if self.animationCurrent == nil then
        self.animationCurrent = 0
    end

    if not self.animKey then
        self.animKey = tostring(self)
    end
    local f = self
    AddToAnimation(
        self.animKey,
        self.animationCurrent,
        powerPrec,
        GetTime(),
        0.2,
        function()
            local powerPrec = animations[f.animKey]["progress"]
            local bit = powerBarWidth / 15
            local spark = bit * math.floor(15 * (powerPrec))

            local spark_current = (bit * (15 * (powerPrec)) - spark) / bit

            local bI = math.min(16, math.max(1, math.floor(17 - (16 * spark_current))))

            f.candy.spark:SetTexCoord(
                bloodSpark[bI].left,
                bloodSpark[bI].right,
                bloodSpark[bI].top,
                bloodSpark[bI].bottom
            )
            f.candy.spark:SetPoint("LEFT", f.bar, "RIGHT", -2, 0)
            local barPoint = spark + 3
            if animations[f.animKey]["progress"] == 0 then
                f.bar:Hide()
            else
                f.bar:Show()
            end
            f.bar:SetPoint("RIGHT", f, "LEFT", barPoint, 0)
            f.statusBar:SetValue(0)
            f.candy:SetValue(0)

            if f.stringUpdateTime == nil or f.stringUpdateTime < GetTime() then
                --f.statusBar.label:SetText(CommaValue(powerMax * animations[f.animKey]["progress"]))
                f.statusBar.label:SetText(CommaValue(f.lostKnownPower))
                f.stringUpdateTime = GetTime() + 0.1
            end

            f.animationCurrent = powerPrec
        end,
        "noease",
        function()
            f.animating = false
        end
    )

    if self.lastPowerType ~= self.powerType and self == GwPlayerPowerBar then
        self.lastPowerType = self.powerType
        self.powerCandySpark = self.candy.spark
        self.powerBar = self.statusBar
        self.powerCandy = self.candy
        self.powerBarString = self.statusBar.label
        if
            self.powerType == nil or self.powerType == 1 or self.powerType == 6 or self.powerType == 13 or
                self.powerType == 8
        then
            self:SetScript("OnUpdate", nil)
        else
            self:SetScript("OnUpdate", powerBar_OnUpdate)
        end
    end
end
GW.UpdatePowerData = UpdatePowerData

local function LoadPowerBar()
    local playerPowerBar = CreateFrame("Frame", "GwPlayerPowerBar", UIParent, "GwPlayerPowerBar")
    GW.RegisterScaleFrame(playerPowerBar)
    if GW.GetSetting("XPBAR_ENABLED") then
        playerPowerBar:SetPoint('BOTTOMLEFT', UIParent, "BOTTOM", 53, 86)
    else
        playerPowerBar:SetPoint('BOTTOMLEFT', UIParent, "BOTTOM", 53, 72)
    end
    GW.MixinHideDuringPetAndOverride(playerPowerBar)

    _G[playerPowerBar:GetName() .. "CandySpark"]:ClearAllPoints()

    playerPowerBar:SetScript(
        "OnEvent",
        function(self, event, unit)
            if (event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER") and unit == "player" then
                UpdatePowerData(GwPlayerPowerBar)
                return
            end
            if event == "UPDATE_SHAPESHIFT_FORM" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
                GwPlayerPowerBar.lastPowerType = nil
                UpdatePowerData(GwPlayerPowerBar)
            end
        end
    )

    _G["GwPlayerPowerBarBarString"]:SetFont(DAMAGE_TEXT_FONT, 14)

    playerPowerBar:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    playerPowerBar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    playerPowerBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    playerPowerBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    playerPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    playerPowerBar:RegisterEvent("PLAYER_TALENT_UPDATE")

    UpdatePowerData(GwPlayerPowerBar)
end
GW.LoadPowerBar = LoadPowerBar
