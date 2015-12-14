local playeCasting = 0
local playerSpellStart = 0
local playerSpellEnd = 0
mainCastingBarBg , mainCastingBarBgt = createBackground('BOTTOM',258,22,0,0,"Interface\\AddOns\\GW2_UI\\textures\\castingbar",0)
mainCastingBarBg:SetPoint('BOTTOM',UIParent,'BOTTOM',0,250)
mainCastingBarBgt:SetVertexColor(0.1,0,0,0.4);



mainCastingBar , mainCastingBart = createBackground('LEFT',256,20,0,0,"Interface\\AddOns\\GW2_UI\\textures\\castingbar",4)
mainCastingBar:SetPoint('LEFT',mainCastingBarBg,'LEFT',0,0)


mainCastingBar:SetParent(mainCastingBarBg)
 mainCastingBarBg:SetAlpha(0)
mainCastingBarBg:SetScript("OnEvent",function(self,event,unitID,spell)
        if  unitID=='player' then
            if event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START' then
                if event=='UNIT_SPELLCAST_CHANNEL_START' then
                    spell, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo("player")
                else
                    spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitCastingInfo("player")
                end
                local uhm = (((GetTime() * 1000)-startTime) / (endTime - startTime))*100
                playerSpellStart = startTime
                playerSpellEnd = endTime
                UIFrameFadeIn(mainCastingBarBg, 0.1,0,1)
               -- overflowh:SetWidth(((endTime - startTime)/200))
                --mainCastingBart:SetTexCoord(0,math.abs(uhm),0,1)
               -- math.abs(uhm - 1)
                playeCasting = 1
                
            end
            
            if  event=='UNIT_SPELLCAST_STOP' or event=='UNIT_SPELLCAST_CHANNEL_STOP' then
                UIFrameFadeOut(mainCastingBarBg, 0.1,1,0)

                playeCasting = 0
            end
            
        else
            
        end
        
        
end)
mainCastingBarBg:SetScript("OnUpdate",function(self)
        if UnitCastingInfo('player') or UnitChannelInfo('player') then
            if playeCasting then    
                local uhm = (((GetTime() * 1000)-playerSpellStart) / (playerSpellEnd - playerSpellStart))
                
                mainCastingBar:SetWidth(uhm*256)
                
                mainCastingBart:SetTexCoord(0,uhm,0,1)

            end
        end
        
        
end)



mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_START")
mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_UPDATE")

mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_STOP")
mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
mainCastingBarBg:RegisterEvent("UNIT_SPELLCAST_FAILED")