local _, GW = ...
local L = GW.L
local lerp = GW.lerp
local GetSetting = GW.GetSetting
local CommaValue = GW.CommaValue
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local tomTomWaypoint = nil

local function AddTomTomWaypoint(questId, objective)
    if TomTom and TomTom.AddWaypoint and Questie and Questie.started then
        local QuestieQuest = QuestieLoader:ImportModule("QuestieDB").GetQuest(questId)
        local spawn, zone, name = QuestieLoader:ImportModule("QuestieMap"):GetNearestQuestSpawn(QuestieQuest)
        if (not spawn) and objective ~= nil then
            spawn, zone, name = QuestieMap:GetNearestSpawn(objective)
        end
        if spawn then
            if tomTomWaypoint and TomTom.RemoveWaypoint then -- remove old waypoint
                TomTom:RemoveWaypoint(tomTomWaypoint)
            end
            local uiMapId = QuestieLoader:ImportModule("ZoneDB"):GetUiMapIdByAreaId(zone)
            tomTomWaypoint = TomTom:AddWaypoint(uiMapId, spawn[1] / 100, spawn[2] / 100,  {title = name, crazy = true})
        end
    end
end

local function LinkQuestIntoChat(title, questId)
    if not ChatFrame1EditBox:IsVisible() then
        if Questie and Questie.started then
            ChatFrame_OpenChat("[" .. title .. " (" .. questId .. ")]")
        else
            ChatFrame_OpenChat(gsub(title, " *(.*)", "%1"))
        end
    else
        if Questie and Questie.started then
            ChatEdit_InsertLink("[" .. title .. " (" .. questId .. ")]")
        else
            ChatEdit_InsertLink(gsub(title, " *(.*)", "%1"))
        end
    end
end

local function UntrackQuest(questLogIndex)
    local questID = GetQuestIDFromLogIndex(questLogIndex)
    for index, value in ipairs(QUEST_WATCH_LIST) do
        if value.id == questID then
            tremove(QUEST_WATCH_LIST, index)
        end
    end
    RemoveQuestWatch(questLogIndex)
    WatchFrame_Update()
    QuestLog_Update()
end

local function IsQuestAutoTurnInOrAutoAccept(blockQuestID, checkType)
    for i = 1, GetNumAutoQuestPopUps() do
        local questID, popUpType = GetAutoQuestPopUp(i)
        if blockQuestID and questID and popUpType and popUpType == checkType and blockQuestID == questID then
            return true
        end
    end

    return false
end

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
            local prog = animations[self:GetName()].progress

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
        if totalQuantity == 0 then
            return string.format("%d %s", quantity, criteriaString)
        else
            return string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
        end
    end

    return criteriaString
end
GW.ParseCriteria = ParseCriteria

local function ParseObjectiveString(block, text, objectiveType, quantity, numItems, numNeeded, overrideShowStatusbarSetting)
    if objectiveType == "progressbar" then
        block.StatusBar:SetMinMaxValues(0, 100)
        block.StatusBar:SetValue(quantity or 0)
        block.StatusBar:SetShown(overrideShowStatusbarSetting or GW.GetSetting("QUESTTRACKER_STATUSBARS_ENABLED"))
        block.StatusBar.precentage = true
        return true
    end
    block.StatusBar.precentage = false

    local numItems, numNeeded = numItems, numNeeded
    if not numItems and not numNeeded then
        _, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)")
        if numItems == nil then
            numItems, numNeeded, _ = string.match(text, "(%d+)/(%d+) (%S+)")
        end
    end
    numItems = tonumber(numItems)
    numNeeded = tonumber(numNeeded)

    if numItems and numNeeded and numNeeded > 1 and numItems < numNeeded then
        block.StatusBar:SetShown(overrideShowStatusbarSetting or GW.GetSetting("QUESTTRACKER_STATUSBARS_ENABLED"))
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
GW.setBlockColor = setBlockColor

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

