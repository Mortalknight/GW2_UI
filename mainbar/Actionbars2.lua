local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetSetting = GW.GetSetting
local Wait = GW.Wait
local Self_Hide = GW.Self_Hide
local CountTable = GW.CountTable
local AddUpdateCB = GW.AddUpdateCB
local AFP = GW.AddProfiling

local MAIN_MENU_BAR_BUTTON_SIZE = 48

local GW_BLIZZARD_HIDE_FRAMES = {
    MainMenuBar,
    MainMenuBar.Background,
    MainMenuBarOverlayFrame,
    MainMenuBarTexture0,
    MainMenuBarTexture1,
    MainMenuBarTexture2,
    MainMenuBarTexture3,
    MainMenuBar.EndCaps.LeftEndCap,
    MainMenuBar.EndCaps.RightEndCap,
    MainMenuBar.ActionBarPageNumber,
    MainMenuBar.ActionBarPageNumber.UpButton,
    MainMenuBar.ActionBarPageNumber.DownButton,
    MainMenuBar.BorderArt,
    ReputationWatchBar,
    HonorWatchBar,
    ArtifactWatchBar,
    MainMenuExpBar,
    ActionBarUpButton,
    ActionBarDownButton,
    MainMenuBarPageNumber,
    MainMenuMaxLevelBar0,
    MainMenuMaxLevelBar1,
    MainMenuMaxLevelBar2,
    MainMenuMaxLevelBar3,
    VerticalMultiBarsContainer
}

local GW_BLIZZARD_FORCE_HIDE = {
    ReputationWatchBar,
    HonorWatchBar,
    MainMenuExpBar,
    ArtifactWatchBar,
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
    PossessBackground2
}

local settings = {
    fadeActionbar = {},
    actionbarSetting = {
        MultiBarBottomLeft = {},
        MultiBarBottomRight = {},
        MultiBarRight = {},
        MultiBarLeft = {},
        MultiBar5 = {},
        MultiBar6 = {},
        MultiBar7 = {},
    }
}

local function UpdateSettings()
    settings.buttonAssignments = GetSetting("BUTTON_ASSIGNMENTS")
    settings.mainBarMargin = tonumber(GetSetting("MAINBAR_MARGIIN"))
    settings.showMarcroName = GetSetting("SHOWACTIONBAR_MACRO_NAME_ENABLED")
    settings.mainBarRangeIndicator = GetSetting("MAINBAR_RANGEINDICATOR")
    settings.xpBarEnabled = GetSetting("XPBAR_ENABLED")
    settings.playerAsTargetFrameEnabled = GetSetting("PLAYER_AS_TARGET_FRAME")
    settings.multibarMargin = tonumber(GetSetting("MULTIBAR_MARGIIN"))
    settings.actiobarBackdropAlpha = tonumber(GetSetting("ACTIONBAR_BACKGROUND_ALPHA"))

    for _, v in pairs({"MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7"}) do
        settings.actionbarSetting[v] = GetSetting(v)
    end

    for i = 1, 8 do
        settings.fadeActionbar[i] = GetSetting("FADE_MULTIACTIONBAR_" .. i)
    end
end
GW.UpdateActionbarSettings = UpdateSettings

-- forward function defs
local actionBarEquipUpdate
local actionBar_OnUpdate

local function hideBlizzardsActionbars()
    for _, v in pairs(GW_BLIZZARD_HIDE_FRAMES) do
        if v then
            v:SetAlpha(0)
            v:EnableMouse(false)
            if v.UnregisterAllEvents then
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
AFP("hideBlizzardsActionbars", hideBlizzardsActionbars)

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
AFP("stateChanged", stateChanged)

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
AFP("changeVertexColorActionbars", changeVertexColorActionbars)

