local _, GW = ...
local lerp = GW.lerp
local RoundInt = GW.RoundInt
local UpdatePowerData = GW.UpdatePowerData
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local GetSetting = GW.GetSetting

local CPWR_FRAME

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
GW.AddForProfiling("classpowers", "powerFlare", powerFlare)

local function decayCounter_OnAnim()
    local f = CPWR_FRAME
    local fdc = f.decayCounter
    local p = animations["DECAYCOUNTER_BAR"]["progress"]
    local px = p * 262
    fdc.precentage = p
    fdc.bar:SetValue(p)
    fdc.bar.spark:ClearAllPoints()
    fdc.bar.spark:SetPoint("RIGHT", fdc.bar, "LEFT", px, 0)
    fdc.bar.spark:SetWidth(math.min(15, math.max(1, px)))
end
GW.AddForProfiling("classpowers", "decayCounter_OnAnim", decayCounter_OnAnim)

local function decayCounterFlash_OnAnim()
    local f = CPWR_FRAME
    local fdc = f.decayCounter
    fdc.flash:SetAlpha(animations["DECAYCOUNTER_TEXT"]["progress"])
end
GW.AddForProfiling("classpowers", "decayCounterFlash_OnAnim", decayCounterFlash_OnAnim)

local function decay_OnAnim()
    local f = CPWR_FRAME
    local fd = f.decay
    local p = animations["DECAY_BAR"]["progress"]
    local px = p * 310
    fd.precentage = p
    fd.bar:SetValue(p)
    fd.bar.spark:ClearAllPoints()
    fd.bar.spark:SetPoint("RIGHT", fd.bar, "LEFT", px, 0)
    fd.bar.spark:SetWidth(math.min(15, math.max(1, px)))
end
GW.AddForProfiling("classpowers", "decay_OnAnim", decay_OnAnim)

local function findBuff(unit, searchID)
    local name, count, duration, expires, spellID
    for i = 1, 40 do
        name, _, count, _, duration, expires, _, _, _, spellID, _ = UnitAura(unit, i)
        if spellID == searchID then
            return name, count, duration, expires
        elseif not spellID then
            break
        end
    end

    return nil, nil, nil, nil
end
GW.AddForProfiling("classpowers", "findBuff", findBuff)

