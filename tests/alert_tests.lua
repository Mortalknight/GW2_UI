local _, GW = ...

local tests = {}

tests.SingleAchievement = function(msg, editBox)
    gwDebug("expected: one achievment shows immediately")
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    AchievementAlertSystem:AddAlert(33)
end

tests.TwoAchievements = function(msg, editBox)
    gwDebug("expected: two achievements show immediately")
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    AchievementAlertSystem:AddAlert(33)
    AchievementAlertSystem:AddAlert(34)
end

tests.ThreeAchievements = function(msg, editBox)
    gwDebug("expected: two achievements show immediately, one shows after first two disappear")
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    AchievementAlertSystem:AddAlert(33)
    AchievementAlertSystem:AddAlert(34)
    AchievementAlertSystem:AddAlert(35)
end

tests.FourAchievementsDelay = function(msg, editBox)
    gwDebug("expected: two achievements show immediately, two more show after first two disappear")
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    AchievementAlertSystem:AddAlert(33)
    AchievementAlertSystem:AddAlert(34)
    AchievementAlertSystem:AddAlert(35)
    C_Timer.After(
        2,
        function()
            AchievementAlertSystem:AddAlert(36)
        end
    )
end

tests.ThreeCriteria = function(msg, editBox)
    gwDebug("expected: two criteria progress show immediately, third NEVER shows")
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    CriteriaAlertSystem:AddAlert(33, "Bloop33")
    CriteriaAlertSystem:AddAlert(34, "Bloop34")
    CriteriaAlertSystem:AddAlert(35, "Bloop35")
end

tests.DungeonComplete = function(msg, editBox)
    gwDebug("expected: dungeon complete for Court of Stars Heroic with Timewarped Badge and Order Resource rewards")
    DungeonCompletionAlertSystem:AddAlert(gwMocks.BuildLFGRewardData(false))
end

tests.BonusRoll = function(msg, editBox)
    gwDebug(
        "expected: bonus roll window appears with 10s timer using Order Resources currency, rolls at 5s then 'wins' some gold, then goes away (if you do not have any Order Resources, window will not appear)"
    )
    BonusRollFrame_StartBonusRoll(242969, 1, 10, 1220, 14)
    BonusRollFrame.PromptFrame.RollButton:Disable()
    C_Timer.After(
        5,
        function()
            BonusRollFrame_OnEvent(BonusRollFrame, "BONUS_ROLL_STARTED")
        end
    )
    C_Timer.After(
        7,
        function()
            BonusRollFrame_OnEvent(BonusRollFrame, "BONUS_ROLL_RESULT", "money", nil, 20000, nil)
        end
    )
end

tests.TalkingHead = function(msg, editBox)
    gwDebug("expected: talking head window appears with Thalyssra voice line, goes away when complete (~8s)")
    if not TalkingHeadFrame then
        TalkingHead_LoadUI()
    end
    TalkingHeadFrame_CloseImmediately()
    TalkingHeadFrame.MainFrame.Model:SetScript("OnModelLoaded", gwMocks.TalkingHeadFrame_OnModelLoaded)
    gwMocks.TalkingHeadFrame_PlayCurrent()
    C_Timer.After(7, TalkingHeadFrame_Close)
    C_Timer.After(
        9,
        function()
            TalkingHeadFrame.MainFrame.Model:SetScript("OnModelLoaded", TalkingHeadFrame_OnModelLoaded)
        end
    )
end

tests.Money = function(msg, editBox)
    gwDebug("expected: money won alert appears")
    MoneyWonAlertSystem:AddAlert(333)
end

tests.Recipe = function(msg, editBox)
    gwDebug("expected: new recipe alert appears")
    NewRecipeLearnedAlertSystem:AddAlert(204)
end

tests.LegendaryLoot = function(msg, editBox)
    gwDebug("expected: legendary loot drop alert appears")
    local _, link, _ = GetItemInfo(18832)
    gwDebug(link)
    C_Timer.After(
        1,
        function()
            LegendaryItemAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r")
        end
    )
end

tests.StoreLoot = function(msg, editBox)
    gwDebug("expected: store loot purchase alert appears")
    StorePurchaseAlertSystem:AddAlert(
        "\124cffa335ee\124Hitem:180545::::::::::\124h[Mystic Runesaber]\124h\124r",
        "",
        "",
        214
    )
