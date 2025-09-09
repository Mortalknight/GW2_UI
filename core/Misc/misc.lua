local _, GW = ...

local mostValue = {}
local upgradeIconsByPawn = {}

local function QuestXPPercent()
    if not GW.settings.QUEST_XP_PERCENT then return end

    local _, unitXPMax = UnitXP("player"), UnitXPMax("player")
    if QuestInfoFrame.questLog then
        local selectedQuest = GW.Retail and C_QuestLog.GetSelectedQuest() or GetQuestID()
        if C_QuestLog.ShouldShowQuestRewards(selectedQuest) then
            local xp = GetQuestLogRewardXP()
            if xp and xp > 0 then
                local text = MapQuestInfoRewardsFrame.XPFrame.Name:GetText()
                if text then MapQuestInfoRewardsFrame.XPFrame.Name:SetFormattedText("%s (|cff4beb2c+%.2f%%|r)", text, (xp / unitXPMax) * 100) end
            end
        end
    else
        local xp = GetRewardXP()
        if xp and xp > 0 then
            local text = QuestInfoXPFrame.ValueText:GetText()
            if text then QuestInfoXPFrame.ValueText:SetFormattedText("%s (|cff4beb2c+%.2f%%|r)", text, (xp / unitXPMax) * 100) end
        end
    end
end

local function ResetQuestRewardMostValueIcon()
    -- hide all old overlays
    for i = 1, MAX_NUM_ITEMS do
        if upgradeIconsByPawn[i] then upgradeIconsByPawn[i]:Hide() end
    end

    if mostValue then mostValue:Hide() end
end
GW.ResetQuestRewardMostValueIcon = ResetQuestRewardMostValueIcon

local function QuestRewardMostValueIcon()
    if not GW.settings.QUEST_REWARDS_MOST_VALUE_ICON then return end

    ResetQuestRewardMostValueIcon()

    local firstItem = QuestInfoRewardsFrameQuestInfoItem1
    if not firstItem then return end

    local numQuestChoices = GetNumQuestChoices()
    if numQuestChoices < 2 then return end

    local questRewards = {}
    local bestValue, bestItem = 0, 0
    for i = 1, numQuestChoices do
        local itemLink = GetQuestItemLink("choice", i)
        local _, _, amount, _, usable = GetQuestItemInfo("choice", i)
        local itemSellPrice = itemLink and select(11, C_Item.GetItemInfo(itemLink))
        local item = PawnGetItemData and PawnGetItemData(itemLink)

        if item then
            tinsert(questRewards, { Item = item, RewardType = "choice", Usable = usable, Index = i })
        end

        if itemSellPrice and itemSellPrice > 0 then
            local totalValue = (amount and amount > 0) and (itemSellPrice * amount) or 0
            if totalValue > bestValue then
                bestValue = totalValue
                bestItem = i
            end
        end
    end

    if bestItem then
        local btn = _G["QuestInfoRewardsFrameQuestInfoItem" .. bestItem]
        if btn and btn.type == "choice" then
            mostValue:ClearAllPoints()
            mostValue:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
            mostValue:SetFrameStrata("HIGH")
            mostValue:Show()
        end
    end

    if PawnFindInterestingItems then PawnFindInterestingItems(questRewards) end

    for _, reward in pairs(questRewards) do
        local itemButton = QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame, reward.Index)
        if itemButton then
            local overlay = upgradeIconsByPawn[reward.Index]
            if not overlay then
                overlay = itemButton:CreateTexture(nil, "OVERLAY", "PawnUI_QuestAdvisorTexture")
                overlay:SetDrawLayer("OVERLAY", 7)

                upgradeIconsByPawn[reward.Index] = overlay
            end
            if reward.Result == "upgrade" then
                overlay:SetTexture("Interface/AddOns/Pawn/Textures/UpgradeArrowBig")
                overlay:SetTexCoord(0, .5, 0, .5)
                overlay:Show()
            elseif reward.Result == "vendor" then
                overlay:SetTexture("Interface/AddOns/Pawn/Textures/UpgradeArrowBig")
                overlay:SetTexCoord(0, .5, .5, 1)
                overlay:Show()
            elseif reward.Result == "trinket" then -- trinkets or relics
                overlay:SetTexture("Interface/AddOns/Pawn/Textures/UpgradeArrowBig")
                overlay:SetTexCoord(.5, 1, .5, 1)
                overlay:Show()
            end
        end
    end
end

local function InitializeMiscFunctions()
    local MiscFrame = CreateFrame("Frame")

    mostValue = CreateFrame("Frame", "GW2UI_QuestRewardGoldIconFrame", QuestInfoRewardsFrame)
    mostValue:SetFrameStrata("HIGH")
    mostValue:SetSize(15, 15)
    mostValue:Hide()

    mostValue.Icon = mostValue:CreateTexture(nil, "OVERLAY")
    mostValue.Icon:SetAllPoints(mostValue)
    mostValue.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/Coins")
    mostValue.Icon:SetTexCoord(0.33, 0.66, 0.022, 0.66)

    hooksecurefunc(QuestFrameRewardPanel, "Hide", function()
        if mostValue then
            mostValue:Hide()
        end
    end)

    MiscFrame:RegisterEvent("QUEST_COMPLETE") -- used for quest gold reward icon

    MiscFrame:SetScript("OnEvent", QuestRewardMostValueIcon)

    --Add (+X%) to quest rewards experience text
    hooksecurefunc("QuestInfo_Display", QuestXPPercent)
end
GW.InitializeMiscFunctions = InitializeMiscFunctions