local searchIDs = {}
local function findBuffs(unit, ...)
    local name, count, duration, expires, spellID
    table.wipe(searchIDs)
    for i = 1, select("#", ...) do
        searchIDs["ID" .. select(i, ...)] = true
    end
    local results = nil
    for i = 1, 40 do
        name, _, count, _, duration, expires, _, _, _, spellID, _ = UnitAura(unit, i)
        if not spellID then
            break
        elseif searchIDs["ID" .. spellID] then
            if results == nil then
                results = {}
            end
            results[#results + 1] = {name, count, duration, expires}
        end
    end

    return results
end
GW.AddForProfiling("classpowers", "findBuffs", findBuffs)

-- MANA (multi class use)
local function powerMana(self, event, ...)
    local ptype = select(2, ...)
    if event == "CLASS_POWER_INIT" or ptype == "MANA" then
        UpdatePowerData(self.exbar, 0, "MANA", "GwExtraPowerBar")
    end
end
GW.AddForProfiling("classpowers", "powerMana", powerMana)

local function powerLittleMana(self, event, ...)
    local ptype = select(2, ...)
    if event == "CLASS_POWER_INIT" or ptype == "MANA" then
        UpdatePowerData(self:GetParent().lmb, 0, "MANA", "GwLittlePowerBar")
    end
end
GW.AddForProfiling("classpowers", "powerLittleMana", powerLittleMana)

local function setManaBar(f)
    f.barType = "mana"
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f.exbar:Show()

    f:ClearAllPoints()
    if GetSetting("XPBAR_ENABLED") then
        f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", -372, 81)
    else
        f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", -372, 67)
    end
    f:SetWidth(220)
    f:SetHeight(30)
    f:Hide()

    f:SetScript("OnEvent", powerMana)
    powerMana(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end
GW.AddForProfiling("classpowers", "setManaBar", setManaBar)

local function setLittleManaBar(f)
    f.barType = "combo"  -- only used in feral form, so we need to show the combo points
    f.lmb:Show()

    f.littleManaBarEventFrame:SetScript("OnEvent", powerLittleMana)
    powerLittleMana(f.littleManaBarEventFrame, "CLASS_POWER_INIT")
    f.littleManaBarEventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f.littleManaBarEventFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end
GW.AddForProfiling("classpowers", "setManaBar", setManaBar)

-- COMBO POINTS (multi class use)
local function powerCombo(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "COMBO_POINTS" then
        return
    end

    local old_power = self.gwPower
    old_power = old_power or -1
    

    local pwrMax = UnitPowerMax("player", 4)
    local pwr = UnitPower("player", 4)
    local p = pwr - 1

    if pwr > 0 and not self:IsShown() and UnitExists("target") then
        self:Show()
    end

    self.gwPower = pwr

    self.background:SetTexCoord(0, 1, 0.125 * (pwrMax - 1), 0.125 * pwrMax)
    self.fill:SetTexCoord(0, 1, 0.125 * p, 0.125 * (p + 1))

    if old_power < pwr and event ~= "CLASS_POWER_INIT" then
        animFlare(self, 40)
    end
end
GW.AddForProfiling("classpowers", "powerCombo", powerCombo)

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
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

    if f.ourTarget and f.comboPointsOnTarget then
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", GwTargetUnitFrame.castingbar, "TOPLEFT", -8, -10)
        f:SetWidth(220)
        f:SetHeight(30)
        f:Hide()
    end
end
GW.AddForProfiling("classpowers", "setComboBar", setComboBar)

-- WARRIOR
local function powerEnrage(self, event, ...)
    local _, _, duration, expires = findBuff("player", 184362)
    if duration ~= nil then
        local pre = (expires - GetTime()) / duration
        AddToAnimation("DECAY_BAR", pre, 0, GetTime(), expires - GetTime(), decay_OnAnim, "noease")
    end
end
GW.AddForProfiling("classpowers", "powerEnrage", powerEnrage)

local function powerSBlock(self, event, ...)
    local results
    if self.gw_BolsterSelected then
        results = findBuffs("player", 132404, 871, 12975)
    else
        results = findBuffs("player", 132404, 871)
    end
    if results == nil then
        return
    end
    local duration = -1
    local expires = -1
    for i = 1, #results do
        if results[i][4] > expires then
            expires = results[i][4]
            duration = results[i][3]
        end
    end
    if expires > 0 then
        local pre = (expires - GetTime()) / duration
        AddToAnimation("DECAY_BAR", pre, 0, GetTime(), expires - GetTime(), decay_OnAnim, "noease")
    end
end
GW.AddForProfiling("classpowers", "powerSBlock", powerSBlock)

local function setWarrior(f)
    local selected

    if GW.myspec == 2 or GW.myspec == 3 then
        f.background:SetTexture(nil)
        f.fill:SetTexture(nil)
        local fd = f.decay
        fd.bar:SetStatusBarColor(0.45, 0.55, 0.60)
        fd.bar.texture1:SetVertexColor(1, 1, 1, 0)
        fd.bar.texture2:SetVertexColor(1, 1, 1, 0)
        fd.bar:SetValue(0)
        fd:Show()

        if GW.myspec == 2 then -- fury
            f:SetScript("OnEvent", powerEnrage)
            powerEnrage(f, "CLASS_POWER_INIT")
        elseif GW.myspec == 3 then -- prot
            -- determine if bolster talent is selected
            _, _, _, selected, _ = GetTalentInfo(4, 3, 1, false, "player")
            f.gw_BolsterSelected = selected
            f:SetScript("OnEvent", powerSBlock)
            powerSBlock(f, "CLASS_POWER_INIT")
        end
        f:RegisterUnitEvent("UNIT_AURA", "player")

        return true
    end

    return false
end
GW.AddForProfiling("classpowers", "setWarrior", setWarrior)

-- PALADIN
local function powerSotR(self, event, ...)
    local results = findBuffs("player", 132403, 31850, 212641)
    if results == nil then
        return
    end
    local duration = -1
    local expires = -1
    for i = 1, #results do
        if results[i][4] > expires then
            expires = results[i][4]
            duration = results[i][3]
        end
    end
    if expires > 0 then
        local pre = (expires - GetTime()) / duration
        AddToAnimation("DECAY_BAR", pre, 0, GetTime(), expires - GetTime(), decay_OnAnim, "noease")
    end
end
GW.AddForProfiling("classpowers", "powerSotR", powerSotR)

local function powerHoly(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "HOLY_POWER" then
        return
    end

    local old_power = self.gwPower
    old_power = old_power or -1

    local pwrMax = UnitPowerMax("player", 9)
    local pwr = UnitPower("player", 9)
    local p = pwr - 1

    self.gwPower = pwr

    self.background:SetTexCoord(0, 1, 0.125 * pwrMax, 0.125 * (pwrMax + 1))
    self.fill:SetTexCoord(0, 1, 0.125 * p, 0.125 * (p + 1))

    if old_power < pwr and event ~= "CLASS_POWER_INIT" then
        animFlare(self)
    end
end
GW.AddForProfiling("classpowers", "powerHoly", powerHoly)

local function setPaladin(f)
    if GW.myspec == 2 then -- prot
        f.background:SetTexture(nil)
        f.fill:SetTexture(nil)
        local fd = f.decay
        fd.bar:SetStatusBarColor(0.85, 0.65, 0)
        fd.bar.texture1:SetVertexColor(1, 1, 1, 0)
        fd.bar.texture2:SetVertexColor(1, 1, 1, 0)
        fd.bar:SetValue(0)
        fd:Show()

        f:SetScript("OnEvent", powerSotR)
        powerSotR(f, "CLASS_POWER_INIT")
        f:RegisterUnitEvent("UNIT_AURA", "player")

        return true
    elseif GW.myspec == 3 then -- retribution
        f:SetHeight(32)
        f:SetWidth(320)
        f.background:SetHeight(32)
        f.background:SetWidth(320)
        f.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\holypower")
        f.background:SetTexCoord(0, 1, 0.5, 1)
        f.fill:SetHeight(32)
        f.fill:SetWidth(320)
        f.fill:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\holypower")

        f:SetScript("OnEvent", powerHoly)
        powerHoly(f, "CLASS_POWER_INIT")
        f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
        f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

        return true
    end

    return false
end
GW.AddForProfiling("classpowers", "setPaladin", setPaladin)

-- HUNTER
local function powerFrenzy(self, event, ...)
    local fdc = self.decayCounter
    local _, count, duration, expires = findBuff("pet", 272790)

    if duration == nil then
        fdc.count:SetText(0)
        self.gwPower = -1
        return
    end

    fdc.count:SetText(count)
    local old_expires = self.gwPower
    old_expires = old_expires or -1
    self.gwPower = expires
    if event == "CLASS_POWER_INIT" or expires > old_expires then
        local pre = (expires - GetTime()) / duration
        AddToAnimation("DECAYCOUNTER_BAR", pre, 0, GetTime(), expires - GetTime(), decayCounter_OnAnim, "noease")
        if event ~= "CLASS_POWER_INIT" then
            AddToAnimation("DECAYCOUNTER_TEXT", 1, 0, GetTime(), 0.5, decayCounterFlash_OnAnim)
        end
    end
end
GW.AddForProfiling("classpowers", "powerFrenzy", powerFrenzy)

local function powerMongoose(self, event, ...)
    local fdc = self.decayCounter
    local _, count, duration, expires = findBuff("player", 259388)

    if duration == nil then
        fdc.count:SetText(0)
        self.gwPower = -1
        return
    end

    fdc.count:SetText(count)
    local old_count = self.gwPower
    old_count = old_count or -1
    self.gwPower = count
    if event == "CLASS_POWER_INIT" or count > old_count then
        local pre = (expires - GetTime()) / duration
        AddToAnimation("DECAYCOUNTER_BAR", pre, 0, GetTime(), expires - GetTime(), decayCounter_OnAnim, "noease")
        if event ~= "CLASS_POWER_INIT" then
            AddToAnimation("DECAYCOUNTER_TEXT", 1, 0, GetTime(), 0.5, decayCounterFlash_OnAnim)
        end
    end
end
GW.AddForProfiling("classpowers", "powerMongoose", powerMongoose)

local function setHunter(f)
    local selected = false
    if GW.myspec == 3 then
        -- determine if mongoose talent is selected for survival
        _, _, _, selected, _ = GetTalentInfo(6, 2, 1, false, "player")
    end

    if GW.myspec == 1 or (GW.myspec == 3 and selected) then
        f.background:SetTexture(nil)
        f.fill:SetTexture(nil)
        local fdc = f.decayCounter
        fdc.bar.texture1:SetVertexColor(1, 1, 1, 0)
        fdc.bar.texture2:SetVertexColor(1, 1, 1, 0)
        fdc.bar:SetValue(0)
        fdc:Show()

        if GW.myspec == 1 then -- beast mastery
            f:SetScript("OnEvent", powerFrenzy)
            powerFrenzy(f, "CLASS_POWER_INIT")
            f:RegisterUnitEvent("UNIT_AURA", "pet")
        elseif GW.myspec == 3 then -- survival
            f:SetScript("OnEvent", powerMongoose)
            powerMongoose(f, "CLASS_POWER_INIT")
            f:RegisterUnitEvent("UNIT_AURA", "player")
        end

        return true
    end

    return false
end
GW.AddForProfiling("classpowers", "setHunter", setHunter)

-- ROGUE
local function setRogue(f)
    setComboBar(f)
    return true
end
GW.AddForProfiling("classpowers", "setRogue", setRogue)

-- PRIEST
local function setPriest(f)
    if GW.myspec == 3 then -- shadow
        setManaBar(f)
        return true
    end

    return false
end
GW.AddForProfiling("classpowers", "setPriest", setPriest)

-- DEATH KNIGHT
local RUNE_TIMER_ANIMATIONS = {}
RUNE_TIMER_ANIMATIONS[1] = 0
RUNE_TIMER_ANIMATIONS[2] = 0
RUNE_TIMER_ANIMATIONS[3] = 0
RUNE_TIMER_ANIMATIONS[4] = 0
RUNE_TIMER_ANIMATIONS[5] = 0
RUNE_TIMER_ANIMATIONS[6] = 0
local function powerRune(self, event, ...)
    local f = self
    local fr = self.runeBar
    for i = 1, 6 do
        local rune_start, rune_duration, rune_ready = GetRuneCooldown(i)
        if rune_start == nil then
            rune_start = GetTime()
            rune_duration = 0
        end
        local fFill = fr["runeTexFill" .. i]
        local fTex = fr["runeTex" .. i]
        local animId = "RUNE_TIMER_ANIMATIONS" .. i
        if rune_ready and fFill then
            fFill:SetTexCoord(0.5, 1, 0, 1)
            fFill:SetHeight(32)
            fFill:SetVertexColor(1, 1, 1)
            if animations[animId] then
                animations[animId]["completed"] = true
                animations[animId]["duration"] = 0
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
                    fFill:SetTexCoord(0.5, 1, 1 - animations[animId]["progress"], 1)
                    fFill:SetHeight(32 * animations[animId]["progress"])
                    fFill:SetVertexColor(1, 0.6 * animations[animId]["progress"], 0.6 * animations[animId]["progress"])
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
                            f.flare:SetAlpha(animations["HOLY_POWER_FLARE_ANIMATION"]["progress"])
                        end
                    )
                end
            )
            RUNE_TIMER_ANIMATIONS[i] = 0
        end
        fTex:SetTexCoord(0, 0.5, 0, 1)
    end
end
GW.AddForProfiling("classpowers", "powerRune", powerRune)

local function setDeathKnight(f)
    local fr = f.runeBar
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f.flare:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\runeflash")
    f.flare:SetWidth(256)
    f.flare:SetHeight(128)
    fr:Show()

    local texture = "runes-blood"
    if GW.myspec == 2 then -- frost
        texture = "runes"
    elseif GW.myspec == 3 then -- unholy
        texture = "runes-unholy"
    end

    for i = 1, 6 do
        local fFill = fr["runeTexFill" .. i]
        local fTex = fr["runeTex" .. i]
        fFill:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\" .. texture)
        fTex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\" .. texture)
    end

    f:SetScript("OnEvent", powerRune)
    powerRune(f, "CLASS_POWER_INIT")
    f:RegisterEvent("RUNE_POWER_UPDATE")

    return true
end
GW.AddForProfiling("classpowers", "setDeathKnight", setDeathKnight)

-- SHAMAN
local function setShaman(f)
    if GW.myspec == 1 or GW.myspec == 2 then
        -- ele and enh both use extra mana bar on left
        setManaBar(f)
        return true
    end

    return false
end
GW.AddForProfiling("classpowers", "setShaman", setShaman)

-- MAGE
local function powerArcane(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "ARCANE_CHARGES" then
        return
    end

    local old_power = self.gwPower
    old_power = old_power or -1

    local pwr = UnitPower("player", 16)
    local p = pwr - 1

    self.gwPower = pwr

    self.background:SetTexCoord(0, 1, 0.125 * 3, 0.125 * (3 + 1))
    self.fill:SetTexCoord(0, 1, 0.125 * p, 0.125 * (p + 1))

    if old_power < pwr and event ~= "CLASS_POWER_INIT" then
        animFlare(self, 64, -32, 2, true)
    end
end
GW.AddForProfiling("classpowers", "powerArcane", powerArcane)

local function powerFrost(self, event, ...)
    local _, count, duration, expires = findBuff("player", 205473)

    if not count then count = 0 end

    local old power = self.gwPower
    old_power = old_power or -1

    local p = count

    self.gwPower = count
    self.background:SetTexCoord(0, 1, 0.125 * 5, 0.125 *( 5+ 1))
    self.fill:SetTexCoord(0, 1, 0.125 * p, 0.125 * (p + 1))

    if old_power < count and count > 0 and event ~= "CLASS_POWER_INIT" then
        animFlare(self, 32, -16, 2, true)
    end
end

local function setMage(f)
    if GW.myspec == 1 then -- arcane
        if GetSetting("XPBAR_ENABLED") then
            f:SetPoint('BOTTOMLEFT', UIParent, "BOTTOM", -372, 66)
        else
            f:SetPoint('BOTTOMLEFT', UIParent, "BOTTOM", -372, 52)
        end
        f:SetHeight(64)
        f:SetWidth(512)
        f.background:SetHeight(64)
        f.background:SetWidth(512)
        f.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\arcane")
        f.background:SetTexCoord(0, 1, 0.125 * 3, 0.125 * (3 + 1))
        f.flare:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\arcane-flash")
        f.flare:SetWidth(256)
        f.flare:SetHeight(256)
        f.fill:SetHeight(64)
        f.fill:SetWidth(512)
        f.fill:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\arcane")
        f.background:SetVertexColor(0, 0, 0, 0.5)

        f:SetScript("OnEvent", powerArcane)
        powerArcane(f, "CLASS_POWER_INIT")
        f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
        f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

        return true
    elseif GW.myspec == 3 then --frost
        f:SetHeight(32)
        f:SetWidth(256)
        f.background:SetHeight(32)
        f.background:SetWidth(256)
        f.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\frostmage-altpower")
        f.background:SetTexCoord(0, 1, 0.125 * 5, 0.125 * (5 + 1))
        f.flare:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\arcane-flash")
        f.flare:SetWidth(128)
        f.flare:SetHeight(128)
        f.fill:SetHeight(32)
        f.fill:SetWidth(256)
        f.fill:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\frostmage-altpower")
        f.background:SetVertexColor(0, 0, 0, 0.5)

        f:SetScript("OnEvent", powerFrost)
        powerFrost(f, "CLASS_POWER_INIT")
        f:RegisterUnitEvent("UNIT_AURA", "player")

        return true
    end

    return false
end
GW.AddForProfiling("classpowers", "setMage", setMage)

-- WARLOCK
local function powerSoulshard(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "SOUL_SHARDS" then
        return
    end

    local pwrMax = UnitPowerMax("player", 7)
    local pwr = UnitPower("player", 7)

    self.background:SetTexCoord(0, 1, 0.125 * pwrMax, 0.125 * (pwrMax + 1))
    self.fill:SetTexCoord(0, 1, 0.125 * pwr, 0.125 * (pwr + 1))
end
GW.AddForProfiling("classpowers", "powerSoulshard", powerSoulshard)

local function setWarlock(f)
    f:SetHeight(32)
    f:SetWidth(256)
    f.background:SetHeight(32)
    f.background:SetWidth(128)
    f.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\shadoworbs-bg")
    f.fill:SetHeight(32)
    f.fill:SetWidth(256)
    f.fill:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\shadoworbs")

    f:SetScript("OnEvent", powerSoulshard)
    powerSoulshard(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

    return true
end
GW.AddForProfiling("classpowers", "setWarlock", setWarlock)

-- MONK
local function powerChi(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "CHI" then
        return
    end

    local old_power = self.gwPower
    old_power = old_power or -1

    local pwrMax = UnitPowerMax("player", 12)
    local pwr = UnitPower("player", 12)
    local p = pwr - 1

    self.gwPower = pwr

    self.background:SetTexCoord(0, 1, 0.125 * (pwrMax + 1), 0.125 * (pwrMax + 2))
    self.fill:SetTexCoord(0, 1, 0.125 * p, 0.125 * (p + 1))

    if old_power < pwr and event ~= "CLASS_POWER_INIT" then
        animFlare(self)
    end
end
GW.AddForProfiling("classpowers", "powerChi", powerChi)

local function loopStagger()
    local f = CPWR_FRAME
    local fb = f.brewmaster
    local staggerAmountClamped = math.min(1, fb.debugpre)

    if fb.debugpre == 0 then
        fb.stagger.blue:Hide()
        fb.stagger.yellow:Hide()
        fb.stagger.red:Hide()
        fb.stagger.indicator:Hide()
        fb.stagger.indicatorText:Hide()
    elseif not fb.stagger.blue:IsShown() then
        fb.stagger.blue:Show()
        fb.stagger.yellow:Show()
        fb.stagger.red:Show()
        fb.stagger.indicator:Show()
        fb.stagger.indicatorText:Show()
    end

    fb.stagger.blue:SetVertexColor(1, 1, 1, 1)
    fb.stagger.yellow:SetVertexColor(1, 1, 1, lerp(0, 1, staggerAmountClamped / 0.5))
    fb.stagger.red:SetVertexColor(1, 1, 1, lerp(0, 1, (staggerAmountClamped - 0.5) / 0.5))

    fb.stagger.blue:SetTexCoord(0, staggerAmountClamped, 0, 1)
    fb.stagger.yellow:SetTexCoord(0, staggerAmountClamped, 0, 1)
    fb.stagger.red:SetTexCoord(0, staggerAmountClamped, 0, 1)

    fb.stagger.blue:SetWidth(staggerAmountClamped * 256)
    fb.stagger.yellow:SetWidth(staggerAmountClamped * 256)
    fb.stagger.red:SetWidth(staggerAmountClamped * 256)

    fb.stagger.indicator:SetPoint("LEFT", (staggerAmountClamped * 256) - 13, -6)
    fb.stagger.indicatorText:SetText(math.floor(fb.debugpre * 100) .. "%")
end
GW.AddForProfiling("classpowers", "loopStagger", loopStagger)

local function ironSkin_OnUpdate()
    local f = CPWR_FRAME
    local fb = f.brewmaster
    local precentage = math.min(1, math.max(0, (fb.ironskin.expires - GetTime()) / 23))
    fb.stagger.ironartwork:SetAlpha(precentage)
    fb.ironskin.fill:SetTexCoord(0, precentage, 0, 1)
    fb.ironskin.fill:SetWidth(precentage * 256)

    fb.ironskin.indicator:SetPoint("LEFT", math.min(252, (precentage * 256)) - 13, 19)
    fb.ironskin.indicatorText:SetText(RoundInt(fb.ironskin.expires - GetTime()) .. "s")
end
GW.AddForProfiling("classpowers", "ironSkin_OnUpdate", ironSkin_OnUpdate)

local function powerStagger(self, event, ...)
    local unit = select(1, ...)
    local fb = self.brewmaster
    if event == nil then
        fb.debugpre = 0
        loopStagger()
        fb.ironskin:Hide()
        fb.stagger.ironartwork:Hide()
    end

    if unit == "player" and event == "UNIT_AURA" then
        local _, _, _, expires = findBuff("player", 215479)
        if expires ~= nil then
            fb.ironskin.expires = expires
            fb.ironskin:SetScript("OnUpdate", ironSkin_OnUpdate)
            fb.ironskin:Show()
            fb.stagger.ironartwork:Show()
        else
            fb.ironskin:SetScript("OnUpdate", nil)
            fb.ironskin:Hide()
            fb.stagger.ironartwork:Hide()
        end
        return
    end

    local pwrMax = UnitHealthMax("player")
    local pwr = UnitStagger("player")
    --   CLASS_POWER =  168000
    local staggarPrec = pwr / pwrMax

    staggarPrec = math.max(0, math.min(staggarPrec, 1))

    fb.debugpre = staggarPrec
    loopStagger()
end
GW.AddForProfiling("classpowers", "powerStagger", powerStagger)

local function setMonk(f)
    if GW.myspec == 1 then -- brewmaster
        f.brewmaster:Show()
        f.staggerBar.loopValue = 0
        f.background:SetTexture(nil)
        f.fill:SetTexture(nil)

        f:SetScript("OnEvent", powerStagger)
        powerStagger(f, "CLASS_POWER_INIT")
        f:RegisterUnitEvent("UNIT_AURA", "player")
        f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
        f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

        return true
    elseif GW.myspec == 3 then -- ww
        f:SetHeight(32)
        f:SetWidth(256)
        f.background:SetHeight(32)
        f.background:SetWidth(320)
        f.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\chi")
        f.background:SetTexCoord(0, 1, 0.5, 1)
        f.flare:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\chi-flare")
        f.fill:SetHeight(32)
        f.fill:SetWidth(256)
        f.fill:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\chi")

        f:SetScript("OnEvent", powerChi)
        powerChi(f, "CLASS_POWER_INIT")
        f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
        f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

        return true
    end

    return false
end
GW.AddForProfiling("classpowers", "setMonk", setMonk)

-- DRUID
local function setDruid(f)
    local form = f.gwPlayerForm

    -- determine affinity talent
    local aff1, aff2, aff3
    _, _, _, aff1, _ = GetTalentInfo(3, 1, 1, false, "player")
    _, _, _, aff2, _ = GetTalentInfo(3, 2, 1, false, "player")
    _, _, _, aff3, _ = GetTalentInfo(3, 3, 1, false, "player")

    local barType = "none"
    if GW.myspec == 1 then -- balance
        if form == 1 and aff1 then
            -- if in cat form with feral affinity, show combo points
            barType = "combo"
        elseif form ~= 4 and form ~= 29 and form ~= 27 and form ~= 3 then
            -- show mana bar by default except in travel forms
            barType = "mana"
        end
    elseif GW.myspec == 2 then -- feral
        if form == 1 then
            -- show combo points and little mana bar in cat form
            barType = "combo|little_mana"
        elseif form == 5 then
            -- show mana bar in bear form
            barType = "mana"
        end
    elseif GW.myspec == 3 then -- guardian
        if form == 1 then
            if aff2 then
                -- show combo points in cat form with feral affinity
                barType = "combo"
            else
                -- show mana in cat form without affinity
                barType = "mana"
            end
        elseif form == 5 then
            -- show mana in bear form
            barType = "mana"
        end
    elseif GW.myspec == 4 then -- resto
        if form == 1 then
            if aff2 then
                -- show combo points in cat form with feral affinity
                barType = "combo"
            else
                -- show mana in cat form without affinity
                barType = "mana"
            end
        elseif form == 5 then
            -- show mana in bear form
            barType = "mana"
        end
    end

    if barType == "combo" then
        setComboBar(f)
        return true
    elseif barType == "mana" then
        setManaBar(f)
        return true
    elseif barType == "combo|little_mana" then
        setComboBar(f)
        if f.ourPowerBar then
            setLittleManaBar(f)
        end
        return true
    else
        return false
    end
end
GW.AddForProfiling("classpowers", "setDruid", setDruid)

local function selectType(f)
    f:SetScript("OnEvent", nil)
    f:UnregisterAllEvents()

    -- hide all class power sub-pieces and reset anything needed
    f.runeBar:Hide()
    f.decayCounter:Hide()
    f.brewmaster:Hide()
    f.staggerBar:Hide()
    f.disc:Hide()
    f.decay:Hide()
    f.exbar:Hide()
    if f.ourPowerBar then
        f.lmb:Hide()
    end
    f.gwPower = -1
    local showBar = false

    if GW.myClassID == 1 then
        showBar = setWarrior(f)
    elseif GW.myClassID == 2 then
        showBar = setPaladin(f)
    elseif GW.myClassID == 3 then
        showBar = setHunter(f)
    elseif GW.myClassID == 4 then
        showBar = setRogue(f)
    elseif GW.myClassID == 5 then
        showBar = setPriest(f)
    elseif GW.myClassID == 6 then
        showBar = setDeathKnight(f)
    elseif GW.myClassID == 7 then
        showBar = setShaman(f)
    elseif GW.myClassID == 8 then
        showBar = setMage(f)
    elseif GW.myClassID == 9 then
        showBar = setWarlock(f)
    elseif GW.myClassID == 10 then
        showBar = setMonk(f)
    elseif GW.myClassID == 11 then
        showBar = setDruid(f)
    end

    if showBar then
        f:Show()
    else
        f:Hide()
    end
end
GW.AddForProfiling("classpowers", "selectType", selectType)

local function barChange_OnEvent(self, event, ...)
    local f = self:GetParent()
    if event == "UPDATE_SHAPESHIFT_FORM" then
        -- this event fires often when form hasn't changed; check old form against current form
        -- to prevent touching the bar unnecessarily (which causes annoying anim flickering)
        local s = GetShapeshiftFormID()
        if f.gwPlayerForm == s then
            return
        end
        f.gwPlayerForm = s
        selectType(f)
    elseif event == "PLAYER_TARGET_CHANGED" then
        if UnitExists("target") and UnitCanAttack("player", "target") and f.barType == "combo" and not UnitIsDead("target") then
            f:Show()
        elseif f.barType == "combo" then
            f:Hide()
        end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        f.gwPlayerForm = GetShapeshiftFormID()
        GW.CheckRole()
        selectType(f)
    end
end

local function LoadClassPowers()
    local cpf = CreateFrame("Frame", "GwPlayerClassPower", UIParent, "GwPlayerClassPower")
    GW.RegisterScaleFrame(cpf)
    if GW.GetSetting("XPBAR_ENABLED") then
        cpf:SetPoint('BOTTOMLEFT', UIParent, "BOTTOM", -372, 81)
    else
        cpf:SetPoint('BOTTOMLEFT', UIParent, "BOTTOM", -372, 67)
    end
    GW.MixinHideDuringPetAndOverride(cpf)
    CPWR_FRAME = cpf

    cpf.ourTarget = GetSetting("TARGET_ENABLED")
    cpf.comboPointsOnTarget = GetSetting("target_HOOK_COMBOPOINTS")
    cpf.ourPowerBar = GetSetting("POWERBAR_ENABLED")

    -- create an extra mana power bar that is used sometimes (feral druid in cat form) only if your Powerbar is on
    if cpf.ourPowerBar then
        local lmb = CreateFrame("Frame", nil, GwPlayerPowerBar, "GwPlayerPowerBar")
        GW.MixinHideDuringPetAndOverride(lmb)
        cpf.lmb = lmb
        lmb.candy.spark:ClearAllPoints()
        lmb:SetSize(GwPlayerPowerBar:GetWidth(), 5)
        lmb.bar:SetHeight(5)
        lmb.candy:SetHeight(5)
        lmb.candy.spark:SetHeight(5)
        lmb.statusBar:SetHeight(5)
        lmb:ClearAllPoints()
        lmb:SetPoint("TOPLEFT", "GwPlayerPowerBar", "TOPLEFT", 0, 5)
        lmb:SetFrameStrata("MEDIUM")
        lmb.statusBar.label:SetFont(DAMAGE_TEXT_FONT, 8)
    end

    -- create an extra mana power bar that is used sometimes
    local exbar = CreateFrame("Frame", nil, cpf, "GwPlayerPowerBar")
    GW.MixinHideDuringPetAndOverride(exbar)
    cpf.exbar = exbar
    exbar.candy.spark:ClearAllPoints()
    exbar:ClearAllPoints()
    exbar:SetPoint("BOTTOMLEFT", cpf, "BOTTOMLEFT", 0, 5)
    exbar:SetFrameStrata("MEDIUM")
    exbar.statusBar.label:SetFont(DAMAGE_TEXT_FONT, 14)

    -- set a bunch of other init styling stuff
    cpf.decayCounter.count:SetFont(DAMAGE_TEXT_FONT, 24, "OUTLINED")
    cpf.brewmaster.debugpre = 0
    cpf.brewmaster.stagger.indicatorText:SetFont(UNIT_NAME_FONT, 11)
    cpf.brewmaster.ironskin.indicatorText:SetFont(UNIT_NAME_FONT, 11)
    cpf.brewmaster.ironskin.expires = 0
    cpf.staggerBar.value = 0
    cpf.staggerBar.spark = cpf.staggerBar.bar.spark
    cpf.staggerBar.texture1 = cpf.staggerBar.bar.texture1
    cpf.staggerBar.texture2 = cpf.staggerBar.bar.texture2
    cpf.staggerBar.fill = cpf.staggerBar.bar.fill
    cpf.staggerBar.fill:SetVertexColor(59 / 255, 173 / 255, 231 / 255)
    cpf.disc.bar.overlay:SetModel(1372783)
    cpf.disc.bar.overlay:SetPosition(0, 0, 2)
    cpf.disc.bar.overlay:SetPosition(0, 0, 0)

    cpf.decay:SetScript("OnEvent", barChange_OnEvent)
    cpf.decay:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    cpf.decay:RegisterEvent("PLAYER_ENTERING_WORLD")
    cpf.decay:RegisterEvent("CHARACTER_POINTS_CHANGED")
    cpf.decay:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

    cpf.gwPlayerForm = GetShapeshiftFormID()

    selectType(cpf)

    if (GW.myClassID == 4 or GW.myClassID == 11) and (cpf.ourTarget and cpf.comboPointsOnTarget) then
        cpf.decay:RegisterEvent("PLAYER_TARGET_CHANGED")
        if cpf.barType == "combo" then
            cpf:Hide()
        end
    end
    
end
GW.LoadClassPowers = LoadClassPowers
