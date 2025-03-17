local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR


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

local function UpdateBlockInternal(self, parent, quest, questID, questLogIndex)
    local numObjectives = C_QuestLog.GetNumQuestObjectives(questID)
    local isComplete = quest:IsComplete()
    local requiredMoney = C_QuestLog.GetRequiredMoney(questID)
    local questFailed = C_QuestLog.IsFailed(questID)
    local hasGroupFinderButton = C_LFGList.CanCreateQuestGroup(questID)

    self.height = 25
    self.numObjectives = 0
    self.turnin:SetShown(self:IsQuestAutoTurnInOrAutoAccept(questID, "COMPLETE"))
    self.popupQuestAccept:SetShown(self:IsQuestAutoTurnInOrAutoAccept(questID, "OFFER"))
    self.groupButton:SetShown(hasGroupFinderButton)

    if requiredMoney then
        parent.watchMoneyReasons = parent.watchMoneyReasons + 1
    else
        parent.watchMoneyReasons = parent.watchMoneyReasons - 1
    end

    self.questID = questID
    self.id = questID
    self.questLogIndex = questLogIndex
    self.hasGroupFinderButton = hasGroupFinderButton

    self.Header:SetText(quest.title)

    GW.CombatQueue_Queue(nil, self.UpdateObjectiveActionButton, {self})

    if numObjectives == 0 and GetMoney() >= requiredMoney and not quest.startEvent then
        isComplete = true
    end

    self:UpdateBlockObjectives(numObjectives)

    if requiredMoney and requiredMoney > GetMoney() and not isComplete then
        self:AddObjective(GetMoneyString(GetMoney()) .. " / " .. GetMoneyString(requiredMoney), self.numObjectives + 1, {isQuest = true, finished = isComplete, objectiveType = nil})
    end

    if isComplete then
        if quest.isAutoComplete then
            self:AddObjective(QUEST_WATCH_CLICK_TO_COMPLETE, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
        else
            local completionText = GetQuestLogCompletionText(questLogIndex)
            if completionText then
                self:AddObjective(completionText, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
            else
                self:AddObjective(QUEST_WATCH_QUEST_READY, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
            end
        end
    elseif questFailed then
        self:AddObjective(FAILED, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
    end

    if not self.objectiveBlocks then
        self.objectiveBlocks = {}
    end

    self.height = self.height + 5
    self:SetHeight(self.height)
end

GwQuestLogBlockMixin = {}

function GwQuestLogBlockMixin:UpdateBlockObjectives(numObjectives)
    local addedObjectives = 1
    for objectiveIndex = 1, numObjectives do
        local text, objectiveType, finished = GetQuestObjectiveInfo(self.questID, objectiveIndex, false)
        if not finished or not text then
            self:AddObjective(text, addedObjectives, {isQuest = true, finished = finished, objectiveType = objectiveType})
            addedObjectives = addedObjectives + 1
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

    if event == "LOAD" then
        self:UpdateLayout()
        self.init = true
    elseif event == "QUEST_LOG_UPDATE" then
        self:UpdateLayout()
    elseif event == "QUEST_ACCEPTED" then
        local questID = ...
        if not C_QuestLog.IsQuestBounty(questID) then
            if C_QuestLog.IsQuestTask(questID) then
                if not C_QuestLog.IsWorldQuest(questID) then
                    self:PartialUpdate(questID)
                end
            else
                if GetCVarBool("autoQuestWatch") and numWatchedQuests < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
                    C_QuestLog.AddQuestWatch(questID)
                    self:PartialUpdate(questID)
                end
            end
        end
    elseif event == "QUEST_WATCH_LIST_CHANGED" then
        local questID, added = ...
        if added then
            if not C_QuestLog.IsQuestBounty(questID) or C_QuestLog.IsComplete(questID) then
                self:PartialUpdate(questID, added)
            end
        else
            self:UpdateLayout()
        end
    elseif event == "QUEST_AUTOCOMPLETE" then
        local questID = ...
        self:PartialUpdate(questID)
    elseif event == "PLAYER_MONEY" and self.watchMoneyReasons > numWatchedQuests then
        self:UpdateLayout()
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:RegisterEvent("QUEST_DATA_LOAD_RESULT")
    elseif event == "QUEST_DATA_LOAD_RESULT" then
        local questID, success = ...
        local idx = C_QuestLog.GetLogIndexForQuestID(questID)
        if success and questID and idx and idx > 0 then
            C_Timer.After(1, function() self:PartialUpdate(questID) end)
        end
    end

    if self.watchMoneyReasons > numWatchedQuests then
        self.watchMoneyReasons = self.watchMoneyReasons - numWatchedQuests
    end
    self:CheckForAutoQuests()
    GwQuestTracker:LayoutChanged()
end

function GwQuestLogMixin:GetBlockByQuestId(questID)
    local frameName = self:GetName()
    for i = 1, Constants.QuestWatchConsts.MAX_QUEST_WATCHES do
        local block = _G[frameName .. "Block" .. i]
        if block and block.questID == questID then
            return block
        end
    end
    return nil
end

function GwQuestLogMixin:GetOrCreateBlockByQuestId(questID, colorKey)
    local blockName = self:GetName() .. "Block"
    for i = 1, Constants.QuestWatchConsts.MAX_QUEST_WATCHES do
        if _G[blockName .. i] then
            if _G[blockName .. i].questID == questID then
                return _G[blockName .. i]
            elseif _G[blockName .. i].questID == nil then
                return self:GetBlock(i, colorKey, true)
            end
        else
            return self:GetBlock(i, colorKey, true)
        end
    end
    return nil
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
    if self.isUpdating or not self.init then
        return
    end
    self.isUpdating = true

    local counterQuest = 0
    local savedContainerHeight = self.collapsed and 20 or 1
    local shouldShowHeader = not self.collapsed
    local frameName = self:GetName()

    if self.collapsed then
        self.header:Show()
    elseif not self.isCampaignContainer then
        self.header:Hide()
    end

    local numQuests = C_QuestLog.GetNumQuestWatches()
    for i = 1, numQuests do
        local curQuestId = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if curQuestId then
            local q = QuestCache:Get(curQuestId)
            local isCampaign = q:IsCampaign()
            if (isCampaign and self.isCampaignContainer) or (not isCampaign and not self.isCampaignContainer) then
                if shouldShowHeader then
                    self.header:Show()
                    counterQuest = counterQuest + 1
                    if counterQuest == 1 then
                        savedContainerHeight = 20
                    end

                    local isFrequency = IsQuestFrequency(q)
                    local colorKey = self.isCampaignContainer and "CAMPAIGN" or (isFrequency and "DAILY" or "QUEST")
                    local block = self:GetBlock(counterQuest, colorKey, true)
                    block.isFrequency = isFrequency
                    block:UpdateBlock(self, q)
                    block:Show()
                    savedContainerHeight = savedContainerHeight + block.height
                    GW.CombatQueue_Queue("update_tracker_" .. frameName .. block.index, block.UpdateObjectiveActionButtonPosition, {block, savedContainerHeight, self.isCampaignContainer and nil or "QUEST"})
                else
                    counterQuest = counterQuest + 1
                    local block = _G[frameName .. "Block" .. counterQuest]
                    if block then
                        block:Hide()
                        block.questLogIndex = 0
                        GW.CombatQueue_Queue("update_tracker_" .. frameName .. counterQuest, block.UpdateObjectiveActionButton, {block})
                    end
                end
            end
        end
    end

    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(counterQuest > 0 and savedContainerHeight or 1)
    self.numQuests = counterQuest

    -- hide other quests
    for i = counterQuest + 1, Constants.QuestWatchConsts.MAX_QUEST_WATCHES do
        local block = _G[frameName .. "Block" .. i]
        if block then
            block.questID = nil
            block.questLogIndex = 0
            block:Hide()
            GW.CombatQueue_Queue("update_tracker_itembutton_remove" .. i, block.UpdateObjectiveActionButton, {block})
        end
    end
    if counterQuest == 0 and self.isCampaignContainer then
        self.header:Hide()
    end

    local headerCounterText = " (" .. counterQuest .. ")"
    self.header.title:SetText(self.isCampaignContainer and TRACKER_HEADER_CAMPAIGN_QUESTS .. headerCounterText or TRACKER_HEADER_QUESTS .. headerCounterText)

    GwQuestTracker:LayoutChanged()
    self.isUpdating = false
end

function GwQuestLogMixin:PartialUpdate(questID, added)
    if self.isUpdating or not self.init or not questID then
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
    local colorKey = self.isCampaignContainer and "CAMPAIGN" or (isFrequency and "DAILY" or "QUEST")
    local block = self:GetOrCreateBlockByQuestId(questID, colorKey)

    if block and questLogIndex and questLogIndex > 0 then
        block.isFrequency = isFrequency
        block:UpdateBlock(self, q, questID, questLogIndex)
        block:Show()
        if added then
            C_Timer.After(0.1, function() block:NewQuestAnimation() end)
        end
    end

    local newHeight = 20
    local counterQuest = 0
    local frameName = self:GetName()
    for i = 1, Constants.QuestWatchConsts.MAX_QUEST_WATCHES do
        local b = _G[frameName .. "Block" .. i]
        if b and b:IsShown() then
            newHeight = newHeight + b.height
            counterQuest = counterQuest + 1
        end
    end
    self:SetHeight(newHeight)
    local headerCounterText = " (" .. counterQuest .. ")"
    self.header.title:SetText(self.isCampaignContainer and TRACKER_HEADER_CAMPAIGN_QUESTS .. headerCounterText or TRACKER_HEADER_QUESTS .. headerCounterText)

    if block and block.hasItem then
        local heightForQuestItem = 20
        for i = 1, Constants.QuestWatchConsts.MAX_QUEST_WATCHES do
            local b = _G[frameName .. "Block" .. i]
            if b and b:IsShown() then
                heightForQuestItem = heightForQuestItem + b.height
                if b.questID == questID then
                    break
                end
            end
        end
        GW.CombatQueue_Queue("update_tracker_quest_itembutton_position" .. block.index, block.UdateQuestItemPositions, {block.actionButton, heightForQuestItem, self.isCampaignContainer and nil or "QUEST"})
    end

    GwQuestTracker:LayoutChanged()
    self.isUpdating = false
end

function GwQuestLogMixin:BlockOnClick(button)
    if ChatEdit_TryInsertQuestLinkForQuestID(self.questID) then
        return
    end

    if button ~= "RightButton" then
        local questID = self.id
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
            local questID = self.id
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
    self.watchMoneyReasons = 0
    self.isCampaignContainer = self:GetName() == "GwQuesttrackerContainerCampaign"

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function
    if self.isCampaignContainer then
        self.header.title:SetTextColor(TRACKER_TYPE_COLOR.CAMPAIGN.r, TRACKER_TYPE_COLOR.CAMPAIGN.g, TRACKER_TYPE_COLOR.CAMPAIGN.b)
        self.header.icon:SetTexCoord(0.5, 1, 0, 0.25)
        self.header.title:SetText(TRACKER_HEADER_CAMPAIGN_QUESTS)
    else
        self.header.title:SetTextColor(TRACKER_TYPE_COLOR.QUEST.r, TRACKER_TYPE_COLOR.QUEST.g, TRACKER_TYPE_COLOR.QUEST.b)
        self.header.icon:SetTexCoord(0, 0.5, 0.25, 0.5)
        self.header.title:SetText(TRACKER_HEADER_QUESTS)
    end

    self.init = false

    self:OnEvent("LOAD")
end
