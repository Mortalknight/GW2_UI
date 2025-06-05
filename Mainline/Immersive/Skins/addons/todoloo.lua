local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

GwTodolooContainerMixin =  {}
GwTodolooBlockMixin = {}

function GwTodolooBlockMixin:GetObjectiveBlock(index, id)
    if _G[self:GetName() .. "Objective" .. index] then
        _G[self:GetName() .. "Objective" .. index].objectiveKey = id

        return _G[self:GetName() .. "Objective" .. index]
    end
    local newBlock = CreateFrame("Frame", self:GetName() .. "Objective" .. index, self, "GwQuesttrackerObjectiveTemplate")
    newBlock:SetParent(self)
    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)
    newBlock.notChangeSize = true
    if index == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint("TOPRIGHT", _G[self:GetName() .. "Objective" .. (index - 1)], "BOTTOMRIGHT", 0, 0)
    end
    newBlock.objectiveKey = id

    newBlock:HookScript("OnEnter", function()
        local task = Todoloo.TaskManager:GetTask(self.id, newBlock.objectiveKey)
        if task then
            GameTooltip:SetOwner(newBlock, "ANCHOR_BOTTOMLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(task.name, 1, 1, 1)
            if task.description then
                GameTooltip:AddLine(task.description, 1, 1, 1)
            end
            if task.reset then
                local interval = ""
                if task.reset == TODOLOO_RESET_INTERVALS.Daily then
                    interval = "Daily"
                elseif task.reset == TODOLOO_RESET_INTERVALS.Weekly then
                    interval = "Weekly"
                elseif task.reset == TODOLOO_RESET_INTERVALS.Manually then
                    interval = "Manually"
                end
                GameTooltip:AddLine("Reset interval: " .. interval, 1, 1, 1)
            end
            GameTooltip:Show()
        end
    end)
    newBlock:HookScript("OnLeave", GameTooltip_Hide)

    newBlock:SetScript("OnMouseDown", function()
        if IsShiftKeyDown() then
            if newBlock.objectiveKey == "GROUP_COMPLETE" then
                return
            end

            local task = Todoloo.TaskManager:GetTask(self.id, newBlock.objectiveKey)
            Todoloo.TaskManager:SetTaskCompletion(self.id, newBlock.objectiveKey, not task.completed)
        end
    end)

    GW.AddMouseMotionPropagationToChildFrames(self)

    return newBlock
end

local function SetUpObjectivesBlock(block, name, isCompleted, resetType)
    block:Show()

    local text = ""
    if resetType == TODOLOO_RESET_INTERVALS.Daily then
        text = "|A:questlog-questtypeicon-daily:13:13|a " .. name
    elseif resetType == TODOLOO_RESET_INTERVALS.Weekly then
        text = "|A:questlog-questtypeicon-weekly:13:13|a " .. name
    elseif resetType == TODOLOO_RESET_INTERVALS.Manually then
        text = "|TInterface/AddOns/Todoloo/Images/questlog-questtypeicon-disabled:13:13:0:0:32:32:0:18:0:18|t " .. name
    else
        text = name
    end

    block.ObjectiveText:SetText(text)
    block.ObjectiveText:SetHeight(block.ObjectiveText:GetStringHeight() + 15)
    if isCompleted then
        block.ObjectiveText:SetTextColor(OBJECTIVE_TRACKER_COLOR.Complete.r, OBJECTIVE_TRACKER_COLOR.Complete.g, OBJECTIVE_TRACKER_COLOR.Complete.b)
    else
        block.ObjectiveText:SetTextColor(1, 1, 1)
    end
    block.StatusBar:Hide()
    local h = block.ObjectiveText:GetStringHeight() + 10
    block:SetHeight(h)
    block.height = h
end

function GwTodolooBlockMixin:DoTasks(groupCompleted, groupReset)
    local tasks = Todoloo.TaskManager:GetGroupTasks(self.id)
    local counter = 1
    local height = 20
    local iterTasks = {};
    for index, task in ipairs(tasks) do
        task["id"] = index;
        tinsert(iterTasks, task);
    end

    if Todoloo.Config.Get(Todoloo.Config.Options.ORDER_BY_COMPLETION) then
        table.sort(iterTasks, function(lhs, rhs)
            return not lhs.completed and rhs.completed;
        end);
    end

    for _, task in pairs(iterTasks) do
        if groupCompleted then
            if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
                local objectivesBlock = self:GetObjectiveBlock(counter, task.id)
                SetUpObjectivesBlock(objectivesBlock, task.name, true, (task.reset and task.reset or groupReset or 0))

                height = height + objectivesBlock.height
                counter = counter + 1
            end
        else
            if task.completed then
                if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
                    local objectivesBlock = self:GetObjectiveBlock(counter, task.id)
                    SetUpObjectivesBlock(objectivesBlock, task.name, true,  (task.reset and task.reset or groupReset or 0))

                    height = height + objectivesBlock.height
                    counter = counter + 1
                end
            else
                local objectivesBlock = self:GetObjectiveBlock(counter, task.id)
                SetUpObjectivesBlock(objectivesBlock, task.name, false,  (task.reset and task.reset or groupReset or 0))

                height = height + objectivesBlock.height
                counter = counter + 1
            end
        end
    end

    self.height = height + 5
    self:SetHeight(self.height)
end

function GwTodolooContainerMixin:UpdateSingle(group, idx)
    -- Groups without names should not be visible.
    if group.name == "" then
        return false
    end

    local block = self:GetBlock(idx, "EVENT")
    local isComplete = Todoloo.TaskManager:IsGroupComplete(group.id)
    local groupData = Todoloo.TaskManager:GetGroup(group.id)
    local groupHeaderText = group.name
    local groupReset = 0

    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT) then
        local groupProgressText = " (" .. group.numCompletedTasks .. "/" .. group.numTasks .. ")"
        groupHeaderText = groupHeaderText .. groupProgressText
    end
    block.Header:SetText(groupHeaderText)
    block.id = group.id

    if groupData and groupData.reset and (groupData.reset == TODOLOO_RESET_INTERVALS.Daily or groupData.reset == TODOLOO_RESET_INTERVALS.Weekly) then
        block.color = TRACKER_TYPE_COLOR.DAILY
        groupReset = groupData.reset
    else
        block.color = TRACKER_TYPE_COLOR.EVENT
    end

    block.Header:SetTextColor(block.color.r, block.color.g, block.color.b)
        block.hover:SetVertexColor(block.color.r, block.color.g, block.color.b)

    if isComplete and not Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
        block:DoTasks(isComplete, groupReset)
        if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS) then
            local objectivesBlock = block:GetObjectiveBlock(0, "GROUP_COMPLETE")
            SetUpObjectivesBlock(objectivesBlock, "Group tasks done", true, 0)
            block.height = block.height + objectivesBlock.height
        end
    else
        block:DoTasks(isComplete, groupReset)
    end

    block:Show()

    return true, block.height
