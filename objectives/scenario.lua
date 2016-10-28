

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
       
        block.height = block.height + objectiveBlock:GetHeight()
        block.numObjectives = block.numObjectives + 1
    end
    
end


local function updateCurrentScenario()
    GwScenarioBlock.height = 1
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
        GwScenarioBlock:SetHeight(GwScenarioBlock.height)
        GwQuesttrackerContainerScenario:SetHeight(GwScenarioBlock.height)
        return 
    end



    local stageName, stageDescription, numCriteria, _,_,_,_,_,_,questID = C_Scenario.GetStepInfo();
    
    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo() 
    if stageDescription==nil then stageDescription='' end
    if stageName==nil then stageName='' end
    gwSetObjectiveNotification('SCENARIO',stageName..' |cFFFFFFFF '..difficultyName..'|r',stageDescription..' ', GW_TRAKCER_TYPE_COLOR['SCENARIO'])
   
    

    --[[
	local inChallengeMode = bit.band(flags, SCENARIO_FLAG_CHALLENGE_MODE) == SCENARIO_FLAG_CHALLENGE_MODE;
	local inProvingGrounds = bit.band(flags, SCENARIO_FLAG_PROVING_GROUNDS) == SCENARIO_FLAG_PROVING_GROUNDS;
	local dungeonDisplay = bit.band(flags, SCENARIO_FLAG_USE_DUNGEON_DISPLAY) == SCENARIO_FLAG_USE_DUNGEON_DISPLAY;
    ]]--
	local scenariocompleted = currentStage > numStages;
   
    local questLogIndex = 0
    
    if questID~=nil or questID~=0 then
        questLogIndex = GetQuestLogIndexByID(questID); 
    end
    
    GwupdateQuestItem(GwScenarioItemButton, questLogIndex)
    
    
    for criteriaIndex = 1, numCriteria do
        local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, __, isWeightedProgress = C_Scenario.GetCriteriaInfo(criteriaIndex);

        local objectiveType ='progressbar'
        if not isWeightedProgress then
            objectiveType = 'monster'
        end
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
  
    GwScenarioBlock:SetHeight(GwScenarioBlock.height)
    GwQuesttrackerContainerScenario:SetHeight(GwScenarioBlock.height)
        
end


function gw_register_scenarioFrame()
    
    GwQuesttrackerContainerScenario:SetScript('OnEvent',  updateCurrentScenario)
    
    
    GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_UPDATE");
	GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_CRITERIA_UPDATE");
    
	GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED_INDOORS");
	GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED");
	GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_COMPLETED");
    
    local newBlock = CreateFrame('Button','GwScenarioBlock',GwQuesttrackerContainerScenario,'GwQuesttrackerObject')
    newBlock:SetParent(GwQuesttrackerContainerScenario)
    newBlock:SetPoint('TOPRIGHT',GwQuesttrackerContainerScenario,'TOPRIGHT',0,0) 
    newBlock.Header:SetText('')
    
    newBlock.color = GW_TRAKCER_TYPE_COLOR['SCENARIO']
    newBlock.Header:SetTextColor(newBlock.color.r,newBlock.color.g,newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r,newBlock.color.g,newBlock.color.b)
    updateCurrentScenario()
end