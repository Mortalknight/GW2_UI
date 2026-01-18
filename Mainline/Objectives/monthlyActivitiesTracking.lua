local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local ChatEdit_GetActiveWindow = ChatFrameUtil and ChatFrameUtil.GetActiveWindow or ChatEdit_GetActiveWindow


GwObjectivesMonthlyActivitiesBlockMixin = {}

function GwObjectivesMonthlyActivitiesBlockMixin:UpdateBlock(requirements)
    self.height = 25
    self.numObjectives = 0

    for idx, requirement in ipairs(requirements) do
        if not requirement.completed then
            local criteriaString = requirement.requirementText
            criteriaString = string.gsub(criteriaString, " / ", "/")
            criteriaString = string.gsub(criteriaString, "- ", "")
            self:AddObjective(criteriaString, idx, {isMonthlyActivity = true, finished = false})
        end
    end

    for i = (self.numObjectives or 0) + 1, #self.objectiveBlocks do
        self.objectiveBlocks[i]:Hide()
    end

    self:SetHeight(self.height)
end

GwObjectivesMonthlyActivitiesContainerMixin = {}

function GwObjectivesMonthlyActivitiesContainerMixin:UpdateLayout()
    local trackedActivities = C_PerksActivities.GetTrackedPerksActivities().trackedIDs
    local savedHeight = 1
    local shownIndex = 1
    local showHeader = false

    self.header:Hide()

    if self.collapsed and #trackedActivities > 0 then
        self.header:Show()
        wipe(trackedActivities)
        savedHeight = 20
    end

    for i = 1, #trackedActivities do
        local activityID = trackedActivities[i]
        local activityInfo = C_PerksActivities.GetPerksActivityInfo(activityID)

        if activityInfo and not activityInfo.completed then
            local activityName = activityInfo.activityName
			local requirements = activityInfo.requirementsList
            local block = self:GetBlock(shownIndex, "MONTHLYACTIVITY", false)
            if block == nil then
                return
            end

            block.id = activityID
            block.title = activityName
            block.Header:SetText(activityName)
            -- criteria
            block:UpdateBlock(requirements)
            block:Show()

            savedHeight = savedHeight + block.height

            shownIndex = shownIndex + 1

            self.header:Show()
            showHeader = true
        end
    end

    if showHeader and not self.collapsed then
        savedHeight = savedHeight + 20
    end
    self:SetHeight(savedHeight)

    for i = shownIndex, 25 do
        if _G["GwQuesttrackerContainerMonthlyActivityBlock" .. i] then
            _G["GwQuesttrackerContainerMonthlyActivityBlock" .. i]:Hide()
            _G["GwQuesttrackerContainerMonthlyActivityBlock" .. i].id = nil
        end
    end

    GwQuestTracker:LayoutChanged()
end

function GwObjectivesMonthlyActivitiesContainerMixin:OnEvent(event, ...)
    if event == "PERKS_ACTIVITIES_TRACKED_UPDATED" or event == "PERKS_ACTIVITIES_TRACKED_LIST_CHANGED" then
        self:UpdateLayout()
    elseif event == "PERKS_ACTIVITY_COMPLETED" then
        local trackedActivities = C_PerksActivities.GetTrackedPerksActivities().trackedIDs
        local perksActivityID = ...
        for i = 1, #trackedActivities do
            local activityID = trackedActivities[i]
            if activityID == perksActivityID then
                PlaySound(SOUNDKIT.TRADING_POST_UI_COMPLETING_ACTIVITIES)
                self:UpdateLayout()
                break
            end
        end
    end
end

function GwObjectivesMonthlyActivitiesContainerMixin:BlockOnClick(button)
    if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local perksActivityLink = C_PerksActivities.GetPerksActivityChatLink(self.id)
		ChatFrameUtil.InsertLink(perksActivityLink)
	elseif button ~= "RightButton" then
		if not EncounterJournal then
			EncounterJournal_LoadUI()
		end
		if IsModifiedClick("QUESTWATCHTOGGLE") then
			C_PerksActivities.RemoveTrackedPerksActivity(self.id)
		else
			MonthlyActivitiesFrame_OpenFrameToActivity(self.id)
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	else
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
            rootDescription:SetMinimumWidth(1)
            rootDescription:CreateTitle(self.title)
            rootDescription:CreateButton(OBJECTIVES_VIEW_IN_QUESTLOG, function()
                if not EncounterJournal then
                    EncounterJournal_LoadUI()
                end
                MonthlyActivitiesFrame_OpenFrameToActivity(self.id)
            end)
            rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function()
                C_PerksActivities.RemoveTrackedPerksActivity(self.id)
            end)
        end)
	end
end

function GwObjectivesMonthlyActivitiesContainerMixin:InitModule()
    self:RegisterEvent("PERKS_ACTIVITIES_TRACKED_UPDATED")
    self:RegisterEvent("PERKS_ACTIVITY_COMPLETED")
    self:RegisterEvent("PERKS_ACTIVITIES_TRACKED_LIST_CHANGED")
    self:SetScript("OnEvent", self.OnEvent)

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0.5, 1, 0.75, 1)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(TRACKER_HEADER_MONTHLY_ACTIVITIES)

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function
    self.header.title:SetTextColor(
        TRACKER_TYPE_COLOR.MONTHLYACTIVITY.r,
        TRACKER_TYPE_COLOR.MONTHLYACTIVITY.g,
        TRACKER_TYPE_COLOR.MONTHLYACTIVITY.b
    )

    self.blockMixInTemplate = GwObjectivesMonthlyActivitiesBlockMixin

    self:UpdateLayout()
end
