---@class GW2
local GW = select(2, ...)

local TIME_FOR_3 = 0.6
local TIME_FOR_2 = 0.8
local UI_WIDGET_TYPE_STATUS_BAR = 2
local UI_WIDGET_TYPE_DOUBLE_STATUS_BAR = 3
local UI_WIDGET_TYPE_SCENARIO_CURRENCIES = 11

GwObjectivesScenarioContainerWidgetMixin = {}
GwObjectivesScenarioContainerMixin = {}
GwQuesttrackerScenarioBlockMixin = {}

local function HasValidTimerData(widgetInfo)
    return type(widgetInfo) == "table"
        and type(widgetInfo.timerMin) == "number"
        and type(widgetInfo.timerMax) == "number"
        and type(widgetInfo.timerValue) == "number"
        and widgetInfo.timerMax > widgetInfo.timerMin
        and widgetInfo.timerValue > widgetInfo.timerMin
        and widgetInfo.timerValue <= widgetInfo.timerMax
end

local function IsRealTimerWidget(widgetInfo)
    return widgetInfo and widgetInfo.hasTimer and HasValidTimerData(widgetInfo)
end

local function IsFakeTimerWidget(widgetInfo)
    return widgetInfo and not widgetInfo.hasTimer and HasValidTimerData(widgetInfo)
end

local function IsScenarioCriteriaComplete(criteriaInfo)
    if not criteriaInfo then
        return false
    end

    if criteriaInfo.completed ~= nil then
        return criteriaInfo.completed
    end

    if criteriaInfo.quantity and criteriaInfo.totalQuantity and criteriaInfo.totalQuantity > 0 then
        return criteriaInfo.quantity >= criteriaInfo.totalQuantity
    end

    return false
end

function GwObjectivesScenarioContainerWidgetMixin:RemoveAllWidgets()
    self.widgetFrames = {}
    self.timerWidgets = {}
    self.numTimers = 0

    if self.timerBlock.ticker then
        self.timerBlock.ticker:Cancel()
        self.timerBlock.ticker = nil
    end

    self.widgetPools:ReleaseAll()
end

function GwObjectivesScenarioContainerWidgetMixin:RegisterTimerWidget(widgetID, widgetFrame)
    if not self.timerWidgets[widgetID] then
        -- New timer added
        self.timerWidgets[widgetID] = widgetFrame
        if not self.timerBlock.ticker then
            self.timerBlock.ticker = C_Timer.NewTicker(1,
                function()
                    for id, widget in pairs(self.timerWidgets) do
                        self:ProcessWidget(id, widget.widgetType)
                    end
                end)
        end

        self.numTimers = self.numTimers + 1
    end
end

function GwObjectivesScenarioContainerWidgetMixin:UnregisterTimerWidget(widgetID)
    if self.timerWidgets[widgetID] then
        -- Existing timer removed
        self.timerWidgets[widgetID] = nil

        self.numTimers = self.numTimers - 1

        if self.numTimers == 0 and self.timerBlock.ticker then
            self.timerBlock.ticker:Cancel()
            self.timerBlock.ticker = nil
        end

        if self.numTimers == 0 and self.layoutFunc and self.container then
            self.layoutFunc(self.container)
        end
    end
end

function GwObjectivesScenarioContainerWidgetMixin:RegisterFakeTimerWidget(widgetID, widgetFrame)
    if not self.timerWidgets[widgetID] then
        self.timerWidgets[widgetID] = widgetFrame
        self.numTimers = self.numTimers + 1
    end
end

function GwObjectivesScenarioContainerWidgetMixin:UnregisterFakeTimerWidget(widgetID)
    if self.timerWidgets[widgetID] then
        self.timerWidgets[widgetID] = nil
        self.numTimers = self.numTimers - 1

        if self.numTimers == 0 and self.layoutFunc and self.container then
            self.layoutFunc(self.container)
        end
    end
end

