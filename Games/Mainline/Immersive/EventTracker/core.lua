---@class GW2
local GW = select(2, ...)
local L = GW.L

--[[
    World event tracker: a bar below the world map with one tracker per event plus the summary
    tooltip on the micro menu icon.
    Credits: fang2hou -> ElvUI_Windtools

    core.lua          infrastructure, shared helpers, tracker pool and layout
    weekly.lua        tracker type for weekly quests
    loopTimer.lua     tracker type for events running on a fixed schedule
    <expansion>.lua   the events, registered in display order via ET:RegisterEvent
]]--

local ET = {
    types = {},     -- tracker types by args.type (weekly.lua, loopTimer.lua)
    events = {},    -- event definitions by key
    eventList = {}, -- event keys in display order (= registration order)
    pool = {},      -- created tracker frames by key
}
GW.EventTracker = ET

local mapFrame
local eventHandlers = {}

ET.LeftButtonIcon = "|TInterface/TUTORIALFRAME/UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t"

ET.infoColors = {
    greyLight = "b5b5b5",
    primary = "00d1b2",
    success = "48c774",
    link = "3273dc",
    info = "209cee",
    danger = "ff3860",
    warning = "ffdd57"
}
-- rgb variants for SetTextColor, converted once instead of on every ticker tick
ET.infoRGB = {}
for key, hex in pairs(ET.infoColors) do
    ET.infoRGB[key] = { GW.HexToRGB(hex) }
end

---------- text / format helpers ----------

function ET.SecondToTime(second)
    local hour = floor(second / 3600)
    local min = floor((second - hour * 3600) / 60)
    local sec = floor(second - hour * 3600 - min * 60)

    if hour == 0 then
        return format("%02d:%02d", min, sec)
    else
        return format("%02d:%02d:%02d", hour, min, sec)
    end
end

function ET.StringWithHex(text, color)
    return format("|cff%s%s|r", color, text)
end

function ET.StringByTemplate(text, template)
    return ET.StringWithHex(text, ET.infoColors[template])
end

function ET.GetMapName(mapID)
    local info = mapID and C_Map.GetMapInfo(mapID)
    return info and info.name or nil
end

-- "<icon> name (map)" label for storyline entries, position may be a map id or a text
function ET.WeeklyName(iconID, name, position)
    name = GW.GetIconString(iconID, 14, 16, true) .. " " .. name
    if type(position) == "number" then
        position = ET.GetMapName(position)
    end

    if position then
        name = format("%s (%s)", name, ET.StringByTemplate(position, "info"))
    end

    return name
end

function ET.SafeNumber(value)
    local success, number = pcall(tonumber, value)
    return success and number or nil
end

---------- event definition helpers ----------

-- start timestamps differ per region; TW has no own region id, KR clients that are not koKR are TW
function ET.RegionTimestamp(timestamps)
    local region = GetCurrentRegion()
    if region == 2 and GW.mylocal ~= "koKR" then
        region = 4
    end

    return timestamps[region] or timestamps[1]
end

-- filter: the tracker (alerts) only matter once a quest, e.g. the expansion intro, is done
function ET.QuestCompletedFilter(questID)
    return function()
        return C_QuestLog.IsQuestFlaggedCompleted(questID)
    end
end

-- single quest id or a list of alternatives
function ET.IsAnyQuestCompleted(questIDs)
    if type(questIDs) == "table" then
        for _, questID in pairs(questIDs) do
            if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                return true
            end
        end
        return false
    end

    return questIDs ~= nil and C_QuestLog.IsQuestFlaggedCompleted(questIDs)
end

-- flat quest list: completed when one (or, with checkAllCompleted, every) quest is done
function ET.IsQuestListCompleted(questIDs, checkAllCompleted)
    local completed = 0
    if checkAllCompleted then
        completed = 1 - #questIDs
    end

    for _, questID in pairs(questIDs) do
        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
            completed = completed + 1
        end
    end

    return completed > 0
end

