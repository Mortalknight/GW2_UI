local _, GW = ...
local CommaValue = GW.CommaValue
local PowerBarColorCustom = GW.PowerBarColorCustom
local bloodSpark = GW.BLOOD_SPARK
local DODGEBAR_SPELLS = GW.DODGEBAR_SPELLS
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local AddToClique = GW.AddToClique
local Self_Hide = GW.Self_Hide
local TimeParts = GW.TimeParts

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
    if powerPrec== 0 then  self.bar:Hide() else  self.bar:Show() end
    
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

local function repair_OnEvent()
    local needRepair = false
    local gearBroken = false
    for i = 1, 23 do
        local current, maximum = GetInventoryItemDurability(i)
        if current ~= nil then
            local dur = current / maximum
            if dur < 0.5 then
                needRepair = true
            end
            if dur == 0 then
                gearBroken = true
            end
        end
    end

    if gearBroken then
        GwHudArtFrameRepairTexture:SetTexCoord(0, 1, 0.5, 1)
    else
        GwHudArtFrameRepairTexture:SetTexCoord(0, 1, 0, 0.5)
    end

    if needRepair then
        GwHudArtFrameRepair:Show()
    else
        GwHudArtFrameRepair:Hide()
    end
end
GW.AddForProfiling("playerhud", "repair_OnEvent", repair_OnEvent)

local function UpdatePowerData(self, forcePowerType, powerToken, forceAnimationName)
    if forcePowerType == nil then
        forcePowerType, powerToken, _ = UnitPowerType("player")
        forceAnimationName = "powerBarAnimation"
    end

    self.animating = true

    local power = UnitPower("Player", forcePowerType)
    local powerMax = UnitPowerMax("Player", forcePowerType)
    local powerPrec = 0
    local powerBarWidth = _G[self:GetName() .. "Bar"]:GetWidth()

    self.powerType = forcePowerType
    self.lostKnownPower = power
    self.powerMax = powerMax
    self.lastUpdate = GetTime()
    self.powerBarWidth = powerBarWidth

    if power > 0 and powerMax > 0 then
        powerPrec = power / powerMax
    end

    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        _G[self:GetName() .. "Bar"]:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
        _G[self:GetName() .. "CandySpark"]:SetVertexColor(pwcolor.r, pwcolor.g, pwcolor.b)
        _G[self:GetName() .. "Candy"]:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
        _G[self:GetName()].bar:SetVertexColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end

    if self.animationCurrent == nil then
        self.animationCurren = 0
    end

    AddToAnimation(
        self:GetName(),
        self.animationCurrent,
        powerPrec,
        GetTime(),
        0.2,
        function()
            local powerPrec = animations[self:GetName()]["progress"]
            local bit = powerBarWidth / 15
            local spark = bit * math.floor(15 * (powerPrec))

            local spark_current = (bit * (15 * (powerPrec)) - spark) / bit

            local bI = math.min(16, math.max(1, math.floor(17 - (16 * spark_current))))

            _G[self:GetName() .. "CandySpark"]:SetTexCoord(
                bloodSpark[bI].left,
                bloodSpark[bI].right,
                bloodSpark[bI].top,
                bloodSpark[bI].bottom
            )
            _G[self:GetName() .. "CandySpark"]:SetPoint("LEFT", _G[self:GetName()].bar, "RIGHT", -2, 0)
            local barPoint = spark + 3
            if animations[self:GetName()]["progress"] == 0 then  _G[self:GetName()].bar:Hide() else  _G[self:GetName()].bar:Show() end
            _G[self:GetName()].bar:SetPoint("RIGHT", self, "LEFT", barPoint, 0)
            _G[self:GetName() .. "Bar"]:SetValue(0)
            _G[self:GetName() .. "Candy"]:SetValue(0)

            if self.stringUpdateTime==nil or self.stringUpdateTime < GetTime() then
                 _G[self:GetName() .. "BarString"]:SetText(CommaValue(powerMax * animations[self:GetName()]["progress"]))
                self.stringUpdateTime = GetTime() + 0.1
            end
           

            self.animationCurrent = powerPrec
        end,
        "noease",
        function()
            self.animating = false
        end
    )

    if self.lastPowerType ~= self.powerType and self == GwPlayerPowerBar then
        self.lastPowerType = self.powerType
        self.powerCandySpark = _G[self:GetName() .. "CandySpark"]
        self.powerBar = _G[self:GetName() .. "Bar"]
        self.powerCandy = _G[self:GetName() .. "Candy"]
        self.powerBarString = _G[self:GetName() .. "BarString"]
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

