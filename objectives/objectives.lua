local blockIndex = 0
local blocks = {}
local savedQuests = {}

GW_TRAKCER_TYPE_COLOR = {}
GW_TRAKCER_TYPE_COLOR['QUEST'] ={r=221/255,g=198/255,b=68/255}
GW_TRAKCER_TYPE_COLOR['BONUS'] ={r=240/255,g=121/255,b=37/255}
GW_TRAKCER_TYPE_COLOR['SCENARIO'] ={r=171/255,g=37/255,b=240/255}
GW_TRAKCER_TYPE_COLOR['BOSS'] ={r=240/255,g=37/255,b=37/255}



function gw_animate_wiggle(self)
    if self.animation==nil then self.animation = 0 end
    if self.doingAnimation == true then return end
    self.doingAnimation = true
    addToAnimation(self:GetName(),0,1,GetTime(),2,function()
       
       
            
        local prog = animations[self:GetName()]['progress']
            
         self.flare:SetRotation(lerp(0,1,prog))
        
        if prog<0.25 then
            self.texture:SetRotation( lerp(0,-0.5,math.sin((prog/0.25) * math.pi * 0.5) ))
            self.flare:SetAlpha(lerp(0,1,math.sin((prog/0.25) * math.pi * 0.5) ))
        end
        if prog>0.25 and prog<0.75 then
             self.texture:SetRotation(lerp(-0.5,0.5, math.sin(((prog - 0.25)/0.5) * math.pi * 0.5)  ))
           
        end
        if prog>0.75 then
            self.texture:SetRotation(lerp(0.5,0, math.sin(((prog - 0.75)/0.25) * math.pi * 0.5)  ))
        end
            
        if prog>0.25 then
         self.flare:SetAlpha(lerp(1,0,((prog - 0.25)/0.75)))
        end
          
    end,nil,function() self.doingAnimation = false end)
    
end


function gwNewQuestAnimation(block)
    block.flare:Show()
    block.flare:SetAlpha(1)
    addToAnimation(block:GetName()..'flare',0,1,GetTime(),1,function(step)
        block:SetWidth(300*step)
        block.flare:SetSize(300*(1 - step),300*(1 - step) )
        block.flare:SetRotation(2*step)
            
        if step>0.75 then
            block.flare:SetAlpha( (step - 0.75)/0.25)     
        end
            
    end, nil, function() 
        block.flare:Hide()    
    end)

end

local function loadQuestButtons()
    for i=1,25 do
        local actionButton = CreateFrame('Button','GwQuestItemButton'..i,GwQuestTracker,'QuestObjectiveItemButtonTemplate')
        actionButton.icon:SetTexCoord(0.1,0.9,0.1,0.9)
        actionButton.NormalTexture:SetTexture(nil)
    end
    
    local actionButton = CreateFrame('Button','GwBonusItemButton',GwQuestTracker,'QuestObjectiveItemButtonTemplate')
    actionButton.icon:SetTexCoord(0.1,0.9,0.1,0.9)
    actionButton.NormalTexture:SetTexture(nil) 
    
    local actionButton = CreateFrame('Button','GwScenarioItemButton',GwQuestTracker,'QuestObjectiveItemButtonTemplate')
    actionButton.icon:SetTexCoord(0.1,0.9,0.1,0.9)
    actionButton.NormalTexture:SetTexture(nil)
    
    
    
end


function gwParseSimpleObjective(text)
    
    local  itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
   
    if itemName==nil then
        numItems,numNeeded,itemName = string.match(text, "(%d+)/(%d+) (%S+)");
    end
    local ndString = ''
    
    if numItems~=nil then ndString = numItems end
    
    if numNeeded~=nil then ndString = ndString..'/'..numNeeded end
    
   return string.gsub(text, ndString, '')
    
   
end

function gw_parse_criteria(quantity, totalQuantity,criteriaString)
    
    if quantity~=nil and totalQuantity~=nil and criteriaString~=nil then
       return string.format("%d/%d %s", quantity, totalQuantity, criteriaString);
    end
     
    return criteriaString
end

function GwParseObjectiveString(block, text, objectiveType,quantity)
    
    if objectiveType=='progressbar' then
        block.StatusBar:SetMinMaxValues(0, 100)
        block.StatusBar:SetValue(quantity)
        block.StatusBar:Show()
        return true
    end
    
    local  itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
    if numItems==nil then
        numItems,numNeeded,itemName = string.match(text, "(%d+)/(%d+) (%S+)");
    end
    numItems= tonumber(numItems)
    numNeeded= tonumber(numNeeded)
    
    if numItems~=nil and numNeeded~=nil and numNeeded>1 and numItems<numNeeded then

        block.StatusBar:SetMinMaxValues(0, 100)
        block.StatusBar:SetValue((numItems/numNeeded)*100)
        return true
    end
    return false
