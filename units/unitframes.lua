local _, GW = ...
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local GetSetting = GW.GetSetting
local CommaValue = GW.CommaValue
local TimeCount = GW.TimeCount
local GWGetClassColor = GW.GWGetClassColor
local Diff = GW.Diff
local PowerBarColorCustom = GW.PowerBarColorCustom
local bloodSpark = GW.BLOOD_SPARK
local TARGET_FRAME_ART = GW.TARGET_FRAME_ART
local RegisterMovableFrame = GW.RegisterMovableFrame
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation
local AddToClique = GW.AddToClique
local IsIn = GW.IsIn
local RoundDec = GW.RoundDec
local LoadAuras = GW.LoadAuras
local UpdateBuffLayout = GW.UpdateBuffLayout
local LCC = GW.Libs.LCC
local LCD = GW.Libs.LCD

local function normalUnitFrame_OnEnter(self)
    if self.unit ~= nil then
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(self.unit)
        GameTooltip:Show()
    end
end
GW.AddForProfiling("unitframes", "normalUnitFrame_OnEnter", normalUnitFrame_OnEnter)

local function createNormalUnitFrame(ftype, revert)
    local f = CreateFrame("Button", ftype, UIParent, revert and "GwNormalUnitFrameInvert" or "GwNormalUnitFrame")

    f.frameInvert = revert

    f.healthString:SetFont(UNIT_NAME_FONT, 11)
    f.healthString:SetShadowOffset(1, -1)

    f.nameString:SetFont(UNIT_NAME_FONT, 14)
    f.nameString:SetShadowOffset(1, -1)

    f.threatString:SetFont(STANDARD_TEXT_FONT, 11)
    f.threatString:SetShadowOffset(1, -1)

    f.levelString:SetFont(UNIT_NAME_FONT, 14)
    f.levelString:SetShadowOffset(1, -1)

    f.castingString:SetFont(UNIT_NAME_FONT, 12)
    f.castingString:SetShadowOffset(1, -1)

    f.castingTimeString:SetFont(UNIT_NAME_FONT, 12)
    f.castingTimeString:SetShadowOffset(1, -1)

    f.healthValue = 0

    f.barWidth = 212

    f:SetScript("OnEnter", normalUnitFrame_OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    return f
end
GW.createNormalUnitFrame = createNormalUnitFrame
GW.AddForProfiling("unitframes", "createNormalUnitFrame", createNormalUnitFrame)

local function createNormalUnitFrameSmall(ftype)
    local f = CreateFrame("Button", ftype, UIParent, "GwNormalUnitFrameSmall")

    f.healthString:SetFont(UNIT_NAME_FONT, 11)
    f.healthString:SetShadowOffset(1, -1)

    f.nameString:SetFont(UNIT_NAME_FONT, 14)
    f.nameString:SetShadowOffset(1, -1)

    f.levelString:SetFont(UNIT_NAME_FONT, 14)
    f.levelString:SetShadowOffset(1, -1)

    f.castingString:SetFont(UNIT_NAME_FONT, 12)
    f.castingString:SetShadowOffset(1, -1)

    f.healthValue = 0

    f.barWidth = 146

    f:SetScript("OnEnter", normalUnitFrame_OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    return f
end
GW.AddForProfiling("unitframes", "createNormalUnitFrameSmall", createNormalUnitFrameSmall)

local function updateHealthTextString(self, health, healthPrecentage)
    local healthString = ""

    if self.showHealthValue == true then
        healthString = CommaValue(health)
        if self.showHealthPrecentage == true then
            healthString = healthString .. " - "
        end
    end

    if self.showHealthPrecentage == true then
        healthString = healthString .. CommaValue(healthPrecentage * 100) .. "%"
    end

    self.healthString:SetText(healthString)
end
GW.AddForProfiling("unitframes", "updateHealthTextString", updateHealthTextString)

local function updateHealthbarColor(self)
    if self.classColor == true and UnitIsPlayer(self.unit) then
        local _, englishClass = UnitClass(self.unit)
        local color = GWGetClassColor(englishClass, true)

        self.healthbar:SetVertexColor(color.r, color.g, color.b, color.a)
        self.healthbarSpark:SetVertexColor(color.r, color.g, color.b, color.a)
        self.healthbarFlash:SetVertexColor(color.r, color.g, color.b, color.a)
        self.healthbarFlashSpark:SetVertexColor(color.r, color.g, color.b, color.a)

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

        self.healthbar:SetVertexColor(nameColor.r, nameColor.g, nameColor.b, 1)
        self.healthbarSpark:SetVertexColor(nameColor.r, nameColor.g, nameColor.b, 1)
        self.healthbarFlash:SetVertexColor(nameColor.r, nameColor.g, nameColor.b, 1)
        self.healthbarFlashSpark:SetVertexColor(nameColor.r, nameColor.g, nameColor.b, 1)
        self.nameString:SetTextColor(nameColor.r, nameColor.g, nameColor.b, 1)
    end

    if (UnitLevel(self.unit) - GW.mylevel) <= -5 and not UnitIsPlayer(self.unit) then
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
        (math.max(0, math.min(powerBarWidth, spark)) * (self.frameInvert and -1 or 1)) + (self.frameInvert and -1 or 1),
        0
    )
end
GW.healthBarAnimation = healthBarAnimation
GW.AddForProfiling("unitframes", "healthBarAnimation", healthBarAnimation)

local function setUnitPortraitFrame(self)
    if self.portrait == nil or self.background == nil then
        return
    end

    local border = "normal"
    local unitClassIfication = UnitClassification(self.unit)
    if TARGET_FRAME_ART[unitClassIfication] ~= nil then
        border = unitClassIfication
        if UnitLevel(self.unit) == -1 and not UnitIsPlayer(self.unit) then
            border = "boss"
        end
    end

    --if DBM or BigWigs is load, check if target is a boss and set boss frame
    local foundBossMod = false
    if IsAddOnLoaded("DBM-Core") then
        local npcId = GW.GetUnitCreatureId(self.unit)

        for modId, idTable in pairs(DBM.ModLists) do
            for i, id in ipairs(DBM.ModLists[modId]) do
                local mod = DBM:GetModByName(id)
                if mod.creatureId ~= nil and mod.creatureId == npcId then
                    foundBossMod = true
                    break
                end
            end
            if foundBossMod then
                break
            end
        end
    elseif IsAddOnLoaded("BigWigs") then
        local npcId = GW.GetUnitCreatureId(self.unit)
        if BigWigs ~= nil then
            local BWMods = BigWigs:GetEnableMobs()
            if BWMods[npcId] ~= nil then
                foundBossMod = true
            end
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
    self.guid = UnitGUID(self.unit)
    if level == -1 then
        level = "??"
    end

    local name = UnitName(self.unit)

    if UnitIsGroupLeader(self.unit) then
        name = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\icon-groupleader:18:18|t" .. name
    end

    self.nameString:SetText(name)
    self.levelString:SetText(level)
    -- Color level number
    if UnitCanAttack("player", self.unit) then
        if level == "??" then level = 99 end
        local color = GetCreatureDifficultyColor(level)
        self.levelString:SetVertexColor(color.r, color.g, color.b)
    else
        self.levelString:SetVertexColor(1, 1, 1)
    end

    updateHealthbarColor(self)

    setUnitPortraitFrame(self)
end
GW.AddForProfiling("unitframes", "unitFrameData", unitFrameData)

local function normalCastBarAnimation(self, powerPrec)
    local powerBarWidth = self.barWidth
    self.castingbarNormal:SetWidth(math.min(powerBarWidth, math.max(1, powerBarWidth * powerPrec)))
    self.castingbarNormal:SetTexCoord(0, powerPrec, 0.25, 0.5)
    self.castingbarNormalSpark:SetWidth(math.max(1, math.min(16, 16 * (powerPrec / 0.10))))
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
end
GW.AddForProfiling("unitframes", "protectedCastAnimation", protectedCastAnimation)

local function hideCastBar(self)
    self.castingbarBackground:Hide()
    self.castingString:Hide()

    if self.castingTimeString then
        self.castingTimeString:Hide()
    end

    self.castingbar:Hide()
    self.castingbarSpark:Hide()

    self.castingbarNormal:Hide()
    self.castingbarNormalSpark:Hide()

    self.castingbarBackground:ClearAllPoints()
    self.castingbarBackground:SetPoint("TOPLEFT", self.powerbarBackground, "BOTTOMLEFT", self.type == "NormalTarget" and -2 or 0, 19)

    if self.portrait ~= nil then
        setUnitPortrait(self)
    end

    if animations["GwUnitFrame" .. self.unit .. "Cast"] ~= nil then
        animations["GwUnitFrame" .. self.unit .. "Cast"]["completed"] = true
        animations["GwUnitFrame" .. self.unit .. "Cast"]["duration"] = 0
    end
end
GW.AddForProfiling("unitframes", "hideCastBar", hideCastBar)

local function updateCastValues(self)
    local castType = 1

    local name, _, texture, startTime, endTime = LCC:UnitCastingInfo(self.unit)

    if name == nil then
        name, _, texture, startTime, endTime = LCC:UnitChannelInfo(self.unit)
        castType = 0
    end

    if name == nil  then
        hideCastBar(self)
        return
    end

    startTime = startTime / 1000
    endTime = endTime / 1000

    self.castingString:SetText(name)
    if texture ~= nil and self.portrait ~= nil and (self.activePortrait == nil or self.activePortrait ~= texture) then
        self.portrait:SetTexture(texture)
        self.activePortrait = texture
    end

    self.castingbarBackground:Show()
    self.castingbarBackground:ClearAllPoints()
    self.castingbarBackground:SetPoint("TOPLEFT", self.powerbarBackground, "BOTTOMLEFT", self.type == "NormalTarget" and -2 or 0, -1)
    self.castingString:Show()
    if self.castingTimeString then
        self.castingTimeString:Show()
    end

    --if notInterruptible then
        --self.castingbarNormal:Hide()
        --self.castingbarNormalSpark:Hide()

        --self.castingbar:Show()
        --self.castingbarSpark:Show()
    --else
        self.castingbar:Hide()
        self.castingbarSpark:Hide()

        self.castingbarNormal:Show()
        self.castingbarNormalSpark:Show()
    --end

    AddToAnimation(
        "GwUnitFrame" .. self.unit .. "Cast",
        0,
        1,
        startTime,
        endTime - startTime,
        function(step)
            if GetSetting("target_CASTINGBAR_DATA") and self.castingTimeString then
                self.castingTimeString:SetText(TimeCount(endTime - GetTime(), true))
            end
            if castType == 0 then
                step = 1 - step
            end
            --if notInterruptible then
                --protectedCastAnimation(self, step)
            --else
                normalCastBarAnimation(self, step)
            --end
        end,
        "noease"
    )
end
GW.AddForProfiling("unitframes", "updateCastValues", updateCastValues)

local function updatePowerValues(self)
    local powerType, powerToken, _ = UnitPowerType(self.unit)
    local power = UnitPower(self.unit, powerType)
    local powerMax = UnitPowerMax(self.unit, powerType)
    local powerPrecentage = 0

    if power > 0 and powerMax > 0 then
        powerPrecentage = power / powerMax
    end

    if power <= 0 then
        self.powerbarBackground:Hide()
        self.powerbar:Hide()
    else
        self.powerbarBackground:Show()
        self.powerbar:Show()
    end

    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.powerbar:SetVertexColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end

    self.powerbar:SetWidth(math.min(self.barWidth, math.max(1, self.barWidth * powerPrecentage)))
end
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
GW.updatePowerValues = updatePowerValues
GW.AddForProfiling("unitframes", "updateThreatValues", updateThreatValues)

local function updateHealthValues(self, event)
    local health = UnitHealth(self.unit)
    local healthMax = UnitHealthMax(self.unit)
    local healPredictionAmount = UnitGetIncomingHeals(self.unit) or 0
    local healthPrecentage = 0
    local predictionPrecentage = 0

    if health > 0 and healthMax > 0 then
        healthPrecentage = health / healthMax
    end

    local animationSpeed

    if event == "UNIT_TARGET" or event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_TARGET_CHANGED" then
        animationSpeed = 0
        self.healthValue = healthPrecentage
        StopAnimation(self:GetName() .. self.unit)
    else
        animationSpeed = Diff(self.healthValue, healthPrecentage)
        animationSpeed = math.min(1.00, math.max(0.2, 2.00 * animationSpeed))
    end

    --prediction calc
    if (healPredictionAmount ~= nil or healPredictionAmount == 0) and healthMax ~= 0 then
        predictionPrecentage = healPredictionAmount / healthMax
    end

    local predictionbar = self.predictionbar
    if healPredictionAmount == 0 then
        predictionbar:SetAlpha(0.0)
    else
        local predictionAmount = healthPrecentage + predictionPrecentage

        predictionbar:SetWidth(math.min(self.barWidth, math.max(1, self.barWidth * predictionAmount)))
        predictionbar:SetTexCoord(0, math.min(1, 1 * predictionAmount), 0, 1)
        predictionbar:SetAlpha(math.max(0, math.min(1, (1 * (predictionPrecentage / 0.1)))))
    end

    healthBarAnimation(self, healthPrecentage, true)
    if animationSpeed == 0 then
        healthBarAnimation(self, healthPrecentage)
        updateHealthTextString(self, health, healthPrecentage)
    else
        self.healthValueStepCount = 0
        AddToAnimation(
            self:GetName() .. self.unit,
            self.healthValue,
            healthPrecentage,
            GetTime(),
            animationSpeed,
            function(step)
                healthBarAnimation(self, step)

                local hvsc = self.healthValueStepCount
                if hvsc % 5 == 0 then
                    updateHealthTextString(self, healthMax * step, step)
                end
                self.healthValueStepCount = hvsc + 1
                self.healthValue = step
            end,
            nil,
            function()
                updateHealthTextString(self, health, healthPrecentage)
            end
        )
    end
end
GW.AddForProfiling("unitframes", "updateHealthValues", updateHealthValues)

local function target_OnEvent(self, event, unit)
    local ttf = GwTargetTargetUnitFrame

    if IsIn(event, "PLAYER_TARGET_CHANGED", "ZONE_CHANGED") then
        if self.showThreat then
            updateThreatValues(self)
        elseif self.threattabbg:IsShown() then
            self.threattabbg:Hide()
        end

        unitFrameData(self)
        if (ttf) then unitFrameData(ttf) end
        updateHealthValues(self, event)
        if (ttf) then updateHealthValues(ttf, event) end
        updatePowerValues(self, event)
        if (ttf) then updatePowerValues(ttf, event) end
        updateCastValues(self, event)
        if (ttf) then updateCastValues(ttf, event) end
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
                updatePowerValues(ttf)
                updateCastValues(ttf)
                updateRaidMarkers(ttf)
            end
        end
    elseif event == "RAID_TARGET_UPDATE" then
        updateRaidMarkers(self)
        if (ttf) then updateRaidMarkers(ttf, event) end
    elseif event == "UNIT_THREAT_LIST_UPDATE" and self.showThreat then
        updateThreatValues(self)
    elseif UnitIsUnit(unit, self.unit) then
        if event == "UNIT_AURA" then
            UpdateBuffLayout(self, event)
        elseif IsIn(event, "UNIT_MAXHEALTH", "UNIT_HEALTH_FREQUENT", "UNIT_HEAL_PREDICTION") then
            updateHealthValues(self, event)
        elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_UPDATE") then
            updatePowerValues(self)
        elseif IsIn(event, "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_DELAYED") then
            updateCastValues(self)
        elseif IsIn(event, "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_FAILED") then
            hideCastBar(self)
        elseif event == "UNIT_FACTION" then
            updateHealthbarColor(self)
        end
    end
end
GW.AddForProfiling("unitframes", "target_OnEvent", target_OnEvent)

local function focus_OnEvent(self, event, unit)
    local ttf = GwFocusTargetUnitFrame

    if event == "PLAYER_FOCUS_CHANGED" or event == "ZONE_CHANGED" then
        unitFrameData(self, event)
        if (ttf) then unitFrameData(ttf, event) end
        updateHealthValues(self, event)
        if (ttf) then updateHealthValues(ttf, event) end
        updatePowerValues(self)
        if (ttf) then updatePowerValues(ttf) end
        updateCastValues(self, event)
        if (ttf) then updateCastValues(ttf, event) end
        updateRaidMarkers(self, event)
        if (ttf) then updateRaidMarkers(ttf, event) end
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
                unitFrameData(ttf, event)
                updateHealthValues(ttf, event)
                updatePowerValues(ttf)
                updateCastValues(ttf, event)
                updateRaidMarkers(ttf)
            end
        end
    elseif event == "RAID_TARGET_UPDATE" then
        updateRaidMarkers(self)
    elseif UnitIsUnit(unit, self.unit) then
        if event == "UNIT_AURA" then
            UpdateBuffLayout(self, event)
        elseif IsIn(event, "UNIT_MAXHEALTH", "UNIT_HEALTH_FREQUENT", "UNIT_HEAL_PREDICTION") then
            updateHealthValues(self, event)
        elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT") then
            updatePowerValues(self)
        elseif IsIn(event, "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START") then
            updateCastValues(self, event)
        elseif IsIn(event, "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_FAILED") then
            hideCastBar(self, event)
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
    updatePowerValues(self)
    updateCastValues(self)
end
GW.AddForProfiling("unitframes", "unittarget_OnUpdate", unittarget_OnUpdate)

local function LoadTarget()
    local NewUnitFrame = createNormalUnitFrame("GwTargetUnitFrame", GetSetting("target_FRAME_INVERT"))
    NewUnitFrame.unit = "target"
    NewUnitFrame.type = "NormalTarget"
    NewUnitFrame.auraPositionTop = GetSetting("target_AURAS_ON_TOP")

    if NewUnitFrame.auraPositionTop then
        NewUnitFrame.auras:ClearAllPoints()
        if NewUnitFrame.frameInvert then
            NewUnitFrame.auras:SetPoint("TOPRIGHT", NewUnitFrame.nameString, "TOPRIGHT", -2, 17)
        else
            NewUnitFrame.auras:SetPoint("TOPLEFT", NewUnitFrame.nameString, "TOPLEFT", 2, 17)
        end
    elseif GetSetting("target_HOOK_COMBOPOINTS") and (GW.myClassID == 4 or GW.myClassID == 11) then
        NewUnitFrame.auras:ClearAllPoints()
        NewUnitFrame.auras:SetPoint("TOPLEFT", NewUnitFrame.castingbarBackground, "BOTTOMLEFT", 2, -23)
    end

    RegisterMovableFrame(NewUnitFrame, TARGET, "target_pos", "GwTargetFrameTemplateDummy", nil, nil, {"default", "scaleable"})

    NewUnitFrame:ClearAllPoints()
    NewUnitFrame:SetPoint("TOPLEFT", NewUnitFrame.gwMover)

    NewUnitFrame.portrait.mask = NewUnitFrame:CreateMaskTexture()
    NewUnitFrame.portrait.mask:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER", 0, 0)
    NewUnitFrame.portrait.mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    NewUnitFrame.portrait.mask:SetSize(58, 58)
    NewUnitFrame.portrait:AddMaskTexture(NewUnitFrame.portrait.mask)

    NewUnitFrame:SetAttribute("*type1", "target")
    NewUnitFrame:SetAttribute("*type2", "togglemenu")
    NewUnitFrame:SetAttribute("unit", "target")
    RegisterUnitWatch(NewUnitFrame)
    NewUnitFrame:EnableMouse(true)
    NewUnitFrame:RegisterForClicks("AnyDown")

    AddToClique(NewUnitFrame)

    NewUnitFrame.classColor = GetSetting("target_CLASS_COLOR")

    NewUnitFrame.showHealthValue = GetSetting("target_HEALTH_VALUE_ENABLED")
    NewUnitFrame.showHealthPrecentage = GetSetting("target_HEALTH_VALUE_TYPE")

    NewUnitFrame.displayBuffs = GetSetting("target_BUFFS")
    NewUnitFrame.displayDebuffs = GetSetting("target_DEBUFFS")

    NewUnitFrame.showThreat = GetSetting("target_THREAT_VALUE_ENABLED")

    -- priority: All > Important > Player
    NewUnitFrame.debuffFilter = "PLAYER|HARMFUL"
    if GetSetting("target_BUFFS_FILTER_IMPORTANT") then
        NewUnitFrame.debuffFilter = "IMPORTANT"
    end
    if GetSetting("target_BUFFS_FILTER_ALL") then
        NewUnitFrame.debuffFilter = "HARMFUL"
    end

    NewUnitFrame:SetScript("OnEvent", target_OnEvent)

    NewUnitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    NewUnitFrame:RegisterEvent("ZONE_CHANGED")
    NewUnitFrame:RegisterEvent("RAID_TARGET_UPDATE")
    NewUnitFrame:RegisterEvent("UNIT_HEAL_PREDICTION")
    NewUnitFrame:RegisterUnitEvent("UNIT_FACTION", "target")

    NewUnitFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_TARGET", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXPOWER", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_AURA", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", "target")

    --NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "target")
    --NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "target")
    --NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "target")
    --NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "target")
    --NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "target")
    --NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "target")
    --NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "target")
    --NewUnitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "target")

    local CastbarEventHandler = function(event, ...)
        local self = NewUnitFrame
        return target_OnEvent(self, event, ...)
    end

    LCD.RegisterCallback("GW2_UI", "UNIT_BUFF", function(_, unit)
        target_OnEvent(NewUnitFrame, "UNIT_AURA", unit)
    end)

    LCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_START", CastbarEventHandler)
    LCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_DELAYED", CastbarEventHandler) -- only for player
    LCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_STOP", CastbarEventHandler)
    LCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_FAILED", CastbarEventHandler)
    LCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_INTERRUPTED", CastbarEventHandler)
    LCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_CHANNEL_START", CastbarEventHandler)
    LCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_CHANNEL_UPDATE", CastbarEventHandler) -- only for player
    LCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_CHANNEL_STOP", CastbarEventHandler)

    LoadAuras(NewUnitFrame)

    -- create floating combat text
    if GetSetting("TARGET_FLOATING_COMBAT_TEXT") then
        local fctf = CreateFrame("Frame", nil, NewUnitFrame)
        fctf:SetFrameLevel(NewUnitFrame:GetFrameLevel() + 3)
        fctf:RegisterEvent("UNIT_COMBAT")
        fctf:SetScript("OnEvent", function(self, _, unit, ...)
            if self.unit == unit then
                CombatFeedback_OnCombatEvent(self, ...)
            end
        end)
        fctf:SetScript("OnUpdate", CombatFeedback_OnUpdate)
        fctf.unit = NewUnitFrame.unit

        local font = fctf:CreateFontString(nil, "OVERLAY")
        font:SetFont(DAMAGE_TEXT_FONT, 30)
        fctf.fontString = font
        font:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER")
        font:Hide()

        CombatFeedback_Initialize(fctf, font, 30)
    end

    TargetFrame:Kill()
    ComboFrame:Kill()
