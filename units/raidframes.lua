local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local PowerBarColorCustom = GW.PowerBarColorCustom
local DEBUFF_COLOR = GW.DEBUFF_COLOR
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local GWGetClassColor = GW.GWGetClassColor
local INDICATORS = GW.INDICATORS
local AURAS_INDICATORS = GW.AURAS_INDICATORS
local RegisterMovableFrame = GW.RegisterMovableFrame
local Bar = GW.Bar
local SetClassIcon = GW.SetClassIcon
local SetDeadIcon = GW.SetDeadIcon
local AddToClique = GW.AddToClique
local FillTable = GW.FillTable
local IsIn = GW.IsIn
local TimeCount = GW.TimeCount
local CommaValue = GW.CommaValue
local RoundDec = GW.RoundDec
local REALM_FLAGS = GW.REALM_FLAGS
local nameRoleIcon = GW.nameRoleIcon
local LRI = GW.Libs.LRI

GW.GROUPD_TYPE = "RAID"
local previewSteps = {40, 20, 10, 5}
local previewStep = 0
local hudMoving = false
local missing, ignored = {}, {}
local spellIDs = {}
local spellBookSearched = 0
local players
local onLoad

local function hideBlizzardRaidFrame()
    if InCombatLockdown() then
        return
    end

    if CompactRaidFrameManager then
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:Hide()
    end
    if CompactRaidFrameContainer then
        CompactRaidFrameContainer:UnregisterAllEvents()
    end
    if CompactRaidFrameManager_GetSetting then
        local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
        if compact_raid and compact_raid ~= "0" then
            CompactRaidFrameManager_SetSetting("IsShown", "0")
        end
    end
end
GW.AddForProfiling("raidframes", "hideBlizzardRaidFrame", hideBlizzardRaidFrame)

local function updateRaidMarkers(self)
    local i = GetRaidTargetIndex(self.unit)

    if i then
        self.targetmarker = i
        self.classicon:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_" .. i)
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
        self.classicon:SetShown(true)
    else
        self.targetmarker = nil
        if not GetSetting("RAID_CLASS_COLOR" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or "")) then
            self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
            SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))
        else
            self.classicon:SetTexture(nil)
        end
    end
end
GW.AddForProfiling("raidframes", "updateRaidMarkers", updateRaidMarkers)

local function togglePartyFrames(b)
    if InCombatLockdown() then
        return
    end

    if IsInRaid() then
        b = false
    end

    if b then
        if GetSetting("RAID_STYLE_PARTY") or GetSetting("RAID_STYLE_PARTY_AND_FRAMES") then
            _G["GwCompactplayer"]:Show()
            RegisterUnitWatch(_G["GwCompactplayer"])

            for i = 1, 4 do
                _G["GwCompactparty" .. i]:Show()
                RegisterUnitWatch(_G["GwCompactparty" .. i])
            end
        end
        GW.TogglePartyRaid(true)
    else
        GW.TogglePartyRaid(false)
        UnregisterUnitWatch(_G["GwCompactplayer"])
        _G["GwCompactplayer"]:Hide()
        for i = 1, 4 do
            UnregisterUnitWatch(_G["GwCompactparty" .. i])
            _G["GwCompactparty" .. i]:Hide()
        end
    end
end
GW.AddForProfiling("raidframes", "togglePartyFrames", togglePartyFrames)

local function unhookPlayerFrame()
    if InCombatLockdown() then
        return
    end
    if IsInRaid() then
        return
    end

    if IsInGroup() and (GetSetting("RAID_STYLE_PARTY") or GetSetting("RAID_STYLE_PARTY_AND_FRAMES")) then
        _G["GwCompactplayer"]:Show()
        RegisterUnitWatch(_G["GwCompactplayer"])
    else
        UnregisterUnitWatch(_G["GwCompactplayer"])
        _G["GwCompactplayer"]:Hide()
    end
end
GW.AddForProfiling("raidframes", "unhookPlayerFrame", unhookPlayerFrame)

local function setAbsorbAmount(self)
    local healthMax = UnitHealthMax(self.unit)
    local absorb = UnitGetTotalAbsorbs(self.unit)
    local absorbPrecentage = 0

    if (absorb ~= nil or absorb == 0) and healthMax ~= 0 then
        absorbPrecentage = math.min(absorb / healthMax, 1)
    end
    self.absorbbar:SetValue(absorbPrecentage)
end
GW.AddForProfiling("raidframes", "setAbsorbAmount", setAbsorbAmount)

local function setHealPrediction(self,predictionPrecentage)
    self.predictionbar:SetValue(predictionPrecentage)    
end
GW.AddForProfiling("raidframes", "setHealPrediction", setHealPrediction)