local function globeFlashComplete()
    GwPlayerHealthGlobe.animating = true
    local lerpTo = 0

    if GwPlayerHealthGlobe.animationPrecentage == nil then
        GwPlayerHealthGlobe.animationPrecentage = 0
    end

    if GwPlayerHealthGlobe.animationPrecentage <= 0 then
        lerpTo = 0.4
    end

    AddToAnimation(
        "healthGlobeFlash",
        GwPlayerHealthGlobe.animationPrecentage,
        lerpTo,
        GetTime(),
        0.8,
        function()
            local l = animations["healthGlobeFlash"]["progress"]

            GwPlayerHealthGlobe.background:SetVertexColor(l, l, l)
        end,
        nil,
        function()
            local health = UnitHealth("Player")
            local healthMax = UnitHealthMax("Player")
            local healthPrec = 0.00001
            if health > 0 and healthMax > 0 then
                healthPrec = health / healthMax
            end
            if healthPrec < 0.5 then
                GwPlayerHealthGlobe.animationPrecentage = lerpTo
                globeFlashComplete()
            else
                GwPlayerHealthGlobe.background:SetVertexColor(0, 0, 0)
                GwPlayerHealthGlobe.animating = false
            end
        end
    )
end
GW.AddForProfiling("playerhud", "globeFlashComplete", globeFlashComplete)

local function updateHealthText(text)
    local v = CommaValue(text)
    _G["GwPlayerHealthGlobeTextValue"]:SetText(v)
    for i = 1, 8 do
        _G["GwPlayerHealthGlobeTextShadow" .. i]:SetText(v)
    end
end
GW.AddForProfiling("playerhud", "updateHealthText", updateHealthText)

local function updateAbsorbText(text)
    local v
    if text <= 0 then
        v = ""
    else
        v = CommaValue(text)
    end

    _G["GwPlayerAbsorbGlobeTextValue"]:SetText(v)
    for i = 1, 8 do
        _G["GwPlayerAbsorbGlobeTextShadow" .. i]:SetText(v)
    end
end
GW.AddForProfiling("playerhud", "updateAbsorbText", updateAbsorbText)

local healtGlobaFlareColors={}

healtGlobaFlareColors[0] = {r=79,g=10,b=5}
healtGlobaFlareColors[1] = {r=212,g=32,b=4}

local function lerpFlareColors(step)
    
    r = Lerp(healtGlobaFlareColors[0].r,healtGlobaFlareColors[1].r,step)
    g = Lerp(healtGlobaFlareColors[0].g,healtGlobaFlareColors[1].g,step)
    b = Lerp(healtGlobaFlareColors[0].b,healtGlobaFlareColors[1].b,step)
    
    return r/255, g/255, b/255
end
GW.AddForProfiling("playerhud", "lerpFlareColors", lerpFlareColors)

