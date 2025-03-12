local _, GW = ...
local RoundDec = GW.RoundDec
local IsIn = GW.IsIn
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local AFP = GW.AddProfiling

-- needed frames
local fTracker
local fTraScr
local fNotify
local fBoss
local fArenaBG
local fScen
local fAchv
local fCampaign
local fQuest
local fBonus
local fRecipe
local fMonthlyActivity
local fCollection


local function ParseSimpleObjective(text)
    local itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)")

    if itemName == nil then
        numItems, numNeeded, _ = string.match(text, "(%d+)/(%d+) (%S+)")
    end
    local ndString = ""

    if numItems ~= nil then
        ndString = numItems
    end

    if numNeeded ~= nil then
        ndString = ndString .. "/" .. numNeeded
    end

    return string.gsub(text, ndString, "")
end
GW.ParseSimpleObjective = ParseSimpleObjective


local function ParseCriteria(quantity, totalQuantity, criteriaString, isMythicKeystone, mythicKeystoneCurrentValue, isWeightedProgress)
    if quantity ~= nil and totalQuantity ~= nil and criteriaString ~= nil then
        if isMythicKeystone then
            if isWeightedProgress then
                return string.format("%.2f", (mythicKeystoneCurrentValue / totalQuantity * 100)) .."% " ..  string.format("(%s/%s) %s", mythicKeystoneCurrentValue, totalQuantity, criteriaString)
            else
                return string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
            end
        elseif totalQuantity == 0 then
            return string.format("%d %s", quantity, criteriaString)
        else
            return string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
        end
    end

    return criteriaString
end
GW.ParseCriteria = ParseCriteria

local function FormatObjectiveNumbers(text)
    local itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)")

    if itemName == nil then
        numItems, numNeeded, itemName = string.match(text, "(%d+)/(%d+) ((.*))")
    end
    numItems = tonumber(numItems)
    numNeeded = tonumber(numNeeded)

    if numItems ~= nil and numNeeded ~= nil then
        return GW.GetLocalizedNumber(numItems) .. " / " .. GW.GetLocalizedNumber(numNeeded) .. " " .. itemName
    end
    return text
end
GW.FormatObjectiveNumbers = FormatObjectiveNumbers


local questExraButtonHelperFrame = CreateFrame("Frame")
questExraButtonHelperFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    GW.updateExtraQuestItemPositions(self.height)
end)

local function updateExtraQuestItemPositions(height)
    if GwBonusItemButton == nil or GwScenarioItemButton == nil then
        return
    end

    if InCombatLockdown() then
        questExraButtonHelperFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        questExraButtonHelperFrame.height = height
        return
    end

    height = height or 0

    if fNotify:IsShown() then
        height = height + fNotify.desc:GetHeight() + 50
    end

    height = height + fBoss:GetHeight() + fArenaBG:GetHeight()

    GwScenarioItemButton:SetPoint("TOPLEFT", fTracker, "TOPRIGHT", -330, -height)

    height = height + fScen:GetHeight() + fQuest:GetHeight() + fAchv:GetHeight() + fCampaign:GetHeight()

    -- get correct height for WQ block
    for i = 1, 20 do
        if _G["GwBonusObjectiveBlock" .. i] ~= nil and _G["GwBonusObjectiveBlock" .. i].questID then
            if _G["GwBonusObjectiveBlock" .. i].hasItem then
                break
            end
            height = height + _G["GwBonusObjectiveBlock" .. i]:GetHeight()
        end
    end

    GwBonusItemButton:SetPoint("TOPLEFT", fTracker, "TOPRIGHT", -330, -height + -25)
end
GW.updateExtraQuestItemPositions = updateExtraQuestItemPositions

local function QuestTrackerLayoutChanged()
    updateExtraQuestItemPositions()
    -- adjust scrolframe height
    local height = fCollection:GetHeight() + fMonthlyActivity:GetHeight() + fRecipe:GetHeight() + fBonus:GetHeight() + fQuest:GetHeight() + fCampaign:GetHeight() + fAchv:GetHeight() + 60 + (GwQuesttrackerContainerWQT and GwQuesttrackerContainerWQT:GetHeight() or 0) + (GwQuesttrackerContainerPetTracker and GwQuesttrackerContainerPetTracker:GetHeight() or 0) + (GwQuesttrackerContainerTodoloo and GwQuesttrackerContainerTodoloo:GetHeight() or 0)
    local scroll = 0
    local trackerHeight = GW.settings.QuestTracker_pos_height - fBoss:GetHeight() - fArenaBG:GetHeight() - fScen:GetHeight() - fNotify:GetHeight()
    if height > tonumber(trackerHeight) then
        scroll = math.abs(trackerHeight - height)
    end
    fTraScr.maxScroll = scroll

    fTraScr:SetSize(fTracker:GetWidth(), height)
