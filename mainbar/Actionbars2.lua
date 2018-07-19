local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetSetting = GW.GetSetting
local ToggleMainHud = GW.ToggleMainHud
local Wait = GW.Wait
local Debug = GW.Debug
local Self_Hide = GW.Self_Hide
local IsFrameModified = GW.IsFrameModified
local CountTable = GW.CountTable
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local LoadAuras = GW.LoadAuras
local PowerBarColorCustom = GW.PowerBarColorCustom
local CommaValue = GW.CommaValue
local UpdateBuffLayout = GW.UpdateBuffLayout

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

local GW_BARS = {
    MainMenuBarArtFrame,
    MultiBarLeft,
    MultiBarRight,
    MultiBarBottomLeft,
    MultiBarBottomRight
}

-- forward function defs
local actionBarEquipUpdate
local actionButtons_OnUpdate
local multiButtons_OnUpdate

local function hideBlizzardsActionbars()
    for k, v in pairs(GW_BLIZZARD_HIDE_FRAMES) do
        if v and v.Hide ~= nil then
            v:Hide()
            if v.UnregisterAllEvents ~= nil then
                v:UnregisterAllEvents()
            end
        end
    end
    for k, object in pairs(GW_BLIZZARD_FORCE_HIDE) do
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
    for k, v in pairs(callback) do
        v()
    end
end
GW.AddForProfiling("Actionbars2", "stateChanged", stateChanged)

hooksecurefunc("ValidateActionBarTransition", stateChanged)

-- fader logic (previously separated into fader.lua)
local function actionBarFrameShow(f, name)
    StopAnimation(name)
    f.gw_FadeShowing = true
    stateChanged()
    AddToAnimation(
        name,
        0,
        1,
        GetTime(),
        0.1,
        function()
            f:SetAlpha(animations[name]["progress"])
        end,
        nil,
        function()
            for i = 1, 12 do
                f.gw_MultiButtons[i].cooldown:SetDrawBling(true)
            end
            stateChanged()
        end
    )
end
GW.AddForProfiling("Actionbars2", "actionBarFrameShow", actionBarFrameShow)

local function actionBarFrameHide(f, name)
    StopAnimation(name)
    f.gw_FadeShowing = false
    for i = 1, 12 do
        f.gw_MultiButtons[i].cooldown:SetDrawBling(false)
    end
    AddToAnimation(
        name,
        1,
        0,
        GetTime(),
        0.1,
        function()
            f:SetAlpha(animations[name]["progress"])
        end,
        nil,
        function()
            stateChanged()
        end
    )
end
GW.AddForProfiling("Actionbars2", "actionBarFrameHide", actionBarFrameHide)

local function fadeCheck(self, elapsed)
    self.gw_LastFadeCheck = self.gw_LastFadeCheck - elapsed
    if self.gw_LastFadeCheck > 0 then
        return
    end
    self.gw_LastFadeCheck = 0.1
    if not self:IsShown() then
        return
    end

    if self:IsMouseOver(100, -100, -100, 100) or UnitAffectingCombat("player") then
        if not self.gw_FadeShowing then
            actionBarFrameShow(self, self:GetName())
        end
    elseif self.gw_FadeShowing and UnitAffectingCombat("player") == false then
        local isFlyout =
            (SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() and
            SpellFlyout:GetParent():GetParent() == self)
        if not isFlyout then
            actionBarFrameHide(self, self:GetName())
        end
    end
end
GW.AddForProfiling("Actionbars2", "fadeCheck", fadeCheck)

local function fader_OnShow(self)
    self.gw_FadeShowing = true
    if self.gw_StateTrigger then
        stateChanged()
    end
end
GW.AddForProfiling("Actionbars2", "fader_OnShow", fader_OnShow)

local function fader_OnHide(self)
    self.gw_FadeShowing = false
    if self.gw_StateTrigger then
        stateChanged()
    end
end
GW.AddForProfiling("Actionbars2", "fader_OnHide", fader_OnHide)

local function updateHotkey(self, actionButtonType)
    local hotkey = self.HotKey --_G[self:GetName() .. 'HotKey']
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

    if hotkey:GetText() == RANGE_INDICATOR then
        hotkey:SetText("")
    else
        if GetSetting("BUTTON_ASSIGNMENTS") then
            hotkey:SetText(text)
        else
            hotkey:SetText("")
        end
    end
