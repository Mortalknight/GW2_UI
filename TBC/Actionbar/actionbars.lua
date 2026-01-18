local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame
local Wait = GW.Wait
local Self_Hide = GW.Self_Hide
local CountTable = GW.CountTable
local AddUpdateCB = GW.AddUpdateCB

local MAIN_MENU_BAR_BUTTON_SIZE = 48

local GW_BLIZZARD_HIDE_FRAMES = {
    MainMenuBarOverlayFrame,
    MainMenuBarTexture0,
    MainMenuBarTexture1,
    MainMenuBarTexture2,
    MainMenuBarTexture3,
    MainMenuBarRightEndCap,
    MainMenuBarLeftEndCap,
    ReputationWatchBar,
    MainMenuExpBar,
    ActionBarUpButton,
    ActionBarDownButton,
    MainActionBar.ActionBarPageNumber,
    MainActionBar.ActionBarPageNumber.UpButton,
    MainActionBar.ActionBarPageNumber.DownButton,
    MainMenuMaxLevelBar0,
    MainMenuMaxLevelBar1,
    MainMenuMaxLevelBar2,
    MainMenuMaxLevelBar3,
}

local GW_BLIZZARD_FORCE_HIDE = {
    ReputationWatchBar,
    MainMenuExpBar,
    KeyRingButton,
    MainMenuBarTexture,
    MainMenuMaxLevelBar,
    MainMenuXPBarTexture,
    ReputationWatchBarTexture,
    ReputationXPBarTexture,
    MainMenuBarPageNumber,
    SlidingActionBarTexture0,
    SlidingActionBarTexture1,
    StanceBarLeft,
    StanceBarMiddle,
    StanceBarRight,
    PossessBackground1,
    PossessBackground2,
    MainMenuBarMaxLevelBar
}

-- forward function defs
local actionBarEquipUpdate
local actionBar_OnUpdate

local function hideBlizzardsActionbars()
    for _, v in pairs(GW_BLIZZARD_HIDE_FRAMES) do
        if v and v.Hide ~= nil then
            v:Hide()
            if v.UnregisterAllEvents ~= nil then
                v:UnregisterAllEvents()
            end
        end
    end
    for _, object in pairs(GW_BLIZZARD_FORCE_HIDE) do
        if object:IsObjectType("Frame") then
            object:UnregisterAllEvents()
            object:SetScript("OnEnter", nil)
            object:SetScript("OnLeave", nil)
        end

        if object:IsObjectType("Button") then
            object:SetScript("OnClick", nil)
        end
        hooksecurefunc(object, "Show", Self_Hide)

        object:Hide()
    end

    MainMenuBar:EnableMouse(false)
end
GW.AddForProfiling("Actionbars2", "hideBlizzardsActionbars", hideBlizzardsActionbars)

-- other things can register callbacks for when actionbar visibility/fade changes
local callback = {}

local function AddActionBarCallback(m)
    local k = CountTable(callback) + 1
    callback[k] = m
end
GW.AddActionBarCallback = AddActionBarCallback

local function stateChanged()
    for _, v in pairs(callback) do
        v()
    end
end
GW.AddForProfiling("Actionbars2", "stateChanged", stateChanged)

hooksecurefunc("ValidateActionBarTransition", stateChanged)

local function changeVertexColorActionbars(btn)
    if btn and btn.changedColor then
        local valid = IsActionInRange(btn.action)
        local checksRange = (valid ~= nil)
        local inRange = checksRange and valid
        local out_R, out_G, out_B = RED_FONT_COLOR:GetRGB()
        if checksRange and not inRange then
            btn.icon:SetVertexColor(out_R, out_G, out_B)
        end
    end
end

local function updateActionbarBorders(btn)
    local texture = GetActionTexture(btn.action)
    if texture then
        btn.gwBackdrop.border1:SetAlpha(1)
        btn.gwBackdrop.border2:SetAlpha(1)
        btn.gwBackdrop.border3:SetAlpha(1)
        btn.gwBackdrop.border4:SetAlpha(1)
    else
        btn.gwBackdrop.border1:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
        btn.gwBackdrop.border2:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
        btn.gwBackdrop.border3:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
        btn.gwBackdrop.border4:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
    end
end

local function changeFlyoutStyle(self)
    self.Background.End:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png")
    self.Background.HorizontalMiddle:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png")
    self.Background.VerticalMiddle:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png")
    self.Background.Start:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png")

    local i = 1
    local btn = _G["SpellFlyoutPopupButton" .. i]
    while btn do
        if btn.NormalTexture then
            btn:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagnormal.png")
        end
        btn.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        btn:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed.png")
        btn:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png")
        i = i + 1
        btn = _G["SpellFlyoutPopupButton" .. i]
    end
end

local function FlyoutDirection(actionbar)
    if InCombatLockdown() then return end

    for i = 1, 12 do
        local button = actionbar.gw_Buttons[i]
        if button.FlyoutArrowContainer then
            --Change arrow direction depending on what bar the button is on
            local point = GW.GetScreenQuadrant(actionbar)
            if point ~= "UNKNOWN" then
                if strfind(point, "TOP") then
                    button:SetAttribute("flyoutDirection", "DOWN")
                elseif point == "RIGHT" then
                    button:SetAttribute("flyoutDirection", "LEFT")
                elseif point == "LEFT" then
                    button:SetAttribute("flyoutDirection", "RIGHT")
                elseif point == "CENTER" or strfind(point, "BOTTOM") then
                    button:SetAttribute("flyoutDirection", "UP")
                end
                if button.UpdateFlyout then
                    button:UpdateFlyout()
                end
            end
        end
    end
end

-- fader logic
local fadeTime = 0.1

local function fadeIn_OnFinished(self)
    local bar = self:GetParent()
    for i = 1, 12 do
        bar.gw_Buttons[i].cooldown:SetDrawBling(true)
    end
    if bar.gw_StateTrigger then
        stateChanged()
    end
    bar:SetAlpha(1.0)
end
GW.AddForProfiling("Actionbars2", "fadeIn_OnFinished", fadeIn_OnFinished)

