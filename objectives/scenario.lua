local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local ParseCriteria = GW.ParseCriteria
local ParseObjectiveString = GW.ParseObjectiveString
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local UpdateQuestItem = GW.UpdateQuestItem
local setBlockColor = GW.setBlockColor

local TIME_FOR_3 = 0.6
local TIME_FOR_2 = 0.8

local function getObjectiveBlock(self, index)
    local block = _G[self:GetName() .. "GwQuestObjective" .. index]
    if block then
        block:SetScript("OnEnter", nil)
        block:SetScript("OnLeave", nil)
        block.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)
        block.isMythicKeystone = false
        return block
    end

    if self.objectiveBlocksNum == nil then
        self.objectiveBlocksNum = 0
    end
    self.objectiveBlocks = self.objectiveBlocks or {}
    self.objectiveBlocksNum = self.objectiveBlocksNum + 1

    local newBlock = CreateObjectiveNormal(self:GetName() .. "GwQuestObjective" .. self.objectiveBlocksNum, self)
    tinsert(self.objectiveBlocks, newBlock)
    newBlock:SetParent(self)
    if self.objectiveBlocksNum == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -5)
    else
        newBlock:SetPoint(
            "TOPRIGHT",
            _G[self:GetName() .. "GwQuestObjective" .. (self.objectiveBlocksNum - 1)],
            "BOTTOMRIGHT",
            0,
            0
        )
    end

    newBlock.hasObjectToHide = false
    newBlock.objectToHide = nil
    newBlock.resetParent = false
    newBlock.isMythicKeystone = false
    newBlock:SetScript("OnEnter", nil)
    newBlock:SetScript("OnLeave", nil)
    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    return newBlock
end
GW.GetScenarioObjectivesBlock = getObjectiveBlock
GW.AddForProfiling("scenario", "getObjectiveBlock", getObjectiveBlock)

local function addObjectiveBlock(block, text, finished, objectiveIndex, objectiveType, quantity, isMythicKeystone)
    local objectiveBlock = getObjectiveBlock(block, objectiveIndex)
    objectiveBlock.isMythicKeystone = isMythicKeystone

    if text then
        if objectiveBlock.hasObjectToHide then
            if objectiveBlock.resetParent then objectiveBlock.objectToHide.SetParent = nil end
            objectiveBlock.objectToHide:SetParent(GW.HiddenFrame)
            if objectiveBlock.resetParent then objectiveBlock.objectToHide.SetParent = GW.NoOp end
        end
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText(text)
        objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
        if finished then
            objectiveBlock.ObjectiveText:SetTextColor(0.8, 0.8, 0.8)
        else
            objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
        end

        if not ParseObjectiveString(objectiveBlock, text, objectiveType, quantity, nil, nil, isMythicKeystone) then
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
end
GW.AddScenarioObjectivesBlock = addObjectiveBlock
GW.AddForProfiling("scenario", "addObjectiveBlock", addObjectiveBlock)