local function blockOnEnter(self)
    if not self.hover then
        self.oldColor = {}
        self.oldColor.r, self.oldColor.g, self.oldColor.b = self:GetParent().Header:GetTextColor()
        self:GetParent().Header:SetTextColor(self.oldColor.r * 2, self.oldColor.g * 2, self.oldColor.b * 2)

        self = self:GetParent()
    end

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
            self.hover:SetAlpha(math.max((step - 0.3), 0))
            self.hover:SetTexCoord(0, step, 0, 1)
        end
    )
    if self.event then
        BonusObjectiveTracker_ShowRewardsTooltip(self)
    end
end

local function blockOnLeave(self)
    if not self.hover then
        if self.oldColor ~= nil then
            self:GetParent().Header:SetTextColor(self.oldColor.r, self.oldColor.g, self.oldColor.b)
        end

        self = self:GetParent()
    end

    self.hover:Hide()
    if self.objectiveBlocks == nil then
        self.objectiveBlocks = {}
    end
    for _, v in pairs(self.objectiveBlocks) do
        v.StatusBar.progress:Hide()
    end
    if animations[self:GetName() .. "hover"] then
        animations[self:GetName() .. "hover"].complete = true
    end
    GameTooltip_Hide()
end

local function CreateTrackerObject(name, parent)
    local f = CreateFrame("Button", name, parent, "GwQuesttrackerObject")
    f.Header:SetFont(UNIT_NAME_FONT, 14)
    f.SubHeader:SetFont(UNIT_NAME_FONT, 12)
    f.Header:SetShadowOffset(1, -1)
    f.SubHeader:SetShadowOffset(1, -1)
    f:SetScript("OnEnter", blockOnEnter)
    f:SetScript("OnLeave", blockOnLeave)
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
    f.turnin:SetScript("OnClick",function(self)
        ShowQuestComplete(self:GetParent().id)
        RemoveAutoQuestPopUp(self:GetParent().id)
        self:Hide()
    end)
    f.popupQuestAccept:SetScript(
        "OnShow",
        function(self)
            self:SetScript("OnUpdate", wiggleAnim)
        end
    )
    f.popupQuestAccept:SetScript(
        "OnHide",
        function(self)
            self:SetScript("OnUpdate", nil)
        end
    )
    f.popupQuestAccept:SetScript("OnClick", function(self)
        ShowQuestOffer(self:GetParent().id)
        RemoveAutoQuestPopUp(self:GetParent().id)
        self:Hide()
    end)

    f.turnin:SetScale(GwQuestTracker:GetScale() * 0.9)
    f.popupQuestAccept:SetScale(GwQuestTracker:GetScale() * 0.9)

    -- hooks for scaling
    hooksecurefunc(GwQuestTracker, "SetScale", function(_, scale)
        f.turnin:SetScale(scale * 0.9)
        f.popupQuestAccept:SetScale(scale * 0.9)
    end)

    return f
end
GW.CreateTrackerObject = CreateTrackerObject

local function getBlockById(questID)
    for i = 1, 25 do
        local block = _G["GwQuestBlock" .. i]
        if block then
            if block.questID == questID then
                return block
            end
        end
    end

    return nil
end

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

local function getBlockQuest(blockIndex, isFrequency)
    if _G["GwQuestBlock" .. blockIndex] then
        local block = _G["GwQuestBlock" .. blockIndex]
        -- set the correct block color for an existing block here
        setBlockColor(block, isFrequency and "DAILY" or "QUEST")
        block.Header:SetTextColor(block.color.r, block.color.g, block.color.b)
        block.hover:SetVertexColor(block.color.r, block.color.g, block.color.b)
        for i = 1, 20 do
            if _G[block:GetName() .. "GwQuestObjective" .. i] then
                _G[block:GetName() .. "GwQuestObjective" .. i].StatusBar:SetStatusBarColor(block.color.r, block.color.g, block.color.b)
            end
        end
        return block
    end

    local newBlock = CreateTrackerObject("GwQuestBlock" .. blockIndex, GwQuesttrackerContainerQuests)
    newBlock:SetParent(GwQuesttrackerContainerQuests)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerQuests, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwQuestBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end

    newBlock.index = blockIndex
    setBlockColor(newBlock, isFrequency and "DAILY" or "QUEST")
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)

    -- quest item button here
    newBlock.actionButton = CreateFrame("Button", nil, GwQuestTracker, "GwQuestItemTemplate")
    newBlock.actionButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    newBlock.actionButton.NormalTexture:SetTexture(nil)
    newBlock.actionButton:RegisterForClicks("AnyUp", "AnyDown")
    newBlock.actionButton:SetScript("OnShow", QuestObjectiveItem_OnShow)
    newBlock.actionButton:SetScript("OnHide", QuestObjectiveItem_OnHide)
    newBlock.actionButton:SetScript("OnEnter", QuestObjectiveItem_OnEnter)
    newBlock.actionButton:SetScript("OnLeave", GameTooltip_Hide)
    newBlock.actionButton:SetScript("OnEvent", QuestObjectiveItem_OnEvent)

    return newBlock