local function actionBarFrameShow(f, instant)
    f.fadeOut:Stop()
    f.fadeIn:Stop()

    f.gw_FadeShowing = true
    if not InCombatLockdown() then
        f:SetAttribute("gw_FadeShowing", true)
    end
    if f.gw_StateTrigger then
        stateChanged()
    end

    if instant then
        fadeIn_OnFinished(f.fadeIn)
    else
        f.fadeIn:Play()
    end
end
GW.AddForProfiling("Actionbars2", "actionBarFrameShow", actionBarFrameShow)

local function fadeOut_OnFinished(self)
    local bar = self:GetParent()
    if bar.gw_StateTrigger then
        stateChanged()
    end
    bar:SetAlpha(0.0)
end
GW.AddForProfiling("Actionbars2", "fadeOut_OnFinished", fadeOut_OnFinished)

local function actionBarFrameHide(f, instant)
    f.fadeOut:Stop()
    f.fadeIn:Stop()

    f.gw_FadeShowing = false
    if not InCombatLockdown() then
        f:SetAttribute("gw_FadeShowing", false)
    end
    for i = 1, 12 do
        f.gw_Buttons[i].cooldown:SetDrawBling(false)
    end

    if instant then
        fadeOut_OnFinished(f.fadeOut)
    else
        f.fadeOut:Play()
    end
end
GW.AddForProfiling("Actionbars2", "actionBarFrameHide", actionBarFrameHide)

-- gw_DirtySetting - set on load and by trackBarChanges; indicates we are pending changes; handled out of combat and then reset
-- bar.gw_IsEnabled - set by trackBarChanges; directly tracks if bars are enabled or not; disabled bars never show
local function fadeCheck(self, forceCombat)
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
        local fadeOption = GW.settings["FADE_MULTIACTIONBAR_" .. i]
        if f then
            if isDirty and not inLockdown and f ~= self then
                -- this should only be set after a bar setting change (including initial load)
                if f.gw_IsEnabled then
                    f:Show()
                    actionBarFrameShow(f, true)
                else
                    f:Hide()
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
                local busy = (f.fadeIn:IsPlaying() or f.fadeOut:IsPlaying())
                local forceHide = false
                if not f.gw_IsEnabled then
                    forceHide = true
                end
                if f:IsShown() and not forceHide and ((inFocus and (fadeOption == "MOUSE_OVER" or fadeOption == "INCOMBAT") and not inCombat) or (inFocus or (inCombat and fadeOption == "INCOMBAT")) or isFlyout or fadeOption == "ALWAYS") then
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
GW.AddForProfiling("Actionbars2", "fadeCheck", fadeCheck)

local function createFaderAnim(self, state)
    self.fadeOut = self:CreateAnimationGroup("fadeOut")
    self.fadeIn = self:CreateAnimationGroup("fadeIn")
    self.fadeOut:SetLooping("NONE")
    self.fadeIn:SetLooping("NONE")
    self.fadeOut:SetScript("OnFinished", fadeOut_OnFinished)
    self.fadeIn:SetScript("OnFinished", fadeIn_OnFinished)

    local fadeOut = self.fadeOut:CreateAnimation("Alpha")
    local fadeIn = self.fadeIn:CreateAnimation("Alpha")
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
    bar.elapsedTimer = -1
    bar.fadeTimer = -1
end

local function updateHotkey(self)
    local hotkey = self.HotKey

    if GW.settings.BUTTON_ASSIGNMENTS then
        hotkey:Show()
        if self.hkBg then
            self.hkBg.texture:Show()
        end
    else
        hotkey:Hide()
        if self.hkBg then
            self.hkBg.texture:Hide()
        end
    end

    local text = hotkey:GetText()
    if text and text ~= RANGE_INDICATOR then
        text = gsub(text, "(s%-)", "S")
        text = gsub(text, "(a%-)", "A")
        text = gsub(text, "(c%-)", "C")
        text = gsub(text, "SHIFT%-", "S")
		text = gsub(text, "ALT%-", "A")
		text = gsub(text, "CTRL%-", "C")
        text = gsub(text, KEY_BUTTON3, "M3") --middle mouse Button
        text = gsub(text, gsub(KEY_BUTTON4, "4", ""), "M") -- mouse button
        text = gsub(text, KEY_PAGEUP, "PU")
        text = gsub(text, KEY_PAGEDOWN, "PD")
        text = gsub(text, KEY_SPACE, "SpB")
        text = gsub(text, KEY_INSERT, "Ins")
        text = gsub(text, KEY_HOME, "Hm")
        text = gsub(text, KEY_DELETE, "Del")
        text = gsub(text, "NDIVIDE", "N/")
        text = gsub(text, "NMULTIPLY", "N*")
        text = gsub(text, "NMINUS", "N-")
        text = gsub(text, "NPLUS", "N+")
        text = gsub(text, "NEQUALS", "N=")
        text = gsub(text, KEY_LEFT, "LT")
        text = gsub(text, KEY_RIGHT, "RT")
        text = gsub(text, KEY_UP, "UP")
        text = gsub(text, KEY_DOWN, "DN")
        text = gsub(text, gsub(KEY_NUMPADPLUS, "%+", ""), "N") -- for all numpad keys
        text = gsub(text, KEY_MOUSEWHEELDOWN, "MwD")
        text = gsub(text, KEY_MOUSEWHEELUP, "MwU")

        hotkey:SetText(text)
    else
        hotkey:SetText("")
    end
end
GW.updateHotkey = updateHotkey

local function updateMacroName(self)
    if self.Name then
        if self.showMacroName then
            self.Name:SetPoint("TOPLEFT", self, "TOPLEFT")
            self.Name:SetJustifyH("LEFT")
            self.Name:SetWidth(self:GetWidth())
            local font, fontHeight = self.Name:GetFont()
            self.Name:SetFont(font, fontHeight, "OUTLINED")
            self.Name:SetAlpha(1)
        else
            self.Name:SetAlpha(0)
        end
    end
end
GW.updateMacroName = updateMacroName

local function hideBackdrop(self)
    self.gwBackdrop:Hide()
end
GW.AddForProfiling("Actionbars2", "hideBackdrop", hideBackdrop)

local function showBackdrop(self)
    self.gwBackdrop:Show()
