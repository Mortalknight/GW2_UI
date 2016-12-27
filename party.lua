local GW_CURRENT_GROUP_TYPE = 'PARTY'

local GW_READY_CHECK_INPROGRESS = false

local GW_PORTRAIT_BACKGROUND = {}

GW_PORTRAIT_BACKGROUND[1] = {l=0,r=0.828,t=0,b=0.166015625}
GW_PORTRAIT_BACKGROUND[2] = {l=0,r=0.828,t=0.166015625,b=0.166015625*2}
GW_PORTRAIT_BACKGROUND[3] = {l=0,r=0.828,t=0.166015625*2,b=0.166015625*3}
GW_PORTRAIT_BACKGROUND[4] = {l=0,r=0.828,t=0.166015625*3,b=0.166015625*4}




local buffLists = {}
local DebuffLists = {}


function gw_manage_group_button()
    CreateFrame('Button','GwManageGroupButton',UIParent,'GwManageGroupButton')
    CreateFrame('Frame','GwGroupManage',UIParent,'GwGroupManage')
	
	GwButtonInviteToParty:SetText(GwLocalization['PARTY_INVITE'])
	GwManageGroupLeaveButton:SetText(GwLocalization['PARTY_LEAVE'])
	GwGroupReadyCheck:SetText(GwLocalization['PARTY_READY_CHECK'])
	GwGroupRoleCheck:SetText(GwLocalization['PARTY_ROLE_CHECK'])
    
    tinsert(UISpecialFrames, "GwGroupManage") 
    local x = 10
    local y = -8
    for i=1,8 do

        local f = CreateFrame('Button','GwRaidMarkerButton'..i,GwGroupManagerInGroup,'GwRaidMarkerButton') 
        
        f:ClearAllPoints()
        f:SetPoint('TOPLEFT',GwGroupManagerInGroup,'TOPLEFT',x,y)
        f:SetNormalTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..i)
        f:SetScript('OnClick',function()
            SetRaidTarget("target", i)
        end)
        
        x = x + 61
        if i==4 then
            y = y + -55; 
            x=10
        end
        
    end
    
    
end

function gw_invite_to_group(str)
  
    InviteUnit(str)
end

function gw_register_partyframes()
    
    gw_manage_group_button()
 
    SetCVar('useCompactPartyFrames',1)
    
    
    if gwGetSetting('RAID_STYLE_PARTY') then
        return
    end
   
    
    
    gw_create_partyframe(1)
    gw_create_partyframe(2)
    gw_create_partyframe(3)
    gw_create_partyframe(4)
    
    GwPartyFrame1:SetPoint('TOPLEFT',20,-104)
 
    
end

function gw_toggle_partyRaid(b)
    if b==true and not IsInRaid() then
        for i=1,4 do
            if _G['GwPartyFrame'..i]~=nil then
                _G['GwPartyFrame'..i]:Show()
                RegisterUnitWatch(_G['GwPartyFrame'..i])
                _G['GwPartyFrame'..i]:SetScript('OnEvent',gw_partyframe_OnEvent)
            end
        end
        GW_CURRENT_GROUP_TYPE ='PARTY'
    else
        for i=1,4 do
            if _G['GwPartyFrame'..i]~=nil then
                _G['GwPartyFrame'..i]:Hide()
                _G['GwPartyFrame'..i]:SetScript('OnEvent',nil)
                UnregisterUnitWatch(_G['GwPartyFrame'..i])
            end
        end
        GW_CURRENT_GROUP_TYPE ='RAID'
    end    
end


