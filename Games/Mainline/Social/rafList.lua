---@class GW2
local GW = select(2, ...)

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

        local text = reward.Months.Text
        text:SetTextColor(1, 1, 1)
    end
end

function GW.SkinRecruitAFriendList()
    -- 12.1: the RAF list is a SocialUI view, only the two dialogs are still global frames
    local RecruitAFriend = SocialUIFrame.RecruitAFriendFrame
    if not RecruitAFriend then return end

    GW.SkinSocialContactsView(RecruitAFriend)

    if RecruitAFriend.NoRecruitsScrollBar then
        GW.HandleTrimScrollBar(RecruitAFriend.NoRecruitsScrollBar)
    end
    if RecruitAFriend.Header then
        RecruitAFriend.Header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end

    local RewardClaiming = RecruitAFriend.RewardClaiming
    if RewardClaiming then
        RewardClaiming.Background:SetAlpha(0)
        RewardClaiming.Watermark:SetAlpha(0)
        RewardClaiming:GwCreateBackdrop(GW.BackdropTemplates.Default)
        RewardClaiming.backdrop:SetFrameLevel(RewardClaiming:GetFrameLevel())
        RewardClaiming.MonthCount.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

        local NextRewardButton = RewardClaiming.NextRewardButton
        if NextRewardButton then
            NextRewardButton.CircleMask:Hide()
            NextRewardButton.IconBorder:SetAlpha(0)
            if NextRewardButton.IconOverlay then
                NextRewardButton.IconOverlay:SetAlpha(0)
            end
            NextRewardButton.Icon:SetDesaturation(0)
            GW.HandleIcon(NextRewardButton.Icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)
            RAFRewardQuality(NextRewardButton)
        end

        RewardClaiming.ClaimOrViewRewardButton:GwSkinButton(false, true)
    end

    -- link dialog (StaticPopupSpecial, still global)
    RecruitAFriendRecruitmentFrame:GwStripTextures()
    RecruitAFriendRecruitmentFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    GW.SkinTextBox(RecruitAFriendRecruitmentFrame.EditBox.Middle, RecruitAFriendRecruitmentFrame.EditBox.Left, RecruitAFriendRecruitmentFrame.EditBox.Right)
    RecruitAFriendRecruitmentFrame.GenerateOrCopyLinkButton:GwSkinButton(false, true)
    RecruitAFriendRecruitmentFrame.CloseButton:GwSkinButton(true)
    RecruitAFriendRecruitmentFrame.CloseButton:SetSize(15, 15)

    -- rewards overview (still global)
    RecruitAFriendRewardsFrame.CloseButton:GwSkinButton(true)
    RecruitAFriendRewardsFrame.CloseButton:SetSize(20, 20)
    RecruitAFriendRewardsFrame:GwStripTextures()
    RecruitAFriendRewardsFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    RecruitAFriendRewardsFrame.Background:SetAlpha(0)
    RecruitAFriendRewardsFrame.Watermark:SetAlpha(0)
    RecruitAFriendRewardsFrame.Title.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    hooksecurefunc(RecruitAFriendRewardsFrame, "UpdateRewards", RAFRewards)
    RAFRewards()
end