local function updateCurrentScenario(self, event, ...)
    if event == "UPDATE_UI_WIDGET" then
        -- we need this event only for torghast atm, so only update this we it is the torghast widget
        local w = ...
        if not w or (w and w.widgetID ~= 3302) then
            return
        end
    end
    GW.RemoveTrackerNotificationOfType("SCENARIO")
    GW.RemoveTrackerNotificationOfType("TORGHAST")

    local compassData = {}
    local showTimerAsBonus = false
    local GwQuestTrackerTimerSavedHeight = 1
    local isEmberCourtWidget = false
    local isDragonflightCookingEventWidget = false

    compassData.TYPE = "SCENARIO"
    compassData.TITLE = "Unknown Scenario"
    compassData.ID = "unknown"
    compassData.QUESTID = "unknown"
    compassData.COMPASS = false

    compassData.MAPID = nil
    compassData.X = nil
    compassData.Y = nil

    compassData.COLOR = TRACKER_TYPE_COLOR.SCENARIO

    GwScenarioBlock.height = 1

    if GwQuestTrackerTimer:IsShown() then
        GwScenarioBlock.height = GwQuestTrackerTimer.height
    end

    GwScenarioBlock.numObjectives = 0
    GwScenarioBlock.questLogIndex = 0
    GwScenarioBlock:Show()

    local _, _, numStages = C_Scenario.GetInfo()
    if (numStages == 0 or IsOnGroundFloorInJailersTower()) then
        local name, instanceType, _, difficultyName, _ = GetInstanceInfo()
        if instanceType == "raid" then
            compassData.TITLE = name
            compassData.DESC = difficultyName
            GW.AddTrackerNotification(compassData)
            GwScenarioBlock.height = GwScenarioBlock.height + 5
        else
            GW.RemoveTrackerNotificationOfType("SCENARIO")
            GW.RemoveTrackerNotificationOfType("TORGHAST")
            GwScenarioBlock:Hide()
        end
        GW.CombatQueue_Queue(nil, UpdateQuestItem, {GwScenarioBlock})
        if GwScenarioBlock.hasItem then
            GW.CombatQueue_Queue("update_tracker_scenario_itembutton_position", GW.updateQuestItemPositions, {GwScenarioBlock.actionButton, GwScenarioBlock.height, "SCENARIO", GwScenarioBlock})
        end
        for i = GwScenarioBlock.numObjectives + 1, 20 do
            if _G[GwScenarioBlock:GetName() .. "GwQuestObjective" .. i] then
                _G[GwScenarioBlock:GetName() .. "GwQuestObjective" .. i]:Hide()
            end
        end

        GwScenarioBlock:SetHeight(GwScenarioBlock.height)

        GwQuesttrackerContainerScenario.oldHeight = GW.RoundInt(GwQuesttrackerContainerScenario:GetHeight())
        GwQuesttrackerContainerScenario:SetHeight(GwScenarioBlock.height)

        GwQuestTrackerTimer.timer:Hide()

        if not showTimerAsBonus then
            return
        end
    end

    local stageName, stageDescription, numCriteria, _, _, _, _, _, _, questID = C_Scenario.GetStepInfo()

    local _, _, difficultyID, difficultyName = GetInstanceInfo()
    local isMythicKeystone = difficultyID == 8
    if stageDescription == nil then
        stageDescription = ""
    end
    if stageName == nil then
        stageName = ""
    end
    if difficultyName then
        local level = C_ChallengeMode.GetActiveKeystoneInfo()
        if level > 0 then
            compassData.TITLE = stageName .. " |cFFFFFFFF +" .. level .. " " .. difficultyName .. "|r"
        else
            compassData.TITLE = stageName .. " |cFFFFFFFF " .. difficultyName .. "|r"
        end
        compassData.DESC = stageDescription .. " "
    end

    if IsInJailersTower() then
        local floor = ""
        if event == "JAILERS_TOWER_LEVEL_UPDATE" then
            local level, type, textureKit = ...
            self.jailersTowerLevelUpdateInfo = {level = level, type = type, textureKit = textureKit}
        end
        local widgetInfo = C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo(3302)
        if widgetInfo then floor = widgetInfo.headerText or "" end

        if self.jailersTowerLevelUpdateInfo ~= nil and self.jailersTowerLevelUpdateInfo.type ~= nil then
            local typeString = C_ScenarioInfo.GetJailersTowerTypeString(self.jailersTowerLevelUpdateInfo.type)
            if typeString then
                compassData.TITLE = difficultyName .. " |cFFFFFFFF " .. floor .. " - " .. typeString .. "|r"
            else
                compassData.TITLE = difficultyName .. " |cFFFFFFFF " .. floor .. "|r"
            end
        else
            compassData.TITLE = difficultyName .. " |cFFFFFFFF " .. floor .. "|r"
        end

        compassData.COLOR = TRACKER_TYPE_COLOR.TORGHAST
        compassData.TYPE = "TORGHAST"
    end
    setBlockColor(GwScenarioBlock, compassData.TYPE)
    GwScenarioBlock.Header:SetTextColor(GwScenarioBlock.color.r, GwScenarioBlock.color.g, GwScenarioBlock.color.b)
    GwScenarioBlock.hover:SetVertexColor(GwScenarioBlock.color.r, GwScenarioBlock.color.g, GwScenarioBlock.color.b)
    GW.AddTrackerNotification(compassData, true)

    if questID ~= nil then
        GwScenarioBlock.questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    end

    GW.CombatQueue_Queue(nil, UpdateQuestItem, {GwScenarioBlock})

    for criteriaIndex = 1, numCriteria do
        local criteriaString, _, _, quantity, totalQuantity, _, _, mythicKeystoneCurrentValue, _, _, _, _, isWeightedProgress = C_Scenario.GetCriteriaInfo(criteriaIndex)
        local objectiveType = not isWeightedProgress and "monster" or "progressbar"
        if objectiveType == "progressbar" and not isMythicKeystone then
            totalQuantity = 100
        end
        if isMythicKeystone then
            mythicKeystoneCurrentValue = strtrim(mythicKeystoneCurrentValue, "%") or 1
        end
        addObjectiveBlock(
            GwScenarioBlock,
            ParseCriteria(quantity, totalQuantity, criteriaString, isMythicKeystone, mythicKeystoneCurrentValue, isWeightedProgress),
            false,
            criteriaIndex,
            objectiveType,
            quantity,
            isMythicKeystone
        )
    end
    -- add special widgets here
    numCriteria = GW.addWarfrontData(GwScenarioBlock, numCriteria)
    numCriteria = GW.addHeroicVisionsData(GwScenarioBlock, numCriteria)
    numCriteria = GW.addJailersTowerData(GwScenarioBlock, numCriteria)
    numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget = GW.addEmberCourtData(GwScenarioBlock, numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget)
    GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isDragonflightCookingEventWidget = GW.addDragonflightCookingEventData(GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isDragonflightCookingEventWidget)

    local bonusSteps = C_Scenario.GetBonusSteps() or {}
    local numCriteriaPrev = numCriteria

    for _, v in pairs(bonusSteps) do
        local bonusStepIndex = v
        local _, _, numCriteria = C_Scenario.GetStepInfo(bonusStepIndex)

        for criteriaIndex = 1, numCriteria do
            local criteriaString, _, criteriaCompleted, quantity, totalQuantity, _, _, _, _, duration, elapsed, criteriaFailed, isWeightedProgress = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex)
            local objectiveType = "progressbar"
            if not isWeightedProgress then
                objectiveType = "monster"
            end
            -- timer bar
            if (duration > 0 and elapsed <= duration and not (criteriaFailed or criteriaCompleted)) then
                GwQuestTrackerTimer:SetScript(
                    "OnUpdate",
                    function()
                        local elapsed = select(11, C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex))
                        if elapsed and elapsed > 0 then
                            GwQuestTrackerTimer.timer:SetValue(1 - (elapsed / duration))
                            GwQuestTrackerTimer.timerString:SetText(SecondsToClock(duration - elapsed))
                        else
                            GwQuestTrackerTimer:SetScript("OnUpdate", nil)
                        end
                    end
                )
                GwQuestTrackerTimer.timer:Show()
                GwQuestTrackerTimerSavedHeight = GwQuestTrackerTimerSavedHeight + 40
                showTimerAsBonus = true
            elseif not showTimerAsBonus then
                GwQuestTrackerTimerSavedHeight = 1
                GwQuestTrackerTimer:SetScript("OnUpdate", nil)
                GwQuestTrackerTimer.timer:Hide()

                addObjectiveBlock(
                    GwScenarioBlock,
                    ParseCriteria(quantity, totalQuantity, criteriaString),
                    false,
                    numCriteriaPrev + criteriaIndex,
                    objectiveType,
                    quantity
                )
            end
        end
        numCriteriaPrev = numCriteriaPrev + numCriteria
    end

    for i = GwScenarioBlock.numObjectives + 1, 20 do
        if _G[GwScenarioBlock:GetName() .. "GwQuestObjective" .. i] ~= nil then
            _G[GwScenarioBlock:GetName() .. "GwQuestObjective" .. i]:Hide()
        end
    end

    GwScenarioBlock.height = GwScenarioBlock.height + 5
    if GwScenarioBlock.hasItem then
        GW.CombatQueue_Queue("update_tracker_scenario_itembutton_position", GW.updateQuestItemPositions, {GwScenarioBlock.actionButton, GwScenarioBlock.height, "SCENARIO", GwScenarioBlock})
    end

    local intGWQuestTrackerHeight = 0

    if GwQuestTrackerTimer.affixes:IsShown() then
        intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40
    end

    if GwQuestTrackerTimer.timer:IsShown() then
        intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40
    end

    if showTimerAsBonus or isEmberCourtWidget or isDragonflightCookingEventWidget then
        GwQuestTrackerTimer.height = GwQuestTrackerTimerSavedHeight
    end

    GwQuestTrackerTimer:SetHeight(GwQuestTrackerTimer.height)
    GwScenarioBlock:SetHeight(GwScenarioBlock.height - intGWQuestTrackerHeight)
    GwQuesttrackerContainerScenario.oldHeight = GW.RoundInt(GwQuesttrackerContainerScenario:GetHeight())
    GwQuesttrackerContainerScenario:SetHeight(GwScenarioBlock.height)
