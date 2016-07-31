local buffLists = {}
local DebuffLists = {}

function gw_set_buffframe()
BuffFrame:Hide()
BuffFrame:SetScript('OnShow',function(self) self:Hide() end)


local player_buff_frame = CreateFrame('Frame','GwPlayerAuraFrame',UIParent,'GwPlayerAuraFrame')
    player_buff_frame:SetScript('OnEvent',function() gw_playerUpdateAuras() end)
    player_buff_frame:RegisterEvent('UNIT_AURA')
    
    
    local fgw = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate')
    fgw:SetFrameRef('GwPlayerAuraFrame', player_buff_frame)
    fgw:SetFrameRef('UIParent', UIParent)
    fgw:SetFrameRef('MultiBarBottomRight', MultiBarBottomRight)
    fgw:SetAttribute('_onstate-combat', [=[ 
        
        if self:GetFrameRef('MultiBarBottomRight'):IsShown()==false then
            return
        end
        
      self:GetFrameRef('GwPlayerAuraFrame'):ClearAllPoints()
        if newstate == 'show' then
         self:GetFrameRef('GwPlayerAuraFrame'):SetPoint('BOTTOMLEFT',self:GetFrameRef('UIParent'),'BOTTOM',53,212)
        end
    ]=])
    RegisterStateDriver(fgw, 'combat', '[combat] show; hide')
    
    gw_actionbar_state_add_callback(gw_updatePlayerBuffFrameLocation)
    gw_updatePlayerBuffFrameLocation()
    update_buff_timers('GwPlayerBuff')
      _G['GwPlayerAuraFrame']:SetScript('OnUpdate',function() 
            update_player_buff_timers('GwPlayerBuffItemFrame')    
    end)
    
    gw_playerUpdateAuras()
end

local player_update_buff_Timer_cooldown = 0
function update_player_buff_timers(thisName)
    if player_update_buff_Timer_cooldown>GetTime() then
        return
    end
    player_update_buff_Timer_cooldown = GetTime()+1

    for i=1,40 do
        if _G['playerDeBuffItemFrame'..i] then
        
           local buffDur = '';
            d = tonumber(_G['playerDeBuffItemFrame'..i].duration)
            e = tonumber(_G['playerDeBuffItemFrame'..i].expires)
            
            if d>0 then
                buffDur = timeCount(e-GetTime());
            end
            _G['playerDeBuffItemFrame'..i..'CooldownBuffDuration']:SetText(buffDur)
        
        end
        if _G['GwPlayerBuffItemFrame'..i] then

           local buffDur = '';
            d = tonumber(_G['GwPlayerBuffItemFrame'..i].duration)
            e = tonumber(_G['GwPlayerBuffItemFrame'..i].expires)
            
            if d>0 then
                buffDur = timeCount(e-GetTime());
            end
            _G['GwPlayerBuffItemFrame'..i..'BuffDuration']:SetText(buffDur)
        
        end
    end
end
function gw_updatePlayerBuffFrameLocation()
    
    if InCombatLockdown() then
        return
    end 
    
    local b = false
    _G['GwPlayerAuraFrame']:ClearAllPoints()
     if MultiBarBottomRight:GetAlpha()>0.0 and MultiBarBottomRight:IsShown()  then
          b = true
    end
    if b then
        _G['GwPlayerAuraFrame']:SetPoint('BOTTOMLEFT',UIParent,'BOTTOM',53,212)
    else
        _G['GwPlayerAuraFrame']:SetPoint('BOTTOMLEFT',UIParent,'BOTTOM',53,120)
    end
    
    
end

function gw_playerUpdateAuras()

    unitToWatch = 'player'
    updatePlayerBuffLisr()
    local x = 0;
    local y = 0;
    for i=1,40 do
        local indexBuffFrame = _G['GwPlayerBuffItemFrame'..i]
        if buffLists[unitToWatch][i] then
            local key = buffLists[unitToWatch][i]['key'];
            if indexBuffFrame==nil then
                indexBuffFrame = CreateFrame('Button',  'GwPlayerBuffItemFrame'..i,_G['GwPlayerAuraFrame'],'GwBuffIconBig');
                indexBuffFrame:SetParent(_G['GwPlayerAuraFrame']);
            end
            local margin = -indexBuffFrame:GetWidth() + -2
            local marginy = indexBuffFrame:GetWidth() + 12
            _G['GwPlayerBuffItemFrame'..i..'BuffIcon']:SetTexture(buffLists[unitToWatch][i]['icon'])
            _G['GwPlayerBuffItemFrame'..i..'BuffIcon']:SetParent(_G['GwPlayerBuffItemFrame'..i])
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
            _G['GwPlayerBuffItemFrame'..i..'BuffDuration']:SetText(buffDur)
            _G['GwPlayerBuffItemFrame'..i..'BuffStacks']:SetText(stacks)
            indexBuffFrame:ClearAllPoints()
            indexBuffFrame:SetPoint('BOTTOMRIGHT',(margin*x),marginy*y)
             
            indexBuffFrame:SetScript('OnEnter', function() GameTooltip:SetOwner(indexBuffFrame,"ANCHOR_BOTTOMLEFT",28,0); GameTooltip:ClearLines(); GameTooltip:SetUnitBuff(unitToWatch,key); GameTooltip:Show() end)
            indexBuffFrame:SetScript('OnLeave', function() GameTooltip:Hide() end)
             
            indexBuffFrame:SetScript('OnClick', function(self,button) 
                    if InCombatLockdown() then
                        return
                    end 
                    if button=='RightButton' then
                        CancelUnitBuff("player",key)
                    end
                end)
                
            indexBuffFrame:Show()
            
            x=x+1
            if x>7 then
                y=y+1
                x=0
            end
            
        else
            
            if indexBuffFrame~=nil then
               indexBuffFrame:Hide() 
                indexBuffFrame:SetScript('OnEnter',nil)
                indexBuffFrame:SetScript('OnClick',nil) 
                indexBuffFrame:SetScript('OnLeave',nil) 
              
            else
                break
            end
        end
        
    end
   gw_playerUpdateDeBuffs(x,y)
