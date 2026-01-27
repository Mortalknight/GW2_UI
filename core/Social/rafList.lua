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

function GW.SkinRecruitAFriendList()
    if not GW.Retail then return end

    RecruitAFriendRecruitmentFrame:GwStripTextures()
    RecruitAFriendRecruitmentFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    GW.SkinTextBox(RecruitAFriendRecruitmentFrame.EditBox.Middle, RecruitAFriendRecruitmentFrame.EditBox.Left, RecruitAFriendRecruitmentFrame.EditBox.Right)
    RecruitAFriendRecruitmentFrame.GenerateOrCopyLinkButton:GwSkinButton(false, true)
    RecruitAFriendRecruitmentFrame.CloseButton:GwSkinButton(true)
    RecruitAFriendRecruitmentFrame.CloseButton:SetSize(15, 15)

    RecruitAFriendFrame.RewardClaiming.Inset:Hide()
    RecruitAFriendFrame.RewardClaiming.Bracket_TopLeft:Hide()
    RecruitAFriendFrame.RewardClaiming.Bracket_TopRight:Hide()
    RecruitAFriendFrame.RewardClaiming.Bracket_BottomRight:Hide()
    RecruitAFriendFrame.RewardClaiming.Bracket_BottomLeft:Hide()

    RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton:GwSkinButton(false, true)

    RecruitAFriendFrame.RewardClaiming.MonthCount:ClearAllPoints()
    RecruitAFriendFrame.RewardClaiming.MonthCount:SetPoint("TOPLEFT", 120, -15)
    RecruitAFriendFrame.RewardClaiming.MonthCount:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

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
    RecruitAFriendFrame.RewardClaiming:GwCreateBackdrop(GW.BackdropTemplates.Default)
    RecruitAFriendFrame.RewardClaiming.backdrop:SetFrameLevel(RecruitAFriendFrame.RewardClaiming:GetFrameLevel())

    RecruitAFriendFrame.RecruitList.ScrollFrameInset:GwStripTextures()
    GW.HandleTrimScrollBar(RecruitAFriendFrame.RecruitList.ScrollBar, true)
    GW.HandleScrollControls(RecruitAFriendFrame.RecruitList)
    RecruitAFriendFrame.RecruitList.ScrollBox:SetSize(433, 420)

    RecruitAFriendFrame.RecruitList.Header:SetSize(450, 20)
    RecruitAFriendFrame.RecruitList.Header.Background:Hide()
    RecruitAFriendFrame.RecruitList.Header.RecruitedFriends:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
    RecruitAFriendFrame.RecruitList.Header.RecruitedFriends:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

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
