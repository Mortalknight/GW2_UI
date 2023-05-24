local _, GW = ...
local function AddProfiling(name, func)
    if not name or type(name) ~= "string" or not func or (type(func) ~= "function" and type(func) ~= "table") then
        return
    end
    local callLine, _ = strsplit("\n", debugstack(2, 1, 0), 2)
    local unit = gsub(gsub(callLine, '%[string "@Interface\\AddOns\\GW2_UI\\', ""), '%.lua".*', "")
    unit = gsub(gsub(unit, '\\', "::"), '/', "::")
    local gName = "GW2_" .. unit
    GW[name] = func
end
TRACKER_HEADER_CAMPAIGN_QUESTS = "Campaign";
OPTION_SHOW_ACTION_BAR = "Action Bar %d";
local HBD
QuestCache = {}
QuestCache.quests = {}
C_CVar  = {}
C_Map = {}
C_AzeriteItem = {}
C_AzeriteEmpoweredItem = {}
C_Chatinfo = {}
C_QuestLog = {}
C_Container = {}
C_CurrencyInfo = {}
--C_TradeSkillUI = {}
C_PerksActivities = {}
C_IncomingSummon = {}
C_GossipInfo = {}
C_Reputation = {}
C_MajorFactions = {}
C_GuildInfo ={}
C_FriendList = {}
--C_LFGList = {}
C_DateAndTime = {}
--C_MountJournal = {}
C_TooltipInfo = {}

BACKPACK_CONTAINER = 0
NUM_TOTAL_EQUIPPED_BAG_SLOTS  = 4

Enum.ItemQuality = {}
Enum.ItemQuality.Poor= 0
Enum.ItemQuality.Common= 1
Enum.ItemQuality.Uncommon= 2
Enum.ItemQuality.Rare= 3
Enum.ItemQuality.Epic= 4
Enum.ItemQuality.Legendary= 5
Enum.ItemQuality.Artifact= 6
Enum.ItemQuality.Heirloom= 7
Enum.ItemQuality.WoWToken= 8

Enum.QuestWatchType = {}
Enum.QuestWatchType.Automatic = 0
Enum.QuestWatchType.Manual = 1

ItemQuality = {}
ItemQuality.Poor= 0
ItemQuality.Common= 1
ItemQuality.Uncommon= 2
ItemQuality.Rare= 3
ItemQuality.Epic= 4
ItemQuality.Legendary= 5
ItemQuality.Artifact= 6
ItemQuality.Heirloom= 7
ItemQuality.WoWToken= 8
Enum.SummonStatus = {}
Enum.SummonStatus.Pending = 1
Enum.SummonStatus.Accepted = 2
Enum.SummonStatus.Declined = 3

function QuestCache.Get(self,QuestID)
    if not QuestCache.quests[QuestID] then
        local max  = C_QuestLog.GetNumQuestWatches() 
        for i=1,max do 
            C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        end
        max =C_QuestLog.GetNumWorldQuestWatches()
        for i=1,max do 
            C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        end
    end
   
    return QuestCache.quests[QuestID]
end
function QuestCache.IsCampaign(self)
    if self.isStory~=nil then 
        return self.isStory
    end
    return false
end
function QuestCache.GetQuestLogIndex(self)
    if self.questLogIndex~=nil then 
        return self.questLogIndex
    end
    return false
end
function QuestCache.GetID(self)
    if self.questID~=nil then 
        return self.questID
    end
    return false
end
function QuestCache.IsComplete(self)
    if self.iscomplete~=nil then 
        return self.iscomplete
    end
    return false
end

function C_IncomingSummon.HasIncomingSummon()
    return false
end
function C_IncomingSummon.IncomingSummonStatus()
end
function UnitPhaseReason(unit) 
    if not UnitInPhase(unit) then 
        return  0
    end
    return nil
end
function GetMaxLevelForPlayerExpansion()
    return 110