end

local function setBlockColor(block, string)
    block.color = GW_TRAKCER_TYPE_COLOR[string]
end


local function getObjectiveBlock(self,index)
    
    if _G[self:GetName()..'GwQuestObjective'..index]~=nil then return _G[self:GetName()..'GwQuestObjective'..index] end
    
    if self.objectiveBlocksNum==nil then self.objectiveBlocksNum = 0 end
    if self.objectiveBlocks==nil then self.objectiveBlocks = {} end
    
    self.objectiveBlocksNum = self.objectiveBlocksNum + 1
    
    local newBlock = CreateFrame('Frame',self:GetName()..'GwQuestObjective'..self.objectiveBlocksNum,self,'GwQuesttrackerObjectiveNormal')
    newBlock:SetParent(self)
    self.objectiveBlocks[#self.objectiveBlocks] = newBlock
    if self.objectiveBlocksNum==1 then
        newBlock:SetPoint('TOPRIGHT',self,'TOPRIGHT',0,-25) 
    else
        newBlock:SetPoint('TOPRIGHT',_G[self:GetName()..'GwQuestObjective'..(self.objectiveBlocksNum - 1)],'BOTTOMRIGHT',0,0) 
    end
    
    newBlock.StatusBar:SetStatusBarColor(self.color.r,self.color.g,self.color.b)

    
    return newBlock
end

local function getBlock(blockIndex)
    
    if _G['GwQuestBlock'..blockIndex]~=nil then return _G['GwQuestBlock'..blockIndex] end
    

    local newBlock = CreateFrame('Button','GwQuestBlock'..blockIndex,GwQuesttrackerContainerQuests,'GwQuesttrackerObject')
     newBlock:SetParent(GwQuesttrackerContainerQuests)

    if blockIndex==1 then
        newBlock:SetPoint('TOPRIGHT',GwQuesttrackerContainerQuests,'TOPRIGHT',0,-20) 
    else
        newBlock:SetPoint('TOPRIGHT',_G['GwQuestBlock'..(blockIndex - 1)],'BOTTOMRIGHT',0,0) 
    end
    
    setBlockColor(newBlock,'QUEST')
    newBlock.Header:SetTextColor(newBlock.color.r,newBlock.color.g,newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r,newBlock.color.g,newBlock.color.b)
    return newBlock
end




local function addObjective(block,text,finished,objectiveIndex) 
    
    
    if finished==true then return end
    local objectiveBlock = getObjectiveBlock(block,objectiveIndex)
    
    if text  then
       
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

local function updateQuestObjective(block,numObjectives,isComplete)

    for objectiveIndex = 1, numObjectives do
       
        local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, block.questLogIndex)
        
        addObjective(block,text,finished,objectiveIndex)
        
    end
    
end
function GetLeaderBoardDetails (boardIndex,questIndex)
  local leaderboardTxt, itemType, isDone = GetQuestLogLeaderBoard (boardIndex,questIndex);
  local i, j, itemName, numItems, numNeeded = string.find(leaderboardTxt, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
  return itemType, itemName, numItems, numNeeded, isDone;
end

function GwupdateQuestItem(button,questLogIndex)
    
    if InCombatLockdown() then return end
    
    if button==nil then return end
    
     local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex); 
    
    if item==nil then button:Hide() return end
    
    
    button:SetID(questLogIndex);
    button.charges =  charges;
    button.rangeTimer = -1;
    SetItemButtonTexture(button,  item);
    SetItemButtonCount(button,  charges);
    QuestObjectiveItem_UpdateCooldown(button);
    button:Show();
    
    
end

local function quest_update_POI(questID,questLogIndex)
    
	PlaySound("igMainMenuOptionCheckBoxOn");

	if ( IsQuestWatched(questLogIndex) ) then
		if ( IsShiftKeyDown() ) then
			QuestObjectiveTracker_UntrackQuest(nil, questID);
			return;
		end
	else
		AddQuestWatch(questLogIndex, true);
	end
	SetSuperTrackedQuestID(questID);
	WorldMapFrame_OnUserChangedSuperTrackedQuest(questID);
end


