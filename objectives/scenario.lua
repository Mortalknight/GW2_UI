local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local TIME_FOR_3 = 0.6
local TIME_FOR_2 = 0.8

local allowedWidgetUpdateIdsForTimer = {
    [3302] = true, -- DF cooking event
    [5527] = true, -- DF archeolgy event
    [6183] = true, -- TWW delve
    [5483] = true, -- TWW theather event
    [5865] = true, -- TWW echos
    [5986] = true, -- 20th
    [5990] = true, -- 20th
    [5991] = true, -- 20th
}

local allowedWidgetUpdateIdsForStatusBar = {
    [6350] = true, -- 20th
    [6758] = true, -- 11.1
}

GwObjectivesScenarioContainerMixin = {}
GwQuesttrackerScenarioBlockMixin = {}

function GwObjectivesScenarioContainerMixin:UpdateLayout(event, ...)
    if event == "UPDATE_UI_WIDGET" then
        local w = ...
        if not (w and (allowedWidgetUpdateIdsForTimer[w.widgetID] or allowedWidgetUpdateIdsForStatusBar[w.widgetID])) then
            return
        end
    end

    GwObjectivesNotification:RemoveNotificationOfType("SCENARIO")
    GwObjectivesNotification:RemoveNotificationOfType("TORGHAST")
    GwObjectivesNotification:RemoveNotificationOfType("DELVE")

    local compassData = {
        TYPE = "SCENARIO",
        TITLE = "Unknown Scenario",
        ID = "unknown",
        QUESTID = "unknown",
        COMPASS = false,
        MAPID = nil,
        X = nil,
        Y = nil,
        COLOR = TRACKER_TYPE_COLOR.SCENARIO,
    }

    local block = self.block
    local timerBlock = self.timerBlock
    local containerName = self.block:GetName()
    local showTimerAsBonus = false
    local GwQuestTrackerTimerSavedHeight = 1
    local isEmberCourtWidget = false
    local isEventTimerBarByWidgetId = false

    block.height = 1

    if timerBlock:IsShown() then
        block.height = timerBlock.height
    end

    block.numObjectives = 0
    block.questLogIndex = 0
    block.groupButton:Hide()
    block:Show()

    -- here we show only the statusbar
    for id in pairs(allowedWidgetUpdateIdsForStatusBar) do
        local widgetInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(id)
        if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
            block:AddObjective(GW.ParseCriteria(widgetInfo.barValue, widgetInfo.barMax, widgetInfo.text), 1, { finished = false, objectiveType = "object", qty = widgetInfo.barValue, firstObjectivesYValue = -5 })

            for i = block.numObjectives + 1, 20 do
                if _G[containerName .. "Objective" .. i] then
                    _G[containerName .. "Objective" .. i]:Hide()
                end
            end

            compassData.TITLE = widgetInfo.text
            compassData.DESC = widgetInfo.text
            GwObjectivesNotification:AddNotification(compassData)
            block:SetHeight(block.height)
            self.oldHeight = GW.RoundInt(self:GetHeight())
            self:SetHeight(block.height)
            timerBlock.timer:Hide()
            GW.TerminateScenarioWidgetTimer()
            return
        end
    end

    local _, _, numStages, _, _, _, _, _, _, _, _, _, scenarioID = C_Scenario.GetInfo()
    if numStages == 0 or IsOnGroundFloorInJailersTower() then
        local name, instanceType, _, difficultyName, _ = GetInstanceInfo()
        if instanceType == "raid" then
            compassData.TITLE = name
            compassData.DESC = difficultyName
            GwObjectivesNotification:AddNotification(compassData)
            block.height = block.height + 5
        else
            GwObjectivesNotification:RemoveNotificationOfType("SCENARIO")
            GwObjectivesNotification:RemoveNotificationOfType("TORGHAST")
            block:Hide()
        end
        GW.CombatQueue_Queue(nil, block.UpdateObjectiveActionButton, {block})
        if block.hasItem then
            block.fromContainerTopHeight = block.height
            GW.CombatQueue_Queue("update_tracker_scenario_itembutton_position", block.UpdateObjectiveActionButtonPosition, {block, "SCENARIO"})
        end
        for i = block.numObjectives + 1, 20 do
            if _G[containerName .. "Objective" .. i] then
                _G[containerName .. "Objective" .. i]:Hide()
            end
        end

        block:SetHeight(block.height)
        self.oldHeight = GW.RoundInt(self:GetHeight())
        self:SetHeight(block.height)
        timerBlock.timer:Hide()
        GW.TerminateScenarioWidgetTimer()

        return
    end

    local stageName, stageDescription, numCriteria, _, _, _, _, _, _, questID = C_Scenario.GetStepInfo()
    local _, _, difficultyID, difficultyName = GetInstanceInfo()
    local isMythicKeystone = difficultyID == 8
    stageDescription = stageDescription or ""
    stageName = stageName or ""
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

        if self.jailersTowerLevelUpdateInfo and self.jailersTowerLevelUpdateInfo.type then
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

    -- check for active delves
    local delvesWidgetInfo = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6183)
    if delvesWidgetInfo and delvesWidgetInfo.frameTextureKit == "delves-scenario" then
        local tierLevel = delvesWidgetInfo.tierText or ""
        GwObjectivesNotification.iconFrame.tooltipSpellID = delvesWidgetInfo.tierTooltipSpellID
        compassData.TITLE = difficultyName .. " |cFFFFFFFF(" .. tierLevel .. ")|r - " .. delvesWidgetInfo.headerText
        block.delvesFrame:Show()
        block.delvesFrame.reward:Show()
        local id = 1
        for _, spellInfo in ipairs(delvesWidgetInfo.spells) do
            if spellInfo.shownState ~= Enum.WidgetShownState.Hidden then
                local spellData = C_Spell.GetSpellInfo(spellInfo.spellID)
                local spellBlock = block.delvesFrame.spell[id]
                spellBlock.icon:SetTexture(spellData.iconID)
                if not spellBlock.mask then
                    spellBlock.mask = spellBlock:CreateMaskTexture()
                    spellBlock.mask:SetAllPoints(spellBlock.icon)
                    spellBlock.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                    spellBlock.icon:AddMaskTexture(spellBlock.mask)
                end
                spellBlock.icon:SetDesaturated(spellInfo.enabledState == Enum.WidgetEnabledState.Disabled)
                spellBlock.spellID = spellData.spellID
                spellBlock:Show()
                id = id + 1
            end
        end

        for i = id, 5 do
            block.delvesFrame.spell[i].spellID = nil
            block.delvesFrame.spell[i]:Hide()
        end

        -- handle death
        if delvesWidgetInfo.currencies and #delvesWidgetInfo.currencies > 0 and delvesWidgetInfo.currencies[1].textEnabledState > 0 then
            block.delvesFrame.deathCounter.tooltip = delvesWidgetInfo.currencies[1].tooltip
            block.delvesFrame.deathCounter.counter:SetText(delvesWidgetInfo.currencies[1].text)
            block.delvesFrame.deathCounter.icon:SetTexture(delvesWidgetInfo.currencies[1].iconFileID)
            block.delvesFrame.deathCounter:Show()
        else
            block.delvesFrame.deathCounter:Hide()
        end

        -- handle rewards
        if delvesWidgetInfo.rewardInfo.shownState ~= Enum.UIWidgetRewardShownState.Hidden then
            local rewardTooltip = (delvesWidgetInfo.rewardInfo.shownState == Enum.UIWidgetRewardShownState.ShownEarned) and delvesWidgetInfo.rewardInfo.earnedTooltip or delvesWidgetInfo.rewardInfo.unearnedTooltip
            block.delvesFrame.reward.tooltip = rewardTooltip
            block.delvesFrame.reward.earned:SetShown(delvesWidgetInfo.rewardInfo.shownState == Enum.UIWidgetRewardShownState.ShownEarned)
            block.delvesFrame.reward.unearned:SetShown(delvesWidgetInfo.rewardInfo.shownState == Enum.UIWidgetRewardShownState.ShownUnearned)
            block.delvesFrame.reward:Show()
        else
            block.delvesFrame.reward:Hide()
        end

        compassData.COLOR = TRACKER_TYPE_COLOR.DELVE
        compassData.TYPE = "DELVE"
    else
        block.delvesFrame:Hide()
    end

    block:SetBlockColorByKey(compassData.TYPE)
    block.Header:SetTextColor(block.color.r, block.color.g, block.color.b)
    block.hover:SetVertexColor(block.color.r, block.color.g, block.color.b)
    GwObjectivesNotification:AddNotification(compassData, true)

    if questID then
        block.questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    end

    --check for groupfinder button
    block:UpdateFindGroupButton(scenarioID)

    GW.CombatQueue_Queue(nil, block.UpdateObjectiveActionButton, {block})

    for criteriaIndex = 1, numCriteria do
        local scenarioCriteriaInfo = C_ScenarioInfo.GetCriteriaInfo(criteriaIndex)
        if scenarioCriteriaInfo then
            local objectiveType = scenarioCriteriaInfo.isWeightedProgress and "progressbar" or "monster"

            if objectiveType == "progressbar" and not isMythicKeystone then
                scenarioCriteriaInfo.totalQuantity = 100
            end

            local mythicKeystoneCurrentValue = 0
            if isMythicKeystone then
                mythicKeystoneCurrentValue = tonumber(string.match(scenarioCriteriaInfo.quantityString, "%d+")) or 1
            end
            block:AddObjective(GW.ParseCriteria(scenarioCriteriaInfo.quantity, scenarioCriteriaInfo.totalQuantity, scenarioCriteriaInfo.description, isMythicKeystone, mythicKeystoneCurrentValue, scenarioCriteriaInfo.isWeightedProgress), criteriaIndex, { finished = false, objectiveType = objectiveType, qty = scenarioCriteriaInfo.quantity, isMythicKeystone = isMythicKeystone, firstObjectivesYValue = -5 })
        end
    end
    -- add special widgets here
    numCriteria = GW.addWarfrontData(block, numCriteria)
    numCriteria = GW.addHeroicVisionsData(block, numCriteria)
    numCriteria = GW.addJailersTowerData(block, numCriteria)

    if not showTimerAsBonus then
        numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget = GW.addEmberCourtData(self, numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget)
    end
    for id, _ in pairs(allowedWidgetUpdateIdsForTimer) do
        if not showTimerAsBonus then
            GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEventTimerBarByWidgetId = GW.addEventTimerBarByWidgetId(timerBlock, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEventTimerBarByWidgetId, id)
        end
    end

    local bonusSteps = C_Scenario.GetBonusSteps() or {}
    local numCriteriaPrev = numCriteria

    for _, v in pairs(bonusSteps) do
        local bonusStepIndex = v
        local _, _, numCriteriaForStep = C_Scenario.GetStepInfo(bonusStepIndex)

        for criteriaIndex = 1, numCriteriaForStep do
            local scenarioCriteriaInfo = C_ScenarioInfo.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex)
            local objectiveType = scenarioCriteriaInfo.isWeightedProgress and "progressbar" or "monster"

            -- timer bar
            if scenarioCriteriaInfo.duration > 0 and scenarioCriteriaInfo.elapsed <= scenarioCriteriaInfo.duration and not (scenarioCriteriaInfo.failed or scenarioCriteriaInfo.completed) then
                timerBlock:SetScript(
                    "OnUpdate",
                    function()
                        local info = C_ScenarioInfo.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex)
                        if info.elapsed and info.elapsed > 0 then
                            timerBlock.timer:SetValue(1 - (info.elapsed / scenarioCriteriaInfo.duration))
                            timerBlock.timerString:SetText(SecondsToClock(scenarioCriteriaInfo.duration - info.elapsed))
                        else
                            timerBlock:SetScript("OnUpdate", nil)
                        end
                    end
                )
                timerBlock.timer:Show()
                timerBlock.needToShowTimer = true
                GwQuestTrackerTimerSavedHeight = GwQuestTrackerTimerSavedHeight + 40
                showTimerAsBonus = true
            elseif not showTimerAsBonus then
                GwQuestTrackerTimerSavedHeight = 1
                timerBlock:SetScript("OnUpdate", nil)
                timerBlock.timer:Hide()
                block:AddObjective(GW.ParseCriteria(scenarioCriteriaInfo.quantity, scenarioCriteriaInfo.totalQuantity, scenarioCriteriaInfo.description), numCriteriaPrev + criteriaIndex, { finished = false, objectiveType = objectiveType, qty = scenarioCriteriaInfo.quantity, firstObjectivesYValue = -5 })
            end
        end
        numCriteriaPrev = numCriteriaPrev + numCriteriaForStep
    end

    for i = block.numObjectives + 1, 20 do
        if _G[containerName.. "Objective" .. i] then
            _G[containerName .. "Objective" .. i]:Hide()
        end
    end

    block.height = block.height + 5
    if block.hasItem then
        block.fromContainerTopHeight = block.height
        GW.CombatQueue_Queue("update_tracker_scenario_itembutton_position", block.UpdateObjectiveActionButtonPosition, {block, "SCENARIO"})
    end

    local intGWQuestTrackerHeight = 0
    if timerBlock.affixeFrame:IsShown() then intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40 end
    if timerBlock.timer:IsShown() then intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40 end

    if showTimerAsBonus or isEmberCourtWidget or isEventTimerBarByWidgetId then
        timerBlock.height = GwQuestTrackerTimerSavedHeight
    end

    timerBlock:SetHeight(timerBlock.height)
    block:SetHeight(block.height - intGWQuestTrackerHeight)
    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(block.height)
