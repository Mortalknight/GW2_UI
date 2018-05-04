
local function updateHealthTextString(self,health,healthPrecentage)
       
        local healthString = ''
            
        if self.showHealthValue==true then
            healthString = comma_value(health)
        end
        if self.showHealthValue==true and self.showHealthPrecentage ==true then healthString= healthString..' - ' end
            
        if self.showHealthPrecentage ==true then
            healthString = healthString..comma_value(healthPrecentage*100)..'%'
        end            
            
        self.healthString:SetText(healthString) 
end


local function updateHealthbarColor(self)
   
    if self.classColor == true and UnitIsPlayer(self.unit) then
        local _, _, classIndex = UnitClass(self.unit)
        self.healthbar:SetVertexColor(GW_CLASS_COLORS_RAIDFRAME[classIndex].r,GW_CLASS_COLORS_RAIDFRAME[classIndex].g,GW_CLASS_COLORS_RAIDFRAME[classIndex].b,1)
        self.healthbarSpark:SetVertexColor(GW_CLASS_COLORS_RAIDFRAME[classIndex].r,GW_CLASS_COLORS_RAIDFRAME[classIndex].g,GW_CLASS_COLORS_RAIDFRAME[classIndex].b,1)
        self.healthbarFlash:SetVertexColor(GW_CLASS_COLORS_RAIDFRAME[classIndex].r,GW_CLASS_COLORS_RAIDFRAME[classIndex].g,GW_CLASS_COLORS_RAIDFRAME[classIndex].b,1)
        self.healthbarFlashSpark:SetVertexColor(GW_CLASS_COLORS_RAIDFRAME[classIndex].r,GW_CLASS_COLORS_RAIDFRAME[classIndex].g,GW_CLASS_COLORS_RAIDFRAME[classIndex].b,1)
        
        self.nameString:SetTextColor(GW_CLASS_COLORS_RAIDFRAME[classIndex].r,GW_CLASS_COLORS_RAIDFRAME[classIndex].g,GW_CLASS_COLORS_RAIDFRAME[classIndex].b,1)
        
        local r,g,b,a = self.nameString:GetTextColor()
        self.nameString:SetTextColor(r+0.3,g+0.3,b+0.3,1)
        
    else
    
        local isFriend = UnitIsFriend("player",self.unit);
        local friendlyColor = GW_COLOR_FRIENDLY[1]

        if isFriend~=true then
            friendlyColor = GW_COLOR_FRIENDLY[2]
        end
        if UnitIsTapDenied('player') then
            friendlyColor = GW_COLOR_FRIENDLY[3]
        end

        self.healthbar:SetVertexColor(friendlyColor.r,friendlyColor.g,friendlyColor.b,1)
        self.healthbarSpark:SetVertexColor(friendlyColor.r,friendlyColor.g,friendlyColor.b,1)
        self.healthbarFlash:SetVertexColor(friendlyColor.r,friendlyColor.g,friendlyColor.b,1)
        self.healthbarFlashSpark:SetVertexColor(friendlyColor.r,friendlyColor.g,friendlyColor.b,1)
        self.nameString:SetTextColor(friendlyColor.r,friendlyColor.g,friendlyColor.b,1)
    end
    
    if  ( UnitLevel(self.unit) - UnitLevel('player'))<=-5 then
        local r,g,b,a = self.nameString:GetTextColor()
        self.nameString:SetTextColor(r+0.5,g+0.5,b+0.5,1)
    end
    
end



local function healthBarAnimation(self,powerPrec)
            
    local powerBarWidth = self.barWidth
    local bit = powerBarWidth/12        
    local spark = bit * math.floor(12 * (powerPrec))
    local spark_current = (bit * (12 * (powerPrec)) - spark) / bit 
    local round_closest = (spark/powerBarWidth)
            
            
    local bI = math.min(16,math.max(1,math.floor(17 - (16*spark_current))))
         
    self.healthbarFlashSpark:SetTexCoord(bloodSpark[bI].left,bloodSpark[bI].right,bloodSpark[bI].top,bloodSpark[bI].bottom)          self.healthbarFlashSpark:SetPoint('LEFT',self.healthbarBackground,'LEFT',math.max(0,math.min(powerBarWidth - bit, math.floor(spark))),0)
    self.healthbarFlash:SetPoint('RIGHT',self.healthbarBackground,'LEFT',math.max(0,math.min(powerBarWidth,spark))+1,0) 
