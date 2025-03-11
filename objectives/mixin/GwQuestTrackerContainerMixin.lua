local _, GW = ...

GwQuestTrackerContainerMixin = {}
function GwQuestTrackerContainerMixin:GetQuestBlock(blockIndex, isFrequency)
    if _G["GwQuestBlock" .. blockIndex] then
        local block = _G["GwQuestBlock" .. blockIndex]
        -- set the correct block color for an existing block here
        block:SetBlockColorByKey(isFrequency and "DAILY" or "QUEST")
        block.Header:SetTextColor(block.color.r, block.color.g, block.color.b)
        block.hover:SetVertexColor(block.color.r, block.color.g, block.color.b)
        for i = 1, 20 do
            if _G[block:GetName() .. "GwQuestObjective" .. i] then
                _G[block:GetName() .. "GwQuestObjective" .. i].StatusBar:SetStatusBarColor(block.color.r, block.color.g, block.color.b)
            end
        end
        return block
    end

    local newBlock = CreateFrame("Button", "GwQuestBlock" .. blockIndex, GwQuesttrackerContainerQuests, "GwObjectivesBlockTemplate")
    newBlock:SetParent(GwQuesttrackerContainerQuests)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerQuests, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwQuestBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end

    newBlock.index = blockIndex
    newBlock:SetBlockColorByKey(isFrequency and "DAILY" or "QUEST")
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)

    -- quest item button here
    newBlock.actionButton = CreateFrame("Button", nil, GwQuestTracker, "GwQuestItemTemplate")
    newBlock.actionButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    newBlock.actionButton.NormalTexture:SetTexture(nil)
    newBlock.actionButton:RegisterForClicks("AnyUp", "AnyDown")
    newBlock.actionButton:SetScript("OnShow", newBlock.actionButton.OnShow)
    newBlock.actionButton:SetScript("OnHide", newBlock.actionButton.OnHide)
    newBlock.actionButton:SetScript("OnEnter", newBlock.actionButton.OnEnter)
    newBlock.actionButton:SetScript("OnLeave", GameTooltip_Hide)
    newBlock.actionButton:SetScript("OnEvent", newBlock.actionButton.OnEvent)

    return newBlock
end

function GwQuestTrackerContainerMixin:GetCampaignBlock(blockIndex)
    if _G["GwCampaignBlock" .. blockIndex] then
        return _G["GwCampaignBlock" .. blockIndex]
    end

    local newBlock = CreateFrame("Button", "GwCampaignBlock" .. blockIndex, GwQuesttrackerContainerCampaign, "GwObjectivesBlockTemplate")
    newBlock:SetParent(GwQuesttrackerContainerCampaign)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerCampaign, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwCampaignBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end

    newBlock.index = blockIndex
    newBlock:SetBlockColorByKey("CAMPAIGN")
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)

    -- quest item button here
    newBlock.actionButton = CreateFrame("Button", nil, GwQuestTracker, "GwQuestItemTemplate")
    newBlock.actionButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    newBlock.actionButton.NormalTexture:SetTexture(nil)
    newBlock.actionButton:RegisterForClicks("AnyUp", "AnyDown")
    newBlock.actionButton:SetScript("OnShow", newBlock.actionButton.OnShow)
    newBlock.actionButton:SetScript("OnHide", newBlock.actionButton.OnHide)
    newBlock.actionButton:SetScript("OnEnter", newBlock.actionButton.OnEnter)
    newBlock.actionButton:SetScript("OnLeave", GameTooltip_Hide)
    newBlock.actionButton:SetScript("OnEvent", newBlock.actionButton.OnEvent)

    return newBlock
end

function GwQuestTrackerContainerMixin:GetBlockById(questID)
    for i = 1, 50 do -- loop quest and campaign
        local block = _G[(i <= 25 and "GwCampaignBlock" or "GwQuestBlock") .. (i <= 25 and i or i - 25)]
        if block then
            if block.questID == questID then
                return block
            end
        end
    end

    return nil
end

function GwQuestTrackerContainerMixin:GetBlockByIdAndType(container, questID, isCampaign, isFrequency)
    local blockName = isCampaign and "GwCampaignBlock" or "GwQuestBlock"

    for i = 1, 25 do
        if _G[blockName .. i] then
            if _G[blockName .. i].questID == questID then
                return _G[blockName .. i]
            elseif _G[blockName .. i].questID == nil then
                return isCampaign and container:GetCampaignBlock(i) or container:GetQuestBlock(i, isFrequency)
            end
        else
            return isCampaign and container:GetCampaignBlock(i) or container:GetQuestBlock(i, isFrequency)
        end
    end

    return nil
