
MainMenuBarVehicleLeaveButton:HookScript("OnShow", function(self)
        
    MainMenuBarVehicleLeaveButton:ClearAllPoints()
	MainMenuBarVehicleLeaveButton:SetPoint('RIGHT', ActionButton12, 'RIGHT', ActionButton12:GetWidth(), 0)
end)




	local addon, ns = ...

	--generate a holder for the config data
	local cfg = CreateFrame("Frame")
	
    local replace = string.gsub
	
	-----------------------------
	-- CONFIG
	-----------------------------
	
	-----------------------------
	-- Main Action Bar
	-----------------------------
	
    MainMenuExpBar:Hide()
    MainMenuExpBar:SetScript("OnEvent", nil);

	MainMenuBar:SetScale(1.3)
	MultiBarBottomLeft:SetScale(0.8)
	MultiBarBottomRight:SetScale(0.8)
	OverrideActionBar:SetScale(1)
	
	PetActionButton1:ClearAllPoints()
	--PetActionButton1:SetPoint('BOTTOM', MainMenuBar, 'BOTTOM', 450, 5)
	
	--StanceButton1:ClearAllPoints()
	StanceBarFrame:ClearAllPoints()
	StanceBarFrame:SetScale(0.6)
	StanceButton1:SetPoint('LEFT', StanceBarFrame, 'LEFT', 0, 0)
	StanceBarFrame:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'TOPLEFT', 0, 20)
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
	PetActionBarFrame:SetScale(0.6)
	PetActionButton1:SetPoint('LEFT', PetActionBarFrame, 'LEFT', 0, 0)

    

    
    
	
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

    -- repositiom the micromenu
	CharacterMicroButton:ClearAllPoints()
	CharacterMicroButton:SetScale(0.6)
	SpellbookMicroButton:SetScale(0.6)
	TalentMicroButton:SetScale(0.6)
	QuestLogMicroButton:SetScale(0.6)
	AchievementMicroButton:SetScale(0.6)
	GuildMicroButton:SetScale(0.6)
	LFDMicroButton:SetScale(0.6)
	CollectionsMicroButton:SetScale(0.6)
	EJMicroButton:SetScale(0.6)
	StoreMicroButton:SetScale(0.6)
	MainMenuMicroButton:SetScale(0.6)
	CharacterMicroButton:SetPoint('TOPLEFT', UIParent,'TOPLEFT', 0, 25)

	hooksecurefunc('MoveMicroButtons', function(anchor, achorTo, relAnchor, x, y, isStacked)
		if (not isStacked) then
			CharacterMicroButton:ClearAllPoints()
			CharacterMicroButton:SetPoint('TOPLEFT', UIParent,'TOPLEFT', 0, 25)
		end
	end)

	-- a new place for the exit vehicle button

	stancePadding = 0
	for i = 1,12 do
    
        --MAIN ACTIONBAR--
        setBackDrop("MultiBarLeftButton"..i.."Icon",'MultiBarLeft')
        setBackDrop("MultiBarRightButton"..i.."Icon",'MultiBarRight')
    
        setBackDrop("ActionButton"..i.."Icon",'MainMenuBar')
        setBackDrop("MultiBarBottomLeftButton"..i.."Icon",'MultiBarBottomLeft')
        setBackDrop("MultiBarBottomRightButton"..i.."Icon",'MultiBarBottomRight')
    
        setOverlay("ActionButton"..i.."Icon","ActionButton"..i)
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
    end
    
        _G["MultiBarBottomLeftButton" .. i .. "HotKey"]:ClearAllPoints()
        _G["MultiBarBottomRightButton" .. i .. "HotKey"]:ClearAllPoints()
    
        

        _G["MultiBarBottomLeftButton" .. i .. "HotKey"]:SetPoint('BOTTOM', _G["MultiBarBottomLeftButton" .. i ], 0, -4)
    
        _G["MultiBarBottomRightButton" .. i .. "HotKey"]:SetPoint('BOTTOM', _G["MultiBarBottomRightButton" .. i ], 0, -4)
   _G["MultiBarBottomRightButton" .. i .. "HotKey"] :SetJustifyH("CENTER")
    _G["MultiBarBottomLeftButton" .. i .. "HotKey"] :SetJustifyH("CENTER")
    
        _G["ActionButton" .. i .. "HotKey"]:ClearAllPoints()
        _G["ActionButton" .. i .. "HotKey"]:SetPoint('BOTTOM', _G["ActionButton" .. i ], 0, -10)
    
        _G["ActionButton" .. i .. "HotKey"]:SetJustifyH("CENTER")
    
    
         _G["hotKey" .. i .. "BG"], _G["hotKey" .. i .. "BGt"] = createBackground('BOTTOM',15,15,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbg",4)
        _G["hotKey" .. i .. "BG"]:ClearAllPoints();
        _G["hotKey" .. i .. "BG"]:SetFrameLevel(3)
        _G["hotKey" .. i .. "BG"]:SetFrameStrata("MEDIUM")
        _G["hotKey" .. i .. "BGt"]:SetVertexColor(0,0,0,1);
        _G["hotKey" .. i .. "BG"]:SetPoint('CENTER', _G["ActionButton" .. i .. "HotKey"], 'CENTER', 17,-2);
    
        
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
        
    if  _G["StanceButton"..i.."Icon"] then
        _G["StanceButton" .. i]:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
        _G["StanceButton" .. i]:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
        _G["StanceButton" .. i]:SetCheckedTexture('Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress')
     --   _G["StanceButton" .. i ]:SetNormalTexture(nil)
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
        
        
		
        end
        

    end
    


--[[	
	-- Hide the stance bar
	StanceBarFrame:SetScript("OnEvent", nil);
	RegisterStateDriver(StanceBarFrame, "visibility", "hide");
	StanceBarFrame:Hide()
--]]

	-----------------------------
	-- Right/Left Action Bar
	-----------------------------
	cfg.bars = {
		bar1 = { -- MulitBarRight
			buttonsize      = 36,
			buttonspacing   = 5,
			barscale        = 1,
			showonmouseover = false,
			userplaced      = true, --want to place the bar somewhere else?
			locked          = true, --frame locked
			pos             = { a1 = "RIGHT", a2 = "LEFT", af = "ObjectiveTrackerFrame", x = -25, y = 0 },
			testmode        = false,
		},
		bar2 = { -- MultiBarLeft
			buttonsize      = 36,
			buttonspacing   = 5,
			barscale        = 1,
			showonmouseover = false,
			userplaced      = true, --want to place the bar somewhere else?
			locked          = true, --frame locked
			pos             = { a1 = "LEFT", a2 = "LEFT", af = "rABS_MultiBarRight", x = -47, y = 0 },
			testmode        = false,
		},
	}
	
	-----------------------------
	-- CONFIG END
	-----------------------------
	
    -- disable the automatic frame position
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
			
		}) do
			UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
		end
	end
	
	-- hide unwanted objects
	for i = 2, 3 do
		for _, object in pairs({
			_G['ActionBarUpButton'],
			_G['ActionBarDownButton'],

			_G['MainMenuBarBackpackButton'],
			_G['KeyRingButton'],

			_G['CharacterBag0Slot'],
			_G['CharacterBag1Slot'],
			_G['CharacterBag2Slot'],
			_G['CharacterBag3Slot'],

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

	hooksecurefunc(_G['MainMenuXPBarDiv2'], 'Show', function(self)
		local divWidth = MainMenuExpBar:GetWidth() / 10
		local xpos = divWidth - 4.5

		for i = 2, 19, 2 do
			local texture = _G['MainMenuXPBarDiv'..i]
			local xalign = floor(xpos)
			texture:SetPoint('LEFT', xalign, 1)
			xpos = xpos + divWidth
		end
	end)

	_G['MainMenuXPBarDiv2']:Hide()

	local playername, _ = UnitName("player")
	local _, playerclass = UnitClass("player")

	cfg.playername = playername
	cfg.playerclass = playerclass

	--font
	cfg.font = "FONTS\\FRIZQT__.ttf"

	--how many pixels around a bar reserved for dragging?
	cfg.barinset = 10

	--backdrop settings
	cfg.backdrop = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "",
		tile = false,
		tileSize = 0,
		edgeSize = 0,
		insets = {
			left = -cfg.barinset,
			right = -cfg.barinset,
			top = -cfg.barinset,
			bottom = -cfg.barinset,
		},
	}


	-----------------------------
	-- HANDOVER
	-----------------------------

	--hand the config to the namespace for usage in other lua files (remember: those lua files must be called after the cfg.lua)
	ns.cfg = cfg
	
	-----------------------------
	-- Functions
	-----------------------------
	
	-----------------------------
	-- RightBar
	-----------------------------
	--get the config values
	local cfg = ns.cfg
	local barcfg = cfg.bars.bar1

	local bar = CreateFrame("Frame","rABS_MultiBarRight",UIParent, "SecureHandlerStateTemplate")
	bar:SetHeight(barcfg.buttonsize*12+barcfg.buttonspacing*11)
	bar:SetWidth(barcfg.buttonsize)
	bar:SetPoint(barcfg.pos.a1,barcfg.pos.af,barcfg.pos.a2,barcfg.pos.x,barcfg.pos.y)
	bar:SetHitRectInsets(-cfg.barinset, -cfg.barinset, -cfg.barinset, -cfg.barinset)

	if barcfg.testmode then
		bar:SetBackdrop(cfg.backdrop)
		bar:SetBackdropColor(1,0.8,1,0.6)
	end
	bar:SetScale(barcfg.barscale)

	
	MultiBarRight:SetParent(bar)

	for i=1, 12 do
		local button = _G["MultiBarRightButton"..i]
		button:ClearAllPoints()
		button:SetSize(barcfg.buttonsize, barcfg.buttonsize)
		if i == 1 then
			button:SetPoint("TOPLEFT", bar, 0,0)
		else
			local previous = _G["MultiBarRightButton"..i-1]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -barcfg.buttonspacing)
		end
	end

	if barcfg.showonmouseover then    
		local function lighton(alpha)
			if MultiBarRight:IsShown() then
				for i=1, 12 do
					local pb = _G["MultiBarRightButton"..i]
					pb:SetAlpha(alpha)
				end
			end
		end    
	bar:EnableMouse(true)
	bar:SetScript("OnEnter", function(self) lighton(1) end)
	bar:SetScript("OnLeave", function(self) lighton(0) end)  
		for i=1, 12 do
			local pb = _G["MultiBarRightButton"..i]
			pb:SetAlpha(0)
			pb:HookScript("OnEnter", function(self) lighton(1) end)
			pb:HookScript("OnLeave", function(self) lighton(0) end)
		end    
	end
	
	-----------------------------
	-- LeftBar
	-----------------------------
	--get the config values
	local cfg = ns.cfg
	local barcfg = cfg.bars.bar2

	local bar = CreateFrame("Frame","rABS_MultiBarLeft",UIParent, "SecureHandlerStateTemplate")
	bar:SetHeight(barcfg.buttonsize*12+barcfg.buttonspacing*11)
	bar:SetWidth(barcfg.buttonsize)
	bar:SetPoint(barcfg.pos.a1,barcfg.pos.af,barcfg.pos.a2,barcfg.pos.x,barcfg.pos.y)
	bar:SetHitRectInsets(-cfg.barinset, -cfg.barinset, -cfg.barinset, -cfg.barinset)

	if barcfg.testmode then
		bar:SetBackdrop(cfg.backdrop)
		bar:SetBackdropColor(1,0.8,1,0.6)
	end
	bar:SetScale(barcfg.barscale)



	MultiBarLeft:SetParent(bar)

	for i=1, 12 do
		local button = _G["MultiBarLeftButton"..i]
		button:ClearAllPoints()
		button:SetSize(barcfg.buttonsize, barcfg.buttonsize)
		if i == 1 then
			button:SetPoint("TOPLEFT", bar, 0,0)
		else
			local previous = _G["MultiBarLeftButton"..i-1]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -barcfg.buttonspacing)
		end
	end

	if barcfg.showonmouseover then    
		local function lighton(alpha)
			if MultiBarLeft:IsShown() then
				for i=1, 12 do
					local pb = _G["MultiBarLeftButton"..i]
					pb:SetAlpha(alpha)
				end
			end
		end    
		bar:EnableMouse(true)
		bar:SetScript("OnEnter", function(self) lighton(1) end)
		bar:SetScript("OnLeave", function(self) lighton(0) end)  
		for i=1, 12 do
			local pb = _G["MultiBarLeftButton"..i]
			pb:SetAlpha(0)
			pb:HookScript("OnEnter", function(self) lighton(1) end)
			pb:HookScript("OnLeave", function(self) lighton(0) end)
		end    
	end

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

