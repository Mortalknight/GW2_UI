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
    GwPlayerClassPower:SetScript('OnEvent', GW_UPDATE_CLASSPOWER)
    
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
    GW_UPDATE_CLASSPOWER(GwPlayerClassPower, 'PLAYER_ENTERING_WORLD', 'player')

    -- show/hide stuff with override bar
    OverrideActionBar:HookScript('OnShow', function()
        classPowerFrame:SetAlpha(0)
    end)
    OverrideActionBar:HookScript('OnHide', function()
        classPowerFrame:SetAlpha(1)
    end)
end





function select_altpower_type()
    
    PLAYER_SPECIALIZATION = GetSpecialization();
    
    GW_SET_BARTYPE()
   
end

function GW_UPDATE_CLASSPOWER(self,event,unit)
    
    
    
    if event=='PLAYER_SPECIALIZATION_CHANGED'  or  event=='CHARACTER_POINTS_CHANGED' or event=='UPDATE_SHAPESHIFT_FORM' then
        select_altpower_type()
    end
    
    if  CLASS_POWERS[PLAYER_CLASS]~=nil and CLASS_POWERS[PLAYER_CLASS][PLAYER_SPECIALIZATION]~=nil then
        local s = GetShapeshiftFormID()
        if s==1 then
            GW_POWERTYPE_COMBOPOINT()
            return
        end
            CLASS_POWERS[PLAYER_CLASS][PLAYER_SPECIALIZATION](event,unit)
        
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
 
    local staggerAmountClamped = math.min(1,GwBrewmaster.debugpre)
    
        
  
    
    if GwBrewmaster.debugpre== 0 then
        GwBrewmaster.stagger.blue:Hide()
        GwBrewmaster.stagger.yellow:Hide()
        GwBrewmaster.stagger.red:Hide()
        GwBrewmaster.stagger.indicator:Hide()   
        GwBrewmaster.stagger.indicatorText:Hide()   
    elseif not GwBrewmaster.stagger.blue:IsShown() then
            GwBrewmaster.stagger.blue:Show()
            GwBrewmaster.stagger.yellow:Show()
            GwBrewmaster.stagger.red:Show()
            GwBrewmaster.stagger.indicator:Show();
            GwBrewmaster.stagger.indicatorText:Show();
    end
 
    GwBrewmaster.stagger.blue:SetVertexColor(1,1,1,1)
    GwBrewmaster.stagger.yellow:SetVertexColor(1,1,1,lerp(0,1, staggerAmountClamped/0.5) )
    GwBrewmaster.stagger.red:SetVertexColor(1,1,1,lerp(0,1, (staggerAmountClamped - 0.5)/0.5) )
    
    GwBrewmaster.stagger.blue:SetTexCoord(0, staggerAmountClamped,0,1)
    GwBrewmaster.stagger.yellow:SetTexCoord(0, staggerAmountClamped,0,1)
    GwBrewmaster.stagger.red:SetTexCoord(0, staggerAmountClamped,0,1)  
    
    GwBrewmaster.stagger.blue:SetWidth(staggerAmountClamped*256)
    GwBrewmaster.stagger.yellow:SetWidth(staggerAmountClamped*256)
    GwBrewmaster.stagger.red:SetWidth(staggerAmountClamped*256)
    
    GwBrewmaster.stagger.indicator:SetPoint('LEFT',(staggerAmountClamped*256) - 13,-6)
    GwBrewmaster.stagger.indicatorText:SetText(math.floor(GwBrewmaster.debugpre*100)..'%')

end

local function ironSkin_OnUpdate()

    local precentage = math.min(1,math.max(0,(GwBrewmaster.ironskin.expires - GetTime())/23));
    GwBrewmaster.stagger.ironartwork:SetAlpha(precentage)
    GwBrewmaster.ironskin.fill:SetTexCoord(0, precentage,0,1)
    GwBrewmaster.ironskin.fill:SetWidth(precentage*256)
    
    GwBrewmaster.ironskin.indicator:SetPoint('LEFT',math.min(252,(precentage*256)) - 13,19)
    GwBrewmaster.ironskin.indicatorText:SetText(intRound(GwBrewmaster.ironskin.expires - GetTime())..'s')