end
GW.LoadTarget = LoadTarget

local function LoadFocus()
    local NewUnitFrame = createNormalUnitFrame("GwFocusUnitFrame", GetSetting("focus_FRAME_INVERT"))
    NewUnitFrame.unit = "focus"
    NewUnitFrame.type = "NormalTarget"

    RegisterMovableFrame(NewUnitFrame, FOCUS, "focus_pos", "GwTargetFrameTemplateDummy", nil, nil, {"default", "scaleable"})

    NewUnitFrame:ClearAllPoints()
    NewUnitFrame:SetPoint("TOPLEFT", NewUnitFrame.gwMover)

    NewUnitFrame.portrait.mask = NewUnitFrame:CreateMaskTexture()
    NewUnitFrame.portrait.mask:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER", 0, 0)
    NewUnitFrame.portrait.mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    NewUnitFrame.portrait.mask:SetSize(58, 58)
    NewUnitFrame.portrait:AddMaskTexture(NewUnitFrame.portrait.mask)

    NewUnitFrame:SetAttribute("*type1", "target")
    NewUnitFrame:SetAttribute("*type2", "togglemenu")
    NewUnitFrame:SetAttribute("unit", "focus")
    RegisterUnitWatch(NewUnitFrame)
    NewUnitFrame:EnableMouse(true)
    NewUnitFrame:RegisterForClicks("AnyDown")

    AddToClique(NewUnitFrame)

    NewUnitFrame.showHealthValue = GetSetting("focus_HEALTH_VALUE_ENABLED")
    NewUnitFrame.showHealthPrecentage = GetSetting("focus_HEALTH_VALUE_TYPE")

    NewUnitFrame.classColor = GetSetting("focus_CLASS_COLOR")

    NewUnitFrame.displayBuffs = GetSetting("focus_BUFFS")
    NewUnitFrame.displayDebuffs = GetSetting("focus_DEBUFFS")

    -- priority: All > Important > Player
    NewUnitFrame.debuffFilter = "PLAYER"
    if GetSetting("focus_BUFFS_FILTER_IMPORTANT") then
        NewUnitFrame.debuffFilter = "IMPORTANT"
    end
    if GetSetting("focus_BUFFS_FILTER_ALL") then
        NewUnitFrame.debuffFilter = nil
    end

    NewUnitFrame:SetScript("OnEvent", focus_OnEvent)

    NewUnitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    NewUnitFrame:RegisterEvent("ZONE_CHANGED")
    NewUnitFrame:RegisterEvent("RAID_TARGET_UPDATE")
    NewUnitFrame:RegisterEvent("UNIT_HEAL_PREDICTION")

    NewUnitFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "focus")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "focus")
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
    NewUnitFrame:RegisterUnitEvent("UNIT_FACTION", "focus")

    LoadAuras(NewUnitFrame)

    FocusFrame:Kill()
end
GW.LoadFocus = LoadFocus

local function LoadTargetOfUnit(unit)
    local f = createNormalUnitFrameSmall("Gw" .. unit .. "TargetUnitFrame")
    local unitID = string.lower(unit) .. "target"

    f.unit = unitID

    RegisterMovableFrame(f, unit == "Focus" and MINIMAP_TRACKING_FOCUS or SHOW_TARGET_OF_TARGET_TEXT, unitID .. "_pos", "GwTargetFrameSmallTemplateDummy", nil, nil, {"default", "scaleable"})

    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", f.gwMover)

    f:SetAttribute("*type1", "target")
    f:SetAttribute("*type2", "togglemenu")
    f:SetAttribute("unit", unitID)
    RegisterUnitWatch(f)
    f:EnableMouse(true)
    f:RegisterForClicks("AnyDown")

    AddToClique(f)

    f.showHealthValue = false
    f.showHealthPrecentage = false

    f.classColor = GetSetting(string.lower(unit) .. "_CLASS_COLOR")
    f.debuffFilter = nil

    f.totalElapsed = 0.25
    f:SetScript("OnUpdate", unittarget_OnUpdate)
end
GW.LoadTargetOfUnit = LoadTargetOfUnit
