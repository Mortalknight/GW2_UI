local _, GW = ...
local GetClassColour = GW.GetClassColour
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local DEBUFF_COLOR = GW.DEBUFF_COLOR
local GetSetting = GW.GetSetting
local TimeCount = GW.TimeCount
local CommaValue = GW.CommaValue
local Diff = GW.Diff
local PowerBarColorCustom = GW.PowerBarColorCustom
local bloodSpark = GW.BLOOD_SPARK
local CLASS_COLORS_RAIDFRAME = GW.CLASS_COLORS_RAIDFRAME
local TARGET_FRAME_ART = GW.TARGET_FRAME_ART
local RegisterMovableFrame = GW.RegisterMovableFrame
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation
local AddToClique = GW.AddToClique
local IsIn = GW.IsIn
local RoundDec = GW.RoundDec
local unitIlvls = {}
local LibClassicDurations = LibStub("LibClassicDurations", true)
local LibCC = LibStub("LibClassicCasterino", true)
LibClassicDurations:Register("GW2_UI")

local textureMapping = {
	[1] = 16,	--Main hand
	[2] = 17,	--Off-hand
	[3] = 18,	--Ranged
}

local function sortAuras(a, b)
    if a["caster"] and b["caster"] and a["caster"] == b["caster"] then
        return a["timeremaning"] < b["timeremaning"]
    end

    return (b["caster"] ~= "player" and a["caster"] == "player")
end
GW.AddForProfiling("unitframes", "sortAuras", sortAuras)

local function sortAuraList(auraList)
    table.sort(
        auraList,
        function(a, b)
            return sortAuras(a, b)
        end
    )

    return auraList
end
GW.AddForProfiling("unitframes", "sortAuraList", sortAuraList)

local buffList = {}
for i = 1, 40 do
    buffList[i] = {}
end
local function getBuffs(unit, filter)
    if filter == nil then
        filter = "HELPFUL"
    end
    local tempCounter = 1
    for i = 1, 40 do
        table.wipe(buffList[i])
        if LibClassicDurations:UnitAura(unit, i, filter) ~= nil then
            local bli = buffList[i]
            tempCounter = tempCounter + 1
            bli["id"] = i
            bli["name"],
            bli["icon"],
            bli["count"],
            bli["dispelType"],
            bli["duration"],
            bli["expires"],
            bli["caster"],
            bli["isStealable"],
            bli["shouldConsolidate"],
            bli["spellID"] = LibClassicDurations:UnitAura(unit, i, filter)

            local durationNew, expirationTimeNew = LibClassicDurations:GetAuraDurationByUnit(
                unit, bli["spellID"], bli["caster"], bli["name"]
            )

            if bli["duration"] == 0 and durationNew then
                bli["duration"] = durationNew
                bli["expires"] = expirationTimeNew
            end

            bli["timeremaning"] = bli["expires"] - GetTime()

            if bli["duration"] <= 0 then
                bli["timeremaning"] = 500001
            end
        end
    end

    --Add temp weaponbuffs if unit is player
    if unit == "player" then
        local RETURNS_PER_ITEM = 4
        local numVals = select("#", GetWeaponEnchantInfo())
        local numItems = numVals / RETURNS_PER_ITEM

        if numItems > 0 then
            TemporaryEnchantFrame:Hide()
            for itemIndex = numItems, 1, -1 do	--Loop through the items from the back
                local hasEnchant, enchantExpiration, enchantCharges = select(RETURNS_PER_ITEM * (itemIndex - 1) + 1, GetWeaponEnchantInfo())
                if hasEnchant then
                    tempCounter = tempCounter + 1
                    if buffList[tempCounter] then
                        table.wipe(buffList[tempCounter])
                    else
                        buffList[tempCounter] = {}
                    end
                    local atc = buffList[tempCounter]
                    atc["id"] = tempCounter
                    atc["name"] = "WeaponTempEnchant"
                    atc["icon"] = GetInventoryItemTexture("player", textureMapping[itemIndex])
                    atc["spellID"] = textureMapping[itemIndex]
                    atc["caster"] = "player"
                    atc["duration"] = enchantExpiration
                    atc["dispelType"] = "Curse"

                    -- Show buff durations if necessary
                    if enchantExpiration then
                        atc["expires"] = enchantExpiration / 1000
                        atc["timeremaning"] = atc["expires"]
                    else
                        atc["timeremaning"] = 500001
                    end
                end
            end
        end
    end

    return sortAuraList(buffList)
