local _, GW = ...

local QuestRewardGoldIconOverlay = {}

local function ResetQuestRewardMostValueIcon()
    -- hide all old overlays
    for i = 1, MAX_NUM_ITEMS do
        if QuestRewardGoldIconOverlay[i] then QuestRewardGoldIconOverlay[i]:Hide() end
    end
end
GW.ResetQuestRewardMostValueIcon = ResetQuestRewardMostValueIcon

local function QuestRewardMostValueIcon()
    if not GW.GetSetting("QUEST_REWARDS_MOST_VALUE_ICON") then return end

    ResetQuestRewardMostValueIcon()

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
        local btn = _G["misc.lua" .. bestItem]
        if btn and btn.type == "choice" then
            local questRewardGoldOverlay = QuestRewardGoldIconOverlay[bestItem]

            if not questRewardGoldOverlay then
                questRewardGoldOverlay = btn:CreateTexture(nil, "OVERLAY")
                questRewardGoldOverlay:SetPoint("TOPLEFT", -5, 5)
                questRewardGoldOverlay:SetSize(15, 15)
                questRewardGoldOverlay:SetTexture("Interface/AddOns/GW2_UI/textures/icons/Coins")
                questRewardGoldOverlay:SetTexCoord(0.33, 0.66, 0.022, 0.66)
                questRewardGoldOverlay:SetDrawLayer("OVERLAY", 7)

                QuestRewardGoldIconOverlay[bestItem] = questRewardGoldOverlay
            end

            questRewardGoldOverlay:Show()
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

    MiscFrame:RegisterEvent("QUEST_COMPLETE") -- used for quest gold reward icon

    MiscFrame:SetScript("OnEvent", MiscFrameOnEvent)
end
GW.InitializeMiscFunctions = InitializeMiscFunctions