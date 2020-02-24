local _, GW = ...
local AddToAnimation = GW.AddToAnimation
local animations = GW.animations
local GetSetting = GW.GetSetting
local UpdatePowerData = GW.UpdatePowerData

local MAX_COMBO_POINTS = 5

local function findBuff(unit, searchID)
    local spellID
    for i = 1, 40 do
        spellID = select(10, UnitBuff(unit, i))
        if spellID == searchID then
            return spellID
        elseif not spellID then
            break
        end
    end

    return nil
end
GW.AddForProfiling("classpowers", "findBuff", findBuff)

local function animFlare(f, scale, offset, duration, rotate)
    scale = scale or 32
    offset = offset or 0
    duration = duration or 0.5
    rotate = rotate or false
    local ff = f.flare
    local pwr = f.gwPower
    ff:ClearAllPoints()
    ff:SetPoint("CENTER", f, "LEFT", (scale * pwr) + offset, 0)
    AddToAnimation(
        "POWER_FLARE_ANIM",
        1,
        0,
        GetTime(),
        duration,
        function()
            local p = animations["POWER_FLARE_ANIM"]["progress"]
            ff:SetAlpha(p)
            if rotate then
                ff:SetRotation(1 * p)
            end
        end
    )
end

local function powerCombo(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "COMBO_POINTS" then
        return
    end

    local old_power = self.gwPower
    old_power = old_power or -1

    local pwr = GetComboPoints("player", "target")
    local p = pwr - 1

    if pwr > 0 and not self:IsShown() and UnitExists("target") then
        self:Show()
    end
    self.gwPower = pwr

    self.background:SetTexCoord(0, 1, 0.125 * (MAX_COMBO_POINTS - 1), 0.125 * MAX_COMBO_POINTS)
    self.fill:SetTexCoord(0, 1, 0.125 * p, 0.125 * (p + 1))

    if old_power < pwr and event ~= "CLASS_POWER_INIT" then
        animFlare(self, 40)
    end
end

local function setComboBar(f)
    f.barType = "combo"
    f:SetHeight(40)
    f:SetWidth(320)
    f.background:SetHeight(32)
    f.background:SetWidth(256)
    f.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\combo-bg")
    f.background:SetTexCoord(0, 1, 0.5, 1)
    f.flare:SetWidth(128)
    f.flare:SetHeight(128)
    f.flare:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\combo-flash")
    f.fill:SetHeight(40)
    f.fill:SetWidth(320)
    f.fill:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\combo")

    f:SetScript("OnEvent", powerCombo)
    powerCombo(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")

    if f.ourTarget and f.comboPointsOnTarget then
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", GwTargetUnitFrame.castingbar, "TOPLEFT", -8, -10)
        f:SetWidth(220)
        f:SetHeight(30)
        f:Hide()
    end
end

local function powerMana(self, event, ...)
    local ptype = select(2, ...)
    if event == "CLASS_POWER_INIT" or ptype == "MANA" then
        UpdatePowerData(self, 0, "MANA", "GwPlayerPowerBar")
    end
end

local function setManaBar(f)
    f.barType = "mana"
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    GwPlayerPowerBarExtra:Show()

    if GetSetting("target_HOOK_COMBOPOINTS") and GetSetting("TARGET_ENABLED") then
        f:ClearAllPoints()
        if GetSetting("XPBAR_ENABLED") then
            f:SetPoint('BOTTOMLEFT', UIParent, "BOTTOM", -372, 81)
        else
            f:SetPoint('BOTTOMLEFT', UIParent, "BOTTOM", -372, 67)
        end
        f:SetWidth(220)
        f:SetHeight(30)
        f:Hide()
    end

    GwPlayerPowerBarExtra:SetScript("OnEvent", powerMana)
    powerMana(GwPlayerPowerBarExtra, "CLASS_POWER_INIT")
    GwPlayerPowerBarExtra:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    GwPlayerPowerBarExtra:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end

-- ROGUE
local function setRogue(f)
    setComboBar(f)
    return true
end

-- DRUID
local function setDruid(f)
    local form = f.gwPlayerForm
    local barType = "none"
    local extraManaBar = false

    if form == 768 then
        barType = "combo"
    end
    if UnitPowerType("Player") ~= 0 then
        extraManaBar = true
    end
    if extraManaBar then
        setManaBar(f)
    end
    if barType == "combo" then
        return true
    else
        return false
    end
end
GW.AddForProfiling("classpowers", "setDruid", setDruid)

local function selectType(f)
    f:SetScript("OnEvent", nil)
    f:UnregisterAllEvents()

    local pClass = f.gwPlayerClass

    GwPlayerPowerBarExtra:Hide()
    f.gwPower = -1
    local showBar = false

    if pClass == 4 then
        showBar = setRogue(f)
    elseif pClass == 11 then
        showBar = setDruid(f)
    end
    if showBar then
        f:Show()
    else
        f:Hide()
    end
end

local function barChange_OnEvent(self, event, ...)
    local f = self:GetParent()
    if event == "UPDATE_SHAPESHIFT_FORM" then
        -- this event fires often when form hasn't changed; check old form against current form
        -- to prevent touching the bar unnecessarily (which causes annoying anim flickering)
        local results = findBuff("player", 768)
        if f.gwPlayerForm == results then
            return
        end
        f.gwPlayerForm = results
        selectType(f)
    elseif event == "PLAYER_TARGET_CHANGED" then
        if UnitExists("target") and UnitIsEnemy("player", "target") and f.barType == "combo" and not UnitIsDead("target") then
            f:Show()
        else
            f:Hide()
        end
    end
end

local function LoadClassPowers()
    local _, _, pClass = UnitClass("player")

    local cpf = CreateFrame("Frame", "GwPlayerClassPower", UIParent, "GwPlayerClassPower")
    if GW.GetSetting("XPBAR_ENABLED") then
        cpf:SetPoint('BOTTOMLEFT', UIParent, "BOTTOM", -372, 81)
    else
        cpf:SetPoint('BOTTOMLEFT', UIParent, "BOTTOM", -372, 67)
    end

    cpf.gwPlayerClass = pClass
    cpf.ourTarget = GetSetting("TARGET_ENABLED")
    cpf.comboPointsOnTarget = GetSetting("target_HOOK_COMBOPOINTS")
    cpf.gwPlayerForm = findBuff("player", 768)

    -- create an extra mana power bar that is used sometimes (druid)
    local exbar = CreateFrame("Frame", "GwPlayerPowerBarExtra", GwPlayerPowerBar, "GwPlayerPowerBar")
    exbar.candy.spark:ClearAllPoints()
    exbar:SetSize(GwPlayerPowerBar:GetWidth(), 5)
    exbar.bar:SetHeight(5)
    exbar.candy:SetHeight(5)
    exbar.candy.spark:SetHeight(5)
    exbar.statusBar:SetHeight(5)
    exbar:ClearAllPoints()
    exbar:SetPoint("TOPLEFT", "GwPlayerPowerBar", "TOPLEFT", 0, 5)
    exbar:SetFrameStrata("MEDIUM")
    exbar.statusBar.label:SetFont(DAMAGE_TEXT_FONT, 8)

    cpf.Script:SetScript("OnEvent", barChange_OnEvent)
    cpf.Script:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

    selectType(cpf)

    if (pClass == 4 or pClass == 11) and (cpf.ourTarget and cpf.comboPointsOnTarget) then
        cpf.Script:RegisterEvent("PLAYER_TARGET_CHANGED")
        if cpf.barType == "combo" then
            cpf:Hide()
        end
    end
end
GW.LoadClassPowers = LoadClassPowers