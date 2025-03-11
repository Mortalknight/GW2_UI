local _, GW = ...

GwAchievementTrackerContainerMixin = CreateFromMixins(GwObjectivesContainerMixin)

function GwAchievementTrackerContainerMixin:UpdateAchievementLayout(event, ...)
    local savedHeight = 1
    local shownIndex = 1
    local trackedAchievements = C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)

    self.header:Hide()

    local numAchievements = #trackedAchievements
    if self.collapsed and numAchievements > 0 then
        self.header:Show()
        numAchievements = 0
        savedHeight = 20
    end

    if event == "TRACKED_ACHIEVEMENT_UPDATE" then
        local achievementID, criteriaID, elapsed, duration = ...
		if elapsed and duration then
			-- we're already handling timer bars for achievements with visible criteria
			-- we use this system to handle timer bars for the rest
			local numCriteria = GetAchievementNumCriteria(achievementID)
			if numCriteria == 0 then
				local timedCriteria = self.timedCriteria[criteriaID] or {}
				timedCriteria.achievementID = achievementID
				timedCriteria.startTime = GetTime() - elapsed
				timedCriteria.duration = duration
				self.timedCriteria[criteriaID] = timedCriteria
			end
		end
    end

    for i = 1, numAchievements do
        local achievementID = trackedAchievements[i]
        local achievementName = select(2, GetAchievementInfo(achievementID))
        local wasEarnedByMe = select(13, GetAchievementInfo(achievementID))

        if not wasEarnedByMe then
            if shownIndex == 1 then
                savedHeight = 20
            end

            self.header:Show()
            local block = self:GetBlock(shownIndex, "ACHIEVEMENT", false)
            if block == nil then
                return
            end
            Mixin(block, GwAchievementTrackerBlockMixin)
            block.id = achievementID
            block:UpdateAchievementObjectives(self)

            block.Header:SetText(achievementName)

            block:Show()

            block:SetScript("OnClick", block.OnClick)

            savedHeight = savedHeight + block.height

            shownIndex = shownIndex + 1
        end
    end

    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(savedHeight)

    for i = shownIndex, 25 do
        if _G["GwQuesttrackerContainerAchievementBlock" .. i] then
            _G["GwQuesttrackerContainerAchievementBlock" .. i]:Hide()
        end
    end

    GW.QuestTrackerLayoutChanged()
end
