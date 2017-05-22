local blockIndex = 0
local waitForUpdate = false
local updatedThisFrame = false
local blocks = {}
local savedQuests = {}

GW_TRAKCER_TYPE_COLOR = {}
GW_TRAKCER_TYPE_COLOR['QUEST'] ={r=221/255,g=198/255,b=68/255}
GW_TRAKCER_TYPE_COLOR['EVENT'] ={r=240/255,g=121/255,b=37/255}
GW_TRAKCER_TYPE_COLOR['BONUS'] ={r=240/255,g=121/255,b=37/255}
GW_TRAKCER_TYPE_COLOR['SCENARIO'] ={r=171/255,g=37/255,b=240/255}
GW_TRAKCER_TYPE_COLOR['BOSS'] ={r=240/255,g=37/255,b=37/255}
GW_TRAKCER_TYPE_COLOR['ACHIEVEMENT'] ={r=37/255,g=240/255,b=172/255}



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
        local actionButton = CreateFrame('Button','GwQuestItemButton'..i,GwQuestTracker,'GwQuestItemTemplate')
        actionButton.icon:SetTexCoord(0.1,0.9,0.1,0.9)
        actionButton.NormalTexture:SetTexture(nil)
        actionButton:RegisterForClicks("AnyUp");
    end
    
    local actionButton = CreateFrame('Button','GwBonusItemButton',GwQuestTracker,'GwQuestItemTemplate')
    actionButton.icon:SetTexCoord(0.1,0.9,0.1,0.9)
    actionButton.NormalTexture:SetTexture(nil) 
     actionButton:RegisterForClicks("AnyUp");
    
    local actionButton = CreateFrame('Button','GwScenarioItemButton',GwQuestTracker,'GwQuestItemTemplate')
    actionButton.icon:SetTexCoord(0.1,0.9,0.1,0.9)
    actionButton.NormalTexture:SetTexture(nil)
     actionButton:RegisterForClicks("AnyUp");
    
    
    
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
        block.StatusBar.precentage = true
        return true
    end
    block.StatusBar.precentage = false
    local itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
    if numItems==nil then
        numItems,numNeeded,itemName = string.match(text, "(%d+)/(%d+) (%S+)");
    end
    numItems= tonumber(numItems)
    numNeeded= tonumber(numNeeded)
    
    if numItems~=nil and numNeeded~=nil and numNeeded>1 and numItems<numNeeded then

        block.StatusBar:Show()
        block.StatusBar:SetMinMaxValues(0, numNeeded)
        block.StatusBar:SetValue(numItems)
        
        return true
    end
    return false
end

function GwFormatObjectiveNumbers(text)

   local  itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
   
    if itemName==nil then
        numItems,numNeeded,itemName = string.match(text, "(%d+)/(%d+) ((.*))");
    end
    numItems= tonumber(numItems)
    numNeeded= tonumber(numNeeded)
    
    if numItems~=nil and numNeeded~=nil then

        return comma_value(numItems)..' / '..comma_value(numNeeded)..' '..itemName
    end
    return text
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
    newBlock.clickHeader:Show() 
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
            if objectiveType=='progressbar' then
                objectiveBlock.StatusBar:Show()
                objectiveBlock.StatusBar:SetMinMaxValues(0, 100)
                objectiveBlock.StatusBar:SetValue(GetQuestProgressBarPercent(block.questID))
            end
        else
            objectiveBlock.StatusBar:Hide()
        end
        local h = 20
        if objectiveBlock.StatusBar:IsShown() then h = 50 end
        block.height = block.height + h
        block.numObjectives = block.numObjectives + 1
    end
    
end

local function updateQuestObjective(block,numObjectives,isComplete,title)

   
    local addedObjectives = 1
    
    local compass, x, y, o, mapId  =gwScanMapforObjective(block.questID) 
    
    if isComplete then compass = false end
    
    local compassData = {}
  
    local objectiveText = ''
    if compass then
        
     
           compassData['TYPE']= 'QUEST'
           compassData['TITLE']= title
           compassData['ID']=block.questID
           
           compassData['COLOR']=  GW_TRAKCER_TYPE_COLOR['QUEST']
           compassData['COMPASS'] = true
           compassData['X'] = x
           compassData['Y'] = y
           compassData['QUESTID']= block.questID
           compassData['MAPID'] = mapId
            
        end
    
    for objectiveIndex = 1, numObjectives do
       
    
        local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, block.questLogIndex)
        if compass and (objectiveIndex - 1)==o then
  
           objectiveText  = text
        end
        if not finished then
            addObjective(block,text,finished,addedObjectives)
            addedObjectives = addedObjectives + 1
        end
    end
    
    if compass then
        compassData['DESC'] = objectiveText
    
        gwAddTrackerNotification(compassData) 
    end
    
