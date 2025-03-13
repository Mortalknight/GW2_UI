local _, GW = ...
local L = GW.L
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local AddToAnimation = GW.AddToAnimation

local notifications = {}
local questCompass = {}

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

local function prioritys(a, b)
    if a == nil or a == "" then
        return true
    end
    if a == b then
        return true
    end
    return notification_priority[a] > notification_priority[b]
end
GW.AddForProfiling("notifications", "prioritys", prioritys)

local function getQuestPOIText(questLogIndex)
    local finalText = ""
    local text, finished
    local numFinished = 0
    local numItemDropTooltips = GetNumQuestItemDrops(questLogIndex)
    if numItemDropTooltips and numItemDropTooltips > 0 then
        for i = 1, numItemDropTooltips do
            text, _, finished = GetQuestLogItemDrop(i, questLogIndex)
            if text and not finished then
                finalText = finalText .. text .. "\n"
            end
            if finished then numFinished = numFinished + 1 end
        end
        if finalText == "" and numItemDropTooltips == numFinished then finalText = QUEST_WATCH_QUEST_READY end
    else
        local numObjectives = GetNumQuestLeaderBoards(questLogIndex)
        for i = 1, numObjectives do
            text, _, finished = GetQuestLogLeaderBoard(i, questLogIndex)

            if text and not finished then
                finalText = finalText .. text .. "\n"
            elseif text and numObjectives == 1  and finished then
                finalText = QUEST_WATCH_QUEST_READY
            end
            if finished then numFinished = numFinished + 1 end
        end
        if finalText == "" and numObjectives == numFinished then finalText = QUEST_WATCH_QUEST_READY end
    end
    return finalText
end
GW.AddForProfiling("notifications", "getQuestPOIText", getQuestPOIText)