end
local function healthBarAnimationNormal(self,powerPrec)
            
    local powerBarWidth = self.barWidth
    local bit = powerBarWidth/12        
    local spark = bit * math.floor(12 * (powerPrec))
    local spark_current = (bit * (12 * (powerPrec)) - spark) / bit 
    local round_closest = (spark/powerBarWidth)
            
            
    local bI = math.min(16,math.max(1,math.floor(17 - (16*spark_current))))
         
    self.healthbarSpark:SetTexCoord(bloodSpark[bI].left,bloodSpark[bI].right,bloodSpark[bI].top,bloodSpark[bI].bottom)          self.healthbarSpark:SetPoint('LEFT',self.healthbarBackground,'LEFT',math.max(0,math.min(powerBarWidth - bit, math.floor(spark))),0)
    self.healthbar:SetPoint('RIGHT',self.healthbarBackground,'LEFT',math.max(0,math.min(powerBarWidth,spark))+2,0) 
end

local function setUnitPortraitFrame(self,event)
    
    if self.portrait==nil or self.background==nil then return end
    
    local border = 'normal'
    
    local unitClassIfication = UnitClassification(self.unit)
    
    if GW_TARGET_FRAME_ART[unitClassIfication]~=nil then
        border = unitClassIfication
    end
    
    if (UnitPrestige(self.unit)~=nil and UnitPrestige(self.unit)>0)   then
        local p = UnitPrestige(self.unit)
        if p > 4 then 
			plvl = 4 
		else
			plvl = p
		end
        key = 'prestige'..plvl
        if GW_TARGET_FRAME_ART[key]~=nil then
            border = key
        end
             
        self.prestigebg:Show()
        self.prestigeString:Show()
        self.prestigeString:SetText(p)
        
    else
        self.prestigebg:Hide()
        self.prestigeString:Hide() 
    end
    
    self.background:SetTexture(GW_TARGET_FRAME_ART[border])
    
    

end

local function updateRaidMarkers(self,event)
    
    local i = GetRaidTargetIndex(self.unit);
    if i==nil then self.raidmarker:SetTexture(nil) return end
    self.raidmarker:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..i)
end


local function setUnitPortrait(self,evnt)
    if self.portrait==nil then return end
    SetPortraitTexture(self.portrait, self.unit) 
    self.activePortrait = '';
end


local function unitFrameData(self,event)
    
    local level = UnitLevel(self.unit)
    if level == -1 then level = '??'end
    
    
    local name = ''
    name = UnitName(self.unit)
    
    if UnitIsGroupLeader(self.unit) then
        name = '|TInterface\\AddOns\\GW2_UI\\textures\\party\\icon-groupleader:18:18|t'..name
    end
    
    
    self.nameString:SetText(name)
    self.levelString:SetText(level)
    
    updateHealthbarColor(self)
    
    
    
    setUnitPortraitFrame(self,event)
    
    
end


local function normalCastBarAnimation(self, powerPrec)
    local powerBarWidth = self.barWidth
    self.castingbarNormal:SetWidth(math.min(powerBarWidth,math.max(1,powerBarWidth*powerPrec)))
    self.castingbarNormal:SetTexCoord(0,powerPrec,0.25,0.5)
    self.castingbarNormalSpark:SetWidth( math.max(1,math.min(16,16*(powerPrec/0.10))) )
end

local function protectedCastAnimation(self, powerPrec)
    
    local powerBarWidth = self.barWidth
    local bit = powerBarWidth/16  
    local spark = bit * math.floor(16 * (powerPrec))
    local segment = math.floor(16 * (powerPrec))
    local sparkPoint = (powerBarWidth * powerPrec) - 20
            
    local spark_current = (bit * (16 * (powerPrec)) - spark) / bit 

            
            
    local bI = math.min(7,math.max(1,intRound(7*spark_current)))
            
    self.castingbarSpark:SetWidth(math.min(32,32*(powerPrec/0.10)))
    self.castingbarSpark:SetPoint('LEFT',self.castingbar,'LEFT',math.max(0,sparkPoint),0)
                
    self.castingbar:SetTexCoord(0,math.min(1,math.max(0,0.0625*segment)),0,1)
    self.castingbar:SetWidth(math.min(powerBarWidth,math.max(1,spark)))
        
