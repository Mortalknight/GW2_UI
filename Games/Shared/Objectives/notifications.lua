---@class GW2
local GW = select(2, ...)
local L = GW.L

-- one entry per source, the first source in this order that has one is shown; dead and quest
-- are asked on every refresh, the others are set by their modules
local SOURCE_ORDER = {"dead", "scenario", "event", "arena", "boss", "quest"}
local SOURCE_TYPES = {
    scenario = GW.Enum.ObjectivesNotificationType.Scenario,
    event = GW.Enum.ObjectivesNotificationType.Event,
    arena = GW.Enum.ObjectivesNotificationType.Arena,
    boss = GW.Enum.ObjectivesNotificationType.Boss,
}
local sourceEntries = {}

local icons = {
    [GW.Enum.ObjectivesNotificationType.Quest] = {tex = "icon-objective", l = 0, r = 0.5, t = 0.25, b = 0.5},
    [GW.Enum.ObjectivesNotificationType.Campaign] = {tex = "icon-objective", l = 0.5, r = 1, t = 0, b = 0.25},
    [GW.Enum.ObjectivesNotificationType.Event] = {tex = "icon-objective", l = 0, r = 0.5, t = 0.5, b = 0.75},
    [GW.Enum.ObjectivesNotificationType.Scenario] = {tex = "icon-objective", l = 0, r = 0.5, t = 0.75, b = 1},
    [GW.Enum.ObjectivesNotificationType.Boss] = {tex = "icon-boss", l = 0, r = 1, t = 0, b = 1},
    [GW.Enum.ObjectivesNotificationType.Dead] = {tex = "icon-dead", l = 0, r = 1, t = 0, b = 1},
    [GW.Enum.ObjectivesNotificationType.Arena] = {tex = "icon-arena", l = 0, r = 1, t = 0, b = 1},
    [GW.Enum.ObjectivesNotificationType.DailyQuest] = {tex = "icon-objective", l = 0.5, r = 1, t = 0.25, b = 0.5},
    [GW.Enum.ObjectivesNotificationType.Torghast] = {tex = "icon-objective", l = 0.5, r = 1, t = 0.5, b = 0.75},
    [GW.Enum.ObjectivesNotificationType.Delve] = {tex = "icon-delve", l = 0, r = 1, t = 0, b = 1},
}

function GW.GetObjectivesTypeIcon(notificationType)
    return icons[notificationType]
end

-- Questie Helper
local function _GetDistance(x1, y1, x2, y2)
    -- Basic proximity distance calculation to compare two locs (normally player position and provided loc)
    return math.sqrt( (x2-x1)^2 + (y2-y1)^2 );
end

local function _GetDistanceToClosestObjective(spawn, zone, name)
    -- main function for proximity
    local mapId = GW.Location.GetMapID()
    if not GW.Location.GetCoords() or not mapId then
        return nil
    end

    local position = C_Map.GetPlayerMapPosition(mapId, "player")
    if not position then
        return nil
    end

    local _, player = C_Map.GetWorldPosFromMapPos(mapId, position)
    if not player then
        return nil
    end

    if not spawn or not zone or not name then
        return nil
    end

    local uiMapId = QuestieLoader:ImportModule("ZoneDB"):GetUiMapIdByAreaId(zone)
    if not uiMapId then
        return nil
    end
    local _, worldPosition = C_Map.GetWorldPosFromMapPos(uiMapId, {
        x = spawn[1] / 100,
        y = spawn[2] / 100
    })

    local coordinates = {}
    tinsert(coordinates, {
        x = worldPosition.x,
        y = worldPosition.y
    })

    if (not coordinates) then
        return nil
    end

    local closestDistance
    for _, _ in pairs(coordinates) do
        local distance = _GetDistance(player.x, player.y, worldPosition.x, worldPosition.y)
        if closestDistance == nil or distance < closestDistance then
            closestDistance = distance;
        end
    end

    return closestDistance
end

local function getQuestPOIText(questLogIndex)
    local finalText, numFinished = "", 0
    local numItemDrops = GetNumQuestItemDrops(questLogIndex)
    local numObjectives = numItemDrops > 0 and numItemDrops or GetNumQuestLeaderBoards(questLogIndex)
    local completionText = GetQuestLogCompletionText(questLogIndex) or QUEST_WATCH_QUEST_READY
    local getter = numItemDrops > 0 and GetQuestLogItemDrop or GetQuestLogLeaderBoard

    for i = 1, numObjectives do
        local text, _, finished = getter(i, questLogIndex)
        if text then
            if finished then
                numFinished = numFinished + 1
                if numObjectives == 1 then
                    return completionText
                end
            else
                finalText = finalText .. text .. "\n"
            end
        end
    end

    return numFinished == numObjectives and completionText or finalText
