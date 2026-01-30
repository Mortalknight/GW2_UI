local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local ChatEdit_GetActiveWindow = ChatFrameUtil and ChatFrameUtil.GetActiveWindow or ChatEdit_GetActiveWindow
local ChatEdit_InsertLink = ChatFrameUtil and ChatFrameUtil.InsertLink or ChatEdit_InsertLink

local MAX_OBJECTIVES = 10
GwAchievementTrackerBlockMixin = {}
function GwAchievementTrackerBlockMixin:UpdateBlock(parent)
    local numIncomplete = 0
    local numCriteria = GetAchievementNumCriteria(self.id)
    local description = select(8, GetAchievementInfo(self.id))

    self.height = 35
    self.numObjectives = 0

    if numCriteria > 0 then
        for criteriaIndex = 1, numCriteria do
            local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, _, flags, assetID, quantityString, _, eligible, duration, elapsed = GetAchievementCriteriaInfo(self.id, criteriaIndex)

            if not criteriaCompleted and criteriaString then
                numIncomplete = numIncomplete + 1

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

                self:AddObjective(criteriaString, numIncomplete, {isAchievement = true, qty = quantity, totalqty = totalQuantity, eligible = eligible, timerShown = needTimer, duration = duration, startTime = GetTime() - (elapsed or 0)})
                if numIncomplete == MAX_OBJECTIVES then
                    self:AddObjective("...", numIncomplete + 1, {isAchievement = true, qty = nil, totalqty = nil, eligible = true, timerShown = false, duration = nil, startTime = nil})
                    break
                end
            end
        end
    else
        -- single criteria type of achievement
		-- check if we're supposed to show a timer bar for this
		local timerShown = false
		local timerFailed = false
		local timerCriteriaDuration = 0
		local timerCriteriaStartTime = 0
		for _, timedCriteria in pairs(parent.timedCriteria) do
			if timedCriteria.achievementID == self.id then
				local elapsed = GetTime() - timedCriteria.startTime
				if elapsed <= timedCriteria.duration then
					timerCriteriaDuration = timedCriteria.duration
					timerCriteriaStartTime = timedCriteria.startTime
					timerShown = true
				else
					timerFailed = true
				end
				break;
			end
		end
        local eligible = (not timerFailed and IsAchievementEligible(self.id)) and true or false

        self:AddObjective(description, 1, {isAchievement = true, qty = nil, totalqty = nil, eligible = eligible, timerShown = timerShown, duration = timerCriteriaDuration, startTime = timerCriteriaStartTime})
    end

    self:SetHeight(self.height)
end

GwAchievementTrackerContainerMixin = {}
function GwAchievementTrackerContainerMixin:BlockOnClick(mouseButton)
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
            if GW.Retail then
                C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, self.id, Enum.ContentTrackingStopType.Manual)
            else
                WatchFrame_StopTrackingAchievement(_, self.id)
            end
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
            rootDescription:SetMinimumWidth(1)
            local _, achievementName = GetAchievementInfo(self.id);
            rootDescription:CreateTitle(achievementName)
            rootDescription:CreateButton(OBJECTIVES_VIEW_ACHIEVEMENT, function() OpenAchievementFrameToAchievement(self.id) end)
            rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function()
                if GW.Retail then
                    C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, self.id, Enum.ContentTrackingStopType.Manual)
                else
                    WatchFrame_StopTrackingAchievement(_, self.id)
                end
                if AchievementFrameAchievements_ForceUpdate then
                    AchievementFrameAchievements_ForceUpdate();
                end
            end)
            rootDescription:CreateButton("Wowhead URL", function()
                GW.ShowPopup({text = "WoWHead URL",
                    hasEditBox = true,
                    hideOnEscape = true,
                    EditBoxOnEnterPressed = function(popup) popup:Hide() end,
                    EditBoxOnEscapePressed = function(popup) popup:Hide() end,
                    button2 = CLOSE,
                    inputText = (function()
                        return GW.GetWowheadLinkForLanguage() .. "achievement=" .. self.id

                    end)(),
                    })
            end)
        end)
    end
end
function GwAchievementTrackerContainerMixin:UpdateLayout(event, ...)
    local savedHeight = 1
    local shownIndex = 1
    local trackedAchievements = GW.Retail and C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement) or {GetTrackedAchievements()}

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
            block.id = achievementID
            block:UpdateBlock(self)

            block.Header:SetText(achievementName)

            block:Show()

            block:SetScript("OnClick", block.OnClick)

            savedHeight = savedHeight + block.height

            shownIndex = shownIndex + 1
        end
    end

    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(savedHeight)

    for i = shownIndex, #self.blocks do
        self.blocks[i]:Hide()
    end

    GwQuestTracker:LayoutChanged()
end

local function OnEvent(self, event, ...)
    self:UpdateLayout(event, ...)
end

function GwAchievementTrackerContainerMixin:InitModule()
    self:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED")
    self:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE")
    self:RegisterEvent("ACHIEVEMENT_EARNED")
    if GW.Retail then
        self:RegisterEvent("CONTENT_TRACKING_UPDATE")
    end
    self:SetScript("OnEvent", OnEvent)

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0, 0.5, 0, 0.25)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(TRACKER_HEADER_ACHIEVEMENTS)

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function
    self.header.title:SetTextColor(
        TRACKER_TYPE_COLOR.ACHIEVEMENT.r,
        TRACKER_TYPE_COLOR.ACHIEVEMENT.g,
        TRACKER_TYPE_COLOR.ACHIEVEMENT.b
    )

    self.timedCriteria = {}
    self.blockMixInTemplate = GwAchievementTrackerBlockMixin

    self:UpdateLayout()
end
