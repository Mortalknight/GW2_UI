local function updateBossFrameHeight()
        
    local height = 1
    for i=1,4 do
        if _G['GwQuestTrackerBossFrame'..i]:IsShown() then
            height = height + _G['GwQuestTrackerBossFrame'..i]:GetHeight()
        end
    end
    GwQuesttrackerContainerBossFrames:SetHeight(height)
end

local function bossFrameOnEvent(self)

    local health = UnitHealth(self.unit)
    local maxHealth = UnitHealthMax(self.unit)
    local healthPrecentage = 0
    
    if health>0 and maxHealth>0 then
        healthPrecentage = health/maxHealth 
    end 
    
    self.name:SetText(UnitName(self.unit))
    self.health:SetValue(healthPrecentage)
    
end

local function registerFrame(i)
    

    local debug_unit_Track = 'boss'..i
    

    
    local targetF = CreateFrame('Button','GwQuestTrackerBossFrame'..i,GwQuestTracker,'GwQuestTrackerBossFrame')

    local p = 70 + ((35*i) - 35 ) 
    
    targetF:SetPoint('TOPRIGHT',GwQuestTracker,'TOPRIGHT',0,-p)
    
    targetF.unit = debug_unit_Track
    targetF:SetAttribute("unit", debug_unit_Track);

    targetF:SetAttribute("*type1", 'target')
    targetF:SetAttribute("*type2", "showmenu")
    
    GwaddTOClique(targetF)
    
    RegisterUnitWatch(targetF);
    targetF:EnableMouse(true)
    targetF:RegisterForClicks('AnyDown')
    
    targetF.name:SetFont(UNIT_NAME_FONT,12)
    targetF.name:SetShadowOffset(1,-1)
    
    _G['GwQuestTrackerBossFrame'..i..'StatusBar']:SetStatusBarColor(GW_TRAKCER_TYPE_COLOR['BOSS'].r,GW_TRAKCER_TYPE_COLOR['BOSS'].g,GW_TRAKCER_TYPE_COLOR['BOSS'].b)
    _G['GwQuestTrackerBossFrame'..i..'Icon']:SetVertexColor(GW_TRAKCER_TYPE_COLOR['BOSS'].r,GW_TRAKCER_TYPE_COLOR['BOSS'].g,GW_TRAKCER_TYPE_COLOR['BOSS'].b)

    
    targetF:RegisterEvent('UNIT_MAX_HEALTH')
    targetF:RegisterEvent('UNIT_HEALTH')
    targetF:RegisterEvent("PLAYER_TARGET_CHANGED");
    
    targetF:SetScript('OnShow',function(self) 

        updateBossFrameHeight(self) 


        local compassData = {} 

        compassData['TYPE']= 'BOSS'
        compassData['TITLE']= 'Unknown'
        compassData['ID']= 'boss_unknown'
        compassData['QUESTID']= 'unknown'
        compassData['COMPASS'] = false
        compassData['DESC'] = ''

        compassData['MAPID'] = 0
        compassData['X'] = 0
        compassData['Y'] = 0

        compassData['COLOR']=  GW_TRAKCER_TYPE_COLOR['BOSS']
        compassData['TITLE'] =  UnitName(self.unit)

        gwAddTrackerNotification(compassData)
    end )

    
        targetF:SetScript('OnHide',function(self)
                    updateBossFrameHeight(self) 
        
                    local visible = false
                    for i=1,4 do
                        if _G['GwQuestTrackerBossFrame'..i]:IsShown() then
                            visible = true
                        end
                    end
                    if visible==false then
                        gwRemoveTrackerNotificationOfType('BOSS') 
                    end
        
    end)
    

    targetF:SetScript('OnEvent',bossFrameOnEvent)
end




function gw_register_bossFrames()
   for i=1,4 do
       registerFrame(i) 
        if _G['Boss'..i..'TargetFrame']~=nil then
            _G['Boss'..i..'TargetFrame']:Hide()
            _G['Boss'..i..'TargetFrame']:SetScript("OnEvent", nil);
        end
        
    end
    updateBossFrameHeight()
end

