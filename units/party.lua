local _, GW = ...
local TimeCount = GW.TimeCount
local PowerBarColorCustom = GW.PowerBarColorCustom
local DebuffColors = GW.Libs.Dispel:GetDebuffTypeColor()
local BleedList = GW.Libs.Dispel:GetBleedList()
local BadDispels = GW.Libs.Dispel:GetBadList()
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local Bar = GW.Bar
local SetClassIcon = GW.SetClassIcon
local AddToClique = GW.AddToClique
local CommaValue = GW.CommaValue
local RoundDec = GW.RoundDec
local IsIn = GW.IsIn
local nameRoleIcon = GW.nameRoleIcon

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
    local playerInstanceId = select(4, UnitPosition("player"))
    local instanceId = select(4, UnitPosition(self.unit))
    local readyCheckStatus = GetReadyCheckStatus(self.unit)
    local phaseReason = UnitPhaseReason(self.unit)
    local portraitIndex = 1

    if not readyCheckStatus and not UnitHasIncomingResurrection(self.unit) and not C_IncomingSummon.HasIncomingSummon(self.unit) then 
        self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
        SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))
    end

    if playerInstanceId ~= instanceId then
        portraitIndex = 2
    end

    if phaseReason then
        portraitIndex = 4
    end

    if UnitHasIncomingResurrection(self.unit) then
        self.classicon:SetTexture("Interface/RaidFrame/Raid-Icon-Rez")
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
    end

    if C_IncomingSummon.HasIncomingSummon(self.unit) then
        local status = C_IncomingSummon.IncomingSummonStatus(self.unit)
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
        if status == Enum.SummonStatus.Pending then
            self.classicon:SetAtlas("Raid-Icon-SummonPending")
        elseif status == Enum.SummonStatus.Accepted then
            self.classicon:SetAtlas("Raid-Icon-SummonAccepted")
        elseif status == Enum.SummonStatus.Declined then
            self.classicon:SetAtlas("Raid-Icon-SummonDeclined")
        end
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

        if playerInstanceId == instanceId and not UnitPhaseReason(self.unit) then
            SetPortraitTexture(self.portrait, self.unit)
        else
            self.portrait:SetTexture(nil)
        end
    end
end
GW.AddForProfiling("party", "updateUnitPortrait", updateUnitPortrait)