end

function GwTodolooContainerMixin:UpdateLayout()
    if not Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER) then
        self.header:Hide()
        self:SetHeight(0.001)

        return
    else
        self.header:Show()
    end

    -- hide always all blocks
    for i = 1, 99 do
        local block = _G[self:GetName() .. "Block" .. i]
        if block then
            block:Hide()
        end
    end

    local foundTodo = false
    if self.collapsed then
        self:SetHeight(20)
    else
        local groups = TodolooObjectiveTracker:BuildGroupInfos()
        local containerHeight = 20

        for idx, group in ipairs(groups) do
            local added, usedheight = self:UpdateSingle(group, idx)
            if added then
                foundTodo = true
                containerHeight = containerHeight + usedheight
            end
        end

        self:SetHeight(containerHeight)
    end

    self:SetShown(foundTodo or self.collapsed)

    GwQuestTracker:LayoutChanged()
end

function GwTodolooContainerMixin:InitModule()
    if not GW.settings.SKIN_TODOLOO_ENABLED or not Todoloo then return end

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0, 0.5, 0.5, 0.75)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText("Todoloo's")
    self.header.title:SetTextColor(TRACKER_TYPE_COLOR.EVENT.r, TRACKER_TYPE_COLOR.EVENT.g, TRACKER_TYPE_COLOR.EVENT.b)
    self.header:Show()

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function

    self.blockMixInTemplate = GwTodolooBlockMixin

    Todoloo.EventBus:RegisterEvents(self, {
        Todoloo.Tasks.Events.GROUP_ADDED,
        Todoloo.Tasks.Events.GROUP_REMOVED,
        Todoloo.Tasks.Events.GROUP_RESET,
        Todoloo.Tasks.Events.GROUP_UPDATED,
        Todoloo.Tasks.Events.GROUP_MOVED,
        Todoloo.Tasks.Events.TASK_ADDED,
        Todoloo.Tasks.Events.TASK_COMPLETION_SET,
        Todoloo.Tasks.Events.TASK_REMOVED,
        Todoloo.Tasks.Events.TASK_RESET,
        Todoloo.Tasks.Events.TASK_UPDATED,
        Todoloo.Tasks.Events.TASK_MOVED,
        Todoloo.Reset.Events.RESET_PERFORMED,
        Todoloo.Config.Events.CONFIG_CHANGED
    }, function() self:UpdateLayout() end)
end