end
GW.AddForProfiling("Actionbars2", "updateHotkey", updateHotkey)

local function setMicroButtons()
    MicroButtonPortrait:Hide()
    GuildMicroButtonTabard:Hide()
    MainMenuBarPerformanceBar:Hide()
    TalentMicroButtonAlert:Hide()
    TalentMicroButtonAlert:SetScript("OnShow", Self_Hide)
    TalentMicroButtonAlert:SetScript("OnHide", nil)
    TalentMicroButtonAlert:SetScript("OnEnter", nil)
    TalentMicroButtonAlert:SetScript("OnLeave", nil)

    for i = 1, #MICRO_BUTTONS do
        if _G[MICRO_BUTTONS[i]] then
            _G[MICRO_BUTTONS[i]]:SetScript("OnShow", Self_Hide)
            _G[MICRO_BUTTONS[i]]:SetScript("OnHide", nil)
            _G[MICRO_BUTTONS[i]]:SetScript("OnEnter", nil)
            _G[MICRO_BUTTONS[i]]:SetScript("OnLeave", nil)
            _G[MICRO_BUTTONS[i]]:SetScript("OnEvent", nil)
            _G[MICRO_BUTTONS[i]]:SetScript("OnUpdate", nil)
            _G[MICRO_BUTTONS[i]]:UnregisterAllEvents()
            _G[MICRO_BUTTONS[i]]:Hide()
        end
    end
end
GW.AddForProfiling("Actionbars2", "setMicroButtons", setMicroButtons)

local function hideBackdrop(self)
    self.gwBackdrop:Hide()
end
GW.AddForProfiling("Actionbars2", "hideBackdrop", hideBackdrop)

local function showBackdrop(self)
    self.gwBackdrop:Show()
end
GW.AddForProfiling("Actionbars2", "showBackdrop", showBackdrop)

local function setActionButtonStyle(buttonName, noBackDrop, hideUnused)
    local btn = _G[buttonName]

    if btn.icon ~= nil then
        btn.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
    if btn.HotKey ~= nil then
        btn.HotKey:ClearAllPoints()
        btn.HotKey:SetPoint("CENTER", btn, "BOTTOM", 0, 0)
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
        btn.Border:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder")
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
    if btn.AutoCastable ~= nil then
        btn.AutoCastable:SetSize(btn:GetWidth(), btn:GetWidth())
    end

    btn:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\actionbutton-pressed")
    btn:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress")
    btn:SetCheckedTexture("Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress")
    btn.Name:SetAlpha(0) --Hide Marco Name on Actionbutton

    if noBackDrop == nil or noBackDrop == false then
        local backDrop = CreateFrame("Frame", nil, btn, "GwActionButtonBackDrop")
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
GW.AddForProfiling("Actionbars2", "setActionButtonStyle", setActionButtonStyle)

local function main_OnEvent(self, event)
    if event == "PET_BATTLE_OPENING_START" then
        ToggleMainHud(false)
    elseif event == "PET_BATTLE_CLOSE" then
        ToggleMainHud(true)
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        actionBarEquipUpdate()
    end
end
GW.AddForProfiling("Actionbars2", "main_OnEvent", main_OnEvent)

