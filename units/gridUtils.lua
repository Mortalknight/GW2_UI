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

local settings = {
    raidClassColor = {},
    raidUnitHealthString = {},
    raidUnitFlag = {},
    raidUnitMarkers = {},
    raidUnitPowerBar = {},
    raidAuraTooltipInCombat = {},
    raidShowDebuffs = {},
    raidShowOnlyDispelDebuffs = {},
    raidShowImportendInstanceDebuffs = {},
    raidIndicators = {}
}

local function UpdateSettings()
    settings.fontEnabled = GetSetting("FONTS_ENABLED")
    settings.aurasIgnored = GetSetting("AURAS_IGNORED")
    settings.aurasMissing = GetSetting("AURAS_MISSING")
    settings.raidDebuffScale = GetSetting("RAIDDEBUFFS_Scale")
    settings.raidDispelDebuffScale = GetSetting("DISPELL_DEBUFFS_Scale")
    settings.raidIndicatorIcon = GetSetting("INDICATORS_ICON")
    settings.raidIndicatorTime = GetSetting("INDICATORS_TIME")

    settings.raidClassColor.PARTY = GetSetting("RAID_CLASS_COLOR_PARTY")
    settings.raidClassColor.RAID_PET = GetSetting("RAID_CLASS_COLOR_PET")
    settings.raidClassColor.RAID = GetSetting("RAID_CLASS_COLOR")

    settings.raidUnitHealthString.PARTY = GetSetting("RAID_UNIT_HEALTH_PARTY")
    settings.raidUnitHealthString.RAID_PET = GetSetting("RAID_UNIT_HEALTH_PET")
    settings.raidUnitHealthString.RAID = GetSetting("RAID_UNIT_HEALTH")

    settings.raidUnitFlag.PARTY = GetSetting("RAID_UNIT_FLAGS_PARTY")
    settings.raidUnitFlag.RAID_PET = GetSetting("RAID_UNIT_FLAGS_PET")
    settings.raidUnitFlag.RAID = GetSetting("RAID_UNIT_FLAGS")

    settings.raidUnitMarkers.PARTY = GetSetting("RAID_UNIT_MARKERS_PARTY")
    settings.raidUnitMarkers.RAID_PET = GetSetting("RAID_UNIT_MARKERS_PET")
    settings.raidUnitMarkers.RAID = GetSetting("RAID_UNIT_MARKERS")

    settings.raidUnitPowerBar.PARTY = GetSetting("RAID_POWER_BARS_PARTY")
    settings.raidUnitPowerBar.RAID_PET = GetSetting("RAID_POWER_BARS_PET")
    settings.raidUnitPowerBar.RAID = GetSetting("RAID_POWER_BARS")

    settings.raidAuraTooltipInCombat.PARTY = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT_PARTY")
    settings.raidAuraTooltipInCombat.RAID_PET = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT_PET")
    settings.raidAuraTooltipInCombat.RAID = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT")

    settings.raidShowDebuffs.PARTY = GetSetting("RAID_SHOW_DEBUFFS_PARTY")
    settings.raidShowDebuffs.RAID_PET = GetSetting("RAID_SHOW_DEBUFFS_PET")
    settings.raidShowDebuffs.RAID = GetSetting("RAID_SHOW_DEBUFFS")

    settings.raidShowOnlyDispelDebuffs.PARTY = GetSetting("RAID_ONLY_DISPELL_DEBUFFS_PARTY")
    settings.raidShowOnlyDispelDebuffs.RAID_PET = GetSetting("RAID_ONLY_DISPELL_DEBUFFS_PET")
    settings.raidShowOnlyDispelDebuffs.RAID = GetSetting("RAID_ONLY_DISPELL_DEBUFFS")

    settings.raidShowImportendInstanceDebuffs.PARTY = GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PARTY")
    settings.raidShowImportendInstanceDebuffs.RAID_PET = GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PET")
    settings.raidShowImportendInstanceDebuffs.RAID = GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF")

    for _, pos in ipairs(INDICATORS) do
        settings.raidIndicators[pos] = GetSetting("INDICATOR_" .. pos, true)
    end

    missing = FillTable(missing, true, strsplit(",", (settings.aurasMissing:trim():gsub("%s*,%s*", ","))))
    ignored = FillTable(ignored, true, strsplit(",", (settings.aurasIgnored:trim():gsub("%s*,%s*", ","))))