end

function GwQuesttrackerScenarioBlockMixin:UpdateFindGroupButton(scenarioID)
    local hasButton = C_LFGList.CanCreateScenarioGroup(scenarioID)
    if hasButton then
		self.groupButton:SetUp(scenarioID)
		self.groupButton:Show()
	else
		self.groupButton:Hide()
	end
end

function GwQuesttrackerScenarioBlockMixin:UpdateAffixes(fakeIds)
    local _, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
    affixes = fakeIds and #fakeIds > 0 and fakeIds or affixes

    for idx, v in pairs(affixes) do
        local affix = self.affixeFrame.affixes[idx]
        local _, _, filedataid = C_ChallengeMode.GetAffixInfo(v)
        if idx == 1 then self.height = self.height + 40 end
        if filedataid then
            affix.icon:SetTexture(filedataid)
            if not affix.mask then
                affix.mask = affix:CreateMaskTexture()
                affix.mask:SetAllPoints(affix.icon)
                affix.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                affix.icon:AddMaskTexture(affix.mask)
            end
        end
        affix.affixID = v
        affix:Show()
        self.affixeFrame:Show()
        self.affixeFrame:SetHeight(40) -- needed for anchor points
    end

    if not affixes or (#affixes == 0) then
        for _, v in ipairs(self.affixeFrame.affixes) do
            v.affixID = nil
            v.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-boss")
        end
        self.affixeFrame:Hide()
        self.affixeFrame:SetHeight(1) -- needed for anchor points
    end
end

function GwQuesttrackerScenarioBlockMixin:UpdateDeathCounter()
    local count, timeLost = C_ChallengeMode.GetDeathCount()
    self.deathcounter.count = count
    self.deathcounter.timeLost = timeLost
    if timeLost and timeLost > 0 and count and count > 0 then
        self.deathcounter.counterlabel:SetText(count)
        self.deathcounter:Show()
    else
        self.deathcounter:Hide()
    end
end

function GwQuesttrackerScenarioBlockMixin:TimerStop()
    self:SetScript("OnUpdate", nil)
    self.timer:Hide()
    self.chestoverlay:Hide()
    self.deathcounter:Hide()
end

function GwQuesttrackerScenarioBlockMixin:TimerUpdate(...)
    self.height = 1
    local fake = false
    if fake then
        self.timer:Show()
        self.needToShowTimer = true
        self.height = self.height + 50
        self:UpdateAffixes({146})
        self:UpdateDeathCounter()
        self.chestoverlay:Show()
        self.chestoverlay.chest2:Show()
        self.chestoverlay.chest3:Show()
        self.chestoverlay.timerStringChest3:Show()
        self.chestoverlay.timerStringChest2:Show()

        return
    end

    for i = 1, select("#", ...) do
        local timerID = select(i, ...)
        local _, _, wtype = GetWorldElapsedTime(timerID)
        if wtype == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE then
            local mapID = C_ChallengeMode.GetActiveChallengeMapID()
            if mapID then
                local _, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
                local time3 = timeLimit * TIME_FOR_3
                local time2 = timeLimit * TIME_FOR_2
                self.chestoverlay:Show()
                self:SetScript("OnUpdate", function()
                    local _, elapsedTime = GetWorldElapsedTime(timerID)
                    self.timer:SetValue(1 - (elapsedTime / timeLimit))
                    self.chestoverlay.chest2:SetShown(elapsedTime < time2)
                    self.chestoverlay.chest3:SetShown(elapsedTime < time3)
                    if elapsedTime < timeLimit then
                        self.timerString:SetText(SecondsToClock(timeLimit - elapsedTime))
                        self.timerString:SetTextColor(1, 1, 1)
                    else
                        self.timerString:SetText(SecondsToClock(0))
                        self.timerString:SetTextColor(255, 0, 0)
                    end
                    if elapsedTime < time3 then
                        self.chestoverlay.timerStringChest3:SetText(SecondsToClock(time3 - elapsedTime))
                        self.chestoverlay.timerStringChest2:SetText(SecondsToClock(time2 - elapsedTime))
                        self.chestoverlay.timerStringChest3:Show()
                        self.chestoverlay.timerStringChest2:Show()
                    elseif elapsedTime < time2 then
                        self.chestoverlay.timerStringChest2:SetText(SecondsToClock(time2 - elapsedTime))
                        self.chestoverlay.timerStringChest2:Show()
                        self.chestoverlay.timerStringChest3:Hide()
                    else
                        self.chestoverlay.timerStringChest2:Hide()
                        self.chestoverlay.timerStringChest3:Hide()
                    end
                end)
                self.timer:Show()
                self.needToShowTimer = true
                self.height = self.height + 50
                self:UpdateAffixes()
                self:UpdateDeathCounter()
                return
            end
        elseif wtype == LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND then
            local _, _, _, duration = C_Scenario.GetProvingGroundsInfo()
            if duration > 0 then
                self:SetScript("OnUpdate", function()
                    local _, elapsedTime, _ = GetWorldElapsedTime(timerID)
                    self.timer:SetValue(1 - (elapsedTime / duration))
                    self.timerString:SetText(SecondsToClock(duration - elapsedTime))
                end)
                self.timer:Show()
                self.needToShowTimer = true
                self.height = self.height + 40
                return
            end
        end
    end

    self.timer:Hide()
    self.chestoverlay:Hide()
    self.deathcounter:Hide()
    self:SetScript("OnUpdate", nil)
    self.needToShowTimer = false

    for _, v in ipairs(self.affixeFrame.affixes) do
        v.affixID = nil
        v.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-boss")
    end
    self.affixeFrame:Hide()
    self.affixeFrame:SetHeight(1) -- needed for anchor points
end

function GwQuesttrackerScenarioBlockMixin:TimerBlockOnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == nil then
        self:TimerUpdate(GetWorldElapsedTimers())
        self:UpdateDeathCounter()
    elseif event == "WORLD_STATE_TIMER_START" then
        local timerID = ...
        self:TimerUpdate(timerID)
    elseif event == "WORLD_STATE_TIMER_STOP" then
        self:TimerStop()
    elseif event == "PROVING_GROUNDS_SCORE_UPDATE" then
        local score = ...
        self.score.scoreString:SetText(score)
        self.score:Show()
        self.height = self.height + 40
    elseif event == "CHALLENGE_MODE_START" or event == "CHALLENGE_MODE_COMPLETED" or event == "CHALLENGE_MODE_MAPS_UPDATE" or event == "ZONE_CHANGED" then
        self:TimerUpdate(GetWorldElapsedTimers())
    elseif event == "CHALLENGE_MODE_DEATH_COUNT_UPDATED" then
        self:UpdateDeathCounter()
    end
    self:SetHeight(self.height)

    self.container:UpdateLayout()
end

local function UIWidgetTemplateTooltipFrameOnEnter(self)
    if self.tooltip then
        self.tooltipContainsHyperLink = false
        self.preString = nil
        self.hyperLinkString = nil
        self.postString = nil
        self.tooltipContainsHyperLink, self.preString, self.hyperLinkString, self.postString = ExtractHyperlinkString(self.tooltip)

        EmbeddedItemTooltip:SetOwner(self, "ANCHOR_LEFT")

        if self.tooltipContainsHyperLink then
            local clearTooltip = true
            if self.preString and self.preString:len() > 0 then
                EmbeddedItemTooltip:AddLine(self.preString, 1, 1, 1, true)
                clearTooltip = false
            end

            GameTooltip_ShowHyperlink(EmbeddedItemTooltip, self.hyperLinkString, 0, 0, clearTooltip)

            if self.postString and self.postString:len() > 0 then
                GameTooltip_AddColoredLine(EmbeddedItemTooltip, self.postString, self.tooltipColor or HIGHLIGHT_FONT_COLOR, true)
            end

            self.UpdateTooltip = self.OnEnter

            EmbeddedItemTooltip:Show()
        else
            local header, nonHeader = SplitTextIntoHeaderAndNonHeader(self.tooltip)
            if header then
                GameTooltip_AddColoredLine(EmbeddedItemTooltip, header, self.tooltipColor or NORMAL_FONT_COLOR, true)
            end
            if nonHeader then
                GameTooltip_AddColoredLine(EmbeddedItemTooltip, nonHeader, self.tooltipColor or NORMAL_FONT_COLOR, true)
            end
            self.UpdateTooltip = nil

            EmbeddedItemTooltip:SetShown(header ~= nil)
        end
    end
end

function GwObjectivesScenarioContainerMixin:InitModule()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("SCENARIO_UPDATE")
    self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    self:RegisterEvent("LOOT_CLOSED")
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("UPDATE_UI_WIDGET")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("SCENARIO_COMPLETED")
    self:RegisterEvent("SCENARIO_SPELL_UPDATE")
    self:RegisterEvent("JAILERS_TOWER_LEVEL_UPDATE")
    self:SetScript("OnEvent", self.UpdateLayout)

    self.jailersTowerType = nil

    -- JailersTower hook
    -- do it only here so we are sure we do not hook more than one time
    hooksecurefunc(ScenarioObjectiveTracker, "SlideInContents", function(container)
        if container:ShouldShowCriteria() and IsInJailersTower() then
            self:UpdateLayout()
        end
    end)

    self.timerBlock = CreateFrame("Button", "GwQuestTrackerTimer", self, "GwQuesttrackerScenarioBlock")
    self.timerBlock.container = self
    self.timerBlock.needToShowTimer = false
    self.timerBlock.height = self.timerBlock:GetHeight()
    self.timerBlock.timerlabel = self.timerBlock.timer.timerlabel
    self.timerBlock.timerString = self.timerBlock.timer.timerString

    self.timerBlock.timerlabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    self.timerBlock.timerlabel:SetTextColor(1, 1, 1)
    self.timerBlock.timerlabel:SetShadowOffset(1, -1)
    self.timerBlock.timerString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    self.timerBlock.timerString:SetTextColor(1, 1, 1)
    self.timerBlock.timerString:SetShadowOffset(1, -1)

    self.timerBlock.chestoverlay.timerStringChest2:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -2)
    self.timerBlock.chestoverlay.timerStringChest2:SetTextColor(1, 1, 1)
    self.timerBlock.chestoverlay.timerStringChest2:SetShadowOffset(1, -1)
    self.timerBlock.chestoverlay.timerStringChest3:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -2)
    self.timerBlock.chestoverlay.timerStringChest3:SetTextColor(1, 1, 1)
    self.timerBlock.chestoverlay.timerStringChest3:SetShadowOffset(1, -1)

    self.timerBlock.chestoverlay.chest2:ClearAllPoints()
    self.timerBlock.chestoverlay.chest3:ClearAllPoints()
    self.timerBlock.chestoverlay.timerStringChest2:ClearAllPoints()
    self.timerBlock.chestoverlay.timerStringChest3:ClearAllPoints()
    self.timerBlock.chestoverlay.chest2:SetPoint("LEFT", self.timerBlock.timer, "LEFT", self.timerBlock.timer:GetWidth() * (1 - TIME_FOR_2) - 1, -6)
    self.timerBlock.chestoverlay.chest3:SetPoint("LEFT", self.timerBlock.timer, "LEFT", self.timerBlock.timer:GetWidth() * (1 - TIME_FOR_3) - 1, -6)
    self.timerBlock.chestoverlay.timerStringChest2:SetPoint("RIGHT", self.timerBlock.chestoverlay.chest2, "LEFT", -2, -6)
    self.timerBlock.chestoverlay.timerStringChest3:SetPoint("RIGHT", self.timerBlock.chestoverlay.chest3, "LEFT", -2, -6)

    self.timerBlock.deathcounter.counterlabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -2)
    self.timerBlock.deathcounter.counterlabel:SetTextColor(1, 1, 1)
    self.timerBlock.deathcounter.counterlabel:SetShadowOffset(1, -1)
    self.timerBlock.score.scoreString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)

    for _, v in ipairs(self.timerBlock.affixeFrame.affixes) do
        v:SetScript("OnEnter", function(affixBlock)
            if affixBlock.affixID then
                GameTooltip:SetOwner(affixBlock, "ANCHOR_BOTTOMLEFT", 0, 50)
                GameTooltip:ClearLines()
                local name, description = C_ChallengeMode.GetAffixInfo(affixBlock.affixID)
                GameTooltip:SetOwner(affixBlock, "ANCHOR_RIGHT")
                GameTooltip:SetText(name, 1, 1, 1, 1, true)
                GameTooltip:AddLine(description, nil, nil, nil, true)
                GameTooltip:Show()
            end
        end)
        v:SetScript("OnLeave", GameTooltip_Hide)
    end

    self.timerBlock.deathcounter:SetScript("OnEnter", function(deathCounterBlock)
            GameTooltip:SetOwner(deathCounterBlock, "ANCHOR_LEFT")
            GameTooltip:SetText(CHALLENGE_MODE_DEATH_COUNT_TITLE:format(deathCounterBlock.count), 1, 1, 1)
            GameTooltip:AddLine(CHALLENGE_MODE_DEATH_COUNT_DESCRIPTION:format(SecondsToClock(deathCounterBlock.timeLost)))
            GameTooltip:Show()
        end)
    self.timerBlock.deathcounter:SetScript("OnLeave", GameTooltip_Hide)

    self.timerBlock:SetParent(self)
    self.timerBlock:ClearAllPoints()
    self.timerBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)

    self.timerBlock:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.timerBlock:RegisterEvent("WORLD_STATE_TIMER_START")
    self.timerBlock:RegisterEvent("WORLD_STATE_TIMER_STOP")
    self.timerBlock:RegisterEvent("PROVING_GROUNDS_SCORE_UPDATE")
    self.timerBlock:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
    self.timerBlock:RegisterEvent("CHALLENGE_MODE_START")
    self.timerBlock:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self.timerBlock:RegisterEvent("ZONE_CHANGED")
    self.timerBlock:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED")
    self.timerBlock:SetScript("OnEvent", self.timerBlock.TimerBlockOnEvent)

    self.block = self:GetBlock(1, "SCENARIO", true)
    self.block:ClearAllPoints()
    self.block:SetPoint("TOPRIGHT", self.timerBlock, "BOTTOMRIGHT", 0, 0)
    self.block.Header:SetText("")
    self.block.delvesFrame:ClearAllPoints()
    self.block.delvesFrame:SetPoint("TOPRIGHT", GwObjectivesNotification, "BOTTOMRIGHT", 0, 35)

    for _, v in ipairs(self.block.delvesFrame.spell) do
        v:SetScript("OnEnter", function(delveBlock)
                if delveBlock.spellID then
                    GameTooltip:SetOwner(delveBlock, "ANCHOR_LEFT")
                    GameTooltip:SetSpellByID(delveBlock.spellID)
                    GameTooltip:Show()
                end
            end)
        v:SetScript("OnLeave", GameTooltip_Hide)
    end

    self.block.delvesFrame.reward:SetScript("OnEnter", UIWidgetTemplateTooltipFrameOnEnter)
    self.block.delvesFrame.reward:SetScript("OnLeave", function() UIWidgetTemplateTooltipFrameMixin:OnLeave() end)

    self.block.delvesFrame.deathCounter:SetScript("OnEnter", UIWidgetTemplateTooltipFrameOnEnter)
    self.block.delvesFrame.deathCounter:SetScript("OnLeave", function() UIWidgetTemplateTooltipFrameMixin:OnLeave() end)
    self.block.delvesFrame.deathCounter.counter:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)

    C_Timer.After(0.8, function() self:UpdateLayout() end)

    self.timerBlock:TimerBlockOnEvent()
end
