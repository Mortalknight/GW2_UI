local _, GW = ...

GwObjectivesBlockTemplateMixin = {}

local function wiggleAnim(self)
    if self.animation == nil then
        self.animation = 0
    end
    if self.doingAnimation == true then
        return
    end
    self.doingAnimation = true
    GW.AddToAnimation(
        self:GetName(),
        0,
        1,
        GetTime(),
        2,
        function(prog)
            self.flare:SetRotation(GW.lerp(0, 1, prog))

            if prog < 0.25 then
                self.texture:SetRotation(GW.lerp(0, -0.5, math.sin((prog / 0.25) * math.pi * 0.5)))
                self.flare:SetAlpha(GW.lerp(0, 1, math.sin((prog / 0.25) * math.pi * 0.5)))
            end
            if prog > 0.25 and prog < 0.75 then
                self.texture:SetRotation(GW.lerp(-0.5, 0.5, math.sin(((prog - 0.25) / 0.5) * math.pi * 0.5)))
            end
            if prog > 0.75 then
                self.texture:SetRotation(GW.lerp(0.5, 0, math.sin(((prog - 0.75) / 0.25) * math.pi * 0.5)))
            end

            if prog > 0.25 then
                self.flare:SetAlpha(GW.lerp(1, 0, ((prog - 0.25) / 0.75)))
            end
        end,
        nil,
        function()
            self.doingAnimation = false
        end
    )
end

local function ParseObjectiveString(block, text, objectiveType, quantity, numItems, numNeeded, overrideShowStatusbarSetting)
    if objectiveType == "progressbar" then
        block.StatusBar:SetMinMaxValues(0, 100)
        block.StatusBar:SetValue(quantity or 0)
        block.StatusBar:SetShown(overrideShowStatusbarSetting or GW.settings.QUESTTRACKER_STATUSBARS_ENABLED)
        block.StatusBar.precentage = true
        return true
    end
    block.StatusBar.precentage = false

    local numItems, numNeeded = numItems, numNeeded
    if not numItems and not numNeeded then
        _, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)")
        if numItems == nil then
            numItems, numNeeded, _ = string.match(text, "(%d+)/(%d+) (%S+)")
        end
    end
    numItems = tonumber(numItems)
    numNeeded = tonumber(numNeeded)

    if numItems and numNeeded and numNeeded > 1 and numItems < numNeeded then
        block.StatusBar:SetShown(overrideShowStatusbarSetting or GW.settings.QUESTTRACKER_STATUSBARS_ENABLED)
        block.StatusBar:SetMinMaxValues(0, numNeeded)
        block.StatusBar:SetValue(numItems)
        block.progress = numItems / numNeeded
        return true
    end
    return false
end
GW.ParseObjectiveString = ParseObjectiveString

function GwObjectivesBlockTemplateMixin:OnEnter()
    if not self.hover then
        self.oldColor = {}
        self.oldColor.r, self.oldColor.g, self.oldColor.b = self:GetParent().Header:GetTextColor()
        self:GetParent().Header:SetTextColor(self.oldColor.r * 2, self.oldColor.g * 2, self.oldColor.b * 2)

        self = self:GetParent()
    end

    self.hover:Show()
    if self.objectiveBlocks == nil then
        self.objectiveBlocks = {}
    end
    for _, v in pairs(self.objectiveBlocks) do
        if not v.StatusBar.notHide then
            v.StatusBar.progress:Show()
        end
    end
    GW.AddToAnimation(
        (self.animationName or self:GetName()) .. "hover",
        0,
        1,
        GetTime(),
        0.2,
        function(step)
            self.hover:SetAlpha(math.max((step - 0.3), 0))
            self.hover:SetTexCoord(0, step, 0, 1)
        end
    )
    if self.event then
        self:TryShowRewardsTooltip()
    else
        if IsInGroup() and self.id then
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0)
            GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
            GameTooltip:SetQuestPartyProgress(self.id)
            EventRegistry:TriggerEvent("OnQuestBlockHeader.OnEnter", self, self.id, true)
        end
    end
end

function GwObjectivesBlockTemplateMixin:OnLeave()
    if not self.hover then
        if self.oldColor ~= nil then
            self:GetParent().Header:SetTextColor(self.oldColor.r, self.oldColor.g, self.oldColor.b)
        end

        self = self:GetParent()
    end

    self.hover:Hide()
    if self.objectiveBlocks == nil then
        self.objectiveBlocks = {}
    end
    for _, v in pairs(self.objectiveBlocks) do
        if not v.StatusBar.notHide then
            v.StatusBar.progress:Hide()
        end
    end
    if GW.animations[(self.animationName or self:GetName()) .. "hover"] then
        GW.animations[(self.animationName or self:GetName()) .. "hover"].complete = true
    end
    GameTooltip_Hide()
end

