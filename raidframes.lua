local GROUPD_TYPE = 'PARTY'


function gw_raidframe_hideBlizzard()
    CompactRaidFrameManager:UnregisterAllEvents()
    CompactRaidFrameManager:Hide()
    CompactRaidFrameContainer:UnregisterAllEvents() 
    CompactRaidFrameContainer:Hide()
end

function gw_register_raidframes()
    gw_raidframe_hideBlizzard()
    CreateFrame('Frame','GwRaidFrameContainer',UIParent,'GwRaidFrameContainer')
    
    GwRaidFrameContainer:SetPoint(gwGetSetting('raid_pos')['point'],UIParent,gwGetSetting('raid_pos')['relativePoint'],gwGetSetting('raid_pos')['xOfs'],gwGetSetting('raid_pos')['yOfs'])
    
    gw_register_movable_frame('GwRaidFrameContainerFrame',GwRaidFrameContainer,'raid_pos','VerticalActionBarDummy')

  
    gw_create_raidframe('player') 
    for i=1,4 do
       gw_create_raidframe('party'..i) 
    end
    
    for i=1,80 do
       gw_create_raidframe('raid'..i) 
    end
    gw_raidframes_update_layout()
    
    if gwGetSetting('RAID_STYLE_PARTY')==false then
        UnregisterUnitWatch(_G['GwCompactplayer'])
        _G['GwCompactplayer']:Hide()
        for i=1,4 do      
            UnregisterUnitWatch(_G['GwCompactparty'..i])
            _G['GwCompactparty'..i]:Hide()
        end
    end
    
end

function gw_create_raidframe(registerUnit)
    
    local frame = _G['GwCompact'..registerUnit]
    if _G['GwCompact'..registerUnit]==nil then
        frame = CreateFrame('Button','GwCompact'..registerUnit,GwRaidFrameContainer,'GwRaidFrame')
    end
    
    frame.unit=registerUnit
    
    frame.healthbar.animationName ='GwCompact'..registerUnit..'animation'
    frame.healthbar.animationValue = 0
    
    frame:SetAttribute("unit", registerUnit);
    frame:SetAttribute("*type1", 'target')
    frame:SetAttribute("*type2", "togglemenu")

    RegisterUnitWatch(frame);
    frame:EnableMouse(true)
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")    
    
    
    frame:RegisterEvent('UNIT_HEALTH')
    frame:RegisterEvent('UNIT_HEALTH_MAX')
    frame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    frame:RegisterEvent("UNIT_POWER");
    frame:RegisterEvent("UNIT_MAX_POWER");
    frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
    frame:RegisterEvent("RAID_ROSTER_UPDATE");
    frame:RegisterEvent("GROUP_ROSTER_UPDATE");
    frame:RegisterEvent("UNIT_PHASE");
    frame:RegisterEvent("PARTY_MEMBER_DISABLE");
    frame:RegisterEvent("PARTY_MEMBER_ENABLE");
    frame:RegisterEvent("UNIT_AURA");
    frame:RegisterEvent("UNIT_LEVEL");
    frame:RegisterEvent("PLAYER_TARGET_CHANGED");
    frame:RegisterEvent("PARTY_CONVERTED_TO_RAID");
    frame:SetScript('OnEvent',gw_raidframe_OnEvent)
    
    frame:SetScript('OnUpdate',gw_raidFrame_OnUpdate)
    
end

function gw_toggle_partyframes_for_use(b)
    
    if InCombatLockdown() then return end
    
    if b==true then
        if gwGetSetting('RAID_STYLE_PARTY') then
            RegisterUnitWatch(_G['GwCompactplayer']) 
                RegisterUnitWatch(frame);
                _G['GwCompactplayer']:Show()
            for i=1,4 do
                RegisterUnitWatch(_G['GwCompactparty'..i]) 
                _G['GwCompactparty'..i]:Show()
            end
        end
        gw_toggle_partyRaid(true)
    else
        gw_toggle_partyRaid(false)
        UnregisterUnitWatch(_G['GwCompactplayer'])
        _G['GwCompactplayer']:Hide()
        for i=1,4 do
          
            UnregisterUnitWatch(_G['GwCompactparty'..i])
            _G['GwCompactparty'..i]:Hide()
        end
    end
    
    
end

