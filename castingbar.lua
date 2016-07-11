local playeCasting = 0
local playerSpellStart = 0
local playerSpellEnd = 0
local castingbarAnimation = 0
mainCastingBarBg , mainCastingBarBgt = createBackground('BOTTOM',258,22,0,0,"Interface\\AddOns\\GW2_UI\\textures\\castingbar",0)
mainCastingBarBg:SetPoint('BOTTOM',UIParent,'BOTTOM',0,270)
mainCastingBarBgt:SetVertexColor(0.1,0,0,0.4);



mainCastingBar , mainCastingBart = createBackground('LEFT',256,20,0,0,"Interface\\AddOns\\GW2_UI\\textures\\castingbar",4)
mainCastingBar:SetPoint('LEFT',mainCastingBarBg,'LEFT',0,0)


mainCastingBar:SetParent(mainCastingBarBg)
mainCastingBarBg:SetAlpha(0)
mainCastingBarBg:SetScript("OnEvent",function(self,event,unitID,spell)
        local castingType = 1
        if  unitID~='player' then
            return
        end
        if event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START' then
            if event=='UNIT_SPELLCAST_CHANNEL_START' then
                spell, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo("player")
                castingType = 2
            else
                spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitCastingInfo("player")
            end
            mainCastingBart:SetVertexColor(1,1,1); 
            startTime = startTime /1000
            endTime = endTime /1000
            mainCastingBart:SetBlendMode("BLEND")
                    
            addToAnimation('castingbarAnimation',castingbarAnimation,1,startTime,endTime-startTime,function()    
                    local p = animations['castingbarAnimation']['progress']
                    if castingType==2 then
                        p = 1 - animations['castingbarAnimation']['progress']
                    end
                    
                    mainCastingBar:SetWidth(p*256)
                    
                    mainCastingBart:SetTexCoord(0,p,0,1)
                            
            end,'noease')    
            castingbarAnimation = 0
               
                
            local uhm = (((GetTime() * 1000)-startTime) / (endTime - startTime))*100
                
            UIFrameFadeIn(mainCastingBarBg, 0.1,0,1)
            playeCasting = 1
                    
        end
                
        if  event=='UNIT_SPELLCAST_STOP' or event=='UNIT_SPELLCAST_CHANNEL_STOP' then
            UIFrameFadeOut(mainCastingBarBg, 0.2,1,0)
            gw_castingbar_reset()
            playeCasting = 0
        end
            
        if  event=='UNIT_SPELLCAST_FAILED' or event=='UNIT_SPELLCAST_INTERRUPTED' then
            mainCastingBart:SetVertexColor(1,0.5,0.5); 
        end
        if  event=='UNIT_SPELLCAST_SUCCEEDED' or event=='UNIT_SPELLCAST_SUCCESS' then
            mainCastingBart:SetBlendMode("ADD")
        end
            
       
        
        
end)

function gw_castingbar_reset()
    
    if animations['castingbarAnimation'] then
        animations['castingbarAnimation']['completed'] = true
        animations['castingbarAnimation']['duration'] = 0
    end
end

mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_START")
mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_UPDATE")

mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_STOP")
mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_SUCCESS")
mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")