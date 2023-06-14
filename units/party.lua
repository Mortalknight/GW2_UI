local _, GW = ...
local TimeCount = GW.TimeCount
local PowerBarColorCustom = GW.PowerBarColorCustom
local GetSetting = GW.GetSetting
local DEBUFF_COLOR = GW.DEBUFF_COLOR
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local Bar = GW.Bar
local SetClassIcon = GW.SetClassIcon
local AddToClique = GW.AddToClique
local CommaValue = GW.CommaValue
local RoundDec = GW.RoundDec
local UnitAura = GW.Libs.LCD.UnitAuraWithBuffs
local LCD = GW.Libs.LCD

local GW_PORTRAIT_BACKGROUND = {
    [1] = {l = 0, r = 0.828, t = 0, b = 0.166015625},
    [2] = {l = 0, r = 0.828, t = 0.166015625, b = 0.166015625 * 2},
    [3] = {l = 0, r = 0.828, t = 0.166015625 * 2, b = 0.166015625 * 3},
    [4] = {l = 0, r = 0.828, t = 0.166015625 * 3, b = 0.166015625 * 4},
    [5] = {l = 0, r = 0.828, t = 0.166015625 * 4, b = 0.166015625 * 5}
}

local function setPortraitBackground(self, idx)
    self.portraitBackground:SetTexCoord(GW_PORTRAIT_BACKGROUND[idx].l, GW_PORTRAIT_BACKGROUND[idx].r, GW_PORTRAIT_BACKGROUND[idx].t, GW_PORTRAIT_BACKGROUND[idx].b)
end
GW.AddForProfiling("party", "setPortraitBackground", setPortraitBackground)

local function updateAwayData(self)
    if not self.classicon then return end
    local readyCheckStatus = GetReadyCheckStatus(self.unit)
    local instanceId = select(4, UnitPosition(self.unit))
    local playerInstanceId = select(4, UnitPosition("player"))
    local portraitIndex = 1

    if not readyCheckStatus then
        self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons")
        local _, _, classIndex = UnitClass(self.unit)
        if classIndex ~= nil and classIndex ~= 0 then
            SetClassIcon(self.classicon, classIndex)
        end
    end

    if playerInstanceId ~= instanceId then
        portraitIndex = 2
    end

    if not UnitInPhase(self.unit) then
        portraitIndex = 4
        self.classicon:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
        self.classicon:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
    end
    if not UnitIsConnected(self.unit) then
        portraitIndex = 3
    end

    if readyCheckStatus then
        self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/readycheck")
        if readyCheckStatus == "waiting" then
            self.classicon:SetTexCoord(0, 1, 0, 0.25)
        elseif readyCheckStatus == "notready" then
            self.classicon:SetTexCoord(0, 1, 0.25, 0.50)
        elseif readyCheckStatus == "ready" then
            self.classicon:SetTexCoord(0, 1, 0.50, 0.75)
        end
    end

    if UnitThreatSituation(self.unit) and UnitThreatSituation(self.unit) > 2 then
        portraitIndex = 5
    end

    setPortraitBackground(self, portraitIndex)
end
GW.AddForProfiling("party", "updateAwayData", updateAwayData)

local function updateUnitPortrait(self)
    if self.portrait then
        local playerInstanceId = select(4, UnitPosition("player"))
        local instanceId = select(4, UnitPosition(self.unit))

        if playerInstanceId == instanceId then
            SetPortraitTexture(self.portrait, self.unit)
        else
            self.portrait:SetTexture(nil)
        end
    end
end
GW.AddForProfiling("party", "updateUnitPortrait", updateUnitPortrait)

