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
TRACKER_HEADER_CAMPAIGN_QUESTS                              = "Campaign";
OPTION_SHOW_ACTION_BAR                                      = "Action Bar %d";
local HBD
QuestCache                                                  = {}
QuestCache.quests                                           = {}
C_CVar                                                      = {}
C_Map                                                       = {}
C_AzeriteItem                                               = {}
C_AzeriteEmpoweredItem                                      = {}
C_ChatInfo                                                  = {}
C_QuestLog                                                  = {}
C_Container                                                 = {}
C_CurrencyInfo                                              = {}
--C_TradeSkillUI = {}
C_PerksActivities                                           = {}
C_IncomingSummon                                            = {}
C_GossipInfo                                                = {}
C_Reputation                                                = {}
C_MajorFactions                                             = {}
C_GuildInfo                                                 = {}
C_FriendList                                                = {}
--C_LFGList = {}
C_DateAndTime                                               = {}
--C_MountJournal = {}
C_TooltipInfo                                               = {}
C_SpecializationInfo                                        = {}

BACKPACK_CONTAINER                                          = 0
NUM_TOTAL_EQUIPPED_BAG_SLOTS                                = 4

Enum.ItemQuality                                            = {}
Enum.ItemQuality.Poor                                       = 0
Enum.ItemQuality.Common                                     = 1
Enum.ItemQuality.Uncommon                                   = 2
Enum.ItemQuality.Rare                                       = 3
Enum.ItemQuality.Epic                                       = 4
Enum.ItemQuality.Legendary                                  = 5
Enum.ItemQuality.Artifact                                   = 6
Enum.ItemQuality.Heirloom                                   = 7
Enum.ItemQuality.WoWToken                                   = 8

Enum.GarrisonType                                           = {}
Enum.GarrisonType.Type_6_0                                  = 2
Enum.GarrisonType.Type_7_0                                  = 3
Enum.GarrisonType.Type_8_0                                  = 9
Enum.GarrisonType.Type_9_0                                  = 111

Enum.GarrisonFollowerType                                   = {}
Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower = 1
Enum.GarrisonFollowerType.FollowerType_6_0__Boat            = 2
Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower = 4
Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower = 22
Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower = 123

Enum.QuestWatchType                                         = {}
Enum.QuestWatchType.Automatic                               = 0
Enum.QuestWatchType.Manual                                  = 1

ItemQuality                                                 = {}
ItemQuality.Poor                                            = 0
ItemQuality.Common                                          = 1
ItemQuality.Uncommon                                        = 2
ItemQuality.Rare                                            = 3
ItemQuality.Epic                                            = 4
ItemQuality.Legendary                                       = 5
ItemQuality.Artifact                                        = 6
ItemQuality.Heirloom                                        = 7
ItemQuality.WoWToken                                        = 8
Enum.SummonStatus                                           = {}
Enum.SummonStatus.Pending                                   = 1
Enum.SummonStatus.Accepted                                  = 2
Enum.SummonStatus.Declined                                  = 3

local function gw_artifact_points()
    local itemID, altItemID, name, icon, totalXP, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop, artifactTier =
        C_ArtifactUI.GetEquippedArtifactInfo();

    local numPoints = pointsSpent;
    local xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier);
    while totalXP >= xpForNextPoint and xpForNextPoint > 0 do
        totalXP = totalXP - xpForNextPoint;

        pointsSpent = pointsSpent + 1;
        numPoints = numPoints + 1;

        xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier);
    end
    return numPoints, totalXP, xpForNextPoint;
end

function QuestCache.Get(self, QuestID)
    if not QuestCache.quests[QuestID] then
        local max = C_QuestLog.GetNumQuestWatches()
        for i = 1, max do
            C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        end
        max = C_QuestLog.GetNumWorldQuestWatches()
        for i = 1, max do
            C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        end
    end

    return QuestCache.quests[QuestID]
end

function QuestCache.IsCampaign(self)
    if self.isStory ~= nil then
        return self.isStory
    end
    return false
end

