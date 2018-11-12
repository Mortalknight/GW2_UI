local _, GW = ...
local gw_set_unit_flag = GW.UnitFlags
local Debuff = GW.Debuff
local GetSetting = GW.GetSetting
local CountTable = GW.CountTable
local SplitString = GW.SplitString
local PowerBarColorCustom = GW.PowerBarColorCustom
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

local GROUPD_TYPE = "PARTY"
local GW_READY_CHECK_INPROGRESS = false
local realmid_Player

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

    if absorb > 0 and healthMax > 0 then
        absorbPrecentage = absorb / healthMax
    end
    self.healthbar.absorbbar:SetValue(absorbPrecentage)
end
GW.AddForProfiling("raidframes", "setAbsorbAmount", setAbsorbAmount)



local function setHealPrediction(self,predictionPrecentage)
    self.predictionbar:SetValue(predictionPrecentage)    
end
GW.AddForProfiling("raidframes", "setHealPrediction", setHealPrediction)

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
    setHealPrediction(self,predictionPrecentage)
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

    local guid = UnitGUID(self.unit)
    local realmid = string.match(guid, "^Player%-(%d+)") 
    local guid_Player = UnitGUID("Player")
    if guid_Player ~= nil then
        realmid_Player = string.match(guid_Player, "^Player%-(%d+)")
    end

    local role = UnitGroupRolesAssigned(self.unit)
    local nameString = UnitName(self.unit)
    local realmflag = ""
    
    if not nameString or nameString == UNKNOWNOBJECT then
        self.nameNotLoaded = false
    else
        self.nameNotLoaded = true
    end

    if GetSetting("RAID_UNIT_FLAGS") == "NONE" then
        realmflag = ""
    elseif GetSetting("RAID_UNIT_FLAGS") == "DIFFERENT" then
        if gw_set_unit_flag[realmid] ~= gw_set_unit_flag[realmid_Player] then
            realmflag = gw_set_unit_flag[realmid]
        end
    elseif GetSetting("RAID_UNIT_FLAGS") == "ALL" then
        realmflag = gw_set_unit_flag[realmid]
    end
    if realmflag == nil then
        realmflag = ""
    end
    if nameRoleIcon[role] ~= nil then
        nameString = nameRoleIcon[role] .. nameString
    end
    if UnitIsGroupLeader(self.unit) then
        nameString = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\icon-groupleader:15:15:0:-1|t" .. nameString
    elseif UnitIsGroupAssistant(self.unit) then
        nameString = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\icon-assist:15:15:0:-1|t" .. nameString
    end
    if self.index then
        local _, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(self.index)
        if role == "MAINTANK" then
            nameString = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\icon-maintank:15:15:0:-1|t" .. nameString
        elseif role == "MAINASSIST" then
            nameString = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\icon-mainassist:15:15:0:-1|t" .. nameString
        end 
    end
    self.name:SetText(nameString .. " " .. realmflag)
end
GW.AddForProfiling("raidframes", "setUnitName", setUnitName)

local function highlightTargetFrame(self)
    local guidTarget = UnitGUID("target")

    if self.guid == guidTarget then
        self.targetHighlight:SetVertexColor(1, 1, 1, 1)
    else
        self.targetHighlight:SetVertexColor(0, 0, 0, 1)
    end
end
GW.AddForProfiling("raidframes", "highlightTargetFrame", highlightTargetFrame)

local function updateClassIcon(self)
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

    if classIndex ~= nil and classIndex ~= 0 and classColor == false and GW_READY_CHECK_INPROGRESS == false then
        self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons")
        iconState = 1
    end

    if classColor == true and classIndex ~= nil and classIndex ~= 0 then
        iconState = 0
    end
    if UnitIsDeadOrGhost(self.unit) then
        iconState = 2
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
        self.healthbar:SetStatusBarColor(0.3, 0.3, 0.3, 1)
    end

    if (not UnitInPhase(self.unit) or UnitIsWarModePhased(self.unit)) or UnitInRange(self.unit) ~= true then
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

