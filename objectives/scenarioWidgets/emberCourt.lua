local _, GW = ...

local isOnUpdateHooked = false
local function addEmberCourtData(container, numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget)
    if GW.Libs.GW2Lib:GetPlayerLocationMapID()== 1644 then
        if BottomScenarioWidgetContainerBlock.WidgetContainer:GetHeight() > 1.1 then
            numCriteria = numCriteria + 1

            local objectiveBlock = container.block:GetObjectiveBlock(numCriteria)
            BottomScenarioWidgetContainerBlock.gwBlock = objectiveBlock
            objectiveBlock:SetHeight(max(BottomScenarioWidgetContainerBlock.height, BottomScenarioWidgetContainerBlock.WidgetContainer:GetHeight()))
            BottomScenarioWidgetContainerBlock.SetParent = nil
            BottomScenarioWidgetContainerBlock.ClearAllPoints = nil
            BottomScenarioWidgetContainerBlock.SetPoint = nil
            BottomScenarioWidgetContainerBlock:SetParent(objectiveBlock)
            BottomScenarioWidgetContainerBlock:ClearAllPoints()
            BottomScenarioWidgetContainerBlock:SetPoint("TOP", 0, 15)
            BottomScenarioWidgetContainerBlock.SetParent = GW.NoOp
            BottomScenarioWidgetContainerBlock.ClearAllPoints = GW.NoOp
            BottomScenarioWidgetContainerBlock.SetPoint = GW.NoOp
            objectiveBlock:Show()
            objectiveBlock.ObjectiveText:SetText("")
            container.block.height = container.block.height + objectiveBlock:GetHeight() + 15
            container.block.numObjectives = container.block.numObjectives + 1
            objectiveBlock.hasObjectToHide = true
            objectiveBlock.objectToHide = BottomScenarioWidgetContainerBlock
            objectiveBlock.resetParent = true
        end

        local w2 = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904) or C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2906)
        if w2 and w2.timerMax > 0 and w2.timerValue <= w2.timerMax then
            if not isOnUpdateHooked then
                container.timerBlock:SetScript(
                    "OnUpdate",
                    function()
                        local widget = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904) or C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2906)
                        if widget and widget.timerValue ~= widget.timerMax then
                            container.timerBlock.timer:SetValue(widget.timerValue / widget.timerMax)
                            container.timerBlock.timerString:SetText(SecondsToClock(widget.timerValue, false))
                        else
                            container.timerBlock:SetScript("OnUpdate", nil)
                            GwQuesttrackerContainerScenario:UpdateLayout()
                        end
                    end
                )
            end
            container.timerBlock.timer:Show()
            GwQuestTrackerTimerSavedHeight = GwQuestTrackerTimerSavedHeight + 40
            showTimerAsBonus = true
            isOnUpdateHooked = true
        else
            GwQuestTrackerTimerSavedHeight = 1
            container.timerBlock:SetScript("OnUpdate", nil)
            container.timerBlock.timer:Hide()
            isOnUpdateHooked = false
        end

        isEmberCourtWidget = true
    end

    return numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget
end
GW.addEmberCourtData = addEmberCourtData
