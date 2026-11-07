---@class GW2
local GW = select(2, ...)

local addonContainerWaitingQueue = {}

local function GetObjectivesTrackerModuleName(module)
    local moduleType = type(module)
    if moduleType == "string" then
        return module
    end

    if moduleType == "number" then
        return GW.GetEnumName(GW.Enum.ObjectivesBlockType, module)
    end

    if moduleType == "table" then
        if module.gwObjectivesModuleName then
            return module.gwObjectivesModuleName
        end

        if module.type then
            return GW.GetEnumName(GW.Enum.ObjectivesBlockType, module.type)
        end
    end

    return nil
end

local function BuildObjectivesTrackerModuleOrderIndex()
    local orderIndex = {}
    local nextOrder = 1

    local function AddModule(module)
        local moduleName = GetObjectivesTrackerModuleName(module)
        if not moduleName then return end

        if not orderIndex[moduleName] then
            orderIndex[moduleName] = nextOrder
            nextOrder = nextOrder + 1
        end
    end

    local function AddOrderList(list)
        if not list or type(list) ~= "table" then return end

        for _, module in ipairs(list) do
            AddModule(module)
        end
    end

    AddOrderList(GW.settings.objectives.moduleOrder)
    AddOrderList(GW.globalDefault.profile.objectives.moduleOrder)

    return orderIndex
end


local function SortObjectivesTrackerScrollableContainers()
    local containers = GW.QuestTrackerScrollableContainer
    if not containers then return end

    local orderIndex = BuildObjectivesTrackerModuleOrderIndex()

    local originalIndex = {}
    for i, frame in ipairs(containers) do
        originalIndex[frame] = i
    end

    table.sort(containers, function(a, b)
        local aName = GetObjectivesTrackerModuleName(a)
        local bName = GetObjectivesTrackerModuleName(b)

        local aOrder = aName and orderIndex[aName] or nil
        local bOrder = bName and orderIndex[bName] or nil

        if aOrder and bOrder then
            if aOrder ~= bOrder then
                return aOrder < bOrder
            end
        elseif aOrder then
            return true
        elseif bOrder then
            return false
        end

        local aFallback = a.gwScrollableContainerCreationIndex or originalIndex[a] or 0
        local bFallback = b.gwScrollableContainerCreationIndex or originalIndex[b] or 0

        if aFallback ~= bFallback then
            return aFallback < bFallback
        end

        return (originalIndex[a] or 0) < (originalIndex[b] or 0)
    end)
end

local function IsPinnedSection(container)
    return container.gwCollapsedByScroll and container.collapsed and container:IsShown()
end

local function GetStickyContainer()
    local tracker = GwQuestTracker
    if not tracker or not tracker.ScrollFrame then return nil end
    local scroll = tracker.ScrollFrame:GetVerticalScroll()
    local headerHeight = GW.GetObjectivesHeaderHeight()
    local current = GW.QuestTrackerStickyContainer
    local top = 0
    local sticky

    for _, frame in ipairs(GW.QuestTrackerScrollableContainer) do
        if frame:IsShown() and not IsPinnedSection(frame) then
            if frame.header and frame.header:IsShown() and not frame.collapsed then
                local threshold = frame == current and top or top + headerHeight
                if scroll >= threshold then
                    sticky = frame
                end
            end
            top = top + frame:GetHeight()
        end
    end

    return sticky
end

local function GetStickyHeaderHeight()
    return GW.QuestTrackerStickyContainer and GW.GetObjectivesHeaderHeight() or 0
end

