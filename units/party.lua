local _, GW = ...
local TimeCount = GW.TimeCount
local PowerBarColorCustom = GW.PowerBarColorCustom
local GetSetting = GW.GetSetting
local DEBUFF_COLOR = GW.DEBUFF_COLOR
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local Bar = GW.Bar
local SetClassIcon = GW.SetClassIcon
local AddToAnimation = GW.AddToAnimation
local AddToClique =GW.AddToClique

local GW_READY_CHECK_INPROGRESS = false

local GW_PORTRAIT_BACKGROUND = {}
GW_PORTRAIT_BACKGROUND[1] = {l = 0, r = 0.828, t = 0, b = 0.166015625}
GW_PORTRAIT_BACKGROUND[2] = {l = 0, r = 0.828, t = 0.166015625, b = 0.166015625 * 2}
GW_PORTRAIT_BACKGROUND[3] = {l = 0, r = 0.828, t = 0.166015625 * 2, b = 0.166015625 * 3}
GW_PORTRAIT_BACKGROUND[4] = {l = 0, r = 0.828, t = 0.166015625 * 3, b = 0.166015625 * 4}

local buffLists = {}
local DebuffLists = {}

local function inviteToGroup(str)
    InviteUnit(str)
end
GW.AddForProfiling("party", "inviteToGroup", inviteToGroup)

local function manageButtonDelay(inCombat, action)
    if inCombat == true then
        GwWorldMarkerManage:SetScript(
            "OnUpdate",
            function()
                local inCombat2 = UnitAffectingCombat("player")
                if inCombat2 == true then
                    return
                end
                manageButtonDelay(false, action)
                GwWorldMarkerManage:SetScript("OnUpdate", nil)
            end
        )
    else
        if action == "hide" then
            GwWorldMarkerManage:Hide()
        elseif action == "show" then
            GwWorldMarkerManage:Show()
        end
    end
end
GW.AddForProfiling("party", "manageButtonDelay", manageButtonDelay)

local function manageButton()
    local fmGMGB = CreateFrame("Button", "GwManageGroupButton", UIParent, "GwManageGroupButton")
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
    fmGMGB:SetScript("OnClick", fnGMGB_OnClick)
    fmGMGB:SetScript("OnEnter", fnGMGB_OnEnter)
    fmGMGB:SetScript("OnLeave", fnGMGB_OnLeave)

    CreateFrame("Frame", "GwGroupManage", UIParent, "GwGroupManage")
    local fmGMGIB = GwManageGroupInviteBox
    local fmGBITP = GwButtonInviteToParty
    local fmGMGLB = GwManageGroupLeaveButton
    local fmGGRC = GwGroupReadyCheck
    local fmGGRlC = GwGroupRoleCheck
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

    local fnGGRlC_OnEvent = function(self, event, ...)
        if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
            self:Enable()
        else
            self:Disable()
        end
    end
    local fnGGRlC_OnClick = function(self, button)
        InitiateRolePoll()
    end
    fmGGRlC:SetScript("OnEvent", fnGGRlC_OnEvent)
    fmGGRlC:SetScript("OnClick", fnGGRlC_OnClick)
    fmGGRlC:RegisterEvent("GROUP_ROSTER_UPDATE")
    fmGGRlC:RegisterEvent("RAID_ROSTER_UPDATE")

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
            GwManageGroupButton.icon:SetTexCoord(0, 0.59375, 0.2968, 0.2968 * 2)
        else
            GwManageGroupButton.icon:SetTexCoord(0, 0.59375, 0, 0.2968)
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
            GwManageGroupButton.icon:SetTexCoord(0, 0.59375, 0.2968, 0.2968 * 2)
        else
            GwManageGroupButton.icon:SetTexCoord(0, 0.59375, 0, 0.2968)
        end
    end
    fmGMIG:SetScript("OnEvent", fnGMIG_OnEvent)
    fnGMIG_OnLoad(fmGMIG)


    GwButtonInviteToParty:SetText(PARTY_INVITE)
    GwManageGroupLeaveButton:SetText(PARTY_LEAVE)
    GwGroupReadyCheck:SetText(QUEUED_STATUS_READY_CHECK_IN_PROGRESS)
    GwGroupRoleCheck:SetText(QUEUED_STATUS_ROLE_CHECK_IN_PROGRESS)

    tinsert(UISpecialFrames, "GwGroupManage")
    local x = 10
    local y = -30

    local xx = 1
    local yy = -30

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
                SetRaidTarget("target", i)
            end
        )

        x = x + 61
        if i == 4 then
            y = y + -55
            x = 10
        end
    end