local function updateHealthData(self)
    local health = UnitHealth("Player")
    local healthMax = UnitHealthMax("Player")
    local healthPrec = 0.00001
    local absorb = UnitGetTotalAbsorbs("Player")

    local absorbPrec = 0.00001

    if health > 0 and healthMax > 0 then
        healthPrec = math.max(0.0001, health / healthMax)
    end

    if absorb > 0 and healthMax > 0 then
        absorbPrec = math.min(math.max(0.001, absorb / healthMax), 1)
        _G["GwPlayerHealthGlobeAbsorbBackdropBar"]:Show()
         GwPlayerHealthGlobeAbsorbBackdrop.spark:Show();
    else
       _G["GwPlayerHealthGlobeAbsorbBackdropBar"]:Hide(); 
        GwPlayerHealthGlobeAbsorbBackdrop.spark:Hide();
    end

    if healthPrec < 0.5 and (self.animating == false or self.animating == nil) then
        globeFlashComplete()
    end

    self.stringUpdateTime = 0

    local startTime = GetTime()
    AddToAnimation(
        "healthGlobeAnimation",
        self.animationCurrent,
        healthPrec,
        GetTime(),
        0.2,
        function()
            local healthPrecCandy = math.min(1, animations["healthGlobeAnimation"]["progress"] + 0.02)

            if self.stringUpdateTime < GetTime() then
                updateHealthText(healthMax * animations["healthGlobeAnimation"]["progress"])
                updateAbsorbText(absorb)
                self.stringUpdateTime = GetTime() + 0.05
            end
            
            local absorbPrecentage = (animations["healthGlobeAnimation"]["progress"] + absorbPrec) - 0.05
            if absorbPrec<=0.001   then absorbPrecentage = 0.01 end
            local healthAnimationReduction = math.max(0,math.min(1, animations["healthGlobeAnimation"]["progress"] - 0.05))
            if animations["healthGlobeAnimation"]["progress"]>=0.95 then  healthAnimationReduction = animations["healthGlobeAnimation"]["progress"] end
  
            

            _G["GwPlayerHealthGlobeAbsorbBackdrop"]:SetHeight(
                math.min(1, absorbPrecentage) *
                    _G["GwPlayerHealthGlobeHealthBar"]:GetWidth()
            )
            _G["GwPlayerHealthGlobeAbsorbBackdropBar"]:SetTexCoord(
                0,
                1,
                math.abs(math.min(1, absorbPrecentage) - 1),
                1
            )

            _G["GwPlayerHealthGlobeHealth"]:SetHeight(
                healthAnimationReduction * _G["GwPlayerHealthGlobeHealthBar"]:GetWidth()
            )
            _G["GwPlayerHealthGlobeHealthBar"]:SetTexCoord(
                0,
                1,
                math.abs(healthAnimationReduction - 1),
                1
            )
            if healthPrec <animations["healthGlobeAnimation"]["progress"] then
                GwPlayerHealthGlobeHealth.spark:SetAlpha(Lerp(1,0.5,( GetTime() - startTime)/ 0.2))
            end
        
            
        
           
            
            local bit = _G["GwPlayerHealthGlobeHealthBar"]:GetWidth() / 20
            local spark = bit * math.floor(4  * ( animations["healthGlobeAnimation"]["progress"]))

            local spark_current = (bit * (4 * ( animations["healthGlobeAnimation"]["progress"])) - spark) / bit
            local sprite = math.min(4, math.max(1, math.floor(5 - (6 * spark_current))))
            GwPlayerHealthGlobeHealth.spark:SetTexCoord(0,1, (0.25 * sprite) - 0.25,0.25*sprite)
            GwPlayerHealthGlobeHealth.spark2:SetTexCoord(0,1, (0.25 * sprite) - 0.25,0.25*sprite)
            local r,g,b = lerpFlareColors( healthAnimationReduction )
            GwPlayerHealthGlobeHealth.spark2:SetVertexColor(r,g,b,1)
            
            GwPlayerHealthGlobeAbsorbBackdrop.spark:SetTexCoord(0,1, (0.25 * sprite) - 0.25,0.25*sprite)
           
          
            
   
        end,
        nil,
        function()
            updateHealthText(health)
            updateAbsorbText(absorb)
        end
    )
    self.animationCurrent = healthPrec

    local absorbPrecOverflow = (healthPrec + absorbPrec) - 1
    _G["GwPlayerHealthGlobeAbsorb"]:SetHeight(absorbPrecOverflow * _G["GwPlayerHealthGlobeHealthBar"]:GetWidth())
    _G["GwPlayerHealthGlobeAbsorbBar"]:SetTexCoord(0, 1, math.abs(absorbPrecOverflow - 1), 1)
    if absorbPrecOverflow>0.001 then
        _G["GwPlayerHealthGlobeAbsorb"]:Show();
    else
        _G["GwPlayerHealthGlobeAbsorb"]:Hide(); 
    end
end
GW.AddForProfiling("playerhud", "updateHealthData", updateHealthData)



local function updateDodgeBar(start, duration, chargesMax, charges)
    --  GwDodgeBar.spark.anim:SetDegrees(63)
    --   GwDodgeBar.spark.anim:SetDuration(1)
    --  GwDodgeBar.spark.anim:Play()

    if chargesMax == charges then
        return
    end

    AddToAnimation(
        "GwDodgeBar",
        0,
        1,
        start,
        duration,
        function()
            local p = animations["GwDodgeBar"]["progress"]
            local c = (charges + p) / chargesMax
            GwDodgeBar.fill:SetTexCoord(0, 1 * c, 0, 1)
            GwDodgeBar.fill:SetWidth(114 * c)
        end,
        "noease"
    )
    GwDodgeBar.animation = 0
end
GW.AddForProfiling("playerhud", "updateDodgeBar", updateDodgeBar)

