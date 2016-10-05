
local unitFrameAnimations  = {}
local buffLists = {}
local DebuffLists = {}
local gw_unitFrame_debufflist_old = {}



 bloodSparkIndex = {}
 bloodSparkThro = {}
-- 0.1,0.9,0.1,0.9)


function gw_registerNewUnitFrame(unitToWatch, frameType)
    

    

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
    
    GwaddTOClique(targetF)
    
    targetF:SetScript('OnLeave',function() 
        GameTooltip:Hide()
    end)
    targetF:SetScript('OnEnter',function() 
            GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(unitToWatch)
       
        GameTooltip:Show()
    end)
    
    local dropdown = nil;
    if unitToWatch=='target' then
        
        TargetFrame:SetScript("OnEvent", nil);
        TargetFrame:Hide();   
        
    end
    if unitToWatch=='focus' then
    
        FocusFrame:SetScript("OnEvent", nil);
        FocusFrame:Hide();     
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
    
    
    _G[thisName.."HealthBarSpark"]:ClearAllPoints()
    
    
    if _G[thisName.."Portrait"]~=nil then
        _G[thisName.."Portrait"]:SetMask("Textures\\MinimapMask")
    end

    
    

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
     
   
        
        if (event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START' or event=='UNIT_SPELLCAST_UPDATE' or event=='UNIT_SPELLCAST_CHANNEL_STOP' or event=='UNIT_SPELLCAST_STOP' or event=='UNIT_SPELLCAST_INTERRUPTED' or event=='UNIT_SPELLCAST_FAILED') and unit==unitToWatch then
            updateCastingbar(thisName,unitToWatch)
        end
   
        if event=='UNIT_AURA' or unit==unitToWatch then
            gw_unitFrame_updateAuras(thisName,unitToWatch,event)
        end
            
        if event=='PLAYER_TARGET_CHANGED' then
            updateFrameData(thisName,unitToWatch,event)
        end
        
        if  event=='UNIT_TARGET' and (unit=='player' or unit=='focus' or unit=='target') then
            updateFrameData(thisName,unitToWatch,event)
        end
        
        if event=='PLAYER_FOCUS_CHANGED' then
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

    targetF:RegisterEvent("ZONE_CHANGED");

    targetF:RegisterEvent("UNIT_HEALTH");
    targetF:RegisterEvent("UNIT_MAX_HEALTH");
    targetF:RegisterEvent("UNIT_TARGET");


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

function gw_unitFrame_updateAuras(thisName, unitToWatch,event)
    if gwGetSetting(unitToWatch..'_BUFFS')~=true then
        return
    end
 
    update_buff_list(unitToWatch)
    
    local frameIndex = 1
    local x = 0;
    local y = 0;
    for i=1,40 do
        local indexBuffFrame = _G[thisName..'BuffItemFrame'..frameIndex]
        if buffLists[unitToWatch][i] then
            local  key = buffLists[unitToWatch][i]['key']
            if indexBuffFrame==nil then
                
                indexBuffFrame = CreateFrame('Frame', thisName..'BuffItemFrame'..frameIndex,_G[thisName..'Buffs'],'GwBuffIcon');
                indexBuffFrame:SetParent(_G[thisName..'Buffs']);
                _G[thisName..'BuffItemFrame'..frameIndex..'BuffIcon']:SetParent(_G[thisName..'BuffItemFrame'..frameIndex])
                
                indexBuffFrame.unit = unitToWatch
                
                
                  
                local margin = indexBuffFrame:GetWidth() + 4
                local marginy = indexBuffFrame:GetWidth() + 12
                
                
                indexBuffFrame:ClearAllPoints()
                indexBuffFrame:SetPoint('TOPLEFT',(margin*x),(-marginy*y) + -10)
            end
      
            
            gw_buff(indexBuffFrame,buffLists[unitToWatch][i],key)
            
            indexBuffFrame:Show()
            
            x=x+1
            if x>7 then
                y=y+1
                x=0
            end
            frameIndex = frameIndex + 1
            
        end
        
    end
    
    for i=frameIndex,40 do
        local indexBuffFrame = _G[thisName..'BuffItemFrame'..i]
        if indexBuffFrame~=nil and indexBuffFrame:IsShown() then
           indexBuffFrame:Hide() 
        end
    end
    
    gw_unitFrame_updateDebuffs(thisName,unitToWatch,x,y,event)
end
function gw_unitFrame_updateDebuffs(thisName, unitToWatch,x,y,event)
 
    if gwGetSetting(unitToWatch..'_DEBUFFS')~=true then
        return
    end
    y=y+1
    x=0
    local frameIndex = 1
    local filter = 'player'
    
    if gwGetSetting(unitToWatch..'_BUFFS_FILTER_ALL') or UnitIsFriend("player",unitToWatch) then
        filter = nil
    end
    update_Debuff_list(unitToWatch)

    for i=1,40 do
        local indexBuffFrame = _G[thisName..'DeBuffItemFrame'..frameIndex]
        if DebuffLists[unitToWatch][i] then
            local key =DebuffLists[unitToWatch][i]['key']
            if indexBuffFrame==nil then
                indexBuffFrame = CreateFrame('Frame', thisName..'DeBuffItemFrame'..frameIndex,_G[thisName..'Buffs'],'GwDeBuffIcon');
                indexBuffFrame:SetParent(_G[thisName..'Buffs']);
                indexBuffFrame:SetSize(28,28)
                indexBuffFrame:ClearAllPoints()
                indexBuffFrame:SetPoint('CENTER',_G[thisName..'Buffs'],'TOPLEFT',(32*x)+16,(-40*y) - 16)
                indexBuffFrame.unit = unitToWatch
                    
            end
            
            if DebuffLists[unitToWatch][i]['caster']~=nil and DebuffLists[unitToWatch][i]['caster']=='player' then   
                gw_hightlighted_debuff(indexBuffFrame,DebuffLists[unitToWatch][i],key)
                indexBuffFrame:SetSize(28,28)
            else
                indexBuffFrame:SetSize(24,24)
                gw_debuff(indexBuffFrame,DebuffLists[unitToWatch][i],key,filter)
            end
   
            indexBuffFrame:Show()
            if DebuffLists[unitToWatch][i]['new'] and event~=nil and DebuffLists[unitToWatch][i]['caster']=='player' then
                addToAnimation(indexBuffFrame:GetName(),40,28,GetTime(),0.2,function()
                    indexBuffFrame:SetSize(animations[indexBuffFrame:GetName()]['progress'],animations[indexBuffFrame:GetName()]['progress'])
                end)
            end
            
            x=x+1
            if x>7 then
                y=y+1
                x=0
            end
            frameIndex = frameIndex + 1
            
        else
            
            if indexBuffFrame~=nil then
                indexBuffFrame:Hide() 
            end
        end
        
    end
    for i=frameIndex,40 do
        local indexBuffFrame = _G[thisName..'DeBuffItemFrame'..i]
        if indexBuffFrame~=nil and indexBuffFrame:IsShown() then
           indexBuffFrame:Hide() 
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
    
    local filter = 'player'
    
    if gwGetSetting(unitToWatch..'_BUFFS_FILTER_ALL') or UnitIsFriend("player",unitToWatch) then
        filter = nil
        
    end
    gw_unitFrame_debufflist_old[unitToWatch] = {}
    gw_unitFrame_debufflist_old[unitToWatch] = DebuffLists[unitToWatch]
    DebuffLists[unitToWatch] = {}
     for i=1,40 do
        if  UnitDebuff(unitToWatch,i,filter)  then
            DebuffLists[unitToWatch][i] ={}
    DebuffLists[unitToWatch][i]['name'],  DebuffLists[unitToWatch][i]['rank'],  DebuffLists[unitToWatch][i]['icon'],  DebuffLists[unitToWatch][i]['count'],  DebuffLists[unitToWatch][i]['dispelType'],  DebuffLists[unitToWatch][i]['duration'],  DebuffLists[unitToWatch][i]['expires'],  DebuffLists[unitToWatch][i]['caster'],  DebuffLists[unitToWatch][i]['isStealable'],  DebuffLists[unitToWatch][i]['shouldConsolidate'],  DebuffLists[unitToWatch][i]['spellID']  =  UnitDebuff(unitToWatch,i,filter) 
            DebuffLists[unitToWatch][i]['key'] = i 
            DebuffLists[unitToWatch][i]['new'] = true
            DebuffLists[unitToWatch][i]['timeRemaining'] =  DebuffLists[unitToWatch][i]['expires']-GetTime();
            if DebuffLists[unitToWatch][i]['duration']<=0 then
                  DebuffLists[unitToWatch][i]['timeRemaining'] = 500000
            end    
        end
    end
   
    for k,v in pairs(DebuffLists[unitToWatch]) do
        for k2,v2 in pairs(gw_unitFrame_debufflist_old[unitToWatch]) do
            if v['name']==v2['name'] and  v['caster']=='player' then
                DebuffLists[unitToWatch][k]['new'] = false
            end
        end
    
        
    end
        
    if gwGetSetting(unitToWatch..'_BUFFS_FILTER_ALL') or UnitIsFriend("player",unitToWatch) then
           
        local playerList = {}
        local otherList = {}
        local returnList = {}
        local playerIndex = 0
        local otherIndex = 0
            
        for k,v in pairs(DebuffLists[unitToWatch]) do    
            
            if v['caster']~=nil and v['caster']=='player' then
                playerIndex = playerIndex + 1
                    
                playerList[playerIndex] = {}
                playerList[playerIndex] = v
            else
               
                otherIndex = otherIndex + 1
                otherList[otherIndex] = {}
                otherList[otherIndex] = v
            end
                
            for i=1,(playerIndex) do
                returnList[i] ={}  
                returnList[i] = playerList[i]                 
            end
            local ind = 0
            for i=(playerIndex+1),(playerIndex + otherIndex) do
                ind = ind + 1
                returnList[i] ={}  
                returnList[i] = otherList[ind]                 
            end
            
        end
        DebuffLists[unitToWatch] = returnList
        
    else
        table.sort( DebuffLists[unitToWatch], function(a,b) return a['timeRemaining'] < b['timeRemaining']  end)         
    end
    

   
  
    
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
                _G[thisName.."Portrait"]:SetMask("Textures\\MinimapMask")
                _G[thisName.."Portrait"]:SetTexture(texture)
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
    function updatHealthValues(thisName,unitToWatch,noAnimation)
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
    
    local dif = math.abs(unitFrameAnimations[unitToWatch..'healthAnimation'] - healthPrecentage) 
    if dif==0 then return end
    
    local speed = math.max(0.2,1.00 * dif)
    if noAnimation~=nil then speed = 0 end
    addToAnimation(unitToWatch..'healthAnimation',unitFrameAnimations[unitToWatch..'healthAnimation'],healthPrecentage,GetTime(),speed,function()
          
            
    local powerPrec = animations[unitToWatch..'healthAnimation']['progress']
    local powerBarWidth = _G[thisName.."HealthBar"]:GetWidth()
    local bit = powerBarWidth/12        
    local spark = bit * math.floor(12 * (powerPrec))
    local spark_current = (bit * (12 * (powerPrec)) - spark) / bit 
    local round_closest = (spark/powerBarWidth)
            
            
    local bI = math.min(16,math.max(1,math.floor(17 - (16*spark_current))))
         
    _G[thisName.."HealthBarSpark"]:SetTexCoord(bloodSpark[bI].left,bloodSpark[bI].right,bloodSpark[bI].top,bloodSpark[bI].bottom)         _G[thisName.."HealthBarSpark"]:SetPoint('LEFT',_G[thisName].bar,'RIGHT',0,0)
    _G[thisName].bar:SetPoint('RIGHT',_G[thisName.."HealthBar"],'LEFT',spark,0)
            
            
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
        
            
            _G[thisName.."HealthBar"]:SetValue(0)
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
    
    
    updatePowerValues(thisName,unitToWatch)
        
    if animations[unitToWatch..'powerAnimation'] then
        animations[unitToWatch..'powerAnimation']['completed'] = true
        animations[unitToWatch..'powerAnimation']['duration'] = 0
    end
    
    if  animations[unitToWatch..'healthAnimation'] then
        animations[unitToWatch..'healthAnimation']['completed'] = true
        animations[unitToWatch..'healthAnimation']['duration'] = 0
    end

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
        if _G[thisName.."HealthBarSpark"] then
            _G[thisName.."HealthBarSpark"]:SetVertexColor(GW_COLOR_FRIENDLY[1].r,GW_COLOR_FRIENDLY[1].g,GW_COLOR_FRIENDLY[1].b)
            _G[thisName.."HealthBar"]:SetStatusBarColor(GW_COLOR_FRIENDLY[1].r,GW_COLOR_FRIENDLY[1].g,GW_COLOR_FRIENDLY[1].b)
            _G[thisName].bar:SetVertexColor(GW_COLOR_FRIENDLY[1].r,GW_COLOR_FRIENDLY[1].g,GW_COLOR_FRIENDLY[1].b)
        end
        
    else
       
         if _G[thisName.."HealthBarSpark"] then
            _G[thisName.."HealthBarSpark"]:SetVertexColor(GW_COLOR_FRIENDLY[2].r,GW_COLOR_FRIENDLY[2].g,GW_COLOR_FRIENDLY[2].b)
            _G[thisName.."HealthBar"]:SetStatusBarColor(GW_COLOR_FRIENDLY[2].r,GW_COLOR_FRIENDLY[2].g,GW_COLOR_FRIENDLY[2].b)
            _G[thisName].bar:SetVertexColor(GW_COLOR_FRIENDLY[2].r,GW_COLOR_FRIENDLY[2].g,GW_COLOR_FRIENDLY[2].b)
        end
    end
    
    _G[thisName.."Name"]:SetTextColor(friendlyColor.r,friendlyColor.g,friendlyColor.b)
    _G[thisName.."HealthBarCandy"]:SetStatusBarColor(friendlyColor.r,friendlyColor.g,friendlyColor.b)
    
    if _G[thisName.."Background"] then
        _G[thisName.."Background"]:SetTexture(GW_TARGET_FRAME_ART[UnitClassification(unitToWatch)])
    end
        
    updateCastingbar(thisName,unitToWatch)
    updatHealthValues(thisName,unitToWatch,false)
    gw_unitFrame_updateAuras(thisName,unitToWatch,nil)

        
end


function gw_unitFrameSetBuffPosition(thisName)

    
    if _G[thisName.."CastingBarBackground"]:IsShown() then
         _G[thisName..'Buffs']:SetPoint('TOPLEFT',130,-75)
    else
        _G[thisName..'Buffs']:SetPoint('TOPLEFT',130,-60)
    end
end
    
    