MainMenuExpBar:SetScript("OnUpdate",function(self,event,addon)
    MainMenuExpBar:Hide()
end)

    MainMenuExpBar:RegisterEvent("PLAYER_ALIVE");
    




MainMenuMicroButton:SetScript("OnUpdate",function(self,event,addon)
    setMicroButtons();
end)

function setMicroButtons()
    MicroButtonPortrait:Hide()
    GuildMicroButtonTabard:Hide()
     MainMenuBarPerformanceBar:Hide()
    
     MICRO_BUTTONS = {
    "CharacterMicroButton",
    "SpellbookMicroButton",
    "TalentMicroButton",
    "AchievementMicroButton",
    "QuestLogMicroButton",
    "GuildMicroButton",
    "LFDMicroButton",
    "EJMicroButton",
    "CollectionsMicroButton",
    "MainMenuMicroButton",
    "HelpMicroButton",
    "StoreMicroButton",
    }
 for i=1, #MICRO_BUTTONS do
    if  _G[MICRO_BUTTONS[i]] then
        _G[MICRO_BUTTONS[i]]:SetDisabledTexture('Interface\\AddOns\\GW2_UI\\textures\\'..MICRO_BUTTONS[i]..'-Up'); 
        _G[MICRO_BUTTONS[i]]:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\'..MICRO_BUTTONS[i]..'-Up'); 
        _G[MICRO_BUTTONS[i]]:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\'..MICRO_BUTTONS[i]..'-Down'); 
        _G[MICRO_BUTTONS[i]]:SetWidth(32) 
        _G[MICRO_BUTTONS[i]]:SetHeight(64) 
            
            texture = _G[MICRO_BUTTONS[i]]:GetNormalTexture()
            texture:ClearAllPoints()
            texture:SetPoint('CENTER',_G[MICRO_BUTTONS[i]],'CENTER',0,-8)
            
            texture = _G[MICRO_BUTTONS[i]]:GetPushedTexture()
            texture:ClearAllPoints()
            texture:SetPoint('CENTER',_G[MICRO_BUTTONS[i]],'CENTER',0,-8)
            
            texture = _G[MICRO_BUTTONS[i]]:GetDisabledTexture()
            texture:ClearAllPoints()
            texture:SetPoint('CENTER',_G[MICRO_BUTTONS[i]],'CENTER',0,-8)
        _G[MICRO_BUTTONS[i]]:SetHighlightTexture(nil)
    end
