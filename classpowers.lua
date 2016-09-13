local extra_manabar_loaded = false

HOLY_POWER_FLARE_ANIMATION = 0

RUNE_TIMER_ANIMATIONS = {}
RUNE_TIMER_ANIMATIONS[1] = 0
RUNE_TIMER_ANIMATIONS[2] = 0
RUNE_TIMER_ANIMATIONS[3] = 0
RUNE_TIMER_ANIMATIONS[4] = 0
RUNE_TIMER_ANIMATIONS[5] = 0
RUNE_TIMER_ANIMATIONS[6] = 0

local CLASS_POWERS = {}




local CLASS_POWER_TYPE = 0
local CLASS_POWER_MAX = 0
local CLASS_POWER = 0
local PLAYER_CLASS = 0
local PLAYER_SPECIALIZATION = 0


function create_classpowers()
    local playerClassName, playerClassEng, playerClass = UnitClass('player')
    
    
    PLAYER_CLASS = playerClass
    
    local classPowerFrame = CreateFrame('Frame','GwPlayerClassPower',UIParent,'GwPlayerClassPower')
    GwPlayerClassPower:SetScript('OnEvent',function(self,event) GW_UPDATE_CLASSPOWER(self,event) end)
    
    GwPlayerClassPower:RegisterEvent("UNIT_POWER");
    GwPlayerClassPower:RegisterEvent("UNIT_MAX_POWER");
    GwPlayerClassPower:RegisterEvent("RUNE_POWER_UPDATE");
    GwPlayerClassPower:RegisterEvent("RUNE_TYPE_UPDATE");
    GwPlayerClassPower:RegisterEvent("UNIT_AURA");

    classPowerFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    classPowerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    classPowerFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
    classPowerFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    
    select_altpower_type()
    GW_UPDATE_CLASSPOWER()
end





function select_altpower_type()
    
    PLAYER_SPECIALIZATION = GetSpecialization();
    
    GW_SET_BARTYPE()
   
end

function GW_UPDATE_CLASSPOWER(self,event)
    
    
    
    if event=='PLAYER_SPECIALIZATION_CHANGED'  or  event=='CHARACTER_POINTS_CHANGED' or event=='UPDATE_SHAPESHIFT_FORM' then
        select_altpower_type()
    end
    
    if  CLASS_POWERS[PLAYER_CLASS]~=nil and CLASS_POWERS[PLAYER_CLASS][PLAYER_SPECIALIZATION]~=nil then
        local s = GetShapeshiftFormID()
        if s==1 then
            GW_POWERTYPE_COMBOPOINT()
            return
        end
            CLASS_POWERS[PLAYER_CLASS][PLAYER_SPECIALIZATION](event)
        
    end
    
    
   
end


function GW_POWERTYPE_SOULSHARD()
    
    CLASS_POWER_MAX = UnitPowerMax('player',7)
    CLASS_POWER = UnitPower('player',7)    

    GwPlayerClassPowerBackground:SetTexCoord(0,1,0.125*CLASS_POWER_MAX,0.125*(CLASS_POWER_MAX+1))   
    GwPlayerClassPowerFill:SetTexCoord(0,1,0.125*CLASS_POWER,0.125*(CLASS_POWER+1))

end
function GW_POWERTYPE_HOLYPOWER()
    
    local old_power = CLASS_POWER
    CLASS_POWER_MAX =  UnitPowerMax('player',9)
    CLASS_POWER =  UnitPower('player',9)
    local p = CLASS_POWER - 1

    GwPlayerClassPowerBackground:SetTexCoord(0,1,0.125*CLASS_POWER_MAX,0.125*(CLASS_POWER_MAX+1))   
    GwPlayerClassPowerFill:SetTexCoord(0,1,0.125*p,0.125*(p+1))
    
    if old_power<CLASS_POWER then
        HOLY_POWER_FLARE_ANIMATION = 1
        old_power = CLASS_POWER
        GwPlayerClassPowerFlare:ClearAllPoints()
        GwPlayerClassPowerFlare:SetPoint('CENTER',GwPlayerClassPower,'LEFT',(32*CLASS_POWER),0)
        addToAnimation('HOLY_POWER_FLARE_ANIMATION',HOLY_POWER_FLARE_ANIMATION,0,GetTime(),0.5,function()
            GwPlayerClassPowerFlare:SetAlpha(animations['HOLY_POWER_FLARE_ANIMATION']['progress'])
           
        end)
        
        
    end

