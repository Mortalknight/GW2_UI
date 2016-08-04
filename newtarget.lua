
local unitFrameAnimations  = {}
local buffLists = {}
local DebuffLists = {}



 bloodSparkIndex = {}
 bloodSparkThro = {}
-- 0.1,0.9,0.1,0.9)


function registerNewUnitFrame(unitToWatch, frameType)
    

    

    unitFrameAnimations[unitToWatch..'healthAnimation'] = 0
    unitFrameAnimations[unitToWatch..'powerAnimation'] = 0
    unitFrameAnimations[unitToWatch..'castingAnimation'] = 0
    bloodSparkIndex[unitToWatch] = 1
    bloodSparkThro[unitToWatch] = 0
    buffLists[unitToWatch] = {}
    DebuffLists[unitToWatch] = {}
    

    
    local targetF = CreateFrame('Button', 'Gw'..unitToWatch..'Frame',UIParent,frameType);
    targetF.unit = unitToWatch
    
    gw_register_movable_frame(unitToWatch..'frame',targetF,unitToWatch..'_pos',frameType..'Dummy')
    
    local thisName = targetF:GetName();   
        _G[thisName..'Buffs']:SetScript('OnUpdate',function() 
            update_buff_timers(thisName)    
    end)
    
    

    targetF:ClearAllPoints()
    targetF:SetPoint(gwGetSetting(unitToWatch..'_pos')['point'],UIParent,gwGetSetting(unitToWatch..'_pos')['relativePoint'],gwGetSetting(unitToWatch..'_pos')['xOfs'],gwGetSetting(unitToWatch..'_pos')['yOfs'])

   

    targetF:SetAttribute("unit", unitToWatch);
   -- targetF:SetFrameStrata('HIGH');

    targetF:SetAttribute("*type1", 'target')
    targetF:SetAttribute("*type2", "togglemenu")
    targetF:SetAttribute("unit", unitToWatch)
    RegisterUnitWatch(targetF);
    targetF:EnableMouse(true)
    targetF:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    
    local dropdown = nil;
    if unitToWatch=='target' then
        dropdown = TargetFrameDropDown
        
        TargetFrame:SetScript("OnEvent", nil);
        TargetFrame:Hide();   
        
    end
     if unitToWatch=='focus' then
        dropdown = FocusFrameDropDown
        
        FocusFrame:SetScript("OnEvent", nil);
        FocusFrame:Hide();     
    end
    
    if dropdown then
        targetF:SetScript('OnMouseDown', function(self,button)
            if button=='RightButton' then
            ToggleDropDownMenu(1, nil, dropdown, targetF, 0, 0)
            end	
        end)
    end
    
    _G[thisName.."Level"]:SetFont(UNIT_NAME_FONT,14)
    _G[thisName.."Name"]:SetFont(UNIT_NAME_FONT,14)
    _G[thisName.."HealthBarHealthBarString"]:SetFont(UNIT_NAME_FONT,11)
    _G[thisName.."CastingBarCastingBarString"]:SetFont(UNIT_NAME_FONT,12)
    
    _G[thisName.."HealthBarHealthBarString"]:SetTextColor(255,255,255)
    _G[thisName.."CastingBarCastingBarString"]:SetTextColor(255,255,255)
    _G[thisName.."CastingBarCastingBarString"]:SetShadowColor(0,0,0,0.5)
    
    _G[thisName.."AbsorbBar"]:SetStatusBarColor(0.9,0.9,0.6,0.6)
    
    _G[thisName.."HealthBarCandy"]:SetFrameLevel(2)
    _G[thisName.."HealthBar"]:SetFrameLevel(3)
  
    _G[thisName.."AbsorbBar"]:SetFrameLevel(4)
    _G[thisName.."CastingBar"]:SetFrameLevel(5)

    
    

    local healthAnimation = {}  
    local powerAnimation = {}
    local castingAnimation = {}
     castingAnimation[unitToWatch] = 0;

    function target_OnEvent(self,event,unit)
        
       
        
        local u = "PLAYER_"..unitToWatch.."_CHANGED"

        u = string.upper(u)     
        
        if event =='UNIT_MAX_HEALTH' or event=='UNIT_HEALTH' or event=='UNIT_ABSORB_AMOUNT_CHANGED' and unit==unitToWatch then   
            updatHealthValues(thisName,unitToWatch)
        end        
        -- if power changed add the change to animation
        if event=='UNIT_MAX_POWER' or event=='UNIT_POWER' and unit==unitToWatch then
            updatePowerValues(thisName,unitToWatch)
        end
     
   
        
        if event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START' or event=='UNIT_SPELLCAST_UPDATE' or event=='UNIT_SPELLCAST_CHANNEL_STOP' or event=='UNIT_SPELLCAST_STOP' or event=='UNIT_SPELLCAST_INTERRUPTED' or event=='UNIT_SPELLCAST_FAILED'   then
            updateCastingbar(thisName,unitToWatch)
        end
   
        if event=='UNIT_AURA' or unit=='target' then
            updateAuras(thisName,unitToWatch,event)
        end
            
        if event=='PLAYER_TARGET_CHANGED' or event=='UNIT_TARGET' then
            updateFrameData(thisName,unitToWatch,event)
        end
        if event=='PLAYER_FOCUS_CHANGED' or event=='UNIT_FOCUS' then
            updateFrameData(thisName,unitToWatch,event)
        end
  

    end
    

    
    
    

    

    targetF:SetScript("OnShow",function()
            if InCombatLockdown() then
                return
            end 
        UIFrameFadeIn(targetF, 0.1,0,1)
    end)
  
    function hide_health_numbers()
        _G[thisName.."CastingBarCastingBarString"]:Hide()
    end
    function show_health_numbers()
        _G[thisName.."CastingBarCastingBarString"]:Show()
    end
    
    
    targetF:RegisterEvent("PLAYER_TARGET_CHANGED");
    targetF:RegisterEvent("PLAYER_FOCUS_CHANGED");
    targetF:RegisterEvent("UNIT_AURA");
    targetF:RegisterEvent("PLAYER_ENTERING_WORLD");
    targetF:RegisterEvent("ZONE_CHANGED");

    targetF:RegisterEvent("UNIT_SPELLCAST_START");
    targetF:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    targetF:RegisterEvent("UNIT_SPELLCAST_UPDATE");
    targetF:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    targetF:RegisterEvent("UNIT_SPELLCAST_STOP");
    targetF:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
    targetF:RegisterEvent("UNIT_SPELLCAST_FAILED");
    targetF:RegisterEvent("UNIT_HEALTH");
    targetF:RegisterEvent("UNIT_MAX_HEALTH");
    targetF:RegisterEvent("UNIT_TARGET");
    targetF:RegisterEvent("PLAYER_ENTERING_WORLD");

    targetF:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")


    targetF:RegisterEvent("UNIT_POWER");
    targetF:RegisterEvent("UNIT_MAX_POWER");
    targetF:RegisterEvent("PLAYER_ENTERING_WORLD");
    targetF:RegisterEvent("UNIT_AURA");
    
    targetF:RegisterEvent("UNIT_SPELLCAST_START");
    targetF:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    targetF:RegisterEvent("UNIT_SPELLCAST_UPDATE");

    targetF:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    targetF:RegisterEvent("UNIT_SPELLCAST_STOP");
    targetF:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
    targetF:RegisterEvent("UNIT_SPELLCAST_FAILED");

    targetF:SetScript('OnEvent',target_OnEvent)

