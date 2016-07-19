GW_QUESTTRACKER_TYPE_COLORS = {}
GW_QUESTTRACKER_TYPE_COLORS['QUEST'] ={r=221/255,g=198/255,b=68/255}
GW_QUESTTRACKER_TYPE_COLORS['BONUS'] ={r=240/255,g=121/255,b=37/255}
GW_QUESTTRACKER_TYPE_COLORS['SCENARIO'] ={r=171/255,g=37/255,b=240/255}

GW_QUESTTRACKER_ICON = {}
GW_QUESTTRACKER_ICON['QUEST'] ={l=0,r=1,t=0.25,b=0.5}
GW_QUESTTRACKER_ICON['BONUS'] ={l=0,r=1,t=0.5,b=0.75}
GW_QUESTTRACKER_ICON['SCENARIO'] ={l=0,r=1,t=0.75,b=1}

GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS = {}
GW_QUESTTRACKER_LOADED_FRAMES = {}

GW_RADAR_DATA = {}

GW_HIDDEN_QUESTS = {}

GW_QUESTS = {}

local UPDATE_POI_SCAN = 0


local SCENARIO_FLAG_CHALLENGE_MODE		= 0x00000001;
local SCENARIO_FLAG_SUPRESS_STAGE_TEXT	= 0x00000002;
local SCENARIO_FLAG_PROVING_GROUNDS		= 0x00000004;
local SCENARIO_FLAG_USE_DUNGEON_DISPLAY	= 0x00000008;


local GW_TRACKER_PARENT_FRAMES = {}

local  bX,bY =0

local cvar = GetCVarBool("questPOI")


function gw_toggle_quest_hidden(qid)
    local found = false
    for k,v in pairs(GW_HIDDEN_QUESTS) do
        if k==qid then
            if v==true then
                GW_HIDDEN_QUESTS[k] = false
            else
                GW_HIDDEN_QUESTS[k] = true
            end
            found = true
        end
    end
    if not found then
        GW_HIDDEN_QUESTS[qid] =true
    end
end

function gw_load_questtracker()

    ObjectiveTrackerFrame:Hide()
    ObjectiveTrackerFrame:SetScript('OnShow', function() ObjectiveTrackerFrame:Hide() end)
    
    CreateFrame('Frame','GwQuestTracker',UIParent,'GwQuestTracker') 
    CreateFrame('Frame','GwQuestTrackerRadar',GwQuestTracker,'GwQuestTrackerRadar')
    
    CreateFrame('Frame','GwQuesttrackerContainerScenario',GwQuestTracker,'GwQuesttrackerContainer') 
    CreateFrame('Frame','GwQuesttrackerContainerQuests',GwQuestTracker,'GwQuesttrackerContainer') 
    CreateFrame('Frame','GwQuesttrackerContainerBonusObjectives',GwQuestTracker,'GwQuesttrackerContainer')     
    CreateFrame('Frame','GwQuesttrackerContainerBossFrames',GwQuestTracker,'GwQuesttrackerContainerProtected') 
    
    GwQuesttrackerContainerBonusObjectives:ClearAllPoints()
    GwQuesttrackerContainerQuests:ClearAllPoints()
    GwQuesttrackerContainerBossFrames:ClearAllPoints()
    GwQuesttrackerContainerScenario:ClearAllPoints()
    
    
    GwQuesttrackerContainerBonusObjectives:SetPoint('TOPRIGHT',GwQuesttrackerContainerQuests,'BOTTOMRIGHT',0,0)
    GwQuesttrackerContainerQuests:SetPoint('TOPRIGHT',GwQuesttrackerContainerScenario,'BOTTOMRIGHT',0,0)
    GwQuesttrackerContainerBossFrames:SetPoint('TOPRIGHT',UIParent,'TOPRIGHT',0,-75)
    GwQuesttrackerContainerScenario:SetPoint('TOPRIGHT',GwQuestTrackerRadar,'BOTTOMRIGHT',0,0)
    
    GW_TRACKER_PARENT_FRAMES['QUEST'] =GwQuesttrackerContainerQuests
    GW_TRACKER_PARENT_FRAMES['BONUS'] = GwQuesttrackerContainerBonusObjectives
    GW_TRACKER_PARENT_FRAMES['SCENARIO'] =GwQuesttrackerContainerScenario
    
    
    GwQuestTrackerRadar:SetScript('OnUpdate',gw_update_radar)
    
  	GwQuestTracker:SetScript('OnEvent',function(self,event) gw_questtracker_OnEvent(self,event) end)
  	GwQuestTracker:RegisterEvent("QUEST_GREETING");
	GwQuestTracker:RegisterEvent("QUEST_DETAIL");
	GwQuestTracker:RegisterEvent("QUEST_PROGRESS");
	GwQuestTracker:RegisterEvent("QUEST_COMPLETE");
	GwQuestTracker:RegisterEvent("QUEST_FINISHED");
	GwQuestTracker:RegisterEvent("QUEST_ITEM_UPDATE");
	GwQuestTracker:RegisterEvent("QUEST_LOG_UPDATE");
	GwQuestTracker:RegisterEvent("QUEST_REMOVED");
	GwQuestTracker:RegisterEvent("QUESTLINE_UPDATE");
	GwQuestTracker:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	GwQuestTracker:RegisterEvent("QUESTTASK_UPDATE");
	GwQuestTracker:RegisterEvent("TASK_PROGRESS_UPDATE");
    
    GwQuestTracker:RegisterEvent("QUEST_LOG_UPDATE");
	GwQuestTracker:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED");
	GwQuestTracker:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
	GwQuestTracker:RegisterEvent("QUEST_AUTOCOMPLETE");
	GwQuestTracker:RegisterEvent("QUEST_ACCEPTED");	
	GwQuestTracker:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");
	GwQuestTracker:RegisterEvent("SCENARIO_UPDATE");
	GwQuestTracker:RegisterEvent("SCENARIO_CRITERIA_UPDATE");
	GwQuestTracker:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE");
	GwQuestTracker:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	GwQuestTracker:RegisterEvent("ZONE_CHANGED");
	GwQuestTracker:RegisterEvent("QUEST_POI_UPDATE");
	GwQuestTracker:RegisterEvent("VARIABLES_LOADED");
	GwQuestTracker:RegisterEvent("QUEST_TURNED_IN");
	GwQuestTracker:RegisterEvent("PLAYER_MONEY");
    
    GwQuestTracker:RegisterEvent("WORLD_STATE_TIMER_START");
	GwQuestTracker:RegisterEvent("WORLD_STATE_TIMER_STOP");
	GwQuestTracker:RegisterEvent("PROVING_GROUNDS_SCORE_UPDATE");
	GwQuestTracker:RegisterEvent("SCENARIO_COMPLETED");
	GwQuestTracker:RegisterEvent("PLAYER_REGEN_DISABLED");
	GwQuestTracker:RegisterEvent("PLAYER_REGEN_ENABLED");
    
    WorldMapFrame:HookScript('OnHide',gw_questtracker_OnEvent)
    
    
    gw_questtracker_OnEvent()