end
GW.AddForProfiling("unitframes", "getBuffs", getBuffs)

local debuffList = {}
for i = 1, 40 do
    debuffList[i] = {}
end
local function getDebuffs(unit, filter)
    for i = 1, 40 do
        table.wipe(debuffList[i])
        if UnitDebuff(unit, i, filter) ~= nil then
            local dbi = debuffList[i]
            dbi["id"] = i
            dbi["name"],
            dbi["icon"],
            dbi["count"],
            dbi["dispelType"],
            dbi["duration"],
            dbi["expires"],
            dbi["caster"],
            dbi["isStealable"],
            dbi["shouldConsolidate"],
            dbi["spellID"] = UnitDebuff(unit, i, filter)

            local durationNew, expirationTimeNew = LibClassicDurations:GetAuraDurationByUnit(
                unit, dbi["spellID"], dbi["caster"], dbi["name"]
            )

            if dbi["duration"] == 0 and durationNew then
                dbi["duration"] = durationNew
                dbi["expires"] = expirationTimeNew
            end

            dbi["timeremaning"] = dbi["expires"] - GetTime()

            if dbi["duration"] <= 0 then
                dbi["timeremaning"] = 500001
            end
        end
    end

    return sortAuraList(debuffList)
end
GW.AddForProfiling("unitframes", "getDebuffs", getDebuffs)

local function setAuraType(self, typeAura)
    if self.typeAura == typeAura then
        return
    end

    if typeAura == "smallbuff" then
        self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
        self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
        self.duration:SetFont(UNIT_NAME_FONT, 11)
        self.stacks:SetFont(UNIT_NAME_FONT, 12, "OUTLINED")
    end

    if typeAura == "bigBuff" then
        self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
        self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
        self.duration:SetFont(UNIT_NAME_FONT, 14)
        self.stacks:SetFont(UNIT_NAME_FONT, 14, "OUTLINED")
    end

    self.typeAura = typeAura
end
GW.AddForProfiling("unitframes", "setAuraType", setAuraType)

local function setBuffData(self, buffs, i, oldBuffs)
    if not self or not buffs then
        return false
    end
    local b = buffs[i]
    if b == nil or b["name"] == nil then
        return false
    end

    local stacks = ""
    local duration = ""

    if b["caster"] == "player" and (b["duration"] > 0 and b["duration"] < 120) then
        setAuraType(self, "bigBuff")

        self.cooldown:SetCooldown(b["expires"] - b["duration"], b["duration"])
    else
        setAuraType(self, "smallbuff")
    end

    if b["count"] ~= nil and b["count"] > 1 then
        stacks = b["count"]
    end
    if b["timeremaning"] ~= nil and b["timeremaning"] > 0 and b["timeremaning"] < 500000 then
        duration = TimeCount(b["timeremaning"])
    end

    if b["expires"] < 1 or b["timeremaning"] > 500000 then
        self.expires = nil
    else
        self.expires = b["expires"]
    end

    if self.auraType == "debuff" or b["name"] == "WeaponTempEnchant" then
        if b["dispelType"] ~= nil then
            self.background:SetVertexColor(
                DEBUFF_COLOR[b["dispelType"]].r,
                DEBUFF_COLOR[b["dispelType"]].g,
                DEBUFF_COLOR[b["dispelType"]].b
            )
        else
            self.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
        end
    else
        if b["isStealable"] then
            self.background:SetVertexColor(1, 1, 1)
        else
            self.background:SetVertexColor(0, 0, 0)
        end
    end

    if b["name"] == "WeaponTempEnchant" then
        self.auraid = b["spellID"]
    else
        self.auraid = b["id"]
    end
    self.isTempEnchant = b["name"]
    self.duration:SetText(duration)
    self.stacks:SetText(stacks)
    self.icon:SetTexture(b["icon"])

    return true
end
GW.AddForProfiling("unitframes", "setBuffData", setBuffData)

