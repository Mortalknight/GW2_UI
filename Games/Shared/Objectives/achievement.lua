---@class GW2
local GW = select(2, ...)

local ChatEdit_GetActiveWindow = ChatFrameUtil and ChatFrameUtil.GetActiveWindow or ChatEdit_GetActiveWindow
local ChatEdit_InsertLink = ChatFrameUtil and ChatFrameUtil.InsertLink or ChatEdit_InsertLink

local MAX_OBJECTIVES = 10
GwAchievementTrackerBlockMixin = {}
function GwAchievementTrackerBlockMixin:UpdateBlock(parent)
    local numIncomplete = 0
    local numCriteria = GetAchievementNumCriteria(self.id)
    local description = select(8, GetAchievementInfo(self.id))
    local showCompletedObjectives = GW.settings.OBJECTIVES_SHOW_COMPLETED_OBJECTIVES

    self.height = GW.GetObjectivesWideBlockBaseHeight()
    self.numObjectives = 0

    if numCriteria > 0 then
        for criteriaIndex = 1, numCriteria do
            local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, _, flags, assetID, quantityString, _, eligible, duration, elapsed = GetAchievementCriteriaInfo(self.id, criteriaIndex)

            if (not criteriaCompleted or showCompletedObjectives) and criteriaString then
                numIncomplete = numIncomplete + 1

                if (description and bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR) then
                    -- progress bar
                    if (string.find(strlower(quantityString), "interface/moneyframe") or string.find(strlower(quantityString), "interface/moneyframe")) then -- no easy way of telling it's a money progress bar ("\" for mac and linux)
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

                self:AddObjective(criteriaString, {isAchievement = true, finished = criteriaCompleted, useCompletedLine = showCompletedObjectives, qty = quantity, totalqty = totalQuantity, eligible = eligible, timerShown = needTimer, duration = duration, startTime = GetTime() - (elapsed or 0)})
                if numIncomplete == MAX_OBJECTIVES then
                    self:AddObjective("...", {isAchievement = true, qty = nil, totalqty = nil, eligible = true, timerShown = false, duration = nil, startTime = nil})
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

        self:AddObjective(description, {isAchievement = true, qty = nil, totalqty = nil, eligible = eligible, timerShown = timerShown, duration = timerCriteriaDuration, startTime = timerCriteriaStartTime})
    end

    self:SetHeight(self.height)
end


local function AttemptToOpenAchievement(achievementID, clickAgainToClose)
    if Narci_AchievementFrame then
        Narci_AchievementFrame:LocateAchievement(achievementID, clickAgainToClose);
    else
        Narci.LoadAchievementPanel(achievementID, clickAgainToClose);
    end
end

local function CloseDefaultWindow()
    local f = AchievementFrame;
    if f and f:IsShown() then
        if InCombatLockdown() then
            --f:Hide();
            --"Hide" doesn't seem to cause Interface Failure, but UIPanel still considers it opened
            --which affects frame anchors and cause Esc unable to clear targets or open Game Menu
        else
            HideUIPanel(f);
        end
    end
end