end


local SAVED_RADAR_POSX = 0
local SAVED_RADAR_POSY = 0
local MAPID = 0
local RADAR_THRO = 0


function gw_update_radar()
         
   if WorldMapFrame:IsShown() then return end
    local posX, posY  = 0
    
    local CLOSEST_RADAR_POSX =nil
    local CLOSEST_RADAR_POSY = nil
    local CLOSEST_RADAR_TYPE = nil
    local CLOSEST_RADAR_TEXT = nil
    local CLOSEST_MAPID = nil
    
    if RADAR_THRO<GetTime() then
      RADAR_THRO = GetTime() + 1
        local closest = math.huge
        for k,v in pairs(GW_RADAR_DATA) do
            
            SetMapByID(v['mapID'])
            posX, posY  = GetPlayerMapPosition("player");
            
            local dx = v['posX'] - posX
            local dy = v['posY'] - posY
            local dist = sqrt(dx * dx + dy * dy)

            if dist<closest then
                closest=dist
                
                CLOSEST_RADAR_TEXT =v['title']
                CLOSEST_RADAR_TYPE =v['GW_TYPE']
 
                CLOSEST_RADAR_POSX = v['posX']
                CLOSEST_RADAR_POSY = v['posY']
                CLOSEST_RADAR_POSY = v['posY']
                CLOSEST_MAPID = v['mapID']

            end
        end
        
    end
    if CLOSEST_RADAR_POSX~=nil then
                   
                GwQuestTrackerRadarString:SetText(CLOSEST_RADAR_TEXT)
                GwQuestTrackerRadarString:SetTextColor(GW_QUESTTRACKER_TYPE_COLORS[CLOSEST_RADAR_TYPE].r,GW_QUESTTRACKER_TYPE_COLORS[CLOSEST_RADAR_TYPE].g,GW_QUESTTRACKER_TYPE_COLORS[CLOSEST_RADAR_TYPE].b)
                GwQuestTrackerRadarIcon:SetTexCoord(GW_QUESTTRACKER_ICON[CLOSEST_RADAR_TYPE].l,GW_QUESTTRACKER_ICON[CLOSEST_RADAR_TYPE].r,GW_QUESTTRACKER_ICON[CLOSEST_RADAR_TYPE].t,GW_QUESTTRACKER_ICON[CLOSEST_RADAR_TYPE].b)
                 
            SAVED_RADAR_POSX =CLOSEST_RADAR_POSX
            SAVED_RADAR_POSY =CLOSEST_RADAR_POSY
            MAPID = CLOSEST_MAPID
    end
        
        if GetCurrentMapAreaID()~=MAPID then
            SetMapByID(MAPID)
        end
       
        local pFaceing = GetPlayerFacing()
        posX, posY  =GetPlayerMapPosition("player");
        
        local dir_x  =SAVED_RADAR_POSX - posX
        local dir_y  =SAVED_RADAR_POSY - posY

                
        local square_half = math.sqrt(0.5)
        local rad_135 = math.rad(135)
       
        local a  = math.atan2(dir_y, dir_x)
        a=-a
        
        a = a + rad_135
        a = a -pFaceing
		
		local sin,cos = math.sin(a) * square_half, math.cos(a) * square_half

        _G['GwCompassArrow']:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)
    
