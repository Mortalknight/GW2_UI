---@class GW2
local GW = select(2, ...)

local function ApplyQuestTimersSkin()
    if ObjectiveTrackerFrame and QuestTimerFrame:GetParent() == ObjectiveTrackerFrame then
        QuestTimerFrame:SetParent(UIParent)
    end

    GW.RegisterMovableFrame(QuestTimerFrame, QUEST_TIMERS, "skins.questTimers", "BLIZZARD", nil, {GW.MoverOption.Scale})
    QuestTimerFrame:ClearAllPoints()
    QuestTimerFrame:SetPoint("TOPLEFT", QuestTimerFrame.gwMover)

    QuestTimerFrame:GwStripTextures()
    QuestTimerFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    if QuestTimerHeader then
        QuestTimerHeader:SetPoint('TOP', 1, 8)
    end
    if QuestTimerFrame.Border then
        QuestTimerFrame.Border:Hide()
    end

    hooksecurefunc(QuestTimerFrame, "SetPoint", function(_, _, parent)
        if parent ~= QuestTimerFrame.gwMover then
            QuestTimerFrame:ClearAllPoints()
            QuestTimerFrame:SetPoint("TOPLEFT", QuestTimerFrame.gwMover)
        end
    end)
end

local function LoadQuestTimersSkin()
    if not GW.settings.skins.questTimers.enabled then return end
    GW.RegisterLoadHook(ApplyQuestTimersSkin, "Blizzard_QuestTimer", QuestTimerFrame)
end
GW.LoadQuestTimersSkin = LoadQuestTimersSkin