end

function updateAuras(thisName, unitToWatch)
    if gwGetSetting(unitToWatch..'_BUFFS')~=true then
        return
    end
 
    update_buff_list(unitToWatch)
    local x = 0;
    local y = 0;
    for i=1,40 do
        local indexBuffFrame = _G[thisName..'BuffItemFrame'..i]
        if buffLists[unitToWatch][i] then
            local  key = buffLists[unitToWatch][i]['key']
            if indexBuffFrame==nil then
                indexBuffFrame = CreateFrame('Frame', thisName..'BuffItemFrame'..i,_G[thisName..'Buffs'],'GwBuffIcon');
                indexBuffFrame:SetParent(_G[thisName..'Buffs']);
            end
            local margin = indexBuffFrame:GetWidth() + 4
            local marginy = indexBuffFrame:GetWidth() + 12
            _G[thisName..'BuffItemFrame'..i..'BuffIcon']:SetTexture(buffLists[unitToWatch][i]['icon'])
            _G[thisName..'BuffItemFrame'..i..'BuffIcon']:SetParent(_G[thisName..'BuffItemFrame'..i])
            local buffDur = '';
            local stacks = '';
            if buffLists[unitToWatch][i]['duration']>0 then
                buffDur = timeCount(buffLists[unitToWatch][i]['timeRemaining']);
            end
              if buffLists[unitToWatch][i]['count']>0 then
               stacks = buffLists[unitToWatch][i]['count'] 
            end
            indexBuffFrame.expires =buffLists[unitToWatch][i]['expires']
            indexBuffFrame.duration =buffLists[unitToWatch][i]['duration']
             _G[thisName..'BuffItemFrame'..i..'BuffDuration']:SetText(buffDur)
             _G[thisName..'BuffItemFrame'..i..'BuffStacks']:SetText(stacks)
            indexBuffFrame:ClearAllPoints()
            indexBuffFrame:SetPoint('TOPLEFT',(margin*x),(-marginy*y) + -10)
            
            indexBuffFrame:SetScript('OnEnter', function() GameTooltip:SetOwner(indexBuffFrame, "ANCHOR_BOTTOMLEFT"); GameTooltip:ClearLines(); GameTooltip:SetUnitBuff(unitToWatch,key); GameTooltip:Show() end)
            indexBuffFrame:SetScript('OnLeave', function() GameTooltip:Hide() end)
            
            indexBuffFrame:Show()
            
            x=x+1
            if x>7 then
                y=y+1
                x=0
            end
            
        else
            
            if indexBuffFrame~=nil then
                indexBuffFrame:Hide() 
            else
                break
            end
        end
        
    end
    updateDebuffs(thisName,unitToWatch,x,y)