function gw_create_partyframe(i)
    
    local registerUnit = 'party'..i
  --  registerUnit = 'player'
    
   local frame = CreateFrame('Button','GwPartyFrame'..i,UIParent,'GwPartyFrame')
    
    frame:SetPoint('TOPLEFT',20,-104 + ((-85*i))+85)
    
    frame.unit=registerUnit
	frame.ready = -1
    
    frame:SetAttribute("unit", registerUnit);
    frame:SetAttribute("*type1", 'target')
    frame:SetAttribute("*type2", "togglemenu")

    RegisterUnitWatch(frame);
    frame:EnableMouse(true)
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    
    frame:SetScript('OnLeave',function() 
        GameTooltip:Hide()
    end)
    frame:SetScript('OnEnter',function() 
            GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(registerUnit)
       
        GameTooltip:Show()
    end)
    
    GwaddTOClique(frame)
    
    frame.healthbar.spark:SetVertexColor(GW_COLOR_FRIENDLY[1].r,GW_COLOR_FRIENDLY[1].g,GW_COLOR_FRIENDLY[1].b)
    
    frame.healthbar.animationName =registerUnit..'animation'
    frame.healthbar.animationValue = 0
    
    frame:RegisterEvent('UNIT_HEALTH')
    frame:RegisterEvent('UNIT_HEALTH_MAX')
    frame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    frame:RegisterEvent("UNIT_POWER");
    frame:RegisterEvent("UNIT_MAX_POWER");
    frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
    frame:RegisterEvent("GROUP_ROSTER_UPDATE");
    frame:RegisterEvent("UNIT_PHASE");
    frame:RegisterEvent("PARTY_MEMBER_DISABLE");
    frame:RegisterEvent("PARTY_MEMBER_ENABLE");
    frame:RegisterEvent("UNIT_AURA");
    frame:RegisterEvent("UNIT_LEVEL");
    frame:RegisterEvent("PARTY_CONVERTED_TO_RAID");
    frame:RegisterEvent("RAID_CONVERTED_TO_PARTY");
	frame:RegisterEvent("READY_CHECK");
    frame:RegisterEvent("READY_CHECK_CONFIRM");
    frame:RegisterEvent("READY_CHECK_FINISHED");
	
	frame:SetScript('OnEvent',gw_partyframe_OnEvent)
    
    gw_update_partyFrameData(frame)
    
end

function gw_partyframe_OnEvent(self,event,unit,arg1)

    if not UnitExists(self.unit) then return end
    if IsInRaid() then return end
    if event=='UNIT_HEALTH' or event=='UNIT_MAX_HEALTH' and unit==self.unit then
        local health = UnitHealth(self.unit)
        local healthMax = UnitHealthMax(self.unit)
        local healthPrec = 0
        if healthMax>0 then
            healthPrec = health/healthMax
        end
        gwBar(self.healthbar,healthPrec)
    end
    if event=='UNIT_POWER' or event=='UNIT_MAX_POWER' and unit==self.unit then
        local power =   UnitPower(self.unit,UnitPowerType(self.unit))
        local powerMax =   UnitPowerMax(self.unit,UnitPowerType(self.unit))
        local powerPrecentage = 0
        if powerMax>0 then
            powerPrecentage = power/powerMax
        end
        self.powerbar:SetValue(powerPrecentage)
    end
    if event=='PARTY_MEMBERS_CHANGED' or event=='UNIT_LEVEL' or event == 'GROUP_ROSTER_UPDATE' or event == "RAID_CONVERTED_TO_PARTY" then
        gw_update_partyFrameData(self)
    end
    if event=='UNIT_PHASE' or event=='PARTY_MEMBER_DISABLE' or event=='PARTY_MEMBER_ENABLE'  then
       gw_update_awaydata(self)
    end 
	
    if event=='UNIT_AURA' and unit==self.unit then
       gw_updatePartyFrameAuras(self,self.unit)
    end
	
	if event=='READY_CHECK' then
        self.ready = -1
        GW_READY_CHECK_INPROGRESS = true
        gw_update_awaydata(self)
        self.classicon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\party\\readycheck')	
    end
	
    if event=='READY_CHECK_CONFIRM' and unit==self.unit then
        self.ready = arg1
        gw_update_awaydata(self)
    end
	
    if event=='READY_CHECK_FINISHED' then
		GW_READY_CHECK_INPROGRESS = false
		addToAnimation("ReadyCheckPartyWait"..self.unit,0,1,GetTime(),2,function() end,nil,function()
				if UnitInParty(self.unit) ~=nil then
					self.classicon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\party\\classicons');
					localizedClass, englishClass, classIndex = UnitClass(self.unit);
					if classIndex~=nil and classIndex~=0 then
						gw_setClassIcon(self.classicon,classIndex);
					end;
				end
			end)
    end
