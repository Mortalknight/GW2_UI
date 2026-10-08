---@class GW2
local GW = select(2, ...)
local L = GW.L

local created = false

local LeaveParty = C_PartyInfo and C_PartyInfo.LeaveParty or LeaveParty
local ConvertToParty = C_PartyInfo and C_PartyInfo.ConvertToParty or ConvertToParty
local ConvertToRaid = C_PartyInfo and C_PartyInfo.ConvertToRaid or ConvertToRaid

local function fnGMIG_OnEvent(self)
    if InCombatLockdown() then
        GW.CombatQueue:Queue("GwGroupManageUpdate", fnGMIG_OnEvent, {self})
        return
    end
    local activ = (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) or (IsInGroup() and not IsInRaid())

    if IsInRaid() then
        GwManageGroupButton.icon:SetTexCoord(0, 0.59375, 0.2968, 0.2968 * 2)
    else
        GwManageGroupButton.icon:SetTexCoord(0, 0.59375, 0, 0.2968)
    end

    for _, marker in pairs(self.markers) do
        marker:SetEnabled(activ)
        marker:GetNormalTexture():SetDesaturated(not activ)
    end
    for _, marker in pairs(self.workdmarkers) do
        marker:GetNormalTexture():SetDesaturated(not activ)
    end

    self.convert:SetEnabled(UnitIsGroupLeader("player"))
    self.convert:SetText(IsInRaid() and CONVERT_TO_PARTY or CONVERT_TO_RAID)

    self.countdown:SetEnabled(activ)
    self.readyCheck:SetEnabled(activ)
    self.roleCheck:SetEnabled(activ)

    -- set counter
    local unit = (IsInRaid() and "raid" or "party")
    local numTank, numDamage, numHeal = 0, 0, 0
    for i = 1, GetNumGroupMembers() do
        local role = UnitGroupRolesAssigned(unit .. i)

        if GW.NotSecretValue(role) and role then
            if role == "TANK" then
                numTank = numTank + 1
            elseif role == "HEALER" then
                numHeal = numHeal + 1
            elseif role == "DAMAGER" then
                numDamage = numDamage + 1
            end
        end
    end

    if GetNumGroupMembers() == 0 or unit == "party" then
        if GW.myrole then
            if GW.myrole == "TANK" then
                numTank = numTank + 1
            elseif GW.myrole == "HEALER" then
                numHeal = numHeal + 1
            elseif GW.myrole == "DAMAGER" then
                numDamage = numDamage + 1
            end
        end
    end
    self.groupCounter:SetText("|TInterface/AddOns/GW2_UI/textures/party/roleicon-tank.png:0:0:0:2:64:64:4:60:4:60|t " .. numTank .. "    |TInterface/AddOns/GW2_UI/textures/party/roleicon-healer.png:0:0:0:2:64:64:4:60:4:60|t " .. numHeal .. "    |TInterface/AddOns/GW2_UI/textures/party/roleicon-dps.png:15:15:0:0:64:64:4:60:4:60|t " .. numDamage)
end

local function ToggleVisibility()
    if not created then return end
    if GW.settings.hud.fadeGroupManageButton then
        GwManageGroupButton.fadeOut()
    else
        GwManageGroupButton.fadeIn()
    end
end
GW.ToggleRaidControllFrame = ToggleVisibility

