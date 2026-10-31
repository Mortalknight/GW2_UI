---@class GW2
local GW = select(2, ...)

local MAX_SHOWN = 3
local MAX_CANDIDATES = 30
local SCAN_BUDGET_MS = 2
local MIN_PROGRESS = 0.5
local LOGIN_SCAN_DELAY = 10
local LAYOUT_DELAY = 5
local EXCLUDED_CATEGORIES = {[81] = true, [15234] = true} -- feats of strength, legacy

local function IsExcludedCategory(categoryID)
    while categoryID and categoryID > 0 do
        if EXCLUDED_CATEGORIES[categoryID] then
            return true
        end
        categoryID = select(2, GetCategoryInfo(categoryID))
    end
    return false
end

-- several criteria count as done of all, a single one only with its own progress bar;
-- the criteria are expensive to read, so counting stops once too many are missing for MIN_PROGRESS
local function GetProgress(achievementID)
    local numCriteria = GetAchievementNumCriteria(achievementID)
    if numCriteria == 1 then
        local _, _, _, quantity, reqQuantity, _, flags, _, quantityString = GetAchievementCriteriaInfo(achievementID, 1)
        if flags and bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) ~= 0 and not strlower(quantityString or ""):find("moneyframe") and quantity >= reqQuantity * MIN_PROGRESS then
            return quantity, reqQuantity
        end
    elseif numCriteria > 1 then
        local maxMissing = numCriteria * (1 - MIN_PROGRESS)
        local missing = 0
        for i = 1, numCriteria do
            if not select(3, GetAchievementCriteriaInfo(achievementID, i)) then
                missing = missing + 1
                if missing > maxMissing then return end
            end
        end
        return numCriteria - missing, numCriteria
    end
end

local function IsTracked(id)
    if GW.isModern then
        return C_ContentTracking.IsTracking(Enum.ContentTrackingType.Achievement, id)
    end
    return IsTrackedAchievement(id)
end

local function Track(id)
    if GW.isModern then
        C_ContentTracking.StartTracking(Enum.ContentTrackingType.Achievement, id)
    else
        AddTrackedAchievement(id)
    end
end

local function SortCandidates(a, b)
    if a.progress ~= b.progress then
        return a.progress > b.progress
    end
    return a.total - a.done < b.total - b.done
end

GwObjectivesNearlyDoneBlockMixin = {}

function GwObjectivesNearlyDoneBlockMixin:UpdateBlock(done, total)
    local description = select(8, GetAchievementInfo(self.id))
    self.height = GW.GetObjectivesBlockBaseHeight()
    self.numObjectives = 0

    self:AddObjective(GW.ParseCriteria(done, total, description), {isAchievement = true, eligible = true, qty = done, totalqty = total})

    self:SetHeight(self.height)
end

GwObjectivesNearlyDoneContainerMixin = {}

function GwObjectivesNearlyDoneContainerMixin:UpdateLayout()
    local shownIndex = 1
    local hidden = GW.private.hiddenNearlyDoneAchievements

    self.header:Hide()

    if GW.settings.objectives.nearlyDone then
        for _, id in ipairs(GW.private.nearlyDoneCandidates) do
            if shownIndex > MAX_SHOWN then break end

            local done, total = GetProgress(id)
            if done and done < total and not hidden[id] and not select(4, GetAchievementInfo(id)) and not IsTracked(id) then
                self.header:Show()
                if self.collapsed then break end

                local block = self:GetBlock(shownIndex, GW.Enum.ObjectivesNotificationType.Achievement, false)
                block.id = id
                block.Header:SetText((select(2, GetAchievementInfo(id))))
                block:UpdateBlock(done, total)
                block:Show()

                shownIndex = shownIndex + 1
            end
        end
    end

    for i = shownIndex, #self.blocks do
        self.blocks[i]:Hide()
        self.blocks[i].id = nil
    end

    self:LayoutBlocks(shownIndex - 1)

    GwQuestTracker:LayoutChanged()
end

