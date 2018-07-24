local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local ParseObjectiveString = GW.ParseObjectiveString
local FormatObjectiveNumbers = GW.FormatObjectiveNumbers
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local QuestTrackerLayoutChanged = GW.QuestTrackerLayoutChanged

local MAX_OBJECTIVES = 10
local function achievement_OnClick(block, mouseButton)
    if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
        local achievementLink = GetAchievementLink(block.id)
        if (achievementLink) then
            ChatEdit_InsertLink(achievementLink)
        end
    elseif (mouseButton ~= "RightButton") then
        CloseDropDownMenus()
        if (not AchievementFrame) then
            AchievementFrame_LoadUI()
        end
        if (IsModifiedClick("QUESTWATCHTOGGLE")) then
            AchievementObjectiveTracker_UntrackAchievement(_, block.id)
        elseif (not AchievementFrame:IsShown()) then
            AchievementFrame_ToggleAchievementFrame()
            AchievementFrame_SelectAchievement(block.id)
        else
            if (AchievementFrameAchievements.selection ~= block.id) then
                AchievementFrame_SelectAchievement(block.id)
            else
                AchievementFrame_ToggleAchievementFrame()
            end
        end
    end
end
GW.AddForProfiling("achievement", "achievement_OnClick", achievement_OnClick)

local function setBlockColor(block, string)
    block.color = TRACKER_TYPE_COLOR[string]
end
GW.AddForProfiling("achievement", "setBlockColor", setBlockColor)