local function getUnitDebuffs(unit)
    local debuffList = {}
    local show_debuffs = GetSetting("PARTY_SHOW_DEBUFFS")
    local only_dispellable_debuffs = GetSetting("PARTY_ONLY_DISPELL_DEBUFFS")
    local show_importend_raid_instance_debuffs = GetSetting("PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF")
    local counter = 1

    for i = 1, 40 do
        if UnitAura(unit, i, "HARMFUL") then
            local debuffName, icon, count, debuffType, duration, expires, caster, isStealable, shouldConsolidate, spellId = UnitAura(unit, i, "HARMFUL")
            local shouldDisplay = false
            local isImportant, isDispellable = false, false

            if show_debuffs then
                if only_dispellable_debuffs then
                    if debuffType and GW.IsDispellableByMe(debuffType) then
                        shouldDisplay = debuffName and not (spellId == 6788 and caster and not UnitIsUnit(caster, "player")) -- Don't show "Weakened Soul" from other players
                    end
                else
                    shouldDisplay = debuffName and not (spellId == 6788 and caster and not UnitIsUnit(caster, "player")) -- Don't show "Weakened Soul" from other players
                end

                isDispellable = GW.IsDispellableByMe(debuffType)
            end

            isImportant = (GW.ImportendRaidDebuff[spellId] and show_importend_raid_instance_debuffs) or false

            if show_importend_raid_instance_debuffs and not shouldDisplay then
                shouldDisplay = GW.ImportendRaidDebuff[spellId] or false
            end

            if shouldDisplay then
                debuffList[counter] = {}

                debuffList[counter].name = debuffName
                debuffList[counter].icon = icon
                debuffList[counter].count = count
                debuffList[counter].dispelType = debuffType
                debuffList[counter].duration = duration
                debuffList[counter].expires = expires
                debuffList[counter].caster = caster
                debuffList[counter].isStealable = isStealable
                debuffList[counter].shouldConsolidate = shouldConsolidate
                debuffList[counter].spellID = spellId
                debuffList[counter].isImportant = isImportant
                debuffList[counter].isDispellable = isDispellable
                debuffList[counter].key = i
                debuffList[counter].timeRemaining = duration <= 0 and 500000 or expires - GetTime()

                counter = counter  + 1
            end
        end
    end

    table.sort(
        debuffList,
        function(a, b)
            return a.timeRemaining < b.timeRemaining
        end
    )

    return debuffList
end
GW.AddForProfiling("party", "getUnitDebuffs", getUnitDebuffs)

local function updatePartyDebuffs(self, x, y)
    if x ~= 0 and not self.isPet then
        y = y + 1
    end
    x = self.isPet and x or 0
    local unit = self.unit
    local debuffList = getUnitDebuffs(unit)
    local debuffScale = GW.GetDebuffScaleBasedOnPrio()

    for i, debuffFrame in pairs(self.debuffFrames) do
        if debuffList[i] then
            debuffFrame.icon:SetTexture(debuffList[i].icon)
            debuffFrame.icon:SetParent(debuffFrame)

            debuffFrame.expires = debuffList[i].expires
            debuffFrame.duration = debuffList[i].duration

            debuffFrame.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
            if debuffList[i].dispelType ~= nil and DEBUFF_COLOR[debuffList[i].dispelType] ~= nil then
                debuffFrame.background:SetVertexColor(DEBUFF_COLOR[debuffList[i].dispelType].r, DEBUFF_COLOR[debuffList[i].dispelType].g, DEBUFF_COLOR[debuffList[i].dispelType].b)
            end

            debuffFrame.cooldown.duration:SetText(debuffList[i].duration > 0 and TimeCount(debuffList[i].timeRemaining) or "")
            debuffFrame.debuffIcon.stacks:SetText((debuffList[i].count or 1) > 1 and debuffList[i].count or "")
            debuffFrame.debuffIcon.stacks:SetFont(UNIT_NAME_FONT, (debuffList[i].count or 1) > 9 and 11 or 14, "OUTLINE")

            debuffFrame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
                GameTooltip:ClearLines()
                GameTooltip:SetUnitDebuff(unit, debuffList[i].key)
                GameTooltip:Show()
            end)
            debuffFrame:SetScript("OnLeave", GameTooltip_Hide)

            local size = self.isPet and 10 or 24
            if debuffList[i].isImportant or debuffList[i].isDispellable then
                if debuffList[i].isImportant and debuffList[i].isDispellable then
                    size = size * debuffScale
                elseif debuffList[i].isImportant then
                    size = size * tonumber(GW.GetSetting("RAIDDEBUFFS_Scale"))
                elseif debuffList[i].isDispellable then
                    size = size * tonumber(GW.GetSetting("DISPELL_DEBUFFS_Scale"))
                end
            end
            debuffFrame:SetSize(size, size)
            local margin = -size + -2
            local marginy = size + 1
            debuffFrame:ClearAllPoints()
            debuffFrame:SetPoint("BOTTOMRIGHT", (self.isPet and (-margin * x) or (26 * x)), (self.isPet and (marginy * y) or (26 * y)))

            debuffFrame:Show()

            x = x + 1
            if (x > 8 and not self.isPet) or (x > 13 and self.isPet) then
                y = y + 1
                x = 0
            end
        else
            debuffFrame:Hide()
            debuffFrame:SetScript("OnEnter", nil)
            debuffFrame:SetScript("OnLeave", nil)
        end
    end
