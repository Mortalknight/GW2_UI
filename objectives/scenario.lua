




local function getObjectiveBlock(self,index)
    
    if _G[self:GetName()..'GwQuestObjective'..index]~=nil then return _G[self:GetName()..'GwQuestObjective'..index] end
    
    if self.objectiveBlocksNum==nil then self.objectiveBlocksNum = 0 end
    if self.objectiveBlocks==nil then self.objectiveBlocks = {} end
    
    self.objectiveBlocksNum = self.objectiveBlocksNum + 1
    
    local newBlock = CreateFrame('Frame',self:GetName()..'GwQuestObjective'..self.objectiveBlocksNum,self,'GwQuesttrackerObjectiveNormal')
    self.objectiveBlocks[#self.objectiveBlocks] = newBlock
    newBlock:SetParent(self)
    if self.objectiveBlocksNum==1 then
        newBlock:SetPoint('TOPRIGHT',self,'TOPRIGHT',0,-5) 
    else
        newBlock:SetPoint('TOPRIGHT',_G[self:GetName()..'GwQuestObjective'..(self.objectiveBlocksNum - 1)],'BOTTOMRIGHT',0,0) 
    end
    
    newBlock.StatusBar:SetStatusBarColor(self.color.r,self.color.g,self.color.b)
    
    return newBlock
end
function addObjectiveBlock(block,text,finished,objectiveIndex,objectiveType,quantity) 

    local objectiveBlock = getObjectiveBlock(block,objectiveIndex)
     
    
    if text then
       
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText(text)
        if finished then
            objectiveBlock.ObjectiveText:SetTextColor(0.8,0.8,0.8)
        else
            objectiveBlock.ObjectiveText:SetTextColor(1,1,1)
        end
        
        if not GwParseObjectiveString(objectiveBlock, text,objectiveType,quantity) then
   
            objectiveBlock.StatusBar:Hide()
        end
        local h = 20
        if objectiveBlock.StatusBar:IsShown() then h = 50 end
        block.height = block.height + h
        block.numObjectives = block.numObjectives + 1
    end
    
end


local function updateCurrentScenario()
    
	local delayUpdateTime = GetTime() + 0.8;
	GwQuesttrackerContainerScenario:SetScript('OnUpdate', function()
    if GetTime()<delayUpdateTime  then return end 
    updateCurrentScenario() 
    GwQuesttrackerContainerScenario:SetScript('OnUpdate',nil)
    end)
    
    GwScenarioBlock.height = 1
    
    if GwQuestTrackerTimer:IsShown() then
        GwScenarioBlock.height =  GwQuestTrackerTimer.height 
    end
    
    GwScenarioBlock.numObjectives = 0
    GwScenarioBlock:Show()
    
    local scenarioName, currentStage, numStages, flags, _, _, completed, xp, money = C_Scenario.GetInfo();
    if ( numStages == 0 ) then 
        
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo() 
        if instanceType=='raid' then
            gwSetObjectiveNotification('SCENARIO',name,difficultyName, GW_TRAKCER_TYPE_COLOR['SCENARIO'])
            
        else
            gwRemoveNotification('SCENARIO')
            GwScenarioBlock:Hide()
        end
        GwupdateQuestItem(GwScenarioItemButton, 0)
        for  i=GwScenarioBlock.numObjectives + 1, 20 do
        if _G[GwScenarioBlock:GetName()..'GwQuestObjective'..i]~=nil then
            _G[GwScenarioBlock:GetName()..'GwQuestObjective'..i]:Hide()
        end
    end

    
    GwScenarioBlock.height = GwScenarioBlock.height + 5 
  
    GwScenarioBlock:SetHeight(GwScenarioBlock.height)
    GwQuesttrackerContainerScenario:SetHeight(GwScenarioBlock.height)
        return
         
    end



    local stageName, stageDescription, numCriteria, _,_,_,_,_,_,questID = C_Scenario.GetStepInfo();
    
    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo() 
    if stageDescription==nil then stageDescription='' end
    if stageName==nil then stageName='' end
	if difficultyName ~=nil then
		gwSetObjectiveNotification('SCENARIO',stageName..' |cFFFFFFFF '..difficultyName..'|r',stageDescription..' ', GW_TRAKCER_TYPE_COLOR['SCENARIO'])
	end
    

    --[[
	local inChallengeMode = bit.band(flags, SCENARIO_FLAG_CHALLENGE_MODE) == SCENARIO_FLAG_CHALLENGE_MODE;
	local inProvingGrounds = bit.band(flags, SCENARIO_FLAG_PROVING_GROUNDS) == SCENARIO_FLAG_PROVING_GROUNDS;
	local dungeonDisplay = bit.band(flags, SCENARIO_FLAG_USE_DUNGEON_DISPLAY) == SCENARIO_FLAG_USE_DUNGEON_DISPLAY;
    ]]--
	local scenariocompleted = currentStage > numStages;
   
    local questLogIndex = 0
    
    if questID~=nil then
        questLogIndex = GetQuestLogIndexByID(questID); 
    end
    
    GwupdateQuestItem(GwScenarioItemButton, questLogIndex)
    
    
    for criteriaIndex = 1, numCriteria do
        local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, __, isWeightedProgress = C_Scenario.GetCriteriaInfo(criteriaIndex);
        local objectiveType ='progressbar'
        if not isWeightedProgress then
            objectiveType = 'monster'
        end
		if objectiveType == 'progressbar' then totalQuantity = 100 end
        addObjectiveBlock(GwScenarioBlock,gw_parse_criteria(quantity,totalQuantity,criteriaString),false,criteriaIndex,objectiveType,quantity) 
    end
    
    local bonusSteps = C_Scenario.GetBonusSteps();
    for k,v in pairs(bonusSteps) do
        bonusStepIndex = v
        local scenarioName, currentStage, numStages, flags, _, _, completed, xp, money = C_Scenario.GetInfo(bonusStepIndex);
        
        local stageName, stageDescription, numCriteria = C_Scenario.GetStepInfo(bonusStepIndex);
        for criteriaIndex = 1, numCriteria do
            
            if criteriaIndex==1 then
                addObjectiveBlock(GwScenarioBlock,gw_parse_criteria(quantity,totalQuantity,criteriaString),false,criteriaIndex,objectiveType,quantity) 
            end
            
            local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex,criteriaIndex);
            
            local objectiveType ='progressbar'
            if not isWeightedProgress then
                objectiveType = 'monster'
            end
            addObjectiveBlock(GwScenarioBlock,gw_parse_criteria(quantity,totalQuantity,criteriaString),false,criteriaIndex,objectiveType,quantity) 
        end
    end
    
     for  i=GwScenarioBlock.numObjectives + 1, 20 do
        if _G[GwScenarioBlock:GetName()..'GwQuestObjective'..i]~=nil then
            _G[GwScenarioBlock:GetName()..'GwQuestObjective'..i]:Hide()
        end
    end

    
    GwScenarioBlock.height = GwScenarioBlock.height + 5 
	
	local intGWQuestTrackerHeight
	intGWQuestTrackerHeight = 0	
	
	if _G['GwAffixFrame']:IsShown() then intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40 end
	if GwQuestTrackerTimer.timer:IsShown() then intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40 end

    GwScenarioBlock:SetHeight(GwScenarioBlock.height - intGWQuestTrackerHeight)
    GwQuesttrackerContainerScenario:SetHeight(GwScenarioBlock.height)
        