end
function GW_POWERTYPE_CHI()
    
    local old_power = CLASS_POWER
    CLASS_POWER_MAX =  UnitPowerMax('player',12)
    CLASS_POWER =  UnitPower('player',12)
    local p = CLASS_POWER - 1

    GwPlayerClassPowerBackground:SetTexCoord(0,1,0.125*(CLASS_POWER_MAX+1),0.125*(CLASS_POWER_MAX+2))   
    GwPlayerClassPowerFill:SetTexCoord(0,1,0.125*p,0.125*(p+1))
    
    if old_power<CLASS_POWER then
        HOLY_POWER_FLARE_ANIMATION = 1
        old_power = CLASS_POWER
        GwPlayerClassPowerFlare:ClearAllPoints()
        GwPlayerClassPowerFlare:SetPoint('CENTER',GwPlayerClassPower,'LEFT',(32*CLASS_POWER),0)
        addToAnimation('HOLY_POWER_FLARE_ANIMATION',HOLY_POWER_FLARE_ANIMATION,0,GetTime(),0.5,function()
            GwPlayerClassPowerFlare:SetAlpha(animations['HOLY_POWER_FLARE_ANIMATION']['progress'])
           
        end)
        
        
    end

end

function GW_LOOP_STAGGER()
 
    GwStaggerBar.looping =true
    addToAnimation('STAGGER_CLASS_POWER',0,1,GetTime(),10,function()
            
        local staggarPrec = CLASS_POWER/CLASS_POWER_MAX
            
        
        local imagesize = 18/256
            
        local cord = staggarPrec
    
        local l = animations['STAGGER_CLASS_POWER']['progress'] 
        local r = l + imagesize
            
        local a = 1
        local a2 = 0
            
        if animations['STAGGER_CLASS_POWER']['progress']<0.25 then
             a = lerp(0,1,animations['STAGGER_CLASS_POWER']['progress'] /0.25)
        elseif animations['STAGGER_CLASS_POWER']['progress']>0.75 then
            a = lerp(1,0,(animations['STAGGER_CLASS_POWER']['progress']-0.75) /0.25)  
        end
            
            
        local r = lerp(37,240,staggarPrec/0.5) / 255
        local g = lerp(240,200,staggarPrec/0.5) / 255
        local b = lerp(152,37,staggarPrec/0.5) / 255 
            
        if animations['STAGGER_CLASS_POWER']['progress']>0.5 then
        local p = (staggarPrec - 0.5) / 0.5
         r = lerp(240,240,p) / 255
         g = lerp(200,37,p) / 255
         b = lerp(37,37,p) / 255
        end  
        
        GwStaggerBar.texture1:SetTexCoord(0,cord,l,r)
        GwStaggerBar.texture2:SetTexCoord(0,cord,l,r)
            
            
        GwStaggerBar.texture1:SetVertexColor(r,g,b,a)
        GwStaggerBar.texture2:SetVertexColor(r,g,b,0)
        GwStaggerBar.fill:SetVertexColor(r,g,b,1)

    end,'noease',function()
        
        local staggarPrec = CLASS_POWER/CLASS_POWER_MAX
        if staggarPrec>0 then
            GW_LOOP_STAGGER()    
        else
           GwStaggerBar.looping =false     
        end
        
        
    end) 
    
end

function GW_POWERTYPE_STAGGER()
    
    local old_power = CLASS_POWER
    CLASS_POWER_MAX =  UnitHealthMax('player')
    CLASS_POWER = UnitStagger('player')
 --   CLASS_POWER =  168000
    local staggarPrec = CLASS_POWER/CLASS_POWER_MAX
    
    staggarPrec = math.max(0,math.min(staggarPrec,1))
    
    addToAnimation('STAGGER_CLASS_POWER_FILL',GwStaggerBar.value,staggarPrec,GetTime(),0.1,function() 
     
        GwStaggerBar.bar:SetWidth(math.max(1,316*animations['STAGGER_CLASS_POWER_FILL']['progress']))
         GwStaggerBar.spark:ClearAllPoints()
         GwStaggerBar.spark:SetPoint('RIGHT',GwStaggerBar.bar,'RIGHT',0,0)
           local sparkwidth = 12
        if (316*animations['STAGGER_CLASS_POWER_FILL']['progress'])<12 then
            sparkwidth = math.max(1,12/ (316*animations['STAGGER_CLASS_POWER_FILL']['progress']))
        end

         GwStaggerBar.spark:SetWidth(sparkwidth)
    end)

       GwStaggerBar.value = staggarPrec
    
    if GwStaggerBar.looping==nil or GwStaggerBar.looping==false and staggarPrec>0 then
        GW_LOOP_STAGGER()
    end

