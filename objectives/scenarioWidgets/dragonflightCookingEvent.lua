local _, GW = ...

local timer
local function addDragonflightCookingEventData(GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isDragonflightCookingEventWidget)
    if GW.locationData.mapID == 2024 then
        local widget = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(4324)
        if widget and widget.timerMax > 0 and widget.timerValue <= widget.timerMax then
            if not timer then
                timer = C_Timer.NewTicker(0.5, function()
                    local widget2 = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(4324)
                    if widget2 and widget2.timerValue ~= widget2.timerMax then
                        GwQuestTrackerTimer.timer:SetValue(widget2.timerValue / widget2.timerMax)
                        GwQuestTrackerTimer.timerString:SetText(SecondsToClock(widget2.timerValue, false))
                    else
                        timer:Cancel()
                        timer = nil
                        GW.updateCurrentScenario(GwQuesttrackerContainerScenario)
                    end
                end)
            end
            GwQuestTrackerTimer.timer:Show()
            GwQuestTrackerTimerSavedHeight = GwQuestTrackerTimerSavedHeight + 40
            showTimerAsBonus = true
        else
            GwQuestTrackerTimerSavedHeight = 1
            GwQuestTrackerTimer.timer:Hide()
            if timer then
                timer:Cancel()
                timer = nil
            end
        end

        isDragonflightCookingEventWidget = true
    end

    return GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isDragonflightCookingEventWidget
end
GW.addDragonflightCookingEventData = addDragonflightCookingEventData
