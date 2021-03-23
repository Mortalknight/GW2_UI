local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting

local function manageButtonDelay(self, setShown)
    if UnitAffectingCombat("player") then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        self:SetShown(setShown)
    end
end
GW.AddForProfiling("raidControl", "manageButtonDelay", manageButtonDelay)

local function manageButton()
    local GwGroupManage = CreateFrame("Frame", "GwGroupManage", UIParent, "GwGroupManage")
    local fmGMGB = CreateFrame("Frame", "GwManageGroupButton", UIParent, "GwManageGroupButtonTmpl")

    local fnGMGB_OnClick = function()
        if GwGroupManage:IsShown() then
            GwGroupManage:Hide()
        else
            GwGroupManage:Show()
        end
    end
    fmGMGB:SetScript("OnMouseDown", fnGMGB_OnClick)

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
        C_PartyInfo.InviteUnit(self:GetText())
        self:SetText("")
        self:ClearFocus()
    end
    GwGroupManage.groupInviteBox:SetScript("OnEscapePressed", fnGMGIB_OnEscapePressed)
    GwGroupManage.groupInviteBox:SetScript("OnEditFocusGained", fnGMGIB_OnEditFocusGained)
    GwGroupManage.groupInviteBox:SetScript("OnEditFocusLost", fnGMGIB_OnEditFocusLost)
    GwGroupManage.groupInviteBox:SetScript("OnEnterPressed", fnGMGIB_OnEnterPressed)
    local sT = GwGroupManage.groupInviteBox:GetText()
    if sT == nil or sT == "" then
        GwGroupManage.groupInviteBox:SetText(CALENDAR_PLAYER_NAME)
        GwGroupManage.groupInviteBox:SetTextColor(1, 1, 1, 0.5)
    end

    GwGroupManage.inviteToParty:SetScript("OnClick", function(self)
        C_PartyInfo.InviteUnit(self:GetParent().groupInviteBox:GetText())
        self:GetParent().groupInviteBox:SetText("")
        self:GetParent().groupInviteBox:ClearFocus()
    end)

    GwGroupManage.groupLeaveButton:SetScript("OnClick", function()
        C_PartyInfo.LeaveParty()
    end)

    local fmButtonSetActiceDeactive = function(self)
        if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
            self:Enable()
        else
            self:Disable()
        end
    end
    local fnGGRC_OnClick = function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        DoReadyCheck()
    end
    GwGroupManage.inGroup.readyCheck:SetScript("OnEvent", fmButtonSetActiceDeactive)
    GwGroupManage.inGroup.readyCheck:SetScript("OnClick", fnGGRC_OnClick)
    GwGroupManage.inGroup.readyCheck.hover:SetTexture("Interface/AddOns/GW2_UI/textures/party/readycheck-button-hover")
    GwGroupManage.inGroup.readyCheck:GetFontString():SetTextColor(218 / 255, 214 / 255, 200 / 255)
    GwGroupManage.inGroup.readyCheck:GetFontString():SetShadowColor(0, 0, 0, 1)
    GwGroupManage.inGroup.readyCheck:GetFontString():SetShadowOffset(1, -1)
    GwGroupManage.inGroup.readyCheck:RegisterEvent("GROUP_ROSTER_UPDATE")
    GwGroupManage.inGroup.readyCheck:RegisterEvent("RAID_ROSTER_UPDATE")

    local fmGGCD_OnClick = function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        C_PartyInfo.DoCountdown(10)
    end

    GwGroupManage.inGroup.countdown:SetScript("OnEvent", fmButtonSetActiceDeactive)
    GwGroupManage.inGroup.countdown:SetScript("OnClick", fmGGCD_OnClick)
    GwGroupManage.inGroup.countdown.hover:SetTexture("Interface/AddOns/GW2_UI/textures/party/readycheck-button-hover")
    GwGroupManage.inGroup.countdown:GetFontString():SetTextColor(218 / 255, 214 / 255, 200 / 255)
    GwGroupManage.inGroup.countdown:GetFontString():SetShadowColor(0, 0, 0, 1)
    GwGroupManage.inGroup.countdown:GetFontString():SetShadowOffset(1, -1)
    GwGroupManage.inGroup.countdown:RegisterEvent("GROUP_ROSTER_UPDATE")
    GwGroupManage.inGroup.countdown:RegisterEvent("RAID_ROSTER_UPDATE")

    local fnGGRlC_OnClick = function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        InitiateRolePoll()
    end
    GwGroupManage.inGroup.roleCheck:SetScript("OnEvent", fmButtonSetActiceDeactive)
    GwGroupManage.inGroup.roleCheck:SetScript("OnClick", fnGGRlC_OnClick)
    GwGroupManage.inGroup.roleCheck:RegisterEvent("GROUP_ROSTER_UPDATE")
    GwGroupManage.inGroup.roleCheck:RegisterEvent("RAID_ROSTER_UPDATE")

    local fnGGMC_OnEvent = function(self)
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
    local fnGGMC_OnClick = function()
        if IsInRaid() then
            C_PartyInfo.ConvertToParty()
        else
            C_PartyInfo.ConvertToRaid()
        end
    end
    GwGroupManage.inGroup.convert:SetScript("OnEvent", fnGGMC_OnEvent)
    GwGroupManage.inGroup.convert:SetScript("OnClick", fnGGMC_OnClick)
    GwGroupManage.inGroup.convert:RegisterEvent("GROUP_ROSTER_UPDATE")
    GwGroupManage.inGroup.convert:RegisterEvent("RAID_ROSTER_UPDATE")
    GwGroupManage.inGroup.convert:RegisterEvent("PLAYER_ENTERING_WORLD")

    local fnGMIG_OnLoad = function(self)
        if IsInGroup() then
            self:Show()
            GwGroupManage:SetHeight(280)
        else
            self:Hide()
            GwGroupManage:SetHeight(80)
        end

        if IsInRaid() then
            fmGMGB.icon:SetTexCoord(0, 0.59375, 0.2968, 0.2968 * 2)
        else
            fmGMGB.icon:SetTexCoord(0, 0.59375, 0, 0.2968)
        end
        self.header:SetFont(UNIT_NAME_FONT, 14)

        self:RegisterEvent("GROUP_ROSTER_UPDATE")
        self:RegisterEvent("RAID_ROSTER_UPDATE")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    end
    local fnGMIG_OnEvent = function(self)
        if IsInGroup() then
            self:Show()
            GwGroupManage:SetHeight(280)
        else
            self:Hide()
            GwGroupManage:SetHeight(80)
        end

        if IsInRaid() then
            fmGMGB.icon:SetTexCoord(0, 0.59375, 0.2968, 0.2968 * 2)
        else
            fmGMGB.icon:SetTexCoord(0, 0.59375, 0, 0.2968)
        end
    end
    GwGroupManage.inGroup:SetScript("OnEvent", fnGMIG_OnEvent)
    fnGMIG_OnLoad(GwGroupManage.inGroup)

    local fnGWMM_OnEvent = function(self, event)
        local shouldShowWm = GetSetting("WORLD_MARKER_FRAME") and ((IsInGroup() and GetSetting("RAID_STYLE_PARTY")) or IsInRaid()) and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))
        if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent(event) end

        manageButtonDelay(self, shouldShowWm)
    end
    local fmGWMM = CreateFrame("Frame", "GwWorldMarkerManage", UIParent, "GwWorldMarkerManage")
    if GetSetting("WORLD_MARKER_FRAME") and ((IsInGroup() and GetSetting("RAID_STYLE_PARTY")) or IsInRaid()) and
        (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
            fmGWMM:Show()
    else
        fmGWMM:Hide()
    end
    fmGWMM:RegisterEvent("GROUP_ROSTER_UPDATE")
    fmGWMM:RegisterEvent("RAID_ROSTER_UPDATE")
    fmGWMM:RegisterEvent("PLAYER_REGEN_ENABLED")
    fmGWMM:SetScript("OnEvent", fnGWMM_OnEvent)
    fmGWMM.header:SetFont(UNIT_NAME_FONT, 14)
    fmGWMM.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    fmGWMM.header:SetText(L["WM"])

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

    local f
    for i = 1, 9 do
        f = CreateFrame("Button", "GwRaidMarkerButton" .. i, fmGWMM, "GwRaidGroundMarkerButton")
        f:SetScript("OnEnter", fnF_OnEnter)
        f:SetScript("OnLeave", fnF_OnLeave)
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", fmGWMM, "TOPLEFT", xx, yy)
        f:SetNormalTexture(i < 9 and "Interface/AddOns/GW2_UI/textures/party/GM_" .. i or "Interface/BUTTONS/UI-GROUPLOOT-PASS-DOWN")
        f:SetAttribute("type", "macro")
        f:SetAttribute("macrotext", (i < 9 and "/wm " .. i or "/cwm 9"))

        yy = yy + -37
    end

    for i = 1, 8 do
        f = CreateFrame("Button", "GwRaidMarkerButton" .. i, GwGroupManage.inGroup, "GwRaidMarkerButton")
        f:SetScript("OnEnter", fnF_OnEnter)
        f:SetScript("OnLeave", fnF_OnLeave)

        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", GwGroupManage.inGroup, "TOPLEFT", x, y)
        f:SetNormalTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i)
        f:SetScript("OnClick", function()
            PlaySound(1115) --U_CHAT_SCROLL_BUTTON
            SetRaidTarget("target", i)
        end)

        x = x + 61
        if i == 4 then
            y = y + -55
            x = 10
        end
    end

    local fnGMGB_OnEnter = function(self)
        self.arrow:SetSize(21, 42)
        if GetSetting("FADE_GROUP_MANAGE_FRAME") then
            if GwGroupManage:IsShown() then
                return
            end
            fmGMGB.fadeIn()
        end
    end
    local fnGMGB_OnLeave = function(self)
        self.arrow:SetSize(16, 32)
        if GetSetting("FADE_GROUP_MANAGE_FRAME") then
            if GwGroupManage:IsShown() then
                return
            end
            fmGMGB.fadeOut()
        end
    end
    fmGMGB:SetScript("OnEnter", fnGMGB_OnEnter)
    fmGMGB:HookScript("OnLeave", fnGMGB_OnLeave)

    if GetSetting("FADE_GROUP_MANAGE_FRAME") then
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
    end
end
GW.manageButton = manageButton
GW.AddForProfiling("raidControl", "manageButton", manageButton)
