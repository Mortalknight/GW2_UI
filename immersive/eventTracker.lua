local _, GW = ...
local L = GW.L

--[[
    Credits: fang2hou -> ElvUI_Windtools
]]--

local settings = {
    iskaaranFishingNet = {
        playerData = {}
    }
}

local function UpdateSettings()
    settings.communityFeast = {
        enabled = GW.settings.WORLD_EVENTS_COMMUNITY_FEAST_ENABLED,
        desaturate = GW.settings.WORLD_EVENTS_COMMUNITY_FEAST_DESATURATE,
        alert = GW.settings.WORLD_EVENTS_COMMUNITY_FEAST_ALERT,
        alertSeconds = GW.settings.WORLD_EVENTS_COMMUNITY_FEAST_ALERT_SECONDS,
        stopAlertIfCompleted = GW.settings.WORLD_EVENTS_COMMUNITY_FEAST_STOP_ALERT_IF_COMPLETED,
        flashTaskbar = GW.settings.WORLD_EVENTS_COMMUNITY_FEAST_FLASH_TASKBAR
    }

    settings.dragonbaneKeep = {
        enabled = GW.settings.WORLD_EVENTS_DRAGONBANE_KEEP_ENABLED,
        desaturate = GW.settings.WORLD_EVENTS_DRAGONBANE_KEEP_DESATURATE,
        alert = GW.settings.WORLD_EVENTS_DRAGONBANE_KEEP_ALERT,
        alertSeconds = GW.settings.WORLD_EVENTS_DRAGONBANE_KEEP_ALERT_SECONDS,
        stopAlertIfCompleted = GW.settings.WORLD_EVENTS_DRAGONBANE_KEEP_STOP_ALERT_IF_COMPLETED,
        flashTaskbar = GW.settings.WORLD_EVENTS_DRAGONBANE_KEEP_FLASH_TASKBAR
    }

    settings.researchersUnderFire = {
        enabled = GW.settings.WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ENABLED,
        desaturate = GW.settings.WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_DESATURATE,
        alert = GW.settings.WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT,
        alertSeconds = GW.settings.WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_ALERT_SECONDS,
        stopAlertIfCompleted = GW.settings.WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_STOP_ALERT_IF_COMPLETED,
        flashTaskbar = GW.settings.WORLD_EVENTS_RESEARCHERS_UNDER_FIRE_FLASH_TASKBAR
    }

    settings.timeRiftThaldraszus = {
        enabled = GW.settings.WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ENABLED,
        desaturate = GW.settings.WORLD_EVENTS_TIME_RIFT_THALDRASZUS_DESATURATE,
        alert = GW.settings.WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT,
        alertSeconds = GW.settings.WORLD_EVENTS_TIME_RIFT_THALDRASZUS_ALERT_SECONDS,
        stopAlertIfCompleted = GW.settings.WORLD_EVENTS_TIME_RIFT_THALDRASZUS_STOP_ALERT_IF_COMPLETED,
        flashTaskbar = GW.settings.WORLD_EVENTS_TIME_RIFT_THALDRASZUS_FLASH_TASKBAR
    }

    settings.superBloom = {
        enabled = GW.settings.WORLD_EVENTS_SUPER_BLOOM_ENABLED,
        desaturate = GW.settings.WORLD_EVENTS_SUPER_BLOOM_DESATURATE,
        alert = GW.settings.WORLD_EVENTS_SUPER_BLOOM_ALERT,
        alertSeconds = GW.settings.WORLD_EVENTS_SUPER_BLOOM_ALERT_SECONDS,
        stopAlertIfCompleted = GW.settings.WORLD_EVENTS_SUPER_BLOOM_STOP_ALERT_IF_COMPLETED,
        flashTaskbar = GW.settings.WORLD_EVENTS_SUPER_BLOOM_FLASH_TASKBAR
    }

    settings.bigDig = {
        enabled = GW.settings.WORLD_EVENTS_BIG_DIG_ENABLED,
        desaturate = GW.settings.WORLD_EVENTS_BIG_DIG_DESATURATE,
        alert = GW.settings.WORLD_EVENTS_BIG_DIG_ALERT,
        alertSeconds = GW.settings.WORLD_EVENTS_BIG_DIG_ALERT_SECONDS,
        stopAlertIfCompleted = GW.settings.WORLD_EVENTS_BIG_DIG_STOP_ALERT_IF_COMPLETED,
        flashTaskbar = GW.settings.WORLD_EVENTS_BIG_DIG_FLASH_TASKBAR
    }

    settings.iskaaranFishingNet = {
        enabled = GW.settings.WORLD_EVENTS_ISKAARAN_FISHING_NET_ENABLED,
        alert = GW.settings.WORLD_EVENTS_ISKAARAN_FISHING_NET_ALERT,
        disableAlertAfterHours = GW.settings.WORLD_EVENTS_ISKAARAN_FISHING_NET_DISABLE_ALERT_AFTER_HOURS,
        flashTaskbar = GW.settings.WORLD_EVENTS_ISKAARAN_FISHING_NET_FLASH_TASKBAR,
        -- this are player settings no global ones
        playerData = GW.private.ISKAARAN_FISHING_NET_DATA
    }
