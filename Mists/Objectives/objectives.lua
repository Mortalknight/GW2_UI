local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local ChatEdit_GetActiveWindow = ChatFrameUtil and ChatFrameUtil.GetActiveWindow or ChatEdit_GetActiveWindow

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

local function LinkQuestIntoChat(questId)
    if not ChatFrame1EditBox:IsVisible() then
        ChatFrame_OpenChat(GetQuestLink(questId))
    else
        ChatEdit_InsertLink(GetQuestLink(questId))
    end
end

local function UntrackQuest(questLogIndex)
    RemoveQuestWatch(questLogIndex)
    QuestWatch_Update()
    QuestLog_Update()
end

local function AddQuestInfos(questLogIndex, id)
    local title, level, questTag, _, _, isComplete, frequency, questId, startEvent = GetQuestLogTitle(questLogIndex)
    if title and questId then
        local isFailed = false
        local numObjectives = GetNumQuestLeaderBoards(questLogIndex)

        if isComplete == nil then
            local hiddenObjective = nil
			local uncompletedObjectives = nil
            for j = 1, numObjectives do
                local text, _, finished = GetQuestLogLeaderBoard(j, questLogIndex)
                if not finished and text then
                    uncompletedObjectives = true
                elseif not finished and not text then
                    hiddenObjective = true
                end
            end
            if (hiddenObjective and not uncompletedObjectives) then
                isComplete = true
            else
                isComplete = false
            end
        elseif isComplete == 1 then
            isComplete = true
        else
            isComplete = false
            isFailed = true
        end

        return {
            questId = questId,
            questWatchedId = id or 0,
            questLogIndex = questLogIndex,
            questLevel = level,
            questTag = questTag,
            title = title,
            isComplete = isComplete,
            startEvent = startEvent,
            numObjectives = numObjectives,
            requiredMoney = GetQuestLogRequiredMoney(questLogIndex),
            isAutoComplete = GetQuestLogIsAutoComplete(questLogIndex),
            isFailed = isFailed,
            isFrequency = frequency and frequency > 1
        }
    end
end
local function UpdateBlockInternal(self, parent, quest)
    self.height = 25
    self.numObjectives = 0
    self.turnin:Hide()
    self.turnin:SetShown(self:IsQuestAutoTurnInOrAutoAccept(quest.questId, "COMPLETE", quest.isComplete, quest.isAutoComplete))
    self.popupQuestAccept:SetShown(self:IsQuestAutoTurnInOrAutoAccept(quest.questId, "OFFER"))

    if quest.requiredMoney then
        parent.watchMoneyReasons = parent.watchMoneyReasons + 1
    else
        parent.watchMoneyReasons = parent.watchMoneyReasons - 1
    end

    self.title = quest.title
    local text = ""
    if quest.questTag == "Elite" then
        text = "[" .. quest.questLevel .. "|TInterface/AddOns/GW2_UI/textures/icons/quest-group-icon.png:12:12:0:0|t] "
    elseif quest.questTag == "Dungeon" then
        text = "[" .. quest.questLevel .. "|TInterface/AddOns/GW2_UI/textures/icons/quest-dungeon-icon.png:12:12:0:0|t] "
    elseif quest.questTag == "Group" then
        text = "[" .. quest.questLevel .. "+] "
    else
        text = "[" .. quest.questLevel .. "] "
    end

    self.questID = quest.questId
    self.questLogIndex = quest.questLogIndex
    self.title = quest.title
    self.isAutoComplete = quest.isAutoComplete
    self.Header:SetText(text .. quest.title)

    GW.CombatQueue_Queue(nil, self.UpdateObjectiveActionButton, {self})

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
    UpdateBlockInternal(self, parent, quest)
end

GwQuestLogMixin = {}

function GwQuestLogMixin:GetBlockByQuestId(questID)
    for _, block in ipairs(self.blocks) do
        if block and block.questID == questID then
            return block
        end
    end
    return nil
end

