local _, GW = ...
local lerp = GW.lerp
local RoundInt = GW.RoundInt
local animations = GW.animations

local CPWR_FRAME

local playerAuras = {buffs = {}, debuffs = {}}
local petAuras = {buffs = {}, debuffs = {}}

local function HandleUnitAuraEvent(unit, ...)
    local auraUpdateInfo = ...
    local isFullUpdate = not auraUpdateInfo or auraUpdateInfo.isFullUpdate
    local buffsChanged = false
    local debuffsChanged = false
    local dataTable = unit == "pet" and petAuras or unit == "player" and playerAuras or nil
    if not dataTable then return end

    if isFullUpdate then
        table.wipe(dataTable.buffs)
        table.wipe(dataTable.debuffs)
        local slots = {C_UnitAuras.GetAuraSlots(unit, "HELPFUL")}
        for i = 2, #slots do -- #1 return is continuationToken, we don't care about it
            local data = C_UnitAuras.GetAuraDataBySlot(unit, slots[i])

            if data and data.name then
                dataTable.buffs[data.auraInstanceID] = data
            end
        end

        slots = {C_UnitAuras.GetAuraSlots(unit, "HARMFUL")}
        for i = 2, #slots do -- #1 return is continuationToken, we don't care about it
            local data = C_UnitAuras.GetAuraDataBySlot(unit, slots[i])

            if data and data.name then
                dataTable.debuffs[data.auraInstanceID] = data
            end
        end
    else
        if auraUpdateInfo.addedAuras then
            for _, data in next, auraUpdateInfo.addedAuras do
                if (data.isHelpful and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, "HELPFUL")) then
                    if data and data.name then
                        dataTable.buffs[data.auraInstanceID] = data
                        buffsChanged = true
                    end
                elseif (data.isHarmful and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, "HARMFUL")) then
                    if data and data.name then
                        dataTable.debuffs[data.auraInstanceID] = data
                        debuffsChanged = true
                    end
                end
            end
        end

        if auraUpdateInfo.updatedAuraInstanceIDs then
            for _, auraInstanceID in next, auraUpdateInfo.updatedAuraInstanceIDs do
                if(dataTable.buffs[auraInstanceID]) then
                    dataTable.buffs[auraInstanceID] = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
                    buffsChanged = true
                elseif(dataTable.debuffs[auraInstanceID]) then
                    dataTable.debuffs[auraInstanceID] = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
                    debuffsChanged = true
                end
            end
        end

        if auraUpdateInfo.removedAuraInstanceIDs then
            for _, auraInstanceID in next, auraUpdateInfo.removedAuraInstanceIDs do
                if(dataTable.buffs[auraInstanceID]) then
                    dataTable.buffs[auraInstanceID] = nil
                    buffsChanged = true
                elseif(dataTable.debuffs[auraInstanceID]) then
                    dataTable.debuffs[auraInstanceID] = nil
                    debuffsChanged = true
                end
            end
        end
    end

    if buffsChanged or debuffsChanged or isFullUpdate then
        EventRegistry:TriggerEvent("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", unit, dataTable)
    end
end

local function UpdateVisibility(self, inCombat)
    local shouldBeVisible = self.shouldShowBar and (not self.onlyShowInCombat or inCombat)
    local targetAlpha = shouldBeVisible and 1 or 0
    for _, frame in ipairs({
        self,
        self.customResourceBar,
        self.customResourceBar.decay,
        self.lmb,
        self.lmb.decay,
        self.exbar,
        self.exbar.decay,
    }) do
        if frame then
            GW.SetAlphaRecursive(frame, targetAlpha)
        end
    end
end

local function updateVisibilitySetting(self, updateVis)
    self.onlyShowInCombat = GW.settings.CLASSPOWER_ONLY_SHOW_IN_COMBAT
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

