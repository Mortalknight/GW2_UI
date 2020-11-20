local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting

local function inviteToGroup(str)
    C_PartyInfo.InviteUnit(str)
end
GW.AddForProfiling("raidControl", "inviteToGroup", inviteToGroup)

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
GW.AddForProfiling("raidControl", "manageButtonDelay", manageButtonDelay)

local function manageButton()
    local GwGroupManage = CreateFrame("Frame", nil, UIParent, "GwGroupManage")
    local fmGMGB = CreateFrame("Frame", "GwManageGroupButton", UIParent, "GwManageGroupButtonTmpl")

    local fnGMGB_OnClick = function(self, button)
        if GwGroupManage:IsShown() then
            GwGroupManage:Hide()
        else
            GwGroupManage:Show()
        end
    end
    fmGMGB:SetScript("OnMouseDown", fnGMGB_OnClick)

    local fmGMGIB = GwManageGroupInviteBox
    local fmGBITP = GwButtonInviteToParty
    local fmGMGLB = GwManageGroupLeaveButton
    local fmGGRC = GwGroupReadyCheck
    local fmGGCD = GwGroupCountdown
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
        C_PartyInfo.LeaveParty()
    end
    fmGMGLB:SetScript("OnClick", fnGMGLB_OnClick)

    local fmButtonSetActiceDeactive = function(self, event, ...)
        if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
            self:Enable()
        else
            self:Disable()
        end
    end
    local fnGGRC_OnClick = function(self, button)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        DoReadyCheck()
    end
    fmGGRC:SetScript("OnEvent", fmButtonSetActiceDeactive)
    fmGGRC:SetScript("OnClick", fnGGRC_OnClick)
    fmGGRC.hover:SetTexture("Interface/AddOns/GW2_UI/textures/party/readycheck-button-hover")
    fmGGRC:GetFontString():SetTextColor(218 / 255, 214 / 255, 200 / 255)
    fmGGRC:GetFontString():SetShadowColor(0, 0, 0, 1)
    fmGGRC:GetFontString():SetShadowOffset(1, -1)
    fmGGRC:RegisterEvent("GROUP_ROSTER_UPDATE")
    fmGGRC:RegisterEvent("RAID_ROSTER_UPDATE")

    local fmGGCD_OnClick = function(self, button)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        C_PartyInfo.DoCountdown(10)
    end

    fmGGCD:SetScript("OnEvent", fmButtonSetActiceDeactive)
    fmGGCD:SetScript("OnClick", fmGGCD_OnClick)
    fmGGCD.hover:SetTexture("Interface/AddOns/GW2_UI/textures/party/readycheck-button-hover")
    fmGGCD:GetFontString():SetTextColor(218 / 255, 214 / 255, 200 / 255)
    fmGGCD:GetFontString():SetShadowColor(0, 0, 0, 1)
    fmGGCD:GetFontString():SetShadowOffset(1, -1)
    fmGGCD:RegisterEvent("GROUP_ROSTER_UPDATE")
    fmGGCD:RegisterEvent("RAID_ROSTER_UPDATE")

    local fnGGRlC_OnClick = function(self, button)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        InitiateRolePoll()
    end
    fmGGRlC:SetScript("OnEvent", fmButtonSetActiceDeactive)
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
            C_PartyInfo.ConvertToParty()
        else
            C_PartyInfo.ConvertToRaid()
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
            fmGMGB.icon:SetTexCoord(0, 0.59375, 0.2968, 0.2968 * 2)
        else
            fmGMGB.icon:SetTexCoord(0, 0.59375, 0, 0.2968)
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
            fmGMGB.icon:SetTexCoord(0, 0.59375, 0.2968, 0.2968 * 2)
        else
            fmGMGB.icon:SetTexCoord(0, 0.59375, 0, 0.2968)
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
        fmGMGB.fadeOut = function(self)
            fi:Stop()
            fo:Stop()
            fo:Play()
        end
        fmGMGB.fadeIn = function(self)
            fi:Stop()
            fo:Stop()
            fi:Play()
        end
        fmGMGB:SetAlpha(0)
    end
end
GW.manageButton = manageButton
GW.AddForProfiling("party", "manageButton", manageButton)