local function AnchorObjectivesTrackerScrollableContainers()
    local tracker = GwQuestTracker
    if not tracker or not tracker.ScrollFrame or not tracker.ScrollFrame.Child then return end
    if not GW.QuestTrackerScrollableContainer then return end

    local child = tracker.ScrollFrame.Child
    local pinnedAnchor = GW.QuestTrackerFixedContainer[#GW.QuestTrackerFixedContainer]
    local previousScrolling
    local sticky = GetStickyContainer()
    GW.QuestTrackerStickyContainer = sticky

    tracker.ScrollFrame:ClearAllPoints()
    for _, frame in ipairs(GW.QuestTrackerScrollableContainer) do
        frame:ClearAllPoints()
        if frame.gwHeaderStuck and frame ~= sticky then
            frame.gwHeaderStuck = nil
            frame.header:SetParent(frame)
            frame.header:ClearAllPoints()
            frame.header:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
        end
    end

    for _, frame in ipairs(GW.QuestTrackerScrollableContainer) do
        if IsPinnedSection(frame) then
            frame:SetParent(tracker)
            frame:SetPoint("TOPRIGHT", pinnedAnchor, "BOTTOMRIGHT")
            pinnedAnchor = frame
        else
            frame:SetParent(child)
            local offsetY = frame == sticky and GW.GetObjectivesHeaderHeight() or 0
            if previousScrolling then
                frame:SetPoint("TOPRIGHT", previousScrolling, "BOTTOMRIGHT", 0, offsetY)
            else
                frame:SetPoint("TOPRIGHT", child, "TOPRIGHT", 0, offsetY)
            end
            previousScrolling = frame
        end
    end

    if sticky then
        sticky.gwHeaderStuck = true
        sticky.header:SetParent(tracker)
        sticky.header:ClearAllPoints()
        sticky.header:SetPoint("TOPRIGHT", pinnedAnchor, "BOTTOMRIGHT")
        pinnedAnchor = sticky.header
    end

    tracker.ScrollFrame:SetPoint("TOPRIGHT", pinnedAnchor, "BOTTOMRIGHT")
    tracker.ScrollFrame:SetPoint("BOTTOMRIGHT", tracker, "BOTTOMRIGHT")
end

function GW.ApplyObjectivesTrackerModuleOrder()
    SortObjectivesTrackerScrollableContainers()
    AnchorObjectivesTrackerScrollableContainers()
    GW.RefreshObjectivesTrackerLayout()
end

function GW.IsObjectivesTrackerCompactMode()
    return GW.settings.objectives.compactMode
end

-- an empty container must not be exactly 0 high: the fixed containers are chained
-- through anchors, and a 0 height frame is not reliably positioned by them
GW.OBJECTIVES_EMPTY_HEIGHT = 0.1

-- Height of a container whose frames sit in fixed slots (boss and arena unit frames).
-- Those are SecureUnitButtons: they must not be moved in combat, so they keep their
-- slot chain and a hidden frame in between keeps its space - the height therefore has
-- to reach down to the last shown slot. Returns the height and that slot number.
function GW.GetFixedSlotContainerHeight(frames)
    local lastShown = 0
    for index, frame in pairs(frames) do
        if frame:IsShown() then
            lastShown = math.max(lastShown, index)
        end
    end

    if lastShown == 0 then
        return GW.OBJECTIVES_EMPTY_HEIGHT, 0
    end

    local height = 0
    for index, frame in pairs(frames) do
        if index <= lastShown then
            height = height + frame:GetHeight()
        end
    end

    return height, lastShown
end

function GW.GetObjectivesHeaderHeight()
    return GW.IsObjectivesTrackerCompactMode() and 16 or 20
end

function GW.GetObjectivesBlockBaseHeight()
    return -GW.GetObjectivesFirstObjectiveOffset()
end

-- scales both gaps below; compact mode keeps its own base values, so the two settings stay
-- independent - this one only stretches or tightens what compact mode picked
local function ScaleObjectivesGap(gap)
    return math.floor(gap * (GW.settings.objectives.spacing or 1) + 0.5)
end

function GW.GetObjectivesRowGap()
    return ScaleObjectivesGap(GW.IsObjectivesTrackerCompactMode() and 6 or 10)
end

function GW.GetObjectivesBlockGap()
    return ScaleObjectivesGap(GW.IsObjectivesTrackerCompactMode() and 5 or 8)
end

function GW.GetObjectivesEntrySpacing()
    return GW.IsObjectivesTrackerCompactMode() and 4 or 10
end

function GW.GetObjectivesStatusBarGap()
    return GW.IsObjectivesTrackerCompactMode() and 1 or 0
end

function GW.GetObjectivesTextPadding()
    return GW.IsObjectivesTrackerCompactMode() and 3 or 5
end

function GW.GetObjectivesRowTextOffset()
    return GW.IsObjectivesTrackerCompactMode() and 3 or 5
end

function GW.GetObjectivesFirstObjectiveOffset()
    return GW.IsObjectivesTrackerCompactMode() and -14 or -25
end

function GW.GetObjectivesTimerLabelHeight()
    return 10
end

function GW.GetObjectivesTimerIconSize()
    return GW.IsObjectivesTrackerCompactMode() and 12 or 14
end

function GW.GetObjectivesTimerGap()
    return GW.IsObjectivesTrackerCompactMode() and 5 or 8
end

function GW.GetObjectivesStatusBarBorderOverhang()
    return 2
end

function GW.ApplyObjectivesHeaderStyle(header)
    if not header then return end

    local compact = GW.IsObjectivesTrackerCompactMode()
    local headerHeight = GW.GetObjectivesHeaderHeight()

    header:SetHeight(headerHeight)
    if header.title then
        header.title:SetHeight(headerHeight)
        header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, compact and GW.Enum.TextSizeType.Normal or GW.Enum.TextSizeType.Header, "SHADOW")
    end

    if header.icon then
        local iconSize = compact and 22 or 26
        header.icon:SetSize(iconSize, iconSize)
        header.icon:ClearAllPoints()
        header.icon:SetPoint("CENTER", header, "LEFT", compact and -18 or -20, 0)
    end
