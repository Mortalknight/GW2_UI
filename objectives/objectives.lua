local _, GW = ...
local RoundDec = GW.RoundDec
local lerp = GW.lerp
local GetSetting = GW.GetSetting
local CommaValue = GW.CommaValue
--local NotificationStateChanged = GW.NotificationStateChanged
--local SetObjectiveNotification = GW.SetObjectiveNotification
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local savedQuests = {}
local mapID = ""
local updateCap = 1 / 5

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

local function loadQuestButtons()
    local actionButton
    for i = 1, 25 do
        actionButton = CreateFrame("Button", "GwQuestItemButton" .. i, GwQuestTracker, "GwQuestItemTemplate")
        actionButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        actionButton.NormalTexture:SetTexture(nil)
        actionButton:RegisterForClicks("AnyUp")
        actionButton:SetScript("OnShow", QuestObjectiveItem_OnShow)
        actionButton:SetScript("OnHide", QuestObjectiveItem_OnHide)
        actionButton:SetScript("OnEnter", QuestObjectiveItem_OnEnter)
        actionButton:SetScript("OnLeave", GameTooltip_Hide)
        actionButton:SetScript("OnEvent", QuestObjectiveItem_OnEvent)
        actionButton:SetScript("OnUpdate", QuestObjectiveItem_OnUpdate)
        
    end

    actionButton = CreateFrame("Button", "GwBonusItemButton", GwQuestTracker, "GwQuestItemTemplate")
    actionButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    actionButton.NormalTexture:SetTexture(nil)
    actionButton:RegisterForClicks("AnyUp")
    actionButton:SetScript("OnShow", QuestObjectiveItem_OnShow)
    actionButton:SetScript("OnHide", QuestObjectiveItem_OnHide)
    actionButton:SetScript("OnEnter", QuestObjectiveItem_OnEnter)
    actionButton:SetScript("OnLeave", GameTooltip_Hide)
    actionButton:SetScript("OnEvent", QuestObjectiveItem_OnEvent)
    actionButton:SetScript("OnUpdate", QuestObjectiveItem_OnUpdate)

    actionButton = CreateFrame("Button", "GwScenarioItemButton", GwQuestTracker, "GwQuestItemTemplate")
    actionButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    actionButton.NormalTexture:SetTexture(nil)
    actionButton:RegisterForClicks("AnyUp")
    actionButton:SetScript("OnShow", QuestObjectiveItem_OnShow)
    actionButton:SetScript("OnHide", QuestObjectiveItem_OnHide)
    actionButton:SetScript("OnEnter", QuestObjectiveItem_OnEnter)
    actionButton:SetScript("OnLeave", GameTooltip_Hide)
    actionButton:SetScript("OnEvent", QuestObjectiveItem_OnEvent)
    actionButton:SetScript("OnUpdate", QuestObjectiveItem_OnUpdate)
end
GW.AddForProfiling("objectives", "loadQuestButtons", loadQuestButtons)

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
GW.setBlockColor = setBlockColor
GW.AddForProfiling("objectives", "setBlockColor", setBlockColor)

local function statusBar_OnShow(self)
    local f = self:GetParent()
    if not f then
        return
    end
    f:SetHeight(50)
    f.statusbarBg:Show()
end
GW.AddForProfiling("objectives", "statusBar_OnShow", statusBar_OnShow)

local function statusBar_OnHide(self)
    local f = self:GetParent()
    if not f then
        return
    end
    f:SetHeight(20)
    f.statusbarBg:Hide()
end
GW.AddForProfiling("objectives", "statusBar_OnHide", statusBar_OnHide)

