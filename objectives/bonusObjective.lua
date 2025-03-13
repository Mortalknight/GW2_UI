local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local savedQuests = {}
local trackedEventIDs = {}

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
	local questID
	if self.id < 0 then
		-- this is a scenario bonus objective
		questID = C_Scenario.GetBonusStepRewardQuestID(-self.id)
		if questID == 0 then
			-- huh, no reward
			return
		end
	else
		questID = self.id;
		if C_QuestLog.IsQuestFlaggedCompleted(questID) then
			-- no tooltip for completed objectives
			return;
		end
	end

	if HaveQuestRewardData(questID) and GetQuestLogRewardXP(questID) == 0 and (not C_QuestInfoSystem.HasQuestRewardCurrencies(questID))
								and GetNumQuestLogRewards(questID) == 0 and GetQuestLogRewardMoney(questID) == 0 and GetQuestLogRewardArtifactXP(questID) == 0 then
		GameTooltip:Hide()
		return
	end

	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0)
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")

	if not HaveQuestRewardData(questID) then
		GameTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		GameTooltip_SetTooltipWaitingForData(GameTooltip, true)
	else
		local isWorldQuest = self.parentModule.showWorldQuests
		if isWorldQuest then
			QuestUtils_AddQuestTypeToTooltip(GameTooltip, questID, NORMAL_FONT_COLOR)
			GameTooltip:AddLine(REWARDS, NORMAL_FONT_COLOR:GetRGB())
		else
			GameTooltip:SetText(REWARDS, NORMAL_FONT_COLOR:GetRGB())
		end
		GameTooltip:AddLine(isWorldQuest and WORLD_QUEST_TOOLTIP_DESCRIPTION or BONUS_OBJECTIVE_TOOLTIP_DESCRIPTION, 1, 1, 1, 1)
		GameTooltip:AddLine(" ")
		GameTooltip_AddQuestRewardsToTooltip(GameTooltip, questID, TOOLTIP_QUEST_REWARDS_STYLE_NONE)
		GameTooltip_SetTooltipWaitingForData(GameTooltip, false)
	end

	GameTooltip:Show()
	EventRegistry:TriggerEvent("BonusObjectiveBlock.QuestRewardTooltipShown", self, self.id, true)
	self.hasRewardsTooltip = true
end

GwBonusObjectivesTrackerContainerMixin = {}

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

    for _, v in pairs(questIDs) do
        local questID = v.ID
        local isInArea, isOnMap, numObjectives, text = GetTaskInfo(questID)
        local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        local simpleDesc = ""
        local compassData = {}

        if isOnMap then
            compassData.TYPE = "EVENT"
            compassData.COMPASS = true
        end

        if numObjectives == nil then
            numObjectives = 0
        end
        if isInArea or (v.tracked and text) then
            if not self.collapsed then
                compassData.TITLE = text

                if text == nil then
                    text = ""
                end
                local block = self:GetBlock(blockIndex, "EVENT", true)
                if block == nil then
                    return
                end
                -- needed for tooltip
                block.parentModule = {}
                block.parentModule.showWorldQuests = true
                block.event = true

                if block.ticker then
                    block.ticker:Cancel()
                    block.ticker = nil
                end
                block.tickerSeconds = 0
                block.height = 20
                block.numObjectives = 0


                block.Header:SetText(text)

                if savedQuests[questID] == nil then
                    block:NewQuestAnimation()
                    PlaySound(SOUNDKIT.UI_WORLDQUEST_START)
                    savedQuests[questID] = true
                end

                block.questID = questID
                block.id = questID
                block.TrackedQuest = {}
                block.TrackedQuest.questID = questID
                block.questLogIndex = questLogIndex
                block.hasGroupFinderButton = C_LFGList.CanCreateQuestGroup(questID)

                block.groupButton:SetShown(block.hasGroupFinderButton)

                GW.CombatQueue_Queue(nil, block.UpdateObjectiveActionButton, {block})

                if not foundEvent then
                    savedContainerHeight = 20
                end

                foundEvent = true

                compassData.PROGRESS = 0

                local objectiveProgress = 0
                for objectiveIndex = 1, numObjectives do
                    local txt, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, false)
                    txt = txt and txt or ""
                    compassData.TYPE = "EVENT"
                    compassData.ID = questID
                    compassData.COLOR = TRACKER_TYPE_COLOR.EVENT
                    compassData.COMPASS = false
                    compassData.X = nil
                    compassData.Y = nil
                    compassData.QUESTID = questID
                    compassData.MAPID = GW.Libs.GW2Lib:GetPlayerLocationMapID()

                    if simpleDesc == "" then
                        simpleDesc = GW.ParseSimpleObjective(txt)
                    else
                        simpleDesc = simpleDesc .. ", " .. GW.ParseSimpleObjective(txt)
                    end

                    if not self.collapsed then
                        local progressValue = block:AddObjective(txt, objectiveIndex, {isBonusObjective = true, finished = finished, objectiveType = objectiveType})
                        if finished then
                            objectiveProgress = objectiveProgress + (1 / numObjectives)
                        else
                            objectiveProgress = objectiveProgress + (progressValue / numObjectives)
                        end
                    end
                end

                -- try to add a timer here
                block:TryAddingExpirationWarningLine(numObjectives + 1)
                if block.tickerSeconds > 0 then
                    if block.ticker then
                        block.ticker:Cancel()
                        block.ticker = nil
                    end
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
                block.savedHeight = savedContainerHeight
                if block.hasItem then
                    GW.CombatQueue_Queue("update_tracker_bonus_itembutton_position" .. blockIndex, block.UpdateObjectiveActionButtonPosition, {block, savedContainerHeight, "EVENT"})
                end

                if not self.collapsed then
                    block:Show()
                end
                for i = block.numObjectives + 1, 20 do
                    if _G[block:GetName() .. "Objective" .. i] then
                        _G[block:GetName() .. "Objective" .. i]:Hide()
                    end
                end

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

