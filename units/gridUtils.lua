local _, GW = ...
local CommaValue = GW.CommaValue
local RoundDec = GW.RoundDec
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local REALM_FLAGS = GW.REALM_FLAGS
local nameRoleIcon = GW.nameRoleIcon
local LRI = GW.Libs.LRI
local DEBUFF_COLOR = GW.DEBUFF_COLOR
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local FillTable = GW.FillTable
local TimeCount = GW.TimeCount
local INDICATORS = GW.INDICATORS
local AURAS_INDICATORS = GW.AURAS_INDICATORS
local PowerBarColorCustom = GW.PowerBarColorCustom
local AddToClique = GW.AddToClique

local missing, ignored = {}, {}
local spellIDs = {}
local spellBookSearched = 0
local players
local previewStepsRaid = {40, 20, 10, 5}
local previewStepRaid = 0
local previewStepsParty = {5}
local previewStepParty = 0

local function CreateGridFrame(index, isParty, parent, OnEvent, OnUpdate, profile)
    local frame, unit = nil, ""
    if isParty then
        frame = CreateFrame("Button", "GwCompactPartyFrame" .. index, parent, "GwRaidFrame")
        unit = index == 1 and "player" or "party" .. index - 1
    else
        frame = CreateFrame("Button", "GwCompactRaidFrame" .. index, parent, "GwRaidFrame")
        unit = "raid" .. index
    end
    frame:SetParent(parent)

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

    frame.unit = unit
    frame.guid = UnitGUID(frame.unit)
    frame.ready = -1
    frame.targetmarker = GetRaidTargetIndex(frame.unit)
    frame.index = index

    frame.healthbar.animationName = frame:GetName() .. "animation"
    frame.healthbar.animationValue = 0

    frame.manabar.animationName = frame:GetName() .. "manabaranimation"
    frame.manabar.animationValue = 0

    frame:SetAttribute("unit", frame.unit)
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")

    AddToClique(frame)

    if isParty then
        RegisterStateDriver(frame, "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format(frame.unit))
    else
        RegisterUnitWatch(frame)
    end
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
            GameTooltip:SetUnit(frame.unit)
            GameTooltip:Show()
            self.targetHighlight:SetVertexColor(1, 1, 1, 1)
        end
    )

    frame:SetScript("OnEvent", OnEvent)
    frame:SetScript("OnUpdate", OnUpdate)

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

    frame:RegisterUnitEvent("UNIT_HEALTH", frame.unit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", frame.unit)
    frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", frame.unit)
    frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", frame.unit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", frame.unit)
    frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", frame.unit)
    frame:RegisterUnitEvent("UNIT_PHASE", frame.unit)
    frame:RegisterUnitEvent("UNIT_AURA", frame.unit)
    frame:RegisterUnitEvent("UNIT_LEVEL", frame.unit)
    frame:RegisterUnitEvent("UNIT_TARGET", frame.unit)
    frame:RegisterUnitEvent("UNIT_NAME_UPDATE", frame.unit)
    frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", frame.unit)

    OnEvent(frame, "load")

    if GetSetting("RAID_POWER_BARS" .. (profile == "PARTY" and "_PARTY" or "")) then
        frame.predictionbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 5)
        frame.manabar:Show()
    end
end
GW.CreateGridFrame = CreateGridFrame

local function GridUpdateRaidMarkers(self, profile)
    local i = GetRaidTargetIndex(self.unit)

    if i then
        self.targetmarker = i
        self.classicon:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_" .. i)
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
        self.classicon:SetShown(true)
    else
        self.targetmarker = nil
        if not GetSetting("RAID_CLASS_COLOR" .. (profile == "PARTY" and "_PARTY" or "")) then
            self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
            GW.SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))
        else
            self.classicon:SetTexture(nil)
        end
    end
end
GW.GridUpdateRaidMarkers = GridUpdateRaidMarkers

local function GridSetAbsorbAmount(self)
    local healthMax = UnitHealthMax(self.unit)
    local absorb = UnitGetTotalAbsorbs(self.unit)
    local absorbPrecentage = 0

    if (absorb ~= nil or absorb == 0) and healthMax ~= 0 then
        absorbPrecentage = math.min(absorb / healthMax, 1)
    end
    self.absorbbar:SetValue(absorbPrecentage)
end
GW.GridSetAbsorbAmount = GridSetAbsorbAmount

local function GridSetHealPrediction(self,predictionPrecentage)
    self.predictionbar:SetValue(predictionPrecentage)
end
GW.GridSetHealPrediction = GridSetHealPrediction


