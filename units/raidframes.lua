local _, GW = ...
local gw_set_unit_flag = GW.UnitFlags
local Debuff = GW.Debuff
local GetSetting = GW.GetSetting
local CountTable = GW.CountTable
local PowerBarColorCustom = GW.PowerBarColorCustom
local CLASS_COLORS_RAIDFRAME = GW.CLASS_COLORS_RAIDFRAME
local TogglePartyRaid = GW.TogglePartyRaid
local RegisterMovableFrame = GW.RegisterMovableFrame
local Bar = GW.Bar
local SetClassIcon = GW.SetClassIcon
local SetDeadIcon = GW.SetDeadIcon
local AddToAnimation = GW.AddToAnimation
local AddToClique = GW.AddToClique

local GROUPD_TYPE = "PARTY"
local GW_READY_CHECK_INPROGRESS = false

local function UpdateRaidFramesAnchor()
    GwRaidFrameContainerMoveAble:GetScript("OnDragStop")(GwRaidFrameContainerMoveAble)
end
GW.UpdateRaidFramesAnchor = UpdateRaidFramesAnchor

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

    local nameString = UnitName(self.unit)
    
    if not nameString or nameString == UNKNOWNOBJECT then
        self.nameNotLoaded = false
    else
        self.nameNotLoaded = true
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
    self.name:SetText(nameString)
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

    if not UnitInPhase(self.unit) or UnitInRange(self.unit) ~= true then
        local r, g, b = self.healthbar:GetStatusBarColor()
        r = r * 0.3
        b = b * 0.3
        g = g * 0.3
        self.healthbar:SetStatusBarColor(r, g, b)
        self.classicon:SetAlpha(0.4)
    else
        self.classicon:SetAlpha(1)
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
        local shouldDisplay = false
        --remove old debuff
        if indexBuffFrame ~= nil then
            indexBuffFrame:Hide()
            indexBuffFrame:SetScript("OnEnter", nil)
            indexBuffFrame:SetScript("OnClick", nil)
            indexBuffFrame:SetScript("OnLeave", nil)
        end   
        --set new debuff
        if DebuffLists[i]["name"] ~= nil then
            shouldDisplay = true
        end

        if shouldDisplay and widthLimitExceeded == false then
            if indexBuffFrame == nil then
                indexBuffFrame =
                    CreateFrame("Button", "Gw" .. self:GetName() .. "DeBuffItemFrame" .. i, self, "GwDeBuffIcon")
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

                _G["Gw" .. self:GetName() .. "DeBuffItemFrame" .. buffIndex .. "Icon"]:SetPoint(
                    "TOPLEFT",
                    indexBuffFrame,
                    "TOPLEFT",
                    1,
                    -1
                )
                _G["Gw" .. self:GetName() .. "DeBuffItemFrame" .. buffIndex .. "Icon"]:SetPoint(
                    "BOTTOMRIGHT",
                    indexBuffFrame,
                    "BOTTOMRIGHT",
                    -1,
                    1
                )
            end

            GW.LoadDebuff(indexBuffFrame, DebuffLists[i], i, filter)

            indexBuffFrame:Show()

            buffIndex = buffIndex + 1
            x = x + 1
            if (margin * x) < (-(self:GetWidth() / 2)) then
                y = y + 1
                x = 0
            end

            if widthLimit < (margin * x) then
                widthLimitExceeded = true
            end
        end    
    end
end
GW.AddForProfiling("raidframes", "updateDebuffs", updateDebuffs)

