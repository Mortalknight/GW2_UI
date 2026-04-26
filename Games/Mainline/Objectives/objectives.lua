---@class GW2
local GW = select(2, ...)

local function IsQuestFrequency(q)
    local isFreq = q.frequency and q.frequency > 0
    if q.frequency == nil then
        local questLogIndex = q:GetQuestLogIndex()
        if questLogIndex and questLogIndex > 0 then
            local questInfo = C_QuestLog.GetInfo(questLogIndex)
            if questInfo then
                isFreq = questInfo.frequency > 0
            end
        end
    end
    return isFreq
end

local function BrightenColor(r, g, b, factor)
    factor = factor or 0.3
    return
        math.min(1, r + (1 - r) * factor),
        math.min(1, g + (1 - g) * factor),
        math.min(1, b + (1 - b) * factor)
end

local function ShouldSortSuperTrackedQuestToTop()
    return GW.settings.OBJECTIVES_SUPERTRACKED_QUEST_TOP
end

local function UpdateBlockInternal(self, parent, quest, questID, questLogIndex)
    local numObjectives = C_QuestLog.GetNumQuestObjectives(questID)
    local isComplete = quest:IsComplete()
    local questFailed = C_QuestLog.IsFailed(questID)
    local isSuperTracked = (questID == C_SuperTrack.GetSuperTrackedQuestID())
    local shouldShowWaypoint = isSuperTracked or (questID == QuestMapFrame_GetFocusedQuestID())

    self.height = GW.GetObjectivesBlockBaseHeight()
    self.numObjectives = 0
    self.turnin:SetShown(self:IsQuestAutoTurnInOrAutoAccept(questID, "COMPLETE"))
    self.popupQuestAccept:SetShown(self:IsQuestAutoTurnInOrAutoAccept(questID, "OFFER"))
    self:UpdateFindGroupButton(questID, false)

    if quest.requiredMoney > 0 then
        parent.watchMoneyReasons = parent.watchMoneyReasons + 1
    else
        parent.watchMoneyReasons = parent.watchMoneyReasons - 1
    end

    self.questID = questID
    self.questLogIndex = questLogIndex
    self.title = quest.title
    self.isSuperTracked = isSuperTracked
    self.Header:SetText(quest.title)

    if isSuperTracked then
        local r, g, b = BrightenColor(self.color.r, self.color.g, self.color.b, 0.3)
        self.Header:SetTextColor(r, g, b)
        self:GetScript("OnEnter")(self)
    else
        self:GetScript("OnLeave")(self)
    end

    GW.CombatQueue:Queue(nil, self.UpdateObjectiveActionButton, {self})

    if numObjectives == 0 and GetMoney() >= quest.requiredMoney and not quest.startEvent then
        isComplete = true
    end

    self:UpdateBlockObjectives(numObjectives)

    if isComplete then
        if quest.isAutoComplete then
            self:AddObjective(QUEST_WATCH_CLICK_TO_COMPLETE, {isQuest = true, finished = false, objectiveType = nil})
        else
            local completionText = GetQuestLogCompletionText(questLogIndex)
            if completionText then
                if shouldShowWaypoint then
                    local waypointText = C_QuestLog.GetNextWaypointText(questID)
                    if waypointText then
                        self:AddObjective(WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText), {isQuest = true, finished = false, objectiveType = nil})
                    end
                end
                self:AddObjective(completionText, {isQuest = true, finished = false, objectiveType = nil})
            else
                local waypointText = C_QuestLog.GetNextWaypointText(questID)
                if waypointText then
                    self:AddObjective(waypointText, {isQuest = true, finished = false, objectiveType = nil})
                else
                    self:AddObjective(QUEST_WATCH_QUEST_READY, {isQuest = true, finished = false, objectiveType = nil})
                end
            end
        end
    elseif questFailed then
        self:AddObjective(FAILED, {isQuest = true, finished = false, objectiveType = nil})
    else
        if shouldShowWaypoint then
			local waypointText = C_QuestLog.GetNextWaypointText(questID);
			if waypointText  then
                self:AddObjective(WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText), {isQuest = true, finished = isComplete, objectiveType = nil})
			end
		end

        if quest.requiredMoney > GetMoney() then
            self:AddObjective(GetMoneyString(GetMoney()) .. " / " .. GetMoneyString(quest.requiredMoney), {isQuest = true, finished = isComplete, objectiveType = nil})
        end

        -- timer bar
		local timeTotal, timeElapsed = C_QuestLog.GetTimeAllowed(questID)
		if timeTotal and timeElapsed and timeElapsed < timeTotal then
            self:AddObjective(TIME_REMAINING, {isQuest = true, qty = nil, totalqty = nil, timerShown = true, duration = timeTotal, startTime = GetTime() - timeElapsed})
		end
    end

    self.height = self.height + GW.GetObjectivesBottomPadding()
    self:SetHeight(self.height)
