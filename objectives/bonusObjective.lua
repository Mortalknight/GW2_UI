local savedQuests = {}



local function getObjectiveBlock(self,index)
    
    if _G[self:GetName()..'GwQuestObjective'..index]~=nil then return _G[self:GetName()..'GwQuestObjective'..index] end
    
    if self.objectiveBlocksNum==nil then self.objectiveBlocksNum = 0 end
    if self.objectiveBlocks==nil then self.objectiveBlocks = {} end
    
    self.objectiveBlocksNum = self.objectiveBlocksNum + 1
    
    local newBlock = CreateFrame('Frame',self:GetName()..'GwQuestObjective'..self.objectiveBlocksNum,self,'GwQuesttrackerObjectiveNormal')
    self.objectiveBlocks[#self.objectiveBlocks] = newBlock
    newBlock:SetParent(self)
    if self.objectiveBlocksNum==1 then
        newBlock:SetPoint('TOPRIGHT',self,'TOPRIGHT',0,-25) 
    else
        newBlock:SetPoint('TOPRIGHT',_G[self:GetName()..'GwQuestObjective'..(self.objectiveBlocksNum - 1)],'BOTTOMRIGHT',0,0) 
    end
    
    newBlock.StatusBar:SetStatusBarColor(self.color.r,self.color.g,self.color.b)
    
    return newBlock
end
local function addObjectiveBlock(block,text,finished,objectiveIndex,objectiveType,quantity) 

    local objectiveBlock = getObjectiveBlock(block,objectiveIndex)
     
    if text then
       
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText(text)
        if finished then
            objectiveBlock.ObjectiveText:SetTextColor(0.8,0.8,0.8)
        else
            objectiveBlock.ObjectiveText:SetTextColor(1,1,1)
        end
 
       if objectiveType=='progressbar' or GwParseObjectiveString(objectiveBlock, text) then
            objectiveBlock.StatusBar:Show()
            objectiveBlock.StatusBar:SetMinMaxValues(0, 100)
            objectiveBlock.StatusBar:SetValue(GetQuestProgressBarPercent(block.questID))
        else
            objectiveBlock.StatusBar:Hide()
        end
       
        block.height = block.height + objectiveBlock:GetHeight()
        block.numObjectives = block.numObjectives + 1
    end
    
end

local function updateBonusObjective(self,event)
 
    GwBonusObjectiveBlock.height = 1
    GwBonusObjectiveBlock.numObjectives = 0
    GwBonusObjectiveBlock:Hide()
    GwupdateQuestItem(GwBonusItemButton,0)
    
    local foundEvent = false
 
    
    local tasks = GetTasksTable();
    
    if GwQuesttrackerContainerBonusObjectives.collapsed==true then
         GwBonusHeader:Show()
    end

    
    for k,v in pairs(tasks) do
       
        local questID = v
        local isInArea, isOnMap, numObjectives, text = GetTaskInfo(questID)
        local questLogIndex = GetQuestLogIndexByID(questID);
        local simpleDesc = ''
        
        if numObjectives==nil then numObjectives = 0 end
        if isInArea then
            if text==nil then text ='' end
            GwBonusObjectiveBlock.Header:SetText(text)
            
            if savedQuests[questID]==nil then
                gwNewQuestAnimation(GwBonusObjectiveBlock)
                savedQuests[questID] = true
            end
            
            GwBonusObjectiveBlock.questID = questID
            
            GwBonusHeader:Show()
            GwupdateQuestItem(GwBonusItemButton,questLogIndex)
                
            
   
            foundEvent = true
          
           
            for objectiveIndex = 1,numObjectives do
                local text, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, false);

                if simpleDesc=='' then
                    simpleDesc = gwParseSimpleObjective(text)
                else
                        simpleDesc = simpleDesc..', '..gwParseSimpleObjective(text)
                end

                if not GwQuesttrackerContainerBonusObjectives.collapsed==true then
                    addObjectiveBlock(GwBonusObjectiveBlock,text,finished,objectiveIndex,objectiveType)
                end
                end
          
            gwSetObjectiveNotification('EVENT','Event: '..text,simpleDesc, GW_TRAKCER_TYPE_COLOR['BONUS'])
        end        
    end
    
    if foundEvent==false then
        savedQuests = {}
        gwRemoveNotification('EVENT')
        GwBonusHeader:Hide()
    else
        if not GwQuesttrackerContainerBonusObjectives.collapsed==true then
            GwBonusObjectiveBlock:Show() 
        end
    end
    for  i=GwBonusObjectiveBlock.numObjectives + 1, 20 do
        if _G[GwBonusObjectiveBlock:GetName()..'GwQuestObjective'..i]~=nil then
            _G[GwBonusObjectiveBlock:GetName()..'GwQuestObjective'..i]:Hide()
        end
    end 
    
    GwBonusObjectiveBlock:SetHeight(GwBonusObjectiveBlock.height + 5)
    GwQuesttrackerContainerBonusObjectives:SetHeight(GwBonusObjectiveBlock.height + 20)
    
    gwQuestTrackerLayoutChanged()
end


function gw_register_bonusObjectiveFrame()
    
    GwQuesttrackerContainerBonusObjectives:SetScript('OnEvent',  updateBonusObjective)
    
    
    GwQuesttrackerContainerBonusObjectives:RegisterEvent("QUEST_LOG_UPDATE");
    GwQuesttrackerContainerBonusObjectives:RegisterEvent("QUESTTASK_UPDATE");
	GwQuesttrackerContainerBonusObjectives:RegisterEvent("TASK_PROGRESS_UPDATE");
    
    GwQuesttrackerContainerBonusObjectives:RegisterEvent("QUEST_WATCH_LIST_CHANGED");

    
    local newBlock = CreateFrame('Button','GwBonusObjectiveBlock',GwQuesttrackerContainerBonusObjectives,'GwQuesttrackerObject')
    
    newBlock:SetParent(GwQuesttrackerContainerBonusObjectives)
    newBlock:SetPoint('TOPRIGHT',GwQuesttrackerContainerBonusObjectives,'TOPRIGHT',0,-20) 
    newBlock.Header:SetText('')
    
 
    
    newBlock.color = GW_TRAKCER_TYPE_COLOR['BONUS']
    newBlock.Header:SetTextColor(newBlock.color.r,newBlock.color.g,newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r,newBlock.color.g,newBlock.color.b)
    
    
    local header = CreateFrame('Button','GwBonusHeader',GwQuesttrackerContainerBonusObjectives,'GwQuestTrackerHeader')
    header.icon:SetTexCoord(0,1,0.5,0.75)
    
    GwQuesttrackerContainerBonusObjectives.collapsed = false
     header:SetScript('OnClick',function(self) 
        local p = self:GetParent()
        if p.collapsed==nil or p.collapsed==false then
             p.collapsed = true
                
         else
             p.collapsed = false
         end    
       updateBonusObjective()
    end)
    header.title:SetTextColor(GW_TRAKCER_TYPE_COLOR['BONUS'].r,GW_TRAKCER_TYPE_COLOR['BONUS'].g,GW_TRAKCER_TYPE_COLOR['BONUS'].b)   
    header.title:SetText('Events')
  
    updateBonusObjective()
end