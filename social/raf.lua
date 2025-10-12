local _, GW = ...

local function RAFRewards()
    for reward in RecruitAFriendRewardsFrame.rewardPool:EnumerateActive() do
        reward.Button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        reward.Button.IconBorder:GwKill()
    end
end

local function LoadRecruitAFriendList(tabContainer)
    local RAFFrame = CreateFrame("Frame", "GwRAFWindow", tabContainer, "GwRAFWindow")
    --[[
    RecruitAFriendFrame.RewardClaiming:SetParent(RAFFrame.claming)
    RecruitAFriendFrame.RewardClaiming:ClearAllPoints()
    RecruitAFriendFrame.RewardClaiming:SetAllPoints(RAFFrame.claming)
    RecruitAFriendFrame.RewardClaiming.Background:SetAllPoints(RAFFrame.claming)

    RecruitAFriendFrame.RewardClaiming.Inset:Hide()
    RecruitAFriendFrame.RewardClaiming.Bracket_TopLeft:Hide()
    RecruitAFriendFrame.RewardClaiming.Bracket_TopRight:Hide()
    RecruitAFriendFrame.RewardClaiming.Bracket_BottomRight:Hide()
    RecruitAFriendFrame.RewardClaiming.Bracket_BottomLeft:Hide()

    RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton:GwSkinButton(false, true)

    RecruitAFriendFrame.RewardClaiming.MonthCount:ClearAllPoints()
    RecruitAFriendFrame.RewardClaiming.MonthCount:SetPoint("TOPLEFT", 120, -15)

    RecruitAFriendFrame.RewardClaiming.NextRewardName:ClearAllPoints()
    RecruitAFriendFrame.RewardClaiming.NextRewardName:SetPoint("TOPLEFT", 120, -48)

    RecruitAFriendFrame.RewardClaiming.EarnInfo:ClearAllPoints()
    RecruitAFriendFrame.RewardClaiming.EarnInfo:SetPoint("TOPLEFT", 120, -33)

    RecruitAFriendFrame.RewardClaiming.NextRewardButton:ClearAllPoints()
    RecruitAFriendFrame.RewardClaiming.NextRewardButton:SetPoint("CENTER", RecruitAFriendFrame.RewardClaiming, "LEFT", 65, 0)
    RecruitAFriendFrame.RewardClaiming.NextRewardButton.CircleMask:Hide()
	RecruitAFriendFrame.RewardClaiming.NextRewardButton.IconBorder:GwKill()
    RecruitAFriendFrame.RewardClaiming.NextRewardButton.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
  

    RecruitAFriendFrame.RecruitList:SetParent(RAFFrame.RecruitList)
    RecruitAFriendFrame.RecruitList:ClearAllPoints()
    RecruitAFriendFrame.RecruitList:SetAllPoints(RAFFrame.RecruitList)

    RecruitAFriendFrame.RecruitList.ScrollFrameInset:GwStripTextures()
    GW.HandleTrimScrollBar(RecruitAFriendFrame.RecruitList.ScrollBar)
    GW.HandleAchivementsScrollControls(RecruitAFriendFrame.RecruitList)
    RecruitAFriendFrame.RecruitList.ScrollBox:SetSize(433, 420)

    RecruitAFriendFrame.RecruitList.Header:SetSize(450, 20)
    RecruitAFriendFrame.RecruitList.Header.Background:Hide()
    RecruitAFriendFrame.RecruitList.Header.RecruitedFriends:SetFont(DAMAGE_TEXT_FONT, 20)
    RecruitAFriendFrame.RecruitList.Header.RecruitedFriends:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    RecruitAFriendFrame.RecruitmentButton:SetParent(RAFFrame.RecruitList)
    RecruitAFriendFrame.RecruitmentButton:ClearAllPoints()
    RecruitAFriendFrame.RecruitmentButton:SetPoint("BOTTOMLEFT", RecruitAFriendFrame.RecruitList.ScrollBox,  "BOTTOMLEFT", 4, -20)
    RecruitAFriendFrame.RecruitmentButton:GwSkinButton(false, true)

    RecruitAFriendFrame.SplashFrame.OKButton:GwSkinButton(false, true)

    RecruitAFriendRewardsFrame.CloseButton:GwSkinButton(true)
    RecruitAFriendRewardsFrame.CloseButton:SetSize(20, 20)
    RecruitAFriendRewardsFrame:GwStripTextures()
    RecruitAFriendRewardsFrame:GwCreateBackdrop(GW.skins.constBackdropFrame, true)
    hooksecurefunc(RecruitAFriendRewardsFrame, "UpdateRewards", RAFRewards)
    RAFRewards()
      ]]--
end
GW.LoadRecruitAFriendList = LoadRecruitAFriendList