-- storyline map { [label] = { questIDs... } }: one tooltip row per storyline with the quest that
-- is done or accepted this week
function ET.StorylineQuestProgress(args)
    local questIDs = type(args.questIDs) == "function" and args:questIDs() or args.questIDs
    local progress = {}

    for storylineName, storylineQuests in pairs(questIDs) do
        local weeklyQuestID, status
        for _, questID in pairs(storylineQuests) do
            if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                weeklyQuestID, status = questID, "completed"
                break
            end

            if C_QuestLog.IsOnQuest(questID) then
                weeklyQuestID, status = questID, C_QuestLog.IsComplete(questID) and "readyForTurnIn" or "inProgress"
                break
            end
        end

        local questName = weeklyQuestID and C_QuestLog.GetTitleForQuestID(weeklyQuestID)
        local prefix = questName and (questName .. " - ") or ""
        local rightText
        if status == "inProgress" then
            rightText = prefix .. ET.StringByTemplate(IN_PROGRESS, "warning")
        elseif status == "readyForTurnIn" then
            rightText = prefix .. ET.StringByTemplate(QUEST_WATCH_QUEST_READY, "success")
        elseif status == "completed" then
            rightText = prefix .. ET.StringByTemplate(CRITERIA_COMPLETED, "success")
        else
            rightText = ET.StringByTemplate(L["Not Accepted"], "danger")
        end

        tinsert(progress, { label = storylineName, rightText = rightText })
    end

    -- pairs order is random, keep the tooltip stable
    sort(progress, function(a, b) return a.label < b.label end)

    return progress
end

---------- tooltip building blocks ----------

function ET.TooltipHeader(self)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 8)
    GameTooltip:SetText(GW.GetIconString(self.args.icon, 16, 16) .. " " .. self.args.eventName, 1, 1, 1)
end

function ET.AddLocationLines(self)
    for _, locationContext in ipairs({
        { LOCATION_COLON, self.args.location },
        { L["Current Location"], self.args.currentLocation },
        { L["Next Location"], self.args.nextLocation },
    }) do
        local left, right = locationContext[1], locationContext[2]
        if right then
            right = type(right) == "function" and right(self.args) or right
            GameTooltip:AddDoubleLine(left, right, 1, 1, 1)
        end
    end
end

function ET.AddQuestProgressLines(self)
    if not self.args.questProgress then
        return
    end

    local questProgress = self.args.questProgress
    if type(questProgress) == "function" then
        questProgress = questProgress(self.args)
    end
    if not questProgress then
        return
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["Quest Progress:"], 1, 1, 1)
    for _, data in ipairs(questProgress) do
        local label = type(data.label) == "function" and data:label() or data.label
        if type(label) == "string" then
            local isCompleted = data.isCompleted or (data.questID ~= nil and ET.IsAnyQuestCompleted(data.questID))
            local rightText = data.rightText or ET.StringByTemplate(isCompleted and CRITERIA_COMPLETED or CRITERIA_NOT_COMPLETED, isCompleted and "success" or "danger")
            GameTooltip:AddDoubleLine(label, rightText, 1, 1, 1)
        end
    end
end

function ET.AddWeeklyRewardLine(self)
    if not self.args.hasWeeklyReward then
        return
    end

    if self.isCompleted then
        GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD, ET.StringByTemplate(CRITERIA_COMPLETED, "success"), 1, 1, 1)
    else
        GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD, ET.StringByTemplate(CRITERIA_NOT_COMPLETED, "danger"), 1, 1, 1)
    end
end

function ET.AddClickHelpLine(self)
    if self.args.onClickHelpText then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(ET.LeftButtonIcon .. " " .. self.args.onClickHelpText, 1, 1, 1)
    end
end

---------- row look ----------

ET.rowColors = {
    completed = CreateColor(0.6, 0.6, 0.6),
    open = GW.Colors.FactionBarColors[1], -- gw2 red
}

ET.colorPalette = {
    blue = CreateColor(0.32941, 0.52157, 0.93333),
    red = CreateColor(0.92549, 0.00000, 0.54902),
    green = CreateColor(0.40392, 0.92549, 0.54902),
    purple = CreateColor(0.55686, 0.32941, 0.91373),
    bronze = CreateColor(0.83000, 0.42000, 0.10000),
    running = CreateColor(0 / 255, 211 / 255, 144 / 255),
    gray = CreateColor(159 / 255, 159 / 255, 159 / 255),
}