local function updateQuest(block, questWatchId)
    
    block.height = 25
    block.numObjectives = 0
    block.turnin:Hide()
    
    local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent,  isAutoComplete, failureTime, timeElapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(questWatchId);

    if questID then
        
        if savedQuests[questID]==nil then
            
            gwNewQuestAnimation(block)
        
            savedQuests[questID] = true
        end
        
        block.questID = questID
        block.questLogIndex = questLogIndex
        
        block.Header:SetText(title)

        --Quest item
       
        GwupdateQuestItem(_G['GwQuestItemButton'..questWatchId],questLogIndex)
        
        
        if requiredMoney~=nil and requiredMoney>GetMoney() then
           addObjective(block,GetMoneyString(GetMoney()).." / "..GetMoneyString(requiredMoney),finished, block.numObjectives+1)            
        end

        if ( isComplete and isComplete < 0 ) then
				isComplete = false;
				questFailed = true;
			elseif ( numObjectives == 0 and GetMoney() >= requiredMoney and not startEvent ) then
				isComplete = true;
			end
        
        updateQuestObjective(block, numObjectives,isComplete)
        
        if isComplete then
            
            if isAutoComplete then
                addObjective(block,QUEST_WATCH_CLICK_TO_COMPLETE,false, block.numObjectives+1) 
                block.turnin:Show()
                block.turnin:SetScript('OnClick',function() ShowQuestComplete(questLogIndex) end)
            else
                local completionText = GetQuestLogCompletionText(questLogIndex);
            
                if ( completionText ) then
                    addObjective(block,completionText,false, block.numObjectives+1) 
                else
                    addObjective(block,QUEST_WATCH_QUEST_READY,false, block.numObjectives+1) 
                end
            end
            
        end
        
        block.clickHeader:SetScript('OnClick', function() quest_update_POI(questID,questLogIndex) end)
        block:SetScript('OnClick', function() 
                QuestLogPopupDetailFrame_Show(questLogIndex);
        end)
             
    end
    if block.objectiveBlocks==nil then block.objectiveBlocks = {} end
    
    for  i=block.numObjectives + 1, 20 do
        if _G[block:GetName()..'GwQuestObjective'..i]~=nil then
            _G[block:GetName()..'GwQuestObjective'..i]:Hide()
        end
    end
    block.height = block.height + 5 
    block:SetHeight(block.height)
    
end

local function updateQuestItemPositions(index, height)
    
    if _G['GwQuestItemButton'..index]==nil then return end
    
    if InCombatLockdown() then return end
    
    height = height + GwQuesttrackerContainerScenario:GetHeight()
    
    if GwObjectivesNotification:IsShown() then height = height + 70 end
    
    _G['GwQuestItemButton'..index]:SetPoint('TOPLEFT',GwQuestTracker,'TOPRIGHT',-330, -height)
    
    
end

local function updateExtraQuestItemPositions()
 
    if GwBonusItemButton==nil or GwScenarioItemButton==nil then return end
    
    if InCombatLockdown() then return end

    local height = 0

    if GwObjectivesNotification:IsShown() then height = height + 70 end
    
    GwScenarioItemButton:SetPoint('TOPLEFT',GwQuestTracker,'TOPRIGHT',-330, -height)
    
    height = GwQuesttrackerContainerScenario:GetHeight() + GwQuesttrackerContainerQuests:GetHeight()
    
    GwBonusItemButton:SetPoint('TOPLEFT',GwQuestTracker,'TOPRIGHT',-330, -height)
end


local function updateQuestLogLayout(intent)

    local savedHeight = 0
    GwQuestHeader:Hide()
    
    for i = 1, GetNumQuestWatches() do    
        GwQuestHeader:Show()
        local block = getBlock(i)
        if block==nil then return end
        updateQuest(block,i)
        block:Show()
        updateQuestItemPositions(i,savedHeight)
        
        savedHeight =savedHeight + block.height
        
    end
    savedHeight = savedHeight + 20
    GwQuesttrackerContainerQuests:SetHeight(savedHeight)
    for i=GetNumQuestWatches() + 1,25 do
        if _G['GwQuestBlock'..i]~=nil then
           _G['GwQuestBlock'..i]:Hide() 
        end
    end
    
end




function gwQuestTrackerLayoutChanged()

    updateExtraQuestItemPositions()
    
    GwQuestTrackerScroll:SetSize(400,GwQuesttrackerContainerBonusObjectives:GetHeight() + GwQuesttrackerContainerQuests:GetHeight())
    
  

end


local function QuestTracker_OnEvent(self,event,data1)

        updateQuestLogLayout(data1)
   
    
end

