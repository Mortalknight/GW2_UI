local _, GW = ...
local CommaValue = GW.CommaValue
local PowerBarColorCustom = GW.PowerBarColorCustom
local bloodSpark = GW.BLOOD_SPARK
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local GetSetting = GW.GetSetting

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
    if self.powerToken == "MANA" then
        decayRate = 5
    end
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

local function UpdatePowerData(self, forcePowerType, powerToken)
    if forcePowerType == nil then
        forcePowerType, powerToken = UnitPowerType("player")
    end

    self.animating = true

    local power = UnitPower("player", forcePowerType)
    local powerMax = UnitPowerMax("player", forcePowerType)
    local powerPrec = 0
    local powerBarWidth = self.statusBar:GetWidth()

    self.powerType = forcePowerType
    self.powerToken = powerToken
    self.lostKnownPower = power
    self.powerMax = powerMax
    self.lastUpdate = GetTime()
    self.powerBarWidth = powerBarWidth

    if power >= 0 and powerMax > 0 then
        powerPrec = power / powerMax
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
            local powerPrec = animations[f.animKey].progress
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
end
GW.UpdatePowerData = UpdatePowerData

local function LoadPowerBar()
    local playerPowerBar = CreateFrame("Frame", "GwPlayerPowerBar", UIParent, "GwPlayerPowerBar")

    GW.RegisterMovableFrame(playerPowerBar, DISPLAY_POWER_BARS, "PowerBar_pos", "VerticalActionBarDummy", nil, true, {"default", "scaleable"}, true)

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

    _G[playerPowerBar:GetName() .. "CandySpark"]:ClearAllPoints()

    playerPowerBar:SetScript(
        "OnEvent",
        function(_, event, unit)
            if (event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER") and unit == "player" then
                UpdatePowerData(GwPlayerPowerBar)
                return
            end
            if event == "UPDATE_SHAPESHIFT_FORM" then
                GwPlayerPowerBar.lastPowerType = nil
                UpdatePowerData(GwPlayerPowerBar)
            end
        end
    )

    _G["GwPlayerPowerBarBarString"]:SetFont(DAMAGE_TEXT_FONT, 14)

    playerPowerBar:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    playerPowerBar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    playerPowerBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    playerPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")

    UpdatePowerData(GwPlayerPowerBar)
end
GW.LoadPowerBar = LoadPowerBar
