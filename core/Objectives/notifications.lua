local _, GW = ...
local L = GW.L
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local notifications = {}

local icons = {
    QUEST = {tex = "icon-objective", l = 0, r = 0.5, t = 0.25, b = 0.5},
    CAMPAIGN = {tex = "icon-objective", l = 0.5, r = 1, t = 0, b = 0.25},
    EVENT = {tex = "icon-objective", l = 0, r = 0.5, t = 0.5, b = 0.75},
    SCENARIO = {tex = "icon-objective", l = 0, r = 0.5, t = 0.75, b = 1},
    BOSS = {tex = "icon-boss", l = 0, r = 1, t = 0, b = 1},
    DEAD = {tex = "icon-dead", l = 0, r = 1, t = 0, b = 1},
    ARENA = {tex = "icon-arena", l = 0, r = 1, t = 0, b = 1},
    DAILY = {tex = "icon-objective", l = 0.5, r = 1, t = 0.25, b = 0.5},
    TORGHAST = {tex = "icon-objective", l = 0.5, r = 1, t = 0.5, b = 0.75},
    DELVE = {tex = "icon-delve", l = 0, r = 1, t = 0, b = 1},
}

local notification_priority = {
    DELVE = 1,
    TORGHAST = 1,
    SCENARIO = 2,
    EVENT = 3,
    ARENA = 4,
    BOSS = 5,
}

-- Questie Helper
local function _GetDistance(x1, y1, x2, y2)
    -- Basic proximity distance calculation to compare two locs (normally player position and provided loc)
    return math.sqrt( (x2-x1)^2 + (y2-y1)^2 );
end

local function _GetDistanceToClosestObjective(spawn, zone, name)
    -- main function for proximity
    local mapId = GW.Libs.GW2Lib:GetPlayerLocationMapID()
    if not GW.Libs.GW2Lib:GetPlayerLocationCoords() or not mapId then
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

local function prioritys(a, b)
    if a == nil or a == "" then
        return true
    end
    if a == b then
        return true
    end
    return notification_priority[a] > notification_priority[b]
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
    if not GW.Libs.GW2Lib:GetPlayerLocationMapID() then
        return nil
    end

    local numTrackedQuests = C_QuestLog.GetNumQuestWatches()
    local numTrackedWQ = C_QuestLog.GetNumWorldQuestWatches()
    local numQuests = C_QuestLog.GetNumQuestLogEntries()
    local x, y = GW.Libs.GW2Lib:GetPlayerLocationCoords()
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
                poiX, poiY = C_QuestLog.GetNextWaypointForMap(questID, GW.Libs.GW2Lib:GetPlayerLocationMapID())
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
        poiX, poiY = C_TaskQuest.GetQuestLocation(closestQuestID, GW.Libs.GW2Lib:GetPlayerLocationMapID())
    else
        if not poiX then
            local questsOnMap = C_QuestLog.GetQuestsOnMap(GW.Libs.GW2Lib:GetPlayerLocationMapID())
            for _, info in ipairs(questsOnMap or {}) do
                if info.questID == closestQuestID then
                    poiX, poiY = info.x, info.y
                    break
                end
            end
            if not poiX then
                poiX, poiY = C_QuestLog.GetNextWaypointForMap(closestQuestID, GW.Libs.GW2Lib:GetPlayerLocationMapID())
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
        X = poiX,
        Y = poiY,
        DESC = objectiveText,
        TITLE = questData.title,
        TYPE = isCampaign and GW.TRACKER_TYPE.CAMPAIGN or isFrequent and GW.TRACKER_TYPE.DAILY or isWQ and GW.TRACKER_TYPE.EVENT or GW.TRACKER_TYPE.QUEST,
        ID = closestQuestID,
        COLOR = isCampaign and TRACKER_TYPE_COLOR.CAMPAIGN
            or isFrequent and TRACKER_TYPE_COLOR.DAILY
            or isWQ and TRACKER_TYPE_COLOR.EVENT
            or TRACKER_TYPE_COLOR.QUEST,
        COMPASS = true,
        QUESTID = closestQuestID
    }
end


local function getNearestQuestPOIClassic()
    if not GW.Libs.GW2Lib:GetPlayerLocationMapID() or not Questie or not Questie.started then
        return nil
    end

    local x, y = GW.Libs.GW2Lib:GetPlayerLocationCoords()

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
                        if QuestieLoader:ImportModule("ZoneDB"):GetUiMapIdByAreaId(zone) == GW.Libs.GW2Lib:GetPlayerLocationMapID() then
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
        X = poiX,
        Y = poiY,
        DESC = getQuestPOIText(GetQuestLogIndexByID(closestQuestID)),
        TITLE = GetQuestLogTitle(GetQuestLogIndexByID(closestQuestID)),
        TYPE = isDaily and GW.TRACKER_TYPE.DAILY or GW.TRACKER_TYPE.QUEST,
        ID = closestQuestID,
        COLOR = isDaily and TRACKER_TYPE_COLOR.DAILY or TRACKER_TYPE_COLOR.QUEST,
        COMPASS = true,
        QUESTID = closestQuestID
    }