end
GW.AddForProfiling("objectives", "getBlockQuest", getBlockQuest)

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
                objectiveBlock.StatusBar:SetShown(GW.GetSetting("QUESTTRACKER_STATUSBARS_ENABLED"))
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
        objectives = C_QuestLog.GetQuestObjectives(block.questID)
        if not objectives[objectiveIndex].finished then
            addObjective(block, objectives[objectiveIndex].text, objectives[objectiveIndex].finished, addedObjectives, objectives[objectiveIndex].type)
            addedObjectives = addedObjectives + 1
        end
    end
end
GW.AddForProfiling("objectives", "updateQuestObjective", updateQuestObjective)

local function UpdateQuestItem(block)
    local link, item, charges, showItemWhenComplete = nil, nil, nil, false

    if block.questLogIndex then
        link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(block.questLogIndex)
    end

    local shouldShowItem = item and (not block.isComplete or showItemWhenComplete)
    if shouldShowItem then
        block.hasItem = true
        block.actionButton:SetID(block.questLogIndex)

        block.actionButton:SetAttribute("type", "item")
        block.actionButton:SetAttribute("item", link)

        block.actionButton.charges = charges
        block.actionButton.rangeTimer = -1
        SetItemButtonTexture(block.actionButton, item)
        SetItemButtonCount(block.actionButton, charges)

        QuestObjectiveItem_UpdateCooldown(block.actionButton)
        block.actionButton:SetScript("OnUpdate", WatchFrameItem_OnUpdate)
        block.actionButton:Show()
    else
        block.hasItem = false
        block.actionButton:Hide()
        block.actionButton:SetScript("OnUpdate", nil)
    end
end

local function updateQuestItemPositions(button, height, type, block)
    if not button or not block.hasItem then
        return
    end

    local height = height + (GwQuesttrackerContainerScenario and GwQuesttrackerContainerScenario:GetHeight() or 0) + GwQuesttrackerContainerAchievement:GetHeight() + GwQuesttrackerContainerBossFrames:GetHeight() + GwQuesttrackerContainerArenaBGFrames:GetHeight()
    if GwObjectivesNotification:IsShown() then
        height = height + GwObjectivesNotification.desc:GetHeight()
    else
        height = height - 40
    end
    if type == "SCENARIO" then
        height = height - (GwQuesttrackerContainerAchievement:GetHeight() + GwQuesttrackerContainerBossFrames:GetHeight() + GwQuesttrackerContainerArenaBGFrames:GetHeight())
    end
    if type == "EVENT" then
        height = height + GwQuesttrackerContainerQuests:GetHeight()
    end
    if (type == "QUEST" or type == "EVENT") and GwQuesttrackerContainerCampaign then
        height = height + GwQuesttrackerContainerCampaign:GetHeight()
    end

    button:SetPoint("TOPLEFT", GwQuestTracker, "TOPRIGHT", -330, -height)
end
GW.AddForProfiling("objectives", "updateQuestItemPositions", updateQuestItemPositions)

