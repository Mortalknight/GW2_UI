local _, GW = ...
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local TimeCount = GW.TimeCount
local GWGetClassColor = GW.GWGetClassColor
local TARGET_FRAME_ART = GW.TARGET_FRAME_ART
local RegisterMovableFrame = GW.RegisterMovableFrame
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local AddToClique = GW.AddToClique
local IsIn = GW.IsIn
local RoundDec = GW.RoundDec
local LoadAuras = GW.LoadAuras
local PopulateUnitIlvlsCache = GW.PopulateUnitIlvlsCache

local fctf


local function CreateUnitFrame(name, revert)
    local f = CreateFrame("Button", name, UIParent, revert and "GwNormalUnitFrameInvert" or "GwNormalUnitFrame")

    local hg = f.healthContainer
    f.absorbOverlay = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay
    f.antiHeal      = hg.healPrediction.absorbbg.health.antiHeal
    f.health        = hg.healPrediction.absorbbg.health
    f.absorbbg      = hg.healPrediction.absorbbg
    f.healPrediction= hg.healPrediction
    f.healthString  = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.healthString

    GW.hookStatusbarBehaviour(f.absorbOverlay, true)
    GW.hookStatusbarBehaviour(f.antiHeal, true)
    GW.hookStatusbarBehaviour(f.health, true)
    GW.hookStatusbarBehaviour(f.absorbbg, true)
    GW.hookStatusbarBehaviour(f.healPrediction, false)
    GW.hookStatusbarBehaviour(f.castingbarNormal, false)
    GW.hookStatusbarBehaviour(f.powerbar, true)

    local elements = { f.absorbOverlay, f.antiHeal, f.health, f.absorbbg, f.healPrediction, f.castingbarNormal, f.powerbar }
    for _, element in ipairs(elements) do
        element.customMaskSize = 64
    end

    f.absorbOverlay:SetStatusBarColor(1, 1, 1, 0.66)
    f.absorbbg:SetStatusBarColor(1, 1, 1, 0.66)
    f.healPrediction:SetStatusBarColor(0.58431, 0.9372, 0.2980, 0.60)

    f.frameInvert = revert

    if revert then
        f.healthString:ClearAllPoints()
        f.healthString:SetPoint("RIGHT", f.absorbOverlay, "RIGHT", -5, 0)
        f.healthString:SetJustifyH("RIGHT")
        local reverseElements = { f.absorbOverlay, f.antiHeal, f.health, f.absorbbg, f.healPrediction, f.powerbar, f.castingbarNormal }
        for _, bar in ipairs(reverseElements) do
            bar:SetReverseFill(true)
        end
        f.castingbarNormal.internalBar:SetTexCoord(1, 0, 0, 1)
        f.castingbarSpark:SetTexCoord(1, 0, 0, 1)
    end

    f.healthString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    f.healthString:SetShadowOffset(1, -1)
    f.nameString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    f.nameString:SetShadowOffset(1, -1)
    f.threatString:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.TextSizeType.SMALL)
    f.threatString:SetShadowOffset(1, -1)
    f.levelString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    f.levelString:SetShadowOffset(1, -1)
    f.castingString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    f.castingString:SetShadowOffset(1, -1)
    f.castingbarNormal.castingString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    f.castingbarNormal.castingString:SetShadowOffset(1, -1)
    f.castingbarNormal.castingTimeString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    f.castingbarNormal.castingTimeString:SetShadowOffset(1, -1)
    f.castingTimeString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    f.castingTimeString:SetShadowOffset(1, -1)
    f.prestigeString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    f.prestigebg:SetPoint("CENTER", f.prestigeString, "CENTER", -1, 1)

    f.healthValue = 0
    f.barWidth = 214

    f:SetScript("OnEnter", f.OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    return f
end
GW.CreateUnitFrame = CreateUnitFrame

local function CreateSmallUnitFrame(name)
    local f = CreateFrame("Button", name, UIParent, "GwNormalUnitFrameSmall")

    local hg = f.healthContainer
    f.absorbOverlay = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay
    f.antiHeal      = hg.healPrediction.absorbbg.health.antiHeal
    f.health        = hg.healPrediction.absorbbg.health
    f.absorbbg      = hg.healPrediction.absorbbg
    f.healPrediction= hg.healPrediction
    f.healthString  = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.healthString

    GW.hookStatusbarBehaviour(f.absorbOverlay, true)
    GW.hookStatusbarBehaviour(f.antiHeal, true)
    GW.hookStatusbarBehaviour(f.health, true)
    GW.hookStatusbarBehaviour(f.absorbbg, true)
    GW.hookStatusbarBehaviour(f.healPrediction, false)
    GW.hookStatusbarBehaviour(f.castingbarNormal, false)
    GW.hookStatusbarBehaviour(f.powerbar, true)

    local elements = { f.absorbOverlay, f.antiHeal, f.health, f.absorbbg, f.healPrediction, f.castingbarNormal, f.powerbar }
    for _, element in ipairs(elements) do
        element.customMaskSize = 64
    end

    f.absorbOverlay:SetStatusBarColor(1, 1, 1, 0.66)
    f.absorbbg:SetStatusBarColor(1, 1, 1, 0.66)
    f.healPrediction:SetStatusBarColor(0.58431, 0.9372, 0.2980, 0.60)

    f.healthString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    f.healthString:SetShadowOffset(1, -1)
    f.nameString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    f.nameString:SetShadowOffset(1, -1)
    f.levelString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    f.levelString:SetShadowOffset(1, -1)
    f.castingString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    f.castingString:SetShadowOffset(1, -1)
    f.castingbarNormal.castingString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    f.castingbarNormal.castingString:SetShadowOffset(1, -1)
    f.castingbarNormal.castingTimeString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    f.castingbarNormal.castingTimeString:SetShadowOffset(1, -1)

    f.healthValue = 0
    f.barWidth = 149

    f:SetScript("OnEnter", f.OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    return f
end

GwUnitFrameMixin = {}

function GwUnitFrameMixin:OnEnter()
    if self.unit then
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(self.unit)
        GameTooltip:Show()
    end
end

function GwUnitFrameMixin:UpdateHealthbarColor()
    local unit = self.unit
    local healthBar = self.health
    local nameString = self.nameString

    if self.classColor and (UnitIsPlayer(unit) or UnitInPartyIsAI(unit)) then
        local _, englishClass = UnitClass(unit)
        local color = GWGetClassColor(englishClass, true)
        healthBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
        nameString:SetTextColor(color.r + 0.3, color.g + 0.3, color.b + 0.3, color.a)
    else
        local unitReaction = UnitReaction(unit, "player")
        local nameColor = unitReaction and GW.FACTION_BAR_COLORS[unitReaction] or RAID_CLASS_COLORS.PRIEST
        if unitReaction then
            if unitReaction <= 3 then
                nameColor = COLOR_FRIENDLY[2]
            elseif unitReaction >= 5 then
                nameColor = COLOR_FRIENDLY[1]
            end
        end

        if UnitIsTapDenied(unit) then
            nameColor = { r = 159 / 255, g = 159 / 255, b = 159 / 255 }
        end

        healthBar:SetStatusBarColor(nameColor.r, nameColor.g, nameColor.b, 1)
        nameString:SetTextColor(nameColor.r, nameColor.g, nameColor.b, 1)
    end

    if (UnitLevel(unit) - GW.mylevel) <= -5 then
        local r, g, b = nameString:GetTextColor()
        nameString:SetTextColor(r + 0.5, g + 0.5, b + 0.5, 1)
    end
end

function GwUnitFrameMixin:SetUnitPortraitFrame()
    if not self.portrait or not self.background then return end

    local unit = self.unit
    local border = "normal"
    local txt
    local unitLevel = UnitLevel(unit)
    local unitClassification = UnitClassification(unit)
    local canInspect = CanInspect(unit)

    if TARGET_FRAME_ART[unitClassification] then
        border = unitClassification
        if unitLevel == -1 then border = "boss" end
    end

    if canInspect then
        if self.showItemLevel == "ITEM_LEVEL" then
            local guid = UnitGUID(self.unit)
            if guid then
                local cachedIlvl = GW.unitIlvlsCache[guid]
                if cachedIlvl and cachedIlvl.itemLevel then
                    txt = RoundDec(cachedIlvl.itemLevel, 0)
                end
            end
        elseif self.showItemLevel == "PVP_LEVEL" then
            local honorLevel = UnitHonorLevel(unit) or 0
            local prestigeLevel = (honorLevel > 199 and 4) or (honorLevel > 99 and 3) or
                                  (honorLevel > 49 and 2) or (honorLevel > 9 and 1) or 0


            if prestigeLevel > 0 and TARGET_FRAME_ART["prestige" .. prestigeLevel] then
                border = "prestige" .. prestigeLevel
            end
            txt = honorLevel
        end
    end

    if txt then
        self.prestigebg:Show()
        self.prestigeString:Show()
        self.prestigeString:SetText(txt)
    else
        self.prestigebg:Hide()
        self.prestigeString:Hide()
    end

    --if DBM or BigWigs is load, check if target is a boss and set boss frame
    local foundBossMod = false
    if DBM and DBM.ModLists then
        local npcId = GW.GetUnitCreatureId(unit)
        if npcId ~= nil then
            for _, mods in pairs(DBM.ModLists) do
                for _, id in ipairs(mods) do
                    local mod = DBM:GetModByName(id)
                    if mod and mod.creatureId == npcId then
                        foundBossMod = true
                        break
                    end
                end
                if foundBossMod then
                    break
                end
            end
        end
    elseif BigWigs then
        local npcId = GW.GetUnitCreatureId(unit)
        if npcId ~= nil then
            for _, module in BigWigs:IterateBossModules() do
                if module.enableMobs[npcId] then
                    foundBossMod = true
                    break
                end
            end
        end
    end
    if foundBossMod then
        border = (border == "boss") and "realboss" or "boss"
    end

    self.background:SetTexture(TARGET_FRAME_ART[border])
end

function GwUnitFrameMixin:UpdateAvgItemLevel(guid)
    if guid ~= UnitGUID(self.unit) or not CanInspect(self.unit) then return end

    local itemLevel, retryUnit, retryTable, iLevelDB = GW.GetUnitItemLevel(self.unit)

    if itemLevel == "tooSoon" then
        C_Timer.After(0.05, function()
            local canUpdate = true

            for _, slot in ipairs(retryTable) do
                local slotInfo = GW.GetGearSlotInfo(retryUnit, slot)
                if slotInfo == "tooSoon" then
                    canUpdate = false
                    break
                end
                iLevelDB[slot] = slotInfo.iLvl
            end

            if canUpdate then
                local calculatedIlvl = GW.CalculateAverageItemLevel(iLevelDB, retryUnit)
                PopulateUnitIlvlsCache(guid, calculatedIlvl)
                ClearInspectPlayer()
                self:UnregisterEvent("INSPECT_READY")
                self:SetUnitPortraitFrame()
            end
        end)
    else
        PopulateUnitIlvlsCache(guid, itemLevel)
        self:UnregisterEvent("INSPECT_READY")
        self:SetUnitPortraitFrame()
    end
end

function GwUnitFrameMixin:UpdateRaidMarkers()
    local i = GetRaidTargetIndex(self.unit)
    if i == nil then
        self.raidmarker:SetTexture(nil)
        return
    end
    self.raidmarker:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_" .. i)
end

function GwUnitFrameMixin:SetUnitPortrait()
    SetPortraitTexture(self.portrait, self.unit)
    if self.frameInvert then
        self.portrait:SetTexCoord(1, 0, 0, 1)
    end
    self.activePortrait = nil
end

function GwUnitFrameMixin:UnitFrameData(lvl)
    local level = lvl or UnitLevel(self.unit)
    local name = UnitName(self.unit)

    if UnitIsGroupLeader(self.unit) then
        name = "|TInterface/AddOns/GW2_UI/textures/party/icon-groupleader:18:18|t" .. name
    end

    self.nameString:SetText(name)
    self.levelString:SetText((level == -1 and "??" or level))

    if self.unit == "player" and self.classColor and UnitIsPlayer(self.unit) then
        local _, englishClass = UnitClass(self.unit)
        local color = GW.GWGetClassColor(englishClass, true)

        self.health:SetStatusBarColor(color.r, color.g, color.b, color.a)
        self.nameString:SetTextColor(math.min(color.r + 0.3, 1), math.min(color.g + 0.3, 1), math.min(color.b + 0.3, 1), color.a)

        SetPortraitTexture(self.portrait, self.unit)
    else
        self:UpdateHealthbarColor()
    end

    self:SetUnitPortraitFrame()
end

function GwUnitFrameMixin:SelectPvp()
    local prevFlag = self.pvp.pvpFlag
    if GW.settings.PLAYER_SHOW_PVP_INDICATOR and (C_PvP.IsWarModeDesired() or GetPVPDesired() or UnitIsPVP("player") or UnitIsPVPFreeForAll("player")) then
        self.pvp.pvpFlag = true
        if prevFlag ~= true then
            if GW.myfaction == "Horde" then
                self.pvp.ally:Hide()
                self.pvp.horde:Show()
            else
                self.pvp.ally:Show()
                self.pvp.horde:Hide()
            end
        end
    else
        self.pvp.pvpFlag = false
        self.pvp.ally:Hide()
        self.pvp.horde:Hide()
    end
end

function GwUnitFrameMixin:NormalCastBarAnimation(powerPrec)
    self.castingbarNormal:SetFillAmount(powerPrec)
end

function GwUnitFrameMixin:ProtectedCastAnimation(powerPrec)
    local powerBarWidth = self.barWidth
    local bit = powerBarWidth / 16
    local spark = bit * math.floor(16 * (powerPrec))
    local segment = math.floor(16 * (powerPrec))
    local sparkPoint = (powerBarWidth * powerPrec) - 20

    self.castingbarSpark:SetWidth(math.min(32, 32 * (powerPrec / 0.10)))
    if self.frameInvert then
        self.castingbarSpark:SetPoint("RIGHT", self.castingbar, "RIGHT", -math.max(0, sparkPoint), 0)
        self.castingbar:SetTexCoord(math.min(1, math.max(0, 0.0625 * segment)), 0, 0, 1)
        self.castingbar:SetWidth(-math.min(powerBarWidth, math.max(1, spark)))
    else
        self.castingbarSpark:SetPoint("LEFT", self.castingbar, "LEFT", math.max(0, sparkPoint), 0)
        self.castingbar:SetTexCoord(0, math.min(1, math.max(0, 0.0625 * segment)), 0, 1)
        self.castingbar:SetWidth(math.min(powerBarWidth, math.max(1, spark)))
    end
end

function GwUnitFrameMixin:HideCastBar()
    local pb = self.powerbar
    local castBG = self.castingbarBackground
    if castBG then
        castBG:Hide()
        castBG:ClearAllPoints()
        castBG:SetPoint("TOPLEFT", pb, "BOTTOMLEFT", (self.type == "NormalTarget") and -2 or 0, 19)
    end

    if self.castingString then self.castingString:Hide() end
    if self.highlight then self.highlight:Hide() end
    if self.castingTimeString then self.castingTimeString:Hide() end
    if self.castingbar then self.castingbar:Hide() end
    if self.castingbarSpark then self.castingbarSpark:Hide() end
    if self.castingbarNormal then self.castingbarNormal:Hide() end

    GW.ClearStages(self)

    if self.portrait then
        self:SetUnitPortrait()
    end

    local animKey = "GwUnitFrame" .. self.unit .. "Cast"
    local anim = animations[animKey]
    if anim then
        anim.completed = true
        anim.duration = 0
    end
end

function GwUnitFrameMixin:UpdateCastValues()
    local numStages = 0
    local barTexture = GW.CASTINGBAR_TEXTURES.YELLOW.NORMAL
    local barHighlightTexture = GW.CASTINGBAR_TEXTURES.YELLOW.HIGHLIGHT

    local isCasting, isChanneling, reverseChanneling = true, false, false

    local name, _, texture, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(self.unit)

    if not name then
        name, _, texture, startTime, endTime, _, notInterruptible, _, _, numStages = UnitChannelInfo(self.unit)
        isCasting, isChanneling, reverseChanneling = false, true, false
        barTexture = GW.CASTINGBAR_TEXTURES.GREEN.NORMAL
        barHighlightTexture = GW.CASTINGBAR_TEXTURES.GREEN.HIGHLIGHT
    end

    local isChargeSpell = numStages and numStages > 0 or false

    if isChargeSpell then
        endTime = endTime + GetUnitEmpowerHoldAtMaxTime(self.unit)
        isCasting, isChanneling, reverseChanneling = true, false, true
    end

    if not name or not self.showCastbar then
        self:HideCastBar()
        return
    end

    self.isCasting = isCasting
    self.isChanneling = isChanneling
    self.reverseChanneling = reverseChanneling
    self.barCoords = barTexture
    self.barHighLightCoords = barHighlightTexture
    self.numStages = numStages and (numStages + 1) or 0
    self.maxValue = (endTime - startTime) / 1000
    startTime, endTime = startTime / 1000, endTime / 1000

    if texture and self.portrait and self.activePortrait ~= texture then
        self.portrait:SetTexture(texture)
        self.activePortrait = texture
        if self.frameInvert then
            self.portrait:SetTexCoord(1, 0, 0, 1)
        else
            self.portrait:SetTexCoord(0, 1, 0, 1)
        end
    end

    local cbBackground = self.castingbarBackground
    cbBackground:Show()
    cbBackground:ClearAllPoints()
    cbBackground:SetPoint("TOPLEFT", self.powerbar, "BOTTOMLEFT", (self.type == "NormalTarget") and -2 or 0, -1)

    self.castingString:Show()
    if self.castingTimeString then
        self.castingTimeString:Show()
    end

    if notInterruptible then
        self.castingString:SetText(name)
        self.castingbarNormal:Hide()
        self.castingbar:Show()
        self.castingbarSpark:Show()
    else
        self.castingbarNormal.castingString:SetText(name)
        self.castingString:Hide()
        if self.castingTimeString then self.castingTimeString:Hide() end
        self.castingbar:Hide()
        self.castingbarSpark:Hide()
        self.castingbarNormal:Show()
    end

    if reverseChanneling then
        GW.AddStages(self, cbBackground, self.barWidth)
    else
        GW.ClearStages(self)
    end

    AddToAnimation(
        "GwUnitFrame" .. self.unit .. "Cast",
        0,
        1,
        startTime,
        endTime - startTime,
        function(p)
            if self.showCastingbarData and self.castingTimeString then
              if notInterruptible then
                  self.castingTimeString:SetText(TimeCount(endTime - GetTime(), true))
              else
                  self.castingbarNormal.castingTimeString:SetText(TimeCount(endTime - GetTime(), true))
              end

            end
            p = self.isChanneling and (1 - p) or p

            if notInterruptible then
                self:ProtectedCastAnimation(p)
            else
                self:NormalCastBarAnimation(p)
            end
        end,
        "noease"
    )
end

local function updateThreatValues(self)
    self.threatValue = select(3, UnitDetailedThreatSituation("player", self.unit))

    if self.threatValue == nil then
        self.threatString:SetText("")
        self.threattabbg:SetAlpha(0.0)
    else
        self.threatString:SetText(RoundDec(self.threatValue, 0) .. "%")
        self.threattabbg:SetAlpha(1.0)
    end
end
GW.AddForProfiling("unitframes", "updateThreatValues", updateThreatValues)

function GwUnitFrameMixin:OnEvent(event, unit, ...)
    local secondaryFrame
    if self.unit == "target" then
        secondaryFrame = GwTargetTargetUnitFrame
    elseif self.unit == "focus" then
        secondaryFrame = GwFocusTargetUnitFrame
    end

    if IsIn(event, "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED", "PLAYER_ENTERING_WORLD", "FORCE_UPDATE") then
        if event == "PLAYER_TARGET_CHANGED" and self.unit == "target" and CanInspect(self.unit) and
            (self.showItemLevel == "PVP_LEVEL" or self.showItemLevel == "ITEM_LEVEL") then
            local guid = UnitGUID(self.unit)
            if guid and (not GW.unitIlvlsCache[guid] or (GW.unitIlvlsCache[guid] and GW.unitIlvlsCache[guid].itemLevel == nil)) then
                local _, englishClass = UnitClass(self.unit)
                local color = GWGetClassColor(englishClass, true, true)
                GW.unitIlvlsCache[guid] = {unitColor = {color.r, color.g, color.b}}
                self:RegisterEvent("INSPECT_READY")
                NotifyInspect(self.unit)
            end
        end

        if self.showThreat then
            updateThreatValues(self)
        elseif self.threattabbg and self.threattabbg:IsShown() then
            self.threattabbg:Hide()
        end

        if event == "PLAYER_ENTERING_WORLD" and self.unit == "target" then
            wipe(GW.unitIlvlsCache)
        end

        self:UnitFrameData()
        if secondaryFrame then secondaryFrame:UnitFrameData() end
        self:UpdateHealthBar(true)
        if secondaryFrame then secondaryFrame:UpdateHealthBar(true) end

        if IsIn(event, "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED") then
            self:UpdatePowerBar(true)
            if secondaryFrame then  secondaryFrame:UpdatePowerBar(true) end
        else
            self:UpdatePowerBar()
            if secondaryFrame then secondaryFrame:UpdatePowerBar() end
        end

        self:UpdateCastValues()
        if secondaryFrame then secondaryFrame:UpdateCastValues() end
        self:UpdateRaidMarkers()
        if secondaryFrame then secondaryFrame:UpdateRaidMarkers() end

        self.auras:ForceUpdate()

        if IsIn(event, "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED") then
            if UnitExists(self.unit) and not C_PlayerInteractionManager.IsReplacingUnit() then
                if UnitIsEnemy(self.unit, "player") then
                    PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
                elseif UnitIsFriend("player", self.unit) then
                    PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT)
                else
                    PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
                end
            else
                PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
            end
        end
    elseif event == "UNIT_TARGET" then
        if unit == self.unit and secondaryFrame then
            local targetUnit = self.unit .. "target"  -- "targettarget" or "focustarget"
            if UnitExists(targetUnit) then
                secondaryFrame:UnitFrameData()
                secondaryFrame:UpdateHealthBar(true)
                secondaryFrame:UpdatePowerBar(true)
                secondaryFrame:UpdateCastValues()
                secondaryFrame:UpdateRaidMarkers()
            end
        end
    elseif event == "RAID_TARGET_UPDATE" then
        self:UpdateRaidMarkers()
        if secondaryFrame then secondaryFrame:UpdateRaidMarkers() end
    elseif event == "INSPECT_READY" then
        if self.unit == "target" then
            if self.showItemLevel == "NONE" then
                self:UnregisterEvent("INSPECT_READY")
            else
                self:UpdateAvgItemLevel(unit) -- with this event the unit is a guid
            end
        end
    elseif event == "UNIT_THREAT_LIST_UPDATE" and self.showThreat then
        updateThreatValues(self)
    elseif UnitIsUnit(unit, self.unit) then
        if event == "UNIT_AURA" then
            GW.UpdateBuffLayout(self, event, unit, ...)
        elseif IsIn(event, "UNIT_MAXHEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEALTH", "UNIT_HEAL_PREDICTION") then
            self:UpdateHealthBar()
        elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT") then
            self:UpdatePowerBar()
        elseif IsIn(event, "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_EMPOWER_START") then
            self:UpdateCastValues()
        elseif IsIn(event, "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_EMPOWER_STOP") then
            self:HideCastBar()
        elseif event == "UNIT_FACTION" then
            self:UpdateHealthbarColor()
        end
    end
end

function GwUnitFrameMixin:ToggleSettings()
    local unit = self.unit:lower()

    self.classColor = GW.settings[unit .. "_CLASS_COLOR"]
    self.showHealthValue = GW.settings[unit .. "_HEALTH_VALUE_ENABLED"]
    self.showHealthPrecentage = GW.settings[unit .. "_HEALTH_VALUE_TYPE"]
    self.showCastbar = GW.settings[unit .. "_SHOW_CASTBAR"]

    self.showCastingbarData = GW.settings[unit .. "_CASTINGBAR_DATA"]

    self.displayBuffs = GW.settings[unit .. "_BUFFS"] and 32 or 0
    self.displayDebuffs = GW.settings[unit .. "_DEBUFFS"] and 40 or 0

    self.auras.smallSize = 20
    self.auras.bigSize = 26

    self.shortendHealthValues = GW.settings[unit .. "_SHORT_VALUES"]

    self.showItemLevel = GW.settings[unit .. "_ILVL"]

    if GW.settings[unit .. "_THREAT_VALUE_ENABLED"] ~= nil then
        self.showThreat = GW.settings[unit .. "_THREAT_VALUE_ENABLED"]
    end

    self.auraPositionTop = GW.settings[unit .. "_AURAS_ON_TOP"]

    self.altBg:SetShown(GW.settings[unit .. "_FRAME_ALT_BACKGROUND"])

    self.auras:ClearAllPoints()
    self.auras:SetPoint("TOPLEFT", self.castingbarBackground, "BOTTOMLEFT", 2, -15)

    if self.auraPositionTop then
        local yOff = GW.settings[unit .. "_FRAME_ALT_BACKGROUND"] and 22 or 17
        self.auras:ClearAllPoints()
        if self.frameInvert then
            self.auras:SetPoint("TOPRIGHT", self.nameString, "TOPRIGHT", -2, yOff)
        else
            self.auras:SetPoint("TOPLEFT", self.nameString, "TOPLEFT", 2, yOff)
        end
    elseif GW.settings[unit .. "_HOOK_COMBOPOINTS"] and (GW.myClassID == 4 or GW.myClassID == 11) then
        self.auras:ClearAllPoints()
        self.auras:SetPoint("TOPLEFT", self.castingbarBackground, "BOTTOMLEFT", 2, -23)
    end

    self.debuffFilter = GW.settings[unit .. "_BUFFS_FILTER_ALL"] and "HARMFUL" or "PLAYER|HARMFUL"
    self.debuffFilterShowImportant = GW.settings[unit .. "_BUFFS_FILTER_IMPORTANT"]

    self:OnEvent("FORCE_UPDATE")

    if GwPlayerClassPower then
        GW.UpdateClasspowerBar(GwPlayerClassPower.decay, "FORCE_UPDATE")
    end
end

function GwUnitFrameMixin:ToggleTargetFrameCombatFeedback()
    if GW.settings.target_FLOATING_COMBAT_TEXT then
        if not fctf then
            fctf = CreateFrame("Frame", nil, self)
            fctf:SetFrameLevel(self:GetFrameLevel() + 3)
            fctf:SetScript("OnEvent", function(frame, _, unit, ...)
                if frame.unit == unit then
                    CombatFeedback_OnCombatEvent(frame, ...)
                end
            end)
            local font = fctf:CreateFontString(nil, "OVERLAY")
            font:SetFont(DAMAGE_TEXT_FONT, 30, "")
            fctf.fontString = font
            font:SetPoint("CENTER", self.portrait, "CENTER")
            font:Hide()

            fctf.unit = self.unit
            CombatFeedback_Initialize(fctf, fctf.fontString, 30)
        end
        fctf:RegisterEvent("UNIT_COMBAT")
        fctf:SetScript("OnUpdate", CombatFeedback_OnUpdate)
    else
        if fctf then
            fctf:UnregisterAllEvents()
            fctf:SetScript("OnUpdate", nil)
        end
    end
end

local function LoadUnitFrame(unit, frameInvert)
    local unitframe = CreateUnitFrame("Gw" .. unit .."UnitFrame", frameInvert)
    unit = unit:lower()
    unitframe.unit = unit
    unitframe.type = "NormalTarget"

    LoadAuras(unitframe)

    RegisterMovableFrame(unitframe, unit == "target" and TARGET or FOCUS, unit .. "_pos", ALL .. ",Unitframe", nil, {"default", "scaleable"})

    unitframe:ClearAllPoints()
    unitframe:SetPoint("TOPLEFT", unitframe.gwMover)

    -- Porträt-Maske erstellen
    unitframe.portrait.mask = unitframe:CreateMaskTexture()
    unitframe.portrait.mask:SetPoint("CENTER", unitframe.portrait, "CENTER", 0, 0)
    unitframe.portrait.mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    unitframe.portrait.mask:SetSize(58, 58)
    unitframe.portrait:AddMaskTexture(unitframe.portrait.mask)

    unitframe.altBg = CreateFrame("Frame", nil, unitframe, "GwAlternativeUnitFrameBackground")
    unitframe.altBg:SetAllPoints(unitframe)
    if unitframe.frameInvert then
        unitframe.altBg.backgroundOverlay:SetTexCoord(1, 0, 0, 1)
        unitframe.altBg.backgroundOverlay:SetPoint("CENTER", -15, -5)
        unitframe.healthContainer:ClearAllPoints()
        unitframe.healthContainer:SetPoint("RIGHT", unitframe.healthbarBackground, "RIGHT", -1, 0)
    end

    unitframe.segments = {}
    unitframe.StagePoints = {}

    unitframe:SetAttribute("*type1", "target")
    unitframe:SetAttribute("*type2", "togglemenu")
    unitframe:SetAttribute("unit", unit)
    RegisterUnitWatch(unitframe)
    unitframe:EnableMouse(true)
    unitframe:RegisterForClicks("AnyDown")
    AddToClique(unitframe)

    unitframe:ToggleSettings()
    unitframe:SetScript("OnEvent", unitframe.OnEvent)

    unitframe:RegisterEvent("PLAYER_ENTERING_WORLD")
    unitframe:RegisterEvent("RAID_TARGET_UPDATE")
    unitframe:RegisterUnitEvent("UNIT_HEALTH", unit)
    unitframe:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    unitframe:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
    unitframe:RegisterUnitEvent("UNIT_TARGET", unit)
    unitframe:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
    unitframe:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    unitframe:RegisterUnitEvent("UNIT_AURA", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", unit)
    unitframe:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit)
        unitframe:RegisterUnitEvent("UNIT_FACTION", unit)
    if unit == "target" then
        unitframe:RegisterEvent("PLAYER_TARGET_CHANGED")
        unitframe:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit)
    elseif unit == "focus" then
        unitframe:RegisterEvent("PLAYER_FOCUS_CHANGED")
    end

    if unit == "target" then
        unitframe:ToggleTargetFrameCombatFeedback()
    end

    return unitframe
