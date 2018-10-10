local _, GW = ...
local AddTrackerNotification = GW.AddTrackerNotification
local RemoveTrackerNotificationOfType = GW.RemoveTrackerNotificationOfType
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local ParseCriteria = GW.ParseCriteria
local ParseObjectiveString = GW.ParseObjectiveString
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local UpdateQuestItem = GW.UpdateQuestItem

local TIME_FOR_3 = 0.6
local TIME_FOR_2 = 0.8

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
    self.objectiveBlocks[#self.objectiveBlocks] = newBlock
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

    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    return newBlock
end
GW.AddForProfiling("scenario", "getObjectiveBlock", getObjectiveBlock)

local function addObjectiveBlock(block, text, finished, objectiveIndex, objectiveType, quantity)
    local objectiveBlock = getObjectiveBlock(block, objectiveIndex)

    if text then
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText(text)
        if finished then
            objectiveBlock.ObjectiveText:SetTextColor(0.8, 0.8, 0.8)
        else
            objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
        end

        if not ParseObjectiveString(objectiveBlock, text, objectiveType, quantity) then
            objectiveBlock.StatusBar:Hide()
        end
        local h = 20
        if objectiveBlock.StatusBar:IsShown() then
            h = 50
        end
        block.height = block.height + h
        block.numObjectives = block.numObjectives + 1
    end
end
GW.AddForProfiling("scenario", "addObjectiveBlock", addObjectiveBlock)

local function updateCurrentScenario()
    GW.RemoveTrackerNotificationOfType("SCENARIO")

    local compassData = {}

    compassData["TYPE"] = "SCENARIO"
    compassData["TITLE"] = "Unknown Scenario"
    compassData["ID"] = "unknown"
    compassData["QUESTID"] = "unknown"
    compassData["COMPASS"] = false

    compassData["MAPID"] = 0
    compassData["X"] = 0
    compassData["Y"] = 0

    compassData["COLOR"] = TRACKER_TYPE_COLOR["SCENARIO"]

    local delayUpdateTime = GetTime() + 0.8
    GwQuesttrackerContainerScenario:SetScript(
        "OnUpdate",
        function()
            if GetTime() < delayUpdateTime then
                return
            end
            updateCurrentScenario()
            GwQuesttrackerContainerScenario:SetScript("OnUpdate", nil)
        end
    )

    GwScenarioBlock.height = 1

    if GwQuestTrackerTimer:IsShown() then
        GwScenarioBlock.height = GwQuestTrackerTimer.height
    end

    GwScenarioBlock.numObjectives = 0
    GwScenarioBlock:Show()

    local _, _, numStages, _ = C_Scenario.GetInfo()
    if (numStages == 0) then
        local name, instanceType, _, difficultyName, _ = GetInstanceInfo()
        if instanceType == "raid" then
            compassData["TITLE"] = name
            compassData["DESC"] = difficultyName
            GW.AddTrackerNotification(compassData)
        else
            GW.RemoveTrackerNotificationOfType("SCENARIO")
            GwScenarioBlock:Hide()
        end
        UpdateQuestItem(GwScenarioItemButton, 0)
        for i = GwScenarioBlock.numObjectives + 1, 20 do
            if _G[GwScenarioBlock:GetName() .. "GwQuestObjective" .. i] ~= nil then
                _G[GwScenarioBlock:GetName() .. "GwQuestObjective" .. i]:Hide()
            end
        end

        GwScenarioBlock.height = GwScenarioBlock.height + 5

        GwScenarioBlock:SetHeight(GwScenarioBlock.height)
        GwQuesttrackerContainerScenario:SetHeight(GwScenarioBlock.height)
        return
    end

    local stageName, stageDescription, numCriteria, _, _, _, _, _, _, questID = C_Scenario.GetStepInfo()

    local _, _, _, difficultyName, _ = GetInstanceInfo()
    if stageDescription == nil then
        stageDescription = ""
    end
    if stageName == nil then
        stageName = ""
    end
    if difficultyName ~= nil then
        local level, _, _ = C_ChallengeMode.GetActiveKeystoneInfo()
        if level > 0 then
            compassData["TITLE"] = stageName .. " |cFFFFFFFF +" .. level .. " " .. difficultyName .. "|r"
        else
            compassData["TITLE"] = stageName .. " |cFFFFFFFF " .. difficultyName .. "|r"
        end
        compassData["DESC"] = stageDescription .. " "
        GW.AddTrackerNotification(compassData)
    end
    --

    --[[
	local inChallengeMode = bit.band(flags, SCENARIO_FLAG_CHALLENGE_MODE) == SCENARIO_FLAG_CHALLENGE_MODE;
	local inProvingGrounds = bit.band(flags, SCENARIO_FLAG_PROVING_GROUNDS) == SCENARIO_FLAG_PROVING_GROUNDS;
	local dungeonDisplay = bit.band(flags, SCENARIO_FLAG_USE_DUNGEON_DISPLAY) == SCENARIO_FLAG_USE_DUNGEON_DISPLAY;
    --]]
    local questLogIndex = 0

    if questID ~= nil then
        questLogIndex = GetQuestLogIndexByID(questID)
    end

    UpdateQuestItem(GwScenarioItemButton, questLogIndex)

    for criteriaIndex = 1, numCriteria do
        local criteriaString, _, _, quantity, totalQuantity, _, _, _, _, _, _, _, isWeightedProgress =
            C_Scenario.GetCriteriaInfo(criteriaIndex)
        local objectiveType = "progressbar"
        if not isWeightedProgress then
            objectiveType = "monster"
        end
        if objectiveType == "progressbar" then
            totalQuantity = 100
        end
        addObjectiveBlock(
            GwScenarioBlock,
            ParseCriteria(quantity, totalQuantity, criteriaString),
            false,
            criteriaIndex,
            objectiveType,
            quantity
        )
    end

    local bonusSteps = C_Scenario.GetBonusSteps()
    for k, v in pairs(bonusSteps) do
        bonusStepIndex = v
        --[[
        local scenarioName, currentStage, numStages, flags, _, _, completed, xp, money =
            C_Scenario.GetInfo(bonusStepIndex)
        --]]
        local _, _, numCriteria = C_Scenario.GetStepInfo(bonusStepIndex)
        for criteriaIndex = 1, numCriteria do
            if criteriaIndex == 1 then
                addObjectiveBlock(
                    GwScenarioBlock,
                    ParseCriteria(quantity, totalQuantity, criteriaString),
                    false,
                    criteriaIndex,
                    objectiveType,
                    quantity
                )
            end

            local criteriaString, _, _, quantity, totalQuantity, _ =
                C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex)

            local objectiveType = "progressbar"
            if not isWeightedProgress then
                objectiveType = "monster"
            end
            addObjectiveBlock(
                GwScenarioBlock,
                ParseCriteria(quantity, totalQuantity, criteriaString),
                false,
                criteriaIndex,
                objectiveType,
                quantity
            )
        end
    end

    for i = GwScenarioBlock.numObjectives + 1, 20 do
        if _G[GwScenarioBlock:GetName() .. "GwQuestObjective" .. i] ~= nil then
            _G[GwScenarioBlock:GetName() .. "GwQuestObjective" .. i]:Hide()
        end
    end

    GwScenarioBlock.height = GwScenarioBlock.height + 5

    local intGWQuestTrackerHeight
    intGWQuestTrackerHeight = 0

    if _G["GwAffixFrame"]:IsShown() then
        intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40
    end
    if GwQuestTrackerTimer.timer:IsShown() then
        intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40
    end

    GwScenarioBlock:SetHeight(GwScenarioBlock.height - intGWQuestTrackerHeight)
    GwQuesttrackerContainerScenario:SetHeight(GwScenarioBlock.height)