end

function GW_POWERTYPE_STAGGER(event,unit)
    if event==nil then
        GwBrewmaster.debugpre =0;
        GW_LOOP_STAGGER()
         GwBrewmaster.ironskin:Hide()GwBrewmaster.stagger.ironartwork:Hide() 
    end
    
    if event=='UNIT_AURA' and unit=='player' then
        local found = false;
        local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal,   spellID, canApplyAura, isBossDebuff, _, nameplateShowAll, timeMod, value1, value2, value3 = nil
        for i=1,40 do
            name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, _, nameplateShowAll, timeMod, value1, value2, value3 =     UnitAura('player',i)
           
            if spellID==215479 then 
                GwBrewmaster.ironskin.expires = expires;
                 GwBrewmaster.ironskin:SetScript('OnUpdate',ironSkin_OnUpdate);
                 GwBrewmaster.ironskin:Show()
                 GwBrewmaster.stagger.ironartwork:Show()
                found = true;
                break 
            end
        end
        if not found then GwBrewmaster.ironskin:SetScript('OnUpdate',nil);  GwBrewmaster.ironskin:Hide()GwBrewmaster.stagger.ironartwork:Hide() end
        
        return
    end
    
    
    local old_power = CLASS_POWER
    CLASS_POWER_MAX =  UnitHealthMax('player')
    CLASS_POWER = UnitStagger('player')
 --   CLASS_POWER =  168000
    local staggarPrec = CLASS_POWER/CLASS_POWER_MAX
    
    staggarPrec = math.max(0,math.min(staggarPrec,1))
    
    GwBrewmaster.debugpre =staggarPrec;
    GW_LOOP_STAGGER()


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
                    GwPlayerClassPowerFlare:SetPoint('CENTER', _G['GwRuneTextureFill'..i],'CENTER',0,0)
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
    _G[GwExtraPlayerPowerBar:GetName()..'CandySpark']:ClearAllPoints()
    
   GwExtraPlayerPowerBar:SetParent(GwPlayerClassPower)
   GwExtraPlayerPowerBar:ClearAllPoints()
    GwExtraPlayerPowerBar:SetPoint('BOTTOMLEFT',GwPlayerClassPower,'BOTTOMLEFT',0,0)
    
    
    GwExtraPlayerPowerBar:SetScript('OnEvent',function(self,event,unit)
            if unit=='player' then
                gw_update_power_data(GwExtraPlayerPowerBar,0,'MANA','GwExtraPowerBar')
            end
    end)
    
    _G['GwExtraPlayerPowerBarBarString']:SetFont(DAMAGE_TEXT_FONT,14)

    GwExtraPlayerPowerBar:RegisterEvent("UNIT_POWER");
    GwExtraPlayerPowerBar:RegisterEvent("UNIT_MAX_POWER");
    GwExtraPlayerPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD");
    
    gw_update_power_data(GwExtraPlayerPowerBar,0,'MANA','GwExtraPowerBar')
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
function GW_MONGOOSE_LOOP_ANIMATION()
    GwMongooseBar.looping =true
    addToAnimation('GW_MONGOOSE_LOOP_ANIMATION',0,1,GetTime(),10,function()
            
        local precentage = GwMongooseBar.precentage
            
        
        local imagesize = 18/262
            
        local cord = precentage + 0.5
        local cord2 = precentage
    
        local l = animations['GW_MONGOOSE_LOOP_ANIMATION']['progress'] 
        local r = l + imagesize
            
        local a = 1
        local a2 = 1
            
        if animations['GW_MONGOOSE_LOOP_ANIMATION']['progress']<0.25 then
             a = lerp(0,1,animations['GW_MONGOOSE_LOOP_ANIMATION']['progress'] /0.25)
             a2 = lerp(0,1,animations['GW_MONGOOSE_LOOP_ANIMATION']['progress'] /0.25)
        elseif animations['GW_MONGOOSE_LOOP_ANIMATION']['progress']>0.75 then
            a = lerp(1,0,(animations['GW_MONGOOSE_LOOP_ANIMATION']['progress']-0.75) /0.25)  
            a2 = lerp(1,0,(animations['GW_MONGOOSE_LOOP_ANIMATION']['progress']-0.75) /0.25)  
        end
            
 
        local r = 240 / 255
        local g = 37/ 255
        local b = 37 / 255 
       
        
        GwMongooseBar.texture1:SetTexCoord(0,cord,l,r)
        GwMongooseBar.texture2:SetTexCoord(0,cord2,l,r)
            
            
        GwMongooseBar.texture1:SetWidth(math.max(1,262*precentage))
        GwMongooseBar.texture2:SetWidth(math.max(1,262*precentage))
        GwMongooseBar.texture1:SetVertexColor(r,g,b,a)
        GwMongooseBar.texture2:SetVertexColor(r,g,b,a2)
    --    GwStaggerBar.fill:SetVertexColor(r,g,b,1)

    end,'noease',function()
        
        if GwMongooseBar.precentage>0 then
            GW_MONGOOSE_LOOP_ANIMATION()    
        else
           GwMongooseBar.looping =false     
        end
        
        
    end)  