end


local function getNearestQuestPOIMists()
    if not GW.Libs.GW2Lib:GetPlayerLocationMapID() then
        return nil
    end

    local numQuests = GetNumQuestLogEntries()
    local x, y = GW.Libs.GW2Lib:GetPlayerLocationCoords()

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
            X = poiX,
            Y = poiY,
            DESC = getQuestPOIText(GetQuestLogIndexByID(closestQuestID)),
            TITLE = title,
            TYPE = isFrequent and GW.TRACKER_TYPE.DAILY or GW.TRACKER_TYPE.QUEST,
            ID = closestQuestID,
            COLOR = isFrequent and TRACKER_TYPE_COLOR.DAILY or TRACKER_TYPE_COLOR.QUEST,
            COMPASS = true,
            QUESTID = closestQuestID
        }
    end

    return nil
end

local function getBodyPOI()
    local mapID = GW.Libs.GW2Lib:GetPlayerLocationMapID()
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
        X = x,
        Y = y,
        TITLE = L["Retrieve your corpse"],
        TYPE = GW.TRACKER_TYPE.DEAD,
        ID = "playerDead",
        COLOR = TRACKER_TYPE_COLOR.DEAD,
        COMPASS = true
    }
end


local square_half = math.sqrt(0.5)
local rad_135 = math.rad(135)
local function updateRadar(self)
    local x, y = GW.Libs.GW2Lib:GetPlayerLocationCoords()
    if not x or not y or not self.data.X then
        self:GetParent():RemoveNotificationById(self.dataIndex)
        return
    end

    local pFacing = GetPlayerFacing() or 0
    local dir_x = self.data.X - x
    local dir_y = self.data.Y - y
    local angle = math.atan2(dir_y, dir_x)
    angle = rad_135 - angle - pFacing

    local sin_a = math.sin(angle) * square_half
    local cos_a = math.cos(angle) * square_half
    self.arrow:SetTexCoord(0.5 - sin_a, 0.5 + cos_a, 0.5 + cos_a, 0.5 + sin_a, 0.5 - cos_a, 0.5 - sin_a, 0.5 + sin_a, 0.5 - cos_a)
end


GwObjectivesTrackerNotificationMixin = {}
function GwObjectivesTrackerNotificationMixin:AddNotification(data, forceUpdate)
    if data == nil or data.ID == nil then
        return
    end
    notifications[data.ID] = data
    if forceUpdate then
        self:OnUpdate()
    end
end

function GwObjectivesTrackerNotificationMixin:RemoveNotificationById(notificationID)
    if notificationID == nil then
        return
    end

    notifications[notificationID] = nil
end

function GwObjectivesTrackerNotificationMixin:RemoveNotificationOfType(doType)
    for k, v in pairs(notifications) do
        if v.TYPE == doType then
            notifications[k] = nil
        end
    end
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
            GwQuestTracker:LayoutChanged()
        end,
        true
    )
end

