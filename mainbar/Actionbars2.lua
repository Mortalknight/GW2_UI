local _, GW = ...
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local RegisterMovableFrame = GW.RegisterMovableFrame
local Self_Hide = GW.Self_Hide
local CountTable = GW.CountTable
local MAIN_MENU_BAR_BUTTON_SIZE = 48
local MAIN_MENU_BAR_BUTTON_MARGIN = 5

local GW_BLIZZARD_HIDE_FRAMES ={
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
    MainMenuBarPageNumber,
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
}

local GW_BARS= {
    MainMenuBarArtFrame,
    MultiBarLeft,
    MultiBarRight,
    MultiBarBottomLeft,
    MultiBarBottomRight,
}

function gw_hideBlizzardsActionbars()
    for k,v in pairs(GW_BLIZZARD_HIDE_FRAMES) do
        v:Hide()
        if v.UnregisterAllEvents ~= nil then
            v:UnregisterAllEvents()
        end
    end
    for k,object in pairs(GW_BLIZZARD_FORCE_HIDE) do
        if object:IsObjectType('Frame') then
            object:UnregisterAllEvents()
            object:SetScript('OnEnter', nil)
            object:SetScript('OnLeave', nil)
        end
        
        if  object:IsObjectType('Button') then
            object:SetScript('OnClick', nil)
        end
        hooksecurefunc(object, 'Show', Self_Hide)

        object:Hide()
    end
    
    MainMenuBar:EnableMouse(false)
end

function gwActionButton_UpdateHotkeys(self, actionButtonType)
    local hotkey = self.HotKey
    local text = hotkey:GetText()

    if text == nil then return end

    text = string.gsub(text, '(s%-)', 'S')
    text = string.gsub(text, '(a%-)', 'A')
    text = string.gsub(text, '(c%-)', 'C')
    text = string.gsub(text, '(Mouse Button )', 'M')
    text = string.gsub(text, '(Middle Mouse)', 'M3')
    text = string.gsub(text, '(Num Pad )', 'N')
    text = string.gsub(text, '(Page Up)', 'PU')
    text = string.gsub(text, '(Page Down)', 'PD')
    text = string.gsub(text, '(Spacebar)', 'SpB')
    text = string.gsub(text, '(Insert)', 'Ins')
    text = string.gsub(text, '(Home)', 'Hm')
    text = string.gsub(text, '(Delete)', 'Del')
    text = string.gsub(text, '(Left Arrow)', 'LT')
    text = string.gsub(text, '(Right Arrow)', 'RT')
    text = string.gsub(text, '(Up Arrow)', 'UP')
    text = string.gsub(text, '(Down Arrow)', 'DN')

    if hotkey:GetText() == RANGE_INDICATOR then
        hotkey:SetText('')
    else
        if GetSetting('BUTTON_ASSIGNMENTS') then
            hotkey:SetText(text)
        else
            hotkey:SetText('')
        end
    end
end

function gwHideBackdrop(self)
    _G[self:GetName() .. 'GwBackDrop']:Hide()
end

function gwShowBackdrop(self)
    _G[self:GetName() .. 'GwBackDrop']:Show()
end