local function CreateRaidControlFrame()
    if created then return end
    created = true

    local GwGroupManage = CreateFrame("Frame", "GwGroupManage", UIParent, "GwGroupManage")
    local fmGMGB = CreateFrame("Button", "GwManageGroupButton", UIParent, "GwManageGroupButtonTmpl")

    fmGMGB:SetFrameRef("GroupManager", GwGroupManage)
    fmGMGB:SetAttribute("state", "closed")
    fmGMGB:SetAttribute("_onclick", [=[
        local ref = self:GetFrameRef("GroupManager")
        local state = self:GetAttribute("state")

        if state == "closed" then
            ref:Show()
            self:SetAttribute("state", "open")
            ref:SetAttribute("state", "open")
        else
            ref:Hide()
            self:SetAttribute("state","closed")
            ref:SetAttribute("state", "closed")
        end
    ]=])

    GwGroupManage:SetAttribute("maxHeight", not (GW.Classic or GW.TBC or GW.Wrath) and 450 or 320)
    GwGroupManage:SetFrameRef("GroupManagerGroup", GwGroupManage.inGroup)
    GwGroupManage:SetAttribute("_onshow", [=[
        local ref = self:GetFrameRef("GroupManagerGroup")
        local maxHeight = self:GetAttribute("maxHeight")

        if PlayerInGroup() ~= false then
            ref:Show()
            self:SetHeight(maxHeight)
        else
            ref:Hide()
            self:SetHeight(80)
        end
    ]=])
    GwGroupManage:SetAttribute("_onstate-barlayout", [=[
        local ref = self:GetFrameRef("GroupManagerGroup")
        local state = self:GetAttribute("state")
        local maxHeight = self:GetAttribute("maxHeight")

        if newstate == "show" and state == "open" then
            self:SetHeight(maxHeight)
            ref:Show()
        elseif newstate == "hide" and state == "open" then
            self:SetHeight(80)
            ref:Hide()
        end
    ]=])
    RegisterStateDriver(GwGroupManage, "barlayout", "[group:raid] show; [group:party] show; hide")

    local TextBox_OnEscapePressed = function(self)
        self:ClearFocus()
    end

    local inviteBox = GwGroupManage.groupInviteBox
    inviteBox.hint = inviteBox:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    inviteBox.hint:SetPoint("LEFT", inviteBox, "LEFT", 0, 0)
    inviteBox.hint:SetText(CALENDAR_PLAYER_NAME)
    inviteBox.hint:SetTextColor(1, 1, 1, 0.5)
    -- the hint over an empty box; the invite button stays enabled, the protected group frame hangs on it
    local function UpdateInviteHint(box)
        box.hint:SetShown(box:GetText() == "" and not box:HasFocus())
    end
    local function InviteTypedName(box)
        local name = strtrim(box:GetText())
        if name ~= "" then
            C_PartyInfo.InviteUnit(name)
        end
        box:SetText("")
        box:ClearFocus()
    end
    inviteBox:SetScript("OnEscapePressed", TextBox_OnEscapePressed)
    inviteBox:SetScript("OnEditFocusGained", UpdateInviteHint)
    inviteBox:SetScript("OnEditFocusLost", UpdateInviteHint)
    inviteBox:SetScript("OnTextChanged", UpdateInviteHint)
    inviteBox:SetScript("OnEnterPressed", InviteTypedName)
    UpdateInviteHint(inviteBox)

    GwGroupManage.inviteToParty:SetScript("OnClick", function(self)
        InviteTypedName(self:GetParent().groupInviteBox)
    end)

    GwGroupManage.groupLeaveButton:SetScript("OnClick", function()
        LeaveParty()
    end)

    local fnGGRC_OnClick = function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if GW.isModern and InCombatLockdown() then return end
        DoReadyCheck()
    end
    GwGroupManage.inGroup.readyCheck:SetScript("OnClick", fnGGRC_OnClick)
    GwGroupManage.inGroup.readyCheck.hover:SetTexture("Interface/AddOns/GW2_UI/textures/party/readycheck-button-hover.png")
    GwGroupManage.inGroup.readyCheck:GetFontString():SetTextColor(218 / 255, 214 / 255, 200 / 255)
    GwGroupManage.inGroup.readyCheck:GetFontString():SetShadowColor(0, 0, 0, 1)
    GwGroupManage.inGroup.readyCheck:GetFontString():SetShadowOffset(1, -1)
    GwGroupManage.inGroup.readyCheck:SetEnabled(UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))

    local fmGGCD_OnClick = function(_, button)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if IsControlKeyDown() and button == "LeftButton" and C_AddOns.IsAddOnLoaded("DBM-Core") then
            SlashCmdList.DEADLYBOSSMODSPULL(GW.settings.groupFrames.pullTimerSeconds)
        else
            if GW.isModern and InCombatLockdown() then return end
            C_PartyInfo.DoCountdown(GW.settings.groupFrames.pullTimerSeconds)
        end
    end

    GwGroupManage.inGroup.countdown:SetScript("OnClick", fmGGCD_OnClick)
    GwGroupManage.inGroup.countdown.hover:SetTexture("Interface/AddOns/GW2_UI/textures/party/readycheck-button-hover.png")
    GwGroupManage.inGroup.countdown:GetFontString():SetTextColor(218 / 255, 214 / 255, 200 / 255)
    GwGroupManage.inGroup.countdown:GetFontString():SetShadowColor(0, 0, 0, 1)
    GwGroupManage.inGroup.countdown:GetFontString():SetShadowOffset(1, -1)
    GwGroupManage.inGroup.countdown:SetEnabled(UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))

    GwGroupManage.inGroup.inputCountdownFrame.input:SetText(GW.settings.groupFrames.pullTimerSeconds)

    GwGroupManage.inGroup.inputCountdownFrame.input:SetScript("OnEscapePressed", TextBox_OnEscapePressed)
    GwGroupManage.inGroup.inputCountdownFrame.input:SetScript("OnEnterPressed", function(self)
        local roundValue = GW.RoundDec(self:GetNumber(), 0) or GW.settings.groupFrames.pullTimerSeconds
        self:ClearFocus()
        if tonumber(roundValue) == 0 then
            roundValue = GW.globalDefault.profile.groupFrames.pullTimerSeconds
        end
        GW.settings.groupFrames.pullTimerSeconds = tonumber(roundValue)
        self:SetText(roundValue)
    end)

    local fnGGRlC_OnClick = function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        InitiateRolePoll()
    end
    GwGroupManage.inGroup.roleCheck:SetScript("OnClick", fnGGRlC_OnClick)
    GwGroupManage.inGroup.roleCheck:GetFontString():SetShadowColor(0, 0, 0, 1)
    GwGroupManage.inGroup.roleCheck:SetEnabled(UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))

    local fnGGMC_OnClick = function()
        if GW.isModern and InCombatLockdown() then return end
        if IsInRaid() then
            ConvertToParty()
        else
            ConvertToRaid()
        end
    end
    GwGroupManage.inGroup.convert:SetScript("OnClick", fnGGMC_OnClick)
    GwGroupManage.inGroup.convert:GetFontString():SetShadowColor(0, 0, 0, 1)

    GwGroupManage.inGroup.header:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    GwGroupManage.inGroup.header2:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    GwGroupManage.inGroup.header2:SetText(WORLD_MARKER:format(0):gsub("%d", ""))

    GwGroupManage.inGroup.groupCounter:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)

    GwGroupManage.inGroup:RegisterEvent("GROUP_ROSTER_UPDATE")
    GwGroupManage.inGroup:RegisterEvent("RAID_ROSTER_UPDATE")
    GwGroupManage.inGroup:SetScript("OnEvent", fnGMIG_OnEvent)

    local fnF_OnEnter = function(self)
        self.texture:SetBlendMode("ADD")
    end
    local fnF_OnLeave = function(self)
        self.texture:SetBlendMode("BLEND")
    end

    local x, y, f = 15, -50, nil

    GwGroupManage.inGroup.markers = {}
    GwGroupManage.inGroup.workdmarkers = {}
    for i = 1, 8 do
        f = CreateFrame("Button", "GwRaidMarkerButton" .. i, GwGroupManage.inGroup, "GwRaidMarkerButton")
        f:SetScript("OnEnter", fnF_OnEnter)
        f:SetScript("OnLeave", fnF_OnLeave)

        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", GwGroupManage.inGroup, "TOPLEFT", x, y)
        f:SetNormalTexture("Interface/TargetingFrame/UI-RaidTargetingIcons")
        SetRaidTargetIconTexture(f:GetNormalTexture(), i)
        f:SetScript("OnClick", function()
            PlaySound(1115)
            -- blizzards SetRaidTargetIcon compares the secret current index, a second click only clears it when readable
            local current = GetRaidTargetIndex("target")
            SetRaidTarget("target", GW.NotSecretValue(current) and current == i and 0 or i)
        end)

        x = x + 44
        if i == 4 then
            y = y + -40
            x = 15
        end
        GwGroupManage.inGroup.markers[i] = f
    end

    if not (GW.Classic or GW.TBC or GW.Wrath) then
        GwGroupManage.inGroup.header2:Show()
        y = y + -65
        x = 15
        for i = 1, 9 do
            f = CreateFrame("Button", "GwWorldMarkerButton" .. i, GwGroupManage.inGroup, "GwRaidGroundMarkerButton")
            f:SetScript("OnEnter", fnF_OnEnter)
            f:SetScript("OnLeave", fnF_OnLeave)
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", GwGroupManage.inGroup, "TOPLEFT", x, y)
            f:SetNormalTexture(i < 9 and "Interface/AddOns/GW2_UI/textures/party/gm_" .. i .. ".png" or "Interface/BUTTONS/UI-GROUPLOOT-PASS-DOWN")
            f:SetAttribute("type", "macro")
            f:SetAttribute("macrotext", (i < 9 and "/wm " .. i or "/cwm 9"))
            f:RegisterForClicks("AnyUp", "AnyDown")

            x = x + 44
            if i == 4 or i == 8 then
                y = y + -40
                x = 15
            end
            GwGroupManage.inGroup.workdmarkers[i] = f
        end
    else
        GwGroupManage.inGroup.countdown:SetText(L["Countdown"])
        GwGroupManage.inGroup.readyCheck:ClearAllPoints()
        GwGroupManage.inGroup.readyCheck:SetPoint("TOPLEFT", GwGroupManage.inGroup.header2, "BOTTOMLEFT", -5, 0)
    end
    local fnGMGB_OnEnter = function(self)
        self.arrow:SetSize(21, 42)
        if GW.settings.hud.fadeGroupManageButton then
            if GwGroupManage:IsShown() then
                return
            end
            fmGMGB.fadeIn()
        end
    end
    local fnGMGB_OnLeave = function(self)
        self.arrow:SetSize(16, 32)
        if GW.settings.hud.fadeGroupManageButton then
            if GwGroupManage:IsShown() then
                return
            end
            fmGMGB.fadeOut()
        end
    end
    fmGMGB:SetScript("OnEnter", fnGMGB_OnEnter)
    fmGMGB:HookScript("OnLeave", fnGMGB_OnLeave)

    fnGMIG_OnEvent(GwGroupManage.inGroup)

    local fo = fmGMGB:CreateAnimationGroup("fadeOut")
    local fi = fmGMGB:CreateAnimationGroup("fadeIn")
    local fadeOut = fo:CreateAnimation("Alpha")
    local fadeIn = fi:CreateAnimation("Alpha")
    fo:SetScript("OnFinished", function(self)
        self:GetParent():SetAlpha(0)
    end)
    fi:SetScript("OnFinished", function(self)
        self:GetParent():SetAlpha(1)
    end)
    fadeOut:SetStartDelay(0.25)
    fadeOut:SetFromAlpha(1.0)
    fadeOut:SetToAlpha(0.0)
    fadeOut:SetDuration(0.15)
    fadeIn:SetFromAlpha(0.0)
    fadeIn:SetToAlpha(1.0)
    fadeIn:SetDuration(0.15)
    fmGMGB.fadeOut = function()
        fi:Stop()
        fo:Stop()
        fo:Play()
    end
    fmGMGB.fadeIn = function()
        fi:Stop()
        fo:Stop()
        fi:Play()
    end
    fmGMGB:SetAlpha(0)

    if GW.settings.hud.fadeGroupManageButton then
        fmGMGB.fadeOut()
    else
        fmGMGB.fadeIn()
    end
end
GW.CreateRaidControlFrame = CreateRaidControlFrame
