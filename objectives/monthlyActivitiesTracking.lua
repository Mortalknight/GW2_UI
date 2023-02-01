local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local ParseObjectiveString = GW.ParseObjectiveString
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local setBlockColor = GW.setBlockColor

local function MonthlyActivitiesObjectiveTracker_OpenFrameToActivity(activityID)
	if not EncounterJournal then
		EncounterJournal_LoadUI()
	end
	MonthlyActivitiesFrame_OpenFrameToActivity(activityID)
end

local function MonthlyActivitiesObjectiveTracker_UntrackPerksActivity(_, perksActivityID)
	C_PerksActivities.RemoveTrackedPerksActivity(perksActivityID)
end


local function MonthlyActivitiesObjectiveTracker_OnOpenDropDown(self)
    local block = self.activeFrame;

	local info = UIDropDownMenu_CreateInfo()
	info.text = block.title
	info.isTitle = 1
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)

	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = 1

	info.text = OBJECTIVES_VIEW_IN_QUESTLOG;
	info.func = function (button, ...) MonthlyActivitiesObjectiveTracker_OpenFrameToActivity(...) end
	info.arg1 = block.id
	info.checked = false
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)

	info.text = OBJECTIVES_STOP_TRACKING
	info.func = MonthlyActivitiesObjectiveTracker_UntrackPerksActivity
	info.arg1 = block.id
	info.checked = false
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
end

local function monthlyActivities_OnClick(self, button)
    if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local perksActivityLink = C_PerksActivities.GetPerksActivityChatLink(self.id)
		ChatEdit_InsertLink(perksActivityLink)
	elseif button ~= "RightButton" then
		CloseDropDownMenus()
		if not EncounterJournal then
			EncounterJournal_LoadUI()
		end
		if IsModifiedClick("QUESTWATCHTOGGLE") then
			MonthlyActivitiesObjectiveTracker_UntrackPerksActivity(_, self.id)
		else
			MonthlyActivitiesFrame_OpenFrameToActivity(self.id)
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	else
		ObjectiveTracker_ToggleDropDown(self, MonthlyActivitiesObjectiveTracker_OnOpenDropDown)
	end
end

local function getObjectiveBlock(self)
    if _G[self:GetName() .. "Objective" .. self.numObjectives] then
        return _G[self:GetName() .. "Objective" .. self.numObjectives]
    end

    self.objectiveBlocks = self.objectiveBlocks or {}

    local newBlock = CreateObjectiveNormal(self:GetName() .. "Objective" .. self.numObjectives, self)
    newBlock:SetParent(self)

    self.objectiveBlocks[#self.objectiveBlocks] = newBlock

    if self.numObjectives == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint("TOPRIGHT", _G[self:GetName() .. "Objective" .. self.numObjectives - 1], "BOTTOMRIGHT", 0, 0)
    end

    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    return newBlock
end

local function getBlock(blockIndex)
    if _G["GwMonthlyActivityBlock" .. blockIndex] then
        return  _G["GwMonthlyActivityBlock" .. blockIndex]
    end

    local newBlock = CreateTrackerObject("GwMonthlyActivityBlock" .. blockIndex, GwQuesttrackerContainerMonthlyActivity)
    newBlock:SetParent(GwQuesttrackerContainerMonthlyActivity)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerMonthlyActivity, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwMonthlyActivityBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end
    newBlock.height = 0
    setBlockColor(newBlock, "MONTHLYACTIVITY")
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    return newBlock
end

local function addObjective(block, text, finished, qty, totalqty)
    if finished or not text then
        return
    end

    block.numObjectives = block.numObjectives + 1
    local objectiveBlock = getObjectiveBlock(block)

    objectiveBlock:Show()
    if qty < totalqty then
        objectiveBlock.ObjectiveText:SetText(GW.CommaValue(qty) .. "/" .. GW.CommaValue(totalqty) .. " " .. text)
    else
        objectiveBlock.ObjectiveText:SetText(text)
    end
    objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
    objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)

    if ParseObjectiveString(objectiveBlock, text, nil, nil, qty, totalqty) then
        --added progressbar in ParseObjectiveString
    else
        objectiveBlock.StatusBar:Hide()
    end
    local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
    objectiveBlock:SetHeight(h)
    if objectiveBlock.StatusBar:IsShown() then
        if block.numObjectives >= 1 then
            h = h + objectiveBlock.StatusBar:GetHeight() + 5
        else
            h = h + objectiveBlock.StatusBar:GetHeight() + 5
        end
        objectiveBlock:SetHeight(h)
    end
    block.height = block.height + objectiveBlock:GetHeight()
