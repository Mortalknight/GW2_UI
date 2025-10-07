local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local lastAQW = GetTime()
local tomTomWaypoint = nil

local function AddTomTomWaypoint(questId, objective)
    if TomTom and TomTom.AddWaypoint and Questie and Questie.started then
        local QuestieQuest = QuestieLoader:ImportModule("QuestieDB").GetQuest(questId)
        local spawn, zone, name = QuestieLoader:ImportModule("DistanceUtils").GetNearestSpawnForQuest(QuestieQuest)
        if (not spawn) and objective ~= nil then
            spawn, zone, name = QuestieLoader:ImportModule("DistanceUtils").GetNearestSpawn(objective)
        end
        if spawn then
            if tomTomWaypoint and TomTom.RemoveWaypoint then -- remove old waypoint
                TomTom:RemoveWaypoint(tomTomWaypoint)
            end
            local uiMapId = QuestieLoader:ImportModule("ZoneDB"):GetUiMapIdByAreaId(zone)
            tomTomWaypoint = TomTom:AddWaypoint(uiMapId, spawn[1] / 100, spawn[2] / 100,  {title = name, crazy = true})
        end
    end
end

local function LinkQuestIntoChat(title, questId)
    if not ChatFrame1EditBox:IsVisible() then
        if Questie and Questie.started then
            ChatFrame_OpenChat("[" .. title .. " (" .. questId .. ")]")
        else
            ChatFrame_OpenChat(gsub(title, " *(.*)", "%1"))
        end
    else
        if Questie and Questie.started then
            ChatEdit_InsertLink("[" .. title .. " (" .. questId .. ")]")
        else
            ChatEdit_InsertLink(gsub(title, " *(.*)", "%1"))
        end
    end
end

local function UntrackQuest(questLogIndex)
    local questID = GetQuestIDFromLogIndex(questLogIndex)
    for index, value in ipairs(QUEST_WATCH_LIST) do
        if value.id == questID then
            tremove(QUEST_WATCH_LIST, index)
        end
    end
    if GetCVar("autoQuestWatch") == "0" then
        GW2UI_QUEST_WATCH_DB.TrackedQuests[questID] = nil
    else
        GW2UI_QUEST_WATCH_DB.AutoUntrackedQuests[questID] = true
    end
    RemoveQuestWatch(questLogIndex)
    QuestWatch_Update()
    QuestLog_Update()
end

local function AddQuestInfos(questId, id)
    local title, level, group, _, _, isComplete, _, _, startEvent = GetQuestLogTitle(id)
    local sourceItemId = nil
    local isFailed = false

    if Questie and Questie.started then
        local questieQuest = QuestieLoader:ImportModule("QuestieDB").GetQuest(questId)
        if questieQuest and questieQuest.sourceItemId then
            sourceItemId = questieQuest.sourceItemId
        end
    end

    if isComplete == nil then
        isComplete = false
    elseif isComplete == 1 then
        isComplete = true
    else
        isComplete = false
        isFailed = true
    end

    return {
        questId = questId,
        questWatchedId = id or 0,
        questLogIndex = id,
        questLevel = level,
        questGroup = group,
        title = title,
        isComplete = isComplete,
        startEvent = startEvent,
        numObjectives = GetNumQuestLeaderBoards(id),
        requiredMoney = GetQuestLogRequiredMoney(questId),
        isAutoComplete = false,
        sourceItemId = sourceItemId,
        isFailed = isFailed
    }
end

local function IsQuestFrequency(questId)
    -- if questie is loaded check for daily quest
    if Questie and Questie.started then
        return QuestieLoader:ImportModule("QuestieDB").IsDailyQuest(questId)
    end
    return false
end