local function updateAuras(self)
    local buffIndex = 1
    local x = 0
    local y = 0
    local spellTotrack = false
    local spellToTrackExpires = 0
    local spellToTrackDuration = 0
    for i = 1, 40 do
        local _, icon, _, _, duration, expires, caster, _, _, spellID, canApplyAura, _ = UnitBuff(self.unit, i)

        local showThis = false
        if UnitBuff(self.unit, i) then
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
        end
        --remove old buff
        local indexBuffFrame = _G["Gw" .. self:GetName() .. "BuffItemFrame" .. i]
        if indexBuffFrame ~= nil then
            indexBuffFrame:Hide()
            indexBuffFrame:SetScript("OnEnter", nil)
            indexBuffFrame:SetScript("OnClick", nil)
            indexBuffFrame:SetScript("OnLeave", nil)
        end
        --set new buff
        local indexBuffFrame = _G["Gw" .. self:GetName() .. "BuffItemFrame" .. buffIndex]
        local created = false
        if showThis then
            if indexBuffFrame == nil then
                indexBuffFrame =
                    CreateFrame("Button", "Gw" .. self:GetName() .. "BuffItemFrame" .. buffIndex, self, "GwBuffIconBig")
                indexBuffFrame:RegisterForClicks("RightButtonUp")
                _G[indexBuffFrame:GetName() .. "BuffDuration"]:SetFont(UNIT_NAME_FONT, 11)
                _G[indexBuffFrame:GetName() .. "BuffDuration"]:SetTextColor(1, 1, 1)
                _G[indexBuffFrame:GetName() .. "BuffStacks"]:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
                _G[indexBuffFrame:GetName() .. "BuffStacks"]:SetTextColor(1, 1, 1)
                indexBuffFrame:SetParent(self)
                indexBuffFrame:SetFrameStrata("MEDIUM")
                indexBuffFrame:SetSize(14, 14)
                created = true
            end
            local margin = -indexBuffFrame:GetWidth() + -2
            local marginy = indexBuffFrame:GetWidth() + 2

            if created then
                indexBuffFrame:ClearAllPoints()
                indexBuffFrame:SetPoint("BOTTOMRIGHT", self.healthbar, "BOTTOMRIGHT", -3 + (margin * x), 3 + (marginy * y))
            end
            _G["Gw" .. self:GetName() .. "BuffItemFrame" .. buffIndex .. "BuffIcon"]:SetTexture(icon)
            indexBuffFrame:SetScript(
                "OnEnter",
                function()
                    GameTooltip:SetOwner(indexBuffFrame, "ANCHOR_BOTTOMLEFT", 28, 0)
                    GameTooltip:ClearLines()
                    GameTooltip:SetUnitBuff(self.unit, i)
                    GameTooltip:Show()
                end
            )
            indexBuffFrame:SetScript("OnLeave", GameTooltip_Hide)

            indexBuffFrame:Show()

            x = x + 1
            buffIndex = buffIndex + 1
            
            if (margin * x) < (-(self:GetWidth() / 2)) then
                y = y + 1
                x = 0
            end
        end     
    end
    
    self.spelltracker:Hide()
    self.spelltracker:SetScript("OnUpdate", nil)

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
    local power = UnitPower(self.unit, UnitPowerType(self.unit))
    local powerMax = UnitPowerMax(self.unit, UnitPowerType(self.unit))
    local powerPrecentage = 0

    if healthMax > 0 then
        healthPrec = health / healthMax
    end

    if powerMax > 0 then
        powerPrecentage = power / powerMax
    end
    self.manabar:SetValue(powerPrecentage)
    Bar(self.healthbar, healthPrec)

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

local function UpdateRaidFramesPosition()
    local WIDTH = GetSetting("RAID_WIDTH")
    local HEIGHT = GetSetting("RAID_HEIGHT")
    local MARGIN = 2
    local WINDOW_SIZE = GwRaidFrameContainer:GetHeight()

    local USED_WIDTH = 0
    local USED_HEIGHT = 0

    for i = 1, 40 do
        _G["GwRaidGridDisplay" .. i]:SetPoint(
            "TOPLEFT",
            GwRaidFrameContainerMoveAble,
            "TOPLEFT",
            USED_WIDTH,
            -USED_HEIGHT
        )
        _G["GwRaidGridDisplay" .. i]:SetSize(WIDTH, HEIGHT)

        USED_HEIGHT = USED_HEIGHT + HEIGHT + MARGIN

        if (USED_HEIGHT + HEIGHT + MARGIN) > WINDOW_SIZE then
            USED_HEIGHT = 0
            USED_WIDTH = USED_WIDTH + WIDTH + MARGIN
        end
    end
end
GW.UpdateRaidFramesPosition = UpdateRaidFramesPosition

local function sortByRole()
    local sorted_array = {}
    local roleIndex = {"TANK", "HEALER", "DAMAGER", "NONE"}
    local unitString = IsInRaid() and "raid" or "party"

    for k, v in pairs(roleIndex) do
        if unitString == "party"  then
            tinsert(sorted_array, "player")
        end

        for i = 1, 440 do
            if UnitExists(unitString .. i) then
                tinsert(sorted_array, unitString .. i)
            end
        end
    end

    return sorted_array
