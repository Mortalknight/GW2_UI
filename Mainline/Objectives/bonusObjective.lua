local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local function SortWorldQuestsHelper(questID1, questID2)
    local inArea1, onMap1 = GetTaskInfo(questID1)
    local inArea2, onMap2 = GetTaskInfo(questID2)

    if inArea1 ~= inArea2 then
        return inArea1
    elseif onMap1 ~= onMap2 then
        return onMap1
    else
        return questID1 < questID2
    end
end

GwBonusObjectivesTrackerBlockMixin = {}

function GwBonusObjectivesTrackerBlockMixin:TryAddingExpirationWarningLine(objectiveIndex)
    if QuestUtils_ShouldDisplayExpirationWarning(self.questID) then
        local objectiveBlock = self:GetObjectiveBlock(objectiveIndex)
        local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(self.questID)
        if timeLeftMinutes and self.tickerSeconds and timeLeftMinutes > 0 then
            if timeLeftMinutes < WORLD_QUESTS_TIME_CRITICAL_MINUTES then
                local timeString = SecondsToTime(timeLeftMinutes * 60)
                local text = BONUS_OBJECTIVE_TIME_LEFT:format(timeString)
                objectiveBlock:Show()
                objectiveBlock.ObjectiveText:SetText(text)
                objectiveBlock.ObjectiveText:SetTextColor(DIM_RED_FONT_COLOR.r, DIM_RED_FONT_COLOR.g, DIM_RED_FONT_COLOR.b)
                objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
                objectiveBlock.StatusBar:Hide()
                local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
                objectiveBlock:SetHeight(h)
                self.height = self.height + objectiveBlock:GetHeight()
                self.numObjectives = self.numObjectives + 1

                self.tickerSeconds = 10
            else
                local timeToAlert = max((timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) * 60 - 10, 10)
                if self.tickerSeconds == 0 or timeToAlert < self.tickerSeconds then
                    self.tickerSeconds = timeToAlert
                end
            end
        end
    end
end

function GwBonusObjectivesTrackerBlockMixin:TryShowRewardsTooltip()
    if self.questID < 0 then
        -- this is a scenario bonus objective
        self.questID = C_Scenario.GetBonusStepRewardQuestID(-self.questID)
        if self.questID == 0 then
            -- huh, no reward
            return
        end
    else
        if C_QuestLog.IsQuestFlaggedCompleted(self.questID) then
            -- no tooltip for completed objectives
            return;
        end
    end

    if HaveQuestRewardData(self.questID) and GetQuestLogRewardXP(self.questID) == 0 and (not C_QuestInfoSystem.HasQuestRewardCurrencies(self.questID))
                                and GetNumQuestLogRewards(self.questID) == 0 and GetQuestLogRewardMoney(self.questID) == 0 and GetQuestLogRewardArtifactXP(self.questID) == 0 then
        GameTooltip:Hide()
        return
    end

    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0)
    GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")

    if not HaveQuestRewardData(self.questID) then
        GameTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
        GameTooltip_SetTooltipWaitingForData(GameTooltip, true)
    else
        local isWorldQuest = self.parentModule.showWorldQuests
        if isWorldQuest then
            QuestUtils_AddQuestTypeToTooltip(GameTooltip, self.questID, NORMAL_FONT_COLOR)
            GameTooltip:AddLine(REWARDS, NORMAL_FONT_COLOR:GetRGB())
        else
            GameTooltip:SetText(REWARDS, NORMAL_FONT_COLOR:GetRGB())
        end
        GameTooltip:AddLine(isWorldQuest and WORLD_QUEST_TOOLTIP_DESCRIPTION or BONUS_OBJECTIVE_TOOLTIP_DESCRIPTION, 1, 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip_AddQuestRewardsToTooltip(GameTooltip, self.questID, TOOLTIP_QUEST_REWARDS_STYLE_NONE)
        GameTooltip_SetTooltipWaitingForData(GameTooltip, false)
    end

    GameTooltip:Show()
    EventRegistry:TriggerEvent("BonusObjectiveBlock.QuestRewardTooltipShown", self, self.questID, true)
    self.hasRewardsTooltip = true
end

GwBonusObjectivesTrackerContainerMixin = {}

function GwBonusObjectivesTrackerContainerMixin:GetSortedWorldQuests()
    local sortedQuests = {}
    for i = 1, C_QuestLog.GetNumWorldQuestWatches() do
        tinsert(sortedQuests, C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i))
    end

    table.sort(sortedQuests, SortWorldQuestsHelper)

    return sortedQuests