end

local function updateActivityObjectives(block, requirements)
    block.height = 25
    block.numObjectives = 0

    for _, requirement in ipairs(requirements) do
        if not requirement.completed then
            local criteriaString = requirement.requirementText
            criteriaString = string.gsub(criteriaString, " / ", "/")
            criteriaString = string.gsub(criteriaString, "- ", "")
            addObjective(block, criteriaString, false, 0, 0)
        end
    end

    for i = block.numObjectives + 1, 20 do
        if _G[block:GetName() .. "Objective" .. i] then
            _G[block:GetName() .. "Objective" .. i]:Hide()
        end
    end

    block:SetHeight(block.height)
end

local function Update(self)
    local trackedActivities = C_PerksActivities.GetTrackedPerksActivities().trackedIDs
    local savedHeight = 1
    local shownIndex = 1

    self.header:Hide()

    if self.collapsed and #trackedActivities > 0 then
        self.header:Show()
        wipe(trackedActivities)
        savedHeight = 20
    end

    for i = 1, #trackedActivities do
        local activityID = trackedActivities[i]
        local activityInfo = C_PerksActivities.GetPerksActivityInfo(activityID)

        self.header:Show()
        if activityInfo and not activityInfo.completed then
            local activityName = activityInfo.activityName
			local requirements = activityInfo.requirementsList
            local block = getBlock(shownIndex)
            if block == nil then
                return
            end

            block.id = activityID
            block.title = activityName
            block.Header:SetText(activityName)
            -- criteria
            updateActivityObjectives(block, requirements)
            block:Show()

            block:SetScript("OnClick", monthlyActivities_OnClick)

            savedHeight = savedHeight + block.height

            shownIndex = shownIndex + 1
        end
    end

    self:SetHeight(savedHeight)

    for i = shownIndex, 25 do
        if _G["GwMonthlyActivityBlock" .. i] then
            _G["GwMonthlyActivityBlock" .. i]:Hide()
            _G["GwMonthlyActivityBlock" .. i].id = nil
        end
    end

    GW.QuestTrackerLayoutChanged()
end

local function OnEvent(self, event, ...)
    if event == "PERKS_ACTIVITIES_TRACKED_UPDATED" then
        Update(self)
    elseif event == "PERKS_ACTIVITY_COMPLETED" then
        local trackedActivities = C_PerksActivities.GetTrackedPerksActivities().trackedIDs
        local perksActivityID = ...
        for i = 1, #trackedActivities do
            local activityID = trackedActivities[i]
            if activityID == perksActivityID then
                PlaySound(SOUNDKIT.TRADING_POST_UI_COMPLETING_ACTIVITIES)
                break
            end
        end
    end
end

local function CollapseHeader(self, forceCollapse, forceOpen)
    if (not self.collapsed or forceCollapse) and not forceOpen then
        self.collapsed = true
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        self.collapsed = false
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    Update(GwQuesttrackerContainerMonthlyActivity, IsRecrafting)
end
GW.CollapseonthlyActivitiesHeader = CollapseHeader

local function LoadMonthlyActivitiesTracking(self)
    self:RegisterEvent("PERKS_ACTIVITIES_TRACKED_UPDATED")
    self:RegisterEvent("PERKS_ACTIVITY_COMPLETED")
    self:SetScript("OnEvent", OnEvent)

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0.5, 1, 0.75, 1)
    self.header.title:SetFont(UNIT_NAME_FONT, 14)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(TRACKER_HEADER_MONTHLY_ACTIVITIES)

    self.collapsed = false
    self.header:SetScript("OnMouseDown",
        function(self)
            CollapseHeader(self:GetParent(), false, false)
        end
    )
    self.header.title:SetTextColor(
        TRACKER_TYPE_COLOR.MONTHLYACTIVITY.r,
        TRACKER_TYPE_COLOR.MONTHLYACTIVITY.g,
        TRACKER_TYPE_COLOR.MONTHLYACTIVITY.b
    )

    Update(self)
end
GW.LoadMonthlyActivitiesTracking = LoadMonthlyActivitiesTracking