end


function gw_questtracker_OnEvent(self,event,arg1,arg2)
  
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS = {}

    GW_QUESTS = {}
    gw_questtracker_setblock_unused()
    

    bX,bY = GetPlayerMapPosition("player");
    
    local playerMoney = GetMoney();
    for i = 1, GetNumQuestWatches() do
        
        local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(i);


		if ( questID ) then

            if isComplete and isComplete < 0  then
					isComplete = false;
            elseif  numObjectives == 0 and playerMoney >= requiredMoney and not startEvent  then
					isComplete = true;
            end
            
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i] ={}
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['TITLE'] = title
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['questID'] = questID
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['questLogIndex'] = questLogIndex
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['numObjectives'] = numObjectives
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['requiredMoney'] = requiredMoney
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['isComplete'] = isComplete
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['startEvent'] = startEvent
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['isAutoComplete'] = isAutoComplete
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['failureTime'] = failureTime
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['timeElapsed'] = timeElapsed
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['questType'] = questType
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['isTask'] = isTask
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['isStory'] = isStory
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['isOnMap'] = isOnMap
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['hasLocalPOI'] = hasLocalPOI
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['GW_TYPE'] = 'QUEST'
            
            

           gw_update_questobjectives(i,numObjectives,questID,questLogIndex)
        end
    end
    
    if event=='TASK_PROGRESS_UPDATE' then

    end
    gw_check_tasks()
    gw_check_senario()
    gw_display_questtracker_layout()
    
    gw_questtracker_hide_unused()
    gw_toggle_radar()

end

function gw_update_questobjectives(QuestWatchIndex, numObjectives, questID,questLogIndex)
    
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[QuestWatchIndex]['OBJECTIVES'] = {}
    for objectiveIndex = 1, numObjectives do
        
		local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questLogIndex);
         GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[QuestWatchIndex]['OBJECTIVES'][objectiveIndex] ={}
         GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[QuestWatchIndex]['OBJECTIVES'][objectiveIndex]['questLogIndex'] = questLogIndex
         GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[QuestWatchIndex]['OBJECTIVES'][objectiveIndex]['text'] = text
         GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[QuestWatchIndex]['OBJECTIVES'][objectiveIndex]['objectiveType'] = objectiveType
         GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[QuestWatchIndex]['OBJECTIVES'][objectiveIndex]['finished'] = finished   
         GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[QuestWatchIndex]['OBJECTIVES'][objectiveIndex]['questID'] = questID   
    end
   gw_update_questitems(questLogIndex,QuestWatchIndex)
end