function ET.CreateRow(self)
    self.background = self:CreateTexture(nil, "BACKGROUND")
    self.background:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
    self.background:SetAllPoints()
    self.background:SetVertexColor(1, 1, 1, 0.7)

    self.stateOverlay = self:CreateTexture(nil, "BORDER")
    self.stateOverlay:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    self.stateOverlay:SetAllPoints()

    self.icon = self:CreateTexture(nil, "ARTWORK")
    self.iconBorder = self:CreateTexture(nil, "OVERLAY")
    self.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")

    self.name = self:CreateFontString(nil, "OVERLAY")
    self.timerText = self:CreateFontString(nil, "OVERLAY")
    self.subText = self:CreateFontString(nil, "OVERLAY")

    self.progress = CreateFrame("StatusBar", nil, self)
    self.progress:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    self.progress:SetMinMaxValues(0, 1)
    self.progress.bg = self.progress:CreateTexture(nil, "BACKGROUND")
    self.progress.bg:SetColorTexture(0, 0, 0, 0.5)
    self.progress.bg:SetAllPoints()
end

function ET.SetupRow(self)
    self.icon:SetTexture(self.args.icon)
    self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.icon:SetSize(24, 24)
    self.icon:ClearAllPoints()
    self.icon:SetPoint("LEFT", self, "LEFT", 3, 0)
    self.iconBorder:SetSize(24, 24)
    self.iconBorder:ClearAllPoints()
    self.iconBorder:SetPoint("CENTER", self.icon, "CENTER", 0, 0)

    self.timerText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
    self.timerText:ClearAllPoints()
    self.timerText:SetPoint("TOPRIGHT", self, "TOPRIGHT", -4, -4)
    self.timerText:SetJustifyH("RIGHT")

    self.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
    self.name:ClearAllPoints()
    self.name:SetPoint("TOPLEFT", self, "TOPLEFT", 32, -4)
    self.name:SetPoint("TOPRIGHT", self.timerText, "TOPLEFT", -4, 0)
    self.name:SetJustifyH("LEFT")
    self.name:SetWordWrap(false)
    self.name:SetText(self.args.label)

    self.subText:SetFont(UNIT_NAME_FONT, 10, "OUTLINE")
    self.subText:ClearAllPoints()
    self.subText:SetPoint("TOPLEFT", self, "TOPLEFT", 32, -17)
    self.subText:SetPoint("TOPRIGHT", self, "TOPRIGHT", -4, -17)
    self.subText:SetJustifyH("LEFT")
    self.subText:SetWordWrap(false)

    self.progress:ClearAllPoints()
    -- 34px row: name 4-16, sub line 17-27, line 28-30 (from the top)
    self.progress:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 32, 4)
    self.progress:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4)
    self.progress:SetHeight(2)

    self.rowState = nil -- force the next SetRowState to apply
end

-- state: "neutral" (waiting / done) or "running"; colors only change on a state change
function ET.SetRowState(self, state)
    if self.rowState == state then
        return
    end
    self.rowState = state

    if state == "running" then
        local color = self.args.runningBarColor or ET.colorPalette.running
        self.stateOverlay:SetVertexColor(color.r, color.g, color.b, 0.45)
        self.progress:SetStatusBarColor(color:GetRGB())
        self.timerText:SetTextColor(color:GetRGB())
        self.subText:SetTextColor(color:GetRGB())
    else
        local color = self.args.barColor or ET.colorPalette.blue
        self.stateOverlay:SetVertexColor(color.r, color.g, color.b, 0.15)
        self.progress:SetStatusBarColor(color:GetRGB())
        self.timerText:SetTextColor(1, 1, 1)
        self.subText:SetTextColor(ET.rowColors.completed:GetRGB())
    end
end

function ET.SetRowHover(self, hover)
    self.stateOverlay:SetBlendMode(hover and "ADD" or "BLEND")
end

function ET.GetWorldMapIDSetter(idOrFunc)
    return function(...)
        if not WorldMapFrame or not WorldMapFrame:IsShown() or not WorldMapFrame.SetMapID then
            return
        end

        local id = type(idOrFunc) == "function" and idOrFunc(...) or idOrFunc
        WorldMapFrame:SetMapID(id)
    end
end

---------- registration ----------

-- data = { dbKey = <settings key>, args = { type = "weekly" | "loopTimer", ... } }
function ET:RegisterEvent(key, data)
    if self.events[key] then
        return
    end

    self.events[key] = data
    tinsert(self.eventList, key)
end

---------- micro menu summary tooltip ----------

