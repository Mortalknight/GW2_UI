local _, GW = ...
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local CountTable = GW.CountTable
local SplitString = GW.SplitString
local PowerBarColorCustom = GW.PowerBarColorCustom
local DEBUFF_COLOR = GW.DEBUFF_COLOR
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local CLASS_COLORS_RAIDFRAME = GW.CLASS_COLORS_RAIDFRAME
local INDICATORS = GW.INDICATORS
local AURAS_INDICATORS = GW.AURAS_INDICATORS
local TogglePartyRaid = GW.TogglePartyRaid
local RegisterMovableFrame = GW.RegisterMovableFrame
local Bar = GW.Bar
local SetClassIcon = GW.SetClassIcon
local SetDeadIcon = GW.SetDeadIcon
local AddToAnimation = GW.AddToAnimation
local AddToClique = GW.AddToClique
local FillTable = GW.FillTable
local IsIn = GW.IsIn
local TimeCount = GW.TimeCount
local CommaValue = GW.CommaValue
local RoundDec = GW.RoundDec
local REALM_FLAGS = GW.REALM_FLAGS
local LRI = LibStub("LibRealmInfo", true)

local GROUPD_TYPE = "PARTY"
local GW_READY_CHECK_INPROGRESS = false

local previewSteps = {40, 20, 10, 5}
local previewStep = 0
local hudMoving = false
local missing, ignored = {}, {}
local spellBookIndex = {}
local spellBookSearched = 0

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
    self.targetmarker = i
    if self.targetmarker == nil then
        self.classicon:SetTexture(nil)
        return
    end
    self.classicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i)
    if not self.classicon:IsShown() then
        self.classicon:Show()
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

    if b == true then
        if GetSetting("RAID_STYLE_PARTY") == true then
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

    if IsInGroup() and GetSetting("RAID_STYLE_PARTY") == true then
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
    local healthsetting = GetSetting("RAID_UNIT_HEALTH")
    local healthstring = ""

    if healthsetting == "NONE" then
        self.healthstring:Hide()
        return
    end

    if healthsetting == "PREC" then
        self.healthstring:SetText(RoundDec(healthPrec *100,0).. "%")
        self.healthstring:SetJustifyH("LEFT")
    elseif healthsetting == "HEALTH" then
        self.healthstring:SetText(CommaValue(healthCur))
        self.healthstring:SetJustifyH("LEFT")
    elseif healthsetting == "LOSTHEALTH" then
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
    if self == nil or self.unit == nil then
        return
    end

    local nameRoleIcon = {}
    nameRoleIcon["TANK"] = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-tank:12:12:0:0|t "
    nameRoleIcon["HEALER"] = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-healer:12:12:0:0|t "
    nameRoleIcon["DAMAGER"] = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-dps:12:12:0:0|t "
    nameRoleIcon["NONE"] = ""

    local flagSetting = GetSetting("RAID_UNIT_FLAGS")
    local playerLocal = GetLocale()

    local role = UnitGroupRolesAssigned(self.unit)
    local nameString = UnitName(self.unit)
    local realmflag = ""
    
    if not nameString or nameString == UNKNOWNOBJECT then
        self.nameNotLoaded = false
    else
        self.nameNotLoaded = true
    end

    if flagSetting == "DIFFERENT" then
        local realmLocal = select(5, LRI:GetRealmInfoByUnit(self.unit))

        if playerLocal ~= realmLocal then
            realmflag = REALM_FLAGS[realmLocal]
        end
    elseif flagSetting == "ALL" then
        local realmLocal = select(5, LRI:GetRealmInfoByUnit(self.unit))
        if realmLocal ~= nil then
            realmflag = REALM_FLAGS[realmLocal]
        end
    end

    if realmflag == nil then
        realmflag = ""
    end

    if nameRoleIcon[role] ~= nil then
        nameString = nameRoleIcon[role] .. nameString
    end

    if UnitIsGroupLeader(self.unit) then
        nameString = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\icon-groupleader:15:15:0:-3|t" .. nameString
    elseif UnitIsGroupAssistant(self.unit) then
        nameString = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\icon-assist:15:15:0:-3|t" .. nameString
    end

    if self.index then
        local _, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(self.index)
        if role == "MAINTANK" then
            nameString = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\icon-maintank:15:15:0:-3|t" .. nameString
        elseif role == "MAINASSIST" then
            nameString = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\icon-mainassist:15:15:0:-3|t" .. nameString
        end 
    end

    self.name:SetText(nameString .. " " .. realmflag)
    self.name:SetWidth(self:GetWidth()-4)
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

