local playeCasting = 0
local playerSpellStart = 0
local playerSpellEnd = 0
local castingbarAnimation = 0

function gw_register_castingbar() 
    
CastingBarFrame:Hide()
CastingBarFrame:UnregisterAllEvents()
    
   local GwCastingBar = CreateFrame('Frame','GwCastingBar', UIParent,'GwCastingBar')

  GwCastingBar:SetPoint(gwGetSetting('castingbar_pos')['point'],UIParent,gwGetSetting('castingbar_pos')['relativePoint'],gwGetSetting('castingbar_pos')['xOfs'],gwGetSetting('castingbar_pos')['yOfs'])
    

GwCastingBar:SetAlpha(0)

    
gw_register_movable_frame('castingbarframe',GwCastingBar,'castingbar_pos','GwCastFrameDummy')    
    
GwCastingBar:SetScript("OnEvent",function(self,event,unitID,spell)
        local castingType = 1
        if  unitID~='player' then
            return
        end
        if event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START' or event=='UNIT_SPELLCAST_UPDATE'or event=='UNIT_SPELLCAST_CHANNEL_UPDATE' then
            if event=='UNIT_SPELLCAST_CHANNEL_START' or event=='UNIT_SPELLCAST_CHANNEL_UPDATE' then
                spell, subText, displayName, icon, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo("player")
                castingType = 2
            else
                spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitCastingInfo("player")
            end
                
            if gwGetSetting('CASTINGBAR_DATA') then
                gw_player_castingbar_values(spell,icon)
            end
      
            startTime = startTime /1000
            endTime = endTime /1000
            gw_castingbar_reset()
                GwCastingBar.spark:Show()
            addToAnimation('castingbarAnimation',0,1,startTime,endTime-startTime,function()    
                        
                    if gwGetSetting('CASTINGBAR_DATA') then
                            GwCastingBar.time:SetText(timeCount(endTime - GetTime(),true))
                    end
                        
                    local p = animations['castingbarAnimation']['progress']
                    if castingType==2 then
                        p = 1 - animations['castingbarAnimation']['progress']
                    end
                    
                    GwCastingBar.bar:SetWidth(math.max(1,p*176))
                    GwCastingBar.bar:SetVertexColor(1,1,1,1)
                        
                    
                        
                    GwCastingBar.spark:SetWidth(math.min(15,math.max(1,p*176)))
                    GwCastingBar.bar:SetTexCoord(0,p,0.25,0.5)
                            
            end,'noease')    
            castingbarAnimation = 0
               
                
            local uhm = (((GetTime() * 1000)-startTime) / (endTime - startTime))*100
                
            UIFrameFadeIn(GwCastingBar, 0.1,0,1)
            playeCasting = 1
                    
        end
                
        if  event=='UNIT_SPELLCAST_STOP' or event=='UNIT_SPELLCAST_CHANNEL_STOP' then
            if GwCastingBar.animating==nil or GwCastingBar.animating==false  then
                UIFrameFadeOut(GwCastingBar, 0.2,1,0)
            end
            gw_castingbar_reset()
            playeCasting = 0
        end
            
        if  event=='UNIT_SPELLCAST_FAILED' or event=='UNIT_SPELLCAST_INTERRUPTED' then
    
            gw_castingbar_reset()
            playeCasting = 0
        end
        if  event=='UNIT_SPELLCAST_SUCCEEDED' or event=='UNIT_SPELLCAST_SUCCESS' then
                
                GwCastingBar.animating =true
                GwCastingBar.bar:SetTexCoord(0,1,0.5,0.75)
                GwCastingBar.bar:SetWidth(176)
                GwCastingBar.spark:Hide()
             addToAnimation('castingbarAnimationComplete',0,1,GetTime(),0.2,function()    
               
                
                GwCastingBar.bar:SetVertexColor(1,1,1,lerp(0.7,1,animations['castingbarAnimationComplete']['progress']))
                
               
            end,nil, function() 
                GwCastingBar.animating = false     
                if playeCasting==0 then
                    if GwCastingBar:GetAlpha()>0 then
                        UIFrameFadeOut(GwCastingBar, 0.2,1,0)
                    end
                end
            end)
        end
            
       
        
        
end)


GwCastingBar:RegisterEvent("UNIT_SPELLCAST_START")
GwCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
GwCastingBar:RegisterEvent("UNIT_SPELLCAST_UPDATE")

GwCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
GwCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
GwCastingBar:RegisterEvent("UNIT_SPELLCAST_STOP")
GwCastingBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
GwCastingBar:RegisterEvent("UNIT_SPELLCAST_SUCCESS")
GwCastingBar:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

end

function gw_player_castingbar_values(name,icon)
    GwCastingBar.name:SetText(name)
    GwCastingBar.icon:SetTexture(icon)
end

function gw_castingbar_reset()
    
    if animations['castingbarAnimation'] then
        animations['castingbarAnimation']['completed'] = true
        animations['castingbarAnimation']['duration'] = 0
    end
end