end

local function scenarioTimerStop()
    GwQuestTrackerTimer:SetScript('OnUpdate',nil) 
    GwQuestTrackerTimer.timer:Hide()
end



local function scenarioTimerUpdate(...)
    
    GwQuestTrackerTimer.height = 1
    local hasUpdatedAffixes = false;
    
	for i = 1, select("#", ...) do
		local timerID = select(i, ...);
		local _, elapsedTime, type = GetWorldElapsedTime(timerID);
		if ( type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE) then
			local mapID = C_ChallengeMode.GetActiveChallengeMapID()
			if ( mapID ) then
				local _, _, timeLimit = C_ChallengeMode.GetMapInfo(mapID);
			--	Scenario_ChallengeMode_ShowBlock(timerID, elapsedTime, timeLimit);
                GwQuestTrackerTimer:SetScript('OnUpdate',function()
                    local _, elapsedTime,  type = GetWorldElapsedTime(timerID);
                    GwQuestTrackerTimer.timer:SetValue (1 - (elapsedTime/timeLimit))
                    GwQuestTrackerTimer.timerString:SetText(GetTimeStringFromSeconds(timeLimit - elapsedTime))
                   
                end)
                GwQuestTrackerTimer.timer:Show()
                GwQuestTrackerTimer.height = GwQuestTrackerTimer.height + 40
                gw_scenario_affixes()
                hasUpdatedAffixes = true;
				return;
			end
		elseif ( type == LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND ) then
			local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
			if (duration > 0) then
			--	Scenario_ProvingGrounds_ShowBlock(timerID, elapsedTime, duration, diffID, currWave, maxWave);
                  GwQuestTrackerTimer:SetScript('OnUpdate',function()
                    local _, elapsedTime, type = GetWorldElapsedTime(timerID);
                    GwQuestTrackerTimer.timer:SetValue (1 - (elapsedTime/duration))
                        GwQuestTrackerTimer.timerString:SetText(GetTimeStringFromSeconds(duration - elapsedTime,false,true))
                end)
                 GwQuestTrackerTimer.timer:Show()
                GwQuestTrackerTimer.height = GwQuestTrackerTimer.height + 40
				return;
			end
		end
	end
    GwQuestTrackerTimer.timer:Hide()
    GwQuestTrackerTimer:SetScript('OnUpdate',nil)
    
    if hasUpdatedAffixes==false then
		for i = 1,3 do
			_G['GwAffixFrame'..i].affixID = nil
			_G['GwAffixFrame'..i..'Icon']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\icon-boss')
		end
        _G['GwAffixFrame']:Hide();
    end
  
end

