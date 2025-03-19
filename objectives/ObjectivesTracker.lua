local _, GW = ...

-- container configuration
local objectivesTrackerConfiguration = {
    { name = "GwObjectivesNotification", scrollable = false, mixin = GwObjectivesTrackerNotificationMixin, enumName = "Notification", template = "GwObjectivesNotification" },
    { name = "GwQuesttrackerContainerBossFrames", scrollable = false, mixin = GwObjectivesBossContainerMixin, enumName = "BossFrames" },
    { name = "GwQuesttrackerContainerArenaBGFrames", scrollable = false, mixin = GwObjectivesArenaContainerMixin, enumName = "ArenaFrames" },
    { name = "GwQuesttrackerContainerScenario", scrollable = false, mixin = GwObjectivesScenarioContainerMixin, enumName = "Scenario" },
    { name = "GwQuesttrackerContainerAchievement", scrollable = true, mixin = GwAchievementTrackerContainerMixin, enumName = "Achievement" },
    { name = "GwQuesttrackerContainerCampaign", scrollable = true, mixin = GwObjectivesQuestContainerMixin, enumName = "Campaign" },
    { name = "GwQuesttrackerContainerQuests", scrollable = true, mixin = GwObjectivesQuestContainerMixin, enumName = "Quests" },
    { name = "GwQuesttrackerContainerBonus", scrollable = true, mixin = GwBonusObjectivesTrackerContainerMixin, enumName = "Bonus" },
    { name = "GwQuesttrackerContainerRecipe", scrollable = true, mixin = GwObjectivesRecipeContainerMixin, enumName = "Recipe" },
    { name = "GwQuesttrackerContainerMonthlyActivity", scrollable = true, mixin = GwObjectivesMonthlyActivitiesContainerMixin, enumName = "MonthlyActivity" },
    { name = "GwQuesttrackerContainerCollection", scrollable = true, mixin = GwObjectivesCollectionContainerMixin, enumName = "Collection" },
    -- ADDONS
    { name = "GwQuesttrackerContainerWQT", scrollable = true, mixin = GwWorldQuestTrackerContainerMixin, enumName = "WQT" },
    { name = "GwQuesttrackerContainerPetTracker", scrollable = true, mixin = GwPetTrackerContainerMixin, enumName = "PetTracker" },
    { name = "GwQuesttrackerContainerTodoloo", scrollable = true, mixin = GwTodolooContainerMixin, enumName = "Todoloo" }
}

-- container enum
GW.ObjectiveTrackerContainer = {}

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
    for i = 1, 25 do
        local campaignBlock = _G["GwQuesttrackerContainerCampaignBlock" .. i]
        local questBlock = _G["GwQuesttrackerContainerQuestsBlock" .. i]
        local bonusObjectiveBlock = _G["GwQuesttrackerContainerBlock" .. i]
        if campaignBlock then
            if i <= GW.ObjectiveTrackerContainer.Campaign.numQuests then
                GW.CombatQueue_Queue("update_tracker_campaign_itembutton_position" .. campaignBlock.index, campaignBlock.UpdateObjectiveActionButtonPosition, {campaignBlock})
            else
                GW.CombatQueue_Queue("update_tracker_campaign_itembutton_remove" .. i, campaignBlock.UpdateObjectiveActionButton, {campaignBlock})
            end
        end
        if questBlock then
            if i <= GW.ObjectiveTrackerContainer.Quests.numQuests then
                GW.CombatQueue_Queue("update_tracker_quest_itembutton_position" .. questBlock.index, questBlock.UpdateObjectiveActionButtonPosition, {questBlock, "QUEST"})
            else
                GW.CombatQueue_Queue("update_tracker_quest_itembutton_remove" .. i, questBlock.UpdateObjectiveActionButton, {questBlock})
            end
        end

        if i <= 20 then
            if bonusObjectiveBlock then
                if GW.ObjectiveTrackerContainer.Bonus.numEvents <= i then
                    GW.CombatQueue_Queue("update_tracker_bonus_itembutton_position" .. i, bonusObjectiveBlock.UpdateObjectiveActionButtonPosition, {bonusObjectiveBlock, "EVENT"})
                else
                    GW.CombatQueue_Queue("update_tracker_bonus_itembutton_remove" .. i, bonusObjectiveBlock.UpdateObjectiveActionButton, {bonusObjectiveBlock})
                end
            end
        end
    end

    if GW.ObjectiveTrackerContainer.Scenario.block.hasItem then
        GW.CombatQueue_Queue("update_tracker_scenario_itembutton_position", GW.ObjectiveTrackerContainer.Scenario.block.UpdateObjectiveActionButtonPosition, {GW.ObjectiveTrackerContainer.Scenario.block, "SCENARIO"})
    end
end

local function DisableBlizzardsObjevtiveTracker()
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

function GwObjectivesTrackerMixin:CreateTrackerContainer(name, parent, mixin, template)
    local frame = CreateFrame("Frame", name, parent, template or "GwQuesttrackerContainer")
    frame:SetParent(parent)
    if mixin then
        Mixin(frame, mixin)
    end
    return frame
end

local function LoadObjectivesTracker()
    DisableBlizzardsObjevtiveTracker()

    -- Create our own tracker
    local objectivesTracker = CreateFrame("Frame", "GwQuestTracker", UIParent, "GwQuestTracker")
    objectivesTracker.ScrollFrame = objectivesTracker:CreateTrackerScrollFrame("GwQuestTrackerScroll", GW.settings.QuestTracker_pos_height)
    objectivesTracker.ScrollFrame.Child = CreateFrame("Frame", "GwQuestTrackerScrollChild", objectivesTracker.ScrollFrame, objectivesTracker)

    GW.QuestTrackerFixedContainer = {}
    GW.QuestTrackerScrollableContainer = {}

    -- create container
    for _, config in ipairs(objectivesTrackerConfiguration) do
        local parent = config.scrollable and objectivesTracker.ScrollFrame.Child or objectivesTracker
        local frame = objectivesTracker:CreateTrackerContainer(config.name, parent, config.mixin, config.template)

        GW.ObjectiveTrackerContainer[config.enumName] = frame
        if config.scrollable then
            table.insert(GW.QuestTrackerScrollableContainer, frame)
        else
            table.insert(GW.QuestTrackerFixedContainer, frame)
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

    GW.ToggleCollapseObjectivesInChallangeMode()

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
                C_Timer.After(0.25, function()
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