end
function GW_POWERTYPE_MONGOOSE()
       
    local old_power = CLASS_POWER
    CLASS_POWER = 0
    local found=false
    local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, _, nameplateShowAll, timeMod, value1, value2, value3 = nil
    for i=1,40 do
        name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, _, nameplateShowAll, timeMod, value1, value2, value3 = UnitAura('player',i)
        if spellID==190931 then found=true break end
    end
    

    CLASS_POWER_MAX = 6

    if found==true then
        if count==nil then count=1 end

       
        CLASS_POWER = count
        
        local pre = (expires - GetTime()) / duration
        
        if animations['MONGOOSEBITE_BAR']~=nil then
            animations['MONGOOSEBITE_BAR']['completed'] = true
            animations['MONGOOSEBITE_BAR']['duration'] = 0
        end
        
        GW_MONGOOSE_LOOP_ANIMATION()
        
        addToAnimation('MONGOOSEBITE_BAR',pre,0,GetTime(),expires - GetTime(),function()  
            GwMongooseBar.precentage =animations['MONGOOSEBITE_BAR']['progress']
            GwMongooseBar.bar:SetValue(animations['MONGOOSEBITE_BAR']['progress'])    
            GwMongooseBar.bar.spark:ClearAllPoints()
            GwMongooseBar.bar.spark:SetPoint('RIGHT',GwMongooseBar.bar,'LEFT',262*animations['MONGOOSEBITE_BAR']['progress'],0)    
            GwMongooseBar.bar.spark:SetWidth(math.min(15,math.max(1,animations['MONGOOSEBITE_BAR']['progress']*262)))
        end,'noease')
        
        if CLASS_POWER>old_power then
            addToAnimation('MONGOOSEBITE_TEXT',1,0,GetTime(),0.5,function()  
               
                 GwMongooseBar.flash:SetAlpha(animations['MONGOOSEBITE_TEXT']['progress'])
            end)
        end
    end
    
    GwMongooseBar.count:SetText(CLASS_POWER)


end

function GW_FOCUS_RAGE_LOOP()
    
    if GwFocusRage.looping~=nil and GwFocusRage.looping~=false then return end
    
    GwFocusRage.looping =true
    
    addToAnimation('GW_MONGOOSE_LOOP_ANIMATION',0,1,GetTime(),2,function()
            
    local a =  lerp(1,0,(animations['GW_MONGOOSE_LOOP_ANIMATION']['progress'] - 0.5)/0.5)
            
        if animations['GW_MONGOOSE_LOOP_ANIMATION']['progress']<0.5 then
            a = lerp(0,1,animations['GW_MONGOOSE_LOOP_ANIMATION']['progress']/0.5)
        end
    if CLASS_POWER<3 then
        a = 0
    end
            
        GwFocusRage.glow:SetAlpha(a)
        GwFocusRage.highlight:SetAlpha(a)
            
    end,nil,function() 
            
        GwFocusRage.looping =false
            
        if GwFocusRage.bar:GetValue()==3 then
            GW_FOCUS_RAGE_LOOP()
        end
    end)
    
    
end

