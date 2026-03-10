---@class GW2
local GW = select(2, ...)
local L = GW.L

--[[
    Credits: fang2hou -> ElvUI_Windtools
]]--
local LeftButtonIcon = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t"
local mapFrame
local eventHandlers = {}

local eventList = {
    -- Midnight
    "WeeklyMN",
    "ProfessionsWeeklyMN",
    "StormarionAssault",
    -- TWW
    "KhazAlgarEmissary",
    "TheaterTroupe",
    "RingingDeeps",
    "SpreadingTheLight",
    "UnderworldOperative",
    -- DF
    "CommunityFeast",
    "SiegeOnDragonbaneKeep",
    "ResearchersUnderFire",
    "TimeRiftThaldraszus",
    "SuperBloom",
    "BigDig",
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
    ProfessionsWeeklyMN = {
        [4620669] = 93690, -- 炼金术
        [4620670] = 93691, -- 锻造
        [4620672] = 93698, -- 附魔
        [4620673] = 93692, -- 工程学
        [4620675] = { 93700, 93702, 93703, 93704 }, -- 草药学
        [4620676] = 93693, -- 铭文
        [4620677] = 93694, -- 珠宝
        [4620678] = 93695, -- 制皮
        [4620679] = { 93705, 93706, 93708, 93709 }, -- 采矿
        [4620680] = { 93710, 93711, 93714 }, -- 剥皮
        [4620681] = 93696, -- 裁缝
    },
}