end
GW.AddForProfiling("Actionbars2", "showBackdrop", showBackdrop)

local function FixHotKeyPosition(button, isStanceButton, isPetButton, isMainBar)
    button.HotKey:ClearAllPoints()
    if isPetButton or isStanceButton then
        button.HotKey:SetPoint("CENTER", button, "BOTTOM", 0, 5)
    elseif isMainBar then
        button.HotKey:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
        button.HotKey:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        button.HotKey:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER, "OUTLINE")
        button.HotKey:SetTextColor(1, 1, 1)
    else
        button.HotKey:SetPoint("CENTER", button, "BOTTOM", 0, 0)
    end
    button.HotKey:SetJustifyH("CENTER")
end
GW.FixHotKeyPosition = FixHotKeyPosition

local function setActionButtonStyle(buttonName, noBackDrop, isStanceButton, isPet)
    local btn = _G[buttonName]
    local btnWidth = btn:GetWidth()

    if btn.icon then
        btn.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
    if btn.HotKey then
        FixHotKeyPosition(btn, isStanceButton, isPet)
    end
    if btn.Count then
        btn.Count:ClearAllPoints()
        btn.Count:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -3, -3)
        btn.Count:SetJustifyH("RIGHT")
        btn.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER, "OUTLINE")
        btn.Count:SetTextColor(1, 1, 0.6)
    end

    if btn.cooldown then
        btn.cooldown:ClearAllPoints()
        btn.cooldown:SetAllPoints(btn)
    end

    btn:GetPushedTexture():SetSize(btnWidth, btnWidth)

    if btn.Border then
        btn.Border:SetSize(btnWidth, btnWidth)
        btn.Border:SetBlendMode("BLEND")
        if isStanceButton then
            btn.Border:Show()
            btn.Border:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\stancebar-border.png")
        else
            btn.Border:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder.png")
        end
    end
    if btn.NormalTexture then
        btn:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagnormal.png")
    end

    if _G[buttonName .. "FloatingBG"] then
        _G[buttonName .. "FloatingBG"]:SetTexture(nil)
    end
    if _G[buttonName .. "NormalTexture"] then
        _G[buttonName .. "NormalTexture"]:SetTexture(nil)
        _G[buttonName .. "NormalTexture"]:SetAlpha(0)
    end
    if _G[buttonName .. "NormalTexture2"] then
        _G[buttonName .. "NormalTexture2"]:SetTexture(nil)
        _G[buttonName .. "NormalTexture2"]:SetAlpha(0)
    end
    if btn.AutoCastable then
        btn.AutoCastable:SetSize(btnWidth * 2, btnWidth * 2)
    end
    if btn.AutoCastShine then
        btn.AutoCastShine:SetSize(btnWidth, btnWidth)
    end
    if btn.AutoCastOverlay then
        btn.AutoCastOverlay:SetSize(btnWidth, btnWidth)
    end
    if btn.NewActionTexture then
        btn.NewActionTexture:SetSize(btnWidth, btnWidth)
    end
    if btn.SpellHighlightTexture then
        btn.SpellHighlightTexture:SetSize(btnWidth, btnWidth)
    end
    if btn.CooldownFlash then
        btn.CooldownFlash:GwSetOutside(btn, 4, 4)
    end

    if btn.SpellCastAnimFrame and not btn.gwSpellCastAnimFrameFillMask then
        btn.SpellCastAnimFrame.Fill.InnerGlowTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder.png")
        btn.SpellCastAnimFrame.Fill.InnerGlowTexture:SetVertexColor(0, 0, 0, 0)

        -- create our own mask
        btn.SpellCastAnimFrame.EndBurst.GlowRing:RemoveMaskTexture(btn.SpellCastAnimFrame.EndBurst.EndMask)
        btn.gwSpellCastAnimFrameMask = btn.SpellCastAnimFrame.EndBurst:CreateMaskTexture()
        btn.gwSpellCastAnimFrameMask:SetPoint("CENTER", btn.SpellCastAnimFrame.EndBurst, "CENTER", 0, 0)
        btn.gwSpellCastAnimFrameMask:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\bag\\bagbg.png",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        btn.gwSpellCastAnimFrameMask:SetSize(btnWidth, btnWidth)
        btn.SpellCastAnimFrame.EndBurst.GlowRing:AddMaskTexture(btn.gwSpellCastAnimFrameMask)

        btn.SpellCastAnimFrame.Fill.CastFill:RemoveMaskTexture(btn.SpellCastAnimFrame.Fill.FillMask)
        btn.gwSpellCastAnimFrameFillMask = btn.SpellCastAnimFrame.Fill:CreateMaskTexture()
        btn.gwSpellCastAnimFrameFillMask:SetPoint("CENTER", btn.SpellCastAnimFrame.Fill, "CENTER", 0, 0)
        btn.gwSpellCastAnimFrameFillMask:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\bag\\bagbg.png",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        btn.gwSpellCastAnimFrameFillMask:SetSize(btnWidth, btnWidth)
        btn.SpellCastAnimFrame.Fill.CastFill:AddMaskTexture(btn.gwSpellCastAnimFrameFillMask)

        hooksecurefunc(btn.SpellCastAnimFrame.Fill.CastingAnim, "OnFinished", function()
            btn.SpellCastAnimFrame.Fill.CastFill:Hide()
        end)

        hooksecurefunc(btn.SpellCastAnimFrame, "Setup", function()
            btn.SpellCastAnimFrame.Fill.CastFill:Show()
        end)
    end

    if btn.InterruptDisplay and not btn.gwInterruptDisplayMask then
        -- create our own mask
        btn.InterruptDisplay.Highlight.HighlightTexture:RemoveMaskTexture(btn.InterruptDisplay.Highlight.Mask)
        btn.gwInterruptDisplayMask = btn.InterruptDisplay.Highlight:CreateMaskTexture()
        btn.gwInterruptDisplayMask:SetPoint("CENTER", btn.InterruptDisplay.Highlight, "CENTER", 0, 0)
        btn.gwInterruptDisplayMask:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\bag\\bagbg.png",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        btn.gwInterruptDisplayMask:SetSize(btnWidth, btnWidth)
        btn.InterruptDisplay.Highlight.HighlightTexture:AddMaskTexture(btn.gwInterruptDisplayMask)

        btn.InterruptDisplay.Base.Base:SetSize(btnWidth, btnWidth)
        btn.InterruptDisplay.Base.Base:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder.png")
        btn.InterruptDisplay.Base.Base:SetVertexColor(1, 0, 0)
    end

    if btn.TargetReticleAnimFrame and not btn.gwTargetReticleAnimFrameMask then
        -- create our own mask
        btn.TargetReticleAnimFrame.Highlight:RemoveMaskTexture(btn.InterruptDisplay.Highlight.Mask)
        btn.gwTargetReticleAnimFrameMask = btn.InterruptDisplay.Highlight:CreateMaskTexture()
        btn.gwTargetReticleAnimFrameMask:SetPoint("CENTER", btn.TargetReticleAnimFrame.Highlight, "CENTER", 0, 0)
        btn.gwTargetReticleAnimFrameMask:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\bag\\bagbg.png",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        btn.gwTargetReticleAnimFrameMask:SetSize(btnWidth, btnWidth)
        btn.TargetReticleAnimFrame.Highlight:AddMaskTexture(btn.gwTargetReticleAnimFrameMask)

        btn.TargetReticleAnimFrame.Base:SetSize(btnWidth, btnWidth)
    end

    if btn.BottomDivider then
        btn.BottomDivider:SetAlpha(0)
    end

    if btn.IconMask then
        btn.icon:RemoveMaskTexture(btn.IconMask)
    end

    btn:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed.png")
    btn:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png")

    if btn.HighlightTexture then
        btn.HighlightTexture:SetSize(btnWidth, btnWidth)
    end
    if btn.SetCheckedTexture then
        btn:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png")
    end
    btn.CheckedTexture:SetSize(btnWidth, btnWidth)

    updateMacroName(btn)

    if btn.gwBackdrop == nil and (noBackDrop == nil or noBackDrop == false) then
        local backDrop = CreateFrame("Frame", nil, btn, "GwActionButtonBackdropTmpl")
        local backDropSize = 1

        backDrop:SetPoint("TOPLEFT", btn, "TOPLEFT", -backDropSize, backDropSize)
        backDrop:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", backDropSize, -backDropSize)

        btn.gwBackdrop = backDrop
        btn.gwBackdrop:SetFrameLevel(btn:GetFrameLevel() - 1)

        if not isStanceButton and not isPet then
            btn.gwBackdrop.bg:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
            btn.gwBackdrop.border1:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
            btn.gwBackdrop.border2:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
            btn.gwBackdrop.border3:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
            btn.gwBackdrop.border4:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
        end
    end