function gw_check_senario()
    local scenarioName, currentStage, numStages, flags, _, _, completed, xp, money = C_Scenario.GetInfo();
    if ( numStages == 0 ) then
		return
	end



    local stageName, stageDescription, numCriteria = C_Scenario.GetStepInfo();

	local inChallengeMode = bit.band(flags, SCENARIO_FLAG_CHALLENGE_MODE) == SCENARIO_FLAG_CHALLENGE_MODE;
	local inProvingGrounds = bit.band(flags, SCENARIO_FLAG_PROVING_GROUNDS) == SCENARIO_FLAG_PROVING_GROUNDS;
	local dungeonDisplay = bit.band(flags, SCENARIO_FLAG_USE_DUNGEON_DISPLAY) == SCENARIO_FLAG_USE_DUNGEON_DISPLAY;
	local scenariocompleted = currentStage > numStages;
    
    local i = countTable(GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS)+1
    
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i] ={}
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['TITLE'] = stageName
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['questID'] = '0'
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['questLogIndex'] = 0
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['numObjectives'] = numCriteria
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['isComplete'] = false
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['isTask'] = false
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['isOnMap'] = true
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['flags'] = flags
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['subHeader'] = stageDescription
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['GW_TYPE'] = 'SCENARIO'
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES']={}
    
    local lastInserted = 1

    
    for criteriaIndex = 1, numCriteria do
        local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, __, isWeightedProgress = C_Scenario.GetCriteriaInfo(criteriaIndex);

       local objectiveType ='progressbar'
        if not isWeightedProgress then
            criteriaString = string.format("%d/%d %s", quantity, totalQuantity, criteriaString);
            objectiveType = 'monster'
        end
        GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][criteriaIndex] ={}
        GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][criteriaIndex]['questLogIndex'] = 0
        GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][criteriaIndex]['text'] = criteriaString
        GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][criteriaIndex]['objectiveType'] = objectiveType
        GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][criteriaIndex]['finished'] = false   
        GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][criteriaIndex]['quantity'] = quantity   
        GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][criteriaIndex]['GW_TYPE'] = 'SCENARIO'   
        GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][criteriaIndex]['questID'] = 0  
        lastInserted = criteriaIndex
    end
    
 
    
    local bonusSteps = C_Scenario.GetBonusSteps();
    for k,v in pairs(bonusSteps) do
        bonusStepIndex = v
        local scenarioName, currentStage, numStages, flags, _, _, completed, xp, money = C_Scenario.GetInfo(bonusStepIndex);
        
        local stageName, stageDescription, numCriteria = C_Scenario.GetStepInfo(bonusStepIndex);
        
        for criteriaIndex = 1, numCriteria do
            local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex,criteriaIndex);
             criteriaString = string.format("%d/%d %s", quantity, totalQuantity, criteriaString);
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][lastInserted+criteriaIndex] ={}
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][lastInserted+criteriaIndex]['questLogIndex'] = 0
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][lastInserted+criteriaIndex]['text'] = criteriaString
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][lastInserted+criteriaIndex]['objectiveType'] = monster
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][lastInserted+criteriaIndex]['finished'] = false   
            GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][lastInserted+criteriaIndex]['questID'] = 0  
        end
    
    end


    
end

function gw_check_tasks()
    local tasks = GetTasksTable();
    for k,v in pairs(tasks) do
        gw_bonusobjective_update(v)
    end 
end

function gw_bonusobjective_update(questID) 
    
    local i = countTable(GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS)+1
    local isInArea, isOnMap, numObjectives, text = GetTaskInfo(questID)
    
    if not isInArea then return end
    
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i] ={}
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['TITLE'] = text
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['questID'] = questID
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['questLogIndex'] = 0
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['numObjectives'] = numObjectives
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['isComplete'] = false
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['isTask'] = true
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['isOnMap'] = isOnMap
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['GW_TYPE'] = 'BONUS'
   
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES']={}
    for objectiveIndex = 1,numObjectives do
        local text, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, true);
        finished =false
        GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][objectiveIndex] ={}
         GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][objectiveIndex]['questLogIndex'] = 0
         GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][objectiveIndex]['text'] = text
         GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][objectiveIndex]['objectiveType'] = objectiveType
         GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][objectiveIndex]['finished'] = finished   
         GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[i]['OBJECTIVES'][objectiveIndex]['questID'] = questID  
    end
end


function gw_update_questitems(questLogIndex,QuestWatchIndex) 
   local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex); 
    
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[QuestWatchIndex]['link']=link
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[QuestWatchIndex]['item']=item
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[QuestWatchIndex]['charges']=charges
    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[QuestWatchIndex]['showItemWhenComplete']=showItemWhenComplete
end