end
function updateDebuffs(thisName, unitToWatch,x,y)
 
    if gwGetSetting(unitToWatch..'_DEBUFFS')~=true then
        return
    end
    y=y+1
    x=0
    update_Debuff_list(unitToWatch)

    for i=1,40 do
        local indexBuffFrame = _G[thisName..'DeBuffItemFrame'..i]
        if DebuffLists[unitToWatch][i] then
            local key =DebuffLists[unitToWatch][i]['key']
            if indexBuffFrame==nil then
                indexBuffFrame = CreateFrame('Frame', thisName..'DeBuffItemFrame'..i,_G[thisName..'Buffs'],'GwDeBuffIcon');
                indexBuffFrame:SetParent(_G[thisName..'Buffs']);
                
                _G[thisName..'DeBuffItemFrame'..i..'DeBuffBackground']:SetVertexColor(GW_COLOR_FRIENDLY[2].r,GW_COLOR_FRIENDLY[2].g,GW_COLOR_FRIENDLY[2].b);
                _G[thisName..'DeBuffItemFrame'..i..'Cooldown']:SetDrawEdge(0)
                _G[thisName..'DeBuffItemFrame'..i..'Cooldown']:SetDrawSwipe(1)
                _G[thisName..'DeBuffItemFrame'..i..'Cooldown']:SetReverse(false)
                _G[thisName..'DeBuffItemFrame'..i..'Cooldown']:SetHideCountdownNumbers(true)
                
   
                _G[thisName..'DeBuffItemFrame'..i..'IconBuffStacks']:SetFont(UNIT_NAME_FONT,14,'OUTLINE')
                _G[thisName..'DeBuffItemFrame'..i..'IconBuffStacks']:SetTextColor(255,255,255)
                
                
                _G[thisName..'DeBuffItemFrame'..i..'CooldownBuffDuration']:SetFont(UNIT_NAME_FONT,14)
                _G[thisName..'DeBuffItemFrame'..i..'CooldownBuffDuration']:SetTextColor(255,255,255)
                
            end
            _G[thisName..'DeBuffItemFrame'..i..'IconBuffIcon']:SetTexture(DebuffLists[unitToWatch][key]['icon'])
     
            local buffDur = '';
            local stacks  = '';
            if DebuffLists[unitToWatch][key]['count']>0 then
               stacks = DebuffLists[unitToWatch][key]['count'] 
            end
            if DebuffLists[unitToWatch][key]['duration']>0 then
                buffDur = timeCount(DebuffLists[unitToWatch][key]['timeRemaining']);
            end
            indexBuffFrame.expires =DebuffLists[unitToWatch][key]['expires']
            indexBuffFrame.duration =DebuffLists[unitToWatch][key]['duration']
           _G[thisName..'DeBuffItemFrame'..i..'Cooldown']:SetCooldown(DebuffLists[unitToWatch][key]['expires'] - DebuffLists[unitToWatch][key]['duration'], DebuffLists[unitToWatch][key]['duration'])
     
            
            _G[thisName..'DeBuffItemFrame'..i..'CooldownBuffDuration']:SetText(buffDur)
            _G[thisName..'DeBuffItemFrame'..i..'IconBuffStacks']:SetText(stacks)
            indexBuffFrame:ClearAllPoints()
            indexBuffFrame:SetPoint('TOPLEFT',(32*x),-32*y)
            
            indexBuffFrame:SetScript('OnEnter', function() GameTooltip:SetOwner(indexBuffFrame, "ANCHOR_BOTTOMLEFT"); GameTooltip:ClearLines(); GameTooltip:SetUnitBuff(unitToWatch,i); GameTooltip:Show() end)
            indexBuffFrame:SetScript('OnLeave', function() GameTooltip:Hide() end)
            
            indexBuffFrame:Show()
            
            x=x+1
            if x>7 then
                y=y+1
                x=0
            end
            
        else
            
            if indexBuffFrame~=nil then
                indexBuffFrame:Hide() 
            else
                break
            end
        end
        
    end
    
