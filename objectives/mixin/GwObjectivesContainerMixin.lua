local _, GW = ...

GwObjectivesContainerMixin = {}

function GwObjectivesContainerMixin:UpdateLayout()
    -- override per module
end

function GwObjectivesContainerMixin:BlockOnClick()
    -- override per module
end

function GwObjectivesContainerMixin:CollapseHeader(forceCollapse, forceOpen)
    if (not self.collapsed or forceCollapse) and not forceOpen then
        self.collapsed = true
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        self.collapsed = false
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    self:UpdateLayout()
end

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

    newBlock:SetScript("OnMouseDown", self.BlockOnClick)

    if self.blockMixInTemplate then
        Mixin(newBlock, self.blockMixInTemplate)
    end

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
