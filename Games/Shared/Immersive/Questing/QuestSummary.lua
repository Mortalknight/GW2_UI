---@class GW2
local GW = select(2, ...)

GwImmersiveQuestingSummaryFrameMixin = {}

function GwImmersiveQuestingSummaryFrameMixin:ClearInfo()
    self.quest_id = nil
    self.quest_idx = nil
    self.has_rewards = false
    self:SetObjectiveText(nil)
    self.reqItems:ClearInfo()
    self.reqItems:Hide()
end

function GwImmersiveQuestingSummaryFrameMixin:SetObjectiveText(text)
    self.objective_text = text
    self.objectiveText:SetText(text)
    if text then
        self.objectiveHeader:Show()
    else
        self.objectiveHeader:Hide()
    end
end

local function styleBlizzRewards(f_rewards)
    if f_rewards.RewardButtons then
        for i, quest_item in ipairs(f_rewards.RewardButtons) do
            local point, relativeTo, relativePoint, _, y = quest_item:GetPoint()
            if point and relativeTo and relativePoint then
                if i == 1 then
                    quest_item:SetPoint(point, relativeTo, relativePoint, 0, y)
                elseif relativePoint == "BOTTOMLEFT" then
                    quest_item:SetPoint(point, relativeTo, relativePoint, 0, -4)
                else
                    quest_item:SetPoint(point, relativeTo, relativePoint, 4, 0)
                end
            end
        end
    end

    local styleText = function(text)
        if not text then
            return
        end
        text:SetTextColor(1, 1, 1)
        text:SetShadowColor(0, 0, 0, 1)
        text:SetShadowOffset(1, -1)
    end

    styleText(QuestInfoRewardText)
    styleText(f_rewards.ItemChooseText)
    styleText(f_rewards.ItemReceiveText)
    styleText(QuestInfoXPFrame and QuestInfoXPFrame.ReceiveText)
    styleText(f_rewards.Header)
    styleText(f_rewards.SpellLearnText)
    styleText(f_rewards.PlayerTitleText)
    styleText(f_rewards.XPFrame and f_rewards.XPFrame.ReceiveText)
end

local function unstyleBlizzRewards(f_rewards)
    local unstyleText = function(text)
        if not text then
            return
        end
        text:SetTextColor(0, 0, 0)
        text:SetShadowColor(0, 0, 0, 0)
        text:SetShadowOffset(0, 0)
    end

    unstyleText(QuestInfoRewardText)
    unstyleText(f_rewards.ItemChooseText)
    unstyleText(f_rewards.ItemReceiveText)
    unstyleText(QuestInfoXPFrame and QuestInfoXPFrame.ReceiveText)
    unstyleText(f_rewards.Header)
    unstyleText(f_rewards.SpellLearnText)
    unstyleText(f_rewards.PlayerTitleText)
    unstyleText(f_rewards.XPFrame and f_rewards.XPFrame.ReceiveText)
end

function GwImmersiveQuestingSummaryFrameMixin:UpdateRewards()
    local f_rwd = QuestInfoRewardsFrame
    if (not f_rwd or not f_rwd:IsShown()) then
        self.has_rewards = false
        return
    end
    self.has_rewards = true

    -- restyle and then steal Blizz's quest reward frame
    -- TODO: not a fan of just stealing the blizz reward panel despite the simplicity
    -- see Blizzard_UIPanels_Game/Mainline/QuestInfo.xml to clone/mimic this eventually
    local qinfoHeight = 300
    --local qinfoTop = -20
    self.old_height = f_rwd:GetHeight()
    self.old_parent = f_rwd:GetParent()
    self.old_flevel = f_rwd:GetFrameLevel()
    self.old_handle = f_rwd
    styleBlizzRewards(f_rwd)
    f_rwd:SetParent(self)
    f_rwd:SetHeight(qinfoHeight)
    f_rwd:ClearAllPoints()
    f_rwd:SetFrameLevel(5)
    f_rwd:SetPoint("TOPLEFT", self.objectiveText, "BOTTOMLEFT", 0, -15)
end

function GwImmersiveQuestingSummaryFrameMixin:ReleaseRewards()
    local f_rwd = self.old_handle
    if not f_rwd then
        return
    end

    unstyleBlizzRewards(f_rwd)
    f_rwd:SetParent(self.old_parent or UIParent)
    self.old_parent = nil
    f_rwd:SetHeight(self.old_height or 300)
    self.old_height = nil
    f_rwd:ClearAllPoints()
    f_rwd:SetFrameLevel(self.old_flevel or 1)
    self.old_flevel = nil
    f_rwd:Hide()
    self.old_handle = nil
end

function GwImmersiveQuestingSummaryFrameMixin:UpdateInfo(quest_id, quest_idx, state)
    self.quest_id = quest_id
    self.quest_idx = quest_idx
    if state == "PROGRESS" then
        -- show required items in summary, if avail
        self.reqItems:UpdateInfo()
        if self.reqItems:HasRequiredItems() then
            self.reqItems:UpdateFrame()
            self.reqItems:Show()
        end
    else
        -- show rewards in summary, if avail
        self:UpdateRewards()
    end
end

function GwImmersiveQuestingSummaryFrameMixin:IsEmpty()
    if self.objective_text or self.has_rewards or self.reqItems:HasRequiredItems() then
        return false
    end
    return true
end