end

GwQuestLogBlockMixin = {}

function GwQuestLogBlockMixin:UpdateBlockObjectives(numObjectives)
    local showCompletedObjectives = GW.settings.OBJECTIVES_SHOW_COMPLETED_OBJECTIVES
    for objectiveIndex = 1, numObjectives do
        local text, objectiveType, finished = GetQuestObjectiveInfo(self.questID, objectiveIndex, false)
        if text and (showCompletedObjectives or not finished) then
            self:AddObjective(text, {isQuest = true, finished = finished, useCompletedLine = showCompletedObjectives, objectiveType = objectiveType})
        end
    end
end

function GwQuestLogBlockMixin:UpdateBlock(parent, quest, questID, questLogIndex)
    if quest and not questID then
        questID = quest:GetID()
        questLogIndex = quest:GetQuestLogIndex()
    end
    UpdateBlockInternal(self, parent, quest, questID, questLogIndex)
end

GwQuestLogMixin = {}

function GwQuestLogMixin:OnEvent(event, ...)
    local numWatchedQuests = C_QuestLog.GetNumQuestWatches()

    if event == "QUEST_LOG_UPDATE" then
        self:QueueUpdateLayout()
    elseif event == "QUEST_ACCEPTED" then
        local questID = ...
        if not C_QuestLog.IsQuestBounty(questID) then
            if C_QuestLog.IsQuestTask(questID) then
                if not C_QuestLog.IsWorldQuest(questID) then
                    self:QueuePartialUpdate(questID)
                end
            else
                if GetCVarBool("autoQuestWatch") and numWatchedQuests < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
                    C_QuestLog.AddQuestWatch(questID)
                    self:QueuePartialUpdate(questID)
                end
            end
        end
    elseif event == "QUEST_WATCH_LIST_CHANGED" then
        local questID, added = ...
        if added then
            if not C_QuestLog.IsQuestBounty(questID) or C_QuestLog.IsComplete(questID) then
                self:QueuePartialUpdate(questID, added)
            end
        else
            self:QueueUpdateLayout()
        end
    elseif event == "QUEST_AUTOCOMPLETE" then
        local questID = ...
        self:QueuePartialUpdate(questID)
    elseif event == "PLAYER_MONEY" and self.watchMoneyReasons > numWatchedQuests then
        self:QueueUpdateLayout()
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:RegisterEvent("QUEST_DATA_LOAD_RESULT")
    elseif event == "QUEST_DATA_LOAD_RESULT" then
        local questID, success = ...
        local idx = C_QuestLog.GetLogIndexForQuestID(questID)
        if success and questID and idx and idx > 0 then
            C_Timer.After(1, function() self:QueuePartialUpdate(questID) end)
        end
    else
        self:QueueUpdateLayout()
    end

    if self.watchMoneyReasons > numWatchedQuests then
        self.watchMoneyReasons = self.watchMoneyReasons - numWatchedQuests
    end
end

local function QuestLogFlushQueuedUpdatesOnUpdate(frame)
    frame:SetScript("OnUpdate", nil)

    local container = frame.container
    container.updateFlushQueued = false

    local didUpdate = false
    if container.fullUpdateQueued then
        container.fullUpdateQueued = false
        wipe(container.partialUpdatesByQuestID)
        wipe(container.partialUpdateOrder)
        container:UpdateLayout()
        didUpdate = true
    else
        for _, questID in ipairs(container.partialUpdateOrder) do
            local updateData = container.partialUpdatesByQuestID[questID]
            if updateData then
                container:PartialUpdate(questID, updateData.added)
                didUpdate = true
            end
        end
        wipe(container.partialUpdatesByQuestID)
        wipe(container.partialUpdateOrder)
    end

    container:CheckForAutoQuests()
    if didUpdate then
        GwQuestTracker:LayoutChanged()
    end