end
function  IsPlayerAtEffectiveMaxLevel()
   return ( UnitLevel("player")>=GetMaxLevelForPlayerExpansion())
end

function C_CVar.SetCVar(v)
    if not GetCVar(v) then return end
    SetCVar(v)
end
function C_CVar.GetCVar(v)
    GetCVar(v)
end

function C_Map.GetBestMapForUnit(unit)
    HBD = LibStub("HereBeDragons-1.0")
    HBD:GetPlayerZone()
end

function C_AzeriteItem.FindActiveAzeriteItem()
    return nil
end
function C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID()
    return false
end
function IsCorruptedItem()
    return false 
end
function QuestUtils_ShouldDisplayExpirationWarning(questID)
    return false
end
function C_QuestLog.GetNumQuestLogEntries()
    return nil --GetNumQuestWatches()
end
function C_QuestLog.GetNumQuestWatches()
    return GetNumQuestWatches()
end
function C_QuestLog.GetNumWorldQuestWatches()
    return GetNumWorldQuestWatches()
end
function C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
   return GetWorldQuestWatchInfo(i)
end
function C_QuestLog.GetWorldQuestWatchInfo(i)
    return GetWorldQuestWatchInfo(i)
end
function C_QuestLog.GetLogIndexForQuestID(i)
    return GetQuestLogIndexByID(i)
end
function C_QuestLog.GetSelectedQuest(i)
    return GetQuestLogSelection(i)
end

function C_QuestLog.GetQuestIDForQuestWatchIndex(i)
   local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isBounty, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(i);
    

       local _, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, _, _, displayQuestID, _, _, _, _, _, isHidden, isScaling = GetQuestLogTitle(questLogIndex)
        QuestCache.quests[questID]= {
            questID = questID,
            title = title,
            level = level,
            suggestedGroup = suggestedGroup,
            isHeader = isHeader,
            isCollapsed = isCollapsed,
            frequency = frequency,
            displayQuestID = displayQuestID,
            isHidden = isHidden,
            isScaling = isScaling,
            questLogIndex = questLogIndex,
            numObjectives = numObjectives,
            requiredMoney = requiredMoney,
            iscomplete = isComplete,
            startEvent = startEvent,
            isAutoComplete = isAutoComplete,
            failureTime = failureTime,
            timeElapsed = timeElapsed,
            questType = questType,
            isTask = isTask,
            isBounty = isBounty,
            isStory = isStory,
            isOnMap = isOnMap,
            hasLocalPOI = hasLocalPOI,
            IsCampaign = QuestCache.IsCampaign,
            GetQuestLogIndex = QuestCache.GetQuestLogIndex,
            GetID = QuestCache.GetID,
            IsComplete = QuestCache.IsComplete,
        }

    return  questID
end
AddProfiling("blizzardConstants", "C_QuestLog.GetQuestIDForQuestWatchIndex", C_QuestLog.GetQuestIDForQuestWatchIndex)
function C_QuestLog.GetNumQuestObjectives(questID)
    return QuestCache:Get(questID).numObjectives
end
function C_QuestLog.GetRequiredMoney(questID) 
    return QuestCache:Get(questID).requiredMoney
end
function C_QuestLog.IsFailed(questID) 
    local q = QuestCache:Get(questID)
    return q.iscomplete and q.iscomplete < 0
end
function C_QuestLog.IsQuestBounty(questID)
    local q = QuestCache:Get(questID)
    return q and q.isBounty or false
end
function C_QuestLog.IsQuestTask()
    local q = QuestCache:Get(questID)
    return q and q.isTask or false
end
function  C_QuestLog.AddQuestWatch(questWatchIndex)

    AddQuestWatch(C_QuestLog.GetLogIndexForQuestID(questWatchIndex))
end
     
function C_Container.GetContainerNumFreeSlots(i)
   return GetContainerNumFreeSlots(i)
end
function C_Container.GetContainerNumSlots(i)
   return GetContainerNumSlots(i)
