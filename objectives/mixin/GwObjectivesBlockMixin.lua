local _, GW = ...

GwObjectivesBlockTemplateMixin = {}

function GwObjectivesBlockTemplateMixin:UpdateBlockObjectives()
    -- override per module
end

function GwObjectivesBlockTemplateMixin:UpdateBlock()
    -- override per module
end

local function wiggleAnim(self)
    if self.animation == nil then
        self.animation = 0
    end
    if self.doingAnimation == true then
        return
    end
    self.doingAnimation = true
    GW.AddToAnimation(
        self:GetName(),
        0,
        1,
        GetTime(),
        2,
        function(prog)
            self.flare:SetRotation(GW.lerp(0, 1, prog))

            if prog < 0.25 then
                self.texture:SetRotation(GW.lerp(0, -0.5, math.sin((prog / 0.25) * math.pi * 0.5)))
                self.flare:SetAlpha(GW.lerp(0, 1, math.sin((prog / 0.25) * math.pi * 0.5)))
            end
            if prog > 0.25 and prog < 0.75 then
                self.texture:SetRotation(GW.lerp(-0.5, 0.5, math.sin(((prog - 0.25) / 0.5) * math.pi * 0.5)))
            end
            if prog > 0.75 then
                self.texture:SetRotation(GW.lerp(0.5, 0, math.sin(((prog - 0.75) / 0.25) * math.pi * 0.5)))
            end

            if prog > 0.25 then
                self.flare:SetAlpha(GW.lerp(1, 0, ((prog - 0.25) / 0.75)))
            end
        end,
        nil,
        function()
            self.doingAnimation = false
        end
    )
end

function GwObjectivesBlockTemplateMixin:OnEnter()
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
        if not v.StatusBar.notHide then
            v.StatusBar.progress:Show()
        end
    end
    GW.AddToAnimation(
        (self.animationName or self:GetName()) .. "hover",
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
        self:TryShowRewardsTooltip()
    else
        if IsInGroup() and self.id then
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0)
            GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
            GameTooltip:SetQuestPartyProgress(self.id)
            EventRegistry:TriggerEvent("OnQuestBlockHeader.OnEnter", self, self.id, true)
        end
    end
end

function GwObjectivesBlockTemplateMixin:OnLeave()
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
        if not v.StatusBar.notHide then
            v.StatusBar.progress:Hide()
        end
    end
    if GW.animations[(self.animationName or self:GetName()) .. "hover"] then
        GW.animations[(self.animationName or self:GetName()) .. "hover"].complete = true
    end
    GameTooltip_Hide()
end

function GwObjectivesBlockTemplateMixin:OnLoad()
    self.Header:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    self.SubHeader:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)

    self.turnin:SetScript("OnShow", function(self) self:SetScript("OnUpdate", wiggleAnim) end)
    self.turnin:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)
    self.turnin:SetScript("OnClick",function(self)
        ShowQuestComplete(self:GetParent().id)
        RemoveAutoQuestPopUp(self:GetParent().id)
        self:Hide()
    end)
    self.popupQuestAccept:SetScript(
        "OnShow",
        function(self)
            self:SetScript("OnUpdate", wiggleAnim)
        end
    )
    self.popupQuestAccept:SetScript(
        "OnHide",
        function(self)
            self:SetScript("OnUpdate", nil)
        end
    )
    self.popupQuestAccept:SetScript("OnClick", function(self)
        ShowQuestOffer(self:GetParent().id)
        RemoveAutoQuestPopUp(self:GetParent().id)
        self:Hide()
    end)
    self.groupButton:SetScript("OnClick", function(self)
        if self:GetParent().hasGroupFinderButton then
            LFGListUtil_FindQuestGroup(self:GetParent().id, true)
        end
    end)
    self.groupButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self)
        GameTooltip:AddLine(TOOLTIP_TRACKER_FIND_GROUP_BUTTON, HIGHLIGHT_FONT_COLOR:GetRGB())
        GameTooltip:Show()
    end)
    self.groupButton:SetScript("OnLeave", GameTooltip_Hide)

    self.turnin:SetScale(GwQuestTracker:GetScale() * 0.9)
    self.popupQuestAccept:SetScale(GwQuestTracker:GetScale() * 0.9)
    self.groupButton:SetScale(GwQuestTracker:GetScale() * 0.9)

    -- hooks for scaling
    hooksecurefunc(GwQuestTracker, "SetScale", function(_, scale)
        self.turnin:SetScale(scale * 0.9)
        self.popupQuestAccept:SetScale(scale * 0.9)
        self.groupButton:SetScale(scale * 0.9)
    end)
end

function GwObjectivesBlockTemplateMixin:SetBlockColorByKey(string)
    self.color = GW.TRACKER_TYPE_COLOR[string]
end

function GwObjectivesBlockTemplateMixin:GetObjectiveBlock(index)
    if _G[self:GetName() .. "Objective" .. index] then
        _G[self:GetName() .. "Objective" .. index]:SetScript("OnUpdate", nil)
        return _G[self:GetName() .. "Objective" .. index]
    end

    if self.objectiveBlocksNum == nil then
        self.objectiveBlocksNum = 0
    end
    self.objectiveBlocks = self.objectiveBlocks or {}
    self.objectiveBlocksNum = self.objectiveBlocksNum + 1

    local newBlock = CreateFrame("Frame", self:GetName() .. "Objective" .. self.objectiveBlocksNum, self, "GwQuesttrackerObjectiveTemplate")
    newBlock:SetParent(self)
    tinsert(self.objectiveBlocks, newBlock)
    if self.objectiveBlocksNum == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint("TOPRIGHT", _G[self:GetName() .. "Objective" .. (self.objectiveBlocksNum - 1)], "BOTTOMRIGHT", 0, 0)
    end

    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)
    newBlock.notChangeSize = true

    return newBlock