end
GW.AddForProfiling("party", "manageButton", manageButton)

local function setPortrait(self, index)
    self.portraitBackground:SetTexCoord(
        GW_PORTRAIT_BACKGROUND[index].l,
        GW_PORTRAIT_BACKGROUND[index].r,
        GW_PORTRAIT_BACKGROUND[index].t,
        GW_PORTRAIT_BACKGROUND[index].b
    )
end
GW.AddForProfiling("party", "setPortrait", setPortrait)

local function updateAwayData(self)
    local portraitIndex = 1

    posY, posX, posZ, instanceID = UnitPosition(self.unit)
    _, _, _, playerinstanceID = UnitPosition("player")
    if not GW_READY_CHECK_INPROGRESS then 
        self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons")
        _, _, classIndex = UnitClass(self.unit)
        if classIndex ~= nil and classIndex ~= 0 then
            SetClassIcon(self.classicon, classIndex)
        end
    end

    if playerinstanceID ~= instanceID then
        portraitIndex = 2
    end

    if not UnitInPhase(self.unit) then
        portraitIndex = 4
        self.classicon:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
        self.classicon:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
    end
    if UnitIsConnected(self.unit) ~= true then
        portraitIndex = 3
    end

    if portraitIndex == 1 then
        SetPortraitTexture(self.portrait, self.unit)
        if self.portrait:GetTexture() == nil then
            portraitIndex = 2
        end
    else
        self.portrait:SetTexture(nil)
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

    setPortrait(self, portraitIndex)
end
GW.AddForProfiling("party", "updateAwayData", updateAwayData)

local function getUnitDebuffs(unit)
    DebuffLists[unit] = {}
    for i = 1, 40 do
        if UnitDebuff(unit, i) then
            DebuffLists[unit][i] = {}
            DebuffLists[unit][i]["name"],
                DebuffLists[unit][i]["icon"],
                DebuffLists[unit][i]["count"],
                DebuffLists[unit][i]["dispelType"],
                DebuffLists[unit][i]["duration"],
                DebuffLists[unit][i]["expires"],
                DebuffLists[unit][i]["caster"],
                DebuffLists[unit][i]["isStealable"],
                DebuffLists[unit][i]["shouldConsolidate"],
                DebuffLists[unit][i]["spellID"] = UnitDebuff(unit, i)
            DebuffLists[unit][i]["key"] = i
            DebuffLists[unit][i]["timeRemaining"] = DebuffLists[unit][i]["expires"] - GetTime()
            if DebuffLists[unit][i]["duration"] <= 0 then
                DebuffLists[unit][i]["timeRemaining"] = 500000
            end
        end
    end

    table.sort(
        DebuffLists[unit],
        function(a, b)
            return a["timeRemaining"] < b["timeRemaining"]
        end
    )
end
GW.AddForProfiling("party", "getUnitDebuffs", getUnitDebuffs)