end

function GwQuestTrackerContainerMixin:GetQuestWatchId(questID)
    for i = 1, C_QuestLog.GetNumQuestWatches() do
        if questID == C_QuestLog.GetQuestIDForQuestWatchIndex(i) then
            return i
        end
    end

    return nil
end

function GwQuestTrackerContainerMixin:UpdateQuestLogLayout()
    if self.isUpdating or not self.init then
        return
    end
    self.isUpdating = true

    local counterQuest = 0
    local counterCampaign = 0
    local savedHeightQuest = 1
    local savedHeightCampagin = 1
    local shouldShowQuests = true
    local shouldShowCampaign = true
    GwQuesttrackerContainerQuests.header:Hide()

    local numQuests = C_QuestLog.GetNumQuestWatches()
    if GwQuesttrackerContainerCampaign.collapsed then
        GwQuesttrackerContainerCampaign.header:Show()
        savedHeightCampagin = 20
        shouldShowCampaign = false
    end
    if GwQuesttrackerContainerQuests.collapsed then
        GwQuesttrackerContainerQuests.header:Show()
        savedHeightQuest = 20
        shouldShowQuests = false
    end

    for i = 1, numQuests do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)

        -- check if we have a quest id to prevent errors
        if questID then
            local q = QuestCache:Get(questID)
            -- Campaing Quests
            if q and q:IsCampaign() then
                if shouldShowCampaign then
                    GwQuesttrackerContainerCampaign.header:Show()
                    counterCampaign = counterCampaign + 1

                    if counterCampaign == 1 then
                        savedHeightCampagin = 20
                    end
                    local block = self:GetCampaignBlock(counterCampaign)
                    if block == nil then
                        return
                    end

                    block:UpdateQuest(self, q)
                    block:Show()
                    savedHeightCampagin = savedHeightCampagin + block.height
                    -- save some values for later use
                    block.savedHeight = savedHeightCampagin
                    GW.CombatQueue_Queue("update_tracker_campaign_itembutton_position" .. block.index, block.UpdateQuestItemPositions, {block.actionButton, savedHeightCampagin})
                else
                    counterCampaign = counterCampaign + 1
                    if _G["GwCampaignBlock" .. counterCampaign] then
                        _G["GwCampaignBlock" .. counterCampaign]:Hide()
                        _G["GwCampaignBlock" .. counterCampaign].questLogIndex = 0
                        GW.CombatQueue_Queue("update_tracker_campaign_itembutton_remove" .. counterCampaign, _G["GwCampaignBlock" .. counterCampaign].UpdateQuestItem, {_G["GwCampaignBlock" .. counterCampaign]})
                    end
                end
            elseif q then
                if shouldShowQuests then
                    GwQuesttrackerContainerQuests.header:Show()
                    counterQuest = counterQuest + 1

                    if counterQuest == 1 then
                        savedHeightQuest = 20
                    end
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
                    local block = self:GetQuestBlock(counterQuest, isFrequency)
                    if block == nil then
                        return
                    end
                    block:UpdateQuest(self, q)
                    block.isFrequency = isFrequency
                    block:Show()
                    savedHeightQuest = savedHeightQuest + block.height

                    block.savedHeight = savedHeightQuest
                    GW.CombatQueue_Queue("update_tracker_quest_itembutton_position" .. block.index, block.UpdateQuestItemPositions, {block.actionButton, savedHeightQuest, "QUEST"})
                else
                    counterQuest = counterQuest + 1
                    if _G["GwQuestBlock" .. counterQuest] then
                        _G["GwQuestBlock" .. counterQuest]:Hide()
                        _G["GwQuestBlock" .. counterQuest].questLogIndex = 0
                        GW.CombatQueue_Queue("update_tracker_quest_itembutton_remove" .. counterQuest, _G["GwQuestBlock" .. counterQuest].UpdateQuestItem, {_G["GwQuestBlock" .. counterQuest]})
                    end
                end
            end
        end
    end

    GwQuesttrackerContainerCampaign.oldHeight = GW.RoundInt(GwQuesttrackerContainerCampaign:GetHeight())
    GwQuesttrackerContainerQuests.oldHeight = GW.RoundInt(GwQuesttrackerContainerQuests:GetHeight())
    GwQuesttrackerContainerCampaign:SetHeight(counterCampaign > 0 and savedHeightCampagin or 1)
    GwQuesttrackerContainerQuests:SetHeight(counterQuest > 0 and savedHeightQuest or 1)

    GwQuesttrackerContainerQuests.numQuests = counterQuest
    GwQuesttrackerContainerCampaign.numQuests = counterCampaign

    -- hide other quests
    for i = counterCampaign + 1, 25 do
        if _G["GwCampaignBlock" .. i] then
            _G["GwCampaignBlock" .. i].questID = nil
            _G["GwCampaignBlock" .. i].questLogIndex = 0
            _G["GwCampaignBlock" .. i]:Hide()
            GW.CombatQueue_Queue("update_tracker_campaign_itembutton_remove" .. i, _G["GwCampaignBlock" .. i].UpdateQuestItem, {_G["GwCampaignBlock" .. i]})
        end
    end
    for i = counterQuest + 1, 25 do
        if _G["GwQuestBlock" .. i] then
            _G["GwQuestBlock" .. i].questID = nil
            _G["GwQuestBlock" .. i].questLogIndex = 0
            _G["GwQuestBlock" .. i]:Hide()
            GW.CombatQueue_Queue("update_tracker_quest_itembutton_remove" .. i, _G["GwQuestBlock" .. i].UpdateQuestItem, {_G["GwQuestBlock" .. i]})
        end
    end

    if counterCampaign == 0 then GwQuesttrackerContainerCampaign.header:Hide() end

    -- Set number of quest to the Header
    GwQuesttrackerContainerQuests.header.title:SetText(TRACKER_HEADER_QUESTS .. " (" .. counterQuest .. ")")
    GwQuesttrackerContainerCampaign.header.title:SetText(TRACKER_HEADER_CAMPAIGN_QUESTS .. " (" .. counterCampaign .. ")")

    self.isUpdating = false