end


local function getNearestQuestPOIRetail()
    if not GW.Location.GetMapID() then
        return nil
    end

    local numTrackedQuests = C_QuestLog.GetNumQuestWatches()
    local numTrackedWQ = C_QuestLog.GetNumWorldQuestWatches()
    local numQuests = C_QuestLog.GetNumQuestLogEntries()
    local x, y = GW.Location.GetCoords()
    local poiX, poiY = nil, nil

    if (not x or not y) and (numTrackedQuests == 0 and numTrackedWQ == 0 and numQuests == 0) then
        return nil
    end


    local closestQuestID, minDistSqr, isWQ = nil, math.huge, false

    -- first check for nearest tracker WQ
    for i = 1, numTrackedWQ do
        local questID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
        local dist = questID and C_QuestLog.GetDistanceSqToQuest(questID)
        if dist and dist <= minDistSqr then
            minDistSqr, closestQuestID, isWQ = dist, questID, true
        end
    end

    if not closestQuestID then
        local questID = C_SuperTrack.GetSuperTrackedQuestID()
        if questID then
            local dist, onContinent = C_QuestLog.GetDistanceSqToQuest(questID)
            if onContinent and dist and dist <= minDistSqr then
                minDistSqr, closestQuestID = dist, questID
            else
                poiX, poiY = C_QuestLog.GetNextWaypointForMap(questID, GW.Location.GetMapID())
                if poiX and poiY then
                    closestQuestID = questID
                end
            end
        end
    end

    -- If nothing with POI data is being tracked expand search to quest log
    if not closestQuestID then
        for questLogIndex = 1, numQuests do
            local questID = C_QuestLog.GetQuestIDForLogIndex(questLogIndex)
            local questData = QuestCache:Get(questID)
            local isOnMap, hasLocalPOI = questData:IsOnMap()
            if isOnMap and hasLocalPOI and QuestHasPOIInfo(questID) then
                local dist, onContinent = C_QuestLog.GetDistanceSqToQuest(questID)
                if onContinent and dist and dist <= minDistSqr then
                    minDistSqr, closestQuestID = dist, questID
                end
            end
        end
    end

    if not closestQuestID then return nil end

    if isWQ then
        poiX, poiY = C_TaskQuest.GetQuestLocation(closestQuestID, GW.Location.GetMapID())
    else
        if not poiX then
            local questsOnMap = C_QuestLog.GetQuestsOnMap(GW.Location.GetMapID())
            for _, info in ipairs(questsOnMap or {}) do
                if info.questID == closestQuestID then
                    poiX, poiY = info.x, info.y
                    break
                end
            end
            if not poiX then
                poiX, poiY = C_QuestLog.GetNextWaypointForMap(closestQuestID, GW.Location.GetMapID())
            end
        end
    end

    if not poiX then return nil end

    local questData = QuestCache:Get(closestQuestID)
    local isCampaign = questData:IsCampaign()
    local isFrequent = questData.frequency and questData.frequency > 0
    local objectiveText = isWQ and GW.ParseSimpleObjective(GetQuestObjectiveInfo(closestQuestID, 1, false)) or getQuestPOIText(C_QuestLog.GetLogIndexForQuestID(closestQuestID))

    if questData.frequency == nil then
        for i = 1, 25 do
            local block = GW.ObjectiveTrackerContainer.Campaign.blocks[i]
            if block and block.questID == closestQuestID then
                isFrequent = block.isFrequency
                break
            end
            block = GW.ObjectiveTrackerContainer.Quests.blocks[i]
            if block and block.questID == closestQuestID then
                isFrequent = block.isFrequency
                break
            end
        end
    end

    return {
        x = poiX,
        y = poiY,
        desc = objectiveText,
        title = questData.title,
        type = isCampaign and GW.Enum.ObjectivesNotificationType.Campaign or isFrequent and GW.Enum.ObjectivesNotificationType.DailyQuest or isWQ and GW.Enum.ObjectivesNotificationType.Event or GW.Enum.ObjectivesNotificationType.Quest,
        id = closestQuestID,
        compass = true,
        questID = closestQuestID
    }