local function normalUnitFrame_OnEnter(self)
    if self.unit ~= nil then
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(self.unit)
        GameTooltip:Show()
    end
end
GW.AddForProfiling("unitframes", "normalUnitFrame_OnEnter", normalUnitFrame_OnEnter)

local function createNormalUnitFrame(ftype)
    local f = CreateFrame("Button", ftype, UIParent, "GwNormalUnitFrame")

    f.healthString:SetFont(UNIT_NAME_FONT, 11)
    f.healthString:SetShadowOffset(1, -1)

    f.nameString:SetFont(UNIT_NAME_FONT, 14)
    f.nameString:SetShadowOffset(1, -1)

    f.levelString:SetFont(UNIT_NAME_FONT, 14)
    f.levelString:SetShadowOffset(1, -1)

    f.castingString:SetFont(UNIT_NAME_FONT, 12)
    f.castingString:SetShadowOffset(1, -1)

    f.portrait:SetMask(186178)

    f.healthValue = 0

    f.barWidth = 212

    f:SetScript("OnEnter", normalUnitFrame_OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    return f
end
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

    if healthString == "" then
        healthString = self.lastKnownHealth
    end

    if self.healthString == nil then
        self.statusBar.healthString:SetText(healthString)
    else
        self.healthString:SetText(healthString)
    end
end
GW.UpdateHealthTextString = updateHealthTextString
GW.AddForProfiling("unitframes", "updateHealthTextString", updateHealthTextString)

local function updateHealthbarColor(self)
    local frame = self
    if frame.classColor == true and UnitIsPlayer(frame.unit) then
        local red, green, blue, _ = GetClassColour(frame.unit)

        frame.healthbar:SetVertexColor(
            red,
            green,
            blue
        )
        frame.healthbarSpark:SetVertexColor(
            red,
            green,
            blue
        )
        frame.healthbarFlash:SetVertexColor(
            red,
            green,
            blue
        )
        frame.healthbarFlashSpark:SetVertexColor(
            red,
            green,
            blue
        )
        frame.nameString:SetTextColor(
            red,
            green,
            blue
        )

        --local r, g, b, _ = frame.nameString:GetTextColor()
        --frame.nameString:SetTextColor(r + 0.3, g + 0.3, b + 0.3, 1)
    else
        local isFriend = UnitIsFriend("player", frame.unit)
        local friendlyColor = COLOR_FRIENDLY[1]

        if isFriend ~= true then
            friendlyColor = COLOR_FRIENDLY[2]
        end
        if UnitIsTapDenied(frame.unit) then
            friendlyColor = COLOR_FRIENDLY[3]
        end

        frame.healthbar:SetVertexColor(friendlyColor.r, friendlyColor.g, friendlyColor.b, 1)
        frame.healthbarSpark:SetVertexColor(friendlyColor.r, friendlyColor.g, friendlyColor.b, 1)
        frame.healthbarFlash:SetVertexColor(friendlyColor.r, friendlyColor.g, friendlyColor.b, 1)
        frame.healthbarFlashSpark:SetVertexColor(friendlyColor.r, friendlyColor.g, friendlyColor.b, 1)
        frame.nameString:SetTextColor(friendlyColor.r, friendlyColor.g, friendlyColor.b, 1)
    end

    if (UnitLevel(frame.unit) - UnitLevel("player")) <= -5 then
        local r, g, b, _ = frame.nameString:GetTextColor()
        frame.nameString:SetTextColor(r + 0.5, g + 0.5, b + 0.5, 1)
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
        bloodSpark[bI].left,
        bloodSpark[bI].right,
        bloodSpark[bI].top,
        bloodSpark[bI].bottom
    )
    hbSpark:SetPoint(
        "LEFT",
        hbbg,
        "LEFT",
        math.max(0, math.min(powerBarWidth - bit, math.floor(spark))),
        0
    )
    hb:SetPoint(
        "RIGHT",
        hbbg,
        "LEFT",
        math.max(0, math.min(powerBarWidth, spark)) + 1,
        0
    )
end
GW.AddForProfiling("unitframes", "healthBarAnimation", healthBarAnimation)

local function setUnitPortraitFrame(self, event)
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