end
GW.setActionButtonStyle = setActionButtonStyle
GW.AddForProfiling("Actionbars2", "setActionButtonStyle", setActionButtonStyle)

local red_R, red_G, red_B = RED_FONT_COLOR:GetRGB()
local function helper_RangeUpdate(slot, inRange, checkRange)
    local btn = nil
    local indicator = "RED_OVERLAY"
    local barPrefix = GW.settings.BAR_LAYOUT_ENABLED and "Gw" or ""
    if slot <= 24 then
        btn = MainActionBar.gw_Buttons[slot]
        indicator = GW.settings.MAINBAR_RANGEINDICATOR
        -- 13 to 24 is page 2
    elseif slot <= 36 then
        btn = _G[barPrefix .. "MultiBarRight"].gw_Buttons[slot - 24]
    elseif slot <= 48 then
        btn = _G[barPrefix .. "MultiBarLeft"].gw_Buttons[slot - 36]
    elseif slot <= 60 then
        btn = _G[barPrefix .. "MultiBarBottomRight"].gw_Buttons[slot - 48]
    elseif slot <= 72 then
        btn = _G[barPrefix .. "MultiBarBottomLeft"].gw_Buttons[slot - 60]
    elseif slot <= 144 then
        -- not sure where the 73-144 range gets used?
    elseif slot <= 156 then
        btn = _G[barPrefix .. "MultiBar5"].gw_Buttons[slot - 144]
    elseif slot <= 168 then
        btn = _G[barPrefix .. "MultiBar6"].gw_Buttons[slot - 156]
    elseif slot <= 180 then
        btn = _G[barPrefix .. "MultiBar7"].gw_Buttons[slot - 168]
    end

    if not btn then
        return
    end

    if checkRange and not inRange then
        if indicator == "RED_INDICATOR" or indicator == "BOTH" then
            btn.gw_RangeIndicator:Show()
        end
        if indicator == "RED_OVERLAY" or indicator == "BOTH" then
            btn.icon:SetVertexColor(red_R, red_G, red_B, 1, true)
        end
    else
        if btn.gw_RangeIndicator then
            btn.gw_RangeIndicator:Hide()
        end
        local vc = btn.icon.savedVertexColor
        btn.icon:SetVertexColor(vc.r, vc.g, vc.b, vc.a, true)
    end
end

local function saveVertexColor(self, r, g, b, a, bypass)
    if bypass then
        return
    end
    if a == nil then
        a = 1
    end
    -- reuse the same table to avoid allocating on every SetVertexColor call
    self.savedVertexColor = self.savedVertexColor or {}
    local saved = self.savedVertexColor
    saved.r, saved.g, saved.b, saved.a = r, g, b, a
end

local function main_OnEvent(_, event, ...)
    if event == "ACTION_RANGE_CHECK_UPDATE" then
        helper_RangeUpdate(...)
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        actionBarEquipUpdate()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        local forceCombat = event == "PLAYER_REGEN_DISABLED"
        fadeCheck(MainActionBar, forceCombat)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        C_Timer.After(1.1, GW.AddGw2Layout)
    end

    -- keep actionbutton style
    if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_LEVEL_UP" then
        for i = 1, 12 do
            setActionButtonStyle("ActionButton" .. i)
        end
    end
end
GW.AddForProfiling("Actionbars2", "main_OnEvent", main_OnEvent)

