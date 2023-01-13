local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting

--[[
    Credits: fang2hou -> ElvUI_Windtools
]]--

local settings = {
    communityFeast = {},
    dragonbaneKeep = {},
    iskaaranFishingNet = {
        playerData = {}
    }
}

local function UpdateSettings()
    settings.communityFeast = {
        enabled = GetSetting("WORLD_EVENTS_COMMUNITY_FEAST_ENABLED"),
        desaturate = GetSetting("WORLD_EVENTS_COMMUNITY_FEAST_DESATURATE"),
        alert = GetSetting("WORLD_EVENTS_COMMUNITY_FEAST_ALERT"),
        alertSeconds = GetSetting("WORLD_EVENTS_COMMUNITY_FEAST_ALERT_SECONDS"),
        stopAlertIfCompleted = GetSetting("WORLD_EVENTS_COMMUNITY_FEAST_STOP_ALERT_IF_COMPLETED"),
        flashTaskbar = GetSetting("WORLD_EVENTS_COMMUNITY_FEAST_FLASH_TASKBAR")
    }

    settings.dragonbaneKeep = {
        enabled = GetSetting("WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED"),
        desaturate = GetSetting("WORLD_EVENTS_DRAGONBANE_KEEP_DESATURATE"),
        alert = GetSetting("WORLD_EVENTS_DRAGONBANE_KEEP_ALERT"),
        alertSeconds = GetSetting("WORLD_EVENTS_DRAGONBANE_KEEP_ALERT_SECONDS"),
        stopAlertIfCompleted = GetSetting("WORLD_EVENTS_DRAGONBANE_KEEP_STOP_ALERT_IF_COMPLETED"),
        flashTaskbar = GetSetting("WORLD_EVENTS_DRAGONBANE_KEEP_FLASH_TASKBAR")
    }

    settings.iskaaranFishingNet = {
        enabled = GetSetting("WORLD_EVENTS_ISKAARAN_FISHING_NET_ENABLED"),
        alert = GetSetting("WORLD_EVENTS_ISKAARAN_FISHING_NET_ALERT"),
        disableAlertAfterHours = GetSetting("WORLD_EVENTS_ISKAARAN_FISHING_NET_DISABLE_ALERT_AFTER_HOURS"),
        flashTaskbar = GetSetting("WORLD_EVENTS_ISKAARAN_FISHING_NET_FLASH_TASKBAR"),
        -- this are player settings no global ones
        playerData = GetSetting("ISKAARAN_FISHING_NET_DATA")
    }
end
GW.UpdateEventTrackerSettings = UpdateSettings

local function UpdateIskaaranFishingNetPlayerData(key, value)
    if not settings.iskaaranFishingNet.playerData[key] then
        settings.iskaaranFishingNet.playerData[key] = {}
    end
    settings.iskaaranFishingNet.playerData[key] = value

    GW.SetSetting("ISKAARAN_FISHING_NET_DATA", settings.iskaaranFishingNet.playerData)
end

local mapFrame
local eventHandlers = {}