function gw_setActionButtonStyle(buttonName, noBackDrop, hideUnused, isStanceButton)
    if _G[buttonName..'Icon']~=nil then
        _G[buttonName..'Icon']:SetTexCoord(0.1,0.9,0.1,0.9)
    end
    if _G[buttonName.."HotKey"]~=nil then
        _G[buttonName.."HotKey"]:ClearAllPoints()
        _G[buttonName.."HotKey"]:SetPoint('CENTER',_G[buttonName],'BOTTOM',0,0)
        _G[buttonName.."HotKey"]:SetJustifyH("CENTER")
    end
    if _G[buttonName.."Count"]~=nil then
        _G[buttonName.."Count"]:ClearAllPoints()
        _G[buttonName.."Count"]:SetPoint('TOPRIGHT',_G[buttonName],'TOPRIGHT',-3,-3)
        _G[buttonName.."Count"]:SetJustifyH("RIGHT")
        _G[buttonName.."Count"]:SetFont(UNIT_NAME_FONT,14,'OUTLINED')
        _G[buttonName.."Count"]:SetTextColor(1,1,0.6)
    end

    if _G[buttonName..'Border'] ~= nil then
        _G[buttonName..'Border']:SetBlendMode('BLEND')
        if isStanceButton then
            _G[buttonName..'Border']:Show()
            _G[buttonName..'Border']:SetSize(_G[buttonName]:GetWidth(),_G[buttonName]:GetWidth())
            _G[buttonName..'Border']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\stancebar-border')
        else
            _G[buttonName..'Border']:SetSize(_G[buttonName]:GetWidth(),_G[buttonName]:GetWidth())
            _G[buttonName..'Border']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder')
        end
    end
    if _G[buttonName..'NormalTexture']~=nil then
        _G[buttonName]:SetNormalTexture(nil)
    end
    
    if _G[buttonName..'FloatingBG']~=nil then
        _G[buttonName..'FloatingBG']:SetTexture(nil)
    end
    if _G[buttonName..'NormalTexture2']~=nil then
        _G[buttonName..'NormalTexture2']:SetTexture(nil)
        _G[buttonName..'NormalTexture2']:Hide()
    end
    if _G[buttonName..'AutoCastable']~=nil then
        _G[buttonName..'AutoCastable']:SetSize(_G[buttonName]:GetWidth(),_G[buttonName]:GetWidth())
    end

    _G[buttonName]:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\actionbutton-pressed')
    _G[buttonName]:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G[buttonName]:SetCheckedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G[buttonName].Name:SetAlpha(0)

    if noBackDrop==nil or noBackDrop==false then
        local backDrop = CreateFrame('Frame', buttonName .. 'GwBackDrop', _G[buttonName]:GetParent(), 'GwActionButtonBackDrop')
        local backDropSize = 1
        if _G[buttonName]:GetWidth()>40 then
            backDropSize =2
        end

        backDrop:SetPoint('TOPLEFT',_G[buttonName],'TOPLEFT',-backDropSize,backDropSize)
        backDrop:SetPoint('BOTTOMRIGHT',_G[buttonName],'BOTTOMRIGHT',backDropSize,-backDropSize)
    end

    if hideUnused==true then
        _G[buttonName..'GwBackDrop']:Hide()
        _G[buttonName]:HookScript('OnHide', gwHideBackdrop)
        _G[buttonName]:HookScript('OnShow', gwShowBackdrop)
    end
end

function gwMainMenuOnEvent(self, event)
    if event == 'PLAYER_EQUIPMENT_CHANGED' then
        gwActionBarEquipUpdate()
    end
end

function gwShowAttr()
    for i=1,12 do
        local BUTTON =  _G['ActionButton'..i]
    end
end

