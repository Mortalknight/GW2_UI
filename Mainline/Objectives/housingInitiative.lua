local _, GW = ...

local ChatEdit_GetActiveWindow = ChatFrameUtil and ChatFrameUtil.GetActiveWindow or ChatEdit_GetActiveWindow


GwObjectivesHousingInitiativeBlockMixin = {}

function GwObjectivesHousingInitiativeBlockMixin:UpdateBlock(requirements)
    self.height = 25
    self.numObjectives = 0

    for idx, requirement in ipairs(requirements) do
        if not requirement.completed then
            local criteriaString = requirement.requirementText
            criteriaString = string.gsub(criteriaString, " / ", "/")
            criteriaString = string.gsub(criteriaString, "- ", "")
            self:AddObjective(criteriaString, idx, {isHousingInitiativ = true, finished = false})
        end
    end

    for i = (self.numObjectives or 0) + 1, #self.objectiveBlocks do
        self.objectiveBlocks[i]:Hide()
    end

    self:SetHeight(self.height)
end

GwObjectivesHousingInitiativeContainerMixin = {}

function GwObjectivesHousingInitiativeContainerMixin:UpdateLayout()
    local trackedTasks = C_NeighborhoodInitiative.GetTrackedInitiativeTasks().trackedIDs
    local savedHeight = 1
    local shownIndex = 1
    local showHeader = false

    self.header:Hide()

    if self.collapsed and #trackedTasks > 0 then
        self.header:Show()
        wipe(trackedTasks)
        savedHeight = 20
    end

    for i = 1, #trackedTasks do
        local taskID = trackedTasks[i]
        local taskInfo = C_NeighborhoodInitiative.GetInitiativeTaskInfo(taskID)

        if taskInfo and not taskInfo.completed then
            local taskName = taskInfo.taskName
			local requirements = taskInfo.requirementsList
            local block = self:GetBlock(shownIndex, GW.Enum.ObjectivesNotificationType.HousingInitiative, false)
            if block == nil then
                return
            end

            block.id = taskID
            block.title = taskName
            block.Header:SetText(taskName)
            -- criteria
            block:UpdateBlock(requirements)
            block:Show()

            savedHeight = savedHeight + block.height

            shownIndex = shownIndex + 1

            self.header:Show()
            showHeader = true
        end
    end

    if showHeader and not self.collapsed then
        savedHeight = savedHeight + 20
    end
    self:SetHeight(savedHeight)

    for i = shownIndex, #self.blocks do
        self.blocks[i]:Hide()
        self.blocks[i].id = nil
    end

    GwQuestTracker:LayoutChanged()
end

function GwObjectivesHousingInitiativeContainerMixin:OnEvent(event, ...)
    if event == "INITIATIVE_TASKS_TRACKED_UPDATED" or event == "INITIATIVE_TASKS_TRACKED_LIST_CHANGED" then
        self:UpdateLayout()
    elseif event == "INITIATIVE_TASK_COMPLETED" then
        local trackedTasks = C_NeighborhoodInitiative.GetTrackedInitiativeTasks().trackedIDs
        local completeTaskname = ...
        for i = 1, #trackedTasks do
            local taskID = trackedTasks[i]
            local taskInfo = C_NeighborhoodInitiative.GetInitiativeTaskInfo(taskID)
            if taskInfo and completeTaskname == taskInfo.taskName then
                PlaySound(SOUNDKIT.TRADING_POST_UI_COMPLETING_ACTIVITIES)
                self:UpdateLayout()
                break
            end
        end
    end
end

function GwObjectivesHousingInitiativeContainerMixin:BlockOnClick(button)
    if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local initiativeTaskLink = C_NeighborhoodInitiative.GetInitiativeTaskChatLink(self.id)
		ChatFrameUtil.InsertLink(initiativeTaskLink)
	elseif button ~= "RightButton" then
		if IsModifiedClick("QUESTWATCHTOGGLE") then
            C_NeighborhoodInitiative.RemoveTrackedInitiativeTask(self.id)
		else
            HousingFramesUtil.OpenFrameToTaskID(self.id)
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	else
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
            rootDescription:SetMinimumWidth(1)
            rootDescription:CreateTitle(self.title)
            rootDescription:CreateButton(OBJECTIVES_VIEW_IN_QUESTLOG, function()
                HousingFramesUtil.OpenFrameToTaskID(self.id)
            end)
            rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function()
                 C_NeighborhoodInitiative.RemoveTrackedInitiativeTask(self.id)
            end)
        end)
	end
end

function GwObjectivesHousingInitiativeContainerMixin:InitModule()
    self:RegisterEvent("INITIATIVE_TASKS_TRACKED_UPDATED")
    self:RegisterEvent("INITIATIVE_TASKS_TRACKED_LIST_CHANGED")
    self:RegisterEvent("INITIATIVE_TASK_COMPLETED")
    self:SetScript("OnEvent", self.OnEvent)

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0.5, 1, 0.75, 1)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(HOUSING_DASHBOARD_ENDEAVOR)

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function
    self.header.title:SetTextColor(GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.HousingInitiative]:GetRGB())

    self.blockMixInTemplate = GwObjectivesHousingInitiativeBlockMixin

    self:UpdateLayout()
end
