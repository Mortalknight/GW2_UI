local LastPlayerPowerType = 0


local function updateBuffLayout(self,event)
    

    
    local minIndex = 1
    local maxIndex = 80
    
    if self.displayBuffs~=true then
        minIndex = 40
    end
    if self.displayDebuffs~=true then
        maxIndex = 40
    end
    
    local marginX = 3
    local marginY = 20
    
    
    local usedWidth = 0
    local usedHeight = 0
    
    local smallSize = 20
    local bigSize = 28
    local lineSize = smallSize
    local maxSize = self.auras:GetWidth()
    
    local auraList = {}
    local debuffList = {}
    
    auraList = gw_get_buffs(self.unit)
    debuffList = gw_get_debuffs(self.unit,self.debuffFilter)
    
    local saveAuras = {}
    
    saveAuras['buff'] = {}
    saveAuras['debuff'] = {}
  
    for frameIndex=minIndex,maxIndex do
        
        local index = frameIndex
        local list = auraList
        local newAura = true
          
        if frameIndex>40 then index = frameIndex - 40 end
        
        local frame = _G['Gw'..self.unit..'buffFrame'..index]
        
        if frameIndex>40 then
            frame = _G['Gw'..self.unit..'debuffFrame'..index]
            list = debuffList
        end
        
        if frameIndex==41 then
            usedWidth = 0
            usedHeight = usedHeight + lineSize + marginY
            lineSize = smallSize 
        end
        

        
        if gw_set_buffData(frame,list,index) then

            if not frame:IsShown() then frame:Show() end

            local isBig = frame.typeAura=='bigBuff'

            local size = smallSize
            if isBig then
                size = bigSize
                lineSize = bigSize
               
                for k,v in pairs(self.saveAuras[frame.auraType]) do
                    if v==list[index]['name'] then
                       newAura = false
                    end
                end
                self.animating =false
                saveAuras[frame.auraType][ #saveAuras[frame.auraType]+1] = list[index]['name']
            end
            frame:SetPoint('CENTER', self.auras,'BOTTOMRIGHT',-(usedWidth + (size/2)),usedHeight + (size/2) )
            frame:SetSize(size,size)
            if newAura  and isBig and event=='UNIT_AURA' then 
                gw_aura_animate_in(frame)
            end

            usedWidth = usedWidth + size + marginX
            if maxSize<usedWidth then
                usedWidth = 0
                usedHeight = usedHeight + lineSize + marginY
                lineSize = smallSize
            
            end 
        else
            if frame:IsShown() then
                frame:Hide()
            end
        end
    end
    
    self.saveAuras = saveAuras
    
end

local function loadAuras(self)
    for i=1,40 do
       local frame =  CreateFrame('Button','Gw'..self.unit..'buffFrame'..i,self.auras,'GwAuraFrame')
        frame.unit = self.unit
        frame.auraType = 'buff'
        frame = CreateFrame('Button','Gw'..self.unit..'debuffFrame'..i,self.auras,'GwAuraFrame')
        frame.unit = self.unit
        frame.auraType = 'debuff'
       
    end
   self.saveAuras = {}
   self.saveAuras['buff'] = {}
   self.saveAuras['debuff'] = {}
end

local function updatePetFrameLocation()
    if InCombatLockdown() or not GwPlayerPetFrame then
        return
    end
    GwPlayerPetFrame:ClearAllPoints()
    if MultiBarBottomLeft.gw_FadeShowing then
        GwPlayerPetFrame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOM', -53, 212)
    else
        GwPlayerPetFrame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOM', -53, 120)
    end
end
function gw_updatePetFrameLocation()
    -- when PETBAR_LOCKED is set, this empty function is replaced by updatePetFrameLocation during init
end

function gw_create_pet_frame()
    local playerPetFrame = CreateFrame('Button', 'GwPlayerPetFrame', UIParent, 'GwPlayerPetFrame');
    
    gw_register_movable_frame('petframe', GwPlayerPetFrame, 'pet_pos', 'GwPetFrameDummy', 'PETBAR_LOCKED')
    
    playerPetFrame:SetAttribute("*type1", 'target')
    playerPetFrame:SetAttribute("*type2", "togglemenu")
    playerPetFrame:SetAttribute("unit", 'pet')
    playerPetFrame:EnableMouse(true)
    playerPetFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    RegisterUnitWatch(playerPetFrame)
    
    _G['GwPlayerPetFrameHealth']:SetStatusBarColor(GW_COLOR_FRIENDLY[2].r, GW_COLOR_FRIENDLY[2].g, GW_COLOR_FRIENDLY[2].b)
    _G['GwPlayerPetFrameHealthString']:SetFont(UNIT_NAME_FONT, 11)
    
    playerPetFrame:SetScript('OnEvent', function(self, event ,unit)
        gw_update_pet_data(event, unit)
    end)
    playerPetFrame:HookScript('OnShow', function()
        gw_update_pet_data('UNIT_PET', 'player')
    end)
    playerPetFrame.unit = 'pet'
    
    playerPetFrame.displayBuffs = true
    playerPetFrame.displayDebuffs = true
    playerPetFrame.debuffFilter = 'player'
    
    loadAuras(playerPetFrame)
    
    playerPetFrame:RegisterEvent('UNIT_PET')
    playerPetFrame:RegisterEvent('UNIT_POWER')
    playerPetFrame:RegisterEvent('UNIT_MAXPOWER')
    playerPetFrame:RegisterEvent('UNIT_HEALTH')
    playerPetFrame:RegisterEvent('UNIT_MAXHEALTH')
    playerPetFrame:RegisterEvent('UNIT_AURA')
    
    --_G['GwPlayerPetFramePortrait']
    gw_update_pet_data('UNIT_PET','player')
    
    if gwGetSetting('PETBAR_LOCKED') == true then
        GwPlayerPetFrame:ClearAllPoints()
        GwPlayerPetFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOM', -372, 86)
        playerPetFrame:SetFrameRef('GwPlayerPetFrame', GwPlayerPetFrame)
        playerPetFrame:SetFrameRef('UIParent', UIParent)
        playerPetFrame:SetFrameRef('MultiBarBottomLeft', MultiBarBottomLeft)
        playerPetFrame:SetAttribute('_onstate-combat', [=[
            if self:GetFrameRef('MultiBarBottomLeft'):IsShown()==false then
                return
            end
        
            self:GetFrameRef('GwPlayerPetFrame'):ClearAllPoints()
            if newstate == 'show' then
                self:GetFrameRef('GwPlayerPetFrame'):SetPoint('BOTTOMRIGHT',self:GetFrameRef('UIParent'),'BOTTOM',-53,212)
            end
        ]=])
        RegisterStateDriver(playerPetFrame, 'combat', '[combat] show; hide')
        gw_updatePetFrameLocation = updatePetFrameLocation
        gwActionBar_AddStateCallback(gw_updatePetFrameLocation)
        gw_updatePetFrameLocation()
        return
    end
    
    GwPlayerPetFrame:ClearAllPoints()
    GwPlayerPetFrame:SetPoint(gwGetSetting('pet_pos')['point'], UIParent, gwGetSetting('pet_pos') ['relativePoint'],gwGetSetting('pet_pos')['xOfs'], gwGetSetting('pet_pos')['yOfs'])

    -- show/hide stuff with override bar
    OverrideActionBar:HookScript('OnHide', function()
        playerPetFrame:SetAlpha(1)
    end)
end

function gw_create_power_bar()

    local playerPowerBar = CreateFrame('Frame', 'GwPlayerPowerBar',UIParent, 'GwPlayerPowerBar');
    
    _G[playerPowerBar:GetName()..'CandySpark']:ClearAllPoints()
    
    playerPowerBar:SetScript('OnEvent',function(self,event,unit)
            if (event=='UNIT_POWER' or event=='UNIT_MAXPOWER') and unit=='player' then
                gw_update_power_data(GwPlayerPowerBar) 
                return
            end 
            if event=='UPDATE_SHAPESHIFT_FORM' or event=='ACTIVE_TALENT_GROUP_CHANGED' then
                GwPlayerPowerBar.lastPowerType = nil
                gw_update_power_data(GwPlayerPowerBar) 
            end
    end)
    
    _G['GwPlayerPowerBarBarString']:SetFont(DAMAGE_TEXT_FONT,14)

    playerPowerBar:RegisterEvent("UNIT_POWER");
    playerPowerBar:RegisterEvent("UNIT_MAXPOWER");
    playerPowerBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
    playerPowerBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
    playerPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD");
    
    gw_update_power_data(GwPlayerPowerBar)

    -- show/hide stuff with override bar
    OverrideActionBar:HookScript('OnShow', function()
        playerPowerBar:SetAlpha(0)
    end)
    OverrideActionBar:HookScript('OnHide', function()
        playerPowerBar:SetAlpha(1)
    end)
end


function gw_powerbar_updateRegen(self)
    if self.lostKnownPower==nil or self.powerMax==nil or self.lastUpdate==nil or self.animating==true then return end
    if self.lostKnownPower>=self.powerMax then return end
    if self.textUpdate==nil then self.textUpdate = 0 end
    
   local decayRate = 1
   local inactiveRegen, activeRegen = GetPowerRegen()
    
    local regen = inactiveRegen
    
    if InCombatLockdown() then
        regen = activeRegen
    end
 
    local addPower = regen * ((GetTime() - self.lastUpdate)/decayRate)
    
    local power = self.lostKnownPower + addPower
    local powerMax = self.powerMax
    local powerPrec = 0
    local powerBarWidth = self.powerBarWidth
    
     if power>0 and powerMax>0 then
         powerPrec = math.min(1,power/powerMax)
    end
    
    
   
    
    local bit = powerBarWidth/15        
    local spark = bit * math.floor(15 * (powerPrec))
    
    local spark_current = (bit * (15 * (powerPrec)) - spark) / bit 
    local round_closest = (spark/powerBarWidth)
            
            
    local bI = math.min(16,math.max(1,math.floor(17 - (16*spark_current))))
         
    self.powerCandySpark:SetTexCoord(bloodSpark[bI].left,bloodSpark[bI].right,bloodSpark[bI].top,bloodSpark[bI].bottom)         self.powerCandySpark:SetPoint('LEFT',self.bar,'RIGHT',-2,0)
    self.bar:SetPoint('RIGHT',self,'LEFT',spark,0)
    self.powerBar:SetValue(0)
    self.powerCandy:SetValue( 0 )

    if self.textUpdate<GetTime() then
        self.powerBarString:SetText(comma_value(powerMax*powerPrec))
        self.textUpdate = GetTime() + 0.2
    end
            
    self.animationCurrent = powerPrec;
    
end

function gw_create_player_hud()
    
    PlayerFrame:SetScript("OnEvent", nil);
    PlayerFrame:Hide();


    local playerHealthGLobaBg = CreateFrame('Button', 'GwPlayerHealthGlobe',UIParent, 'GwPlayerHealthGlobe');
    GwPlayerHealthGlobe.animationCurrent = 0
    

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
    
    _G['GwPlayerAbsorbGlobeTextValue']:SetFont(DAMAGE_TEXT_FONT,16)
    _G['GwPlayerAbsorbGlobeTextValue']:SetShadowColor(1, 1, 1, 0) 

    
    for i = 1 , 8 do
       
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetFont(DAMAGE_TEXT_FONT,16)
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetShadowColor(1, 1, 1, 0) 
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetTextColor(0,0,0,1/i)     
        
        _G['GwPlayerAbsorbGlobeTextShadow'..i]:SetFont(DAMAGE_TEXT_FONT,16)
        _G['GwPlayerAbsorbGlobeTextShadow'..i]:SetShadowColor(1, 1, 1, 0) 
        _G['GwPlayerAbsorbGlobeTextShadow'..i]:SetTextColor(0,0,0,1/i)
    end
    _G['GwPlayerHealthGlobeTextShadow1']:SetPoint("CENTER",-1,0)
    _G['GwPlayerHealthGlobeTextShadow2']:SetPoint("CENTER",0,-1)
    _G['GwPlayerHealthGlobeTextShadow3']:SetPoint("CENTER",1,0)
    _G['GwPlayerHealthGlobeTextShadow4']:SetPoint("CENTER",0,1)
    _G['GwPlayerHealthGlobeTextShadow5']:SetPoint("CENTER",-2,0)
    _G['GwPlayerHealthGlobeTextShadow6']:SetPoint("CENTER",0,-2)
    _G['GwPlayerHealthGlobeTextShadow7']:SetPoint("CENTER",2,0)
    _G['GwPlayerHealthGlobeTextShadow8']:SetPoint("CENTER",0,2)  
    
    _G['GwPlayerAbsorbGlobeTextShadow1']:SetPoint("CENTER",-1,0)
    _G['GwPlayerAbsorbGlobeTextShadow2']:SetPoint("CENTER",0,-1)
    _G['GwPlayerAbsorbGlobeTextShadow3']:SetPoint("CENTER",1,0)
    _G['GwPlayerAbsorbGlobeTextShadow4']:SetPoint("CENTER",0,1)
    _G['GwPlayerAbsorbGlobeTextShadow5']:SetPoint("CENTER",-2,0)
    _G['GwPlayerAbsorbGlobeTextShadow6']:SetPoint("CENTER",0,-2)
    _G['GwPlayerAbsorbGlobeTextShadow7']:SetPoint("CENTER",2,0)
    _G['GwPlayerAbsorbGlobeTextShadow8']:SetPoint("CENTER",0,2)
    
    
    playerHealthGLobaBg:SetScript('OnEvent',function(self,event,unit)
            if unit=='player' then
                gw_update_health_data() 
            end
    end)

    playerHealthGLobaBg:RegisterEvent("UNIT_HEALTH");
    playerHealthGLobaBg:RegisterEvent("UNIT_MAXHEALTH");
    playerHealthGLobaBg:RegisterEvent("PLAYER_ENTERING_WORLD");
    playerHealthGLobaBg:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    
    gw_update_health_data()
	
	
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
    
    

    
    gw_dodgebar_onevent(GwDodgeBar, 'PLAYER_ENTERING_WORLD', 'player')
    
    -- show/hide stuff with override bar
    OverrideActionBar:HookScript('OnShow', function()
        GwPlayerHealthGlobe:SetAlpha(0)
        GwHudArtFrame:SetAlpha(0)
    end)
    OverrideActionBar:HookScript('OnHide', function()
        GwPlayerHealthGlobe:SetAlpha(1)
        GwHudArtFrame:SetAlpha(1)
    end)

    
end

function gw_update_pet_data(event, unit)
    if not UnitExists('pet') then
        return
    end
    if UnitExists('vehicle') and UnitIsUnit('pet', 'vehicle') then
        GwPlayerPetFrame:SetAlpha(0)
        return
    end
    
    if event=='UNIT_AURA' and unit=='pet' then
        updateBuffLayout(GwPlayerPetFrame,event)
       return 
    end
    
    local health = UnitHealth('pet')
    local healthMax = UnitHealthMax('pet')
    local healthprec =0
    
     
    local powerType, powerToken, altR, altG, altB = UnitPowerType('pet')
    local resource = UnitPower('pet',powerType)
    local resourceMax = UnitPowerMax('pet',powerType)
    local resourcePrec = 0
   
    
    if health>0 and healthMax>0 then
         healthprec = health/healthMax
    end
    
    if resource~=nil and resource>0 and resourceMax>0 then
        resourcePrec = resource/resourceMax;
    end
    
    if GW_PowerBarColorCustom[powerToken] then
        local pwcolor = GW_PowerBarColorCustom[powerToken]
        GwPlayerPetFrame.resource:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end
    
    GwPlayerPetFrame.resource:SetValue(resourcePrec)
   
       SetPortraitTexture(_G['GwPlayerPetFramePortrait'],'pet')
    
        if GwPlayerPetFrameHealth.animationCurrent==nil then GwPlayerPetFrameHealth.animationCurrent = 0 end
        addToAnimation('petBarAnimation',GwPlayerPetFrameHealth.animationCurrent,healthprec,GetTime(),0.2,function()
                _G['GwPlayerPetFrameHealth']:SetValue(animations['petBarAnimation']['progress'])
        end)
        GwPlayerPetFrameHealth.animationCurrent = healthprec
        _G['GwPlayerPetFrameHealthString']:SetText(comma_value(health))
  
   
  
    

    
end

function gw_update_power_data(self,forcePowerType,powerToken,forceAnimationName)
    
    if forcePowerType==nil then
        forcePowerType, powerToken, altR, altG, altB = UnitPowerType("player")
        forceAnimationName = 'powerBarAnimation'
    
    end
    
    self.animating = true 
    
    local animation_duration = 0.2
    local power = UnitPower('Player',forcePowerType)
    local powerMax = UnitPowerMax('Player',forcePowerType)
    local powerPrec = 0
    local powerBarWidth = _G[self:GetName()..'Bar']:GetWidth()
    
    
    self.powerType =forcePowerType
    self.lostKnownPower =power
    self.powerMax =powerMax
    self.lastUpdate =GetTime()
    self.powerBarWidth = powerBarWidth
    
    
     if power>0 and powerMax>0 then
         powerPrec = power/powerMax

    end
   
    if GW_PowerBarColorCustom[powerToken] then
        local pwcolor = GW_PowerBarColorCustom[powerToken]
        _G[self:GetName()..'Bar']:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
        _G[self:GetName()..'CandySpark']:SetVertexColor(pwcolor.r, pwcolor.g, pwcolor.b)
        _G[self:GetName()..'Candy']:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
        _G[self:GetName()].bar:SetVertexColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end
     
       
 
    if self.animationCurrent==nil then self.animationCurren=0 end
    


    addToAnimation(self:GetName(),self.animationCurrent,powerPrec,GetTime(),0.2,function()
            
                
        local powerPrec = animations[self:GetName()]['progress']
        local bit = powerBarWidth/15        
        local spark = bit * math.floor(15 * (powerPrec))
    
        local spark_current = (bit * (15 * (powerPrec)) - spark) / bit 
        local round_closest = (spark/powerBarWidth)
            
            
        local bI = math.min(16,math.max(1,math.floor(17 - (16*spark_current))))
        
        _G[self:GetName()..'CandySpark']:SetTexCoord(bloodSpark[bI].left,bloodSpark[bI].right,bloodSpark[bI].top,bloodSpark[bI].bottom)         _G[self:GetName()..'CandySpark']:SetPoint('LEFT',_G[self:GetName()].bar,'RIGHT',-2,0)
        _G[self:GetName()].bar:SetPoint('RIGHT',self,'LEFT',spark,0)
        _G[self:GetName()..'Bar']:SetValue(0)
        _G[self:GetName()..'Candy']:SetValue( 0 )
        
        _G[self:GetName()..'BarString']:SetText(comma_value(powerMax*animations[self:GetName()]['progress']))
            
           self.animationCurrent = powerPrec;
        end,'noease',function() 
            self.animating = false
           
        end)            
      
    if self.lastPowerType ~= self.powerType and self == GwPlayerPowerBar then
        self.lastPowerType = self.powerType
        self.powerCandySpark = _G[self:GetName() .. 'CandySpark']
        self.powerBar = _G[self:GetName() .. 'Bar']
        self.powerCandy = _G[self:GetName() .. 'Candy']
        self.powerBarString = _G[self:GetName() .. 'BarString']
        if self.powerType==nil or self.powerType==1 or self.powerType==6 or self.powerType==13 or self.powerType==8 then
            self:SetScript('OnUpdate', nil)
        else
            self:SetScript('OnUpdate', gw_powerbar_updateRegen)
        end
    end
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

function gw_update_health_data()   
    
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
    addToAnimation('healthGlobeAnimation',GwPlayerHealthGlobe.animationCurrent,healthPrec,GetTime(),0.2,function()
           
            local healthPrecCandy = math.min(1, animations['healthGlobeAnimation']['progress'] + 0.02)
           
            if GwPlayerHealthGlobe.stringUpdateTime<GetTime() then
                gw_update_health_text(healthMax*animations['healthGlobeAnimation']['progress'])
                gw_update_absorb_text(absorb)
                GwPlayerHealthGlobe.stringUpdateTime= GetTime() + 0.05
            end
            _G['GwPlayerHealthGlobeCandy']:SetHeight(healthPrecCandy*_G['GwPlayerHealthGlobeHealthBar']:GetWidth())
            _G['GwPlayerHealthGlobeCandyBar']:SetTexCoord(0,1,  math.abs(healthPrecCandy - 1),1)  
            
            _G['GwPlayerHealthGlobeAbsorbBackdrop']:SetHeight( math.min(1,animations['healthGlobeAnimation']['progress'] + absorbPrec)*_G['GwPlayerHealthGlobeHealthBar']:GetWidth())
            _G['GwPlayerHealthGlobeAbsorbBackdropBar']:SetTexCoord(0,1,  math.abs( math.min(1,animations['healthGlobeAnimation']['progress'] + absorbPrec) - 1),1) 
            
            _G['GwPlayerHealthGlobeHealth']:SetHeight(animations['healthGlobeAnimation']['progress']*_G['GwPlayerHealthGlobeHealthBar']:GetWidth())
            _G['GwPlayerHealthGlobeHealthBar']:SetTexCoord(0,1,  math.abs(animations['healthGlobeAnimation']['progress'] - 1),1) 
        end,nil,function() 
             gw_update_health_text(health)
             gw_update_absorb_text(absorb)
        end)            
        GwPlayerHealthGlobe.animationCurrent = healthPrec;

   
    local absorbPrecOverflow = (healthPrec + absorbPrec) - 1 
    _G['GwPlayerHealthGlobeAbsorb']:SetHeight(absorbPrecOverflow*_G['GwPlayerHealthGlobeHealthBar']:GetWidth())
    _G['GwPlayerHealthGlobeAbsorbBar']:SetTexCoord(0,1,  math.abs(absorbPrecOverflow - 1),1)  
    
end

function gw_update_health_text(text)
    
    local v = comma_value(text)
    _G['GwPlayerHealthGlobeTextValue']:SetText(v)
    for i = 1 , 8 do
        _G['GwPlayerHealthGlobeTextShadow'..i]:SetText(v)
    end
end

function gw_update_absorb_text(text)
    local v  = text;
    if text<=0 then 
        v = ''
    else
        v = comma_value(text)
    end
    
    _G['GwPlayerAbsorbGlobeTextValue']:SetText(v)
    for i = 1 , 8 do
        _G['GwPlayerAbsorbGlobeTextShadow'..i]:SetText(v)
    end
end



function gw_dodgebar_onevent(self,event,unit)

    if event == 'SPELL_UPDATE_COOLDOWN' then
        if self.gwDashSpell then
            local charges, maxCharges, start, duration
            if self.gwMaxCharges > 1 then
                charges, maxCharges, start, duration = GetSpellCharges(self.gwDashSpell)
            else
                charges = 0
                maxCharges = 1
                start, duration, _ = GetSpellCooldown(self.gwDashSpell)
            end                
            gw_update_dodgebar(start, duration, maxCharges, charges)
        end
    elseif event == 'PLAYER_SPECIALIZATION_CHANGED' or event == 'CHARACTER_POINTS_CHANGED' or event == 'PLAYER_ENTERING_WORLD' then
        local foundADash = false
        local _, _ , c = UnitClass('player')
        self.gwMaxCharges = nil
        self.gwDashSpell = nil
        if GW_DODGEBAR_SPELLS[c] ~= nil then
            for k, v in pairs(GW_DODGEBAR_SPELLS[c]) do
                local name = GetSpellInfo(v)
                if name ~= nil then                       
                    if IsPlayerSpell(v) then               
                        self.gwDashSpell = v
                        local charges, maxCharges, start, duration = GetSpellCharges(v)
                        if charges ~= nil and charges <= maxCharges then
                            foundADash = true
                            GwDodgeBar.spellId = v
                            self.gwMaxCharges = maxCharges
                            gw_update_dodgebar(start, duration, maxCharges, charges)
                            break
                        else
                            local start, duration, enable = GetSpellCooldown(v)
                            foundADash = true
                            GwDodgeBar.spellId = v
                            self.gwMaxCharges = 1
                            gw_update_dodgebar(start, duration, 1, 0)
                        end
                    end
                end
            end
        end
        if foundADash then
            if self.gwMaxCharges > 1 and self.gwMaxCharges < 3 then
                _G['GwDodgeBarSep1']:Show()
            else
                _G['GwDodgeBarSep1']:Hide()
            end
    
            if self.gwMaxCharges > 2 then
                _G['GwDodgeBarSep2']:SetRotation(0.55) 
                _G['GwDodgeBarSep3']:SetRotation(-0.55)
        
                _G['GwDodgeBarSep2']:Show() 
                _G['GwDodgeBarSep3']:Show() 
            else
                _G['GwDodgeBarSep2']:Hide() 
                _G['GwDodgeBarSep3']:Hide() 
            end
            GwDodgeBar:Show() 
        else
            GwDodgeBar:Hide()
        end
    end
end


function gw_update_dodgebar(start,duration,chargesMax,charges)
    
    

  --  GwDodgeBar.spark.anim:SetDegrees(63)
 --   GwDodgeBar.spark.anim:SetDuration(1)  
  --  GwDodgeBar.spark.anim:Play()

    if chargesMax==charges then return end

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
