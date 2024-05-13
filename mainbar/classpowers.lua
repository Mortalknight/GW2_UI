local _, GW = ...
local AddToAnimation = GW.AddToAnimation
local animations = GW.animations
local GetSetting = GW.GetSetting
local UpdatePowerData = GW.UpdatePowerData

local function UpdateVisibility(self, inCombat)
    if self.onlyShowInCombat then
        self:SetShown(inCombat and self.shouldShowBar)
    else
        self:SetShown(self.shouldShowBar)
    end
end

local function updateVisibilitySetting(self, updateVis)
    self.onlyShowInCombat = GW.GetSetting("CLASSPOWER_ONLY_SHOW_IN_COMBAT")
    if self.onlyShowInCombat then
        self.decay:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.decay:RegisterEvent("PLAYER_REGEN_DISABLED")
    else
        self.decay:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self.decay:UnregisterEvent("PLAYER_REGEN_DISABLED")
    end
    if updateVis then
        UpdateVisibility(self, false)
    end
end
GW.UpdateClassPowerVisibilitySetting = updateVisibilitySetting

local function findBuff(unit, searchID)
    if unit == "player" then
        local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(searchID)
        if auraInfo then
            return auraInfo.name, auraInfo.applications, auraInfo.duration, auraInfo.expirationTime
        end
    else
        local auraData
        for i = 1, 40 do
            auraData = C_UnitAuras.GetAuraDataByIndex(unit, i)
            if auraData and auraData.spellId == searchID then
                return auraData.name, auraData.applications, auraData.duration, auraData.expirationTime
            elseif not auraData then
                break
            end
        end
    end

    return nil, nil, nil, nil
end

---Styling for powerbars
local function setPowerTypePaladinShield(self)
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/bloster")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/spark")
    self.runeoverlay:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/bloster-intensity")
    self.runeoverlay:SetAlpha(1)
    self.spark:SetBlendMode("ADD")
    self.spark:SetAlpha(0.3)
    self.customMaskSize = 30
end

local function animFlarePoint(f, point, to, from, duration)
    local ff = f.flare
    ff:ClearAllPoints()
    ff:SetPoint("CENTER", point, "CENTER", 0, 0)
    AddToAnimation(
        "POWER_FLARE_ANIM",
        1,
        0,
        GetTime(),
        duration,
        function(p)
            p = math.min(1, math.max(0, p))
            ff:SetAlpha(p)
        end
    )
end

local function powerEclipsOnUpdate(self, event, ...)
    local pwrMax = UnitPowerMax(self.unit, Enum.PowerType.Balance)
    local pwr = UnitPower(self.unit, Enum.PowerType.Balance)
    if self.oldEclipsPower ~= nil and self.oldEclipsPower == pwr then
        return
    end

    AddToAnimation(
        "ECLIPS_BAR",
        self.oldEclipsPower,
        pwr,
        GetTime(),
        0.2,
        function()
            local p = animations["ECLIPS_BAR"].progress
            local pwrP = p / pwrMax;
            local pwrAbs = math.abs(p) / pwrMax;
            local segmentSize = self.eclips:GetWidth() / 2
            local arrowPosition = segmentSize * pwrP

            local clampedArrowPosition = math.max(math.min(arrowPosition, segmentSize - 9), -segmentSize + 9)
            self.eclips.arrow:SetPoint("CENTER", self.background, "CENTER", clampedArrowPosition, 0)
            self.eclips.fill:ClearAllPoints()
            if p > 0 then
                self.eclips.fill:SetPoint("LEFT", self.background, "CENTER", 0, 0)
                self.eclips.fill:SetPoint("RIGHT", self.background, "CENTER", arrowPosition, 0)
                self.eclips.fill:SetTexCoord(0, pwrAbs, 0, 1)
            else
                self.eclips.fill:SetPoint("LEFT", self.background, "CENTER", arrowPosition, 0)
                self.eclips.fill:SetPoint("RIGHT", self.background, "CENTER", 0, 0)
                self.eclips.fill:SetTexCoord(0, pwrAbs, 0, 1)
            end
            self.oldEclipsPower = p;
        end
    )
