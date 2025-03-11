local _, GW = ...

GwObjectivesContainerMixin = {}

function GwObjectivesContainerMixin:GetBlock(idx, colorKey, addItemButton)
    if _G[self:GetName() .. "Block" .. idx] then
        local block = _G[self:GetName() .. "Block" .. idx]
        -- set the correct block color for an existing block here
        block:SetBlockColorByKey(colorKey)
        block.Header:SetTextColor(block.color.r, block.color.g, block.color.b)
        block.hover:SetVertexColor(block.color.r, block.color.g, block.color.b)
        for i = 1, 50 do
            if _G[block:GetName() .. "Objective" .. i] then
                _G[block:GetName() .. "Objective" .. i].StatusBar:SetStatusBarColor(block.color.r, block.color.g, block.color.b)
            end
        end
        return block
    end

    local newBlock = CreateFrame("Button", self:GetName() .. "Block" .. idx, self, "GwObjectivesBlockTemplate")
    newBlock:SetParent(self)

    if idx == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G[self:GetName() .. "Block" ..  (idx - 1)], "BOTTOMRIGHT", 0, 0)
    end

    newBlock.index = idx
    newBlock:SetBlockColorByKey(colorKey)
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)

    -- quest item button here
    if addItemButton then
        newBlock.actionButton = CreateFrame("Button", nil, GwQuestTracker, "GwQuestItemTemplate")
        newBlock.actionButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        newBlock.actionButton.NormalTexture:SetTexture(nil)
        newBlock.actionButton:RegisterForClicks("AnyUp", "AnyDown")
        newBlock.actionButton:SetScript("OnShow", newBlock.actionButton.OnShow)
        newBlock.actionButton:SetScript("OnHide", newBlock.actionButton.OnHide)
        newBlock.actionButton:SetScript("OnEnter", newBlock.actionButton.OnEnter)
        newBlock.actionButton:SetScript("OnLeave", GameTooltip_Hide)
        newBlock.actionButton:SetScript("OnEvent", newBlock.actionButton.OnEvent)
    end

    return newBlock
end

function GwObjectivesContainerMixin:GetBlockByQuestId(questID)
    for i = 1, 25 do -- loop quest and campaign
        local block = _G[self:GetName() .. "Block" .. i]
        if block then
            if block.questID == questID then
                return block
            end
        end
    end

    return nil
end

function GwObjectivesContainerMixin:GetOrCreateBlockByQuestId(questID, colorKey)
    local blockName = self:GetName() .. "Block"

    for i = 1, 25 do
        if _G[blockName .. i] then
            if _G[blockName .. i].questID == questID then
                return _G[blockName .. i]
            elseif _G[blockName .. i].questID == nil then
                return self:GetBlock(i, colorKey, true)
            end
        else
            return self:GetBlock(i, colorKey, true)
        end
    end

    return nil
end

function GwObjectivesContainerMixin:GetQuestWatchId(questID)
    for i = 1, C_QuestLog.GetNumQuestWatches() do
        if questID == C_QuestLog.GetQuestIDForQuestWatchIndex(i) then
            return i
        end
    end

    return nil
end

function GwObjectivesContainerMixin:UpdateQuestLogLayout()
    if self.isUpdating or not self.init then
        return
    end
    self.isUpdating = true

    local counterQuest = 0
    local savedContainerHeight = 1
    local shouldShowHeader = true
    local containerType = not self.isCampaignContainer and "QUEST"

    if not self.isCampaignContainer then self.header:Hide() end

    local numQuests = C_QuestLog.GetNumQuestWatches()
    if self.collapsed then
        self.header:Show()
        savedContainerHeight = 20
        shouldShowHeader = false
    end

    for i = 1, numQuests do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)

        -- check if we have a quest id to prevent errors
        if questID  then
            local q = QuestCache:Get(questID)
            local isCampaign = q:IsCampaign()
            if (isCampaign and self.isCampaignContainer) or (not isCampaign and not self.isCampaignContainer) then
                if shouldShowHeader then
                    self.header:Show()
                    counterQuest = counterQuest + 1

                    if counterQuest == 1 then
                        savedContainerHeight = 20
                    end

                    local block
                    if self.isCampaignContainer then
                        block  = self:GetBlock(counterQuest, "CAMPAIGN", true)
                    elseif not self.isCampaignContainer then
                        --if quest is reapeataple make it blue
                        local isFrequency = q.frequency and q.frequency > 0
                        if q.frequency == nil then
                            local questLogIndex = q:GetQuestLogIndex()
                            if questLogIndex and questLogIndex > 0 then
                                local questInfo = C_QuestLog.GetInfo(questLogIndex)
                                if questInfo then
                                    isFrequency = questInfo.frequency > 0
                                end
                            end
                        end
                        block = self:GetBlock(counterQuest, isFrequency and "DAILY" or "QUEST", true)
                        block.isFrequency = isFrequency
                    end
                    if block == nil then
                        return
                    end

                    block:UpdateQuest(self, q)
                    block:Show()
                    savedContainerHeight = savedContainerHeight + block.height
                    -- save some values for later use
                    block.savedHeight = savedContainerHeight
                    GW.CombatQueue_Queue("update_tracker_" .. self:GetName() .. block.index, block.UpdateQuestItemPositions, {block.actionButton, savedContainerHeight}, containerType)
                else
                    if (isCampaign and self.isCampaignContainer) or (not isCampaign and not self.isCampaignContainer) then
                        counterQuest = counterQuest + 1
                    end
                    if _G[self:GetName() .. "Block" .. counterQuest] then
                        _G[self:GetName() .. "Block" .. counterQuest]:Hide()
                        _G[self:GetName() .. "Block" .. counterQuest].questLogIndex = 0
                        GW.CombatQueue_Queue("update_tracker_" .. self:GetName() .. counterQuest, _G[self:GetName() .. "Block" .. counterQuest].UpdateQuestItem, {_G[self:GetName() .. "Block" .. counterQuest]})
                    end
                end
            end
        end
    end

    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(counterQuest > 0 and savedContainerHeight or 1)

    self.numQuests = counterQuest

    -- hide other quests
    for i = counterQuest + 1, 25 do
        if _G[self:GetName() .. "Block" .. i] then
            _G[self:GetName() .. "Block" .. i].questID = nil
            _G[self:GetName() .. "Block" .. i].questLogIndex = 0
            _G[self:GetName() .. "Block" .. i]:Hide()

            GW.CombatQueue_Queue("update_tracker_campaign_itembutton_remove" .. i, _G[self:GetName() .. "Block" .. i].UpdateQuestItem, {_G[self:GetName() .. "Block" .. i]})
        end
    end
    if counterQuest == 0 and self.isCampaignContainer then self.header:Hide() end

    -- Set number of quest to the Header
    self.header.title:SetText((self.isCampaignContainer and TRACKER_HEADER_CAMPAIGN_QUESTS or TRACKER_HEADER_QUESTS) .. " (" .. counterQuest .. ")")

    self.isUpdating = false