end
GW.AddForProfiling("raidframes", "sortByRole", sortByRole)

local function UpdateRaidFramesLayout()
    if InCombatLockdown() then
        return
    end

    local WIDTH = GetSetting("RAID_WIDTH")
    local HEIGHT = GetSetting("RAID_HEIGHT")
    local MARGIN = 2
    local WINDOW_SIZE = GwRaidFrameContainer:GetHeight()

    local USED_WIDTH = 0
    local USED_HEIGHT = 0

    local sorted = sortByRole()

    local sparkHeight = _G["GwCompactraid1"].healthbar:GetHeight()

    for k, v in pairs(sorted) do
        _G["GwCompact" .. v]:SetPoint("TOPLEFT", GwRaidFrameContainer, "TOPLEFT", USED_WIDTH, -USED_HEIGHT)
        _G["GwCompact" .. v]:SetSize(WIDTH, HEIGHT)
        _G["GwCompact" .. v].healthbar.spark:SetHeight(sparkHeight)

        USED_HEIGHT = USED_HEIGHT + HEIGHT + MARGIN

        if (USED_HEIGHT + HEIGHT + MARGIN) > WINDOW_SIZE then
            USED_HEIGHT = 0
            USED_WIDTH = USED_WIDTH + WIDTH + MARGIN
        end
    end

    for i = 1, 40 do
        local frameHasBeenPlace = false

        for k, v in pairs(sorted) do
            local n = "GwCompactraid" .. i
            local np = "GwCompactparty" .. i
            local sn = "GwCompact" .. v
            if n == sn or np == sn then
                frameHasBeenPlace = true
            end
        end
        if not frameHasBeenPlace then
            if i < 5 then
                _G["GwCompactparty" .. i]:SetPoint("TOPLEFT", GwRaidFrameContainer, "TOPLEFT", USED_WIDTH, -USED_HEIGHT)
                _G["GwCompactparty" .. i]:SetSize(WIDTH, HEIGHT)
                _G["GwCompactparty" .. i].healthbar.spark:SetHeight(sparkHeight)
            end
            _G["GwCompactraid" .. i]:SetPoint("TOPLEFT", GwRaidFrameContainer, "TOPLEFT", USED_WIDTH, -USED_HEIGHT)
            _G["GwCompactraid" .. i]:SetSize(WIDTH, HEIGHT)
            _G["GwCompactraid" .. i].healthbar.spark:SetHeight(sparkHeight)

            USED_HEIGHT = USED_HEIGHT + HEIGHT + MARGIN

            if (USED_HEIGHT + HEIGHT + MARGIN) > WINDOW_SIZE then
                USED_HEIGHT = 0
                USED_WIDTH = USED_WIDTH + WIDTH + MARGIN
            end
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
    frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", registerUnit)
    frame:RegisterUnitEvent("UNIT_PHASE", registerUnit)
    frame:RegisterUnitEvent("UNIT_AURA", registerUnit)
    frame:RegisterUnitEvent("UNIT_LEVEL", registerUnit)
    frame:RegisterUnitEvent("UNIT_TARGET", registerUnit)
    frame:RegisterUnitEvent("UNIT_NAME_UPDATE", registerUnit)

    raidframe_OnEvent(frame, "load")

    if GetSetting("RAID_POWER_BARS") == true then
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

    GwRaidFrameContainer:SetHeight((GetSetting("RAID_HEIGHT") + 2) * GetSetting("RAID_UNITS_PER_COLUMN"))

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
            anchor = (GW.IsIn("DOWN", g1, g2) and "TOP" or "BOTTOM") .. (GW.IsIn("RIGHT", g1, g2) and "LEFT" or "RIGHT")
        end
    
        if anchor ~= "POSITION" then
            x = anchor:sub(-5) == "RIGHT" and frame:GetRight() - GetScreenWidth() or anchor:sub(-4) == "LEFT" and frame:GetLeft() or frame:GetLeft() + (frame:GetWidth() - GetScreenWidth()) / 2
            y = anchor:sub(1, 3) == "TOP" and frame:GetTop() - GetScreenHeight() or anchor:sub(1, 6) == "BOTTOM" and frame:GetBottom() or frame:GetBottom() + (frame:GetHeight() - GetScreenHeight()) / 2
    
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