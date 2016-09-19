powerBarAnimations = {}
powerBarAnimations['powerBarAnimation'] =1
powerBarAnimations['GwExtraPowerBar'] =1


healthGlobeAnimation = 1;
powerBarAnimation = 1;
petBarAnimation = 1;

local LastPlayerPowerType = 0

function create_pet_frame()
    
    local playerPetFrame = CreateFrame('Button', 'GwPlayerPetFrame',UIParent, 'GwPlayerPetFrame');
--    playerPetFrame:SetPoint('BOTTOMLEFT',_G['PetActionBarFrame'],'BOTTOMLEFT',0,0)
--    playerPetFrame:SetPoint('BOTTOMRIGHT',_G['PetActionBarFrame'],'BOTTOMRIGHT',0,0)
    
    gw_register_movable_frame('petframe',GwPlayerPetFrame,'pet_pos','GwPetFrameDummy')
    
     

    
    playerPetFrame:SetAttribute("*type1", 'target')
    playerPetFrame:SetAttribute("*type2", "togglemenu")
    playerPetFrame:SetAttribute("unit", 'pet')
    playerPetFrame:EnableMouse(true)
    playerPetFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    RegisterUnitWatch(playerPetFrame);
    
    _G['GwPlayerPetFrameHealth']:SetStatusBarColor(GW_COLOR_FRIENDLY[2].r,GW_COLOR_FRIENDLY[2].g,GW_COLOR_FRIENDLY[2].b);
    _G['GwPlayerPetFrameHealthString']:SetFont(UNIT_NAME_FONT,11)
    
    playerPetFrame:SetScript('OnEvent',function(self, event ,unit)
        update_pet_data(event,unit)    
    end)
    playerPetFrame:HookScript('OnShow',function()
         update_pet_data('UNIT_PET','player')
    end)
    
    playerPetFrame:RegisterEvent('UNIT_PET')
    playerPetFrame:RegisterEvent('UNIT_HEALTH')
    playerPetFrame:RegisterEvent('UNIT_HEALTH_MAX')
    
    --_G['GwPlayerPetFramePortrait']
    update_pet_data('UNIT_PET','player')
   
    GwPlayerPetFrame:ClearAllPoints()
    GwPlayerPetFrame:SetPoint(gwGetSetting('pet_pos')['point'],UIParent,gwGetSetting('pet_pos')['relativePoint'],gwGetSetting('pet_pos')['xOfs'],gwGetSetting('pet_pos')['yOfs'])
    
    
    CreateFrame('Button','GwDodgeBar',UIParemt,'GwDodgeBar')
    
    local ag = GwDodgeBar.spark:CreateAnimationGroup()    
    local anim = ag:CreateAnimation("Rotation")
    GwDodgeBar.spark.anim = anim
    ag:SetLooping("REPEAT")
    
    
    GwDodgeBar.animation = 0
    
        
    GwDodgeBar:SetScript('OnEvent', gw_dodgebar_onevent)
    
    GwDodgeBar:RegisterEvent('SPELL_UPDATE_COOLDOWN')
    GwDodgeBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    GwDodgeBar:RegisterEvent("CHARACTER_POINTS_CHANGED")
    GwDodgeBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    

    
    gw_dodgebar_onevent()
    
    
end