function GwObjectivesScenarioContainerWidgetMixin:SyncWidgetTimerRegistration(widgetID, widgetFrame, widgetInfo)
    local oldIsRealTimer = widgetFrame.isRealTimer
    local oldIsFakeTimer = widgetFrame.isFakeTimer
    local newIsRealTimer = IsRealTimerWidget(widgetInfo)
    local newIsFakeTimer = IsFakeTimerWidget(widgetInfo)

    if oldIsRealTimer and not newIsRealTimer then
        self:UnregisterTimerWidget(widgetID)
    elseif oldIsFakeTimer and not newIsFakeTimer then
        self:UnregisterFakeTimerWidget(widgetID)
    end

    if not oldIsRealTimer and newIsRealTimer then
        self:RegisterTimerWidget(widgetID, widgetFrame)
    elseif not oldIsFakeTimer and newIsFakeTimer then
        self:RegisterFakeTimerWidget(widgetID, widgetFrame)
    end

    widgetFrame.hasTimer = widgetInfo.hasTimer
    widgetFrame.isRealTimer = newIsRealTimer
    widgetFrame.isFakeTimer = newIsFakeTimer
end

function GwObjectivesScenarioContainerWidgetMixin:RemoveWidget(widgetID)
    local widgetFrame = self.widgetFrames[widgetID]
    if not widgetFrame then
        -- This widget was never created. Nothing to do
        return
    end

    -- If this is a widget with a timer, remove it from the timer list
    if widgetFrame.isRealTimer then
        self:UnregisterTimerWidget(widgetID)
    elseif widgetFrame.isFakeTimer then
        self:UnregisterFakeTimerWidget(widgetID)
    end

    self.widgetPools:Release(widgetFrame)
    self.widgetFrames[widgetID] = nil
end

function GwObjectivesScenarioContainerWidgetMixin:OnEvent(event, ...)
    if event == "UPDATE_ALL_UI_WIDGETS" then
        self:ProcessAllWidgets()
    elseif event == "UPDATE_UI_WIDGET" then
        local widgetInfo = ...
        if self:IsRegisteredForWidgetSet(widgetInfo.widgetSetID) then
            self:ProcessWidget(widgetInfo.widgetID, widgetInfo.widgetType)
        end
    end
end

function GwObjectivesScenarioContainerWidgetMixin:IsRegisteredForWidgetSet(widgetSetID)
    if widgetSetID then
        return self.widgetSetID == widgetSetID
    else
        return self.widgetSetID ~= nil
    end
end

function GwObjectivesScenarioContainerWidgetMixin:GetWidgetFromPools(templateInfo)
    if templateInfo then
        return self.widgetPools:Acquire()
    end
end

function GwObjectivesScenarioContainerWidgetMixin:CreateWidget(widgetID, widgetType, widgetTypeInfo, widgetInfo)
    local widgetFrame = self:GetWidgetFromPools(widgetTypeInfo.templateInfo)

    widgetFrame.widgetID = widgetID
    widgetFrame.widgetSetID = self.widgetSetID
    widgetFrame.widgetType = widgetType
    widgetFrame.isRealTimer = false
    widgetFrame.isFakeTimer = false
    self:SyncWidgetTimerRegistration(widgetID, widgetFrame, widgetInfo)

    self.widgetFrames[widgetID] = widgetFrame

    return widgetFrame
end

function GwObjectivesScenarioContainerWidgetMixin:HandleTimer(timerBlock, widgetInfo)
    if widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
        local timerValue = Clamp(widgetInfo.timerValue, widgetInfo.timerMin, widgetInfo.timerMax)
        local timeRemaining = timerValue - widgetInfo.timerMin
        local timerText = SecondsToClock(timeRemaining)

        timerBlock.timer:SetMinMaxValues(widgetInfo.timerMin, widgetInfo.timerMax)
        timerBlock.timer:SetValue(timerValue)
        timerBlock.timerString:SetText(timerText)

        timerBlock.timer:Show()
    else
        timerBlock.timer:SetShown(timerBlock.needToShowTimer)
        if not timerBlock.needToShowTimer then
            timerBlock.height = 1
        end
    end
end

function GwObjectivesScenarioContainerWidgetMixin:IsTimerRunning()
    return (self.numTimers or 0) > 0
end