--[[
local function showAttr()
    for i = 1, 12 do
        local BUTTON = _G["ActionButton" .. i]
        print(BUTTON:GetAttribute("type"))
    end
end
--]]
local function updateMainBar()
    local used_height = MAIN_MENU_BAR_BUTTON_SIZE
    local btn_padding = MAIN_MENU_BAR_BUTTON_MARGIN

    MainMenuBarArtFrame.gw_ActionButtons = {}
    for i = 1, 12 do
        local btn = _G["ActionButton" .. i]
        MainMenuBarArtFrame.gw_ActionButtons[i] = btn

        if btn ~= nil then
            btn:SetScript("OnUpdate", nil) -- disable the default button update handler

            local hotkey = _G["ActionButton" .. i .. "HotKey"]
            btn_padding = btn_padding + MAIN_MENU_BAR_BUTTON_SIZE + MAIN_MENU_BAR_BUTTON_MARGIN
            btn:SetSize(MAIN_MENU_BAR_BUTTON_SIZE, MAIN_MENU_BAR_BUTTON_SIZE)

            setActionButtonStyle("ActionButton" .. i)
            updateHotkey(btn)

            hotkey:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
            hotkey:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
            hotkey:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINED")
            hotkey:SetTextColor(1, 1, 1)

            if IsEquippedAction(btn.action) then
                local borname = "ActionButton" .. i .. "Border"
                if _G[borname] then
                    _G[borname]:SetVertexColor(0, 1.0, 0, 1)
                end
            end

            local rangeIndicator =
                CreateFrame("FRAME", "GwActionRangeIndicator" .. i, hotkey:GetParent(), "GwActionRangeIndicator")
            rangeIndicator:SetFrameStrata("BACKGROUND", 1)
            rangeIndicator:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", -1, -2)
            rangeIndicator:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 1, -2)
            _G["GwActionRangeIndicator" .. i .. "Texture"]:SetVertexColor(147 / 255, 19 / 255, 2 / 255)
            rangeIndicator:Hide()

            btn["gw_RangeIndicator"] = rangeIndicator
            btn["gw_HotKey"] = hotkey
            btn.noGrid = nil

            if GetSetting("BUTTON_ASSIGNMENTS") then
                local hkBg =
                    CreateFrame(
                    "Frame",
                    "GwHotKeyBackDropActionButton" .. i,
                    hotkey:GetParent(),
                    "GwActionHotKeyBackDrop"
                )

                hkBg:SetPoint("CENTER", hotkey, "CENTER", 0, 0)
                _G["GwHotKeyBackDropActionButton" .. i .. "Texture"]:SetParent(hotkey:GetParent())
            end

            btn:ClearAllPoints()
            btn:SetPoint(
                "LEFT",
                MainMenuBarArtFrame,
                "LEFT",
                btn_padding - MAIN_MENU_BAR_BUTTON_MARGIN - MAIN_MENU_BAR_BUTTON_SIZE,
                0
            )

            if i == 6 then
                btn_padding = btn_padding + 108
            end
        end
    end

    -- TODO: gotta be a much better way to handle all this
    -- default bar sizes in various circumstances:
    --   with bottomright shown = 804
    --   with bottomright hide  = 550
    MainMenuBarArtFrame:SetScript("OnUpdate", actionButtons_OnUpdate)
    MainMenuBarArtFrame:SetSize(btn_padding, used_height) -- width is always overriden later by action bar controller
    hooksecurefunc(
        "MultiActionBar_Update",
        function()
            if InCombatLockdown() then
                return
            end
            local xOff
            if SHOW_MULTI_ACTIONBAR_2 then
                xOff = (804 - btn_padding) / 2
            else
                xOff = -(btn_padding - 550) / 2
            end
            MainMenuBarArtFrame:ClearAllPoints()
            MainMenuBarArtFrame:SetPoint("TOP", UIParent, "BOTTOM", xOff, 80)

            MultiBarLeft:ClearAllPoints()
            local pt = GetSetting("MultiBarLeft")
            MultiBarLeft:SetPoint(pt.point, UIParent, pt.relativePoint, pt.xOfs, pt.yOfs)

            MultiBarRight:ClearAllPoints()
            pt = GetSetting("MultiBarRight")
            MultiBarRight:SetPoint(pt.point, UIParent, pt.relativePoint, pt.xOfs, pt.yOfs)
        end
    )
end
GW.AddForProfiling("Actionbars2", "updateMainBar", updateMainBar)

local function updateMultiBar(barName, buttonName)
    local multibar = _G[barName]
    local settings = GetSetting(barName)
    local used_width = 0
    local used_height = settings["size"]
    local btn_padding = 0
    local btn_padding_y = 0
    local btn_this_row = 0

    multibar.gw_MultiButtons = {}
    multibar.gw_LastFadeCheck = -1
    if multibar:IsShown() then
        multibar.gw_FadeShowing = true
    else
        multibar.gw_FadeShowing = false
    end

    local hideActionBarBG = GetSetting("HIDEACTIONBAR_BACKGROUND_ENABLED")
    for i = 1, 12 do
        local btn = _G[buttonName .. i]
        multibar.gw_MultiButtons[i] = btn

        if btn ~= nil then
            btn:SetScript("OnUpdate", nil) -- disable the default button update handler

            btn:SetSize(settings.size, settings.size)
            updateHotkey(btn)
            setActionButtonStyle(buttonName .. i, nil, hideActionBarBG)

            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", multibar, "TOPLEFT", btn_padding, -btn_padding_y)
            btn.noGrid = nil

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
    multibar:HookScript("OnUpdate", multiButtons_OnUpdate)
    multibar:ClearAllPoints()
    multibar:SetPoint(settings.point, UIParent, settings.relativePoint, settings.xOfs, settings.yOfs)
    multibar:SetSize(used_width, used_height)