local function dodgeBar_OnEvent(self, event, unit)
    if event == "SPELL_UPDATE_COOLDOWN" then
        if self.gwDashSpell then
            local charges, maxCharges, start, duration
            if self.gwMaxCharges > 1 then
                charges, maxCharges, start, duration = GetSpellCharges(self.gwDashSpell)
            else
                charges = 0
                maxCharges = 1
                start, duration, _ = GetSpellCooldown(self.gwDashSpell)
            end
            updateDodgeBar(start, duration, maxCharges, charges)
        end
    elseif
        event == "PLAYER_SPECIALIZATION_CHANGED" or event == "CHARACTER_POINTS_CHANGED" or
            event == "PLAYER_ENTERING_WORLD"
     then
        local foundADash = false
        local _, _, c = UnitClass("player")
        self.gwMaxCharges = nil
        self.gwDashSpell = nil
        if DODGEBAR_SPELLS[c] ~= nil then
            for k, v in pairs(DODGEBAR_SPELLS[c]) do
                local name = GetSpellInfo(v)
                if name ~= nil then
                    if IsPlayerSpell(v) then
                        self.gwDashSpell = v
                        local charges, maxCharges, start, duration = GetSpellCharges(v)
                        if charges ~= nil and charges <= maxCharges then
                            foundADash = true
                            GwDodgeBar.spellId = v
                            self.gwMaxCharges = maxCharges
                            updateDodgeBar(start, duration, maxCharges, charges)
                            break
                        else
                            local start, duration, enable = GetSpellCooldown(v)
                            foundADash = true
                            GwDodgeBar.spellId = v
                            self.gwMaxCharges = 1
                            updateDodgeBar(start, duration, 1, 0)
                        end
                    end
                end
            end
        end
        if foundADash then
            if self.gwMaxCharges > 1 and self.gwMaxCharges < 3 then
                _G["GwDodgeBarSep1"]:Show()
            else
                _G["GwDodgeBarSep1"]:Hide()
            end

            if self.gwMaxCharges > 2 then
                _G["GwDodgeBarSep2"]:SetRotation(0.55)
                _G["GwDodgeBarSep3"]:SetRotation(-0.55)

                _G["GwDodgeBarSep2"]:Show()
                _G["GwDodgeBarSep3"]:Show()
            else
                _G["GwDodgeBarSep2"]:Hide()
                _G["GwDodgeBarSep3"]:Hide()
            end
            GwDodgeBar:Show()
        else
            GwDodgeBar:Hide()
        end
    end
end
GW.AddForProfiling("playerhud", "dodgeBar_OnEvent", dodgeBar_OnEvent)

local function LoadPowerBar()
    local playerPowerBar = CreateFrame("Frame", "GwPlayerPowerBar", UIParent, "GwPlayerPowerBar")

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

    playerPowerBar:RegisterEvent("UNIT_POWER_FREQUENT")
    playerPowerBar:RegisterEvent("UNIT_MAXPOWER")
    playerPowerBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    playerPowerBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    playerPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")

    UpdatePowerData(GwPlayerPowerBar)

    -- show/hide stuff with override bar
    OverrideActionBar:HookScript(
        "OnShow",
        function()
            playerPowerBar:SetAlpha(0)
        end
    )
    OverrideActionBar:HookScript(
        "OnHide",
        function()
            playerPowerBar:SetAlpha(1)
        end
    )
end
GW.LoadPowerBar = LoadPowerBar

local function selectPvp(self)
    local prevFlag = self.pvp.pvpFlag
    if C_PvP.IsWarModeDesired() or GetPVPDesired("player") or UnitIsPVP("player") or UnitIsPVPFreeForAll("player") then
        self.pvp.pvpFlag = true
        if prevFlag ~= true then
            local fac, _ = UnitFactionGroup("player")
            if fac == "Horde" then
                self.pvp.ally:Hide()
                self.pvp.horde:Show()
            else
                self.pvp.ally:Show()
                self.pvp.horde:Hide()
            end
            AddToAnimation(
                "pvpMarkerFlash",
                1,
                0.33,
                GetTime(),
                3,
                function()
                    self.pvp.ally:SetAlpha(animations["pvpMarkerFlash"]["progress"])
                    self.pvp.horde:SetAlpha(animations["pvpMarkerFlash"]["progress"])
                end
            )
        end
    else
        self.pvp.pvpFlag = false
        self.pvp.ally:Hide()
        self.pvp.horde:Hide()
    end
