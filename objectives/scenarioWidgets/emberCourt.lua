local _, GW = ...

local isOnUpdateHooked = false
local function addEmberCourtData(block, numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget)
    if GW.locationData.mapID == 1644 then
        if BottomScenarioWidgetContainerBlock.WidgetContainer:GetHeight() > 1.1 then
            numCriteria = numCriteria + 1

            local objectiveBlock = GW.GetScenarioObjectivesBlock(block, numCriteria)
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
            block.height = block.height + objectiveBlock:GetHeight() + 15
            block.numObjectives = block.numObjectives + 1
            objectiveBlock.hasObjectToHide = true
            objectiveBlock.objectToHide = BottomScenarioWidgetContainerBlock
            objectiveBlock.resetParent = true
--[[
            if not BottomScenarioWidgetContainerBlock.gwHooked then
                hooksecurefunc(BottomScenarioWidgetContainerBlock, "SetHeight", function()
                    if BottomScenarioWidgetContainerBlock:IsShown() and BottomScenarioWidgetContainerBlock.gwBlock then
                        GW.updateCurrentScenario(GwQuesttrackerContainerScenario)
                    end
                end)

                hooksecurefunc(BottomScenarioWidgetContainerBlock.WidgetContainer, "SetHeight", function()
                    if BottomScenarioWidgetContainerBlock:IsShown() and BottomScenarioWidgetContainerBlock.gwBlock then
                        GW.updateCurrentScenario(GwQuesttrackerContainerScenario)
                    end
                end)
                container.gwHooked = true
            end
]]

        end

        local w2 = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904) and C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904) or C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2906)
        if w2 and w2.timerMax > 0 and w2.timerValue <= w2.timerMax then
            if not isOnUpdateHooked then
                GwQuestTrackerTimer:SetScript(
                    "OnUpdate",
                    function()
                        local widget = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904) and C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2904) or C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(2906)
                        if widget and widget.timerValue ~= widget.timerMax then
                            GwQuestTrackerTimer.timer:SetValue(widget.timerValue / widget.timerMax)
                            GwQuestTrackerTimer.timerString:SetText(SecondsToClock(widget.timerValue, false))
                        else
                            GwQuestTrackerTimer:SetScript("OnUpdate", nil)
                            GW.updateCurrentScenario(GwQuesttrackerContainerScenario)
                        end
                    end
                )
            end
            GwQuestTrackerTimer.timer:Show()
            GwQuestTrackerTimerSavedHeight = GwQuestTrackerTimerSavedHeight + 40
            showTimerAsBonus = true
            isOnUpdateHooked = true
        else
            GwQuestTrackerTimerSavedHeight = 1
            GwQuestTrackerTimer:SetScript("OnUpdate", nil)
            GwQuestTrackerTimer.timer:Hide()
            isOnUpdateHooked = false
        end

        isEmberCourtWidget = true
    end

    return numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget
end
GW.addEmberCourtData = addEmberCourtData
