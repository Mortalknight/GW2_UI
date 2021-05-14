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
local LHC = GW.Libs.LHC

local GW_PORTRAIT_BACKGROUND = {
    [1] = {l = 0, r = 0.828, t = 0, b = 0.166015625},
    [2] = {l = 0, r = 0.828, t = 0.166015625, b = 0.166015625 * 2},
    [3] = {l = 0, r = 0.828, t = 0.166015625 * 2, b = 0.166015625 * 3},
    [4] = {l = 0, r = 0.828, t = 0.166015625 * 3, b = 0.166015625 * 4},
    [5] = {l = 0, r = 0.828, t = 0.166015625 * 4, b = 0.166015625 * 5}
}

local function inviteToGroup(str)
    InviteUnit(str)
end
GW.AddForProfiling("party", "inviteToGroup", inviteToGroup)

local function manageButton()
    local fmGMGB = CreateFrame("Frame", "GwManageGroupButton", UIParent, "GwManageGroupButtonTmpl")
    local fnGMGB_OnClick = function(self, button)
        if GwGroupManage:IsShown() then
            GwGroupManage:Hide()
        else
            GwGroupManage:Show()
        end
    end
    local fnGMGB_OnEnter = function(self)
        self.arrow:SetSize(21, 42)
    end
    local fnGMGB_OnLeave = function(self)
        self.arrow:SetSize(16, 32)
    end
    fmGMGB.cf.button:SetScript("OnClick", fnGMGB_OnClick)
    fmGMGB.cf.button:SetScript("OnEnter", fnGMGB_OnEnter)
    fmGMGB.cf.button:SetScript("OnLeave", fnGMGB_OnLeave)

    CreateFrame("Frame", "GwGroupManage", UIParent, "GwGroupManage")
    local fmGMGIB = GwManageGroupInviteBox
    local fmGBITP = GwButtonInviteToParty
    local fmGMGLB = GwManageGroupLeaveButton
    local fmGGRC = GwGroupReadyCheck
    local fmGGMC = GwGroupManagerConvert
    local fmGMIG = GwGroupManagerInGroup

    local fnGMGIB_OnEscapePressed = function(self)
        self:ClearFocus()
    end
    local fnGMGIB_OnEditFocusGained = function(self)
        local sT = self:GetText()
        if sT == CALENDAR_PLAYER_NAME then
            self:SetText("")
            self:SetTextColor(1, 1, 1, 1)
        end
    end
    local fnGMGIB_OnEditFocusLost = function(self)
        local sT = self:GetText()
        if sT == nil or sT == "" then
            self:SetText(CALENDAR_PLAYER_NAME)
            self:SetTextColor(1, 1, 1, 0.5)
        end
    end
    local fnGMGIB_OnEnterPressed = function(self)
        inviteToGroup(GwManageGroupInviteBox:GetText())
        self:SetText("")
        self:ClearFocus()
    end
    fmGMGIB:SetScript("OnEscapePressed", fnGMGIB_OnEscapePressed)
    fmGMGIB:SetScript("OnEditFocusGained", fnGMGIB_OnEditFocusGained)
    fmGMGIB:SetScript("OnEditFocusLost", fnGMGIB_OnEditFocusLost)
    fmGMGIB:SetScript("OnEnterPressed", fnGMGIB_OnEnterPressed)
    local sT = fmGMGIB:GetText()
    if sT == nil or sT == "" then
        fmGMGIB:SetText(CALENDAR_PLAYER_NAME)
        fmGMGIB:SetTextColor(1, 1, 1, 0.5)
    end

    local fnGBITP_OnClick = function(self, button)
        inviteToGroup(GwManageGroupInviteBox:GetText())
        GwManageGroupInviteBox:SetText("")
        GwManageGroupInviteBox:ClearFocus()
    end
    fmGBITP:SetScript("OnClick", fnGBITP_OnClick)

    local fnGMGLB_OnClick = function(self, button)
        LeaveParty()
    end
    fmGMGLB:SetScript("OnClick", fnGMGLB_OnClick)

    local fnGGRC_OnEvent = function(self, event, ...)
        if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
            self:Enable()
        else
            self:Disable()
        end
    end
    local fnGGRC_OnClick = function(self, button)
        DoReadyCheck()
    end
    fmGGRC:SetScript("OnEvent", fnGGRC_OnEvent)
    fmGGRC:SetScript("OnClick", fnGGRC_OnClick)
    fmGGRC.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\readycheck-button-hover")
    fmGGRC:GetFontString():SetTextColor(218 / 255, 214 / 255, 200 / 255)
    fmGGRC:GetFontString():SetShadowColor(0, 0, 0, 1)
    fmGGRC:GetFontString():SetShadowOffset(1, -1)
    fmGGRC:RegisterEvent("GROUP_ROSTER_UPDATE")
    fmGGRC:RegisterEvent("RAID_ROSTER_UPDATE")

    local fnGGMC_OnEvent = function(self, event, ...)
        if UnitIsGroupLeader("player") then
            self:Enable()
        else
            self:Disable()
        end

        if IsInRaid() then
            self:SetText(CONVERT_TO_PARTY)
        else
            self:SetText(CONVERT_TO_RAID)
        end
    end
    local fnGGMC_OnClick = function(self, button)
        if IsInRaid() then
            ConvertToParty()
        else
            ConvertToRaid()
        end
    end
    fmGGMC:SetScript("OnEvent", fnGGMC_OnEvent)
    fmGGMC:SetScript("OnClick", fnGGMC_OnClick)
    fmGGMC:RegisterEvent("GROUP_ROSTER_UPDATE")
    fmGGMC:RegisterEvent("RAID_ROSTER_UPDATE")
    fmGGMC:RegisterEvent("PLAYER_ENTERING_WORLD")

    local fnGMIG_OnLoad = function(self)
        if IsInGroup() then
            self:Show()
            GwGroupManage:SetHeight(280)
        else
            self:Hide()
            GwGroupManage:SetHeight(80)
        end

        if IsInRaid() then
            GwManageGroupButton.cf.button.icon:SetTexCoord(0, 0.59375, 0.2968, 0.2968 * 2)
        else
            GwManageGroupButton.cf.button.icon:SetTexCoord(0, 0.59375, 0, 0.2968)
        end
        _G[self:GetName() .. "Target"]:SetFont(UNIT_NAME_FONT, 14)
        _G[self:GetName() .. "Target"]:SetTextColor(255 / 255, 241 / 255, 209 / 255)
        _G[self:GetName() .. "Target"]:SetText(RAID_TARGET_ICON)

        self:RegisterEvent("GROUP_ROSTER_UPDATE")
        self:RegisterEvent("RAID_ROSTER_UPDATE")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    end
    local fnGMIG_OnEvent = function(self, event, ...)
        if IsInGroup() then
            self:Show()
            GwGroupManage:SetHeight(280)
        else
            self:Hide()
            GwGroupManage:SetHeight(80)
        end

        if IsInRaid() then
            GwManageGroupButton.cf.button.icon:SetTexCoord(0, 0.59375, 0.2968, 0.2968 * 2)
        else
            GwManageGroupButton.cf.button.icon:SetTexCoord(0, 0.59375, 0, 0.2968)
        end
    end
    fmGMIG:SetScript("OnEvent", fnGMIG_OnEvent)
    fnGMIG_OnLoad(fmGMIG)

    GwButtonInviteToParty:SetText(PARTY_INVITE)
    GwManageGroupLeaveButton:SetText(EXIT)
    GwGroupReadyCheck:SetText(QUEUED_STATUS_READY_CHECK_IN_PROGRESS)

    tinsert(UISpecialFrames, "GwGroupManage")
    local x = 10
    local y = -30

    local fnF_OnEnter = function(self)
        self.texture:SetBlendMode("ADD")
    end
    local fnF_OnLeave = function(self)
        self.texture:SetBlendMode("BLEND")
    end

    for i = 1, 8 do
        local f = CreateFrame("Button", "GwRaidMarkerButton" .. i, GwGroupManagerInGroup, "GwRaidMarkerButton")
        f:SetScript("OnEnter", fnF_OnEnter)
        f:SetScript("OnLeave", fnF_OnLeave)

        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", GwGroupManagerInGroup, "TOPLEFT", x, y)
        f:SetNormalTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i)
        f:SetScript(
            "OnClick",
            function()
                PlaySound(1115) --U_CHAT_SCROLL_BUTTON
                SetRaidTarget("target", i)
            end
        )

        x = x + 61
        if i == 4 then
            y = y + -55
            x = 10
        end
    end

    if GetSetting("FADE_GROUP_MANAGE_FRAME") then
        fmGMGB.cf:SetAttribute("fadeTime", 0.15)
        local fo = fmGMGB.cf:CreateAnimationGroup("fadeOut")
        local fi = fmGMGB.cf:CreateAnimationGroup("fadeIn")
        local fadeOut = fo:CreateAnimation("Alpha")
        local fadeIn = fi:CreateAnimation("Alpha")
        fo:SetScript("OnFinished", function(self)
            self:GetParent():SetAlpha(0)
        end)
        fadeOut:SetStartDelay(0.25)
        fadeOut:SetFromAlpha(1.0)
        fadeOut:SetToAlpha(0.0)
        fadeOut:SetDuration(fmGMGB.cf:GetAttribute("fadeTime"))
        fadeIn:SetFromAlpha(0.0)
        fadeIn:SetToAlpha(1.0)
        fadeIn:SetDuration(fmGMGB.cf:GetAttribute("fadeTime"))
        fmGMGB.cf.fadeOut = function(self)
            fi:Stop()
            fo:Stop()
            fo:Play()
        end
        fmGMGB.cf.fadeIn = function(self)
            self:SetAlpha(1)
            fi:Stop()
            fo:Stop()
            fi:Play()
        end

        fmGMGB:SetFrameRef("cf", fmGMGB.cf)

        fmGMGB:SetAttribute("_onenter", [=[
            local cf = self:GetFrameRef("cf")
            if cf:IsShown() then
                return
            end
            cf:UnregisterAutoHide()
            cf:Show()
            cf:CallMethod("fadeIn", cf)
            cf:RegisterAutoHide(cf:GetAttribute("fadeTime") + 0.25)
        ]=])
        fmGMGB.cf:HookScript("OnLeave", function(self)
            if not self:IsMouseOver() and not GwGroupManage:IsShown() then
                self:fadeOut()
            end
        end)
        fmGMGB.cf:Hide()
    end 