local function setHealthValue(self, healthCur, healthMax, healthPrec, profile)
    local healthsetting = GetSetting("RAID_UNIT_HEALTH" .. (profile == "PARTY" and "_PARTY" or ""))
    local healthstring = ""

    if healthsetting == "NONE" then
        self.healthstring:Hide()
        return
    end

    if healthsetting == "PREC" then
        self.healthstring:SetText(RoundDec(healthPrec * 100,0) .. "%")
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

local function GridSetHealth(self, profile)
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
    GW.GridSetHealPrediction(self,predictionPrecentage)
    setHealthValue(self, health, healthMax, healthPrec, profile)
    GW.Bar(self.healthbar, healthPrec)
end
GW.GridSetHealth = GridSetHealth

local function GridSetPredictionAmount(self, profile)
    local prediction = UnitGetIncomingHeals(self.unit) or 0

    self.healPredictionAmount = prediction
    GridSetHealth(self, profile)
end
GW.GridSetPredictionAmount = GridSetPredictionAmount

local function GridSetUnitName(self, profile)
    if not self or not self.unit then
        return
    end

    local flagSetting = GetSetting("RAID_UNIT_FLAGS" .. (profile == "PARTY" and "_PARTY" or ""))
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
GW.GridSetUnitName = GridSetUnitName

local function GridUpdateAwayData(self, profile)
    local classColor = GetSetting("RAID_CLASS_COLOR" .. (profile == "PARTY" and "_PARTY" or ""))
    local readyCheckStatus = GetReadyCheckStatus(self.unit)
    local iconState = 0
    local _, englishClass, classIndex = UnitClass(self.unit)

    self.name:SetTextColor(1, 1, 1)

    if classColor and classIndex and classIndex > 0 then
        local color = GW.GWGetClassColor(englishClass, true)
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
        GW.SetClassIcon(self.classicon, classIndex)
    end

    if self.targetmarker and not readyCheckStatus and GetSetting("RAID_UNIT_MARKERS"  .. (profile == "PARTY" and "_PARTY" or "")) then
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
        GW.GridUpdateRaidMarkers(self)
    end

    if iconState == 2 then
        if classColor then
            self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
        end
        GW.SetDeadIcon(self.classicon)
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

    -- manabar
    local showRessourbar = GetSetting("RAID_POWER_BARS" .. (profile == "PARTY" and "_PARTY" or ""))

    self.predictionbar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, (showRessourbar and 5 or 0))
    self.manabar:SetShown(showRessourbar)
end
GW.GridUpdateAwayData = GridUpdateAwayData


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

local function GridShowDebuffIcon(parent, i, btnIndex, x, y, filter, icon, count, debuffType, duration, expires, isImportant, isDispellable, profile)
    local size = 16
    if isImportant or isDispellable then
        if isImportant and isDispellable then
            size = size * GW.GetDebuffScaleBasedOnPrio()
        elseif isImportant then
            size = size * tonumber(GW.GetSetting("RAIDDEBUFFS_Scale"))
        elseif isDispellable then
            size = size * tonumber(GW.GetSetting("DISPELL_DEBUFFS_Scale"))
        end
    end

    local marginX, marginY = x * (size + 2), y * (size + 2)
    local frame = _G["Gw" .. parent:GetName() .. "DeBuffItemFrame" .. btnIndex]

    if not frame then
        frame = CreateFrame("Button", "Gw" .. parent:GetName() .. "DeBuffItemFrame" .. btnIndex, parent, "GwDeBuffIcon")
        frame:SetParent(parent)
        frame:SetFrameStrata("MEDIUM")

        frame.debuffIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
        frame.debuffIcon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)

        frame:SetScript("OnEnter", onDebuffEnter)
        frame:SetScript("OnLeave", GameTooltip_Hide)
        frame:SetScript("OnMouseUp", onDebuffMouseUp)
        frame:RegisterForClicks("RightButtonUp")

        frame.tooltipSetting = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT" .. (profile == "PARTY" and "_PARTY" or ""))
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
    frame:ClearAllPoints()
    frame:SetPoint("BOTTOMLEFT", parent.healthbar, "BOTTOMLEFT", marginX + 3, marginY + 3)
    frame:SetSize(size, size)

    frame.expires = expires
    frame.duration = duration
    frame.cooldown:SetCooldown(0, 0)
    frame.index = i
    frame.filter = filter

    frame.cooldown.duration:SetText(expires and TimeCount(expires - GetTime()) or 0)
    frame.debuffIcon.stacks:SetText((count or 1) > 1 and count or "")
    frame.debuffIcon.stacks:SetFont(UNIT_NAME_FONT, ((count or 1) > 9 and 8 or 14))

    frame:Show()

    btnIndex, x, marginX = btnIndex + 1, x + 1, marginX + size + 2
    if marginX > parent:GetWidth() / 2 then
        x, y, marginX = 0, y + 1, 0
    end

    return btnIndex, x, y, marginX
