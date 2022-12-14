local _, GW = ...
local L = GW.L

--[[
 	Credits: fang2hou -> ElvUI_Windtools
 ]]--

local mapFrame

local eventList = {
    "CommunityFeast",
    "SiegeOnDragonbaneKeep"
}

local infoColors = {
    greyLight = "b5b5b5",
    primary = "00d1b2",
    success = "48c774",
    link = "3273dc",
    info = "209cee",
    danger = "ff3860",
    warning = "ffdd57"
}

local colorPlatte = {
    blue = {
        { r = 0.32941, g = 0.52157, b = 0.93333, a = 1 },
        { r = 0.25882, g = 0.84314, b = 0.86667, a = 1 }
    },
    red = {
        { r = 0.92549, g = 0.00000, b = 0.54902, a = 1 },
        { r = 0.98824, g = 0.40392, b = 0.40392, a = 1 }
    },
    running = {
        { r = 0.00000, g = 0.94902, b = 0.37647, a = 1 },
        { r = 0.01961, g = 0.45882, b = 0.90196, a = 1 }
    }
}


local function secondToTime(second)
    local hour = floor(second / 3600)
    local min = floor((second - hour * 3600) / 60)
    local sec = floor(second - hour * 3600 - min * 60)

    if hour == 0 then
        return format("%02d:%02d", min, sec)
    else
        return format("%02d:%02d:%02d", hour, min, sec)
    end
end

local function CreateColorFromTable(colorTable)
    return CreateColor(colorTable.r, colorTable.g, colorTable.b, colorTable.a)
end

local function StringWithHex(text, color)
    return format("|cff%s%s|r", color, text)
end

local function StringByTemplate(text, template)
    return StringWithHex(text, infoColors[template])
end

local function reskinStatusBar(bar)
    bar:SetFrameLevel(bar:GetFrameLevel() + 1)
    bar:StripTextures()
    bar:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
    bar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/hud/castinbar-white")
end

