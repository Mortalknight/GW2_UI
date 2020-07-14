local _, GW = ...
local L = GW.L
local TimeCount = GW.TimeCount
local PowerBarColorCustom = GW.PowerBarColorCustom
local GetSetting = GW.GetSetting
local DEBUFF_COLOR = GW.DEBUFF_COLOR
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local Bar = GW.Bar
local SetClassIcon = GW.SetClassIcon
local AddToAnimation = GW.AddToAnimation
local AddToClique =GW.AddToClique
local CommaValue = GW.CommaValue
local RoundDec = GW.RoundDec
local IsIn = GW.IsIn
local nameRoleIcon = GW.nameRoleIcon

local GW_READY_CHECK_INPROGRESS = false

local GW_PORTRAIT_BACKGROUND = {}
GW_PORTRAIT_BACKGROUND[1] = {l = 0, r = 0.828, t = 0, b = 0.166015625}
GW_PORTRAIT_BACKGROUND[2] = {l = 0, r = 0.828, t = 0.166015625, b = 0.166015625 * 2}
GW_PORTRAIT_BACKGROUND[3] = {l = 0, r = 0.828, t = 0.166015625 * 2, b = 0.166015625 * 3}
GW_PORTRAIT_BACKGROUND[4] = {l = 0, r = 0.828, t = 0.166015625 * 3, b = 0.166015625 * 4}
GW_PORTRAIT_BACKGROUND[5] = {l = 0, r = 0.828, t = 0.166015625 * 4, b = 0.166015625 * 5}

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

    local fnGWMM_OnLoad = function(self)
        if GetSetting("WORLD_MARKER_FRAME") and ((IsInGroup() and GetSetting("RAID_STYLE_PARTY")) or IsInRaid()) and
                (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
            self:Show()
        else
            self:Hide()
        end
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
        self:RegisterEvent("RAID_ROSTER_UPDATE")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        _G[self:GetName() .. "Ground"]:SetFont(UNIT_NAME_FONT, 14)
        _G[self:GetName() .. "Ground"]:SetTextColor(255 / 255, 241 / 255, 209 / 255)
        _G[self:GetName() .. "Ground"]:SetText(L["GROUND_MARKER"])
    end
    local fnGWMM_OnEvent = function(self)
        local inCombat = UnitAffectingCombat("player")
        if GetSetting("WORLD_MARKER_FRAME") and ((IsInGroup() and GetSetting("RAID_STYLE_PARTY")) or IsInRaid()) and
                (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
            manageButtonDelay(inCombat, "show")
        else
            manageButtonDelay(inCombat, "hide")
        end
    end
    local fmGWMM = CreateFrame("Frame", "GwWorldMarkerManage", UIParent, "GwWorldMarkerManage")
    fmGWMM:SetScript("OnEvent", fnGWMM_OnEvent)
    fnGWMM_OnLoad(fmGWMM)

    GwButtonInviteToParty:SetText(PARTY_INVITE)
    GwManageGroupLeaveButton:SetText(EXIT)
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

    for i = 1, 9 do
        if i < 9 then
            local f = CreateFrame("Button", "GwRaidGroundMarkerButton" .. i, GwWorldMarkerManage, "GwRaidGroundMarkerButton")
            f:SetScript("OnEnter", fnF_OnEnter)
            f:SetScript("OnLeave", fnF_OnLeave)
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", GwWorldMarkerManage, "TOPLEFT", xx, yy)
            f:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\GM_" .. i)
            f:SetAttribute("type", "macro")
            f:SetAttribute("macrotext", "/wm " .. i)
        else
            local f = CreateFrame("Button", "GwRaidGroundMarkerButton" .. i, GwWorldMarkerManage, "GwRaidGroundMarkerButton")
            f:SetScript("OnEnter", fnF_OnEnter)
            f:SetScript("OnLeave", fnF_OnLeave)
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", GwWorldMarkerManage, "TOPLEFT", xx, yy)
            f:SetNormalTexture("Interface\\BUTTONS\\UI-GROUPLOOT-PASS-DOWN")
            f:SetAttribute("type", "macro")
            f:SetAttribute("macrotext", "/cwm 9")
        end

        yy = yy + -37
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

    local _, _, _, instanceID = UnitPosition(self.unit)
    local _, _, _, playerinstanceID = UnitPosition("player")
    if not GW_READY_CHECK_INPROGRESS then 
        self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons")
        SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))
    end

    if playerinstanceID ~= instanceID then
        portraitIndex = 2
    end

    if not UnitInPhase(self.unit) or UnitIsWarModePhased(self.unit) then
        portraitIndex = 4
    end

    if UnitHasIncomingResurrection(self.unit) then
        self.classicon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
    end

    if C_IncomingSummon.HasIncomingSummon(self.unit) then
        local status = C_IncomingSummon.IncomingSummonStatus(self.unit)
        if status == Enum.SummonStatus.Pending then
            self.classicon:SetAtlas("Raid-Icon-SummonPending")
        elseif status == Enum.SummonStatus.Accepted then
            self.classicon:SetAtlas("Raid-Icon-SummonAccepted")
        elseif status == Enum.SummonStatus.Declined then
            self.classicon:SetAtlas("Raid-Icon-SummonDeclined")
        end
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
    end

    if not UnitIsConnected(self.unit) then
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

    if UnitThreatSituation(self.unit) ~= nil and UnitThreatSituation(self.unit) > 2 then
        portraitIndex = 5
    end
    
    setPortrait(self, portraitIndex)
