local _, GW = ...
local L = GW.L
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local GetSetting = GW.GetSetting
--local QuestTrackerLayoutChanged = GW.QuestTrackerLayoutChanged
local AddToAnimation = GW.AddToAnimation

local currentNotificationKey = ""
local currentMapID = ""
local notifications = {}

local icons = {}
icons["QUEST"] = {tex = "icon-objective", l = 0, r = 1, t = 0.25, b = 0.5}
icons["EVENT_NEARBY"] = {tex = "icon-objective", l = 0, r = 1, t = 0.5, b = 0.75}
icons["EVENT"] = {tex = "icon-objective", l = 0, r = 1, t = 0.5, b = 0.75}
icons["SCENARIO"] = {tex = "icon-objective", l = 0, r = 1, t = 0.75, b = 1}
icons["BOSS"] = {tex = "icon-boss", l = 0, r = 1, t = 0, b = 1}
icons["DEAD"] = {tex = "party/icon-dead", l = 0, r = 1, t = 0, b = 1}
icons["ARENA"] = {tex = "icon-arena", l = 0, r = 1, t = 0, b = 1}

local notification_priority = {}
notification_priority["EVENT_NEARBY"] = 1
notification_priority["SCENARIO"] = 2
notification_priority["EVENT"] = 3
notification_priority["ARENA"] = 4
notification_priority["BOSS"] = 5

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
    local numItemDropTooltips = GetNumQuestItemDrops(questLogIndex)
    if numItemDropTooltips and numItemDropTooltips > 0 then
        for i = 1, numItemDropTooltips do
            text, _, finished = GetQuestLogItemDrop(i, questLogIndex)
            if text and not finished then
                finalText = finalText .. text .. "\n"
            end
        end
    else
        --local numPOITooltips = QuestBlobDataProvider:GetNumTooltips()
        local numObjectives = GetNumQuestLeaderBoards(questLogIndex)
        for i = 1, numObjectives do
            if numPOITooltips and (numPOITooltips == numObjectives) then
                local questPOIIndex = QuestBlobDataProvider:GetTooltipIndex(i)
                text, _, finished = GetQuestPOILeaderBoard(questPOIIndex, questLogIndex)
            else
                text, _, finished = GetQuestLogLeaderBoard(i, questLogIndex)
            end
            if text and not finished then
                finalText = finalText .. text .. "\n"
            end
        end
    end
    return finalText
end
GW.AddForProfiling("notifications", "getQuestPOIText", getQuestPOIText)

local questCompass = {
    ["TYPE"] = "QUEST",
    ["COLOR"] = TRACKER_TYPE_COLOR["QUEST"],
    ["COMPASS"] = true
}
local function getNearestQuestPOI(currentMapID)
    if not currentMapID then
        return nil
    end

	local posX, posY = GW.GetPlayerMapPos(currentMapID)
    
    local numQuests, _ = GetNumQuestLogEntries()
    if posX == nil or posY == nil or numQuests == nil then
        return nil
    end

    local closest = false
    for i = 1, numQuests do
        local title, _, _, isHeader, _, isComplete, _, questID, _, _, _, hasLocalPOI, _ = GetQuestLogTitle(i)
        if not isHeader and not isComplete and hasLocalPOI then
            local _, poiX, poiY, _ = QuestPOIGetIconInfo(questID)
            if poiX then
                local dx = posX - poiX
                local dy = posY - poiY
                local dist = sqrt(dx * dx + dy * dy)
                if not closest or dist < closest then
                    closest = dist
                    local objectiveText = getQuestPOIText(i)
                    questCompass["DESC"] = objectiveText
                    questCompass["TITLE"] = title
                    questCompass["ID"] = questID
                    questCompass["X"] = poiX
                    questCompass["Y"] = poiY
                    questCompass["QUESTID"] = questID
                end
            end
        end
    end
    if closest then
        return questCompass
    else
        return nil
    end
end
GW.AddForProfiling("notifications", "getNearestQuestPOI", getNearestQuestPOI)

local bodyCompass = {
    ["TYPE"] = "DEAD",
    ["ID"] = "playerDead",
    ["COLOR"] = TRACKER_TYPE_COLOR["DEAD"],
    ["COMPASS"] = true
}
local function getBodyPOI()
    if not currentMapID then
        return nil
    end

    local posX, posY = GW.GetPlayerMapPos(currentMapID)
    if posX == nil or posY == nil then
        return nil
    end

    local corpTable = C_DeathInfo.GetCorpseMapPosition(currentMapID)
    if corpTable == nil then
        return nil
    end

    local x, y = corpTable:GetXY()
    if x == nil or x == 0 then
        return nil
    end

    bodyCompass["X"] = x
    bodyCompass["Y"] = y
    bodyCompass["TITLE"] = L["TRACKER_RETRIVE_CORPSE"]

    return bodyCompass
end
GW.AddForProfiling("notifications", "getBodyPOI", getBodyPOI)

local function AddTrackerNotification(data)
    if data == nil or data["ID"] == nil then
        return
    end

    notifications[data["ID"]] = data

    --   SetObjectiveNotification()
end
GW.AddTrackerNotification = AddTrackerNotification

local function RemoveTrackerNotification(notificationID)
    if data == nil or notificationID == nil then
        return
    end
    notifications[data["ID"]] = nil
    --   SetObjectiveNotification()
end
GW.RemoveTrackerNotification = RemoveTrackerNotification

local function RemoveTrackerNotificationOfType(doType)
    for k, v in pairs(notifications) do
        if v["TYPE"] == doType then
            notifications[k] = nil
        end
    end
    --   SetObjectiveNotification()
end
GW.RemoveTrackerNotificationOfType = RemoveTrackerNotificationOfType