function gw_load_questTracker()
    ObjectiveTrackerFrame:Hide()
    ObjectiveTrackerFrame:SetScript('OnShow', function() ObjectiveTrackerFrame:Hide() end) 
    
    CreateFrame('Frame','GwQuestTracker',UIParent,'GwQuestTracker') 
    CreateFrame('ScrollFrame','GwQuestTrackerScroll',GwQuestTracker,'GwQuestTrackerScroll') 
   
    CreateFrame('Frame','GwQuestTrackerScrollChild',GwQuestTrackerScroll,'GwQuestTracker') 
    CreateFrame('Frame','GwObjectivesNotification',GwQuestTracker,'GwObjectivesNotification')
    CreateFrame('Frame','GwQuesttrackerContainerBossFrames',GwQuestTracker,'GwQuesttrackerContainer') 
    CreateFrame('Frame','GwQuesttrackerContainerScenario',GwQuestTracker,'GwQuesttrackerContainer') 
    
    CreateFrame('Frame','GwQuesttrackerContainerQuests',GwQuestTrackerScrollChild,'GwQuesttrackerContainer') 
    CreateFrame('Frame','GwQuesttrackerContainerBonusObjectives',GwQuestTrackerScrollChild,'GwQuesttrackerContainer')
    GwQuesttrackerContainerQuests:SetParent(GwQuestTrackerScrollChild)
    GwQuesttrackerContainerBonusObjectives:SetParent(GwQuestTrackerScrollChild)
    
    GwQuestTracker:SetPoint('TOPRIGHT',UIParent,'TOPRIGHT')
    GwQuestTracker:SetPoint('BOTTOMRIGHT',Minimap,'TOPRIGHT')
    
    GwObjectivesNotification:SetPoint('TOPRIGHT',GwQuestTracker,'TOPRIGHT')
    GwQuesttrackerContainerBossFrames:SetPoint('TOPRIGHT',GwObjectivesNotification,'BOTTOMRIGHT')
    GwQuesttrackerContainerScenario:SetPoint('TOPRIGHT',GwQuesttrackerContainerBossFrames,'BOTTOMRIGHT')
    
    GwQuestTrackerScroll:SetPoint('TOPRIGHT',GwQuesttrackerContainerScenario,'BOTTOMRIGHT')
    GwQuestTrackerScroll:SetPoint('BOTTOMRIGHT',GwQuestTracker,'BOTTOMRIGHT')
    
    GwQuestTrackerScrollChild:SetPoint('TOPRIGHT',GwQuestTrackerScroll,'TOPRIGHT')
    GwQuesttrackerContainerQuests:SetPoint('TOPRIGHT',GwQuestTrackerScrollChild,'TOPRIGHT')
    GwQuesttrackerContainerBonusObjectives:SetPoint('TOPRIGHT',GwQuesttrackerContainerQuests,'BOTTOMRIGHT')
    
    GwQuestTrackerScrollChild:SetSize(400,2)
    GwQuestTrackerScroll:SetScrollChild(GwQuestTrackerScrollChild)
    

    GwQuesttrackerContainerQuests:RegisterEvent('QUEST_LOG_UPDATE')
    GwQuesttrackerContainerQuests:RegisterEvent("QUEST_ITEM_UPDATE");

	GwQuesttrackerContainerQuests:RegisterEvent("QUEST_REMOVED");
	GwQuesttrackerContainerQuests:RegisterEvent("QUESTLINE_UPDATE");

	GwQuesttrackerContainerQuests:RegisterEvent("QUESTTASK_UPDATE");
	GwQuesttrackerContainerQuests:RegisterEvent("TASK_PROGRESS_UPDATE");
    
    GwQuesttrackerContainerQuests:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
	GwQuesttrackerContainerQuests:RegisterEvent("QUEST_AUTOCOMPLETE");
	GwQuesttrackerContainerQuests:RegisterEvent("QUEST_ACCEPTED");	
    
    GwQuesttrackerContainerQuests:RegisterEvent("QUEST_GREETING");
	GwQuesttrackerContainerQuests:RegisterEvent("QUEST_DETAIL");
	GwQuesttrackerContainerQuests:RegisterEvent("QUEST_PROGRESS");
	GwQuesttrackerContainerQuests:RegisterEvent("QUEST_COMPLETE");
	GwQuesttrackerContainerQuests:RegisterEvent("QUEST_FINISHED");
    
    GwQuesttrackerContainerQuests:SetScript('OnEvent',QuestTracker_OnEvent)
  
    
    
    local header = CreateFrame('Frame','GwQuestHeader',GwQuesttrackerContainerQuests,'GwQuestTrackerHeader')
    header.icon:SetTexCoord(0,1,0.25,0.5)
    header.title:SetTextColor(GW_TRAKCER_TYPE_COLOR['QUEST'].r,GW_TRAKCER_TYPE_COLOR['QUEST'].g,GW_TRAKCER_TYPE_COLOR['QUEST'].b)   
   
      updateQuestLogLayout()
    loadQuestButtons()
    
    
    gw_register_bossFrames()
    gw_register_scenarioFrame()
    gw_register_bonusObjectiveFrame()
    
end