local function UpdateActionbarBorders(btn)
    local texture = GetActionTexture(btn.action)
    if texture then
        btn.gwBackdrop.border1:SetAlpha(1)
        btn.gwBackdrop.border2:SetAlpha(1)
        btn.gwBackdrop.border3:SetAlpha(1)
        btn.gwBackdrop.border4:SetAlpha(1)
    else
        btn.gwBackdrop.border1:SetAlpha(settings.actiobarBackdropAlpha)
        btn.gwBackdrop.border2:SetAlpha(settings.actiobarBackdropAlpha)
        btn.gwBackdrop.border3:SetAlpha(settings.actiobarBackdropAlpha)
        btn.gwBackdrop.border4:SetAlpha(settings.actiobarBackdropAlpha)
    end
end

local function changeFlyoutStyle(self)
    if not self.FlyoutArrow then
        return
    end

    self.FlyoutBorder:Hide()
    self.FlyoutBorderShadow:Hide()
    SpellFlyoutHorizontalBackground:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background")
    SpellFlyoutVerticalBackground:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background")
    SpellFlyoutBackgroundEnd:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background")

    local i = 1
    local btn = _G["SpellFlyoutButton1"]
    while btn do
        btn:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed")
        btn:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
        i = i + 1
        btn = _G["SpellFlyoutButton" .. i]
    end
end
AFP("changeFlyoutStyle", changeFlyoutStyle)

local function FlyoutDirection(actionbar)
    if InCombatLockdown() then return end

    for i = 1, 12 do
        local button = actionbar.gw_Buttons[i]
        if button.FlyoutArrow then
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
AFP("FlyoutDirection", FlyoutDirection)

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
AFP("fadeIn_OnFinished", fadeIn_OnFinished)

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
AFP("actionBarFrameShow", actionBarFrameShow)

local function fadeOut_OnFinished(self)
    local bar = self:GetParent()
    if bar.gw_StateTrigger then
        stateChanged()
    end
    bar:SetAlpha(0.0)
end
AFP("fadeOut_OnFinished", fadeOut_OnFinished)

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
AFP("actionBarFrameHide", actionBarFrameHide)

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
        local fadeOption = settings.fadeActionbar[i]
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
                local inFocus
                if fadeOption == "MOUSE_OVER" or fadeOption == "INCOMBAT" then
                    if f:IsMouseOver(100, -100, -100, 100) then
                        inFocus = true
                    else
                        inFocus = false
                    end
                else
                    inFocus = true
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
                if f:IsShown() and forceHide ~= true and ((inFocus and (fadeOption == "MOUSE_OVER" or fadeOption == "INCOMBAT") and not inCombat) or (inFocus or (inCombat and fadeOption == "INCOMBAT")) or isFlyout or fadeOption == "ALWAYS") then
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
AFP("fadeCheck", fadeCheck)

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
AFP("createFaderAnim", createFaderAnim)

local function updateHotkey(self)
    local hotkey = self.HotKey
    local text = hotkey:GetText()

    if text == nil then
        return
    end

    if settings.buttonAssignments then
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

    text = gsub(text, "(s%-)", "S")
    text = gsub(text, "(a%-)", "A")
    text = gsub(text, "(c%-)", "C")
    text = gsub(text, KEY_BUTTON3, "M3") --middle mouse Button
    text = gsub(text, gsub(KEY_BUTTON4, " 4", ""), "M") -- mouse button
    text = gsub(text, KEY_PAGEUP, "PU")
    text = gsub(text, KEY_PAGEDOWN, "PD")
    text = gsub(text, KEY_SPACE, "SpB")
    text = gsub(text, KEY_INSERT, "Ins")
    text = gsub(text, KEY_HOME, "Hm")
    text = gsub(text, KEY_DELETE, "Del")
    text = gsub(text, KEY_LEFT, "LT")
    text = gsub(text, KEY_RIGHT, "RT")
    text = gsub(text, KEY_UP, "UP")
    text = gsub(text, KEY_DOWN, "DN")
    text = gsub(text, gsub(KEY_NUMPADPLUS, "%+", ""), "N") -- for all numpad keys
    text = gsub(text, KEY_MOUSEWHEELDOWN, 'MwD')
    text = gsub(text, KEY_MOUSEWHEELUP, 'MwU')

    if hotkey:GetText() == RANGE_INDICATOR then
        hotkey:SetText("")
    else
        hotkey:SetText(text)
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
AFP("hideBackdrop", hideBackdrop)

