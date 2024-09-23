local _, GW = ...

local function RAFRewardQuality(button)
    local color = button.item and button.item:GetItemQualityColor()
    if color and button.Icon then
        button.Icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
    end
end

local function RAFRewards()
    for reward in RecruitAFriendRewardsFrame.rewardPool:EnumerateActive() do
        local button = reward.Button
        button.IconOverlay:SetAlpha(0)
        button.IconBorder:SetAlpha(0)

        GW.HandleIcon(button.Icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)
        RAFRewardQuality(button)

        local icon = button.Icon
        icon:SetDesaturation(0)

        local text = reward.Months
        text:SetTextColor(1, 1, 1)
    end
end

local function LoadRecruitAFriendList(tabContainer)
    local RAFFrame = CreateFrame("Frame", "GwRAFWindow", tabContainer, "GwRAFWindow")
    for tab in RecruitAFriendRewardsFrame.rewardTabPool:EnumerateActive() do
        tab:HookScript("OnClick", function(self)
            RecruitAFriendFrame:SetSelectedRAFVersion(self.rafVersion);
        end)
    end

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
    RecruitAFriendFrame.RewardClaiming.MonthCount:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

    RecruitAFriendFrame.RewardClaiming.NextRewardName:ClearAllPoints()
    RecruitAFriendFrame.RewardClaiming.NextRewardName:SetPoint("TOPLEFT", 120, -48)

    RecruitAFriendFrame.RewardClaiming.EarnInfo:ClearAllPoints()
    RecruitAFriendFrame.RewardClaiming.EarnInfo:SetPoint("TOPLEFT", 120, -33)

    RecruitAFriendFrame.RewardClaiming.NextRewardButton:ClearAllPoints()
    RecruitAFriendFrame.RewardClaiming.NextRewardButton:SetPoint("CENTER", RecruitAFriendFrame.RewardClaiming, "LEFT", 65, 0)
    RecruitAFriendFrame.RewardClaiming.NextRewardButton.CircleMask:Hide()
    RecruitAFriendFrame.RewardClaiming.NextRewardButton.IconBorder:SetAlpha(0)
    RecruitAFriendFrame.RewardClaiming.NextRewardButton.IconOverlay:SetAlpha(0)
    RecruitAFriendFrame.RewardClaiming.NextRewardButton.Icon:SetDesaturation(0)
    GW.HandleIcon(RecruitAFriendFrame.RewardClaiming.NextRewardButton.Icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)
    RAFRewardQuality(RecruitAFriendFrame.RewardClaiming.NextRewardButton)
    RecruitAFriendFrame.RewardClaiming.Watermark:SetAlpha(0)
    RecruitAFriendFrame.RewardClaiming.Background:SetAlpha(0)
    RecruitAFriendFrame.RewardClaiming:GwCreateBackdrop(GW.BackdropTemplates.Default, true)

    RecruitAFriendFrame.RecruitList:SetParent(RAFFrame.RecruitList)
    RecruitAFriendFrame.RecruitList:ClearAllPoints()
    RecruitAFriendFrame.RecruitList:SetAllPoints(RAFFrame.RecruitList)

    RecruitAFriendFrame.RecruitList.ScrollFrameInset:GwStripTextures()
    GW.HandleTrimScrollBar(RecruitAFriendFrame.RecruitList.ScrollBar, true)
    GW.HandleScrollControls(RecruitAFriendFrame.RecruitList)
    RecruitAFriendFrame.RecruitList.ScrollBox:SetSize(433, 420)

    RecruitAFriendFrame.RecruitList.Header:SetSize(450, 20)
    RecruitAFriendFrame.RecruitList.Header.Background:Hide()
    RecruitAFriendFrame.RecruitList.Header.RecruitedFriends:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
    RecruitAFriendFrame.RecruitList.Header.RecruitedFriends:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

    RecruitAFriendFrame.RecruitmentButton:SetParent(RAFFrame.RecruitList)
    RecruitAFriendFrame.RecruitmentButton:ClearAllPoints()
    RecruitAFriendFrame.RecruitmentButton:SetPoint("BOTTOMLEFT", RecruitAFriendFrame.RecruitList.ScrollBox,  "BOTTOMLEFT", 4, -20)
    RecruitAFriendFrame.RecruitmentButton:GwSkinButton(false, true)

    RecruitAFriendFrame.SplashFrame.OKButton:GwSkinButton(false, true)

    RecruitAFriendRewardsFrame.CloseButton:GwSkinButton(true)
    RecruitAFriendRewardsFrame.CloseButton:SetSize(20, 20)
    RecruitAFriendRewardsFrame:GwStripTextures()
    RecruitAFriendRewardsFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    RecruitAFriendRewardsFrame.Background:SetAlpha(0)
    RecruitAFriendRewardsFrame.Watermark:SetAlpha(0)
    RecruitAFriendRewardsFrame.Title:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

    hooksecurefunc(RecruitAFriendRewardsFrame, "UpdateRewards", RAFRewards)
    RAFRewards()
end
GW.LoadRecruitAFriendList = LoadRecruitAFriendList