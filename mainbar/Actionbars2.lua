local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetSetting = GW.GetSetting
local Wait = GW.Wait
local Self_Hide = GW.Self_Hide
local IsFrameModified = GW.IsFrameModified
local CountTable = GW.CountTable
local AddUpdateCB = GW.AddUpdateCB

local MAIN_MENU_BAR_BUTTON_SIZE = 48
local MAIN_MENU_BAR_BUTTON_MARGIN = 5

local GW_BLIZZARD_HIDE_FRAMES = {
    MainMenuBar,
    MainMenuBarArtFrameBackground,
    MainMenuBarOverlayFrame,
    MainMenuBarTexture0,
    MainMenuBarTexture1,
    MainMenuBarTexture2,
    MainMenuBarTexture3,
    MainMenuBarArtFrame.LeftEndCap,
    MainMenuBarArtFrame.RightEndCap,
    MainMenuBarArtFrame.PageNumber,
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
                ActionButton_UpdateFlyout(button)
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

    for i = 1, 5 do
        local f = self["gw_Bar" .. i]
        if i == 5 then f = self end
        local fadeOption = GetSetting("FADE_MULTIACTIONBAR_" .. i)
        if f then
            if isDirty and not inLockdown then
                -- this should only be set after a bar setting change (including initial load)
                if f.gw_IsEnabled then
                    f:Show()
                    actionBarFrameShow(f, true)
                else
                    f:Hide()
                    actionBarFrameHide(f, true)
                end
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

    if not inLockdown and self.gw_DirtySetting then
        local xOff
        local btn_padding = self.gw_Width
        if self.gw_Bar2:IsShown() then
            xOff = (804 - btn_padding) / 2
        else
            xOff = -(btn_padding - 550) / 2
        end
        self:ClearAllPoints()
        self:SetPoint("TOP", UIParent, "BOTTOM", xOff, 80)
        self.gw_DirtySetting = false
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
    local text = hotkey:GetText()

    if text == nil then
        return
    end

    text = string.gsub(text, "(s%-)", "S")
    text = string.gsub(text, "(a%-)", "A")
    text = string.gsub(text, "(c%-)", "C")
    text = string.gsub(text, "(Mouse Button )", "M")
    text = string.gsub(text, "(Middle Mouse)", "M3")
    text = string.gsub(text, "(Num Pad )", "N")
    text = string.gsub(text, "(Page Up)", "PU")
    text = string.gsub(text, "(Page Down)", "PD")
    text = string.gsub(text, "(Spacebar)", "SpB")
    text = string.gsub(text, "(Insert)", "Ins")
    text = string.gsub(text, "(Home)", "Hm")
    text = string.gsub(text, "(Delete)", "Del")
    text = string.gsub(text, "(Left Arrow)", "LT")
    text = string.gsub(text, "(Right Arrow)", "RT")
    text = string.gsub(text, "(Up Arrow)", "UP")
    text = string.gsub(text, "(Down Arrow)", "DN")

    if hotkey:GetText() == RANGE_INDICATOR or not GetSetting("BUTTON_ASSIGNMENTS") then
        hotkey:SetText("")
    else
        hotkey:SetText(text)
    end
end
GW.updateHotkey = updateHotkey
GW.AddForProfiling("Actionbars2", "updateHotkey", updateHotkey)

local function hideBackdrop(self)
    self.gwBackdrop:Hide()
end
GW.AddForProfiling("Actionbars2", "hideBackdrop", hideBackdrop)

local function showBackdrop(self)
    self.gwBackdrop:Show()
end
GW.AddForProfiling("Actionbars2", "showBackdrop", showBackdrop)

local function setActionButtonStyle(buttonName, noBackDrop, hideUnused, showName, isStanceButton, isPet)
    local btn = _G[buttonName]

    if btn.icon ~= nil then
        btn.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
    if btn.HotKey ~= nil then
        btn.HotKey:ClearAllPoints()
        if isPet then
            btn.HotKey:SetPoint("CENTER", btn, "BOTTOM", 0, 5)
        else
            btn.HotKey:SetPoint("CENTER", btn, "BOTTOM", 0, 0)
        end
        btn.HotKey:SetJustifyH("CENTER")
    end
    if btn.Count ~= nil then
        btn.Count:ClearAllPoints()
        btn.Count:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -3, -3)
        btn.Count:SetJustifyH("RIGHT")
        btn.Count:SetFont(UNIT_NAME_FONT, 14, "OUTLINED")
        btn.Count:SetTextColor(1, 1, 0.6)
    end

    if btn.Border ~= nil then
        btn.Border:SetSize(btn:GetWidth(), btn:GetWidth())
        btn.Border:SetBlendMode("BLEND")
        if isStanceButton then
            btn.Border:Show()
            btn.Border:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\stancebar-border")
        else
            btn.Border:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder")
        end
    end
    if btn.NormalTexture ~= nil then
        btn:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagnormal")
    end

    if _G[buttonName .. "FloatingBG"] ~= nil then
        _G[buttonName .. "FloatingBG"]:SetTexture(nil)
    end
    if _G[buttonName .. "NormalTexture2"] ~= nil then
        _G[buttonName .. "NormalTexture2"]:SetTexture(nil)
        _G[buttonName .. "NormalTexture2"]:Hide()
    end
    if btn.AutoCastable then
        btn.AutoCastable:SetSize(btn:GetWidth() * 2, btn:GetWidth() * 2)
    end
    if btn.AutoCastShine then
        btn.AutoCastShine:SetSize(btn:GetWidth(), btn:GetWidth())
    end
    if btn.NewActionTexture then
        btn.NewActionTexture:SetSize(btn:GetWidth(), btn:GetWidth())
    end
    if btn.SpellHighlightTexture then
        btn.SpellHighlightTexture:SetSize(btn:GetWidth(), btn:GetWidth())
    end

    btn:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed")
    btn:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
    if btn.SetCheckedTexture then btn:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress") end

    if btn.Name then
        if showName then
            btn.Name:SetPoint("TOPLEFT", btn, "TOPLEFT")
            btn.Name:SetJustifyH("LEFT")
            local font, fontHeight, fontFlags = btn.Name:GetFont()
            btn.Name:SetFont(font, fontHeight, "OUTLINED")
        else
            btn.Name:SetAlpha(0)
        end
    end

    if noBackDrop == nil or noBackDrop == false then
        local backDrop = CreateFrame("Frame", nil, btn, "GwActionButtonBackdropTmpl")
        local backDropSize = 1
        if btn:GetWidth() > 40 then
            backDropSize = 2
        end

        backDrop:SetPoint("TOPLEFT", btn, "TOPLEFT", -backDropSize, backDropSize)
        backDrop:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", backDropSize, -backDropSize)

        btn.gwBackdrop = backDrop
    end

    if hideUnused == true then
        btn.gwBackdrop:Hide()
        btn:HookScript("OnHide", hideBackdrop)
        btn:HookScript("OnShow", showBackdrop)
    end