local function updateMainBar()
    local fmActionbar = MainActionBar

    fmActionbar:GwKillEditMode()

    local used_height = MAIN_MENU_BAR_BUTTON_SIZE
    local btn_padding = GW.settings.MAINBAR_MARGIIN

    fmActionbar.gw_Buttons = {}
    fmActionbar.rangeTimer = -1
    fmActionbar.fadeTimer = -1
    fmActionbar.elapsedTimer = -1

    for i = 1, 12 do
        local btn = _G["ActionButton" .. i]
        fmActionbar.gw_Buttons[i] = btn

        if btn then
            btn:SetScript("OnUpdate", nil) -- disable the default button update handler
            btn.SlotBackground:SetAlpha(0)

            local hotkey = _G["ActionButton" .. i .. "HotKey"]
            btn_padding = btn_padding + MAIN_MENU_BAR_BUTTON_SIZE + GW.settings.MAINBAR_MARGIIN
            btn:SetSize(MAIN_MENU_BAR_BUTTON_SIZE, MAIN_MENU_BAR_BUTTON_SIZE)
            btn.showMacroName = GW.settings.SHOWACTIONBAR_MACRO_NAME_ENABLED

            btn.hkBg = CreateFrame("Frame", "GwHotKeyBackDropActionButton" .. i, hotkey:GetParent(), "GwActionHotkeyBackdropTmpl")
            btn.hkBg:SetPoint("CENTER", hotkey, "CENTER", 0, 0)
            btn.hkBg.texture:SetParent(hotkey:GetParent())
            setActionButtonStyle("ActionButton" .. i)
            updateHotkey(btn)
            saveVertexColor(btn.icon, btn.icon:GetVertexColor())
            hooksecurefunc(btn.icon, "SetVertexColor", saveVertexColor)
            hooksecurefunc(btn, "UpdateUsable", changeVertexColorActionbars)
            hooksecurefunc(btn, "Update", updateActionbarBorders)
            updateActionbarBorders(btn)

            hotkey:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
            hotkey:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
            hotkey:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER, "OUTLINE")
            hotkey:SetTextColor(1, 1, 1)
            btn.changedColor = false
            btn.rangeIndicatorSetting = GW.settings.MAINBAR_RANGEINDICATOR

            if IsEquippedAction(btn.action) then
                local borname = "ActionButton" .. i .. "Border"
                if _G[borname] then
                    _G[borname]:SetVertexColor(0, 1, 0, 1)
                end
            end
            local rangeIndicator = CreateFrame("FRAME", nil, hotkey:GetParent(), "GwActionRangeIndicatorTmpl")
            rangeIndicator:SetFrameStrata("BACKGROUND")
            rangeIndicator:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", -1, -2)
            rangeIndicator:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 1, -2)
            rangeIndicator.texture:SetVertexColor(147 / 255, 19 / 255, 2 / 255)
            rangeIndicator:Hide()
            btn.gw_RangeIndicator = rangeIndicator

            btn:ClearAllPoints()
            btn:SetPoint("LEFT", fmActionbar, "LEFT", btn_padding - GW.settings.MAINBAR_MARGIIN - MAIN_MENU_BAR_BUTTON_SIZE, GW.settings.XPBAR_ENABLED and 0 or -14)

            if i == 6 and not GW.settings.PLAYER_AS_TARGET_FRAME then
                btn_padding = btn_padding + 108
            end
        end
    end

    -- position the main action bar
    fmActionbar:SetSize(btn_padding, used_height)
    fmActionbar.gw_Width = btn_padding

    -- event/update handlers
    AddUpdateCB(actionBar_OnUpdate, fmActionbar)
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    eventFrame:RegisterEvent("ACTION_RANGE_CHECK_UPDATE")
    -- add a reposition hook to spec switches
    eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    eventFrame:HookScript("OnEvent", main_OnEvent)

    -- disable default main action bar behaviors
    MainActionBar:SetMovable(1)
    MainActionBar:SetUserPlaced(true)
    MainActionBar:SetMovable(0)
    MainActionBar:SetFrameLevel(1)
    MainActionBar.ignoreFramePositionManager = true

    -- set fader logic
    createFaderAnim(fmActionbar, true)
    fmActionbar.gw_FadeShowing = true

    return fmActionbar
end
GW.AddForProfiling("Actionbars2", "updateMainBar", updateMainBar)
local function trackBarChanges()
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

    -- set that we'll need to immediately re-calc visible bars and mainbar offset (happens in fadeCheck)
    fmActionbar.gw_DirtySetting = true
    fmActionbar.fadeTimer = -1
    fmActionbar.elapsedTimer = -1

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