end
GW.AddForProfiling("party", "updatePartyDebuffs", updatePartyDebuffs)

local function getUnitBuffs(unit)
    local buffList = {}

    for i = 1, 40 do
        if UnitAura(unit, i, "HELPFUL") then
            buffList[i] = {}

            buffList[i].name,
            buffList[i].icon,
            buffList[i].count,
            buffList[i].dispelType,
            buffList[i].duration,
            buffList[i].expires,
            buffList[i].caster,
            buffList[i].isStealable,
            buffList[i].shouldConsolidate,
            buffList[i].spellID = UnitAura(unit, i, "HELPFUL")
            buffList[i].key = i
            buffList[i].timeRemaining = buffList[i].duration <= 0 and 500000 or buffList[i].expires - GetTime()
        end
    end

    table.sort(
        buffList,
        function(a, b)
            return a.timeRemaining > b.timeRemaining
        end
    )

    return buffList
end
GW.AddForProfiling("party", "getUnitBuffs", getUnitBuffs)

local function updatePartyAuras(self)
    local x = 0
    local y = 0
    local unit = self.unit

    local buffList = getUnitBuffs(self.unit)

    for i, buffFrame in pairs(self.buffFrames) do
        if buffList[i] then
            local margin = -buffFrame:GetWidth() + -2
            local marginy = self.isPet and buffFrame:GetWidth() + 1 or buffFrame:GetWidth() + 5
            buffFrame.buffIcon:SetTexture(buffList[i].icon)
            buffFrame.buffIcon:SetParent(buffFrame)

            buffFrame.expires = buffList[i].expires
            buffFrame.duration = buffList[i].duration

            buffFrame.buffDuration:SetText("")
            buffFrame.buffStacks:SetText((buffList[i].count or 1) > 1 and buffList[i].count or "")
            buffFrame:ClearAllPoints()
            buffFrame:SetPoint("BOTTOMRIGHT", (-margin * x), marginy * y)

            buffFrame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
                GameTooltip:ClearLines()
                GameTooltip:SetUnitBuff(unit, buffList[i].key)
                GameTooltip:Show()
            end)
            buffFrame:SetScript("OnLeave", GameTooltip_Hide)

            buffFrame:Show()

            x = x + 1
            if (x > 8 and not self.isPet) or (x > 13 and self.isPet) then
                y = y + 1
                x = 0
            end
        else
            buffFrame:Hide()
            buffFrame:SetScript("OnEnter", nil)
            buffFrame:SetScript("OnLeave", nil)
        end
    end
    updatePartyDebuffs(self, x, y)
end
GW.AddForProfiling("party", "updatePartyAuras", updatePartyAuras)

local function setUnitName(self)
    local nameString = UnitName(self.unit)

    if not nameString or nameString == UNKNOWNOBJECT then
        self.nameNotLoaded = false
    else
        self.nameNotLoaded = true
    end

    if UnitIsGroupLeader(self.unit) then
        nameString = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\icon-groupleader:18:18:0:-3|t" .. nameString
    end
    self.name:SetText(nameString)
end
GW.AddForProfiling("party", "setUnitName", setUnitName)

local function setHealthValue(self, healthCur, healthMax, healthPrec)
    self.healthsetting = GetSetting("PARTY_UNIT_HEALTH")
    local healthstring = ""

    if self.healthsetting == "NONE" then
        self.healthstring:Hide()
        return
    end

    if self.healthsetting == "PREC" then
        self.healthstring:SetText(RoundDec(healthPrec *100,0).. "%")
        self.healthstring:SetJustifyH("LEFT")
    elseif self.healthsetting == "HEALTH" then
        self.healthstring:SetText(CommaValue(healthCur))
        self.healthstring:SetJustifyH("LEFT")
    elseif self.healthsetting == "LOSTHEALTH" then
        if healthMax - healthCur > 0 then healthstring = CommaValue(healthMax - healthCur) end
        self.healthstring:SetText(healthstring)
        self.healthstring:SetJustifyH("RIGHT")
    end
    if healthCur == 0 then 
        self.healthstring:SetTextColor(255, 0, 0)
    else
        self.healthstring:SetTextColor(1, 1, 1)
    end
    self.healthstring:Show()