local function updateMainBar()
    local used_height = MAIN_MENU_BAR_BUTTON_SIZE
    local btn_padding = MAIN_MENU_BAR_BUTTON_MARGIN
    local rangeIndicatorSetting = GetSetting("MAINBAR_RANGEINDICATOR")

    MainMenuBarArtFrame.gw_Buttons = {}
    for i = 1, 12 do
        local btn = _G['ActionButton' .. i]
        MainMenuBarArtFrame.gw_Buttons[i] = btn
        
        if btn ~= nil then
            btn:SetScript('OnUpdate', nil) -- disable the default button update handler

            local hotkey = _G['ActionButton' .. i .. 'HotKey']
            btn_padding = btn_padding + MAIN_MENU_BAR_BUTTON_SIZE + MAIN_MENU_BAR_BUTTON_MARGIN
            btn:SetSize(MAIN_MENU_BAR_BUTTON_SIZE, MAIN_MENU_BAR_BUTTON_SIZE)

            gw_setActionButtonStyle('ActionButton' .. i)
            gwActionButton_UpdateHotkeys(btn)

            hotkey:SetPoint('BOTTOMLEFT', btn, 'BOTTOMLEFT', 0, 0)
            hotkey:SetPoint('BOTTOMRIGHT', btn, 'BOTTOMRIGHT', 0, 0)
            hotkey:SetFont(DAMAGE_TEXT_FONT, 14, 'OUTLINED')
            hotkey:SetTextColor(1, 1, 1)
            btn.changedColor = false
            btn.rangeIndicatorSetting = rangeIndicatorSetting
            
            if IsEquippedAction(btn.action) then
                local borname = 'ActionButton' .. i .. 'Border'
                if _G[borname] then
                    _G[borname]:SetVertexColor(0, 1.0, 0, 1)
                end
            end

            local rangeIndicator = CreateFrame('FRAME', 'GwActionRangeIndicator' .. i, hotkey:GetParent(), 'GwActionRangeIndicator')
            rangeIndicator:SetFrameStrata('BACKGROUND', 1)
            rangeIndicator:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT', -1, -2)
            rangeIndicator:SetPoint('TOPRIGHT', btn, 'BOTTOMRIGHT', 1, -2)
            _G['GwActionRangeIndicator' .. i .. 'Texture']:SetVertexColor(147/255, 19/255, 2/255)
            rangeIndicator:Hide()

            btn['gw_RangeIndicator'] = rangeIndicator
            btn['gw_HotKey'] = hotkey

            if GetSetting('BUTTON_ASSIGNMENTS') then
                local hkBg = CreateFrame('Frame', 'GwHotKeyBackDropActionButton' .. i, hotkey:GetParent(), 'GwActionHotKeyBackDrop')
            
                hkBg:SetPoint('CENTER', hotkey, 'CENTER', 0, 0)
                _G['GwHotKeyBackDropActionButton' .. i .. 'Texture']:SetParent(hotkey:GetParent())
            end

            btn:ClearAllPoints()
            btn:SetPoint('LEFT', MainMenuBarArtFrame, 'LEFT', btn_padding - MAIN_MENU_BAR_BUTTON_MARGIN - MAIN_MENU_BAR_BUTTON_SIZE, 0)

            if i == 6 then
                btn_padding = btn_padding + 108
            end
        end
    end
    MainMenuBarArtFrame:HookScript('OnUpdate', gwActionButtons_OnUpdate)
    MainMenuBarArtFrame:ClearAllPoints()
    if GetSetting("XPBAR_ENABLED") then
        MainMenuBarArtFrame:SetPoint('TOP', UIParent, 'BOTTOM', 0, 80)
    else
        MainMenuBarArtFrame:SetPoint('TOP', UIParent, 'BOTTOM', 0, 66)
    end
    MainMenuBarArtFrame:SetSize(btn_padding, used_height)
    MainMenuBarArtFrame:SetFrameStrata("LOW")
end

