local _, GW = ...

local timer

local function TimerFunction(widgetId)
    local widget = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(widgetId)
    if widget and widget.timerValue ~= widget.timerMax then
        GwQuestTrackerTimer.timer:SetValue(widget.timerValue / widget.timerMax)
        GwQuestTrackerTimer.timerString:SetText(SecondsToClock(widget.timerValue, false))
    else
        timer:Cancel()
        timer = nil
        GW.updateCurrentScenario(GwQuesttrackerContainerScenario)
    end
end
local function addEventTimerBarByWidgetId(gwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEventTimerBarByWidgetId, widgetId)
    local widget = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(widgetId)
    if widget then
        if widget.timerMax > 0 and widget.timerValue <= widget.timerMax and widget.timerValue > 1 then
            if not timer then
                timer = C_Timer.NewTicker(0.25, function() TimerFunction(widgetId) end)
            end
            GwQuestTrackerTimer.timer:Show()
            gwQuestTrackerTimerSavedHeight = gwQuestTrackerTimerSavedHeight + 40
            showTimerAsBonus = true
        else
            gwQuestTrackerTimerSavedHeight = 1
            GwQuestTrackerTimer.height = 1
            GwQuestTrackerTimer.timer:Hide()
            showTimerAsBonus = false
            if timer then
                timer:Cancel()
                timer = nil
            end

        end
        isEventTimerBarByWidgetId = true
    else
        gwQuestTrackerTimerSavedHeight = 1
        GwQuestTrackerTimer.timer:SetShown(GwQuestTrackerTimer.needToShowTimer)
        if not GwQuestTrackerTimer.needToShowTimer then
            GwQuestTrackerTimer.height = 1
        end
        showTimerAsBonus = false
        if timer then
            timer:Cancel()
            timer = nil
        end

        isEventTimerBarByWidgetId = false
    end

    return gwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEventTimerBarByWidgetId
end
GW.addEventTimerBarByWidgetId = addEventTimerBarByWidgetId