function gw_raidframe_OnEvent(self,event,unit)
    
    if not UnitExists(self.unit) then return end
    if event=='UNIT_HEALTH' or event=='UNIT_MAX_HEALTH' and unit==self.unit then
        local health = UnitHealth(self.unit)
        local healthMax = UnitHealthMax(self.unit)
        local healthPrec = 0
        if healthMax>0 then
            healthPrec = health/healthMax
        end
        gwBar(self.healthbar,healthPrec)
    end
    
    if event=='UNIT_ABSORB_AMOUNT_CHANGED' and unit==self.unit then
        local healthMax = UnitHealthMax(unitToWatch)
        local absorb = UnitGetTotalAbsorbs(unitToWatch)
    
        local absorbPrecentage = 0
        
        if absorb>0 and healthMax>0 then
            absorbPrecentage = absorb/healthMax
        end
        self.healthbar.absorbbar:SetValue(absorbPrecentage)
    end
    if event=='UNIT_PHASE' or event=='PARTY_MEMBER_DISABLE' or event=='PARTY_MEMBER_ENABLE'  then
       gw_update_raidframe_awayData(self)
    end 
    
    if event=='PARTY_MEMBERS_CHANGED' or event=='UNIT_LEVEL' or event=='GROUP_ROSTER_UPDATE' or event=='RAID_ROSTER_UPDATE' then
        
        if IsInRaid()==false and GROUPD_TYPE=='RAID' then
            gw_toggle_partyframes_for_use(true)
            GROUPD_TYPE='PARTY'
        end
        if  IsInRaid() and GROUPD_TYPE=='PARTY' then
            gw_toggle_partyframes_for_use(false)
            GROUPD_TYPE='RAID'
        end
        
        gw_update_raidframeData(self)
        gw_raidframes_update_layout()
    end
    
    if event=='PLAYER_TARGET_CHANGED' then
       gw_highlight_target_raidframe()
    end
    

    if event=='PARTY_CONVERTED_TO_RAID' and GROUPD_TYPE=='PARTY' then
        gw_toggle_partyframes_for_use(false)
        GROUPD_TYPE='RAID'
    end
    
    
    
end

function gw_highlight_target_raidframe(self)
    
    local  guid = UnitGUID('target')
    
    if guid==_G['GwCompactplayer'].guid then
        _G['GwCompactplayer'].targetHighlight:SetVertexColor(1,1,1,1)
    else
        _G['GwCompactplayer'].targetHighlight:SetVertexColor(0,0,0,1)
    end 

  
    for i=1,80 do 
        
        if i<5 then
           if guid==_G['GwCompactparty'..i].guid then
            _G['GwCompactparty'..i].targetHighlight:SetVertexColor(1,1,1,1)
            else
            _G['GwCompactparty'..i].targetHighlight:SetVertexColor(0,0,0,1)
            end 
        end
        
        if guid==_G['GwCompactraid'..i].guid then
        _G['GwCompactraid'..i].targetHighlight:SetVertexColor(1,1,1,1)
        else
        _G['GwCompactraid'..i].targetHighlight:SetVertexColor(0,0,0,1)
        end
        
    end
    
    
end


function gw_update_raidframeData(self)    
   if not UnitExists(self.unit) then return end
    
    self.guid = UnitGUID(self.unit)
    
   
    local health = UnitHealth(self.unit)
    local healthMax = UnitHealthMax(self.unit)
    local healthPrec = 0
    local absorb = UnitGetTotalAbsorbs(unitToWatch)
    local absorbPrecentage = 0
        
    if healthMax>0 then
        healthPrec = health/healthMax
    end
       
    if absorb>0 and healthMax>0 then
        absorbPrecentage = absorb/healthMax
    end
    
     gwBar(self.healthbar,healthPrec)
    self.healthbar.absorbbar:SetValue(absorbPrecentage)
    
    local nameRoleIcon = {}
    nameRoleIcon['TANK'] = '|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-tank:12:12:0:0|t '
    nameRoleIcon['HEALER'] = '|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-healer:12:12:0:0|t '
    nameRoleIcon['DAMAGER'] = '|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-dps:12:12:0:0|t '
    nameRoleIcon['NONE'] = ''
    
    local role = UnitGroupRolesAssigned(self.unit)
    local nameString = UnitName(self.unit)
    if nameRoleIcon[role]~=nil then
        nameString = nameRoleIcon[role]..nameString
    end
    
    self.name:SetText(nameString)
   
    gw_highlight_target_raidframe()
    
    gw_update_raidframe_awayData(self)
    
    
end

function gw_raidFrame_OnUpdate(self)
    if not UnitExists(self.unit) then return end
    if self.onUpdateDelay==nil then self.onUpdateDelay=0 end
    if self.onUpdateDelay>GetTime() then return end
    self.onUpdateDelay = GetTime()+0.2
    gw_update_raidframe_awayData(self)
    
end