local colorPlatte = {
    blue = {
        startColor = CreateColor(0.32941, 0.52157, 0.93333, 1),
        endColor = CreateColor(0.25882, 0.84314,0.86667, 1)
    },
    red = {
        startColor = CreateColor(0.92549, 0.00000, 0.54902, 1),
        endColor = CreateColor(0.98824, 0.40392, 0.40392, 1)
    },
    green = {
        startColor = CreateColor(0.40392, 0.92549, 0.54902, 1),
        endColor = CreateColor(0.00000, 0.98824, 0.40392, 1)
    },
    purple = {
        startColor = CreateColor(0.27843, 0.46275, 0.90196, 1),
        endColor = CreateColor(0.55686, 0.32941, 0.91373, 1)
    },
    bronze = {
        startColor = CreateColor(0.83000, 0.42000, 0.10000, 1),
        endColor = CreateColor(0.56500, 0.40800, 0.16900, 1)
    },
    running = {
        startColor = CreateColor(0 / 255, 148 / 255, 135 / 255, 1),
        endColor = CreateColor(0 / 255, 211 / 255, 144 / 255, 1),
    },
    gray = {
        startColor = CreateColor(159 / 255, 159 / 255, 159 / 255, 1),
        endColor = CreateColor(65 / 255, 65 / 255, 65 / 255, 1)
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
    bar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/hud/castinbar-white.png")
    bar.backdrop:GwSetOutside(bar, 4, 4)
end

local function GetWorldMapIDSetter(idOrFunc)
    return function(...)
        if not WorldMapFrame or not WorldMapFrame:IsShown() or not WorldMapFrame.SetMapID then
            return
        end

        local id = type(idOrFunc) == "function" and idOrFunc(...) or idOrFunc
        WorldMapFrame:SetMapID(id)
    end
end

local function WeeklyName(iconID, name, position)
    name = GW.GetIconString(iconID, 14, 16, true) .. " " .. name
    if type(position) == "number" then
        position = C_Map.GetMapInfo(position).name
    end

    if position then
        name = format("%s (%s)", name, StringByTemplate(position, "info"))
    end

    return name
end

local eventData = {
    -- Midnight
    ProfessionsWeeklyMN = {
        dbKey = "professionsWeeklyMN",
        args = {
            icon = 1392955,
            type = "weekly",
            questProgress = function()
                local prof1, prof2 = GetProfessions()
                local quests = {}

                for _, prof in pairs({ prof1, prof2 }) do
                    if prof then
                        local name, iconID = GetProfessionInfo(prof)
                        local questData = env.ProfessionsWeeklyMN[iconID]
                        if questData then
                            tinsert(quests, {
                                questID = questData,
                                label = GW.GetIconString(iconID, 14, 14) .. " " .. name,
                            })
                        end
                    end
                end

                return quests
            end,
            hasWeeklyReward = false,
            eventName = L["Professions Weekly"],
            location = C_Map.GetMapInfo(2393).name,
            label = L["Professions Weekly"],
            onClick = GetWorldMapIDSetter(2393),
            onClickHelpText = L["Click to show location"],
        },
    },
    WeeklyMN = {
        dbKey = "weeklyMN",
        args = {
            icon = 236681,
            type = "weekly",
            questIDs = {
                [WeeklyName(7578704, L["Liadrin 4 > 1"], 2393)] = {
                    -- https://www.wowhead.com/npc=256203/lady-liadrin
                    93767,
                    93889,
                    93909,
                    93911,
                },
                [WeeklyName(5554512, L["Dungeon"], 2393)] = {
                    -- https://www.wowhead.com/npc=256210/halduron-brightwing
                    93753,
                },
                [WeeklyName(2066011, L["Soiree"], 2395)] = {
                    -- https://www.wowhead.com/item=268489/surplus-bag-of-party-favors
                    90573,
                    90574,
                    90575,
                    90576,
                },
                [WeeklyName(7385004, L["Legend"], 2413)] = {
                    -- https://www.wowhead.com/npc=238170/zurashar-kassameh#ends
                    88993,
                    88994,
                    88995,
                    88996,
                    88997,
                },
                [WeeklyName(7636650, L["Abundance"], 2437)] = {
                    -- https://www.wowhead.com/quest=89507/abundant-offerings
                    89507,
                },
            },
            questProgress = function(args)
                local questIDs = type(args.questIDs) == "function" and args:questIDs() or args.questIDs
                local progress = {}

                for storylineName, storylineQuests in pairs(questIDs) do
                    local weeklyQuestID, status
                    for _, questID in pairs(storylineQuests) do
                        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                            weeklyQuestID = questID
                            status = "completed"
                            break
                        end

                        if C_QuestLog.IsOnQuest(questID) then
                            weeklyQuestID = questID
                            status = "inProgress"
                            break
                        end
                    end

                    local rightText = ""
                    local questName = weeklyQuestID and C_QuestLog.GetTitleForQuestID(weeklyQuestID)

                    if questName then
                        if status == "inProgress" then
                            rightText = format("%s - %s", StringByTemplate(questName, "greyLight"), StringByTemplate(IN_PROGRESS, "warning"))
                        elseif status == "completed" then
                            rightText = format("%s - %s", StringByTemplate(questName, "greyLight"), StringByTemplate(CRITERIA_COMPLETED, "success"))
                        end
                    else
                        rightText = StringByTemplate(L["Not Accepted"], "danger")
                    end

                    tinsert(progress, { label = storylineName, rightText = rightText })
                end

                return progress
            end,
            eventName = format("%s (%s)", L["Weekly Quest"], L["Midnight"]),
            location = C_Map.GetMapInfo(2537).name,
            label = format("%s (%s)", L["Weekly Quest"], L["MN"]),
            onClick = GetWorldMapIDSetter(2537),
            onClickHelpText = L["Click to show location"],
        },
    },
    StormarionAssault = {
        dbKey = "stormarionAssault",
        args = {
            icon = 7431083,
            type = "loopTimer",
            questIDs = { 90962 },
            hasWeeklyReward = true,
            duration = 15 * 60,
            interval = 30 * 60,
            eventName = L["Stormarion Assault"],
            label = L["Stormarion Assault"],
            location = C_Map.GetMapInfo(2405).name,
            flash = true,
            runningBarColor = colorPlatte.green,
            runningText = IN_PROGRESS,
            filter = function(args)
                if not C_QuestLog.IsQuestFlaggedCompleted(91281) then
                    return false
                end
                return true
            end,
            startTimestamp = 1772728200,
            onClick = GetWorldMapIDSetter(2405),
            onClickHelpText = L["Click to show location"],
        },
    },
    -- TWW
    KhazAlgarEmissary = {
        dbKey = "khazAlgarEmissary",
        args = {
            icon = 236681,
            type = "weekly",
            questIDs = {
                82449,
                82452,
                82453,
                82482,
                82483,
                82485,
                82486,
                82487,
                82488,
                82489,
                82490,
                82491,
                82492,
                82493,
                82494,
                82495,
                82496,
                82497,
                82498,
                82499,
                82500,
                82501,
                82502,
                82503,
                82504,
                82505,
                82506,
                82507,
                82508,
                82509,
                82510,
                82511,
                82512,
                82516,
                82659,
                82678,
                82708,
            },
            hasWeeklyReward = true,
            eventName = L["Khaz Algar Emissary"],
            location = C_Map.GetMapInfo(2339).name,
            label = L["Khaz Algar Emissary"],
            completedText = CRITERIA_COMPLETED,
            notCompletedText = CRITERIA_NOT_COMPLETED,
            onClick = GetWorldMapIDSetter(2339),
            onClickHelpText = L["Click to show location"],
        },
    },
    TheaterTroupe = {
        dbKey = "theaterTroupe",
        args = {
            icon = 5788303,
            type = "loopTimer",
            questIDs = {83240},
            hasWeeklyReward = true,
            duration = 15 * 60,
            interval = 60 * 60,
            barColor = colorPlatte.bronze,
            flash = true,
            runningBarColor = colorPlatte.green,
            eventName = L["Theater Troupe"],
            location = C_Map.GetMapInfo(2248).name,
            label = L["Theater"],
            runningText = L["Performing"],
            startTimestamp = (function()
                local timestampTable = {
                    [1] = 1724976005, -- NA
                    [2] = 1724976005, -- KR
                    [3] = 1724976005, -- EU
                    [4] = 1724976005, -- TW
                    [5] = 1724976005, -- CN
                    [72] = 1724976000,
                }

                local region = GetCurrentRegion()
                -- TW is not a real region, so we need to check the client language if player in KR
                if region == 2 and GW.mylocal ~= "koKR" then
                    region = 4
                end

                return timestampTable[region] or timestampTable[1]
            end)(),
            onClick = GetWorldMapIDSetter(2248),
            onClickHelpText = L["Click to show location"],
        },
    },
    RingingDeeps = {
        dbKey = "ringingDeeps",
        args = {
            icon = 2120036,
            type = "weekly",
            questIDs = { 83333 },
            hasWeeklyReward = true,
            eventName = L["Ringing Deeps"],
            location = C_Map.GetMapInfo(2214).name,
            label = L["Ringing Deeps"],
            completedText = CRITERIA_COMPLETED,
            notCompletedText = CRITERIA_NOT_COMPLETED,
            onClick = GetWorldMapIDSetter(2214),
            onClickHelpText = L["Click to show location"],
        },
    },
    SpreadingTheLight = {
        dbKey = "spreadingTheLight",
        args = {
            icon = 5927633,
            type = "weekly",
            questIDs = { 76586 },
            hasWeeklyReward = true,
            eventName = L["Spreading The Light"],
            location = C_Map.GetMapInfo(2215).name,
            label = L["Spreading The Light"],
            completedText = CRITERIA_COMPLETED,
            notCompletedText = CRITERIA_NOT_COMPLETED,
            onClick = GetWorldMapIDSetter(2215),
            onClickHelpText = L["Click to show location"],
        },
    },
    UnderworldOperative = {
        dbKey = "underworldOperative",
        args = {
            icon = 5309857,
            type = "weekly",
            questIDs = { 80670, 80671, 80672 },
            hasWeeklyReward = true,
            eventName = L["Underworld Operative"],
            location = C_Map.GetMapInfo(2255).name,
            label = L["Underworld Operative"],
            completedText = CRITERIA_COMPLETED,
            notCompletedText = CRITERIA_NOT_COMPLETED,
            onClick = GetWorldMapIDSetter(2255),
            onClickHelpText = L["Click to show location"],
        },
    },
    --DF
    CommunityFeast = {
        dbKey = "communityFeast",
        args = {
            icon = 4687629,
            type = "loopTimer",
            questIDs = {70893},
            hasWeeklyReward = true,
            duration = 900,
            interval = 5400,
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
                    [1] = 1679751000, -- NA
                    [2] = 1679747400, -- KR
                    [3] = 1679749200, -- EU
                    [4] = 1679747400, -- TW
                    [5] = 1679747400, -- CN
                }
                local region = GetCurrentRegion()
                -- TW is not a real region, so we need to check the client language if player in KR
                if region == 2 and GW.mylocal ~= "koKR" then
                    region = 4
                end

                return timestampTable[region] or timestampTable[1]
            end)(),
            onClick = GetWorldMapIDSetter(2024),
            onClickHelpText = L["Click to show location"]
        }
    },
    SiegeOnDragonbaneKeep = {
        dbKey = "dragonbaneKeep",
        args = {
            icon = 236469,
            type = "loopTimer",
            questIDs = {70866},
            hasWeeklyReward = true,
            duration = 600,
            interval = 7200,
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
                    [1] = 1670338860, -- NA
                    [2] = 1670698860, -- KR
                    [3] = 1670342460, -- EU
                    [4] = 1670698860, -- TW
                    [5] = 1670677260, -- CN
                }
                local region = GetCurrentRegion()
                -- TW is not a real region, so we need to check the client language if player in KR
                if region == 2 and GW.mylocal ~= "koKR" then
                    region = 4
                end

                return timestampTable[region] or timestampTable[1]
            end)(),
            onClick = GetWorldMapIDSetter(2022),
            onClickHelpText = L["Click to show location"]
        }
    },
    ResearchersUnderFire = {
        dbKey = "researchersUnderFire",
        args = {
            icon = 5140835,
            type = "loopTimer",
            questIDs = {75627, 75628, 75629, 75630},
            hasWeeklyReward = true,
            duration = 1500,
            interval = 3600,
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
                    [1] = 1670333400, -- NA
                    [2] = 1670703300, -- KR
                    [3] = 1683804600, -- EU
                    [4] = 1670702400, -- TW
                    [5] = 1670702460, -- CN
                }
                local region = GetCurrentRegion()
                -- TW is not a real region, so we need to check the client language if player in KR
                if region == 2 and GW.mylocal ~= "koKR" then
                    region = 4
                end

            return timestampTable[region] or timestampTable[1]
            end)(),
            onClick = GetWorldMapIDSetter(2133),
            onClickHelpText = L["Click to show location"]
        }
    },
    TimeRiftThaldraszus = {
        dbKey = "timeRiftThaldraszus",
        args = {
            icon = 237538,
            type = "loopTimer",
            questIDs = {77236},
            hasWeeklyReward = true,
            duration = 900,
            interval = 3600,
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
                    [1] = 1701831600, -- NA
                    [2] = 1701853200, -- KR
                    [3] = 1689274800, -- EU
                    [4] = 1701849600, -- TW
                    [5] = 1701824400, -- CN
                }
                local region = GetCurrentRegion()
                -- TW is not a real region, so we need to check the client language if player in KR
                if region == 2 and GW.mylocal ~= "koKR" then
                    region = 4
                end

            return timestampTable[region] or timestampTable[1]
            end)(),
            onClick = GetWorldMapIDSetter(2025),
            onClickHelpText = L["Click to show location"]
        }
    },
    SuperBloom = {
        dbKey = "superBloom",
        args = {
            icon = 133940,
            type = "loopTimer",
            questIDs = {78319},
            hasWeeklyReward = true,
            duration = 900,
            interval = 3600,
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
                    [1] = 1699462800, -- NA
                    [2] = 1701828010, -- KR
                    [3] = 1699462800, -- EU
                    [4] = 1701828010, -- TW
                    [5] = 1701828010, -- CN
                }
                local region = GetCurrentRegion()
                -- TW is not a real region, so we need to check the client language if player in KR
                if region == 2 and GW.mylocal ~= "koKR" then
                    region = 4
                end

                return timestampTable[region] or timestampTable[1]
            end)()
        }
    },
    BigDig = {
        dbKey = "bigDig",
        args = {
            icon = 1362650,
            type = "loopTimer",
            questIDs = {79226},
            hasWeeklyReward = true,
            duration = 600,
            interval = 3600,
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
                    [1] = 1705595400, -- NA
                    [2] = 1701826200, -- KR
                    [3] = 1705595400, -- EU
                    [4] = 1701826200, -- TW
                    [5] = 1701826200, -- CN
                }
                local region = GetCurrentRegion()
                -- TW is not a real region, so we need to check the client language if player in KR
                if region == 2 and GW.mylocal ~= "koKR" then
                    region = 4
                end

                return timestampTable[region] or timestampTable[1]
            end)(),
            onClick = GetWorldMapIDSetter(2024),
            onClickHelpText = L["Click to show location"]
        }
    },
}