end
GW.AddForProfiling("party", "setHealthValue", setHealthValue)

local function setHealPrediction(self, predictionPrecentage)
    self.predictionbar:SetValue(predictionPrecentage)
end
GW.AddForProfiling("party", "setHealPrediction", setHealPrediction)

local function setHealth(self)
    local health = UnitHealth(self.unit)
    local healthMax = UnitHealthMax(self.unit)
    local healthPrec = 0
    local predictionPrecentage = 0

    if healthMax > 0 then
        healthPrec = health / healthMax
    end

    if (self.healPredictionAmount ~= nil or self.healPredictionAmount == 0) and healthMax ~= 0 then
        predictionPrecentage = math.min(healthPrec + (self.healPredictionAmount / healthMax), 1)
    end
    setHealPrediction(self, predictionPrecentage)
    setHealthValue(self, health, healthMax, healthPrec)
    Bar(self.healthbar, healthPrec)
end
GW.AddForProfiling("party", "setHealth", setHealth)

local function setPredictionAmount(self)
    local prediction = UnitGetIncomingHeals(self.unit) or 0

    self.healPredictionAmount = prediction
    setHealth(self)
end

local function updatePartyData(self)
    if not UnitExists(self.unit) then
        return
    end
    local health = UnitHealth(self.unit)
    local healthMax = UnitHealthMax(self.unit)
    local healthPrec = 0

    local power = UnitPower(self.unit, UnitPowerType(self.unit))
    local powerMax = UnitPowerMax(self.unit, UnitPowerType(self.unit))
    local powerPrecentage = 0

    local _, powerToken = UnitPowerType(self.unit)
    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.powerbar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end

    self.guid = UnitGUID(self.unit)
    self.healPredictionAmount = 0

    if powerMax > 0 then
        powerPrecentage = power / powerMax
    end
    if healthMax > 0 then
        healthPrec = health / healthMax
    end
    Bar(self.healthbar, healthPrec)
    self.powerbar:SetValue(powerPrecentage)

    setHealth(self)
    setUnitName(self)
    updateAwayData(self)
    updateUnitPortrait(self)

    if self.level then
        self.level:SetText(UnitLevel(self.unit))
    end

    if self.classicon then
        SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))
    end

    updatePartyAuras(self)
end
GW.AddForProfiling("party", "updatePartyData", updatePartyData)

local function party_OnEvent(self, event, unit)
    if not UnitExists(self.unit) or IsInRaid() then
        return
    end

    if event == "load" then
        setPredictionAmount(self)
        setHealth(self)
    end
    if not self.nameNotLoaded then
        setUnitName(self)
    end
    if event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH_FREQUENT" and unit == self.unit then
        setHealth(self)
    elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" and unit == self.unit then
        local power = UnitPower(self.unit, UnitPowerType(self.unit))
        local powerMax = UnitPowerMax(self.unit, UnitPowerType(self.unit))
        local powerPrecentage = 0
        if powerMax > 0 then
            powerPrecentage = power / powerMax
        end
        self.powerbar:SetValue(powerPrecentage)
    elseif event == "UNIT_LEVEL" or event == "GROUP_ROSTER_UPDATE" or event == "UNIT_MODEL_CHANGED" then
        updatePartyData(self)
    elseif event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" or event == "UNIT_THREAT_SITUATION_UPDATE" then
        updateAwayData(self)
    elseif event == "UNIT_PORTRAIT_UPDATE" or event == "PORTRAITS_UPDATED" or event == "UNIT_PHASE" then
        updateUnitPortrait(self)
    elseif event == "UNIT_NAME_UPDATE" then
        setUnitName(self)
    elseif event == "UNIT_AURA" then
        updatePartyAuras(self)
    elseif event == "READY_CHECK" or (event == "READY_CHECK_CONFIRM" and unit == self.unit) then
        updateAwayData(self)
    elseif event == "READY_CHECK_FINISHED" then
        C_Timer.After(1.5, function()
            if UnitInParty(self.unit) then
                self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
                SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))
            end
        end)
    end
end
GW.AddForProfiling("party", "party_OnEvent", party_OnEvent)