function GwObjectivesScenarioContainerWidgetMixin:ProcessWidget(widgetID, widgetType)
    local widgetTypeInfo = UIWidgetManager:GetWidgetTypeInfo(widgetType)
    if not widgetTypeInfo then
        -- This WidgetType is not supported (nothing called RegisterWidgetVisTypeTemplate for it)
        return
    end

    local widgetInfo = widgetTypeInfo.visInfoDataFunction(widgetID)
    local widgetFrame = self.widgetFrames[widgetID]
    local widgetAlreadyExisted = (widgetFrame ~= nil)

    if widgetAlreadyExisted and widgetFrame.widgetType ~= widgetType then
        -- This widget existed already but the type has changed, so release the old widget frame and treat it as a brand new widget
        self:RemoveWidget(widgetID)
        widgetAlreadyExisted = false
    end
    local isNewWidget = false
    if widgetAlreadyExisted then
        if not widgetInfo then
            self:RemoveWidget(widgetID)
            return
        end

        self:SyncWidgetTimerRegistration(widgetID, widgetFrame, widgetInfo)
    else
        -- Widget did not already exist
        if widgetInfo then
            -- And it should be shown...create it
            widgetFrame = self:CreateWidget(widgetID, widgetType, widgetTypeInfo, widgetInfo)
            isNewWidget = true
        else
            -- Widget should not be shown. It didn't already exist so there is nothing to do
            return
        end
    end
    if widgetFrame.isRealTimer or widgetFrame.isFakeTimer then
        self:HandleTimer(self.timerBlock, widgetInfo)
    elseif widgetInfo and self.handlesCurrencyWidgets and widgetType == UI_WIDGET_TYPE_SCENARIO_CURRENCIES then
        wipe(self.widgetInfoForCurrency)
        tinsert(self.widgetInfoForCurrency, widgetInfo)
        if self.layoutFunc then
            self.layoutFunc(self.container)
        end
        return
    elseif widgetInfo and self.handlesStatusBarWidgets and (widgetType == UI_WIDGET_TYPE_STATUS_BAR or widgetType == UI_WIDGET_TYPE_DOUBLE_STATUS_BAR) then
        wipe(self.widgetInfoForStatusBar)
        tinsert(self.widgetInfoForStatusBar, widgetInfo)
        if self.layoutFunc then
            self.layoutFunc(self.container)
        end
        return
    end

    if isNewWidget or widgetFrame.isFakeTimer then
        if self.layoutFunc then
            self.layoutFunc(self.container)
        end
    end
end

function GwObjectivesScenarioContainerWidgetMixin:ProcessAllWidgets()
    local setWidgets = C_UIWidgetManager.GetAllWidgetsBySetID(self.widgetSetID)
    for _, widgetInfo in ipairs(setWidgets) do
        self:ProcessWidget(widgetInfo.widgetID, widgetInfo.widgetType)
    end

    if self.layoutFunc then
        self.layoutFunc(self.container)
    end
end

function GwObjectivesScenarioContainerWidgetMixin:UnregisterForWidgetSet()
    if not self.widgetSetID then
        -- We are not registered to a WidgetSet...nothing to do
        return
    end

    self:RemoveAllWidgets()

    self.widgetSetID = nil
    self.widgetID = nil
    self.layoutFunc = nil
    wipe(self.widgetInfoForStatusBar)
    wipe(self.widgetInfoForCurrency)

    self:UnregisterEvent("UPDATE_ALL_UI_WIDGETS")
    self:UnregisterEvent("UPDATE_UI_WIDGET")
end

function GwObjectivesScenarioContainerWidgetMixin:RegisterForWidgetSet(widgetSetID)
    if self.widgetSetID then
        -- We are already registered to a WidgetSet
        if self.widgetSetID == widgetSetID then
            -- And it's the same WidgetSet we are trying to register again...nothing to do
            return
        else
            -- We are already registered for a different WidgetSet...unregister it
            self:UnregisterForWidgetSet()
        end
    end

    if not widgetSetID then
        return
    end

    self.widgetSetID = widgetSetID
    self.layoutFunc = self.container.QueueUpdateLayout
    self.widgetFrames = {}
    self.timerWidgets = {}
    self.widgetInfoForStatusBar = {}
    self.widgetInfoForCurrency = {}
    self.numTimers = 0

    self:ProcessAllWidgets()

    self:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
    self:RegisterEvent("UPDATE_UI_WIDGET")
end

local function CreateScenarioWidgetManager(container, handlesStatusBarWidgets, handlesCurrencyWidgets)
    local widgetManager = CreateFrame("Frame")
    Mixin(widgetManager, GwObjectivesScenarioContainerWidgetMixin)
    widgetManager.widgetPools = CreateFramePool("Frame")
    widgetManager:SetScript("OnEvent", widgetManager.OnEvent)
    widgetManager.timerBlock = container.timerBlock
    widgetManager.container = container
    widgetManager.handlesStatusBarWidgets = handlesStatusBarWidgets
    widgetManager.handlesCurrencyWidgets = handlesCurrencyWidgets

    return widgetManager
end

function GwObjectivesScenarioContainerMixin:ClearWidgetSet()
    self:UpdateWidgetRegistration()
