local tests = {}

tests.SingleAchievement = function(msg, editBox)
    gwDebug('expected: one achievment shows immediately')
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    AchievementAlertSystem:AddAlert(33)
end

tests.TwoAchievements = function(msg, editBox)
    gwDebug('expected: two achievements show immediately')
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    AchievementAlertSystem:AddAlert(33)
    AchievementAlertSystem:AddAlert(34)
end

tests.ThreeAchievements = function(msg, editBox)
    gwDebug('expected: two achievements show immediately, one shows after first two disappear')
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    AchievementAlertSystem:AddAlert(33)
    AchievementAlertSystem:AddAlert(34)
    AchievementAlertSystem:AddAlert(35)
end

tests.FourAchievementsDelay = function(msg, editBox)
    gwDebug('expected: two achievements show immediately, two more show after first two disappear')
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    AchievementAlertSystem:AddAlert(33)
    AchievementAlertSystem:AddAlert(34)
    AchievementAlertSystem:AddAlert(35)
    C_Timer.After(2, function()
        AchievementAlertSystem:AddAlert(36)
    end)
end

tests.ThreeCriteria = function(msg, editBox)
    gwDebug('expected: two criteria progress show immediately, third NEVER shows')
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    CriteriaAlertSystem:AddAlert(33, "Bloop33")
    CriteriaAlertSystem:AddAlert(34, "Bloop34")
    CriteriaAlertSystem:AddAlert(35, "Bloop35")
end

tests.CriteriaAchievementMix = function(msg, editBox)
    gwDebug('expected: two criteria progress and one achievement show immediately, second achievement shows after 2 seconds')
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    CriteriaAlertSystem:AddAlert(33, "Bloop33")
    AchievementAlertSystem:AddAlert(34)
    CriteriaAlertSystem:AddAlert(35, "Bloop35")
    C_Timer.After(2, function()
        AchievementAlertSystem:AddAlert(36)
    end)
end

tests.DungeonComplete = function(msg, editBox)
    gwDebug('expected: dungeon complete for Court of Stars Heroic with Timewarped Badge and Order Resource rewards')
    DungeonCompletionAlertSystem:AddAlert(gwMocks.BuildLFGRewardData(false))
end

tests.DungeonCompleteAchievement = function(msg, editBox)
    gwDebug('expected: dungeon complete for Court of Stars with two achievements')
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    DungeonCompletionAlertSystem:AddAlert(gwMocks.BuildLFGRewardData(false))
    AchievementAlertSystem:AddAlert(34)
    AchievementAlertSystem:AddAlert(35)
end

tests.BonusRoll = function(msg, editBox)
    gwDebug("expected: bonus roll window appears with 10s timer using Seal of Fate currency, rolls at 5s then 'wins' some gold, then goes away")
    BonusRollFrame_StartBonusRoll(242969, 1, 10, 1273, 14)
    BonusRollFrame.PromptFrame.RollButton:Disable()
    C_Timer.After(5, function()
        BonusRollFrame_OnEvent(BonusRollFrame, 'BONUS_ROLL_STARTED')
    end)
    C_Timer.After(7, function()
        BonusRollFrame_OnEvent(BonusRollFrame, 'BONUS_ROLL_RESULT', 'money', nil, 20000, nil)
    end)
end

tests.TalkingHead = function(msg, editBox)
    gwDebug("expected: talking head window appears with Thalyssra voice line, goes away when complete (~8s)")
    if not TalkingHeadFrame then
        TalkingHead_LoadUI()
    end
    TalkingHeadFrame_CloseImmediately()
    TalkingHeadFrame.MainFrame.Model:SetScript('OnModelLoaded', gwMocks.TalkingHeadFrame_OnModelLoaded)
    gwMocks.TalkingHeadFrame_PlayCurrent()
    C_Timer.After(7, TalkingHeadFrame_Close)
    C_Timer.After(9, function()
        TalkingHeadFrame.MainFrame.Model:SetScript('OnModelLoaded', TalkingHeadFrame_OnModelLoaded)
    end)
end

tests.TalkingHeadAchievement = function(msg, editBox)
    gwDebug("expected: talking head window appears with two achievements")
    if not TalkingHeadFrame then
        TalkingHead_LoadUI()
    end
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    TalkingHeadFrame_CloseImmediately()
    TalkingHeadFrame.MainFrame.Model:SetScript('OnModelLoaded', gwMocks.TalkingHeadFrame_OnModelLoaded)
    gwMocks.TalkingHeadFrame_PlayCurrent()
    C_Timer.After(7, TalkingHeadFrame_Close)
    C_Timer.After(9, function()
        TalkingHeadFrame.MainFrame.Model:SetScript('OnModelLoaded', TalkingHeadFrame_OnModelLoaded)
    end)
    AchievementAlertSystem:AddAlert(34)
    AchievementAlertSystem:AddAlert(35)
end

function gwAlertTestsSetup()
    _G['SLASH_GW_TEST_ALERT1'] = '/gwtestalert'
    SlashCmdList['GW_TEST_ALERT'] = function(msg, editBox)
        if not msg or not tests[msg] then
            gwDebug('use /gwtestalert <testname>')
            gwDebug('expected: for all tests, it is expected that alerts stack, growing upwards, without ever overlapping the action bar or multibars, with no errors or taint, INCLUDING IN COMBAT')
            gwDebug('available alert tests:')
            for k, _ in pairs(tests) do
                gwDebug(' ', k)
            end
        else
            gwDebug('running alert test:', msg)
            tests[msg](msg, editBox)
        end
    end
end