local function setHealthValue(self, healthCur, healthMax, healthPrec)
    local healthsetting = GetSetting("RAID_UNIT_HEALTH" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    local healthstring = ""

    if healthsetting == "NONE" then
        self.healthstring:Hide()
        return
    end

    if healthsetting == "PREC" then
        self.healthstring:SetText(RoundDec(healthPrec *100,0).. "%")
    elseif healthsetting == "HEALTH" then
        self.healthstring:SetText(CommaValue(healthCur))
    elseif healthsetting == "LOSTHEALTH" then
        if healthMax - healthCur > 0 then healthstring = CommaValue(healthMax - healthCur) end
        self.healthstring:SetText(healthstring)
    end
    if healthCur == 0 then 
        self.healthstring:SetTextColor(255, 0, 0)
    else
        self.healthstring:SetTextColor(1, 1, 1)
    end
    self.healthstring:Show()
end
GW.AddForProfiling("raidframes", "setHealthValue", setHealthValue)

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
    setHealPrediction(self,predictionPrecentage)
    setHealthValue(self, health, healthMax, healthPrec)
    Bar(self.healthbar, healthPrec)
end
GW.AddForProfiling("raidframes", "setHealth", setHealth)

local function setPredictionAmount(self)
    local prediction = UnitGetIncomingHeals(self.unit) or 0

    self.healPredictionAmount = prediction
    setHealth(self)
end
GW.AddForProfiling("raidframes", "setPredictionAmount", setPredictionAmount)

local function setUnitName(self)
    if not self or not self.unit then
        return
    end

    local flagSetting = GetSetting("RAID_UNIT_FLAGS" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    local role = UnitGroupRolesAssigned(self.unit)
    local nameString = UnitName(self.unit)
    local realmflag = ""

    if not nameString or nameString == UNKNOWNOBJECT then
        self.nameNotLoaded = false
    else
        self.nameNotLoaded = true
    end

    if flagSetting ~= "NONE" then
        local realmLocal = select(5, LRI:GetRealmInfoByUnit(self.unit))

        if realmLocal then
            realmflag = flagSetting == "DIFFERENT" and GW.mylocal ~= realmLocal and REALM_FLAGS[realmLocal] or flagSetting == "ALL" and REALM_FLAGS[realmLocal] or ""
        end
    end

    if nameRoleIcon[role] then
        nameString = nameRoleIcon[role] .. nameString
    end

    if UnitIsGroupLeader(self.unit) then
        nameString = "|TInterface/AddOns/GW2_UI/textures/party/icon-groupleader:0:0:0:-2:64:64:4:60:4:60|t " .. nameString
    elseif UnitIsGroupAssistant(self.unit) then
        nameString = "|TInterface/AddOns/GW2_UI/textures/party/icon-assist:0:0:0:-2:64:64:4:60:4:60|t " .. nameString
    end

    if self.index then
        local _, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(self.index)
        if role == "MAINTANK" then
            nameString = "|TInterface/AddOns/GW2_UI/textures/party/icon-maintank:15:15:0:-2|t " .. nameString
        elseif role == "MAINASSIST" then
            nameString = "|TInterface/AddOns/GW2_UI/textures/party/icon-mainassist:15:15:0:-1|t " .. nameString
        end 
    end

    self.name:SetText(nameString .. " " .. realmflag)
    self.name:SetWidth(self:GetWidth() - 4)
end
GW.AddForProfiling("raidframes", "setUnitName", setUnitName)

local function highlightTargetFrame(self)
    local guidTarget = UnitGUID("target")
    self.guid = UnitGUID(self.unit)

    if self.guid == guidTarget then
        self.targetHighlight:SetVertexColor(1, 1, 1, 1)
    else
        self.targetHighlight:SetVertexColor(0, 0, 0, 1)
    end
end
GW.AddForProfiling("raidframes", "highlightTargetFrame", highlightTargetFrame)

local function updateAwayData(self)
    local classColor = GetSetting("RAID_CLASS_COLOR" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    local readyCheckStatus = GetReadyCheckStatus(self.unit)
    local iconState = 0
    local _, englishClass, classIndex = UnitClass(self.unit)

    self.name:SetTextColor(1, 1, 1)

    if classColor and classIndex and classIndex > 0 then
        local color = GWGetClassColor(englishClass, true)
        self.healthbar:SetStatusBarColor(color.r, color.g, color.b, color.a)
        self.classicon:SetShown(false)
    end
    if not classColor and not readyCheckStatus then
        iconState = 1
    end
    if UnitIsDeadOrGhost(self.unit) then
        iconState = 2
    end
    if UnitHasIncomingResurrection(self.unit) then
        iconState = 3
    end
    if C_IncomingSummon.HasIncomingSummon(self.unit) then
        local status = C_IncomingSummon.IncomingSummonStatus(self.unit)
        if status == Enum.SummonStatus.Pending then
            iconState = 4
        elseif status == Enum.SummonStatus.Accepted then
            iconState = 5
        elseif status == Enum.SummonStatus.Declined then
            iconState = 6
        end
    end

    if iconState == 1 then
        self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
        self.classicon:SetShown(true)
        self.healthbar:SetStatusBarColor(0.207, 0.392, 0.168)
        SetClassIcon(self.classicon, classIndex)
    end

    if self.targetmarker and not readyCheckStatus and GetSetting("RAID_UNIT_MARKERS"  .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or "")) then
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
        updateRaidMarkers(self)
    end

    if iconState == 2 then
        if classColor then
            self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
        end
        SetDeadIcon(self.classicon)
        self.name:SetTextColor(255, 0, 0)
        self.classicon:Show()
    end

    if iconState == 3 then
        self.classicon:SetTexture("Interface/RaidFrame/Raid-Icon-Rez")
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
        self.name:SetTextColor(1, 1, 1)
        self.classicon:Show()
    end
    if iconState == 4 or iconState == 5 or iconState == 6 then
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
        if iconState == 4 then
            self.classicon:SetAtlas("Raid-Icon-SummonPending")
        elseif iconState == 5 then
            self.classicon:SetAtlas("Raid-Icon-SummonAccepted")
        elseif iconState == 6 then
            self.classicon:SetAtlas("Raid-Icon-SummonDeclined")
        end

        self.classicon:Show()
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
        if not self.classicon:IsShown() then
            self.classicon:Show()
        end
    end

    if not UnitIsConnected(self.unit) then
        self.classicon:SetTexture("Interface/CharacterFrame/Disconnect-Icon")
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
        self.classicon:Show()
        self.healthbar:SetStatusBarColor(0.3, 0.3, 0.3, 1)
    end

    if UnitIsConnected(self.unit) and (UnitPhaseReason(self.unit) or not UnitInRange(self.unit)) then
        local r, g, b = self.healthbar:GetStatusBarColor()

        self.healthbar:SetStatusBarColor(r * 0.3, g * 0.3, b * 0.3)
        self.classicon:SetAlpha(0.4)
    else
        self.classicon:SetAlpha(1)
    end

    if UnitThreatSituation(self.unit) and UnitThreatSituation(self.unit) > 2 then
        self.aggroborder:Show()
    else
        self.aggroborder:Hide()
    end
end
GW.AddForProfiling("raidframes", "updateAwayData", updateAwayData)

local function onDebuffEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:ClearLines()
    GameTooltip:SetUnitDebuff(self:GetParent().unit, self.index, self.filter)
    GameTooltip:Show()
end

local function onDebuffMouseUp(self, btn)
    if btn == "RightButton" and IsShiftKeyDown() then
        local name = UnitDebuff(self:GetParent().unit, self.index, self.filter)
        if name then
            local s = GetSetting("AURAS_IGNORED") or ""
            SetSetting("AURAS_IGNORED", s .. (s == "" and "" or ", ") .. name)
        end
    end
end

local function showDebuffIcon(parent, i, btnIndex, x, y, filter, icon, count, debuffType, duration, expires, isImportant, isDispellable)
    local size = isImportant and (16 * tonumber(GW.GetSetting("RAIDDEBUFFS_Scale"))) or isDispellable and (16 * tonumber(GW.GetSetting("DISPELL_DEBUFFS_Scale"))) or 16
    local marginX, marginY = x * (size + 2), y * (size + 2)
    local frame = _G["Gw" .. parent:GetName() .. "DeBuffItemFrame" .. btnIndex]

    if not frame then
        frame = CreateFrame("Button", "Gw" .. parent:GetName() .. "DeBuffItemFrame" .. btnIndex, parent, "GwDeBuffIcon")
        frame:SetParent(parent)
        frame:SetFrameStrata("MEDIUM")
        frame:SetSize(size, size)
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT", parent.healthbar, "BOTTOMLEFT", marginX + 3, marginY + 3)

        frame.debuffIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
        frame.debuffIcon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)

        frame:SetScript("OnEnter", onDebuffEnter)
        frame:SetScript("OnLeave", GameTooltip_Hide)
        frame:SetScript("OnMouseUp", onDebuffMouseUp)
        frame:RegisterForClicks("RightButtonUp")

        frame.tooltipSetting = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
        if frame.tooltipSetting == "NEVER" then
            frame:EnableMouse(false)
        elseif frame.tooltipSetting == "ALWAYS" then
            frame:EnableMouse(true)
        elseif frame.tooltipSetting == "OUT_COMBAT" then
            frame:EnableMouse(true)
        end
    end

    if debuffType and DEBUFF_COLOR[debuffType] then
        frame.background:SetVertexColor(DEBUFF_COLOR[debuffType].r, DEBUFF_COLOR[debuffType].g, DEBUFF_COLOR[debuffType].b)
    else
        frame.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
    end

    frame.cooldown:SetDrawEdge(0)
    frame.cooldown:SetDrawSwipe(1)
    frame.cooldown:SetReverse(false)
    frame.cooldown:SetHideCountdownNumbers(true)

    frame.icon:SetTexture(icon)

    frame.expires = expires
    frame.duration = duration
    frame.cooldown:SetCooldown(0, 0)
    frame.index = i
    frame.filter = filter

    frame.cooldown.duration:SetText(expires and TimeCount(expires - GetTime()) or 0)
    frame.debuffIcon.stacks:SetText((count or 1) > 1 and count or "")
    frame.debuffIcon.stacks:SetFont(UNIT_NAME_FONT, (count or 1) > 9 and 9 or 14)

    frame:Show()

    btnIndex, x, marginX = btnIndex + 1, x + 1, marginX + size + 2
    if marginX > parent:GetWidth() / 2 then
        x, y, marginX = 0, y + 1, 0
    end

    return btnIndex, x, y, marginX
end

local function updateDebuffs(self)
    local btnIndex, x, y = 1, 0, 0
    local filter = "HARMFUL"
    local showDebuffs = GetSetting("RAID_SHOW_DEBUFFS" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    local onlyDispellableDebuffs = GetSetting("RAID_ONLY_DISPELL_DEBUFFS" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    local showImportendInstanceDebuffs = GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    FillTable(ignored, true, strsplit(",", (GetSetting("AURAS_IGNORED"):trim():gsub("%s*,%s*", ","))))

    local i, framesDone, aurasDone = 0, false, false
    repeat
        i = i + 1

        -- hide old frames
        if not framesDone then
            local frame = _G["Gw" .. self:GetName() .. "DeBuffItemFrame" .. i]
            framesDone = not (frame and frame:IsShown())
            if not framesDone then
                frame:Hide()
            end
        end

        -- show current debuffs
        if not aurasDone then
            local debuffName, icon, count, debuffType, duration, expires, caster, _, _, spellId = UnitDebuff(self.unit, i, filter)
            local shouldDisplay = false
            local isImportant, isDispellable = false, false

            if showDebuffs then
                if onlyDispellableDebuffs then
                    if debuffType and GW.IsDispellableByMe(debuffType) then
                        shouldDisplay = debuffName and not (ignored[debuffName] or spellId == 6788 and caster and not UnitIsUnit(caster, "player")) -- Don't show "Weakened Soul" from other players
                    end
                else
                    shouldDisplay = debuffName and not (ignored[debuffName] or spellId == 6788 and caster and not UnitIsUnit(caster, "player")) -- Don't show "Weakened Soul" from other players
                end

                isDispellable = GW.IsDispellableByMe(debuffType)
            end

            isImportant = (GW.ImportendRaidDebuff[spellId] and showImportendInstanceDebuffs) or false

            if showImportendInstanceDebuffs and not shouldDisplay then
                shouldDisplay = GW.ImportendRaidDebuff[spellId] or false
            end

            if shouldDisplay then
                btnIndex, x, y = showDebuffIcon(self, i, btnIndex, x, y, filter, icon, count, debuffType, duration, expires, isImportant, isDispellable)
            end

            aurasDone = not debuffName or y > 0
        end
    until framesDone and aurasDone
end
GW.AddForProfiling("raidframes", "updateDebuffs", updateDebuffs)

local function onBuffEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
    GameTooltip:ClearLines()
    if self.isMissing then
        GameTooltip:SetSpellByID(self.index)
    else
        GameTooltip:SetUnitBuff(self:GetParent().unit, self.index)
    end
    GameTooltip:Show()
end

local function onBuffMouseUp(self, btn)
    if btn == "RightButton" and IsShiftKeyDown() then
        if self.isMissing then
            local name = GetSpellInfo(self.index)
            if name then
                local s = (GetSetting("AURAS_MISSING") or ""):gsub("%s*,?%s*" .. name .. "%s*,?%s*", ", "):trim(", ")
                SetSetting("AURAS_MISSING", s)
            end
        else
            local name =  UnitBuff(self:GetParent().unit, self.index)
            if name then
                local s = GetSetting("AURAS_IGNORED") or ""
                SetSetting("AURAS_IGNORED", s .. (s == "" and "" or ", ") .. name)
            end
        end
    end
end

local function showBuffIcon(parent, i, btnIndex, x, y, icon, isMissing)
    local size = 14
    local marginX, marginY = x * (size + 2), y * (size + 2)
    local frame = _G["Gw" .. parent:GetName() .. "BuffItemFrame" .. btnIndex]

    if not frame then
        frame = CreateFrame("Button", "Gw" .. parent:GetName() .. "BuffItemFrame" .. btnIndex, parent, "GwBuffIconBig")
        frame:SetParent(parent)
        frame:SetFrameStrata("MEDIUM")
        frame:SetSize(14, 14)
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMRIGHT", parent.healthbar, "BOTTOMRIGHT", -(marginX + 3), marginY + 3)

        frame.buffDuration:SetFont(UNIT_NAME_FONT, 11)
        frame.buffDuration:SetTextColor(1, 1, 1)
        frame.buffStacks:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
        frame.buffStacks:SetTextColor(1, 1, 1)

        frame:SetScript("OnEnter", onBuffEnter)
        frame:SetScript("OnLeave", GameTooltip_Hide)
        frame:SetScript("OnMouseUp", onBuffMouseUp)
        frame:RegisterForClicks("RightButtonUp")

        frame.tooltipSetting = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
        if frame.tooltipSetting == "NEVER" then
            frame:EnableMouse(false)
        elseif frame.tooltipSetting == "ALWAYS" then
            frame:EnableMouse(true)
        elseif frame.tooltipSetting == "OUT_COMBAT" then
            frame:EnableMouse(true)
        end
    end

    frame.index = i
    frame.isMissing = isMissing

    frame.buffIcon:SetTexture(icon)
    frame.buffIcon:SetVertexColor(1, isMissing and .75 or 1, isMissing and .75 or 1)
    frame.buffDuration:SetText("")
    frame.buffStacks:SetText("")

    frame:Show()

    btnIndex, x, marginX = btnIndex + 1, x + 1, marginX + size + 2
    if marginX > parent:GetWidth() / 2 then
        x, y = 0, y + 1
    end

    return btnIndex, x, y
end

local function updateBuffs(self)
    local btnIndex, x, y = 1, 0, 0
    local indicators = AURAS_INDICATORS[GW.myclass]
    local i, name, spellid = 1, nil, nil
    FillTable(missing, true, strsplit(",", (GetSetting("AURAS_MISSING"):trim():gsub("%s*,%s*", ","))))
    FillTable(ignored, true, strsplit(",", (GetSetting("AURAS_IGNORED"):trim():gsub("%s*,%s*", ","))))

    for _, pos in pairs(INDICATORS) do
        self['indicator' .. pos]:Hide()
    end

    -- missing buffs
    if not UnitIsDeadOrGhost(self.unit) then

        repeat
            i, name = i + 1, UnitBuff(self.unit, i)
            if name and missing[name] then
                missing[name] = false
            end
        until not name

        i = 0
        for mName, v in pairs(missing) do
            if v then
                while not spellIDs[mName] and spellBookSearched < MAX_SPELLS do
                    spellBookSearched = spellBookSearched + 1
                    name, _, spellid = GetSpellBookItemName(spellBookSearched, BOOKTYPE_SPELL)
                    if not name or not spellid then
                        spellBookSearched = MAX_SPELLS
                    elseif missing[name] ~= nil and not spellIDs[name] then
                        spellIDs[name] = spellid
                    end
                end

                if spellIDs[mName] then
                    local icon = GetSpellTexture(spellIDs[mName])
                    i, btnIndex, x, y = i + 1, showBuffIcon(self, spellIDs[mName], btnIndex, x, y, icon, true)
                end
            end
        end
    end

    -- current buffs
    local framesDone, aurasDone
    repeat
        i = i + 1

        -- hide old frames
        if not framesDone then
            local frame = _G["Gw" .. self:GetName() .. "BuffItemFrame" .. i]
            framesDone = not (frame and frame:IsShown())
            if not framesDone then
                frame:Hide()
            end
        end

        -- show buffs
        if not aurasDone then
            local name, icon, count, _, duration, expires, caster, _, _, spellID, canApplyAura, _ = UnitBuff(self.unit, i)
            if name then
                -- visibility
                local shouldDisplay
                local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
                if (hasCustom) then
                    shouldDisplay = showForMySpec or (alwaysShowMine and (caster == "player" or caster == "pet" or caster == "vehicle"))
                else
                    shouldDisplay = (caster == "player" or caster == "pet" or caster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellID)
                end

                if shouldDisplay then
                    -- indicators
                    local indicator = indicators[spellID]
                    if indicator then
                        for _, pos in ipairs(INDICATORS) do
                            if GetSetting("INDICATOR_" .. pos, true) == (indicator[4] or spellID) then
                                local frame = self["indicator" .. pos]
                                local r, g, b = unpack(indicator)

                                if pos == "BAR" then
                                    frame.expires = expires
                                    frame.duration = duration
                                else
                                    -- Stacks
                                    if count > 1 then
                                        frame.text:SetText(count)
                                        frame.text:SetFont(UNIT_NAME_FONT, count > 9 and 9 or 11, "OUTLINE")
                                        frame.text:Show()
                                    else
                                        frame.text:Hide()
                                    end

                                    -- Icon
                                    if GetSetting("INDICATORS_ICON") then
                                        frame.icon:SetTexture(icon)
                                    else
                                        frame.icon:SetColorTexture(r, g, b)
                                    end

                                    -- Cooldown
                                    if GetSetting("INDICATORS_TIME") then
                                        frame.cooldown:Show()
                                        frame.cooldown:SetCooldown(expires - duration, duration)
                                    else
                                        frame.cooldown:Hide()
                                    end

                                    shouldDisplay = false
                                end

                                frame:Show()
                            end
                        end
                    end

                    --set new buff
                    if shouldDisplay and not (ignored[name] or missing[name] ~= nil) then
                        btnIndex, x, y = showBuffIcon(self, i, btnIndex, x, y, icon)
                    end
                end
            else
                aurasDone = true
            end
        end
    until framesDone and aurasDone
end
GW.AddForProfiling("raidframes", "updateBuffs", updateBuffs)

local function updateAuras(self)
    updateBuffs(self)
    updateDebuffs(self)
end
GW.AddForProfiling("raidframes", "updateAuras", updateAuras)

local function updatePower(self)
    local power = UnitPower(self.unit, UnitPowerType(self.unit))
    local powerMax = UnitPowerMax(self.unit, UnitPowerType(self.unit))
    local powerPrecentage = 0
    if powerMax > 0 then
        powerPrecentage = power / powerMax
    end
    self.manabar:SetValue(powerPrecentage)
    local _, powerToken = UnitPowerType(self.unit)
    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.manabar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end
end

local function raidframe_OnEvent(self, event, unit)
    if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        -- Enable or disable mouse handling on aura frames
        local name = self:GetName()
        for j = 1, 2 do
            local i, aura = 1, j == 1 and "Buff" or "DeBuff"
            local frame = nil
            repeat
                frame = _G["Gw" .. name .. aura .. "ItemFrame" .. i]
                if frame then
                    if frame.tooltipSetting == "NEVER" then
                        frame:EnableMouse(false)
                    elseif frame.tooltipSetting == "ALWAYS" then
                        frame:EnableMouse(true)
                    elseif frame.tooltipSetting == "IN_COMBAT" and event == "PLAYER_REGEN_ENABLED" then
                        frame:EnableMouse(false)
                    elseif frame.tooltipSetting == "IN_COMBAT" and event == "PLAYER_REGEN_DISABLED" then
                        frame:EnableMouse(true)
                    elseif frame.tooltipSetting == "OUT_COMBAT" and event == "PLAYER_REGEN_ENABLED" then
                        frame:EnableMouse(true)
                    elseif frame.tooltipSetting == "OUT_COMBAT" and event == "PLAYER_REGEN_DISABLED" then
                        frame:EnableMouse(false)
                    end
                end
                i = i + 1
            until not frame
        end
    end

    if not UnitExists(self.unit) then
        return
    elseif not self.nameNotLoaded then
        setUnitName(self)
    end

    if event == "load" then
        setAbsorbAmount(self)
        setPredictionAmount(self)
        setHealth(self)
        updateAwayData(self)
        updateAuras(self)
        updatePower(self)
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        setHealth(self)
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        updatePower(self)
    elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        setAbsorbAmount(self)
    elseif event == "UNIT_HEAL_PREDICTION" then
        setPredictionAmount(self)
    elseif event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" or event == "UNIT_THREAT_SITUATION_UPDATE" then
        updateAwayData(self)
    elseif event == "PLAYER_TARGET_CHANGED" then
        highlightTargetFrame(self)
    elseif event == "UNIT_NAME_UPDATE" then
        setUnitName(self)
    elseif event == "UNIT_AURA" then
        updateAuras(self)
    elseif event == "PLAYER_ENTERING_WORLD" then
        RequestRaidInfo()
    elseif event == "UPDATE_INSTANCE_INFO" then
        updateAuras(self)
        updateAwayData(self)
    elseif (event == "INCOMING_RESURRECT_CHANGED" or event == "INCOMING_SUMMON_CHANGED") and unit == self.unit then
        updateAwayData(self)
    elseif event == "RAID_TARGET_UPDATE" and GetSetting("RAID_UNIT_MARKERS" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or "")) then
        updateRaidMarkers(self)
    elseif event == "READY_CHECK" or (event == "READY_CHECK_CONFIRM" and unit == self.unit) then
        updateAwayData(self)
    elseif event == "READY_CHECK_FINISHED" then
        C_Timer.After(1.5, function()
            if UnitInRaid(self.unit) then
                local _, englishClass, classIndex = UnitClass(self.unit)
                if GetSetting("RAID_CLASS_COLOR" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or "")) then
                    local color = GWGetClassColor(englishClass, true)
                    self.healthbar:SetStatusBarColor(color.r, color.g, color.b, color.a)
                    self.classicon:SetShown(false)
                else
                    self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
                    self.healthbar:SetStatusBarColor(0.207, 0.392, 0.168)
                    self.classicon:SetShown(true)
                    SetClassIcon(self.classicon, classIndex)
                end
            end
        end)
    end
end
GW.raidframe_OnEvent = raidframe_OnEvent
GW.AddForProfiling("raidframes", "raidframe_OnEvent", raidframe_OnEvent)

local function updateFrameData(self, index)
    if not UnitExists(self.unit) then
        return
    end

    self.guid = UnitGUID(self.unit)
    self.index = index

    local health = UnitHealth(self.unit)
    local healthMax = UnitHealthMax(self.unit)
    local healthPrec = 0
    local absorb = UnitGetTotalAbsorbs(self.unit)
    local absorbPrecentage = 0
    local prediction = UnitGetIncomingHeals(self.unit) or 0
    local predictionPrecentage = 0

    local power = UnitPower(self.unit, UnitPowerType(self.unit))
    local powerMax = UnitPowerMax(self.unit, UnitPowerType(self.unit))
    local powerPrecentage = 0

    if healthMax > 0 then
        healthPrec = health / healthMax
    end
    if absorb > 0 and healthMax > 0 then
        absorbPrecentage = math.min(absorb / healthMax, 1)
    end
    if prediction > 0 and healthMax > 0 then
        predictionPrecentage = math.min((healthPrec) + (prediction / healthMax), 1)
    end
    if powerMax > 0 then
        powerPrecentage = power / powerMax
    end
    self.manabar:SetValue(powerPrecentage)
    Bar(self.healthbar, healthPrec)
    self.absorbbar:SetValue(absorbPrecentage)
    self.predictionbar:SetValue(predictionPrecentage)

    local _, powerToken = UnitPowerType(self.unit)
    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.manabar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end

    setUnitName(self)
    -- highlightTargetFrame()

    updateAwayData(self)
    updateAuras(self)
end
GW.AddForProfiling("raidframes", "updateFrameData", updateFrameData)

local function raidframe_OnUpdate(self, elapsed)
    if self.onUpdateDelay ~= nil and self.onUpdateDelay > 0 then
        self.onUpdateDelay = self.onUpdateDelay - elapsed
        return
    end
    self.onUpdateDelay = 0.2
    if UnitExists(self.unit) then
        updateAwayData(self)
    end
end
GW.AddForProfiling("raidframes", "raidframe_OnUpdate", raidframe_OnUpdate)

local function GetRaidFramesMeasures(players)
    -- Get settings
    local grow = GetSetting("RAID_GROW" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    local w = GetSetting("RAID_WIDTH" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    local h = GetSetting("RAID_HEIGHT" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    local cW = GetSetting("RAID_CONT_WIDTH" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    local cH = GetSetting("RAID_CONT_HEIGHT" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    local per = ceil(GetSetting("RAID_UNITS_PER_COLUMN" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or "")))
    local byRole = GetSetting("RAID_SORT_BY_ROLE" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))
    local m = 2

    -- Determine # of players
    if players or byRole or not IsInRaid() then
        players = players or max(1, GetNumGroupMembers())
    else
        players = 0
        for i = 1, MAX_RAID_MEMBERS do
            local _, _, grp = GetRaidRosterInfo(i)
            if grp >= ceil(players / MEMBERS_PER_RAID_GROUP) then
                players = max((grp - 1) * MEMBERS_PER_RAID_GROUP, players) + 1
            end
        end
        players = max(1, players, GetNumGroupMembers())
    end

    -- Directions
    local grow1, grow2 = strsplit("+", grow)
    local isV = grow1 == "DOWN" or grow1 == "UP"

    -- Rows, cols and cell size
    local sizeMax1, sizePer1 = isV and cH or cW, isV and h or w
    local sizeMax2, sizePer2 = isV and cW or cH, isV and w or h

    local cells1 = players

    if per > 0 then
        cells1 = min(cells1, per)
        if tonumber(sizeMax1) > 0 then
            sizePer1 = min(sizePer1, (sizeMax1 + m) / cells1 - m)
        end
    elseif tonumber(sizeMax1) > 0 then
        cells1 = max(1, min(players, floor((sizeMax1 + m) / (sizePer1 + m))))
    end

    local cells2 = ceil(players / cells1)

    if tonumber(sizeMax2) > 0 then
        sizePer2 = min(sizePer2, (sizeMax2 + m) / cells2 - m)
    end

    -- Container size
    local size1, size2 = cells1 * (sizePer1 + m) - m, cells2 * (sizePer2 + m) - m
    sizeMax1, sizeMax2 = max(size1, sizeMax1), max(size2, sizeMax2)

    return grow1, grow2, cells1, cells2, size1, size2, sizeMax1, sizeMax2, sizePer1, sizePer2, m
end
GW.AddForProfiling("raidframes", "GetRaidFramesMeasures", GetRaidFramesMeasures)

local function PositionRaidFrame(frame, parent, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
    local isV = grow1 == "DOWN" or grow1 == "UP"
    local isU = grow1 == "UP" or grow2 == "UP"
    local isR = grow1 == "RIGHT" or grow2 == "RIGHT"

    local dir1, dir2 = isU and 1 or -1, isR and 1 or -1
    if not isV then
        dir1, dir2 = dir2, dir1
    end

    local pos1, pos2 = dir1 * ((i - 1) % cells1), dir2 * (ceil(i / cells1) - 1)

    local a = (isU and "BOTTOM" or "TOP") .. (isR and "LEFT" or "RIGHT")
    local w = isV and sizePer2 or sizePer1
    local h = isV and sizePer1 or sizePer2
    local x = (isV and pos2 or pos1) * (w + m)
    local y = (isV and pos1 or pos2) * (h + m)

    if not InCombatLockdown() then
        frame:ClearAllPoints()
        frame:SetPoint(a, parent, a, x, y)
        frame:SetSize(w, h)
    end

    if frame.healthbar then
        frame.healthbar.spark:SetHeight(frame.healthbar:GetHeight())
    end
end

local function UpdateRaidFramesAnchor()
    GwRaidFrameContainer.gwMover:GetScript("OnDragStop")(GwRaidFrameContainer.gwMover)
    GwRaidFramePartyContainer.gwMover:GetScript("OnDragStop")(GwRaidFramePartyContainer.gwMover)
end
GW.UpdateRaidFramesAnchor = UpdateRaidFramesAnchor
GW.AddForProfiling("raidframes", "UpdateRaidFramesAnchor", UpdateRaidFramesAnchor)

local function UpdateRaidFramesPosition()
    local g_type_old = GW.GROUPD_TYPE

    if GW.GROUPD_TYPE == "PARTY" or onLoad then
        if onLoad then GW.GROUPD_TYPE = "PARTY" end

        players = previewStep == 0 and 5 or previewSteps[previewStep]

        -- Get directions, rows, cols and sizing
        local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GetRaidFramesMeasures(players)
        local isV = grow1 == "DOWN" or grow1 == "UP"

        -- Update size
        --print(isV and size2 or size1, isV and size1 or size2)
        GwRaidFramePartyContainer.gwMover:SetSize(isV and size2 or size1, isV and size1 or size2)

        -- Update unit frames
        for i = 1, 5 do
            PositionRaidFrame(_G["GwCompactraid" .. i], GwRaidFramePartyContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
            if i > (IsInGroup() and GetNumGroupMembers() or players) then _G["GwCompactraid" .. i]:Hide() else _G["GwCompactraid" .. i]:Show() end
        end
    end
    if GW.GROUPD_TYPE == "RAID" or onLoad then
        if onLoad then GW.GROUPD_TYPE = "RAID" end

        players = previewStep == 0 and 40 or previewSteps[previewStep]

        -- Get directions, rows, cols and sizing
        local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GetRaidFramesMeasures(players)
        local isV = grow1 == "DOWN" or grow1 == "UP"

        -- Update size
        GwRaidFrameContainer.gwMover:SetSize(isV and size2 or size1, isV and size1 or size2)

        -- Update unit frames
        for i = 1, MAX_RAID_MEMBERS do
            PositionRaidFrame(_G["GwCompactraid" .. i], GwRaidFrameContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
            if i > (IsInGroup() and GetNumGroupMembers() or players) then _G["GwCompactraid" .. i]:Hide() else _G["GwCompactraid" .. i]:Show() end
        end
    end

    GW.GROUPD_TYPE = g_type_old
end
GW.UpdateRaidFramesPosition = UpdateRaidFramesPosition
GW.AddForProfiling("raidframes", "UpdateRaidFramesPosition", UpdateRaidFramesPosition)

local function ToggleRaidFramesPreview(_, _, moveHudMode)
    previewStep = max((previewStep + 1) % (#previewSteps + 1), hudMoving and 1 or 0, (previewStep == 4 and GW.GROUPD_TYPE == "PARTY" and 0 or GW.GROUPD_TYPE == "PARTY" and 4 or 0))

    if previewStep == 0 or moveHudMode then
        for i = 1, MAX_RAID_MEMBERS do
            if _G["GwCompactraid" .. i] then
                _G["GwCompactraid" .. i].unit = "raid" .. i
                _G["GwCompactraid" .. i].guid = UnitGUID("raid" .. i)
                _G["GwCompactraid" .. i]:SetAttribute("unit", "raid" .. i)
                raidframe_OnEvent(_G["GwCompactraid" .. i], "load")
            end
        end
    else
        for i = 1, MAX_RAID_MEMBERS do
            if _G["GwCompactraid" .. i] then
                if i <= (previewStep == 0 and (GW.GROUPD_TYPE == "PARTY" and 5 or 40) or previewSteps[previewStep]) then
                    _G["GwCompactraid" .. i].unit = "player"
                    _G["GwCompactraid" .. i].guid = UnitGUID("player")
                    _G["GwCompactraid" .. i]:SetAttribute("unit", "player")
                else
                    _G["GwCompactraid" .. i].unit = "raid" .. i
                    _G["GwCompactraid" .. i].guid = UnitGUID("raid" .. i)
                    _G["GwCompactraid" .. i]:SetAttribute("unit", "raid" .. i)
                end
                raidframe_OnEvent(_G["GwCompactraid" .. i], "load")
            end
        end
        UpdateRaidFramesPosition()
    end
    GwSettingsRaidPanel.buttonRaidPreview:SetText(previewStep == 0 and "-" or previewSteps[previewStep])
end

local function sortByRole()
    local sorted = {}
    local roleIndex = {"TANK", "HEALER", "DAMAGER", "NONE"}
    local unitString = IsInRaid() and "raid" or "party"

    for _, v in pairs(roleIndex) do
        if unitString == "party" and UnitGroupRolesAssigned("player") == v then
            tinsert(sorted, "player")
        end

        for i = 1, MAX_RAID_MEMBERS do
            if UnitExists(unitString .. i) and UnitGroupRolesAssigned(unitString .. i) == v then
                tinsert(sorted, unitString .. i)
            end
        end
    end
    return sorted
end
GW.AddForProfiling("raidframes", "sortByRole", sortByRole)

local grpPos, noGrp = {}, {}
local function UpdateRaidFramesLayout()

    local g_type_old = GW.GROUPD_TYPE
    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GetRaidFramesMeasures()
    local isV = grow1 == "DOWN" or grow1 == "UP"

    local unitString = IsInRaid() and "raid" or "party"
    local sorted = (unitString == "party" or GetSetting("RAID_SORT_BY_ROLE" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))) and sortByRole() or {}

    if not InCombatLockdown() then
        if GW.GROUPD_TYPE == "PARTY" or onLoad then
            if onLoad then GW.GROUPD_TYPE = "PARTY" end
            GwRaidFramePartyContainer:SetSize(isV and size2 or size1, isV and size1 or size2)
        end
        if GW.GROUPD_TYPE == "RAID" or onLoad then
            if onLoad then GW.GROUPD_TYPE = "RAID" end
            GwRaidFrameContainer:SetSize(isV and size2 or size1, isV and size1 or size2)
        end
    end


    if GW.GROUPD_TYPE == "PARTY" or onLoad then
        if onLoad then GW.GROUPD_TYPE = "PARTY" end
        -- Position by role
        for i, v in ipairs(sorted) do
            PositionRaidFrame(_G["GwCompact" .. v], GwRaidFramePartyContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
        end

        wipe(grpPos) wipe(noGrp)

        -- Position by group
        for i = 1, MAX_RAID_MEMBERS do
            if not tContains(sorted, unitString .. i) then
                if i < MEMBERS_PER_RAID_GROUP then
                    PositionRaidFrame(_G["GwCompactparty" .. i], GwRaidFramePartyContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
                end

                local name, _, grp = GetRaidRosterInfo(i)
                if name or grp > 1 then
                    grpPos[grp] = (grpPos[grp] or 0) + 1
                    PositionRaidFrame(_G["GwCompactraid" .. i], GwRaidFramePartyContainer , (grp - 1) * MEMBERS_PER_RAID_GROUP + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
                else
                    tinsert(noGrp, i)
                end
            end
        end

        -- Find spots for units with missing group info
        for _,i in ipairs(noGrp) do
            for grp = 1, NUM_RAID_GROUPS do
                if (grpPos[grp] or 0) < MEMBERS_PER_RAID_GROUP then
                    grpPos[grp] = (grpPos[grp] or 0) + 1
                    PositionRaidFrame(_G["GwCompactraid" .. i], GwRaidFramePartyContainer, (grp - 1) * MEMBERS_PER_RAID_GROUP + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
                    break
                end
            end
        end
    end
    if GW.GROUPD_TYPE == "RAID" or onLoad then
        if onLoad then GW.GROUPD_TYPE = "RAID" end
        -- Position by role
        for i, v in ipairs(sorted) do
            PositionRaidFrame(_G["GwCompact" .. v], GwRaidFrameContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
        end

        wipe(grpPos) wipe(noGrp)


        -- Position by group
        for i = 1, MAX_RAID_MEMBERS do
            if not tContains(sorted, unitString .. i) then
                if i < MEMBERS_PER_RAID_GROUP then
                    PositionRaidFrame(_G["GwCompactparty" .. i], GwRaidFrameContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
                end

                local name, _, grp = GetRaidRosterInfo(i)
                if name or grp > 1 then
                    grpPos[grp] = (grpPos[grp] or 0) + 1
                    PositionRaidFrame(_G["GwCompactraid" .. i], GwRaidFrameContainer , (grp - 1) * MEMBERS_PER_RAID_GROUP + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
                else
                    tinsert(noGrp, i)
                end
            end
        end

        -- Find spots for units with missing group info
        for _,i in ipairs(noGrp) do
            for grp = 1, NUM_RAID_GROUPS do
                if (grpPos[grp] or 0) < MEMBERS_PER_RAID_GROUP then
                    grpPos[grp] = (grpPos[grp] or 0) + 1
                    PositionRaidFrame(_G["GwCompactraid" .. i], GwRaidFrameContainer, (grp - 1) * MEMBERS_PER_RAID_GROUP + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
                    break
                end
            end
        end
    end

    GW.GROUPD_TYPE = g_type_old
end
GW.UpdateRaidFramesLayout = UpdateRaidFramesLayout
GW.AddForProfiling("raidframes", "UpdateRaidFramesLayout", UpdateRaidFramesLayout)

local function createRaidFrame(registerUnit, index)
    local frame = _G["GwCompact" .. registerUnit]
    if not frame then
        frame = CreateFrame("Button", "GwCompact" .. registerUnit, GwRaidFrameContainer, "GwRaidFrame")
        frame.name = _G[frame:GetName() .. "Data"].name
        frame.healthstring = _G[frame:GetName() .. "Data"].healthstring
        frame.classicon = _G[frame:GetName() .. "Data"].classicon
        frame.healthbar = frame.predictionbar.healthbar
        frame.absorbbar = frame.healthbar.absorbbar
        frame.aggroborder = frame.absorbbar.aggroborder
        frame.nameNotLoaded = false

        if GetSetting("FONTS_ENABLED") then -- for any reason blizzard is not supporting UTF8 if we set this font
            frame.name:SetFont(UNIT_NAME_FONT, 12)
        end
        frame.name:SetShadowOffset(-1, -1)
        frame.name:SetShadowColor(0, 0, 0, 1)

        frame.healthstring:SetFont(UNIT_NAME_FONT, 11)
        frame.healthstring:SetShadowOffset(-1, -1)
        frame.healthstring:SetShadowColor(0, 0, 0, 1)

        hooksecurefunc(
            frame.healthbar,
            "SetStatusBarColor",
            function(_, r, g, b, a)
                frame.healthbar.spark:SetVertexColor(r, g, b, a)
            end
        )
    end

    frame.unit = registerUnit
    frame.guid = UnitGUID(frame.unit)
    frame.ready = -1
    frame.targetmarker = GetRaidTargetIndex(frame.unit)
    frame.index = index

    frame.healthbar.animationName = "GwCompact" .. registerUnit .. "animation"
    frame.healthbar.animationValue = 0

    frame.manabar.animationName = "GwCompact" .. registerUnit .. "manabaranimation"
    frame.manabar.animationValue = 0

    frame:SetAttribute("unit", registerUnit)
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")

    AddToClique(frame)

    RegisterUnitWatch(frame)
    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyUp")

    frame:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        if self.guid ~= UnitGUID("target") then
            self.targetHighlight:SetVertexColor(0, 0, 0, 1)
        end
    end)
    frame:SetScript(
        "OnEnter",
        function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit(registerUnit)
            GameTooltip:Show()
            self.targetHighlight:SetVertexColor(1, 1, 1, 1)
        end
    )

    frame:SetScript("OnEvent", raidframe_OnEvent)
    frame:SetScript("OnUpdate", raidframe_OnUpdate)

    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("READY_CHECK")
    frame:RegisterEvent("READY_CHECK_CONFIRM")
    frame:RegisterEvent("READY_CHECK_FINISHED")
    frame:RegisterEvent("RAID_TARGET_UPDATE")
    frame:RegisterEvent("UPDATE_INSTANCE_INFO")
    frame:RegisterEvent("PARTY_MEMBER_DISABLE")
    frame:RegisterEvent("PARTY_MEMBER_ENABLE")
    frame:RegisterEvent("INCOMING_RESURRECT_CHANGED")
    frame:RegisterEvent("INCOMING_SUMMON_CHANGED")

    frame:RegisterUnitEvent("UNIT_HEALTH", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", registerUnit)
    frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", registerUnit)
    frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", registerUnit)
    frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", registerUnit)
    frame:RegisterUnitEvent("UNIT_PHASE", registerUnit)
    frame:RegisterUnitEvent("UNIT_AURA", registerUnit)
    frame:RegisterUnitEvent("UNIT_LEVEL", registerUnit)
    frame:RegisterUnitEvent("UNIT_TARGET", registerUnit)
    frame:RegisterUnitEvent("UNIT_NAME_UPDATE", registerUnit)
    frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", registerUnit)

    raidframe_OnEvent(frame, "load")

    if GetSetting("RAID_POWER_BARS") then
        frame.predictionbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 5)
        frame.manabar:Show()
    end
end
GW.AddForProfiling("raidframes", "createRaidFrame", createRaidFrame)

local function LoadRaidFrames()
    onLoad = true
    if not _G.GwManageGroupButton then
        GW.manageButton()
    end

    hideBlizzardRaidFrame()

    if CompactRaidFrameManager_UpdateShown then
        hooksecurefunc("CompactRaidFrameManager_UpdateShown", hideBlizzardRaidFrame)
    end
    if CompactRaidFrameManager then
        CompactRaidFrameManager:HookScript("OnShow", hideBlizzardRaidFrame)
    end

    CreateFrame("Frame", "GwRaidFrameContainer", UIParent, "GwRaidFrameContainer")
    CreateFrame("Frame", "GwRaidFramePartyContainer", UIParent, "GwRaidFrameContainer")

    GwRaidFrameContainer:ClearAllPoints()
    GwRaidFrameContainer:SetPoint(
        GetSetting("raid_pos")["point"],
        UIParent,
        GetSetting("raid_pos")["relativePoint"],
        GetSetting("raid_pos")["xOfs"],
        GetSetting("raid_pos")["yOfs"]
    )

    GwRaidFramePartyContainer:ClearAllPoints()
    GwRaidFramePartyContainer:SetPoint(
        GetSetting("raid_party_pos")["point"],
        UIParent,
        GetSetting("raid_party_pos")["relativePoint"],
        GetSetting("raid_party_pos")["xOfs"],
        GetSetting("raid_party_pos")["yOfs"]
    )

    RegisterMovableFrame(GwRaidFrameContainer, RAID_FRAMES_LABEL, "raid_pos", "VerticalActionBarDummy", nil, true, {"default", "default"})
    RegisterMovableFrame(GwRaidFramePartyContainer, L["Group Frames"], "raid_party_pos", "VerticalActionBarDummy", nil, true, {"default", "default"})

    hooksecurefunc(GwRaidFrameContainer.gwMover, "StopMovingOrSizing", function (frame)
        local anchor = GetSetting("RAID_ANCHOR" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))

        if anchor == "GROWTH" then
            local g1, g2 = strsplit("+", GetSetting("RAID_GROW" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or "")))
            anchor = (IsIn("DOWN", g1, g2) and "TOP" or "BOTTOM") .. (IsIn("RIGHT", g1, g2) and "LEFT" or "RIGHT")
        end

        if anchor ~= "POSITION" then
            local x = anchor:sub(-5) == "RIGHT" and frame:GetRight() - GetScreenWidth() or anchor:sub(-4) == "LEFT" and frame:GetLeft() or frame:GetLeft() + (frame:GetWidth() - GetScreenWidth()) / 2
            local y = anchor:sub(1, 3) == "TOP" and frame:GetTop() - GetScreenHeight() or anchor:sub(1, 6) == "BOTTOM" and frame:GetBottom() or frame:GetBottom() + (frame:GetHeight() - GetScreenHeight()) / 2

            frame:ClearAllPoints()
            frame:SetPoint(anchor, x, y)
        end

        if not InCombatLockdown() then
            GwRaidFrameContainer:ClearAllPoints()
            GwRaidFrameContainer:SetPoint(frame:GetPoint())
        end
    end)

    hooksecurefunc(GwRaidFramePartyContainer.gwMover, "StopMovingOrSizing", function (frame)
        local anchor = GetSetting("RAID_ANCHOR" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or ""))

        if anchor == "GROWTH" then
            local g1, g2 = strsplit("+", GetSetting("RAID_GROW" .. (GW.GROUPD_TYPE == "PARTY" and "_PARTY" or "")))
            anchor = (IsIn("DOWN", g1, g2) and "TOP" or "BOTTOM") .. (IsIn("RIGHT", g1, g2) and "LEFT" or "RIGHT")
        end

        if anchor ~= "POSITION" then
            local x = anchor:sub(-5) == "RIGHT" and frame:GetRight() - GetScreenWidth() or anchor:sub(-4) == "LEFT" and frame:GetLeft() or frame:GetLeft() + (frame:GetWidth() - GetScreenWidth()) / 2
            local y = anchor:sub(1, 3) == "TOP" and frame:GetTop() - GetScreenHeight() or anchor:sub(1, 6) == "BOTTOM" and frame:GetBottom() or frame:GetBottom() + (frame:GetHeight() - GetScreenHeight()) / 2

            frame:ClearAllPoints()
            frame:SetPoint(anchor, x, y)
        end

        if not InCombatLockdown() then
            GwRaidFramePartyContainer:ClearAllPoints()
            GwRaidFramePartyContainer:SetPoint(frame:GetPoint())
        end
    end)

    createRaidFrame("player", nil)
    for i = 1, 4 do
        createRaidFrame("party" .. i, i)
    end

    for i = 1, MAX_RAID_MEMBERS do
        createRaidFrame("raid" .. i, i)
    end

    UpdateRaidFramesPosition()
    UpdateRaidFramesLayout()

    GwSettingsRaidPanel.buttonRaidPreview:SetScript("OnClick", ToggleRaidFramesPreview)
    GwSettingsRaidPanel.buttonRaidPreview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to toggle raid frame preview and cycle through different group sizes."], 1, 1, 1)
        GameTooltip:Show()
    end)
    GwSettingsRaidPanel.buttonRaidPreview:SetScript("OnLeave", GameTooltip_Hide)
    GwSettingsWindowMoveHud:HookScript("OnClick", function ()
        hudMoving = true
        ToggleRaidFramesPreview(_, _, true)
    end)
    GwSmallSettingsWindow.lockHud:HookScript("OnClick", function()
        hudMoving = false
        previewStep = 4
        ToggleRaidFramesPreview(_, _, false)
    end)

    GwRaidFrameContainer:RegisterEvent("RAID_ROSTER_UPDATE")
    GwRaidFrameContainer:RegisterEvent("GROUP_ROSTER_UPDATE")
    GwRaidFrameContainer:RegisterEvent("PLAYER_ENTERING_WORLD")

    GwRaidFrameContainer:SetScript("OnEvent", function(self)
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            --return
        else
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end

        if not IsInRaid() and IsInGroup() and GW.GROUPD_TYPE == "RAID" then
            togglePartyFrames(true)
            GW.GROUPD_TYPE = "PARTY"
        elseif IsInRaid() then
            togglePartyFrames(false)
            GW.GROUPD_TYPE = "RAID"
        end

        unhookPlayerFrame()

        UpdateRaidFramesLayout()

        updateFrameData(_G["GwCompactplayer"], nil)
        for i = 1, MAX_RAID_MEMBERS do
            if i < MEMBERS_PER_RAID_GROUP then
                updateFrameData(_G["GwCompactparty" .. i], i)
            end
            updateFrameData(_G["GwCompactraid" .. i], i)
        end

        GwSettingsRaidPanel.selectProfile.string:SetText(getglobal(GW.GROUPD_TYPE))
        if GW.GROUPD_TYPE == "RAID" then
            GwSettingsRaidPanel.selectProfile.raid:GetScript("OnClick")(GwSettingsRaidPanel.selectProfile.raid)
        else
            GwSettingsRaidPanel.selectProfile.party:GetScript("OnClick")(GwSettingsRaidPanel.selectProfile.party)
        end

        GwSettingsRaidPanel.selectProfile.container:Hide()

        -- update positions
        GW.CombatQueue_Queue("raidframePosUpdate",
            function(profileType)
                if profileType == "RAID" then
                    GwRaidFrameContainer:ClearAllPoints()
                    GwRaidFrameContainer:SetPoint("TOPLEFT", GwRaidFrameContainer.gwMover)
                elseif profileType == "PARTY" then
                    GwRaidFrameContainer:ClearAllPoints()
                    GwRaidFrameContainer:SetPoint("TOPLEFT", GwRaidFramePartyContainer.gwMover)
                end
            end,
            {GW.GROUPD_TYPE}
        )
    end)

    onLoad = false

    if not GetSetting("RAID_STYLE_PARTY") and not GetSetting("RAID_STYLE_PARTY_AND_FRAMES") then
        UnregisterUnitWatch(_G["GwCompactplayer"])
        _G["GwCompactplayer"]:Hide()
        for i = 1, 4 do
            UnregisterUnitWatch(_G["GwCompactparty" .. i])
            _G["GwCompactparty" .. i]:Hide()
        end
        return
    end
    if not UnitExists("party1") then
        UnregisterUnitWatch(_G["GwCompactplayer"])
        _G["GwCompactplayer"]:Hide()
    end
end
GW.LoadRaidFrames = LoadRaidFrames