end
function GW_POWERTYPE_COMBOPOINT()
    
    local old_power = CLASS_POWER
    CLASS_POWER_MAX =  UnitPowerMax('player',4)
    CLASS_POWER =  UnitPower('player',4)
    local p = CLASS_POWER - 1

    GwPlayerClassPowerBackground:SetTexCoord(0,1,0.125*(CLASS_POWER_MAX-1),0.125*(CLASS_POWER_MAX))
    GwPlayerClassPowerFill:SetTexCoord(0,1,0.125*p,0.125*(p+1))
    
    if old_power<CLASS_POWER then
        HOLY_POWER_FLARE_ANIMATION = 1
        old_power = CLASS_POWER
        GwPlayerClassPowerFlare:ClearAllPoints()
        GwPlayerClassPowerFlare:SetPoint('CENTER',GwPlayerClassPower,'LEFT',(40*CLASS_POWER),0)
        addToAnimation('HOLY_POWER_FLARE_ANIMATION',HOLY_POWER_FLARE_ANIMATION,0,GetTime(),0.5,function()
            GwPlayerClassPowerFlare:SetAlpha(animations['HOLY_POWER_FLARE_ANIMATION']['progress'])
           
        end)
        
        
    end

end
function GW_POWERTYPE_RUNE()

    for i=1,6 do
        local rune_start, rune_duration, rune_ready = GetRuneCooldown(i)
        if rune_start==nil then
            rune_start = GetTime()
            rune_duration = 0 
        end
        if rune_ready then
            _G['GwRuneTextureFill'..i]:SetTexCoord(0.5,1,0,1)
            _G['GwRuneTextureFill'..i]:SetHeight(32)
            _G['GwRuneTextureFill'..i]:SetVertexColor(1,1,1)
            if animations['RUNE_TIMER_ANIMATIONS'..i] then
                animations['RUNE_TIMER_ANIMATIONS'..i]['completed']=true
                animations['RUNE_TIMER_ANIMATIONS'..i]['duration'] = 0
                
            end
        else
            
            if rune_start==0 then return end
            local startTime = rune_start
            local endTime = rune_start + rune_duration
            
            startTime = startTime 
            endTime = endTime 
            
            addToAnimation('RUNE_TIMER_ANIMATIONS'..i,RUNE_TIMER_ANIMATIONS[i],1,rune_start,rune_duration,function()                    
                _G['GwRuneTextureFill'..i]:SetTexCoord(0.5,1,1-animations['RUNE_TIMER_ANIMATIONS'..i]['progress'],1)
                 _G['GwRuneTextureFill'..i]:SetHeight(32*animations['RUNE_TIMER_ANIMATIONS'..i]['progress'])
                    
                _G['GwRuneTextureFill'..i]:SetVertexColor(1,0.6*animations['RUNE_TIMER_ANIMATIONS'..i]['progress'],0.6*animations['RUNE_TIMER_ANIMATIONS'..i]['progress'])
            end,'noease', function()
                      
                    local runpadding = (42 * i) - 42
                    HOLY_POWER_FLARE_ANIMATION = 1
                    GwPlayerClassPowerFlare:ClearAllPoints()
                    GwPlayerClassPowerFlare:SetPoint('CENTER',GwPlayerClassPower,'LEFT',(runpadding*i),0)
                    addToAnimation('HOLY_POWER_FLARE_ANIMATION',HOLY_POWER_FLARE_ANIMATION,0,GetTime(),0.5,function()

                        GwPlayerClassPowerFlare:SetAlpha(animations['HOLY_POWER_FLARE_ANIMATION']['progress'])
                    end)
                
            end)
            RUNE_TIMER_ANIMATIONS[i] = 0
            
        end
        _G['GwRuneTexture'..i]:SetTexCoord(0,0.5,0,1)
    end

end

function GW_POWERTYPE_MANABAR()
    if extra_manabar_loaded then return end
    extra_manabar_loaded = true
    local GwExtraPlayerPowerBar = CreateFrame('Frame', 'GwExtraPlayerPowerBar',UIParent, 'GwPlayerPowerBar');
    
    
   GwExtraPlayerPowerBar:SetParent(GwPlayerClassPower)
   GwExtraPlayerPowerBar:ClearAllPoints()
    GwExtraPlayerPowerBar:SetPoint('BOTTOMLEFT',GwPlayerClassPower,'BOTTOMLEFT',0,0)
    
    
    GwExtraPlayerPowerBar:SetScript('OnEvent',function(self,event,unit)
            if unit=='player' then
                update_power_data(GwExtraPlayerPowerBar,0,'MANA','GwExtraPowerBar')
            end
    end)
    
    _G['GwExtraPlayerPowerBarBarString']:SetFont(DAMAGE_TEXT_FONT,14)

    GwExtraPlayerPowerBar:RegisterEvent("UNIT_POWER");
    GwExtraPlayerPowerBar:RegisterEvent("UNIT_MAX_POWER");
    GwExtraPlayerPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD");
    
    update_power_data(GwExtraPlayerPowerBar,0,'MANA','GwExtraPowerBar')