end

function gw_update_awaydata(self)
    
    local portraitIndex = 1
    
    posY, posX, posZ, instanceID = UnitPosition(self.unit);
    _,_,_, playerinstanceID = UnitPosition('player');
    
    if playerinstanceID~=instanceID then
        portraitIndex = 2
    end
    
    if UnitInPhase(self.unit)~=true then
        portraitIndex =4
    end
    if UnitIsConnected(self.unit)~=true then
        portraitIndex = 3
    end

    if portraitIndex==1 then
        SetPortraitTexture(self.portrait, self.unit) 
        if self.portrait:GetTexture()==nil then
            portraitIndex = 2
        end
    else
        self.portrait:SetTexture(nil)
    end
	
	if GW_READY_CHECK_INPROGRESS==true then
     
        if self.ready == -1 then
            self.classicon:SetTexCoord(0,1,0,0.25)
        end
        if self.ready==false then
            self.classicon:SetTexCoord(0,1,0.25,0.50)
        end 
        if self.ready==true then
            self.classicon:SetTexCoord(0,1,0.50,0.75)
        end
        if not self.classicon:IsShown() then
            self.classicon:Show()
        end
    end
     

    gw_partyframe_setPortrait(self,portraitIndex)
end

function gw_update_partyFrameData(self)
    if not UnitExists(self.unit) then return end
    local health = UnitHealth(self.unit)
    local healthMax = UnitHealthMax(self.unit)
    local healthPrec = 0
    local power =   UnitPower(self.unit,UnitPowerType(self.unit))
    local powerMax =   UnitPowerMax(self.unit,UnitPowerType(self.unit))
    local powerPrecentage = 0
    powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
    if GW_PowerBarColorCustom[powerToken] then
        local pwcolor = GW_PowerBarColorCustom[powerToken]
        self.powerbar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end
    
    
    if powerMax>0 then
        powerPrecentage = power/powerMax
    end
    if healthMax>0 then
        healthPrec = health/healthMax
    end
    gwBar(self.healthbar,healthPrec)
    self.powerbar:SetValue(powerPrecentage)

    
    gw_update_awaydata(self)
    
    local nameRoleIcon = {}
    nameRoleIcon['TANK'] = '|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-tank:16:16:0:0|t '
    nameRoleIcon['HEALER'] = '|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-healer:16:16:0:0|t '
    nameRoleIcon['DAMAGER'] = '|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-dps:16:16:0:0|t '
    nameRoleIcon['NONE'] = ''
    
    local role = UnitGroupRolesAssigned(self.unit)
    local nameString = UnitName(self.unit)
    if nameRoleIcon[role]~=nil then
        nameString = nameRoleIcon[role]..nameString
    end
    
    self.name:SetText(nameString)
    
    self.level:SetText(UnitLevel(self.unit))
    
    localizedClass, englishClass, classIndex = UnitClass(self.unit);
    if classIndex~=nil and classIndex~=0 then
        gw_setClassIcon(self.classicon,classIndex)
    end
    
    gw_updatePartyFrameAuras(self,self.unit)
    
end






function gw_partyframe_setPortrait(self,index)
    self.portraitBackground:SetTexCoord(GW_PORTRAIT_BACKGROUND[index].l,GW_PORTRAIT_BACKGROUND[index].r,GW_PORTRAIT_BACKGROUND[index].t,GW_PORTRAIT_BACKGROUND[index].b)
end