end


local function hideCastBar(self,event)
    
    self.castingbarBackground:Hide()
    self.castingString:Hide()
    
    self.castingbar:Hide()
    self.castingbarSpark:Hide()
    
    self.castingbarNormal:Hide()
    self.castingbarNormalSpark:Hide()
    
    self.castingbarBackground:SetPoint('TOPLEFT',self.powerbarBackground,'BOTTOMLEFT',-2,19);
    
    
    
    if self.portrait~=nil then
        setUnitPortrait(self,event)
    end
    
    if animations['GwUnitFrame'..self.unit..'Cast']~=nil then
        animations['GwUnitFrame'..self.unit..'Cast']['completed'] = true
        animations['GwUnitFrame'..self.unit..'Cast']['duration'] = 0
    end
    
end

local function updateCastValues(self,event)
    
    local castType = 1
    
    local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(self.unit)
    
    if name==nil then
        name, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(self.unit)
        castType = 0
    end
    
    if name==nil then
        hideCastBar(self,event)
        return
    end
    
    startTime = startTime /1000
    endTime = endTime /1000
    
    self.castingString:SetText(name)
    
   if texture~=nil and self.portrait~=nil and (self.activePortrait==nil or self.activePortrait~=texture) then 
        self.portrait:SetTexture(texture)
        self.activePortrait = texture;
    end
    
    self.castingbarBackground:Show()
    self.castingbarBackground:SetPoint('TOPLEFT',self.powerbarBackground,'BOTTOMLEFT',-2,-1);
    self.castingString:Show()
    
    if notInterruptible then
        self.castingbarNormal:Hide()
        self.castingbarNormalSpark:Hide()
        
        self.castingbar:Show()
        self.castingbarSpark:Show()
        
    else
        self.castingbar:Hide()
        self.castingbarSpark:Hide()
        
        self.castingbarNormal:Show()
        self.castingbarNormalSpark:Show()
    end
    
    
    addToAnimation('GwUnitFrame'..self.unit..'Cast',0,1,startTime,endTime - startTime,function(step)
          
        if castType==0 then
            step = 1 - step
        end
        if notInterruptible then
            protectedCastAnimation(self,step)
        else
            normalCastBarAnimation(self,step)
        end
            
            
    end,'noease')
    
    
    
    
end



local function updatePowerValues(self,event)
    
    local powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
    local power =   UnitPower(self.unit,powerType)
    local powerMax =   UnitPowerMax(self.unit,powerType)
    local powerPrecentage = 0
    
    if power>0 and powerMax>0 then
        powerPrecentage = power/powerMax
    end
    
    if power<=0 then 
        self.powerbarBackground:Hide()
        self.powerbar:Hide()
    else
        self.powerbarBackground:Show()
        self.powerbar:Show()
    end
    
   
    if GW_PowerBarColorCustom[powerToken] then
        local pwcolor = GW_PowerBarColorCustom[powerToken]
        self.powerbar:SetVertexColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end
    
    
    self.powerbar:SetWidth(math.min( self.barWidth,math.max(1,self.barWidth*powerPrecentage)))
    
    
end

local function setAbsorbValue(self,absorb,absorbPrecentage,healthPrecentage,health,healthMax)
    
    local absorbAmount = healthPrecentage + absorbPrecentage 
    local absorbAmount2 = absorbPrecentage - (1 - healthPrecentage)
    
    self.absorbbarbg:SetWidth(math.min( self.barWidth,math.max(1,self.barWidth*absorbAmount)))
    self.absorbbar:SetWidth(math.min( self.barWidth,math.max(1,self.barWidth*absorbAmount2)))
    
    self.absorbbarbg:SetTexCoord(0,math.min(1,1*absorbAmount),0,1)
    self.absorbbar:SetTexCoord(0,math.min(1,1*absorbAmount),0,1)
    
    
    self.absorbbarbg:SetAlpha( math.max(0,math.min(1,(1*(absorbPrecentage/0.1)) )) )
    self.absorbbar:SetAlpha( math.max(0,math.min(1,(1*(absorbPrecentage/0.1)) )) )