local function updateMultiBar(lm, barName, buttonName, actionPage, state)
    local multibar = _G[barName]
    local settings = GW.settings[barName]
    local used_width = 0
    local used_height = settings.size
    local btn_padding = 0
    local btn_padding_y = 0
    local btn_this_row = 0
    local first = 1
    local last = 12
    local buttonOrder = {}
    local buttonsPerRow = settings.ButtonsPerRow or (last - first + 1)
    local totalRows = math.ceil((last - first + 1) / buttonsPerRow)

    multibar:GwKillEditMode()

    local fmMultibar = CreateFrame("FRAME", "Gw" .. barName, UIParent, "GwMultibarTmpl")
    if actionPage ~= nil then
        fmMultibar:SetAttribute("actionpage", actionPage)
        fmMultibar:SetFrameStrata("LOW")
    end
    fmMultibar.gw_Buttons = {}
    fmMultibar.originalBarName = barName

    if settings.invert then
        for row = totalRows - 1, 0, -1 do
            for col = 0, buttonsPerRow - 1 do
                local idx = first + row * buttonsPerRow + col
                if idx <= last then
                    buttonOrder[#buttonOrder + 1] = idx
                end
            end
        end
    else
        for i = first, last do
            buttonOrder[#buttonOrder + 1] = i
        end
    end

    for _, i in ipairs(buttonOrder) do
        local btn = _G[buttonName .. i]
        fmMultibar.gw_Buttons[i] = btn

        if btn then
            if actionPage then
                -- reparent button to our action bar
                btn:SetParent(fmMultibar)
            end
            btn:SetScript("OnUpdate", nil) -- disable the default button update handler
            btn.SlotBackground:SetAlpha(0)

            btn:SetSize(settings.size, settings.size)
            updateHotkey(btn)

            btn.showMacroName = GW.settings.SHOWACTIONBAR_MACRO_NAME_ENABLED

            setActionButtonStyle(buttonName .. i)

            saveVertexColor(btn.icon, btn.icon:GetVertexColor())
            hooksecurefunc(btn.icon, "SetVertexColor", saveVertexColor)
            hooksecurefunc(btn, "UpdateUsable", changeVertexColorActionbars)
            hooksecurefunc(btn, "Update", updateActionbarBorders)

            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", fmMultibar, "TOPLEFT", btn_padding, -btn_padding_y)
            btn.gwX = btn_padding
            btn.gwY = btn_padding_y
            btn.changedColor = false
            hooksecurefunc(btn, "SetPoint", function(_, _, parent)
                if parent ~= fmMultibar then
                    btn:ClearAllPoints()
                    btn:SetPoint("TOPLEFT", fmMultibar, "TOPLEFT", btn.gwX, -btn.gwY)
                end
            end)

            btn_padding = btn_padding + settings.size + GW.settings.MULTIBAR_MARGIIN
            btn_this_row = btn_this_row + 1
            used_width = btn_padding

            if btn_this_row == settings.ButtonsPerRow then
                btn_padding_y = btn_padding_y + settings.size + GW.settings.MULTIBAR_MARGIIN
                btn_this_row = 0
                btn_padding = 0
                used_height = btn_padding_y
            end

            if IsEquippedAction(btn.action) then
                local borname = buttonName .. i .. "Border"
                if _G[borname] then
                    _G[borname]:SetVertexColor(0, 1, 0, 1)
                end
            end
        end
    end

    fmMultibar:SetScript("OnUpdate", nil)
    fmMultibar:SetSize(used_width, used_height)

    -- to keep actionbutton style after spec switch
    fmMultibar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    fmMultibar:SetScript("OnEvent", function()
        for i = 1, 12 do
            setActionButtonStyle(buttonName .. i)
        end
    end)

    multibar.ignoreFramePositionManager = true

    if barName == "MultiBarLeft" then
        RegisterMovableFrame(fmMultibar, OPTION_SHOW_ACTION_BAR:format(5), barName, ALL .. "," .. BINDING_HEADER_ACTIONBAR, nil, {"default", "scaleable"}, nil, FlyoutDirection)
    elseif barName == "MultiBarRight" then
        RegisterMovableFrame(fmMultibar, OPTION_SHOW_ACTION_BAR:format(4), barName, ALL .. "," .. BINDING_HEADER_ACTIONBAR, nil, {"default", "scaleable"}, nil, FlyoutDirection)
    elseif barName == "MultiBarBottomLeft" then
        RegisterMovableFrame(fmMultibar, OPTION_SHOW_ACTION_BAR:format(2), barName, ALL .. "," .. BINDING_HEADER_ACTIONBAR, nil, {"default", "scaleable"}, true, FlyoutDirection)
        lm:RegisterMultiBarLeft(fmMultibar)
    elseif barName == "MultiBarBottomRight" then
        RegisterMovableFrame(fmMultibar, OPTION_SHOW_ACTION_BAR:format(3), barName, ALL .. "," .. BINDING_HEADER_ACTIONBAR, nil, {"default", "scaleable"}, true, FlyoutDirection)
        lm:RegisterMultiBarRight(fmMultibar)
    elseif barName == "MultiBar5" then
        RegisterMovableFrame(fmMultibar, OPTION_SHOW_ACTION_BAR:format(6), barName, ALL .. "," .. BINDING_HEADER_ACTIONBAR, nil, {"default", "scaleable"}, nil, FlyoutDirection)
    elseif barName == "MultiBar6" then
        RegisterMovableFrame(fmMultibar, OPTION_SHOW_ACTION_BAR:format(7), barName, ALL .. "," .. BINDING_HEADER_ACTIONBAR, nil, {"default", "scaleable"}, nil, FlyoutDirection)
    elseif barName == "MultiBar7" then
        RegisterMovableFrame(fmMultibar, OPTION_SHOW_ACTION_BAR:format(8), barName, ALL .. "," .. BINDING_HEADER_ACTIONBAR, nil, {"default", "scaleable"}, nil, FlyoutDirection)
    end

    fmMultibar:ClearAllPoints()
    fmMultibar:SetPoint("TOPLEFT", fmMultibar.gwMover)
    hooksecurefunc(fmMultibar, "SetPoint", function(_, _, anchor)
        if anchor ~= fmMultibar.gwMover then
            fmMultibar:ClearAllPoints()
            fmMultibar:SetPoint("TOPLEFT", fmMultibar.gwMover)
        end
    end)

    -- position mover
    if (barName == "MultiBarBottomLeft" or barName == "MultiBarBottomRight") and (not GW.settings.XPBAR_ENABLED or GW.settings.PLAYER_AS_TARGET_FRAME) and not fmMultibar.isMoved  then
        local yOff = not GW.settings.XPBAR_ENABLED and 14 or 0
        local xOff = GW.settings.PLAYER_AS_TARGET_FRAME and 56 or 0
        fmMultibar.gwMover:ClearAllPoints()
        if barName == "MultiBarBottomLeft" then
            fmMultibar.gwMover:SetPoint(settings.point, UIParent, settings.relativePoint, settings.xOfs + xOff, settings.yOfs - yOff)
        elseif barName == "MultiBarBottomRight" then
            fmMultibar.gwMover:SetPoint(settings.point, UIParent, settings.relativePoint, settings.xOfs - xOff, settings.yOfs - yOff)
        end
    end

    -- set fader logic
    createFaderAnim(fmMultibar, state)

    -- disable default multibar behaviors
    multibar:UnregisterAllEvents()
    multibar:SetScript("OnUpdate", nil)
    multibar:SetScript("OnShow", nil)
    multibar:SetScript("OnHide", nil)
    multibar:EnableMouse(false)
    multibar:SetMovable(1)
    multibar:SetUserPlaced(true)
    multibar:SetMovable(0)

    -- flyout direction
    FlyoutDirection(fmMultibar)

    fmMultibar:Show()

    return fmMultibar
end
GW.AddForProfiling("Actionbars2", "updateMultiBar", updateMultiBar)

local function UpdateMultibarButtons()
    local fmActionbar = MainActionBar
    local fmMultiBar

    for y = 1, 7 do
        fmMultiBar = fmActionbar["gw_Bar" .. y]
        if fmMultiBar.gw_IsEnabled then
            local settings = GW.settings[fmMultiBar.originalBarName]
            local used_height = 0
            local btn_padding = 0
            local btn_padding_y = 0
            local btn_this_row = 0
            local used_width = 0

            local buttonOrder = {}
            local buttonsPerRow = settings.ButtonsPerRow or 12
            local totalRows = math.ceil(12 / buttonsPerRow)

            if settings.invert then
                for row = totalRows - 1, 0, -1 do
                    for col = 0, buttonsPerRow - 1 do
                        local idx = row * buttonsPerRow + col + 1
                        if idx <= 12 then
                            buttonOrder[#buttonOrder + 1] = idx
                        end
                    end
                end
            else
                for i = 1, 12 do
                    buttonOrder[#buttonOrder + 1] = i
                end
            end

            for _, i in ipairs(buttonOrder) do
                local btn = fmMultiBar.gw_Buttons[i]

                btn.gwX = btn_padding
                btn.gwY = btn_padding_y
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", fmMultiBar, "TOPLEFT", btn_padding, -btn_padding_y)

                btn_padding = btn_padding + settings.size + GW.settings.MULTIBAR_MARGIIN
                btn_this_row = btn_this_row + 1
                used_width = btn_padding

                if btn_this_row == settings.ButtonsPerRow then
                    btn_padding_y = btn_padding_y + settings.size + GW.settings.MULTIBAR_MARGIIN
                    btn_this_row = 0
                    btn_padding = 0
                    used_height = used_height + settings.size + GW.settings.MULTIBAR_MARGIIN
                end

                btn.gwBackdrop.bg:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
                btn.gwBackdrop.border1:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
                btn.gwBackdrop.border2:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
                btn.gwBackdrop.border3:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
                btn.gwBackdrop.border4:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))

                btn.showMacroName = GW.settings.SHOWACTIONBAR_MACRO_NAME_ENABLED
                updateMacroName(btn)
                updateHotkey(btn)
            end

            fmMultiBar.gwMover:SetSize(used_width, used_height)
            fmMultiBar:SetSize(used_width, used_height)
        end
    end
end
GW.UpdateMultibarButtons = UpdateMultibarButtons

local function vehicleLeave_OnUpdate()
    if InCombatLockdown() then
        return
    end
    MainMenuBarVehicleLeaveButton:SetPoint("LEFT", ActionButton12, "RIGHT", 0, 0)
end
GW.AddForProfiling("Actionbars2", "vehicleLeave_OnUpdate", vehicleLeave_OnUpdate)

local function vehicleLeave_OnShow()
    MainMenuBarVehicleLeaveButton:SetScript("OnUpdate", vehicleLeave_OnUpdate)
end
GW.AddForProfiling("Actionbars2", "vehicleLeave_OnShow", vehicleLeave_OnShow)

local function vehicleLeave_OnHide()
    MainMenuBarVehicleLeaveButton:SetScript("OnUpdate", nil)
end
GW.AddForProfiling("Actionbars2", "vehicleLeave_OnHide", vehicleLeave_OnHide)

local function setLeaveVehicleButton()
    MainMenuBarVehicleLeaveButton:SetParent(MainMenuBar)
    MainMenuBarVehicleLeaveButton:ClearAllPoints()
    MainMenuBarVehicleLeaveButton:SetPoint("LEFT", ActionButton12, "RIGHT", 0, 0)

    MainMenuBarVehicleLeaveButton:GwKillEditMode()

    MainMenuBarVehicleLeaveButton:HookScript("OnShow", vehicleLeave_OnShow)
    MainMenuBarVehicleLeaveButton:HookScript("OnHide", vehicleLeave_OnHide)
end
GW.AddForProfiling("Actionbars2", "setLeaveVehicleButton", setLeaveVehicleButton)

actionBarEquipUpdate = function()
    local bars = {
        "MultiBarBottomRightButton",
        "MultiBarBottomLeftButton",
        "MultiBarRightButton",
        "MultiBarLeftButton",
        "ActionButton",
        "MultiBar5Button",
        "MultiBar6Button",
        "MultiBar7Button"
    }
    for b = 1, #bars do
        local barname = bars[b]
        for i = 1, 12 do
            local button = _G[barname .. i]
            if button then
                if IsEquippedAction(button.action) then
                    local borname = barname .. i .. "Border"
                    if _G[borname] then
                        Wait(
                            0.05,
                            function()
                                _G[borname]:SetVertexColor(0, 1.0, 0, 1)
                            end
                        )
                    end
                end
            end
        end
    end
end
GW.AddForProfiling("Actionbars2", "actionBarEquipUpdate", actionBarEquipUpdate)

local function actionButtonFlashing(btn, elapsed)
    local flashtime = btn.flashtime
    flashtime = flashtime - elapsed

    if (flashtime <= 0) then
        local overtime = -flashtime
        if (overtime >= ATTACK_BUTTON_FLASH_TIME) then
            overtime = 0
        end
        flashtime = ATTACK_BUTTON_FLASH_TIME - overtime

        local flashTexture = btn.Flash
        if (flashTexture:IsShown()) then
            flashTexture:Hide()
        else
            flashTexture:Show()
        end
    end

    btn.flashtime = flashtime
end
GW.AddForProfiling("Actionbars2", "actionButtonFlashing", actionButtonFlashing)

local function actionButtons_OnUpdate(self, elapsed)
    for i = 1, 12 do
        local btn = self.gw_Buttons[i]
        -- override of /Interface/FrameXML/ActionButton.lua ActionButton_OnUpdate
        if (btn:IsFlashing()) then
            actionButtonFlashing(btn, elapsed)
        end
    end
end
GW.AddForProfiling("Actionbars2", "actionButtons_OnUpdate", actionButtons_OnUpdate)

local function multiButtons_OnUpdate(self, elapsed)
    for i = 1, 12 do
        local btn = self.gw_Buttons[i]
        -- override of /Interface/FrameXML/ActionButton.lua ActionButton_OnUpdate
        if (btn:IsFlashing()) then
            actionButtonFlashing(btn, elapsed)
        end
    end
end
GW.AddForProfiling("Actionbars2", "multiButtons_OnUpdate", multiButtons_OnUpdate)

local updateCap = 1 / 60 -- cap updates to 60 FPS
actionBar_OnUpdate = function(self, elapsed)
    local testFade = false
    self.elapsedTimer = (self.elapsedTimer or 0) + elapsed
    if self.elapsedTimer < updateCap then
        return
    end
    local elapsedToProcess = self.elapsedTimer
    self.elapsedTimer = 0
    self.rangeTimer = self.rangeTimer - elapsedToProcess
    self.fadeTimer = self.fadeTimer - elapsedToProcess

    if self.rangeTimer <= 0 then
        self.rangeTimer = TOOLTIP_UPDATE_TIME
    end

    if self.fadeTimer <= 0 then
        testFade = true
        self.fadeTimer = 0.1
    end

    -- fade bars in/out as required
    if testFade then
        fadeCheck(self)
    end

    -- update action bar buttons
    if self.gw_FadeShowing then
        actionButtons_OnUpdate(self, elapsedToProcess)
    end

     -- update multibar buttons
    if self.gw_Bar1.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar1, elapsedToProcess)
    end
    if self.gw_Bar2.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar2, elapsedToProcess)
    end
    if self.gw_Bar3.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar3, elapsedToProcess)
    end
    if self.gw_Bar4.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar4, elapsedToProcess)
    end
    if self.gw_Bar5.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar5, elapsedToProcess)
    end
    if self.gw_Bar6.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar6, elapsedToProcess)
    end
    if self.gw_Bar7.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar7, elapsedToProcess)
    end
