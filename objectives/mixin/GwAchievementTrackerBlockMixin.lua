local _, GW = ...

local MAX_OBJECTIVES = 10

GwAchievementTrackerBlockMixin = {}
function GwAchievementTrackerBlockMixin:UpdateAchievementObjectives(parent)
    local numIncomplete = 0
    local numCriteria = GetAchievementNumCriteria(self.id)
    local description = select(8, GetAchievementInfo(self.id))
    local firstunfinishedobjectiv = false

    self.height = 35
    self.numObjectives = 0

    if numCriteria > 0 then
        for criteriaIndex = 1, numCriteria do
            local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, _, flags, assetID, quantityString, _, eligible, duration, elapsed = GetAchievementCriteriaInfo(self.id, criteriaIndex)

            if not criteriaCompleted then
                numIncomplete = numIncomplete + 1
            end

            if numIncomplete == 1 then
                firstunfinishedobjectiv = true
            else
                firstunfinishedobjectiv = false
            end

            if (description and bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR) then
                -- progress bar
                if (string.find(strlower(quantityString), "interface/moneyframe") or string.find(strlower(quantityString), "interface\\moneyframe")) then -- no easy way of telling it's a money progress bar ("\" for mac and linux)
                    quantity = math.floor(quantity / (COPPER_PER_SILVER * SILVER_PER_GOLD))
                    totalQuantity = math.floor(totalQuantity / (COPPER_PER_SILVER * SILVER_PER_GOLD))

                    criteriaString = description
                else

                    criteriaString = description
                end
            else
                -- for meta criteria look up the achievement name
                if (criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID) then
                    _, criteriaString = GetAchievementInfo(assetID)
                end
            end

            local needTimer = duration and elapsed and elapsed < duration
            self:AddObjective(criteriaString, criteriaCompleted, firstunfinishedobjectiv, quantity, totalQuantity, eligible, needTimer, duration, GetTime() - (elapsed or 0))

            if numIncomplete == MAX_OBJECTIVES then
                self:AddObjective("...", false, firstunfinishedobjectiv, nil, nil, true)
                break
            end
        end
    else
        -- single criteria type of achievement
		-- check if we're supposed to show a timer bar for this
		local timerShown = false;
		local timerFailed = false;
		local timerCriteriaDuration = 0;
		local timerCriteriaStartTime = 0;
		for _, timedCriteria in pairs(parent.timedCriteria) do
			if timedCriteria.achievementID == self.id then
				local elapsed = GetTime() - timedCriteria.startTime;
				if elapsed <= timedCriteria.duration then
					timerCriteriaDuration = timedCriteria.duration;
					timerCriteriaStartTime = timedCriteria.startTime;
					timerShown = true;
				else
					timerFailed = true;
				end
				break;
			end
		end
        local eligible = (not timerFailed and IsAchievementEligible(self.id)) and true or false

        self:AddObjective(description, false, true, nil, nil, eligible, timerShown, timerCriteriaDuration, timerCriteriaStartTime)
    end

    for i = self.numObjectives + 1, 20 do
        if _G[self:GetName() .. "GwAchievementObjective" .. i] ~= nil then
            _G[self:GetName() .. "GwAchievementObjective" .. i]:Hide()
        end
    end

    self:SetHeight(self.height)
end

function GwAchievementTrackerBlockMixin:AddObjective(text, finished, firstunfinishedobjectiv, qty, totalqty, eligible, timerShown, duration, starTime)
    if finished or not text then
        return
    end

    self.numObjectives = self.numObjectives + 1
    local objectiveBlock = self:GetObjectiveBlock(firstunfinishedobjectiv)

    objectiveBlock:Show()
    objectiveBlock.ObjectiveText:SetText(GW.FormatObjectiveNumbers(text))
    objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
    if eligible then
        objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
    else
        objectiveBlock.ObjectiveText:SetTextColor(DIM_RED_FONT_COLOR.r, DIM_RED_FONT_COLOR.g, DIM_RED_FONT_COLOR.b)
    end

    if GW.ParseObjectiveString (objectiveBlock, text, nil, nil, qty, totalqty) then
        --added progressbar in ParseObjectiveString
    else
        objectiveBlock.StatusBar:Hide()
    end
    local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
    objectiveBlock:SetHeight(h)
    if objectiveBlock.StatusBar:IsShown() then
        if self.numObjectives >= 1 then
            h = h + objectiveBlock.StatusBar:GetHeight() + 10
        else
            h = h + objectiveBlock.StatusBar:GetHeight() + 5
        end
        objectiveBlock:SetHeight(h)
    end

    if timerShown then
        objectiveBlock:AddTimer(duration, starTime)
    else
        objectiveBlock.TimerBar:Hide()
    end
    self.height = self.height + objectiveBlock:GetHeight()
end

function GwAchievementTrackerBlockMixin:GetObjectiveBlock(firstunfinishedobjectiv)
    if _G[self:GetName() .. "GwAchievementObjective" .. self.numObjectives] then
        _G[self:GetName() .. "GwAchievementObjective" .. self.numObjectives]:SetScript("OnUpdate", nil)

        return _G[self:GetName() .. "GwAchievementObjective" .. self.numObjectives]
    end

    if firstunfinishedobjectiv then
        self.objectiveBlocks = {}
    end

    local newBlock = CreateFrame("Frame", self:GetName() .. "GwAchievementObjective" .. self.numObjectives, self, "GwQuesttrackerObjectiveTemplate")
    newBlock:SetParent(self)

    self.objectiveBlocks[#self.objectiveBlocks] = newBlock

    if firstunfinishedobjectiv then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint(
            "TOPRIGHT",
            _G[self:GetName() .. "GwAchievementObjective" .. self.numObjectives - 1],
            "BOTTOMRIGHT",
            0,
            0
        )
    end

    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)
    newBlock.TimerBar:Hide()
    newBlock.TimerBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    Mixin(newBlock, GwAchievementTrackerObjectiveMixin)

    return newBlock
end

function GwAchievementTrackerBlockMixin:OnClick(mouseButton)
    if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
        local achievementLink = GetAchievementLink(self.id)
        if (achievementLink) then
            ChatEdit_InsertLink(achievementLink)
        end
    elseif (mouseButton ~= "RightButton") then
        if (not AchievementFrame) then
            AchievementFrame_LoadUI()
        end
        if (IsModifiedClick("QUESTWATCHTOGGLE")) then
            C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, self.id, Enum.ContentTrackingStopType.Manual);
            if AchievementFrameAchievements_ForceUpdate then
                AchievementFrameAchievements_ForceUpdate();
            end
        elseif (not AchievementFrame:IsShown()) then
            AchievementFrame_ToggleAchievementFrame()
            AchievementFrame_SelectAchievement(self.id)
        else
            if (AchievementFrameAchievements.selection ~= self.id) then
                AchievementFrame_SelectAchievement(self.id)
            else
                AchievementFrame_ToggleAchievementFrame()
            end
        end
    else
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
            local _, achievementName = GetAchievementInfo(self.id);
            rootDescription:CreateTitle(achievementName)
            rootDescription:CreateButton(OBJECTIVES_VIEW_ACHIEVEMENT, function() OpenAchievementFrameToAchievement(self.id) end)
            rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function() C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, self.id, Enum.ContentTrackingStopType.Manual);
                if AchievementFrameAchievements_ForceUpdate then
                    AchievementFrameAchievements_ForceUpdate();
                end
            end)
        end)
    end
end