end

function GwObjectivesScenarioContainerMixin:UpdateWidgetRegistration(widgetSetID)
    self.timerWidgetManager:RegisterForWidgetSet(widgetSetID)
    if widgetSetID ~= nil then
        self.statusBarWidgetManager:RegisterForWidgetSet(514)
    else
        self.statusBarWidgetManager:RegisterForWidgetSet()
    end
end

local function PrepareScenarioCustomObjectiveBlock(objectiveBlock, height)
    objectiveBlock:SetHeight(height)
    objectiveBlock.ObjectiveText:SetText("")
    objectiveBlock.StatusBar:Hide()
    objectiveBlock.TimerBar:Hide()
    objectiveBlock.TimerBar:SetScript("OnUpdate", nil)
    objectiveBlock:SetCompletedLineState(false)
    objectiveBlock:Show()
end

local function AddScenarioCurrencyObjective(block, widgetInfo)
    if not widgetInfo or widgetInfo.shownState == Enum.WidgetShownState.Hidden or not widgetInfo.currencies or #widgetInfo.currencies == 0 then
        return false
    end

    block.numObjectives = block.numObjectives + 1
    local objectiveBlock = block:GetObjectiveBlock(block.numObjectives, -5)

    PrepareScenarioCustomObjectiveBlock(objectiveBlock, block.currenciesFrame:GetHeight())

    block.currenciesFrame:SetParent(objectiveBlock)
    block.currenciesFrame:ClearAllPoints()
    block.currenciesFrame:SetPoint("TOPRIGHT", objectiveBlock, "TOPRIGHT", 0, 0)
    block.currenciesFrame:Show()

    for idx, currency in ipairs(widgetInfo.currencies) do
        if idx == 6 then break end

        local currencyFrame = block.currenciesFrame.currency[idx]
        currencyFrame.counter:SetText(currency.text)
        currencyFrame.icon:SetTexture(currency.iconFileID)
        if not currencyFrame.mask then
            currencyFrame.mask = currencyFrame:CreateMaskTexture()
            currencyFrame.mask:SetAllPoints(currencyFrame.icon)
            currencyFrame.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            currencyFrame.icon:AddMaskTexture(currencyFrame.mask)
        end
        currencyFrame.tooltip = currency.tooltip
        currencyFrame:Show()
    end

    block.height = block.height + objectiveBlock:GetHeight()

    return true
end

local function AddScenarioTieredEntranceTraitsObjective(block)
    if not (GW.Retail and C_ScenarioInfo.IsTieredEntranceScenario()) then
        return false
    end

    local spells = C_ScenarioInfo.GetTieredEntranceActiveSpells()
    if not spells then
        return false
    end

    block.numObjectives = block.numObjectives + 1
    local objectiveBlock = block:GetObjectiveBlock(block.numObjectives, nil, -5)

    block.tieredEntranceTraitsFrame:SetSpells(spells)
    PrepareScenarioCustomObjectiveBlock(objectiveBlock, block.tieredEntranceTraitsFrame:GetHeight() + GW.GetObjectivesEntrySpacing())

    block.tieredEntranceTraitsFrame:SetParent(objectiveBlock)
    block.tieredEntranceTraitsFrame:ClearAllPoints()
    block.tieredEntranceTraitsFrame:SetPoint("TOPRIGHT", objectiveBlock, "TOPRIGHT", -10, 0)
    block.tieredEntranceTraitsFrame:Show()

    block.height = block.height + objectiveBlock:GetHeight()

    return true
end

local function ScenarioContainerLayoutRunnerOnUpdate(frame)
    frame:SetScript("OnUpdate", nil)

    local container = frame.container
    container.layoutQueued = false
    container:UpdateLayout()
end

function GwObjectivesScenarioContainerMixin:QueueUpdateLayout(event, ...)
    if event == "JAILERS_TOWER_LEVEL_UPDATE" then
        local level, type, textureKit = ...
        self.jailersTowerLevelUpdateInfo = {level = level, type = type, textureKit = textureKit}
    end

    if self.layoutQueued then
        return
    end

    self.layoutQueued = true
    self.layoutUpdateFrame:SetScript("OnUpdate", ScenarioContainerLayoutRunnerOnUpdate)
end