end
GW.updateCurrentScenario = updateCurrentScenario
GW.AddForProfiling("scenario", "updateCurrentScenario", updateCurrentScenario)

local function scenarioTimerStop()
    _G.GwQuestTrackerTimer:SetScript("OnUpdate", nil)
    _G.GwQuestTrackerTimer.timer:Hide()
    _G.GwQuestTrackerTimer.timerStringChest2:Hide()
    _G.GwQuestTrackerTimer.timerStringChest3:Hide()
    _G.GwQuestTrackerTimer.chestoverlay:Hide()
    _G.GwQuestTrackerTimer.deathcounter:Hide()
end
GW.AddForProfiling("scenario", "scenarioTimerStop", scenarioTimerStop)

local function scenarioAffixes()
    local _, affixes, _ = C_ChallengeMode.GetActiveKeystoneInfo()
    local i = 1
    for _, v in pairs(affixes) do
        if i == 1 then
            _G.GwQuestTrackerTimer.height = GwQuestTrackerTimer.height + 40
            GwQuestTrackerTimer.timer:ClearAllPoints()
            GwQuestTrackerTimer.timer:SetPoint("TOPLEFT", GwQuestTrackerTimer.affixes, "BOTTOMLEFT", -10, -15)
        end
        local affixID = v
        local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID)

        if filedataid ~= nil then
            SetPortraitToTexture(GwQuestTrackerTimer.affixes.affixes[i].icon, filedataid)
        end
        GwQuestTrackerTimer.affixes.affixes[i].affixID = affixID
        GwQuestTrackerTimer.affixes.affixes[i]:Show()
        GwQuestTrackerTimer.affixes.affixes[i].icon:Show()
        GwQuestTrackerTimer.affixes:Show()
        i = i + 1
    end

    if i == 1 then
        GwQuestTrackerTimer.timer:ClearAllPoints()
        GwQuestTrackerTimer.timer:SetPoint("TOPRIGHT", GwQuestTrackerTimer.affixes, "BOTTOMRIGHT", -10, 20)
        for _, v in ipairs(GwQuestTrackerTimer.affixes.affixes) do
            v.affixID = nil
            v.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-boss")
        end
        GwQuestTrackerTimer.affixes:Hide()
    end