function GwQuestLogMixin:CheckForAutoQuests()
    for i = 1, GetNumAutoQuestPopUps() do
        local questID, popUpType = GetAutoQuestPopUp(i)
        if questID and (popUpType == "OFFER" or popUpType == "COMPLETE") then
            local questBlock = self:GetBlockByQuestId(questID)
            if questBlock then
                if popUpType == "OFFER" then
                    questBlock.popupQuestAccept:Show()
                elseif popUpType == "COMPLETE" then
                    questBlock.turnin:Show()
                end
            end
        end
    end
end

function GwQuestLogMixin:OnEvent(event, ...)
    local arg1 = ...
    local numWatchedQuests = GetNumQuestWatches()

    if (event == "QUEST_WATCH_LIST_CHANGED" or event == "QUEST_LOG_UPDATE" or event == "UPDATE_FACTION" or (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player")) then
        self:UpdateLayout()
    elseif event == "PLAYER_MONEY" and self.watchMoneyReasons > numWatchedQuests then
        self:UpdateLayout()
    else
        self:UpdateLayout()
    end

    if self.watchMoneyReasons > numWatchedQuests then
        self.watchMoneyReasons = self.watchMoneyReasons - numWatchedQuests
    end
    self:CheckForAutoQuests()
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
    local numQuests = GetNumQuestWatches()
    for i = 1, numQuests do
        local questLogIndex = GetQuestIndexForWatch(i)

        if questLogIndex and questLogIndex > 0 then
            local questInfo = AddQuestInfos(questLogIndex, i)
             if questInfo then table.insert(sorted, questInfo) end
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
        if shouldShowHeader then
            self.header:Show()
            counterQuest = counterQuest + 1
            if counterQuest == 1 then
                savedContainerHeight = 20
            end

            local colorKey = quest.isFrequency and "DAILY" or "QUEST"
            local block = self:GetBlock(counterQuest, colorKey, true)
            block.isFrequency = quest.isFrequency
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
                block:Hide()
                GW.CombatQueue_Queue("update_tracker_" .. counterQuest, block.UpdateObjectiveActionButton, {block})
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

                rootDescription:CreateButton("Wowhead URL", function() StaticPopup_Show("QUESTIE_WOWHEAD_URL", self.questID, self.title) end)
            else
                if WatchFrame.showObjectives then
                    rootDescription:CreateButton(OBJECTIVES_SHOW_QUEST_MAP, function()
                        QuestMapFrame_OpenToQuestDetails(self.questID)
                    end)
                end
            end

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

            rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function() UntrackQuest(self.questLogIndex) end)

            if GetQuestLogPushable(self.questLogIndex) and IsInGroup()then
				rootDescription:CreateButton(SHARE_QUEST, function()
					WatchFrame_ShareQuest(button, self.questLogIndex)
				end)
			end

        end)
        return
    end

    if IsShiftKeyDown() and ChatEdit_GetActiveWindow() then
        if button == "LeftButton" then
            LinkQuestIntoChat(self.questID)
        end
        return
    elseif IsControlKeyDown() then
        if button == "LeftButton" then
            AddTomTomWaypoint(self.questID, nil)
        else
            WatchFrame_StopTrackingQuest(self, self.questWatchedId)
        end
        return
    end

    if button ~= "RightButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

        if self.isComplete and self.isAutoComplete then
            ShowQuestComplete(self.questLogIndex)
            WatchFrameAutoQuest_ClearPopUp(self.questID)
        else
            QuestLogFrame:Show()
            QuestLog_SetSelection(self.questLogIndex)
            QuestLog_Update()
        end
    end
end

GwObjectivesQuestContainerMixin = CreateFromMixins(GwQuestLogMixin)

function GwObjectivesQuestContainerMixin:InitModule()
    self.blockMixInTemplate = GwQuestLogBlockMixin

    self:SetScript("OnEvent", self.OnEvent)
    self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("QUEST_WATCH_UPDATE")
	self:RegisterEvent("UPDATE_FACTION")
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
    self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
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


    ExpandQuestHeader(0)

    self:OnEvent("LOAD")
end