function GwObjectivesScenarioContainerMixin:UpdateLayout()
    GwObjectivesNotification:RemoveNotificationOfType(GW.Enum.ObjectivesNotificationType.Scenario)
    GwObjectivesNotification:RemoveNotificationOfType(GW.Enum.ObjectivesNotificationType.Torghast)
    GwObjectivesNotification:RemoveNotificationOfType(GW.Enum.ObjectivesNotificationType.Delve)

    local compassData = self.compassData or {}
    self.compassData = compassData
    compassData.TYPE = GW.Enum.ObjectivesNotificationType.Scenario
    compassData.TITLE = "Unknown Scenario"
    compassData.ID = "unknown"
    compassData.QUESTID = "unknown"
    compassData.COMPASS = false
    compassData.MAPID = nil
    compassData.X = nil
    compassData.Y = nil
    compassData.COLOR = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Scenario]

    local block = self.block
    local timerBlock = self.timerBlock
    local _, _, numStages, _, _, _, _, _, _, _, _, _, scenarioID = C_Scenario.GetInfo()
    local name, instanceType, difficultyID, difficultyName = GetInstanceInfo()
    local isDelveScenario = GW.Retail and difficultyID == 208

    block.height = 0.1

    if timerBlock.timer:IsShown() then
        block.height = timerBlock.height
    end

    block.numObjectives = 0
    block.questLogIndex = 0
    block.groupButton:Hide()
    block.delvesFrame:Hide()
    block.currenciesFrame:Hide()
    for i = 1, 5 do
        block.currenciesFrame.currency[i]:Hide()
    end
    block.tieredEntranceTraitsFrame:Hide()

    if not isDelveScenario then
        GW.StopNemesisCounter()
    end
    block:Show()
    if numStages == 0 or (GW.Retail and IsOnGroundFloorInJailersTower()) then
        if instanceType == "raid" then
            compassData.TITLE = name
            compassData.DESC = difficultyName
            GwObjectivesNotification:AddNotification(compassData)
            block.height = block.height + 5
        else
            GwObjectivesNotification:RemoveNotificationOfType(GW.Enum.ObjectivesNotificationType.Scenario)
            GwObjectivesNotification:RemoveNotificationOfType(GW.Enum.ObjectivesNotificationType.Torghast)
            block:Hide()
        end
        GW.CombatQueue:Queue(nil, block.UpdateObjectiveActionButton, {block})
        if block.hasItem then
            block.fromContainerTopHeight = block.height
            GW.CombatQueue:Queue("update_tracker_scenario_itembutton_position", block.UpdateObjectiveActionButtonPosition, {block})
        end

        for i = (block.numObjectives or 0) + 1, #block.objectiveBlocks do
            block.objectiveBlocks[i]:Hide()
        end

        block:SetHeight(block.height)
        self:SetHeight(block.height)
        if not timerBlock.needToShowTimer then
            timerBlock.timer:Hide()
            timerBlock.height = 1
            timerBlock:SetHeight(timerBlock.height)
        end
        self:ClearWidgetSet()

        return
    end

    local stageName, stageDescription, numCriteria, _, _, _, _, _, allSpellInfo, _, questID, widgetSetID = C_Scenario.GetStepInfo()
    self:UpdateWidgetRegistration(widgetSetID)
    local isMythicKeystone = difficultyID == 8
    stageDescription = stageDescription or ""
    stageName = stageName or ""
    if difficultyName then
        local level = GW.Retail and C_ChallengeMode.GetActiveKeystoneInfo() or 0
        if level > 0 then
            compassData.TITLE = stageName .. " |cFFFFFFFF +" .. level .. " " .. difficultyName .. "|r"
        else
            compassData.TITLE = stageName .. " |cFFFFFFFF " .. difficultyName .. "|r"
        end
        compassData.DESC = stageDescription .. " "
    end

    if GW.Retail and IsInJailersTower() then
        local floor = ""
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

        compassData.COLOR = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Torghast]
        compassData.TYPE = GW.Enum.ObjectivesNotificationType.Torghast
    end

    -- check for active delves
    local delvesWidgetInfo = isDelveScenario and C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6183)
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

                if spellInfo.spellID == 1270179 then -- Chest icon
                    spellBlock.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/chest.png")
                    GW.RequestNemesisCounterUpdate(spellBlock)
                else
                    spellBlock.icon:SetTexture(spellData.iconID)
                    spellBlock.notification.Text:SetText("")
                    spellBlock.notification:Hide()
                end

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
            block.delvesFrame.spell[i].notification:Hide()
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

        compassData.COLOR = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Delve]
        compassData.TYPE = GW.Enum.ObjectivesNotificationType.Delve
    end

    block:SetBlockColorByKey(compassData.TYPE)
    block.Header:SetTextColor(block.color.r, block.color.g, block.color.b)
    block.hover:SetVertexColor(block.color.r, block.color.g, block.color.b)
    GwObjectivesNotification:AddNotification(compassData, true)

    if questID then
        block.questLogIndex = (GW.Retail and C_QuestLog.GetLogIndexForQuestID or GetQuestLogIndexByID)(questID)
    end

    --check for groupfinder button and add spells
    if GW.Retail then
        block:UpdateFindGroupButton(scenarioID, true)
        GW.CombatQueue:Queue(nil, block.UpdateScenarioSpell, {block, allSpellInfo})
    end

    local objectiveOptions = {
        finished = false,
        useCompletedLine = true,
        scenarioObjective = true,
        objectiveType = "monster",
        qty = 0,
        isMythicKeystone = false,
        firstObjectivesYValue = -5,
    }

    for _, widgetInfo in ipairs( self.timerWidgetManager.widgetInfoForCurrency or {} ) do
        if AddScenarioCurrencyObjective(block, widgetInfo) then
            break
        end
    end
    AddScenarioTieredEntranceTraitsObjective(block)

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
            objectiveOptions.finished = IsScenarioCriteriaComplete(scenarioCriteriaInfo)
            objectiveOptions.objectiveType = objectiveType
            objectiveOptions.qty = scenarioCriteriaInfo.quantity
            objectiveOptions.isMythicKeystone = isMythicKeystone
            block:AddObjective(GW.ParseCriteria(scenarioCriteriaInfo.quantity, scenarioCriteriaInfo.totalQuantity, scenarioCriteriaInfo.description, isMythicKeystone, mythicKeystoneCurrentValue, scenarioCriteriaInfo.isWeightedProgress), objectiveOptions)
            if scenarioCriteriaInfo.duration > 0 and scenarioCriteriaInfo.elapsed <= scenarioCriteriaInfo.duration then
                block:AddObjective(TIME_REMAINING, {isQuest = false, qty = nil, totalqty = nil, timerShown = true, duration = scenarioCriteriaInfo.duration, startTime = GetTime() - scenarioCriteriaInfo.elapsed})
            end
        end
    end
    -- add special widgets here
    GW.addWarfrontData(block)
    GW.addHeroicVisionsData(block)
    GW.addJailersTowerData(block)
    GW.addEmberCourtData(self)

    local bonusSteps = C_Scenario.GetBonusSteps() or {}
    for _, v in ipairs(bonusSteps) do
        local bonusStepIndex = v
        local _, _, numCriteriaForStep = C_Scenario.GetStepInfo(bonusStepIndex)

        for criteriaIndex = 1, numCriteriaForStep do
            local scenarioCriteriaInfo = C_ScenarioInfo.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex)
            local objectiveType = scenarioCriteriaInfo.isWeightedProgress and "progressbar" or "monster"

            -- timer bar
            if scenarioCriteriaInfo.duration > 0 and scenarioCriteriaInfo.elapsed <= scenarioCriteriaInfo.duration and not (scenarioCriteriaInfo.failed or scenarioCriteriaInfo.completed) then
                block:AddObjective(TIME_REMAINING, {isQuest = false, qty = nil, totalqty = nil, timerShown = true, duration = scenarioCriteriaInfo.duration, startTime = GetTime() - scenarioCriteriaInfo.elapsed})
            else
                objectiveOptions.finished = IsScenarioCriteriaComplete(scenarioCriteriaInfo)
                objectiveOptions.objectiveType = objectiveType
                objectiveOptions.qty = scenarioCriteriaInfo.quantity
                objectiveOptions.isMythicKeystone = false
                block:AddObjective(GW.ParseCriteria(scenarioCriteriaInfo.quantity, scenarioCriteriaInfo.totalQuantity, scenarioCriteriaInfo.description), objectiveOptions)
            end
        end
    end

    --check for additonal statusbar
    local hasVisibleStatusBarWidget = false
    for _, widgetInfo in ipairs( self.statusBarWidgetManager.widgetInfoForStatusBar or {} ) do
        if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
            hasVisibleStatusBarWidget = true
            local objectiveType = "object"
            local quantity = widgetInfo.barValue
            local text = GW.ParseCriteria(widgetInfo.barValue, widgetInfo.barMax, widgetInfo.text)

            if widgetInfo.barValueTextType == Enum.StatusBarValueTextType.Percentage then
                objectiveType = "progressbar"
                quantity = math.min(1, widgetInfo.barValue / widgetInfo.barMax)
                text = (widgetInfo.text or "") .. " " .. FormatPercentage(quantity)
                quantity = quantity * 100
            end
            block:AddObjective(text, { finished = false, objectiveType = objectiveType, qty = quantity, firstObjectivesYValue = -5 })
        end
    end
    if hasVisibleStatusBarWidget and not self.timerWidgetManager:IsTimerRunning() then
        self:ClearWidgetSet()
    end

    for i = (block.numObjectives or 0) + 1, #block.objectiveBlocks do
        block.objectiveBlocks[i]:Hide()
    end

    block.height = block.height + 5
    if block.hasItem then
        block.fromContainerTopHeight = block.height
        GW.CombatQueue:Queue("update_tracker_scenario_itembutton_position", block.UpdateObjectiveActionButtonPosition, {block})
    end

    local intGWQuestTrackerHeight = 0
    if timerBlock.affixeFrame:IsShown() then intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40 end
    if timerBlock.timer:IsShown() then intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40 end

    if self.timerWidgetManager:IsTimerRunning() then
        timerBlock.height = 40
    end

    timerBlock:SetHeight(timerBlock.height)
    block:SetHeight(block.height - intGWQuestTrackerHeight)
    self:SetHeight(block.height)