end

function GwObjectivesContainerMixin:UpdateQuestLogLayoutSingle(questID, added)
    if self.isUpdating or not self.init or not questID then
        return
    end
    self.isUpdating = true

    -- get the correct quest block for that questID
    local q = QuestCache:Get(questID)
    local isCampaign = q:IsCampaign()

    if self.collapsed or ((isCampaign and not self.isCampaignContainer) or (not isCampaign and self.isCampaignContainer)) then
        self.isUpdating = false
        return
    end
    local questLogIndex = q:GetQuestLogIndex()
    local isFrequency = q.frequency and q.frequency > 0
    if q.frequency == nil then
        if questLogIndex and questLogIndex > 0 then
            local questInfo = C_QuestLog.GetInfo(questLogIndex)
            if questInfo then
                isFrequency = questInfo.frequency > 0
            end
        end
    end

    local questWatchId = self:GetQuestWatchId(questID)
    local block = questWatchId and self:GetOrCreateBlockByQuestId(questID, isFrequency and "DAILY" or "QUEST")
    local header = self.header
    local savedHeight = 20
    local heightForQuestItem = 20
    local counterQuest = 0
    if questWatchId and block and questLogIndex and questLogIndex > 0 then
        block:UpdateQuestByID(self, q, questID, questLogIndex)
        block.isFrequency = isFrequency
        block:Show()
        if added == true then
            C_Timer.After(0.1, function() block:NewQuestAnimation() end)
        end

        for i = 1, 25 do
            if _G[self:GetName() .. "Block" .. i] and _G[self:GetName() .. "Block" .. i]:IsShown() and _G[self:GetName() .. "Block" .. i].questID ~= nil then
                savedHeight = savedHeight + _G[self:GetName() .. "Block" .. i].height
                counterQuest = counterQuest + 1
            elseif _G[self:GetName() .. "Block" .. i] and not _G[self:GetName() .. "Block" .. i]:IsShown() then
                _G[self:GetName() .. "Block" .. i]:Hide()
            end
        end

        self.oldHeight = GW.RoundInt(self:GetHeight())
        self:SetHeight(savedHeight)
        header:Show()

        if block.hasItem then
            for i = 1, 25 do
                if _G[self:GetName() .. "Block" .. i] and _G[self:GetName() .. "Block" .. i]:IsShown() and _G[self:GetName() .. "Block" .. i].questID ~= questID then
                    heightForQuestItem = heightForQuestItem + _G[self:GetName() .. "Block" .. i].height
                elseif _G[self:GetName() .. "Block" .. i] and _G[self:GetName() .. "Block" .. i]:IsShown() and _G[self:GetName() .. "Block" .. i].questID == questID then
                    heightForQuestItem = heightForQuestItem + _G[self:GetName() .. "Block" .. i].height
                    break
                end
            end
            GW.CombatQueue_Queue("update_tracker_quest_itembutton_position" .. block.index, block.UdateQuestItemPositions, {block.actionButton, heightForQuestItem, self.isCampaignContainer and nil or "QUEST"})
        end

        -- Set number of quest to the Header
        local headerCounterText = " (" .. counterQuest .. ")"
        header.title:SetText(self.isCampaignContainer and TRACKER_HEADER_CAMPAIGN_QUESTS .. headerCounterText or TRACKER_HEADER_QUESTS .. headerCounterText)
    end

    self.isUpdating = false
end

function GwObjectivesContainerMixin:CheckForAutoQuests()
    for i = 1, GetNumAutoQuestPopUps() do
        local questID, popUpType = GetAutoQuestPopUp(i)
        if questID and (popUpType == "OFFER" or popUpType == "COMPLETE") then
            --find our block with that questId
            local questBlock = self:GetBlockByQuestId(questID)
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