end
GW.UpdateGridSettings = UpdateSettings

local function CreateGridFrame(index, parent, OnEvent, OnUpdate, profile)
    local frame, unit = nil, ""
    if profile == "PARTY" then
        frame = CreateFrame("Button", "GwCompactPartyFrame" .. index, parent, "GwRaidFrame")
        unit = index == 1 and "player" or "party" .. index - 1
    elseif profile == "RAID" then
        frame = CreateFrame("Button", "GwCompactRaidFrame" .. index, parent, "GwRaidFrame")
        unit = "raid" .. index
    elseif profile == "RAID_PET" then
        frame = CreateFrame("Button", "GwCompactRaidPetFrame" .. index, parent, "GwRaidFrame")
        unit = "raidpet" .. index
    end
    frame.parent = parent

    frame.name = _G[frame:GetName() .. "Data"].name
    frame.healthstring = _G[frame:GetName() .. "Data"].healthstring
    frame.classicon = _G[frame:GetName() .. "Data"].classicon
    frame.healthbar = frame.predictionbar.healthbar
    frame.absorbbar = frame.healthbar.absorbbar
    frame.aggroborder = frame.absorbbar.aggroborder
    frame.nameNotLoaded = false

    if settings.fontEnabled then -- for any reason blizzard is not supporting UTF8 if we set this font
        frame.name:SetFont(UNIT_NAME_FONT, 12)
    end
    frame.name:SetShadowOffset(-1, -1)
    frame.name:SetShadowColor(0, 0, 0, 1)

    frame.healthstring:SetFont(UNIT_NAME_FONT, 11)
    frame.healthstring:SetShadowOffset(-1, -1)
    frame.healthstring:SetShadowColor(0, 0, 0, 1)

    hooksecurefunc(frame.healthbar, "SetStatusBarColor",
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

    if profile == "PARTY" then
        RegisterStateDriver(frame, "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format(frame.unit))
    elseif profile == "RAID" or profile == "RAID_PET" then
        RegisterStateDriver(frame, "visibility", ("[group:raid,@%s,exists] show; [group:party] hide; hide"):format(frame.unit))
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

    if profile == "RAID_PET" then
        frame:RegisterUnitEvent("UNIT_PET", "raid" .. index)
    end

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

    if settings.raidUnitPowerBar[profile] then
        frame.predictionbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 5)
        frame.manabar:Show()
    end

    if profile == "RAID_PET" then
        frame.classicon:SetTexture(nil)
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
        if settings.raidClassColor[profile] then
            self.classicon:SetTexture(nil)
        else
            self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
            GW.SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))
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
    local healthstring = ""

    if settings.raidUnitHealthString[profile] == "NONE" then
        self.healthstring:Hide()
        return
    end

    if settings.raidUnitHealthString[profile] == "PREC" then
        self.healthstring:SetText(RoundDec(healthPrec * 100,0) .. "%")
    elseif settings.raidUnitHealthString[profile] == "HEALTH" then
        self.healthstring:SetText(CommaValue(healthCur))
    elseif settings.raidUnitHealthString[profile] == "LOSTHEALTH" then
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

    local role = UnitGroupRolesAssigned(self.unit)
    local nameString = UnitName(self.unit)
    local realmflag = ""

    if not nameString or nameString == UNKNOWNOBJECT then
        self.nameNotLoaded = false
    else
        self.nameNotLoaded = true
    end

    if settings.raidUnitFlag[profile] ~= "NONE" then
        local realmLocal = select(5, LRI:GetRealmInfoByUnit(self.unit))

        if realmLocal then
            realmflag = settings.raidUnitFlag[profile] == "DIFFERENT" and GW.mylocal ~= realmLocal and REALM_FLAGS[realmLocal] or settings.raidUnitFlag[profile] == "ALL" and REALM_FLAGS[realmLocal] or ""
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
        local _, _, _, _, _, _, _, _, _, role2 = GetRaidRosterInfo(self.index)
        if role2 == "MAINTANK" then
            nameString = "|TInterface/AddOns/GW2_UI/textures/party/icon-maintank:15:15:0:-2|t " .. nameString
        elseif role2 == "MAINASSIST" then
            nameString = "|TInterface/AddOns/GW2_UI/textures/party/icon-mainassist:15:15:0:-1|t " .. nameString
        end
    end

    self.name:SetText(nameString .. " " .. realmflag)
    self.name:SetWidth(self:GetWidth() - 4)