end
GW.AddForProfiling("Actionbars2", "updateMultiBar", updateMultiBar)

local function petBarUpdate()
    _G["PetActionButton1Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-attack")
    _G["PetActionButton2Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-follow")
    _G["PetActionButton3Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-place")

    _G["PetActionButton8Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-assist")
    _G["PetActionButton9Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-defense")
    _G["PetActionButton10Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-passive")
    for i = 1, 12 do
        if _G["PetActionButton" .. i] ~= nil then
            _G["PetActionButton" .. i .. "NormalTexture2"]:SetTexture(nil)
        end
    end
end
GW.AddForProfiling("Actionbars2", "petBarUpdate", petBarUpdate)

local function setPetBar()
    local BUTTON_SIZE = 28
    local BUTTON_MARGIN = 3

    PetActionButton1:ClearAllPoints()
    PetActionButton1:SetPoint("BOTTOMLEFT", GwPlayerPetFrame, "BOTTOMLEFT", 3, 30)

    for i = 1, 12 do
        local btn = _G["PetActionButton" .. i]
        local btnPrev = _G["PetActionButton" .. (i - 1)]
        if btn ~= nil then
            btn:SetParent(GwPlayerPetFrame)
            updateHotkey(btn)

            btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
            if i < 4 then
                btn:SetSize(32, 32)
            elseif i == 8 then
                btn:ClearAllPoints()
                btn:SetPoint("BOTTOM", _G["PetActionButton5"], "TOP", 0, BUTTON_MARGIN)
            end

            if i > 1 and i ~= 8 then
                btn:ClearAllPoints()

                if i > 3 then
                    btn:SetPoint("BOTTOMLEFT", btnPrev, "BOTTOMRIGHT", BUTTON_MARGIN, 0)
                else
                    btn:SetPoint("BOTTOMLEFT", btnPrev, "BOTTOMRIGHT", BUTTON_MARGIN, 0)
                end
            end
            local btnShine = _G["PetActionButton" .. i .. "Shine"]
            if btnShine then
                btnShine:SetSize(btn:GetSize())

            --for k,v in pairs(_G['PetActionButton'..i..'Shine'].sparkles) do
            --   v:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\autocast')
            --end
            -- _G['PetActionButton'..i..'ShineAutoCastable']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\autocast')
            end

            if i == 1 then
                hooksecurefunc("PetActionBar_Update", petBarUpdate)
            end

            if i <= 3 or i >= 8 then
                btn:SetScript("OnDragStart", nil)
                btn:SetAttribute("_ondragstart", nil)
                btn:SetScript("OnReceiveDrag", nil)
                btn:SetAttribute("_onreceivedrag", nil)
            end

            setActionButtonStyle("PetActionButton" .. i)
        end
    end
end
GW.AddForProfiling("Actionbars2", "setPetBar", setPetBar)

local function stance_OnEvent(self, event)
    if InCombatLockdown() then
        return
    end

    if GetNumShapeshiftForms() < 1 then
        GwStanceBarButton:Hide()
    else
        GwStanceBarButton:Show()
    end
end
GW.AddForProfiling("Actionbars2", "stance_OnEvent", stance_OnEvent)