end
GW.LoadUnitFrame = LoadUnitFrame

GwTargetUnitFrameMixin = {}

function GwTargetUnitFrameMixin:OnUpdate(elapsed)
    if self.totalElapsed > 0 then
        self.totalElapsed = self.totalElapsed - elapsed
        return
    end
    self.totalElapsed = 0.25
    if not UnitExists(self.unit) then
        return
    end

    self:UpdateRaidMarkers()
    self:UpdateHealthBar(true)
    self:UpdatePowerBar(true)
    self:UpdateCastValues()
end

function GwTargetUnitFrameMixin:ToggleSettings()
    self.classColor = GW.settings[self.parentUnitId .. "_CLASS_COLOR"]
    self.classColor = GW.settings[self.parentUnitId .. "_TARGET_SHOW_CASTBAR"]

    self.altBg:SetShown(GW.settings[self.parentUnitId .. "_FRAME_ALT_BACKGROUND"])

    self.parentUnitFrame:OnEvent("FORCE_UPDATE")
end

function GwTargetUnitFrameMixin:ToggleUnitFrame()
    if GW.settings[self.parentUnitId .. "_TARGET_ENABLED"] then
        self:SetScript("OnUpdate", self.OnUpdate)
        RegisterUnitWatch(self)
    else
        self:SetScript("OnUpdate", nil)
        UnregisterUnitWatch(self)
        RegisterStateDriver(self, "visibility", "hide")
    end