local eventList = {
    "CommunityFeast",
    "SiegeOnDragonbaneKeep",
    "IskaaranFishingNet"
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

local env = {
    fishingNetPosition = {
        [1] = {map = 2022, x = 0.63585, y = 0.75349},
        [2] = {map = 2022, x = 0.64514, y = 0.74178},
        [3] = {map = 2025, x = 0.56782, y = 0.65178},
        [4] = {map = 2025, x = 0.57756, y = 0.65491},
        [5] = {map = 2023, x = 0.80522, y = 0.78433},
        [6] = {map = 2023, x = 0.80467, y = 0.77742}
    },
     fishingNetWidgetIDToIndex = {
         -- Waking Shores
         [4203] = 1,
         [4317] = 2
     }
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
    purple = {
        {r = 0.27843, g = 0.46275, b = 0.90196, a = 1},
        {r = 0.55686, g = 0.32941, b = 0.91373, a = 1}
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

local function getGradientText(text, colorTable)
    if not text or not colorTable then
        return text
    end
    return GW.TextGradient(
        text,
        colorTable[1].r,
        colorTable[1].g,
        colorTable[1].b,
        colorTable[2].r,
        colorTable[2].g,
        colorTable[2].b
    )
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

                if self.args.filter and not self.args:filter() then
                    return
                end

                if self.timeLeft <= self.args.alertSecond then
                    self.args["alertCache"][self.nextEventIndex] = true
                    local eventIconString = GW.GetIconString(self.args.icon, 16, 16)
                    local gradientName = getGradientText(self.args.eventName, self.args.barColor)
                    DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. format(L["%s will start in %s!"], eventIconString .. " " .. gradientName, secondToTime(self.timeLeft))):gsub("*", GW.Gw2Color))
                    if self.args.flashTaskbar then
                        FlashClientIcon()
                    end
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
    triggerTimer = {
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

            self.runningTip:SetFont(UNIT_NAME_FONT, 13, "OUTLINE")
            self.runningTip:SetText(self.args.runningText)
            self.runningTip:SetPoint("CENTER", self.statusBar, "BOTTOM", 0, 0)
        end,
        ticker = {
            interval = 0.3,
            dateUpdater = function(self)
                if not C_QuestLog.IsQuestFlaggedCompleted(70871) then
                    self.netTable = nil
                    return
                end

                local db = settings.iskaaranFishingNet.playerData
                if not db then
                    return
                end

                self.netTable = {}
                local now = GetServerTime()
                for netIndex = 1, #env.fishingNetPosition do
                    -- update db from old version
                    if type(db[netIndex]) ~= "table" then
                        db[netIndex] = nil
                    end
                    if not db[netIndex] or db[netIndex] == 0 then
                        self.netTable[netIndex] = "NOT_STARTED"
                    else
                        self.netTable[netIndex] = {
                            left = db[netIndex].time - now,
                            duration = db[netIndex].duration
                        }
                    end
                end
            end,
            uiUpdater = function(self)
                local done = {}
                local notStarted = {}
                local waiting = {}

                if self.netTable then
                    for netIndex, timeData in pairs(self.netTable) do
                        if type(timeData) == "string" then
                            if timeData == "NOT_STARTED" then
                                tinsert(notStarted, netIndex)
                            end
                        elseif type(timeData) == "table" then
                            if timeData <= 0 then
                                tinsert(done, netIndex)
                            else
                                tinsert(waiting, netIndex)
                            end
                        end
                    end
                end

                local tip = ""

                if #done == #env.fishingNetPosition then
                    tip = StringByTemplate(L["All nets can be collected"], "success")
                    self.timerText:SetText("")

                    self.statusBar:GetStatusBarTexture():SetGradient("HORIZONTAL", CreateColorFromTable(colorPlatte.running[1]), CreateColorFromTable(colorPlatte.running[2]))
                    self.statusBar:SetMinMaxValues(0, 1)
                    self.statusBar:SetValue(1)

                    GW.FrameFlash(self.runningTip, 1, 0.3, 1, true)
                elseif #waiting > 0 then
                    if #done > 0 then
                        local netsText = ""
                        for i = 1, #done do
                            netsText = netsText .. "#" .. done[i]
                            if i ~= #done then
                                netsText = netsText .. ", "
                            end
                        end
                        tip = StringByTemplate(format(L["Net %s can be collected"], netsText), "success")
                    else
                        tip = QUEUED_STATUS_WAITING
                    end

                    local maxTimeIndex
                    for _, index in pairs(waiting) do
                        if not maxTimeIndex or self.netTable[index].left > self.netTable[maxTimeIndex].left then
                            maxTimeIndex = index
                        end
                    end

                    if type(self.args.barColor[1]) == "number" then
                        self.statusBar:SetStatusBarColor(unpack(self.args.barColor))
                    else
                        self.statusBar:GetStatusBarTexture():SetGradient("HORIZONTAL", CreateColorFromTable(self.args.barColor[1]), CreateColorFromTable(self.args.barColor[2]))
                    end

                    self.timerText:SetText(secondToTime(self.netTable[maxTimeIndex].left))
                    self.statusBar:SetMinMaxValues(0, self.netTable[maxTimeIndex].duration)
                    self.statusBar:SetValue(self.netTable[maxTimeIndex].left)

                    GW.StopFlash(self.runningTip)
                else
                    self.timerText:SetText("")
                    self.statusBar:GetStatusBarTexture():SetGradient("HORIZONTAL", CreateColorFromTable(colorPlatte.running[1]), CreateColorFromTable(colorPlatte.running[2]))
                    self.statusBar:SetMinMaxValues(0, 1)

                    if #done > 0 then
                        local netsText = ""
                        for i = 1, #done do
                            netsText = netsText .. "#" .. done[i]
                            if i ~= #done then
                                netsText = netsText .. ", "
                            end
                        end
                        tip = StringByTemplate(format(L["Net %s can be collected"], netsText), "success")
                        self.statusBar:SetValue(1)
                    else
                        tip = StringByTemplate(L["No Nets Set"], "danger")
                        self.statusBar:SetValue(0)
                    end

                    GW.StopFlash(self.runningTip)
                end

                self.runningTip:SetText(tip)
            end,
            alert = function(self)
                if not self.netTable then
                    return
                end

                local db = settings.iskaaranFishingNet.playerData
                if not db then
                    return
                end

                if not self.args["alertCache"] then
                    self.args["alertCache"] = {}
                end

                local needAnnounce = false
                local readyNets = {}

                for netIndex, timeData in pairs(self.netTable) do
                    if type(timeData) == "table" and timeData.left <= 0 then
                        if not self.args["alertCache"][netIndex] then
                            self.args["alertCache"][netIndex] = {}
                        end

                        if not self.args["alertCache"][netIndex][db[netIndex].time] then
                            self.args["alertCache"][netIndex][db[netIndex].time] = true
                            local hour = self.args.disableAlertAfterHours
                            if not hour or hour == 0 or (hour * 60 * 60 + timeData.left) > 0 then
                                tinsert(readyNets, netIndex)
                                needAnnounce = true
                            end
                        end
                    end
                end

                if needAnnounce then
                    local netsText = ""
                    for i = 1, #readyNets do
                        netsText = netsText .. "#" .. readyNets[i]
                        if i ~= #readyNets then
                            netsText = netsText .. ", "
                        end
                    end

                    local eventIconString = GW.GetIconString(self.args.icon, 16, 16)
                    local gradientName = getGradientText(self.args.eventName, self.args.barColor)
                    DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. format(eventIconString .. " " .. gradientName .. " " .. L["Net %s can be collected"], netsText)):gsub("*", GW.Gw2Color))
                    if self.args.flashTaskbar then
                        FlashClientIcon()
                    end
                end
            end
        },
        tooltip = {
            onEnter = function(self)
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 8)
                GameTooltip:SetText(GW.GetIconString(self.args.icon, 16, 16) .. " " .. self.args.eventName, 1, 1, 1)
                GameTooltip:AddLine(" ")

                if not self.netTable or #self.netTable == 0 then
                    GameTooltip:AddLine(StringByTemplate(L["No Nets Set"], "danger"))
                    GameTooltip:Show()
                    return
                end
                GameTooltip:AddLine(L["Fishing Nets"])

                for netIndex, timeData in pairs(self.netTable) do
                    local text
                    if type(timeData) == "table" then
                        if timeData.left <= 0 then
                            text = StringByTemplate(L["Can be collected"], "success")
                        else
                            text = StringByTemplate(secondToTime(timeData.left), "info")
                        end
                    else
                        if timeData == "NOT_STARTED" then --TODO
                            text = StringByTemplate(L["Can be set"], "warning")
                        end
                    end

                    GameTooltip:AddDoubleLine(format(L["Net #%d"], netIndex), text, 1, 1, 1, 1, 1, 1)
                end

                GameTooltip:Show()
            end,
            onLeave = function()
                GameTooltip:Hide()
            end
        }
    }
}