local function setStanceBar()
    for i = 1, 12 do
        if _G["StanceButton" .. i] ~= nil then
            if i > 1 then
                _G["StanceButton" .. i]:ClearAllPoints()
                local last = i - 1

                _G["StanceButton" .. i]:SetPoint("BOTTOM", _G["StanceButton" .. last], "TOP", 0, 2)
            end

            _G["StanceButton" .. i]:SetSize(38, 38)
            setActionButtonStyle("StanceButton" .. i, true)
        end
    end

    CreateFrame("Button", "GwStanceBarButton", UIParent, "GwStanceBarButton")

    GwStanceBarButton:SetPoint("TOPRIGHT", ActionButton1, "TOPLEFT", -5, 2)
    CreateFrame("Frame", "GwStanceBarContainer", UIParent, nil)
    GwStanceBarContainer:SetPoint("BOTTOM", GwStanceBarButton, "TOP", 0, 0)

    StanceBarFrame:SetParent(GwStanceBarContainer)

    StanceButton1:ClearAllPoints()
    StanceButton1:SetPoint("BOTTOM", StanceBarFrame, "BOTTOM", 0, 0)

    StanceBarFrame:SetPoint("BOTTOMLEFT", GwStanceBarButton, "TOPLEFT", 0, 0)
    StanceBarFrame:SetPoint("BOTTOMRIGHT", GwStanceBarButton, "TOPRIGHT", 0, 0)

    GwStanceBarButton:RegisterEvent("CHARACTER_POINTS_CHANGED")
    GwStanceBarButton:RegisterEvent("PLAYER_ALIVE")
    GwStanceBarButton:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    GwStanceBarButton:RegisterEvent("UNIT_POWER_FREQUENT")
    GwStanceBarButton:RegisterEvent("UNIT_HEALTH")
    GwStanceBarButton:SetScript("OnEvent", stance_OnEvent)

    if GetNumShapeshiftForms() < 1 then
        GwStanceBarButton:Hide()
    else
        GwStanceBarButton:Show()
    end

    GwStanceBarContainer:Hide()

    GwStanceBarButton:SetFrameRef("GwStanceBarContainer", GwStanceBarContainer)

    GwStanceBarButton:SetAttribute(
        "_onclick",
        [=[
        if self:GetFrameRef('GwStanceBarContainer'):IsVisible() then
            self:GetFrameRef('GwStanceBarContainer'):Hide()
        else
            self:GetFrameRef('GwStanceBarContainer'):Show()
        end
    ]=]
    )
end
GW.AddForProfiling("Actionbars2", "setStanceBar", setStanceBar)

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

actionButtons_OnUpdate = function(self, elapsed)
    for i = 1, 12 do
        local btn = self.gw_ActionButtons[i]
        -- override of /Interface/FrameXML/ActionButton.lua ActionButton_OnUpdate
        if (ActionButton_IsFlashing(btn)) then
            actionButtonFlashing(btn, elapsed)
        end

        local rangeTimer = btn.rangeTimer
        if (rangeTimer) then
            rangeTimer = rangeTimer - elapsed

            if (rangeTimer <= 0) then
                local valid = IsActionInRange(btn.action)
                local checksRange = (valid ~= nil)
                local inRange = checksRange and valid
                if (not checksRange or inRange) then
                    btn.gw_RangeIndicator:Hide()
                else
                    btn.gw_RangeIndicator:Show()
                end
                rangeTimer = TOOLTIP_UPDATE_TIME
            end

            btn.rangeTimer = rangeTimer
        end
    end
end
GW.AddForProfiling("Actionbars2", "actionButtons_OnUpdate", actionButtons_OnUpdate)

multiButtons_OnUpdate = function(self, elapsed)
    if not self.gw_FadeShowing then
        return -- don't need OnUpdate stuff if this bar is not visible
    end

    local out_range_RGB = {RED_FONT_COLOR:GetRGB()}
    local in_range_RGB = {LIGHTGRAY_FONT_COLOR:GetRGB()}
    for i = 1, 12 do
        local btn = self.gw_MultiButtons[i]
        -- override of /Interface/FrameXML/ActionButton.lua ActionButton_OnUpdate
        if (ActionButton_IsFlashing(btn)) then
            actionButtonFlashing(btn, elapsed)
        end

        local rangeTimer = btn.rangeTimer
        if (rangeTimer) then
            rangeTimer = rangeTimer - elapsed

            if (rangeTimer <= 0) then
                local valid = IsActionInRange(btn.action)
                local checksRange = (valid ~= nil)
                local inRange = checksRange and valid
                if checksRange and not inRange then
                    btn.HotKey:SetVertexColor(unpack(out_range_RGB))
                else
                    btn.HotKey:SetVertexColor(unpack(in_range_RGB))
                end
                rangeTimer = TOOLTIP_UPDATE_TIME
            end

            btn.rangeTimer = rangeTimer
        end
    end
end
GW.AddForProfiling("Actionbars2", "multiButtons_OnUpdate", multiButtons_OnUpdate)