end

-- Helper functions
local function ParseObjectiveString(block, text, numItems, numNeeded, overrideShowStatusbarSetting)
    block.StatusBar.precentage = false

    if not numItems or not numNeeded then
        numItems, numNeeded = string.match(text, "(%d+)/(%d+)")
    end

    numItems = tonumber(numItems)
    numNeeded = tonumber(numNeeded)

    if numItems and numNeeded and numNeeded > 1 and numItems < numNeeded then
        block.StatusBar:SetShown(overrideShowStatusbarSetting or GW.settings.objectives.statusBars)
        block.StatusBar:SetMinMaxValues(0, numNeeded)
        block.StatusBar:SetValue(numItems)
        block.progress = numItems / numNeeded
        return true
    end
    return false
end
GW.ParseObjectiveString = ParseObjectiveString
local function ParseSimpleObjective(text)
    if not text then return "" end
    local trimmed = strtrim(text)
    local itemName, numItems, numNeeded = string.match(trimmed, "^(.-):%s*([%d]+)%s*/%s*([%d]+)%s*$")

    if itemName and numItems and numNeeded then
        return string.format("%s: %s/%s", strtrim(itemName), numItems, numNeeded)
    end

    numItems, numNeeded, itemName = string.match(trimmed, "^(%d+)%s*/%s*(%d+)%s+(.+)$")
    if itemName and numItems and numNeeded then
        return string.format("%s: %s/%s", strtrim(itemName), numItems, numNeeded)
    end

    return trimmed
end
GW.ParseSimpleObjective = ParseSimpleObjective

local function ParseCriteria(quantity, totalQuantity, criteriaString, isMythicKeystone, mythicKeystoneCurrentValue, isWeightedProgress)
    if not (quantity and totalQuantity and criteriaString) then
        return criteriaString
    end

    if isMythicKeystone then
        if isWeightedProgress then
            local percent = mythicKeystoneCurrentValue / totalQuantity * 100
            return string.format("%s (%d/%d) %s", GW.GetLocalizedNumber(format("%.2f%%", percent)), mythicKeystoneCurrentValue, totalQuantity, criteriaString)
        end
        return string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
    end

    if totalQuantity == 0 then
        return string.format("%d %s", quantity, criteriaString)
    end

    local startPattern = "^%d+/%d+%s+"
    local endPattern = ":%s*%d+/%d+$"

    if criteriaString:match(startPattern) or criteriaString:match(endPattern) then
        return criteriaString
    end

    return string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
end
GW.ParseCriteria = ParseCriteria

local function FormatObjectiveNumbers(text)
    local itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)")

    if itemName == nil then
        numItems, numNeeded, itemName = string.match(text, "(%d+)/(%d+) ((.*))")
    end
    numItems = tonumber(numItems)
    numNeeded = tonumber(numNeeded)

    if numItems ~= nil and numNeeded ~= nil then
        return GW.GetLocalizedNumber(numItems) .. " / " .. GW.GetLocalizedNumber(numNeeded) .. " " .. itemName
    end
    return text
end
GW.FormatObjectiveNumbers = FormatObjectiveNumbers

local SCROLL_STEP = 15
local MIN_SCROLL_STOP_DISTANCE = 5