local function updatePartyDebuffs(self, unit, x, y)
    if x ~= 0 then
        y = y + 1
    end
    x = 0
    getUnitDebuffs(unit)

    for i = 1, 40 do
        local indexBuffFrame = _G["Gw" .. unit .. "DebuffItemFrame" .. i]
        if DebuffLists[unit][i] then
            local key = DebuffLists[unit][i]["key"]

            if indexBuffFrame == nil then
                indexBuffFrame =
                    CreateFrame(
                    "Frame",
                    "Gw" .. unit .. "DebuffItemFrame" .. i,
                    _G[self:GetName() .. "Auras"],
                    "GwDeBuffIcon"
                )
                indexBuffFrame:SetParent(_G[self:GetName() .. "Auras"])

                _G["Gw" .. unit .. "DebuffItemFrame" .. i .. "DeBuffBackground"]:SetVertexColor(
                    COLOR_FRIENDLY[2].r,
                    COLOR_FRIENDLY[2].g,
                    COLOR_FRIENDLY[2].b
                )
                _G["Gw" .. unit .. "DebuffItemFrame" .. i .. "Cooldown"]:SetDrawEdge(0)
                _G["Gw" .. unit .. "DebuffItemFrame" .. i .. "Cooldown"]:SetDrawSwipe(1)
                _G["Gw" .. unit .. "DebuffItemFrame" .. i .. "Cooldown"]:SetReverse(1)
                _G["Gw" .. unit .. "DebuffItemFrame" .. i .. "Cooldown"]:SetHideCountdownNumbers(true)
                indexBuffFrame:SetSize(24, 24)
            end
            _G["Gw" .. unit .. "DebuffItemFrame" .. i .. "IconBuffIcon"]:SetTexture(DebuffLists[unit][i]["icon"])
            _G["Gw" .. unit .. "DebuffItemFrame" .. i .. "IconBuffIcon"]:SetParent(
                _G["Gw" .. unit .. "DebuffItemFrame" .. i]
            )
            local buffDur = ""
            local stacks = ""
            if DebuffLists[unit][i]["count"] > 1 then
                stacks = DebuffLists[unit][i]["count"]
            end
            if DebuffLists[unit][i]["duration"] > 0 then
                buffDur = TimeCount(DebuffLists[unit][i]["timeRemaining"])
            end
            indexBuffFrame.expires = DebuffLists[unit][i]["expires"]
            indexBuffFrame.duration = DebuffLists[unit][i]["duration"]

            _G["Gw" .. unit .. "DebuffItemFrame" .. i .. "DeBuffBackground"]:SetVertexColor(
                COLOR_FRIENDLY[2].r,
                COLOR_FRIENDLY[2].g,
                COLOR_FRIENDLY[2].b
            )
            if DebuffLists[unit][i]["dispelType"] ~= nil and DEBUFF_COLOR[DebuffLists[unit][i]["dispelType"]] ~= nil then
                _G["Gw" .. unit .. "DebuffItemFrame" .. i .. "DeBuffBackground"]:SetVertexColor(
                    DEBUFF_COLOR[DebuffLists[unit][i]["dispelType"]].r,
                    DEBUFF_COLOR[DebuffLists[unit][i]["dispelType"]].g,
                    DEBUFF_COLOR[DebuffLists[unit][i]["dispelType"]].b
                )
            end

            _G["Gw" .. unit .. "DebuffItemFrame" .. i .. "CooldownBuffDuration"]:SetText(buffDur)
            _G["Gw" .. unit .. "DebuffItemFrame" .. i .. "IconBuffStacks"]:SetText(stacks)
            indexBuffFrame:ClearAllPoints()
            indexBuffFrame:SetPoint("BOTTOMRIGHT", (26 * x), 26 * y)

            indexBuffFrame:SetScript(
                "OnEnter",
                function()
                    GameTooltip:SetOwner(indexBuffFrame, "ANCHOR_BOTTOMLEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:SetUnitDebuff(unit, key)
                    GameTooltip:Show()
                end
            )
            indexBuffFrame:SetScript("OnLeave", GameTooltip_Hide)

            indexBuffFrame:Show()

            x = x + 1
            if x > 8 then
                y = y + 1
                x = 0
            end
        else
            if indexBuffFrame ~= nil then
                indexBuffFrame:Hide()
            end
        end
    end
end
GW.AddForProfiling("party", "updatePartyDebuffs", updatePartyDebuffs)

local function getUnitBuffs(unit)
    buffLists[unit] = {}
    for i = 1, 40 do
        if UnitBuff(unit, i) then
            buffLists[unit][i] = {}
            buffLists[unit][i]["name"],
                buffLists[unit][i]["icon"],
                buffLists[unit][i]["count"],
                buffLists[unit][i]["dispelType"],
                buffLists[unit][i]["duration"],
                buffLists[unit][i]["expires"],
                buffLists[unit][i]["caster"],
                buffLists[unit][i]["isStealable"],
                buffLists[unit][i]["shouldConsolidate"],
                buffLists[unit][i]["spellID"] = UnitBuff(unit, i)
            buffLists[unit][i]["key"] = i
            buffLists[unit][i]["timeRemaining"] = buffLists[unit][i]["expires"] - GetTime()
            if buffLists[unit][i]["duration"] <= 0 then
                buffLists[unit][i]["timeRemaining"] = 500000
            end
        end
    end

    table.sort(
        buffLists[unit],
        function(a, b)
            return a["timeRemaining"] > b["timeRemaining"]
        end
    )
end
GW.AddForProfiling("party", "getUnitBuffs", getUnitBuffs)

local function updatePartyAuras(self, unit)
    local x = 0
    local y = 0

    getUnitBuffs(unit)
    local fname = self:GetName()

    for i = 1, 40 do
        local indexBuffFrame = _G["Gw" .. unit .. "BuffItemFrame" .. i]
        if buffLists[unit][i] then
            local key = buffLists[unit][i]["key"]
            if indexBuffFrame == nil then
                indexBuffFrame =
                    CreateFrame(
                    "Button",
                    "Gw" .. unit .. "BuffItemFrame" .. i,
                    _G[self:GetName() .. "Auras"],
                    "GwBuffIconBig"
                )
                indexBuffFrame:RegisterForClicks("RightButtonUp")
                _G[indexBuffFrame:GetName() .. "BuffDuration"]:SetFont(UNIT_NAME_FONT, 11)
                _G[indexBuffFrame:GetName() .. "BuffDuration"]:SetTextColor(1, 1, 1)
                _G[indexBuffFrame:GetName() .. "BuffStacks"]:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
                _G[indexBuffFrame:GetName() .. "BuffStacks"]:SetTextColor(1, 1, 1)
                indexBuffFrame:SetParent(_G[fname .. "Auras"])
                indexBuffFrame:SetSize(20, 20)
            end
            local margin = -indexBuffFrame:GetWidth() + -2
            local marginy = indexBuffFrame:GetWidth() + 12
            _G["Gw" .. unit .. "BuffItemFrame" .. i .. "BuffIcon"]:SetTexture(buffLists[unit][i]["icon"])
            _G["Gw" .. unit .. "BuffItemFrame" .. i .. "BuffIcon"]:SetParent(_G["Gw" .. unit .. "BuffItemFrame" .. i])
            local buffDur = ""
            local stacks = ""
            if buffLists[unit][i]["duration"] > 0 then
                buffDur = TimeCount(buffLists[unit][i]["timeRemaining"])
            end
            if buffLists[unit][i]["count"] > 1 then
                stacks = buffLists[unit][i]["count"]
            end
            indexBuffFrame.expires = buffLists[unit][i]["expires"]
            indexBuffFrame.duration = buffLists[unit][i]["duration"]
            _G["Gw" .. unit .. "BuffItemFrame" .. i .. "BuffDuration"]:SetText("")
            _G["Gw" .. unit .. "BuffItemFrame" .. i .. "BuffStacks"]:SetText(stacks)
            indexBuffFrame:ClearAllPoints()
            indexBuffFrame:SetPoint("BOTTOMRIGHT", (-margin * x), marginy * y)

            indexBuffFrame:SetScript(
                "OnEnter",
                function()
                    GameTooltip:SetOwner(indexBuffFrame, "ANCHOR_BOTTOMLEFT", 28, 0)
                    GameTooltip:ClearLines()
                    GameTooltip:SetUnitBuff(unit, key)
                    GameTooltip:Show()
                end
            )
            indexBuffFrame:SetScript("OnLeave", GameTooltip_Hide)

            indexBuffFrame:Show()

            x = x + 1
            if x > 7 then
                y = y + 1
                x = 0
            end
        else
            if indexBuffFrame ~= nil then
                indexBuffFrame:Hide()
                indexBuffFrame:SetScript("OnEnter", nil)
                indexBuffFrame:SetScript("OnClick", nil)
                indexBuffFrame:SetScript("OnLeave", nil)
            end
        end
    end
    updatePartyDebuffs(self, unit, x, y)
end
GW.AddForProfiling("party", "updatePartyAuras", updatePartyAuras)

local function setUnitName(self)
    local nameString = UnitName(self.unit)

    if not nameString or nameString == UNKNOWNOBJECT then
        self.nameNotLoaded = false
    else
        self.nameNotLoaded = true
    end    
    self.name:SetText(nameString)
end
GW.AddForProfiling("party", "setUnitName", setUnitName)

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
    powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.powerbar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end

    if powerMax > 0 then
        powerPrecentage = power / powerMax
    end
    if healthMax > 0 then
        healthPrec = health / healthMax
    end
    Bar(self.healthbar, healthPrec)
    self.powerbar:SetValue(powerPrecentage)

    updateAwayData(self)
    setUnitName(self)

    self.level:SetText(UnitLevel(self.unit))

    localizedClass, englishClass, classIndex = UnitClass(self.unit)
    if classIndex ~= nil and classIndex ~= 0 then
        SetClassIcon(self.classicon, classIndex)
    end

    updatePartyAuras(self, self.unit)
end
GW.AddForProfiling("party", "updatePartyData", updatePartyData)

local function party_OnEvent(self, event, unit, arg1)
    if not UnitExists(self.unit) then
        return
    end
    if IsInRaid() then
        return
    end

    if not self.nameNotLoaded then
        setUnitName(self)
    end

    if event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" and unit == self.unit then
        local health = UnitHealth(self.unit)
        local healthMax = UnitHealthMax(self.unit)
        local healthPrec = 0
        if healthMax > 0 then
            healthPrec = health / healthMax
        end
        Bar(self.healthbar, healthPrec)
    end
    if event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" and unit == self.unit then
        local power = UnitPower(self.unit, UnitPowerType(self.unit))
        local powerMax = UnitPowerMax(self.unit, UnitPowerType(self.unit))
        local powerPrecentage = 0
        if powerMax > 0 then
            powerPrecentage = power / powerMax
        end
        self.powerbar:SetValue(powerPrecentage)
    end
    if event == "UNIT_LEVEL" or event == "GROUP_ROSTER_UPDATE" or event == "UNIT_MODEL_CHANGED" then
        updatePartyData(self)
    end
    if event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" then
        updateAwayData(self)
    end
    if event == "UNIT_NAME_UPDATE" and unit == self.unit then
        setUnitName(self)
    end
    if event == "UNIT_AURA" and unit == self.unit then
        updatePartyAuras(self, self.unit)
    end

    if event == "READY_CHECK" then
        self.ready = -1
        GW_READY_CHECK_INPROGRESS = true
        updateAwayData(self)
        self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\readycheck")
    end

    if event == "READY_CHECK_CONFIRM" and unit == self.unit then
        self.ready = arg1
        updateAwayData(self)
    end

    if event == "READY_CHECK_FINISHED" then
        GW_READY_CHECK_INPROGRESS = false
        AddToAnimation(
            "ReadyCheckPartyWait" .. self.unit,
            0,
            1,
            GetTime(),
            2,
            function()
            end,
            nil,
            function()
                if UnitInParty(self.unit) ~= nil then
                    self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons")
                    localizedClass, englishClass, classIndex = UnitClass(self.unit)
                    if classIndex ~= nil and classIndex ~= 0 then
                        SetClassIcon(self.classicon, classIndex)
                    end
                end
            end
        )
    end
end
GW.AddForProfiling("party", "party_OnEvent", party_OnEvent)

local function TogglePartyRaid(b)
    if b == true and not IsInRaid() then
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
    local registerUnit = "party" .. i
    --  registerUnit = 'player'

    local frame = CreateFrame("Button", "GwPartyFrame" .. i, UIParent, "GwPartyFrame")
    frame.name:SetFont(UNIT_NAME_FONT, 12)
    frame.name:SetShadowOffset(-1, -1)
    frame.name:SetShadowColor(0, 0, 0, 1)
    frame.level:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINED")
    frame:SetScript("OnEvent", party_OnEvent)

    frame:SetPoint("TOPLEFT", 20, -104 + (-85 * i) + 85)

    frame.unit = registerUnit
    frame.ready = -1
    frame.nameNotLoaded = false

    frame:SetAttribute("unit", registerUnit)
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")

    RegisterUnitWatch(frame)
    frame:EnableMouse(true)
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp", "Button4Up", "Button5Up", "MiddleButtonUp")

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
    
    frame:RegisterUnitEvent("UNIT_MODEL_CHANGED", registerUnit)
    frame:RegisterUnitEvent("UNIT_AURA", registerUnit)
    frame:RegisterUnitEvent("UNIT_LEVEL", registerUnit)
    frame:RegisterUnitEvent("UNIT_PHASE", registerUnit)
    frame:RegisterUnitEvent("UNIT_HEALTH", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", registerUnit)
    frame:RegisterUnitEvent("UNIT_POWER_UPDATE", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", registerUnit)
    frame:RegisterUnitEvent("UNIT_NAME_UPDATE", registerUnit)

    updatePartyData(frame)
end
GW.AddForProfiling("party", "createPartyFrame", createPartyFrame)

local function LoadPartyFrames()
    manageButton()

    SetCVar("useCompactPartyFrames", 1)

    if GetSetting("RAID_STYLE_PARTY") then
        return
    end

    createPartyFrame(1)
    createPartyFrame(2)
    createPartyFrame(3)
    createPartyFrame(4)

    GwPartyFrame1:SetPoint("TOPLEFT", 20, -104)
end
GW.LoadPartyFrames = LoadPartyFrames