end

local function LoadTargetOfUnit(unit, parentUnitFrame)
    local f = CreateSmallUnitFrame("Gw" .. unit .. "TargetUnitFrame")
    local unitID = unit:lower() .. "target"
    f.type = "SmallTarget"
    f.unit = unitID

    f.parentUnitFrame = parentUnitFrame
    f.parentUnitId = unit:lower()

    f.segments = {}
    f.StagePoints = {}

    RegisterMovableFrame(f, unit == "Focus" and MINIMAP_TRACKING_FOCUS or SHOW_TARGET_OF_TARGET_TEXT, unitID .. "_pos", ALL .. ",Unitframe", nil, {"default", "scaleable"})

    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", f.gwMover)

    f:SetAttribute("*type1", "target")
    f:SetAttribute("*type2", "togglemenu")
    f:SetAttribute("unit", unitID)
    f:EnableMouse(true)
    f:RegisterForClicks("AnyDown")

    f.altBg = CreateFrame("Frame", nil, f, "GwAlternativeUnitFrameBackground")
    f.altBg.backgroundOverlay:Hide()
    f.altBg.backgroundOverlaySmall:Show()
    f.altBg:SetAllPoints(f)

    AddToClique(f)

    f.showHealthValue = false
    f.showHealthPrecentage = false

    f:ToggleSettings()

    f.debuffFilter = nil

    f.totalElapsed = 0.15

    f:ToggleUnitFrame()
end
GW.LoadTargetOfUnit = LoadTargetOfUnit