function QuestCache.GetQuestLogIndex(self)
    if self.questLogIndex ~= nil then
        return self.questLogIndex
    end
    return false
end

function QuestCache.GetID(self)
    if self.questID ~= nil then
        return self.questID
    end
    return false
end

function QuestCache.IsComplete(self)
    if self.iscomplete ~= nil then
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
        return 0
    end
    return nil
end

function GetMaxLevelForPlayerExpansion()
    return 110
end

function IsPlayerAtEffectiveMaxLevel()
    return (UnitLevel("player") >= GetMaxLevelForPlayerExpansion())
end

function C_CVar.SetCVar(k, v)
    if not GetCVar(k) then return end
    SetCVar(k, v)
end

function C_CVar.GetCVar(v)
    return GetCVar(v)
end

function C_Map.GetBestMapForUnit(unit)
    HBD = LibStub("HereBeDragons-1.0")
    HBD:GetPlayerZone()
end

function C_Map.GetMapInfo(mapID)
    return GetMapInfo(mapID)
end

function C_ChatInfo.ReplaceIconAndGroupExpressions(input, noIconReplacement, noGroupReplacement)
    return ChatFrame_ReplaceIconAndGroupExpressions(input, noIconReplacement, noGroupReplacement)
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
    local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isBounty, isStory, isOnMap, hasLocalPOI =
        GetQuestWatchInfo(i);


    local _, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, _, _, displayQuestID, _, _, _, _, _, isHidden, isScaling =
        GetQuestLogTitle(questLogIndex)
    QuestCache.quests[questID] = {
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

    return questID
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

function C_QuestLog.AddQuestWatch(questWatchIndex)
    AddQuestWatch(C_QuestLog.GetLogIndexForQuestID(questWatchIndex))
end

function C_QuestLog.GetNextWaypointText(questID)
    return nil
end

function C_Container.GetContainerNumFreeSlots(i)
    return GetContainerNumFreeSlots(i)
end

function C_Container.GetContainerNumSlots(i)
    return GetContainerNumSlots(i)
end

function C_Container.GetContainerItemInfo(i, b)
    local iconFileID, stackCount, isLocked, quality, isReadable, hasLoot, hyperlink, isFiltered, hasNoValue, itemID, isBound =
        GetContainerItemInfo(i, b)
    local element = {}
    element.iconFileID = iconFileID
    element.stackCount = stackCount
    element.isLocked = isLocked
    element.quality = quality
    element.isReadable = isReadable
    element.hasLoot = hasLoot
    element.hyperlink = hyperlink
    element.isFiltered = isFiltered
    element.hasNoValue = hasNoValue
    element.itemID = itemID
    element.isBound = isBound
    return element

    --[[



        Field 	Type 	Description
iconFileID 	number 	
stackCount 	number 	
isLocked 	boolean 	
quality 	Enum.ItemQuality? 	
isReadable 	boolean 	
hasLoot 	boolean 	
hyperlink 	string 	Hyperlink
isFiltered 	boolean 	
hasNoValue 	boolean 	
itemID 	number 	
isBound 	boolean 	

    1. texture
        number - The icon texture (FileID) for the item in the specified bag slot.
    2. itemCount
        number - The number of items in the specified bag slot.
    3. locked
        boolean - True if the item is locked by the server, false otherwise.
    4. quality
        number - The Quality of the item.
    5. readable
        boolean - True if the item can be "read" (as in a book), false otherwise.
    6. lootable
        boolean - True if the item is a temporary container containing items that can be looted, false otherwise.
    7. itemLink
        string - The itemLink of the item in the specified bag slot.
    8. isFiltered
        boolean - True if the item is grayed-out during the current inventory search, false otherwise.
    9. noValue
        boolean - True if the item has no gold value, false otherwise.
    10. itemID
        number - The unique ID for the item in the specified bag slot.
    11. isBound
        boolean - True if the item is bound to the current character, false otherwise.





]] --
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
    t.name, t.quantity, t.iconFileID, t.earnedThisWeek, t.weeklyMax, t.maxQuantity, t.isDiscovered, t.rarity =
        GetCurrencyInfo(curid)
    return t
end

function C_GossipInfo.GetFriendshipReputation(factionID)
    local t = {}
    t.friendshipFactionID, t.friendRep, _, _, _, _, t.reaction, t.friendThreshold, t.nextFriendThreshold =
        GetFriendshipReputation(factionID)
    return t
end

function C_GossipInfo.GetFriendshipReputationRanks(friendID)
    local t = {}
    t.currentLevel, t.maxLevel = GetFriendshipReputationRanks(friendID)
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

function C_SpecializationInfo.CanPlayerUseTalentSpecUI()
    if GW.mylevel >= 10 then
        return true
    end
    return false
end

function C_SpecializationInfo.CanPlayerUsePVPTalentUI()
    return GW.mylevel == 100
end

function C_SpecializationInfo.GetSpellsDisplay(specializationID)
    return nil --NYI
end

local function getNumberFirends()
    local online = 0;
    local friend = 0;
    for i = 0, 50 do
        name, level, class, area, connected, status, note = GetFriendInfo(i);
        if name ~= nil then
            friend = friend + 1;
            if connected then
                online = online + 1;
            end
        end
    end
    return online, friend
end
function C_QuestLog.GetInfo(questLogIndex)
    for k, v in pairs(QuestCache.quests) do
        if v.questLogIndex == questLogIndex then
            return v
        end
    end
    return nil
end

AddProfiling("blizzardConstants", "C_QuestLog.GetInfo", C_QuestLog.GetInfo)
function C_FriendList.GetNumFriends()
    local onlineFriends, numberOfFriends = getNumberFirends();
    return numberOfFriends or 0
end

function C_FriendList.GetFriendInfoByIndex(index)
    local t = {}
    t.name, t.level, t.className, t.area, t.connected, t.notes, t.afk, t.guid = GetFriendInfo(index)
    return t
    --[[

connected 	boolean 	If the friend is online
name 	string 	
className 	string? 	Friend's class, or "Unknown" (if offline)
area 	string? 	Current location, or "Unknown" (if offline)
notes 	string? 	
guid 	string 	GUID, example: "Player-1096-085DE703"
level 	number 	Friend's level, or 0 (if offline)
dnd 	boolean 	If the friend's current status flag is DND
afk 	boolean 	If the friend's current status flag is AFK
rafLinkType 	Enum.RafLinkType🔗 	
mobile 	boolean
    ]]
end

function C_FriendList.GetNumOnlineFriends()
    local onlineFriends, numberOfFriends = getNumberFirends();

    return onlineFriends or 0
end

function C_FriendList.GetNumIgnores()
    return GetNumIgnores()
end

function C_FriendList.GetNumWhoResults()
    return GetNumWhoResults()
end

function C_FriendList.SetWhoToUi()
    return SetWhoToUI()
end

function C_FriendList.GetWhoInfo(index)
    local t = {}
    t.fullName, t.fullGuildName, t.level, t.raceStr, t.classStr, t.area, t.filename, t.gender = GetWhoInfo(index)
    return t
    --[[
fullName 	string 	Character-Realm name
fullGuildName 	string 	Guild name
level 	number 	
raceStr 	string 	
classStr 	string 	Localized class name
area 	string 	The character's current zone
filename 	string? 	Localization-independent classFilename
gender 	number 	Sex of the character. 2 for male, 3 for female
timerunningSeasonID 	number? 	10.2.7
    ]]
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
    return {}
end

function C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
    --[[
        ---@return number xp
---@return number totalLevelXP
    ]]

    local numPoints, artifactXP, xpForNextPoint = gw_artifact_points()
    return artifactXP, xpForNextPoint;
end

function C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
    local numPoints, artifactXP, xpForNextPoint = gw_artifact_points()
    return numPoints;
end

function C_AzeriteEmpoweredItem.IsHeartOfAzerothEquipped()
    return HasArtifactEquipped();
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

function GameTooltip_AddNormalLine(string, bool)
    GameTooltip:AddLine(string, bool)
end

function GameTooltip_SetTitle(string, bool)
    GameTooltip:AddLine(string, bool)
end
