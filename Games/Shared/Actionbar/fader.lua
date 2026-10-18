---@class GW2
local GW = select(2, ...)

-- fader logic
local fadeTime = 0.1

local function fadeIn_OnFinished(self)
    local bar = self:GetParent()
    for i = 1, 12 do
        bar.gw_Buttons[i].cooldown:SetDrawBling(true)
    end
    if bar.gw_StateTrigger then
        EventRegistry:TriggerEvent("GW2_UI.ActionBarStateChanged")
    end
    bar:SetAlpha(1.0)
end

local MULTIBAR_FADE_ORDER = {"MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7"}

local function actionBarFrameShow(f, instant)
    f.gw_FadeOut:Stop()
    f.gw_FadeIn:Stop()

    f.gw_FadeShowing = true
    -- mirrored as an attribute because the secure state driver snippet in
    -- mainBarLayout.lua can only read attributes; never on Blizzard's own bars,
    -- setting attributes on those taints them
    if f.gw_IsGwFrame and not InCombatLockdown() then
        f:SetAttribute("gw_FadeShowing", true)
    end
    if f.gw_StateTrigger then
        EventRegistry:TriggerEvent("GW2_UI.ActionBarStateChanged")
    end

    if instant then
        fadeIn_OnFinished(f.gw_FadeIn)
    else
        f.gw_FadeIn:Play()
    end
end

local function fadeOut_OnFinished(self)
    local bar = self:GetParent()
    if bar.gw_StateTrigger then
        EventRegistry:TriggerEvent("GW2_UI.ActionBarStateChanged")
    end
    bar:SetAlpha(0.0)
end

local function actionBarFrameHide(f, instant)
    f.gw_FadeOut:Stop()
    f.gw_FadeIn:Stop()

    f.gw_FadeShowing = false
    -- mirrored as an attribute because the secure state driver snippet in
    -- mainBarLayout.lua can only read attributes; never on Blizzard's own bars,
    -- setting attributes on those taints them
    if f.gw_IsGwFrame and not InCombatLockdown() then
        f:SetAttribute("gw_FadeShowing", false)
    end
    for i = 1, 12 do
        f.gw_Buttons[i].cooldown:SetDrawBling(false)
    end

    if instant then
        fadeOut_OnFinished(f.gw_FadeOut)
    else
        f.gw_FadeOut:Play()
    end
end

local HasBonusActionBar = C_ActionBar and C_ActionBar.HasBonusActionBar or HasBonusActionBar
local HasVehicleActionBar = C_ActionBar and C_ActionBar.HasVehicleActionBar or HasVehicleActionBar
local HasOverrideActionBar = C_ActionBar and C_ActionBar.HasOverrideActionBar or HasOverrideActionBar
local IsPossessBarVisible = C_ActionBar and C_ActionBar.IsPossessBarVisible or IsPossessBarVisible

-- the main bar carries the skyriding, vehicle and possess abilities, it only hides on its normal page
local function IsMainBarHiddenWhileMounted()
    local settings = GW.settings.actionbars.mainBar
    if not settings.hideMounted or not (IsMounted() or UnitInVehicle("player")) then
        return false
    end
    if settings.hideSkyriding and C_PlayerInfo.GetGlidingInfo and select(2, C_PlayerInfo.GetGlidingInfo()) then
        return true
    end
    return not (HasBonusActionBar() or HasVehicleActionBar() or HasOverrideActionBar() or IsPossessBarVisible())
end

-- our multibars show and hide through a secure driver: blizzards override, vehicle and pet battle bars where the
-- client has them, per bar combat and mounts, and "hover" for the mouse over modes. A hidden bar takes no clicks,
-- so a hover bar is shown by a secure detector below it and hidden again by blizzards secure auto hide.
-- "combathide" and "hover" keep the space of the bar in the bar layout
local VISIBILITY_SNIPPET = [=[
    local detector = self:GetFrameRef("gw_HoverDetector")
    if newstate == "show" then
        self:UnregisterAutoHide()
        self:SetAttribute("gw_KeepSpace", false)
        if self:GetAttribute("gw_WasShowing") then
            self:Show()
        end
    else
        if self:IsShown() then
            self:SetAttribute("gw_WasShowing", true)
            self:Hide()
        end
        self:SetAttribute("gw_KeepSpace", (newstate == "combathide" or newstate == "hover") and self:GetAttribute("gw_WasShowing") == true)
    end
    if newstate == "hover" and self:GetAttribute("gw_WasShowing") then
        detector:Show()
    else
        detector:Hide()
    end
]=]

local HOVER_SNIPPET = [=[
    local bar = self:GetFrameRef("gw_Bar")
    if bar:GetAttribute("state-gwvisibility") == "hover" and bar:GetAttribute("gw_WasShowing") then
        bar:Show()
        bar:RegisterAutoHide(0.5)
        bar:AddToAutoHide(self)
    end
]=]