end
GW.AddForProfiling("playerhud", "selectPvp", selectPvp)

local MAIN_HUD_FRAMES = {
    "GwHudArtFrame",
    "GwPlayerPowerBar",
    "GwPlayerAuraFrame",
    "GwPlayerClassPower",
    "GwPlayerHealthGlobe",
    "GwPlayerPetFrame"
}

local function toggleMainHud(b, inCombat)
    for i, name in ipairs(MAIN_HUD_FRAMES) do
        local f = _G[name]
        if f then
            if b then
                if not inCombat then
                    f:Show()
                end
                if not f.visible then 
                    f:Hide()
                end
            else    
                f.visible = f:IsShown()
                if not inCombat then
                    f:Hide()
                end
            end
        end
    end
end

local function globe_OnEvent(self, event, unit)
    --Hide Healtglobe if not using our Actionbars
    local inCombat = UnitAffectingCombat("player")
    if event == "PET_BATTLE_OPENING_START" then
        toggleMainHud(false, inCombat)
    elseif event == "PET_BATTLE_CLOSE" then
        toggleMainHud(true, inCombat)
    end

    if unit ~= "player" then
        return
    end
    if
        event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "PLAYER_ENTERING_WORLD" or
            event == "UNIT_ABSORB_AMOUNT_CHANGED"
     then
        updateHealthData(self)
    elseif event == "WAR_MODE_STATUS_UPDATE" or event == "PLAYER_FLAGS_CHANGED" or event == "UNIT_FACTION" then
        selectPvp(self)
    end 
end
GW.AddForProfiling("playerhud", "globe_OnEvent", globe_OnEvent)

local function globe_OnEnter(self)
    local warmode = C_PvP.IsWarModeDesired()
    local pvpdesired = GetPVPDesired("player")
    local pvpactive = UnitIsPVP("player") or UnitIsPVPFreeForAll("player")

    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    if warmode or pvpdesired or pvpactive then
        GameTooltip_SetTitle(GameTooltip, PVP .. " - " .. VIDEO_OPTIONS_ENABLED)
    else
        GameTooltip_SetTitle(GameTooltip, PVP .. " - " .. VIDEO_OPTIONS_DISABLED)
    end
    if warmode then
        GameTooltip_AddNormalLine(GameTooltip, PVP_WARMODE_TOGGLE_ON, true)
    else
        if pvpdesired then
            GameTooltip_AddNormalLine(GameTooltip, PVP_TOGGLE_ON_VERBOSE, true)
        else
            if pvpactive then
                local pvpTime = GetPVPTimer()
                if pvpTime > 0 and pvpTime < 301000 then
                    local _, nMin, nSec, _ = TimeParts(pvpTime)
                    GameTooltip_AddNormalLine(
                        GameTooltip,
                        TIME_REMAINING .. " " .. string.format(TIMER_MINUTES_DISPLAY, nMin, nSec)
                    )
                end
                GameTooltip_AddNormalLine(GameTooltip, PVP_TOGGLE_OFF_VERBOSE, true)
            else
                GameTooltip_AddNormalLine(GameTooltip, PVP_WARMODE_TOGGLE_OFF, true)
            end
        end
    end
    GameTooltip:Show()
    AddToAnimation(
        "pvpMarkerFlash",
        0.33,
        1,
        GetTime(),
        0.5,
        function()
            self.pvp.ally:SetAlpha(animations["pvpMarkerFlash"]["progress"])
            self.pvp.horde:SetAlpha(animations["pvpMarkerFlash"]["progress"])
        end
    )
end
GW.AddForProfiling("playerhud", "globe_OnEnter", globe_OnEnter)

local function globe_OnLeave(self)
    GameTooltip_Hide()
    AddToAnimation(
        "pvpMarkerFlash",
        1,
        0.33,
        GetTime(),
        0.5,
        function()
            self.pvp.ally:SetAlpha(animations["pvpMarkerFlash"]["progress"])
            self.pvp.horde:SetAlpha(animations["pvpMarkerFlash"]["progress"])
        end
    )
end
GW.AddForProfiling("playerhud", "globe_OnLeave", globe_OnLeave)