end
GW.GridSetUnitName = GridSetUnitName

local function GridUpdateAwayData(self, profile, incomingSummonOrResurrectionCheck, checkReadyCheck)
    local readyCheckStatus = checkReadyCheck and GetReadyCheckStatus(self.unit) or false
    local iconState = 0
    local _, englishClass, classIndex = UnitClass(self.unit)

    self.name:SetTextColor(1, 1, 1)

    if settings.raidClassColor[profile] and englishClass then
        local color = GW.GWGetClassColor(englishClass, true)

        self.healthbar:SetStatusBarColor(color.r, color.g, color.b, color.a)
        self.classicon:SetShown(false)
    end
    if not settings.raidClassColor[profile] and not readyCheckStatus then
        iconState = 1
    end
    if UnitIsDeadOrGhost(self.unit) then
        iconState = 2
    end
    if incomingSummonOrResurrectionCheck and UnitHasIncomingResurrection(self.unit) then
        iconState = 3
    end
    if incomingSummonOrResurrectionCheck and C_IncomingSummon.HasIncomingSummon(self.unit) then
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

    if self.targetmarker and not readyCheckStatus and settings.raidUnitMarkers[profile] then
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
        GW.GridUpdateRaidMarkers(self)
    end

    if iconState == 2 then
        if settings.raidClassColor[profile] then
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
    self.predictionbar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, (settings.raidUnitPowerBar[profile] and 5 or 0))
    self.manabar:SetShown(settings.raidUnitPowerBar[profile])
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
            local s = settings.aurasIgnored or ""
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
                local s = (settings.aurasMissing or ""):gsub("%s*,?%s*" .. name .. "%s*,?%s*", ", "):trim(", ")
                SetSetting("AURAS_MISSING", s)
            end
        else
            local name =  UnitBuff(self:GetParent().unit, self.index)
            if name then
                local s = settings.aurasIgnored or ""
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
            size = size * tonumber(settings.raidDebuffScale)
        elseif isDispellable then
            size = size * tonumber(settings.raidDispelDebuffScale)
        end
    end

    local marginX, marginY = x * (size + 2), y * (size + 2)
    local frame = _G["Gw" .. parent:GetName() .. "DeBuffItemFrame" .. btnIndex]

    if not frame then
        frame = CreateFrame("Button", "Gw" .. parent:GetName() .. "DeBuffItemFrame" .. btnIndex, parent, "GwDeBuffIcon")
        frame:SetParent(parent)
        frame:SetFrameStrata("MEDIUM")

        frame.throt = -1

        frame.debuffIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
        frame.debuffIcon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)

        frame:SetScript("OnEnter", onDebuffEnter)
        frame:SetScript("OnLeave", GameTooltip_Hide)
        frame:SetScript("OnMouseUp", onDebuffMouseUp)
        frame:RegisterForClicks("RightButtonUp")

        if settings.raidAuraTooltipInCombat[profile] == "NEVER" then
            frame:EnableMouse(false)
        elseif settings.raidAuraTooltipInCombat[profile] == "ALWAYS" then
            frame:EnableMouse(true)
        elseif settings.raidAuraTooltipInCombat[profile] == "OUT_COMBAT" then
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

    -- readd OnUpdate handler
    frame:SetScript("OnUpdate", function(self, elapsed)
        if self.throt < 0 and self.expires ~= nil and self:IsShown() then
            self.throt = 0.2
            if GameTooltip:IsOwned(self) then
                onDebuffEnter(self)
            end
        else
            self.throt = self.throt - elapsed
        end
    end)

    return btnIndex, x, y, marginX