end

 

local update_buff_Timer_cooldown = 0
function update_buff_timers(thisName)
    if update_buff_Timer_cooldown>GetTime() then
        return
    end
    update_buff_Timer_cooldown = GetTime()+1

    for i=1,40 do

        if _G[thisName..'DeBuffItemFrame'..i] then
        
           local buffDur = '';
            d = tonumber(_G[thisName..'DeBuffItemFrame'..i].duration)
            e = tonumber(_G[thisName..'DeBuffItemFrame'..i].expires)
            
            if d>0 then
                buffDur = timeCount(e-GetTime());
            end
            _G[thisName..'DeBuffItemFrame'..i..'CooldownBuffDuration']:SetText(buffDur)
        
        end 
        if _G[thisName..'BuffItemFrame'..i] then
        
           local buffDur = '';
            d = tonumber(_G[thisName..'BuffItemFrame'..i].duration)
            e = tonumber(_G[thisName..'BuffItemFrame'..i].expires)
            
            if d>0 then
                buffDur = timeCount(e-GetTime());
            end
            _G[thisName..'BuffItemFrame'..i..'BuffDuration']:SetText(buffDur)
        
        end
    end
end

function update_buff_list(unitToWatch)
        buffLists[unitToWatch] = {}
    for i=1,40 do
        if  UnitBuff(unitToWatch,i) then
            buffLists[unitToWatch][i] ={}
    buffLists[unitToWatch][i]['name'],  buffLists[unitToWatch][i]['rank'],  buffLists[unitToWatch][i]['icon'],  buffLists[unitToWatch][i]['count'],  buffLists[unitToWatch][i]['dispelType'],  buffLists[unitToWatch][i]['duration'],  buffLists[unitToWatch][i]['expires'],  buffLists[unitToWatch][i]['caster'],  buffLists[unitToWatch][i]['isStealable'],  buffLists[unitToWatch][i]['shouldConsolidate'],  buffLists[unitToWatch][i]['spellID']  =  UnitBuff(unitToWatch,i) 
            buffLists[unitToWatch][i]['key'] = i
            buffLists[unitToWatch][i]['timeRemaining'] =  buffLists[unitToWatch][i]['expires']-GetTime();
            if buffLists[unitToWatch][i]['duration']<=0 then
                  buffLists[unitToWatch][i]['timeRemaining'] = 500000
            end    
        end
    end
    

    table.sort( buffLists[unitToWatch], function(a,b) return a['timeRemaining'] < b['timeRemaining'] end)
    