GwAchievementTrackerContainerMixin = {}
function GwAchievementTrackerContainerMixin:BlockOnClick(mouseButton)
    local isNarcissusAchievementFrameDefault = NarciAchievementOptions and NarciAchievementOptions.UseAsDefault
    if isNarcissusAchievementFrameDefault then
        C_AddOns.EnableAddOn("Narcissus_Achievements")
        C_AddOns.LoadAddOn("Narcissus_Achievements")
        if Narci_AchievementFrame and Narci_AchievementFrame.Init then
            Narci_AchievementFrame:Init()
        end
    end
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
            if C_AddOns.IsAddOnLoaded("Narcissus_Achievements") and isNarcissusAchievementFrameDefault then
                AttemptToOpenAchievement(self.id, true)
                CloseDefaultWindow()
            else
                AchievementFrame_ToggleAchievementFrame()
                AchievementFrame_SelectAchievement(self.id)
            end
        else
            if C_AddOns.IsAddOnLoaded("Narcissus_Achievements") and isNarcissusAchievementFrameDefault then
                AttemptToOpenAchievement(self.id, true)
                CloseDefaultWindow()
            else
                if (AchievementFrameAchievements.selection ~= self.id) then
                    AchievementFrame_SelectAchievement(self.id)
                else
                    AchievementFrame_ToggleAchievementFrame()
                end
            end
        end
    else
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
            rootDescription:SetMinimumWidth(1)
            local _, achievementName = GetAchievementInfo(self.id);
            rootDescription:CreateTitle(achievementName)
            rootDescription:CreateButton(OBJECTIVES_VIEW_ACHIEVEMENT, function()
                if C_AddOns.IsAddOnLoaded("Narcissus_Achievements") and isNarcissusAchievementFrameDefault then
                    AttemptToOpenAchievement(self.id, true)
                    CloseDefaultWindow()
                else
                    OpenAchievementFrameToAchievement(self.id)
                end
            end)
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
            rootDescription:CreateButton(GW.L["Wowhead URL"], function()
                GW.ShowPopup({text = GW.L["Wowhead URL"],
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
local function AchievementLayoutFlushOnUpdate(frame)
    frame:SetScript("OnUpdate", nil)

    local container = frame.container
    container.layoutUpdateQueued = false
    container:UpdateLayout()
    GwQuestTracker:LayoutChanged()
end

function GwAchievementTrackerContainerMixin:QueueUpdateLayout(event, ...)
    if event == "TRACKED_ACHIEVEMENT_UPDATE" then
        local achievementID, criteriaID, elapsed, duration = ...
        if elapsed and duration then
            -- Handle timer bars for achievements without visible criteria.
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

    if self.layoutUpdateQueued then
        return
    end

    self.layoutUpdateQueued = true
    self.layoutUpdateFrame:SetScript("OnUpdate", AchievementLayoutFlushOnUpdate)
end

function GwAchievementTrackerContainerMixin:UpdateLayout()
    local savedHeight = 0.1
    local shownIndex = 1
    local trackedAchievements = GW.Retail and C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement) or {GetTrackedAchievements()}

    self.header:Hide()

    local numAchievements = #trackedAchievements
    if self.collapsed and numAchievements > 0 then
        self.header:Show()
        numAchievements = 0
        savedHeight = GW.GetObjectivesHeaderHeight()
    end

    for i = 1, numAchievements do
        local achievementID = trackedAchievements[i]
        local achievementName = select(2, GetAchievementInfo(achievementID))
        local wasEarnedByMe = select(13, GetAchievementInfo(achievementID))

        if not wasEarnedByMe then
            if shownIndex == 1 then
                savedHeight = GW.GetObjectivesHeaderHeight()
            end

            self.header:Show()
            local block = self:GetBlock(shownIndex, GW.Enum.ObjectivesNotificationType.Achievement, false)
            block.id = achievementID
            block:UpdateBlock(self)

            block.Header:SetText(achievementName)

            block:Show()

            block:SetScript("OnClick", block.OnClick)

            savedHeight = savedHeight + block.height

            shownIndex = shownIndex + 1
        end
    end

    self:SetHeight(savedHeight)

    for i = shownIndex, #self.blocks do
        self.blocks[i]:Hide()
    end

end

local function OnEvent(self, event, ...)
    self:QueueUpdateLayout(event, ...)
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
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(TRACKER_HEADER_ACHIEVEMENTS)

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:ToggleCollapsed() end) -- this way, otherwiese we have a wrong self at the function
    self.header.title:SetTextColor(GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Achievement]:GetRGB())

    self.timedCriteria = {}
    self.layoutUpdateFrame = CreateFrame("Frame", nil, self)
    self.layoutUpdateFrame.container = self
    self.layoutUpdateQueued = false
    self.blockMixInTemplate = GwAchievementTrackerBlockMixin

    self:QueueUpdateLayout()
end
