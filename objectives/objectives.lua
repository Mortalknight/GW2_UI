local _, GW = ...
local lerp = GW.lerp
local GetSetting = GW.GetSetting
local CommaValue = GW.CommaValue
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation

local savedQuests = {}

local TRACKER_TYPE_COLOR = {}
GW.TRACKER_TYPE_COLOR = TRACKER_TYPE_COLOR
TRACKER_TYPE_COLOR["QUEST"] = {r = 221 / 255, g = 198 / 255, b = 68 / 255}

local function wiggleAnim(self)
    if self.animation == nil then
        self.animation = 0
    end
    if self.doingAnimation == true then
        return
    end
    self.doingAnimation = true
    AddToAnimation(
        self:GetName(),
        0,
        1,
        GetTime(),
        2,
        function()
            local prog = animations[self:GetName()]["progress"]

            self.flare:SetRotation(lerp(0, 1, prog))

            if prog < 0.25 then
                self.texture:SetRotation(lerp(0, -0.5, math.sin((prog / 0.25) * math.pi * 0.5)))
                self.flare:SetAlpha(lerp(0, 1, math.sin((prog / 0.25) * math.pi * 0.5)))
            end
            if prog > 0.25 and prog < 0.75 then
                self.texture:SetRotation(lerp(-0.5, 0.5, math.sin(((prog - 0.25) / 0.5) * math.pi * 0.5)))
            end
            if prog > 0.75 then
                self.texture:SetRotation(lerp(0.5, 0, math.sin(((prog - 0.75) / 0.25) * math.pi * 0.5)))
            end

            if prog > 0.25 then
                self.flare:SetAlpha(lerp(1, 0, ((prog - 0.25) / 0.75)))
            end
        end,
        nil,
        function()
            self.doingAnimation = false
        end
    )
end
GW.AddForProfiling("objectives", "wiggleAnim", wiggleAnim)

local function NewQuestAnimation(block)
    block.flare:Show()
    block.flare:SetAlpha(1)
    AddToAnimation(
        block:GetName() .. "flare",
        0,
        1,
        GetTime(),
        1,
        function(step)
            block:SetWidth(300 * step)
            block.flare:SetSize(300 * (1 - step), 300 * (1 - step))
            block.flare:SetRotation(2 * step)

            if step > 0.75 then
                block.flare:SetAlpha((step - 0.75) / 0.25)
            end
        end,
        nil,
        function()
            block.flare:Hide()
        end
    )
end
GW.NewQuestAnimation = NewQuestAnimation

local function ParseSimpleObjective(text)
    local itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)")

    if itemName == nil then
        numItems, numNeeded, _ = string.match(text, "(%d+)/(%d+) (%S+)")
    end
    local ndString = ""

    if numItems ~= nil then
        ndString = numItems
    end

    if numNeeded ~= nil then
        ndString = ndString .. "/" .. numNeeded
    end

    return string.gsub(text, ndString, "")
end
GW.ParseSimpleObjective = ParseSimpleObjective

local function ParseCriteria(quantity, totalQuantity, criteriaString)
    if quantity ~= nil and totalQuantity ~= nil and criteriaString ~= nil then
        return string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
    end

    return criteriaString
end
GW.ParseCriteria = ParseCriteria

local function ParseObjectiveString(block, text, objectiveType, quantity)
    if objectiveType == "progressbar" then
        block.StatusBar:SetMinMaxValues(0, 100)
        block.StatusBar:SetValue(quantity)
        block.StatusBar:Show()
        block.StatusBar.precentage = true
        return true
    end
    block.StatusBar.precentage = false
    local _, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)")
    if numItems == nil then
        numItems, numNeeded, _ = string.match(text, "(%d+)/(%d+) (%S+)")
    end
    numItems = tonumber(numItems)
    numNeeded = tonumber(numNeeded)

    if numItems ~= nil and numNeeded ~= nil and numNeeded > 1 and numItems < numNeeded then
        block.StatusBar:Show()
        block.StatusBar:SetMinMaxValues(0, numNeeded)
        block.StatusBar:SetValue(numItems)
        block.progress = numItems / numNeeded
        return true
    end
    return false
end
GW.ParseObjectiveString = ParseObjectiveString

local function FormatObjectiveNumbers(text)
    local itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)")

    if itemName == nil then
        numItems, numNeeded, itemName = string.match(text, "(%d+)/(%d+) ((.*))")
    end
    numItems = tonumber(numItems)
    numNeeded = tonumber(numNeeded)

    if numItems ~= nil and numNeeded ~= nil then
        return CommaValue(numItems) .. " / " .. CommaValue(numNeeded) .. " " .. itemName
    end
    return text
