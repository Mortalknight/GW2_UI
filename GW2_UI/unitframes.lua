 PlayerFrame:SetScript("OnEvent", nil);
 PlayerFrame:Hide();



TargetFrame:SetScript("OnEvent", nil);
TargetFrame:Hide();

--FocusFrame:SetScript("OnEvent", nil);
--FocusFrame:Hide();

unitBGf,unitBGt = createBackground('BOTTOM',104,104,0,16,"Interface\\AddOns\\GW2_UI\\textures\\healthfill",1)
 unitBGt:SetVertexColor(0.1,0,0,1);

UIErrorsFrame:ClearAllPoints()
UIErrorsFrame:SetPoint('TOP',UIParent,'TOP',0,0)

   tprf,tprt = createBackground('BOTTOM',102,102,0,17,"Interface\\AddOns\\GW2_UI\\textures\\healthfill",3)
 --  tprt:SetVertexColor(159/255,36/255,20/255)
tprf:EnableMouse(false);

    healtTextureBg,healtTextureT = createBackground('BOTTOM',102,102,0,17,"Interface\\AddOns\\GW2_UI\\textures\\healthfillCandy",2)
    healtTextureT:SetVertexColor(255/255,84/255,0/255);
   


    absorb,absorbt = createBackground('BOTTOM',102,102,0,17,"Interface\\AddOns\\GW2_UI\\textures\\shieldfill",4)
    
    absorb:EnableMouse(false);absorb:SetHeight(0)
        absorbt:SetTexCoord(0,1,  0,1)


    local secureButtonFrame = CreateFrame("Button", "TargetButton", unitBGf, "SecureUnitButtonTemplate");
    secureButtonFrame:SetFrameStrata('HIGH')
    secureButtonFrame:SetSize(128,128)

    secureButtonFrame:SetPoint('BOTTOM',0,10)
    local t = secureButtonFrame:CreateTexture('Interface\\AddOns\\GW2_UI\\textures\\healthfill',"OVERLAY",2)
    t:SetTexture(texture)
    t:SetAllPoints(secureButtonFrame)
    secureButtonFrame.texture = t
    secureButtonFrame:Show()
    t:SetDrawLayer('OVERLAY',1)
    secureButtonFrame:SetAttribute("*type1", "target")
    secureButtonFrame:SetAttribute("*type2", "showmenu")
    secureButtonFrame:SetAttribute("unit", "player")
    secureButtonFrame:EnableMouse(true)
    secureButtonFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    RegisterUnitWatch(secureButtonFrame)
    

local healthFill = tprt
    local healthFillBg = tprf
    
    healthFill:SetPoint("BOTTOM",0,0)

    absorbt:SetPoint("BOTTOM",0,0)

    function createHealthBackDrop()
    
        for i = 1,8 do
            _G['hbackDrop'..i] = unitBGf:CreateFontString('hbackDrop'..i, "OVERLAY", "GameFontNormal")
            _G['hbackDrop'..i]:SetTextColor(78/255,0,0)
            _G['hbackDrop'..i]:SetFont(DAMAGE_TEXT_FONT,16)
            _G['hbackDrop'..i]:SetShadowColor(1, 1, 1, 0) 
            _G['hbackDrop'..i]:SetText("0")
        end
        _G['hbackDrop1']:SetPoint("CENTER",-1,0)
        _G['hbackDrop2']:SetPoint("CENTER",0,-1)
        _G['hbackDrop3']:SetPoint("CENTER",1,0)
        _G['hbackDrop4']:SetPoint("CENTER",0,1)
    
        _G['hbackDrop5']:SetPoint("CENTER",-2,0)
        _G['hbackDrop6']:SetPoint("CENTER",0,-2)
        _G['hbackDrop7']:SetPoint("CENTER",2,0)
        _G['hbackDrop8']:SetPoint("CENTER",0,2)
    
    end
    function setHealtNumber(s)
        for i = 1,8 do
            _G['hbackDrop'..i]:SetText(s)
        
        end
        unitframePlayerHealth:SetText(s)
    end

    createHealthBackDrop()
    local health = unitBGf:CreateFontString('unitframePlayerHealth', "OVERLAY", "GameFontNormal")
    unitBGf:EnableMouse(false);
    health:SetTextColor(1,1,1)
    health:SetFont(DAMAGE_TEXT_FONT,16)
    health:SetPoint("CENTER")
    health:SetShadowColor(1, 1, 1, 0) 
    health:SetText("0")
  

    secureButtonFrame:SetParent(unitBGf)

    
    unitframePowerbg,unitframePowerbgt = createBackground('TOPLEFT',315,18,0,0,"Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar",2,'unitframePowerbg')

    --unitframePowerbg:SetParent(ActionButton7)
    unitframePowerbg:SetScale(1)
    unitframePowerbg:ClearAllPoints()
    unitframePowerbgt:SetVertexColor(0,0,0,0.6);
    unitframePowerbg:SetPoint("BOTTOMLEFT",ActionButton7,"TOPLEFT",0,5)
    unitframePower = CreateFrame("StatusBar", nil, unitframePowerbg)
    unitframePower:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
    unitframePower:GetStatusBarTexture():SetHorizTile(false)
    unitframePower:SetMinMaxValues(0, 100)
    unitframePower:SetValue(0)
    unitframePower:SetWidth(313)
    unitframePower:SetHeight(16)
    unitframePower:SetPoint("TOPLEFT",unitframePowerbg,"TOPLEFT",1,-1)

    unitframePowerCandy = CreateFrame("StatusBar", nil, unitframePowerbg)
    unitframePowerCandy:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbarcandy")
    unitframePowerCandy:GetStatusBarTexture():SetHorizTile(false)
    unitframePowerCandy:SetMinMaxValues(0, 100)
    unitframePowerCandy:SetValue(0)
    unitframePowerCandy:SetWidth(313)
    unitframePowerCandy:SetHeight(16)
    unitframePowerCandy:SetPoint("TOPLEFT",unitframePowerbg,"TOPLEFT",1,-1)

    


    local unitframePowerText = unitframePower:CreateFontString('unitframePlayerPower', "OVERLAY", "GameFontNormal")
    unitframePowerText:SetTextColor(1,1,1)
    unitframePowerText:SetFont(STANDARD_TEXT_FONT,14)
    unitframePowerText:SetPoint("CENTER")
    unitframePowerText:SetText("0")
 
    
    