function gw_update_raidframe_awayData(self)
     
    local classColor = gwGetSetting('RAID_CLASS_COLOR')
    
    localizedClass, englishClass, classIndex = UnitClass(self.unit);
    if classIndex~=nil and classIndex~=0 and classColor==false then
        gw_setClassIcon(self.classicon,classIndex)
    end
    if classColor==true and classIndex~=nil and classIndex~=0 then
        self.healthbar:SetStatusBarColor(GW_CLASS_COLORS_RAIDFRAME[classIndex].r,GW_CLASS_COLORS_RAIDFRAME[classIndex].g,GW_CLASS_COLORS_RAIDFRAME[classIndex].b,1)
        self.classicon:SetTexture(nil)
       
    else
        self.healthbar:SetStatusBarColor(0.207,0.392,0.168)
        if self.classicon:GetTexture()==nil then
            self.classicon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\party\\classicons')
        end
    end
    
    
    if UnitIsConnected(self.unit)~=true then
        self.healthbar:SetStatusBarColor(0.3,0.3,0.3,1)
    end
    
    if UnitIsDeadOrGhost(self.unit) then
       
        self.classicon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\party\\icon-dead')
        self.classicon:SetTexCoord(0,1,0,1)
    end
    
    
    
    if UnitInPhase(self.unit)~=true or UnitInRange(self.unit)~=true then
        local r,g,b = self.healthbar:GetStatusBarColor()
        r = r*0.3
        b = b*0.3
        g = g*0.3
        self.healthbar:SetStatusBarColor(r,g,b)
    end
     

    
end

function gw_raidframes_update_layout()
    
    if InCombatLockdown() then return end

    
    local WIDTH = gwGetSetting('RAID_WIDTH')
    local HEIGHT =  gwGetSetting('RAID_HEIGHT')
    local MARGIN = 2
    local WINDOW_SIZE = GwRaidFrameContainer:GetHeight()
    
    local USED_WIDTH = 0
    local USED_HEIGHT = 0
    
    local sorted = gw_raidframes_sortByRole()
    
   for k,v in pairs(sorted) do
        
        _G['GwCompact'..v]:SetPoint('TOPLEFT',GwRaidFrameContainer,'TOPLEFT',USED_WIDTH,-USED_HEIGHT);
        _G['GwCompact'..v]:SetSize(WIDTH,HEIGHT)
        _G['GwCompact'..v].healthbar.spark:SetHeight(_G['GwCompact'..v].healthbar:GetHeight())
               
        
        USED_HEIGHT = USED_HEIGHT + HEIGHT + MARGIN
        
        if (USED_HEIGHT + HEIGHT + MARGIN)>WINDOW_SIZE then
            USED_HEIGHT = 0
            USED_WIDTH = USED_WIDTH + WIDTH +MARGIN
        end
        
    end    
    

    
    for i=1,80 do
        
        local frameHasBeenPlace = false
        
        for k,v in pairs(sorted) do
            local n = 'GwCompactraid'..i
            local np = 'GwCompactparty'..i
            local sn = 'GwCompact'..v
            if n==sn or np==sn then
                frameHasBeenPlace = true
            end
        end
        if not frameHasBeenPlace then
            
            if i<5 then
                _G['GwCompactparty'..i]:SetPoint('TOPLEFT',GwRaidFrameContainer,'TOPLEFT',USED_WIDTH,-USED_HEIGHT);
                _G['GwCompactparty'..i]:SetSize(WIDTH,HEIGHT)
                _G['GwCompactparty'..i].healthbar.spark:SetHeight(_G['GwCompactparty'..i].healthbar:GetHeight())
            end
            _G['GwCompactraid'..i]:SetPoint('TOPLEFT',GwRaidFrameContainer,'TOPLEFT',USED_WIDTH,-USED_HEIGHT);
            _G['GwCompactraid'..i]:SetSize(WIDTH,HEIGHT)
            _G['GwCompactraid'..i].healthbar.spark:SetHeight(_G['GwCompactraid'..i].healthbar:GetHeight())

            USED_HEIGHT = USED_HEIGHT + HEIGHT + MARGIN
        
        if (USED_HEIGHT + HEIGHT + MARGIN)>WINDOW_SIZE then
            USED_HEIGHT = 0
            USED_WIDTH = USED_WIDTH + WIDTH +MARGIN
        end
        end
    end
    
end

function gw_raidframes_sortByRole()
    
    local sorted_array={}
    
    local roleIndex = {}
    roleIndex[1]= 'TANK'
    roleIndex[2]= 'HEALER'
    roleIndex[3]= 'DAMAGER'
    roleIndex[4]= 'NONE'
    
    local unitString = 'raid'
    local maxIteration = 80
    if not IsInRaid() then
        unitString = 'party'
        maxIteration = 4    
    end
    
    
    
    for k,v in pairs(roleIndex) do
        
        if unitString=='party' then
            local role = UnitGroupRolesAssigned('player')
            if role==v then
                sorted_array[countTable(sorted_array)+1] = 'player'
            end
        end
        
        for i=1,80 do 
            if  UnitExists(unitString..i) then
                local role = UnitGroupRolesAssigned(unitString..i)
                if role==v then
                    sorted_array[countTable(sorted_array)+1] = unitString..i
                end
            end
        end
    end
    return sorted_array
end