end
GW.UpdateEventTrackerSettings = UpdateSettings

local function UpdateIskaaranFishingNetPlayerData(key, value)
    if not settings.iskaaranFishingNet.playerData[key] then
        settings.iskaaranFishingNet.playerData[key] = {}
    end
    settings.iskaaranFishingNet.playerData[key] = value

    GW.private.ISKAARAN_FISHING_NET_DATA = settings.iskaaranFishingNet.playerData
end

local mapFrame
local eventHandlers = {}

local eventList = {
    "CommunityFeast",
    "SiegeOnDragonbaneKeep",
    "ResearchersUnderFire",
    "TimeRiftThaldraszus",
    "SuperBloom",
    "BigDig",
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
        -- Waking Shores
        [1] = {map = 2022, x = 0.63585, y = 0.75349},
        [2] = {map = 2022, x = 0.64514, y = 0.74178},
        -- Lava
        [3] = {map = 2022, x = 0.33722, y = 0.65047},
        [4] = {map = 2022, x = 0.34376, y = 0.64763},
        -- Thaldraszus
        [5] = {map = 2025, x = 0.56782, y = 0.65178},
        [6] = {map = 2025, x = 0.57756, y = 0.65491},
        -- Ohn'ahran Plains
        [7] = {map = 2023, x = 0.80522, y = 0.78433},
        [8] = {map = 2023, x = 0.80467, y = 0.77742},
        -- 10.0.7
        [9] = {map = 2151, x = 0.73951, y = 0.41047},
    },
    fishingNetWidgetIDToIndex = {
        -- data mining: https://wow.tools/dbc/?dbc=uiwidget&build=10.0.5.47621#page=1&colFilter[3]=exact%3A2087
        -- Waking Shores
        [4203] = 1,
        [4317] = 2,
        -- Thaldraszus
        [4388] = 5,
        [4398] = 6,
        --10.0.7
        [4615] = 9,
        --[4318] = 5,
        --[4364] = 5,
        --[4365] = 5,
        --[4389] = 5,
        --[4397] = 5,
        --[4399] = 5,
        --[4400] = 5,
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
    green = {
        {r = 0.40392, g = 0.92549, b = 0.54902, a = 1},
        {r = 0.00000, g = 0.98824, b = 0.40392, a = 1}
    },
    purple = {
        {r = 0.27843, g = 0.46275, b = 0.90196, a = 1},
        {r = 0.55686, g = 0.32941, b = 0.91373, a = 1}
    },
    bronze = {
        {r = 0.83000, g = 0.42000, b = 0.10000, a = 1},
        {r = 0.56500, g = 0.40800, b = 0.16900, a = 1}
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
    bar:GwStripTextures()
    bar:GwCreateBackdrop(GW.BackdropTemplates.StatusBar, true)
    bar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/hud/castinbar-white")
    bar.backdrop:GwSetOutside(bar, 4, 4)
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

local eventData = {
    CommunityFeast = {
        dbKey = "communityFeast",
        args = {
            icon = 4687629,
            type = "loopTimer",
            questIDs = {70893},
            hasWeeklyReward = true,
            duration = 16 * 60,
            interval = 1.5 * 60 * 60,
            barColor = colorPlatte.blue,
            eventName = L["Community Feast"],
            location = C_Map.GetMapInfo(2024).name,
            label = L["Feast"],
            runningText = L["Cooking"],
            frame = nil,
            filter = function()
                if not C_QuestLog.IsQuestFlaggedCompleted(67700) then
                    return false
                end
                return true
            end,
            startTimestamp = (function()
                local timestampTable = {
                    [1] = 1675765800, -- NA
                    [2] = 1675767600, -- KR
                    [3] = 1676017800, -- EU
                    [4] = 1675767600, -- TW
                    [5] = 1675767600, -- CN
                    [72] = 1675767600
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
            questIDs = {70866},
            hasWeeklyReward = true,
            duration = 10 * 60,
            interval = 2 * 60 * 60,
            eventName = L["Siege On Dragonbane Keep"],
            label = L["Dragonbane Keep"],
            location = C_Map.GetMapInfo(2022).name,
            barColor = colorPlatte.red,
            runningText = IN_PROGRESS,
            frame = nil,
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
                    [5] = 1670770800, -- CN
                    [72] = 1675767600
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
    ResearchersUnderFire = {
        dbKey = "researchersUnderFire",
        args = {
            icon = 5140835,
            type = "loopTimer",
            questIDs = {75627, 75628, 75629, 75630},
            hasWeeklyReward = true,
            duration = 25 * 60,
            interval = 1 * 60 * 60,
            eventName = L["Researchers"],
            label = L["Researchers"],
            location = C_Map.GetMapInfo(2133).name,
            barColor = colorPlatte.green,
            runningText = IN_PROGRESS,
            filter = function()
                if not C_QuestLog.IsQuestFlaggedCompleted(67700) then
                    return false
                end
                return true
            end,
            startTimestamp = (function()
                local timestampTable = {
                    [1] = 1670333460, -- NA
                    [2] = 1702240245, -- KR
                    [3] = 1683804640, -- EU
                    [4] = 1670704240, -- TW
                    [5] = 1670702460, -- CN
                    [72] = 1670702460 -- TR
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
    TimeRiftThaldraszus = {
        dbKey = "timeRiftThaldraszus",
        args = {
            icon = 237538,
            type = "loopTimer",
            --questIDs = {0},
            hasWeeklyReward = false,
            duration = 15 * 60,
            interval = 1 * 60 * 60,
            eventName = L["Time Rift"],
            label = L["Time Rift"],
            location = C_Map.GetMapInfo(2025).name,
            barColor = colorPlatte.bronze,
            runningText = IN_PROGRESS,
            filter = function()
                if not C_QuestLog.IsQuestFlaggedCompleted(67700) then
                    return false
                end
                return true
            end,
            startTimestamp = (function()
                local timestampTable = {
                    [1] = 1701831615, -- NA
                    [2] = 1701853215, -- KR
                    [3] = 1701828015, -- EU
                    [4] = 1701824400, -- TW
                    [5] = 1701824400, -- CN
                    [72] = 1701852315 -- TR
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
    SuperBloom = {
        dbKey = "superBloom",
        args = {
            icon = 3939983,
            type = "loopTimer",
            questIDs = {78319},
            hasWeeklyReward = true,
            duration = 15 * 16,
            interval = 1 * 60 * 60,
            eventName = L["Superbloom"],
            label = L["Superbloom"],
            location = C_Map.GetMapInfo(2200).name,
            barColor = colorPlatte.green,
            runningText = IN_PROGRESS,
            filter = function()
                if not C_QuestLog.IsQuestFlaggedCompleted(67700) then
                    return false
                end
                return true
            end,
            startTimestamp = (function()
                local timestampTable = {
                    [1] = 1701828010, -- NA
                    [2] = 1701828010, -- KR
                    [3] = 1701828010, -- EU
                    [4] = 1701828010, -- TW
                    [5] = 1701828010, -- CN
                    [72] = 1701828010 -- TR
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
    BigDig = {
        dbKey = "bigDig",
        args = {
            icon = 4549135,
            type = "loopTimer",
            questIDs = {79226},
            hasWeeklyReward = true,
            duration = 15 * 60,
            interval = 1 * 60 * 60,
            eventName = L["Big Dig"],
            label = L["Big Dig"],
            location = C_Map.GetMapInfo(2024).name,
            barColor = colorPlatte.purple,
            runningText = IN_PROGRESS,
            filter = function()
                if not C_QuestLog.IsQuestFlaggedCompleted(67700) then
                    return false
                end
                return true
            end,
            startTimestamp = (function()
                local timestampTable = {
                    -- need more accurate Timers
                    [1] = 1701826200, -- NA
                    [2] = 1701826200, -- KR
                    [3] = 1701826200, -- EU
                    [4] = 1701826200, -- TW
                    [5] = 1701826200, -- CN
                    [72] = 1701826200 -- TR
                }
                local region = GetCurrentRegion()
                -- TW is not a real region, so we need to check the client language if player in KR
                if region == 2 and GW.Locale ~= "koKR" then
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
            frame = nil,
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
                        local x, y = GW2_ADDON.Libs.GW2Lib:GetPlayerLocationCoords()
                        if not x or not y then return end

                        for i, netPos in ipairs(env.fishingNetPosition) do
                            if GW.Libs.GW2Lib:GetPlayerLocationMapID() == netPos.map then
                                local length = math.pow(x - netPos.x, 2) + math.pow(y - netPos.y, 2)
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

local functionFactory = {
    onEnterAll = function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip, self.tooltipText)
        GameTooltip:AddLine(" ")
        for _, event in ipairs(eventList) do
            local data = eventData[event]

            if settings[data.dbKey].enabled then
                if event  == "IskaaranFishingNet" then
                    GameTooltip:AddLine(GW.GetIconString(data.args.icon, 16, 16) .. " " .. data.args.eventName, 1, 1, 1)
                    GameTooltip:AddLine(" ")

                    if not data.netTable or #data.netTable == 0 then
                        GameTooltip:AddLine(StringByTemplate(L["No Nets Set"], "danger"))
                        GameTooltip:Show()
                        return
                    end
                    GameTooltip:AddLine(L["Fishing Nets"])

                    local netIndex1Status  -- Always
                    local netIndex2Status  -- Always
                    local bonusNetStatus  -- Bonus
                    local bonusTimeLeft = 0

                    for netIndex, timeData in pairs(data.frame.netTable) do
                        local text
                        if type(timeData) == "table" then
                            if timeData.left <= 0 then
                                text = StringByTemplate(L["Can be collected"], "success")
                            else
                                text = StringByTemplate(secondToTime(timeData.left), "info")
                            end

                            -- only show latest bonus net
                            if netIndex > 2 and timeData.left > bonusTimeLeft then
                                bonusTimeLeft = timeData.left
                                bonusNetStatus = text
                            end
                        else
                            if timeData == "NOT_STARTED" then
                                text = StringByTemplate(L["Can be set"], "warning")
                            end
                        end

                        if netIndex == 1 then
                            netIndex1Status = text
                        elseif netIndex == 2 then
                            netIndex2Status = text
                        end
                    end

                    GameTooltip:AddDoubleLine(format(L["Net #%d"], 1), netIndex1Status)
                    GameTooltip:AddDoubleLine(format(L["Net #%d"], 2), netIndex2Status)
                    if bonusNetStatus then
                        GameTooltip:AddDoubleLine(L["Bonus Net"], bonusNetStatus)
                    else -- no bonus net
                        GameTooltip:AddDoubleLine(L["Bonus Net"], StringByTemplate(L["Not Set"], "danger"))
                    end
                else
                    GameTooltip:AddLine(GW.GetIconString(data.args.icon, 16, 16) .. " " .. data.args.eventName, 1, 1, 1)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddDoubleLine(LOCATION_COLON, data.args.location, 1, 1, 1)

                    GameTooltip:AddLine(" ")
                    GameTooltip:AddDoubleLine(L["Interval"] .. ":", secondToTime(data.args.interval), 1, 1, 1)
                    GameTooltip:AddDoubleLine(AUCTION_DURATION .. ":", secondToTime(data.args.duration), 1, 1, 1)
                    if data.nextEventTimestamp then
                        GameTooltip:AddDoubleLine(L["Next Event"] .. ":", date(L["TimeStamp m/d h:m:s"], data.nextEventTimestamp), 1, 1, 1)
                    end

                    GameTooltip:AddLine(" ")
                    if data.frame.isRunning then
                        GameTooltip:AddDoubleLine(STATUS .. ":", StringByTemplate(data.args.runningText, "success"), 1, 1, 1)
                    else
                        GameTooltip:AddDoubleLine(STATUS .. ":", StringByTemplate(QUEUED_STATUS_WAITING, "greyLight"), 1, 1, 1)
                    end

                    if data.args.hasWeeklyReward then
                        if data.frame.isCompleted then
                            GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD .. ":", StringByTemplate(CRITERIA_COMPLETED, "success"), 1, 1, 1)
                        else
                            GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD .. ":", StringByTemplate(CRITERIA_NOT_COMPLETED, "danger"), 1, 1, 1)
                        end
                    end
                    GameTooltip:AddLine(" ")
                end
            end
        end

        GameTooltip:Show()
    end,
    loopTimer = {
        init = function(self)
            self.icon = self:CreateTexture(nil, "ARTWORK")
            self.icon:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
            self.icon.backdrop:GwSetOutside(self.icon, 1, 1)
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
            self.statusBar:SetPoint("TOPLEFT", self, "LEFT", 24, 2)
            self.statusBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 6)

            self.timerText:SetFont(UNIT_NAME_FONT, 12, "OUTLINE")
            self.timerText:ClearAllPoints()
            self.timerText:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -6)

            self.name:SetFont(UNIT_NAME_FONT, 12, "OUTLINE")
            self.name:ClearAllPoints()
            self.name:SetPoint("TOPLEFT", self, "TOPLEFT", 25, -6)
            self.name:SetText(self.args.label)
            self.name:SetWidth(125)
            self.name:SetJustifyH("LEFT")

            self.runningTip:SetFont(UNIT_NAME_FONT, 10, "OUTLINE")
            self.runningTip:SetText(self.args.runningText)
            self.runningTip:SetPoint("CENTER", self.statusBar, "BOTTOM", 0, 0)
        end,
        ticker = {
            interval = 0.3,
            dateUpdater = function(self)
                local completed = 0
                if self.args.questIDs then
                    for _, questID in pairs(self.args.questIDs) do
                        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                            completed = completed + 1
                        end
                    end
                end
                self.isCompleted = completed > 0

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
                if not self.args.alertCache then
                    self.args.alertCache = {}
                end

                if self.args.alertCache[self.nextEventIndex] then
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
                    self.args.alertCache[self.nextEventIndex] = true
                    local eventIconString = GW.GetIconString(self.args.icon, 16, 16)
                    local gradientName = getGradientText(self.args.eventName, self.args.barColor)
                    GW.Notice(format(L["%s will start in %s!"], eventIconString .. " " .. gradientName, secondToTime(self.timeLeft)))
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

                if self.args.hasWeeklyReward then
                    if self.isCompleted then
                        GameTooltip:AddDoubleLine(
                            PVP_WEEKLY_REWARD,
                            StringByTemplate(CRITERIA_COMPLETED, "success"),
                            1,
                            1,
                            1
                        )
                    else
                        GameTooltip:AddDoubleLine(
                            PVP_WEEKLY_REWARD,
                            StringByTemplate(CRITERIA_NOT_COMPLETED, "danger"),
                            1,
                            1,
                            1
                        )
                    end
                end

                GameTooltip:Show()
            end,
            onLeave = function()
                GameTooltip:Hide()
            end,
        },
    },
    triggerTimer = {
        init = function(self)
            self.icon = self:CreateTexture(nil, "ARTWORK")
            self.icon:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
            self.icon.backdrop:GwSetOutside(self.icon, 1, 1)
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
                            if timeData.left <= 0 then
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

                if not self.args.alertCache then
                    self.args.alertCache = {}
                end

                local needAnnounce = false
                local readyNets = {}
                local bonusReady = false

                for netIndex, timeData in pairs(self.netTable) do
                    if type(timeData) == "table" and timeData.left <= 0 then
                        if not self.args.alertCache[netIndex] then
                            self.args.alertCache[netIndex] = {}
                        end

                        if not self.args.alertCache[netIndex][db[netIndex].time] then
                            self.args.alertCache[netIndex][db[netIndex].time] = true
                            local hour = self.args.disableAlertAfterHours
                            if not hour or hour == 0 or (hour * 60 * 60 + timeData.left) > 0 then
                                readyNets[netIndex] = true
                                if netIndex > 2 then
                                    bonusReady = true
                                end
                                needAnnounce = true
                            end
                        end
                    end
                end

                if needAnnounce then
                    local netsText = ""

                    if readyNets[1] and readyNets[2] then
                        netsText = netsText .. format(L["Net #%d"], 1) .. ", " .. format(L["Net #%d"], 2)
                    elseif readyNets[1] then
                        netsText = netsText .. format(L["Net #%d"], 1)
                    elseif readyNets[2] then
                        netsText = netsText .. format(L["Net #%d"], 2)
                    end
                    if bonusReady then
                        if readyNets[1] or readyNets[2] then
                            netsText = netsText .. ", "
                        end
                        netsText = netsText .. L["Bonus Net"]
                    end

                    local eventIconString = GW.GetIconString(self.args.icon, 16, 16)
                    local gradientName = getGradientText(self.args.eventName, self.args.barColor)
                    GW.Notice(format(eventIconString .. " " .. gradientName .. " " .. L["%s can be collected"], netsText))
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

                local netIndex1Status  -- Always
                local netIndex2Status  -- Always
                local bonusNetStatus  -- Bonus
                local bonusTimeLeft = 0

                for netIndex, timeData in pairs(self.netTable) do
                    local text
                    if type(timeData) == "table" then
                        if timeData.left <= 0 then
                            text = StringByTemplate(L["Can be collected"], "success")
                        else
                            text = StringByTemplate(secondToTime(timeData.left), "info")
                        end

                        -- only show latest bonus net
                        if netIndex > 2 and timeData.left > bonusTimeLeft then
                            bonusTimeLeft = timeData.left
                            bonusNetStatus = text
                        end
                    else
                        if timeData == "NOT_STARTED" then
                            text = StringByTemplate(L["Can be set"], "warning")
                        end
                    end

                    if netIndex == 1 then
                        netIndex1Status = text
                    elseif netIndex == 2 then
                        netIndex2Status = text
                    end
                end

                GameTooltip:AddDoubleLine(format(L["Net #%d"], 1), netIndex1Status)
                GameTooltip:AddDoubleLine(format(L["Net #%d"], 2), netIndex2Status)
                if bonusNetStatus then
                    GameTooltip:AddDoubleLine(L["Bonus Net"], bonusNetStatus)
                else -- no bonus net
                    GameTooltip:AddDoubleLine(L["Bonus Net"], StringByTemplate(L["Not Set"], "danger"))
                end

                GameTooltip:Show()
            end,
            onLeave = function()
                GameTooltip:Hide()
            end
        }
    }
}
GW.EventTrackerFunctions = functionFactory

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
    frame:SetSize(190, 30)

    frame.args = data.args
    frame.dbKey = data.dbKey
    data.frame = frame

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
            if frame.tickerInstance then
                frame.tickerInstance:Cancel()
                frame.tickerInstance = nil
            end
            frame.tickerInstance = C_Timer.NewTicker(functions.ticker.interval, function()
                if not settings.communityFeast.enabled and not settings.dragonbaneKeep.enabled and not settings.iskaaranFishingNet.enabled
                    and not settings.researchersUnderFire.enabled and not settings.timeRiftThaldraszus.enabled and not settings.superBloom.enabled then
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
    mapFrame.heightPerRow = 30
    mapFrame:SetFrameStrata("MEDIUM")
    mapFrame:SetPoint("TOPLEFT", WorldMapFrame, "BOTTOMLEFT", 0, 2)
    mapFrame:SetPoint("TOPRIGHT", WorldMapFrame, "BOTTOMRIGHT", 0, 2)
    mapFrame:SetHeight(mapFrame.heightPerRow)
    mapFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)

    mapFrame:SetScript("OnEvent", HandlerEvent)
end

local function UpdateTrackers()
    UpdateSettings()

    local lastTracker = nil
    local usedWidth = 0
    local mapFrameWidth = WorldMapFrame:GetWidth()
    local rowIdx = 1
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
                tracker.args.alertSecond = tonumber(settings[data.dbKey].alertSeconds)
                tracker.args.stopAlertIfCompleted = settings[data.dbKey].stopAlertIfCompleted
                tracker.args.disableAlertAfterHours = tonumber(settings[data.dbKey].disableAlertAfterHours)
            else
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
                tracker:SetPoint("TOPLEFT", mapFrame, "TOPLEFT", 3.5, rowIdx == 1 and 0 or -(mapFrame.heightPerRow * (rowIdx - 1) - 3))
                usedWidth = usedWidth + tracker:GetWidth() + 3.5
            end
            lastTracker = tracker
        end
    end
    mapFrame:SetHeight(mapFrame.heightPerRow * rowIdx)
    mapFrame:SetShown(settings.communityFeast.enabled or settings.dragonbaneKeep.enable or settings.iskaaranFishingNet.enabled or settings.researchersUnderFire.enabled or settings.timeRiftThaldraszus.enabled or settings.superBloom.enabled)
end
GW.UpdateWorldEventTrackers = UpdateTrackers

local function LoadDragonFlightWorldEvents()
    AddWorldMapFrame()
    C_Timer.After(1, function()
        WorldMapFrame:Show()
        UpdateTrackers()
        WorldMapFrame:Hide()
    end)

    for event in pairs(eventHandlers) do
        mapFrame:RegisterEvent(event)
    end
end
GW.LoadDragonFlightWorldEvents = LoadDragonFlightWorldEvents


_G["SLASH_GWSLASH1"] = "/gw2"

SlashCmdList["GWSLASH"] = function(msg)
    if msg == "fnet forceUpdate" then
        local map = C_Map.GetBestMapForUnit("player")
        if not map then
            return
        end

        local position = C_Map.GetPlayerMapPosition(map, "player")

        if not position then
            return
        end

        local lengthMap = {}

        for i, netPos in ipairs(env.fishingNetPosition) do
            if map == netPos.map then
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

        local namePlates = C_NamePlate.GetNamePlates(true)
        if #namePlates > 0 then
            for _, namePlate in ipairs(namePlates) do
                if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.WidgetContainer then
                    local container = namePlate.UnitFrame.WidgetContainer
                    if container.timerWidgets then
                        for id, widget in pairs(container.timerWidgets) do
                            if env.fishingNetWidgetIDToIndex[id] and env.fishingNetWidgetIDToIndex[id] == netIndex then
                                if widget.Bar and widget.Bar.value then
                                    db[netIndex] = {
                                        time = GetServerTime() + widget.Bar.value,
                                        duration = widget.Bar.range
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if msg == "findNet" then
        local map = C_Map.GetBestMapForUnit("player")
        if not map then
            return
        end

        local position = C_Map.GetPlayerMapPosition(map, "player")

        if not position then
            return
        end

        local namePlates = C_NamePlate.GetNamePlates(true)
        if #namePlates > 0 then
            for _, namePlate in ipairs(namePlates) do
                if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.WidgetContainer then
                    local container = namePlate.UnitFrame.WidgetContainer
                    if container.timerWidgets then
                        for id, widget in pairs(container.timerWidgets) do
                            if widget.Bar and widget.Bar.value then
                                print("------------")
                                print("mapID", map)
                                print("mapName", C_Map.GetMapInfo(map).name)
                                print("position", position.x, position.y)
                                print("widgetID", id)
                                print("timeLeft", widget.Bar.value, secondToTime(widget.Bar.value))
                                print("------------")
                            end
                        end
                    end
                end
            end
        end
    end
end
