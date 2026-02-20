local _, GW = ...

local addonContainerWaitingQueue = {}

-- Helper functions
local function ParseObjectiveString(block, text, numItems, numNeeded, overrideShowStatusbarSetting)
    block.StatusBar.precentage = false

    if not numItems or not numNeeded then
        numItems, numNeeded = string.match(text, "(%d+)/(%d+)")
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
    if not (quantity and totalQuantity and criteriaString) then
        return criteriaString
    end

    if isMythicKeystone then
        if isWeightedProgress then
            local percent = mythicKeystoneCurrentValue / totalQuantity * 100
            return string.format("%s (%d/%d) %s", GW.GetLocalizedNumber(format("%.2f%%", percent)), mythicKeystoneCurrentValue, totalQuantity, criteriaString)
        end
        return string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
    end

    if totalQuantity == 0 then
        return string.format("%d %s", quantity, criteriaString)
    end

    local startPattern = "^%d+/%d+%s+"
    local endPattern = ":%s*%d+/%d+$"

    if criteriaString:match(startPattern) or criteriaString:match(endPattern) then
        return criteriaString
    end

    return string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
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

GwObjectivesTrackerMixin = {}
function GwObjectivesTrackerMixin:LayoutChanged()
    -- adjust scrolframe height
    local scrollContentHeight = 0
    local trackerHeight = GW.settings.QuestTracker_pos_height
    local scroll = 0

    for _, container in pairs(GW.QuestTrackerScrollableContainer) do
        scrollContentHeight = scrollContentHeight + container:GetHeight()
    end

    for _, container in pairs(GW.QuestTrackerFixedContainer) do
        trackerHeight = trackerHeight - container:GetHeight()
    end

    if scrollContentHeight > tonumber(trackerHeight) then
        scroll = math.abs(trackerHeight - scrollContentHeight)
    end
    self.ScrollFrame.maxScroll = scroll

    self.ScrollFrame:SetSize(self:GetWidth(), scrollContentHeight)
end

function GwObjectivesTrackerMixin:AdjustItemButtonPositions()
    for _, container in next, { GW.ObjectiveTrackerContainer.Campaign, GW.ObjectiveTrackerContainer.Quests, GW.ObjectiveTrackerContainer.Bonus } do
        for i = 1, #container.blocks do
            local block = container.blocks[i]
            if i <= container.numQuests then
                GW.CombatQueue_Queue("UpdateTrackerItemButtonPositionForBlock: " .. container:GetDebugName(), block.UpdateObjectiveActionButtonPosition, {block})
            else
                GW.CombatQueue_Queue("RemoveTrackerItemButtonForBlock: " .. container:GetDebugName(), block.UpdateObjectiveActionButton, {block})
            end
        end
    end

    if GW.ObjectiveTrackerContainer.Scenario and GW.ObjectiveTrackerContainer.Scenario.block.hasItem then
        GW.CombatQueue_Queue("UpdateTrackerItemButtonPositionForBlock: " .. GW.ObjectiveTrackerContainer:GetDebugName(), GW.ObjectiveTrackerContainer.Scenario.block.UpdateObjectiveActionButtonPosition, {GW.ObjectiveTrackerContainer.Scenario.block})
    end
end

local function DisableBlizzardsObjevtiveTracker()
    if GW.Retail then
        ObjectiveTrackerFrame:Hide()
        ObjectiveTrackerFrame:UnregisterAllEvents()
        ObjectiveTrackerFrame:SetScript("OnUpdate", nil)
        hooksecurefunc(ObjectiveTrackerFrame, "Show", function(self)
            self:Hide()
        end)
        hooksecurefunc(ObjectiveTrackerFrame, "SetShown", function(self, show)
            if show then
                self:Hide()
            end
        end)
        EventRegistry:UnregisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", ObjectiveTrackerManager)
    elseif GW.Mists then
        WatchFrame:SetMovable(1)
        WatchFrame:SetUserPlaced(true)
        WatchFrame:GwKill()
        WatchFrame:SetScript("OnShow",function() WatchFrame:Hide() end)
    elseif GW.Classic or GW.TBC then
        QuestWatchFrame:SetMovable(1)
        QuestWatchFrame:SetUserPlaced(true)
        QuestWatchFrame:Hide()
        QuestWatchFrame:SetScript("OnShow",function() QuestWatchFrame:Hide() end)
        SetCVar("autoQuestWatch", "1")
    end