end
GW.AddForProfiling("Actionbars2", "actionBar_OnUpdate", actionBar_OnUpdate)

local function UpdateMainBarHot()
    local fmActionbar = MainActionBar
    local used_height = MAIN_MENU_BAR_BUTTON_SIZE
    local btn_padding = GW.settings.MAINBAR_MARGIIN

    for i = 1, 12 do
        local btn = fmActionbar.gw_Buttons[i]
        btn_padding = btn_padding + MAIN_MENU_BAR_BUTTON_SIZE + GW.settings.MAINBAR_MARGIIN

        btn:ClearAllPoints()
        btn:SetPoint("LEFT", fmActionbar, "LEFT", btn_padding - GW.settings.MAINBAR_MARGIIN - MAIN_MENU_BAR_BUTTON_SIZE, (GW.settings.XPBAR_ENABLED and 0 or -14))

        if i == 6 and not GW.settings.PLAYER_AS_TARGET_FRAME then
            btn_padding = btn_padding + 108
        end

        btn.gwBackdrop.bg:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
        btn.gwBackdrop.border1:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
        btn.gwBackdrop.border2:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
        btn.gwBackdrop.border3:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
        btn.gwBackdrop.border4:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))

        btn.showMacroName = GW.settings.SHOWACTIONBAR_MACRO_NAME_ENABLED
        btn.rangeIndicatorSetting = GW.settings.MAINBAR_RANGEINDICATOR
        updateMacroName(btn)
        updateHotkey(btn)
    end
    -- position the main action bar
    fmActionbar:SetSize(btn_padding, used_height)
    fmActionbar.gw_Width = btn_padding

    actionButtons_OnUpdate(MainActionBar, 0)