end
GW.QuestTrackerLayoutChanged = QuestTrackerLayoutChanged

local function QuestTrackerOnEvent(self, event, ...)
    local numWatchedQuests = C_QuestLog.GetNumQuestWatches()

    if event == "QUEST_LOG_UPDATE" then
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
    elseif event == "LOAD" then
        self:UpdateLayout()
        C_Timer.After(0.5, function() fBonus:UpdateLayout() end)
        self.init = true
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:RegisterEvent("QUEST_DATA_LOAD_RESULT")
    elseif event == "QUEST_DATA_LOAD_RESULT" then
        local questID, success = ...
        local idx = C_QuestLog.GetLogIndexForQuestID(questID)
        if success and questID and idx and idx > 0 then
            C_Timer.After(1, function()self:UpdateLayoutByQuestId(questID) end)
        end
    end

    if self.watchMoneyReasons > numWatchedQuests then self.watchMoneyReasons = self.watchMoneyReasons - numWatchedQuests end
    self:CheckForAutoQuests()
    QuestTrackerLayoutChanged()
end

local function tracker_OnUpdate()
    local prevState = fNotify.shouldDisplay

    if GW.Libs.GW2Lib:GetPlayerLocationMapID() or GW.Libs.GW2Lib:GetPlayerInstanceMapID() then
        GW.SetObjectiveNotification()
    end

    if prevState ~= fNotify.shouldDisplay then
        GW.NotificationStateChanged(fNotify.shouldDisplay)
    end
end
GW.forceCompassHeaderUpdate = tracker_OnUpdate

local function bonus_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetText(RoundDec(self.progress * 100, 0) .. "%")
    GameTooltip:Show()
end
AFP("bonus_OnEnter", bonus_OnEnter)

local function AdjustItemButtonPositions()
    for i = 1, 25 do
        local campaignBlock = _G["GwQuesttrackerContainerCampaignBlock" .. i]
        local questBlock = _G["GwQuesttrackerContainerQuestsBlock" .. i]
        local bonusObjectiveBlock = _G["GwQuesttrackerContainerBonusObjectivesBlock" .. i]
        if campaignBlock then
            if i <= fCampaign.numQuests then
                GW.CombatQueue_Queue("update_tracker_campaign_itembutton_position" .. campaignBlock.index, campaignBlock.UpdateObjectiveActionButtonPosition, {campaignBlock, campaignBlock.savedHeight})
            else
                GW.CombatQueue_Queue("update_tracker_campaign_itembutton_remove" .. i, campaignBlock.UpdateObjectiveActionButton, {campaignBlock})
            end
        end
        if questBlock then
            if i <= fQuest.numQuests then
                GW.CombatQueue_Queue("update_tracker_quest_itembutton_position" .. questBlock.index, questBlock.UpdateObjectiveActionButtonPosition, {questBlock, questBlock.savedHeight, "QUEST"})
            else
                GW.CombatQueue_Queue("update_tracker_quest_itembutton_remove" .. i, questBlock.UpdateObjectiveActionButton, {questBlock})
            end
        end

        if i <= 20 then
            if bonusObjectiveBlock then
                if fBonus.numEvents <= i then
                    GW.CombatQueue_Queue("update_tracker_bonus_itembutton_position" .. i, bonusObjectiveBlock.UpdateObjectiveActionButtonPosition, {bonusObjectiveBlock, bonusObjectiveBlock.savedHeight, "EVENT"})
                else
                    GW.CombatQueue_Queue("update_tracker_bonus_itembutton_remove" .. i, bonusObjectiveBlock.UpdateObjectiveActionButton, {bonusObjectiveBlock})
                end
            end
        end
    end

    if GwScenarioBlock.hasItem then
        GW.CombatQueue_Queue("update_tracker_scenario_itembutton_position", GwScenarioBlock.UpdateObjectiveActionButtonPosition, {GwScenarioBlock, GwScenarioBlock.height, "SCENARIO"})
    end
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

local function CollapseHeader(self, forceCollapse, forceOpen)
    if (not self.collapsed or forceCollapse) and not forceOpen then
        self.collapsed = true
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        self.collapsed = false
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    fQuest:UpdateLayout()
    fCampaign:UpdateLayout()
    QuestTrackerLayoutChanged()
