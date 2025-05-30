local _, GW = ...
--/dump  C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(5865)

local timer

local function TerminateTimer()
    if timer then
        timer:Cancel()
        timer = nil
    end
end
GW.TerminateScenarioWidgetTimer = TerminateTimer

local function TimerFunction(timerBlock, widgetId)
    local widget = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(widgetId)
    if widget and widget.timerValue ~= widget.timerMax then
        timerBlock.timer:SetValue(widget.timerValue / widget.timerMax)
        timerBlock.timerString:SetText(SecondsToClock(widget.timerValue, false))
    else
        timerBlock.height = 1
        timerBlock.timer:Hide()
        TerminateTimer()
        GwQuesttrackerContainerScenario:UpdateLayout()
    end
end

local function addEventTimerBarByWidgetId(timerBlock, gwQuestTrackerTimerSavedHeight, showTimerAsBonus, widgetId, useRealTimer)
    local widget = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(widgetId)
    if widget then
        if widget.shownState ~= Enum.WidgetShownState.Hidden and widget.timerMax > 0 and widget.timerValue < widget.timerMax and widget.timerValue > 1 then
            if useRealTimer then -- here we need to add a real timer
                if not timer then
                    timer = C_Timer.NewTicker(0.25, function() TimerFunction(timerBlock, widgetId) end)
                end
            else
                timerBlock.timer:SetValue(widget.timerValue / widget.timerMax)
                timerBlock.timerString:SetText(SecondsToClock(widget.timerValue, false))
            end
            timerBlock.timer:Show()
            gwQuestTrackerTimerSavedHeight = gwQuestTrackerTimerSavedHeight + 40
            showTimerAsBonus = true
        else
            gwQuestTrackerTimerSavedHeight = 1
            timerBlock.height = 1
            timerBlock.timer:Hide()
            showTimerAsBonus = false
            TerminateTimer()
        end
    else
        gwQuestTrackerTimerSavedHeight = 1
        timerBlock.timer:SetShown(timerBlock.needToShowTimer)
        if not timerBlock.needToShowTimer then
            timerBlock.height = 1
        end
        showTimerAsBonus = false
        TerminateTimer()
    end

    return gwQuestTrackerTimerSavedHeight, showTimerAsBonus
end
GW.addEventTimerBarByWidgetId = addEventTimerBarByWidgetId