local function showBackdrop(self)
    self.gwBackdrop:Show()
end
AFP("showBackdrop", showBackdrop)

local function FixHotKeyPosition(button, isStanceButton, isPetButton, isMainBar)
    button.HotKey:ClearAllPoints()
    if isPetButton or isStanceButton then
        button.HotKey:SetPoint("CENTER", button, "BOTTOM", 0, 5)
    elseif isMainBar then
        button.HotKey:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
        button.HotKey:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        button.HotKey:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINED")
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
        btn.Count:SetFont(UNIT_NAME_FONT, 14, "OUTLINED")
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
            btn.Border:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\stancebar-border")
        else
            btn.Border:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder")
        end
    end
    if btn.NormalTexture then
        btn:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagnormal")
    end

    if _G[buttonName .. "FloatingBG"] then
        _G[buttonName .. "FloatingBG"]:SetTexture(nil)
    end
    if _G[buttonName .. "NormalTexture"] then
        _G[buttonName .. "NormalTexture"]:SetTexture(nil)
        _G[buttonName .. "NormalTexture"]:Hide()
    end
    if _G[buttonName .. "NormalTexture2"] then
        _G[buttonName .. "NormalTexture2"]:SetTexture(nil)
        _G[buttonName .. "NormalTexture2"]:Hide()
    end
    if btn.AutoCastable then
        btn.AutoCastable:SetSize(btnWidth * 2, btnWidth * 2)
    end
    if btn.AutoCastShine then
        btn.AutoCastShine:SetSize(btnWidth, btnWidth)
    end
    if btn.NewActionTexture then
        btn.NewActionTexture:SetSize(btnWidth, btnWidth)
    end
    if btn.SpellHighlightTexture then
        btn.SpellHighlightTexture:SetSize(btnWidth, btnWidth)
    end

    if btn.HighlightTexture then
        btn.HighlightTexture:SetSize(btnWidth, btnWidth)
    end

    if btn.BottomDivider then
        btn.BottomDivider:SetAlpha(0)
    end

    if btn.IconMask then btn.IconMask:Hide() end

    btn:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed")
    btn:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")

    if btn.HighlightTexture then
        btn.HighlightTexture:SetSize(btnWidth, btnWidth)
    end
    if btn.SetCheckedTexture then
        btn:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
    end
    btn.CheckedTexture:SetSize(btnWidth, btnWidth)

    updateMacroName(btn)

    if noBackDrop == nil or noBackDrop == false then
        local backDrop = CreateFrame("Frame", nil, btn, "GwActionButtonBackdropTmpl")
        local backDropSize = 1

        backDrop:SetPoint("TOPLEFT", btn, "TOPLEFT", -backDropSize, backDropSize)
        backDrop:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", backDropSize, -backDropSize)

        btn.gwBackdrop = backDrop

        if not isStanceButton and not isPet then
            btn.gwBackdrop.bg:SetAlpha(settings.actiobarBackdropAlpha)
            btn.gwBackdrop.border1:SetAlpha(settings.actiobarBackdropAlpha)
            btn.gwBackdrop.border2:SetAlpha(settings.actiobarBackdropAlpha)
            btn.gwBackdrop.border3:SetAlpha(settings.actiobarBackdropAlpha)
            btn.gwBackdrop.border4:SetAlpha(settings.actiobarBackdropAlpha)
        end
        --btn:HookScript("OnHide", hideBackdrop)
        --btn:HookScript("OnShow", showBackdrop)
    end
end
GW.setActionButtonStyle = setActionButtonStyle