function GwBonusObjectivesTrackerContainerMixin:UpdateLayout()
    GwObjectivesNotification:RemoveNotificationOfType("EVENT")

    for i = 1, 20 do
        local block = _G[self:GetName() .. i]
        if block then
            block.questID = false
            block.questLogIndex = 0
            if block.groupButton then block.groupButton:Hide() end
            GW.CombatQueue_Queue("update_tracker_bonus_itembutton_remove" .. i, block.UpdateObjectiveActionButton, {block})
        end
    end

    local tasks = GetTasksTable()
    wipe(trackedEventIDs)

    for i = 1, C_QuestLog.GetNumWorldQuestWatches() do
        local wqID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
        if wqID and trackedEventIDs[wqID] == nil then
            trackedEventIDs[wqID] = {}
            trackedEventIDs[wqID].ID = wqID
            trackedEventIDs[wqID].tracked = true
        end
    end

    for _, v in pairs(tasks or {}) do
        if trackedEventIDs[v] == nil then
            trackedEventIDs[v] = {}
            trackedEventIDs[v].ID = v
            trackedEventIDs[v].tracked = false
        end
    end

    local foundEvent, shownBlocks = self:UpdateBlocks(trackedEventIDs)
    self.numEvents = shownBlocks

    for i = (shownBlocks > 0 and not self.collapsed and shownBlocks + 1) or 1, 20 do
        local block = _G[self:GetName() .. "Block" .. i]
        if block then
            block.questID = false
            block.questLogIndex = 0
            block:Hide()
            GW.CombatQueue_Queue("update_tracker_bonus_itembutton_remove" .. i, block.UpdateObjectiveActionButton, {block})
            if block.ticker then
                block.ticker:Cancel()
                block.ticker = nil
            end
        end
    end

    if foundEvent or shownBlocks > 0 then
        self.header.title:SetText(EVENTS_LABEL .. " (" .. shownBlocks .. ")")
        self.header:Show()
    else
        self.header:Hide()
        wipe(savedQuests)
    end

    GwQuestTracker:LayoutChanged()
end

function GwBonusObjectivesTrackerContainerMixin:InitModule()
    self.blockMixInTemplate = GwBonusObjectivesTrackerBlockMixin

    self:SetScript("OnEvent", self.UpdateLayout)
    self:RegisterEvent("QUEST_LOG_UPDATE")
    self:RegisterEvent("TASK_PROGRESS_UPDATE")
    self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0, 0.5, 0.5, 0.75)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(EVENTS_LABEL)

    self.collapsed = false
    self.header:SetScript("OnMouseDown", self.CollapseHeader)
    self.header.title:SetTextColor(
        TRACKER_TYPE_COLOR.EVENT.r,
        TRACKER_TYPE_COLOR.EVENT.g,
        TRACKER_TYPE_COLOR.EVENT.b
    )

    hooksecurefunc(QuestUtil, "UntrackWorldQuest", function(questID)
        savedQuests[questID] = nil
        if trackedEventIDs[questID] then
            trackedEventIDs[questID].tracked = false
        end
    end)

    self:UpdateLayout()
end