local function updateMultiBar(barName, buttonName)
    local multibar = _G[barName]
    local settings = GetSetting(barName)
    local used_width = 0
    local used_height = settings['size']
    local btn_padding = 0
    local btn_padding_y = 0
    local btn_this_row = 0

    multibar.gw_Buttons = {}
    multibar.gw_LastFadeCheck = -1
    if multibar:IsShown() then
        multibar.gw_FadeShowing = true
    else
        multibar.gw_FadeShowing = false
    end

    GW.RegisterScaleFrame(multibar)
    
    for i = 1, 12 do
        local btn = _G[buttonName .. i]
        multibar.gw_Buttons[i] = btn

        if btn ~= nil then
            btn:SetScript('OnUpdate', nil) -- disable the default button update handler

            btn:SetSize(settings.size, settings.size)
            gwActionButton_UpdateHotkeys(btn)
            gw_setActionButtonStyle(buttonName .. i, nil, GetSetting('HIDEACTIONBAR_BACKGROUND_ENABLED'))

            btn:ClearAllPoints()
            btn:SetPoint('TOPLEFT', multibar, 'TOPLEFT', btn_padding, -btn_padding_y)

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
                local borname = buttonName .. i .. 'Border'
                if _G[borname] then
                    _G[borname]:SetVertexColor(0, 1.0, 0, 1)
                end
            end
        end
    end
    multibar:HookScript('OnUpdate', gwMultiButtons_OnUpdate)
    multibar:ClearAllPoints()
    if (barName == "MultiBarBottomRight" or barName == "MultiBarBottomLeft") and not GetSetting("XPBAR_ENABLED") then
        multibar:SetPoint(settings.point, UIParent, settings.relativePoint, settings.xOfs, settings.yOfs -14)
    else
        multibar:SetPoint(settings.point, UIParent, settings.relativePoint, settings.xOfs, settings.yOfs)
    end
    multibar:SetSize(used_width, used_height)
    multibar:SetFrameStrata("LOW")
end

local function getStanceBarButton()
    if _G["GwStanceBarButton"] ~= nil then
        return _G["GwStanceBarButton"]
    else
        local SBB = CreateFrame('Button', 'GwStanceBarButton', UIParent, 'GwStanceBarButton')

        SBB:RegisterEvent('CHARACTER_POINTS_CHANGED')
        SBB:RegisterEvent('PLAYER_ALIVE')
        SBB:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
        SBB:SetScript('OnEvent', GW.StanceOnEvent)
        return SBB
    end
end

local function getStanceBarContainer()
    if _G["GwStanceBarContainer"] ~= nil then
        return _G["GwStanceBarContainer"]
    else
        return CreateFrame('Frame', 'GwStanceBarContainer', UIParent, nil)
    end
end

local function setStanceBar()
    local SBB = getStanceBarButton()
    local SBC

    for i = 1, 10 do
        if _G["StanceButton" .. i] ~= nil then
            if i == 1 then
                _G["StanceButton" .. i]:ClearAllPoints()
                _G["StanceButton" .. i]:SetPoint('BOTTOM', StanceBarFrame, 'BOTTOM', 0, 0)
            else
                _G["StanceButton" .. i]:ClearAllPoints()
                _G["StanceButton" .. i]:SetPoint('BOTTOM', _G['StanceButton' .. i - 1], 'TOP', 0, 2)
            end
            _G["StanceButton" .. i]:SetSize(30, 30)
            gw_setActionButtonStyle('StanceButton' .. i, true, nil, true)
        end
    end

    SBB:ClearAllPoints()
    if GetSetting("STANCEBAR_POSITION") == "LEFT" then
        SBB:SetPoint('BOTTOMRIGHT', ActionButton1, 'BOTTOMLEFT', -5, 0)
    else
        SBB:SetPoint('BOTTOMLEFT', ActionButton12, 'BOTTOMRIGHT', 5, 0)
    end

    if GetNumShapeshiftForms() == 1 then
        StanceButton1:ClearAllPoints()
        if GetSetting("STANCEBAR_POSITION") == "LEFT" then
            StanceButton1:SetPoint('TOPRIGHT', ActionButton1, 'TOPLEFT', -5, 2)
        else
            StanceButton1:SetPoint('TOPLEFT', ActionButton12, 'TOPRIGHT', 5, 2)
        end
    else
        SBC = getStanceBarContainer()
        SBC:ClearAllPoints()
        SBC:SetPoint('BOTTOM', SBB, 'TOP', 0, 0)
        
        StanceBarFrame:SetParent(SBC)
        StanceBarFrame:ClearAllPoints()
        StanceBarFrame:SetPoint('BOTTOMLEFT', SBB, 'TOPLEFT', 0, 0)
        StanceBarFrame:SetPoint('BOTTOMRIGHT', SBB, 'TOPRIGHT', 0, 0)
    end

    if GetNumShapeshiftForms() < 2 then
        SBB:Hide()
    else
        SBB:Show()
        SBC:Hide()
        SBB:SetFrameRef('GwStanceBarContainer', SBC)
        SBB:SetAttribute("_onclick", [=[
        if self:GetFrameRef('GwStanceBarContainer'):IsVisible() then
            self:GetFrameRef('GwStanceBarContainer'):Hide()
        else
            self:GetFrameRef('GwStanceBarContainer'):Show()
        end
    ]=])
    end