local function main_OnEvent(_, event)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        actionBarEquipUpdate()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        local forceCombat = event == "PLAYER_REGEN_DISABLED"
        fadeCheck(MainMenuBar, forceCombat)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        C_Timer.After(1.1, function()
            GW.Libs.LEMO:LoadLayouts()
            if GW.Libs.LEMO:GetActiveLayout() ~= "GW2_Layout" then
                GW.Libs.LEMO:SetActiveLayout("GW2_Layout")
                GW.Libs.LEMO:ApplyChanges()
            end
        end)
    end
end
AFP("main_OnEvent", main_OnEvent)

local function updateMainBar()
    local fmActionbar = MainMenuBar

    MainMenuBar:KillEditMode()

    local used_height = MAIN_MENU_BAR_BUTTON_SIZE
    local btn_padding = settings.mainBarMargin

    fmActionbar.gw_Buttons = {}
    fmActionbar.rangeTimer = -1
    fmActionbar.fadeTimer = -1
    fmActionbar.elapsedTimer = -1

    for i = 1, 12 do
        local btn = _G["ActionButton" .. i]
        fmActionbar.gw_Buttons[i] = btn

        if btn then
            btn:SetScript("OnUpdate", nil) -- disable the default button update handler
            btn.RightDivider:Hide()
            btn.SlotArt:Hide()

            local hotkey = _G["ActionButton" .. i .. "HotKey"]
            btn_padding = btn_padding + MAIN_MENU_BAR_BUTTON_SIZE + settings.mainBarMargin
            btn:SetSize(MAIN_MENU_BAR_BUTTON_SIZE, MAIN_MENU_BAR_BUTTON_SIZE)
            btn.showMacroName = settings.showMarcroName

            btn.hkBg = CreateFrame("Frame", "GwHotKeyBackDropActionButton" .. i, hotkey:GetParent(), "GwActionHotkeyBackdropTmpl")
            btn.hkBg:SetPoint("CENTER", hotkey, "CENTER", 0, 0)
            btn.hkBg.texture:SetParent(hotkey:GetParent())
            setActionButtonStyle("ActionButton" .. i)
            updateHotkey(btn)
            hooksecurefunc(btn, "UpdateUsable", changeVertexColorActionbars)
            hooksecurefunc(btn, "UpdateFlyout", changeFlyoutStyle)
            hooksecurefunc(btn, "Update", UpdateActionbarBorders)

            hotkey:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
            hotkey:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
            hotkey:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINED")
            hotkey:SetTextColor(1, 1, 1)
            btn.changedColor = false
            btn.rangeIndicatorSetting = settings.mainBarRangeIndicator

            if IsEquippedAction(btn.action) then
                local borname = "ActionButton" .. i .. "Border"
                if _G[borname] then
                    _G[borname]:SetVertexColor(0, 1, 0, 1)
                end
            end

            local rangeIndicator = CreateFrame("FRAME", "GwActionRangeIndicator" .. i, hotkey:GetParent(), "GwActionRangeIndicatorTmpl")
            rangeIndicator:SetFrameStrata("BACKGROUND")
            rangeIndicator:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", -1, -2)
            rangeIndicator:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 1, -2)
            _G["GwActionRangeIndicator" .. i .. "Texture"]:SetVertexColor(147 / 255, 19 / 255, 2 / 255)
            rangeIndicator:Hide()

            btn.gw_RangeIndicator = rangeIndicator

            btn:ClearAllPoints()
            btn:SetPoint("LEFT", fmActionbar, "LEFT", btn_padding - settings.mainBarMargin - MAIN_MENU_BAR_BUTTON_SIZE, settings.xpBarEnabled and 0 or -14)

            if i == 6 and not settings.playerAsTargetFrameEnabled then
                btn_padding = btn_padding + 108
            end
        end
    end

    -- position the main action bar
    fmActionbar:SetSize(btn_padding, used_height)
    fmActionbar.gw_Width = btn_padding

    -- event/update handlers
    AddUpdateCB(actionBar_OnUpdate, fmActionbar)
    local helperFrame = CreateFrame("Frame")
    helperFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    helperFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    helperFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    helperFrame:HookScript("OnEvent", main_OnEvent)

    -- disable default main action bar behaviors
    --MainMenuBar:UnregisterAllEvents()
    --MainMenuBar:SetScript("OnUpdate", nil)
    --MainMenuBar:EnableMouse(false)
    MainMenuBar:SetMovable(1)
    MainMenuBar:SetUserPlaced(true)
    MainMenuBar:SetMovable(0)
    MainMenuBar.ignoreFramePositionManager = true

    -- add a reposition hook to spec switches
    helperFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

    -- set fader logic
    createFaderAnim(fmActionbar, true)
    fmActionbar.gw_FadeShowing = true

    return fmActionbar