end

function GwBonusObjectivesTrackerContainerMixin:BlockOnClick(button)
    local isThreatQuest = C_QuestLog.IsThreatQuest(self.questID)
    if self.parentModule.showWorldQuests or isThreatQuest then
        if button == "LeftButton" then
            if not ChatEdit_TryInsertQuestLinkForQuestID(self.questID) then
                if IsShiftKeyDown() then
                    if QuestUtils_IsQuestWatched(self.questID) and not isThreatQuest then
                        QuestUtil.UntrackWorldQuest(self.questID)
                    end
                else
                    local mapID = C_TaskQuest.GetQuestZoneID(self.questID)
                    if mapID then
                        OpenQuestLog(mapID)
                        EventRegistry:TriggerEvent("MapCanvas.PingQuestID", self.questID)
                    end
                end
            end
        elseif button == "RightButton" and not isThreatQuest then
            -- Ensure at least one option will appear before showing the dropdown.
            if not QuestUtils_IsQuestWatched(self.questID) then
                return
            end

            MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
                local title = C_TaskQuest.GetQuestInfoByQuestID(self.questID)
                rootDescription:CreateTitle(title)
                rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function()
                    QuestUtil.UntrackWorldQuest(self.questID)
                end)
            end)
        end
    end
end

function GwBonusObjectivesTrackerContainerMixin:UpdateBlocks(questIDs)
    local savedContainerHeight = 1
    local shownBlocks = 0
    local blockIndex = 1
    local foundEvent = false

    for _, questData in pairs(questIDs) do
        local questID = questData.questID
        local isInArea, isOnMap, numObjectives, text = GetTaskInfo(questID)
        text = text or ""
        numObjectives = numObjectives or 0
        local treatAsInArea = (questData.tracked and text ~= "") or isInArea
        local simpleDesc = ""
        local compassData = {}

        if isOnMap then
            compassData.TYPE = GW.TRACKER_TYPE.EVENT
            compassData.COMPASS = true
        end
        if numObjectives > 0 and treatAsInArea then
            if not self.collapsed then
                local block = self:GetBlock(blockIndex, "EVENT", true)
                compassData.TITLE = text
                -- needed for tooltip
                block.parentModule = { showWorldQuests = true }
                block.event = true
                block.height = 20
                block.numObjectives = 0
                block.tickerSeconds = 0
                block.questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
                block.Header:SetText(text)

                if questData.playAnimation then
                    block:NewQuestAnimation()
                    PlaySound(SOUNDKIT.UI_WORLDQUEST_START)
                end

                block.questID = questID
                block:UpdateFindGroupButton(questID, false)

                GW.CombatQueue_Queue(nil, block.UpdateObjectiveActionButton, {block})

                if not foundEvent then
                    savedContainerHeight = 20
                end
                foundEvent = true

                compassData.PROGRESS = 0
                local objectiveProgress = 0
                local playerMapID = GW.Libs.GW2Lib:GetPlayerLocationMapID()

                compassData.TYPE = GW.TRACKER_TYPE.EVENT
                compassData.ID = questID
                compassData.COLOR = TRACKER_TYPE_COLOR.EVENT
                compassData.COMPASS = false
                compassData.X = nil
                compassData.Y = nil
                compassData.QUESTID = questID
                compassData.MAPID = playerMapID

                for objectiveIndex = 1, numObjectives do
                    local txt, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, false)
                    txt = txt or ""
                    local parsedObjective = GW.ParseSimpleObjective(txt)
                    if simpleDesc == "" then
                        simpleDesc = parsedObjective
                    else
                        simpleDesc = simpleDesc .. ", " .. parsedObjective
                    end

                    local progressValue = block:AddObjective(txt, objectiveIndex, { isBonusObjective = true, finished = finished, objectiveType = objectiveType })
                    if finished then
                        objectiveProgress = objectiveProgress + (1 / numObjectives)
                    else
                        objectiveProgress = objectiveProgress + (progressValue / numObjectives)
                    end
                end

                -- try to add a timer here
                block:TryAddingExpirationWarningLine(numObjectives + 1)
                if block.tickerSeconds > 0 then
                    block.ticker = C_Timer.NewTicker(block.tickerSeconds, function()
                        self:UpdateLayout()
                    end)
                end

                if simpleDesc ~= "" then
                    compassData.DESC = simpleDesc
                end

                compassData.PROGRESS = objectiveProgress

                if isInArea then
                    GwObjectivesNotification:AddNotification(compassData)
                end

                savedContainerHeight = savedContainerHeight + block.height + 10
                block.fromContainerTopHeight = savedContainerHeight
                if block.hasItem then
                    GW.CombatQueue_Queue("update_tracker_bonus_itembutton_position" .. blockIndex, block.UpdateObjectiveActionButtonPosition, {block, "EVENT"})
                end

                block:Show()
                block:SetHeight(block.height + 10)
                shownBlocks = shownBlocks + 1
                blockIndex = blockIndex + 1
            else
                shownBlocks = shownBlocks + 1
                savedContainerHeight = 20
            end
        end
    end
    self:SetHeight(savedContainerHeight)

    return foundEvent, shownBlocks