end
GW.FormatObjectiveNumbers = FormatObjectiveNumbers

local function setBlockColor(block, string)
    block.color = TRACKER_TYPE_COLOR[string]
end
GW.AddForProfiling("objectives", "setBlockColor", setBlockColor)

local function statusBar_OnShow(self)
    local f = self:GetParent()
    if not f then
        return
    end
    f:SetHeight(50)
    f.StatusBar.statusbarBg:Show()
end
GW.AddForProfiling("objectives", "statusBar_OnShow", statusBar_OnShow)

local function statusBar_OnHide(self)
    local f = self:GetParent()
    if not f then
        return
    end
    f:SetHeight(20)
    f.StatusBar.statusbarBg:Hide()
end
GW.AddForProfiling("objectives", "statusBar_OnHide", statusBar_OnHide)

local function statusBarSetValue(self)
    local f = self:GetParent()
    if not f then
        return
    end
    local _, mx = f.StatusBar:GetMinMaxValues()
    local v = f.StatusBar:GetValue()
    local width = math.max(1, math.min(10, 10 * ((v / mx) / 0.1)))
    f.StatusBar.Spark:SetPoint("RIGHT", f.StatusBar, "LEFT", 280 * (v / mx), 0)
    f.StatusBar.Spark:SetWidth(width)
    if f.StatusBar.precentage == nil or f.StatusBar.precentage == false then
        f.StatusBar.progress:SetText(v .. " / " .. mx)
    else
        f.StatusBar.progress:SetText(math.floor((v / mx) * 100) .. "%")
    end
end
GW.AddForProfiling("objectives", "statusBarSetValue", statusBarSetValue)

local function CreateObjectiveNormal(name, parent)
    local f = CreateFrame("Frame", name, parent, "GwQuesttrackerObjectiveNormal")
    f.ObjectiveText:SetFont(UNIT_NAME_FONT, 12)
    f.ObjectiveText:SetShadowOffset(-1, 1)
    f.StatusBar.progress:SetFont(UNIT_NAME_FONT, 11)
    f.StatusBar.progress:SetShadowOffset(-1, 1)
    if f.StatusBar.animationOld == nil then
        f.StatusBar.animationOld = 0
    end
    f.StatusBar:SetScript("OnShow", statusBar_OnShow)
    f.StatusBar:SetScript("OnHide", statusBar_OnHide)
    hooksecurefunc(f.StatusBar, "SetValue", statusBarSetValue)

    return f
end
GW.CreateObjectiveNormal = CreateObjectiveNormal

local function CreateTrackerObject(name, parent)
    local f = CreateFrame("Button", name, parent, "GwQuesttrackerObject")
    f.Header:SetFont(UNIT_NAME_FONT, 14)
    f.SubHeader:SetFont(UNIT_NAME_FONT, 12)
    f.Header:SetShadowOffset(1, -1)
    f.SubHeader:SetShadowOffset(1, -1)
    f:SetScript(
        "OnEnter",
        function(self)
            self.hover:Show()
            if self.objectiveBlocks == nil then
                self.objectiveBlocks = {}
            end
            for _, v in pairs(self.objectiveBlocks) do
                v.StatusBar.progress:Show()
            end
            AddToAnimation(
                self:GetName() .. "hover",
                0,
                1,
                GetTime(),
                0.2,
                function(step)
                    self.hover:SetAlpha(step - 0.3)
                    self.hover:SetTexCoord(0, step, 0, 1)
                end
            )
        end
    )
    f:SetScript(
        "OnLeave",
        function(self)
            self.hover:Hide()
            if self.objectiveBlocks == nil then
                self.objectiveBlocks = {}
            end
            for _, v in pairs(self.objectiveBlocks) do
                v.StatusBar.progress:Hide()
            end
            if animations[self:GetName() .. "hover"] ~= nil then
                animations[self:GetName() .. "hover"]["complete"] = true
            end
        end
    )
    f.clickHeader:SetScript(
        "OnEnter",
        function(self)
            self.oldColor = {}
            self.oldColor.r, self.oldColor.g, self.oldColor.b = self:GetParent().Header:GetTextColor()
            self:GetParent().Header:SetTextColor(self.oldColor.r * 2, self.oldColor.g * 2, self.oldColor.b * 2)
        end
    )
    f.clickHeader:SetScript(
        "OnLeave",
        function(self)
            if self.oldColor == nil then
                return
            end
            self:GetParent().Header:SetTextColor(self.oldColor.r, self.oldColor.g, self.oldColor.b)
        end
    )
    f.turnin:SetScript(
        "OnShow",
        function(self)
            self:SetScript("OnUpdate", wiggleAnim)
        end
    )
    f.turnin:SetScript(
        "OnHide",
        function(self)
            self:SetScript("OnUpdate", nil)
        end
    )

    return f