local function getNearestQuestPOI()
    if not GW.Libs.GW2Lib:GetPlayerLocationMapID() then
        return nil
    end

    local numTrackedQuests = C_QuestLog.GetNumQuestWatches()
    local numTrackedWQ = C_QuestLog.GetNumWorldQuestWatches()
    local numQuests = C_QuestLog.GetNumQuestLogEntries()
    local x, y = GW.Libs.GW2Lib:GetPlayerLocationCoords()

    if (x == nil or y == nil) and (numTrackedQuests == 0 or numTrackedWQ == 0 or numQuests == 0) then
        return nil
    end

    local closestQuestID
    local minDistSqr = math.huge
    local isWQ = false
    wipe(questCompass)

    -- first check for nearest tracker WQ
    for i = 1, numTrackedWQ do
        local watchedWorldQuestID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
        if watchedWorldQuestID then
            local distanceSq = C_QuestLog.GetDistanceSqToQuest(watchedWorldQuestID)
            if distanceSq and distanceSq <= minDistSqr then
                minDistSqr = distanceSq;
                closestQuestID = watchedWorldQuestID
                isWQ = true
            end
        end
    end

    if not closestQuestID then
        local questID = C_SuperTrack.GetSuperTrackedQuestID()
        if questID and QuestHasPOIInfo(questID) then
            local distSqr, onContinent = C_QuestLog.GetDistanceSqToQuest(questID)
            if onContinent and distSqr <= minDistSqr then
                minDistSqr = distSqr
                closestQuestID = questID
            end
        end
    end

    -- If nothing with POI data is being tracked expand search to quest log
    if not closestQuestID then
        for questLogIndex = 1, numQuests do
            local questID = C_QuestLog.GetQuestIDForLogIndex(questLogIndex)
            local isOnMap, hasLocalPOI = QuestCache:Get(questID):IsOnMap()
            if questID and isOnMap and hasLocalPOI and QuestHasPOIInfo(questID) then
                local distSqr, onContinent = C_QuestLog.GetDistanceSqToQuest(questID)
                if onContinent and distSqr <= minDistSqr then
                    minDistSqr = distSqr
                    closestQuestID = questID
                end
            end
        end
    end

    if closestQuestID then
        local poiX, poiY
        if isWQ then
            poiX, poiY = C_TaskQuest.GetQuestLocation(closestQuestID, GW.Libs.GW2Lib:GetPlayerLocationMapID())
        else
            local questsOnMap = C_QuestLog.GetQuestsOnMap(GW.Libs.GW2Lib:GetPlayerLocationMapID())

            if questsOnMap then
                for _, info in ipairs(questsOnMap) do
                    if info.questID == closestQuestID then
                        poiX = info.x
                        poiY = info.y
                        break
                    end
                end
            end
        end

        if poiX then
            local objectiveText = isWQ and GW.ParseSimpleObjective(GetQuestObjectiveInfo(closestQuestID, 1, false)) or getQuestPOIText(C_QuestLog.GetLogIndexForQuestID(closestQuestID))
            local isCampaign = QuestCache:Get(closestQuestID):IsCampaign()
            local isFrequent = QuestCache:Get(closestQuestID).frequency and QuestCache:Get(closestQuestID).frequency > 0
            if QuestCache:Get(closestQuestID).frequency == nil then
                -- Could happens that blizzard returns the wrong value, check at the tracker is the quest us frequent to avoid a memory leak here
                local found = false
                for i = 1, 25 do
                    if _G["GwQuesttrackerContainerCampaignBlock" .. i] ~= nil and _G["GwQuesttrackerContainerCampaignBlock" .. i].questID == closestQuestID then
                        isFrequent = _G["GwQuesttrackerContainerCampaignBlock" .. i].isFrequency
                        found = true
                        break
                    end
                end
                if not found then
                    for i = 1, 25 do
                        if _G["GwQuesttrackerContainerQuestsBlock" .. i] ~= nil and _G["GwQuesttrackerContainerQuestsBlock" .. i].questID == closestQuestID then
                            isFrequent = _G["GwQuesttrackerContainerQuestsBlock" .. i].isFrequency
                            break
                        end
                    end
                end
            end
            questCompass.DESC = objectiveText
            questCompass.TITLE = QuestUtils_GetQuestName(closestQuestID)
            questCompass.ID = closestQuestID
            questCompass.X = poiX
            questCompass.Y = poiY
            questCompass.QUESTID = closestQuestID
            questCompass.TYPE = isCampaign and "CAMPAIGN" or isFrequent and "DAILY" or isWQ and "EVENT" or "QUEST"
            questCompass.COLOR = isCampaign and TRACKER_TYPE_COLOR.CAMPAIGN or isFrequent and TRACKER_TYPE_COLOR.DAILY or isWQ and TRACKER_TYPE_COLOR.EVENT or TRACKER_TYPE_COLOR.QUEST
            questCompass.COMPASS = true

            return questCompass
        end
    end

    return nil
end
GW.AddForProfiling("notifications", "getNearestQuestPOI", getNearestQuestPOI)

local function getBodyPOI()
    if not GW.Libs.GW2Lib:GetPlayerLocationMapID() then
        return nil
    end

    local corpTable = C_DeathInfo.GetCorpseMapPosition(GW.Libs.GW2Lib:GetPlayerLocationMapID())
    if corpTable == nil then
        return nil
    end

    local x, y = corpTable:GetXY()
    if x == nil or x == 0 then
        return nil
    end

    local bodyCompass = {}
    bodyCompass.X = x
    bodyCompass.Y = y
    bodyCompass.TITLE = L["Retrieve your corpse"]
    bodyCompass.TYPE = "DEAD"
    bodyCompass.ID = "playerDead"
    bodyCompass.COLOR = TRACKER_TYPE_COLOR.DEAD
    bodyCompass.COMPASS = true

    return bodyCompass
end
GW.AddForProfiling("notifications", "getBodyPOI", getBodyPOI)

