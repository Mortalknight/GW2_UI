local _, GW = ...
local AddTrackerNotification = GW.AddTrackerNotification
local RemoveTrackerNotificationOfType = GW.RemoveTrackerNotificationOfType
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local NewQuestAnimation = GW.NewQuestAnimation
local ParseSimpleObjective = GW.ParseSimpleObjective
local ParseObjectiveString = GW.ParseObjectiveString
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local UpdateQuestItem = GW.UpdateQuestItem
local QuestTrackerLayoutChanged = GW.QuestTrackerLayoutChanged

local savedQuests = {}
local trackedEventIDs = {}

local function getObjectiveBlock(self, index)
    if _G[self:GetName() .. "GwQuestObjective" .. index] ~= nil then
        return _G[self:GetName() .. "GwQuestObjective" .. index]
    end

    if self.objectiveBlocksNum == nil then
        self.objectiveBlocksNum = 0
    end
    if self.objectiveBlocks == nil then
        self.objectiveBlocks = {}
    end

    self.objectiveBlocksNum = self.objectiveBlocksNum + 1

    local newBlock = CreateObjectiveNormal(self:GetName() .. "GwQuestObjective" .. self.objectiveBlocksNum, self)
    newBlock:SetParent(self)
    self.objectiveBlocks[self.objectiveBlocksNum] = newBlock
    if self.objectiveBlocksNum == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint(
            "TOPRIGHT",
            _G[self:GetName() .. "GwQuestObjective" .. (self.objectiveBlocksNum - 1)],
            "BOTTOMRIGHT",
            0,
            0
        )
    end

    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    return newBlock
end
GW.AddForProfiling("bonusObjective", "getObjectiveBlock", getObjectiveBlock)

local function TryAddingExpirationWarningLine(block, objectiveIndex)
    if QuestUtils_ShouldDisplayExpirationWarning(block.questID) then
        local objectiveBlock = getObjectiveBlock(block, objectiveIndex)
        local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(block.questID)
        if timeLeftMinutes and block.tickerSeconds and timeLeftMinutes > 0 then
            if timeLeftMinutes < WORLD_QUESTS_TIME_CRITICAL_MINUTES then
                local timeString = SecondsToTime(timeLeftMinutes * 60)
                local text = BONUS_OBJECTIVE_TIME_LEFT:format(timeString)
                objectiveBlock:Show()
                objectiveBlock.ObjectiveText:SetText(text)
                objectiveBlock.ObjectiveText:SetTextColor(DIM_RED_FONT_COLOR.r, DIM_RED_FONT_COLOR.g, DIM_RED_FONT_COLOR.b )
                objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
                objectiveBlock.StatusBar:Hide()
                local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
                objectiveBlock:SetHeight(h)
                block.height = block.height + objectiveBlock:GetHeight()
                block.numObjectives = block.numObjectives + 1

                block.tickerSeconds = 10
            else
                local timeToAlert = max((timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) * 60 - 10, 10)
                if block.tickerSeconds == 0 or timeToAlert < block.tickerSeconds then
                    block.tickerSeconds = timeToAlert
                end
            end
        end
    end
end

local function addObjectiveBlock(block, text, finished, objectiveIndex, objectiveType, quantity)
    local objectiveBlock = getObjectiveBlock(block, objectiveIndex)

    local precentageComplete = 0
    if text then
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText(text)
        objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
        if finished then
            objectiveBlock.ObjectiveText:SetTextColor(0.8, 0.8, 0.8)
        else
            objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
        end

        if objectiveType == "progressbar" or ParseObjectiveString(objectiveBlock, text, objectiveType, quantity) then
            if objectiveType == "progressbar" then
                objectiveBlock.StatusBar:Show()
                objectiveBlock.StatusBar:SetMinMaxValues(0, 100)
                objectiveBlock.StatusBar:SetValue(GetQuestProgressBarPercent(block.questID))
                objectiveBlock.progress = GetQuestProgressBarPercent(block.questID) / 100
                objectiveBlock.StatusBar.precentage = true
            end
            precentageComplete = objectiveBlock.progress
        else
            objectiveBlock.StatusBar:Hide()
        end

        local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
        objectiveBlock:SetHeight(h)
        if objectiveBlock.StatusBar:IsShown() then
            if block.numObjectives >= 1 then
                h = h + objectiveBlock.StatusBar:GetHeight() + 10
            else
                h = h + objectiveBlock.StatusBar:GetHeight() + 5
            end
            objectiveBlock:SetHeight(h)
        end
        block.height = block.height + objectiveBlock:GetHeight()
        block.numObjectives = block.numObjectives + 1
    end
    return precentageComplete