local function FinishScan(container)
    local results = container.scan.results
    container.scan = nil
    container.scanFrame:SetScript("OnUpdate", nil)

    table.sort(results, SortCandidates)
    local candidates = {}
    for i = 1, math.min(#results, MAX_CANDIDATES) do
        candidates[i] = results[i].id
    end
    -- kept per character, so the section is there right after the next login
    GW.private.nearlyDoneCandidates = candidates
    container:UpdateLayout()
end

-- reading every criteria of every achievement takes far too long for one frame, so each frame
-- only gets a small time budget; in combat the scan waits
local function ScanStep(scanFrame)
    if InCombatLockdown() then return end

    local container = scanFrame.container
    local scan = container.scan
    local stopAt = debugprofilestop() + SCAN_BUDGET_MS

    while debugprofilestop() < stopAt do
        scan.achievementIndex = scan.achievementIndex + 1
        if scan.achievementIndex > scan.numAchievements then
            scan.categoryIndex = scan.categoryIndex + 1
            local categoryID = scan.categories[scan.categoryIndex]
            if not categoryID then
                FinishScan(container)
                return
            end
            scan.categoryID = categoryID
            scan.achievementIndex = 0
            scan.numAchievements = IsExcludedCategory(categoryID) and 0 or GetCategoryNumAchievements(categoryID)
        else
            local id, _, _, completed = GetAchievementInfo(scan.categoryID, scan.achievementIndex)
            if id and not completed then
                local done, total = GetProgress(id)
                if done and done < total then
                    tinsert(scan.results, {id = id, done = done, total = total, progress = done / total})
                end
            end
        end
    end
end

function GwObjectivesNearlyDoneContainerMixin:StartScan()
    if self.scan or not GW.settings.objectives.nearlyDone then return end

    self.scan = {categories = GetCategoryList(), categoryIndex = 0, achievementIndex = 0, numAchievements = 0, results = {}}
    self.scanFrame:SetScript("OnUpdate", ScanStep)
end

function GwObjectivesNearlyDoneContainerMixin:QueueScan(delay)
    if self.scanQueued then return end

    self.scanQueued = true
    C_Timer.After(delay, function()
        self.scanQueued = false
        self:StartScan()
    end)
end

-- criteria change with almost every kill: only the known candidates are updated, and at most every few seconds
function GwObjectivesNearlyDoneContainerMixin:QueueLayout()
    if self.layoutQueued then return end

    self.layoutQueued = true
    C_Timer.After(LAYOUT_DELAY, function()
        self.layoutQueued = false
        self:UpdateLayout()
    end)
end

function GwObjectivesNearlyDoneContainerMixin:OnEvent(event)
    if not GW.settings.objectives.nearlyDone then return end

    if event == "ACHIEVEMENT_EARNED" then
        self:QueueScan(LAYOUT_DELAY)
    elseif event == "CRITERIA_UPDATE" then
        self:QueueLayout()
    else
        self:UpdateLayout()
    end
end

local function OpenAchievement(id)
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    if not AchievementFrame:IsShown() then
        AchievementFrame_ToggleAchievementFrame()
    end
    AchievementFrame_SelectAchievement(id)
end

function GwObjectivesNearlyDoneContainerMixin:BlockOnClick(mouseButton)
    if IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() then
        ChatFrameUtil.InsertLink(GetAchievementLink(self.id))
    elseif mouseButton ~= "RightButton" then
        OpenAchievement(self.id)
    else
        MenuUtil.CreateContextMenu(self, function(_, rootDescription)
            rootDescription:SetMinimumWidth(1)
            rootDescription:CreateTitle((select(2, GetAchievementInfo(self.id))))
            rootDescription:CreateButton(OBJECTIVES_VIEW_ACHIEVEMENT, function() OpenAchievement(self.id) end)
            rootDescription:CreateButton(TRACK_ACHIEVEMENT, function() Track(self.id) end)
            rootDescription:CreateButton(HIDE, function()
                GW.private.hiddenNearlyDoneAchievements[self.id] = true
                self:GetParent():UpdateLayout()
            end)
        end)
    end
end

function GwObjectivesNearlyDoneContainerMixin:InitModule()
    self:RegisterEvent("CRITERIA_UPDATE")
    self:RegisterEvent("ACHIEVEMENT_EARNED")
    if GW.isModern then
        self:RegisterEvent("CONTENT_TRACKING_UPDATE")
    else
        self:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED")
    end
    self:SetScript("OnEvent", self.OnEvent)

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0, 0.5, 0, 0.25)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, "SHADOW")
    self.header.title:SetText(GW.L["Nearly Done"])

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:ToggleCollapsed() end) -- this way, otherwiese we have a wrong self at the function
    self.header.title:SetTextColor(GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Achievement]:GetRGB())

    self.scanFrame = CreateFrame("Frame")
    self.scanFrame.container = self
    self.blockMixInTemplate = GwObjectivesNearlyDoneBlockMixin

    self:UpdateLayout()
    self:QueueScan(LOGIN_SCAN_DELAY)
end

function GW.UpdateNearlyDoneAchievements()
    local container = GW.ObjectiveTrackerContainer and GW.ObjectiveTrackerContainer.NearlyDone
    if not container then return end

    container:UpdateLayout()
    container:StartScan()
end
