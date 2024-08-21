local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local ParseObjectiveString = GW.ParseObjectiveString
local FormatObjectiveNumbers = GW.FormatObjectiveNumbers
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local QuestTrackerLayoutChanged = GW.QuestTrackerLayoutChanged
local setBlockColor = GW.setBlockColor

local MAX_OBJECTIVES = 10

local function achievement_OnClick(block, mouseButton)
    if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
        local achievementLink = GetAchievementLink(block.id)
        if (achievementLink) then
            ChatEdit_InsertLink(achievementLink)
        end
    elseif (mouseButton ~= "RightButton") then
        if (not AchievementFrame) then
            AchievementFrame_LoadUI()
        end
        if (IsModifiedClick("QUESTWATCHTOGGLE")) then
            C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, block.id, Enum.ContentTrackingStopType.Manual);
            if AchievementFrameAchievements_ForceUpdate then
                AchievementFrameAchievements_ForceUpdate();
            end
        elseif (not AchievementFrame:IsShown()) then
            AchievementFrame_ToggleAchievementFrame()
            AchievementFrame_SelectAchievement(block.id)
        else
            if (AchievementFrameAchievements.selection ~= block.id) then
                AchievementFrame_SelectAchievement(block.id)
            else
                AchievementFrame_ToggleAchievementFrame()
            end
        end
    else
        MenuUtil.CreateContextMenu(block, function(ownerRegion, rootDescription)
            local _, achievementName = GetAchievementInfo(block.id);
            rootDescription:CreateTitle(achievementName)
            rootDescription:CreateButton(OBJECTIVES_VIEW_ACHIEVEMENT, function() OpenAchievementFrameToAchievement(block.id) end)
            rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function() C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, block.id, Enum.ContentTrackingStopType.Manual);
                if AchievementFrameAchievements_ForceUpdate then
                    AchievementFrameAchievements_ForceUpdate();
                end
            end)
        end)
    end
end
GW.AddForProfiling("achievement", "achievement_OnClick", achievement_OnClick)

local function getObjectiveBlock(self, firstunfinishedobjectiv)
    if _G[self:GetName() .. "GwAchievementObjective" .. self.numObjectives] then
        _G[self:GetName() .. "GwAchievementObjective" .. self.numObjectives]:SetScript("OnUpdate", nil)

        return _G[self:GetName() .. "GwAchievementObjective" .. self.numObjectives]
    end

    if firstunfinishedobjectiv then
        self.objectiveBlocks = {}
    end

    local newBlock = CreateObjectiveNormal(self:GetName() .. "GwAchievementObjective" .. self.numObjectives, self)
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

    return newBlock
end
GW.AddForProfiling("achievement", "getObjectiveBlock", getObjectiveBlock)

local function getBlock(blockIndex)
    if _G["GwAchivementBlock" .. blockIndex] ~= nil then
       return  _G["GwAchivementBlock" .. blockIndex]
    end

    local newBlock = CreateTrackerObject("GwAchivementBlock" .. blockIndex, GwQuesttrackerContainerAchievement)
    newBlock:SetParent(GwQuesttrackerContainerAchievement)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerAchievement, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwAchivementBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end
    newBlock.height = 0
    setBlockColor(newBlock, "ACHIEVEMENT")
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    return newBlock
end
GW.AddForProfiling("achievement", "getBlock", getBlock)


local START_PERCENTAGE_YELLOW = .66;
local START_PERCENTAGE_RED = .33;
local function GetTextColor(self, timeRemaining)
	local elapsed = self.duration - timeRemaining;
	local percentageLeft = 1 - ( elapsed / self.duration )
	if percentageLeft > START_PERCENTAGE_YELLOW then
		return 1, 1, 1;
	elseif percentageLeft > START_PERCENTAGE_RED then -- Start fading to yellow by eliminating blue
		local blueOffset = (percentageLeft - START_PERCENTAGE_RED) / (START_PERCENTAGE_YELLOW - START_PERCENTAGE_RED);
		return 1, 1, blueOffset;
	else
		local greenOffset = percentageLeft / START_PERCENTAGE_RED; -- Fade to red by eliminating green
		return 1, greenOffset, 0;
	end