local function OnBlockClick(self, button)
    if button == "RightButton" then
        local menuList = {{text = self.title, isTitle = true, notCheckable = true}}
        local subMenu = {}

        -- if we have objectives, we add them needs Questi
        if Questie and Questie.started then
            local QuestieQuest = QuestieLoader:ImportModule("QuestieDB").GetQuest(self.questID)
            for _, objective in pairs(QuestieQuest.Objectives) do
                local objectiveMenu = {}

                if TomTom and TomTom.AddWaypoint and Questie and Questie.started then
                    tinsert(objectiveMenu, {text = L["Set TomTom Target"], hasArrow = false, notCheckable = true, func = function() AddTomTomWaypoint(self.questID, objective) end})
                end

                tinsert(objectiveMenu, {text = L["Show on Map"], notCheckable = true, func = function()
                    QuestieLoader:ImportModule("TrackerUtils"):ShowObjectiveOnMap(objective)
                end})

                tinsert(subMenu, {text = objective.Description, hasArrow = true, notCheckable = true, menuList = objectiveMenu})
            end

            if next(QuestieQuest.SpecialObjectives) then
                for _, objective in pairs(QuestieQuest.SpecialObjectives) do
                    local objectiveMenu = {}

                    if TomTom and TomTom.AddWaypoint and Questie and Questie.started then
                        tinsert(objectiveMenu, {text = L["Set TomTom Target"], hasArrow = false, notCheckable = true, func = function() AddTomTomWaypoint(self.questID, objective) end})
                    end

                    tinsert(objectiveMenu, {text = L["Show on Map"], notCheckable = true, func = function()
                        QuestieLoader:ImportModule("TrackerUtils"):ShowObjectiveOnMap(objective)
                    end})

                    tinsert(subMenu, {text = objective.Description, hasArrow = true, notCheckable = true, menuList = objectiveMenu})
                end
            end

            if QuestieQuest:IsComplete() == 0 then
                tinsert(menuList, { text = OBJECTIVES_TRACKER_LABEL, hasArrow = true, notCheckable = true, menuList = subMenu})
            end
        end

        tinsert(menuList, {text = COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, hasArrow = false, notCheckable = true, func = function() LinkQuestIntoChat(self.title, self.questID) end})
        tinsert(menuList, {text = "Wowhead URL", hasArrow = false, notCheckable = true, func = function() StaticPopup_Show("GW2_WOWHEAD_URL", self.questID, self.title) end})
        tinsert(menuList, {text = OBJECTIVES_VIEW_IN_QUESTLOG, notCheckable = true, func = function() QuestLogFrame:Show()
            QuestLog_SetSelection(self.questLogIndex)
            QuestLog_Update() end})

        if TomTom and TomTom.AddWaypoint and Questie and Questie.started then
            tinsert(menuList, {text = L["Set TomTom Target"], hasArrow = false, notCheckable = true, func = function() AddTomTomWaypoint(self.questID, nil) end})
        end

        if Questie and Questie.started and self.isComplete then
            tinsert(menuList, {text = L["Show on Map"], notCheckable = true, func = function()
                local QuestieQuest = QuestieLoader:ImportModule("QuestieDB").GetQuest(self.questID)
                QuestieLoader:ImportModule("TrackerUtils"):ShowFinisherOnMap(QuestieQuest)
            end})
        end

        tinsert(menuList, {text = UNTRACK_QUEST, hasArrow = false, notCheckable = true, func = function() UntrackQuest(self.questLogIndex) end})

        GW.SetEasyMenuAnchor(GW.EasyMenu, self)
        EasyMenu(menuList, GW.EasyMenu, nil, nil, nil, "MENU")
        return
    end

    if IsShiftKeyDown() and ChatEdit_GetActiveWindow() then
        if button == "LeftButton" then
            LinkQuestIntoChat(self.title, self.questID)
        end
        return
    elseif IsControlKeyDown() then
        if button == "LeftButton" then
            AddTomTomWaypoint(self.questID, nil)
        else
            UntrackQuest(self.questLogIndex)
        end
        return
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
    end
end
GW.AddForProfiling("objectives", "OnBlockClick", OnBlockClick)

local function OnBlockClickHandler(self, button)
    OnBlockClick(self, button)
end
GW.AddForProfiling("objectives", "OnBlockClickHandler", OnBlockClickHandler)