end
GW.AddForProfiling("scenario", "scenarioAffixes", scenarioAffixes)

local function scenarioTimerUpdateDeathCounter(self)
    local count, timeLost = C_ChallengeMode.GetDeathCount()
    self.deathcounter.count = count
    self.deathcounter.timeLost = timeLost
    if (timeLost and timeLost > 0 and count and count > 0) then
        self.deathcounter.counterlabel:SetText(count)
        self.deathcounter:Show()
    else
        self.deathcounter:Hide()
    end
end
GW.AddForProfiling("scenario", "scenarioTimerUpdateDeathCounter", scenarioTimerUpdateDeathCounter)

local function scenarioTimerUpdate(...)
    GwQuestTrackerTimer.height = 1

    for i = 1, select("#", ...) do
        local timerID = select(i, ...)
        local _, _, wtype = GetWorldElapsedTime(timerID)
        if (wtype == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE) then
            local mapID = C_ChallengeMode.GetActiveChallengeMapID()
            if (mapID) then
                local _, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
                local time3 = timeLimit * TIME_FOR_3
                local time2 = timeLimit * TIME_FOR_2
                --    Scenario_ChallengeMode_ShowBlock(timerID, elapsedTime, timeLimit);
                --set Chest icon
                GwQuestTrackerTimer.chestoverlay:Show()
                GwQuestTrackerTimer.chestoverlay.chest2:ClearAllPoints()
                GwQuestTrackerTimer.chestoverlay.chest2:SetPoint("LEFT", GwQuestTrackerTimer.timer, "LEFT", GwQuestTrackerTimer.timer:GetWidth() * (1 - TIME_FOR_2) - 1, -6)
                GwQuestTrackerTimer.chestoverlay.chest3:ClearAllPoints()
                GwQuestTrackerTimer.chestoverlay.chest3:SetPoint("LEFT", GwQuestTrackerTimer.timer, "LEFT", GwQuestTrackerTimer.timer:GetWidth() * (1 - TIME_FOR_3) - 1, -6)
                GwQuestTrackerTimer:SetScript(
                    "OnUpdate",
                    function()
                        local _, elapsedTime, _ = GetWorldElapsedTime(timerID)
                        GwQuestTrackerTimer.timer:SetValue(1 - (elapsedTime / timeLimit))
                        GwQuestTrackerTimer.chestoverlay.chest2:SetShown(elapsedTime < time2)
                        GwQuestTrackerTimer.chestoverlay.chest3:SetShown(elapsedTime < time3)
                        if elapsedTime < timeLimit then
                            GwQuestTrackerTimer.timerString:SetText(SecondsToClock(timeLimit - elapsedTime))
                            GwQuestTrackerTimer.timerString:SetTextColor(1, 1, 1)
                        else
                            GwQuestTrackerTimer.timerString:SetText(SecondsToClock(0))
                            GwQuestTrackerTimer.timerString:SetTextColor(255, 0, 0)
                        end
                        if elapsedTime < time3 then
                            GwQuestTrackerTimer.timerStringChest3:SetText(SecondsToClock(time3 - elapsedTime))
                            GwQuestTrackerTimer.timerStringChest2:SetText(SecondsToClock(time2 - elapsedTime))
                            GwQuestTrackerTimer.timerStringChest3:Show()
                            GwQuestTrackerTimer.timerStringChest2:Show()
                        elseif elapsedTime < time2 then
                            GwQuestTrackerTimer.timerStringChest2:SetText(SecondsToClock(time2 - elapsedTime))
                            GwQuestTrackerTimer.timerStringChest2:Show()
                            GwQuestTrackerTimer.timerStringChest3:Hide()
                        else
                            GwQuestTrackerTimer.timerStringChest2:Hide()
                            GwQuestTrackerTimer.timerStringChest3:Hide()
                        end
                    end
                )
                GwQuestTrackerTimer.timer:Show()
                GwQuestTrackerTimer.height = GwQuestTrackerTimer.height + 50
                scenarioAffixes()
                scenarioTimerUpdateDeathCounter(GwQuestTrackerTimer)
                return
            end
        elseif (wtype == LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND) then
            local _, _, _, duration = C_Scenario.GetProvingGroundsInfo()
            if (duration > 0) then
                --    Scenario_ProvingGrounds_ShowBlock(timerID, elapsedTime, duration, diffID, currWave, maxWave);
                GwQuestTrackerTimer:SetScript(
                    "OnUpdate",
                    function()
                        local _, elapsedTime, _ = GetWorldElapsedTime(timerID)
                        GwQuestTrackerTimer.timer:SetValue(1 - (elapsedTime / duration))
                        GwQuestTrackerTimer.timerString:SetText(SecondsToClock(duration - elapsedTime))
                    end
                )
                GwQuestTrackerTimer.timer:Show()
                GwQuestTrackerTimer.height = GwQuestTrackerTimer.height + 40
                return
            end
        end
    end
    GwQuestTrackerTimer.timer:Hide()
    GwQuestTrackerTimer.timerStringChest2:Hide()
    GwQuestTrackerTimer.timerStringChest3:Hide()
    GwQuestTrackerTimer.chestoverlay:Hide()
    GwQuestTrackerTimer.deathcounter:Hide()
    GwQuestTrackerTimer:SetScript("OnUpdate", nil)

    for _, v in ipairs(GwQuestTrackerTimer.affixes.affixes) do
        v.affixID = nil
        v.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-boss")
    end
    GwQuestTrackerTimer.affixes:Hide()