local function GetScrollStops(scrollFrame)
    local stops = {}
    local childTop = scrollFrame.Child:GetTop()
    if not childTop then return stops end
    for _, container in ipairs(GW.QuestTrackerScrollableContainer) do
        local top = container:IsShown() and not IsPinnedSection(container) and container:GetTop()
        if top then
            stops[#stops + 1] = childTop - top
            local isFirstBlock = true
            for _, block in ipairs(container.blocks or {}) do
                local blockTop = block:IsShown() and block:GetTop()
                if blockTop then
                    if not isFirstBlock then
                        stops[#stops + 1] = childTop - blockTop
                    end
                    isFirstBlock = false
                end
            end
        end
    end
    table.sort(stops)
    return stops
end

local function GetNextScroll(scrollFrame, delta)
    local current = scrollFrame:GetVerticalScroll()
    local stops = GetScrollStops(scrollFrame)
    local target
    if delta < 0 then
        for i = 1, #stops do
            if stops[i] > current + MIN_SCROLL_STOP_DISTANCE then target = stops[i] break end
        end
    else
        for i = #stops, 1, -1 do
            if stops[i] < current - MIN_SCROLL_STOP_DISTANCE then target = stops[i] break end
        end
    end
    if not target or math.abs(target - current) > (scrollFrame.visibleHeight or 0) then
        target = current - delta * SCROLL_STEP
    end
    return math.max(0, math.min(scrollFrame.maxScroll or 0, target))
end

local function FadeScrollIndicator(track, elapsed)
    local target = track:GetParent():IsMouseOver() and 1 or 0
    local alpha = track:GetAlpha()
    if math.abs(target - alpha) < 0.02 then
        track:SetAlpha(target)
    else
        track:SetAlpha(alpha + (target - alpha) * math.min(1, elapsed * 8))
    end
end

local function UpdateScrollIndicator(scrollFrame, scroll)
    local track = scrollFrame.gwScrollTrack
    if not track then
        track = CreateFrame("Frame", nil, scrollFrame)
        track:SetFrameLevel(scrollFrame.Child:GetFrameLevel() + 20)
        track:SetPoint("TOPRIGHT")
        track:SetWidth(4)
        local rail = track:CreateTexture(nil, "BACKGROUND")
        rail:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle.png")
        rail:SetAlpha(0.15)
        rail:SetAllPoints()
        track.thumb = track:CreateTexture(nil, "OVERLAY")
        track.thumb:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle.png")
        track.thumb:SetAlpha(0.7)
        track:SetAlpha(0)
        track:SetScript("OnUpdate", FadeScrollIndicator)
        scrollFrame.gwScrollTrack = track
    end

    local visible, maxScroll = scrollFrame.visibleHeight or 0, scrollFrame.maxScroll
    if maxScroll <= 0 or visible <= 0 then
        track:Hide()
        return
    end
    track:SetHeight(visible)
    local height = math.max(20, visible * visible / (visible + maxScroll))
    local y = (visible - height) * math.min(1, scroll / maxScroll)
    track.thumb:SetHeight(height)
    track.thumb:SetPoint("TOPLEFT", 0, -y)
    track.thumb:SetPoint("TOPRIGHT", 0, -y)
    track:Show()
end

local function UpdateScrollView()
    local scrollFrame = GwQuestTracker and GwQuestTracker.ScrollFrame
    local childTop = scrollFrame and scrollFrame.Child:GetTop()
    if not childTop then return end
    local scroll = scrollFrame:GetVerticalScroll()
    UpdateScrollIndicator(scrollFrame, scroll)
    if not InCombatLockdown() and GetStickyContainer() ~= GW.QuestTrackerStickyContainer then
        GwQuestTracker:LayoutChanged()
    end
end

function GW.ScrollObjectivesTrackerToContainer(container)
    local scrollFrame = GwQuestTracker.ScrollFrame
    local childTop, top = scrollFrame.Child:GetTop(), container:GetTop()
    if not (childTop and top) then return end
    scrollFrame:SetVerticalScroll(math.max(0, childTop - top))
    UpdateScrollView()
end

GwObjectivesTrackerMixin = {}
function GwObjectivesTrackerMixin:LayoutChanged()
    if not InCombatLockdown() then
        AnchorObjectivesTrackerScrollableContainers()
    end

    local stickyHeaderHeight = GetStickyHeaderHeight()
    local scrollContentHeight = -stickyHeaderHeight
    local visibleHeight = self:GetHeight() - stickyHeaderHeight
    for _, container in pairs(GW.QuestTrackerScrollableContainer) do
        if IsPinnedSection(container) then
            visibleHeight = visibleHeight - container:GetHeight()
        else
            scrollContentHeight = scrollContentHeight + container:GetHeight()
        end
    end

    -- the visible part is the tracker height below the fixed containers and the pinned sections
    for _, container in pairs(GW.QuestTrackerFixedContainer) do
        visibleHeight = visibleHeight - container:GetHeight()
    end
    local scroll = math.max(0, scrollContentHeight - visibleHeight)
    self.ScrollFrame.visibleHeight = visibleHeight
    self.ScrollFrame.maxScroll = scroll
    -- shrunk content, a collapsed section for example, must not leave the view scrolled into nothing
    if self.ScrollFrame:GetVerticalScroll() > scroll then
        self.ScrollFrame:SetVerticalScroll(scroll)
        self:AdjustItemButtonPositions()
    end
    UpdateScrollView()

    if InCombatLockdown() then
        GW.CombatQueue:Queue("GwQuestTrackerScrollLayout", self.LayoutChanged, {self})
        return
    end
    self.ScrollFrame:SetSize(self:GetWidth(), scrollContentHeight)
end

local ITEM_BUTTON_COLUMN_X = -362
local ITEM_BUTTON_TOP_NO_COMPASS = 1
local ITEM_BUTTON_TOP_WITH_COMPASS = 6
local NOTIFICATION_MAX_HEIGHT = 70
local ITEM_BUTTON_GAP = 6

local isNotificationHooked = false

function GW.LayoutObjectiveItemButtons()
    if not isNotificationHooked and GwObjectivesNotification then
        isNotificationHooked = true
        GwObjectivesNotification:HookScript("OnSizeChanged", GW.LayoutObjectiveItemButtons)
    end

    if InCombatLockdown() then
        GW.CombatQueue:Queue("LayoutObjectiveItemButtons", GW.LayoutObjectiveItemButtons)
        return
    end

    local containers = GW.ObjectiveTrackerContainer
    if not containers then return end

    local notificationHeight = GwObjectivesNotification and GwObjectivesNotification:GetHeight() or 0
    local extraHeight = math.max(notificationHeight - 1, 0)
    local progress = math.min(extraHeight / (NOTIFICATION_MAX_HEIGHT - 1), 1)
    local y = -(extraHeight + ITEM_BUTTON_TOP_NO_COMPASS + (ITEM_BUTTON_TOP_WITH_COMPASS - ITEM_BUTTON_TOP_NO_COMPASS) * progress)
    local function Place(block)
        local button = block and block.actionButton
        if not (button and block.hasItem and button:IsShown()) then return end
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", GwQuestTracker, "TOPRIGHT", ITEM_BUTTON_COLUMN_X, y)
        y = y - button:GetHeight() - ITEM_BUTTON_GAP
    end

    if containers.Scenario then
        Place(containers.Scenario.block)
    end
    for _, container in next, { containers.Campaign, containers.Quests, containers.Bonus } do
        if container and not container.collapsed then
            for i = 1, #container.blocks do
                Place(container.blocks[i])
            end
        end
    end
end

function GwObjectivesTrackerMixin:AdjustItemButtonPositions()
    local function Remove(key, block)
        if InCombatLockdown() then
            GW.CombatQueue:Queue(key, block.UpdateObjectiveActionButton, {block})
        else
            block:UpdateObjectiveActionButton()
        end
    end

    for _, container in next, { GW.ObjectiveTrackerContainer.Campaign, GW.ObjectiveTrackerContainer.Quests, GW.ObjectiveTrackerContainer.Bonus } do
        for i = 1, #container.blocks do
            local counter = container.numQuests or container.numEvents or 0
            if i > counter or container.collapsed then
                Remove("RemoveTrackerItemButtonForBlock: " .. container:GetDebugName() .. i, container.blocks[i])
            end
        end
    end

    GW.LayoutObjectiveItemButtons()
end

local function DisableBlizzardsObjevtiveTracker()
    if GW.isModern then
        ObjectiveTrackerFrame:Hide()
        ObjectiveTrackerFrame:UnregisterAllEvents()
        ObjectiveTrackerFrame:SetScript("OnUpdate", nil)
        hooksecurefunc(ObjectiveTrackerFrame, "Show", function(self)
            self:Hide()
        end)
        hooksecurefunc(ObjectiveTrackerFrame, "SetShown", function(self, show)
            if show then
                self:Hide()
            end
        end)
        EventRegistry:UnregisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", ObjectiveTrackerManager)

        -- the tracker modules register their events on themselves once the manager
        -- assigns them to the (hidden) container after PLAYER_ENTERING_WORLD, so an
        -- unregister here alone gets undone. Once our taint reaches the scenario
        -- modules state, C_Spell.GetSpellCooldown hands its cooldown update secret
        -- values CooldownFrame_Set cannot compare — its spell buttons are invisible
        -- anyway. Only this one event is muted: the module keeps running for its
        -- banners and toasts
        if ScenarioObjectiveTracker then
            -- on our own OnUpdate once the module is set up: a hook on SetContainer runs inside blizzards
            -- event and taints the rest of it, up to the gamepad bindings
            local muter = CreateFrame("Frame")
            muter:SetScript("OnUpdate", function(self)
                if ScenarioObjectiveTracker.init then
                    ScenarioObjectiveTracker:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
                    self:SetScript("OnUpdate", nil)
                end
            end)
        end
    elseif GW.Mists or GW.Wrath then
        WatchFrame:SetMovable(1)
        WatchFrame:SetUserPlaced(true)
        WatchFrame:Hide()
        WatchFrame:SetScript("OnShow",function() WatchFrame:Hide() end)
        SetCVar("autoQuestWatch", "1")
    elseif GW.Classic or GW.TBC then
        QuestWatchFrame:SetMovable(1)
        QuestWatchFrame:SetUserPlaced(true)
        QuestWatchFrame:Hide()
        QuestWatchFrame:SetScript("OnShow",function() QuestWatchFrame:Hide() end)
        SetCVar("autoQuestWatch", "1")
    end
end

local function GetTrackerSections()
    local sections = {}
    for _, container in ipairs(GW.QuestTrackerScrollableContainer) do
        if container:IsShown() and container.header and container.header:IsShown() then
            sections[#sections + 1] = container
        end
    end
    return sections
end

local function CollapseTopSectionOnScroll()
    local expanded = {}
    for _, section in ipairs(GetTrackerSections()) do
        if not section.collapsed then
            expanded[#expanded + 1] = section
        end
    end
    if #expanded < 2 then return false end

    expanded[1].gwCollapsedByScroll = true
    expanded[1]:SetCollapsed(true, "scroll")
    return true
end

local function ExpandLastCollapsedSectionOnScroll()
    local sections = GetTrackerSections()
    for i = #sections, 1, -1 do
        local section = sections[i]
        if section.gwCollapsedByScroll and section.collapsed then
            section.gwCollapsedByScroll = nil
            section:SetCollapsed(false, "scroll")
            return true
        end
    end
    return false
end

function GwObjectivesTrackerMixin:CreateTrackerScrollFrame(name, height)
    local scrollFrame = CreateFrame("ScrollFrame", name, self, "GwQuestTrackerScroll")
    scrollFrame:SetHeight(height)
    scrollFrame:SetScript("OnMouseWheel", function(frame, delta)
        local reachedTop = frame:GetVerticalScroll() <= 1
        if (delta < 0 and CollapseTopSectionOnScroll()) or (delta > 0 and reachedTop and ExpandLastCollapsedSectionOnScroll()) then
            frame:SetVerticalScroll(0)
            GwQuestTracker:LayoutChanged()
            UpdateScrollView()
            return
        end
        frame:SetVerticalScroll(GetNextScroll(frame, delta))
        UpdateScrollView()
    end)
    scrollFrame.maxScroll = 0
    return scrollFrame
end

function GwObjectivesTrackerMixin:CreateTrackerContainer(name, parent, mixin, template, enum)
    local frame = CreateFrame("Frame", name, parent, template or "GwQuesttrackerContainer")
    frame:SetParent(parent)
    frame.type = enum
    frame.gwObjectivesModuleName = GW.GetEnumName(GW.Enum.ObjectivesBlockType, enum)
    if mixin then
        Mixin(frame, mixin)
    end
    frame.blocks = {}

    return frame
end

function GwObjectivesTrackerMixin:OnEvent(_, ...)
    local addonName = ...
    for id, config in ipairs(addonContainerWaitingQueue) do
        if config.addonName == addonName then
            local frame = self:CreateTrackerContainer(config.name, self.ScrollFrame.Child, config.mixin, config.template, config.enum)

            GW.ObjectiveTrackerContainer[GW.GetEnumName(GW.Enum.ObjectivesBlockType, config.enum)] = frame

            table.insert(GW.QuestTrackerScrollableContainer, frame)

            if frame.InitModule then frame:InitModule() end

            GW.ApplyObjectivesHeaderStyle(frame.header)
            GW.ApplyObjectivesTrackerModuleOrder()
            GW.ToggleObjectivesAutoCollapse()

            table.remove(addonContainerWaitingQueue, id)
            break
        end
    end

    if #addonContainerWaitingQueue == 0 then
        self:UnregisterEvent("ADDON_LOADED")
    end
end

function GwObjectivesTrackerMixin:AddAddonContainerLoadingToQueue(config)
    table.insert(addonContainerWaitingQueue, config)

    if not self:IsEventRegistered("ADDON_LOADED") then
        self:RegisterEvent("ADDON_LOADED")
        self:SetScript("OnEvent", self.OnEvent)
    end
end

-- Shared runtime state of the tracker modules. layoutGeneration is bumped whenever the
-- layout affecting settings pass runs (compact mode etc.) — blocks and objective rows
-- re-apply their fonts/anchors only when their generation is behind, a content update
-- alone no longer re-styles every row
local ObjectivesTrackerState = {
    layoutGeneration = 1,
}
GW.ObjectivesTrackerState = ObjectivesTrackerState

function GW.RefreshObjectivesTrackerLayout()
    if not GwQuestTracker or not GW.ObjectiveTrackerContainer then
        return
    end

    ObjectivesTrackerState.layoutGeneration = ObjectivesTrackerState.layoutGeneration + 1

    local function RefreshObjectivesFrame(frame)
        GW.ApplyObjectivesHeaderStyle(frame.header)

        if frame == GW.ObjectiveTrackerContainer.Scenario then
            frame.timerBlock:TimerBlockOnEvent(nil)
        end

        if frame.UpdateLayout then
            frame:UpdateLayout()
        end
    end

    for _, frame in ipairs(GW.QuestTrackerFixedContainer or {}) do
        RefreshObjectivesFrame(frame)
    end

    for _, frame in ipairs(GW.QuestTrackerScrollableContainer or {}) do
        RefreshObjectivesFrame(frame)
    end

    GwQuestTracker:LayoutChanged()
    GwQuestTracker:AdjustItemButtonPositions()
end

local function LoadObjectivesTracker()
    -- container configuration
    local objectivesTrackerConfiguration = {
        { name = "GwObjectivesNotification", scrollable = false, mixin = GwObjectivesTrackerNotificationMixin, enum = GW.Enum.ObjectivesBlockType.Notification, template = "GwObjectivesNotification", load = true },
        { name = "GwQuesttrackerContainerBossFrames", scrollable = false, mixin = GwObjectivesBossContainerMixin, enum = GW.Enum.ObjectivesBlockType.BossFrames, load = not (GW.Classic or GW.TBC) },
        { name = "GwQuesttrackerContainerArenaBGFrames", scrollable = false, mixin = GwObjectivesArenaContainerMixin, enum = GW.Enum.ObjectivesBlockType.ArenaFrames, load = not GW.Classic },
        { name = "GwQuesttrackerContainerScenario", scrollable = false, mixin = GwObjectivesScenarioContainerMixin, enum = GW.Enum.ObjectivesBlockType.Scenario, load = not (GW.Classic or GW.TBC) },
        { name = "GwQuesttrackerContainerAchievement", scrollable = true, mixin = GwAchievementTrackerContainerMixin, enum = GW.Enum.ObjectivesBlockType.Achievement, load = not (GW.Classic or GW.TBC) },
        { name = "GwQuesttrackerContainerNearlyDone", scrollable = true, mixin = GwObjectivesNearlyDoneContainerMixin, enum = GW.Enum.ObjectivesBlockType.NearlyDone, load = not (GW.Classic or GW.TBC) },
        { name = "GwQuesttrackerContainerCampaign", scrollable = true, mixin = GwObjectivesQuestContainerMixin, enum = GW.Enum.ObjectivesBlockType.Campaign, load = true },
        { name = "GwQuesttrackerContainerQuests", scrollable = true, mixin = GwObjectivesQuestContainerMixin, enum = GW.Enum.ObjectivesBlockType.Quests, load = true },
        { name = "GwQuesttrackerContainerBonus", scrollable = true, mixin = GwBonusObjectivesTrackerContainerMixin, enum = GW.Enum.ObjectivesBlockType.Bonus, load = GW.isModern },
        { name = "GwQuesttrackerContainerRecipe", scrollable = true, mixin = GwObjectivesRecipeContainerMixin, enum = GW.Enum.ObjectivesBlockType.Recipe, load = GW.isModern },
        { name = "GwQuesttrackerContainerMonthlyActivity", scrollable = true, mixin = GwObjectivesMonthlyActivitiesContainerMixin, enum = GW.Enum.ObjectivesBlockType.MonthlyActivity, load = GW.isModern },
        { name = "GwQuesttrackerContainerCollection", scrollable = true, mixin = GwObjectivesCollectionContainerMixin, enum = GW.Enum.ObjectivesBlockType.Collection, load = GW.isModern },
        { name = "GwQuesttrackerContainerHousingInitiative", scrollable = true, mixin = GwObjectivesHousingInitiativeContainerMixin, enum = GW.Enum.ObjectivesBlockType.HousingInitiative, load = GW.Retail },
        -- ADDONS
        { name = "GwQuesttrackerContainerWQT", scrollable = true, mixin = GwWorldQuestTrackerContainerMixin, enum = GW.Enum.ObjectivesBlockType.WQT, addonName = "WorldQuestTracker", load = GW.Retail },
        { name = "GwQuesttrackerContainerPetTracker", scrollable = true, mixin = GwPetTrackerContainerMixin, enum = GW.Enum.ObjectivesBlockType.PetTracker, addonName = "PetTracker_Config", load = GW.Retail },
        { name = "GwQuesttrackerContainerTodoloo", scrollable = true, mixin = GwTodolooContainerMixin, enum = GW.Enum.ObjectivesBlockType.Todoloo, addonName = "Todoloo", load = GW.Retail }
    }

    DisableBlizzardsObjevtiveTracker()

    -- Create our own tracker
    local objectivesTracker = CreateFrame("Frame", "GwQuestTracker", UIParent, "GwQuestTracker")
    Mixin(objectivesTracker, GwObjectivesTrackerMixin)
    objectivesTracker.ScrollFrame = objectivesTracker:CreateTrackerScrollFrame("GwQuestTrackerScroll", GW.settings.objectives.height)
    objectivesTracker.ScrollFrame.Child = CreateFrame("Frame", "GwQuestTrackerScrollChild", objectivesTracker.ScrollFrame, objectivesTracker)

    GW.MixinHideDuringPet(objectivesTracker)

    GW.QuestTrackerFixedContainer = {}
    GW.QuestTrackerScrollableContainer = {}

    -- create container
    for _, config in ipairs(objectivesTrackerConfiguration) do
        local shouldLoad = config.load
        if shouldLoad and config.addonName then
            shouldLoad = C_AddOns.IsAddOnLoaded(config.addonName)
            if not shouldLoad then
                objectivesTracker:AddAddonContainerLoadingToQueue(config)
            end
        end

        if shouldLoad then
            local parent = config.scrollable and objectivesTracker.ScrollFrame.Child or objectivesTracker
            local frame = objectivesTracker:CreateTrackerContainer(config.name, parent, config.mixin, config.template, config.enum)

            GW.ObjectiveTrackerContainer[GW.GetEnumName(GW.Enum.ObjectivesBlockType, config.enum)] = frame
            if config.scrollable then
                table.insert(GW.QuestTrackerScrollableContainer, frame)
            else
                table.insert(GW.QuestTrackerFixedContainer, frame)
            end
        end
    end

    -- position of fixed container
    GW.QuestTrackerFixedContainer[1]:SetPoint("TOPRIGHT", objectivesTracker, "TOPRIGHT")
    for i = 2, #GW.QuestTrackerFixedContainer do
        GW.QuestTrackerFixedContainer[i]:SetPoint("TOPRIGHT", GW.QuestTrackerFixedContainer[i - 1], "BOTTOMRIGHT")
    end

    objectivesTracker.ScrollFrame:SetPoint("TOPRIGHT", GW.QuestTrackerFixedContainer[#GW.QuestTrackerFixedContainer], "BOTTOMRIGHT")
    objectivesTracker.ScrollFrame:SetPoint("BOTTOMRIGHT", objectivesTracker, "BOTTOMRIGHT")

    -- position of scroll child
    objectivesTracker.ScrollFrame.Child:SetPoint("TOPRIGHT", objectivesTracker.ScrollFrame, "TOPRIGHT")
    objectivesTracker.ScrollFrame.Child:SetSize(objectivesTracker:GetWidth(), 2)
    objectivesTracker.ScrollFrame:SetScrollChild(objectivesTracker.ScrollFrame.Child)

    -- position of scrollable container
    SortObjectivesTrackerScrollableContainers()
    AnchorObjectivesTrackerScrollableContainers()

    -- init container
    for _, frame in ipairs(GW.QuestTrackerFixedContainer) do
        if frame.InitModule then frame:InitModule() end
    end
    for _, frame in ipairs(GW.QuestTrackerScrollableContainer) do
        if frame.InitModule then frame:InitModule() end
    end

    GW.ToggleObjectivesAutoCollapse()

    GW.RefreshObjectivesTrackerLayout()

     -- some hooks to set the itembuttons correct
    local UpdateItemButtonPositionAndAdjustScrollFrame = function()
        GW.Debug("Update Quest Buttons")
        objectivesTracker:LayoutChanged()
        objectivesTracker:AdjustItemButtonPositions()
    end

    local itemButtonUpdateQueued = false
    local function QueueItemButtonPositionUpdate(delay)
        if itemButtonUpdateQueued then return end

        itemButtonUpdateQueued = true

        C_Timer.After(delay or 0.1, function()
            itemButtonUpdateQueued = false
            UpdateItemButtonPositionAndAdjustScrollFrame()
        end)
    end
    -- for correct itembutton position
    for _, container in next, {
        GW.ObjectiveTrackerContainer.BossFrames,
        GW.ObjectiveTrackerContainer.ArenaFrames,
        GW.ObjectiveTrackerContainer.Scenario,
        GW.ObjectiveTrackerContainer.Achievement,
        GW.ObjectiveTrackerContainer.Quests,
        GW.ObjectiveTrackerContainer.Campaign
    } do
        container.oldHeight = GW.RoundInt(container:GetHeight() or 0.1)

        hooksecurefunc(container, "SetHeight", function(_, height)
            local newHeight = GW.RoundInt(height)
            if container.oldHeight ~= newHeight then
                container.oldHeight = newHeight
                QueueItemButtonPositionUpdate(0.1)
            end
        end)
    end

    GW.ObjectiveTrackerContainer.Notification:HookScript("OnShow", function() QueueItemButtonPositionUpdate(0.25) end)
    GW.ObjectiveTrackerContainer.Notification:HookScript("OnHide", function() QueueItemButtonPositionUpdate(0.25) end)

    GW.RegisterMovableFrame(objectivesTracker, GW.L["Tracker"], "objectives", ALL, nil, {GW.MoverOption.Scale, GW.MoverOption.Height})
    objectivesTracker:ClearAllPoints()
    objectivesTracker:SetPoint("TOPLEFT", objectivesTracker.gwMover)
    hooksecurefunc(objectivesTracker, "SetHeight", objectivesTracker.LayoutChanged)
    objectivesTracker:SetHeight(GW.settings.objectives.height)
end
GW.LoadObjectivesTracker = LoadObjectivesTracker