end
GW.setStanceBar = setStanceBar

local function StanceOnEvent(self, event, ...)
    local unit = ...
    if InCombatLockdown() or unit ~= "player" then
        return
    end

    if GetNumShapeshiftForms() < 1 then
        GwStanceBarButton:Hide()
    else
        setStanceBar()
        GwStanceBarButton:Show()
    end
end
GW.StanceOnEvent = StanceOnEvent

function gw_setbagFrame()   
    if not GetSetting('BAGS_ENABLED') then
        CharacterBag0Slot:ClearAllPoints()
        CharacterBag1Slot:ClearAllPoints()
        CharacterBag2Slot:ClearAllPoints()
        CharacterBag3Slot:ClearAllPoints()

        MainMenuBarBackpackButton:SetPoint('RIGHT', ActionButton12, 'RIGHT', ActionButton12:GetWidth() + 64, 0)

        CharacterBag0Slot:SetPoint('LEFT', MainMenuBarBackpackButton, 'RIGHT', 0, 0)
        CharacterBag1Slot:SetPoint('LEFT', CharacterBag0Slot, 'RIGHT', 0, 0)
        CharacterBag2Slot:SetPoint('LEFT', CharacterBag1Slot, 'RIGHT', 0, 0)
        CharacterBag3Slot:SetPoint('LEFT', CharacterBag2Slot, 'RIGHT', 0, 0)
    end
end

function gwVehicleLeaveOnShow()
    MainMenuBarVehicleLeaveButton:SetScript('OnUpdate', gwVehicleLeaveOnUpdate)
end

function gwVehicleLeaveOnHide()
    MainMenuBarVehicleLeaveButton:SetScript('OnUpdate', nil)
end

function gwVehicleLeaveOnUpdate()
    if InCombatLockdown() then
        return
    end
    MainMenuBarVehicleLeaveButton:SetPoint('LEFT', ActionButton12, 'RIGHT', 0, 0)
end

function gw_setLeaveVehicleButton()   
    MainMenuBarVehicleLeaveButton:SetParent(MainMenuBar)
    MainMenuBarVehicleLeaveButton:ClearAllPoints()
    MainMenuBarVehicleLeaveButton:SetPoint('LEFT',ActionButton12,'RIGHT',0,0)

    MainMenuBarVehicleLeaveButton:HookScript('OnShow', gwVehicleLeaveOnShow)
    MainMenuBarVehicleLeaveButton:HookScript('OnHide', gwVehicleLeaveOnHide) 
end

function gwActionBarEquipUpdate()
    local bars = {'MultiBarBottomRightButton', 'MultiBarBottomLeftButton', 'MultiBarRightButton', 'MultiBarLeftButton', 'ActionButton'}
    for b = 1, #bars do
        local barname = bars[b]
        for i = 1, 12 do
            local button = _G[barname .. i]
            if button ~= nil then
                if IsEquippedAction(button.action) then
                    local borname = barname .. i .. 'Border'
                    if _G[borname] then
                        GW.Wait(0.05, function()
                            _G[borname]:SetVertexColor(0, 1.0, 0, 1)
                        end)
                    end
                end
            end
        end
    end
end

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

local out_R, out_G, out_B = RED_FONT_COLOR:GetRGB()

