local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local setBlockColor = GW.setBlockColor

local NavigableContentTrackingTargets = {
	[Enum.ContentTrackingTargetType.Vendor] = true,
	[Enum.ContentTrackingTargetType.JournalEncounter] = true,
};
local blockIndex
local savedHeight

local function collection_OnClick(self, button)
    if not ContentTrackingUtil.ProcessChatLink(self.trackableType, self.trackableID) then
		if button ~= "RightButton" then
			CloseDropDownMenus()

			if ContentTrackingUtil.IsTrackingModifierDown() then
				C_ContentTracking.StopTracking(self.trackableType, self.trackableID, Enum.ContentTrackingStopType.Manual)
			elseif (self.trackableType == Enum.ContentTrackingType.Appearance) and IsModifiedClick("DRESSUP") then
				DressUpVisual(self.trackableID);
			elseif self.targetType == Enum.ContentTrackingTargetType.Achievement then
				OpenAchievementFrameToAchievement(self.targetID)
			elseif self.targetType == Enum.ContentTrackingTargetType.Profession then
				AdventureObjectiveTracker_ClickProfessionTarget(self.targetID)
			else
				ContentTrackingUtil.OpenMapToTrackable(self.trackableType, self.trackableID)
			end

			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		else
            MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
                rootDescription:CreateTitle(self.title)
                rootDescription:CreateButton(CONTENT_TRACKING_OPEN_JOURNAL_OPTION, function() TransmogUtil.OpenCollectionToItem(self.trackableID) end)
                rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function() C_ContentTracking.StopTracking(self.trackableType, self.trackableID, Enum.ContentTrackingStopType.Manual) end)
            end)
        end
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
    if _G["GwCollectionBlock" .. blockIndex] then
        return  _G["GwCollectionBlock" .. blockIndex]
    end

    local newBlock = CreateTrackerObject("GwCollectionBlock" .. blockIndex, GwQuesttrackerContainerCollection)
    newBlock:SetParent(GwQuesttrackerContainerCollection)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerCollection, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwCollectionBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end
    newBlock.height = 0
    setBlockColor(newBlock, "RECIPE")
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    return newBlock
end

local function addObjective(block, text)
    if not text then
        return
    end

    block.numObjectives = block.numObjectives + 1
    local objectiveBlock = getObjectiveBlock(block)

    objectiveBlock:Show()
    objectiveBlock.ObjectiveText:SetText(text)
    objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
    objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
    objectiveBlock.StatusBar:Hide()

    local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
    objectiveBlock:SetHeight(h)
    block.height = block.height + objectiveBlock:GetHeight()
end

local function updateCollectionLayout(self, trackableType, trackableID)
    local targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(trackableType, trackableID)

    if targetType then
        blockIndex = blockIndex + 1

        local block = getBlock(blockIndex)
        block.trackableID = trackableID
		block.trackableType = trackableType
        block.height = 35
        block.numObjectives = 0

		local title = C_ContentTracking.GetTitle(trackableType, trackableID)
		block.title = title
		block.Header:SetText(title)

		block.targetType = targetType
		block.targetID = targetID

        local ignoreWaypoint = true
		local trackingResult, uiMapID = C_ContentTracking.GetBestMapForTrackable(trackableType, trackableID, ignoreWaypoint)
		block.endLocationUIMap = (trackingResult == Enum.ContentTrackingResult.Success) and uiMapID or nil

		local objectiveText = C_ContentTracking.GetObjectiveText(targetType, targetID)
		if objectiveText then
            addObjective(block, objectiveText)
		else
            addObjective(block, CONTENT_TRACKING_RETRIEVING_INFO)
		end

        if NavigableContentTrackingTargets[targetType] then
			-- If data is still pending, show nothing extra and wait for it to load.
			if objectiveText and (trackingResult ~= Enum.ContentTrackingResult.DataPending) then
				if not block.endLocationUIMap then
                    addObjective(block, CONTENT_TRACKING_LOCATION_UNAVAILABLE)
				else
					local navigableTrackingResult, isNavigable = C_ContentTracking.IsNavigable(trackableType, trackableID);
					if (navigableTrackingResult == Enum.ContentTrackingResult.Failure) or
						(navigableTrackingResult == Enum.ContentTrackingResult.Success and not isNavigable) then
                        addObjective(block, CONTENT_TRACKING_ROUTE_UNAVAILABLE)
					end
				end
			end
		end

        for i = block.numObjectives + 1, 20 do
            if _G[block:GetName() .. "Objective" .. i] then
                _G[block:GetName() .. "Objective" .. i]:Hide()
            end
        end

        if blockIndex == 1 then
            savedHeight = 20
        end
        savedHeight = savedHeight + block.height

        block:SetHeight(block.height)
        self:SetHeight(savedHeight)

        if blockIndex <= 25 then
            self.header:Show()
            block:Show()
        else
            block:Hide()
        end

        block:SetScript("OnClick", collection_OnClick)
    end

    for i = blockIndex + 1, 25 do
        if _G["GwCollectionBlock" .. i] then
            _G["GwCollectionBlock" .. i]:Hide()
            _G["GwCollectionBlock" .. i].id = nil
            _G["GwCollectionBlock" .. i].isRecraft = nil
        end
    end
    GW.QuestTrackerLayoutChanged()

    if blockIndex > 25 then
        return false
    end

    return true
