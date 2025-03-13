local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local function QuestTrackerOnEvent(self, event, ...)
    local numWatchedQuests = C_QuestLog.GetNumQuestWatches()

    if event == "LOAD" then
        self:UpdateLayout()
        --C_Timer.After(0.5, function() fBonus:UpdateLayout() end) -- Needed??
        self.init = true
    elseif event == "QUEST_LOG_UPDATE" then
        self:UpdateLayout()
    elseif event == "QUEST_ACCEPTED" then
        local questID = ...
        if not C_QuestLog.IsQuestBounty(questID) then
            if C_QuestLog.IsQuestTask(questID) then
                if not C_QuestLog.IsWorldQuest(questID) then
                    self:UpdateLayoutByQuestId(questID)
                end
            else
                if GetCVarBool("autoQuestWatch") and C_QuestLog.GetNumQuestWatches() < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
                    C_QuestLog.AddQuestWatch(questID)
                    self:UpdateLayoutByQuestId(questID)
                end
            end
        end
    elseif event == "QUEST_WATCH_LIST_CHANGED" then
        local questID, added = ...
        if added then
            if not C_QuestLog.IsQuestBounty(questID) or C_QuestLog.IsComplete(questID) then
                self:UpdateLayoutByQuestId(questID, added)
            end
        else
            self:UpdateLayout()
        end
    elseif event == "QUEST_AUTOCOMPLETE" then
        local questID = ...
        self:UpdateLayoutByQuestId(questID)
    elseif event == "PLAYER_MONEY" and self.watchMoneyReasons > numWatchedQuests then
        self:UpdateLayout()
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:RegisterEvent("QUEST_DATA_LOAD_RESULT")
    elseif event == "QUEST_DATA_LOAD_RESULT" then
        local questID, success = ...
        local idx = C_QuestLog.GetLogIndexForQuestID(questID)
        if success and questID and idx and idx > 0 then
            C_Timer.After(1, function() self:UpdateLayoutByQuestId(questID) end)
        end
    end

    if self.watchMoneyReasons > numWatchedQuests then self.watchMoneyReasons = self.watchMoneyReasons - numWatchedQuests end
    self:CheckForAutoQuests()
    GwQuestTracker:LayoutChanged()
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