end

local function GridUpdateDebuffs(self, profile)
    local btnIndex, x, y = 1, 0, 0
    local shouldDisplay, isImportant, isDispellable

    for i = 1, 40 do
        local debuffName, icon, count, debuffType, duration, expires, caster, _, _, spellId = UnitDebuff(self.unit, i, "HARMFUL")

        if debuffName and y <= 0 then
            shouldDisplay = false
            isDispellable = debuffType and GW.Libs.Dispel:IsDispellableByMe(debuffType) or false
            isImportant = (settings.raidShowImportendInstanceDebuffs[profile] and GW.ImportendRaidDebuff[spellId]) or false

            if settings.raidShowDebuffs[profile] then
                if settings.raidShowOnlyDispelDebuffs[profile] then
                    if isDispellable then
                        shouldDisplay = debuffName and not (ignored[debuffName] or spellId == 6788 and caster and not UnitIsUnit(caster, "player")) -- Don't show "Weakened Soul" from other players
                    end
                else
                    shouldDisplay = debuffName and not (ignored[debuffName] or spellId == 6788 and caster and not UnitIsUnit(caster, "player")) -- Don't show "Weakened Soul" from other players
                end
            end

            if settings.raidShowImportendInstanceDebuffs[profile] and not shouldDisplay then
                shouldDisplay = isImportant
            end

            if shouldDisplay then
                btnIndex, x, y = GridShowDebuffIcon(self, i, btnIndex, x, y, "HARMFUL", icon, count, debuffType, duration, expires, isImportant, isDispellable, profile)
            end
        else
            break
        end
    end

    for i = btnIndex, 40 do
        local frame = _G["Gw" .. self:GetName() .. "DeBuffItemFrame" .. i]

        if frame then
            frame:Hide()
            frame:SetScript("OnUpdate", nil)
        end
    end
end