end

function GwQuesttrackerScenarioBlockMixin:UpdateAffixes(fakeIds)
    if not GW.Retail then return end
    local _, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
    affixes = fakeIds and #fakeIds > 0 and fakeIds or affixes or {}

    for idx, v in ipairs(affixes) do
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
            v.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-boss.png")
        end
        self.affixeFrame:Hide()
        self.affixeFrame:SetHeight(1) -- needed for anchor points
    end
end

function GwQuesttrackerScenarioBlockMixin:UpdateDeathCounter()
    if not GW.Retail then return end
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

local function GetChallengeModeMapID()
    if GW.Retail then
        return C_ChallengeMode.GetActiveChallengeMapID()
    elseif GW.Mists then
        local _, _, _, _, _, _, _, mapID = GetInstanceInfo()
        return mapID
    end
end

local function GetChallengeModeTimeData(mapID)
    if not mapID then
        return
    end

    if GW.Retail then
        local _, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
        if not timeLimit or timeLimit <= 0 then
            return
        end
        return timeLimit, timeLimit * TIME_FOR_2, timeLimit * TIME_FOR_3
    end

    local times = C_ChallengeMode.GetChallengeModeMapTimes(mapID)
    if not times or not times[1] or times[1] <= 0 then
        return
    end
    return times[1], times[2], times[3]