end
AFP("updateMainBar", updateMainBar)

local function trackBarChanges()
    local fmActionbar = MainMenuBar
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
AFP("trackBarChanges", trackBarChanges)

local function updateMultiBar(lm, barName, buttonName, actionPage, state)
    local multibar = _G[barName]
    local used_width = 0
    local used_height = settings.actionbarSetting[barName].size
    local btn_padding = 0
    local btn_padding_y = 0
    local btn_this_row = 0

    multibar:KillEditMode()

    local fmMultibar = CreateFrame("FRAME", "Gw" .. barName, UIParent, "GwMultibarTmpl")
    GW.MixinHideDuringPetAndOverride(fmMultibar)
    if actionPage ~= nil then
        fmMultibar:SetAttribute("actionpage", actionPage)
        fmMultibar:SetFrameStrata("LOW")
    end
    fmMultibar.gw_Buttons = {}
    fmMultibar.originalBarName = barName

    for i = 1, 12 do
        local btn = _G[buttonName .. i]
        fmMultibar.gw_Buttons[i] = btn

        if btn then
            if actionPage then
                -- reparent button to our action bar
                btn:SetParent(fmMultibar)
            end
            btn:SetScript("OnUpdate", nil) -- disable the default button update handler
            btn.SlotBackground:SetAlpha(0)

            btn:SetSize(settings.actionbarSetting[barName].size, settings.actionbarSetting[barName].size)
            updateHotkey(btn)

            btn.showMacroName = settings.showMarcroName

            setActionButtonStyle(buttonName .. i)

            hooksecurefunc(btn, "UpdateUsable", changeVertexColorActionbars)
            hooksecurefunc(btn, "UpdateFlyout", changeFlyoutStyle)
            hooksecurefunc(btn, "Update", UpdateActionbarBorders)

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

            btn_padding = btn_padding + settings.actionbarSetting[barName].size + settings.multibarMargin
            btn_this_row = btn_this_row + 1
            used_width = btn_padding

            if btn_this_row == settings.actionbarSetting[barName].ButtonsPerRow then
                btn_padding_y = btn_padding_y + settings.actionbarSetting[barName].size + settings.multibarMargin
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
    if (barName == "MultiBarBottomLeft" or barName == "MultiBarBottomRight") and (not settings.xpBarEnabled or settings.playerAsTargetFrameEnabled) and not fmMultibar.isMoved  then
        local yOff = not settings.xpBarEnabled and 14 or 0
        local xOff = settings.playerAsTargetFrameEnabled and 56 or 0
        fmMultibar.gwMover:ClearAllPoints()
        if barName == "MultiBarBottomLeft" then
            fmMultibar.gwMover:SetPoint(settings.actionbarSetting[barName].point, UIParent, settings.actionbarSetting[barName].relativePoint, settings.actionbarSetting[barName].xOfs + xOff, settings.actionbarSetting[barName].yOfs - yOff)
        elseif barName == "MultiBarBottomRight" then
            fmMultibar.gwMover:SetPoint(settings.actionbarSetting[barName].point, UIParent, settings.actionbarSetting[barName].relativePoint, settings.actionbarSetting[barName].xOfs - xOff, settings.actionbarSetting[barName].yOfs - yOff)
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
AFP("updateMultiBar", updateMultiBar)