end


local function getNearestQuestPOIClassic()
    if not GW.Location.GetMapID() or not Questie or not Questie.started then
        return nil
    end

    local x, y = GW.Location.GetCoords()

    if (not x or not y) then
        return nil
    end

    local closestQuestID
    local minDist = math.huge
    local spawnInfo
    local questieQuest

    for _, quest in pairs(GW.ObjectiveTrackerContainer.Quests.trackedQuests) do
        if quest.questId then
            questieQuest = QuestieLoader:ImportModule("QuestieDB").GetQuest(quest.questId)
            if questieQuest then
                -- do this to prevent a questie error
                local shouldCheck = false
                if questieQuest.Objectives then
                    for _, objective in pairs(questieQuest.Objectives) do
                        if objective.spawnList then --and next(objective.spawnList) then
                            shouldCheck = true
                            break
                        else
                            shouldCheck = false
                        end
                    end
                end
                if shouldCheck then
                    local spawn, zone, name = QuestieLoader:ImportModule("DistanceUtils").GetNearestSpawnForQuest(questieQuest)
                    if spawn and zone and name then
                        if QuestieLoader:ImportModule("ZoneDB"):GetUiMapIdByAreaId(zone) == GW.Location.GetMapID() then
                            local distance = _GetDistanceToClosestObjective(spawn, zone, name)
                            if distance and distance < minDist then
                                minDist = distance
                                closestQuestID = quest.questId
                                spawnInfo = spawn
                            end
                        end
                    end
                end
            end
        end
    end

    local poiX, poiY = nil, nil
    if closestQuestID and spawnInfo and spawnInfo[1] then
        poiX, poiY = spawnInfo[1] / 100, spawnInfo[2] / 100
    end

    if not poiX then return nil end

    local isDaily = QuestieLoader:ImportModule("QuestieDB").IsDailyQuest(closestQuestID)

    return {
        x = poiX,
        y = poiY,
        desc = getQuestPOIText(GetQuestLogIndexByID(closestQuestID)),
        title = GetQuestLogTitle(GetQuestLogIndexByID(closestQuestID)),
        type = isDaily and GW.Enum.ObjectivesNotificationType.DailyQuest or GW.Enum.ObjectivesNotificationType.Quest,
        id = closestQuestID,
        compass = true,
        questID = closestQuestID
    }
end


local function getNearestQuestPOIMists()
    if not GW.Location.GetMapID() then
        return nil
    end

    local numQuests = GetNumQuestLogEntries()
    local x, y = GW.Location.GetCoords()

    if x == nil or y == nil or numQuests == 0 then
        return nil
    end

    local closestQuestID
    local minDistSqr = math.huge
    local isFrequent = false
    local title

    for questLogIndex = 1, numQuests do
        local questLogTitleText, _, _, _, _, _, frequency, questID, _, _, isOnMap, hasLocalPOI = GetQuestLogTitle(questLogIndex)
        if questID and isOnMap and hasLocalPOI then
            local _, poiX, poiY = QuestPOIGetIconInfo(questID)

            local distance = CalculateDistance(x, y, poiX, poiY)
            if distance and distance < minDistSqr then
                minDistSqr = distance
                closestQuestID = questID
                isFrequent = frequency and frequency > 1
                title = questLogTitleText
            end
        end
    end
    if closestQuestID then
        local _, poiX, poiY = QuestPOIGetIconInfo(closestQuestID)

        return {
            x = poiX,
            y = poiY,
            desc = getQuestPOIText(GetQuestLogIndexByID(closestQuestID)),
            title = title,
            type = isFrequent and GW.Enum.ObjectivesNotificationType.DailyQuest or GW.Enum.ObjectivesNotificationType.Quest,
            id = closestQuestID,
            compass = true,
            questID = closestQuestID
        }
    end

    return nil
end

local function getBodyPOI()
    local mapID = GW.Location.GetMapID()
    if not mapID then
        return nil
    end

    local corpTable = C_DeathInfo.GetCorpseMapPosition(mapID)
    if not corpTable then
        return nil
    end

    local x, y = corpTable:GetXY()
    if not x or x == 0 then
        return nil
    end

    return {
        x = x,
        y = y,
        title = L["Retrieve your corpse"],
        type = GW.Enum.ObjectivesNotificationType.Dead,
        id = "playerDead",
        compass = true
    }
