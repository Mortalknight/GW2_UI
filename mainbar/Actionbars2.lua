local MAIN_MENU_BAR_BUTTON_SIZE = 48
local MAIN_MENU_BAR_BUTTON_MARGIN = 5

local GW_BLIZZARD_HIDE_FRAMES ={
    
  --  MainMenuBar,
    MainMenuBarOverlayFrame,
    MainMenuBarTexture0,
    MainMenuBarTexture1,
    MainMenuBarTexture2,
    MainMenuBarTexture3,
    MainMenuBarRightEndCap,
    MainMenuBarLeftEndCap,
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
    PossessBackground2,
}
   
local GW_BARS= {
    MainMenuBarArtFrame,
    MultiBarLeft,
    MultiBarRight,
    MultiBarBottomLeft,
    MultiBarBottomRight,
}

function gwHideSelf(self)
    self:Hide()
end
function gw_hideBlizzardsActionbars()
    for k,v in pairs(GW_BLIZZARD_HIDE_FRAMES) do
        v:Hide()
        if v.UnregisterAllEvents~=nil then
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
        hooksecurefunc(object, 'Show', gwHideSelf)

        object:Hide()
    end
    
    MainMenuBar:EnableMouse(false)
    
end

function gwActionButton_UpdateHotkeys(self, actionButtonType)
	local hotkey = self.HotKey --_G[self:GetName() .. 'HotKey']
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
		if gwGetSetting('BUTTON_ASSIGNMENTS') then
			hotkey:SetText(text)
		else
			hotkey:SetText('')
		end
	end
end

function gwSetMicroButtons()
    MicroButtonPortrait:Hide()
    GuildMicroButtonTabard:Hide()
    MainMenuBarPerformanceBar:Hide()
    TalentMicroButtonAlert:Hide()
    TalentMicroButtonAlert:SetScript('OnShow', gwHideSelf)

    for i = 1, #MICRO_BUTTONS do
        if _G[MICRO_BUTTONS[i]] then
            _G[MICRO_BUTTONS[i]]:SetScript('OnShow', gwHideSelf)
            _G[MICRO_BUTTONS[i]]:Hide()
        end
    end
end
  
function gwSetMultibarCols()
    local cols = gwGetSetting('MULTIBAR_RIGHT_COLS')
    gwDebug('setting multibar cols', cols)
    local mb1 = gwGetSetting('MultiBarRight')
    local mb2 = gwGetSetting('MultiBarLeft')
    mb1['ButtonsPerRow'] = cols
    mb2['ButtonsPerRow'] = cols
    gwSetSetting('MultiBarRight', mb1)
    gwSetSetting('MultiBarLeft', mb2)
end

function gwHideBackdrop(self)
    _G[self:GetName() .. 'GwBackDrop']:Hide()
end
function gwShowBackdrop(self)
    _G[self:GetName() .. 'GwBackDrop']:Show()
end
function gw_setActionButtonStyle(buttonName, noBackDrop,hideUnused)
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
    
    if _G[buttonName..'Border']~=nil then

        _G[buttonName..'Border']:SetSize(_G[buttonName]:GetWidth(),_G[buttonName]:GetWidth())
        _G[buttonName..'Border']:SetBlendMode('BLEND')
        _G[buttonName..'Border']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder')
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
    
    
    if noBackDrop==nil or noBackDrop==false then
        local backDrop = CreateFrame('Frame',buttonName..'GwBackDrop',_G[buttonName]:GetParent(),'GwActionButtonBackDrop')
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
    if event == 'PET_BATTLE_OPENING_START' then
        gwToggleMainHud(false)
    elseif event == 'PET_BATTLE_CLOSE' then
        gwToggleMainHud(true)
    elseif event == 'PLAYER_EQUIPMENT_CHANGED' then
        gwActionBarEquipUpdate()
    end
end

function gwShowAttr()
    for i=1,12 do
        local BUTTON =  _G['ActionButton'..i]
        print(BUTTON:GetAttribute('type'))
    end
end

local function updateMainBar()
    local used_height = MAIN_MENU_BAR_BUTTON_SIZE
    local btn_padding = MAIN_MENU_BAR_BUTTON_MARGIN

    MainMenuBarArtFrame.gw_ActionButtons = {}
    for i = 1, 12 do
        local btn = _G['ActionButton' .. i]
        MainMenuBarArtFrame.gw_ActionButtons[i] = btn
        
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
            
			if gwGetSetting('BUTTON_ASSIGNMENTS') then
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
    MainMenuBarArtFrame:SetPoint('TOP', UIParent, 'BOTTOM', 0, 80)
    MainMenuBarArtFrame:SetSize(btn_padding, used_height)