end
    end

local f = CreateFrame('frame', nil, nil, 'SecureHandlerStateTemplate')
f:SetFrameRef('PetActionBarFrame', PetActionBarFrame)
f:SetFrameRef('MultiBarBottomLeft', MultiBarBottomLeft)
f:SetFrameRef('StanceBarFrame', StanceBarFrame)
f:SetAttribute('_onstate-combat', [=[ -- Securely toggle visibility in combat
    point, relativeTo, relativePoint, xOfs, yOfs = self:GetFrameRef('MultiBarBottomLeft'):GetPoint()

    if newstate == 'show' then
        self:GetFrameRef('PetActionBarFrame'):ClearAllPoints()
        self:GetFrameRef('StanceBarFrame'):ClearAllPoints()
        self:GetFrameRef('PetActionBarFrame'):SetPoint(point, relativeTo, relativePoint, xOfs, yOfs+151)
        if UnitExists('Pet') then
        self:GetFrameRef('StanceBarFrame'):SetPoint(point, relativeTo, relativePoint, xOfs, yOfs+195)
        else
            self:GetFrameRef('StanceBarFrame'):SetPoint(point, relativeTo, relativePoint, xOfs, yOfs+140)
        end
    else
        self:GetFrameRef('PetActionBarFrame'):ClearAllPoints()
        self:GetFrameRef('StanceBarFrame'):ClearAllPoints()
         self:GetFrameRef('PetActionBarFrame'):SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
        self:GetFrameRef('StanceBarFrame'):SetPoint(point, relativeTo, relativePoint, xOfs, yOfs+100)
    end
]=])
RegisterStateDriver(f, 'combat', '[combat] show; hide')
 