local function updateRaidMarkers(self, event)
    local i = GetRaidTargetIndex(self.unit)
    if i == nil then
        self.raidmarker:SetTexture(nil)
        return
    end
    self.raidmarker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i)
end
GW.AddForProfiling("unitframes", "updateRaidMarkers", updateRaidMarkers)

local function setUnitPortrait(self, event)
    if self.portrait == nil then
        return
    end
    SetPortraitTexture(self.portrait, self.unit)
    self.activePortrait = ""
end
GW.AddForProfiling("unitframes", "setUnitPortrait", setUnitPortrait)

local function unitFrameData(self, event)
    local level = UnitLevel(self.unit)
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

    setUnitPortraitFrame(self, event)
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

local function hideCastBar(self, event)
    self.castingbarBackground:Hide()
    self.castingString:Hide()

    self.castingbar:Hide()
    self.castingbarSpark:Hide()

    self.castingbarNormal:Hide()
    self.castingbarNormalSpark:Hide()

    self.castingbarBackground:SetPoint("TOPLEFT", self.powerbarBackground, "BOTTOMLEFT", -2, 19)

    if self.portrait ~= nil then
        setUnitPortrait(self, event)
    end

    if animations["GwUnitFrame" .. self.unit .. "Cast"] ~= nil then
        animations["GwUnitFrame" .. self.unit .. "Cast"]["completed"] = true
        animations["GwUnitFrame" .. self.unit .. "Cast"]["duration"] = 0
    end
end
GW.AddForProfiling("unitframes", "hideCastBar", hideCastBar)

local function updateCastValues(self, event)
    local castType = 1

    local name, _, texture, startTime, endTime, _, _, notInterruptible, spellID = LibCC:UnitCastingInfo(self.unit)

    if name == nil then
        name, _, texture, startTime, endTime, _, notInterruptible = LibCC:UnitChannelInfo(self.unit)
        castType = 0
    end

    if name == nil  then
        hideCastBar(self, event)
        return
    end

    startTime = startTime / 1000
    endTime = endTime / 1000

    self.castingString:SetText(name)

    self.castingbarBackground:Show()
    self.castingbarBackground:SetPoint("TOPLEFT", self.powerbarBackground, "BOTTOMLEFT", -2, -1)
    self.castingString:Show()

    if notInterruptible then
        self.castingbarNormal:Hide()
        self.castingbarNormalSpark:Hide()

        self.castingbar:Show()
        self.castingbarSpark:Show()
    else
        self.castingbar:Hide()
        self.castingbarSpark:Hide()

        self.castingbarNormal:Show()
        self.castingbarNormalSpark:Show()
    end

    AddToAnimation(
        "GwUnitFrame" .. self.unit .. "Cast",
        0,
        1,
        startTime,
        endTime - startTime,
        function(step)
            if castType == 0 then
                step = 1 - step
            end
            if notInterruptible then
                protectedCastAnimation(self, step)
            else
                normalCastBarAnimation(self, step)
            end
        end,
        "noease"
    )
end
GW.AddForProfiling("unitframes", "updateCastValues", updateCastValues)

local function updatePowerValues(self, event)
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

    local powerBarWidth = math.min(self.barWidth, math.max(1, self.barWidth * powerPrecentage))
    self.powerbar:SetWidth(powerBarWidth - 1)
end
GW.AddForProfiling("unitframes", "updatePowerValues", updatePowerValues)

local function updateHealthValues(self, event)
    local health = 0
    local healthMax = 0
    local healthPrecentage = 0

    if IsAddOnLoaded("RealMobHealth") then
        health, healthMax = RealMobHealth.GetUnitHealth(self.unit)
        if health == nil or health < 0 then
            health = UnitHealth(self.unit)
        end
        if healthMax == nil or healthMax < 0 then
            healthMax = UnitHealthMax(self.unit)
        end
    else
        health = UnitHealth(self.unit)
        healthMax = UnitHealthMax(self.unit)
    end

    if health > 0 and healthMax > 0 then
        healthPrecentage = health / healthMax
    end

    local animationSpeed = 0

    if event == "UNIT_TARGET" or event == "PLAYER_TARGET_CHANGED" then
        animationSpeed = 0
        self.healthValue = healthPrecentage
        StopAnimation(self:GetName() .. self.unit)
    else
        animationSpeed = Diff(self.healthValue, healthPrecentage)
        animationSpeed = math.min(1.00, math.max(0.2, 2.00 * animationSpeed))
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