local function UpdateMultibarButtons()
    local fmActionbar = MainMenuBar
    local fmMultiBar

    for y = 1, 7 do
        if y == 1 then fmMultiBar = fmActionbar.gw_Bar1 end
        if y == 2 then fmMultiBar = fmActionbar.gw_Bar2 end
        if y == 3 then fmMultiBar = fmActionbar.gw_Bar3 end
        if y == 4 then fmMultiBar = fmActionbar.gw_Bar4 end
        if y == 5 then fmMultiBar = fmActionbar.gw_Bar5 end
        if y == 6 then fmMultiBar = fmActionbar.gw_Bar6 end
        if y == 7 then fmMultiBar = fmActionbar.gw_Bar7 end
        if fmMultiBar.gw_IsEnabled then
            local used_height = 0
            local btn_padding = 0
            local btn_padding_y = 0
            local btn_this_row = 0
            local used_width = 0
            for i = 1, 12 do
                local btn = fmMultiBar.gw_Buttons[i]

                btn.gwX = btn_padding
                btn.gwY = btn_padding_y
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", fmMultiBar, "TOPLEFT", btn_padding, -btn_padding_y)

                btn_padding = btn_padding + settings.actionbarSetting[fmMultiBar.originalBarName].size + settings.multibarMargin
                btn_this_row = btn_this_row + 1
                used_width = btn_padding

                if btn_this_row == settings.actionbarSetting[fmMultiBar.originalBarName].ButtonsPerRow then
                    btn_padding_y = btn_padding_y + settings.actionbarSetting[fmMultiBar.originalBarName].size + settings.multibarMargin
                    btn_this_row = 0
                    btn_padding = 0
                    used_height = used_height + settings.actionbarSetting[fmMultiBar.originalBarName].size + settings.multibarMargin
                end

                btn.gwBackdrop.bg:SetAlpha(settings.actiobarBackdropAlpha)
                btn.gwBackdrop.border1:SetAlpha(settings.actiobarBackdropAlpha)
                btn.gwBackdrop.border2:SetAlpha(settings.actiobarBackdropAlpha)
                btn.gwBackdrop.border3:SetAlpha(settings.actiobarBackdropAlpha)
                btn.gwBackdrop.border4:SetAlpha(settings.actiobarBackdropAlpha)

                btn.showMacroName = settings.showMarcroName
                updateMacroName(btn)
                updateHotkey(btn)
            end

            fmMultiBar.gwMover:SetSize(used_width, used_height)
            fmMultiBar:SetSize(used_width, used_height)
        end
    end
end
GW.UpdateMultibarButtons = UpdateMultibarButtons

local function setLeaveVehicleButton()
    MainMenuBarVehicleLeaveButton:SetParent(MainMenuBar)
    MainMenuBarVehicleLeaveButton:ClearAllPoints()
    MainMenuBarVehicleLeaveButton:SetPoint("LEFT", ActionButton12, "RIGHT", 0, 0)

    MainMenuBarVehicleLeaveButton:KillEditMode()

    hooksecurefunc(MainMenuBarVehicleLeaveButton, "SetPoint", function(_, _, parent)
        if parent ~= ActionButton12 then
            MainMenuBarVehicleLeaveButton:ClearAllPoints()
            MainMenuBarVehicleLeaveButton:SetParent(UIParent)
            MainMenuBarVehicleLeaveButton:SetPoint("LEFT", ActionButton12, "RIGHT", 0, 0)
        end
    end)
end
AFP("setLeaveVehicleButton", setLeaveVehicleButton)

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
AFP("actionBarEquipUpdate", actionBarEquipUpdate)

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
AFP("actionButtonFlashing", actionButtonFlashing)

