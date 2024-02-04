local _, GW = ...
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local TimeCount = GW.TimeCount
local CommaValue = GW.CommaValue
local PowerBarColorCustom = GW.PowerBarColorCustom
local bloodSpark = GW.BLOOD_SPARK
local GWGetClassColor = GW.GWGetClassColor
local TARGET_FRAME_ART = GW.TARGET_FRAME_ART
local RegisterMovableFrame = GW.RegisterMovableFrame
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local AddToClique = GW.AddToClique
local IsIn = GW.IsIn
local RoundDec = GW.RoundDec
local LoadAuras = GW.LoadAuras
local UpdateBuffLayout = GW.UpdateBuffLayout
local PopulateUnitIlvlsCache = GW.PopulateUnitIlvlsCache

local fctf

local function normalUnitFrame_OnEnter(self)
    if self.unit ~= nil then
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(self.unit)
        GameTooltip:Show()
    end
end
GW.AddForProfiling("unitframes", "normalUnitFrame_OnEnter", normalUnitFrame_OnEnter)

local function createNormalUnitFrame(ftype, revert)
    local f = CreateFrame("Button", ftype, UIParent, revert and "GwNormalUnitFrameInvert" or "GwNormalUnitFrame")
    local hg = f.healthContainer
    f.absorbOverlay = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay
    f.antiHeal = hg.healPrediction.absorbbg.health.antiHeal
    f.health = hg.healPrediction.absorbbg.health
    f.absorbbg = hg.healPrediction.absorbbg
    f.healPrediction = hg.healPrediction
    f.healthString = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.healthString

    --GwTargetUnitFrame.health:GetValue()
    GW.hookStatusbarBehaviour(f.absorbOverlay,true)
    GW.hookStatusbarBehaviour(f.antiHeal,true)
    GW.hookStatusbarBehaviour(f.health, true, nil)
    GW.hookStatusbarBehaviour(f.absorbbg,true)
    GW.hookStatusbarBehaviour(f.healPrediction,false)
    GW.hookStatusbarBehaviour(f.castingbarNormal,false)
    GW.hookStatusbarBehaviour(f.powerbar,true)

    f.absorbOverlay.customMaskSize = 64
    f.antiHeal.customMaskSize = 64
    f.health.customMaskSize = 64
    f.absorbbg.customMaskSize = 64
    f.healPrediction.customMaskSize = 64
    f.castingbarNormal.customMaskSize = 64
    f.powerbar.customMaskSize = 64

    f.absorbOverlay:SetStatusBarColor(1,1,1,0.66)
    f.absorbbg:SetStatusBarColor(1,1,1,0.66)
    f.healPrediction:SetStatusBarColor(0.58431,0.9372,0.2980,0.60)


    f.frameInvert = revert

    if revert then
        f.healthString:ClearAllPoints()
        f.healthString:SetPoint("RIGHT", f.absorbOverlay, "RIGHT", -5, 0)
        f.healthString:SetJustifyH("RIGHT")

        --f.absorbOverlay:SetReverseFill(true)
        --f.antiHeal:SetReverseFill(true)
        --f.health:SetReverseFill(true)
        --f.absorbbg:SetReverseFill(true)
        --f.healPrediction:SetReverseFill(true)
        --f.powerbar:SetReverseFill(true)
    end

    f.healthString:SetFont(UNIT_NAME_FONT, 11)
    f.healthString:SetShadowOffset(1, -1)

    if GW.settings.FONTS_ENABLED then -- for any reason blizzard is not supporting UTF8 if we set this font
        f.nameString:SetFont(UNIT_NAME_FONT, 14)
    end
    f.nameString:SetShadowOffset(1, -1)

    f.threatString:SetFont(STANDARD_TEXT_FONT, 11)
    f.threatString:SetShadowOffset(1, -1)

    f.levelString:SetFont(UNIT_NAME_FONT, 14)
    f.levelString:SetShadowOffset(1, -1)

    f.castingString:SetFont(UNIT_NAME_FONT, 12)
    f.castingString:SetShadowOffset(1, -1)

    f.castingbarNormal.castingString:SetFont(UNIT_NAME_FONT, 12)
    f.castingbarNormal.castingString:SetShadowOffset(1, -1)

    f.castingbarNormal.castingTimeString:SetFont(UNIT_NAME_FONT, 12)
    f.castingbarNormal.castingTimeString:SetShadowOffset(1, -1)

    f.castingTimeString:SetFont(UNIT_NAME_FONT, 12)
    f.castingTimeString:SetShadowOffset(1, -1)

    f.prestigeString:SetFont(UNIT_NAME_FONT, 12, "OUTLINED")

    f.prestigebg:SetPoint("CENTER", f.prestigeString, "CENTER", -1, 1)

    f.healthValue = 0

    f.barWidth = 214

    f:SetScript("OnEnter", normalUnitFrame_OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    return f
end
GW.createNormalUnitFrame = createNormalUnitFrame
GW.AddForProfiling("unitframes", "createNormalUnitFrame", createNormalUnitFrame)

local function createNormalUnitFrameSmall(ftype)
    local f = CreateFrame("Button", ftype, UIParent, "GwNormalUnitFrameSmall")
    local hg = f.healthContainer
    f.absorbOverlay = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay
    f.antiHeal = hg.healPrediction.absorbbg.health.antiHeal
    f.health = hg.healPrediction.absorbbg.health
    f.absorbbg = hg.healPrediction.absorbbg
    f.healPrediction = hg.healPrediction
    f.healthString = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.healthString


    GW.hookStatusbarBehaviour(f.absorbOverlay,true)
    GW.hookStatusbarBehaviour(f.antiHeal,true)
    GW.hookStatusbarBehaviour(f.health,true)
    GW.hookStatusbarBehaviour(f.absorbbg,true)
    GW.hookStatusbarBehaviour(f.healPrediction,false)
    GW.hookStatusbarBehaviour(f.castingbarNormal,false)
    GW.hookStatusbarBehaviour(f.powerbar,true)

    f.absorbOverlay.customMaskSize = 64
    f.antiHeal.customMaskSize = 64
    f.health.customMaskSize = 64
    f.absorbbg.customMaskSize = 64
    f.healPrediction.customMaskSize = 64
    f.castingbarNormal.customMaskSize = 64
    f.powerbar.customMaskSize = 64

    f.absorbOverlay:SetStatusBarColor(1,1,1,0.66)
    f.absorbbg:SetStatusBarColor(1,1,1,0.66)
    f.healPrediction:SetStatusBarColor(0.58431,0.9372,0.2980,0.60)


    f.healthString:SetFont(UNIT_NAME_FONT, 11)
    f.healthString:SetShadowOffset(1, -1)

    if GW.settings.FONTS_ENABLED then -- for any reason blizzard is not supporting UTF8 if we set this font
        f.nameString:SetFont(UNIT_NAME_FONT, 14)
    end
    f.nameString:SetShadowOffset(1, -1)

    f.levelString:SetFont(UNIT_NAME_FONT, 14)
    f.levelString:SetShadowOffset(1, -1)

    f.castingString:SetFont(UNIT_NAME_FONT, 12)
    f.castingString:SetShadowOffset(1, -1)

    f.castingbarNormal.castingString:SetFont(UNIT_NAME_FONT, 12)
    f.castingbarNormal.castingString:SetShadowOffset(1, -1)

    f.castingbarNormal.castingTimeString:SetFont(UNIT_NAME_FONT, 12)
    f.castingbarNormal.castingTimeString:SetShadowOffset(1, -1)

    f.healthValue = 0

    f.barWidth = 149

    f:SetScript("OnEnter", normalUnitFrame_OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    return f
end
GW.AddForProfiling("unitframes", "createNormalUnitFrameSmall", createNormalUnitFrameSmall)

local function updateHealthTextString(self, health, healthPrecentage)
    local healthString = ""

    if self.showHealthValue and self.showHealthPrecentage then
        if not self.frameInvert then
            healthString = CommaValue(health) .. " - " .. CommaValue(healthPrecentage * 100) .. "%"
        else
            healthString = CommaValue(healthPrecentage * 100) .. "% - " .. CommaValue(health)
        end
    elseif self.showHealthValue and not self.showHealthPrecentage then
        healthString = CommaValue(health)
    elseif not self.showHealthValue and self.showHealthPrecentage then
        healthString = CommaValue(healthPrecentage * 100) .. "%"
    end

    self.healthString:SetText(healthString)
end
GW.AddForProfiling("unitframes", "updateHealthTextString", updateHealthTextString)

local function updateHealthbarColor(self)
    if self.classColor and (UnitIsPlayer(self.unit) or UnitInPartyIsAI(self.unit)) then
        local _, englishClass = UnitClass(self.unit)
        local color = GWGetClassColor(englishClass, true)

        self.health:SetStatusBarColor(color.r, color.g, color.b, color.a)
      --  self.healthbar:SetVertexColor(color.r, color.g, color.b, color.a)
      -- self.healthbarSpark:SetVertexColor(color.r, color.g, color.b, color.a)
      --  self.healthbarFlash:SetVertexColor(color.r, color.g, color.b, color.a)
      --  self.healthbarFlashSpark:SetVertexColor(color.r, color.g, color.b, color.a)

        self.nameString:SetTextColor(color.r + 0.3, color.g + 0.3, color.b + 0.3, color.a)
    else
        local unitReaction = UnitReaction(self.unit, "player")
        local nameColor = unitReaction and GW.FACTION_BAR_COLORS[unitReaction] or RAID_CLASS_COLORS.PRIEST

        if unitReaction then
            if unitReaction <= 3 then nameColor = COLOR_FRIENDLY[2] end --Enemy
            if unitReaction >= 5 then nameColor = COLOR_FRIENDLY[1] end --Friend
        end

        if UnitIsTapDenied(self.unit) then
            nameColor = {r = 159 / 255, g = 159 / 255, b = 159 / 255}
        end
        self.health:SetStatusBarColor(nameColor.r, nameColor.g, nameColor.b, 1)
    --    self.healthbar:SetVertexColor(nameColor.r, nameColor.g, nameColor.b, 1)
    --    self.healthbarSpark:SetVertexColor(nameColor.r, nameColor.g, nameColor.b, 1)
    --    self.healthbarFlash:SetVertexColor(nameColor.r, nameColor.g, nameColor.b, 1)
    --    self.healthbarFlashSpark:SetVertexColor(nameColor.r, nameColor.g, nameColor.b, 1)
        self.nameString:SetTextColor(nameColor.r, nameColor.g, nameColor.b, 1)
    end

    if (UnitLevel(self.unit) - GW.mylevel) <= -5 then
        local r, g, b = self.nameString:GetTextColor()
        self.nameString:SetTextColor(r + 0.5, g + 0.5, b + 0.5, 1)
    end
end
GW.AddForProfiling("unitframes", "updateHealthbarColor", updateHealthbarColor)

local function healthBarAnimation(self, powerPrec, norm)
    local powerBarWidth = self.barWidth
    local bit = powerBarWidth / 12
    local spark = bit * math.floor(12 * (powerPrec))
    local spark_current = (bit * (12 * (powerPrec)) - spark) / bit

    local bI = math.min(16, math.max(1, math.floor(17 - (16 * spark_current))))

    local hb
    local hbSpark
    local hbbg = self.healthbarBackground
    if (norm ~= nil) then
        hb = self.healthbar
        hbSpark = self.healthbarSpark
    else
        hb = self.healthbarFlash
        hbSpark = self.healthbarFlashSpark
    end

    if powerPrec>=1 or powerPrec<=0 then
      hbSpark:Hide()
    else
      hbSpark:Show()
      hbSpark:SetWidth(powerBarWidth/12)
    end

    hbSpark:SetTexCoord(
        self.frameInvert and bloodSpark[bI].right or bloodSpark[bI].left,
        self.frameInvert and bloodSpark[bI].left or bloodSpark[bI].right,
        bloodSpark[bI].top,
        bloodSpark[bI].bottom
    )
    hbSpark:SetPoint(
        self.frameInvert and "RIGHT" or "LEFT",
        hbbg,
        self.frameInvert and "RIGHT" or "LEFT",
        (math.max(0, math.min(powerBarWidth - bit, math.floor(spark))) - (self.frameInvert and 0.6 or 0)) * (self.frameInvert and -1 or 1),
        0
    )
    hb:SetPoint(
        self.frameInvert and "LEFT" or "RIGHT",
        hbbg,
        self.frameInvert and "RIGHT" or "LEFT",
        (math.max(0, math.min(powerBarWidth, spark)) * (self.frameInvert and -1 or 1)), -- + (self.frameInvert and -1 or 1),
        0
    )
end
GW.healthBarAnimation = healthBarAnimation
GW.AddForProfiling("unitframes", "healthBarAnimation", healthBarAnimation)

local function setUnitPortraitFrame(self)
    if self.portrait == nil or self.background == nil then
        return
    end

    local txt
    local border = "normal"
    local showItemLevel = (GW.settings[self.unit .. "_SHOW_ILVL"] and CanInspect(self.unit))
    local honorLevel = showItemLevel and 0 or UnitHonorLevel(self.unit)

    local unitClassIfication = UnitClassification(self.unit)
    if TARGET_FRAME_ART[unitClassIfication] ~= nil then
        border = unitClassIfication
        if UnitLevel(self.unit) == -1 then
            border = "boss"
        end
    end

    if showItemLevel then
        local guid = UnitGUID(self.unit)
        if guid and GW.unitIlvlsCache[guid] and GW.unitIlvlsCache[guid].itemLevel then
            txt = RoundDec(GW.unitIlvlsCache[guid].itemLevel, 0)
        end
    elseif honorLevel > 9 then
        local plvl
        txt = honorLevel

        if txt > 199 then
            plvl = 4
        elseif txt > 99 then
            plvl = 3
        elseif txt > 49 then
            plvl = 2
        elseif txt > 9 then
            plvl = 1
        end

        local key = "prestige" .. plvl
        if TARGET_FRAME_ART[key] then
            border = key
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
        local npcId = GW.GetUnitCreatureId(self.unit)

        for modId, _ in pairs(DBM.ModLists) do
            for _, id in ipairs(DBM.ModLists[modId]) do
                local mod = DBM:GetModByName(id)
                if mod.creatureId and mod.creatureId == npcId then
                    foundBossMod = true
                    break
                end
            end
            if foundBossMod then
                break
            end
        end
    elseif BigWigs then
        local npcId = GW.GetUnitCreatureId(self.unit)
        local BWMods = BigWigs:GetEnableMobs()
        if BWMods[npcId] then
            foundBossMod = true
        end
    end

    if foundBossMod and border == "boss" then
        border = "realboss"
    elseif foundBossMod and border ~= "boss" then
        border = "boss"
    end
    self.background:SetTexture(TARGET_FRAME_ART[border])
end
GW.AddForProfiling("unitframes", "setUnitPortraitFrame", setUnitPortraitFrame)

local function updateAvgItemLevel(self, guid)
    if guid == UnitGUID(self.unit) and CanInspect(self.unit) then
        local itemLevel, retryUnit, retryTable, iLevelDB = GW.GetUnitItemLevel(self.unit)
        if itemLevel == "tooSoon" then
            C_Timer.After(0.05, function()
                local canUpdate = true
                for _, x in ipairs(retryTable) do
                    local slotInfo = GW.GetGearSlotInfo(retryUnit, x)
                    if slotInfo == "tooSoon" then
                        canUpdate = false
                    else
                        iLevelDB[x] = slotInfo.iLvl
                        slotInfo = nil -- clear cache
                    end
                end

                if canUpdate then
                    local calculateItemLevel = GW.CalculateAverageItemLevel(iLevelDB, retryUnit)
                    PopulateUnitIlvlsCache(guid, calculateItemLevel)
                    ClearInspectPlayer()
                    self:UnregisterEvent("INSPECT_READY")
                    setUnitPortraitFrame(self)
                end
            end)
        else
            PopulateUnitIlvlsCache(guid, itemLevel)
            self:UnregisterEvent("INSPECT_READY")
        end
        setUnitPortraitFrame(self)
    end
end
GW.AddForProfiling("unitframes", "updateAvgItemLevel", updateAvgItemLevel)

local function updateRaidMarkers(self)
    local i = GetRaidTargetIndex(self.unit)
    if i == nil then
        self.raidmarker:SetTexture(nil)
        return
    end
    self.raidmarker:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_" .. i)
end
GW.AddForProfiling("unitframes", "updateRaidMarkers", updateRaidMarkers)

local function setUnitPortrait(self)
    SetPortraitTexture(self.portrait, self.unit)
    if self.frameInvert then
        self.portrait:SetTexCoord(1, 0, 0, 1)
    end
    self.activePortrait = nil
end
GW.AddForProfiling("unitframes", "setUnitPortrait", setUnitPortrait)

local function unitFrameData(self)
    local level = UnitLevel(self.unit)
    if level == -1 then
        level = "??"
    end

    local name = UnitName(self.unit)

    if UnitIsGroupLeader(self.unit) then
        name = "|TInterface/AddOns/GW2_UI/textures/party/icon-groupleader:18:18|t" .. name
    end

    self.nameString:SetText(name)
    self.levelString:SetText(level)

    updateHealthbarColor(self)

    setUnitPortraitFrame(self)
end
GW.AddForProfiling("unitframes", "unitFrameData", unitFrameData)

local function normalCastBarAnimation(self, powerPrec)

  self.castingbarNormal:SetFillAmount(powerPrec)
  --[[


    local powerBarWidth = self.barWidth
    self.castingbarNormal:SetWidth(math.max(1, powerPrec * powerBarWidth))
    self.castingbarNormalSpark:SetWidth(math.min(15, math.max(1, powerPrec * powerBarWidth)))
    self.castingbarNormal:SetTexCoord(self.barCoords.L, GW.lerp(self.barCoords.L,self.barCoords.R, powerPrec), self.barCoords.T, self.barCoords.B)

    self.castingbarNormal:SetVertexColor(1, 1, 1, 1)

    if self.numStages > 0 then
        for i = 1, self.numStages - 1, 1 do
            local stage_percentage = self.StagePoints[i]
            if stage_percentage <= powerPrec then
                self.highlight:SetTexCoord(self.barHighLightCoords.L, GW.lerp(self.barHighLightCoords.L, self.barHighLightCoords.R, stage_percentage), self.barHighLightCoords.T, self.barHighLightCoords.B)
                self.highlight:SetWidth(math.max(1, stage_percentage * powerBarWidth))
                self.highlight:Show()
            end

            if i == 1 and stage_percentage >= powerPrec then
                self.highlight:Hide()
            end
        end
    end
      ]]
end
GW.AddForProfiling("unitframes", "normalCastBarAnimation", normalCastBarAnimation)

local function protectedCastAnimation(self, powerPrec)
    local powerBarWidth = self.barWidth
    local bit = powerBarWidth / 16
    local spark = bit * math.floor(16 * (powerPrec))
    local segment = math.floor(16 * (powerPrec))
    local sparkPoint = (powerBarWidth * powerPrec) - 20

    self.castingbarSpark:SetWidth(math.min(32, 32 * (powerPrec / 0.10)))
    self.castingbarSpark:SetPoint("LEFT", self.castingbar, "LEFT", math.max(0, sparkPoint), 0)

    self.castingbar:SetTexCoord(0, math.min(1, math.max(0, 0.0625 * segment)), 0, 1)
    self.castingbar:SetWidth(math.min(powerBarWidth, math.max(1, spark)))


    --if self.numStages > 0 then
    --    for i = 1, self.numStages - 1, 1 do
    --        local stage_percentage = self.StagePoints[i]
    --        if stage_percentage <= powerPrec then
    --            self.highlight:SetTexCoord(self.barHighLightCoords.L, GW.lerp(self.barHighLightCoords.L, self.barHighLightCoords.R, stage_percentage), self.barHighLightCoords.T, self.barHighLightCoords.B)
    --            self.highlight:SetWidth(math.max(1, stage_percentage * powerBarWidth))
    --            self.highlight:Show()
    --        end

    --        if i == 1 and stage_percentage >= powerPrec then
    --            self.highlight:Hide()
    --        end
    --    end
    --end
end
GW.AddForProfiling("unitframes", "protectedCastAnimation", protectedCastAnimation)

local function hideCastBar(self)
    self.castingbarBackground:Hide()
    self.castingString:Hide()
    self.highlight:Hide()

    GW.ClearStages(self)

    if self.castingTimeString then
        self.castingTimeString:Hide()
    end

    self.castingbar:Hide()
    self.castingbarSpark:Hide()

    self.castingbarNormal:Hide()

    self.castingbarBackground:ClearAllPoints()
    self.castingbarBackground:SetPoint("TOPLEFT", self.powerbar, "BOTTOMLEFT", self.type == "NormalTarget" and -2 or 0, 19)

    if self.portrait ~= nil then
        setUnitPortrait(self)
    end

    if animations["GwUnitFrame" .. self.unit .. "Cast"] then
        animations["GwUnitFrame" .. self.unit .. "Cast"].completed = true
        animations["GwUnitFrame" .. self.unit .. "Cast"].duration = 0
    end
end
GW.AddForProfiling("unitframes", "hideCastBar", hideCastBar)

local function updateCastValues(self)
    local numStages = 0
    local barTexture = GW.CASTINGBAR_TEXTURES.YELLOW.NORMAL
    local barHighlightTexture = GW.CASTINGBAR_TEXTURES.YELLOW.HIGHLIGHT

    self.isCasting = true
    self.isChanneling = false
    self.reverseChanneling = false

    local name, _, texture, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(self.unit)

    if name == nil then
        name, _, texture, startTime, endTime, _, notInterruptible, _, _, numStages = UnitChannelInfo(self.unit)

        self.isCasting = false
        self.isChanneling = true
        self.reverseChanneling = false

        barTexture = GW.CASTINGBAR_TEXTURES.GREEN.NORMAL
        barHighlightTexture = GW.CASTINGBAR_TEXTURES.GREEN.HIGHLIGHT
    end

    --WIP self.castingbarNormal:SetTexCoord(barTexture.L, barTexture.R, barTexture.T, barTexture.B)

    local isChargeSpell = numStages and numStages > 0 or false

    if isChargeSpell then
        endTime = endTime + GetUnitEmpowerHoldAtMaxTime(self.unit)
        self.isCasting = true
        self.isChanneling = false
        self.reverseChanneling = true
    end

    if name == nil or not self.showCastbar then
        hideCastBar(self)
        return
    end

    self.barCoords = barTexture
    self.barHighLightCoords = barHighlightTexture
    self.numStages = numStages and numStages + 1 or 0
    self.maxValue = (endTime - startTime) / 1000
    startTime = startTime / 1000
    endTime = endTime / 1000



    if texture ~= nil and self.portrait ~= nil and (self.activePortrait == nil or self.activePortrait ~= texture) then
        self.portrait:SetTexture(texture)
        self.activePortrait = texture
    end

    self.castingbarBackground:Show()
    self.castingbarBackground:ClearAllPoints()
    self.castingbarBackground:SetPoint("TOPLEFT", self.powerbar, "BOTTOMLEFT", self.type == "NormalTarget" and -2 or 0, -1)
    self.castingString:Show()
    if self.castingTimeString then
        self.castingTimeString:Show()
    end

    if notInterruptible then
        self.castingString:SetText(name)
        self.castingbarNormal:Hide()

        self.castingbar:Show()
        self.castingbarSpark:Show()

        self.castingString:Show();
        if self.castingTimeString~=nil then
          self.castingTimeString:Show();
        end
    else
        self.castingbarNormal.castingString:SetText(name)
        self.castingString:Hide();
        if self.castingTimeString~=nil then
          self.castingTimeString:Hide();
        end

        self.castingbar:Hide()
        self.castingbarSpark:Hide()

        self.castingbarNormal:Show()
    end

    if self.reverseChanneling then
        GW.AddStages(self, self.castingbarBackground, self.barWidth)
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
                protectedCastAnimation(self, p)
            else
                normalCastBarAnimation(self, p)
            end
        end,
        "noease"
    )
end
GW.AddForProfiling("unitframes", "updateCastValues", updateCastValues)

local function updatePowerValues(self, hideAt0,event)
    local powerType, powerToken, _ = UnitPowerType(self.unit)
    local power = UnitPower(self.unit, powerType)
    local powerMax = UnitPowerMax(self.unit, powerType)
    local powerPrecentage = 0

    if power > 0 and powerMax > 0 then
        powerPrecentage = power / powerMax
    end

    if power <= 0 and hideAt0 then
        self.powerbar:Hide()
    else
        self.powerbar:Show()
    end

    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.powerbar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end

    if event and event == "UNIT_TARGET" or event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_TARGET_CHANGED" then
      self.powerbar:ForceFillAmount(powerPrecentage)
    else
      self.powerbar:SetFillAmount(powerPrecentage)
    end
end
GW.updatePowerValues = updatePowerValues
GW.AddForProfiling("unitframes", "updatePowerValues", updatePowerValues)

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

local function updateHealthValues(self, event)
    local health = UnitHealth(self.unit)
    local healthMax = UnitHealthMax(self.unit)
    local absorb = UnitGetTotalAbsorbs(self.unit)
    local prediction = UnitGetIncomingHeals(self.unit) or 0
    local healAbsorb =  UnitGetTotalHealAbsorbs(self.unit)
    local absorbPrecentage = 0
    local absorbAmount = 0
    local absorbAmount2 = 0
    local predictionPrecentage = 0
    local healAbsorbPrecentage = 0
    local healthPrecentage = 0

    if health > 0 and healthMax > 0 then
        healthPrecentage = health / healthMax
    end

    if absorb > 0 and healthMax > 0 then
        absorbPrecentage = absorb / healthMax
        absorbAmount = healthPrecentage + absorbPrecentage
        absorbAmount2 = absorbPrecentage - (1 - healthPrecentage)
    end

    if prediction > 0 and healthMax > 0 then
        predictionPrecentage = (prediction / healthMax) + healthPrecentage
    end
    if healAbsorb > 0 and healthMax > 0 then
        healAbsorbPrecentage = min(healthMax,healAbsorb / healthMax)
    end
    self.healPrediction:SetFillAmount(predictionPrecentage)

    self.health.barOnUpdate = function()
      updateHealthTextString(self, health, self.health:GetFillAmount())
    end

    if event == "UNIT_TARGET" or event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_TARGET_CHANGED" then
        self.health:ForceFillAmount(healthPrecentage)
        self.absorbbg:ForceFillAmount(absorbAmount)
        self.absorbOverlay:ForceFillAmount(absorbAmount2)
        self.antiHeal:ForceFillAmount(healAbsorbPrecentage)
    else
        self.health:SetFillAmount(healthPrecentage)
        self.absorbbg:SetFillAmount(absorbAmount)
        self.absorbOverlay:SetFillAmount(absorbAmount2)
        self.antiHeal:SetFillAmount(healAbsorbPrecentage)
    end
end
GW.AddForProfiling("unitframes", "updateHealthValues", updateHealthValues)

local function target_OnEvent(self, event, unit)
    local ttf = GwTargetTargetUnitFrame

    if IsIn(event, "PLAYER_TARGET_CHANGED", "ZONE_CHANGED", "FORCE_UPDATE") then
        if event == "PLAYER_TARGET_CHANGED" and CanInspect(self.unit) and GW.settings.target_SHOW_ILVL then
            local guid = UnitGUID(self.unit)
            if guid then
                if not GW.unitIlvlsCache[guid] then
                    local _, englishClass = UnitClass(self.unit)
                    local color = GWGetClassColor(englishClass, true, true)
                    GW.unitIlvlsCache[guid] = {unitColor = {color.r, color.g, color.b}}
                    self:RegisterEvent("INSPECT_READY")
                    NotifyInspect(self.unit)
                end
            end
        end
        if self.showThreat then
            updateThreatValues(self)
        elseif self.threattabbg:IsShown() then
            self.threattabbg:Hide()
        end

        unitFrameData(self)
        if (ttf) then unitFrameData(ttf) end
        updateHealthValues(self, event)
        if (ttf) then updateHealthValues(ttf, event) end
        updatePowerValues(self,nil,event)
        if (ttf) then updatePowerValues(ttf,nil,event) end
        updateCastValues(self)
        if (ttf) then updateCastValues(ttf) end
        updateRaidMarkers(self)
        if (ttf) then updateRaidMarkers(ttf) end
        UpdateBuffLayout(self, event)

        if event == "PLAYER_TARGET_CHANGED" then
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
    elseif event == "UNIT_TARGET" and unit == "target" then
        if (ttf ~= nil) then
            if UnitExists("targettarget") then
                unitFrameData(ttf)
                updateHealthValues(ttf, event)
                updatePowerValues(ttf,nil,event)
                updateCastValues(ttf)
                updateRaidMarkers(ttf)
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        wipe(GW.unitIlvlsCache)
    elseif event == "RAID_TARGET_UPDATE" then
        updateRaidMarkers(self)
        if (ttf) then updateRaidMarkers(ttf) end
    elseif event == "INSPECT_READY" then
        if not GW.settings.target_SHOW_ILVL then
            self:UnregisterEvent("INSPECT_READY")
        else
            updateAvgItemLevel(self, unit)
        end
    elseif event == "UNIT_THREAT_LIST_UPDATE" and self.showThreat then
        updateThreatValues(self)
    elseif UnitIsUnit(unit, self.unit) then
        if event == "UNIT_AURA" then
            UpdateBuffLayout(self, event)
        elseif IsIn(event, "UNIT_MAXHEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEALTH", "UNIT_HEAL_PREDICTION") then
            updateHealthValues(self, event)
        elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT") then
            updatePowerValues(self,nil,event)
        elseif IsIn(event, "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_EMPOWER_START") then
            updateCastValues(self)
        elseif IsIn(event, "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_EMPOWER_STOP") then
            hideCastBar(self)
        elseif event == "UNIT_FACTION" then
            updateHealthbarColor(self)
        end
    end
end
GW.AddForProfiling("unitframes", "target_OnEvent", target_OnEvent)

local function focus_OnEvent(self, event, unit)
    local ttf = GwFocusTargetUnitFrame

    if event == "PLAYER_FOCUS_CHANGED" or event == "ZONE_CHANGED" or event == "FORCE_UPDATE" then
        unitFrameData(self)
        if (ttf) then unitFrameData(ttf) end
        updateHealthValues(self, event)
        if (ttf) then updateHealthValues(ttf, event) end
        updatePowerValues(self,nil,event)
        if (ttf) then updatePowerValues(ttf,nil,event) end
        updateCastValues(self)
        if (ttf) then updateCastValues(ttf) end
        updateRaidMarkers(self)
        if (ttf) then updateRaidMarkers(ttf) end
        UpdateBuffLayout(self, event)

        if event == "PLAYER_FOCUS_CHANGED" then
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
    elseif event == "UNIT_TARGET" and unit == "focus" then
        if (ttf ~= nil) then
            if UnitExists("focustarget") then
                unitFrameData(ttf)
                updateHealthValues(ttf, event)
                updatePowerValues(ttf,nil,event)
                updateCastValues(ttf)
                updateRaidMarkers(ttf)
            end
        end
    elseif event == "RAID_TARGET_UPDATE" then
        updateRaidMarkers(self)
    elseif UnitIsUnit(unit, self.unit) then
        if event == "UNIT_AURA" then
            UpdateBuffLayout(self, event)
        elseif IsIn(event, "UNIT_MAXHEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEALTH", "UNIT_HEAL_PREDICTION") then
            updateHealthValues(self, event)
        elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT") then
            updatePowerValues(self,nil,event)
        elseif IsIn(event, "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_EMPOWER_START") then
            updateCastValues(self)
        elseif IsIn(event, "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_EMPOWER_STOP") then
            hideCastBar(self)
        elseif event == "UNIT_FACTION" then
            updateHealthbarColor(self)
        end
    end
end
GW.AddForProfiling("unitframes", "focus_OnEvent", focus_OnEvent)

local function unittarget_OnUpdate(self, elapsed)
    if self.unit == nil then
        return
    end
    if self.totalElapsed > 0 then
        self.totalElapsed = self.totalElapsed - elapsed
        return
    end
    self.totalElapsed = 0.25
    if not UnitExists(self.unit) then
        return
    end

    updateRaidMarkers(self)
    updateHealthValues(self, "UNIT_TARGET")
    updatePowerValues(self,nil,"UNIT_TARGET")
    updateCastValues(self)
end
GW.AddForProfiling("unitframes", "unittarget_OnUpdate", unittarget_OnUpdate)

local function ToggleTargetFrameSettings()
    GwTargetUnitFrame.classColor = GW.settings.target_CLASS_COLOR

    GwTargetUnitFrame.showHealthValue = GW.settings.target_HEALTH_VALUE_ENABLED
    GwTargetUnitFrame.showHealthPrecentage = GW.settings.target_HEALTH_VALUE_TYPE
    GwTargetUnitFrame.showCastbar = GW.settings.target_SHOW_CASTBAR
    GwTargetUnitFrame.showCastingbarData = GW.settings.target_CASTINGBAR_DATA

    GwTargetUnitFrame.displayBuffs = GW.settings.target_BUFFS
    GwTargetUnitFrame.displayDebuffs = GW.settings.target_DEBUFFS

    GwTargetUnitFrame.showThreat = GW.settings.target_THREAT_VALUE_ENABLED

    GwTargetUnitFrame.auraPositionTop = GW.settings.target_AURAS_ON_TOP

    GwTargetUnitFrame.altBg:SetShown(GW.settings.target_FRAME_ALT_BACKGROUND)

    GwTargetUnitFrame.auras:ClearAllPoints()
    GwTargetUnitFrame.auras:SetPoint("TOPLEFT", GwTargetUnitFrame.castingbarBackground, "BOTTOMLEFT", 2, -15)

    if GwTargetUnitFrame.auraPositionTop then
        local yOff = GW.settings.target_FRAME_ALT_BACKGROUND and 22 or 17

        GwTargetUnitFrame.auras:ClearAllPoints()
        if GwTargetUnitFrame.frameInvert then
            GwTargetUnitFrame.auras:SetPoint("TOPRIGHT", GwTargetUnitFrame.nameString, "TOPRIGHT", -2, yOff)
        else
            GwTargetUnitFrame.auras:SetPoint("TOPLEFT", GwTargetUnitFrame.nameString, "TOPLEFT", 2, yOff)
        end
    elseif GW.settings.target_HOOK_COMBOPOINTS and (GW.myClassID == 4 or GW.myClassID == 11) then
        GwTargetUnitFrame.auras:ClearAllPoints()
        GwTargetUnitFrame.auras:SetPoint("TOPLEFT", GwTargetUnitFrame.castingbarBackground, "BOTTOMLEFT", 2, -23)
    end

    -- priority: All > Important > Player
    GwTargetUnitFrame.debuffFilter = "PLAYER"
    if GW.settings.target_BUFFS_FILTER_IMPORTANT then
        GwTargetUnitFrame.debuffFilter = "IMPORTANT"
    end
    if GW.settings.target_BUFFS_FILTER_ALL then
        GwTargetUnitFrame.debuffFilter = nil
    end

    target_OnEvent(GwTargetUnitFrame, "FORCE_UPDATE")
end
GW.ToggleTargetFrameSettings = ToggleTargetFrameSettings

local function ToggleTargetFrameCombatFeedback()
    if GW.settings.target_FLOATING_COMBAT_TEXT then
        if not fctf then
            fctf = CreateFrame("Frame", nil, GwTargetUnitFrame)
            fctf:SetFrameLevel(GwTargetUnitFrame:GetFrameLevel() + 3)
            fctf:SetScript("OnEvent", function(self, _, unit, ...)
                if self.unit == unit then
                    CombatFeedback_OnCombatEvent(self, ...)
                end
            end)
            local font = fctf:CreateFontString(nil, "OVERLAY")
            font:SetFont(DAMAGE_TEXT_FONT, 30, "")
            fctf.fontString = font
            font:SetPoint("CENTER", GwTargetUnitFrame.portrait, "CENTER")
            font:Hide()

            fctf.unit = GwTargetUnitFrame.unit
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
GW.ToggleTargetFrameCombatFeedback = ToggleTargetFrameCombatFeedback

local function LoadTarget()
    local NewUnitFrame = createNormalUnitFrame("GwTargetUnitFrame", GW.settings.target_FRAME_INVERT)
    NewUnitFrame.unit = "target"
    NewUnitFrame.type = "NormalTarget"

    RegisterMovableFrame(NewUnitFrame, TARGET, "target_pos",  ALL .. ",Unitframe", nil, {"default", "scaleable"})

    NewUnitFrame:ClearAllPoints()
    NewUnitFrame:SetPoint("TOPLEFT", NewUnitFrame.gwMover)

    NewUnitFrame.portrait.mask = NewUnitFrame:CreateMaskTexture()
    NewUnitFrame.portrait.mask:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER", 0, 0)
    NewUnitFrame.portrait.mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    NewUnitFrame.portrait.mask:SetSize(58, 58)
    NewUnitFrame.portrait:AddMaskTexture(NewUnitFrame.portrait.mask)

    NewUnitFrame.altBg = CreateFrame("Frame", nil, NewUnitFrame, "GwAlternativeUnitFrameBackground")
    NewUnitFrame.altBg:SetAllPoints(NewUnitFrame)
    if NewUnitFrame.frameInvert then
        NewUnitFrame.altBg.backgroundOverlay:SetTexCoord(1, 0, 0, 1)
        NewUnitFrame.altBg.backgroundOverlay:SetPoint("CENTER", -15, -5)
        NewUnitFrame.healthContainer:ClearAllPoints()
        NewUnitFrame.healthContainer:SetPoint("RIGHT", NewUnitFrame.healthbarBackground, "RIGHT", -1, 0)
    end

    NewUnitFrame.segments = {}
    NewUnitFrame.StagePoints = {}

    NewUnitFrame:SetAttribute("*type1", "target")
    NewUnitFrame:SetAttribute("*type2", "togglemenu")
    NewUnitFrame:SetAttribute("unit", "target")
    RegisterUnitWatch(NewUnitFrame)
    NewUnitFrame:EnableMouse(true)
    NewUnitFrame:RegisterForClicks("AnyDown")

    AddToClique(NewUnitFrame)

    ToggleTargetFrameSettings()

    NewUnitFrame:SetScript("OnEvent", target_OnEvent)

    NewUnitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    NewUnitFrame:RegisterEvent("ZONE_CHANGED")
    NewUnitFrame:RegisterEvent("RAID_TARGET_UPDATE")
    NewUnitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    NewUnitFrame:RegisterUnitEvent("UNIT_HEALTH", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_TARGET", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXPOWER", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_AURA", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "target")

    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "target")

    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_FACTION", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "target")

    LoadAuras(NewUnitFrame)

    -- create floating combat text
    ToggleTargetFrameCombatFeedback()
end
GW.LoadTarget = LoadTarget

local function ToggleFocusFrameSettings()
    GwFocusUnitFrame.classColor = GW.settings.focus_CLASS_COLOR

    GwFocusUnitFrame.showHealthValue = GW.settings.focus_HEALTH_VALUE_ENABLED
    GwFocusUnitFrame.showHealthPrecentage = GW.settings.focus_HEALTH_VALUE_TYPE
    GwFocusUnitFrame.showCastbar = GW.settings.focus_SHOW_CASTBAR

    GwFocusUnitFrame.displayBuffs = GW.settings.focus_BUFFS
    GwFocusUnitFrame.displayDebuffs = GW.settings.focus_DEBUFFS

    GwFocusUnitFrame.auraPositionTop = GW.settings.focus_AURAS_ON_TOP

    GwFocusUnitFrame.altBg:SetShown(GW.settings.focus_FRAME_ALT_BACKGROUND)

    GwFocusUnitFrame.auras:ClearAllPoints()
    GwFocusUnitFrame.auras:SetPoint("TOPLEFT", GwFocusUnitFrame.castingbarBackground, "BOTTOMLEFT", 2, -15)

    if GwFocusUnitFrame.auraPositionTop then
        local yOff = GW.settings.focus_FRAME_ALT_BACKGROUND and 22 or 17

        GwFocusUnitFrame.auras:ClearAllPoints()
        if GwFocusUnitFrame.frameInvert then
            GwFocusUnitFrame.auras:SetPoint("TOPRIGHT", GwFocusUnitFrame.nameString, "TOPRIGHT", -2, yOff)
        else
            GwFocusUnitFrame.auras:SetPoint("TOPLEFT", GwFocusUnitFrame.nameString, "TOPLEFT", 2, yOff)
        end
    end

    -- priority: All > Important > Player
    GwFocusUnitFrame.debuffFilter = "PLAYER"
    if GW.settings.focus_BUFFS_FILTER_IMPORTANT then
        GwFocusUnitFrame.debuffFilter = "IMPORTANT"
    end
    if GW.settings.focus_BUFFS_FILTER_ALL then
        GwFocusUnitFrame.debuffFilter = nil
    end

    focus_OnEvent(GwFocusUnitFrame, "FORCE_UPDATE")
end
GW.ToggleFocusFrameSettings = ToggleFocusFrameSettings

local function LoadFocus()
    local NewUnitFrame = createNormalUnitFrame("GwFocusUnitFrame", GW.settings.focus_FRAME_INVERT)
    NewUnitFrame.unit = "focus"
    NewUnitFrame.type = "NormalTarget"

    RegisterMovableFrame(NewUnitFrame, FOCUS, "focus_pos", ALL .. ",Unitframe", nil, {"default", "scaleable"})

    NewUnitFrame:ClearAllPoints()
    NewUnitFrame:SetPoint("TOPLEFT", NewUnitFrame.gwMover)

    NewUnitFrame.portrait.mask = NewUnitFrame:CreateMaskTexture()
    NewUnitFrame.portrait.mask:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER", 0, 0)
    NewUnitFrame.portrait.mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    NewUnitFrame.portrait.mask:SetSize(58, 58)
    NewUnitFrame.portrait:AddMaskTexture(NewUnitFrame.portrait.mask)

    NewUnitFrame.altBg = CreateFrame("Frame", nil, NewUnitFrame, "GwAlternativeUnitFrameBackground")
    NewUnitFrame.altBg:SetAllPoints(NewUnitFrame)
    if NewUnitFrame.frameInvert then
        NewUnitFrame.altBg.backgroundOverlay:SetTexCoord(1, 0, 0, 1)
        NewUnitFrame.altBg.backgroundOverlay:SetPoint("CENTER", -15, -5)
    end

    NewUnitFrame.segments = {}
    NewUnitFrame.StagePoints = {}

    NewUnitFrame:SetAttribute("*type1", "target")
    NewUnitFrame:SetAttribute("*type2", "togglemenu")
    NewUnitFrame:SetAttribute("unit", "focus")
    RegisterUnitWatch(NewUnitFrame)
    NewUnitFrame:EnableMouse(true)
    NewUnitFrame:RegisterForClicks("AnyDown")

    AddToClique(NewUnitFrame)

    ToggleFocusFrameSettings()

    NewUnitFrame:SetScript("OnEvent", focus_OnEvent)

    NewUnitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    NewUnitFrame:RegisterEvent("ZONE_CHANGED")
    NewUnitFrame:RegisterEvent("RAID_TARGET_UPDATE")

    NewUnitFrame:RegisterUnitEvent("UNIT_HEALTH", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_TARGET", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXPOWER", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_AURA", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_FACTION", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "focus")

    LoadAuras(NewUnitFrame)
end
GW.LoadFocus = LoadFocus

local function ToggleTargetTargetFrameSetting(unit)
    _G["Gw" .. unit .. "TargetUnitFrame"].classColor = GW.settings[string.lower(unit) .. "_CLASS_COLOR"]
    _G["Gw" .. unit .. "TargetUnitFrame"].showCastbar = GW.settings[string.lower(unit) .. "_TARGET_SHOW_CASTBAR"]


    _G["Gw" .. unit .. "TargetUnitFrame"].altBg:SetShown((unit == "Target" and GW.settings.target_FRAME_ALT_BACKGROUND) or (unit == "Focus" and GW.settings.focus_FRAME_ALT_BACKGROUND))

    if unit == "Target" then
        target_OnEvent(GwTargetUnitFrame, "FORCE_UPDATE")
    else
        focus_OnEvent(GwFocusTargetUnitFrame, "FORCE_UPDATE")
    end
end
GW.ToggleTargetTargetFrameSetting = ToggleTargetTargetFrameSetting

local function LoadTargetOfUnit(unit)
    local f = createNormalUnitFrameSmall("Gw" .. unit .. "TargetUnitFrame")
    local unitID = string.lower(unit) .. "target"
    f.type = "SmallTarget"
    f.unit = unitID

    f.segments = {}
    f.StagePoints = {}

    RegisterMovableFrame(f, unit == "Focus" and MINIMAP_TRACKING_FOCUS or SHOW_TARGET_OF_TARGET_TEXT, unitID .. "_pos", ALL .. ",Unitframe", nil, {"default", "scaleable"})

    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", f.gwMover)

    f:SetAttribute("*type1", "target")
    f:SetAttribute("*type2", "togglemenu")
    f:SetAttribute("unit", unitID)
    RegisterUnitWatch(f)
    f:EnableMouse(true)
    f:RegisterForClicks("AnyDown")

    f.altBg = CreateFrame("Frame", nil, f, "GwAlternativeUnitFrameBackground")
    f.altBg.backgroundOverlay:Hide()
    f.altBg.backgroundOverlaySmall:Show()
    f.altBg:SetAllPoints(f)

    AddToClique(f)

    f.showHealthValue = false
    f.showHealthPrecentage = false

    ToggleTargetTargetFrameSetting(unit)

    f.debuffFilter = nil

    f.totalElapsed = 0.15
    f:SetScript("OnUpdate", unittarget_OnUpdate)
end
GW.LoadTargetOfUnit = LoadTargetOfUnit