end
GW.CollapseQuestHeader = CollapseHeader

local function LoadQuestTracker()
    -- disable the default tracker
    ObjectiveTrackerFrame:SetMovable(1)
    ObjectiveTrackerFrame:SetUserPlaced(true)
    ObjectiveTrackerFrame:Hide()
    ObjectiveTrackerFrame:SetScript(
        "OnShow",
        function()
            ObjectiveTrackerFrame:Hide()
        end
    )

    --ObjectiveTrackerFrame:UnregisterAllEvents()
    ObjectiveTrackerFrame:SetScript("OnUpdate", nil)
    ObjectiveTrackerFrame:SetScript("OnSizeChanged", nil)
    --ObjectiveTrackerFrame:SetScript("OnEvent", nil)

    -- create our tracker
    fTracker = CreateFrame("Frame", "GwQuestTracker", UIParent, "GwQuestTracker")

    fTraScr = CreateFrame("ScrollFrame", "GwQuestTrackerScroll", fTracker, "GwQuestTrackerScroll")
    fTraScr:SetHeight(GW.settings.QuestTracker_pos_height)
    fTraScr:SetScript(
        "OnMouseWheel",
        function(self, delta)
            delta = -delta * 15
            local s = math.max(0, self:GetVerticalScroll() + delta)
            if self.maxScroll ~= nil then
                s = math.min(self.maxScroll, s)
            end
            self:SetVerticalScroll(s)
        end
    )
    fTraScr.maxScroll = 0

    local fScroll = CreateFrame("Frame", "GwQuestTrackerScrollChild", fTraScr, fTracker)

    fNotify = CreateFrame("Frame", "GwObjectivesNotification", fTracker, "GwObjectivesNotification")
    fNotify.animatingState = false
    fNotify.animating = false
    fNotify.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    fNotify.title:SetShadowOffset(1, -1)
    fNotify.desc:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    fNotify.desc:SetShadowOffset(1, -1)
    fNotify.bonusbar.bar:SetOrientation("VERTICAL")
    fNotify.bonusbar.bar:SetMinMaxValues(0, 1)
    fNotify.bonusbar.bar:SetValue(0.5)
    fNotify.bonusbar:SetScript("OnEnter", bonus_OnEnter)
    fNotify.bonusbar:SetScript("OnLeave", GameTooltip_Hide)
    fNotify.compass:SetScript("OnShow", fNotify.compass.NewQuestAnimation)
    fNotify.compass:SetScript("OnMouseDown", function() C_SuperTrack.SetSuperTrackedQuestID(0) end) -- to rest the SuperTracked quest

    fBoss = CreateFrame("Frame", "GwQuesttrackerContainerBossFrames", fTracker, "GwQuesttrackerContainer")
    fArenaBG = CreateFrame("Frame", "GwQuesttrackerContainerArenaBGFrames", fTracker, "GwQuesttrackerContainer")
    fScen = CreateFrame("Frame", "GwQuesttrackerContainerScenario", fTracker, "GwQuesttrackerContainer")
    fAchv = CreateFrame("Frame", "GwQuesttrackerContainerAchievement", fTracker, "GwQuesttrackerContainer")
    fCampaign = CreateFrame("Frame", "GwQuesttrackerContainerCampaign", fScroll, "GwQuesttrackerContainer")
    fQuest = CreateFrame("Frame", "GwQuesttrackerContainerQuests", fScroll, "GwQuesttrackerContainer")
    fBonus = CreateFrame("Frame", "GwQuesttrackerContainerBonusObjectives", fScroll, "GwQuesttrackerContainer")
    fRecipe = CreateFrame("Frame", "GwQuesttrackerContainerRecipe", fScroll, "GwQuesttrackerContainer")
    fMonthlyActivity = CreateFrame("Frame", "GwQuesttrackerContainerMonthlyActivity", fScroll, "GwQuesttrackerContainer")
    fCollection = CreateFrame("Frame", "GwQuesttrackerContainerCollection", fScroll, "GwQuesttrackerContainer")

    fNotify:SetParent(fTracker)
    fBoss:SetParent(fTracker)
    fArenaBG:SetParent(fTracker)
    fScen:SetParent(fTracker)
    fAchv:SetParent(fScroll)
    fCampaign:SetParent(fScroll)
    fQuest:SetParent(fScroll)
    fBonus:SetParent(fScroll)
    fRecipe:SetParent(fScroll)
    fMonthlyActivity:SetParent(fScroll)
    fCollection:SetParent(fScroll)

    fNotify:SetPoint("TOPRIGHT", fTracker, "TOPRIGHT")
    fBoss:SetPoint("TOPRIGHT", fNotify, "BOTTOMRIGHT")
    fArenaBG:SetPoint("TOPRIGHT", fBoss, "BOTTOMRIGHT")
    fScen:SetPoint("TOPRIGHT", fArenaBG, "BOTTOMRIGHT")

    fTraScr:SetPoint("TOPRIGHT", fScen, "BOTTOMRIGHT")
    fTraScr:SetPoint("BOTTOMRIGHT", fTracker, "BOTTOMRIGHT")

    fScroll:SetPoint("TOPRIGHT", fTraScr, "TOPRIGHT")
    fAchv:SetPoint("TOPRIGHT", fScroll, "TOPRIGHT")
    fCampaign:SetPoint("TOPRIGHT", fAchv, "BOTTOMRIGHT")
    fQuest:SetPoint("TOPRIGHT", fCampaign, "BOTTOMRIGHT")
    fBonus:SetPoint("TOPRIGHT", fQuest, "BOTTOMRIGHT")
    fRecipe:SetPoint("TOPRIGHT", fBonus, "BOTTOMRIGHT")
    fMonthlyActivity:SetPoint("TOPRIGHT", fRecipe, "BOTTOMRIGHT")
    fCollection:SetPoint("TOPRIGHT", fMonthlyActivity, "BOTTOMRIGHT")

    fScroll:SetSize(fTracker:GetWidth(), 2)
    fTraScr:SetScrollChild(fScroll)

    --Mixin
    Mixin(fQuest, GwQuestLogMixin)
    Mixin(fCampaign, GwQuestLogMixin)
    fQuest.blockMixInTemplate = GwQuestLogBlockMixin
    fCampaign.blockMixInTemplate = GwQuestLogBlockMixin

    fQuest:SetScript("OnEvent", QuestTrackerOnEvent)
    fQuest:RegisterEvent("QUEST_LOG_UPDATE")
    fQuest:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    fQuest:RegisterEvent("QUEST_AUTOCOMPLETE")
    fQuest:RegisterEvent("QUEST_ACCEPTED")
    fQuest:RegisterEvent("PLAYER_MONEY")
    fQuest:RegisterEvent("PLAYER_ENTERING_WORLD")
    fQuest.watchMoneyReasons = 0
    fQuest.isCampaignContainer = false

    fCampaign:SetScript("OnEvent", QuestTrackerOnEvent)
    fCampaign:RegisterEvent("QUEST_LOG_UPDATE")
    fCampaign:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    fCampaign:RegisterEvent("QUEST_AUTOCOMPLETE")
    fCampaign:RegisterEvent("QUEST_ACCEPTED")
    fCampaign:RegisterEvent("PLAYER_MONEY")
    fCampaign:RegisterEvent("PLAYER_ENTERING_WORLD")
    fCampaign.watchMoneyReasons = 0
    fCampaign.isCampaignContainer = true

    fCampaign.header = CreateFrame("Button", nil, fCampaign, "GwQuestTrackerHeader")
    fCampaign.header.icon:SetTexCoord(0.5, 1, 0, 0.25)
    fCampaign.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    fCampaign.header.title:SetShadowOffset(1, -1)
    fCampaign.header.title:SetText(TRACKER_HEADER_CAMPAIGN_QUESTS)

    fCampaign.collapsed = false
    fCampaign.header:SetScript("OnMouseDown",
        function(self)
            CollapseHeader(self:GetParent(), false, false)
        end
    )
    fCampaign.header.title:SetTextColor(TRACKER_TYPE_COLOR.CAMPAIGN.r, TRACKER_TYPE_COLOR.CAMPAIGN.g, TRACKER_TYPE_COLOR.CAMPAIGN.b)

    fQuest.header = CreateFrame("Button", nil, fQuest, "GwQuestTrackerHeader")
    fQuest.header.icon:SetTexCoord(0, 0.5, 0.25, 0.5)
    fQuest.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    fQuest.header.title:SetShadowOffset(1, -1)
    fQuest.header.title:SetText(TRACKER_HEADER_QUESTS)

    fQuest.collapsed = false
    fQuest.header:SetScript("OnMouseDown",
        function(self)
            CollapseHeader(self:GetParent(), false, false)
        end
    )
    fQuest.header.title:SetTextColor(TRACKER_TYPE_COLOR.QUEST.r, TRACKER_TYPE_COLOR.QUEST.g, TRACKER_TYPE_COLOR.QUEST.b)

    fQuest.init = false

    GW.LoadBossFrame()
    if not C_AddOns.IsAddOnLoaded("sArena") then
        GW.LoadArenaFrame(fArenaBG)
    end
    GW.LoadScenarioFrame(fScen)
    GW.LoadAchievementFrame(fAchv)
    GW.LoadBonusFrame(fBonus)
    GW.LoadRecipeTracking(fRecipe)
    GW.LoadMonthlyActivitiesTracking(fMonthlyActivity)
    GW.LoadCollectionTracking(fCollection)
    GW.LoadWQTAddonSkin()
    GW.LoadPetTrackerAddonSkin()
    GW.LoadTodolooAddonSkin()

    GW.ToggleCollapseObjectivesInChallangeMode()

    fNotify.shouldDisplay = false
    -- only update the tracker on Events or if player moves
    local compassUpdateFrame = CreateFrame("Frame")
    compassUpdateFrame:RegisterEvent("PLAYER_STARTED_MOVING")
    compassUpdateFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
    compassUpdateFrame:RegisterEvent("PLAYER_CONTROL_LOST")
    compassUpdateFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
    compassUpdateFrame:RegisterEvent("QUEST_LOG_UPDATE")
    compassUpdateFrame:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    compassUpdateFrame:RegisterEvent("PLAYER_MONEY")
    compassUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    compassUpdateFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    compassUpdateFrame:RegisterEvent("QUEST_DATA_LOAD_RESULT")
    compassUpdateFrame:RegisterEvent("SUPER_TRACKING_CHANGED")
    compassUpdateFrame:RegisterEvent("SCENARIO_UPDATE")
    compassUpdateFrame:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    compassUpdateFrame:SetScript("OnEvent", function(self, event, ...)
        -- Events for start updating
        if IsIn(event, "PLAYER_STARTED_MOVING", "PLAYER_CONTROL_LOST") then
            if self.Ticker then
                self.Ticker:Cancel()
                self.Ticker = nil
            end
            self.Ticker = C_Timer.NewTicker(1, function() tracker_OnUpdate() end)
        elseif IsIn(event, "PLAYER_STOPPED_MOVING", "PLAYER_CONTROL_GAINED") then -- Events for stop updating
            if self.Ticker then
                self.Ticker:Cancel()
                self.Ticker = nil
            end
        elseif event == "QUEST_DATA_LOAD_RESULT" then
            local questID, success = ...
            if success and fNotify.compass.dataIndex and questID == fNotify.compass.dataIndex then
                tracker_OnUpdate()
            end
        else
            C_Timer.After(0.25, function() tracker_OnUpdate() end)
        end
    end)

    -- some hooks to set the itembuttons correct
    local UpdateItemButtonPositionAndAdjustScrollFrame = function()
        GW.Debug("Update Quest Buttons")
        QuestTrackerLayoutChanged()
        AdjustItemButtonPositions()
    end

    fBoss.oldHeight = 1
    fArenaBG.oldHeight = 1
    fScen.oldHeight = 1
    fAchv.oldHeight = 1
    fQuest.oldHeight = 1
    fCampaign.oldHeight = 1

    hooksecurefunc(fBoss, "SetHeight", function(_, height)
        if fBoss.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)
    hooksecurefunc(fArenaBG, "SetHeight", function(_, height)
        if fArenaBG.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)
    hooksecurefunc(fAchv, "SetHeight", function(_, height)
        if fAchv.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)
    hooksecurefunc(fScen, "SetHeight", function(_, height)
        if fScen.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)

    hooksecurefunc(fQuest, "SetHeight", function(_, height)
        if fQuest.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)
    hooksecurefunc(fCampaign, "SetHeight", function(_, height)
        if fCampaign.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)

    fNotify:HookScript("OnShow", function() C_Timer.After(0.25, function() UpdateItemButtonPositionAndAdjustScrollFrame() end) end)
    fNotify:HookScript("OnHide", function() C_Timer.After(0.25, function() UpdateItemButtonPositionAndAdjustScrollFrame() end) end)

    GW.RegisterMovableFrame(fTracker, OBJECTIVES_TRACKER_LABEL, "QuestTracker_pos", ALL, nil, {"scaleable", "height"})
    fTracker:ClearAllPoints()
    fTracker:SetPoint("TOPLEFT", fTracker.gwMover)
    fTracker:SetHeight(GW.settings.QuestTracker_pos_height)

    QuestTrackerOnEvent(fQuest, "LOAD")
    QuestTrackerOnEvent(fCampaign, "LOAD")
end
GW.LoadQuestTracker = LoadQuestTracker