function gw_display_questtracker_layout() 
    local OBJECTIVE_HEIGHT = 20
    local QUEST_HEADER_HEIGHT = 30
    local USED_HEIGHT = {}

    USED_HEIGHT['QUEST'] = 0
    USED_HEIGHT['BONUS'] = 0
    USED_HEIGHT['SCENARIO'] = 0
    
    
    
    local QUESTINDEX = 1
    
    for k,v in pairs(GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS) do
        
        subHeader_Height = 0
    
        local QUEST_CONTAINER_FRAME = gw_request_questContainer(k,GW_TRACKER_PARENT_FRAMES[v['GW_TYPE']])
  
        QUEST_CONTAINER_FRAME.used = true
        QUEST_CONTAINER_FRAME:Show()
        QUEST_CONTAINER_FRAME:SetPoint('TOPRIGHT',GW_TRACKER_PARENT_FRAMES[v['GW_TYPE']],'TOPRIGHT',0,-USED_HEIGHT[v['GW_TYPE']])
        
        _G[QUEST_CONTAINER_FRAME:GetName()..'QuestName']:SetFont(DAMAGE_TEXT_FONT,14)
        _G[QUEST_CONTAINER_FRAME:GetName()..'QuestName']:SetShadowOffset(-1,-1)
        _G[QUEST_CONTAINER_FRAME:GetName()..'QuestName']:SetTextColor(GW_QUESTTRACKER_TYPE_COLORS[v['GW_TYPE']].r,GW_QUESTTRACKER_TYPE_COLORS[v['GW_TYPE']].g,GW_QUESTTRACKER_TYPE_COLORS[v['GW_TYPE']].b)
        _G[QUEST_CONTAINER_FRAME:GetName()..'QuestName']:SetText(v['TITLE'])
        
        _G[QUEST_CONTAINER_FRAME:GetName()..'QuestSubHeader']:SetFont(UNIT_NAME_FONT,12)
        _G[QUEST_CONTAINER_FRAME:GetName()..'QuestSubHeader']:SetShadowOffset(-1,-1)
        
        local subHeader =''
        if GW_HIDDEN_QUESTS[v['questID']]~=nil and GW_HIDDEN_QUESTS[v['questID']]==false then
            if v['subHeader']~=nil and v['subHeader']~='' then
                subHeader = v['subHeader']
                subHeader_Height = 30
            end
        end
        _G[QUEST_CONTAINER_FRAME:GetName()..'QuestSubHeader']:SetText(subHeader)
        
        
        if ( IsQuestComplete(v['questID']) and GetQuestLogIsAutoComplete(v['questLogIndex']) ) then
				QUEST_CONTAINER_FRAME:SetScript('OnClick',function() ShowQuestComplete(v['questLogIndex']) end)
			else
				QUEST_CONTAINER_FRAME:SetScript('OnClick', function()  gw_toggle_quest_hidden(v['questID']) gw_questtracker_OnEvent() end )
            
        end

        

        
        if not InCombatLockdown() then
            local itemButton = _G[QUEST_CONTAINER_FRAME:GetName()..'ItemButton']
            if ( v['item'] and ( not v['isQuestComplete'] or v['showItemWhenComplete'] ) ) then
        
                itemButton:SetID( v['questLogIndex']);
                itemButton.charges =  v['charges'];
                itemButton.rangeTimer = -1;
                SetItemButtonTexture(itemButton,  v['item']);
                SetItemButtonCount(itemButton,  v['charges']);
                QuestObjectiveItem_UpdateCooldown(itemButton);
                itemButton:Show();


            else
                itemButton:Hide();
            end
        end
        if v['isComplete']  then

            local objectiveCount = countTable(GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[k]['OBJECTIVES'])
             GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[k]['OBJECTIVES'][objectiveCount] = {}
             GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[k]['OBJECTIVES'][objectiveCount]['finished'] = false
            if ( v['isAutoComplete'] ) then
                
                GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[k]['OBJECTIVES'][objectiveCount]['text'] = QUEST_WATCH_QUEST_COMPLETE
                GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[k]['OBJECTIVES'][objectiveCount]['text'] = QUEST_WATCH_CLICK_TO_COMPLETE
            else
                if not v['isBreadcrumb']  then
                    GW_QUESTTRACKER_ACTIVE_QUEST_BLOCKS[k]['OBJECTIVES'][objectiveCount]['text'] = QUEST_WATCH_QUEST_READY
                    
                end
            end
        end
        
        local GQ = countTable(GW_QUESTS)
        GW_QUESTS[GQ] = {}
        GW_QUESTS[GQ]['title'] = v['TITLE']
        GW_QUESTS[GQ]['GW_TYPE'] = v['GW_TYPE']
        GW_QUESTS[GQ]['questID'] = v['questID']

        local objective_count = 1
        USED_HEIGHT[v['GW_TYPE']] = USED_HEIGHT[v['GW_TYPE']] + QUEST_HEADER_HEIGHT 
        local USED_OBJECTIVE_HEIGHT = 0
        
        
        if GW_HIDDEN_QUESTS[v['questID']]==nil or GW_HIDDEN_QUESTS[v['questID']]==false then
            USED_OBJECTIVE_HEIGHT=  QUEST_HEADER_HEIGHT + subHeader_Height
            for objective_k,objective_v in pairs(v['OBJECTIVES']) do


                if not objective_v['finished'] then

                    if objective_count==1 then USED_OBJECTIVE_HEIGHT = USED_OBJECTIVE_HEIGHT -OBJECTIVE_HEIGHT end

                     USED_OBJECTIVE_HEIGHT = USED_OBJECTIVE_HEIGHT + OBJECTIVE_HEIGHT

                    local QUEST_OBJECTIVE_CONTAINER = gw_request_objectiveContainer(QUEST_CONTAINER_FRAME,k,objective_k)
                     QUEST_OBJECTIVE_CONTAINER.used = true
                     QUEST_OBJECTIVE_CONTAINER:Show()


                    gw_setobjective_style(QUEST_CONTAINER_FRAME,QUEST_OBJECTIVE_CONTAINER,USED_OBJECTIVE_HEIGHT,v['GW_TYPE'])
                    _G[QUEST_OBJECTIVE_CONTAINER:GetName()..'String']:SetText(objective_v['text'])

                      if gw_objective_use_statusbar(objective_v['text'],QUEST_OBJECTIVE_CONTAINER:GetName()) or gw_objective_use_builtin_bar(objective_v,QUEST_OBJECTIVE_CONTAINER:GetName()) then 
                        USED_OBJECTIVE_HEIGHT = USED_OBJECTIVE_HEIGHT + 15
                    end
                    objective_count = objective_count + 1
                end   
            end    
        end    
        QUEST_CONTAINER_FRAME:SetHeight(USED_OBJECTIVE_HEIGHT+QUEST_HEADER_HEIGHT)
        USED_HEIGHT[v['GW_TYPE']] = USED_HEIGHT[v['GW_TYPE']] + USED_OBJECTIVE_HEIGHT
        
    end
    local BOSS_FRAME_HEIGHT = 0
    for bossFrameIndex = 1,5 do 

        if _G['GwQuestTrackerBossFrame'..bossFrameIndex] and _G['GwQuestTrackerBossFrame'..bossFrameIndex]:IsShown() then
             BOSS_FRAME_HEIGHT = BOSS_FRAME_HEIGHT + 35 
        end
    end
    if BOSS_FRAME_HEIGHT>0 then
        BOSS_FRAME_HEIGHT = BOSS_FRAME_HEIGHT + 20 
    end
    
    GwQuesttrackerContainerQuests:SetHeight(math.max(1,USED_HEIGHT['QUEST']))
    GwQuesttrackerContainerBonusObjectives:SetHeight(math.max(1,USED_HEIGHT['BONUS']))
    GwQuesttrackerContainerScenario:SetHeight(math.max(1,USED_HEIGHT['SCENARIO']))
    GwQuesttrackerContainerScenario:SetPoint('TOPRIGHT',GwQuestTrackerRadar,'BOTTOMRIGHT',0,-BOSS_FRAME_HEIGHT)
  --  GwQuesttrackerContainerBossFrames:SetHeight(math.max(1,BOSS_FRAME_HEIGHT))
    
    if UPDATE_POI_SCAN < GetTime() then
        gw_find_bonusObjectives()
        gw_findPOI()
        UPDATE_POI_SCAN = GetTime() + 1
    end
    