end
GW.setActionButtonStyle = setActionButtonStyle
GW.AddForProfiling("Actionbars2", "setActionButtonStyle", setActionButtonStyle)

local function main_OnEvent(self, event)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        actionBarEquipUpdate()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        local forceCombat = (event == "PLAYER_REGEN_DISABLED")
        fadeCheck(self, forceCombat)
    end
end
GW.AddForProfiling("Actionbars2", "main_OnEvent", main_OnEvent)

local function updateMainBar()
    local fmActionbar = MainMenuBarArtFrame

    local used_height = MAIN_MENU_BAR_BUTTON_SIZE
    local btn_padding = MAIN_MENU_BAR_BUTTON_MARGIN

    fmActionbar.gw_Buttons = {}
    fmActionbar.gw_Backdrops = {}
    fmActionbar.rangeTimer = -1
    fmActionbar.fadeTimer = -1
    fmActionbar.elapsedTimer = -1

    local rangeIndicatorSetting = GetSetting("MAINBAR_RANGEINDICATOR")
    for i = 1, 12 do
        local btn = _G["ActionButton" .. i]
        fmActionbar.gw_Buttons[i] = btn

        if btn ~= nil then
            -- create a backdrop not attached to button because default actionbar backdrop logic is wonky
            local backDrop = CreateFrame("Frame", nil, fmActionbar, "GwActionButtonBackdropTmpl")
            local backDropSize = 1
            if btn:GetWidth() > 40 then
                backDropSize = 2
            end
            backDrop:SetPoint("TOPLEFT", btn, "TOPLEFT", -backDropSize, backDropSize)
            backDrop:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", backDropSize, -backDropSize)
            fmActionbar.gw_Backdrops[i] = backDrop

            btn:SetScript("OnUpdate", nil) -- disable the default button update handler

            local hotkey = _G["ActionButton" .. i .. "HotKey"]
            btn_padding = btn_padding + MAIN_MENU_BAR_BUTTON_SIZE + MAIN_MENU_BAR_BUTTON_MARGIN
            btn:SetSize(MAIN_MENU_BAR_BUTTON_SIZE, MAIN_MENU_BAR_BUTTON_SIZE)

            local showName = GetSetting("SHOWACTIONBAR_MACRO_NAME_ENABLED")
            setActionButtonStyle("ActionButton" .. i, true, nil, showName)
            updateHotkey(btn)

            hotkey:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
            hotkey:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
            hotkey:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINED")
            hotkey:SetTextColor(1, 1, 1)
            btn.changedColor = false
            btn.rangeIndicatorSetting = rangeIndicatorSetting

            if IsEquippedAction(btn.action) then
                local borname = "ActionButton" .. i .. "Border"
                if _G[borname] then
                    _G[borname]:SetVertexColor(0, 1, 0, 1)
                end
            end

            local rangeIndicator = CreateFrame("FRAME", "GwActionRangeIndicator" .. i, hotkey:GetParent(), "GwActionRangeIndicatorTmpl")
            rangeIndicator:SetFrameStrata("BACKGROUND", 1)
            rangeIndicator:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", -1, -2)
            rangeIndicator:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 1, -2)
            _G["GwActionRangeIndicator" .. i .. "Texture"]:SetVertexColor(147 / 255, 19 / 255, 2 / 255)
            rangeIndicator:Hide()

            btn["gw_RangeIndicator"] = rangeIndicator
            btn["gw_HotKey"] = hotkey

            if GetSetting("BUTTON_ASSIGNMENTS") then
                local hkBg = CreateFrame("Frame", "GwHotKeyBackDropActionButton" .. i, hotkey:GetParent(), "GwActionHotkeyBackdropTmpl")

                hkBg:SetPoint("CENTER", hotkey, "CENTER", 0, 0)
                _G["GwHotKeyBackDropActionButton" .. i .. "Texture"]:SetParent(hotkey:GetParent())
            end

            btn:ClearAllPoints()
            btn:SetPoint(
                "LEFT",
                fmActionbar,
                "LEFT",
                btn_padding - MAIN_MENU_BAR_BUTTON_MARGIN - MAIN_MENU_BAR_BUTTON_SIZE,
                (GetSetting("XPBAR_ENABLED") and 0 or -14)
            )

            if i == 6 and not GetSetting("PLAYER_AS_TARGET_FRAME") then
                btn_padding = btn_padding + 108
            end
        end
    end

    -- position the main action bar
    fmActionbar:ClearAllPoints()
    fmActionbar:SetPoint("TOP", UIParent, "BOTTOM", 0, 80)
    fmActionbar:SetSize(btn_padding, used_height)
    fmActionbar.gw_Width = btn_padding

    -- event/update handlers
    AddUpdateCB(actionBar_OnUpdate, fmActionbar)
    fmActionbar:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    fmActionbar:RegisterEvent("PLAYER_REGEN_DISABLED")
    fmActionbar:RegisterEvent("PLAYER_REGEN_ENABLED")
    fmActionbar:SetScript("OnEvent", main_OnEvent)

    -- disable default main action bar behaviors
    MainMenuBar:UnregisterAllEvents()
    MainMenuBar:SetScript("OnUpdate", nil)
    MainMenuBar:EnableMouse(false)
    MainMenuBar:SetMovable(1)
    MainMenuBar:SetUserPlaced(true)
    MainMenuBar:SetMovable(0)
    -- even with IsUserPlaced set, the Blizz multibar handlers mess with the width so reset in fadeCheck DirtySetting

    -- set fader logic
    createFaderAnim(fmActionbar, true)

    return fmActionbar