end

local function EnumerateTrackables(self, callback)
    local hasSomethingToTrack = false
    blockIndex = 0
    savedHeight = 1

    for i, trackableType in ipairs(C_ContentTracking.GetCollectableSourceTypes()) do
		local trackedIDs = C_ContentTracking.GetTrackedIDs(trackableType)
		for j, trackableID in ipairs(trackedIDs) do
            hasSomethingToTrack = true
			if not callback(trackableType, trackableID) then
				break
			end
		end
	end

    if not hasSomethingToTrack then
        self.header:Hide()
        for i = 1, 25 do
            if _G["GwCollectionBlock" .. i] then
                _G["GwCollectionBlock" .. i]:Hide()
            end
        end
        GW.QuestTrackerLayoutChanged()
    end

    if hasSomethingToTrack and self.collapsed then
        for i = 1, 25 do
            if _G["GwCollectionBlock" .. i] then
                _G["GwCollectionBlock" .. i]:Hide()
            end
        end
        GW.QuestTrackerLayoutChanged()
    end
end

local function StopTrackingCollectedItems(self)
	if not self.collectedIds then
		return
	end

	local removingCollectedObjective = false;
	for trackableId, trackableType in pairs(self.collectedIds) do
		C_ContentTracking.StopTracking(trackableType, trackableId, Enum.ContentTrackingStopType.Manual)
		removingCollectedObjective = true
	end
	if removingCollectedObjective then
		PlaySound(SOUNDKIT.CONTENT_TRACKING_OBJECTIVE_TRACKING_END)
	end
	self.collectedIds = nil
end

local function UpdateCollectionTrackingLayout(self)
    StopTrackingCollectedItems(self)
    EnumerateTrackables(self, GenerateClosure(updateCollectionLayout, self))
end
GW.UpdateCollectionTrackingLayout = UpdateCollectionTrackingLayout

local function OnEvent(self)
    if not ContentTrackingUtil.IsContentTrackingEnabled() then return end

    UpdateCollectionTrackingLayout(self)
end

local function CollapseHeader(self, forceCollapse, forceOpen)
    if (not self.collapsed or forceCollapse) and not forceOpen then
        self.collapsed = true
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        self.collapsed = false
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    UpdateCollectionTrackingLayout(self)
end
GW.CollapseCollectionHeader = CollapseHeader

local function LoadCollectionTracking(self)
    self:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
    self:RegisterEvent("CONTENT_TRACKING_UPDATE")
    self:RegisterEvent("TRACKING_TARGET_INFO_UPDATE")
    self:SetScript("OnEvent", OnEvent)

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0.5, 1, 0.75, 1)
    self.header.title:SetFont(UNIT_NAME_FONT, 14)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(ADVENTURE_TRACKING_MODULE_HEADER_TEXT)

    self.collapsed = false
    self.header:SetScript("OnMouseDown",
        function(self)
            CollapseHeader(self:GetParent(), false, false)
        end
    )
    self.header.title:SetTextColor(
        TRACKER_TYPE_COLOR.RECIPE.r,
        TRACKER_TYPE_COLOR.RECIPE.g,
        TRACKER_TYPE_COLOR.RECIPE.b
    )

    StopTrackingCollectedItems(self)
    EnumerateTrackables(self, GenerateClosure(updateCollectionLayout, self))
end
GW.LoadCollectionTracking = LoadCollectionTracking