end
GW.AddForProfiling("bonusObjective", "addObjectiveBlock", addObjectiveBlock)

local function createNewBonusObjectiveBlock(blockIndex)
    if _G["GwBonusObjectiveBlock" .. blockIndex] ~= nil then
        return _G["GwBonusObjectiveBlock" .. blockIndex]
    end

    local newBlock = CreateTrackerObject("GwBonusObjectiveBlock" .. blockIndex, GwQuesttrackerContainerBonusObjectives)
    newBlock:SetParent(GwQuesttrackerContainerBonusObjectives)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerBonusObjectives, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwBonusObjectiveBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end

    newBlock.Header:SetText("")
    newBlock.event = true
    newBlock:SetScript("OnClick", BonusObjectiveTracker_OnBlockClick)

    hooksecurefunc("BonusObjectiveTracker_UntrackWorldQuest", function(questID)
        savedQuests[questID] = nil
        if trackedEventIDs[questID] ~= nil then
            trackedEventIDs[questID]["tracked"] = false
        end
    end)

    newBlock.color = TRACKER_TYPE_COLOR["BONUS"]
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)

    newBlock.joingroup:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/LFDMicroButton-Down")
    newBlock.joingroup:SetScript(
        "OnClick",
        function (self)
            local p = self:GetParent()
            LFGListUtil_FindQuestGroup(p.questID)
        end
    )
    newBlock.joingroup:SetScript(
        "OnEnter",
        function (self)
            GameTooltip:SetOwner(self)
            GameTooltip:AddLine(TOOLTIP_TRACKER_FIND_GROUP_BUTTON, HIGHLIGHT_FONT_COLOR:GetRGB())
            GameTooltip:Show()
        end
    )
    newBlock.joingroup:SetScript("OnLeave", GameTooltip_Hide)

    newBlock.height = 20
    newBlock.numObjectives = 0
    newBlock:Hide()

    return newBlock
end

local foundEvent = false
local shownBlocks = 0
local blockIndex = 1