function GW_POWERTYPE_FOCUSRAGE(event, unit)    
    if event ~= 'UNIT_AURA' or unit ~= 'player' then
        return
    end
    
    local found = false
    local old_power = CLASS_POWER
    CLASS_POWER = 0
    local count, spellID = nil
    
    for i = 1, 40 do
        _, _, _, count, _, _, _, _, _, _, spellID, _ = UnitAura('player', i)
        if spellID == 207982 then
            found = true
            break
        end
    end
          
    if count == nil or found == false then
        count = 0
    end
    CLASS_POWER = count
    local animationSpeed = 0.2
    if CLASS_POWER <= 0 then
        animationSpeed = 0
    end
    
    if CLASS_POWER >= 3 then
       GW_FOCUS_RAGE_LOOP() 
    end
    
    addToAnimation('FOCUS_RAGE_BAR', old_power, CLASS_POWER, GetTime(), animationSpeed, function()
        GwFocusRage.bar:SetValue(animations['FOCUS_RAGE_BAR']['progress'])
    end)
end

function GW_SET_BARTYPE()
    
    GwPlayerClassPower:Show()
    local s = GetShapeshiftFormID()
   
    if  CLASS_POWERS[PLAYER_CLASS]==nil or CLASS_POWERS[PLAYER_CLASS][PLAYER_SPECIALIZATION]==nil then
          GwPlayerClassPower:Hide()
        return
    end
    
   
    if PLAYER_CLASS==1 and PLAYER_SPECIALIZATION==1 then
        
        local talentID, name, texture, selected, available, spellid, tier, column, _ = GetTalentInfo(6, 3, 1, false, "player")

        if selected then
            GwFocusRage:Show()
            GwPlayerClassPowerBackground:SetTexture(nil)
            GwPlayerClassPowerFill:SetTexture(nil)
            return
        end
    end
    GwFocusRage:Hide()
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
     if PLAYER_CLASS==3 then
        GwMongooseBar:Show()
        GwMongooseBar.looping  = false
        GwMongooseBar.precentage  = 0
        GwPlayerClassPowerBackground:SetTexture(nil)
        GwPlayerClassPowerFill:SetTexture(nil)
        GwMongooseBar.texture1:SetVertexColor(1,1,1,0)
        GwMongooseBar.texture2:SetVertexColor(1,1,1,0)
        GwMongooseBar.bar:SetValue(0)
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
         GwPlayerClassPowerBackground:SetTexture(nil)
         GwPlayerClassPowerFill:SetTexture(nil)
        return 
    end
    if PLAYER_CLASS==6 then
        
        GwRuneBar:Show()     
        GwPlayerClassPowerBackground:SetTexture(nil)
        GwPlayerClassPowerFill:SetTexture(nil)
        GwPlayerClassPowerFlare:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\runeflash')
        GwPlayerClassPowerFlare:SetWidth(256)
        GwPlayerClassPowerFlare:SetHeight(128)
        
        local texture  ="runes-blood";
        
        if PLAYER_SPECIALIZATION==2 then
         texture  ="runes";
        elseif PLAYER_SPECIALIZATION==3 then
             texture  ="runes-unholy";
        end
        for i=1,6 do
      
                _G['GwRuneTextureFill'..i]:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\'..texture);
                _G['GwRuneTexture'..i]:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\altpower\\'..texture);
        end
        
        return
   end
    if PLAYER_CLASS==7 then
         GwPlayerClassPowerBackground:SetTexture(nil)
         GwPlayerClassPowerFill:SetTexture(nil)
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
         
        GwBrewmaster:Show()     
   
        GwStaggerBar.loopValue= 0   
        GwPlayerClassPowerBackground:SetTexture(nil)
        GwPlayerClassPowerFill:SetTexture(nil)
        return
    end
    if PLAYER_CLASS==10 and PLAYER_SPECIALIZATION==3 then
        GwBrewmaster:Hide()
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



CLASS_POWERS[1] = {}
CLASS_POWERS[1][1]= GW_POWERTYPE_FOCUSRAGE
CLASS_POWERS[1][3]= GW_POWERTYPE_FOCUSRAGE

CLASS_POWERS[2] = {}
CLASS_POWERS[2][3]= GW_POWERTYPE_HOLYPOWER

CLASS_POWERS[3] = {}
CLASS_POWERS[3][3]= GW_POWERTYPE_MONGOOSE

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




