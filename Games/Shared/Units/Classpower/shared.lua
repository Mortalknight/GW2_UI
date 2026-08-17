---@class GW2
local GW = select(2, ...)
local lerp = GW.lerp

local playerAuras = {buffs = {}, debuffs = {}}
local petAuras = {buffs = {}, debuffs = {}}
-- Shared classpower namespace: helpers, bar stylers and the per-class setup
-- registry (CP.setups[GW.Enum.ClassIndex.X], filled by the class files in this folder).
-- CP.frame is the classpower frame, assigned in classpowers.lua on load.
local CP = {}
CP.setups = {}
GW.ClassPowers = CP

local function HandleUnitAuraEvent(unit, ...)
    local auraUpdateInfo = ...
    local isFullUpdate = not auraUpdateInfo or auraUpdateInfo.isFullUpdate
    local buffsChanged = false
    local debuffsChanged = false
    local dataTable = unit == "pet" and petAuras or unit == "player" and playerAuras or nil
    if not dataTable then return end
    -- every lookup below is one of the RequiresUnitAuraAccess APIs, so while the restriction is
    -- in effect they cannot return data either way - this trades an error for a skipped refresh
    if GW.AreAurasSecret() then return end

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
        EventRegistry:TriggerEvent("GW2_UI.ClasspowerPlayerUnitAura", unit, dataTable)
    end
end

local function UpdateAlphaFader(alpha)
    for _, frame in ipairs({
        CP.frame,
        CP.frame.customResourceBar,
        CP.frame.customResourceBar.decay,
        CP.frame.lmb,
        CP.frame.lmb.decay,
        CP.frame.lmbSecret,
        CP.frame.exbar,
        CP.frame.exbar.decay,
        CP.frame.exbarSecret
    }) do
        if frame then
            GW.SetAlphaRecursive(frame, alpha)
        end
    end
end

local function UpdateVisibility(self, inCombat)
    local shouldBeVisible = self.shouldShowBar and (not self.onlyShowInCombat or inCombat)
    local targetAlpha = shouldBeVisible and 1 or 0

    if self.shouldShowBar and GW.settings.PLAYER_AS_TARGET_FRAME and GwPlayerUnitFrame.Fader and GwPlayerUnitFrame.Fader:IsEnabled() then
        targetAlpha = GwPlayerUnitFrame.Fader.currentAlpha
    end

    for _, frame in ipairs({
        self,
        self.customResourceBar,
        self.customResourceBar.decay,
        self.lmb,
        self.lmb.decay,
        self.lmbSecret,
        self.exbar,
        self.exbar.decay,
        self.exbarSecret
    }) do
        if frame then
            GW.SetAlphaRecursive(frame, targetAlpha)
        end
    end
end

local VALID_CLASSPOWER_ANCHOR_MODES = {
    DEFAULT = true,
    CENTER = true,
    LEFT = true,
    RIGHT = true
}

local VALID_CLASSPOWER_CUSTOM_RESOURCEBAR_SIDES = {
    AUTO = true,
    LEFT = true,
    RIGHT = true
}

function CP.GetAnchorMode()
    local mode = GW.settings.CLASSPOWER_ANCHOR_MODE
    if mode and VALID_CLASSPOWER_ANCHOR_MODES[mode] then
        return mode
    end

    return "DEFAULT"
end

function CP.GetAnchorPoint(defaultPoint)
    local mode = CP.GetAnchorMode()
    if mode == "DEFAULT" then
        return defaultPoint or "TOPLEFT"
    end

    return mode
end

function CP.GetCustomResourceBarSide()
    local side = GW.settings.CLASSPOWER_CUSTOMRESOURCEBAR_SIDE
    if not (side and VALID_CLASSPOWER_CUSTOM_RESOURCEBAR_SIDES[side]) then
        side = "AUTO"
    end

    if side ~= "AUTO" then
        return side
    end

    local anchorMode = CP.GetAnchorMode()
    if anchorMode == "RIGHT" then
        return "LEFT"
    elseif anchorMode == "LEFT" then
        return "RIGHT"
    end

    return "RIGHT"