end

function GwQuestTrackerContainerMixin:UpdateQuestLogLayoutSingle(questID, added)
    if self.isUpdating or not self.init or not questID then
        return
    end
    self.isUpdating = true

    -- get the correct quest block for that questID
    local q = QuestCache:Get(questID)
    local isCampaign = q:IsCampaign()
    if (isCampaign and GwQuesttrackerContainerCampaign.collapsed) or GwQuesttrackerContainerQuests.collapsed then
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
    local block = questWatchId and self:GetBlockByIdAndType(self, questID, isCampaign, isFrequency)
    local blockName = isCampaign and "GwCampaignBlock" or "GwQuestBlock"
    local containerName = isCampaign and GwQuesttrackerContainerCampaign or GwQuesttrackerContainerQuests
    local header = containerName.header
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
            if _G[blockName .. i] and _G[blockName .. i]:IsShown() and _G[blockName .. i].questID ~= nil then
                savedHeight = savedHeight + _G[blockName .. i].height
                counterQuest = counterQuest + 1
            elseif _G[blockName .. i] and not _G[blockName .. i]:IsShown() then
                _G[blockName .. i]:Hide()
            end
        end

        containerName.oldHeight = GW.RoundInt(containerName:GetHeight())
        containerName:SetHeight(savedHeight)
        header:Show()

        if block.hasItem then
            for i = 1, 25 do
                if _G[blockName .. i] and _G[blockName .. i]:IsShown() and _G[blockName .. i].questID ~= questID then
                    heightForQuestItem = heightForQuestItem + _G[blockName .. i].height
                elseif _G[blockName .. i] and _G[blockName .. i]:IsShown() and _G[blockName .. i].questID == questID then
                    heightForQuestItem = heightForQuestItem + _G[blockName .. i].height
                    break
                end
            end
            GW.CombatQueue_Queue("update_tracker_quest_itembutton_position" .. block.index, block.UdateQuestItemPositions, {block.actionButton, heightForQuestItem, isCampaign and nil or "QUEST"})
        end

        -- Set number of quest to the Header
        local headerCounterText = " (" .. counterQuest .. ")"
        header.title:SetText(isCampaign and TRACKER_HEADER_CAMPAIGN_QUESTS .. headerCounterText or TRACKER_HEADER_QUESTS .. headerCounterText)
    end

    self.isUpdating = false
end

function GwQuestTrackerContainerMixin:CheckForAutoQuests()
    for i = 1, GetNumAutoQuestPopUps() do
        local questID, popUpType = GetAutoQuestPopUp(i)
        if questID and (popUpType == "OFFER" or popUpType == "COMPLETE") then
            --find our block with that questId
            local questBlock = self:GetBlockById(questID)
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