local out_R, out_G, out_B = RED_FONT_COLOR:GetRGB()
local function actionButtons_OnUpdate(self, elapsed, testRange)
    for i = 1, 12 do
        local btn = self.gw_Buttons[i]
        -- override of /Interface/FrameXML/ActionButton.lua ActionButton_OnUpdate
        if (btn:IsFlashing()) then
            actionButtonFlashing(btn, elapsed)
        end

        if testRange then
            local valid = IsActionInRange(btn.action)
            local checksRange = (valid ~= nil)
            local inRange = checksRange and valid
            if checksRange and not inRange then
                if btn.rangeIndicatorSetting == "RED_INDICATOR" then
                    btn.gw_RangeIndicator:Show()
                elseif btn.rangeIndicatorSetting == "RED_OVERLAY" then
                    btn.icon:SetVertexColor(out_R, out_G, out_B)
                    btn.changedColor = true
                elseif btn.rangeIndicatorSetting == "BOTH" then
                    btn.gw_RangeIndicator:Show()
                    btn.icon:SetVertexColor(out_R, out_G, out_B)
                    btn.changedColor = true
                end
            else
                local isUsable, notEnoughMana = IsUsableAction(btn.action)

                if btn.rangeIndicatorSetting == "RED_INDICATOR" then
                    btn.gw_RangeIndicator:Hide()
                elseif btn.rangeIndicatorSetting == "RED_OVERLAY" then
                    if btn.changedColor then
                        if isUsable then
                            btn.icon:SetVertexColor(1, 1, 1)
                        elseif notEnoughMana then
                            btn.icon:SetVertexColor(0.5, 0.5, 1.0)
                        else
                            btn.icon:SetVertexColor(0.4, 0.4, 0.4)
                        end
                        btn.changedColor = false
                    end
                elseif btn.rangeIndicatorSetting == "BOTH" then
                    btn.gw_RangeIndicator:Hide()
                    if btn.changedColor then
                        if isUsable then
                            btn.icon:SetVertexColor(1, 1, 1)
                        elseif notEnoughMana then
                            btn.icon:SetVertexColor(0.5, 0.5, 1.0)
                        else
                            btn.icon:SetVertexColor(0.4, 0.4, 0.4)
                        end
                        btn.changedColor = false
                    end
                end
            end
        end
    end
end
AFP("actionButtons_OnUpdate", actionButtons_OnUpdate)

local function multiButtons_OnUpdate(self, elapsed, testRange)
    for i = 1, 12 do
        local btn = self.gw_Buttons[i]
        -- override of /Interface/FrameXML/ActionButton.lua ActionButton_OnUpdate
        if (btn:IsFlashing()) then
            actionButtonFlashing(btn, elapsed)
        end

        if testRange then
            local valid = IsActionInRange(btn.action)
            local checksRange = (valid ~= nil)
            local inRange = checksRange and valid
            if checksRange and not inRange then
                btn.icon:SetVertexColor(out_R, out_G, out_B)
                btn.changedColor = true
            else
                if btn.changedColor then
                    btn.icon:SetVertexColor(1, 1, 1)
                    btn.changedColor = false
                end
            end
        end
    end
end
AFP("multiButtons_OnUpdate", multiButtons_OnUpdate)

local updateCap = 1 / 60 -- cap updates to 60 FPS
actionBar_OnUpdate = function(self, elapsed)
    local testRange = false
    local testFade = false
    self.rangeTimer = self.rangeTimer - elapsed
    self.fadeTimer = self.fadeTimer - elapsed
    self.elapsedTimer = self.elapsedTimer - elapsed

    if self.elapsedTimer > 0 then
        return
    end
    self.elapsedTimer = updateCap

    if self.rangeTimer <= 0 then
        testRange = true
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
        actionButtons_OnUpdate(self, elapsed, testRange)
    end

    -- update multibar buttons
    if self.gw_Bar1.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar1, elapsed, testRange)
    end
    if self.gw_Bar2.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar2, elapsed, testRange)
    end
    if self.gw_Bar3.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar3, elapsed, testRange)
    end
    if self.gw_Bar4.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar4, elapsed, testRange)
    end
    if self.gw_Bar5.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar5, elapsed, testRange)
    end
    if self.gw_Bar6.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar6, elapsed, testRange)
    end
    if self.gw_Bar7.gw_FadeShowing then
        multiButtons_OnUpdate(self.gw_Bar7, elapsed, testRange)
    end