local functionFactory = {
    loopTimer = {
        init = function(self)
            self.icon = self:CreateTexture(nil, "ARTWORK")
            self.icon:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
            self.icon.backdrop:SetOutside(self.icon, 1, 1)
            self.statusBar = CreateFrame("StatusBar", nil, self)
            self.name = self.statusBar:CreateFontString(nil, "OVERLAY")
            self.timerText = self.statusBar:CreateFontString(nil, "OVERLAY")
            self.runningTip = self.statusBar:CreateFontString(nil, "OVERLAY")

            reskinStatusBar(self.statusBar)

            self.statusBar.spark = self.statusBar:CreateTexture(nil, "ARTWORK", nil, 1)
            self.statusBar.spark:SetTexture("Interface/CastingBar/UI-CastingBar-Spark")
            self.statusBar.spark:SetBlendMode("ADD")
            self.statusBar.spark:SetPoint("CENTER", self.statusBar:GetStatusBarTexture(), "RIGHT", 0, 0)
            self.statusBar.spark:SetSize(4, 26)
        end,
        setup = function(self)
            self.icon:SetTexture(self.args.icon)
            self.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            self.icon:SetSize(22, 22)
            self.icon:ClearAllPoints()
            self.icon:SetPoint("LEFT", self, "LEFT", 0, 0)

            self.statusBar:ClearAllPoints()
            self.statusBar:SetPoint("TOPLEFT", self, "LEFT", 26, 2)
            self.statusBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 6)

            self.timerText:SetFont(UNIT_NAME_FONT, 13, "OUTLINE")
            self.timerText:ClearAllPoints()
            self.timerText:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -6)

            self.name:SetFont(UNIT_NAME_FONT, 13, "OUTLINE")
            self.name:ClearAllPoints()
            self.name:SetPoint("TOPLEFT", self, "TOPLEFT", 30, -6)
            self.name:SetText(self.args.label)

            self.runningTip:SetFont(UNIT_NAME_FONT, 10, "OUTLINE")
            self.runningTip:SetText(self.args.runningText)
            self.runningTip:SetPoint("CENTER", self.statusBar, "BOTTOM", 0, 0)
        end,
        ticker = {
            interval = 0.3,
            dateUpdater = function(self)
                self.isCompleted = C_QuestLog.IsQuestFlaggedCompleted(self.args.questID)

                local timeSinceStart = GetServerTime() - self.args.startTimestamp
                self.timeOver = timeSinceStart % self.args.interval
                self.nextEventIndex = floor(timeSinceStart / self.args.interval) + 1
                self.nextEventTimestamp = self.args.startTimestamp + self.args.interval * self.nextEventIndex

                if self.timeOver < self.args.duration then
                    self.timeLeft = self.args.duration - self.timeOver
                    self.isRunning = true
                else
                    self.timeLeft = self.args.interval - self.timeOver
                    self.isRunning = false
                end
            end,
            uiUpdater = function(self)
                self.icon:SetDesaturated(self.args.desaturate and self.isCompleted)

                if self.isRunning then
                    -- event ending tracking timer
                    self.timerText:SetText(StringByTemplate(secondToTime(self.timeLeft), "success"))
                    self.statusBar:SetMinMaxValues(0, self.args.duration)
                    self.statusBar:SetValue(self.timeOver)
                    local tex = self.statusBar:GetStatusBarTexture()
                    tex:SetGradient("HORIZONTAL", CreateColorFromTable(colorPlatte.running[1]), CreateColorFromTable(colorPlatte.running[2]))
                    self.runningTip:Show()
                    GW.FrameFlash(self.runningTip, 1, 0.3, 1, true)
                else
                    -- normal tracking timer
                    self.timerText:SetText(secondToTime(self.timeLeft))
                    self.statusBar:SetMinMaxValues(0, self.args.interval)
                    self.statusBar:SetValue(self.timeLeft)

                    if type(self.args.barColor[1]) == "number" then
                        self.statusBar:SetStatusBarColor(unpack(self.args.barColor))
                    else
                        local tex = self.statusBar:GetStatusBarTexture()
                        tex:SetGradient("HORIZONTAL", CreateColorFromTable(self.args.barColor[1]), CreateColorFromTable(self.args.barColor[2]))
                    end

                    GW.StopFlash(self.runningTip)
                    self.runningTip:Hide()
                end
            end,
            alert = function(self)
                if not self.args["alertCache"] then
                    self.args["alertCache"] = {}
                end

                if self.args["alertCache"][self.nextEventIndex] then
                    return
                end

                if not self.args.alertSecond or self.isRunning then
                    return
                end

                if self.args.stopAlertIfCompleted and self.isCompleted then
                    return
                end

                if self.timeLeft < self.args.alertSecond then
                    DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. format(L["%s will start in %s!"], self.args.eventName, secondToTime(self.timeLeft))):gsub("*", GW.Gw2Color))
                    self.args["alertCache"][self.nextEventIndex] = true
                end
            end
        },
        tooltip = {
            onEnter = function(self)
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 8)
                GameTooltip:SetText(GW.GetIconString(self.args.icon, 16, 16) .. " " .. self.args.eventName, 1, 1, 1)

                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine(LOCATION_COLON, self.args.location, 1, 1, 1)

                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine(L["Interval"] .. ":", secondToTime(self.args.interval), 1, 1, 1)
                GameTooltip:AddDoubleLine(AUCTION_DURATION .. ":", secondToTime(self.args.duration), 1, 1, 1)
                if self.nextEventTimestamp then
                    GameTooltip:AddDoubleLine(L["Next Event"] .. ":", date(L["TimeStamp m/d h:m:s"], self.nextEventTimestamp), 1, 1, 1)
                end

                GameTooltip:AddLine(" ")
                if self.isRunning then
                    GameTooltip:AddDoubleLine(STATUS .. ":", StringByTemplate(self.args.runningText, "success"), 1, 1, 1)
                else
                    GameTooltip:AddDoubleLine(STATUS .. ":", StringByTemplate(QUEUED_STATUS_WAITING, "greyLight"), 1, 1, 1)
                end

                if self.isCompleted then
                    GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD .. ":", StringByTemplate(CRITERIA_COMPLETED, "success"), 1, 1, 1)
                else
                    GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD .. ":", StringByTemplate(CRITERIA_NOT_COMPLETED, "danger"), 1, 1, 1)
                end

                GameTooltip:Show()
            end,
            onLeave = function()
                GameTooltip:Hide()
            end
        },
    },
}