end

function GwObjectivesTrackerMixin:CreateTrackerScrollFrame(name, height)
    local scrollFrame = CreateFrame("ScrollFrame", name, self, "GwQuestTrackerScroll")
    scrollFrame:SetHeight(height)
    scrollFrame:SetScript("OnMouseWheel", function(frame, delta)
        delta = -delta * 15
        local s = math.max(0, frame:GetVerticalScroll() + delta)
        if frame.maxScroll then
            s = math.min(frame.maxScroll, s)
        end
        frame:SetVerticalScroll(s)
    end)
    scrollFrame.maxScroll = 0
    return scrollFrame
end

function GwObjectivesTrackerMixin:CreateTrackerContainer(name, parent, mixin, template, enum)
    local frame = CreateFrame("Frame", name, parent, template or "GwQuesttrackerContainer")
    frame:SetParent(parent)
    frame.type = enum
    if mixin then
        Mixin(frame, mixin)
    end
    frame.blocks = {}

    return frame
end

function GwObjectivesTrackerMixin:OnEvent(_, ...)
    local addonName = ...
    for id, config in ipairs(addonContainerWaitingQueue) do
        if config.addonName == addonName then
            local frame = self:CreateTrackerContainer(config.name, self.ScrollFrame.Child, config.mixin, config.template, config.enum)

            GW.ObjectiveTrackerContainer[GW.GetEnumName(GW.Enum.ObjectivesBlockType, config.enum)] = frame
            frame:SetPoint("TOPRIGHT", GW.QuestTrackerScrollableContainer[#GW.QuestTrackerScrollableContainer], "BOTTOMRIGHT")

            table.insert(GW.QuestTrackerScrollableContainer, frame)

            if frame.InitModule then frame:InitModule() end

            GW.ToggleCollapseObjectivesInChallangeMode()
            table.remove(addonContainerWaitingQueue, id)
            break
        end
    end

    if #addonContainerWaitingQueue == 0 then
        self:UnregisterAllEvents()
    end
end

function GwObjectivesTrackerMixin:AddAddonContainerLoadingToQueue(config)
    table.insert(addonContainerWaitingQueue, config)

    if not self:IsEventRegistered("ADDON_LOADED") then
        self:RegisterEvent("ADDON_LOADED")
        self:SetScript("OnEvent", self.OnEvent)
    end
end

local function LoadObjectivesTracker()
    -- container configuration
    local objectivesTrackerConfiguration = {
        { name = "GwObjectivesNotification", scrollable = false, mixin = GwObjectivesTrackerNotificationMixin, enum = GW.Enum.ObjectivesBlockType.Notification, template = "GwObjectivesNotification", load = true },
        { name = "GwQuesttrackerContainerBossFrames", scrollable = false, mixin = GwObjectivesBossContainerMixin, enum = GW.Enum.ObjectivesBlockType.BossFrames, load = not (GW.Classic or GW.TBC) },
        { name = "GwQuesttrackerContainerArenaBGFrames", scrollable = false, mixin = GwObjectivesArenaContainerMixin, enum = GW.Enum.ObjectivesBlockType.ArenaFrames, load = not GW.Classic },
        { name = "GwQuesttrackerContainerScenario", scrollable = false, mixin = GwObjectivesScenarioContainerMixin, enum = GW.Enum.ObjectivesBlockType.Scenario, load = not (GW.Classic or GW.TBC) },
        { name = "GwQuesttrackerContainerAchievement", scrollable = true, mixin = GwAchievementTrackerContainerMixin, enum = GW.Enum.ObjectivesBlockType.Achievement, load = not (GW.Classic or GW.TBC) },
        { name = "GwQuesttrackerContainerCampaign", scrollable = true, mixin = GwObjectivesQuestContainerMixin, enum = GW.Enum.ObjectivesBlockType.Campaign, load = GW.Retail },
        { name = "GwQuesttrackerContainerQuests", scrollable = true, mixin = GwObjectivesQuestContainerMixin, enum = GW.Enum.ObjectivesBlockType.Quests, load = true },
        { name = "GwQuesttrackerContainerBonus", scrollable = true, mixin = GwBonusObjectivesTrackerContainerMixin, enum = GW.Enum.ObjectivesBlockType.Bonus, load = GW.Retail },
        { name = "GwQuesttrackerContainerRecipe", scrollable = true, mixin = GwObjectivesRecipeContainerMixin, enum = GW.Enum.ObjectivesBlockType.Recipe, load = GW.Retail },
        { name = "GwQuesttrackerContainerMonthlyActivity", scrollable = true, mixin = GwObjectivesMonthlyActivitiesContainerMixin, enum = GW.Enum.ObjectivesBlockType.MonthlyActivity, load = GW.Retail },
        { name = "GwQuesttrackerContainerCollection", scrollable = true, mixin = GwObjectivesCollectionContainerMixin, enum = GW.Enum.ObjectivesBlockType.Collection, load = GW.Retail },
        { name = "GwQuesttrackerContainerHousingInitiative", scrollable = true, mixin = GwObjectivesHousingInitiativeContainerMixin, enum = GW.Enum.ObjectivesBlockType.HousingInitiative, load = GW.Retail },
        -- ADDONS
        { name = "GwQuesttrackerContainerWQT", scrollable = true, mixin = GwWorldQuestTrackerContainerMixin, enum = GW.Enum.ObjectivesBlockType.WQT, addonName = "WorldQuestTracker", load = GW.Retail },
        { name = "GwQuesttrackerContainerPetTracker", scrollable = true, mixin = GwPetTrackerContainerMixin, enum = GW.Enum.ObjectivesBlockType.PetTracker, addonName = "PetTracker_Config", load = GW.Retail },
        { name = "GwQuesttrackerContainerTodoloo", scrollable = true, mixin = GwTodolooContainerMixin, enum = GW.Enum.ObjectivesBlockType.Todoloo, addonName = "Todoloo", load = GW.Retail }
    }

    DisableBlizzardsObjevtiveTracker()

    -- Create our own tracker
    local objectivesTracker = CreateFrame("Frame", "GwQuestTracker", UIParent, "GwQuestTracker")
    Mixin(objectivesTracker, GwObjectivesTrackerMixin)
    objectivesTracker.ScrollFrame = objectivesTracker:CreateTrackerScrollFrame("GwQuestTrackerScroll", GW.settings.QuestTracker_pos_height)
    objectivesTracker.ScrollFrame.Child = CreateFrame("Frame", "GwQuestTrackerScrollChild", objectivesTracker.ScrollFrame, objectivesTracker)

    GW.MixinHideDuringPet(objectivesTracker)

    GW.QuestTrackerFixedContainer = {}
    GW.QuestTrackerScrollableContainer = {}

    -- create container
    for _, config in ipairs(objectivesTrackerConfiguration) do
        local shouldLoad = config.load
        if shouldLoad and config.addonName then
            shouldLoad = C_AddOns.IsAddOnLoaded(config.addonName)
            if not shouldLoad then
                objectivesTracker:AddAddonContainerLoadingToQueue(config)
            end
        end

        if shouldLoad then
            local parent = config.scrollable and objectivesTracker.ScrollFrame.Child or objectivesTracker
            local frame = objectivesTracker:CreateTrackerContainer(config.name, parent, config.mixin, config.template, config.enum)

            GW.ObjectiveTrackerContainer[GW.GetEnumName(GW.Enum.ObjectivesBlockType, config.enum)] = frame
            if config.scrollable then
                table.insert(GW.QuestTrackerScrollableContainer, frame)
            else
                table.insert(GW.QuestTrackerFixedContainer, frame)
            end
        end
    end

    -- position of fixed container
    GW.QuestTrackerFixedContainer[1]:SetPoint("TOPRIGHT", objectivesTracker, "TOPRIGHT")
    for i = 2, #GW.QuestTrackerFixedContainer do
        GW.QuestTrackerFixedContainer[i]:SetPoint("TOPRIGHT", GW.QuestTrackerFixedContainer[i - 1], "BOTTOMRIGHT")
    end

    objectivesTracker.ScrollFrame:SetPoint("TOPRIGHT", GW.QuestTrackerFixedContainer[#GW.QuestTrackerFixedContainer], "BOTTOMRIGHT")
    objectivesTracker.ScrollFrame:SetPoint("BOTTOMRIGHT", objectivesTracker, "BOTTOMRIGHT")

    -- position of scroll child
    objectivesTracker.ScrollFrame.Child:SetPoint("TOPRIGHT", objectivesTracker.ScrollFrame, "TOPRIGHT")
    objectivesTracker.ScrollFrame.Child:SetSize(objectivesTracker:GetWidth(), 2)
    objectivesTracker.ScrollFrame:SetScrollChild(objectivesTracker.ScrollFrame.Child)

    -- position of scrollable container
    for i, frame in ipairs(GW.QuestTrackerScrollableContainer) do
        if i == 1 then
            frame:SetPoint("TOPRIGHT", objectivesTracker.ScrollFrame.Child, "TOPRIGHT")
        else
            frame:SetPoint("TOPRIGHT", GW.QuestTrackerScrollableContainer[i - 1], "BOTTOMRIGHT")
        end
    end

    -- init container
    for _, frame in ipairs(GW.QuestTrackerFixedContainer) do
        if frame.InitModule then frame:InitModule() end
    end
    for _, frame in ipairs(GW.QuestTrackerScrollableContainer) do
        if frame.InitModule then frame:InitModule() end
    end

    if GW.Retail then
        GW.ToggleCollapseObjectivesInChallangeMode()
    end

     -- some hooks to set the itembuttons correct
    local UpdateItemButtonPositionAndAdjustScrollFrame = function()
        GW.Debug("Update Quest Buttons")
        objectivesTracker:LayoutChanged()
        objectivesTracker:AdjustItemButtonPositions()
    end

    -- for correct itembutton position
    for _, container in next, { GW.ObjectiveTrackerContainer.BossFrames, GW.ObjectiveTrackerContainer.AreanFrames, GW.ObjectiveTrackerContainer.Scenario, GW.ObjectiveTrackerContainer.Achievement, GW.ObjectiveTrackerContainer.Quests, GW.ObjectiveTrackerContainer.Campaign } do
        container.oldHeight = 1
        hooksecurefunc(container, "SetHeight", function(_, height)
            if container.oldHeight ~= GW.RoundInt(height) then
                C_Timer.After(0.1, function()
                    UpdateItemButtonPositionAndAdjustScrollFrame()
                end)
            end
        end)
    end

    GW.ObjectiveTrackerContainer.Notification:HookScript("OnShow", function() C_Timer.After(0.25, UpdateItemButtonPositionAndAdjustScrollFrame) end)
    GW.ObjectiveTrackerContainer.Notification:HookScript("OnHide", function() C_Timer.After(0.25, UpdateItemButtonPositionAndAdjustScrollFrame) end)

    GW.RegisterMovableFrame(objectivesTracker, OBJECTIVES_TRACKER_LABEL, "QuestTracker_pos", ALL, nil, {"scaleable", "height"})
    objectivesTracker:ClearAllPoints()
    objectivesTracker:SetPoint("TOPLEFT", objectivesTracker.gwMover)
    objectivesTracker:SetHeight(GW.settings.QuestTracker_pos_height)
end
GW.LoadObjectivesTracker = LoadObjectivesTracker
