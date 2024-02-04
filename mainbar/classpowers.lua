local _, GW = ...
local AddToAnimation = GW.AddToAnimation
local animations = GW.animations
local GetSetting = GW.GetSetting
local UpdatePowerData = GW.UpdatePowerData

local function powerCombo(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "COMBO_POINTS" then
        return
    end

    local pwrMax = UnitPowerMax(self.unit, Enum.PowerType.ComboPoints)
    local pwr = UnitPower(self.unit, Enum.PowerType.ComboPoints)
    local comboPoints = GetComboPoints(self.unit, "target")

    if self.unit == "vehicle" then
        if comboPoints == 0 then
            self.combopoints:Hide()
            return
        else
            self.combopoints:Show()
        end
    end

    local old_power = self.gwPower
    self.gwPower = pwr

    if pwr > 0 and not self:IsShown() and UnitExists("target") then
        self.combopoints:Show()
    end

    -- hide all not needed ones
    for i = pwrMax + 1, 9 do
        self.combopoints["runeTex" .. i]:Hide()
        self.combopoints["combo" .. i]:Hide()
    end


    for i = 1, pwrMax do
        if pwr >= i then
            self.combopoints["combo" .. i]:SetTexCoord(0.5, 1, 0.5, 0)
            self.combopoints["runeTex" .. i]:Show()
            self.combopoints["combo" .. i]:Show()
            self.combopoints.comboFlare:ClearAllPoints()
            self.combopoints.comboFlare:SetPoint("CENTER", self.combopoints["combo" .. i], "CENTER", 0, 0)
            if pwr > old_power then
                self.combopoints.comboFlare:Show()
                AddToAnimation(
                    "COMBOPOINTS_FLARE",
                    0,
                    5,
                    GetTime(),
                    0.5,
                    function()
                        local p = math.min(1, math.max(0, animations["COMBOPOINTS_FLARE"].progress))
                        self.combopoints.comboFlare:SetAlpha(p)
                    end,
                    nil,
                    function()
                        self.combopoints.comboFlare:Hide()
                    end
                )
            end
        else
            self.combopoints["combo" .. i]:Hide()
        end
    end
end

local function setComboBar(f)
    f.barType = "combo"
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f:SetHeight(32)
    f.combopoints:Show()

    f:SetScript("OnEvent", powerCombo)
    powerCombo(f, "CLASS_POWER_INIT")
    f:RegisterEvent("UNIT_MAXPOWER")
    f:RegisterEvent("UNIT_POWER_UPDATE")
end

local function powerMana(self, event, ...)
    local ptype = select(2, ...)
    if event == "CLASS_POWER_INIT" or ptype == "MANA" then
        UpdatePowerData(self, 0, "MANA", "GwLittlePowerBar")
    end
end

local function setManaBar(f)
    f.barType = "combo"  -- we use this only for druid extra bar
    GwPlayerPowerBarExtra:Show()

    f:SetWidth(220)
    f:SetHeight(30)
    --f:Hide()

    GwPlayerPowerBarExtra:SetScript("OnEvent", powerMana)
    powerMana(GwPlayerPowerBarExtra, "CLASS_POWER_INIT")
    GwPlayerPowerBarExtra:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    GwPlayerPowerBarExtra:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end

-- ROGUE
local function setRogue(f)
    if GetSetting("target_HOOK_COMBOPOINTS") then return false end

    setComboBar(f)
    return true
end

-- DRUID
local function setDruid(f)
    local form = f.gwPlayerForm
    local barType = "none"

    if form == CAT_FORM then -- cat
        barType = "combo|little_mana"
    elseif form == BEAR_FORM or form == 8 then --bear
        barType = "little_mana"
    end

    if barType == "combo|little_mana" then
        setComboBar(f)
        if f.ourPowerBar then
            setManaBar(f)
        end
        return true
    elseif barType == "little_mana" and f.ourPowerBar then
        setManaBar(f)
        return false
    else
        f.barType = "none"
        return false
    end
end
GW.AddForProfiling("classpowers", "setDruid", setDruid)

local function selectType(f)
    f:SetScript("OnEvent", nil)
    f:UnregisterAllEvents()

    f.combopoints:Hide()

    if GwPlayerPowerBarExtra then
        GwPlayerPowerBarExtra:Hide()
    end
    f.gwPower = -1
    local showBar = false

    if GW.myClassID == 4 then
        showBar = setRogue(f)
    elseif GW.myClassID == 11 then
        showBar = setDruid(f)
    end

    if showBar and not f:IsShown() then
        f:Show()
    elseif not showBar and f:IsShown() then
        f:Hide()
    end
end

local function barChange_OnEvent(self, event, ...)
    local f = self:GetParent()
    if event == "UPDATE_SHAPESHIFT_FORM" then
        -- this event fires often when form hasn't changed; check old form against current form
        -- to prevent touching the bar unnecessarily (which causes annoying anim flickering)
        local results = GetShapeshiftFormID()
        if f.gwPlayerForm == results then
            return
        end
        f.gwPlayerForm = results
        selectType(f)
    elseif event == "PLAYER_TARGET_CHANGED" then
        if UnitExists("target") and UnitCanAttack("player", "target") and f.barType == "combo" and not UnitIsDead("target") then
            f:Show()
        elseif f.barType == "combo" then
            f:Hide()
        end
    elseif event == "UNIT_ENTERED_VEHICLE" then
        f.unit = "vehicle"
        selectType(f)
    elseif event == "UNIT_EXITED_VEHICLE" then
        f.unit = "player"
        selectType(f)
    end
end

local function LoadClassPowers()
    local cpf = CreateFrame("Frame", "GwPlayerClassPower", UIParent, "GwPlayerClassPower")

    GW.RegisterMovableFrame(cpf, GW.L["Class Power"], "ClasspowerBar_pos", ALL .. ",Unitframe,Power", {316, 32}, {"default", "scaleable"}, true)
    cpf:ClearAllPoints()
    cpf:SetPoint("TOPLEFT", cpf.gwMover)
    hooksecurefunc(cpf, "SetHeight", function() if not InCombatLockdown() then  cpf.gwMover:SetHeight(cpf:GetHeight()) end end)
    hooksecurefunc(cpf, "SetWidth", function() if not InCombatLockdown() then cpf.gwMover:SetWidth(cpf:GetWidth()) end end)

    -- position mover
    if (not GetSetting("XPBAR_ENABLED") or GetSetting("PLAYER_AS_TARGET_FRAME")) and not cpf.isMoved  then
        local framePoint = GW.GetSetting("ClasspowerBar_pos")
        local yOff = not GetSetting("XPBAR_ENABLED") and 14 or 0
        local xOff = GetSetting("PLAYER_AS_TARGET_FRAME") and 52 or 0
        cpf.gwMover:ClearAllPoints()
        cpf.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs + xOff, framePoint.yOfs - yOff)
    end

    cpf.ourPowerBar = GetSetting("POWERBAR_ENABLED")
    cpf.gwPlayerForm = GetShapeshiftFormID()

    -- create an extra mana power bar that is used sometimes (druid) only if our Powerbar is on
    if cpf.ourPowerBar then
        local anchorFrame = GetSetting("PLAYER_AS_TARGET_FRAME") and _G.GwPlayerUnitFrame or _G.GwPlayerPowerBar
        local barWidth = GetSetting("PLAYER_AS_TARGET_FRAME") and _G.GwPlayerUnitFrame.powerbar:GetWidth() or _G.GwPlayerPowerBar:GetWidth()
        local lmb = GW.createNewStatusbar("GwPlayerPowerBarExtra", cpf, "GwStatusPowerBar", true)
        lmb.customMaskSize = 64
        lmb.bar = lmb
        lmb:addToBarMask(lmb.intensity)
        lmb:addToBarMask(lmb.intensity2)
        lmb:addToBarMask(lmb.scrollTexture)
        lmb:addToBarMask(lmb.scrollTexture2)
        lmb:addToBarMask(lmb.runeoverlay)
        lmb.runicmask:SetSize(lmb:GetSize())
        lmb.runeoverlay:AddMaskTexture(lmb.runicmask)
        cpf.lmb = lmb

        GW.initPowerBar(cpf.lmb)

        lmb.decay = GW.createNewStatusbar("GwPlayerPowerBarDecay", lmb, nil, true)
        lmb.decay:SetFillAmount(0)
        lmb.decay:SetFrameLevel(lmb.decay:GetFrameLevel() - 1)
        lmb.decay:ClearAllPoints()
        lmb.decay:SetPoint("TOPLEFT", lmb, "TOPLEFT", 0, 0)
        lmb.decay:SetPoint("BOTTOMRIGHT", lmb, "BOTTOMRIGHT", 0, 0)

        lmb:ClearAllPoints()
        if GetSetting("PLAYER_AS_TARGET_FRAME") then
            lmb:SetPoint("BOTTOMLEFT", anchorFrame.powerbar, "TOPLEFT", 0, -10)
            lmb:SetPoint("BOTTOMRIGHT", anchorFrame.powerbar, "TOPRIGHT", 0, -10)
            lmb:SetSize(barWidth + 2, 3)
        else
            lmb:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 0)
            lmb:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 0)
            lmb:SetSize(barWidth, 5)
        end
        lmb:SetFrameStrata("MEDIUM")
        lmb.label:SetFont(DAMAGE_TEXT_FONT, 12)
        lmb.label:SetShadowColor(0, 0, 0, 1)
        lmb.label:SetShadowOffset(1, -1)
    end

    cpf.Script:SetScript("OnEvent", barChange_OnEvent)
    cpf.Script:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    cpf.Script:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
	cpf.Script:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")

    cpf.unit = "player"

    selectType(cpf)
end
GW.LoadClassPowers = LoadClassPowers