-- overrides for the alert frame subsystem update loop in Interface/FrameXML/AlertFrames.lua
local function adjustFixedAnchors(self, relativeAlert)
    if self.anchorFrame:IsShown() then
        local pt, relTo, relPt, xOf, _ = self.anchorFrame:GetPoint()
        local name = self.anchorFrame:GetName()
        if pt == "BOTTOM" and relTo:GetName() == "UIParent" and relPt == "BOTTOM" then
            if name == "TalkingHeadFrame" then
                self.anchorFrame:ClearAllPoints()
                self.anchorFrame:SetPoint(pt, relTo, relPt, xOf, GwAlertFrameOffsetter:GetHeight())
            elseif name == "GroupLootContainer" then
                self.anchorFrame:ClearAllPoints()
                if TalkingHeadFrame and TalkingHeadFrame:IsShown() then
                    self.anchorFrame:SetPoint(pt, relTo, relPt, xOf, GwAlertFrameOffsetter:GetHeight() + 140)
                else
                    self.anchorFrame:SetPoint(pt, relTo, relPt, xOf, GwAlertFrameOffsetter:GetHeight())
                end
            end
        end
        return self.anchorFrame
    end
    return relativeAlert
end
GW.AddForProfiling("Actionbars2", "adjustFixedAnchors", adjustFixedAnchors)

local function updateAnchors(self)
    self:CleanAnchorPriorities()

    local relativeFrame = GwAlertFrameOffsetter
    for i, alertFrameSubSystem in ipairs(self.alertFrameSubSystems) do
        if alertFrameSubSystem.AdjustAnchors == AlertFrameExternallyAnchoredMixin.AdjustAnchors then
            relativeFrame = adjustFixedAnchors(alertFrameSubSystem, relativeFrame)
        else
            relativeFrame = alertFrameSubSystem:AdjustAnchors(relativeFrame)
        end
    end
end
GW.AddForProfiling("Actionbars2", "updateAnchors", updateAnchors)

