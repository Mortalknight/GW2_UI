---@class GW2
local GW = select(2, ...)

-- quarter of Pawn's arrow texture per advice result
local PAWN_ARROWS = {
    upgrade = { 0, 0.5, 0, 0.5 },
    vendor = { 0, 0.5, 0.5, 1 },
    trinket = { 0.5, 1, 0.5, 1 }, -- trinkets and relics
}

local coinMarker
local pawnArrows = {} -- per reward index

-- appends the share of the current level, e.g. "1200 (+3.45%)"
local function AppendXPShare(fontString, xp)
    local text, levelXP = fontString:GetText(), UnitXPMax("player")
    if text and xp and xp > 0 and levelXP > 0 then
        local share = GW.Colors.SkinColors.Positive:WrapTextInColorCode(format("(+%.2f%%)", xp / levelXP * 100))
        fontString:SetText(text .. " " .. share)
    end
end

local function AddQuestXPShare()
    if not GW.settings.general.questXpPercent then return end

    if not QuestInfoFrame.questLog then
        AppendXPShare(QuestInfoXPFrame.ValueText, GetRewardXP())
        return
    end

    local questID = C_QuestLog.GetSelectedQuest and C_QuestLog.GetSelectedQuest() or GetQuestID()
    if C_QuestLog.ShouldShowQuestRewards(questID) then
        AppendXPShare(MapQuestInfoRewardsFrame.XPFrame.Name, GetQuestLogRewardXP())
    end
end

local function ResetQuestRewardMarkers()
    coinMarker:Hide()
    for _, arrow in pairs(pawnArrows) do
        arrow:Hide()
    end
end
GW.ResetQuestRewardMostValueIcon = ResetQuestRewardMarkers

-- the choice that sells for the most gold, nil when none has a sell price
local function FindMostValuableChoice(numChoices)
    local bestIndex, bestValue = nil, 0
    for index = 1, numChoices do
        local link = GetQuestItemLink("choice", index)
        local _, _, amount = GetQuestItemInfo("choice", index)
        local sellPrice = link and select(11, C_Item.GetItemInfo(link)) or 0
        local value = sellPrice * (amount or 0)
        if value > bestValue then
            bestIndex, bestValue = index, value
        end
    end
    return bestIndex
end

local function ShowPawnAdvice(numChoices)
    if not (PawnGetItemData and PawnFindInterestingItems) then return end

    local rewards = {}
    for index = 1, numChoices do
        local _, _, _, _, usable = GetQuestItemInfo("choice", index)
        local item = PawnGetItemData(GetQuestItemLink("choice", index))
        if item then
            rewards[#rewards + 1] = { Item = item, RewardType = "choice", Usable = usable, Index = index }
        end
    end
    -- Pawn writes its verdict into reward.Result
    PawnFindInterestingItems(rewards)

    for _, reward in ipairs(rewards) do
        local coords = PAWN_ARROWS[reward.Result]
        local button = coords and QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame, reward.Index)
        if button then
            local arrow = pawnArrows[reward.Index]
            if not arrow then
                arrow = button:CreateTexture(nil, "OVERLAY", "PawnUI_QuestAdvisorTexture")
                arrow:SetDrawLayer("OVERLAY", 7)
                arrow:SetTexture("Interface/AddOns/Pawn/Textures/UpgradeArrowBig")
                pawnArrows[reward.Index] = arrow
            end
            arrow:SetTexCoord(unpack(coords))
            arrow:Show()
        end
    end
end

local function MarkQuestRewards()
    if not GW.settings.general.questRewardMostValueIcon then return end

    ResetQuestRewardMarkers()
    local numChoices = GetNumQuestChoices()
    if numChoices < 2 then return end

    local bestIndex = FindMostValuableChoice(numChoices)
    local button = bestIndex and _G["QuestInfoRewardsFrameQuestInfoItem" .. bestIndex]
    if button and button.type == "choice" then
        coinMarker:ClearAllPoints()
        coinMarker:SetPoint("TOPRIGHT", button, "TOPRIGHT", -2, -2)
        coinMarker:Show()
    end

    ShowPawnAdvice(numChoices)
end

local function InitializeMiscFunctions()
    coinMarker = CreateFrame("Frame", nil, QuestInfoRewardsFrame)
    coinMarker:SetFrameStrata("HIGH")
    coinMarker:SetSize(15, 15)
    coinMarker:Hide()

    local coin = coinMarker:CreateTexture(nil, "OVERLAY")
    coin:SetAllPoints()
    coin:SetTexture("Interface/AddOns/GW2_UI/textures/icons/coins.png")
    coin:SetTexCoord(0.33, 0.66, 0.022, 0.66)

    hooksecurefunc(QuestFrameRewardPanel, "Hide", function() coinMarker:Hide() end)

    local events = CreateFrame("Frame")
    events:RegisterEvent("QUEST_COMPLETE")
    events:SetScript("OnEvent", MarkQuestRewards)

    hooksecurefunc("QuestInfo_Display", AddQuestXPShare)
end
GW.InitializeMiscFunctions = InitializeMiscFunctions