function gw_updatePartyFrameAuras(self,unit)
    
    local x = 0;
    local y = 0;

    gw_getUnitBuffs(unit)
    local fname = self:GetName()

    for i=1,40 do
        local indexBuffFrame = _G['Gw'..unit..'BuffItemFrame'..i]
        if buffLists[unit][i] then
            local key = buffLists[unit][i]['key'];
            if indexBuffFrame==nil then
                indexBuffFrame = CreateFrame('Button',  'Gw'..unit..'BuffItemFrame'..i,_G[self:GetName()..'Auras'],'GwBuffIconBig');
                indexBuffFrame:SetParent(_G[fname..'Auras']);
                indexBuffFrame:SetSize(20,20)
            end
            local margin = -indexBuffFrame:GetWidth() + -2
            local marginy = indexBuffFrame:GetWidth() + 12
            _G['Gw'..unit..'BuffItemFrame'..i..'BuffIcon']:SetTexture(buffLists[unit][i]['icon'])
            _G['Gw'..unit..'BuffItemFrame'..i..'BuffIcon']:SetParent(_G['Gw'..unit..'BuffItemFrame'..i])
            local buffDur = '';
            local stacks = '';
            if buffLists[unit][i]['duration']>0 then
                buffDur = timeCount(buffLists[unit][i]['timeRemaining']);
                end
                  if buffLists[unit][i]['count']>1 then
                stacks = buffLists[unit][i]['count'] 
            end
            indexBuffFrame.expires =buffLists[unit][i]['expires']
            indexBuffFrame.duration =buffLists[unit][i]['duration']
            _G['Gw'..unit..'BuffItemFrame'..i..'BuffDuration']:SetText('')
            _G['Gw'..unit..'BuffItemFrame'..i..'BuffStacks']:SetText(stacks)
            indexBuffFrame:ClearAllPoints()
            indexBuffFrame:SetPoint('BOTTOMRIGHT',(-margin*x),marginy*y)
             
            indexBuffFrame:SetScript('OnEnter', function() GameTooltip:SetOwner(indexBuffFrame,"ANCHOR_BOTTOMLEFT",28,0); GameTooltip:ClearLines(); GameTooltip:SetUnitBuff(unit,key); GameTooltip:Show() end)
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
                indexBuffFrame:SetScript('OnEnter',nil)
                indexBuffFrame:SetScript('OnClick',nil) 
                indexBuffFrame:SetScript('OnLeave',nil) 
            end
        end
        
    end
    gw_updatePartyFrameDebuffs(self,unit,x,y)
    
end

function gw_updatePartyFrameDebuffs(self,unit,x,y)

    if x~=0 then
        y=y+1
    end
    x=0
    gw_getUnitDebuffs(unit)

    for i=1,40 do
        local indexBuffFrame = _G['Gw'..unit..'DebuffItemFrame'..i]
        if DebuffLists[unit][i] then
             
            local key = DebuffLists[unit][i]['key'];
            
            if indexBuffFrame==nil then
                indexBuffFrame = CreateFrame('Frame', 'Gw'..unit..'DebuffItemFrame'..i,_G[self:GetName()..'Auras'],'GwDeBuffIcon');
                indexBuffFrame:SetParent(_G[self:GetName()..'Auras']);
                
                _G['Gw'..unit..'DebuffItemFrame'..i..'DeBuffBackground']:SetVertexColor(GW_COLOR_FRIENDLY[2].r,GW_COLOR_FRIENDLY[2].g,GW_COLOR_FRIENDLY[2].b);
                _G['Gw'..unit..'DebuffItemFrame'..i..'Cooldown']:SetDrawEdge(0)
                _G['Gw'..unit..'DebuffItemFrame'..i..'Cooldown']:SetDrawSwipe(1)
                _G['Gw'..unit..'DebuffItemFrame'..i..'Cooldown']:SetReverse(1)
                _G['Gw'..unit..'DebuffItemFrame'..i..'Cooldown']:SetHideCountdownNumbers(true)
                indexBuffFrame:SetSize(24,24)
            end 
            _G['Gw'..unit..'DebuffItemFrame'..i..'IconBuffIcon']:SetTexture(DebuffLists[unit][i]['icon'])
            _G['Gw'..unit..'DebuffItemFrame'..i..'IconBuffIcon']:SetParent(_G['Gw'..unit..'DebuffItemFrame'..i])
            local buffDur = '';
            local stacks  = '';
            if DebuffLists[unit][i]['count']>1 then
               stacks = DebuffLists[unit][i]['count'] 
            end
            if DebuffLists[unit][i]['duration']>0 then
                buffDur = timeCount(DebuffLists[unit][i]['timeRemaining']);
            end
            indexBuffFrame.expires =DebuffLists[unit][i]['expires']
            indexBuffFrame.duration =DebuffLists[unit][i]['duration']
            
             _G['Gw'..unit..'DebuffItemFrame'..i..'DeBuffBackground']:SetVertexColor(GW_COLOR_FRIENDLY[2].r,GW_COLOR_FRIENDLY[2].g,GW_COLOR_FRIENDLY[2].b);
                if DebuffLists[unit][i]['dispelType']~=nil and GW_DEBUFF_COLOR[DebuffLists[unit][i]['dispelType']]~=nil then
                     _G['Gw'..unit..'DebuffItemFrame'..i..'DeBuffBackground']:SetVertexColor( GW_DEBUFF_COLOR[DebuffLists[unit][i]['dispelType']].r, GW_DEBUFF_COLOR[DebuffLists[unit][i]['dispelType']].g, GW_DEBUFF_COLOR[DebuffLists[unit][i]['dispelType']].b)
                end

            _G['Gw'..unit..'DebuffItemFrame'..i..'CooldownBuffDuration']:SetText(buffDur)
            _G['Gw'..unit..'DebuffItemFrame'..i..'IconBuffStacks']:SetText(stacks)
            indexBuffFrame:ClearAllPoints()
            indexBuffFrame:SetPoint('BOTTOMRIGHT',(26*x),26*y)
            
            indexBuffFrame:SetScript('OnEnter', function() GameTooltip:SetOwner(indexBuffFrame, "ANCHOR_BOTTOMLEFT"); GameTooltip:ClearLines(); GameTooltip:SetUnitDebuff(unit,key); GameTooltip:Show() end)
            indexBuffFrame:SetScript('OnLeave', function() GameTooltip:Hide() end)
            
            indexBuffFrame:Show()
            
            x=x+1
            if x>8 then
                y=y+1
                x=0
            end
            
        else
            
            if indexBuffFrame~=nil then
                indexBuffFrame:Hide() 
            end
        end
        
    end
    