end

local function SetupChallengeModeTimer(self, timerID, timeLimit, time2, time3)
    self.chestoverlay:Show()
    self.timer:SetMinMaxValues(0, timeLimit)
    self.cmTimerThrottle = 0
    self:SetScript("OnUpdate", function(_, elapsed)
        -- M+ timer text has second resolution; throttle to ~10x/s instead of every frame
        -- (this runs for the whole dungeon, i.e. exactly when frame budget is tightest).
        self.cmTimerThrottle = self.cmTimerThrottle + elapsed
        if self.cmTimerThrottle < 0.1 then
            return
        end
        self.cmTimerThrottle = 0

        local _, elapsedTime = GetWorldElapsedTime(timerID)
        self.timer:SetValue(math.max(0, timeLimit - elapsedTime))
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
end

local function SetupProvingGroundTimer(self, timerID, duration)
    self.timer:SetMinMaxValues(0, duration)
    self.pgTimerThrottle = 0
    self:SetScript("OnUpdate", function(_, elapsed)
        self.pgTimerThrottle = self.pgTimerThrottle + elapsed
        if self.pgTimerThrottle < 0.1 then
            return
        end
        self.pgTimerThrottle = 0

        local _, elapsedTime = GetWorldElapsedTime(timerID)
        self.timer:SetValue(1 - (elapsedTime / duration))
        self.timerString:SetText(SecondsToClock(duration - elapsedTime))
    end)
    self.timer:Show()
    self.needToShowTimer = true
    self.height = self.height + 40
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
        if wtype == Enum.WorldElapsedTimerTypes.ChallengeMode then
            local mapID = GetChallengeModeMapID()
            local timeLimit, time2, time3 = GetChallengeModeTimeData(mapID)
            if timeLimit and time2 and time3 then
                SetupChallengeModeTimer(self, timerID, timeLimit, time2, time3)
                return
            end
        elseif wtype == Enum.WorldElapsedTimerTypes.ProvingGround then
            local _, _, _, duration = C_Scenario.GetProvingGroundsInfo()
            if duration and duration > 0 then
                SetupProvingGroundTimer(self, timerID, duration)
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
        v.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-boss.png")
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

    self.container:QueueUpdateLayout()
end

local function ScenarioContainerOnEvent(self, event, ...)
    self:QueueUpdateLayout(event, ...)
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
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("SCENARIO_COMPLETED")
    self:RegisterEvent("SCENARIO_SPELL_UPDATE")
    self:RegisterEvent("JAILERS_TOWER_LEVEL_UPDATE")
    self:SetScript("OnEvent", ScenarioContainerOnEvent)


    self.jailersTowerType = nil
    self.layoutQueued = false
    self.layoutUpdateFrame = CreateFrame("Frame", nil, self)
    self.layoutUpdateFrame.container = self

    -- JailersTower hook
    -- do it only here so we are sure we do not hook more than one time
    if GW.Retail then
        hooksecurefunc(ScenarioObjectiveTracker, "SlideInContents", function(container)
            if container:ShouldShowCriteria() and IsInJailersTower() then
                self:QueueUpdateLayout()
            end
        end)
    end

    self.timerBlock = CreateFrame("Button", "GwQuestTrackerTimer", self, "GwQuesttrackerScenarioBlock")
    self.timerBlock.container = self
    self.timerBlock.needToShowTimer = false
    self.timerBlock.height = self.timerBlock:GetHeight()
    self.timerBlock.timerlabel = self.timerBlock.timer.timerlabel
    self.timerBlock.timerString = self.timerBlock.timer.timerString

    self.timerBlock.timerlabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    self.timerBlock.timerlabel:SetTextColor(1, 1, 1)
    self.timerBlock.timerlabel:SetShadowOffset(1, -1)
    self.timerBlock.timerString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    self.timerBlock.timerString:SetTextColor(1, 1, 1)
    self.timerBlock.timerString:SetShadowOffset(1, -1)

    self.timerBlock.chestoverlay.timerStringChest2:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -2)
    self.timerBlock.chestoverlay.timerStringChest2:SetTextColor(1, 1, 1)
    self.timerBlock.chestoverlay.timerStringChest2:SetShadowOffset(1, -1)
    self.timerBlock.chestoverlay.timerStringChest3:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -2)
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

    self.timerBlock.deathcounter.counterlabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -2)
    self.timerBlock.deathcounter.counterlabel:SetTextColor(1, 1, 1)
    self.timerBlock.deathcounter.counterlabel:SetShadowOffset(1, -1)
    self.timerBlock.score.scoreString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)

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
    self.timerBlock:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
    self.timerBlock:RegisterEvent("CHALLENGE_MODE_START")
    self.timerBlock:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self.timerBlock:RegisterEvent("ZONE_CHANGED")
    self.timerBlock:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED")

    if GW.Retail then
        self.timerBlock:RegisterEvent("PROVING_GROUNDS_SCORE_UPDATE")
    end
    self.timerBlock:SetScript("OnEvent", self.timerBlock.TimerBlockOnEvent)

    self.block = self:GetBlock(1, GW.Enum.ObjectivesNotificationType.Scenario, GW.Retail) -- only create an actionbutton for retail here
    if GW.Retail then
        Mixin(self.block.actionButton, ScenarioSpellButtonMixin)
        self.block.actionButton:SetScript("OnEnter", self.block.actionButton.OnEnter)
    end

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
    self.block.delvesFrame.deathCounter.counter:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)

    for i = 1, 5 do
        self.block.currenciesFrame.currency[i]:SetScript("OnEnter", UIWidgetTemplateTooltipFrameOnEnter)
        self.block.currenciesFrame.currency[i]:SetScript("OnLeave", function() UIWidgetTemplateTooltipFrameMixin:OnLeave() end)
        self.block.currenciesFrame.currency[i].counter:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    end

    self.timerWidgetManager = CreateScenarioWidgetManager(self, false, true)
    self.statusBarWidgetManager = CreateScenarioWidgetManager(self, true, false)

    C_Timer.After(0.8, function() self:QueueUpdateLayout() end)

    self.timerBlock:TimerBlockOnEvent()
end