end


local function updateHealthValues(self,event)
    
    local health = UnitHealth(self.unit)
    local healthMax = UnitHealthMax(self.unit)
    local healthPrecentage = 0
    local absorb = UnitGetTotalAbsorbs(self.unit)
    local absorbPrecentage = 0
    
    if health>0 and healthMax>0 then
        healthPrecentage = health/healthMax 
    end
    
    if absorb>0 and healthMax>0 then
        absorbPrecentage = absorb/healthMax
    end
    
    if self.healthTextThroth==nil then self.healthTextThroth=0 end
    
    local animationSpeed = dif(self.healthValue, healthPrecentage)
    animationSpeed = math.min(1.00,math.max(0.2,2.00 * animationSpeed))
    

    if event=='UNIT_TARGET_CHANGED' or event=='FOCUS_TARGET_CHANGED' or event=='PLAYER_TARGET_CHANGED' then
        animationSpeed = 0
    end

    setAbsorbValue(self,absorb,absorbPrecentage,healthPrecentage,health,healthMax)
    
    healthBarAnimationNormal(self,healthPrecentage)
    
    addToAnimation(self:GetName()..self.unit,self.healthValue,healthPrecentage,GetTime(),animationSpeed,function(step)

         healthBarAnimation(self,step)
            
        if self.healthTextThroth<GetTime() then
            self.healthTextThroth = GetTime() + 0.1
            updateHealthTextString(self,healthMax*step,step)
        end
        self.healthValue = step
            
    end,nil,function() 
        
        updateHealthTextString(self,health,healthPrecentage)
           
    end)
    