end


function GwupdateQuestItem(button,questLogIndex)
    
    if InCombatLockdown() then return end
    
    if button==nil then return end
    
    local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex); 
    
    if item==nil then   button:Hide()   return end
    
    
    button:SetID(questLogIndex);

    button:SetAttribute("type",'item')
    button:SetAttribute('item',GetItemInfo(link))

    
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
        
 

        if ( isComplete and isComplete < 0 ) then
				isComplete = false;
				questFailed = true;
			elseif ( numObjectives == 0 and GetMoney() >= requiredMoney and not startEvent ) then
				isComplete = true;
			end
        
        updateQuestObjective(block, numObjectives,isComplete,title)
        
               
        if requiredMoney~=nil and requiredMoney>GetMoney() then
           addObjective(block,GetMoneyString(GetMoney()).." / "..GetMoneyString(requiredMoney),finished, block.numObjectives+1)            
        end
        
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
    
    height = height + GwQuesttrackerContainerScenario:GetHeight() + 25
    height = height + GwQuesttrackerContainerAchievement:GetHeight() 
    
    if GwObjectivesNotification:IsShown() then height = height + 70 end
    
    _G['GwQuestItemButton'..index]:SetPoint('TOPLEFT',GwQuestTracker,'TOPRIGHT',-330, -height)
    
    
end

local function updateExtraQuestItemPositions()
 
    if GwBonusItemButton==nil or GwScenarioItemButton==nil then return end
    
    if InCombatLockdown() then return end

    local height = 0

    if GwObjectivesNotification:IsShown() then height = height + 70 end
    
    GwScenarioItemButton:SetPoint('TOPLEFT',GwQuestTracker,'TOPRIGHT',-330, -height)
    
    height = height + GwQuesttrackerContainerScenario:GetHeight() + GwQuesttrackerContainerQuests:GetHeight() + GwQuesttrackerContainerAchievement:GetHeight() + GwQuesttrackerContainerAchievement:GetHeight()
    
    GwBonusItemButton:SetPoint('TOPLEFT',GwQuestTracker,'TOPRIGHT',-330, -height + -25)
end



local function updateQuestLogLayout(intent)
    
    
    if updatedThisFrame and intent~='update' then
        waitForUpdate  = true
        
    end
        
    updatedThisFrame = true
    
    gwRemoveTrackerNotificationOfType('QUEST')

    local savedHeight = 1
    GwQuestHeader:Hide()

    
    local numQuests = GetNumQuestWatches()
    if GwQuesttrackerContainerQuests.collapsed==true then
        GwQuestHeader:Show()
        numQuests = 0
        savedHeight = 20
    end
         
    
    for i = 1, numQuests do    
        if i==1 then savedHeight = 20 end
        GwQuestHeader:Show()
        local block = getBlock(i)
        if block==nil then return end
        updateQuest(block,i)
        block:Show()
        updateQuestItemPositions(i,savedHeight)
        
        savedHeight =savedHeight + block.height
       
    end
    GwQuesttrackerContainerQuests:SetHeight(savedHeight)
    for i=numQuests + 1,25 do
        if _G['GwQuestBlock'..i]~=nil then
           _G['GwQuestBlock'..i]:Hide() 
            GwupdateQuestItem(_G['GwQuestItemButton'..i],0) 
        end
    end
    
    gwQuestTrackerLayoutChanged()
    
end

function gwRequestQustlogUpdate()
    updateQuestLogLayout()
end