local function getUnitDebuffs(unit)
    local debuffList = {}
    local counter = 1

    for i = 1, 40 do
        local auraData = C_UnitAuras.GetDebuffDataByIndex(unit, i, "HARMFUL")
        if auraData then
            local shouldDisplay = false
            local isImportant = (GW.ImportendRaidDebuff[auraData.spellId] and GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF) or false
            local isDispellable = GW.Libs.Dispel:IsDispellableByMe(auraData.dispelName)

            if GW.settings.PARTY_SHOW_DEBUFFS then
                if GW.settings.PARTY_ONLY_DISPELL_DEBUFFS then
                    if auraData.dispelName and GW.Libs.Dispel:IsDispellableByMe(auraData.dispelName) then
                        shouldDisplay = auraData.name and not (auraData.spellId == 6788 and auraData.sourceUnit and not UnitIsUnit(auraData.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
                    end
                else
                    shouldDisplay = auraData.name and not (auraData.spellId == 6788 and auraData.sourceUnit and not UnitIsUnit(auraData.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
                end
            end

            if GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF and not shouldDisplay then
                shouldDisplay = GW.ImportendRaidDebuff[auraData.spellId] or false
            end

            if shouldDisplay then
                debuffList[counter] = {}

                debuffList[counter].name = auraData.name
                debuffList[counter].icon = auraData.icon
                debuffList[counter].count = auraData.applications
                debuffList[counter].dispelType = auraData.dispelName
                debuffList[counter].duration = auraData.duration
                debuffList[counter].expires = auraData.expirationTime
                debuffList[counter].caster = auraData.sourceUnit
                debuffList[counter].isStealable = auraData.isStealable
                debuffList[counter].shouldConsolidate = auraData.nameplateShowPersonal
                debuffList[counter].spellID = auraData.spellId
                debuffList[counter].isImportant = isImportant
                debuffList[counter].isDispellable = isDispellable
                debuffList[counter].key = i
                debuffList[counter].timeRemaining = auraData.duration <= 0 and 500000 or auraData.expirationTime - GetTime()

                counter = counter  + 1
            end
        end
    end

    table.sort(
        debuffList,
        function(a, b)
            return a.timeRemaining > b.timeRemaining
        end
    )

    return debuffList
end
GW.AddForProfiling("party", "getUnitDebuffs", getUnitDebuffs)

local function DebuffOnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:ClearLines()
    GameTooltip:SetUnitDebuff(self.unit, self.key)
    GameTooltip:Show()
end

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
            debuffFrame.key = debuffList[i].key
            debuffFrame.unit = unit

            if debuffList[i].dispelType and BadDispels[debuffList[i].spellID] and GW.Libs.Dispel:IsDispellableByMe(debuffList[i].dispelType) then
                debuffList[i].dispelType = "BadDispel"
            end
            if not debuffList[i].dispelType and BleedList[debuffList[i].spellID] and GW.Libs.Dispel:IsDispellableByMe("Bleed") then
                debuffList[i].dispelType = "Bleed"
            end

            debuffFrame.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
            if debuffList[i].dispelType and DebuffColors[debuffList[i].dispelType] then
                debuffFrame.background:SetVertexColor(DebuffColors[debuffList[i].dispelType].r, DebuffColors[debuffList[i].dispelType].g, DebuffColors[debuffList[i].dispelType].b)
            end

            debuffFrame.cooldown.duration:SetText(debuffList[i].duration > 0 and TimeCount(debuffList[i].timeRemaining) or "")
            debuffFrame.debuffIcon.stacks:SetText((debuffList[i].count or 1) > 1 and debuffList[i].count or "")
            debuffFrame.debuffIcon.stacks:SetFont(UNIT_NAME_FONT, (debuffList[i].count or 1) > 9 and 11 or 14, "OUTLINE")

            debuffFrame:SetScript("OnEnter", DebuffOnEnter)
            debuffFrame:SetScript("OnLeave", GameTooltip_Hide)
            debuffFrame:SetScript("OnUpdate", function(self, elapsed)
                if self.throt < 0 and self.expires ~= nil and self:IsShown() then
                    self.throt = 0.2
                    if GameTooltip:IsOwned(self) then
                        DebuffOnEnter(self)
                    end
                else
                    self.throt = self.throt - elapsed
                end
            end)

            local size = self.isPet and 10 or 24
            if debuffList[i].isImportant or debuffList[i].isDispellable then
                if debuffList[i].isImportant and debuffList[i].isDispellable then
                    size = size * debuffScale
                elseif debuffList[i].isImportant then
                    size = size * tonumber(GW.settings.RAIDDEBUFFS_Scale)
                elseif debuffList[i].isDispellable then
                    size = size * tonumber(GW.settings.DISPELL_DEBUFFS_Scale)
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
            debuffFrame:SetScript("OnUpdate", nil)
        end
    end
end
GW.AddForProfiling("party", "updatePartyDebuffs", updatePartyDebuffs)

local function getUnitBuffs(unit)
    local buffList = {}

    for i = 1, 40 do
        local auraData = C_UnitAuras.GetBuffDataByIndex(unit, i)
        if auraData then
            buffList[i] = {}
            buffList[i].key = i

            buffList[i].name = auraData.name
            buffList[i].icon = auraData.icon
            buffList[i].count = auraData.applications
            buffList[i].dispelType = auraData.dispelName
            buffList[i].duration = auraData.duration
            buffList[i].expires = auraData.expirationTime
            buffList[i].caster = auraData.sourceUnit
            buffList[i].isStealable = auraData.isStealable
            buffList[i].shouldConsolidate = auraData.nameplateShowPersonal
            buffList[i].spellID = auraData.spellId

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

local function BuffOnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetUnitBuff(self.unit, self.key)
    GameTooltip:Show()
end

local function updatePartyAuras(self)
    local x = 0
    local y = 0
    local unit = self.unit

    local buffList = getUnitBuffs(unit)

    for i, buffFrame in pairs(self.buffFrames) do
        if buffList[i] then
            local margin = -buffFrame:GetWidth() + -2
            local marginy = self.isPet and buffFrame:GetWidth() + 1 or buffFrame:GetWidth() + 5
            buffFrame.buffIcon:SetTexture(buffList[i].icon)
            buffFrame.buffIcon:SetParent(buffFrame)

            buffFrame.expires = buffList[i].expires
            buffFrame.duration = buffList[i].duration
            buffFrame.key = buffList[i].key
            buffFrame.unit = unit

            buffFrame.buffDuration:SetText("")
            buffFrame.buffStacks:SetText((buffList[i].count or 1) > 1 and buffList[i].count or "")
            buffFrame:ClearAllPoints()
            buffFrame:SetPoint("BOTTOMRIGHT", (-margin * x), marginy * y)

            buffFrame:SetScript("OnEnter", BuffOnEnter)
            buffFrame:SetScript("OnLeave", GameTooltip_Hide)
            buffFrame:SetScript("OnUpdate", function(self, elapsed)
                if self.throt < 0 and self.expires ~= nil and self:IsShown() then
                    self.throt = 0.2
                    if GameTooltip:IsOwned(self) then
                        BuffOnEnter(self)
                    end
                else
                    self.throt = self.throt - elapsed
                end
            end)

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
            buffFrame:SetScript("OnUpdate", nil)
        end
    end
    updatePartyDebuffs(self, x, y)
end
GW.AddForProfiling("party", "updatePartyAuras", updatePartyAuras)

local function setUnitName(self)
    local role = UnitGroupRolesAssigned(self.unit)
    local nameString = UnitName(self.unit)

    if not nameString or nameString == UNKNOWNOBJECT then
        self.nameNotLoaded = false
    else
        self.nameNotLoaded = true
    end

    if nameRoleIcon[role] ~= nil then
        nameString = nameRoleIcon[role] .. nameString
    end

    if UnitIsGroupLeader(self.unit) then
        nameString = "|TInterface/AddOns/GW2_UI/textures/party/icon-groupleader:18:18:0:-3|t" .. nameString
    end

    self.name:SetText(nameString)
end
GW.AddForProfiling("party", "setUnitName", setUnitName)

local function setHealthValue(self, healthCur, healthMax, healthPrec)
    local healthstring = ""

    if GW.settings.PARTY_UNIT_HEALTH == "NONE" then
        self.healthString:Hide()
        return
    end

    if GW.settings.PARTY_UNIT_HEALTH == "PREC" then
        self.healthString:SetText(RoundDec(healthPrec * 100, 0) .. "%")
        self.healthString:SetJustifyH("LEFT")
    elseif GW.settings.PARTY_UNIT_HEALTH == "HEALTH" then
        self.healthString:SetText(CommaValue(healthCur))
        self.healthString:SetJustifyH("LEFT")
    elseif GW.settings.PARTY_UNIT_HEALTH == "LOSTHEALTH" then
        if healthMax - healthCur > 0 then healthstring = CommaValue(healthMax - healthCur) end
        self.healthString:SetText(healthstring)
        self.healthString:SetJustifyH("RIGHT")
    end
    if healthCur == 0 then
        self.healthString:SetTextColor(255, 0, 0)
    else
        self.healthString:SetTextColor(1, 1, 1)
    end
    self.healthString:Show()
end
GW.AddForProfiling("party", "setHealthValue", setHealthValue)
local function setAbsorbAmount(self)
local health = UnitHealth(self.unit)
  local healthMax = UnitHealthMax(self.unit)
  local absorb = UnitGetTotalAbsorbs(self.unit)
  local absorbPrecentage = 0
  local absorbAmount = 0
  local absorbAmount2 = 0
  local healthPrecentage = 0

    if health > 0 and healthMax > 0 then
        healthPrecentage = health / healthMax
    end


    if absorb > 0 and healthMax > 0 then
        absorbPrecentage = absorb / healthMax
        absorbAmount = healthPrecentage + absorbPrecentage
        absorbAmount2 = absorbPrecentage - (1 - healthPrecentage)
    end
    self.absorbbg:SetFillAmount(absorbAmount)
    self.absorbOverlay:SetFillAmount(absorbAmount2)
end
GW.AddForProfiling("party", "setAbsorbAmount", setHealthValue)
local function setUnitHealAbsorb(self)
    local healthMax = UnitHealthMax(self.unit)
    local healAbsorb =  UnitGetTotalHealAbsorbs(self.unit)
    local healAbsorbPrecentage = 0
  
    if healAbsorb > 0 and healthMax > 0 then
        healAbsorbPrecentage = min(healthMax,healAbsorb / healthMax)
    end
    self.antiHeal:SetFillAmount(healAbsorbPrecentage)
end
local function setHealPrediction(self, predictionPrecentage)
    
    self.healPrediction:SetFillAmount(predictionPrecentage)
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
    if (self.healPredictionAmount ~= nil or self.healPredictionAmount == 0) and healthMax~=0 then
        predictionPrecentage = math.min(healthPrec + (self.healPredictionAmount / healthMax), 1)
    end
    setHealPrediction(self, predictionPrecentage)
    setHealthValue(self, health, healthMax, healthPrec)
    self.health:SetFillAmount(healthPrec)
end
GW.AddForProfiling("party", "setHealth", setHealth)

local function setPredictionAmount(self)
    local prediction = UnitGetIncomingHeals(self.unit) or 0

    self.healPredictionAmount = prediction
    setHealth(self)
end
GW.AddForProfiling("party", "setPredictionAmount", setPredictionAmount)

local function updatePartyData(self)
    if not UnitExists(self.unit) then
        return
    end

    local health = UnitHealth(self.unit)
    local healthMax = UnitHealthMax(self.unit)
    local healthPrec = 0
    local prediction = UnitGetIncomingHeals(self.unit) or 0
    local predictionPrecentage = 0

    local power = UnitPower(self.unit, UnitPowerType(self.unit))
    local powerMax = UnitPowerMax(self.unit, UnitPowerType(self.unit))
    local powerPrecentage = 0

    local _, powerToken = UnitPowerType(self.unit)
    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.powerbar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end
    if healthMax > 0 then
        healthPrec = health / healthMax
    end
    if prediction > 0 and healthMax > 0 then
        predictionPrecentage = math.min(healthPrec + (prediction / healthMax), 1)
    end
    if powerMax > 0 then
        powerPrecentage = power / powerMax
    end
    Bar(self.healthbar, healthPrec)
    self.healPrediction:SetFillAmount(predictionPrecentage)

    self.powerbar:SetValue(powerPrecentage)
    setHealth(self)
    setUnitHealAbsorb(self)
    setAbsorbAmount(self)
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
    if event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        setHealth(self)
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        local power = UnitPower(self.unit, UnitPowerType(self.unit))
        local powerMax = UnitPowerMax(self.unit, UnitPowerType(self.unit))
        local powerPrecentage = 0
        if powerMax > 0 then
            powerPrecentage = power / powerMax
        end
        self.powerbar:SetValue(powerPrecentage)
    elseif IsIn(event, "UNIT_LEVEL", "GROUP_ROSTER_UPDATE", "UNIT_MODEL_CHANGED") then
        updatePartyData(self)
    elseif event == "UNIT_HEAL_PREDICTION" then
        setPredictionAmount(self)
    elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        setAbsorbAmount(self)
    elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
        setUnitHealAbsorb(self)
    elseif IsIn(event,"UNIT_PHASE", "PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE", "UNIT_THREAT_SITUATION_UPDATE", "INCOMING_RESURRECT_CHANGED", "INCOMING_SUMMON_CHANGED") then
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

local function UpdatePetVisibility()
    for i = 1, MAX_PARTY_MEMBERS + (GW.settings.PARTY_PLAYER_FRAME and 1 or 0) do
        local frame = _G["GwPartyPetFrame" .. i]
        if GW.settings.PARTY_SHOW_PETS then
            RegisterStateDriver(frame, "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format((i == 1 and GW.settings.PARTY_PLAYER_FRAME and "pet" or "partypet" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0)))))
        else
            RegisterStateDriver(frame, "visibility", "hide")
        end
    end
end
GW.UpdatePartyPetVisibility = UpdatePetVisibility

local function UpdatePlayerInPartySetting()
    local isFirstFrame = true
    for i = 1, MAX_PARTY_MEMBERS + 1 do
        local frame = _G["GwPartyFrame" .. i]

        frame:ClearAllPoints()
        if GW.settings.PARTY_PLAYER_FRAME and isFirstFrame then
            frame:SetPoint("TOPLEFT", 20, -104 + (-85 * i) + 85)
        else
            if isFirstFrame then
                frame:SetPoint("TOPLEFT", 20, -104 + (-85 * i) + 85)
            else
                frame:SetPoint("BOTTOMLEFT", _G["GwPartyPetFrame" .. (i - 1)], "BOTTOMLEFT", -15, -90)
            end
        end

        frame.unit = i == 1 and GW.settings.PARTY_PLAYER_FRAME and "player" or "party" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))
        frame.guid = UnitGUID(frame.unit)
        frame:SetAttribute("unit", frame.unit)
        party_OnEvent(frame, "load")
        updatePartyData(frame)

        if frame.unit == "player" then
            RegisterStateDriver(frame, "visibility", ("[@raid1,exists][@%s,noexists] hide;show"):format("party1"))
        else
            RegisterStateDriver(frame, "visibility", ("[@raid1,exists][@%s,noexists] hide;show"):format(frame.unit))
        end

        isFirstFrame = false
    end

    if not GW.settings.PARTY_PLAYER_FRAME then
        RegisterStateDriver(_G["GwPartyFrame" .. MAX_PARTY_MEMBERS + 1], "visibility", "hide")
        RegisterStateDriver(_G["GwPartyPetFrame" .. MAX_PARTY_MEMBERS + 1], "visibility", "hide")
    end
end
GW.UpdatePlayerInPartySetting = UpdatePlayerInPartySetting

local function CreatePartyPetFrame(frame, i)
    local unit = frame.unit == "player" and "pet" or "partypet" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))
    local f = CreateFrame("Button", "GwPartyPetFrame" .. i, UIParent, "GwPartyPetFrame")

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

    f.absorbOverlay:SetStatusBarColor(1,1,1,0.66)
    f.absorbbg:SetStatusBarColor(1,1,1,0.66)
    f.healPrediction:SetStatusBarColor(0.58431,0.9372,0.2980,0.60)

    f.healthString:SetFontObject(GameFontNormalSmall)

    f:SetAttribute("*type1", "target")
    f:SetAttribute("*type2", "togglemenu")
    f:SetAttribute("unit", unit)
    f:EnableMouse(true)
    f:RegisterForClicks("AnyDown")
    f.unit = unit
    f.isPet = true

    f:ClearAllPoints()
    f:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, -17)

    f:SetScript("OnLeave", GameTooltip_Hide)
    f:SetScript("OnEnter", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(unit)
        GameTooltip:Show()
    end)

    AddToClique(f)

    f.health:SetStatusBarColor(COLOR_FRIENDLY[1].r, COLOR_FRIENDLY[1].g, COLOR_FRIENDLY[1].b)


    f:SetScript("OnEvent", party_OnEvent)

    f:RegisterEvent("GROUP_ROSTER_UPDATE")
    f:RegisterEvent("PARTY_MEMBER_DISABLE")
    f:RegisterEvent("PARTY_MEMBER_ENABLE")
    f:RegisterEvent("PORTRAITS_UPDATED")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")

    f:RegisterUnitEvent("UNIT_PET", frame.unit)
    f:RegisterUnitEvent("UNIT_AURA", unit)
    f:RegisterUnitEvent("UNIT_LEVEL", unit)
    f:RegisterUnitEvent("UNIT_PHASE", unit)
    f:RegisterUnitEvent("UNIT_HEALTH", unit)
    f:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    f:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
    f:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    f:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
    f:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit)
    f:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED",unit)
    f:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED",unit)

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
        debuffFrame.throt = -1
        debuffFrame:SetSize(10, 10)

        f.debuffFrames[k] = debuffFrame

        local buffFrame = CreateFrame("Button", nil, f.auras, "GwBuffIconBig")
        buffFrame.buffDuration:SetFont(UNIT_NAME_FONT, 11)
        buffFrame.buffDuration:SetTextColor(1, 1, 1)
        buffFrame.buffStacks:SetFont(UNIT_NAME_FONT, 6, "OUTLINED")
        buffFrame.buffStacks:SetTextColor(1, 1, 1)
        buffFrame:SetParent(f.auras)
        buffFrame:SetSize(10, 10)
        buffFrame.throt = -1

        f.buffFrames[k] = buffFrame
    end

    party_OnEvent(f, "load")

    updatePartyData(f)