local function AddQuestInfos(questLogIndex, watchId)
    local title, level, group, _, _, isComplete, frequency, questId, startEvent = GetQuestLogTitle(questLogIndex)
    if title and questId then
        local isFailed = false

        if isComplete == nil then
            isComplete = false
        elseif isComplete == 1 then
            isComplete = true
        else
            isComplete = false
            isFailed = true
        end

        return {
            questId = questId,
            questWatchedId = watchId or 0,
            questLogIndex = questLogIndex,
            questLevel = level,
            questGroup = group,
            title = title,
            isComplete = isComplete,
            startEvent = startEvent,
            numObjectives = GetNumQuestLeaderBoards(questLogIndex),
            requiredMoney = GetQuestLogRequiredMoney(questId),
            isAutoComplete = false,
            isFailed = isFailed,
            isFrequency = frequency and frequency > 1
        }
    else
        return nil
    end
end

local function updateQuest(self, block, quest)
    block.height = 25
    block.numObjectives = 0
    block.turnin:SetShown(IsQuestAutoTurnInOrAutoAccept(quest.questId, "COMPLETE"))
    block.popupQuestAccept:SetShown(IsQuestAutoTurnInOrAutoAccept(quest.questId, "OFFER"))

    if quest.questId and quest.questLogIndex and quest.questLogIndex > 0 then
        block.questID = quest.questId
        block.id = quest.questId
        block.questLogIndex = quest.questLogIndex
        block.isComplete = quest.isComplete
        block.title = quest.title
        local text = ""
        if quest.questGroup == "Elite" then
            text = "[" .. quest.questLevel .. "|TInterface/AddOns/GW2_UI/textures/icons/quest-group-icon:12:12:0:0|t] "
        elseif quest.questGroup == "Dungeon" then
            text = "[" .. quest.questLevel .. "|TInterface/AddOns/GW2_UI/textures/icons/quest-dungeon-icon:12:12:0:0|t] "
        elseif quest.questGroup then
            text = "[" .. quest.questLevel .. "+] "
        else
            text = "[" .. quest.questLevel .. "] "
        end
        block.Header:SetText(text .. quest.title)

        --Quest item
        GW.CombatQueue_Queue(nil, UpdateQuestItem, {block})

        if quest.numObjectives == 0 and GetMoney() >= quest.requiredMoney and not quest.startEvent then
            quest.isComplete = true
        end

        updateQuestObjective(block, quest.numObjectives)

        if quest.requiredMoney ~= nil and quest.requiredMoney > GetMoney() then
            addObjective(
                block,
                GetMoneyString(GetMoney()) .. " / " .. GetMoneyString(quest.requiredMoney),
                quest.isComplete,
                block.numObjectives + 1,
                nil
            )
        end

        if quest.isComplete then
            if quest.isAutoComplete then
                addObjective(block, QUEST_WATCH_CLICK_TO_COMPLETE, false, block.numObjectives + 1, nil)
            else
                local completionText = GetQuestLogCompletionText(quest.questLogIndex)

                if (completionText) then
                    addObjective(block, completionText, false, block.numObjectives + 1, nil)
                else
                    addObjective(block, QUEST_WATCH_QUEST_READY, false, block.numObjectives + 1, nil)
                end
            end
        elseif quest.isFailed then
            addObjective(block, FAILED, false, block.numObjectives + 1, nil)
        end
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
    local height = GwQuesttrackerContainerQuests:GetHeight() + GwQuesttrackerContainerAchievement:GetHeight() + 60
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

    local savedHeightQuest = 1
    local counterQuest = 0
    local shouldShowQuests = true
    local numQuests = GetNumQuestWatches()

    self.header:Hide()

    if self.collapsed then
        self.header:Show()
        savedHeightQuest = 20
        shouldShowQuests = false
    end

    -- collect quests here
    local sorted = {}

    for i = 1, numQuests do
        local questLogIndex = GetQuestIndexForWatch(i)
        if questLogIndex then
            local quest = AddQuestInfos(questLogIndex, i)
            if quest then table.insert(sorted, quest) end
        end
    end

    if GetSetting("QUESTTRACKER_SORTING") == "LEVEL" then
        -- Sort by level
        table.sort(sorted, function(a, b)
            return a and b and a.questLevel < b.questLevel
        end)
    elseif GetSetting("QUESTTRACKER_SORTING") == "ZONE" then
        -- Sort by Zone
        if Questie and Questie.started and QuestieLoader then
            local QuestieTrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
            local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
            if QuestieTrackerUtils and QuestieDB then
                table.sort(sorted, function(a, b)
                    local qA = QuestieDB.GetQuest(a.questId)
                    local qB = QuestieDB.GetQuest(b.questId)
                    local qAZone, qBZone
                    if qA.zoneOrSort > 0 then
                        qAZone = QuestieTrackerUtils:GetZoneNameByID(qA.zoneOrSort)
                    elseif qA.zoneOrSort < 0 then
                        qAZone = QuestieTrackerUtils:GetCategoryNameByID(qA.zoneOrSort)
                    else
                        qAZone = tostring(qA.zoneOrSort)
                    end

                    if qB.zoneOrSort > 0 then
                        qBZone = QuestieTrackerUtils:GetZoneNameByID(qB.zoneOrSort)
                    elseif qB.zoneOrSort < 0 then
                        qBZone = QuestieTrackerUtils:GetCategoryNameByID(qB.zoneOrSort)
                    else
                        qBZone = tostring(qB.zoneOrSort)
                    end

                    -- Sort by Zone then by Level to mimic QuestLog sorting
                    if qAZone == qBZone then
                        return qA.level < qB.level
                    else
                        if qAZone ~= nil and qBZone ~= nil then
                            return qAZone < qBZone
                        else
                            return qAZone and qBZone
                        end
                    end
                end)
            end
        end
    end

    for _, quest in pairs(sorted) do
        if shouldShowQuests then
            self.header:Show()
            counterQuest = counterQuest + 1

            if counterQuest == 1 then
                savedHeightQuest = 20
            end

            local block = getBlockQuest(counterQuest, quest.isFrequency)
            if block == nil then
                return
            end
            updateQuest(self, block, quest)
            block.isFrequency = quest.isFrequency
            block:Show()
            savedHeightQuest = savedHeightQuest + block.height

            block.savedHeight = savedHeightQuest
            GW.CombatQueue_Queue("update_tracker_quest_itembutton_position" .. block.index, updateQuestItemPositions, {block.actionButton, savedHeightQuest, nil, block})
        else
            counterQuest = counterQuest + 1
            if _G["GwQuestBlock" .. counterQuest] then
                _G["GwQuestBlock" .. counterQuest]:Hide()
                _G["GwQuestBlock" .. counterQuest].questLogIndex = 0
                GW.CombatQueue_Queue("update_tracker_quest_itembutton_remove" .. counterQuest, UpdateQuestItem, {_G["GwQuestBlock" .. counterQuest]})
            end
        end
    end

    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(counterQuest > 0 and savedHeightQuest or 1)

    self.numQuests = counterQuest

    for i = counterQuest + 1, 25 do
        if _G["GwQuestBlock" .. i] then
            _G["GwQuestBlock" .. i].questID = nil
            _G["GwQuestBlock" .. i].questLogIndex = 0
            _G["GwQuestBlock" .. i]:Hide()
            GW.CombatQueue_Queue("update_tracker_quest_itembutton_remove" .. i, UpdateQuestItem, {_G["GwQuestBlock" .. i]})
        end
    end

    self.header.title:SetText(TRACKER_HEADER_QUESTS .. " (" .. counterQuest .. ")")
    self.isUpdating = false