end

local function TimerBarOnUpdate(self)
    local timeNow = GetTime()
	local timeRemaining = self.duration - (timeNow - self.startTime)
	self.TimerBar:SetValue(timeRemaining)
    if timeRemaining < 0 then
		-- hold at 0 for a moment
		if timeRemaining > -1 then
			timeRemaining = 0;
        else
            self.TimerBar:Hide()
            GW.UpdateAchievementLayout(GwQuesttrackerContainerAchievement)
		end
	end
	self.TimerBar.Label:SetText(SecondsToClock(timeRemaining))
	self.TimerBar.Label:SetTextColor(GetTextColor(self, timeRemaining))
end

local function addTimer(block, duration, startTime)
    block.TimerBar:Show()
    block.TimerBar:SetMinMaxValues(0, duration)
    block.startTime = startTime;
    block.duration = duration;

    block:SetHeight(block:GetHeight() + 15)

    block.TimerBar:ClearAllPoints()
    if block.StatusBar:IsShown() then
        block.TimerBar:SetPoint("BOTTOMRIGHT", block.StatusBar, 0, -20)
    else
        block.TimerBar:SetPoint("BOTTOMRIGHT", block.ObjectiveText)
    end

    block:SetScript("OnUpdate", TimerBarOnUpdate)
end


local function addObjective(block, text, finished, firstunfinishedobjectiv, qty, totalqty, eligible, timerShown, duration, starTime)
    if finished or not text then
        return
    end

    block.numObjectives = block.numObjectives + 1
    local objectiveBlock = getObjectiveBlock(block, firstunfinishedobjectiv)

    objectiveBlock:Show()
    objectiveBlock.ObjectiveText:SetText(FormatObjectiveNumbers(text))
    objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
    if eligible then
        objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
    else
        objectiveBlock.ObjectiveText:SetTextColor(DIM_RED_FONT_COLOR.r, DIM_RED_FONT_COLOR.g, DIM_RED_FONT_COLOR.b)
    end

    if ParseObjectiveString(objectiveBlock, text, nil, nil, qty, totalqty) then
        --added progressbar in ParseObjectiveString
    else
        objectiveBlock.StatusBar:Hide()
    end
    local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
    objectiveBlock:SetHeight(h)
    if objectiveBlock.StatusBar:IsShown() then
        if block.numObjectives >= 1 then
            h = h + objectiveBlock.StatusBar:GetHeight() + 10
        else
            h = h + objectiveBlock.StatusBar:GetHeight() + 5
        end
        objectiveBlock:SetHeight(h)
    end

    if timerShown then
        addTimer(objectiveBlock, duration, starTime)
    else
        objectiveBlock.TimerBar:Hide()
    end
    block.height = block.height + objectiveBlock:GetHeight()
end
GW.AddForProfiling("achievement", "addObjective", addObjective)

local function updateAchievementObjectives(block, parent)
    local numIncomplete = 0
    local numCriteria = GetAchievementNumCriteria(block.id)
    local description = select(8, GetAchievementInfo(block.id))
    local firstunfinishedobjectiv = false

    block.height = 35
    block.numObjectives = 0

    if numCriteria > 0 then
        for criteriaIndex = 1, numCriteria do
            local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, _, flags, assetID, quantityString, _, eligible, duration, elapsed = GetAchievementCriteriaInfo(block.id, criteriaIndex)

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
            addObjective(block, criteriaString, criteriaCompleted, firstunfinishedobjectiv, quantity, totalQuantity, eligible, needTimer, duration, GetTime() - (elapsed or 0))

            if numIncomplete == MAX_OBJECTIVES then
                addObjective(block, "...", false, firstunfinishedobjectiv, nil, nil, true)
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
			if timedCriteria.achievementID == block.id then
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
        local eligible = (not timerFailed and IsAchievementEligible(block.id)) and true or false

        addObjective(block, description, false, true, nil, nil, eligible, timerShown, timerCriteriaDuration, timerCriteriaStartTime)
    end

    for i = block.numObjectives + 1, 20 do
        if _G[block:GetName() .. "GwAchievementObjective" .. i] ~= nil then
            _G[block:GetName() .. "GwAchievementObjective" .. i]:Hide()
        end
    end

    block:SetHeight(block.height)