end


function gw_find_bonusObjectives()

    local mapAreaID = GetCurrentMapAreaID();
    local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(mapAreaID);
    local numTaskPOIs = 0;
   
    if(taskInfo ~= nil) then
        numTaskPOIs = #taskInfo;
    end
    
    
    local taskIconCount = 1;
    if ( numTaskPOIs > 0 ) then
        local GQ = countTable(GW_QUESTS) + 1
        for _, info  in next, taskInfo do
			
          for k,v in pairs(info) do

            end
            GW_QUESTS[GQ] = {}
            GW_QUESTS[GQ]['title'] = 'Event Nearby'
            GW_QUESTS[GQ]['GW_TYPE'] = 'BONUS'
            GW_QUESTS[GQ]['questID'] = info.questId
            GW_QUESTS[GQ]['posX'] = info.x
            GW_QUESTS[GQ]['posY'] = info.Y
            GQ = GQ+1
        end
	end
	
    
end


function gw_findPOI()
    if WorldMapFrame:IsShown() then return end
    GW_RADAR_DATA = {}
    SetMapToCurrentZone()
    local RADAR_INDEX = 1
    local scanMap = true
    local maxZoom = false
    local foundSomethingOnThisMap = false
    GW_RADAR_DATA ={}
    SetCVar("questPOI", 1)
    local max = 0
    
    while scanMap and max<5 do

        for k,v in pairs(GW_QUESTS) do
            
            QuestPOIUpdateIcons()
            local posX = 0
            local posY = 0
            if v['posX']~=nil and v['posY']~=nil then
                posX=v['posX']
                posY=v['posY']
            else
                _, posX, posY, objective = QuestPOIGetIconInfo(v['questID']) 
            end
               
            if posX~=nil then
                mapId,currentFloor =  GetCurrentMapAreaID()
                GW_RADAR_DATA[RADAR_INDEX] ={}
                GW_RADAR_DATA[RADAR_INDEX]['posX'] = posX
                GW_RADAR_DATA[RADAR_INDEX]['posY'] = posY
                GW_RADAR_DATA[RADAR_INDEX]['objective'] = objective
                GW_RADAR_DATA[RADAR_INDEX]['title'] = v['title']
                GW_RADAR_DATA[RADAR_INDEX]['GW_TYPE'] = v['GW_TYPE']
                GW_RADAR_DATA[RADAR_INDEX]['mapID'] =mapId
                
                RADAR_INDEX = RADAR_INDEX + 1
                foundSomethingOnThisMap = true
            end
        end
        if foundSomethingOnThisMap then
            scanMap = false;
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
         
    SetCVar("questPOI", cvar and 1 or 0)
    if countTable(GW_RADAR_DATA)<1 then
       
        gw_display_suggested()
        return
    end
    GwQuestTrackerRadarSubString:SetText('')
