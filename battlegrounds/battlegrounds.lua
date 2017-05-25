

local bgs ={
   
}


local function getPointsNum(t)
    local base, score, max = string.match(t, "[^%d]+(%d+)[^%d]+(%d+)/(%d+)");

  
    return score, max
end
local function capStateChanged(self)
    
       addToAnimation(self:GetName(),2,1,GetTime(),0.5,function(prog)
            self:SetScale(prog)
        end)
    
end
local function setIcon(self,icon)
    
    if self.savedIconIndex~=icon then capStateChanged(self) end
    self.savedIconIndex = icon
    
    local x1, x2, y1, y2 = GetPOITextureCoords(icon)
    self.icon:SetTexCoord(x1,x2,y1,y2)
    
end


local function LandMarkFrameSetPoint_noTimer(i)
     _G['GwBattleLandMarkFrame'..i]:SetPoint('CENTER',GwBattleGroundScores.MID,'BOTTOMLEFT', (32 )*(i - 1) +16, 45)
end

local function getLandMarkFrame(i)
    
  
    if _G['GwBattleLandMarkFrame'..i]==nil then
        CreateFrame('FRAME','GwBattleLandMarkFrame'..i,GwBattleGroundScores,'GwBattleLandMarkFrame')
        _G['GwBattleLandMarkFrame'..i]:SetPoint('CENTER',GwBattleGroundScores.MID,'BOTTOMLEFT', (32 )*(i - 1) +16, 32)

    end
    return _G['GwBattleLandMarkFrame'..i];

    
end 





local function AB_onEvent(self,event,...)
    
    
        local uiType, state, hidden, text, icon, dynamicIcon, tooltip, dynamicTooltip, extendedUI, extendedUIState1, extendedUIState2, extendedUIState3 = GetWorldStateUIInfo(1);
        
        local uiType, state, hidden, text2, icon, dynamicIcon, tooltip, dynamicTooltip, extendedUI, extendedUIState1, extendedUIState2, extendedUIState3 = GetWorldStateUIInfo(2);
        

       
    
        local current, max = getPointsNum(text)
        local current2, max2 = getPointsNum(text2)

    self.scoreRight:SetText(current)
         
    self.scoreLeft:SetText(current2)
       
   
     self.timer:SetText('');
   
    for i = 1, GetNumMapLandmarks() do
        local _, name, _, icon = GetMapLandmarkInfo(i)
        local f = getLandMarkFrame(i)
        LandMarkFrameSetPoint_noTimer(i)
      
        setIcon(f,icon)
        
        GwBattleGroundScores.MID:SetWidth(32*i)
        
        
    end
    
    AlwaysUpFrame1:Hide()
    AlwaysUpFrame2:Hide()
    
end

local function pvpHud_onEvent(self,event)
    local  name, typeOf, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()
   
    if bgs[mapID]~=nil then
         print(mapID)
        GwBattleGroundScores:SetScript('OnEvent',bgs[mapID])
  
        
        GwBattleGroundScores:RegisterEvent("UPDATE_WORLD_STATES");
	GwBattleGroundScores:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");
	
	GwBattleGroundScores:RegisterEvent("PLAYER_ENTERING_WORLD");

	GwBattleGroundScores:RegisterEvent("ZONE_CHANGED");
	GwBattleGroundScores:RegisterEvent("ZONE_CHANGED_INDOORS");
	GwBattleGroundScores:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	GwBattleGroundScores:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND");

	GwBattleGroundScores:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE");
	
	GwBattleGroundScores:RegisterEvent("BATTLEGROUND_POINTS_UPDATE");
	GwBattleGroundScores:RegisterEvent("LFG_ROLE_CHECK_DECLINED");
	GwBattleGroundScores:RegisterEvent("LFG_ROLE_CHECK_SHOW");
	GwBattleGroundScores:RegisterEvent("LFG_READY_CHECK_DECLINED");
	GwBattleGroundScores:RegisterEvent("LFG_READY_CHECK_SHOW");

        
        
        GwBattleGroundScores:Show()
    else
        GwBattleGroundScores:UnregisterAllEvents()
        GwBattleGroundScores:Hide()
    end
end

function gwLoadBattlegrounds()
    CreateFrame('FRAME','GwPvpHudManager',UIParent)
    
    CreateFrame('FRAME','GwBattleGroundScores',UIParent,'GwBattleGroundScores')  
    
    GwPvpHudManager:RegisterEvent('PLAYER_ENTERING_WORLD')
    GwPvpHudManager:RegisterEvent("ZONE_CHANGED");
	GwPvpHudManager:RegisterEvent("ZONE_CHANGED_INDOORS");
	GwPvpHudManager:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	GwPvpHudManager:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND");
	GwPvpHudManager:SetScript('OnEvent',pvpHud_onEvent)

    
    bgs = {
         [529] = AB_onEvent
    }
  
end