end

function GW_POWERTYPE_ARCANE()
       
  
    local old_power = CLASS_POWER
    CLASS_POWER_MAX =  UnitPowerMax('player',16)
    CLASS_POWER =  UnitPower('player',16)
    local p = CLASS_POWER - 1

    GwPlayerClassPowerBackground:SetTexCoord(0,1,0.125*3,0.125*(3+1))
    GwPlayerClassPowerFill:SetTexCoord(0,1,0.125*p,0.125*(p+1))
    
    if old_power<CLASS_POWER then
        HOLY_POWER_FLARE_ANIMATION = 1
        old_power = CLASS_POWER
        GwPlayerClassPowerFlare:ClearAllPoints()
        GwPlayerClassPowerFlare:SetPoint('CENTER',GwPlayerClassPower,'LEFT',(64*CLASS_POWER)-32,0)
        
        addToAnimation('HOLY_POWER_FLARE_ANIMATION',HOLY_POWER_FLARE_ANIMATION,0,GetTime(),2,function()
            
            local alpha =  animations['HOLY_POWER_FLARE_ANIMATION']['progress']

            GwPlayerClassPowerFlare:SetAlpha(alpha)
            GwPlayerClassPowerFlare:SetRotation(1*animations['HOLY_POWER_FLARE_ANIMATION']['progress'])
                
        
        end)
        
        
    end 
end


function GW_SET_BARTYPE()
    
    GwPlayerClassPower:Show()
    local s = GetShapeshiftFormID()
   
    if  CLASS_POWERS[PLAYER_CLASS]==nil or CLASS_POWERS[PLAYER_CLASS][PLAYER_SPECIALIZATION]==nil then
          GwPlayerClassPower:Hide()
        return
    end
    
    if PLAYER_CLASS==2 then
      
        GwPlayerClassPowerBackground:SetHeight(32)
        GwPlayerClassPowerBackground:SetWidth(320)
        
        GwPlayerClassPower:SetHeight(32)
        GwPlayerClassPower:SetWidth(320)
        GwPlayerClassPowerBackground:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\holypower')
        GwPlayerClassPowerBackground:SetTexCoord(0,1,0.5,1)   

        GwPlayerClassPowerFill:SetHeight(32)
        GwPlayerClassPowerFill:SetWidth(320)
        GwPlayerClassPowerFill:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\holypower')
        return
   end 
    if PLAYER_CLASS==4 or PLAYER_CLASS==11 and s==1 then
        if GwExtraPlayerPowerBar~=nil then
            GwExtraPlayerPowerBar:Hide()
        end
        
        GwPlayerClassPowerBackground:SetHeight(32)
        GwPlayerClassPowerBackground:SetWidth(256)
        
        GwPlayerClassPower:SetHeight(40)
        GwPlayerClassPower:SetWidth(320)
        GwPlayerClassPowerFlare:SetWidth(128)
        GwPlayerClassPowerFlare:SetHeight(128)
        GwPlayerClassPowerBackground:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\combo-bg')
        GwPlayerClassPowerFlare:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\combo-flash')
        GwPlayerClassPowerBackground:SetTexCoord(0,1,0.5,1)

        GwPlayerClassPowerFill:SetHeight(40)
        GwPlayerClassPowerFill:SetWidth(320)
        GwPlayerClassPowerFill:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\combo')
        return
   end
    
    if PLAYER_CLASS==5 then
        return 
    end
    if PLAYER_CLASS==6 then
        GwRuneBar:Show()     
        GwPlayerClassPowerBackground:SetTexture(nil)
        GwPlayerClassPowerFill:SetTexture(nil)
        return
   end
    if PLAYER_CLASS==7 then
        return 
    end  
    if PLAYER_CLASS==8 then
        GwPlayerClassPower:SetPoint('BOTTOMLEFT',UIParent,'BOTTOM',-372,70)
        GwPlayerClassPowerBackground:SetHeight(64)
        GwPlayerClassPowerBackground:SetWidth(512)
        
        GwPlayerClassPower:SetHeight(64)
        GwPlayerClassPower:SetWidth(512)
        GwPlayerClassPowerBackground:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\arcane')
        GwPlayerClassPowerFlare:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\arcane-flash')
        GwPlayerClassPowerBackground:SetTexCoord(0,1,0.125*3,0.125*(3+1))
         
        GwPlayerClassPowerFlare:SetWidth(256)
        GwPlayerClassPowerFlare:SetHeight(256)

        GwPlayerClassPowerFill:SetHeight(64)
        GwPlayerClassPowerFill:SetWidth(512)
        GwPlayerClassPowerFill:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\arcane')
        
        GwPlayerClassPowerBackground:SetVertexColor(0,0,0,0.5)
        return 
    end

    if PLAYER_CLASS==9 then
        GwPlayerClassPowerBackground:SetHeight(32)
        GwPlayerClassPowerBackground:SetWidth(128)
        GwPlayerClassPower:SetHeight(32)
        GwPlayerClassPower:SetWidth(256)
        GwPlayerClassPowerBackground:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\shadoworbs-bg')

        GwPlayerClassPowerFill:SetHeight(32)
        GwPlayerClassPowerFill:SetWidth(256)
        GwPlayerClassPowerFill:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\shadoworbs')
        return
    end
   
    if PLAYER_CLASS==10 and PLAYER_SPECIALIZATION==1 then
         
        GwStaggerBar:Show()     
   
        GwStaggerBar.loopValue= 0   
        GwPlayerClassPowerBackground:SetTexture(nil)
        GwPlayerClassPowerFill:SetTexture(nil)
        return
    end
    if PLAYER_CLASS==10 and PLAYER_SPECIALIZATION==3 then
        GwPlayerClassPowerBackground:SetHeight(32)
        GwPlayerClassPowerBackground:SetWidth(320)
        
        GwPlayerClassPower:SetHeight(32)
        GwPlayerClassPower:SetWidth(256)
        GwPlayerClassPowerBackground:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\chi')
        GwPlayerClassPowerFlare:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\chi-flare')
        GwPlayerClassPowerBackground:SetTexCoord(0,1,0.5,1)   

        GwPlayerClassPowerFill:SetHeight(32)
        GwPlayerClassPowerFill:SetWidth(256)
        GwPlayerClassPowerFill:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\chi')
        return
   end
   
    if PLAYER_CLASS==11 and s==5  or s==31 then
        if GwExtraPlayerPowerBar~=nil then
            GwExtraPlayerPowerBar:Show()
        end
         GwPlayerClassPowerBackground:SetTexture(nil)
         GwPlayerClassPowerFill:SetTexture(nil)
        return
    end
    GwPlayerClassPower:Hide()