end
GW.UpdateMainBarHot = UpdateMainBarHot

local function LoadActionBars(lm)
    -- init our bars
    local fmActionbar = updateMainBar()
    fmActionbar.gw_Bar1 = updateMultiBar(lm, "MultiBarBottomLeft", "MultiBarBottomLeftButton", BOTTOMLEFT_ACTIONBAR_PAGE, true)
    fmActionbar.gw_Bar2 = updateMultiBar(lm, "MultiBarBottomRight", "MultiBarBottomRightButton", BOTTOMRIGHT_ACTIONBAR_PAGE, true)
    fmActionbar.gw_Bar3 = updateMultiBar(lm, "MultiBarRight", "MultiBarRightButton", RIGHT_ACTIONBAR_PAGE)
    fmActionbar.gw_Bar4 = updateMultiBar(lm, "MultiBarLeft", "MultiBarLeftButton", LEFT_ACTIONBAR_PAGE)

    fmActionbar.gw_Bar5 = updateMultiBar(lm, "MultiBar5", "MultiBar5Button", MULTIBAR_5_ACTIONBAR_PAGE, nil)
    fmActionbar.gw_Bar6 = updateMultiBar(lm, "MultiBar6", "MultiBar6Button", MULTIBAR_6_ACTIONBAR_PAGE, nil)
    fmActionbar.gw_Bar7 = updateMultiBar(lm, "MultiBar7", "MultiBar7Button", MULTIBAR_7_ACTIONBAR_PAGE, nil)

    GW.RegisterScaleFrame(fmActionbar)

    -- hook existing multibars to track settings changes
    hooksecurefunc("SetActionBarToggles", function() C_Timer.After(1, trackBarChanges) end)
    hooksecurefunc(SpellFlyout, "Toggle", changeFlyoutStyle)
    trackBarChanges()

    -- do stuff to other pieces of the blizz UI
    hideBlizzardsActionbars()
    GW.CreateStanceBar()
    setLeaveVehicleButton()

   -- hook hotkey update calls so we can override styling changes
    local hotkeyEventTrackerFrame = CreateFrame("Frame")
    hotkeyEventTrackerFrame:RegisterEvent("UPDATE_BINDINGS")
    hotkeyEventTrackerFrame:SetScript("OnEvent", function()
        local fmMultiBar
        for y = 0, 7 do
            if y == 0 then
                fmMultiBar = fmActionbar
            else
                fmMultiBar = fmActionbar["gw_Bar" .. y]
            end
            if fmMultiBar.gw_IsEnabled then
                for i = 1, 12 do
                    updateHotkey(fmMultiBar.gw_Buttons[i])
                    FixHotKeyPosition(fmMultiBar.gw_Buttons[i], false, false, y == 0)
                end
            end
        end
    end)
end
GW.LoadActionBars = LoadActionBars