local function removeNotification(key)
    currentNotificationKey = ""
    GwObjectivesNotification.shouldDisplay = false
end
GW.AddForProfiling("notifications", "removeNotification", removeNotification)

local function NotificationStateChanged(show)
    if show then
        GwObjectivesNotification:Show()
    end
    AddToAnimation(
        "notificationToggle",
        0,
        70,
        GetTime(),
        0.2,
        function(step)
            if show == false then
                step = 70 - step
            end

            GwObjectivesNotification:SetAlpha(step / 70)
            GwObjectivesNotification:SetHeight(math.max(step, 1))
        end,
        nil,
        function()
            if not show then
                GwObjectivesNotification:Hide()
            end
            GwObjectivesNotification.animating = false
            GW.QuestTrackerLayoutChanged()
        end,
        true
    )
end
GW.NotificationStateChanged = NotificationStateChanged

local square_half = math.sqrt(0.5)
local rad_135 = math.rad(135)
local function updateRadar(self, elapsed)
    if not currentMapID then
        return
    end
    self.TotalElapsed = self.TotalElapsed + elapsed
    if self.TotalElapsed < 0.016 then
        return
    end
    self.TotalElapsed = 0

	local posX, posY = GW.GetPlayerMapPos(currentMapID)

    if posX == nil or posY == nil or self.data["X"] == nil then
        RemoveTrackerNotification(GwObjectivesNotification.compass.dataIndex)
        return
    end

    local pFacing = GetPlayerFacing()
    if pFacing == nil then pFacing = 0 end
    local dir_x = self.data["X"] - posX
    local dir_y = self.data["Y"] - posY
    local a = math.atan2(dir_y, dir_x)
    a = rad_135 - a - pFacing

    local sin, cos = math.sin(a) * square_half, math.cos(a) * square_half
    self.arrow:SetTexCoord(0.5 - sin, 0.5 + cos, 0.5 + cos, 0.5 + sin, 0.5 - cos, 0.5 - sin, 0.5 + sin, 0.5 - cos)
end
GW.AddForProfiling("notifications", "updateRadar", updateRadar)

local function SetObjectiveNotification(mapID)
    currentMapID = mapID
    local data
    for k, v in pairs(notifications) do
        if not notifications[k]["COMPASS"] and notifications[k] ~= nil then
            if data ~= nil then
                if prioritys(data["TYPE"], notifications[k]["TYPE"]) then
                    data = notifications[k]
                end
            else
                data = notifications[k]
            end
        end
    end

    if data == nil and GetSetting("SHOW_QUESTTRACKER_COMPASS") then
        if UnitIsDeadOrGhost("PLAYER") then
            data = getBodyPOI()
        end
        if data == nil then
            data = getNearestQuestPOI(currentMapID)
        end
    end

    if data == nil then
        removeNotification(currentNotificationKey)
        return
    end

    local key = data["TYPE"]
    local title = data["TITLE"]
    local desc = data["DESC"]
    local color = data["COLOR"]
    local useRadar = data["COMPASS"]
    local progress = data["PROGRESS"]

    if color == nil then
        color = {r = 1, g = 1, b = 1}
    end

    currentNotificationKey = key

    if icons[data["TYPE"]] ~= nil then
        GwObjectivesNotification.icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\" .. icons[data["TYPE"]].tex)
        GwObjectivesNotification.icon:SetTexCoord(
            icons[data["TYPE"]].l,
            icons[data["TYPE"]].r,
            icons[data["TYPE"]].t,
            icons[data["TYPE"]].b
        )

        if progress ~= nil and icons[data["TYPE"]] then
            GwObjectivesNotification.bonusbar:Show()
            GwObjectivesNotification.bonusbar.progress = progress
            GwObjectivesNotification.bonusbar.bar:SetValue(progress)
            GwObjectivesNotification.icon:SetTexture(nil)
        else
            GwObjectivesNotification.bonusbar:Hide()
        end
    else
        GwObjectivesNotification.icon:SetTexture(nil)
    end

    if useRadar then
        GwObjectivesNotification.compass:Show()
        GwObjectivesNotification.compass.data = data
        GwObjectivesNotification.compass.dataIndex = data["ID"]

        if icons[data["TYPE"]] ~= nil then
            GwObjectivesNotification.compass.icon:SetTexture(
                "Interface\\AddOns\\GW2_UI\\textures\\" .. icons[data["TYPE"]].tex
            )
            GwObjectivesNotification.compass.icon:SetTexCoord(
                icons[data["TYPE"]].l,
                icons[data["TYPE"]].r,
                icons[data["TYPE"]].t,
                icons[data["TYPE"]].b
            )
        else
            GwObjectivesNotification.compass.icon:SetTexture(nil)
        end

        GwObjectivesNotification.compass.TotalElapsed = 0
        GwObjectivesNotification.compass:SetScript("OnUpdate", updateRadar)
        GwObjectivesNotification.icon:SetTexture(nil)
    else
        GwObjectivesNotification.compass:Hide()
        GwObjectivesNotification.compass:SetScript("OnUpdate", nil)
    end

    GwObjectivesNotification.title:SetText(title)
    GwObjectivesNotification.title:SetTextColor(color.r, color.g, color.b)
    GwObjectivesNotification.desc:SetText(desc)

    if desc == nil or desc == "" then
        GwObjectivesNotification.title:SetPoint("TOP", GwObjectivesNotification, "TOP", 0, -30)
    else
        GwObjectivesNotification.title:SetPoint("TOP", GwObjectivesNotification, "TOP", 0, -15)
    end
    GwObjectivesNotification.shouldDisplay = true
end
GW.SetObjectiveNotification = SetObjectiveNotification