end

function gw_getUnitBuffs(unit)
   
    buffLists[unit] = {}
    for i=1,40 do
        if  UnitBuff(unit,i) then
            buffLists[unit][i] ={}
    buffLists[unit][i]['name'],  buffLists[unit][i]['rank'],  buffLists[unit][i]['icon'],  buffLists[unit][i]['count'],  buffLists[unit][i]['dispelType'],  buffLists[unit][i]['duration'],  buffLists[unit][i]['expires'],  buffLists[unit][i]['caster'],  buffLists[unit][i]['isStealable'],  buffLists[unit][i]['shouldConsolidate'],  buffLists[unit][i]['spellID']  =  UnitBuff(unit,i) 
             buffLists[unit][i]['key'] = i
            buffLists[unit][i]['timeRemaining'] =  buffLists[unit][i]['expires']-GetTime();
            if buffLists[unit][i]['duration']<=0 then
                  buffLists[unit][i]['timeRemaining'] = 500000
            end    
        end
    end
    

    table.sort( buffLists[unit], function(a,b) return a['timeRemaining'] > b['timeRemaining'] end)
    
end
function gw_getUnitDebuffs(unit)

    DebuffLists[unit] = {}
    for i=1,40 do
       
        if  UnitDebuff(unit,i)  then
           
            DebuffLists[unit][i] ={}
            DebuffLists[unit][i]['name'],  DebuffLists[unit][i]['rank'],  DebuffLists[unit][i]['icon'],  DebuffLists[unit][i]['count'],  DebuffLists[unit][i]['dispelType'],  DebuffLists[unit][i]['duration'],  DebuffLists[unit][i]['expires'],  DebuffLists[unit][i]['caster'],  DebuffLists[unit][i]['isStealable'],  DebuffLists[unit][i]['shouldConsolidate'],  DebuffLists[unit][i]['spellID']  =  UnitDebuff(unit,i)
            DebuffLists[unit][i]['key'] = i
            DebuffLists[unit][i]['timeRemaining'] =  DebuffLists[unit][i]['expires']-GetTime();
            if DebuffLists[unit][i]['duration']<=0 then
                  DebuffLists[unit][i]['timeRemaining'] = 500000
            end    
        end
    end
    

    table.sort( DebuffLists[unit], function(a,b) return a['timeRemaining'] < b['timeRemaining'] end)
    
end