end

local sourceProviders = {
    dead = function()
        return UnitIsDeadOrGhost("player") and getBodyPOI() or nil
    end,
    quest = function()
        if GW.isModern then
            return getNearestQuestPOIRetail()
        elseif GW.Classic or GW.TBC or GW.Wrath then
            return getNearestQuestPOIClassic()
        elseif GW.Mists then
            return getNearestQuestPOIMists()
        end
    end,
}

local square_half = math.sqrt(0.5)
local rad_135 = math.rad(135)
local function updateRadar(self)
    local x, y = GW.Location.GetCoords()
    if not x or not y or not self.data.x then
        return
    end

    local pFacing = GetPlayerFacing() or 0
    local dir_x = self.data.x - x
    local dir_y = self.data.y - y
    local angle = math.atan2(dir_y, dir_x)
    angle = rad_135 - angle - pFacing

    local sin_a = math.sin(angle) * square_half
    local cos_a = math.cos(angle) * square_half
    self.arrow:SetTexCoord(0.5 - sin_a, 0.5 + cos_a, 0.5 + cos_a, 0.5 + sin_a, 0.5 - cos_a, 0.5 - sin_a, 0.5 + sin_a, 0.5 - cos_a)
end


GwObjectivesTrackerNotificationMixin = {}

local function PlayHeaderRefreshAnimation(self, color)
    if not color then
        return
    end

    GW.AddToAnimation(
        self.headerAnimationName,
        0,
        1,
        GetTime(),
        0.28,
        function(step)
            local pulse = math.sin(step * math.pi) -- 0 -> 1 -> 0
            local textAlpha = 0.55 + (step * 0.45)
            local descAlpha = 0.4 + (step * 0.6)
            local bgAlpha = 0.3 + (pulse * 0.28)
            local colorBoost = pulse * 0.22
            local titleR = math.min(1, color.r + ((1 - color.r) * colorBoost))
            local titleG = math.min(1, color.g + ((1 - color.g) * colorBoost))
            local titleB = math.min(1, color.b + ((1 - color.b) * colorBoost))

            self.iconFrame:SetScale(1 + (pulse * 0.08))
            self.title:SetTextColor(titleR, titleG, titleB)
            self.title:SetAlpha(textAlpha)
            self.desc:SetAlpha(descAlpha)
            self.compassBG:SetVertexColor(color.r, color.g, color.b, bgAlpha)
        end,
        nil,
        function()
            self.iconFrame:SetScale(1)
            self.title:SetTextColor(color.r, color.g, color.b)
            self.title:SetAlpha(1)
            self.desc:SetAlpha(1)
            self.compassBG:SetVertexColor(color.r, color.g, color.b, 0.3)
        end,
        true
    )
end

local function PlayNotificationHover(self, hoverIn)
    local color = self.currentNotificationColor or GW.Colors.FallbackWhite
    local fromAlpha = self:GetAlpha() or 1
    local toAlpha = hoverIn and 1 or 0.95
    local fromBgAlpha = self.currentBgAlpha or 0.3
    local toBgAlpha = hoverIn and 0.5 or 0.3

    GW.AddToAnimation(
        self.hoverAnimationName,
        0,
        1,
        GetTime(),
        0.16,
        function(step)
            self:SetAlpha(GW.lerp(fromAlpha, toAlpha, step))
            local bgAlpha = GW.lerp(fromBgAlpha, toBgAlpha, step)
            self.currentBgAlpha = bgAlpha
            self.compassBG:SetVertexColor(color.r, color.g, color.b, bgAlpha)
        end,
        nil,
        nil,
        true
    )
end