end
function gw_display_suggested()
    local suggested = {}
	   C_AdventureJournal.GetSuggestions(suggested);

    -- hide all the display info
    for i = 1, 1 do  
        if suggested[i]~=nil and suggested[i].title~=nil then
            GwQuestTrackerRadarString:SetText('More adventures await:' )
            GwQuestTrackerRadarSubString:SetText(suggested[i].title)       
            GwQuestTrackerRadarSubString:SetTextColor(1,1,1)       
        else
            GwQuestTrackerRadarSubString:SetText(' ')
            GwQuestTrackerRadarString:SetText('')
        end
    end
end

function gw_objective_use_builtin_bar(objective_array,objectiveFrame)
    if objective_array['objectiveType']=='progressbar' then
        
            _G[objectiveFrame..'StatusBar']:Show()
            _G[objectiveFrame..'StatusBarBg']:Show()
            _G[objectiveFrame..'StatusBar']:SetMinMaxValues(0, 100)
            if objective_array['GW_TYPE']=='SCENARIO' then
                _G[objectiveFrame..'StatusBar']:SetValue(objective_array['quantity'])
            else  
                _G[objectiveFrame..'StatusBar']:SetValue(GetQuestProgressBarPercent(objective_array['questID']) )
            end
        return true
    end
    _G[objectiveFrame..'StatusBar']:Hide()
    _G[objectiveFrame..'StatusBarBg']:Hide()
    return false
end


function gw_setobjective_style(QUEST_CONTAINER_FRAME,QUEST_OBJECTIVE_CONTAINER,USED_OBJECTIVE_HEIGHT,ObjectiveType)

    QUEST_OBJECTIVE_CONTAINER:ClearAllPoints()
    QUEST_OBJECTIVE_CONTAINER:SetPoint('TOPRIGHT',QUEST_CONTAINER_FRAME,'TOPRIGHT',0,-USED_OBJECTIVE_HEIGHT)
    _G[QUEST_OBJECTIVE_CONTAINER:GetName()..'StatusBar']:SetStatusBarColor(GW_QUESTTRACKER_TYPE_COLORS[ObjectiveType].r,GW_QUESTTRACKER_TYPE_COLORS[ObjectiveType].g,GW_QUESTTRACKER_TYPE_COLORS[ObjectiveType].b)
    _G[QUEST_OBJECTIVE_CONTAINER:GetName()..'String']:SetFont(UNIT_NAME_FONT,12)
    _G[QUEST_OBJECTIVE_CONTAINER:GetName()..'String']:SetShadowOffset(-1,-1)
    
end


function gw_objective_use_statusbar(text, objectiveFrame)
    if text==nil then return false end

       local i, j, itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
        if numItems==nil then
           numItems,numNeeded,itemName = string.match(text, "(%d+)/(%d+) (%S+)");
        end
        numItems= tonumber(numItems)
        numNeeded= tonumber(numNeeded)
    
        if numItems~=nil and numNeeded~=nil and numNeeded>1 and numItems<numNeeded then
        
            _G[objectiveFrame..'StatusBar']:Show()
            _G[objectiveFrame..'StatusBarBg']:Show()
            _G[objectiveFrame..'StatusBar']:SetMinMaxValues(0, numNeeded)
            _G[objectiveFrame..'StatusBar']:SetValue(numItems)
   
            return true
        end
    _G[objectiveFrame..'StatusBar']:Hide()
    _G[objectiveFrame..'StatusBarBg']:Hide()
    return false
    
end

function gw_request_questContainer(k,parent)
    local frameName = 'GwQuesttrackerObject'..k
    if _G[frameName]==nil then
        local i = countTable(GW_QUESTTRACKER_LOADED_FRAMES)+1
        GW_QUESTTRACKER_LOADED_FRAMES[i] = CreateFrame('Button',frameName,parent,'GwQuesttrackerObject')
        _G[frameName..'ItemButton'].icon:SetTexCoord(0.1,0.9,0.1,0.9)
        _G[frameName..'ItemButton'].NormalTexture:SetTexture(nil)
    end
    return _G[frameName]
end

function gw_request_objectiveContainer(parent,parentId,k)
    local frameName = 'GwQuesttrackerObjectiveNormal'..parentId..'Objective'..k
    if _G[frameName]==nil then
        local i = countTable(GW_QUESTTRACKER_LOADED_FRAMES)+1
        GW_QUESTTRACKER_LOADED_FRAMES[i] = CreateFrame('FRAME',frameName,parent,'GwQuesttrackerObjectiveNormal')
    end
    return _G[frameName]