end

local function GridUpdateDebuffs(self, profile)
    local btnIndex, x, y = 1, 0, 0
    local filter = "HARMFUL"
    local showDebuffs = GetSetting("RAID_SHOW_DEBUFFS" .. (profile == "PARTY" and "_PARTY" or ""))
    local onlyDispellableDebuffs = GetSetting("RAID_ONLY_DISPELL_DEBUFFS" .. (profile == "PARTY" and "_PARTY" or ""))
    local showImportendInstanceDebuffs = GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF" .. (profile == "PARTY" and "_PARTY" or ""))
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
                btnIndex, x, y = GridShowDebuffIcon(self, i, btnIndex, x, y, filter, icon, count, debuffType, duration, expires, isImportant, isDispellable)
            end

            aurasDone = not debuffName or y > 0
        end
    until framesDone and aurasDone
end

local function GridShowBuffIcon(parent, i, btnIndex, x, y, icon, isMissing, profile)
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

        frame.tooltipSetting = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT" .. (profile == "PARTY" and "_PARTY" or ""))
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

local function GridUpdateBuffs(self, profile)
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
                    i, btnIndex, x, y = i + 1, GridShowBuffIcon(self, spellIDs[mName], btnIndex, x, y, icon, true, profile)
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
                        btnIndex, x, y = GridShowBuffIcon(self, i, btnIndex, x, y, icon, nil, profile)
                    end
                end
            else
                aurasDone = true
            end
        end
    until framesDone and aurasDone
end

local function GridUpdateAuras(self, profile)
    GridUpdateBuffs(self, profile)
    GridUpdateDebuffs(self, profile)
end
GW.GridUpdateAuras = GridUpdateAuras

local function GridHighlightTargetFrame(self)
    local guidTarget = UnitGUID("target")
    self.guid = UnitGUID(self.unit)

    if self.guid == guidTarget then
        self.targetHighlight:SetVertexColor(1, 1, 1, 1)
    else
        self.targetHighlight:SetVertexColor(0, 0, 0, 1)
    end
end
GW.GridHighlightTargetFrame = GridHighlightTargetFrame

local function GridUpdatePower(self)
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
GW.GridUpdatePower = GridUpdatePower

local function GridUpdateFrameData(self, index, profile)
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
    GW.Bar(self.healthbar, healthPrec)
    self.absorbbar:SetValue(absorbPrecentage)
    self.predictionbar:SetValue(predictionPrecentage)

    local _, powerToken = UnitPowerType(self.unit)
    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.manabar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end

    GW.GridSetUnitName(self, profile)
    GW.GridUpdateAwayData(self, profile)
    GW.GridUpdateAuras(self, profile)
end
GW.GridUpdateFrameData = GridUpdateFrameData