local function updateClassIcon(self, b)
    if b == false then
        self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons")
    else
        self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\readycheck")
    end
end
GW.AddForProfiling("raidframes", "updateClassIcon", updateClassIcon)

local function updateAwayData(self)
    local classColor = GetSetting("RAID_CLASS_COLOR")
    local iconState = 1

    localizedClass, englishClass, classIndex = UnitClass(self.unit)
    self.name:SetTextColor(1, 1, 1)

    if classColor == false and GW_READY_CHECK_INPROGRESS == false then
        self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons")
        iconState = 1
    end

    if classColor == true and classIndex ~= nil and classIndex ~= 0 then
        iconState = 0
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

    if iconState == 0 then
        self.healthbar:SetStatusBarColor(
            CLASS_COLORS_RAIDFRAME[classIndex].r,
            CLASS_COLORS_RAIDFRAME[classIndex].g,
            CLASS_COLORS_RAIDFRAME[classIndex].b,
            1
        )
        if self.classicon:IsShown() then
            self.classicon:Hide()
        end
    end
    if iconState == 1 then
        self.healthbar:SetStatusBarColor(0.207, 0.392, 0.168)
        SetClassIcon(self.classicon, classIndex)
    end

    if self.targetmarker ~= nil and GW_READY_CHECK_INPROGRESS == false and GetSetting("RAID_UNIT_MARKERS") == true then
        self.classicon:SetTexCoord(0, 1, 0, 1)
        updateRaidMarkers(self)
    end

    if iconState == 2 then
        if classColor == true then
            self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons")
        end
        SetDeadIcon(self.classicon)
        self.name:SetTextColor(255, 0, 0)
        self.classicon:Show()
    end

    if iconState == 3 then
        self.classicon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
        self.classicon:SetTexCoord(0, 1, 0, 1)
        self.name:SetTextColor(1, 1, 1)
        self.classicon:Show()
    end
    if iconState == 4 or iconState == 5 or iconState == 6 then
        if iconState == 4 then
            self.classicon:SetAtlas("Raid-Icon-SummonPending")
        elseif iconState == 5 then
            self.classicon:SetAtlas("Raid-Icon-SummonAccepted")
        elseif iconState == 6 then
            self.classicon:SetAtlas("Raid-Icon-SummonDeclined")
        end
        self.classicon:SetTexCoord(0, 1, 0, 1)
        self.classicon:Show()
    end

    if GW_READY_CHECK_INPROGRESS == true then
        if self.ready == -1 then
            self.classicon:SetTexCoord(0, 1, 0, 0.25)
        end
        if self.ready == false then
            self.classicon:SetTexCoord(0, 1, 0.25, 0.50)
        end
        if self.ready == true then
            self.classicon:SetTexCoord(0, 1, 0.50, 0.75)
        end
        if not self.classicon:IsShown() then
            self.classicon:Show()
        end
    end

    if UnitIsConnected(self.unit) ~= true then
        self.classicon:SetTexture("Interface\\CharacterFrame\\Disconnect-Icon")
        self.classicon:SetTexCoord(0, 1, 0, 1)
        self.classicon:Show()
        self.healthbar:SetStatusBarColor(0.3, 0.3, 0.3, 1)
    end

    if UnitIsConnected(self.unit) and ((not UnitInPhase(self.unit) or UnitIsWarModePhased(self.unit)) or not UnitInRange(self.unit)) then
        local r, g, b = self.healthbar:GetStatusBarColor()
        r = r * 0.3
        b = b * 0.3
        g = g * 0.3
        self.healthbar:SetStatusBarColor(r, g, b)
        self.classicon:SetAlpha(0.4)
    else
        self.classicon:SetAlpha(1)
    end

    if UnitThreatSituation(self.unit) ~= nil and UnitThreatSituation(self.unit) > 2 then
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

