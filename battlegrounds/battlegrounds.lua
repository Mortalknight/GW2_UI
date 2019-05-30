

    local bgs ={

    }

    local activeBg = 0

    local function getPointsNum(t)
        local base, score, max = string.match(t, "[^%d]+(%d+)[^%d]+(%d+)/(%d+)");


        return score, max
    end
    local function capStateChanged(self)

           addToAnimation(self:GetName(),2,1,GetTime(),0.5,function(prog)
                self:SetScale(prog)
            end)

    end

local function iconOverrider(self,icon)
    
    if bgs[activeBg]['icons'][icon]==nil then return false end
    
    local x1, x2, y1, y2 = bgs[activeBg]['icons'][icon][1],bgs[activeBg]['icons'][icon][2],bgs[activeBg]['icons'][icon][3],bgs[activeBg]['icons'][icon][4]
       
    self.icon:SetTexture('Interface\\AddOns\\GW2_UI\\Textures\\battleground\\objective-icons')
    
    self.icon:SetTexCoord(0.25,0.5,0,1)
    self.icon:SetTexCoord(x1,x2,y1,y2)
    
    
    local iconState = icon - bgs[activeBg]['icons'][icon]['normalState']
    
    if iconState==0 then -- no cap
        self.IconBackground:SetVertexColor(1,1,1)
        self.icon:SetVertexColor(0,0,0)
    elseif iconState==1 then
        self.IconBackground:SetVertexColor(1,1,1)
        self.icon:SetVertexColor(GW_FACTION_COLOR[2].r,GW_FACTION_COLOR[2].g,GW_FACTION_COLOR[2].b)
    elseif iconState==2 then
        self.IconBackground:SetVertexColor(GW_FACTION_COLOR[2].r,GW_FACTION_COLOR[2].g,GW_FACTION_COLOR[2].b)
        self.icon:SetVertexColor(0,0,0)
    elseif iconState==3 then
        self.IconBackground:SetVertexColor(1,1,1)
        self.icon:SetVertexColor(GW_FACTION_COLOR[1].r,GW_FACTION_COLOR[1].g,GW_FACTION_COLOR[1].b)
    elseif iconState==4 then
        self.IconBackground:SetVertexColor(GW_FACTION_COLOR[1].r,GW_FACTION_COLOR[1].g,GW_FACTION_COLOR[1].b)
        self.icon:SetVertexColor(0,0,0)
    end
        
        
        return true
        
    end

    local function setIcon(self,icon)
    
        
    
        if self.savedIconIndex~=icon then capStateChanged(self) end
        self.savedIconIndex = icon
    
        if iconOverrider(self,icon) then return end

        local x1, x2, y1, y2 = GetPOITextureCoords(icon)
        self.icon:SetTexture('Interface\\Minimap\\POIIcons')
        self.icon:SetTexCoord(x1,x2,y1,y2)

    end


    local function LandMarkFrameSetPoint_noTimer(i)
         _G['GwBattleLandMarkFrame'..i]:SetPoint('CENTER',GwBattleGroundScores.MID,'BOTTOMLEFT', (36 )*(i - 1) +18, 45)
    end

    local function getLandMarkFrame(i)


        if _G['GwBattleLandMarkFrame'..i]==nil then
            CreateFrame('FRAME','GwBattleLandMarkFrame'..i,GwBattleGroundScores,'GwBattleLandMarkFrame')
            _G['GwBattleLandMarkFrame'..i]:SetPoint('CENTER',GwBattleGroundScores.MID,'BOTTOMLEFT', (36 )*(i - 1) +18, 32)

        end
        return _G['GwBattleLandMarkFrame'..i];


    end 





    local function AB_onEvent(self,event,...)


            local uiType, state, hidden, text, icon, dynamicIcon, tooltip, dynamicTooltip, extendedUI, extendedUIState1, extendedUIState2, extendedUIState3 = GetWorldStateUIInfo(1);

            local uiType, state, hidden, text2, icon, dynamicIcon, tooltip, dynamicTooltip, extendedUI, extendedUIState1, extendedUIState2, extendedUIState3 = GetWorldStateUIInfo(2);

         
            if text2==nil or text==nil then return end


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

            GwBattleGroundScores.MID:SetWidth(36*i)


        end
        for i=1,5 do 
            if _G['AlwaysUpFrame'..i]~=nil then
                _G['AlwaysUpFrame'..i]:Hide()
            end
        end

    end

    local function pvpHud_onEvent(self,event)
        local  name, typeOf, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()

        if bgs[mapID]~=nil then
            activeBg = mapID
            GwBattleGroundScores:SetScript('OnEvent',bgs[mapID]['OnEvent'])


            GwBattleGroundScores:RegisterEvent("UPDATE_WORLD_STATES");
            GwBattleGroundScores:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");

            GwBattleGroundScores:RegisterEvent("PLAYER_ENTERING_WORLD");

            GwBattleGroundScores:RegisterEvent("ZONE_CHANGED");
            GwBattleGroundScores:RegisterEvent("ZONE_CHANGED_INDOORS");
            GwBattleGroundScores:RegisterEvent("ZONE_CHANGED_NEW_AREA");
            GwBattleGroundScores:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND");

            GwBattleGroundScores:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE");

            GwBattleGroundScores:RegisterEvent("BATTLEGROUND_POINTS_UPDATE");

            GwBattleGroundScores:Show()
        else
            GwBattleGroundScores:UnregisterAllEvents()
            GwBattleGroundScores:Hide()
        end
    end

    function gwLoadBattlegrounds()

          bgs = {
             [529] = { 
                ['OnEvent'] = AB_onEvent,
                ['icons'] ={
                    [16] = {[1]=0.25, [2]=0.50, [3]=0, [4]=0.5, ['normalState']=16 },
                    [17] = {[1]=0.25, [2]=0.50, [3]=0, [4]=0.5, ['normalState']=16 },
                    [18] = {[1]=0.25, [2]=0.50, [3]=0, [4]=0.5, ['normalState']=16 },
                    [19] = {[1]=0.25, [2]=0.50, [3]=0, [4]=0.5, ['normalState']=16 },
                    [20] = {[1]=0.25, [2]=0.50, [3]=0, [4]=0.5, ['normalState']=16 },
                
                    [21] = {[1]=0, [2]=0.25, [3]=0, [4]=0.5, ['normalState']=21 },
                    [22] = {[1]=0, [2]=0.25, [3]=0, [4]=0.5, ['normalState']=21 },
                    [23] = {[1]=0, [2]=0.25, [3]=0, [4]=0.5, ['normalState']=21 },
                    [24] = {[1]=0, [2]=0.25, [3]=0, [4]=0.5, ['normalState']=21 },
                    [25] = {[1]=0, [2]=0.25, [3]=0, [4]=0.5, ['normalState']=21 },
                
                    [26] = {[1]=0, [2]=0.25, [3]=0.5, [4]=1, ['normalState']=26 },
                    [27] = {[1]=0, [2]=0.25, [3]=0.5, [4]=1, ['normalState']=26 },
                    [28] = {[1]=0, [2]=0.25, [3]=0.5, [4]=1, ['normalState']=26 },
                    [29] = {[1]=0, [2]=0.25, [3]=0.5, [4]=1, ['normalState']=26 },
                    [30] = {[1]=0, [2]=0.25, [3]=0.5, [4]=1, ['normalState']=26 },
                
                    [31] = {[1]=0.75, [2]=1, [3]=0, [4]=0.5, ['normalState']=31 },
                    [32] = {[1]=0.75, [2]=1, [3]=0, [4]=0.5, ['normalState']=31 },
                    [33] = {[1]=0.75, [2]=1, [3]=0, [4]=0.5, ['normalState']=31 },
                    [34] = {[1]=0.75, [2]=1, [3]=0, [4]=0.5, ['normalState']=31 },
                    [35] = {[1]=0.75, [2]=1, [3]=0, [4]=0.5, ['normalState']=31 },
                
                    [36] = {[1]=0.5, [2]=0.75, [3]=0, [4]=0.5, ['normalState']=36 },
                    [37] = {[1]=0.5, [2]=0.75, [3]=0, [4]=0.5, ['normalState']=36 },
                    [38] = {[1]=0.5, [2]=0.75, [3]=0, [4]=0.5, ['normalState']=36 },
                    [39] = {[1]=0.5, [2]=0.75, [3]=0, [4]=0.5, ['normalState']=36 },
                    [40] = {[1]=0.5, [2]=0.75, [3]=0, [4]=0.5, ['normalState']=36 },
                }
            }
        }

        CreateFrame('FRAME','GwPvpHudManager',UIParent)

        CreateFrame('FRAME','GwBattleGroundScores',UIParent,'GwBattleGroundScores')  

        GwPvpHudManager:RegisterEvent('PLAYER_ENTERING_WORLD')
        GwPvpHudManager:RegisterEvent("ZONE_CHANGED");
        GwPvpHudManager:RegisterEvent("ZONE_CHANGED_INDOORS");
        GwPvpHudManager:RegisterEvent("ZONE_CHANGED_NEW_AREA");
        GwPvpHudManager:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND");
        GwPvpHudManager:SetScript('OnEvent',pvpHud_onEvent)

   




    end