end

local function createPartyFrame(i, isFirstFrame, isPlayer)
    local registerUnit = isPlayer and "player" or "party" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))
    local frame = CreateFrame("Button", "GwPartyFrame" .. i, UIParent, "GwPartyFrame")

    local hg = frame.healthContainer
    frame.absorbOverlay = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay
    frame.antiHeal = hg.healPrediction.absorbbg.health.antiHeal
    frame.health = hg.healPrediction.absorbbg.health
    frame.absorbbg = hg.healPrediction.absorbbg
    frame.healPrediction = hg.healPrediction
    frame.healthString = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.healthString

    GW.hookStatusbarBehaviour(frame.absorbOverlay,true)
    GW.hookStatusbarBehaviour(frame.antiHeal,true)
    GW.hookStatusbarBehaviour(frame.health,true)
    GW.hookStatusbarBehaviour(frame.absorbbg,true)
    GW.hookStatusbarBehaviour(frame.healPrediction,false)

    frame.absorbOverlay:SetStatusBarColor(1,1,1,0.66)
    frame.absorbbg:SetStatusBarColor(1,1,1,0.66)
    frame.healPrediction:SetStatusBarColor(0.58431,0.9372,0.2980,0.60)

    frame.name:SetFont(UNIT_NAME_FONT, 12)
    frame.name:SetShadowOffset(-1, -1)
    frame.name:SetShadowColor(0, 0, 0, 1)
    frame.level:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINED")

    frame.healthString:SetFontObject(GameFontNormalSmall)

    frame.unit = registerUnit
    frame.guid = UnitGUID(frame.unit)
    frame.ready = -1
    frame.nameNotLoaded = false

    CreatePartyPetFrame(frame, i)

    frame:SetAttribute("unit", registerUnit)
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")

    if registerUnit == "player" then
        RegisterStateDriver(frame, "visibility", ("[@raid6,exists][@%s,noexists] hide;show"):format("party1"))
    else
        RegisterStateDriver(frame, "visibility", ("[@raid6,exists][@%s,noexists] hide;show"):format(registerUnit))
    end

    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyUp")

    frame:SetScript("OnLeave", GameTooltip_Hide)
    frame:SetScript("OnEnter", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(registerUnit)
        GameTooltip:Show()
    end)

    AddToClique(frame)

    frame.health:SetStatusBarColor(COLOR_FRIENDLY[1].r, COLOR_FRIENDLY[1].g, COLOR_FRIENDLY[1].b)

    frame:SetScript("OnEvent", party_OnEvent)

    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("PARTY_MEMBER_DISABLE")
    frame:RegisterEvent("PARTY_MEMBER_ENABLE")
    frame:RegisterEvent("READY_CHECK")
    frame:RegisterEvent("READY_CHECK_CONFIRM")
    frame:RegisterEvent("READY_CHECK_FINISHED")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("INCOMING_RESURRECT_CHANGED")
    frame:RegisterEvent("INCOMING_SUMMON_CHANGED")
    frame:RegisterEvent("PORTRAITS_UPDATED")

    frame:RegisterUnitEvent("UNIT_AURA", registerUnit)
    frame:RegisterUnitEvent("UNIT_LEVEL", registerUnit)
    frame:RegisterUnitEvent("UNIT_PHASE", registerUnit)
    frame:RegisterUnitEvent("UNIT_HEALTH", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", registerUnit)
    frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", registerUnit)
    frame:RegisterUnitEvent("UNIT_NAME_UPDATE", registerUnit)
    frame:RegisterUnitEvent("UNIT_MODEL_CHANGED", registerUnit)
    frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", registerUnit)
    frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", registerUnit)
    frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", registerUnit)
    frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", registerUnit)
    frame:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", registerUnit)

    frame:SetScript("OnEvent", party_OnEvent)

    -- create de/buff frames
    frame.buffFrames = {}
    frame.debuffFrames = {}
    frame.privateAuraFrames = {}
    for k = 1, 40 do
        local debuffFrame = CreateFrame("Frame", nil, frame.auras,  "GwDeBuffIcon")
        debuffFrame:SetParent(frame.auras)
        debuffFrame.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
        debuffFrame.cooldown:SetDrawEdge(0)
        debuffFrame.cooldown:SetDrawSwipe(1)
        debuffFrame.cooldown:SetReverse(1)
        debuffFrame.cooldown:SetHideCountdownNumbers(true)
        debuffFrame:SetSize(24, 24)
        debuffFrame.throt = -1

        frame.debuffFrames[k] = debuffFrame

        local buffFrame = CreateFrame("Button", nil, frame.auras, "GwBuffIconBig")
        buffFrame.buffDuration:SetFont(UNIT_NAME_FONT, 11)
        buffFrame.buffDuration:SetTextColor(1, 1, 1)
        buffFrame.buffStacks:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
        buffFrame.buffStacks:SetTextColor(1, 1, 1)
        buffFrame:SetParent(frame.auras)
        buffFrame:SetSize(20, 20)
        buffFrame.throt = -1

        frame.buffFrames[k] = buffFrame

        if k <=2 then
            local privateAura = CreateFrame("Frame", nil, frame.auras, "GwPrivateAuraTmpl")
            privateAura:SetPoint("BOTTOMRIGHT", frame.auras, (28 * (k - 1)), 28 * 2)
            privateAura.auraIndex = k
            privateAura:SetSize(24, 24)
            local auraAnchor = {
                unitToken = registerUnit,
                auraIndex = privateAura.auraIndex,
                -- The parent frame of an aura anchor must have a valid rect with a non-zero
                -- size. Each private aura will anchor to all points on its parent,
                -- providing a tooltip when mouseovered.
                parent = privateAura,
                -- An optional cooldown spiral can be configured to represent duration.
                showCountdownFrame = true,
                showCountdownNumbers = true,
                -- An optional icon can be created and shown for the aura. Omitting this
                -- will display no icon.
                iconInfo = {
                    iconWidth = 24,
                    iconHeight = 24,
                    iconAnchor = {
                        point = "CENTER",
                        relativeTo = privateAura.status,
                        relativePoint = "CENTER",
                        offsetX = 0,
                        offsetY = 0,
                    },
                },
            }
            -- Anchors can be removed (and the aura hidden) via the RemovePrivateAuraAnchor
            -- API, passing it the anchor index returned from the Add function.
            privateAura.anchorIndex = C_UnitAuras.AddPrivateAuraAnchor(auraAnchor)

            frame.privateAuraFrames[k] = privateAura
        end
    end

    party_OnEvent(frame, "load")

    updatePartyData(frame)
end
GW.AddForProfiling("party", "createPartyFrame", createPartyFrame)


local function LoadPartyFrames()
    GW.CreateRaidControlFrame()

    if GW.settings.RAID_FRAMES and GW.settings.RAID_STYLE_PARTY then
        return
    end
    local index = 1
    local isFirstFrame = true
    for _ = 1, MAX_PARTY_MEMBERS + 1 do
        if GW.settings.PARTY_PLAYER_FRAME and isFirstFrame then
            createPartyFrame(index, isFirstFrame, true)
        else
            createPartyFrame(index, isFirstFrame, false)
        end
        isFirstFrame = false
        index = index + 1
    end

    UpdatePlayerInPartySetting()
    UpdatePetVisibility()

    -- Set up preview mode
    GwSettingsPartyPanel.buttonPartyPreview.previewMode = false
    GwSettingsPartyPanel.buttonPartyPreview:SetScript("OnClick", function(self)
        local unitFrame, unitPetFrame
        if self.previewMode then
            self:SetText("-")
            for i = 1, MAX_PARTY_MEMBERS + 1 do
                unitFrame = _G["GwPartyFrame" .. i]
                unitPetFrame = _G["GwPartyPetFrame" .. i]

                unitFrame.unit = i == 1 and GW.settings.PARTY_PLAYER_FRAME and "player" or "party" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))
                unitFrame.guid = UnitGUID(i == 1 and GW.settings.PARTY_PLAYER_FRAME and "player" or "party" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0)))
                unitFrame:SetAttribute("unit", (i == 1 and GW.settings.PARTY_PLAYER_FRAME and "player" or "party" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))))
                UnregisterStateDriver(unitFrame, "visibility")
                if i == 1 and GW.settings.PARTY_PLAYER_FRAME then
                    RegisterStateDriver(unitFrame, "visibility", ("[@raid6,exists][@%s,noexists] hide;show"):format("party1"))
                else
                    RegisterStateDriver(unitFrame, "visibility", ("[@raid6,exists][@%s,noexists] hide;show"):format("party" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))))
                end
                party_OnEvent(unitFrame, "load")
                updatePartyData(unitFrame)

                unitPetFrame.unit = i == 1 and GW.settings.PARTY_PLAYER_FRAME and "pet" or "partypet" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))
                unitPetFrame.guid = UnitGUID(i == 1 and GW.settings.PARTY_PLAYER_FRAME and "pet" or "partypet" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0)))
                unitPetFrame:SetAttribute("unit", (i == 1 and GW.settings.PARTY_PLAYER_FRAME and "pet" or "partypet" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))))
                UnregisterStateDriver(unitPetFrame, "visibility")
                if GW.settings.PARTY_SHOW_PETS then
                    RegisterStateDriver(unitPetFrame, "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format((i == 1 and GW.settings.PARTY_PLAYER_FRAME and "pet" or "partypet" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0)))))
                else
                    RegisterStateDriver(unitPetFrame, "visibility", "hide")
                end
                party_OnEvent(unitPetFrame, "load")
                updatePartyData(unitPetFrame)
            end
            if not GW.settings.PARTY_PLAYER_FRAME then
                RegisterStateDriver(_G["GwPartyFrame" .. MAX_PARTY_MEMBERS + 1], "visibility", "hide")
                RegisterStateDriver(_G["GwPartyPetFrame" .. MAX_PARTY_MEMBERS + 1], "visibility", "hide")
            end
            self.previewMode = false
        else
            self:SetText("5")
            for i = 1, MAX_PARTY_MEMBERS + 1 do
                unitFrame = _G["GwPartyFrame" .. i]
                unitPetFrame = _G["GwPartyPetFrame" .. i]
                if unitFrame then
                    unitFrame.unit = "player"
                    unitFrame.guid = UnitGUID("player")
                    unitFrame:SetAttribute("unit", "player")
                    UnregisterStateDriver(unitFrame, "visibility")
                    RegisterStateDriver(unitFrame, "visibility", "show")
                    party_OnEvent(unitFrame, "load")
                    updatePartyData(unitFrame)

                    if GW.settings.PARTY_SHOW_PETS then
                        unitPetFrame.unit = "player"
                        unitPetFrame.guid = UnitGUID("player")
                        unitPetFrame:SetAttribute("unit", "player")
                        UnregisterStateDriver(unitPetFrame, "visibility")
                        RegisterStateDriver(unitPetFrame, "visibility", "show")
                        party_OnEvent(unitPetFrame, "load")
                        updatePartyData(unitPetFrame)
                    end
                end

                if not GW.settings.PARTY_PLAYER_FRAME then
                    RegisterStateDriver(_G["GwPartyFrame" .. MAX_PARTY_MEMBERS + 1], "visibility", "hide")
                    RegisterStateDriver(_G["GwPartyPetFrame" .. MAX_PARTY_MEMBERS + 1], "visibility", "hide")
                end
            end
            self.previewMode = true
        end
    end)
end
GW.LoadPartyFrames = LoadPartyFrames