function GwQuestLogBlockMixin:UpdateBlock(parent, quest)
    local questID = quest:GetID()
    local numObjectives = C_QuestLog.GetNumQuestObjectives(questID)
    local isComplete = quest:IsComplete()
    local questLogIndex = quest:GetQuestLogIndex()
    local requiredMoney = C_QuestLog.GetRequiredMoney(questID)
    local questFailed = C_QuestLog.IsFailed(questID)
    local hasGroupFinderButton = C_LFGList.CanCreateQuestGroup(questID)

    self.height = 25
    self.numObjectives = 0
    self.turnin:SetShown(self:IsQuestAutoTurnInOrAutoAccept(questID, "COMPLETE"))
    self.popupQuestAccept:SetShown(self:IsQuestAutoTurnInOrAutoAccept(questID, "OFFER"))
    self.groupButton:SetShown(hasGroupFinderButton)

    if questID and questLogIndex and questLogIndex > 0 then
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

        --Quest item
        GW.CombatQueue_Queue(nil, self.UpdateObjectiveActionButton, {self})

        if numObjectives == 0 and GetMoney() >= requiredMoney and not quest.startEvent then
            isComplete = true
        end

        self:UpdateBlockObjectives(numObjectives)

        if requiredMoney ~= nil and requiredMoney > GetMoney() and not isComplete then
            self:AddObjective(GetMoneyString(GetMoney()) .. " / " .. GetMoneyString(requiredMoney), self.numObjectives + 1, {isQuest = true, finished = isComplete, objectiveType = nil})
        end

        if isComplete then
            if quest.isAutoComplete then
                self:AddObjective(QUEST_WATCH_CLICK_TO_COMPLETE, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
            else
                local completionText = GetQuestLogCompletionText(questLogIndex)

                if (completionText) then
                    self:AddObjective(completionText, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
                else
                    self:AddObjective(QUEST_WATCH_QUEST_READY, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
                end
            end
        elseif questFailed then
            self:AddObjective(FAILED, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
        end
        self:SetScript("OnClick", self.OnClick)
    end
    if self.objectiveBlocks == nil then
        self.objectiveBlocks = {}
    end

    for i = self.numObjectives + 1, 20 do
        if _G[self:GetName() .. "Objective" .. i] ~= nil then
            _G[self:GetName() .. "Objective" .. i]:Hide()
        end
    end
    self.height = self.height + 5
    self:SetHeight(self.height)
end

function GwQuestLogBlockMixin:UpdateBlockById(questID, parent, quest, questLogIndex)
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

    --Quest item
    GW.CombatQueue_Queue(nil, self.UpdateObjectiveActionButton, {self})

    if numObjectives == 0 and GetMoney() >= requiredMoney and not quest.startEvent then
        isComplete = true
    end

    self:UpdateBlockObjectives(numObjectives)

    if requiredMoney ~= nil and requiredMoney > GetMoney() and not isComplete then
        self:AddObjective(GetMoneyString(GetMoney()) .. " / " .. GetMoneyString(requiredMoney), self.numObjectives + 1, {isQuest = true, finished = isComplete, objectiveType = nil})
    end

    if isComplete then
        if quest.isAutoComplete then
            self:AddObjective(QUEST_WATCH_CLICK_TO_COMPLETE, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
        else
            local completionText = GetQuestLogCompletionText(questLogIndex)

            if (completionText) then
                self:AddObjective(completionText, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
            else
                self:AddObjective(QUEST_WATCH_QUEST_READY, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
            end
        end
    elseif questFailed then
        self:AddObjective(FAILED, self.numObjectives + 1, {isQuest = true, finished = false, objectiveType = nil})
    end
    self:SetScript("OnClick", self.OnClick)

    if self.objectiveBlocks == nil then
        self.objectiveBlocks = {}
    end

    for i = self.numObjectives + 1, 20 do
        if _G[self:GetName() .. "Objective" .. i] ~= nil then
            _G[self:GetName() .. "Objective" .. i]:Hide()
        end
    end
    self.height = self.height + 5
    self:SetHeight(self.height)
end

GwQuestLogMixin = {}
function GwQuestLogMixin:UpdateLayout()
    if self.isUpdating or not self.init then
        return
    end
    self.isUpdating = true

    local counterQuest = 0
    local savedContainerHeight = 1
    local shouldShowHeader = true
    local containerType = not self.isCampaignContainer and "QUEST"

    if not self.isCampaignContainer then self.header:Hide() end

    local numQuests = C_QuestLog.GetNumQuestWatches()
    if self.collapsed then
        self.header:Show()
        savedContainerHeight = 20
        shouldShowHeader = false
    end

    for i = 1, numQuests do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)

        -- check if we have a quest id to prevent errors
        if questID  then
            local q = QuestCache:Get(questID)
            local isCampaign = q:IsCampaign()
            if (isCampaign and self.isCampaignContainer) or (not isCampaign and not self.isCampaignContainer) then
                if shouldShowHeader then
                    self.header:Show()
                    counterQuest = counterQuest + 1

                    if counterQuest == 1 then
                        savedContainerHeight = 20
                    end

                    local block
                    if self.isCampaignContainer then
                        block  = self:GetBlock(counterQuest, "CAMPAIGN", true)
                    elseif not self.isCampaignContainer then
                        --if quest is reapeataple make it blue
                        local isFrequency = q.frequency and q.frequency > 0
                        if q.frequency == nil then
                            local questLogIndex = q:GetQuestLogIndex()
                            if questLogIndex and questLogIndex > 0 then
                                local questInfo = C_QuestLog.GetInfo(questLogIndex)
                                if questInfo then
                                    isFrequency = questInfo.frequency > 0
                                end
                            end
                        end
                        block = self:GetBlock(counterQuest, isFrequency and "DAILY" or "QUEST", true)
                        block.isFrequency = isFrequency
                    end
                    if block == nil then
                        return
                    end

                    block:UpdateBlock(self, q)
                    block:Show()
                    savedContainerHeight = savedContainerHeight + block.height
                    -- save some values for later use
                    block.savedHeight = savedContainerHeight
                    GW.CombatQueue_Queue("update_tracker_" .. self:GetName() .. block.index, block.UpdateObjectiveActionButtonPosition, {block, savedContainerHeight}, containerType)
                else
                    if (isCampaign and self.isCampaignContainer) or (not isCampaign and not self.isCampaignContainer) then
                        counterQuest = counterQuest + 1
                    end
                    if _G[self:GetName() .. "Block" .. counterQuest] then
                        _G[self:GetName() .. "Block" .. counterQuest]:Hide()
                        _G[self:GetName() .. "Block" .. counterQuest].questLogIndex = 0
                        GW.CombatQueue_Queue("update_tracker_" .. self:GetName() .. counterQuest, _G[self:GetName() .. "Block" .. counterQuest].UpdateObjectiveActionButton, {_G[self:GetName() .. "Block" .. counterQuest]})
                    end
                end
            end
        end
    end

    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(counterQuest > 0 and savedContainerHeight or 1)

    self.numQuests = counterQuest

    -- hide other quests
    for i = counterQuest + 1, 25 do
        if _G[self:GetName() .. "Block" .. i] then
            _G[self:GetName() .. "Block" .. i].questID = nil
            _G[self:GetName() .. "Block" .. i].questLogIndex = 0
            _G[self:GetName() .. "Block" .. i]:Hide()

            GW.CombatQueue_Queue("update_tracker_campaign_itembutton_remove" .. i, _G[self:GetName() .. "Block" .. i].UpdateObjectiveActionButton, {_G[self:GetName() .. "Block" .. i]})
        end
    end
    if counterQuest == 0 and self.isCampaignContainer then self.header:Hide() end

    -- Set number of quest to the Header
    self.header.title:SetText((self.isCampaignContainer and TRACKER_HEADER_CAMPAIGN_QUESTS or TRACKER_HEADER_QUESTS) .. " (" .. counterQuest .. ")")


    GwQuestTracker:LayoutChanged()
    self.isUpdating = false
end

function GwQuestLogMixin:UpdateLayoutByQuestId(questID, added)
    if self.isUpdating or not self.init or not questID then
        return
    end
    self.isUpdating = true

    -- get the correct quest block for that questID
    local q = QuestCache:Get(questID)
    local isCampaign = q:IsCampaign()

    if self.collapsed or ((isCampaign and not self.isCampaignContainer) or (not isCampaign and self.isCampaignContainer)) then
        self.isUpdating = false
        return
    end
    local questLogIndex = q:GetQuestLogIndex()
    local isFrequency = q.frequency and q.frequency > 0
    if q.frequency == nil then
        if questLogIndex and questLogIndex > 0 then
            local questInfo = C_QuestLog.GetInfo(questLogIndex)
            if questInfo then
                isFrequency = questInfo.frequency > 0
            end
        end
    end

    local questWatchId = self:GetQuestWatchId(questID)
    local block = questWatchId and self:GetOrCreateBlockByQuestId(questID, isFrequency and "DAILY" or "QUEST")
    local header = self.header
    local savedHeight = 20
    local heightForQuestItem = 20
    local counterQuest = 0
    if questWatchId and block and questLogIndex and questLogIndex > 0 then
        block:UpdateBlockById(questID, self, q, questLogIndex)
        block.isFrequency = isFrequency
        block:Show()
        if added == true then
            C_Timer.After(0.1, function() block:NewQuestAnimation() end)
        end

        for i = 1, 25 do
            if _G[self:GetName() .. "Block" .. i] and _G[self:GetName() .. "Block" .. i]:IsShown() and _G[self:GetName() .. "Block" .. i].questID ~= nil then
                savedHeight = savedHeight + _G[self:GetName() .. "Block" .. i].height
                counterQuest = counterQuest + 1
            elseif _G[self:GetName() .. "Block" .. i] and not _G[self:GetName() .. "Block" .. i]:IsShown() then
                _G[self:GetName() .. "Block" .. i]:Hide()
            end
        end

        self.oldHeight = GW.RoundInt(self:GetHeight())
        self:SetHeight(savedHeight)
        header:Show()

        if block.hasItem then
            for i = 1, 25 do
                if _G[self:GetName() .. "Block" .. i] and _G[self:GetName() .. "Block" .. i]:IsShown() and _G[self:GetName() .. "Block" .. i].questID ~= questID then
                    heightForQuestItem = heightForQuestItem + _G[self:GetName() .. "Block" .. i].height
                elseif _G[self:GetName() .. "Block" .. i] and _G[self:GetName() .. "Block" .. i]:IsShown() and _G[self:GetName() .. "Block" .. i].questID == questID then
                    heightForQuestItem = heightForQuestItem + _G[self:GetName() .. "Block" .. i].height
                    break
                end
            end
            GW.CombatQueue_Queue("update_tracker_quest_itembutton_position" .. block.index, block.UdateQuestItemPositions, {block.actionButton, heightForQuestItem, self.isCampaignContainer and nil or "QUEST"})
        end

        -- Set number of quest to the Header
        local headerCounterText = " (" .. counterQuest .. ")"
        header.title:SetText(self.isCampaignContainer and TRACKER_HEADER_CAMPAIGN_QUESTS .. headerCounterText or TRACKER_HEADER_QUESTS .. headerCounterText)
    end

    self.isUpdating = false
end

function GwQuestLogMixin:BlockOnClick(button)
    if ChatEdit_TryInsertQuestLinkForQuestID(self.questID) then
        return
    end

    if button ~= "RightButton" then
		local questID = self.id;
		if IsModifiedClick("QUESTWATCHTOGGLE") then
			C_QuestLog.RemoveQuestWatch(questID);
		else
			local quest = QuestCache:Get(questID);
			if quest.isAutoComplete and quest:IsComplete() then
				RemoveAutoQuestPopUp(questID)
				ShowQuestComplete(questID);
			else
				QuestMapFrame_OpenToQuestDetails(questID);
			end
		end
	else
		MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
			local questID = self.id;
			rootDescription:CreateTitle(C_QuestLog.GetTitleForQuestID(questID));

			if C_SuperTrack.GetSuperTrackedQuestID() ~= questID then
				rootDescription:CreateButton(SUPER_TRACK_QUEST, function()
					C_SuperTrack.SetSuperTrackedQuestID(questID);
				end);
			else
				rootDescription:CreateButton(STOP_SUPER_TRACK_QUEST, function()
					C_SuperTrack.SetSuperTrackedQuestID(0);
				end);
			end

			local toggleDetailsText = QuestUtil.IsShowingQuestDetails(questID) and OBJECTIVES_HIDE_VIEW_IN_QUESTLOG or OBJECTIVES_VIEW_IN_QUESTLOG;

			rootDescription:CreateButton(toggleDetailsText, function()
				QuestUtil.OpenQuestDetails(questID);
			end);

			rootDescription:CreateButton(OBJECTIVES_SHOW_QUEST_MAP, function()
				QuestMapFrame_OpenToQuestDetails(questID);
			end);

			rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function()
				C_QuestLog.RemoveQuestWatch(questID);
			end);

			if C_QuestLog.IsPushableQuest(questID) and IsInGroup() then
				rootDescription:CreateButton(SHARE_QUEST, function()
					QuestUtil.ShareQuest(questID);
				end);
			end
			rootDescription:CreateButton(ABANDON_QUEST_ABBREV, function()
				QuestMapQuestOptions_AbandonQuest(questID);
			end)
		end)
	end
end

GwObjectivesQuestContainerMixin = CreateFromMixins(GwQuestLogMixin)

function GwObjectivesQuestContainerMixin:InitModule()
    self.blockMixInTemplate = GwQuestLogBlockMixin

    self:SetScript("OnEvent", QuestTrackerOnEvent)
    self:RegisterEvent("QUEST_LOG_UPDATE")
    self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    self:RegisterEvent("QUEST_AUTOCOMPLETE")
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("PLAYER_MONEY")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.watchMoneyReasons = 0
    self.isCampaignContainer = self:GetName() == "GwQuesttrackerContainerCampaign"

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0, 0.5, 0.25, 0.5)
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

    QuestTrackerOnEvent(self, "LOAD")
end