end
function gw_playerUpdateDeBuffs(x,y)

    y=y+1
    x=0
    updatePlayerDeBuffList()

    for i=1,40 do
        local indexBuffFrame = _G['playerDeBuffItemFrame'..i]
        if DebuffLists[unitToWatch][i] then
             
            local key = DebuffLists[unitToWatch][i]['key'];
            
            if indexBuffFrame==nil then
                indexBuffFrame = CreateFrame('Frame', 'playerDeBuffItemFrame'..i,_G['GwPlayerAuraFrame'],'GwDeBuffIcon');
                indexBuffFrame:SetParent(_G['GwPlayerAuraFrame']);
                
                _G['playerDeBuffItemFrame'..i..'DeBuffBackground']:SetVertexColor(GW_COLOR_FRIENDLY[2].r,GW_COLOR_FRIENDLY[2].g,GW_COLOR_FRIENDLY[2].b);
                _G['playerDeBuffItemFrame'..i..'Cooldown']:SetDrawEdge(0)
                _G['playerDeBuffItemFrame'..i..'Cooldown']:SetDrawSwipe(1)
                _G['playerDeBuffItemFrame'..i..'Cooldown']:SetReverse(1)
                _G['playerDeBuffItemFrame'..i..'Cooldown']:SetHideCountdownNumbers(true)
            end 
            _G['playerDeBuffItemFrame'..i..'IconBuffIcon']:SetTexture(DebuffLists[unitToWatch][i]['icon'])
            _G['playerDeBuffItemFrame'..i..'IconBuffIcon']:SetParent(_G['playerDeBuffItemFrame'..i])
            local buffDur = '';
            local stacks  = '';
            if DebuffLists[unitToWatch][i]['count']>0 then
               stacks = DebuffLists[unitToWatch][i]['count'] 
            end
            if DebuffLists[unitToWatch][i]['duration']>0 then
                buffDur = timeCount(DebuffLists[unitToWatch][i]['timeRemaining']);
            end
            indexBuffFrame.expires =DebuffLists[unitToWatch][i]['expires']
            indexBuffFrame.duration =DebuffLists[unitToWatch][i]['duration']
            

            _G['playerDeBuffItemFrame'..i..'CooldownBuffDuration']:SetText(buffDur)
            _G['playerDeBuffItemFrame'..i..'IconBuffStacks']:SetText(stacks)
            indexBuffFrame:ClearAllPoints()
            indexBuffFrame:SetPoint('BOTTOMRIGHT',(-32*x),32*y)
            
            indexBuffFrame:SetScript('OnEnter', function() GameTooltip:SetOwner(indexBuffFrame, "ANCHOR_BOTTOMLEFT"); GameTooltip:ClearLines(); GameTooltip:SetUnitDebuff(unitToWatch,i); GameTooltip:Show() end)
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

 function updatePlayerBuffLisr()
    unitToWatch ='Player'
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
    

    table.sort( buffLists[unitToWatch], function(a,b) return a['timeRemaining'] > b['timeRemaining'] end)

end
function updatePlayerDeBuffList()
    unitToWatch ='Player'
    DebuffLists[unitToWatch] = {}
    for i=1,40 do
       
        if  UnitDebuff(unitToWatch,i)  then
           
            DebuffLists[unitToWatch][i] ={}
    DebuffLists[unitToWatch][i]['name'],  DebuffLists[unitToWatch][i]['rank'],  DebuffLists[unitToWatch][i]['icon'],  DebuffLists[unitToWatch][i]['count'],  DebuffLists[unitToWatch][i]['dispelType'],  DebuffLists[unitToWatch][i]['duration'],  DebuffLists[unitToWatch][i]['expires'],  DebuffLists[unitToWatch][i]['caster'],  DebuffLists[unitToWatch][i]['isStealable'],  DebuffLists[unitToWatch][i]['shouldConsolidate'],  DebuffLists[unitToWatch][i]['spellID']  =  UnitDebuff(unitToWatch,i)
            DebuffLists[unitToWatch][i]['key'] = i
            DebuffLists[unitToWatch][i]['timeRemaining'] =  DebuffLists[unitToWatch][i]['expires']-GetTime();
            if DebuffLists[unitToWatch][i]['duration']<=0 then
                  DebuffLists[unitToWatch][i]['timeRemaining'] = 500000
            end    
        end
    end
    

    table.sort( DebuffLists[unitToWatch], function(a,b) return a['timeRemaining'] < b['timeRemaining'] end)
    
end