local function GridShowBuffIcon(parent, i, btnIndex, x, y, icon, isMissing, expires, profile)
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

        frame.throt = -1

        frame.buffDuration:SetFont(UNIT_NAME_FONT, 11)
        frame.buffDuration:SetTextColor(1, 1, 1)
        frame.buffStacks:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
        frame.buffStacks:SetTextColor(1, 1, 1)

        frame:SetScript("OnEnter", onBuffEnter)
        frame:SetScript("OnLeave", GameTooltip_Hide)
        frame:SetScript("OnMouseUp", onBuffMouseUp)
        frame:RegisterForClicks("RightButtonUp")

        if settings.raidAuraTooltipInCombat[profile] == "NEVER" then
            frame:EnableMouse(false)
        elseif settings.raidAuraTooltipInCombat[profile] == "ALWAYS" then
            frame:EnableMouse(true)
        elseif settings.raidAuraTooltipInCombat[profile] == "OUT_COMBAT" then
            frame:EnableMouse(true)
        end
    end

    -- readding onUpdate handler
    frame:SetScript("OnUpdate", function(self, elapsed)
        if self.throt < 0 and self.expires ~= nil and self:IsShown() then
            self.throt = 0.2
            if GameTooltip:IsOwned(self) then
                onBuffEnter(self)
            end
        else
            self.throt = self.throt - elapsed
        end
    end)

    frame.index = i
    frame.isMissing = isMissing
    frame.expires = expires

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
    local shouldDisplay, hasCustom, alwaysShowMine, showForMySpec, indicator

    -- hide all indicators
    for _, pos in pairs(INDICATORS) do
        self["indicator" .. pos]:Hide()
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
                    i, btnIndex, x, y = i + 1, GridShowBuffIcon(self, spellIDs[mName], btnIndex, x, y, icon, true, nil, profile)
                end
            end
        end
    end

    -- current buffs
    for i = 1, 40 do
        local name, icon, count, _, duration, expires, caster, _, _, spellID, canApplyAura, _, castByPlayer = UnitBuff(self.unit, i)

        if name then
            hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

            if hasCustom then
                shouldDisplay = showForMySpec or (alwaysShowMine and (caster == "player" or caster == "pet" or caster == "vehicle"))
            else
                shouldDisplay = (caster == "player" or caster == "pet" or caster == "vehicle") and (canApplyAura or castByPlayer) and not SpellIsSelfBuff(spellID)
            end

            if shouldDisplay then
                -- indicators
                indicator = indicators[spellID]
                if indicator then
                    for _, pos in ipairs(INDICATORS) do
                        if settings.raidIndicators[pos] == (indicator[4] or spellID) then
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
                                if settings.raidIndicatorIcon then
                                    frame.icon:SetTexture(icon)
                                else
                                    frame.icon:SetColorTexture(r, g, b)
                                end

                                -- Cooldown
                                if settings.raidIndicatorTime then
                                    frame.cooldown:Show()
                                    frame.cooldown:SetCooldown(expires - duration, duration)
                                else
                                    frame.cooldown:Hide()
                                end

                                -- do not show that buff as normal buff
                                shouldDisplay = false
                            end

                            frame:Show()
                        end
                    end
                end

                --set new buff
                if shouldDisplay and not (ignored[name] or missing[name] ~= nil) then
                    btnIndex, x, y = GridShowBuffIcon(self, i, btnIndex, x, y, icon, nil, expires, profile)
                end
            end
        else
            break
        end
    end

    for i = btnIndex, 40 do
        local frame = _G["Gw" .. self:GetName() .. "BuffItemFrame" .. i]

        if frame then
            frame:Hide()
            frame:SetScript("OnUpdate", nil)
        end
    end
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

---- Settings Function Functions
local function GridUpdateFramesLayout(profile)
    if profile == "RAID" then
        GW.GridRaidUpdateFramesLayout()
    elseif profile == "PARTY" then
        GW.GridPartyUpdateFramesLayout()
    elseif profile == "RAID_PET" then
        GW.GridRaidPetUpdateFramesLayout()
    end
end
GW.GridUpdateFramesLayout = GridUpdateFramesLayout

local function GridUpdateFramesPosition(profile)
    if profile == "RAID" then
        GW.GridRaidUpdateFramesPosition()
    elseif profile == "PARTY" then
        GW.GridPartyUpdateFramesPosition()
    elseif profile == "RAID_PET" then
        GW.GridRaidPetUpdateFramesPosition()
    end
end
GW.GridUpdateFramesPosition = GridUpdateFramesPosition

local function GridContainerUpdateAnchor(profile)
    if profile == "RAID" then
        GwRaidFrameContainer.gwMover:GetScript("OnDragStop")(GwRaidFrameContainer.gwMover)
    elseif profile == "PARTY" then
        GwRaidFramePartyContainer.gwMover:GetScript("OnDragStop")(GwRaidFramePartyContainer.gwMover)
    elseif profile == "RAID_PET" then
        GwRaidFramePetContainer.gwMover:GetScript("OnDragStop")(GwRaidFramePetContainer.gwMover)
    end
end
GW.GridContainerUpdateAnchor = GridContainerUpdateAnchor