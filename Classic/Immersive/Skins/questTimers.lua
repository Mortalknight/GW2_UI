local _, GW = ...

local function ApplyQuestTimersSkin()
    GW.RegisterMovableFrame(QuestTimerFrame, QUEST_TIMERS, "QUEST_TIMERS_FRAME_POSITION", ALL .. ",BLIZZARD", nil, {"default", "scaleable"})
    QuestTimerFrame:ClearAllPoints()
    QuestTimerFrame:SetPoint("TOPLEFT", QuestTimerFrame.gwMover)

    QuestTimerFrame:GwStripTextures()
    QuestTimerFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    QuestTimerHeader:SetPoint('TOP', 1, 8)

    hooksecurefunc(QuestTimerFrame, "SetPoint", function(_, _, parent)
        if parent ~= QuestTimerFrame.gwMover then
            QuestTimerFrame:ClearAllPoints()
            QuestTimerFrame:SetPoint("TOPLEFT", QuestTimerFrame.gwMover)
        end
    end)
end

local function LoadQuestTimersSkin()
    if not GW.settings.QUESTTIMERS_SKIN_ENABLED then return end
    GW.RegisterLoadHook(ApplyQuestTimersSkin, "Blizzard_QuestTimer", QuestTimerFrame)

    C_AddOns.LoadAddOn("Blizzard_QuestTimer")
end
GW.LoadQuestTimersSkin = LoadQuestTimersSkin