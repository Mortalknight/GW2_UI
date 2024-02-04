local _, GW = ...

local function LoadQuestTimersSkin()
    if not GW.GetSetting("QUESTTIMERS_SKIN_ENABLED") then return end

    GW.RegisterMovableFrame(QuestTimerFrame, QUEST_TIMERS, "QUEST_TIMERS_FRAME_POSITION", ALL .. ",BLIZZARD", nil, {"default", "scaleable"})
    QuestTimerFrame:ClearAllPoints()
    QuestTimerFrame:SetPoint("TOPLEFT", QuestTimerFrame.gwMover)

    QuestTimerFrame:StripTextures()
    QuestTimerFrame:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder)
    QuestTimerHeader:SetPoint('TOP', 1, 8)


    hooksecurefunc(QuestTimerFrame, "SetPoint", function(_, _, parent)
		if parent ~= QuestTimerFrame.gwMover then
			QuestTimerFrame:ClearAllPoints()
			QuestTimerFrame:SetPoint("TOPLEFT", QuestTimerFrame.gwMover)
		end
	end)
end
GW.LoadQuestTimersSkin = LoadQuestTimersSkin