function create_power_bar()

    local playerPowerBar = CreateFrame('Frame', 'GwPlayerPowerBar',UIParent, 'GwPlayerPowerBar');
    
    
    playerPowerBar:SetScript('OnEvent',function(self,event,unit)
            if event=='UNIT_POWER' or event=='UNIT_MAX_POWER' and unit=='player' then
                update_power_data(GwPlayerPowerBar) 
                return
            end 
            if event=='UPDATE_SHAPESHIFT_FORM' then
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

    

    playerHealthGLobaBg:EnableMouse(true)
  --  RegisterUnitWatch(playerHealthGLobaBg);
    
    --DELETE ME AFTER ACTIONBARS REWORK
    playerHealthGLobaBg:SetAttribute("*type1", 'target')
    playerHealthGLobaBg:SetAttribute("*type2", "togglemenu")
    playerHealthGLobaBg:SetAttribute("unit", 'player')
    

    
    GwaddTOClique(playerHealthGLobaBg)
    
    
    
  --  RegisterUnitWatch(playerHealthGLobaBg)
    _G['GwPlayerHealthGlobeTextValue']:SetFont(DAMAGE_TEXT_FONT,16)
    _G['GwPlayerHealthGlobeTextValue']:SetShadowColor(1, 1, 1, 0) 

    
    for i = 1 , 8 do
       
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetFont(DAMAGE_TEXT_FONT,16)
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetShadowColor(1, 1, 1, 0) 
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetTextColor(0,0,0,1/i)
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
    local animation_duration = 0.2
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
     
       
 
    
    addToAnimation(forceAnimationName,powerBarAnimations[forceAnimationName],powerPrec,GetTime(),animation_duration,function()
            
                
    
                local snap = (animations[forceAnimationName]['progress']*100)/5

                local round_closest = 0.05 * snap
  
                local spark_min =  math.floor(snap)
                local spark_max =  math.ceil(snap) 
                local spark_current = snap

                local spark_prec = spark_current - spark_min
                
                            
                local spark = math.min( powerBarWidth - 15,math.floor(powerBarWidth*round_closest) - math.floor(15*spark_prec))
                local bI = 17 - math.max(1,intRound(16 * spark_prec))

                   _G[self:GetName()..'CandySpark']:SetTexCoord(bloodSpark[bI].left,
                        bloodSpark[bI].right,
                        bloodSpark[bI].top,
                        bloodSpark[bI].bottom)
             
           


           
            _G[self:GetName()..'Bar']:SetValue(round_closest)
            _G[self:GetName()..'Candy']:SetValue( 0 )
            _G[self:GetName()..'CandySpark']:ClearAllPoints()
            _G[self:GetName()..'CandySpark']:SetPoint('LEFT',spark,0)
            _G[self:GetName()..'BarString']:SetText(comma_value(powerMax*animations[forceAnimationName]['progress']))
            
            
        end)            
        powerBarAnimations[forceAnimationName] = powerPrec;
    
    
    

end

function gw_healthGlobe_FlashComplete()
    
    GwPlayerHealthGlobe.animating = true
    local lerpTo = 0
    
    if GwPlayerHealthGlobe.animationPrecentage==nil then
       GwPlayerHealthGlobe.animationPrecentage = 0 
    end
    
    if GwPlayerHealthGlobe.animationPrecentage<=0 then
        lerpTo = 0.4
    end
    
    addToAnimation('healthGlobeFlash',GwPlayerHealthGlobe.animationPrecentage,lerpTo,GetTime(),0.8,function()
            
            
            local l = animations['healthGlobeFlash']['progress']
             
            GwPlayerHealthGlobe.background:SetVertexColor(l,l,l)
           
                
    end,nil,function() 
                
        local health = UnitHealth('Player')
        local healthMax = UnitHealthMax('Player')
        local healthPrec = 0.00001
        if health>0 and healthMax>0 then
            healthPrec = health/healthMax
        end 
        if healthPrec<0.7 then
            
            GwPlayerHealthGlobe.animationPrecentage = lerpTo
                
            gw_healthGlobe_FlashComplete()
        else
            GwPlayerHealthGlobe.background:SetVertexColor(0,0,0)
            GwPlayerHealthGlobe.animating = false
        end
            
    end)
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
         absorbPrec =  math.min(math.max(0.0001,absorb/healthMax), 1)
    end

    if healthPrec<0.7 and (GwPlayerHealthGlobe.animating==false or GwPlayerHealthGlobe.animating==nil ) then
       
        
      gw_healthGlobe_FlashComplete()
        
    
    end
    
    GwPlayerHealthGlobe.stringUpdateTime = 0
     addToAnimation('healthGlobeAnimation',healthGlobeAnimation,healthPrec,GetTime(),0.2,function()
           
            local healthPrecCandy = math.min(1, animations['healthGlobeAnimation']['progress'] + 0.02)
           
            if GwPlayerHealthGlobe.stringUpdateTime<GetTime() then
            update_health_text(healthMax*animations['healthGlobeAnimation']['progress'])
                GwPlayerHealthGlobe.stringUpdateTime= GetTime() + 0.05
            end
            _G['GwPlayerHealthGlobeCandy']:SetHeight(healthPrecCandy*_G['GwPlayerHealthGlobeHealthBar']:GetWidth())
            _G['GwPlayerHealthGlobeCandyBar']:SetTexCoord(0,1,  math.abs(healthPrecCandy - 1),1)  
            
            _G['GwPlayerHealthGlobeHealth']:SetHeight(animations['healthGlobeAnimation']['progress']*_G['GwPlayerHealthGlobeHealthBar']:GetWidth())
            _G['GwPlayerHealthGlobeHealthBar']:SetTexCoord(0,1,  math.abs(animations['healthGlobeAnimation']['progress'] - 1),1) 
        end,nil,function() 
             update_health_text(health)
        end)            
        healthGlobeAnimation = healthPrec;

    
    _G['GwPlayerHealthGlobeAbsorb']:SetHeight(absorbPrec*_G['GwPlayerHealthGlobeHealthBar']:GetWidth())
    _G['GwPlayerHealthGlobeAbsorbBar']:SetTexCoord(0,1,  math.abs(absorbPrec - 1),1)  
    
end

function update_health_text(text)
    
    local v = comma_value(text)
    _G['GwPlayerHealthGlobeTextValue']:SetText(v)
    for i = 1 , 8 do
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetText(v)
    end
end



function gw_dodgebar_onevent(self,event,unit)
    
    local foundADash = false
  
    local __,__,c = UnitClass('Player')
        if GW_DODGEBAR_SPELLS[c]~=nil then
            for k,v in pairs(GW_DODGEBAR_SPELLS[c]) do
                local name = GetSpellInfo(v)
                if name~=nil then
                    charges, maxCharges, start, duration = GetSpellCharges(v)
                    foundADash = true
                    GwDodgeBar.spellId = v
                    if charges~=nil and charges<maxCharges then
                       gw_update_dodgebar(start,duration,maxCharges,charges)
                       
                    end
                end
            end
    end
    if foundADash==false then
        GwDodgeBar:Hide()
    else
       GwDodgeBar:Show() 
    end
    
end


function gw_update_dodgebar(start,duration,chargesMax,charges)
    

    
    if chargesMax>1 and chargesMax<3 then
        _G['GwDodgeBarSep1']:Show()
    else
        _G['GwDodgeBarSep1']:Hide()
    end
    
    if chargesMax>2 then
       _G['GwDodgeBarSep2']:SetRotation(0.55) 
       _G['GwDodgeBarSep3']:SetRotation(-0.55)
        
        _G['GwDodgeBarSep2']:Show() 
        _G['GwDodgeBarSep3']:Show() 
    else
        _G['GwDodgeBarSep2']:Hide() 
        _G['GwDodgeBarSep3']:Hide() 
    end

  --  GwDodgeBar.spark.anim:SetDegrees(63)
 --   GwDodgeBar.spark.anim:SetDuration(1)  
  --  GwDodgeBar.spark.anim:Play()

    

    addToAnimation('GwDodgeBar',0,1,start,duration,function()
            
        local p = animations['GwDodgeBar']['progress']
        local c = (charges + p) / chargesMax
        local t = lerp(1,-1,c) +1.4
        GwDodgeBar.fill:SetTexCoord(0,1*c,0,1)
        GwDodgeBar.fill:SetWidth(114*c)
            
        --[[local spark = GwDodgeBar.spark  
            value = c --values is between 0 and 1
            local radian =t
            spark:SetPoint("CENTER", 94 * math.cos(radian), 94 * math.sin(radian))
            spark:SetRotation(radian)  
        ]]--
      
                      
    
    end,'noease')
    GwDodgeBar.animation = 0
    
end