end

function GwQuestLogMixin:QueueUpdateLayout()
    self.fullUpdateQueued = true
    wipe(self.partialUpdatesByQuestID)
    wipe(self.partialUpdateOrder)

    if self.updateFlushQueued then
        return
    end

    self.updateFlushQueued = true
    self.updateQueueFrame:SetScript("OnUpdate", QuestLogFlushQueuedUpdatesOnUpdate)
end

function GwQuestLogMixin:QueuePartialUpdate(questID, added)
    if not questID or self.fullUpdateQueued then
        return
    end

    local updateData = self.partialUpdatesByQuestID[questID]
    if updateData then
        updateData.added = updateData.added or added
    else
        self.partialUpdatesByQuestID[questID] = {added = added}
        tinsert(self.partialUpdateOrder, questID)
    end

    if self.updateFlushQueued then
        return
    end

    self.updateFlushQueued = true
    self.updateQueueFrame:SetScript("OnUpdate", QuestLogFlushQueuedUpdatesOnUpdate)
end

function GwQuestLogMixin:GetBlockByQuestId(questID)
    for i = 1, #self.blocks do
        local block = self.blocks[i]
        if block.questID == questID then
            return block
        end
    end
    return nil
end

function GwQuestLogMixin:GetOrCreateBlockByQuestId(questID, colorKey)
    for i = 1, #self.blocks do
        local block = self.blocks[i]
        if block.questID == questID then
            return block
        elseif block.questID == nil then
            return self:GetBlock(i, colorKey, true)
        end
    end
    return self:GetBlock(#self.blocks + 1, colorKey, true)
end

function GwQuestLogMixin:GetQuestWatchId(questID)
    for i = 1, C_QuestLog.GetNumQuestWatches() do
        if questID == C_QuestLog.GetQuestIDForQuestWatchIndex(i) then
            return i
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

function GwQuestLogMixin:UpdateLayout()
    if self.isUpdating then
        return
    end
    self.isUpdating = true

    local counterQuest = 0
    local savedContainerHeight = self.collapsed and GW.GetObjectivesHeaderHeight() or 0.1
    local shouldShowHeader = not self.collapsed
    local frameName = self:GetName()
    local watchedQuestIDs = {}
    local watchedQuestOrder = {}

    if self.collapsed then
        self.header:Show()
    elseif not self.isCampaignContainer then
        self.header:Hide()
    end

    local numQuests = C_QuestLog.GetNumQuestWatches()
    for i = 1, numQuests do
        local curQuestId = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if curQuestId then
            watchedQuestOrder[curQuestId] = i
            watchedQuestIDs[#watchedQuestIDs + 1] = curQuestId
        end
    end

    if ShouldSortSuperTrackedQuestToTop() then
        local superTrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID()
        table.sort(watchedQuestIDs, function(leftQuestID, rightQuestID)
            local isLeftSuperTracked = leftQuestID == superTrackedQuestID
            local isRightSuperTracked = rightQuestID == superTrackedQuestID

            if isLeftSuperTracked ~= isRightSuperTracked then
                return isLeftSuperTracked
            end

            return (watchedQuestOrder[leftQuestID] or 0) < (watchedQuestOrder[rightQuestID] or 0)
        end)
    end

    for _, curQuestId in ipairs(watchedQuestIDs) do
        if curQuestId then
            local q = QuestCache:Get(curQuestId)
            local isCampaign = q:IsCampaign()
            if (isCampaign and self.isCampaignContainer) or (not isCampaign and not self.isCampaignContainer) then
                if shouldShowHeader then
                    self.header:Show()
                    counterQuest = counterQuest + 1
                    if counterQuest == 1 then
                        savedContainerHeight = GW.GetObjectivesHeaderHeight()
                    end

                    local isFrequency = IsQuestFrequency(q)
                    local colorKey = self.isCampaignContainer and GW.Enum.ObjectivesNotificationType.Campaign or (isFrequency and GW.Enum.ObjectivesNotificationType.DailyQuest or GW.Enum.ObjectivesNotificationType.Quest)
                    local block = self:GetBlock(counterQuest, colorKey, true)
                    block.isFrequency = isFrequency
                    block:UpdateBlock(self, q)
                    block:Show()
                    savedContainerHeight = savedContainerHeight + block.height
                    block.fromContainerTopHeight = savedContainerHeight
                    GW.CombatQueue:Queue("update_tracker_" .. frameName .. block.index, block.UpdateObjectiveActionButtonPosition, {block})
                else
                    counterQuest = counterQuest + 1
                    local block = self.blocks and self.blocks[counterQuest]
                    if block then
                        block:Hide()
                        block.questLogIndex = 0
                        GW.CombatQueue:Queue("update_tracker_" .. frameName .. counterQuest, block.UpdateObjectiveActionButton, {block})
                    end
                end
            end
        end
    end
    self:SetHeight(counterQuest > 0 and savedContainerHeight or 0.1)
    self.numQuests = counterQuest

    -- hide other quests
    for i = counterQuest + 1, #self.blocks do
        local block = self.blocks[i]
        block.questID = nil
        block.questLogIndex = 0
        block:Hide()
        GW.CombatQueue:Queue("update_tracker_itembutton_remove" .. i, block.UpdateObjectiveActionButton, {block})
    end

    if counterQuest == 0 and self.isCampaignContainer then
        self.header:Hide()
    end

    local headerCounterText = " (" .. counterQuest .. ")"
    self.header.title:SetText(self.isCampaignContainer and TRACKER_HEADER_CAMPAIGN_QUESTS .. headerCounterText or TRACKER_HEADER_QUESTS .. headerCounterText)

    self.isUpdating = false
end

function GwQuestLogMixin:PartialUpdate(questID, added)
    if self.isUpdating or not questID then
        return
    end

    if ShouldSortSuperTrackedQuestToTop() then
        self:UpdateLayout()
        GwQuestTracker:LayoutChanged()
        return
    end

    self.isUpdating = true

    local questWatchId = self:GetQuestWatchId(questID)
    local q = QuestCache:Get(questID)
    local isCampaign = q:IsCampaign()
    if self.collapsed or ((isCampaign and not self.isCampaignContainer) or (not isCampaign and self.isCampaignContainer)) or questWatchId == nil or not questWatchId then
        self.isUpdating = false
        return
    end

    local questLogIndex = q:GetQuestLogIndex()
    local isFrequency = IsQuestFrequency(q)
    local colorKey = self.isCampaignContainer and GW.Enum.ObjectivesNotificationType.Campaign or (isFrequency and GW.Enum.ObjectivesNotificationType.DailyQuest or GW.Enum.ObjectivesNotificationType.Quest)
    local block = self:GetOrCreateBlockByQuestId(questID, colorKey)

    if block and questLogIndex and questLogIndex > 0 then
        block.isFrequency = isFrequency
        block:UpdateBlock(self, q, questID, questLogIndex)
        block:Show()
        if added then
            C_Timer.After(0.1, function()
                local b = self:GetBlockByQuestId(questID)
                if b then b:NewQuestAnimation() end
            end)
        end
    end

    local newHeight = GW.GetObjectivesHeaderHeight()
    local counterQuest = 0

    for i = 1, #self.blocks do
        local b = self.blocks[i]
        if b:IsShown() then
            newHeight = newHeight + b.height
            counterQuest = counterQuest + 1
        end
    end

    self:SetHeight(newHeight)
    local headerCounterText = " (" .. counterQuest .. ")"
    self.header.title:SetText(self.isCampaignContainer and TRACKER_HEADER_CAMPAIGN_QUESTS .. headerCounterText or TRACKER_HEADER_QUESTS .. headerCounterText)

    if block and block.hasItem then
        local heightForQuestItem = GW.GetObjectivesHeaderHeight()
        for i = 1, #self.blocks do
            local b = self.blocks[i]
            if b:IsShown() then
                heightForQuestItem = heightForQuestItem + b.height
                if b.questID == questID then
                    break
                end
            end
        end

        block.fromContainerTopHeight = heightForQuestItem
        GW.CombatQueue:Queue("update_tracker_quest_itembutton_position" .. block.index, block.UpdateObjectiveActionButtonPosition, {block})
    end

    self.isUpdating = false
end

function GwQuestLogMixin:BlockOnClick(button)
    if ChatFrameUtil.TryInsertQuestLinkForQuestID(self.questID) then
        return
    end

    if button ~= "RightButton" then
        local questID = self.questID
        if IsModifiedClick("QUESTWATCHTOGGLE") then
            C_QuestLog.RemoveQuestWatch(questID)
        else
            local quest = QuestCache:Get(questID)
            if quest.isAutoComplete and quest:IsComplete() then
                RemoveAutoQuestPopUp(questID)
                ShowQuestComplete(questID)
            else
                QuestMapFrame_OpenToQuestDetails(questID)
            end
        end
    else
        MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
            rootDescription:SetMinimumWidth(1)
            local questID = self.questID
            rootDescription:CreateTitle(C_QuestLog.GetTitleForQuestID(questID))

            if C_SuperTrack.GetSuperTrackedQuestID() ~= questID then
                rootDescription:CreateButton(SUPER_TRACK_QUEST, function()
                    C_SuperTrack.SetSuperTrackedQuestID(questID)
                end)
            else
                rootDescription:CreateButton(STOP_SUPER_TRACK_QUEST, function()
                    C_SuperTrack.SetSuperTrackedQuestID(0)
                end)
            end

            local toggleDetailsText = QuestUtil.IsShowingQuestDetails(questID) and OBJECTIVES_HIDE_VIEW_IN_QUESTLOG or OBJECTIVES_VIEW_IN_QUESTLOG

            rootDescription:CreateButton(toggleDetailsText, function()
                QuestUtil.OpenQuestDetails(questID)
            end)

            rootDescription:CreateButton(OBJECTIVES_SHOW_QUEST_MAP, function()
                QuestMapFrame_OpenToQuestDetails(questID)
            end)

            rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function()
                C_QuestLog.RemoveQuestWatch(questID)
            end)

            if C_QuestLog.IsPushableQuest(questID) and IsInGroup() then
                rootDescription:CreateButton(SHARE_QUEST, function()
                    QuestUtil.ShareQuest(questID)
                end)
            end
            rootDescription:CreateButton(ABANDON_QUEST_ABBREV, function()
                QuestMapQuestOptions_AbandonQuest(questID)
            end)
            rootDescription:CreateButton(GW.L["Wowhead URL"], function()
                GW.ShowPopup({text = GW.L["Wowhead URL"],
                    hasEditBox = true,
                    hideOnEscape = true,
                    EditBoxOnEnterPressed = function(popup) popup:Hide() end,
                    EditBoxOnEscapePressed = function(popup) popup:Hide() end,
                    button2 = CLOSE,
                    inputText = (function()
                        return GW.GetWowheadLinkForLanguage() .. "quest=" .. questID

                    end)(),
                    })
            end)
        end)
    end