end
GW.AddForProfiling("Actionbars2", "updateMainBar", updateMainBar)

local function trackBarChanges()
    local fmActionbar = MainMenuBarArtFrame
    if not fmActionbar then
        return
    end

    local show1, show2, show3, show4
    -- need explicit bool's because we test for nil as a separate case
    if SHOW_MULTI_ACTIONBAR_1 then
        show1 = true
    else
        show1 = false
    end
    if SHOW_MULTI_ACTIONBAR_2 then
        show2 = true
    else
        show2 = false
    end
    if SHOW_MULTI_ACTIONBAR_3 then
        show3 = true
    else
        show3 = false
    end
    if SHOW_MULTI_ACTIONBAR_3 and SHOW_MULTI_ACTIONBAR_4 then
        show4 = true
    else
        show4 = false
    end

    -- set that we'll need to immediately re-calc visible bars and mainbar offset (happens in fadeCheck)
    fmActionbar.gw_DirtySetting = true
    fmActionbar.fadeTimer = -1
    fmActionbar.elapsedTimer = -1

    -- store the new enabled state for each multibar
    fmActionbar.gw_Bar1.gw_IsEnabled = show1
    fmActionbar.gw_Bar2.gw_IsEnabled = show2
    fmActionbar.gw_Bar3.gw_IsEnabled = show3
    fmActionbar.gw_Bar4.gw_IsEnabled = show4

    fmActionbar.gw_IsEnabled = true