local function updateDebuffs(self)
    local widthLimit = self:GetWidth() / 2
    local widthLimitExceeded = false
    local buffIndex = 1
    local x = 0
    local y = 0
    local DebuffLists = {}
    local ignored = GetSetting("AURAS_IGNORED")

    local filter = nil
    if GetSetting("RAID_ONLY_DISPELL_DEBUFFS") then
        filter = "RAID"
    end

    for i = 1, 40 do
        DebuffLists[i] = {}
        DebuffLists[i]["name"],
            DebuffLists[i]["icon"],
            DebuffLists[i]["count"],
            DebuffLists[i]["dispelType"],
            DebuffLists[i]["duration"],
            DebuffLists[i]["expires"],
            DebuffLists[i]["caster"],
            DebuffLists[i]["isStealable"],
            DebuffLists[i]["shouldConsolidate"],
            DebuffLists[i]["spellID"] = UnitDebuff(self.unit, i, filter)

        local indexBuffFrame = _G["Gw" .. self:GetName() .. "DeBuffItemFrame" .. i]
        local created = false
        local shouldDisplay = DebuffLists[i]["name"] and not ignored:find(DebuffLists[i]["name"])

        --remove old debuff
        if indexBuffFrame ~= nil then
            indexBuffFrame:Hide()
            indexBuffFrame:SetScript("OnEnter", nil)
            indexBuffFrame:SetScript("OnClick", nil)
            indexBuffFrame:SetScript("OnLeave", nil)
        end   

        --set new debuff
        if shouldDisplay and widthLimitExceeded == false then
            local name = "Gw" .. self:GetName() .. "DeBuffItemFrame" .. buffIndex
            indexBuffFrame = _G[name]
            if indexBuffFrame == nil then
                indexBuffFrame =
                    CreateFrame("Button", name, self, "GwDeBuffIcon")
                indexBuffFrame:SetParent(self)
                indexBuffFrame:SetFrameStrata("MEDIUM")
                indexBuffFrame:SetSize(16, 16)
                indexBuffFrame:EnableMouse(false)
                created = true
                indexBuffFrame.unit = self.unit
            end
            local margin = indexBuffFrame:GetWidth() + 2
            local marginy = indexBuffFrame:GetWidth() + 2
            if created then
                indexBuffFrame:ClearAllPoints()
                indexBuffFrame:SetPoint("BOTTOMLEFT", self.healthbar, "BOTTOMLEFT", 3 + (margin * x), 3 + (marginy * y))

                _G[name .. "Icon"]:SetPoint("TOPLEFT", indexBuffFrame, "TOPLEFT", 1, -1)
                _G[name .. "Icon"]:SetPoint("BOTTOMRIGHT", indexBuffFrame, "BOTTOMRIGHT", -1, 1)
            end

            GW.Debuff(indexBuffFrame, DebuffLists[i], i, filter)

            indexBuffFrame:Show()

            buffIndex = buffIndex + 1
            x = x + 1
            if (margin * x) < (-(self:GetWidth() / 2)) then
                x, y = 0, y + 1
            end

            if widthLimit < (margin * x) then
                widthLimitExceeded = true
            end
        end    
    end
end
GW.AddForProfiling("raidframes", "updateDebuffs", updateDebuffs)