end
GW.AddForProfiling("scenario", "scenarioTimerUpdate", scenarioTimerUpdate)

local function scenarioTimerOnEvent(_, event, ...)
    if (event == "PLAYER_ENTERING_WORLD" or event == nil) then
        -- ScenarioTimer_CheckTimers(GetWorldElapsedTimers());
        scenarioTimerUpdate(GetWorldElapsedTimers())
        scenarioTimerUpdateDeathCounter(GwQuestTrackerTimer)
    elseif (event == "WORLD_STATE_TIMER_START") then
        local timerID = ...
        scenarioTimerUpdate(timerID)
    elseif (event == "WORLD_STATE_TIMER_STOP") then
        scenarioTimerStop()
    elseif (event == "PROVING_GROUNDS_SCORE_UPDATE") then
        --elseif (event == "SPELL_UPDATE_COOLDOWN") then
        --    ScenarioSpellButtons_UpdateCooldowns();
        local score = ...
        GwQuestTrackerTimer.score.scoreString:SetText(score)
        GwQuestTrackerTimer.score:Show()
        GwQuestTrackerTimer.height = GwQuestTrackerTimer.height + 40
    elseif (event == "CHALLENGE_MODE_START" or event == "CHALLENGE_MODE_COMPLETED" or event == "CHALLENGE_MODE_MAPS_UPDATE" or event == "ZONE_CHANGED") then
        scenarioTimerUpdate(GetWorldElapsedTimers())
    elseif event == "CHALLENGE_MODE_DEATH_COUNT_UPDATED" then
        scenarioTimerUpdateDeathCounter(GwQuestTrackerTimer)
    end
    GwQuestTrackerTimer:SetHeight(GwQuestTrackerTimer.height)

    updateCurrentScenario(GwQuesttrackerContainerScenario)
