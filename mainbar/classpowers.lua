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

    local pwrMax = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    local pwr = UnitPower("player", Enum.PowerType.ComboPoints)

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
                        local p = animations["COMBOPOINTS_FLARE"].progress
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
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")

    if f.ourTarget and f.comboPointsOnTarget then
        f:ClearAllPoints()
        if GwTargetUnitFrame.frameInvert then
            f:SetPoint("TOPRIGHT", GwTargetUnitFrame.castingbar, "TOPRIGHT", 0, -13)
            f.combopoints:SetWidth(213)
        else
            f:SetPoint("TOPLEFT", GwTargetUnitFrame.castingbar, "TOPLEFT", 0, -13)
        end
        f:SetWidth(220)
        f:SetHeight(30)
        f.combopoints.comboFlare:SetSize(64, 64)
        local point = 0
        for i = 1, 9 do
            f.combopoints["runeTex" .. i]:SetSize(18, 18)
            f.combopoints["combo" .. i]:SetSize(18, 18)
            if GwTargetUnitFrame.frameInvert then
                f.combopoints["runeTex" .. i]:ClearAllPoints()
                f.combopoints["combo" .. i]:ClearAllPoints()
                f.combopoints["runeTex" .. i]:SetPoint("RIGHT", f.combopoints, "RIGHT", point, 0)
                f.combopoints["combo" .. i]:SetPoint("RIGHT", f.combopoints, "RIGHT", point, 0)
                point = point - 32
            end
        end
        f:Hide()
    end
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
    f:Hide()

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


-- DEATHKNIGHT
local RUNETYPE_BLOOD = 1
local RUNETYPE_FROST = 2
local RUNETYPE_UNHOLY = 3
local RUNETYPE_DEATH = 4

local iconTextures = {}
iconTextures[RUNETYPE_BLOOD] = "Interface/AddOns/GW2_UI/textures/altpower/runes-blood"
iconTextures[RUNETYPE_FROST] = "Interface/AddOns/GW2_UI/textures/altpower/runes"
iconTextures[RUNETYPE_UNHOLY] = "Interface/AddOns/GW2_UI/textures/altpower/runes-unholy"
iconTextures[RUNETYPE_DEATH] = "Interface/AddOns/GW2_UI/textures/altpower/runes-death"
local RUNE_TIMER_ANIMATIONS = {}
RUNE_TIMER_ANIMATIONS[1] = 0
RUNE_TIMER_ANIMATIONS[2] = 0
RUNE_TIMER_ANIMATIONS[3] = 0
RUNE_TIMER_ANIMATIONS[4] = 0
RUNE_TIMER_ANIMATIONS[5] = 0
RUNE_TIMER_ANIMATIONS[6] = 0
local function powerRune(self)
    local f = self
    local fr = self.runeBar
    for i = 1, 6 do
        local rune_start, rune_duration, rune_ready = GetRuneCooldown(i)
        local runeType = GetRuneType(i)
        local fFill = fr["runeTexFill" .. i]
        local fTex = fr["runeTex" .. i]
        local animId = "RUNE_TIMER_ANIMATIONS" .. i

        if rune_start == nil then
            rune_start = GetTime()
            rune_duration = 0
        end

        if runeType then
            fFill:SetTexture(iconTextures[runeType])
            fTex:SetTexture(iconTextures[runeType])
        end

        if rune_ready and fFill then
            fFill:SetTexCoord(0.5, 1, 0, 1)
            fFill:SetHeight(32)
            fFill:SetVertexColor(1, 1, 1)
            if animations[animId] then
                animations[animId].completed = true
                animations[animId].duration = 0
            end
        else
            if rune_start == 0 then
                return
            end

            AddToAnimation(
                animId,
                RUNE_TIMER_ANIMATIONS[i],
                1,
                rune_start,
                rune_duration,
                function()
                    fFill:SetTexCoord(0.5, 1, 1 - animations[animId].progress, 1)
                    fFill:SetHeight(32 * animations[animId].progress)
                    fFill:SetVertexColor(0.6 * animations[animId].progress, 0.6 * animations[animId].progress, 0.6 * animations[animId].progress)
                end,
                "noease",
                function()
                    f.flare:ClearAllPoints()
                    f.flare:SetPoint("CENTER", fFill, "CENTER", 0, 0)
                    AddToAnimation(
                        "HOLY_POWER_FLARE_ANIMATION",
                        1,
                        0,
                        GetTime(),
                        0.5,
                        function()
                            f.flare:SetAlpha(animations["HOLY_POWER_FLARE_ANIMATION"].progress)
                        end
                    )
                end
            )
            RUNE_TIMER_ANIMATIONS[i] = 0
        end
        fTex:SetTexCoord(0, 0.5, 0, 1)
    end
end

local function setDeathKnight(f)
    local fr = f.runeBar
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f.flare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/runeflash")
    f.flare:SetWidth(256)
    f.flare:SetHeight(128)
    fr:Show()

    f:SetScript("OnEvent", powerRune)
    powerRune(f)
    f:RegisterEvent("RUNE_POWER_UPDATE")
    f:RegisterEvent("RUNE_TYPE_UPDATE")

    return true
end
GW.AddForProfiling("classpowers", "setDeathKnight", setDeathKnight)

-- DRUID
local function setDruid(f)
    local form = f.gwPlayerForm
    local barType = "none"

    if form == 1 then -- cat
        barType = "combo|little_mana"
    elseif form == 5 or form == 8 then --bear
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
        return false
    end
end
GW.AddForProfiling("classpowers", "setDruid", setDruid)