local function showDebuffIcon(parent, i, btnIndex, x, y, filter, icon, count, debuffType, duration, expires)
    local size = 16
    local marginX, marginY = x * (size + 2), y * (size + 2)
    local name = "Gw" .. parent:GetName() .. "DeBuffItemFrame" .. btnIndex
    local frame = _G[name]

    if not frame then
        frame = CreateFrame("Button", name, parent, "GwDeBuffIcon")
        frame:SetParent(parent)
        frame:SetFrameStrata("MEDIUM")
        frame:SetSize(size, size)
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT", parent.healthbar, "BOTTOMLEFT", marginX + 3, marginY + 3)

        _G[name .. "Icon"]:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
        _G[name .. "Icon"]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
        
        frame:SetScript("OnEnter", onDebuffEnter)
        frame:SetScript("OnLeave", GameTooltip_Hide)
        frame:SetScript("OnMouseUp", onDebuffMouseUp)
        frame:EnableMouse(not InCombatLockdown() or GetSetting("RAID_AURA_TOOLTIP_IN_COMBAT"))
        frame:RegisterForClicks("RightButtonUp")
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

    _G[frame:GetName() .. "CooldownBuffDuration"]:SetText(expires and TimeCount(expires - GetTime()) or "")
    _G[frame:GetName() .. "IconBuffStacks"]:SetText((count or 1) > 1 and count or "")

    frame:Show()

    btnIndex, x, marginX = btnIndex + 1, x + 1, marginX + size + 2
    if marginX > parent:GetWidth() / 2 then
        x, y, marginX = 0, y + 1, 0
    end

    return btnIndex, x, y, marginX
end

local function updateDebuffs(self)
    local btnIndex, x, y = 1, 0, 0
    local filter = GetSetting("RAID_ONLY_DISPELL_DEBUFFS") and "RAID" or nil
    FillTable(ignored, true, strsplit(",", (GetSetting("AURAS_IGNORED"):trim():gsub("%s*,%s*", ","))))

    local i, framesDone, aurasDone = 0
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
            local shouldDisplay = debuffName and not (
                ignored[debuffName]
                or spellId == 6788 and caster and not UnitIsUnit(caster, "player") -- Don't show "Weakened Soul" from other players
            )

            if shouldDisplay then
                btnIndex, x, y = showDebuffIcon(self, i, btnIndex, x, y, filter, icon, count, debuffType, duration, expires)
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
        GameTooltip:SetSpellBookItem(self.index, BOOKTYPE_SPELL)
    else
        GameTooltip:SetUnitBuff(self:GetParent().unit, self.index)
    end
    GameTooltip:Show()
end

local function onBuffMouseUp(self, btn)
    if btn == "RightButton" and IsShiftKeyDown() then
        if self.isMissing then
            local name = GetSpellBookItemName(self.index, BOOKTYPE_SPELL)
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
    local name = "Gw" .. parent:GetName() .. "BuffItemFrame" .. btnIndex
    local frame = _G[name]

    if not frame then
        frame = CreateFrame("Button", name, parent, "GwBuffIconBig")
        frame:SetParent(parent)
        frame:SetFrameStrata("MEDIUM")
        frame:SetSize(14, 14)
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMRIGHT", parent.healthbar, "BOTTOMRIGHT", -(marginX + 3), marginY + 3)

        _G[name .. "BuffDuration"]:SetFont(UNIT_NAME_FONT, 11)
        _G[name .. "BuffDuration"]:SetTextColor(1, 1, 1)
        _G[name .. "BuffStacks"]:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
        _G[name .. "BuffStacks"]:SetTextColor(1, 1, 1)

        frame:SetScript("OnEnter", onBuffEnter)
        frame:SetScript("OnLeave", GameTooltip_Hide)
        frame:SetScript("OnMouseUp", onBuffMouseUp)
        frame:EnableMouse(not InCombatLockdown() or GetSetting("RAID_AURA_TOOLTIP_IN_COMBAT"))
        frame:RegisterForClicks("RightButtonUp")
    end

    frame.index = i
    frame.isMissing = isMissing

    _G[name .. "BuffIcon"]:SetTexture(icon)
    _G[name .. "BuffIcon"]:SetVertexColor(1, isMissing and .75 or 1, isMissing and .75 or 1)
    _G[name .. "BuffDuration"]:SetText("")
    _G[name .. "BuffStacks"]:SetText("")

    frame:Show()

    btnIndex, x, marginX = btnIndex + 1, x + 1, marginX + size + 2
    if marginX > parent:GetWidth() / 2 then
        x, y = 0, y + 1
    end

    return btnIndex, x, y