local function setUpBlock(questIDs)
    local savedContainerHeight = 20

    for k, v in pairs(questIDs) do
        local questID = v.ID
        local isInArea, isOnMap, numObjectives, text = GetTaskInfo(questID)
        local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        local simpleDesc = ""
        local compassData = {}

        if isOnMap then
            compassData.TYPE = "EVENT"
            compassData.COMPASS = true
        end

        if numObjectives == nil then
            numObjectives = 0
        end
        if isInArea or v.tracked then
            compassData.TITLE = text

            if text == nil then
                text = ""
            end
            local GwBonusObjectiveBlock = createNewBonusObjectiveBlock(blockIndex)
            if GwBonusObjectiveBlock == nil then
                return
            end
            if GwBonusObjectiveBlock.ticker then
                GwBonusObjectiveBlock.ticker:Cancel()
                GwBonusObjectiveBlock.ticker = nil
            end
            GwBonusObjectiveBlock.tickerSeconds = 0
            shownBlocks = shownBlocks + 1
            GwBonusObjectiveBlock.height = 20
            GwBonusObjectiveBlock.numObjectives = 0
            
            GwBonusObjectiveBlock.Header:SetText(text)

            if savedQuests[questID] == nil then
                NewQuestAnimation(GwBonusObjectiveBlock)
                PlaySound(SOUNDKIT["UI_WORLDQUEST_START"])
                savedQuests[questID] = true
            end

            GwBonusObjectiveBlock.questID = questID
            GwBonusObjectiveBlock.id = questID
            GwBonusObjectiveBlock.TrackedQuest = {}
            GwBonusObjectiveBlock.TrackedQuest.questID = questID

            local module = CreateBonusObjectiveTrackerModule()
            module.ShowWorldQuests = true
            GwBonusObjectiveBlock.module = module

            GwBonusHeader:Show()
            UpdateQuestItem(GwBonusItemButton, questLogIndex, GwBonusObjectiveBlock)

            foundEvent = true

            compassData.PROGRESS = 0

            local objectiveProgress = 0
            for objectiveIndex = 1, numObjectives do
                local txt, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, false)

                compassData.TYPE = "EVENT"
                compassData.ID = questID
                compassData.COLOR = TRACKER_TYPE_COLOR.EVENT
                compassData.COMPASS = false
                compassData.X = nil
                compassData.Y = nil
                compassData.QUESTID = questID
                compassData.MAPID = GW.locationData.mapID

                if simpleDesc == "" then
                    simpleDesc = ParseSimpleObjective(txt)
                else
                    simpleDesc = simpleDesc .. ", " .. ParseSimpleObjective(txt)
                end

                if not GwQuesttrackerContainerBonusObjectives.collapsed == true then
                    local progressValue = addObjectiveBlock(GwBonusObjectiveBlock, txt, finished, objectiveIndex, objectiveType)
                    if finished then
                        objectiveProgress = objectiveProgress + (1 / numObjectives)
                    else
                        objectiveProgress = objectiveProgress + progressValue
                    end
                end
            end

            -- try to add a timer here
            TryAddingExpirationWarningLine(GwBonusObjectiveBlock, numObjectives + 1)
            if GwBonusObjectiveBlock.tickerSeconds > 0 then
                GwBonusObjectiveBlock.ticker = C_Timer.NewTicker(GwBonusObjectiveBlock.tickerSeconds, function()
                    GW.updateBonusObjective(GwQuesttrackerContainerBonusObjectives)
                end)
            end

            if simpleDesc ~= "" then
                compassData.DESC = simpleDesc
            end

            compassData.PROGRESS = objectiveProgress

            if isInArea then
                AddTrackerNotification(compassData)
            end

            savedContainerHeight = savedContainerHeight + GwBonusObjectiveBlock.height + 10

            if not GwQuesttrackerContainerBonusObjectives.collapsed then
                --add groupfinder button
                if C_LFGList.CanCreateQuestGroup(GwBonusObjectiveBlock.questID) then
                    GwBonusObjectiveBlock.joingroup:Show()
                else
                    GwBonusObjectiveBlock.joingroup:Hide()
                end
                GwBonusObjectiveBlock:Show()
            end
            for i = GwBonusObjectiveBlock.numObjectives + 1, 20 do
                if _G[GwBonusObjectiveBlock:GetName() .. "GwQuestObjective" .. i] ~= nil then
                    _G[GwBonusObjectiveBlock:GetName() .. "GwQuestObjective" .. i]:Hide()
                end
            end

            GwBonusObjectiveBlock:SetHeight(GwBonusObjectiveBlock.height + 10)
            blockIndex = blockIndex + 1
        end
    end
    GwQuesttrackerContainerBonusObjectives:SetHeight(savedContainerHeight)
end