function gwActionButtons_OnUpdate(self, elapsed)
    for i = 1, 12 do
        local btn = self.gw_Buttons[i]
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
                    if btn.rangeIndicatorSetting == "RED_INDICATOR" then
                        btn.gw_RangeIndicator:Hide()
                    elseif btn.rangeIndicatorSetting == "RED_OVERLAY" then
                        if btn.changedColor then
                            btn.icon:SetVertexColor(1, 1, 1)
                            btn.changedColor = false
                        end
                    elseif btn.rangeIndicatorSetting == "BOTH" then
                        btn.gw_RangeIndicator:Hide()
                        if btn.changedColor then
                            btn.icon:SetVertexColor(1, 1, 1)
                            btn.changedColor = false
                        end
                    end
                end
                rangeTimer = TOOLTIP_UPDATE_TIME
            end
            btn.rangeTimer = rangeTimer
        end
    end
end


local function changeVertexColorActionbars()
    local fmMultiBar 
    for y = 1, 5 do
        if y == 1 then fmMultiBar = _G["MultiBarBottomRight"] end
        if y == 2 then fmMultiBar = _G["MultiBarBottomLeft"] end
        if y == 3 then fmMultiBar = _G["MultiBarLeft"] end
        if y == 4 then fmMultiBar = _G["MultiBarRight"] end
        if y == 5 then fmMultiBar = MainMenuBarArtFrame end
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
GW.AddForProfiling("Actionbars2", "changeVertexColorActionbars", changeVertexColorActionbars)

function gwMultiButtons_OnUpdate(self, elapsed)
    if not self.gw_FadeShowing then
        return -- don't need OnUpdate stuff if this bar is not visible
    end

    for i = 1, 12 do
        local btn = self.gw_Buttons[i]
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
                    btn.icon:SetVertexColor(out_R, out_G, out_B)
                    btn.changedColor = true
                else
                    if btn.changedColor then
                        btn.icon:SetVertexColor(1, 1, 1)
                        btn.changedColor = false
                    end
                end
                rangeTimer = TOOLTIP_UPDATE_TIME
            end

            btn.rangeTimer = rangeTimer
        end
    end
end
-- other things can register callbacks for when actionbar visibility/fade changes
local callback = {}

local function AddActionBarCallback(m)
    local k = CountTable(callback) + 1
    callback[k] = m
end
GW.AddActionBarCallback = AddActionBarCallback