local function UpdateBlockInternal(self, parent, quest)
    self.height = 25
    self.numObjectives = 0
    self.turnin:Hide()

    if quest.requiredMoney then
        parent.watchMoneyReasons = parent.watchMoneyReasons + 1
    else
        parent.watchMoneyReasons = parent.watchMoneyReasons - 1
    end

    self.title = quest.title
    local text = ""
    if quest.questGroup == "Elite" then
        text = "[" .. quest.questLevel .. "|TInterface/AddOns/GW2_UI/textures/icons/quest-group-icon.png:12:12:0:0|t] "
    elseif quest.questGroup == "Dungeon" then
        text = "[" .. quest.questLevel .. "|TInterface/AddOns/GW2_UI/textures/icons/quest-dungeon-icon.png:12:12:0:0|t] "
    elseif quest.questGroup then
        text = "[" .. quest.questLevel .. "+] "
    else
        text = "[" .. quest.questLevel .. "] "
    end

    self.questID = quest.questId
    self.questLogIndex = quest.questLogIndex
    self.sourceItemId = quest.sourceItemId
    self.title = quest.title
    self.Header:SetText(text .. quest.title)

    GW.CombatQueue_Queue(nil, self.UpdateObjectiveActionButton, {self})

    if Questie and Questie.started and GW.settings.QUESTTRACKER_SHOW_XP and GW.mylevel < GetMaxPlayerLevel() then
        local xpReward = QuestieLoader:ImportModule("QuestXP"):GetQuestLogRewardXP(quest.questId, false)

        if xpReward then
            self.Header:SetText(text .. quest.title .. " |cFF888888(" .. GW.CommaValue(xpReward) .. XP .. ")|r")
        end
    end

    if quest.numObjectives == 0 and GetMoney() >= quest.requiredMoney and not quest.startEvent then
        quest.isComplete = true
    end
    self.isComplete = quest.isComplete

    if not quest.isComplete then
        self:UpdateBlockObjectives(quest.numObjectives)
    end

    if quest.requiredMoney and quest.requiredMoney > GetMoney() and not quest.isComplete then
        self:AddObjective(GetMoneyString(GetMoney()) .. " / " .. GetMoneyString(quest.requiredMoney), self.numObjectives + 1, {isQuest = true, finished = quest.isComplete, objectiveType = nil})
    end

    if quest.isComplete then
        if quest.isAutoComplete then
            self:AddObjective(QUEST_WATCH_CLICK_TO_COMPLETE, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
        else
            local completionText = GetQuestLogCompletionText(quest.questLogIndex)
            if completionText then
                self:AddObjective(completionText, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
            else
                self:AddObjective(QUEST_WATCH_QUEST_READY, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
            end
        end
    elseif quest.isFailed then
        self:AddObjective(FAILED, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
    end

    self.height = self.height + 5
    self:SetHeight(self.height)
end

GwQuestLogBlockMixin = {}

function GwQuestLogBlockMixin:UpdateBlockObjectives(numObjectives)
    local addedObjectives = 1
    local infos = C_QuestLog.GetQuestObjectives(self.questID)
    for objectiveIndex = 1, numObjectives do
        local text = infos[objectiveIndex].text
        local objectiveType = infos[objectiveIndex].type
        local finished = infos[objectiveIndex].finished
        if not finished or not text then
            self:AddObjective(text, addedObjectives, {isQuest = true, finished = finished, objectiveType = objectiveType})
            addedObjectives = addedObjectives + 1
        end
    end
end

function GwQuestLogBlockMixin:UpdateBlock(parent, quest)
    if quest.questId then
        UpdateBlockInternal(self, parent, quest, quest.questId, quest.questLogIndex)
    end
end

GwQuestLogMixin = {}

function GwQuestLogMixin:OnEvent(event, ...)
    local arg1 = ...
    local numWatchedQuests = GetNumQuestWatches()

    if (event == "QUEST_LOG_UPDATE" or event == "UPDATE_FACTION" or (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player")) then
        self:UpdateLayout()
    elseif event == "PLAYER_MONEY" and self.watchMoneyReasons > numWatchedQuests then
        self:UpdateLayout()
    else
        self:UpdateLayout()
    end

    if self.watchMoneyReasons > numWatchedQuests then
        self.watchMoneyReasons = self.watchMoneyReasons - numWatchedQuests
    end
    GwQuestTracker:LayoutChanged()
end

function GwQuestLogMixin:UpdateLayout()
    if self.isUpdating then
        return
    end
    self.isUpdating = true

    local counterQuest = 0
    local savedContainerHeight = self.collapsed and 20 or 1
    local shouldShowHeader = not self.collapsed
    local frameName = self:GetName()

    if self.collapsed then
        self.header:Show()
    else
        self.header:Hide()
    end

    -- collect quests here
    local sorted = {}
    GW.sorted = sorted
    local numQuests = GetNumQuestLogEntries()
    for i = 1, numQuests do
        local questId = select(8, GetQuestLogTitle(i))

        if questId and questId > 0 then
            local questInfo = AddQuestInfos(questId, i)
            table.insert(sorted, questInfo)
        end
    end

    --sort based on setting
    if GW.settings.QUESTTRACKER_SORTING == "LEVEL" then
        -- Sort by level
        table.sort(sorted, function(a, b)
            return a and b and a.questLevel < b.questLevel
        end)
    elseif GW.settings.QUESTTRACKER_SORTING == "ZONE" then
        -- Sort by Zone
        if Questie and Questie.started and QuestieLoader then
            local QuestieTrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
            local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
            if QuestieTrackerUtils and QuestieDB then
                table.sort(sorted, function(a, b)
                    local qA = QuestieDB.GetQuest(a.questId)
                    local qB = QuestieDB.GetQuest(b.questId)
                    local qAZone, qBZone
                    if qA and qA.zoneOrSort > 0 then
                        qAZone = QuestieTrackerUtils:GetZoneNameByID(qA.zoneOrSort)
                    elseif qA and qA.zoneOrSort < 0 then
                        qAZone = QuestieTrackerUtils:GetCategoryNameByID(qA.zoneOrSort)
                    else
                        qAZone = tostring(qA and qA.zoneOrSort or "")
                    end

                    if qB and qB.zoneOrSort > 0 then
                        qBZone = QuestieTrackerUtils:GetZoneNameByID(qB.zoneOrSort)
                    elseif qB and qB.zoneOrSort < 0 then
                        qBZone = QuestieTrackerUtils:GetCategoryNameByID(qB.zoneOrSort)
                    else
                        qBZone = tostring(qB and qB.zoneOrSort or "")
                    end

                    -- Sort by Zone then by Level to mimic QuestLog sorting
                    if qAZone == qBZone then
                        return qA.level < qB.level
                    else
                        if qAZone ~= nil and qBZone ~= nil then
                            return qAZone < qBZone
                        else
                            return qAZone and qBZone
                        end
                    end
                end)
            end
        end
    end

    wipe(self.trackedQuests)
    for _, quest in pairs(sorted) do
        if ((GetCVar("autoQuestWatch") == "1" and not GW2UI_QUEST_WATCH_DB.AutoUntrackedQuests[quest.questId]) or (GetCVar("autoQuestWatch") == "0" and GW2UI_QUEST_WATCH_DB.TrackedQuests[quest.questId])) then
            if shouldShowHeader then
                self.header:Show()
                counterQuest = counterQuest + 1
                if counterQuest == 1 then
                    savedContainerHeight = 20
                end

                local isFrequency = IsQuestFrequency(quest.questId)
                local colorKey = isFrequency and "DAILY" or "QUEST"
                local block = self:GetBlock(counterQuest, colorKey, true)
                block.isFrequency = isFrequency
                block:UpdateBlock(self, quest)
                block:Show()
                savedContainerHeight = savedContainerHeight + block.height
                block.fromContainerTopHeight = savedContainerHeight

                GW.CombatQueue_Queue("update_tracker_" .. frameName .. block.index, block.UpdateObjectiveActionButtonPosition, {block})
                tinsert(self.trackedQuests, quest)
            else
                counterQuest = counterQuest + 1
                local block = self.blocks and self.blocks[counterQuest]
                if block then
                    block.questID = nil
                    block.questLogIndex = 0
                    block.sourceItemId = nil
                    block:Hide()
                    GW.CombatQueue_Queue("update_tracker_" .. counterQuest, block.UpdateObjectiveActionButton, {block})
                end
            end
        end
    end

    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(counterQuest > 0 and savedContainerHeight or 1)
    self.numQuests = counterQuest

    -- hide other quests
    for i = counterQuest + 1, #self.blocks do
        local block = self.blocks[i]
        block.questID = nil
        block.questLogIndex = 0
        block.sourceItemId = nil
        block:Hide()
        GW.CombatQueue_Queue("update_tracker_itembutton_remove" .. i, block.UpdateObjectiveActionButton, {block})
    end

    local headerCounterText = " (" .. counterQuest .. ")"
    self.header.title:SetText(TRACKER_HEADER_QUESTS .. headerCounterText)

    GwQuestTracker:LayoutChanged()
    self.isUpdating = false
end

function GwQuestLogMixin:BlockOnClick(button)
    if button == "RightButton" then
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
            rootDescription:CreateTitle(self.title)

            if Questie and Questie.started then
                local QuestieQuest = QuestieLoader:ImportModule("QuestieDB").GetQuest(self.questID) or {}

                if QuestieQuest:IsComplete() == 0 then
                    local submenuObjectives = rootDescription:CreateButton(OBJECTIVES_TRACKER_LABEL)

                    for _, objective in pairs(QuestieQuest.Objectives) do
                        local submenuObjectives = submenuObjectives:CreateButton(objective.Description)

                        if TomTom and TomTom.AddWaypoint then
                            submenuObjectives:CreateButton(GW.L["Set TomTom Target"], function()
                                AddTomTomWaypoint(self.questID, objective)
                            end)
                        end

                        submenuObjectives:CreateButton(GW.L["Show on Map"], function()
                            QuestieLoader:ImportModule("TrackerUtils"):ShowObjectiveOnMap(objective)
                        end)
                    end

                    if next(QuestieQuest.SpecialObjectives) then
                        for _, objective in pairs(QuestieQuest.SpecialObjectives) do
                            local submenuObjectives = submenuObjectives:CreateButton(objective.Description)

                            if TomTom and TomTom.AddWaypoint then
                                submenuObjectives:CreateButton(GW.L["Set TomTom Target"], function()
                                    AddTomTomWaypoint(self.questID, objective)
                                end)
                            end

                            submenuObjectives:CreateButton(GW.L["Show on Map"], function()
                                QuestieLoader:ImportModule("TrackerUtils"):ShowObjectiveOnMap(objective)
                            end)
                        end
                    end
                end
            end

            rootDescription:CreateButton(COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, function() LinkQuestIntoChat(self.title, self.questID) end)
            rootDescription:CreateButton("Wowhead URL", function() StaticPopup_Show("QUESTIE_WOWHEAD_URL", self.questID, self.title) end)
            rootDescription:CreateButton(OBJECTIVES_VIEW_IN_QUESTLOG, function() QuestLogFrame:Show()
                QuestLog_SetSelection(self.questLogIndex)
                QuestLog_Update()
            end)

            if TomTom and TomTom.AddWaypoint and Questie and Questie.started then
                rootDescription:CreateButton(GW.L["Set TomTom Target"], function() AddTomTomWaypoint(self.questID, nil) end)
            end

            if Questie and Questie.started and self.isComplete then
                rootDescription:CreateButton(GW.L["Show on Map"], function()
                    local QuestieQuest = QuestieLoader:ImportModule("QuestieDB").GetQuest(self.questID)
                    QuestieLoader:ImportModule("TrackerUtils"):ShowFinisherOnMap(QuestieQuest)
                end)
            end

            rootDescription:CreateButton(UNTRACK_QUEST, function() UntrackQuest(self.questLogIndex)  end)

        end)
        return
    end

    if IsShiftKeyDown() and ChatEdit_GetActiveWindow() then
        if button == "LeftButton" then
            LinkQuestIntoChat(self.title, self.questID)
        end
        return
    elseif IsControlKeyDown() then
        if button == "LeftButton" then
            AddTomTomWaypoint(self.questID, nil)
        else
            UntrackQuest(self.questLogIndex)
        end
        return
    end

    if button ~= "RightButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if QuestLogFrame:IsShown() and QuestLogFrame.selectedButtonID == self.questLogIndex then
            QuestLogFrame:Hide()
        else
            QuestLogFrame:Show()
            QuestLog_SetSelection(self.questLogIndex)
            QuestLog_Update()
        end
    end
end

GwObjectivesQuestContainerMixin = CreateFromMixins(GwQuestLogMixin)


function GwObjectivesQuestContainerMixin:_RemoveQuestWatch(index, isGW2)
    if not isGW2 then
        local questId = select(8, GetQuestLogTitle(index))
        if questId == 0 then
            questId = index
        end

        if questId then
            if "0" == GetCVar("autoQuestWatch") then
                GW2UI_QUEST_WATCH_DB.TrackedQuests[questId] = nil
            else
                GW2UI_QUEST_WATCH_DB.AutoUntrackedQuests[questId] = true
            end
            self:OnEvent()
        end
    end
end

function GwObjectivesQuestContainerMixin:_AQW_Insert(index)
    if index == 0 then
        return
    end

    local now = GetTime()
    if index and index == self._last_aqw and (now - lastAQW) < 0.1 then
        -- this fixes double calling due to AQW+AQW_Insert (QuestGuru fix)
        return
    end

    lastAQW = now
    self._last_aqw = index
    RemoveQuestWatch(index, true) -- prevent hitting 5 quest watch limit

    local questId = select(8, GetQuestLogTitle(index))
    if questId == 0 then
        questId = index
    end

    if questId > 0 then
        if "0" == GetCVar("autoQuestWatch") then
            if GW2UI_QUEST_WATCH_DB.TrackedQuests[questId] then
                GW2UI_QUEST_WATCH_DB.TrackedQuests[questId] = nil
            else
                GW2UI_QUEST_WATCH_DB.TrackedQuests[questId] = true
            end
        else
            if GW2UI_QUEST_WATCH_DB.AutoUntrackedQuests[questId] then
                GW2UI_QUEST_WATCH_DB.AutoUntrackedQuests[questId] = nil
            elseif IsShiftKeyDown() and (QuestLogFrame:IsShown() or (QuestLogExFrame and QuestLogExFrame:IsShown())) then--hack
                GW2UI_QUEST_WATCH_DB.AutoUntrackedQuests[questId] = true
            end
        end

        self:OnEvent()
    end
end

function GwObjectivesQuestContainerMixin:InitModule()
    self.blockMixInTemplate = GwQuestLogBlockMixin

    GW2UI_QUEST_WATCH_DB = GW2UI_QUEST_WATCH_DB or {}
    GW2UI_QUEST_WATCH_DB.TrackedQuests = GW2UI_QUEST_WATCH_DB.TrackedQuests or {}
    GW2UI_QUEST_WATCH_DB.AutoUntrackedQuests = GW2UI_QUEST_WATCH_DB.AutoUntrackedQuests or {}

    self:SetScript("OnEvent", self.OnEvent)
    self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("QUEST_WATCH_UPDATE")
	self:RegisterEvent("UPDATE_FACTION")
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
	self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("PLAYER_MONEY")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.watchMoneyReasons = 0
    self.trackedQuests = {}

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function
    self.header.title:SetTextColor(TRACKER_TYPE_COLOR.QUEST.r, TRACKER_TYPE_COLOR.QUEST.g, TRACKER_TYPE_COLOR.QUEST.b)
    self.header.icon:SetTexCoord(0, 0.5, 0.25, 0.5)
    self.header.title:SetText(TRACKER_HEADER_QUESTS)

    --hook functions
    hooksecurefunc("AutoQuestWatch_Insert", function(questIndex) self:_AQW_Insert(questIndex) end)
    hooksecurefunc("AddQuestWatch", function(questIndex) self:_AQW_Insert(questIndex) end)
    hooksecurefunc("RemoveQuestWatch", function(questIndex) self:_RemoveQuestWatch(questIndex) end)

    IsQuestWatched = function(index)
        local _, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(index)
        if isHeader then return false end
        if questId == 0 then
            questId = index
        end

        if "0" == GetCVar("autoQuestWatch") then
            return GW2UI_QUEST_WATCH_DB.TrackedQuests[questId or -1]
        else
            return questId and (not GW2UI_QUEST_WATCH_DB.AutoUntrackedQuests[questId])
        end
    end

    GetNumQuestWatches = function()
        return 0
    end

    local baseQLTB_OnClick = QuestLogTitleButton_OnClick
    QuestLogTitleButton_OnClick = function(btn, button) -- I wanted to use hooksecurefunc but this needs to be a pre-hook to work properly unfortunately
        if (not btn) or btn.isHeader or not IsShiftKeyDown() then baseQLTB_OnClick(btn, button) return end
        local questLogLineIndex = self:GetID()

        if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
            local questId = GetQuestIDFromLogIndex(questLogLineIndex)
            ChatEdit_InsertLink("["..gsub(btn:GetText(), " *(.*)", "%1").." ("..questId..")]")
        else
            if GetNumQuestLeaderBoards(questLogLineIndex) == 0 and not IsQuestWatched(questLogLineIndex) then -- only call if we actually want to fix this quest (normal quests already call AQW_insert)
                self:_AQW_Insert(questLogLineIndex)
                QuestWatch_Update()
                QuestLog_SetSelection(questLogLineIndex)
                QuestLog_Update()
            else
                baseQLTB_OnClick(btn, button)
            end
        end
    end

    if not self._IsQuestWatched then
        self._IsQuestWatched = IsQuestWatched
        self._GetNumQuestWatches = GetNumQuestWatches
    end

    self:OnEvent("LOAD")
end