end

local function updateMultiBar(lm, barName, buttonName, actionPage, state, showName)
    local multibar = _G[barName]
    local settings = GetSetting(barName)
    local used_width = 0
    local used_height = settings.size
    local btn_padding = 0
    local btn_padding_y = 0
    local btn_this_row = 0

    local fmMultibar = CreateFrame("FRAME", "Gw" .. barName, UIParent, "GwMultibarTmpl")
    GW.MixinHideDuringPetAndOverride(fmMultibar)
    if actionPage ~= nil then
        fmMultibar:SetAttribute("actionpage", actionPage)
        fmMultibar:SetFrameStrata("LOW")
    end
    fmMultibar.gw_Buttons = {}

    local hideActionBarBG = GetSetting("HIDEACTIONBAR_BACKGROUND_ENABLED")
    for i = 1, 12 do
        local btn = _G[buttonName .. i]
        fmMultibar.gw_Buttons[i] = btn

        if btn ~= nil then
            if actionPage ~= nil then
                -- reparent button to our action bar
                btn:SetParent(fmMultibar)
            end
            btn:SetScript("OnUpdate", nil) -- disable the default button update handler

            btn:SetSize(settings.size, settings.size)
            updateHotkey(btn)
            setActionButtonStyle(buttonName .. i, nil, hideActionBarBG, showName)

            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", fmMultibar, "TOPLEFT", btn_padding, -btn_padding_y)
            btn.noGrid = nil
            btn.changedColor = false

            btn_padding = btn_padding + settings.size + settings.margin
            btn_this_row = btn_this_row + 1
            used_width = btn_padding

            if btn_this_row == settings.ButtonsPerRow then
                btn_padding_y = btn_padding_y + settings.size + settings.margin
                btn_this_row = 0
                btn_padding = 0
                used_height = btn_padding_y
            end

            if IsEquippedAction(btn.action) then
                local borname = buttonName .. i .. "Border"
                if _G[borname] then
                    _G[borname]:SetVertexColor(0, 1.0, 0, 1)
                end
            end
        end
    end

    fmMultibar:SetScript("OnUpdate", nil)
    fmMultibar:SetSize(used_width, used_height)

    if barName == "MultiBarLeft" then
        RegisterMovableFrame(fmMultibar, SHOW_MULTIBAR4_TEXT, barName, "VerticalActionBarDummy", nil, nil, {"default", "scaleable"}, nil, FlyoutDirection)
    elseif barName == "MultiBarRight" then
        RegisterMovableFrame(fmMultibar, SHOW_MULTIBAR3_TEXT, barName, "VerticalActionBarDummy", nil, nil, {"default", "scaleable"}, nil, FlyoutDirection)
    elseif barName == "MultiBarBottomLeft" then
        lm:RegisterMultiBarLeft(fmMultibar)
        RegisterMovableFrame(fmMultibar, SHOW_MULTIBAR1_TEXT, barName, "VerticalActionBarDummy", nil, true, {"default", "scaleable"}, true, FlyoutDirection)
    elseif barName == "MultiBarBottomRight" then
        lm:RegisterMultiBarRight(fmMultibar)
        RegisterMovableFrame(fmMultibar, SHOW_MULTIBAR2_TEXT, barName, "VerticalActionBarDummy", nil, true, {"default", "scaleable"}, true, FlyoutDirection)
    end

    fmMultibar:ClearAllPoints()
    fmMultibar:SetPoint("TOPLEFT", fmMultibar.gwMover)

    -- position mover
    if (barName == "MultiBarBottomLeft" or barName == "MultiBarBottomRight") and (not GetSetting("XPBAR_ENABLED") or GetSetting("PLAYER_AS_TARGET_FRAME")) and not fmMultibar.isMoved  then
        local framePoint = GetSetting(barName)
        local yOff = not GetSetting("XPBAR_ENABLED") and 14 or 0
        local xOff = GetSetting("PLAYER_AS_TARGET_FRAME") and 56 or 0
        fmMultibar.gwMover:ClearAllPoints()
        if barName == "MultiBarBottomLeft" then
            fmMultibar.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs + xOff, framePoint.yOfs - yOff)
        elseif barName == "MultiBarBottomRight" then
            fmMultibar.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs - xOff, framePoint.yOfs - yOff)
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

    -- flyout direction
    FlyoutDirection(fmMultibar)

    return fmMultibar