end

local function updateMultiBar(barName, buttonName)
    local multibar = _G[barName]
    local settings = gwGetSetting(barName)
    local used_width = 0
    local used_height = settings['size']
    local btn_padding = 0
    local btn_padding_y = 0
    local btn_this_row = 0

    multibar.gw_MultiButtons = {}
    multibar.gw_LastFadeCheck = -1
    multibar.gw_FadeShowing = true
    
    for i = 1, 12 do
        local btn = _G[buttonName .. i]
        multibar.gw_MultiButtons[i] = btn

        if btn ~= nil then
            btn:SetScript('OnUpdate', nil) -- disable the default button update handler

            btn:SetSize(settings.size, settings.size)
            gwActionButton_UpdateHotkeys(btn)
            gw_setActionButtonStyle(buttonName .. i, nil, gwGetSetting('HIDEACTIONBAR_BACKGROUND_ENABLED'))

            btn:ClearAllPoints()
            btn:SetPoint('TOPLEFT', multibar, 'TOPLEFT', btn_padding, -btn_padding_y)

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
    multibar:SetPoint(settings.point, UIParent, settings.relativePoint, settings.xOfs, settings.yOfs)
    multibar:SetSize(used_width, used_height)
end

function gwSetupActionbars()

    local HIDE_ACTIONBARS_CVAR = gwGetSetting('HIDEACTIONBAR_BACKGROUND_ENABLED')
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
 
    --gw_register_movable_frame(MultiBarBottomRight:GetName(),MultiBarBottomRight,'MultiBarBottomRight','VerticalActionBarDummy')
    --gw_register_movable_frame(MultiBarBottomLeft:GetName(),MultiBarBottomLeft,'MultiBarBottomLeft','VerticalActionBarDummy')
    gw_register_movable_frame(MultiBarRight:GetName(),MultiBarRight,'MultiBarRight','VerticalActionBarDummy')
    gw_register_movable_frame(MultiBarLeft:GetName(),MultiBarLeft,'MultiBarLeft','VerticalActionBarDummy')
     
    gw_hideBlizzardsActionbars()
    gwSetMicroButtons()
    gw_setStanceBar()
    if gwGetSetting('PETBAR_ENABLED') then
        gw_setPetBar()
    end
    gw_setbagFrame()
    gw_setLeaveVehicleButton()
     
    hooksecurefunc("ActionButton_UpdateHotkeys",  gwActionButton_UpdateHotkeys)
         
    MainMenuBarArtFrame:RegisterEvent('PET_BATTLE_CLOSE')
    MainMenuBarArtFrame:RegisterEvent('PET_BATTLE_OPENING_START')
    MainMenuBarArtFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    MainMenuBarArtFrame:HookScript('OnEvent', gwMainMenuOnEvent)
end

function gwPetBarUpdate()
    _G['PetActionButton1Icon']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-attack')
    _G['PetActionButton2Icon']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-follow')
    _G['PetActionButton3Icon']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-place')
                        
    _G['PetActionButton8Icon']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-assist')
    _G['PetActionButton9Icon']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-defense')
    _G['PetActionButton10Icon']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-passive')
    for i = 1, 12 do
        if _G['PetActionButton' .. i] ~= nil then
            _G['PetActionButton' .. i .. 'NormalTexture2']:SetTexture(nil)
        end
    end
