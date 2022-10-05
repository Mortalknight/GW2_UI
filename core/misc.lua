local _, GW = ...

local mostValue

local function QuestRewardMostValueIcon()
    if not GW.GetSetting("QUEST_REWARDS_MOST_VALUE_ICON") then return end

    local firstItem = QuestInfoRewardsFrameQuestInfoItem1
    if not firstItem then return end

    local numQuests = GetNumQuestChoices()
    if numQuests < 2 then return end

    local bestValue, bestItem = 0, 0
    for i = 1, numQuests do
        local questLink = GetQuestItemLink("choice", i)
        local _, _, amount = GetQuestItemInfo("choice", i)
        local itemSellPrice = questLink and select(11, GetItemInfo(questLink))

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


end
GW.InitializeMiscFunctions = InitializeMiscFunctions