local function ApplyIndicatorState(self, useProgress, data, animate)
    if useProgress then
        self.bonusbar.progress = data.progress
        self.bonusbar.bar:SetValue(data.progress)
    end

    if not animate then
        if useProgress then
            self.bonusbar:Show()
            self.bonusbar:SetAlpha(1)
            self.bonusbar:SetScale(1)
            self.iconFrame:SetAlpha(1)
            self.iconFrame:SetScale(1)
            self.iconFrame.icon:SetTexture(nil)
        else
            self.bonusbar:Hide()
            self.bonusbar:SetAlpha(1)
            self.bonusbar:SetScale(1)
            self.iconFrame:SetAlpha(1)
            self.iconFrame:SetScale(1)
        end
        self.usingProgressIndicator = useProgress
        return
    end

    if useProgress then
        self.bonusbar:Show()
        self.bonusbar:SetAlpha(0)
    end

    GW.AddToAnimation(
        self.indicatorAnimationName,
        0,
        1,
        GetTime(),
        0.2,
        function(step)
            local pulse = math.sin(step * math.pi)
            self.iconFrame:SetAlpha(useProgress and (1 - step) or step)
            self.iconFrame:SetScale(0.94 + (0.06 * step) + (pulse * 0.02))
            self.bonusbar:SetAlpha(useProgress and step or (1 - step))
            self.bonusbar:SetScale(0.94 + (0.06 * step) + (pulse * 0.02))
        end,
        nil,
        function()
            self.iconFrame:SetAlpha(1)
            self.iconFrame:SetScale(1)
            self.bonusbar:SetScale(1)
            self.bonusbar:SetAlpha(1)
            if useProgress then
                self.iconFrame.icon:SetTexture(nil)
                self.bonusbar:Show()
            else
                self.bonusbar:Hide()
            end
        end,
        true
    )

    self.usingProgressIndicator = useProgress
end

local function PlayBonusbarShowAnimation(self)
    if not self.bonusbar:IsShown() then
        return
    end

    if self.bonusbar.flare then
        self.bonusbar.flare:Show()
        self.bonusbar.flare:SetAlpha(0.9)
        self.bonusbar.flare:SetRotation(0)
    end

    GW.AddToAnimation(
        self.bonusbarShowAnimationName,
        0,
        1,
        GetTime(),
        0.24,
        function(step)
            local pulse = math.sin(step * math.pi)
            self.bonusbar:SetScale(0.9 + (0.1 * step) + (pulse * 0.02))
            self.bonusbar:SetAlpha(0.7 + (0.3 * step))
            if self.bonusbar.flare then
                self.bonusbar.flare:SetAlpha(1 - step)
                self.bonusbar.flare:SetRotation(1.8 * step)
            end
        end,
        nil,
        function()
            self.bonusbar:SetScale(1)
            self.bonusbar:SetAlpha(1)
            if self.bonusbar.flare then
                self.bonusbar.flare:Hide()
            end
        end,
        true
    )
end

-- data needs a title; desc, progress, questID and a type other than the sources one are optional;
-- nil removes the sources entry
function GwObjectivesTrackerNotificationMixin:SetNotification(source, data)
    if data then
        data.id = data.id or source
        data.type = data.type or SOURCE_TYPES[source]
    end
    sourceEntries[source] = data
    self:QueueRefresh()
end

function GwObjectivesTrackerNotificationMixin:QueueRefresh(delay)
    if self.pendingRefresh then
        return
    end
    self.pendingRefresh = true
    C_Timer.After(delay or 0, function()
        self.pendingRefresh = nil
        self:OnUpdate()
    end)
end

function GwObjectivesTrackerNotificationMixin:NotificationStateChanged(show)
    self:SetShown(show)

    GW.AddToAnimation(
        "notificationToggle",
        0,
        70,
        GetTime(),
        0.2,
        function(step)
            if not show then
                step = 70 - step
            end

            self:SetAlpha(step / 70)
            self:SetHeight(math.max(step, 1))
        end,
        nil,
        function()
            self:SetShown(show)
            self.animating = false
            if show and self.usingProgressIndicator then
                PlayBonusbarShowAnimation(self)
            end
            GwQuestTracker:LayoutChanged()
        end,
        true
    )
end

local function GetQuestBlock(questID)
    local containers = GW.ObjectiveTrackerContainer
    for _, container in pairs({containers.Campaign or false, containers.Quests or false}) do
        if container then
            for _, block in ipairs(container.blocks) do
                if block.questID == questID and block:IsShown() then
                    return block
                end
            end
        end
    end
end

local function CompassOnMouseUp(self, button)
    local questID = self.compassQuestID
    if not questID then return end

    local block = GetQuestBlock(questID)
    if block then
        block:GetScript("OnMouseDown")(block, button)
    elseif button == "LeftButton" then
        -- a quest the tracker does not show has no block menu, it can still be opened
        if GW.isModern then
            GW.ShowQuestDetails(questID)
        else
            local questLogIndex = GetQuestLogIndexByID(questID)
            if questLogIndex and questLogIndex > 0 then
                GW.ShowQuestLogEntry(questLogIndex)
            end
        end
    end
end