end
function gw_questtracker_setblock_unused()
    for k,v in pairs(GW_QUESTTRACKER_LOADED_FRAMES) do
        v.used=false
    end
end
function gw_questtracker_hide_unused()
    for k,v in pairs(GW_QUESTTRACKER_LOADED_FRAMES) do
        if v.used==false then
            v:Hide()
        end
    end
end

function gw_toggle_radar()
    
    if GW_RADAR_DATA~=nil  then  
        GwQuestTrackerRadar:SetPoint('TOPRIGHT',0,0)
    else 
        GwQuestTrackerRadar:SetPoint('TOPRIGHT',0,70)
    end
    
end

function gw_load_bossFrame(i)
    
    local debug_unit_Track = 'boss'..i
    

    
    local targetF = CreateFrame('Button','GwQuestTrackerBossFrame'..i,GwQuesttrackerContainerBossFrames,'GwQuestTrackerBossFrame')

    targetF:SetPoint('TOPRIGHT',GwQuesttrackerContainerBossFrames,'TOPRIGHT',0,(-35*i)- -35)
    
    
    targetF:SetAttribute("unit", debug_unit_Track);
    targetF:SetFrameStrata('HIGH');

    targetF:SetAttribute("*type1", 'target')
    targetF:SetAttribute("*type2", "showmenu")
    targetF:SetAttribute("unit", debug_unit_Track)
    RegisterUnitWatch(targetF);
    targetF:EnableMouse(true)
    targetF:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    _G['GwQuestTrackerBossFrame'..i..'String']:SetFont(UNIT_NAME_FONT,12)
    _G['GwQuestTrackerBossFrame'..i..'String']:SetShadowOffset(-1,-1)
    
    _G['GwQuestTrackerBossFrame'..i..'StatusBar']:SetStatusBarColor(GW_QUESTTRACKER_TYPE_COLORS['SCENARIO'].r,GW_QUESTTRACKER_TYPE_COLORS['SCENARIO'].g,GW_QUESTTRACKER_TYPE_COLORS['SCENARIO'].b)
    _G['GwQuestTrackerBossFrame'..i..'Icon']:SetVertexColor(GW_QUESTTRACKER_TYPE_COLORS['SCENARIO'].r,GW_QUESTTRACKER_TYPE_COLORS['SCENARIO'].g,GW_QUESTTRACKER_TYPE_COLORS['SCENARIO'].b)

    
    targetF:RegisterEvent('UNIT_MAX_HEALTH')
    targetF:RegisterEvent('UNIT_HEALTH')
    targetF:RegisterEvent("PLAYER_TARGET_CHANGED");
    
    targetF:SetScript('OnShow',gw_questtracker_OnEvent )
    targetF:SetScript('OnHide',gw_questtracker_OnEvent )
    
    targetF:SetScript('OnShow',function()  gw_update_bossframe( _G['GwQuestTrackerBossFrame'..i], debug_unit_Track) end)
    targetF:SetScript('OnEvent',function() gw_update_bossframe( _G['GwQuestTrackerBossFrame'..i], debug_unit_Track)end)
    gw_update_bossframe( _G['GwQuestTrackerBossFrame'..i], debug_unit_Track)
    
end

 function gw_update_bossframe(self,debug_unit_Track)
        
            _G[self:GetName()..'String']:SetText(UnitName(debug_unit_Track)) 
            local health = UnitHealth(debug_unit_Track)
            local healthMax = UnitHealthMax(debug_unit_Track)
            local healthPrecentage = 0

            if health>0 and healthMax>0 then
                healthPrecentage = health/healthMax
            end
            _G[self:GetName()..'StatusBar']:SetValue(healthPrecentage)
    end

local DEFAULT_BOSS_FRAMES ={
    Boss1TargetFrame,
    Boss2TargetFrame,
    Boss3TargetFrame,
    Boss4TargetFrame,
}


function gw_load_all_bossFrames()
    
    gw_load_bossFrame(1)
    gw_load_bossFrame(2)
    gw_load_bossFrame(3)
    gw_load_bossFrame(4)
    
    for k,v in pairs(DEFAULT_BOSS_FRAMES) do
        if v~=nil then
            v:Hide()
            v:SetScript("OnEvent", nil);
        end
    end
    
   


    
    
    local fgw = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate')
    fgw:SetFrameRef('UIParent', UIParent)
    fgw:SetFrameRef('GwQuesttrackerContainerBossFrames', GwQuesttrackerContainerBossFrames)
    fgw:SetAttribute('_onstate-combat', [=[ 

        if newstate == 'show' then
            self:GetFrameRef('GwQuesttrackerContainerBossFrames'):SetPoint('TOPRIGHT',UIParent,'TOPRIGHT',0,-75)
        end
    ]=])
    RegisterStateDriver(fgw, 'combat', '[combat] show; hide')
    
end