local eventData = {
    CommunityFeast = {
        dbKey = "WORLD_EVENTS_COMMUNITY_FEAST_",
        args = {
            icon = 4687629,
            type = "loopTimer",
            questID = 70893,
            duration = 15 * 60,
            interval = 3.5 * 60 * 60,
            barColor = colorPlatte.blue,
            eventName = L["Community Feast"],
            location = C_Map.GetMapInfo(2024).name,
            label = L["Feast"],
            runningText = L["Cooking"],
            startTimestamp = (function()
                local timestampTable = {
                    [1] = 1670776200, -- NA
                    [2] = 1670770800, -- KR
                    [3] = 1670774400, -- EU
                    [4] = 1670779800, -- TW
                    [5] = 1670779800 -- CN
                }
                local region = GetCurrentRegion()
                -- TW is not a real region, so we need to check the client language if player in KR
                if region == 2 and GetLocale() ~= "koKR" then
                    region = 4
                end

                return timestampTable[region]
            end)()
        }
    },
    SiegeOnDragonbaneKeep = {
        dbKey = "WORLD_EVENTS_DRAGONBANE_KEEP_",
        args = {
            icon = 236469,
            type = "loopTimer",
            questID = 70866,
            duration = 15 * 60,
            interval = 2 * 60 * 60,
            eventName = L["Siege On Dragonbane Keep"],
            label = L["Dragonbane Keep"],
            location = C_Map.GetMapInfo(2022).name,
            barColor = colorPlatte.red,
            runningText = IN_PROGRESS,
            startTimestamp = (function()
                local timestampTable = {
                    [1] = 1670774400, -- NA
                    [2] = 1670770800, -- KR
                    [3] = 1670774400, -- EU
                    [4] = 1670770800, -- TW
                    [5] = 1670770800 -- CN
                }
                local region = GetCurrentRegion()
                -- TW is not a real region, so we need to check the client language if player in KR
                if region == 2 and GetLocale() ~= "koKR" then
                    region = 4
                end

                return timestampTable[region]
            end)()
        }
    }
}

local trackers = {
    pool = {}
}

function trackers:get(event)
    if self.pool[event] then
        self.pool[event]:Show()
        return self.pool[event]
    end

    local data = eventData[event]

    local frame = CreateFrame("Frame", "GW2_EventTracker" .. event, mapFrame)
    frame:SetSize(220, 30)

    frame.args = data.args

    if functionFactory[data.args.type] then
        local functions = functionFactory[data.args.type]
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
            frame.tickerInstance = C_Timer.NewTicker(functions.ticker.interval, function()
                if not GW.GetSetting("WORLD_EVENTS_COMMUNITY_FEAST_ENABLED") and not GW.GetSetting("WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED") then
                    return
                end
                functions.ticker.dateUpdater(frame)
                functions.ticker.alert(frame)
                if WorldMapFrame:IsShown() and frame:IsShown() then
                    functions.ticker.uiUpdater(frame)
                end
            end)
        end

        if functions.tooltip then
            frame:SetScript("OnEnter", function()
                functions.tooltip.onEnter(frame)
            end)

            frame:SetScript("OnLeave", function()
                functions.tooltip.onLeave()
            end)
        end
    end

    self.pool[event] = frame

    return frame
end

function trackers:disable(event)
    if self.pool[event] then
        self.pool[event]:Hide()
    end
end


local function AddWorldMapFrame()
    if not WorldMapFrame or mapFrame then
        return
    end

    mapFrame = CreateFrame("Frame", "GW2_EventTracker", WorldMapFrame)
    mapFrame:SetFrameStrata("MEDIUM")
    mapFrame:SetPoint("TOPLEFT", WorldMapFrame, "BOTTOMLEFT", 0, -1)
    mapFrame:SetPoint("TOPRIGHT", WorldMapFrame, "BOTTOMRIGHT", 0, -1)
    mapFrame:SetHeight(30)
    mapFrame:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
end

local function UpdateTrackers()
    local lastTracker = nil
    for _, event in ipairs(eventList) do
        local data = eventData[event]
        local tracker = GW.GetSetting(data.dbKey .. "ENABLED") and trackers:get(event) or trackers:disable(event)
        if tracker then
            if tracker.profileUpdate then
                tracker.profileUpdate()
            end

            tracker.args.desaturate = GW.GetSetting(data.dbKey .."DESATURATE")

            if GW.GetSetting(data.dbKey .. "ALERT") then
                tracker.args.alert = true
                tracker.args.alertSecond = GW.GetSetting(data.dbKey .. "ALERT_SECONDS")
                tracker.args.stopAlertIfCompleted = GW.GetSetting(data.dbKey .. "STOP_ALERT_IF_COMPLETED")
            else
                tracker.args.alertSecond = nil
                tracker.args.stopAlertIfCompleted = nil
            end

            tracker:ClearAllPoints()
            if lastTracker then
                tracker:SetPoint("LEFT", lastTracker, "RIGHT", 5, 0)
            else
                tracker:SetPoint("LEFT", mapFrame, "LEFT", 5 * 0.68, 0)
            end
            lastTracker = tracker
        end
    end

    mapFrame:SetShown(GW.GetSetting("WORLD_EVENTS_COMMUNITY_FEAST_ENABLED") or GW.GetSetting("WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"))
end
GW.UpdateWorldEventTrackers = UpdateTrackers

local function LoadDragonFlightWorldEvents()
    AddWorldMapFrame()

    UpdateTrackers()
end
GW.LoadDragonFlightWorldEvents = LoadDragonFlightWorldEvents