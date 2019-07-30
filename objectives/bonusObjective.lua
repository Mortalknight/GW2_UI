local _, GW = ...
local AddTrackerNotification = GW.AddTrackerNotification
local RemoveTrackerNotificationOfType = GW.RemoveTrackerNotificationOfType
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local NewQuestAnimation = GW.NewQuestAnimation
local ParseSimpleObjective = GW.ParseSimpleObjective
local ParseObjectiveString = GW.ParseObjectiveString
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local UpdateQuestItem = GW.UpdateQuestItem
local QuestTrackerLayoutChanged = GW.QuestTrackerLayoutChanged

local savedQuests = {}

local function getObjectiveBlock(self, index)
    if _G[self:GetName() .. "GwQuestObjective" .. index] ~= nil then
        return _G[self:GetName() .. "GwQuestObjective" .. index]
    end

    if self.objectiveBlocksNum == nil then
        self.objectiveBlocksNum = 0
    end
    if self.objectiveBlocks == nil then
        self.objectiveBlocks = {}
    end

    self.objectiveBlocksNum = self.objectiveBlocksNum + 1

    local newBlock = CreateObjectiveNormal(self:GetName() .. "GwQuestObjective" .. self.objectiveBlocksNum, self)
    newBlock:SetParent(self)
    self.objectiveBlocks[self.objectiveBlocksNum] = newBlock
    if self.objectiveBlocksNum == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint(
            "TOPRIGHT",
            _G[self:GetName() .. "GwQuestObjective" .. (self.objectiveBlocksNum - 1)],
            "BOTTOMRIGHT",
            0,
            0
        )
    end

    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    return newBlock
end
GW.AddForProfiling("bonusObjective", "getObjectiveBlock", getObjectiveBlock)

local function addObjectiveBlock(block, text, finished, objectiveIndex, objectiveType, quantity)
    local objectiveBlock = getObjectiveBlock(block, objectiveIndex)

    local precentageComplete = 0
    if text then
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText(text)
        if finished then
            objectiveBlock.ObjectiveText:SetTextColor(0.8, 0.8, 0.8)
        else
            objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
        end

        if objectiveType == "progressbar" or ParseObjectiveString(objectiveBlock, text) then
            if objectiveType == "progressbar" then
                objectiveBlock.StatusBar:Show()
                objectiveBlock.StatusBar:SetMinMaxValues(0, 100)
                objectiveBlock.StatusBar:SetValue(GetQuestProgressBarPercent(block.questID))
                objectiveBlock.progress = GetQuestProgressBarPercent(block.questID) / 100
            end
            precentageComplete = objectiveBlock.progress
        else
            objectiveBlock.StatusBar:Hide()
        end

        local h = 20
        if objectiveBlock.StatusBar:IsShown() then
            h = 50
        end
        block.height = block.height + h
        block.numObjectives = block.numObjectives + 1
    end
    return precentageComplete
end
GW.AddForProfiling("bonusObjective", "addObjectiveBlock", addObjectiveBlock)