end



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
            frame:SetPoint('CENTER', self.auras,'TOPLEFT',usedWidth + (size/2),-usedHeight - (size/2) )
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
local function target_OnEvent(self,event,unit)
    
    if event=='PLAYER_TARGET_CHANGED' or event=='ZONE_CHANGED' then
        self.stepOnUpdate = 0
        self:SetScript('OnUpdate',function() 
                self.stepOnUpdate = self.stepOnUpdate + 1
                
                
                if self.stepOnUpdate==1 then updateHealthValues(self,event) return end
                if self.stepOnUpdate==2 then unitFrameData(self,event)  return end
                if self.stepOnUpdate==3 then updatePowerValues(self,event)  return end
                if self.stepOnUpdate==4 then      updateCastValues(self,event)  return end
                if self.stepOnUpdate==5 then     updateRaidMarkers(self,event)  return end
                if self.stepOnUpdate==6 then      updateBuffLayout(self,event)  return end
            
                if self.stepOnUpdate==7 then      self:SetScript('OnUpdate',nil)  return end
               
            end)

        return
    end
    
    if (event=='UNIT_HEALTH' or event=='UNIT_MAXHEALTH' or event=='UNIT_ABSORB_AMOUNT_CHANGED') and unit==self.unit then
        updateHealthValues(self,event)
        return
    end
    
    if (event=='UNIT_MAXPOWER' or event=='UNIT_POWER') and unit==self.unit then
        updatePowerValues(self,event)
        return
    end
    
    if (event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START') and unit==self.unit then
        updateCastValues(self,event)
        return
    end
    
    if (event=='UNIT_SPELLCAST_CHANNEL_STOP' or event=='UNIT_SPELLCAST_STOP' or event=='UNIT_SPELLCAST_INTERRUPTED' or event=='UNIT_SPELLCAST_FAILED') and unit==self.unit then
        hideCastBar(self,event)
        return
    end
    
    if event=='RAID_TARGET_UPDATE' then
       updateRaidMarkers(self,event) 
    end
    
    if event=='UNIT_AURA' and unit==self.unit then
       updateBuffLayout(self,event) 
    end
    
end

local function focus_OnEvent(self,event,unit)
    
    if event=='PLAYER_FOCUS_CHANGED' or event=='ZONE_CHANGED' then
           self.stepOnUpdate = 0
        self:SetScript('OnUpdate',function() 
                self.stepOnUpdate = self.stepOnUpdate + 1
                
                
                if self.stepOnUpdate==1 then updateHealthValues(self,event) return end
                if self.stepOnUpdate==2 then unitFrameData(self,event)  return end
                if self.stepOnUpdate==3 then updatePowerValues(self,event)  return end
                if self.stepOnUpdate==4 then      updateCastValues(self,event)  return end
                if self.stepOnUpdate==5 then     updateRaidMarkers(self,event)  return end
                if self.stepOnUpdate==6 then      updateBuffLayout(self,event)  return end
            
                if self.stepOnUpdate==7 then      self:SetScript('OnUpdate',nil)  return end
               
            end)
        return
    end
    
    if (event=='UNIT_HEALTH' or event=='UNIT_MAXHEALTH' or event=='UNIT_ABSORB_AMOUNT_CHANGED') and unit==self.unit then
        updateHealthValues(self,event)
        return
    end
    
    if (event=='UNIT_MAXPOWER' or event=='UNIT_POWER') and unit==self.unit then
        updatePowerValues(self,event)
        return
    end
    
    if (event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START') and unit==self.unit then
        updateCastValues(self,event)
        return
    end
    
    if (event=='UNIT_SPELLCAST_CHANNEL_STOP' or event=='UNIT_SPELLCAST_STOP' or event=='UNIT_SPELLCAST_INTERRUPTED' or event=='UNIT_SPELLCAST_FAILED') and unit==self.unit then
        hideCastBar(self,event)
        return
    end
    
    if event=='RAID_TARGET_UPDATE' then
       updateRaidMarkers(self,event) 
    end
    
    if event=='UNIT_AURA' and unit==self.unit then
       updateBuffLayout(self,event) 
    end
    
end

local function targettarget_OnEvent(self,event,unit,arg2)
    
    if  not UnitExists(self.unit) then return end
    
    if (event=='UNIT_TARGET' and unit=='target') or event=='PLAYER_TARGET_CHANGED' or event=='ZONE_CHANGED' then
      self.stepOnUpdate = 0
        self:SetScript('OnUpdate',function() 
                self.stepOnUpdate = self.stepOnUpdate + 1
                
                
                if self.stepOnUpdate==1 then updateHealthValues(self,event) return end
                if self.stepOnUpdate==2 then unitFrameData(self,event)  return end
                if self.stepOnUpdate==3 then updatePowerValues(self,event)  return end
                if self.stepOnUpdate==4 then      updateCastValues(self,event)  return end
                if self.stepOnUpdate==5 then     updateRaidMarkers(self,event)  return end
              
            
                if self.stepOnUpdate==6 then      self:SetScript('OnUpdate',nil)  return end
               
            end)
        return
    end

    if (event=='UNIT_HEALTH' or event=='UNIT_MAXHEALTH' or event=='UNIT_ABSORB_AMOUNT_CHANGED')  then
        
        updateHealthValues(self,event)
        return
    end
    
    if (event=='UNIT_MAXPOWER' or event=='UNIT_POWER')  then
        updatePowerValues(self,event)
        return
    end
    
    if (event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START')  then
        updateCastValues(self,event)
        return
    end
    
    if (event=='UNIT_SPELLCAST_CHANNEL_STOP' or event=='UNIT_SPELLCAST_STOP' or event=='UNIT_SPELLCAST_INTERRUPTED' or event=='UNIT_SPELLCAST_FAILED')  then
        hideCastBar(self,event)
        return
    end
    
    if event=='RAID_TARGET_UPDATE' then
       updateRaidMarkers(self,event) 
    end

    
end
local function focustarget_OnEvent(self,event,unit,arg2)
    
    if  not UnitExists(self.unit) then return end
    
    if (event=='UNIT_TARGET' and unit=='focustarget') or event=='PLAYER_TARGET_CHANGED' or event=='PLAYER_FOCUS_CHANGED' or event=='ZONE_CHANGED' then
        self.stepOnUpdate = 0
        self:SetScript('OnUpdate',function() 
                self.stepOnUpdate = self.stepOnUpdate + 1
                
                
                if self.stepOnUpdate==1 then updateHealthValues(self,event) return end
                if self.stepOnUpdate==2 then unitFrameData(self,event)  return end
                if self.stepOnUpdate==3 then updatePowerValues(self,event)  return end
                if self.stepOnUpdate==4 then      updateCastValues(self,event)  return end
                if self.stepOnUpdate==5 then     updateRaidMarkers(self,event)  return end
              
            
                if self.stepOnUpdate==6 then      self:SetScript('OnUpdate',nil)  return end
               
            end)
        return
    end

    if (event=='UNIT_HEALTH' or event=='UNIT_MAXHEALTH' or event=='UNIT_ABSORB_AMOUNT_CHANGED')  then
        
        updateHealthValues(self,event)
        return
    end
    
    if (event=='UNIT_MAXPOWER' or event=='UNIT_POWER')  then
        updatePowerValues(self,event)
        return
    end
    
    if (event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START')  then
        updateCastValues(self,event)
        return
    end
    
    if (event=='UNIT_SPELLCAST_CHANNEL_STOP' or event=='UNIT_SPELLCAST_STOP' or event=='UNIT_SPELLCAST_INTERRUPTED' or event=='UNIT_SPELLCAST_FAILED')  then
        hideCastBar(self,event)
        return
    end
    
    if event=='RAID_TARGET_UPDATE' then
       updateRaidMarkers(self,event) 
    end

    
end

function gw_unitframes_register_Target()
    
    
    local NewUnitFrame = CreateFrame('Button','GwTargetUnitFrame',UIParent,'GwNormalUnitFrame')
    NewUnitFrame.unit='target'
    
    gw_register_movable_frame('targetframe',NewUnitFrame,'target_pos','GwTargetFrameTemplateDummy')
    
    NewUnitFrame:ClearAllPoints()
    NewUnitFrame:SetPoint(gwGetSetting('target_pos')['point'],UIParent,gwGetSetting('target_pos')['relativePoint'],gwGetSetting('target_pos')['xOfs'],gwGetSetting('target_pos')['yOfs'])
    
    NewUnitFrame:SetAttribute("unit", 'target');
  

    NewUnitFrame:SetAttribute("*type1", 'target')
    NewUnitFrame:SetAttribute("*type2", "togglemenu")
    NewUnitFrame:SetAttribute("unit", 'target')
    RegisterUnitWatch(NewUnitFrame);
    NewUnitFrame:EnableMouse(true)
    NewUnitFrame:RegisterForClicks("AnyDown")
    
    
     local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("CENTER",NewUnitFrame.portrait,'CENTER',0,0)
    
    
      
    mask:SetTexture("Textures\\MinimapMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(58, 58)
    NewUnitFrame.portrait:AddMaskTexture(mask)
    
    
    
    GwaddTOClique(NewUnitFrame)
    
       NewUnitFrame.classColor = gwGetSetting('target_CLASS_COLOR')

    NewUnitFrame.showHealthValue=gwGetSetting('target_HEALTH_VALUE_ENABLED')
    NewUnitFrame.showHealthPrecentage=gwGetSetting('target_HEALTH_VALUE_TYPE')
    
    
    NewUnitFrame.displayBuffs=gwGetSetting('target_BUFFS')
    NewUnitFrame.displayDebuffs=gwGetSetting('target_DEBUFFS')
    
    
    NewUnitFrame.debuffFilter = 'player'
    
    if gwGetSetting('target_BUFFS_FILTER_ALL')==true then
        NewUnitFrame.debuffFilter = nil
    end
    
    
    
    NewUnitFrame:SetScript('OnEvent',target_OnEvent)
        
    NewUnitFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
   -- NewUnitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");

    NewUnitFrame:RegisterEvent("ZONE_CHANGED");

    NewUnitFrame:RegisterEvent("UNIT_HEALTH");
    NewUnitFrame:RegisterEvent("UNIT_MAXHEALTH");
    NewUnitFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    NewUnitFrame:RegisterEvent("UNIT_TARGET");
    NewUnitFrame:RegisterEvent("RAID_TARGET_UPDATE");


   


    NewUnitFrame:RegisterEvent("UNIT_POWER");
    NewUnitFrame:RegisterEvent("UNIT_MAXPOWER");
    
    NewUnitFrame:RegisterEvent("UNIT_AURA");
    
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_START");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_STOP");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_FAILED");
    
    
    
    loadAuras(NewUnitFrame)
    
    TargetFrame:SetScript("OnEvent", nil);
    TargetFrame:Hide();
end

function gw_unitframes_register_Focus()
    
    
    local NewUnitFrame = CreateFrame('Button','GwFocusUnitFrame',UIParent,'GwNormalUnitFrame')
    NewUnitFrame.unit='focus'
    
    gw_register_movable_frame('focusframe',NewUnitFrame,'focus_pos','GwTargetFrameTemplateDummy')
    
    NewUnitFrame:ClearAllPoints()
    NewUnitFrame:SetPoint(gwGetSetting('focus_pos')['point'],UIParent,gwGetSetting('focus_pos')['relativePoint'],gwGetSetting('focus_pos')['xOfs'],gwGetSetting('focus_pos')['yOfs'])
    
    
                  
    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("CENTER",NewUnitFrame.portrait,'CENTER',0,0)
    
    
      
    mask:SetTexture("Textures\\MinimapMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(58, 58)
    NewUnitFrame.portrait:AddMaskTexture(mask)

    NewUnitFrame:SetAttribute("*type1", 'target')
    NewUnitFrame:SetAttribute("*type2", "togglemenu")
    NewUnitFrame:SetAttribute("unit", 'focus');
    RegisterUnitWatch(NewUnitFrame);
    NewUnitFrame:EnableMouse(true)
    NewUnitFrame:RegisterForClicks("AnyDown")
    
    GwaddTOClique(NewUnitFrame)

    NewUnitFrame.showHealthValue=gwGetSetting('focus_HEALTH_VALUE_ENABLED')
    NewUnitFrame.showHealthPrecentage=gwGetSetting('focus_HEALTH_VALUE_TYPE')
    
    NewUnitFrame.classColor = gwGetSetting('focus_CLASS_COLOR')
    
      NewUnitFrame.displayBuffs=gwGetSetting('focus_BUFFS')
    NewUnitFrame.displayDebuffs=gwGetSetting('focus_DEBUFFS')
    
    NewUnitFrame.debuffFilter = 'player'
    if gwGetSetting('focus_BUFFS_FILTER_ALL')==true then
        NewUnitFrame.debuffFilter = nil
    end
    
    NewUnitFrame:SetScript('OnEvent',focus_OnEvent)
        

   NewUnitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");

    NewUnitFrame:RegisterEvent("ZONE_CHANGED");

    NewUnitFrame:RegisterEvent("UNIT_HEALTH");
    NewUnitFrame:RegisterEvent("UNIT_MAXHEALTH");
    NewUnitFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    NewUnitFrame:RegisterEvent("UNIT_TARGET");
    NewUnitFrame:RegisterEvent("RAID_TARGET_UPDATE");


   


    NewUnitFrame:RegisterEvent("UNIT_POWER");
    NewUnitFrame:RegisterEvent("UNIT_MAXPOWER");
    
    NewUnitFrame:RegisterEvent("UNIT_AURA");
    
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_START");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_STOP");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_FAILED");
    
    
    
    loadAuras(NewUnitFrame)
    
    FocusFrame:SetScript("OnEvent", nil);
    FocusFrame:Hide();
end

function gw_unitframes_register_Targetstarget()
    
    
    local NewUnitFrame = CreateFrame('Button','GwTargetsTargetUnitFrame',UIParent,'GwNormalUnitFrameSmall')
    NewUnitFrame.unit='targettarget'
    
    gw_register_movable_frame('targettargetframe',NewUnitFrame,'targettarget_pos','GwTargetFrameTemplateDummy')
    
    NewUnitFrame:ClearAllPoints()
    NewUnitFrame:SetPoint(gwGetSetting('targettarget_pos')['point'],UIParent,gwGetSetting('targettarget_pos')['relativePoint'],gwGetSetting('targettarget_pos')['xOfs'],gwGetSetting('targettarget_pos')['yOfs'])
    
    NewUnitFrame:SetAttribute("unit", 'targettarget');
  

    NewUnitFrame:SetAttribute("*type1", 'target')
    NewUnitFrame:SetAttribute("*type2", "togglemenu")
    NewUnitFrame:SetAttribute("unit", 'targettarget')
    RegisterUnitWatch(NewUnitFrame);
    NewUnitFrame:EnableMouse(true)
    NewUnitFrame:RegisterForClicks("AnyDown")
    
    GwaddTOClique(NewUnitFrame)

    NewUnitFrame.showHealthValue=false
    NewUnitFrame.showHealthPrecentage=false
    
    NewUnitFrame.classColor = gwGetSetting('target_CLASS_COLOR')
    NewUnitFrame.debuffFilter = nil
    
    NewUnitFrame:SetScript('OnEvent',targettarget_OnEvent)
        
    NewUnitFrame:RegisterEvent("UNIT_TARGET");
    NewUnitFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
    NewUnitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");

    NewUnitFrame:RegisterEvent("ZONE_CHANGED");

    NewUnitFrame:RegisterEvent("UNIT_HEALTH");
    NewUnitFrame:RegisterEvent("UNIT_MAXHEALTH");
    NewUnitFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    NewUnitFrame:RegisterEvent("UNIT_TARGET");
    NewUnitFrame:RegisterEvent("RAID_TARGET_UPDATE");


   


    NewUnitFrame:RegisterEvent("UNIT_POWER");
    NewUnitFrame:RegisterEvent("UNIT_MAXPOWER");
    
    NewUnitFrame:RegisterEvent("UNIT_AURA");
    
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_START");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_STOP");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_FAILED");
    
    
   
end

function gw_unitframes_register_Focusstarget()
    
    
    local NewUnitFrame = CreateFrame('Button','GwTargetsTargetUnitFrame',UIParent,'GwNormalUnitFrameSmall')
    NewUnitFrame.unit='focustarget'
    
    gw_register_movable_frame('focustargetframe',NewUnitFrame,'focustarget_pos','GwTargetFrameTemplateDummy')
    
    NewUnitFrame:ClearAllPoints()
    NewUnitFrame:SetPoint(gwGetSetting('focustarget_pos')['point'],UIParent,gwGetSetting('focustarget_pos')['relativePoint'],gwGetSetting('focustarget_pos')['xOfs'],gwGetSetting('focustarget_pos')['yOfs'])
    
    NewUnitFrame:SetAttribute("unit", 'focustarget');
  

    NewUnitFrame:SetAttribute("*type1", 'target')
    NewUnitFrame:SetAttribute("*type2", "togglemenu")
    NewUnitFrame:SetAttribute("unit", 'focustarget')
    RegisterUnitWatch(NewUnitFrame);
    NewUnitFrame:EnableMouse(true)
    NewUnitFrame:RegisterForClicks("AnyDown")
    
    GwaddTOClique(NewUnitFrame)

    NewUnitFrame.showHealthValue=false
    NewUnitFrame.showHealthPrecentage=false
    
    NewUnitFrame.classColor = gwGetSetting('target_CLASS_COLOR')
    NewUnitFrame.debuffFilter = nil
    
    NewUnitFrame:SetScript('OnEvent',focustarget_OnEvent)
        
    NewUnitFrame:RegisterEvent("UNIT_TARGET");
    NewUnitFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
    NewUnitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");

    NewUnitFrame:RegisterEvent("ZONE_CHANGED");

    NewUnitFrame:RegisterEvent("UNIT_HEALTH");
    NewUnitFrame:RegisterEvent("UNIT_MAXHEALTH");
    NewUnitFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    NewUnitFrame:RegisterEvent("UNIT_TARGET");
    NewUnitFrame:RegisterEvent("RAID_TARGET_UPDATE");


   


    NewUnitFrame:RegisterEvent("UNIT_POWER");
    NewUnitFrame:RegisterEvent("UNIT_MAXPOWER");
    
    NewUnitFrame:RegisterEvent("UNIT_AURA");
    
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_START");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_STOP");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
    NewUnitFrame:RegisterEvent("UNIT_SPELLCAST_FAILED");
    
    
   
end