local function getObjectiveBlock(self, index)
    if _G[self:GetName() .. "GwAchievementObjective" .. index] ~= nil then
        return _G[self:GetName() .. "GwAchievementObjective" .. index]
    end

    if self.objectiveBlocksNum == nil then
        self.objectiveBlocksNum = 0
    end
    if self.objectiveBlocks == nil then
        self.objectiveBlocks = {}
    end

    self.objectiveBlocksNum = self.objectiveBlocksNum + 1

    local newBlock =
        CreateObjectiveNormal(self:GetName() .. "GwAchievementObjective" .. self.objectiveBlocksNum, self)
    newBlock:SetParent(self)
    self.objectiveBlocks[#self.objectiveBlocks] = newBlock
    if self.objectiveBlocksNum == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint(
            "TOPRIGHT",
            _G[self:GetName() .. "GwAchievementObjective" .. (self.objectiveBlocksNum - 1)],
            "BOTTOMRIGHT",
            0,
            0
        )
    end

    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    return newBlock
end
GW.AddForProfiling("achievement", "getObjectiveBlock", getObjectiveBlock)

local function getBlock(blockIndex)
    if _G["GwAchivementBlock" .. blockIndex] ~= nil then
        return _G["GwAchivementBlock" .. blockIndex]
    end

    local newBlock = CreateTrackerObject("GwAchivementBlock" .. blockIndex, GwQuesttrackerContainerAchievement)
    newBlock:SetParent(GwQuesttrackerContainerAchievement)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerAchievement, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwAchivementBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end
    newBlock.height = 0
    setBlockColor(newBlock, "ACHIEVEMENT")
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    return newBlock
end
GW.AddForProfiling("achievement", "getBlock", getBlock)

local function addObjective(block, text, finished, objectiveIndex)
    if finished == true then
        return
    end
    local objectiveBlock = getObjectiveBlock(block, objectiveIndex)

    if text then
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText(FormatObjectiveNumbers(text))
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
            end
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
end
GW.AddForProfiling("achievement", "addObjective", addObjective)

local function updateAchievementObjectives(block, blockIndex, achievementID)
    block.height = 35
    block.numObjectives = 0

    local numIncomplete = 0

    local numCriteria = GetAchievementNumCriteria(achievementID)

    local _, _, _, _, _, _, _, description, _ = GetAchievementInfo(achievementID)

    if (numCriteria > 0) then
        for criteriaIndex = 1, numCriteria do
            local criteriaString,
                criteriaType,
                criteriaCompleted,
                quantity,
                totalQuantity,
                _,
                flags,
                assetID,
                quantityString,
                _ = GetAchievementCriteriaInfo(achievementID, criteriaIndex)

            if not criteriaCompleted then
                numIncomplete = numIncomplete + 1
            end

            if (description and bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR) then
                -- progress bar
                if (string.find(strlower(quantityString), "interface\\moneyframe")) then -- no easy way of telling it's a money progress bar
                    quantity = math.floor(quantity / (COPPER_PER_SILVER * SILVER_PER_GOLD))
                    totalQuantity = math.floor(totalQuantity / (COPPER_PER_SILVER * SILVER_PER_GOLD))

                    criteriaString = quantity .. "/" .. totalQuantity .. " " .. description
                else
                    -- remove spaces so it matches the quest look, x/y
                    criteriaString = string.gsub(quantityString, " / ", "/") .. " " .. description
                end
            else
                -- for meta criteria look up the achievement name
                if (criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID) then
                    _, criteriaString = GetAchievementInfo(assetID)
                end
            end

            addObjective(block, criteriaString, criteriaCompleted, criteriaIndex)

            if numIncomplete == MAX_OBJECTIVES then
                addObjective(block, "....", false, MAX_OBJECTIVES + 1)
                break
            end
        end
    else
        addObjective(block, description, false, 1)
    end

    for i = block.numObjectives + 1, 20 do
        if _G[block:GetName() .. "GwAchievementObjective" .. i] ~= nil then
            _G[block:GetName() .. "GwAchievementObjective" .. i]:Hide()
        end
    end

    block:SetHeight(block.height)
end
GW.AddForProfiling("achievement", "updateAchievementObjectives", updateAchievementObjectives)

local function updateAchievementLayout(intent)
    local savedHeight = 1
    GwAchievementHeader:Hide()
    local trackedAchievements = {GetTrackedAchievements()}

    local numQuests = #trackedAchievements
    if GwQuesttrackerContainerAchievement.collapsed == true then
        GwAchievementHeader:Show()
        numQuests = 0
        savedHeight = 20
    end

    local _ = IsInInstance()

    local shownIndex = 1

    for i = 1, numQuests do
        --if trackedAchievements[i] == intent then
        local achievementID = trackedAchievements[i]
        local _, achievementName, _, _, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(achievementID)

        local showAchievement = true
        if (wasEarnedByMe) then
            showAchievement = false
        end

        if (showAchievement) then
            if i == 1 then
                savedHeight = 20
            end

            GwAchievementHeader:Show()
            local block = getBlock(shownIndex)
            if block == nil then
                return
            end
            block.id = achievementID
            updateAchievementObjectives(block, shownIndex, achievementID)

            block.Header:SetText(achievementName)

            block:Show()

            block:SetScript("OnClick", achievement_OnClick)

            savedHeight = savedHeight + block.height

            shownIndex = shownIndex + 1
        end
        --end
    end

    GwQuesttrackerContainerAchievement:SetHeight(savedHeight)

    for i = shownIndex, 25 do
        if _G["GwAchivementBlock" .. i] ~= nil then
            _G["GwAchivementBlock" .. i]:Hide()
        end
    end

    QuestTrackerLayoutChanged()
end
GW.AddForProfiling("achievement", "updateAchievementLayout", updateAchievementLayout)

local function LoadAchievementFrame()
    GwQuesttrackerContainerAchievement:SetScript("OnEvent", updateAchievementLayout)

    GwQuesttrackerContainerAchievement:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED")
    GwQuesttrackerContainerAchievement:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE")
    GwQuesttrackerContainerAchievement:RegisterEvent("ACHIEVEMENT_EARNED")

    local header =
        CreateFrame("Button", "GwAchievementHeader", GwQuesttrackerContainerAchievement, "GwQuestTrackerHeader")
    header.icon:SetTexCoord(0, 1, 0, 0.25)
    header.title:SetFont(UNIT_NAME_FONT, 14)
    header.title:SetShadowOffset(1, -1)
    header.title:SetText(QUESTS_LABEL)

    GwQuesttrackerContainerAchievement.collapsed = false
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
            updateAchievementLayout()
        end
    )
    header.title:SetTextColor(
        TRACKER_TYPE_COLOR["ACHIEVEMENT"].r,
        TRACKER_TYPE_COLOR["ACHIEVEMENT"].g,
        TRACKER_TYPE_COLOR["ACHIEVEMENT"].b
    )
    header.title:SetText(ACHIEVEMENTS)

    updateAchievementLayout()
end
GW.LoadAchievementFrame = LoadAchievementFrame
