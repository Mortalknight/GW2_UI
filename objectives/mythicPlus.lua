local _, GW = ...

local evenFrame = CreateFrame("Frame")

local function OnEvent(_, event)
    local _, _, difficultyID = GetInstanceInfo()
    local forceCollapse, forceOpen

    if event == "CHALLENGE_MODE_START" or difficultyID == 8 then
        forceCollapse, forceOpen = true, false
    elseif event == "CHALLENGE_MODE_COMPLETED" or event == "PLAYER_ENTERING_WORLD" then
        forceCollapse, forceOpen = false, true
    else
        return
    end

    for _, container in ipairs(GW.QuestTrackerScrollableContainer) do
        if container.shouldUpdate ~= nil then
            container.shouldUpdate = false
        end
        if container.CollapseHeader then
            container:CollapseHeader(forceCollapse, forceOpen)
        end
    end
end
--GW_TESTEVENT = OnEvent
--/run GW_TESTEVENT(nil, "CHALLENGE_MODE_START")
--/run GW_TESTEVENT(nil, "CHALLENGE_MODE_COMPLETED")

local function ToggleCollapseObjectivesInChallangeMode()
    if GW.settings.OBJECTIVES_COLLAPSE_IN_M_PLUS then
        evenFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        evenFrame:RegisterEvent("CHALLENGE_MODE_START")
        evenFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

        evenFrame:SetScript("OnEvent", OnEvent)
    else
        evenFrame:UnregisterAllEvents()
        evenFrame:SetScript("OnEvent", nil)
    end
end
GW.ToggleCollapseObjectivesInChallangeMode = ToggleCollapseObjectivesInChallangeMode