local functionFactory = {
    weekly = {
        init = function(self)
            self.icon = self:CreateTexture(nil, "ARTWORK")
            self.icon:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
            self.icon.backdrop:GwSetOutside(self.icon, 1, 1)
            self.name = self:CreateFontString(nil, "OVERLAY")
            self.completed = self:CreateFontString(nil, "OVERLAY")

            self:SetScript("OnMouseDown", function()
                if self.args.onClick then
                    self.args:onClick()
                end
            end)
        end,
        setup = function(self)
            self.icon:SetTexture(self.args.icon)
            self.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            self.icon:SetSize(22, 22)
            self.icon:ClearAllPoints()
            self.icon:SetPoint("LEFT", self, "LEFT", 0, 0)

            self.name:SetFont(UNIT_NAME_FONT, 13, "OUTLINE")
            self.name:ClearAllPoints()
            self.name:SetPoint("TOPLEFT", self, "TOPLEFT", 30, -2)
            self.name:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
            self.name:SetText(self.args.label)
            self.name:SetJustifyH("LEFT")

            self.completed:SetFont(UNIT_NAME_FONT, 13, "OUTLINE")
            self.completed:ClearAllPoints()
            self.completed:SetPoint("TOPLEFT", self, "TOPLEFT", 30, -17)
            self.completed:SetText(self.args.completedText)
            self.completed:SetTextColor(GW.HexToRGB(infoColors["greyLight"]))
        end,
        ticker = {
            interval = 2,
            dateUpdater = function(self)
                if self.args.questProgress and not self.args.questIDs then
                    local questProgress = self.args.questProgress
                    if type(questProgress) == "function" then
                        questProgress = questProgress(self.args)
                    end

                    if questProgress then
                        local allCompleted = true
                        for _, data in ipairs(questProgress) do
                            local isCompleted = false
                            if data.questID then
                                if type(data.questID) == "table" then
                                    for _, qid in ipairs(data.questID) do
                                        if C_QuestLog.IsQuestFlaggedCompleted(qid) then
                                            isCompleted = true
                                            break
                                        end
                                    end
                                else
                                    isCompleted = C_QuestLog.IsQuestFlaggedCompleted(data.questID)
                                end
                            end
                            if not isCompleted then
                                allCompleted = false
                                break
                            end
                        end
                        self.isCompleted = allCompleted
                    end
                    return
                end

                if not self.args.questIDs then
                    return
                end

                local questIDs = type(self.args.questIDs) == "function" and self.args:questIDs() or self.args.questIDs
                if not questIDs or type(questIDs) ~= "table" then
                    return
                end

                if type(questIDs) == "table" and type(next(questIDs)) ~= "number" then
                    local completedStorylines, totalStorylines = 0, 0

                    for _, storylineQuests in pairs(questIDs) do
                        totalStorylines = totalStorylines + 1
                        local storylineCompleted = false

                        for _, questID in pairs(storylineQuests) do
                            if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                                storylineCompleted = true
                                break
                            end
                        end

                        if storylineCompleted then
                            completedStorylines = completedStorylines + 1
                        end
                    end

                    self.isCompleted = (completedStorylines == totalStorylines)
                    return
                end

                local completed = 0
                if self.args.checkAllCompleted then
                    completed = 1 - #questIDs
                end

                for _, questID in pairs(questIDs) do
                    if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                        completed = completed + 1
                    end
                end

                self.isCompleted = (completed > 0)
            end,

            uiUpdater = function(self)
                self.icon:SetDesaturated(self.args.desaturate and self.isCompleted)
                self.completed:SetText(self.isCompleted and self.args.completedText or self.args.notCompletedText)
                self.completed:SetTextColor(GW.HexToRGB(self.isCompleted and infoColors["greyLight"] or infoColors["danger"]))
            end,
            alert = GW.NoOp,
        },
        tooltip = {
            onEnter = function(self)
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 8)
                GameTooltip:SetText(GW.GetIconString(self.args.icon, 16, 16) .. " " .. self.args.eventName, 1, 1, 1)

                GameTooltip:AddLine(" ")

                -- Location, Current Location, Next Location
                for _, locationContext in ipairs({
                    { LOCATION_COLON, self.args.location },
                    { L["Current Location"], self.args.currentLocation },
                    { L["Next Location"], self.args.nextLocation },
                }) do
                    local left, right = unpack(locationContext)
                    if right then
                        right = type(right) == "function" and right(self.args) or right
                        GameTooltip:AddDoubleLine(left, right, 1, 1, 1)
                    end
                end

                if self.args.questProgress then
                    local questProgress = self.args.questProgress
                    if type(questProgress) == "function" then
                        questProgress = questProgress(self.args)
                    end

                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(L["Quest Progress:"], 1, 1, 1)
                    for _, data in ipairs(questProgress) do
                        local isCompleted = data.isCompleted
                        if not isCompleted and data.questID then
                            if type(data.questID) == "table" then
                                for _, qid in ipairs(data.questID) do
                                    if C_QuestLog.IsQuestFlaggedCompleted(qid) then
                                        isCompleted = true
                                        break
                                    end
                                end
                            else
                                isCompleted = C_QuestLog.IsQuestFlaggedCompleted(data.questID)
                            end
                        end
                        local color = isCompleted and "success" or "danger"
                        local textL = type(data.label) == "function" and data:label() or data.label
                        local textR = data.rightText or StringByTemplate(isCompleted and CRITERIA_COMPLETED or CRITERIA_NOT_COMPLETED, color)
                        if type(textL) == "string" then
                            GameTooltip:AddDoubleLine(textL, textR, color, 1, 1, 1)
                        end
                    end
                end

                if self.args.hasWeeklyReward then
                    if self.isCompleted then
                        GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD, StringByTemplate(CRITERIA_COMPLETED, "success"), 1, 1, 1)
                    else
                        GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD, StringByTemplate(CRITERIA_NOT_COMPLETED, "danger"), 1, 1, 1)
                    end
                end

                if self.args.onClickHelpText then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(LeftButtonIcon .. " " .. self.args.onClickHelpText, 1, 1, 1)
                end

                GameTooltip:Show()
            end,
            onLeave = function()
                GameTooltip:Hide()
            end,
        },
    },
    onEnterAll = function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip, self.tooltipText)
        GameTooltip:AddLine(" ")
        for _, event in ipairs(eventList) do
            local data = eventData[event]

            if GW.settings[data.dbKey].enabled then
                GameTooltip:AddLine(GW.GetIconString(data.args.icon, 16, 16) .. " " .. data.args.eventName, GW.Colors.TextColors.LightHeader:GetRGB())
                GameTooltip:AddDoubleLine(LOCATION_COLON, data.args.location, 1, 1, 1, 1, 1, 1)

                if data.args.interval then
                    GameTooltip:AddDoubleLine(L["Interval"] .. ":", secondToTime(data.args.interval), 1, 1, 1, 1, 1, 1)
                end
                if data.args.duration then
                    GameTooltip:AddDoubleLine(AUCTION_DURATION .. ":", secondToTime(data.args.duration), 1, 1, 1, 1, 1, 1)
                end
                if data.nextEventTimestamp then
                    GameTooltip:AddDoubleLine(L["Next Event"] .. ":", date(L["TimeStamp m/d h:m:s"], data.nextEventTimestamp), 1, 1, 1, 1, 1, 1)
                end

                if data.frame.isRunning then
                    GameTooltip:AddDoubleLine(STATUS .. ":", StringByTemplate(data.args.runningText, "success"), 1, 1, 1, 1, 1, 1)
                else
                    GameTooltip:AddDoubleLine(STATUS .. ":", StringByTemplate(QUEUED_STATUS_WAITING, "greyLight"), 1, 1, 1, 1, 1, 1)
                end

                if data.args.hasWeeklyReward then
                    if data.frame.isCompleted then
                        GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD .. ":", StringByTemplate(CRITERIA_COMPLETED, "success"), 1, 1, 1, 1, 1, 1)
                    else
                        GameTooltip:AddDoubleLine(PVP_WEEKLY_REWARD .. ":", StringByTemplate(CRITERIA_NOT_COMPLETED, "danger"), 1, 1, 1, 1, 1, 1)
                    end
                end
                GameTooltip:AddLine(" ")
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

            self:SetScript(
                "OnMouseDown",
                function()
                    if self.args.onClick then
                        self.args:onClick()
                    end
                end
            )
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

            self.timerText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
            self.timerText:ClearAllPoints()
            self.timerText:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -6)

            self.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
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
                    local platte = self.args.runningBarColor or colorPlatte.running
                    tex:SetGradient("HORIZONTAL", platte.startColor, platte.endColor)
                    if self.args.runningTextUpdater then
                        self.runningTip:SetText(self.args:runningTextUpdater())
                    end
                    self.runningTip:Show()
                    GW.FrameFlash(self.runningTip, 1, 0.3, 1, true)
                else
                    -- normal tracking timer
                    self.timerText:SetText(secondToTime(self.timeLeft))
                    self.statusBar:SetMinMaxValues(0, self.args.interval)
                    self.statusBar:SetValue(self.timeLeft)

                    local palette = self.args.barColor or colorPlatte.blue
                    self.statusBar:GetStatusBarTexture():SetGradient("HORIZONTAL", palette.startColor, palette.endColor)

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
                    local eventName = StringByTemplate(self.args.eventName, "warning")
                    local remainTime = StringByTemplate(secondToTime(self.timeLeft), "warning")
                    GW.Notice(format(L["%s will start in %s!"], eventIconString .. " " .. eventName, remainTime))
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

                if self.args.questProgress then
                    local questProgress = self.args.questProgress
                    if type(questProgress) == "function" then
                        questProgress = questProgress(self.args)
                    end

                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(L["Quest Progress"])
                    for _, data in ipairs(questProgress) do
                        if data.questID then
                            local isCompleted = false
                            if type(data.questID) == "table" then
                                for _, qid in ipairs(data.questID) do
                                    if C_QuestLog.IsQuestFlaggedCompleted(qid) then
                                        isCompleted = true
                                        break
                                    end
                                end
                            else
                                isCompleted = C_QuestLog.IsQuestFlaggedCompleted(data.questID)
                            end
                            local color = isCompleted and "success" or "danger"
                            local label = type(data.label) == "function" and data:label() or data.label
                            if type(label) == "string" then
                                GameTooltip:AddDoubleLine(label, StringByTemplate(isCompleted and CRITERIA_COMPLETED or CRITERIA_NOT_COMPLETED, color), 1, 1, 1)
                            end
                        end
                    end
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

                if self.args.onClickHelpText then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(LeftButtonIcon .. " " .. self.args.onClickHelpText, 1, 1, 1)
                end

                GameTooltip:Show()
            end,
            onLeave = function()
                GameTooltip:Hide()
            end,
        },
    },
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