local function auraAnimateIn(self)
    local endWidth = self:GetWidth()

    AddToAnimation(
        self:GetName(),
        endWidth * 2,
        endWidth,
        GetTime(),
        0.2,
        function(step)
            self:SetSize(step, step)
        end
    )
end
GW.AddForProfiling("unitframes", "auraAnimateIn", auraAnimateIn)

local function UpdateBuffLayout(self, event, anchorPos)
    local minIndex = 1
    local maxIndex = 80

    local isPlayer = false
    if anchorPos and anchorPos == "player" then
        isPlayer = true
    elseif anchorPos ~= "player" then
        if self.displayBuffs ~= true then
            minIndex = 40
        end
        if self.displayDebuffs ~= true then
            maxIndex = 40
        end
    end

    local marginX = 3
    local marginY = 20

    local usedWidth = 0
    local usedHeight = 0

    local smallSize
    local bigSize
    local maxSize

    if isPlayer then
        maxSize = self:GetWidth()
        smallSize = 28
        bigSize = 32
    else
        maxSize = self.auras:GetWidth()
        smallSize = 20
        bigSize = 28
    end

    local lineSize = smallSize

    local auraList = getBuffs(self.unit)
    local dbList = getDebuffs(self.unit, self.debuffFilter)

    local saveAuras = {}

    saveAuras["buff"] = {}
    saveAuras["debuff"] = {}

    local fUnit
    if isPlayer then
        fUnit = "player"
    else
        fUnit = self.unit
    end

    local isBuff = false
    for frameIndex = minIndex, maxIndex do
        local index
        if isPlayer then
            index = 41 - frameIndex
        else
            index = frameIndex
        end
        local list = auraList
        local newAura = true

        if frameIndex > 40 then
            if isPlayer then
                index = 41 - (frameIndex - 40)
            else
                index = frameIndex - 40
            end
        end

        local frame = _G["Gw" .. fUnit .. "buffFrame" .. index]

        if frameIndex > 40 then
            frame = _G["Gw" .. fUnit .. "debuffFrame" .. index]
            list = dbList
        end

        if frameIndex == 41 and isBuff then
            usedWidth = 0
            usedHeight = usedHeight + lineSize + marginY
            lineSize = smallSize
        end

        if setBuffData(frame, list, index) then
            if frameIndex <= 40 then
                isBuff = true
            end
            if not frame:IsShown() then
                frame:Show()
            end

            local isBig = frame.typeAura == "bigBuff"

            local size = smallSize
            if isBig then
                size = bigSize
                lineSize = bigSize

                for k, v in pairs(self.saveAuras[frame.auraType]) do
                    if v == list[index]["name"] then
                        newAura = false
                    end
                end
                self.animating = false
                saveAuras[frame.auraType][#saveAuras[frame.auraType] + 1] = list[index]["name"]
            end

            local px = usedWidth + (size / 2)
            local py = usedHeight + (size / 2)
            if not anchorPos then
                frame:SetPoint("CENTER", self.auras, "TOPLEFT", px, -py)
            elseif anchorPos == "pet" then
                frame:SetPoint("CENTER", self.auras, "BOTTOMRIGHT", -px, py)
            elseif anchorPos == "player" then
                frame:SetPoint("CENTER", GwPlayerHealthBar.auras, "CENTER", -px, py)
            end

            frame:SetSize(size, size)
            if newAura and isBig and event == "UNIT_AURA" then
                auraAnimateIn(frame)
            end

            usedWidth = usedWidth + size + marginX
            if maxSize < usedWidth then
                usedWidth = 0
                usedHeight = usedHeight + lineSize + marginY
                lineSize = smallSize
            end
        elseif frame and frame:IsShown() then
            frame:Hide()
        end
    end

    self.saveAuras = saveAuras
end
GW.UpdateBuffLayout = UpdateBuffLayout

local function auraFrame_OnUpdate(self, elapsed)
    if self.throt < 0 and self.expires ~= nil and self:IsShown() then
        self.throt = 0.2
        self.duration:SetText(TimeCount(self.expires - GetTime()))
    else
        self.throt = self.throt - elapsed
    end
end
GW.AddForProfiling("unitframes", "auraFrame_OnUpdate", auraFrame_OnUpdate)

local function auraFrame_OnEnter(self)
    if self:IsShown() and self.auraid ~= nil and self.unit ~= nil then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:ClearLines()
        if self.isTempEnchant == "WeaponTempEnchant" then
            GameTooltip:SetInventoryItem("player", self.auraid)
        else
            if self.auraType == "buff" then
                GameTooltip:SetUnitBuff(self.unit, self.auraid)
            else
                GameTooltip:SetUnitDebuff(self.unit, self.auraid, self.debuffFilter)
            end
        end
        GameTooltip:Show()
    end
end
GW.AddForProfiling("unitframes", "auraFrame_OnEnter", auraFrame_OnEnter)

local function auraFrame_OnClick(self, button, down)
    if not InCombatLockdown() and self.auraType == "buff" and button == "RightButton" and self.unit == "player" then
        CancelUnitBuff("player", self.auraid)
    elseif self.isTempEnchant == "WeaponTempEnchant" then
        if self.auraid == 16 then
            CancelItemTempEnchantment(1)
        elseif self.auraid == 17 then
            CancelItemTempEnchantment(2)
        elseif self.auraid == 18 then
            CancelItemTempEnchantment(3)
        end
    end
end
GW.AddForProfiling("unitframes", "auraFrame_OnClick", auraFrame_OnClick)

local function CreateAuraFrame(name, parent)
    local f = CreateFrame("Button", name, parent, "GwAuraFrame")
    local fs = f.status

    f.typeAura = "smallbuff"
    f.cooldown:SetDrawEdge(0)
    f.cooldown:SetDrawSwipe(1)
    f.cooldown:SetReverse(false)
    f.cooldown:SetHideCountdownNumbers(true)
    f.throt = -1

    fs.stacks:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
    fs.duration:SetFont(UNIT_NAME_FONT, 10)
    fs.duration:SetShadowOffset(1, -1)

    fs:GetParent().duration = fs.duration
    fs:GetParent().stacks = fs.stacks
    fs:GetParent().icon = fs.icon

    f:SetScript("OnUpdate", auraFrame_OnUpdate)
    f:SetScript("OnEnter", auraFrame_OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)
    f:SetScript("OnClick", auraFrame_OnClick)
    --f:SetAttribute('type2', 'cancelaura')

    return f
end
GW.CreateAuraFrame = CreateAuraFrame

local function LoadAuras(f, a, u)
    local unit = u or f.unit
    for i = 1, 40 do
        local frame = CreateAuraFrame("Gw" .. unit .. "buffFrame" .. i, a)
        frame.unit = unit
        frame.auraType = "buff"
        frame = CreateAuraFrame("Gw" .. unit .. "debuffFrame" .. i, a)
        frame.unit = unit
        frame.auraType = "debuff"
    end
    f.saveAuras = {}
    f.saveAuras["buff"] = {}
    f.saveAuras["debuff"] = {}
end
GW.LoadAuras = LoadAuras

local function target_OnEvent(self, event, unit)

    local ttf = GwTargetTargetUnitFrame

    if IsIn(event, "PLAYER_TARGET_CHANGED", "ZONE_CHANGED") then
        unitFrameData(self, event)
        updateHealthValues(self, event)
        updatePowerValues(self, event)
        updateCastValues(self, event)
        updateRaidMarkers(self, event)
        UpdateBuffLayout(self, event)
        if (ttf) then
            unitFrameData(ttf, event)
            updateHealthValues(ttf, event)
            updatePowerValues(ttf, event)
            updateCastValues(ttf, event)
            updateRaidMarkers(ttf, event)
        end
    elseif event == "UNIT_TARGET" and unit == "target" then
        if (ttf ~= nil) then
            if UnitExists("targettarget") then
                unitFrameData(ttf, event)
                updateHealthValues(ttf, event)
                updatePowerValues(ttf, event)
                updateCastValues(ttf, event)
                updateRaidMarkers(ttf, event)
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        wipe(unitIlvls)
    elseif event == "RAID_TARGET_UPDATE" then
        updateRaidMarkers(self, event)
        if (ttf) then updateRaidMarkers(ttf, event) end
    elseif UnitIsUnit(unit, self.unit) then
        if event == "UNIT_AURA" then
            UpdateBuffLayout(self, event)
        elseif IsIn(event, "UNIT_MAXHEALTH", "UNIT_HEALTH") then
            updateHealthValues(self, event)
        elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_UPDATE") then
            updatePowerValues(self, event)
        elseif IsIn(event, "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_DELAYED") then
            updateCastValues(self, event)
        elseif IsIn(event, "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_FAILED") then
            hideCastBar(self, event)
        elseif event == "UNIT_FACTION" then
            updateHealthbarColor(self)
        end
    end
end
GW.AddForProfiling("unitframes", "target_OnEvent", target_OnEvent)

local function updateRestFrame(self)
    local frame = self
    if IsResting() then
        frame.restMarker:Show()
    else
        frame.restMarker:Hide()
    end
end
GW.AddForProfiling("unitframes", "updateRestFrame", updateRestFrame)

local function portrait_OnEvent(self, event)
    local frame = self
    if event == "RAID_TARGET_UPDATE" then
        updateRaidMarkers(frame, event)
    elseif event == "PLAYER_UPDATE_RESTING" then
        updateRestFrame(frame)
    elseif event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" then
        SetPortraitTexture(frame.portrait, frame.unit)
    end
end
GW.AddForProfiling("unitframes", "portrait_OnEvent", portrait_OnEvent)

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
    local NewUnitFrame = createNormalUnitFrame("GwTargetUnitFrame")
    NewUnitFrame.unit = "target"

    NewUnitFrame:SetAttribute("unit", NewUnitFrame.unit)
    NewUnitFrame:SetAttribute("*type1", NewUnitFrame.unit)
    NewUnitFrame:SetAttribute("*type2", "togglemenu")

    RegisterMovableFrame("targetframe", NewUnitFrame, "target_pos", "GwTargetFrameTemplateDummy")

    NewUnitFrame:ClearAllPoints()
    NewUnitFrame:SetPoint(
        GetSetting("target_pos")["point"],
        UIParent,
        GetSetting("target_pos")["relativePoint"],
        GetSetting("target_pos")["xOfs"],
        GetSetting("target_pos")["yOfs"]
    )

    RegisterUnitWatch(NewUnitFrame)

    NewUnitFrame:EnableMouse(true)
    NewUnitFrame:RegisterForClicks("AnyDown")

    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER", 0, 0)

    mask:SetTexture("Textures\\MinimapMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(58, 58)
    NewUnitFrame.portrait:AddMaskTexture(mask)

    AddToClique(NewUnitFrame)

    NewUnitFrame.classColor = GetSetting("target_CLASS_COLOR")
    --NewUnitFrame.classColor = GetClassColour("Target")

    NewUnitFrame.showHealthValue = GetSetting("target_HEALTH_VALUE_ENABLED")
    NewUnitFrame.showHealthPrecentage = GetSetting("target_HEALTH_VALUE_TYPE")

    NewUnitFrame.displayBuffs = GetSetting("target_BUFFS")
    NewUnitFrame.displayDebuffs = GetSetting("target_DEBUFFS")

    NewUnitFrame.debuffFilter = "player"

    if GetSetting("target_BUFFS_FILTER_ALL") == true then
        NewUnitFrame.debuffFilter = nil
    end

    NewUnitFrame:SetScript("OnEvent", target_OnEvent)

    NewUnitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    NewUnitFrame:RegisterEvent("ZONE_CHANGED")
    NewUnitFrame:RegisterEvent("RAID_TARGET_UPDATE")
    NewUnitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    NewUnitFrame:RegisterUnitEvent("UNIT_FACTION", "target")

    NewUnitFrame:RegisterUnitEvent("UNIT_HEALTH", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_TARGET", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXPOWER", "target")
    NewUnitFrame:RegisterUnitEvent("UNIT_AURA", "target")

    local CastbarEventHandler = function(event, ...)
        local self = NewUnitFrame
        return target_OnEvent(self, event, ...)
    end

    LibCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_START", CastbarEventHandler)
    LibCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_DELAYED", CastbarEventHandler) -- only for player
    LibCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_STOP", CastbarEventHandler)
    LibCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_FAILED", CastbarEventHandler)
    LibCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_INTERRUPTED", CastbarEventHandler)
    LibCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_CHANNEL_START", CastbarEventHandler)
    LibCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_CHANNEL_UPDATE", CastbarEventHandler) -- only for player
    LibCC.RegisterCallback(NewUnitFrame, "UNIT_SPELLCAST_CHANNEL_STOP", CastbarEventHandler)

    LibClassicDurations.RegisterCallback(NewUnitFrame, "UNIT_BUFF", function(event, unit)
        target_OnEvent(NewUnitFrame, "UNIT_AURA", unit)
    end)

    LoadAuras(NewUnitFrame, NewUnitFrame.auras)

    TargetFrame:SetScript("OnEvent", nil)
    TargetFrame:Hide()
    ComboFrame:SetScript("OnShow", function() ComboFrame:Hide() end)
end
GW.LoadTarget = LoadTarget

local function LoadTargetOfUnit(unit)
    local frame = createNormalUnitFrameSmall("Gw" .. unit .. "TargetUnitFrame")
    local unitID = string.lower(unit) .. "target"

    frame.unit = unitID

    RegisterMovableFrame(unitID .. "frame", frame, unitID .. "_pos", "GwTargetFrameSmallTemplateDummy")

    frame:ClearAllPoints()
    frame:SetPoint(
        GetSetting(unitID .. "_pos")["point"],
        UIParent,
        GetSetting(unitID .. "_pos")["relativePoint"],
        GetSetting(unitID .. "_pos")["xOfs"],
        GetSetting(unitID .. "_pos")["yOfs"]
    )

    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame:SetAttribute("unit", unitID)
    RegisterUnitWatch(frame)
    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyDown")

    AddToClique(frame)

    frame.showHealthValue = false
    frame.showHealthPrecentage = false

    frame.classColor = GetSetting(string.lower(unit) .. "_CLASS_COLOR")
    frame.debuffFilter = nil

    frame.totalElapsed = 0.25
    frame:SetScript("OnUpdate", unittarget_OnUpdate)
end
GW.LoadTargetOfUnit = LoadTargetOfUnit


local function LoadPortraitFrame()

    PlayerFrame:SetScript("OnEvent", nil)
    PlayerFrame:Hide()

    DurabilityFrame:UnregisterAllEvents()
    DurabilityFrame:HookScript("OnShow", GW.Self_Hide)
    DurabilityFrame:Hide()

    local frame = CreateFrame("Button", "GwPlayerPortrateFrame", UIParent, "GwPlayerPortrateFrame")
    frame.unit = "Player"

    --RegisterMovableFrame("portraitFrame", frame, "target_pos", "GwTargetFrameTemplateDummy")

    frame.nameString:SetFont(UNIT_NAME_FONT, 14)
    frame.nameString:SetShadowOffset(1, -1)
    frame.nameString:SetText(UnitName(frame.unit))

    local level = UnitLevel(frame.unit)

    frame.levelString:SetFont(UNIT_NAME_FONT, 14)
    frame.levelString:SetShadowOffset(1, -1)
    frame.levelString:SetText(level)

    frame.restMarker:Hide()

    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyDown")

    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame:SetAttribute("unit", "player")

    frame:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "Player")
    frame:RegisterUnitEvent("UNIT_MODEL_CHANGED", "Player")
    frame:RegisterEvent("PLAYER_UPDATE_RESTING")
    frame:RegisterEvent("RAID_TARGET_UPDATE")

    frame:SetScript("OnEvent", portrait_OnEvent)

    AddToClique(frame)

    frame.portrait:SetMask(186178)

    local mask = frame:CreateMaskTexture()
    mask:SetPoint("CENTER", frame.portrait, "CENTER", 0, 0)
    mask:SetTexture("Textures\\MinimapMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(92, 92)
    frame.portrait:AddMaskTexture(mask)

    updateRaidMarkers(frame)
    updateRestFrame(frame)

    SetPortraitTexture(frame.portrait, frame.unit)

    return frame
end
GW.LoadPortraitFrame = LoadPortraitFrame
