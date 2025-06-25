local _, GW = ...

GwObjectivesBlockTemplateMixin = {}

function GwObjectivesBlockTemplateMixin:UpdateBlockObjectives()
    -- override per module
end

function GwObjectivesBlockTemplateMixin:UpdateBlock()
    -- override per module
end

function GwObjectivesBlockTemplateMixin:UpdateFindGroupButton(id, isScenario)
    local hasButton
    if not isScenario then
        hasButton = QuestUtil.CanCreateQuestGroup(id)
    else
        hasButton = C_LFGList.CanCreateScenarioGroup(id)
    end
    if hasButton then
		self.groupButton:SetUp(id, isScenario)
		self.groupButton:Show()
    else
        self.groupButton:Hide()
	end
end

function GwObjectivesBlockTemplateMixin:OnEnter()
    if not self.hover then
        self.oldColor = {}
        self.oldColor.r, self.oldColor.g, self.oldColor.b = self:GetParent().Header:GetTextColor()
        self:GetParent().Header:SetTextColor(self.oldColor.r * 2, self.oldColor.g * 2, self.oldColor.b * 2)

        self = self:GetParent()
    end

    self.hover:Show()

    for _, v in pairs(self.objectiveBlocks) do
        if not v.StatusBar.notHide then
            v.StatusBar.progress:Show()
        end
    end

    if not self.isSuperTracked then
        GW.AddToAnimation(
            (self.animationName or self:GetDebugName()) .. "hover",
            0,
            1,
            GetTime(),
            0.2,
            function(step)
                self.hover:SetAlpha(math.max((step - 0.3), 0))
                self.hover:SetTexCoord(0, step, 0, 1)
            end
        )
    end
    if self.event then
        self:TryShowRewardsTooltip()
    elseif GW.Retail and IsInGroup() and self.questID then
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0)
        GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
        GameTooltip:SetQuestPartyProgress(self.questID)
        EventRegistry:TriggerEvent("OnQuestBlockHeader.OnEnter", self, self.questID, true)
    end
end

function GwObjectivesBlockTemplateMixin:OnLeave()
    if not self.hover then
        if self.oldColor ~= nil then
            self:GetParent().Header:SetTextColor(self.oldColor.r, self.oldColor.g, self.oldColor.b)
        end

        self = self:GetParent()
    end
    if not self.isSuperTracked then
        self.hover:Hide()
    end

    for _, v in pairs(self.objectiveBlocks) do
        if not v.StatusBar.notHide then
            v.StatusBar.progress:Hide()
        end
    end

    GW.StopAnimation((self.animationName or self:GetDebugName()) .. "hover")
    GameTooltip_Hide()
end

function GwObjectivesBlockTemplateMixin:OnLoad()
    self.Header:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    self.SubHeader:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)

    self.turnin:SetScript("OnShow", self.turnin.WiggleAnimation)
    self.turnin:SetScript("OnHide", function(btn) GW.StopAnimation(btn:GetDebugName()) end)
    self.turnin:SetScript("OnClick",function(btn)
        ShowQuestComplete(self.questID)
        RemoveAutoQuestPopUp(self.questID)
        btn:Hide()
    end)
    self.popupQuestAccept:SetScript("OnShow", self.popupQuestAccept.WiggleAnimation)
    self.popupQuestAccept:SetScript("OnHide", function(btn) GW.StopAnimation(btn:GetDebugName()) end)
    self.popupQuestAccept:SetScript("OnClick", function(btn)
            ShowQuestOffer(self.questID)
            RemoveAutoQuestPopUp(self.questID)
            btn:Hide()
        end)
    self.groupButton:SetScript("OnClick", self.groupButton.OnClick)
    self.groupButton:SetScript("OnEnter", self.groupButton.OnEnter)
    self.groupButton:SetScript("OnLeave", self.groupButton.OnLeave)

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

function GwObjectivesBlockTemplateMixin:GetObjectiveBlock(index, firstObjectivesYValue)
    local objective = self.objectiveBlocks and self.objectiveBlocks[index]
    if objective then
        objective:SetScript("OnUpdate", nil)
        objective:SetScript("OnEnter", nil)
        objective:SetScript("OnLeave", nil)
        objective.isMythicKeystone = false
        return objective
    end

    local count = #self.objectiveBlocks + 1

    local newObjective = CreateFrame("Frame", nil, self, "GwQuesttrackerObjectiveTemplate")
    newObjective:SetParent(self)
    tinsert(self.objectiveBlocks, newObjective)

    if count == 1 then
        newObjective:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, (firstObjectivesYValue or -25))
    else
        newObjective:SetPoint("TOPRIGHT", self.objectiveBlocks[count - 1], "BOTTOMRIGHT", 0, 0)
    end

    newObjective.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)
    newObjective.TimerBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    newObjective.notChangeSize = true
    newObjective.hasObjectToHide = false
    newObjective.objectToHide = nil
    newObjective.resetParent = false
    newObjective.isMythicKeystone = false

    return newObjective
end