--SHAMAN
local function setShaman(f)
    if MultiCastActionBarFrame:GetParent() ~= f and not InCombatLockdown() then
        MultiCastActionBarFrame.SetParent = nil
        MultiCastActionBarFrame.ClearAllPoints = nil
        MultiCastActionBarFrame.SetAllPoints = nil
        MultiCastActionBarFrame.SetPoint = nil

        MultiCastActionBarFrame:SetParent(f)
        MultiCastActionBarFrame:ClearAllPoints()
        MultiCastActionBarFrame:SetAllPoints(f)

        MultiCastActionBarFrame.SetParent = GW.NoOp
        MultiCastActionBarFrame.ClearAllPoints = GW.NoOp
        MultiCastActionBarFrame.SetAllPoints = GW.NoOp
        MultiCastActionBarFrame.SetPoint = GW.NoOp

        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", f.gwMover, "TOPLEFT", 0, 0)
    elseif MultiCastActionBarFrame:GetParent() ~= f and InCombatLockdown() then
        f.Script:RegisterEvent("PLAYER_REGEN_ENABLED")
    end

    f.background:Hide()
    f.fill:Hide()

    return true
end

local function selectType(f)
    f:SetScript("OnEvent", nil)
    f:UnregisterAllEvents()

    f.combopoints:Hide()
    f.runeBar:Hide()

    if f.ourPowerBar then
        GwPlayerPowerBarExtra:Hide()
    end
    f.gwPower = -1
    local showBar = false

    if GW.myClassID == 4 then
        showBar = setRogue(f)
    elseif GW.myClassID == 6 then
        showBar = setDeathKnight(f)
    elseif GW.myClassID == 7 then
        showBar = setShaman(f)
    elseif GW.myClassID == 11 then
        showBar = setDruid(f)
    end

    if (GW.myClassID == 4 or GW.myClassID == 11) and f.ourTarget and f.comboPointsOnTarget and f.barType == "combo" then
        showBar = UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target") or false
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
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        selectType(f)
    end
end

local function LoadClassPowers()
    local cpf = CreateFrame("Frame", "GwPlayerClassPower", UIParent, "GwPlayerClassPower")

    GW.RegisterMovableFrame(cpf, GW.L["Class Power"], "ClasspowerBar_pos", "VerticalActionBarDummy", nil, true, {"default", "scaleable"}, true)
    cpf:ClearAllPoints()
    cpf:SetPoint("TOPLEFT", cpf.gwMover)
    hooksecurefunc(cpf, "SetHeight", function() cpf.gwMover:SetHeight(cpf:GetHeight()) end)
    hooksecurefunc(cpf, "SetWidth", function() cpf.gwMover:SetWidth(cpf:GetWidth()) end)

    -- position mover
    if (not GetSetting("XPBAR_ENABLED") or GetSetting("PLAYER_AS_TARGET_FRAME")) and not cpf.isMoved  then
        local framePoint = GW.GetSetting("ClasspowerBar_pos")
        local yOff = not GetSetting("XPBAR_ENABLED") and 14 or 0
        local xOff = GetSetting("PLAYER_AS_TARGET_FRAME") and 52 or 0
        cpf.gwMover:ClearAllPoints()
        cpf.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs + xOff, framePoint.yOfs - yOff)
    end

    cpf.ourTarget = GetSetting("TARGET_ENABLED")
    cpf.comboPointsOnTarget = GetSetting("target_HOOK_COMBOPOINTS")
    cpf.ourPowerBar = GetSetting("POWERBAR_ENABLED")
    cpf.gwPlayerForm = GetShapeshiftFormID()

    -- create an extra mana power bar that is used sometimes (druid) only if our Powerbar is on
    if cpf.ourPowerBar then
        local anchorFrame = GetSetting("PLAYER_AS_TARGET_FRAME") and GwPlayerUnitFrame or GwPlayerPowerBar
        local barWidth = GetSetting("PLAYER_AS_TARGET_FRAME") and GwPlayerUnitFrame.powerbar:GetWidth() or GwPlayerPowerBar:GetWidth()
        local lmb = CreateFrame("Frame", "GwPlayerPowerBarExtra", anchorFrame, "GwPlayerPowerBar")
        cpf.lmb = lmb
        lmb.candy.spark:ClearAllPoints()

        lmb.bar:SetHeight(5)
        lmb.candy:SetHeight(5)
        lmb.candy.spark:SetHeight(5)
        lmb.statusBar:SetHeight(5)
        lmb:ClearAllPoints()
        if GetSetting("PLAYER_AS_TARGET_FRAME") then
            lmb:SetPoint("LEFT", anchorFrame.castingbarBackground, "LEFT", 2, 5)
            lmb:SetSize(barWidth + 2, 7)
            lmb.statusBar:SetWidth(barWidth - 2)
        else
            lmb:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, 5)
            lmb:SetSize(barWidth, 7)
        end
        lmb:SetFrameStrata("MEDIUM")
        lmb.statusBar.label:SetFont(DAMAGE_TEXT_FONT, 8)
    end

    cpf.Script:SetScript("OnEvent", barChange_OnEvent)
    cpf.Script:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

    selectType(cpf)

    if (GW.myClassID == 4 or GW.myClassID == 11) and (cpf.ourTarget and cpf.comboPointsOnTarget) then
        cpf.Script:RegisterEvent("PLAYER_TARGET_CHANGED")
        if cpf.barType == "combo" then
            cpf:Hide()
        end
    end
end
GW.LoadClassPowers = LoadClassPowers