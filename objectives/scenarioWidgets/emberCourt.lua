local _, GW = ...
local addedPadding = false

local function addEmberCourtData(block, numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus)
    if GW.locationData.mapID == 1644 then
        if ScenarioWidgetContainerBlock.WidgetContainer:GetHeight() > 1.1 then
            numCriteria = numCriteria + 1
            local w2 = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904)
            local container = _G.ScenarioWidgetContainerBlock
            local padding = 0
            objectiveBlock = GW.GetScenarioObjectivesBlock(block, numCriteria)
            container.gwBlock = objectiveBlock
            if not addedPadding and w2 and w2.timerMax == 0 then
                padding = 15
                addedPadding = true
            end
            objectiveBlock:SetHeight(container:GetHeight() + padding)
            

            if not container.gwHooked then
                container:SetParent(objectiveBlock)
                container:ClearAllPoints()
                container:SetAllPoints()

                hooksecurefunc(ScenarioWidgetContainerBlock, "SetHeight", function(self)
                    if ScenarioWidgetContainerBlock:IsShown() and ScenarioWidgetContainerBlock.gwBlock then
                        GW.updateCurrentScenario(GwQuesttrackerContainerScenario)
                        container.ClearAllPoints = nil
                        container.SetAllPoints = nil

                        container:ClearAllPoints()
                        container:SetAllPoints()

                        container.ClearAllPoints = GW.NoOp
                        container.SetAllPoints = GW.NoOp
                    end
                end)

                hooksecurefunc(ScenarioWidgetContainerBlock.WidgetContainer, "SetHeight", function(self)
                    if ScenarioWidgetContainerBlock:IsShown() and ScenarioWidgetContainerBlock.gwBlock then
                        GW.updateCurrentScenario(GwQuesttrackerContainerScenario)
                        container.ClearAllPoints = nil
                        container.SetAllPoints = nil

                        container:ClearAllPoints()
                        container:SetAllPoints()

                        container.ClearAllPoints = GW.NoOp
                        container.SetAllPoints = GW.NoOp
                    end
                end)

                container.SetParent = GW.NoOp
                container.ClearAllPoints = GW.NoOp
                container.SetAllPoints = GW.NoOp

                container.gwHooked = true
            end

            objectiveBlock:Show()
            objectiveBlock.ObjectiveText:SetText("")
            block.height = block.height + objectiveBlock:GetHeight()
            block.numObjectives = block.numObjectives + 1
        end

        local w2 = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904)
        if w2 and w2.timerMax > 0 and w2.timerValue <= w2.timerMax then
            GwQuestTrackerTimer:SetScript(
                "OnUpdate",
                function()
                    local widget = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904)
                    if widget.timerValue ~= widget.timerMax then 
                        GwQuestTrackerTimer.timer:SetValue(widget.timerValue / widget.timerMax)
                        GwQuestTrackerTimer.timerString:SetText(SecondsToClock(widget.timerValue, false))
                    else
                        GwQuestTrackerTimer:SetScript("OnUpdate", nil)
                        GW.updateCurrentScenario(GwQuesttrackerContainerScenario)
                    end
                end
            )
            GwQuestTrackerTimer.timer:Show()
            GwQuestTrackerTimerSavedHeight = GwQuestTrackerTimerSavedHeight + 40
            showTimerAsBonus = true
        else
            GwQuestTrackerTimerSavedHeight = 1
            GwQuestTrackerTimer:SetScript("OnUpdate", nil)
            GwQuestTrackerTimer.timer:Hide()
        end
    end

    return numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus
end
GW.addEmberCourtData = addEmberCourtData