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

    local numQuests = GetNumQuestChoices()
    if numQuests < 2 then return end

    local bestValue, bestItem = 0, 0
    for i = 1, numQuests do
        local questLink = GetQuestItemLink("choice", i)
        local _, _, amount = GetQuestItemInfo("choice", i)
        local itemSellPrice = questLink and select(11, C_Item.GetItemInfo(questLink))
        local itemIsUpgrade = questLink and PawnShouldItemLinkHaveUpgradeArrow and PawnShouldItemLinkHaveUpgradeArrow(questLink)
        local upgradeIconByPawn = upgradeIconsByPawn[i]

        if itemIsUpgrade then
            if not upgradeIconByPawn then
                upgradeIconByPawn = _G["QuestInfoRewardsFrameQuestInfoItem" .. i]:CreateTexture(nil, "OVERLAY")
                upgradeIconByPawn:SetPoint("BOTTOMRIGHT", _G["QuestInfoRewardsFrameQuestInfoItem" .. i], "BOTTOMRIGHT", -2, 2)
                upgradeIconByPawn:SetSize(15, 15)
                upgradeIconByPawn:SetAtlas("bags-greenarrow", true)
                upgradeIconByPawn:SetDrawLayer("OVERLAY", 7)
                upgradeIconByPawn:Hide()

                upgradeIconsByPawn[i] = upgradeIconByPawn
            end
            upgradeIconByPawn:Show()
        end

        local totalValue = (itemSellPrice and itemSellPrice * amount) or 0
        if totalValue > bestValue then
            bestValue = totalValue
            bestItem = i
        end
    end

    if bestItem > 0 then
        local btn = _G["QuestInfoRewardsFrameQuestInfoItem" .. bestItem]
        if btn and btn.type == "choice" then
            mostValue:ClearAllPoints()
            mostValue:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
            mostValue:Show()
        end
    end
end

local function MiscFrameOnEvent(_, event)
    if event == "QUEST_COMPLETE" then
        QuestRewardMostValueIcon()
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

    MiscFrame:SetScript("OnEvent", MiscFrameOnEvent)

    --Add (+X%) to quest rewards experience text
    hooksecurefunc("QuestInfo_Display", QuestXPPercent)
end
GW.InitializeMiscFunctions = InitializeMiscFunctions