end
local function powerEclips(self, event, ...)
    if event == "ECLIPSE_DIRECTION_CHANGE" then
        local direction = ...
        if direction == "sun" then
            self.eclips.arrow:SetTexCoord(0, 1, 0, 1)
        elseif direction == "moon" then
            self.eclips.arrow:SetTexCoord(1, 0, 0, 1)
        else
            self.eclips.lunar:Hide()
            self.eclips.solar:Hide()
        end
    elseif event == "UNIT_AURA" then
        local aura = findBuff("player", ECLIPSE_BAR_LUNAR_BUFF_ID)
        if aura ~= nil then
            self.eclips.lunar:Show()
            self.eclips.solar:Hide()
            return
        end
        aura = findBuff("player", ECLIPSE_BAR_SOLAR_BUFF_ID)
        if aura ~= nil then
            self.eclips.lunar:Hide()
            self.eclips.solar:Show()
            return
        end
        self.eclips.lunar:Hide()
        self.eclips.solar:Hide()
    end
end

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

local function setEclips(f)
    f.eclips:Show()
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)

    f:SetScript("OnUpdate", powerEclipsOnUpdate)
    f:SetScript("OnEvent", powerEclips)
    powerEclips(f, "CLASS_POWER_INIT")

    f:RegisterUnitEvent("UNIT_AURA", "player")
    f:RegisterEvent("ECLIPSE_DIRECTION_CHANGE")
