powerBarAnimations = {}
powerBarAnimations['powerBarAnimation'] =1
powerBarAnimations['GwExtraPowerBar'] =1


healthGlobeAnimation = 1;
powerBarAnimation = 1;
petBarAnimation = 1;

function create_pet_frame()
    
    local playerPetFrame = CreateFrame('Button', 'GwPlayerPetFrame',UIParent, 'GwPlayerPetFrame');
--    playerPetFrame:SetPoint('BOTTOMLEFT',_G['PetActionBarFrame'],'BOTTOMLEFT',0,0)
--    playerPetFrame:SetPoint('BOTTOMRIGHT',_G['PetActionBarFrame'],'BOTTOMRIGHT',0,0)
    
     playerPetFrame:SetPoint('CENTER',0,0)
    
    playerPetFrame:SetAttribute("*type1", 'target')
    playerPetFrame:SetAttribute("*type2", "showmenu")
    playerPetFrame:SetAttribute("unit", 'pet')
    playerPetFrame:EnableMouse(true)
    RegisterUnitWatch(playerPetFrame);
    
    _G['GwPlayerPetFrameHealth']:SetStatusBarColor(GW_COLOR_FRIENDLY[2].r,GW_COLOR_FRIENDLY[2].g,GW_COLOR_FRIENDLY[2].b);
    _G['GwPlayerPetFrameHealthString']:SetFont(UNIT_NAME_FONT,11)
    
    playerPetFrame:SetScript('OnEvent',function(self, event ,unit)
        update_pet_data(event,unit)    
    end)
    playerPetFrame:SetScript('OnShow',function()
         update_pet_data('UNIT_PET','player')
    end)
    
    playerPetFrame:SetScript('OnMouseDown', function(self,button)
            if button=='RightButton' then
                ToggleDropDownMenu(1, nil, PetFrameDropDown, playerPetFrame, 0, 0)
            end	
    end)    
    
    playerPetFrame:RegisterEvent('UNIT_PET')
    playerPetFrame:RegisterEvent('UNIT_HEALTH')
    playerPetFrame:RegisterEvent('UNIT_HEALTH_MAX')
    
    --_G['GwPlayerPetFramePortrait']
    update_pet_data('UNIT_PET','player')
    

end

function create_power_bar()

    local playerPowerBar = CreateFrame('Frame', 'GwPlayerPowerBar',UIParent, 'GwPlayerPowerBar');
    
    
    playerPowerBar:SetScript('OnEvent',function(self,event,unit)
            if unit=='player' then
                update_power_data(GwPlayerPowerBar) 
            end
    end)
    
    _G['GwPlayerPowerBarBarString']:SetFont(DAMAGE_TEXT_FONT,14)

    playerPowerBar:RegisterEvent("UNIT_POWER");
    playerPowerBar:RegisterEvent("UNIT_MAX_POWER");
    playerPowerBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
    playerPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD");
    
    update_power_data(GwPlayerPowerBar)

end

function create_player_hud()
    
    PlayerFrame:SetScript("OnEvent", nil);
    PlayerFrame:Hide();


    local playerHealthGLobaBg = CreateFrame('Button', 'GwPlayerHealthGlobe',UIParent, 'GwPlayerHealthGlobe');


    playerHealthGLobaBg:SetAttribute("*type1", 'target')
    playerHealthGLobaBg:SetAttribute("*type2", "showmenu")
    playerHealthGLobaBg:SetAttribute("unit", 'player')
    playerHealthGLobaBg:EnableMouse(true)
    RegisterUnitWatch(playerHealthGLobaBg);
    
    playerHealthGLobaBg:SetScript('OnMouseDown', function(self,button)
            if button=='RightButton' then
                ToggleDropDownMenu(1, nil, PlayerFrameDropDown, playerHealthGLobaBg, 0, 0)
            end       
    end)
    
    
    
    RegisterUnitWatch(playerHealthGLobaBg)
    _G['GwPlayerHealthGlobeTextValue']:SetFont(DAMAGE_TEXT_FONT,16)
    _G['GwPlayerHealthGlobeTextValue']:SetShadowColor(1, 1, 1, 0) 

    
    for i = 1 , 8 do
       
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetFont(DAMAGE_TEXT_FONT,16)
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetShadowColor(1, 1, 1, 0) 
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetTextColor(78/255,0,0,1/i)
    end
    _G['GwPlayerHealthGlobeTextShadow1']:SetPoint("CENTER",-1,0)
    _G['GwPlayerHealthGlobeTextShadow2']:SetPoint("CENTER",0,-1)
    _G['GwPlayerHealthGlobeTextShadow3']:SetPoint("CENTER",1,0)
    _G['GwPlayerHealthGlobeTextShadow4']:SetPoint("CENTER",0,1)
    
    _G['GwPlayerHealthGlobeTextShadow5']:SetPoint("CENTER",-2,0)
    _G['GwPlayerHealthGlobeTextShadow6']:SetPoint("CENTER",0,-2)
    _G['GwPlayerHealthGlobeTextShadow7']:SetPoint("CENTER",2,0)
    _G['GwPlayerHealthGlobeTextShadow8']:SetPoint("CENTER",0,2)
    
    
    playerHealthGLobaBg:SetScript('OnEvent',function(self,event,unit)
            if unit=='player' then
                update_health_data() 
            end
    end)

    playerHealthGLobaBg:RegisterEvent("UNIT_HEALTH");
    playerHealthGLobaBg:RegisterEvent("UNIT_MAX_HEALTH");
    playerHealthGLobaBg:RegisterEvent("PLAYER_ENTERING_WORLD");
    playerHealthGLobaBg:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    
    update_health_data()
    