local eventData = {
    CommunityFeast = {
        dbKey = "communityFeast",
        args = {
            icon = 4687629,
            type = "loopTimer",
            questID = 70893,
            duration = 16 * 60,
            interval = 3.5 * 60 * 60,
            barColor = colorPlatte.blue,
            eventName = L["Community Feast"],
            location = C_Map.GetMapInfo(2024).name,
            label = L["Feast"],
            runningText = L["Cooking"],
            filter = function()
                if not C_QuestLog.IsQuestFlaggedCompleted(67700) then
                    return false
                end
                return true
            end,
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
                if region == 2 and GW.mylocal ~= "koKR" then
                    region = 4
                end

                return timestampTable[region]
            end)()
        }
    },
    SiegeOnDragonbaneKeep = {
        dbKey = "dragonbaneKeep",
        args = {
            icon = 236469,
            type = "loopTimer",
            questID = 70866,
            duration = 10 * 60,
            interval = 2 * 60 * 60,
            eventName = L["Siege On Dragonbane Keep"],
            label = L["Dragonbane Keep"],
            location = C_Map.GetMapInfo(2022).name,
            barColor = colorPlatte.red,
            runningText = IN_PROGRESS,
            filter = function()
                if not C_QuestLog.IsQuestFlaggedCompleted(67700) then
                    return false
                end
                return true
            end,
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
                if region == 2 and GW.mylocal ~= "koKR" then
                    region = 4
                end

                return timestampTable[region]
            end)()
        }
    },
    IskaaranFishingNet = {
        dbKey = "iskaaranFishingNet",
        args = {
            icon = 2159815,
            type = "triggerTimer",
            filter = function()
                return C_QuestLog.IsQuestFlaggedCompleted(70871)
            end,
            barColor = colorPlatte.purple,
            eventName = L["Iskaaran Fishing Net"],
            label = L["Fishing Net"],
            events = {
                {
                    "UNIT_SPELLCAST_SUCCEEDED",
                    function(unit, _, spellID)
                        if not unit or unit ~= "player" then
                            return
                        end

                        if not GW.Libs.GW2Lib:GetPlayerLocationMapID() or (spellID ~= 377887 and spellID ~= 377883) then
                            return
                        end

                        local lengthMap = {}
                        local position = C_Map.GetPlayerMapPosition(GW.Libs.GW2Lib:GetPlayerLocationMapID(), "player")
                        if not position then return end

                        for i, netPos in ipairs(env.fishingNetPosition) do
                            if GW.Libs.GW2Lib:GetPlayerLocationMapID() == netPos.map then
                                local length = math.pow(position.x - netPos.x, 2) + math.pow(position.y - netPos.y, 2)
                                lengthMap[i] = length
                            end
                        end

                        local min
                        local netIndex = 0
                        for i, length in pairs(lengthMap) do
                            if not min or length < min then
                                min = length
                                netIndex = i
                            end
                        end

                        if not min or netIndex <= 0 then
                            return
                        end

                        local db = settings.iskaaranFishingNet.playerData

                        if spellID == 377887 then -- Get Fish
                            if db[netIndex] then
                                db[netIndex] = nil
                            end
                        elseif spellID == 377883 then -- Set Net
                            C_Timer.After(0.5, function()
                                local namePlates = C_NamePlate.GetNamePlates(true)
                                if #namePlates > 0 then
                                    for _, namePlate in ipairs(namePlates) do
                                        if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.WidgetContainer then
                                            local container = namePlate.UnitFrame.WidgetContainer
                                            if container.timerWidgets then
                                                for id, widget in pairs(container.timerWidgets) do
                                                    if
                                                        env.fishingNetWidgetIDToIndex[id] and
                                                            env.fishingNetWidgetIDToIndex[id] == netIndex
                                                    then
                                                        if widget.Bar and widget.Bar.value and widget.Bar.range then
                                                            UpdateIskaaranFishingNetPlayerData(netIndex, {time = GetServerTime() + widget.Bar.value, duration = widget.Bar.range})
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end)
                        end
                    end
                }
            }
        }
    }
}

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
    end

    tinsert(eventHandlers[event], handler)