local function updateBonusObjective(self, event)
    RemoveTrackerNotificationOfType("EVENT")
    RemoveTrackerNotificationOfType("EVENT_NEARBY")
    RemoveTrackerNotificationOfType("BONUS")

    GwBonusObjectiveBlock.height = 20
    GwBonusObjectiveBlock.numObjectives = 0
    GwBonusObjectiveBlock:Hide()
    UpdateQuestItem(GwBonusItemButton, 0)

    local foundEvent = false

    local tasks = GetTasksTable()

    if GwQuesttrackerContainerBonusObjectives.collapsed == true then
        GwBonusHeader:Show()
    end

    for k, v in pairs(tasks) do
        local questID = v
        local isInArea, isOnMap, numObjectives, text = GetTaskInfo(questID)
        local questLogIndex = GetQuestLogIndexByID(questID)
        local simpleDesc = ""
        local compassData = {}

        if isOnMap then
            --local compassData = {}
            compassData["TYPE"] = "EVENT"
            compassData["COMPASS"] = true
        end

        if numObjectives == nil then
            numObjectives = 0
        end
        if isInArea then
            compassData["TITLE"] = text

            if text == nil then
                text = ""
            end
            GwBonusObjectiveBlock.Header:SetText(text)

            if savedQuests[questID] == nil then
                NewQuestAnimation(GwBonusObjectiveBlock)
                PlaySound(SOUNDKIT["UI_WORLDQUEST_START"])
                savedQuests[questID] = true
            end

            GwBonusObjectiveBlock.questID = questID
            GwBonusObjectiveBlock.id = questID

            local module = CreateBonusObjectiveTrackerModule()
            GwBonusObjectiveBlock.module = module

            GwBonusHeader:Show()
            UpdateQuestItem(GwBonusItemButton, questLogIndex)

            foundEvent = true

            compassData["PROGRESS"] = 0

            local objectiveProgress = 0
            for objectiveIndex = 1, numObjectives do
                local txt, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, false)

                compassData["TYPE"] = "EVENT"

                compassData["ID"] = questID

                compassData["COLOR"] = TRACKER_TYPE_COLOR["EVENT"]
                compassData["COMPASS"] = false
                compassData["X"] = x
                compassData["Y"] = y
                compassData["QUESTID"] = questID
                compassData["MAPID"] = mapId

                if simpleDesc == "" then
                    simpleDesc = ParseSimpleObjective(txt)
                else
                    simpleDesc = simpleDesc .. ", " .. ParseSimpleObjective(txt)
                end

                if not GwQuesttrackerContainerBonusObjectives.collapsed == true then
                    if finished then
                        objectiveProgress = objectiveProgress + (1 / numObjectives) + addObjectiveBlock(GwBonusObjectiveBlock, txt, finished, objectiveIndex, objectiveType)
                    else
                        objectiveProgress = objectiveProgress + (addObjectiveBlock(GwBonusObjectiveBlock, txt, finished, objectiveIndex, objectiveType) / numObjectives)
                    end
                end
            end

            if simpleDesc ~= "" then
                compassData["DESC"] = simpleDesc
            end

            compassData["PROGRESS"] = objectiveProgress

            AddTrackerNotification(compassData)
            break
        end
    end

    if foundEvent == false then
        savedQuests = {}
        --      RemoveTrackerNotificationOfType('EVENT')
        --      RemoveTrackerNotificationOfType('BONUS')
        GwBonusHeader:Hide()
    else
        if not GwQuesttrackerContainerBonusObjectives.collapsed == true then
            --add groupfinder button
            if C_LFGList.CanCreateQuestGroup(GwBonusObjectiveBlock.questID) then
                GwBonusObjectiveBlock.joingroup:Show()
            else
                GwBonusObjectiveBlock.joingroup:Hide()
            end
            GwBonusObjectiveBlock:Show()
        end
    end
    for i = GwBonusObjectiveBlock.numObjectives + 1, 20 do
        if _G[GwBonusObjectiveBlock:GetName() .. "GwQuestObjective" .. i] ~= nil then
            _G[GwBonusObjectiveBlock:GetName() .. "GwQuestObjective" .. i]:Hide()
        end
    end

    GwBonusObjectiveBlock:SetHeight(GwBonusObjectiveBlock.height + 5)
    GwQuesttrackerContainerBonusObjectives:SetHeight(GwBonusObjectiveBlock.height + 20)

    QuestTrackerLayoutChanged()
end
GW.AddForProfiling("bonusObjective", "updateBonusObjective", updateBonusObjective)

local function LoadBonusFrame()
    GwQuesttrackerContainerBonusObjectives:SetScript(
        "OnEvent",
        function(self, event)
            updateBonusObjective(self, event)
        end
    )

    GwQuesttrackerContainerBonusObjectives:RegisterEvent("QUEST_LOG_UPDATE")
    GwQuesttrackerContainerBonusObjectives:RegisterEvent("TASK_PROGRESS_UPDATE")
    GwQuesttrackerContainerBonusObjectives:RegisterEvent("QUEST_WATCH_LIST_CHANGED")

    local newBlock = CreateTrackerObject("GwBonusObjectiveBlock", GwQuesttrackerContainerBonusObjectives)
    newBlock:SetParent(GwQuesttrackerContainerBonusObjectives)
    newBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerBonusObjectives, "TOPRIGHT", 0, -20)
    newBlock.Header:SetText("")

    newBlock:SetScript("OnEnter", BonusObjectiveTracker_ShowRewardsTooltip)
    newBlock:SetScript("OnLeave", GameTooltip_Hide)

    newBlock.color = TRACKER_TYPE_COLOR["BONUS"]
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)

    newBlock.joingroup:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
    newBlock.joingroup:SetScript(
                    "OnClick",
                    function (self)
                        local p = self:GetParent()
                        LFGListUtil_FindQuestGroup(p.questID)
                    end
                )
    newBlock.joingroup:SetScript(
        "OnEnter",
        function (self)
            GameTooltip:SetOwner(self)
            GameTooltip:AddLine(TOOLTIP_TRACKER_FIND_GROUP_BUTTON, HIGHLIGHT_FONT_COLOR:GetRGB())
            GameTooltip:Show()
        end
    )
    newBlock.joingroup:SetScript("OnLeave", GameTooltip_Hide)

    local header =
        CreateFrame("Button", "GwBonusHeader", GwQuesttrackerContainerBonusObjectives, "GwQuestTrackerHeader")
    header.icon:SetTexCoord(0, 1, 0.5, 0.75)
    header.title:SetFont(UNIT_NAME_FONT, 14)
    header.title:SetShadowOffset(1, -1)
    header.title:SetText(EVENTS_LABEL)

    GwQuesttrackerContainerBonusObjectives.collapsed = false
    header:SetScript(
        "OnClick",
        function(self)
            local p = self:GetParent()
            if p.collapsed == nil or p.collapsed == false then
                p.collapsed = true

                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            else
                p.collapsed = false

                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            end
            updateBonusObjective()
        end
    )
    header.title:SetTextColor(
        TRACKER_TYPE_COLOR["BONUS"].r,
        TRACKER_TYPE_COLOR["BONUS"].g,
        TRACKER_TYPE_COLOR["BONUS"].b
    )
    
    updateBonusObjective()
end
GW.LoadBonusFrame = LoadBonusFrame