end

function GwObjectivesBlockTemplateMixin:AddObjective(text, objectiveIndex, options)
    if not text then return end
    self.numObjectives = self.numObjectives + 1
    local objectiveBlock = self:GetObjectiveBlock(objectiveIndex)
    local precentageComplete = 0

    objectiveBlock:Show()
    local formattedText = text
    if options.isReceip then
        if options.qty < options.totalqty then
            objectiveBlock.ObjectiveText:SetText(GW.GetLocalizedNumber(options.qty) .. "/" .. GW.GetLocalizedNumber(options.totalqty) .. " " .. text)
        end
    elseif options.isAchievement then
        GW.FormatObjectiveNumbers(text)
    end
    objectiveBlock.ObjectiveText:SetText(formattedText)
    objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)

    if options.isAchievement then
        if options.eligible then
            objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
        else
            objectiveBlock.ObjectiveText:SetTextColor(DIM_RED_FONT_COLOR.r, DIM_RED_FONT_COLOR.g, DIM_RED_FONT_COLOR.b)
        end
    else
        if options.finished then
            objectiveBlock.ObjectiveText:SetTextColor(0.8, 0.8, 0.8)
        else
            objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
        end
    end

    if options.objectiveType == "progressbar" then
        objectiveBlock.StatusBar:SetMinMaxValues(0, 100)
        objectiveBlock.StatusBar:SetValue(options.qty or GetQuestProgressBarPercent(self.questID) or 0)
        objectiveBlock.StatusBar:SetShown(options.overrideShowStatusbarSetting or GW.settings.QUESTTRACKER_STATUSBARS_ENABLED)
        objectiveBlock.StatusBar:SetValue(GetQuestProgressBarPercent(self.questID))
        objectiveBlock.progress = (options.qty or GetQuestProgressBarPercent(self.questID)) / 100
        objectiveBlock.StatusBar.precentage = true
        precentageComplete = objectiveBlock.progress
    elseif GW.ParseObjectiveString(objectiveBlock, text, options.qty, options.totalqty, options.overrideShowStatusbarSetting) then
        precentageComplete = objectiveBlock.progress
    else
        objectiveBlock.StatusBar:Hide()
    end

    local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
    objectiveBlock:SetHeight(h)
    if objectiveBlock.StatusBar:IsShown() then
        if self.numObjectives >= 1 then
            h = h + objectiveBlock.StatusBar:GetHeight() + 10
        else
            h = h + objectiveBlock.StatusBar:GetHeight() + 5
        end
        objectiveBlock:SetHeight(h)
    end

    if options.isAchievement and options.timerShown then
        objectiveBlock:AddTimer(options.duration, options.startTime)
    elseif options.isAchievement then
        objectiveBlock.TimerBar:Hide()
    end

    self.height = self.height + objectiveBlock:GetHeight()

    return precentageComplete
end

function GwObjectivesBlockTemplateMixin:IsQuestAutoTurnInOrAutoAccept(blockQuestID, checkType)
    for i = 1, GetNumAutoQuestPopUps() do
        local questID, popUpType = GetAutoQuestPopUp(i)
        if blockQuestID and questID and popUpType and popUpType == checkType and blockQuestID == questID then
            return true
        end
    end

    return false
end

function GwObjectivesBlockTemplateMixin:UpdateObjectiveActionButton()
    local link, item, _, showItemWhenComplete = nil, nil, nil, false

    if self.questLogIndex then
        link, item, _, showItemWhenComplete = GetQuestLogSpecialItemInfo(self.questLogIndex)
    end

    local isQuestComplete = (self and self.questID) and QuestCache:Get(self.questID):IsComplete() or false
    local shouldShowItem = item and (not isQuestComplete or showItemWhenComplete)

    if shouldShowItem and self.questLogIndex then
        self.hasItem = true
        self.actionButton:SetUp(self.questLogIndex)

        self.actionButton:SetAttribute("type", "item")
        self.actionButton:SetAttribute("item", link)

        self.actionButton:SetScript("OnUpdate", self.actionButton.OnUpdate)
        self.actionButton:Show()
    else
        self.hasItem = false
        self.actionButton:Hide()
        self.actionButton:SetScript("OnUpdate", nil)
    end
end

function GwObjectivesBlockTemplateMixin:UpdateObjectiveActionButtonPosition(type)
    if not self.actionButton or not self.hasItem then
        return
    end

    local height = self.fromContainerTopHeight + GW.ObjectiveTrackerContainer.Scenario:GetHeight() + GW.ObjectiveTrackerContainer.Achievement:GetHeight() + GW.ObjectiveTrackerContainer.BossFrames:GetHeight() + GW.ObjectiveTrackerContainer.ArenaFrames:GetHeight()
    if GW.ObjectiveTrackerContainer.Notification:IsShown() then
        height = height + GW.ObjectiveTrackerContainer.Notification.desc:GetHeight()
    else
        height = height - 40
    end
    if type == "SCENARIO" then
        height = height - (GW.ObjectiveTrackerContainer.Achievement:GetHeight() + GW.ObjectiveTrackerContainer.BossFrames:GetHeight() + GW.ObjectiveTrackerContainer.ArenaFrames:GetHeight())
    end
    if type == "EVENT" then
        height = height + GW.ObjectiveTrackerContainer.Quests:GetHeight()
    end
    if type == "QUEST" or type == "EVENT" then
        height = height + GW.ObjectiveTrackerContainer.Campaign:GetHeight()
    end

    self.actionButton:SetPoint("TOPLEFT", GwQuestTracker, "TOPRIGHT", -330, -height)
end