end

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
    frame.dbKey = data.dbKey

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
                if not settings.communityFeast.enabled and not settings.dragonbaneKeep.enabled and not settings.iskaaranFishingNet.enabled then
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

    if data.args.events then
        for _, eventToAdd in ipairs(data.args.events) do
            AddEventHandler(eventToAdd[1], eventToAdd[2])
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
    mapFrame:SetPoint("TOPLEFT", WorldMapFrame, "BOTTOMLEFT", 0, 2)
    mapFrame:SetPoint("TOPRIGHT", WorldMapFrame, "BOTTOMRIGHT", 0, 2)
    mapFrame:SetHeight(30)
    mapFrame:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder)

    mapFrame:SetScript("OnEvent", HandlerEvent)
end

local function UpdateTrackers()
    UpdateSettings()

    local lastTracker = nil
    for _, event in ipairs(eventList) do
        local data = eventData[event]
        local tracker = settings[data.dbKey].enabled and trackers:get(event) or trackers:disable(event)
        if tracker then
            if tracker.profileUpdate then
                tracker.profileUpdate()
            end

            tracker.args.desaturate = settings[data.dbKey].desaturate
            tracker.args.flshTaskbar = settings[data.dbKey].flashTaskbar

            if settings[data.dbKey].alert then
                tracker.args.alert = true
                tracker.args.alertSecond = settings[data.dbKey].alertSeconds
                tracker.args.stopAlertIfCompleted = settings[data.dbKey].stopAlertIfCompleted
                tracker.args.disableAlertAfterHours = settings[data.dbKey].disableAlertAfterHours
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

    mapFrame:SetShown(settings.communityFeast.enabled or settings.dragonbaneKeep.enable or settings.iskaaranFishingNet.enabled)
end
GW.UpdateWorldEventTrackers = UpdateTrackers

local function LoadDragonFlightWorldEvents()
    AddWorldMapFrame()

    UpdateTrackers()

    for event in pairs(eventHandlers) do
        mapFrame:RegisterEvent(event)
    end
end
GW.LoadDragonFlightWorldEvents = LoadDragonFlightWorldEvents