local _, GW = ...

local function addEventTimerBarByWidgetId(timerBlock, gwQuestTrackerTimerSavedHeight, showTimerAsBonus, widgetId)
    local widget = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(widgetId)
    if widget then
        if widget.shownState ~= Enum.WidgetShownState.Hidden and widget.timerMax > 0 and widget.timerValue < widget.timerMax and widget.timerValue > 1 then
            timerBlock.timer:SetValue(widget.timerValue / widget.timerMax)
            timerBlock.timerString:SetText(SecondsToClock(widget.timerValue, false))
            timerBlock.timer:Show()
            gwQuestTrackerTimerSavedHeight = gwQuestTrackerTimerSavedHeight + 40
            showTimerAsBonus = true
        else
            gwQuestTrackerTimerSavedHeight = 1
            timerBlock.height = 1
            timerBlock.timer:Hide()
            showTimerAsBonus = false
        end
    else
        gwQuestTrackerTimerSavedHeight = 1
        timerBlock.timer:SetShown(timerBlock.needToShowTimer)
        if not timerBlock.needToShowTimer then
            timerBlock.height = 1
        end
        showTimerAsBonus = false
    end

    return gwQuestTrackerTimerSavedHeight, showTimerAsBonus
end
GW.addEventTimerBarByWidgetId = addEventTimerBarByWidgetId