local function updateBonusObjective(self, event)
    RemoveTrackerNotificationOfType("EVENT")
    RemoveTrackerNotificationOfType("EVENT_NEARBY")
    RemoveTrackerNotificationOfType("BONUS")

    UpdateQuestItem(GwBonusItemButton, 0, nil)

    local tasks = GetTasksTable()
    local EventToShow = false

    foundEvent = false
    shownBlocks = 0
    blockIndex = 1
    trackedEventIDs = {}

    for i = 1, C_QuestLog.GetNumWorldQuestWatches() do
        local wqID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
        if trackedEventIDs[wqID] == nil then
            trackedEventIDs[wqID] = {}
            trackedEventIDs[wqID].ID = wqID
            trackedEventIDs[wqID].tracked = true
            EventToShow = true
        end
    end

    for k, v in pairs(tasks) do
        if trackedEventIDs[v] == nil then
            trackedEventIDs[v] = {}
            trackedEventIDs[v].ID = v
            trackedEventIDs[v].tracked = false
            local isInArea = GetTaskInfo(v)
            if isInArea then EventToShow = true end
        end
    end

    if GwQuesttrackerContainerBonusObjectives.collapsed then
        if EventToShow then
            GwBonusHeader:Show()
            foundEvent = true
            trackedEventIDs = {}
        else
            foundEvent = false
            GwQuesttrackerContainerBonusObjectives.collapsed = false
        end
    end

    setUpBlock(trackedEventIDs)
    if not foundEvent then
        savedQuests = {}
        GwBonusHeader:Hide()
        for i = 1, 20 do
            if _G["GwBonusObjectiveBlock" .. i] ~= nil then
                _G["GwBonusObjectiveBlock" .. i].questID = false
                _G["GwBonusObjectiveBlock" .. i]:Hide()
                if _G["GwBonusObjectiveBlock" .. i].ticker then
                    _G["GwBonusObjectiveBlock" .. i].ticker:Cancel()
                    _G["GwBonusObjectiveBlock" .. i].ticker = nil
                end
            end
        end
    else
        for i = shownBlocks + 1, 20 do
            if _G["GwBonusObjectiveBlock" .. i] ~= nil then
                _G["GwBonusObjectiveBlock" .. i].questID = false
                _G["GwBonusObjectiveBlock" .. i]:Hide()
                if _G["GwBonusObjectiveBlock" .. i].ticker then
                    _G["GwBonusObjectiveBlock" .. i].ticker:Cancel()
                    _G["GwBonusObjectiveBlock" .. i].ticker = nil
                end
            end
        end
    end

    QuestTrackerLayoutChanged()
end
GW.updateBonusObjective = updateBonusObjective
GW.AddForProfiling("bonusObjective", "updateBonusObjective", updateBonusObjective)

local function LoadBonusFrame()
    GwQuesttrackerContainerBonusObjectives:SetScript("OnEvent", updateBonusObjective)
    GwQuesttrackerContainerBonusObjectives:RegisterEvent("QUEST_LOG_UPDATE")
    GwQuesttrackerContainerBonusObjectives:RegisterEvent("TASK_PROGRESS_UPDATE")
    GwQuesttrackerContainerBonusObjectives:RegisterEvent("QUEST_WATCH_LIST_CHANGED")

    local header = CreateFrame("Button", "GwBonusHeader", GwQuesttrackerContainerBonusObjectives, "GwQuestTrackerHeader")
    header.icon:SetTexCoord(0, 0.5, 0.5, 0.75)
    header.title:SetFont(UNIT_NAME_FONT, 14)
    header.title:SetShadowOffset(1, -1)
    header.title:SetText(EVENTS_LABEL)

    GwQuesttrackerContainerBonusObjectives.collapsed = false
    header:SetScript(
        "OnClick",
        function(self)
            local p = self:GetParent()
            if p.collapsed == nil or p.collapsed == false then
                p.collapsed = true

                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            else
                p.collapsed = false

                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            end
            updateBonusObjective()
        end
    )
    header.title:SetTextColor(
        TRACKER_TYPE_COLOR.BONUS.r,
        TRACKER_TYPE_COLOR.BONUS.g,
        TRACKER_TYPE_COLOR.BONUS.b
    )
    
    updateBonusObjective()
end
GW.LoadBonusFrame = LoadBonusFrame