local function LoadActionBars()
    local HIDE_ACTIONBARS_CVAR = GetSetting('HIDEACTIONBAR_BACKGROUND_ENABLED')
    if HIDE_ACTIONBARS_CVAR then
        HIDE_ACTIONBARS_CVAR = 0
    else
        HIDE_ACTIONBARS_CVAR = 1
    end

    SetCVar('alwaysShowActionBars', HIDE_ACTIONBARS_CVAR)

    for k, v in pairs(GW_BARS) do
        v:SetParent(UIParent)
    end

    for _, frame in pairs({
        'MultiBarLeft',
        'MultiBarRight',
        'MultiBarBottomRight',
        'MultiBarBottomLeft',
        'StanceBarFrame',
        'PossessBarFrame',
        'MULTICASTACTIONBAR_YPOS',
        'MultiCastActionBarFrame',
        'PETACTIONBAR_YPOS',
        'PETACTIONBAR_XPOS',
    }) do
        UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
    end

    updateMainBar()
    updateMultiBar('MultiBarBottomRight', 'MultiBarBottomRightButton')
    updateMultiBar('MultiBarBottomLeft', 'MultiBarBottomLeftButton')
    updateMultiBar('MultiBarRight', 'MultiBarRightButton')
    updateMultiBar('MultiBarLeft', 'MultiBarLeftButton')

    MultiBarBottomLeft:HookScript('OnShow', function (self, event)
        self.gw_FadeShowing = true
        GW.updatePetFrameLocation()
    end)
    MultiBarBottomLeft:HookScript('OnHide', function (self, event)
        self.gw_FadeShowing = false
        GW.updatePetFrameLocation()
    end)
    MultiBarBottomRight:HookScript('OnShow', function (self, event)
        self.gw_FadeShowing = true
        GW.UpdatePlayerBuffFrame()
    end)
    MultiBarBottomRight:HookScript('OnHide', function (self, event)
        self.gw_FadeShowing = false
        GW.UpdatePlayerBuffFrame()
    end)
    MultiBarLeft:HookScript('OnShow', function (self, event)
        self.gw_FadeShowing = true
    end)
    MultiBarLeft:HookScript('OnHide', function (self, event)
        self.gw_FadeShowing = false
    end)
    MultiBarRight:HookScript('OnShow', function (self, event)
        self.gw_FadeShowing = true
    end)
    MultiBarRight:HookScript('OnHide', function (self, event)
        self.gw_FadeShowing = false
    end)

    RegisterMovableFrame(MultiBarRight, SHOW_MULTIBAR3_TEXT, 'MultiBarRight', 'VerticalActionBarDummy')
    RegisterMovableFrame(MultiBarLeft, SHOW_MULTIBAR4_TEXT, 'MultiBarLeft', 'VerticalActionBarDummy')

    hooksecurefunc('MultiActionBar_Update', function() 
        if InCombatLockdown() then return end

        local multibar = _G["MultiBarLeft"]
        local settings = GetSetting("MultiBarLeft")
        multibar:ClearAllPoints()
        multibar:SetPoint(settings.point, UIParent, settings.relativePoint, settings.xOfs, settings.yOfs)
        multibar:SetScale(MultiBarLeft.gwMover:GetScale())
        MultiBarRight:SetScale(MultiBarRight.gwMover:GetScale())
    end)

    local fgw = CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")
    fgw:SetFrameRef("MultiBarLeft", MultiBarLeft)
    fgw:SetFrameRef("MultiBarRight", MultiBarRight)
    fgw:SetFrameRef("GwMultiBarRightMoveAble", MultiBarRight.gwMover)
    fgw:SetFrameRef("GwMultiBarLeftMoveAble", MultiBarLeft.gwMover)
    fgw:SetAttribute(
        "_onstate-page",
        [=[
        local mbarL = self:GetFrameRef("MultiBarLeft")
        local mbarR = self:GetFrameRef("MultiBarRight")
        local framePosL = self:GetFrameRef("GwMultiBarLeftMoveAble")
        local framePosR = self:GetFrameRef("GwMultiBarRightMoveAble")
        local protected = mbarL:IsProtected()

        if protected then
            mbarL:ClearAllPoints()
            mbarL:SetPoint(framePosL:GetPoint())
            mbarL:SetScale(framePosL:GetScale())

            mbarR:ClearAllPoints()
            mbarR:SetPoint(framePosR:GetPoint())
            mbarR:SetScale(framePosR:GetScale())
        end
        ]=]
    )
    RegisterStateDriver(fgw, "page", "[vehicleui] 1; [possessbar] 2; [overridebar] 3; [shapeshift] 4; [bar:2] 5; [bar:3] 6; [bar:4] 7; [bar:5] 8; [bar:6] 9; [bonusbar:1] 10; [bonusbar:2] 11; [bonusbar:3] 12; [bonusbar:4] 13; 14")

    gw_hideBlizzardsActionbars()
    setStanceBar()
    gw_setbagFrame()
    gw_setLeaveVehicleButton()

    hooksecurefunc("ActionButton_UpdateHotkeys",  gwActionButton_UpdateHotkeys)
    hooksecurefunc("ActionButton_UpdateUsable", changeVertexColorActionbars)

    MainMenuBarArtFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    MainMenuBarArtFrame:RegisterEvent('UPDATE_BONUS_ACTIONBAR')
    MainMenuBarArtFrame:HookScript('OnEvent', gwMainMenuOnEvent)
end
GW.LoadActionBars = LoadActionBars