end
GW.AddForProfiling("objectives", "updateQuestLogLayout", updateQuestLogLayout)

local function checkForAutoQuests()
    for i = 1, GetNumAutoQuestPopUps() do
        local questID, popUpType = GetAutoQuestPopUp(i)
        if questID and (popUpType == "OFFER" or popUpType == "COMPLETE") then
            --find our block with that questId
            local questBlock = getBlockById(questID)
            if questBlock then
                if popUpType == "OFFER" then
                    questBlock.popupQuestAccept:Show()
                elseif popUpType == "COMPLETE" then
                    questBlock.turnin:Show()
                end
            end
        end
    end
end

local function tracker_OnEvent(self, event, ...)
    if event == "LOAD" then
        updateQuestLogLayout(self)
        self.init = true
    else
        updateQuestLogLayout(self)
    end

    checkForAutoQuests()
    QuestTrackerLayoutChanged()
end
GW.UpdateQuestTracker = tracker_OnEvent
GW.AddForProfiling("objectives", "tracker_OnEvent", tracker_OnEvent)



local function tracker_OnUpdate()
    local prevState = GwObjectivesNotification.shouldDisplay

    if GW.Libs.GW2Lib:GetPlayerLocationMapID() or GW.Libs.GW2Lib:GetPlayerInstanceMapID() then
        GW.SetObjectiveNotification()
    end

    if prevState ~= GwObjectivesNotification.shouldDisplay then
        GW.NotificationStateChanged(GwObjectivesNotification.shouldDisplay)
    end