-- the flyout hangs on its button, outside the bar; blizzard lays it out before it shows, so a hover bar can take
-- its area into the auto hide right away. Leaving both hides the bar, and the flyout closes with it
local FLYOUT_SNIPPET = [=[
    local button = self:GetParent()
    local bar = button and button:GetParent()
    if bar and bar:GetAttribute("state-gwvisibility") == "hover" and bar:IsShown() then
        bar:RegisterAutoHide(0.5)
        bar:AddToAutoHide(bar:GetFrameRef("gw_HoverDetector"))
        bar:AddToAutoHide(self)
    end
]=]

local flyoutWrapped = false
local function WrapSpellFlyout()
    if flyoutWrapped or not SpellFlyout then
        return
    end
    flyoutWrapped = true
    SecureHandlerWrapScript(SpellFlyout, "OnShow", CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate"), FLYOUT_SNIPPET)
end

local function RefreshMultibarVisibility(bar)
    -- a reload in combat leaves the bar without its driver until now
    if not bar.gw_HoverDetector then
        GW.UpdateMultibarVisibility(bar)
        return
    end
    bar:Execute(format("local newstate = %q\n", bar:GetAttribute("state-gwvisibility") or "show") .. VISIBILITY_SNIPPET)
end

function GW.UpdateMultibarVisibility(bar)
    if InCombatLockdown() or not bar.gw_IsGwFrame then
        return
    end
    local settings = GW.settings.actionbars.bars[bar.originalBarName]
    local conditions = bar.gw_HideForOverride and "[overridebar] hide; [vehicleui] hide; [petbattle] hide; [possessbar,@vehicle,exists] hide; " or ""
    if settings.fade == "HIDE_IN_COMBAT" then
        conditions = conditions .. "[combat] combathide; "
    end
    if settings.hideMounted then
        conditions = conditions .. "[mounted] hide; [@vehicle,exists] hide; "
    end
    if settings.fade == "INCOMBAT" then
        conditions = conditions .. "[combat] show; hover"
    elseif settings.fade == "MOUSE_OVER" then
        conditions = conditions .. "hover"
    else
        conditions = conditions .. "show"
    end

    if not bar.gw_HoverDetector then
        WrapSpellFlyout()
        local detector = CreateFrame("Frame", nil, UIParent, "SecureHandlerEnterLeaveTemplate")
        detector:SetAllPoints(bar)
        detector:SetFrameStrata(bar:GetFrameStrata())
        detector:SetFrameLevel(math.max(0, bar:GetFrameLevel() - 1))
        detector:EnableMouse(true)
        detector:Hide()
        detector:SetFrameRef("gw_Bar", bar)
        detector:SetAttribute("_onenter", HOVER_SNIPPET)
        bar:SetFrameRef("gw_HoverDetector", detector)
        bar.gw_HoverDetector = detector
        bar:SetAttribute("gw_WasShowing", bar:IsShown())
        bar:SetAttribute("_onstate-gwvisibility", VISIBILITY_SNIPPET)
    end
    RegisterStateDriver(bar, "gwvisibility", conditions)
    RefreshMultibarVisibility(bar)
end

function GW.UpdateAllMultibarVisibility()
    local fmActionbar = MainActionBar
    for i = 1, 7 do
        local bar = fmActionbar and fmActionbar["gw_Bar" .. i]
        if bar then
            GW.UpdateMultibarVisibility(bar)
        end
    end
end

-- gw_DirtySetting - set on load and by TrackActionBarChanges; indicates we are pending changes; handled out of combat and then reset
-- bar.gw_IsEnabled - set by TrackActionBarChanges; directly tracks if bars are enabled or not; disabled bars never show
function GW.ActionBarFadeCheck(self, forceCombat)
    local testFlyout
    if SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() then
        testFlyout = SpellFlyout:GetParent():GetParent()
    end

    local inCombat = UnitAffectingCombat("player")
    if forceCombat then
        inCombat = true
    end

    local inLockdown = InCombatLockdown()
    local isDirty = self.gw_DirtySetting

    for i = 1, 8 do
        local f = i == 8 and self or self["gw_Bar" .. i]
        local fadeOption = i == 8 and GW.settings.actionbars.mainBar.fade or GW.settings.actionbars.bars[MULTIBAR_FADE_ORDER[i]].fade
        if f then
            if isDirty and not inLockdown and f ~= self then
                -- this should only be set after a bar setting change (including initial load)
                if f.gw_IsGwFrame then
                    -- the visibility driver decides when an enabled bar shows
                    f:SetAttribute("gw_WasShowing", f.gw_IsEnabled == true)
                    if not f.gw_IsEnabled then
                        GW.SetSecureShown(f, false)
                    end
                    RefreshMultibarVisibility(f)
                else
                    GW.SetSecureShown(f, f.gw_IsEnabled == true)
                end
                if f.gw_IsEnabled then
                    actionBarFrameShow(f, true)
                else
                    actionBarFrameHide(f, true)
                end

                self.gw_DirtySetting = false
            else
                local inFocus = true
                if fadeOption == "MOUSE_OVER" or fadeOption == "INCOMBAT" then
                    if f:IsMouseOver() then
                        inFocus = true
                    else
                        inFocus = false
                    end
                end
                local isFlyout = false
                if testFlyout and testFlyout == f then
                    isFlyout = true
                end
                local curAlpha = f:GetAlpha()
                local busy = (f.gw_FadeIn:IsPlaying() or f.gw_FadeOut:IsPlaying())
                local forceHide = false
                if not f.gw_IsEnabled or (fadeOption == "HIDE_IN_COMBAT" and inCombat) or (f == self and IsMainBarHiddenWhileMounted()) then
                    forceHide = true
                end
                if f:IsShown() and not forceHide and ((inFocus and (fadeOption == "MOUSE_OVER" or fadeOption == "INCOMBAT") and not inCombat) or (inFocus or (inCombat and fadeOption == "INCOMBAT")) or isFlyout or fadeOption == "ALWAYS" or fadeOption == "HIDE_IN_COMBAT") then
                    -- should be showing
                    if not busy and curAlpha < 1.0 then
                        actionBarFrameShow(f)
                    end
                else
                    -- should not be showing
                    if not busy and curAlpha > 0.0 then
                        actionBarFrameHide(f, not f:IsShown())
                    end
                end
            end
        end
    end
end

function GW.CreateActionBarFaderAnim(self, state)
    self.gw_FadeOut = self:CreateAnimationGroup("fadeOut")
    self.gw_FadeIn = self:CreateAnimationGroup("fadeIn")
    self.gw_FadeOut:SetLooping("NONE")
    self.gw_FadeIn:SetLooping("NONE")
    self.gw_FadeOut:SetScript("OnFinished", fadeOut_OnFinished)
    self.gw_FadeIn:SetScript("OnFinished", fadeIn_OnFinished)

    local fadeOut = self.gw_FadeOut:CreateAnimation("Alpha")
    local fadeIn = self.gw_FadeIn:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1.0)
    fadeOut:SetToAlpha(0.0)
    fadeOut:SetDuration(fadeTime)
    fadeIn:SetFromAlpha(0.0)
    fadeIn:SetToAlpha(1.0)
    fadeIn:SetDuration(fadeTime)

    if state then
        self.gw_StateTrigger = true
    end
    local bar = self:GetParent()
    bar.gw_ElapsedTimer = -1
    bar.gw_FadeTimer = -1