end
function update_Debuff_list(unitToWatch)
        DebuffLists[unitToWatch] = {}
    for i=1,40 do
        if  UnitDebuff(unitToWatch,i,'PLAYER')  then
            DebuffLists[unitToWatch][i] ={}
    DebuffLists[unitToWatch][i]['name'],  DebuffLists[unitToWatch][i]['rank'],  DebuffLists[unitToWatch][i]['icon'],  DebuffLists[unitToWatch][i]['count'],  DebuffLists[unitToWatch][i]['dispelType'],  DebuffLists[unitToWatch][i]['duration'],  DebuffLists[unitToWatch][i]['expires'],  DebuffLists[unitToWatch][i]['caster'],  DebuffLists[unitToWatch][i]['isStealable'],  DebuffLists[unitToWatch][i]['shouldConsolidate'],  DebuffLists[unitToWatch][i]['spellID']  =  UnitDebuff(unitToWatch,i,'PLAYER') 
            DebuffLists[unitToWatch][i]['key'] = i 
            DebuffLists[unitToWatch][i]['timeRemaining'] =  DebuffLists[unitToWatch][i]['expires']-GetTime();
            if DebuffLists[unitToWatch][i]['duration']<=0 then
                  DebuffLists[unitToWatch][i]['timeRemaining'] = 500000
            end    
        end
    end
    

    table.sort( DebuffLists[unitToWatch], function(a,b) return a['timeRemaining'] < b['timeRemaining'] end)
    
end