end
GW.forceCompassHeaderUpdate = tracker_OnUpdate
GW.AddForProfiling("objectives", "tracker_OnUpdate", tracker_OnUpdate)

local function AdjustItemButtonPositions()
    for i = 1, 25 do
        if _G["GwQuestBlock" .. i] then
            if i <= GwQuesttrackerContainerQuests.numQuests then
                GW.CombatQueue_Queue("update_tracker_quest_itembutton_position" .. _G["GwQuestBlock" .. i].index, updateQuestItemPositions, {_G["GwQuestBlock" .. i].actionButton, _G["GwQuestBlock" .. i].savedHeight, "QUEST", _G["GwQuestBlock" .. i]})
            else
                GW.CombatQueue_Queue("update_tracker_quest_itembutton_remove" .. i, UpdateQuestItem, {_G["GwQuestBlock" .. i]})
            end
        end
    end

end

local function CollapseHeader(self, forceCollapse, forceOpen)
    if (not self.collapsed or forceCollapse) and not forceOpen then
        self.collapsed = true
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        self.collapsed = false
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    updateQuestLogLayout(self)
    QuestTrackerLayoutChanged()
end
GW.CollapseQuestHeader = CollapseHeader

local function AdjustQuestTracker(our_bars, our_minimap)
    if (not our_minimap) then
        return
    end

    local o = WatchFrame
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
    WatchFrame:SetMovable(1)
    WatchFrame:SetUserPlaced(true)
    WatchFrame:GwKill()
    WatchFrame:SetScript(
        "OnShow",
        function()
            WatchFrame:Hide()
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
    fNotify.bonusbar.bar:SetOrientation("VERTICAL")
    fNotify.bonusbar.bar:SetMinMaxValues(0, 1)
    fNotify.bonusbar.bar:SetValue(0.5)
    fNotify.bonusbar:SetScript("OnEnter", bonus_OnEnter)
    fNotify.bonusbar:SetScript("OnLeave", GameTooltip_Hide)
    fNotify.compass:SetScript("OnShow", NewQuestAnimation)

    local fBoss = CreateFrame("Frame", "GwQuesttrackerContainerBossFrames", fTracker, "GwQuesttrackerContainer")
    local fArenaBG = CreateFrame("Frame", "GwQuesttrackerContainerArenaBGFrames", fTracker, "GwQuesttrackerContainer")
    local fAchv = CreateFrame("Frame", "GwQuesttrackerContainerAchievement", fTracker, "GwQuesttrackerContainer")
    local fQuest = CreateFrame("Frame", "GwQuesttrackerContainerQuests", fScroll, "GwQuesttrackerContainer")

    fNotify:SetParent(fTracker)
    fBoss:SetParent(fTracker)
    fArenaBG:SetParent(fTracker)
    fQuest:SetParent(fScroll)
    fAchv:SetParent(fScroll)

    fNotify:SetPoint("TOPRIGHT", fTracker, "TOPRIGHT")
    fBoss:SetPoint("TOPRIGHT", fNotify, "BOTTOMRIGHT")
    fArenaBG:SetPoint("TOPRIGHT", fBoss, "BOTTOMRIGHT")

    fTraScr:SetPoint("TOPRIGHT", fArenaBG, "BOTTOMRIGHT")
    fTraScr:SetPoint("BOTTOMRIGHT", fTracker, "BOTTOMRIGHT")

    fScroll:SetPoint("TOPRIGHT", fTraScr, "TOPRIGHT")
    fAchv:SetPoint("TOPRIGHT", fScroll, "TOPRIGHT")
    fQuest:SetPoint("TOPRIGHT", fAchv, "BOTTOMRIGHT")

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

    fQuest.header = CreateFrame("Button", nil, fQuest, "GwQuestTrackerHeader")
    fQuest.header.icon:SetTexCoord(0, 0.5, 0.25, 0.5)
    fQuest.header.title:SetFont(UNIT_NAME_FONT, 14)
    fQuest.header.title:SetShadowOffset(1, -1)
    fQuest.header.title:SetText(TRACKER_HEADER_QUESTS)

    fQuest.collapsed = false

    fQuest.header:SetScript("OnMouseDown",
        function(self)
            CollapseHeader(self:GetParent(), false, false)
        end
    )
    fQuest.header.title:SetTextColor(TRACKER_TYPE_COLOR.QUEST.r, TRACKER_TYPE_COLOR.QUEST.g, TRACKER_TYPE_COLOR.QUEST.b)

    fQuest.init = false
    tracker_OnEvent(fQuest, "LOAD")

    if not C_AddOns.IsAddOnLoaded("sArena") then
        GW.LoadArenaFrame(fArenaBG)
    end

    GW.LoadBossFrame()
    GW.LoadAchievementFrame()

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
            if self.Ticker then
                self.Ticker:Cancel()
                self.Ticker = nil
            end
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

    GW.RegisterMovableFrame(fTracker, OBJECTIVES_TRACKER_LABEL, "QuestTracker_pos", ALL, nil, {"scaleable", "height"})
    fTracker:ClearAllPoints()
    fTracker:SetPoint("TOPLEFT", fTracker.gwMover)
    fTracker:SetHeight(GetSetting("QuestTracker_pos_height"))

    local baseQLTB_OnClick = QuestLogTitleButton_OnClick
    QuestLogTitleButton_OnClick = function(self, button) -- I wanted to use hooksecurefunc but this needs to be a pre-hook to work properly unfortunately
        if (not self) or self.isHeader or not IsShiftKeyDown() then baseQLTB_OnClick(self, button) return end
        local questLogLineIndex = self:GetID()

        if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
            local questId = GetQuestIDFromLogIndex(questLogLineIndex)
            ChatEdit_InsertLink("["..gsub(self:GetText(), " *(.*)", "%1").." ("..questId..")]")
        else
            if GetNumQuestLeaderBoards(questLogLineIndex) == 0 and not IsQuestWatched(questLogLineIndex) then -- only call if we actually want to fix this quest (normal quests already call AQW_insert)
                WatchFrame_Update()
                QuestLog_SetSelection(questLogLineIndex)
                QuestLog_Update()
            else
                baseQLTB_OnClick(self, button)
            end
        end
    end

    -- some hooks to set the itembuttons correct
    local UpdateItemButtonPositionAndAdjustScrollFrame = function()
        GW.Debug("Update Quest Buttons")
        QuestTrackerLayoutChanged()
        AdjustItemButtonPositions()
    end

    fBoss.oldHeight = 1
    fArenaBG.oldHeight = 1
    fAchv.oldHeight = 1
    fQuest.oldHeight = 1

    hooksecurefunc(fBoss, "SetHeight", function(_, height)
        if fBoss.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)
    hooksecurefunc(fArenaBG, "SetHeight", function(_, height)
        if fArenaBG.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)
    hooksecurefunc(fAchv, "SetHeight", function(_, height)
        if fAchv.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)
    hooksecurefunc(fQuest, "SetHeight", function(_, height)
        if fQuest.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)

    fNotify:HookScript("OnShow", function() C_Timer.After(0.25, function() UpdateItemButtonPositionAndAdjustScrollFrame() end) end)
    fNotify:HookScript("OnHide", function() C_Timer.After(0.25, function() UpdateItemButtonPositionAndAdjustScrollFrame() end) end)

    -- Update all quests if questue is loaded
    local QuestieInit = QuestieLoader and QuestieLoader:ImportModule("QuestieInit")
    if QuestieInit then
        C_Timer.After(10, function()
            UpdateItemButtonPositionAndAdjustScrollFrame()
        end)
    end
end
GW.LoadQuestTracker = LoadQuestTracker