end

function GwBonusObjectivesTrackerContainerMixin:UpdateLayout(newQuestId)
    if self.isUpdating then return end

    self.isUpdating = true
    local trackedEventIDs = {}
    GwObjectivesNotification:RemoveNotificationOfType(GW.TRACKER_TYPE.EVENT)

    for i = 1, #self.blocks do
        local block = self.blocks[i]
        block.questID = false
        if block.ticker then
            block.ticker:Cancel()
            block.ticker = nil
        end
        GW.CombatQueue_Queue("update_tracker_bonus_itembutton_remove" .. i, block.UpdateObjectiveActionButton, {block})
        block:Hide()
    end

    local tasks = GetTasksTable()
    for _, questID in pairs(tasks or {}) do
        if not QuestUtils_IsQuestWatched(questID) then
            if not trackedEventIDs[questID] then
                trackedEventIDs[questID] = { questID = questID, tracked = false, playAnimation = questID == newQuestId }
            end
        end
    end

    local sortedQuests = self:GetSortedWorldQuests()
    for _, questID in ipairs(sortedQuests) do
        if not trackedEventIDs[questID] then
            trackedEventIDs[questID] = { questID = questID, tracked = true, playAnimation = false }
        end
    end

    local foundEvent, shownBlocks = self:UpdateBlocks(trackedEventIDs)
    self.numEvents = shownBlocks

    for i = (shownBlocks > 0 and not self.collapsed and shownBlocks + 1) or 1, #self.blocks do
        local block = self.blocks[i]
        block.questID = false
        block:Hide()
        GW.CombatQueue_Queue("update_tracker_bonus_itembutton_remove" .. i, block.UpdateObjectiveActionButton, {block})
        if block.ticker then
            block.ticker:Cancel()
            block.ticker = nil
        end
    end

    if foundEvent or shownBlocks > 0 then
        self.header.title:SetText(EVENTS_LABEL .. " (" .. shownBlocks .. ")")
        self.header:Show()
    else
        self.header:Hide()
    end

    GwQuestTracker:LayoutChanged()
    self.isUpdating = false
end

function GwBonusObjectivesTrackerContainerMixin:OnEvent(event, ...)
    if event == "QUEST_ACCEPTED" then
        local newQuestId = ...
        self:UpdateLayout(newQuestId)
    else
        self:UpdateLayout()
    end
end

function GwBonusObjectivesTrackerContainerMixin:InitModule()
    self.blockMixInTemplate = GwBonusObjectivesTrackerBlockMixin

    self:SetScript("OnEvent", self.OnEvent)
    self:RegisterEvent("QUEST_LOG_UPDATE")
    self:RegisterEvent("TASK_PROGRESS_UPDATE")
    self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("SUPER_TRACKING_CHANGED")

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0, 0.5, 0.5, 0.75)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(EVENTS_LABEL)

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function
    self.header.title:SetTextColor(TRACKER_TYPE_COLOR.EVENT.r, TRACKER_TYPE_COLOR.EVENT.g, TRACKER_TYPE_COLOR.EVENT.b)

    self:UpdateLayout()
end