local function LoadActionBars()
    local HIDE_ACTIONBARS_CVAR = GetSetting("HIDEACTIONBAR_BACKGROUND_ENABLED")
    if HIDE_ACTIONBARS_CVAR then
        HIDE_ACTIONBARS_CVAR = 0
    else
        HIDE_ACTIONBARS_CVAR = 1
    end

    SetCVar("alwaysShowActionBars", HIDE_ACTIONBARS_CVAR)

    for k, v in pairs(GW_BARS) do
        v:SetParent(UIParent)
    end

    for _, frame in pairs(
        {
            "MultiBarLeft",
            "MultiBarRight",
            "MultiBarBottomRight",
            "MultiBarBottomLeft",
            "StanceBarFrame",
            "PossessBarFrame",
            "MULTICASTACTIONBAR_YPOS",
            "MultiCastActionBarFrame",
            "PETACTIONBAR_YPOS",
            "PETACTIONBAR_XPOS"
        }
    ) do
        UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
    end

    -- separate multibars from default handling (FrameXML/MultiActionBar.lua line 53)
    VerticalMultiBarsContainer:SetScript("OnEvent", nil)
    MultiBarLeft:SetParent(UIParent)
    MultiBarRight:SetParent(UIParent)

    -- setup fader logic
    MultiBarBottomLeft.gw_StateTrigger = true
    MultiBarBottomLeft:SetScript("OnShow", fader_OnShow)
    MultiBarBottomLeft:SetScript("OnHide", fader_OnHide)
    MultiBarBottomRight.gw_StateTrigger = true
    MultiBarBottomRight:SetScript("OnShow", fader_OnShow)
    MultiBarBottomRight:SetScript("OnHide", fader_OnHide)
    MultiBarLeft:SetScript("OnShow", fader_OnShow)
    MultiBarLeft:SetScript("OnHide", fader_OnHide)
    MultiBarRight:SetScript("OnShow", fader_OnShow)
    MultiBarRight:SetScript("OnHide", fader_OnHide)

    -- init our bars
    updateMainBar()
    updateMultiBar("MultiBarBottomRight", "MultiBarBottomRightButton")
    updateMultiBar("MultiBarBottomLeft", "MultiBarBottomLeftButton")
    updateMultiBar("MultiBarRight", "MultiBarRightButton")
    updateMultiBar("MultiBarLeft", "MultiBarLeftButton")

    RegisterMovableFrame(MultiBarRight:GetName(), MultiBarRight, "MultiBarRight", "VerticalActionBarDummy")
    RegisterMovableFrame(MultiBarLeft:GetName(), MultiBarLeft, "MultiBarLeft", "VerticalActionBarDummy")

    hideBlizzardsActionbars()
    setMicroButtons()
    setStanceBar()
    setPossessBar()
    if GetSetting("PETBAR_ENABLED") then
        setPetBar()
    end
    setLeaveVehicleButton()

    hooksecurefunc("ActionButton_UpdateHotkeys", updateHotkey)

    MainMenuBarArtFrame:RegisterEvent("PET_BATTLE_CLOSE")
    MainMenuBarArtFrame:RegisterEvent("PET_BATTLE_OPENING_START")
    MainMenuBarArtFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    MainMenuBarArtFrame:HookScript("OnEvent", main_OnEvent)

    -- frames using the alert frame subsystem have their positioning managed by UIParent
    -- the secure code for that lives mostly in Interface/FrameXML/UIParent.lua
    -- we can override the alert frame subsystem update loop in Interface/FrameXML/AlertFrames.lua
    -- doing it there avoids any taint issues
    -- we also exclude a few frames from the auto-positioning stuff regardless
    GwAlertFrameOffsetter:SetHeight(205)
    UIPARENT_MANAGED_FRAME_POSITIONS["ExtraActionBarFrame"] = nil
    UIPARENT_MANAGED_FRAME_POSITIONS["ZoneAbilityFrame"] = nil
    UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil
    UIPARENT_MANAGED_FRAME_POSITIONS["TalkingHeadFrame"] = nil
    if not IsFrameModified("ExtraActionBarFrame") then
        Debug("moving ExtraActionBarFrame")
        ExtraActionBarFrame:ClearAllPoints()
        ExtraActionBarFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 130)
        ExtraActionBarFrame:SetFrameStrata("MEDIUM")
    end
    if not IsFrameModified("ZoneAbilityFrame") then
        Debug("moving ZoneAbilityFrame")
        ZoneAbilityFrame:ClearAllPoints()
        ZoneAbilityFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 130)
    end
    AlertFrame.UpdateAnchors = updateAnchors

    -- return handler for fading action bars
    if GetSetting("FADE_BOTTOM_ACTIONBAR") then
        return function(elapsed)
            fadeCheck(MultiBarBottomLeft, elapsed)
            fadeCheck(MultiBarBottomRight, elapsed)
            fadeCheck(MultiBarRight, elapsed)
            fadeCheck(MultiBarLeft, elapsed)
        end
    else
        return nil
    end
end
GW.LoadActionBars = LoadActionBars

local function updatePetFrameLocation()
    if InCombatLockdown() or not GwPlayerPetFrame then
        return
    end
    GwPlayerPetFrame:ClearAllPoints()
    if MultiBarBottomLeft.gw_FadeShowing then
        GwPlayerPetFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -53, 212)
    else
        GwPlayerPetFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -53, 120)
    end
end
GW.AddForProfiling("Actionbars2", "updatePetFrameLocation", updatePetFrameLocation)