end
GW.manageButton = manageButton
GW.AddForProfiling("party", "manageButton", manageButton)

local function setPortraitBackground(self, idx)
    self.portraitBackground:SetTexCoord(GW_PORTRAIT_BACKGROUND[idx].l, GW_PORTRAIT_BACKGROUND[idx].r, GW_PORTRAIT_BACKGROUND[idx].t, GW_PORTRAIT_BACKGROUND[idx].b)
end
GW.AddForProfiling("party", "setPortraitBackground", setPortraitBackground)

local function updateAwayData(self)
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

            if show_debuffs then
                if only_dispellable_debuffs then
                    if debuffType and GW.IsDispellableByMe(debuffType) then
                        shouldDisplay = debuffName and not (spellId == 6788 and caster and not UnitIsUnit(caster, "player")) -- Don't show "Weakened Soul" from other players
                    end
                else
                    shouldDisplay = debuffName and not (spellId == 6788 and caster and not UnitIsUnit(caster, "player")) -- Don't show "Weakened Soul" from other players
                end
            end

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
    if x ~= 0 then
        y = y + 1
    end
    x = 0
    local unit = self.unit
    local debuffList = getUnitDebuffs(unit)

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
            debuffFrame:ClearAllPoints()
            debuffFrame:SetPoint("BOTTOMRIGHT", (26 * x), 26 * y)

            debuffFrame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
                GameTooltip:ClearLines()
                GameTooltip:SetUnitDebuff(unit, debuffList[i].key)
                GameTooltip:Show()
            end)
            debuffFrame:SetScript("OnLeave", GameTooltip_Hide)

            debuffFrame:Show()

            x = x + 1
            if x > 8 then
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

    local buffList = getUnitBuffs(unit)

    for i, buffFrame in pairs(self.buffFrames) do
        if buffList[i] then
            local margin = -buffFrame:GetWidth() + -2
            local marginy = buffFrame:GetWidth() + 5
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
            if x > 8 then
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
    local prediction = (LHC:GetHealAmount(self.guid, LHC.ALL_HEALS) or 0) * (LHC:GetHealModifier(self.guid) or 1)

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

    self.level:SetText(UnitLevel(self.unit))

    SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))

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
    if event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" and unit == self.unit then
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
    elseif event == "UNIT_NAME_UPDATE" then
        setUnitName(self)
    elseif event == "UNIT_AURA" then
        updatePartyAuras(self, self.unit)
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