local function GridToggleFramesPreviewRaid(_, _, moveHudMode, hudMoving)
    previewStepRaid = max((previewStepRaid + 1) % (#previewStepsRaid + 1), hudMoving and 1 or 0)

    if previewStepRaid == 0 or moveHudMode then
        for i = 1, MAX_RAID_MEMBERS do
            if _G["GwCompactRaidFrame" .. i] then
                _G["GwCompactRaidFrame" .. i].unit = "raid" .. i
                _G["GwCompactRaidFrame" .. i].guid = UnitGUID("raid" .. i)
                _G["GwCompactRaidFrame" .. i]:SetAttribute("unit", "raid" .. i)
                GW.GridOnEvent(_G["GwCompactRaidFrame" .. i], "load")
            end
        end
    else
        for i = 1, MAX_RAID_MEMBERS do
            if _G["GwCompactRaidFrame" .. i] then
                if i <= (previewStepRaid == 0 and 40 or previewStepsRaid[previewStepRaid]) then
                    _G["GwCompactRaidFrame" .. i].unit = "player"
                    _G["GwCompactRaidFrame" .. i].guid = UnitGUID("player")
                    _G["GwCompactRaidFrame" .. i]:SetAttribute("unit", "player")
                else
                    _G["GwCompactRaidFrame" .. i].unit = "raid" .. i
                    _G["GwCompactRaidFrame" .. i].guid = UnitGUID("raid" .. i)
                    _G["GwCompactRaidFrame" .. i]:SetAttribute("unit", "raid" .. i)
                end
                GW.GridOnEvent(_G["GwCompactRaidFrame" .. i], "load")
            end
        end
        GW.GridUpdateRaidFramesPosition(nil, true)
    end
    GwSettingsRaidPanel.buttonRaidPreview:SetText(previewStepRaid == 0 and "-" or previewStepsRaid[previewStepRaid])
end
GW.GridToggleFramesPreviewRaid = GridToggleFramesPreviewRaid

local function GridToggleFramesPreviewParty(_, _, moveHudMode, hudMoving)
    previewStepParty = max((previewStepParty + 1) % (#previewStepsParty + 1), hudMoving and 1 or 0)

    if previewStepParty == 0 or moveHudMode then
        for i = 1, 5 do
            if _G["GwCompactPartyFrame" .. i] then
                _G["GwCompactPartyFrame" .. i].unit = i == 1 and "player" or "party" .. i - 1
                _G["GwCompactPartyFrame" .. i].guid = UnitGUID(i == 1 and "player" or "party" .. i - 1)
                _G["GwCompactPartyFrame" .. i]:SetAttribute("unit", i == 1 and "player" or "party" .. i - 1)
                RegisterStateDriver(_G["GwCompactPartyFrame" .. i], "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format(_G["GwCompactPartyFrame" .. i].unit))
                GW.GridOnEvent(_G["GwCompactPartyFrame" .. i], "load")
            end
        end
    else
        for i = 1, 5 do
            if _G["GwCompactPartyFrame" .. i] then
                _G["GwCompactPartyFrame" .. i].unit = "player"
                _G["GwCompactPartyFrame" .. i].guid = UnitGUID("player")
                _G["GwCompactPartyFrame" .. i]:SetAttribute("unit", "player")
                RegisterStateDriver(_G["GwCompactPartyFrame" .. i], "visibility", ("show"):format(_G["GwCompactPartyFrame" .. i].unit))
                GW.GridOnEvent(_G["GwCompactPartyFrame" .. i], "load")
            end
        end
        GW.GridUpdateRaidFramesPosition("PARTY", true)
    end
    GwSettingsRaidPanel.buttonRaidPreview:SetText(previewStepParty == 0 and "-" or previewStepsParty[previewStepParty])
end
GW.GridToggleFramesPreviewParty = GridToggleFramesPreviewParty

local function GridSortByRole()
    local sorted = {}
    local roleIndex = {"TANK", "HEALER", "DAMAGER", "NONE"}
    local unitString = IsInRaid() and "Raid" or "Party"

    for _, v in pairs(roleIndex) do
        if unitString == "Party" and UnitGroupRolesAssigned("player") == v then
            tinsert(sorted, "PartyFrame1")
        end

        for i = 1, MAX_RAID_MEMBERS do
            if UnitExists(unitString .. i) and UnitGroupRolesAssigned(unitString .. i) == v then
                tinsert(sorted, unitString .. "Frame" .. (unitString == "Party" and i + 1 or i))
            end
        end
    end
    return sorted
end

---- CALC Functions
local function GridContainerUpdateAnchor(profile)
    local container = (profile == "PARTY" and GwRaidFramePartyContainer or GwRaidFrameContainer)

    container.gwMover:GetScript("OnDragStop")(container.gwMover)
end
GW.GridContainerUpdateAnchor = GridContainerUpdateAnchor

local function GridPositionRaidFrame(frame, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
    if not frame then return end

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
        frame:SetPoint(a, frame:GetParent(), a, x, y)
        frame:SetSize(w, h)
    end

    if frame.healthbar then
        frame.healthbar.spark:SetHeight(frame.healthbar:GetHeight())
    end
end
GW.GridPositionRaidFrame = GridPositionRaidFrame

local function GridGetRaidFramesMeasures(players, profile)
    -- Get settings
    local grow = GetSetting("RAID_GROW" .. (profile == "PARTY" and "_PARTY" or ""))
    local w = GetSetting("RAID_WIDTH" .. (profile == "PARTY" and "_PARTY" or ""))
    local h = GetSetting("RAID_HEIGHT" .. (profile == "PARTY" and "_PARTY" or ""))
    local cW = GetSetting("RAID_CONT_WIDTH" .. (profile == "PARTY" and "_PARTY" or ""))
    local cH = GetSetting("RAID_CONT_HEIGHT" .. (profile == "PARTY" and "_PARTY" or ""))
    local per = ceil(GetSetting("RAID_UNITS_PER_COLUMN" .. (profile == "PARTY" and "_PARTY" or "")))
    local byRole = GetSetting("RAID_SORT_BY_ROLE" .. (profile == "PARTY" and "_PARTY" or ""))
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
GW.GridGetRaidFramesMeasures = GridGetRaidFramesMeasures

local function GridUpdateRaidFramesPosition(profile, force)
    if profile == "PARTY"  then
        players = previewStepParty == 0 and 5 or previewStepsParty[previewStepParty]

        -- Get directions, rows, cols and sizing
        local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GW.GridGetRaidFramesMeasures(players, profile)
        local isV = grow1 == "DOWN" or grow1 == "UP"

        -- Update size
        GwRaidFramePartyContainer.gwMover:SetSize(isV and size2 or size1, isV and size1 or size2)

        -- Update unit frames
        if IsInGroup() or force then
            for i = 1, 5 do
                GridPositionRaidFrame(_G["GwCompactPartyFrame" .. i], i, grow1, grow2, cells1, sizePer1, sizePer2, m)
                if i > players then _G["GwCompactPartyFrame" .. i]:Hide() else _G["GwCompactPartyFrame" .. i]:Show() end
            end
        end
    else
        players = previewStepRaid == 0 and 40 or previewStepsRaid[previewStepRaid]

        -- Get directions, rows, cols and sizing
        local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GW.GridGetRaidFramesMeasures(players, profile)
        local isV = grow1 == "DOWN" or grow1 == "UP"

        -- Update size
        GwRaidFrameContainer.gwMover:SetSize(isV and size2 or size1, isV and size1 or size2)

        -- Update unit frames
        for i = 1, MAX_RAID_MEMBERS do
            GridPositionRaidFrame(_G["GwCompactRaidFrame" .. i], i, grow1, grow2, cells1, sizePer1, sizePer2, m)
            if i > players then _G["GwCompactRaidFrame" .. i]:Hide() else _G["GwCompactRaidFrame" .. i]:Show() end
        end
    end
end
GW.GridUpdateRaidFramesPosition = GridUpdateRaidFramesPosition


local grpPos, noGrp = {}, {}
local function GridUpdateRaidFramesLayout(profile)
    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GridGetRaidFramesMeasures(nil, profile)
    local isV = grow1 == "DOWN" or grow1 == "UP"
    local container = profile == "PARTY" and GwRaidFramePartyContainer or GwRaidFrameContainer

    if not InCombatLockdown() then
        container:SetSize(isV and size2 or size1, isV and size1 or size2)
    end

    local unitString = IsInRaid() and "Raid" or "Party"
    local sorted = (unitString == "Party" or GetSetting("RAID_SORT_BY_ROLE" .. (profile == "PARTY" and "_PARTY" or ""))) and GridSortByRole() or {}

    -- Position by role
    for i, v in ipairs(sorted) do
        GridPositionRaidFrame(_G["GwCompact" .. v], i, grow1, grow2, cells1, sizePer1, sizePer2, m)
    end

    wipe(grpPos) wipe(noGrp)

    -- Position by group
    for i = 1, profile == "PARTY" and 5 or 40 do
        if not tContains(sorted, unitString .. i) then
            if i <= 5 and profile == "PARTY" then -- <= ??
                GridPositionRaidFrame(_G["GwCompactPartyFrame" .. i], i, grow1, grow2, cells1, sizePer1, sizePer2, m)
            end

            if not profile == "PARTY" then
                local name, _, grp = GetRaidRosterInfo(i)
                if name or grp > 1 then
                    grpPos[grp] = (grpPos[grp] or 0) + 1
                    GridPositionRaidFrame(_G["GwCompactRaidFrame" .. i], (grp - 1) * MEMBERS_PER_RAID_GROUP + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
                else
                    tinsert(noGrp, i)
                end
            end
        end
    end

    -- Find spots for units with missing group info
    if not profile == "PARTY" then
        for _,i in ipairs(noGrp) do
            for grp = 1, NUM_RAID_GROUPS do
                if (grpPos[grp] or 0) < MEMBERS_PER_RAID_GROUP then
                    grpPos[grp] = (grpPos[grp] or 0) + 1
                    GridPositionRaidFrame(_G["GwCompactRaidFrame" .. i], (grp - 1) * MEMBERS_PER_RAID_GROUP + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
                    break
                end
            end
        end
    end
end
GW.GridUpdateRaidFramesLayout = GridUpdateRaidFramesLayout