local function updatePetData(self, event, unit)
    if unit == "player" and (event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") then
        if UnitHasVehiclePlayerFrameUI("player") then
            self:SetAlpha(0)
        else
            self:SetAlpha(1)
        end
        return
    end

    if not UnitExists("pet") then
        return
    end

    if event == "UNIT_AURA" and unit == "pet" then
        UpdateBuffLayout(self, event, unit)
        return
    end

    local health = UnitHealth("pet")
    local healthMax = UnitHealthMax("pet")
    local healthprec = 0

    local powerType, powerToken, _ = UnitPowerType("pet")
    local resource = UnitPower("pet", powerType)
    local resourceMax = UnitPowerMax("pet", powerType)
    local resourcePrec = 0

    if health > 0 and healthMax > 0 then
        healthprec = health / healthMax
    end

    if resource ~= nil and resource > 0 and resourceMax > 0 then
        resourcePrec = resource / resourceMax
    end

    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.resource:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end

    self.resource:SetValue(resourcePrec)

    SetPortraitTexture(_G["GwPlayerPetFramePortrait"], "pet")

    if GwPlayerPetFrameHealth.animationCurrent == nil then
        GwPlayerPetFrameHealth.animationCurrent = 0
    end
    AddToAnimation(
        "petBarAnimation",
        GwPlayerPetFrameHealth.animationCurrent,
        healthprec,
        GetTime(),
        0.2,
        function()
            _G["GwPlayerPetFrameHealth"]:SetValue(animations["petBarAnimation"]["progress"])
        end
    )
    GwPlayerPetFrameHealth.animationCurrent = healthprec
    _G["GwPlayerPetFrameHealthString"]:SetText(CommaValue(health))
end
GW.AddForProfiling("Actionbars2", "updatePetData", updatePetData)

local function LoadPetFrame()
    -- disable default PetFrame stuff
    PetFrame:UnregisterAllEvents()
    PetFrame:SetScript("OnUpdate", nil)

    local playerPetFrame = CreateFrame("Button", "GwPlayerPetFrame", UIParent, "GwPlayerPetFrame")

    RegisterMovableFrame("petframe", GwPlayerPetFrame, "pet_pos", "GwPetFrameDummy", "PETBAR_LOCKED")

    playerPetFrame:SetAttribute("*type1", "target")
    playerPetFrame:SetAttribute("*type2", "togglemenu")
    playerPetFrame:SetAttribute("unit", "pet")
    playerPetFrame:EnableMouse(true)
    playerPetFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    RegisterUnitWatch(playerPetFrame)

    _G["GwPlayerPetFrameHealth"]:SetStatusBarColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
    _G["GwPlayerPetFrameHealthString"]:SetFont(UNIT_NAME_FONT, 11)

    playerPetFrame:SetScript("OnEvent", updatePetData)
    playerPetFrame:HookScript(
        "OnShow",
        function(self)
            updatePetData(self, "UNIT_PET", "player")
        end
    )
    playerPetFrame.unit = "pet"

    playerPetFrame.displayBuffs = true
    playerPetFrame.displayDebuffs = true
    playerPetFrame.debuffFilter = "player"

    LoadAuras(playerPetFrame, playerPetFrame.auras)

    playerPetFrame:RegisterEvent("UNIT_PET")
    playerPetFrame:RegisterEvent("UNIT_POWER_FREQUENT")
    playerPetFrame:RegisterEvent("UNIT_MAXPOWER")
    playerPetFrame:RegisterEvent("UNIT_HEALTH")
    playerPetFrame:RegisterEvent("UNIT_MAXHEALTH")
    playerPetFrame:RegisterEvent("UNIT_AURA")
    playerPetFrame:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
    playerPetFrame:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")

    --_G['GwPlayerPetFramePortrait']
    updatePetData(playerPetFrame, "UNIT_PET", "player")

    if GetSetting("PETBAR_LOCKED") == true then
        GwPlayerPetFrame:ClearAllPoints()
        GwPlayerPetFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", -372, 86)
        playerPetFrame:SetFrameRef("GwPlayerPetFrame", GwPlayerPetFrame)
        playerPetFrame:SetFrameRef("UIParent", UIParent)
        playerPetFrame:SetFrameRef("MultiBarBottomLeft", MultiBarBottomLeft)
        playerPetFrame:SetAttribute(
            "_onstate-combat",
            [=[
            if self:GetFrameRef('MultiBarBottomLeft'):IsShown()==false then
                return
            end
        
            self:GetFrameRef('GwPlayerPetFrame'):ClearAllPoints()
            if newstate == 'show' then
                self:GetFrameRef('GwPlayerPetFrame'):SetPoint('BOTTOMRIGHT',self:GetFrameRef('UIParent'),'BOTTOM',-53,212)
            end
        ]=]
        )
        RegisterStateDriver(playerPetFrame, "combat", "[combat] show; hide")
        AddActionBarCallback(updatePetFrameLocation)
        updatePetFrameLocation()
        return
    end

    GwPlayerPetFrame:ClearAllPoints()
    GwPlayerPetFrame:SetPoint(
        GetSetting("pet_pos")["point"],
        UIParent,
        GetSetting("pet_pos")["relativePoint"],
        GetSetting("pet_pos")["xOfs"],
        GetSetting("pet_pos")["yOfs"]
    )
end
GW.LoadPetFrame = LoadPetFrame