local function showBuffIcon(parent, icon, buffIndex, x, y, index, isMissing)
    local name = "Gw" .. parent:GetName() .. "BuffItemFrame" .. buffIndex
    local frame = _G[name]
    local created = not frame

    if created then
        frame = CreateFrame("Button", name, parent, "GwBuffIconBig")
        _G[name .. "BuffDuration"]:SetFont(UNIT_NAME_FONT, 11)
        _G[name .. "BuffDuration"]:SetTextColor(1, 1, 1)
        _G[name .. "BuffStacks"]:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
        _G[name .. "BuffStacks"]:SetTextColor(1, 1, 1)
        frame:SetParent(parent)
        frame:SetFrameStrata("MEDIUM")
        frame:SetSize(14, 14)
        frame:RegisterForClicks("RightButtonUp")

        frame:SetScript("OnEnter", function (self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
            GameTooltip:ClearLines()
            if self.isMissing then
                GameTooltip:SetSpellBookItem(self.index, BOOKTYPE_SPELL)
            else
                GameTooltip:SetUnitBuff(self:GetParent().unit, self.index)
            end

            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", GameTooltip_Hide)
    end
    
    local margin = -frame:GetWidth() + -2
    local marginy = frame:GetWidth() + 2

    if created then
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMRIGHT", parent.healthbar, "BOTTOMRIGHT", -3 + (margin * x), 3 + (marginy * y))
    end

    frame.index = index
    frame.isMissing = isMissing

    _G[name .. "BuffIcon"]:SetTexture(icon)
    _G[name .. "BuffIcon"]:SetVertexColor(1, isMissing and .75 or 1, isMissing and .75 or 1)
    _G[name .. "BuffDuration"]:SetText("")
    _G[name .. "BuffStacks"]:SetText("")

    frame:Show()

    buffIndex = buffIndex + 1
    x = x + 1

    if (margin * x) < (-(parent:GetWidth() / 2)) then
        x, y = 0, y + 1
    end

    return buffIndex, x, y
end

local function updateAuras(self)
    local buffIndex = 1
    local x = 0
    local y = 0
    local missing = GetSetting("AURAS_MISSING")
    local ignored = GetSetting("AURAS_IGNORED")
    local indicators = AURAS_INDICATORS[select(2, UnitClass("player"))]
    
    for _, pos in pairs(INDICATORS) do
        self['indicator' .. pos]:Hide()
    end

    for i = 1, 40 do
        --remove old buff
        local frame = _G["Gw" .. self:GetName() .. "BuffItemFrame" .. i]
        if frame then
            frame:Hide()
        end
        
        -- check missing
        local name = UnitBuff(self.unit, i)
        if name then
            missing = missing:gsub(name, "")
        end
    end
    
    -- missing buffs
    for i = 1, 1000 do
        local name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not name then
            break
        elseif missing:find(name) then
            local icon = GetSpellBookItemTexture(i, BOOKTYPE_SPELL)
            buffIndex, x, y = showBuffIcon(self, icon, buffIndex, x, y, i, true)
            break
        end
    end

    missing = GetSetting("AURAS_MISSING")

    for i = 1, 40 do
        local showThis = false
        local name, icon, _, _, duration, expires, caster, _, _, spellID, canApplyAura, _ = UnitBuff(self.unit, i)

        if not name then
            break
        end

        -- visibility
        local hasCustom, alwaysShowMine, showForMySpec =
            SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
        if (hasCustom) then
            showThis =
                showForMySpec or (alwaysShowMine and (caster == "player" or caster == "pet" or caster == "vehicle"))
        else
            showThis =
                (caster == "player" or caster == "pet" or caster == "vehicle") and canApplyAura and
                not SpellIsSelfBuff(spellID)
        end

        -- indicators
        if showThis then
            for _, pos in ipairs(INDICATORS) do
                if spellID == GetSetting("INDICATOR_" .. pos, true) then
                    local frame = self["indicator" .. pos]

                    if pos == "BAR" then
                        frame.expires = expires
                        frame.duration = duration
                    else
                        if GetSetting("INDICATORS_ICON") then
                            frame.icon:SetTexture(icon)
                        else
                            frame.icon:SetColorTexture(unpack(indicators[spellID]))
                        end

                        if GetSetting("INDICATORS_TIME") then
                            frame.cooldown:Show()
                            frame.cooldown:SetCooldown(expires - duration, duration)
                        else
                            frame.cooldown:Hide()
                        end

                        showThis = false
                    end
                    
                    frame:Show()
                end
            end
        end

        --set new buff
        if showThis and not (ignored:find(name) or missing:find(name)) then
            buffIndex, x, y = showBuffIcon(self, icon, buffIndex, x, y, i)
        end
    end

    updateDebuffs(self)
end
GW.AddForProfiling("raidframes", "updateAuras", updateAuras)

local function raidframe_OnEvent(self, event, unit, arg1)
    if not UnitExists(self.unit) then
        return
    end

    if not self.nameNotLoaded then
        setUnitName(self)
    end
    if event == "load" then
        setAbsorbAmount(self)
        setPredictionAmount(self)
        setHealth(self)
    end

    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" and unit == self.unit then
        setHealth(self)
    end

    if event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" and unit == self.unit then
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
    end

    if event == "UNIT_ABSORB_AMOUNT_CHANGED" and unit == self.unit then
        setAbsorbAmount(self)
    end

    if event == "UNIT_HEAL_PREDICTION" and unit == self.unit then
        setPredictionAmount(self)
    end

    if
        (event == "UNIT_PHASE" and unit == self.unit) or event == "PARTY_MEMBER_DISABLE" or
            event == "PARTY_MEMBER_ENABLE"
     then
        updateAwayData(self)
    end

    if event == "PLAYER_TARGET_CHANGED" then
        highlightTargetFrame(self)
    end
    if event == "UNIT_NAME_UPDATE" and unit == self.unit then
        setUnitName(self)
    end
    if event == "UNIT_AURA" and unit == self.unit then
        updateAuras(self)
    end
    if event == "PLAYER_ENTERING_WORLD" then
        RequestRaidInfo()
    end
    if event == "UPDATE_INSTANCE_INFO" then
        updateAuras(self)
        updateAwayData(self)
    end
    if event == "RAID_TARGET_UPDATE" and GetSetting("RAID_UNIT_MARKERS") == true then
        updateRaidMarkers(self)
    end

    if event == "READY_CHECK" then
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
    end

    if event == "READY_CHECK_CONFIRM" and unit == self.unit then
        self.ready = arg1
        updateAwayData(self)
    end

    if event == "READY_CHECK_FINISHED" then
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
                    localizedClass, englishClass, classIndex = UnitClass(self.unit)
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
    self.healthbar.absorbbar:SetValue(absorbPrecentage)
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

local function GetRaidFramesMeasures(full)
    -- Get settings
    local players = full and 40 or max(1, GetNumGroupMembers())
    local grow = GetSetting("RAID_GROW")
    local w = GetSetting("RAID_WIDTH")
    local h = GetSetting("RAID_HEIGHT")
    local cW = GetSetting("RAID_CONT_WIDTH")
    local cH = GetSetting("RAID_CONT_HEIGHT")
    local per = min(players, ceil(GetSetting("RAID_UNITS_PER_COLUMN")))
    local m = 2

    -- Directions
    local grow1, grow2 = strsplit("+", grow)
    local isV = grow1 == "D" or grow1 == "U"

    -- Rows, cols and cell size
    local sizeMax1, sizePer1 = isV and cH or cW, isV and h or w
    local sizeMax2, sizePer2 = isV and cW or cH, isV and w or h
    local cells1 = players

    if per > 0 and per < cells1 then
        cells1 = per
        if sizeMax1 > 0 then
            sizePer1 = min(sizePer1, (sizeMax1 + m) / cells1 - m)
        end
    elseif sizeMax1 > 0 then
        cells1 = max(1, min(cells1, floor((sizeMax1 + m) / (sizePer1 + m))))
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

local function PositionRaidFrame(frame, parent, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
    local isV = grow1 == "D" or grow1 == "U"
    local isU = grow1 == "U" or grow2 == "U"
    local isR = grow1 == "R" or grow2 == "R"

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

    frame:ClearAllPoints()
    frame:SetPoint(a, parent, a, x, y)
    frame:SetSize(w, h)

    if frame.healthbar then
        frame.healthbar.spark:SetHeight(frame.healthbar:GetHeight())
    end
end

local function UpdateRaidFramesPosition()
    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, cells2, size1, size2, sizeMax1, sizeMax2, sizePer1, sizePer2, m = GetRaidFramesMeasures(true)
    local isV = grow1 == "D" or grow1 == "U"

    GwRaidFrameContainerMoveAble:SetSize(isV and size2 or size1, isV and size1 or size2)

    for i = 1, 40 do
        PositionRaidFrame(_G["GwRaidGridDisplay" .. i], GwRaidFrameContainerMoveAble, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
    end
end
GW.UpdateRaidFramesPosition = UpdateRaidFramesPosition

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

local function UpdateRaidFramesLayout()
    if InCombatLockdown() then
        GwRaidFrameContainer:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, cells2, size1, size2, sizeMax1, sizeMax2, sizePer1, sizePer2, m = GetRaidFramesMeasures()
    local isV = grow1 == "D" or grow1 == "U"
    
    GwRaidFrameContainer:SetSize(isV and size2 or size1, isV and size1 or size2)

    -- Position sorted players
    local sorted = sortByRole()

    for i, v in ipairs(sorted) do
        PositionRaidFrame(_G["GwCompact" .. v], GwRaidFrameContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
    end

    -- Position everyone else
    for i = 1, 40 do
        local placed = false

        for k, v in ipairs(sorted) do
            if v == "raid" .. i or v == "party" .. i then
                placed = true
                break
            end
        end

        if not placed then
            if i < 5 then
                PositionRaidFrame(_G["GwCompactparty" .. i], GwRaidFrameContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
            end

            PositionRaidFrame(_G["GwCompactraid" .. i], GwRaidFrameContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
        end
    end
end
GW.UpdateRaidFramesLayout = UpdateRaidFramesLayout

local function createRaidFrame(registerUnit, index)
    local frame = _G["GwCompact" .. registerUnit]
    if _G["GwCompact" .. registerUnit] == nil then
        frame = CreateFrame("Button", "GwCompact" .. registerUnit, GwRaidFrameContainer, "GwRaidFrame")
        frame.name = _G[frame:GetName() .. "Data"].name
        frame.classicon = _G[frame:GetName() .. "Data"].classicon
        frame.healthbar = frame.predictionbar.healthbar;
        frame.aggroborder = frame.healthbar.absorbbar.aggroborder
        frame.nameNotLoaded = false

        frame.name:SetFont(UNIT_NAME_FONT, 12)
        frame.name:SetShadowOffset(-1, -1)
        frame.name:SetShadowColor(0, 0, 0, 1)

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
    frame:RegisterForClicks("LeftButtonDown", "RightButtonUp", "Button4Up", "Button5Up")

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
    frame:RegisterEvent("READY_CHECK")
    frame:RegisterEvent("READY_CHECK_CONFIRM")
    frame:RegisterEvent("READY_CHECK_FINISHED")
    frame:RegisterEvent("RAID_TARGET_UPDATE")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("UPDATE_INSTANCE_INFO")
    frame:RegisterEvent("PARTY_MEMBER_DISABLE")
    frame:RegisterEvent("PARTY_MEMBER_ENABLE")

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

    GwRaidFrameContainer:ClearAllPoints();
    GwRaidFrameContainer:SetPoint(
        GetSetting("raid_pos")["point"],
        UIParent,
        GetSetting("raid_pos")["relativePoint"],
        GetSetting("raid_pos")["xOfs"],
        GetSetting("raid_pos")["yOfs"]
    )

    RegisterMovableFrame("GwRaidFrameContainer", GwRaidFrameContainer, "raid_pos", "VerticalActionBarDummy")

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
    UpdateRaidFramesLayout()

    GwRaidFrameContainer:RegisterEvent("RAID_ROSTER_UPDATE")
    GwRaidFrameContainer:RegisterEvent("GROUP_ROSTER_UPDATE")
    GwRaidFrameContainer:RegisterEvent("PLAYER_ENTERING_WORLD")

    GwRaidFrameContainer:SetScript(
        "OnEvent",
        function(self, event)
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

            if event == "PLAYER_REGEN_ENABLED" then
                self:UnregisterEvent(event)
            end
        end
    )

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

    UpdateRaidFramesPosition()
end
GW.LoadRaidFrames = LoadRaidFrames