local function statusBarSetValue(self)
    local f = self:GetParent()
    if not f then
        return
    end
    local _, mx = self:GetMinMaxValues()
    local v = self:GetValue()
    local width = math.max(1, math.min(10, 10 * ((v / mx) / 0.1)))
    f.StatusBar.Spark:SetPoint("RIGHT", self, "LEFT", 280 * (v / mx), 0)
    f.StatusBar.Spark:SetWidth(width)
    if self.precentage == nil or self.precentage == false then
        self.progress:SetText(v .. " / " .. mx)
    else
        self.progress:SetText(math.floor((v / mx) * 100) .. "%")
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
            for k, v in pairs(self.objectiveBlocks) do
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
            if self.event then
                BonusObjectiveTracker_ShowRewardsTooltip(self)
            end
        end
    )
    f:SetScript(
        "OnLeave",
        function(self)
            self.hover:Hide()
            if self.objectiveBlocks == nil then
                self.objectiveBlocks = {}
            end
            for k, v in pairs(self.objectiveBlocks) do
                v.StatusBar.progress:Hide()
            end
            if animations[self:GetName() .. "hover"] ~= nil then
                animations[self:GetName() .. "hover"]["complete"] = true
            end
            GameTooltip_Hide()
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
        local h = 20
        if objectiveBlock.StatusBar:IsShown() then
            if block.numObjectives >= 1 then
                h = 50
            else
                h = 40
            end
        end
        block.height = block.height + h
        block.numObjectives = block.numObjectives + 1
    end
end
GW.AddForProfiling("objectives", "addObjective", addObjective)

local function updateQuestObjective(block, numObjectives, isComplete, title)
    local addedObjectives = 1
    for objectiveIndex = 1, numObjectives do
        --local text, _, finished = GetQuestLogLeaderBoard(objectiveIndex, block.questLogIndex)
        local text, objectiveType, finished = GetQuestObjectiveInfo(block.questID, objectiveIndex, false)
        if not finished then
            addObjective(block, text, finished, addedObjectives, objectiveType)
            addedObjectives = addedObjectives + 1
        end
    end
end
GW.AddForProfiling("objectives", "updateQuestObjective", updateQuestObjective)

local function UpdateQuestItem(button, questLogIndex)
    if InCombatLockdown() then
        return
    end

    if button == nil then
        return
    end

    local link, item, charges, _ = GetQuestLogSpecialItemInfo(questLogIndex)

    if item == nil then
        button:Hide()
        return
    end

    button:SetID(questLogIndex)

    button:SetAttribute("type", "item")
    button:SetAttribute("item", link)

    button.charges = charges
    button.rangeTimer = -1
    SetItemButtonTexture(button, item)
    SetItemButtonCount(button, charges)

    QuestObjectiveItem_UpdateCooldown(button)
    button:Show()
end
GW.UpdateQuestItem = UpdateQuestItem

local function OnBlockClick(self, button, isHeader)
    if button == "RightButton" then
        ObjectiveTracker_ToggleDropDown(self, QuestObjectiveTracker_OnOpenDropDown)
        return
    end
    CloseDropDownMenus()

    if ChatEdit_TryInsertQuestLinkForQuestID(self.questID) then
        return
    end
    
    if isHeader and not IsModifiedClick("QUESTWATCHTOGGLE") then
        SetSuperTrackedQuestID(self.questID)
        return
    end

    if button ~= "RightButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if IsModifiedClick("QUESTWATCHTOGGLE") then
            QuestObjectiveTracker_UntrackQuest(nil, self.questID)
        else
            QuestMapFrame_OpenToQuestDetails(self.questID)
        end
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

local function updateQuest(block, questWatchId)
    block.height = 25
    block.numObjectives = 0
    block.turnin:Hide()

    local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, _ =
        GetQuestWatchInfo(questWatchId)

    if questID then
        if savedQuests[questID] == nil then
            NewQuestAnimation(block)
            savedQuests[questID] = true
        end

        block.questID = questID
        block.id = questID
        block.questLogIndex = questLogIndex

        block.Header:SetText(title)

        --Quest item

        UpdateQuestItem(_G["GwQuestItemButton" .. questWatchId], questLogIndex)

        if isComplete and isComplete < 0 then
            isComplete = false
        elseif numObjectives == 0 and GetMoney() >= requiredMoney and not startEvent then
            isComplete = true
        end

        updateQuestObjective(block, numObjectives, isComplete, title)

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
                local completionText = GetQuestLogCompletionText(questLogIndex)

                if (completionText) then
                    addObjective(block, completionText, false, block.numObjectives + 1, nil)
                else
                    addObjective(block, QUEST_WATCH_QUEST_READY, false, block.numObjectives + 1, nil)
                end
            end
        end
        block.clickHeader:SetScript("OnClick", OnBlockClickHandler)
        block:SetScript("OnClick", OnBlockClickHandler)
        --add groupfinder button
        if C_LFGList.CanCreateQuestGroup(block.questID) then
            block.joingroup:Show()
        else
            block.joingroup:Hide()
        end
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

local function updateQuestItemPositions(index, height)
    if _G["GwQuestItemButton" .. index] == nil then
        return
    end

    if InCombatLockdown() then
        return
    end

    height = height + GwQuesttrackerContainerScenario:GetHeight() + 25
    height = height + GwQuesttrackerContainerAchievement:GetHeight()

    if GwObjectivesNotification:IsShown() then
        height = height + GwObjectivesNotification.desc:GetHeight() + 50
    end

    if GwQuesttrackerContainerBossFrames:IsShown() then
        height = height + GwQuesttrackerContainerBossFrames:GetHeight()
    end

    _G["GwQuestItemButton" .. index]:SetPoint("TOPLEFT", GwQuestTracker, "TOPRIGHT", -330, -height)
end
GW.AddForProfiling("objectives", "updateQuestItemPositions", updateQuestItemPositions)

local function updateExtraQuestItemPositions()
    if GwBonusItemButton == nil or GwScenarioItemButton == nil then
        return
    end

    if InCombatLockdown() then
        return
    end

    local height = 0

    if GwObjectivesNotification:IsShown() then
        height = height + GwObjectivesNotification.desc:GetHeight() + 50
    end

    GwScenarioItemButton:SetPoint("TOPLEFT", GwQuestTracker, "TOPRIGHT", -330, -height)

    if GwQuesttrackerContainerBossFrames:IsShown() then
        height = height + GwQuesttrackerContainerBossFrames:GetHeight()
    end

    height = height + GwQuesttrackerContainerScenario:GetHeight() + GwQuesttrackerContainerQuests:GetHeight() +
        GwQuesttrackerContainerAchievement:GetHeight()

    GwBonusItemButton:SetPoint("TOPLEFT", GwQuestTracker, "TOPRIGHT", -330, -height + -25)
end
GW.AddForProfiling("objectives", "updateExtraQuestItemPositions", updateExtraQuestItemPositions)

--[[
function gwRequestQustlogUpdate()
    updateQuestLogLayout()
end
--]]
local function QuestTrackerLayoutChanged()
    updateExtraQuestItemPositions()
    GwQuestTrackerScroll:SetSize(
        400,
        GwQuesttrackerContainerBonusObjectives:GetHeight() + GwQuesttrackerContainerQuests:GetHeight()
    )
end
GW.QuestTrackerLayoutChanged = QuestTrackerLayoutChanged

local function updateQuestLogLayout(intent, ...)
    local savedHeight = 1
    GwQuestHeader:Hide()

    local numQuests = GetNumQuestWatches()
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
        updateQuestItemPositions(i, savedHeight)

        savedHeight = savedHeight + block.height
    end
    GwQuesttrackerContainerQuests:SetHeight(savedHeight)
    for i = numQuests + 1, 25 do
        if _G["GwQuestBlock" .. i] ~= nil then
            _G["GwQuestBlock" .. i]:Hide()
            UpdateQuestItem(_G["GwQuestItemButton" .. i], 0)
        end
    end

    QuestTrackerLayoutChanged()
end
GW.AddForProfiling("objectives", "updateQuestLogLayout", updateQuestLogLayout)

local function tracker_OnEvent(self, event, ...)
    updateQuestLogLayout(...)
end
GW.AddForProfiling("objectives", "tracker_OnEvent", tracker_OnEvent)

local function trackerNotification_OnEvent(self, event)
    mapID = C_Map.GetBestMapForUnit("player")
end
GW.AddForProfiling("objectives", "trackerNotification_OnEvent", trackerNotification_OnEvent)

local function tracker_OnUpdate(self, elapsed)
    self.elapsedTimer = self.elapsedTimer - elapsed
    if self.elapsedTimer > 0 then
        return
    end
    self.elapsedTimer = updateCap

    local prevState = GwObjectivesNotification.shouldDisplay

    if mapID then
        GW.SetObjectiveNotification(mapID)
    end

    if prevState ~= GwObjectivesNotification.shouldDisplay then
        GW.NotificationStateChanged(GwObjectivesNotification.shouldDisplay)
    end
end
GW.AddForProfiling("objectives", "tracker_OnUpdate", tracker_OnUpdate)

local function bonus_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetText(RoundDec(self.progress * 100, 0) .. "%")
    GameTooltip:Show()
end
GW.AddForProfiling("objectives", "bonus_OnEnter", bonus_OnEnter)

local function LoadQuestTracker()
    --local qt_enabled = GetSetting("QUESTTRACKER_ENABLED")
    --local bars_enabled = GetSetting("ACTIONBARS_ENABLED")
    local map_enabled = GetSetting("MINIMAP_ENABLED")
    local map_position = GetSetting("MINIMAP_POS")

    -- disable the default tracker
    ObjectiveTrackerFrame:SetMovable(1)
    ObjectiveTrackerFrame:SetUserPlaced(true)
    ObjectiveTrackerFrame:Hide()
    ObjectiveTrackerFrame:SetScript(
        "OnShow",
        function()
            ObjectiveTrackerFrame:Hide()
        end
    )
    -- don't do this til new tracker
    --ObjectiveTrackerFrame:UnregisterAllEvents()
    --ObjectiveTrackerFrame:SetScript("OnUpdate", nil)
    --ObjectiveTrackerFrame:SetScript("OnSizeChanged", nil)
    --ObjectiveTrackerFrame:SetScript("OnEvent", nil)

    -- create our tracker
    local fTracker = CreateFrame("Frame", "GwQuestTracker", UIParent, "GwQuestTracker")

    local fTraScr = CreateFrame("ScrollFrame", "GwQuestTrackerScroll", fTracker, "GwQuestTrackerScroll")
    fTraScr:SetScript(
        "OnMouseWheel",
        function(self, delta)
            delta = -delta * 15
            local s = math.max(0, self:GetVerticalScroll() + delta)
            self:SetVerticalScroll(s)
        end
    )

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
    local fScen = CreateFrame("Frame", "GwQuesttrackerContainerScenario", fTracker, "GwQuesttrackerContainer")
    local fAchv = CreateFrame("Frame", "GwQuesttrackerContainerAchievement", fTracker, "GwQuesttrackerContainer")
    local fQuest = CreateFrame("Frame", "GwQuesttrackerContainerQuests", fScroll, "GwQuesttrackerContainer")
    local fBonus = CreateFrame("Frame", "GwQuesttrackerContainerBonusObjectives", fScroll, "GwQuesttrackerContainer")
    fAchv:SetParent(fScroll)
    fQuest:SetParent(fScroll)
    fBonus:SetParent(fScroll)

    if map_enabled then
        if map_position == "TOP" then
            fTracker:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT")
            fTracker:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 25)
        else
            fTracker:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT")
            fTracker:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 0, 3)
        end
    else
        fTracker:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT")
        fTracker:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT")
    end

    fNotify:SetPoint("TOPRIGHT", fTracker, "TOPRIGHT")
    fBoss:SetPoint("TOPRIGHT", fNotify, "BOTTOMRIGHT")
    fScen:SetPoint("TOPRIGHT", fBoss, "BOTTOMRIGHT")

    fTraScr:SetPoint("TOPRIGHT", fScen, "BOTTOMRIGHT")
    fTraScr:SetPoint("BOTTOMRIGHT", fTracker, "BOTTOMRIGHT")

    fScroll:SetPoint("TOPRIGHT", fTraScr, "TOPRIGHT")
    fAchv:SetPoint("TOPRIGHT", fScroll, "TOPRIGHT")
    fQuest:SetPoint("TOPRIGHT", fAchv, "BOTTOMRIGHT")
    fBonus:SetPoint("TOPRIGHT", fQuest, "BOTTOMRIGHT")

    fScroll:SetSize(400, 2)
    fTraScr:SetScrollChild(fScroll)

    fQuest:SetScript("OnEvent", tracker_OnEvent)
    fQuest:RegisterEvent("QUEST_LOG_UPDATE")
    fQuest:RegisterEvent("QUEST_ITEM_UPDATE")
    fQuest:RegisterEvent("QUEST_REMOVED")
    fQuest:RegisterEvent("QUESTLINE_UPDATE")
    fQuest:RegisterEvent("TASK_PROGRESS_UPDATE")
    fQuest:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    fQuest:RegisterEvent("QUEST_AUTOCOMPLETE")
    fQuest:RegisterEvent("QUEST_ACCEPTED")
    fQuest:RegisterEvent("QUEST_GREETING")
    fQuest:RegisterEvent("QUEST_DETAIL")
    fQuest:RegisterEvent("QUEST_PROGRESS")
    fQuest:RegisterEvent("QUEST_COMPLETE")
    fQuest:RegisterEvent("QUEST_FINISHED")
    fQuest:RegisterEvent("QUEST_POI_UPDATE")
    fQuest:RegisterEvent("PLAYER_MONEY")
    fQuest:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED")
    fQuest:RegisterEvent("PLAYER_REGEN_ENABLED")

    local header = CreateFrame("Button", "GwQuestHeader", fQuest, "GwQuestTrackerHeader")
    header.icon:SetTexCoord(0, 1, 0.25, 0.5)
    header.title:SetFont(UNIT_NAME_FONT, 14)
    header.title:SetShadowOffset(1, -1)
    header.title:SetText(QUESTS_LABEL)

    header:SetScript(
        "OnClick",
        function(self)
            local p = self:GetParent()
            if p.collapsed == nil or p.collapsed == false then
                p.collapsed = true
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            else
                p.collapsed = false
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end
            updateQuestLogLayout("COLLAPSE")
        end
    )
    header.title:SetTextColor(
        TRACKER_TYPE_COLOR["QUEST"].r,
        TRACKER_TYPE_COLOR["QUEST"].g,
        TRACKER_TYPE_COLOR["QUEST"].b
    )

    loadQuestButtons()
    updateQuestLogLayout("LOAD")

    GW.LoadBossFrame()
    if not IsAddOnLoaded("sArena") then
        GW.LoadArenaFrame()
    end
    GW.LoadScenarioFrame()
    GW.LoadAchievementFrame()
    GW.LoadBonusFrame()

    fNotify.shouldDisplay = false
    fTracker.elapsedTimer = -1
    fTracker:SetScript("OnEvent", trackerNotification_OnEvent)
    fTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
    fTracker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    fTracker:SetScript("OnUpdate", tracker_OnUpdate)
end
GW.LoadQuestTracker = LoadQuestTracker