end

function GW.TrackActionBarChanges()
    local fmActionbar = MainActionBar
    if not fmActionbar then
        return
    end

    local toggles = {GetActionBarToggles()}
    local show1, show2, show3, show4, show5, show6, show7
    -- need explicit bool's because we test for nil as a separate case
    show1 = toggles[1] -- Bar 2
    show2 = toggles[2] -- Bar 3
    show3 = toggles[3] -- Bar 4
    show4 = toggles[4] -- Bar 5
    show5 = toggles[5] -- Bar 6
    show6 = toggles[6] -- Bar 7
    show7 = toggles[7] -- Bar 8

    -- set that we'll need to immediately re-calc visible bars and mainbar offset (happens in ActionBarFadeCheck)
    fmActionbar.gw_DirtySetting = true
    fmActionbar.gw_FadeTimer = -1
    fmActionbar.gw_ElapsedTimer = -1

    -- store the new enabled state for each multibar
    fmActionbar.gw_Bar1.gw_IsEnabled = show1
    fmActionbar.gw_Bar2.gw_IsEnabled = show2
    fmActionbar.gw_Bar3.gw_IsEnabled = show3
    fmActionbar.gw_Bar4.gw_IsEnabled = show4
    fmActionbar.gw_Bar5.gw_IsEnabled = show5
    fmActionbar.gw_Bar6.gw_IsEnabled = show6
    fmActionbar.gw_Bar7.gw_IsEnabled = show7

    fmActionbar.gw_IsEnabled = true
end

-- after a reconnect blizzards bar toggles can arrive after our load, so login and reload read them again
local loginWatcher = CreateFrame("Frame")
loginWatcher:SetScript("OnEvent", function(self, _, isInitialLogin, isReloadingUi)
    if isInitialLogin or isReloadingUi then
        self:UnregisterAllEvents()
        GW.TrackActionBarChanges()
    end
end)

function GW.WatchActionBarChanges()
    hooksecurefunc("SetActionBarToggles", function() C_Timer.After(1, GW.TrackActionBarChanges) end)
    loginWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    GW.TrackActionBarChanges()
end