function ET.OnEnterAll(self)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip_SetTitle(GameTooltip, self.tooltipText)
    GameTooltip:AddLine(" ")
    for _, event in ipairs(ET.eventList) do
        local data = ET.events[event]
        local frame = data.frame

        if GW.settings.weeklyEvents[data.dbKey].enabled and frame then
            GameTooltip:AddLine(GW.GetIconString(data.args.icon, 16, 16) .. " " .. data.args.eventName, GW.Colors.TextColors.LightHeader:GetRGB())
            GameTooltip:AddDoubleLine(LOCATION_COLON, data.args.location, 1, 1, 1, 1, 1, 1)

            if data.args.interval then
                GameTooltip:AddDoubleLine(L["Interval"] .. ":", ET.SecondToTime(data.args.interval), 1, 1, 1, 1, 1, 1)
            end
            if data.args.duration then
                GameTooltip:AddDoubleLine(AUCTION_DURATION .. ":", ET.SecondToTime(data.args.duration), 1, 1, 1, 1, 1, 1)
            end
            if frame.nextEventTimestamp then
                GameTooltip:AddDoubleLine(L["Next Event"] .. ":", date(L["TimeStamp m/d h:m:s"], frame.nextEventTimestamp), 1, 1, 1, 1, 1, 1)
            end

            if frame.isRunning then
                GameTooltip:AddDoubleLine(STATUS .. ":", ET.StringByTemplate(data.args.runningText, "success"), 1, 1, 1, 1, 1, 1)
            else
                GameTooltip:AddDoubleLine(STATUS .. ":", ET.StringByTemplate(QUEUED_STATUS_WAITING, "greyLight"), 1, 1, 1, 1, 1, 1)
            end

            if data.args.hasWeeklyReward then
                if frame.isCompleted then
                    GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD .. ":", ET.StringByTemplate(CRITERIA_COMPLETED, "success"), 1, 1, 1, 1, 1, 1)
                else
                    GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD .. ":", ET.StringByTemplate(CRITERIA_NOT_COMPLETED, "danger"), 1, 1, 1, 1, 1, 1)
                end
            end
            GameTooltip:AddLine(" ")
        end
    end

    GameTooltip:Show()
end

---------- game events for event definitions (args.events = { { "EVENT", handler }, ... }) ----------

local function HandlerEvent(_, event, ...)
    if eventHandlers[event] then
        for _, handler in ipairs(eventHandlers[event]) do
            handler(...)
        end
    end
end

local function AddEventHandler(event, handler)
    if not eventHandlers[event] then
        eventHandlers[event] = {}
        if mapFrame then
            mapFrame:RegisterEvent(event)
        end
    end

    tinsert(eventHandlers[event], handler)
end

---------- tracker pool ----------

function ET:GetTracker(event)
    if self.pool[event] then
        self.pool[event]:Show()
        return self.pool[event]
    end

    local data = self.events[event]

    local frame = CreateFrame("Frame", "GW2_EventTracker" .. event, mapFrame)
    frame:SetSize(190, 34)

    frame.args = data.args
    frame.dbKey = data.dbKey
    data.frame = frame

    local functions = self.types[data.args.type]
    if functions then
        if functions.init then
            functions.init(frame)
        end

        if functions.setup then
            functions.setup(frame)
            frame.profileUpdate = function()
                functions.setup(frame)
            end
        end

        if functions.ticker then
            frame.tickFunc = function()
                functions.ticker.dateUpdater(frame)
                if functions.ticker.alert then
                    functions.ticker.alert(frame)
                end
                if WorldMapFrame:IsShown() and frame:IsShown() then
                    functions.ticker.uiUpdater(frame)
                end
            end

            local interval = functions.ticker.interval
            frame.tickerInstance = C_Timer.NewTicker(interval, function()
                if not frame:IsShown() then
                    return
                end
                if WorldMapFrame:IsShown() then
                    frame.bgTickAccum = 0
                    frame.tickFunc()
                else
                    frame.bgTickAccum = (frame.bgTickAccum or 0) + interval
                    if frame.bgTickAccum >= 1 then
                        frame.bgTickAccum = 0
                        frame.tickFunc()
                    end
                end
            end)
        end

        frame:SetScript("OnEnter", function()
            ET.SetRowHover(frame, true)
            if functions.tooltip then
                functions.tooltip.onEnter(frame)
            end
        end)
        frame:SetScript("OnLeave", function()
            ET.SetRowHover(frame, false)
            GameTooltip:Hide()
        end)
    end

    if data.args.events then
        for _, eventToAdd in ipairs(data.args.events) do
            AddEventHandler(eventToAdd[1], eventToAdd[2])
        end
    end

    self.pool[event] = frame

    return frame