function GwObjectivesBlockTemplateMixin:AddObjective(text, objectiveIndex, options)
    if not text then return end
    self.numObjectives = self.numObjectives + 1
    local objectiveBlock = self:GetObjectiveBlock(objectiveIndex, options.firstObjectivesYValue)
    local precentageComplete = 0

    objectiveBlock:Show()
    local formattedText = text
    if options.isReceip then
        if options.qty and options.qty < options.totalqty then
            formattedText = GW.GetLocalizedNumber(options.qty) .. "/" .. GW.GetLocalizedNumber(options.totalqty) .. " " .. text
        end
    elseif options.isAchievement then
        formattedText = GW.FormatObjectiveNumbers(text)
    end
    objectiveBlock.ObjectiveText:SetText(formattedText)
    objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)

    if objectiveBlock.hasObjectToHide then
        if objectiveBlock.resetParent then objectiveBlock.objectToHide.SetParent = nil end
        objectiveBlock.objectToHide:SetParent(GW.HiddenFrame)
        if objectiveBlock.resetParent then objectiveBlock.objectToHide.SetParent = GW.NoOp end
    end

    objectiveBlock.isMythicKeystone = options.isMythicKeystone

    if options.isAchievement then
        if options.eligible then
            objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
        else
            objectiveBlock.ObjectiveText:SetTextColor(DIM_RED_FONT_COLOR.r, DIM_RED_FONT_COLOR.g, DIM_RED_FONT_COLOR.b)
        end
    else
        if options.finished then
            objectiveBlock.ObjectiveText:SetTextColor(0.8, 0.8, 0.8)
        else
            objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
        end
    end

    if options.objectiveType == "progressbar" then
        objectiveBlock.StatusBar:SetMinMaxValues(0, 100)
        objectiveBlock.StatusBar:SetValue(options.qty or (self.questID and GetQuestProgressBarPercent(self.questID)) or 0)
        objectiveBlock.StatusBar:SetShown(options.isMythicKeystone or options.overrideShowStatusbarSetting or GW.settings.QUESTTRACKER_STATUSBARS_ENABLED)
        objectiveBlock.progress = (options.qty or (self.questID and GetQuestProgressBarPercent(self.questID))) / 100
        objectiveBlock.StatusBar.precentage = true
        precentageComplete = objectiveBlock.progress
    elseif GW.ParseObjectiveString(objectiveBlock, text, options.qty, options.totalqty, (options.overrideShowStatusbarSetting or options.isMythicKeystone)) then
        precentageComplete = objectiveBlock.progress
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

    if options.timerShown then
        objectiveBlock:AddTimer(options.duration, options.startTime)
    else
        objectiveBlock.TimerBar:Hide()
        objectiveBlock.TimerBar:SetScript("OnUpdate", nil)
    end

    self.height = self.height + objectiveBlock:GetHeight()

    return precentageComplete
end

function GwObjectivesBlockTemplateMixin:IsQuestAutoTurnInOrAutoAccept(blockQuestID, checkType, isComplete, isAutoComplete)
    for i = 1, GetNumAutoQuestPopUps() do
        local questID, popUpType = GetAutoQuestPopUp(i)
        if blockQuestID and questID and popUpType and popUpType == checkType and blockQuestID == questID then
            return true
        end
    end

    --fallback for cata
    if GW.Cata and checkType == "COMPLETE" and isComplete and isAutoComplete then
        return true
    end

    return false
end

function GwObjectivesBlockTemplateMixin:UpdateObjectiveActionButton()
    local btn = self.actionButton
    self.hasItem = false

    if not GW.Classic then
        if self.questLogIndex then
            local link, item, charges, showWhenComplete = GetQuestLogSpecialItemInfo(self.questLogIndex)

            local isComplete = GW.Retail and (self.questID and QuestCache:Get(self.questID):IsComplete()) or GW.Cata and (self.isComplete) or false
            if item and (not isComplete or showWhenComplete) then
                self.hasItem = true
                if GW.Retail then
                    btn:SetUp(self.questLogIndex)
                else
                    btn.questLogIndex = self.questLogIndex
                    btn.charges = charges
                    btn.rangeTimer = -1
                    SetItemButtonTexture(btn, item)
                    SetItemButtonCount(btn, charges)
                    btn:UpdateCooldown()
                end
                btn:SetAttribute("type", "item")
                btn:SetAttribute("item", link)
                btn:SetScript("OnUpdate", btn.OnUpdate)
                btn:Show()
                return
            end
        end
        btn:Hide()
        btn:SetScript("OnUpdate", nil)
    elseif GW.Classic then
        if self.sourceItemId and not self.isComplete and btn:SetItem(self) then
            btn:SetScript("OnUpdate", btn.OnUpdate)
            btn:Show()
            self.hasItem = true
        else
            btn:FakeHide()
            btn.itemID, btn.questID, btn.itemName = nil, nil, nil
            btn:Hide()
            btn:SetScript("OnUpdate", nil)
        end
    end
end

function GwObjectivesBlockTemplateMixin:UpdateObjectiveActionButtonPosition(type)
    if not self.actionButton or not self.hasItem then
        return
    end

    local height = self.fromContainerTopHeight
    if GW.Retail then
        height = height + GW.ObjectiveTrackerContainer.Scenario:GetHeight()
    end
    if not GW.Classic then
        height = height +GW.ObjectiveTrackerContainer.Achievement:GetHeight() + GW.ObjectiveTrackerContainer.BossFrames:GetHeight() + GW.ObjectiveTrackerContainer.ArenaFrames:GetHeight()
    end

    if GW.ObjectiveTrackerContainer.Notification:IsShown() then
        height = height + GW.ObjectiveTrackerContainer.Notification.desc:GetHeight()
    else
        height = height - 40
    end
    if type == "SCENARIO" then
        height = height - (GW.ObjectiveTrackerContainer.Achievement:GetHeight() + GW.ObjectiveTrackerContainer.BossFrames:GetHeight() + GW.ObjectiveTrackerContainer.ArenaFrames:GetHeight())
    end
    if type == "EVENT" then
        height = height + GW.ObjectiveTrackerContainer.Quests:GetHeight() + GW.ObjectiveTrackerContainer.Campaign:GetHeight()
    end
    if GW.Retail and type == "QUEST" then
        height = height + GW.ObjectiveTrackerContainer.Campaign:GetHeight()
    end

    self.actionButton:SetPoint("TOPLEFT", GwQuestTracker, "TOPRIGHT", -330, -height)
end