local currentCompassData
function GwObjectivesTrackerNotificationMixin:SetObjectiveNotification()
    if not GW.settings.SHOW_QUESTTRACKER_COMPASS then
        self.shouldDisplay = false
        return
    end

    local data = nil

    if UnitIsDeadOrGhost("player") then
        data = getBodyPOI()
    end

    if not data then
        for _, notification in pairs(notifications) do
            if notification and not notification.COMPASS then
                if not data or prioritys(data.TYPE, notification.TYPE) then
                    data = notification
                end
            end
        end
    end

    if not data then
        if GW.Retail then
            data = getNearestQuestPOIRetail()
        elseif GW.Classic or GW.TBC then
            data = getNearestQuestPOIClassic()
        elseif GW.Mists then
            data = getNearestQuestPOIMists()
        end
    end

    if not data then
        self.shouldDisplay = false
        return
    end

    data.COLOR = data.COLOR or { r = 1, g = 1, b = 1 }

    --remove tooltip here
    self.iconFrame:SetScript("OnEnter", nil)
    self.iconFrame:SetScript("OnLeave", nil)

    local iconInfo = icons[data.TYPE]

    if iconInfo then
        self.iconFrame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/" .. iconInfo.tex .. ".png")
        self.iconFrame.icon:SetTexCoord(iconInfo.l, iconInfo.r, iconInfo.t, iconInfo.b)

        if data.TYPE == GW.TRACKER_TYPE.DELVE then
            self.iconFrame:SetScript("OnEnter", function()
                GameTooltip:SetOwner(self.iconFrame, "ANCHOR_LEFT")
                GameTooltip:SetSpellByID(self.iconFrame.tooltipSpellID)
            end)
            self.iconFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end

        if data.PROGRESS and iconInfo then
            self.bonusbar:Show()
            self.bonusbar.progress = data.PROGRESS
            self.bonusbar.bar:SetValue(data.PROGRESS)
            self.iconFrame.icon:SetTexture(nil)
        else
            self.bonusbar:Hide()
        end
    else
        self.iconFrame.icon:SetTexture(nil)
    end

    if data.COMPASS then
        self.compass:Show()
        self.compass.data = data
        self.compass.dataIndex = data.ID

        if iconInfo then
            self.compass.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/" .. iconInfo.tex .. ".png")
            self.compass.icon:SetTexCoord(iconInfo.l, iconInfo.r, iconInfo.t, iconInfo.b)
        else
            self.compass.icon:SetTexture(nil)
        end

        if (not currentCompassData or currentCompassData ~= self.compass.dataIndex) or not self.compass.Timer then
            currentCompassData = self.compass.dataIndex
            if self.compass.Timer then
                self.compass.Timer:Cancel()
                self.compass.Timer = nil
            end
            self.compass.Timer = C_Timer.NewTicker(0.025, function() updateRadar(self.compass) end)
        end

        self.iconFrame.icon:SetTexture(nil)
    else
        self.compass:Hide()
        if self.compass.Timer then
            self.compass.Timer:Cancel()
            self.compass.Timer = nil
        end
    end

    self.title:SetText(data.TITLE)
    self.title:SetTextColor(data.COLOR.r, data.COLOR.g, data.COLOR.b)
    self.compassBG:SetVertexColor(data.COLOR.r, data.COLOR.g, data.COLOR.b, 0.3)
    self.desc:SetText(data.DESC or "")

    if not data.DESC or data.DESC == "" then
        self.title:SetPoint("TOP", self, "TOP", 0, -30)
    else
        self.title:SetPoint("TOP", self, "TOP", 0, -15)
    end

    self.shouldDisplay = true
end

function GwObjectivesTrackerNotificationMixin:BonusbarOnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetText(GW.RoundDec(self.progress * 100, 0) .. "%")
    GameTooltip:Show()
end

function GwObjectivesTrackerNotificationMixin:OnUpdate()
    local prevState = self.shouldDisplay

    if GW.Libs.GW2Lib:GetPlayerLocationMapID() or GW.Libs.GW2Lib:GetPlayerInstanceMapID() then
        self:SetObjectiveNotification()
    end

    if prevState ~= self.shouldDisplay then
        self:NotificationStateChanged(self.shouldDisplay)
    end
end

function GwObjectivesTrackerNotificationMixin:OnEvent(event, ...)
    if GW.IsIn(event, "PLAYER_STARTED_MOVING", "PLAYER_CONTROL_LOST") then
        if self.Ticker then
            self.Ticker:Cancel()
            self.Ticker = nil
        end
        self.Ticker = C_Timer.NewTicker(1, function() self:OnUpdate() end)
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
        C_Timer.After(0.25, function() self:OnUpdate() end)
    end
end

function GwObjectivesTrackerNotificationMixin:InitModule()
    self.animatingState = false
    self.animating = false
    self.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.title:SetShadowOffset(1, -1)
    self.desc:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self.desc:SetShadowOffset(1, -1)
    self.bonusbar.bar:SetOrientation("VERTICAL")
    self.bonusbar.bar:SetMinMaxValues(0, 1)
    self.bonusbar.bar:SetValue(0.5)
    self.bonusbar:SetScript("OnEnter", self.BonusbarOnEnter)
    self.bonusbar:SetScript("OnLeave", GameTooltip_Hide)
    self.compass:SetScript("OnShow", self.compass.NewQuestAnimation)
    self.compass:SetScript("OnMouseDown", function() if GW.Retail then C_SuperTrack.ClearAllSuperTracked() end end)
    self.shouldDisplay = false

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
    if GW.Retail then
        self:RegisterEvent("QUEST_DATA_LOAD_RESULT")
        self:RegisterEvent("SUPER_TRACKING_CHANGED")
        self:RegisterEvent("SCENARIO_UPDATE")
        self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    end
    self:SetScript("OnEvent", self.OnEvent)
end
