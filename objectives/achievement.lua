local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local ParseObjectiveString = GW.ParseObjectiveString
local FormatObjectiveNumbers = GW.FormatObjectiveNumbers
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local QuestTrackerLayoutChanged = GW.QuestTrackerLayoutChanged
local setBlockColor = GW.setBlockColor

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
    else
        ObjectiveTracker_ToggleDropDown(block, AchievementObjectiveTracker_OnOpenDropDown)
    end
end
GW.AddForProfiling("achievement", "achievement_OnClick", achievement_OnClick)

local function getObjectiveBlock(self, firstunfinishedobjectiv)
    if _G[self:GetName() .. "GwAchievementObjective" .. self.numObjectives] ~= nil then
        return _G[self:GetName() .. "GwAchievementObjective" .. self.numObjectives]
    end

    if firstunfinishedobjectiv then
        self.objectiveBlocks = {}
    end

    local newBlock = CreateObjectiveNormal(self:GetName() .. "GwAchievementObjective" .. self.numObjectives, self)
    newBlock:SetParent(self)

    self.objectiveBlocks[#self.objectiveBlocks] = newBlock

    if firstunfinishedobjectiv then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint(
            "TOPRIGHT",
            _G[self:GetName() .. "GwAchievementObjective" .. self.numObjectives - 1],
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
       return  _G["GwAchivementBlock" .. blockIndex]
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

local function addObjective(block, text, finished, firstunfinishedobjectiv, qty, totalqty)
    if finished or not text then
        return
    end

    local objectiveBlock = getObjectiveBlock(block, firstunfinishedobjectiv)

    objectiveBlock:Show()
    objectiveBlock.ObjectiveText:SetText(FormatObjectiveNumbers(text))
    objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
    objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)

    if ParseObjectiveString(objectiveBlock, text, nil, nil, qty, totalqty) then
        --added progressbar in ParseObjectiveString
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
GW.AddForProfiling("achievement", "addObjective", addObjective)

local function updateAchievementObjectives(block)
    local numIncomplete = 0
    local numCriteria = GetAchievementNumCriteria(block.id)
    local description = select(8, GetAchievementInfo(block.id))
    local firstunfinishedobjectiv = false

    block.height = 35
    block.numObjectives = 0

    if numCriteria > 0 then
        for criteriaIndex = 1, numCriteria do
            local criteriaString,
                criteriaType,
                criteriaCompleted,
                quantity,
                totalQuantity,
                _,
                flags,
                assetID,
                quantityString = GetAchievementCriteriaInfo(block.id, criteriaIndex)

            if not criteriaCompleted then
                numIncomplete = numIncomplete + 1
            end

            if numIncomplete == 1 then 
                firstunfinishedobjectiv = true
            else
                firstunfinishedobjectiv = false
            end

            if (description and bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR) then
                -- progress bar
                if (string.find(strlower(quantityString), "interface/moneyframe") or string.find(strlower(quantityString), "interface\\moneyframe")) then -- no easy way of telling it's a money progress bar ("\" for mac and linux)
                    quantity = math.floor(quantity / (COPPER_PER_SILVER * SILVER_PER_GOLD))
                    totalQuantity = math.floor(totalQuantity / (COPPER_PER_SILVER * SILVER_PER_GOLD))

                    criteriaString = description
                else

                    criteriaString = description
                end
            else
                -- for meta criteria look up the achievement name
                if (criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID) then
                    _, criteriaString = GetAchievementInfo(assetID)
                end
            end
            addObjective(block, criteriaString, criteriaCompleted, firstunfinishedobjectiv, quantity, totalQuantity)

            if numIncomplete == MAX_OBJECTIVES then
                addObjective(block, "...", false, firstunfinishedobjectiv)
                break
            end
        end
    else
        addObjective(block, description, false, true)
    end

    for i = block.numObjectives + 1, 20 do
        if _G[block:GetName() .. "GwAchievementObjective" .. i] ~= nil then
            _G[block:GetName() .. "GwAchievementObjective" .. i]:Hide()
        end
    end

    block:SetHeight(block.height)
end
GW.AddForProfiling("achievement", "updateAchievementObjectives", updateAchievementObjectives)

local function updateAchievementLayout()
    local savedHeight = 1
    local shownIndex = 1
    local trackedAchievements = {GetTrackedAchievements()}

    GwAchievementHeader:Hide() 

    local numQuests = #trackedAchievements
    if GwQuesttrackerContainerAchievement.collapsed == true then
        GwAchievementHeader:Show()
        numQuests = 0
        savedHeight = 20
    end

    for i = 1, numQuests do
        local achievementID = trackedAchievements[i]
        local achievementName = select(2, GetAchievementInfo(achievementID))
        local wasEarnedByMe = select(13, GetAchievementInfo(achievementID))

        if not wasEarnedByMe then
            if i == 1 then
                savedHeight = 20
            end

            GwAchievementHeader:Show()
            local block = getBlock(shownIndex)
            if block == nil then
                return
            end
            block.id = achievementID
            updateAchievementObjectives(block)

            block.Header:SetText(achievementName)

            block:Show()

            block:SetScript("OnClick", achievement_OnClick)

            savedHeight = savedHeight + block.height

            shownIndex = shownIndex + 1
        end
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
    GwQuesttrackerContainerAchievement:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED")
    GwQuesttrackerContainerAchievement:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE")
    GwQuesttrackerContainerAchievement:RegisterEvent("ACHIEVEMENT_EARNED")
    GwQuesttrackerContainerAchievement:SetScript("OnEvent", updateAchievementLayout)

    local header = CreateFrame("Button", "GwAchievementHeader", GwQuesttrackerContainerAchievement, "GwQuestTrackerHeader")
    header.icon:SetTexCoord(0, 0.5, 0, 0.25)
    header.title:SetFont(UNIT_NAME_FONT, 14)
    header.title:SetShadowOffset(1, -1)
    header.title:SetText(TRACKER_HEADER_ACHIEVEMENTS)

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
        TRACKER_TYPE_COLOR.ACHIEVEMENT.r,
        TRACKER_TYPE_COLOR.ACHIEVEMENT.g,
        TRACKER_TYPE_COLOR.ACHIEVEMENT.b
    ) 

    updateAchievementLayout()
end
GW.LoadAchievementFrame = LoadAchievementFrame