end

tests.MultiLoot = function(msg, editBox)
    gwDebug("expected: a combination of loot and upgrade alerts appear")
    local _, link, _ = GetItemInfo(18832)
    gwDebug(link)
    C_Timer.After(
        1,
        function()
            LootAlertSystem:AddAlert(
                "\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r",
                1,
                1,
                1,
                1,
                false,
                false,
                0,
                false,
                false
            )
            LootUpgradeAlertSystem:AddAlert(
                "\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r",
                1,
                1,
                1,
                nil,
                nil,
                false
            )
        end
    )
end

tests.GroupLoot = function(msg, editBox)
    gwDebug("expected: two group loot windows with countdowns that disappear near end of countdown")
    local rollID1 = GetTime() + 10
    local rollID2 = GetTime() + 11
    GroupLootFrame1:SetScript("OnShow", gwMocks.GroupLootFrame_OnShow)
    GroupLootFrame1.Timer:SetScript("OnUpdate", gwMocks.GroupLootFrame_OnUpdate)
    GroupLootFrame2:SetScript("OnShow", gwMocks.GroupLootFrame_OnShow)
    GroupLootFrame2.Timer:SetScript("OnUpdate", gwMocks.GroupLootFrame_OnUpdate)
    GroupLootFrame3:SetScript("OnShow", gwMocks.GroupLootFrame_OnShow)
    GroupLootFrame3.Timer:SetScript("OnUpdate", gwMocks.GroupLootFrame_OnUpdate)
    GroupLootFrame4:SetScript("OnShow", gwMocks.GroupLootFrame_OnShow)
    GroupLootFrame4.Timer:SetScript("OnUpdate", gwMocks.GroupLootFrame_OnUpdate)
    GroupLootFrame_OpenNewFrame(rollID1, 10)
    GroupLootFrame_OpenNewFrame(rollID2, 11)
    C_Timer.After(
        10,
        function()
            GroupLootFrame_OnEvent(GroupLootFrame1, "CANCEL_LOOT_ROLL", rollID1)
            GroupLootFrame_OnEvent(GroupLootFrame2, "CANCEL_LOOT_ROLL", rollID2)
        end
    )
    C_Timer.After(
        11,
        function()
            GroupLootFrame1:SetScript("OnShow", GroupLootFrame_OnShow)
            GroupLootFrame1.Timer:SetScript("OnUpdate", GroupLootFrame_OnUpdate)
            GroupLootFrame2:SetScript("OnShow", GroupLootFrame_OnShow)
            GroupLootFrame2.Timer:SetScript("OnUpdate", GroupLootFrame_OnUpdate)
            GroupLootFrame3:SetScript("OnShow", GroupLootFrame_OnShow)
            GroupLootFrame3.Timer:SetScript("OnUpdate", GroupLootFrame_OnUpdate)
            GroupLootFrame4:SetScript("OnShow", GroupLootFrame_OnShow)
            GroupLootFrame4.Timer:SetScript("OnUpdate", GroupLootFrame_OnUpdate)
        end
    )
end

function gwAlertTestsSetup()
    _G["SLASH_GW_TEST_ALERT1"] = "/gwtestalert"
    SlashCmdList["GW_TEST_ALERT"] = function(msg, editBox)
        local args = {}
        for arg in msg:gmatch("%w+") do
            tinsert(args, arg)
        end
        if not msg or not args or #args < 1 then
            gwDebug("use /gwtestalert <testname1> [testname2] ...")
            gwDebug(
                "Multiple tests can be combined by specifying more than one test name (separated by spaces). This is a good way to test alert combinations. The alerts are added simultaneously."
            )
            gwDebug(
                "expected: for all tests, it is expected that alerts stack, growing upwards, without ever overlapping the action bar or multibars, with no errors or taint, INCLUDING IN COMBAT"
            )
            gwDebug("available alert tests:")
            for k, _ in pairs(tests) do
                gwDebug(" ", k)
            end
        else
            gwDebug("running alert tests:", msg)
            for i = 1, #args do
                if tests[args[i]] then
                    tests[args[i]](msg, editBox)
                end
            end
        end
    end
end