local currentCompassData
function GwObjectivesTrackerNotificationMixin:SetObjectiveNotification()
    if not GW.settings.objectives.compass then
        self.shouldDisplay = false
        self.compassQuestID = nil
        return
    end

    local data, source
    for _, key in ipairs(SOURCE_ORDER) do
        local provider = sourceProviders[key]
        data = sourceEntries[key] or (provider and provider())
        if data then
            source = key
            break
        end
    end
    self.currentSource = source

    if not data then
        self.shouldDisplay = false
        self.compassQuestID = nil
        return
    end

    data.color = data.color or GW.Colors.ObjectivesTypeColors[data.type] or GW.Colors.FallbackWhite
    self.compassQuestID = data.questID

    --remove tooltip here
    self.iconFrame:SetScript("OnEnter", nil)
    self.iconFrame:SetScript("OnLeave", nil)

    local iconInfo = icons[data.type]

    if iconInfo then
        self.iconFrame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/" .. iconInfo.tex .. ".png")
        self.iconFrame.icon:SetTexCoord(iconInfo.l, iconInfo.r, iconInfo.t, iconInfo.b)

        if data.type == GW.Enum.ObjectivesNotificationType.Delve then
            self.iconFrame:SetScript("OnEnter", function()
                GameTooltip:SetOwner(self.iconFrame, "ANCHOR_LEFT")
                GameTooltip:SetSpellByID(self.iconFrame.tooltipSpellID)
            end)
            self.iconFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end

        local useProgressIndicator = (data.progress ~= nil) and (iconInfo ~= nil)
        local shouldAnimateIndicator = self.usingProgressIndicator ~= nil and self.usingProgressIndicator ~= useProgressIndicator
        ApplyIndicatorState(self, useProgressIndicator, data, shouldAnimateIndicator)
    else
        self.bonusbar:Hide()
        self.bonusbar:SetAlpha(1)
        self.bonusbar:SetScale(1)
        self.iconFrame:SetAlpha(1)
        self.iconFrame:SetScale(1)
        self.usingProgressIndicator = false
        self.iconFrame.icon:SetTexture(nil)
    end

    if data.compass then
        self.compass:Show()
        self.compass.data = data
        self.compass.dataIndex = data.id

        if iconInfo then
            self.compass.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/" .. iconInfo.tex .. ".png")
            self.compass.icon:SetTexCoord(iconInfo.l, iconInfo.r, iconInfo.t, iconInfo.b)
        else
            self.compass.icon:SetTexture(nil)
        end

        if (not currentCompassData or GW.SafeValuesDiffer(currentCompassData, self.compass.dataIndex)) or not self.compass.Timer then
            currentCompassData = self.compass.dataIndex
            if self.compass.Timer then
                self.compass.Timer:Cancel()
                self.compass.Timer = nil
            end
            self.compass.Timer = C_Timer.NewTicker(0.05, function() updateRadar(self.compass) end)
        end

        self.iconFrame.icon:SetTexture(nil)
    else
        self.compass:Hide()
        if self.compass.Timer then
            self.compass.Timer:Cancel()
            self.compass.Timer = nil
        end
    end

    local titleText = data.title or ""
    local descText = data.desc or ""
    local headerStateChanged = GW.SafeValuesDiffer(self.lastNotificationID, data.id) or GW.SafeValuesDiffer(self.lastTitleText, titleText)

    self.title:SetText(titleText)
    self.title:SetTextColor(data.color.r, data.color.g, data.color.b)
    self.compassBG:SetVertexColor(data.color.r, data.color.g, data.color.b, 0.3)
    self.currentNotificationColor = data.color
    self.currentBgAlpha = 0.3
    self.desc:SetText(descText)

    if GW.IsNilOrEmptyNonSecretString(data.desc) then
        self.title:SetPoint("TOP", self, "TOP", 0, -30)
    else
        self.title:SetPoint("TOP", self, "TOP", 0, -15)
    end

    if headerStateChanged then
        PlayHeaderRefreshAnimation(self, data.color)
    end

    self.lastNotificationID = data.id
    self.lastTitleText = titleText
    self.lastDescText = descText

    self.shouldDisplay = true
end

function GwObjectivesTrackerNotificationMixin:BonusbarOnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetText(GW.RoundDec(self.progress * 100, 0) .. "%", 1, 1, 1)
    GameTooltip:Show()
end