end

GwObjectivesQuestContainerMixin = CreateFromMixins(GwQuestLogMixin)

function GwObjectivesQuestContainerMixin:InitModule()
    self.blockMixInTemplate = GwQuestLogBlockMixin

    self:SetScript("OnEvent", self.OnEvent)
    self:RegisterEvent("QUEST_LOG_UPDATE")
    self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    self:RegisterEvent("QUEST_AUTOCOMPLETE")
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("PLAYER_MONEY")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("SUPER_TRACKING_CHANGED")
    self:RegisterEvent("QUEST_POI_UPDATE")
    self.watchMoneyReasons = 0
    self.isCampaignContainer = self:GetName() == "GwQuesttrackerContainerCampaign"
    self.updateQueueFrame = CreateFrame("Frame", nil, self)
    self.updateQueueFrame.container = self
    self.updateFlushQueued = false
    self.fullUpdateQueued = false
    self.partialUpdatesByQuestID = {}
    self.partialUpdateOrder = {}

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    self.header.title:SetShadowOffset(1, -1)

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:ToggleCollapsed() end) -- this way, otherwiese we have a wrong self at the function
    if self.isCampaignContainer then
        self.header.title:SetTextColor(GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Campaign]:GetRGB())
        self.header.icon:SetTexCoord(0.5, 1, 0, 0.25)
        self.header.title:SetText(TRACKER_HEADER_CAMPAIGN_QUESTS)
    else
        self.header.title:SetTextColor(GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Quest]:GetRGB())
        self.header.icon:SetTexCoord(0, 0.5, 0.25, 0.5)
        self.header.title:SetText(TRACKER_HEADER_QUESTS)
    end

    self:OnEvent("LOAD")
end