end
function C_Container.GetContainerItemInfo(i,b) 
   return GetContainerItemInfo(i,b)
end
function C_Container.ContainerIDToInventoryID(bag_idx)
    return NUM_BAG_SLOTS
end
function C_Container.GetContainerItemLink(bagID, slotIndex)
    return GetContainerItemLink(bagID, slotIndex)
end
function C_Container.UseContainerItem(BagID, slotID)
    return UseContainerItem(BagID, slotID)
end
function C_Container.SortBags()
    SortBags();
end

function C_TradeSkillUI.GetRecipesTracked(isRecraft)
    return {}
end
function C_PerksActivities.GetTrackedPerksActivities()
    return {}
end


function C_CurrencyInfo.GetCurrencyListSize()
    return GetCurrencyListSize()
end
function C_CurrencyInfo.GetCurrencyListInfo(i)
    local t = {}
     t.name, t.isHeader, t.isExpanded, t.isUnused, t.isShowInBackpack, t.quantity, t.iconFileID = GetCurrencyListInfo(i);
     return t
end
function C_CurrencyInfo.GetCurrencyListLink(i)
    return GetCurrencyListLink(i)
end
function C_CurrencyInfo.GetCurrencyInfo(curid)
    local t = {}
    t.name, t.quantity, t.iconFileID, t.earnedThisWeek, t.weeklyMax, t.maxQuantity, t.isDiscovered, t.rarity = GetCurrencyInfo(curid)
    return t
end

function  C_GossipInfo.GetFriendshipReputation(factionID)
    local t = {}
     t.friendshipFactionID, t.friendRep, _, _, _, _, t.reaction, t.friendThreshold, t.nextFriendThreshold = GetFriendshipReputation(factionID)
     return t
end
function C_Reputation.IsMajorFaction(factionID) 
    return false
end
function C_Reputation.IsFactionParagon()
    return false
end
function C_MajorFactions.GetMajorFactionData(factionID) 
    return nil
end
function C_GuildInfo.GuildRoster()
    return GuildRoster()
end
local function  getNumberFirends()
    local online = 0;
    local friend = 0;
  for i = 0,50 do
    name, level, class, area, connected, status, note = GetFriendInfo(i);
    if name~=nil then
      friend = friend  + 1;
      if connected then
        online = online + 1;
      end
    end
  
  end
  return online,friend
  end
function C_QuestLog.GetInfo(questLogIndex) 
    for k,v in pairs(QuestCache.quests) do
        if v.questLogIndex == questLogIndex then 
            return v 
        end
    end
    return nil
end
AddProfiling("blizzardConstants", "C_QuestLog.GetInfo",  C_QuestLog.GetInfo)
function C_FriendList.GetNumFriends() 
    local onlineFriends, numberOfFriends = getNumberFirends();
    return numberOfFriends or 0
end
function C_FriendList.GetNumOnlineFriends()
    local onlineFriends, numberOfFriends = getNumberFirends();

    return onlineFriends or 0
end
function C_MountJournal.GetCollectedDragonridingMounts()
   return {}
end
function C_MountJournal.GetMountIDs()
    return {}
end
function C_MountJournal.GetNumMountsNeedingFanfare()
    return 0
end
function C_LFGList.CanCreateQuestGroup(questID) 
    return false;
end

function C_DateAndTime.GetSecondsUntilDailyReset()
    return GetQuestResetTime();
end
function C_DateAndTime.GetSecondsUntilWeeklyReset()
    return GetQuestResetTime();
end
function C_TooltipInfo.GetInventoryItem(unit, slot)
    return{}
end


function IsOnGroundFloorInJailersTower()
    return false
end
function IsInJailersTower()
    return false
end



function GameTooltip_AddColoredLine(string, color)
    GameTooltip:AddLine(string)
end
function GameTooltip_AddNormalLine(string,bool)
    GameTooltip:AddLine(string,bool)
end
function GameTooltip_SetTitle(string,bool)
    GameTooltip:AddLine(string,bool)
end
