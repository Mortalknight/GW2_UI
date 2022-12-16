local _, GW = ...

local isOnUpdateHooked = false
local function addDragonflightCookingEventData(GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isDragonflightCookingEventWidget)
    if GW.locationData.mapID == 2024 then
        local widget = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(4324)
        if widget and widget.timerMax > 0 and widget.timerValue <= widget.timerMax then
            if not isOnUpdateHooked then
                GwQuestTrackerTimer:SetScript(
                    "OnUpdate",
                    function()
                        local widget2 = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(4324)
                        if widget2 and widget2.timerValue ~= widget2.timerMax then
                            GwQuestTrackerTimer.timer:SetValue(widget2.timerValue / widget2.timerMax)
                            GwQuestTrackerTimer.timerString:SetText(SecondsToClock(widget2.timerValue, false))
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

        isDragonflightCookingEventWidget = true
    end

    return GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isDragonflightCookingEventWidget
end
GW.addDragonflightCookingEventData = addDragonflightCookingEventData