local function LoadPlayerHud()
    PlayerFrame:SetScript("OnEvent", nil)
    PlayerFrame:Hide()

    local playerHealthGLobaBg = CreateFrame("Button", "GwPlayerHealthGlobe", UIParent, "GwPlayerHealthGlobe")
    GwPlayerHealthGlobe.animationCurrent = 0

    playerHealthGLobaBg:EnableMouse(true)
    --  RegisterUnitWatch(playerHealthGLobaBg);

    --DELETE ME AFTER ACTIONBARS REWORK
    playerHealthGLobaBg:SetAttribute("*type1", "target")
    playerHealthGLobaBg:SetAttribute("*type2", "togglemenu")
    playerHealthGLobaBg:SetAttribute("unit", "player")

    AddToClique(playerHealthGLobaBg)

    --  RegisterUnitWatch(playerHealthGLobaBg)
    _G["GwPlayerHealthGlobeTextValue"]:SetFont(DAMAGE_TEXT_FONT, 16)
    _G["GwPlayerHealthGlobeTextValue"]:SetShadowColor(1, 1, 1, 0)

    _G["GwPlayerAbsorbGlobeTextValue"]:SetFont(DAMAGE_TEXT_FONT, 16)
    _G["GwPlayerAbsorbGlobeTextValue"]:SetShadowColor(1, 1, 1, 0)

    for i = 1, 8 do
        _G["GwPlayerHealthGlobeTextShadow" .. i]:SetFont(DAMAGE_TEXT_FONT, 16)
        _G["GwPlayerHealthGlobeTextShadow" .. i]:SetShadowColor(1, 1, 1, 0)
        _G["GwPlayerHealthGlobeTextShadow" .. i]:SetTextColor(0, 0, 0, 1 / i)

        _G["GwPlayerAbsorbGlobeTextShadow" .. i]:SetFont(DAMAGE_TEXT_FONT, 16)
        _G["GwPlayerAbsorbGlobeTextShadow" .. i]:SetShadowColor(1, 1, 1, 0)
        _G["GwPlayerAbsorbGlobeTextShadow" .. i]:SetTextColor(0, 0, 0, 1 / i)
    end
    _G["GwPlayerHealthGlobeTextShadow1"]:SetPoint("CENTER", -1, 0)
    _G["GwPlayerHealthGlobeTextShadow2"]:SetPoint("CENTER", 0, -1)
    _G["GwPlayerHealthGlobeTextShadow3"]:SetPoint("CENTER", 1, 0)
    _G["GwPlayerHealthGlobeTextShadow4"]:SetPoint("CENTER", 0, 1)
    _G["GwPlayerHealthGlobeTextShadow5"]:SetPoint("CENTER", -2, 0)
    _G["GwPlayerHealthGlobeTextShadow6"]:SetPoint("CENTER", 0, -2)
    _G["GwPlayerHealthGlobeTextShadow7"]:SetPoint("CENTER", 2, 0)
    _G["GwPlayerHealthGlobeTextShadow8"]:SetPoint("CENTER", 0, 2)

    _G["GwPlayerAbsorbGlobeTextShadow1"]:SetPoint("CENTER", -1, 0)
    _G["GwPlayerAbsorbGlobeTextShadow2"]:SetPoint("CENTER", 0, -1)
    _G["GwPlayerAbsorbGlobeTextShadow3"]:SetPoint("CENTER", 1, 0)
    _G["GwPlayerAbsorbGlobeTextShadow4"]:SetPoint("CENTER", 0, 1)
    _G["GwPlayerAbsorbGlobeTextShadow5"]:SetPoint("CENTER", -2, 0)
    _G["GwPlayerAbsorbGlobeTextShadow6"]:SetPoint("CENTER", 0, -2)
    _G["GwPlayerAbsorbGlobeTextShadow7"]:SetPoint("CENTER", 2, 0)
    _G["GwPlayerAbsorbGlobeTextShadow8"]:SetPoint("CENTER", 0, 2)

    playerHealthGLobaBg:SetScript("OnEvent", globe_OnEvent)
    playerHealthGLobaBg:SetScript("OnEnter", globe_OnEnter)
    playerHealthGLobaBg:SetScript("OnLeave", globe_OnLeave)

    playerHealthGLobaBg:RegisterEvent("UNIT_HEALTH")
    playerHealthGLobaBg:RegisterEvent("UNIT_MAXHEALTH")
    playerHealthGLobaBg:RegisterEvent("PLAYER_ENTERING_WORLD")
    playerHealthGLobaBg:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    playerHealthGLobaBg:RegisterEvent("WAR_MODE_STATUS_UPDATE")
    playerHealthGLobaBg:RegisterEvent("PLAYER_FLAGS_CHANGED")
    playerHealthGLobaBg:RegisterEvent("UNIT_FACTION")
    
    
  
    local mask = UIParent:CreateMaskTexture()
    mask:SetTexture(
        "Textures\\MinimapMask",
        "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE"
    )
    mask:SetSize(105, 105)
    mask:SetPoint('CENTER',GwPlayerHealthGlobe,'CENTER')
    GwPlayerHealthGlobeHealth.spark:AddMaskTexture(mask);
    GwPlayerHealthGlobeHealth.spark2:AddMaskTexture(mask);
    GwPlayerHealthGlobeAbsorbBackdrop.spark:AddMaskTexture(mask);
    GwPlayerHealthGlobeHealth.spark.mask = mask;
    

    

    -- Hide HealthGlobe if not using our Actionbars
    if not GW.GetSetting("ACTIONBARS_ENABLED") then
        playerHealthGLobaBg:RegisterEvent("PET_BATTLE_CLOSE")
        playerHealthGLobaBg:RegisterEvent("PET_BATTLE_OPENING_START")
    end

    updateHealthData(playerHealthGLobaBg)
    selectPvp(playerHealthGLobaBg)

    local fmGDB = CreateFrame("Button", "GwDodgeBar", UIParemt, "GwDodgeBar")
    local fnGDB_OnEnter = function(self)
        self:SetScale(1.06)
        GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(self.spellId)
        GameTooltip:Show()
    end
    local fnGDB_OnLeave = function(self)
        self:SetScale(1)
        GameTooltip_Hide()
    end
    fmGDB:SetScript("OnEnter", fnGDB_OnEnter)
    fmGDB:SetScript("Onleave", fnGDB_OnLeave)

    local ag = GwDodgeBar.spark:CreateAnimationGroup()
    local anim = ag:CreateAnimation("Rotation")
    GwDodgeBar.spark.anim = anim
    ag:SetLooping("REPEAT")

    GwDodgeBar.animation = 0

    GwDodgeBar:SetScript("OnEvent", dodgeBar_OnEvent)

    GwDodgeBar:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    GwDodgeBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    GwDodgeBar:RegisterEvent("CHARACTER_POINTS_CHANGED")
    GwDodgeBar:RegisterEvent("PLAYER_ENTERING_WORLD")

    dodgeBar_OnEvent(GwDodgeBar, "PLAYER_ENTERING_WORLD", "player")

    -- setup hooks for the repair icon (and disable default repair frame)
    DurabilityFrame:UnregisterAllEvents()
    DurabilityFrame:HookScript("OnShow", Self_Hide)
    DurabilityFrame:Hide()
    GwHudArtFrameRepair:SetScript("OnEvent", repair_OnEvent)
    GwHudArtFrameRepair:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    GwHudArtFrameRepair:SetScript(
        "OnEnter",
        function()
            GameTooltip:SetOwner(_G["GwHudArtFrameRepair"], "ANCHOR_CURSOR")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(GwLocalization["DAMAGED_OR_BROKEN_EQUIPMENT"], 1, 1, 1)
            GameTooltip:Show()
        end
    )
    GwHudArtFrameRepair:SetScript("OnLeave", GameTooltip_Hide)
    repair_OnEvent()

    -- grab the TotemFrame so it remains visible
    if PlayerFrame and TotemFrame then
        TotemFrame:SetParent(playerHealthGLobaBg)
        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -500, 50)
        -- TODO: we can't position this directly; it's permanently attached to the PlayerFrame via SetPoints
        -- in the TotemFrame OnUpdate that we can't override because combat lockdowns and whatnot, and simply
        -- moving the PlayerFrame isn't ideal because its layout is highly variable; really we probably just
        -- need to completely re-implement the TotemFrame with a custom version
    end
    
    -- show/hide stuff with override bar
    OverrideActionBar:HookScript(
        "OnShow",
        function()
            GwPlayerHealthGlobe:SetAlpha(0)
            GwHudArtFrame:SetAlpha(0)
        end
    )
    OverrideActionBar:HookScript(
        "OnHide",
        function()
            GwPlayerHealthGlobe:SetAlpha(1)
            GwHudArtFrame:SetAlpha(1)
        end
    )
end
GW.LoadPlayerHud = LoadPlayerHud