function GwObjectivesBlockTemplateMixin:OnLoad()
    self.Header:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    self.SubHeader:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)

    self.turnin:SetScript("OnShow", function(self) self:SetScript("OnUpdate", wiggleAnim) end)
    self.turnin:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)
    self.turnin:SetScript("OnClick",function(self)
        ShowQuestComplete(self:GetParent().id)
        RemoveAutoQuestPopUp(self:GetParent().id)
        self:Hide()
    end)
    self.popupQuestAccept:SetScript(
        "OnShow",
        function(self)
            self:SetScript("OnUpdate", wiggleAnim)
        end
    )
    self.popupQuestAccept:SetScript(
        "OnHide",
        function(self)
            self:SetScript("OnUpdate", nil)
        end
    )
    self.popupQuestAccept:SetScript("OnClick", function(self)
        ShowQuestOffer(self:GetParent().id)
        RemoveAutoQuestPopUp(self:GetParent().id)
        self:Hide()
    end)
    self.groupButton:SetScript("OnClick", function(self)
        if self:GetParent().hasGroupFinderButton then
            LFGListUtil_FindQuestGroup(self:GetParent().id, true)
        end
    end)
    self.groupButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self)
	    GameTooltip:AddLine(TOOLTIP_TRACKER_FIND_GROUP_BUTTON, HIGHLIGHT_FONT_COLOR:GetRGB())
	    GameTooltip:Show()
    end)
    self.groupButton:SetScript("OnLeave", GameTooltip_Hide)

    self.turnin:SetScale(GwQuestTracker:GetScale() * 0.9)
    self.popupQuestAccept:SetScale(GwQuestTracker:GetScale() * 0.9)
    self.groupButton:SetScale(GwQuestTracker:GetScale() * 0.9)

    -- hooks for scaling
    hooksecurefunc(GwQuestTracker, "SetScale", function(_, scale)
        self.turnin:SetScale(scale * 0.9)
        self.popupQuestAccept:SetScale(scale * 0.9)
        self.groupButton:SetScale(scale * 0.9)
    end)
end

function GwObjectivesBlockTemplateMixin:SetBlockColorByKey(string)
    self.color = GW.TRACKER_TYPE_COLOR[string]
end

function GwObjectivesBlockTemplateMixin:GetObjectiveBlock(index)
    if _G[self:GetName() .. "Objective" .. index] then
        _G[self:GetName() .. "Objective" .. index]:SetScript("OnUpdate", nil)
        return _G[self:GetName() .. "Objective" .. index]
    end

    if self.objectiveBlocksNum == nil then
        self.objectiveBlocksNum = 0
    end
    self.objectiveBlocks = self.objectiveBlocks or {}
    self.objectiveBlocksNum = self.objectiveBlocksNum + 1

    local newBlock = CreateFrame("Frame", self:GetName() .. "Objective" .. self.objectiveBlocksNum, self, "GwQuesttrackerObjectiveTemplate")
    newBlock:SetParent(self)
    tinsert(self.objectiveBlocks, newBlock)
    if self.objectiveBlocksNum == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint("TOPRIGHT", _G[self:GetName() .. "Objective" .. (self.objectiveBlocksNum - 1)], "BOTTOMRIGHT", 0, 0)
    end

    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    return newBlock
end

function GwObjectivesBlockTemplateMixin:AddObjective(text, finished, objectiveIndex, objectiveType)
    local objectiveBlock = self:GetObjectiveBlock(objectiveIndex)
    objectiveBlock:Show()
    objectiveBlock.ObjectiveText:SetText(text)
    objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
    if finished then
        objectiveBlock.ObjectiveText:SetTextColor(0.8, 0.8, 0.8)
    else
        objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
    end

    if objectiveType == "progressbar" or ParseObjectiveString(objectiveBlock, text) then
        if objectiveType == "progressbar" then
            objectiveBlock.StatusBar:SetShown(GW.settings.QUESTTRACKER_STATUSBARS_ENABLED)
            objectiveBlock.StatusBar:SetMinMaxValues(0, 100)
            objectiveBlock.StatusBar:SetValue(GetQuestProgressBarPercent(self.questID))
            objectiveBlock.progress = GetQuestProgressBarPercent(self.questID) / 100
            objectiveBlock.StatusBar.precentage = true
        end
    else
        objectiveBlock.StatusBar:Hide()
    end
    local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
    objectiveBlock:SetHeight(h)
    if objectiveBlock.StatusBar:IsShown() then
        if self.numObjectives >= 1 then
            h = h + objectiveBlock.StatusBar:GetHeight() + 10
        else
            h = h + objectiveBlock.StatusBar:GetHeight() + 5
        end
        objectiveBlock:SetHeight(h)
    end
    self.height = self.height + objectiveBlock:GetHeight()
    self.numObjectives = self.numObjectives + 1
end

function GwObjectivesBlockTemplateMixin:IsQuestAutoTurnInOrAutoAccept(blockQuestID, checkType)
    for i = 1, GetNumAutoQuestPopUps() do
        local questID, popUpType = GetAutoQuestPopUp(i)
        if blockQuestID and questID and popUpType and popUpType == checkType and blockQuestID == questID then
            return true
        end
    end

    return false
end