local function TogglePartyRaid(b)
    if b and not IsInRaid() then
        for i = 1, 4 do
            if _G["GwPartyFrame" .. i] ~= nil then
                _G["GwPartyFrame" .. i]:Show()
                RegisterUnitWatch(_G["GwPartyFrame" .. i])
                _G["GwPartyFrame" .. i]:SetScript("OnEvent", party_OnEvent)
            end
        end
    else
        for i = 1, 4 do
            if _G["GwPartyFrame" .. i] ~= nil then
                _G["GwPartyFrame" .. i]:Hide()
                _G["GwPartyFrame" .. i]:SetScript("OnEvent", nil)
                UnregisterUnitWatch(_G["GwPartyFrame" .. i])
            end
        end
    end
end
GW.TogglePartyRaid = TogglePartyRaid

local function CreatePartyPetFrame(frame, i)
    local unit = frame.unit == "player" and "pet" or "partypet" .. i
    local f = CreateFrame("Button", "GwPartyPetFrame" .. i, UIParent, "GwPartyPetFrame")

    f:SetAttribute("*type1", "target")
    f:SetAttribute("*type2", "togglemenu")
    f:SetAttribute("unit", unit)
    f:EnableMouse(true)
    f:RegisterForClicks("AnyDown")
    f.unit = unit
    f.isPet = true

    if GetSetting("PARTY_SHOW_PETS") then
        RegisterStateDriver(f, "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format(unit))
    else
        RegisterStateDriver(f, "visibility", "hide")
    end

    f.healthbar = f.predictionbar.healthbar
    f.healthstring = f.healthbar.healthstring

    f:ClearAllPoints()
    f:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, -17)

    f:SetScript("OnLeave", GameTooltip_Hide)
    f:SetScript("OnEnter", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(unit)
        GameTooltip:Show()
    end)

    AddToClique(f)

    f.healthbar.spark:SetVertexColor(COLOR_FRIENDLY[1].r, COLOR_FRIENDLY[1].g, COLOR_FRIENDLY[1].b)

    f.healthbar.animationName = unit .. "animation"
    f.healthbar.animationValue = 0

    f:SetScript("OnEvent", party_OnEvent)

    f:RegisterEvent("GROUP_ROSTER_UPDATE")
    f:RegisterEvent("PARTY_MEMBER_DISABLE")
    f:RegisterEvent("PARTY_MEMBER_ENABLE")
    f:RegisterEvent("PORTRAITS_UPDATED")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:RegisterEvent("UNIT_HEAL_PREDICTION")

    f:RegisterUnitEvent("UNIT_AURA", unit)
    f:RegisterUnitEvent("UNIT_PET", frame.unit)
    f:RegisterUnitEvent("UNIT_LEVEL", unit)
    f:RegisterUnitEvent("UNIT_PHASE", unit)
    f:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit)
    f:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    f:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
    f:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    f:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)

    -- create de/buff frames
    f.buffFrames = {}
    f.debuffFrames = {}
    for k = 1, 40 do
        local debuffFrame = CreateFrame("Frame", nil, f.auras,  "GwDeBuffIcon")
        debuffFrame:SetParent(f.auras)
        debuffFrame.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
        debuffFrame.cooldown:SetDrawEdge(0)
        debuffFrame.cooldown:SetDrawSwipe(1)
        debuffFrame.cooldown:SetReverse(1)
        debuffFrame.cooldown:SetHideCountdownNumbers(true)
        debuffFrame:SetSize(10, 10)

        f.debuffFrames[k] = debuffFrame

        local buffFrame = CreateFrame("Button", nil, f.auras, "GwBuffIconBig")
        buffFrame.buffDuration:SetFont(UNIT_NAME_FONT, 11)
        buffFrame.buffDuration:SetTextColor(1, 1, 1)
        buffFrame.buffStacks:SetFont(UNIT_NAME_FONT, 6, "OUTLINED")
        buffFrame.buffStacks:SetTextColor(1, 1, 1)
        buffFrame:SetParent(f.auras)
        buffFrame:SetSize(10, 10)

        f.buffFrames[k] = buffFrame
    end

    party_OnEvent(f, "load")

    updatePartyData(f)
end