function gwScanMapforObjective(questID)
    if WorldMapFrame:IsShown() then return end

    SetMapToCurrentZone()
   
    local scanMap = true
    local maxZoom = false
    local foundSomethingOnThisMap = false

    SetCVar("questPOI", 1)
    local max = 0
    local PposX, PposY  = GetPlayerMapPosition("player");
    
    while scanMap and max<5 do
            
        QuestPOIUpdateIcons()
       
          
        local _, posX, posY, objective = QuestPOIGetIconInfo(questID) 
          
                 
        if posX~=nil and posX~=0 and PposX~=nil and PposX~=0 then

           local mapId,currentFloor =  GetCurrentMapAreaID()
            
            SetMapToCurrentZone()
         --   SetCVar("questPOI", cvar and 1 or 0)
     
            return true, posX, posY, objective, mapId 

            
        end
    
        if  maxZoom then
            scanMap = false;
        end
        
        if  ZoomOut() ~= nil then
            if ( GetCurrentMapContinent() == WORLDMAP_AZEROTH_ID ) then
                SetMapZoom(WORLDMAP_AZEROTH_ID);
                maxZoom = true
            elseif ( GetCurrentMapContinent() == WORLDMAP_OUTLAND_ID  )then
                SetMapZoom(WORLDMAP_OUTLAND_ID);
                maxZoom = true
            elseif ( GetCurrentMapContinent() == WORLDMAP_DRAENOR_ID ) then
                SetMapZoom(WORLDMAP_DRAENOR_ID);
                maxZoom = true
            else
                SetMapZoom(WORLDMAP_AZEROTH_ID);
                maxZoom = true
            end
        end

        max =max +1
    end
         
    SetMapToCurrentZone()
  --  SetCVar("questPOI", cvar and 1 or 0)
    return false
 
end




function gwQuestTrackerLayoutChanged()

    updateExtraQuestItemPositions()
    
    GwQuestTrackerScroll:SetSize(400,GwQuesttrackerContainerBonusObjectives:GetHeight() + GwQuesttrackerContainerQuests:GetHeight())
    
  

end


local function QuestTracker_OnEvent(self,event,data1)

        updateQuestLogLayout(data1)


end