end
GW.CreateTrackerObject = CreateTrackerObject

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
    self.objectiveBlocks[#self.objectiveBlocks] = newBlock
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
GW.AddForProfiling("objectives", "getObjectiveBlock", getObjectiveBlock)

local function getBlock(blockIndex)
    if _G["GwQuestBlock" .. blockIndex] ~= nil then
        return _G["GwQuestBlock" .. blockIndex]
    end

    local newBlock = CreateTrackerObject("GwQuestBlock" .. blockIndex, GwQuesttrackerContainerQuests)
    newBlock:SetParent(GwQuesttrackerContainerQuests)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerQuests, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwQuestBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end
    newBlock.clickHeader:Show()
    setBlockColor(newBlock, "QUEST")
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    return newBlock
end
GW.AddForProfiling("objectives", "getBlock", getBlock)

local function addObjective(block, text, finished, objectiveIndex, objectiveType)
    if finished == true then
        return
    end
    local objectiveBlock = getObjectiveBlock(block, objectiveIndex)

    if text then
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText(text)
        objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
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
                objectiveBlock.StatusBar.precentage = true
            end
        else
            objectiveBlock.StatusBar:Hide()
        end
        local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
        objectiveBlock:SetHeight(h)
        if objectiveBlock.StatusBar:IsShown() then
            if block.numObjectives >= 1 then
                h = h + objectiveBlock.StatusBar:GetHeight() + 10
            else
                h = h + objectiveBlock.StatusBar:GetHeight() + 5
            end
            objectiveBlock:SetHeight(h)
        end
        block.height = block.height + objectiveBlock:GetHeight()
        block.numObjectives = block.numObjectives + 1
    end
end
GW.AddForProfiling("objectives", "addObjective", addObjective)

local function updateQuestObjective(block, numObjectives)
    local addedObjectives = 1
    local objectives = {}
    for objectiveIndex = 1, numObjectives do
        --local text, _, finished = GetQuestLogLeaderBoard(objectiveIndex, block.questLogIndex)
        objectives = C_QuestLog.GetQuestObjectives(block.questID)
        local text = objectives[objectiveIndex].text
        local objectiveType = objectives[objectiveIndex].type
        local finished = objectives[objectiveIndex].finished
        if not finished then
            addObjective(block, text, finished, addedObjectives, objectiveType)
            addedObjectives = addedObjectives + 1
        end
    end
end
GW.AddForProfiling("objectives", "updateQuestObjective", updateQuestObjective)

local function OnBlockClick(self, button)
    if IsShiftKeyDown() and ChatEdit_GetActiveWindow() then
        if button == "LeftButton" then
            if IsAddOnLoaded("Questie") then
                ChatEdit_InsertLink("[" .. self.title .. " (" .. self.questID .. ")]")
            else
                ChatEdit_InsertLink(gsub(self.title, " *(.*)", "%1"))
            end
        else
            SelectQuestLogEntry(self.questLogIndex)
            local chat = ""
            local numObjectives = GetNumQuestLeaderBoards()
            if numObjectives > 0 then
                for objectiveIndex = 1, numObjectives do
                    local objectiveText = GetQuestLogLeaderBoard(objectiveIndex)
                    chat = chat .. objectiveText
                    if objectiveIndex ~= numObjectives then
                        chat = chat .. ", "
                    end
                end
            else
                local _, objectiveText = GetQuestLogQuestText()
                chat = objectiveText
            end
            ChatEdit_GetActiveWindow():Insert(chat)
        end
        return
    end
    if IsControlKeyDown() then
        local questID = GetQuestIDFromLogIndex(self.questLogIndex)
        for index, value in ipairs(QUEST_WATCH_LIST) do
            if value.id == questID then
                tremove(QUEST_WATCH_LIST, index)
            end
        end
        RemoveQuestWatch(self.questLogIndex)
        QuestWatch_Update()
        QuestLog_Update()
        return
    end

    if IsAddOnLoaded("QuestGuru") then
        QuestLogFrame = QuestGuru
    end
    if button ~= "RightButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if QuestLogFrame:IsShown() and QuestLogFrame.selectedButtonID == self.questLogIndex then
            QuestLogFrame:Hide()
        else
            QuestLogFrame:Show()
            QuestLog_SetSelection(self.questLogIndex)
            QuestLog_Update()
        end
    elseif button == "RightButton" and QuestLogFrame:IsShown() then
        QuestLogFrame:Hide()
    end
end
GW.AddForProfiling("objectives", "OnBlockClick", OnBlockClick)

local function OnBlockClickHandler(self, button)
    if self.questID == nil then
        OnBlockClick(self:GetParent(), button, true)
    else
        OnBlockClick(self, button, false)
    end
end
GW.AddForProfiling("objectives", "OnBlockClickHandler", OnBlockClickHandler)

local function getQuestInfoLevel(questID, block)
    for i = 1, GetNumQuestLogEntries() do
        local _, level, group, _, _, _, _, questID2 = GetQuestLogTitle(i)
        if questID == questID2 then
            block.level = level
            block.group = group
            break
        end
    end
end

local function updateQuest(block, questWatchId)
    block.height = 25
    block.numObjectives = 0
    block.turnin:Hide()

    local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete = GetQuestWatchInfo(questWatchId)

    if questID then
        if savedQuests[questID] == nil then
            NewQuestAnimation(block)
            savedQuests[questID] = true
        end
        block.title = title
        getQuestInfoLevel(questID, block)
        local text = ""
        if block.group == "Elite" then
            text = "[" .. block.level .."|TInterface\\AddOns\\GW2_UI\\textures\\quest-group-icon:12:12:0:0|t] "
        elseif block.group == "Dungeon" then
            text = "[" .. block.level .."|TInterface\\AddOns\\GW2_UI\\textures\\quest-dungeon-icon:12:12:0:0|t] "
        else
            text = "[" .. block.level .."] "
        end
        block.questID = questID
        block.questLogIndex = questLogIndex
        block.Header:SetText(text .. title)

        local rewardXP = GetQuestLogRewardXP and GetQuestLogRewardXP(questID) or nil
        if rewardXP and GetSetting("QUESTTRACKER_SHOW_XP") and GW.mylevel < GetMaxPlayerLevel() then
            block.Header:SetText(text .. title .. " |cFF888888(" .. CommaValue(rewardXP) .. XP .. ")|r")
        end

        if isComplete and isComplete < 0 then
            isComplete = false
        elseif numObjectives == 0 and GetMoney() >= requiredMoney and not startEvent then
            isComplete = true
        end

        updateQuestObjective(block, numObjectives)

        if requiredMoney ~= nil and requiredMoney > GetMoney() then
            addObjective(
                block,
                GetMoneyString(GetMoney()) .. " / " .. GetMoneyString(requiredMoney),
                finished,
                block.numObjectives + 1,
                nil
            )
        end

        if isComplete then
            if isAutoComplete then
                addObjective(block, QUEST_WATCH_CLICK_TO_COMPLETE, false, block.numObjectives + 1, nil)
                block.turnin:Show()
                block.turnin:SetScript(
                    "OnClick",
                    function()
                        ShowQuestComplete(questLogIndex)
                    end
                )
            else
                addObjective(block, QUEST_WATCH_QUEST_READY, false, block.numObjectives + 1, nil)
            end
        end
        block.clickHeader:SetScript("OnClick", OnBlockClickHandler)
        block:SetScript("OnClick", OnBlockClickHandler)
    end
    if block.objectiveBlocks == nil then
        block.objectiveBlocks = {}
    end

    for i = block.numObjectives + 1, 20 do
        if _G[block:GetName() .. "GwQuestObjective" .. i] ~= nil then
            _G[block:GetName() .. "GwQuestObjective" .. i]:Hide()
        end
    end
    block.height = block.height + 5
    block:SetHeight(block.height)
end
GW.AddForProfiling("objectives", "updateQuest", updateQuest)

local function QuestTrackerLayoutChanged()
    local scroll = 0
    local height = GwQuesttrackerContainerQuests:GetHeight() + 60
    local trackerHeight = GetSetting("QuestTracker_pos_height") - GwObjectivesNotification:GetHeight()

    if height > tonumber(trackerHeight) then
        scroll = math.abs(trackerHeight - height)
    end
    GwQuestTrackerScroll.maxScroll = scroll
    GwQuestTrackerScroll:SetSize(GwQuestTracker:GetWidth(), height)
end
GW.QuestTrackerLayoutChanged = QuestTrackerLayoutChanged

local function updateQuestLogLayout(self)
    if self.isUpdating or not self.init then
        return
    end
    self.isUpdating = true

    local savedHeight = 1
    local numQuests = GetNumQuestWatches()
    if numQuests == 0 then GwQuestHeader:Hide() end

    if GwQuesttrackerContainerQuests.collapsed == true then
        GwQuestHeader:Show()
        numQuests = 0
        savedHeight = 20
    end

    for i = 1, numQuests do
        if i == 1 then
            savedHeight = 20
        end
        GwQuestHeader:Show()
        local block = getBlock(i)
        if block == nil then
            return
        end
        updateQuest(block, i)
        block:Show()

        savedHeight = savedHeight + block.height
    end
    GwQuesttrackerContainerQuests:SetHeight(savedHeight)
    for i = numQuests + 1, 25 do
        if _G["GwQuestBlock" .. i] ~= nil then
            _G["GwQuestBlock" .. i]:Hide()
        end
    end

    QuestTrackerLayoutChanged()

    self.isUpdating = false
end
GW.AddForProfiling("objectives", "updateQuestLogLayout", updateQuestLogLayout)

local function tracker_OnEvent(self)
    updateQuestLogLayout(self)
end
GW.AddForProfiling("objectives", "tracker_OnEvent", tracker_OnEvent)

local function tracker_OnUpdate()
    local prevState = GwObjectivesNotification.shouldDisplay

    if GW.locationData.mapID or GW.locationData.instanceMapID then
        GW.SetObjectiveNotification()
    end

    if prevState ~= GwObjectivesNotification.shouldDisplay then
        GW.NotificationStateChanged(GwObjectivesNotification.shouldDisplay)
    end
end
GW.AddForProfiling("objectives", "tracker_OnUpdate", tracker_OnUpdate)

local function AdjustQuestTracker(our_bars, our_minimap)
    if (not our_minimap) then
        return
    end

    local o = QuestWatchFrame
    if (o:IsUserPlaced()) then
        return
    end

    local m = MinimapCluster
    local x

    if (our_bars) then
        x = 310
    else
        x = 220
    end

    o:ClearAllPoints()
    o:SetMovable(true)
    o:SetUserPlaced(true)
    o:SetPoint("TOPRIGHT", m, "BOTTOMRIGHT", x, 0)
    o:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", x, 130)
    o:SetMovable(false)
end
GW.AdjustQuestTracker = AdjustQuestTracker

local function LoadQuestTracker()
    -- disable the default tracker
    QuestWatchFrame:SetMovable(1)
    QuestWatchFrame:SetUserPlaced(true)
    QuestWatchFrame:Hide()
    QuestWatchFrame:SetScript(
        "OnShow",
        function()
            QuestWatchFrame:Hide()
        end
    )

    -- create our tracker
    local fTracker = CreateFrame("Frame", "GwQuestTracker", UIParent, "GwQuestTracker")

    local fTraScr = CreateFrame("ScrollFrame", "GwQuestTrackerScroll", fTracker, "GwQuestTrackerScroll")
    fTraScr:SetScript(
        "OnMouseWheel",
        function(self, delta)
            delta = -delta * 15
            local s = math.max(0, self:GetVerticalScroll() + delta)
            if self.maxScroll ~= nil then
                s = math.min(self.maxScroll, s)
            end
            self:SetVerticalScroll(s)
        end
    )
    fTraScr.maxScroll = 0

    local fScroll = CreateFrame("Frame", "GwQuestTrackerScrollChild", fTraScr, "GwQuestTracker")

    local fNotify = CreateFrame("Frame", "GwObjectivesNotification", fTracker, "GwObjectivesNotification")
    fNotify.animatingState = false
    fNotify.animating = false
    fNotify.title:SetFont(UNIT_NAME_FONT, 14)
    fNotify.title:SetShadowOffset(1, -1)
    fNotify.desc:SetFont(UNIT_NAME_FONT, 12)
    fNotify.desc:SetShadowOffset(1, -1)
    fNotify.compass:SetScript("OnShow", NewQuestAnimation)

    local fQuest = CreateFrame("Frame", "GwQuesttrackerContainerQuests", fScroll, "GwQuesttrackerContainer")

    fQuest:SetParent(fScroll)

    fNotify:SetPoint("TOPRIGHT", fTracker, "TOPRIGHT")

    fTraScr:SetPoint("TOPRIGHT", fNotify, "BOTTOMRIGHT")
    fTraScr:SetPoint("BOTTOMRIGHT", fTracker, "BOTTOMRIGHT")

    fScroll:SetPoint("TOPRIGHT", fTraScr, "TOPRIGHT")
    fQuest:SetPoint("TOPRIGHT", fScroll, "TOPRIGHT")

    fScroll:SetSize(fTracker:GetWidth(), 2)
    fTraScr:SetScrollChild(fScroll)

    fQuest:SetScript("OnEvent", tracker_OnEvent)
    fQuest:RegisterEvent("QUEST_LOG_UPDATE")
    fQuest:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    fQuest:RegisterEvent("QUEST_ITEM_UPDATE")
    fQuest:RegisterEvent("QUEST_REMOVED")
    fQuest:RegisterEvent("TASK_PROGRESS_UPDATE")
    fQuest:RegisterEvent("QUEST_AUTOCOMPLETE")
    fQuest:RegisterEvent("QUEST_ACCEPTED")
    fQuest:RegisterEvent("QUEST_GREETING")
    fQuest:RegisterEvent("QUEST_DETAIL")
    fQuest:RegisterEvent("QUEST_PROGRESS")
    fQuest:RegisterEvent("QUEST_COMPLETE")
    fQuest:RegisterEvent("QUEST_FINISHED")
    fQuest:RegisterEvent("PLAYER_MONEY")
    fQuest:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED")
    fQuest:RegisterEvent("PLAYER_REGEN_ENABLED")

    local header = CreateFrame("Button", "GwQuestHeader", fQuest, "GwQuestTrackerHeader")
    header.icon:SetTexCoord(0, 1, 0.25, 0.5)
    header.title:SetFont(UNIT_NAME_FONT, 14)
    header.title:SetShadowOffset(1, -1)
    header.title:SetText(QUESTS_LABEL)

    header:SetScript(
        "OnMouseDown",
        function(self)
            local p = self:GetParent()
            if not p.collapsed then
                p.collapsed = true
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            else
                p.collapsed = false
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end
            updateQuestLogLayout(p)
            QuestTrackerLayoutChanged()
        end
    )
    header.title:SetTextColor(
        TRACKER_TYPE_COLOR["QUEST"].r,
        TRACKER_TYPE_COLOR["QUEST"].g,
        TRACKER_TYPE_COLOR["QUEST"].b
    )

    fQuest.init = false
    tracker_OnEvent(fQuest)
    fQuest.init = true

    fNotify.shouldDisplay = false

    -- only update the tracker on Events or if player moves
    local compassUpdateFrame = CreateFrame("Frame")
    compassUpdateFrame:RegisterEvent("PLAYER_STARTED_MOVING")
    compassUpdateFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
    compassUpdateFrame:RegisterEvent("PLAYER_CONTROL_LOST")
    compassUpdateFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
    compassUpdateFrame:RegisterEvent("QUEST_LOG_UPDATE")
    compassUpdateFrame:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    compassUpdateFrame:RegisterEvent("PLAYER_MONEY")
    compassUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    compassUpdateFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    compassUpdateFrame:SetScript("OnEvent", function(self, event, ...)
        -- Events for start updating
        if GW.IsIn(event, "PLAYER_STARTED_MOVING", "PLAYER_CONTROL_LOST") then
            self.Ticker = C_Timer.NewTicker(1, function() tracker_OnUpdate() end)
        elseif GW.IsIn(event, "PLAYER_STOPPED_MOVING", "PLAYER_CONTROL_GAINED") then -- Events for stop updating
            if self.Ticker then
                self.Ticker:Cancel()
                self.Ticker = nil
            end
        elseif event == "QUEST_DATA_LOAD_RESULT" then
            local questID, success = ...
            if success and GwObjectivesNotification.compass.dataIndex and questID == GwObjectivesNotification.compass.dataIndex then
                tracker_OnUpdate()
            end
        else
            C_Timer.After(0.25, function() tracker_OnUpdate() end)
        end
    end)

    GW.RegisterMovableFrame(fTracker, OBJECTIVES_TRACKER_LABEL, "QuestTracker_pos", "VerticalActionBarDummy", {350, 10}, true, {"scaleable", "height"})
    fTracker:ClearAllPoints()
    fTracker:SetPoint("TOPLEFT", fTracker.gwMover)
    fTracker:SetHeight(GetSetting("QuestTracker_pos_height"))
end
GW.LoadQuestTracker = LoadQuestTracker