end
GW.AddForProfiling("scenario", "updateCurrentScenario", updateCurrentScenario)

local function scenarioTimerStop()
    GwQuestTrackerTimer:SetScript("OnUpdate", nil)
    GwQuestTrackerTimer.timer:Hide()
    GwQuestTrackerTimer.timerStringChest2:Hide()
    GwQuestTrackerTimer.timerStringChest3:Hide()
    GwQuestTrackerTimer.chestoverlay:Hide()
    GwQuestTrackerTimer.deathcounter:Hide()
end
GW.AddForProfiling("scenario", "scenarioTimerStop", scenarioTimerStop)

local function scenarioAffixes()
    local _, affixes, _ = C_ChallengeMode.GetActiveKeystoneInfo()
    local i = 1
    for k, v in pairs(affixes) do
        if i == 1 then
            GwQuestTrackerTimer.height = GwQuestTrackerTimer.height + 40
            GwQuestTrackerTimer.timer:ClearAllPoints()
            GwQuestTrackerTimer.timer:SetPoint("TOPLEFT", GwQuestTrackerTimer.affixes, "BOTTOMLEFT", -10, -15)
        end
        local affixID = v
        local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID)

        if filedataid ~= nil then
            SetPortraitToTexture(_G["GwAffixFrame" .. i .. "Icon"], filedataid)
        end
        _G["GwAffixFrame" .. i].affixID = affixID
        _G["GwAffixFrame" .. i]:Show()
        _G["GwAffixFrame" .. i .. "Icon"]:Show()
        _G["GwAffixFrame"]:Show()
        i = i + 1
    end

    if i == 1 then
        GwQuestTrackerTimer.timer:ClearAllPoints()
        GwQuestTrackerTimer.timer:SetPoint("TOPRIGHT", GwQuestTrackerTimer.affixes, "BOTTOMRIGHT", -10, 20)
        for k = 1, 4 do
            _G["GwAffixFrame" .. k].affixID = nil
            _G["GwAffixFrame" .. k .. "Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icon-boss")
        end
        _G["GwAffixFrame"]:Hide()
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
    local hasUpdatedAffixes = false

    for i = 1, select("#", ...) do
        local timerID = select(i, ...)
        local _, _, wtype = GetWorldElapsedTime(timerID)
        if (wtype == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE) then
            --local _, _, _, _, _, _, _, mapID = GetInstanceInfo();
            local mapID = C_ChallengeMode.GetActiveChallengeMapID()
            if (mapID) then
                local _, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
                local time3 = timeLimit * TIME_FOR_3
	            local time2 = timeLimit * TIME_FOR_2
                --	Scenario_ChallengeMode_ShowBlock(timerID, elapsedTime, timeLimit);
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
                            GwQuestTrackerTimer.timerString:SetText(GetTimeStringFromSeconds(timeLimit - elapsedTime, false, true))
                            GwQuestTrackerTimer.timerString:SetTextColor(1, 1, 1)
                        else
                            GwQuestTrackerTimer.timerString:SetText(GetTimeStringFromSeconds(0, false, true))
                            GwQuestTrackerTimer.timerString:SetTextColor(255, 0, 0)
                        end
                        if elapsedTime < time3 then
                            GwQuestTrackerTimer.timerStringChest3:SetText(GetTimeStringFromSeconds(time3 - elapsedTime, false, true))
                            GwQuestTrackerTimer.timerStringChest2:SetText(GetTimeStringFromSeconds(time2 - elapsedTime, false, true))
                            GwQuestTrackerTimer.timerStringChest3:Show()
                            GwQuestTrackerTimer.timerStringChest2:Show()
                        elseif elapsedTime < time2 then
                            GwQuestTrackerTimer.timerStringChest2:SetText(GetTimeStringFromSeconds(time2 - elapsedTime, false, true))
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
                --	Scenario_ProvingGrounds_ShowBlock(timerID, elapsedTime, duration, diffID, currWave, maxWave);
                GwQuestTrackerTimer:SetScript(
                    "OnUpdate",
                    function()
                        local _, elapsedTime, _ = GetWorldElapsedTime(timerID)
                        GwQuestTrackerTimer.timer:SetValue(1 - (elapsedTime / duration))
                        GwQuestTrackerTimer.timerString:SetText(
                            GetTimeStringFromSeconds(duration - elapsedTime, false, true)
                        )
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

    if hasUpdatedAffixes == false then
        for i = 1, 4 do
            _G["GwAffixFrame" .. i].affixID = nil
            _G["GwAffixFrame" .. i .. "Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icon-boss")
        end
        _G["GwAffixFrame"]:Hide()
    end
end
GW.AddForProfiling("scenario", "scenarioTimerUpdate", scenarioTimerUpdate)

local function scenarioTimerOnEvent(self, event, ...)
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
        --	ScenarioSpellButtons_UpdateCooldowns();
        local score = ...
        GwQuestTrackerTimer.score.scoreString:SetText(score)
        GwQuestTrackerTimer.score:Show()
        GwQuestTrackerTimer.height = GwQuestTrackerTimer.height + 40
    elseif
        (event == "CHALLENGE_MODE_START" or event == "CHALLENGE_MODE_COMPLETED" or event == "CHALLENGE_MODE_MAPS_UPDATE" or
            event == "ZONE_CHANGED")
     then
        scenarioTimerUpdate(GetWorldElapsedTimers())
    elseif event == "CHALLENGE_MODE_DEATH_COUNT_UPDATED" then
        scenarioTimerUpdateDeathCounter(GwQuestTrackerTimer)
    end
    GwQuestTrackerTimer:SetHeight(GwQuestTrackerTimer.height)

    updateCurrentScenario()
end
GW.AddForProfiling("scenario", "scenarioTimerOnEvent", scenarioTimerOnEvent)

local function LoadScenarioFrame()
    GwQuesttrackerContainerScenario:SetScript("OnEvent", updateCurrentScenario)

    GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_UPDATE")
    GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_CRITERIA_UPDATE")

    GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED_INDOORS")
    GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    GwQuesttrackerContainerScenario:RegisterEvent("ZONE_CHANGED")
    GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_COMPLETED")
    GwQuesttrackerContainerScenario:RegisterEvent("SCENARIO_SPELL_UPDATE")

    local timerBlock =
        CreateFrame("Button", "GwQuestTrackerTimer", GwQuesttrackerContainerScenario, "GwQuesttrackerScenarioBlock")
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
    timerBlock.timer:ClearAllPoints()
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
    timerBlock.affixes["1"]:SetScript(
        "OnEnter",
        function(self)
            if self.affixID ~= nil then
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
    timerBlock.affixes["1"]:SetScript("OnLeave", GameTooltip_Hide)
    timerBlock.affixes["2"]:SetScript(
        "OnEnter",
        function(self)
            if self.affixID ~= nil then
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
    timerBlock.affixes["2"]:SetScript("OnLeave", GameTooltip_Hide)
    timerBlock.affixes["3"]:SetScript(
        "OnEnter",
        function(self)
            if self.affixID ~= nil then
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
    timerBlock.affixes["3"]:SetScript("OnLeave", GameTooltip_Hide)
    timerBlock.affixes["4"]:SetScript(
        "OnEnter",
        function(self)
            if self.affixID ~= nil then
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
    timerBlock.affixes["4"]:SetScript("OnLeave", GameTooltip_Hide)
    timerBlock.deathcounter:SetScript(
        "OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	        GameTooltip:SetText(CHALLENGE_MODE_DEATH_COUNT_TITLE:format(self.count), 1, 1, 1)
	        GameTooltip:AddLine(CHALLENGE_MODE_DEATH_COUNT_DESCRIPTION:format(GetTimeStringFromSeconds(self.timeLost, false, true)))
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
    timerBlock:RegisterEvent("SPELL_UPDATE_COOLDOWN")
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

    newBlock.color = TRACKER_TYPE_COLOR["SCENARIO"]
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    updateCurrentScenario()
    scenarioTimerOnEvent()
end
GW.LoadScenarioFrame = LoadScenarioFrame