end
GW.AddForProfiling("achievement", "updateAchievementObjectives", updateAchievementObjectives)

local function updateAchievementLayout(self, event, ...)
    local savedHeight = 1
    local shownIndex = 1
    local trackedAchievements = C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)

    self.header:Hide()

    local numQuests = #trackedAchievements
    if self.collapsed and numQuests > 0 then
        self.header:Show()
        numQuests = 0
        savedHeight = 20
    end

    if event == "TRACKED_ACHIEVEMENT_UPDATE" then
        local achievementID, criteriaID, elapsed, duration = ...;
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

    for i = 1, numQuests do
        local achievementID = trackedAchievements[i]
        local achievementName = select(2, GetAchievementInfo(achievementID))
        local wasEarnedByMe = select(13, GetAchievementInfo(achievementID))

        if not wasEarnedByMe then
            if i == 1 then
                savedHeight = 20
            end

            self.header:Show()
            local block = getBlock(shownIndex)
            if block == nil then
                return
            end
            block.id = achievementID
            updateAchievementObjectives(block, self)

            block.Header:SetText(achievementName)

            block:Show()

            block:SetScript("OnClick", achievement_OnClick)

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

    QuestTrackerLayoutChanged()
end
GW.UpdateAchievementLayout = updateAchievementLayout
GW.AddForProfiling("achievement", "updateAchievementLayout", updateAchievementLayout)

local function CollapseHeader(self, forceCollapse, forceOpen)
    if (not self.collapsed or forceCollapse) and not forceOpen then
        self.collapsed = true
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        self.collapsed = false
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    updateAchievementLayout(GwQuesttrackerContainerAchievement)
end
GW.CollapseAchievementHeader = CollapseHeader

local function LoadAchievementFrame()
    GwQuesttrackerContainerAchievement:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED")
    GwQuesttrackerContainerAchievement:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE")
    GwQuesttrackerContainerAchievement:RegisterEvent("ACHIEVEMENT_EARNED")
    GwQuesttrackerContainerAchievement:RegisterEvent("CONTENT_TRACKING_UPDATE")
    GwQuesttrackerContainerAchievement:SetScript("OnEvent", updateAchievementLayout)

    GwQuesttrackerContainerAchievement.header = CreateFrame("Button", nil, GwQuesttrackerContainerAchievement, "GwQuestTrackerHeader")
    GwQuesttrackerContainerAchievement.header.icon:SetTexCoord(0, 0.5, 0, 0.25)
    GwQuesttrackerContainerAchievement.header.title:SetFont(UNIT_NAME_FONT, 14)
    GwQuesttrackerContainerAchievement.header.title:SetShadowOffset(1, -1)
    GwQuesttrackerContainerAchievement.header.title:SetText(TRACKER_HEADER_ACHIEVEMENTS)

    GwQuesttrackerContainerAchievement.collapsed = false
    GwQuesttrackerContainerAchievement.header:SetScript("OnMouseDown",
        function(self)
            CollapseHeader(self:GetParent(), false, false)
        end
    )
    GwQuesttrackerContainerAchievement.header.title:SetTextColor(
        TRACKER_TYPE_COLOR.ACHIEVEMENT.r,
        TRACKER_TYPE_COLOR.ACHIEVEMENT.g,
        TRACKER_TYPE_COLOR.ACHIEVEMENT.b
    )

    GwQuesttrackerContainerAchievement.timedCriteria = {}

    updateAchievementLayout(GwQuesttrackerContainerAchievement)
end
GW.LoadAchievementFrame = LoadAchievementFrame