local function createPartyFrame(i)
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

    frame:SetScript("OnEvent", party_OnEvent)

    frame:SetPoint("TOPLEFT", 20, -104 + (-85 * (i + multiplier)) + 85)

    frame.unit = registerUnit
    frame.guid = UnitGUID(frame.unit)
    frame.ready = -1
    frame.nameNotLoaded = false

    frame:SetAttribute("unit", registerUnit)
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")

    if i > 0 then
        RegisterUnitWatch(frame)
    else
        RegisterStateDriver(frame, "visibility", "[group:raid] hide; [group:party] show; hide")
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

    frame.healthbar.spark:SetVertexColor(COLOR_FRIENDLY[1].r, COLOR_FRIENDLY[1].g, COLOR_FRIENDLY[1].b)

    frame.healthbar.animationName = registerUnit .. "animation"
    frame.healthbar.animationValue = 0

    -- Handle callbacks from HealComm
    local HealCommEventHandler = function ()
        local self = frame
        return setPredictionAmount(self)
    end

    frame:SetScript("OnEvent", party_OnEvent)

    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("PARTY_MEMBER_DISABLE")
    frame:RegisterEvent("PARTY_MEMBER_ENABLE")
    frame:RegisterEvent("READY_CHECK")
    frame:RegisterEvent("READY_CHECK_CONFIRM")
    frame:RegisterEvent("READY_CHECK_FINISHED")

    frame:RegisterUnitEvent("UNIT_MODEL_CHANGED", registerUnit)
    frame:RegisterUnitEvent("UNIT_AURA", registerUnit)
    frame:RegisterUnitEvent("UNIT_LEVEL", registerUnit)
    frame:RegisterUnitEvent("UNIT_PHASE", registerUnit)
    frame:RegisterUnitEvent("UNIT_HEALTH", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", registerUnit)
    frame:RegisterUnitEvent("UNIT_POWER_UPDATE", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", registerUnit)
    frame:RegisterUnitEvent("UNIT_NAME_UPDATE", registerUnit)
    frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", registerUnit)

    LHC.RegisterCallback(frame, "HealComm_HealStarted", HealCommEventHandler)
    LHC.RegisterCallback(frame, "HealComm_HealUpdated", HealCommEventHandler)
    LHC.RegisterCallback(frame, "HealComm_HealStopped", HealCommEventHandler)
    LHC.RegisterCallback(frame, "HealComm_HealDelayed", HealCommEventHandler)
    LHC.RegisterCallback(frame, "HealComm_ModifierChanged", HealCommEventHandler)
    LHC.RegisterCallback(frame, "HealComm_GUIDDisappeared", HealCommEventHandler)

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
    if not _G.GwManageGroupButton then
        manageButton()
    end

    hideBlizzardPartyFrame()

    if GetSetting("RAID_FRAMES") and GetSetting("RAID_STYLE_PARTY") then
        return
    end

    if GetSetting("PARTY_PLAYER_FRAME") then
        createPartyFrame(0)
    end

    for i = 1, MAX_PARTY_MEMBERS do
        createPartyFrame(i)
    end
end
GW.LoadPartyFrames = LoadPartyFrames