function GwObjectivesBlockTemplateMixin:UpdateQuestObjective(numObjectives)
    local addedObjectives = 1
    for objectiveIndex = 1, numObjectives do
        --local text, _, finished = GetQuestLogLeaderBoard(objectiveIndex, block.questLogIndex)
        local text, objectiveType, finished = GetQuestObjectiveInfo(self.questID, objectiveIndex, false)
        if not finished or not text then
            self:AddObjective(text, finished, addedObjectives, objectiveType)
            addedObjectives = addedObjectives + 1
        end
    end
end

function GwObjectivesBlockTemplateMixin:UpdateQuestItem()
    local link, item, _, showItemWhenComplete = nil, nil, nil, false

    if self.questLogIndex then
        link, item, _, showItemWhenComplete = GetQuestLogSpecialItemInfo(self.questLogIndex)
    end

    local isQuestComplete = (self and self.questID) and QuestCache:Get(self.questID):IsComplete() or false
    local shouldShowItem = item and (not isQuestComplete or showItemWhenComplete)
    if shouldShowItem and self.questLogIndex then
        self.hasItem = true
        self.actionButton:SetUp(self.questLogIndex)

        self.actionButton:SetAttribute("type", "item")
        self.actionButton:SetAttribute("item", link)

        self.actionButton:SetScript("OnUpdate", self.actionButton.OnUpdate)
        self.actionButton:Show()
    else
        self.hasItem = false
        self.actionButton:Hide()
        self.actionButton:SetScript("OnUpdate", nil)
    end
end

function GwObjectivesBlockTemplateMixin:UpdateQuestItemPositions(button, height, type)
    if not button or not self.hasItem then
        return
    end

    local height = height + GwQuesttrackerContainerScenario:GetHeight() + GwQuesttrackerContainerAchievement:GetHeight() + GwQuesttrackerContainerBossFrames:GetHeight() + GwQuesttrackerContainerArenaBGFrames:GetHeight()
    if GwObjectivesNotification:IsShown() then
        height = height + GwObjectivesNotification.desc:GetHeight()
    else
        height = height - 40
    end
    if type == "SCENARIO" then
        height = height - (GwQuesttrackerContainerAchievement:GetHeight() + GwQuesttrackerContainerBossFrames:GetHeight() + GwQuesttrackerContainerArenaBGFrames:GetHeight())
    end
    if type == "EVENT" then
        height = height + GwQuesttrackerContainerQuests:GetHeight()
    end
    if type == "QUEST" or type == "EVENT" then
        height = height + GwQuesttrackerContainerCampaign:GetHeight()
    end

    button:SetPoint("TOPLEFT", GwQuestTracker, "TOPRIGHT", -330, -height)
end

function GwObjectivesBlockTemplateMixin:OnClick(button)
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

function GwObjectivesBlockTemplateMixin:UpdateQuest(parent, quest)
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
        GW.CombatQueue_Queue(nil, self.UpdateQuestItem, {self})

        if numObjectives == 0 and GetMoney() >= requiredMoney and not quest.startEvent then
            isComplete = true
        end

        self:UpdateQuestObjective(numObjectives)

        if requiredMoney ~= nil and requiredMoney > GetMoney() and not isComplete then
            self:AddObjective(GetMoneyString(GetMoney()) .. " / " .. GetMoneyString(requiredMoney), isComplete, self.numObjectives + 1, nil)
        end

        if isComplete then
            if quest.isAutoComplete then
                self:AddObjective(QUEST_WATCH_CLICK_TO_COMPLETE, false, self.numObjectives + 1, nil)
            else
                local completionText = GetQuestLogCompletionText(questLogIndex)

                if (completionText) then
                    self:AddObjective(completionText, false, self.numObjectives + 1, nil)
                else
                    self:AddObjective(QUEST_WATCH_QUEST_READY, false, self.numObjectives + 1, nil)
                end
            end
        elseif questFailed then
            self:AddObjective(FAILED, false, self.numObjectives + 1, nil)
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

function GwObjectivesBlockTemplateMixin:UpdateQuestByID(parent, quest, questID, questLogIndex)
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
    GW.CombatQueue_Queue(nil, self.UpdateQuestItem, {self})

    if numObjectives == 0 and GetMoney() >= requiredMoney and not quest.startEvent then
        isComplete = true
    end

    self:UpdateQuestObjective(numObjectives)

    if requiredMoney ~= nil and requiredMoney > GetMoney() and not isComplete then
        self:AddObjective(GetMoneyString(GetMoney()) .. " / " .. GetMoneyString(requiredMoney), isComplete, self.numObjectives + 1, nil)
    end

    if isComplete then
        if quest.isAutoComplete then
            self:AddObjective(QUEST_WATCH_CLICK_TO_COMPLETE, false, self.numObjectives + 1, nil)
        else
            local completionText = GetQuestLogCompletionText(questLogIndex)

            if (completionText) then
                self:AddObjective(completionText, false, self.numObjectives + 1, nil)
            else
                self:AddObjective(QUEST_WATCH_QUEST_READY, false, self.numObjectives + 1, nil)
            end
        end
    elseif questFailed then
        self:AddObjective(FAILED, false, self.numObjectives + 1, nil)
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