end
GW.AddForProfiling("Actionbars2", "updateMultiBar", updateMultiBar)



local function setPossessBar()
    PossessBarFrame:ClearAllPoints()
    PossessBarFrame:SetPoint("BOTTOM", MainMenuBarArtFrame, "TOP", -110, 40)
end
GW.AddForProfiling("Actionbars2", "setPossessBar", setPossessBar)

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
        "ActionButton"
    }
    for b = 1, #bars do
        local barname = bars[b]
        for i = 1, 12 do
            local button = _G[barname .. i]
            if button ~= nil then
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
GW.AddForProfiling("Actionbars2", "actionButtons_OnUpdate", actionButtons_OnUpdate)

local function changeVertexColorActionbars()
    local fmActionbar = MainMenuBarArtFrame
    local fmMultiBar
    for y = 1, 5 do
        if y == 1 then fmMultiBar = fmActionbar.gw_Bar1 end
        if y == 2 then fmMultiBar = fmActionbar.gw_Bar2 end
        if y == 3 then fmMultiBar = fmActionbar.gw_Bar3 end
        if y == 4 then fmMultiBar = fmActionbar.gw_Bar4 end
        if y == 5 then fmMultiBar = fmActionbar end
        if fmMultiBar.gw_IsEnabled then
            for i = 1, 12 do
                local btn = fmMultiBar.gw_Buttons[i]
                if btn.changedColor then
                    local valid = IsActionInRange(btn.action)
                    local checksRange = (valid ~= nil)
                    local inRange = checksRange and valid
                    if checksRange and not inRange then
                        btn.icon:SetVertexColor(out_R, out_G, out_B)
                    end
                end
            end
        end
    end
end
GW.AddForProfiling("Actionbars2", "changeVertexColorActionbars", changeVertexColorActionbars)

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
GW.AddForProfiling("Actionbars2", "multiButtons_OnUpdate", multiButtons_OnUpdate)

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
end
GW.AddForProfiling("Actionbars2", "actionBar_OnUpdate", actionBar_OnUpdate)

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