function setPetBar(bool)
    PetActionBarFrame.locked = nil;
    PetActionBarFrame:ClearAllPoints()
    PetActionButton1:ClearAllPoints()
    PetActionButton1:SetParent(PetActionBarFrame);
	PetActionBarFrame:SetScale(0.6)
	PetActionButton1:SetPoint('LEFT', PetActionBarFrame, 'LEFT', 0, 0)

     if bool then
        PetActionBarFrame:SetPoint('TOPLEFT', MultiBarBottomLeft, 'BOTTOMLEFT', 0, 190)
        if UnitExists('Pet') then
            StanceBarFrame:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'TOPLEFT', 0, 95)
        else
            StanceBarFrame:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'TOPLEFT', 0, 45)
        end
            
    else
        PetActionBarFrame:SetPoint('TOPLEFT', MultiBarBottomLeft, 'BOTTOMLEFT', 0, 60)
        if UnitExists('Pet') then
        StanceBarFrame:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'TOPLEFT', 0, -30)
            else
            StanceBarFrame:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'TOPLEFT', 0, -70)
        end
    end
    
end
setMicroButtons()



function setMoveableActionbars()
local frameMultiBarLeftdrageAbleFrame = CreateFrame("Frame","frameMultiBarLeftdrageAbleFrame",UIParent)
    frameMultiBarLeftdrageAbleFrame:SetWidth(rABS_MultiBarLeft:GetWidth())
    frameMultiBarLeftdrageAbleFrame:SetHeight(rABS_MultiBarLeft:GetHeight())
    frameMultiBarLeftdrageAbleFrame.texture = frameMultiBarLeftdrageAbleFrame:CreateTexture()

    frameMultiBarLeftdrageAbleFrame.texture:SetAllPoints(frameMultiBarLeftdrageAbleFrame)
    frameMultiBarLeftdrageAbleFrame.texture:SetTexture(1,0,0,0.5)
    frameMultiBarLeftdrageAbleFrame:SetPoint(GW2UI_SETTINGS['multibarleft_pos']['point'],GW2UI_SETTINGS['multibarleft_pos']['xOfs'],GW2UI_SETTINGS['multibarleft_pos']['yOfs'])
    frameMultiBarLeftdrageAbleFrame:SetFrameStrata('HIGH');