end

local function updateBuffs(self)
    local btnIndex, x, y = 1, 0, 0
    local indicators = AURAS_INDICATORS[select(2, UnitClass("player"))]
    local i, name = 1
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
        for mName,v in pairs(missing) do
            if v then
                while not spellBookIndex[mName] and spellBookSearched < 1000 do
                    spellBookSearched = spellBookSearched + 1
                    name = GetSpellBookItemName(spellBookSearched, BOOKTYPE_SPELL)
                    if not name then
                        spellBookSearched = 1000
                    elseif missing[name] ~= nil and not spellBookIndex[name] then
                        spellBookIndex[name] = spellBookSearched
                    end
                end

                if spellBookIndex[mName] then
                    local icon = GetSpellBookItemTexture(spellBookIndex[mName], BOOKTYPE_SPELL)
                    i, btnIndex, x, y = i + 1, showBuffIcon(self, spellBookIndex[mName], btnIndex, x, y, icon, true)
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
                                        frame.text:SetFont(UNIT_NAME_FONT, 11, "OUTLINE")
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

local function raidframe_OnEvent(self, event, unit, arg1)
    if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        -- Enable or disable mouse handling on aura frames
        local name, enable = self:GetName(), event == "PLAYER_REGEN_ENABLED" or GetSetting("RAID_AURA_TOOLTIP_IN_COMBAT")
        for j=1,2 do
            local i, aura, frame = 1, j == 1 and "Buff" or "Debuff"
            repeat
                frame, i = _G["Gw" .. name .. aura .. "ItemFrame" .. i], i + 1
                if frame then
                    frame:EnableMouse(enable)
                end
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
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH_FREQUENT" and unit == self.unit then
        setHealth(self)
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" and unit == self.unit then
        local power = UnitPower(self.unit, UnitPowerType(self.unit))
        local powerMax = UnitPowerMax(self.unit, UnitPowerType(self.unit))
        local powerPrecentage = 0
        if powerMax > 0 then
            powerPrecentage = power / powerMax
        end
        self.manabar:SetValue(powerPrecentage)
        powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
        if PowerBarColorCustom[powerToken] then
            local pwcolor = PowerBarColorCustom[powerToken]
            self.manabar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
        end
    elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" and unit == self.unit then
        setAbsorbAmount(self)
    elseif event == "UNIT_HEAL_PREDICTION" and unit == self.unit then
        setPredictionAmount(self)
    elseif (event == "UNIT_PHASE" and unit == self.unit) or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" then
        updateAwayData(self)
    elseif event == "PLAYER_TARGET_CHANGED" then
        highlightTargetFrame(self)
    elseif event == "UNIT_NAME_UPDATE" and unit == self.unit then
        setUnitName(self)
    elseif event == "UNIT_AURA" and unit == self.unit then
        updateAuras(self)
    elseif event == "PLAYER_ENTERING_WORLD" then
        RequestRaidInfo()
    elseif event == "UPDATE_INSTANCE_INFO" then
        updateAuras(self)
        updateAwayData(self)
    elseif event == "INCOMING_RESURRECT_CHANGED" or event == "INCOMING_SUMMON_CHANGED" then
        updateAwayData(self)
    elseif event == "RAID_TARGET_UPDATE" and GetSetting("RAID_UNIT_MARKERS") == true then
        updateRaidMarkers(self)
    elseif event == "READY_CHECK" then
        self.ready = -1
        if not IsInRaid() and self.unit == "player" then
            self.ready = true
        end
        if IsInRaid() and self.unit == "raid" .. UnitInRaid(unit) then
            self.ready = true
        end
        GW_READY_CHECK_INPROGRESS = true
        updateAwayData(self)
        updateClassIcon(self, true)
    elseif event == "READY_CHECK_CONFIRM" and unit == self.unit then
        self.ready = arg1
        updateAwayData(self)
    elseif event == "READY_CHECK_FINISHED" then
        AddToAnimation(
            "ReadyCheckRaidWaitCheck" .. self.unit,
            0,
            1,
            GetTime(),
            2,
            function()
            end,
            nil,
            function()
                GW_READY_CHECK_INPROGRESS = false
                local classColor = GetSetting("RAID_CLASS_COLOR")
                if UnitInRaid(self.unit) ~= nil then
                    _, _, classIndex = UnitClass(self.unit)
                    if classColor == true then
                        self.healthbar:SetStatusBarColor(
                            CLASS_COLORS_RAIDFRAME[classIndex].r,
                            CLASS_COLORS_RAIDFRAME[classIndex].g,
                            CLASS_COLORS_RAIDFRAME[classIndex].b,
                            1
                        )
                        if self.classicon:IsShown() then
                            self.classicon:Hide()
                        end
                    else
                        self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons")
                    end
                    self.healthbar:SetStatusBarColor(0.207, 0.392, 0.168)
                    SetClassIcon(self.classicon, classIndex)
                end
            end
        )
    end