end

local function GetClassPowerCustomResourceBarGap(fallback)
    local gap = GW.settings.CLASSPOWER_CUSTOMRESOURCEBAR_GAP
    if type(gap) ~= "number" then
        gap = fallback or 4
    end

    return gap
end

local function SetClassPowerAnchor(frame, mover, defaultPoint, xOfs, yOfs, relativePoint)
    if not frame or not mover then
        return
    end

    local point = CP.GetAnchorPoint(defaultPoint)
    local finalX = xOfs or 0
    local finalY = yOfs or 0

    if CP.frame and mover == CP.frame.gwMover then
        finalX = finalX + (GW.settings.CLASSPOWER_ANCHOR_OFFSET_X or 0)
        finalY = finalY + (GW.settings.CLASSPOWER_ANCHOR_OFFSET_Y or 0)
    end

    frame:ClearAllPoints()
    frame:SetPoint(point, mover, relativePoint or point, finalX, finalY)
end

local function SetClassPowerCustomResourceBarAnchor(bar, mover, ownerFrame, yOfs, leftXOfs, rightXOfs, edgeGap)
    if not bar or not mover then
        return
    end

    local side = CP.GetCustomResourceBarSide()
    local anchorMode = CP.GetAnchorMode()
    local configuredWidth = bar.gwConfiguredWidth or bar:GetWidth()
    bar:ClearAllPoints()

    -- In CENTER mode keep the bar inside mover bounds and shrink it to available side space.
    local gap = GetClassPowerCustomResourceBarGap(edgeGap or 4)
    if anchorMode == "CENTER" and ownerFrame:IsShown() then
        local moverWidth = mover:GetWidth()
        local ownerWidth = ownerFrame:GetWidth()
        local availableWidth = math.max(1, math.floor(((moverWidth - ownerWidth) * 0.5) - gap))
        bar:SetWidth(math.min(configuredWidth, availableWidth))

        if side == "LEFT" then
            bar:SetPoint("LEFT", mover, "LEFT", leftXOfs or 0, yOfs or 0)
        else
            bar:SetPoint("RIGHT", mover, "RIGHT", rightXOfs or 2, yOfs or 0)
        end
        return
    end

    bar:SetWidth(configuredWidth)
    if side == "LEFT" then
        bar:SetPoint("LEFT", mover, "LEFT", leftXOfs or 0, yOfs or 0)
    else
        bar:SetPoint("RIGHT", mover, "RIGHT", rightXOfs or 2, yOfs or 0)
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
CP.UpdateVisibilitySetting = updateVisibilitySetting

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
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/bloster.png")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/spark.png")
    self.runeoverlay:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/bloster-intensity.png")
    self.runeoverlay:SetAlpha(1)
    self.spark:SetBlendMode("ADD")
    self.spark:SetAlpha(0.3)
    self.customMaskSize = 30