function GwObjectivesTrackerNotificationMixin:OnUpdate()
    local prevState = self.shouldDisplay

    if GW.Location.GetMapID() or GW.Location.GetInstanceMapID() then
        self:SetObjectiveNotification()
    end

    if prevState ~= self.shouldDisplay then
        self:NotificationStateChanged(self.shouldDisplay)
    end
end

-- while moving only the asked sources (corpse, nearest quest) can change, a modules entry stays the same
local function OnMovingTick(self)
    if not self.currentSource or sourceProviders[self.currentSource] then
        self:OnUpdate()
    end
end

function GwObjectivesTrackerNotificationMixin:OnEvent(event, ...)
    if GW.IsIn(event, "PLAYER_STARTED_MOVING", "PLAYER_CONTROL_LOST") then
        if self.Ticker then
            self.Ticker:Cancel()
            self.Ticker = nil
        end
        self.Ticker = C_Timer.NewTicker(1, function() OnMovingTick(self) end)
    elseif GW.IsIn(event, "PLAYER_STOPPED_MOVING", "PLAYER_CONTROL_GAINED") then -- Events for stop updating
        if self.Ticker then
            self.Ticker:Cancel()
            self.Ticker = nil
        end
    elseif event == "QUEST_DATA_LOAD_RESULT" then
        local questID, success = ...
        if success and self.compass.dataIndex and questID == self.compass.dataIndex then
            self:OnUpdate()
        end
    else
        self:QueueRefresh(0.25)
    end
end

function GwObjectivesTrackerNotificationMixin:InitModule()
    self.animatingState = false
    self.animating = false
    self.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, "SHADOW")
    self.desc:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    self.bonusbar.bar:SetOrientation("VERTICAL")
    self.bonusbar.bar:SetMinMaxValues(0, 1)
    self.bonusbar.bar:SetValue(0.5)
    self.bonusbar:SetScript("OnEnter", self.BonusbarOnEnter)
    self.bonusbar:SetScript("OnLeave", GameTooltip_Hide)
    self.compass:SetScript("OnShow", self.compass.NewQuestAnimation)
    local canClearSuperTrack = C_SuperTrack and C_SuperTrack.ClearAllSuperTracked
    self.compass:SetScript("OnMouseDown", function(_, button)
        if canClearSuperTrack and button == "LeftButton" then
            C_SuperTrack.ClearAllSuperTracked()
        end
    end)
    self.compass:SetScript("OnMouseUp", function(_, button)
        if not canClearSuperTrack or button ~= "LeftButton" then
            CompassOnMouseUp(self, button)
        end
    end)
    self:SetScript("OnMouseUp", CompassOnMouseUp)
    self.shouldDisplay = false
    self.headerAnimationName = self:GetDebugName() .. "_Header"
    self.indicatorAnimationName = self:GetDebugName() .. "_Indicator"
    self.bonusbarShowAnimationName = self:GetDebugName() .. "_BonusShow"
    self.hoverAnimationName = self:GetDebugName() .. "_Hover"
    self.lastNotificationID = nil
    self.lastTitleText = nil
    self.lastDescText = nil
    self.usingProgressIndicator = nil
    self.pendingRefresh = nil
    self.currentBgAlpha = 0.3
    self.currentNotificationColor = CreateColor(1, 1, 1, 1)
    self:SetScript("OnEnter", function() PlayNotificationHover(self, true) end)
    self:SetScript("OnLeave", function() PlayNotificationHover(self, false) end)
    GW.AddMouseMotionPropagationToChildFrames(self)

    -- only update the tracker on Events or if player moves
    self:RegisterEvent("PLAYER_STARTED_MOVING")
    self:RegisterEvent("PLAYER_STOPPED_MOVING")
    self:RegisterEvent("PLAYER_CONTROL_LOST")
    self:RegisterEvent("PLAYER_CONTROL_GAINED")
    self:RegisterEvent("QUEST_LOG_UPDATE")
    self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    self:RegisterEvent("PLAYER_MONEY")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    self:RegisterEvent("PLAYER_DEAD")
    self:RegisterEvent("PLAYER_ALIVE")
    self:RegisterEvent("PLAYER_UNGHOST")
    if GW.isModern then
        self:RegisterEvent("QUEST_DATA_LOAD_RESULT")
        self:RegisterEvent("SUPER_TRACKING_CHANGED")
        self:RegisterEvent("SCENARIO_UPDATE")
        self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    end
    self:SetScript("OnEvent", self.OnEvent)
end