end



CLASS_POWERS[2] = {}
CLASS_POWERS[2][3]= GW_POWERTYPE_HOLYPOWER

CLASS_POWERS[6] = {}
CLASS_POWERS[6][1]= GW_POWERTYPE_RUNE
CLASS_POWERS[6][2]= GW_POWERTYPE_RUNE
CLASS_POWERS[6][3]= GW_POWERTYPE_RUNE

CLASS_POWERS[4] = {}
CLASS_POWERS[4][1]= GW_POWERTYPE_COMBOPOINT
CLASS_POWERS[4][2]= GW_POWERTYPE_COMBOPOINT
CLASS_POWERS[4][3]= GW_POWERTYPE_COMBOPOINT

CLASS_POWERS[5] = {}
CLASS_POWERS[5][3]= GW_POWERTYPE_MANABAR

CLASS_POWERS[7] = {}
CLASS_POWERS[7][1]= GW_POWERTYPE_MANABAR
CLASS_POWERS[7][2]= GW_POWERTYPE_MANABAR

CLASS_POWERS[8] = {}
CLASS_POWERS[8][1]= GW_POWERTYPE_ARCANE

CLASS_POWERS[9] = {}
CLASS_POWERS[9][1]= GW_POWERTYPE_SOULSHARD
CLASS_POWERS[9][2]= GW_POWERTYPE_SOULSHARD
CLASS_POWERS[9][3]= GW_POWERTYPE_SOULSHARD

CLASS_POWERS[10] = {}
CLASS_POWERS[10][1]= GW_POWERTYPE_STAGGER
CLASS_POWERS[10][3]= GW_POWERTYPE_CHI


CLASS_POWERS[11] = {}
CLASS_POWERS[11][1]= GW_POWERTYPE_MANABAR
CLASS_POWERS[11][2]= GW_POWERTYPE_MANABAR
CLASS_POWERS[11][3]= GW_POWERTYPE_MANABAR
CLASS_POWERS[11][4]= GW_POWERTYPE_MANABAR




