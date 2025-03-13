local _, GW = ...

local evenFrame = CreateFrame("Frame")

local function OnEvent(_, event)
    local _, _, difficultyID = GetInstanceInfo()

    if event == "CHALLENGE_MODE_START" or difficultyID == 8 then
        GwQuesttrackerContainerQuests.shouldUpdate = false
        GwQuesttrackerContainerCampaign:CollapseHeader(true, false)
        GwQuesttrackerContainerQuests.shouldUpdate = false
        GwQuesttrackerContainerQuests:CollapseHeader(true, false)
        GwQuesttrackerContainerRecipe:CollapseHeader(true, false)
        GwQuesttrackerContainerMonthlyActivity:CollapseHeader(true, false)
        GwQuesttrackerContainerCollection:CollapseHeader(true, false)
        GwQuesttrackerContainerBonus:CollapseHeader(true, false)
        GwQuesttrackerContainerAchievement:CollapseHeader(true, false)
        if GwQuesttrackerContainerWQT then
            GW.CollapseWQTAddonHeader(GwQuesttrackerContainerWQT, true, false)
        end
        if GwQuesttrackerContainerPetTracker then
            GW.CollapsePetTrackerAddonHeader(GwQuesttrackerContainerPetTracker, true, false)
        end
        if GwQuesttrackerContainerTodoloo then
            GW.CollapseTodolooAddonHeader(GwQuesttrackerContainerTodoloo, true, false)
        end
    elseif event == "CHALLENGE_MODE_COMPLETED" or event == "PLAYER_ENTERING_WORLD" then
        GwQuesttrackerContainerQuests.shouldUpdate = false
        GwQuesttrackerContainerCampaign:CollapseHeader(false, true)
        GwQuesttrackerContainerQuests.shouldUpdate = false
        GwQuesttrackerContainerQuests:CollapseHeader(false, true)
        GwQuesttrackerContainerRecipe:CollapseHeader(false, true)
        GwQuesttrackerContainerMonthlyActivity:CollapseHeader(false, true)
        GwQuesttrackerContainerCollection:CollapseHeader(false, true)
        GwQuesttrackerContainerBonus:CollapseHeader(false, true)
        GwQuesttrackerContainerAchievement:CollapseHeader(false, true)
        if GwQuesttrackerContainerWQT then
            GW.CollapseWQTAddonHeader(GwQuesttrackerContainerWQT, false, true)
        end
        if GwQuesttrackerContainerPetTracker then
            GW.CollapsePetTrackerAddonHeader(GwQuesttrackerContainerPetTracker, false, true)
        end
        if GwQuesttrackerContainerTodoloo then
            GW.CollapseTodolooAddonHeader(GwQuesttrackerContainerTodoloo, false, true)
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