local function playerDeadState (self,event) 
        
        if not UnitIsDeadOrGhost('PLAYER') then
                gwRemoveTrackerNotificationOfType('DEAD')
                return
        end
        
            
        local compassData = {}    
            
        local x, y = GetCorpseMapPosition()
        local PposX, PposY  = GetPlayerMapPosition("player");
    
        if PposX==nil or PposX==0 then return end    
    
        compassData['TYPE']= 'DEAD'
           compassData['TITLE']= GwLocalization['TRACKER_RETRIVE_CORPSE']
           compassData['ID']='playerDead'
           
           compassData['COLOR']=  GW_TRAKCER_TYPE_COLOR['DEAD']
           compassData['COMPASS'] = true
           compassData['X'] = x
           compassData['Y'] = y
           compassData['QUESTID']= ''
            compassData['MAPID'] = ''
            compassData['DESC'] = ''
    
        gwAddTrackerNotification(compassData) 
            
  
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
    CreateFrame('Frame','GwQuesttrackerContainerAchievement',GwQuestTracker,'GwQuesttrackerContainer') 
    
    CreateFrame('Frame','GwQuesttrackerContainerQuests',GwQuestTrackerScrollChild,'GwQuesttrackerContainer') 
    CreateFrame('Frame','GwQuesttrackerContainerBonusObjectives',GwQuestTrackerScrollChild,'GwQuesttrackerContainer')
    GwQuesttrackerContainerAchievement:SetParent(GwQuestTrackerScrollChild)
    GwQuesttrackerContainerQuests:SetParent(GwQuestTrackerScrollChild)
    GwQuesttrackerContainerBonusObjectives:SetParent(GwQuestTrackerScrollChild)
    
    
    if gwGetSetting('MINIMAP_ENABLED') then
    GwQuestTracker:SetPoint('TOPRIGHT',UIParent,'TOPRIGHT')
    GwQuestTracker:SetPoint('BOTTOMRIGHT',Minimap,'TOPRIGHT')
    else
        GwQuestTracker:SetPoint('TOPRIGHT',Minimap,'BOTTOMRIGHT')
        GwQuestTracker:SetPoint('BOTTOMRIGHT',UIParent,'BOTTOMRIGHT')
    end
    
    GwObjectivesNotification:SetPoint('TOPRIGHT',GwQuestTracker,'TOPRIGHT')
    GwQuesttrackerContainerBossFrames:SetPoint('TOPRIGHT',GwObjectivesNotification,'BOTTOMRIGHT')
    GwQuesttrackerContainerScenario:SetPoint('TOPRIGHT',GwQuesttrackerContainerBossFrames,'BOTTOMRIGHT')
    
    GwQuestTrackerScroll:SetPoint('TOPRIGHT',GwQuesttrackerContainerScenario,'BOTTOMRIGHT')
    GwQuestTrackerScroll:SetPoint('BOTTOMRIGHT',GwQuestTracker,'BOTTOMRIGHT')
    
    GwQuestTrackerScrollChild:SetPoint('TOPRIGHT',GwQuestTrackerScroll,'TOPRIGHT')
    GwQuesttrackerContainerAchievement:SetPoint('TOPRIGHT',GwQuestTrackerScrollChild,'TOPRIGHT')
    GwQuesttrackerContainerQuests:SetPoint('TOPRIGHT',GwQuesttrackerContainerAchievement,'BOTTOMRIGHT')
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
	GwQuesttrackerContainerQuests:RegisterEvent("QUEST_POI_UPDATE");
	GwQuesttrackerContainerQuests:RegisterEvent("PLAYER_MONEY");
	GwQuesttrackerContainerQuests:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");
	GwQuesttrackerContainerQuests:RegisterEvent("QUEST_ACCEPTED");
    
    
    GwQuesttrackerContainerQuests:SetScript('OnUpdate', function() 
        if waitForUpdate then
            updateQuestLogLayout('update')
            waitForUpdate = false
        end
        updatedThisFrame = false
    end)
    

    
    GwQuesttrackerContainerQuests:SetScript('OnEvent',QuestTracker_OnEvent)
  
    
    
    local header = CreateFrame('Button','GwQuestHeader',GwQuesttrackerContainerQuests,'GwQuestTrackerHeader')
    header.icon:SetTexCoord(0,1,0.25,0.5)
    
    header:SetScript('OnClick',function(self) 
        local p = self:GetParent()
        if p.collapsed==nil or p.collapsed==false then
             p.collapsed = true
            PlaySound("igMainMenuOptionCheckBoxOff");
         else
             p.collapsed = false
            PlaySound("igMainMenuOptionCheckBoxOn");
         end    
        updateQuestLogLayout('COLLAPSE')
    end)
    header.title:SetTextColor(GW_TRAKCER_TYPE_COLOR['QUEST'].r,GW_TRAKCER_TYPE_COLOR['QUEST'].g,GW_TRAKCER_TYPE_COLOR['QUEST'].b)   
   
    loadQuestButtons()
    updateQuestLogLayout('load')
    
    
    
    
    gw_register_bossFrames()
    gw_register_scenarioFrame()
    gw_register_achievement()
    gw_register_bonusObjectiveFrame()
    
    GwObjectivesNotification:RegisterEvent('PLAYER_ALIVE')
    GwObjectivesNotification:RegisterEvent('PLAYER_DEAD')
    GwObjectivesNotification:RegisterEvent('PLAYER_UNGHOST')
    
	GwObjectivesNotification:RegisterEvent("ZONE_CHANGED_INDOORS");
	GwObjectivesNotification:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	GwObjectivesNotification:RegisterEvent("ZONE_CHANGED");
    
    GwObjectivesNotification:SetScript('OnEvent', playerDeadState)
    
    
    playerDeadState(GwObjectivesNotification,'')
    GwObjectivesNotification.shouldDisplay = false
    GwQuestTracker.trot = GetTime() + 2
    GwQuestTracker:SetScript('OnUpdate', function(self)
            if  GwQuestTracker.trot < GetTime() then
                
                local state = GwObjectivesNotification.shouldDisplay
               
                
                GwQuestTracker.trot = GetTime() + 1
                gwSetObjectiveNotification() 
           
                
                if state~=GwObjectivesNotification.shouldDisplay then
                    state = GwObjectivesNotification.shouldDisplay
                    gwNotificationStateChanged(state) 
                end
                
                           
                
            end
    end)

  
end