function gw_scenario_affixes()
    
    local level, affixes, wasEnergized = C_ChallengeMode.GetActiveKeystoneInfo();
    local i = 1
    for k,v in pairs(affixes) do
        if i == 1 then
              GwQuestTrackerTimer.height = GwQuestTrackerTimer.height + 40
			  GwQuestTrackerTimer.timer:ClearAllPoints()
			  GwQuestTrackerTimer.timer:SetPoint('TOPLEFT',GwQuestTrackerTimer.affixes,'BOTTOMLEFT',-10,-15)
		end
        local affixID = v
        local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID);
        
        if filedataid~=nil then
            SetPortraitToTexture(_G['GwAffixFrame'..i..'Icon'], filedataid);
        end
        _G['GwAffixFrame'..i].affixID = affixID;
        _G['GwAffixFrame'..i]:Show();
        _G['GwAffixFrame'..i..'Icon']:Show();
        _G['GwAffixFrame']:Show();
        i = i + 1
    end
	
    
    if i==1 then
		GwQuestTrackerTimer.timer:ClearAllPoints()
		GwQuestTrackerTimer.timer:SetPoint('TOPRIGHT',GwQuestTrackerTimer.affixes,'BOTTOMRIGHT',-10,20)
		for i = 1,3 do
			_G['GwAffixFrame'..i].affixID = nil
			_G['GwAffixFrame'..i..'Icon']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\icon-boss')
		end
       _G['GwAffixFrame']:Hide(); 
    end
    
    
end

local function scenarioTimerOnEvent(self, event, ...)
    
    
	if ( event == "PLAYER_ENTERING_WORLD" or event == nil ) then
        -- ScenarioTimer_CheckTimers(GetWorldElapsedTimers());
        scenarioTimerUpdate(GetWorldElapsedTimers())
	elseif ( event == "WORLD_STATE_TIMER_START") then
		local timerID = ...;
		scenarioTimerUpdate(timerID);
	elseif ( event == "WORLD_STATE_TIMER_STOP" ) then
		local timerID = ...;
        scenarioTimerStop()
	elseif (event == "PROVING_GROUNDS_SCORE_UPDATE") then
		local score = ...
        GwQuestTrackerTimer.score.scoreString:SetText(score);
        GwQuestTrackerTimer.score:Show()
        GwQuestTrackerTimer.height = GwQuestTrackerTimer.height + 40
	elseif (event == "SPELL_UPDATE_COOLDOWN") then
	--	ScenarioSpellButtons_UpdateCooldowns();
	elseif (event == "CHALLENGE_MODE_START" or event == "CHALLENGE_MODE_COMPLETED" or event == "CHALLENGE_MODE_MAPS_UPDATE" or event == "ZONE_CHANGED") then
    	scenarioTimerUpdate(GetWorldElapsedTimers());
    end
    GwQuestTrackerTimer:SetHeight(GwQuestTrackerTimer.height)
    updateCurrentScenario()
    
end
 

function gw_register_scenarioFrame()
    
    GwQuesttrackerContainerScenario:SetScript('OnEvent',  updateCurrentScenario)
    
    
    GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_UPDATE");
	GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_CRITERIA_UPDATE");	
    
	GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED_INDOORS");
	GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED");
	GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_COMPLETED");
	GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_SPELL_UPDATE");
    
    
    local timerBlock = CreateFrame('Button','GwQuestTrackerTimer',GwQuesttrackerContainerScenario,'GwQuesttrackerScenarioBlock')
    
    timerBlock:SetParent(GwQuesttrackerContainerScenario)
    timerBlock:ClearAllPoints()
    timerBlock:SetPoint('TOPRIGHT',GwQuesttrackerContainerScenario,'TOPRIGHT',0,0)
    
    timerBlock:RegisterEvent('PLAYER_ENTERING_WORLD')
    timerBlock:RegisterEvent('WORLD_STATE_TIMER_START')
    timerBlock:RegisterEvent('WORLD_STATE_TIMER_STOP')
    timerBlock:RegisterEvent('PROVING_GROUNDS_SCORE_UPDATE')
    timerBlock:RegisterEvent('SPELL_UPDATE_COOLDOWN')
    timerBlock:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')
    timerBlock:RegisterEvent('CHALLENGE_MODE_START')
    timerBlock:RegisterEvent('CHALLENGE_MODE_COMPLETED')
    timerBlock:RegisterEvent('ZONE_CHANGED')

    timerBlock:SetScript('OnEvent',scenarioTimerOnEvent)
    
    
    
    
    local newBlock = CreateFrame('Button','GwScenarioBlock',GwQuesttrackerContainerScenario,'GwQuesttrackerObject')
    newBlock:SetParent(GwQuesttrackerContainerScenario)
    newBlock:SetPoint('TOPRIGHT',timerBlock,'BOTTOMRIGHT',0,0) 
    newBlock.Header:SetText('')
    
    newBlock.color = GW_TRAKCER_TYPE_COLOR['SCENARIO']
    newBlock.Header:SetTextColor(newBlock.color.r,newBlock.color.g,newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r,newBlock.color.g,newBlock.color.b)
    updateCurrentScenario()
    scenarioTimerOnEvent()
end