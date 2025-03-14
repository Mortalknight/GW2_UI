local _, GW = ...
local PowerBarColorCustom = GW.PowerBarColorCustom
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local SetClassIcon = GW.SetClassIcon
local AddToClique = GW.AddToClique
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

local function FilterAura(element, unit, data, isBuff)
    if isBuff then
        if data.name then
            return true
        end
    else
        if data and data.name then
            local shouldDisplay = false

            if GW.settings.PARTY_SHOW_DEBUFFS then
                if GW.settings.PARTY_ONLY_DISPELL_DEBUFFS then
                    if data.dispelName and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) then
                        shouldDisplay = data.name and not (data.spellId == 6788 and data.sourceUnit and not UnitIsUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
                    end
                else
                    shouldDisplay = data.name and not (data.spellId == 6788 and data.sourceUnit and not UnitIsUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
                end
            end

            if GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF and not shouldDisplay then
                shouldDisplay = GW.ImportendRaidDebuff[data.spellId] or false
            end

            return shouldDisplay
        end
    end
end

local function AuraSetPoint(element, from, to)
    local x = 0
    local y = 0

    for i = from, to do
        local button = element[i]
        if(not button) then break end

        if x > 10 then
            y = y + 1
            x = 0
        end

        button:ClearAllPoints()
        button:SetPoint("BOTTOMRIGHT", ((button.neededSize - 1) * x), (button.neededSize + 2) * y)

        x = x + 1
    end
end

local function setUnitName(self)
    local role = UnitGroupRolesAssigned(self.unit)
    local nameString = UnitName(self.unit) or UNKNOWNOBJECT

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
    local formatFunction

    if GW.settings.PARTY_UNIT_HEALTH_SHORT_VALUES then
        formatFunction = GW.ShortValue
    else
        formatFunction = GW.GetLocalizedNumber
    end

    if GW.settings.PARTY_UNIT_HEALTH == "NONE" then
        self.healthString:Hide()
        return
    end

    if GW.settings.PARTY_UNIT_HEALTH == "PREC" then
        self.healthString:SetText(RoundDec(healthPrec * 100, 0) .. "%")
        self.healthString:SetJustifyH("LEFT")
    elseif GW.settings.PARTY_UNIT_HEALTH == "HEALTH" then
        self.healthString:SetText(formatFunction(healthCur))
        self.healthString:SetJustifyH("LEFT")
    elseif GW.settings.PARTY_UNIT_HEALTH == "LOSTHEALTH" then
        if healthMax - healthCur > 0 then healthstring = formatFunction(healthMax - healthCur) end
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
GW.AddForProfiling("party", "setAbsorbAmount", setAbsorbAmount)
local function setUnitHealAbsorb(self)
    local healthMax = UnitHealthMax(self.unit)
    local healAbsorb = UnitGetTotalHealAbsorbs(self.unit)
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
    self.healPrediction:SetFillAmount(predictionPrecentage)
    self.powerbar:SetFillAmount(powerPrecentage)
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

end
GW.AddForProfiling("party", "updatePartyData", updatePartyData)

local function party_OnEvent(self, event, unit, ...)
    if (not UnitExists(self.unit) or IsInRaid()) and not event == "load" then
        return
    end

    if event == "load" then
        updatePartyData(self)
        self.auras:ForceUpdate()
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
        self.powerbar:SetFillAmount(powerPrecentage)
    elseif IsIn(event, "UNIT_LEVEL", "GROUP_ROSTER_UPDATE", "UNIT_MODEL_CHANGED") then
        updatePartyData(self)
        self.auras:ForceUpdate()
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
        GW.UpdateBuffLayout(self, event, unit, ...)
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

local function UpdatePartyFrames()
    for i = 1, MAX_PARTY_MEMBERS + (GW.settings.PARTY_PLAYER_FRAME and 1 or 0) do
        local frame = _G["GwPartyFrame" .. i]
        frame.displayBuffs = GW.settings.PARTY_SHOW_BUFFS and 32 or 0
        frame.displayDebuffs = (GW.settings.PARTY_SHOW_DEBUFFS or GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF) and 40 or 0
        frame.auras.smallSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE
        frame.auras.bigSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE
        party_OnEvent(frame, "load")
        frame = _G["GwPartyPetFrame" .. i]
        frame.auras.smallSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE - 6
        frame.auras.bigSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE - 6
        frame.displayDebuffs = (GW.settings.PARTY_SHOW_DEBUFFS or GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF) and 40 or 0
        frame.displayBuffs = GW.settings.PARTY_SHOW_BUFFS and 32 or 0
        if frame then party_OnEvent(frame, "load") end
    end
end
GW.UpdatePartyFrames = UpdatePartyFrames

local function UpdatePetVisibility(alwaysHide)
    for i = 1, MAX_PARTY_MEMBERS + (GW.settings.PARTY_PLAYER_FRAME and 1 or 0) do
        local frame = _G["GwPartyPetFrame" .. i]
        if not GW.settings.PARTY_SHOW_PETS or alwaysHide then
            RegisterStateDriver(frame, "visibility", "hide")
        else
            RegisterStateDriver(frame, "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format((i == 1 and GW.settings.PARTY_PLAYER_FRAME and "pet" or "partypet" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0)))))
        end
    end
end
GW.UpdatePartyPetVisibility = UpdatePetVisibility

local function UpdatePlayerInPartySetting(alwaysHide)
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
        frame.auras:ForceUpdate()

        if alwaysHide then
            RegisterStateDriver(frame, "visibility", "hide")
        else
            if frame.unit == "player" then
                RegisterStateDriver(frame, "visibility", ("[@raid1,exists][@%s,noexists] hide;show"):format("party1"))
            else
                RegisterStateDriver(frame, "visibility", ("[@raid1,exists][@%s,noexists] hide;show"):format(frame.unit))
            end
        end

        if not GW.settings.PARTY_PLAYER_FRAME and i == 5 then
            frame:SetScript("OnEvent", nil)
            _G["GwPartyPetFrame5"]:SetScript("OnEvent", nil)
        elseif GW.settings.PARTY_PLAYER_FRAME and i == 5 then
            frame:SetScript("OnEvent", party_OnEvent)
            _G["GwPartyPetFrame5"]:SetScript("OnEvent", party_OnEvent)
        end

        isFirstFrame = false
    end

    if not GW.settings.PARTY_PLAYER_FRAME then
        RegisterStateDriver(_G["GwPartyFrame" .. MAX_PARTY_MEMBERS + 1], "visibility", "hide")
        RegisterStateDriver(_G["GwPartyPetFrame" .. MAX_PARTY_MEMBERS + 1], "visibility", "hide")
    end

    UpdatePetVisibility(alwaysHide)
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
    GW.hookStatusbarBehaviour(f.powerbar, true)

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

    f.auras.FilterAura = FilterAura
    f.auras.SetPosition = AuraSetPoint
    f.auras.smallSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE - 6
    f.auras.bigSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE - 6
    f.displayBuffs = GW.settings.PARTY_SHOW_BUFFS and 32 or 0
    f.displayDebuffs = (GW.settings.PARTY_SHOW_DEBUFFS or GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF) and 40 or 0
    f.auras.hideDuration = true
    GW.LoadAuras(f)

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

    party_OnEvent(f, "load")
end

local function createPartyFrame(i, isPlayer)
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
    GW.hookStatusbarBehaviour(frame.powerbar, true)

    frame.absorbOverlay:SetStatusBarColor(1,1,1,0.66)
    frame.absorbbg:SetStatusBarColor(1,1,1,0.66)
    frame.healPrediction:SetStatusBarColor(0.58431,0.9372,0.2980,0.60)

    frame.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    frame.name:SetShadowOffset(-1, -1)
    frame.name:SetShadowColor(0, 0, 0, 1)
    frame.level:SetFont(UNIT_NAME_FONT, 12, "OUTLINE")

    frame.healthString:SetFontObject(GameFontNormalSmall)

    frame.unit = registerUnit
    frame.guid = UnitGUID(frame.unit)
    frame.ready = -1
    frame.nameNotLoaded = false

    frame.auras.smallSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE
    frame.auras.bigSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE
    frame.auras.hideDuration = true
    frame.auras.FilterAura = FilterAura
    frame.auras.SetPosition = AuraSetPoint
    frame.displayBuffs = GW.settings.PARTY_SHOW_BUFFS and 32 or 0
    frame.displayDebuffs = (GW.settings.PARTY_SHOW_DEBUFFS or GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF) and 40 or 0
    GW.LoadAuras(frame)

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

    frame.privateAuraFrames = {}
    for k = 1, 40 do
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
end
GW.AddForProfiling("party", "createPartyFrame", createPartyFrame)

local function LoadPartyFrames()
    GW.CreateRaidControlFrame()

    local index = 1
    local isFirstFrame = true
    for _ = 1, MAX_PARTY_MEMBERS + 1 do
        if GW.settings.PARTY_PLAYER_FRAME and isFirstFrame then
            createPartyFrame(index, true)
        else
            createPartyFrame(index, false)
        end
        isFirstFrame = false
        index = index + 1
    end

    UpdatePlayerInPartySetting(GW.settings.RAID_FRAMES and GW.settings.RAID_STYLE_PARTY)

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