function updateCastingbar(thisName,unitToWatch)
        
        local spellType = 0
        local castingbarWidth = _G[thisName.."CastingBar"]:GetWidth()
        
        local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unitToWatch)
        casting = false
        channel = false
            
         
        if name==nil then
            name, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unitToWatch)
            spellType = 1;
        end
       
        if name~=nil and endTime~=nil and startTime~=nil and texture~=nil  then    
            
            _G[thisName.."CastingBarCastingBarString"]:SetText(name)
            
            if _G[thisName.."Portrait"] then
                SetPortraitToTexture(_G[thisName.."Portrait"], texture)
            end
            
            _G[thisName.."CastingBar"]:Show()
            if _G[thisName.."CastingBarBackground"] then
                _G[thisName.."CastingBarBackground"]:Show()
                gw_unitFrameSetBuffPosition(thisName) 
            end
            
            if notInterruptible then
                _G[thisName.."CastingBar"]:SetStatusBarColor(145/255,145/255,145/255)  
            else
                _G[thisName.."CastingBar"]:SetStatusBarColor(221/255,173/255,69/255)
            end
            startTime = startTime /1000
            endTime = endTime /1000
            addToAnimation(unitToWatch..'newcastingAnimation',unitFrameAnimations[unitToWatch..'castingAnimation'],1,startTime,endTime-startTime,function()
                if _G[thisName.."CastingBarSpark"] then
                    
                    local w = math.max(0.001,math.min(10,(animations[unitToWatch..'newcastingAnimation']['progress']/1)*100))
                    if _G[thisName.."CastingBarSpark"]:GetWidth()~=w then
                        _G[thisName.."CastingBarSpark"]:SetWidth(w)
                    end
                    _G[thisName.."CastingBarSpark"]:SetPoint('RIGHT',_G[thisName.."CastingBar"],'LEFT',castingbarWidth*animations[unitToWatch..'newcastingAnimation']['progress'],0)
                end
                 _G[thisName.."CastingBar"]:SetValue(animations[unitToWatch..'newcastingAnimation']['progress'])
            end,'noease')    
            
        
        else
        _G[thisName.."CastingBar"]:Hide()
        _G[thisName.."CastingBar"]:SetValue(0)
        if _G[thisName.."CastingBarBackground"] then
            _G[thisName.."CastingBarBackground"]:Hide()
            gw_unitFrameSetBuffPosition(thisName) 
        end
            if animations[unitToWatch..'newcastingAnimation'] then
                animations[unitToWatch..'newcastingAnimation']['completed'] = true
                animations[unitToWatch..'newcastingAnimation']['duration'] = 0
            end
        if _G[thisName.."Portrait"] then
            SetPortraitTexture(_G[thisName.."Portrait"], unitToWatch)
        end
          
        end
        
    end
    function updatePowerValues(thisName,unitToWatch)
        
        local power =   UnitPower(unitToWatch,UnitPowerType(unitToWatch))
        local powerMax =   UnitPowerMax(unitToWatch,UnitPowerType(unitToWatch))
        local powerPrecentage = 0
        if power>0 and powerMax>0 then
            powerPrecentage= power/powerMax
        end
        if _G[thisName.."PowerBarBackground"] then
                if powerMax<=0 then
                _G[thisName.."PowerBarBackground"]:Hide()
                else 
                 _G[thisName.."PowerBarBackground"]:Show()
                end
        end
        
        addToAnimation(unitToWatch..'powerAnimation',unitFrameAnimations[unitToWatch..'powerAnimation'],powerPrecentage,GetTime(),0.1,function()
            _G[thisName.."ManaBar"]:SetValue(animations[unitToWatch..'powerAnimation']['progress'])
        end)            
        unitFrameAnimations[unitToWatch..'powerAnimation'] = powerPrecentage;
        
    end
    function updatHealthValues(thisName,unitToWatch)
        if not UnitExists(unitToWatch) then return end
        local health = UnitHealth(unitToWatch)
        local healthMax = UnitHealthMax(unitToWatch)
        local healthPrecentage = 0
        local absorb = UnitGetTotalAbsorbs(unitToWatch)
    
        local absorbPrecentage = 0
        
    
        
        
        if absorb>0 and healthMax>0 then
            absorbPrecentage = absorb/healthMax
        end
    
        if health>0 and healthMax>0 then
            healthPrecentage = health/healthMax
        end

         
        
    
        --set health and absorbvalue
          
    addToAnimation(unitToWatch..'healthAnimation',unitFrameAnimations[unitToWatch..'healthAnimation'],healthPrecentage,GetTime(),0.45,function()
          
                
                local  round_closest = 0.05 * math.floor((animations[unitToWatch..'healthAnimation']['progress']*100)/5) 
                local spark_min =  math.floor((animations[unitToWatch..'healthAnimation']['progress']*100)/5)
                local spark_max =  math.ceil((animations[unitToWatch..'healthAnimation']['progress']*100)/5) 
                local spark_current = (animations[unitToWatch..'healthAnimation']['progress']*100)/5
                local spark_prec = spark_current - spark_min
               
                local spark = math.min(_G[thisName.."HealthBar"]:GetWidth()-15,(_G[thisName.."HealthBar"]:GetWidth()*round_closest))
                    bloodSparkIndex[unitToWatch] = 17 - math.max(1,math.ceil(16 * spark_prec))
                    local bI = bloodSparkIndex[unitToWatch]
                    _G[thisName.."HealthBarSpark"]:SetTexCoord(bloodSpark[bI].left,
                        bloodSpark[bI].right,
                        bloodSpark[bI].top,
                        bloodSpark[bI].bottom)
                 _G[thisName.."HealthBarSpark"]:ClearAllPoints()
                _G[thisName.."HealthBarSpark"]:SetPoint('LEFT',math.floor(spark),0)
    
            healthValueText =''
            if gwGetSetting(unitToWatch..'_HEALTH_VALUE_ENABLED') then
                healthValueText = comma_value(health)
                if gwGetSetting(unitToWatch..'_HEALTH_VALUE_TYPE') then
                    healthValueText = healthValueText..' - '
                end
            end
            if gwGetSetting(unitToWatch..'_HEALTH_VALUE_TYPE') then
                local precentag_show = healthPrecentage*100
                healthValueText = healthValueText..comma_value(precentag_show)..'%'
        end
    _G[thisName.."HealthBarHealthBarString"]:SetText(healthValueText)
        
            
            _G[thisName.."HealthBar"]:SetValue(round_closest)
            local candy = lerp(animations[unitToWatch..'healthAnimation']['from'],animations[unitToWatch..'healthAnimation']['to'],(GetTime() - animations[unitToWatch..'healthAnimation']['start'])/animations[unitToWatch..'healthAnimation']['duration'])
            _G[thisName.."HealthBarCandy"]:SetValue(0)
            
            
        end)            
        unitFrameAnimations[unitToWatch..'healthAnimation'] = healthPrecentage;
        
        _G[thisName.."AbsorbBar"]:SetValue(absorbPrecentage)
        
        
    
        
    end

  function updateFrameData(thisName,unitToWatch,event)
  

    if UnitExists("Target")~=true then
        return
    end        
            
    local health = UnitHealth(unitToWatch)
    local healthMax = UnitHealthMax(unitToWatch)
    local healthPrecentage = 0
    local absorb = UnitGetTotalAbsorbs(unitToWatch)
    local absorbPrecentage = 0
    local power =   UnitPower(unitToWatch,UnitPowerType(unitToWatch))
    local powerMax =   UnitPowerMax(unitToWatch,UnitPowerType(unitToWatch))
    local powerPrecentage = 0
    local level = UnitLevel(unitToWatch)
    local name = UnitName(unitToWatch)
    local isFriend = UnitIsFriend("player",unitToWatch);
    local friendlyColor = GW_COLOR_FRIENDLY[1]
    
    
        
    
        
        
    if absorb>0 and healthMax>0 then
        absorbPrecentage = absorb/healthMax
    end
        
    if power>0 and powerMax>0 then
        powerPrecentage = power/powerMax
    end 
    if health>0 and healthMax>0 then
        healthPrecentage = health/healthMax
    end
          
    if isFriend~=true then
        friendlyColor = GW_COLOR_FRIENDLY[2]
    end
    if UnitIsTapDenied('player') then
        friendlyColor = GW_COLOR_FRIENDLY[3]
    end
    
    updatHealthValues(thisName,unitToWatch)
    updatePowerValues(thisName,unitToWatch)
        
    if animations[unitToWatch..'powerAnimation'] then
        animations[unitToWatch..'powerAnimation']['completed'] = true
        animations[unitToWatch..'powerAnimation']['duration'] = 0
    end
    
    if  animations[unitToWatch..'healthAnimation'] then
        animations[unitToWatch..'healthAnimation']['completed'] = true
        animations[unitToWatch..'healthAnimation']['duration'] = 0
    end
    if  _G[thisName.."HealthBarSpark"] then
        _G[thisName.."HealthBarSpark"]:ClearAllPoints()
        _G[thisName.."HealthBarSpark"]:SetPoint('LEFT',_G[thisName.."HealthBar"],'LEFT',(_G[thisName.."HealthBar"]:GetWidth()*healthPrecentage)-15,0)
    end
    _G[thisName.."HealthBarCandy"]:SetValue(healthPrecentage)
    _G[thisName.."HealthBar"]:SetValue(healthPrecentage)
    _G[thisName.."ManaBar"]:SetValue(powerPrecentage)
    _G[thisName.."AbsorbBar"]:SetValue(absorbPrecentage)
   
    healthValueText =''
    if gwGetSetting(unitToWatch..'_HEALTH_VALUE_ENABLED') then
        healthValueText = comma_value(health)
        if gwGetSetting(unitToWatch..'_HEALTH_VALUE_TYPE') then
            healthValueText = healthValueText..' - '
        end
    end
    if gwGetSetting(unitToWatch..'_HEALTH_VALUE_TYPE') then
        local precentag_show = healthPrecentage*100
        healthValueText = healthValueText..comma_value(precentag_show)..'%'
    end
    _G[thisName.."HealthBarHealthBarString"]:SetText(healthValueText)
        
       
            
        --Can we see the level?
    if level == -1 then
        level = '??'
    end
    --set name and level
    _G[thisName.."Level"]:SetText(level)
    _G[thisName.."Name"]:SetText(name)
    
    if _G[thisName.."Portrait"] then
            SetPortraitTexture(_G[thisName.."Portrait"], unitToWatch)
    end
    
    --Set Color of name and level 
    _G[thisName.."Level"]:SetTextColor(255,255,255)
        
    --Set The Color of the powerbar
    powerType, powerToken, altR, altG, altB = UnitPowerType(unitToWatch)
    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        _G[thisName.."ManaBar"]:SetStatusBarColor(pwcolor.r,pwcolor.g,pwcolor.b)
    end
    
    if isFriend then
        _G[thisName.."HealthBar"]:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\statusbarcolored_green")
        if _G[thisName.."HealthBarSpark"] then
            _G[thisName.."HealthBarSpark"]:SetVertexColor(GW_COLOR_FRIENDLY[1].r,GW_COLOR_FRIENDLY[1].g,GW_COLOR_FRIENDLY[1].b)
        end
        
    else
        _G[thisName.."HealthBar"]:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\statusbarcolored_red") 
         if _G[thisName.."HealthBarSpark"] then
            _G[thisName.."HealthBarSpark"]:SetVertexColor(GW_COLOR_FRIENDLY[2].r,GW_COLOR_FRIENDLY[2].g,GW_COLOR_FRIENDLY[2].b)
        end
    end
    
    _G[thisName.."Name"]:SetTextColor(friendlyColor.r,friendlyColor.g,friendlyColor.b)
    _G[thisName.."HealthBarCandy"]:SetStatusBarColor(friendlyColor.r,friendlyColor.g,friendlyColor.b)
    
    if _G[thisName.."Background"] then
        _G[thisName.."Background"]:SetTexture(GW_TARGET_FRAME_ART[UnitClassification(unitToWatch)])
    end
        
    updateCastingbar(thisName,unitToWatch)
    updateAuras(thisName,unitToWatch,event)
        
        
end


function gw_unitFrameSetBuffPosition(thisName)

    
    if _G[thisName.."CastingBarBackground"]:IsShown() then
         _G[thisName..'Buffs']:SetPoint('TOPLEFT',130,-75)
    else
        _G[thisName..'Buffs']:SetPoint('TOPLEFT',130,-60)
    end
end
    
    