powerBeforeLerp =  (UnitPower('Player')/UnitPowerMax('Player')) * 100
unitframePower:SetScript("OnEvent",function(self,event,unit)
      
          if event~='PLAYER_ENTERING_WORLD' then
            if unit ~='player' then
                return
            end
        end
    powerType, powerToken, altR, altG, altB = UnitPowerType("player")
    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        unitframePower:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
        unitframePowerCandy:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end
   
    local prog = (UnitPower('Player')/UnitPowerMax('Player')) * 100
        
     addToAnimation('unitFramePowerBar',powerBeforeLerp,prog,GetTime(),0.2,function()
       unitframePower:SetValue(animations['unitFramePowerBar']['progress'])
    end)
    addToAnimation('unitFramePowerBarCandy',powerBeforeLerp,prog,GetTime(),0.25,function()
       unitframePowerCandy:SetValue(animations['unitFramePowerBarCandy']['progress'])
    end)
       
    powerBeforeLerp = prog
    local num = UnitPower('player')
    local uhm = UnitPower('Player')/UnitPowerMax('Player')
    if not num then return 0 end
    if abs(num) > 10000 then 
    
    local neg = num < 0 and "-" or ""
    local left, mid, right = tostring(abs(num)):match("^([^%d]*%d)(%d*)(.-)$")
    unitframePowerText:SetText(("%s%s%s%s"):format(neg, left, mid:reverse():gsub("(%d%d%d)", "%1,"):reverse(), right))
    else
        unitframePowerText:SetText(num)
    end
        
end)
healthBefore = UnitHealth('Player') / UnitHealthMax('Player')
normalHealthBefore = healthBefore

unitBGf:SetScript("OnEvent",function(self,event,unit)
        if event~='PLAYER_ENTERING_WORLD' then
            if unit ~='player' then
                return
            end
        end
    local num = UnitHealth('player')
    local uhm = UnitHealth('Player')/UnitHealthMax('Player')
    local totalAbsorb =  UnitGetTotalAbsorbs("Player")
    if totalAbsorb > UnitHealthMax('Player') then
            totalAbsorb = UnitHealthMax('Player')
    end
    if totalAbsorb <= 0 then
            totalAbsorb = 1
    end
    local auhm = totalAbsorb/UnitHealthMax('Player')    
        
    
    
    addToAnimation('unitFrameHealth',healthBefore, uhm + 0.03,GetTime(),0.2,function()
        animations['unitFrameHealth']['progress'] = min(1,max(animations['unitFrameHealth']['progress'],0.01))
        if isnan(animations['unitFrameHealth']['progress'])==false then
                    
            healtTextureBg:SetHeight(animations['unitFrameHealth']['progress']*healtTextureBg:GetWidth())
            healtTextureT:SetTexCoord(0,1,  math.abs(animations['unitFrameHealth']['progress'] - 1),1)  
                    
        end
    end) 
    healthBefore = uhm + 0.03
    addToAnimation('unitFrameHealthNormal',normalHealthBefore, uhm,GetTime(),0.1,function()
        animations['unitFrameHealthNormal']['progress'] = min(1,max(animations['unitFrameHealthNormal']['progress'],0.01))
        if isnan(animations['unitFrameHealthNormal']['progress'])==false then

            healthFillBg:SetHeight(animations['unitFrameHealthNormal']['progress']*healthFill:GetWidth())
            healthFill:SetTexCoord(0,1,  math.abs(animations['unitFrameHealthNormal']['progress'] - 1),1)
                    
                    
        end
    end)  
    normalHealthBefore = uhm 
    
       
        
     
        absorb:SetHeight(auhm*absorb:GetWidth())
        absorbt:SetTexCoord(0,1,  math.abs(auhm - 1),1)
        
    if not num then return 0 end
    if abs(num) > 10000 then
    
    local neg = num < 0 and "-" or ""
    local left, mid, right = tostring(abs(num)):match("^([^%d]*%d)(%d*)(.-)$")
        setHealtNumber(("%s%s%s%s"):format(neg, left, mid:reverse():gsub("(%d%d%d)", "%1,"):reverse(), right))
    else
            setHealtNumber(num)
    end
        
        
    
        
        
end)




    
   



secureButtonFrame:SetScript('OnMouseDown', function(self,button)
	
        if button=='RightButton' then
		ToggleDropDownMenu(1, nil, PlayerFrameDropDown, unitBGf, 0, 0)
        end
            
	
end)

unitBGf:RegisterEvent("UNIT_HEALTH");
unitBGf:RegisterEvent("UNIT_MAX_HEALTH");
unitBGf:RegisterEvent("PLAYER_ENTERING_WORLD");

unitBGf:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")


unitframePower:RegisterEvent("UNIT_POWER");
unitframePower:RegisterEvent("UNIT_MAX_POWER");
unitframePower:RegisterEvent("PLAYER_ENTERING_WORLD");



