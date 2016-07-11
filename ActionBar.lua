local addon, ns = ...
local pet_bar_state =1
local exit_trot = 0
local pet_bar_th = 0

function set_exit_button()
    MainMenuBarVehicleLeaveButton:ClearAllPoints()
	MainMenuBarVehicleLeaveButton:SetPoint('RIGHT', ActionButton12, 'RIGHT', ActionButton12:GetWidth(), 0) 
end
function check_Exit_Button()
    if exit_trot>GetTime() then
        return
    end
    exit_trot = GetTime() + 1
    MainMenuBarVehicleLeaveButton:ClearAllPoints()
	MainMenuBarVehicleLeaveButton:SetPoint('RIGHT', ActionButton12, 'RIGHT', ActionButton12:GetWidth(), 0) 
end

function gw_set_actionbars()
    

    
MainMenuBarVehicleLeaveButton:HookScript("OnShow", function(self)
    set_exit_button()
    MainMenuBarVehicleLeaveButton:HookScript('OnUpdate', check_Exit_Button)
end)
MainMenuBarVehicleLeaveButton:HookScript("OnHide", function(self)
    MainMenuBarVehicleLeaveButton:HookScript('OnUpdate', nil)
end)

    
    
    
    MultiBarRight:ClearAllPoints()
	MultiBarLeft:SetScale(0.8)
	MultiBarRight:SetScale(0.8)

    MultiBarBottomLeft:SetScale(0.8)
    MultiBarBottomRight:SetScale(0.8)
    
    
    local left_saved_point = gwGetSetting('multibarleft_pos');
    local right_saved_point = gwGetSetting('multibarright_pos');
    
    MultiBarLeft:SetPoint(left_saved_point['point'],UIParent,left_saved_point['relativePoint'],left_saved_point['xOfs'],left_saved_point['yOfs'])   
   
    MultiBarRight:SetPoint(right_saved_point['point'],UIParent,right_saved_point['relativePoint'],right_saved_point['xOfs'],right_saved_point['yOfs'])   
    
    gw_register_movable_frame(MultiBarLeft:GetName(),MultiBarLeft,'multibarleft_pos','VerticalActionBarDummy')
    gw_register_movable_frame(MultiBarRight:GetName(),MultiBarRight,'multibarright_pos','VerticalActionBarDummy')


	--generate a holder for the config data
	local cfg = CreateFrame("Frame")
	
    local replace = string.gsub
	
    ReputationWatchBar:Hide()
    MainMenuExpBar:Hide()
    MainMenuExpBar:SetScript("OnEvent", nil); 
    
    ArtifactWatchBar:Hide()
    ArtifactWatchBar:SetScript("OnEvent", nil);


    MainMenuBar:SetScale(1.3)    
	
    
    
    MainMenuExpBar:SetScript('OnShow',function(self) self:Hide() end)
    ArtifactWatchBar:SetScript('OnShow',function(self) self:Hide() end)
    
    ReputationWatchBar:SetScript('OnShow',function(self) self:Hide() end)
    
    
    
	OverrideActionBar:SetScale(1)
	
	PetActionButton1:ClearAllPoints()
	--PetActionButton1:SetPoint('BOTTOM', MainMenuBar, 'BOTTOM', 450, 5)
	

    
    -- the bottom right bar needs a better place, above the bottom left bar
	MultiBarBottomRight:EnableMouse(false)
	MultiBarBottomRight:SetHeight(MultiBarBottomRightButton1:GetHeight()*2)
	MultiBarBottomRight:SetWidth(MultiBarBottomRightButton1:GetWidth()*6)

    MultiBarBottomLeft:SetHeight(MultiBarBottomLeftButton1:GetHeight()*2)
	MultiBarBottomLeft:SetWidth(MultiBarBottomLeftButton1:GetWidth()*6)

	MultiBarBottomRight:ClearAllPoints()
	MultiBarBottomLeft:ClearAllPoints()

    PetActionBarFrame:ClearAllPoints()
    PetActionButton1:ClearAllPoints()
    PetActionButton1:SetParent(PetActionBarFrame);

	

    
	PetActionButton1:SetPoint('LEFT', PetActionBarFrame, 'LEFT', 0, 0)

        -- repositiom the micromenu
	
	
	MultiBarBottomRight:SetPoint('BOTTOMRIGHT', ActionButton12, 'TOPRIGHT', -10, 0)
	MultiBarBottomLeft:SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 0, 0)
    
    MultiBarBottomRightButton1:ClearAllPoints()
	MultiBarBottomRightButton1:SetPoint('BOTTOMLEFT', MultiBarBottomRight, 'BOTTOMLEFT', 0, 40)

    
    MultiBarBottomLeftButton1:ClearAllPoints()
	MultiBarBottomLeftButton1:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'BOTTOMLEFT', 0, 28)

    
    

	-- reposition some objects
	MainMenuBarTexture0:SetPoint('BOTTOM', MainMenuBarArtFrame, -128, 0)
	MainMenuBarTexture1:SetPoint('BOTTOM', MainMenuBarArtFrame, 128, 0)
    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint('BOTTOM', -36, 20)

	MainMenuMaxLevelBar0:Hide()
	MainMenuMaxLevelBar1:Hide()
    MainMenuBarTexture0:SetTexture(0,0,0,0)
    MainMenuBarTexture1:SetTexture(0,0,0,0)
    MainMenuBarLeftEndCap:Hide()
    MainMenuBarRightEndCap:Hide()

    CastingBarFrame:Hide()
    CastingBarFrame:UnregisterAllEvents()
    
    
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

	-- a new place for the exit vehicle button

	stancePadding = 0
	for i = 1,12 do
        
 
    --MAIN ACTIONBAR--
    setBackDrop("MultiBarLeftButton"..i.."Icon",'MultiBarLeft')
    setBackDrop("MultiBarRightButton"..i.."Icon",'MultiBarRight')
    
    setBackDrop("ActionButton"..i.."Icon",'MainMenuBar')
    setBackDrop("MultiBarBottomLeftButton"..i.."Icon",'MultiBarBottomLeft')
    setBackDrop("MultiBarBottomRightButton"..i.."Icon",'MultiBarBottomRight')
    
    --setOverlay("ActionButton"..i.."Icon","ActionButton"..i)
    --setOverlay("MultiBarBottomLeftButton"..i.."Icon","MultiBarBottomLeftButton"..i)
    -- setOverlay("MultiBarBottomRightButton"..i.."Icon","MultiBarBottomRightButton"..i)

    if  _G["MultiBarRightButton"..i.."Icon"] then
        _G["MultiBarRightButton"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
    end
    if  _G["MultiBarLeftButton"..i.."Icon"] then
        _G["MultiBarLeftButton"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
    end
    
    if  _G["StanceButton"..i.."Icon"] then
       _G["StanceButton"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
    end
    if  _G["PetActionButton"..i.."Icon"] then
       _G["PetActionButton"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
    end
      if  _G["ActionButton"..i.."Icon"] then
       _G["ActionButton"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
    end

    if  _G["MultiBarBottomLeftButton"..i.."Icon"] then
        _G["MultiBarBottomLeftButton"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
    end
    
    if  _G["MultiBarBottomRightButton"..i.."Icon"] then
        _G["MultiBarBottomRightButton"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
    end
    
    if _G["StanceButton"..i.."Icon"] then
        _G["StanceButton"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
            _G["StanceButton"..i]:SetSize(38,38)
    end
    
    _G["MultiBarBottomLeftButton" .. i .. "HotKey"]:ClearAllPoints()
    _G["MultiBarBottomRightButton" .. i .. "HotKey"]:ClearAllPoints()
    
        

    _G["MultiBarBottomLeftButton" .. i .. "HotKey"]:SetPoint('BOTTOM', _G["MultiBarBottomLeftButton" .. i ], 0, -4)
    
    _G["MultiBarBottomRightButton" .. i .. "HotKey"]:SetPoint('BOTTOM', _G["MultiBarBottomRightButton" .. i ], 0, -4)
    _G["MultiBarBottomRightButton" .. i .. "HotKey"]:SetJustifyH("CENTER")
    _G["MultiBarBottomLeftButton" .. i .. "HotKey"]:SetJustifyH("CENTER") 
    _G["MultiBarBottomRightButton" .. i .. "HotKey"]:SetFont(UNIT_NAME_FONT,11)
    _G["MultiBarBottomLeftButton" .. i .. "HotKey"]:SetFont(UNIT_NAME_FONT,11)
    
    _G["ActionButton" .. i .. "HotKey"]:ClearAllPoints()
    _G["ActionButton" .. i .. "HotKey"]:SetFont(UNIT_NAME_FONT,14)
    _G["ActionButton" .. i .. "HotKey"]:SetPoint('BOTTOM', _G["ActionButton" .. i ], 0, -10)
    
    _G["ActionButton" .. i .. "HotKey"]:SetJustifyH("CENTER")
    

        _G["hotKey" .. i .. "BG"], _G["hotKey" .. i .. "BGt"] = createBackground('BOTTOM',25,25,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbg",4)

    _G["hotKey" .. i .. "BG"]:ClearAllPoints();
    _G["hotKey" .. i .. "BG"]:SetFrameLevel(3)
    _G["hotKey" .. i .. "BG"]:SetFrameStrata("LOW")
    _G["hotKey" .. i .. "BGt"]:SetVertexColor(0,0,0,1);
    _G["hotKey" .. i .. "BG"]:SetPoint('CENTER', _G["ActionButton" .. i .. "HotKey"], 'CENTER', 0,-2);
    
        
    _G["ActionButton" .. i .. "NormalTexture" ]:SetTexture(nil)
    
    -- _G["MultiBarBottomRightButton" .. i .. "NormalTexture" ]:SetTexture(nil)
    --   _G["MultiBarBottomRightButton" .. i .. "NormalTexture" ]:SetTexture(nil)

    if  _G["MultiBarLeftButton" .. i..'FloatingBG'] then
        _G["MultiBarLeftButton" .. i..'FloatingBG']:SetTexture(nil)
    end
    if  _G["MultiBarRightButton" .. i..'FloatingBG'] then
        _G["MultiBarRightButton" .. i..'FloatingBG']:SetTexture(nil)
    end
    if  _G["MultiBarBottomLeftButton" .. i..'FloatingBG'] then
        _G["MultiBarBottomLeftButton" .. i..'FloatingBG']:SetTexture(nil)
    end
    if  _G["MultiBarBottomRightButton" .. i..'FloatingBG'] then
        _G["MultiBarBottomRightButton" .. i..'FloatingBG']:SetTexture(nil)
    end
    if  _G["ActionButton" .. i..'FloatingBG'] then
        _G["ActionButton" .. i..'FloatingBG']:SetTexture(nil)
    end
    if  _G["StanceButton" .. i..'FloatingBG'] then
        _G["StanceButton" .. i..'FloatingBG']:SetTexture(nil)
    end
    if  _G["PetActionButton" .. i..'FloatingBG'] then
        _G["PetActionButton" .. i..'FloatingBG']:SetTexture(nil)
    end
    
    _G["MultiBarLeftButton" .. i ]:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["MultiBarRightButton" .. i ]:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["ActionButton" .. i ]:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["MultiBarBottomRightButton" .. i]:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["MultiBarBottomLeftButton" .. i]:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    
       
    
    _G["MultiBarLeftButton" .. i ]:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["MultiBarRightButton" .. i ]:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["ActionButton" .. i ]:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["MultiBarBottomRightButton" .. i]:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["MultiBarBottomLeftButton" .. i]:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    
    _G["MultiBarLeftButton" .. i ]:SetCheckedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["MultiBarRightButton" .. i ]:SetCheckedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["ActionButton" .. i ]:SetCheckedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["MultiBarBottomRightButton" .. i]:SetCheckedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
    _G["MultiBarBottomLeftButton" .. i]:SetCheckedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
     
    
    _G["MultiBarLeftButton" .. i ]:SetNormalTexture(nil)
    _G["MultiBarRightButton" .. i ]:SetNormalTexture(nil)
    _G["ActionButton" .. i ]:SetNormalTexture(nil)
    _G["MultiBarBottomRightButton" .. i ]:SetNormalTexture(nil)
    _G["MultiBarBottomLeftButton" .. i ]:SetNormalTexture(nil)
        
    if  _G["StanceButton"..i.."Icon"]~=nil then
        _G["StanceButton" .. i]:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
        _G["StanceButton" .. i]:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
        _G["StanceButton" .. i]:SetCheckedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
            if _G["StanceButton" .. i..'NormalTexture2']  then
                _G["StanceButton" .. i..'NormalTexture2']:SetTexture(nil)
        end
    end
        
    
        
    if  _G["PetActionButton"..i.."Icon"] then
        _G["PetActionButton" .. i]:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
        _G["PetActionButton" .. i]:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
        _G["PetActionButton" .. i]:SetCheckedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
     --   _G["StanceButton" .. i ]:SetNormalTexture(nil)
    end
    
    --    _G["ActionButton" .. i .. "Icon" ]:SetDrawLayer("OVERLAY", 0)
    if _G["ActionButton" .. i .. "Hotkey" ] then
        --_G["ActionButton" .. i .. "Hotkey" ]:SetDrawLayer("OVERLAY", 0)
      
        end
    
    if i > 1 then
        _G["ActionButton" .. i]:ClearAllPoints()
		_G["MultiBarBottomLeftButton" .. i]:ClearAllPoints()
		
		_G["MultiBarBottomRightButton" .. i]:ClearAllPoints()
  
		
        local padding = (i -1) * ActionButton1:GetWidth()
        local leftPadding = (i -1) * (MultiBarBottomLeftButton1:GetWidth()+2)
        local ypadding = 0
    
        if i > 6 then
            padding = padding + 80
            ypadding = MultiBarBottomLeftButton1:GetHeight() + 3
            leftPadding = (i -7) * (MultiBarBottomLeftButton1:GetWidth()+2)
        end
		  
        
        _G["ActionButton" .. i]:SetPoint('RIGHT', ActionButton1, padding + 5*(i-1), 0)
       
        
        _G["MultiBarBottomLeftButton" .. i]:SetPoint('RIGHT', MultiBarBottomLeftButton1, leftPadding, ypadding)
        _G["MultiBarBottomRightButton" .. i]:SetPoint('RIGHT', MultiBarBottomRightButton1, leftPadding, ypadding)
        
        
            if  _G["StanceButton"..i]~=nil and i~=1 then
                _G["StanceButton"..i]:ClearAllPoints()

                local last = i - 1
                
                _G["StanceButton"..i]:SetPoint('BOTTOM',_G['StanceButton'..last],'TOP',0,2)
                
                
            end
    
		
    end
        

end
    

	do
		for _, frame in pairs({
			'MultiBarLeft',
			'MultiBarRight',
			'MultiBarBottomRight',

			'StanceBarFrame',
			'PossessBarFrame',

			'MULTICASTACTIONBAR_YPOS',
			'MultiCastActionBarFrame',

			'PETACTIONBAR_YPOS',
			'PETACTIONBAR_XPOS',
			'PetActionBarFrame',
			
		}) do
			UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
		end
	end

    
	-- hide unwanted objects
	for i = 2, 3 do
		for _, object in pairs({
			_G['ActionBarUpButton'],
			_G['ActionBarDownButton'],

		--	_G['MainMenuBarBackpackButton'],
			_G['KeyRingButton'],

		--	_G['CharacterBag0Slot'],
		--	_G['CharacterBag1Slot'],
		--	_G['CharacterBag2Slot'],
		--	_G['CharacterBag3Slot'],

			_G['MainMenuBarTexture'..i],
			_G['MainMenuMaxLevelBar'..i],
			_G['MainMenuXPBarTexture'..i],

			_G['ReputationWatchBarTexture'..i],
			_G['ReputationXPBarTexture'..i],

			_G['MainMenuBarPageNumber'],

			_G['SlidingActionBarTexture0'],
			_G['SlidingActionBarTexture1'],

			_G['StanceBarLeft'],
			_G['StanceBarMiddle'],
			_G['StanceBarRight'],
			

			_G['PossessBackground1'],
			_G['PossessBackground2'],
		}) do 
			if (object:IsObjectType('Frame') or object:IsObjectType('Button')) then
				object:UnregisterAllEvents()
				object:SetScript('OnEnter', nil)
				object:SetScript('OnLeave', nil)
				object:SetScript('OnClick', nil)
			end

			hooksecurefunc(object, 'Show', function(self)
				self:Hide()
			end)

			object:Hide()
		end
	end
	
	-- reduce the size of some main menu bar objects
	for _, object in pairs({
		_G['MainMenuBar'],
		_G['MainMenuExpBar'],
		_G['MainMenuBarMaxLevelBar'],

		_G['ReputationWatchBar'],
		_G['ReputationWatchStatusBar'],
	}) do
		object:SetWidth(512)
	end
	
    -- remove divider
	for i = 1, 19, 2 do
		for _, object in pairs({
			_G['MainMenuXPBarDiv'..i],
		}) do
			hooksecurefunc(object, 'Show', function(self)
				self:Hide()
			end)

			object:Hide()
		end
	end



CreateFrame('Button', 'GwStanceBarButton',UIParent,'GwStanceBarButton')
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
    GwStanceBarButton:SetScript('OnEvent',function() 
            if InCombatLockdown() then
                return
            end 
                 
         if  GetNumShapeshiftForms()<1 then
                GwStanceBarButton:Hide()
            else
                GwStanceBarButton:Show()
            end
            
    end)
    

       
        if  GetNumShapeshiftForms()<1 then
            GwStanceBarButton:Hide()
        else
            GwStanceBarButton:Show()
        end
 
        
    GwStanceBarContainer:SetAlpha(0)
    
    GwStanceBarButton:SetScript('OnClick',function()
        if GwStanceBarContainer:GetAlpha()>0 then
                GwStanceBarContainer:SetAlpha(0)
        else
                GwStanceBarContainer:SetAlpha(1)
        end
    end)
	
	

  local function updatehotkey(self, actionButtonType)
	local hotkey = _G[self:GetName() .. 'HotKey']
	local text = hotkey:GetText()
	
	text = replace(text, '(s%-)', 'S')
	text = replace(text, '(a%-)', 'A')
	text = replace(text, '(c%-)', 'C')
	text = replace(text, '(Mouse Button )', 'M')
	text = replace(text, '(Middle Mouse)', 'M3')
	text = replace(text, '(Num Pad )', 'N')
	text = replace(text, '(Page Up)', 'PU')
	text = replace(text, '(Page Down)', 'PD')
	text = replace(text, '(Spacebar)', 'SpB')
	text = replace(text, '(Insert)', 'Ins')
	text = replace(text, '(Home)', 'Hm')
	text = replace(text, '(Delete)', 'Del')
	text = replace(text, '(Left Arrow)', 'LT')
	text = replace(text, '(Right Arrow)', 'RT')
	text = replace(text, '(Up Arrow)', 'UP')
	text = replace(text, '(Down Arrow)', 'DN')
		
	if hotkey:GetText() == _G['RANGE_INDICATOR'] then
		hotkey:SetText('')
	else
		hotkey:SetText(text)
	end
  end
  hooksecurefunc("ActionButton_UpdateHotkeys",  updatehotkey)










    --StanceBarFrame
    --PetActionBarFrame
    --	PetActionBarFrame:SetScale(0.6)
    --PetActionButton1:SetPoint('LEFT', PetActionBarFrame, 'LEFT', 0, 0)
    --  PetActionBarFrame:ClearAllPoints()
  --  PetActionButton1:ClearAllPoints()
--    PetActionButton1:SetParent(PetActionBarFrame
    
    
    function setStanceBar(bool)
        if InCombatLockdown() then
            return
        end 
     --   StanceBarFrame:ClearAllPoints()
        y = 142
        if bool==true then
           y=264
        end
            
        if PetActionBarFrame:IsShown() then
            y = y + 80
        end
  
     --   StanceBarFrame:SetPoint('BOTTOMLEFT',UIParent,'BOTTOM',-480,y)
    
    end
    
    
    function setPetBar(bool)
        
       
        if InCombatLockdown() then
            return
        end
        
        GwPlayerPetFrame:ClearAllPoints()
       
        if bool==true then
            GwPlayerPetFrame:SetPoint('BOTTOMLEFT',UIParent,'BOTTOM',-372,220)
        else
            GwPlayerPetFrame:SetPoint('BOTTOMLEFT',UIParent,'BOTTOM',-372,120)
        end
      --  PetActionButton1:SetPoint('BOTTOMLEFT', PetActionBarFrame, 'BOTTOMLEFT', 0, 0)
        pet_bar_state = bool
    
    end
    

    
    function gw_updatePetBarLocation()
        
        local b = false
        
        if MultiBarBottomLeft:GetAlpha()>0.0 and MultiBarBottomLeft:IsShown() then
            b = true
        end

        setPetBar(b)
        setStanceBar(b)
    end


        
       
      
           
               
    GwPlayerPetFrame:SetScript('OnUpdate',function() 
            if pet_bar_th>GetTime() then return end
            pet_bar_th = GetTime()+1
            if InCombatLockdown() then
                return
            end     
            if PetActionBarFrame and PetActionBarFrame:IsShown() and GwPlayerPetFrame~=nil and GwPlayerPetFrame:IsShown() then
                gw_anchor_petbar()
                GwPlayerPetFrame:SetScript('OnUpdate', nil)
            end
                        
                   
        end)
            
    
    


    setMicroButtons()

end


function gw_anchor_petbar()

    PetActionBarFrame:SetParent(GwPlayerPetFrame)
    PetActionBarFrame:ClearAllPoints()
    PetActionBarFrame:SetPoint('BOTTOMLEFT',GwPlayerPetFrame,'BOTTOMLEFT',0,0)
    PetActionBarFrame:SetScale(0.77)


    gw_actionbar_state_add_callback(gw_updatePetBarLocation)

    PetActionBarFrame:HookScript("OnShow",gw_updatePetBarLocation)
    PetActionBarFrame:HookScript("OnLoad",gw_updatePetBarLocation)
    PetActionBarFrame:SetScript("OnEvent",gw_updatePetBarLocation)
    PetActionBarFrame:SetScript("OnUpdate",nil)
    PetActionBarFrame_OnUpdate = nil
    --hooksecurefunc('PetActionBarFrame_OnUpdate',gw_updatePetBarLocation)
    
    PetActionBarFrame.SetPoint = function() end
    
    
    local f = CreateFrame('frame', nil, nil, 'SecureHandlerStateTemplate')
f:SetFrameRef('PetActionBarFrame', PetActionBarFrame)
f:SetFrameRef('MultiBarBottomLeft', MultiBarBottomLeft)
f:SetFrameRef('StanceBarFrame', StanceBarFrame)
f:SetFrameRef('UIParent', UIParent)
f:SetFrameRef('GwPlayerPetFrame', GwPlayerPetFrame)

f:SetAttribute('_onstate-combat', [=[ 
        
        self:GetFrameRef('GwPlayerPetFrame'):ClearAllPoints()
        y = 264
        if newstate == 'show' then

            self:GetFrameRef('GwPlayerPetFrame'):SetPoint('BOTTOMLEFT',self:GetFrameRef('UIParent'),'BOTTOM',-372,220)
        else
             self:GetFrameRef('GwPlayerPetFrame'):SetPoint('BOTTOMLEFT',self:GetFrameRef('UIParent'),'BOTTOM',-372,120)
        end
        if self:GetFrameRef('PetActionBarFrame'):IsShown() then
            y = y + 80
        end
     
]=])
    
    --   self:GetFrameRef('StanceBarFrame'):SetPoint('BOTTOMLEFT',self:GetFrameRef('UIParent'),'BOTTOM',-480,y)
RegisterStateDriver(f, 'combat', '[combat] show; hide')
    

    gw_updatePetBarLocation() 
end


    MICRO_BUTTON_FUNCTIONS ={}
    function setMicroButtons()
        MicroButtonPortrait:Hide()
        GuildMicroButtonTabard:Hide()
        MainMenuBarPerformanceBar:Hide()
        TalentMicroButtonAlert:Hide()
        TalentMicroButtonAlert:SetScript('OnShow',function(self) self:Hide() end)    

        for i=1, #MICRO_BUTTONS do
        
            if  _G[MICRO_BUTTONS[i]] then
                MICRO_BUTTON_FUNCTIONS[MICRO_BUTTONS[i]]=_G[MICRO_BUTTONS[i]]:GetScript('OnClick')
    
                _G[MICRO_BUTTONS[i]]:SetScript('OnShow',function(self) self:Hide() end)    
                _G[MICRO_BUTTONS[i]]:Hide()
            end
        end
    end


