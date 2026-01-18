local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local NavigableContentTrackingTargets = {
    [Enum.ContentTrackingTargetType.Vendor] = true,
    [Enum.ContentTrackingTargetType.JournalEncounter] = true,
};
local blockIndex
local savedHeight

GwObjectivesCollectionBlockMixin = CreateFromMixins(POIButtonOwnerMixin)

function GwObjectivesCollectionBlockMixin:UpdateBlock()
    local ignoreWaypoint = true
    local trackingResult, uiMapID = C_ContentTracking.GetBestMapForTrackable(self.trackableType, self.trackableID, ignoreWaypoint)
    self.endLocationUIMap = (trackingResult == Enum.ContentTrackingResult.Success) and uiMapID or nil

    local objectiveText = C_ContentTracking.GetObjectiveText(self.targetType, self.targetID)
    if objectiveText then
        self:AddObjective(objectiveText, 1, {})
    else
        self:AddObjective(CONTENT_TRACKING_RETRIEVING_INFO, 1, {})
    end

    if NavigableContentTrackingTargets[self.targetType] then
        -- If data is still pending, show nothing extra and wait for it to load.
        if objectiveText and (trackingResult ~= Enum.ContentTrackingResult.DataPending) then
            if not self.endLocationUIMap then
                self:AddObjective(CONTENT_TRACKING_LOCATION_UNAVAILABLE, 2, {})
            else
                local navigableTrackingResult, isNavigable = C_ContentTracking.IsNavigable(self.trackableType, self.trackableID)
                if (navigableTrackingResult == Enum.ContentTrackingResult.Failure) or (navigableTrackingResult == Enum.ContentTrackingResult.Success and not isNavigable) then
                    self:AddObjective(CONTENT_TRACKING_ROUTE_UNAVAILABLE, 2, {})
                else
                    local superTrackedType, superTrackedID = C_SuperTrack.GetSuperTrackedContent()
                    if (self.trackableType == superTrackedType) and (self.trackableID == superTrackedID) then
                        local waypointText = C_ContentTracking.GetWaypointText(self.trackableType, self.trackableID)
                        if waypointText then
                            local formattedText = OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION:format(waypointText)
                            self:AddObjective(formattedText, 2, {})
                        end
                    end
                end
            end
        end
    end

    if ObjectiveTrackerManager:CanShowPOIs(self) then
        local poiButton = self:GetButtonForTrackable(self.trackableType, self.trackableID)
        if poiButton then
            poiButton:SetPoint("TOPRIGHT", self.Header, "TOPLEFT", -3, -5)
            poiButton.NormalTexture:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/132060.png")
            poiButton.PushedTexture:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/132060.png")
            poiButton.HighlightTexture:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/132060.png")
            poiButton.Display.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/132060.png")
            poiButton:SetSize(20, 20)
            poiButton.NormalTexture:SetSize(20, 20)
            poiButton.PushedTexture:SetSize(20, 20)
            poiButton.HighlightTexture:SetSize(20, 20)
            poiButton.Display.Icon:SetSize(20, 20)

            poiButton.NormalTexture:SetDesaturated(true)
            poiButton.PushedTexture:SetDesaturated(true)
            poiButton.HighlightTexture:SetDesaturated(true)
            poiButton.Display.Icon:SetDesaturated(true)

            poiButton.Glow:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/132060.png")
            if not poiButton.hooked then
                hooksecurefunc(poiButton.Display, "SetAtlas", function(btn)
                    btn.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/132060.png")
                    btn.Icon:SetSize(20, 20)
                end)
                poiButton.hooked = true
            end

            self.poiButton = poiButton
        end
    end
end

GwObjectivesCollectionContainerMixin = {}
local function updateCollectionLayout(self, trackableType, trackableID)
    local targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(trackableType, trackableID)

    if targetType then
        blockIndex = blockIndex + 1

        local block = self:GetBlock(blockIndex, "RECIPE", false)
        block:Init() -- POIButtonOwnerTemplate
        block.poiButton = nil
        block.trackableID = trackableID
        block.trackableType = trackableType
        block.targetType = targetType
        block.targetID = targetID
        block.height = 35
        block.numObjectives = 0

        local title = C_ContentTracking.GetTitle(trackableType, trackableID)
        block.title = title
        block.Header:SetText(title)
        block:UpdateBlock()

        if blockIndex == 1 then
            savedHeight = 20 -- for header
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
    end

    for i = blockIndex + 1, #self.blocks do
        local block = self.blocks[i]
        block:Hide()
        block.id = nil
        block.isRecraft = nil
        block.poiButton = nil
    end
    GwQuestTracker:LayoutChanged()

    if blockIndex > 25 then
        return false
    end

    return true