end
GW.AddForProfiling("party", "updateAwayData", updateAwayData)

local function getUnitDebuffs(unit)
    local show_debuffs = GetSetting("PARTY_SHOW_DEBUFFS")
    local only_dispellable_debuffs = GetSetting("PARTY_ONLY_DISPELL_DEBUFFS")
    local show_importend_raid_instance_debuffs = GetSetting("PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF")
    local counter = 1

    DebuffLists[unit] = {}
    for i = 1, 40 do
        if UnitDebuff(unit, i, "HARMFUL") then
            local debuffName, icon, count, debuffType, duration, expires, caster, isStealable, shouldConsolidate, spellId = UnitDebuff(unit, i, "HARMFUL")
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
                DebuffLists[unit][counter] = {}
                
                DebuffLists[unit][counter]["name"] = debuffName
                DebuffLists[unit][counter]["icon"] = icon
                DebuffLists[unit][counter]["count"] = count
                DebuffLists[unit][counter]["dispelType"] = debuffType
                DebuffLists[unit][counter]["duration"] = duration
                DebuffLists[unit][counter]["expires"] = expires
                DebuffLists[unit][counter]["caster"] = caster
                DebuffLists[unit][counter]["isStealable"] = isStealable
                DebuffLists[unit][counter]["shouldConsolidate"] = shouldConsolidate
                DebuffLists[unit][counter]["spellID"] = spellId
                DebuffLists[unit][counter]["key"] = i
                DebuffLists[unit][counter]["timeRemaining"] = duration <= 0 and 500000 or expires - GetTime()

                counter = counter  + 1
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
            if x > 8 then
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
    if (self.healPredictionAmount ~= nil or self.healPredictionAmount == 0) and healthMax~=0 then
        predictionPrecentage = math.min(healthPrec + (self.healPredictionAmount / healthMax), 1)
    end
    setHealPrediction(self, predictionPrecentage)
    setHealthValue(self, health, healthMax, healthPrec)
    Bar(self.healthbar, healthPrec)
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
    self.predictionbar:SetValue(predictionPrecentage)

    self.powerbar:SetValue(powerPrecentage)
    setHealth(self)
    setUnitName(self)
    updateAwayData(self)

    self.level:SetText(UnitLevel(self.unit))

    SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))

    updatePartyAuras(self, self.unit)
end
GW.AddForProfiling("party", "updatePartyData", updatePartyData)

local function party_OnEvent(self, event, unit, arg1)
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
    if event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH_FREQUENT" and unit == self.unit then
        setHealth(self)
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" and unit == self.unit then
        local power = UnitPower(self.unit, UnitPowerType(self.unit))
        local powerMax = UnitPowerMax(self.unit, UnitPowerType(self.unit))
        local powerPrecentage = 0
        if powerMax > 0 then
            powerPrecentage = power / powerMax
        end
        self.powerbar:SetValue(powerPrecentage)
    elseif IsIn(event, "UNIT_LEVEL", "GROUP_ROSTER_UPDATE", "UNIT_MODEL_CHANGED") then
        updatePartyData(self)
    elseif event == "UNIT_HEAL_PREDICTION" and unit == self.unit then
        setPredictionAmount(self)
    elseif IsIn(event,"UNIT_PHASE", "PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE", "UNIT_THREAT_SITUATION_UPDATE", "INCOMING_RESURRECT_CHANGED", "INCOMING_SUMMON_CHANGED") then
        updateAwayData(self)
    elseif event == "UNIT_NAME_UPDATE" and unit == self.unit then
        setUnitName(self)
    elseif event == "UNIT_AURA" and unit == self.unit then
        updatePartyAuras(self, self.unit)
    elseif event == "READY_CHECK" then
        self.ready = -1
        GW_READY_CHECK_INPROGRESS = true
        updateAwayData(self)
        self.classicon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\readycheck")
    elseif event == "READY_CHECK_CONFIRM" and unit == self.unit then
        self.ready = arg1
        updateAwayData(self)
    elseif event == "READY_CHECK_FINISHED" then
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
                    SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))
                end
            end
        )
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
        RegisterStateDriver(
        frame,
        "visibility",
        "[group:raid] hide; [group:party] show; hide"
    )
    end
    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyUp")

    frame:SetScript("OnLeave", GameTooltip_Hide)
    frame:SetScript(
        "OnEnter",
        function()
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
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("INCOMING_RESURRECT_CHANGED")
    frame:RegisterEvent("INCOMING_SUMMON_CHANGED")

    frame:RegisterUnitEvent("UNIT_AURA", registerUnit)
    frame:RegisterUnitEvent("UNIT_LEVEL", registerUnit)
    frame:RegisterUnitEvent("UNIT_PHASE", registerUnit)
    frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", registerUnit)
    frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", registerUnit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", registerUnit)
    frame:RegisterUnitEvent("UNIT_NAME_UPDATE", registerUnit)
    frame:RegisterUnitEvent("UNIT_MODEL_CHANGED", registerUnit)
    frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", registerUnit)
    frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", registerUnit)

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