local function isOneEventEnabled()
    for _, event in ipairs(eventList) do
        local data = eventData[event]
        if GW.settings[data.dbKey].enabled == true then
            return true
        end
    end
    return false
end

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
            frame.tickFunc = function()
                functions.ticker.dateUpdater(frame)
                functions.ticker.alert(frame)
                if WorldMapFrame:IsShown() and frame:IsShown() then
                    functions.ticker.uiUpdater(frame)
                end
            end

            frame.tickerInstance = C_Timer.NewTicker(functions.ticker.interval, function()
                if not isOneEventEnabled() then
                    return
                end
                frame.tickFunc()
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
    local lastTracker = nil
    local usedWidth = 0
    local mapFrameWidth = WorldMapFrame:GetWidth()
    local rowIdx = 1
    for _, event in ipairs(eventList) do
        local data = eventData[event]
        local tracker = GW.settings[data.dbKey].enabled and trackers:get(event) or trackers:disable(event)
        if tracker then
            if tracker.profileUpdate then
                tracker.profileUpdate()
            end

            tracker.args.desaturate = GW.settings[data.dbKey].desaturate
            tracker.args.flshTaskbar = GW.settings[data.dbKey].flashTaskbar

            if GW.settings[data.dbKey].alert then
                tracker.args.alert = true
                tracker.args.alertSecond = tonumber(GW.settings[data.dbKey].alertSeconds)
                tracker.args.stopAlertIfCompleted = GW.settings[data.dbKey].stopAlertIfCompleted
                tracker.args.disableAlertAfterHours = tonumber(GW.settings[data.dbKey].disableAlertAfterHours)
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

            if tracker.tickFunc then tracker.tickFunc() end
        end
    end
    mapFrame:SetHeight(mapFrame.heightPerRow * rowIdx)
    mapFrame:SetShown(isOneEventEnabled())
end
GW.UpdateWorldEventTrackers = UpdateTrackers

function GW.LoadWorldEventTimer()
    AddWorldMapFrame()
    UpdateTrackers()

    for event in pairs(eventHandlers) do
        mapFrame:RegisterEvent(event)
    end

    EventRegistry:RegisterCallback("WorldMapOnShow", UpdateTrackers)
    EventRegistry:RegisterCallback("WorldMapMinimized", function() C_Timer.After(0.1, UpdateTrackers) end)
    EventRegistry:RegisterCallback("WorldMapMaximized", function() C_Timer.After(0.1, UpdateTrackers) end)
    QuestMapFrame:HookScript("OnShow", UpdateTrackers)
    QuestMapFrame:HookScript("OnHide", UpdateTrackers)
end