local frameMultiBarRightdrageAbleFrame = CreateFrame("Frame","frameMultiBarRightdrageAbleFrame",UIParent)
    frameMultiBarRightdrageAbleFrame:SetWidth(rABS_MultiBarLeft:GetWidth())
    frameMultiBarRightdrageAbleFrame:SetHeight(rABS_MultiBarLeft:GetHeight())
    frameMultiBarRightdrageAbleFrame.texture = frameMultiBarRightdrageAbleFrame:CreateTexture()

    frameMultiBarRightdrageAbleFrame.texture:SetAllPoints(frameMultiBarRightdrageAbleFrame)
    frameMultiBarRightdrageAbleFrame.texture:SetTexture(1,0,0,0.5)
    frameMultiBarRightdrageAbleFrame:SetPoint(GW2UI_SETTINGS['multibarright_pos']['point'],GW2UI_SETTINGS['multibarright_pos']['xOfs'],GW2UI_SETTINGS['multibarright_pos']['yOfs'])
    frameMultiBarRightdrageAbleFrame:SetFrameStrata('HIGH');

    rABS_MultiBarLeft:ClearAllPoints()
    rABS_MultiBarRight:ClearAllPoints()

    
    rABS_MultiBarLeft:SetPoint('CENTER',frameMultiBarLeftdrageAbleFrame,'CENTER',0,0)
    rABS_MultiBarRight:SetPoint('CENTER',frameMultiBarRightdrageAbleFrame,'CENTER',0,0)

    

    frameMultiBarLeftdrageAbleFrame:SetMovable(false)
    frameMultiBarLeftdrageAbleFrame:EnableMouse(false)

    frameMultiBarRightdrageAbleFrame:SetMovable(false)
    frameMultiBarRightdrageAbleFrame:EnableMouse(false)
    
    frameMultiBarLeftdrageAbleFrame:RegisterForDrag("LeftButton")
    frameMultiBarRightdrageAbleFrame:RegisterForDrag("LeftButton")

    frameMultiBarLeftdrageAbleFrame:SetScript("OnDragStart", frameMultiBarLeftdrageAbleFrame.StartMoving)

    frameMultiBarLeftdrageAbleFrame:SetScript("OnDragStop", function(self)
        frameMultiBarLeftdrageAbleFrame:StopMovingOrSizing()
            
        point, relativeTo, relativePoint, xOfs, yOfs = frameMultiBarLeftdrageAbleFrame:GetPoint()
            
        GW2UI_SETTINGS['multibarleft_pos']['point'] =point
        GW2UI_SETTINGS['multibarleft_pos']['relativePoint'] = relativePoint
        GW2UI_SETTINGS['multibarleft_pos']['xOfs'] = xOfs
        GW2UI_SETTINGS['multibarleft_pos']['yOfs']=  yOfs

    end)

    frameMultiBarRightdrageAbleFrame:SetScript("OnDragStart", frameMultiBarRightdrageAbleFrame.StartMoving)
    frameMultiBarRightdrageAbleFrame:SetScript("OnDragStop", function(self)
        frameMultiBarRightdrageAbleFrame:StopMovingOrSizing()
        point, relativeTo, relativePoint, xOfs, yOfs = frameMultiBarRightdrageAbleFrame:GetPoint()
        GW2UI_SETTINGS['multibarright_pos']['point'] =point
        GW2UI_SETTINGS['multibarright_pos']['relativePoint'] = relativePoint
        GW2UI_SETTINGS['multibarright_pos']['xOfs'] = xOfs
        GW2UI_SETTINGS['multibarright_pos']['yOfs']=  yOfs

    end)
        frameMultiBarRightdrageAbleFrame:Hide()
    frameMultiBarLeftdrageAbleFrame:Hide()
end

local actionBarsFrameLoad = CreateFrame('frame',nil,UIParent)

actionBarsFrameLoad:SetScript('OnUpdate',function()
    if GW2UI_SETTINGS['SETTINGS_LOADED'] == false then
                return
    end
  
    setMoveableActionbars()
    actionBarsFrameLoad:SetScript('OnUpdate',nil)
end)