local function AnimationStagger(self)
    local fill = self:GetFillAmount()

    local yellow = lerp(0, 1, fill / 0.5)
    local red = lerp(0, 1, (fill - 0.5) / 0.5)
    self.intensity:SetAlpha(yellow)
    self.intensity2:SetAlpha(red)

    self.scrollTexture:SetAlpha(lerp(0, 1, (fill - 0.5) / 0.5))
    self.scrollTexture2:SetAlpha(lerp(0, 1, (fill - 0.5) / 0.5))
    self.scrollSpeedMultiplier = lerp(-1, -10, fill)
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
local function setPowerTypeEbonMight(self)
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/agu")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/agu-intensity", "REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/agu-intensity2", "REPEAT")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/furyspark")
    self.animator:SetScript("OnUpdate", function(_, delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(1)
    self.scrollTexture2:SetAlpha(1)
    self.scrollTexture:SetBlendMode("ADD")

    self.spark:SetAlpha(1)
    self.scrollSpeedMultiplier = -5
end
local function setPowerTypeMeta(self)
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/fury")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/meta-intensity", "REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/meta-intensity2", "REPEAT")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/furyspark")
    self.animator:SetScript("OnUpdate", function(_, delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(1)
    self.scrollTexture2:SetAlpha(1)
    self.spark:SetAlpha(0.5)
    self.scrollSpeedMultiplier = 5
    -- self.onUpdateAnimation = AnimationFury
end
local function setPowerTypeStagger(self)
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll", "REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll2", "REPEAT")
    self.intensity:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-intensity")
    self.intensity2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-intensity2")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/furyspark")
    self.animator:SetScript("OnUpdate", function(_, delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(0)
    self.scrollTexture2:SetAlpha(0)
    self.spark:SetAlpha(0.5)
    self.scrollSpeedMultiplier = -1
    self.onUpdateAnimation = AnimationStagger
end

local function setPowerTypeEnrage(self)
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/rage")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/enrage-intensity", "REPEAT", "REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/enrage-intensity2", "REPEAT", "REPEAT")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/furyspark")
    self.animator:SetScript("OnUpdate", function(_, delta) self:ScrollTextureVerticalParalaxOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(0.5)
    self.scrollTexture2:SetAlpha(0.5)
    self.scrollTexture:SetBlendMode("ADD")
    self.scrollTexture2:SetBlendMode("ADD")
    -- self.scrollTexture2:SetAlpha(1)
    self.spark:SetAlpha(0.5)
    self.scrollSpeedMultiplier = 5
end
local function setPowerTYpeBolster(self)
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/bloster")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/spark")
    self.runeoverlay:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/bloster-intensity")
    self.runeoverlay:SetAlpha(1)
    self.spark:SetBlendMode("ADD")
    self.spark:SetAlpha(0.3)
    self.customMaskSize = 30
end
local function setPowerTYpeFrenzy(self)
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/frenzy")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/frenzyspark")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll", "REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll2", "REPEAT")
    self.animator:SetScript("OnUpdate", function(_, delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollSpeedMultiplier = -3
    self.scrollTexture:SetAlpha(1)
    self.scrollTexture2:SetAlpha(1)
    self.spark:SetAlpha(0.3)
    self:SetWidth(262)
    self.customMaskSize = 128
end
local function setPowerTypeRend(self)
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/frenzy")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/frenzyspark")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll", "REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll2", "REPEAT")
    self.animator:SetScript("OnUpdate", function(_, delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollSpeedMultiplier = -3
    self.scrollTexture:SetAlpha(1)
    self.scrollTexture2:SetAlpha(1)
    self.spark:SetAlpha(0.3)

    self.customMaskSize = 128
end

local function updateTextureBasedOnCondition(self)
    if GW.myClassID == 9 then           -- Warlock
        -- Hook green fire
        if GW.IsSpellKnown(101508) then -- check for spell id 101508
            self.warlock.shardFlare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/soulshardFlare-green")
            self.warlock.shardFragment.barFill:SetTexture(
                "Interface/AddOns/GW2_UI/textures/altpower/soulshardFragmentBarFill-green")
            for i = 1, 5 do
                self.warlock["shard" .. i]:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/soulshard-green")
            end
        else
            local textureShardFlare = self.useRedTexture and
                "Interface/AddOns/GW2_UI/textures/altpower/soulshardFlare-red" or
                "Interface/AddOns/GW2_UI/textures/altpower/soulshardFlare"
            local textureShardFragmentFill = self.useRedTexture and
                "Interface/AddOns/GW2_UI/textures/altpower/soulshardFragmentBarFill-red" or
                "Interface/AddOns/GW2_UI/textures/altpower/soulshardFragmentBarFill"
            local textureShardShard = self.useRedTexture and "Interface/AddOns/GW2_UI/textures/altpower/soulshard-red" or
                "Interface/AddOns/GW2_UI/textures/altpower/soulshard"

            self.warlock.shardFlare:SetTexture(textureShardFlare)
            self.warlock.shardFragment.barFill:SetTexture(textureShardFragmentFill)
            for i = 1, 5 do
                self.warlock["shard" .. i]:SetTexture(textureShardShard)
            end
        end
    end
end

local function animFlarePoint(f, point, duration)
    local ff = f.flare
    ff:ClearAllPoints()
    ff:SetPoint("CENTER", point, "CENTER", 0, 0)
    GW.AddToAnimation(
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

local function animFlare(f, scale, offset, duration, rotate)
    scale = scale or 32
    offset = offset or 0
    duration = duration or 0.5
    rotate = rotate or false
    local ff = f.flare
    local pwr = f.gwPower
    ff:ClearAllPoints()
    ff:SetPoint("CENTER", f, "LEFT", (scale * pwr) + offset, 0)
    GW.AddToAnimation(
        "POWER_FLARE_ANIM",
        1,
        0,
        GetTime(),
        duration,
        function(p)
            p = math.min(1, math.max(0, p))
            ff:SetAlpha(p)
            if rotate then
                ff:SetRotation(1 * p)
            end
        end
    )
end
GW.AddForProfiling("classpowers", "animFlare", animFlare)

local function decayCounterFlash_OnAnim(p)
    local f = CPWR_FRAME
    local fdc = f.decayCounter
    fdc.flash:SetAlpha(math.min(1, math.max(0, p)))
end
GW.AddForProfiling("classpowers", "decayCounterFlash_OnAnim", decayCounterFlash_OnAnim)

local function GetAuraData(unit, unitSource, filter, ...)
    local searchIDs = {}
    local results = {}
    local multipleIds = select("#", ...) > 1
    for i = 1, select("#", ...) do
        searchIDs[select(i, ...)] = true
    end

    if (unit == "player" or unit == "pet") and filter == "HELPFUL" then
        for _, auraData in pairs((unit == "player" and playerAuras.buffs) or (unit == "pet" and petAuras.buffs) or {}) do
            if searchIDs[auraData.spellId] then
                results[#results + 1] = auraData
            end
        end
    elseif (unit == "player" or unit == "pet") and filter == "HARMFUL" then
        for _, auraData in pairs((unit == "player" and playerAuras.debuffs) or (unit == "pet" and petAuras.debuffs) or {}) do
            if searchIDs[auraData.spellId] then
                results[#results + 1] = auraData
            end
        end
    elseif unitSource and filter == "HARMFUL" then
        for i = 1, 40 do
            local auraData = C_UnitAuras.GetDebuffDataByIndex(unit, i)

            if auraData and (unitSource == auraData.sourceUnit and searchIDs[auraData.spellId]) then
                return auraData
            elseif not auraData then
                break
            end
        end
    end

    if multipleIds then
        return #results > 0 and results or nil
    else
        return #results > 0 and results[1] or nil
    end
end

-- MANA (multi class use)
local function powerMana(self, event, ...)
    local ptype = select(2, ...)
    if event == "CLASS_POWER_INIT" or ptype == "MANA" then
        self.exbar:UpdatePowerData(0, "MANA")

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
GW.AddForProfiling("classpowers", "powerMana", powerMana)

local function powerLittleMana(self, event, ...)
    local ptype = select(2, ...)
    if event == "CLASS_POWER_INIT" or ptype == "MANA" then
        self:GetParent().lmb:UpdatePowerData(0, "MANA")
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
    if GW.settings.XPBAR_ENABLED or f.isMoved then
        f:SetPoint("TOPLEFT", f.gwMover, 0, -13)
    else
        f:SetPoint("TOPLEFT", f.gwMover, 0, -3)
    end

    f:SetScript("OnEvent", powerMana)
    C_Timer.After(0.5, function() powerMana(f, "CLASS_POWER_INIT") end)
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end
GW.AddForProfiling("classpowers", "setManaBar", setManaBar)

local function setLittleManaBar(f, barType)
    f.barType = barType -- used in druid feral form and evoker ebon might bar
    f.lmb:Show()
    f.lmb.decay:Show()

    f.littleManaBarEventFrame:SetScript("OnEvent", powerLittleMana)
    powerLittleMana(f.littleManaBarEventFrame, "CLASS_POWER_INIT")
    f.littleManaBarEventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f.littleManaBarEventFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end
GW.AddForProfiling("classpowers", "setLittleManaBar", setLittleManaBar)

-- COMBO POINTS (multi class use)
local function powerCombo(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "COMBO_POINTS" then
        return
    end

    local pwrMax = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    local pwr = UnitPower("player", Enum.PowerType.ComboPoints)
    local chargedPowerPoints = GetUnitChargedPowerPoints and GetUnitChargedPowerPoints("player") or {}
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
    local showPoint = false
    self.gwPower = pwr

    if pwr > 0 and not self:IsShown() and UnitExists("target") then
        self.combopoints:Show()
    end

    if pwrMax == 6 or pwrMax == 9 then
        self.showExtraPoint = 7
    else
        self.showExtraPoint = pwrMax
    end

    -- hide all not needed ones
    for i = pwrMax + 1, 9 do
        self.combopoints["runeTex" .. i]:Hide()
        self.combopoints["combo" .. i]:Hide()
    end

    for i = 1, self.showExtraPoint do
        local isCharged = chargedPowerPoints and tContains(chargedPowerPoints, i)
        if isCharged then
            self.combopoints["combo" .. i]:SetTexCoord(0, 0.5, 0.5, 1)
        else
            self.combopoints["combo" .. i]:SetTexCoord(0.5, 1, 0.5, 0)
        end

        if i >= self.showExtraPoint and pwr >= self.showExtraPoint then -- only show the extra point if we have it
            showPoint = true
        elseif i >= self.showExtraPoint and pwr < self.showExtraPoint then
            showPoint = false
        elseif i < self.showExtraPoint and pwr >= i then
            showPoint = true
        else
            showPoint = false
        end

        self.combopoints["runeTex" .. i]:SetShown((i < self.showExtraPoint or i <= pwrMax or showPoint))
        self.combopoints["combo" .. i]:SetShown(showPoint)
        self.combopoints.comboFlare:ClearAllPoints()
        self.combopoints.comboFlare:SetPoint("CENTER", self.combopoints["combo" .. i], "CENTER", 0, 0)
        if pwr > old_power then
            self.combopoints.comboFlare:SetShown(showPoint)
            if showPoint then
                GW.AddToAnimation(
                    "COMBOPOINTS_FLARE",
                    0,
                    5,
                    GetTime(),
                    0.5,
                    function(p)
                        p = math.min(1, math.max(0, p))
                        self.combopoints.comboFlare:SetAlpha(p)
                    end,
                    nil,
                    function()
                        self.combopoints.comboFlare:Hide()
                    end
                )
            end
        end
    end
end
GW.AddForProfiling("classpowers", "powerCombo", powerCombo)

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
GW.AddForProfiling("classpowers", "setComboBar", setComboBar)

local function powerEclipsOnUpdate(self)
    local pwrMax = UnitPowerMax(self.unit, Enum.PowerType.Balance)
    local pwr = UnitPower(self.unit, Enum.PowerType.Balance)
    if self.oldEclipsPower == pwr then
        return
    end

    GW.AddToAnimation(
        "ECLIPS_BAR",
        self.oldEclipsPower,
        pwr,
        GetTime(),
        0.2,
        function(p)
            local pwrP = p / pwrMax
            local pwrAbs = math.abs(p) / pwrMax
            local segmentSize = self.eclips:GetWidth() / 2
            local arrowPosition = segmentSize * pwrP

            local clampedArrowPosition = math.max(math.min(arrowPosition, segmentSize - 9), -segmentSize + 9)
            self.eclips.arrow:SetPoint("CENTER", self.background, "CENTER", clampedArrowPosition, 0)
            self.eclips.fill:ClearAllPoints()
            if p > 0 then
                self.eclips.fill:SetPoint("LEFT", self.background, "CENTER", 0, 0)
                self.eclips.fill:SetPoint("RIGHT", self.background, "CENTER", arrowPosition, 0)
                self.eclips.fill:SetTexCoord(0, math.max(0, math.min(pwrAbs, 1)), 0, 1)
            else
                self.eclips.fill:SetPoint("LEFT", self.background, "CENTER", arrowPosition, 0)
                self.eclips.fill:SetPoint("RIGHT", self.background, "CENTER", 0, 0)
                self.eclips.fill:SetTexCoord(0, math.max(0, math.min(pwrAbs, 1)), 0, 1)
            end
            self.oldEclipsPower = p
        end
    )
end

local function eclipsUnitAura()
    local hasLunarEclipse = GetAuraData("player", nil, "HELPFUL", ECLIPSE_BAR_LUNAR_BUFF_ID) ~= nil
    local hasSolarEclipse = GetAuraData("player", nil, "HELPFUL", ECLIPSE_BAR_SOLAR_BUFF_ID) ~= nil
    if hasLunarEclipse then
        CPWR_FRAME.eclips.lunar:Show()
        CPWR_FRAME.eclips.solar:Hide()
    elseif hasSolarEclipse then
        CPWR_FRAME.eclips.lunar:Hide()
        CPWR_FRAME.eclips.solar:Show()
    else
        CPWR_FRAME.eclips.lunar:Hide()
        CPWR_FRAME.eclips.solar:Hide()
    end
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
        HandleUnitAuraEvent(...)
    elseif event == "CLASS_POWER_INIT" then
        eclipsUnitAura()
        powerEclipsOnUpdate(self)
    end
end

local function setEclips(f)
    f.barType = "eclips"
    f.eclips:Show()
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)

    f:SetScript("OnUpdate", powerEclipsOnUpdate)
    f:SetScript("OnEvent", powerEclips)
    powerEclips(f, "CLASS_POWER_INIT")

    f:RegisterUnitEvent("UNIT_AURA", "player")
    f:RegisterEvent("ECLIPSE_DIRECTION_CHANGE")
    EventRegistry:RegisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", eclipsUnitAura, "GW2_UI")
end

-- EVOKER
local FillingAnimationTime = 5.0

local function Essence_OnUpdate(self)
    local peace = GetPowerRegenForPowerType(Enum.PowerType.Essence)
    if (peace == nil or peace == 0) then
        peace = 0.2
    end
    local cooldownDuration = 1 / peace
    local animationSpeedMultiplier = FillingAnimationTime / cooldownDuration
    self.EssenceFilling.FillingAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier)
    self.EssenceFilling.CircleAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier)
end
local function SetEssennceFull(self)
    self.EssenceFilling.FillingAnim:Stop()
    self.EssenceFilling.CircleAnim:Stop()
    self.EssenceFillDone:Show()
    self.EssenceEmpty:Hide()
    self:SetScript("OnUpdate", nil)
end

local function AnimOut(self)
    if (self.EssenceFull:IsShown() or self.EssenceFilling:IsShown() or self.EssenceFillDone:IsShown()) then
        self.EssenceDepleting:Show()
        self.EssenceFilling:Hide()
        self.EssenceEmpty:Hide()
        self.EssenceFillDone:Hide()
        self.EssenceFull:Hide()
        self.EssenceFilling.FillingAnim:Stop()
        self.EssenceFilling.CircleAnim:Stop()
        self:SetScript("OnUpdate", nil)
    end
end

local function AnimIn(self, animationSpeedMultiplier)
    self.EssenceFilling.FillingAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier)
    self.EssenceFilling.CircleAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier)
    self:SetScript("OnUpdate", Essence_OnUpdate)
    self.EssenceFilling:Show()
    self.EssenceDepleting:Hide()
    self.EssenceEmpty:Hide()
    self.EssenceFillDone:Hide()
    self.EssenceFull:Hide()
end

local function powerEssence(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "ESSENCE" then
        return
    end

    local pwrMax = UnitPowerMax("player", Enum.PowerType.Essence)
    local pwr = UnitPower("player", Enum.PowerType.Essence)
    self.gwPower = pwr

    for i = 1, 6 do
        if i <= pwrMax then
            self.evoker["essence" .. i]:Show()
        else
            self.evoker["essence" .. i]:Hide()
        end
    end

    for i = 1, min(pwr, 6) do
        SetEssennceFull(self.evoker["essence" .. i])
    end
    for i = pwr + 1, 6 do
        AnimOut(self.evoker["essence" .. i])
    end

    local isAtMaxPoints = pwr == pwrMax
    local peace = GetPowerRegenForPowerType(Enum.PowerType.Essence)
    if (peace == nil or peace == 0) then
        peace = 0.2
    end
    local cooldownDuration = 1 / peace
    local animationSpeedMultiplier = FillingAnimationTime / cooldownDuration;
    if (not isAtMaxPoints and self.evoker["essence" .. pwr + 1] and not self.evoker["essence" .. pwr + 1].EssenceFull:IsShown()) then
        AnimIn(self.evoker["essence" .. pwr + 1], animationSpeedMultiplier)
    end
end
GW.AddForProfiling("classpowers", "powerEssence", powerEssence)

-- this needs also the essence bar
local function evokerEbonMight()
    local auraInfo = GetAuraData("player", nil, "HELPFUL", 395296)
    local auraExpirationTime = auraInfo and auraInfo.expirationTime or nil

    if auraInfo and auraExpirationTime ~= CPWR_FRAME.auraExpirationTime then
        CPWR_FRAME.auraExpirationTime = auraExpirationTime

        local remainingPrecantage = math.min(1, (auraExpirationTime - GetTime()) / 20) -- hard coded max duration of 20 sec like blizzard
        CPWR_FRAME.customResourceBar:SetCustomAnimation(remainingPrecantage, 0, auraInfo.duration)
    end
end
local function evokerEvent(self, event, ...)
    if event == "UNIT_AURA" then
        HandleUnitAuraEvent(...)
    else
        powerEssence(self, event, ...)
    end
end

local function setEvoker(f)
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", f.gwMover, "TOPLEFT", 0, 0)
    f.barType = "essence"
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f:SetHeight(32)
    f.evoker:Show()

    f:SetScript("OnEvent", evokerEvent)
    powerEssence(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    f:RegisterUnitEvent("UNIT_POWER_POINT_CHARGE", "player")

    if GW.myspec == 3 then
        f.customResourceBar:SetWidth(115)
        f.customResourceBar:ClearAllPoints()
        f.customResourceBar:SetPoint("RIGHT", GwPlayerClassPower.gwMover, 2, 0)
        f.customResourceBar:Show()

        setPowerTypeEbonMight(f.customResourceBar)
        f:RegisterUnitEvent("UNIT_AURA", "player")
        EventRegistry:RegisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", evokerEbonMight, "GW2_UI")
    end
    return true
end

-- DEAMONHUNTER
local function timerMetamorphosis()
    local results = GetAuraData("player", nil, "HELPFUL", 162264, 187827)
    if results == nil then
        CPWR_FRAME.customResourceBar:Hide()
        return
    end

    local duration = -1
    local expires = -1
    for i = 1, #results do
        if results[i].expirationTime > expires then
            expires = results[i].expirationTime
            duration = results[i].duration
        end
    end

    if duration ~= nil then
        CPWR_FRAME.customResourceBar:Show()
        local remainingPrecantage = (expires - GetTime()) / duration
        local remainingTime = duration * remainingPrecantage
        CPWR_FRAME.customResourceBar:SetCustomAnimation(remainingPrecantage, 0, remainingTime)
    else
        CPWR_FRAME.customResourceBar:Hide()
    end
end
GW.AddForProfiling("classpowers", "timerMetamorphosis", timerMetamorphosis)

-- WARRIOR
local function powerRend()
    local auraData = GetAuraData("target", "player", "HARMFUL", 388539)
    if auraData and auraData.duration ~= nil then
        CPWR_FRAME.customResourceBar:Show()
        local remainingPrecantage = (auraData.expirationTime - GetTime()) / auraData.duration
        local remainingTime = auraData.duration * remainingPrecantage
        CPWR_FRAME.customResourceBar:SetCustomAnimation(remainingPrecantage, 0, remainingTime)
    else
        CPWR_FRAME.customResourceBar:Hide()
    end
end
local function powerEnrage()
    local auraData = GetAuraData("player", nil, "HELPFUL", 184362)
    if auraData and auraData.duration ~= nil then
        CPWR_FRAME.customResourceBar:Show()
        local remainingPrecantage = (auraData.expirationTime - GetTime()) / auraData.duration
        local remainingTime = auraData.duration * remainingPrecantage
        CPWR_FRAME.customResourceBar:SetCustomAnimation(remainingPrecantage, 0, remainingTime)
    else
        CPWR_FRAME.customResourceBar:Hide()
    end
end
GW.AddForProfiling("classpowers", "powerEnrage", powerEnrage)

local function powerSBlock()
    local results
    if CPWR_FRAME.gw_BolsterSelected then
        results = GetAuraData("player", nil, "HELPFUL", 132404, 871, 12975)
    else
        results = GetAuraData("player", nil, "HELPFUL", 132404, 871)
    end
    if results == nil then
        CPWR_FRAME.customResourceBar:Hide()
        return
    end
    CPWR_FRAME.customResourceBar:Show()
    local duration = -1
    local expires = -1
    for i = 1, #results do
        if results[i].expirationTime > expires then
            expires = results[i].expirationTime
            duration = results[i].duration
        end
    end
    if expires > 0 then
        local remainingPrecantage = (expires - GetTime()) / duration
        local remainingTime = duration * remainingPrecantage
        CPWR_FRAME.customResourceBar:SetCustomAnimation(remainingPrecantage, 0, remainingTime)
    end
end
GW.AddForProfiling("classpowers", "powerSBlock", powerSBlock)

local function setWarrior(f)
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)

    if GW.myspec == 1 then --arms rend
        setPowerTypeRend(f.customResourceBar)
        f:SetScript("OnEvent", powerRend)
        powerRend()
        f:RegisterUnitEvent("UNIT_AURA", "target")
        f:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif GW.myspec == 2 then -- fury
        setPowerTypeEnrage(f.customResourceBar)
        f:SetScript("OnEvent", function(_, _, unit, ...) HandleUnitAuraEvent(unit, ...) end)
        powerEnrage()
        f:RegisterUnitEvent("UNIT_AURA", "player")
        EventRegistry:RegisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", powerEnrage, "GW2_UI")
    elseif GW.myspec == 3 then -- prot
        -- determine if bolster talent is selected
        setPowerTYpeBolster(f.customResourceBar)
        f.gw_BolsterSelected = GW.IsSpellTalented(12975)
        f:SetScript("OnEvent", function(_, _, unit, ...) HandleUnitAuraEvent(unit, ...) end)
        powerSBlock()
        f:RegisterUnitEvent("UNIT_AURA", "player")
        EventRegistry:RegisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", powerSBlock, "GW2_UI")
    end

    return true
end
GW.AddForProfiling("classpowers", "setWarrior", setWarrior)

-- PALADIN
local function powerSotR()
    local results = GetAuraData("player", nil, "HELPFUL", 132403, 31850, 212641)
    if results == nil then
        return
    end
    local duration = -1
    local expires = -1
    for i = 1, #results do
        if results[i].expirationTime > expires then
            expires = results[i].expirationTime
            duration = results[i].duration
        end
    end
    if expires > 0 then
        local pre = (expires - GetTime()) / duration
        GW.AddToAnimation("DECAY_BAR", pre, 0, GetTime(), expires - GetTime(), function()
            local remainingPrecantage = (expires - GetTime()) / duration
            local remainingTime = duration * remainingPrecantage
            CPWR_FRAME.customResourceBar:SetCustomAnimation(remainingPrecantage, 0, remainingTime)
        end, "noease")
    end
end


local function powerHoly(self, event, ...)
    if event == "UNIT_AURA" then
        HandleUnitAuraEvent(...)
        return
    end

    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "HOLY_POWER" then
        return
    end

    local old_power = self.gwPower
    local pwr = UnitPower("player", 9)
    local pwrThreshold = (GW.Retail and 3 or 1)
    if pwr < pwrThreshold then
        self.background:SetAlpha(0.2)
    else
        self.background:SetAlpha(1)
    end
    for _, v in pairs(self.paladin.power) do
        if v:IsShown() then
            local id = tonumber(v:GetParentKey())
            if old_power < id and pwr >= id then
                animFlarePoint(self, v, 0.5)
            end
            if pwr >= pwrThreshold and id < (pwrThreshold - 1) then
                v:SetTexCoord(0, 0.5, 0.5, 1)
            elseif pwr >= id then
                v:SetTexCoord(0.5, 1, 0, 0.5)
            elseif pwr < id then
                v:SetTexCoord(0, 0.5, 0, 0.5)
            end
        end
    end
    self.gwPower = pwr
end
GW.AddForProfiling("classpowers", "powerHoly", powerHoly)

local function setPaladin(f)
    f.paladin:Show()

    f.background:ClearAllPoints()
    f.background:SetHeight(41)
    f.background:SetWidth(181)
    f.background:SetTexCoord(0, 0.70703125, 0, 0.640625)
    f.paladin:ClearAllPoints()
    f.paladin:SetPoint("TOPLEFT", f.gwMover, 0, 0)
    f.paladin:SetPoint("BOTTOMLEFT", f.gwMover, 0, 0)
    f.background:SetPoint("LEFT", f.gwMover, "LEFT", 0, 2)

    f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/holypower/background")

    f.fill:Hide()

    local maxPoints = UnitPowerMax("player", 9)
    for _, v in pairs(f.paladin.power) do
        local id = tonumber(v:GetParentKey())
        if id > maxPoints then
            v:Hide()
        else
            v:Show()
        end
    end

    f:SetScript("OnEvent", powerHoly)
    powerHoly(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

    if GW.myspec == 2 then
        f.customResourceBar:SetWidth(164)
        f.customResourceBar:ClearAllPoints()
        f.customResourceBar:SetPoint("RIGHT", f.gwMover, 2, 0)
        f.customResourceBar:Show()

        setPowerTypePaladinShield(f.customResourceBar)

        f:RegisterUnitEvent("UNIT_AURA", "player")
        EventRegistry:RegisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", powerSotR, "GW2_UI")
    end

    return true
end
GW.AddForProfiling("classpowers", "setPaladin", setPaladin)

-- HUNTER
local function powerFrenzy(event)
    local fdc = CPWR_FRAME.decayCounter
    local auraData = GetAuraData("pet", nil, "HELPFUL", 272790)

    if auraData and auraData.duration == nil or not auraData then
        fdc.count:SetText(0)
        CPWR_FRAME.gwPower = -1
        return
    end

    fdc.count:SetText(auraData.applications)
    local old_expires = CPWR_FRAME.gwPower
    old_expires = old_expires or -1
    CPWR_FRAME.gwPower = auraData.expirationTime
    if event == "CLASS_POWER_INIT" or auraData.expirationTime > old_expires then
        local remainingPrecantage = (auraData.expirationTime - GetTime()) / auraData.duration
        local remainingTime = auraData.duration * remainingPrecantage
        CPWR_FRAME.customResourceBar:SetCustomAnimation(remainingPrecantage, 0, remainingTime)
        if event ~= "CLASS_POWER_INIT" then
            GW.AddToAnimation("DECAYCOUNTER_TEXT", 1, 0, GetTime(), 0.5, decayCounterFlash_OnAnim)
        end
    end
end
GW.AddForProfiling("classpowers", "powerFrenzy", powerFrenzy)

local function powerMongoose(event)
    local fdc = CPWR_FRAME.decayCounter
    local auraData = GetAuraData("player", nil, "HELPFUL", 259388)

    if auraData and auraData.duration == nil or not auraData then
        fdc.count:SetText(0)
        CPWR_FRAME.gwPower = -1
        return
    end

    fdc.count:SetText(auraData.applications)
    local old_expires = CPWR_FRAME.gwPower
    old_expires = old_expires or -1
    CPWR_FRAME.gwPower = auraData.expirationTime
    if event == "CLASS_POWER_INIT" or auraData.expirationTime > old_expires then
        local remainingPrecantage = (auraData.expirationTime - GetTime()) / auraData.duration
        local remainingTime = auraData.duration * remainingPrecantage
        CPWR_FRAME.customResourceBar:SetCustomAnimation(remainingPrecantage, 0, remainingTime)
        if event ~= "CLASS_POWER_INIT" then
            GW.AddToAnimation("DECAYCOUNTER_TEXT", 1, 0, GetTime(), 0.5, decayCounterFlash_OnAnim)
        end
    end
end
GW.AddForProfiling("classpowers", "powerMongoose", powerMongoose)

local function setHunter(f)
    if GW.myspec == 1 or (GW.myspec == 3 and GW.IsSpellTalented(259387)) then -- 259387 = mangoose id
        setPowerTYpeFrenzy(f.customResourceBar)
        f.background:SetTexture(nil)
        f.fill:SetTexture(nil)
        f.customResourceBar:Show()
        f.decayCounter:Show()

        if GW.myspec == 1 then -- beast mastery
            f:SetScript("OnEvent", function(_, _, unit, ...) HandleUnitAuraEvent(unit, ...) end)
            powerFrenzy("CLASS_POWER_INIT")
            f:RegisterUnitEvent("UNIT_AURA", "pet")
            EventRegistry:RegisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", powerFrenzy, "GW2_UI")
        elseif GW.myspec == 3 then -- survival
            f:SetScript("OnEvent", function(_, _, unit, ...) HandleUnitAuraEvent(unit, ...) end)
            powerMongoose("CLASS_POWER_INIT")
            f:RegisterUnitEvent("UNIT_AURA", "player")
            EventRegistry:RegisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", powerMongoose, "GW2_UI")
        end

        return true
    end

    return false
end
GW.AddForProfiling("classpowers", "setHunter", setHunter)

-- ROGUE
local function setRogue(f)
    if GW.settings.target_HOOK_COMBOPOINTS then return false end

    setComboBar(f)
    return true
end
GW.AddForProfiling("classpowers", "setRogue", setRogue)

-- PRIEST
local function shadowOrbs(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "SHADOW_ORBS" then
        return
    end

    local currentOrbs = UnitPower("player", Enum.PowerType.ShadowOrbs)
    local old_power = self.gwPower
    if currentOrbs < 2 then
        self.background:SetAlpha(0.2)
    else
        self.background:SetAlpha(1)
    end
    for _, v in pairs(self.priest.power) do
        local id = tonumber(v:GetParentKey())
        if old_power < id and currentOrbs >= id then
            animFlarePoint(self, v, 0.5)
        end
        if currentOrbs >= 3 and id < 4 then
            v:SetTexCoord(0, 0.5, 0.5, 1)
        elseif currentOrbs >= id then
            v:SetTexCoord(0.5, 1, 0, 0.5)
        elseif currentOrbs < id then
            v:SetTexCoord(0, 0.5, 0, 0.5)
        end
    end
    self.gwPower = currentOrbs
end
GW.AddForProfiling("classpowers", "shadowOrbs", shadowOrbs)

local function setPriest(f)
    if GW.myspec == 3 then -- shadow
        if GW.Retail then
            setManaBar(f)
            return true
        elseif GW.Mists then
            f.priest:Show()

            f.background:ClearAllPoints()
            f.background:SetHeight(41)
            f.background:SetWidth(181)
            f.background:SetTexCoord(0, 0.70703125, 0, 0.640625)
            f.priest:ClearAllPoints()
            f.priest:SetPoint("TOPLEFT", f.gwMover, 0, 0)
            f.priest:SetPoint("BOTTOMLEFT", f.gwMover, 0, 0)
            f.background:SetPoint("LEFT", f.gwMover, "LEFT", 0, 2)

            f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/shadoworbs/background")

            f.fill:Hide()

            f:SetScript("OnEvent", shadowOrbs)
            shadowOrbs(f, "CLASS_POWER_INIT")
            f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

            return true
        end
    end

    return false
end
GW.AddForProfiling("classpowers", "setPriest", setPriest)

-- DEATH KNIGHT
local RUNETYPE_BLOOD = 1
local RUNETYPE_FROST = 2
local RUNETYPE_UNHOLY = 3
local RUNETYPE_DEATH = 4

local iconTextures = {
    [RUNETYPE_BLOOD] = "Interface/AddOns/GW2_UI/textures/altpower/runes-blood",
    [RUNETYPE_FROST] = "Interface/AddOns/GW2_UI/textures/altpower/runes",
    [RUNETYPE_UNHOLY] = "Interface/AddOns/GW2_UI/textures/altpower/runes-unholy",
    [RUNETYPE_DEATH] = "Interface/AddOns/GW2_UI/textures/altpower/runes-death"
}
local RUNE_TIMER_ANIMATIONS = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
}

local getBlizzardRuneId = {
    [1] = 1,
    [2] = 2,
    [3] = 5,
    [4] = 6,
    [5] = 3,
    [6] = 4,
}

local function getRuneData(index)
    if GW.Retail then
        local start, duration, ready = GetRuneCooldown(index)
        local progress = 1
        if start ~= nil and duration > 0 then
            progress = (GetTime() - start) / duration
        end
        return {
            start = start,
            duration = duration,
            ready = ready,
            progress = progress,
            runeType = nil, -- no need in retail
        }
    else
        local correctRuneId = getBlizzardRuneId[index]
        local start, duration, ready = GetRuneCooldown(correctRuneId)
        local runeType = GetRuneType(correctRuneId)

        local progress = 1
        if start == nil then
            start = GetTime()
            duration = 0
        end
        return {
            start = start,
            duration = duration,
            ready = ready,
            progress = progress,
            runeType = runeType,
        }
    end
end

local function powerRune(self)
    local f = self
    local fr = self.runeBar
    local runeData = {}

    for i = 1, 6 do
        runeData[i] = getRuneData(i)
    end

    if GW.Retail then
        table.sort(runeData, function(a, b) return a.progress > b.progress end)
    end

    for i = 1, 6 do
        local data = runeData[i]
        local fFill = fr["runeTexFill" .. i]
        local fTex = fr["runeTex" .. i]
        local fFlare = fr["flare" .. i]
        local animId = "RUNE_TIMER_ANIMATIONS" .. i

        if not GW.Retail and data.runeType then
            fFill:SetTexture(iconTextures[data.runeType])
            fTex:SetTexture(iconTextures[data.runeType])
        end

        if data.ready and fFill then
            fFill:SetTexCoord(0.5, 1, 0, 1)
            fFill:SetHeight(32)
            fFill:SetVertexColor(1, 1, 1, 1)
            if GW.Retail then
                fFill:SetDesaturated(false)
            end
            if animations[animId] then
                animations[animId].completed = true
                animations[animId].duration = 0
            end
        else
            if data.start == 0 then
                return
            end
            GW.AddToAnimation(
                animId,
                GW.Retail and data.progress or RUNE_TIMER_ANIMATIONS[i],
                1,
                data.start,
                data.duration,
                function(p)
                    fFill:SetTexCoord(0.5, 1, 1 - p, 1)
                    fFill:SetHeight(32 * p)
                    if GW.Retail then
                        fFill:SetVertexColor(1, 1, 1, 0.5)
                        fFill:SetDesaturated(true)
                        fFill:SetBlendMode("BLEND")
                        fFlare:SetVertexColor(1, 1, 1, 0)
                    else
                        fFill:SetVertexColor(0.6 * p, 0.6 * p, 0.6 * p)
                    end
                end,
                "noease",
                function()
                    f.flare:ClearAllPoints()
                    f.flare:SetPoint("CENTER", fFill, "CENTER", 0, 0)
                    GW.AddToAnimation(
                        "RUNE_FLARE_ANIMATIONS" .. i,
                        1,
                        0,
                        GetTime(),
                        0.5,
                        function(p)
                            if GW.Retail then
                                fFlare:SetVertexColor(1, 1, 1, p)
                                fFlare:SetSize(512 * math.sin(p * math.pi * 0.5), 256)
                                fFlare:SetBlendMode("ADD")
                            else
                                f.flare:SetAlpha(math.min(1, math.max(0, p)))
                            end
                        end
                    )
                end
            )

            if not GW.Retail then
                RUNE_TIMER_ANIMATIONS[i] = 0
            end
        end
        fTex:SetTexCoord(0, 0.5, 0, 1)
    end
end
GW.AddForProfiling("classpowers", "powerRune", powerRune)

local function setDeathKnight(f)
    local fr = f.runeBar
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", f.gwMover, "TOPLEFT", 0, -10)
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f.flare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/runeflash")
    f.flare:SetWidth(256)
    f.flare:SetHeight(128)
    fr:Show()

    if GW.Retail then
        local texture = "runes-blood"
        if GW.myspec == 2 then     -- frost
            texture = "runes"
        elseif GW.myspec == 3 then -- unholy
            texture = "runes-unholy"
        end

        for i = 1, 6 do
            local fFill = fr["runeTexFill" .. i]
            local fTex = fr["runeTex" .. i]
            local fFlare = fr["flare" .. i]

            fFill:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/" .. texture)
            fTex:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/" .. texture)
            fFlare:SetRotation(1.5708)
            fFlare:SetVertexColor(1, 1, 1, 0)
            fFlare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/runeflash")
        end
    elseif GW.Mists then
        for i = 1, 6 do
            local texture
            local fFill = fr["runeTexFill" .. i]
            local fTex = fr["runeTex" .. i]
            local fFlare = fr["flare" .. i]

            if i <= 2 then
                texture = "runes-blood"
            elseif i <= 4 then
                texture = "runes-unholy"
            else
                texture = "runes"
            end

            fFill:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/" .. texture)
            fTex:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/" .. texture)
            fFlare:SetRotation(1.5708)
            fFlare:SetVertexColor(1, 1, 1, 0)
            fFlare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/runeflash")
        end
    end

    f:SetScript("OnEvent", powerRune)
    powerRune(f)
    f:RegisterEvent("RUNE_POWER_UPDATE")

    return true
end
GW.AddForProfiling("classpowers", "setDeathKnight", setDeathKnight)

-- SHAMAN
local function powerMaelstrom()
    local auraData = GetAuraData("player", nil, "HELPFUL", 344179)

    if auraData and auraData.duration == nil then
        CPWR_FRAME.gwPower = -1
        auraData.applications = 0
    end

    if auraData and auraData.applications >= 5 then
        CPWR_FRAME.maelstrom.flare1:Show()
    else
        CPWR_FRAME.maelstrom.flare1:Hide()
    end
    if auraData and auraData.applications >= 10 then
        CPWR_FRAME.maelstrom.flare2:Show()
    else
        CPWR_FRAME.maelstrom.flare2:Hide()
    end

    for i = 1, 10 do
        if auraData and auraData.applications >= i then
            CPWR_FRAME.maelstrom["rune" .. i]:Show()
        else
            CPWR_FRAME.maelstrom["rune" .. i]:Hide()
        end
    end
end
GW.AddForProfiling("classpowers", "powerMaelstrom", powerMaelstrom)

local function setShaman(f)
    if GW.Retail then
        if GW.myspec == 1 then
            -- ele use extra mana bar on left
            setManaBar(f)
            return true
        elseif GW.myspec == 2 then -- enh
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", f.gwMover, "TOPLEFT", 0, -10)
            f.background:SetTexture(nil)
            f.fill:SetTexture(nil)
            local fms = f.maelstrom
            fms:Show()

            f:SetScript("OnEvent", function(_, _, unit, ...) HandleUnitAuraEvent(unit, ...) end)
            powerMaelstrom()
            f:RegisterUnitEvent("UNIT_AURA", "player")
            EventRegistry:RegisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", powerMaelstrom, "GW2_UI")
            return true
        end
    else
        if not InCombatLockdown() then
            UIPARENT_MANAGED_FRAME_POSITIONS.MultiCastActionBarFrame = nil

            MultiCastActionBarFrame:SetParent(f)
            MultiCastActionBarFrame:ClearAllPoints()
            MultiCastActionBarFrame:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, 5)
            hooksecurefunc(MultiCastActionBarFrame, "SetPoint", function(self, p1, anchor, p2, x, y)
                if p1 ~= "TOPLEFT" or anchor ~= f or p2 ~= "BOTTOMLEFT" or x ~= 0 or y ~= 5 then
                    self:ClearAllPoints()
                    self:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, 5)
                end
            end)
        elseif InCombatLockdown() then
            f.decay:RegisterEvent("PLAYER_REGEN_ENABLED")
        end

        f.background:Hide()
        f.fill:Hide()

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

local function powerFrost(event)
    local auraData = GetAuraData("player", nil, "HELPFUL", 205473)
    local count = auraData and auraData.applications or 0

    local old_power = CPWR_FRAME.gwPower
    old_power = old_power or -1

    CPWR_FRAME.gwPower = count
    CPWR_FRAME.background:SetTexCoord(0, 1, 0.125 * 5, 0.125 * (5 + 1))
    CPWR_FRAME.fill:SetTexCoord(0, 1, 0.125 * count, 0.125 * (count + 1))

    if old_power < count and count > 0 and event ~= "CLASS_POWER_INIT" then
        animFlare(CPWR_FRAME, 32, -16, 2, true)
    end
end

local function setMage(f)
    if GW.myspec == 1 then -- arcane
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", f.gwMover, "TOPLEFT", 0, 15)
        f:SetHeight(64)
        f:SetWidth(512)
        f.background:SetHeight(64)
        f.background:SetWidth(512)
        f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/arcane")
        f.background:SetTexCoord(0, 1, 0.125 * 3, 0.125 * (3 + 1))
        f.flare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/arcane-flash")
        f.flare:SetWidth(256)
        f.flare:SetHeight(256)
        f.fill:SetHeight(64)
        f.fill:SetWidth(512)
        f.fill:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/arcane")
        f.background:SetVertexColor(0, 0, 0, 0.5)

        f:SetScript("OnEvent", powerArcane)
        powerArcane(f, "CLASS_POWER_INIT")
        f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
        f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

        return true
    elseif GW.myspec == 3 then --frost
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", f.gwMover, "TOPLEFT", 0, 0)
        f:SetHeight(32)
        f:SetWidth(256)
        f.background:SetHeight(32)
        f.background:SetWidth(256)
        f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/frostmage-altpower")
        f.background:SetTexCoord(0, 1, 0.125 * 5, 0.125 * (5 + 1))
        f.flare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/arcane-flash")
        f.flare:SetWidth(128)
        f.flare:SetHeight(128)
        f.fill:SetHeight(32)
        f.fill:SetWidth(256)
        f.fill:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/frostmage-altpower")
        f.background:SetVertexColor(0, 0, 0, 0.5)

        f:SetScript("OnEvent", function(_, _, unit, ...) HandleUnitAuraEvent(unit, ...) end)
        powerFrost("CLASS_POWER_INIT")
        f:RegisterUnitEvent("UNIT_AURA", "player")
        EventRegistry:RegisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", powerFrost, "GW2_UI")

        return true
    end

    return false
end
GW.AddForProfiling("classpowers", "setMage", setMage)

-- WARLOCK
local function powerSoulshard(self, event, ...)
    if event == "LEARNED_SPELL_IN_TAB" then
        updateTextureBasedOnCondition(self)
        return
    end

    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and (pType ~= "SOUL_SHARDS" and pType ~= "BURNING_EMBERS") then
        return
    end
    local powerType = self.warlock.powerType
    local pwrMax = UnitPowerMax("player", powerType)
    local pwr = UnitPower("player", powerType)
    local old_power = self.gwPower
    self.gwPower = pwr

    for i = 1, pwrMax do
        self.warlock["shardBg" .. i]:Show()
        if pwr >= i then
            self.warlock["shard" .. i]:Show()
            self.warlock.shardFlare:ClearAllPoints()
            self.warlock.shardFlare:SetPoint("CENTER", self.warlock["shard" .. i], "CENTER", 0, 0)
            if pwr > old_power then
                self.warlock.shardFlare:Show()
                GW.AddToAnimation(
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

    if GW.myspec == 3 then -- Destruction
        local shardPower = UnitPower("player", powerType, true)
        local shardModifier = UnitPowerDisplayMod(powerType)
        shardPower = (shardModifier ~= 0) and (shardPower / shardModifier) or 0
        shardPower = Saturate(shardPower - pwr)
        if shardPower == 0 then shardPower = 0.00000000000001 end

        --Hide fragment bar if capped
        if pwr >= pwrMax or shardPower >= 1 then
            self.warlock.shardFragment:Hide()
        else
            self.warlock.shardFragment:Show()
        end

        self.warlock.shardFragment.barFill:SetWidth(130 * shardPower)
        self.warlock.shardFragment.barFill:SetTexCoord(0, shardPower, 0, 1)
        if self.warlock.shardFragment.amount < shardPower then
            GW.AddToAnimation(
                "WARLOCK_FRAGMENT_FLARE",
                1,
                0,
                GetTime(),
                0.3,
                function(p)
                    self.warlock.shardFragment.flare:SetAlpha(math.min(1, math.max(0, p)))
                end
            )
        end
        self.warlock.shardFragment.amount = shardPower
    end
end
GW.AddForProfiling("classpowers", "powerSoulshard", powerSoulshard)

local function powerDemonicFury(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "DEMONIC_FURY" then
        return
    end

    local power = UnitPower("player", Enum.PowerType.DemonicFury)
    local maxPower = UnitPowerMax("player", Enum.PowerType.DemonicFury)
    local percent = power / maxPower
    if event == "CLASS_POWER_INIT" then
        self.customResourceBar:ForceFillAmount(percent)
    else
        self.customResourceBar:SetFillAmount(percent)
    end
end

local function setWarlock(f)
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f:SetHeight(32)
    f.warlock:Show()
    if GW.myspec == 3 then -- Destruction
        f.warlock.shardFragment.amount = -1
        f.warlock.shardFragment:Show()
        local flarAnimationMap = {
            width = 512,
            height = 512,
            colums = 2,
            rows = 4
        }
        f.warlock.flareMap = flarAnimationMap
    else
        f.warlock.shardFragment:Hide()
    end
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    if GW.Mists then
        f:RegisterEvent("UNIT_DISPLAYPOWER")
    end
    -- Register "LEARNED_SPELL_IN_TAB" so we can check for the green fire spell and check an login
    f:RegisterEvent("LEARNED_SPELL_IN_TAB")
    f.useRedTexture = false

    if GW.Retail then
        f.warlock.powerType = Enum.PowerType.SoulShards
        f:SetScript("OnEvent", powerSoulshard)
        powerSoulshard(f, "CLASS_POWER_INIT")
    elseif GW.Mists then
        if GW.myspec == 1 then
            f.warlock.powerType = Enum.PowerType.SoulShards
            f:SetScript("OnEvent", powerSoulshard)
            powerSoulshard(f, "CLASS_POWER_INIT")
        elseif GW.myspec == 2 then
            f.warlock:Hide()
            setPowerTypeMeta(f.customResourceBar)
            f.customResourceBar:Show()
            f.customResourceBar:SetWidth(312)
            f.customResourceBar:ClearAllPoints()
            f.customResourceBar:SetPoint("LEFT", f.gwMover, 0, -5)

            f:SetScript("OnEvent", powerDemonicFury)
            powerDemonicFury(f, "CLASS_POWER_INIT")
        elseif GW.myspec == 3 then
            f.warlock.powerType = Enum.PowerType.BurningEmbers
            f:SetScript("OnEvent", powerSoulshard)
            powerSoulshard(f, "CLASS_POWER_INIT")
            f.useRedTexture = true
        end
    end

    updateTextureBasedOnCondition(f)

    return true
end
GW.AddForProfiling("classpowers", "setWarlock", setWarlock)

-- MONK
local function powerChi(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "CHI" and pType ~= "DARK_FORCE" then
        return
    end

    local old_power = self.gwPower
    old_power = old_power or -1

    local pwrMax = UnitPowerMax("player", 12)
    local pwr = UnitPower("player", 12)
    local p = pwr - 1

    self.gwPower = pwr

    self.background:SetTexCoord(0, 1, 0.111 * (pwrMax + 2), 0.111 * (pwrMax + 3))
    self.fill:SetTexCoord(0, 1, 0.111 * p, 0.111 * (p + 1))

    if old_power < pwr and event ~= "CLASS_POWER_INIT" then
        animFlare(self)
    end
end
GW.AddForProfiling("classpowers", "powerChi", powerChi)

local function ironSkin_OnUpdate(self)
    local precentage = math.min(1, math.max(0, (self.expires - GetTime()) / 23))
    self.ironartwork:SetAlpha(precentage)
    self.fill:SetTexCoord(0, precentage, 0, 1)
    self.fill:SetWidth(precentage * 256)

    self.indicator:SetPoint("LEFT", math.min(252, (precentage * 256)) - 13, 19)
    self.indicatorText:SetText(RoundInt(self.expires - GetTime()) .. "s")
end
GW.AddForProfiling("classpowers", "ironSkin_OnUpdate", ironSkin_OnUpdate)

local staggerTextColors = {
    {r = 0.4, g = 0.9, b = 0.4},
    {r = 0.95, g = 0.85, b = 0.3},
    {r = 0.9, g = 0.4, b = 0.4}
}

local function setStaggerBar()
    local fb = CPWR_FRAME.brewmaster
    local auraData = GetAuraData("player", nil, "HELPFUL", GW.Mists and 115307 or 215479)

    if auraData and auraData.expirationTime then
        fb.ironskin.expires = auraData.expirationTime
        if fb.ironskin.ticker then
            fb.ironskin.ticker:Cancel()
        end
        fb.ironskin.ticker = C_Timer.NewTicker(0.05, function() ironSkin_OnUpdate(fb.ironskin) end)
        fb.ironskin:Show()
        fb.ironskin.ironartwork:Show()
    else
        if fb.ironskin.ticker then
            fb.ironskin.ticker:Cancel()
        end
        fb.ironskin:Hide()
        fb.ironskin.ironartwork:Hide()
        fb.ironskin.expires = nil
    end

    local debuff
    auraData = GetAuraData("player", nil, "HARMFUL", 124275, 124274, 124273)
    debuff = auraData and auraData[1] or nil

    local bar = CPWR_FRAME.customResourceBar

    if debuff and debuff.duration and debuff.expirationTime then
        local now = GetTime()
        local remaining = max(0, debuff.expirationTime - now)
        local remainingPercentage = max(0, min(remaining / debuff.duration, 1))
        local remainingTime = debuff.duration * remainingPercentage


        local pwrMax = UnitHealthMax("player")
        local stagger = UnitStagger("player") or 0

        local staggerPrec = math.max(0, math.min(stagger / pwrMax, 1))
        local colorToUse = staggerTextColors[1]
        if staggerPrec >= 0.75 then
            colorToUse = staggerTextColors[3]
        elseif staggerPrec >= 0.5 then
            colorToUse = staggerTextColors[2]
        end

        if bar._lastFill ~= staggerPrec or bar._lastRemain ~= remaining then
            bar:SetCustomAnimation(staggerPrec, 0, remainingTime)
            bar._lastFill = staggerPrec
            bar._lastRemain = remaining
        end

        local staggerText = GW.GetLocalizedNumber(format("%.2f%%", staggerPrec * 100))
        if bar.label._lastText ~= staggerText then
            bar.label:SetText(staggerText)
            bar.label._lastText = staggerText
        end
        if not (bar.label._lastR == colorToUse.r and bar.label._lastG == colorToUse.g and bar.label._lastB == colorToUse.b) then
            bar.label:SetTextColor(colorToUse.r, colorToUse.g, colorToUse.b)
            bar.label._lastR, bar.label._lastG, bar.label._lastB = colorToUse.r, colorToUse.g, colorToUse.b
        end
    else
        if bar._lastFill ~= 0 then
            bar:ForceFillAmount(0)
            bar._lastFill, bar._lastRemain = 0, 0
        end
        local staggerText = GW.GetLocalizedNumber(format("%.2f%%", 0))
        if bar.label._lastText ~= staggerText then
            bar.label:SetText(staggerText)
            bar.label._lastText = staggerText
        end
        local c = staggerTextColors[1]
        if not (bar.label._lastR == c.r and bar.label._lastG == c.g and bar.label._lastB == c.b) then
            bar.label:SetTextColor(c.r, c.g, c.b)
            bar.label._lastR, bar.label._lastG, bar.label._lastB = c.r, c.g, c.b
        end
    end
end

local function powerStagger(self, event, ...)
    local unit = select(1, ...)
    local fb = self.brewmaster
    if event == nil then
        fb.ironskin:Hide()
        fb.ironskin.ironartwork:Hide()
        if fb.ironskin.ticker then
            fb.ironskin.ticker:Cancel()
        end
    end

    if unit == "player" and event == "UNIT_AURA" then
        HandleUnitAuraEvent(...)
    end
end
GW.AddForProfiling("classpowers", "powerStagger", powerStagger)

local function setMonk(f)
    if GW.Retail then
        if GW.myspec == 1 then -- brewmaster
            f.background:SetTexture(nil)
            f.fill:SetTexture(nil)
            setPowerTypeStagger(f.customResourceBar)
            f.brewmaster:Show()
            f.customResourceBar:Show()
            f.customResourceBar:SetWidth(312)
            f.customResourceBar:ClearAllPoints()
            f.customResourceBar:SetPoint("LEFT", f.gwMover, 0, -5)

            f:SetScript("OnEvent", powerStagger)
            powerStagger(f, "CLASS_POWER_INIT")

            f:RegisterUnitEvent("UNIT_AURA", "player")
            f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
            f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
            EventRegistry:RegisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", setStaggerBar, "GW2_UI")

            return true
        elseif GW.myspec == 3 then -- ww
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", f.gwMover, "TOPLEFT", 0, 0)
            f:SetHeight(32)
            f:SetWidth(256)
            f.background:SetHeight(32)
            f.background:SetWidth(320)
            f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi")
            f.background:SetTexCoord(0, 1, 0.5, 1)
            f.flare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi-flare")
            f.fill:SetHeight(32)
            f.fill:SetWidth(256)
            f.fill:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi")

            f:SetScript("OnEvent", powerChi)
            powerChi(f, "CLASS_POWER_INIT")
            f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
            f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

            return true
        end
    elseif GW.Mists then
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", f.gwMover, "TOPLEFT", 0, 0)
        f:SetHeight(32)
        f:SetWidth(256)
        f.background:SetHeight(32)
        f.background:SetWidth(320)
        f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi")
        f.background:SetTexCoord(0, 1, 0.5, 1)
        f.flare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi-flare")
        f.fill:SetHeight(32)
        f.fill:SetWidth(256)
        f.fill:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/chi")

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
    local barType = "none"

    if GW.Retail then
        if GW.myspec == 1 then -- balance
            if form == 1 then
                -- if in cat form, show combo points
                barType = "combo|little_mana"
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
                -- show combo points in cat form
                barType = "combo|little_mana"
            elseif form == 5 then
                -- show mana in bear form
                barType = "mana"
            end
        elseif GW.myspec == 4 then -- resto
            if form == 1 then
                -- show combo points in cat form
                barType = "combo|little_mana"
            elseif form == 5 then
                -- show mana in bear form
                barType = "mana"
            end
        end
    elseif GW.Mists then
        if GW.myspec == 1 and form == nil then
            barType = "eclips"
        end
        if form == CAT_FORM then                   -- cat
            barType = "combo|little_mana"
        elseif form == BEAR_FORM or form == 8 then --bear
            barType = "little_mana"
        elseif form == MOONKIN_FORM then           --Moonkin
            barType = "eclips"
        end
    elseif GW.Classic then
        if form == CAT_FORM then                   -- cat
            barType = "combo|little_mana"
        elseif form == BEAR_FORM or form == 8 then --bear
            barType = "little_mana"
        end
    end

    if barType == "combo" then
        setComboBar(f)
        return true
    elseif barType == "mana" then
        setManaBar(f)
        return true
    elseif barType == "little_mana" and GW.settings.POWERBAR_ENABLED then -- classic
        setLittleManaBar(f, "combo")
        return false
    elseif barType == "combo|little_mana" then
        setComboBar(f)
        if GW.settings.POWERBAR_ENABLED then
            setLittleManaBar(f, "combo")
        end
        return true
    elseif barType == "eclips" then
        setEclips(f)
        return true
    else
        return false
    end
end
GW.AddForProfiling("classpowers", "setDruid", setDruid)

local function setDeamonHunter(f)
    if GW.myspec == 1 then -- havoc
        setPowerTypeMeta(f.customResourceBar)
        f.customResourceBar:Show()
        f.background:SetTexture(nil)
        f.fill:SetTexture(nil)

        f:SetScript("OnEvent", function(_, _, unit, ...) HandleUnitAuraEvent(unit, ...) end)
        timerMetamorphosis()
        f:RegisterUnitEvent("UNIT_AURA", "player")
        EventRegistry:RegisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", timerMetamorphosis, "GW2_UI")

        return true
    end

    return false
end
GW.AddForProfiling("classpowers", "setDeamonHunter", setDeamonHunter)

local function selectType(f)
    f:SetScript("OnEvent", nil)
    EventRegistry:UnregisterCallback("GW2_UI_CLASSPOWER_PLAYER_UNIT_AURA", "GW2_UI")
    f:UnregisterAllEvents()

    -- hide all class power sub-pieces and reset anything needed
    f.customResourceBar:ForceFillAmount(0)
    f.customResourceBar:ResetPowerBarVisuals()
    f.customResourceBar:Hide()
    f.customResourceBar:SetWidth(313)
    f.runeBar:Hide()
    f.decayCounter:Hide()
    f.maelstrom:Hide()
    f.priest:Hide()
    f.paladin:Hide()
    f.brewmaster:Hide()
    f.disc:Hide()
    f.decay:Hide()
    f.exbar:Hide()
    f.exbar.decay:Hide()
    f.warlock:Hide()
    f.combopoints:Hide()
    f.evoker:Hide()
    f.eclips:Hide()

    if GW.settings.POWERBAR_ENABLED then
        f.lmb:Hide()
        f.lmb.decay:Hide()
    end
    f.gwPower = -1
    local showBar = false

    if f.unit == "vehicle" then
        showBar = false
    elseif GW.myClassID == 1 and GW.Retail then
        showBar = setWarrior(f)
    elseif GW.myClassID == 2 and not GW.Classic then
        showBar = setPaladin(f)
    elseif GW.myClassID == 3 and GW.Retail then
        showBar = setHunter(f)
    elseif GW.myClassID == 4 then
        showBar = setRogue(f)
    elseif GW.myClassID == 5 and not GW.Classic then
        showBar = setPriest(f)
    elseif GW.myClassID == 6 and not GW.Classic then
        showBar = setDeathKnight(f)
    elseif GW.myClassID == 7 and not GW.Classic then
        showBar = setShaman(f)
    elseif GW.myClassID == 8 and GW.Retail then
        showBar = setMage(f)
    elseif GW.myClassID == 9 and not GW.Classic then
        showBar = setWarlock(f)
    elseif GW.myClassID == 10 and (GW.Retail or GW.Mists) then
        showBar = setMonk(f)
    elseif GW.myClassID == 11 then
        showBar = setDruid(f)
    elseif GW.myClassID == 12 and GW.Retail then
        showBar = setDeamonHunter(f)
    elseif GW.myClassID == 13 and GW.Retail then
        showBar = setEvoker(f)
    end

    f.shouldShowBar = showBar

    UpdateVisibility(f, InCombatLockdown())
end
GW.AddForProfiling("classpowers", "selectType", selectType)

local function barChange_OnEvent(self, event)
    if not self then return end
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
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "CHARACTER_POINTS_CHANGED" or event == "FORCE_UPDATE" then
        f.gwPlayerForm = GetShapeshiftFormID()
        GW.CheckRole()
        selectType(f)
    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        UpdateVisibility(f, event == "PLAYER_REGEN_DISABLED")
    elseif event == "UNIT_ENTERED_VEHICLE" then
        f.unit = "vehicle"
        selectType(f)
    elseif event == "UNIT_EXITED_VEHICLE" then
        f.unit = "player"
        selectType(f)
    end
end
GW.UpdateClasspowerBar = barChange_OnEvent

local function UpdateExtraManabar()
    if not GW.settings.CLASS_POWER then return end
    if GW.settings.POWERBAR_ENABLED then
        local anchorFrame = GW.settings.PLAYER_AS_TARGET_FRAME and GwPlayerUnitFrame and GwPlayerUnitFrame or
            GwPlayerPowerBar
        local barWidth = GW.settings.PLAYER_AS_TARGET_FRAME and GwPlayerUnitFrame and
            GwPlayerUnitFrame.powerbar:GetWidth() or GwPlayerPowerBar:GetWidth()

        GwPlayerAltClassLmb:ClearAllPoints()
        if GW.settings.PLAYER_AS_TARGET_FRAME then
            GwPlayerAltClassLmb:SetPoint("TOPLEFT", anchorFrame.powerbar, "BOTTOMLEFT", 0, -3)
            GwPlayerAltClassLmb:SetPoint("TOPRIGHT", anchorFrame.powerbar, "BOTTOMRIGHT", 0, -3)
            GwPlayerAltClassLmb:SetSize(barWidth + 2, 3)
        else
            GwPlayerAltClassLmb:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 0)
            GwPlayerAltClassLmb:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 0)
            GwPlayerAltClassLmb:SetSize(barWidth, 5)
        end

        GwPlayerAltClassLmb:SetParent(UIParent)

        barChange_OnEvent(GwPlayerClassPower.decay, "FORCE_UPDATE")
    else
        GwPlayerAltClassLmb:SetParent(GW.HiddenFrame)
    end
end
GW.UpdateClassPowerExtraManabar = UpdateExtraManabar

local function LoadClassPowers()
    local cpf = CreateFrame("Frame", "GwPlayerClassPower", UIParent, "GwPlayerClassPower")
    CPWR_FRAME = cpf

    cpf.customResourceBar = GW.CreateAnimatedStatusBar("GwCustomResourceBar", cpf, "GwStatusPowerBar", true)
    cpf.customResourceBar.customMaskSize = 64
    cpf.customResourceBar.bar = cpf.customResourceBar
    cpf.customResourceBar:AddToBarMask(cpf.customResourceBar.intensity)
    cpf.customResourceBar:AddToBarMask(cpf.customResourceBar.intensity2)
    cpf.customResourceBar:AddToBarMask(cpf.customResourceBar.scrollTexture)
    cpf.customResourceBar:AddToBarMask(cpf.customResourceBar.scrollTexture2)
    cpf.customResourceBar:AddToBarMask(cpf.customResourceBar.runeoverlay)
    cpf.customResourceBar.runicmask:SetSize(cpf.customResourceBar:GetSize())
    cpf.customResourceBar.runeoverlay:AddMaskTexture(cpf.customResourceBar.runicmask)

    cpf.customResourceBar.decay = GW.CreateAnimatedStatusBar("GwPlayerPowerBarDecay", UIParent, nil, true)

    cpf.customResourceBar.decay:SetFillAmount(0)
    cpf.customResourceBar.decay:SetFrameLevel(cpf.customResourceBar.decay:GetFrameLevel() - 1)
    cpf.customResourceBar.decay:ClearAllPoints()
    cpf.customResourceBar.decay:SetPoint("TOPLEFT", cpf.customResourceBar, "TOPLEFT", 0, 0)
    cpf.customResourceBar.decay:SetPoint("BOTTOMRIGHT", cpf.customResourceBar, "BOTTOMRIGHT", 0, 0)

    cpf.customResourceBar:SetScript("OnShow", function() cpf.customResourceBar.decay:Show() end)
    cpf.customResourceBar:SetScript("OnHide", function() cpf.customResourceBar.decay:Hide() end)

    cpf.customResourceBar:ClearAllPoints()
    cpf.customResourceBar:SetPoint("LEFT", cpf, "LEFT", 0, -11)

    cpf.customResourceBar.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    cpf.customResourceBar.label:SetShadowColor(0, 0, 0, 1)
    cpf.customResourceBar.label:SetShadowOffset(1, -1)

    GW.RegisterMovableFrame(cpf, GW.L["Class Power"], "ClasspowerBar_pos", ALL .. ",Unitframe,Power", { 312, 32 },
        { "default", "scaleable" }, true)

    -- position mover
    if (not GW.settings.XPBAR_ENABLED or GW.settings.PLAYER_AS_TARGET_FRAME) and not cpf.isMoved then
        local framePoint = GW.settings.ClasspowerBar_pos
        local yOff = not GW.settings.XPBAR_ENABLED and 14 or 0
        local xOff = GW.settings.PLAYER_AS_TARGET_FRAME and 52 or 0
        cpf.gwMover:ClearAllPoints()
        cpf.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs + xOff,
            framePoint.yOfs - yOff)
    end
    cpf:ClearAllPoints()
    cpf:SetPoint("TOPLEFT", cpf.gwMover)

    -- need to pull it out of core because of not existing atlas files on non retail clients
    if GW.Retail then
        for i = 1, 6 do
            cpf.evoker["essence" .. i] = CreateFrame("Frame", nil, cpf.evoker, "GwEssencePointTemplate")
            cpf.evoker["essence" .. i]:SetSize(32, 32)
            cpf.evoker["essence" .. i]:SetPoint("LEFT", cpf.evoker, "LEFT", (i - 1) * 32, 0)
        end
    end

    cpf.auraExpirationTime = nil

    -- create an extra mana power bar that is used sometimes (feral druid in cat form) only if your Powerbar is on
    local lmb = GW.CreateAnimatedStatusBar("GwPlayerAltClassLmb", cpf, "GwStatusPowerBar", true)
    lmb.customMaskSize = 64
    lmb.bar = lmb
    lmb:AddToBarMask(lmb.intensity)
    lmb:AddToBarMask(lmb.intensity2)
    lmb:AddToBarMask(lmb.scrollTexture)
    lmb:AddToBarMask(lmb.scrollTexture2)
    lmb:AddToBarMask(lmb.runeoverlay)
    lmb.runicmask:SetSize(lmb:GetSize())
    lmb.runeoverlay:AddMaskTexture(lmb.runicmask)
    cpf.lmb = lmb

    lmb.decay = GW.CreateAnimatedStatusBar("GwPlayerAltClassLmbBarDecay", lmb, nil, true)
    lmb.decay:SetFillAmount(0)
    lmb.decay:SetFrameLevel(lmb.decay:GetFrameLevel() - 1)
    lmb.decay:ClearAllPoints()
    lmb.decay:SetPoint("TOPLEFT", lmb, "TOPLEFT", 0, 0)
    lmb.decay:SetPoint("BOTTOMRIGHT", lmb, "BOTTOMRIGHT", 0, 0)
    lmb:SetFrameStrata("MEDIUM")
    lmb.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL)
    lmb.label:SetShadowColor(0, 0, 0, 1)
    lmb.label:SetShadowOffset(1, -1)

    -- create an extra mana power bar that is used sometimes
    local exbar = GW.CreateAnimatedStatusBar("GwPlayerAltClassExBar", cpf, "GwStatusPowerBar", true)
    exbar.customMaskSize = 64
    exbar.bar = exbar
    exbar:AddToBarMask(exbar.intensity)
    exbar:AddToBarMask(exbar.intensity2)
    exbar:AddToBarMask(exbar.scrollTexture)
    exbar:AddToBarMask(exbar.scrollTexture2)
    exbar:AddToBarMask(exbar.runeoverlay)
    exbar.runicmask:SetSize(exbar:GetSize())
    exbar.runeoverlay:AddMaskTexture(exbar.runicmask)

    exbar.decay = GW.CreateAnimatedStatusBar("GwPlayerAltClassExBarDecay", exbar, nil, true)
    exbar.decay:SetFillAmount(0)
    exbar.decay:SetFrameLevel(exbar.decay:GetFrameLevel() - 1)
    exbar.decay:ClearAllPoints()
    exbar.decay:SetPoint("TOPLEFT", exbar, "TOPLEFT", 0, 0)
    exbar.decay:SetPoint("BOTTOMRIGHT", exbar, "BOTTOMRIGHT", 0, 0)

    if not GW.Classic then
        GW.MixinHideDuringPetAndOverride(cpf)
        GW.MixinHideDuringPetAndOverride(cpf.customResourceBar)
        GW.MixinHideDuringPetAndOverride(cpf.customResourceBar.decay)
        GW.MixinHideDuringPetAndOverride(lmb)
        GW.MixinHideDuringPetAndOverride(lmb.decay)
        GW.MixinHideDuringPetAndOverride(exbar)
        GW.MixinHideDuringPetAndOverride(exbar.decay)
    end
    cpf.exbar = exbar

    exbar:SetPoint("TOPLEFT", cpf)

    exbar:SetFrameStrata("MEDIUM")
    exbar.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    exbar.label:SetShadowColor(0, 0, 0, 1)
    exbar.label:SetShadowOffset(1, -1)

    -- set a bunch of other init styling stuff
    cpf.decayCounter.count:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, "OUTLINE", 6)
    cpf.brewmaster.ironskin.indicatorText:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    cpf.brewmaster.ironskin.expires = 0
    cpf.disc.bar.overlay:SetModel(1372783)
    cpf.disc.bar.overlay:SetPosition(0, 0, 2)
    cpf.disc.bar.overlay:SetPosition(0, 0, 0)

    cpf.decay:SetScript("OnEvent", barChange_OnEvent)
    cpf.decay:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    cpf.decay:RegisterEvent("PLAYER_ENTERING_WORLD")
    cpf.decay:RegisterEvent("CHARACTER_POINTS_CHANGED")
    cpf.decay:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    cpf.decay:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
    cpf.decay:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")

    cpf.gwPlayerForm = GetShapeshiftFormID()
    cpf.unit = "player"
    cpf:Show()

    updateVisibilitySetting(cpf, false)
    selectType(cpf)
    UpdateExtraManabar()
end
GW.LoadClassPowers = LoadClassPowers