local function LoadActionBars(lm)
    local HIDE_ACTIONBARS_CVAR = GetSetting("HIDEACTIONBAR_BACKGROUND_ENABLED")
    if HIDE_ACTIONBARS_CVAR then
        HIDE_ACTIONBARS_CVAR = 0
    else
        HIDE_ACTIONBARS_CVAR = 1
    end
    SetCVar("alwaysShowActionBars", HIDE_ACTIONBARS_CVAR)

    for _, frame in pairs(
        {
            "MainMenuBar",
            "MainMenuBarArtFrame",
            "MultiBarLeft",
            "MultiBarRight",
            "MultiBarBottomRight",
            "MultiBarBottomLeft",
            "StanceBarFrame",
            "PossessBarFrame",
            "MULTICASTACTIONBAR_YPOS",
            "MultiCastActionBarFrame",
            "PETACTIONBAR_YPOS",
            "PETACTIONBAR_XPOS",
            "OBJTRACKER_OFFSET_X"
        }
    ) do
        if UIPARENT_MANAGED_FRAME_POSITIONS[frame] then
            UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
        end
    end

    -- init our bars
    local fmActionbar = updateMainBar(showBotRight)
    local showName = GetSetting("SHOWACTIONBAR_MACRO_NAME_ENABLED")
    fmActionbar.gw_Bar1 = updateMultiBar(lm, "MultiBarBottomLeft", "MultiBarBottomLeftButton", BOTTOMLEFT_ACTIONBAR_PAGE, true, showName)
    fmActionbar.gw_Bar2 = updateMultiBar(lm, "MultiBarBottomRight", "MultiBarBottomRightButton", BOTTOMRIGHT_ACTIONBAR_PAGE, true, showName)
    fmActionbar.gw_Bar3 = updateMultiBar(lm, "MultiBarRight", "MultiBarRightButton", RIGHT_ACTIONBAR_PAGE, nil, showName)
    fmActionbar.gw_Bar4 = updateMultiBar(lm, "MultiBarLeft", "MultiBarLeftButton", LEFT_ACTIONBAR_PAGE, nil, showName)

    GW.RegisterScaleFrame(MainMenuBarArtFrame)

    -- hook existing multibars to track settings changes
    hooksecurefunc("SetActionBarToggles", trackBarChanges)
    hooksecurefunc(ActionBarActionButtonMixin, "UpdateUsable", changeVertexColorActionbars)
    hooksecurefunc("ActionButton_UpdateFlyout", changeFlyoutStyle)
    trackBarChanges()

    -- do stuff to other pieces of the blizz UI
    hideBlizzardsActionbars()
    GW.CreateStanceBar()
    setPossessBar()
    setLeaveVehicleButton()

    -- hook hotkey update calls so we can override styling changes
    hooksecurefunc(ActionBarActionButtonMixin, "UpdateHotkeys", updateHotkey)

    -- frames using the alert frame subsystem have their positioning managed by UIParent
    -- the secure code for that lives mostly in Interface/FrameXML/UIParent.lua
    -- we can override the alert frame subsystem update loop in Interface/FrameXML/AlertFrames.lua
    -- doing it there avoids any taint issues
    -- we also exclude a few frames from the auto-positioning stuff regardless
    UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil

    if not IsFrameModified("ExtraActionBarFrame") then
        GW.Debug("moving ExtraActionBarFrame")
        ExtraActionBarFrame:ClearAllPoints()
        ExtraActionBarFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 130)
        ExtraActionBarFrame:SetFrameStrata("MEDIUM")
    end

    --[[ -- This is taintig in pet battles for rouge and druid
    local HIDE_MOST = {
        GwStanceBarButton = "hidden",
        StanceButton1 = "hidden",
        StanceButton2 = "hidden",
        StanceButton3 = "hidden",
        StanceButton4 = "hidden",
        StanceButton5 = "hidden",
        StanceButton6 = "hidden",
    -- Add new frames/ buttons to hide
    }

    FRAMELOCK_STATES.COMMENTATOR_SPECTATING_MODE = Mixin(FRAMELOCK_STATES.COMMENTATOR_SPECTATING_MODE, HIDE_MOST)
    FRAMELOCK_STATES.PETBATTLES = Mixin(FRAMELOCK_STATES.PETBATTLES, HIDE_MOST)
    ]]
    --ActionBarController:HookScript("OnEvent", function(_, event)
        --if event == "UPDATE_BONUS_ACTIONBAR" then
            --ActionBarController_ResetToDefault()
            --ValidateActionBarTransition()
        --end
    --end)
end
GW.LoadActionBars = LoadActionBars