end
local function setPowerTypeEbonMight(self)
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/agu.png")
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/agu-intensity.png", "REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/agu-intensity2.png", "REPEAT")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/furyspark.png")
    self.animator:SetScript("OnUpdate", function(_, delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(1)
    self.scrollTexture2:SetAlpha(1)
    self.scrollTexture:SetBlendMode("ADD")

    self.spark:SetAlpha(1)
    self.scrollSpeedMultiplier = -5
end
local function setPowerTypeMeta(self, lightVersion)
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/fury.png")

    if lightVersion then return end
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/meta-intensity.png", "REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/meta-intensity2.png", "REPEAT")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/furyspark.png")
    self.animator:SetScript("OnUpdate", function(_, delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(1)
    self.scrollTexture2:SetAlpha(1)
    self.spark:SetAlpha(0.5)
    self.scrollSpeedMultiplier = 5
end
local function setPowerTypeStagger(self)
    self:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger.png")
    self.spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/furyspark.png")
    self.spark:SetAlpha(0.5)

    if GW.Retail then return end
    self.scrollTexture:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll.png", "REPEAT")
    self.scrollTexture2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-scroll2.png", "REPEAT")
    self.intensity:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-intensity.png")
    self.intensity2:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/stagger-intensity2.png")
    self.animator:SetScript("OnUpdate", function(_, delta) self:ScrollTextureParalaxOnUpdate(delta) end)
    self.scrollTexture:SetAlpha(0)
    self.scrollTexture2:SetAlpha(0)

    self.scrollSpeedMultiplier = -1
    self.onUpdateAnimation = AnimationStagger
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

local getAuraDataSearchIDs = {} -- reused scratch (never returned), refilled per call
local function GetAuraData(unit, unitSource, filter, ...)
    local searchIDs = wipe(getAuraDataSearchIDs)
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

-- AURA TRACKER (Retail): AuraContainer per spec feature whose single button carries a
-- GW-styled decay bar (and optionally a stack counter) driven engine-side. This works
-- even while aura values are secret — see GW.CreateAuraTrackerContainer. Trackers are
-- created lazily on first spec activation and toggled on spec switches; the container
-- shows/hides the bar automatically depending on whether the tracked aura is present.
local function EnableAuraTracker(f, key, config)
    f.gwAuraTrackers = f.gwAuraTrackers or {}
    local tracker = f.gwAuraTrackers[key]
    if not tracker then
        config.name = "GwClassPowerTracker" .. key
        config.parent = f
        tracker = GW.CreateAuraTrackerContainer(config)
        f.gwAuraTrackers[key] = tracker
    else
        -- re-apply the tracked spells — conditional includes (e.g. talent based
        -- entries like Last Stand with Bolster) may have changed since creation
        tracker:SetAuraGroupCandidateFilters("tracker", { includeSpellIDs = config.spellIDs })
    end
    tracker.gwConfiguredWidth = config.width or 1
    tracker:Show()
    tracker:SetEnabled(true)
    tracker:UpdateAllAuras()
    return tracker
end

local function DisableAuraTrackers(f)
    if not f.gwAuraTrackers then return end
    for _, tracker in pairs(f.gwAuraTrackers) do
        tracker:SetEnabled(false)
        -- disabled containers keep their last button state — hide the whole tracker
        tracker:Hide()
    end
end

-- Builds the tracker display as children of the (forbidden) aura button — inbound
-- widgets must be descendants of the button. GW status bar look with the spec's
-- bar texture; the spark rides on the fill edge and follows the engine-driven timer.
-- withTimer: countdown text centered on the bar; withCounter: big stack count at the
-- right edge (empty below 2 applications) — both are driven engine-side.
local function BuildTrackerBarWidgets(button, texture, sparkTexture, withCounter, withTimer)
    local bar = CreateFrame("StatusBar", nil, button, "GwStatusBarBackground")
    bar:SetAllPoints(button)
    bar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/bartextures/" .. texture .. ".png")

    local spark = bar:CreateTexture(nil, "OVERLAY", nil, 3)
    spark:SetTexture("Interface/Addons/GW2_UI/textures/bartextures/" .. (sparkTexture or "spark") .. ".png")
    spark:SetSize(3, 14)
    spark:SetAlpha(0.5)
    spark:SetPoint("RIGHT", bar:GetStatusBarTexture(), "RIGHT", 0, 0)

    local widgets = { durationBar = bar }
    if withTimer then
        local timer = bar:CreateFontString(nil, "OVERLAY")
        timer:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
        timer:SetJustifyH("CENTER")
        timer:SetPoint("CENTER", bar, "CENTER", 0, 0)
        widgets.durationText = timer
    end
    if withCounter then
        -- floats above the right end of the bar — next to it it would sit right on
        -- top of the action bar icons and become unreadable
        local count = bar:CreateFontString(nil, "OVERLAY")
        count:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, "OUTLINE", 6)
        count:SetJustifyH("CENTER")
        count:SetPoint("BOTTOM", bar, "TOPRIGHT", 14, 4)
        widgets.counterText = count
    end
    return widgets
end

-- MANA (multi class use)
local function powerMana(self, event, ...)
    local ptype = select(2, ...)
    if event == "CLASS_POWER_INIT" or ptype == "MANA" then
        if GW.Retail then
            self.exbarSecret:UpdatePowerData(0, ptype)
        else
            self.exbar:UpdatePowerData(0, ptype)
        end

        C_Timer.After(0.12, function()
            if GwPlayerPowerBar and GwPlayerPowerBar.powerType == 0 then
                self.exbar:Hide()
                self.exbar.decay:Hide()
                self.exbarSecret:Hide()
            else
                if self.barType == "mana" then
                    if GW.Retail then
                        self.exbarSecret:Show()
                    else
                        self.exbar:Show()
                        self.exbar.decay:Show()
                    end
                end
            end
        end)
    end
end

local function powerLittleMana(self, event, ...)
    local ptype = select(2, ...)
    if event == "CLASS_POWER_INIT" or ptype == "MANA" then
        if GW.Retail then
            self:GetParent().lmbSecret:UpdatePowerData(0, "MANA")
        else
            self:GetParent().lmb:UpdatePowerData(0, "MANA")
        end
    end
end

local function setManaBar(f)
    f.barType = "mana"
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    if GW.Retail then
        f.exbarSecret:Show()
    else
        f.exbar:Show()
    end
    f:SetHeight(14)

    local yOfs = 0
    if CP.GetAnchorMode() == "DEFAULT" then
        yOfs = (GW.settings.XPBAR_ENABLED or f.isMoved) and -13 or -3
    end
    SetClassPowerAnchor(f, f.gwMover, "TOPLEFT", 0, yOfs)

    f:SetScript("OnEvent", powerMana)
    C_Timer.After(0.5, function() powerMana(f, "CLASS_POWER_INIT") end)
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end

local function setLittleManaBar(f, barType)
    f.barType = barType -- used in druid feral form and evoker ebon might bar
    if GW.Retail then
        f.lmbSecret:Show()
    else
        f.lmb:Show()
        f.lmb.decay:Show()
    end

    f.littleManaBarEventFrame:SetScript("OnEvent", powerLittleMana)
    powerLittleMana(f.littleManaBarEventFrame, "CLASS_POWER_INIT")
    f.littleManaBarEventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f.littleManaBarEventFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end


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

    local slotsToAnchor = self.showExtraPoint or pwrMax
    if slotsToAnchor and slotsToAnchor > 0 then
        local comboWidth = slotsToAnchor * 32
        self.combopoints:SetWidth(comboWidth)
        self:SetWidth(comboWidth)
        SetClassPowerAnchor(self.combopoints, self, "LEFT")
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

local function setComboBar(f)
    SetClassPowerAnchor(f, f.gwMover, "TOPLEFT")
    f.barType = "combo"
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f.combopoints:SetWidth(9 * 32)
    f:SetWidth(f.combopoints:GetWidth())
    f:SetHeight(32)
    SetClassPowerAnchor(f.combopoints, f, "LEFT")
    f.combopoints:Show()

    f:SetScript("OnEvent", powerCombo)
    powerCombo(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
end

CP.HandleUnitAuraEvent = HandleUnitAuraEvent
CP.UpdateAlphaFader = UpdateAlphaFader
CP.UpdateVisibility = UpdateVisibility
CP.GetClassPowerCustomResourceBarGap = GetClassPowerCustomResourceBarGap
CP.SetClassPowerAnchor = SetClassPowerAnchor
CP.SetClassPowerCustomResourceBarAnchor = SetClassPowerCustomResourceBarAnchor
CP.setPowerTypePaladinShield = setPowerTypePaladinShield
CP.setPowerTypeEbonMight = setPowerTypeEbonMight
CP.setPowerTypeMeta = setPowerTypeMeta
CP.setPowerTypeStagger = setPowerTypeStagger
CP.animFlarePoint = animFlarePoint
CP.animFlare = animFlare
CP.GetAuraData = GetAuraData
CP.EnableAuraTracker = EnableAuraTracker
CP.DisableAuraTrackers = DisableAuraTrackers
CP.BuildTrackerBarWidgets = BuildTrackerBarWidgets
CP.setManaBar = setManaBar
CP.setLittleManaBar = setLittleManaBar
CP.setComboBar = setComboBar