end

function ET:DisableTracker(event)
    if self.pool[event] then
        self.pool[event]:Hide()
    end
end

---------- map frame + layout ----------

local function AddWorldMapFrame()
    if not WorldMapFrame or mapFrame then
        return
    end

    mapFrame = CreateFrame("Frame", "GW2_EventTracker", WorldMapFrame)
    mapFrame.heightPerRow = 34
    mapFrame.padding = 4
    mapFrame:SetFrameStrata("MEDIUM")
    mapFrame:SetPoint("TOPLEFT", WorldMapFrame, "BOTTOMLEFT", 0, 0)
    mapFrame:SetPoint("TOPRIGHT", WorldMapFrame, "BOTTOMRIGHT", 0, 0)
    mapFrame:SetHeight(mapFrame.heightPerRow + 2 * mapFrame.padding)

    mapFrame.separator = mapFrame:CreateTexture(nil, "ARTWORK")
    mapFrame.separator:SetColorTexture(1, 1, 1, 0.2)
    mapFrame.separator:SetPoint("TOPLEFT", mapFrame, "TOPLEFT", 6, 0)
    mapFrame.separator:SetPoint("TOPRIGHT", mapFrame, "TOPRIGHT", -6, 0)
    mapFrame.separator:SetHeight(1)

    mapFrame:SetScript("OnEvent", HandlerEvent)
end

local function UpdateTrackers()
    local lastTracker = nil
    local usedWidth = 0
    local mapFrameWidth = WorldMapFrame:GetWidth()
    local rowIdx = 1
    local anyEnabled = false

    for _, event in ipairs(ET.eventList) do
        local data = ET.events[event]
        local settings = GW.settings.weeklyEvents[data.dbKey]
        local tracker = settings.enabled and ET:GetTracker(event) or ET:DisableTracker(event)
        if tracker then
            anyEnabled = true
            if tracker.profileUpdate then
                tracker.profileUpdate()
            end

            tracker.args.desaturate = settings.desaturate
            tracker.args.flashTaskbar = settings.flashTaskbar

            if settings.alert then
                tracker.args.alert = true
                tracker.args.alertSecond = tonumber(settings.alertSeconds)
                tracker.args.stopAlertIfCompleted = settings.stopAlertIfCompleted
            else
                tracker.args.alert = nil
                tracker.args.alertSecond = nil
                tracker.args.stopAlertIfCompleted = nil
            end

            if usedWidth + tracker:GetWidth() + 5 > mapFrameWidth then
                -- create a new row
                lastTracker = nil
                usedWidth = 0
                rowIdx = rowIdx + 1
            end

            tracker:ClearAllPoints()
            if lastTracker then
                tracker:SetPoint("LEFT", lastTracker, "RIGHT", 5, 0)
                usedWidth = usedWidth + tracker:GetWidth() + 5
            else
                tracker:SetPoint("TOPLEFT", mapFrame, "TOPLEFT", 6, -(mapFrame.padding + mapFrame.heightPerRow * (rowIdx - 1)))
                usedWidth = usedWidth + tracker:GetWidth() + 6
            end
            lastTracker = tracker

            if tracker.tickFunc then
                tracker.tickFunc()
            end
        end
    end

    mapFrame:SetHeight(mapFrame.heightPerRow * rowIdx + 2 * mapFrame.padding)
    mapFrame:SetShown(anyEnabled)

    -- pull the window body background down over the bar (WorldMapFrame.tex comes from the map skin)
    if WorldMapFrame.tex then
        WorldMapFrame.tex:SetPoint("BOTTOMRIGHT", anyEnabled and mapFrame or WorldMapFrame, "BOTTOMRIGHT", 0, 0)
    end
end
GW.UpdateWorldEventTrackers = UpdateTrackers

function GW.LoadWorldEventTimer()
    AddWorldMapFrame()
    UpdateTrackers()

    EventRegistry:RegisterCallback("WorldMapOnShow", UpdateTrackers)
    EventRegistry:RegisterCallback("WorldMapMinimized", function() C_Timer.After(0.1, UpdateTrackers) end)
    EventRegistry:RegisterCallback("WorldMapMaximized", function() C_Timer.After(0.1, UpdateTrackers) end)
    QuestMapFrame:HookScript("OnShow", UpdateTrackers)
    QuestMapFrame:HookScript("OnHide", UpdateTrackers)
end