local function createPartyFrame(i, isFirstFrame)
    local registerUnit
    if i > 0 then
        registerUnit = "party" .. i
    else
        registerUnit = "player"
    end
    local frame = CreateFrame("Button", "GwPartyFrame" .. i, UIParent, "GwPartyFrame")
    local multiplier = GetSetting("PARTY_PLAYER_FRAME") and 1 or 0

    frame.name:SetFont(UNIT_NAME_FONT, 12)
    frame.name:SetShadowOffset(-1, -1)
    frame.name:SetShadowColor(0, 0, 0, 1)
    frame.level:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINED")
    frame.healthbar = frame.predictionbar.healthbar
    frame.healthstring = frame.healthbar.healthstring

    frame.unit = registerUnit
    frame.guid = UnitGUID(frame.unit)
    frame.ready = -1
    frame.nameNotLoaded = false

    frame:ClearAllPoints()
    if isFirstFrame then
        frame:SetPoint("TOPLEFT", 20, -104 + (-85 * (i + multiplier)) + 85)
    else
        frame:SetPoint("BOTTOMLEFT", _G["GwPartyPetFrame" .. (i - 1)], "BOTTOMLEFT", -15, -90)
    end

    CreatePartyPetFrame(frame, i)

    frame:SetAttribute("unit", registerUnit)
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")

    RegisterStateDriver(frame, "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format(registerUnit))

    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyUp")

    frame:SetScript("OnLeave", GameTooltip_Hide)
    frame:SetScript("OnEnter", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(registerUnit)
        GameTooltip:Show()
    end)

    AddToClique(frame)

    frame.healthbar.spark:SetVertexColor(COLOR_FRIENDLY[1].r, COLOR_FRIENDLY[1].g, COLOR_FRIENDLY[1].b)

    frame.healthbar.animationName = registerUnit .. "animation"
    frame.healthbar.animationValue = 0

    frame:SetScript("OnEvent", party_OnEvent)

    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("PARTY_MEMBER_DISABLE")
    frame:RegisterEvent("PARTY_MEMBER_ENABLE")
    frame:RegisterEvent("READY_CHECK")
    frame:RegisterEvent("READY_CHECK_CONFIRM")
    frame:RegisterEvent("READY_CHECK_FINISHED")
    frame:RegisterEvent("PORTRAITS_UPDATED")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("UNIT_HEAL_PREDICTION")

    frame:RegisterUnitEvent("UNIT_MODEL_CHANGED", registerUnit)
    frame:RegisterUnitEvent("UNIT_AURA", registerUnit)
    frame:RegisterUnitEvent("UNIT_LEVEL", registerUnit)
    frame:RegisterUnitEvent("UNIT_PHASE", registerUnit)
    frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", registerUnit)
    frame:RegisterUnitEvent("UNIT_POWER_UPDATE", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", registerUnit)
    frame:RegisterUnitEvent("UNIT_NAME_UPDATE", registerUnit)
    frame:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", registerUnit)
    frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", registerUnit)

    LCD.RegisterCallback("GW2_UI", "UNIT_BUFF", function(_, unit)
        party_OnEvent(frame, "UNIT_AURA", registerUnit)
    end)

    -- create de/buff frames
    frame.buffFrames = {}
    frame.debuffFrames = {}
    for k = 1, 40 do
        local debuffFrame = CreateFrame("Frame", nil, frame.auras,  "GwDeBuffIcon")
        debuffFrame:SetParent(frame.auras)
        debuffFrame.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
        debuffFrame.cooldown:SetDrawEdge(0)
        debuffFrame.cooldown:SetDrawSwipe(1)
        debuffFrame.cooldown:SetReverse(1)
        debuffFrame.cooldown:SetHideCountdownNumbers(true)
        debuffFrame:SetSize(24, 24)

        frame.debuffFrames[k] = debuffFrame

        local buffFrame = CreateFrame("Button", nil, frame.auras, "GwBuffIconBig")
        buffFrame.buffDuration:SetFont(UNIT_NAME_FONT, 11)
        buffFrame.buffDuration:SetTextColor(1, 1, 1)
        buffFrame.buffStacks:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
        buffFrame.buffStacks:SetTextColor(1, 1, 1)
        buffFrame:SetParent(frame.auras)
        buffFrame:SetSize(20, 20)

        frame.buffFrames[k] = buffFrame
    end

    party_OnEvent(frame, "load")

    updatePartyData(frame)
end
GW.AddForProfiling("party", "createPartyFrame", createPartyFrame)

local function hideBlizzardPartyFrame()
    if InCombatLockdown() then
        return
    end

    for i = 1, MAX_PARTY_MEMBERS do
        if _G["PartyMemberFrame" .. i] then
            _G["PartyMemberFrame" .. i]:Kill()
        end
    end

    if CompactRaidFrameManager then
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:Hide()
    end
end
GW.AddForProfiling("party", "hideBlizzardPartyFrame", hideBlizzardPartyFrame)

local function LoadPartyFrames()
    if not GwManageGroupButton then
        GW.manageButton()
    end

    hideBlizzardPartyFrame()

    if GetSetting("RAID_FRAMES") and GetSetting("RAID_STYLE_PARTY") then
        return
    end
    local isFirstFrame = GetSetting("PARTY_PLAYER_FRAME")

    if GetSetting("PARTY_PLAYER_FRAME") then
        createPartyFrame(0, isFirstFrame)
    end

    isFirstFrame = not GetSetting("PARTY_PLAYER_FRAME")
    for i = 1, MAX_PARTY_MEMBERS do
        createPartyFrame(i, isFirstFrame)
        isFirstFrame = false
    end

    -- Set up preview mode
    GwSettingsPartyPanel.buttonPartyPreview.previewMode = false
    GwSettingsPartyPanel.buttonPartyPreview:SetScript("OnClick", function(self)
        if self.previewMode then
            self:SetText("-")
            for i = 0, MAX_PARTY_MEMBERS do
                if _G["GwPartyFrame" .. i] then
                    _G["GwPartyFrame" .. i].unit = i == 0 and "player" or "party" .. i
                    _G["GwPartyFrame" .. i].guid = UnitGUID(i == 0 and "player" or "party" .. i)
                    _G["GwPartyFrame" .. i]:SetAttribute("unit", (i == 0 and "player" or "party" .. i))
                    UnregisterStateDriver(_G["GwPartyFrame" .. i], "visibility")
                    RegisterStateDriver(_G["GwPartyFrame" .. i], "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format((i == 0 and "player" or "party" .. i)))
                    party_OnEvent(_G["GwPartyFrame" .. i], "load")
                    updatePartyData(_G["GwPartyFrame" .. i])

                    _G["GwPartyPetFrame" .. i].unit = i == 0 and "pet" or "partypet" .. i
                    _G["GwPartyPetFrame" .. i].guid = UnitGUID(i == 0 and "pet" or "partypet" .. i)
                    _G["GwPartyPetFrame" .. i]:SetAttribute("unit", (i == 0 and "pet" or "partypet" .. i))
                    UnregisterStateDriver(_G["GwPartyPetFrame" .. i], "visibility")
                    if GetSetting("PARTY_SHOW_PETS") then
                        RegisterStateDriver(_G["GwPartyPetFrame" .. i], "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format((i == 0 and "pet" or "partypet" .. i)))
                    else
                        RegisterStateDriver(_G["GwPartyPetFrame" .. i], "visibility", "hide")
                    end
                    party_OnEvent(_G["GwPartyPetFrame" .. i], "load")
                    updatePartyData(_G["GwPartyPetFrame" .. i])
                end
            end
            self.previewMode = false
        else
            self:SetText("5")
            for i = 0, MAX_PARTY_MEMBERS do
                if _G["GwPartyFrame" .. i] then
                    _G["GwPartyFrame" .. i].unit = "player"
                    _G["GwPartyFrame" .. i].guid = UnitGUID("player")
                    _G["GwPartyFrame" .. i]:SetAttribute("unit", "player")
                    UnregisterStateDriver(_G["GwPartyFrame" .. i], "visibility")
                    RegisterStateDriver(_G["GwPartyFrame" .. i], "visibility", "show")
                    party_OnEvent(_G["GwPartyFrame" .. i], "load")
                    updatePartyData(_G["GwPartyFrame" .. i])

                    _G["GwPartyPetFrame" .. i].unit = "player"
                    _G["GwPartyPetFrame" .. i].guid = UnitGUID("player")
                    _G["GwPartyPetFrame" .. i]:SetAttribute("unit", "player")
                    UnregisterStateDriver(_G["GwPartyPetFrame" .. i], "visibility")
                    RegisterStateDriver(_G["GwPartyPetFrame" .. i], "visibility", "show")
                    party_OnEvent(_G["GwPartyPetFrame" .. i], "load")
                    updatePartyData(_G["GwPartyPetFrame" .. i])
                end
            end
            self.previewMode = true
        end
    end)
end
GW.LoadPartyFrames = LoadPartyFrames
