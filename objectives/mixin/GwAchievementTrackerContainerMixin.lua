local _, GW = ...

GwAchievementTrackerContainerMixin = {}
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
            local block = self:GetBlock(shownIndex)
            if block == nil then
                return
            end
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
        if _G["GwAchivementBlock" .. i] ~= nil then
            _G["GwAchivementBlock" .. i]:Hide()
        end
    end

    GW.QuestTrackerLayoutChanged()
end

function GwAchievementTrackerContainerMixin:GetBlock(blockIndex)
    if _G["GwAchivementBlock" .. blockIndex] ~= nil then
       return  _G["GwAchivementBlock" .. blockIndex]
    end

    local newBlock = CreateFrame("Button", "GwAchivementBlock" .. blockIndex, self, "GwObjectivesBlockTemplate")
    newBlock:SetParent(self)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwAchivementBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end
    newBlock.height = 0
    newBlock:SetBlockColorByKey("ACHIEVEMENT")
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)

    Mixin(newBlock, GwAchievementTrackerBlockMixin)
    return newBlock
end
