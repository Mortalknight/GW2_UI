local _, GW = ...

local function addEmberCourtData(block, numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget)
    if GW.locationData.mapID == 1644 then
        if _G.ScenarioWidgetContainerBlock.WidgetContainer:GetHeight() > 1.1 then
            numCriteria = numCriteria + 1
            local container = _G.ScenarioWidgetContainerBlock
            local objectiveBlock = GW.GetScenarioObjectivesBlock(block, numCriteria)
            container.gwBlock = objectiveBlock
            objectiveBlock:SetHeight(container:GetHeight())

            container:SetParent(objectiveBlock)
            container:ClearAllPoints()
            container:SetAllPoints()

            if not container.gwHooked then
                hooksecurefunc(_G.ScenarioWidgetContainerBlock, "SetHeight", function()
                    if _G.ScenarioWidgetContainerBlock:IsShown() and _G.ScenarioWidgetContainerBlock.gwBlock then
                        GW.updateCurrentScenario(_G.GwQuesttrackerContainerScenario)
                    end
                end)

                hooksecurefunc(_G.ScenarioWidgetContainerBlock.WidgetContainer, "SetHeight", function()
                    if _G.ScenarioWidgetContainerBlock:IsShown() and _G.ScenarioWidgetContainerBlock.gwBlock then
                        GW.updateCurrentScenario(_G.GwQuesttrackerContainerScenario)
                    end
                end)
                container.gwHooked = true
            end

            --container.SetParent = GW.NoOp
            --container.ClearAllPoints = GW.NoOp
            --container.SetAllPoints = GW.NoOp

            objectiveBlock:Show()
            objectiveBlock.ObjectiveText:SetText("")
            block.height = block.height + objectiveBlock:GetHeight() + 15
            block.numObjectives = block.numObjectives + 1
        end

        local w2 = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904) and C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904) or C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2906)
        if w2 and w2.timerMax > 0 and w2.timerValue <= w2.timerMax then
            _G.GwQuestTrackerTimer:SetScript(
                "OnUpdate",
                function()
                    local widget = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904) and C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904) or C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2906)
                    if widget and widget.timerValue ~= widget.timerMax then 
                        _G.GwQuestTrackerTimer.timer:SetValue(widget.timerValue / widget.timerMax)
                        _G.GwQuestTrackerTimer.timerString:SetText(SecondsToClock(widget.timerValue, false))
                    else
                        _G.GwQuestTrackerTimer:SetScript("OnUpdate", nil)
                        GW.updateCurrentScenario(GwQuesttrackerContainerScenario)
                    end
                end
            )
            _G.GwQuestTrackerTimer.timer:Show()
            GwQuestTrackerTimerSavedHeight = GwQuestTrackerTimerSavedHeight + 40
            showTimerAsBonus = true
        else
            GwQuestTrackerTimerSavedHeight = 1
            _G.GwQuestTrackerTimer:SetScript("OnUpdate", nil)
            _G.GwQuestTrackerTimer.timer:Hide()
        end

        isEmberCourtWidget = true
    end

    return numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget
end
GW.addEmberCourtData = addEmberCourtData