end
local function setComboBar(f)
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", f.gwMover, "TOPLEFT", 0, 0)
    f.barType = "combo"
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f:SetHeight(32)
    f.combopoints:Show()

    f:SetScript("OnEvent", powerCombo)
    powerCombo(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end

local function powerMana(self, event, ...)
    local ptype = select(2, ...)
    if event == "CLASS_POWER_INIT" or ptype == "MANA" then
        UpdatePowerData(self.exbar, 0, "MANA")

        C_Timer.After(0.12, function()
            if GwPlayerPowerBar and GwPlayerPowerBar.powerType == 0 then
                self.exbar:Hide()
                self.exbar.decay:Hide()
            else
                if self.barType == "mana" then
                    self.exbar:Show()
                    self.exbar.decay:Show()
                end
            end
        end)
    end
end

local function powerLittleMana(self, event, ...)
    local ptype = select(2, ...)
    if event == "CLASS_POWER_INIT" or ptype == "MANA" then
        UpdatePowerData(self:GetParent().lmb, 0, "MANA")
    end
end
GW.AddForProfiling("classpowers", "powerLittleMana", powerLittleMana)

local function setManaBar(f)
    f.barType = "mana"
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f.exbar:Show()
    f:SetHeight(14)

    f:ClearAllPoints()
    if GW.GetSetting("XPBAR_ENABLED") or (f.isMoved and not CPF_HOOKED_TO_TARGETFRAME) then
        f:SetPoint("TOPLEFT", f.gwMover, 0, -13)
    else
        f:SetPoint("TOPLEFT", f.gwMover, 0, -3)
    end

    f:Hide()

    f:SetScript("OnEvent", powerMana)
    C_Timer.After(0.5, function() powerMana(f, "CLASS_POWER_INIT") end)
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end

local function setLittleManaBar(f, barType)
    f.barType = barType -- used in druid feral form and evoker ebon might bar
    f.lmb:Show()
    f.lmb.decay:Show()

    f.littleManaBarEventFrame:SetScript("OnEvent", powerLittleMana)
    powerLittleMana(f.littleManaBarEventFrame, "CLASS_POWER_INIT")
    f.littleManaBarEventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f.littleManaBarEventFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end

-- ROGUE
local function setRogue(f)
    if GetSetting("target_HOOK_COMBOPOINTS") then return false end

    setComboBar(f)
    return true
end

--priest
local function shadowOrbs(self, event, ...)
    if event ~= "CLASS_POWER_INIT" and event ~= "UNIT_AURA" then
        return
    end

    local _, count, _, _ = findBuff("player", 77487)
    if count == nil then
        count = 0
    end

    local old_power = self.gwPower
    local pwr = count
    if pwr < 2 then
        self.background:SetAlpha(0.2)
    else
        self.background:SetAlpha(1)
    end
    for _, v in pairs(self.priest.power) do
        local id = tonumber(v:GetParentKey())
        if old_power < id and pwr >= id then
            animFlarePoint(self, v, 1, 0, 0.5)
        end
        if pwr >= 3 and id < 4 then
            v:SetTexCoord(0, 0.5, 0.5, 1)
        elseif pwr >= id then
            v:SetTexCoord(0.5, 1, 0, 0.5)
        elseif pwr < id then
            v:SetTexCoord(0, 0.5, 0, 0.5)
        end
    end
    self.gwPower = pwr;
end
GW.AddForProfiling("classpowers", "shadowOrbs", shadowOrbs)

--PALADIN
local function powerHoly(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "HOLY_POWER" and event ~= "UNIT_AURA" then
        return
    end
    if event == "UNIT_AURA" then
        local _, _, duration, expires = findBuff("player", 132403)
        if duration ~= nil then
            local remainingPrecantage = (expires - GetTime()) / duration
            local remainingTime = duration * remainingPrecantage
            self.customResourceBar:setCustomAnimation(remainingPrecantage, 0, remainingTime)
        end
    else
        local old_power = self.gwPower
        local pwr = UnitPower("player", 9)
        if pwr < 2 then
            self.background:SetAlpha(0.2)
        else
            self.background:SetAlpha(1)
        end
        for _, v in pairs(self.paladin.power) do
            local id = tonumber(v:GetParentKey())
            if old_power < id and pwr >= id then
                animFlarePoint(self, v, 1, 0, 0.5)
            end
            if pwr >= 3 and id < 4 then
                v:SetTexCoord(0, 0.5, 0.5, 1)
            elseif pwr >= id then
                v:SetTexCoord(0.5, 1, 0, 0.5)
            elseif pwr < id then
                v:SetTexCoord(0, 0.5, 0, 0.5)
            end
        end
        self.gwPower = pwr;
    end
end
GW.AddForProfiling("classpowers", "powerHoly", powerHoly)

local function setPaladin(f)
    --if GW.myspec == 2 then -- prot
    --f.background:SetTexture(nil)
    --f.fill:SetTexture(nil)
    --local fd = f.decay
    --fd.bar:SetStatusBarColor(0.85, 0.65, 0)
    --fd.bar.texture1:SetVertexColor(1, 1, 1, 0)
    --fd.bar.texture2:SetVertexColor(1, 1, 1, 0)
    --fd.bar:SetValue(0)
    --fd:Show()

    --f:SetScript("OnEvent", powerSotR)
    --powerSotR(f, "CLASS_POWER_INIT")
    --f:RegisterUnitEvent("UNIT_AURA", "player")

    --return true
    --elseif GW.myspec == 3 or GW.myspec == 5 then -- retribution / standard
    f.paladin:Show()

    f.background:ClearAllPoints()
    f.background:SetHeight(41)
    f.background:SetWidth(181)
    f.background:SetTexCoord(0, 0.70703125, 0, 0.640625)
    f.paladin:ClearAllPoints()
    f.paladin:SetPoint("TOPLEFT", GwPlayerClassPower.gwMover, 0, 0)
    f.paladin:SetPoint("BOTTOMLEFT", GwPlayerClassPower.gwMover, 0, 0)
    f.background:SetPoint("LEFT", GwPlayerClassPower.gwMover, "LEFT", 0, 2)

    f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/holypower/background")

    f.fill:Hide()

    f:SetScript("OnEvent", powerHoly)
    powerHoly(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

    if GW.myspec == 2 then
        f.customResourceBar:SetWidth(164)
        f.customResourceBar:ClearAllPoints()
        f.customResourceBar:SetPoint("RIGHT", GwPlayerClassPower.gwMover, 2, 0)
        f.customResourceBar:Show()

        setPowerTypePaladinShield(f.customResourceBar)

        f:RegisterUnitEvent("UNIT_AURA", "player")
    end

    return true
    --end

    --return false
end

-- WARLOCK
local function powerSoulshard(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "SOUL_SHARDS" then
        return
    end

    local pwrMax = UnitPowerMax("player", 7)
    local pwr = UnitPower("player", 7)
    local old_power = self.gwPower
    self.gwPower = pwr

    for i = 1, pwrMax do
        if pwr >= i then
            self.warlock["shard" .. i]:Show()
            self.warlock.shardFlare:ClearAllPoints()
            self.warlock.shardFlare:SetPoint("CENTER", self.warlock["shard" .. i], "CENTER", 0, 0)
            if pwr > old_power then
                self.warlock.shardFlare:Show()
                AddToAnimation(
                    "WARLOCK_SHARD_FLARE",
                    0,
                    5,
                    GetTime(),
                    0.7,
                    function(p)
                        p = GW.RoundInt(p)
                        self.warlock.shardFlare:SetTexCoord(GW.getSpriteByIndex(self.warlock.flareMap, p))
                    end,
                    nil,
                    function()
                        self.warlock.shardFlare:Hide()
                    end
                )
            end
        else
            self.warlock["shard" .. i]:Hide()
        end
    end
end
GW.AddForProfiling("classpowers", "powerSoulshard", powerSoulshard)

local function setWarlock(f)
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f:SetHeight(32)
    f.warlock:Show()
    f.warlock.shardFragment:Hide()
    f:SetScript("OnEvent", powerSoulshard)
    powerSoulshard(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

    return true
end
GW.AddForProfiling("classpowers", "setWarlock", setWarlock)

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

local getBlizzardRuneId = {
    [1] = 1,
    [2] = 2,
    [3] = 5,
    [4] = 6,
    [5] = 3,
    [6] = 4,
}

local function powerRune(self)
    local f = self
    local fr = self.runeBar
    for i = 1, 6 do
        local correctRuneId = getBlizzardRuneId[i]
        local rune_start, rune_duration, rune_ready = GetRuneCooldown(correctRuneId)
        local runeType = GetRuneType(correctRuneId)
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
                function(p)
                    fFill:SetTexCoord(0.5, 1, 1 - p, 1)
                    fFill:SetHeight(32 * p)
                    fFill:SetVertexColor(0.6 * p, 0.6 * p, 0.6 * p)
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
                        function(p)
                            f.flare:SetAlpha(math.min(1, math.max(0, p)))
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
local function setPriest(f)
    if GW.myspec == 3 then
        f.priest:Show()

        f.background:ClearAllPoints()
        f.background:SetHeight(41)
        f.background:SetWidth(181)
        f.background:SetTexCoord(0, 0.70703125, 0, 0.640625)
        f.priest:ClearAllPoints()
        f.priest:SetPoint("TOPLEFT", GwPlayerClassPower.gwMover, 0, 0)
        f.priest:SetPoint("BOTTOMLEFT", GwPlayerClassPower.gwMover, 0, 0)
        f.background:SetPoint("LEFT", GwPlayerClassPower.gwMover, "LEFT", 0, 2)

        f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/shadoworbs/background")

        f.fill:Hide()

        f:SetScript("OnEvent", shadowOrbs)
        shadowOrbs(f, "CLASS_POWER_INIT")
        f:RegisterUnitEvent("UNIT_AURA", "player")

        return true
    end
    return false
end
GW.AddForProfiling("classpowers", "setPriest", setPriest)

-- DRUID
local function setDruid(f)
    local form = f.gwPlayerForm
    local barType = "none"

    if form == CAT_FORM then                   -- cat
        barType = "combo|little_mana"
    elseif form == BEAR_FORM or form == 8 then --bear
        barType = "mana"
    elseif form == MOONKIN_FORM then           --Moonkin
        barType = "eclips"
    end

    f.eclips:Hide()

    if barType == "combo|little_mana" then
        setComboBar(f)
        if f.ourPowerBar then
            setLittleManaBar(f)
        end
        return true
    elseif barType == "little_mana" and f.ourPowerBar then
        setLittleManaBar(f)
        return false
    elseif barType == "mana" then
        setManaBar(f)
        return true
    elseif barType == "eclips" then
        setEclips(f)
        return true
    else
        f.barType = "none"
        return false
    end
end
GW.AddForProfiling("classpowers", "setDruid", setDruid)

--SHAMAN
local function setShaman(f)
    if not InCombatLockdown() then
        UIPARENT_MANAGED_FRAME_POSITIONS.MultiCastActionBarFrame = nil

        MultiCastActionBarFrame:SetParent(f)
        MultiCastActionBarFrame:ClearAllPoints()
        MultiCastActionBarFrame:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, 5)
    elseif InCombatLockdown() then
        f.Script:RegisterEvent("PLAYER_REGEN_ENABLED")
    end

    f.background:Hide()
    f.fill:Hide()

    return true
end

local function selectType(f)
    f:SetScript("OnEvent", nil)
    f:UnregisterAllEvents()

    f.customResourceBar:ForceFillAmount(0)
    f.customResourceBar:resetPowerBarVisuals()
    f.customResourceBar:Hide()
    f.customResourceBar:SetWidth(313)
    f.combopoints:Hide()
    f.runeBar:Hide()
    f.paladin:Hide()
    f.decay:Hide()
    f.exbar:Hide()
    f.eclips:Hide()
    f.priest:Hide()
    f.warlock:Hide()

    if GW.GetSetting("POWERBAR_ENABLED") then
        f.lmb:Hide()
        f.lmb.decay:Hide()
    end
    f.gwPower = -1
    local showBar = false

    if f.unit == "vehicle" then
        showBar = false
    elseif GW.myClassID == 2 then
        showBar = setPaladin(f)
    elseif GW.myClassID == 4 then
        showBar = setRogue(f)
    elseif GW.myClassID == 5 then
        showBar = setPriest(f)
    elseif GW.myClassID == 6 then
        showBar = setDeathKnight(f)
    elseif GW.myClassID == 7 then
        showBar = setShaman(f)
    elseif GW.myClassID == 9 then
        showBar = setWarlock(f)
    elseif GW.myClassID == 11 then
        showBar = setDruid(f)
    end

    if showBar and not f:IsShown() then
        f:Show()
    elseif not showBar and f:IsShown() then
        f:Hide()
    end

    f.shouldShowBar = showBar

    UpdateVisibility(f)
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
        if UnitExists("target") and UnitCanAttack(f.unit, "target") and f.barType == "combo" and not UnitIsDead("target") then
            f:Show()
        elseif f.barType == "combo" then
            f:Hide()
        end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        f.gwPlayerForm = GetShapeshiftFormID()
        GW.CheckRole()
        selectType(f)
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        selectType(f)
    elseif event == "UNIT_ENTERED_VEHICLE" then
        f.unit = "vehicle"
        selectType(f)
    elseif event == "UNIT_EXITED_VEHICLE" then
        f.unit = "player"
        selectType(f)
    end
end
--GWTEST = barChange_OnEvent
--/run GWTEST(GwPlayerClassPower.Script, "UNIT_ENTERED_VEHICLE")
--/run GWTEST(GwPlayerClassPower.Script, "UNIT_EXITED_VEHICLE")

local function LoadClassPowers()
    local cpf = CreateFrame("Frame", "GwPlayerClassPower", UIParent, "GwPlayerClassPower")
    --GW.hookStatusbarBehaviour(cpf.staggerBar.ironskin, false)
    --cpf.staggerBar.ironskin.customMaskSize = 64
    --cpf.staggerBar.ironskin.customMaskSize = 64

    cpf.customResourceBar = GW.createNewStatusbar("GwCustomResourceBar", cpf, "GwStatusPowerBar", true)
    cpf.customResourceBar.customMaskSize = 64
    cpf.customResourceBar.bar = cpf.customResourceBar
    cpf.customResourceBar:addToBarMask(cpf.customResourceBar.intensity)
    cpf.customResourceBar:addToBarMask(cpf.customResourceBar.intensity2)
    cpf.customResourceBar:addToBarMask(cpf.customResourceBar.scrollTexture)
    cpf.customResourceBar:addToBarMask(cpf.customResourceBar.scrollTexture2)
    cpf.customResourceBar:addToBarMask(cpf.customResourceBar.runeoverlay)
    cpf.customResourceBar.runicmask:SetSize(cpf.customResourceBar:GetSize())
    cpf.customResourceBar.runeoverlay:AddMaskTexture(cpf.customResourceBar.runicmask)

    cpf.customResourceBar.decay = GW.createNewStatusbar("GwPlayerPowerBarDecay", UIParent, nil, true)

    cpf.customResourceBar.decay:SetFillAmount(0)
    cpf.customResourceBar.decay:SetFrameLevel(cpf.customResourceBar.decay:GetFrameLevel() - 1)
    cpf.customResourceBar.decay:ClearAllPoints()
    cpf.customResourceBar.decay:SetPoint("TOPLEFT", cpf.customResourceBar, "TOPLEFT", 0, 0)
    cpf.customResourceBar.decay:SetPoint("BOTTOMRIGHT", cpf.customResourceBar, "BOTTOMRIGHT", 0, 0)

    cpf.customResourceBar:SetScript("OnShow", function() cpf.customResourceBar.decay:Show() end)
    cpf.customResourceBar:SetScript("OnHide", function() cpf.customResourceBar.decay:Hide() end)

    cpf.customResourceBar:ClearAllPoints()
    cpf.customResourceBar:SetPoint("LEFT", cpf, "LEFT", 0, -11) -- GLow help, is this the proper way of aligning this?

    GW.initPowerBar(cpf.customResourceBar)

    GW.RegisterMovableFrame(cpf, GW.L["Class Power"], "ClasspowerBar_pos", ALL .. ",Unitframe,Power", { 312, 32 },
        { "default", "scaleable" }, true)


    -- position mover
    if (not GW.GetSetting("XPBAR_ENABLED") or GW.GetSetting("PLAYER_AS_TARGET_FRAME")) and not cpf.isMoved then
        local framePoint = GW.GetSetting("ClasspowerBar_pos")
        local yOff = not GW.GetSetting("XPBAR_ENABLED") and 14 or 0
        local xOff = GW.GetSetting("PLAYER_AS_TARGET_FRAME") and 52 or 0
        cpf.gwMover:ClearAllPoints()
        cpf.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs + xOff,
            framePoint.yOfs - yOff)
    end
    cpf:ClearAllPoints()
    cpf:SetPoint("TOPLEFT", cpf.gwMover)

    GW.MixinHideDuringPetAndOverride(cpf)
    GW.MixinHideDuringPetAndOverride(cpf.customResourceBar)
    GW.MixinHideDuringPetAndOverride(cpf.customResourceBar.decay)
    --CPWR_FRAME = cpf

    -- create an extra mana power bar that is used sometimes (feral druid in cat form) only if your Powerbar is on
    if GW.GetSetting("POWERBAR_ENABLED") then
        local anchorFrame = GW.GetSetting("PLAYER_AS_TARGET_FRAME") and GwPlayerUnitFrame and GwPlayerUnitFrame or
            GwPlayerPowerBar
        local barWidth = GW.GetSetting("PLAYER_AS_TARGET_FRAME") and GwPlayerUnitFrame and
            GwPlayerUnitFrame.powerbar:GetWidth() or GwPlayerPowerBar:GetWidth()
        local lmb = GW.createNewStatusbar("GwPlayerAltClassLmb", cpf, "GwStatusPowerBar", true)
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
        if GW.GetSetting("PLAYER_AS_TARGET_FRAME") then
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

        GW.MixinHideDuringPetAndOverride(lmb)
        GW.MixinHideDuringPetAndOverride(lmb.decay)
    end

    -- create an extra mana power bar that is used sometimes
    local exbar = GW.createNewStatusbar("GwPlayerAltClassExBar", cpf, "GwStatusPowerBar", true)
    exbar.customMaskSize = 64
    exbar.bar = exbar
    exbar:addToBarMask(exbar.intensity)
    exbar:addToBarMask(exbar.intensity2)
    exbar:addToBarMask(exbar.scrollTexture)
    exbar:addToBarMask(exbar.scrollTexture2)
    exbar:addToBarMask(exbar.runeoverlay)
    exbar.runicmask:SetSize(exbar:GetSize())
    exbar.runeoverlay:AddMaskTexture(exbar.runicmask)

    exbar.decay = GW.createNewStatusbar("GwPlayerPowerBarDecay", exbar, nil, true)
    exbar.decay:SetFillAmount(0)
    exbar.decay:SetFrameLevel(exbar.decay:GetFrameLevel() - 1)
    exbar.decay:ClearAllPoints()
    exbar.decay:SetPoint("TOPLEFT", exbar, "TOPLEFT", 0, 0)
    exbar.decay:SetPoint("BOTTOMRIGHT", exbar, "BOTTOMRIGHT", 0, 0)

    GW.MixinHideDuringPetAndOverride(exbar)
    GW.MixinHideDuringPetAndOverride(exbar.decay)
    cpf.exbar = exbar
    GW.initPowerBar(cpf.exbar)
    exbar:SetPoint("TOPLEFT", cpf)

    exbar:SetFrameStrata("MEDIUM")
    exbar.label:SetFont(DAMAGE_TEXT_FONT, 12)
    exbar.label:SetShadowColor(0, 0, 0, 1)
    exbar.label:SetShadowOffset(1, -1)

    -- set a bunch of other init styling stuff
    --cpf.decayCounter.count:SetFont(DAMAGE_TEXT_FONT, 24, "OUTLINED")
    --cpf.brewmaster.debugpre = 0
    --cpf.brewmaster.stagger.indicatorText:SetFont(UNIT_NAME_FONT, 11)
    --cpf.brewmaster.ironskin.indicatorText:SetFont(UNIT_NAME_FONT, 11)
    --cpf.brewmaster.ironskin.expires = 0
    --cpf.staggerBar.value = 0
    --cpf.staggerBar.spark = cpf.staggerBar.bar.spark
    --cpf.staggerBar.texture1 = cpf.staggerBar.bar.texture1
    --cpf.staggerBar.texture2 = cpf.staggerBar.bar.texture2
    --cpf.staggerBar.fill = cpf.staggerBar.bar.fill
    --cpf.staggerBar.fill:SetVertexColor(59 / 255, 173 / 255, 231 / 255)
    --cpf.disc.bar.overlay:SetModel(1372783)
    --cpf.disc.bar.overlay:SetPosition(0, 0, 2)
    --cpf.disc.bar.overlay:SetPosition(0, 0, 0)

    cpf.decay:SetScript("OnEvent", barChange_OnEvent)
    cpf.decay:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    cpf.decay:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    cpf.decay:RegisterEvent("PLAYER_ENTERING_WORLD")
    cpf.decay:RegisterEvent("CHARACTER_POINTS_CHANGED")
    cpf.decay:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
    cpf.decay:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")

    cpf.unit = "player"

    cpf.gwPlayerForm = GetShapeshiftFormID()

    cpf.ourPowerBar = GW.GetSetting("POWERBAR_ENABLED")

    updateVisibilitySetting(cpf, false)
    selectType(cpf)
end
GW.LoadClassPowers = LoadClassPowers