end
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

    powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
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
    local grow = GetSetting("RAID_GROW")
    local w = GetSetting("RAID_WIDTH")
    local h = GetSetting("RAID_HEIGHT")
    local cW = GetSetting("RAID_CONT_WIDTH")
    local cH = GetSetting("RAID_CONT_HEIGHT")
    local per = ceil(GetSetting("RAID_UNITS_PER_COLUMN"))
    local byRole = GetSetting("RAID_SORT_BY_ROLE")
    local m = 2

    -- Determine # of players
    if players or byRole or not IsInRaid() then
        players = players or max(1, GetNumGroupMembers())
    else
        players = 0
        for i = 1, 40 do
            local _, _, grp = GetRaidRosterInfo(i)
            if grp >= ceil(players / 5) then
                players = max((grp - 1) * 5, players) + 1
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
        if sizeMax1 > 0 then
            sizePer1 = min(sizePer1, (sizeMax1 + m) / cells1 - m)
        end
    elseif sizeMax1 > 0 then
        cells1 = max(1, min(players, floor((sizeMax1 + m) / (sizePer1 + m))))
    end

    local cells2 = ceil(players / cells1)

    if sizeMax2 > 0 then
        sizePer2 = min(sizePer2, (sizeMax2 + m) / cells2 - m)
    end

    -- Container size
    local size1, size2 = cells1 * (sizePer1 + m) - m, cells2 * (sizePer2 + m) - m
    sizeMax1, sizeMax1 = max(size1, sizeMax1), max(size2, sizeMax2)

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
    GwRaidFrameContainerMoveAble:GetScript("OnDragStop")(GwRaidFrameContainerMoveAble)
end
GW.UpdateRaidFramesAnchor = UpdateRaidFramesAnchor
GW.AddForProfiling("raidframes", "UpdateRaidFramesAnchor", UpdateRaidFramesAnchor)