end

local function EnumerateTrackables(self, callback)
    local hasSomethingToTrack = false
    blockIndex = 0
    savedHeight = 1

    for _, trackableType in ipairs(C_ContentTracking.GetCollectableSourceTypes()) do
        local trackedIDs = C_ContentTracking.GetTrackedIDs(trackableType)
        for _, trackableID in ipairs(trackedIDs) do
            hasSomethingToTrack = true
            if not callback(trackableType, trackableID) then
                break
            end
        end
    end
    if not hasSomethingToTrack or (hasSomethingToTrack and self.collapsed) then
        if not hasSomethingToTrack then
            self.header:Hide()
        else
            savedHeight = 20 -- for header
        end
        for i = 1, #self.blocks do
            self.blocks[i]:Hide()
        end

        self:SetHeight(savedHeight)
        GwQuestTracker:LayoutChanged()
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

function GwObjectivesCollectionContainerMixin:UpdateLayout()
    -- POIButtonOwnerTemplate
    for i = 1, 25 do
        local block = _G["GwQuesttrackerContainerCollectionBlock" .. i]
        if block then
            block:ResetUsage()
        end
    end
    StopTrackingCollectedItems(self)
    EnumerateTrackables(self, GenerateClosure(updateCollectionLayout, self))
end

function GwObjectivesCollectionContainerMixin:OnEvent()
    if not ContentTrackingUtil.IsContentTrackingEnabled() then return end

    self:UpdateLayout()
end

function GwObjectivesCollectionContainerMixin:BlockOnClick(button)
    if not ContentTrackingUtil.ProcessChatLink(self.trackableType, self.trackableID) then
        if button ~= "RightButton" then
            if ContentTrackingUtil.IsTrackingModifierDown() then
                C_ContentTracking.StopTracking(self.trackableType, self.trackableID, Enum.ContentTrackingStopType.Manual)
            elseif (self.trackableType == Enum.ContentTrackingType.Appearance) and IsModifiedClick("DRESSUP") then
                DressUpVisual(self.trackableID);
            elseif self.targetType == Enum.ContentTrackingTargetType.Achievement then
                OpenAchievementFrameToAchievement(self.targetID)
            elseif self.targetType == Enum.ContentTrackingTargetType.Profession then
                AdventureObjectiveTrackerMixin:ClickProfessionTarget(self.targetID)
            else
                ContentTrackingUtil.OpenMapToTrackable(self.trackableType, self.trackableID)
            end

            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        else
            MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
                rootDescription:SetMinimumWidth(1)
                rootDescription:CreateTitle(self.title)
                rootDescription:CreateButton(CONTENT_TRACKING_OPEN_JOURNAL_OPTION, function() TransmogUtil.OpenCollectionToItem(self.trackableID) end)
                rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function() C_ContentTracking.StopTracking(self.trackableType, self.trackableID, Enum.ContentTrackingStopType.Manual) end)
            end)
        end
    end
end

function GwObjectivesCollectionContainerMixin:InitModule()
    self:RegisterEvent("SUPER_TRACKING_CHANGED")
    self:RegisterEvent("TRACKING_TARGET_INFO_UPDATE")
    self:RegisterEvent("TRACKABLE_INFO_UPDATE")
    self:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
    self:RegisterEvent("CONTENT_TRACKING_UPDATE")
    self:SetScript("OnEvent", self.OnEvent)

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0.5, 1, 0.75, 1)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(ADVENTURE_TRACKING_MODULE_HEADER_TEXT)

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function
    self.header.title:SetTextColor(TRACKER_TYPE_COLOR.RECIPE.r, TRACKER_TYPE_COLOR.RECIPE.g, TRACKER_TYPE_COLOR.RECIPE.b)

    self.blockMixInTemplate = GwObjectivesCollectionBlockMixin

    self:UpdateLayout()
end