end
GW.AddForProfiling("scenario", "scenarioTimerOnEvent", scenarioTimerOnEvent)

local function LoadScenarioFrame()
    GwQuesttrackerContainerScenario:SetScript("OnEvent", updateCurrentScenario)

    GwQuesttrackerContainerScenario:RegisterEvent("PLAYER_ENTERING_WORLD")
    GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_UPDATE")
    GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    GwQuesttrackerContainerScenario:RegisterEvent("LOOT_CLOSED")
    GwQuesttrackerContainerScenario:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    GwQuesttrackerContainerScenario:RegisterEvent("UPDATE_UI_WIDGET")

    GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED_INDOORS")
    GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED")
    GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_COMPLETED")
    GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_SPELL_UPDATE")
    GwQuesttrackerContainerScenario:RegisterEvent("JAILERS_TOWER_LEVEL_UPDATE")

    GwQuesttrackerContainerScenario.jailersTowerType = nil

    -- JailersTower hook
    -- do it only here so we are sure we do not hook more than one time
    hooksecurefunc("ScenarioBlocksFrame_ExtraBlocksSetShown", function(shown)
        if shown and IsInJailersTower() then
            updateCurrentScenario(GwQuesttrackerContainerScenario)
        end
    end)

    local timerBlock = CreateFrame("Button", "GwQuestTrackerTimer", GwQuesttrackerContainerScenario, "GwQuesttrackerScenarioBlock")
    timerBlock.height = timerBlock:GetHeight()
    timerBlock.timerlabel = timerBlock.timer.timerlabel
    timerBlock.timerString = timerBlock.timer.timerString
    timerBlock.timerStringChest2 = timerBlock.timer.timerStringChest2
    timerBlock.timerStringChest3 = timerBlock.timer.timerStringChest3
    timerBlock.timerBackground:ClearAllPoints()
    timerBlock.timerBackground:SetPoint("CENTER", timerBlock.timer, "CENTER")
    timerBlock.timerlabel:SetFont(UNIT_NAME_FONT, 12)
    timerBlock.timerlabel:SetTextColor(1, 1, 1)
    timerBlock.timerlabel:SetShadowOffset(1, -1)
    timerBlock.timerString:SetFont(UNIT_NAME_FONT, 12)
    timerBlock.timerString:SetTextColor(1, 1, 1)
    timerBlock.timerString:SetShadowOffset(1, -1)
    timerBlock.timerStringChest2:SetFont(UNIT_NAME_FONT, 10)
    timerBlock.timerStringChest2:SetTextColor(1, 1, 1)
    timerBlock.timerStringChest2:SetShadowOffset(1, -1)
    timerBlock.timerStringChest2:ClearAllPoints()
    timerBlock.timerStringChest2:SetPoint("RIGHT", timerBlock.chestoverlay.chest2, "LEFT", -2, -6)
    timerBlock.timerStringChest3:SetFont(UNIT_NAME_FONT, 10)
    timerBlock.timerStringChest3:SetTextColor(1, 1, 1)
    timerBlock.timerStringChest3:SetShadowOffset(1, -1)
    timerBlock.timerStringChest3:ClearAllPoints()
    timerBlock.timerStringChest3:SetPoint("RIGHT", timerBlock.chestoverlay.chest3, "LEFT", -2, -6)
    timerBlock.deathcounter:ClearAllPoints()
    timerBlock.deathcounter:SetPoint("LEFT", timerBlock.timer, "RIGHT", -35, -14)
    timerBlock.deathcounter.counterlabel:SetFont(UNIT_NAME_FONT, 10)
    timerBlock.deathcounter.counterlabel:SetTextColor(1, 1, 1)
    timerBlock.deathcounter.counterlabel:SetShadowOffset(1, -1)
    timerBlock.score:ClearAllPoints()
    timerBlock.score:SetPoint("TOPLEFT", timerBlock.timer, "BOTTOMLEFT", 0, 0)
    timerBlock.score.scoreString:SetFont(UNIT_NAME_FONT, 12)
    timerBlock.score.scorelabel:SetFont(UNIT_NAME_FONT, 12)
    timerBlock.timer:SetScript(
        "OnShow",
        function(self)
            self:GetParent().timerBackground:Show()
            self.timerlabel:SetText(TIME_REMAINING)
        end
    )
    timerBlock.timer:SetScript(
        "OnHide",
        function(self)
            self:GetParent().timerBackground:Hide()
        end
    )
    for _, v in ipairs(timerBlock.affixes.affixes) do
        v:SetScript(
            "OnEnter",
            function(self)
                if self.affixID then
                    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 50)
                    GameTooltip:ClearLines()
                    local name, description = C_ChallengeMode.GetAffixInfo(self.affixID)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(name, 1, 1, 1, 1, true)
                    GameTooltip:AddLine(description, nil, nil, nil, true)
                    GameTooltip:Show()
                end
            end
        )
        v:SetScript("OnLeave", GameTooltip_Hide)
    end

    timerBlock.deathcounter:SetScript(
        "OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(CHALLENGE_MODE_DEATH_COUNT_TITLE:format(self.count), 1, 1, 1)
            GameTooltip:AddLine(CHALLENGE_MODE_DEATH_COUNT_DESCRIPTION:format(SecondsToClock(self.timeLost)))
            GameTooltip:Show()
        end
    )
    timerBlock.deathcounter:SetScript("OnLeave", GameTooltip_Hide)

    timerBlock:SetParent(GwQuesttrackerContainerScenario)
    timerBlock:ClearAllPoints()
    timerBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerScenario, "TOPRIGHT", 0, 0)

    timerBlock:RegisterEvent("PLAYER_ENTERING_WORLD")
    timerBlock:RegisterEvent("WORLD_STATE_TIMER_START")
    timerBlock:RegisterEvent("WORLD_STATE_TIMER_STOP")
    timerBlock:RegisterEvent("PROVING_GROUNDS_SCORE_UPDATE")
    --timerBlock:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    timerBlock:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
    timerBlock:RegisterEvent("CHALLENGE_MODE_START")
    timerBlock:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    timerBlock:RegisterEvent("ZONE_CHANGED")
    timerBlock:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED")

    timerBlock:SetScript("OnEvent", scenarioTimerOnEvent)

    local newBlock = CreateTrackerObject("GwScenarioBlock", GwQuesttrackerContainerScenario)
    newBlock:SetParent(GwQuesttrackerContainerScenario)
    newBlock:SetPoint("TOPRIGHT", timerBlock, "BOTTOMRIGHT", 0, 0)
    newBlock.Header:SetText("")

    newBlock.actionButton = CreateFrame("Button", nil, GwQuestTracker, "GwQuestItemTemplate")
    newBlock.actionButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    newBlock.actionButton.NormalTexture:SetTexture(nil)
    newBlock.actionButton:RegisterForClicks("AnyUp", "AnyDown")
    newBlock.actionButton:SetScript("OnShow", QuestObjectiveItem_OnShow)
    newBlock.actionButton:SetScript("OnHide", QuestObjectiveItem_OnHide)
    newBlock.actionButton:SetScript("OnEnter", QuestObjectiveItem_OnEnter)
    newBlock.actionButton:SetScript("OnLeave", GameTooltip_Hide)
    newBlock.actionButton:SetScript("OnEvent", QuestObjectiveItem_OnEvent)

    setBlockColor(newBlock, "SCENARIO")
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)

    C_Timer.After(0.8, function() updateCurrentScenario(GwQuesttrackerContainerScenario) end)

    scenarioTimerOnEvent()
end
GW.LoadScenarioFrame = LoadScenarioFrame