end
function gw_setPetBar()
    
    local BUTTON_SIZE = 28;
    local BUTTON_MARGIN = 3;
    
    PetActionButton1:ClearAllPoints()
    PetActionButton1:SetPoint('BOTTOMLEFT',GwPlayerPetFrame,'BOTTOMLEFT',3,30)

    for i=1,12 do
    
        if _G['PetActionButton'..i]~=nil then
            
            gwActionButton_UpdateHotkeys(_G['PetActionButton'..i])
            
            _G['PetActionButton'..i]:SetSize(BUTTON_SIZE,BUTTON_SIZE)
            if i < 4 then
                _G['PetActionButton'..i]:SetSize(32,32)
            elseif i==8 then
                _G['PetActionButton'..i]:ClearAllPoints()
                _G['PetActionButton'..i]:SetPoint('BOTTOM',_G['PetActionButton5'],'TOP',0,BUTTON_MARGIN);
           
            end
           
           
            
            if i>1 and i~=8 then
                _G['PetActionButton'..i]:ClearAllPoints()
              
                if i>3 then
                    
                     _G['PetActionButton'..i]:SetPoint('BOTTOMLEFT',_G['PetActionButton'..(i - 1)],'BOTTOMRIGHT',BUTTON_MARGIN,0);
                else
                   
                    _G['PetActionButton'..i]:SetPoint('BOTTOMLEFT',_G['PetActionButton'..(i - 1)],'BOTTOMRIGHT',BUTTON_MARGIN,0);
                end
               
            end
            if _G['PetActionButton'..i..'Shine'] then
                _G['PetActionButton'..i..'Shine']:SetSize(_G['PetActionButton'..i]:GetSize())
               
                
                --for k,v in pairs(_G['PetActionButton'..i..'Shine'].sparkles) do
                --   v:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\autocast')
                --end
               -- _G['PetActionButton'..i..'ShineAutoCastable']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\autocast')
            end
            
            if i==1 then
                hooksecurefunc('PetActionBar_Update', gwPetBarUpdate)
            end
            
            gw_setActionButtonStyle('PetActionButton' .. i)
         
        end
    end
    
end

function gwStanceOnEvent(self, event)
    if InCombatLockdown() then
        return
    end

    if GetNumShapeshiftForms() < 1 then
        GwStanceBarButton:Hide()
    else
        GwStanceBarButton:Show()
    end
end
function gw_setStanceBar()
    
    for i=1,12 do
        if _G["StanceButton"..i]~=nil then
            
            
        
            if i>1 then
                _G["StanceButton"..i]:ClearAllPoints()
                local last = i - 1
                
                _G["StanceButton"..i]:SetPoint('BOTTOM',_G['StanceButton'..last],'TOP',0,2)
            end
            
            _G["StanceButton"..i]:SetSize(38,38)
            gw_setActionButtonStyle('StanceButton'..i,true)
          
        end
    end
    
   
    CreateFrame('Button','GwStanceBarButton',UIParent,'GwStanceBarButton')
    
    GwStanceBarButton:SetPoint('TOPRIGHT',ActionButton1,'TOPLEFT',-5,2)
    CreateFrame('Frame', 'GwStanceBarContainer',UIParent,nil)
    GwStanceBarContainer:SetPoint('BOTTOM',GwStanceBarButton,'TOP',0,0)
    
    StanceBarFrame:SetParent(GwStanceBarContainer)
  
    StanceButton1:ClearAllPoints()
	StanceButton1:SetPoint('BOTTOM', StanceBarFrame, 'BOTTOM', 0, 0)
    

    StanceBarFrame:SetPoint('BOTTOMLEFT',GwStanceBarButton,'TOPLEFT',0,0)
    StanceBarFrame:SetPoint('BOTTOMRIGHT',GwStanceBarButton,'TOPRIGHT',0,0)


    GwStanceBarButton:RegisterEvent('CHARACTER_POINTS_CHANGED')
    GwStanceBarButton:RegisterEvent('PLAYER_ALIVE')
    GwStanceBarButton:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
    GwStanceBarButton:RegisterEvent('UNIT_POWER')
    GwStanceBarButton:RegisterEvent('UNIT_HEALTH')
    GwStanceBarButton:SetScript('OnEvent', gwStanceOnEvent)
       
    if  GetNumShapeshiftForms()<1 then
        GwStanceBarButton:Hide()
    else
        GwStanceBarButton:Show()
    end
 
        
    GwStanceBarContainer:Hide()
    
    GwStanceBarButton:SetFrameRef('GwStanceBarContainer',GwStanceBarContainer)
    
    GwStanceBarButton:SetAttribute("_onclick", [=[
        if self:GetFrameRef('GwStanceBarContainer'):IsVisible() then
            self:GetFrameRef('GwStanceBarContainer'):Hide()
        else
            self:GetFrameRef('GwStanceBarContainer'):Show()
        end
    ]=]);
end


function gw_setbagFrame()
    
      if not gwGetSetting('BAGS_ENABLED') then
        CharacterBag0Slot:ClearAllPoints()
        CharacterBag1Slot:ClearAllPoints()
        CharacterBag2Slot:ClearAllPoints()
        CharacterBag3Slot:ClearAllPoints()

        MainMenuBarBackpackButton:SetPoint('RIGHT', ActionButton12, 'RIGHT', ActionButton12:GetWidth()+64, 0)

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
                        gw_wait(0.05, function()
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

function gwActionButtons_OnUpdate(self, elapsed)
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

function gwMultiButtons_OnUpdate(self, elapsed)
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