local square_half = math.sqrt(0.5)
local rad_135 = math.rad(135)
local function updateRadar(self)
    if not GW.Libs.GW2Lib:GetPlayerLocationMapID() then
        return
    end

    local x, y = GW.Libs.GW2Lib:GetPlayerLocationCoords()
    if x == nil or y == nil or self.data.X == nil then
        self:GetParent():RemoveNotificationById(self.dataIndex)
        return
    end

    local pFacing = GetPlayerFacing()
    if pFacing == nil then pFacing = 0 end
    local dir_x = self.data.X - x
    local dir_y = self.data.Y - y
    local a = math.atan2(dir_y, dir_x)
    a = rad_135 - a - pFacing

    local sin, cos = math.sin(a) * square_half, math.cos(a) * square_half
    self.arrow:SetTexCoord(0.5 - sin, 0.5 + cos, 0.5 + cos, 0.5 + sin, 0.5 - cos, 0.5 - sin, 0.5 + sin, 0.5 - cos)
end
GW.AddForProfiling("notifications", "updateRadar", updateRadar)

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

    AddToAnimation(
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

    local data
    if UnitIsDeadOrGhost("player") then
        data = getBodyPOI()
    end
    if data == nil then
        for k, _ in pairs(notifications) do
            if not notifications[k].COMPASS and notifications[k] ~= nil then
                if data ~= nil then
                    if prioritys(data.TYPE, notifications[k].TYPE) then
                        data = notifications[k]
                    end
                else
                    data = notifications[k]
                end
            end
        end
    end
    if data == nil then
        data = getNearestQuestPOI()
    end
    if data == nil then
        self.shouldDisplay = false
        return
    end

    if data.COLOR == nil then
        data.COLOR = {r = 1, g = 1, b = 1}
    end

    --remove tooltip here
    self.iconFrame:SetScript("OnEnter", nil)
    self.iconFrame:SetScript("OnLeave", nil)

    if icons[data.TYPE] ~= nil then
        self.iconFrame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/" .. icons[data.TYPE].tex)
        self.iconFrame.icon:SetTexCoord(
            icons[data.TYPE].l,
            icons[data.TYPE].r,
            icons[data.TYPE].t,
            icons[data.TYPE].b
        )

        if data.TYPE == "DELVE" then
            self.iconFrame:SetScript("OnEnter", function()
                GameTooltip:SetOwner(self.iconFrame, "ANCHOR_LEFT")
                GameTooltip:SetSpellByID(self.iconFrame.tooltipSpellID)
            end)
            self.iconFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end

        if data.PROGRESS ~= nil and icons[data.TYPE] then
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

        if icons[data.TYPE] ~= nil then
            self.compass.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/" .. icons[data.TYPE].tex)
            self.compass.icon:SetTexCoord(
                icons[data.TYPE].l,
                icons[data.TYPE].r,
                icons[data.TYPE].t,
                icons[data.TYPE].b
            )
        else
            self.compass.icon:SetTexture(nil)
        end

        if currentCompassData and currentCompassData ~= self.compass.dataIndex then
            currentCompassData = self.compass.dataIndex
            if self.compass.Timer then
                self.compass.Timer:Cancel()
                self.compass.Timer = nil
            end
            self.compass.Timer = C_Timer.NewTicker(0.025, function() updateRadar(self.compass) end)
        elseif not currentCompassData then
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
    self.desc:SetText(data.DESC)

    if data.DESC == nil or data.DESC == "" then
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
    self.compass:SetScript("OnMouseDown", function() C_SuperTrack.SetSuperTrackedQuestID(0) end)

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
    self:RegisterEvent("QUEST_DATA_LOAD_RESULT")
    self:RegisterEvent("SUPER_TRACKING_CHANGED")
    self:RegisterEvent("SCENARIO_UPDATE")
    self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    self:SetScript("OnEvent", self.OnEvent)
end