end
AFP("actionBar_OnUpdate", actionBar_OnUpdate)

local function UpdateMainBarHot()
    local fmActionbar = MainMenuBar
    local used_height = MAIN_MENU_BAR_BUTTON_SIZE
    local btn_padding = settings.mainBarMargin

    for i = 1, 12 do
        local btn = fmActionbar.gw_Buttons[i]
        btn_padding = btn_padding + MAIN_MENU_BAR_BUTTON_SIZE + settings.mainBarMargin

        btn:ClearAllPoints()
        btn:SetPoint("LEFT", fmActionbar, "LEFT", btn_padding - settings.mainBarMargin - MAIN_MENU_BAR_BUTTON_SIZE, (settings.xpBarEnabled and 0 or -14))

        if i == 6 and not settings.playerAsTargetFrameEnabled then
            btn_padding = btn_padding + 108
        end

        btn.gwBackdrop.bg:SetAlpha(settings.actiobarBackdropAlpha)
        btn.gwBackdrop.border1:SetAlpha(settings.actiobarBackdropAlpha)
        btn.gwBackdrop.border2:SetAlpha(settings.actiobarBackdropAlpha)
        btn.gwBackdrop.border3:SetAlpha(settings.actiobarBackdropAlpha)
        btn.gwBackdrop.border4:SetAlpha(settings.actiobarBackdropAlpha)

        btn.showMacroName = settings.showMarcroName
        btn.rangeIndicatorSetting = settings.mainBarRangeIndicator
        updateMacroName(btn)
        updateHotkey(btn)
    end
    -- position the main action bar
    fmActionbar:SetSize(btn_padding, used_height)
    fmActionbar.gw_Width = btn_padding

    actionButtons_OnUpdate(MainMenuBar, 0, true)
end
GW.UpdateMainBarHot = UpdateMainBarHot

local function LoadActionBars(lm)
    UpdateSettings()
    -- init our bars
    local fmActionbar = updateMainBar()
    fmActionbar.gw_Bar1 = updateMultiBar(lm, "MultiBarBottomLeft", "MultiBarBottomLeftButton", BOTTOMLEFT_ACTIONBAR_PAGE, true)
    fmActionbar.gw_Bar2 = updateMultiBar(lm, "MultiBarBottomRight", "MultiBarBottomRightButton", BOTTOMRIGHT_ACTIONBAR_PAGE, true)
    fmActionbar.gw_Bar3 = updateMultiBar(lm, "MultiBarRight", "MultiBarRightButton", RIGHT_ACTIONBAR_PAGE, nil)
    fmActionbar.gw_Bar4 = updateMultiBar(lm, "MultiBarLeft", "MultiBarLeftButton", LEFT_ACTIONBAR_PAGE, nil)

    fmActionbar.gw_Bar5 = updateMultiBar(lm, "MultiBar5", "MultiBar5Button", MULTIBAR_5_ACTIONBAR_PAGE, nil)
    fmActionbar.gw_Bar6 = updateMultiBar(lm, "MultiBar6", "MultiBar6Button", MULTIBAR_6_ACTIONBAR_PAGE, nil)
    fmActionbar.gw_Bar7 = updateMultiBar(lm, "MultiBar7", "MultiBar7Button", MULTIBAR_7_ACTIONBAR_PAGE, nil)

    GW.RegisterScaleFrame(fmActionbar)

    -- hook existing multibars to track settings changes
    hooksecurefunc("SetActionBarToggles", function() C_Timer.After(1, trackBarChanges) end)
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