local function UpdateRaidFramesPosition()
    players = previewStep == 0 and 40 or previewSteps[previewStep]

    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, cells2, size1, size2, sizeMax1, sizeMax2, sizePer1, sizePer2, m = GetRaidFramesMeasures(players)
    local isV = grow1 == "DOWN" or grow1 == "UP"

    -- Update size
    GwRaidFrameContainerMoveAble:SetSize(isV and size2 or size1, isV and size1 or size2)

    -- Update unit frames
    for i = 1, 40 do
        PositionRaidFrame(_G["GwRaidGridDisplay" .. i], GwRaidFrameContainerMoveAble, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
        if i > players then _G["GwRaidGridDisplay" .. i]:Hide() else _G["GwRaidGridDisplay" .. i]:Show() end
    end
end
GW.UpdateRaidFramesPosition = UpdateRaidFramesPosition
GW.AddForProfiling("raidframes", "UpdateRaidFramesPosition", UpdateRaidFramesPosition)

local function ToggleRaidFramesPreview()
    previewStep = max((previewStep + 1) % (#previewSteps + 1), hudMoving and 1 or 0)
    if previewStep == 0 then
        GwRaidFrameContainerMoveAble:EnableMouse(false)
        GwRaidFrameContainerMoveAble:SetMovable(false)
        GwRaidFrameContainerMoveAble:Hide()
    else
        GwRaidFrameContainerMoveAble:Show()
        GwRaidFrameContainerMoveAble:EnableMouse(true)
        GwRaidFrameContainerMoveAble:SetMovable(true)
        UpdateRaidFramesPosition()
    end
    GwToggleRaidPreview:SetText(previewStep == 0 and "-" or previewSteps[previewStep])
end

local function sortByRole()
    local sorted = {}
    local roleIndex = {"TANK", "HEALER", "DAMAGER", "NONE"}
    local unitString = IsInRaid() and "raid" or "party"

    for k, v in pairs(roleIndex) do
        if unitString == "party" and UnitGroupRolesAssigned("player") == v then
            tinsert(sorted, "player")
        end

        for i = 1, 40 do
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
    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, cells2, size1, size2, sizeMax1, sizeMax2, sizePer1, sizePer2, m = GetRaidFramesMeasures()
    local isV = grow1 == "DOWN" or grow1 == "UP"
    
    if not InCombatLockdown() then
        GwRaidFrameContainer:SetSize(isV and size2 or size1, isV and size1 or size2)
    end

    local unitString = IsInRaid() and "raid" or "party"
    local sorted = (unitString == "party" or GetSetting("RAID_SORT_BY_ROLE")) and sortByRole() or {}

    -- Position by role
    for i, v in ipairs(sorted) do
        PositionRaidFrame(_G["GwCompact" .. v], GwRaidFrameContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
    end

    wipe(grpPos) wipe(noGrp)

    -- Position by group
    for i = 1, 40 do
        if not tContains(sorted, unitString .. i) then
            if i < 5 then
                PositionRaidFrame(_G["GwCompactparty" .. i], GwRaidFrameContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
            end

            local name, _, grp = GetRaidRosterInfo(i)
            if name or grp > 1 then
                grpPos[grp] = (grpPos[grp] or 0) + 1
                PositionRaidFrame(_G["GwCompactraid" .. i], GwRaidFrameContainer, (grp - 1) * 5 + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
            else
                tinsert(noGrp, i)
            end
        end
    end

    -- Find spots for units with missing group info
    for _,i in ipairs(noGrp) do
        for grp=1,8 do
            if (grpPos[grp] or 0) < 5 then
                grpPos[grp] = (grpPos[grp] or 0) + 1
                PositionRaidFrame(_G["GwCompactraid" .. i], GwRaidFrameContainer, (grp - 1) * 5 + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
                break
            end
        end
    end
end
GW.UpdateRaidFramesLayout = UpdateRaidFramesLayout
GW.AddForProfiling("raidframes", "UpdateRaidFramesLayout", UpdateRaidFramesLayout)

local function createRaidFrame(registerUnit, index)
    local frame = _G["GwCompact" .. registerUnit]
    if _G["GwCompact" .. registerUnit] == nil then
        frame = CreateFrame("Button", "GwCompact" .. registerUnit, GwRaidFrameContainer, "GwRaidFrame")
        frame.name = _G[frame:GetName() .. "Data"].name
        frame.healthstring = _G[frame:GetName() .. "Data"].healthstring
        frame.classicon = _G[frame:GetName() .. "Data"].classicon
        frame.healthbar = frame.predictionbar.healthbar
        frame.absorbbar = frame.healthbar.absorbbar
        frame.aggroborder = frame.absorbbar.aggroborder
        frame.nameNotLoaded = false

        frame.name:SetFont(UNIT_NAME_FONT, 12)
        frame.name:SetShadowOffset(-1, -1)
        frame.name:SetShadowColor(0, 0, 0, 1)

        frame.healthstring:SetFont(UNIT_NAME_FONT, 11)
        frame.healthstring:SetShadowOffset(-1, -1)
        frame.healthstring:SetShadowColor(0, 0, 0, 1)

        hooksecurefunc(
            frame.healthbar,
            "SetStatusBarColor",
            function(bar, r, g, b, a)
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
    frame:RegisterForClicks("LeftButtonDown", "RightButtonUp", "Button4Up", "Button5Up", "MiddleButtonUp")

    frame:SetScript("OnLeave", GameTooltip_Hide)
    frame:SetScript(
        "OnEnter",
        function()
            GameTooltip:ClearLines()
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit(registerUnit)

            GameTooltip:Show()
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

    frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", registerUnit)
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

    raidframe_OnEvent(frame, "load")

    if GetSetting("RAID_POWER_BARS") == true then
        frame.predictionbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 5)
        frame.manabar:Show()
    end
end
GW.AddForProfiling("raidframes", "createRaidFrame", createRaidFrame)

local function LoadRaidFrames()
    hideBlizzardRaidFrame()

    if CompactRaidFrameManager_UpdateShown then
        hooksecurefunc("CompactRaidFrameManager_UpdateShown", hideBlizzardRaidFrame)
    end
    if CompactRaidFrameManager then
        CompactRaidFrameManager:HookScript("OnShow", hideBlizzardRaidFrame)
    end

    CreateFrame("Frame", "GwRaidFrameContainer", UIParent, "GwRaidFrameContainer")

    GwRaidFrameContainer:ClearAllPoints()
    GwRaidFrameContainer:SetPoint(
        GetSetting("raid_pos")["point"],
        UIParent,
        GetSetting("raid_pos")["relativePoint"],
        GetSetting("raid_pos")["xOfs"],
        GetSetting("raid_pos")["yOfs"]
    )

    RegisterMovableFrame("GwRaidFrameContainer", GwRaidFrameContainer, "raid_pos", "VerticalActionBarDummy")

    hooksecurefunc(GwRaidFrameContainerMoveAble, "StopMovingOrSizing", function (frame)
        local anchor = GetSetting("RAID_ANCHOR")
    
        if anchor == "GROWTH" then
            local g1, g2 = strsplit("+", GetSetting("RAID_GROW"))
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

    for i = 1, 40 do
        local f = CreateFrame("Frame", "GwRaidGridDisplay" .. i, GwRaidFrameContainerMoveAble, "VerticalActionBarDummy")
        f:SetParent(GwRaidFrameContainerMoveAble)
        f.frameName:SetText("")
        f.Background:SetVertexColor(0.2, 0.2, 0.2, 1)
        f:SetPoint("TOPLEFT", GwRaidFrameContainerMoveAble, "TOPLEFT", 0, 0)
    end

    createRaidFrame("player", nil)
    for i = 1, 4 do
        createRaidFrame("party" .. i, i)
    end

    for i = 1, 40 do
        createRaidFrame("raid" .. i, i)
    end

    UpdateRaidFramesPosition()
    UpdateRaidFramesLayout()

    GwToggleRaidPreview:SetScript("OnClick", ToggleRaidFramesPreview)
    GwSettingsWindowMoveHud:HookScript("OnClick", function ()
        hudMoving = true
        if previewStep == 0 then
            ToggleRaidFramesPreview()
        end
    end)
    GwToggleRaidPreview.label:SetText(PREVIEW)

    GwRaidFrameContainer:RegisterEvent("RAID_ROSTER_UPDATE")
    GwRaidFrameContainer:RegisterEvent("GROUP_ROSTER_UPDATE")
    GwRaidFrameContainer:RegisterEvent("PLAYER_ENTERING_WORLD")

    GwRaidFrameContainer:SetScript("OnEvent", function(self)
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            return
        else
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end

        if IsInRaid() == false and GROUPD_TYPE == "RAID" then
            togglePartyFrames(true)
            GROUPD_TYPE = "PARTY"
        end
        if IsInRaid() and GROUPD_TYPE == "PARTY" then
            togglePartyFrames(false)
            GROUPD_TYPE = "RAID"
        end

        unhookPlayerFrame()

        UpdateRaidFramesLayout()

        updateFrameData(_G["GwCompactplayer"], nil)
        for i = 1, 40 do
            if i < 5 then
                updateFrameData(_G["GwCompactparty" .. i], i)
            end
            updateFrameData(_G["GwCompactraid" .. i], i)
        end
    end)

    if GetSetting("RAID_STYLE_PARTY") == false then
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