end

function update_pet_data(event, unit)
    
    if UnitExists('pet')==false then
        return
    end
    
    local health = UnitHealth('pet')
    local healthMax = UnitHealthMax('pet')
    local healthprec =0
    
    if health>0 and healthMax>0 then
         healthprec = health/healthMax
    end
    
   
       SetPortraitTexture(_G['GwPlayerPetFramePortrait'],'pet')
    
    
        addToAnimation('petBarAnimation',petBarAnimation,healthprec,GetTime(),0.2,function()
                _G['GwPlayerPetFrameHealth']:SetValue(animations['petBarAnimation']['progress'])
        end)
        petBarAnimation = healthprec
        _G['GwPlayerPetFrameHealthString']:SetText(comma_value(health))
  
   
  
    

    
end

function update_power_data(self,forcePowerType,powerToken,forceAnimationName)
    
    if forcePowerType==nil then
        forcePowerType, powerToken, altR, altG, altB = UnitPowerType("player")
        forceAnimationName = 'powerBarAnimation'
    end

    local power = UnitPower('Player',forcePowerType)
    local powerMax = UnitPowerMax('Player',forcePowerType)
    local powerPrec = 0
    local powerBarWidth = _G[self:GetName()..'Bar']:GetWidth()
    
     if power>0 and powerMax>0 then
         powerPrec = power/powerMax
    end
    
   
    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        _G[self:GetName()..'Bar']:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
        _G[self:GetName()..'CandySpark']:SetVertexColor(pwcolor.r, pwcolor.g, pwcolor.b)
        _G[self:GetName()..'Candy']:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end
    
    addToAnimation(forceAnimationName,powerBarAnimations[forceAnimationName],powerPrec,GetTime(),0.2,function()
            
            
 
                local  round_closest = 0.05 * math.floor((animations[forceAnimationName]['progress']*100)/5) 
                local spark_min =  math.floor((animations[forceAnimationName]['progress']*100)/5)
                local spark_max =  math.ceil((animations[forceAnimationName]['progress']*100)/5) 
                local spark_current = (animations[forceAnimationName]['progress']*100)/5
                local spark_prec = spark_current - spark_min
                local spark = math.min(powerBarWidth-15,(powerBarWidth*round_closest)-2)
                    local bI = 17 - math.max(1,math.ceil(16 * spark_prec))
                   _G[self:GetName()..'CandySpark']:SetTexCoord(bloodSpark[bI].left,
                        bloodSpark[bI].right,
                        bloodSpark[bI].top,
                        bloodSpark[bI].bottom)
                _G[self:GetName()..'CandySpark']:ClearAllPoints()
                _G[self:GetName()..'CandySpark']:SetPoint('LEFT',math.floor(spark),0)
           
            
            local candy = lerp(animations[forceAnimationName]['from'],animations[forceAnimationName]['to'],(GetTime() - animations[forceAnimationName]['start'])/animations[forceAnimationName]['duration'])
            local sparkPosition = (316*animations[forceAnimationName]['progress'])-18

            
            _G[self:GetName()..'Bar']:SetValue(round_closest)
            _G[self:GetName()..'Candy']:SetValue( 0 )
            _G[self:GetName()..'BarString']:SetText(comma_value(powerMax*animations[forceAnimationName]['progress']))
            
            
        end)            
    powerBarAnimations[forceAnimationName] = powerPrec;
    
    
    

end

function update_health_data()   
    
    local health = UnitHealth('Player')
    local healthMax = UnitHealthMax('Player')
    local healthPrec = 0.00001
    local absorb = UnitGetTotalAbsorbs('Player')
    
    local absorbPrec =  0.00001
    
    
    if health>0 and healthMax>0 then
         healthPrec = math.max(0.0001,health/healthMax)
    end
    
    if absorb>0 and healthMax>0 then
         absorbPrec =  math.max(0.0001,absorb/healthMax)
    end

    

    
     addToAnimation('healthGlobeAnimation',healthGlobeAnimation,healthPrec,GetTime(),0.2,function()
           
            local healthPrecCandy = math.min(1, animations['healthGlobeAnimation']['progress'] + 0.02)
           
            update_health_text(healthMax*animations['healthGlobeAnimation']['progress'])
            _G['GwPlayerHealthGlobeCandy']:SetHeight(healthPrecCandy*_G['GwPlayerHealthGlobeHealthBar']:GetWidth())
            _G['GwPlayerHealthGlobeCandyBar']:SetTexCoord(0,1,  math.abs(healthPrecCandy - 1),1)  
            
            _G['GwPlayerHealthGlobeHealth']:SetHeight(animations['healthGlobeAnimation']['progress']*_G['GwPlayerHealthGlobeHealthBar']:GetWidth())
            _G['GwPlayerHealthGlobeHealthBar']:SetTexCoord(0,1,  math.abs(animations['healthGlobeAnimation']['progress'] - 1),1) 
        end)            
        healthGlobeAnimation = healthPrec;

    
    _G['GwPlayerHealthGlobeAbsorb']:SetHeight(absorbPrec*_G['GwPlayerHealthGlobeHealthBar']:GetWidth())
    _G['GwPlayerHealthGlobeAbsorbBar']:SetTexCoord(0,1,  math.abs(absorbPrec - 1),1)  
    
end

function update_health_text(text)
    
    _G['GwPlayerHealthGlobeTextValue']:SetText(comma_value(text))
    for i = 1 , 8 do
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetText(comma_value(text))
    end
end
